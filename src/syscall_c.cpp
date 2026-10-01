#include "../inc/syscall_c.h"
#include "../lib/hw.h"

void* mem_alloc(size_t size) {
    if (size == 0) return nullptr;

    // abi call 0x01 takes the size in blocks: round bytes up
    size_t numBlocks = (size + MEM_BLOCK_SIZE - 1) / MEM_BLOCK_SIZE;

    // load the registers then ecall; the return value comes back in a0
    register uint64 code   asm("a0") = 0x01;
    register uint64 blocks asm("a1") = numBlocks;
    asm volatile("ecall"
        : "=r"(code)
        : "r"(code), "r"(blocks)
        : "memory");

    return (void*)code;
}

int mem_free(void* ptr) {
    // abi call 0x02: a1 = pointer obtained from mem_alloc
    register uint64 code asm("a0") = 0x02;
    register uint64 p    asm("a1") = (uint64)ptr;
    asm volatile("ecall"
        : "=r"(code)
        : "r"(code), "r"(p)
        : "memory");

    return (int)code;   // 0 = success, negative = error
}

int thread_create(thread_t* handle, void (*start_routine)(void*), void* arg) {
    if (!handle || !start_routine) return -1;

    // spec, abi call 0x11: the thread stack is allocated by THIS layer (via mem_alloc,
    // i.e. one more ecall), then passed to the kernel as the 4th argument
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
    if (result != 0) mem_free(stackSpace);   // thread was not created - give the stack back
    return result;
}

int thread_exit() {
    register uint64 code asm("a0") = 0x12;
    asm volatile("ecall" : "=r"(code) : "r"(code) : "memory");
    return (int)code;   // reached only on failure
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

int time_sleep(time_t period) {
    register uint64 code asm("a0") = 0x31;
    register uint64 t    asm("a1") = (uint64)period;
    asm volatile("ecall" : "=r"(code) : "r"(code), "r"(t) : "memory");
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
