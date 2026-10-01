# 09 - Semaphores (Part 3)

Files: `inc/scb.hpp`, `src/scb.cpp`, changes in `inc/tcb.hpp`, `src/tcb.cpp`,
`src/riscv.cpp` (0x21-0x26), `inc/syscall_c.h`, `src/syscall_c.cpp`

## The idea in one sentence

A semaphore is a counter of free "slots" plus a FIFO queue of threads waiting at the gate:
wait means enter, or join the queue and go to sleep; signal releases the first one in the queue (or
records a free slot); close wakes everyone up with an error.

## Design decisions

1. **Blocked threads are chained through the same TCB::next pointer** as in the
   scheduler. This is safe because of an invariant: at any moment a thread is in at most
   one queue (running, ready in the scheduler, or waiting on exactly one semaphore).
2. **value never goes negative.** wait passes only if there is a free slot, otherwise it
   queues; signal first tries to release a waiter, and only then increments. This reads better,
   and sem_wait_n (n units) fits in naturally (check value >= n).
3. **Unification**: plain wait/signal is a special case of wait(n)/signal(n)
   with n=1, so one mechanism covers calls 0x23/0x24 and 0x25/0x26.

## A third thread state: BLOCKED

Until now a thread was either on the CPU or READY (in the scheduler's queue). Now:

```
       dispatch/preemption
RUNNING <------------------->  READY (scheduler's queue)
  |                             ^
  | sem_wait (no free slot)     | sem_signal / sem_close
  v                             |
BLOCKED (queue of THAT semaphore) ---+
```

A blocked thread is not in the scheduler. Only the queue of the semaphore it waits on knows about it.
That is why we introduced `TCB::switchToNext()`: "switch to the next one without putting me back
among the ready ones". The caller has already placed the thread where it belongs.
dispatch is now put(running) + switchToNext().

## Flow: a sem_wait that blocks, then a sem_signal that wakes

```
thread A: sem_wait(s)  -> ecall 0x23 -> SCB::wait(1)
       value == 0   -> A.blockResult=0, A.pendingN=1
                    -> enqueue(A) into the SEMAPHORE'S QUEUE (not the scheduler!)
                    -> switchToNext(): A is parked IN THE MIDDLE of handleSupervisorTrap
   ... other threads run ...
thread B: sem_signal(s) -> ecall 0x24 -> SCB::signal(1)
       value += 1; head(=A).pendingN(=1) <= value
                    -> dequeue(A), value -= 1, Scheduler::put(A)
       (B continues - signal does NOT preempt the CPU!)
   ... A gets its turn from the scheduler ...
thread A: wakes up after switchToNext, wait returns A.blockResult = 0
       -> handleSupervisorTrap returns 0 -> A's sem_wait returned 0. Passed legitimately.
```

Code (core of scb.cpp):

```cpp
int SCB::wait(unsigned n) {
    if (value >= n) { value -= n; return 0; }
    TCB* self = TCB::running;
    self->blockResult = 0;
    self->pendingN = n;
    enqueue(self);
    TCB::switchToNext();
    return self->blockResult;   // 0 = signal; negative = close
}

int SCB::signal(unsigned n) {
    value += n;
    while (head && value >= head->pendingN) {   // fifo, no skipping
        TCB* t = dequeue();
        value -= t->pendingN;
        t->blockResult = 0;
        Scheduler::put(t);
    }
    return 0;
}
```

## sem_close: waking up with an error

Spec: all waiting threads are unblocked, and their wait returns an error.
Mechanism: the per-thread field `blockResult`. close sets it to -1 before
Scheduler::put, so every woken thread returns -1 from its wait to its
caller. After unblocking, the SCB is deleted (delete -> MemoryAllocator).

## FIFO without skipping (wait_n policy)

If the head of the queue waits for 5 units and value is 3, nobody passes, not even a waiter behind
it that needs only 1. We chose this on purpose: with strict FIFO a large request never
starves. Letting smaller requests through would be faster, but then a large
request could wait forever.

## Imported tests

test/ extended with: ConsumerProducer_C_API_test.{hpp,cpp} + buffer.{hpp,cpp}
(a bounded buffer over 4 semaphores: itemAvailable, spaceAvailable, 2 mutexes).
userMain: LEVEL_3 = 1, case 3 enabled. Test 3 is interactive: you enter the
number of producers and the buffer capacity, then type text; ESC ends it.

## Review questions

1. What are the three thread states, and who "knows" about the thread in each of them?
2. Why is it safe for the semaphore to use the same next pointer as the scheduler?
3. Why does signal not preempt the CPU immediately (the woken thread goes to the queue, not onto the CPU)?
4. How does a woken thread "find out" whether it was released by signal or killed by close?
5. Where exactly does a thread blocked on a semaphore sleep? (the place in the code!)
6. What would happen if wait returned blockResult before calling switchToNext?
