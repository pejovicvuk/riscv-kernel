# 05 - Threads: TCB, Scheduler and context switch

Files: `inc/tcb.hpp`, `src/tcb.cpp`, `inc/scheduler.hpp`, `src/scheduler.cpp`,
`src/contextSwitch.S`

## What a thread is, physically

The processor can "freeze" a program in the middle of its work, like pausing a
movie. To resume it later at the exact spot, we only need to keep two things:

1. **Its stack**: local variables plus the saved "who called me"
2. **A snapshot of its registers**: where it stopped (ra), the top of its stack
   (sp), and the values it was holding

So a thread is its own stack, that frozen snapshot, and a bit of bookkeeping.
Five threads means five stacks and five snapshots, while one processor jumps
from snapshot to snapshot fast enough that it looks like five things are
happening at once.

## TCB: the thread's ID card

```cpp
Body body;        // what the thread does in its life: a function
void* arg;        // the argument of that function
uint64* stack;    // where it lives: its private stack (kept so it can be freed)
Context context;  // the frozen snapshot: ONLY ra + sp
bool finished;    // whether it has finished
TCB* next;        // for the ready queue (intrusive linking)
static TCB* running;   // the only thread currently running ("at the register")
```

Why the body + arg pair? body is the "role" (what the thread does) and arg is
the "costume" (what it works with). One function can serve several threads
with different data, so we never copy-paste a body. void* is a universal plug:
it points to anything, and the body casts it back. The project specification
dictates the signature (thread_create(handle, start_routine, arg)).

createThread calls nothing. It only stores body and arg in the TCB, and the
actual call `running->body(running->arg)` happens on the first wake-up, inside
threadWrapper. The TCB is the only bridge between "stored" and "called":
contextSwitch does not carry the a-registers, so the argument can reach the
body only through the TCB.

Why are ra + sp enough for the snapshot? Before freezing, all other registers
are pushed onto the thread's own stack, and sp points to that stack. sp is the
suitcase handle: lift it and everything else comes with it.

Why is `next` inside the TCB itself (intrusive)? The project specification
recommends it. With no separate list nodes we skip a dynamic allocation on
every insertion and avoid the fragmentation that comes with it. Each waiter
keeps a hand on the shoulder of the next one.

Why does TCB have its own operator new/delete? The hardware has one sepc (the
note saying "where I stopped"). If the kernel, while handling one ecall,
executed an ecall itself (global new -> mem_alloc -> ecall), it would overwrite
sepc and the return address to the user would be gone. So kernel classes
allocate directly through MemoryAllocator with a plain function call. (C++
detail: `new TCB(...)` first asks our operator new for raw memory, then runs
the constructor on that chunk by itself.)

## Scheduler: the queue at the register (FIFO)

- Threads waiting for the processor stand in a queue. `running` is not in the
  queue. At any moment a thread is either on the processor or in the queue,
  never both (otherwise get() could pull it out while it is already running,
  and we would have two execution points on the same stack)
- `put(t)`: go to the end (if the queue is empty, you are both first and last)
- `get()`: take the first one from the front. If you took the last one, tail
  must also become nullptr. Otherwise tail points to a "ghost": the next put()
  writes into someone else's TCB, head stays nullptr, and the new thread is
  lost for good

## contextSwitch: 20 instructions (contextSwitch.S)

```
thread A calls dispatch()
  1. A goes into the queue (if it is not finished)
  2. take the next one from the queue -> B, running = B
  3. contextSwitch(&A.context, &B.context):
       push A's s0-s11 onto A's stack         (the suitcase is packed)
       A.ra <- "where I stopped" = return from contextSwitch
       A.sp <- top of A's stack               (suitcase handle)   == A FROZEN
       ra <- B.ra, sp <- B.sp                                     == B WAKES UP
       pop B's s0-s11 from B's stack          (the suitcase is unpacked)
       ret -> jump to B.ra = exactly where B once stopped
```

The key point: you enter contextSwitch as A and leave it as B. Thread A's call
freezes at that spot, and when someone later wakes A up, it continues right
after the call.

Why exactly s0-s11 (+ra +sp)?
- The compiler has already taken care of the t/a registers. dispatch is an
  ordinary function, so on this synchronous call the caller does not expect
  t/a to survive. That is the calling convention
- The called function must preserve the s registers, and contextSwitch lets
  another thread clobber them, so we push them onto the thread's stack by hand
  before freezing
- With asynchronous preemption (Part 4) an interrupt can hit anywhere, so there
  everything must be saved (trap.S already does that for the caller-saved part)

## Bootstrap: how a thread is born (the trickiest part)

contextSwitch wakes a thread up where it stopped. A new thread never stopped
anywhere, because it has never run. Our answer is to **fake its past** in
createThread: we set up the context as if the thread had "fallen asleep" at
the entry of threadWrapper:

