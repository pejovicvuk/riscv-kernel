#include "../lib/hw.h"   // adjust path to wherever your hw.h lives

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

void userMain();   // forward declaration: defined elsewhere (your test file)

int main() {
    kputs(">> kernel: starting\n");

    userMain();    // THE CHEAT: calling it as a plain function for now.
                   // In the real kernel this becomes "wrap userMain as the
                   // body of the first thread and let the scheduler run it."

    kputs(">> kernel: userMain returned, halting\n");

    // Halt the emulator: writing the 32-bit value 0x5555 to physical
    // address 0x100000 is qemu's "guest asked to power off" signal, so
    // `make qemu` returns to your shell instead of hanging.
    *(volatile int*)0x100000 = 0x5555;

    return 0;   // never really reached, but keeps the signature honest
}