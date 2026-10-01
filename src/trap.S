# trap handler: the only gate for ecall, exceptions and interrupts (stvec -> here).
# it must save all registers the c function handleSupervisorTrap may
# clobber (caller-saved: ra, t0-t6, a1-a7), because the interrupted code expects
# them untouched. a0 is deliberately not saved/restored: it carries the return
# value of handleSupervisorTrap (the system call result; for interrupts the
# original a0 is returned). we do not save s0-s11: by convention
# handleSupervisorTrap saves them itself if it uses them.

.align 4
.global trap
trap:
    addi sp, sp, -128      # 15 registers x 8B = 120, rounded up to 128 (sp divisible by 16)
    sd ra, 0(sp)
    sd t0, 8(sp)
    sd t1, 16(sp)
    sd t2, 24(sp)
    sd t3, 32(sp)
    sd t4, 40(sp)
    sd t5, 48(sp)
    sd t6, 56(sp)
    sd a1, 64(sp)
    sd a2, 72(sp)
    sd a3, 80(sp)
    sd a4, 88(sp)
    sd a5, 96(sp)
    sd a6, 104(sp)
    sd a7, 112(sp)

    call handleSupervisorTrap   # a0..a4 = registers as they were at the moment of the trap

    ld ra, 0(sp)
    ld t0, 8(sp)
    ld t1, 16(sp)
    ld t2, 24(sp)
    ld t3, 32(sp)
    ld t4, 40(sp)
    ld t5, 48(sp)
    ld t6, 56(sp)
    ld a1, 64(sp)
    ld a2, 72(sp)
    ld a3, 80(sp)
    ld a4, 88(sp)
    ld a5, 96(sp)
    ld a6, 104(sp)
    ld a7, 112(sp)
    addi sp, sp, 128
    sret
