#include "../lib/hw.h"
#include "../h/print.hpp"
#include "../h/memoryAllocator.hpp"
#include "../h/tcb.hpp"

// zajednicki c deo prekidne rutine: cita scause i grana se na obradu.
// a0..a4 parametri se poklapaju sa registrima a0..a4 u trenutku trapa
// (trap.S ih ne dira pre call-a), pa abi argumente citamo direktno.
extern "C" uint64 handleTrap(uint64 a0, uint64 a1, uint64 a2, uint64 a3, uint64 a4) {
    uint64 cause, sepc, sstatus;
    asm volatile("csrr %0, scause"  : "=r"(cause));
    asm volatile("csrr %0, sepc"    : "=r"(sepc));
    asm volatile("csrr %0, sstatus" : "=r"(sstatus));
    // sepc i sstatus su DEO KONTEKSTA NITI: obrada moze da promeni nit
    // (dispatch), a dok ova nit spava, globalne csr registre ce puniti tudji
    // trapovi. zato ih odmah snimamo u lokalne promenljive (zive na steku ove
    // niti, parkiraju se s njom), a pred povratak vracamo bas nase vrednosti.

    uint64 topBit = cause >> 63;
    uint64 code   = cause & 0xff;
    uint64 ret    = a0;

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
        // sepc se ne uvecava: prekinuta instrukcija mora da se ponovi
    }
    else if (topBit == 0 && (code == 8 || code == 9)) {
        // ecall (8 = iz korisnickog, 9 = iz sistemskog rezima)
        sepc += 4;   // preskoci sam ecall - u lokalnoj kopiji!

        switch (a0) {
            case 0x01:   // mem_alloc(broj blokova)
                ret = (uint64)MemoryAllocator::alloc(a1 * MEM_BLOCK_SIZE);
                break;
            case 0x02:   // mem_free(pokazivac)
                ret = (uint64)MemoryAllocator::free((void*)a1);
                break;
            case 0x11: { // thread_create(handle, telo, arg, stek)
                // niti nastale kroz syscall su korisnicke: telo u u-modu
                TCB* tcb = TCB::createThread((TCB::Body)a2, (void*)a3, (void*)a4, false);
                if (tcb) { *(TCB**)a1 = tcb; ret = 0; }
                else     { ret = (uint64)-1; }
                break;
            }
            case 0x12:   // thread_exit - odavde nema povratka za ovu nit
                TCB::running->setFinished(true);
                TCB::dispatch();
                break;
            case 0x13:   // thread_dispatch - nit dobrovoljno ustupa procesor
                TCB::dispatch();
                ret = 0;
                break;
            default:
                ret = (uint64)-1;   // nepoznat kod sistemskog poziva
        }
    }
    else {
        // nepoznat uzrok (izuzetak koji ne umemo da obradimo): panika.
        // ne vracamo se - sepc bi pokazivao na istu instrukciju i vrteli bismo se.
        kputs("PANIC: cause="); kputhex(cause);
        kputs(" sepc=");        kputhex(sepc);
        kputs("\n");
        *(volatile int*)0x100000 = 0x5555;   // halt emulatora
    }

    // svako se vraca sa SVOJIM vrednostima, ma koliko dugo spavao
    asm volatile("csrw sstatus, %0" : : "r"(sstatus));
    asm volatile("csrw sepc, %0"    : : "r"(sepc));
    return ret;
}
