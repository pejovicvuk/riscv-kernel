#include "../h/syscall_cpp.hpp"
#include "printing.hpp"

static Semaphore *semA, *semB, *done;

class PingWorkerA: public Thread {
    void workerBodyA(void* arg);
public:
    PingWorkerA():Thread() {}

    void run() override {
        workerBodyA(nullptr);
    }
};

void PingWorkerA::workerBodyA(void *arg){
    for (int i = 0; i < 10; i++) {
        semA->wait();
        printString("A: i="); printInt(i); printString("\n");
        semB->signal();
    }
    done->signal();   // javi da je nit A zavrsila
}

static void pingBodyB(void *arg){
    for (int i = 0; i < 10; i++) {
        semB->wait();
        printString("B: i="); printInt(i); printString("\n");
        semA->signal();
    }
    done->signal();   // javi da je nit B zavrsila
}

void my_test() {
    // 1. semafori
    semA = new Semaphore(1);
    semB = new Semaphore(0);
    done = new Semaphore(0);

    // 2. radnici
    PingWorkerA a;
    Thread b(pingBodyB, nullptr);
    a.start();
    b.start();

    // 3. cekaj oba (dva wait-a, nikakva petlja)
    done->wait();
    done->wait();

    // 4. pospremi
    delete semA; delete semB; delete done;
}