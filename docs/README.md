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
| 05 | [niti - kostur (TCB + Scheduler)](05-niti-kostur.md) | u izradi |

## trenutno stanje projekta

- zadatak 1 (alokator): gotov, dokazan kroz ceo ecall lanac
- prekidna rutina: cuva registre, panika na nepoznat uzrok, prekidi maskirani
- zadatak 2 (niti): kostur napravljen (TCB, Scheduler), sledi promena konteksta
- cilj: svih 30 poena (zadaci 1+2+3+4)

## kako radimo

1. novi kod + objasnjenje toka prostim jezikom
2. citanje koda liniju po liniju
3. "jasno" -> kontrolna pitanja -> sledeca celina
4. posle svake celine: update ovih lekcija
