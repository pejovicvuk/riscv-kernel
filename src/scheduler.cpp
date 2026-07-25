#include "../inc/scheduler.hpp"
#include "../inc/tcb.hpp"

TCB* Scheduler::head = nullptr;
TCB* Scheduler::tail = nullptr;

// stani na kraj reda
void Scheduler::put(TCB* thread) {
    thread->next = nullptr;
    if (tail) {
        tail->next = thread;   // dosadasnji poslednji pokaze na novog
    } else {
        head = thread;         // red je bio prazan: novi je i prvi
    }
    tail = thread;             // novi je u svakom slucaju poslednji
}

// skini nit sa cela reda
TCB* Scheduler::get() {
    TCB* thread = head;
    if (!thread) return nullptr;   // prazan red
    head = head->next;
    if (!head) tail = nullptr;     // skinuli smo i poslednjeg
    thread->next = nullptr;
    return thread;
}
