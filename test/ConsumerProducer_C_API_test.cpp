
#include "../inc/syscall_c.h"

#include "buffer.hpp"

static sem_t waitForAll;

struct thread_data {
    int id;
    Buffer *buffer;
    sem_t wait;
};

static volatile int threadEnd = 0;

static void producerKeyboard(void *arg) {
    struct thread_data *data = (struct thread_data *) arg;

    int key;
    int i = 0;
    while ((key = getc()) != 0x1b) {
        data->buffer->put(key);
        i++;

        if (i % (10 * data->id) == 0) {
            thread_dispatch();
        }
    }

    threadEnd = 1;
    data->buffer->put('!');

    sem_signal(data->wait);
}

static void producer(void *arg) {
    struct thread_data *data = (struct thread_data *) arg;

    int i = 0;
    while (!threadEnd) {
        data->buffer->put(data->id + '0');
        i++;

        if (i % (10 * data->id) == 0) {
            thread_dispatch();
        }
    }

    sem_signal(data->wait);
}

static void consumer(void *arg) {
    struct thread_data *data = (struct thread_data *) arg;

    int i = 0;
    while (!threadEnd) {
        int key = data->buffer->get();
        i++;

        putc(key);

        if (i % (5 * data->id) == 0) {
            thread_dispatch();
        }

        if (i % 80 == 0) {
            putc('\n');
        }
    }

    while (data->buffer->getCnt() > 0) {
        int key = data->buffer->get();
        putc(key);
    }

    sem_signal(data->wait);
}

void producerConsumer_C_API() {
    char input[30];
    int n, threadNum;

    printString("Enter the number of producers?\n");
    getString(input, 30);
    threadNum = stringToInt(input);

    printString("Enter the buffer size?\n");
    getString(input, 30);
    n = stringToInt(input);

    printString("Number of producers "); printInt(threadNum);
    printString(" and buffer size "); printInt(n);
    printString(".\n");

    if(threadNum > n) {
        printString("Number of producers must not be less than the buffer size!\n");
        return;
    } else if (threadNum < 1) {
        printString("Number of producers must be greater than zero!\n");
        return;
    }

    Buffer *buffer = new Buffer(n);

    sem_open(&waitForAll, 0);

    thread_t threads[threadNum];
    thread_t consumerThread;

    struct thread_data data[threadNum + 1];

    data[threadNum].id = threadNum;
    data[threadNum].buffer = buffer;
    data[threadNum].wait = waitForAll;
    thread_create(&consumerThread, consumer, data + threadNum);

    for (int i = 0; i < threadNum; i++) {
        data[i].id = i;
        data[i].buffer = buffer;
        data[i].wait = waitForAll;

        thread_create(threads + i,
                      i > 0 ? producer : producerKeyboard,
                      data + i);
    }

    thread_dispatch();

    for (int i = 0; i <= threadNum; i++) {
        sem_wait(waitForAll);
    }

    sem_close(waitForAll);

    delete buffer;

}
