#include "../h/MemoryAllocator.hpp"
#include "../lib/hw.h"
#include "../h/print.hpp"
MemoryAllocator::FreeBlock* MemoryAllocator::freeListHead = nullptr;

void MemoryAllocator::init() {
    freeListHead = (FreeBlock*)HEAP_START_ADDR;
    freeListHead->next = nullptr;
    freeListHead->size = (char*)HEAP_END_ADDR - (char*)HEAP_START_ADDR;
}
void* MemoryAllocator::alloc(size_t size){
    if (size == 0) {
        return nullptr;
    }
    //rounding ((n + B - 1) / B) * B
    size_t n = size + sizeof(FreeBlock);
    size_t roundedSize = ((n + MEM_BLOCK_SIZE - 1) / MEM_BLOCK_SIZE) * MEM_BLOCK_SIZE; //velicina koju treba alocirati

    FreeBlock* curr = freeListHead;
    FreeBlock* prev = nullptr;
    while(curr != nullptr){
        if(curr->size >= roundedSize){
            size_t remainder = curr->size - roundedSize;
            if (remainder >= MEM_BLOCK_SIZE) {
                //cepamo, uzimamo samo deo bloka, ostatak ostaje u free listi
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
                // dajemo ceo blok — ostatak je premali
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
    return nullptr;
}
void MemoryAllocator::printFreeList() {
    FreeBlock* curr = freeListHead;
    kputs("Free list:\n");
    while (curr != nullptr) {
        kputs("  Block at ");
        kputhex((uint64)curr);
        kputs(", size: ");
        kputhex(curr->size);
        kputs("\n");
        curr = curr->next;
    }
}