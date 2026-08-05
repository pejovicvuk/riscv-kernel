# 11 - deljenje vremena (preotimanje na tajmerski prekid)

fajlovi: `src/riscv.cpp` (grana code==1), `h/tcb.hpp` + `src/tcb.cpp`
(tick, usedTicks, timeSlice, reset u switchToNext), `src/main.cpp`
(redosled ukljucivanja prekida)

uradjeno 2026-07-21, tada kao JEDINI deo zadatka 4. od 2026-08-05
zadatak 4 je kompletan (lekcija 12): tajmerska grana sada PRE tick-a
zove i `TCB::wakeSleepers()` (budjenje niti uspavanih time_sleep-om).

## sta je asinhrona promena konteksta

do sada je nit gubila procesor SAMO kad sama zatrazi (dispatch, exit,
blokada na semaforu) - sinhrona promena. sada tajmer (10 otkucaja u
sekundi, stize kao softverski prekid, kod 1) NAPLACUJE vreme tekucoj
niti, i kad potrosi kvantum - jezgro je skida sa procesora IZ PREKIDA,
bez njenog znanja i pristanka. to je asinhrona promena konteksta.

## flow

1. nit radi bilo sta (u-mode; ili ceka u __getc u s-modu - i to se
   prekida, jer __getc pusta prekide dok ceka)
2. tajmerski otkucaj -> trap -> trap.S sacuva registre na
   stek niti -> handleSupervisorTrap, grana code==1
3. `Riscv::mc_sip(SIP_SSIP)` - potvrdi prijem (PRE eventualne promene
   niti - inace bi zahtev ostao da visi)
4. `TCB::tick()` - usedTicks++, poredi sa running->timeSlice.
   nije isteklo -> povratak, nit nista ne primeti
5. isteklo -> `TCB::dispatch()` - ISTA masinerija kao kod dobrovoljnog
   dispatch-a (lekcija 10, flow 4). nit se zamrzne usred svoje prekidne
   obrade: sepc/sstatus cekaju u lokalima na njenom steku
6. kad opet dodje na red: odmota se kroz SVOJ trap, sret, nastavlja od
   prekinute instrukcije - "vreme joj je preskocilo", nista vise

## projektne odluke (studentove, za odbranu)

- brojac `usedTicks`: staticki u TCB (kvantum je osobina tekuce NITI;
  pdf str. 28 - "jedna staticka promenljiva, enkapsulirana"). metoda
  `tick()` vraca true kad kvantum istekne
- reset kvantuma: na JEDNOM mestu - u `switchToNext`, pri izboru nove
  tekuce niti. pokriva automatski SVE puteve (dispatch, exit, blokadu,
  preotimanje) - nemoguce zaboraviti granu. (alternativa "reset rasuto
  po syscall granama" - tako kolegin projekat - lako promasi npr. granu
  blokade na semaforu)
- kvantum `timeSlice` je POLJE u TCB-u (podrazumevano DEFAULT_TIME_SLICE
  iz hw.h): pdf kaze "nit se kreira sa podrazumevanom velicinom
  vremenskog odsecka", a na odbrani je klasicna modifikacija "daj niti X
  duzi kvantum" - sa poljem trivijalno

## zamka koju smo morali da resimo: redosled u main-u

`tick()` cita `TCB::running` -> ako tajmerski prekid stigne PRE nego
sto nulta nit postoji, jezgro puca na nullptr. zato main SADA ukljucuje
prekide (sie, sstatus.SIE) tek POSLE stvaranja nulte niti. redosled
inicijalizacije je deo dizajna, ne kozmetika!

## zasto nas trap okvir ovo izdrzava bez izmena

- trap.S cuva t-registre: kod asinhronog prekida oni su "zivi"
  u prekinutom kodu (pdf str. 23-24) - test 1 (t1=7) i dalje prolazi
- a0 prekinutog koda se vraca kroz `ret = a0` (za prekide handler vraca
  zateceni a0, pa ga sret-put vrati netaknut)
- s-registre cuva C lanac (konvencija) + contextSwitch (na steku niti)
- sepc/sstatus u LOKALIMA handleSupervisorTrap-a: prezive i promenu niti
  i ugnjezdene trapove

## posledice po ponasanje

- testovi 3/4: cifre teku KONTINUALNO bez kucanja (proizvodjaci dobijaju
  procesor i dok tastaturna nit ceka u __getc) - overeno 2026-07-21
- testovi 1/2: preplitanje A/B/C/D izgleda izmesanije (smena i na kvantum,
  ne samo na dispatch) - marker "C: t1=7" i fibonacci vrednosti ostaju
- sistem sada ima preotimanje i TOKOM koda jezgra (samo u __getc/__putc
  cekanjima - jedina mesta gde su prekidi ukljuceni unutar jezgra);
  ostatak jezgra radi sa iskljucenim prekidima = prirodna kriticna sekcija

## pitanja za odbranu

1. razlika sinhrone i asinhrone promene konteksta? gde se u kodu vidi
   svaka od njih?
2. zasto se ssip brise PRE dispatch-a, a ne posle?
3. gde se resetuje kvantum i zasto bas tamo? koje sve puteve to pokriva?
4. zasto prekidi u main-u smeju da se ukljuce tek posle nulte niti?
5. sta sve mora da prezivi preotimanje (t-registri, a0, sepc/sstatus) i
   ko od njih koga cuva?
6. moze li preotimanje da prekine jezgro usred rada sa scheduler-om ili
   semaforom? zasto ne? (prekidi u jezgru iskljuceni osim u __getc/__putc)
