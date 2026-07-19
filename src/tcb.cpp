#include "../h/tcb.hpp"
#include "../h/scheduler.hpp"
#include "../h/memoryAllocator.hpp"
#include "../h/print.hpp"
#include "../h/syscall_c.hpp"   // za thread_exit iz userWrapper-a (u-mode deo)

// asemblerska rutina iz contextSwitch.S
extern "C" void contextSwitch(TCB::Context* oldCtx, TCB::Context* newCtx);

TCB* TCB::running = nullptr;
TCB* TCB::zombie  = nullptr;

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
      finished(false), systemLevel(systemLevel), next(nullptr)
{}

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
    uint64 target = (uint64)&userWrapper;
    asm volatile("csrw sepc, %0" : : "r"(target));
    uint64 sstatus;
    asm volatile("csrr %0, sstatus" : "=r"(sstatus));
    sstatus &= ~(1UL << 8);                    // spp = 0: sret vodi u u-mode
    asm volatile("csrw sstatus, %0" : : "r"(sstatus));
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

// sinhrona promena konteksta: tekuca nit ustupa procesor
void TCB::dispatch() {
    TCB* old = running;
    if (!old->finished) Scheduler::put(old);
    else zombie = old;   // jos stojimo na njegovom steku - ciscenje kasnije!

    TCB* next = Scheduler::get();
    if (!next) {
        // nema nijedne spremne niti, a tekuca je gotova: sistem nema sta da radi
        kputs("PANIC: nema spremnih niti\n");
        *(volatile int*)0x100000 = 0x5555;
    }

    running = next;
    contextSwitch(&old->context, &running->context);
    // budjenje: sad smo na steku probudjene niti - bezbedno pocisti zombija
    reapZombie();
}
