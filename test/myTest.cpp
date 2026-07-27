#include "../inc/syscall_cpp.hpp"
#include "printing.hpp"

static Semaphore* done;

static void body(void *arg){
    char* letter = (char*)arg;
    for (int i = 0; i < 10; i++){
        printString(letter);
        for (volatile int j = 0; j < 100000; j++);
    }
    printString("\n");
    done->signal();
}

void my_test(){
    done = new Semaphore(0);

    Thread t1(body, (void*)"A", 1);
    Thread t2(body, (void*)"B", 2);
    Thread t3(body, (void*)"C", 3);

    t3.start();
    t2.start();
    t1.start();
    
    done->wait();
    done->wait();
    done->wait();

    delete done;
}