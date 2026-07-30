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

SCB::SCB(unsigned init) : value(init), head(nullptr), tail(nullptr), partnersHead(nullptr) {}

SCB* SCB::createSemaphore(unsigned init) {
    return new SCB(init);
}

// isti fifo obrazac kao Scheduler - stani na kraj / skini sa cela
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
        value -= n;      // ima mesta: prodji odmah
        return 0;
    }
    Partner* curr = partnersHead;
    while(curr){

        if(curr->semaphore->value >= n){
            //prodji na curr semaforu
            curr->semaphore->value -= n;
            return 1;
        }
        curr = curr->next;
    }
    // nema mesta: stani u red OVOG semafora i predaj procesor.
    // nit NE ide u scheduler - za nju zna samo ovaj red, dok je neko
    // (signal ili close) ne vrati medju spremne.
    TCB* self = TCB::running;
    self->blockResult = 0;
    self->pendingN = n;      // koliko jedinica ceka (za signal-ovu proveru)
    enqueue(self);
    TCB::switchToNext();
    // budjenje: neko nas je vratio u scheduler i dosli smo na red
    return self->blockResult;   // 0 = pusteni signalom; negativno = close
}

int SCB::signal(unsigned n) {
    value += n;
    // pusti redom sa cela sve koje sada mozemo da usluzimo.
    // fifo bez preskakanja: ako celu kolonu drzi cekac sa velikim n,
    // niko iza njega ne prolazi - nema izgladnjivanja cela
    while (head && value >= head->pendingN) {
        TCB* t = dequeue();
        value -= t->pendingN;
        t->blockResult = 0;
        Scheduler::put(t);
    }
    return 0;
}

int SCB::close() {
    // svi cekaci se bude, ali sa greskom - njihov sem_wait vraca negativno
    TCB* t;
    while ((t = dequeue()) != nullptr) {
        t->blockResult = -1;
        Scheduler::put(t);
    }
    return 0;
}
int SCB::pairSems(SCB* s1, SCB* s2){
    if (!s1 || !s2) return -1;
    Partner* p1 = (Partner*)MemoryAllocator::alloc(sizeof(Partner));
    Partner* p2 = (Partner*)MemoryAllocator::alloc(sizeof(Partner));
    p1->semaphore = s2;
    p2->semaphore = s1;
    
    p1->next = s1->partnersHead;
    s1->partnersHead = p1;
    p2->next = s2->partnersHead;
    s2->partnersHead = p2;
    return 0;
}