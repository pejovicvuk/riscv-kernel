# 10 - Code flow guide: from user code to the kernel and back

This is a map for reading the code. Each flow is one story: it starts at a
line the user writes and follows it through every layer down to the kernel
and back. Read flow by flow: open the file from step 1, read the indicated
lines, move on to step 2, and so on. Line numbers refer to the current state
of the code; if the code changes, go by the function names.

The flows are ordered so that each one builds on the ones before it, so
read them in order and don't skip.

## File map (who is who)

| Layer | File | Role |
|-------|------|------|
| user program | `test/*.cpp`, `src/userMain.cpp` | official tests; knows nothing about the kernel, only the API |
| C++ API | `inc/syscall_cpp.hpp`, `src/syscall_cpp.cpp` | Thread/Semaphore/Console classes, thin wrappers around the C API |
| new/delete | `src/_new.cpp` | global new/delete for the user layer -> mem_alloc/mem_free |
| C API | `inc/syscall_c.h`, `src/syscall_c.cpp` | functions that pack arguments into registers and execute `ecall` |
| gate | `src/trap.S` | the only entry into the kernel (stvec points here); saves/restores registers |
| dispatcher | `src/riscv.cpp` | `handleSupervisorTrap`: reads scause, branches on the call code |
| kernel: threads | `inc/tcb.hpp`, `src/tcb.cpp` | TCB, threadWrapper/userWrapper, dispatch, zombie |
| kernel: switch | `src/contextSwitch.S` | freeze one thread, unfreeze another |
| kernel: queue | `inc/scheduler.hpp`, `src/scheduler.cpp` | FIFO queue of ready threads |
| kernel: semaphores | `inc/scb.hpp`, `src/scb.cpp` | SCB: counter + FIFO queue of blocked threads |
| kernel: memory | `inc/memoryAllocator.hpp`, `src/memoryAllocator.cpp` | free list, first-fit |
| kernel: console | `inc/ccb.hpp`, `src/ccb.cpp` | CCB: our own buffers + output thread (Part 4, lesson 12) |
| start/end | `src/main.cpp` | machine setup, initial thread, CCB::init, userMain as a thread |

One picture sits behind the whole project. The user layer and the kernel
share the same address space (there is no memory protection), but the
privilege boundary is real: the kernel is entered only through the `ecall`
instruction and left only through the `sret` instruction. Everything else
is ordinary function calls within one layer.

---

## Flow 1: boot, or how the system gets to userMain at all

File: `src/main.cpp` (read the whole file, it is short)

1. The course library (hw.lib) brings up the machine, prints "xv6 kernel is
   booting" and calls our `main()` in supervisor mode.
2. `main.cpp` (csrw stvec): the address of the entry point `trap` from
   trap.S is written into `stvec`. From this moment on, every
   ecall/exception/interrupt jumps here and only here.
3. `main.cpp`: `MemoryAllocator::init()` turns the heap into one large free
   block.
4. `main.cpp`: main gets its own TCB (the "initial thread",
   systemLevel=true) with an empty context and no stack. The reason: when
   main yields the processor for the first time, there has to be a place
   to freeze it (flow 4).
5. `main.cpp`: `CCB::init()` (lesson 12) sets up the console buffers,
   semaphores and the kernel output thread. This happens before interrupts
   are enabled, so the first console interrupt finds the buffers ready.
6. `main.cpp` (sie block): interrupts are enabled per type in the `sie`
   register. Console (seie, bit 9): our CCB::handleInterrupt fills the
   input buffer. Timer (ssie, bit 1): time sharing plus waking sleeping
   threads. We use `sie` because it also applies in user mode, where
   sstatus.SIE is ignored (lessons 04/07). We enable them only now because
   the timer tick reads TCB::running, so the initial thread must exist
   before the first interrupt (lesson 11).
7. `main.cpp` (sstatus block): `sstatus.SIE = 1`, so interrupts also arrive
   while main (S-mode) is on the processor. U-mode threads don't look at
   this bit.
