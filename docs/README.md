# os1 projekat - lekcije

skripta projekta: sta smo uradili, kako radi i zasto bas tako.
svaka lekcija ima "flow" primere - korak po korak kako se stvari desavaju.
ovo je ujedno i priprema za odbranu: na kraju svake lekcije su pitanja
na koja treba znati odgovor.

## sadrzaj

| # | lekcija | status |
|---|---------|--------|
| 01 | [platforma i okruzenje](01-platforma-i-okruzenje.md) | gotovo |
| 02 | [alokator memorije (zadatak 1)](02-alokator-memorije.md) | gotovo |
| 03 | [trap, ecall i sistemski pozivi](03-trap-ecall-abi.md) | gotovo |
| 04 | [prekidi, maskiranje i veliki bug](04-prekidi-maskiranje-bug.md) | gotovo |
| 05 | [niti - TCB, Scheduler, promena konteksta](05-niti-kostur.md) | gotovo |
| 06 | [niti kroz sistemske pozive](06-sistemski-pozivi-niti.md) | gotovo |
| 07 | [niti u korisnickom rezimu (u-mode)](07-u-mode-niti.md) | gotovo |
| 08 | [zvanicni testovi + polling konzola](08-zvanicni-testovi.md) | gotovo |
| 09 | [semafori (zadatak 3)](09-semafori.md) | gotovo |

## trenutno stanje projekta

- zadatak 1 (alokator): KOMPLETAN - mem_alloc i mem_free kroz ceo ecall lanac,
  spajanje dokazano (heap se vraca u jedan blok, nula curenja)
- prekidna rutina: cuva registre, sepc/sstatus po niti (lokali), panika na
  nepoznat uzrok; maska prekida u sie registru (vazi u oba rezima)
- zadatak 2 (niti): KOMPLETAN - ZVANICNI TESTOVI 1 i 7 PROLAZE (2026-07-20).
  syscalls 0x11-0x13, c api, u-mode tela, zombi ciscenje, t-registri prezivljavaju
  dispatch (test 1: "C: t1=7"), polling putc/getc za meni testova
- zadatak 3 (semafori): ZVANICNI TEST 3 PROLAZI (2026-07-19); test 1 regresija ok.
  scb, pozivi 0x21-0x26, trece stanje niti (blokirana), switchToNext refaktor,
  globalni new/delete za korisnicki sloj (newdelete.cpp)
- sledece: c++ api (Thread, Semaphore...) -> testovi 2 i 4, pa zadatak 4
  (tajmer/preotimanje, time_sleep, prava konzola) -> testovi 5 i 6
- cilj: svih 30 poena (zadaci 1+2+3+4)

## kako radimo

1. novi kod + objasnjenje toka prostim jezikom
2. citanje koda liniju po liniju
3. "jasno" -> kontrolna pitanja -> sledeca celina
4. posle svake celine: update ovih lekcija
