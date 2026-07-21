# 01 - platforma i okruzenje

## sta uopste pravimo

malo ali pravo jezgro operativnog sistema za risc-v procesor (rv64ima).
"pravo" znaci: ispod naseg koda nema nikakvog os-a koji pomaze - nas kod
je gazda procesora. sistem-domacin (modifikovani xv6) samo ucita program,
obezbedi tajmer i konzolu, i preda kontrolu nasem `main`-u u sistemskom rezimu.

jezgro je "bibliotecko": nas kernel + korisnicki test program se staticki
povezu u jedan izvrsni fajl i dele isti adresni prostor (kao kod embedded
sistema).

slojevi (mi pisemo sve izmedju app.lib i hw.lib):

```
korisnicki program (app.lib)   <- daje fakultet (testovi)
c++ api (Thread, Semaphore)    <- tanki omotac oko c api-ja
c api (mem_alloc, thread_...)  <- omotac oko abi-ja
abi (ecall + registri a0..)    <- softverski prekid
jezgro (alokator, niti...)     <- srce
hw.lib (pristup hardveru)      <- daje fakultet
```

## build i pokretanje

- radi se kroz docker container koji vidi projekat na `/work`
- `make` - prevodjenje, `make qemu` - pokretanje, izlaz iz qemu: `ctrl-a` pa `x`
- `make clean && make` kad make "ne vidi" izmene (cest slucaj kod izmena samo u headerima)
- zaustavljanje emulatora iz koda: upis 32-bitne vrednosti `0x5555` na adresu `0x100000`

## dve infrastrukturne zamke (vec su nas ujedale)

1. **mac mount je case-insensitive**: `trap.S` i `trap.s` su isti fajl!
   gnu make je pravio `.s` medjufajl iz `.S` i pri ciscenju gazio original.
   resenje: pravilo u Makefile koje pravi `.o` direktno iz `.S` (uvlacenje mora biti tab):
   ```
   ${DIR_BUILD}/%.o: %.S Makefile | ${DIR_BUILD}
   	@mkdir -p $(dir ${@})
   	${CC} -c ${CFLAGS} -o ${@} ${<}
   ```
   iz istog razloga: include putanje moraju da se poklapaju sa stvarnim imenom
   fajla do poslednjeg slova (`memoryAllocator.hpp`, ne `MemoryAllocator.hpp`) -
   na fakultetskom linux-u (case-sensitive) pogresno slovo = build pada!
2. **vs code nesnimljeni buffer**: kod "postoji" u editoru ali ne na disku.
   veruj `ls`/`cat`/`grep` u containeru, ne vs code prikazu.
3. **make SAMO u containeru**: mac-ov homebrew toolchain ima noviji binutils
   koji za csr instrukcije trazi `-march=rv64ima_zicsr`, pa build puca sa
   "extension zicsr required". container (i fakultet) imaju stariji gcc kome
   `rv64ima` podrazumeva csr. makefile ne diramo. kako prepoznati gresku:
   temp putanja `/var/folders/...` u ispisu = mac toolchain, ne container.
   posledica ako se make ipak pokrene na mac-u: u build/ ostane mesavina
   mac i container .o fajlova, pa linker u containeru puca sa "unsupported
   ISA subset" / "failed to merge target specific data". lek: `make clean && make`
   u containeru.

## alati za debug (nas detektivski pribor)

- `grep -n simbol fajl` - gde se simbol pominje
- `nm build/.../x.o | grep simbol` - da li simbol postoji u objektnom fajlu
  ("undefined reference" = deklarisan ali definicija fali; malo `t` = static)
- `build/src/*.lst` - asemblerski listing svakog fajla (dokaz sta je stvarno prevedeno)
- `kernel.asm` - disasembliran ceo kernel (trazi adresu iz sepc-a kad nesto pukne!)
- `make qemu 2>&1 | tee /work/out.txt` - snimi ceo izlaz kad terminal poplavi
- `kputs`/`kputhex` iz `h/print.hpp` - direktan polling ispis, radi i usred
  prekidne rutine (debug alat, ne deo resenja)
- panika u `handleSupervisorTrap`: nepoznat uzrok ispisuje `cause` + `sepc` i gasi emulator -
  nikad vise tiha beskonacna petlja

## pitanja za odbranu

1. zasto jezgro ne sme da koristi standardne c/c++ biblioteke?
2. sta znaci da je jezgro "bibliotecko" i po cemu se to razlikuje od pravog os-a?
3. kako se program regularno zavrsava i zasto je to vazno za testove?
