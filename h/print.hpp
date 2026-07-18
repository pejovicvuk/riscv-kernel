#ifndef _print_hpp_
#define _print_hpp_

#include "../lib/hw.h"

// debug alati za direktan ispis na konzolu (polling, bez prekida);
// nisu deo resenja koje se predaje
void kputc(char c);
void kputs(const char* s);
void kputhex(uint64 n);

#endif // _print_hpp_
