#ifndef _tcb_hpp_
#define _tcb_hpp_

#include "../lib/hw.h"

// tcb (thread control block) = the "id card" of one thread:
// everything the kernel must know about a thread to pause and resume it
class TCB {
public:
    typedef void (*Body)(void*);   // type of a thread body: function taking void*

    // frozen snapshot of a thread: ra (where it stopped) and sp (top of its
    // stack) are enough - other registers are saved on its stack, so sp "drags" them along.
    // careful: field layout (ra then sp) must match contextSwitch.S!
    struct Context {
        uint64 ra;
        uint64 sp;
    };

    // factory: create a thread over the given function (body + argument).
    // the stack is NOT allocated by the kernel - it comes from outside (the c api
    // takes it via mem_alloc, per the abi signature of call 0x11 in the spec).
    // sets up the initial context and (if it has a body) puts the thread in the ready queue.
    // systemLevel: true only for internal kernel threads (body stays in s-mode);
    // user threads (via syscall 0x11) use false - body runs in u-mode
    static TCB* createThread(Body body, void* arg, void* stackSpace, bool systemLevel);

    // synchronous context switch: the running thread yields to the next one in the queue
    static void dispatch();

    // timer tick: charge one tick to the running thread;
    // returns true when the time slice has expired (time to preempt)
    static bool tick();

    // put the running thread to sleep for the given number of timer ticks (time_sleep);
    // the timer branch of the trap handler wakes it via wakeSleepers
    static int putToSleep(time_t ticks);

    // timer tick for the sleep list: count down the head of the list (relative
    // time!), then move back to ready all whose time has expired
    static void wakeSleepers();

    bool isFinished() const { return finished; }
    void setFinished(bool f) { finished = f; }

    // the thread currently running; exactly one
    static TCB* running;

    // new/delete for tcb go straight to MemoryAllocator (the kernel must not
    // call its own mem_alloc system call through ecall);
    // SCB uses the same pattern
    void* operator new(size_t size);
    void operator delete(void* ptr);

private:
    TCB(Body body, void* arg, uint64* stack, bool systemLevel);

    // thread body wrapper, s-mode part: first function in every thread's life.
    // for internal kernel threads it calls the body right away; user threads are
    // DROPPED to user mode (sepc=userWrapper, spp=0, sret)
    static void threadWrapper();

    // thread body wrapper, u-mode part: runs in user mode -
    // calls the body, then returns to the kernel the only allowed way
    // (ecall: thread_exit)
    static void userWrapper();

    // zombie mechanism: a finished thread must not free the stack IT IS STANDING ON,
    // so we only record it; the next thread that wakes up cleans it up
    // (standing on its own, safe stack)
    static TCB* zombie;
    static void reapZombie();

    // switch to the next ready thread WITHOUT taking care of the current one -
    // the caller has already put the current one where it belongs
    // (ready queue / semaphore queue / zombie)
    static void switchToNext();

    // used part of the time slice of the RUNNING thread (in timer ticks);
    // one variable is enough - it always refers only to running,
    // and is reset in ONE place: in switchToNext, when a new thread is picked
    static uint64 usedTicks;

    // list of sleeping threads (time_sleep), sorted by wake-up time.
    // each node stores time RELATIVE to its predecessor (spec p. 26): the sum
    // of deltas from the head to a thread = its absolute time. so a tick touches
    // ONLY the head of the list; the only harder operation is insertion
    static TCB* sleepHead;

    Body body;        // function the thread runs
    void* arg;        // argument of that function
    uint64* stack;    // start of the allocated stack space (to free it later)
    Context context;  // frozen snapshot (valid only while the thread is not running)
    bool finished;    // has the thread finished
    bool systemLevel; // true = internal kernel thread (body runs in s-mode)
    time_t timeSlice; // time slice of THIS thread (default DEFAULT_TIME_SLICE)
    TCB* next;        // link in EXACTLY ONE queue at any moment:
                      // either Scheduler (ready) or one semaphore's queue
                      // (blocked) - never both, so one pointer is enough
    int blockResult;  // outcome of waiting on a semaphore: 0 ok, negative = closed
    uint64 pendingN;  // how many semaphore units the thread waits for (sem_wait_n)
    time_t sleepRelative; // ticks left until wake-up, RELATIVE to the
                          // predecessor in the sleep list (0 = same moment)

    friend class Scheduler;   // Scheduler may use next for its queue
    friend class SCB;         // semaphore blocks/links threads into its queue
};

#endif // _tcb_hpp_
