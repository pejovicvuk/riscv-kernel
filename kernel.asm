
kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00004117          	auipc	sp,0x4
    80000004:	42813103          	ld	sp,1064(sp) # 80004428 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	00001537          	lui	a0,0x1
    8000000c:	f14025f3          	csrr	a1,mhartid
    80000010:	00158593          	addi	a1,a1,1
    80000014:	02b50533          	mul	a0,a0,a1
    80000018:	00a10133          	add	sp,sp,a0
    8000001c:	390010ef          	jal	ra,800013ac <start>

0000000080000020 <spin>:
    80000020:	0000006f          	j	80000020 <spin>
	...

0000000080001000 <_Z5kputcc>:
#include "../h/print.hpp"

// Send one character to the console controller.
void kputc(char c) {
    80001000:	ff010113          	addi	sp,sp,-16
    80001004:	00813423          	sd	s0,8(sp)
    80001008:	01010413          	addi	s0,sp,16
    // CONSOLE_STATUS is an address (a constant from hw.h). To read the
    // byte living at that address, we reinterpret the integer address as
    // a pointer-to-volatile-char and dereference it. 'volatile' tells the
    // compiler the value can change outside our code (the hardware sets it),
    // so it must actually re-read memory every loop pass, not cache it.
    while ((*(volatile char*)CONSOLE_STATUS & (1 << 5)) == 0) {
    8000100c:	00003797          	auipc	a5,0x3
    80001010:	0047b783          	ld	a5,4(a5) # 80004010 <CONSOLE_STATUS>
    80001014:	0007c783          	lbu	a5,0(a5)
    80001018:	0ff7f793          	andi	a5,a5,255
    8000101c:	0207f793          	andi	a5,a5,32
    80001020:	fe0786e3          	beqz	a5,8000100c <_Z5kputcc+0xc>
        // spin: bit 5 == 0 means "not ready to accept a char to send"
    }
    // Ready. Write the byte into the transmit-data register.
    *(volatile char*)CONSOLE_TX_DATA = c;
    80001024:	00003797          	auipc	a5,0x3
    80001028:	fe47b783          	ld	a5,-28(a5) # 80004008 <CONSOLE_TX_DATA>
    8000102c:	00a78023          	sb	a0,0(a5)
}
    80001030:	00813403          	ld	s0,8(sp)
    80001034:	01010113          	addi	sp,sp,16
    80001038:	00008067          	ret

000000008000103c <_Z5kputsPKc>:

// Convenience: print a whole string by sending char by char.
void kputs(const char* s) {
    8000103c:	fe010113          	addi	sp,sp,-32
    80001040:	00113c23          	sd	ra,24(sp)
    80001044:	00813823          	sd	s0,16(sp)
    80001048:	00913423          	sd	s1,8(sp)
    8000104c:	02010413          	addi	s0,sp,32
    80001050:	00050493          	mv	s1,a0
    while (*s) kputc(*s++);
    80001054:	0004c503          	lbu	a0,0(s1)
    80001058:	00050a63          	beqz	a0,8000106c <_Z5kputsPKc+0x30>
    8000105c:	00148493          	addi	s1,s1,1
    80001060:	00000097          	auipc	ra,0x0
    80001064:	fa0080e7          	jalr	-96(ra) # 80001000 <_Z5kputcc>
    80001068:	fedff06f          	j	80001054 <_Z5kputsPKc+0x18>
}
    8000106c:	01813083          	ld	ra,24(sp)
    80001070:	01013403          	ld	s0,16(sp)
    80001074:	00813483          	ld	s1,8(sp)
    80001078:	02010113          	addi	sp,sp,32
    8000107c:	00008067          	ret

