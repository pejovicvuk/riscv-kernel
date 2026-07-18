#include "../h/tcb.hpp"
#include "../h/memoryAllocator.hpp"

TCB* TCB::running = nullptr;

// new/delete za tcb: direktno na alokator jezgra (bez ecall-a)
void* TCB::operator new(size_t size) {
    return MemoryAllocator::alloc(size);
}
void TCB::operator delete(void* ptr) {
    MemoryAllocator::free(ptr);
}

TCB::TCB(Body body, void* arg, uint64* stack)
    : body(body), arg(arg), stack(stack),
      context({0, 0}),   // pravi pocetni kontekst pravimo u sledecoj lekciji
      finished(false), next(nullptr)
{}

TCB* TCB::createThread(Body body, void* arg) {
    // stek niti: DEFAULT_STACK_SIZE bajtova iz hw.h
    uint64* stack = (uint64*)MemoryAllocator::alloc(DEFAULT_STACK_SIZE);
    if (!stack) return nullptr;

    TCB* tcb = new TCB(body, arg, stack);
    if (!tcb) { MemoryAllocator::free(stack); return nullptr; }

    // todo (lekcija 2): postaviti context.ra i context.sp tako da prvo
    // "odmrzavanje" ubaci nit u njeno telo
    return tcb;
}
