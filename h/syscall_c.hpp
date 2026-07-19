#ifndef _syscall_c_hpp_
#define _syscall_c_hpp_

#include "../lib/hw.h"

// c api jezgra (potpisi iz postavke projekta)

void* mem_alloc(size_t size);
int mem_free(void*);

// "rucka" niti: neproziran pokazivac - korisnik ne zna (i ne treba da zna)
// sta je unutra; jezgro iza njega krije svoj TCB
class _thread;
typedef _thread* thread_t;

int  thread_create(thread_t* handle, void (*start_routine)(void*), void* arg);
int  thread_exit();
void thread_dispatch();

#endif // _syscall_c_hpp_
