#include "../h/print.hpp"

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