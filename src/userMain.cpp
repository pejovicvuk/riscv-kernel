// src/userMain.cpp
#include "../h/MemoryAllocator.hpp"
#include "../h/print.hpp"

void userMain() {
    MemoryAllocator::init();
    kputs("   user: hello from userMain\n");

    MemoryAllocator::printFreeList();

    void* p1 = MemoryAllocator::alloc(100);
    kputs("   p1 = "); kputhex((uint64)p1); kputs("\n");
    MemoryAllocator::printFreeList();

    void* p2 = MemoryAllocator::alloc(50);
    kputs("   p2 = "); kputhex((uint64)p2); kputs("\n");
    MemoryAllocator::printFreeList();



}