0000000080001080 <_Z7kputhexm>:
void kputhex(uint64 n) {
    80001080:	fe010113          	addi	sp,sp,-32
    80001084:	00113c23          	sd	ra,24(sp)
    80001088:	00813823          	sd	s0,16(sp)
    8000108c:	00913423          	sd	s1,8(sp)
    80001090:	01213023          	sd	s2,0(sp)
    80001094:	02010413          	addi	s0,sp,32
    80001098:	00050913          	mv	s2,a0
    kputs("0x");
    8000109c:	00003517          	auipc	a0,0x3
    800010a0:	f8450513          	addi	a0,a0,-124 # 80004020 <CONSOLE_STATUS+0x10>
    800010a4:	00000097          	auipc	ra,0x0
    800010a8:	f98080e7          	jalr	-104(ra) # 8000103c <_Z5kputsPKc>
    for (int shift = 60; shift >= 0; shift -= 4) {
    800010ac:	03c00493          	li	s1,60
    800010b0:	0140006f          	j	800010c4 <_Z7kputhexm+0x44>
        uint64 digit = (n >> shift) & 0xF;
        char c;
        if (digit < 10) {
            c = '0' + digit;
        } else {
            c = 'a' + (digit - 10);
    800010b4:	05750513          	addi	a0,a0,87
        }
        kputc(c);
    800010b8:	00000097          	auipc	ra,0x0
    800010bc:	f48080e7          	jalr	-184(ra) # 80001000 <_Z5kputcc>
    for (int shift = 60; shift >= 0; shift -= 4) {
    800010c0:	ffc4849b          	addiw	s1,s1,-4
    800010c4:	0004ce63          	bltz	s1,800010e0 <_Z7kputhexm+0x60>
        uint64 digit = (n >> shift) & 0xF;
    800010c8:	00995533          	srl	a0,s2,s1
    800010cc:	00f57513          	andi	a0,a0,15
        if (digit < 10) {
    800010d0:	00900793          	li	a5,9
    800010d4:	fea7e0e3          	bltu	a5,a0,800010b4 <_Z7kputhexm+0x34>
            c = '0' + digit;
    800010d8:	03050513          	addi	a0,a0,48
    800010dc:	fddff06f          	j	800010b8 <_Z7kputhexm+0x38>
    }
    800010e0:	01813083          	ld	ra,24(sp)
    800010e4:	01013403          	ld	s0,16(sp)
    800010e8:	00813483          	ld	s1,8(sp)
    800010ec:	00013903          	ld	s2,0(sp)
    800010f0:	02010113          	addi	sp,sp,32
    800010f4:	00008067          	ret

00000000800010f8 <_Z8userMainv>:
// src/userMain.cpp
#include "../h/MemoryAllocator.hpp"
#include "../h/print.hpp"

void userMain() {
    800010f8:	fe010113          	addi	sp,sp,-32
    800010fc:	00113c23          	sd	ra,24(sp)
    80001100:	00813823          	sd	s0,16(sp)
    80001104:	00913423          	sd	s1,8(sp)
    80001108:	02010413          	addi	s0,sp,32
    MemoryAllocator::init();
    8000110c:	00000097          	auipc	ra,0x0
    80001110:	0bc080e7          	jalr	188(ra) # 800011c8 <_ZN15MemoryAllocator4initEv>
    kputs("   user: hello from userMain\n");
    80001114:	00003517          	auipc	a0,0x3
    80001118:	f1450513          	addi	a0,a0,-236 # 80004028 <CONSOLE_STATUS+0x18>
    8000111c:	00000097          	auipc	ra,0x0
    80001120:	f20080e7          	jalr	-224(ra) # 8000103c <_Z5kputsPKc>

    MemoryAllocator::printFreeList();
    80001124:	00000097          	auipc	ra,0x0
    80001128:	198080e7          	jalr	408(ra) # 800012bc <_ZN15MemoryAllocator13printFreeListEv>

    void* p1 = MemoryAllocator::alloc(100);
    8000112c:	06400513          	li	a0,100
    80001130:	00000097          	auipc	ra,0x0
    80001134:	0e4080e7          	jalr	228(ra) # 80001214 <_ZN15MemoryAllocator5allocEm>
    80001138:	00050493          	mv	s1,a0
    kputs("   p1 = "); kputhex((uint64)p1); kputs("\n");
    8000113c:	00003517          	auipc	a0,0x3
    80001140:	f0c50513          	addi	a0,a0,-244 # 80004048 <CONSOLE_STATUS+0x38>
    80001144:	00000097          	auipc	ra,0x0
    80001148:	ef8080e7          	jalr	-264(ra) # 8000103c <_Z5kputsPKc>
    8000114c:	00048513          	mv	a0,s1
    80001150:	00000097          	auipc	ra,0x0
    80001154:	f30080e7          	jalr	-208(ra) # 80001080 <_Z7kputhexm>
    80001158:	00003517          	auipc	a0,0x3
    8000115c:	09050513          	addi	a0,a0,144 # 800041e8 <CONSOLE_STATUS+0x1d8>
    80001160:	00000097          	auipc	ra,0x0
    80001164:	edc080e7          	jalr	-292(ra) # 8000103c <_Z5kputsPKc>
    MemoryAllocator::printFreeList();
    80001168:	00000097          	auipc	ra,0x0
    8000116c:	154080e7          	jalr	340(ra) # 800012bc <_ZN15MemoryAllocator13printFreeListEv>

    void* p2 = MemoryAllocator::alloc(50);
    80001170:	03200513          	li	a0,50
    80001174:	00000097          	auipc	ra,0x0
    80001178:	0a0080e7          	jalr	160(ra) # 80001214 <_ZN15MemoryAllocator5allocEm>
    8000117c:	00050493          	mv	s1,a0
    kputs("   p2 = "); kputhex((uint64)p2); kputs("\n");
    80001180:	00003517          	auipc	a0,0x3
    80001184:	ed850513          	addi	a0,a0,-296 # 80004058 <CONSOLE_STATUS+0x48>
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	eb4080e7          	jalr	-332(ra) # 8000103c <_Z5kputsPKc>
    80001190:	00048513          	mv	a0,s1
    80001194:	00000097          	auipc	ra,0x0
    80001198:	eec080e7          	jalr	-276(ra) # 80001080 <_Z7kputhexm>
    8000119c:	00003517          	auipc	a0,0x3
    800011a0:	04c50513          	addi	a0,a0,76 # 800041e8 <CONSOLE_STATUS+0x1d8>
    800011a4:	00000097          	auipc	ra,0x0
    800011a8:	e98080e7          	jalr	-360(ra) # 8000103c <_Z5kputsPKc>
    MemoryAllocator::printFreeList();
    800011ac:	00000097          	auipc	ra,0x0
    800011b0:	110080e7          	jalr	272(ra) # 800012bc <_ZN15MemoryAllocator13printFreeListEv>



    800011b4:	01813083          	ld	ra,24(sp)
    800011b8:	01013403          	ld	s0,16(sp)
    800011bc:	00813483          	ld	s1,8(sp)
    800011c0:	02010113          	addi	sp,sp,32
    800011c4:	00008067          	ret

00000000800011c8 <_ZN15MemoryAllocator4initEv>:
#include "../h/MemoryAllocator.hpp"
#include "../lib/hw.h"
#include "../h/print.hpp"
MemoryAllocator::FreeBlock* MemoryAllocator::freeListHead = nullptr;

void MemoryAllocator::init() {
    800011c8:	ff010113          	addi	sp,sp,-16
    800011cc:	00813423          	sd	s0,8(sp)
    800011d0:	01010413          	addi	s0,sp,16
    freeListHead = (FreeBlock*)HEAP_START_ADDR;
    800011d4:	00003797          	auipc	a5,0x3
    800011d8:	24478793          	addi	a5,a5,580 # 80004418 <HEAP_START_ADDR>
    800011dc:	0007b683          	ld	a3,0(a5)
    800011e0:	00003717          	auipc	a4,0x3
    800011e4:	26070713          	addi	a4,a4,608 # 80004440 <_ZN15MemoryAllocator12freeListHeadE>
    800011e8:	00d73023          	sd	a3,0(a4)
    freeListHead->next = nullptr;
    800011ec:	0006b023          	sd	zero,0(a3)
    freeListHead->size = (char*)HEAP_END_ADDR - (char*)HEAP_START_ADDR;
    800011f0:	0007b683          	ld	a3,0(a5)
    800011f4:	00073703          	ld	a4,0(a4)
    800011f8:	00003797          	auipc	a5,0x3
    800011fc:	2187b783          	ld	a5,536(a5) # 80004410 <HEAP_END_ADDR>
    80001200:	40d787b3          	sub	a5,a5,a3
    80001204:	00f73423          	sd	a5,8(a4)
}
    80001208:	00813403          	ld	s0,8(sp)
    8000120c:	01010113          	addi	sp,sp,16
    80001210:	00008067          	ret

0000000080001214 <_ZN15MemoryAllocator5allocEm>:
void* MemoryAllocator::alloc(size_t size){
    80001214:	ff010113          	addi	sp,sp,-16
    80001218:	00813423          	sd	s0,8(sp)
    8000121c:	01010413          	addi	s0,sp,16
    if (size == 0) {
    80001220:	08050a63          	beqz	a0,800012b4 <_ZN15MemoryAllocator5allocEm+0xa0>
        return nullptr;
    }
    //rounding ((n + B - 1) / B) * B
    size_t n = size + sizeof(FreeBlock);
    size_t roundedSize = ((n + MEM_BLOCK_SIZE - 1) / MEM_BLOCK_SIZE) * MEM_BLOCK_SIZE; //velicina koju treba alocirati
    80001224:	04f50513          	addi	a0,a0,79
    80001228:	fc057713          	andi	a4,a0,-64

    FreeBlock* curr = freeListHead;
    8000122c:	00003517          	auipc	a0,0x3
    80001230:	21453503          	ld	a0,532(a0) # 80004440 <_ZN15MemoryAllocator12freeListHeadE>
    FreeBlock* prev = nullptr;
    80001234:	00000693          	li	a3,0
    while(curr != nullptr){
    80001238:	04050263          	beqz	a0,8000127c <_ZN15MemoryAllocator5allocEm+0x68>
        if(curr->size >= roundedSize){
    8000123c:	00853783          	ld	a5,8(a0)
    80001240:	00e7f863          	bgeu	a5,a4,80001250 <_ZN15MemoryAllocator5allocEm+0x3c>
                    freeListHead = curr->next;
                }
            }
            return (char*)curr + sizeof(FreeBlock);
        }
        prev = curr;
    80001244:	00050693          	mv	a3,a0
        curr = curr->next;
    80001248:	00053503          	ld	a0,0(a0)
    while(curr != nullptr){
    8000124c:	fedff06f          	j	80001238 <_ZN15MemoryAllocator5allocEm+0x24>
            size_t remainder = curr->size - roundedSize;
    80001250:	40e787b3          	sub	a5,a5,a4
            if (remainder >= MEM_BLOCK_SIZE) {
    80001254:	03f00613          	li	a2,63
    80001258:	02f67e63          	bgeu	a2,a5,80001294 <_ZN15MemoryAllocator5allocEm+0x80>
                FreeBlock* newBlock = (FreeBlock*)((char*)curr + roundedSize);
    8000125c:	00e50633          	add	a2,a0,a4
                newBlock->size = remainder;
    80001260:	00f63423          	sd	a5,8(a2)
                newBlock->next = curr->next;
    80001264:	00053783          	ld	a5,0(a0)
    80001268:	00f63023          	sd	a5,0(a2)
                if (prev != nullptr) {
    8000126c:	00068e63          	beqz	a3,80001288 <_ZN15MemoryAllocator5allocEm+0x74>
                    prev->next = newBlock;
    80001270:	00c6b023          	sd	a2,0(a3)
                curr->size = roundedSize;
    80001274:	00e53423          	sd	a4,8(a0)
            return (char*)curr + sizeof(FreeBlock);
    80001278:	01050513          	addi	a0,a0,16
    }
    return nullptr;
}
    8000127c:	00813403          	ld	s0,8(sp)
    80001280:	01010113          	addi	sp,sp,16
    80001284:	00008067          	ret
                    freeListHead = newBlock;
    80001288:	00003797          	auipc	a5,0x3
    8000128c:	1ac7bc23          	sd	a2,440(a5) # 80004440 <_ZN15MemoryAllocator12freeListHeadE>
    80001290:	fe5ff06f          	j	80001274 <_ZN15MemoryAllocator5allocEm+0x60>
                if (prev != nullptr) {
    80001294:	00068863          	beqz	a3,800012a4 <_ZN15MemoryAllocator5allocEm+0x90>
                    prev->next = curr->next;
    80001298:	00053783          	ld	a5,0(a0)
    8000129c:	00f6b023          	sd	a5,0(a3)
    800012a0:	fd9ff06f          	j	80001278 <_ZN15MemoryAllocator5allocEm+0x64>
                    freeListHead = curr->next;
    800012a4:	00053783          	ld	a5,0(a0)
    800012a8:	00003717          	auipc	a4,0x3
    800012ac:	18f73c23          	sd	a5,408(a4) # 80004440 <_ZN15MemoryAllocator12freeListHeadE>
    800012b0:	fc9ff06f          	j	80001278 <_ZN15MemoryAllocator5allocEm+0x64>
        return nullptr;
    800012b4:	00000513          	li	a0,0
    800012b8:	fc5ff06f          	j	8000127c <_ZN15MemoryAllocator5allocEm+0x68>

00000000800012bc <_ZN15MemoryAllocator13printFreeListEv>:
void MemoryAllocator::printFreeList() {
    800012bc:	fe010113          	addi	sp,sp,-32
    800012c0:	00113c23          	sd	ra,24(sp)
    800012c4:	00813823          	sd	s0,16(sp)
    800012c8:	00913423          	sd	s1,8(sp)
    800012cc:	02010413          	addi	s0,sp,32
    FreeBlock* curr = freeListHead;
    800012d0:	00003497          	auipc	s1,0x3
    800012d4:	1704b483          	ld	s1,368(s1) # 80004440 <_ZN15MemoryAllocator12freeListHeadE>
    kputs("Free list:\n");
    800012d8:	00003517          	auipc	a0,0x3
    800012dc:	d9050513          	addi	a0,a0,-624 # 80004068 <CONSOLE_STATUS+0x58>
    800012e0:	00000097          	auipc	ra,0x0
    800012e4:	d5c080e7          	jalr	-676(ra) # 8000103c <_Z5kputsPKc>
    while (curr != nullptr) {
    800012e8:	04048a63          	beqz	s1,8000133c <_ZN15MemoryAllocator13printFreeListEv+0x80>
        kputs("  Block at ");
    800012ec:	00003517          	auipc	a0,0x3
    800012f0:	d8c50513          	addi	a0,a0,-628 # 80004078 <CONSOLE_STATUS+0x68>
    800012f4:	00000097          	auipc	ra,0x0
    800012f8:	d48080e7          	jalr	-696(ra) # 8000103c <_Z5kputsPKc>
        kputhex((uint64)curr);
    800012fc:	00048513          	mv	a0,s1
    80001300:	00000097          	auipc	ra,0x0
    80001304:	d80080e7          	jalr	-640(ra) # 80001080 <_Z7kputhexm>
        kputs(", size: ");
    80001308:	00003517          	auipc	a0,0x3
    8000130c:	d8050513          	addi	a0,a0,-640 # 80004088 <CONSOLE_STATUS+0x78>
    80001310:	00000097          	auipc	ra,0x0
    80001314:	d2c080e7          	jalr	-724(ra) # 8000103c <_Z5kputsPKc>
        kputhex(curr->size);
    80001318:	0084b503          	ld	a0,8(s1)
    8000131c:	00000097          	auipc	ra,0x0
    80001320:	d64080e7          	jalr	-668(ra) # 80001080 <_Z7kputhexm>
        kputs("\n");
    80001324:	00003517          	auipc	a0,0x3
    80001328:	ec450513          	addi	a0,a0,-316 # 800041e8 <CONSOLE_STATUS+0x1d8>
    8000132c:	00000097          	auipc	ra,0x0
    80001330:	d10080e7          	jalr	-752(ra) # 8000103c <_Z5kputsPKc>
        curr = curr->next;
    80001334:	0004b483          	ld	s1,0(s1)
    while (curr != nullptr) {
    80001338:	fb1ff06f          	j	800012e8 <_ZN15MemoryAllocator13printFreeListEv+0x2c>
    }
    8000133c:	01813083          	ld	ra,24(sp)
    80001340:	01013403          	ld	s0,16(sp)
    80001344:	00813483          	ld	s1,8(sp)
    80001348:	02010113          	addi	sp,sp,32
    8000134c:	00008067          	ret

0000000080001350 <main>:
#include "../h/print.hpp"

void userMain();   // forward declaration: defined elsewhere (your test file)

int main() {
    80001350:	ff010113          	addi	sp,sp,-16
    80001354:	00113423          	sd	ra,8(sp)
    80001358:	00813023          	sd	s0,0(sp)
    8000135c:	01010413          	addi	s0,sp,16
    kputs(">> kernel: starting\n");
    80001360:	00003517          	auipc	a0,0x3
    80001364:	d3850513          	addi	a0,a0,-712 # 80004098 <CONSOLE_STATUS+0x88>
    80001368:	00000097          	auipc	ra,0x0
    8000136c:	cd4080e7          	jalr	-812(ra) # 8000103c <_Z5kputsPKc>

    userMain();    // THE CHEAT: calling it as a plain function for now.
    80001370:	00000097          	auipc	ra,0x0
    80001374:	d88080e7          	jalr	-632(ra) # 800010f8 <_Z8userMainv>
                   // In the real kernel this becomes "wrap userMain as the
                   // body of the first thread and let the scheduler run it."

    kputs(">> kernel: userMain returned, halting\n");
    80001378:	00003517          	auipc	a0,0x3
    8000137c:	d3850513          	addi	a0,a0,-712 # 800040b0 <CONSOLE_STATUS+0xa0>
    80001380:	00000097          	auipc	ra,0x0
    80001384:	cbc080e7          	jalr	-836(ra) # 8000103c <_Z5kputsPKc>

    // Halt the emulator: writing the 32-bit value 0x5555 to physical
    // address 0x100000 is qemu's "guest asked to power off" signal, so
    // `make qemu` returns to your shell instead of hanging.
    *(volatile int*)0x100000 = 0x5555;
    80001388:	00100737          	lui	a4,0x100
    8000138c:	000057b7          	lui	a5,0x5
    80001390:	5557879b          	addiw	a5,a5,1365
    80001394:	00f72023          	sw	a5,0(a4) # 100000 <_entry-0x7ff00000>

    return 0;   // never really reached, but keeps the signature honest
    80001398:	00000513          	li	a0,0
    8000139c:	00813083          	ld	ra,8(sp)
    800013a0:	00013403          	ld	s0,0(sp)
    800013a4:	01010113          	addi	sp,sp,16
    800013a8:	00008067          	ret

00000000800013ac <start>:
    800013ac:	ff010113          	addi	sp,sp,-16
    800013b0:	00813423          	sd	s0,8(sp)
    800013b4:	01010413          	addi	s0,sp,16
    800013b8:	300027f3          	csrr	a5,mstatus
    800013bc:	ffffe737          	lui	a4,0xffffe
    800013c0:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fff913f>
    800013c4:	00e7f7b3          	and	a5,a5,a4
    800013c8:	00001737          	lui	a4,0x1
    800013cc:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800013d0:	00e7e7b3          	or	a5,a5,a4
    800013d4:	30079073          	csrw	mstatus,a5
    800013d8:	00000797          	auipc	a5,0x0
    800013dc:	16078793          	addi	a5,a5,352 # 80001538 <system_main>
    800013e0:	34179073          	csrw	mepc,a5
    800013e4:	00000793          	li	a5,0
    800013e8:	18079073          	csrw	satp,a5
    800013ec:	000107b7          	lui	a5,0x10
    800013f0:	fff78793          	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800013f4:	30279073          	csrw	medeleg,a5
    800013f8:	30379073          	csrw	mideleg,a5
    800013fc:	104027f3          	csrr	a5,sie
    80001400:	2227e793          	ori	a5,a5,546
    80001404:	10479073          	csrw	sie,a5
    80001408:	fff00793          	li	a5,-1
    8000140c:	00a7d793          	srli	a5,a5,0xa
    80001410:	3b079073          	csrw	pmpaddr0,a5
    80001414:	00f00793          	li	a5,15
    80001418:	3a079073          	csrw	pmpcfg0,a5
    8000141c:	f14027f3          	csrr	a5,mhartid
    80001420:	0200c737          	lui	a4,0x200c
    80001424:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80001428:	0007869b          	sext.w	a3,a5
    8000142c:	00269713          	slli	a4,a3,0x2
    80001430:	000f4637          	lui	a2,0xf4
    80001434:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80001438:	00d70733          	add	a4,a4,a3
    8000143c:	0037979b          	slliw	a5,a5,0x3
    80001440:	020046b7          	lui	a3,0x2004
    80001444:	00d787b3          	add	a5,a5,a3
    80001448:	00c585b3          	add	a1,a1,a2
    8000144c:	00371693          	slli	a3,a4,0x3
    80001450:	00003717          	auipc	a4,0x3
    80001454:	02070713          	addi	a4,a4,32 # 80004470 <timer_scratch>
    80001458:	00b7b023          	sd	a1,0(a5)
    8000145c:	00d70733          	add	a4,a4,a3
    80001460:	00f73c23          	sd	a5,24(a4)
    80001464:	02c73023          	sd	a2,32(a4)
    80001468:	34071073          	csrw	mscratch,a4
    8000146c:	00000797          	auipc	a5,0x0
    80001470:	6e478793          	addi	a5,a5,1764 # 80001b50 <timervec>
    80001474:	30579073          	csrw	mtvec,a5
    80001478:	300027f3          	csrr	a5,mstatus
    8000147c:	0087e793          	ori	a5,a5,8
    80001480:	30079073          	csrw	mstatus,a5
    80001484:	304027f3          	csrr	a5,mie
    80001488:	0807e793          	ori	a5,a5,128
    8000148c:	30479073          	csrw	mie,a5
    80001490:	f14027f3          	csrr	a5,mhartid
    80001494:	0007879b          	sext.w	a5,a5
    80001498:	00078213          	mv	tp,a5
    8000149c:	30200073          	mret
    800014a0:	00813403          	ld	s0,8(sp)
    800014a4:	01010113          	addi	sp,sp,16
    800014a8:	00008067          	ret

00000000800014ac <timerinit>:
    800014ac:	ff010113          	addi	sp,sp,-16
    800014b0:	00813423          	sd	s0,8(sp)
    800014b4:	01010413          	addi	s0,sp,16
    800014b8:	f14027f3          	csrr	a5,mhartid
    800014bc:	0200c737          	lui	a4,0x200c
    800014c0:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    800014c4:	0007869b          	sext.w	a3,a5
    800014c8:	00269713          	slli	a4,a3,0x2
    800014cc:	000f4637          	lui	a2,0xf4
    800014d0:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    800014d4:	00d70733          	add	a4,a4,a3
    800014d8:	0037979b          	slliw	a5,a5,0x3
    800014dc:	020046b7          	lui	a3,0x2004
    800014e0:	00d787b3          	add	a5,a5,a3
    800014e4:	00c585b3          	add	a1,a1,a2
    800014e8:	00371693          	slli	a3,a4,0x3
    800014ec:	00003717          	auipc	a4,0x3
    800014f0:	f8470713          	addi	a4,a4,-124 # 80004470 <timer_scratch>
    800014f4:	00b7b023          	sd	a1,0(a5)
    800014f8:	00d70733          	add	a4,a4,a3
    800014fc:	00f73c23          	sd	a5,24(a4)
    80001500:	02c73023          	sd	a2,32(a4)
    80001504:	34071073          	csrw	mscratch,a4
    80001508:	00000797          	auipc	a5,0x0
    8000150c:	64878793          	addi	a5,a5,1608 # 80001b50 <timervec>
    80001510:	30579073          	csrw	mtvec,a5
    80001514:	300027f3          	csrr	a5,mstatus
    80001518:	0087e793          	ori	a5,a5,8
    8000151c:	30079073          	csrw	mstatus,a5
    80001520:	304027f3          	csrr	a5,mie
    80001524:	0807e793          	ori	a5,a5,128
    80001528:	30479073          	csrw	mie,a5
    8000152c:	00813403          	ld	s0,8(sp)
    80001530:	01010113          	addi	sp,sp,16
    80001534:	00008067          	ret

0000000080001538 <system_main>:
    80001538:	fe010113          	addi	sp,sp,-32
    8000153c:	00813823          	sd	s0,16(sp)
    80001540:	00913423          	sd	s1,8(sp)
    80001544:	00113c23          	sd	ra,24(sp)
    80001548:	02010413          	addi	s0,sp,32
    8000154c:	00000097          	auipc	ra,0x0
    80001550:	0c4080e7          	jalr	196(ra) # 80001610 <cpuid>
    80001554:	00003497          	auipc	s1,0x3
    80001558:	ef448493          	addi	s1,s1,-268 # 80004448 <started>
    8000155c:	02050263          	beqz	a0,80001580 <system_main+0x48>
    80001560:	0004a783          	lw	a5,0(s1)
    80001564:	0007879b          	sext.w	a5,a5
    80001568:	fe078ce3          	beqz	a5,80001560 <system_main+0x28>
    8000156c:	0ff0000f          	fence
    80001570:	00003517          	auipc	a0,0x3
    80001574:	b9850513          	addi	a0,a0,-1128 # 80004108 <CONSOLE_STATUS+0xf8>
    80001578:	00001097          	auipc	ra,0x1
    8000157c:	a74080e7          	jalr	-1420(ra) # 80001fec <panic>
    80001580:	00001097          	auipc	ra,0x1
    80001584:	9c8080e7          	jalr	-1592(ra) # 80001f48 <consoleinit>
    80001588:	00001097          	auipc	ra,0x1
    8000158c:	154080e7          	jalr	340(ra) # 800026dc <printfinit>
    80001590:	00003517          	auipc	a0,0x3
    80001594:	c5850513          	addi	a0,a0,-936 # 800041e8 <CONSOLE_STATUS+0x1d8>
    80001598:	00001097          	auipc	ra,0x1
    8000159c:	ab0080e7          	jalr	-1360(ra) # 80002048 <__printf>
    800015a0:	00003517          	auipc	a0,0x3
    800015a4:	b3850513          	addi	a0,a0,-1224 # 800040d8 <CONSOLE_STATUS+0xc8>
    800015a8:	00001097          	auipc	ra,0x1
    800015ac:	aa0080e7          	jalr	-1376(ra) # 80002048 <__printf>
    800015b0:	00003517          	auipc	a0,0x3
    800015b4:	c3850513          	addi	a0,a0,-968 # 800041e8 <CONSOLE_STATUS+0x1d8>
    800015b8:	00001097          	auipc	ra,0x1
    800015bc:	a90080e7          	jalr	-1392(ra) # 80002048 <__printf>
    800015c0:	00001097          	auipc	ra,0x1
    800015c4:	4a8080e7          	jalr	1192(ra) # 80002a68 <kinit>
    800015c8:	00000097          	auipc	ra,0x0
    800015cc:	148080e7          	jalr	328(ra) # 80001710 <trapinit>
    800015d0:	00000097          	auipc	ra,0x0
    800015d4:	16c080e7          	jalr	364(ra) # 8000173c <trapinithart>
    800015d8:	00000097          	auipc	ra,0x0
    800015dc:	5b8080e7          	jalr	1464(ra) # 80001b90 <plicinit>
    800015e0:	00000097          	auipc	ra,0x0
    800015e4:	5d8080e7          	jalr	1496(ra) # 80001bb8 <plicinithart>
    800015e8:	00000097          	auipc	ra,0x0
    800015ec:	078080e7          	jalr	120(ra) # 80001660 <userinit>
    800015f0:	0ff0000f          	fence
    800015f4:	00100793          	li	a5,1
    800015f8:	00003517          	auipc	a0,0x3
    800015fc:	af850513          	addi	a0,a0,-1288 # 800040f0 <CONSOLE_STATUS+0xe0>
    80001600:	00f4a023          	sw	a5,0(s1)
    80001604:	00001097          	auipc	ra,0x1
    80001608:	a44080e7          	jalr	-1468(ra) # 80002048 <__printf>
    8000160c:	0000006f          	j	8000160c <system_main+0xd4>

0000000080001610 <cpuid>:
    80001610:	ff010113          	addi	sp,sp,-16
    80001614:	00813423          	sd	s0,8(sp)
    80001618:	01010413          	addi	s0,sp,16
    8000161c:	00020513          	mv	a0,tp
    80001620:	00813403          	ld	s0,8(sp)
    80001624:	0005051b          	sext.w	a0,a0
    80001628:	01010113          	addi	sp,sp,16
    8000162c:	00008067          	ret

0000000080001630 <mycpu>:
    80001630:	ff010113          	addi	sp,sp,-16
    80001634:	00813423          	sd	s0,8(sp)
    80001638:	01010413          	addi	s0,sp,16
    8000163c:	00020793          	mv	a5,tp
    80001640:	00813403          	ld	s0,8(sp)
    80001644:	0007879b          	sext.w	a5,a5
    80001648:	00779793          	slli	a5,a5,0x7
    8000164c:	00004517          	auipc	a0,0x4
    80001650:	e5450513          	addi	a0,a0,-428 # 800054a0 <cpus>
    80001654:	00f50533          	add	a0,a0,a5
    80001658:	01010113          	addi	sp,sp,16
    8000165c:	00008067          	ret

0000000080001660 <userinit>:
    80001660:	ff010113          	addi	sp,sp,-16
    80001664:	00813423          	sd	s0,8(sp)
    80001668:	01010413          	addi	s0,sp,16
    8000166c:	00813403          	ld	s0,8(sp)
    80001670:	01010113          	addi	sp,sp,16
    80001674:	00000317          	auipc	t1,0x0
    80001678:	cdc30067          	jr	-804(t1) # 80001350 <main>

000000008000167c <either_copyout>:
    8000167c:	ff010113          	addi	sp,sp,-16
    80001680:	00813023          	sd	s0,0(sp)
    80001684:	00113423          	sd	ra,8(sp)
    80001688:	01010413          	addi	s0,sp,16
    8000168c:	02051663          	bnez	a0,800016b8 <either_copyout+0x3c>
    80001690:	00058513          	mv	a0,a1
    80001694:	00060593          	mv	a1,a2
    80001698:	0006861b          	sext.w	a2,a3
    8000169c:	00002097          	auipc	ra,0x2
    800016a0:	c58080e7          	jalr	-936(ra) # 800032f4 <__memmove>
    800016a4:	00813083          	ld	ra,8(sp)
    800016a8:	00013403          	ld	s0,0(sp)
    800016ac:	00000513          	li	a0,0
    800016b0:	01010113          	addi	sp,sp,16
    800016b4:	00008067          	ret
    800016b8:	00003517          	auipc	a0,0x3
    800016bc:	a7850513          	addi	a0,a0,-1416 # 80004130 <CONSOLE_STATUS+0x120>
    800016c0:	00001097          	auipc	ra,0x1
    800016c4:	92c080e7          	jalr	-1748(ra) # 80001fec <panic>

00000000800016c8 <either_copyin>:
    800016c8:	ff010113          	addi	sp,sp,-16
    800016cc:	00813023          	sd	s0,0(sp)
    800016d0:	00113423          	sd	ra,8(sp)
    800016d4:	01010413          	addi	s0,sp,16
    800016d8:	02059463          	bnez	a1,80001700 <either_copyin+0x38>
    800016dc:	00060593          	mv	a1,a2
    800016e0:	0006861b          	sext.w	a2,a3
    800016e4:	00002097          	auipc	ra,0x2
    800016e8:	c10080e7          	jalr	-1008(ra) # 800032f4 <__memmove>
    800016ec:	00813083          	ld	ra,8(sp)
    800016f0:	00013403          	ld	s0,0(sp)
    800016f4:	00000513          	li	a0,0
    800016f8:	01010113          	addi	sp,sp,16
    800016fc:	00008067          	ret
    80001700:	00003517          	auipc	a0,0x3
    80001704:	a5850513          	addi	a0,a0,-1448 # 80004158 <CONSOLE_STATUS+0x148>
    80001708:	00001097          	auipc	ra,0x1
    8000170c:	8e4080e7          	jalr	-1820(ra) # 80001fec <panic>

0000000080001710 <trapinit>:
    80001710:	ff010113          	addi	sp,sp,-16
    80001714:	00813423          	sd	s0,8(sp)
    80001718:	01010413          	addi	s0,sp,16
    8000171c:	00813403          	ld	s0,8(sp)
    80001720:	00003597          	auipc	a1,0x3
    80001724:	a6058593          	addi	a1,a1,-1440 # 80004180 <CONSOLE_STATUS+0x170>
    80001728:	00004517          	auipc	a0,0x4
    8000172c:	df850513          	addi	a0,a0,-520 # 80005520 <tickslock>
    80001730:	01010113          	addi	sp,sp,16
    80001734:	00001317          	auipc	t1,0x1
    80001738:	5c430067          	jr	1476(t1) # 80002cf8 <initlock>

000000008000173c <trapinithart>:
    8000173c:	ff010113          	addi	sp,sp,-16
    80001740:	00813423          	sd	s0,8(sp)
    80001744:	01010413          	addi	s0,sp,16
    80001748:	00000797          	auipc	a5,0x0
    8000174c:	2f878793          	addi	a5,a5,760 # 80001a40 <kernelvec>
    80001750:	10579073          	csrw	stvec,a5
    80001754:	00813403          	ld	s0,8(sp)
    80001758:	01010113          	addi	sp,sp,16
    8000175c:	00008067          	ret

0000000080001760 <usertrap>:
    80001760:	ff010113          	addi	sp,sp,-16
    80001764:	00813423          	sd	s0,8(sp)
    80001768:	01010413          	addi	s0,sp,16
    8000176c:	00813403          	ld	s0,8(sp)
    80001770:	01010113          	addi	sp,sp,16
    80001774:	00008067          	ret

0000000080001778 <usertrapret>:
    80001778:	ff010113          	addi	sp,sp,-16
    8000177c:	00813423          	sd	s0,8(sp)
    80001780:	01010413          	addi	s0,sp,16
    80001784:	00813403          	ld	s0,8(sp)
    80001788:	01010113          	addi	sp,sp,16
    8000178c:	00008067          	ret

0000000080001790 <kerneltrap>:
    80001790:	fe010113          	addi	sp,sp,-32
    80001794:	00813823          	sd	s0,16(sp)
    80001798:	00113c23          	sd	ra,24(sp)
    8000179c:	00913423          	sd	s1,8(sp)
    800017a0:	02010413          	addi	s0,sp,32
    800017a4:	142025f3          	csrr	a1,scause
    800017a8:	100027f3          	csrr	a5,sstatus
    800017ac:	0027f793          	andi	a5,a5,2
    800017b0:	10079c63          	bnez	a5,800018c8 <kerneltrap+0x138>
    800017b4:	142027f3          	csrr	a5,scause
    800017b8:	0207ce63          	bltz	a5,800017f4 <kerneltrap+0x64>
    800017bc:	00003517          	auipc	a0,0x3
    800017c0:	a0c50513          	addi	a0,a0,-1524 # 800041c8 <CONSOLE_STATUS+0x1b8>
    800017c4:	00001097          	auipc	ra,0x1
    800017c8:	884080e7          	jalr	-1916(ra) # 80002048 <__printf>
    800017cc:	141025f3          	csrr	a1,sepc
    800017d0:	14302673          	csrr	a2,stval
    800017d4:	00003517          	auipc	a0,0x3
    800017d8:	a0450513          	addi	a0,a0,-1532 # 800041d8 <CONSOLE_STATUS+0x1c8>
    800017dc:	00001097          	auipc	ra,0x1
    800017e0:	86c080e7          	jalr	-1940(ra) # 80002048 <__printf>
    800017e4:	00003517          	auipc	a0,0x3
    800017e8:	a0c50513          	addi	a0,a0,-1524 # 800041f0 <CONSOLE_STATUS+0x1e0>
    800017ec:	00001097          	auipc	ra,0x1
    800017f0:	800080e7          	jalr	-2048(ra) # 80001fec <panic>
    800017f4:	0ff7f713          	andi	a4,a5,255
    800017f8:	00900693          	li	a3,9
    800017fc:	04d70063          	beq	a4,a3,8000183c <kerneltrap+0xac>
    80001800:	fff00713          	li	a4,-1
    80001804:	03f71713          	slli	a4,a4,0x3f
    80001808:	00170713          	addi	a4,a4,1
    8000180c:	fae798e3          	bne	a5,a4,800017bc <kerneltrap+0x2c>
    80001810:	00000097          	auipc	ra,0x0
    80001814:	e00080e7          	jalr	-512(ra) # 80001610 <cpuid>
    80001818:	06050663          	beqz	a0,80001884 <kerneltrap+0xf4>
    8000181c:	144027f3          	csrr	a5,sip
    80001820:	ffd7f793          	andi	a5,a5,-3
    80001824:	14479073          	csrw	sip,a5
    80001828:	01813083          	ld	ra,24(sp)
    8000182c:	01013403          	ld	s0,16(sp)
    80001830:	00813483          	ld	s1,8(sp)
    80001834:	02010113          	addi	sp,sp,32
    80001838:	00008067          	ret
    8000183c:	00000097          	auipc	ra,0x0
    80001840:	3c8080e7          	jalr	968(ra) # 80001c04 <plic_claim>
    80001844:	00a00793          	li	a5,10
    80001848:	00050493          	mv	s1,a0
    8000184c:	06f50863          	beq	a0,a5,800018bc <kerneltrap+0x12c>
    80001850:	fc050ce3          	beqz	a0,80001828 <kerneltrap+0x98>
    80001854:	00050593          	mv	a1,a0
    80001858:	00003517          	auipc	a0,0x3
    8000185c:	95050513          	addi	a0,a0,-1712 # 800041a8 <CONSOLE_STATUS+0x198>
    80001860:	00000097          	auipc	ra,0x0
    80001864:	7e8080e7          	jalr	2024(ra) # 80002048 <__printf>
    80001868:	01013403          	ld	s0,16(sp)
    8000186c:	01813083          	ld	ra,24(sp)
    80001870:	00048513          	mv	a0,s1
    80001874:	00813483          	ld	s1,8(sp)
    80001878:	02010113          	addi	sp,sp,32
    8000187c:	00000317          	auipc	t1,0x0
    80001880:	3c030067          	jr	960(t1) # 80001c3c <plic_complete>
    80001884:	00004517          	auipc	a0,0x4
    80001888:	c9c50513          	addi	a0,a0,-868 # 80005520 <tickslock>
    8000188c:	00001097          	auipc	ra,0x1
    80001890:	490080e7          	jalr	1168(ra) # 80002d1c <acquire>
    80001894:	00003717          	auipc	a4,0x3
    80001898:	bb870713          	addi	a4,a4,-1096 # 8000444c <ticks>
    8000189c:	00072783          	lw	a5,0(a4)
    800018a0:	00004517          	auipc	a0,0x4
    800018a4:	c8050513          	addi	a0,a0,-896 # 80005520 <tickslock>
    800018a8:	0017879b          	addiw	a5,a5,1
    800018ac:	00f72023          	sw	a5,0(a4)
    800018b0:	00001097          	auipc	ra,0x1
    800018b4:	538080e7          	jalr	1336(ra) # 80002de8 <release>
    800018b8:	f65ff06f          	j	8000181c <kerneltrap+0x8c>
    800018bc:	00001097          	auipc	ra,0x1
    800018c0:	094080e7          	jalr	148(ra) # 80002950 <uartintr>
    800018c4:	fa5ff06f          	j	80001868 <kerneltrap+0xd8>
    800018c8:	00003517          	auipc	a0,0x3
    800018cc:	8c050513          	addi	a0,a0,-1856 # 80004188 <CONSOLE_STATUS+0x178>
    800018d0:	00000097          	auipc	ra,0x0
    800018d4:	71c080e7          	jalr	1820(ra) # 80001fec <panic>

00000000800018d8 <clockintr>:
    800018d8:	fe010113          	addi	sp,sp,-32
    800018dc:	00813823          	sd	s0,16(sp)
    800018e0:	00913423          	sd	s1,8(sp)
    800018e4:	00113c23          	sd	ra,24(sp)
    800018e8:	02010413          	addi	s0,sp,32
    800018ec:	00004497          	auipc	s1,0x4
    800018f0:	c3448493          	addi	s1,s1,-972 # 80005520 <tickslock>
    800018f4:	00048513          	mv	a0,s1
    800018f8:	00001097          	auipc	ra,0x1
    800018fc:	424080e7          	jalr	1060(ra) # 80002d1c <acquire>
    80001900:	00003717          	auipc	a4,0x3
    80001904:	b4c70713          	addi	a4,a4,-1204 # 8000444c <ticks>
    80001908:	00072783          	lw	a5,0(a4)
    8000190c:	01013403          	ld	s0,16(sp)
    80001910:	01813083          	ld	ra,24(sp)
    80001914:	00048513          	mv	a0,s1
    80001918:	0017879b          	addiw	a5,a5,1
    8000191c:	00813483          	ld	s1,8(sp)
    80001920:	00f72023          	sw	a5,0(a4)
    80001924:	02010113          	addi	sp,sp,32
    80001928:	00001317          	auipc	t1,0x1
    8000192c:	4c030067          	jr	1216(t1) # 80002de8 <release>

0000000080001930 <devintr>:
    80001930:	142027f3          	csrr	a5,scause
    80001934:	00000513          	li	a0,0
    80001938:	0007c463          	bltz	a5,80001940 <devintr+0x10>
    8000193c:	00008067          	ret
    80001940:	fe010113          	addi	sp,sp,-32
    80001944:	00813823          	sd	s0,16(sp)
    80001948:	00113c23          	sd	ra,24(sp)
    8000194c:	00913423          	sd	s1,8(sp)
    80001950:	02010413          	addi	s0,sp,32
    80001954:	0ff7f713          	andi	a4,a5,255
    80001958:	00900693          	li	a3,9
    8000195c:	04d70c63          	beq	a4,a3,800019b4 <devintr+0x84>
    80001960:	fff00713          	li	a4,-1
    80001964:	03f71713          	slli	a4,a4,0x3f
    80001968:	00170713          	addi	a4,a4,1
    8000196c:	00e78c63          	beq	a5,a4,80001984 <devintr+0x54>
    80001970:	01813083          	ld	ra,24(sp)
    80001974:	01013403          	ld	s0,16(sp)
    80001978:	00813483          	ld	s1,8(sp)
    8000197c:	02010113          	addi	sp,sp,32
    80001980:	00008067          	ret
    80001984:	00000097          	auipc	ra,0x0
    80001988:	c8c080e7          	jalr	-884(ra) # 80001610 <cpuid>
    8000198c:	06050663          	beqz	a0,800019f8 <devintr+0xc8>
    80001990:	144027f3          	csrr	a5,sip
    80001994:	ffd7f793          	andi	a5,a5,-3
    80001998:	14479073          	csrw	sip,a5
    8000199c:	01813083          	ld	ra,24(sp)
    800019a0:	01013403          	ld	s0,16(sp)
    800019a4:	00813483          	ld	s1,8(sp)
    800019a8:	00200513          	li	a0,2
    800019ac:	02010113          	addi	sp,sp,32
    800019b0:	00008067          	ret
    800019b4:	00000097          	auipc	ra,0x0
    800019b8:	250080e7          	jalr	592(ra) # 80001c04 <plic_claim>
    800019bc:	00a00793          	li	a5,10
    800019c0:	00050493          	mv	s1,a0
    800019c4:	06f50663          	beq	a0,a5,80001a30 <devintr+0x100>
    800019c8:	00100513          	li	a0,1
    800019cc:	fa0482e3          	beqz	s1,80001970 <devintr+0x40>
    800019d0:	00048593          	mv	a1,s1
    800019d4:	00002517          	auipc	a0,0x2
    800019d8:	7d450513          	addi	a0,a0,2004 # 800041a8 <CONSOLE_STATUS+0x198>
    800019dc:	00000097          	auipc	ra,0x0
    800019e0:	66c080e7          	jalr	1644(ra) # 80002048 <__printf>
    800019e4:	00048513          	mv	a0,s1
    800019e8:	00000097          	auipc	ra,0x0
    800019ec:	254080e7          	jalr	596(ra) # 80001c3c <plic_complete>
    800019f0:	00100513          	li	a0,1
    800019f4:	f7dff06f          	j	80001970 <devintr+0x40>
    800019f8:	00004517          	auipc	a0,0x4
    800019fc:	b2850513          	addi	a0,a0,-1240 # 80005520 <tickslock>
    80001a00:	00001097          	auipc	ra,0x1
    80001a04:	31c080e7          	jalr	796(ra) # 80002d1c <acquire>
    80001a08:	00003717          	auipc	a4,0x3
    80001a0c:	a4470713          	addi	a4,a4,-1468 # 8000444c <ticks>
    80001a10:	00072783          	lw	a5,0(a4)
    80001a14:	00004517          	auipc	a0,0x4
    80001a18:	b0c50513          	addi	a0,a0,-1268 # 80005520 <tickslock>
    80001a1c:	0017879b          	addiw	a5,a5,1
    80001a20:	00f72023          	sw	a5,0(a4)
    80001a24:	00001097          	auipc	ra,0x1
    80001a28:	3c4080e7          	jalr	964(ra) # 80002de8 <release>
    80001a2c:	f65ff06f          	j	80001990 <devintr+0x60>
    80001a30:	00001097          	auipc	ra,0x1
    80001a34:	f20080e7          	jalr	-224(ra) # 80002950 <uartintr>
    80001a38:	fadff06f          	j	800019e4 <devintr+0xb4>
    80001a3c:	0000                	unimp
	...

0000000080001a40 <kernelvec>:
    80001a40:	f0010113          	addi	sp,sp,-256
    80001a44:	00113023          	sd	ra,0(sp)
    80001a48:	00213423          	sd	sp,8(sp)
    80001a4c:	00313823          	sd	gp,16(sp)
    80001a50:	00413c23          	sd	tp,24(sp)
    80001a54:	02513023          	sd	t0,32(sp)
    80001a58:	02613423          	sd	t1,40(sp)
    80001a5c:	02713823          	sd	t2,48(sp)
    80001a60:	02813c23          	sd	s0,56(sp)
    80001a64:	04913023          	sd	s1,64(sp)
    80001a68:	04a13423          	sd	a0,72(sp)
    80001a6c:	04b13823          	sd	a1,80(sp)
    80001a70:	04c13c23          	sd	a2,88(sp)
    80001a74:	06d13023          	sd	a3,96(sp)
    80001a78:	06e13423          	sd	a4,104(sp)
    80001a7c:	06f13823          	sd	a5,112(sp)
    80001a80:	07013c23          	sd	a6,120(sp)
    80001a84:	09113023          	sd	a7,128(sp)
    80001a88:	09213423          	sd	s2,136(sp)
    80001a8c:	09313823          	sd	s3,144(sp)
    80001a90:	09413c23          	sd	s4,152(sp)
    80001a94:	0b513023          	sd	s5,160(sp)
    80001a98:	0b613423          	sd	s6,168(sp)
    80001a9c:	0b713823          	sd	s7,176(sp)
    80001aa0:	0b813c23          	sd	s8,184(sp)
    80001aa4:	0d913023          	sd	s9,192(sp)
    80001aa8:	0da13423          	sd	s10,200(sp)
    80001aac:	0db13823          	sd	s11,208(sp)
    80001ab0:	0dc13c23          	sd	t3,216(sp)
    80001ab4:	0fd13023          	sd	t4,224(sp)
    80001ab8:	0fe13423          	sd	t5,232(sp)
    80001abc:	0ff13823          	sd	t6,240(sp)
    80001ac0:	cd1ff0ef          	jal	ra,80001790 <kerneltrap>
    80001ac4:	00013083          	ld	ra,0(sp)
    80001ac8:	00813103          	ld	sp,8(sp)
    80001acc:	01013183          	ld	gp,16(sp)
    80001ad0:	02013283          	ld	t0,32(sp)
    80001ad4:	02813303          	ld	t1,40(sp)
    80001ad8:	03013383          	ld	t2,48(sp)
    80001adc:	03813403          	ld	s0,56(sp)
    80001ae0:	04013483          	ld	s1,64(sp)
    80001ae4:	04813503          	ld	a0,72(sp)
    80001ae8:	05013583          	ld	a1,80(sp)
    80001aec:	05813603          	ld	a2,88(sp)
    80001af0:	06013683          	ld	a3,96(sp)
    80001af4:	06813703          	ld	a4,104(sp)
    80001af8:	07013783          	ld	a5,112(sp)
    80001afc:	07813803          	ld	a6,120(sp)
    80001b00:	08013883          	ld	a7,128(sp)
    80001b04:	08813903          	ld	s2,136(sp)
    80001b08:	09013983          	ld	s3,144(sp)
    80001b0c:	09813a03          	ld	s4,152(sp)
    80001b10:	0a013a83          	ld	s5,160(sp)
    80001b14:	0a813b03          	ld	s6,168(sp)
    80001b18:	0b013b83          	ld	s7,176(sp)
    80001b1c:	0b813c03          	ld	s8,184(sp)
    80001b20:	0c013c83          	ld	s9,192(sp)
    80001b24:	0c813d03          	ld	s10,200(sp)
    80001b28:	0d013d83          	ld	s11,208(sp)
    80001b2c:	0d813e03          	ld	t3,216(sp)
    80001b30:	0e013e83          	ld	t4,224(sp)
    80001b34:	0e813f03          	ld	t5,232(sp)
    80001b38:	0f013f83          	ld	t6,240(sp)
    80001b3c:	10010113          	addi	sp,sp,256
    80001b40:	10200073          	sret
    80001b44:	00000013          	nop
    80001b48:	00000013          	nop
    80001b4c:	00000013          	nop

0000000080001b50 <timervec>:
    80001b50:	34051573          	csrrw	a0,mscratch,a0
    80001b54:	00b53023          	sd	a1,0(a0)
    80001b58:	00c53423          	sd	a2,8(a0)
    80001b5c:	00d53823          	sd	a3,16(a0)
    80001b60:	01853583          	ld	a1,24(a0)
    80001b64:	02053603          	ld	a2,32(a0)
    80001b68:	0005b683          	ld	a3,0(a1)
    80001b6c:	00c686b3          	add	a3,a3,a2
    80001b70:	00d5b023          	sd	a3,0(a1)
    80001b74:	00200593          	li	a1,2
    80001b78:	14459073          	csrw	sip,a1
    80001b7c:	01053683          	ld	a3,16(a0)
    80001b80:	00853603          	ld	a2,8(a0)
    80001b84:	00053583          	ld	a1,0(a0)
    80001b88:	34051573          	csrrw	a0,mscratch,a0
    80001b8c:	30200073          	mret

0000000080001b90 <plicinit>:
    80001b90:	ff010113          	addi	sp,sp,-16
    80001b94:	00813423          	sd	s0,8(sp)
    80001b98:	01010413          	addi	s0,sp,16
    80001b9c:	00813403          	ld	s0,8(sp)
    80001ba0:	0c0007b7          	lui	a5,0xc000
    80001ba4:	00100713          	li	a4,1
    80001ba8:	02e7a423          	sw	a4,40(a5) # c000028 <_entry-0x73ffffd8>
    80001bac:	00e7a223          	sw	a4,4(a5)
    80001bb0:	01010113          	addi	sp,sp,16
    80001bb4:	00008067          	ret

0000000080001bb8 <plicinithart>:
    80001bb8:	ff010113          	addi	sp,sp,-16
    80001bbc:	00813023          	sd	s0,0(sp)
    80001bc0:	00113423          	sd	ra,8(sp)
    80001bc4:	01010413          	addi	s0,sp,16
    80001bc8:	00000097          	auipc	ra,0x0
    80001bcc:	a48080e7          	jalr	-1464(ra) # 80001610 <cpuid>
    80001bd0:	0085171b          	slliw	a4,a0,0x8
    80001bd4:	0c0027b7          	lui	a5,0xc002
    80001bd8:	00e787b3          	add	a5,a5,a4
    80001bdc:	40200713          	li	a4,1026
    80001be0:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>
    80001be4:	00813083          	ld	ra,8(sp)
    80001be8:	00013403          	ld	s0,0(sp)
    80001bec:	00d5151b          	slliw	a0,a0,0xd
    80001bf0:	0c2017b7          	lui	a5,0xc201
    80001bf4:	00a78533          	add	a0,a5,a0
    80001bf8:	00052023          	sw	zero,0(a0)
    80001bfc:	01010113          	addi	sp,sp,16
    80001c00:	00008067          	ret

0000000080001c04 <plic_claim>:
    80001c04:	ff010113          	addi	sp,sp,-16
    80001c08:	00813023          	sd	s0,0(sp)
    80001c0c:	00113423          	sd	ra,8(sp)
    80001c10:	01010413          	addi	s0,sp,16
    80001c14:	00000097          	auipc	ra,0x0
    80001c18:	9fc080e7          	jalr	-1540(ra) # 80001610 <cpuid>
    80001c1c:	00813083          	ld	ra,8(sp)
    80001c20:	00013403          	ld	s0,0(sp)
    80001c24:	00d5151b          	slliw	a0,a0,0xd
    80001c28:	0c2017b7          	lui	a5,0xc201
    80001c2c:	00a78533          	add	a0,a5,a0
    80001c30:	00452503          	lw	a0,4(a0)
    80001c34:	01010113          	addi	sp,sp,16
    80001c38:	00008067          	ret

0000000080001c3c <plic_complete>:
    80001c3c:	fe010113          	addi	sp,sp,-32
    80001c40:	00813823          	sd	s0,16(sp)
    80001c44:	00913423          	sd	s1,8(sp)
    80001c48:	00113c23          	sd	ra,24(sp)
    80001c4c:	02010413          	addi	s0,sp,32
    80001c50:	00050493          	mv	s1,a0
    80001c54:	00000097          	auipc	ra,0x0
    80001c58:	9bc080e7          	jalr	-1604(ra) # 80001610 <cpuid>
    80001c5c:	01813083          	ld	ra,24(sp)
    80001c60:	01013403          	ld	s0,16(sp)
    80001c64:	00d5179b          	slliw	a5,a0,0xd
    80001c68:	0c201737          	lui	a4,0xc201
    80001c6c:	00f707b3          	add	a5,a4,a5
    80001c70:	0097a223          	sw	s1,4(a5) # c201004 <_entry-0x73dfeffc>
    80001c74:	00813483          	ld	s1,8(sp)
    80001c78:	02010113          	addi	sp,sp,32
    80001c7c:	00008067          	ret

0000000080001c80 <consolewrite>:
    80001c80:	fb010113          	addi	sp,sp,-80
    80001c84:	04813023          	sd	s0,64(sp)
    80001c88:	04113423          	sd	ra,72(sp)
    80001c8c:	02913c23          	sd	s1,56(sp)
    80001c90:	03213823          	sd	s2,48(sp)
    80001c94:	03313423          	sd	s3,40(sp)
    80001c98:	03413023          	sd	s4,32(sp)
    80001c9c:	01513c23          	sd	s5,24(sp)
    80001ca0:	05010413          	addi	s0,sp,80
    80001ca4:	06c05c63          	blez	a2,80001d1c <consolewrite+0x9c>
    80001ca8:	00060993          	mv	s3,a2
    80001cac:	00050a13          	mv	s4,a0
    80001cb0:	00058493          	mv	s1,a1
    80001cb4:	00000913          	li	s2,0
    80001cb8:	fff00a93          	li	s5,-1
    80001cbc:	01c0006f          	j	80001cd8 <consolewrite+0x58>
    80001cc0:	fbf44503          	lbu	a0,-65(s0)
    80001cc4:	0019091b          	addiw	s2,s2,1
    80001cc8:	00148493          	addi	s1,s1,1
    80001ccc:	00001097          	auipc	ra,0x1
    80001cd0:	a9c080e7          	jalr	-1380(ra) # 80002768 <uartputc>
    80001cd4:	03298063          	beq	s3,s2,80001cf4 <consolewrite+0x74>
    80001cd8:	00048613          	mv	a2,s1
    80001cdc:	00100693          	li	a3,1
    80001ce0:	000a0593          	mv	a1,s4
    80001ce4:	fbf40513          	addi	a0,s0,-65
    80001ce8:	00000097          	auipc	ra,0x0
    80001cec:	9e0080e7          	jalr	-1568(ra) # 800016c8 <either_copyin>
    80001cf0:	fd5518e3          	bne	a0,s5,80001cc0 <consolewrite+0x40>
    80001cf4:	04813083          	ld	ra,72(sp)
    80001cf8:	04013403          	ld	s0,64(sp)
    80001cfc:	03813483          	ld	s1,56(sp)
    80001d00:	02813983          	ld	s3,40(sp)
    80001d04:	02013a03          	ld	s4,32(sp)
    80001d08:	01813a83          	ld	s5,24(sp)
    80001d0c:	00090513          	mv	a0,s2
    80001d10:	03013903          	ld	s2,48(sp)
    80001d14:	05010113          	addi	sp,sp,80
    80001d18:	00008067          	ret
    80001d1c:	00000913          	li	s2,0
    80001d20:	fd5ff06f          	j	80001cf4 <consolewrite+0x74>

0000000080001d24 <consoleread>:
    80001d24:	f9010113          	addi	sp,sp,-112
    80001d28:	06813023          	sd	s0,96(sp)
    80001d2c:	04913c23          	sd	s1,88(sp)
    80001d30:	05213823          	sd	s2,80(sp)
    80001d34:	05313423          	sd	s3,72(sp)
    80001d38:	05413023          	sd	s4,64(sp)
    80001d3c:	03513c23          	sd	s5,56(sp)
    80001d40:	03613823          	sd	s6,48(sp)
    80001d44:	03713423          	sd	s7,40(sp)
    80001d48:	03813023          	sd	s8,32(sp)
    80001d4c:	06113423          	sd	ra,104(sp)
    80001d50:	01913c23          	sd	s9,24(sp)
    80001d54:	07010413          	addi	s0,sp,112
    80001d58:	00060b93          	mv	s7,a2
    80001d5c:	00050913          	mv	s2,a0
    80001d60:	00058c13          	mv	s8,a1
    80001d64:	00060b1b          	sext.w	s6,a2
    80001d68:	00003497          	auipc	s1,0x3
    80001d6c:	7d048493          	addi	s1,s1,2000 # 80005538 <cons>
    80001d70:	00400993          	li	s3,4
    80001d74:	fff00a13          	li	s4,-1
    80001d78:	00a00a93          	li	s5,10
    80001d7c:	05705e63          	blez	s7,80001dd8 <consoleread+0xb4>
    80001d80:	09c4a703          	lw	a4,156(s1)
    80001d84:	0984a783          	lw	a5,152(s1)
    80001d88:	0007071b          	sext.w	a4,a4
    80001d8c:	08e78463          	beq	a5,a4,80001e14 <consoleread+0xf0>
    80001d90:	07f7f713          	andi	a4,a5,127
    80001d94:	00e48733          	add	a4,s1,a4
    80001d98:	01874703          	lbu	a4,24(a4) # c201018 <_entry-0x73dfefe8>
    80001d9c:	0017869b          	addiw	a3,a5,1
    80001da0:	08d4ac23          	sw	a3,152(s1)
    80001da4:	00070c9b          	sext.w	s9,a4
    80001da8:	0b370663          	beq	a4,s3,80001e54 <consoleread+0x130>
    80001dac:	00100693          	li	a3,1
    80001db0:	f9f40613          	addi	a2,s0,-97
    80001db4:	000c0593          	mv	a1,s8
    80001db8:	00090513          	mv	a0,s2
    80001dbc:	f8e40fa3          	sb	a4,-97(s0)
    80001dc0:	00000097          	auipc	ra,0x0
    80001dc4:	8bc080e7          	jalr	-1860(ra) # 8000167c <either_copyout>
    80001dc8:	01450863          	beq	a0,s4,80001dd8 <consoleread+0xb4>
    80001dcc:	001c0c13          	addi	s8,s8,1
    80001dd0:	fffb8b9b          	addiw	s7,s7,-1
    80001dd4:	fb5c94e3          	bne	s9,s5,80001d7c <consoleread+0x58>
    80001dd8:	000b851b          	sext.w	a0,s7
    80001ddc:	06813083          	ld	ra,104(sp)
    80001de0:	06013403          	ld	s0,96(sp)
    80001de4:	05813483          	ld	s1,88(sp)
    80001de8:	05013903          	ld	s2,80(sp)
    80001dec:	04813983          	ld	s3,72(sp)
    80001df0:	04013a03          	ld	s4,64(sp)
    80001df4:	03813a83          	ld	s5,56(sp)
    80001df8:	02813b83          	ld	s7,40(sp)
    80001dfc:	02013c03          	ld	s8,32(sp)
    80001e00:	01813c83          	ld	s9,24(sp)
    80001e04:	40ab053b          	subw	a0,s6,a0
    80001e08:	03013b03          	ld	s6,48(sp)
    80001e0c:	07010113          	addi	sp,sp,112
    80001e10:	00008067          	ret
    80001e14:	00001097          	auipc	ra,0x1
    80001e18:	1d8080e7          	jalr	472(ra) # 80002fec <push_on>
    80001e1c:	0984a703          	lw	a4,152(s1)
    80001e20:	09c4a783          	lw	a5,156(s1)
    80001e24:	0007879b          	sext.w	a5,a5
    80001e28:	fef70ce3          	beq	a4,a5,80001e20 <consoleread+0xfc>
    80001e2c:	00001097          	auipc	ra,0x1
    80001e30:	234080e7          	jalr	564(ra) # 80003060 <pop_on>
    80001e34:	0984a783          	lw	a5,152(s1)
    80001e38:	07f7f713          	andi	a4,a5,127
    80001e3c:	00e48733          	add	a4,s1,a4
    80001e40:	01874703          	lbu	a4,24(a4)
    80001e44:	0017869b          	addiw	a3,a5,1
    80001e48:	08d4ac23          	sw	a3,152(s1)
    80001e4c:	00070c9b          	sext.w	s9,a4
    80001e50:	f5371ee3          	bne	a4,s3,80001dac <consoleread+0x88>
    80001e54:	000b851b          	sext.w	a0,s7
    80001e58:	f96bf2e3          	bgeu	s7,s6,80001ddc <consoleread+0xb8>
    80001e5c:	08f4ac23          	sw	a5,152(s1)
    80001e60:	f7dff06f          	j	80001ddc <consoleread+0xb8>

0000000080001e64 <consputc>:
    80001e64:	10000793          	li	a5,256
    80001e68:	00f50663          	beq	a0,a5,80001e74 <consputc+0x10>
    80001e6c:	00001317          	auipc	t1,0x1
    80001e70:	9f430067          	jr	-1548(t1) # 80002860 <uartputc_sync>
    80001e74:	ff010113          	addi	sp,sp,-16
    80001e78:	00113423          	sd	ra,8(sp)
    80001e7c:	00813023          	sd	s0,0(sp)
    80001e80:	01010413          	addi	s0,sp,16
    80001e84:	00800513          	li	a0,8
    80001e88:	00001097          	auipc	ra,0x1
    80001e8c:	9d8080e7          	jalr	-1576(ra) # 80002860 <uartputc_sync>
    80001e90:	02000513          	li	a0,32
    80001e94:	00001097          	auipc	ra,0x1
    80001e98:	9cc080e7          	jalr	-1588(ra) # 80002860 <uartputc_sync>
    80001e9c:	00013403          	ld	s0,0(sp)
    80001ea0:	00813083          	ld	ra,8(sp)
    80001ea4:	00800513          	li	a0,8
    80001ea8:	01010113          	addi	sp,sp,16
    80001eac:	00001317          	auipc	t1,0x1
    80001eb0:	9b430067          	jr	-1612(t1) # 80002860 <uartputc_sync>

0000000080001eb4 <consoleintr>:
    80001eb4:	fe010113          	addi	sp,sp,-32
    80001eb8:	00813823          	sd	s0,16(sp)
    80001ebc:	00913423          	sd	s1,8(sp)
    80001ec0:	01213023          	sd	s2,0(sp)
    80001ec4:	00113c23          	sd	ra,24(sp)
    80001ec8:	02010413          	addi	s0,sp,32
    80001ecc:	00003917          	auipc	s2,0x3
    80001ed0:	66c90913          	addi	s2,s2,1644 # 80005538 <cons>
    80001ed4:	00050493          	mv	s1,a0
    80001ed8:	00090513          	mv	a0,s2
    80001edc:	00001097          	auipc	ra,0x1
    80001ee0:	e40080e7          	jalr	-448(ra) # 80002d1c <acquire>
    80001ee4:	02048c63          	beqz	s1,80001f1c <consoleintr+0x68>
    80001ee8:	0a092783          	lw	a5,160(s2)
    80001eec:	09892703          	lw	a4,152(s2)
    80001ef0:	07f00693          	li	a3,127
    80001ef4:	40e7873b          	subw	a4,a5,a4
    80001ef8:	02e6e263          	bltu	a3,a4,80001f1c <consoleintr+0x68>
    80001efc:	00d00713          	li	a4,13
    80001f00:	04e48063          	beq	s1,a4,80001f40 <consoleintr+0x8c>
    80001f04:	07f7f713          	andi	a4,a5,127
    80001f08:	00e90733          	add	a4,s2,a4
    80001f0c:	0017879b          	addiw	a5,a5,1
    80001f10:	0af92023          	sw	a5,160(s2)
    80001f14:	00970c23          	sb	s1,24(a4)
    80001f18:	08f92e23          	sw	a5,156(s2)
    80001f1c:	01013403          	ld	s0,16(sp)
    80001f20:	01813083          	ld	ra,24(sp)
    80001f24:	00813483          	ld	s1,8(sp)
    80001f28:	00013903          	ld	s2,0(sp)
    80001f2c:	00003517          	auipc	a0,0x3
    80001f30:	60c50513          	addi	a0,a0,1548 # 80005538 <cons>
    80001f34:	02010113          	addi	sp,sp,32
    80001f38:	00001317          	auipc	t1,0x1
    80001f3c:	eb030067          	jr	-336(t1) # 80002de8 <release>
    80001f40:	00a00493          	li	s1,10
    80001f44:	fc1ff06f          	j	80001f04 <consoleintr+0x50>

0000000080001f48 <consoleinit>:
    80001f48:	fe010113          	addi	sp,sp,-32
    80001f4c:	00113c23          	sd	ra,24(sp)
    80001f50:	00813823          	sd	s0,16(sp)
    80001f54:	00913423          	sd	s1,8(sp)
    80001f58:	02010413          	addi	s0,sp,32
    80001f5c:	00003497          	auipc	s1,0x3
    80001f60:	5dc48493          	addi	s1,s1,1500 # 80005538 <cons>
    80001f64:	00048513          	mv	a0,s1
    80001f68:	00002597          	auipc	a1,0x2
    80001f6c:	29858593          	addi	a1,a1,664 # 80004200 <CONSOLE_STATUS+0x1f0>
    80001f70:	00001097          	auipc	ra,0x1
    80001f74:	d88080e7          	jalr	-632(ra) # 80002cf8 <initlock>
    80001f78:	00000097          	auipc	ra,0x0
    80001f7c:	7ac080e7          	jalr	1964(ra) # 80002724 <uartinit>
    80001f80:	01813083          	ld	ra,24(sp)
    80001f84:	01013403          	ld	s0,16(sp)
    80001f88:	00000797          	auipc	a5,0x0
    80001f8c:	d9c78793          	addi	a5,a5,-612 # 80001d24 <consoleread>
    80001f90:	0af4bc23          	sd	a5,184(s1)
    80001f94:	00000797          	auipc	a5,0x0
    80001f98:	cec78793          	addi	a5,a5,-788 # 80001c80 <consolewrite>
    80001f9c:	0cf4b023          	sd	a5,192(s1)
    80001fa0:	00813483          	ld	s1,8(sp)
    80001fa4:	02010113          	addi	sp,sp,32
    80001fa8:	00008067          	ret

0000000080001fac <console_read>:
    80001fac:	ff010113          	addi	sp,sp,-16
    80001fb0:	00813423          	sd	s0,8(sp)
    80001fb4:	01010413          	addi	s0,sp,16
    80001fb8:	00813403          	ld	s0,8(sp)
    80001fbc:	00003317          	auipc	t1,0x3
    80001fc0:	63433303          	ld	t1,1588(t1) # 800055f0 <devsw+0x10>
    80001fc4:	01010113          	addi	sp,sp,16
    80001fc8:	00030067          	jr	t1

0000000080001fcc <console_write>:
    80001fcc:	ff010113          	addi	sp,sp,-16
    80001fd0:	00813423          	sd	s0,8(sp)
    80001fd4:	01010413          	addi	s0,sp,16
    80001fd8:	00813403          	ld	s0,8(sp)
    80001fdc:	00003317          	auipc	t1,0x3
    80001fe0:	61c33303          	ld	t1,1564(t1) # 800055f8 <devsw+0x18>
    80001fe4:	01010113          	addi	sp,sp,16
    80001fe8:	00030067          	jr	t1

0000000080001fec <panic>:
    80001fec:	fe010113          	addi	sp,sp,-32
    80001ff0:	00113c23          	sd	ra,24(sp)
    80001ff4:	00813823          	sd	s0,16(sp)
    80001ff8:	00913423          	sd	s1,8(sp)
    80001ffc:	02010413          	addi	s0,sp,32
    80002000:	00050493          	mv	s1,a0
    80002004:	00002517          	auipc	a0,0x2
    80002008:	20450513          	addi	a0,a0,516 # 80004208 <CONSOLE_STATUS+0x1f8>
    8000200c:	00003797          	auipc	a5,0x3
    80002010:	6807a623          	sw	zero,1676(a5) # 80005698 <pr+0x18>
    80002014:	00000097          	auipc	ra,0x0
    80002018:	034080e7          	jalr	52(ra) # 80002048 <__printf>
    8000201c:	00048513          	mv	a0,s1
    80002020:	00000097          	auipc	ra,0x0
    80002024:	028080e7          	jalr	40(ra) # 80002048 <__printf>
    80002028:	00002517          	auipc	a0,0x2
    8000202c:	1c050513          	addi	a0,a0,448 # 800041e8 <CONSOLE_STATUS+0x1d8>
    80002030:	00000097          	auipc	ra,0x0
    80002034:	018080e7          	jalr	24(ra) # 80002048 <__printf>
    80002038:	00100793          	li	a5,1
    8000203c:	00002717          	auipc	a4,0x2
    80002040:	40f72a23          	sw	a5,1044(a4) # 80004450 <panicked>
    80002044:	0000006f          	j	80002044 <panic+0x58>

0000000080002048 <__printf>:
    80002048:	f3010113          	addi	sp,sp,-208
    8000204c:	08813023          	sd	s0,128(sp)
    80002050:	07313423          	sd	s3,104(sp)
    80002054:	09010413          	addi	s0,sp,144
    80002058:	05813023          	sd	s8,64(sp)
    8000205c:	08113423          	sd	ra,136(sp)
    80002060:	06913c23          	sd	s1,120(sp)
    80002064:	07213823          	sd	s2,112(sp)
    80002068:	07413023          	sd	s4,96(sp)
    8000206c:	05513c23          	sd	s5,88(sp)
    80002070:	05613823          	sd	s6,80(sp)
    80002074:	05713423          	sd	s7,72(sp)
    80002078:	03913c23          	sd	s9,56(sp)
    8000207c:	03a13823          	sd	s10,48(sp)
    80002080:	03b13423          	sd	s11,40(sp)
    80002084:	00003317          	auipc	t1,0x3
    80002088:	5fc30313          	addi	t1,t1,1532 # 80005680 <pr>
    8000208c:	01832c03          	lw	s8,24(t1)
    80002090:	00b43423          	sd	a1,8(s0)
    80002094:	00c43823          	sd	a2,16(s0)
    80002098:	00d43c23          	sd	a3,24(s0)
    8000209c:	02e43023          	sd	a4,32(s0)
    800020a0:	02f43423          	sd	a5,40(s0)
    800020a4:	03043823          	sd	a6,48(s0)
    800020a8:	03143c23          	sd	a7,56(s0)
    800020ac:	00050993          	mv	s3,a0
    800020b0:	4a0c1663          	bnez	s8,8000255c <__printf+0x514>
    800020b4:	60098c63          	beqz	s3,800026cc <__printf+0x684>
    800020b8:	0009c503          	lbu	a0,0(s3)
    800020bc:	00840793          	addi	a5,s0,8
    800020c0:	f6f43c23          	sd	a5,-136(s0)
    800020c4:	00000493          	li	s1,0
    800020c8:	22050063          	beqz	a0,800022e8 <__printf+0x2a0>
    800020cc:	00002a37          	lui	s4,0x2
    800020d0:	00018ab7          	lui	s5,0x18
    800020d4:	000f4b37          	lui	s6,0xf4
    800020d8:	00989bb7          	lui	s7,0x989
    800020dc:	70fa0a13          	addi	s4,s4,1807 # 270f <_entry-0x7fffd8f1>
    800020e0:	69fa8a93          	addi	s5,s5,1695 # 1869f <_entry-0x7ffe7961>
    800020e4:	23fb0b13          	addi	s6,s6,575 # f423f <_entry-0x7ff0bdc1>
    800020e8:	67fb8b93          	addi	s7,s7,1663 # 98967f <_entry-0x7f676981>
    800020ec:	00148c9b          	addiw	s9,s1,1
    800020f0:	02500793          	li	a5,37
    800020f4:	01998933          	add	s2,s3,s9
    800020f8:	38f51263          	bne	a0,a5,8000247c <__printf+0x434>
    800020fc:	00094783          	lbu	a5,0(s2)
    80002100:	00078c9b          	sext.w	s9,a5
    80002104:	1e078263          	beqz	a5,800022e8 <__printf+0x2a0>
    80002108:	0024849b          	addiw	s1,s1,2
    8000210c:	07000713          	li	a4,112
    80002110:	00998933          	add	s2,s3,s1
    80002114:	38e78a63          	beq	a5,a4,800024a8 <__printf+0x460>
    80002118:	20f76863          	bltu	a4,a5,80002328 <__printf+0x2e0>
    8000211c:	42a78863          	beq	a5,a0,8000254c <__printf+0x504>
    80002120:	06400713          	li	a4,100
    80002124:	40e79663          	bne	a5,a4,80002530 <__printf+0x4e8>
    80002128:	f7843783          	ld	a5,-136(s0)
    8000212c:	0007a603          	lw	a2,0(a5)
    80002130:	00878793          	addi	a5,a5,8
    80002134:	f6f43c23          	sd	a5,-136(s0)
    80002138:	42064a63          	bltz	a2,8000256c <__printf+0x524>
    8000213c:	00a00713          	li	a4,10
    80002140:	02e677bb          	remuw	a5,a2,a4
    80002144:	00002d97          	auipc	s11,0x2
    80002148:	0ecd8d93          	addi	s11,s11,236 # 80004230 <digits>
    8000214c:	00900593          	li	a1,9
    80002150:	0006051b          	sext.w	a0,a2
    80002154:	00000c93          	li	s9,0
    80002158:	02079793          	slli	a5,a5,0x20
    8000215c:	0207d793          	srli	a5,a5,0x20
    80002160:	00fd87b3          	add	a5,s11,a5
    80002164:	0007c783          	lbu	a5,0(a5)
    80002168:	02e656bb          	divuw	a3,a2,a4
    8000216c:	f8f40023          	sb	a5,-128(s0)
    80002170:	14c5d863          	bge	a1,a2,800022c0 <__printf+0x278>
    80002174:	06300593          	li	a1,99
    80002178:	00100c93          	li	s9,1
    8000217c:	02e6f7bb          	remuw	a5,a3,a4
    80002180:	02079793          	slli	a5,a5,0x20
    80002184:	0207d793          	srli	a5,a5,0x20
    80002188:	00fd87b3          	add	a5,s11,a5
    8000218c:	0007c783          	lbu	a5,0(a5)
    80002190:	02e6d73b          	divuw	a4,a3,a4
    80002194:	f8f400a3          	sb	a5,-127(s0)
    80002198:	12a5f463          	bgeu	a1,a0,800022c0 <__printf+0x278>
    8000219c:	00a00693          	li	a3,10
    800021a0:	00900593          	li	a1,9
    800021a4:	02d777bb          	remuw	a5,a4,a3
    800021a8:	02079793          	slli	a5,a5,0x20
    800021ac:	0207d793          	srli	a5,a5,0x20
    800021b0:	00fd87b3          	add	a5,s11,a5
    800021b4:	0007c503          	lbu	a0,0(a5)
    800021b8:	02d757bb          	divuw	a5,a4,a3
    800021bc:	f8a40123          	sb	a0,-126(s0)
    800021c0:	48e5f263          	bgeu	a1,a4,80002644 <__printf+0x5fc>
    800021c4:	06300513          	li	a0,99
    800021c8:	02d7f5bb          	remuw	a1,a5,a3
    800021cc:	02059593          	slli	a1,a1,0x20
    800021d0:	0205d593          	srli	a1,a1,0x20
    800021d4:	00bd85b3          	add	a1,s11,a1
    800021d8:	0005c583          	lbu	a1,0(a1)
    800021dc:	02d7d7bb          	divuw	a5,a5,a3
    800021e0:	f8b401a3          	sb	a1,-125(s0)
    800021e4:	48e57263          	bgeu	a0,a4,80002668 <__printf+0x620>
    800021e8:	3e700513          	li	a0,999
    800021ec:	02d7f5bb          	remuw	a1,a5,a3
    800021f0:	02059593          	slli	a1,a1,0x20
    800021f4:	0205d593          	srli	a1,a1,0x20
    800021f8:	00bd85b3          	add	a1,s11,a1
    800021fc:	0005c583          	lbu	a1,0(a1)
    80002200:	02d7d7bb          	divuw	a5,a5,a3
    80002204:	f8b40223          	sb	a1,-124(s0)
    80002208:	46e57663          	bgeu	a0,a4,80002674 <__printf+0x62c>
    8000220c:	02d7f5bb          	remuw	a1,a5,a3
    80002210:	02059593          	slli	a1,a1,0x20
    80002214:	0205d593          	srli	a1,a1,0x20
    80002218:	00bd85b3          	add	a1,s11,a1
    8000221c:	0005c583          	lbu	a1,0(a1)
    80002220:	02d7d7bb          	divuw	a5,a5,a3
    80002224:	f8b402a3          	sb	a1,-123(s0)
    80002228:	46ea7863          	bgeu	s4,a4,80002698 <__printf+0x650>
    8000222c:	02d7f5bb          	remuw	a1,a5,a3
    80002230:	02059593          	slli	a1,a1,0x20
    80002234:	0205d593          	srli	a1,a1,0x20
    80002238:	00bd85b3          	add	a1,s11,a1
    8000223c:	0005c583          	lbu	a1,0(a1)
    80002240:	02d7d7bb          	divuw	a5,a5,a3
    80002244:	f8b40323          	sb	a1,-122(s0)
    80002248:	3eeaf863          	bgeu	s5,a4,80002638 <__printf+0x5f0>
    8000224c:	02d7f5bb          	remuw	a1,a5,a3
    80002250:	02059593          	slli	a1,a1,0x20
    80002254:	0205d593          	srli	a1,a1,0x20
    80002258:	00bd85b3          	add	a1,s11,a1
    8000225c:	0005c583          	lbu	a1,0(a1)
    80002260:	02d7d7bb          	divuw	a5,a5,a3
    80002264:	f8b403a3          	sb	a1,-121(s0)
    80002268:	42eb7e63          	bgeu	s6,a4,800026a4 <__printf+0x65c>
    8000226c:	02d7f5bb          	remuw	a1,a5,a3
    80002270:	02059593          	slli	a1,a1,0x20
    80002274:	0205d593          	srli	a1,a1,0x20
    80002278:	00bd85b3          	add	a1,s11,a1
    8000227c:	0005c583          	lbu	a1,0(a1)
    80002280:	02d7d7bb          	divuw	a5,a5,a3
    80002284:	f8b40423          	sb	a1,-120(s0)
    80002288:	42ebfc63          	bgeu	s7,a4,800026c0 <__printf+0x678>
    8000228c:	02079793          	slli	a5,a5,0x20
    80002290:	0207d793          	srli	a5,a5,0x20
    80002294:	00fd8db3          	add	s11,s11,a5
    80002298:	000dc703          	lbu	a4,0(s11)
    8000229c:	00a00793          	li	a5,10
    800022a0:	00900c93          	li	s9,9
    800022a4:	f8e404a3          	sb	a4,-119(s0)
    800022a8:	00065c63          	bgez	a2,800022c0 <__printf+0x278>
    800022ac:	f9040713          	addi	a4,s0,-112
    800022b0:	00f70733          	add	a4,a4,a5
    800022b4:	02d00693          	li	a3,45
    800022b8:	fed70823          	sb	a3,-16(a4)
    800022bc:	00078c93          	mv	s9,a5
    800022c0:	f8040793          	addi	a5,s0,-128
    800022c4:	01978cb3          	add	s9,a5,s9
    800022c8:	f7f40d13          	addi	s10,s0,-129
    800022cc:	000cc503          	lbu	a0,0(s9)
    800022d0:	fffc8c93          	addi	s9,s9,-1
    800022d4:	00000097          	auipc	ra,0x0
    800022d8:	b90080e7          	jalr	-1136(ra) # 80001e64 <consputc>
    800022dc:	ffac98e3          	bne	s9,s10,800022cc <__printf+0x284>
    800022e0:	00094503          	lbu	a0,0(s2)
    800022e4:	e00514e3          	bnez	a0,800020ec <__printf+0xa4>
    800022e8:	1a0c1663          	bnez	s8,80002494 <__printf+0x44c>
    800022ec:	08813083          	ld	ra,136(sp)
    800022f0:	08013403          	ld	s0,128(sp)
    800022f4:	07813483          	ld	s1,120(sp)
    800022f8:	07013903          	ld	s2,112(sp)
    800022fc:	06813983          	ld	s3,104(sp)
    80002300:	06013a03          	ld	s4,96(sp)
    80002304:	05813a83          	ld	s5,88(sp)
    80002308:	05013b03          	ld	s6,80(sp)
    8000230c:	04813b83          	ld	s7,72(sp)
    80002310:	04013c03          	ld	s8,64(sp)
    80002314:	03813c83          	ld	s9,56(sp)
    80002318:	03013d03          	ld	s10,48(sp)
    8000231c:	02813d83          	ld	s11,40(sp)
    80002320:	0d010113          	addi	sp,sp,208
    80002324:	00008067          	ret
    80002328:	07300713          	li	a4,115
    8000232c:	1ce78a63          	beq	a5,a4,80002500 <__printf+0x4b8>
    80002330:	07800713          	li	a4,120
    80002334:	1ee79e63          	bne	a5,a4,80002530 <__printf+0x4e8>
    80002338:	f7843783          	ld	a5,-136(s0)
    8000233c:	0007a703          	lw	a4,0(a5)
    80002340:	00878793          	addi	a5,a5,8
    80002344:	f6f43c23          	sd	a5,-136(s0)
    80002348:	28074263          	bltz	a4,800025cc <__printf+0x584>
    8000234c:	00002d97          	auipc	s11,0x2
    80002350:	ee4d8d93          	addi	s11,s11,-284 # 80004230 <digits>
    80002354:	00f77793          	andi	a5,a4,15
    80002358:	00fd87b3          	add	a5,s11,a5
    8000235c:	0007c683          	lbu	a3,0(a5)
    80002360:	00f00613          	li	a2,15
    80002364:	0007079b          	sext.w	a5,a4
    80002368:	f8d40023          	sb	a3,-128(s0)
    8000236c:	0047559b          	srliw	a1,a4,0x4
    80002370:	0047569b          	srliw	a3,a4,0x4
    80002374:	00000c93          	li	s9,0
    80002378:	0ee65063          	bge	a2,a4,80002458 <__printf+0x410>
    8000237c:	00f6f693          	andi	a3,a3,15
    80002380:	00dd86b3          	add	a3,s11,a3
    80002384:	0006c683          	lbu	a3,0(a3) # 2004000 <_entry-0x7dffc000>
    80002388:	0087d79b          	srliw	a5,a5,0x8
    8000238c:	00100c93          	li	s9,1
    80002390:	f8d400a3          	sb	a3,-127(s0)
    80002394:	0cb67263          	bgeu	a2,a1,80002458 <__printf+0x410>
    80002398:	00f7f693          	andi	a3,a5,15
    8000239c:	00dd86b3          	add	a3,s11,a3
    800023a0:	0006c583          	lbu	a1,0(a3)
    800023a4:	00f00613          	li	a2,15
    800023a8:	0047d69b          	srliw	a3,a5,0x4
    800023ac:	f8b40123          	sb	a1,-126(s0)
    800023b0:	0047d593          	srli	a1,a5,0x4
    800023b4:	28f67e63          	bgeu	a2,a5,80002650 <__printf+0x608>
    800023b8:	00f6f693          	andi	a3,a3,15
    800023bc:	00dd86b3          	add	a3,s11,a3
    800023c0:	0006c503          	lbu	a0,0(a3)
    800023c4:	0087d813          	srli	a6,a5,0x8
    800023c8:	0087d69b          	srliw	a3,a5,0x8
    800023cc:	f8a401a3          	sb	a0,-125(s0)
    800023d0:	28b67663          	bgeu	a2,a1,8000265c <__printf+0x614>
    800023d4:	00f6f693          	andi	a3,a3,15
    800023d8:	00dd86b3          	add	a3,s11,a3
    800023dc:	0006c583          	lbu	a1,0(a3)
    800023e0:	00c7d513          	srli	a0,a5,0xc
    800023e4:	00c7d69b          	srliw	a3,a5,0xc
    800023e8:	f8b40223          	sb	a1,-124(s0)
    800023ec:	29067a63          	bgeu	a2,a6,80002680 <__printf+0x638>
    800023f0:	00f6f693          	andi	a3,a3,15
    800023f4:	00dd86b3          	add	a3,s11,a3
    800023f8:	0006c583          	lbu	a1,0(a3)
    800023fc:	0107d813          	srli	a6,a5,0x10
    80002400:	0107d69b          	srliw	a3,a5,0x10
    80002404:	f8b402a3          	sb	a1,-123(s0)
    80002408:	28a67263          	bgeu	a2,a0,8000268c <__printf+0x644>
    8000240c:	00f6f693          	andi	a3,a3,15
    80002410:	00dd86b3          	add	a3,s11,a3
    80002414:	0006c683          	lbu	a3,0(a3)
    80002418:	0147d79b          	srliw	a5,a5,0x14
    8000241c:	f8d40323          	sb	a3,-122(s0)
    80002420:	21067663          	bgeu	a2,a6,8000262c <__printf+0x5e4>
    80002424:	02079793          	slli	a5,a5,0x20
    80002428:	0207d793          	srli	a5,a5,0x20
    8000242c:	00fd8db3          	add	s11,s11,a5
    80002430:	000dc683          	lbu	a3,0(s11)
    80002434:	00800793          	li	a5,8
    80002438:	00700c93          	li	s9,7
    8000243c:	f8d403a3          	sb	a3,-121(s0)
    80002440:	00075c63          	bgez	a4,80002458 <__printf+0x410>
    80002444:	f9040713          	addi	a4,s0,-112
    80002448:	00f70733          	add	a4,a4,a5
    8000244c:	02d00693          	li	a3,45
    80002450:	fed70823          	sb	a3,-16(a4)
    80002454:	00078c93          	mv	s9,a5
    80002458:	f8040793          	addi	a5,s0,-128
    8000245c:	01978cb3          	add	s9,a5,s9
    80002460:	f7f40d13          	addi	s10,s0,-129
    80002464:	000cc503          	lbu	a0,0(s9)
    80002468:	fffc8c93          	addi	s9,s9,-1
    8000246c:	00000097          	auipc	ra,0x0
    80002470:	9f8080e7          	jalr	-1544(ra) # 80001e64 <consputc>
    80002474:	ff9d18e3          	bne	s10,s9,80002464 <__printf+0x41c>
    80002478:	0100006f          	j	80002488 <__printf+0x440>
    8000247c:	00000097          	auipc	ra,0x0
    80002480:	9e8080e7          	jalr	-1560(ra) # 80001e64 <consputc>
    80002484:	000c8493          	mv	s1,s9
    80002488:	00094503          	lbu	a0,0(s2)
    8000248c:	c60510e3          	bnez	a0,800020ec <__printf+0xa4>
    80002490:	e40c0ee3          	beqz	s8,800022ec <__printf+0x2a4>
    80002494:	00003517          	auipc	a0,0x3
    80002498:	1ec50513          	addi	a0,a0,492 # 80005680 <pr>
    8000249c:	00001097          	auipc	ra,0x1
    800024a0:	94c080e7          	jalr	-1716(ra) # 80002de8 <release>
    800024a4:	e49ff06f          	j	800022ec <__printf+0x2a4>
    800024a8:	f7843783          	ld	a5,-136(s0)
    800024ac:	03000513          	li	a0,48
    800024b0:	01000d13          	li	s10,16
    800024b4:	00878713          	addi	a4,a5,8
    800024b8:	0007bc83          	ld	s9,0(a5)
    800024bc:	f6e43c23          	sd	a4,-136(s0)
    800024c0:	00000097          	auipc	ra,0x0
    800024c4:	9a4080e7          	jalr	-1628(ra) # 80001e64 <consputc>
    800024c8:	07800513          	li	a0,120
    800024cc:	00000097          	auipc	ra,0x0
    800024d0:	998080e7          	jalr	-1640(ra) # 80001e64 <consputc>
    800024d4:	00002d97          	auipc	s11,0x2
    800024d8:	d5cd8d93          	addi	s11,s11,-676 # 80004230 <digits>
    800024dc:	03ccd793          	srli	a5,s9,0x3c
    800024e0:	00fd87b3          	add	a5,s11,a5
    800024e4:	0007c503          	lbu	a0,0(a5)
    800024e8:	fffd0d1b          	addiw	s10,s10,-1
    800024ec:	004c9c93          	slli	s9,s9,0x4
    800024f0:	00000097          	auipc	ra,0x0
    800024f4:	974080e7          	jalr	-1676(ra) # 80001e64 <consputc>
    800024f8:	fe0d12e3          	bnez	s10,800024dc <__printf+0x494>
    800024fc:	f8dff06f          	j	80002488 <__printf+0x440>
    80002500:	f7843783          	ld	a5,-136(s0)
    80002504:	0007bc83          	ld	s9,0(a5)
    80002508:	00878793          	addi	a5,a5,8
    8000250c:	f6f43c23          	sd	a5,-136(s0)
    80002510:	000c9a63          	bnez	s9,80002524 <__printf+0x4dc>
    80002514:	1080006f          	j	8000261c <__printf+0x5d4>
    80002518:	001c8c93          	addi	s9,s9,1
    8000251c:	00000097          	auipc	ra,0x0
    80002520:	948080e7          	jalr	-1720(ra) # 80001e64 <consputc>
    80002524:	000cc503          	lbu	a0,0(s9)
    80002528:	fe0518e3          	bnez	a0,80002518 <__printf+0x4d0>
    8000252c:	f5dff06f          	j	80002488 <__printf+0x440>
    80002530:	02500513          	li	a0,37
    80002534:	00000097          	auipc	ra,0x0
    80002538:	930080e7          	jalr	-1744(ra) # 80001e64 <consputc>
    8000253c:	000c8513          	mv	a0,s9
    80002540:	00000097          	auipc	ra,0x0
    80002544:	924080e7          	jalr	-1756(ra) # 80001e64 <consputc>
    80002548:	f41ff06f          	j	80002488 <__printf+0x440>
    8000254c:	02500513          	li	a0,37
    80002550:	00000097          	auipc	ra,0x0
    80002554:	914080e7          	jalr	-1772(ra) # 80001e64 <consputc>
    80002558:	f31ff06f          	j	80002488 <__printf+0x440>
    8000255c:	00030513          	mv	a0,t1
    80002560:	00000097          	auipc	ra,0x0
    80002564:	7bc080e7          	jalr	1980(ra) # 80002d1c <acquire>
    80002568:	b4dff06f          	j	800020b4 <__printf+0x6c>
    8000256c:	40c0053b          	negw	a0,a2
    80002570:	00a00713          	li	a4,10
    80002574:	02e576bb          	remuw	a3,a0,a4
    80002578:	00002d97          	auipc	s11,0x2
    8000257c:	cb8d8d93          	addi	s11,s11,-840 # 80004230 <digits>
    80002580:	ff700593          	li	a1,-9
    80002584:	02069693          	slli	a3,a3,0x20
    80002588:	0206d693          	srli	a3,a3,0x20
    8000258c:	00dd86b3          	add	a3,s11,a3
    80002590:	0006c683          	lbu	a3,0(a3)
    80002594:	02e557bb          	divuw	a5,a0,a4
    80002598:	f8d40023          	sb	a3,-128(s0)
    8000259c:	10b65e63          	bge	a2,a1,800026b8 <__printf+0x670>
    800025a0:	06300593          	li	a1,99
    800025a4:	02e7f6bb          	remuw	a3,a5,a4
    800025a8:	02069693          	slli	a3,a3,0x20
    800025ac:	0206d693          	srli	a3,a3,0x20
    800025b0:	00dd86b3          	add	a3,s11,a3
    800025b4:	0006c683          	lbu	a3,0(a3)
    800025b8:	02e7d73b          	divuw	a4,a5,a4
    800025bc:	00200793          	li	a5,2
    800025c0:	f8d400a3          	sb	a3,-127(s0)
    800025c4:	bca5ece3          	bltu	a1,a0,8000219c <__printf+0x154>
    800025c8:	ce5ff06f          	j	800022ac <__printf+0x264>
    800025cc:	40e007bb          	negw	a5,a4
    800025d0:	00002d97          	auipc	s11,0x2
    800025d4:	c60d8d93          	addi	s11,s11,-928 # 80004230 <digits>
    800025d8:	00f7f693          	andi	a3,a5,15
    800025dc:	00dd86b3          	add	a3,s11,a3
    800025e0:	0006c583          	lbu	a1,0(a3)
    800025e4:	ff100613          	li	a2,-15
    800025e8:	0047d69b          	srliw	a3,a5,0x4
    800025ec:	f8b40023          	sb	a1,-128(s0)
    800025f0:	0047d59b          	srliw	a1,a5,0x4
    800025f4:	0ac75e63          	bge	a4,a2,800026b0 <__printf+0x668>
    800025f8:	00f6f693          	andi	a3,a3,15
    800025fc:	00dd86b3          	add	a3,s11,a3
    80002600:	0006c603          	lbu	a2,0(a3)
    80002604:	00f00693          	li	a3,15
    80002608:	0087d79b          	srliw	a5,a5,0x8
    8000260c:	f8c400a3          	sb	a2,-127(s0)
    80002610:	d8b6e4e3          	bltu	a3,a1,80002398 <__printf+0x350>
    80002614:	00200793          	li	a5,2
    80002618:	e2dff06f          	j	80002444 <__printf+0x3fc>
    8000261c:	00002c97          	auipc	s9,0x2
    80002620:	bf4c8c93          	addi	s9,s9,-1036 # 80004210 <CONSOLE_STATUS+0x200>
    80002624:	02800513          	li	a0,40
    80002628:	ef1ff06f          	j	80002518 <__printf+0x4d0>
    8000262c:	00700793          	li	a5,7
    80002630:	00600c93          	li	s9,6
    80002634:	e0dff06f          	j	80002440 <__printf+0x3f8>
    80002638:	00700793          	li	a5,7
    8000263c:	00600c93          	li	s9,6
    80002640:	c69ff06f          	j	800022a8 <__printf+0x260>
    80002644:	00300793          	li	a5,3
    80002648:	00200c93          	li	s9,2
    8000264c:	c5dff06f          	j	800022a8 <__printf+0x260>
    80002650:	00300793          	li	a5,3
    80002654:	00200c93          	li	s9,2
    80002658:	de9ff06f          	j	80002440 <__printf+0x3f8>
    8000265c:	00400793          	li	a5,4
    80002660:	00300c93          	li	s9,3
    80002664:	dddff06f          	j	80002440 <__printf+0x3f8>
    80002668:	00400793          	li	a5,4
    8000266c:	00300c93          	li	s9,3
    80002670:	c39ff06f          	j	800022a8 <__printf+0x260>
    80002674:	00500793          	li	a5,5
    80002678:	00400c93          	li	s9,4
    8000267c:	c2dff06f          	j	800022a8 <__printf+0x260>
    80002680:	00500793          	li	a5,5
    80002684:	00400c93          	li	s9,4
    80002688:	db9ff06f          	j	80002440 <__printf+0x3f8>
    8000268c:	00600793          	li	a5,6
    80002690:	00500c93          	li	s9,5
    80002694:	dadff06f          	j	80002440 <__printf+0x3f8>
    80002698:	00600793          	li	a5,6
    8000269c:	00500c93          	li	s9,5
    800026a0:	c09ff06f          	j	800022a8 <__printf+0x260>
    800026a4:	00800793          	li	a5,8
    800026a8:	00700c93          	li	s9,7
    800026ac:	bfdff06f          	j	800022a8 <__printf+0x260>
    800026b0:	00100793          	li	a5,1
    800026b4:	d91ff06f          	j	80002444 <__printf+0x3fc>
    800026b8:	00100793          	li	a5,1
    800026bc:	bf1ff06f          	j	800022ac <__printf+0x264>
    800026c0:	00900793          	li	a5,9
    800026c4:	00800c93          	li	s9,8
    800026c8:	be1ff06f          	j	800022a8 <__printf+0x260>
    800026cc:	00002517          	auipc	a0,0x2
    800026d0:	b4c50513          	addi	a0,a0,-1204 # 80004218 <CONSOLE_STATUS+0x208>
    800026d4:	00000097          	auipc	ra,0x0
    800026d8:	918080e7          	jalr	-1768(ra) # 80001fec <panic>

00000000800026dc <printfinit>:
    800026dc:	fe010113          	addi	sp,sp,-32
    800026e0:	00813823          	sd	s0,16(sp)
    800026e4:	00913423          	sd	s1,8(sp)
    800026e8:	00113c23          	sd	ra,24(sp)
    800026ec:	02010413          	addi	s0,sp,32
    800026f0:	00003497          	auipc	s1,0x3
    800026f4:	f9048493          	addi	s1,s1,-112 # 80005680 <pr>
    800026f8:	00048513          	mv	a0,s1
    800026fc:	00002597          	auipc	a1,0x2
    80002700:	b2c58593          	addi	a1,a1,-1236 # 80004228 <CONSOLE_STATUS+0x218>
    80002704:	00000097          	auipc	ra,0x0
    80002708:	5f4080e7          	jalr	1524(ra) # 80002cf8 <initlock>
    8000270c:	01813083          	ld	ra,24(sp)
    80002710:	01013403          	ld	s0,16(sp)
    80002714:	0004ac23          	sw	zero,24(s1)
    80002718:	00813483          	ld	s1,8(sp)
    8000271c:	02010113          	addi	sp,sp,32
    80002720:	00008067          	ret

0000000080002724 <uartinit>:
    80002724:	ff010113          	addi	sp,sp,-16
    80002728:	00813423          	sd	s0,8(sp)
    8000272c:	01010413          	addi	s0,sp,16
    80002730:	100007b7          	lui	a5,0x10000
    80002734:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>
    80002738:	f8000713          	li	a4,-128
    8000273c:	00e781a3          	sb	a4,3(a5)
    80002740:	00300713          	li	a4,3
    80002744:	00e78023          	sb	a4,0(a5)
    80002748:	000780a3          	sb	zero,1(a5)
    8000274c:	00e781a3          	sb	a4,3(a5)
    80002750:	00700693          	li	a3,7
    80002754:	00d78123          	sb	a3,2(a5)
    80002758:	00e780a3          	sb	a4,1(a5)
    8000275c:	00813403          	ld	s0,8(sp)
    80002760:	01010113          	addi	sp,sp,16
    80002764:	00008067          	ret

0000000080002768 <uartputc>:
    80002768:	00002797          	auipc	a5,0x2
    8000276c:	ce87a783          	lw	a5,-792(a5) # 80004450 <panicked>
    80002770:	00078463          	beqz	a5,80002778 <uartputc+0x10>
    80002774:	0000006f          	j	80002774 <uartputc+0xc>
    80002778:	fd010113          	addi	sp,sp,-48
    8000277c:	02813023          	sd	s0,32(sp)
    80002780:	00913c23          	sd	s1,24(sp)
    80002784:	01213823          	sd	s2,16(sp)
    80002788:	01313423          	sd	s3,8(sp)
    8000278c:	02113423          	sd	ra,40(sp)
    80002790:	03010413          	addi	s0,sp,48
    80002794:	00002917          	auipc	s2,0x2
    80002798:	cc490913          	addi	s2,s2,-828 # 80004458 <uart_tx_r>
    8000279c:	00093783          	ld	a5,0(s2)
    800027a0:	00002497          	auipc	s1,0x2
    800027a4:	cc048493          	addi	s1,s1,-832 # 80004460 <uart_tx_w>
    800027a8:	0004b703          	ld	a4,0(s1)
    800027ac:	02078693          	addi	a3,a5,32
    800027b0:	00050993          	mv	s3,a0
    800027b4:	02e69c63          	bne	a3,a4,800027ec <uartputc+0x84>
    800027b8:	00001097          	auipc	ra,0x1
    800027bc:	834080e7          	jalr	-1996(ra) # 80002fec <push_on>
    800027c0:	00093783          	ld	a5,0(s2)
    800027c4:	0004b703          	ld	a4,0(s1)
    800027c8:	02078793          	addi	a5,a5,32
    800027cc:	00e79463          	bne	a5,a4,800027d4 <uartputc+0x6c>
    800027d0:	0000006f          	j	800027d0 <uartputc+0x68>
    800027d4:	00001097          	auipc	ra,0x1
    800027d8:	88c080e7          	jalr	-1908(ra) # 80003060 <pop_on>
    800027dc:	00093783          	ld	a5,0(s2)
    800027e0:	0004b703          	ld	a4,0(s1)
    800027e4:	02078693          	addi	a3,a5,32
    800027e8:	fce688e3          	beq	a3,a4,800027b8 <uartputc+0x50>
    800027ec:	01f77693          	andi	a3,a4,31
    800027f0:	00003597          	auipc	a1,0x3
    800027f4:	eb058593          	addi	a1,a1,-336 # 800056a0 <uart_tx_buf>
    800027f8:	00d586b3          	add	a3,a1,a3
    800027fc:	00170713          	addi	a4,a4,1
    80002800:	01368023          	sb	s3,0(a3)
    80002804:	00e4b023          	sd	a4,0(s1)
    80002808:	10000637          	lui	a2,0x10000
    8000280c:	02f71063          	bne	a4,a5,8000282c <uartputc+0xc4>
    80002810:	0340006f          	j	80002844 <uartputc+0xdc>
    80002814:	00074703          	lbu	a4,0(a4)
    80002818:	00f93023          	sd	a5,0(s2)
    8000281c:	00e60023          	sb	a4,0(a2) # 10000000 <_entry-0x70000000>
    80002820:	00093783          	ld	a5,0(s2)
    80002824:	0004b703          	ld	a4,0(s1)
    80002828:	00f70e63          	beq	a4,a5,80002844 <uartputc+0xdc>
    8000282c:	00564683          	lbu	a3,5(a2)
    80002830:	01f7f713          	andi	a4,a5,31
    80002834:	00e58733          	add	a4,a1,a4
    80002838:	0206f693          	andi	a3,a3,32
    8000283c:	00178793          	addi	a5,a5,1
    80002840:	fc069ae3          	bnez	a3,80002814 <uartputc+0xac>
    80002844:	02813083          	ld	ra,40(sp)
    80002848:	02013403          	ld	s0,32(sp)
    8000284c:	01813483          	ld	s1,24(sp)
    80002850:	01013903          	ld	s2,16(sp)
    80002854:	00813983          	ld	s3,8(sp)
    80002858:	03010113          	addi	sp,sp,48
    8000285c:	00008067          	ret

0000000080002860 <uartputc_sync>:
    80002860:	ff010113          	addi	sp,sp,-16
    80002864:	00813423          	sd	s0,8(sp)
    80002868:	01010413          	addi	s0,sp,16
    8000286c:	00002717          	auipc	a4,0x2
    80002870:	be472703          	lw	a4,-1052(a4) # 80004450 <panicked>
    80002874:	02071663          	bnez	a4,800028a0 <uartputc_sync+0x40>
    80002878:	00050793          	mv	a5,a0
    8000287c:	100006b7          	lui	a3,0x10000
    80002880:	0056c703          	lbu	a4,5(a3) # 10000005 <_entry-0x6ffffffb>
    80002884:	02077713          	andi	a4,a4,32
    80002888:	fe070ce3          	beqz	a4,80002880 <uartputc_sync+0x20>
    8000288c:	0ff7f793          	andi	a5,a5,255
    80002890:	00f68023          	sb	a5,0(a3)
    80002894:	00813403          	ld	s0,8(sp)
    80002898:	01010113          	addi	sp,sp,16
    8000289c:	00008067          	ret
    800028a0:	0000006f          	j	800028a0 <uartputc_sync+0x40>

00000000800028a4 <uartstart>:
    800028a4:	ff010113          	addi	sp,sp,-16
    800028a8:	00813423          	sd	s0,8(sp)
    800028ac:	01010413          	addi	s0,sp,16
    800028b0:	00002617          	auipc	a2,0x2
    800028b4:	ba860613          	addi	a2,a2,-1112 # 80004458 <uart_tx_r>
    800028b8:	00002517          	auipc	a0,0x2
    800028bc:	ba850513          	addi	a0,a0,-1112 # 80004460 <uart_tx_w>
    800028c0:	00063783          	ld	a5,0(a2)
    800028c4:	00053703          	ld	a4,0(a0)
    800028c8:	04f70263          	beq	a4,a5,8000290c <uartstart+0x68>
    800028cc:	100005b7          	lui	a1,0x10000
    800028d0:	00003817          	auipc	a6,0x3
    800028d4:	dd080813          	addi	a6,a6,-560 # 800056a0 <uart_tx_buf>
    800028d8:	01c0006f          	j	800028f4 <uartstart+0x50>
    800028dc:	0006c703          	lbu	a4,0(a3)
    800028e0:	00f63023          	sd	a5,0(a2)
    800028e4:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    800028e8:	00063783          	ld	a5,0(a2)
    800028ec:	00053703          	ld	a4,0(a0)
    800028f0:	00f70e63          	beq	a4,a5,8000290c <uartstart+0x68>
    800028f4:	01f7f713          	andi	a4,a5,31
    800028f8:	00e806b3          	add	a3,a6,a4
    800028fc:	0055c703          	lbu	a4,5(a1)
    80002900:	00178793          	addi	a5,a5,1
    80002904:	02077713          	andi	a4,a4,32
    80002908:	fc071ae3          	bnez	a4,800028dc <uartstart+0x38>
    8000290c:	00813403          	ld	s0,8(sp)
    80002910:	01010113          	addi	sp,sp,16
    80002914:	00008067          	ret

0000000080002918 <uartgetc>:
    80002918:	ff010113          	addi	sp,sp,-16
    8000291c:	00813423          	sd	s0,8(sp)
    80002920:	01010413          	addi	s0,sp,16
    80002924:	10000737          	lui	a4,0x10000
    80002928:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000292c:	0017f793          	andi	a5,a5,1
    80002930:	00078c63          	beqz	a5,80002948 <uartgetc+0x30>
    80002934:	00074503          	lbu	a0,0(a4)
    80002938:	0ff57513          	andi	a0,a0,255
    8000293c:	00813403          	ld	s0,8(sp)
    80002940:	01010113          	addi	sp,sp,16
    80002944:	00008067          	ret
    80002948:	fff00513          	li	a0,-1
    8000294c:	ff1ff06f          	j	8000293c <uartgetc+0x24>

0000000080002950 <uartintr>:
    80002950:	100007b7          	lui	a5,0x10000
    80002954:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80002958:	0017f793          	andi	a5,a5,1
    8000295c:	0a078463          	beqz	a5,80002a04 <uartintr+0xb4>
    80002960:	fe010113          	addi	sp,sp,-32
    80002964:	00813823          	sd	s0,16(sp)
    80002968:	00913423          	sd	s1,8(sp)
    8000296c:	00113c23          	sd	ra,24(sp)
    80002970:	02010413          	addi	s0,sp,32
    80002974:	100004b7          	lui	s1,0x10000
    80002978:	0004c503          	lbu	a0,0(s1) # 10000000 <_entry-0x70000000>
    8000297c:	0ff57513          	andi	a0,a0,255
    80002980:	fffff097          	auipc	ra,0xfffff
    80002984:	534080e7          	jalr	1332(ra) # 80001eb4 <consoleintr>
    80002988:	0054c783          	lbu	a5,5(s1)
    8000298c:	0017f793          	andi	a5,a5,1
    80002990:	fe0794e3          	bnez	a5,80002978 <uartintr+0x28>
    80002994:	00002617          	auipc	a2,0x2
    80002998:	ac460613          	addi	a2,a2,-1340 # 80004458 <uart_tx_r>
    8000299c:	00002517          	auipc	a0,0x2
    800029a0:	ac450513          	addi	a0,a0,-1340 # 80004460 <uart_tx_w>
    800029a4:	00063783          	ld	a5,0(a2)
    800029a8:	00053703          	ld	a4,0(a0)
    800029ac:	04f70263          	beq	a4,a5,800029f0 <uartintr+0xa0>
    800029b0:	100005b7          	lui	a1,0x10000
    800029b4:	00003817          	auipc	a6,0x3
    800029b8:	cec80813          	addi	a6,a6,-788 # 800056a0 <uart_tx_buf>
    800029bc:	01c0006f          	j	800029d8 <uartintr+0x88>
    800029c0:	0006c703          	lbu	a4,0(a3)
    800029c4:	00f63023          	sd	a5,0(a2)
    800029c8:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    800029cc:	00063783          	ld	a5,0(a2)
    800029d0:	00053703          	ld	a4,0(a0)
    800029d4:	00f70e63          	beq	a4,a5,800029f0 <uartintr+0xa0>
    800029d8:	01f7f713          	andi	a4,a5,31
    800029dc:	00e806b3          	add	a3,a6,a4
    800029e0:	0055c703          	lbu	a4,5(a1)
    800029e4:	00178793          	addi	a5,a5,1
    800029e8:	02077713          	andi	a4,a4,32
    800029ec:	fc071ae3          	bnez	a4,800029c0 <uartintr+0x70>
    800029f0:	01813083          	ld	ra,24(sp)
    800029f4:	01013403          	ld	s0,16(sp)
    800029f8:	00813483          	ld	s1,8(sp)
    800029fc:	02010113          	addi	sp,sp,32
    80002a00:	00008067          	ret
    80002a04:	00002617          	auipc	a2,0x2
    80002a08:	a5460613          	addi	a2,a2,-1452 # 80004458 <uart_tx_r>
    80002a0c:	00002517          	auipc	a0,0x2
    80002a10:	a5450513          	addi	a0,a0,-1452 # 80004460 <uart_tx_w>
    80002a14:	00063783          	ld	a5,0(a2)
    80002a18:	00053703          	ld	a4,0(a0)
    80002a1c:	04f70263          	beq	a4,a5,80002a60 <uartintr+0x110>
    80002a20:	100005b7          	lui	a1,0x10000
    80002a24:	00003817          	auipc	a6,0x3
    80002a28:	c7c80813          	addi	a6,a6,-900 # 800056a0 <uart_tx_buf>
    80002a2c:	01c0006f          	j	80002a48 <uartintr+0xf8>
    80002a30:	0006c703          	lbu	a4,0(a3)
    80002a34:	00f63023          	sd	a5,0(a2)
    80002a38:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    80002a3c:	00063783          	ld	a5,0(a2)
    80002a40:	00053703          	ld	a4,0(a0)
    80002a44:	02f70063          	beq	a4,a5,80002a64 <uartintr+0x114>
    80002a48:	01f7f713          	andi	a4,a5,31
    80002a4c:	00e806b3          	add	a3,a6,a4
    80002a50:	0055c703          	lbu	a4,5(a1)
    80002a54:	00178793          	addi	a5,a5,1
    80002a58:	02077713          	andi	a4,a4,32
    80002a5c:	fc071ae3          	bnez	a4,80002a30 <uartintr+0xe0>
    80002a60:	00008067          	ret
    80002a64:	00008067          	ret

0000000080002a68 <kinit>:
    80002a68:	fc010113          	addi	sp,sp,-64
    80002a6c:	02913423          	sd	s1,40(sp)
    80002a70:	fffff7b7          	lui	a5,0xfffff
    80002a74:	00004497          	auipc	s1,0x4
    80002a78:	c4b48493          	addi	s1,s1,-949 # 800066bf <end+0xfff>
    80002a7c:	02813823          	sd	s0,48(sp)
    80002a80:	01313c23          	sd	s3,24(sp)
    80002a84:	00f4f4b3          	and	s1,s1,a5
    80002a88:	02113c23          	sd	ra,56(sp)
    80002a8c:	03213023          	sd	s2,32(sp)
    80002a90:	01413823          	sd	s4,16(sp)
    80002a94:	01513423          	sd	s5,8(sp)
    80002a98:	04010413          	addi	s0,sp,64
    80002a9c:	000017b7          	lui	a5,0x1
    80002aa0:	01100993          	li	s3,17
    80002aa4:	00f487b3          	add	a5,s1,a5
    80002aa8:	01b99993          	slli	s3,s3,0x1b
    80002aac:	06f9e063          	bltu	s3,a5,80002b0c <kinit+0xa4>
    80002ab0:	00003a97          	auipc	s5,0x3
    80002ab4:	c10a8a93          	addi	s5,s5,-1008 # 800056c0 <end>
    80002ab8:	0754ec63          	bltu	s1,s5,80002b30 <kinit+0xc8>
    80002abc:	0734fa63          	bgeu	s1,s3,80002b30 <kinit+0xc8>
    80002ac0:	00088a37          	lui	s4,0x88
    80002ac4:	fffa0a13          	addi	s4,s4,-1 # 87fff <_entry-0x7ff78001>
    80002ac8:	00002917          	auipc	s2,0x2
    80002acc:	9a090913          	addi	s2,s2,-1632 # 80004468 <kmem>
    80002ad0:	00ca1a13          	slli	s4,s4,0xc
    80002ad4:	0140006f          	j	80002ae8 <kinit+0x80>
    80002ad8:	000017b7          	lui	a5,0x1
    80002adc:	00f484b3          	add	s1,s1,a5
    80002ae0:	0554e863          	bltu	s1,s5,80002b30 <kinit+0xc8>
    80002ae4:	0534f663          	bgeu	s1,s3,80002b30 <kinit+0xc8>
    80002ae8:	00001637          	lui	a2,0x1
    80002aec:	00100593          	li	a1,1
    80002af0:	00048513          	mv	a0,s1
    80002af4:	00000097          	auipc	ra,0x0
    80002af8:	5e4080e7          	jalr	1508(ra) # 800030d8 <__memset>
    80002afc:	00093783          	ld	a5,0(s2)
    80002b00:	00f4b023          	sd	a5,0(s1)
    80002b04:	00993023          	sd	s1,0(s2)
    80002b08:	fd4498e3          	bne	s1,s4,80002ad8 <kinit+0x70>
    80002b0c:	03813083          	ld	ra,56(sp)
    80002b10:	03013403          	ld	s0,48(sp)
    80002b14:	02813483          	ld	s1,40(sp)
    80002b18:	02013903          	ld	s2,32(sp)
    80002b1c:	01813983          	ld	s3,24(sp)
    80002b20:	01013a03          	ld	s4,16(sp)
    80002b24:	00813a83          	ld	s5,8(sp)
    80002b28:	04010113          	addi	sp,sp,64
    80002b2c:	00008067          	ret
    80002b30:	00001517          	auipc	a0,0x1
    80002b34:	71850513          	addi	a0,a0,1816 # 80004248 <digits+0x18>
    80002b38:	fffff097          	auipc	ra,0xfffff
    80002b3c:	4b4080e7          	jalr	1204(ra) # 80001fec <panic>

0000000080002b40 <freerange>:
    80002b40:	fc010113          	addi	sp,sp,-64
    80002b44:	000017b7          	lui	a5,0x1
    80002b48:	02913423          	sd	s1,40(sp)
    80002b4c:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80002b50:	009504b3          	add	s1,a0,s1
    80002b54:	fffff537          	lui	a0,0xfffff
    80002b58:	02813823          	sd	s0,48(sp)
    80002b5c:	02113c23          	sd	ra,56(sp)
    80002b60:	03213023          	sd	s2,32(sp)
    80002b64:	01313c23          	sd	s3,24(sp)
    80002b68:	01413823          	sd	s4,16(sp)
    80002b6c:	01513423          	sd	s5,8(sp)
    80002b70:	01613023          	sd	s6,0(sp)
    80002b74:	04010413          	addi	s0,sp,64
    80002b78:	00a4f4b3          	and	s1,s1,a0
    80002b7c:	00f487b3          	add	a5,s1,a5
    80002b80:	06f5e463          	bltu	a1,a5,80002be8 <freerange+0xa8>
    80002b84:	00003a97          	auipc	s5,0x3
    80002b88:	b3ca8a93          	addi	s5,s5,-1220 # 800056c0 <end>
    80002b8c:	0954e263          	bltu	s1,s5,80002c10 <freerange+0xd0>
    80002b90:	01100993          	li	s3,17
    80002b94:	01b99993          	slli	s3,s3,0x1b
    80002b98:	0734fc63          	bgeu	s1,s3,80002c10 <freerange+0xd0>
    80002b9c:	00058a13          	mv	s4,a1
    80002ba0:	00002917          	auipc	s2,0x2
    80002ba4:	8c890913          	addi	s2,s2,-1848 # 80004468 <kmem>
    80002ba8:	00002b37          	lui	s6,0x2
    80002bac:	0140006f          	j	80002bc0 <freerange+0x80>
    80002bb0:	000017b7          	lui	a5,0x1
    80002bb4:	00f484b3          	add	s1,s1,a5
    80002bb8:	0554ec63          	bltu	s1,s5,80002c10 <freerange+0xd0>
    80002bbc:	0534fa63          	bgeu	s1,s3,80002c10 <freerange+0xd0>
    80002bc0:	00001637          	lui	a2,0x1
    80002bc4:	00100593          	li	a1,1
    80002bc8:	00048513          	mv	a0,s1
    80002bcc:	00000097          	auipc	ra,0x0
    80002bd0:	50c080e7          	jalr	1292(ra) # 800030d8 <__memset>
    80002bd4:	00093703          	ld	a4,0(s2)
    80002bd8:	016487b3          	add	a5,s1,s6
    80002bdc:	00e4b023          	sd	a4,0(s1)
    80002be0:	00993023          	sd	s1,0(s2)
    80002be4:	fcfa76e3          	bgeu	s4,a5,80002bb0 <freerange+0x70>
    80002be8:	03813083          	ld	ra,56(sp)
    80002bec:	03013403          	ld	s0,48(sp)
    80002bf0:	02813483          	ld	s1,40(sp)
    80002bf4:	02013903          	ld	s2,32(sp)
    80002bf8:	01813983          	ld	s3,24(sp)
    80002bfc:	01013a03          	ld	s4,16(sp)
    80002c00:	00813a83          	ld	s5,8(sp)
    80002c04:	00013b03          	ld	s6,0(sp)
    80002c08:	04010113          	addi	sp,sp,64
    80002c0c:	00008067          	ret
    80002c10:	00001517          	auipc	a0,0x1
    80002c14:	63850513          	addi	a0,a0,1592 # 80004248 <digits+0x18>
    80002c18:	fffff097          	auipc	ra,0xfffff
    80002c1c:	3d4080e7          	jalr	980(ra) # 80001fec <panic>

0000000080002c20 <kfree>:
    80002c20:	fe010113          	addi	sp,sp,-32
    80002c24:	00813823          	sd	s0,16(sp)
    80002c28:	00113c23          	sd	ra,24(sp)
    80002c2c:	00913423          	sd	s1,8(sp)
    80002c30:	02010413          	addi	s0,sp,32
    80002c34:	03451793          	slli	a5,a0,0x34
    80002c38:	04079c63          	bnez	a5,80002c90 <kfree+0x70>
    80002c3c:	00003797          	auipc	a5,0x3
    80002c40:	a8478793          	addi	a5,a5,-1404 # 800056c0 <end>
    80002c44:	00050493          	mv	s1,a0
    80002c48:	04f56463          	bltu	a0,a5,80002c90 <kfree+0x70>
    80002c4c:	01100793          	li	a5,17
    80002c50:	01b79793          	slli	a5,a5,0x1b
    80002c54:	02f57e63          	bgeu	a0,a5,80002c90 <kfree+0x70>
    80002c58:	00001637          	lui	a2,0x1
    80002c5c:	00100593          	li	a1,1
    80002c60:	00000097          	auipc	ra,0x0
    80002c64:	478080e7          	jalr	1144(ra) # 800030d8 <__memset>
    80002c68:	00002797          	auipc	a5,0x2
    80002c6c:	80078793          	addi	a5,a5,-2048 # 80004468 <kmem>
    80002c70:	0007b703          	ld	a4,0(a5)
    80002c74:	01813083          	ld	ra,24(sp)
    80002c78:	01013403          	ld	s0,16(sp)
    80002c7c:	00e4b023          	sd	a4,0(s1)
    80002c80:	0097b023          	sd	s1,0(a5)
    80002c84:	00813483          	ld	s1,8(sp)
    80002c88:	02010113          	addi	sp,sp,32
    80002c8c:	00008067          	ret
    80002c90:	00001517          	auipc	a0,0x1
    80002c94:	5b850513          	addi	a0,a0,1464 # 80004248 <digits+0x18>
    80002c98:	fffff097          	auipc	ra,0xfffff
    80002c9c:	354080e7          	jalr	852(ra) # 80001fec <panic>

0000000080002ca0 <kalloc>:
    80002ca0:	fe010113          	addi	sp,sp,-32
    80002ca4:	00813823          	sd	s0,16(sp)
    80002ca8:	00913423          	sd	s1,8(sp)
    80002cac:	00113c23          	sd	ra,24(sp)
    80002cb0:	02010413          	addi	s0,sp,32
    80002cb4:	00001797          	auipc	a5,0x1
    80002cb8:	7b478793          	addi	a5,a5,1972 # 80004468 <kmem>
    80002cbc:	0007b483          	ld	s1,0(a5)
    80002cc0:	02048063          	beqz	s1,80002ce0 <kalloc+0x40>
    80002cc4:	0004b703          	ld	a4,0(s1)
    80002cc8:	00001637          	lui	a2,0x1
    80002ccc:	00500593          	li	a1,5
    80002cd0:	00048513          	mv	a0,s1
    80002cd4:	00e7b023          	sd	a4,0(a5)
    80002cd8:	00000097          	auipc	ra,0x0
    80002cdc:	400080e7          	jalr	1024(ra) # 800030d8 <__memset>
    80002ce0:	01813083          	ld	ra,24(sp)
    80002ce4:	01013403          	ld	s0,16(sp)
    80002ce8:	00048513          	mv	a0,s1
    80002cec:	00813483          	ld	s1,8(sp)
    80002cf0:	02010113          	addi	sp,sp,32
    80002cf4:	00008067          	ret

0000000080002cf8 <initlock>:
    80002cf8:	ff010113          	addi	sp,sp,-16
    80002cfc:	00813423          	sd	s0,8(sp)
    80002d00:	01010413          	addi	s0,sp,16
    80002d04:	00813403          	ld	s0,8(sp)
    80002d08:	00b53423          	sd	a1,8(a0)
    80002d0c:	00052023          	sw	zero,0(a0)
    80002d10:	00053823          	sd	zero,16(a0)
    80002d14:	01010113          	addi	sp,sp,16
    80002d18:	00008067          	ret

0000000080002d1c <acquire>:
    80002d1c:	fe010113          	addi	sp,sp,-32
    80002d20:	00813823          	sd	s0,16(sp)
    80002d24:	00913423          	sd	s1,8(sp)
    80002d28:	00113c23          	sd	ra,24(sp)
    80002d2c:	01213023          	sd	s2,0(sp)
    80002d30:	02010413          	addi	s0,sp,32
    80002d34:	00050493          	mv	s1,a0
    80002d38:	10002973          	csrr	s2,sstatus
    80002d3c:	100027f3          	csrr	a5,sstatus
    80002d40:	ffd7f793          	andi	a5,a5,-3
    80002d44:	10079073          	csrw	sstatus,a5
    80002d48:	fffff097          	auipc	ra,0xfffff
    80002d4c:	8e8080e7          	jalr	-1816(ra) # 80001630 <mycpu>
    80002d50:	07852783          	lw	a5,120(a0)
    80002d54:	06078e63          	beqz	a5,80002dd0 <acquire+0xb4>
    80002d58:	fffff097          	auipc	ra,0xfffff
    80002d5c:	8d8080e7          	jalr	-1832(ra) # 80001630 <mycpu>
    80002d60:	07852783          	lw	a5,120(a0)
    80002d64:	0004a703          	lw	a4,0(s1)
    80002d68:	0017879b          	addiw	a5,a5,1
    80002d6c:	06f52c23          	sw	a5,120(a0)
    80002d70:	04071063          	bnez	a4,80002db0 <acquire+0x94>
    80002d74:	00100713          	li	a4,1
    80002d78:	00070793          	mv	a5,a4
    80002d7c:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80002d80:	0007879b          	sext.w	a5,a5
    80002d84:	fe079ae3          	bnez	a5,80002d78 <acquire+0x5c>
    80002d88:	0ff0000f          	fence
    80002d8c:	fffff097          	auipc	ra,0xfffff
    80002d90:	8a4080e7          	jalr	-1884(ra) # 80001630 <mycpu>
    80002d94:	01813083          	ld	ra,24(sp)
    80002d98:	01013403          	ld	s0,16(sp)
    80002d9c:	00a4b823          	sd	a0,16(s1)
    80002da0:	00013903          	ld	s2,0(sp)
    80002da4:	00813483          	ld	s1,8(sp)
    80002da8:	02010113          	addi	sp,sp,32
    80002dac:	00008067          	ret
    80002db0:	0104b903          	ld	s2,16(s1)
    80002db4:	fffff097          	auipc	ra,0xfffff
    80002db8:	87c080e7          	jalr	-1924(ra) # 80001630 <mycpu>
    80002dbc:	faa91ce3          	bne	s2,a0,80002d74 <acquire+0x58>
    80002dc0:	00001517          	auipc	a0,0x1
    80002dc4:	49050513          	addi	a0,a0,1168 # 80004250 <digits+0x20>
    80002dc8:	fffff097          	auipc	ra,0xfffff
    80002dcc:	224080e7          	jalr	548(ra) # 80001fec <panic>
    80002dd0:	00195913          	srli	s2,s2,0x1
    80002dd4:	fffff097          	auipc	ra,0xfffff
    80002dd8:	85c080e7          	jalr	-1956(ra) # 80001630 <mycpu>
    80002ddc:	00197913          	andi	s2,s2,1
    80002de0:	07252e23          	sw	s2,124(a0)
    80002de4:	f75ff06f          	j	80002d58 <acquire+0x3c>

0000000080002de8 <release>:
    80002de8:	fe010113          	addi	sp,sp,-32
    80002dec:	00813823          	sd	s0,16(sp)
    80002df0:	00113c23          	sd	ra,24(sp)
    80002df4:	00913423          	sd	s1,8(sp)
    80002df8:	01213023          	sd	s2,0(sp)
    80002dfc:	02010413          	addi	s0,sp,32
    80002e00:	00052783          	lw	a5,0(a0)
    80002e04:	00079a63          	bnez	a5,80002e18 <release+0x30>
    80002e08:	00001517          	auipc	a0,0x1
    80002e0c:	45050513          	addi	a0,a0,1104 # 80004258 <digits+0x28>
    80002e10:	fffff097          	auipc	ra,0xfffff
    80002e14:	1dc080e7          	jalr	476(ra) # 80001fec <panic>
    80002e18:	01053903          	ld	s2,16(a0)
    80002e1c:	00050493          	mv	s1,a0
    80002e20:	fffff097          	auipc	ra,0xfffff
    80002e24:	810080e7          	jalr	-2032(ra) # 80001630 <mycpu>
    80002e28:	fea910e3          	bne	s2,a0,80002e08 <release+0x20>
    80002e2c:	0004b823          	sd	zero,16(s1)
    80002e30:	0ff0000f          	fence
    80002e34:	0f50000f          	fence	iorw,ow
    80002e38:	0804a02f          	amoswap.w	zero,zero,(s1)
    80002e3c:	ffffe097          	auipc	ra,0xffffe
    80002e40:	7f4080e7          	jalr	2036(ra) # 80001630 <mycpu>
    80002e44:	100027f3          	csrr	a5,sstatus
    80002e48:	0027f793          	andi	a5,a5,2
    80002e4c:	04079a63          	bnez	a5,80002ea0 <release+0xb8>
    80002e50:	07852783          	lw	a5,120(a0)
    80002e54:	02f05e63          	blez	a5,80002e90 <release+0xa8>
    80002e58:	fff7871b          	addiw	a4,a5,-1
    80002e5c:	06e52c23          	sw	a4,120(a0)
    80002e60:	00071c63          	bnez	a4,80002e78 <release+0x90>
    80002e64:	07c52783          	lw	a5,124(a0)
    80002e68:	00078863          	beqz	a5,80002e78 <release+0x90>
    80002e6c:	100027f3          	csrr	a5,sstatus
    80002e70:	0027e793          	ori	a5,a5,2
    80002e74:	10079073          	csrw	sstatus,a5
    80002e78:	01813083          	ld	ra,24(sp)
    80002e7c:	01013403          	ld	s0,16(sp)
    80002e80:	00813483          	ld	s1,8(sp)
    80002e84:	00013903          	ld	s2,0(sp)
    80002e88:	02010113          	addi	sp,sp,32
    80002e8c:	00008067          	ret
    80002e90:	00001517          	auipc	a0,0x1
    80002e94:	3e850513          	addi	a0,a0,1000 # 80004278 <digits+0x48>
    80002e98:	fffff097          	auipc	ra,0xfffff
    80002e9c:	154080e7          	jalr	340(ra) # 80001fec <panic>
    80002ea0:	00001517          	auipc	a0,0x1
    80002ea4:	3c050513          	addi	a0,a0,960 # 80004260 <digits+0x30>
    80002ea8:	fffff097          	auipc	ra,0xfffff
    80002eac:	144080e7          	jalr	324(ra) # 80001fec <panic>

0000000080002eb0 <holding>:
    80002eb0:	00052783          	lw	a5,0(a0)
    80002eb4:	00079663          	bnez	a5,80002ec0 <holding+0x10>
    80002eb8:	00000513          	li	a0,0
    80002ebc:	00008067          	ret
    80002ec0:	fe010113          	addi	sp,sp,-32
    80002ec4:	00813823          	sd	s0,16(sp)
    80002ec8:	00913423          	sd	s1,8(sp)
    80002ecc:	00113c23          	sd	ra,24(sp)
    80002ed0:	02010413          	addi	s0,sp,32
    80002ed4:	01053483          	ld	s1,16(a0)
    80002ed8:	ffffe097          	auipc	ra,0xffffe
    80002edc:	758080e7          	jalr	1880(ra) # 80001630 <mycpu>
    80002ee0:	01813083          	ld	ra,24(sp)
    80002ee4:	01013403          	ld	s0,16(sp)
    80002ee8:	40a48533          	sub	a0,s1,a0
    80002eec:	00153513          	seqz	a0,a0
    80002ef0:	00813483          	ld	s1,8(sp)
    80002ef4:	02010113          	addi	sp,sp,32
    80002ef8:	00008067          	ret

0000000080002efc <push_off>:
    80002efc:	fe010113          	addi	sp,sp,-32
    80002f00:	00813823          	sd	s0,16(sp)
    80002f04:	00113c23          	sd	ra,24(sp)
    80002f08:	00913423          	sd	s1,8(sp)
    80002f0c:	02010413          	addi	s0,sp,32
    80002f10:	100024f3          	csrr	s1,sstatus
    80002f14:	100027f3          	csrr	a5,sstatus
    80002f18:	ffd7f793          	andi	a5,a5,-3
    80002f1c:	10079073          	csrw	sstatus,a5
    80002f20:	ffffe097          	auipc	ra,0xffffe
    80002f24:	710080e7          	jalr	1808(ra) # 80001630 <mycpu>
    80002f28:	07852783          	lw	a5,120(a0)
    80002f2c:	02078663          	beqz	a5,80002f58 <push_off+0x5c>
    80002f30:	ffffe097          	auipc	ra,0xffffe
    80002f34:	700080e7          	jalr	1792(ra) # 80001630 <mycpu>
    80002f38:	07852783          	lw	a5,120(a0)
    80002f3c:	01813083          	ld	ra,24(sp)
    80002f40:	01013403          	ld	s0,16(sp)
    80002f44:	0017879b          	addiw	a5,a5,1
    80002f48:	06f52c23          	sw	a5,120(a0)
    80002f4c:	00813483          	ld	s1,8(sp)
    80002f50:	02010113          	addi	sp,sp,32
    80002f54:	00008067          	ret
    80002f58:	0014d493          	srli	s1,s1,0x1
    80002f5c:	ffffe097          	auipc	ra,0xffffe
    80002f60:	6d4080e7          	jalr	1748(ra) # 80001630 <mycpu>
    80002f64:	0014f493          	andi	s1,s1,1
    80002f68:	06952e23          	sw	s1,124(a0)
    80002f6c:	fc5ff06f          	j	80002f30 <push_off+0x34>

0000000080002f70 <pop_off>:
    80002f70:	ff010113          	addi	sp,sp,-16
    80002f74:	00813023          	sd	s0,0(sp)
    80002f78:	00113423          	sd	ra,8(sp)
    80002f7c:	01010413          	addi	s0,sp,16
    80002f80:	ffffe097          	auipc	ra,0xffffe
    80002f84:	6b0080e7          	jalr	1712(ra) # 80001630 <mycpu>
    80002f88:	100027f3          	csrr	a5,sstatus
    80002f8c:	0027f793          	andi	a5,a5,2
    80002f90:	04079663          	bnez	a5,80002fdc <pop_off+0x6c>
    80002f94:	07852783          	lw	a5,120(a0)
    80002f98:	02f05a63          	blez	a5,80002fcc <pop_off+0x5c>
    80002f9c:	fff7871b          	addiw	a4,a5,-1
    80002fa0:	06e52c23          	sw	a4,120(a0)
    80002fa4:	00071c63          	bnez	a4,80002fbc <pop_off+0x4c>
    80002fa8:	07c52783          	lw	a5,124(a0)
    80002fac:	00078863          	beqz	a5,80002fbc <pop_off+0x4c>
    80002fb0:	100027f3          	csrr	a5,sstatus
    80002fb4:	0027e793          	ori	a5,a5,2
    80002fb8:	10079073          	csrw	sstatus,a5
    80002fbc:	00813083          	ld	ra,8(sp)
    80002fc0:	00013403          	ld	s0,0(sp)
    80002fc4:	01010113          	addi	sp,sp,16
    80002fc8:	00008067          	ret
    80002fcc:	00001517          	auipc	a0,0x1
    80002fd0:	2ac50513          	addi	a0,a0,684 # 80004278 <digits+0x48>
    80002fd4:	fffff097          	auipc	ra,0xfffff
    80002fd8:	018080e7          	jalr	24(ra) # 80001fec <panic>
    80002fdc:	00001517          	auipc	a0,0x1
    80002fe0:	28450513          	addi	a0,a0,644 # 80004260 <digits+0x30>
    80002fe4:	fffff097          	auipc	ra,0xfffff
    80002fe8:	008080e7          	jalr	8(ra) # 80001fec <panic>

0000000080002fec <push_on>:
    80002fec:	fe010113          	addi	sp,sp,-32
    80002ff0:	00813823          	sd	s0,16(sp)
    80002ff4:	00113c23          	sd	ra,24(sp)
    80002ff8:	00913423          	sd	s1,8(sp)
    80002ffc:	02010413          	addi	s0,sp,32
    80003000:	100024f3          	csrr	s1,sstatus
    80003004:	100027f3          	csrr	a5,sstatus
    80003008:	0027e793          	ori	a5,a5,2
    8000300c:	10079073          	csrw	sstatus,a5
    80003010:	ffffe097          	auipc	ra,0xffffe
    80003014:	620080e7          	jalr	1568(ra) # 80001630 <mycpu>
    80003018:	07852783          	lw	a5,120(a0)
    8000301c:	02078663          	beqz	a5,80003048 <push_on+0x5c>
    80003020:	ffffe097          	auipc	ra,0xffffe
    80003024:	610080e7          	jalr	1552(ra) # 80001630 <mycpu>
    80003028:	07852783          	lw	a5,120(a0)
    8000302c:	01813083          	ld	ra,24(sp)
    80003030:	01013403          	ld	s0,16(sp)
    80003034:	0017879b          	addiw	a5,a5,1
    80003038:	06f52c23          	sw	a5,120(a0)
    8000303c:	00813483          	ld	s1,8(sp)
    80003040:	02010113          	addi	sp,sp,32
    80003044:	00008067          	ret
    80003048:	0014d493          	srli	s1,s1,0x1
    8000304c:	ffffe097          	auipc	ra,0xffffe
    80003050:	5e4080e7          	jalr	1508(ra) # 80001630 <mycpu>
    80003054:	0014f493          	andi	s1,s1,1
    80003058:	06952e23          	sw	s1,124(a0)
    8000305c:	fc5ff06f          	j	80003020 <push_on+0x34>

0000000080003060 <pop_on>:
    80003060:	ff010113          	addi	sp,sp,-16
    80003064:	00813023          	sd	s0,0(sp)
    80003068:	00113423          	sd	ra,8(sp)
    8000306c:	01010413          	addi	s0,sp,16
    80003070:	ffffe097          	auipc	ra,0xffffe
    80003074:	5c0080e7          	jalr	1472(ra) # 80001630 <mycpu>
    80003078:	100027f3          	csrr	a5,sstatus
    8000307c:	0027f793          	andi	a5,a5,2
    80003080:	04078463          	beqz	a5,800030c8 <pop_on+0x68>
    80003084:	07852783          	lw	a5,120(a0)
    80003088:	02f05863          	blez	a5,800030b8 <pop_on+0x58>
    8000308c:	fff7879b          	addiw	a5,a5,-1
    80003090:	06f52c23          	sw	a5,120(a0)
    80003094:	07853783          	ld	a5,120(a0)
    80003098:	00079863          	bnez	a5,800030a8 <pop_on+0x48>
    8000309c:	100027f3          	csrr	a5,sstatus
    800030a0:	ffd7f793          	andi	a5,a5,-3
    800030a4:	10079073          	csrw	sstatus,a5
    800030a8:	00813083          	ld	ra,8(sp)
    800030ac:	00013403          	ld	s0,0(sp)
    800030b0:	01010113          	addi	sp,sp,16
    800030b4:	00008067          	ret
    800030b8:	00001517          	auipc	a0,0x1
    800030bc:	1e850513          	addi	a0,a0,488 # 800042a0 <digits+0x70>
    800030c0:	fffff097          	auipc	ra,0xfffff
    800030c4:	f2c080e7          	jalr	-212(ra) # 80001fec <panic>
    800030c8:	00001517          	auipc	a0,0x1
    800030cc:	1b850513          	addi	a0,a0,440 # 80004280 <digits+0x50>
    800030d0:	fffff097          	auipc	ra,0xfffff
    800030d4:	f1c080e7          	jalr	-228(ra) # 80001fec <panic>

00000000800030d8 <__memset>:
    800030d8:	ff010113          	addi	sp,sp,-16
    800030dc:	00813423          	sd	s0,8(sp)
    800030e0:	01010413          	addi	s0,sp,16
    800030e4:	1a060e63          	beqz	a2,800032a0 <__memset+0x1c8>
    800030e8:	40a007b3          	neg	a5,a0
    800030ec:	0077f793          	andi	a5,a5,7
    800030f0:	00778693          	addi	a3,a5,7
    800030f4:	00b00813          	li	a6,11
    800030f8:	0ff5f593          	andi	a1,a1,255
    800030fc:	fff6071b          	addiw	a4,a2,-1
    80003100:	1b06e663          	bltu	a3,a6,800032ac <__memset+0x1d4>
    80003104:	1cd76463          	bltu	a4,a3,800032cc <__memset+0x1f4>
    80003108:	1a078e63          	beqz	a5,800032c4 <__memset+0x1ec>
    8000310c:	00b50023          	sb	a1,0(a0)
    80003110:	00100713          	li	a4,1
    80003114:	1ae78463          	beq	a5,a4,800032bc <__memset+0x1e4>
    80003118:	00b500a3          	sb	a1,1(a0)
    8000311c:	00200713          	li	a4,2
    80003120:	1ae78a63          	beq	a5,a4,800032d4 <__memset+0x1fc>
    80003124:	00b50123          	sb	a1,2(a0)
    80003128:	00300713          	li	a4,3
    8000312c:	18e78463          	beq	a5,a4,800032b4 <__memset+0x1dc>
    80003130:	00b501a3          	sb	a1,3(a0)
    80003134:	00400713          	li	a4,4
    80003138:	1ae78263          	beq	a5,a4,800032dc <__memset+0x204>
    8000313c:	00b50223          	sb	a1,4(a0)
    80003140:	00500713          	li	a4,5
    80003144:	1ae78063          	beq	a5,a4,800032e4 <__memset+0x20c>
    80003148:	00b502a3          	sb	a1,5(a0)
    8000314c:	00700713          	li	a4,7
    80003150:	18e79e63          	bne	a5,a4,800032ec <__memset+0x214>
    80003154:	00b50323          	sb	a1,6(a0)
    80003158:	00700e93          	li	t4,7
    8000315c:	00859713          	slli	a4,a1,0x8
    80003160:	00e5e733          	or	a4,a1,a4
    80003164:	01059e13          	slli	t3,a1,0x10
    80003168:	01c76e33          	or	t3,a4,t3
    8000316c:	01859313          	slli	t1,a1,0x18
    80003170:	006e6333          	or	t1,t3,t1
    80003174:	02059893          	slli	a7,a1,0x20
    80003178:	40f60e3b          	subw	t3,a2,a5
    8000317c:	011368b3          	or	a7,t1,a7
    80003180:	02859813          	slli	a6,a1,0x28
    80003184:	0108e833          	or	a6,a7,a6
    80003188:	03059693          	slli	a3,a1,0x30
    8000318c:	003e589b          	srliw	a7,t3,0x3
    80003190:	00d866b3          	or	a3,a6,a3
    80003194:	03859713          	slli	a4,a1,0x38
    80003198:	00389813          	slli	a6,a7,0x3
    8000319c:	00f507b3          	add	a5,a0,a5
    800031a0:	00e6e733          	or	a4,a3,a4
    800031a4:	000e089b          	sext.w	a7,t3
    800031a8:	00f806b3          	add	a3,a6,a5
    800031ac:	00e7b023          	sd	a4,0(a5)
    800031b0:	00878793          	addi	a5,a5,8
    800031b4:	fed79ce3          	bne	a5,a3,800031ac <__memset+0xd4>
    800031b8:	ff8e7793          	andi	a5,t3,-8
    800031bc:	0007871b          	sext.w	a4,a5
    800031c0:	01d787bb          	addw	a5,a5,t4
    800031c4:	0ce88e63          	beq	a7,a4,800032a0 <__memset+0x1c8>
    800031c8:	00f50733          	add	a4,a0,a5
    800031cc:	00b70023          	sb	a1,0(a4)
    800031d0:	0017871b          	addiw	a4,a5,1
    800031d4:	0cc77663          	bgeu	a4,a2,800032a0 <__memset+0x1c8>
    800031d8:	00e50733          	add	a4,a0,a4
    800031dc:	00b70023          	sb	a1,0(a4)
    800031e0:	0027871b          	addiw	a4,a5,2
    800031e4:	0ac77e63          	bgeu	a4,a2,800032a0 <__memset+0x1c8>
    800031e8:	00e50733          	add	a4,a0,a4
    800031ec:	00b70023          	sb	a1,0(a4)
    800031f0:	0037871b          	addiw	a4,a5,3
    800031f4:	0ac77663          	bgeu	a4,a2,800032a0 <__memset+0x1c8>
    800031f8:	00e50733          	add	a4,a0,a4
    800031fc:	00b70023          	sb	a1,0(a4)
    80003200:	0047871b          	addiw	a4,a5,4
    80003204:	08c77e63          	bgeu	a4,a2,800032a0 <__memset+0x1c8>
    80003208:	00e50733          	add	a4,a0,a4
    8000320c:	00b70023          	sb	a1,0(a4)
    80003210:	0057871b          	addiw	a4,a5,5
    80003214:	08c77663          	bgeu	a4,a2,800032a0 <__memset+0x1c8>
    80003218:	00e50733          	add	a4,a0,a4
    8000321c:	00b70023          	sb	a1,0(a4)
    80003220:	0067871b          	addiw	a4,a5,6
    80003224:	06c77e63          	bgeu	a4,a2,800032a0 <__memset+0x1c8>
    80003228:	00e50733          	add	a4,a0,a4
    8000322c:	00b70023          	sb	a1,0(a4)
    80003230:	0077871b          	addiw	a4,a5,7
    80003234:	06c77663          	bgeu	a4,a2,800032a0 <__memset+0x1c8>
    80003238:	00e50733          	add	a4,a0,a4
    8000323c:	00b70023          	sb	a1,0(a4)
    80003240:	0087871b          	addiw	a4,a5,8
    80003244:	04c77e63          	bgeu	a4,a2,800032a0 <__memset+0x1c8>
    80003248:	00e50733          	add	a4,a0,a4
    8000324c:	00b70023          	sb	a1,0(a4)
    80003250:	0097871b          	addiw	a4,a5,9
    80003254:	04c77663          	bgeu	a4,a2,800032a0 <__memset+0x1c8>
    80003258:	00e50733          	add	a4,a0,a4
    8000325c:	00b70023          	sb	a1,0(a4)
    80003260:	00a7871b          	addiw	a4,a5,10
    80003264:	02c77e63          	bgeu	a4,a2,800032a0 <__memset+0x1c8>
    80003268:	00e50733          	add	a4,a0,a4
    8000326c:	00b70023          	sb	a1,0(a4)
    80003270:	00b7871b          	addiw	a4,a5,11
    80003274:	02c77663          	bgeu	a4,a2,800032a0 <__memset+0x1c8>
    80003278:	00e50733          	add	a4,a0,a4
    8000327c:	00b70023          	sb	a1,0(a4)
    80003280:	00c7871b          	addiw	a4,a5,12
    80003284:	00c77e63          	bgeu	a4,a2,800032a0 <__memset+0x1c8>
    80003288:	00e50733          	add	a4,a0,a4
    8000328c:	00b70023          	sb	a1,0(a4)
    80003290:	00d7879b          	addiw	a5,a5,13
    80003294:	00c7f663          	bgeu	a5,a2,800032a0 <__memset+0x1c8>
    80003298:	00f507b3          	add	a5,a0,a5
    8000329c:	00b78023          	sb	a1,0(a5)
    800032a0:	00813403          	ld	s0,8(sp)
    800032a4:	01010113          	addi	sp,sp,16
    800032a8:	00008067          	ret
    800032ac:	00b00693          	li	a3,11
    800032b0:	e55ff06f          	j	80003104 <__memset+0x2c>
    800032b4:	00300e93          	li	t4,3
    800032b8:	ea5ff06f          	j	8000315c <__memset+0x84>
    800032bc:	00100e93          	li	t4,1
    800032c0:	e9dff06f          	j	8000315c <__memset+0x84>
    800032c4:	00000e93          	li	t4,0
    800032c8:	e95ff06f          	j	8000315c <__memset+0x84>
    800032cc:	00000793          	li	a5,0
    800032d0:	ef9ff06f          	j	800031c8 <__memset+0xf0>
    800032d4:	00200e93          	li	t4,2
    800032d8:	e85ff06f          	j	8000315c <__memset+0x84>
    800032dc:	00400e93          	li	t4,4
    800032e0:	e7dff06f          	j	8000315c <__memset+0x84>
    800032e4:	00500e93          	li	t4,5
    800032e8:	e75ff06f          	j	8000315c <__memset+0x84>
    800032ec:	00600e93          	li	t4,6
    800032f0:	e6dff06f          	j	8000315c <__memset+0x84>

00000000800032f4 <__memmove>:
    800032f4:	ff010113          	addi	sp,sp,-16
    800032f8:	00813423          	sd	s0,8(sp)
    800032fc:	01010413          	addi	s0,sp,16
    80003300:	0e060863          	beqz	a2,800033f0 <__memmove+0xfc>
    80003304:	fff6069b          	addiw	a3,a2,-1
    80003308:	0006881b          	sext.w	a6,a3
    8000330c:	0ea5e863          	bltu	a1,a0,800033fc <__memmove+0x108>
    80003310:	00758713          	addi	a4,a1,7
    80003314:	00a5e7b3          	or	a5,a1,a0
    80003318:	40a70733          	sub	a4,a4,a0
    8000331c:	0077f793          	andi	a5,a5,7
    80003320:	00f73713          	sltiu	a4,a4,15
    80003324:	00174713          	xori	a4,a4,1
    80003328:	0017b793          	seqz	a5,a5
    8000332c:	00e7f7b3          	and	a5,a5,a4
    80003330:	10078863          	beqz	a5,80003440 <__memmove+0x14c>
    80003334:	00900793          	li	a5,9
    80003338:	1107f463          	bgeu	a5,a6,80003440 <__memmove+0x14c>
    8000333c:	0036581b          	srliw	a6,a2,0x3
    80003340:	fff8081b          	addiw	a6,a6,-1
    80003344:	02081813          	slli	a6,a6,0x20
    80003348:	01d85893          	srli	a7,a6,0x1d
    8000334c:	00858813          	addi	a6,a1,8
    80003350:	00058793          	mv	a5,a1
    80003354:	00050713          	mv	a4,a0
    80003358:	01088833          	add	a6,a7,a6
    8000335c:	0007b883          	ld	a7,0(a5)
    80003360:	00878793          	addi	a5,a5,8
    80003364:	00870713          	addi	a4,a4,8
    80003368:	ff173c23          	sd	a7,-8(a4)
    8000336c:	ff0798e3          	bne	a5,a6,8000335c <__memmove+0x68>
    80003370:	ff867713          	andi	a4,a2,-8
    80003374:	02071793          	slli	a5,a4,0x20
    80003378:	0207d793          	srli	a5,a5,0x20
    8000337c:	00f585b3          	add	a1,a1,a5
    80003380:	40e686bb          	subw	a3,a3,a4
    80003384:	00f507b3          	add	a5,a0,a5
    80003388:	06e60463          	beq	a2,a4,800033f0 <__memmove+0xfc>
    8000338c:	0005c703          	lbu	a4,0(a1)
    80003390:	00e78023          	sb	a4,0(a5)
    80003394:	04068e63          	beqz	a3,800033f0 <__memmove+0xfc>
    80003398:	0015c603          	lbu	a2,1(a1)
    8000339c:	00100713          	li	a4,1
    800033a0:	00c780a3          	sb	a2,1(a5)
    800033a4:	04e68663          	beq	a3,a4,800033f0 <__memmove+0xfc>
    800033a8:	0025c603          	lbu	a2,2(a1)
    800033ac:	00200713          	li	a4,2
    800033b0:	00c78123          	sb	a2,2(a5)
    800033b4:	02e68e63          	beq	a3,a4,800033f0 <__memmove+0xfc>
    800033b8:	0035c603          	lbu	a2,3(a1)
    800033bc:	00300713          	li	a4,3
    800033c0:	00c781a3          	sb	a2,3(a5)
    800033c4:	02e68663          	beq	a3,a4,800033f0 <__memmove+0xfc>
    800033c8:	0045c603          	lbu	a2,4(a1)
    800033cc:	00400713          	li	a4,4
    800033d0:	00c78223          	sb	a2,4(a5)
    800033d4:	00e68e63          	beq	a3,a4,800033f0 <__memmove+0xfc>
    800033d8:	0055c603          	lbu	a2,5(a1)
    800033dc:	00500713          	li	a4,5
    800033e0:	00c782a3          	sb	a2,5(a5)
    800033e4:	00e68663          	beq	a3,a4,800033f0 <__memmove+0xfc>
    800033e8:	0065c703          	lbu	a4,6(a1)
    800033ec:	00e78323          	sb	a4,6(a5)
    800033f0:	00813403          	ld	s0,8(sp)
    800033f4:	01010113          	addi	sp,sp,16
    800033f8:	00008067          	ret
    800033fc:	02061713          	slli	a4,a2,0x20
    80003400:	02075713          	srli	a4,a4,0x20
    80003404:	00e587b3          	add	a5,a1,a4
    80003408:	f0f574e3          	bgeu	a0,a5,80003310 <__memmove+0x1c>
    8000340c:	02069613          	slli	a2,a3,0x20
    80003410:	02065613          	srli	a2,a2,0x20
    80003414:	fff64613          	not	a2,a2
    80003418:	00e50733          	add	a4,a0,a4
    8000341c:	00c78633          	add	a2,a5,a2
    80003420:	fff7c683          	lbu	a3,-1(a5)
    80003424:	fff78793          	addi	a5,a5,-1
    80003428:	fff70713          	addi	a4,a4,-1
    8000342c:	00d70023          	sb	a3,0(a4)
    80003430:	fec798e3          	bne	a5,a2,80003420 <__memmove+0x12c>
    80003434:	00813403          	ld	s0,8(sp)
    80003438:	01010113          	addi	sp,sp,16
    8000343c:	00008067          	ret
    80003440:	02069713          	slli	a4,a3,0x20
    80003444:	02075713          	srli	a4,a4,0x20
    80003448:	00170713          	addi	a4,a4,1
    8000344c:	00e50733          	add	a4,a0,a4
    80003450:	00050793          	mv	a5,a0
    80003454:	0005c683          	lbu	a3,0(a1)
    80003458:	00178793          	addi	a5,a5,1
    8000345c:	00158593          	addi	a1,a1,1
    80003460:	fed78fa3          	sb	a3,-1(a5)
    80003464:	fee798e3          	bne	a5,a4,80003454 <__memmove+0x160>
    80003468:	f89ff06f          	j	800033f0 <__memmove+0xfc>
	...
