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
void thread_join_all();
void thread_add_child(thread_t handle);

// semafori - "rucka" po istom obrascu kao thread_t (iza nje je SCB jezgra)
class _sem;
typedef _sem* sem_t;

int sem_open(sem_t* handle, unsigned init);
int sem_close(sem_t handle);
int sem_wait(sem_t id);
int sem_signal(sem_t id);
int sem_wait_n(sem_t id, unsigned n);
int sem_signal_n(sem_t id, unsigned n);

// konzola
const int EOF = -1;
char getc();
void putc(char);

#endif // _syscall_c_h_
