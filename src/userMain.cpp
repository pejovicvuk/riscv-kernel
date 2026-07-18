// src/userMain.cpp
#include "../h/syscall_c.hpp"
#include "../h/print.hpp"

void userMain() {
    kputs("   pre mem_alloc\n");
    void* p = mem_alloc(100);
    kputs("   posle mem_alloc\n");
    kputs("   p (preko ecall) = "); kputhex((uint64)p); kputs("\n");
}