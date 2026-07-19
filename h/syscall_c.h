#ifndef _syscall_c_h_
#define _syscall_c_h_

#include "../lib/hw.h"

// c api jezgra (potpisi iz postavke projekta).
// ime fajla je syscall_c.h (ne .hpp) jer ga zvanicni testovi tako include-uju.

void* mem_alloc(size_t size);
int mem_free(void*);

// "rucka" niti: neproziran pokazivac - korisnik ne zna (i ne treba da zna)
// sta je unutra; jezgro iza njega krije svoj TCB
class _thread;
typedef _thread* thread_t;

int  thread_create(thread_t* handle, void (*start_routine)(void*), void* arg);
int  thread_exit();
void thread_dispatch();

// konzola
const int EOF = -1;
char getc();
void putc(char);

#endif // _syscall_c_h_
