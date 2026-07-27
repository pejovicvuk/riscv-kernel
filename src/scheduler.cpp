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
    if (!head) return nullptr;
    TCB* curr = head;
    TCB* prev = nullptr;
    TCB* minPrio = curr;
    TCB* minPrioPrev = nullptr;
    while(curr != nullptr){
        if (curr->priority < minPrio->priority) {
            minPrio = curr;
            minPrioPrev = prev;
        }
        prev = curr;
        curr = curr->next;
    }
    if (minPrioPrev != nullptr){
        minPrioPrev->next = minPrio->next;
    } else {
        head = minPrio->next;
    }
    if(minPrio == tail){
        tail = minPrioPrev;
    }
    minPrio->next = nullptr;
    return minPrio;
}
