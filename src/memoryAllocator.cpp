#include "../h/MemoryAllocator.hpp"
#include "../lib/hw.h"

MemoryAllocator::FreeBlock* MemoryAllocator::freeListHead = nullptr;

void MemoryAllocator::init() {
    freeListHead = (FreeBlock*)HEAP_START_ADDR;
    freeListHead->next = nullptr;
    freeListHead->size = (char*)HEAP_END_ADDR - (char*)HEAP_START_ADDR;
}