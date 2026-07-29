#include "../inc/syscall_cpp.hpp"
#include "printing.hpp"

class ThreadC : public Thread{
    const char* name;
public:
    ThreadC(const char* _name) : Thread(), name(_name){}
    void run() override{
        printString(name) ;printString(" krece \n");
        printString(" C krece \n");
        for (volatile int i = 0; i < 100000; i++);
        printString(" C gotov \n");
        printString(name) ;printString(" krece \n");
    }
};

class ThreadB : public Thread{
    const char* name;
public:
    ThreadB(const char* _name) : Thread(), name(_name){}
    void run() override{
        printString(name) ;printString(" krece \n");
        ThreadC* c1 = new ThreadC("c1");
        ThreadC* c2 = new ThreadC("c2");
        ThreadC* c3 = new ThreadC("c3");

        c1->start();
        c2->start();
        c3->start();

        this->addChild(c1);
        this->addChild(c2);
        this->addChild(c3);

        this->joinAll();
        printString(name) ;printString(" gotov \n");
    }
};

class ThreadA : public Thread{
    
    void workerBodyA();
public:
    void run() override{
        workerBodyA();
    }
};
void ThreadA::workerBodyA(){
        printString(" A krece \n");
        ThreadB* b1 = new ThreadB("b1");
        ThreadB* b2 = new ThreadB("b2");
        ThreadB* b3 = new ThreadB("b3");

        ThreadC* c1 = new ThreadC("c(A)");

        b1->start();
        b2->start();
        b3->start();
        c1->start();

        this->addChild(b1);
        this->addChild(b2);
        this->addChild(b3);
        this->addChild(c1);

        this->joinAll();

        printString(" A gotov \n");
}


void my_test() {
    ThreadA* a = new ThreadA();
    a->start();
    a->addChild(a);
    a->joinAll();

}