// privremeni test program; kad se uveze pravi app.lib sa testovima,
// ovaj fajl se uklanja (duplikat simbola userMain)
#include "../h/syscall_c.hpp"
#include "../h/print.hpp"
#include "../h/tcb.hpp"

// dve niti koje se smenjuju: svaka ispise svoje slovo pa ustupi procesor
static void workerA(void*) {
    for (int i = 0; i < 5; i++) {
        kputs("A");
        TCB::dispatch();
    }
}

static void workerB(void*) {
    for (int i = 0; i < 5; i++) {
        kputs("B");
        TCB::dispatch();
    }
}

void userMain() {
    TCB* a = TCB::createThread(workerA, nullptr);
    TCB* b = TCB::createThread(workerB, nullptr);

    // main (nulta nit) vrti dispatch dok obe ne zavrse
    while (!a->isFinished() || !b->isFinished()) {
        TCB::dispatch();
    }
    kputs("\nobe niti zavrsile\n");
}
