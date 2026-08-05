# 10 - vodic kroz flowove: od korisnickog koda do jezgra i nazad

ovo je mapa za citanje koda. svaki flow je jedna prica: krece od linije
koju pise korisnik, prati je kroz sve slojeve do jezgra i nazad.
citaj flow po flow: otvori fajl iz koraka 1, procitaj naznacene linije,
predji na korak 2, itd. linije vaze za trenutno stanje koda - ako se
kod menja, drzi se imena funkcija.

preporucen redosled citanja: flowovi su poredjani tako da svaki koristi
znanje iz prethodnih. ne preskaci.

## mapa fajlova (ko je ko)

| sloj | fajl | uloga |
|------|------|-------|
| korisnicki program | `test/*.cpp`, `src/userMain.cpp` | zvanicni testovi; ne zna nista o jezgru, zna samo api |
| c++ api | `h/syscall_cpp.hpp`, `src/syscall_cpp.cpp` | klase Thread/Semaphore/Console - tanki omotaci oko c api-ja |
| new/delete | `src/_new.cpp` | globalni new/delete korisnickog sloja -> mem_alloc/mem_free |
| c api | `h/syscall_c.h`, `src/syscall_c.cpp` | funkcije koje pakuju argumente u registre i rade `ecall` |
| kapija | `src/trap.S` | jedini ulaz u jezgro (stvec pokazuje ovde); cuva/vraca registre |
| razvodnik | `src/riscv.cpp` | `handleSupervisorTrap`: cita scause, grana se po kodu poziva |
| jezgro-niti | `h/tcb.hpp`, `src/tcb.cpp` | TCB, threadWrapper/userWrapper, dispatch, zombi |
| jezgro-zamena | `src/contextSwitch.S` | zamrzni jednu nit, odmrzni drugu |
| jezgro-red | `h/scheduler.hpp`, `src/scheduler.cpp` | fifo red spremnih niti |
| jezgro-semafori | `h/scb.hpp`, `src/scb.cpp` | SCB: brojac + fifo red blokiranih |
| jezgro-memorija | `h/memoryAllocator.hpp`, `src/memoryAllocator.cpp` | slobodna lista, first-fit |
| jezgro-konzola | `h/ccb.hpp`, `src/ccb.cpp` | CCB: nasi baferi + izlazna nit (zadatak 4, lekcija 12) |
| start/kraj | `src/main.cpp` | podesavanje masine, nulta nit, CCB::init, userMain kao nit |

kljucna slika koju drzi ceo projekat: **korisnicki sloj i jezgro su u istom
adresnom prostoru** (nema memorijske zastite), ali granica privilegija
postoji - u jezgro se ulazi ISKLJUCIVO instrukcijom `ecall`, a iz jezgra
se izlazi ISKLJUCIVO instrukcijom `sret`. sve ostalo su obicni pozivi
funkcija unutar istog sloja.

---

## flow 1: boot - kako sistem uopste dodje do userMain

fajl: `src/main.cpp` (ceo, kratak je)

1. fakultetska biblioteka (hw.lib) podize masinu, ispise "xv6 kernel is
   booting" i pozove nas `main()` - u SISTEMSKOM rezimu.
2. `main.cpp` (csrw stvec) - u `stvec` se upisuje adresa `trapHandler`-a
   iz trap.S. od ovog trenutka svaki ecall/izuzetak/prekid skace TU i samo tu.
3. `main.cpp` (sie blok) - prekidi PO VRSTI u `sie` registru se UKLJUCUJU:
   konzola (seie, bit 9) mora da bude ziva jer console_handler na svaki
   njen prekid puni/prazni bafere console.lib (lekcija 08); tajmer (ssie,
   bit 1) je odmaskiran ali se za sada samo potvrdjuje - prava obrada je
   zadatak 4. zasto bas `sie`: on vazi i u korisnickom rezimu, gde se
   sstatus.SIE ignorise (lekcija 04/07).
