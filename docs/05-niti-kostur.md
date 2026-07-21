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

zasto par body + arg? body je "uloga" (sta nit radi), arg je "kostim" (sa cim
radi) - jedna ista funkcija moze da sluzi vise niti sa razlicitim podacima,
bez copy-paste tela. void* je univerzalni utikac: pokazuje na bilo sta, telo
ga kastuje nazad. potpis diktira pdf (thread_create(handle, start_routine, arg)).
vazno: createThread NISTA ne poziva - body i arg se samo ZAPAMTE u tcb-u,
a stvarni poziv `running->body(running->arg)` desi se tek pri prvom budjenju,
u threadWrapper-u. tcb je jedini most izmedju "zapamceno" i "pozvano"
(contextSwitch ne prenosi a-registre, pa argument do tela stize samo kroz tcb).

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

## sinhrona vs asinhrona promena konteksta

razlika je u jednoj reci: KO ODLUCUJE.

- **sinhrona**: nit SAMA pozove dispatch ("predajem smenu"). posto je dispatch
  obican poziv funkcije, kompajler po konvenciji vec zna da t/a registri ne
  prezivljavaju poziv - nista vazno i ne drzi u njima preko te tacke. zato je
  dovoljno rucno cuvati s0-s11 + ra + sp. ovo sad imamo.
- **asinhrona**: tajmer/prekid skida nit USRED BILO KOJE instrukcije, bez
  najave - nit mozda drzi poluizracunat rezultat u t3. mora se cuvati SVE:
  trap.S cuva t/a/ra na ulasku, contextSwitch doda s0-s11 - zajedno kompletan
  kontekst. ovo stize u zadatku 4 (preotimanje).

analogija: sinhrono = sam predas kasu kolegi (zapise se samo ono sto se
zvanicno predaje). asinhrono = sef te povuce sa kase usred kucanja racuna
(belezi se bas sve, i nedovrsena cifra na ekranu).

zasto asinhrona uopste treba? bez nje nit koja "zaboravi" dispatch drzi
procesor doveka - nema pravog time sharing-a.

## dokaz da radi: ceo flow naseg testa, korak po korak (sa kodom)

### glumci

nulta nit - `src/main.cpp`:

```cpp
// main postaje "nulta" nit: dobija svoj tcb da ima gde da se zamrzne
// kad prvi put ustupi procesor (kontekst mu se popuni pri prvom dispatch-u)
TCB::running = TCB::createThread(nullptr, nullptr);

userMain();
```

radnice i rezija - `src/userMain.cpp`:

```cpp
// dve niti koje se smenjuju: svaka ispise svoje slovo pa ustupi procesor
static void workerA(void*) {
    for (int i = 0; i < 5; i++) {
        kputs("A");
        TCB::dispatch();
    }
}
// workerB identican, ispisuje "B"

void userMain() {
    TCB* a = TCB::createThread(workerA, nullptr);
    TCB* b = TCB::createThread(workerB, nullptr);

    // main (nulta nit) vrti dispatch dok obe ne zavrse
    while (!a->isFinished() || !b->isFinished()) {
        TCB::dispatch();
    }
    kputs("\nobe niti zavrsile\n");
}
```

### rodjenje: falsifikat proslosti - `src/tcb.cpp`, createThread

```cpp
// bootstrap: falsifikuj proslost niti da izgleda kao da je "zaspala"
// na samom ulazu u threadWrapper. prvo budjenje (contextSwitch) ce:
// pokupiti 12 laznih s-registara sa steka, pa ret na threadWrapper.
uint64 top = (uint64)stack + DEFAULT_STACK_SIZE;   // stek raste ka nizim adresama
tcb->context.sp = top - 96;                        // mesto za 12 "s-registara"
uint64* fakeRegs = (uint64*)tcb->context.sp;
for (int i = 0; i < 12; i++) fakeRegs[i] = 0;      // nit krece cistih ruku
tcb->context.ra = (uint64)&threadWrapper;

// main-ova nulta nit (body == nullptr) se ne raspredjuje kroz red
if (body) Scheduler::put(tcb);
```

posle ovoga stek novorodjene niti izgleda ovako:

```
top (kraj alociranog prostora) ->  +----------------+
                                   | 12 x 0 (laznih |
                                   |  s-registara)  |
context.sp ------------------->    +----------------+
                                   |   prazno...    |
stack (pocetak alokacije) ---->    +----------------+
context.ra = &threadWrapper
```

### smena: ko koga i kako - `src/tcb.cpp`, dispatch

