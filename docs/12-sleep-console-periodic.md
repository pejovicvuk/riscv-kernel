# 12 - Part 4 in full: time_sleep, a real console, PeriodicThread

Files: `inc/tcb.hpp` + `src/tcb.cpp` (sleeping list), `inc/ccb.hpp` +
`src/ccb.cpp` (our console), `src/riscv.cpp` (0x31, 0x41/0x42, branches
code==1 and code==9), `src/main.cpp` (CCB::init + drain before shutdown),
`src/syscall_c.cpp` (time_sleep), `src/syscall_cpp.cpp` (Thread::sleep,
PeriodicThread), `Makefile` (console.lib removed)

With this, Part 4 is complete: time sharing ([chapter 11](11-time-sharing.md)), time_sleep,
getc/putc over our own buffers, and PeriodicThread. We no longer need console.lib;
[chapter 08](08-official-tests.md) stays as the history of the 20-point version.

## 1) time_sleep: a sleeping list with relative differences

The idea in one sentence: a sleeping thread is neither ready nor blocked on a
semaphore. It sits in a separate list, sorted by wake-up time, and the timer
branch of the interrupt routine wakes it.

The trick (spec p. 26): each list element stores its time relative to its
predecessor. A thread's absolute time is the sum of differences from the head up to it.

```
time_sleep: A(3), B(5), C(5), D(9)   ->   list: A:3 -> B:2 -> C:0 -> D:4
```

The payoff: a timer tick touches only the head of the list (one decrement in
`wakeSleepers`), no matter how many sleepers there are. The price is a slightly more complex insertion
(`putToSleep`). Walking through the list, you spend your time on the predecessors,
write the remainder into yourself, and subtract your difference from your successor, which
from now on measures from you. Zero (C:0) means "I wake up at the same moment as my predecessor".

Flow of going to sleep (syscall 0x31):

1. `syscall_c.cpp`, time_sleep: a0=0x31, a1=number of ticks, ecall
2. `riscv.cpp` case 0x31 -> `TCB::putToSleep(a1)`
3. insertion into the list (`TCB::next` is reused, since a thread is in at most one
   queue: while sleeping it is neither in the scheduler nor at a semaphore)
4. `switchToNext()`: the thread freezes in the middle of putToSleep, on its own stack,
   the same way as blocking on a semaphore ([chapter 09](09-semaphores.md) / [chapter 10](10-code-flow-guide.md), flow 6)

Flow of waking up (timer branch, code==1):

1. `mc_sip` acknowledges the interrupt
2. `TCB::wakeSleepers()`: decrement the head; while the head is at zero,
   remove it and `Scheduler::put` it (several threads can share the same moment)
3. only then `TCB::tick()` and possible preemption. Waking goes first,
   so the woken thread is already in the queue when scheduling starts

Pitfall in wakeSleepers: first advance sleepHead, then call Scheduler::put,
because put overwrites the next pointer.

## 2) A real console: CCB (console control block)

Until now (20-point version), getc/putc went through the provided console.lib (__getc/__putc
+ console_handler). Part 4 requires our own buffers, so we removed console.lib
from the Makefile, and the kernel gets a fourth class: CCB, all-static
like Scheduler and MemoryAllocator.

Architecture (spec p. 27): two circular buffers, two producer/consumer
pairs, three semaphores. These are plain kernel SCBs, not sem_open, because the kernel does not
make system calls to itself.

```
INPUT:  keyboard -> controller --interrupt--> [interrupt routine = producer]
        -> inputBuffer -> [getc syscall = consumer; empty buffer = block]
        semaphore: inputItems (init 0, counts characters)

OUTPUT: [putc syscall = producer; full buffer = block] -> outputBuffer
        -> [KERNEL OUTPUT THREAD = consumer, sends with polling] -> controller
        semaphores: outputItems (init 0), outputSpace (init BUFFER_SIZE)
```

- circular buffer: read at head, write at tail; "(tail+1)%N == head" means
  full. We sacrifice one slot to tell full from empty, so we need no
  separate counter
- input interrupt (code==9, `CCB::handleInterrupt`): we do
  plic_claim/plic_complete ourselves (console_handler used to do it).
  We collect characters in a loop while there are any. If the buffer is full, we read the character from the
  controller and discard it (the spec allows this)
- `getc` (0x41): wait(inputItems). An empty buffer puts the thread to sleep right there,
  in the middle of the kernel, like sem_wait; the interrupt routine wakes it with a signal
