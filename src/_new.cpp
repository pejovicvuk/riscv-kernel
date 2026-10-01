// global operators new/delete for USER code (spec, p. 11):
// they wrap the mem_alloc/mem_free system calls, so every "new" in a
// user program ends up in the kernel allocator through ecall.
//
// careful: the kernel MUST NOT use these operators (an ecall from the kernel
// would overwrite sepc of the current trap) - that is why kernel classes
// (TCB, SCB) have their own operator new/delete that go straight to MemoryAllocator.
#include "../inc/syscall_c.h"

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
