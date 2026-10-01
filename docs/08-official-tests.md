# 08 - Official tests + console via console.lib

> This chapter describes the 20-point (base) phase of the project.
> Part 4 removed console.lib, and the console is now our own (class CCB,
> see [chapter 12](12-sleep-console-periodic.md)). The history below still
> explains why the 20-point version had to use console.lib (project
> specification, p. 31) and how we got there.

Files: `test/` (official files), `src/userMain.cpp` (official menu,
adapted), `inc/syscall_c.h` (renamed from .hpp), `src/riscv.cpp`
(case 0x41/0x42 + branch for the console interrupt), `src/syscall_c.cpp` (getc/putc),
`lib/console.h` (provided: __getc, __putc, console_handler)

## What was imported and why exactly that

For now, `test/` contains only the files for tests we can run:
printing.{hpp,cpp}, lock.S, Threads_C_API_test.{hpp,cpp},
System_Mode_test.{hpp,cpp}. The others (semaphores, sleep, C++ API) get added
when their functionality arrives, not earlier. The makefile compiles every
.cpp file in the project (find . -name "*.cpp"), so a test that calls
sem_open would cause an "undefined reference" at link time.

Housekeeping:
- our header was renamed to `syscall_c.h`, since that is how the tests include it
- our old userMain was replaced with the official menu (LEVEL_1/2 = 1, 3/4 = 0);
  todo markers show what gets re-enabled when the C++ API, semaphores and Part 4 arrive
- after renaming the header you have to run `make clean` (stale .d files in
  build/ remember the dependency on the deleted .hpp)

## Console via console.lib (correction: at first we wrongly used polling)

History: the first version of getc/putc polled the CONSOLE_STATUS/RX/TX
registers by hand, with all interrupts masked. The tests passed, but this was
wrong for the 20-point version. The project specification (p. 31) says that
whoever does not implement Part 4 must use the provided library `console.lib`
(functions `__getc`/`__putc`) and call `console_handler` from the interrupt
routine on a console interrupt. A custom getc/putc with buffers belongs to
Part 4 (see the grading table, p. 30).

How it works now (flow):

1. syscall 0x41 -> `ret = __getc()`: the library looks at its own input buffer.
   If the buffer is empty, it waits, and while waiting it enables interrupts
   by itself for a while (spec: "these functions may enable interrupts during their execution")
2. key press -> console interrupt (scause interrupt bit=1, code 9) -> our
   handleSupervisorTrap -> branch code==9 -> `console_handler()`. The handler does
   plic_claim/plic_complete itself (we verified this in the library's symbols) and moves
   characters controller->input buffer and output buffer->controller
3. return into __getc, which now has a character and returns it
4. syscall 0x42 -> `__putc(c)`, same principle in the opposite direction

Consequences for interrupt masking (main.cpp):
- sie: the console bit (seie, bit 9) must be enabled. Without it console_handler never
  fills the buffer and __getc hangs forever. The timer (ssie, bit 1) is unmasked;
  for now the handler only acknowledges it (clears ssip), and real handling comes with Part 4
- sstatus.SIE = 1, so interrupts arrive even while main (S-mode) is on the CPU;
  user-mode threads ignore this bit, and for them sie applies directly

Nested trap: __getc/__putc enable interrupts in the middle of handling our
syscall, so a console or timer interrupt can arrive while we are already inside
handleSupervisorTrap. Our "sepc/sstatus in locals" design (chapters 03/06) handles
this for free. The outer trap keeps its values on the thread's stack, and
the nested one is free to overwrite the CSRs and restore them from its own locals.

This phase had a drawback: __getc waited while holding the CPU.
Other threads did not run while it waited for a character, so tests 3/4 "stuttered"
(digits in bursts, then silence until the next key press). Time sharing fixed
this (preemption on the timer interrupt, [chapter 11](11-time-sharing.md)): the
timer now preempts even a thread waiting in __getc, so the digits flow continuously.

## What the official tests check (read from the code)

- test 1: 4 threads (A,B,C,D) alternate with huge busy-wait loops.
  The interesting part is thread C: it does `li t1, 7`, then thread_dispatch, then checks
  whether t1 survived the context switch. This tests saving the t-registers
  per thread, which is what our trap.S does (t/a/ra onto the thread's stack on a trap).
  D does the same with `li t1, 5`: two threads, the same register, different values.
- test 7: thread B at i==10 executes `csrr t6, sepc`. In user mode that is an illegal
  instruction -> panic -> no regular end, which counts as a PASS. The message
  "Test did not finish successfully" must not appear.
- printing wraps output in a spin-lock (copy_and_swap from lock.S, lr.w/sc.w atomics).
  It keeps the output from interleaving when threads switch in the middle of a string.

## How to run

```
make clean && make && make qemu     (inside the container!)
menu: type 1 then enter -> test 1 (takes a LONG time - busy loops, watch the A:/B:/C:/D: lines)
      type 7 then enter -> expected PANIC cause=0x2 (that is a pass!)
```

To exit qemu if a test runs too long: ctrl-a then x.

## Review questions

1. Why must the 20-point version use console.lib instead of manual polling? (spec pp. 30-31)
2. Who calls plic_claim/plic_complete in our project? (not us, console_handler does)
3. What happens when an interrupt arrives in the middle of handling a getc syscall? Why
   does the nested trap not clobber our sepc/sstatus?
4. Why must the console bit (9) in sie be enabled, while the timer bit (1) is
   optional before Part 4? What does sstatus.SIE do and whom does it affect?
5. What does test 1 check with the li t1,7 / dispatch / mv trick? Where does our code guarantee it?
6. Why must printString hold a spin-lock around the putc loop?
7. Why does test 7 "pass by crashing"? Which message must not appear?
8. Why did tests 3/4 "stutter" before time sharing, and how does
   preemption fix it? (key: __getc waits while holding the CPU, but enables
   interrupts, so the timer can preempt it)