8. `main.cpp`: per the project specification (p. 4), main "starts a
   thread over the userMain function". It does this with a plain
   `thread_create` (ecall works from S-mode too) over the wrapper
   `userMainWrapper`, then spins in `while (!userMainDone) thread_dispatch()`,
   yielding the processor until the user program finishes. This way the test
   menu runs in U-mode, like all user code.
   One catch: we detect the end through the `userMainDone` flag, which the
   wrapper raises before thread_exit. We can't use the thread handle,
   because zombie cleanup eats the TCB of a finished thread (flow 5), so
   reading the handle would be a use-after-free.
9. `main.cpp`: once the flag is set, main first runs a drain loop
   (`while (!CCB::outputEmpty()) thread_dispatch()`) so the output thread
   sends the last characters. Then it writes 0x5555 to 0x100000, which shuts
   down the emulator.

There is nothing magic about main. After step 4 it is an ordinary thread
among threads (always ready, never blocked) that happens to be the first
one, and its context only gets written by the first dispatch. Because it
never blocks, main also serves as our idle thread: the scheduler is never
empty, so the "no ready threads" panic cannot happen even when all user
threads are sleeping (test 5).

---

## Flow 2: anatomy of a system call, `mem_alloc` (the simplest example)

This is the most important flow, since all the others are variations of it.
Scenario: user code says `new BufferCPP(n)` or calls `mem_alloc(...)`
directly.

Files in order: `_new.cpp` -> `syscall_c.cpp` -> `trap.S` ->
`riscv.cpp` -> `memoryAllocator.cpp` -> back the same way.

1. `src/_new.cpp:10-12`: the global `operator new` forwards to
   `mem_alloc(size)`. (If the user called mem_alloc directly, skip this.)
2. `src/syscall_c.cpp:4-19`: `mem_alloc` rounds bytes up to blocks (ABI
   call 0x01 takes blocks), packs a0=0x01, a1=blocks and executes `ecall`.
3. Hardware (no code to read here, you only need to know it): ecall sets
   scause=8 (from U-mode) or 9 (from S-mode), sepc=the address of the ecall
   itself, sstatus.SPP=the mode we came from, and pc jumps to stvec ->
   trapHandler.
4. `src/trap.S:11-26`: pushes ra, t0-t6, a1-a7 onto the current thread's
   stack. a0 is left out on purpose, because it will carry the call's
   return value, so we deliberately do not restore the old value (lesson 04
   covers the bug that bit us here).
5. `src/trap.S:28`: `call handleSupervisorTrap`. At that moment registers
   a0..a4 still hold the values the user packed, so the C function sees
   them as its parameters. That is all there is to passing arguments.
6. `src/riscv.cpp:13-20`: scause/sepc/sstatus are read immediately into
   local variables. Locals live on this thread's stack. If handling the
   trap switches threads, other threads' traps will overwrite the global
   CSRs, while our values wait safely on our stack (flows 4 and 6 depend on
   this).
7. `src/riscv.cpp:47-49`: the ecall branch does `sepc += 4` in the local
   copy, so that on return execution continues after the ecall instead of
   on it.
8. `src/riscv.cpp:51-53`: `switch (a0)`, case 0x01 calls
   `MemoryAllocator::alloc(a1 * MEM_BLOCK_SIZE)`. Read the allocator
   itself too (`src/memoryAllocator.cpp`): first-fit through the free list,
   a header in the first 16B, and the rest of the block goes back to the
   list.
9. `src/riscv.cpp:125-128`: before exiting, our local sstatus and sepc
   are written back into the CSRs, and `return ret` puts the result into a0.
10. `src/trap.S:30-46`: restores all saved registers (not a0, which holds
    the result) and executes `sret`: pc=sepc (the instruction after the
    ecall), mode=SPP.
11. `src/syscall_c.cpp:18`: mem_alloc continues after the ecall. The
    pointer has arrived in `code` (a0); we cast it and return it to the
    user.

Key points:
- The whole path is synchronous: same thread, same stack, only the
  privilege level changes.
- a0 works in both directions: it carries the call code in and the result
  out.
- sepc+=4 happens in a local; the write to the CSR only happens right
  before sret.

---

## Flow 3: birth of a C++ thread, `new WorkerA()` + `start()` (test 2)

Scenario: `test/Threads_CPP_API_test.cpp` (function
`Threads_CPP_API_test`, near the bottom of the file):
`threads[0] = new WorkerA(); threads[0]->start();`

