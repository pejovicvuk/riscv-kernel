# 07 - Threads in user mode (U-mode)

Files: `src/tcb.cpp`, `inc/tcb.hpp`, `src/main.cpp`

## Why

The architecture in the project specification has the kernel run privileged
and user code (thread bodies) run unprivileged. Until this point everything ran
in S-mode. That works, but it hands a user thread the keys to the whole house:
it can disable interrupts, overwrite stvec, and so on.

The concrete reason is **official test 7**. It executes `csrr t6, sepc` (a
privileged instruction) in a thread body and expects the program to crash. In
S-mode the instruction goes through and the test fails. In U-mode it raises an
illegal instruction exception, the kernel panics, and the test passes. It is
the only test that passes by crashing the program.

## Design decisions

1. **userWrapper reads body/arg directly from the TCB** (instead of passing
   them through registers before sret). Reason: on this platform everyone
   shares one address space with no memory protection, so the read is
   physically possible and reliable. The privilege boundary is about
   instructions (csr/sret), not memory. The alternative (registers + sret in
   asm) breaks easily when the code changes.
2. **The interrupt mask lives in the sie register** (ssie bit 1 + seie bit 9).
   Reason: sie applies in both modes (U-mode ignores sstatus.SIE), so one
   mechanism covers everything. (In this phase both bits were off. From
   lessons 08/11 on they are enabled, and sstatus.SIE=1 is set alongside them
   only so that interrupts also arrive while main is on the processor in
   S-mode. See [lesson 04](04-interrupts-masking-bug.md) for the two-level
   decision model.)

## How a thread drops into U-mode: the birth flow (extended)

The only way down (S -> U) is `sret` with SPP=0. The wrapper now has two
branches:

```
contextSwitch -> ret -> threadWrapper       (S-mode, as before)
  reapZombie()
  system thread (systemLevel)?  -> body right away, here, privileged
  user thread:
     sepc    <- address of userWrapper
     sstatus.SPP <- 0            "sret leads into user mode"
     sret  ========== DROP INTO U-MODE ==========
userWrapper                                  (U-mode!)
  running->body(running->arg)                the body runs unprivileged
  thread_exit()                              ecall - the only way back into the kernel
```

Code (tcb.cpp):

```cpp
void TCB::threadWrapper() {
    reapZombie();
    if (running->systemLevel) {
        running->body(running->arg);
        running->finished = true;
        dispatch();
    }
    uint64 target = (uint64)&userWrapper;
    asm volatile("csrw sepc, %0" : : "r"(target));
    uint64 sstatus;
    asm volatile("csrr %0, sstatus" : "=r"(sstatus));
    sstatus &= ~(1UL << 8);                    // spp = 0
    asm volatile("csrw sstatus, %0" : : "r"(sstatus));
    asm volatile("sret");
}

void TCB::userWrapper() {
    running->body(running->arg);
    thread_exit();      // ecall - the only legal return into the kernel
    for (;;) {}         // unreachable; so that it never "falls off"
}
```

The `systemLevel` flag in the TCB keeps internal kernel threads (the zero
thread, and later the console thread from Part 4) in S-mode. The project
specification requires that "their body executes in system mode".

## Returning to the right mode, for free

When a U-thread does an ecall, the hardware writes SPP=0 (came from U-mode).
handleSupervisorTrap saves sstatus (with that SPP=0) into a local variable
right away. That local is part of the thread's context, and the handler
restores it before sret. As a result:

- a U-thread returns to U-mode from every syscall (its sstatus carries SPP=0)
- an S-thread (main) returns to S-mode (its sstatus carries SPP=1)

This takes no extra code. The "sepc/sstatus into locals" fix from
[lesson 06](06-thread-syscalls.md) already handles the per-thread mode, which
is why we were saving sstatus back then.

## Consequences of U-mode (reminder from lesson 04)

- U-mode ignores sstatus.SIE, which is why the mask goes into sie (applies everywhere)
- ecall from U-mode gives scause=8 (from S-mode 9), and the handler accepts both
- a privileged instruction in U-mode raises illegal instruction (c=2) and the kernel panics
- MMIO access (kputs) from U-mode works because the platform has no memory protection

## How it is tested

1. Ordinary test: same output as before (ABABABABAB + "both threads finished"), but the bodies now run in U-mode, and
   thread_dispatch arrives as scause=8
2. Mode check ("our test 7"): in workerA uncomment
   `asm volatile("csrr t6, sepc");`. Expect PANIC cause=0x2 (illegal
   instruction), which proves the body runs unprivileged. Comment the line out
   again afterwards.

## Review questions

1. What is the only gate from S-mode to U-mode, and how does the wrapper use it?
2. Why may userWrapper READ the TCB, but not call TCB::dispatch() directly?
3. How does a U-thread return to U-mode after a syscall, and an S-thread to S-mode? Where is that information kept?
4. Why did the mask have to move from sstatus.SIE to sie?
5. What exactly does test 7 check, and why is a program "crash" its pass condition?
6. Which threads stay system threads, and why?
