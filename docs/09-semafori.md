# 09 - semafori (zadatak 3)

fajlovi: `h/scb.hpp`, `src/scb.cpp`, izmene u `h/tcb.hpp`, `src/tcb.cpp`,
`src/riscv.cpp` (0x21-0x26), `h/syscall_c.h`, `src/syscall_c.cpp`

## ideja u jednoj recenici

semafor je brojac slobodnih "mesta" + fifo red niti koje cekaju ispred rampe;
wait = udji ili stani u red i zaspi, signal = pusti prvog iz reda (ili
zabelezi slobodno mesto), close = probudi sve uz gresku.

## projektne odluke (moje)

1. **blokirane niti se ulancavaju istim TCB::next pokazivacem** kao u
   scheduleru. bezbedno zbog invarijante: nit je u svakom trenutku u NAJVISE
   jednom redu (radi / spremna u scheduleru / ceka na tacno jednom semaforu).
2. **value nikad ne ide u minus**: wait prolazi samo ako ima mesta, inace u
   red; signal prvo pokusa da pusti cekaca, tek onda uvecava. citljivije, i
   kljucno - sem_wait_n (n jedinica) se prirodno uklapa (provera value >= n).
3. **unifikacija**: obican wait/signal je specijalan slucaj wait(n)/signal(n)
   sa n=1 - jedan mehanizam pokriva pozive 0x23/0x24 i 0x25/0x26.

## trece stanje niti: BLOKIRANA

do sada je nit bila ili NA PROCESORU ili SPREMNA (schedulerov red). sad:

```
       dispatch/preotimanje
RADI  <------------------->  SPREMNA (schedulerov red)
  |                             ^
  | sem_wait (nema mesta)       | sem_signal / sem_close
  v                             |
BLOKIRANA (red TOG semafora) ---+
```

blokirana nit NIJE u scheduleru - za nju zna samo red semafora na kom ceka.
zato je uveden `TCB::switchToNext()`: "predji na sledeceg BEZ vracanja mene
u spremne" - pozivalac je vec smestio nit tamo gde joj je mesto.
dispatch je sada samo: put(running) + switchToNext().

## flow: sem_wait koji blokira, pa sem_signal koji budi

```
nit A: sem_wait(s)  -> ecall 0x23 -> SCB::wait(1)
       value == 0   -> A.blockResult=0, A.pendingN=1
                    -> enqueue(A) u RED SEMAFORA (ne scheduler!)
                    -> switchToNext(): A parkirana USRED handleSupervisorTrap-a
   ... rade druge niti ...
nit B: sem_signal(s) -> ecall 0x24 -> SCB::signal(1)
       value += 1; head(=A).pendingN(=1) <= value
                    -> dequeue(A), value -= 1, Scheduler::put(A)
       (B nastavlja - signal NE preotima procesor!)
   ... A dodje na red kod schedulera ...
nit A: budi se iza switchToNext, wait vraca A.blockResult = 0
       -> handleSupervisorTrap vraca 0 -> A-jin sem_wait vratio 0. legalno prosla.
```

kod (srz scb.cpp):

```cpp
int SCB::wait(unsigned n) {
    if (value >= n) { value -= n; return 0; }
    TCB* self = TCB::running;
    self->blockResult = 0;
    self->pendingN = n;
    enqueue(self);
    TCB::switchToNext();
    return self->blockResult;   // 0 = signal; negativno = close
}

int SCB::signal(unsigned n) {
    value += n;
    while (head && value >= head->pendingN) {   // fifo, bez preskakanja
        TCB* t = dequeue();
        value -= t->pendingN;
        t->blockResult = 0;
        Scheduler::put(t);
    }
    return 0;
}
```

## sem_close: budjenje sa greskom

pdf: sve niti koje cekaju se deblokiraju, a njihov wait vraca GRESKU.
mehanizam: per-nit polje `blockResult` - close ga postavi na -1 pre
Scheduler::put, pa svaka probudjena nit iz svog wait-a vrati -1 svom
pozivaocu. posle deblokiranja scb se brise (delete -> MemoryAllocator).

## fifo bez preskakanja (wait_n politika)

ako celo reda ceka 5 jedinica a value je 3, NIKO ne prolazi - ni cekac iza
njega kome treba 1. svesna odluka: strog fifo znaci da veliki zahtev nikad
ne gladuje. alternativa (propustanje manjih) bi bila brza ali bi veliki
zahtev mogao vecno da ceka.

## uvezeni testovi

test/ dopunjen: ConsumerProducer_C_API_test.{hpp,cpp} + buffer.{hpp,cpp}
(ograniceni bafer nad 4 semafora: itemAvailable, spaceAvailable, 2 mutexa).
userMain: LEVEL_3 = 1, case 3 aktivan. test 3 je INTERAKTIVAN: unosi se
broj proizvodjaca i kapacitet bafera, pa se kuca tekst; ESC zavrsava.

## pitanja za odbranu

1. koja su tri stanja niti i ko "zna" za nit u svakom od njih?
2. zasto je bezbedno da semafor koristi isti next pokazivac kao scheduler?
3. zasto signal ne preotima procesor odmah (probudjena nit ide u red, ne na cpu)?
4. kako probudjena nit "sazna" da li je pustena signalom ili ubijena close-om?
5. gde tacno spava nit blokirana na semaforu? (mesto u kodu!)
6. sta bi se desilo da wait vrati blockResult PRE switchToNext poziva?
