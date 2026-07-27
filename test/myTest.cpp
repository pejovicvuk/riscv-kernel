#include "../inc/syscall_cpp.hpp"
#include "printing.hpp"

static Semaphore* done;

static void primalac(void* arg){
    int p;
    receive(&p);                       // scenario 1: spava dok ne stigne
    printString("primio: "); printInt(p); printString("\n");
    for (int i = 0; i < 3; i++){       // scenario 3: FIFO
        receive(&p);
        printInt(p); printString("\n");
    }
    done->signal();
}

static void posiljalac(void* arg){
    thread_t b = (thread_t)arg;                    // koverta -> rucka primaoca
    for (volatile int j = 0; j < 100000; j++);     // pauza: B sigurno prvi ceka
    send(b, 42);                                   // scenario 2: budjenje
    send(b, 10); send(b, 20); send(b, 30);         // tri zaredom
    done->signal();
}

void my_test(){
    
    done = new Semaphore(0);

    thread_t b;
    thread_create(&b, primalac, nullptr);      // prvo primalac (odmah legne da ceka)

    thread_t a;
    thread_create(&a, posiljalac, (void*)b);   // posiljalac dobija B-ovu rucku u koverti

    done->wait();                              // dva radnika -> dva cekanja
    done->wait();

    delete done;

}