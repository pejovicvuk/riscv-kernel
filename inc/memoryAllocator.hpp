#ifndef _memory_allocator_hpp_
#define _memory_allocator_hpp_

#include "../lib/hw.h"

// kernel memory allocator: intrusive free list (header lives in the first
// 16B of every block), first-fit, all allocations a multiple of MEM_BLOCK_SIZE
class MemoryAllocator {
private:
    struct FreeBlock {
        FreeBlock* next;
        size_t size;   // size of this block in bytes (header included)
    };
    static FreeBlock* freeListHead;   // head of the free list
    MemoryAllocator() = delete;       // all-static class, never instantiated
public:
    static void init();
    static void* alloc(size_t size);
    static int free(void* ptr);
    static void printFreeList();      // debug tool
};

#endif // _memory_allocator_hpp_
