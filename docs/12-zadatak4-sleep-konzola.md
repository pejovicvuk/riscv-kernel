# 12 - zadatak 4 u celosti: time_sleep, prava konzola, PeriodicThread

fajlovi: `inc/tcb.hpp` + `src/tcb.cpp` (lista uspavanih), `inc/ccb.hpp` +
`src/ccb.cpp` (nasa konzola), `src/riscv.cpp` (0x31, 0x41/0x42, grane
code==1 i code==9), `src/main.cpp` (CCB::init + drain pred gasenje),
`src/syscall_c.cpp` (time_sleep), `src/syscall_cpp.cpp` (Thread::sleep,
PeriodicThread), `Makefile` (console.lib izbacena)

ovim je zadatak 4 KOMPLETAN: deljenje vremena (lekcija 11) + time_sleep
+ getc/putc preko sopstvenih bafera + PeriodicThread. console.lib vise
nije potrebna - lekcija 08 ostaje kao istorija 20p verzije.

## 1) time_sleep - lista uspavanih sa RELATIVNIM razlikama

ideja u jednoj recenici: nit koja spava nije ni spremna ni blokirana na
semaforu - stoji u POSEBNOJ listi, sortiranoj po trenutku budjenja, a
budi je tajmerska grana prekidne rutine.

kljucni trik (pdf str. 26): svaki clan liste pamti vreme RELATIVNO na
prethodnika. apsolutno vreme niti = zbir razlika od cela do nje.

```
time_sleep: A(3), B(5), C(5), D(9)   ->   lista: A:3 -> B:2 -> C:0 -> D:4
```

zasto: otkucaj tajmera onda dira SAMO celo liste (jedan dekrement,
`wakeSleepers`), ma koliko spavaca bilo. cena je malo slozenije umetanje
(`putToSleep`): setajuci kroz listu trosis svoje vreme na prethodnike,
ostatak upises sebi, a SLEDBENIKU ODUZMES svoju razliku - on od sada
meri od tebe. nula (C:0) = "budim se u istom trenutku kao prethodnik".

flow uspavljivanja (syscall 0x31):

1. `syscall_c.cpp` - time_sleep: a0=0x31, a1=broj otkucaja, ecall
2. `riscv.cpp` case 0x31 -> `TCB::putToSleep(a1)`
3. umetanje u listu (reciklira se `TCB::next` - nit je u najvise JEDNOM
   redu: spava, pa nije ni u scheduleru ni kod semafora)
4. `switchToNext()` - nit se zamrzne USRED putToSleep, na svom steku,
   identicno blokadi na semaforu (lekcija 09/10, flow 6)

flow budjenja (tajmerska grana, code==1):

1. `mc_sip` potvrdi prekid
2. `TCB::wakeSleepers()`: dekrementiraj celo; dok je celo na nuli -
   skini ga i `Scheduler::put` (vise niti moze deliti trenutak!)
3. tek onda `TCB::tick()` / eventualno preotimanje - budjenje ima
   prednost, da probudjena nit vec stoji u redu kad krene raspodela

zamka u wakeSleepers: PRVO pomeri sleepHead, PA Scheduler::put -
put gazi next pokazivac (ista lekcija kao u modifikacijama).

## 2) prava konzola - CCB (console control block)

do sada (20p verzija): getc/putc preko date console.lib (__getc/__putc
+ console_handler). zadatak 4 trazi SVOJE bafere - console.lib je
izbacena iz Makefile-a, a jezgro dobija cetvrtu klasu: CCB, all-static
kao Scheduler i MemoryAllocator.

arhitektura (pdf str. 27) - dva kruzna bafera, dva proizvodjac/potrosac
para, tri semafora (obicni SCB-ovi jezgra, ne sem_open - jezgro sebi
ne zvoni!):

```
ULAZ:  tastatura -> kontroler --prekid--> [prekidna rutina = proizvodjac]
       -> inputBuffer -> [getc syscall = potrosac; prazan bafer = blokada]
       semafor: inputItems (init 0, broji znakove)

IZLAZ: [putc syscall = proizvodjac; pun bafer = blokada] -> outputBuffer
       -> [IZLAZNA NIT JEZGRA = potrosac, salje uz prozivanje] -> kontroler
       semafori: outputItems (init 0), outputSpace (init BUFFER_SIZE)
```

- kruzni bafer: cita se sa head, pise na tail; "(tail+1)%N == head" je
  pun - jedno mesto se zrtvuje da se pun razlikuje od praznog, pa ne
  treba poseban brojac
- ulazni prekid (code==9, `CCB::handleInterrupt`): SAMI radimo
  plic_claim/plic_complete (to je ranije radio console_handler);
  znakovi se kupe u petlji dok ih ima; pun bafer -> znak se procita iz
  kontrolera pa ODBACI (pdf dozvoljava)
- `getc` (0x41): wait(inputItems) - prazan bafer uspava nit bas tu,
  usred jezgra, kao sem_wait; budi je prekidna rutina signalom
- `putc` (0x42): wait(outputSpace) - pun bafer blokira POZIVAOCA
  (pdf nudi blokadu ili gresku; blokada je prirodna uz semafor mesta),
  upis, signal(outputItems)
