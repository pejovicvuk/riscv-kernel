# os1

A small operating system kernel for RISC-V (RV64), written in C++ and
assembly, that runs on QEMU. It was built as the project for the
Operating Systems 1 course at the School of Electrical Engineering,
University of Belgrade (ETF).

The course splits the project into four parts: Part 1 is the memory
allocator, Part 2 is threads, Part 3 is semaphores, and Part 4 is time
sharing, sleep and the console. All four parts are done.

## Features

- **Memory allocator:** first-fit allocator over the free heap, with
  merging of free blocks
- **Traps and system calls:** one trap entry point (`src/trap.S`),
  system calls through `ecall` with a register-based ABI
- **Threads:** TCB, FIFO scheduler, context switch, user threads run
  in U-mode (user mode), the kernel runs in S-mode
- **Semaphores:** blocking FIFO semaphores (`sem_open`, `sem_wait`,
  `sem_signal`, `sem_close`, ...)
- **Time sharing:** preemption on the timer interrupt, with a time
  slice per thread
- **Sleep:** `time_sleep` with a sorted list of sleeping threads
  (relative delays)
- **Console:** interrupt-driven console with input and output buffers
  and a kernel output thread
- **C and C++ APIs:** `syscall_c.h` (C API) and `syscall_cpp.hpp`
  (`Thread`, `Semaphore`, `PeriodicThread`, `Console`)

All official course tests (1-7) pass. Test 7 checks that user code
cannot run privileged instructions, so it is expected to end with
`PANIC cause=2` (illegal instruction).

## Layers

```
user program (test/)                <- official tests + own test 8
C++ API (Thread, Semaphore, ...)    <- thin wrapper over the C API
C API (mem_alloc, thread_*, ...)    <- packs registers + ecall
ABI (ecall, a0=code, a1..=args)     <- software interrupt
kernel (TCB, Scheduler, SCB, CCB,   <- entry ONLY through trap.S,
        MemoryAllocator)               exit ONLY through sret
hw.lib (hardware access)            <- provided by the course
```

## Build and run

The build needs the `riscv64-unknown-elf` GCC toolchain and
`qemu-system-riscv64`. The easiest way is the included `Dockerfile`
(Ubuntu 20.04 with the right toolchain versions):

```sh
docker build -t os1 .
docker run --rm -it -v "$PWD":/work os1
```

On macOS you can use Apple `container` with the same image instead of
Docker.

Inside the container:

```sh
make            # build the kernel
make qemu       # run it in QEMU (exit: Ctrl-A, then X)
make qemu-gdb   # run with a GDB server
make clean      # remove build output
```

When the kernel starts, it asks for a test number (1-8) and runs that
test.

Newer host toolchains (Homebrew on macOS, for example) can fail
with "extension zicsr required". Build inside the container.

## Project layout

```
src/    kernel and API sources (trap.S, contextSwitch.S, tcb, scheduler, ...)
inc/    headers
test/   official course tests + own test (myTest)
lib/    course-provided libraries (only hw.lib is linked; the own
        console replaces console.lib)
docs/   lessons: how each part works and why
```

## Documentation

The [docs/](docs/README.md) folder has 12 lessons that explain the
design step by step, from the platform and the memory allocator to
time sharing and the console. Lesson 10 is a guided tour through the
code, flow by flow.

## Credits

- The project base (build files, `lib/`, `kernel.ld`, official tests)
  is provided by the OS1 course at ETF Belgrade.
- The `LICENSE` file comes from xv6 (MIT), which the course base is
  derived from.
