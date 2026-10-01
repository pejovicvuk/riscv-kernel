#include "../inc/ccb.hpp"
#include "../inc/scb.hpp"
#include "../inc/tcb.hpp"
#include "../inc/memoryAllocator.hpp"
#include "../lib/hw.h"

const int CCB::BUFFER_SIZE;

char CCB::inputBuffer[CCB::BUFFER_SIZE];
int  CCB::inputHead = 0;
int  CCB::inputTail = 0;
SCB* CCB::inputItems = nullptr;

char CCB::outputBuffer[CCB::BUFFER_SIZE];
int  CCB::outputHead = 0;
int  CCB::outputTail = 0;
SCB* CCB::outputItems = nullptr;
SCB* CCB::outputSpace = nullptr;

// semaphores are created directly through SCB (the kernel does not ecall itself!),
// and the output thread stack comes directly from the allocator - same reason
void CCB::init() {
    inputItems  = SCB::createSemaphore(0);
    outputItems = SCB::createSemaphore(0);
    outputSpace = SCB::createSemaphore(BUFFER_SIZE);

    // kernel output thread: endless consumer of the output buffer. it is a
    // system thread (spec p. 27: internal thread bodies run in supervisor mode,
    // so they may access controller registers)
    TCB::createThread(&outputBody, nullptr,
                      MemoryAllocator::alloc(DEFAULT_STACK_SIZE), true);
}

// console interrupt: the controller reports "i have a char from the keyboard"
// and/or "i am ready to send". here we do ONLY input (the interrupt handler is
// the producer, spec p. 27); output is not touched - the output thread sends it
// by polling, so it needs no interrupt.
// plic_claim tells which device interrupted, plic_complete acknowledges it
void CCB::handleInterrupt() {
    int irq = plic_claim();
    if (irq == CONSOLE_IRQ) {
        // collect chars while there are any (several may arrive in one interrupt)
        while (*(volatile char*)CONSOLE_STATUS & CONSOLE_RX_STATUS_BIT) {
            char c = *(volatile char*)CONSOLE_RX_DATA;   // always take it from the controller
            int nextTail = (inputTail + 1) % BUFFER_SIZE;
            if (nextTail == inputHead) continue;   // full buffer: char is dropped (spec p. 27)
            inputBuffer[inputTail] = c;
            inputTail = nextTail;
            inputItems->signal(1);
        }
    }
    if (irq) plic_complete(irq);
}

// syscall 0x41: take a char from the input buffer; empty buffer -> the calling
// thread blocks on the semaphore (sleeps as in sem_wait), and the interrupt
// handler wakes it with a signal when a char arrives from the keyboard
char CCB::getc() {
    if (inputItems->wait(1) < 0) return -1;   // (unreachable: this semaphore is never closed)
    char c = inputBuffer[inputHead];
    inputHead = (inputHead + 1) % BUFFER_SIZE;
    return c;
}

// syscall 0x42: put a char into the output buffer; full buffer -> the caller
// blocks until the output thread frees a slot (spec p. 27 allows blocking
// or an error - we block, it is natural with a free-slots semaphore)
void CCB::putc(char c) {
    outputSpace->wait(1);
    outputBuffer[outputTail] = c;
    outputTail = (outputTail + 1) % BUFFER_SIZE;
    outputItems->signal(1);
}

bool CCB::outputEmpty() {
    return outputHead == outputTail;
}

// endless consumer: waits for a char (blocks on an empty buffer - the only
// time it yields the cpu), then waits for the controller by POLLING and sends.
// the body runs in s-mode with interrupts masked (a system thread is not dropped
// via sret), so buffer accesses are naturally atomic w.r.t. putc from a trap
void CCB::outputBody(void*) {
    for (;;) {
        outputItems->wait(1);
        char c = outputBuffer[outputHead];
        outputHead = (outputHead + 1) % BUFFER_SIZE;
        while (!(*(volatile char*)CONSOLE_STATUS & CONSOLE_TX_STATUS_BIT)) {
            // bit 5 == 0: controller is still sending the previous char
        }
        *(volatile char*)CONSOLE_TX_DATA = c;
        outputSpace->signal(1);
    }
}
