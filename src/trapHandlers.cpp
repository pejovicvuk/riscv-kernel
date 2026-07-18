#include "../lib/hw.h"
#include "../h/print.hpp"
#include "../h/memoryAllocator.hpp"

// zajednicki c deo prekidne rutine: cita scause i grana se na obradu.
// a0..a3 parametri se poklapaju sa registrima a0..a3 u trenutku trapa
// (trap.S ih ne dira pre call-a), pa abi argumente citamo direktno.
extern "C" uint64 handleTrap(uint64 a0, uint64 a1, uint64 a2, uint64 a3) {
    uint64 cause;
    asm volatile("csrr %0, scause" : "=r"(cause));
    kputs("c="); kputhex(cause); kputs(" ");   // debug: ceo scause, top bit = prekid/izuzetak

    uint64 topBit = cause >> 63;
    uint64 code   = cause & 0xff;

    if (topBit == 1) {
        // asinhroni prekid - za sad samo pocisti zahtev i vrati se
        if (code == 1) {
            // softverski (tajmer) - obrisi ssip bit u sip
            uint64 sip;
            asm volatile("csrr %0, sip" : "=r"(sip));
            sip &= ~(1UL << 1);
            asm volatile("csrw sip, %0" : : "r"(sip));
        } else if (code == 9) {
            // spoljasnji (konzola) - potvrdi preko plic-a
            int irq = plic_claim();
            plic_complete(irq);
        }
        // sepc se ne dira: prekinuta instrukcija mora da se ponovi
        return a0;
    }
    else if (topBit == 0 && (code == 8 || code == 9)) {
        // ecall (8 = iz korisnickog, 9 = iz sistemskog rezima)
        kputs("   [ECALL] a0="); kputhex(a0); kputs("\n");
        uint64 ret = 0;
        switch (a0) {
            case 0x01:
                kputs("   pre alloc, a1="); kputhex(a1); kputs("\n");
                ret = (uint64)MemoryAllocator::alloc(a1 * MEM_BLOCK_SIZE);
                kputs("   posle alloc, ret="); kputhex(ret); kputs("\n");
                break;
            case 0x02:
                ret = (uint64)MemoryAllocator::free((void*)a1);
                break;
        }
        // sepc pokazuje na sam ecall: pomeri ga da se ne bi vrteli
        kputs("   pre sepc\n");
        uint64 sepc;
        asm volatile("csrr %0, sepc" : "=r"(sepc));
        sepc += 4;
        asm volatile("csrw sepc, %0" : : "r"(sepc));
        kputs("   pre return\n");
        return ret;
    }

    // nepoznat uzrok (izuzetak koji ne umemo da obradimo): panika.
    // ne vracamo se - sepc bi pokazivao na istu instrukciju i vrteli bismo se.
    uint64 sepc;
    asm volatile("csrr %0, sepc" : "=r"(sepc));
    kputs("PANIC: cause="); kputhex(cause);
    kputs(" sepc=");        kputhex(sepc);
    kputs("\n");
    *(volatile int*)0x100000 = 0x5555;   // halt emulatora
    return a0;
}
