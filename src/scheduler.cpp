#include "../inc/scheduler.hpp"
#include "../inc/tcb.hpp"

TCB* Scheduler::head = nullptr;
TCB* Scheduler::tail = nullptr;

// append to the tail of the queue
void Scheduler::put(TCB* thread) {
    thread->next = nullptr;
    if (tail) {
        tail->next = thread;   // the old last one points to the new one
    } else {
        head = thread;         // queue was empty: the new one is also first
    }
    tail = thread;             // the new one is last in any case
}

// take a thread from the head of the queue
TCB* Scheduler::get() {
    TCB* thread = head;
    if (!thread) return nullptr;   // empty queue
    head = head->next;
    if (!head) tail = nullptr;     // we took the last one too
    thread->next = nullptr;
    return thread;
}
