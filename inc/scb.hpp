#ifndef _scb_hpp_
#define _scb_hpp_

#include "../lib/hw.h"

class TCB;

// scb (semaphore control block) = kernel semaphore: count of free
// "slots" + fifo queue of waiting threads. this type hides behind the
// c api handle sem_t.
// convention (design decision): value never goes negative - waiters are seen
// in the queue, not in the sign of the counter.
class SCB {
public:
    static SCB* createSemaphore(unsigned init);

    // wait/signal for n units at once; plain sem_wait/sem_signal is n == 1
    // (one mechanism covers both 0x23/0x24 and 0x25/0x26).
    // wait returns 0 when the thread passed normally, negative if the
    // semaphore was closed while it was waiting
    int wait(unsigned n);
    int signal(unsigned n);
    int close();   // wake ALL waiters, their wait returns an error

    // new/delete go straight to the kernel allocator (no ecall), as for tcb
    void* operator new(size_t size);
    void operator delete(void* ptr);

private:
    SCB(unsigned init);
    void enqueue(TCB* t);
    TCB* dequeue();

    unsigned value;   // number of free "slots"
    TCB* head;        // fifo queue of blocked threads (linked via TCB::next -
    TCB* tail;        // a thread is always in at most ONE queue, so next is free)
};

#endif // _scb_hpp_
