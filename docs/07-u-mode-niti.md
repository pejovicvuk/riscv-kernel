# 07 - niti u korisnickom rezimu (u-mode)

fajlovi: `src/tcb.cpp`, `h/tcb.hpp`, `src/main.cpp`

## zasto

pdf arhitektura: jezgro radi privilegovano, korisnicki kod (tela niti)
neprivilegovano. do sada je SVE radilo u s-modu - radi, ali korisnicka nit
ima kljuceve od cele kuce (moze da ugasi prekide, prepise stvec...).

konkretan razlog: **zvanicni test 7** u telu niti izvrsi `csrr t6, sepc`
(privilegovana instrukcija) i OCEKUJE da program pukne. u s-modu instrukcija
prodje -> test pada. u u-modu -> ilegalna instrukcija -> panika -> test prolazi.
jedini test koji prolazi tako sto program pukne.

## projektne odluke (moje)

1. **userWrapper cita body/arg direktno iz TCB-a** (umesto slanja kroz
   registre pre sret-a). razlog: na ovoj platformi svi dele isti adresni
   prostor bez memorijske zastite, pa je citanje fizicki moguce i pouzdano;
   granica privilegija su INSTRUKCIJE (csr/sret), ne memorija. alternativa
   (registri + sret u asm-u) je krhka na izmene.
2. **maska prekida zivi samo u sie registru** (ssie bit 1 + seie bit 9),
   ne vise u sstatus.SIE. razlog: sie vazi u OBA rezima (sstatus.SIE se u
   u-modu ignorise) - jedan mehanizam za celu pricu; u zadatku 4 se biti
   samo ukljuce nazad.

## kako se nit spusta u u-mode - flow rodjenja (dopunjen)

jedina kapija nadole (s -> u) je `sret` sa spp=0. wrapper dobija dva dela:

```
contextSwitch -> ret -> threadWrapper       (s-mode, kao i do sada)
  reapZombie()
  sistemska nit (systemLevel)?  -> telo odmah, ovde, privilegovano
  korisnicka nit:
     sepc    <- adresa userWrapper-a
     sstatus.SPP <- 0            "sret vodi u korisnicki rezim"
     sret  ========== SPUST U U-MODE ==========
userWrapper                                  (u-mode!)
  running->body(running->arg)                telo radi neprivilegovano
  thread_exit()                              ecall - jedini put nazad u jezgro
```

kod (tcb.cpp):

```cpp
void TCB::threadWrapper() {
    reapZombie();
    if (running->systemLevel) {
        running->body(running->arg);
        running->finished = true;
        dispatch();
    }
    uint64 target = (uint64)&userWrapper;
    asm volatile("csrw sepc, %0" : : "r"(target));
    uint64 sstatus;
    asm volatile("csrr %0, sstatus" : "=r"(sstatus));
    sstatus &= ~(1UL << 8);                    // spp = 0
    asm volatile("csrw sstatus, %0" : : "r"(sstatus));
    asm volatile("sret");
}

void TCB::userWrapper() {
    running->body(running->arg);
    thread_exit();      // ecall - jedini legalan povratak u jezgro
    for (;;) {}         // nedostizno; da se nikad ne "ispadne"
}
```

`systemLevel` zastavica u tcb-u: interne niti jezgra (nulta nit, kasnije
konzolna nit iz zadatka 4) ostaju u s-modu - pdf izricito trazi da se
"njihovo telo izvrsava u sistemskom rezimu".

## lepota koju smo dobili besplatno: povratak u PRAVI rezim

kad u-nit uradi ecall, hardver upise spp=0 (dosao iz u-moda). handleTrap
ODMAH snima sstatus (sa tim spp=0) u lokalnu promenljivu - deo konteksta
niti! - i vraca ga pred sret. dakle:

- u-nit se iz svakog syscalla vraca u u-mode (njen sstatus nosi spp=0)
- s-nit (main) se vraca u s-mode (njen sstatus nosi spp=1)

nikakav dodatni kod: resenje "sepc/sstatus u lokale" iz lekcije 06
automatski resava i per-nit rezim. zato se sstatus cuvao jos tada.

## posledice u-moda (podsetnik iz lekcije 04)

- sstatus.SIE se u u-modu IGNORISE -> zato maska ide u sie (vazi svuda)
- ecall iz u-moda daje scause=8 (iz s-moda 9) - handler prihvata oba
- privilegovana instrukcija u u-modu -> ilegalna instrukcija (c=2) -> panika
- mmio pristup (kputs) iz u-moda radi: nema memorijske zastite na platformi

## kako se testira

1. obican test: isti izlaz kao ranije (ABABABABAB + obe niti zavrsile) -
   ali tela sada rade u u-modu, a thread_dispatch stize kao scause=8
2. provera rezima ("nas test 7"): u workerA odkomentarisi
   `asm volatile("csrr t6, sepc");` -> ocekivan PANIC cause=0x2 (ilegalna
   instrukcija) - dokaz da je telo stvarno neprivilegovano. vrati komentar!

## pitanja za odbranu

1. koja je jedina kapija iz s-moda u u-mode i kako je wrapper koristi?
2. zasto userWrapper sme da CITA tcb, a ne sme da pozove TCB::dispatch() direktno?
3. kako se u-nit posle syscalla vrati u u-mode, a s-nit u s-mode - gde je ta informacija?
4. zasto je maska morala da se preseli iz sstatus.SIE u sie?
5. sta tacno test 7 proverava i zasto mu je "pad" programa uslov prolaza?
6. koje niti ostaju sistemske i zasto?
