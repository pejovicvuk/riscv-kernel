#include "../lib/hw.h"
#include "../h/print.hpp"
#include "../h/MemoryAllocator.hpp"

extern "C" uint64 handleTrap(uint64 a0, uint64 a1, uint64 a2, uint64 a3) {
    kputs("   [trap] usao\n");
    uint64 cause;
    asm volatile("csrr %0, scause" : "=r" (cause));
    kputs("   [trap] cause = "); kputhex(cause); kputs("\n");

    if (cause == 8 || cause == 9) {   // ecall
        switch (a0) {
            case 0x01:
                return (uint64) MemoryAllocator::alloc((size_t)a1);   // a1 = size
            case 0x02:
                return (uint64) MemoryAllocator::free((void*)a1);    // a1 = pointer
        }
    }
    return 0;
}