#ifndef _memory_allocator_hpp_
#define _memory_allocator_hpp_

#include "../lib/hw.h"

// alokator memorije jezgra: intruzivna slobodna lista (heder zivi u prvih
// 16B svakog bloka), first-fit, sve alokacije umnozak MEM_BLOCK_SIZE
class MemoryAllocator {
private:
    struct FreeBlock {
        FreeBlock* next;
        size_t size;   // velicina ovog bloka u bajtovima (ukljucuje heder)
    };
    static FreeBlock* freeListHead;   // celo slobodne liste
    MemoryAllocator() = delete;       // all-static klasa, ne instancira se
public:
    static void init();
    static void* alloc(size_t size);
    static int free(void* ptr);
    static void printFreeList();      // debug alat
};

#endif // _memory_allocator_hpp_
