// zvanicni test userMain (javni testovi 2024), prilagodjen trenutnom stanju:
// - LEVEL zastavice: 1 i 2 gotovi, 3 i 4 jos nisu
// - todo: vratiti include/pozive za cpp api (test 2) kad c++ api bude gotov
// - todo: vratiti testove 3-6 kad stignu semafori i zadatak 4
#include "../test/printing.hpp"

#define LEVEL_1_IMPLEMENTED 1
#define LEVEL_2_IMPLEMENTED 1
#define LEVEL_3_IMPLEMENTED 1
#define LEVEL_4_IMPLEMENTED 0

#if LEVEL_2_IMPLEMENTED == 1
// TEST 1 (zadatak 2, niti C API i sinhrona promena konteksta)
#include "../test/Threads_C_API_test.hpp"
// TEST 2 (zadatak 2., niti CPP API) - TODO: ceka c++ api
// #include "../test/Threads_CPP_API_test.hpp"
// TEST 7 (zadatak 2., testiranje da li se korisnicki kod izvrsava u korisnickom rezimu)
#include "../test/System_Mode_test.hpp"
#endif

#if LEVEL_3_IMPLEMENTED == 1
// TEST 3 (zadatak 3., kompletan C API sa semaforima, sinhrona promena konteksta)
#include "../test/ConsumerProducer_C_API_test.hpp"
// TEST 4 (zadatak 3., CPP Sync API) - TODO: ceka c++ api
// #include "../test/ConsumerProducer_CPP_Sync_API_test.hpp"
#endif

void userMain() {
    printString("Unesite broj testa? [1-7]\n");
    int test = getc() - '0';
    getc(); // enter posle broja

    if ((test >= 1 && test <= 2) || test == 7) {
        if (LEVEL_2_IMPLEMENTED == 0) {
            printString("Nije navedeno da je zadatak 2 implementiran\n");
            return;
        }
    }

    if (test >= 3 && test <= 4) {
        if (LEVEL_3_IMPLEMENTED == 0) {
            printString("Nije navedeno da je zadatak 3 implementiran\n");
            return;
        }
    }

    if (test >= 5 && test <= 6) {
        if (LEVEL_4_IMPLEMENTED == 0) {
            printString("Nije navedeno da je zadatak 4 implementiran\n");
            return;
        }
    }

    switch (test) {
        case 1:
#if LEVEL_2_IMPLEMENTED == 1
            Threads_C_API_test();
            printString("TEST 1 (zadatak 2, niti C API i sinhrona promena konteksta)\n");
#endif
            break;
        case 2:
#if LEVEL_2_IMPLEMENTED == 1
            // TODO: Threads_CPP_API_test(); - ceka c++ api
            printString("TEST 2: c++ api jos nije implementiran\n");
#endif
            break;
        case 3:
#if LEVEL_3_IMPLEMENTED == 1
            producerConsumer_C_API();
            printString("TEST 3 (zadatak 3., kompletan C API sa semaforima, sinhrona promena konteksta)\n");
#endif
            break;
        case 4:
#if LEVEL_3_IMPLEMENTED == 1
            // TODO: producerConsumer_CPP_Sync_API(); - ceka c++ api
            printString("TEST 4: c++ api jos nije implementiran\n");
#endif
            break;
        case 7:
#if LEVEL_2_IMPLEMENTED == 1
            System_Mode_test();
            printString("Test se nije uspesno zavrsio\n");
            printString("TEST 7 (zadatak 2., testiranje da li se korisnicki kod izvrsava u korisnickom rezimu)\n");
#endif
            break;
        default:
            printString("Niste uneli odgovarajuci broj za test\n");
    }
}
