# 04 - Interrupts, masking and the big bug

## Three interrupt registers: who is who

- `sip` (pending): the waiting board - "a request of this kind has arrived and
  has not been handled yet". Masking does not clear requests; they wait in sip.
  After handling the timer, we clear the ssip bit (bit 1) by hand, which
  means "handled, remove the request".
- `sie` (enable): individual switches per interrupt type.
  ssie (bit 1) = software/timer, seie (bit 9) = external/console.
  **Always in effect, including in user mode.**
- `sstatus.SIE` (bit 1): the master switch "may you interrupt me right now".
  **In effect only in supervisor mode; ignored in user mode** (project
  specification, pp. 15-16).

Two-level decision model:

```
interrupt arrives -> is this type allowed?          (sie: ssie/seie - always in effect)
                  -> may you interrupt me now?      (sstatus.SIE - supervisor mode only;
                                                     in user mode always "yes")
                  -> both "yes": trap to stvec.  otherwise: the request waits in sip.
```

Consequence (at the time of this lesson): the mask `sstatus.SIE = 0` in main
worked only because everything was still running in supervisor mode. Once
threads moved to user mode (test 7 requires it), the mask moved to the
`sie` register, and it is still there (lesson 07). In the final state
both sie bits are on (console + timer, lessons 11/12), and sstatus.SIE = 1 is
set alongside them so that interrupts also arrive while main (S-mode) is on
the processor.

The mask is self-sustaining across traps: on entry the hardware saves
`SPIE <- SIE`, and `sret` restores `SIE <- SPIE`. (At the time of this lesson:
zero begets zero.)

## Platform specifics

- The timer arrives as a software interrupt (scause top=1, code=1), 10 times
  per second; handling: clear ssip in sip
- The console arrives as an external interrupt (top=1, code=9); handling:
  `plic_claim()`, then `plic_complete(irq)`
- **The console is "chatty"**: the controller also raises an interrupt when it
  is ready to send, and it is almost always ready. You do claim/complete
  correctly, and it raises a new interrupt right away. Without buffering
  (Part 4), the console has to stay masked.

## The big bug: chasing the wrong culprit

Symptom: after a successful mem_alloc ecall, an infinite loop alternating
`c=0x8000000000000009` / `c=0x2`. Masking SIE did not help.

What gave it away:
1. `sstatus after mask = 0x0` -> the mask was written
2. ecall gives `c=0x...09` (top 0) -> confirms we are running in supervisor mode
3. after "before return": `c=0x8000000000000009` -> an external interrupt was
   delivered despite SIE=0, and that can only happen in user mode.

Reconstruction (follow the `ra` register):

```
userMain --call--> mem_alloc              ra = return address into userMain
                   mem_alloc is a leaf function -> its compiled code does not save ra on the stack
ecall -> old trapHandler:
    call handleSupervisorTrap             !!! call writes into ra the address of the NEXT
                                          instruction = the address of sret
    sret -> back into mem_alloc           but ra is still CLOBBERED
mem_alloc: ret                            jump to ra = to the sret in trapHandler
rogue sret: mode <- SPP                   SPP is 0 (the previous sret reset it)
                                          -> drop into user mode
user mode: sstatus.SIE is ignored         -> the chatty console barges in: c=0x8...09
its sret returns to user mode -> code again reaches ret -> jump to sret ->
in user mode sret is an ILLEGAL (privileged) instruction -> c=0x2
the handler for c=2 does not advance sepc -> same address -> and the console is already waiting -> 9,2,9,2...
```

## Lessons from the bug

1. **The interrupt routine must save the caller-saved registers** (ra, t0-t6,
   a1-a7): by convention a C function may clobber them, and the interrupted
   code (which the interrupt cut off mid-work; it did not "call" anyone)
   assumes they are untouched. That is why trap.S now pushes 15 registers onto
   the stack before the call and restores them afterwards. (Not s0-s11: those
   are saved by handleSupervisorTrap itself in its prologue/epilogue, by
   convention.)
2. **Privileged instructions protect the kernel**: sret/csr from user mode =
   illegal instruction. If that were not the case, a user program could switch
   itself into supervisor mode and there would be no protection.
3. **Panic instead of a silent loop**: unknown cause -> print cause + sepc ->
   halt. sepc tells you the exact address that failed; find it in kernel.asm
   and you see what it is.
4. Debug-print the whole scause, not just the low byte. The top bit carries
   half of the information.

## Review questions

1. What is the difference between sip/sie/sstatus.SIE? Which of them is in
   effect in user mode?
2. Why does the timer require clearing ssip, while the console requires
   claim/complete?
3. Why does the console interrupt keep arriving even though we "handle" it?
4. Why are fewer registers saved for a synchronous context switch than for an
   asynchronous one?
5. Tell the story of the big bug: which register, which instruction, which mode.
