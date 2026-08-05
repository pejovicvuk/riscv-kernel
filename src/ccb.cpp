#include "../inc/ccb.hpp"
#include "../inc/scb.hpp"
#include "../inc/tcb.hpp"
#include "../inc/memoryAllocator.hpp"
#include "../lib/hw.h"

const int CCB::BUFFER_SIZE;

char CCB::inputBuffer[CCB::BUFFER_SIZE];
int  CCB::inputHead = 0;
int  CCB::inputTail = 0;
SCB* CCB::inputItems = nullptr;

char CCB::outputBuffer[CCB::BUFFER_SIZE];
int  CCB::outputHead = 0;
int  CCB::outputTail = 0;
SCB* CCB::outputItems = nullptr;
SCB* CCB::outputSpace = nullptr;

// semafori nastaju direktno kroz SCB (jezgro sebi ne zvoni ecall-om!),
// a stek izlazne niti direktno iz alokatora - iz istog razloga
void CCB::init() {
    inputItems  = SCB::createSemaphore(0);
    outputItems = SCB::createSemaphore(0);
    outputSpace = SCB::createSemaphore(BUFFER_SIZE);

    // izlazna nit jezgra: vecni potrosac izlaznog bafera. sistemska je
    // (pdf str. 27: telo internih niti radi u sistemskom rezimu, da sme
    // da pristupa registrima kontrolera)
    TCB::createThread(&outputBody, nullptr,
                      MemoryAllocator::alloc(DEFAULT_STACK_SIZE), true);
}

// konzolni prekid: kontroler javlja "imam znak sa tastature" i/ili
// "spreman sam za slanje". ovde radimo SAMO ulaz (prekidna rutina je
// proizvodjac, pdf str. 27); izlaz ne diramo - njega izlazna nit salje
// prozivanjem, pa joj prekid nije potreban.
// plic_claim kaze koji uredjaj je prekinuo, plic_complete potvrdi obradu
void CCB::handleInterrupt() {
    int irq = plic_claim();
    if (irq == CONSOLE_IRQ) {
        // pokupi znakove dok ih ima (u jednom prekidu moze stici vise)
        while (*(volatile char*)CONSOLE_STATUS & CONSOLE_RX_STATUS_BIT) {
            char c = *(volatile char*)CONSOLE_RX_DATA;   // uvek skini iz kontrolera
            int nextTail = (inputTail + 1) % BUFFER_SIZE;
            if (nextTail == inputHead) continue;   // pun bafer: znak se odbacuje (pdf str. 27)
            inputBuffer[inputTail] = c;
            inputTail = nextTail;
            inputItems->signal(1);
        }
    }
    if (irq) plic_complete(irq);
}

// syscall 0x41: uzmi znak iz ulaznog bafera; prazan bafer -> pozivajuca
// nit blokira na semaforu (spava kao kod sem_wait), a budi je prekidna
// rutina signalom kad znak stigne sa tastature
char CCB::getc() {
    if (inputItems->wait(1) < 0) return -1;   // (nedostizno: ovaj semafor se ne gasi)
    char c = inputBuffer[inputHead];
    inputHead = (inputHead + 1) % BUFFER_SIZE;
    return c;
}

// syscall 0x42: stavi znak u izlazni bafer; pun bafer -> pozivalac
// blokira dok izlazna nit ne oslobodi mesto (pdf str. 27 nudi blokadu
// ili gresku - biramo blokadu, prirodna je uz semafor slobodnih mesta)
void CCB::putc(char c) {
    outputSpace->wait(1);
    outputBuffer[outputTail] = c;
    outputTail = (outputTail + 1) % BUFFER_SIZE;
    outputItems->signal(1);
}

bool CCB::outputEmpty() {
    return outputHead == outputTail;
}

// vecni potrosac: ceka znak (na praznom baferu blokira - tada jedino i
// ustupa procesor), pa PROZIVANJEM saceka spremnost kontrolera i posalje.
// telo radi u s-modu sa maskiranim prekidima (sistemska nit se ne spusta
// sret-om), pa su pristupi baferu prirodno atomski prema putc-u iz trapa
void CCB::outputBody(void*) {
    for (;;) {
        outputItems->wait(1);
        char c = outputBuffer[outputHead];
        outputHead = (outputHead + 1) % BUFFER_SIZE;
        while (!(*(volatile char*)CONSOLE_STATUS & CONSOLE_TX_STATUS_BIT)) {
            // bit 5 == 0: kontroler jos salje prethodni znak
        }
        *(volatile char*)CONSOLE_TX_DATA = c;
        outputSpace->signal(1);
    }
}
