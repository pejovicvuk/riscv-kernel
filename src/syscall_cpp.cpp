// implementacija c++ api-ja: svaka metoda je tanak omotac oko
// odgovarajuceg c api poziva (koji dalje ide ecall-om u jezgro)
#include "../inc/syscall_cpp.hpp"

// ---------- Thread ----------

// javni konstruktor: nit sa pokazivacem na funkciju - pamti body i arg,
// nit jos NE postoji u jezgru (nastaje tek u start)
Thread::Thread(void (*body)(void*), void* arg)
    : myHandle(nullptr), body(body), arg(arg) {}

// zasticeni konstruktor: za izvedene klase koje redefinisu run()
Thread::Thread() : myHandle(nullptr), body(nullptr), arg(nullptr) {}

// destruktor ne radi nista: jezgro samo oslobadja stek i tcb
// kad nit zavrsi (zombi mehanizam), a c api nema thread_delete
Thread::~Thread() {}

// tek ovde jezgro pravi nit; kao telo se uvek salje runWrapper sa this,
// pa se odluka body-ili-run donosi kad nit prvi put dobije procesor
int Thread::start() {
    return thread_create(&myHandle, runWrapper, this);
}

// pdf str. 11: ako je konstruktorom postavljen pokazivac na funkciju,
// run se ignorise u svakom slucaju - zato body ima prednost
void Thread::runWrapper(void* t) {
    Thread* self = (Thread*) t;
    if (self->body) {
        self->body(self->arg);
    } else {
        self->run();
    }
}

void Thread::dispatch() {
    thread_dispatch();
}

int Thread::getId(){
    return thread_getid();
}

// stub do zadatka 4: nema time_sleep sistemskog poziva jos - vraca gresku
int Thread::sleep(time_t) {
    return -1;
}

// ---------- PeriodicThread ----------

PeriodicThread::PeriodicThread(time_t period) : Thread(), period(period) {}

// stub do zadatka 4: periodicno aktiviranje trazi time_sleep
void PeriodicThread::terminate() {}

// ---------- Semaphore ----------

// semafor u jezgru nastaje odmah u konstruktoru (nema odvojenog start-a)
Semaphore::Semaphore(unsigned init) : myHandle(nullptr) {
    sem_open(&myHandle, init);
}

// zatvaranje oslobadja scb u jezgru i budi eventualne cekace sa greskom
Semaphore::~Semaphore() {
    sem_close(myHandle);
}

int Semaphore::wait() {
    return sem_wait(myHandle);
}

int Semaphore::signal() {
    return sem_signal(myHandle);
}
void Semaphore::pairSems(Semaphore *s1, Semaphore *s2){
    sem_pair(s1->myHandle, s2->myHandle);
}

// ---------- Console ----------

// fasada (pdf str. 11): samo prostor imena oko c poziva;
// :: ispred da se ne bi rekurzivno zvala ista metoda
char Console::getc() {
    return ::getc();
}

void Console::putc(char c) {
    ::putc(c);
}
