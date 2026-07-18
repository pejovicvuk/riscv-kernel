#include "../h/syscall_c.hpp"
#include "../lib/hw.h"

void* mem_alloc(size_t size) {
    if (size == 0) return nullptr;

    // 1. zaokruži size (bajtovi) na broj BLOKOVA
    size_t numBlocks = (size + MEM_BLOCK_SIZE - 1) / MEM_BLOCK_SIZE;

    // 2. spakuj registre
    register uint64 code   asm("a0") = 0x01;
    register uint64 blocks asm("a1") = numBlocks;

    // 3. ecall
    asm volatile("ecall"
        : "=r"(code)
        : "r"(code), "r"(blocks)
        : "memory");

    // 4. vrati rezultat (bivši a0) kao void*
    return (void*)code;
}