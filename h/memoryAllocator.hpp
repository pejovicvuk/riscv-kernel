#ifndef MEMORYALLOCATOR_HPP
#define MEMORYALLOCATOR_HPP

#include "../lib/hw.h"

class MemoryAllocator {
private:
    struct FreeBlock {
    FreeBlock* next;
    size_t size;   // size of this block, in bytes
    };
    static FreeBlock* freeListHead;   // head of the free list
    MemoryAllocator() = delete;
public:
    static void init();
    static void* alloc(size_t size);
    static int free(void* ptr);
};

#endif // MEMORYALLOCATOR_HPP