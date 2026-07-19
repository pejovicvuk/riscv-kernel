#include "../h/scb.hpp"
#include "../h/tcb.hpp"
#include "../h/scheduler.hpp"
#include "../h/memoryAllocator.hpp"

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
