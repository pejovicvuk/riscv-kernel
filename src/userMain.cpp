// privremeni test program; kad se uveze pravi app.lib sa testovima,
// ovaj fajl se uklanja (duplikat simbola userMain)
#include "../h/syscall_c.hpp"
#include "../h/print.hpp"
#include "../h/memoryAllocator.hpp"

void userMain() {
    // tri alokacije razlicitih velicina kroz ecall
    void* p1 = mem_alloc(100);   // 100+16=116 -> 128B (2 bloka)
    void* p2 = mem_alloc(200);   // 200+16=216 -> 256B (4 bloka)
    void* p3 = mem_alloc(50);    // 50+16=66   -> 128B (2 bloka)
    kputs("p1 = "); kputhex((uint64)p1); kputs("\n");
    kputs("p2 = "); kputhex((uint64)p2); kputs("\n");
    kputs("p3 = "); kputhex((uint64)p3); kputs("\n");
    MemoryAllocator::printFreeList();   // ocekujemo: jedan veliki ostatak heapa

    // oslobodi SREDNJI pa PRVI: rupa p2 i rupa p1 moraju da se spoje u jednu
    int r2 = mem_free(p2);
    int r1 = mem_free(p1);
    kputs("free(p2) = "); kputhex((uint64)r2); kputs("\n");
    kputs("free(p1) = "); kputhex((uint64)r1); kputs("\n");
    MemoryAllocator::printFreeList();   // ocekujemo: [rupa p1+p2: 384B] + [veliki ostatak]

    // oslobodi i p3: sve mora da se stopi nazad u JEDAN blok
    int r3 = mem_free(p3);
    kputs("free(p3) = "); kputhex((uint64)r3); kputs("\n");
    MemoryAllocator::printFreeList();   // ocekujemo: jedan jedini blok = ceo heap
}
