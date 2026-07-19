# os1 projekat - lekcije

skripta projekta: sta smo uradili, kako radi i zasto bas tako.
svaka lekcija ima "flow" primere - korak po korak kako se stvari desavaju.
ovo je ujedno i priprema za odbranu: na kraju svake lekcije su pitanja
na koja treba znati odgovor.

## sadrzaj

| # | lekcija | status |
|---|---------|--------|
| 01 | [platforma i okruzenje](01-platforma-i-okruzenje.md) | gotovo |
| 02 | [alokator memorije (zadatak 1)](02-alokator-memorije.md) | gotovo |
| 03 | [trap, ecall i sistemski pozivi](03-trap-ecall-abi.md) | gotovo |
| 04 | [prekidi, maskiranje i veliki bug](04-prekidi-maskiranje-bug.md) | gotovo |
| 05 | [niti - TCB, Scheduler, promena konteksta](05-niti-kostur.md) | gotovo |
| 06 | [niti kroz sistemske pozive](06-sistemski-pozivi-niti.md) | gotovo |
| 07 | [niti u korisnickom rezimu (u-mode)](07-u-mode-niti.md) | gotovo |
| 08 | [zvanicni testovi + polling konzola](08-zvanicni-testovi.md) | test u toku |

## trenutno stanje projekta

- zadatak 1 (alokator): KOMPLETAN - mem_alloc i mem_free kroz ceo ecall lanac,
  spajanje dokazano (heap se vraca u jedan blok, nula curenja)
- prekidna rutina: cuva registre, sepc/sstatus po niti (lokali), panika na
  nepoznat uzrok; maska prekida u sie registru (vazi u oba rezima)
- zadatak 2 (niti): thread_create/exit/dispatch kao sistemski pozivi (0x11-0x13),
  c api, zombi ciscenje, tela korisnickih niti u U-MODU (test 7 spreman);
  test ABABABABAB prosao kroz ceo syscall lanac
- sledece: semafori (zadatak 3), pa tajmer/preotimanje i konzola (zadatak 4)
- cilj: svih 30 poena (zadaci 1+2+3+4)

## kako radimo

1. novi kod + objasnjenje toka prostim jezikom
2. citanje koda liniju po liniju
3. "jasno" -> kontrolna pitanja -> sledeca celina
4. posle svake celine: update ovih lekcija
