#ifndef _ccb_hpp_
#define _ccb_hpp_

class SCB;

// ccb (console control block) = nasa konzola (zadatak 4), zamena za datu
// console.lib. dva kruzna bafera + semafori za blokiranje (pdf str. 27):
// - ulaz: PREKIDNA RUTINA je proizvodjac (prebacuje znakove iz kontrolera
//   u ulazni bafer), getc syscall je potrosac (prazan bafer -> blokada)
// - izlaz: putc syscall je proizvodjac (pun bafer -> blokada), a INTERNA
//   SISTEMSKA NIT jezgra je potrosac (salje kontroleru uz prozivanje)
class CCB {
public:
    // napravi semafore i pokreni izlaznu nit jezgra;
    // zvati u main-u PRE ukljucivanja prekida
    static void init();

    // obrada konzolnog prekida (scause top=1, code=9): plic_claim/complete
    // + prebaci sve pristigle znakove kontroler -> ulazni bafer
    static void handleInterrupt();

    // za syscall-e 0x41/0x42: izvrsavaju se u kontekstu pozivajuce niti,
    // pa smeju da je blokiraju - ista mehanika kao sem_wait
    static char getc();
    static void putc(char c);

    // da li je izlazni bafer prazan - main pred gasenje ceka da izlazna
    // nit posalje i poslednji znak (inace bi kraj ispisa testa propao)
    static bool outputEmpty();

private:
    CCB() = delete;   // all-static klasa, kao Scheduler i MemoryAllocator

    static const int BUFFER_SIZE = 512;

    // kruzni baferi: cita se sa head, pise na tail;
    // (tail+1)%N == head znaci "pun" - jedno mesto se zrtvuje za razliku
    // punog od praznog, pa poseban brojac nije potreban
    static char inputBuffer[BUFFER_SIZE];
    static int inputHead, inputTail;
    static SCB* inputItems;    // broj znakova koji cekaju u ulaznom baferu

    static char outputBuffer[BUFFER_SIZE];
    static int outputHead, outputTail;
    static SCB* outputItems;   // broj znakova koji cekaju slanje
    static SCB* outputSpace;   // broj slobodnih mesta u izlaznom baferu

    // telo izlazne niti (systemLevel=true: ostaje u s-modu jer pise
    // direktno u registre kontrolera konzole)
    static void outputBody(void*);
};

#endif // _ccb_hpp_
