#include "../inc/syscall_cpp.hpp"
#include "printing.hpp"

static sem_t start, finish;

void body(void* arg){
    uint64 id = (uint64)arg;
    printString("thread "); printInt(id); printString(" started \n");
    sem_wait(start);
    printString("thread "); printInt(id); printString(" began working \n");
    for (volatile uint64 i = 0; i < 10000000 * (id+1); i++);
    printString("thread "); printInt(id); printString(" finished working \n");
    sem_signal(finish);
};

void my_test() {
    sem_open(&start, 0);
    sem_open(&finish, 0);

    thread_t threads[5];
    for (int i = 0; i < 5; i++) {
        thread_create(&threads[i], body, (void*)(uint64)i);
    }

    // let ALL of them reach the gate and block there.
    // one dispatch is enough: a blocked thread does not go to the ready queue,
    // so switchToNext chains through the whole queue and only then returns to me
    thread_dispatch();

    printString("-- all waiting, opening the gate --\n");
    sem_signal_n(start, 5);             // NOW there are 5 waiters -> all 5 wake up

    sem_wait_n(finish, 5);
    printString("all threads finished working \n");

    sem_close(start);
    sem_close(finish);
}