4. `main.cpp` (sstatus blok) - `sstatus.SIE = 1`: da prekidi stizu i dok
   je main (s-mode) na procesoru; u-mode niti ovaj bit ne gledaju.
5. `main.cpp` - `MemoryAllocator::init()`: heap postaje jedan veliki
   slobodan blok.
6. `main.cpp` - main dobija svoj TCB ("nulta nit", systemLevel=true)
   sa PRAZNIM kontekstom i bez steka. zasto: kad main prvi put ustupi
   procesor, mora da postoji mesto gde ce se zamrznuti (flow 4).
7. `main.cpp` - pdf str. 4: main "pokrece NIT nad funkcijom userMain" -
   obicnim `thread_create` (ecall radi i iz s-moda!) nad omotacem
   `userMainWrapper`, pa se vrti u `while (!userMainDone) thread_dispatch()`
   i ustupa procesor dok korisnicki program ne zavrsi. meni testova time
   radi u U-MODU, kao i sav korisnicki kod.
   caka: kraj se ceka preko zastavice `userMainDone` koju omotac digne
   PRE thread_exit-a - ne preko rucke niti, jer tcb zavrsene niti pojede
   zombi ciscenje (flow 5), pa bi citanje rucke bilo use-after-free.
8. `main.cpp` - kad zastavica padne: upis 0x5555 na 0x100000 gasi emulator.

kljucna tacka: main NIJE posebna magija - posle koraka 6 on je obicna
nit medju nitima (uvek spreman, nikad blokiran), samo sto je prvi i sto
mu kontekst pise tek prvi dispatch.

---

## flow 2: anatomija sistemskog poziva - `mem_alloc` (najprostiji primer)

ovo je NAJVAZNIJI flow - svi ostali su varijacije. scenario: korisnicki
kod kaze `new BufferCPP(n)` ili direktno `mem_alloc(...)`.

fajlovi redom: `_new.cpp` -> `syscall_c.cpp` -> `trap.S` ->
`riscv.cpp` -> `memoryAllocator.cpp` -> nazad istim putem.

1. `src/_new.cpp:10-12` - globalni `operator new` samo prosledi u
   `mem_alloc(size)`. (ako je korisnik zvao mem_alloc direktno, preskoci.)
2. `src/syscall_c.cpp:4-19` - `mem_alloc`: bajtove zaokruzi navise na
   blokove (abi poziv 0x01 prima BLOKOVE); spakuje a0=0x01, a1=blokovi;
   `ecall`.
3. HARDVER (nema koda za citanje, samo znaj): ecall postavlja
   scause=8 (iz u-moda) ili 9 (iz s-moda), sepc=adresa samog ecall-a,
   sstatus.SPP=rezim iz kog se doslo, pc skace na stvec -> trapHandler.
4. `src/trap.S:11-26` - na stek tekuce niti spusti ra, t0-t6, a1-a7.
   zasto ne i a0: a0 ce poneti povratnu vrednost poziva - namerno se
   NE vraca staro stanje (lekcija 04 - bug koji nas je ujeo).
5. `src/trap.S:28` - `call handleSupervisorTrap`. registri a0..a4 u tom trenutku
   jos drze vrednosti koje je korisnik spakovao - pa ih c funkcija vidi
   kao svoje parametre. to je cela "magija" prenosa argumenata.
6. `src/riscv.cpp:13-19` - scause/sepc/sstatus se ODMAH citaju u
   lokalne promenljive. zasto lokalne: one zive na steku OVE niti; ako
   obrada promeni nit, globalne csr-ove ce gaziti tudji trapovi, a nase
   vrednosti mirno cekaju na nasem steku (flow 4 i 6 zive od ovoga).
7. `src/riscv.cpp:40-42` - grana za ecall: `sepc += 4` u LOKALNOJ
   kopiji - da se po povratku nastavi IZA ecall-a, ne na njemu.
8. `src/riscv.cpp:44-47` - `switch (a0)`, slucaj 0x01: poziv
   `MemoryAllocator::alloc(a1 * MEM_BLOCK_SIZE)`. procitaj i sam alokator
   (`src/memoryAllocator.cpp`): first-fit kroz slobodnu listu, heder u
   prvih 16B, ostatak bloka nazad u listu.
