#include "../h/memoryAllocator.hpp"
#include "../lib/hw.h"
#include "../h/print.hpp"

MemoryAllocator::FreeBlock* MemoryAllocator::freeListHead = nullptr;

// ceo heap = jedan slobodan blok
void MemoryAllocator::init() {
    freeListHead = (FreeBlock*)HEAP_START_ADDR;
    freeListHead->next = nullptr;
    freeListHead->size = (char*)HEAP_END_ADDR - (char*)HEAP_START_ADDR;
}

void* MemoryAllocator::alloc(size_t size){
    if (size == 0) {
        return nullptr;
    }
    // zaokruzivanje navise: ((n + B - 1) / B) * B; heder ukljucen u racun
    // da payload uvek bude >= size
    size_t n = size + sizeof(FreeBlock);
    size_t roundedSize = ((n + MEM_BLOCK_SIZE - 1) / MEM_BLOCK_SIZE) * MEM_BLOCK_SIZE;

    // first-fit kroz slobodnu listu
    FreeBlock* curr = freeListHead;
    FreeBlock* prev = nullptr;
    while(curr != nullptr){
        if(curr->size >= roundedSize){
            size_t remainder = curr->size - roundedSize;
            if (remainder >= MEM_BLOCK_SIZE) {
                // cepamo: uzimamo samo deo bloka, ostatak ostaje u listi
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
                // dajemo ceo blok - ostatak je premali za samostalan blok
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
    return nullptr;   // nema dovoljno velikog bloka
}

// debug ispis slobodne liste (nije deo resenja koje se predaje)
void MemoryAllocator::printFreeList() {
    FreeBlock* curr = freeListHead;
    kputs("free list:\n");
    while (curr != nullptr) {
        kputs("  blok na ");
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
    // heder zivi tacno ispred payload-a
    FreeBlock* block = (FreeBlock*)((char*)ptr - sizeof(FreeBlock));
    // nadji mesto po adresi (lista je sortirana da bi spajanje radilo)
    while(curr != nullptr && curr < block){
        prev = curr;
        curr = curr->next;
    }

    // da li se blok fizicki naslanja na suseda ispred/iza?
    bool mergePrev = (prev != nullptr) && ((char*)prev + prev->size == (char*)block);
    bool mergeNext = (curr != nullptr) && ((char*)block + block->size == (char*)curr);

    if (!mergePrev && !mergeNext) {
        // nema spajanja: samo umetni izmedju prev i curr
        block->next = curr;
        if (prev != nullptr) {
            prev->next = block;
        } else {
            freeListHead = block;
        }
    } else if (mergePrev && !mergeNext) {
        // spoji sa prethodnim
        prev->size += block->size;
    } else if (!mergePrev && mergeNext) {
        // spoji sa sledecim
        block->size += curr->size;
        block->next = curr->next;
        if (prev != nullptr) {
            prev->next = block;
        } else {
            freeListHead = block;
        }
    } else {
        // spoji sa oba suseda
        prev->size += block->size + curr->size;
        prev->next = curr->next;
    }
    return 0;
}
