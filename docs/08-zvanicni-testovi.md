# 08 - zvanicni testovi + konzola kroz console.lib

fajlovi: `test/` (zvanicni fajlovi), `src/userMain.cpp` (zvanicni meni,
prilagodjen), `h/syscall_c.h` (preimenovan sa .hpp), `src/riscv.cpp`
(case 0x41/0x42 + grana za konzolni prekid), `src/syscall_c.cpp` (getc/putc),
`lib/console.h` (dato: __getc, __putc, console_handler)

## sta je uvezeno i zasto bas to

u `test/` su za sada SAMO fajlovi za testove koje mozemo da pokrenemo:
printing.{hpp,cpp}, lock.S, Threads_C_API_test.{hpp,cpp},
System_Mode_test.{hpp,cpp}. ostali (semafori, sleep, cpp api) se dodaju
kad stigne njihova funkcionalnost - NE ranije, jer makefile kompajlira
SVE .cpp fajlove u projektu (find . -name "*.cpp"), pa bi test koji zove
sem_open pravio "undefined reference" na linkovanju.

administrativa:
- nas header preimenovan u `syscall_c.h` - testovi ga tako include-uju
- nas stari userMain zamenjen zvanicnim menijem (LEVEL_1/2 = 1, 3/4 = 0);
  todo markeri pokazuju sta se vraca kad stignu cpp api / semafori / zadatak 4
- posle preimenovanja headera OBAVEZNO `make clean` (stari .d fajlovi u
  build/ pamte zavisnost na obrisani .hpp)

## konzola kroz console.lib (ispravka: prvo smo pogresno radili polling)

ISTORIJA (vazno za odbranu): prva verzija getc/putc je bila rucni polling
nad CONSOLE_STATUS/RX/TX registrima, sa svim prekidima maskiranim. testovi
su prolazili, ali je to bilo POGRESNO za 20p verziju - pdf str. 31 kaze:
ko ne radi zadatak 4, DUZAN je da koristi datu biblioteku `console.lib`
(funkcije `__getc`/`__putc`) i da iz prekidne rutine zove `console_handler`
na konzolni prekid. sopstveni getc/putc sa baferima je tek deo zadatka 4
(vidi bodovnu tabelu, str. 30).

kako sada radi (flow):

1. syscall 0x41 -> `ret = __getc()`: biblioteka gleda SVOJ ulazni bafer;
   ako je prazan, CEKA - ali dok ceka SAMA privremeno dozvoli prekide
   (pdf: "ove funkcije u toku svog izvrsavanja mogu dozvoliti prekide")
2. pritisak tastera -> konzolni prekid (scause bnt=1, kod 9) -> nas
   handleSupervisorTrap -> grana code==9 -> `console_handler()` - on SAM odradi
   plic_claim/plic_complete (provereno u simbolima biblioteke!) i prebaci
   znakove kontroler->ulazni bafer / izlazni bafer->kontroler
3. povratak u __getc koji sada ima znak i vrati ga
4. syscall 0x42 -> `__putc(znak)` - isti princip u suprotnom smeru

posledice po masku prekida (main.cpp):
- sie: konzola (seie, bit 9) MORA biti ziva - inace console_handler nikad
  ne puni bafer i __getc visi zauvek. tajmer (ssie, bit 1) odmaskiran,
  handler ga za sada samo potvrdi (obrise ssip) - prava obrada = zadatak 4
- sstatus.SIE = 1: da prekidi stizu i dok je main (s-mode) na procesoru;
  u-mode niti ovaj bit ne gledaju, za njih vazi sie direktno

UGNJEZDENI TRAP: posto __getc/__putc puste prekide USRED obrade naseg
syscall-a, konzolni/tajmerski prekid moze da upadne dok smo vec u
handleSupervisorTrap-u. nas dizajn "sepc/sstatus u lokalima" (lekcija 03/06) ovo
resava besplatno: spoljni trap drzi svoje vrednosti na steku niti, a
ugnjezdeni slobodno gazi csr registre i vrati ih iz SVOJIH lokala.

mana koja je POSTOJALA do 2026-07-21: __getc ceka drzeci procesor -
druge niti nisu radile dok se ceka znak, pa su testovi 3/4 "seckali"
(cifre u naletima, muk do sledeceg tastera). resena uvodjenjem DELJENJA
VREMENA (preotimanje na tajmerski prekid - lekcija 11): tajmer sada
preotme i nit koja ceka u __getc, pa cifre teku kontinualno.

## sta zvanicni testovi zapravo proveravaju (procitano iz koda!)

- test 1: 4 niti (A,B,C,D) se smenjuju uz ogromne busy-wait petlje.
  najzanimljivije: nit C uradi `li t1, 7`, pa thread_dispatch, pa PROVERI
  da li je t1 preziveo promenu konteksta! ovo testira cuvanje t-registara
  po niti - tacno ono sto nas supervisorTrap.S radi (t/a/ra na stek niti pri trapu).
  slicno i D sa `li t1, 5` - dve niti, ISTI registar, razlicite vrednosti.
- test 7: nit B na i==10 izvrsi `csrr t6, sepc` - u u-modu to je ilegalna
  instrukcija -> panika -> nema regularnog kraja == PROLAZ. poruka
  "Test se nije uspesno zavrsio" NE SME da se pojavi.
- printing koristi spin-lock (copy_and_swap iz lock.S, lr.w/sc.w atomike)
  oko ispisa - stitи ispis od mesanja kad se niti smenjuju usred stringa.

## kako se pokrece

```
make clean && make && make qemu     (u containeru!)
meni: ukucaj 1 pa enter -> test 1 (TRAJE dugo - busy petlje, gledaj A:/B:/C:/D: redove)
      ukucaj 7 pa enter -> ocekivan PANIC cause=0x2 (to je prolaz!)
```

izlaz iz qemu ako test predugo traje: ctrl-a pa x.

## pitanja za odbranu

1. zasto 20p verzija MORA console.lib, a ne rucni polling? (pdf str. 30-31)
2. ko zove plic_claim/plic_complete u nasem projektu? (mi ne - console_handler!)
3. sta se desi kad prekid stigne USRED obrade getc syscall-a? zasto nam
   ugnjezdeni trap ne gazi sepc/sstatus?
4. zasto konzolni bit (9) u sie mora biti ukljucen, a tajmerski (1) je
   stvar izbora dok nema zadatka 4? sta radi sstatus.SIE i koga se tice?
5. sta test 1 proverava trikom li t1,7 / dispatch / mv? gde nas kod to garantuje?
6. zasto printString mora spin-lock oko petlje sa putc?
7. zasto test 7 "prolazi padom"? koja poruka ne sme da se pojavi?
8. zasto su testovi 3/4 "seckali" PRE deljenja vremena, i kako ga tacno
   preotimanje resava? (kljuc: __getc ceka drzeci procesor, ali pusta
   prekide - pa tajmer moze da ga preotme)
