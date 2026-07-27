#include "../inc/syscall_cpp.hpp"
#include "printing.hpp"

unsigned static seed = 0;

static int random(){
    ++seed;
    seed = (seed * 1103515245 + 12345) % 2147483648;
    return (seed >> 16) % 20;
}

static int matrix[10][10];

static void populate_matrix(int matrix[10][10]){
    for(int i = 0; i < 10; i++){
        for(int j = 0; j < 10; j++){
            matrix[i][j] = random();
        }
    }
}
static int counter[10];

static Semaphore* done;

static Thread* threads[10];
static void countBody(void* arg){
    int num = (int)(uint64)arg;
    for (int i = 0; i < 10; i++){
        for(int j = 0; j < 10; j++){
            if(matrix[i][j] % 10 == num){
                counter[num]++;
            }
        }
    }
    done->signal();
}

void my_test(){
    done = new Semaphore(0);
    populate_matrix(matrix);
    for(int i = 0; i < 10; i++){
        threads[i] = new Thread(countBody, (void*)(uint64)i);
        threads[i]->start();
    }
    for(int i = 0; i < 10; i++){
        done->wait();
    }
    for (int i = 0; i < 10; i++){
        printString("Number of ");
        printInt(i);
        printString("'s: ");
        printInt(counter[i]);
        printString("\n");
    }
}
