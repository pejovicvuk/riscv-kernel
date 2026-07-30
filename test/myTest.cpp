#include "../inc/syscall_cpp.hpp"
#include "printing.hpp"

Semaphore* done;

class Nit : public Thread{

public:
    void run() override{
        for (int i = 0; i < 5; i ++){
            printString("hello "); printInt(getID()); printString("\n");
        }
        for (volatile int i = 0; i < getID()*20000; i++);
        done->signal();
    }
};


void my_test() {
    done = new Semaphore(0);
    Thread::setMaxThread(3);

    for (int i = 0; i < 20; i ++){
        Nit* t = new Nit();
        t->start();
    }
    for (int i = 0; i < 20; i++) done->wait();
}
