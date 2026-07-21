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
| 10 | [vodic kroz flowove (citanje koda)](10-vodic-kroz-flowove.md) | gotovo |
| 11 | [deljenje vremena (preotimanje)](11-deljenje-vremena.md) | gotovo |

## trenutno stanje projekta

- zadatak 1 (alokator): KOMPLETAN - mem_alloc i mem_free kroz ceo ecall lanac,
  spajanje dokazano (heap se vraca u jedan blok, nula curenja)
- prekidna rutina: cuva registre, sepc/sstatus po niti (lokali), panika na
  nepoznat uzrok; maska prekida u sie registru (vazi u oba rezima)
- zadatak 2 (niti): KOMPLETAN - ZVANICNI TESTOVI 1 i 7 PROLAZE (2026-07-20).
  syscalls 0x11-0x13, c api, u-mode tela, zombi ciscenje, t-registri prezivljavaju
  dispatch (test 1: "C: t1=7")
- konzola (2026-07-21, VAZNA ISPRAVKA): getc/putc preko console.lib
  (__getc/__putc + console_handler na prekid, pdf str. 31) umesto naseg
  pollinga; sie bitovi 1 i 9 ukljuceni; userMain je sada NIT (pdf str. 4);
  svi testovi ponovo overeni posle izmene
- zadatak 3 (semafori): ZVANICNI TEST 3 PROLAZI (2026-07-19); test 1 regresija ok.
  scb, pozivi 0x21-0x26, trece stanje niti (blokirana), switchToNext refaktor,
  globalni new/delete za korisnicki sloj (_new.cpp)
- c++ api (syscall_cpp.hpp/.cpp): GOTOV - ZVANICNI TESTOVI 2 i 4 PROLAZE
  (2026-07-20). Thread/Semaphore/PeriodicThread/Console kao tanki omotaci;
  runWrapper bira body ili run() (pdf pravilo); sleep i PeriodicThread su
  stub do zadatka 4. TIME JE SEKCIJA OD 20 POENA KOMPLETNO OVERENA
  (testovi 1, 2, 3, 4 i 7 svi prolaze)
- preimenovanje na skolske konvencije (2026-07-21, projektna odluka):
  trapHandlers.cpp -> riscv.cpp + klasa Riscv
  (csr helperi r_/w_/ms_/mc_ umesto sirovih asm blokova); handleTrap ->
  handleSupervisorTrap; newdelete.cpp -> _new.cpp (SCB je probano kao
  _sem pa VRACENO na SCB; trap.S je probano kao supervisorTrap.S pa
  VRACENO na trap.S, ulazna labela je sada `trap` - studentove odluke).
  logika NIJE menjana;
  unutrasnjost TCB-a (switchToNext, reapZombie, userWrapper, systemLevel)
  namerno zadrzana nasa - to su nase projektne odluke
- DELJENJE VREMENA (2026-07-21, odluka studenta - obim kao kolegin
  projekat): preotimanje na tajmerski prekid - TCB::tick + dispatch iz
  grane code==1, kvantum timeSlice po niti, reset u switchToNext,
  prekidi u main-u tek posle nulte niti. testovi 3/4 sada teku
  KONTINUALNO (overeno); time_sleep, svoja konzola i PeriodicThread
  se i dalje NE rade
- u toku: rezim potpunog razumevanja - citanje koda po lekcijama 10 i 11
- sledece (odluka studenta): zadatak 4 (tajmer/preotimanje, time_sleep,
  prava konzola -> testovi 5 i 6) ili priprema odbrane

## kako radimo

1. novi kod + objasnjenje toka prostim jezikom
2. citanje koda liniju po liniju
3. "jasno" -> kontrolna pitanja -> sledeca celina
4. posle svake celine: update ovih lekcija
