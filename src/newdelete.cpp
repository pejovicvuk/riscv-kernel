// globalni operatori new/delete za KORISNICKI kod (pdf, str. 11):
// omotavaju sistemske pozive mem_alloc/mem_free, pa svako "new" iz
// korisnickog programa zavrsi u alokatoru jezgra kroz ecall.
//
// paznja: jezgro NE SME da koristi ove operatore (ecall iz jezgra bi
// pregazio sepc tekuceg trapa) - zato klase jezgra (TCB, SCB) imaju
// svoje operator new/delete koji idu direktno na MemoryAllocator.
#include "../h/syscall_c.h"

void* operator new(size_t size) {
    return mem_alloc(size);
}

void* operator new[](size_t size) {
    return mem_alloc(size);
}

void operator delete(void* ptr) noexcept {
    mem_free(ptr);
}

void operator delete[](void* ptr) noexcept {
    mem_free(ptr);
}
