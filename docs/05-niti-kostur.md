# 05 - niti: TCB, Scheduler i promena konteksta

fajlovi: `h/tcb.hpp`, `src/tcb.cpp`, `h/scheduler.hpp`, `src/scheduler.cpp`,
`src/contextSwitch.S`

## sta je nit, fizicki

procesor moze da "zamrzne" program usred posla - kao pauza na filmu.
da bi kasnije nastavio tacno gde je stao, mora da upamti samo dve stvari:

1. **njegov stek** - lokalne promenljive + zapamceno "ko me je pozvao"
2. **sliku registara** - gde je stao (ra), vrh steka (sp), vrednosti u rukama

nit = sopstveni stek + ta zamrznuta slika + malo knjigovodstva. nista vise.
"pet niti" = pet stekova i pet slika, a JEDAN procesor skace sa slike na sliku
tako brzo da izgleda kao da radi pet stvari odjednom.

## TCB - licna karta niti

```cpp
Body body;        // sta nit radi u zivotu: funkcija
void* arg;        // argument te funkcije
uint64* stack;    // gde stanuje: njen privatni stek (pamtimo za oslobadjanje)
Context context;  // zamrznuta slika: SAMO ra + sp
bool finished;    // da li je zavrsila
TCB* next;        // za red cekanja (intruzivno ulancavanje)
static TCB* running;   // jedina nit koja trenutno radi ("na kasi")
```

zasto su ra + sp dovoljni za sliku? ostali registri se pre zamrzavanja spuste
NA STEK same niti, a sp pokazuje na taj stek. sp je rucka kofera: podignes nju,
sve ostalo visi okaceno o nju.

zasto `next` u samom TCB-u (intruzivno)? pdf preporucuje: bez posebnih kutijica
za listu -> nema dinamickih alokacija po ubacivanju, nema fragmentacije.
svaki cekac "drzi ruku na ramenu" sledeceg.

zasto TCB ima svoj operator new/delete? hardver ima JEDAN sepc (papiric "gde
sam stao"). kad bi jezgro usred obrade jednog ecall-a samo izvrsilo ecall
(globalni new -> mem_alloc -> ecall), sepc bi bio PREPISAN i povratak korisniku
zauvek izgubljen. zato klase jezgra alociraju direktno preko MemoryAllocator-a,
obicnim pozivom funkcije. (c++ finta: `new TCB(...)` prvo pita nas operator new
za sirovu memoriju, pa sam pozove konstruktor na tom parcetu.)

## Scheduler - red ispred kase (fifo)

- niti koje CEKAJU procesor stoje u koloni; `running` NIJE u redu - nit je u
  svakom trenutku ILI na procesoru ILI u redu, nikad oboje (inace bi je get()
  izvukao dok vec radi -> dve izvrsne tacke na istom steku)
- `put(t)`: stani na kraj (ako je red prazan, ti si i prvi i poslednji)
- `get()`: skini prvog sa cela; ako si skinuo POSLEDNJEG, i tail mora na nullptr!
  inace tail pokazuje na "duha": sledeci put() upisuje u tudj tcb, head ostaje
  nullptr, nova nit izgubljena zauvek

## contextSwitch - magija od 20 instrukcija (contextSwitch.S)

```
nit A zove dispatch()
  1. A stane u red (ako nije gotova)
  2. uzmi sledecu iz reda -> B, running = B
  3. contextSwitch(&A.context, &B.context):
       spusti A-jne s0-s11 na A-jin stek     (kofer se pakuje)
       A.ra <- "gde sam stala" = povratak iz contextSwitch
       A.sp <- vrh A-jinog steka             (rucka kofera)   == A ZAMRZNUTA
       ra <- B.ra, sp <- B.sp                                 == B SE BUDI
       pokupi B-jne s0-s11 sa B-jinog steka  (kofer se raspakuje)
       ret -> skok na B.ra = tacno tamo gde je B nekad stala
```

kljucno: contextSwitch UDJE kao A, a IZADJE kao B. poziv za nit A se "smrzne"
na tom mestu; kad je neko kasnije probudi, A nastavlja tacno iza poziva.

zasto se cuvaju bas s0-s11 (+ra +sp)?
- t/a registre je kompajler vec resio: kod sinhronog poziva (dispatch je obicna
  funkcija!) pozivalac NE ocekuje da t/a prezive - konvencija poziva
- s registre pozvana funkcija MORA da ocuva - a contextSwitch pusta DRUGU nit
  da ih gazi - zato ih rucno spustamo na stek niti pre zamrzavanja
- kod ASINHRONOG preotimanja (zadatak 4) prekid pada bilo gde -> tamo se mora
  cuvati SVE (to vec radi trap.S za caller-saved deo)

## bootstrap - kako se radja nit (najveca mozgalica)

problem: contextSwitch "budi" nit tamo gde je stala. ali nova nit NIGDE nije
stala - nikad nije ni zivela! resenje: **falsifikujemo joj proslost** u
createThread - namestimo kontekst kao da je "zaspala" na ulazu u threadWrapper:

```
context.ra = adresa threadWrapper-a   "kad se probudis, krenula si u wrapper"
context.sp = vrh steka - 96           12 laznih s-registara (nule) ceka na steku
```

prvo budjenje: contextSwitch ucita ra/sp, pokupi 12 nula u s-registre, ret ->
nit POCNE DA ZIVI u wrapper-u.

threadWrapper = prva funkcija u zivotu svake niti:
```cpp
running->body(running->arg);   // odradi zivot
running->finished = true;      // obelezi kraj
dispatch();                    // ustupi procesor - odavde nema povratka
```
wrapper garantuje: iz tela se nikad ne "ispada" u nistavilo, i gotova nit se
vise nikad ne vraca u red (dispatch je ne put-uje).

main je "nulta nit": dobije svoj tcb (body=nullptr, ne ide u red) cisto da ima
gde da se zamrzne kad prvi put ustupi procesor.

## dokaz da radi

test: main + workerA + workerB; a i b ispisuju svoje slovo pa dispatch, main
cuti i vrti dispatch dok obe ne zavrse. izlaz:

```
ABABABABAB
obe niti zavrsile
```

tacno naizmenicno = tri niti dele procesor, svaka se budi gde je stala,
deset puta zaredom, uredan kraj.

## sledece (todo)

- [ ] thread_create/exit/dispatch kao sistemski pozivi (0x11/0x12/0x13) + c api
- [ ] oslobadjanje tcb-a i steka gotove niti (thread_exit)
- [ ] userMain kao prava nit
- [ ] niti u korisnickom rezimu (sret sa SPP=0) - trazi ga javni test 7;
      maska se tada seli iz sstatus.SIE u sie registar
- [ ] semafori (zadatak 3)

## pitanja za odbranu

1. sta sve cini "kontekst" niti i gde je sta uskladisteno u trenutku dok nit ne radi?
2. objasni recenicu "contextSwitch udje kao jedna nit a izadje kao druga"
3. zasto se u contextSwitch cuvaju bas s0-s11, a ne i t/a registri?
4. kako nova nit dobije "proslost"? sta tacno stoji u njenom kontekstu pre prvog budjenja?
5. cemu sluzi threadWrapper? sta bi se desilo bez njega?
6. zasto gotova nit ne sme nazad u red? ko je poslednji put-uje i ko je nikad vise ne get-uje?
7. zasto main mora da ima svoj tcb?
