#include "../inc/syscall_cpp.hpp"
#include "printing.hpp"

Semaphore* done;

class ThreadA : public Thread{

public:
    void run() override{
        for(volatile int i = 0; i < 3; i++){
            printString("nit A id: ");printInt(getId()); printString(" krug "); printInt(i);
            printString("\n");
            for (volatile int j = 0; j < 10000; j++);
            sync();
        }
        done->signal();
    }
};
class ThreadB : public Thread{

public:
    void run() override{
        for(volatile int i = 0; i < 3; i++){
            printString("nit B id: ");printInt(getId()); printString(" krug "); printInt(i);
            printString("\n");
            sync();
        }
        done->signal();
    }
};

void my_test() {
    done = new Semaphore(0);
    ThreadA* a = new ThreadA();
    ThreadB* b = new ThreadB();
    b->start();
    a->start();
    Thread::pair(a,b);
    done->wait();
    done->wait();
    delete done;
}