```
context.ra = address of threadWrapper   "when you wake up, you were heading into the wrapper"
context.sp = stack top - 96             12 fake s-registers (zeros) wait on the stack
```

On the first wake-up, contextSwitch loads ra/sp, pops the 12 zeros into the
s-registers, and its ret lands in the wrapper, where the thread starts running.

threadWrapper is the first function in the life of every thread:
```cpp
running->body(running->arg);   // live your life
running->finished = true;      // mark the end
dispatch();                    // give up the processor - no return from here
```
The wrapper guarantees two things: the body never "falls off" into nothing, and
a finished thread never goes back into the queue (dispatch does not put it).

main is the "zero thread". It gets its own TCB (body=nullptr, not queued) only
so it has somewhere to freeze the first time it gives up the processor.

## Synchronous vs asynchronous context switch

The difference comes down to who decides.

- **Synchronous**: the thread itself calls dispatch ("handing over my shift").
  dispatch is an ordinary function call, so by convention the compiler knows
  that t/a registers do not survive it and keeps nothing important in them
  across that point. Saving s0-s11 + ra + sp by hand is enough. This is what we
  have now.
- **Asynchronous**: a timer interrupt takes the thread off the processor in the
  middle of any instruction, without warning. The thread may be holding a
  half-computed result in t3, so everything must be saved: trap.S saves t/a/ra
  on entry, contextSwitch adds s0-s11, and together that is the complete
  context. This arrives in Part 4 (preemption).

Analogy: synchronous is you handing the register over to a colleague yourself,
and only what is officially handed over gets recorded. Asynchronous is the boss
pulling you off the register halfway through ringing up a receipt, so
everything gets recorded, even the half-typed digit on the screen.

Why do we need asynchronous switching at all? Without it, a thread that
"forgets" to call dispatch holds the processor forever, and there is no real
time sharing.

## Proof that it works: the whole flow of our test, step by step (with code)

### The cast

The zero thread, in `src/main.cpp`:

```cpp
// main becomes the "zero" thread: it gets its own tcb so it has somewhere to freeze
// when it first gives up the processor (its context is filled in on the first dispatch)
TCB::running = TCB::createThread(nullptr, nullptr);

userMain();
```

Workers and direction, in `src/userMain.cpp`:

```cpp
// two threads taking turns: each prints its letter and then gives up the processor
static void workerA(void*) {
    for (int i = 0; i < 5; i++) {
        kputs("A");
        TCB::dispatch();
    }
}
// workerB is identical, prints "B"

void userMain() {
    TCB* a = TCB::createThread(workerA, nullptr);
    TCB* b = TCB::createThread(workerB, nullptr);

    // main (the zero thread) keeps calling dispatch until both finish
    while (!a->isFinished() || !b->isFinished()) {
        TCB::dispatch();
    }
    kputs("\nboth threads finished\n");
}
```

### Birth: a faked past (`src/tcb.cpp`, createThread)

```cpp
// bootstrap: fake the thread's past so it looks like it "fell asleep"
// right at the entry of threadWrapper. the first wake-up (contextSwitch) will:
// pop 12 fake s-registers from the stack, then ret to threadWrapper.
uint64 top = (uint64)stack + DEFAULT_STACK_SIZE;   // the stack grows toward lower addresses
tcb->context.sp = top - 96;                        // room for 12 "s-registers"
uint64* fakeRegs = (uint64*)tcb->context.sp;
for (int i = 0; i < 12; i++) fakeRegs[i] = 0;      // the thread starts with clean hands
tcb->context.ra = (uint64)&threadWrapper;

// main's zero thread (body == nullptr) is not scheduled through the queue
if (body) Scheduler::put(tcb);
```

After this, the stack of the newborn thread looks like this:

```
top (end of allocated space) ->    +----------------+
                                   | 12 x 0 (fake   |
                                   |  s-registers)  |
context.sp ------------------->    +----------------+
                                   |   empty...     |
stack (start of allocation) -->    +----------------+
context.ra = &threadWrapper
```

### Shift change: who replaces whom, and how (`src/tcb.cpp`, dispatch)

```cpp
void TCB::dispatch() {
    TCB* old = running;
    if (!old->finished) Scheduler::put(old);   // a finished thread does not go back into the queue

    TCB* next = Scheduler::get();
    if (!next) {
        // no ready thread at all, and the current one is finished: the system has nothing to do
        kputs("PANIC: no ready threads\n");
        *(volatile int*)0x100000 = 0x5555;
    }

    running = next;
    contextSwitch(&old->context, &running->context);
    // execution continues here only when someone GIVES the processor BACK to the old thread
}
```

### Freezing and waking (`src/contextSwitch.S`, the core)

