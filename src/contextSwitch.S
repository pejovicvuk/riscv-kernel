# promena konteksta: "zamrzni" tekucu nit, "odmrzni" sledecu.
# void contextSwitch(TCB::Context* oldCtx, TCB::Context* newCtx)
#   a0 = &stari kontekst {ra, sp},  a1 = &novi kontekst {ra, sp}
#
# s0-s11 (callee-saved) se spustaju na stek SAME niti pre zamrzavanja:
# nit ce ih ocekivati netaknute kad se probudi, a u medjuvremenu ce ih
# druge niti slobodno koristiti. ra/sp idu u tcb (context), ostalo "visi"
# o sp-u kao kofer o rucki.
#
# paznja: raspored polja mora da se poklapa sa strukturom Context u tcb.hpp
# (ra na pomeraju 0, sp na pomeraju 8).

.global contextSwitch
contextSwitch:
    addi sp, sp, -96       # mesto za 12 s-registara (12 x 8B)
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

    sd ra, 0(a0)           # stara nit: gde da nastavi kad se probudi
    sd sp, 8(a0)           # stara nit: rucka kofera        == zamrznuta

    ld ra, 0(a1)           # nova nit: odakle nastavlja
    ld sp, 8(a1)           # nova nit: njen stek            == budi se

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
    ret                    # skok na ra nove niti: usao kao stara, izasao kao nova