9. `src/riscv.cpp:114-116` - pred izlaz: nasi lokalni sstatus i
   sepc se VRACAJU u csr-ove; `return ret` stavlja rezultat u a0.
10. `src/trap.S:30-46` - vrati sve sacuvane registre (a0 NE - u njemu je
    rezultat), `sret`: pc=sepc (instrukcija iza ecall-a), rezim=SPP.
11. `src/syscall_c.cpp:18` - mem_alloc nastavlja iza ecall-a: u `code`
    (a0) je stigao pokazivac; cast i return korisniku.

kljucne tacke:
- ceo put je SINHRON: ista nit, isti stek, samo se privilegije menjaju.
- a0 je dvosmerno: nosi kod poziva unutra, rezultat napolje.
- sepc+=4 se desava u lokalu, upis u csr tek pred sret.

---

## flow 3: radjanje c++ niti - `new WorkerA()` + `start()` (test 2)

scenario: `test/Threads_CPP_API_test.cpp` (funkcija `Threads_CPP_API_test`,
pri dnu fajla): `threads[0] = new WorkerA(); threads[0]->start();`

fajlovi redom: test -> `syscall_cpp.cpp` -> `syscall_c.cpp` ->
`riscv.cpp` -> `tcb.cpp` -> `scheduler.cpp`.

1. test: `new WorkerA()` - operator new ide kroz ceo flow 2 (alokacija
   objekta u heap-u jezgra kroz ecall!), pa se izvrsi konstruktor:
   `WorkerA():Thread() {}`.
2. `src/syscall_cpp.cpp:13` - zasticeni `Thread()`: myHandle=nullptr,
   body=nullptr, arg=nullptr. NIT JOS NE POSTOJI - postoji samo objekat.
3. test: `threads[0]->start()`.
4. `src/syscall_cpp.cpp:22-24` - `start()` zove
   `thread_create(&myHandle, runWrapper, this)`. obrati paznju: kao telo
   se salje runWrapper, a kao argument this - odluka body-ili-run se
   odlaze za kasnije (flow 4, korak 7).
5. `src/syscall_c.cpp:33-54` - `thread_create`: PRVO sam alocira stek
   niti kroz `mem_alloc(DEFAULT_STACK_SIZE)` (to je poseban, ugnjezdeni
   prolaz kroz ceo flow 2!), pa spakuje a0=0x11, a1=&myHandle,
   a2=runWrapper, a3=this, a4=stek; `ecall`. (pdf abi: stek daje
   pozivalac, ne jezgro.)
6. `src/riscv.cpp:51-57` - slucaj 0x11: poziv
   `TCB::createThread(telo, arg, stek, systemLevel=false)` - false jer
   niti nastale syscall-om izvrsavaju telo u korisnickom rezimu.
7. `src/tcb.cpp:69-91` - `createThread`: `new TCB(...)` - PAZI, ovo je
   TCB-ov SOPSTVENI operator new (`tcb.cpp:14-16`) koji ide DIREKTNO na
   MemoryAllocator, bez ecall-a (jezgro ne sme ecall iz trapa - pregazio
   bi sopstveni sepc). zatim bootstrap prevara:
   - `context.sp = vrh steka - 96` (mesto za 12 laznih s-registara, nule)
   - `context.ra = &threadWrapper`
   - falsifikovana je "proslost": nit izgleda kao da je zaspala na ulazu
     u threadWrapper (flow 4 objasnjava zasto bas takav oblik).
8. `src/tcb.cpp:86` - `Scheduler::put(tcb)`: nit staje na kraj reda
   spremnih (`src/scheduler.cpp:8-16`).
9. `src/riscv.cpp:54` - `*(TCB**)a1 = tcb`: jezgro kroz pokazivac
   upise rucku pravo u `myHandle` objekta Thread. ret=0.
10. nazad kroz trap.S/sret u thread_create, pa u start(), pa u test.

