
kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00004117          	auipc	sp,0x4
    80000004:	4e813103          	ld	sp,1256(sp) # 800044e8 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	00001537          	lui	a0,0x1
    8000000c:	f14025f3          	csrr	a1,mhartid
    80000010:	00158593          	addi	a1,a1,1
    80000014:	02b50533          	mul	a0,a0,a1
    80000018:	00a10133          	add	sp,sp,a0
    8000001c:	5b0010ef          	jal	ra,800015cc <start>

0000000080000020 <spin>:
    80000020:	0000006f          	j	80000020 <spin>
	...

0000000080001000 <trapHandler>:
.align 4
.global trapHandler
trapHandler:
    call handleTrap
    80001000:	14c000ef          	jal	ra,8000114c <handleTrap>
    csrr t0, sepc
    80001004:	141022f3          	csrr	t0,sepc
    addi t0, t0, 4
    80001008:	00428293          	addi	t0,t0,4
    csrw sepc, t0
    8000100c:	14129073          	csrw	sepc,t0
    sret
    80001010:	10200073          	sret
	...

0000000080001020 <_Z9mem_allocm>:
#include "../h/syscall_c.hpp"
#include "../lib/hw.h"

void* mem_alloc(size_t size) {
    80001020:	ff010113          	addi	sp,sp,-16
    80001024:	00813423          	sd	s0,8(sp)
    80001028:	01010413          	addi	s0,sp,16
    if (size == 0) return nullptr;
    8000102c:	02050063          	beqz	a0,8000104c <_Z9mem_allocm+0x2c>

    // 1. zaokruži size (bajtovi) na broj BLOKOVA
    size_t numBlocks = (size + MEM_BLOCK_SIZE - 1) / MEM_BLOCK_SIZE;
    80001030:	03f50593          	addi	a1,a0,63 # 103f <_entry-0x7fffefc1>

    // 2. spakuj registre
    register uint64 code   asm("a0") = 0x01;
    80001034:	00100513          	li	a0,1
    register uint64 blocks asm("a1") = numBlocks;
    80001038:	0065d593          	srli	a1,a1,0x6

    // 3. ecall
    asm volatile("ecall"
        : "=r"(code)
        : "r"(code), "r"(blocks)
        : "memory");
    8000103c:	00000073          	ecall

    // 4. vrati rezultat (bivši a0) kao void*
    return (void*)code;
    80001040:	00813403          	ld	s0,8(sp)
    80001044:	01010113          	addi	sp,sp,16
    80001048:	00008067          	ret
    if (size == 0) return nullptr;
    8000104c:	00000513          	li	a0,0
    80001050:	ff1ff06f          	j	80001040 <_Z9mem_allocm+0x20>

0000000080001054 <_Z5kputcc>:
#include "../h/print.hpp"

// Send one character to the console controller.
void kputc(char c) {
    80001054:	ff010113          	addi	sp,sp,-16
    80001058:	00813423          	sd	s0,8(sp)
    8000105c:	01010413          	addi	s0,sp,16
    // CONSOLE_STATUS is an address (a constant from hw.h). To read the
    // byte living at that address, we reinterpret the integer address as
    // a pointer-to-volatile-char and dereference it. 'volatile' tells the
    // compiler the value can change outside our code (the hardware sets it),
    // so it must actually re-read memory every loop pass, not cache it.
    while ((*(volatile char*)CONSOLE_STATUS & (1 << 5)) == 0) {
    80001060:	00003797          	auipc	a5,0x3
    80001064:	fb07b783          	ld	a5,-80(a5) # 80004010 <CONSOLE_STATUS>
    80001068:	0007c783          	lbu	a5,0(a5)
    8000106c:	0ff7f793          	andi	a5,a5,255
    80001070:	0207f793          	andi	a5,a5,32
    80001074:	fe0786e3          	beqz	a5,80001060 <_Z5kputcc+0xc>
        // spin: bit 5 == 0 means "not ready to accept a char to send"
    }
    // Ready. Write the byte into the transmit-data register.
    *(volatile char*)CONSOLE_TX_DATA = c;
    80001078:	00003797          	auipc	a5,0x3
    8000107c:	f907b783          	ld	a5,-112(a5) # 80004008 <CONSOLE_TX_DATA>
    80001080:	00a78023          	sb	a0,0(a5)
}
    80001084:	00813403          	ld	s0,8(sp)
    80001088:	01010113          	addi	sp,sp,16
    8000108c:	00008067          	ret

0000000080001090 <_Z5kputsPKc>:

// Convenience: print a whole string by sending char by char.
void kputs(const char* s) {
    80001090:	fe010113          	addi	sp,sp,-32
    80001094:	00113c23          	sd	ra,24(sp)
    80001098:	00813823          	sd	s0,16(sp)
    8000109c:	00913423          	sd	s1,8(sp)
    800010a0:	02010413          	addi	s0,sp,32
    800010a4:	00050493          	mv	s1,a0
    while (*s) kputc(*s++);
    800010a8:	0004c503          	lbu	a0,0(s1)
    800010ac:	00050a63          	beqz	a0,800010c0 <_Z5kputsPKc+0x30>
    800010b0:	00148493          	addi	s1,s1,1
    800010b4:	00000097          	auipc	ra,0x0
    800010b8:	fa0080e7          	jalr	-96(ra) # 80001054 <_Z5kputcc>
    800010bc:	fedff06f          	j	800010a8 <_Z5kputsPKc+0x18>
}
    800010c0:	01813083          	ld	ra,24(sp)
    800010c4:	01013403          	ld	s0,16(sp)
    800010c8:	00813483          	ld	s1,8(sp)
    800010cc:	02010113          	addi	sp,sp,32
    800010d0:	00008067          	ret

00000000800010d4 <_Z7kputhexm>:
void kputhex(uint64 n) {
    800010d4:	fe010113          	addi	sp,sp,-32
    800010d8:	00113c23          	sd	ra,24(sp)
    800010dc:	00813823          	sd	s0,16(sp)
    800010e0:	00913423          	sd	s1,8(sp)
    800010e4:	01213023          	sd	s2,0(sp)
    800010e8:	02010413          	addi	s0,sp,32
    800010ec:	00050913          	mv	s2,a0
    kputs("0x");
    800010f0:	00003517          	auipc	a0,0x3
    800010f4:	f3050513          	addi	a0,a0,-208 # 80004020 <CONSOLE_STATUS+0x10>
    800010f8:	00000097          	auipc	ra,0x0
    800010fc:	f98080e7          	jalr	-104(ra) # 80001090 <_Z5kputsPKc>
    for (int shift = 60; shift >= 0; shift -= 4) {
    80001100:	03c00493          	li	s1,60
    80001104:	0140006f          	j	80001118 <_Z7kputhexm+0x44>
        uint64 digit = (n >> shift) & 0xF;
        char c;
        if (digit < 10) {
            c = '0' + digit;
        } else {
            c = 'a' + (digit - 10);
    80001108:	05750513          	addi	a0,a0,87
        }
        kputc(c);
    8000110c:	00000097          	auipc	ra,0x0
    80001110:	f48080e7          	jalr	-184(ra) # 80001054 <_Z5kputcc>
    for (int shift = 60; shift >= 0; shift -= 4) {
    80001114:	ffc4849b          	addiw	s1,s1,-4
    80001118:	0004ce63          	bltz	s1,80001134 <_Z7kputhexm+0x60>
        uint64 digit = (n >> shift) & 0xF;
    8000111c:	00995533          	srl	a0,s2,s1
    80001120:	00f57513          	andi	a0,a0,15
        if (digit < 10) {
    80001124:	00900793          	li	a5,9
    80001128:	fea7e0e3          	bltu	a5,a0,80001108 <_Z7kputhexm+0x34>
            c = '0' + digit;
    8000112c:	03050513          	addi	a0,a0,48
    80001130:	fddff06f          	j	8000110c <_Z7kputhexm+0x38>
    }
    80001134:	01813083          	ld	ra,24(sp)
    80001138:	01013403          	ld	s0,16(sp)
    8000113c:	00813483          	ld	s1,8(sp)
    80001140:	00013903          	ld	s2,0(sp)
    80001144:	02010113          	addi	sp,sp,32
    80001148:	00008067          	ret

000000008000114c <handleTrap>:
#include "../lib/hw.h"
#include "../h/print.hpp"
#include "../h/MemoryAllocator.hpp"

extern "C" uint64 handleTrap(uint64 a0, uint64 a1, uint64 a2, uint64 a3) {
    8000114c:	fd010113          	addi	sp,sp,-48
    80001150:	02113423          	sd	ra,40(sp)
    80001154:	02813023          	sd	s0,32(sp)
    80001158:	00913c23          	sd	s1,24(sp)
    8000115c:	01213823          	sd	s2,16(sp)
    80001160:	01313423          	sd	s3,8(sp)
    80001164:	03010413          	addi	s0,sp,48
    80001168:	00050913          	mv	s2,a0
    8000116c:	00058993          	mv	s3,a1
    kputs("   [trap] usao\n");
    80001170:	00003517          	auipc	a0,0x3
    80001174:	eb850513          	addi	a0,a0,-328 # 80004028 <CONSOLE_STATUS+0x18>
    80001178:	00000097          	auipc	ra,0x0
    8000117c:	f18080e7          	jalr	-232(ra) # 80001090 <_Z5kputsPKc>
    uint64 cause;
    asm volatile("csrr %0, scause" : "=r" (cause));
    80001180:	142024f3          	csrr	s1,scause
    kputs("   [trap] cause = "); kputhex(cause); kputs("\n");
    80001184:	00003517          	auipc	a0,0x3
    80001188:	eb450513          	addi	a0,a0,-332 # 80004038 <CONSOLE_STATUS+0x28>
    8000118c:	00000097          	auipc	ra,0x0
    80001190:	f04080e7          	jalr	-252(ra) # 80001090 <_Z5kputsPKc>
    80001194:	00048513          	mv	a0,s1
    80001198:	00000097          	auipc	ra,0x0
    8000119c:	f3c080e7          	jalr	-196(ra) # 800010d4 <_Z7kputhexm>
    800011a0:	00003517          	auipc	a0,0x3
    800011a4:	ec050513          	addi	a0,a0,-320 # 80004060 <CONSOLE_STATUS+0x50>
    800011a8:	00000097          	auipc	ra,0x0
    800011ac:	ee8080e7          	jalr	-280(ra) # 80001090 <_Z5kputsPKc>

    if (cause == 8 || cause == 9) {   // ecall
    800011b0:	ff848493          	addi	s1,s1,-8
    800011b4:	00100793          	li	a5,1
    800011b8:	0297f263          	bgeu	a5,s1,800011dc <handleTrap+0x90>
                return (uint64) MemoryAllocator::alloc((size_t)a1);   // a1 = size
            case 0x02:
                return (uint64) MemoryAllocator::free((void*)a1);    // a1 = pointer
        }
    }
    return 0;
    800011bc:	00000513          	li	a0,0
    800011c0:	02813083          	ld	ra,40(sp)
    800011c4:	02013403          	ld	s0,32(sp)
    800011c8:	01813483          	ld	s1,24(sp)
    800011cc:	01013903          	ld	s2,16(sp)
    800011d0:	00813983          	ld	s3,8(sp)
    800011d4:	03010113          	addi	sp,sp,48
    800011d8:	00008067          	ret
        switch (a0) {
    800011dc:	00f90a63          	beq	s2,a5,800011f0 <handleTrap+0xa4>
    800011e0:	00200793          	li	a5,2
    800011e4:	00f90e63          	beq	s2,a5,80001200 <handleTrap+0xb4>
    800011e8:	00000513          	li	a0,0
    800011ec:	fd5ff06f          	j	800011c0 <handleTrap+0x74>
                return (uint64) MemoryAllocator::alloc((size_t)a1);   // a1 = size
    800011f0:	00098513          	mv	a0,s3
    800011f4:	00000097          	auipc	ra,0x0
    800011f8:	0ec080e7          	jalr	236(ra) # 800012e0 <_ZN15MemoryAllocator5allocEm>
    800011fc:	fc5ff06f          	j	800011c0 <handleTrap+0x74>
                return (uint64) MemoryAllocator::free((void*)a1);    // a1 = pointer
    80001200:	00098513          	mv	a0,s3
    80001204:	00000097          	auipc	ra,0x0
    80001208:	218080e7          	jalr	536(ra) # 8000141c <_ZN15MemoryAllocator4freeEPv>
    8000120c:	fb5ff06f          	j	800011c0 <handleTrap+0x74>

0000000080001210 <_Z8userMainv>:
// src/userMain.cpp
#include "../h/syscall_c.hpp"
#include "../h/print.hpp"

void userMain() {
    80001210:	fe010113          	addi	sp,sp,-32
    80001214:	00113c23          	sd	ra,24(sp)
    80001218:	00813823          	sd	s0,16(sp)
    8000121c:	00913423          	sd	s1,8(sp)
    80001220:	02010413          	addi	s0,sp,32
    kputs("   pre mem_alloc\n");
    80001224:	00003517          	auipc	a0,0x3
    80001228:	e2c50513          	addi	a0,a0,-468 # 80004050 <CONSOLE_STATUS+0x40>
    8000122c:	00000097          	auipc	ra,0x0
    80001230:	e64080e7          	jalr	-412(ra) # 80001090 <_Z5kputsPKc>
    void* p = mem_alloc(100);
    80001234:	06400513          	li	a0,100
    80001238:	00000097          	auipc	ra,0x0
    8000123c:	de8080e7          	jalr	-536(ra) # 80001020 <_Z9mem_allocm>
    80001240:	00050493          	mv	s1,a0
    kputs("   posle mem_alloc\n");
    80001244:	00003517          	auipc	a0,0x3
    80001248:	e2450513          	addi	a0,a0,-476 # 80004068 <CONSOLE_STATUS+0x58>
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	e44080e7          	jalr	-444(ra) # 80001090 <_Z5kputsPKc>
    kputs("   p (preko ecall) = "); kputhex((uint64)p); kputs("\n");
    80001254:	00003517          	auipc	a0,0x3
    80001258:	e2c50513          	addi	a0,a0,-468 # 80004080 <CONSOLE_STATUS+0x70>
    8000125c:	00000097          	auipc	ra,0x0
    80001260:	e34080e7          	jalr	-460(ra) # 80001090 <_Z5kputsPKc>
    80001264:	00048513          	mv	a0,s1
    80001268:	00000097          	auipc	ra,0x0
    8000126c:	e6c080e7          	jalr	-404(ra) # 800010d4 <_Z7kputhexm>
    80001270:	00003517          	auipc	a0,0x3
    80001274:	df050513          	addi	a0,a0,-528 # 80004060 <CONSOLE_STATUS+0x50>
    80001278:	00000097          	auipc	ra,0x0
    8000127c:	e18080e7          	jalr	-488(ra) # 80001090 <_Z5kputsPKc>
    80001280:	01813083          	ld	ra,24(sp)
    80001284:	01013403          	ld	s0,16(sp)
    80001288:	00813483          	ld	s1,8(sp)
    8000128c:	02010113          	addi	sp,sp,32
    80001290:	00008067          	ret

0000000080001294 <_ZN15MemoryAllocator4initEv>:
#include "../h/MemoryAllocator.hpp"
#include "../lib/hw.h"
#include "../h/print.hpp"
MemoryAllocator::FreeBlock* MemoryAllocator::freeListHead = nullptr;

void MemoryAllocator::init() {
    80001294:	ff010113          	addi	sp,sp,-16
    80001298:	00813423          	sd	s0,8(sp)
    8000129c:	01010413          	addi	s0,sp,16
    freeListHead = (FreeBlock*)HEAP_START_ADDR;
    800012a0:	00003797          	auipc	a5,0x3
    800012a4:	23878793          	addi	a5,a5,568 # 800044d8 <HEAP_START_ADDR>
    800012a8:	0007b683          	ld	a3,0(a5)
    800012ac:	00003717          	auipc	a4,0x3
    800012b0:	25470713          	addi	a4,a4,596 # 80004500 <_ZN15MemoryAllocator12freeListHeadE>
    800012b4:	00d73023          	sd	a3,0(a4)
    freeListHead->next = nullptr;
    800012b8:	0006b023          	sd	zero,0(a3)
    freeListHead->size = (char*)HEAP_END_ADDR - (char*)HEAP_START_ADDR;
    800012bc:	0007b683          	ld	a3,0(a5)
    800012c0:	00073703          	ld	a4,0(a4)
    800012c4:	00003797          	auipc	a5,0x3
    800012c8:	20c7b783          	ld	a5,524(a5) # 800044d0 <HEAP_END_ADDR>
    800012cc:	40d787b3          	sub	a5,a5,a3
    800012d0:	00f73423          	sd	a5,8(a4)
}
    800012d4:	00813403          	ld	s0,8(sp)
    800012d8:	01010113          	addi	sp,sp,16
    800012dc:	00008067          	ret

00000000800012e0 <_ZN15MemoryAllocator5allocEm>:
void* MemoryAllocator::alloc(size_t size){
    800012e0:	ff010113          	addi	sp,sp,-16
    800012e4:	00813423          	sd	s0,8(sp)
    800012e8:	01010413          	addi	s0,sp,16
    if (size == 0) {
    800012ec:	08050a63          	beqz	a0,80001380 <_ZN15MemoryAllocator5allocEm+0xa0>
        return nullptr;
    }
    //rounding ((n + B - 1) / B) * B
    size_t n = size + sizeof(FreeBlock);
    size_t roundedSize = ((n + MEM_BLOCK_SIZE - 1) / MEM_BLOCK_SIZE) * MEM_BLOCK_SIZE; //velicina koju treba alocirati
    800012f0:	04f50513          	addi	a0,a0,79
    800012f4:	fc057713          	andi	a4,a0,-64

    FreeBlock* curr = freeListHead;
    800012f8:	00003517          	auipc	a0,0x3
    800012fc:	20853503          	ld	a0,520(a0) # 80004500 <_ZN15MemoryAllocator12freeListHeadE>
    FreeBlock* prev = nullptr;
    80001300:	00000693          	li	a3,0
    while(curr != nullptr){
    80001304:	04050263          	beqz	a0,80001348 <_ZN15MemoryAllocator5allocEm+0x68>
        if(curr->size >= roundedSize){
    80001308:	00853783          	ld	a5,8(a0)
    8000130c:	00e7f863          	bgeu	a5,a4,8000131c <_ZN15MemoryAllocator5allocEm+0x3c>
                    freeListHead = curr->next;
                }
            }
            return (char*)curr + sizeof(FreeBlock);
        }
        prev = curr;
    80001310:	00050693          	mv	a3,a0
        curr = curr->next;
    80001314:	00053503          	ld	a0,0(a0)
    while(curr != nullptr){
    80001318:	fedff06f          	j	80001304 <_ZN15MemoryAllocator5allocEm+0x24>
            size_t remainder = curr->size - roundedSize;
    8000131c:	40e787b3          	sub	a5,a5,a4
            if (remainder >= MEM_BLOCK_SIZE) {
    80001320:	03f00613          	li	a2,63
    80001324:	02f67e63          	bgeu	a2,a5,80001360 <_ZN15MemoryAllocator5allocEm+0x80>
                FreeBlock* newBlock = (FreeBlock*)((char*)curr + roundedSize);
    80001328:	00e50633          	add	a2,a0,a4
                newBlock->size = remainder;
    8000132c:	00f63423          	sd	a5,8(a2)
                newBlock->next = curr->next;
    80001330:	00053783          	ld	a5,0(a0)
    80001334:	00f63023          	sd	a5,0(a2)
                if (prev != nullptr) {
    80001338:	00068e63          	beqz	a3,80001354 <_ZN15MemoryAllocator5allocEm+0x74>
                    prev->next = newBlock;
    8000133c:	00c6b023          	sd	a2,0(a3)
                curr->size = roundedSize;
    80001340:	00e53423          	sd	a4,8(a0)
            return (char*)curr + sizeof(FreeBlock);
    80001344:	01050513          	addi	a0,a0,16
    }
    return nullptr;
}
    80001348:	00813403          	ld	s0,8(sp)
    8000134c:	01010113          	addi	sp,sp,16
    80001350:	00008067          	ret
                    freeListHead = newBlock;
    80001354:	00003797          	auipc	a5,0x3
    80001358:	1ac7b623          	sd	a2,428(a5) # 80004500 <_ZN15MemoryAllocator12freeListHeadE>
    8000135c:	fe5ff06f          	j	80001340 <_ZN15MemoryAllocator5allocEm+0x60>
                if (prev != nullptr) {
    80001360:	00068863          	beqz	a3,80001370 <_ZN15MemoryAllocator5allocEm+0x90>
                    prev->next = curr->next;
    80001364:	00053783          	ld	a5,0(a0)
    80001368:	00f6b023          	sd	a5,0(a3)
    8000136c:	fd9ff06f          	j	80001344 <_ZN15MemoryAllocator5allocEm+0x64>
                    freeListHead = curr->next;
    80001370:	00053783          	ld	a5,0(a0)
    80001374:	00003717          	auipc	a4,0x3
    80001378:	18f73623          	sd	a5,396(a4) # 80004500 <_ZN15MemoryAllocator12freeListHeadE>
    8000137c:	fc9ff06f          	j	80001344 <_ZN15MemoryAllocator5allocEm+0x64>
        return nullptr;
    80001380:	00000513          	li	a0,0
    80001384:	fc5ff06f          	j	80001348 <_ZN15MemoryAllocator5allocEm+0x68>

0000000080001388 <_ZN15MemoryAllocator13printFreeListEv>:
void MemoryAllocator::printFreeList() {
    80001388:	fe010113          	addi	sp,sp,-32
    8000138c:	00113c23          	sd	ra,24(sp)
    80001390:	00813823          	sd	s0,16(sp)
    80001394:	00913423          	sd	s1,8(sp)
    80001398:	02010413          	addi	s0,sp,32
    FreeBlock* curr = freeListHead;
    8000139c:	00003497          	auipc	s1,0x3
    800013a0:	1644b483          	ld	s1,356(s1) # 80004500 <_ZN15MemoryAllocator12freeListHeadE>
    kputs("Free list:\n");
    800013a4:	00003517          	auipc	a0,0x3
    800013a8:	cf450513          	addi	a0,a0,-780 # 80004098 <CONSOLE_STATUS+0x88>
    800013ac:	00000097          	auipc	ra,0x0
    800013b0:	ce4080e7          	jalr	-796(ra) # 80001090 <_Z5kputsPKc>
    while (curr != nullptr) {
    800013b4:	04048a63          	beqz	s1,80001408 <_ZN15MemoryAllocator13printFreeListEv+0x80>
        kputs("  Block at ");
    800013b8:	00003517          	auipc	a0,0x3
    800013bc:	cf050513          	addi	a0,a0,-784 # 800040a8 <CONSOLE_STATUS+0x98>
    800013c0:	00000097          	auipc	ra,0x0
    800013c4:	cd0080e7          	jalr	-816(ra) # 80001090 <_Z5kputsPKc>
        kputhex((uint64)curr);
    800013c8:	00048513          	mv	a0,s1
    800013cc:	00000097          	auipc	ra,0x0
    800013d0:	d08080e7          	jalr	-760(ra) # 800010d4 <_Z7kputhexm>
        kputs(", size: ");
    800013d4:	00003517          	auipc	a0,0x3
    800013d8:	ce450513          	addi	a0,a0,-796 # 800040b8 <CONSOLE_STATUS+0xa8>
    800013dc:	00000097          	auipc	ra,0x0
    800013e0:	cb4080e7          	jalr	-844(ra) # 80001090 <_Z5kputsPKc>
        kputhex(curr->size);
    800013e4:	0084b503          	ld	a0,8(s1)
    800013e8:	00000097          	auipc	ra,0x0
    800013ec:	cec080e7          	jalr	-788(ra) # 800010d4 <_Z7kputhexm>
        kputs("\n");
    800013f0:	00003517          	auipc	a0,0x3
    800013f4:	c7050513          	addi	a0,a0,-912 # 80004060 <CONSOLE_STATUS+0x50>
    800013f8:	00000097          	auipc	ra,0x0
    800013fc:	c98080e7          	jalr	-872(ra) # 80001090 <_Z5kputsPKc>
        curr = curr->next;
    80001400:	0004b483          	ld	s1,0(s1)
    while (curr != nullptr) {
    80001404:	fb1ff06f          	j	800013b4 <_ZN15MemoryAllocator13printFreeListEv+0x2c>
    }
}
    80001408:	01813083          	ld	ra,24(sp)
    8000140c:	01013403          	ld	s0,16(sp)
    80001410:	00813483          	ld	s1,8(sp)
    80001414:	02010113          	addi	sp,sp,32
    80001418:	00008067          	ret

000000008000141c <_ZN15MemoryAllocator4freeEPv>:
int MemoryAllocator::free(void* ptr){
    8000141c:	ff010113          	addi	sp,sp,-16
    80001420:	00813423          	sd	s0,8(sp)
    80001424:	01010413          	addi	s0,sp,16
    if (ptr == nullptr) return -1;
    80001428:	12050663          	beqz	a0,80001554 <_ZN15MemoryAllocator4freeEPv+0x138>
    FreeBlock* curr = freeListHead;
    8000142c:	00003797          	auipc	a5,0x3
    80001430:	0d47b783          	ld	a5,212(a5) # 80004500 <_ZN15MemoryAllocator12freeListHeadE>
    FreeBlock* prev = nullptr;
    FreeBlock* block = (FreeBlock*)((char*)ptr - sizeof(FreeBlock));
    80001434:	ff050693          	addi	a3,a0,-16
    FreeBlock* prev = nullptr;
    80001438:	00000713          	li	a4,0
    while(curr != nullptr && curr < block){
    8000143c:	00078a63          	beqz	a5,80001450 <_ZN15MemoryAllocator4freeEPv+0x34>
    80001440:	00d7f863          	bgeu	a5,a3,80001450 <_ZN15MemoryAllocator4freeEPv+0x34>
        prev = curr;
    80001444:	00078713          	mv	a4,a5
        curr = curr->next;
    80001448:	0007b783          	ld	a5,0(a5)
    while(curr != nullptr && curr < block){
    8000144c:	ff1ff06f          	j	8000143c <_ZN15MemoryAllocator4freeEPv+0x20>
    }
    
    bool mergePrev = (prev != nullptr) && ((char*)prev + prev->size == (char*)block);
    80001450:	04070263          	beqz	a4,80001494 <_ZN15MemoryAllocator4freeEPv+0x78>
    80001454:	00873603          	ld	a2,8(a4)
    80001458:	00c70633          	add	a2,a4,a2
    8000145c:	04d60063          	beq	a2,a3,8000149c <_ZN15MemoryAllocator4freeEPv+0x80>
    80001460:	00000613          	li	a2,0
    bool mergeNext = (curr != nullptr) && ((char*)block + block->size == (char*)curr);
    80001464:	04078063          	beqz	a5,800014a4 <_ZN15MemoryAllocator4freeEPv+0x88>
    80001468:	ff853583          	ld	a1,-8(a0)
    8000146c:	00b685b3          	add	a1,a3,a1
    80001470:	02f58e63          	beq	a1,a5,800014ac <_ZN15MemoryAllocator4freeEPv+0x90>
    80001474:	00000593          	li	a1,0

    if (!mergePrev && !mergeNext) {
    80001478:	04061663          	bnez	a2,800014c4 <_ZN15MemoryAllocator4freeEPv+0xa8>
    8000147c:	04059463          	bnez	a1,800014c4 <_ZN15MemoryAllocator4freeEPv+0xa8>
        // neither merge
        block->next = curr;
    80001480:	fef53823          	sd	a5,-16(a0)
        if (prev != nullptr) {
    80001484:	02070863          	beqz	a4,800014b4 <_ZN15MemoryAllocator4freeEPv+0x98>
            prev->next = block;
    80001488:	00d73023          	sd	a3,0(a4)
    } else {
        // merge with both
        prev->size += block->size + curr->size;
        prev->next = curr->next;
    }
    return 0;
    8000148c:	00000513          	li	a0,0
    80001490:	0b80006f          	j	80001548 <_ZN15MemoryAllocator4freeEPv+0x12c>
    bool mergePrev = (prev != nullptr) && ((char*)prev + prev->size == (char*)block);
    80001494:	00000613          	li	a2,0
    80001498:	fcdff06f          	j	80001464 <_ZN15MemoryAllocator4freeEPv+0x48>
    8000149c:	00100613          	li	a2,1
    800014a0:	fc5ff06f          	j	80001464 <_ZN15MemoryAllocator4freeEPv+0x48>
    bool mergeNext = (curr != nullptr) && ((char*)block + block->size == (char*)curr);
    800014a4:	00000593          	li	a1,0
    800014a8:	fd1ff06f          	j	80001478 <_ZN15MemoryAllocator4freeEPv+0x5c>
    800014ac:	00100593          	li	a1,1
    800014b0:	fc9ff06f          	j	80001478 <_ZN15MemoryAllocator4freeEPv+0x5c>
            freeListHead = block;
    800014b4:	00003797          	auipc	a5,0x3
    800014b8:	04d7b623          	sd	a3,76(a5) # 80004500 <_ZN15MemoryAllocator12freeListHeadE>
    return 0;
    800014bc:	00000513          	li	a0,0
    800014c0:	0880006f          	j	80001548 <_ZN15MemoryAllocator4freeEPv+0x12c>
    } else if (mergePrev && !mergeNext) {
    800014c4:	02060063          	beqz	a2,800014e4 <_ZN15MemoryAllocator4freeEPv+0xc8>
    800014c8:	00059e63          	bnez	a1,800014e4 <_ZN15MemoryAllocator4freeEPv+0xc8>
        prev->size += block->size;
    800014cc:	ff853683          	ld	a3,-8(a0)
    800014d0:	00873783          	ld	a5,8(a4)
    800014d4:	00d787b3          	add	a5,a5,a3
    800014d8:	00f73423          	sd	a5,8(a4)
    return 0;
    800014dc:	00000513          	li	a0,0
        prev->size += block->size;
    800014e0:	0680006f          	j	80001548 <_ZN15MemoryAllocator4freeEPv+0x12c>
    } else if (!mergePrev && mergeNext) {
    800014e4:	04061063          	bnez	a2,80001524 <_ZN15MemoryAllocator4freeEPv+0x108>
    800014e8:	02058e63          	beqz	a1,80001524 <_ZN15MemoryAllocator4freeEPv+0x108>
        block->size += curr->size;
    800014ec:	0087b583          	ld	a1,8(a5)
    800014f0:	ff853603          	ld	a2,-8(a0)
    800014f4:	00b60633          	add	a2,a2,a1
    800014f8:	fec53c23          	sd	a2,-8(a0)
        block->next = curr->next;
    800014fc:	0007b783          	ld	a5,0(a5)
    80001500:	fef53823          	sd	a5,-16(a0)
        if (prev != nullptr) {
    80001504:	00070863          	beqz	a4,80001514 <_ZN15MemoryAllocator4freeEPv+0xf8>
            prev->next = block;
    80001508:	00d73023          	sd	a3,0(a4)
    return 0;
    8000150c:	00000513          	li	a0,0
    80001510:	0380006f          	j	80001548 <_ZN15MemoryAllocator4freeEPv+0x12c>
            freeListHead = block;
    80001514:	00003797          	auipc	a5,0x3
    80001518:	fed7b623          	sd	a3,-20(a5) # 80004500 <_ZN15MemoryAllocator12freeListHeadE>
    return 0;
    8000151c:	00000513          	li	a0,0
    80001520:	0280006f          	j	80001548 <_ZN15MemoryAllocator4freeEPv+0x12c>
        prev->size += block->size + curr->size;
    80001524:	ff853683          	ld	a3,-8(a0)
    80001528:	0087b603          	ld	a2,8(a5)
    8000152c:	00c68633          	add	a2,a3,a2
    80001530:	00873683          	ld	a3,8(a4)
    80001534:	00c686b3          	add	a3,a3,a2
    80001538:	00d73423          	sd	a3,8(a4)
        prev->next = curr->next;
    8000153c:	0007b783          	ld	a5,0(a5)
    80001540:	00f73023          	sd	a5,0(a4)
    return 0;
    80001544:	00000513          	li	a0,0
    80001548:	00813403          	ld	s0,8(sp)
    8000154c:	01010113          	addi	sp,sp,16
    80001550:	00008067          	ret
    if (ptr == nullptr) return -1;
    80001554:	fff00513          	li	a0,-1
    80001558:	ff1ff06f          	j	80001548 <_ZN15MemoryAllocator4freeEPv+0x12c>

000000008000155c <main>:
#include "../h/memoryAllocator.hpp"
extern "C" void trapHandler();

void userMain();   // forward declaration: defined elsewhere (your test file)

int main() {
    8000155c:	ff010113          	addi	sp,sp,-16
    80001560:	00113423          	sd	ra,8(sp)
    80001564:	00813023          	sd	s0,0(sp)
    80001568:	01010413          	addi	s0,sp,16
    kputs(">> kernel: starting\n");
    8000156c:	00003517          	auipc	a0,0x3
    80001570:	b5c50513          	addi	a0,a0,-1188 # 800040c8 <CONSOLE_STATUS+0xb8>
    80001574:	00000097          	auipc	ra,0x0
    80001578:	b1c080e7          	jalr	-1252(ra) # 80001090 <_Z5kputsPKc>

    uint64 addr = (uint64)&trapHandler;              // adresa rutine kao broj
    8000157c:	00000797          	auipc	a5,0x0
    80001580:	a8478793          	addi	a5,a5,-1404 # 80001000 <trapHandler>
    asm volatile("csrw stvec, %0" : : "r" (addr));   // upisi je u stvec
    80001584:	10579073          	csrw	stvec,a5

    MemoryAllocator::init();   // inicijalizuj slobodnu listu
    80001588:	00000097          	auipc	ra,0x0
    8000158c:	d0c080e7          	jalr	-756(ra) # 80001294 <_ZN15MemoryAllocator4initEv>

    userMain();    // THE CHEAT: calling it as a plain function for now.
    80001590:	00000097          	auipc	ra,0x0
    80001594:	c80080e7          	jalr	-896(ra) # 80001210 <_Z8userMainv>
                   // In the real kernel this becomes "wrap userMain as the
                   // body of the first thread and let the scheduler run it."

    kputs(">> kernel: userMain returned, halting\n");
    80001598:	00003517          	auipc	a0,0x3
    8000159c:	b4850513          	addi	a0,a0,-1208 # 800040e0 <CONSOLE_STATUS+0xd0>
    800015a0:	00000097          	auipc	ra,0x0
    800015a4:	af0080e7          	jalr	-1296(ra) # 80001090 <_Z5kputsPKc>

    // Halt the emulator: writing the 32-bit value 0x5555 to physical
    // address 0x100000 is qemu's "guest asked to power off" signal, so
    // `make qemu` returns to your shell instead of hanging.
    *(volatile int*)0x100000 = 0x5555;
    800015a8:	00100737          	lui	a4,0x100
    800015ac:	000057b7          	lui	a5,0x5
    800015b0:	5557879b          	addiw	a5,a5,1365
    800015b4:	00f72023          	sw	a5,0(a4) # 100000 <_entry-0x7ff00000>

    return 0;   // never really reached, but keeps the signature honest
    800015b8:	00000513          	li	a0,0
    800015bc:	00813083          	ld	ra,8(sp)
    800015c0:	00013403          	ld	s0,0(sp)
    800015c4:	01010113          	addi	sp,sp,16
    800015c8:	00008067          	ret

00000000800015cc <start>:
    800015cc:	ff010113          	addi	sp,sp,-16
    800015d0:	00813423          	sd	s0,8(sp)
    800015d4:	01010413          	addi	s0,sp,16
    800015d8:	300027f3          	csrr	a5,mstatus
    800015dc:	ffffe737          	lui	a4,0xffffe
    800015e0:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fff907f>
    800015e4:	00e7f7b3          	and	a5,a5,a4
    800015e8:	00001737          	lui	a4,0x1
    800015ec:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800015f0:	00e7e7b3          	or	a5,a5,a4
    800015f4:	30079073          	csrw	mstatus,a5
    800015f8:	00000797          	auipc	a5,0x0
    800015fc:	16078793          	addi	a5,a5,352 # 80001758 <system_main>
    80001600:	34179073          	csrw	mepc,a5
    80001604:	00000793          	li	a5,0
    80001608:	18079073          	csrw	satp,a5
    8000160c:	000107b7          	lui	a5,0x10
    80001610:	fff78793          	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80001614:	30279073          	csrw	medeleg,a5
    80001618:	30379073          	csrw	mideleg,a5
    8000161c:	104027f3          	csrr	a5,sie
    80001620:	2227e793          	ori	a5,a5,546
    80001624:	10479073          	csrw	sie,a5
    80001628:	fff00793          	li	a5,-1
    8000162c:	00a7d793          	srli	a5,a5,0xa
    80001630:	3b079073          	csrw	pmpaddr0,a5
    80001634:	00f00793          	li	a5,15
    80001638:	3a079073          	csrw	pmpcfg0,a5
    8000163c:	f14027f3          	csrr	a5,mhartid
    80001640:	0200c737          	lui	a4,0x200c
    80001644:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80001648:	0007869b          	sext.w	a3,a5
    8000164c:	00269713          	slli	a4,a3,0x2
    80001650:	000f4637          	lui	a2,0xf4
    80001654:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80001658:	00d70733          	add	a4,a4,a3
    8000165c:	0037979b          	slliw	a5,a5,0x3
    80001660:	020046b7          	lui	a3,0x2004
    80001664:	00d787b3          	add	a5,a5,a3
    80001668:	00c585b3          	add	a1,a1,a2
    8000166c:	00371693          	slli	a3,a4,0x3
    80001670:	00003717          	auipc	a4,0x3
    80001674:	ec070713          	addi	a4,a4,-320 # 80004530 <timer_scratch>
    80001678:	00b7b023          	sd	a1,0(a5)
    8000167c:	00d70733          	add	a4,a4,a3
    80001680:	00f73c23          	sd	a5,24(a4)
    80001684:	02c73023          	sd	a2,32(a4)
    80001688:	34071073          	csrw	mscratch,a4
    8000168c:	00000797          	auipc	a5,0x0
    80001690:	6e478793          	addi	a5,a5,1764 # 80001d70 <timervec>
    80001694:	30579073          	csrw	mtvec,a5
    80001698:	300027f3          	csrr	a5,mstatus
    8000169c:	0087e793          	ori	a5,a5,8
    800016a0:	30079073          	csrw	mstatus,a5
    800016a4:	304027f3          	csrr	a5,mie
    800016a8:	0807e793          	ori	a5,a5,128
    800016ac:	30479073          	csrw	mie,a5
    800016b0:	f14027f3          	csrr	a5,mhartid
    800016b4:	0007879b          	sext.w	a5,a5
    800016b8:	00078213          	mv	tp,a5
    800016bc:	30200073          	mret
    800016c0:	00813403          	ld	s0,8(sp)
    800016c4:	01010113          	addi	sp,sp,16
    800016c8:	00008067          	ret

00000000800016cc <timerinit>:
    800016cc:	ff010113          	addi	sp,sp,-16
    800016d0:	00813423          	sd	s0,8(sp)
    800016d4:	01010413          	addi	s0,sp,16
    800016d8:	f14027f3          	csrr	a5,mhartid
    800016dc:	0200c737          	lui	a4,0x200c
    800016e0:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    800016e4:	0007869b          	sext.w	a3,a5
    800016e8:	00269713          	slli	a4,a3,0x2
    800016ec:	000f4637          	lui	a2,0xf4
    800016f0:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    800016f4:	00d70733          	add	a4,a4,a3
    800016f8:	0037979b          	slliw	a5,a5,0x3
    800016fc:	020046b7          	lui	a3,0x2004
    80001700:	00d787b3          	add	a5,a5,a3
    80001704:	00c585b3          	add	a1,a1,a2
    80001708:	00371693          	slli	a3,a4,0x3
    8000170c:	00003717          	auipc	a4,0x3
    80001710:	e2470713          	addi	a4,a4,-476 # 80004530 <timer_scratch>
    80001714:	00b7b023          	sd	a1,0(a5)
    80001718:	00d70733          	add	a4,a4,a3
    8000171c:	00f73c23          	sd	a5,24(a4)
    80001720:	02c73023          	sd	a2,32(a4)
    80001724:	34071073          	csrw	mscratch,a4
    80001728:	00000797          	auipc	a5,0x0
    8000172c:	64878793          	addi	a5,a5,1608 # 80001d70 <timervec>
    80001730:	30579073          	csrw	mtvec,a5
    80001734:	300027f3          	csrr	a5,mstatus
    80001738:	0087e793          	ori	a5,a5,8
    8000173c:	30079073          	csrw	mstatus,a5
    80001740:	304027f3          	csrr	a5,mie
    80001744:	0807e793          	ori	a5,a5,128
    80001748:	30479073          	csrw	mie,a5
    8000174c:	00813403          	ld	s0,8(sp)
    80001750:	01010113          	addi	sp,sp,16
    80001754:	00008067          	ret

0000000080001758 <system_main>:
    80001758:	fe010113          	addi	sp,sp,-32
    8000175c:	00813823          	sd	s0,16(sp)
    80001760:	00913423          	sd	s1,8(sp)
    80001764:	00113c23          	sd	ra,24(sp)
    80001768:	02010413          	addi	s0,sp,32
    8000176c:	00000097          	auipc	ra,0x0
    80001770:	0c4080e7          	jalr	196(ra) # 80001830 <cpuid>
    80001774:	00003497          	auipc	s1,0x3
    80001778:	d9448493          	addi	s1,s1,-620 # 80004508 <started>
    8000177c:	02050263          	beqz	a0,800017a0 <system_main+0x48>
    80001780:	0004a783          	lw	a5,0(s1)
    80001784:	0007879b          	sext.w	a5,a5
    80001788:	fe078ce3          	beqz	a5,80001780 <system_main+0x28>
    8000178c:	0ff0000f          	fence
    80001790:	00003517          	auipc	a0,0x3
    80001794:	9a850513          	addi	a0,a0,-1624 # 80004138 <CONSOLE_STATUS+0x128>
    80001798:	00001097          	auipc	ra,0x1
    8000179c:	a74080e7          	jalr	-1420(ra) # 8000220c <panic>
    800017a0:	00001097          	auipc	ra,0x1
    800017a4:	9c8080e7          	jalr	-1592(ra) # 80002168 <consoleinit>
    800017a8:	00001097          	auipc	ra,0x1
    800017ac:	154080e7          	jalr	340(ra) # 800028fc <printfinit>
    800017b0:	00003517          	auipc	a0,0x3
    800017b4:	8b050513          	addi	a0,a0,-1872 # 80004060 <CONSOLE_STATUS+0x50>
    800017b8:	00001097          	auipc	ra,0x1
    800017bc:	ab0080e7          	jalr	-1360(ra) # 80002268 <__printf>
    800017c0:	00003517          	auipc	a0,0x3
    800017c4:	94850513          	addi	a0,a0,-1720 # 80004108 <CONSOLE_STATUS+0xf8>
    800017c8:	00001097          	auipc	ra,0x1
    800017cc:	aa0080e7          	jalr	-1376(ra) # 80002268 <__printf>
    800017d0:	00003517          	auipc	a0,0x3
    800017d4:	89050513          	addi	a0,a0,-1904 # 80004060 <CONSOLE_STATUS+0x50>
    800017d8:	00001097          	auipc	ra,0x1
    800017dc:	a90080e7          	jalr	-1392(ra) # 80002268 <__printf>
    800017e0:	00001097          	auipc	ra,0x1
    800017e4:	4a8080e7          	jalr	1192(ra) # 80002c88 <kinit>
    800017e8:	00000097          	auipc	ra,0x0
    800017ec:	148080e7          	jalr	328(ra) # 80001930 <trapinit>
    800017f0:	00000097          	auipc	ra,0x0
    800017f4:	16c080e7          	jalr	364(ra) # 8000195c <trapinithart>
    800017f8:	00000097          	auipc	ra,0x0
    800017fc:	5b8080e7          	jalr	1464(ra) # 80001db0 <plicinit>
    80001800:	00000097          	auipc	ra,0x0
    80001804:	5d8080e7          	jalr	1496(ra) # 80001dd8 <plicinithart>
    80001808:	00000097          	auipc	ra,0x0
    8000180c:	078080e7          	jalr	120(ra) # 80001880 <userinit>
    80001810:	0ff0000f          	fence
    80001814:	00100793          	li	a5,1
    80001818:	00003517          	auipc	a0,0x3
    8000181c:	90850513          	addi	a0,a0,-1784 # 80004120 <CONSOLE_STATUS+0x110>
    80001820:	00f4a023          	sw	a5,0(s1)
    80001824:	00001097          	auipc	ra,0x1
    80001828:	a44080e7          	jalr	-1468(ra) # 80002268 <__printf>
    8000182c:	0000006f          	j	8000182c <system_main+0xd4>

0000000080001830 <cpuid>:
    80001830:	ff010113          	addi	sp,sp,-16
    80001834:	00813423          	sd	s0,8(sp)
    80001838:	01010413          	addi	s0,sp,16
    8000183c:	00020513          	mv	a0,tp
    80001840:	00813403          	ld	s0,8(sp)
    80001844:	0005051b          	sext.w	a0,a0
    80001848:	01010113          	addi	sp,sp,16
    8000184c:	00008067          	ret

0000000080001850 <mycpu>:
    80001850:	ff010113          	addi	sp,sp,-16
    80001854:	00813423          	sd	s0,8(sp)
    80001858:	01010413          	addi	s0,sp,16
    8000185c:	00020793          	mv	a5,tp
    80001860:	00813403          	ld	s0,8(sp)
    80001864:	0007879b          	sext.w	a5,a5
    80001868:	00779793          	slli	a5,a5,0x7
    8000186c:	00004517          	auipc	a0,0x4
    80001870:	cf450513          	addi	a0,a0,-780 # 80005560 <cpus>
    80001874:	00f50533          	add	a0,a0,a5
    80001878:	01010113          	addi	sp,sp,16
    8000187c:	00008067          	ret

0000000080001880 <userinit>:
    80001880:	ff010113          	addi	sp,sp,-16
    80001884:	00813423          	sd	s0,8(sp)
    80001888:	01010413          	addi	s0,sp,16
    8000188c:	00813403          	ld	s0,8(sp)
    80001890:	01010113          	addi	sp,sp,16
    80001894:	00000317          	auipc	t1,0x0
    80001898:	cc830067          	jr	-824(t1) # 8000155c <main>

000000008000189c <either_copyout>:
    8000189c:	ff010113          	addi	sp,sp,-16
    800018a0:	00813023          	sd	s0,0(sp)
    800018a4:	00113423          	sd	ra,8(sp)
    800018a8:	01010413          	addi	s0,sp,16
    800018ac:	02051663          	bnez	a0,800018d8 <either_copyout+0x3c>
    800018b0:	00058513          	mv	a0,a1
    800018b4:	00060593          	mv	a1,a2
    800018b8:	0006861b          	sext.w	a2,a3
    800018bc:	00002097          	auipc	ra,0x2
    800018c0:	c58080e7          	jalr	-936(ra) # 80003514 <__memmove>
    800018c4:	00813083          	ld	ra,8(sp)
    800018c8:	00013403          	ld	s0,0(sp)
    800018cc:	00000513          	li	a0,0
    800018d0:	01010113          	addi	sp,sp,16
    800018d4:	00008067          	ret
    800018d8:	00003517          	auipc	a0,0x3
    800018dc:	88850513          	addi	a0,a0,-1912 # 80004160 <CONSOLE_STATUS+0x150>
    800018e0:	00001097          	auipc	ra,0x1
    800018e4:	92c080e7          	jalr	-1748(ra) # 8000220c <panic>

00000000800018e8 <either_copyin>:
    800018e8:	ff010113          	addi	sp,sp,-16
    800018ec:	00813023          	sd	s0,0(sp)
    800018f0:	00113423          	sd	ra,8(sp)
    800018f4:	01010413          	addi	s0,sp,16
    800018f8:	02059463          	bnez	a1,80001920 <either_copyin+0x38>
    800018fc:	00060593          	mv	a1,a2
    80001900:	0006861b          	sext.w	a2,a3
    80001904:	00002097          	auipc	ra,0x2
    80001908:	c10080e7          	jalr	-1008(ra) # 80003514 <__memmove>
    8000190c:	00813083          	ld	ra,8(sp)
    80001910:	00013403          	ld	s0,0(sp)
    80001914:	00000513          	li	a0,0
    80001918:	01010113          	addi	sp,sp,16
    8000191c:	00008067          	ret
    80001920:	00003517          	auipc	a0,0x3
    80001924:	86850513          	addi	a0,a0,-1944 # 80004188 <CONSOLE_STATUS+0x178>
    80001928:	00001097          	auipc	ra,0x1
    8000192c:	8e4080e7          	jalr	-1820(ra) # 8000220c <panic>

0000000080001930 <trapinit>:
    80001930:	ff010113          	addi	sp,sp,-16
    80001934:	00813423          	sd	s0,8(sp)
    80001938:	01010413          	addi	s0,sp,16
    8000193c:	00813403          	ld	s0,8(sp)
    80001940:	00003597          	auipc	a1,0x3
    80001944:	87058593          	addi	a1,a1,-1936 # 800041b0 <CONSOLE_STATUS+0x1a0>
    80001948:	00004517          	auipc	a0,0x4
    8000194c:	c9850513          	addi	a0,a0,-872 # 800055e0 <tickslock>
    80001950:	01010113          	addi	sp,sp,16
    80001954:	00001317          	auipc	t1,0x1
    80001958:	5c430067          	jr	1476(t1) # 80002f18 <initlock>

000000008000195c <trapinithart>:
    8000195c:	ff010113          	addi	sp,sp,-16
    80001960:	00813423          	sd	s0,8(sp)
    80001964:	01010413          	addi	s0,sp,16
    80001968:	00000797          	auipc	a5,0x0
    8000196c:	2f878793          	addi	a5,a5,760 # 80001c60 <kernelvec>
    80001970:	10579073          	csrw	stvec,a5
    80001974:	00813403          	ld	s0,8(sp)
    80001978:	01010113          	addi	sp,sp,16
    8000197c:	00008067          	ret

0000000080001980 <usertrap>:
    80001980:	ff010113          	addi	sp,sp,-16
    80001984:	00813423          	sd	s0,8(sp)
    80001988:	01010413          	addi	s0,sp,16
    8000198c:	00813403          	ld	s0,8(sp)
    80001990:	01010113          	addi	sp,sp,16
    80001994:	00008067          	ret

0000000080001998 <usertrapret>:
    80001998:	ff010113          	addi	sp,sp,-16
    8000199c:	00813423          	sd	s0,8(sp)
    800019a0:	01010413          	addi	s0,sp,16
    800019a4:	00813403          	ld	s0,8(sp)
    800019a8:	01010113          	addi	sp,sp,16
    800019ac:	00008067          	ret

00000000800019b0 <kerneltrap>:
    800019b0:	fe010113          	addi	sp,sp,-32
    800019b4:	00813823          	sd	s0,16(sp)
    800019b8:	00113c23          	sd	ra,24(sp)
    800019bc:	00913423          	sd	s1,8(sp)
    800019c0:	02010413          	addi	s0,sp,32
    800019c4:	142025f3          	csrr	a1,scause
    800019c8:	100027f3          	csrr	a5,sstatus
    800019cc:	0027f793          	andi	a5,a5,2
    800019d0:	10079c63          	bnez	a5,80001ae8 <kerneltrap+0x138>
    800019d4:	142027f3          	csrr	a5,scause
    800019d8:	0207ce63          	bltz	a5,80001a14 <kerneltrap+0x64>
    800019dc:	00003517          	auipc	a0,0x3
    800019e0:	81c50513          	addi	a0,a0,-2020 # 800041f8 <CONSOLE_STATUS+0x1e8>
    800019e4:	00001097          	auipc	ra,0x1
    800019e8:	884080e7          	jalr	-1916(ra) # 80002268 <__printf>
    800019ec:	141025f3          	csrr	a1,sepc
    800019f0:	14302673          	csrr	a2,stval
    800019f4:	00003517          	auipc	a0,0x3
    800019f8:	81450513          	addi	a0,a0,-2028 # 80004208 <CONSOLE_STATUS+0x1f8>
    800019fc:	00001097          	auipc	ra,0x1
    80001a00:	86c080e7          	jalr	-1940(ra) # 80002268 <__printf>
    80001a04:	00003517          	auipc	a0,0x3
    80001a08:	81c50513          	addi	a0,a0,-2020 # 80004220 <CONSOLE_STATUS+0x210>
    80001a0c:	00001097          	auipc	ra,0x1
    80001a10:	800080e7          	jalr	-2048(ra) # 8000220c <panic>
    80001a14:	0ff7f713          	andi	a4,a5,255
    80001a18:	00900693          	li	a3,9
    80001a1c:	04d70063          	beq	a4,a3,80001a5c <kerneltrap+0xac>
    80001a20:	fff00713          	li	a4,-1
    80001a24:	03f71713          	slli	a4,a4,0x3f
    80001a28:	00170713          	addi	a4,a4,1
    80001a2c:	fae798e3          	bne	a5,a4,800019dc <kerneltrap+0x2c>
    80001a30:	00000097          	auipc	ra,0x0
    80001a34:	e00080e7          	jalr	-512(ra) # 80001830 <cpuid>
    80001a38:	06050663          	beqz	a0,80001aa4 <kerneltrap+0xf4>
    80001a3c:	144027f3          	csrr	a5,sip
    80001a40:	ffd7f793          	andi	a5,a5,-3
    80001a44:	14479073          	csrw	sip,a5
    80001a48:	01813083          	ld	ra,24(sp)
    80001a4c:	01013403          	ld	s0,16(sp)
    80001a50:	00813483          	ld	s1,8(sp)
    80001a54:	02010113          	addi	sp,sp,32
    80001a58:	00008067          	ret
    80001a5c:	00000097          	auipc	ra,0x0
    80001a60:	3c8080e7          	jalr	968(ra) # 80001e24 <plic_claim>
    80001a64:	00a00793          	li	a5,10
    80001a68:	00050493          	mv	s1,a0
    80001a6c:	06f50863          	beq	a0,a5,80001adc <kerneltrap+0x12c>
    80001a70:	fc050ce3          	beqz	a0,80001a48 <kerneltrap+0x98>
    80001a74:	00050593          	mv	a1,a0
    80001a78:	00002517          	auipc	a0,0x2
    80001a7c:	76050513          	addi	a0,a0,1888 # 800041d8 <CONSOLE_STATUS+0x1c8>
    80001a80:	00000097          	auipc	ra,0x0
    80001a84:	7e8080e7          	jalr	2024(ra) # 80002268 <__printf>
    80001a88:	01013403          	ld	s0,16(sp)
    80001a8c:	01813083          	ld	ra,24(sp)
    80001a90:	00048513          	mv	a0,s1
    80001a94:	00813483          	ld	s1,8(sp)
    80001a98:	02010113          	addi	sp,sp,32
    80001a9c:	00000317          	auipc	t1,0x0
    80001aa0:	3c030067          	jr	960(t1) # 80001e5c <plic_complete>
    80001aa4:	00004517          	auipc	a0,0x4
    80001aa8:	b3c50513          	addi	a0,a0,-1220 # 800055e0 <tickslock>
    80001aac:	00001097          	auipc	ra,0x1
    80001ab0:	490080e7          	jalr	1168(ra) # 80002f3c <acquire>
    80001ab4:	00003717          	auipc	a4,0x3
    80001ab8:	a5870713          	addi	a4,a4,-1448 # 8000450c <ticks>
    80001abc:	00072783          	lw	a5,0(a4)
    80001ac0:	00004517          	auipc	a0,0x4
    80001ac4:	b2050513          	addi	a0,a0,-1248 # 800055e0 <tickslock>
    80001ac8:	0017879b          	addiw	a5,a5,1
    80001acc:	00f72023          	sw	a5,0(a4)
    80001ad0:	00001097          	auipc	ra,0x1
    80001ad4:	538080e7          	jalr	1336(ra) # 80003008 <release>
    80001ad8:	f65ff06f          	j	80001a3c <kerneltrap+0x8c>
    80001adc:	00001097          	auipc	ra,0x1
    80001ae0:	094080e7          	jalr	148(ra) # 80002b70 <uartintr>
    80001ae4:	fa5ff06f          	j	80001a88 <kerneltrap+0xd8>
    80001ae8:	00002517          	auipc	a0,0x2
    80001aec:	6d050513          	addi	a0,a0,1744 # 800041b8 <CONSOLE_STATUS+0x1a8>
    80001af0:	00000097          	auipc	ra,0x0
    80001af4:	71c080e7          	jalr	1820(ra) # 8000220c <panic>

0000000080001af8 <clockintr>:
    80001af8:	fe010113          	addi	sp,sp,-32
    80001afc:	00813823          	sd	s0,16(sp)
    80001b00:	00913423          	sd	s1,8(sp)
    80001b04:	00113c23          	sd	ra,24(sp)
    80001b08:	02010413          	addi	s0,sp,32
    80001b0c:	00004497          	auipc	s1,0x4
    80001b10:	ad448493          	addi	s1,s1,-1324 # 800055e0 <tickslock>
    80001b14:	00048513          	mv	a0,s1
    80001b18:	00001097          	auipc	ra,0x1
    80001b1c:	424080e7          	jalr	1060(ra) # 80002f3c <acquire>
    80001b20:	00003717          	auipc	a4,0x3
    80001b24:	9ec70713          	addi	a4,a4,-1556 # 8000450c <ticks>
    80001b28:	00072783          	lw	a5,0(a4)
    80001b2c:	01013403          	ld	s0,16(sp)
    80001b30:	01813083          	ld	ra,24(sp)
    80001b34:	00048513          	mv	a0,s1
    80001b38:	0017879b          	addiw	a5,a5,1
    80001b3c:	00813483          	ld	s1,8(sp)
    80001b40:	00f72023          	sw	a5,0(a4)
    80001b44:	02010113          	addi	sp,sp,32
    80001b48:	00001317          	auipc	t1,0x1
    80001b4c:	4c030067          	jr	1216(t1) # 80003008 <release>

0000000080001b50 <devintr>:
    80001b50:	142027f3          	csrr	a5,scause
    80001b54:	00000513          	li	a0,0
    80001b58:	0007c463          	bltz	a5,80001b60 <devintr+0x10>
    80001b5c:	00008067          	ret
    80001b60:	fe010113          	addi	sp,sp,-32
    80001b64:	00813823          	sd	s0,16(sp)
    80001b68:	00113c23          	sd	ra,24(sp)
    80001b6c:	00913423          	sd	s1,8(sp)
    80001b70:	02010413          	addi	s0,sp,32
    80001b74:	0ff7f713          	andi	a4,a5,255
    80001b78:	00900693          	li	a3,9
    80001b7c:	04d70c63          	beq	a4,a3,80001bd4 <devintr+0x84>
    80001b80:	fff00713          	li	a4,-1
    80001b84:	03f71713          	slli	a4,a4,0x3f
    80001b88:	00170713          	addi	a4,a4,1
    80001b8c:	00e78c63          	beq	a5,a4,80001ba4 <devintr+0x54>
    80001b90:	01813083          	ld	ra,24(sp)
    80001b94:	01013403          	ld	s0,16(sp)
    80001b98:	00813483          	ld	s1,8(sp)
    80001b9c:	02010113          	addi	sp,sp,32
    80001ba0:	00008067          	ret
    80001ba4:	00000097          	auipc	ra,0x0
    80001ba8:	c8c080e7          	jalr	-884(ra) # 80001830 <cpuid>
    80001bac:	06050663          	beqz	a0,80001c18 <devintr+0xc8>
    80001bb0:	144027f3          	csrr	a5,sip
    80001bb4:	ffd7f793          	andi	a5,a5,-3
    80001bb8:	14479073          	csrw	sip,a5
    80001bbc:	01813083          	ld	ra,24(sp)
    80001bc0:	01013403          	ld	s0,16(sp)
    80001bc4:	00813483          	ld	s1,8(sp)
    80001bc8:	00200513          	li	a0,2
    80001bcc:	02010113          	addi	sp,sp,32
    80001bd0:	00008067          	ret
    80001bd4:	00000097          	auipc	ra,0x0
    80001bd8:	250080e7          	jalr	592(ra) # 80001e24 <plic_claim>
    80001bdc:	00a00793          	li	a5,10
    80001be0:	00050493          	mv	s1,a0
    80001be4:	06f50663          	beq	a0,a5,80001c50 <devintr+0x100>
    80001be8:	00100513          	li	a0,1
    80001bec:	fa0482e3          	beqz	s1,80001b90 <devintr+0x40>
    80001bf0:	00048593          	mv	a1,s1
    80001bf4:	00002517          	auipc	a0,0x2
    80001bf8:	5e450513          	addi	a0,a0,1508 # 800041d8 <CONSOLE_STATUS+0x1c8>
    80001bfc:	00000097          	auipc	ra,0x0
    80001c00:	66c080e7          	jalr	1644(ra) # 80002268 <__printf>
    80001c04:	00048513          	mv	a0,s1
    80001c08:	00000097          	auipc	ra,0x0
    80001c0c:	254080e7          	jalr	596(ra) # 80001e5c <plic_complete>
    80001c10:	00100513          	li	a0,1
    80001c14:	f7dff06f          	j	80001b90 <devintr+0x40>
    80001c18:	00004517          	auipc	a0,0x4
    80001c1c:	9c850513          	addi	a0,a0,-1592 # 800055e0 <tickslock>
    80001c20:	00001097          	auipc	ra,0x1
    80001c24:	31c080e7          	jalr	796(ra) # 80002f3c <acquire>
    80001c28:	00003717          	auipc	a4,0x3
    80001c2c:	8e470713          	addi	a4,a4,-1820 # 8000450c <ticks>
    80001c30:	00072783          	lw	a5,0(a4)
    80001c34:	00004517          	auipc	a0,0x4
    80001c38:	9ac50513          	addi	a0,a0,-1620 # 800055e0 <tickslock>
    80001c3c:	0017879b          	addiw	a5,a5,1
    80001c40:	00f72023          	sw	a5,0(a4)
    80001c44:	00001097          	auipc	ra,0x1
    80001c48:	3c4080e7          	jalr	964(ra) # 80003008 <release>
    80001c4c:	f65ff06f          	j	80001bb0 <devintr+0x60>
    80001c50:	00001097          	auipc	ra,0x1
    80001c54:	f20080e7          	jalr	-224(ra) # 80002b70 <uartintr>
    80001c58:	fadff06f          	j	80001c04 <devintr+0xb4>
    80001c5c:	0000                	unimp
	...

0000000080001c60 <kernelvec>:
    80001c60:	f0010113          	addi	sp,sp,-256
    80001c64:	00113023          	sd	ra,0(sp)
    80001c68:	00213423          	sd	sp,8(sp)
    80001c6c:	00313823          	sd	gp,16(sp)
    80001c70:	00413c23          	sd	tp,24(sp)
    80001c74:	02513023          	sd	t0,32(sp)
    80001c78:	02613423          	sd	t1,40(sp)
    80001c7c:	02713823          	sd	t2,48(sp)
    80001c80:	02813c23          	sd	s0,56(sp)
    80001c84:	04913023          	sd	s1,64(sp)
    80001c88:	04a13423          	sd	a0,72(sp)
    80001c8c:	04b13823          	sd	a1,80(sp)
    80001c90:	04c13c23          	sd	a2,88(sp)
    80001c94:	06d13023          	sd	a3,96(sp)
    80001c98:	06e13423          	sd	a4,104(sp)
    80001c9c:	06f13823          	sd	a5,112(sp)
    80001ca0:	07013c23          	sd	a6,120(sp)
    80001ca4:	09113023          	sd	a7,128(sp)
    80001ca8:	09213423          	sd	s2,136(sp)
    80001cac:	09313823          	sd	s3,144(sp)
    80001cb0:	09413c23          	sd	s4,152(sp)
    80001cb4:	0b513023          	sd	s5,160(sp)
    80001cb8:	0b613423          	sd	s6,168(sp)
    80001cbc:	0b713823          	sd	s7,176(sp)
    80001cc0:	0b813c23          	sd	s8,184(sp)
    80001cc4:	0d913023          	sd	s9,192(sp)
    80001cc8:	0da13423          	sd	s10,200(sp)
    80001ccc:	0db13823          	sd	s11,208(sp)
    80001cd0:	0dc13c23          	sd	t3,216(sp)
    80001cd4:	0fd13023          	sd	t4,224(sp)
    80001cd8:	0fe13423          	sd	t5,232(sp)
    80001cdc:	0ff13823          	sd	t6,240(sp)
    80001ce0:	cd1ff0ef          	jal	ra,800019b0 <kerneltrap>
    80001ce4:	00013083          	ld	ra,0(sp)
    80001ce8:	00813103          	ld	sp,8(sp)
    80001cec:	01013183          	ld	gp,16(sp)
    80001cf0:	02013283          	ld	t0,32(sp)
    80001cf4:	02813303          	ld	t1,40(sp)
    80001cf8:	03013383          	ld	t2,48(sp)
    80001cfc:	03813403          	ld	s0,56(sp)
    80001d00:	04013483          	ld	s1,64(sp)
    80001d04:	04813503          	ld	a0,72(sp)
    80001d08:	05013583          	ld	a1,80(sp)
    80001d0c:	05813603          	ld	a2,88(sp)
    80001d10:	06013683          	ld	a3,96(sp)
    80001d14:	06813703          	ld	a4,104(sp)
    80001d18:	07013783          	ld	a5,112(sp)
    80001d1c:	07813803          	ld	a6,120(sp)
    80001d20:	08013883          	ld	a7,128(sp)
    80001d24:	08813903          	ld	s2,136(sp)
    80001d28:	09013983          	ld	s3,144(sp)
    80001d2c:	09813a03          	ld	s4,152(sp)
    80001d30:	0a013a83          	ld	s5,160(sp)
    80001d34:	0a813b03          	ld	s6,168(sp)
    80001d38:	0b013b83          	ld	s7,176(sp)
    80001d3c:	0b813c03          	ld	s8,184(sp)
    80001d40:	0c013c83          	ld	s9,192(sp)
    80001d44:	0c813d03          	ld	s10,200(sp)
    80001d48:	0d013d83          	ld	s11,208(sp)
    80001d4c:	0d813e03          	ld	t3,216(sp)
    80001d50:	0e013e83          	ld	t4,224(sp)
    80001d54:	0e813f03          	ld	t5,232(sp)
    80001d58:	0f013f83          	ld	t6,240(sp)
    80001d5c:	10010113          	addi	sp,sp,256
    80001d60:	10200073          	sret
    80001d64:	00000013          	nop
    80001d68:	00000013          	nop
    80001d6c:	00000013          	nop

0000000080001d70 <timervec>:
    80001d70:	34051573          	csrrw	a0,mscratch,a0
    80001d74:	00b53023          	sd	a1,0(a0)
    80001d78:	00c53423          	sd	a2,8(a0)
    80001d7c:	00d53823          	sd	a3,16(a0)
    80001d80:	01853583          	ld	a1,24(a0)
    80001d84:	02053603          	ld	a2,32(a0)
    80001d88:	0005b683          	ld	a3,0(a1)
    80001d8c:	00c686b3          	add	a3,a3,a2
    80001d90:	00d5b023          	sd	a3,0(a1)
    80001d94:	00200593          	li	a1,2
    80001d98:	14459073          	csrw	sip,a1
    80001d9c:	01053683          	ld	a3,16(a0)
    80001da0:	00853603          	ld	a2,8(a0)
    80001da4:	00053583          	ld	a1,0(a0)
    80001da8:	34051573          	csrrw	a0,mscratch,a0
    80001dac:	30200073          	mret

0000000080001db0 <plicinit>:
    80001db0:	ff010113          	addi	sp,sp,-16
    80001db4:	00813423          	sd	s0,8(sp)
    80001db8:	01010413          	addi	s0,sp,16
    80001dbc:	00813403          	ld	s0,8(sp)
    80001dc0:	0c0007b7          	lui	a5,0xc000
    80001dc4:	00100713          	li	a4,1
    80001dc8:	02e7a423          	sw	a4,40(a5) # c000028 <_entry-0x73ffffd8>
    80001dcc:	00e7a223          	sw	a4,4(a5)
    80001dd0:	01010113          	addi	sp,sp,16
    80001dd4:	00008067          	ret

0000000080001dd8 <plicinithart>:
    80001dd8:	ff010113          	addi	sp,sp,-16
    80001ddc:	00813023          	sd	s0,0(sp)
    80001de0:	00113423          	sd	ra,8(sp)
    80001de4:	01010413          	addi	s0,sp,16
    80001de8:	00000097          	auipc	ra,0x0
    80001dec:	a48080e7          	jalr	-1464(ra) # 80001830 <cpuid>
    80001df0:	0085171b          	slliw	a4,a0,0x8
    80001df4:	0c0027b7          	lui	a5,0xc002
    80001df8:	00e787b3          	add	a5,a5,a4
    80001dfc:	40200713          	li	a4,1026
    80001e00:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>
    80001e04:	00813083          	ld	ra,8(sp)
    80001e08:	00013403          	ld	s0,0(sp)
    80001e0c:	00d5151b          	slliw	a0,a0,0xd
    80001e10:	0c2017b7          	lui	a5,0xc201
    80001e14:	00a78533          	add	a0,a5,a0
    80001e18:	00052023          	sw	zero,0(a0)
    80001e1c:	01010113          	addi	sp,sp,16
    80001e20:	00008067          	ret

0000000080001e24 <plic_claim>:
    80001e24:	ff010113          	addi	sp,sp,-16
    80001e28:	00813023          	sd	s0,0(sp)
    80001e2c:	00113423          	sd	ra,8(sp)
    80001e30:	01010413          	addi	s0,sp,16
    80001e34:	00000097          	auipc	ra,0x0
    80001e38:	9fc080e7          	jalr	-1540(ra) # 80001830 <cpuid>
    80001e3c:	00813083          	ld	ra,8(sp)
    80001e40:	00013403          	ld	s0,0(sp)
    80001e44:	00d5151b          	slliw	a0,a0,0xd
    80001e48:	0c2017b7          	lui	a5,0xc201
    80001e4c:	00a78533          	add	a0,a5,a0
    80001e50:	00452503          	lw	a0,4(a0)
    80001e54:	01010113          	addi	sp,sp,16
    80001e58:	00008067          	ret

0000000080001e5c <plic_complete>:
    80001e5c:	fe010113          	addi	sp,sp,-32
    80001e60:	00813823          	sd	s0,16(sp)
    80001e64:	00913423          	sd	s1,8(sp)
    80001e68:	00113c23          	sd	ra,24(sp)
    80001e6c:	02010413          	addi	s0,sp,32
    80001e70:	00050493          	mv	s1,a0
    80001e74:	00000097          	auipc	ra,0x0
    80001e78:	9bc080e7          	jalr	-1604(ra) # 80001830 <cpuid>
    80001e7c:	01813083          	ld	ra,24(sp)
    80001e80:	01013403          	ld	s0,16(sp)
    80001e84:	00d5179b          	slliw	a5,a0,0xd
    80001e88:	0c201737          	lui	a4,0xc201
    80001e8c:	00f707b3          	add	a5,a4,a5
    80001e90:	0097a223          	sw	s1,4(a5) # c201004 <_entry-0x73dfeffc>
    80001e94:	00813483          	ld	s1,8(sp)
    80001e98:	02010113          	addi	sp,sp,32
    80001e9c:	00008067          	ret

0000000080001ea0 <consolewrite>:
    80001ea0:	fb010113          	addi	sp,sp,-80
    80001ea4:	04813023          	sd	s0,64(sp)
    80001ea8:	04113423          	sd	ra,72(sp)
    80001eac:	02913c23          	sd	s1,56(sp)
    80001eb0:	03213823          	sd	s2,48(sp)
    80001eb4:	03313423          	sd	s3,40(sp)
    80001eb8:	03413023          	sd	s4,32(sp)
    80001ebc:	01513c23          	sd	s5,24(sp)
    80001ec0:	05010413          	addi	s0,sp,80
    80001ec4:	06c05c63          	blez	a2,80001f3c <consolewrite+0x9c>
    80001ec8:	00060993          	mv	s3,a2
    80001ecc:	00050a13          	mv	s4,a0
    80001ed0:	00058493          	mv	s1,a1
    80001ed4:	00000913          	li	s2,0
    80001ed8:	fff00a93          	li	s5,-1
    80001edc:	01c0006f          	j	80001ef8 <consolewrite+0x58>
    80001ee0:	fbf44503          	lbu	a0,-65(s0)
    80001ee4:	0019091b          	addiw	s2,s2,1
    80001ee8:	00148493          	addi	s1,s1,1
    80001eec:	00001097          	auipc	ra,0x1
    80001ef0:	a9c080e7          	jalr	-1380(ra) # 80002988 <uartputc>
    80001ef4:	03298063          	beq	s3,s2,80001f14 <consolewrite+0x74>
    80001ef8:	00048613          	mv	a2,s1
    80001efc:	00100693          	li	a3,1
    80001f00:	000a0593          	mv	a1,s4
    80001f04:	fbf40513          	addi	a0,s0,-65
    80001f08:	00000097          	auipc	ra,0x0
    80001f0c:	9e0080e7          	jalr	-1568(ra) # 800018e8 <either_copyin>
    80001f10:	fd5518e3          	bne	a0,s5,80001ee0 <consolewrite+0x40>
    80001f14:	04813083          	ld	ra,72(sp)
    80001f18:	04013403          	ld	s0,64(sp)
    80001f1c:	03813483          	ld	s1,56(sp)
    80001f20:	02813983          	ld	s3,40(sp)
    80001f24:	02013a03          	ld	s4,32(sp)
    80001f28:	01813a83          	ld	s5,24(sp)
    80001f2c:	00090513          	mv	a0,s2
    80001f30:	03013903          	ld	s2,48(sp)
    80001f34:	05010113          	addi	sp,sp,80
    80001f38:	00008067          	ret
    80001f3c:	00000913          	li	s2,0
    80001f40:	fd5ff06f          	j	80001f14 <consolewrite+0x74>

0000000080001f44 <consoleread>:
    80001f44:	f9010113          	addi	sp,sp,-112
    80001f48:	06813023          	sd	s0,96(sp)
    80001f4c:	04913c23          	sd	s1,88(sp)
    80001f50:	05213823          	sd	s2,80(sp)
    80001f54:	05313423          	sd	s3,72(sp)
    80001f58:	05413023          	sd	s4,64(sp)
    80001f5c:	03513c23          	sd	s5,56(sp)
    80001f60:	03613823          	sd	s6,48(sp)
    80001f64:	03713423          	sd	s7,40(sp)
    80001f68:	03813023          	sd	s8,32(sp)
    80001f6c:	06113423          	sd	ra,104(sp)
    80001f70:	01913c23          	sd	s9,24(sp)
    80001f74:	07010413          	addi	s0,sp,112
    80001f78:	00060b93          	mv	s7,a2
    80001f7c:	00050913          	mv	s2,a0
    80001f80:	00058c13          	mv	s8,a1
    80001f84:	00060b1b          	sext.w	s6,a2
    80001f88:	00003497          	auipc	s1,0x3
    80001f8c:	67048493          	addi	s1,s1,1648 # 800055f8 <cons>
    80001f90:	00400993          	li	s3,4
    80001f94:	fff00a13          	li	s4,-1
    80001f98:	00a00a93          	li	s5,10
    80001f9c:	05705e63          	blez	s7,80001ff8 <consoleread+0xb4>
    80001fa0:	09c4a703          	lw	a4,156(s1)
    80001fa4:	0984a783          	lw	a5,152(s1)
    80001fa8:	0007071b          	sext.w	a4,a4
    80001fac:	08e78463          	beq	a5,a4,80002034 <consoleread+0xf0>
    80001fb0:	07f7f713          	andi	a4,a5,127
    80001fb4:	00e48733          	add	a4,s1,a4
    80001fb8:	01874703          	lbu	a4,24(a4) # c201018 <_entry-0x73dfefe8>
    80001fbc:	0017869b          	addiw	a3,a5,1
    80001fc0:	08d4ac23          	sw	a3,152(s1)
    80001fc4:	00070c9b          	sext.w	s9,a4
    80001fc8:	0b370663          	beq	a4,s3,80002074 <consoleread+0x130>
    80001fcc:	00100693          	li	a3,1
    80001fd0:	f9f40613          	addi	a2,s0,-97
    80001fd4:	000c0593          	mv	a1,s8
    80001fd8:	00090513          	mv	a0,s2
    80001fdc:	f8e40fa3          	sb	a4,-97(s0)
    80001fe0:	00000097          	auipc	ra,0x0
    80001fe4:	8bc080e7          	jalr	-1860(ra) # 8000189c <either_copyout>
    80001fe8:	01450863          	beq	a0,s4,80001ff8 <consoleread+0xb4>
    80001fec:	001c0c13          	addi	s8,s8,1
    80001ff0:	fffb8b9b          	addiw	s7,s7,-1
    80001ff4:	fb5c94e3          	bne	s9,s5,80001f9c <consoleread+0x58>
    80001ff8:	000b851b          	sext.w	a0,s7
    80001ffc:	06813083          	ld	ra,104(sp)
    80002000:	06013403          	ld	s0,96(sp)
    80002004:	05813483          	ld	s1,88(sp)
    80002008:	05013903          	ld	s2,80(sp)
    8000200c:	04813983          	ld	s3,72(sp)
    80002010:	04013a03          	ld	s4,64(sp)
    80002014:	03813a83          	ld	s5,56(sp)
    80002018:	02813b83          	ld	s7,40(sp)
    8000201c:	02013c03          	ld	s8,32(sp)
    80002020:	01813c83          	ld	s9,24(sp)
    80002024:	40ab053b          	subw	a0,s6,a0
    80002028:	03013b03          	ld	s6,48(sp)
    8000202c:	07010113          	addi	sp,sp,112
    80002030:	00008067          	ret
    80002034:	00001097          	auipc	ra,0x1
    80002038:	1d8080e7          	jalr	472(ra) # 8000320c <push_on>
    8000203c:	0984a703          	lw	a4,152(s1)
    80002040:	09c4a783          	lw	a5,156(s1)
    80002044:	0007879b          	sext.w	a5,a5
    80002048:	fef70ce3          	beq	a4,a5,80002040 <consoleread+0xfc>
    8000204c:	00001097          	auipc	ra,0x1
    80002050:	234080e7          	jalr	564(ra) # 80003280 <pop_on>
    80002054:	0984a783          	lw	a5,152(s1)
    80002058:	07f7f713          	andi	a4,a5,127
    8000205c:	00e48733          	add	a4,s1,a4
    80002060:	01874703          	lbu	a4,24(a4)
    80002064:	0017869b          	addiw	a3,a5,1
    80002068:	08d4ac23          	sw	a3,152(s1)
    8000206c:	00070c9b          	sext.w	s9,a4
    80002070:	f5371ee3          	bne	a4,s3,80001fcc <consoleread+0x88>
    80002074:	000b851b          	sext.w	a0,s7
    80002078:	f96bf2e3          	bgeu	s7,s6,80001ffc <consoleread+0xb8>
    8000207c:	08f4ac23          	sw	a5,152(s1)
    80002080:	f7dff06f          	j	80001ffc <consoleread+0xb8>

0000000080002084 <consputc>:
    80002084:	10000793          	li	a5,256
    80002088:	00f50663          	beq	a0,a5,80002094 <consputc+0x10>
    8000208c:	00001317          	auipc	t1,0x1
    80002090:	9f430067          	jr	-1548(t1) # 80002a80 <uartputc_sync>
    80002094:	ff010113          	addi	sp,sp,-16
    80002098:	00113423          	sd	ra,8(sp)
    8000209c:	00813023          	sd	s0,0(sp)
    800020a0:	01010413          	addi	s0,sp,16
    800020a4:	00800513          	li	a0,8
    800020a8:	00001097          	auipc	ra,0x1
    800020ac:	9d8080e7          	jalr	-1576(ra) # 80002a80 <uartputc_sync>
    800020b0:	02000513          	li	a0,32
    800020b4:	00001097          	auipc	ra,0x1
    800020b8:	9cc080e7          	jalr	-1588(ra) # 80002a80 <uartputc_sync>
    800020bc:	00013403          	ld	s0,0(sp)
    800020c0:	00813083          	ld	ra,8(sp)
    800020c4:	00800513          	li	a0,8
    800020c8:	01010113          	addi	sp,sp,16
    800020cc:	00001317          	auipc	t1,0x1
    800020d0:	9b430067          	jr	-1612(t1) # 80002a80 <uartputc_sync>

00000000800020d4 <consoleintr>:
    800020d4:	fe010113          	addi	sp,sp,-32
    800020d8:	00813823          	sd	s0,16(sp)
    800020dc:	00913423          	sd	s1,8(sp)
    800020e0:	01213023          	sd	s2,0(sp)
    800020e4:	00113c23          	sd	ra,24(sp)
    800020e8:	02010413          	addi	s0,sp,32
    800020ec:	00003917          	auipc	s2,0x3
    800020f0:	50c90913          	addi	s2,s2,1292 # 800055f8 <cons>
    800020f4:	00050493          	mv	s1,a0
    800020f8:	00090513          	mv	a0,s2
    800020fc:	00001097          	auipc	ra,0x1
    80002100:	e40080e7          	jalr	-448(ra) # 80002f3c <acquire>
    80002104:	02048c63          	beqz	s1,8000213c <consoleintr+0x68>
    80002108:	0a092783          	lw	a5,160(s2)
    8000210c:	09892703          	lw	a4,152(s2)
    80002110:	07f00693          	li	a3,127
    80002114:	40e7873b          	subw	a4,a5,a4
    80002118:	02e6e263          	bltu	a3,a4,8000213c <consoleintr+0x68>
    8000211c:	00d00713          	li	a4,13
    80002120:	04e48063          	beq	s1,a4,80002160 <consoleintr+0x8c>
    80002124:	07f7f713          	andi	a4,a5,127
    80002128:	00e90733          	add	a4,s2,a4
    8000212c:	0017879b          	addiw	a5,a5,1
    80002130:	0af92023          	sw	a5,160(s2)
    80002134:	00970c23          	sb	s1,24(a4)
    80002138:	08f92e23          	sw	a5,156(s2)
    8000213c:	01013403          	ld	s0,16(sp)
    80002140:	01813083          	ld	ra,24(sp)
    80002144:	00813483          	ld	s1,8(sp)
    80002148:	00013903          	ld	s2,0(sp)
    8000214c:	00003517          	auipc	a0,0x3
    80002150:	4ac50513          	addi	a0,a0,1196 # 800055f8 <cons>
    80002154:	02010113          	addi	sp,sp,32
    80002158:	00001317          	auipc	t1,0x1
    8000215c:	eb030067          	jr	-336(t1) # 80003008 <release>
    80002160:	00a00493          	li	s1,10
    80002164:	fc1ff06f          	j	80002124 <consoleintr+0x50>

0000000080002168 <consoleinit>:
    80002168:	fe010113          	addi	sp,sp,-32
    8000216c:	00113c23          	sd	ra,24(sp)
    80002170:	00813823          	sd	s0,16(sp)
    80002174:	00913423          	sd	s1,8(sp)
    80002178:	02010413          	addi	s0,sp,32
    8000217c:	00003497          	auipc	s1,0x3
    80002180:	47c48493          	addi	s1,s1,1148 # 800055f8 <cons>
    80002184:	00048513          	mv	a0,s1
    80002188:	00002597          	auipc	a1,0x2
    8000218c:	0a858593          	addi	a1,a1,168 # 80004230 <CONSOLE_STATUS+0x220>
    80002190:	00001097          	auipc	ra,0x1
    80002194:	d88080e7          	jalr	-632(ra) # 80002f18 <initlock>
    80002198:	00000097          	auipc	ra,0x0
    8000219c:	7ac080e7          	jalr	1964(ra) # 80002944 <uartinit>
    800021a0:	01813083          	ld	ra,24(sp)
    800021a4:	01013403          	ld	s0,16(sp)
    800021a8:	00000797          	auipc	a5,0x0
    800021ac:	d9c78793          	addi	a5,a5,-612 # 80001f44 <consoleread>
    800021b0:	0af4bc23          	sd	a5,184(s1)
    800021b4:	00000797          	auipc	a5,0x0
    800021b8:	cec78793          	addi	a5,a5,-788 # 80001ea0 <consolewrite>
    800021bc:	0cf4b023          	sd	a5,192(s1)
    800021c0:	00813483          	ld	s1,8(sp)
    800021c4:	02010113          	addi	sp,sp,32
    800021c8:	00008067          	ret

00000000800021cc <console_read>:
    800021cc:	ff010113          	addi	sp,sp,-16
    800021d0:	00813423          	sd	s0,8(sp)
    800021d4:	01010413          	addi	s0,sp,16
    800021d8:	00813403          	ld	s0,8(sp)
    800021dc:	00003317          	auipc	t1,0x3
    800021e0:	4d433303          	ld	t1,1236(t1) # 800056b0 <devsw+0x10>
    800021e4:	01010113          	addi	sp,sp,16
    800021e8:	00030067          	jr	t1

00000000800021ec <console_write>:
    800021ec:	ff010113          	addi	sp,sp,-16
    800021f0:	00813423          	sd	s0,8(sp)
    800021f4:	01010413          	addi	s0,sp,16
    800021f8:	00813403          	ld	s0,8(sp)
    800021fc:	00003317          	auipc	t1,0x3
    80002200:	4bc33303          	ld	t1,1212(t1) # 800056b8 <devsw+0x18>
    80002204:	01010113          	addi	sp,sp,16
    80002208:	00030067          	jr	t1

000000008000220c <panic>:
    8000220c:	fe010113          	addi	sp,sp,-32
    80002210:	00113c23          	sd	ra,24(sp)
    80002214:	00813823          	sd	s0,16(sp)
    80002218:	00913423          	sd	s1,8(sp)
    8000221c:	02010413          	addi	s0,sp,32
    80002220:	00050493          	mv	s1,a0
    80002224:	00002517          	auipc	a0,0x2
    80002228:	01450513          	addi	a0,a0,20 # 80004238 <CONSOLE_STATUS+0x228>
    8000222c:	00003797          	auipc	a5,0x3
    80002230:	5207a623          	sw	zero,1324(a5) # 80005758 <pr+0x18>
    80002234:	00000097          	auipc	ra,0x0
    80002238:	034080e7          	jalr	52(ra) # 80002268 <__printf>
    8000223c:	00048513          	mv	a0,s1
    80002240:	00000097          	auipc	ra,0x0
    80002244:	028080e7          	jalr	40(ra) # 80002268 <__printf>
    80002248:	00002517          	auipc	a0,0x2
    8000224c:	e1850513          	addi	a0,a0,-488 # 80004060 <CONSOLE_STATUS+0x50>
    80002250:	00000097          	auipc	ra,0x0
    80002254:	018080e7          	jalr	24(ra) # 80002268 <__printf>
    80002258:	00100793          	li	a5,1
    8000225c:	00002717          	auipc	a4,0x2
    80002260:	2af72a23          	sw	a5,692(a4) # 80004510 <panicked>
    80002264:	0000006f          	j	80002264 <panic+0x58>

0000000080002268 <__printf>:
    80002268:	f3010113          	addi	sp,sp,-208
    8000226c:	08813023          	sd	s0,128(sp)
    80002270:	07313423          	sd	s3,104(sp)
    80002274:	09010413          	addi	s0,sp,144
    80002278:	05813023          	sd	s8,64(sp)
    8000227c:	08113423          	sd	ra,136(sp)
    80002280:	06913c23          	sd	s1,120(sp)
    80002284:	07213823          	sd	s2,112(sp)
    80002288:	07413023          	sd	s4,96(sp)
    8000228c:	05513c23          	sd	s5,88(sp)
    80002290:	05613823          	sd	s6,80(sp)
    80002294:	05713423          	sd	s7,72(sp)
    80002298:	03913c23          	sd	s9,56(sp)
    8000229c:	03a13823          	sd	s10,48(sp)
    800022a0:	03b13423          	sd	s11,40(sp)
    800022a4:	00003317          	auipc	t1,0x3
    800022a8:	49c30313          	addi	t1,t1,1180 # 80005740 <pr>
    800022ac:	01832c03          	lw	s8,24(t1)
    800022b0:	00b43423          	sd	a1,8(s0)
    800022b4:	00c43823          	sd	a2,16(s0)
    800022b8:	00d43c23          	sd	a3,24(s0)
    800022bc:	02e43023          	sd	a4,32(s0)
    800022c0:	02f43423          	sd	a5,40(s0)
    800022c4:	03043823          	sd	a6,48(s0)
    800022c8:	03143c23          	sd	a7,56(s0)
    800022cc:	00050993          	mv	s3,a0
    800022d0:	4a0c1663          	bnez	s8,8000277c <__printf+0x514>
    800022d4:	60098c63          	beqz	s3,800028ec <__printf+0x684>
    800022d8:	0009c503          	lbu	a0,0(s3)
    800022dc:	00840793          	addi	a5,s0,8
    800022e0:	f6f43c23          	sd	a5,-136(s0)
    800022e4:	00000493          	li	s1,0
    800022e8:	22050063          	beqz	a0,80002508 <__printf+0x2a0>
    800022ec:	00002a37          	lui	s4,0x2
    800022f0:	00018ab7          	lui	s5,0x18
    800022f4:	000f4b37          	lui	s6,0xf4
    800022f8:	00989bb7          	lui	s7,0x989
    800022fc:	70fa0a13          	addi	s4,s4,1807 # 270f <_entry-0x7fffd8f1>
    80002300:	69fa8a93          	addi	s5,s5,1695 # 1869f <_entry-0x7ffe7961>
    80002304:	23fb0b13          	addi	s6,s6,575 # f423f <_entry-0x7ff0bdc1>
    80002308:	67fb8b93          	addi	s7,s7,1663 # 98967f <_entry-0x7f676981>
    8000230c:	00148c9b          	addiw	s9,s1,1
    80002310:	02500793          	li	a5,37
    80002314:	01998933          	add	s2,s3,s9
    80002318:	38f51263          	bne	a0,a5,8000269c <__printf+0x434>
    8000231c:	00094783          	lbu	a5,0(s2)
    80002320:	00078c9b          	sext.w	s9,a5
    80002324:	1e078263          	beqz	a5,80002508 <__printf+0x2a0>
    80002328:	0024849b          	addiw	s1,s1,2
    8000232c:	07000713          	li	a4,112
    80002330:	00998933          	add	s2,s3,s1
    80002334:	38e78a63          	beq	a5,a4,800026c8 <__printf+0x460>
    80002338:	20f76863          	bltu	a4,a5,80002548 <__printf+0x2e0>
    8000233c:	42a78863          	beq	a5,a0,8000276c <__printf+0x504>
    80002340:	06400713          	li	a4,100
    80002344:	40e79663          	bne	a5,a4,80002750 <__printf+0x4e8>
    80002348:	f7843783          	ld	a5,-136(s0)
    8000234c:	0007a603          	lw	a2,0(a5)
    80002350:	00878793          	addi	a5,a5,8
    80002354:	f6f43c23          	sd	a5,-136(s0)
    80002358:	42064a63          	bltz	a2,8000278c <__printf+0x524>
    8000235c:	00a00713          	li	a4,10
    80002360:	02e677bb          	remuw	a5,a2,a4
    80002364:	00002d97          	auipc	s11,0x2
    80002368:	efcd8d93          	addi	s11,s11,-260 # 80004260 <digits>
    8000236c:	00900593          	li	a1,9
    80002370:	0006051b          	sext.w	a0,a2
    80002374:	00000c93          	li	s9,0
    80002378:	02079793          	slli	a5,a5,0x20
    8000237c:	0207d793          	srli	a5,a5,0x20
    80002380:	00fd87b3          	add	a5,s11,a5
    80002384:	0007c783          	lbu	a5,0(a5)
    80002388:	02e656bb          	divuw	a3,a2,a4
    8000238c:	f8f40023          	sb	a5,-128(s0)
    80002390:	14c5d863          	bge	a1,a2,800024e0 <__printf+0x278>
    80002394:	06300593          	li	a1,99
    80002398:	00100c93          	li	s9,1
    8000239c:	02e6f7bb          	remuw	a5,a3,a4
    800023a0:	02079793          	slli	a5,a5,0x20
    800023a4:	0207d793          	srli	a5,a5,0x20
    800023a8:	00fd87b3          	add	a5,s11,a5
    800023ac:	0007c783          	lbu	a5,0(a5)
    800023b0:	02e6d73b          	divuw	a4,a3,a4
    800023b4:	f8f400a3          	sb	a5,-127(s0)
    800023b8:	12a5f463          	bgeu	a1,a0,800024e0 <__printf+0x278>
    800023bc:	00a00693          	li	a3,10
    800023c0:	00900593          	li	a1,9
    800023c4:	02d777bb          	remuw	a5,a4,a3
    800023c8:	02079793          	slli	a5,a5,0x20
    800023cc:	0207d793          	srli	a5,a5,0x20
    800023d0:	00fd87b3          	add	a5,s11,a5
    800023d4:	0007c503          	lbu	a0,0(a5)
    800023d8:	02d757bb          	divuw	a5,a4,a3
    800023dc:	f8a40123          	sb	a0,-126(s0)
    800023e0:	48e5f263          	bgeu	a1,a4,80002864 <__printf+0x5fc>
    800023e4:	06300513          	li	a0,99
    800023e8:	02d7f5bb          	remuw	a1,a5,a3
    800023ec:	02059593          	slli	a1,a1,0x20
    800023f0:	0205d593          	srli	a1,a1,0x20
    800023f4:	00bd85b3          	add	a1,s11,a1
    800023f8:	0005c583          	lbu	a1,0(a1)
    800023fc:	02d7d7bb          	divuw	a5,a5,a3
    80002400:	f8b401a3          	sb	a1,-125(s0)
    80002404:	48e57263          	bgeu	a0,a4,80002888 <__printf+0x620>
    80002408:	3e700513          	li	a0,999
    8000240c:	02d7f5bb          	remuw	a1,a5,a3
    80002410:	02059593          	slli	a1,a1,0x20
    80002414:	0205d593          	srli	a1,a1,0x20
    80002418:	00bd85b3          	add	a1,s11,a1
    8000241c:	0005c583          	lbu	a1,0(a1)
    80002420:	02d7d7bb          	divuw	a5,a5,a3
    80002424:	f8b40223          	sb	a1,-124(s0)
    80002428:	46e57663          	bgeu	a0,a4,80002894 <__printf+0x62c>
    8000242c:	02d7f5bb          	remuw	a1,a5,a3
    80002430:	02059593          	slli	a1,a1,0x20
    80002434:	0205d593          	srli	a1,a1,0x20
    80002438:	00bd85b3          	add	a1,s11,a1
    8000243c:	0005c583          	lbu	a1,0(a1)
    80002440:	02d7d7bb          	divuw	a5,a5,a3
    80002444:	f8b402a3          	sb	a1,-123(s0)
    80002448:	46ea7863          	bgeu	s4,a4,800028b8 <__printf+0x650>
    8000244c:	02d7f5bb          	remuw	a1,a5,a3
    80002450:	02059593          	slli	a1,a1,0x20
    80002454:	0205d593          	srli	a1,a1,0x20
    80002458:	00bd85b3          	add	a1,s11,a1
    8000245c:	0005c583          	lbu	a1,0(a1)
    80002460:	02d7d7bb          	divuw	a5,a5,a3
    80002464:	f8b40323          	sb	a1,-122(s0)
    80002468:	3eeaf863          	bgeu	s5,a4,80002858 <__printf+0x5f0>
    8000246c:	02d7f5bb          	remuw	a1,a5,a3
    80002470:	02059593          	slli	a1,a1,0x20
    80002474:	0205d593          	srli	a1,a1,0x20
    80002478:	00bd85b3          	add	a1,s11,a1
    8000247c:	0005c583          	lbu	a1,0(a1)
    80002480:	02d7d7bb          	divuw	a5,a5,a3
    80002484:	f8b403a3          	sb	a1,-121(s0)
    80002488:	42eb7e63          	bgeu	s6,a4,800028c4 <__printf+0x65c>
    8000248c:	02d7f5bb          	remuw	a1,a5,a3
    80002490:	02059593          	slli	a1,a1,0x20
    80002494:	0205d593          	srli	a1,a1,0x20
    80002498:	00bd85b3          	add	a1,s11,a1
    8000249c:	0005c583          	lbu	a1,0(a1)
    800024a0:	02d7d7bb          	divuw	a5,a5,a3
    800024a4:	f8b40423          	sb	a1,-120(s0)
    800024a8:	42ebfc63          	bgeu	s7,a4,800028e0 <__printf+0x678>
    800024ac:	02079793          	slli	a5,a5,0x20
    800024b0:	0207d793          	srli	a5,a5,0x20
    800024b4:	00fd8db3          	add	s11,s11,a5
    800024b8:	000dc703          	lbu	a4,0(s11)
    800024bc:	00a00793          	li	a5,10
    800024c0:	00900c93          	li	s9,9
    800024c4:	f8e404a3          	sb	a4,-119(s0)
    800024c8:	00065c63          	bgez	a2,800024e0 <__printf+0x278>
    800024cc:	f9040713          	addi	a4,s0,-112
    800024d0:	00f70733          	add	a4,a4,a5
    800024d4:	02d00693          	li	a3,45
    800024d8:	fed70823          	sb	a3,-16(a4)
    800024dc:	00078c93          	mv	s9,a5
    800024e0:	f8040793          	addi	a5,s0,-128
    800024e4:	01978cb3          	add	s9,a5,s9
    800024e8:	f7f40d13          	addi	s10,s0,-129
    800024ec:	000cc503          	lbu	a0,0(s9)
    800024f0:	fffc8c93          	addi	s9,s9,-1
    800024f4:	00000097          	auipc	ra,0x0
    800024f8:	b90080e7          	jalr	-1136(ra) # 80002084 <consputc>
    800024fc:	ffac98e3          	bne	s9,s10,800024ec <__printf+0x284>
    80002500:	00094503          	lbu	a0,0(s2)
    80002504:	e00514e3          	bnez	a0,8000230c <__printf+0xa4>
    80002508:	1a0c1663          	bnez	s8,800026b4 <__printf+0x44c>
    8000250c:	08813083          	ld	ra,136(sp)
    80002510:	08013403          	ld	s0,128(sp)
    80002514:	07813483          	ld	s1,120(sp)
    80002518:	07013903          	ld	s2,112(sp)
    8000251c:	06813983          	ld	s3,104(sp)
    80002520:	06013a03          	ld	s4,96(sp)
    80002524:	05813a83          	ld	s5,88(sp)
    80002528:	05013b03          	ld	s6,80(sp)
    8000252c:	04813b83          	ld	s7,72(sp)
    80002530:	04013c03          	ld	s8,64(sp)
    80002534:	03813c83          	ld	s9,56(sp)
    80002538:	03013d03          	ld	s10,48(sp)
    8000253c:	02813d83          	ld	s11,40(sp)
    80002540:	0d010113          	addi	sp,sp,208
    80002544:	00008067          	ret
    80002548:	07300713          	li	a4,115
    8000254c:	1ce78a63          	beq	a5,a4,80002720 <__printf+0x4b8>
    80002550:	07800713          	li	a4,120
    80002554:	1ee79e63          	bne	a5,a4,80002750 <__printf+0x4e8>
    80002558:	f7843783          	ld	a5,-136(s0)
    8000255c:	0007a703          	lw	a4,0(a5)
    80002560:	00878793          	addi	a5,a5,8
    80002564:	f6f43c23          	sd	a5,-136(s0)
    80002568:	28074263          	bltz	a4,800027ec <__printf+0x584>
    8000256c:	00002d97          	auipc	s11,0x2
    80002570:	cf4d8d93          	addi	s11,s11,-780 # 80004260 <digits>
    80002574:	00f77793          	andi	a5,a4,15
    80002578:	00fd87b3          	add	a5,s11,a5
    8000257c:	0007c683          	lbu	a3,0(a5)
    80002580:	00f00613          	li	a2,15
    80002584:	0007079b          	sext.w	a5,a4
    80002588:	f8d40023          	sb	a3,-128(s0)
    8000258c:	0047559b          	srliw	a1,a4,0x4
    80002590:	0047569b          	srliw	a3,a4,0x4
    80002594:	00000c93          	li	s9,0
    80002598:	0ee65063          	bge	a2,a4,80002678 <__printf+0x410>
    8000259c:	00f6f693          	andi	a3,a3,15
    800025a0:	00dd86b3          	add	a3,s11,a3
    800025a4:	0006c683          	lbu	a3,0(a3) # 2004000 <_entry-0x7dffc000>
    800025a8:	0087d79b          	srliw	a5,a5,0x8
    800025ac:	00100c93          	li	s9,1
    800025b0:	f8d400a3          	sb	a3,-127(s0)
    800025b4:	0cb67263          	bgeu	a2,a1,80002678 <__printf+0x410>
    800025b8:	00f7f693          	andi	a3,a5,15
    800025bc:	00dd86b3          	add	a3,s11,a3
    800025c0:	0006c583          	lbu	a1,0(a3)
    800025c4:	00f00613          	li	a2,15
    800025c8:	0047d69b          	srliw	a3,a5,0x4
    800025cc:	f8b40123          	sb	a1,-126(s0)
    800025d0:	0047d593          	srli	a1,a5,0x4
    800025d4:	28f67e63          	bgeu	a2,a5,80002870 <__printf+0x608>
    800025d8:	00f6f693          	andi	a3,a3,15
    800025dc:	00dd86b3          	add	a3,s11,a3
    800025e0:	0006c503          	lbu	a0,0(a3)
    800025e4:	0087d813          	srli	a6,a5,0x8
    800025e8:	0087d69b          	srliw	a3,a5,0x8
    800025ec:	f8a401a3          	sb	a0,-125(s0)
    800025f0:	28b67663          	bgeu	a2,a1,8000287c <__printf+0x614>
    800025f4:	00f6f693          	andi	a3,a3,15
    800025f8:	00dd86b3          	add	a3,s11,a3
    800025fc:	0006c583          	lbu	a1,0(a3)
    80002600:	00c7d513          	srli	a0,a5,0xc
    80002604:	00c7d69b          	srliw	a3,a5,0xc
    80002608:	f8b40223          	sb	a1,-124(s0)
    8000260c:	29067a63          	bgeu	a2,a6,800028a0 <__printf+0x638>
    80002610:	00f6f693          	andi	a3,a3,15
    80002614:	00dd86b3          	add	a3,s11,a3
    80002618:	0006c583          	lbu	a1,0(a3)
    8000261c:	0107d813          	srli	a6,a5,0x10
    80002620:	0107d69b          	srliw	a3,a5,0x10
    80002624:	f8b402a3          	sb	a1,-123(s0)
    80002628:	28a67263          	bgeu	a2,a0,800028ac <__printf+0x644>
    8000262c:	00f6f693          	andi	a3,a3,15
    80002630:	00dd86b3          	add	a3,s11,a3
    80002634:	0006c683          	lbu	a3,0(a3)
    80002638:	0147d79b          	srliw	a5,a5,0x14
    8000263c:	f8d40323          	sb	a3,-122(s0)
    80002640:	21067663          	bgeu	a2,a6,8000284c <__printf+0x5e4>
    80002644:	02079793          	slli	a5,a5,0x20
    80002648:	0207d793          	srli	a5,a5,0x20
    8000264c:	00fd8db3          	add	s11,s11,a5
    80002650:	000dc683          	lbu	a3,0(s11)
    80002654:	00800793          	li	a5,8
    80002658:	00700c93          	li	s9,7
    8000265c:	f8d403a3          	sb	a3,-121(s0)
    80002660:	00075c63          	bgez	a4,80002678 <__printf+0x410>
    80002664:	f9040713          	addi	a4,s0,-112
    80002668:	00f70733          	add	a4,a4,a5
    8000266c:	02d00693          	li	a3,45
    80002670:	fed70823          	sb	a3,-16(a4)
    80002674:	00078c93          	mv	s9,a5
    80002678:	f8040793          	addi	a5,s0,-128
    8000267c:	01978cb3          	add	s9,a5,s9
    80002680:	f7f40d13          	addi	s10,s0,-129
    80002684:	000cc503          	lbu	a0,0(s9)
    80002688:	fffc8c93          	addi	s9,s9,-1
    8000268c:	00000097          	auipc	ra,0x0
    80002690:	9f8080e7          	jalr	-1544(ra) # 80002084 <consputc>
    80002694:	ff9d18e3          	bne	s10,s9,80002684 <__printf+0x41c>
    80002698:	0100006f          	j	800026a8 <__printf+0x440>
    8000269c:	00000097          	auipc	ra,0x0
    800026a0:	9e8080e7          	jalr	-1560(ra) # 80002084 <consputc>
    800026a4:	000c8493          	mv	s1,s9
    800026a8:	00094503          	lbu	a0,0(s2)
    800026ac:	c60510e3          	bnez	a0,8000230c <__printf+0xa4>
    800026b0:	e40c0ee3          	beqz	s8,8000250c <__printf+0x2a4>
    800026b4:	00003517          	auipc	a0,0x3
    800026b8:	08c50513          	addi	a0,a0,140 # 80005740 <pr>
    800026bc:	00001097          	auipc	ra,0x1
    800026c0:	94c080e7          	jalr	-1716(ra) # 80003008 <release>
    800026c4:	e49ff06f          	j	8000250c <__printf+0x2a4>
    800026c8:	f7843783          	ld	a5,-136(s0)
    800026cc:	03000513          	li	a0,48
    800026d0:	01000d13          	li	s10,16
    800026d4:	00878713          	addi	a4,a5,8
    800026d8:	0007bc83          	ld	s9,0(a5)
    800026dc:	f6e43c23          	sd	a4,-136(s0)
    800026e0:	00000097          	auipc	ra,0x0
    800026e4:	9a4080e7          	jalr	-1628(ra) # 80002084 <consputc>
    800026e8:	07800513          	li	a0,120
    800026ec:	00000097          	auipc	ra,0x0
    800026f0:	998080e7          	jalr	-1640(ra) # 80002084 <consputc>
    800026f4:	00002d97          	auipc	s11,0x2
    800026f8:	b6cd8d93          	addi	s11,s11,-1172 # 80004260 <digits>
    800026fc:	03ccd793          	srli	a5,s9,0x3c
    80002700:	00fd87b3          	add	a5,s11,a5
    80002704:	0007c503          	lbu	a0,0(a5)
    80002708:	fffd0d1b          	addiw	s10,s10,-1
    8000270c:	004c9c93          	slli	s9,s9,0x4
    80002710:	00000097          	auipc	ra,0x0
    80002714:	974080e7          	jalr	-1676(ra) # 80002084 <consputc>
    80002718:	fe0d12e3          	bnez	s10,800026fc <__printf+0x494>
    8000271c:	f8dff06f          	j	800026a8 <__printf+0x440>
    80002720:	f7843783          	ld	a5,-136(s0)
    80002724:	0007bc83          	ld	s9,0(a5)
    80002728:	00878793          	addi	a5,a5,8
    8000272c:	f6f43c23          	sd	a5,-136(s0)
    80002730:	000c9a63          	bnez	s9,80002744 <__printf+0x4dc>
    80002734:	1080006f          	j	8000283c <__printf+0x5d4>
    80002738:	001c8c93          	addi	s9,s9,1
    8000273c:	00000097          	auipc	ra,0x0
    80002740:	948080e7          	jalr	-1720(ra) # 80002084 <consputc>
    80002744:	000cc503          	lbu	a0,0(s9)
    80002748:	fe0518e3          	bnez	a0,80002738 <__printf+0x4d0>
    8000274c:	f5dff06f          	j	800026a8 <__printf+0x440>
    80002750:	02500513          	li	a0,37
    80002754:	00000097          	auipc	ra,0x0
    80002758:	930080e7          	jalr	-1744(ra) # 80002084 <consputc>
    8000275c:	000c8513          	mv	a0,s9
    80002760:	00000097          	auipc	ra,0x0
    80002764:	924080e7          	jalr	-1756(ra) # 80002084 <consputc>
    80002768:	f41ff06f          	j	800026a8 <__printf+0x440>
    8000276c:	02500513          	li	a0,37
    80002770:	00000097          	auipc	ra,0x0
    80002774:	914080e7          	jalr	-1772(ra) # 80002084 <consputc>
    80002778:	f31ff06f          	j	800026a8 <__printf+0x440>
    8000277c:	00030513          	mv	a0,t1
    80002780:	00000097          	auipc	ra,0x0
    80002784:	7bc080e7          	jalr	1980(ra) # 80002f3c <acquire>
    80002788:	b4dff06f          	j	800022d4 <__printf+0x6c>
    8000278c:	40c0053b          	negw	a0,a2
    80002790:	00a00713          	li	a4,10
    80002794:	02e576bb          	remuw	a3,a0,a4
    80002798:	00002d97          	auipc	s11,0x2
    8000279c:	ac8d8d93          	addi	s11,s11,-1336 # 80004260 <digits>
    800027a0:	ff700593          	li	a1,-9
    800027a4:	02069693          	slli	a3,a3,0x20
    800027a8:	0206d693          	srli	a3,a3,0x20
    800027ac:	00dd86b3          	add	a3,s11,a3
    800027b0:	0006c683          	lbu	a3,0(a3)
    800027b4:	02e557bb          	divuw	a5,a0,a4
    800027b8:	f8d40023          	sb	a3,-128(s0)
    800027bc:	10b65e63          	bge	a2,a1,800028d8 <__printf+0x670>
    800027c0:	06300593          	li	a1,99
    800027c4:	02e7f6bb          	remuw	a3,a5,a4
    800027c8:	02069693          	slli	a3,a3,0x20
    800027cc:	0206d693          	srli	a3,a3,0x20
    800027d0:	00dd86b3          	add	a3,s11,a3
    800027d4:	0006c683          	lbu	a3,0(a3)
    800027d8:	02e7d73b          	divuw	a4,a5,a4
    800027dc:	00200793          	li	a5,2
    800027e0:	f8d400a3          	sb	a3,-127(s0)
    800027e4:	bca5ece3          	bltu	a1,a0,800023bc <__printf+0x154>
    800027e8:	ce5ff06f          	j	800024cc <__printf+0x264>
    800027ec:	40e007bb          	negw	a5,a4
    800027f0:	00002d97          	auipc	s11,0x2
    800027f4:	a70d8d93          	addi	s11,s11,-1424 # 80004260 <digits>
    800027f8:	00f7f693          	andi	a3,a5,15
    800027fc:	00dd86b3          	add	a3,s11,a3
    80002800:	0006c583          	lbu	a1,0(a3)
    80002804:	ff100613          	li	a2,-15
    80002808:	0047d69b          	srliw	a3,a5,0x4
    8000280c:	f8b40023          	sb	a1,-128(s0)
    80002810:	0047d59b          	srliw	a1,a5,0x4
    80002814:	0ac75e63          	bge	a4,a2,800028d0 <__printf+0x668>
    80002818:	00f6f693          	andi	a3,a3,15
    8000281c:	00dd86b3          	add	a3,s11,a3
    80002820:	0006c603          	lbu	a2,0(a3)
    80002824:	00f00693          	li	a3,15
    80002828:	0087d79b          	srliw	a5,a5,0x8
    8000282c:	f8c400a3          	sb	a2,-127(s0)
    80002830:	d8b6e4e3          	bltu	a3,a1,800025b8 <__printf+0x350>
    80002834:	00200793          	li	a5,2
    80002838:	e2dff06f          	j	80002664 <__printf+0x3fc>
    8000283c:	00002c97          	auipc	s9,0x2
    80002840:	a04c8c93          	addi	s9,s9,-1532 # 80004240 <CONSOLE_STATUS+0x230>
    80002844:	02800513          	li	a0,40
    80002848:	ef1ff06f          	j	80002738 <__printf+0x4d0>
    8000284c:	00700793          	li	a5,7
    80002850:	00600c93          	li	s9,6
    80002854:	e0dff06f          	j	80002660 <__printf+0x3f8>
    80002858:	00700793          	li	a5,7
    8000285c:	00600c93          	li	s9,6
    80002860:	c69ff06f          	j	800024c8 <__printf+0x260>
    80002864:	00300793          	li	a5,3
    80002868:	00200c93          	li	s9,2
    8000286c:	c5dff06f          	j	800024c8 <__printf+0x260>
    80002870:	00300793          	li	a5,3
    80002874:	00200c93          	li	s9,2
    80002878:	de9ff06f          	j	80002660 <__printf+0x3f8>
    8000287c:	00400793          	li	a5,4
    80002880:	00300c93          	li	s9,3
    80002884:	dddff06f          	j	80002660 <__printf+0x3f8>
    80002888:	00400793          	li	a5,4
    8000288c:	00300c93          	li	s9,3
    80002890:	c39ff06f          	j	800024c8 <__printf+0x260>
    80002894:	00500793          	li	a5,5
    80002898:	00400c93          	li	s9,4
    8000289c:	c2dff06f          	j	800024c8 <__printf+0x260>
    800028a0:	00500793          	li	a5,5
    800028a4:	00400c93          	li	s9,4
    800028a8:	db9ff06f          	j	80002660 <__printf+0x3f8>
    800028ac:	00600793          	li	a5,6
    800028b0:	00500c93          	li	s9,5
    800028b4:	dadff06f          	j	80002660 <__printf+0x3f8>
    800028b8:	00600793          	li	a5,6
    800028bc:	00500c93          	li	s9,5
    800028c0:	c09ff06f          	j	800024c8 <__printf+0x260>
    800028c4:	00800793          	li	a5,8
    800028c8:	00700c93          	li	s9,7
    800028cc:	bfdff06f          	j	800024c8 <__printf+0x260>
    800028d0:	00100793          	li	a5,1
    800028d4:	d91ff06f          	j	80002664 <__printf+0x3fc>
    800028d8:	00100793          	li	a5,1
    800028dc:	bf1ff06f          	j	800024cc <__printf+0x264>
    800028e0:	00900793          	li	a5,9
    800028e4:	00800c93          	li	s9,8
    800028e8:	be1ff06f          	j	800024c8 <__printf+0x260>
    800028ec:	00002517          	auipc	a0,0x2
    800028f0:	95c50513          	addi	a0,a0,-1700 # 80004248 <CONSOLE_STATUS+0x238>
    800028f4:	00000097          	auipc	ra,0x0
    800028f8:	918080e7          	jalr	-1768(ra) # 8000220c <panic>

00000000800028fc <printfinit>:
    800028fc:	fe010113          	addi	sp,sp,-32
    80002900:	00813823          	sd	s0,16(sp)
    80002904:	00913423          	sd	s1,8(sp)
    80002908:	00113c23          	sd	ra,24(sp)
    8000290c:	02010413          	addi	s0,sp,32
    80002910:	00003497          	auipc	s1,0x3
    80002914:	e3048493          	addi	s1,s1,-464 # 80005740 <pr>
    80002918:	00048513          	mv	a0,s1
    8000291c:	00002597          	auipc	a1,0x2
    80002920:	93c58593          	addi	a1,a1,-1732 # 80004258 <CONSOLE_STATUS+0x248>
    80002924:	00000097          	auipc	ra,0x0
    80002928:	5f4080e7          	jalr	1524(ra) # 80002f18 <initlock>
    8000292c:	01813083          	ld	ra,24(sp)
    80002930:	01013403          	ld	s0,16(sp)
    80002934:	0004ac23          	sw	zero,24(s1)
    80002938:	00813483          	ld	s1,8(sp)
    8000293c:	02010113          	addi	sp,sp,32
    80002940:	00008067          	ret

0000000080002944 <uartinit>:
    80002944:	ff010113          	addi	sp,sp,-16
    80002948:	00813423          	sd	s0,8(sp)
    8000294c:	01010413          	addi	s0,sp,16
    80002950:	100007b7          	lui	a5,0x10000
    80002954:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>
    80002958:	f8000713          	li	a4,-128
    8000295c:	00e781a3          	sb	a4,3(a5)
    80002960:	00300713          	li	a4,3
    80002964:	00e78023          	sb	a4,0(a5)
    80002968:	000780a3          	sb	zero,1(a5)
    8000296c:	00e781a3          	sb	a4,3(a5)
    80002970:	00700693          	li	a3,7
    80002974:	00d78123          	sb	a3,2(a5)
    80002978:	00e780a3          	sb	a4,1(a5)
    8000297c:	00813403          	ld	s0,8(sp)
    80002980:	01010113          	addi	sp,sp,16
    80002984:	00008067          	ret

0000000080002988 <uartputc>:
    80002988:	00002797          	auipc	a5,0x2
    8000298c:	b887a783          	lw	a5,-1144(a5) # 80004510 <panicked>
    80002990:	00078463          	beqz	a5,80002998 <uartputc+0x10>
    80002994:	0000006f          	j	80002994 <uartputc+0xc>
    80002998:	fd010113          	addi	sp,sp,-48
    8000299c:	02813023          	sd	s0,32(sp)
    800029a0:	00913c23          	sd	s1,24(sp)
    800029a4:	01213823          	sd	s2,16(sp)
    800029a8:	01313423          	sd	s3,8(sp)
    800029ac:	02113423          	sd	ra,40(sp)
    800029b0:	03010413          	addi	s0,sp,48
    800029b4:	00002917          	auipc	s2,0x2
    800029b8:	b6490913          	addi	s2,s2,-1180 # 80004518 <uart_tx_r>
    800029bc:	00093783          	ld	a5,0(s2)
    800029c0:	00002497          	auipc	s1,0x2
    800029c4:	b6048493          	addi	s1,s1,-1184 # 80004520 <uart_tx_w>
    800029c8:	0004b703          	ld	a4,0(s1)
    800029cc:	02078693          	addi	a3,a5,32
    800029d0:	00050993          	mv	s3,a0
    800029d4:	02e69c63          	bne	a3,a4,80002a0c <uartputc+0x84>
    800029d8:	00001097          	auipc	ra,0x1
    800029dc:	834080e7          	jalr	-1996(ra) # 8000320c <push_on>
    800029e0:	00093783          	ld	a5,0(s2)
    800029e4:	0004b703          	ld	a4,0(s1)
    800029e8:	02078793          	addi	a5,a5,32
    800029ec:	00e79463          	bne	a5,a4,800029f4 <uartputc+0x6c>
    800029f0:	0000006f          	j	800029f0 <uartputc+0x68>
    800029f4:	00001097          	auipc	ra,0x1
    800029f8:	88c080e7          	jalr	-1908(ra) # 80003280 <pop_on>
    800029fc:	00093783          	ld	a5,0(s2)
    80002a00:	0004b703          	ld	a4,0(s1)
    80002a04:	02078693          	addi	a3,a5,32
    80002a08:	fce688e3          	beq	a3,a4,800029d8 <uartputc+0x50>
    80002a0c:	01f77693          	andi	a3,a4,31
    80002a10:	00003597          	auipc	a1,0x3
    80002a14:	d5058593          	addi	a1,a1,-688 # 80005760 <uart_tx_buf>
    80002a18:	00d586b3          	add	a3,a1,a3
    80002a1c:	00170713          	addi	a4,a4,1
    80002a20:	01368023          	sb	s3,0(a3)
    80002a24:	00e4b023          	sd	a4,0(s1)
    80002a28:	10000637          	lui	a2,0x10000
    80002a2c:	02f71063          	bne	a4,a5,80002a4c <uartputc+0xc4>
    80002a30:	0340006f          	j	80002a64 <uartputc+0xdc>
    80002a34:	00074703          	lbu	a4,0(a4)
    80002a38:	00f93023          	sd	a5,0(s2)
    80002a3c:	00e60023          	sb	a4,0(a2) # 10000000 <_entry-0x70000000>
    80002a40:	00093783          	ld	a5,0(s2)
    80002a44:	0004b703          	ld	a4,0(s1)
    80002a48:	00f70e63          	beq	a4,a5,80002a64 <uartputc+0xdc>
    80002a4c:	00564683          	lbu	a3,5(a2)
    80002a50:	01f7f713          	andi	a4,a5,31
    80002a54:	00e58733          	add	a4,a1,a4
    80002a58:	0206f693          	andi	a3,a3,32
    80002a5c:	00178793          	addi	a5,a5,1
    80002a60:	fc069ae3          	bnez	a3,80002a34 <uartputc+0xac>
    80002a64:	02813083          	ld	ra,40(sp)
    80002a68:	02013403          	ld	s0,32(sp)
    80002a6c:	01813483          	ld	s1,24(sp)
    80002a70:	01013903          	ld	s2,16(sp)
    80002a74:	00813983          	ld	s3,8(sp)
    80002a78:	03010113          	addi	sp,sp,48
    80002a7c:	00008067          	ret

0000000080002a80 <uartputc_sync>:
    80002a80:	ff010113          	addi	sp,sp,-16
    80002a84:	00813423          	sd	s0,8(sp)
    80002a88:	01010413          	addi	s0,sp,16
    80002a8c:	00002717          	auipc	a4,0x2
    80002a90:	a8472703          	lw	a4,-1404(a4) # 80004510 <panicked>
    80002a94:	02071663          	bnez	a4,80002ac0 <uartputc_sync+0x40>
    80002a98:	00050793          	mv	a5,a0
    80002a9c:	100006b7          	lui	a3,0x10000
    80002aa0:	0056c703          	lbu	a4,5(a3) # 10000005 <_entry-0x6ffffffb>
    80002aa4:	02077713          	andi	a4,a4,32
    80002aa8:	fe070ce3          	beqz	a4,80002aa0 <uartputc_sync+0x20>
    80002aac:	0ff7f793          	andi	a5,a5,255
    80002ab0:	00f68023          	sb	a5,0(a3)
    80002ab4:	00813403          	ld	s0,8(sp)
    80002ab8:	01010113          	addi	sp,sp,16
    80002abc:	00008067          	ret
    80002ac0:	0000006f          	j	80002ac0 <uartputc_sync+0x40>

0000000080002ac4 <uartstart>:
    80002ac4:	ff010113          	addi	sp,sp,-16
    80002ac8:	00813423          	sd	s0,8(sp)
    80002acc:	01010413          	addi	s0,sp,16
    80002ad0:	00002617          	auipc	a2,0x2
    80002ad4:	a4860613          	addi	a2,a2,-1464 # 80004518 <uart_tx_r>
    80002ad8:	00002517          	auipc	a0,0x2
    80002adc:	a4850513          	addi	a0,a0,-1464 # 80004520 <uart_tx_w>
    80002ae0:	00063783          	ld	a5,0(a2)
    80002ae4:	00053703          	ld	a4,0(a0)
    80002ae8:	04f70263          	beq	a4,a5,80002b2c <uartstart+0x68>
    80002aec:	100005b7          	lui	a1,0x10000
    80002af0:	00003817          	auipc	a6,0x3
    80002af4:	c7080813          	addi	a6,a6,-912 # 80005760 <uart_tx_buf>
    80002af8:	01c0006f          	j	80002b14 <uartstart+0x50>
    80002afc:	0006c703          	lbu	a4,0(a3)
    80002b00:	00f63023          	sd	a5,0(a2)
    80002b04:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    80002b08:	00063783          	ld	a5,0(a2)
    80002b0c:	00053703          	ld	a4,0(a0)
    80002b10:	00f70e63          	beq	a4,a5,80002b2c <uartstart+0x68>
    80002b14:	01f7f713          	andi	a4,a5,31
    80002b18:	00e806b3          	add	a3,a6,a4
    80002b1c:	0055c703          	lbu	a4,5(a1)
    80002b20:	00178793          	addi	a5,a5,1
    80002b24:	02077713          	andi	a4,a4,32
    80002b28:	fc071ae3          	bnez	a4,80002afc <uartstart+0x38>
    80002b2c:	00813403          	ld	s0,8(sp)
    80002b30:	01010113          	addi	sp,sp,16
    80002b34:	00008067          	ret

0000000080002b38 <uartgetc>:
    80002b38:	ff010113          	addi	sp,sp,-16
    80002b3c:	00813423          	sd	s0,8(sp)
    80002b40:	01010413          	addi	s0,sp,16
    80002b44:	10000737          	lui	a4,0x10000
    80002b48:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80002b4c:	0017f793          	andi	a5,a5,1
    80002b50:	00078c63          	beqz	a5,80002b68 <uartgetc+0x30>
    80002b54:	00074503          	lbu	a0,0(a4)
    80002b58:	0ff57513          	andi	a0,a0,255
    80002b5c:	00813403          	ld	s0,8(sp)
    80002b60:	01010113          	addi	sp,sp,16
    80002b64:	00008067          	ret
    80002b68:	fff00513          	li	a0,-1
    80002b6c:	ff1ff06f          	j	80002b5c <uartgetc+0x24>

0000000080002b70 <uartintr>:
    80002b70:	100007b7          	lui	a5,0x10000
    80002b74:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80002b78:	0017f793          	andi	a5,a5,1
    80002b7c:	0a078463          	beqz	a5,80002c24 <uartintr+0xb4>
    80002b80:	fe010113          	addi	sp,sp,-32
    80002b84:	00813823          	sd	s0,16(sp)
    80002b88:	00913423          	sd	s1,8(sp)
    80002b8c:	00113c23          	sd	ra,24(sp)
    80002b90:	02010413          	addi	s0,sp,32
    80002b94:	100004b7          	lui	s1,0x10000
    80002b98:	0004c503          	lbu	a0,0(s1) # 10000000 <_entry-0x70000000>
    80002b9c:	0ff57513          	andi	a0,a0,255
    80002ba0:	fffff097          	auipc	ra,0xfffff
    80002ba4:	534080e7          	jalr	1332(ra) # 800020d4 <consoleintr>
    80002ba8:	0054c783          	lbu	a5,5(s1)
    80002bac:	0017f793          	andi	a5,a5,1
    80002bb0:	fe0794e3          	bnez	a5,80002b98 <uartintr+0x28>
    80002bb4:	00002617          	auipc	a2,0x2
    80002bb8:	96460613          	addi	a2,a2,-1692 # 80004518 <uart_tx_r>
    80002bbc:	00002517          	auipc	a0,0x2
    80002bc0:	96450513          	addi	a0,a0,-1692 # 80004520 <uart_tx_w>
    80002bc4:	00063783          	ld	a5,0(a2)
    80002bc8:	00053703          	ld	a4,0(a0)
    80002bcc:	04f70263          	beq	a4,a5,80002c10 <uartintr+0xa0>
    80002bd0:	100005b7          	lui	a1,0x10000
    80002bd4:	00003817          	auipc	a6,0x3
    80002bd8:	b8c80813          	addi	a6,a6,-1140 # 80005760 <uart_tx_buf>
    80002bdc:	01c0006f          	j	80002bf8 <uartintr+0x88>
    80002be0:	0006c703          	lbu	a4,0(a3)
    80002be4:	00f63023          	sd	a5,0(a2)
    80002be8:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    80002bec:	00063783          	ld	a5,0(a2)
    80002bf0:	00053703          	ld	a4,0(a0)
    80002bf4:	00f70e63          	beq	a4,a5,80002c10 <uartintr+0xa0>
    80002bf8:	01f7f713          	andi	a4,a5,31
    80002bfc:	00e806b3          	add	a3,a6,a4
    80002c00:	0055c703          	lbu	a4,5(a1)
    80002c04:	00178793          	addi	a5,a5,1
    80002c08:	02077713          	andi	a4,a4,32
    80002c0c:	fc071ae3          	bnez	a4,80002be0 <uartintr+0x70>
    80002c10:	01813083          	ld	ra,24(sp)
    80002c14:	01013403          	ld	s0,16(sp)
    80002c18:	00813483          	ld	s1,8(sp)
    80002c1c:	02010113          	addi	sp,sp,32
    80002c20:	00008067          	ret
    80002c24:	00002617          	auipc	a2,0x2
    80002c28:	8f460613          	addi	a2,a2,-1804 # 80004518 <uart_tx_r>
    80002c2c:	00002517          	auipc	a0,0x2
    80002c30:	8f450513          	addi	a0,a0,-1804 # 80004520 <uart_tx_w>
    80002c34:	00063783          	ld	a5,0(a2)
    80002c38:	00053703          	ld	a4,0(a0)
    80002c3c:	04f70263          	beq	a4,a5,80002c80 <uartintr+0x110>
    80002c40:	100005b7          	lui	a1,0x10000
    80002c44:	00003817          	auipc	a6,0x3
    80002c48:	b1c80813          	addi	a6,a6,-1252 # 80005760 <uart_tx_buf>
    80002c4c:	01c0006f          	j	80002c68 <uartintr+0xf8>
    80002c50:	0006c703          	lbu	a4,0(a3)
    80002c54:	00f63023          	sd	a5,0(a2)
    80002c58:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    80002c5c:	00063783          	ld	a5,0(a2)
    80002c60:	00053703          	ld	a4,0(a0)
    80002c64:	02f70063          	beq	a4,a5,80002c84 <uartintr+0x114>
    80002c68:	01f7f713          	andi	a4,a5,31
    80002c6c:	00e806b3          	add	a3,a6,a4
    80002c70:	0055c703          	lbu	a4,5(a1)
    80002c74:	00178793          	addi	a5,a5,1
    80002c78:	02077713          	andi	a4,a4,32
    80002c7c:	fc071ae3          	bnez	a4,80002c50 <uartintr+0xe0>
    80002c80:	00008067          	ret
    80002c84:	00008067          	ret

0000000080002c88 <kinit>:
    80002c88:	fc010113          	addi	sp,sp,-64
    80002c8c:	02913423          	sd	s1,40(sp)
    80002c90:	fffff7b7          	lui	a5,0xfffff
    80002c94:	00004497          	auipc	s1,0x4
    80002c98:	aeb48493          	addi	s1,s1,-1301 # 8000677f <end+0xfff>
    80002c9c:	02813823          	sd	s0,48(sp)
    80002ca0:	01313c23          	sd	s3,24(sp)
    80002ca4:	00f4f4b3          	and	s1,s1,a5
    80002ca8:	02113c23          	sd	ra,56(sp)
    80002cac:	03213023          	sd	s2,32(sp)
    80002cb0:	01413823          	sd	s4,16(sp)
    80002cb4:	01513423          	sd	s5,8(sp)
    80002cb8:	04010413          	addi	s0,sp,64
    80002cbc:	000017b7          	lui	a5,0x1
    80002cc0:	01100993          	li	s3,17
    80002cc4:	00f487b3          	add	a5,s1,a5
    80002cc8:	01b99993          	slli	s3,s3,0x1b
    80002ccc:	06f9e063          	bltu	s3,a5,80002d2c <kinit+0xa4>
    80002cd0:	00003a97          	auipc	s5,0x3
    80002cd4:	ab0a8a93          	addi	s5,s5,-1360 # 80005780 <end>
    80002cd8:	0754ec63          	bltu	s1,s5,80002d50 <kinit+0xc8>
    80002cdc:	0734fa63          	bgeu	s1,s3,80002d50 <kinit+0xc8>
    80002ce0:	00088a37          	lui	s4,0x88
    80002ce4:	fffa0a13          	addi	s4,s4,-1 # 87fff <_entry-0x7ff78001>
    80002ce8:	00002917          	auipc	s2,0x2
    80002cec:	84090913          	addi	s2,s2,-1984 # 80004528 <kmem>
    80002cf0:	00ca1a13          	slli	s4,s4,0xc
    80002cf4:	0140006f          	j	80002d08 <kinit+0x80>
    80002cf8:	000017b7          	lui	a5,0x1
    80002cfc:	00f484b3          	add	s1,s1,a5
    80002d00:	0554e863          	bltu	s1,s5,80002d50 <kinit+0xc8>
    80002d04:	0534f663          	bgeu	s1,s3,80002d50 <kinit+0xc8>
    80002d08:	00001637          	lui	a2,0x1
    80002d0c:	00100593          	li	a1,1
    80002d10:	00048513          	mv	a0,s1
    80002d14:	00000097          	auipc	ra,0x0
    80002d18:	5e4080e7          	jalr	1508(ra) # 800032f8 <__memset>
    80002d1c:	00093783          	ld	a5,0(s2)
    80002d20:	00f4b023          	sd	a5,0(s1)
    80002d24:	00993023          	sd	s1,0(s2)
    80002d28:	fd4498e3          	bne	s1,s4,80002cf8 <kinit+0x70>
    80002d2c:	03813083          	ld	ra,56(sp)
    80002d30:	03013403          	ld	s0,48(sp)
    80002d34:	02813483          	ld	s1,40(sp)
    80002d38:	02013903          	ld	s2,32(sp)
    80002d3c:	01813983          	ld	s3,24(sp)
    80002d40:	01013a03          	ld	s4,16(sp)
    80002d44:	00813a83          	ld	s5,8(sp)
    80002d48:	04010113          	addi	sp,sp,64
    80002d4c:	00008067          	ret
    80002d50:	00001517          	auipc	a0,0x1
    80002d54:	52850513          	addi	a0,a0,1320 # 80004278 <digits+0x18>
    80002d58:	fffff097          	auipc	ra,0xfffff
    80002d5c:	4b4080e7          	jalr	1204(ra) # 8000220c <panic>

0000000080002d60 <freerange>:
    80002d60:	fc010113          	addi	sp,sp,-64
    80002d64:	000017b7          	lui	a5,0x1
    80002d68:	02913423          	sd	s1,40(sp)
    80002d6c:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80002d70:	009504b3          	add	s1,a0,s1
    80002d74:	fffff537          	lui	a0,0xfffff
    80002d78:	02813823          	sd	s0,48(sp)
    80002d7c:	02113c23          	sd	ra,56(sp)
    80002d80:	03213023          	sd	s2,32(sp)
    80002d84:	01313c23          	sd	s3,24(sp)
    80002d88:	01413823          	sd	s4,16(sp)
    80002d8c:	01513423          	sd	s5,8(sp)
    80002d90:	01613023          	sd	s6,0(sp)
    80002d94:	04010413          	addi	s0,sp,64
    80002d98:	00a4f4b3          	and	s1,s1,a0
    80002d9c:	00f487b3          	add	a5,s1,a5
    80002da0:	06f5e463          	bltu	a1,a5,80002e08 <freerange+0xa8>
    80002da4:	00003a97          	auipc	s5,0x3
    80002da8:	9dca8a93          	addi	s5,s5,-1572 # 80005780 <end>
    80002dac:	0954e263          	bltu	s1,s5,80002e30 <freerange+0xd0>
    80002db0:	01100993          	li	s3,17
    80002db4:	01b99993          	slli	s3,s3,0x1b
    80002db8:	0734fc63          	bgeu	s1,s3,80002e30 <freerange+0xd0>
    80002dbc:	00058a13          	mv	s4,a1
    80002dc0:	00001917          	auipc	s2,0x1
    80002dc4:	76890913          	addi	s2,s2,1896 # 80004528 <kmem>
    80002dc8:	00002b37          	lui	s6,0x2
    80002dcc:	0140006f          	j	80002de0 <freerange+0x80>
    80002dd0:	000017b7          	lui	a5,0x1
    80002dd4:	00f484b3          	add	s1,s1,a5
    80002dd8:	0554ec63          	bltu	s1,s5,80002e30 <freerange+0xd0>
    80002ddc:	0534fa63          	bgeu	s1,s3,80002e30 <freerange+0xd0>
    80002de0:	00001637          	lui	a2,0x1
    80002de4:	00100593          	li	a1,1
    80002de8:	00048513          	mv	a0,s1
    80002dec:	00000097          	auipc	ra,0x0
    80002df0:	50c080e7          	jalr	1292(ra) # 800032f8 <__memset>
    80002df4:	00093703          	ld	a4,0(s2)
    80002df8:	016487b3          	add	a5,s1,s6
    80002dfc:	00e4b023          	sd	a4,0(s1)
    80002e00:	00993023          	sd	s1,0(s2)
    80002e04:	fcfa76e3          	bgeu	s4,a5,80002dd0 <freerange+0x70>
    80002e08:	03813083          	ld	ra,56(sp)
    80002e0c:	03013403          	ld	s0,48(sp)
    80002e10:	02813483          	ld	s1,40(sp)
    80002e14:	02013903          	ld	s2,32(sp)
    80002e18:	01813983          	ld	s3,24(sp)
    80002e1c:	01013a03          	ld	s4,16(sp)
    80002e20:	00813a83          	ld	s5,8(sp)
    80002e24:	00013b03          	ld	s6,0(sp)
    80002e28:	04010113          	addi	sp,sp,64
    80002e2c:	00008067          	ret
    80002e30:	00001517          	auipc	a0,0x1
    80002e34:	44850513          	addi	a0,a0,1096 # 80004278 <digits+0x18>
    80002e38:	fffff097          	auipc	ra,0xfffff
    80002e3c:	3d4080e7          	jalr	980(ra) # 8000220c <panic>

0000000080002e40 <kfree>:
    80002e40:	fe010113          	addi	sp,sp,-32
    80002e44:	00813823          	sd	s0,16(sp)
    80002e48:	00113c23          	sd	ra,24(sp)
    80002e4c:	00913423          	sd	s1,8(sp)
    80002e50:	02010413          	addi	s0,sp,32
    80002e54:	03451793          	slli	a5,a0,0x34
    80002e58:	04079c63          	bnez	a5,80002eb0 <kfree+0x70>
    80002e5c:	00003797          	auipc	a5,0x3
    80002e60:	92478793          	addi	a5,a5,-1756 # 80005780 <end>
    80002e64:	00050493          	mv	s1,a0
    80002e68:	04f56463          	bltu	a0,a5,80002eb0 <kfree+0x70>
    80002e6c:	01100793          	li	a5,17
    80002e70:	01b79793          	slli	a5,a5,0x1b
    80002e74:	02f57e63          	bgeu	a0,a5,80002eb0 <kfree+0x70>
    80002e78:	00001637          	lui	a2,0x1
    80002e7c:	00100593          	li	a1,1
    80002e80:	00000097          	auipc	ra,0x0
    80002e84:	478080e7          	jalr	1144(ra) # 800032f8 <__memset>
    80002e88:	00001797          	auipc	a5,0x1
    80002e8c:	6a078793          	addi	a5,a5,1696 # 80004528 <kmem>
    80002e90:	0007b703          	ld	a4,0(a5)
    80002e94:	01813083          	ld	ra,24(sp)
    80002e98:	01013403          	ld	s0,16(sp)
    80002e9c:	00e4b023          	sd	a4,0(s1)
    80002ea0:	0097b023          	sd	s1,0(a5)
    80002ea4:	00813483          	ld	s1,8(sp)
    80002ea8:	02010113          	addi	sp,sp,32
    80002eac:	00008067          	ret
    80002eb0:	00001517          	auipc	a0,0x1
    80002eb4:	3c850513          	addi	a0,a0,968 # 80004278 <digits+0x18>
    80002eb8:	fffff097          	auipc	ra,0xfffff
    80002ebc:	354080e7          	jalr	852(ra) # 8000220c <panic>

0000000080002ec0 <kalloc>:
    80002ec0:	fe010113          	addi	sp,sp,-32
    80002ec4:	00813823          	sd	s0,16(sp)
    80002ec8:	00913423          	sd	s1,8(sp)
    80002ecc:	00113c23          	sd	ra,24(sp)
    80002ed0:	02010413          	addi	s0,sp,32
    80002ed4:	00001797          	auipc	a5,0x1
    80002ed8:	65478793          	addi	a5,a5,1620 # 80004528 <kmem>
    80002edc:	0007b483          	ld	s1,0(a5)
    80002ee0:	02048063          	beqz	s1,80002f00 <kalloc+0x40>
    80002ee4:	0004b703          	ld	a4,0(s1)
    80002ee8:	00001637          	lui	a2,0x1
    80002eec:	00500593          	li	a1,5
    80002ef0:	00048513          	mv	a0,s1
    80002ef4:	00e7b023          	sd	a4,0(a5)
    80002ef8:	00000097          	auipc	ra,0x0
    80002efc:	400080e7          	jalr	1024(ra) # 800032f8 <__memset>
    80002f00:	01813083          	ld	ra,24(sp)
    80002f04:	01013403          	ld	s0,16(sp)
    80002f08:	00048513          	mv	a0,s1
    80002f0c:	00813483          	ld	s1,8(sp)
    80002f10:	02010113          	addi	sp,sp,32
    80002f14:	00008067          	ret

0000000080002f18 <initlock>:
    80002f18:	ff010113          	addi	sp,sp,-16
    80002f1c:	00813423          	sd	s0,8(sp)
    80002f20:	01010413          	addi	s0,sp,16
    80002f24:	00813403          	ld	s0,8(sp)
    80002f28:	00b53423          	sd	a1,8(a0)
    80002f2c:	00052023          	sw	zero,0(a0)
    80002f30:	00053823          	sd	zero,16(a0)
    80002f34:	01010113          	addi	sp,sp,16
    80002f38:	00008067          	ret

0000000080002f3c <acquire>:
    80002f3c:	fe010113          	addi	sp,sp,-32
    80002f40:	00813823          	sd	s0,16(sp)
    80002f44:	00913423          	sd	s1,8(sp)
    80002f48:	00113c23          	sd	ra,24(sp)
    80002f4c:	01213023          	sd	s2,0(sp)
    80002f50:	02010413          	addi	s0,sp,32
    80002f54:	00050493          	mv	s1,a0
    80002f58:	10002973          	csrr	s2,sstatus
    80002f5c:	100027f3          	csrr	a5,sstatus
    80002f60:	ffd7f793          	andi	a5,a5,-3
    80002f64:	10079073          	csrw	sstatus,a5
    80002f68:	fffff097          	auipc	ra,0xfffff
    80002f6c:	8e8080e7          	jalr	-1816(ra) # 80001850 <mycpu>
    80002f70:	07852783          	lw	a5,120(a0)
    80002f74:	06078e63          	beqz	a5,80002ff0 <acquire+0xb4>
    80002f78:	fffff097          	auipc	ra,0xfffff
    80002f7c:	8d8080e7          	jalr	-1832(ra) # 80001850 <mycpu>
    80002f80:	07852783          	lw	a5,120(a0)
    80002f84:	0004a703          	lw	a4,0(s1)
    80002f88:	0017879b          	addiw	a5,a5,1
    80002f8c:	06f52c23          	sw	a5,120(a0)
    80002f90:	04071063          	bnez	a4,80002fd0 <acquire+0x94>
    80002f94:	00100713          	li	a4,1
    80002f98:	00070793          	mv	a5,a4
    80002f9c:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80002fa0:	0007879b          	sext.w	a5,a5
    80002fa4:	fe079ae3          	bnez	a5,80002f98 <acquire+0x5c>
    80002fa8:	0ff0000f          	fence
    80002fac:	fffff097          	auipc	ra,0xfffff
    80002fb0:	8a4080e7          	jalr	-1884(ra) # 80001850 <mycpu>
    80002fb4:	01813083          	ld	ra,24(sp)
    80002fb8:	01013403          	ld	s0,16(sp)
    80002fbc:	00a4b823          	sd	a0,16(s1)
    80002fc0:	00013903          	ld	s2,0(sp)
    80002fc4:	00813483          	ld	s1,8(sp)
    80002fc8:	02010113          	addi	sp,sp,32
    80002fcc:	00008067          	ret
    80002fd0:	0104b903          	ld	s2,16(s1)
    80002fd4:	fffff097          	auipc	ra,0xfffff
    80002fd8:	87c080e7          	jalr	-1924(ra) # 80001850 <mycpu>
    80002fdc:	faa91ce3          	bne	s2,a0,80002f94 <acquire+0x58>
    80002fe0:	00001517          	auipc	a0,0x1
    80002fe4:	2a050513          	addi	a0,a0,672 # 80004280 <digits+0x20>
    80002fe8:	fffff097          	auipc	ra,0xfffff
    80002fec:	224080e7          	jalr	548(ra) # 8000220c <panic>
    80002ff0:	00195913          	srli	s2,s2,0x1
    80002ff4:	fffff097          	auipc	ra,0xfffff
    80002ff8:	85c080e7          	jalr	-1956(ra) # 80001850 <mycpu>
    80002ffc:	00197913          	andi	s2,s2,1
    80003000:	07252e23          	sw	s2,124(a0)
    80003004:	f75ff06f          	j	80002f78 <acquire+0x3c>

0000000080003008 <release>:
    80003008:	fe010113          	addi	sp,sp,-32
    8000300c:	00813823          	sd	s0,16(sp)
    80003010:	00113c23          	sd	ra,24(sp)
    80003014:	00913423          	sd	s1,8(sp)
    80003018:	01213023          	sd	s2,0(sp)
    8000301c:	02010413          	addi	s0,sp,32
    80003020:	00052783          	lw	a5,0(a0)
    80003024:	00079a63          	bnez	a5,80003038 <release+0x30>
    80003028:	00001517          	auipc	a0,0x1
    8000302c:	26050513          	addi	a0,a0,608 # 80004288 <digits+0x28>
    80003030:	fffff097          	auipc	ra,0xfffff
    80003034:	1dc080e7          	jalr	476(ra) # 8000220c <panic>
    80003038:	01053903          	ld	s2,16(a0)
    8000303c:	00050493          	mv	s1,a0
    80003040:	fffff097          	auipc	ra,0xfffff
    80003044:	810080e7          	jalr	-2032(ra) # 80001850 <mycpu>
    80003048:	fea910e3          	bne	s2,a0,80003028 <release+0x20>
    8000304c:	0004b823          	sd	zero,16(s1)
    80003050:	0ff0000f          	fence
    80003054:	0f50000f          	fence	iorw,ow
    80003058:	0804a02f          	amoswap.w	zero,zero,(s1)
    8000305c:	ffffe097          	auipc	ra,0xffffe
    80003060:	7f4080e7          	jalr	2036(ra) # 80001850 <mycpu>
    80003064:	100027f3          	csrr	a5,sstatus
    80003068:	0027f793          	andi	a5,a5,2
    8000306c:	04079a63          	bnez	a5,800030c0 <release+0xb8>
    80003070:	07852783          	lw	a5,120(a0)
    80003074:	02f05e63          	blez	a5,800030b0 <release+0xa8>
    80003078:	fff7871b          	addiw	a4,a5,-1
    8000307c:	06e52c23          	sw	a4,120(a0)
    80003080:	00071c63          	bnez	a4,80003098 <release+0x90>
    80003084:	07c52783          	lw	a5,124(a0)
    80003088:	00078863          	beqz	a5,80003098 <release+0x90>
    8000308c:	100027f3          	csrr	a5,sstatus
    80003090:	0027e793          	ori	a5,a5,2
    80003094:	10079073          	csrw	sstatus,a5
    80003098:	01813083          	ld	ra,24(sp)
    8000309c:	01013403          	ld	s0,16(sp)
    800030a0:	00813483          	ld	s1,8(sp)
    800030a4:	00013903          	ld	s2,0(sp)
    800030a8:	02010113          	addi	sp,sp,32
    800030ac:	00008067          	ret
    800030b0:	00001517          	auipc	a0,0x1
    800030b4:	1f850513          	addi	a0,a0,504 # 800042a8 <digits+0x48>
    800030b8:	fffff097          	auipc	ra,0xfffff
    800030bc:	154080e7          	jalr	340(ra) # 8000220c <panic>
    800030c0:	00001517          	auipc	a0,0x1
    800030c4:	1d050513          	addi	a0,a0,464 # 80004290 <digits+0x30>
    800030c8:	fffff097          	auipc	ra,0xfffff
    800030cc:	144080e7          	jalr	324(ra) # 8000220c <panic>

00000000800030d0 <holding>:
    800030d0:	00052783          	lw	a5,0(a0)
    800030d4:	00079663          	bnez	a5,800030e0 <holding+0x10>
    800030d8:	00000513          	li	a0,0
    800030dc:	00008067          	ret
    800030e0:	fe010113          	addi	sp,sp,-32
    800030e4:	00813823          	sd	s0,16(sp)
    800030e8:	00913423          	sd	s1,8(sp)
    800030ec:	00113c23          	sd	ra,24(sp)
    800030f0:	02010413          	addi	s0,sp,32
    800030f4:	01053483          	ld	s1,16(a0)
    800030f8:	ffffe097          	auipc	ra,0xffffe
    800030fc:	758080e7          	jalr	1880(ra) # 80001850 <mycpu>
    80003100:	01813083          	ld	ra,24(sp)
    80003104:	01013403          	ld	s0,16(sp)
    80003108:	40a48533          	sub	a0,s1,a0
    8000310c:	00153513          	seqz	a0,a0
    80003110:	00813483          	ld	s1,8(sp)
    80003114:	02010113          	addi	sp,sp,32
    80003118:	00008067          	ret

000000008000311c <push_off>:
    8000311c:	fe010113          	addi	sp,sp,-32
    80003120:	00813823          	sd	s0,16(sp)
    80003124:	00113c23          	sd	ra,24(sp)
    80003128:	00913423          	sd	s1,8(sp)
    8000312c:	02010413          	addi	s0,sp,32
    80003130:	100024f3          	csrr	s1,sstatus
    80003134:	100027f3          	csrr	a5,sstatus
    80003138:	ffd7f793          	andi	a5,a5,-3
    8000313c:	10079073          	csrw	sstatus,a5
    80003140:	ffffe097          	auipc	ra,0xffffe
    80003144:	710080e7          	jalr	1808(ra) # 80001850 <mycpu>
    80003148:	07852783          	lw	a5,120(a0)
    8000314c:	02078663          	beqz	a5,80003178 <push_off+0x5c>
    80003150:	ffffe097          	auipc	ra,0xffffe
    80003154:	700080e7          	jalr	1792(ra) # 80001850 <mycpu>
    80003158:	07852783          	lw	a5,120(a0)
    8000315c:	01813083          	ld	ra,24(sp)
    80003160:	01013403          	ld	s0,16(sp)
    80003164:	0017879b          	addiw	a5,a5,1
    80003168:	06f52c23          	sw	a5,120(a0)
    8000316c:	00813483          	ld	s1,8(sp)
    80003170:	02010113          	addi	sp,sp,32
    80003174:	00008067          	ret
    80003178:	0014d493          	srli	s1,s1,0x1
    8000317c:	ffffe097          	auipc	ra,0xffffe
    80003180:	6d4080e7          	jalr	1748(ra) # 80001850 <mycpu>
    80003184:	0014f493          	andi	s1,s1,1
    80003188:	06952e23          	sw	s1,124(a0)
    8000318c:	fc5ff06f          	j	80003150 <push_off+0x34>

0000000080003190 <pop_off>:
    80003190:	ff010113          	addi	sp,sp,-16
    80003194:	00813023          	sd	s0,0(sp)
    80003198:	00113423          	sd	ra,8(sp)
    8000319c:	01010413          	addi	s0,sp,16
    800031a0:	ffffe097          	auipc	ra,0xffffe
    800031a4:	6b0080e7          	jalr	1712(ra) # 80001850 <mycpu>
    800031a8:	100027f3          	csrr	a5,sstatus
    800031ac:	0027f793          	andi	a5,a5,2
    800031b0:	04079663          	bnez	a5,800031fc <pop_off+0x6c>
    800031b4:	07852783          	lw	a5,120(a0)
    800031b8:	02f05a63          	blez	a5,800031ec <pop_off+0x5c>
    800031bc:	fff7871b          	addiw	a4,a5,-1
    800031c0:	06e52c23          	sw	a4,120(a0)
    800031c4:	00071c63          	bnez	a4,800031dc <pop_off+0x4c>
    800031c8:	07c52783          	lw	a5,124(a0)
    800031cc:	00078863          	beqz	a5,800031dc <pop_off+0x4c>
    800031d0:	100027f3          	csrr	a5,sstatus
    800031d4:	0027e793          	ori	a5,a5,2
    800031d8:	10079073          	csrw	sstatus,a5
    800031dc:	00813083          	ld	ra,8(sp)
    800031e0:	00013403          	ld	s0,0(sp)
    800031e4:	01010113          	addi	sp,sp,16
    800031e8:	00008067          	ret
    800031ec:	00001517          	auipc	a0,0x1
    800031f0:	0bc50513          	addi	a0,a0,188 # 800042a8 <digits+0x48>
    800031f4:	fffff097          	auipc	ra,0xfffff
    800031f8:	018080e7          	jalr	24(ra) # 8000220c <panic>
    800031fc:	00001517          	auipc	a0,0x1
    80003200:	09450513          	addi	a0,a0,148 # 80004290 <digits+0x30>
    80003204:	fffff097          	auipc	ra,0xfffff
    80003208:	008080e7          	jalr	8(ra) # 8000220c <panic>

000000008000320c <push_on>:
    8000320c:	fe010113          	addi	sp,sp,-32
    80003210:	00813823          	sd	s0,16(sp)
    80003214:	00113c23          	sd	ra,24(sp)
    80003218:	00913423          	sd	s1,8(sp)
    8000321c:	02010413          	addi	s0,sp,32
    80003220:	100024f3          	csrr	s1,sstatus
    80003224:	100027f3          	csrr	a5,sstatus
    80003228:	0027e793          	ori	a5,a5,2
    8000322c:	10079073          	csrw	sstatus,a5
    80003230:	ffffe097          	auipc	ra,0xffffe
    80003234:	620080e7          	jalr	1568(ra) # 80001850 <mycpu>
    80003238:	07852783          	lw	a5,120(a0)
    8000323c:	02078663          	beqz	a5,80003268 <push_on+0x5c>
    80003240:	ffffe097          	auipc	ra,0xffffe
    80003244:	610080e7          	jalr	1552(ra) # 80001850 <mycpu>
    80003248:	07852783          	lw	a5,120(a0)
    8000324c:	01813083          	ld	ra,24(sp)
    80003250:	01013403          	ld	s0,16(sp)
    80003254:	0017879b          	addiw	a5,a5,1
    80003258:	06f52c23          	sw	a5,120(a0)
    8000325c:	00813483          	ld	s1,8(sp)
    80003260:	02010113          	addi	sp,sp,32
    80003264:	00008067          	ret
    80003268:	0014d493          	srli	s1,s1,0x1
    8000326c:	ffffe097          	auipc	ra,0xffffe
    80003270:	5e4080e7          	jalr	1508(ra) # 80001850 <mycpu>
    80003274:	0014f493          	andi	s1,s1,1
    80003278:	06952e23          	sw	s1,124(a0)
    8000327c:	fc5ff06f          	j	80003240 <push_on+0x34>

0000000080003280 <pop_on>:
    80003280:	ff010113          	addi	sp,sp,-16
    80003284:	00813023          	sd	s0,0(sp)
    80003288:	00113423          	sd	ra,8(sp)
    8000328c:	01010413          	addi	s0,sp,16
    80003290:	ffffe097          	auipc	ra,0xffffe
    80003294:	5c0080e7          	jalr	1472(ra) # 80001850 <mycpu>
    80003298:	100027f3          	csrr	a5,sstatus
    8000329c:	0027f793          	andi	a5,a5,2
    800032a0:	04078463          	beqz	a5,800032e8 <pop_on+0x68>
    800032a4:	07852783          	lw	a5,120(a0)
    800032a8:	02f05863          	blez	a5,800032d8 <pop_on+0x58>
    800032ac:	fff7879b          	addiw	a5,a5,-1
    800032b0:	06f52c23          	sw	a5,120(a0)
    800032b4:	07853783          	ld	a5,120(a0)
    800032b8:	00079863          	bnez	a5,800032c8 <pop_on+0x48>
    800032bc:	100027f3          	csrr	a5,sstatus
    800032c0:	ffd7f793          	andi	a5,a5,-3
    800032c4:	10079073          	csrw	sstatus,a5
    800032c8:	00813083          	ld	ra,8(sp)
    800032cc:	00013403          	ld	s0,0(sp)
    800032d0:	01010113          	addi	sp,sp,16
    800032d4:	00008067          	ret
    800032d8:	00001517          	auipc	a0,0x1
    800032dc:	ff850513          	addi	a0,a0,-8 # 800042d0 <digits+0x70>
    800032e0:	fffff097          	auipc	ra,0xfffff
    800032e4:	f2c080e7          	jalr	-212(ra) # 8000220c <panic>
    800032e8:	00001517          	auipc	a0,0x1
    800032ec:	fc850513          	addi	a0,a0,-56 # 800042b0 <digits+0x50>
    800032f0:	fffff097          	auipc	ra,0xfffff
    800032f4:	f1c080e7          	jalr	-228(ra) # 8000220c <panic>

00000000800032f8 <__memset>:
    800032f8:	ff010113          	addi	sp,sp,-16
    800032fc:	00813423          	sd	s0,8(sp)
    80003300:	01010413          	addi	s0,sp,16
    80003304:	1a060e63          	beqz	a2,800034c0 <__memset+0x1c8>
    80003308:	40a007b3          	neg	a5,a0
    8000330c:	0077f793          	andi	a5,a5,7
    80003310:	00778693          	addi	a3,a5,7
    80003314:	00b00813          	li	a6,11
    80003318:	0ff5f593          	andi	a1,a1,255
    8000331c:	fff6071b          	addiw	a4,a2,-1
    80003320:	1b06e663          	bltu	a3,a6,800034cc <__memset+0x1d4>
    80003324:	1cd76463          	bltu	a4,a3,800034ec <__memset+0x1f4>
    80003328:	1a078e63          	beqz	a5,800034e4 <__memset+0x1ec>
    8000332c:	00b50023          	sb	a1,0(a0)
    80003330:	00100713          	li	a4,1
    80003334:	1ae78463          	beq	a5,a4,800034dc <__memset+0x1e4>
    80003338:	00b500a3          	sb	a1,1(a0)
    8000333c:	00200713          	li	a4,2
    80003340:	1ae78a63          	beq	a5,a4,800034f4 <__memset+0x1fc>
    80003344:	00b50123          	sb	a1,2(a0)
    80003348:	00300713          	li	a4,3
    8000334c:	18e78463          	beq	a5,a4,800034d4 <__memset+0x1dc>
    80003350:	00b501a3          	sb	a1,3(a0)
    80003354:	00400713          	li	a4,4
    80003358:	1ae78263          	beq	a5,a4,800034fc <__memset+0x204>
    8000335c:	00b50223          	sb	a1,4(a0)
    80003360:	00500713          	li	a4,5
    80003364:	1ae78063          	beq	a5,a4,80003504 <__memset+0x20c>
    80003368:	00b502a3          	sb	a1,5(a0)
    8000336c:	00700713          	li	a4,7
    80003370:	18e79e63          	bne	a5,a4,8000350c <__memset+0x214>
    80003374:	00b50323          	sb	a1,6(a0)
    80003378:	00700e93          	li	t4,7
    8000337c:	00859713          	slli	a4,a1,0x8
    80003380:	00e5e733          	or	a4,a1,a4
    80003384:	01059e13          	slli	t3,a1,0x10
    80003388:	01c76e33          	or	t3,a4,t3
    8000338c:	01859313          	slli	t1,a1,0x18
    80003390:	006e6333          	or	t1,t3,t1
    80003394:	02059893          	slli	a7,a1,0x20
    80003398:	40f60e3b          	subw	t3,a2,a5
    8000339c:	011368b3          	or	a7,t1,a7
    800033a0:	02859813          	slli	a6,a1,0x28
    800033a4:	0108e833          	or	a6,a7,a6
    800033a8:	03059693          	slli	a3,a1,0x30
    800033ac:	003e589b          	srliw	a7,t3,0x3
    800033b0:	00d866b3          	or	a3,a6,a3
    800033b4:	03859713          	slli	a4,a1,0x38
    800033b8:	00389813          	slli	a6,a7,0x3
    800033bc:	00f507b3          	add	a5,a0,a5
    800033c0:	00e6e733          	or	a4,a3,a4
    800033c4:	000e089b          	sext.w	a7,t3
    800033c8:	00f806b3          	add	a3,a6,a5
    800033cc:	00e7b023          	sd	a4,0(a5)
    800033d0:	00878793          	addi	a5,a5,8
    800033d4:	fed79ce3          	bne	a5,a3,800033cc <__memset+0xd4>
    800033d8:	ff8e7793          	andi	a5,t3,-8
    800033dc:	0007871b          	sext.w	a4,a5
    800033e0:	01d787bb          	addw	a5,a5,t4
    800033e4:	0ce88e63          	beq	a7,a4,800034c0 <__memset+0x1c8>
    800033e8:	00f50733          	add	a4,a0,a5
    800033ec:	00b70023          	sb	a1,0(a4)
    800033f0:	0017871b          	addiw	a4,a5,1
    800033f4:	0cc77663          	bgeu	a4,a2,800034c0 <__memset+0x1c8>
    800033f8:	00e50733          	add	a4,a0,a4
    800033fc:	00b70023          	sb	a1,0(a4)
    80003400:	0027871b          	addiw	a4,a5,2
    80003404:	0ac77e63          	bgeu	a4,a2,800034c0 <__memset+0x1c8>
    80003408:	00e50733          	add	a4,a0,a4
    8000340c:	00b70023          	sb	a1,0(a4)
    80003410:	0037871b          	addiw	a4,a5,3
    80003414:	0ac77663          	bgeu	a4,a2,800034c0 <__memset+0x1c8>
    80003418:	00e50733          	add	a4,a0,a4
    8000341c:	00b70023          	sb	a1,0(a4)
    80003420:	0047871b          	addiw	a4,a5,4
    80003424:	08c77e63          	bgeu	a4,a2,800034c0 <__memset+0x1c8>
    80003428:	00e50733          	add	a4,a0,a4
    8000342c:	00b70023          	sb	a1,0(a4)
    80003430:	0057871b          	addiw	a4,a5,5
    80003434:	08c77663          	bgeu	a4,a2,800034c0 <__memset+0x1c8>
    80003438:	00e50733          	add	a4,a0,a4
    8000343c:	00b70023          	sb	a1,0(a4)
    80003440:	0067871b          	addiw	a4,a5,6
    80003444:	06c77e63          	bgeu	a4,a2,800034c0 <__memset+0x1c8>
    80003448:	00e50733          	add	a4,a0,a4
    8000344c:	00b70023          	sb	a1,0(a4)
    80003450:	0077871b          	addiw	a4,a5,7
    80003454:	06c77663          	bgeu	a4,a2,800034c0 <__memset+0x1c8>
    80003458:	00e50733          	add	a4,a0,a4
    8000345c:	00b70023          	sb	a1,0(a4)
    80003460:	0087871b          	addiw	a4,a5,8
    80003464:	04c77e63          	bgeu	a4,a2,800034c0 <__memset+0x1c8>
    80003468:	00e50733          	add	a4,a0,a4
    8000346c:	00b70023          	sb	a1,0(a4)
    80003470:	0097871b          	addiw	a4,a5,9
    80003474:	04c77663          	bgeu	a4,a2,800034c0 <__memset+0x1c8>
    80003478:	00e50733          	add	a4,a0,a4
    8000347c:	00b70023          	sb	a1,0(a4)
    80003480:	00a7871b          	addiw	a4,a5,10
    80003484:	02c77e63          	bgeu	a4,a2,800034c0 <__memset+0x1c8>
    80003488:	00e50733          	add	a4,a0,a4
    8000348c:	00b70023          	sb	a1,0(a4)
    80003490:	00b7871b          	addiw	a4,a5,11
    80003494:	02c77663          	bgeu	a4,a2,800034c0 <__memset+0x1c8>
    80003498:	00e50733          	add	a4,a0,a4
    8000349c:	00b70023          	sb	a1,0(a4)
    800034a0:	00c7871b          	addiw	a4,a5,12
    800034a4:	00c77e63          	bgeu	a4,a2,800034c0 <__memset+0x1c8>
    800034a8:	00e50733          	add	a4,a0,a4
    800034ac:	00b70023          	sb	a1,0(a4)
    800034b0:	00d7879b          	addiw	a5,a5,13
    800034b4:	00c7f663          	bgeu	a5,a2,800034c0 <__memset+0x1c8>
    800034b8:	00f507b3          	add	a5,a0,a5
    800034bc:	00b78023          	sb	a1,0(a5)
    800034c0:	00813403          	ld	s0,8(sp)
    800034c4:	01010113          	addi	sp,sp,16
    800034c8:	00008067          	ret
    800034cc:	00b00693          	li	a3,11
    800034d0:	e55ff06f          	j	80003324 <__memset+0x2c>
    800034d4:	00300e93          	li	t4,3
    800034d8:	ea5ff06f          	j	8000337c <__memset+0x84>
    800034dc:	00100e93          	li	t4,1
    800034e0:	e9dff06f          	j	8000337c <__memset+0x84>
    800034e4:	00000e93          	li	t4,0
    800034e8:	e95ff06f          	j	8000337c <__memset+0x84>
    800034ec:	00000793          	li	a5,0
    800034f0:	ef9ff06f          	j	800033e8 <__memset+0xf0>
    800034f4:	00200e93          	li	t4,2
    800034f8:	e85ff06f          	j	8000337c <__memset+0x84>
    800034fc:	00400e93          	li	t4,4
    80003500:	e7dff06f          	j	8000337c <__memset+0x84>
    80003504:	00500e93          	li	t4,5
    80003508:	e75ff06f          	j	8000337c <__memset+0x84>
    8000350c:	00600e93          	li	t4,6
    80003510:	e6dff06f          	j	8000337c <__memset+0x84>

0000000080003514 <__memmove>:
    80003514:	ff010113          	addi	sp,sp,-16
    80003518:	00813423          	sd	s0,8(sp)
    8000351c:	01010413          	addi	s0,sp,16
    80003520:	0e060863          	beqz	a2,80003610 <__memmove+0xfc>
    80003524:	fff6069b          	addiw	a3,a2,-1
    80003528:	0006881b          	sext.w	a6,a3
    8000352c:	0ea5e863          	bltu	a1,a0,8000361c <__memmove+0x108>
    80003530:	00758713          	addi	a4,a1,7
    80003534:	00a5e7b3          	or	a5,a1,a0
    80003538:	40a70733          	sub	a4,a4,a0
    8000353c:	0077f793          	andi	a5,a5,7
    80003540:	00f73713          	sltiu	a4,a4,15
    80003544:	00174713          	xori	a4,a4,1
    80003548:	0017b793          	seqz	a5,a5
    8000354c:	00e7f7b3          	and	a5,a5,a4
    80003550:	10078863          	beqz	a5,80003660 <__memmove+0x14c>
    80003554:	00900793          	li	a5,9
    80003558:	1107f463          	bgeu	a5,a6,80003660 <__memmove+0x14c>
    8000355c:	0036581b          	srliw	a6,a2,0x3
    80003560:	fff8081b          	addiw	a6,a6,-1
    80003564:	02081813          	slli	a6,a6,0x20
    80003568:	01d85893          	srli	a7,a6,0x1d
    8000356c:	00858813          	addi	a6,a1,8
    80003570:	00058793          	mv	a5,a1
    80003574:	00050713          	mv	a4,a0
    80003578:	01088833          	add	a6,a7,a6
    8000357c:	0007b883          	ld	a7,0(a5)
    80003580:	00878793          	addi	a5,a5,8
    80003584:	00870713          	addi	a4,a4,8
    80003588:	ff173c23          	sd	a7,-8(a4)
    8000358c:	ff0798e3          	bne	a5,a6,8000357c <__memmove+0x68>
    80003590:	ff867713          	andi	a4,a2,-8
    80003594:	02071793          	slli	a5,a4,0x20
    80003598:	0207d793          	srli	a5,a5,0x20
    8000359c:	00f585b3          	add	a1,a1,a5
    800035a0:	40e686bb          	subw	a3,a3,a4
    800035a4:	00f507b3          	add	a5,a0,a5
    800035a8:	06e60463          	beq	a2,a4,80003610 <__memmove+0xfc>
    800035ac:	0005c703          	lbu	a4,0(a1)
    800035b0:	00e78023          	sb	a4,0(a5)
    800035b4:	04068e63          	beqz	a3,80003610 <__memmove+0xfc>
    800035b8:	0015c603          	lbu	a2,1(a1)
    800035bc:	00100713          	li	a4,1
    800035c0:	00c780a3          	sb	a2,1(a5)
    800035c4:	04e68663          	beq	a3,a4,80003610 <__memmove+0xfc>
    800035c8:	0025c603          	lbu	a2,2(a1)
    800035cc:	00200713          	li	a4,2
    800035d0:	00c78123          	sb	a2,2(a5)
    800035d4:	02e68e63          	beq	a3,a4,80003610 <__memmove+0xfc>
    800035d8:	0035c603          	lbu	a2,3(a1)
    800035dc:	00300713          	li	a4,3
    800035e0:	00c781a3          	sb	a2,3(a5)
    800035e4:	02e68663          	beq	a3,a4,80003610 <__memmove+0xfc>
    800035e8:	0045c603          	lbu	a2,4(a1)
    800035ec:	00400713          	li	a4,4
    800035f0:	00c78223          	sb	a2,4(a5)
    800035f4:	00e68e63          	beq	a3,a4,80003610 <__memmove+0xfc>
    800035f8:	0055c603          	lbu	a2,5(a1)
    800035fc:	00500713          	li	a4,5
    80003600:	00c782a3          	sb	a2,5(a5)
    80003604:	00e68663          	beq	a3,a4,80003610 <__memmove+0xfc>
    80003608:	0065c703          	lbu	a4,6(a1)
    8000360c:	00e78323          	sb	a4,6(a5)
    80003610:	00813403          	ld	s0,8(sp)
    80003614:	01010113          	addi	sp,sp,16
    80003618:	00008067          	ret
    8000361c:	02061713          	slli	a4,a2,0x20
    80003620:	02075713          	srli	a4,a4,0x20
    80003624:	00e587b3          	add	a5,a1,a4
    80003628:	f0f574e3          	bgeu	a0,a5,80003530 <__memmove+0x1c>
    8000362c:	02069613          	slli	a2,a3,0x20
    80003630:	02065613          	srli	a2,a2,0x20
    80003634:	fff64613          	not	a2,a2
    80003638:	00e50733          	add	a4,a0,a4
    8000363c:	00c78633          	add	a2,a5,a2
    80003640:	fff7c683          	lbu	a3,-1(a5)
    80003644:	fff78793          	addi	a5,a5,-1
    80003648:	fff70713          	addi	a4,a4,-1
    8000364c:	00d70023          	sb	a3,0(a4)
    80003650:	fec798e3          	bne	a5,a2,80003640 <__memmove+0x12c>
    80003654:	00813403          	ld	s0,8(sp)
    80003658:	01010113          	addi	sp,sp,16
    8000365c:	00008067          	ret
    80003660:	02069713          	slli	a4,a3,0x20
    80003664:	02075713          	srli	a4,a4,0x20
    80003668:	00170713          	addi	a4,a4,1
    8000366c:	00e50733          	add	a4,a0,a4
    80003670:	00050793          	mv	a5,a0
    80003674:	0005c683          	lbu	a3,0(a1)
    80003678:	00178793          	addi	a5,a5,1
    8000367c:	00158593          	addi	a1,a1,1
    80003680:	fed78fa3          	sb	a3,-1(a5)
    80003684:	fee798e3          	bne	a5,a4,80003674 <__memmove+0x160>
    80003688:	f89ff06f          	j	80003610 <__memmove+0xfc>
	...
