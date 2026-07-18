#include "../h/tcb.hpp"
#include "../h/scheduler.hpp"
#include "../h/memoryAllocator.hpp"
#include "../h/print.hpp"

// asemblerska rutina iz contextSwitch.S
extern "C" void contextSwitch(TCB::Context* oldCtx, TCB::Context* newCtx);

TCB* TCB::running = nullptr;

// new/delete za tcb: direktno na alokator jezgra (bez ecall-a)
void* TCB::operator new(size_t size) {
    return MemoryAllocator::alloc(size);
}
void TCB::operator delete(void* ptr) {
    MemoryAllocator::free(ptr);
}

TCB::TCB(Body body, void* arg, uint64* stack)
    : body(body), arg(arg), stack(stack),
      context({0, 0}),
      finished(false), next(nullptr)
{}

// prva funkcija u zivotu svake niti (u nju nas ubaci falsifikovani ra);
// kad se telo zavrsi, nit se uredno gasi i nikad vise ne dobija procesor
void TCB::threadWrapper() {
    running->body(running->arg);
    running->finished = true;
    dispatch();   // odavde nema povratka
}

TCB* TCB::createThread(Body body, void* arg) {
    // stek niti: DEFAULT_STACK_SIZE bajtova iz hw.h
    uint64* stack = (uint64*)MemoryAllocator::alloc(DEFAULT_STACK_SIZE);
    if (!stack) return nullptr;

    TCB* tcb = new TCB(body, arg, stack);
    if (!tcb) { MemoryAllocator::free(stack); return nullptr; }

    // bootstrap: falsifikuj proslost niti da izgleda kao da je "zaspala"
    // na samom ulazu u threadWrapper. prvo budjenje (contextSwitch) ce:
    // pokupiti 12 laznih s-registara sa steka, pa ret na threadWrapper.
    uint64 top = (uint64)stack + DEFAULT_STACK_SIZE;   // stek raste ka nizim adresama
    tcb->context.sp = top - 96;                        // mesto za 12 "s-registara"
    uint64* fakeRegs = (uint64*)tcb->context.sp;
    for (int i = 0; i < 12; i++) fakeRegs[i] = 0;      // nit krece cistih ruku
    tcb->context.ra = (uint64)&threadWrapper;

    // main-ova nulta nit (body == nullptr) se ne raspredjuje kroz red
    if (body) Scheduler::put(tcb);
    return tcb;
}

// sinhrona promena konteksta: tekuca nit ustupa procesor
void TCB::dispatch() {
    TCB* old = running;
    if (!old->finished) Scheduler::put(old);   // gotova nit se ne vraca u red

    TCB* next = Scheduler::get();
    if (!next) {
        // nema nijedne spremne niti, a tekuca je gotova: sistem nema sta da radi
        kputs("PANIC: nema spremnih niti\n");
        *(volatile int*)0x100000 = 0x5555;
    }

    running = next;
    contextSwitch(&old->context, &running->context);
    // odavde se nastavlja tek kad neko VRATI procesor staroj niti
}