Files in order: test -> `syscall_cpp.cpp` -> `syscall_c.cpp` ->
`riscv.cpp` -> `tcb.cpp` -> `scheduler.cpp`.

1. test: `new WorkerA()`. Operator new goes through all of flow 2
   (allocating the object in the kernel heap via ecall), then the
   constructor runs: `WorkerA():Thread() {}`.
2. `src/syscall_cpp.cpp:13`: the protected `Thread()` sets myHandle=nullptr,
   body=nullptr, arg=nullptr. The thread does not exist yet, only the
   object does.
3. test: `threads[0]->start()`.
4. `src/syscall_cpp.cpp:22-24`: `start()` calls
   `thread_create(&myHandle, runWrapper, this)`. runWrapper is passed as
   the body and this as the argument, which defers the body-or-run decision
   until later (flow 4, step 10).
5. `src/syscall_c.cpp:33-54`: `thread_create` first allocates the thread's
   stack itself via `mem_alloc(DEFAULT_STACK_SIZE)` (a separate, nested
   pass through all of flow 2), then packs a0=0x11, a1=&myHandle,
   a2=runWrapper, a3=this, a4=stack and executes `ecall`. (Specification
   ABI: the caller provides the stack, not the kernel.)
6. `src/riscv.cpp:58-64`: case 0x11 calls
   `TCB::createThread(body, arg, stack, systemLevel=false)`. It passes false
   because threads created via a system call run their body in user mode.
7. `src/tcb.cpp:75-97`: `createThread` does `new TCB(...)`. Careful: this
   is the TCB's own operator new (`tcb.cpp:17-19`), which goes straight to
   MemoryAllocator without an ecall (the kernel must not ecall from inside
   a trap, because it would overwrite its own sepc). Then comes the
   bootstrap trick:
   - `context.sp = stack top - 96` (room for 12 fake s-registers, zeros)
   - `context.ra = &threadWrapper`
   - this forges the thread's "past": it looks as if it fell asleep at the
     entry of threadWrapper (flow 4 explains why it needs exactly this
     shape).
8. `src/tcb.cpp:92`: `Scheduler::put(tcb)` puts the thread at the end of
   the ready queue (`src/scheduler.cpp:8-16`).
9. `src/riscv.cpp:61`: `*(TCB**)a1 = tcb`. Through the pointer, the
   kernel writes the handle straight into the Thread object's `myHandle`.
   ret=0.
10. Back through trap.S/sret into thread_create, then into start(), then
    into the test.

After start(), the thread only sits in the queue. None of its instructions
will execute until someone calls dispatch (flow 4).

---

## Flow 4: dispatch, switching threads + the first wake-up of a new thread

This is the heart of the project. Scenario: thread A (say, main/the
initial thread) calls `thread_dispatch()` or `Thread::dispatch()`, and the
fresh WorkerA from flow 3 comes out of the queue.

Files in order: `syscall_cpp.cpp` -> `syscall_c.cpp` -> `riscv.cpp`
-> `tcb.cpp` -> `contextSwitch.S` -> `tcb.cpp` (threadWrapper) ->
`syscall_cpp.cpp` (runWrapper) -> test (run()).

Part 1: thread A goes under.

1. `src/syscall_cpp.cpp:37-39`: `Thread::dispatch()` -> `thread_dispatch()`.
2. `src/syscall_c.cpp:62-65`: a0=0x13, `ecall` -> trap.S saves thread A's
   registers onto its own stack (flow 2, step 4).
3. `src/riscv.cpp:65-72`: case 0x13 calls `TCB::dispatch()`.
   Remember that thread A's sepc/sstatus are already safe in the locals of
   handleSupervisorTrap, on thread A's stack.
4. `src/tcb.cpp:119-123`: in `dispatch()`, thread A isn't finished, so
   `Scheduler::put(running)` puts A at the end of the ready queue, followed
   by `switchToNext()`.
5. `src/tcb.cpp:101-113`: `switchToNext()` sets old=A and
   next=`Scheduler::get()` (say, WorkerA). If nobody is ready, it panics
   (deadlock). Then `running = next` and
   `contextSwitch(&old->context, &running->context)`.
