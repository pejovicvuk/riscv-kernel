# 02 - alokator memorije (zadatak 1)

fajlovi: `inc/memoryAllocator.hpp`, `src/memoryAllocator.cpp`

## ideja u jednoj recenici

heap je jedna velika traka memorije; slobodne delove drzimo u ulancanoj listi
sortiranoj po adresi, a evidenciju o svakom slobodnom bloku (heder) drzimo
**u samom bloku** - zato "intruzivna" lista: nema posebne memorije za knjigovodstvo.

## kljucne odluke dizajna

- **heder zivi u prvih 16B bloka**: `struct FreeBlock { FreeBlock* next; size_t size; }`
  (8B + 8B = 16B). korisnik dobija pokazivac ODMAH IZA hedera.
- **first-fit**: uzmi prvi blok koji je dovoljno veliki (jednostavno, dovoljno dobro)
- **interno sve u bajtovima**, a svaka alokacija je umnozak `MEM_BLOCK_SIZE` (64B)
- **lista sortirana po adresi**: jedino tako spajanje suseda (coalescing) radi prosto
- all-static klasa: `MemoryAllocator::init/alloc/free`, konstruktor obrisan

## flow: alloc(100)

```
1. korisnik trazi 100 bajtova
2. dodaj heder:          100 + 16 = 116
3. zaokruzi na blokove:  ((116 + 63) / 64) * 64 = 128     <- ceiling division!
4. first-fit: setaj kroz listu dok ne nadjes blok sa size >= 128
5. nadjen blok od npr. 1024B:
   ostatak = 1024 - 128 = 896 >= 64  -> CEPAMO:
      [ nas blok: 128B ][ novi slobodan blok: 896B -> ostaje u listi ]
   (da je ostatak < 64, dali bismo ceo blok - premali je da zivi sam)
6. vrati (char*)blok + 16   <- adresa IZA hedera
```

vazno za korak 3: ceiling division je `(n + B - 1) / B`, NIJE "podeli pa +1"
(to gresi na tacnim umnoscima: 128/64+1 = 3 bloka umesto 2!).

vazno za korak 2: heder se uracunava PRE zaokruzivanja - garancija da
korisnikov payload uvek ima bar trazenih `size` bajtova.

## flow: free(p)

```
1. heder je tacno ispred payload-a:  block = (char*)p - 16
2. setaj kroz listu (sortirana po adresi) do mesta gde block pripada
3. proveri da li se block FIZICKI naslanja na suseda:
   mergePrev: (char*)prev + prev->size == (char*)block
   mergeNext: (char*)block + block->size == (char*)curr
4. cetiri slucaja:
   nema spajanja        -> samo umetni block u listu
   spoji sa prethodnim  -> prev->size += block->size   (block nestaje u prev-u)
   spoji sa sledecim    -> block "proguta" curr (size i next preuzima)
   spoji sa oba         -> prev proguta i block i curr
```

primer spajanja sa oba suseda:

```
pre:   [prev 128B slobodan][block 128B upravo oslobodjen][curr 256B slobodan]
posle: [prev 512B slobodan]                    <- jedan blok, lista kraca za 2
```

## zamke koje smo vec prezivali

- `sizeof(FreeBlock)` je 16 (cela struktura), `sizeof(FreeBlock*)` je 8 (pokazivac)!
- short-circuit `&&` u mergePrev/mergeNext cuva od null dereference
  (`prev != nullptr && ...` - desna strana se ne izvrsava ako je leva false)
- `free(nullptr)` vraca -1, ne puca

## dvostruko zaokruzivanje kroz ceo lanac (nije bag!)

kad zahtev ide kroz c api -> abi -> jezgro, zaokruzuje se DVAPUT:

```
mem_alloc(100):  c api: (100+63)/64 = 2 bloka    (korisnik dobija >= 128 KORISNIH bajtova)
                 jezgro: alloc(2*64 = 128)
                 alokator: 128+16 heder = 144 -> 192 (3 bloka zauzeto)
```

svaka alokacija zauzme jedan blok vise od "ociglednog" - jer heder zivi u samom
bloku, pa da korisnik dobije punih n*64 korisnih bajtova, mora se zauzeti jos
mesta za heder. to je inherentna cena intruzivnog dizajna; pdf trazi "najmanje
size bajtova" - uslov ispunjen. dokaz iz stvarnog testa: p2-p1 = 0xC0 (192),
p3-p2 = 0x140 (320).

## kako je dokazano

test u `userMain` kroz CEO lanac (c api -> ecall -> jezgro -> alokator):
tri alokacije (100, 200, 50), oslobadjanje u redosledu p2, p1, p3 - pokriva
grane "spoji sa sledecim" i "spoji sa oba". dokaz: posle free(p2)+free(p1)
jedna rupa od 0x200 (= 0xC0 + 0x140), a posle free(p3) CEO heap opet jedan
blok na pocetnoj adresi sa pocetnom velicinom (0x7ffa720) - nula curenja.
mem_alloc I mem_free rade kroz ecall.

## pitanja za odbranu

1. zasto lista mora biti sortirana po adresi?
2. sta bi se desilo da heder NE uracunamo u zaokruzivanje?
3. zasto je ostatak manji od MEM_BLOCK_SIZE "premali da zivi sam"?
4. kako iz payload pokazivaca nalazimo heder i zasto je to bezbedno?
