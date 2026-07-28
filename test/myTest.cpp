// test za joinAll: stablo A(my_test) -> B -> C.
// pravilo (nasa pretpostavka): nit sa potomcima zove join_all pre kraja.
#include "../inc/syscall_cpp.hpp"
#include "../inc/syscall_c.h"
#include "printing.hpp"

// unuk: samo radi svoj posao
static void cTelo(void* arg){
    printString("C: pocinjem\n");
    for (volatile int i = 0; i < 1000000; i++);
    printString("C: zavrsio\n");
}

// dete: napravi unuka, pa po pravilu saceka SVOJE potomke
static void bTelo(void* arg){
    printString("B: pravim C\n");
    thread_t c;
    thread_create(&c, cTelo, nullptr);

    join_all();
    printString("B: svi moji potomci gotovi\n");
}

void my_test() {
    printString("test: pravim B\n");
    thread_t b;
    thread_create(&b, bTelo, nullptr);

    join_all();
    printString("test: SVI gotovi\n");
}
