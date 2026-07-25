#include "../inc/syscall_c.h"
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

int mem_free(void* ptr) {
    // abi poziv 0x02: a1 = pokazivac dobijen iz mem_alloc
    register uint64 code asm("a0") = 0x02;
    register uint64 p    asm("a1") = (uint64)ptr;
    asm volatile("ecall"
        : "=r"(code)
        : "r"(code), "r"(p)
        : "memory");

    return (int)code;   // 0 = uspeh, negativno = greska
}

int thread_create(thread_t* handle, void (*start_routine)(void*), void* arg) {
    if (!handle || !start_routine) return -1;

    // pdf, abi poziv 0x11: stek niti alocira OVAJ sloj (kroz mem_alloc,
    // dakle jos jedan ecall), pa ga prosledjuje jezgru kao 4. argument
    void* stackSpace = mem_alloc(DEFAULT_STACK_SIZE);
    if (!stackSpace) return -2;

    register uint64 code asm("a0") = 0x11;
    register uint64 h    asm("a1") = (uint64)handle;
    register uint64 rt   asm("a2") = (uint64)start_routine;
    register uint64 ag   asm("a3") = (uint64)arg;
    register uint64 st   asm("a4") = (uint64)stackSpace;
    asm volatile("ecall"
        : "=r"(code)
        : "r"(code), "r"(h), "r"(rt), "r"(ag), "r"(st)
        : "memory");

    int result = (int)code;
    if (result != 0) mem_free(stackSpace);   // nit nije nastala - vrati stek
    return result;
}

int thread_exit() {
    register uint64 code asm("a0") = 0x12;
    asm volatile("ecall" : "=r"(code) : "r"(code) : "memory");
    return (int)code;   // dovde stize samo u slucaju neuspeha
}

void thread_dispatch() {
    register uint64 code asm("a0") = 0x13;
    asm volatile("ecall" : "=r"(code) : "r"(code) : "memory");
}

int sem_open(sem_t* handle, unsigned init) {
    if (!handle) return -1;
    register uint64 code asm("a0") = 0x21;
    register uint64 h    asm("a1") = (uint64)handle;
    register uint64 in   asm("a2") = (uint64)init;
    asm volatile("ecall" : "=r"(code) : "r"(code), "r"(h), "r"(in) : "memory");
    return (int)code;
}

int sem_close(sem_t handle) {
    register uint64 code asm("a0") = 0x22;
    register uint64 h    asm("a1") = (uint64)handle;
    asm volatile("ecall" : "=r"(code) : "r"(code), "r"(h) : "memory");
    return (int)code;
}

int sem_wait(sem_t id) {
    register uint64 code asm("a0") = 0x23;
    register uint64 h    asm("a1") = (uint64)id;
    asm volatile("ecall" : "=r"(code) : "r"(code), "r"(h) : "memory");
    return (int)code;
}

int sem_signal(sem_t id) {
    register uint64 code asm("a0") = 0x24;
    register uint64 h    asm("a1") = (uint64)id;
    asm volatile("ecall" : "=r"(code) : "r"(code), "r"(h) : "memory");
    return (int)code;
}

int sem_wait_n(sem_t id, unsigned n) {
    register uint64 code asm("a0") = 0x25;
    register uint64 h    asm("a1") = (uint64)id;
    register uint64 num  asm("a2") = (uint64)n;
    asm volatile("ecall" : "=r"(code) : "r"(code), "r"(h), "r"(num) : "memory");
    return (int)code;
}

int sem_signal_n(sem_t id, unsigned n) {
    register uint64 code asm("a0") = 0x26;
    register uint64 h    asm("a1") = (uint64)id;
    register uint64 num  asm("a2") = (uint64)n;
    asm volatile("ecall" : "=r"(code) : "r"(code), "r"(h), "r"(num) : "memory");
    return (int)code;
}

char getc() {
    register uint64 code asm("a0") = 0x41;
    asm volatile("ecall" : "=r"(code) : "r"(code) : "memory");
    return (char)code;
}

void putc(char c) {
    register uint64 code asm("a0") = 0x42;
    register uint64 ch   asm("a1") = (uint64)c;
    asm volatile("ecall" : "=r"(code) : "r"(code), "r"(ch) : "memory");
}
