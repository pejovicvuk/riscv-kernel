# Lessons

A walkthrough of the project: what we built, how it works, and why we
built it that way. Every lesson has "flow" examples that trace, step by
step, how things happen, and ends with review questions.

## How to read

1. Read lessons 01-04 in order: platform, allocator, trap/ecall, interrupts.
   Everything later builds on these four.
2. Lessons 05-07: threads. First the concept (05), then threads through
   system calls (06), then the drop into user mode (07). The code
   samples in 05 are a historical snapshot; a note at the end of that
   lesson says what has changed since.
3. Lessons 08-09: the official tests and semaphores.
4. Lesson 10 is the main map: 7 flows through the current code, from a
   user-level line down to the kernel and back. Read it with the code open.
5. Lessons 11-12: Part 4 of the project. Time sharing first, then
   `time_sleep`, the console, and `PeriodicThread`.

The lessons were written chronologically and keep the history of design
decisions (including wrong attempts and why they were wrong). Where a later
lesson changed something, the earlier one has a note at the top or at the
place of the change.

## Contents

| # | Lesson |
|---|--------|
| 01 | [Platform and environment](01-platform-and-environment.md) |
| 02 | [Memory allocator (Part 1)](02-memory-allocator.md) |
| 03 | [Trap, ecall and system calls](03-trap-ecall-abi.md) |
| 04 | [Interrupts, masking and the big bug](04-interrupts-masking-bug.md) |
| 05 | [Threads: TCB, Scheduler, context switch](05-threads-skeleton.md) |
| 06 | [Threads through system calls](06-thread-syscalls.md) |
| 07 | [Threads in user mode (U-mode)](07-user-mode-threads.md) |
| 08 | [Official tests + console.lib console (history)](08-official-tests.md) |
| 09 | [Semaphores (Part 3)](09-semaphores.md) |
| 10 | [Code flow guide (reading the code)](10-code-flow-guide.md) |
| 11 | [Time sharing (preemption)](11-time-sharing.md) |
| 12 | [Part 4 in full: sleep, console, PeriodicThread](12-sleep-console-periodic.md) |

## Current state

All parts (1-4) are done. All official tests pass: 1, 2, 3, 4, 5, 6 and 7
(test 7 "passes by failing": it is expected to end with `PANIC cause=2`).

Summary by part:

- **Part 1 (memory allocator):** `mem_alloc` and `mem_free` through the full
  ecall chain; free-block merging verified (the heap returns to a single
  block, zero leaks).
- **Trap handler:** saves registers, keeps `sepc`/`sstatus` per thread (in
  locals), panics on an unknown cause; interrupts are masked per type in the
  `sie` register (works in both modes).
- **Part 2 (threads):** system calls 0x11-0x13, C API, thread bodies run in
  U-mode, zombie cleanup, t-registers survive a dispatch. `userMain` runs as
  a thread (as the project specification requires).
- **Part 3 (semaphores):** `SCB`, calls 0x21-0x26, a third thread state
  (blocked), global `new`/`delete` for the user layer (`_new.cpp`).
- **C++ API (`syscall_cpp.hpp`/`.cpp`):** `Thread`, `Semaphore`,
  `PeriodicThread` and `Console` as thin wrappers; `runWrapper` chooses
  between `body` and `run()` (rule from the specification).
- **Time sharing:** preemption on the timer interrupt (`TCB::tick` +
  dispatch), per-thread time slice, reset in `switchToNext`; interrupts are
  enabled in `main` only after the initial thread exists.
- **Part 4:** `time_sleep` (0x31) with a sleep list that stores relative
  time differences in the TCB; a real console, the `CCB` class (circular
  buffers + 3 semaphores + an output kernel thread; the interrupt handler
  does `plic_claim`/`plic_complete` itself), replacing the earlier
  `console.lib` stage (lesson 08); `Thread::sleep` and `PeriodicThread`
  (terminated via `period = 0`); before shutdown `main` drains the output
  buffer.

## System layers (big picture)

```
user program (test/)                <- official tests + custom test 8
C++ API (Thread, Semaphore...)      <- thin wrapper around the C API
C API (mem_alloc, thread_...)       <- packs registers + ecall
ABI (ecall, a0=code, a1..=args)     <- software interrupt
kernel (TCB, Scheduler, SCB, CCB,   <- the core; entry ONLY through trap.S,
        MemoryAllocator)               exit ONLY through sret
hw.lib (hardware access)            <- provided by the course
```
