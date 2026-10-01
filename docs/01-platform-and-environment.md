# 01 - Platform and environment

## What we are building

A small but real operating system kernel for a RISC-V processor (rv64ima).
"Real" means there is no OS underneath our code to help out. Our code owns
the processor. The host system (a modified xv6) only loads the program,
provides the timer and the console, and hands control to our `main` in
supervisor mode.

The kernel is a "library" kernel: our kernel and the user test program are
statically linked into a single executable and share the same address space
(as in embedded systems).

Layers (we write everything between app.lib and hw.lib):

```
user program (app.lib)          <- provided by the course (tests)
C++ API (Thread, Semaphore)     <- thin wrapper around the C API
C API (mem_alloc, thread_...)   <- wrapper around the ABI
ABI (ecall + registers a0..)    <- software interrupt
kernel (allocator, threads...)  <- the core
hw.lib (hardware access)        <- provided by the course
```

## Building and running

- The build runs inside a container (on macOS: Apple's `container` CLI; the
  course provides a VMware virtual machine with CLion) that sees the project
  at `/work`
- `make` builds, `make qemu` runs; to exit QEMU press `ctrl-a`, then `x`
- `make clean && make` when make "does not see" changes (common when only
  headers were changed)
- Stopping the emulator from code: write the 32-bit value `0x5555` to address
  `0x100000`

## Infrastructure pitfalls

1. **The macOS mount is case-insensitive**: `trap.S` and `trap.s` are the same file.
   GNU make generated an intermediate `.s` file from `.S` and overwrote the
   original during cleanup. Fix: a Makefile rule that builds the `.o` directly
   from the `.S` (the indentation must be a tab):
   ```
   ${DIR_BUILD}/%.o: %.S Makefile | ${DIR_BUILD}
   	@mkdir -p $(dir ${@})
   	${CC} -c ${CFLAGS} -o ${@} ${<}
   ```
   For the same reason, include paths must match the actual file name down to
   the last letter (`memoryAllocator.hpp`, not `MemoryAllocator.hpp`). On a
   case-sensitive Linux system, one wrong letter breaks the build.
2. **Unsaved VS Code buffer**: the code "exists" in the editor but not on disk.
   Trust `ls`/`cat`/`grep` inside the container, not what VS Code shows.
3. **Run make only in the container**: the macOS Homebrew toolchain ships a
   newer binutils that requires `-march=rv64ima_zicsr` for CSR instructions,
   so the build fails with "extension zicsr required". The container (and the
   course environment) has an older GCC for which `rv64ima` implies CSR
   support. We left the Makefile untouched. To recognize the error, look for a temp
   path like `/var/folders/...` in the output means the macOS toolchain, not
   the container. If you run make on macOS anyway, build/ ends up
   with a mix of macOS and container .o files, and the linker in the container
   fails with "unsupported ISA subset" / "failed to merge target specific
   data". Fix: `make clean && make` in the container.

## Debugging tools

- `grep -n symbol file`: where a symbol is mentioned
- `nm build/.../x.o | grep symbol`: whether a symbol exists in an object file
  ("undefined reference" = declared but the definition is missing; lowercase
  `t` = static)
- `build/src/*.lst`: assembly listing of every file (proof of what the
  compiler produced)
- `kernel.asm`: disassembly of the whole kernel (look up the address from
  sepc when something crashes)
- `make qemu 2>&1 | tee /work/out.txt`: capture the whole output when the
  terminal gets flooded
- `kputs`/`kputhex` from `inc/print.hpp`: direct polling output, works even
  in the middle of an interrupt routine (a debugging tool, not part of the
  solution)
- Panic in `handleSupervisorTrap`: an unknown cause prints `cause` + `sepc`
  and shuts down the emulator instead of hanging in a silent infinite loop

## Review questions

1. Why must the kernel not use the standard C/C++ libraries?
2. What does it mean that the kernel is a "library" kernel, and how does that
   differ from a real OS?
3. How does the program terminate normally, and why does that matter for the
   tests?
