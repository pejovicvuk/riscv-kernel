# 04 - prekidi, maskiranje i veliki bug

## tri registra za prekide - ko je ko

- `sip` (pending): tabla cekanja - "stigao je zahtev te vrste, jos nije obradjen".
  maskiranje NE brise zahteve, oni cekaju u sip-u. posle obrade tajmera treba
  RUCNO obrisati ssip bit (bit 1) - to je "obradio sam, skini zahtev".
- `sie` (enable): pojedinacni prekidaci PO VRSTI prekida.
  ssie (bit 1) = softverski/tajmer, seie (bit 9) = spoljasnji/konzola.
  **vazi UVEK, i u korisnickom rezimu!**
- `sstatus.SIE` (bit 1): glavni prekidac "smes li da me prekines SAD".
  **vazi SAMO u sistemskom rezimu; u korisnickom se ignorise** (pdf str. 15-16).

dvospratni model odlucivanja:

```
prekid stize -> da li je vrsta dozvoljena?   (sie: ssie/seie - vazi uvek)
             -> da li me smes prekinuti sad? (sstatus.SIE - samo sistemski rezim;
                                              u korisnickom uvek "da")
             -> oba "da": trap na stvec.  inace: zahtev ceka u sip-u.
```

posledica: nasa trenutna maska (`sstatus.SIE = 0` u main-u) radi jer SVE trenutno
radi u sistemskom rezimu. cim niti budu u korisnickom rezimu (test 7 to trazi!),
maska se seli u `sie` registar.

maska je samoodrziva kroz trapove: hardver na ulasku snimi `SPIE <- SIE(=0)`,
a `sret` vrati `SIE <- SPIE(=0)`. nula radja nulu.

## specificnosti nase platforme

- tajmer stize kao SOFTVERSKI prekid (scause top=1, kod=1), 10x u sekundi;
  obrada: obrisati ssip u sip
- konzola stize kao SPOLJASNJI prekid (top=1, kod=9); obrada: `plic_claim()`
  pa `plic_complete(irq)`
- **konzola je "brbljiva"**: kontroler dize prekid i kad je SPREMAN ZA SLANJE,
  a spreman je prakticno uvek -> uradis claim/complete sasvim ispravno, a on
  ODMAH digne novi prekid. zato se bez bafera (zadatak 4) konzola mora maskirati.

## veliki bug: kako smo 2 dana jurili pogresnog krivca

simptom: posle USPESNOG mem_alloc ecall-a, beskonacna petlja
`c=0x8000000000000009` / `c=0x2` naizmenicno. maskiranje SIE nije pomagalo.

dokazi koji su resili slucaj:
1. `sstatus posle maske = 0x0` -> maska JESTE upisana
2. ecall daje `c=0x...09` (top 0) -> potvrda: radimo u sistemskom rezimu
3. posle "pre return": `c=0x8000000000000009` -> spoljasnji prekid ISPORUCEN
   uprkos SIE=0... a to je moguce SAMO u korisnickom rezimu!

rekonstrukcija (prati registar `ra`):

```
userMain --call--> mem_alloc              ra = povratak u userMain
                   mem_alloc je LEAF funkcija -> njen prevod NE cuva ra na steku!
ecall -> stari trapHandler:
    call handleSupervisorTrap                       !!! call upise u ra adresu SLEDECE
                                          instrukcije = adresu sret-a
    sret -> nazad u mem_alloc             ali ra je i dalje IZGAZEN
mem_alloc: ret                            skok na ra = na SRET u trapHandler-u!
divlji sret: rezim <- SPP                 SPP je 0 (prethodni sret ga resetovao)
                                          -> pad u KORISNICKI rezim!
korisnicki rezim: sstatus.SIE se ignorise -> brbljiva konzola upada: c=0x8...09
njen sret vrati u korisnicki rezim -> kod opet stigne do ret -> skok na sret ->
sret je u korisnickom rezimu ILEGALNA (privilegovana) instrukcija -> c=0x2
handler za c=2 ne pomera sepc -> ista adresa -> a konzola vec ceka -> 9,2,9,2...
```

## lekcije iz buga (ovo se brani!)

1. **prekidna rutina MORA da sacuva caller-saved registre** (ra, t0-t6, a1-a7):
   c funkcija ih po konvenciji sme pokvariti, a prekinuti kod (koga je prekid
   PRESEKAO usred posla, nije nikog "pozvao") racuna da su netaknuti.
   zato trap.S sada spusta 15 registara na stek pre call-a i vraca ih posle.
   (s0-s11 ne: njih cuva sam handleSupervisorTrap svojim prologom/epilogom, po konvenciji.)
2. **privilegovane instrukcije stite jezgro**: sret/csr iz korisnickog rezima =
   ilegalna instrukcija. da nije tako, korisnicki program bi mogao sam sebe da
   prebaci u sistemski rezim i zastita ne bi postojala.
3. **panika umesto tihe petlje**: nepoznat uzrok -> ispisi cause + sepc -> halt.
   sepc ti kaze TACNU adresu koja je pukla; nadji je u kernel.asm i vidis sta je.
4. debug ispis celog scause (ne samo donjeg bajta!) - top bit nosi pola informacije.

## pitanja za odbranu

1. razlika sip/sie/sstatus.SIE? ko od njih vazi u korisnickom rezimu?
2. zasto tajmer zahteva brisanje ssip, a konzola claim/complete?
3. zasto konzolni prekid stalno ponovo stize iako ga "obradimo"?
4. zasto se za sinhronu promenu konteksta cuva manje registara nego za asinhronu?
5. ispricaj pricu velikog buga: koji registar, koja instrukcija, koji rezim.