kljucna tacka: posle start() nit SAMO STOJI U REDU. nece se izvrsiti ni
jedna njena instrukcija dok neko ne pozove dispatch (flow 4).

---

## flow 4: dispatch - zamena niti + prvo budjenje nove niti

ovo je srce projekta. scenario: nit A (recimo main/nulta) zove
`thread_dispatch()` ili `Thread::dispatch()`, a iz reda izlazi svez
WorkerA iz flowa 3.

fajlovi redom: `syscall_cpp.cpp` -> `syscall_c.cpp` -> `riscv.cpp`
-> `tcb.cpp` -> `contextSwitch.S` -> `tcb.cpp` (threadWrapper) ->
`syscall_cpp.cpp` (runWrapper) -> test (run()).

deo 1 - nit A tone:

1. `src/syscall_cpp.cpp:37-39` - `Thread::dispatch()` -> `thread_dispatch()`.
2. `src/syscall_c.cpp:62-65` - a0=0x13, `ecall` -> trap.S sacuva
   registre nita A NA NJEN STEK (flow 2, korak 4).
3. `src/riscv.cpp:62-65` - slucaj 0x13: `TCB::dispatch()`.
   zapamti: sepc/sstatus nita A su vec bezbedni u LOKALIMA handleSupervisorTrap-a,
   na steku nita A.
4. `src/tcb.cpp:111-115` - `dispatch()`: nit A nije gotova ->
   `Scheduler::put(running)` (A staje na KRAJ reda spremnih), pa
   `switchToNext()`.
5. `src/tcb.cpp:95-105` - `switchToNext()`: old=A, next=`Scheduler::get()`
   (recimo WorkerA); ako nema nikog spremnog - panika (deadlock);
   `running = next`; `contextSwitch(&old->context, &running->context)`.
6. `src/contextSwitch.S:15-30` - prva polovina, jos smo nit A:
   12 s-registara na stek nita A; `ra` (adresa POVRATKA u switchToNext,
   linija iza poziva contextSwitch) i `sp` u A-ov TCB context.
   NIT A JE ZAMRZNUTA: sve sto jeste - visi o dva broja u TCB-u.

deo 2 - nit WorkerA izranja (prvi put u zivotu):

7. `src/contextSwitch.S:32-48` - druga polovina, postajemo WorkerA:
   ra i sp se ucitaju iz WorkerA context-a - ra=&threadWrapper (falsifikat
   iz flowa 3!), sp=vrh njegovog steka-96; 12 "s-registara" (nule) se
   pokupi sa steka; `ret` -> skok na threadWrapper. usli smo u funkciju
   kao nit A, izasli kao WorkerA - to je cela promena konteksta.
8. `src/tcb.cpp:40-58` - `threadWrapper` (JOS U SISTEMSKOM rezimu - u
   trap smo usli s-modom trap handlera):
   - `reapZombie()`: rodjenje je i budjenje - pocisti eventualnog mrtvaca
   - systemLevel je false -> priprema spusta u u-mode: sepc=&userWrapper,
     sstatus.SPP=0, pa `sret`. sret je JEDINA silazna kapija.
9. `src/tcb.cpp:63-67` - `userWrapper`, SAD U KORISNICKOM rezimu:
   `running->body(running->arg)` - a body je runWrapper, arg je this
   (tako smo poslali u flowu 3). tcb sme da se CITA iz u-moda: isti
   adresni prostor, granica je u instrukcijama, ne u memoriji.
10. `src/syscall_cpp.cpp:28-35` - `runWrapper(this)`: body je nullptr
    (zasticeni konstruktor) -> `self->run()` - virtuelni poziv koji
    zavrsi u `WorkerA::run()` u testu. da je Thread pravljen sa
    pokazivacem na funkciju, body bi imao prednost (pravilo iz pdf-a).
11. test: `run()` radi telo; svako `thread_dispatch()` u njemu ponavlja
    ceo ovaj flow - WorkerA na kraj reda, sledeci iz reda na procesor.

