.align 4
.global trapHandler
trapHandler:
    call handleTrap
    csrr t0, sepc
    addi t0, t0, 4
    csrw sepc, t0
    sret
