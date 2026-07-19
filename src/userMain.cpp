// privremeni test program; kad se uveze pravi app.lib sa testovima,
// ovaj fajl se uklanja (duplikat simbola userMain)
#include "../h/syscall_c.hpp"
#include "../h/print.hpp"

// korisnicki kod od sada koristi ISKLJUCIVO c api (kao zvanicni testovi) -
// nigde vise direktnog poziva u jezgro

static volatile bool doneA = false;
static volatile bool doneB = false;

static void workerA(void*) {
    // provera rezima (odkomentarisi jednu liniju): u u-modu privilegovana
    // instrukcija MORA da izazove PANIC cause=0x2 - to je nas "test 7"
    // asm volatile("csrr t6, sepc");
    for (int i = 0; i < 5; i++) {
        kputs("A");
        thread_dispatch();
    }
    doneA = true;
}

static void workerB(void*) {
    for (int i = 0; i < 5; i++) {
        kputs("B");
        thread_dispatch();
    }
    doneB = true;
}

void userMain() {
    thread_t a, b;
    thread_create(&a, workerA, nullptr);
    thread_create(&b, workerB, nullptr);

    // main (nulta nit) vrti dispatch dok obe ne zavrse
    while (!doneA || !doneB) {
        thread_dispatch();
    }
    kputs("\nobe niti zavrsile\n");
}