deo 3 - sta se desi kad nit A kasnije dodje na red:

12. neka nit uradi dispatch i Scheduler::get() vrati A. contextSwitch
    ucita A-ove ra/sp -> `ret` NE vodi u threadWrapper nego NAZAD u
    `switchToNext`, tacno iza poziva contextSwitch (`tcb.cpp:106-107`).
13. `reapZombie()` - budjenje je uvek mesto ciscenja.
14. povratak uz A-ov stek: switchToNext -> TCB::dispatch -> handleSupervisorTrap
    slucaj 0x13 -> `riscv.cpp:114-116` upisuje A-ove LOKALNE
    sepc/sstatus (koji su sve vreme cekali na A-ovom steku!) -> trap.S
    vraca A-ove registre -> `sret` -> nit A nastavlja iza svog ecall-a
    u thread_dispatch, kao da se nista nije desilo.

kljucne tacke:
- svaka nit koja ne radi je zamrznuta na TACNO jednom od dva mesta:
  (a) usred switchToNext, iza poziva contextSwitch, sa celim lancem
  ecall->handleSupervisorTrap->dispatch na svom steku, ili (b) kao svez falsifikat
  koji pokazuje na threadWrapper.
- zato lokalni sepc/sstatus rade: parkirani su na steku niti i putuju
  s njom kroz zamrzavanje.

---

## flow 5: smrt niti - run() se vraca

scenario: WorkerA::run() zavrsi poslednju liniju.

fajlovi redom: test -> `syscall_cpp.cpp` -> `tcb.cpp` -> `syscall_c.cpp`
-> `riscv.cpp` -> `tcb.cpp`.

1. `run()` se vrati -> vracamo se u `runWrapper` (`syscall_cpp.cpp:35`)
   -> on se vrati u `userWrapper` (`tcb.cpp:64`).
2. `src/tcb.cpp:65` - `thread_exit()`: iz u-moda NEMA drugog puta u
   jezgro osim ecall-a. (petlja `for(;;)` ispod je osiguranje - dotle
   nikad ne dolazi.)
3. `src/syscall_c.cpp:56-60` - a0=0x12, `ecall`.
4. `src/riscv.cpp:62-65` - slucaj 0x12:
   `running->setFinished(true)` pa `TCB::dispatch()` - odavde za ovu nit
   nema povratka.
5. `src/tcb.cpp:111-115` - dispatch vidi finished=true: nit NE ide u
   scheduler nego u `zombie`. zasto ne oslobodimo odmah: JOS STOJIMO NA
   NJENOM STEKU - oslobodio bi se pod pod nogama.
6. `switchToNext()` prebaci na sledecu spremnu nit; PRVA STVAR koju
   probudjena nit uradi je `reapZombie()` (`tcb.cpp:107` ili
   `tcb.cpp:41`) - sa SVOG, bezbednog steka oslobodi mrtvacev stek
   (`MemoryAllocator::free`) i TCB (`delete`).
7. objekat WorkerA (c++ sloj) zivi i dalje! njega brise tek testov
   `delete threads[i]` - obican mem_free kroz flow 2; nas ~Thread je
   prazan jer je jezgro vec pocistilo sve svoje (projektna odluka).

kljucna tacka: razdvojene su tri smrti - (1) telo gotovo (finished),
(2) jezgro oslobodilo stek+TCB (zombi/reap), (3) korisnik obrisao
Thread objekat (delete). tri razlicita trenutka, tri razlicita vlasnika.

---

## flow 6: semafor - blokiranje i budjenje (test 4)

scenario: potrosac zove `buffer->get()` na praznom baferu, pa ga
proizvodjac kasnije probudi sa `put()`. c++ verzija ide kroz klasu
Semaphore, c verzija direktno kroz sem_wait - jezgro je isto.

fajlovi redom: `test/buffer_CPP_API.cpp` -> `syscall_cpp.cpp` ->
`syscall_c.cpp` -> `riscv.cpp` -> `scb.cpp` -> `tcb.cpp` ->
`contextSwitch.S` -> (druga nit) -> nazad.

