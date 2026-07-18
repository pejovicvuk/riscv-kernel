# 05 - niti: kostur (TCB + Scheduler)   [u izradi]

fajlovi: `h/tcb.hpp`, `src/tcb.cpp`, `h/scheduler.hpp`, `src/scheduler.cpp`

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
bool finished;    // da li je rekla thread_exit
TCB* next;        // za red cekanja (intruzivno ulancavanje)
static TCB* running;   // jedina nit koja trenutno radi ("na kasi")
```

zasto su ra + sp dovoljni za sliku? ostali registri se pre zamrzavanja spuste
NA STEK same niti, a sp pokazuje na taj stek. sp je rucka kofera: podignes nju,
sve ostalo visi okaceno o nju.

zasto `next` u samom TCB-u (intruzivno)? pdf preporucuje: bez posebnih kutijica
za listu -> nema dinamickih alokacija po ubacivanju, nema fragmentacije.
svaki cekac "drzi ruku na ramenu" sledeceg.

## zasto TCB ima svoj operator new/delete

globalni `new` ce kasnije biti preusmeren na `mem_alloc` -> a to je ecall.
kad bi JEZGRO usred obrade jednog ecall-a reklo `new TCB` -> ecall iz jezgra
koje vec obradjuje ecall = zmija guta svoj rep. zato klase jezgra imaju svoj
new/delete koji ide DIREKTNO na MemoryAllocator, bez ecall-a.

(c++ finta: `new TCB(...)` prvo pita nas operator new za sirovu memoriju,
pa sam pozove konstruktor na tom parcetu.)

## Scheduler - red ispred kase (fifo)

- niti koje CEKAJU procesor stoje u koloni; `running` NIJE u redu - on je na kasi
- `put(t)`: stani na kraj (ako je red prazan, ti si i prvi i poslednji)
- `get()`: skini prvog sa cela (ako si skinuo POSLEDNJEG, i tail mora na nullptr -
  klasicno mesto za bag u svakom redu ikad napisanom)

## flow: zivot niti (kako ce izgledati kad zavrsimo)

```
createThread(body, arg)  -> alociraj stek + TCB, namesti POCETNI kontekst [todo]
Scheduler::put(t)        -> nit ceka u redu
promena konteksta        -> sacuvaj sliku tekuce niti, ucitaj sliku sledece [todo]
telo se izvrsava         -> nit radi, povremeno thread_dispatch (ustupi procesor)
thread_exit              -> finished = true, nikad vise ne dobija procesor [todo]
```

## sledece (todo)

- [ ] contextSwitch: ~6 instrukcija asemblera gde se magija desava
- [ ] pocetni kontekst: kako "lazirati proslost" niti koja se prvi put budi
      (najveca mozgalica zadatka 2)
- [ ] wrapper oko tela niti koji na kraju zove thread_exit
- [ ] niti u korisnickom rezimu (sret sa SPP=0) - trazi ga javni test 7
- [ ] thread_create/exit/dispatch kroz abi + c api

## pitanja za odbranu (za sada)

1. sta sve cini "kontekst" niti i gde je sta uskladisteno?
2. zasto running nije u scheduler-ovom redu?
3. zasto jezgro ne sme da koristi obican (globalni) new?
4. sta bi puklo da dva TCB-a dele isti stek?
