#ifndef _print_hpp_
#define _print_hpp_

#include "../lib/hw.h"

// debug tools for direct console output (polling, no interrupts);
// not part of the submitted solution
void kputc(char c);
void kputs(const char* s);
void kputhex(uint64 n);

#endif // _print_hpp_
