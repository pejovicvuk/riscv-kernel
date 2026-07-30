#include "../inc/syscall_cpp.hpp"
#include "printing.hpp"

Semaphore *semMain, *sem1, *sem2, *sem3, *sem4, *sem5, *mutex, *done;
int counter = 0;
class Nit : public Thread{
    Semaphore* sem;
public:
    Nit(Semaphore* _sem) : Thread(), sem(_sem){}
    void run() override{
        for (int i = 0; i < 5; i++){
            printString("id "); printInt(getId()); printString(" iteracija "); printInt(i);
            printString("\n");
            int r = sem->wait();
            if (r == 0){
                printString("id "); printInt(getId()); printString(" prosla semafor "); printInt(i);
                printString("\n");
            }
            else{
                printString("###id "); printInt(getId()); printString("prosla semafor "); printInt(i);
                printString("\n");
                mutex->wait();
                counter++;
                mutex->signal();
            }
            for (int k = 0; k < 1000; k++) Thread::dispatch();
        }
        done->signal();
    }
};

void my_test() {
    mutex = new Semaphore(1);
    done = new Semaphore(0);

    semMain = new Semaphore(100);
    sem1 = new Semaphore(1);
    sem2 = new Semaphore(2);
    sem3 = new Semaphore(3);
    sem4 = new Semaphore(4);
    sem5 = new Semaphore(5);

    Semaphore::pairSems(semMain, sem1);
    Semaphore::pairSems(semMain, sem2);
    Semaphore::pairSems(semMain, sem3);
    Semaphore::pairSems(semMain, sem4);
    Semaphore::pairSems(semMain, sem5);

    Nit* nit1 = new Nit(sem1);
    Nit* nit2 = new Nit(sem2);
    Nit* nit3 = new Nit(sem3);
    Nit* nit4 = new Nit(sem4);
    Nit* nit5 = new Nit(sem5);

    nit1->start();
    nit2->start();
    nit3->start();
    nit4->start();
    nit5->start();

    for (int i = 0; i < 5; i++) done->wait();

    printString("konacni broj: "); printInt(counter);
}