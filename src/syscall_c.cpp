#include "../h/syscall_c.hpp"
#include "../lib/hw.h"

void* mem_alloc(size_t size) {
    if (size == 0) return nullptr;

    // abi poziv 0x01 prima velicinu u blokovima: zaokruzi bajtove navise
    size_t numBlocks = (size + MEM_BLOCK_SIZE - 1) / MEM_BLOCK_SIZE;

    // spakuj registre pa ecall; povratna vrednost stize nazad u a0
    register uint64 code   asm("a0") = 0x01;
    register uint64 blocks asm("a1") = numBlocks;
    asm volatile("ecall"
        : "=r"(code)
        : "r"(code), "r"(blocks)
        : "memory");

    return (void*)code;
}
