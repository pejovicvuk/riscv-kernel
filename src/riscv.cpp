#include "../inc/riscv.hpp"
#include "../lib/hw.h"
#include "../inc/print.hpp"
#include "../inc/memoryAllocator.hpp"
#include "../inc/tcb.hpp"
#include "../inc/scb.hpp"
#include "../inc/ccb.hpp"     // nasa konzola (zadatak 4)

// zajednicki c deo prekidne rutine: cita scause i grana se na obradu.
// a0..a4 parametri se poklapaju sa registrima a0..a4 u trenutku trapa
// (trap.S ih ne dira pre call-a), pa abi argumente citamo direktno.
extern "C" uint64 handleSupervisorTrap(uint64 a0, uint64 a1, uint64 a2, uint64 a3, uint64 a4) {
    uint64 cause   = Riscv::r_scause();
    uint64 sepc    = Riscv::r_sepc();
    uint64 sstatus = Riscv::r_sstatus();
    // sepc i sstatus su DEO KONTEKSTA NITI: obrada moze da promeni nit
    // (dispatch), a dok ova nit spava, globalne csr registre ce puniti tudji
    // trapovi. zato ih odmah snimamo u lokalne promenljive (zive na steku ove
    // niti, parkiraju se s njom), a pred povratak vracamo bas nase vrednosti.

    uint64 topBit = cause >> 63;
    uint64 code   = cause & 0xff;
    uint64 ret    = a0;

    if (topBit == 1) {
        // asinhroni prekid
        if (code == 1) {
            // softverski (tajmer), stize 10x u sekundi: potvrdi prijem,
            // pa odradi oba vremenska posla (pdf str. 28):
            // 1) probudi uspavane niti kojima je isteklo time_sleep vreme
            // 2) naplati otkucaj tekucoj niti; istekao kvantum ->
            //    ASINHRONA promena konteksta: nit gubi procesor bez svog
            //    znanja i pristanka (deljenje vremena)
            Riscv::mc_sip(Riscv::SIP_SSIP);
            TCB::wakeSleepers();
            if (TCB::tick()) {
                TCB::dispatch();
            }
        } else if (code == 9) {
            // spoljasnji (konzola): nasa obrada (zadatak 4) - prekidna
            // rutina je PROIZVODJAC ulaznog bafera: plic_claim/complete
            // + prebaci pristigle znakove iz kontrolera u bafer
            CCB::handleInterrupt();
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
            case 0x21: { // sem_open(handle, init)
                SCB* sem = SCB::createSemaphore((unsigned)a2);
                if (sem) { *(SCB**)a1 = sem; ret = 0; }
                else     { ret = (uint64)-1; }
                break;
            }
            case 0x22: { // sem_close - deblokira sve cekace (sa greskom), pa se brise
                SCB* sem = (SCB*)a1;
                if (!sem) { ret = (uint64)-1; break; }
                ret = (uint64)sem->close();
                delete sem;
                break;
            }
            case 0x23:   // sem_wait = wait(1); moze da blokira nit bas ovde
                ret = a1 ? (uint64)((SCB*)a1)->wait(1) : (uint64)-1;
                break;
            case 0x24:   // sem_signal = signal(1)
                ret = a1 ? (uint64)((SCB*)a1)->signal(1) : (uint64)-1;
                break;
            case 0x25:   // sem_wait_n(id, n)
                ret = a1 ? (uint64)((SCB*)a1)->wait((unsigned)a2) : (uint64)-1;
                break;
            case 0x26:   // sem_signal_n(id, n)
                ret = a1 ? (uint64)((SCB*)a1)->signal((unsigned)a2) : (uint64)-1;
                break;
            case 0x31:   // time_sleep(broj otkucaja tajmera)
                ret = (uint64)TCB::putToSleep((time_t)a1);
                break;
            case 0x41:   // getc - iz naseg ulaznog bafera (zadatak 4)
                // prazan bafer -> nit BLOKIRA bas ovde (kao sem_wait);
                // budi je konzolni prekid kad znak stigne. nasi
                // sepc/sstatus mirno cekaju u lokalima na njenom steku
                ret = (uint64)CCB::getc();
                break;
            case 0x42:   // putc - u nas izlazni bafer (zadatak 4)
                // pun bafer -> pozivalac blokira dok izlazna nit
                // jezgra ne oslobodi mesto
                CCB::putc((char)a1);
                ret = 0;
                break;
            default:
                ret = (uint64)-1;   // nepoznat kod sistemskog poziva
        }
    }
    else {
        // nepoznat uzrok (izuzetak koji ne umemo da obradimo): panika.
        // ne vracamo se - sepc bi pokazivao na istu instrukciju i vrteli bismo se.

        kputs("emulator pukao\n");
        *(volatile int*)0x100000 = 0x5555;   // halt emulatora
    }

    // svako se vraca sa SVOJIM vrednostima, ma koliko dugo spavao
    Riscv::w_sstatus(sstatus);
    Riscv::w_sepc(sepc);
    return ret;
}
