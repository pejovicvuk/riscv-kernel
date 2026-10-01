#include "../inc/print.hpp"
#include "../inc/memoryAllocator.hpp"
#include "../inc/tcb.hpp"
#include "../inc/riscv.hpp"
#include "../inc/ccb.hpp"
#include "../inc/syscall_c.h"

void userMain();   // defined in the test file

// wrapper: userMain as a thread body + a done flag.
// the end must NOT be awaited through the thread handle (zombie cleanup eats
// the tcb of a finished thread), so the thread reports it is done before thread_exit
static volatile bool userMainDone = false;

static void userMainWrapper(void*) {
    userMain();
    userMainDone = true;
}

int main() {
    kputs(">> kernel: starting\n");

    // stvec = trap handler address: the only gate for ecall/exceptions/interrupts
    Riscv::w_stvec((uint64)&trap);

    MemoryAllocator::init();

    // main becomes the "zero" thread: it gets its own tcb so it has somewhere to
    // freeze when it first yields the cpu (its context is filled on the first dispatch)
    TCB::running = TCB::createThread(nullptr, nullptr, nullptr, true);   // the zero thread is a system thread

    // console (part 4): buffers, semaphores and the kernel output thread - before
    // enabling interrupts, so the first console interrupt finds the buffers ready
    CCB::init();

    // interrupts are enabled only NOW, when the zero thread exists: a timer tick
    // charges the time slice to the running thread (TCB::tick reads running), so
    // running must be alive before the first interrupt.
    // sie by type: console (seie) is a MUST - our CCB::handleInterrupt fills the
    // input buffer from the controller on its interrupt; timer (ssie) - drives
    // time sharing (preemption) and waking sleepers (time_sleep).
    Riscv::ms_sie(Riscv::SIE_SSIE | Riscv::SIE_SEIE);

    // enable interrupts in supervisor mode too (sstatus.SIE): main runs in
    // s-mode, and interrupts must arrive while it is on the cpu as well.
    // u-mode threads ignore this bit - for them sie applies directly
    Riscv::ms_sstatus(Riscv::SSTATUS_SIE);

    // spec p. 4: main "starts a thread over the userMain function" - via plain
    // thread_create (ecall works from supervisor mode too), then yields
    // the cpu until the user program finishes
    thread_t userThread;
    if (thread_create(&userThread, userMainWrapper, nullptr) != 0) {
        kputs(">> kernel: failed to create userMain thread\n");
    } else {
        while (!userMainDone) thread_dispatch();
    }

    // before shutdown: let the output thread send everything in the output buffer -
    // otherwise the last test messages would vanish together with the emulator
    while (!CCB::outputEmpty()) thread_dispatch();

    kputs(">> kernel: userMain finished, halting\n");

    // writing 0x5555 to 0x100000 shuts down the emulator (normal exit)
    *(volatile int*)0x100000 = 0x5555;

    return 0;
}
