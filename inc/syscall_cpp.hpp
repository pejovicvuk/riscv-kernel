#ifndef _syscall_cpp_hpp_
#define _syscall_cpp_hpp_

#include "syscall_c.h"

// kernel c++ api (signatures from the project spec, p. 10 - must not be changed!).
// thin wrappers around the c api: each class just forwards calls
// to the matching system call through its handle (myHandle).

// global new/delete are redirected to mem_alloc/mem_free (src/_new.cpp)
void* operator new(size_t size);
void  operator delete(void* ptr) noexcept;

class Thread {
public:
    Thread(void (*body)(void*), void* arg);
    virtual ~Thread();

    int start();

    static void dispatch();
    static int  sleep(time_t);

protected:
    Thread();
    virtual void run() {}

private:
    thread_t myHandle;
    void (*body)(void*); void* arg;

    // the body the kernel actually starts: gets this, then picks body or run()
    // (spec p. 11: if a function pointer was given to the constructor, run is ignored)
    static void runWrapper(void* t);
};

class Semaphore {
public:
    Semaphore(unsigned init = 1);
    virtual ~Semaphore();

    int wait();
    int signal();

private:
    sem_t myHandle;
};

class PeriodicThread : public Thread {
public:
    void terminate();

protected:
    PeriodicThread(time_t period);
    virtual void periodicActivation() {}

    // periodic thread body: activate then sleep, in a loop (part 4).
    // overrides the EXISTING virtual run() - the interface from the spec must
    // not be extended with new fields or new virtual methods (p. 11)
    void run() override;

private:
    time_t period;
};

class Console {
public:
    static char getc();
    static void putc(char);
};

#endif // _syscall_cpp_hpp_
