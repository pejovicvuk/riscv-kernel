#include "../inc/tcb.hpp"
#include "../inc/scheduler.hpp"
#include "../inc/memoryAllocator.hpp"
#include "../inc/print.hpp"
#include "../inc/riscv.hpp"
#include "../inc/syscall_c.h"   // for thread_exit in userWrapper (u-mode part)

// assembly routine from contextSwitch.S
extern "C" void contextSwitch(TCB::Context* oldCtx, TCB::Context* newCtx);

TCB* TCB::running   = nullptr;
TCB* TCB::zombie    = nullptr;
uint64 TCB::usedTicks = 0;
TCB* TCB::sleepHead = nullptr;

// new/delete for tcb: straight to the kernel allocator (no ecall)
void* TCB::operator new(size_t size) {
    return MemoryAllocator::alloc(size);
}
void TCB::operator delete(void* ptr) {
    MemoryAllocator::free(ptr);
}

TCB::TCB(Body body, void* arg, uint64* stack, bool systemLevel)
    : body(body), arg(arg), stack(stack),
      context({0, 0}),
      finished(false), systemLevel(systemLevel),
      timeSlice(DEFAULT_TIME_SLICE), next(nullptr),
      blockResult(0), pendingN(1), sleepRelative(0)
{}

// timer tick: the running thread's time slice drains; when empty - preemption.
// (main's zero thread must exist before the first tick - see main.cpp)
bool TCB::tick() {
    return ++usedTicks >= running->timeSlice;
}

// clean up the thread that died before we woke up (its stack and tcb);
// called from EVERY wake-up point: after contextSwitch and on entry to the wrapper
void TCB::reapZombie() {
    if (!zombie) return;
    if (zombie->stack) MemoryAllocator::free(zombie->stack);
    delete zombie;
    zombie = nullptr;
}

// first function in every thread's life (the forged ra drops us here).
// s-mode part: internal kernel threads run the body right away, here; user threads
// are DROPPED to user mode through the only gate down - sret
void TCB::threadWrapper() {
    reapZombie();   // birth is a wake-up too: clean up any predecessor

    if (running->systemLevel) {
        // internal kernel thread: the body stays privileged
        running->body(running->arg);
        running->finished = true;
        dispatch();     // no return from here
    }

    // user thread: set up sret so it "returns" into userWrapper, in u-mode
    Riscv::w_sepc((uint64)&userWrapper);
    Riscv::mc_sstatus(Riscv::SSTATUS_SPP);     // spp = 0: sret goes to u-mode
    asm volatile("sret");                      // drop: continue in userWrapper
}

// u-mode part of the wrapper: THIS runs in user mode.
// it may READ the tcb (same address space, no memory protection -
// the privilege boundary is instructions), but may enter the kernel only via ecall
void TCB::userWrapper() {
    running->body(running->arg);
    thread_exit();      // ecall - the only legal way back into the kernel
    for (;;) {}         // unreachable; a guard so we never "fall out"
}

TCB* TCB::createThread(Body body, void* arg, void* stackSpace, bool systemLevel) {
    // a real thread cannot exist without a stack
    if (body && !stackSpace) return nullptr;

    TCB* tcb = new TCB(body, arg, (uint64*)stackSpace, systemLevel);
    if (!tcb) return nullptr;

    if (body) {
        // bootstrap: forge the thread's past so it looks like it "fell asleep"
        // right at the entry of threadWrapper. the first wake-up (contextSwitch) will:
        // pop 12 fake s-registers from the stack, then ret to threadWrapper.
        uint64 top = (uint64)stackSpace + DEFAULT_STACK_SIZE;   // stack grows toward lower addresses
        tcb->context.sp = top - 96;                             // room for 12 "s-registers"
        uint64* fakeRegs = (uint64*)tcb->context.sp;
        for (int i = 0; i < 12; i++) fakeRegs[i] = 0;           // the thread starts with a clean slate
        tcb->context.ra = (uint64)&threadWrapper;

        Scheduler::put(tcb);
    }
    // zero thread (body == nullptr, main): no stack and no queue - its context
    // is naturally filled in by its first contextSwitch
    return tcb;
}

// switch to the next ready thread. ASSUMPTION: the running thread has already
// been taken care of (ready queue / semaphore queue / zombie) - here we only switch
void TCB::switchToNext() {
    TCB* old = running;
    TCB* next = Scheduler::get();
    if (!next) {
        // no ready threads at all: the system has nothing to do (possibly a deadlock)
        kputs("no ready threads\n");
        *(volatile int*)0x100000 = 0x5555;
    }

    running = next;
    usedTicks = 0;   // the newly picked thread gets a fresh time slice - one place
                     // covers all paths: dispatch, exit, blocking and preemption
    contextSwitch(&old->context, &running->context);
    // wake-up: now we are on the woken thread's stack - safe to clean up the zombie
    reapZombie();
}

// synchronous context switch: the running thread yields the cpu
void TCB::dispatch() {
    if (!running->finished) Scheduler::put(running);
    else zombie = running;   // we are still on its stack - clean up later!
    switchToNext();
}

// put the running thread to sleep for the given number of timer ticks (syscall 0x31).
// insertion into a sorted list of relative deltas: walking the list we
// spend the given time on predecessors; the remainder is OUR delta, and it is
// SUBTRACTED from the successor - from now on it measures time from us
int TCB::putToSleep(time_t ticks) {
    if (ticks == 0) return 0;   // nothing to wait for

    TCB* self = running;

    // find the spot: skip all that wake before us (or exactly when we do)
    TCB* prev = nullptr;
    TCB* curr = sleepHead;
    while (curr && curr->sleepRelative <= ticks) {
        ticks -= curr->sleepRelative;
        prev = curr;
        curr = curr->next;
    }

    self->sleepRelative = ticks;
    if (curr) curr->sleepRelative -= ticks;   // the successor now measures from us

    // link through the same next pointer (a thread is in at most one queue:
    // it is sleeping, so it is neither in the scheduler nor in a semaphore queue)
    self->next = curr;
    if (prev) prev->next = self;
    else      sleepHead = self;

    // give up the cpu: now only the sleep list knows about the thread,
    // until the timer branch puts it back among the ready ones
    switchToNext();
    return 0;
}

// one timer tick for sleepers: ONLY the head of the list is counted down (the
// others are relative to it), then all whose delta dropped to zero are woken
// in order - several threads may share the same wake-up moment
void TCB::wakeSleepers() {
    if (!sleepHead) return;
    if (sleepHead->sleepRelative > 0) sleepHead->sleepRelative--;
    while (sleepHead && sleepHead->sleepRelative == 0) {
        TCB* awake = sleepHead;
        sleepHead = sleepHead->next;   // move the head first - put overwrites next!
        Scheduler::put(awake);
    }
}