6. `src/contextSwitch.S:15-30`: in the first half we are still thread A.
   The 12 s-registers go onto thread A's stack; `ra` (the return address
   into switchToNext, the line after the call to contextSwitch) and `sp`
   go into A's TCB context. Thread A is now frozen: everything it is hangs
   on two numbers in its TCB.

Part 2: thread WorkerA emerges (for the first time in its life).

7. `src/contextSwitch.S:32-48`: in the second half we become WorkerA.
   ra and sp are loaded from WorkerA's context: ra=&threadWrapper (the
   forgery from flow 3), sp=top of its stack - 96. The 12 "s-registers"
   (zeros) are popped from the stack, and `ret` jumps to threadWrapper. We
   entered the function as thread A and left it as WorkerA, and that is the
   entire context switch.
8. `src/tcb.cpp:49-64`: `threadWrapper` runs while we are still in
   supervisor mode (we got here from inside the trap handler, which runs in
   S-mode):
   - `reapZombie()`: birth also counts as a wake-up, so clean up any dead
     thread
   - systemLevel is false, so prepare the drop into U-mode:
     sepc=&userWrapper, sstatus.SPP=0, then `sret`. sret is the only way
     down.
9. `src/tcb.cpp:68-73`: `userWrapper` runs in user mode and calls
   `running->body(running->arg)`. body is runWrapper and arg is this
   (that is what we passed in flow 3). U-mode code may read the TCB because
   we share one address space; the boundary lives in the instructions, not
   in memory.
10. `src/syscall_cpp.cpp:28-35`: in `runWrapper(this)`, body is nullptr
    (protected constructor), so it calls `self->run()`, a virtual call that
    ends up in `WorkerA::run()` in the test. If the Thread had been created
    with a function pointer, body would take precedence (rule from the
    specification).
11. test: `run()` executes the body. Every `thread_dispatch()` inside it
    repeats this whole flow: WorkerA goes to the end of the queue and the
    next one from the queue gets the processor.

Part 3: what happens when thread A's turn comes later.

12. Some thread dispatches and Scheduler::get() returns A. contextSwitch
    loads A's ra/sp, so `ret` leads back into `switchToNext` right after
    the call to contextSwitch (`tcb.cpp:114-115`) instead of into
    threadWrapper.