```cpp
void TCB::dispatch() {
    TCB* old = running;
    if (!old->finished) Scheduler::put(old);   // gotova nit se ne vraca u red

    TCB* next = Scheduler::get();
    if (!next) {
        // nema nijedne spremne niti, a tekuca je gotova: sistem nema sta da radi
        kputs("PANIC: nema spremnih niti\n");
        *(volatile int*)0x100000 = 0x5555;
    }

    running = next;
    contextSwitch(&old->context, &running->context);
    // odavde se nastavlja tek kad neko VRATI procesor staroj niti
}
```

### zamrzavanje/budjenje - `src/contextSwitch.S` (srz)

```asm
contextSwitch:
    addi sp, sp, -96       # mesto za 12 s-registara (12 x 8B)
    sd s0, 0(sp)
    ...                    # s1-s11 isto, redom
    sd s11, 88(sp)

    sd ra, 0(a0)           # stara nit: gde da nastavi kad se probudi
    sd sp, 8(a0)           # stara nit: rucka kofera        == zamrznuta

    ld ra, 0(a1)           # nova nit: odakle nastavlja
    ld sp, 8(a1)           # nova nit: njen stek            == budi se

    ld s0, 0(sp)
    ...                    # s1-s11 isto, redom
    ld s11, 88(sp)
    addi sp, sp, 96
    ret                    # skok na ra nove niti: usao kao stara, izasao kao nova
```

### porodiliste i pogrebnik - `src/tcb.cpp`, threadWrapper

```cpp
// prva funkcija u zivotu svake niti (u nju nas ubaci falsifikovani ra);
// kad se telo zavrsi, nit se uredno gasi i nikad vise ne dobija procesor
void TCB::threadWrapper() {
    running->body(running->arg);
    running->finished = true;
    dispatch();   // odavde nema povratka
}
```

### sad ceo film, potez po potez

pocetno stanje (posle createThread poziva):

```
running = main          A i B su novorodjene: context.ra = threadWrapper,
red     = [A, B]        na steku ih ceka 12 laznih nula za s-registre
```

prvi krug, potez po potez:

```
ko radi | sta se desi                                    | red POSLE    | izlaz
--------+------------------------------------------------+--------------+------
main    | dispatch: put(main), get->A, running=A         | [B, main]    |
        | contextSwitch(&main.ctx, &A.ctx)               |              |
        |   main ZAMRZNUT (ra = iza contextSwitch-a      |              |
        |   u dispatch-u, sp = njegov stek)              |              |
A       | PRVO BUDJENJE: ret skace na threadWrapper      |              |
        | wrapper zove workerA -> kputs("A")             |              | A
A       | dispatch: put(A), get->B, running=B            | [main, A]    |
        | contextSwitch(&A.ctx, &B.ctx)                  |              |
B       | PRVO BUDJENJE: wrapper -> workerB -> kputs("B")|              | B
B       | dispatch: put(B), get->main, running=main      | [A, B]       |
        | contextSwitch(&B.ctx, &main.ctx)               |              |
main    | BUDI SE tacno iza svog contextSwitch poziva,   |              |
        | vrati se iz dispatch-a u while petlju,         |              |
        | uslov: nisu gotove -> opet dispatch            |              |
```

posle prvog kruga red je opet [A, B] i sve se ponavlja: svaki krug doda "AB"
u izlaz. pet krugova = ABABABABAB.

gde koja nit "spava" dok ne radi? SVAKA parkirana nit je zamrznuta na tacno
jednom istom mestu: usred contextSwitch-a (ra joj pokazuje na instrukciju iza
poziva u dispatch-u). jedini izuzetak su novorodjene niti - njihov ra pokazuje
na threadWrapper. zato je budjenje uvek isto: ret na ra, i nit nastavlja kao
da se nista nije desilo.

smrt niti (posle 5. ispisa): workerA-jina for petlja se zavrsi, telo se
obicnim ret-om VRATI u wrapper (zato wrapper postoji!), wrapper: finished=true,
dispatch - a dispatch gotovu nit NE vraca u red. njen tcb vise niko nikad
ne get-uje: nit je mrtva. red se skrati, main i preziveli nastavljaju.

zanimljiv detalj za kraj: kad main ostane sam, dispatch radi put(main) pa
get->main - nit se "prebaci sama na sebe". contextSwitch tada sacuva pa odmah
ucita isti ra/sp: bezopasno, samo malo uzalud posla. kad while uslov konacno
padne (obe finished), main izadje iz petlje, ispise poruku i vrati se u main()
-> uredan halt.

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
