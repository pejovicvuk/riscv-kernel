// src/userMain.cpp
#include "../h/MemoryAllocator.hpp"
extern void kputs(const char* s);   // defined in main.cpp; same build, so this links

void userMain() {
    MemoryAllocator::init();
    kputs("   user: hello from userMain\n");
}