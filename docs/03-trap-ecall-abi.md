# 03 - Traps, ecall and system calls

Files: `src/trap.S`, `src/riscv.cpp`, `src/syscall_c.cpp`, `inc/syscall_c.h`

## The idea in one sentence

User code is not allowed to do privileged things on its own, so it "rings the
kernel's doorbell" with the `ecall` instruction. The processor then switches to
supervisor mode and jumps to a single address (`stvec`), where our routine
figures out who is ringing and why.

## What the hardware does automatically on a trap (ecall/exception/interrupt)

```
1. sepc    <- pc               (address of the ecall instruction ITSELF / of the interrupted instruction)
2. scause  <- reason           (top bit: 1=interrupt, 0=exception/ecall; the rest: code)
3. sstatus.SPP  <- mode we came from   (0=user, 1=supervisor)
   sstatus.SPIE <- old value of SIE
   sstatus.SIE  <- 0           (mask interrupts while handling)
4. mode    <- supervisor
5. pc      <- stvec            (our trapHandler routine)
```

`sret` does the reverse: `pc <- sepc`, `mode <- SPP`, `SIE <- SPIE`.

Important codes in scause (table from the project specification, p. 15):

```
top bit 1, code 1  -> software interrupt (in our case: the timer)
top bit 1, code 9  -> external hardware interrupt (console)
top bit 0, code 2  -> illegal instruction
top bit 0, code 8  -> ecall from user mode
top bit 0, code 9  -> ecall from supervisor mode
```

## ABI convention (how the caller and the kernel agree)

- `a0` = system call code (0x01 mem_alloc, 0x02 mem_free, 0x11 thread_create...)
- `a1, a2, ...` = arguments, in order
- the return value comes back in `a0`
- mem_alloc specifics: at the ABI level the size is in blocks
  (the C API function rounds bytes up to blocks before the ecall)

## Flow: mem_alloc(100) from start to finish

```
[user code]
1. mem_alloc(100)                       C API function
2. numBlocks = (100+63)/64 = 2          bytes -> blocks
3. a0=0x01, a1=2, ecall                 "ringing the doorbell"

[hardware]
4. sepc/scause/sstatus are filled in, jump to stvec

[trap.S - trapHandler]
5. push 15 registers onto the stack     (ra, t0-t6, a1-a7 - see lesson 04 for why!)
6. call handleSupervisorTrap            a0..a3 are STILL the original registers
                                        (trap.S did not touch them before the call) - so
                                        the C function reads the ABI arguments as parameters

[riscv.cpp - handleSupervisorTrap]
7. reads scause: top bit 0, code 9      -> ecall (from supervisor mode)
8. switch(a0): 0x01                     -> MemoryAllocator::alloc(2 * 64)
9. sepc += 4                            important: sepc points to the ecall itself;
                                        without this, sret returns TO the ecall -> endless loop
10. return ret                          the result goes into a0

[trap.S]
11. pop 15 registers from the stack     (a0 is NOT restored - it carries the result!)
12. sret                                pc<-sepc (after the ecall), mode<-SPP, SIE<-SPIE

[user code]
13. mem_alloc returns (void*)a0         the user got a pointer and knows nothing about the trap
```

## Why sepc += 4 only for ecall

- ecall: sepc = address of the ecall instruction itself. If we do not advance
  it, we loop forever.
- asynchronous interrupt: sepc = address of the interrupted, not yet executed
  instruction. That instruction still has to run, so we leave sepc alone.

## The C API layer (syscall_c.cpp)

A trick for targeting exact registers without writing a .S file:

```cpp
register uint64 code   asm("a0") = 0x01;   // variable bound specifically to a0
register uint64 blocks asm("a1") = numBlocks;
asm volatile("ecall" : "=r"(code) : "r"(code), "r"(blocks) : "memory");
return (void*)code;                        // a0 after the ecall = the result
```

## Review questions

1. Why is one interrupt routine enough for all causes? (stvec, scause)
2. How does handleSupervisorTrap "magically" receive the ABI arguments as C
   parameters?
3. What is the difference between `sret` and `ret`?
4. What would happen without `sepc += 4` for ecall? And what if we did it for
   interrupts?
5. Why is `a0` not saved/restored in trap.S like the other registers?
