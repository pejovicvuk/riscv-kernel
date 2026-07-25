#ifndef _scheduler_hpp_
#define _scheduler_hpp_

class TCB;

// red spremnih niti (fifo): niti koje cekaju procesor;
// tekuca nit (TCB::running) nije u ovom redu
class Scheduler {
public:
    static void put(TCB* thread);   // stani na kraj reda
    static TCB* get();              // skini nit sa cela reda (nullptr ako je prazan)

private:
    static TCB* head;   // celo reda (sledeci dobija procesor)
    static TCB* tail;   // kraj reda (tu staju novopristigli)
};

#endif // _scheduler_hpp_
