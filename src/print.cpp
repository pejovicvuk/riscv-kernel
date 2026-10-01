#include "../inc/print.hpp"

// send one char to the console controller (polling)
void kputc(char c) {
    // CONSOLE_STATUS is an address (constant from hw.h); to read a byte at that
    // address, we cast the number to a pointer to volatile char and dereference.
    // volatile: the value is changed by hardware, the compiler must really read
    // memory on every loop iteration, it must not cache it
    while ((*(volatile char*)CONSOLE_STATUS & (1 << 5)) == 0) {
        // bit 5 == 0 means "not ready to accept a char to send"
    }
    // ready: write the byte into the transmit register
    *(volatile char*)CONSOLE_TX_DATA = c;
}

// print a whole string, char by char
void kputs(const char* s) {
    while (*s) kputc(*s++);
}

// print a 64-bit number in hex (fixed 16 digits)
void kputhex(uint64 n) {
    kputs("0x");
    for (int shift = 60; shift >= 0; shift -= 4) {
        uint64 digit = (n >> shift) & 0xF;
        char c;
        if (digit < 10) {
            c = '0' + digit;
        } else {
            c = 'a' + (digit - 10);
        }
        kputc(c);
    }
}