13. `reapZombie()`: every wake-up is a cleanup point.
14. Return up A's stack: switchToNext -> TCB::dispatch ->
    handleSupervisorTrap case 0x13 -> `riscv.cpp:125-128` writes A's local
    sepc/sstatus (which were waiting on A's stack the whole time) ->
    trap.S restores A's registers -> `sret` -> thread A continues after its
    ecall in thread_dispatch, as if nothing had happened.

Key points:
- every thread that is not running is frozen in exactly one of two places:
  (a) in the middle of switchToNext, after the call to contextSwitch, with
  the whole ecall->handleSupervisorTrap->dispatch chain on its stack, or
  (b) as a fresh forgery pointing at threadWrapper.
- this is why local sepc/sstatus work: they are parked on the thread's
  stack and travel with it through the freeze.

---

## Flow 5: death of a thread, run() returns

Scenario: WorkerA::run() finishes its last line.

Files in order: test -> `syscall_cpp.cpp` -> `tcb.cpp` -> `syscall_c.cpp`
-> `riscv.cpp` -> `tcb.cpp`.

1. `run()` returns, so we go back into `runWrapper`
   (`syscall_cpp.cpp:35`), which returns into `userWrapper` (`tcb.cpp:70`).
2. `src/tcb.cpp:71`: `thread_exit()`. From U-mode the only way into the
   kernel is ecall. (The `for(;;)` loop below it is a safety net; execution
   never gets there.)
3. `src/syscall_c.cpp:56-60`: a0=0x12, `ecall`.
4. `src/riscv.cpp:65-72`: case 0x12 calls
   `running->setFinished(true)` and then `TCB::dispatch()`. For this thread,
   there is no return from here.
5. `src/tcb.cpp:119-123`: dispatch sees finished=true, so the thread goes
   into `zombie` instead of the scheduler. We can't free it right away
   because we are still standing on its stack; freeing it would pull the
   floor out from under our own feet.
6. `switchToNext()` switches to the next ready thread. The first thing the
   woken thread does is `reapZombie()` (`tcb.cpp:115` or `tcb.cpp:42`):
   from its own, safe stack it frees the dead thread's stack
   (`MemoryAllocator::free`) and TCB (`delete`).
7. The WorkerA object (C++ layer) is still alive. Only the test's
   `delete threads[i]` deletes it, as an ordinary mem_free through flow 2.
   Our ~Thread is empty because the kernel has already cleaned up
   everything it owns (a design decision).

We keep three deaths separate: (1) the body is done (finished), (2) the
kernel freed the stack + TCB (zombie/reap), (3) the user deleted the Thread
object (delete). They happen at different moments and belong to different
owners.

---

## Flow 6: semaphore, blocking and waking up (test 4)

Scenario: a consumer calls `buffer->get()` on an empty buffer, and a
producer later wakes it up with `put()`. The C++ version goes through the
Semaphore class and the C version calls sem_wait directly; the kernel side
is the same.

Files in order: `test/buffer_CPP_API.cpp` -> `syscall_cpp.cpp` ->
`syscall_c.cpp` -> `riscv.cpp` -> `scb.cpp` -> `tcb.cpp` ->
`contextSwitch.S` -> (another thread) -> back.

Part 1: the consumer falls asleep.

1. `test/buffer_CPP_API.cpp`: `get()` first does `itemAvailable->wait()`.
2. `src/syscall_cpp.cpp:77-79`: `Semaphore::wait()` -> `sem_wait(myHandle)`.
3. `src/syscall_c.cpp:83-88`: a0=0x23, a1=handle, `ecall`.
4. `src/riscv.cpp:86-88`: case 0x23 calls `((SCB*)a1)->wait(1)`.
5. `src/scb.cpp:36-51`: in `SCB::wait(1)`, value is 0 (buffer empty), so
   the thread can't pass. It enqueues itself in this semaphore's queue
   (`enqueue(self)`, blockResult=0, pendingN=1) and calls
   `TCB::switchToNext()`. Careful: the thread does not go into the
   scheduler. From now on only this semaphore's queue knows about it.
6. `switchToNext` + `contextSwitch` freeze the consumer right there, in
   the middle of SCB::wait. A whole tower waits on its stack: the user's
   call -> ecall frame (trap.S) -> handleSupervisorTrap frame (with its
   sepc/sstatus in locals) -> wait frame -> switchToNext frame -> 12
   s-registers. The processor goes to the next ready thread.

Part 2: the producer wakes it up.

7. producer: `put()` -> `itemAvailable->signal()` -> ecall 0x24 ->
   `src/riscv.cpp:89-91` -> `SCB::signal(1)`.
8. `src/scb.cpp:53-65`: `signal` does value += 1, then loops: while the
   head of the queue holds a waiter whose pendingN fits in value, it calls
   `dequeue()`, does value -= pendingN, sets blockResult=0 and calls
   `Scheduler::put(t)`. The consumer is now ready (in the scheduler) but
   not running yet. The queue is FIFO without skipping: if a waiter with a
   large n is at the head, nobody behind it gets through.
9. The producer returns normally from its ecall and continues.

Part 3: the consumer wakes up.

10. When its turn comes (someone's dispatch), contextSwitch unfreezes it:
    `ret` leads back into switchToNext (`tcb.cpp:114`), then reapZombie,
    then return into `SCB::wait` (`scb.cpp:50`), and wait returns
    `self->blockResult` (0).
11. Up the stack: handleSupervisorTrap writes its local sepc/sstatus,
    trap.S, sret -> the consumer continues after the ecall in sem_wait and
    gets 0. `Semaphore::wait()` returns 0, and `get()` continues and takes
    the item.

A blocked thread sleeps in the middle of kernel code (in SCB::wait), at a
concrete point we can name. Waking up is the continuation of that same
call, which makes blockResult a natural return value: close() sets it to
-1, and that same return tells the thread it waited in vain.

## Flow 6b: deleting a semaphore, `delete waitForAll` (end of test 4)

1. test: `delete waitForAll`. The destructor runs first, and only then is
   the object's memory freed.
2. `src/syscall_cpp.cpp:72-75`: `~Semaphore()` calls `sem_close(myHandle)`
   -> ecall 0x22.
3. `src/riscv.cpp:79-85`: case 0x22 calls `sem->close()` and then
   `delete sem` (SCB's own delete, straight to MemoryAllocator).
4. `src/scb.cpp:67-75`: `close()` wakes all waiters with
   blockResult=-1 and puts them back into the scheduler, so their wait will
   return an error (see flow 6, step 10).
5. Back in the test, operator delete frees the Semaphore object itself
   (mem_free, flow 2).

---

## Flow 7: console, getc/putc through our buffers (CCB, Part 4)

Scenario: the test menu waits for your input; printString prints text.
(History: first we did manual polling, which was wrong; then we used
console.lib, the reduced version from lesson 08; now we have our own
console from Part 4, lesson 12.)

Input direction (getc):

1. `test/printing.cpp` / menu: `getc()` -> a0=0x41, ecall.
2. `src/riscv.cpp` (case 0x41) -> `CCB::getc()`: `wait(inputItems)`.
   If the buffer is empty, the thread blocks right there, in the middle of
   the kernel, exactly as on a semaphore (flow 6), with its sepc/sstatus
   waiting in locals on its stack. The processor immediately goes to
   another ready thread.
3. A key press raises a console interrupt (top=1, code=9) -> trap ->
   `CCB::handleInterrupt()`. We do `plic_claim()`, move characters from the
   controller into the input buffer while there are any, call
   `signal(inputItems)` per character (this wakes the waiter), and finish
   with `plic_complete()`.
4. When the blocked thread's turn comes, it continues from wait, takes the
   character from the head and returns it through a0 -> sret -> the user
   has the character.

Output direction (putc):

1. `putc(c)` -> a0=0x42, a1=character, ecall -> `CCB::putc`.
2. `wait(outputSpace)`: a full buffer blocks the caller until space frees
   up. Otherwise it proceeds immediately: character to the tail,
   `signal(outputItems)`.
3. The kernel output thread (a system thread, created in `CCB::init`)
   lives in a loop: `wait(outputItems)` (empty buffer = sleep) -> take a
   character from the head -> poll the controller's ready bit -> write to
   CONSOLE_TX_DATA -> `signal(outputSpace)`.
4. Before shutdown, main spins `while (!CCB::outputEmpty())
   thread_dispatch()` so the output thread empties the buffer. Without
   this, the last messages are lost.

Key points:
- the console is two separate producer/consumer pairs: input (the
  interrupt handler produces, getc consumes) and output (putc produces,
  the kernel thread consumes).
- getc no longer holds the processor while waiting. The thread sleeps
  properly in a semaphore queue, so tests 3/4 no longer depend on
  preemption to keep running.
- we call plic_claim/plic_complete ourselves now (in CCB::handleInterrupt);
  console_handler no longer exists in the project.
- none of this needs a mutex: getc/putc run inside the trap (interrupts
  masked), the output thread runs in S-mode with interrupts masked, and
  the interrupt handler is itself a trap, so all three contexts are atomic.

---

## Review questions (once you have gone through all the flows)

1. Why doesn't trap.S save a0, and what would break if it saved and
   restored it?
2. At what moment and in which variable does the sepc of a thread sleeping
   on a semaphore live? What would go wrong if sepc were only read right
   before sret?
3. Name the exact two "shapes" in which a frozen thread can exist.
4. Why must a finishing thread not free its own stack, and who frees it
   instead?
5. Which ecalls does one call to `threads[0]->start()` go through?
   (Careful: there is more than one.)
6. What exactly does `runWrapper` see when the Thread was created with the
   protected constructor, and what when it was created with a function
   pointer?
7. Why do TCB and SCB have their own operator new/delete instead of using
   the global ones from _new.cpp?
8. Explain the path of a character from a key press to the return from
   getc. Which buffers does it pass through, and who moves it at each
   step?
9. What happens when a thread calls putc and the output buffer is full?
   Where exactly does it sleep, and who wakes it up?
10. Why does main wait for userMain to finish through a flag rather than
    through the thread handle?
