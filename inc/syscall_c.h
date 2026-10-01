#ifndef _syscall_c_h_
#define _syscall_c_h_

#include "../lib/hw.h"

// kernel c api (signatures from the project spec).
// the file is named syscall_c.h (not .hpp) because the official tests include it that way.

void* mem_alloc(size_t size);
int mem_free(void*);

// thread "handle": opaque pointer - the user does not know (and need not know)
// what is inside; the kernel hides its TCB behind it
class _thread;
typedef _thread* thread_t;

int  thread_create(thread_t* handle, void (*start_routine)(void*), void* arg);
int  thread_exit();
void thread_dispatch();

// semaphores - "handle" in the same pattern as thread_t (kernel SCB behind it)
class _sem;
typedef _sem* sem_t;

int sem_open(sem_t* handle, unsigned init);
int sem_close(sem_t handle);
int sem_wait(sem_t id);
int sem_signal(sem_t id);
int sem_wait_n(sem_t id, unsigned n);
int sem_signal_n(sem_t id, unsigned n);

// sleep: the thread sleeps for the given number of timer periods (part 4)
int time_sleep(time_t);

// console
const int EOF = -1;
char getc();
void putc(char);

#endif // _syscall_c_h_
