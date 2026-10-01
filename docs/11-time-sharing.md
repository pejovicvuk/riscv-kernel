# 11 - Time sharing (preemption on the timer interrupt)

Files: `src/riscv.cpp` (branch code==1), `inc/tcb.hpp` + `src/tcb.cpp`
(tick, usedTicks, timeSlice, reset in switchToNext), `src/main.cpp`
(order in which interrupts are enabled)

We first implemented this as the only piece of Part 4. Part 4 is now
complete ([chapter 12](12-sleep-console-periodic.md)), and the timer branch also calls
`TCB::wakeSleepers()` before tick (to wake threads put to sleep with time_sleep).

## What an asynchronous context switch is

Until now a thread lost the CPU only when it asked for it (dispatch, exit,
blocking on a semaphore). That is a synchronous switch. Now the timer (10 ticks per
second, arriving as a software interrupt, code 1) charges time to the running
thread. When the thread uses up its time slice, the kernel takes it off the CPU from the interrupt,
without its knowledge or consent. That is an asynchronous context switch.

## Flow

1. the thread is doing anything in user mode (sie applies there too, sstatus.SIE is ignored)
2. timer tick -> trap -> trap.S saves the registers on the
   thread's stack -> handleSupervisorTrap, branch code==1
3. `Riscv::mc_sip(SIP_SSIP)` acknowledges the interrupt. This has to happen before any thread
   switch, otherwise the request would stay pending
4. `TCB::wakeSleepers()` wakes threads whose time_sleep time has
   expired ([chapter 12](12-sleep-console-periodic.md)); waking happens before charging the time slice
5. `TCB::tick()`: usedTicks++, compared with running->timeSlice.
   Not expired -> return, and the thread notices nothing
6. expired -> `TCB::dispatch()`, the same machinery as a voluntary
   dispatch ([chapter 10](10-code-flow-guide.md), flow 4). The thread freezes in the middle of its own interrupt
   handling, with sepc/sstatus waiting in locals on its stack
7. when its turn comes again, it unwinds through its own trap, does sret and continues from
   the interrupted instruction. For the thread, time skipped ahead and nothing else changed

## Design decisions

- the counter `usedTicks` is static in TCB (the time slice is a property of the running thread;
  spec p. 28: "a single static variable, encapsulated"). The method
  `tick()` returns true when the time slice expires
- time slice reset happens in one place, `switchToNext`, when it picks the new
  running thread. That covers every path (dispatch, exit, blocking,
  preemption), so we cannot forget a branch. Scattering the reset
  across syscall branches would make it easy to miss one, e.g. the
  branch for blocking on a semaphore
- the time slice `timeSlice` is a field in the TCB (default DEFAULT_TIME_SLICE
  from hw.h). The spec says "a thread is created with the default
  time slice size", and "give thread X a longer time slice" is a
  typical modification, which a field makes trivial

## A pitfall we had to solve: the order in main

`tick()` reads `TCB::running`. If a timer interrupt arrives before
the zeroth (main) thread exists, the kernel crashes on a nullptr. So main now enables
interrupts (sie, sstatus.SIE) only after it creates the zeroth thread. The initialization
order is part of the design.

## Why our trap frame handles this without changes

- trap.S saves the t-registers: on an asynchronous interrupt they are "live"
  in the interrupted code (spec pp. 23-24), and test 1 (t1=7) still passes
- the interrupted code's a0 is returned via `ret = a0` (for interrupts the handler returns
  the a0 it found, so the sret path restores it untouched)
- s-registers are saved by the C call chain (calling convention) + contextSwitch (on the thread's stack)
- sepc/sstatus live in locals of handleSupervisorTrap, so they survive both a thread switch
  and nested traps

## Consequences for behavior

- tests 3/4: digits flow continuously without typing, because the keyboard thread no longer
  holds the CPU while waiting. In the console.lib era preemption is what fixed this.
  With our own console from [chapter 12](12-sleep-console-periodic.md), a thread waiting for a character
  blocks properly, so this case no longer needs preemption at all
- tests 1/2: the interleaving of A/B/C/D looks more mixed (switches also happen on time slice expiry,
  not only on dispatch). The "C: t1=7" marker and the Fibonacci values stay the same
- kernel code is not preempted. The kernel is entered via a trap (hardware clears
  sstatus.SIE on entry), and nothing inside the kernel enables interrupts, so
  all kernel code is a natural critical section (spec p. 20)

## Review questions

1. What is the difference between a synchronous and an asynchronous context switch? Where in the code
   can you see each of them?
2. Why is ssip cleared before dispatch, and not after?
3. Where is the time slice reset and why exactly there? Which paths does that cover?
4. Why may interrupts in main be enabled only after the zeroth thread exists?
5. What must survive preemption (t-registers, a0, sepc/sstatus), and
   who saves what?
6. Can preemption interrupt the kernel in the middle of working with the scheduler or a
   semaphore? Why not? (the kernel is entered via a trap, hardware clears
   sstatus.SIE, and nothing inside turns it back on)
