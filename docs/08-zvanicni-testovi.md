# 08 - zvanicni testovi + polling konzola

fajlovi: `test/` (zvanicni fajlovi), `src/userMain.cpp` (zvanicni meni,
prilagodjen), `h/syscall_c.h` (preimenovan sa .hpp), `src/trapHandlers.cpp`
(case 0x41/0x42), `src/syscall_c.cpp` (getc/putc)

## sta je uvezeno i zasto bas to

u `test/` su za sada SAMO fajlovi za testove koje mozemo da pokrenemo:
printing.{hpp,cpp}, lock.S, Threads_C_API_test.{hpp,cpp},
System_Mode_test.{hpp,cpp}. ostali (semafori, sleep, cpp api) se dodaju
kad stigne njihova funkcionalnost - NE ranije, jer makefile kompajlira
SVE .cpp fajlove u projektu (find . -name "*.cpp"), pa bi test koji zove
sem_open pravio "undefined reference" na linkovanju.

administrativa:
- nas header preimenovan u `syscall_c.h` - testovi ga tako include-uju
- nas stari userMain zamenjen zvanicnim menijem (LEVEL_1/2 = 1, 3/4 = 0);
  todo markeri pokazuju sta se vraca kad stignu cpp api / semafori / zadatak 4
- posle preimenovanja headera OBAVEZNO `make clean` (stari .d fajlovi u
  build/ pamte zavisnost na obrisani .hpp)

## polling putc/getc (privremeno resenje)

zvanicni meni bira test preko getc() -> bez konzolnih syscalls nista ne radi.
puna verzija (baferi + prekid + interna nit jezgra) je zadatak 4; dotle,
posto su prekidi maskirani, legitimno je PROZIVANJE (polling):

```cpp
case 0x41:   // getc: cekaj znak sa tastature, pa ga procitaj
    while ((*(volatile char*)CONSOLE_STATUS & CONSOLE_RX_STATUS_BIT) == 0) {}
    ret = (uint64)(*(volatile char*)CONSOLE_RX_DATA);
    break;
case 0x42:   // putc: cekaj da kontroler moze da primi, pa posalji
    while ((*(volatile char*)CONSOLE_STATUS & CONSOLE_TX_STATUS_BIT) == 0) {}
    *(volatile char*)CONSOLE_TX_DATA = (char)a1;
    break;
```

mana polling getc-a: dok jezgro ceka znak, CEO sistem stoji (nijedna druga
nit ne radi). za meni je to ok; zadatak 4 to resava blokiranjem niti + baferom.

## sta zvanicni testovi zapravo proveravaju (procitano iz koda!)

- test 1: 4 niti (A,B,C,D) se smenjuju uz ogromne busy-wait petlje.
  najzanimljivije: nit C uradi `li t1, 7`, pa thread_dispatch, pa PROVERI
  da li je t1 preziveo promenu konteksta! ovo testira cuvanje t-registara
  po niti - tacno ono sto nas trap.S radi (t/a/ra na stek niti pri trapu).
  slicno i D sa `li t1, 5` - dve niti, ISTI registar, razlicite vrednosti.
- test 7: nit B na i==10 izvrsi `csrr t6, sepc` - u u-modu to je ilegalna
  instrukcija -> panika -> nema regularnog kraja == PROLAZ. poruka
  "Test se nije uspesno zavrsio" NE SME da se pojavi.
- printing koristi spin-lock (copy_and_swap iz lock.S, lr.w/sc.w atomike)
  oko ispisa - stitи ispis od mesanja kad se niti smenjuju usred stringa.

## kako se pokrece

```
make clean && make && make qemu     (u containeru!)
meni: ukucaj 1 pa enter -> test 1 (TRAJE dugo - busy petlje, gledaj A:/B:/C:/D: redove)
      ukucaj 7 pa enter -> ocekivan PANIC cause=0x2 (to je prolaz!)
```

izlaz iz qemu ako test predugo traje: ctrl-a pa x.

## pitanja za odbranu

1. zasto je polling getc "zaustavlja ceo sistem" i kako to zadatak 4 resava?
2. sta test 1 proverava trikom li t1,7 / dispatch / mv? gde nas kod to garantuje?
3. zasto printString mora spin-lock oko petlje sa putc?
4. zasto test 7 "prolazi padom"? koja poruka ne sme da se pojavi?
