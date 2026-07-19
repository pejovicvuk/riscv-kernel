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

    // maskiraj prekide PO VRSTI, u sie registru: ssie (tajmer, bit 1) +
    // seie (konzola, bit 9). sie vazi u OBA rezima - i u korisnickom,
    // gde se sstatus.SIE ignorise. zahtevi se pamte u sip, ali ne stizu.
    // u zadatku 4 se ovi biti samo ukljuce nazad.
    uint64 sie;
    asm volatile("csrr %0, sie" : "=r"(sie));
    sie &= ~((1UL << 1) | (1UL << 9));
    asm volatile("csrw sie, %0" : : "r"(sie));

    // dokaz da je maska stvarno upisana
    asm volatile("csrr %0, sie" : "=r"(sie));
    kputs(">> sie posle maske = "); kputhex(sie); kputs("\n");

    MemoryAllocator::init();

    // main postaje "nulta" nit: dobija svoj tcb da ima gde da se zamrzne
    // kad prvi put ustupi procesor (kontekst mu se popuni pri prvom dispatch-u)
    TCB::running = TCB::createThread(nullptr, nullptr, nullptr, true);   // nulta nit je sistemska

    userMain();    // privremeno: obican poziv funkcije; kasnije postaje
                   // telo prve niti koju pokrece jezgro

    kputs(">> kernel: userMain returned, halting\n");

    // upis 0x5555 na 0x100000 gasi emulator (regularan kraj procesa)
    *(volatile int*)0x100000 = 0x5555;

    return 0;
}
