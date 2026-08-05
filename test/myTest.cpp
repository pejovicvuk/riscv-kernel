#include "../inc/syscall_cpp.hpp"
#include "printing.hpp"

static sem_t start, finish;

void body(void* arg){
    uint64 id = (uint64)arg;
    printString("nit "); printInt(id); printString(" je pokrenuta \n");
    sem_wait(start);
    printString("nit "); printInt(id); printString(" je krenula sa radom \n");
    for (volatile uint64 i = 0; i < 10000000 * (id+1); i++);
    printString("nit "); printInt(id); printString(" je gotova sa radom \n");
    sem_signal(finish);
};

void my_test() {
    sem_open(&start, 0);
    sem_open(&finish, 0);

    thread_t threads[5];
    for (int i = 0; i < 5; i++) {
        thread_create(&threads[i], body, (void*)(uint64)i);
    }

    // pusti ih da SVE stignu do rampe i tamo zaspu.
    // jedan dispatch je dovoljan: blokirana nit ne ide u red spremnih,
    // pa switchToNext lancano izvuce sve iz reda, i tek onda vrati mene
    thread_dispatch();

    printString("-- svi cekaju, otvaram rampu --\n");
    sem_signal_n(start, 5);             // SAD ima 5 cekaca -> svih 5 se budi

    sem_wait_n(finish, 5);
    printString("sve niti su zavrsile sa radom \n");

    sem_close(start);
    sem_close(finish);
}