deo 1 - potrosac tone u san:

1. `test/buffer_CPP_API.cpp` - `get()` prvo `itemAvailable->wait()`.
2. `src/syscall_cpp.cpp:63-65` - `Semaphore::wait()` -> `sem_wait(myHandle)`.
3. `src/syscall_c.cpp:83-88` - a0=0x23, a1=rucka, `ecall`.
4. `src/riscv.cpp:79-81` - slucaj 0x23: `((SCB*)a1)->wait(1)`.
5. `src/scb.cpp:36-51` - `SCB::wait(1)`: value je 0 (bafer prazan) ->
   nema prolaza. nit se upisuje u red OVOG semafora (`enqueue(self)`,
   blockResult=0, pendingN=1) i zove `TCB::switchToNext()`. PAZI:
   nit NE ide u scheduler - za nju sada zna samo red ovog semafora.
6. `switchToNext` + `contextSwitch` zamrznu potrosaca TACNO TU - usred
   SCB::wait. na njegovom steku ceka cela kula: userov poziv -> ecall
   okvir (trap.S) -> handleSupervisorTrap okvir (sa NJEGOVIM sepc/sstatus u
   lokalima!) -> wait okvir -> switchToNext okvir -> 12 s-registara.
   procesor dobija sledeca spremna nit.

deo 2 - proizvodjac ga budi:

7. proizvodjac: `put()` -> `itemAvailable->signal()` -> ecall 0x24 ->
   `src/riscv.cpp:82-84` -> `SCB::signal(1)`.
8. `src/scb.cpp:53-65` - `signal`: value += 1; petlja: dok na celu reda
   ima cekaca ciji pendingN staje u value - `dequeue()`, value -=
   pendingN, blockResult=0, `Scheduler::put(t)`. potrosac je sada
   SPREMAN (u scheduleru), ali jos ne radi. fifo bez preskakanja: ako
   celo drzi cekac sa velikim n, niko iza ne prolazi.
9. proizvodjac se normalno vrati iz svog ecall-a i nastavi.

deo 3 - potrosac se budi:

10. kad dodje na red (neciji dispatch), contextSwitch ga odmrzne: `ret`
    vodi nazad u switchToNext (`tcb.cpp:106`), reapZombie, povratak u
    `SCB::wait` (`scb.cpp:50`) - i wait vrati `self->blockResult` (0).
11. uz stek: handleSupervisorTrap upise NJEGOVE lokalne sepc/sstatus, trap.S,
    sret -> potrosac nastavlja iza ecall-a u sem_wait, dobija 0,
    `Semaphore::wait()` vrati 0, `get()` nastavlja - uzima podatak.

kljucna tacka: blokirana nit spava USRED KODA JEZGRA (u SCB::wait), a ne
"negde apstraktno". budjenje je samo nastavak tog istog poziva - zato je
povratna vrednost blockResult tako prirodna: close() je postavi na -1 i
isti taj povratak javi niti da je cekala dzabe.

## flow 6b: brisanje semafora - `delete waitForAll` (kraj testa 4)

1. test: `delete waitForAll` - PRVO se izvrsi destruktor, TEK ONDA
   oslobadjanje memorije objekta.
2. `src/syscall_cpp.cpp:59-61` - `~Semaphore()`: `sem_close(myHandle)`
   -> ecall 0x22.
3. `src/riscv.cpp:72-78` - slucaj 0x22: `sem->close()` pa
   `delete sem` (SCB-ov delete, direktno na MemoryAllocator).
4. `src/scb.cpp:67-75` - `close()`: sve cekace probudi sa
   blockResult=-1 i vrati u scheduler - njihov wait ce vratiti gresku
   (vidi flow 6, korak 10).
5. nazad u test: operator delete oslobodi sam Semaphore objekat
   (mem_free, flow 2).

---

## flow 7: konzola - getc/putc kroz NASE bafere (CCB, zadatak 4)

