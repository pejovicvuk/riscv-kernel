#ifndef _ccb_hpp_
#define _ccb_hpp_

class SCB;

// ccb (console control block) = our own console (part 4), replaces the
// provided console.lib. two ring buffers + semaphores for blocking (spec p. 27):
// - input: the INTERRUPT HANDLER is the producer (moves chars from the
//   controller into the input buffer), getc syscall is the consumer (empty -> block)
// - output: putc syscall is the producer (full buffer -> block), and an INTERNAL
//   KERNEL THREAD is the consumer (sends to the controller by polling)
class CCB {
public:
    // create the semaphores and start the kernel output thread;
    // call in main BEFORE enabling interrupts
    static void init();

    // console interrupt handling (scause top=1, code=9): plic_claim/complete
    // + move all received chars controller -> input buffer
    static void handleInterrupt();

    // for syscalls 0x41/0x42: they run in the context of the calling thread,
    // so they may block it - same mechanism as sem_wait
    static char getc();
    static void putc(char c);

    // is the output buffer empty - before shutdown main waits for the output
    // thread to send the last char (otherwise the end of test output is lost)
    static bool outputEmpty();

private:
    CCB() = delete;   // all-static class, like Scheduler and MemoryAllocator

    static const int BUFFER_SIZE = 512;

    // ring buffers: read from head, write at tail;
    // (tail+1)%N == head means "full" - one slot is sacrificed to tell
    // full from empty, so no separate counter is needed
    static char inputBuffer[BUFFER_SIZE];
    static int inputHead, inputTail;
    static SCB* inputItems;    // number of chars waiting in the input buffer

    static char outputBuffer[BUFFER_SIZE];
    static int outputHead, outputTail;
    static SCB* outputItems;   // number of chars waiting to be sent
    static SCB* outputSpace;   // number of free slots in the output buffer

    // body of the output thread (systemLevel=true: stays in s-mode because it
    // writes directly to the console controller registers)
    static void outputBody(void*);
};

#endif // _ccb_hpp_
