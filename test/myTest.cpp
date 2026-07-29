#include "../inc/syscall_cpp.hpp"
#include "printing.hpp"

class Worker: public Thread {
    void workerBody();
    const char* ime;
public:
    Worker(const char* _ime) : Thread(), ime(_ime) {}
    void run() override {
        workerBody();
    }
};
class ReaderA: public Thread {
    Thread* first;
    Thread* second;
    void readerABody();
public:
    ReaderA(Thread* _first, Thread* _second ):Thread(), first(_first), second(_second){}

    void run() override {
        readerABody();
    }
};
void Worker::workerBody(){
    printString("nit "); printString(ime); printString(" krece");printString("\n");
    for (volatile int i = 0; i < 10000; i ++){
        for (volatile int j = 0; j < 100000; j ++);
    }
    printString("nit "); printString(ime); printString(" je gotova");printString("\n");
}
void ReaderA::readerABody(){
    printString("nit "); printString("A"); printString(" krece");printString("\n");
    first->join();
    second->join();
    printString("nit "); printString("A"); printString(" je gotova");printString("\n");

}


void my_test() {
    Worker* b = new Worker("B");
    Worker* c = new Worker("C");
    ReaderA* a = new ReaderA(b, c);

    b->start();
    c->start();
    a->start();

    a->join();

}