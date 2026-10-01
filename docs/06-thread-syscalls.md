# 06 - Threads through system calls (thread_create/exit/dispatch)

Files: `src/riscv.cpp`, `src/syscall_c.cpp`, `inc/syscall_c.h`,
`src/tcb.cpp`, `inc/tcb.hpp`

## Design decisions

1. **System call dispatch: switch/case** (the project specification also
   offers a table of function pointers). Reason: everything sits in one place,
   which makes it easy to read and debug. The call codes are also sparse
   (0x01..0x42 with gaps), so a table would have empty slots.
2. **Kernel object allocation: dynamic** through MemoryAllocator (per-class
   operator new/delete), instead of a static array of slots. Reason: the
   project specification calls it "more advanced and flexible", and it puts no
   artificial limit on the number of threads or semaphores. The cost is
   possible fragmentation from small objects, which we accept.

## The C API layer: who does what (specification, ABI call 0x11)

The project specification has ABI call 0x11 also take a pointer to the stack
(a4). The C API layer allocates the thread's stack (through mem_alloc, which is
one more ecall), not the kernel:

```cpp
int thread_create(thread_t* handle, void (*start_routine)(void*), void* arg) {
    if (!handle || !start_routine) return -1;
    void* stackSpace = mem_alloc(DEFAULT_STACK_SIZE);   // 1st ecall (0x01)
    if (!stackSpace) return -2;
    // ... a0=0x11, a1=handle, a2=body, a3=arg, a4=stack ... ecall  // 2nd ecall
    int result = (int)code;
    if (result != 0) mem_free(stackSpace);   // the thread was not created - give the stack back
    return result;
}
```

`thread_t` is an "opaque handle": `class _thread; typedef _thread* thread_t;`.
The user gets a pointer without knowing what is behind it (our TCB). The
kernel writes the handle through `*(TCB**)a1 = tcb`.

## Flow: thread_create(&a, workerA, nullptr) from start to finish

```
[user]       thread_create(&a, workerA, 0)
[C API]      mem_alloc(DEFAULT_STACK_SIZE)  -> ecall 0x01 -> stack for the new thread
[C API]      a0=0x11, a1=&a, a2=workerA, a3=0, a4=stack -> ecall
[hardware]   sepc/scause/sstatus, jump to stvec
[trap.S]     save 15 registers on the CALLER's stack
[handleSupervisorTrap] case 0x11: TCB::createThread(workerA, 0, stack)
[kernel]     new TCB (operator new -> MemoryAllocator, NO ecall!)
             faked past: ra=threadWrapper, sp=stack top-96 (12 zeros)
             Scheduler::put -> the thread waits in the queue (it has NOT got the processor yet!)
[handleSupervisorTrap] *(TCB**)a1 = tcb  (handle for the user), ret=0
[trap.S]     restore registers, sret
[C API]      return 0 to the user. The new thread will run for the FIRST time only
             when somebody's dispatch pulls it out of the queue.
```

## Pitfall 1: sepc and sstatus are part of the thread context

Once thread_dispatch goes through an ecall, the context switch happens in the
middle of trap handling. And sepc is global in hardware, one per processor:

```
thread A: ecall             sepc <- A's address
  handleSupervisorTrap -> dispatch -> A parked IN THE MIDDLE of handleSupervisorTrap
  thread B runs, does its own ecall    sepc <- B's address   !!! overwritten
  A wakes up, finishes its handleSupervisorTrap: sepc+=4; sret -> FLIES OFF TO B's ADDRESS
```

The fix, in handleSupervisorTrap: copy sepc and sstatus into local variables on
entry. Locals live on the stack of that thread, so they get parked and woken up
together with it. Right before returning we write them back into the CSRs, and
each thread returns with its own values.

```cpp
uint64 cause, sepc, sstatus;
asm volatile("csrr %0, scause"  : "=r"(cause));
asm volatile("csrr %0, sepc"    : "=r"(sepc));     // straight into a local
asm volatile("csrr %0, sstatus" : "=r"(sstatus));
...
sepc += 4;                    // for ecall: in the local copy
switch (a0) { ... dispatch may park the thread right here ... }
...
asm volatile("csrw sstatus, %0" : : "r"(sstatus)); // before returning: ours back
asm volatile("csrw sepc, %0"    : : "r"(sepc));
```

## Pitfall 2: the zombie mechanism (don't saw off the branch you are sitting on)

thread_exit has to free the stack and TCB of the finished thread. At that
moment, though, the kernel is executing on that very stack (in our design,
kernel code runs on the current thread's stack), and contextSwitch would
immediately push the s-registers onto the freed memory.

So the dying thread is only recorded (`zombie = old`). The next thread that
wakes up cleans it up from its own, safe stack:

```cpp
void TCB::dispatch() {
    TCB* old = running;
    if (!old->finished) Scheduler::put(old);
    else zombie = old;   // we are still standing on its stack - clean up later
    ...
    contextSwitch(&old->context, &running->context);
    // wake-up: now we are on the woken thread's stack - safe to clean up the zombie
    reapZombie();
}

void TCB::threadWrapper() {
    reapZombie();   // birth is also a wake-up: clean up a possible predecessor
    ...
}
```

We call reapZombie from every wake-up point (after contextSwitch and on entry
into the wrapper), so a zombie never survives two wake-ups and nothing leaks.

## thread_exit and thread_dispatch in the kernel

```cpp
case 0x12:   // thread_exit - no return from here for this thread
    TCB::running->setFinished(true);
    TCB::dispatch();
    break;
case 0x13:   // thread_dispatch
    TCB::dispatch();
    ret = 0;
    break;
```

thread_exit means "mark the end and give up the processor", the same mechanics
as dying through the wrapper. The thread is parked in the middle of
handleSupervisorTrap and marked finished. Nobody wakes it up again, and the
next thread to wake up cleans it up as a zombie.

## Review questions

1. Who allocates the new thread's stack, and why (specification, ABI 0x11)? How many ecalls does one thread_create make?
2. What is thread_t and why is it "opaque"?
3. Why must sepc go into a local variable on entry to handleSupervisorTrap? What would break without it?
4. Why must a finished thread not free its own stack? Who frees it, and when?
5. A new thread has been created. When will it get the processor for the first time?
6. Why is sepc incremented in handleSupervisorTrap before the switch, but written into the CSR only at the end?