```asm
contextSwitch:
    addi sp, sp, -96       # room for 12 s-registers (12 x 8B)
    sd s0, 0(sp)
    ...                    # s1-s11 likewise, in order
    sd s11, 88(sp)

    sd ra, 0(a0)           # old thread: where to continue when it wakes up
    sd sp, 8(a0)           # old thread: suitcase handle    == frozen

    ld ra, 0(a1)           # new thread: where it continues from
    ld sp, 8(a1)           # new thread: its stack          == wakes up

    ld s0, 0(sp)
    ...                    # s1-s11 likewise, in order
    ld s11, 88(sp)
    addi sp, sp, 96
    ret                    # jump to the new thread's ra: entered as the old one, exited as the new one
```

### Maternity ward and undertaker (`src/tcb.cpp`, threadWrapper)

```cpp
// the first function in the life of every thread (the faked ra drops us into it);
// when the body finishes, the thread shuts down cleanly and never gets the processor again
void TCB::threadWrapper() {
    running->body(running->arg);
    running->finished = true;
    dispatch();   // no return from here
}
```

### The whole run, move by move

Initial state (after the createThread calls):

```
running = main          A and B are newborn: context.ra = threadWrapper,
queue   = [A, B]        12 fake zeros for the s-registers wait on their stacks
```

First round, move by move:

```
who runs | what happens                                  | queue AFTER  | output
---------+-----------------------------------------------+--------------+-------
main     | dispatch: put(main), get->A, running=A        | [B, main]    |
         | contextSwitch(&main.ctx, &A.ctx)              |              |
         |   main FROZEN (ra = right after contextSwitch |              |
         |   in dispatch, sp = its stack)                |              |
A        | FIRST WAKE-UP: ret jumps to threadWrapper     |              |
         | wrapper calls workerA -> kputs("A")           |              | A
A        | dispatch: put(A), get->B, running=B           | [main, A]    |
         | contextSwitch(&A.ctx, &B.ctx)                 |              |
B        | FIRST WAKE-UP: wrapper->workerB->kputs("B")   |              | B
B        | dispatch: put(B), get->main, running=main     | [A, B]       |
         | contextSwitch(&B.ctx, &main.ctx)              |              |
main     | WAKES UP right after its contextSwitch call,  |              |
         | returns from dispatch into the while loop,    |              |
         | condition: not finished -> dispatch again     |              |
```

After the first round the queue is [A, B] again and the cycle repeats, with
each round adding "AB" to the output. Five rounds give ABABABABAB.

Where does a thread "sleep" while it is not running? Every parked thread is
frozen at the same place: in the middle of contextSwitch, with its ra pointing
to the instruction after the call in dispatch. Newborn threads are the only
exception, since their ra points to threadWrapper. Waking up is therefore
always the same: ret to ra, and the thread continues as if nothing had
happened.

Death of a thread (after the 5th print): workerA's for loop ends and the body
returns to the wrapper with an ordinary ret (this is why the wrapper exists).
The wrapper sets finished=true and calls dispatch, and dispatch does not put a
finished thread back into the queue. Nobody calls get() on its TCB again, so
the thread is dead. The queue gets shorter, and main and the surviving thread
carry on.

One detail at the end: when main is left alone, dispatch does put(main) and
then get->main, so the thread "switches to itself". contextSwitch saves and
immediately loads the same ra/sp. That is harmless, only a bit of wasted work.
When the while condition finally fails (both finished), main leaves the loop,
prints the message and returns to main(), which ends in a clean halt.

## What came next (all done)

- [x] thread_create/exit/dispatch as system calls + C API -> [06](06-thread-syscalls.md)
- [x] freeing the TCB and stack of a finished thread (zombie mechanism) -> [06](06-thread-syscalls.md)
- [x] userMain as a real thread -> [08](08-official-tests.md)
- [x] threads in user mode (sret with SPP=0) -> [07](07-user-mode-threads.md)
- [x] semaphores (Part 3) -> [09](09-semaphores.md)
- [x] time sharing (preemption) -> [11](11-time-sharing.md)
- [x] time_sleep, real console, PeriodicThread -> [12](12-sleep-console-periodic.md)

The code examples in this lesson are a snapshot from when threads had just been
introduced, before system calls existed. createThread does not yet take
stack/mode arguments, dispatch still calls get() itself, and threadWrapper has
no reapZombie and no drop into U-mode. The concepts (faked past, suitcase,
wrapper, the zombie idea) still hold today. For the exact current code, follow
[lesson 10](10-code-flow-guide.md).

## Review questions

1. What makes up a thread's "context", and where is each part stored while the thread is not running?
2. Explain the sentence "contextSwitch is entered as one thread and exited as another".
3. Why does contextSwitch save exactly s0-s11, and not the t/a registers too?
4. How does a new thread get a "past"? What exactly is in its context before its first wake-up?
5. What is threadWrapper for? What would happen without it?
6. Why must a finished thread not go back into the queue? Who puts it in the queue for the last time, and who never gets it again?
7. Why does main need its own TCB?
