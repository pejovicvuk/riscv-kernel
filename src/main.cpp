#include "../h/print.hpp"
#include "../h/memoryAllocator.hpp"
#include "../h/tcb.hpp"

extern "C" void trapHandler();

void userMain();   // definisana u test fajlu

int main() {
    kputs(">> kernel: starting\n");

    // stvec = adresa prekidne rutine: jedina kapija za ecall/izuzetke/prekide
    uint64 addr = (uint64)&trapHandler;
    asm volatile("csrw stvec, %0" : : "r" (addr));

    // maskiraj prekide: sve radi u sistemskom rezimu, pa sstatus.sie=0
    // znaci "ne prekidaj me" (zahtevi se pamte u sip, ali ne stizu).
    // sret ovo ne kvari: sie<-spie, a spie je snimljena nula.
    uint64 sstatus;
    asm volatile("csrr %0, sstatus" : "=r"(sstatus));
    sstatus &= ~(1UL << 1);
    asm volatile("csrw sstatus, %0" : : "r"(sstatus));

    // dokaz da je maska stvarno upisana
    asm volatile("csrr %0, sstatus" : "=r"(sstatus));
    kputs(">> sstatus posle maske = "); kputhex(sstatus); kputs("\n");

    MemoryAllocator::init();

    // main postaje "nulta" nit: dobija svoj tcb da ima gde da se zamrzne
    // kad prvi put ustupi procesor (kontekst mu se popuni pri prvom dispatch-u)
    TCB::running = TCB::createThread(nullptr, nullptr);

    userMain();    // privremeno: obican poziv funkcije; kasnije postaje
                   // telo prve niti koju pokrece jezgro

    kputs(">> kernel: userMain returned, halting\n");

    // upis 0x5555 na 0x100000 gasi emulator (regularan kraj procesa)
    *(volatile int*)0x100000 = 0x5555;

    return 0;
}
