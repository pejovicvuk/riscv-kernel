#ifndef _syscall_cpp_hpp_
#define _syscall_cpp_hpp_

#include "syscall_c.h"

// c++ api jezgra (potpisi iz postavke projekta, str. 10 - ne smeju se menjati!).
// tanki omotaci oko c api-ja: svaka klasa samo prosledjuje pozive
// odgovarajucem sistemskom pozivu preko svoje rucke (myHandle).

// globalni new/delete su preusmereni na mem_alloc/mem_free (src/_new.cpp)
void* operator new(size_t size);
void  operator delete(void* ptr) noexcept;

class Thread {
public:
    Thread(void (*body)(void*), void* arg, int priority = DEFAULT_PRIORITY);
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
    int priority;   // prioritet OVE niti (podrazumevano DEFAULT_PRIORITY)

    // telo koje jezgro stvarno pokrece: dobija this, pa bira body ili run()
    // (pdf str. 11: ako je konstruktorom dat pokazivac na funkciju, run se ignorise)
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

private:
    time_t period;
};

class Console {
public:
    static char getc();
    static void putc(char);
};

#endif // _syscall_cpp_hpp_
