// official test userMain (public tests 2024), adapted to the current state:
// - LEVEL flags: all parts (1-4) done
#include "../test/printing.hpp"

#define LEVEL_1_IMPLEMENTED 1
#define LEVEL_2_IMPLEMENTED 1
#define LEVEL_3_IMPLEMENTED 1
#define LEVEL_4_IMPLEMENTED 1

#if LEVEL_2_IMPLEMENTED == 1
// TEST 1 (part 2, threads C API and synchronous context switch)
#include "../test/Threads_C_API_test.hpp"
// TEST 2 (part 2, threads CPP API)
#include "../test/Threads_CPP_API_test.hpp"
// TEST 7 (part 2, testing whether user code runs in user mode)
#include "../test/System_Mode_test.hpp"
#endif

#if LEVEL_3_IMPLEMENTED == 1
// TEST 3 (part 3, complete C API with semaphores, synchronous context switch)
#include "../test/ConsumerProducer_C_API_test.hpp"
// TEST 4 (part 3, CPP Sync API)
#include "../test/ConsumerProducer_CPP_Sync_API_test.hpp"
#endif

#if LEVEL_4_IMPLEMENTED == 1
// TEST 5 (part 4, thread_sleep test C API)
#include "../test/ThreadSleep_C_API_test.hpp"
// TEST 6 (part 4, CPP API and asynchronous context switch)
#include "../test/ConsumerProducer_CPP_API_test.hpp"
#endif

// TEST 8 (our test: start gate: 5 threads wait on one semaphore)
#include "../test/myTest.hpp"

void userMain() {
    printString("Enter test number? [1-8]\n");
    int test = getc() - '0';
    getc(); // enter after the number

    if ((test >= 1 && test <= 2) || test == 7) {
        if (LEVEL_2_IMPLEMENTED == 0) {
            printString("Part 2 is not marked as implemented\n");
            return;
        }
    }

    if (test >= 3 && test <= 4) {
        if (LEVEL_3_IMPLEMENTED == 0) {
            printString("Part 3 is not marked as implemented\n");
            return;
        }
    }

    if (test >= 5 && test <= 6) {
        if (LEVEL_4_IMPLEMENTED == 0) {
            printString("Part 4 is not marked as implemented\n");
            return;
        }
    }

    switch (test) {
        case 1:
#if LEVEL_2_IMPLEMENTED == 1
            Threads_C_API_test();
            printString("TEST 1 (part 2, threads C API and synchronous context switch)\n");
#endif
            break;
        case 2:
#if LEVEL_2_IMPLEMENTED == 1
            Threads_CPP_API_test();
            printString("TEST 2 (part 2, threads CPP API)\n");
#endif
            break;
        case 3:
#if LEVEL_3_IMPLEMENTED == 1
            producerConsumer_C_API();
            printString("TEST 3 (part 3, complete C API with semaphores, synchronous context switch)\n");
#endif
            break;
        case 4:
#if LEVEL_3_IMPLEMENTED == 1
            producerConsumer_CPP_Sync_API();
            printString("TEST 4 (part 3, CPP Sync API)\n");
#endif
            break;
        case 5:
#if LEVEL_4_IMPLEMENTED == 1
            testSleeping();
            printString("TEST 5 (part 4, thread_sleep test C API)\n");
#endif
            break;
        case 6:
#if LEVEL_4_IMPLEMENTED == 1
            testConsumerProducer();
            printString("TEST 6 (part 4, CPP API and asynchronous context switch)\n");
#endif
            break;
        case 7:
#if LEVEL_2_IMPLEMENTED == 1
            System_Mode_test();
            printString("Test did not finish successfully\n");
            printString("TEST 7 (part 2, testing whether user code runs in user mode)\n");
#endif
            break;
        case 8:
            my_test();
            printString("TEST 8 (start gate: 5 threads wait on one semaphore)\n");
            break;
        default:
            printString("You did not enter a valid test number\n");
    }
}
