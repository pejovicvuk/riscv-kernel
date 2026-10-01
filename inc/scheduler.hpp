#ifndef _scheduler_hpp_
#define _scheduler_hpp_

class TCB;

// ready queue (fifo): threads waiting for the cpu;
// the running thread (TCB::running) is not in this queue
class Scheduler {
public:
    static void put(TCB* thread);   // append to the tail of the queue
    static TCB* get();              // take a thread from the head (nullptr if empty)

private:
    static TCB* head;   // head of the queue (gets the cpu next)
    static TCB* tail;   // tail of the queue (new arrivals go here)
};

#endif // _scheduler_hpp_
