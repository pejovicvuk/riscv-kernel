#ifndef _riscv_hpp_
#define _riscv_hpp_

#include "../lib/hw.h"

// access to system (csr) registers in one place:
// r_ = read, w_ = write, ms_ = mask set (csrs), mc_ = mask clear (csrc)
class Riscv {
public:
    enum BitMaskSstatus {
        SSTATUS_SIE  = (1 << 1),   // global interrupt enable in s-mode
        SSTATUS_SPIE = (1 << 5),   // SIE saved before the trap
        SSTATUS_SPP  = (1 << 8),   // mode the trap came from (0=u, 1=s)
    };

    enum BitMaskSip {
        SIP_SSIP = (1 << 1),       // software interrupt pending (timer)
        SIP_SEIP = (1 << 9),       // external interrupt pending (console)
    };

    enum BitMaskSie {
        SIE_SSIE = (1 << 1),       // software interrupt enable (timer)
        SIE_STIE = (1 << 5),       // timer interrupt enable (unused - the timer arrives as a software interrupt)
        SIE_SEIE = (1 << 9),       // external interrupt enable (console)
    };

    static uint64 r_scause();
    static uint64 r_sepc();
    static void   w_sepc(uint64 sepc);
    static uint64 r_sstatus();
    static void   w_sstatus(uint64 sstatus);
    static void   ms_sstatus(uint64 mask);
    static void   mc_sstatus(uint64 mask);
    static uint64 r_sip();
    static void   mc_sip(uint64 mask);
    static uint64 r_sie();
    static void   ms_sie(uint64 mask);
    static void   w_stvec(uint64 stvec);
};

inline uint64 Riscv::r_scause() {
    uint64 scause;
    asm volatile("csrr %0, scause" : "=r"(scause));
    return scause;
}

inline uint64 Riscv::r_sepc() {
    uint64 sepc;
    asm volatile("csrr %0, sepc" : "=r"(sepc));
    return sepc;
}

inline void Riscv::w_sepc(uint64 sepc) {
    asm volatile("csrw sepc, %0" : : "r"(sepc));
}

inline uint64 Riscv::r_sstatus() {
    uint64 sstatus;
    asm volatile("csrr %0, sstatus" : "=r"(sstatus));
    return sstatus;
}

inline void Riscv::w_sstatus(uint64 sstatus) {
    asm volatile("csrw sstatus, %0" : : "r"(sstatus));
}

inline void Riscv::ms_sstatus(uint64 mask) {
    asm volatile("csrs sstatus, %0" : : "r"(mask));
}

inline void Riscv::mc_sstatus(uint64 mask) {
    asm volatile("csrc sstatus, %0" : : "r"(mask));
}

inline uint64 Riscv::r_sip() {
    uint64 sip;
    asm volatile("csrr %0, sip" : "=r"(sip));
    return sip;
}

inline void Riscv::mc_sip(uint64 mask) {
    asm volatile("csrc sip, %0" : : "r"(mask));
}

inline uint64 Riscv::r_sie() {
    uint64 sie;
    asm volatile("csrr %0, sie" : "=r"(sie));
    return sie;
}

inline void Riscv::ms_sie(uint64 mask) {
    asm volatile("csrs sie, %0" : : "r"(mask));
}

inline void Riscv::w_stvec(uint64 stvec) {
    asm volatile("csrw stvec, %0" : : "r"(stvec));
}

// trap handler entry point (trap.S) - goes into stvec
extern "C" void trap();

// c part of the trap handler: reads scause and branches to the handling.
// a0..a4 match the registers at the moment of the trap (trap.S does not
// touch them before the call); the return value goes back to the user in a0
extern "C" uint64 handleSupervisorTrap(uint64 a0, uint64 a1, uint64 a2, uint64 a3, uint64 a4);

#endif // _riscv_hpp_