- `putc` (0x42): wait(outputSpace), so a full buffer blocks the caller
  (the spec offers blocking or an error; blocking comes naturally with a free-space semaphore),
  then write, then signal(outputItems)
- output thread (`outputBody`, systemLevel=true): an endless loop of
  wait(outputItems) -> take a character -> poll the transmit-ready bit
  -> write to the controller -> signal(outputSpace). It is a system thread because it writes
  directly to the controller's registers (spec: bodies of internal threads run in S-mode)

### Why this is safe without any locking

- getc/putc run inside a trap. The hardware disabled interrupts on entry, which gives us
  a natural critical section
- the output thread runs in S-mode with interrupts masked (a system thread
  never drops down via sret, and the kernel was entered with SIE=0). Nothing interrupts its access
  to the buffer; it gives up the CPU only when it blocks on an
  empty buffer
- the interrupt routine is itself a trap, so it is atomic with respect to everyone

### Consequence: getc no longer holds the CPU

The old console.lib waited for a character while holding the CPU (it enabled interrupts so
the timer could preempt it, see [chapter 08](08-official-tests.md)). Our getc blocks the thread properly: the thread
leaves all queues, and other threads get the CPU immediately, without any
preemption. Nested traps hardly happen anymore (nothing in the kernel
enables interrupts), but we still need the "sepc/sstatus in locals" design:
it carries thread switches in the middle of a trap (dispatch, blocking, preemption).

### System shutdown: drain

The test's last messages sit in the output buffer. If main wrote
0x5555 right away, they would vanish together with the emulator. So before shutdown main spins in
`while (!CCB::outputEmpty()) thread_dispatch()`, yielding the CPU to the
output thread until it sends the last character.

### Who is the "idle" thread?

When all user threads are sleeping (test 5), some thread must be ready,
otherwise switchToNext panics with "no ready threads". In our kernel that thread is main:
in the loop `while (!userMainDone) thread_dispatch()` it never
blocks, so the scheduler is never empty. That is why we do not need the spec's
"idle thread"; main plays that role for free.

## 3) PeriodicThread and Thread::sleep

- `Thread::sleep(t)` = time_sleep(t), replacing the old stub
- `PeriodicThread::run()` (an override of the existing virtual run):
  `while (period > 0) { periodicActivation(); sleep(period); }`
- catch: the spec (p. 11) forbids new fields and new virtual methods in
  these classes (binary compatibility with app.lib), so terminate()
  has no flag of its own. Solution: period=0 is the termination sentinel (a period
  of 0 makes no sense anyway). Overriding run does not change the vtable layout,
  since the slot already exists, which is why it is allowed
- terminate() from another thread: the current sleep completes, then the loop breaks
  on the check. terminate() from inside the activation itself: the check before sleep catches it

## Official tests 5 and 6

- test 5 (`ThreadSleep_C_API_test`): two threads sleep 10 and 20 ticks,
  each printing "Hello 10/20 !" 5 times. The main test thread busy-waits for completion
  (`while (!(finished[0] && finished[1]))`), which works only because of
  preemption. Expected rhythm: "Hello 10" twice as often as "Hello 20"
- test 6 (`ConsumerProducer_CPP_API_test`): keyboard + n producers
  + consumer over BufferCPP. It uses Thread::sleep, getc and Console::putc,
  so it exercises all of Part 4 at once. ESC ends the test
- in the test 6 file, we removed the unused counter `i` from ProducerKeyborad
  (the official file fails under our -Wall -Werror; logic untouched)

## Review questions

1. Why does the sleeping list store relative differences rather than absolute times?
   What is the cost, and what is the gain?
2. Where exactly does a thread that called time_sleep sleep? Compare it with a thread
   blocked on a semaphore. What is the only difference?
3. Why does the timer branch wake the sleepers first and only then call tick?
4. List both producer/consumer pairs of the console and who is who in each pair.
5. Why is the output direction driven by a thread, and the input by the interrupt routine? (answer: a character
   from the keyboard arrives via an interrupt and must be picked up immediately; sending can
   be deferred and polled whenever it suits us)
6. Why may getc/putc block the caller, while the interrupt routine must never
   block? What does the interrupt routine do when the input buffer is full?
7. Why do buffer accesses not need a mutex? (three contexts, all with
   interrupts masked)
8. Why is the output thread a system thread (systemLevel=true)?
9. What is the drain loop in main before shutdown for?
10. How does terminate() work without a single new field in PeriodicThread?
11. What would break if main could block while all user threads are
    sleeping? Who is our "idle" thread?
