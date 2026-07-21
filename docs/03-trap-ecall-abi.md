# 03 - trap, ecall i sistemski pozivi

fajlovi: `src/supervisorTrap.S`, `src/riscv.cpp`, `src/syscall_c.cpp`, `h/syscall_c.hpp`

## ideja u jednoj recenici

korisnicki kod ne sme sam da radi privilegovane stvari, pa umesto toga "pozvoni
na vrata" jezgra instrukcijom `ecall`; procesor tada uskace u sistemski rezim i
skace na JEDNU jedinu adresu (`stvec`), gde nasa rutina utvrdi ko zvoni i zasto.

## sta hardver radi automatski na trap (ecall/izuzetak/prekid)

```
1. sepc    <- pc               (adresa SAME ecall instrukcije / prekinute instrukcije)
2. scause  <- razlog           (top bit: 1=prekid, 0=izuzetak/ecall; ostalo: kod)
3. sstatus.SPP  <- rezim iz kog se doslo   (0=korisnicki, 1=sistemski)
   sstatus.SPIE <- stara vrednost SIE
   sstatus.SIE  <- 0           (maskiraj prekide dok traje obrada)
4. rezim   <- sistemski
5. pc      <- stvec            (nasa trapHandler rutina)
```

`sret` radi obrnuto: `pc <- sepc`, `rezim <- SPP`, `SIE <- SPIE`.

vazni kodovi u scause (tabela iz pdf-a, str. 15):

```
top bit 1, kod 1  -> softverski prekid (kod nas: tajmer)
top bit 1, kod 9  -> spoljasnji hardverski prekid (konzola)
top bit 0, kod 2  -> ilegalna instrukcija
top bit 0, kod 8  -> ecall iz korisnickog rezima
top bit 0, kod 9  -> ecall iz sistemskog rezima
```

## abi konvencija (kako se dogovaraju pozivalac i jezgro)

- `a0` = kod sistemskog poziva (0x01 mem_alloc, 0x02 mem_free, 0x11 thread_create...)
- `a1, a2, ...` = argumenti redom
- povratna vrednost stize nazad u `a0`
- specificnost mem_alloc-a: na abi nivou velicina je u BLOKOVIMA
  (c api funkcija pre ecall-a zaokruzi bajtove u blokove)

## flow: mem_alloc(100) od pocetka do kraja

```
[korisnicki kod]
1. mem_alloc(100)                       c api funkcija
2. numBlocks = (100+63)/64 = 2          bajtovi -> blokovi
3. a0=0x01, a1=2, ecall                 "zvono na vratima"

[hardver]
4. sepc/scause/sstatus se pune, skok na stvec

[supervisorTrap.S - trapHandler]
5. spusti 15 registara na stek          (ra, t0-t6, a1-a7 - vidi lekciju 04 zasto!)
6. call handleSupervisorTrap                      a0..a3 su JOS UVEK zateceni registri
                                        (supervisorTrap.S ih nije dirao pre call-a) - zato
                                        c funkcija cita abi argumente kao parametre

[riscv.cpp - handleSupervisorTrap]
7. cita scause: top bit 0, kod 9        -> ecall (iz sistemskog rezima)
8. switch(a0): 0x01                     -> MemoryAllocator::alloc(2 * 64)
9. sepc += 4                            KLJUCNO: sepc pokazuje na sam ecall;
                                        bez ovoga sret vraca NA ecall -> vecna petlja
10. return ret                          rezultat ode u a0

[supervisorTrap.S]
11. vrati 15 registara sa steka         (a0 se NE vraca - on nosi rezultat!)
12. sret                                pc<-sepc (iza ecall-a), rezim<-SPP, SIE<-SPIE

[korisnicki kod]
13. mem_alloc vrati (void*)a0           korisnik dobio pokazivac, ne zna nista o trapu
```

## zasto sepc += 4 SAMO za ecall

- ecall: sepc = adresa SAME ecall instrukcije. da ne pomerimo, vrteli bismo se.
- asinhroni prekid: sepc = adresa prekinute a neizvrsene instrukcije - ona MORA
  da se izvrsi, pa se sepc NE dira.

## c api sloj (syscall_c.cpp)

trik za tacno gadjanje registara bez pisanja .S fajla:

```cpp
register uint64 code   asm("a0") = 0x01;   // promenljiva vezana bas za a0
register uint64 blocks asm("a1") = numBlocks;
asm volatile("ecall" : "=r"(code) : "r"(code), "r"(blocks) : "memory");
return (void*)code;                        // a0 posle ecall-a = rezultat
```

## pitanja za odbranu

1. zasto je dovoljna JEDNA prekidna rutina za sve uzroke? (stvec, scause)
2. kako handleSupervisorTrap "magijski" dobija abi argumente kao c parametre?
3. razlika `sret` i `ret`?
4. sta bi se desilo bez `sepc += 4` kod ecall-a? a sta ako bismo ga radili kod prekida?
5. zasto se `a0` ne cuva/ne restaurira u supervisorTrap.S kao ostali registri?