scenario: meni testova ceka tvoj unos; printString ispisuje tekst.
(istorija: prvo rucni polling - pogresno; pa console.lib - 20p verzija,
lekcija 08; sad SVOJA konzola - zadatak 4, lekcija 12.)

ulazni smer (getc):

1. `test/printing.cpp` / meni - `getc()` -> a0=0x41, ecall.
2. `src/riscv.cpp` (case 0x41) -> `CCB::getc()`: `wait(inputItems)`.
   bafer prazan -> nit BLOKIRA bas tu, usred jezgra, identicno kao na
   semaforu (flow 6) - njeni sepc/sstatus cekaju u lokalima na njenom
   steku. procesor odmah dobija druga spremna nit.
3. pritisak tastera -> konzolni prekid (top=1, code=9) -> trap ->
   `CCB::handleInterrupt()`: MI radimo `plic_claim()`, pokupimo znakove
   iz kontrolera u ulazni bafer dok ih ima, `signal(inputItems)` po
   znaku (budi cekaca!), `plic_complete()`.
4. blokirana nit dodje na red -> nastavi iz wait-a, uzme znak sa head-a,
   vrati ga kroz a0 -> sret -> korisnik dobio karakter.

izlazni smer (putc):

1. `putc(c)` -> a0=0x42, a1=znak, ecall -> `CCB::putc`.
2. `wait(outputSpace)` - pun bafer blokira POZIVAOCA dok se ne oslobodi
   mesto; inace odmah: znak na tail, `signal(outputItems)`.
3. IZLAZNA NIT JEZGRA (sistemska, rodjena u `CCB::init`) zivi u petlji:
   `wait(outputItems)` (prazan bafer = spava) -> uzme znak sa head-a ->
   PROZIVA bit spremnosti kontrolera -> upise u CONSOLE_TX_DATA ->
   `signal(outputSpace)`.
4. pred gasenje: main vrti `while (!CCB::outputEmpty()) thread_dispatch()`
   da izlazna nit isprazni bafer - inace poslednje poruke nestaju.

kljucne tacke:
- konzola je dva odvojena proizvodjac/potrosac para: ulaz (prekidna
  rutina proizvodi, getc trosi) i izlaz (putc proizvodi, nit jezgra trosi).
- getc vise NE drzi procesor dok ceka - nit uredno spava u redu semafora;
  za kontinualan tok testova 3/4 vise nije presudno preotimanje.
- plic_claim/plic_complete sada zovemo MI (u CCB::handleInterrupt) -
  console_handler vise ne postoji u projektu.
- nista od ovoga ne trazi mutex: getc/putc rade u trapu (prekidi
  maskirani), izlazna nit radi u s-modu sa maskiranim prekidima, a
  prekidna rutina je i sama trap - sva tri konteksta su atomska.

---

## kontrolna pitanja (kad prodjes sve flowove)

1. zasto trap.S ne cuva a0, i sta bi puklo da ga cuva i vraca?
2. u kom trenutku i u kojoj promenljivoj zivi sepc niti koja spava na
   semaforu? sta bi poslo po zlu da je sepc samo procitan pred sret?
3. nabroj tacna dva "oblika" u kojima zamrznuta nit moze da postoji.
4. zasto nit koja zavrsava ne sme sama da oslobodi svoj stek, i ko ga
   oslobadja umesto nje?
5. kroz koje sve ecall-ove prodje JEDAN poziv `threads[0]->start()`?
   (pazi: ima ih vise od jednog.)
6. sta tacno vidi `runWrapper` kad je Thread napravljen zasticenim
   konstruktorom, a sta kad je napravljen sa pokazivacem na funkciju?
7. zasto TCB i SCB imaju sopstvene operator new/delete umesto da koriste
   globalne iz _new.cpp?
8. objasni put karaktera od pritiska tastera do povratka iz getc - kroz
   koje bafere prolazi i ko ga prebacuje na svakom koraku?
9. sta se desi kad nit pozove putc a izlazni bafer je pun? gde tacno
   spava i ko je budi?
10. zasto main ceka kraj userMain-a preko zastavice, a ne preko rucke niti?
