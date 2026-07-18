#ifndef _tcb_hpp_
#define _tcb_hpp_

#include "../lib/hw.h"

// tcb (thread control block) = "licna karta" jedne niti:
// sve sto jezgro mora da zna o niti da bi mogla da se pauzira i nastavi
class TCB {
public:
    typedef void (*Body)(void*);   // tip za telo niti: funkcija koja prima void*

    // fabrika: napravi nit nad datom funkcijom (telo + argument);
    // alocira tcb i njen stek preko MemoryAllocator-a
    static TCB* createThread(Body body, void* arg);

    bool isFinished() const { return finished; }
    void setFinished(bool f) { finished = f; }

    // nit koja se trenutno izvrsava; jedna jedina
    static TCB* running;

    // new/delete za tcb idu direktno na MemoryAllocator (jezgro ne sme
    // da zove sopstveni sistemski poziv mem_alloc kroz ecall)
    void* operator new(size_t size);
    void operator delete(void* ptr);

private:
    TCB(Body body, void* arg, uint64* stack);

    // zamrznuta slika niti: dovoljni su ra (gde je stala) i sp (vrh njenog
    // steka) - ostali registri se cuvaju na njenom steku, pa ih sp "vuce" sobom
    struct Context {
        uint64 ra;
        uint64 sp;
    };

    Body body;        // funkcija koju nit izvrsava
    void* arg;        // argument te funkcije
    uint64* stack;    // pocetak alociranog prostora za stek (za kasnije oslobadjanje)
    Context context;  // zamrznuta slika (vazi samo dok nit ne radi)
    bool finished;    // da li je nit zavrsila (thread_exit)
    TCB* next;        // ulancavanje u Scheduler-ov red (intruzivno, bez alokacija)

    friend class Scheduler;   // Scheduler sme da koristi next za svoj red
};

#endif // _tcb_hpp_
