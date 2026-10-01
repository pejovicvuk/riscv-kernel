#include "../inc/memoryAllocator.hpp"
#include "../inc/print.hpp"
#include "../lib/hw.h"

MemoryAllocator::FreeBlock* MemoryAllocator::freeListHead = nullptr;

// whole heap = one free block
void MemoryAllocator::init() {
    freeListHead = (FreeBlock*)HEAP_START_ADDR;
    freeListHead->next = nullptr;
    freeListHead->size = (char*)HEAP_END_ADDR - (char*)HEAP_START_ADDR;
}

void* MemoryAllocator::alloc(size_t size){
    if (size == 0) {
        return nullptr;
    }
    // round up: ((n + B - 1) / B) * B; header included in the calculation
    // so the payload is always >= size
    size_t n = size + sizeof(FreeBlock);
    size_t roundedSize = ((n + MEM_BLOCK_SIZE - 1) / MEM_BLOCK_SIZE) * MEM_BLOCK_SIZE;

    // first-fit through the free list
    FreeBlock* curr = freeListHead;
    FreeBlock* prev = nullptr;
    while(curr != nullptr){
        if(curr->size >= roundedSize){
            size_t remainder = curr->size - roundedSize;
            if (remainder >= MEM_BLOCK_SIZE) {
                // split: take only part of the block, the rest stays in the list
                FreeBlock* newBlock = (FreeBlock*)((char*)curr + roundedSize);
                newBlock->size = remainder;
                newBlock->next = curr->next;
                if (prev != nullptr) {
                    prev->next = newBlock;
                } else {
                    freeListHead = newBlock;
                }
                curr->size = roundedSize;
            }
            else{
                // give the whole block - the remainder is too small to be a block
                if (prev != nullptr) {
                    prev->next = curr->next;
                } else {
                    freeListHead = curr->next;
                }
            }
            return (char*)curr + sizeof(FreeBlock);
        }
        prev = curr;
        curr = curr->next;
    }
    return nullptr;   // no block large enough
}

// debug print of the free list (not part of the submitted solution)
void MemoryAllocator::printFreeList() {
    FreeBlock* curr = freeListHead;
    kputs("free list:\n");
    while (curr != nullptr) {
        kputs("  block at ");
        kputhex((uint64)curr);
        kputs(", size: ");
        kputhex(curr->size);
        kputs("\n");
        curr = curr->next;
    }
}

int MemoryAllocator::free(void* ptr){
    if (ptr == nullptr) return -1;
    FreeBlock* curr = freeListHead;
    FreeBlock* prev = nullptr;
    // header lives right before the payload
    FreeBlock* block = (FreeBlock*)((char*)ptr - sizeof(FreeBlock));
    // find the spot by address (list is sorted so merging works)
    while(curr != nullptr && curr < block){
        prev = curr;
        curr = curr->next;
    }

    // is the block physically adjacent to the neighbor before/after?
    bool mergePrev = (prev != nullptr) && ((char*)prev + prev->size == (char*)block);
    bool mergeNext = (curr != nullptr) && ((char*)block + block->size == (char*)curr);

    if (!mergePrev && !mergeNext) {
        // no merging: just insert between prev and curr
        block->next = curr;
        if (prev != nullptr) {
            prev->next = block;
        } else {
            freeListHead = block;
        }
    } else if (mergePrev && !mergeNext) {
        // merge with the previous one
        prev->size += block->size;
    } else if (!mergePrev && mergeNext) {
        // merge with the next one
        block->size += curr->size;
        block->next = curr->next;
        if (prev != nullptr) {
            prev->next = block;
        } else {
            freeListHead = block;
        }
    } else {
        // merge with both neighbors
        prev->size += block->size + curr->size;
        prev->next = curr->next;
    }
    return 0;
}
