// c++ api implementation: every method is a thin wrapper around the
// matching c api call (which then goes into the kernel via ecall)
#include "../inc/syscall_cpp.hpp"

// ---------- Thread ----------

// public constructor: thread with a function pointer - stores body and arg,
// the thread does NOT exist in the kernel yet (it is created only in start)
Thread::Thread(void (*body)(void*), void* arg)
    : myHandle(nullptr), body(body), arg(arg) {}

// protected constructor: for derived classes that override run()
Thread::Thread() : myHandle(nullptr), body(nullptr), arg(nullptr) {}

// the destructor does nothing: the kernel frees the stack and tcb itself
// when the thread finishes (zombie mechanism), and the c api has no thread_delete
Thread::~Thread() {}

// only here does the kernel create the thread; runWrapper with this is always
// passed as the body, so the body-or-run choice is made when the thread first gets the cpu
int Thread::start() {
    return thread_create(&myHandle, runWrapper, this);
}

// spec p. 11: if a function pointer was set by the constructor,
// run is ignored in any case - so body takes precedence
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

// the thread sleeps for the given number of timer periods (part 4)
int Thread::sleep(time_t time) {
    return time_sleep(time);
}

// ---------- PeriodicThread ----------

PeriodicThread::PeriodicThread(time_t period) : Thread(), period(period) {}

// periodic thread body: activate then sleep, until someone stops it.
// the interface from the spec must not get new fields, so terminate uses
// the existing period field: 0 = stop request (period 0 makes no sense anyway)
void PeriodicThread::run() {
    while (period > 0) {
        periodicActivation();
        if (period > 0) Thread::sleep(period);   // terminate may also come from the activation
    }
}

// shutdown: the current sleep completes, there are no more activations;
// after that the thread finishes normally (leaves the run loop)
void PeriodicThread::terminate() {
    period = 0;
}

// ---------- Semaphore ----------

// the kernel semaphore is created right in the constructor (no separate start)
Semaphore::Semaphore(unsigned init) : myHandle(nullptr) {
    sem_open(&myHandle, init);
}

// closing frees the kernel scb and wakes any waiters with an error
Semaphore::~Semaphore() {
    sem_close(myHandle);
}

int Semaphore::wait() {
    return sem_wait(myHandle);
}

int Semaphore::signal() {
    return sem_signal(myHandle);
}

// ---------- Console ----------

// facade (spec p. 11): just a namespace around the c calls;
// :: in front so the same method is not called recursively
char Console::getc() {
    return ::getc();
}

void Console::putc(char c) {
    ::putc(c);
}
