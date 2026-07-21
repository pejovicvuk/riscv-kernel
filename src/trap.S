# prekidna rutina: jedina kapija za ecall, izuzetke i prekide (stvec -> ovde).
# mora da sacuva sve registre koje c funkcija handleSupervisorTrap sme da
# pokvari (caller-saved: ra, t0-t6, a1-a7), jer prekinuti kod racuna da su
# netaknuti. a0 se namerno ne cuva/ne vraca: on nosi povratnu vrednost
# handleSupervisorTrap-a (rezultat sistemskog poziva; za prekide se vraca
# zateceni a0). s0-s11 ne cuvamo mi: njih po konvenciji cuva sam
# handleSupervisorTrap ako ih koristi.

.align 4
.global supervisorTrap
supervisorTrap:
    addi sp, sp, -128      # 15 registara x 8B = 120, zaokruzeno na 128 (sp deljiv sa 16)
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

    call handleSupervisorTrap   # a0..a4 = zateceni registri u trenutku trapa

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
