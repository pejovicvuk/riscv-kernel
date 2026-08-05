#include "../inc/tcb.hpp"
#include "../inc/scheduler.hpp"
#include "../inc/memoryAllocator.hpp"
#include "../inc/print.hpp"
#include "../inc/riscv.hpp"
#include "../inc/syscall_c.h"   // za thread_exit iz userWrapper-a (u-mode deo)

// asemblerska rutina iz contextSwitch.S
extern "C" void contextSwitch(TCB::Context* oldCtx, TCB::Context* newCtx);

TCB* TCB::running   = nullptr;
TCB* TCB::zombie    = nullptr;
uint64 TCB::usedTicks = 0;
TCB* TCB::sleepHead = nullptr;

// new/delete za tcb: direktno na alokator jezgra (bez ecall-a)
void* TCB::operator new(size_t size) {
    return MemoryAllocator::alloc(size);
}
void TCB::operator delete(void* ptr) {
    MemoryAllocator::free(ptr);
}

TCB::TCB(Body body, void* arg, uint64* stack, bool systemLevel)
    : body(body), arg(arg), stack(stack),
      context({0, 0}),
      finished(false), systemLevel(systemLevel),
      timeSlice(DEFAULT_TIME_SLICE), next(nullptr),
      blockResult(0), pendingN(1), sleepRelative(0)
{}

// otkucaj tajmera: kvantum tekuce niti curi; kad iscuri - preotimanje.
// (nulta nit main-a mora da postoji pre prvog otkucaja - vidi main.cpp)
bool TCB::tick() {
    return ++usedTicks >= running->timeSlice;
}

// pocisti nit koja je umrla pre naseg budjenja (njen stek i tcb);
// zovemo je sa SVAKOG mesta budjenja: iza contextSwitch-a i na ulazu u wrapper
void TCB::reapZombie() {
    if (!zombie) return;
    if (zombie->stack) MemoryAllocator::free(zombie->stack);
    delete zombie;
    zombie = nullptr;
}

// prva funkcija u zivotu svake niti (u nju nas ubaci falsifikovani ra).
// s-mode deo: interne niti jezgra rade telo odmah, ovde; korisnicke niti
// se SPUSTAJU u korisnicki rezim jedinom kapijom nadole - sret-om
void TCB::threadWrapper() {
    reapZombie();   // i rodjenje je budjenje: pocisti eventualnog prethodnika

    if (running->systemLevel) {
        // interna nit jezgra: telo ostaje privilegovano
        running->body(running->arg);
        running->finished = true;
        dispatch();     // odavde nema povratka
    }

    // korisnicka nit: namesti sret tako da "vrati" u userWrapper, u u-modu
    Riscv::w_sepc((uint64)&userWrapper);
    Riscv::mc_sstatus(Riscv::SSTATUS_SPP);     // spp = 0: sret vodi u u-mode
    asm volatile("sret");                      // spust: dalje u userWrapper
}

// u-mode deo omotaca: OVO se izvrsava u korisnickom rezimu.
// tcb sme da CITA (isti adresni prostor, nema memorijske zastite -
// granica privilegija su instrukcije), ali u jezgro sme samo kroz ecall
void TCB::userWrapper() {
    running->body(running->arg);
    thread_exit();      // ecall - jedini legalan povratak u jezgro
    for (;;) {}         // nedostizno; osiguranje da se nikad ne "ispadne"
}

TCB* TCB::createThread(Body body, void* arg, void* stackSpace, bool systemLevel) {
    // prava nit bez steka ne moze da postoji
    if (body && !stackSpace) return nullptr;

    TCB* tcb = new TCB(body, arg, (uint64*)stackSpace, systemLevel);
    if (!tcb) return nullptr;

    if (body) {
        // bootstrap: falsifikuj proslost niti da izgleda kao da je "zaspala"
        // na samom ulazu u threadWrapper. prvo budjenje (contextSwitch) ce:
        // pokupiti 12 laznih s-registara sa steka, pa ret na threadWrapper.
        uint64 top = (uint64)stackSpace + DEFAULT_STACK_SIZE;   // stek raste ka nizim adresama
        tcb->context.sp = top - 96;                             // mesto za 12 "s-registara"
        uint64* fakeRegs = (uint64*)tcb->context.sp;
        for (int i = 0; i < 12; i++) fakeRegs[i] = 0;           // nit krece cistih ruku
        tcb->context.ra = (uint64)&threadWrapper;

        Scheduler::put(tcb);
    }
    // nulta nit (body == nullptr, main): bez steka i bez reda - njen kontekst
    // ce prirodno upisati njen prvi contextSwitch
    return tcb;
}

// prebaci se na sledecu spremnu nit. PRETPOSTAVKA: tekuca nit je vec
// zbrinuta (red spremnih / red semafora / zombi) - ovde se samo menja
void TCB::switchToNext() {
    TCB* old = running;
    TCB* next = Scheduler::get();
    if (!next) {
        // nema nijedne spremne niti: sistem nema sta da radi (moguc i deadlock)
        kputs("nema spremnih niti\n");
        *(volatile int*)0x100000 = 0x5555;
    }

    running = next;
    usedTicks = 0;   // novoizabrana nit dobija svez kvantum - jedno mesto
                     // pokriva sve puteve: dispatch, exit, blokadu i preotimanje
    contextSwitch(&old->context, &running->context);
    // budjenje: sad smo na steku probudjene niti - bezbedno pocisti zombija
    reapZombie();
}

// sinhrona promena konteksta: tekuca nit ustupa procesor
void TCB::dispatch() {
    if (!running->finished) Scheduler::put(running);
    else zombie = running;   // jos stojimo na njegovom steku - ciscenje kasnije!
    switchToNext();
}

// uspavaj tekucu nit na zadati broj otkucaja tajmera (syscall 0x31).
// umetanje u sortiranu listu relativnih razlika: setajuci kroz listu
// trosimo zadato vreme na prethodnike; ostatak je NASA razlika, a
// sledbeniku se ona ODUZIMA - on od sada meri vreme od nas
int TCB::putToSleep(time_t ticks) {
    if (ticks == 0) return 0;   // nema sta da se ceka

    TCB* self = running;

    // nadji mesto: preskoci sve koji se bude pre nas (ili tacno kad i mi)
    TCB* prev = nullptr;
    TCB* curr = sleepHead;
    while (curr && curr->sleepRelative <= ticks) {
        ticks -= curr->sleepRelative;
        prev = curr;
        curr = curr->next;
    }

    self->sleepRelative = ticks;
    if (curr) curr->sleepRelative -= ticks;   // sledbenik sada meri od nas

    // uvezivanje istim next pokazivacem (nit je u najvise jednom redu:
    // spava, pa nije ni u scheduleru ni u redu nekog semafora)
    self->next = curr;
    if (prev) prev->next = self;
    else      sleepHead = self;

    // predaj procesor: za nit sada zna samo lista uspavanih,
    // dok je tajmerska grana ne vrati medju spremne
    switchToNext();
    return 0;
}

// jedan otkucaj tajmera za spavace: odbrojava se SAMO celo liste (ostali
// su relativni na njega), pa se bude redom svi kojima je razlika pala na
// nulu - vise niti moze deliti isti trenutak budjenja
void TCB::wakeSleepers() {
    if (!sleepHead) return;
    if (sleepHead->sleepRelative > 0) sleepHead->sleepRelative--;
    while (sleepHead && sleepHead->sleepRelative == 0) {
        TCB* awake = sleepHead;
        sleepHead = sleepHead->next;   // prvo pomeri glavu - put gazi next!
        Scheduler::put(awake);
    }
}
