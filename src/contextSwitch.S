# context switch: "freeze" the running thread, "unfreeze" the next one.
# void contextSwitch(TCB::Context* oldCtx, TCB::Context* newCtx)
#   a0 = &old context {ra, sp},  a1 = &new context {ra, sp}
#
# s0-s11 (callee-saved) are pushed onto the thread's OWN stack before freezing:
# the thread expects them untouched when it wakes up, and meanwhile other
# threads may use them freely. ra/sp go into the tcb (context), the rest "hangs"
# off sp like a suitcase off its handle.
#
# careful: field layout must match the Context struct in tcb.hpp
# (ra at offset 0, sp at offset 8).

.global contextSwitch
contextSwitch:
    addi sp, sp, -96       # room for 12 s-registers (12 x 8B)
    sd s0, 0(sp)
    sd s1, 8(sp)
    sd s2, 16(sp)
    sd s3, 24(sp)
    sd s4, 32(sp)
    sd s5, 40(sp)
    sd s6, 48(sp)
    sd s7, 56(sp)
    sd s8, 64(sp)
    sd s9, 72(sp)
    sd s10, 80(sp)
    sd s11, 88(sp)

    sd ra, 0(a0)           # old thread: where to resume when it wakes up
    sd sp, 8(a0)           # old thread: suitcase handle    == frozen

    ld ra, 0(a1)           # new thread: where it resumes
    ld sp, 8(a1)           # new thread: its stack          == wakes up

    ld s0, 0(sp)
    ld s1, 8(sp)
    ld s2, 16(sp)
    ld s3, 24(sp)
    ld s4, 32(sp)
    ld s5, 40(sp)
    ld s6, 48(sp)
    ld s7, 56(sp)
    ld s8, 64(sp)
    ld s9, 72(sp)
    ld s10, 80(sp)
    ld s11, 88(sp)
    addi sp, sp, 96
    ret                    # jump to the new thread's ra: entered as old, left as new
