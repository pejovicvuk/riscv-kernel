#include "../h/print.hpp"
#include "../h/memoryAllocator.hpp"
#include "../h/tcb.hpp"
#include "../h/riscv.hpp"
#include "../h/syscall_c.h"

void userMain();   // definisana u test fajlu

// omotac: userMain kao telo niti + zastavica kraja.
// kraj se NE sme cekati preko rucke niti (tcb zavrsene niti pojede
// zombi ciscenje), pa nit sama javi da je gotova pre thread_exit-a
static volatile bool userMainDone = false;

static void userMainWrapper(void*) {
    userMain();
    userMainDone = true;
}

int main() {
    kputs(">> kernel: starting\n");

    // stvec = adresa prekidne rutine: jedina kapija za ecall/izuzetke/prekide
    Riscv::w_stvec((uint64)&trap);

    MemoryAllocator::init();

    // main postaje "nulta" nit: dobija svoj tcb da ima gde da se zamrzne
    // kad prvi put ustupi procesor (kontekst mu se popuni pri prvom dispatch-u)
    TCB::running = TCB::createThread(nullptr, nullptr, nullptr, true);   // nulta nit je sistemska

    // prekidi se pustaju tek SAD, kad nulta nit postoji: tajmerski otkucaj
    // naplacuje kvantum tekucoj niti (TCB::tick cita running), pa running
    // mora biti ziv pre prvog prekida.
    // sie po vrsti: konzola (seie) MORA - console_handler na svaki njen
    // prekid prebacuje znakove izmedju kontrolera i bafera console.lib;
    // tajmer (ssie) - pogon deljenja vremena (preotimanje).
    Riscv::ms_sie(Riscv::SIE_SSIE | Riscv::SIE_SEIE);

    // dozvoli prekide i u sistemskom rezimu (sstatus.SIE): main radi u
    // s-modu, a prekidi moraju da stizu i dok je on na procesoru.
    // u-mode niti ovaj bit ne gledaju - za njih vazi direktno sie
    Riscv::ms_sstatus(Riscv::SSTATUS_SIE);

    // pdf str. 4: main "pokrece nit nad funkcijom userMain" - kroz obican
    // thread_create (ecall radi i iz sistemskog rezima), pa ustupa
    // procesor sve dok korisnicki program ne zavrsi
    thread_t userThread;
    if (thread_create(&userThread, userMainWrapper, nullptr) != 0) {
        kputs(">> kernel: neuspesno kreiranje userMain niti\n");
    } else {
        while (!userMainDone) thread_dispatch();
    }

    kputs(">> kernel: userMain finished, halting\n");

    // upis 0x5555 na 0x100000 gasi emulator (regularan kraj procesa)
    *(volatile int*)0x100000 = 0x5555;

    return 0;
}
