#include "../h/print.hpp"

// Send one character to the console controller.
void kputc(char c) {
    // CONSOLE_STATUS is an address (a constant from hw.h). To read the
    // byte living at that address, we reinterpret the integer address as
    // a pointer-to-volatile-char and dereference it. 'volatile' tells the
    // compiler the value can change outside our code (the hardware sets it),
    // so it must actually re-read memory every loop pass, not cache it.
    while ((*(volatile char*)CONSOLE_STATUS & (1 << 5)) == 0) {
        // spin: bit 5 == 0 means "not ready to accept a char to send"
    }
    // Ready. Write the byte into the transmit-data register.
    *(volatile char*)CONSOLE_TX_DATA = c;
}

// Convenience: print a whole string by sending char by char.
void kputs(const char* s) {
    while (*s) kputc(*s++);
}
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