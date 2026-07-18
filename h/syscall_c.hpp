#ifndef _syscall_c_hpp_
#define _syscall_c_hpp_

#include "../lib/hw.h"

// c api jezgra (potpisi iz postavke projekta)
void* mem_alloc(size_t size);
int mem_free(void*);

#endif // _syscall_c_hpp_
