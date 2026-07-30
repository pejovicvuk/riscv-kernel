#ifndef _scb_hpp_
#define _scb_hpp_

#include "../lib/hw.h"

class TCB;

// scb (semaphore control block) = semafor u jezgru: brojac slobodnih
// "mesta" + fifo red niti koje cekaju. iza c api rucke sem_t krije se
// ovaj tip.
// konvencija (projektna odluka): value nikad ne ide u minus - cekaci se vide
// po redu, ne po znaku brojaca.
class SCB {
public:
    static SCB* createSemaphore(unsigned init);

    // wait/signal za n jedinica odjednom; obican sem_wait/sem_signal je n == 1
    // (jedan mehanizam pokriva i 0x23/0x24 i 0x25/0x26).
    // wait vraca 0 kad je nit legalno prosla, negativno ako je semafor
    // zatvoren dok je cekala
    int wait(unsigned n);
    int signal(unsigned n);
    int close();   // probudi SVE cekace, njihov wait vraca gresku

    // new/delete direktno na alokator jezgra (bez ecall-a), kao kod tcb-a
    void* operator new(size_t size);
    void operator delete(void* ptr);

    static int pairSems(SCB* s1, SCB* s2);

private:
    SCB(unsigned init);
    void enqueue(TCB* t);
    TCB* dequeue();

    unsigned value;   // broj slobodnih "mesta"
    TCB* head;        // fifo red blokiranih niti (ulancan kroz TCB::next -
    TCB* tail;        // nit je uvek u najvise JEDNOM redu, pa je next slobodan)

    struct Partner{
        SCB* semaphore;
        Partner* next;
    };
    Partner* partnersHead;
};

#endif // _scb_hpp_
