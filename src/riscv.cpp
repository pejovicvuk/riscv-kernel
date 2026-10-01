#include "../inc/riscv.hpp"
#include "../lib/hw.h"
#include "../inc/print.hpp"
#include "../inc/memoryAllocator.hpp"
#include "../inc/tcb.hpp"
#include "../inc/scb.hpp"
#include "../inc/ccb.hpp"     // our console (part 4)

// common c part of the trap handler: reads scause and branches to the handling.
// parameters a0..a4 match registers a0..a4 at the moment of the trap
// (trap.S does not touch them before the call), so we read abi arguments directly.
extern "C" uint64 handleSupervisorTrap(uint64 a0, uint64 a1, uint64 a2, uint64 a3, uint64 a4) {
    uint64 cause   = Riscv::r_scause();
    uint64 sepc    = Riscv::r_sepc();
    uint64 sstatus = Riscv::r_sstatus();
    // sepc and sstatus are PART OF THE THREAD CONTEXT: handling may switch threads
    // (dispatch), and while this thread sleeps, the global csr registers get filled
    // by other traps. so we save them right away in locals (they live on this
    // thread's stack and park with it), and restore exactly our values before returning.

    uint64 topBit = cause >> 63;
    uint64 code   = cause & 0xff;
    uint64 ret    = a0;

    if (topBit == 1) {
        // asynchronous interrupt
        if (code == 1) {
            // software (timer), arrives 10x per second: acknowledge it,
            // then do both timing jobs (spec p. 28):
            // 1) wake sleeping threads whose time_sleep time has expired
            // 2) charge a tick to the running thread; slice expired ->
            //    ASYNCHRONOUS context switch: the thread loses the cpu without
            //    its knowledge or consent (time sharing)
            Riscv::mc_sip(Riscv::SIP_SSIP);
            TCB::wakeSleepers();
            if (TCB::tick()) {
                TCB::dispatch();
            }
        } else if (code == 9) {
            // external (console): our handling (part 4) - the interrupt
            // handler is the PRODUCER of the input buffer: plic_claim/complete
            // + move received chars from the controller into the buffer
            CCB::handleInterrupt();
        }
        // sepc is not incremented: the interrupted instruction must be re-executed
    }
    else if (topBit == 0 && (code == 8 || code == 9)) {
        // ecall (8 = from user mode, 9 = from supervisor mode)
        sepc += 4;   // skip the ecall itself - in the local copy!

        switch (a0) {
            case 0x01:   // mem_alloc(number of blocks)
                ret = (uint64)MemoryAllocator::alloc(a1 * MEM_BLOCK_SIZE);
                break;
            case 0x02:   // mem_free(pointer)
                ret = (uint64)MemoryAllocator::free((void*)a1);
                break;
            case 0x11: { // thread_create(handle, body, arg, stack)
                // threads created through a syscall are user threads: body in u-mode
                TCB* tcb = TCB::createThread((TCB::Body)a2, (void*)a3, (void*)a4, false);
                if (tcb) { *(TCB**)a1 = tcb; ret = 0; }
                else     { ret = (uint64)-1; }
                break;
            }
            case 0x12:   // thread_exit - no return from here for this thread
                TCB::running->setFinished(true);
                TCB::dispatch();
                break;
            case 0x13:   // thread_dispatch - the thread voluntarily yields the cpu
                TCB::dispatch();
                ret = 0;
                break;
            case 0x21: { // sem_open(handle, init)
                SCB* sem = SCB::createSemaphore((unsigned)a2);
                if (sem) { *(SCB**)a1 = sem; ret = 0; }
                else     { ret = (uint64)-1; }
                break;
            }
            case 0x22: { // sem_close - unblocks all waiters (with an error), then is deleted
                SCB* sem = (SCB*)a1;
                if (!sem) { ret = (uint64)-1; break; }
                ret = (uint64)sem->close();
                delete sem;
                break;
            }
            case 0x23:   // sem_wait = wait(1); may block the thread right here
                ret = a1 ? (uint64)((SCB*)a1)->wait(1) : (uint64)-1;
                break;
            case 0x24:   // sem_signal = signal(1)
                ret = a1 ? (uint64)((SCB*)a1)->signal(1) : (uint64)-1;
                break;
            case 0x25:   // sem_wait_n(id, n)
                ret = a1 ? (uint64)((SCB*)a1)->wait((unsigned)a2) : (uint64)-1;
                break;
            case 0x26:   // sem_signal_n(id, n)
                ret = a1 ? (uint64)((SCB*)a1)->signal((unsigned)a2) : (uint64)-1;
                break;
            case 0x31:   // time_sleep(number of timer ticks)
                ret = (uint64)TCB::putToSleep((time_t)a1);
                break;
            case 0x41:   // getc - from our input buffer (part 4)
                // empty buffer -> the thread BLOCKS right here (like sem_wait);
                // the console interrupt wakes it when a char arrives. our
                // sepc/sstatus wait safely in locals on its stack
                ret = (uint64)CCB::getc();
                break;
            case 0x42:   // putc - into our output buffer (part 4)
                // full buffer -> the caller blocks until the kernel
                // output thread frees a slot
                CCB::putc((char)a1);
                ret = 0;
                break;
            default:
                ret = (uint64)-1;   // unknown system call code
        }
    }
    else {
        // unknown cause (an exception we cannot handle): panic.
        // we do not return - sepc would point to the same instruction and we would loop forever.

        kputs("emulator crashed\n");
        *(volatile int*)0x100000 = 0x5555;   // halt the emulator
    }

    // everyone returns with THEIR OWN values, no matter how long they slept
    Riscv::w_sstatus(sstatus);
    Riscv::w_sepc(sepc);
    return ret;
}
