# 06 - niti kroz sistemske pozive (thread_create/exit/dispatch)

fajlovi: `src/riscv.cpp`, `src/syscall_c.cpp`, `h/syscall_c.hpp`,
`src/tcb.cpp`, `h/tcb.hpp`

## projektne odluke (moje, obrazlozene)

1. **grananje sistemskih poziva: switch/case** (pdf nudi i tabelu pokazivaca
   na funkcije). razlog: sve na jednom mestu, najlakse za citanje, debug i
   odbranu; kodovi poziva su razredjeni (0x01..0x42 sa rupama) pa bi tabela
   imala prazna mesta.
2. **alokacija objekata jezgra: dinamicka** preko MemoryAllocator-a (operator
   new/delete po klasi), umesto statickog niza pregradaka. razlog: pdf je zove
   "naprednije i fleksibilnije", nema vestackog limita broja niti/semafora;
   cena je moguca fragmentacija malih objekata - prihvatljivo.

## c api sloj: sta ko radi (pdf, abi poziv 0x11)

vazan detalj iz pdf-a: abi poziv 0x11 prima i POKAZIVAC NA STEK (a4) - stek
niti alocira C API sloj (kroz mem_alloc = jos jedan ecall!), ne jezgro:

```cpp
int thread_create(thread_t* handle, void (*start_routine)(void*), void* arg) {
    if (!handle || !start_routine) return -1;
    void* stackSpace = mem_alloc(DEFAULT_STACK_SIZE);   // 1. ecall (0x01)
    if (!stackSpace) return -2;
    // ... a0=0x11, a1=handle, a2=telo, a3=arg, a4=stek ... ecall  // 2. ecall
    int result = (int)code;
    if (result != 0) mem_free(stackSpace);   // nit nije nastala - vrati stek
    return result;
}
```

`thread_t` je "neprozirna rucka": `class _thread; typedef _thread* thread_t;` -
korisnik dobija pokazivac a ne zna sta je iza njega (iza je nas TCB).
jezgro upise rucku kroz `*(TCB**)a1 = tcb`.

## flow: thread_create(&a, workerA, nullptr) od pocetka do kraja

```
[korisnik]   thread_create(&a, workerA, 0)
[c api]      mem_alloc(DEFAULT_STACK_SIZE)  -> ecall 0x01 -> stek za novu nit
[c api]      a0=0x11, a1=&a, a2=workerA, a3=0, a4=stek -> ecall
[hardver]    sepc/scause/sstatus, skok na stvec
[trap.S]     sacuvaj 15 registara na stek POZIVAOCA
[handleSupervisorTrap] case 0x11: TCB::createThread(workerA, 0, stek)
[jezgro]     new TCB (operator new -> MemoryAllocator, BEZ ecall-a!)
             falsifikat: ra=threadWrapper, sp=vrh steka-96 (12 nula)
             Scheduler::put -> nit ceka u redu (jos NIJE dobila procesor!)
[handleSupervisorTrap] *(TCB**)a1 = tcb  (rucka korisniku), ret=0
[trap.S]     vrati registre, sret
[c api]      vrati 0 korisniku. nova nit ce PRVI PUT raditi tek kad je
             neciji dispatch izvuce iz reda.
```

## zamka 1: sepc i sstatus su DEO KONTEKSTA NITI

cim thread_dispatch ide kroz ecall, promena konteksta se desava USRED obrade
trapa. a sepc je hardverski globalan - jedan po procesoru:

```
nit A: ecall             sepc <- A-jina adresa
  handleSupervisorTrap -> dispatch -> A parkirana USRED handleSupervisorTrap-a
  nit B radi, uradi svoj ecall    sepc <- B-jina adresa   !!! prepisan
  A se budi, dovrsava svoj handleSupervisorTrap: sepc+=4; sret -> ODLETI NA B-JINU ADRESU
```

resenje (u handleSupervisorTrap): sepc i sstatus se NA ULAZU prepisu u lokalne
promenljive - a lokalne zive na steku TE niti, pa se parkiraju i bude s njom.
pred povratak se upisu nazad u csr registre: svako se vraca sa svojim.

```cpp
uint64 cause, sepc, sstatus;
asm volatile("csrr %0, scause"  : "=r"(cause));
asm volatile("csrr %0, sepc"    : "=r"(sepc));     // odmah u lokal!
asm volatile("csrr %0, sstatus" : "=r"(sstatus));
...
sepc += 4;                    // za ecall: u lokalnoj kopiji
switch (a0) { ... dispatch moze da parkira nit bas ovde ... }
...
asm volatile("csrw sstatus, %0" : : "r"(sstatus)); // pred povratak: nase nazad
asm volatile("csrw sepc, %0"    : : "r"(sepc));
```

## zamka 2: zombi mehanizam - ne seci granu na kojoj sedis

thread_exit treba da oslobodi stek i tcb gotove niti. ali jezgro se u tom
trenutku IZVRSAVA na tom steku (nas dizajn: kod jezgra radi na steku tekuce
niti), a contextSwitch bi odmah gurao s-registre na oslobodjenu memoriju.

resenje: umiruca nit se samo zabelezi (`zombie = old`), a cisti je PRVA
SLEDECA PROBUDJENA nit - sa svog, bezbednog steka:

```cpp
void TCB::dispatch() {
    TCB* old = running;
    if (!old->finished) Scheduler::put(old);
    else zombie = old;   // jos stojimo na njegovom steku - ciscenje kasnije!
    ...
    contextSwitch(&old->context, &running->context);
    // budjenje: sad smo na steku probudjene niti - bezbedno pocisti zombija
    reapZombie();
}

void TCB::threadWrapper() {
    reapZombie();   // i rodjenje je budjenje: pocisti eventualnog prethodnika
    ...
}
```

reapZombie se zove sa SVAKOG mesta budjenja (iza contextSwitch-a + ulaz u
wrapper), pa zombi nikad ne prezivi dva budjenja - nema curenja.

## thread_exit i thread_dispatch u jezgru

```cpp
case 0x12:   // thread_exit - odavde nema povratka za ovu nit
    TCB::running->setFinished(true);
    TCB::dispatch();
    break;
case 0x13:   // thread_dispatch
    TCB::dispatch();
    ret = 0;
    break;
```

thread_exit = "obelezi kraj + ustupi procesor": ista mehanika kao smrt kroz
wrapper. nit parkirana usred handleSupervisorTrap-a, finished, niko je vise ne budi,
prva sledeca probudjena nit je pocisti kao zombija.

## pitanja za odbranu

1. ko alocira stek nove niti i zasto (pdf abi 0x11)? koliko ecall-ova ima jedan thread_create?
2. sta je thread_t i zasto je "neproziran"?
3. zasto sepc mora u lokalnu promenljivu na ulazu u handleSupervisorTrap? sta bi puklo bez toga?
4. zasto gotova nit ne sme sama da oslobodi svoj stek? ko ga oslobadja i kada?
5. nova nit je kreirana - kada ce PRVI put dobiti procesor?
6. zasto se u handleSupervisorTrap sepc uvecava pre switch-a, a upisuje u csr tek na kraju?
