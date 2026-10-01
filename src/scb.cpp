#include "../inc/scb.hpp"
#include "../inc/tcb.hpp"
#include "../inc/scheduler.hpp"
#include "../inc/memoryAllocator.hpp"

void* SCB::operator new(size_t size) {
    return MemoryAllocator::alloc(size);
}
void SCB::operator delete(void* ptr) {
    MemoryAllocator::free(ptr);
}

SCB::SCB(unsigned init) : value(init), head(nullptr), tail(nullptr) {}

SCB* SCB::createSemaphore(unsigned init) {
    return new SCB(init);
}

// same fifo pattern as Scheduler - append at tail / take from head
void SCB::enqueue(TCB* t) {
    t->next = nullptr;
    if (tail) tail->next = t;
    else head = t;
    tail = t;
}

TCB* SCB::dequeue() {
    TCB* t = head;
    if (!t) return nullptr;
    head = head->next;
    if (!head) tail = nullptr;
    t->next = nullptr;
    return t;
}

int SCB::wait(unsigned n) {
    if (value >= n) {
        value -= n;      // slots available: pass right away
        return 0;
    }
    // no slots: join the queue of THIS semaphore and give up the cpu.
    // the thread does NOT go to the scheduler - only this queue knows about it,
    // until someone (signal or close) puts it back among the ready ones.
    TCB* self = TCB::running;
    self->blockResult = 0;
    self->pendingN = n;      // how many units it waits for (for the check in signal)
    enqueue(self);
    TCB::switchToNext();
    // wake-up: someone put us back in the scheduler and it is our turn
    return self->blockResult;   // 0 = released by signal; negative = close
}

int SCB::signal(unsigned n) {
    value += n;
    // release, in order from the head, all we can serve now.
    // fifo with no skipping: if a waiter with a large n holds the head,
    // nobody behind it passes - no starvation of the head
    while (head && value >= head->pendingN) {
        TCB* t = dequeue();
        value -= t->pendingN;
        t->blockResult = 0;
        Scheduler::put(t);
    }
    return 0;
}

int SCB::close() {
    // all waiters are woken, but with an error - their sem_wait returns negative
    TCB* t;
    while ((t = dequeue()) != nullptr) {
        t->blockResult = -1;
        Scheduler::put(t);
    }
    return 0;
}