- izlazna nit (`outputBody`, systemLevel=true): vecna petlja
  wait(outputItems) -> uzmi znak -> PROZIVAJ bit spremnosti za slanje
  -> upisi u kontroler -> signal(outputSpace). sistemska je jer pise
  direktno u registre kontrolera (pdf: tela internih niti u s-modu)

### zasto je ovo bezbedno bez ikakvog zakljucavanja

- getc/putc rade U TRAPU: hardver je na ulasku ugasio prekide -
  prirodna kriticna sekcija
- izlazna nit radi u s-modu SA MASKIRANIM prekidima (sistemska nit se
  nikad ne spusta sret-om, a u jezgro se uslo sa SIE=0) - njen pristup
  baferu niko ne prekida; procesor ustupa jedino kad se BLOKIRA na
  praznom baferu
- prekidna rutina je i sama trap - atomska prema svima

### posledica: getc vise NE drzi procesor

stara console.lib je cekala znak drzeci procesor (pustala prekide pa
je tajmer preotimao - lekcija 08). nas getc nit uredno BLOKIRA: nit
ode iz svih redova, druge niti dobijaju procesor odmah, bez ikakvog
preotimanja. ugnjezdenih trapova vise prakticno nema (niko u jezgru ne
pusta prekide), ali dizajn "sepc/sstatus u lokalima" ostaje kljucan -
nosi promenu niti usred trapa (dispatch, blokada, preotimanje).

### gasenje sistema: drain

poslednje poruke testa stoje u izlaznom baferu - da main odmah upise
0x5555, nestale bi zajedno sa emulatorom. zato main pred gasenje vrti
`while (!CCB::outputEmpty()) thread_dispatch()` - ustupa procesor
izlaznoj niti dok ona ne posalje i poslednji znak.

### ko je "idle" nit?

kad SVE korisnicke niti spavaju (test 5!), neko mora biti spreman -
inace switchToNext panici "nema spremnih niti". kod nas je to SAM MAIN:
on se u petlji `while (!userMainDone) thread_dispatch()` nikad ne
blokira, pa je scheduler garantovano neprazan. pdf-ova "idle nit" nam
zato ne treba - main je igra besplatno.

## 3) PeriodicThread i Thread::sleep

- `Thread::sleep(t)` = time_sleep(t), stub konacno zamenjen
- `PeriodicThread::run()` (redefinicija POSTOJECEG virtuelnog run):
  `while (period > 0) { periodicActivation(); sleep(period); }`
- caka: pdf str. 11 ZABRANJUJE nova polja i nove virtuelne metode u
  ovim klasama (binarna kompatibilnost sa app.lib) - pa terminate()
  nema svoju zastavicu. resenje: period=0 je sentinel za kraj (period
  0 ionako nema smisla). redefinicija run-a NE menja raspored vtable-a
  (slot vec postoji) - zato je dozvoljena
- terminate() iz druge niti: tekuce spavanje se dovrsi, pa petlja pukne
  na proveri; terminate() iz same aktivacije: hvata ga if pre sleep-a

## zvanicni testovi 5 i 6

- test 5 (`ThreadSleep_C_API_test`): dve niti spavaju 10 i 20 otkucaja,
  po 5 puta ispisu "Hello 10/20 !". glavna test nit BUSY-ceka zavrsetak
  (`while (!(finished[0] && finished[1]))`) - radi samo zahvaljujuci
  preotimanju! ocekivan ritam: "Hello 10" duplo cesce od "Hello 20"
- test 6 (`ConsumerProducer_CPP_API_test`): tastatura + n proizvodjaca
  + potrosac nad BufferCPP; koristi Thread::sleep, getc, Console::putc
  - ceo zadatak 4 odjednom. ESC zavrsava test
- u test 6 fajlu uklonjen neiskorisceni brojac `i` iz ProducerKeyborad
  (zvanicni fajl pada na nas -Wall -Werror; logika netaknuta)

## pitanja za odbranu

1. zasto lista uspavanih cuva relativne razlike, a ne apsolutna vremena?
   sta je cena, a sta dobitak?
2. gde tacno spava nit koja je pozvala time_sleep? uporedi sa nitom
   blokiranom na semaforu - u cemu je jedina razlika?
3. zasto se u tajmerskoj grani prvo bude spavaci pa tek onda tick?
4. nabroj oba proizvodjac/potrosac para konzole i ko je u svakom paru ko.
5. zasto izlazni smer vozi NIT, a ulazni PREKIDNA RUTINA? (odgovor: znak
   sa tastature stize prekidom i mora se odmah pokupiti; slanje mozemo
   da odlozimo i prozivamo kad nama odgovara)
6. zasto getc/putc sme da blokira pozivaoca, a prekidna rutina ne sme
   nikad da blokira? sta prekidna rutina radi kad je ulazni bafer pun?
7. zasto pristupi baferima ne traze mutex? (tri konteksta, svi sa
   maskiranim prekidima)
8. zasto je izlazna nit sistemska (systemLevel=true)?
9. cemu drain petlja u main-u pred gasenje?
10. kako terminate() radi bez ijednog novog polja u PeriodicThread?
11. sta bi puklo da main ume da se blokira dok sve korisnicke niti
    spavaju? ko je nas "idle"?
