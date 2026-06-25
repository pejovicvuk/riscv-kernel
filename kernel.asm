
kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00004117          	auipc	sp,0x4
    80000004:	34813103          	ld	sp,840(sp) # 80004348 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	00001537          	lui	a0,0x1
    8000000c:	f14025f3          	csrr	a1,mhartid
    80000010:	00158593          	addi	a1,a1,1
    80000014:	02b50533          	mul	a0,a0,a1
    80000018:	00a10133          	add	sp,sp,a0
    8000001c:	158010ef          	jal	ra,80001174 <start>

0000000080000020 <spin>:
    80000020:	0000006f          	j	80000020 <spin>
	...

0000000080001000 <_Z8userMainv>:
// src/userMain.cpp
#include "../h/MemoryAllocator.hpp"
extern void kputs(const char* s);   // defined in main.cpp; same build, so this links

void userMain() {
    80001000:	fe010113          	addi	sp,sp,-32
    80001004:	00113c23          	sd	ra,24(sp)
    80001008:	00813823          	sd	s0,16(sp)
    8000100c:	02010413          	addi	s0,sp,32
    int size = MemoryAllocator::init();
    80001010:	00000097          	auipc	ra,0x0
    80001014:	038080e7          	jalr	56(ra) # 80001048 <_ZN15MemoryAllocator4initEv>
    80001018:	fea42623          	sw	a0,-20(s0)
    kputs("   user: hello from userMain\n");
    8000101c:	00003517          	auipc	a0,0x3
    80001020:	00450513          	addi	a0,a0,4 # 80004020 <CONSOLE_STATUS+0x10>
    80001024:	00000097          	auipc	ra,0x0
    80001028:	0b0080e7          	jalr	176(ra) # 800010d4 <_Z5kputsPKc>
    kputs((char*)&size);
    8000102c:	fec40513          	addi	a0,s0,-20
    80001030:	00000097          	auipc	ra,0x0
    80001034:	0a4080e7          	jalr	164(ra) # 800010d4 <_Z5kputsPKc>
    80001038:	01813083          	ld	ra,24(sp)
    8000103c:	01013403          	ld	s0,16(sp)
    80001040:	02010113          	addi	sp,sp,32
    80001044:	00008067          	ret

0000000080001048 <_ZN15MemoryAllocator4initEv>:
#include "../h/MemoryAllocator.hpp"
#include "../lib/hw.h"

MemoryAllocator::FreeBlock* MemoryAllocator::freeListHead = nullptr;

int MemoryAllocator::init() {
    80001048:	ff010113          	addi	sp,sp,-16
    8000104c:	00813423          	sd	s0,8(sp)
    80001050:	01010413          	addi	s0,sp,16
    freeListHead = (FreeBlock*)HEAP_START_ADDR;
    80001054:	00003717          	auipc	a4,0x3
    80001058:	2e470713          	addi	a4,a4,740 # 80004338 <HEAP_START_ADDR>
    8000105c:	00073683          	ld	a3,0(a4)
    80001060:	00003797          	auipc	a5,0x3
    80001064:	30078793          	addi	a5,a5,768 # 80004360 <_ZN15MemoryAllocator12freeListHeadE>
    80001068:	00d7b023          	sd	a3,0(a5)
    freeListHead->next = nullptr;
    8000106c:	0006b023          	sd	zero,0(a3)
    freeListHead->size = (char*)HEAP_END_ADDR - (char*)HEAP_START_ADDR;
    80001070:	00073703          	ld	a4,0(a4)
    80001074:	0007b783          	ld	a5,0(a5)
    80001078:	00003517          	auipc	a0,0x3
    8000107c:	2b853503          	ld	a0,696(a0) # 80004330 <HEAP_END_ADDR>
    80001080:	40e50533          	sub	a0,a0,a4
    80001084:	00a7b423          	sd	a0,8(a5)
    return freeListHead->size;
    80001088:	0005051b          	sext.w	a0,a0
    8000108c:	00813403          	ld	s0,8(sp)
    80001090:	01010113          	addi	sp,sp,16
    80001094:	00008067          	ret

0000000080001098 <_Z5kputcc>:
#include "../lib/hw.h"   // adjust path to wherever your hw.h lives

// Send one character to the console controller.
void kputc(char c) {
    80001098:	ff010113          	addi	sp,sp,-16
    8000109c:	00813423          	sd	s0,8(sp)
    800010a0:	01010413          	addi	s0,sp,16
    // CONSOLE_STATUS is an address (a constant from hw.h). To read the
    // byte living at that address, we reinterpret the integer address as
    // a pointer-to-volatile-char and dereference it. 'volatile' tells the
    // compiler the value can change outside our code (the hardware sets it),
    // so it must actually re-read memory every loop pass, not cache it.
    while ((*(volatile char*)CONSOLE_STATUS & (1 << 5)) == 0) {
    800010a4:	00003797          	auipc	a5,0x3
    800010a8:	f6c7b783          	ld	a5,-148(a5) # 80004010 <CONSOLE_STATUS>
    800010ac:	0007c783          	lbu	a5,0(a5)
    800010b0:	0ff7f793          	andi	a5,a5,255
    800010b4:	0207f793          	andi	a5,a5,32
    800010b8:	fe0786e3          	beqz	a5,800010a4 <_Z5kputcc+0xc>
        // spin: bit 5 == 0 means "not ready to accept a char to send"
    }
    // Ready. Write the byte into the transmit-data register.
    *(volatile char*)CONSOLE_TX_DATA = c;
    800010bc:	00003797          	auipc	a5,0x3
    800010c0:	f4c7b783          	ld	a5,-180(a5) # 80004008 <CONSOLE_TX_DATA>
    800010c4:	00a78023          	sb	a0,0(a5)
}
    800010c8:	00813403          	ld	s0,8(sp)
    800010cc:	01010113          	addi	sp,sp,16
    800010d0:	00008067          	ret

00000000800010d4 <_Z5kputsPKc>:

// Convenience: print a whole string by sending char by char.
void kputs(const char* s) {
    800010d4:	fe010113          	addi	sp,sp,-32
    800010d8:	00113c23          	sd	ra,24(sp)
    800010dc:	00813823          	sd	s0,16(sp)
    800010e0:	00913423          	sd	s1,8(sp)
    800010e4:	02010413          	addi	s0,sp,32
    800010e8:	00050493          	mv	s1,a0
    while (*s) kputc(*s++);
    800010ec:	0004c503          	lbu	a0,0(s1)
    800010f0:	00050a63          	beqz	a0,80001104 <_Z5kputsPKc+0x30>
    800010f4:	00148493          	addi	s1,s1,1
    800010f8:	00000097          	auipc	ra,0x0
    800010fc:	fa0080e7          	jalr	-96(ra) # 80001098 <_Z5kputcc>
    80001100:	fedff06f          	j	800010ec <_Z5kputsPKc+0x18>
}
    80001104:	01813083          	ld	ra,24(sp)
    80001108:	01013403          	ld	s0,16(sp)
    8000110c:	00813483          	ld	s1,8(sp)
    80001110:	02010113          	addi	sp,sp,32
    80001114:	00008067          	ret

0000000080001118 <main>:

void userMain();   // forward declaration: defined elsewhere (your test file)

int main() {
    80001118:	ff010113          	addi	sp,sp,-16
    8000111c:	00113423          	sd	ra,8(sp)
    80001120:	00813023          	sd	s0,0(sp)
    80001124:	01010413          	addi	s0,sp,16
    kputs(">> kernel: starting\n");
    80001128:	00003517          	auipc	a0,0x3
    8000112c:	f1850513          	addi	a0,a0,-232 # 80004040 <CONSOLE_STATUS+0x30>
    80001130:	00000097          	auipc	ra,0x0
    80001134:	fa4080e7          	jalr	-92(ra) # 800010d4 <_Z5kputsPKc>

    userMain();    // THE CHEAT: calling it as a plain function for now.
    80001138:	00000097          	auipc	ra,0x0
    8000113c:	ec8080e7          	jalr	-312(ra) # 80001000 <_Z8userMainv>
                   // In the real kernel this becomes "wrap userMain as the
                   // body of the first thread and let the scheduler run it."

    kputs(">> kernel: userMain returned, halting\n");
    80001140:	00003517          	auipc	a0,0x3
    80001144:	f1850513          	addi	a0,a0,-232 # 80004058 <CONSOLE_STATUS+0x48>
    80001148:	00000097          	auipc	ra,0x0
    8000114c:	f8c080e7          	jalr	-116(ra) # 800010d4 <_Z5kputsPKc>

    // Halt the emulator: writing the 32-bit value 0x5555 to physical
    // address 0x100000 is qemu's "guest asked to power off" signal, so
    // `make qemu` returns to your shell instead of hanging.
    *(volatile int*)0x100000 = 0x5555;
    80001150:	00100737          	lui	a4,0x100
    80001154:	000057b7          	lui	a5,0x5
    80001158:	5557879b          	addiw	a5,a5,1365
    8000115c:	00f72023          	sw	a5,0(a4) # 100000 <_entry-0x7ff00000>

    return 0;   // never really reached, but keeps the signature honest
    80001160:	00000513          	li	a0,0
    80001164:	00813083          	ld	ra,8(sp)
    80001168:	00013403          	ld	s0,0(sp)
    8000116c:	01010113          	addi	sp,sp,16
    80001170:	00008067          	ret

0000000080001174 <start>:
    80001174:	ff010113          	addi	sp,sp,-16
    80001178:	00813423          	sd	s0,8(sp)
    8000117c:	01010413          	addi	s0,sp,16
    80001180:	300027f3          	csrr	a5,mstatus
    80001184:	ffffe737          	lui	a4,0xffffe
    80001188:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fff921f>
    8000118c:	00e7f7b3          	and	a5,a5,a4
    80001190:	00001737          	lui	a4,0x1
    80001194:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80001198:	00e7e7b3          	or	a5,a5,a4
    8000119c:	30079073          	csrw	mstatus,a5
    800011a0:	00000797          	auipc	a5,0x0
    800011a4:	16078793          	addi	a5,a5,352 # 80001300 <system_main>
    800011a8:	34179073          	csrw	mepc,a5
    800011ac:	00000793          	li	a5,0
    800011b0:	18079073          	csrw	satp,a5
    800011b4:	000107b7          	lui	a5,0x10
    800011b8:	fff78793          	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800011bc:	30279073          	csrw	medeleg,a5
    800011c0:	30379073          	csrw	mideleg,a5
    800011c4:	104027f3          	csrr	a5,sie
    800011c8:	2227e793          	ori	a5,a5,546
    800011cc:	10479073          	csrw	sie,a5
    800011d0:	fff00793          	li	a5,-1
    800011d4:	00a7d793          	srli	a5,a5,0xa
    800011d8:	3b079073          	csrw	pmpaddr0,a5
    800011dc:	00f00793          	li	a5,15
    800011e0:	3a079073          	csrw	pmpcfg0,a5
    800011e4:	f14027f3          	csrr	a5,mhartid
    800011e8:	0200c737          	lui	a4,0x200c
    800011ec:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    800011f0:	0007869b          	sext.w	a3,a5
    800011f4:	00269713          	slli	a4,a3,0x2
    800011f8:	000f4637          	lui	a2,0xf4
    800011fc:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80001200:	00d70733          	add	a4,a4,a3
    80001204:	0037979b          	slliw	a5,a5,0x3
    80001208:	020046b7          	lui	a3,0x2004
    8000120c:	00d787b3          	add	a5,a5,a3
    80001210:	00c585b3          	add	a1,a1,a2
    80001214:	00371693          	slli	a3,a4,0x3
    80001218:	00003717          	auipc	a4,0x3
    8000121c:	17870713          	addi	a4,a4,376 # 80004390 <timer_scratch>
    80001220:	00b7b023          	sd	a1,0(a5)
    80001224:	00d70733          	add	a4,a4,a3
    80001228:	00f73c23          	sd	a5,24(a4)
    8000122c:	02c73023          	sd	a2,32(a4)
    80001230:	34071073          	csrw	mscratch,a4
    80001234:	00000797          	auipc	a5,0x0
    80001238:	6ec78793          	addi	a5,a5,1772 # 80001920 <timervec>
    8000123c:	30579073          	csrw	mtvec,a5
    80001240:	300027f3          	csrr	a5,mstatus
    80001244:	0087e793          	ori	a5,a5,8
    80001248:	30079073          	csrw	mstatus,a5
    8000124c:	304027f3          	csrr	a5,mie
    80001250:	0807e793          	ori	a5,a5,128
    80001254:	30479073          	csrw	mie,a5
    80001258:	f14027f3          	csrr	a5,mhartid
    8000125c:	0007879b          	sext.w	a5,a5
    80001260:	00078213          	mv	tp,a5
    80001264:	30200073          	mret
    80001268:	00813403          	ld	s0,8(sp)
    8000126c:	01010113          	addi	sp,sp,16
    80001270:	00008067          	ret

0000000080001274 <timerinit>:
    80001274:	ff010113          	addi	sp,sp,-16
    80001278:	00813423          	sd	s0,8(sp)
    8000127c:	01010413          	addi	s0,sp,16
    80001280:	f14027f3          	csrr	a5,mhartid
    80001284:	0200c737          	lui	a4,0x200c
    80001288:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000128c:	0007869b          	sext.w	a3,a5
    80001290:	00269713          	slli	a4,a3,0x2
    80001294:	000f4637          	lui	a2,0xf4
    80001298:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    8000129c:	00d70733          	add	a4,a4,a3
    800012a0:	0037979b          	slliw	a5,a5,0x3
    800012a4:	020046b7          	lui	a3,0x2004
    800012a8:	00d787b3          	add	a5,a5,a3
    800012ac:	00c585b3          	add	a1,a1,a2
    800012b0:	00371693          	slli	a3,a4,0x3
    800012b4:	00003717          	auipc	a4,0x3
    800012b8:	0dc70713          	addi	a4,a4,220 # 80004390 <timer_scratch>
    800012bc:	00b7b023          	sd	a1,0(a5)
    800012c0:	00d70733          	add	a4,a4,a3
    800012c4:	00f73c23          	sd	a5,24(a4)
    800012c8:	02c73023          	sd	a2,32(a4)
    800012cc:	34071073          	csrw	mscratch,a4
    800012d0:	00000797          	auipc	a5,0x0
    800012d4:	65078793          	addi	a5,a5,1616 # 80001920 <timervec>
    800012d8:	30579073          	csrw	mtvec,a5
    800012dc:	300027f3          	csrr	a5,mstatus
    800012e0:	0087e793          	ori	a5,a5,8
    800012e4:	30079073          	csrw	mstatus,a5
    800012e8:	304027f3          	csrr	a5,mie
    800012ec:	0807e793          	ori	a5,a5,128
    800012f0:	30479073          	csrw	mie,a5
    800012f4:	00813403          	ld	s0,8(sp)
    800012f8:	01010113          	addi	sp,sp,16
    800012fc:	00008067          	ret

0000000080001300 <system_main>:
    80001300:	fe010113          	addi	sp,sp,-32
    80001304:	00813823          	sd	s0,16(sp)
    80001308:	00913423          	sd	s1,8(sp)
    8000130c:	00113c23          	sd	ra,24(sp)
    80001310:	02010413          	addi	s0,sp,32
    80001314:	00000097          	auipc	ra,0x0
    80001318:	0c4080e7          	jalr	196(ra) # 800013d8 <cpuid>
    8000131c:	00003497          	auipc	s1,0x3
    80001320:	04c48493          	addi	s1,s1,76 # 80004368 <started>
    80001324:	02050263          	beqz	a0,80001348 <system_main+0x48>
    80001328:	0004a783          	lw	a5,0(s1)
    8000132c:	0007879b          	sext.w	a5,a5
    80001330:	fe078ce3          	beqz	a5,80001328 <system_main+0x28>
    80001334:	0ff0000f          	fence
    80001338:	00003517          	auipc	a0,0x3
    8000133c:	d7850513          	addi	a0,a0,-648 # 800040b0 <CONSOLE_STATUS+0xa0>
    80001340:	00001097          	auipc	ra,0x1
    80001344:	a7c080e7          	jalr	-1412(ra) # 80001dbc <panic>
    80001348:	00001097          	auipc	ra,0x1
    8000134c:	9d0080e7          	jalr	-1584(ra) # 80001d18 <consoleinit>
    80001350:	00001097          	auipc	ra,0x1
    80001354:	15c080e7          	jalr	348(ra) # 800024ac <printfinit>
    80001358:	00003517          	auipc	a0,0x3
    8000135c:	e3850513          	addi	a0,a0,-456 # 80004190 <CONSOLE_STATUS+0x180>
    80001360:	00001097          	auipc	ra,0x1
    80001364:	ab8080e7          	jalr	-1352(ra) # 80001e18 <__printf>
    80001368:	00003517          	auipc	a0,0x3
    8000136c:	d1850513          	addi	a0,a0,-744 # 80004080 <CONSOLE_STATUS+0x70>
    80001370:	00001097          	auipc	ra,0x1
    80001374:	aa8080e7          	jalr	-1368(ra) # 80001e18 <__printf>
    80001378:	00003517          	auipc	a0,0x3
    8000137c:	e1850513          	addi	a0,a0,-488 # 80004190 <CONSOLE_STATUS+0x180>
    80001380:	00001097          	auipc	ra,0x1
    80001384:	a98080e7          	jalr	-1384(ra) # 80001e18 <__printf>
    80001388:	00001097          	auipc	ra,0x1
    8000138c:	4b0080e7          	jalr	1200(ra) # 80002838 <kinit>
    80001390:	00000097          	auipc	ra,0x0
    80001394:	148080e7          	jalr	328(ra) # 800014d8 <trapinit>
    80001398:	00000097          	auipc	ra,0x0
    8000139c:	16c080e7          	jalr	364(ra) # 80001504 <trapinithart>
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	5c0080e7          	jalr	1472(ra) # 80001960 <plicinit>
    800013a8:	00000097          	auipc	ra,0x0
    800013ac:	5e0080e7          	jalr	1504(ra) # 80001988 <plicinithart>
    800013b0:	00000097          	auipc	ra,0x0
    800013b4:	078080e7          	jalr	120(ra) # 80001428 <userinit>
    800013b8:	0ff0000f          	fence
    800013bc:	00100793          	li	a5,1
    800013c0:	00003517          	auipc	a0,0x3
    800013c4:	cd850513          	addi	a0,a0,-808 # 80004098 <CONSOLE_STATUS+0x88>
    800013c8:	00f4a023          	sw	a5,0(s1)
    800013cc:	00001097          	auipc	ra,0x1
    800013d0:	a4c080e7          	jalr	-1460(ra) # 80001e18 <__printf>
    800013d4:	0000006f          	j	800013d4 <system_main+0xd4>

00000000800013d8 <cpuid>:
    800013d8:	ff010113          	addi	sp,sp,-16
    800013dc:	00813423          	sd	s0,8(sp)
    800013e0:	01010413          	addi	s0,sp,16
    800013e4:	00020513          	mv	a0,tp
    800013e8:	00813403          	ld	s0,8(sp)
    800013ec:	0005051b          	sext.w	a0,a0
    800013f0:	01010113          	addi	sp,sp,16
    800013f4:	00008067          	ret

00000000800013f8 <mycpu>:
    800013f8:	ff010113          	addi	sp,sp,-16
    800013fc:	00813423          	sd	s0,8(sp)
    80001400:	01010413          	addi	s0,sp,16
    80001404:	00020793          	mv	a5,tp
    80001408:	00813403          	ld	s0,8(sp)
    8000140c:	0007879b          	sext.w	a5,a5
    80001410:	00779793          	slli	a5,a5,0x7
    80001414:	00004517          	auipc	a0,0x4
    80001418:	fac50513          	addi	a0,a0,-84 # 800053c0 <cpus>
    8000141c:	00f50533          	add	a0,a0,a5
    80001420:	01010113          	addi	sp,sp,16
    80001424:	00008067          	ret

0000000080001428 <userinit>:
    80001428:	ff010113          	addi	sp,sp,-16
    8000142c:	00813423          	sd	s0,8(sp)
    80001430:	01010413          	addi	s0,sp,16
    80001434:	00813403          	ld	s0,8(sp)
    80001438:	01010113          	addi	sp,sp,16
    8000143c:	00000317          	auipc	t1,0x0
    80001440:	cdc30067          	jr	-804(t1) # 80001118 <main>

0000000080001444 <either_copyout>:
    80001444:	ff010113          	addi	sp,sp,-16
    80001448:	00813023          	sd	s0,0(sp)
    8000144c:	00113423          	sd	ra,8(sp)
    80001450:	01010413          	addi	s0,sp,16
    80001454:	02051663          	bnez	a0,80001480 <either_copyout+0x3c>
    80001458:	00058513          	mv	a0,a1
    8000145c:	00060593          	mv	a1,a2
    80001460:	0006861b          	sext.w	a2,a3
    80001464:	00002097          	auipc	ra,0x2
    80001468:	c60080e7          	jalr	-928(ra) # 800030c4 <__memmove>
    8000146c:	00813083          	ld	ra,8(sp)
    80001470:	00013403          	ld	s0,0(sp)
    80001474:	00000513          	li	a0,0
    80001478:	01010113          	addi	sp,sp,16
    8000147c:	00008067          	ret
    80001480:	00003517          	auipc	a0,0x3
    80001484:	c5850513          	addi	a0,a0,-936 # 800040d8 <CONSOLE_STATUS+0xc8>
    80001488:	00001097          	auipc	ra,0x1
    8000148c:	934080e7          	jalr	-1740(ra) # 80001dbc <panic>

0000000080001490 <either_copyin>:
    80001490:	ff010113          	addi	sp,sp,-16
    80001494:	00813023          	sd	s0,0(sp)
    80001498:	00113423          	sd	ra,8(sp)
    8000149c:	01010413          	addi	s0,sp,16
    800014a0:	02059463          	bnez	a1,800014c8 <either_copyin+0x38>
    800014a4:	00060593          	mv	a1,a2
    800014a8:	0006861b          	sext.w	a2,a3
    800014ac:	00002097          	auipc	ra,0x2
    800014b0:	c18080e7          	jalr	-1000(ra) # 800030c4 <__memmove>
    800014b4:	00813083          	ld	ra,8(sp)
    800014b8:	00013403          	ld	s0,0(sp)
    800014bc:	00000513          	li	a0,0
    800014c0:	01010113          	addi	sp,sp,16
    800014c4:	00008067          	ret
    800014c8:	00003517          	auipc	a0,0x3
    800014cc:	c3850513          	addi	a0,a0,-968 # 80004100 <CONSOLE_STATUS+0xf0>
    800014d0:	00001097          	auipc	ra,0x1
    800014d4:	8ec080e7          	jalr	-1812(ra) # 80001dbc <panic>

00000000800014d8 <trapinit>:
    800014d8:	ff010113          	addi	sp,sp,-16
    800014dc:	00813423          	sd	s0,8(sp)
    800014e0:	01010413          	addi	s0,sp,16
    800014e4:	00813403          	ld	s0,8(sp)
    800014e8:	00003597          	auipc	a1,0x3
    800014ec:	c4058593          	addi	a1,a1,-960 # 80004128 <CONSOLE_STATUS+0x118>
    800014f0:	00004517          	auipc	a0,0x4
    800014f4:	f5050513          	addi	a0,a0,-176 # 80005440 <tickslock>
    800014f8:	01010113          	addi	sp,sp,16
    800014fc:	00001317          	auipc	t1,0x1
    80001500:	5cc30067          	jr	1484(t1) # 80002ac8 <initlock>

0000000080001504 <trapinithart>:
    80001504:	ff010113          	addi	sp,sp,-16
    80001508:	00813423          	sd	s0,8(sp)
    8000150c:	01010413          	addi	s0,sp,16
    80001510:	00000797          	auipc	a5,0x0
    80001514:	30078793          	addi	a5,a5,768 # 80001810 <kernelvec>
    80001518:	10579073          	csrw	stvec,a5
    8000151c:	00813403          	ld	s0,8(sp)
    80001520:	01010113          	addi	sp,sp,16
    80001524:	00008067          	ret

0000000080001528 <usertrap>:
    80001528:	ff010113          	addi	sp,sp,-16
    8000152c:	00813423          	sd	s0,8(sp)
    80001530:	01010413          	addi	s0,sp,16
    80001534:	00813403          	ld	s0,8(sp)
    80001538:	01010113          	addi	sp,sp,16
    8000153c:	00008067          	ret

0000000080001540 <usertrapret>:
    80001540:	ff010113          	addi	sp,sp,-16
    80001544:	00813423          	sd	s0,8(sp)
    80001548:	01010413          	addi	s0,sp,16
    8000154c:	00813403          	ld	s0,8(sp)
    80001550:	01010113          	addi	sp,sp,16
    80001554:	00008067          	ret

0000000080001558 <kerneltrap>:
    80001558:	fe010113          	addi	sp,sp,-32
    8000155c:	00813823          	sd	s0,16(sp)
    80001560:	00113c23          	sd	ra,24(sp)
    80001564:	00913423          	sd	s1,8(sp)
    80001568:	02010413          	addi	s0,sp,32
    8000156c:	142025f3          	csrr	a1,scause
    80001570:	100027f3          	csrr	a5,sstatus
    80001574:	0027f793          	andi	a5,a5,2
    80001578:	10079c63          	bnez	a5,80001690 <kerneltrap+0x138>
    8000157c:	142027f3          	csrr	a5,scause
    80001580:	0207ce63          	bltz	a5,800015bc <kerneltrap+0x64>
    80001584:	00003517          	auipc	a0,0x3
    80001588:	bec50513          	addi	a0,a0,-1044 # 80004170 <CONSOLE_STATUS+0x160>
    8000158c:	00001097          	auipc	ra,0x1
    80001590:	88c080e7          	jalr	-1908(ra) # 80001e18 <__printf>
    80001594:	141025f3          	csrr	a1,sepc
    80001598:	14302673          	csrr	a2,stval
    8000159c:	00003517          	auipc	a0,0x3
    800015a0:	be450513          	addi	a0,a0,-1052 # 80004180 <CONSOLE_STATUS+0x170>
    800015a4:	00001097          	auipc	ra,0x1
    800015a8:	874080e7          	jalr	-1932(ra) # 80001e18 <__printf>
    800015ac:	00003517          	auipc	a0,0x3
    800015b0:	bec50513          	addi	a0,a0,-1044 # 80004198 <CONSOLE_STATUS+0x188>
    800015b4:	00001097          	auipc	ra,0x1
    800015b8:	808080e7          	jalr	-2040(ra) # 80001dbc <panic>
    800015bc:	0ff7f713          	andi	a4,a5,255
    800015c0:	00900693          	li	a3,9
    800015c4:	04d70063          	beq	a4,a3,80001604 <kerneltrap+0xac>
    800015c8:	fff00713          	li	a4,-1
    800015cc:	03f71713          	slli	a4,a4,0x3f
    800015d0:	00170713          	addi	a4,a4,1
    800015d4:	fae798e3          	bne	a5,a4,80001584 <kerneltrap+0x2c>
    800015d8:	00000097          	auipc	ra,0x0
    800015dc:	e00080e7          	jalr	-512(ra) # 800013d8 <cpuid>
    800015e0:	06050663          	beqz	a0,8000164c <kerneltrap+0xf4>
    800015e4:	144027f3          	csrr	a5,sip
    800015e8:	ffd7f793          	andi	a5,a5,-3
    800015ec:	14479073          	csrw	sip,a5
    800015f0:	01813083          	ld	ra,24(sp)
    800015f4:	01013403          	ld	s0,16(sp)
    800015f8:	00813483          	ld	s1,8(sp)
    800015fc:	02010113          	addi	sp,sp,32
    80001600:	00008067          	ret
    80001604:	00000097          	auipc	ra,0x0
    80001608:	3d0080e7          	jalr	976(ra) # 800019d4 <plic_claim>
    8000160c:	00a00793          	li	a5,10
    80001610:	00050493          	mv	s1,a0
    80001614:	06f50863          	beq	a0,a5,80001684 <kerneltrap+0x12c>
    80001618:	fc050ce3          	beqz	a0,800015f0 <kerneltrap+0x98>
    8000161c:	00050593          	mv	a1,a0
    80001620:	00003517          	auipc	a0,0x3
    80001624:	b3050513          	addi	a0,a0,-1232 # 80004150 <CONSOLE_STATUS+0x140>
    80001628:	00000097          	auipc	ra,0x0
    8000162c:	7f0080e7          	jalr	2032(ra) # 80001e18 <__printf>
    80001630:	01013403          	ld	s0,16(sp)
    80001634:	01813083          	ld	ra,24(sp)
    80001638:	00048513          	mv	a0,s1
    8000163c:	00813483          	ld	s1,8(sp)
    80001640:	02010113          	addi	sp,sp,32
    80001644:	00000317          	auipc	t1,0x0
    80001648:	3c830067          	jr	968(t1) # 80001a0c <plic_complete>
    8000164c:	00004517          	auipc	a0,0x4
    80001650:	df450513          	addi	a0,a0,-524 # 80005440 <tickslock>
    80001654:	00001097          	auipc	ra,0x1
    80001658:	498080e7          	jalr	1176(ra) # 80002aec <acquire>
    8000165c:	00003717          	auipc	a4,0x3
    80001660:	d1070713          	addi	a4,a4,-752 # 8000436c <ticks>
    80001664:	00072783          	lw	a5,0(a4)
    80001668:	00004517          	auipc	a0,0x4
    8000166c:	dd850513          	addi	a0,a0,-552 # 80005440 <tickslock>
    80001670:	0017879b          	addiw	a5,a5,1
    80001674:	00f72023          	sw	a5,0(a4)
    80001678:	00001097          	auipc	ra,0x1
    8000167c:	540080e7          	jalr	1344(ra) # 80002bb8 <release>
    80001680:	f65ff06f          	j	800015e4 <kerneltrap+0x8c>
    80001684:	00001097          	auipc	ra,0x1
    80001688:	09c080e7          	jalr	156(ra) # 80002720 <uartintr>
    8000168c:	fa5ff06f          	j	80001630 <kerneltrap+0xd8>
    80001690:	00003517          	auipc	a0,0x3
    80001694:	aa050513          	addi	a0,a0,-1376 # 80004130 <CONSOLE_STATUS+0x120>
    80001698:	00000097          	auipc	ra,0x0
    8000169c:	724080e7          	jalr	1828(ra) # 80001dbc <panic>

00000000800016a0 <clockintr>:
    800016a0:	fe010113          	addi	sp,sp,-32
    800016a4:	00813823          	sd	s0,16(sp)
    800016a8:	00913423          	sd	s1,8(sp)
    800016ac:	00113c23          	sd	ra,24(sp)
    800016b0:	02010413          	addi	s0,sp,32
    800016b4:	00004497          	auipc	s1,0x4
    800016b8:	d8c48493          	addi	s1,s1,-628 # 80005440 <tickslock>
    800016bc:	00048513          	mv	a0,s1
    800016c0:	00001097          	auipc	ra,0x1
    800016c4:	42c080e7          	jalr	1068(ra) # 80002aec <acquire>
    800016c8:	00003717          	auipc	a4,0x3
    800016cc:	ca470713          	addi	a4,a4,-860 # 8000436c <ticks>
    800016d0:	00072783          	lw	a5,0(a4)
    800016d4:	01013403          	ld	s0,16(sp)
    800016d8:	01813083          	ld	ra,24(sp)
    800016dc:	00048513          	mv	a0,s1
    800016e0:	0017879b          	addiw	a5,a5,1
    800016e4:	00813483          	ld	s1,8(sp)
    800016e8:	00f72023          	sw	a5,0(a4)
    800016ec:	02010113          	addi	sp,sp,32
    800016f0:	00001317          	auipc	t1,0x1
    800016f4:	4c830067          	jr	1224(t1) # 80002bb8 <release>

00000000800016f8 <devintr>:
    800016f8:	142027f3          	csrr	a5,scause
    800016fc:	00000513          	li	a0,0
    80001700:	0007c463          	bltz	a5,80001708 <devintr+0x10>
    80001704:	00008067          	ret
    80001708:	fe010113          	addi	sp,sp,-32
    8000170c:	00813823          	sd	s0,16(sp)
    80001710:	00113c23          	sd	ra,24(sp)
    80001714:	00913423          	sd	s1,8(sp)
    80001718:	02010413          	addi	s0,sp,32
    8000171c:	0ff7f713          	andi	a4,a5,255
    80001720:	00900693          	li	a3,9
    80001724:	04d70c63          	beq	a4,a3,8000177c <devintr+0x84>
    80001728:	fff00713          	li	a4,-1
    8000172c:	03f71713          	slli	a4,a4,0x3f
    80001730:	00170713          	addi	a4,a4,1
    80001734:	00e78c63          	beq	a5,a4,8000174c <devintr+0x54>
    80001738:	01813083          	ld	ra,24(sp)
    8000173c:	01013403          	ld	s0,16(sp)
    80001740:	00813483          	ld	s1,8(sp)
    80001744:	02010113          	addi	sp,sp,32
    80001748:	00008067          	ret
    8000174c:	00000097          	auipc	ra,0x0
    80001750:	c8c080e7          	jalr	-884(ra) # 800013d8 <cpuid>
    80001754:	06050663          	beqz	a0,800017c0 <devintr+0xc8>
    80001758:	144027f3          	csrr	a5,sip
    8000175c:	ffd7f793          	andi	a5,a5,-3
    80001760:	14479073          	csrw	sip,a5
    80001764:	01813083          	ld	ra,24(sp)
    80001768:	01013403          	ld	s0,16(sp)
    8000176c:	00813483          	ld	s1,8(sp)
    80001770:	00200513          	li	a0,2
    80001774:	02010113          	addi	sp,sp,32
    80001778:	00008067          	ret
    8000177c:	00000097          	auipc	ra,0x0
    80001780:	258080e7          	jalr	600(ra) # 800019d4 <plic_claim>
    80001784:	00a00793          	li	a5,10
    80001788:	00050493          	mv	s1,a0
    8000178c:	06f50663          	beq	a0,a5,800017f8 <devintr+0x100>
    80001790:	00100513          	li	a0,1
    80001794:	fa0482e3          	beqz	s1,80001738 <devintr+0x40>
    80001798:	00048593          	mv	a1,s1
    8000179c:	00003517          	auipc	a0,0x3
    800017a0:	9b450513          	addi	a0,a0,-1612 # 80004150 <CONSOLE_STATUS+0x140>
    800017a4:	00000097          	auipc	ra,0x0
    800017a8:	674080e7          	jalr	1652(ra) # 80001e18 <__printf>
    800017ac:	00048513          	mv	a0,s1
    800017b0:	00000097          	auipc	ra,0x0
    800017b4:	25c080e7          	jalr	604(ra) # 80001a0c <plic_complete>
    800017b8:	00100513          	li	a0,1
    800017bc:	f7dff06f          	j	80001738 <devintr+0x40>
    800017c0:	00004517          	auipc	a0,0x4
    800017c4:	c8050513          	addi	a0,a0,-896 # 80005440 <tickslock>
    800017c8:	00001097          	auipc	ra,0x1
    800017cc:	324080e7          	jalr	804(ra) # 80002aec <acquire>
    800017d0:	00003717          	auipc	a4,0x3
    800017d4:	b9c70713          	addi	a4,a4,-1124 # 8000436c <ticks>
    800017d8:	00072783          	lw	a5,0(a4)
    800017dc:	00004517          	auipc	a0,0x4
    800017e0:	c6450513          	addi	a0,a0,-924 # 80005440 <tickslock>
    800017e4:	0017879b          	addiw	a5,a5,1
    800017e8:	00f72023          	sw	a5,0(a4)
    800017ec:	00001097          	auipc	ra,0x1
    800017f0:	3cc080e7          	jalr	972(ra) # 80002bb8 <release>
    800017f4:	f65ff06f          	j	80001758 <devintr+0x60>
    800017f8:	00001097          	auipc	ra,0x1
    800017fc:	f28080e7          	jalr	-216(ra) # 80002720 <uartintr>
    80001800:	fadff06f          	j	800017ac <devintr+0xb4>
	...

0000000080001810 <kernelvec>:
    80001810:	f0010113          	addi	sp,sp,-256
    80001814:	00113023          	sd	ra,0(sp)
    80001818:	00213423          	sd	sp,8(sp)
    8000181c:	00313823          	sd	gp,16(sp)
    80001820:	00413c23          	sd	tp,24(sp)
    80001824:	02513023          	sd	t0,32(sp)
    80001828:	02613423          	sd	t1,40(sp)
    8000182c:	02713823          	sd	t2,48(sp)
    80001830:	02813c23          	sd	s0,56(sp)
    80001834:	04913023          	sd	s1,64(sp)
    80001838:	04a13423          	sd	a0,72(sp)
    8000183c:	04b13823          	sd	a1,80(sp)
    80001840:	04c13c23          	sd	a2,88(sp)
    80001844:	06d13023          	sd	a3,96(sp)
    80001848:	06e13423          	sd	a4,104(sp)
    8000184c:	06f13823          	sd	a5,112(sp)
    80001850:	07013c23          	sd	a6,120(sp)
    80001854:	09113023          	sd	a7,128(sp)
    80001858:	09213423          	sd	s2,136(sp)
    8000185c:	09313823          	sd	s3,144(sp)
    80001860:	09413c23          	sd	s4,152(sp)
    80001864:	0b513023          	sd	s5,160(sp)
    80001868:	0b613423          	sd	s6,168(sp)
    8000186c:	0b713823          	sd	s7,176(sp)
    80001870:	0b813c23          	sd	s8,184(sp)
    80001874:	0d913023          	sd	s9,192(sp)
    80001878:	0da13423          	sd	s10,200(sp)
    8000187c:	0db13823          	sd	s11,208(sp)
    80001880:	0dc13c23          	sd	t3,216(sp)
    80001884:	0fd13023          	sd	t4,224(sp)
    80001888:	0fe13423          	sd	t5,232(sp)
    8000188c:	0ff13823          	sd	t6,240(sp)
    80001890:	cc9ff0ef          	jal	ra,80001558 <kerneltrap>
    80001894:	00013083          	ld	ra,0(sp)
    80001898:	00813103          	ld	sp,8(sp)
    8000189c:	01013183          	ld	gp,16(sp)
    800018a0:	02013283          	ld	t0,32(sp)
    800018a4:	02813303          	ld	t1,40(sp)
    800018a8:	03013383          	ld	t2,48(sp)
    800018ac:	03813403          	ld	s0,56(sp)
    800018b0:	04013483          	ld	s1,64(sp)
    800018b4:	04813503          	ld	a0,72(sp)
    800018b8:	05013583          	ld	a1,80(sp)
    800018bc:	05813603          	ld	a2,88(sp)
    800018c0:	06013683          	ld	a3,96(sp)
    800018c4:	06813703          	ld	a4,104(sp)
    800018c8:	07013783          	ld	a5,112(sp)
    800018cc:	07813803          	ld	a6,120(sp)
    800018d0:	08013883          	ld	a7,128(sp)
    800018d4:	08813903          	ld	s2,136(sp)
    800018d8:	09013983          	ld	s3,144(sp)
    800018dc:	09813a03          	ld	s4,152(sp)
    800018e0:	0a013a83          	ld	s5,160(sp)
    800018e4:	0a813b03          	ld	s6,168(sp)
    800018e8:	0b013b83          	ld	s7,176(sp)
    800018ec:	0b813c03          	ld	s8,184(sp)
    800018f0:	0c013c83          	ld	s9,192(sp)
    800018f4:	0c813d03          	ld	s10,200(sp)
    800018f8:	0d013d83          	ld	s11,208(sp)
    800018fc:	0d813e03          	ld	t3,216(sp)
    80001900:	0e013e83          	ld	t4,224(sp)
    80001904:	0e813f03          	ld	t5,232(sp)
    80001908:	0f013f83          	ld	t6,240(sp)
    8000190c:	10010113          	addi	sp,sp,256
    80001910:	10200073          	sret
    80001914:	00000013          	nop
    80001918:	00000013          	nop
    8000191c:	00000013          	nop

0000000080001920 <timervec>:
    80001920:	34051573          	csrrw	a0,mscratch,a0
    80001924:	00b53023          	sd	a1,0(a0)
    80001928:	00c53423          	sd	a2,8(a0)
    8000192c:	00d53823          	sd	a3,16(a0)
    80001930:	01853583          	ld	a1,24(a0)
    80001934:	02053603          	ld	a2,32(a0)
    80001938:	0005b683          	ld	a3,0(a1)
    8000193c:	00c686b3          	add	a3,a3,a2
    80001940:	00d5b023          	sd	a3,0(a1)
    80001944:	00200593          	li	a1,2
    80001948:	14459073          	csrw	sip,a1
    8000194c:	01053683          	ld	a3,16(a0)
    80001950:	00853603          	ld	a2,8(a0)
    80001954:	00053583          	ld	a1,0(a0)
    80001958:	34051573          	csrrw	a0,mscratch,a0
    8000195c:	30200073          	mret

0000000080001960 <plicinit>:
    80001960:	ff010113          	addi	sp,sp,-16
    80001964:	00813423          	sd	s0,8(sp)
    80001968:	01010413          	addi	s0,sp,16
    8000196c:	00813403          	ld	s0,8(sp)
    80001970:	0c0007b7          	lui	a5,0xc000
    80001974:	00100713          	li	a4,1
    80001978:	02e7a423          	sw	a4,40(a5) # c000028 <_entry-0x73ffffd8>
    8000197c:	00e7a223          	sw	a4,4(a5)
    80001980:	01010113          	addi	sp,sp,16
    80001984:	00008067          	ret

0000000080001988 <plicinithart>:
    80001988:	ff010113          	addi	sp,sp,-16
    8000198c:	00813023          	sd	s0,0(sp)
    80001990:	00113423          	sd	ra,8(sp)
    80001994:	01010413          	addi	s0,sp,16
    80001998:	00000097          	auipc	ra,0x0
    8000199c:	a40080e7          	jalr	-1472(ra) # 800013d8 <cpuid>
    800019a0:	0085171b          	slliw	a4,a0,0x8
    800019a4:	0c0027b7          	lui	a5,0xc002
    800019a8:	00e787b3          	add	a5,a5,a4
    800019ac:	40200713          	li	a4,1026
    800019b0:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>
    800019b4:	00813083          	ld	ra,8(sp)
    800019b8:	00013403          	ld	s0,0(sp)
    800019bc:	00d5151b          	slliw	a0,a0,0xd
    800019c0:	0c2017b7          	lui	a5,0xc201
    800019c4:	00a78533          	add	a0,a5,a0
    800019c8:	00052023          	sw	zero,0(a0)
    800019cc:	01010113          	addi	sp,sp,16
    800019d0:	00008067          	ret

00000000800019d4 <plic_claim>:
    800019d4:	ff010113          	addi	sp,sp,-16
    800019d8:	00813023          	sd	s0,0(sp)
    800019dc:	00113423          	sd	ra,8(sp)
    800019e0:	01010413          	addi	s0,sp,16
    800019e4:	00000097          	auipc	ra,0x0
    800019e8:	9f4080e7          	jalr	-1548(ra) # 800013d8 <cpuid>
    800019ec:	00813083          	ld	ra,8(sp)
    800019f0:	00013403          	ld	s0,0(sp)
    800019f4:	00d5151b          	slliw	a0,a0,0xd
    800019f8:	0c2017b7          	lui	a5,0xc201
    800019fc:	00a78533          	add	a0,a5,a0
    80001a00:	00452503          	lw	a0,4(a0)
    80001a04:	01010113          	addi	sp,sp,16
    80001a08:	00008067          	ret

0000000080001a0c <plic_complete>:
    80001a0c:	fe010113          	addi	sp,sp,-32
    80001a10:	00813823          	sd	s0,16(sp)
    80001a14:	00913423          	sd	s1,8(sp)
    80001a18:	00113c23          	sd	ra,24(sp)
    80001a1c:	02010413          	addi	s0,sp,32
    80001a20:	00050493          	mv	s1,a0
    80001a24:	00000097          	auipc	ra,0x0
    80001a28:	9b4080e7          	jalr	-1612(ra) # 800013d8 <cpuid>
    80001a2c:	01813083          	ld	ra,24(sp)
    80001a30:	01013403          	ld	s0,16(sp)
    80001a34:	00d5179b          	slliw	a5,a0,0xd
    80001a38:	0c201737          	lui	a4,0xc201
    80001a3c:	00f707b3          	add	a5,a4,a5
    80001a40:	0097a223          	sw	s1,4(a5) # c201004 <_entry-0x73dfeffc>
    80001a44:	00813483          	ld	s1,8(sp)
    80001a48:	02010113          	addi	sp,sp,32
    80001a4c:	00008067          	ret

0000000080001a50 <consolewrite>:
    80001a50:	fb010113          	addi	sp,sp,-80
    80001a54:	04813023          	sd	s0,64(sp)
    80001a58:	04113423          	sd	ra,72(sp)
    80001a5c:	02913c23          	sd	s1,56(sp)
    80001a60:	03213823          	sd	s2,48(sp)
    80001a64:	03313423          	sd	s3,40(sp)
    80001a68:	03413023          	sd	s4,32(sp)
    80001a6c:	01513c23          	sd	s5,24(sp)
    80001a70:	05010413          	addi	s0,sp,80
    80001a74:	06c05c63          	blez	a2,80001aec <consolewrite+0x9c>
    80001a78:	00060993          	mv	s3,a2
    80001a7c:	00050a13          	mv	s4,a0
    80001a80:	00058493          	mv	s1,a1
    80001a84:	00000913          	li	s2,0
    80001a88:	fff00a93          	li	s5,-1
    80001a8c:	01c0006f          	j	80001aa8 <consolewrite+0x58>
    80001a90:	fbf44503          	lbu	a0,-65(s0)
    80001a94:	0019091b          	addiw	s2,s2,1
    80001a98:	00148493          	addi	s1,s1,1
    80001a9c:	00001097          	auipc	ra,0x1
    80001aa0:	a9c080e7          	jalr	-1380(ra) # 80002538 <uartputc>
    80001aa4:	03298063          	beq	s3,s2,80001ac4 <consolewrite+0x74>
    80001aa8:	00048613          	mv	a2,s1
    80001aac:	00100693          	li	a3,1
    80001ab0:	000a0593          	mv	a1,s4
    80001ab4:	fbf40513          	addi	a0,s0,-65
    80001ab8:	00000097          	auipc	ra,0x0
    80001abc:	9d8080e7          	jalr	-1576(ra) # 80001490 <either_copyin>
    80001ac0:	fd5518e3          	bne	a0,s5,80001a90 <consolewrite+0x40>
    80001ac4:	04813083          	ld	ra,72(sp)
    80001ac8:	04013403          	ld	s0,64(sp)
    80001acc:	03813483          	ld	s1,56(sp)
    80001ad0:	02813983          	ld	s3,40(sp)
    80001ad4:	02013a03          	ld	s4,32(sp)
    80001ad8:	01813a83          	ld	s5,24(sp)
    80001adc:	00090513          	mv	a0,s2
    80001ae0:	03013903          	ld	s2,48(sp)
    80001ae4:	05010113          	addi	sp,sp,80
    80001ae8:	00008067          	ret
    80001aec:	00000913          	li	s2,0
    80001af0:	fd5ff06f          	j	80001ac4 <consolewrite+0x74>

0000000080001af4 <consoleread>:
    80001af4:	f9010113          	addi	sp,sp,-112
    80001af8:	06813023          	sd	s0,96(sp)
    80001afc:	04913c23          	sd	s1,88(sp)
    80001b00:	05213823          	sd	s2,80(sp)
    80001b04:	05313423          	sd	s3,72(sp)
    80001b08:	05413023          	sd	s4,64(sp)
    80001b0c:	03513c23          	sd	s5,56(sp)
    80001b10:	03613823          	sd	s6,48(sp)
    80001b14:	03713423          	sd	s7,40(sp)
    80001b18:	03813023          	sd	s8,32(sp)
    80001b1c:	06113423          	sd	ra,104(sp)
    80001b20:	01913c23          	sd	s9,24(sp)
    80001b24:	07010413          	addi	s0,sp,112
    80001b28:	00060b93          	mv	s7,a2
    80001b2c:	00050913          	mv	s2,a0
    80001b30:	00058c13          	mv	s8,a1
    80001b34:	00060b1b          	sext.w	s6,a2
    80001b38:	00004497          	auipc	s1,0x4
    80001b3c:	92048493          	addi	s1,s1,-1760 # 80005458 <cons>
    80001b40:	00400993          	li	s3,4
    80001b44:	fff00a13          	li	s4,-1
    80001b48:	00a00a93          	li	s5,10
    80001b4c:	05705e63          	blez	s7,80001ba8 <consoleread+0xb4>
    80001b50:	09c4a703          	lw	a4,156(s1)
    80001b54:	0984a783          	lw	a5,152(s1)
    80001b58:	0007071b          	sext.w	a4,a4
    80001b5c:	08e78463          	beq	a5,a4,80001be4 <consoleread+0xf0>
    80001b60:	07f7f713          	andi	a4,a5,127
    80001b64:	00e48733          	add	a4,s1,a4
    80001b68:	01874703          	lbu	a4,24(a4) # c201018 <_entry-0x73dfefe8>
    80001b6c:	0017869b          	addiw	a3,a5,1
    80001b70:	08d4ac23          	sw	a3,152(s1)
    80001b74:	00070c9b          	sext.w	s9,a4
    80001b78:	0b370663          	beq	a4,s3,80001c24 <consoleread+0x130>
    80001b7c:	00100693          	li	a3,1
    80001b80:	f9f40613          	addi	a2,s0,-97
    80001b84:	000c0593          	mv	a1,s8
    80001b88:	00090513          	mv	a0,s2
    80001b8c:	f8e40fa3          	sb	a4,-97(s0)
    80001b90:	00000097          	auipc	ra,0x0
    80001b94:	8b4080e7          	jalr	-1868(ra) # 80001444 <either_copyout>
    80001b98:	01450863          	beq	a0,s4,80001ba8 <consoleread+0xb4>
    80001b9c:	001c0c13          	addi	s8,s8,1
    80001ba0:	fffb8b9b          	addiw	s7,s7,-1
    80001ba4:	fb5c94e3          	bne	s9,s5,80001b4c <consoleread+0x58>
    80001ba8:	000b851b          	sext.w	a0,s7
    80001bac:	06813083          	ld	ra,104(sp)
    80001bb0:	06013403          	ld	s0,96(sp)
    80001bb4:	05813483          	ld	s1,88(sp)
    80001bb8:	05013903          	ld	s2,80(sp)
    80001bbc:	04813983          	ld	s3,72(sp)
    80001bc0:	04013a03          	ld	s4,64(sp)
    80001bc4:	03813a83          	ld	s5,56(sp)
    80001bc8:	02813b83          	ld	s7,40(sp)
    80001bcc:	02013c03          	ld	s8,32(sp)
    80001bd0:	01813c83          	ld	s9,24(sp)
    80001bd4:	40ab053b          	subw	a0,s6,a0
    80001bd8:	03013b03          	ld	s6,48(sp)
    80001bdc:	07010113          	addi	sp,sp,112
    80001be0:	00008067          	ret
    80001be4:	00001097          	auipc	ra,0x1
    80001be8:	1d8080e7          	jalr	472(ra) # 80002dbc <push_on>
    80001bec:	0984a703          	lw	a4,152(s1)
    80001bf0:	09c4a783          	lw	a5,156(s1)
    80001bf4:	0007879b          	sext.w	a5,a5
    80001bf8:	fef70ce3          	beq	a4,a5,80001bf0 <consoleread+0xfc>
    80001bfc:	00001097          	auipc	ra,0x1
    80001c00:	234080e7          	jalr	564(ra) # 80002e30 <pop_on>
    80001c04:	0984a783          	lw	a5,152(s1)
    80001c08:	07f7f713          	andi	a4,a5,127
    80001c0c:	00e48733          	add	a4,s1,a4
    80001c10:	01874703          	lbu	a4,24(a4)
    80001c14:	0017869b          	addiw	a3,a5,1
    80001c18:	08d4ac23          	sw	a3,152(s1)
    80001c1c:	00070c9b          	sext.w	s9,a4
    80001c20:	f5371ee3          	bne	a4,s3,80001b7c <consoleread+0x88>
    80001c24:	000b851b          	sext.w	a0,s7
    80001c28:	f96bf2e3          	bgeu	s7,s6,80001bac <consoleread+0xb8>
    80001c2c:	08f4ac23          	sw	a5,152(s1)
    80001c30:	f7dff06f          	j	80001bac <consoleread+0xb8>

0000000080001c34 <consputc>:
    80001c34:	10000793          	li	a5,256
    80001c38:	00f50663          	beq	a0,a5,80001c44 <consputc+0x10>
    80001c3c:	00001317          	auipc	t1,0x1
    80001c40:	9f430067          	jr	-1548(t1) # 80002630 <uartputc_sync>
    80001c44:	ff010113          	addi	sp,sp,-16
    80001c48:	00113423          	sd	ra,8(sp)
    80001c4c:	00813023          	sd	s0,0(sp)
    80001c50:	01010413          	addi	s0,sp,16
    80001c54:	00800513          	li	a0,8
    80001c58:	00001097          	auipc	ra,0x1
    80001c5c:	9d8080e7          	jalr	-1576(ra) # 80002630 <uartputc_sync>
    80001c60:	02000513          	li	a0,32
    80001c64:	00001097          	auipc	ra,0x1
    80001c68:	9cc080e7          	jalr	-1588(ra) # 80002630 <uartputc_sync>
    80001c6c:	00013403          	ld	s0,0(sp)
    80001c70:	00813083          	ld	ra,8(sp)
    80001c74:	00800513          	li	a0,8
    80001c78:	01010113          	addi	sp,sp,16
    80001c7c:	00001317          	auipc	t1,0x1
    80001c80:	9b430067          	jr	-1612(t1) # 80002630 <uartputc_sync>

0000000080001c84 <consoleintr>:
    80001c84:	fe010113          	addi	sp,sp,-32
    80001c88:	00813823          	sd	s0,16(sp)
    80001c8c:	00913423          	sd	s1,8(sp)
    80001c90:	01213023          	sd	s2,0(sp)
    80001c94:	00113c23          	sd	ra,24(sp)
    80001c98:	02010413          	addi	s0,sp,32
    80001c9c:	00003917          	auipc	s2,0x3
    80001ca0:	7bc90913          	addi	s2,s2,1980 # 80005458 <cons>
    80001ca4:	00050493          	mv	s1,a0
    80001ca8:	00090513          	mv	a0,s2
    80001cac:	00001097          	auipc	ra,0x1
    80001cb0:	e40080e7          	jalr	-448(ra) # 80002aec <acquire>
    80001cb4:	02048c63          	beqz	s1,80001cec <consoleintr+0x68>
    80001cb8:	0a092783          	lw	a5,160(s2)
    80001cbc:	09892703          	lw	a4,152(s2)
    80001cc0:	07f00693          	li	a3,127
    80001cc4:	40e7873b          	subw	a4,a5,a4
    80001cc8:	02e6e263          	bltu	a3,a4,80001cec <consoleintr+0x68>
    80001ccc:	00d00713          	li	a4,13
    80001cd0:	04e48063          	beq	s1,a4,80001d10 <consoleintr+0x8c>
    80001cd4:	07f7f713          	andi	a4,a5,127
    80001cd8:	00e90733          	add	a4,s2,a4
    80001cdc:	0017879b          	addiw	a5,a5,1
    80001ce0:	0af92023          	sw	a5,160(s2)
    80001ce4:	00970c23          	sb	s1,24(a4)
    80001ce8:	08f92e23          	sw	a5,156(s2)
    80001cec:	01013403          	ld	s0,16(sp)
    80001cf0:	01813083          	ld	ra,24(sp)
    80001cf4:	00813483          	ld	s1,8(sp)
    80001cf8:	00013903          	ld	s2,0(sp)
    80001cfc:	00003517          	auipc	a0,0x3
    80001d00:	75c50513          	addi	a0,a0,1884 # 80005458 <cons>
    80001d04:	02010113          	addi	sp,sp,32
    80001d08:	00001317          	auipc	t1,0x1
    80001d0c:	eb030067          	jr	-336(t1) # 80002bb8 <release>
    80001d10:	00a00493          	li	s1,10
    80001d14:	fc1ff06f          	j	80001cd4 <consoleintr+0x50>

0000000080001d18 <consoleinit>:
    80001d18:	fe010113          	addi	sp,sp,-32
    80001d1c:	00113c23          	sd	ra,24(sp)
    80001d20:	00813823          	sd	s0,16(sp)
    80001d24:	00913423          	sd	s1,8(sp)
    80001d28:	02010413          	addi	s0,sp,32
    80001d2c:	00003497          	auipc	s1,0x3
    80001d30:	72c48493          	addi	s1,s1,1836 # 80005458 <cons>
    80001d34:	00048513          	mv	a0,s1
    80001d38:	00002597          	auipc	a1,0x2
    80001d3c:	47058593          	addi	a1,a1,1136 # 800041a8 <CONSOLE_STATUS+0x198>
    80001d40:	00001097          	auipc	ra,0x1
    80001d44:	d88080e7          	jalr	-632(ra) # 80002ac8 <initlock>
    80001d48:	00000097          	auipc	ra,0x0
    80001d4c:	7ac080e7          	jalr	1964(ra) # 800024f4 <uartinit>
    80001d50:	01813083          	ld	ra,24(sp)
    80001d54:	01013403          	ld	s0,16(sp)
    80001d58:	00000797          	auipc	a5,0x0
    80001d5c:	d9c78793          	addi	a5,a5,-612 # 80001af4 <consoleread>
    80001d60:	0af4bc23          	sd	a5,184(s1)
    80001d64:	00000797          	auipc	a5,0x0
    80001d68:	cec78793          	addi	a5,a5,-788 # 80001a50 <consolewrite>
    80001d6c:	0cf4b023          	sd	a5,192(s1)
    80001d70:	00813483          	ld	s1,8(sp)
    80001d74:	02010113          	addi	sp,sp,32
    80001d78:	00008067          	ret

0000000080001d7c <console_read>:
    80001d7c:	ff010113          	addi	sp,sp,-16
    80001d80:	00813423          	sd	s0,8(sp)
    80001d84:	01010413          	addi	s0,sp,16
    80001d88:	00813403          	ld	s0,8(sp)
    80001d8c:	00003317          	auipc	t1,0x3
    80001d90:	78433303          	ld	t1,1924(t1) # 80005510 <devsw+0x10>
    80001d94:	01010113          	addi	sp,sp,16
    80001d98:	00030067          	jr	t1

0000000080001d9c <console_write>:
    80001d9c:	ff010113          	addi	sp,sp,-16
    80001da0:	00813423          	sd	s0,8(sp)
    80001da4:	01010413          	addi	s0,sp,16
    80001da8:	00813403          	ld	s0,8(sp)
    80001dac:	00003317          	auipc	t1,0x3
    80001db0:	76c33303          	ld	t1,1900(t1) # 80005518 <devsw+0x18>
    80001db4:	01010113          	addi	sp,sp,16
    80001db8:	00030067          	jr	t1

0000000080001dbc <panic>:
    80001dbc:	fe010113          	addi	sp,sp,-32
    80001dc0:	00113c23          	sd	ra,24(sp)
    80001dc4:	00813823          	sd	s0,16(sp)
    80001dc8:	00913423          	sd	s1,8(sp)
    80001dcc:	02010413          	addi	s0,sp,32
    80001dd0:	00050493          	mv	s1,a0
    80001dd4:	00002517          	auipc	a0,0x2
    80001dd8:	3dc50513          	addi	a0,a0,988 # 800041b0 <CONSOLE_STATUS+0x1a0>
    80001ddc:	00003797          	auipc	a5,0x3
    80001de0:	7c07ae23          	sw	zero,2012(a5) # 800055b8 <pr+0x18>
    80001de4:	00000097          	auipc	ra,0x0
    80001de8:	034080e7          	jalr	52(ra) # 80001e18 <__printf>
    80001dec:	00048513          	mv	a0,s1
    80001df0:	00000097          	auipc	ra,0x0
    80001df4:	028080e7          	jalr	40(ra) # 80001e18 <__printf>
    80001df8:	00002517          	auipc	a0,0x2
    80001dfc:	39850513          	addi	a0,a0,920 # 80004190 <CONSOLE_STATUS+0x180>
    80001e00:	00000097          	auipc	ra,0x0
    80001e04:	018080e7          	jalr	24(ra) # 80001e18 <__printf>
    80001e08:	00100793          	li	a5,1
    80001e0c:	00002717          	auipc	a4,0x2
    80001e10:	56f72223          	sw	a5,1380(a4) # 80004370 <panicked>
    80001e14:	0000006f          	j	80001e14 <panic+0x58>

0000000080001e18 <__printf>:
    80001e18:	f3010113          	addi	sp,sp,-208
    80001e1c:	08813023          	sd	s0,128(sp)
    80001e20:	07313423          	sd	s3,104(sp)
    80001e24:	09010413          	addi	s0,sp,144
    80001e28:	05813023          	sd	s8,64(sp)
    80001e2c:	08113423          	sd	ra,136(sp)
    80001e30:	06913c23          	sd	s1,120(sp)
    80001e34:	07213823          	sd	s2,112(sp)
    80001e38:	07413023          	sd	s4,96(sp)
    80001e3c:	05513c23          	sd	s5,88(sp)
    80001e40:	05613823          	sd	s6,80(sp)
    80001e44:	05713423          	sd	s7,72(sp)
    80001e48:	03913c23          	sd	s9,56(sp)
    80001e4c:	03a13823          	sd	s10,48(sp)
    80001e50:	03b13423          	sd	s11,40(sp)
    80001e54:	00003317          	auipc	t1,0x3
    80001e58:	74c30313          	addi	t1,t1,1868 # 800055a0 <pr>
    80001e5c:	01832c03          	lw	s8,24(t1)
    80001e60:	00b43423          	sd	a1,8(s0)
    80001e64:	00c43823          	sd	a2,16(s0)
    80001e68:	00d43c23          	sd	a3,24(s0)
    80001e6c:	02e43023          	sd	a4,32(s0)
    80001e70:	02f43423          	sd	a5,40(s0)
    80001e74:	03043823          	sd	a6,48(s0)
    80001e78:	03143c23          	sd	a7,56(s0)
    80001e7c:	00050993          	mv	s3,a0
    80001e80:	4a0c1663          	bnez	s8,8000232c <__printf+0x514>
    80001e84:	60098c63          	beqz	s3,8000249c <__printf+0x684>
    80001e88:	0009c503          	lbu	a0,0(s3)
    80001e8c:	00840793          	addi	a5,s0,8
    80001e90:	f6f43c23          	sd	a5,-136(s0)
    80001e94:	00000493          	li	s1,0
    80001e98:	22050063          	beqz	a0,800020b8 <__printf+0x2a0>
    80001e9c:	00002a37          	lui	s4,0x2
    80001ea0:	00018ab7          	lui	s5,0x18
    80001ea4:	000f4b37          	lui	s6,0xf4
    80001ea8:	00989bb7          	lui	s7,0x989
    80001eac:	70fa0a13          	addi	s4,s4,1807 # 270f <_entry-0x7fffd8f1>
    80001eb0:	69fa8a93          	addi	s5,s5,1695 # 1869f <_entry-0x7ffe7961>
    80001eb4:	23fb0b13          	addi	s6,s6,575 # f423f <_entry-0x7ff0bdc1>
    80001eb8:	67fb8b93          	addi	s7,s7,1663 # 98967f <_entry-0x7f676981>
    80001ebc:	00148c9b          	addiw	s9,s1,1
    80001ec0:	02500793          	li	a5,37
    80001ec4:	01998933          	add	s2,s3,s9
    80001ec8:	38f51263          	bne	a0,a5,8000224c <__printf+0x434>
    80001ecc:	00094783          	lbu	a5,0(s2)
    80001ed0:	00078c9b          	sext.w	s9,a5
    80001ed4:	1e078263          	beqz	a5,800020b8 <__printf+0x2a0>
    80001ed8:	0024849b          	addiw	s1,s1,2
    80001edc:	07000713          	li	a4,112
    80001ee0:	00998933          	add	s2,s3,s1
    80001ee4:	38e78a63          	beq	a5,a4,80002278 <__printf+0x460>
    80001ee8:	20f76863          	bltu	a4,a5,800020f8 <__printf+0x2e0>
    80001eec:	42a78863          	beq	a5,a0,8000231c <__printf+0x504>
    80001ef0:	06400713          	li	a4,100
    80001ef4:	40e79663          	bne	a5,a4,80002300 <__printf+0x4e8>
    80001ef8:	f7843783          	ld	a5,-136(s0)
    80001efc:	0007a603          	lw	a2,0(a5)
    80001f00:	00878793          	addi	a5,a5,8
    80001f04:	f6f43c23          	sd	a5,-136(s0)
    80001f08:	42064a63          	bltz	a2,8000233c <__printf+0x524>
    80001f0c:	00a00713          	li	a4,10
    80001f10:	02e677bb          	remuw	a5,a2,a4
    80001f14:	00002d97          	auipc	s11,0x2
    80001f18:	2c4d8d93          	addi	s11,s11,708 # 800041d8 <digits>
    80001f1c:	00900593          	li	a1,9
    80001f20:	0006051b          	sext.w	a0,a2
    80001f24:	00000c93          	li	s9,0
    80001f28:	02079793          	slli	a5,a5,0x20
    80001f2c:	0207d793          	srli	a5,a5,0x20
    80001f30:	00fd87b3          	add	a5,s11,a5
    80001f34:	0007c783          	lbu	a5,0(a5)
    80001f38:	02e656bb          	divuw	a3,a2,a4
    80001f3c:	f8f40023          	sb	a5,-128(s0)
    80001f40:	14c5d863          	bge	a1,a2,80002090 <__printf+0x278>
    80001f44:	06300593          	li	a1,99
    80001f48:	00100c93          	li	s9,1
    80001f4c:	02e6f7bb          	remuw	a5,a3,a4
    80001f50:	02079793          	slli	a5,a5,0x20
    80001f54:	0207d793          	srli	a5,a5,0x20
    80001f58:	00fd87b3          	add	a5,s11,a5
    80001f5c:	0007c783          	lbu	a5,0(a5)
    80001f60:	02e6d73b          	divuw	a4,a3,a4
    80001f64:	f8f400a3          	sb	a5,-127(s0)
    80001f68:	12a5f463          	bgeu	a1,a0,80002090 <__printf+0x278>
    80001f6c:	00a00693          	li	a3,10
    80001f70:	00900593          	li	a1,9
    80001f74:	02d777bb          	remuw	a5,a4,a3
    80001f78:	02079793          	slli	a5,a5,0x20
    80001f7c:	0207d793          	srli	a5,a5,0x20
    80001f80:	00fd87b3          	add	a5,s11,a5
    80001f84:	0007c503          	lbu	a0,0(a5)
    80001f88:	02d757bb          	divuw	a5,a4,a3
    80001f8c:	f8a40123          	sb	a0,-126(s0)
    80001f90:	48e5f263          	bgeu	a1,a4,80002414 <__printf+0x5fc>
    80001f94:	06300513          	li	a0,99
    80001f98:	02d7f5bb          	remuw	a1,a5,a3
    80001f9c:	02059593          	slli	a1,a1,0x20
    80001fa0:	0205d593          	srli	a1,a1,0x20
    80001fa4:	00bd85b3          	add	a1,s11,a1
    80001fa8:	0005c583          	lbu	a1,0(a1)
    80001fac:	02d7d7bb          	divuw	a5,a5,a3
    80001fb0:	f8b401a3          	sb	a1,-125(s0)
    80001fb4:	48e57263          	bgeu	a0,a4,80002438 <__printf+0x620>
    80001fb8:	3e700513          	li	a0,999
    80001fbc:	02d7f5bb          	remuw	a1,a5,a3
    80001fc0:	02059593          	slli	a1,a1,0x20
    80001fc4:	0205d593          	srli	a1,a1,0x20
    80001fc8:	00bd85b3          	add	a1,s11,a1
    80001fcc:	0005c583          	lbu	a1,0(a1)
    80001fd0:	02d7d7bb          	divuw	a5,a5,a3
    80001fd4:	f8b40223          	sb	a1,-124(s0)
    80001fd8:	46e57663          	bgeu	a0,a4,80002444 <__printf+0x62c>
    80001fdc:	02d7f5bb          	remuw	a1,a5,a3
    80001fe0:	02059593          	slli	a1,a1,0x20
    80001fe4:	0205d593          	srli	a1,a1,0x20
    80001fe8:	00bd85b3          	add	a1,s11,a1
    80001fec:	0005c583          	lbu	a1,0(a1)
    80001ff0:	02d7d7bb          	divuw	a5,a5,a3
    80001ff4:	f8b402a3          	sb	a1,-123(s0)
    80001ff8:	46ea7863          	bgeu	s4,a4,80002468 <__printf+0x650>
    80001ffc:	02d7f5bb          	remuw	a1,a5,a3
    80002000:	02059593          	slli	a1,a1,0x20
    80002004:	0205d593          	srli	a1,a1,0x20
    80002008:	00bd85b3          	add	a1,s11,a1
    8000200c:	0005c583          	lbu	a1,0(a1)
    80002010:	02d7d7bb          	divuw	a5,a5,a3
    80002014:	f8b40323          	sb	a1,-122(s0)
    80002018:	3eeaf863          	bgeu	s5,a4,80002408 <__printf+0x5f0>
    8000201c:	02d7f5bb          	remuw	a1,a5,a3
    80002020:	02059593          	slli	a1,a1,0x20
    80002024:	0205d593          	srli	a1,a1,0x20
    80002028:	00bd85b3          	add	a1,s11,a1
    8000202c:	0005c583          	lbu	a1,0(a1)
    80002030:	02d7d7bb          	divuw	a5,a5,a3
    80002034:	f8b403a3          	sb	a1,-121(s0)
    80002038:	42eb7e63          	bgeu	s6,a4,80002474 <__printf+0x65c>
    8000203c:	02d7f5bb          	remuw	a1,a5,a3
    80002040:	02059593          	slli	a1,a1,0x20
    80002044:	0205d593          	srli	a1,a1,0x20
    80002048:	00bd85b3          	add	a1,s11,a1
    8000204c:	0005c583          	lbu	a1,0(a1)
    80002050:	02d7d7bb          	divuw	a5,a5,a3
    80002054:	f8b40423          	sb	a1,-120(s0)
    80002058:	42ebfc63          	bgeu	s7,a4,80002490 <__printf+0x678>
    8000205c:	02079793          	slli	a5,a5,0x20
    80002060:	0207d793          	srli	a5,a5,0x20
    80002064:	00fd8db3          	add	s11,s11,a5
    80002068:	000dc703          	lbu	a4,0(s11)
    8000206c:	00a00793          	li	a5,10
    80002070:	00900c93          	li	s9,9
    80002074:	f8e404a3          	sb	a4,-119(s0)
    80002078:	00065c63          	bgez	a2,80002090 <__printf+0x278>
    8000207c:	f9040713          	addi	a4,s0,-112
    80002080:	00f70733          	add	a4,a4,a5
    80002084:	02d00693          	li	a3,45
    80002088:	fed70823          	sb	a3,-16(a4)
    8000208c:	00078c93          	mv	s9,a5
    80002090:	f8040793          	addi	a5,s0,-128
    80002094:	01978cb3          	add	s9,a5,s9
    80002098:	f7f40d13          	addi	s10,s0,-129
    8000209c:	000cc503          	lbu	a0,0(s9)
    800020a0:	fffc8c93          	addi	s9,s9,-1
    800020a4:	00000097          	auipc	ra,0x0
    800020a8:	b90080e7          	jalr	-1136(ra) # 80001c34 <consputc>
    800020ac:	ffac98e3          	bne	s9,s10,8000209c <__printf+0x284>
    800020b0:	00094503          	lbu	a0,0(s2)
    800020b4:	e00514e3          	bnez	a0,80001ebc <__printf+0xa4>
    800020b8:	1a0c1663          	bnez	s8,80002264 <__printf+0x44c>
    800020bc:	08813083          	ld	ra,136(sp)
    800020c0:	08013403          	ld	s0,128(sp)
    800020c4:	07813483          	ld	s1,120(sp)
    800020c8:	07013903          	ld	s2,112(sp)
    800020cc:	06813983          	ld	s3,104(sp)
    800020d0:	06013a03          	ld	s4,96(sp)
    800020d4:	05813a83          	ld	s5,88(sp)
    800020d8:	05013b03          	ld	s6,80(sp)
    800020dc:	04813b83          	ld	s7,72(sp)
    800020e0:	04013c03          	ld	s8,64(sp)
    800020e4:	03813c83          	ld	s9,56(sp)
    800020e8:	03013d03          	ld	s10,48(sp)
    800020ec:	02813d83          	ld	s11,40(sp)
    800020f0:	0d010113          	addi	sp,sp,208
    800020f4:	00008067          	ret
    800020f8:	07300713          	li	a4,115
    800020fc:	1ce78a63          	beq	a5,a4,800022d0 <__printf+0x4b8>
    80002100:	07800713          	li	a4,120
    80002104:	1ee79e63          	bne	a5,a4,80002300 <__printf+0x4e8>
    80002108:	f7843783          	ld	a5,-136(s0)
    8000210c:	0007a703          	lw	a4,0(a5)
    80002110:	00878793          	addi	a5,a5,8
    80002114:	f6f43c23          	sd	a5,-136(s0)
    80002118:	28074263          	bltz	a4,8000239c <__printf+0x584>
    8000211c:	00002d97          	auipc	s11,0x2
    80002120:	0bcd8d93          	addi	s11,s11,188 # 800041d8 <digits>
    80002124:	00f77793          	andi	a5,a4,15
    80002128:	00fd87b3          	add	a5,s11,a5
    8000212c:	0007c683          	lbu	a3,0(a5)
    80002130:	00f00613          	li	a2,15
    80002134:	0007079b          	sext.w	a5,a4
    80002138:	f8d40023          	sb	a3,-128(s0)
    8000213c:	0047559b          	srliw	a1,a4,0x4
    80002140:	0047569b          	srliw	a3,a4,0x4
    80002144:	00000c93          	li	s9,0
    80002148:	0ee65063          	bge	a2,a4,80002228 <__printf+0x410>
    8000214c:	00f6f693          	andi	a3,a3,15
    80002150:	00dd86b3          	add	a3,s11,a3
    80002154:	0006c683          	lbu	a3,0(a3) # 2004000 <_entry-0x7dffc000>
    80002158:	0087d79b          	srliw	a5,a5,0x8
    8000215c:	00100c93          	li	s9,1
    80002160:	f8d400a3          	sb	a3,-127(s0)
    80002164:	0cb67263          	bgeu	a2,a1,80002228 <__printf+0x410>
    80002168:	00f7f693          	andi	a3,a5,15
    8000216c:	00dd86b3          	add	a3,s11,a3
    80002170:	0006c583          	lbu	a1,0(a3)
    80002174:	00f00613          	li	a2,15
    80002178:	0047d69b          	srliw	a3,a5,0x4
    8000217c:	f8b40123          	sb	a1,-126(s0)
    80002180:	0047d593          	srli	a1,a5,0x4
    80002184:	28f67e63          	bgeu	a2,a5,80002420 <__printf+0x608>
    80002188:	00f6f693          	andi	a3,a3,15
    8000218c:	00dd86b3          	add	a3,s11,a3
    80002190:	0006c503          	lbu	a0,0(a3)
    80002194:	0087d813          	srli	a6,a5,0x8
    80002198:	0087d69b          	srliw	a3,a5,0x8
    8000219c:	f8a401a3          	sb	a0,-125(s0)
    800021a0:	28b67663          	bgeu	a2,a1,8000242c <__printf+0x614>
    800021a4:	00f6f693          	andi	a3,a3,15
    800021a8:	00dd86b3          	add	a3,s11,a3
    800021ac:	0006c583          	lbu	a1,0(a3)
    800021b0:	00c7d513          	srli	a0,a5,0xc
    800021b4:	00c7d69b          	srliw	a3,a5,0xc
    800021b8:	f8b40223          	sb	a1,-124(s0)
    800021bc:	29067a63          	bgeu	a2,a6,80002450 <__printf+0x638>
    800021c0:	00f6f693          	andi	a3,a3,15
    800021c4:	00dd86b3          	add	a3,s11,a3
    800021c8:	0006c583          	lbu	a1,0(a3)
    800021cc:	0107d813          	srli	a6,a5,0x10
    800021d0:	0107d69b          	srliw	a3,a5,0x10
    800021d4:	f8b402a3          	sb	a1,-123(s0)
    800021d8:	28a67263          	bgeu	a2,a0,8000245c <__printf+0x644>
    800021dc:	00f6f693          	andi	a3,a3,15
    800021e0:	00dd86b3          	add	a3,s11,a3
    800021e4:	0006c683          	lbu	a3,0(a3)
    800021e8:	0147d79b          	srliw	a5,a5,0x14
    800021ec:	f8d40323          	sb	a3,-122(s0)
    800021f0:	21067663          	bgeu	a2,a6,800023fc <__printf+0x5e4>
    800021f4:	02079793          	slli	a5,a5,0x20
    800021f8:	0207d793          	srli	a5,a5,0x20
    800021fc:	00fd8db3          	add	s11,s11,a5
    80002200:	000dc683          	lbu	a3,0(s11)
    80002204:	00800793          	li	a5,8
    80002208:	00700c93          	li	s9,7
    8000220c:	f8d403a3          	sb	a3,-121(s0)
    80002210:	00075c63          	bgez	a4,80002228 <__printf+0x410>
    80002214:	f9040713          	addi	a4,s0,-112
    80002218:	00f70733          	add	a4,a4,a5
    8000221c:	02d00693          	li	a3,45
    80002220:	fed70823          	sb	a3,-16(a4)
    80002224:	00078c93          	mv	s9,a5
    80002228:	f8040793          	addi	a5,s0,-128
    8000222c:	01978cb3          	add	s9,a5,s9
    80002230:	f7f40d13          	addi	s10,s0,-129
    80002234:	000cc503          	lbu	a0,0(s9)
    80002238:	fffc8c93          	addi	s9,s9,-1
    8000223c:	00000097          	auipc	ra,0x0
    80002240:	9f8080e7          	jalr	-1544(ra) # 80001c34 <consputc>
    80002244:	ff9d18e3          	bne	s10,s9,80002234 <__printf+0x41c>
    80002248:	0100006f          	j	80002258 <__printf+0x440>
    8000224c:	00000097          	auipc	ra,0x0
    80002250:	9e8080e7          	jalr	-1560(ra) # 80001c34 <consputc>
    80002254:	000c8493          	mv	s1,s9
    80002258:	00094503          	lbu	a0,0(s2)
    8000225c:	c60510e3          	bnez	a0,80001ebc <__printf+0xa4>
    80002260:	e40c0ee3          	beqz	s8,800020bc <__printf+0x2a4>
    80002264:	00003517          	auipc	a0,0x3
    80002268:	33c50513          	addi	a0,a0,828 # 800055a0 <pr>
    8000226c:	00001097          	auipc	ra,0x1
    80002270:	94c080e7          	jalr	-1716(ra) # 80002bb8 <release>
    80002274:	e49ff06f          	j	800020bc <__printf+0x2a4>
    80002278:	f7843783          	ld	a5,-136(s0)
    8000227c:	03000513          	li	a0,48
    80002280:	01000d13          	li	s10,16
    80002284:	00878713          	addi	a4,a5,8
    80002288:	0007bc83          	ld	s9,0(a5)
    8000228c:	f6e43c23          	sd	a4,-136(s0)
    80002290:	00000097          	auipc	ra,0x0
    80002294:	9a4080e7          	jalr	-1628(ra) # 80001c34 <consputc>
    80002298:	07800513          	li	a0,120
    8000229c:	00000097          	auipc	ra,0x0
    800022a0:	998080e7          	jalr	-1640(ra) # 80001c34 <consputc>
    800022a4:	00002d97          	auipc	s11,0x2
    800022a8:	f34d8d93          	addi	s11,s11,-204 # 800041d8 <digits>
    800022ac:	03ccd793          	srli	a5,s9,0x3c
    800022b0:	00fd87b3          	add	a5,s11,a5
    800022b4:	0007c503          	lbu	a0,0(a5)
    800022b8:	fffd0d1b          	addiw	s10,s10,-1
    800022bc:	004c9c93          	slli	s9,s9,0x4
    800022c0:	00000097          	auipc	ra,0x0
    800022c4:	974080e7          	jalr	-1676(ra) # 80001c34 <consputc>
    800022c8:	fe0d12e3          	bnez	s10,800022ac <__printf+0x494>
    800022cc:	f8dff06f          	j	80002258 <__printf+0x440>
    800022d0:	f7843783          	ld	a5,-136(s0)
    800022d4:	0007bc83          	ld	s9,0(a5)
    800022d8:	00878793          	addi	a5,a5,8
    800022dc:	f6f43c23          	sd	a5,-136(s0)
    800022e0:	000c9a63          	bnez	s9,800022f4 <__printf+0x4dc>
    800022e4:	1080006f          	j	800023ec <__printf+0x5d4>
    800022e8:	001c8c93          	addi	s9,s9,1
    800022ec:	00000097          	auipc	ra,0x0
    800022f0:	948080e7          	jalr	-1720(ra) # 80001c34 <consputc>
    800022f4:	000cc503          	lbu	a0,0(s9)
    800022f8:	fe0518e3          	bnez	a0,800022e8 <__printf+0x4d0>
    800022fc:	f5dff06f          	j	80002258 <__printf+0x440>
    80002300:	02500513          	li	a0,37
    80002304:	00000097          	auipc	ra,0x0
    80002308:	930080e7          	jalr	-1744(ra) # 80001c34 <consputc>
    8000230c:	000c8513          	mv	a0,s9
    80002310:	00000097          	auipc	ra,0x0
    80002314:	924080e7          	jalr	-1756(ra) # 80001c34 <consputc>
    80002318:	f41ff06f          	j	80002258 <__printf+0x440>
    8000231c:	02500513          	li	a0,37
    80002320:	00000097          	auipc	ra,0x0
    80002324:	914080e7          	jalr	-1772(ra) # 80001c34 <consputc>
    80002328:	f31ff06f          	j	80002258 <__printf+0x440>
    8000232c:	00030513          	mv	a0,t1
    80002330:	00000097          	auipc	ra,0x0
    80002334:	7bc080e7          	jalr	1980(ra) # 80002aec <acquire>
    80002338:	b4dff06f          	j	80001e84 <__printf+0x6c>
    8000233c:	40c0053b          	negw	a0,a2
    80002340:	00a00713          	li	a4,10
    80002344:	02e576bb          	remuw	a3,a0,a4
    80002348:	00002d97          	auipc	s11,0x2
    8000234c:	e90d8d93          	addi	s11,s11,-368 # 800041d8 <digits>
    80002350:	ff700593          	li	a1,-9
    80002354:	02069693          	slli	a3,a3,0x20
    80002358:	0206d693          	srli	a3,a3,0x20
    8000235c:	00dd86b3          	add	a3,s11,a3
    80002360:	0006c683          	lbu	a3,0(a3)
    80002364:	02e557bb          	divuw	a5,a0,a4
    80002368:	f8d40023          	sb	a3,-128(s0)
    8000236c:	10b65e63          	bge	a2,a1,80002488 <__printf+0x670>
    80002370:	06300593          	li	a1,99
    80002374:	02e7f6bb          	remuw	a3,a5,a4
    80002378:	02069693          	slli	a3,a3,0x20
    8000237c:	0206d693          	srli	a3,a3,0x20
    80002380:	00dd86b3          	add	a3,s11,a3
    80002384:	0006c683          	lbu	a3,0(a3)
    80002388:	02e7d73b          	divuw	a4,a5,a4
    8000238c:	00200793          	li	a5,2
    80002390:	f8d400a3          	sb	a3,-127(s0)
    80002394:	bca5ece3          	bltu	a1,a0,80001f6c <__printf+0x154>
    80002398:	ce5ff06f          	j	8000207c <__printf+0x264>
    8000239c:	40e007bb          	negw	a5,a4
    800023a0:	00002d97          	auipc	s11,0x2
    800023a4:	e38d8d93          	addi	s11,s11,-456 # 800041d8 <digits>
    800023a8:	00f7f693          	andi	a3,a5,15
    800023ac:	00dd86b3          	add	a3,s11,a3
    800023b0:	0006c583          	lbu	a1,0(a3)
    800023b4:	ff100613          	li	a2,-15
    800023b8:	0047d69b          	srliw	a3,a5,0x4
    800023bc:	f8b40023          	sb	a1,-128(s0)
    800023c0:	0047d59b          	srliw	a1,a5,0x4
    800023c4:	0ac75e63          	bge	a4,a2,80002480 <__printf+0x668>
    800023c8:	00f6f693          	andi	a3,a3,15
    800023cc:	00dd86b3          	add	a3,s11,a3
    800023d0:	0006c603          	lbu	a2,0(a3)
    800023d4:	00f00693          	li	a3,15
    800023d8:	0087d79b          	srliw	a5,a5,0x8
    800023dc:	f8c400a3          	sb	a2,-127(s0)
    800023e0:	d8b6e4e3          	bltu	a3,a1,80002168 <__printf+0x350>
    800023e4:	00200793          	li	a5,2
    800023e8:	e2dff06f          	j	80002214 <__printf+0x3fc>
    800023ec:	00002c97          	auipc	s9,0x2
    800023f0:	dccc8c93          	addi	s9,s9,-564 # 800041b8 <CONSOLE_STATUS+0x1a8>
    800023f4:	02800513          	li	a0,40
    800023f8:	ef1ff06f          	j	800022e8 <__printf+0x4d0>
    800023fc:	00700793          	li	a5,7
    80002400:	00600c93          	li	s9,6
    80002404:	e0dff06f          	j	80002210 <__printf+0x3f8>
    80002408:	00700793          	li	a5,7
    8000240c:	00600c93          	li	s9,6
    80002410:	c69ff06f          	j	80002078 <__printf+0x260>
    80002414:	00300793          	li	a5,3
    80002418:	00200c93          	li	s9,2
    8000241c:	c5dff06f          	j	80002078 <__printf+0x260>
    80002420:	00300793          	li	a5,3
    80002424:	00200c93          	li	s9,2
    80002428:	de9ff06f          	j	80002210 <__printf+0x3f8>
    8000242c:	00400793          	li	a5,4
    80002430:	00300c93          	li	s9,3
    80002434:	dddff06f          	j	80002210 <__printf+0x3f8>
    80002438:	00400793          	li	a5,4
    8000243c:	00300c93          	li	s9,3
    80002440:	c39ff06f          	j	80002078 <__printf+0x260>
    80002444:	00500793          	li	a5,5
    80002448:	00400c93          	li	s9,4
    8000244c:	c2dff06f          	j	80002078 <__printf+0x260>
    80002450:	00500793          	li	a5,5
    80002454:	00400c93          	li	s9,4
    80002458:	db9ff06f          	j	80002210 <__printf+0x3f8>
    8000245c:	00600793          	li	a5,6
    80002460:	00500c93          	li	s9,5
    80002464:	dadff06f          	j	80002210 <__printf+0x3f8>
    80002468:	00600793          	li	a5,6
    8000246c:	00500c93          	li	s9,5
    80002470:	c09ff06f          	j	80002078 <__printf+0x260>
    80002474:	00800793          	li	a5,8
    80002478:	00700c93          	li	s9,7
    8000247c:	bfdff06f          	j	80002078 <__printf+0x260>
    80002480:	00100793          	li	a5,1
    80002484:	d91ff06f          	j	80002214 <__printf+0x3fc>
    80002488:	00100793          	li	a5,1
    8000248c:	bf1ff06f          	j	8000207c <__printf+0x264>
    80002490:	00900793          	li	a5,9
    80002494:	00800c93          	li	s9,8
    80002498:	be1ff06f          	j	80002078 <__printf+0x260>
    8000249c:	00002517          	auipc	a0,0x2
    800024a0:	d2450513          	addi	a0,a0,-732 # 800041c0 <CONSOLE_STATUS+0x1b0>
    800024a4:	00000097          	auipc	ra,0x0
    800024a8:	918080e7          	jalr	-1768(ra) # 80001dbc <panic>

00000000800024ac <printfinit>:
    800024ac:	fe010113          	addi	sp,sp,-32
    800024b0:	00813823          	sd	s0,16(sp)
    800024b4:	00913423          	sd	s1,8(sp)
    800024b8:	00113c23          	sd	ra,24(sp)
    800024bc:	02010413          	addi	s0,sp,32
    800024c0:	00003497          	auipc	s1,0x3
    800024c4:	0e048493          	addi	s1,s1,224 # 800055a0 <pr>
    800024c8:	00048513          	mv	a0,s1
    800024cc:	00002597          	auipc	a1,0x2
    800024d0:	d0458593          	addi	a1,a1,-764 # 800041d0 <CONSOLE_STATUS+0x1c0>
    800024d4:	00000097          	auipc	ra,0x0
    800024d8:	5f4080e7          	jalr	1524(ra) # 80002ac8 <initlock>
    800024dc:	01813083          	ld	ra,24(sp)
    800024e0:	01013403          	ld	s0,16(sp)
    800024e4:	0004ac23          	sw	zero,24(s1)
    800024e8:	00813483          	ld	s1,8(sp)
    800024ec:	02010113          	addi	sp,sp,32
    800024f0:	00008067          	ret

00000000800024f4 <uartinit>:
    800024f4:	ff010113          	addi	sp,sp,-16
    800024f8:	00813423          	sd	s0,8(sp)
    800024fc:	01010413          	addi	s0,sp,16
    80002500:	100007b7          	lui	a5,0x10000
    80002504:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>
    80002508:	f8000713          	li	a4,-128
    8000250c:	00e781a3          	sb	a4,3(a5)
    80002510:	00300713          	li	a4,3
    80002514:	00e78023          	sb	a4,0(a5)
    80002518:	000780a3          	sb	zero,1(a5)
    8000251c:	00e781a3          	sb	a4,3(a5)
    80002520:	00700693          	li	a3,7
    80002524:	00d78123          	sb	a3,2(a5)
    80002528:	00e780a3          	sb	a4,1(a5)
    8000252c:	00813403          	ld	s0,8(sp)
    80002530:	01010113          	addi	sp,sp,16
    80002534:	00008067          	ret

0000000080002538 <uartputc>:
    80002538:	00002797          	auipc	a5,0x2
    8000253c:	e387a783          	lw	a5,-456(a5) # 80004370 <panicked>
    80002540:	00078463          	beqz	a5,80002548 <uartputc+0x10>
    80002544:	0000006f          	j	80002544 <uartputc+0xc>
    80002548:	fd010113          	addi	sp,sp,-48
    8000254c:	02813023          	sd	s0,32(sp)
    80002550:	00913c23          	sd	s1,24(sp)
    80002554:	01213823          	sd	s2,16(sp)
    80002558:	01313423          	sd	s3,8(sp)
    8000255c:	02113423          	sd	ra,40(sp)
    80002560:	03010413          	addi	s0,sp,48
    80002564:	00002917          	auipc	s2,0x2
    80002568:	e1490913          	addi	s2,s2,-492 # 80004378 <uart_tx_r>
    8000256c:	00093783          	ld	a5,0(s2)
    80002570:	00002497          	auipc	s1,0x2
    80002574:	e1048493          	addi	s1,s1,-496 # 80004380 <uart_tx_w>
    80002578:	0004b703          	ld	a4,0(s1)
    8000257c:	02078693          	addi	a3,a5,32
    80002580:	00050993          	mv	s3,a0
    80002584:	02e69c63          	bne	a3,a4,800025bc <uartputc+0x84>
    80002588:	00001097          	auipc	ra,0x1
    8000258c:	834080e7          	jalr	-1996(ra) # 80002dbc <push_on>
    80002590:	00093783          	ld	a5,0(s2)
    80002594:	0004b703          	ld	a4,0(s1)
    80002598:	02078793          	addi	a5,a5,32
    8000259c:	00e79463          	bne	a5,a4,800025a4 <uartputc+0x6c>
    800025a0:	0000006f          	j	800025a0 <uartputc+0x68>
    800025a4:	00001097          	auipc	ra,0x1
    800025a8:	88c080e7          	jalr	-1908(ra) # 80002e30 <pop_on>
    800025ac:	00093783          	ld	a5,0(s2)
    800025b0:	0004b703          	ld	a4,0(s1)
    800025b4:	02078693          	addi	a3,a5,32
    800025b8:	fce688e3          	beq	a3,a4,80002588 <uartputc+0x50>
    800025bc:	01f77693          	andi	a3,a4,31
    800025c0:	00003597          	auipc	a1,0x3
    800025c4:	00058593          	mv	a1,a1
    800025c8:	00d586b3          	add	a3,a1,a3
    800025cc:	00170713          	addi	a4,a4,1
    800025d0:	01368023          	sb	s3,0(a3)
    800025d4:	00e4b023          	sd	a4,0(s1)
    800025d8:	10000637          	lui	a2,0x10000
    800025dc:	02f71063          	bne	a4,a5,800025fc <uartputc+0xc4>
    800025e0:	0340006f          	j	80002614 <uartputc+0xdc>
    800025e4:	00074703          	lbu	a4,0(a4)
    800025e8:	00f93023          	sd	a5,0(s2)
    800025ec:	00e60023          	sb	a4,0(a2) # 10000000 <_entry-0x70000000>
    800025f0:	00093783          	ld	a5,0(s2)
    800025f4:	0004b703          	ld	a4,0(s1)
    800025f8:	00f70e63          	beq	a4,a5,80002614 <uartputc+0xdc>
    800025fc:	00564683          	lbu	a3,5(a2)
    80002600:	01f7f713          	andi	a4,a5,31
    80002604:	00e58733          	add	a4,a1,a4
    80002608:	0206f693          	andi	a3,a3,32
    8000260c:	00178793          	addi	a5,a5,1
    80002610:	fc069ae3          	bnez	a3,800025e4 <uartputc+0xac>
    80002614:	02813083          	ld	ra,40(sp)
    80002618:	02013403          	ld	s0,32(sp)
    8000261c:	01813483          	ld	s1,24(sp)
    80002620:	01013903          	ld	s2,16(sp)
    80002624:	00813983          	ld	s3,8(sp)
    80002628:	03010113          	addi	sp,sp,48
    8000262c:	00008067          	ret

0000000080002630 <uartputc_sync>:
    80002630:	ff010113          	addi	sp,sp,-16
    80002634:	00813423          	sd	s0,8(sp)
    80002638:	01010413          	addi	s0,sp,16
    8000263c:	00002717          	auipc	a4,0x2
    80002640:	d3472703          	lw	a4,-716(a4) # 80004370 <panicked>
    80002644:	02071663          	bnez	a4,80002670 <uartputc_sync+0x40>
    80002648:	00050793          	mv	a5,a0
    8000264c:	100006b7          	lui	a3,0x10000
    80002650:	0056c703          	lbu	a4,5(a3) # 10000005 <_entry-0x6ffffffb>
    80002654:	02077713          	andi	a4,a4,32
    80002658:	fe070ce3          	beqz	a4,80002650 <uartputc_sync+0x20>
    8000265c:	0ff7f793          	andi	a5,a5,255
    80002660:	00f68023          	sb	a5,0(a3)
    80002664:	00813403          	ld	s0,8(sp)
    80002668:	01010113          	addi	sp,sp,16
    8000266c:	00008067          	ret
    80002670:	0000006f          	j	80002670 <uartputc_sync+0x40>

0000000080002674 <uartstart>:
    80002674:	ff010113          	addi	sp,sp,-16
    80002678:	00813423          	sd	s0,8(sp)
    8000267c:	01010413          	addi	s0,sp,16
    80002680:	00002617          	auipc	a2,0x2
    80002684:	cf860613          	addi	a2,a2,-776 # 80004378 <uart_tx_r>
    80002688:	00002517          	auipc	a0,0x2
    8000268c:	cf850513          	addi	a0,a0,-776 # 80004380 <uart_tx_w>
    80002690:	00063783          	ld	a5,0(a2)
    80002694:	00053703          	ld	a4,0(a0)
    80002698:	04f70263          	beq	a4,a5,800026dc <uartstart+0x68>
    8000269c:	100005b7          	lui	a1,0x10000
    800026a0:	00003817          	auipc	a6,0x3
    800026a4:	f2080813          	addi	a6,a6,-224 # 800055c0 <uart_tx_buf>
    800026a8:	01c0006f          	j	800026c4 <uartstart+0x50>
    800026ac:	0006c703          	lbu	a4,0(a3)
    800026b0:	00f63023          	sd	a5,0(a2)
    800026b4:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    800026b8:	00063783          	ld	a5,0(a2)
    800026bc:	00053703          	ld	a4,0(a0)
    800026c0:	00f70e63          	beq	a4,a5,800026dc <uartstart+0x68>
    800026c4:	01f7f713          	andi	a4,a5,31
    800026c8:	00e806b3          	add	a3,a6,a4
    800026cc:	0055c703          	lbu	a4,5(a1)
    800026d0:	00178793          	addi	a5,a5,1
    800026d4:	02077713          	andi	a4,a4,32
    800026d8:	fc071ae3          	bnez	a4,800026ac <uartstart+0x38>
    800026dc:	00813403          	ld	s0,8(sp)
    800026e0:	01010113          	addi	sp,sp,16
    800026e4:	00008067          	ret

00000000800026e8 <uartgetc>:
    800026e8:	ff010113          	addi	sp,sp,-16
    800026ec:	00813423          	sd	s0,8(sp)
    800026f0:	01010413          	addi	s0,sp,16
    800026f4:	10000737          	lui	a4,0x10000
    800026f8:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800026fc:	0017f793          	andi	a5,a5,1
    80002700:	00078c63          	beqz	a5,80002718 <uartgetc+0x30>
    80002704:	00074503          	lbu	a0,0(a4)
    80002708:	0ff57513          	andi	a0,a0,255
    8000270c:	00813403          	ld	s0,8(sp)
    80002710:	01010113          	addi	sp,sp,16
    80002714:	00008067          	ret
    80002718:	fff00513          	li	a0,-1
    8000271c:	ff1ff06f          	j	8000270c <uartgetc+0x24>

0000000080002720 <uartintr>:
    80002720:	100007b7          	lui	a5,0x10000
    80002724:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80002728:	0017f793          	andi	a5,a5,1
    8000272c:	0a078463          	beqz	a5,800027d4 <uartintr+0xb4>
    80002730:	fe010113          	addi	sp,sp,-32
    80002734:	00813823          	sd	s0,16(sp)
    80002738:	00913423          	sd	s1,8(sp)
    8000273c:	00113c23          	sd	ra,24(sp)
    80002740:	02010413          	addi	s0,sp,32
    80002744:	100004b7          	lui	s1,0x10000
    80002748:	0004c503          	lbu	a0,0(s1) # 10000000 <_entry-0x70000000>
    8000274c:	0ff57513          	andi	a0,a0,255
    80002750:	fffff097          	auipc	ra,0xfffff
    80002754:	534080e7          	jalr	1332(ra) # 80001c84 <consoleintr>
    80002758:	0054c783          	lbu	a5,5(s1)
    8000275c:	0017f793          	andi	a5,a5,1
    80002760:	fe0794e3          	bnez	a5,80002748 <uartintr+0x28>
    80002764:	00002617          	auipc	a2,0x2
    80002768:	c1460613          	addi	a2,a2,-1004 # 80004378 <uart_tx_r>
    8000276c:	00002517          	auipc	a0,0x2
    80002770:	c1450513          	addi	a0,a0,-1004 # 80004380 <uart_tx_w>
    80002774:	00063783          	ld	a5,0(a2)
    80002778:	00053703          	ld	a4,0(a0)
    8000277c:	04f70263          	beq	a4,a5,800027c0 <uartintr+0xa0>
    80002780:	100005b7          	lui	a1,0x10000
    80002784:	00003817          	auipc	a6,0x3
    80002788:	e3c80813          	addi	a6,a6,-452 # 800055c0 <uart_tx_buf>
    8000278c:	01c0006f          	j	800027a8 <uartintr+0x88>
    80002790:	0006c703          	lbu	a4,0(a3)
    80002794:	00f63023          	sd	a5,0(a2)
    80002798:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    8000279c:	00063783          	ld	a5,0(a2)
    800027a0:	00053703          	ld	a4,0(a0)
    800027a4:	00f70e63          	beq	a4,a5,800027c0 <uartintr+0xa0>
    800027a8:	01f7f713          	andi	a4,a5,31
    800027ac:	00e806b3          	add	a3,a6,a4
    800027b0:	0055c703          	lbu	a4,5(a1)
    800027b4:	00178793          	addi	a5,a5,1
    800027b8:	02077713          	andi	a4,a4,32
    800027bc:	fc071ae3          	bnez	a4,80002790 <uartintr+0x70>
    800027c0:	01813083          	ld	ra,24(sp)
    800027c4:	01013403          	ld	s0,16(sp)
    800027c8:	00813483          	ld	s1,8(sp)
    800027cc:	02010113          	addi	sp,sp,32
    800027d0:	00008067          	ret
    800027d4:	00002617          	auipc	a2,0x2
    800027d8:	ba460613          	addi	a2,a2,-1116 # 80004378 <uart_tx_r>
    800027dc:	00002517          	auipc	a0,0x2
    800027e0:	ba450513          	addi	a0,a0,-1116 # 80004380 <uart_tx_w>
    800027e4:	00063783          	ld	a5,0(a2)
    800027e8:	00053703          	ld	a4,0(a0)
    800027ec:	04f70263          	beq	a4,a5,80002830 <uartintr+0x110>
    800027f0:	100005b7          	lui	a1,0x10000
    800027f4:	00003817          	auipc	a6,0x3
    800027f8:	dcc80813          	addi	a6,a6,-564 # 800055c0 <uart_tx_buf>
    800027fc:	01c0006f          	j	80002818 <uartintr+0xf8>
    80002800:	0006c703          	lbu	a4,0(a3)
    80002804:	00f63023          	sd	a5,0(a2)
    80002808:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    8000280c:	00063783          	ld	a5,0(a2)
    80002810:	00053703          	ld	a4,0(a0)
    80002814:	02f70063          	beq	a4,a5,80002834 <uartintr+0x114>
    80002818:	01f7f713          	andi	a4,a5,31
    8000281c:	00e806b3          	add	a3,a6,a4
    80002820:	0055c703          	lbu	a4,5(a1)
    80002824:	00178793          	addi	a5,a5,1
    80002828:	02077713          	andi	a4,a4,32
    8000282c:	fc071ae3          	bnez	a4,80002800 <uartintr+0xe0>
    80002830:	00008067          	ret
    80002834:	00008067          	ret

0000000080002838 <kinit>:
    80002838:	fc010113          	addi	sp,sp,-64
    8000283c:	02913423          	sd	s1,40(sp)
    80002840:	fffff7b7          	lui	a5,0xfffff
    80002844:	00004497          	auipc	s1,0x4
    80002848:	d9b48493          	addi	s1,s1,-613 # 800065df <end+0xfff>
    8000284c:	02813823          	sd	s0,48(sp)
    80002850:	01313c23          	sd	s3,24(sp)
    80002854:	00f4f4b3          	and	s1,s1,a5
    80002858:	02113c23          	sd	ra,56(sp)
    8000285c:	03213023          	sd	s2,32(sp)
    80002860:	01413823          	sd	s4,16(sp)
    80002864:	01513423          	sd	s5,8(sp)
    80002868:	04010413          	addi	s0,sp,64
    8000286c:	000017b7          	lui	a5,0x1
    80002870:	01100993          	li	s3,17
    80002874:	00f487b3          	add	a5,s1,a5
    80002878:	01b99993          	slli	s3,s3,0x1b
    8000287c:	06f9e063          	bltu	s3,a5,800028dc <kinit+0xa4>
    80002880:	00003a97          	auipc	s5,0x3
    80002884:	d60a8a93          	addi	s5,s5,-672 # 800055e0 <end>
    80002888:	0754ec63          	bltu	s1,s5,80002900 <kinit+0xc8>
    8000288c:	0734fa63          	bgeu	s1,s3,80002900 <kinit+0xc8>
    80002890:	00088a37          	lui	s4,0x88
    80002894:	fffa0a13          	addi	s4,s4,-1 # 87fff <_entry-0x7ff78001>
    80002898:	00002917          	auipc	s2,0x2
    8000289c:	af090913          	addi	s2,s2,-1296 # 80004388 <kmem>
    800028a0:	00ca1a13          	slli	s4,s4,0xc
    800028a4:	0140006f          	j	800028b8 <kinit+0x80>
    800028a8:	000017b7          	lui	a5,0x1
    800028ac:	00f484b3          	add	s1,s1,a5
    800028b0:	0554e863          	bltu	s1,s5,80002900 <kinit+0xc8>
    800028b4:	0534f663          	bgeu	s1,s3,80002900 <kinit+0xc8>
    800028b8:	00001637          	lui	a2,0x1
    800028bc:	00100593          	li	a1,1
    800028c0:	00048513          	mv	a0,s1
    800028c4:	00000097          	auipc	ra,0x0
    800028c8:	5e4080e7          	jalr	1508(ra) # 80002ea8 <__memset>
    800028cc:	00093783          	ld	a5,0(s2)
    800028d0:	00f4b023          	sd	a5,0(s1)
    800028d4:	00993023          	sd	s1,0(s2)
    800028d8:	fd4498e3          	bne	s1,s4,800028a8 <kinit+0x70>
    800028dc:	03813083          	ld	ra,56(sp)
    800028e0:	03013403          	ld	s0,48(sp)
    800028e4:	02813483          	ld	s1,40(sp)
    800028e8:	02013903          	ld	s2,32(sp)
    800028ec:	01813983          	ld	s3,24(sp)
    800028f0:	01013a03          	ld	s4,16(sp)
    800028f4:	00813a83          	ld	s5,8(sp)
    800028f8:	04010113          	addi	sp,sp,64
    800028fc:	00008067          	ret
    80002900:	00002517          	auipc	a0,0x2
    80002904:	8f050513          	addi	a0,a0,-1808 # 800041f0 <digits+0x18>
    80002908:	fffff097          	auipc	ra,0xfffff
    8000290c:	4b4080e7          	jalr	1204(ra) # 80001dbc <panic>

0000000080002910 <freerange>:
    80002910:	fc010113          	addi	sp,sp,-64
    80002914:	000017b7          	lui	a5,0x1
    80002918:	02913423          	sd	s1,40(sp)
    8000291c:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80002920:	009504b3          	add	s1,a0,s1
    80002924:	fffff537          	lui	a0,0xfffff
    80002928:	02813823          	sd	s0,48(sp)
    8000292c:	02113c23          	sd	ra,56(sp)
    80002930:	03213023          	sd	s2,32(sp)
    80002934:	01313c23          	sd	s3,24(sp)
    80002938:	01413823          	sd	s4,16(sp)
    8000293c:	01513423          	sd	s5,8(sp)
    80002940:	01613023          	sd	s6,0(sp)
    80002944:	04010413          	addi	s0,sp,64
    80002948:	00a4f4b3          	and	s1,s1,a0
    8000294c:	00f487b3          	add	a5,s1,a5
    80002950:	06f5e463          	bltu	a1,a5,800029b8 <freerange+0xa8>
    80002954:	00003a97          	auipc	s5,0x3
    80002958:	c8ca8a93          	addi	s5,s5,-884 # 800055e0 <end>
    8000295c:	0954e263          	bltu	s1,s5,800029e0 <freerange+0xd0>
    80002960:	01100993          	li	s3,17
    80002964:	01b99993          	slli	s3,s3,0x1b
    80002968:	0734fc63          	bgeu	s1,s3,800029e0 <freerange+0xd0>
    8000296c:	00058a13          	mv	s4,a1
    80002970:	00002917          	auipc	s2,0x2
    80002974:	a1890913          	addi	s2,s2,-1512 # 80004388 <kmem>
    80002978:	00002b37          	lui	s6,0x2
    8000297c:	0140006f          	j	80002990 <freerange+0x80>
    80002980:	000017b7          	lui	a5,0x1
    80002984:	00f484b3          	add	s1,s1,a5
    80002988:	0554ec63          	bltu	s1,s5,800029e0 <freerange+0xd0>
    8000298c:	0534fa63          	bgeu	s1,s3,800029e0 <freerange+0xd0>
    80002990:	00001637          	lui	a2,0x1
    80002994:	00100593          	li	a1,1
    80002998:	00048513          	mv	a0,s1
    8000299c:	00000097          	auipc	ra,0x0
    800029a0:	50c080e7          	jalr	1292(ra) # 80002ea8 <__memset>
    800029a4:	00093703          	ld	a4,0(s2)
    800029a8:	016487b3          	add	a5,s1,s6
    800029ac:	00e4b023          	sd	a4,0(s1)
    800029b0:	00993023          	sd	s1,0(s2)
    800029b4:	fcfa76e3          	bgeu	s4,a5,80002980 <freerange+0x70>
    800029b8:	03813083          	ld	ra,56(sp)
    800029bc:	03013403          	ld	s0,48(sp)
    800029c0:	02813483          	ld	s1,40(sp)
    800029c4:	02013903          	ld	s2,32(sp)
    800029c8:	01813983          	ld	s3,24(sp)
    800029cc:	01013a03          	ld	s4,16(sp)
    800029d0:	00813a83          	ld	s5,8(sp)
    800029d4:	00013b03          	ld	s6,0(sp)
    800029d8:	04010113          	addi	sp,sp,64
    800029dc:	00008067          	ret
    800029e0:	00002517          	auipc	a0,0x2
    800029e4:	81050513          	addi	a0,a0,-2032 # 800041f0 <digits+0x18>
    800029e8:	fffff097          	auipc	ra,0xfffff
    800029ec:	3d4080e7          	jalr	980(ra) # 80001dbc <panic>

00000000800029f0 <kfree>:
    800029f0:	fe010113          	addi	sp,sp,-32
    800029f4:	00813823          	sd	s0,16(sp)
    800029f8:	00113c23          	sd	ra,24(sp)
    800029fc:	00913423          	sd	s1,8(sp)
    80002a00:	02010413          	addi	s0,sp,32
    80002a04:	03451793          	slli	a5,a0,0x34
    80002a08:	04079c63          	bnez	a5,80002a60 <kfree+0x70>
    80002a0c:	00003797          	auipc	a5,0x3
    80002a10:	bd478793          	addi	a5,a5,-1068 # 800055e0 <end>
    80002a14:	00050493          	mv	s1,a0
    80002a18:	04f56463          	bltu	a0,a5,80002a60 <kfree+0x70>
    80002a1c:	01100793          	li	a5,17
    80002a20:	01b79793          	slli	a5,a5,0x1b
    80002a24:	02f57e63          	bgeu	a0,a5,80002a60 <kfree+0x70>
    80002a28:	00001637          	lui	a2,0x1
    80002a2c:	00100593          	li	a1,1
    80002a30:	00000097          	auipc	ra,0x0
    80002a34:	478080e7          	jalr	1144(ra) # 80002ea8 <__memset>
    80002a38:	00002797          	auipc	a5,0x2
    80002a3c:	95078793          	addi	a5,a5,-1712 # 80004388 <kmem>
    80002a40:	0007b703          	ld	a4,0(a5)
    80002a44:	01813083          	ld	ra,24(sp)
    80002a48:	01013403          	ld	s0,16(sp)
    80002a4c:	00e4b023          	sd	a4,0(s1)
    80002a50:	0097b023          	sd	s1,0(a5)
    80002a54:	00813483          	ld	s1,8(sp)
    80002a58:	02010113          	addi	sp,sp,32
    80002a5c:	00008067          	ret
    80002a60:	00001517          	auipc	a0,0x1
    80002a64:	79050513          	addi	a0,a0,1936 # 800041f0 <digits+0x18>
    80002a68:	fffff097          	auipc	ra,0xfffff
    80002a6c:	354080e7          	jalr	852(ra) # 80001dbc <panic>

0000000080002a70 <kalloc>:
    80002a70:	fe010113          	addi	sp,sp,-32
    80002a74:	00813823          	sd	s0,16(sp)
    80002a78:	00913423          	sd	s1,8(sp)
    80002a7c:	00113c23          	sd	ra,24(sp)
    80002a80:	02010413          	addi	s0,sp,32
    80002a84:	00002797          	auipc	a5,0x2
    80002a88:	90478793          	addi	a5,a5,-1788 # 80004388 <kmem>
    80002a8c:	0007b483          	ld	s1,0(a5)
    80002a90:	02048063          	beqz	s1,80002ab0 <kalloc+0x40>
    80002a94:	0004b703          	ld	a4,0(s1)
    80002a98:	00001637          	lui	a2,0x1
    80002a9c:	00500593          	li	a1,5
    80002aa0:	00048513          	mv	a0,s1
    80002aa4:	00e7b023          	sd	a4,0(a5)
    80002aa8:	00000097          	auipc	ra,0x0
    80002aac:	400080e7          	jalr	1024(ra) # 80002ea8 <__memset>
    80002ab0:	01813083          	ld	ra,24(sp)
    80002ab4:	01013403          	ld	s0,16(sp)
    80002ab8:	00048513          	mv	a0,s1
    80002abc:	00813483          	ld	s1,8(sp)
    80002ac0:	02010113          	addi	sp,sp,32
    80002ac4:	00008067          	ret

0000000080002ac8 <initlock>:
    80002ac8:	ff010113          	addi	sp,sp,-16
    80002acc:	00813423          	sd	s0,8(sp)
    80002ad0:	01010413          	addi	s0,sp,16
    80002ad4:	00813403          	ld	s0,8(sp)
    80002ad8:	00b53423          	sd	a1,8(a0)
    80002adc:	00052023          	sw	zero,0(a0)
    80002ae0:	00053823          	sd	zero,16(a0)
    80002ae4:	01010113          	addi	sp,sp,16
    80002ae8:	00008067          	ret

0000000080002aec <acquire>:
    80002aec:	fe010113          	addi	sp,sp,-32
    80002af0:	00813823          	sd	s0,16(sp)
    80002af4:	00913423          	sd	s1,8(sp)
    80002af8:	00113c23          	sd	ra,24(sp)
    80002afc:	01213023          	sd	s2,0(sp)
    80002b00:	02010413          	addi	s0,sp,32
    80002b04:	00050493          	mv	s1,a0
    80002b08:	10002973          	csrr	s2,sstatus
    80002b0c:	100027f3          	csrr	a5,sstatus
    80002b10:	ffd7f793          	andi	a5,a5,-3
    80002b14:	10079073          	csrw	sstatus,a5
    80002b18:	fffff097          	auipc	ra,0xfffff
    80002b1c:	8e0080e7          	jalr	-1824(ra) # 800013f8 <mycpu>
    80002b20:	07852783          	lw	a5,120(a0)
    80002b24:	06078e63          	beqz	a5,80002ba0 <acquire+0xb4>
    80002b28:	fffff097          	auipc	ra,0xfffff
    80002b2c:	8d0080e7          	jalr	-1840(ra) # 800013f8 <mycpu>
    80002b30:	07852783          	lw	a5,120(a0)
    80002b34:	0004a703          	lw	a4,0(s1)
    80002b38:	0017879b          	addiw	a5,a5,1
    80002b3c:	06f52c23          	sw	a5,120(a0)
    80002b40:	04071063          	bnez	a4,80002b80 <acquire+0x94>
    80002b44:	00100713          	li	a4,1
    80002b48:	00070793          	mv	a5,a4
    80002b4c:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80002b50:	0007879b          	sext.w	a5,a5
    80002b54:	fe079ae3          	bnez	a5,80002b48 <acquire+0x5c>
    80002b58:	0ff0000f          	fence
    80002b5c:	fffff097          	auipc	ra,0xfffff
    80002b60:	89c080e7          	jalr	-1892(ra) # 800013f8 <mycpu>
    80002b64:	01813083          	ld	ra,24(sp)
    80002b68:	01013403          	ld	s0,16(sp)
    80002b6c:	00a4b823          	sd	a0,16(s1)
    80002b70:	00013903          	ld	s2,0(sp)
    80002b74:	00813483          	ld	s1,8(sp)
    80002b78:	02010113          	addi	sp,sp,32
    80002b7c:	00008067          	ret
    80002b80:	0104b903          	ld	s2,16(s1)
    80002b84:	fffff097          	auipc	ra,0xfffff
    80002b88:	874080e7          	jalr	-1932(ra) # 800013f8 <mycpu>
    80002b8c:	faa91ce3          	bne	s2,a0,80002b44 <acquire+0x58>
    80002b90:	00001517          	auipc	a0,0x1
    80002b94:	66850513          	addi	a0,a0,1640 # 800041f8 <digits+0x20>
    80002b98:	fffff097          	auipc	ra,0xfffff
    80002b9c:	224080e7          	jalr	548(ra) # 80001dbc <panic>
    80002ba0:	00195913          	srli	s2,s2,0x1
    80002ba4:	fffff097          	auipc	ra,0xfffff
    80002ba8:	854080e7          	jalr	-1964(ra) # 800013f8 <mycpu>
    80002bac:	00197913          	andi	s2,s2,1
    80002bb0:	07252e23          	sw	s2,124(a0)
    80002bb4:	f75ff06f          	j	80002b28 <acquire+0x3c>

0000000080002bb8 <release>:
    80002bb8:	fe010113          	addi	sp,sp,-32
    80002bbc:	00813823          	sd	s0,16(sp)
    80002bc0:	00113c23          	sd	ra,24(sp)
    80002bc4:	00913423          	sd	s1,8(sp)
    80002bc8:	01213023          	sd	s2,0(sp)
    80002bcc:	02010413          	addi	s0,sp,32
    80002bd0:	00052783          	lw	a5,0(a0)
    80002bd4:	00079a63          	bnez	a5,80002be8 <release+0x30>
    80002bd8:	00001517          	auipc	a0,0x1
    80002bdc:	62850513          	addi	a0,a0,1576 # 80004200 <digits+0x28>
    80002be0:	fffff097          	auipc	ra,0xfffff
    80002be4:	1dc080e7          	jalr	476(ra) # 80001dbc <panic>
    80002be8:	01053903          	ld	s2,16(a0)
    80002bec:	00050493          	mv	s1,a0
    80002bf0:	fffff097          	auipc	ra,0xfffff
    80002bf4:	808080e7          	jalr	-2040(ra) # 800013f8 <mycpu>
    80002bf8:	fea910e3          	bne	s2,a0,80002bd8 <release+0x20>
    80002bfc:	0004b823          	sd	zero,16(s1)
    80002c00:	0ff0000f          	fence
    80002c04:	0f50000f          	fence	iorw,ow
    80002c08:	0804a02f          	amoswap.w	zero,zero,(s1)
    80002c0c:	ffffe097          	auipc	ra,0xffffe
    80002c10:	7ec080e7          	jalr	2028(ra) # 800013f8 <mycpu>
    80002c14:	100027f3          	csrr	a5,sstatus
    80002c18:	0027f793          	andi	a5,a5,2
    80002c1c:	04079a63          	bnez	a5,80002c70 <release+0xb8>
    80002c20:	07852783          	lw	a5,120(a0)
    80002c24:	02f05e63          	blez	a5,80002c60 <release+0xa8>
    80002c28:	fff7871b          	addiw	a4,a5,-1
    80002c2c:	06e52c23          	sw	a4,120(a0)
    80002c30:	00071c63          	bnez	a4,80002c48 <release+0x90>
    80002c34:	07c52783          	lw	a5,124(a0)
    80002c38:	00078863          	beqz	a5,80002c48 <release+0x90>
    80002c3c:	100027f3          	csrr	a5,sstatus
    80002c40:	0027e793          	ori	a5,a5,2
    80002c44:	10079073          	csrw	sstatus,a5
    80002c48:	01813083          	ld	ra,24(sp)
    80002c4c:	01013403          	ld	s0,16(sp)
    80002c50:	00813483          	ld	s1,8(sp)
    80002c54:	00013903          	ld	s2,0(sp)
    80002c58:	02010113          	addi	sp,sp,32
    80002c5c:	00008067          	ret
    80002c60:	00001517          	auipc	a0,0x1
    80002c64:	5c050513          	addi	a0,a0,1472 # 80004220 <digits+0x48>
    80002c68:	fffff097          	auipc	ra,0xfffff
    80002c6c:	154080e7          	jalr	340(ra) # 80001dbc <panic>
    80002c70:	00001517          	auipc	a0,0x1
    80002c74:	59850513          	addi	a0,a0,1432 # 80004208 <digits+0x30>
    80002c78:	fffff097          	auipc	ra,0xfffff
    80002c7c:	144080e7          	jalr	324(ra) # 80001dbc <panic>

0000000080002c80 <holding>:
    80002c80:	00052783          	lw	a5,0(a0)
    80002c84:	00079663          	bnez	a5,80002c90 <holding+0x10>
    80002c88:	00000513          	li	a0,0
    80002c8c:	00008067          	ret
    80002c90:	fe010113          	addi	sp,sp,-32
    80002c94:	00813823          	sd	s0,16(sp)
    80002c98:	00913423          	sd	s1,8(sp)
    80002c9c:	00113c23          	sd	ra,24(sp)
    80002ca0:	02010413          	addi	s0,sp,32
    80002ca4:	01053483          	ld	s1,16(a0)
    80002ca8:	ffffe097          	auipc	ra,0xffffe
    80002cac:	750080e7          	jalr	1872(ra) # 800013f8 <mycpu>
    80002cb0:	01813083          	ld	ra,24(sp)
    80002cb4:	01013403          	ld	s0,16(sp)
    80002cb8:	40a48533          	sub	a0,s1,a0
    80002cbc:	00153513          	seqz	a0,a0
    80002cc0:	00813483          	ld	s1,8(sp)
    80002cc4:	02010113          	addi	sp,sp,32
    80002cc8:	00008067          	ret

0000000080002ccc <push_off>:
    80002ccc:	fe010113          	addi	sp,sp,-32
    80002cd0:	00813823          	sd	s0,16(sp)
    80002cd4:	00113c23          	sd	ra,24(sp)
    80002cd8:	00913423          	sd	s1,8(sp)
    80002cdc:	02010413          	addi	s0,sp,32
    80002ce0:	100024f3          	csrr	s1,sstatus
    80002ce4:	100027f3          	csrr	a5,sstatus
    80002ce8:	ffd7f793          	andi	a5,a5,-3
    80002cec:	10079073          	csrw	sstatus,a5
    80002cf0:	ffffe097          	auipc	ra,0xffffe
    80002cf4:	708080e7          	jalr	1800(ra) # 800013f8 <mycpu>
    80002cf8:	07852783          	lw	a5,120(a0)
    80002cfc:	02078663          	beqz	a5,80002d28 <push_off+0x5c>
    80002d00:	ffffe097          	auipc	ra,0xffffe
    80002d04:	6f8080e7          	jalr	1784(ra) # 800013f8 <mycpu>
    80002d08:	07852783          	lw	a5,120(a0)
    80002d0c:	01813083          	ld	ra,24(sp)
    80002d10:	01013403          	ld	s0,16(sp)
    80002d14:	0017879b          	addiw	a5,a5,1
    80002d18:	06f52c23          	sw	a5,120(a0)
    80002d1c:	00813483          	ld	s1,8(sp)
    80002d20:	02010113          	addi	sp,sp,32
    80002d24:	00008067          	ret
    80002d28:	0014d493          	srli	s1,s1,0x1
    80002d2c:	ffffe097          	auipc	ra,0xffffe
    80002d30:	6cc080e7          	jalr	1740(ra) # 800013f8 <mycpu>
    80002d34:	0014f493          	andi	s1,s1,1
    80002d38:	06952e23          	sw	s1,124(a0)
    80002d3c:	fc5ff06f          	j	80002d00 <push_off+0x34>

0000000080002d40 <pop_off>:
    80002d40:	ff010113          	addi	sp,sp,-16
    80002d44:	00813023          	sd	s0,0(sp)
    80002d48:	00113423          	sd	ra,8(sp)
    80002d4c:	01010413          	addi	s0,sp,16
    80002d50:	ffffe097          	auipc	ra,0xffffe
    80002d54:	6a8080e7          	jalr	1704(ra) # 800013f8 <mycpu>
    80002d58:	100027f3          	csrr	a5,sstatus
    80002d5c:	0027f793          	andi	a5,a5,2
    80002d60:	04079663          	bnez	a5,80002dac <pop_off+0x6c>
    80002d64:	07852783          	lw	a5,120(a0)
    80002d68:	02f05a63          	blez	a5,80002d9c <pop_off+0x5c>
    80002d6c:	fff7871b          	addiw	a4,a5,-1
    80002d70:	06e52c23          	sw	a4,120(a0)
    80002d74:	00071c63          	bnez	a4,80002d8c <pop_off+0x4c>
    80002d78:	07c52783          	lw	a5,124(a0)
    80002d7c:	00078863          	beqz	a5,80002d8c <pop_off+0x4c>
    80002d80:	100027f3          	csrr	a5,sstatus
    80002d84:	0027e793          	ori	a5,a5,2
    80002d88:	10079073          	csrw	sstatus,a5
    80002d8c:	00813083          	ld	ra,8(sp)
    80002d90:	00013403          	ld	s0,0(sp)
    80002d94:	01010113          	addi	sp,sp,16
    80002d98:	00008067          	ret
    80002d9c:	00001517          	auipc	a0,0x1
    80002da0:	48450513          	addi	a0,a0,1156 # 80004220 <digits+0x48>
    80002da4:	fffff097          	auipc	ra,0xfffff
    80002da8:	018080e7          	jalr	24(ra) # 80001dbc <panic>
    80002dac:	00001517          	auipc	a0,0x1
    80002db0:	45c50513          	addi	a0,a0,1116 # 80004208 <digits+0x30>
    80002db4:	fffff097          	auipc	ra,0xfffff
    80002db8:	008080e7          	jalr	8(ra) # 80001dbc <panic>

0000000080002dbc <push_on>:
    80002dbc:	fe010113          	addi	sp,sp,-32
    80002dc0:	00813823          	sd	s0,16(sp)
    80002dc4:	00113c23          	sd	ra,24(sp)
    80002dc8:	00913423          	sd	s1,8(sp)
    80002dcc:	02010413          	addi	s0,sp,32
    80002dd0:	100024f3          	csrr	s1,sstatus
    80002dd4:	100027f3          	csrr	a5,sstatus
    80002dd8:	0027e793          	ori	a5,a5,2
    80002ddc:	10079073          	csrw	sstatus,a5
    80002de0:	ffffe097          	auipc	ra,0xffffe
    80002de4:	618080e7          	jalr	1560(ra) # 800013f8 <mycpu>
    80002de8:	07852783          	lw	a5,120(a0)
    80002dec:	02078663          	beqz	a5,80002e18 <push_on+0x5c>
    80002df0:	ffffe097          	auipc	ra,0xffffe
    80002df4:	608080e7          	jalr	1544(ra) # 800013f8 <mycpu>
    80002df8:	07852783          	lw	a5,120(a0)
    80002dfc:	01813083          	ld	ra,24(sp)
    80002e00:	01013403          	ld	s0,16(sp)
    80002e04:	0017879b          	addiw	a5,a5,1
    80002e08:	06f52c23          	sw	a5,120(a0)
    80002e0c:	00813483          	ld	s1,8(sp)
    80002e10:	02010113          	addi	sp,sp,32
    80002e14:	00008067          	ret
    80002e18:	0014d493          	srli	s1,s1,0x1
    80002e1c:	ffffe097          	auipc	ra,0xffffe
    80002e20:	5dc080e7          	jalr	1500(ra) # 800013f8 <mycpu>
    80002e24:	0014f493          	andi	s1,s1,1
    80002e28:	06952e23          	sw	s1,124(a0)
    80002e2c:	fc5ff06f          	j	80002df0 <push_on+0x34>

0000000080002e30 <pop_on>:
    80002e30:	ff010113          	addi	sp,sp,-16
    80002e34:	00813023          	sd	s0,0(sp)
    80002e38:	00113423          	sd	ra,8(sp)
    80002e3c:	01010413          	addi	s0,sp,16
    80002e40:	ffffe097          	auipc	ra,0xffffe
    80002e44:	5b8080e7          	jalr	1464(ra) # 800013f8 <mycpu>
    80002e48:	100027f3          	csrr	a5,sstatus
    80002e4c:	0027f793          	andi	a5,a5,2
    80002e50:	04078463          	beqz	a5,80002e98 <pop_on+0x68>
    80002e54:	07852783          	lw	a5,120(a0)
    80002e58:	02f05863          	blez	a5,80002e88 <pop_on+0x58>
    80002e5c:	fff7879b          	addiw	a5,a5,-1
    80002e60:	06f52c23          	sw	a5,120(a0)
    80002e64:	07853783          	ld	a5,120(a0)
    80002e68:	00079863          	bnez	a5,80002e78 <pop_on+0x48>
    80002e6c:	100027f3          	csrr	a5,sstatus
    80002e70:	ffd7f793          	andi	a5,a5,-3
    80002e74:	10079073          	csrw	sstatus,a5
    80002e78:	00813083          	ld	ra,8(sp)
    80002e7c:	00013403          	ld	s0,0(sp)
    80002e80:	01010113          	addi	sp,sp,16
    80002e84:	00008067          	ret
    80002e88:	00001517          	auipc	a0,0x1
    80002e8c:	3c050513          	addi	a0,a0,960 # 80004248 <digits+0x70>
    80002e90:	fffff097          	auipc	ra,0xfffff
    80002e94:	f2c080e7          	jalr	-212(ra) # 80001dbc <panic>
    80002e98:	00001517          	auipc	a0,0x1
    80002e9c:	39050513          	addi	a0,a0,912 # 80004228 <digits+0x50>
    80002ea0:	fffff097          	auipc	ra,0xfffff
    80002ea4:	f1c080e7          	jalr	-228(ra) # 80001dbc <panic>

0000000080002ea8 <__memset>:
    80002ea8:	ff010113          	addi	sp,sp,-16
    80002eac:	00813423          	sd	s0,8(sp)
    80002eb0:	01010413          	addi	s0,sp,16
    80002eb4:	1a060e63          	beqz	a2,80003070 <__memset+0x1c8>
    80002eb8:	40a007b3          	neg	a5,a0
    80002ebc:	0077f793          	andi	a5,a5,7
    80002ec0:	00778693          	addi	a3,a5,7
    80002ec4:	00b00813          	li	a6,11
    80002ec8:	0ff5f593          	andi	a1,a1,255
    80002ecc:	fff6071b          	addiw	a4,a2,-1
    80002ed0:	1b06e663          	bltu	a3,a6,8000307c <__memset+0x1d4>
    80002ed4:	1cd76463          	bltu	a4,a3,8000309c <__memset+0x1f4>
    80002ed8:	1a078e63          	beqz	a5,80003094 <__memset+0x1ec>
    80002edc:	00b50023          	sb	a1,0(a0)
    80002ee0:	00100713          	li	a4,1
    80002ee4:	1ae78463          	beq	a5,a4,8000308c <__memset+0x1e4>
    80002ee8:	00b500a3          	sb	a1,1(a0)
    80002eec:	00200713          	li	a4,2
    80002ef0:	1ae78a63          	beq	a5,a4,800030a4 <__memset+0x1fc>
    80002ef4:	00b50123          	sb	a1,2(a0)
    80002ef8:	00300713          	li	a4,3
    80002efc:	18e78463          	beq	a5,a4,80003084 <__memset+0x1dc>
    80002f00:	00b501a3          	sb	a1,3(a0)
    80002f04:	00400713          	li	a4,4
    80002f08:	1ae78263          	beq	a5,a4,800030ac <__memset+0x204>
    80002f0c:	00b50223          	sb	a1,4(a0)
    80002f10:	00500713          	li	a4,5
    80002f14:	1ae78063          	beq	a5,a4,800030b4 <__memset+0x20c>
    80002f18:	00b502a3          	sb	a1,5(a0)
    80002f1c:	00700713          	li	a4,7
    80002f20:	18e79e63          	bne	a5,a4,800030bc <__memset+0x214>
    80002f24:	00b50323          	sb	a1,6(a0)
    80002f28:	00700e93          	li	t4,7
    80002f2c:	00859713          	slli	a4,a1,0x8
    80002f30:	00e5e733          	or	a4,a1,a4
    80002f34:	01059e13          	slli	t3,a1,0x10
    80002f38:	01c76e33          	or	t3,a4,t3
    80002f3c:	01859313          	slli	t1,a1,0x18
    80002f40:	006e6333          	or	t1,t3,t1
    80002f44:	02059893          	slli	a7,a1,0x20
    80002f48:	40f60e3b          	subw	t3,a2,a5
    80002f4c:	011368b3          	or	a7,t1,a7
    80002f50:	02859813          	slli	a6,a1,0x28
    80002f54:	0108e833          	or	a6,a7,a6
    80002f58:	03059693          	slli	a3,a1,0x30
    80002f5c:	003e589b          	srliw	a7,t3,0x3
    80002f60:	00d866b3          	or	a3,a6,a3
    80002f64:	03859713          	slli	a4,a1,0x38
    80002f68:	00389813          	slli	a6,a7,0x3
    80002f6c:	00f507b3          	add	a5,a0,a5
    80002f70:	00e6e733          	or	a4,a3,a4
    80002f74:	000e089b          	sext.w	a7,t3
    80002f78:	00f806b3          	add	a3,a6,a5
    80002f7c:	00e7b023          	sd	a4,0(a5)
    80002f80:	00878793          	addi	a5,a5,8
    80002f84:	fed79ce3          	bne	a5,a3,80002f7c <__memset+0xd4>
    80002f88:	ff8e7793          	andi	a5,t3,-8
    80002f8c:	0007871b          	sext.w	a4,a5
    80002f90:	01d787bb          	addw	a5,a5,t4
    80002f94:	0ce88e63          	beq	a7,a4,80003070 <__memset+0x1c8>
    80002f98:	00f50733          	add	a4,a0,a5
    80002f9c:	00b70023          	sb	a1,0(a4)
    80002fa0:	0017871b          	addiw	a4,a5,1
    80002fa4:	0cc77663          	bgeu	a4,a2,80003070 <__memset+0x1c8>
    80002fa8:	00e50733          	add	a4,a0,a4
    80002fac:	00b70023          	sb	a1,0(a4)
    80002fb0:	0027871b          	addiw	a4,a5,2
    80002fb4:	0ac77e63          	bgeu	a4,a2,80003070 <__memset+0x1c8>
    80002fb8:	00e50733          	add	a4,a0,a4
    80002fbc:	00b70023          	sb	a1,0(a4)
    80002fc0:	0037871b          	addiw	a4,a5,3
    80002fc4:	0ac77663          	bgeu	a4,a2,80003070 <__memset+0x1c8>
    80002fc8:	00e50733          	add	a4,a0,a4
    80002fcc:	00b70023          	sb	a1,0(a4)
    80002fd0:	0047871b          	addiw	a4,a5,4
    80002fd4:	08c77e63          	bgeu	a4,a2,80003070 <__memset+0x1c8>
    80002fd8:	00e50733          	add	a4,a0,a4
    80002fdc:	00b70023          	sb	a1,0(a4)
    80002fe0:	0057871b          	addiw	a4,a5,5
    80002fe4:	08c77663          	bgeu	a4,a2,80003070 <__memset+0x1c8>
    80002fe8:	00e50733          	add	a4,a0,a4
    80002fec:	00b70023          	sb	a1,0(a4)
    80002ff0:	0067871b          	addiw	a4,a5,6
    80002ff4:	06c77e63          	bgeu	a4,a2,80003070 <__memset+0x1c8>
    80002ff8:	00e50733          	add	a4,a0,a4
    80002ffc:	00b70023          	sb	a1,0(a4)
    80003000:	0077871b          	addiw	a4,a5,7
    80003004:	06c77663          	bgeu	a4,a2,80003070 <__memset+0x1c8>
    80003008:	00e50733          	add	a4,a0,a4
    8000300c:	00b70023          	sb	a1,0(a4)
    80003010:	0087871b          	addiw	a4,a5,8
    80003014:	04c77e63          	bgeu	a4,a2,80003070 <__memset+0x1c8>
    80003018:	00e50733          	add	a4,a0,a4
    8000301c:	00b70023          	sb	a1,0(a4)
    80003020:	0097871b          	addiw	a4,a5,9
    80003024:	04c77663          	bgeu	a4,a2,80003070 <__memset+0x1c8>
    80003028:	00e50733          	add	a4,a0,a4
    8000302c:	00b70023          	sb	a1,0(a4)
    80003030:	00a7871b          	addiw	a4,a5,10
    80003034:	02c77e63          	bgeu	a4,a2,80003070 <__memset+0x1c8>
    80003038:	00e50733          	add	a4,a0,a4
    8000303c:	00b70023          	sb	a1,0(a4)
    80003040:	00b7871b          	addiw	a4,a5,11
    80003044:	02c77663          	bgeu	a4,a2,80003070 <__memset+0x1c8>
    80003048:	00e50733          	add	a4,a0,a4
    8000304c:	00b70023          	sb	a1,0(a4)
    80003050:	00c7871b          	addiw	a4,a5,12
    80003054:	00c77e63          	bgeu	a4,a2,80003070 <__memset+0x1c8>
    80003058:	00e50733          	add	a4,a0,a4
    8000305c:	00b70023          	sb	a1,0(a4)
    80003060:	00d7879b          	addiw	a5,a5,13
    80003064:	00c7f663          	bgeu	a5,a2,80003070 <__memset+0x1c8>
    80003068:	00f507b3          	add	a5,a0,a5
    8000306c:	00b78023          	sb	a1,0(a5)
    80003070:	00813403          	ld	s0,8(sp)
    80003074:	01010113          	addi	sp,sp,16
    80003078:	00008067          	ret
    8000307c:	00b00693          	li	a3,11
    80003080:	e55ff06f          	j	80002ed4 <__memset+0x2c>
    80003084:	00300e93          	li	t4,3
    80003088:	ea5ff06f          	j	80002f2c <__memset+0x84>
    8000308c:	00100e93          	li	t4,1
    80003090:	e9dff06f          	j	80002f2c <__memset+0x84>
    80003094:	00000e93          	li	t4,0
    80003098:	e95ff06f          	j	80002f2c <__memset+0x84>
    8000309c:	00000793          	li	a5,0
    800030a0:	ef9ff06f          	j	80002f98 <__memset+0xf0>
    800030a4:	00200e93          	li	t4,2
    800030a8:	e85ff06f          	j	80002f2c <__memset+0x84>
    800030ac:	00400e93          	li	t4,4
    800030b0:	e7dff06f          	j	80002f2c <__memset+0x84>
    800030b4:	00500e93          	li	t4,5
    800030b8:	e75ff06f          	j	80002f2c <__memset+0x84>
    800030bc:	00600e93          	li	t4,6
    800030c0:	e6dff06f          	j	80002f2c <__memset+0x84>

00000000800030c4 <__memmove>:
    800030c4:	ff010113          	addi	sp,sp,-16
    800030c8:	00813423          	sd	s0,8(sp)
    800030cc:	01010413          	addi	s0,sp,16
    800030d0:	0e060863          	beqz	a2,800031c0 <__memmove+0xfc>
    800030d4:	fff6069b          	addiw	a3,a2,-1
    800030d8:	0006881b          	sext.w	a6,a3
    800030dc:	0ea5e863          	bltu	a1,a0,800031cc <__memmove+0x108>
    800030e0:	00758713          	addi	a4,a1,7
    800030e4:	00a5e7b3          	or	a5,a1,a0
    800030e8:	40a70733          	sub	a4,a4,a0
    800030ec:	0077f793          	andi	a5,a5,7
    800030f0:	00f73713          	sltiu	a4,a4,15
    800030f4:	00174713          	xori	a4,a4,1
    800030f8:	0017b793          	seqz	a5,a5
    800030fc:	00e7f7b3          	and	a5,a5,a4
    80003100:	10078863          	beqz	a5,80003210 <__memmove+0x14c>
    80003104:	00900793          	li	a5,9
    80003108:	1107f463          	bgeu	a5,a6,80003210 <__memmove+0x14c>
    8000310c:	0036581b          	srliw	a6,a2,0x3
    80003110:	fff8081b          	addiw	a6,a6,-1
    80003114:	02081813          	slli	a6,a6,0x20
    80003118:	01d85893          	srli	a7,a6,0x1d
    8000311c:	00858813          	addi	a6,a1,8
    80003120:	00058793          	mv	a5,a1
    80003124:	00050713          	mv	a4,a0
    80003128:	01088833          	add	a6,a7,a6
    8000312c:	0007b883          	ld	a7,0(a5)
    80003130:	00878793          	addi	a5,a5,8
    80003134:	00870713          	addi	a4,a4,8
    80003138:	ff173c23          	sd	a7,-8(a4)
    8000313c:	ff0798e3          	bne	a5,a6,8000312c <__memmove+0x68>
    80003140:	ff867713          	andi	a4,a2,-8
    80003144:	02071793          	slli	a5,a4,0x20
    80003148:	0207d793          	srli	a5,a5,0x20
    8000314c:	00f585b3          	add	a1,a1,a5
    80003150:	40e686bb          	subw	a3,a3,a4
    80003154:	00f507b3          	add	a5,a0,a5
    80003158:	06e60463          	beq	a2,a4,800031c0 <__memmove+0xfc>
    8000315c:	0005c703          	lbu	a4,0(a1)
    80003160:	00e78023          	sb	a4,0(a5)
    80003164:	04068e63          	beqz	a3,800031c0 <__memmove+0xfc>
    80003168:	0015c603          	lbu	a2,1(a1)
    8000316c:	00100713          	li	a4,1
    80003170:	00c780a3          	sb	a2,1(a5)
    80003174:	04e68663          	beq	a3,a4,800031c0 <__memmove+0xfc>
    80003178:	0025c603          	lbu	a2,2(a1)
    8000317c:	00200713          	li	a4,2
    80003180:	00c78123          	sb	a2,2(a5)
    80003184:	02e68e63          	beq	a3,a4,800031c0 <__memmove+0xfc>
    80003188:	0035c603          	lbu	a2,3(a1)
    8000318c:	00300713          	li	a4,3
    80003190:	00c781a3          	sb	a2,3(a5)
    80003194:	02e68663          	beq	a3,a4,800031c0 <__memmove+0xfc>
    80003198:	0045c603          	lbu	a2,4(a1)
    8000319c:	00400713          	li	a4,4
    800031a0:	00c78223          	sb	a2,4(a5)
    800031a4:	00e68e63          	beq	a3,a4,800031c0 <__memmove+0xfc>
    800031a8:	0055c603          	lbu	a2,5(a1)
    800031ac:	00500713          	li	a4,5
    800031b0:	00c782a3          	sb	a2,5(a5)
    800031b4:	00e68663          	beq	a3,a4,800031c0 <__memmove+0xfc>
    800031b8:	0065c703          	lbu	a4,6(a1)
    800031bc:	00e78323          	sb	a4,6(a5)
    800031c0:	00813403          	ld	s0,8(sp)
    800031c4:	01010113          	addi	sp,sp,16
    800031c8:	00008067          	ret
    800031cc:	02061713          	slli	a4,a2,0x20
    800031d0:	02075713          	srli	a4,a4,0x20
    800031d4:	00e587b3          	add	a5,a1,a4
    800031d8:	f0f574e3          	bgeu	a0,a5,800030e0 <__memmove+0x1c>
    800031dc:	02069613          	slli	a2,a3,0x20
    800031e0:	02065613          	srli	a2,a2,0x20
    800031e4:	fff64613          	not	a2,a2
    800031e8:	00e50733          	add	a4,a0,a4
    800031ec:	00c78633          	add	a2,a5,a2
    800031f0:	fff7c683          	lbu	a3,-1(a5)
    800031f4:	fff78793          	addi	a5,a5,-1
    800031f8:	fff70713          	addi	a4,a4,-1
    800031fc:	00d70023          	sb	a3,0(a4)
    80003200:	fec798e3          	bne	a5,a2,800031f0 <__memmove+0x12c>
    80003204:	00813403          	ld	s0,8(sp)
    80003208:	01010113          	addi	sp,sp,16
    8000320c:	00008067          	ret
    80003210:	02069713          	slli	a4,a3,0x20
    80003214:	02075713          	srli	a4,a4,0x20
    80003218:	00170713          	addi	a4,a4,1
    8000321c:	00e50733          	add	a4,a0,a4
    80003220:	00050793          	mv	a5,a0
    80003224:	0005c683          	lbu	a3,0(a1)
    80003228:	00178793          	addi	a5,a5,1
    8000322c:	00158593          	addi	a1,a1,1
    80003230:	fed78fa3          	sb	a3,-1(a5)
    80003234:	fee798e3          	bne	a5,a4,80003224 <__memmove+0x160>
    80003238:	f89ff06f          	j	800031c0 <__memmove+0xfc>
	...
