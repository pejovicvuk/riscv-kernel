
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
    8000001c:	140010ef          	jal	ra,8000115c <start>

0000000080000020 <spin>:
    80000020:	0000006f          	j	80000020 <spin>
	...

0000000080001000 <_Z8userMainv>:
// src/userMain.cpp

extern void kputs(const char* s);   // defined in main.cpp; same build, so this links

void userMain() {
    80001000:	ff010113          	addi	sp,sp,-16
    80001004:	00113423          	sd	ra,8(sp)
    80001008:	00813023          	sd	s0,0(sp)
    8000100c:	01010413          	addi	s0,sp,16
    kputs("   user: hello from userMain\n");
    80001010:	00003517          	auipc	a0,0x3
    80001014:	01050513          	addi	a0,a0,16 # 80004020 <CONSOLE_STATUS+0x10>
    80001018:	00000097          	auipc	ra,0x0
    8000101c:	0a4080e7          	jalr	164(ra) # 800010bc <_Z5kputsPKc>
    80001020:	00813083          	ld	ra,8(sp)
    80001024:	00013403          	ld	s0,0(sp)
    80001028:	01010113          	addi	sp,sp,16
    8000102c:	00008067          	ret

0000000080001030 <_ZN15MemoryAllocator4initEv>:
#include "../h/MemoryAllocator.hpp"
#include "../lib/hw.h"

MemoryAllocator::FreeBlock* MemoryAllocator::freeListHead = nullptr;

int MemoryAllocator::init() {
    80001030:	ff010113          	addi	sp,sp,-16
    80001034:	00813423          	sd	s0,8(sp)
    80001038:	01010413          	addi	s0,sp,16
    freeListHead = (FreeBlock*)HEAP_START_ADDR;
    8000103c:	00003717          	auipc	a4,0x3
    80001040:	2fc70713          	addi	a4,a4,764 # 80004338 <HEAP_START_ADDR>
    80001044:	00073683          	ld	a3,0(a4)
    80001048:	00003797          	auipc	a5,0x3
    8000104c:	31878793          	addi	a5,a5,792 # 80004360 <_ZN15MemoryAllocator12freeListHeadE>
    80001050:	00d7b023          	sd	a3,0(a5)
    freeListHead->next = nullptr;
    80001054:	0006b023          	sd	zero,0(a3)
    freeListHead->size = (char*)HEAP_END_ADDR - (char*)HEAP_START_ADDR;
    80001058:	00073703          	ld	a4,0(a4)
    8000105c:	0007b783          	ld	a5,0(a5)
    80001060:	00003517          	auipc	a0,0x3
    80001064:	2d053503          	ld	a0,720(a0) # 80004330 <HEAP_END_ADDR>
    80001068:	40e50533          	sub	a0,a0,a4
    8000106c:	00a7b423          	sd	a0,8(a5)
    return freeListHead->size;
    80001070:	0005051b          	sext.w	a0,a0
    80001074:	00813403          	ld	s0,8(sp)
    80001078:	01010113          	addi	sp,sp,16
    8000107c:	00008067          	ret

0000000080001080 <_Z5kputcc>:
#include "../lib/hw.h"   // adjust path to wherever your hw.h lives

// Send one character to the console controller.
void kputc(char c) {
    80001080:	ff010113          	addi	sp,sp,-16
    80001084:	00813423          	sd	s0,8(sp)
    80001088:	01010413          	addi	s0,sp,16
    // CONSOLE_STATUS is an address (a constant from hw.h). To read the
    // byte living at that address, we reinterpret the integer address as
    // a pointer-to-volatile-char and dereference it. 'volatile' tells the
    // compiler the value can change outside our code (the hardware sets it),
    // so it must actually re-read memory every loop pass, not cache it.
    while ((*(volatile char*)CONSOLE_STATUS & (1 << 5)) == 0) {
    8000108c:	00003797          	auipc	a5,0x3
    80001090:	f847b783          	ld	a5,-124(a5) # 80004010 <CONSOLE_STATUS>
    80001094:	0007c783          	lbu	a5,0(a5)
    80001098:	0ff7f793          	andi	a5,a5,255
    8000109c:	0207f793          	andi	a5,a5,32
    800010a0:	fe0786e3          	beqz	a5,8000108c <_Z5kputcc+0xc>
        // spin: bit 5 == 0 means "not ready to accept a char to send"
    }
    // Ready. Write the byte into the transmit-data register.
    *(volatile char*)CONSOLE_TX_DATA = c;
    800010a4:	00003797          	auipc	a5,0x3
    800010a8:	f647b783          	ld	a5,-156(a5) # 80004008 <CONSOLE_TX_DATA>
    800010ac:	00a78023          	sb	a0,0(a5)
}
    800010b0:	00813403          	ld	s0,8(sp)
    800010b4:	01010113          	addi	sp,sp,16
    800010b8:	00008067          	ret

00000000800010bc <_Z5kputsPKc>:

// Convenience: print a whole string by sending char by char.
void kputs(const char* s) {
    800010bc:	fe010113          	addi	sp,sp,-32
    800010c0:	00113c23          	sd	ra,24(sp)
    800010c4:	00813823          	sd	s0,16(sp)
    800010c8:	00913423          	sd	s1,8(sp)
    800010cc:	02010413          	addi	s0,sp,32
    800010d0:	00050493          	mv	s1,a0
    while (*s) kputc(*s++);
    800010d4:	0004c503          	lbu	a0,0(s1)
    800010d8:	00050a63          	beqz	a0,800010ec <_Z5kputsPKc+0x30>
    800010dc:	00148493          	addi	s1,s1,1
    800010e0:	00000097          	auipc	ra,0x0
    800010e4:	fa0080e7          	jalr	-96(ra) # 80001080 <_Z5kputcc>
    800010e8:	fedff06f          	j	800010d4 <_Z5kputsPKc+0x18>
}
    800010ec:	01813083          	ld	ra,24(sp)
    800010f0:	01013403          	ld	s0,16(sp)
    800010f4:	00813483          	ld	s1,8(sp)
    800010f8:	02010113          	addi	sp,sp,32
    800010fc:	00008067          	ret

0000000080001100 <main>:

void userMain();   // forward declaration: defined elsewhere (your test file)

int main() {
    80001100:	ff010113          	addi	sp,sp,-16
    80001104:	00113423          	sd	ra,8(sp)
    80001108:	00813023          	sd	s0,0(sp)
    8000110c:	01010413          	addi	s0,sp,16
    kputs(">> kernel: starting\n");
    80001110:	00003517          	auipc	a0,0x3
    80001114:	f3050513          	addi	a0,a0,-208 # 80004040 <CONSOLE_STATUS+0x30>
    80001118:	00000097          	auipc	ra,0x0
    8000111c:	fa4080e7          	jalr	-92(ra) # 800010bc <_Z5kputsPKc>

    userMain();    // THE CHEAT: calling it as a plain function for now.
    80001120:	00000097          	auipc	ra,0x0
    80001124:	ee0080e7          	jalr	-288(ra) # 80001000 <_Z8userMainv>
                   // In the real kernel this becomes "wrap userMain as the
                   // body of the first thread and let the scheduler run it."

    kputs(">> kernel: userMain returned, halting\n");
    80001128:	00003517          	auipc	a0,0x3
    8000112c:	f3050513          	addi	a0,a0,-208 # 80004058 <CONSOLE_STATUS+0x48>
    80001130:	00000097          	auipc	ra,0x0
    80001134:	f8c080e7          	jalr	-116(ra) # 800010bc <_Z5kputsPKc>

    // Halt the emulator: writing the 32-bit value 0x5555 to physical
    // address 0x100000 is qemu's "guest asked to power off" signal, so
    // `make qemu` returns to your shell instead of hanging.
    *(volatile int*)0x100000 = 0x5555;
    80001138:	00100737          	lui	a4,0x100
    8000113c:	000057b7          	lui	a5,0x5
    80001140:	5557879b          	addiw	a5,a5,1365
    80001144:	00f72023          	sw	a5,0(a4) # 100000 <_entry-0x7ff00000>

    return 0;   // never really reached, but keeps the signature honest
    80001148:	00000513          	li	a0,0
    8000114c:	00813083          	ld	ra,8(sp)
    80001150:	00013403          	ld	s0,0(sp)
    80001154:	01010113          	addi	sp,sp,16
    80001158:	00008067          	ret

000000008000115c <start>:
    8000115c:	ff010113          	addi	sp,sp,-16
    80001160:	00813423          	sd	s0,8(sp)
    80001164:	01010413          	addi	s0,sp,16
    80001168:	300027f3          	csrr	a5,mstatus
    8000116c:	ffffe737          	lui	a4,0xffffe
    80001170:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fff921f>
    80001174:	00e7f7b3          	and	a5,a5,a4
    80001178:	00001737          	lui	a4,0x1
    8000117c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80001180:	00e7e7b3          	or	a5,a5,a4
    80001184:	30079073          	csrw	mstatus,a5
    80001188:	00000797          	auipc	a5,0x0
    8000118c:	16078793          	addi	a5,a5,352 # 800012e8 <system_main>
    80001190:	34179073          	csrw	mepc,a5
    80001194:	00000793          	li	a5,0
    80001198:	18079073          	csrw	satp,a5
    8000119c:	000107b7          	lui	a5,0x10
    800011a0:	fff78793          	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800011a4:	30279073          	csrw	medeleg,a5
    800011a8:	30379073          	csrw	mideleg,a5
    800011ac:	104027f3          	csrr	a5,sie
    800011b0:	2227e793          	ori	a5,a5,546
    800011b4:	10479073          	csrw	sie,a5
    800011b8:	fff00793          	li	a5,-1
    800011bc:	00a7d793          	srli	a5,a5,0xa
    800011c0:	3b079073          	csrw	pmpaddr0,a5
    800011c4:	00f00793          	li	a5,15
    800011c8:	3a079073          	csrw	pmpcfg0,a5
    800011cc:	f14027f3          	csrr	a5,mhartid
    800011d0:	0200c737          	lui	a4,0x200c
    800011d4:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    800011d8:	0007869b          	sext.w	a3,a5
    800011dc:	00269713          	slli	a4,a3,0x2
    800011e0:	000f4637          	lui	a2,0xf4
    800011e4:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    800011e8:	00d70733          	add	a4,a4,a3
    800011ec:	0037979b          	slliw	a5,a5,0x3
    800011f0:	020046b7          	lui	a3,0x2004
    800011f4:	00d787b3          	add	a5,a5,a3
    800011f8:	00c585b3          	add	a1,a1,a2
    800011fc:	00371693          	slli	a3,a4,0x3
    80001200:	00003717          	auipc	a4,0x3
    80001204:	19070713          	addi	a4,a4,400 # 80004390 <timer_scratch>
    80001208:	00b7b023          	sd	a1,0(a5)
    8000120c:	00d70733          	add	a4,a4,a3
    80001210:	00f73c23          	sd	a5,24(a4)
    80001214:	02c73023          	sd	a2,32(a4)
    80001218:	34071073          	csrw	mscratch,a4
    8000121c:	00000797          	auipc	a5,0x0
    80001220:	6e478793          	addi	a5,a5,1764 # 80001900 <timervec>
    80001224:	30579073          	csrw	mtvec,a5
    80001228:	300027f3          	csrr	a5,mstatus
    8000122c:	0087e793          	ori	a5,a5,8
    80001230:	30079073          	csrw	mstatus,a5
    80001234:	304027f3          	csrr	a5,mie
    80001238:	0807e793          	ori	a5,a5,128
    8000123c:	30479073          	csrw	mie,a5
    80001240:	f14027f3          	csrr	a5,mhartid
    80001244:	0007879b          	sext.w	a5,a5
    80001248:	00078213          	mv	tp,a5
    8000124c:	30200073          	mret
    80001250:	00813403          	ld	s0,8(sp)
    80001254:	01010113          	addi	sp,sp,16
    80001258:	00008067          	ret

000000008000125c <timerinit>:
    8000125c:	ff010113          	addi	sp,sp,-16
    80001260:	00813423          	sd	s0,8(sp)
    80001264:	01010413          	addi	s0,sp,16
    80001268:	f14027f3          	csrr	a5,mhartid
    8000126c:	0200c737          	lui	a4,0x200c
    80001270:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80001274:	0007869b          	sext.w	a3,a5
    80001278:	00269713          	slli	a4,a3,0x2
    8000127c:	000f4637          	lui	a2,0xf4
    80001280:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80001284:	00d70733          	add	a4,a4,a3
    80001288:	0037979b          	slliw	a5,a5,0x3
    8000128c:	020046b7          	lui	a3,0x2004
    80001290:	00d787b3          	add	a5,a5,a3
    80001294:	00c585b3          	add	a1,a1,a2
    80001298:	00371693          	slli	a3,a4,0x3
    8000129c:	00003717          	auipc	a4,0x3
    800012a0:	0f470713          	addi	a4,a4,244 # 80004390 <timer_scratch>
    800012a4:	00b7b023          	sd	a1,0(a5)
    800012a8:	00d70733          	add	a4,a4,a3
    800012ac:	00f73c23          	sd	a5,24(a4)
    800012b0:	02c73023          	sd	a2,32(a4)
    800012b4:	34071073          	csrw	mscratch,a4
    800012b8:	00000797          	auipc	a5,0x0
    800012bc:	64878793          	addi	a5,a5,1608 # 80001900 <timervec>
    800012c0:	30579073          	csrw	mtvec,a5
    800012c4:	300027f3          	csrr	a5,mstatus
    800012c8:	0087e793          	ori	a5,a5,8
    800012cc:	30079073          	csrw	mstatus,a5
    800012d0:	304027f3          	csrr	a5,mie
    800012d4:	0807e793          	ori	a5,a5,128
    800012d8:	30479073          	csrw	mie,a5
    800012dc:	00813403          	ld	s0,8(sp)
    800012e0:	01010113          	addi	sp,sp,16
    800012e4:	00008067          	ret

00000000800012e8 <system_main>:
    800012e8:	fe010113          	addi	sp,sp,-32
    800012ec:	00813823          	sd	s0,16(sp)
    800012f0:	00913423          	sd	s1,8(sp)
    800012f4:	00113c23          	sd	ra,24(sp)
    800012f8:	02010413          	addi	s0,sp,32
    800012fc:	00000097          	auipc	ra,0x0
    80001300:	0c4080e7          	jalr	196(ra) # 800013c0 <cpuid>
    80001304:	00003497          	auipc	s1,0x3
    80001308:	06448493          	addi	s1,s1,100 # 80004368 <started>
    8000130c:	02050263          	beqz	a0,80001330 <system_main+0x48>
    80001310:	0004a783          	lw	a5,0(s1)
    80001314:	0007879b          	sext.w	a5,a5
    80001318:	fe078ce3          	beqz	a5,80001310 <system_main+0x28>
    8000131c:	0ff0000f          	fence
    80001320:	00003517          	auipc	a0,0x3
    80001324:	d9050513          	addi	a0,a0,-624 # 800040b0 <CONSOLE_STATUS+0xa0>
    80001328:	00001097          	auipc	ra,0x1
    8000132c:	a74080e7          	jalr	-1420(ra) # 80001d9c <panic>
    80001330:	00001097          	auipc	ra,0x1
    80001334:	9c8080e7          	jalr	-1592(ra) # 80001cf8 <consoleinit>
    80001338:	00001097          	auipc	ra,0x1
    8000133c:	154080e7          	jalr	340(ra) # 8000248c <printfinit>
    80001340:	00003517          	auipc	a0,0x3
    80001344:	e5050513          	addi	a0,a0,-432 # 80004190 <CONSOLE_STATUS+0x180>
    80001348:	00001097          	auipc	ra,0x1
    8000134c:	ab0080e7          	jalr	-1360(ra) # 80001df8 <__printf>
    80001350:	00003517          	auipc	a0,0x3
    80001354:	d3050513          	addi	a0,a0,-720 # 80004080 <CONSOLE_STATUS+0x70>
    80001358:	00001097          	auipc	ra,0x1
    8000135c:	aa0080e7          	jalr	-1376(ra) # 80001df8 <__printf>
    80001360:	00003517          	auipc	a0,0x3
    80001364:	e3050513          	addi	a0,a0,-464 # 80004190 <CONSOLE_STATUS+0x180>
    80001368:	00001097          	auipc	ra,0x1
    8000136c:	a90080e7          	jalr	-1392(ra) # 80001df8 <__printf>
    80001370:	00001097          	auipc	ra,0x1
    80001374:	4a8080e7          	jalr	1192(ra) # 80002818 <kinit>
    80001378:	00000097          	auipc	ra,0x0
    8000137c:	148080e7          	jalr	328(ra) # 800014c0 <trapinit>
    80001380:	00000097          	auipc	ra,0x0
    80001384:	16c080e7          	jalr	364(ra) # 800014ec <trapinithart>
    80001388:	00000097          	auipc	ra,0x0
    8000138c:	5b8080e7          	jalr	1464(ra) # 80001940 <plicinit>
    80001390:	00000097          	auipc	ra,0x0
    80001394:	5d8080e7          	jalr	1496(ra) # 80001968 <plicinithart>
    80001398:	00000097          	auipc	ra,0x0
    8000139c:	078080e7          	jalr	120(ra) # 80001410 <userinit>
    800013a0:	0ff0000f          	fence
    800013a4:	00100793          	li	a5,1
    800013a8:	00003517          	auipc	a0,0x3
    800013ac:	cf050513          	addi	a0,a0,-784 # 80004098 <CONSOLE_STATUS+0x88>
    800013b0:	00f4a023          	sw	a5,0(s1)
    800013b4:	00001097          	auipc	ra,0x1
    800013b8:	a44080e7          	jalr	-1468(ra) # 80001df8 <__printf>
    800013bc:	0000006f          	j	800013bc <system_main+0xd4>

00000000800013c0 <cpuid>:
    800013c0:	ff010113          	addi	sp,sp,-16
    800013c4:	00813423          	sd	s0,8(sp)
    800013c8:	01010413          	addi	s0,sp,16
    800013cc:	00020513          	mv	a0,tp
    800013d0:	00813403          	ld	s0,8(sp)
    800013d4:	0005051b          	sext.w	a0,a0
    800013d8:	01010113          	addi	sp,sp,16
    800013dc:	00008067          	ret

00000000800013e0 <mycpu>:
    800013e0:	ff010113          	addi	sp,sp,-16
    800013e4:	00813423          	sd	s0,8(sp)
    800013e8:	01010413          	addi	s0,sp,16
    800013ec:	00020793          	mv	a5,tp
    800013f0:	00813403          	ld	s0,8(sp)
    800013f4:	0007879b          	sext.w	a5,a5
    800013f8:	00779793          	slli	a5,a5,0x7
    800013fc:	00004517          	auipc	a0,0x4
    80001400:	fc450513          	addi	a0,a0,-60 # 800053c0 <cpus>
    80001404:	00f50533          	add	a0,a0,a5
    80001408:	01010113          	addi	sp,sp,16
    8000140c:	00008067          	ret

0000000080001410 <userinit>:
    80001410:	ff010113          	addi	sp,sp,-16
    80001414:	00813423          	sd	s0,8(sp)
    80001418:	01010413          	addi	s0,sp,16
    8000141c:	00813403          	ld	s0,8(sp)
    80001420:	01010113          	addi	sp,sp,16
    80001424:	00000317          	auipc	t1,0x0
    80001428:	cdc30067          	jr	-804(t1) # 80001100 <main>

000000008000142c <either_copyout>:
    8000142c:	ff010113          	addi	sp,sp,-16
    80001430:	00813023          	sd	s0,0(sp)
    80001434:	00113423          	sd	ra,8(sp)
    80001438:	01010413          	addi	s0,sp,16
    8000143c:	02051663          	bnez	a0,80001468 <either_copyout+0x3c>
    80001440:	00058513          	mv	a0,a1
    80001444:	00060593          	mv	a1,a2
    80001448:	0006861b          	sext.w	a2,a3
    8000144c:	00002097          	auipc	ra,0x2
    80001450:	c58080e7          	jalr	-936(ra) # 800030a4 <__memmove>
    80001454:	00813083          	ld	ra,8(sp)
    80001458:	00013403          	ld	s0,0(sp)
    8000145c:	00000513          	li	a0,0
    80001460:	01010113          	addi	sp,sp,16
    80001464:	00008067          	ret
    80001468:	00003517          	auipc	a0,0x3
    8000146c:	c7050513          	addi	a0,a0,-912 # 800040d8 <CONSOLE_STATUS+0xc8>
    80001470:	00001097          	auipc	ra,0x1
    80001474:	92c080e7          	jalr	-1748(ra) # 80001d9c <panic>

0000000080001478 <either_copyin>:
    80001478:	ff010113          	addi	sp,sp,-16
    8000147c:	00813023          	sd	s0,0(sp)
    80001480:	00113423          	sd	ra,8(sp)
    80001484:	01010413          	addi	s0,sp,16
    80001488:	02059463          	bnez	a1,800014b0 <either_copyin+0x38>
    8000148c:	00060593          	mv	a1,a2
    80001490:	0006861b          	sext.w	a2,a3
    80001494:	00002097          	auipc	ra,0x2
    80001498:	c10080e7          	jalr	-1008(ra) # 800030a4 <__memmove>
    8000149c:	00813083          	ld	ra,8(sp)
    800014a0:	00013403          	ld	s0,0(sp)
    800014a4:	00000513          	li	a0,0
    800014a8:	01010113          	addi	sp,sp,16
    800014ac:	00008067          	ret
    800014b0:	00003517          	auipc	a0,0x3
    800014b4:	c5050513          	addi	a0,a0,-944 # 80004100 <CONSOLE_STATUS+0xf0>
    800014b8:	00001097          	auipc	ra,0x1
    800014bc:	8e4080e7          	jalr	-1820(ra) # 80001d9c <panic>

00000000800014c0 <trapinit>:
    800014c0:	ff010113          	addi	sp,sp,-16
    800014c4:	00813423          	sd	s0,8(sp)
    800014c8:	01010413          	addi	s0,sp,16
    800014cc:	00813403          	ld	s0,8(sp)
    800014d0:	00003597          	auipc	a1,0x3
    800014d4:	c5858593          	addi	a1,a1,-936 # 80004128 <CONSOLE_STATUS+0x118>
    800014d8:	00004517          	auipc	a0,0x4
    800014dc:	f6850513          	addi	a0,a0,-152 # 80005440 <tickslock>
    800014e0:	01010113          	addi	sp,sp,16
    800014e4:	00001317          	auipc	t1,0x1
    800014e8:	5c430067          	jr	1476(t1) # 80002aa8 <initlock>

00000000800014ec <trapinithart>:
    800014ec:	ff010113          	addi	sp,sp,-16
    800014f0:	00813423          	sd	s0,8(sp)
    800014f4:	01010413          	addi	s0,sp,16
    800014f8:	00000797          	auipc	a5,0x0
    800014fc:	2f878793          	addi	a5,a5,760 # 800017f0 <kernelvec>
    80001500:	10579073          	csrw	stvec,a5
    80001504:	00813403          	ld	s0,8(sp)
    80001508:	01010113          	addi	sp,sp,16
    8000150c:	00008067          	ret

0000000080001510 <usertrap>:
    80001510:	ff010113          	addi	sp,sp,-16
    80001514:	00813423          	sd	s0,8(sp)
    80001518:	01010413          	addi	s0,sp,16
    8000151c:	00813403          	ld	s0,8(sp)
    80001520:	01010113          	addi	sp,sp,16
    80001524:	00008067          	ret

0000000080001528 <usertrapret>:
    80001528:	ff010113          	addi	sp,sp,-16
    8000152c:	00813423          	sd	s0,8(sp)
    80001530:	01010413          	addi	s0,sp,16
    80001534:	00813403          	ld	s0,8(sp)
    80001538:	01010113          	addi	sp,sp,16
    8000153c:	00008067          	ret

0000000080001540 <kerneltrap>:
    80001540:	fe010113          	addi	sp,sp,-32
    80001544:	00813823          	sd	s0,16(sp)
    80001548:	00113c23          	sd	ra,24(sp)
    8000154c:	00913423          	sd	s1,8(sp)
    80001550:	02010413          	addi	s0,sp,32
    80001554:	142025f3          	csrr	a1,scause
    80001558:	100027f3          	csrr	a5,sstatus
    8000155c:	0027f793          	andi	a5,a5,2
    80001560:	10079c63          	bnez	a5,80001678 <kerneltrap+0x138>
    80001564:	142027f3          	csrr	a5,scause
    80001568:	0207ce63          	bltz	a5,800015a4 <kerneltrap+0x64>
    8000156c:	00003517          	auipc	a0,0x3
    80001570:	c0450513          	addi	a0,a0,-1020 # 80004170 <CONSOLE_STATUS+0x160>
    80001574:	00001097          	auipc	ra,0x1
    80001578:	884080e7          	jalr	-1916(ra) # 80001df8 <__printf>
    8000157c:	141025f3          	csrr	a1,sepc
    80001580:	14302673          	csrr	a2,stval
    80001584:	00003517          	auipc	a0,0x3
    80001588:	bfc50513          	addi	a0,a0,-1028 # 80004180 <CONSOLE_STATUS+0x170>
    8000158c:	00001097          	auipc	ra,0x1
    80001590:	86c080e7          	jalr	-1940(ra) # 80001df8 <__printf>
    80001594:	00003517          	auipc	a0,0x3
    80001598:	c0450513          	addi	a0,a0,-1020 # 80004198 <CONSOLE_STATUS+0x188>
    8000159c:	00001097          	auipc	ra,0x1
    800015a0:	800080e7          	jalr	-2048(ra) # 80001d9c <panic>
    800015a4:	0ff7f713          	andi	a4,a5,255
    800015a8:	00900693          	li	a3,9
    800015ac:	04d70063          	beq	a4,a3,800015ec <kerneltrap+0xac>
    800015b0:	fff00713          	li	a4,-1
    800015b4:	03f71713          	slli	a4,a4,0x3f
    800015b8:	00170713          	addi	a4,a4,1
    800015bc:	fae798e3          	bne	a5,a4,8000156c <kerneltrap+0x2c>
    800015c0:	00000097          	auipc	ra,0x0
    800015c4:	e00080e7          	jalr	-512(ra) # 800013c0 <cpuid>
    800015c8:	06050663          	beqz	a0,80001634 <kerneltrap+0xf4>
    800015cc:	144027f3          	csrr	a5,sip
    800015d0:	ffd7f793          	andi	a5,a5,-3
    800015d4:	14479073          	csrw	sip,a5
    800015d8:	01813083          	ld	ra,24(sp)
    800015dc:	01013403          	ld	s0,16(sp)
    800015e0:	00813483          	ld	s1,8(sp)
    800015e4:	02010113          	addi	sp,sp,32
    800015e8:	00008067          	ret
    800015ec:	00000097          	auipc	ra,0x0
    800015f0:	3c8080e7          	jalr	968(ra) # 800019b4 <plic_claim>
    800015f4:	00a00793          	li	a5,10
    800015f8:	00050493          	mv	s1,a0
    800015fc:	06f50863          	beq	a0,a5,8000166c <kerneltrap+0x12c>
    80001600:	fc050ce3          	beqz	a0,800015d8 <kerneltrap+0x98>
    80001604:	00050593          	mv	a1,a0
    80001608:	00003517          	auipc	a0,0x3
    8000160c:	b4850513          	addi	a0,a0,-1208 # 80004150 <CONSOLE_STATUS+0x140>
    80001610:	00000097          	auipc	ra,0x0
    80001614:	7e8080e7          	jalr	2024(ra) # 80001df8 <__printf>
    80001618:	01013403          	ld	s0,16(sp)
    8000161c:	01813083          	ld	ra,24(sp)
    80001620:	00048513          	mv	a0,s1
    80001624:	00813483          	ld	s1,8(sp)
    80001628:	02010113          	addi	sp,sp,32
    8000162c:	00000317          	auipc	t1,0x0
    80001630:	3c030067          	jr	960(t1) # 800019ec <plic_complete>
    80001634:	00004517          	auipc	a0,0x4
    80001638:	e0c50513          	addi	a0,a0,-500 # 80005440 <tickslock>
    8000163c:	00001097          	auipc	ra,0x1
    80001640:	490080e7          	jalr	1168(ra) # 80002acc <acquire>
    80001644:	00003717          	auipc	a4,0x3
    80001648:	d2870713          	addi	a4,a4,-728 # 8000436c <ticks>
    8000164c:	00072783          	lw	a5,0(a4)
    80001650:	00004517          	auipc	a0,0x4
    80001654:	df050513          	addi	a0,a0,-528 # 80005440 <tickslock>
    80001658:	0017879b          	addiw	a5,a5,1
    8000165c:	00f72023          	sw	a5,0(a4)
    80001660:	00001097          	auipc	ra,0x1
    80001664:	538080e7          	jalr	1336(ra) # 80002b98 <release>
    80001668:	f65ff06f          	j	800015cc <kerneltrap+0x8c>
    8000166c:	00001097          	auipc	ra,0x1
    80001670:	094080e7          	jalr	148(ra) # 80002700 <uartintr>
    80001674:	fa5ff06f          	j	80001618 <kerneltrap+0xd8>
    80001678:	00003517          	auipc	a0,0x3
    8000167c:	ab850513          	addi	a0,a0,-1352 # 80004130 <CONSOLE_STATUS+0x120>
    80001680:	00000097          	auipc	ra,0x0
    80001684:	71c080e7          	jalr	1820(ra) # 80001d9c <panic>

0000000080001688 <clockintr>:
    80001688:	fe010113          	addi	sp,sp,-32
    8000168c:	00813823          	sd	s0,16(sp)
    80001690:	00913423          	sd	s1,8(sp)
    80001694:	00113c23          	sd	ra,24(sp)
    80001698:	02010413          	addi	s0,sp,32
    8000169c:	00004497          	auipc	s1,0x4
    800016a0:	da448493          	addi	s1,s1,-604 # 80005440 <tickslock>
    800016a4:	00048513          	mv	a0,s1
    800016a8:	00001097          	auipc	ra,0x1
    800016ac:	424080e7          	jalr	1060(ra) # 80002acc <acquire>
    800016b0:	00003717          	auipc	a4,0x3
    800016b4:	cbc70713          	addi	a4,a4,-836 # 8000436c <ticks>
    800016b8:	00072783          	lw	a5,0(a4)
    800016bc:	01013403          	ld	s0,16(sp)
    800016c0:	01813083          	ld	ra,24(sp)
    800016c4:	00048513          	mv	a0,s1
    800016c8:	0017879b          	addiw	a5,a5,1
    800016cc:	00813483          	ld	s1,8(sp)
    800016d0:	00f72023          	sw	a5,0(a4)
    800016d4:	02010113          	addi	sp,sp,32
    800016d8:	00001317          	auipc	t1,0x1
    800016dc:	4c030067          	jr	1216(t1) # 80002b98 <release>

00000000800016e0 <devintr>:
    800016e0:	142027f3          	csrr	a5,scause
    800016e4:	00000513          	li	a0,0
    800016e8:	0007c463          	bltz	a5,800016f0 <devintr+0x10>
    800016ec:	00008067          	ret
    800016f0:	fe010113          	addi	sp,sp,-32
    800016f4:	00813823          	sd	s0,16(sp)
    800016f8:	00113c23          	sd	ra,24(sp)
    800016fc:	00913423          	sd	s1,8(sp)
    80001700:	02010413          	addi	s0,sp,32
    80001704:	0ff7f713          	andi	a4,a5,255
    80001708:	00900693          	li	a3,9
    8000170c:	04d70c63          	beq	a4,a3,80001764 <devintr+0x84>
    80001710:	fff00713          	li	a4,-1
    80001714:	03f71713          	slli	a4,a4,0x3f
    80001718:	00170713          	addi	a4,a4,1
    8000171c:	00e78c63          	beq	a5,a4,80001734 <devintr+0x54>
    80001720:	01813083          	ld	ra,24(sp)
    80001724:	01013403          	ld	s0,16(sp)
    80001728:	00813483          	ld	s1,8(sp)
    8000172c:	02010113          	addi	sp,sp,32
    80001730:	00008067          	ret
    80001734:	00000097          	auipc	ra,0x0
    80001738:	c8c080e7          	jalr	-884(ra) # 800013c0 <cpuid>
    8000173c:	06050663          	beqz	a0,800017a8 <devintr+0xc8>
    80001740:	144027f3          	csrr	a5,sip
    80001744:	ffd7f793          	andi	a5,a5,-3
    80001748:	14479073          	csrw	sip,a5
    8000174c:	01813083          	ld	ra,24(sp)
    80001750:	01013403          	ld	s0,16(sp)
    80001754:	00813483          	ld	s1,8(sp)
    80001758:	00200513          	li	a0,2
    8000175c:	02010113          	addi	sp,sp,32
    80001760:	00008067          	ret
    80001764:	00000097          	auipc	ra,0x0
    80001768:	250080e7          	jalr	592(ra) # 800019b4 <plic_claim>
    8000176c:	00a00793          	li	a5,10
    80001770:	00050493          	mv	s1,a0
    80001774:	06f50663          	beq	a0,a5,800017e0 <devintr+0x100>
    80001778:	00100513          	li	a0,1
    8000177c:	fa0482e3          	beqz	s1,80001720 <devintr+0x40>
    80001780:	00048593          	mv	a1,s1
    80001784:	00003517          	auipc	a0,0x3
    80001788:	9cc50513          	addi	a0,a0,-1588 # 80004150 <CONSOLE_STATUS+0x140>
    8000178c:	00000097          	auipc	ra,0x0
    80001790:	66c080e7          	jalr	1644(ra) # 80001df8 <__printf>
    80001794:	00048513          	mv	a0,s1
    80001798:	00000097          	auipc	ra,0x0
    8000179c:	254080e7          	jalr	596(ra) # 800019ec <plic_complete>
    800017a0:	00100513          	li	a0,1
    800017a4:	f7dff06f          	j	80001720 <devintr+0x40>
    800017a8:	00004517          	auipc	a0,0x4
    800017ac:	c9850513          	addi	a0,a0,-872 # 80005440 <tickslock>
    800017b0:	00001097          	auipc	ra,0x1
    800017b4:	31c080e7          	jalr	796(ra) # 80002acc <acquire>
    800017b8:	00003717          	auipc	a4,0x3
    800017bc:	bb470713          	addi	a4,a4,-1100 # 8000436c <ticks>
    800017c0:	00072783          	lw	a5,0(a4)
    800017c4:	00004517          	auipc	a0,0x4
    800017c8:	c7c50513          	addi	a0,a0,-900 # 80005440 <tickslock>
    800017cc:	0017879b          	addiw	a5,a5,1
    800017d0:	00f72023          	sw	a5,0(a4)
    800017d4:	00001097          	auipc	ra,0x1
    800017d8:	3c4080e7          	jalr	964(ra) # 80002b98 <release>
    800017dc:	f65ff06f          	j	80001740 <devintr+0x60>
    800017e0:	00001097          	auipc	ra,0x1
    800017e4:	f20080e7          	jalr	-224(ra) # 80002700 <uartintr>
    800017e8:	fadff06f          	j	80001794 <devintr+0xb4>
    800017ec:	0000                	unimp
	...

00000000800017f0 <kernelvec>:
    800017f0:	f0010113          	addi	sp,sp,-256
    800017f4:	00113023          	sd	ra,0(sp)
    800017f8:	00213423          	sd	sp,8(sp)
    800017fc:	00313823          	sd	gp,16(sp)
    80001800:	00413c23          	sd	tp,24(sp)
    80001804:	02513023          	sd	t0,32(sp)
    80001808:	02613423          	sd	t1,40(sp)
    8000180c:	02713823          	sd	t2,48(sp)
    80001810:	02813c23          	sd	s0,56(sp)
    80001814:	04913023          	sd	s1,64(sp)
    80001818:	04a13423          	sd	a0,72(sp)
    8000181c:	04b13823          	sd	a1,80(sp)
    80001820:	04c13c23          	sd	a2,88(sp)
    80001824:	06d13023          	sd	a3,96(sp)
    80001828:	06e13423          	sd	a4,104(sp)
    8000182c:	06f13823          	sd	a5,112(sp)
    80001830:	07013c23          	sd	a6,120(sp)
    80001834:	09113023          	sd	a7,128(sp)
    80001838:	09213423          	sd	s2,136(sp)
    8000183c:	09313823          	sd	s3,144(sp)
    80001840:	09413c23          	sd	s4,152(sp)
    80001844:	0b513023          	sd	s5,160(sp)
    80001848:	0b613423          	sd	s6,168(sp)
    8000184c:	0b713823          	sd	s7,176(sp)
    80001850:	0b813c23          	sd	s8,184(sp)
    80001854:	0d913023          	sd	s9,192(sp)
    80001858:	0da13423          	sd	s10,200(sp)
    8000185c:	0db13823          	sd	s11,208(sp)
    80001860:	0dc13c23          	sd	t3,216(sp)
    80001864:	0fd13023          	sd	t4,224(sp)
    80001868:	0fe13423          	sd	t5,232(sp)
    8000186c:	0ff13823          	sd	t6,240(sp)
    80001870:	cd1ff0ef          	jal	ra,80001540 <kerneltrap>
    80001874:	00013083          	ld	ra,0(sp)
    80001878:	00813103          	ld	sp,8(sp)
    8000187c:	01013183          	ld	gp,16(sp)
    80001880:	02013283          	ld	t0,32(sp)
    80001884:	02813303          	ld	t1,40(sp)
    80001888:	03013383          	ld	t2,48(sp)
    8000188c:	03813403          	ld	s0,56(sp)
    80001890:	04013483          	ld	s1,64(sp)
    80001894:	04813503          	ld	a0,72(sp)
    80001898:	05013583          	ld	a1,80(sp)
    8000189c:	05813603          	ld	a2,88(sp)
    800018a0:	06013683          	ld	a3,96(sp)
    800018a4:	06813703          	ld	a4,104(sp)
    800018a8:	07013783          	ld	a5,112(sp)
    800018ac:	07813803          	ld	a6,120(sp)
    800018b0:	08013883          	ld	a7,128(sp)
    800018b4:	08813903          	ld	s2,136(sp)
    800018b8:	09013983          	ld	s3,144(sp)
    800018bc:	09813a03          	ld	s4,152(sp)
    800018c0:	0a013a83          	ld	s5,160(sp)
    800018c4:	0a813b03          	ld	s6,168(sp)
    800018c8:	0b013b83          	ld	s7,176(sp)
    800018cc:	0b813c03          	ld	s8,184(sp)
    800018d0:	0c013c83          	ld	s9,192(sp)
    800018d4:	0c813d03          	ld	s10,200(sp)
    800018d8:	0d013d83          	ld	s11,208(sp)
    800018dc:	0d813e03          	ld	t3,216(sp)
    800018e0:	0e013e83          	ld	t4,224(sp)
    800018e4:	0e813f03          	ld	t5,232(sp)
    800018e8:	0f013f83          	ld	t6,240(sp)
    800018ec:	10010113          	addi	sp,sp,256
    800018f0:	10200073          	sret
    800018f4:	00000013          	nop
    800018f8:	00000013          	nop
    800018fc:	00000013          	nop

0000000080001900 <timervec>:
    80001900:	34051573          	csrrw	a0,mscratch,a0
    80001904:	00b53023          	sd	a1,0(a0)
    80001908:	00c53423          	sd	a2,8(a0)
    8000190c:	00d53823          	sd	a3,16(a0)
    80001910:	01853583          	ld	a1,24(a0)
    80001914:	02053603          	ld	a2,32(a0)
    80001918:	0005b683          	ld	a3,0(a1)
    8000191c:	00c686b3          	add	a3,a3,a2
    80001920:	00d5b023          	sd	a3,0(a1)
    80001924:	00200593          	li	a1,2
    80001928:	14459073          	csrw	sip,a1
    8000192c:	01053683          	ld	a3,16(a0)
    80001930:	00853603          	ld	a2,8(a0)
    80001934:	00053583          	ld	a1,0(a0)
    80001938:	34051573          	csrrw	a0,mscratch,a0
    8000193c:	30200073          	mret

0000000080001940 <plicinit>:
    80001940:	ff010113          	addi	sp,sp,-16
    80001944:	00813423          	sd	s0,8(sp)
    80001948:	01010413          	addi	s0,sp,16
    8000194c:	00813403          	ld	s0,8(sp)
    80001950:	0c0007b7          	lui	a5,0xc000
    80001954:	00100713          	li	a4,1
    80001958:	02e7a423          	sw	a4,40(a5) # c000028 <_entry-0x73ffffd8>
    8000195c:	00e7a223          	sw	a4,4(a5)
    80001960:	01010113          	addi	sp,sp,16
    80001964:	00008067          	ret

0000000080001968 <plicinithart>:
    80001968:	ff010113          	addi	sp,sp,-16
    8000196c:	00813023          	sd	s0,0(sp)
    80001970:	00113423          	sd	ra,8(sp)
    80001974:	01010413          	addi	s0,sp,16
    80001978:	00000097          	auipc	ra,0x0
    8000197c:	a48080e7          	jalr	-1464(ra) # 800013c0 <cpuid>
    80001980:	0085171b          	slliw	a4,a0,0x8
    80001984:	0c0027b7          	lui	a5,0xc002
    80001988:	00e787b3          	add	a5,a5,a4
    8000198c:	40200713          	li	a4,1026
    80001990:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>
    80001994:	00813083          	ld	ra,8(sp)
    80001998:	00013403          	ld	s0,0(sp)
    8000199c:	00d5151b          	slliw	a0,a0,0xd
    800019a0:	0c2017b7          	lui	a5,0xc201
    800019a4:	00a78533          	add	a0,a5,a0
    800019a8:	00052023          	sw	zero,0(a0)
    800019ac:	01010113          	addi	sp,sp,16
    800019b0:	00008067          	ret

00000000800019b4 <plic_claim>:
    800019b4:	ff010113          	addi	sp,sp,-16
    800019b8:	00813023          	sd	s0,0(sp)
    800019bc:	00113423          	sd	ra,8(sp)
    800019c0:	01010413          	addi	s0,sp,16
    800019c4:	00000097          	auipc	ra,0x0
    800019c8:	9fc080e7          	jalr	-1540(ra) # 800013c0 <cpuid>
    800019cc:	00813083          	ld	ra,8(sp)
    800019d0:	00013403          	ld	s0,0(sp)
    800019d4:	00d5151b          	slliw	a0,a0,0xd
    800019d8:	0c2017b7          	lui	a5,0xc201
    800019dc:	00a78533          	add	a0,a5,a0
    800019e0:	00452503          	lw	a0,4(a0)
    800019e4:	01010113          	addi	sp,sp,16
    800019e8:	00008067          	ret

00000000800019ec <plic_complete>:
    800019ec:	fe010113          	addi	sp,sp,-32
    800019f0:	00813823          	sd	s0,16(sp)
    800019f4:	00913423          	sd	s1,8(sp)
    800019f8:	00113c23          	sd	ra,24(sp)
    800019fc:	02010413          	addi	s0,sp,32
    80001a00:	00050493          	mv	s1,a0
    80001a04:	00000097          	auipc	ra,0x0
    80001a08:	9bc080e7          	jalr	-1604(ra) # 800013c0 <cpuid>
    80001a0c:	01813083          	ld	ra,24(sp)
    80001a10:	01013403          	ld	s0,16(sp)
    80001a14:	00d5179b          	slliw	a5,a0,0xd
    80001a18:	0c201737          	lui	a4,0xc201
    80001a1c:	00f707b3          	add	a5,a4,a5
    80001a20:	0097a223          	sw	s1,4(a5) # c201004 <_entry-0x73dfeffc>
    80001a24:	00813483          	ld	s1,8(sp)
    80001a28:	02010113          	addi	sp,sp,32
    80001a2c:	00008067          	ret

0000000080001a30 <consolewrite>:
    80001a30:	fb010113          	addi	sp,sp,-80
    80001a34:	04813023          	sd	s0,64(sp)
    80001a38:	04113423          	sd	ra,72(sp)
    80001a3c:	02913c23          	sd	s1,56(sp)
    80001a40:	03213823          	sd	s2,48(sp)
    80001a44:	03313423          	sd	s3,40(sp)
    80001a48:	03413023          	sd	s4,32(sp)
    80001a4c:	01513c23          	sd	s5,24(sp)
    80001a50:	05010413          	addi	s0,sp,80
    80001a54:	06c05c63          	blez	a2,80001acc <consolewrite+0x9c>
    80001a58:	00060993          	mv	s3,a2
    80001a5c:	00050a13          	mv	s4,a0
    80001a60:	00058493          	mv	s1,a1
    80001a64:	00000913          	li	s2,0
    80001a68:	fff00a93          	li	s5,-1
    80001a6c:	01c0006f          	j	80001a88 <consolewrite+0x58>
    80001a70:	fbf44503          	lbu	a0,-65(s0)
    80001a74:	0019091b          	addiw	s2,s2,1
    80001a78:	00148493          	addi	s1,s1,1
    80001a7c:	00001097          	auipc	ra,0x1
    80001a80:	a9c080e7          	jalr	-1380(ra) # 80002518 <uartputc>
    80001a84:	03298063          	beq	s3,s2,80001aa4 <consolewrite+0x74>
    80001a88:	00048613          	mv	a2,s1
    80001a8c:	00100693          	li	a3,1
    80001a90:	000a0593          	mv	a1,s4
    80001a94:	fbf40513          	addi	a0,s0,-65
    80001a98:	00000097          	auipc	ra,0x0
    80001a9c:	9e0080e7          	jalr	-1568(ra) # 80001478 <either_copyin>
    80001aa0:	fd5518e3          	bne	a0,s5,80001a70 <consolewrite+0x40>
    80001aa4:	04813083          	ld	ra,72(sp)
    80001aa8:	04013403          	ld	s0,64(sp)
    80001aac:	03813483          	ld	s1,56(sp)
    80001ab0:	02813983          	ld	s3,40(sp)
    80001ab4:	02013a03          	ld	s4,32(sp)
    80001ab8:	01813a83          	ld	s5,24(sp)
    80001abc:	00090513          	mv	a0,s2
    80001ac0:	03013903          	ld	s2,48(sp)
    80001ac4:	05010113          	addi	sp,sp,80
    80001ac8:	00008067          	ret
    80001acc:	00000913          	li	s2,0
    80001ad0:	fd5ff06f          	j	80001aa4 <consolewrite+0x74>

0000000080001ad4 <consoleread>:
    80001ad4:	f9010113          	addi	sp,sp,-112
    80001ad8:	06813023          	sd	s0,96(sp)
    80001adc:	04913c23          	sd	s1,88(sp)
    80001ae0:	05213823          	sd	s2,80(sp)
    80001ae4:	05313423          	sd	s3,72(sp)
    80001ae8:	05413023          	sd	s4,64(sp)
    80001aec:	03513c23          	sd	s5,56(sp)
    80001af0:	03613823          	sd	s6,48(sp)
    80001af4:	03713423          	sd	s7,40(sp)
    80001af8:	03813023          	sd	s8,32(sp)
    80001afc:	06113423          	sd	ra,104(sp)
    80001b00:	01913c23          	sd	s9,24(sp)
    80001b04:	07010413          	addi	s0,sp,112
    80001b08:	00060b93          	mv	s7,a2
    80001b0c:	00050913          	mv	s2,a0
    80001b10:	00058c13          	mv	s8,a1
    80001b14:	00060b1b          	sext.w	s6,a2
    80001b18:	00004497          	auipc	s1,0x4
    80001b1c:	94048493          	addi	s1,s1,-1728 # 80005458 <cons>
    80001b20:	00400993          	li	s3,4
    80001b24:	fff00a13          	li	s4,-1
    80001b28:	00a00a93          	li	s5,10
    80001b2c:	05705e63          	blez	s7,80001b88 <consoleread+0xb4>
    80001b30:	09c4a703          	lw	a4,156(s1)
    80001b34:	0984a783          	lw	a5,152(s1)
    80001b38:	0007071b          	sext.w	a4,a4
    80001b3c:	08e78463          	beq	a5,a4,80001bc4 <consoleread+0xf0>
    80001b40:	07f7f713          	andi	a4,a5,127
    80001b44:	00e48733          	add	a4,s1,a4
    80001b48:	01874703          	lbu	a4,24(a4) # c201018 <_entry-0x73dfefe8>
    80001b4c:	0017869b          	addiw	a3,a5,1
    80001b50:	08d4ac23          	sw	a3,152(s1)
    80001b54:	00070c9b          	sext.w	s9,a4
    80001b58:	0b370663          	beq	a4,s3,80001c04 <consoleread+0x130>
    80001b5c:	00100693          	li	a3,1
    80001b60:	f9f40613          	addi	a2,s0,-97
    80001b64:	000c0593          	mv	a1,s8
    80001b68:	00090513          	mv	a0,s2
    80001b6c:	f8e40fa3          	sb	a4,-97(s0)
    80001b70:	00000097          	auipc	ra,0x0
    80001b74:	8bc080e7          	jalr	-1860(ra) # 8000142c <either_copyout>
    80001b78:	01450863          	beq	a0,s4,80001b88 <consoleread+0xb4>
    80001b7c:	001c0c13          	addi	s8,s8,1
    80001b80:	fffb8b9b          	addiw	s7,s7,-1
    80001b84:	fb5c94e3          	bne	s9,s5,80001b2c <consoleread+0x58>
    80001b88:	000b851b          	sext.w	a0,s7
    80001b8c:	06813083          	ld	ra,104(sp)
    80001b90:	06013403          	ld	s0,96(sp)
    80001b94:	05813483          	ld	s1,88(sp)
    80001b98:	05013903          	ld	s2,80(sp)
    80001b9c:	04813983          	ld	s3,72(sp)
    80001ba0:	04013a03          	ld	s4,64(sp)
    80001ba4:	03813a83          	ld	s5,56(sp)
    80001ba8:	02813b83          	ld	s7,40(sp)
    80001bac:	02013c03          	ld	s8,32(sp)
    80001bb0:	01813c83          	ld	s9,24(sp)
    80001bb4:	40ab053b          	subw	a0,s6,a0
    80001bb8:	03013b03          	ld	s6,48(sp)
    80001bbc:	07010113          	addi	sp,sp,112
    80001bc0:	00008067          	ret
    80001bc4:	00001097          	auipc	ra,0x1
    80001bc8:	1d8080e7          	jalr	472(ra) # 80002d9c <push_on>
    80001bcc:	0984a703          	lw	a4,152(s1)
    80001bd0:	09c4a783          	lw	a5,156(s1)
    80001bd4:	0007879b          	sext.w	a5,a5
    80001bd8:	fef70ce3          	beq	a4,a5,80001bd0 <consoleread+0xfc>
    80001bdc:	00001097          	auipc	ra,0x1
    80001be0:	234080e7          	jalr	564(ra) # 80002e10 <pop_on>
    80001be4:	0984a783          	lw	a5,152(s1)
    80001be8:	07f7f713          	andi	a4,a5,127
    80001bec:	00e48733          	add	a4,s1,a4
    80001bf0:	01874703          	lbu	a4,24(a4)
    80001bf4:	0017869b          	addiw	a3,a5,1
    80001bf8:	08d4ac23          	sw	a3,152(s1)
    80001bfc:	00070c9b          	sext.w	s9,a4
    80001c00:	f5371ee3          	bne	a4,s3,80001b5c <consoleread+0x88>
    80001c04:	000b851b          	sext.w	a0,s7
    80001c08:	f96bf2e3          	bgeu	s7,s6,80001b8c <consoleread+0xb8>
    80001c0c:	08f4ac23          	sw	a5,152(s1)
    80001c10:	f7dff06f          	j	80001b8c <consoleread+0xb8>

0000000080001c14 <consputc>:
    80001c14:	10000793          	li	a5,256
    80001c18:	00f50663          	beq	a0,a5,80001c24 <consputc+0x10>
    80001c1c:	00001317          	auipc	t1,0x1
    80001c20:	9f430067          	jr	-1548(t1) # 80002610 <uartputc_sync>
    80001c24:	ff010113          	addi	sp,sp,-16
    80001c28:	00113423          	sd	ra,8(sp)
    80001c2c:	00813023          	sd	s0,0(sp)
    80001c30:	01010413          	addi	s0,sp,16
    80001c34:	00800513          	li	a0,8
    80001c38:	00001097          	auipc	ra,0x1
    80001c3c:	9d8080e7          	jalr	-1576(ra) # 80002610 <uartputc_sync>
    80001c40:	02000513          	li	a0,32
    80001c44:	00001097          	auipc	ra,0x1
    80001c48:	9cc080e7          	jalr	-1588(ra) # 80002610 <uartputc_sync>
    80001c4c:	00013403          	ld	s0,0(sp)
    80001c50:	00813083          	ld	ra,8(sp)
    80001c54:	00800513          	li	a0,8
    80001c58:	01010113          	addi	sp,sp,16
    80001c5c:	00001317          	auipc	t1,0x1
    80001c60:	9b430067          	jr	-1612(t1) # 80002610 <uartputc_sync>

0000000080001c64 <consoleintr>:
    80001c64:	fe010113          	addi	sp,sp,-32
    80001c68:	00813823          	sd	s0,16(sp)
    80001c6c:	00913423          	sd	s1,8(sp)
    80001c70:	01213023          	sd	s2,0(sp)
    80001c74:	00113c23          	sd	ra,24(sp)
    80001c78:	02010413          	addi	s0,sp,32
    80001c7c:	00003917          	auipc	s2,0x3
    80001c80:	7dc90913          	addi	s2,s2,2012 # 80005458 <cons>
    80001c84:	00050493          	mv	s1,a0
    80001c88:	00090513          	mv	a0,s2
    80001c8c:	00001097          	auipc	ra,0x1
    80001c90:	e40080e7          	jalr	-448(ra) # 80002acc <acquire>
    80001c94:	02048c63          	beqz	s1,80001ccc <consoleintr+0x68>
    80001c98:	0a092783          	lw	a5,160(s2)
    80001c9c:	09892703          	lw	a4,152(s2)
    80001ca0:	07f00693          	li	a3,127
    80001ca4:	40e7873b          	subw	a4,a5,a4
    80001ca8:	02e6e263          	bltu	a3,a4,80001ccc <consoleintr+0x68>
    80001cac:	00d00713          	li	a4,13
    80001cb0:	04e48063          	beq	s1,a4,80001cf0 <consoleintr+0x8c>
    80001cb4:	07f7f713          	andi	a4,a5,127
    80001cb8:	00e90733          	add	a4,s2,a4
    80001cbc:	0017879b          	addiw	a5,a5,1
    80001cc0:	0af92023          	sw	a5,160(s2)
    80001cc4:	00970c23          	sb	s1,24(a4)
    80001cc8:	08f92e23          	sw	a5,156(s2)
    80001ccc:	01013403          	ld	s0,16(sp)
    80001cd0:	01813083          	ld	ra,24(sp)
    80001cd4:	00813483          	ld	s1,8(sp)
    80001cd8:	00013903          	ld	s2,0(sp)
    80001cdc:	00003517          	auipc	a0,0x3
    80001ce0:	77c50513          	addi	a0,a0,1916 # 80005458 <cons>
    80001ce4:	02010113          	addi	sp,sp,32
    80001ce8:	00001317          	auipc	t1,0x1
    80001cec:	eb030067          	jr	-336(t1) # 80002b98 <release>
    80001cf0:	00a00493          	li	s1,10
    80001cf4:	fc1ff06f          	j	80001cb4 <consoleintr+0x50>

0000000080001cf8 <consoleinit>:
    80001cf8:	fe010113          	addi	sp,sp,-32
    80001cfc:	00113c23          	sd	ra,24(sp)
    80001d00:	00813823          	sd	s0,16(sp)
    80001d04:	00913423          	sd	s1,8(sp)
    80001d08:	02010413          	addi	s0,sp,32
    80001d0c:	00003497          	auipc	s1,0x3
    80001d10:	74c48493          	addi	s1,s1,1868 # 80005458 <cons>
    80001d14:	00048513          	mv	a0,s1
    80001d18:	00002597          	auipc	a1,0x2
    80001d1c:	49058593          	addi	a1,a1,1168 # 800041a8 <CONSOLE_STATUS+0x198>
    80001d20:	00001097          	auipc	ra,0x1
    80001d24:	d88080e7          	jalr	-632(ra) # 80002aa8 <initlock>
    80001d28:	00000097          	auipc	ra,0x0
    80001d2c:	7ac080e7          	jalr	1964(ra) # 800024d4 <uartinit>
    80001d30:	01813083          	ld	ra,24(sp)
    80001d34:	01013403          	ld	s0,16(sp)
    80001d38:	00000797          	auipc	a5,0x0
    80001d3c:	d9c78793          	addi	a5,a5,-612 # 80001ad4 <consoleread>
    80001d40:	0af4bc23          	sd	a5,184(s1)
    80001d44:	00000797          	auipc	a5,0x0
    80001d48:	cec78793          	addi	a5,a5,-788 # 80001a30 <consolewrite>
    80001d4c:	0cf4b023          	sd	a5,192(s1)
    80001d50:	00813483          	ld	s1,8(sp)
    80001d54:	02010113          	addi	sp,sp,32
    80001d58:	00008067          	ret

0000000080001d5c <console_read>:
    80001d5c:	ff010113          	addi	sp,sp,-16
    80001d60:	00813423          	sd	s0,8(sp)
    80001d64:	01010413          	addi	s0,sp,16
    80001d68:	00813403          	ld	s0,8(sp)
    80001d6c:	00003317          	auipc	t1,0x3
    80001d70:	7a433303          	ld	t1,1956(t1) # 80005510 <devsw+0x10>
    80001d74:	01010113          	addi	sp,sp,16
    80001d78:	00030067          	jr	t1

0000000080001d7c <console_write>:
    80001d7c:	ff010113          	addi	sp,sp,-16
    80001d80:	00813423          	sd	s0,8(sp)
    80001d84:	01010413          	addi	s0,sp,16
    80001d88:	00813403          	ld	s0,8(sp)
    80001d8c:	00003317          	auipc	t1,0x3
    80001d90:	78c33303          	ld	t1,1932(t1) # 80005518 <devsw+0x18>
    80001d94:	01010113          	addi	sp,sp,16
    80001d98:	00030067          	jr	t1

0000000080001d9c <panic>:
    80001d9c:	fe010113          	addi	sp,sp,-32
    80001da0:	00113c23          	sd	ra,24(sp)
    80001da4:	00813823          	sd	s0,16(sp)
    80001da8:	00913423          	sd	s1,8(sp)
    80001dac:	02010413          	addi	s0,sp,32
    80001db0:	00050493          	mv	s1,a0
    80001db4:	00002517          	auipc	a0,0x2
    80001db8:	3fc50513          	addi	a0,a0,1020 # 800041b0 <CONSOLE_STATUS+0x1a0>
    80001dbc:	00003797          	auipc	a5,0x3
    80001dc0:	7e07ae23          	sw	zero,2044(a5) # 800055b8 <pr+0x18>
    80001dc4:	00000097          	auipc	ra,0x0
    80001dc8:	034080e7          	jalr	52(ra) # 80001df8 <__printf>
    80001dcc:	00048513          	mv	a0,s1
    80001dd0:	00000097          	auipc	ra,0x0
    80001dd4:	028080e7          	jalr	40(ra) # 80001df8 <__printf>
    80001dd8:	00002517          	auipc	a0,0x2
    80001ddc:	3b850513          	addi	a0,a0,952 # 80004190 <CONSOLE_STATUS+0x180>
    80001de0:	00000097          	auipc	ra,0x0
    80001de4:	018080e7          	jalr	24(ra) # 80001df8 <__printf>
    80001de8:	00100793          	li	a5,1
    80001dec:	00002717          	auipc	a4,0x2
    80001df0:	58f72223          	sw	a5,1412(a4) # 80004370 <panicked>
    80001df4:	0000006f          	j	80001df4 <panic+0x58>

0000000080001df8 <__printf>:
    80001df8:	f3010113          	addi	sp,sp,-208
    80001dfc:	08813023          	sd	s0,128(sp)
    80001e00:	07313423          	sd	s3,104(sp)
    80001e04:	09010413          	addi	s0,sp,144
    80001e08:	05813023          	sd	s8,64(sp)
    80001e0c:	08113423          	sd	ra,136(sp)
    80001e10:	06913c23          	sd	s1,120(sp)
    80001e14:	07213823          	sd	s2,112(sp)
    80001e18:	07413023          	sd	s4,96(sp)
    80001e1c:	05513c23          	sd	s5,88(sp)
    80001e20:	05613823          	sd	s6,80(sp)
    80001e24:	05713423          	sd	s7,72(sp)
    80001e28:	03913c23          	sd	s9,56(sp)
    80001e2c:	03a13823          	sd	s10,48(sp)
    80001e30:	03b13423          	sd	s11,40(sp)
    80001e34:	00003317          	auipc	t1,0x3
    80001e38:	76c30313          	addi	t1,t1,1900 # 800055a0 <pr>
    80001e3c:	01832c03          	lw	s8,24(t1)
    80001e40:	00b43423          	sd	a1,8(s0)
    80001e44:	00c43823          	sd	a2,16(s0)
    80001e48:	00d43c23          	sd	a3,24(s0)
    80001e4c:	02e43023          	sd	a4,32(s0)
    80001e50:	02f43423          	sd	a5,40(s0)
    80001e54:	03043823          	sd	a6,48(s0)
    80001e58:	03143c23          	sd	a7,56(s0)
    80001e5c:	00050993          	mv	s3,a0
    80001e60:	4a0c1663          	bnez	s8,8000230c <__printf+0x514>
    80001e64:	60098c63          	beqz	s3,8000247c <__printf+0x684>
    80001e68:	0009c503          	lbu	a0,0(s3)
    80001e6c:	00840793          	addi	a5,s0,8
    80001e70:	f6f43c23          	sd	a5,-136(s0)
    80001e74:	00000493          	li	s1,0
    80001e78:	22050063          	beqz	a0,80002098 <__printf+0x2a0>
    80001e7c:	00002a37          	lui	s4,0x2
    80001e80:	00018ab7          	lui	s5,0x18
    80001e84:	000f4b37          	lui	s6,0xf4
    80001e88:	00989bb7          	lui	s7,0x989
    80001e8c:	70fa0a13          	addi	s4,s4,1807 # 270f <_entry-0x7fffd8f1>
    80001e90:	69fa8a93          	addi	s5,s5,1695 # 1869f <_entry-0x7ffe7961>
    80001e94:	23fb0b13          	addi	s6,s6,575 # f423f <_entry-0x7ff0bdc1>
    80001e98:	67fb8b93          	addi	s7,s7,1663 # 98967f <_entry-0x7f676981>
    80001e9c:	00148c9b          	addiw	s9,s1,1
    80001ea0:	02500793          	li	a5,37
    80001ea4:	01998933          	add	s2,s3,s9
    80001ea8:	38f51263          	bne	a0,a5,8000222c <__printf+0x434>
    80001eac:	00094783          	lbu	a5,0(s2)
    80001eb0:	00078c9b          	sext.w	s9,a5
    80001eb4:	1e078263          	beqz	a5,80002098 <__printf+0x2a0>
    80001eb8:	0024849b          	addiw	s1,s1,2
    80001ebc:	07000713          	li	a4,112
    80001ec0:	00998933          	add	s2,s3,s1
    80001ec4:	38e78a63          	beq	a5,a4,80002258 <__printf+0x460>
    80001ec8:	20f76863          	bltu	a4,a5,800020d8 <__printf+0x2e0>
    80001ecc:	42a78863          	beq	a5,a0,800022fc <__printf+0x504>
    80001ed0:	06400713          	li	a4,100
    80001ed4:	40e79663          	bne	a5,a4,800022e0 <__printf+0x4e8>
    80001ed8:	f7843783          	ld	a5,-136(s0)
    80001edc:	0007a603          	lw	a2,0(a5)
    80001ee0:	00878793          	addi	a5,a5,8
    80001ee4:	f6f43c23          	sd	a5,-136(s0)
    80001ee8:	42064a63          	bltz	a2,8000231c <__printf+0x524>
    80001eec:	00a00713          	li	a4,10
    80001ef0:	02e677bb          	remuw	a5,a2,a4
    80001ef4:	00002d97          	auipc	s11,0x2
    80001ef8:	2e4d8d93          	addi	s11,s11,740 # 800041d8 <digits>
    80001efc:	00900593          	li	a1,9
    80001f00:	0006051b          	sext.w	a0,a2
    80001f04:	00000c93          	li	s9,0
    80001f08:	02079793          	slli	a5,a5,0x20
    80001f0c:	0207d793          	srli	a5,a5,0x20
    80001f10:	00fd87b3          	add	a5,s11,a5
    80001f14:	0007c783          	lbu	a5,0(a5)
    80001f18:	02e656bb          	divuw	a3,a2,a4
    80001f1c:	f8f40023          	sb	a5,-128(s0)
    80001f20:	14c5d863          	bge	a1,a2,80002070 <__printf+0x278>
    80001f24:	06300593          	li	a1,99
    80001f28:	00100c93          	li	s9,1
    80001f2c:	02e6f7bb          	remuw	a5,a3,a4
    80001f30:	02079793          	slli	a5,a5,0x20
    80001f34:	0207d793          	srli	a5,a5,0x20
    80001f38:	00fd87b3          	add	a5,s11,a5
    80001f3c:	0007c783          	lbu	a5,0(a5)
    80001f40:	02e6d73b          	divuw	a4,a3,a4
    80001f44:	f8f400a3          	sb	a5,-127(s0)
    80001f48:	12a5f463          	bgeu	a1,a0,80002070 <__printf+0x278>
    80001f4c:	00a00693          	li	a3,10
    80001f50:	00900593          	li	a1,9
    80001f54:	02d777bb          	remuw	a5,a4,a3
    80001f58:	02079793          	slli	a5,a5,0x20
    80001f5c:	0207d793          	srli	a5,a5,0x20
    80001f60:	00fd87b3          	add	a5,s11,a5
    80001f64:	0007c503          	lbu	a0,0(a5)
    80001f68:	02d757bb          	divuw	a5,a4,a3
    80001f6c:	f8a40123          	sb	a0,-126(s0)
    80001f70:	48e5f263          	bgeu	a1,a4,800023f4 <__printf+0x5fc>
    80001f74:	06300513          	li	a0,99
    80001f78:	02d7f5bb          	remuw	a1,a5,a3
    80001f7c:	02059593          	slli	a1,a1,0x20
    80001f80:	0205d593          	srli	a1,a1,0x20
    80001f84:	00bd85b3          	add	a1,s11,a1
    80001f88:	0005c583          	lbu	a1,0(a1)
    80001f8c:	02d7d7bb          	divuw	a5,a5,a3
    80001f90:	f8b401a3          	sb	a1,-125(s0)
    80001f94:	48e57263          	bgeu	a0,a4,80002418 <__printf+0x620>
    80001f98:	3e700513          	li	a0,999
    80001f9c:	02d7f5bb          	remuw	a1,a5,a3
    80001fa0:	02059593          	slli	a1,a1,0x20
    80001fa4:	0205d593          	srli	a1,a1,0x20
    80001fa8:	00bd85b3          	add	a1,s11,a1
    80001fac:	0005c583          	lbu	a1,0(a1)
    80001fb0:	02d7d7bb          	divuw	a5,a5,a3
    80001fb4:	f8b40223          	sb	a1,-124(s0)
    80001fb8:	46e57663          	bgeu	a0,a4,80002424 <__printf+0x62c>
    80001fbc:	02d7f5bb          	remuw	a1,a5,a3
    80001fc0:	02059593          	slli	a1,a1,0x20
    80001fc4:	0205d593          	srli	a1,a1,0x20
    80001fc8:	00bd85b3          	add	a1,s11,a1
    80001fcc:	0005c583          	lbu	a1,0(a1)
    80001fd0:	02d7d7bb          	divuw	a5,a5,a3
    80001fd4:	f8b402a3          	sb	a1,-123(s0)
    80001fd8:	46ea7863          	bgeu	s4,a4,80002448 <__printf+0x650>
    80001fdc:	02d7f5bb          	remuw	a1,a5,a3
    80001fe0:	02059593          	slli	a1,a1,0x20
    80001fe4:	0205d593          	srli	a1,a1,0x20
    80001fe8:	00bd85b3          	add	a1,s11,a1
    80001fec:	0005c583          	lbu	a1,0(a1)
    80001ff0:	02d7d7bb          	divuw	a5,a5,a3
    80001ff4:	f8b40323          	sb	a1,-122(s0)
    80001ff8:	3eeaf863          	bgeu	s5,a4,800023e8 <__printf+0x5f0>
    80001ffc:	02d7f5bb          	remuw	a1,a5,a3
    80002000:	02059593          	slli	a1,a1,0x20
    80002004:	0205d593          	srli	a1,a1,0x20
    80002008:	00bd85b3          	add	a1,s11,a1
    8000200c:	0005c583          	lbu	a1,0(a1)
    80002010:	02d7d7bb          	divuw	a5,a5,a3
    80002014:	f8b403a3          	sb	a1,-121(s0)
    80002018:	42eb7e63          	bgeu	s6,a4,80002454 <__printf+0x65c>
    8000201c:	02d7f5bb          	remuw	a1,a5,a3
    80002020:	02059593          	slli	a1,a1,0x20
    80002024:	0205d593          	srli	a1,a1,0x20
    80002028:	00bd85b3          	add	a1,s11,a1
    8000202c:	0005c583          	lbu	a1,0(a1)
    80002030:	02d7d7bb          	divuw	a5,a5,a3
    80002034:	f8b40423          	sb	a1,-120(s0)
    80002038:	42ebfc63          	bgeu	s7,a4,80002470 <__printf+0x678>
    8000203c:	02079793          	slli	a5,a5,0x20
    80002040:	0207d793          	srli	a5,a5,0x20
    80002044:	00fd8db3          	add	s11,s11,a5
    80002048:	000dc703          	lbu	a4,0(s11)
    8000204c:	00a00793          	li	a5,10
    80002050:	00900c93          	li	s9,9
    80002054:	f8e404a3          	sb	a4,-119(s0)
    80002058:	00065c63          	bgez	a2,80002070 <__printf+0x278>
    8000205c:	f9040713          	addi	a4,s0,-112
    80002060:	00f70733          	add	a4,a4,a5
    80002064:	02d00693          	li	a3,45
    80002068:	fed70823          	sb	a3,-16(a4)
    8000206c:	00078c93          	mv	s9,a5
    80002070:	f8040793          	addi	a5,s0,-128
    80002074:	01978cb3          	add	s9,a5,s9
    80002078:	f7f40d13          	addi	s10,s0,-129
    8000207c:	000cc503          	lbu	a0,0(s9)
    80002080:	fffc8c93          	addi	s9,s9,-1
    80002084:	00000097          	auipc	ra,0x0
    80002088:	b90080e7          	jalr	-1136(ra) # 80001c14 <consputc>
    8000208c:	ffac98e3          	bne	s9,s10,8000207c <__printf+0x284>
    80002090:	00094503          	lbu	a0,0(s2)
    80002094:	e00514e3          	bnez	a0,80001e9c <__printf+0xa4>
    80002098:	1a0c1663          	bnez	s8,80002244 <__printf+0x44c>
    8000209c:	08813083          	ld	ra,136(sp)
    800020a0:	08013403          	ld	s0,128(sp)
    800020a4:	07813483          	ld	s1,120(sp)
    800020a8:	07013903          	ld	s2,112(sp)
    800020ac:	06813983          	ld	s3,104(sp)
    800020b0:	06013a03          	ld	s4,96(sp)
    800020b4:	05813a83          	ld	s5,88(sp)
    800020b8:	05013b03          	ld	s6,80(sp)
    800020bc:	04813b83          	ld	s7,72(sp)
    800020c0:	04013c03          	ld	s8,64(sp)
    800020c4:	03813c83          	ld	s9,56(sp)
    800020c8:	03013d03          	ld	s10,48(sp)
    800020cc:	02813d83          	ld	s11,40(sp)
    800020d0:	0d010113          	addi	sp,sp,208
    800020d4:	00008067          	ret
    800020d8:	07300713          	li	a4,115
    800020dc:	1ce78a63          	beq	a5,a4,800022b0 <__printf+0x4b8>
    800020e0:	07800713          	li	a4,120
    800020e4:	1ee79e63          	bne	a5,a4,800022e0 <__printf+0x4e8>
    800020e8:	f7843783          	ld	a5,-136(s0)
    800020ec:	0007a703          	lw	a4,0(a5)
    800020f0:	00878793          	addi	a5,a5,8
    800020f4:	f6f43c23          	sd	a5,-136(s0)
    800020f8:	28074263          	bltz	a4,8000237c <__printf+0x584>
    800020fc:	00002d97          	auipc	s11,0x2
    80002100:	0dcd8d93          	addi	s11,s11,220 # 800041d8 <digits>
    80002104:	00f77793          	andi	a5,a4,15
    80002108:	00fd87b3          	add	a5,s11,a5
    8000210c:	0007c683          	lbu	a3,0(a5)
    80002110:	00f00613          	li	a2,15
    80002114:	0007079b          	sext.w	a5,a4
    80002118:	f8d40023          	sb	a3,-128(s0)
    8000211c:	0047559b          	srliw	a1,a4,0x4
    80002120:	0047569b          	srliw	a3,a4,0x4
    80002124:	00000c93          	li	s9,0
    80002128:	0ee65063          	bge	a2,a4,80002208 <__printf+0x410>
    8000212c:	00f6f693          	andi	a3,a3,15
    80002130:	00dd86b3          	add	a3,s11,a3
    80002134:	0006c683          	lbu	a3,0(a3) # 2004000 <_entry-0x7dffc000>
    80002138:	0087d79b          	srliw	a5,a5,0x8
    8000213c:	00100c93          	li	s9,1
    80002140:	f8d400a3          	sb	a3,-127(s0)
    80002144:	0cb67263          	bgeu	a2,a1,80002208 <__printf+0x410>
    80002148:	00f7f693          	andi	a3,a5,15
    8000214c:	00dd86b3          	add	a3,s11,a3
    80002150:	0006c583          	lbu	a1,0(a3)
    80002154:	00f00613          	li	a2,15
    80002158:	0047d69b          	srliw	a3,a5,0x4
    8000215c:	f8b40123          	sb	a1,-126(s0)
    80002160:	0047d593          	srli	a1,a5,0x4
    80002164:	28f67e63          	bgeu	a2,a5,80002400 <__printf+0x608>
    80002168:	00f6f693          	andi	a3,a3,15
    8000216c:	00dd86b3          	add	a3,s11,a3
    80002170:	0006c503          	lbu	a0,0(a3)
    80002174:	0087d813          	srli	a6,a5,0x8
    80002178:	0087d69b          	srliw	a3,a5,0x8
    8000217c:	f8a401a3          	sb	a0,-125(s0)
    80002180:	28b67663          	bgeu	a2,a1,8000240c <__printf+0x614>
    80002184:	00f6f693          	andi	a3,a3,15
    80002188:	00dd86b3          	add	a3,s11,a3
    8000218c:	0006c583          	lbu	a1,0(a3)
    80002190:	00c7d513          	srli	a0,a5,0xc
    80002194:	00c7d69b          	srliw	a3,a5,0xc
    80002198:	f8b40223          	sb	a1,-124(s0)
    8000219c:	29067a63          	bgeu	a2,a6,80002430 <__printf+0x638>
    800021a0:	00f6f693          	andi	a3,a3,15
    800021a4:	00dd86b3          	add	a3,s11,a3
    800021a8:	0006c583          	lbu	a1,0(a3)
    800021ac:	0107d813          	srli	a6,a5,0x10
    800021b0:	0107d69b          	srliw	a3,a5,0x10
    800021b4:	f8b402a3          	sb	a1,-123(s0)
    800021b8:	28a67263          	bgeu	a2,a0,8000243c <__printf+0x644>
    800021bc:	00f6f693          	andi	a3,a3,15
    800021c0:	00dd86b3          	add	a3,s11,a3
    800021c4:	0006c683          	lbu	a3,0(a3)
    800021c8:	0147d79b          	srliw	a5,a5,0x14
    800021cc:	f8d40323          	sb	a3,-122(s0)
    800021d0:	21067663          	bgeu	a2,a6,800023dc <__printf+0x5e4>
    800021d4:	02079793          	slli	a5,a5,0x20
    800021d8:	0207d793          	srli	a5,a5,0x20
    800021dc:	00fd8db3          	add	s11,s11,a5
    800021e0:	000dc683          	lbu	a3,0(s11)
    800021e4:	00800793          	li	a5,8
    800021e8:	00700c93          	li	s9,7
    800021ec:	f8d403a3          	sb	a3,-121(s0)
    800021f0:	00075c63          	bgez	a4,80002208 <__printf+0x410>
    800021f4:	f9040713          	addi	a4,s0,-112
    800021f8:	00f70733          	add	a4,a4,a5
    800021fc:	02d00693          	li	a3,45
    80002200:	fed70823          	sb	a3,-16(a4)
    80002204:	00078c93          	mv	s9,a5
    80002208:	f8040793          	addi	a5,s0,-128
    8000220c:	01978cb3          	add	s9,a5,s9
    80002210:	f7f40d13          	addi	s10,s0,-129
    80002214:	000cc503          	lbu	a0,0(s9)
    80002218:	fffc8c93          	addi	s9,s9,-1
    8000221c:	00000097          	auipc	ra,0x0
    80002220:	9f8080e7          	jalr	-1544(ra) # 80001c14 <consputc>
    80002224:	ff9d18e3          	bne	s10,s9,80002214 <__printf+0x41c>
    80002228:	0100006f          	j	80002238 <__printf+0x440>
    8000222c:	00000097          	auipc	ra,0x0
    80002230:	9e8080e7          	jalr	-1560(ra) # 80001c14 <consputc>
    80002234:	000c8493          	mv	s1,s9
    80002238:	00094503          	lbu	a0,0(s2)
    8000223c:	c60510e3          	bnez	a0,80001e9c <__printf+0xa4>
    80002240:	e40c0ee3          	beqz	s8,8000209c <__printf+0x2a4>
    80002244:	00003517          	auipc	a0,0x3
    80002248:	35c50513          	addi	a0,a0,860 # 800055a0 <pr>
    8000224c:	00001097          	auipc	ra,0x1
    80002250:	94c080e7          	jalr	-1716(ra) # 80002b98 <release>
    80002254:	e49ff06f          	j	8000209c <__printf+0x2a4>
    80002258:	f7843783          	ld	a5,-136(s0)
    8000225c:	03000513          	li	a0,48
    80002260:	01000d13          	li	s10,16
    80002264:	00878713          	addi	a4,a5,8
    80002268:	0007bc83          	ld	s9,0(a5)
    8000226c:	f6e43c23          	sd	a4,-136(s0)
    80002270:	00000097          	auipc	ra,0x0
    80002274:	9a4080e7          	jalr	-1628(ra) # 80001c14 <consputc>
    80002278:	07800513          	li	a0,120
    8000227c:	00000097          	auipc	ra,0x0
    80002280:	998080e7          	jalr	-1640(ra) # 80001c14 <consputc>
    80002284:	00002d97          	auipc	s11,0x2
    80002288:	f54d8d93          	addi	s11,s11,-172 # 800041d8 <digits>
    8000228c:	03ccd793          	srli	a5,s9,0x3c
    80002290:	00fd87b3          	add	a5,s11,a5
    80002294:	0007c503          	lbu	a0,0(a5)
    80002298:	fffd0d1b          	addiw	s10,s10,-1
    8000229c:	004c9c93          	slli	s9,s9,0x4
    800022a0:	00000097          	auipc	ra,0x0
    800022a4:	974080e7          	jalr	-1676(ra) # 80001c14 <consputc>
    800022a8:	fe0d12e3          	bnez	s10,8000228c <__printf+0x494>
    800022ac:	f8dff06f          	j	80002238 <__printf+0x440>
    800022b0:	f7843783          	ld	a5,-136(s0)
    800022b4:	0007bc83          	ld	s9,0(a5)
    800022b8:	00878793          	addi	a5,a5,8
    800022bc:	f6f43c23          	sd	a5,-136(s0)
    800022c0:	000c9a63          	bnez	s9,800022d4 <__printf+0x4dc>
    800022c4:	1080006f          	j	800023cc <__printf+0x5d4>
    800022c8:	001c8c93          	addi	s9,s9,1
    800022cc:	00000097          	auipc	ra,0x0
    800022d0:	948080e7          	jalr	-1720(ra) # 80001c14 <consputc>
    800022d4:	000cc503          	lbu	a0,0(s9)
    800022d8:	fe0518e3          	bnez	a0,800022c8 <__printf+0x4d0>
    800022dc:	f5dff06f          	j	80002238 <__printf+0x440>
    800022e0:	02500513          	li	a0,37
    800022e4:	00000097          	auipc	ra,0x0
    800022e8:	930080e7          	jalr	-1744(ra) # 80001c14 <consputc>
    800022ec:	000c8513          	mv	a0,s9
    800022f0:	00000097          	auipc	ra,0x0
    800022f4:	924080e7          	jalr	-1756(ra) # 80001c14 <consputc>
    800022f8:	f41ff06f          	j	80002238 <__printf+0x440>
    800022fc:	02500513          	li	a0,37
    80002300:	00000097          	auipc	ra,0x0
    80002304:	914080e7          	jalr	-1772(ra) # 80001c14 <consputc>
    80002308:	f31ff06f          	j	80002238 <__printf+0x440>
    8000230c:	00030513          	mv	a0,t1
    80002310:	00000097          	auipc	ra,0x0
    80002314:	7bc080e7          	jalr	1980(ra) # 80002acc <acquire>
    80002318:	b4dff06f          	j	80001e64 <__printf+0x6c>
    8000231c:	40c0053b          	negw	a0,a2
    80002320:	00a00713          	li	a4,10
    80002324:	02e576bb          	remuw	a3,a0,a4
    80002328:	00002d97          	auipc	s11,0x2
    8000232c:	eb0d8d93          	addi	s11,s11,-336 # 800041d8 <digits>
    80002330:	ff700593          	li	a1,-9
    80002334:	02069693          	slli	a3,a3,0x20
    80002338:	0206d693          	srli	a3,a3,0x20
    8000233c:	00dd86b3          	add	a3,s11,a3
    80002340:	0006c683          	lbu	a3,0(a3)
    80002344:	02e557bb          	divuw	a5,a0,a4
    80002348:	f8d40023          	sb	a3,-128(s0)
    8000234c:	10b65e63          	bge	a2,a1,80002468 <__printf+0x670>
    80002350:	06300593          	li	a1,99
    80002354:	02e7f6bb          	remuw	a3,a5,a4
    80002358:	02069693          	slli	a3,a3,0x20
    8000235c:	0206d693          	srli	a3,a3,0x20
    80002360:	00dd86b3          	add	a3,s11,a3
    80002364:	0006c683          	lbu	a3,0(a3)
    80002368:	02e7d73b          	divuw	a4,a5,a4
    8000236c:	00200793          	li	a5,2
    80002370:	f8d400a3          	sb	a3,-127(s0)
    80002374:	bca5ece3          	bltu	a1,a0,80001f4c <__printf+0x154>
    80002378:	ce5ff06f          	j	8000205c <__printf+0x264>
    8000237c:	40e007bb          	negw	a5,a4
    80002380:	00002d97          	auipc	s11,0x2
    80002384:	e58d8d93          	addi	s11,s11,-424 # 800041d8 <digits>
    80002388:	00f7f693          	andi	a3,a5,15
    8000238c:	00dd86b3          	add	a3,s11,a3
    80002390:	0006c583          	lbu	a1,0(a3)
    80002394:	ff100613          	li	a2,-15
    80002398:	0047d69b          	srliw	a3,a5,0x4
    8000239c:	f8b40023          	sb	a1,-128(s0)
    800023a0:	0047d59b          	srliw	a1,a5,0x4
    800023a4:	0ac75e63          	bge	a4,a2,80002460 <__printf+0x668>
    800023a8:	00f6f693          	andi	a3,a3,15
    800023ac:	00dd86b3          	add	a3,s11,a3
    800023b0:	0006c603          	lbu	a2,0(a3)
    800023b4:	00f00693          	li	a3,15
    800023b8:	0087d79b          	srliw	a5,a5,0x8
    800023bc:	f8c400a3          	sb	a2,-127(s0)
    800023c0:	d8b6e4e3          	bltu	a3,a1,80002148 <__printf+0x350>
    800023c4:	00200793          	li	a5,2
    800023c8:	e2dff06f          	j	800021f4 <__printf+0x3fc>
    800023cc:	00002c97          	auipc	s9,0x2
    800023d0:	decc8c93          	addi	s9,s9,-532 # 800041b8 <CONSOLE_STATUS+0x1a8>
    800023d4:	02800513          	li	a0,40
    800023d8:	ef1ff06f          	j	800022c8 <__printf+0x4d0>
    800023dc:	00700793          	li	a5,7
    800023e0:	00600c93          	li	s9,6
    800023e4:	e0dff06f          	j	800021f0 <__printf+0x3f8>
    800023e8:	00700793          	li	a5,7
    800023ec:	00600c93          	li	s9,6
    800023f0:	c69ff06f          	j	80002058 <__printf+0x260>
    800023f4:	00300793          	li	a5,3
    800023f8:	00200c93          	li	s9,2
    800023fc:	c5dff06f          	j	80002058 <__printf+0x260>
    80002400:	00300793          	li	a5,3
    80002404:	00200c93          	li	s9,2
    80002408:	de9ff06f          	j	800021f0 <__printf+0x3f8>
    8000240c:	00400793          	li	a5,4
    80002410:	00300c93          	li	s9,3
    80002414:	dddff06f          	j	800021f0 <__printf+0x3f8>
    80002418:	00400793          	li	a5,4
    8000241c:	00300c93          	li	s9,3
    80002420:	c39ff06f          	j	80002058 <__printf+0x260>
    80002424:	00500793          	li	a5,5
    80002428:	00400c93          	li	s9,4
    8000242c:	c2dff06f          	j	80002058 <__printf+0x260>
    80002430:	00500793          	li	a5,5
    80002434:	00400c93          	li	s9,4
    80002438:	db9ff06f          	j	800021f0 <__printf+0x3f8>
    8000243c:	00600793          	li	a5,6
    80002440:	00500c93          	li	s9,5
    80002444:	dadff06f          	j	800021f0 <__printf+0x3f8>
    80002448:	00600793          	li	a5,6
    8000244c:	00500c93          	li	s9,5
    80002450:	c09ff06f          	j	80002058 <__printf+0x260>
    80002454:	00800793          	li	a5,8
    80002458:	00700c93          	li	s9,7
    8000245c:	bfdff06f          	j	80002058 <__printf+0x260>
    80002460:	00100793          	li	a5,1
    80002464:	d91ff06f          	j	800021f4 <__printf+0x3fc>
    80002468:	00100793          	li	a5,1
    8000246c:	bf1ff06f          	j	8000205c <__printf+0x264>
    80002470:	00900793          	li	a5,9
    80002474:	00800c93          	li	s9,8
    80002478:	be1ff06f          	j	80002058 <__printf+0x260>
    8000247c:	00002517          	auipc	a0,0x2
    80002480:	d4450513          	addi	a0,a0,-700 # 800041c0 <CONSOLE_STATUS+0x1b0>
    80002484:	00000097          	auipc	ra,0x0
    80002488:	918080e7          	jalr	-1768(ra) # 80001d9c <panic>

000000008000248c <printfinit>:
    8000248c:	fe010113          	addi	sp,sp,-32
    80002490:	00813823          	sd	s0,16(sp)
    80002494:	00913423          	sd	s1,8(sp)
    80002498:	00113c23          	sd	ra,24(sp)
    8000249c:	02010413          	addi	s0,sp,32
    800024a0:	00003497          	auipc	s1,0x3
    800024a4:	10048493          	addi	s1,s1,256 # 800055a0 <pr>
    800024a8:	00048513          	mv	a0,s1
    800024ac:	00002597          	auipc	a1,0x2
    800024b0:	d2458593          	addi	a1,a1,-732 # 800041d0 <CONSOLE_STATUS+0x1c0>
    800024b4:	00000097          	auipc	ra,0x0
    800024b8:	5f4080e7          	jalr	1524(ra) # 80002aa8 <initlock>
    800024bc:	01813083          	ld	ra,24(sp)
    800024c0:	01013403          	ld	s0,16(sp)
    800024c4:	0004ac23          	sw	zero,24(s1)
    800024c8:	00813483          	ld	s1,8(sp)
    800024cc:	02010113          	addi	sp,sp,32
    800024d0:	00008067          	ret

00000000800024d4 <uartinit>:
    800024d4:	ff010113          	addi	sp,sp,-16
    800024d8:	00813423          	sd	s0,8(sp)
    800024dc:	01010413          	addi	s0,sp,16
    800024e0:	100007b7          	lui	a5,0x10000
    800024e4:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>
    800024e8:	f8000713          	li	a4,-128
    800024ec:	00e781a3          	sb	a4,3(a5)
    800024f0:	00300713          	li	a4,3
    800024f4:	00e78023          	sb	a4,0(a5)
    800024f8:	000780a3          	sb	zero,1(a5)
    800024fc:	00e781a3          	sb	a4,3(a5)
    80002500:	00700693          	li	a3,7
    80002504:	00d78123          	sb	a3,2(a5)
    80002508:	00e780a3          	sb	a4,1(a5)
    8000250c:	00813403          	ld	s0,8(sp)
    80002510:	01010113          	addi	sp,sp,16
    80002514:	00008067          	ret

0000000080002518 <uartputc>:
    80002518:	00002797          	auipc	a5,0x2
    8000251c:	e587a783          	lw	a5,-424(a5) # 80004370 <panicked>
    80002520:	00078463          	beqz	a5,80002528 <uartputc+0x10>
    80002524:	0000006f          	j	80002524 <uartputc+0xc>
    80002528:	fd010113          	addi	sp,sp,-48
    8000252c:	02813023          	sd	s0,32(sp)
    80002530:	00913c23          	sd	s1,24(sp)
    80002534:	01213823          	sd	s2,16(sp)
    80002538:	01313423          	sd	s3,8(sp)
    8000253c:	02113423          	sd	ra,40(sp)
    80002540:	03010413          	addi	s0,sp,48
    80002544:	00002917          	auipc	s2,0x2
    80002548:	e3490913          	addi	s2,s2,-460 # 80004378 <uart_tx_r>
    8000254c:	00093783          	ld	a5,0(s2)
    80002550:	00002497          	auipc	s1,0x2
    80002554:	e3048493          	addi	s1,s1,-464 # 80004380 <uart_tx_w>
    80002558:	0004b703          	ld	a4,0(s1)
    8000255c:	02078693          	addi	a3,a5,32
    80002560:	00050993          	mv	s3,a0
    80002564:	02e69c63          	bne	a3,a4,8000259c <uartputc+0x84>
    80002568:	00001097          	auipc	ra,0x1
    8000256c:	834080e7          	jalr	-1996(ra) # 80002d9c <push_on>
    80002570:	00093783          	ld	a5,0(s2)
    80002574:	0004b703          	ld	a4,0(s1)
    80002578:	02078793          	addi	a5,a5,32
    8000257c:	00e79463          	bne	a5,a4,80002584 <uartputc+0x6c>
    80002580:	0000006f          	j	80002580 <uartputc+0x68>
    80002584:	00001097          	auipc	ra,0x1
    80002588:	88c080e7          	jalr	-1908(ra) # 80002e10 <pop_on>
    8000258c:	00093783          	ld	a5,0(s2)
    80002590:	0004b703          	ld	a4,0(s1)
    80002594:	02078693          	addi	a3,a5,32
    80002598:	fce688e3          	beq	a3,a4,80002568 <uartputc+0x50>
    8000259c:	01f77693          	andi	a3,a4,31
    800025a0:	00003597          	auipc	a1,0x3
    800025a4:	02058593          	addi	a1,a1,32 # 800055c0 <uart_tx_buf>
    800025a8:	00d586b3          	add	a3,a1,a3
    800025ac:	00170713          	addi	a4,a4,1
    800025b0:	01368023          	sb	s3,0(a3)
    800025b4:	00e4b023          	sd	a4,0(s1)
    800025b8:	10000637          	lui	a2,0x10000
    800025bc:	02f71063          	bne	a4,a5,800025dc <uartputc+0xc4>
    800025c0:	0340006f          	j	800025f4 <uartputc+0xdc>
    800025c4:	00074703          	lbu	a4,0(a4)
    800025c8:	00f93023          	sd	a5,0(s2)
    800025cc:	00e60023          	sb	a4,0(a2) # 10000000 <_entry-0x70000000>
    800025d0:	00093783          	ld	a5,0(s2)
    800025d4:	0004b703          	ld	a4,0(s1)
    800025d8:	00f70e63          	beq	a4,a5,800025f4 <uartputc+0xdc>
    800025dc:	00564683          	lbu	a3,5(a2)
    800025e0:	01f7f713          	andi	a4,a5,31
    800025e4:	00e58733          	add	a4,a1,a4
    800025e8:	0206f693          	andi	a3,a3,32
    800025ec:	00178793          	addi	a5,a5,1
    800025f0:	fc069ae3          	bnez	a3,800025c4 <uartputc+0xac>
    800025f4:	02813083          	ld	ra,40(sp)
    800025f8:	02013403          	ld	s0,32(sp)
    800025fc:	01813483          	ld	s1,24(sp)
    80002600:	01013903          	ld	s2,16(sp)
    80002604:	00813983          	ld	s3,8(sp)
    80002608:	03010113          	addi	sp,sp,48
    8000260c:	00008067          	ret

0000000080002610 <uartputc_sync>:
    80002610:	ff010113          	addi	sp,sp,-16
    80002614:	00813423          	sd	s0,8(sp)
    80002618:	01010413          	addi	s0,sp,16
    8000261c:	00002717          	auipc	a4,0x2
    80002620:	d5472703          	lw	a4,-684(a4) # 80004370 <panicked>
    80002624:	02071663          	bnez	a4,80002650 <uartputc_sync+0x40>
    80002628:	00050793          	mv	a5,a0
    8000262c:	100006b7          	lui	a3,0x10000
    80002630:	0056c703          	lbu	a4,5(a3) # 10000005 <_entry-0x6ffffffb>
    80002634:	02077713          	andi	a4,a4,32
    80002638:	fe070ce3          	beqz	a4,80002630 <uartputc_sync+0x20>
    8000263c:	0ff7f793          	andi	a5,a5,255
    80002640:	00f68023          	sb	a5,0(a3)
    80002644:	00813403          	ld	s0,8(sp)
    80002648:	01010113          	addi	sp,sp,16
    8000264c:	00008067          	ret
    80002650:	0000006f          	j	80002650 <uartputc_sync+0x40>

0000000080002654 <uartstart>:
    80002654:	ff010113          	addi	sp,sp,-16
    80002658:	00813423          	sd	s0,8(sp)
    8000265c:	01010413          	addi	s0,sp,16
    80002660:	00002617          	auipc	a2,0x2
    80002664:	d1860613          	addi	a2,a2,-744 # 80004378 <uart_tx_r>
    80002668:	00002517          	auipc	a0,0x2
    8000266c:	d1850513          	addi	a0,a0,-744 # 80004380 <uart_tx_w>
    80002670:	00063783          	ld	a5,0(a2)
    80002674:	00053703          	ld	a4,0(a0)
    80002678:	04f70263          	beq	a4,a5,800026bc <uartstart+0x68>
    8000267c:	100005b7          	lui	a1,0x10000
    80002680:	00003817          	auipc	a6,0x3
    80002684:	f4080813          	addi	a6,a6,-192 # 800055c0 <uart_tx_buf>
    80002688:	01c0006f          	j	800026a4 <uartstart+0x50>
    8000268c:	0006c703          	lbu	a4,0(a3)
    80002690:	00f63023          	sd	a5,0(a2)
    80002694:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    80002698:	00063783          	ld	a5,0(a2)
    8000269c:	00053703          	ld	a4,0(a0)
    800026a0:	00f70e63          	beq	a4,a5,800026bc <uartstart+0x68>
    800026a4:	01f7f713          	andi	a4,a5,31
    800026a8:	00e806b3          	add	a3,a6,a4
    800026ac:	0055c703          	lbu	a4,5(a1)
    800026b0:	00178793          	addi	a5,a5,1
    800026b4:	02077713          	andi	a4,a4,32
    800026b8:	fc071ae3          	bnez	a4,8000268c <uartstart+0x38>
    800026bc:	00813403          	ld	s0,8(sp)
    800026c0:	01010113          	addi	sp,sp,16
    800026c4:	00008067          	ret

00000000800026c8 <uartgetc>:
    800026c8:	ff010113          	addi	sp,sp,-16
    800026cc:	00813423          	sd	s0,8(sp)
    800026d0:	01010413          	addi	s0,sp,16
    800026d4:	10000737          	lui	a4,0x10000
    800026d8:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800026dc:	0017f793          	andi	a5,a5,1
    800026e0:	00078c63          	beqz	a5,800026f8 <uartgetc+0x30>
    800026e4:	00074503          	lbu	a0,0(a4)
    800026e8:	0ff57513          	andi	a0,a0,255
    800026ec:	00813403          	ld	s0,8(sp)
    800026f0:	01010113          	addi	sp,sp,16
    800026f4:	00008067          	ret
    800026f8:	fff00513          	li	a0,-1
    800026fc:	ff1ff06f          	j	800026ec <uartgetc+0x24>

0000000080002700 <uartintr>:
    80002700:	100007b7          	lui	a5,0x10000
    80002704:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80002708:	0017f793          	andi	a5,a5,1
    8000270c:	0a078463          	beqz	a5,800027b4 <uartintr+0xb4>
    80002710:	fe010113          	addi	sp,sp,-32
    80002714:	00813823          	sd	s0,16(sp)
    80002718:	00913423          	sd	s1,8(sp)
    8000271c:	00113c23          	sd	ra,24(sp)
    80002720:	02010413          	addi	s0,sp,32
    80002724:	100004b7          	lui	s1,0x10000
    80002728:	0004c503          	lbu	a0,0(s1) # 10000000 <_entry-0x70000000>
    8000272c:	0ff57513          	andi	a0,a0,255
    80002730:	fffff097          	auipc	ra,0xfffff
    80002734:	534080e7          	jalr	1332(ra) # 80001c64 <consoleintr>
    80002738:	0054c783          	lbu	a5,5(s1)
    8000273c:	0017f793          	andi	a5,a5,1
    80002740:	fe0794e3          	bnez	a5,80002728 <uartintr+0x28>
    80002744:	00002617          	auipc	a2,0x2
    80002748:	c3460613          	addi	a2,a2,-972 # 80004378 <uart_tx_r>
    8000274c:	00002517          	auipc	a0,0x2
    80002750:	c3450513          	addi	a0,a0,-972 # 80004380 <uart_tx_w>
    80002754:	00063783          	ld	a5,0(a2)
    80002758:	00053703          	ld	a4,0(a0)
    8000275c:	04f70263          	beq	a4,a5,800027a0 <uartintr+0xa0>
    80002760:	100005b7          	lui	a1,0x10000
    80002764:	00003817          	auipc	a6,0x3
    80002768:	e5c80813          	addi	a6,a6,-420 # 800055c0 <uart_tx_buf>
    8000276c:	01c0006f          	j	80002788 <uartintr+0x88>
    80002770:	0006c703          	lbu	a4,0(a3)
    80002774:	00f63023          	sd	a5,0(a2)
    80002778:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    8000277c:	00063783          	ld	a5,0(a2)
    80002780:	00053703          	ld	a4,0(a0)
    80002784:	00f70e63          	beq	a4,a5,800027a0 <uartintr+0xa0>
    80002788:	01f7f713          	andi	a4,a5,31
    8000278c:	00e806b3          	add	a3,a6,a4
    80002790:	0055c703          	lbu	a4,5(a1)
    80002794:	00178793          	addi	a5,a5,1
    80002798:	02077713          	andi	a4,a4,32
    8000279c:	fc071ae3          	bnez	a4,80002770 <uartintr+0x70>
    800027a0:	01813083          	ld	ra,24(sp)
    800027a4:	01013403          	ld	s0,16(sp)
    800027a8:	00813483          	ld	s1,8(sp)
    800027ac:	02010113          	addi	sp,sp,32
    800027b0:	00008067          	ret
    800027b4:	00002617          	auipc	a2,0x2
    800027b8:	bc460613          	addi	a2,a2,-1084 # 80004378 <uart_tx_r>
    800027bc:	00002517          	auipc	a0,0x2
    800027c0:	bc450513          	addi	a0,a0,-1084 # 80004380 <uart_tx_w>
    800027c4:	00063783          	ld	a5,0(a2)
    800027c8:	00053703          	ld	a4,0(a0)
    800027cc:	04f70263          	beq	a4,a5,80002810 <uartintr+0x110>
    800027d0:	100005b7          	lui	a1,0x10000
    800027d4:	00003817          	auipc	a6,0x3
    800027d8:	dec80813          	addi	a6,a6,-532 # 800055c0 <uart_tx_buf>
    800027dc:	01c0006f          	j	800027f8 <uartintr+0xf8>
    800027e0:	0006c703          	lbu	a4,0(a3)
    800027e4:	00f63023          	sd	a5,0(a2)
    800027e8:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    800027ec:	00063783          	ld	a5,0(a2)
    800027f0:	00053703          	ld	a4,0(a0)
    800027f4:	02f70063          	beq	a4,a5,80002814 <uartintr+0x114>
    800027f8:	01f7f713          	andi	a4,a5,31
    800027fc:	00e806b3          	add	a3,a6,a4
    80002800:	0055c703          	lbu	a4,5(a1)
    80002804:	00178793          	addi	a5,a5,1
    80002808:	02077713          	andi	a4,a4,32
    8000280c:	fc071ae3          	bnez	a4,800027e0 <uartintr+0xe0>
    80002810:	00008067          	ret
    80002814:	00008067          	ret

0000000080002818 <kinit>:
    80002818:	fc010113          	addi	sp,sp,-64
    8000281c:	02913423          	sd	s1,40(sp)
    80002820:	fffff7b7          	lui	a5,0xfffff
    80002824:	00004497          	auipc	s1,0x4
    80002828:	dbb48493          	addi	s1,s1,-581 # 800065df <end+0xfff>
    8000282c:	02813823          	sd	s0,48(sp)
    80002830:	01313c23          	sd	s3,24(sp)
    80002834:	00f4f4b3          	and	s1,s1,a5
    80002838:	02113c23          	sd	ra,56(sp)
    8000283c:	03213023          	sd	s2,32(sp)
    80002840:	01413823          	sd	s4,16(sp)
    80002844:	01513423          	sd	s5,8(sp)
    80002848:	04010413          	addi	s0,sp,64
    8000284c:	000017b7          	lui	a5,0x1
    80002850:	01100993          	li	s3,17
    80002854:	00f487b3          	add	a5,s1,a5
    80002858:	01b99993          	slli	s3,s3,0x1b
    8000285c:	06f9e063          	bltu	s3,a5,800028bc <kinit+0xa4>
    80002860:	00003a97          	auipc	s5,0x3
    80002864:	d80a8a93          	addi	s5,s5,-640 # 800055e0 <end>
    80002868:	0754ec63          	bltu	s1,s5,800028e0 <kinit+0xc8>
    8000286c:	0734fa63          	bgeu	s1,s3,800028e0 <kinit+0xc8>
    80002870:	00088a37          	lui	s4,0x88
    80002874:	fffa0a13          	addi	s4,s4,-1 # 87fff <_entry-0x7ff78001>
    80002878:	00002917          	auipc	s2,0x2
    8000287c:	b1090913          	addi	s2,s2,-1264 # 80004388 <kmem>
    80002880:	00ca1a13          	slli	s4,s4,0xc
    80002884:	0140006f          	j	80002898 <kinit+0x80>
    80002888:	000017b7          	lui	a5,0x1
    8000288c:	00f484b3          	add	s1,s1,a5
    80002890:	0554e863          	bltu	s1,s5,800028e0 <kinit+0xc8>
    80002894:	0534f663          	bgeu	s1,s3,800028e0 <kinit+0xc8>
    80002898:	00001637          	lui	a2,0x1
    8000289c:	00100593          	li	a1,1
    800028a0:	00048513          	mv	a0,s1
    800028a4:	00000097          	auipc	ra,0x0
    800028a8:	5e4080e7          	jalr	1508(ra) # 80002e88 <__memset>
    800028ac:	00093783          	ld	a5,0(s2)
    800028b0:	00f4b023          	sd	a5,0(s1)
    800028b4:	00993023          	sd	s1,0(s2)
    800028b8:	fd4498e3          	bne	s1,s4,80002888 <kinit+0x70>
    800028bc:	03813083          	ld	ra,56(sp)
    800028c0:	03013403          	ld	s0,48(sp)
    800028c4:	02813483          	ld	s1,40(sp)
    800028c8:	02013903          	ld	s2,32(sp)
    800028cc:	01813983          	ld	s3,24(sp)
    800028d0:	01013a03          	ld	s4,16(sp)
    800028d4:	00813a83          	ld	s5,8(sp)
    800028d8:	04010113          	addi	sp,sp,64
    800028dc:	00008067          	ret
    800028e0:	00002517          	auipc	a0,0x2
    800028e4:	91050513          	addi	a0,a0,-1776 # 800041f0 <digits+0x18>
    800028e8:	fffff097          	auipc	ra,0xfffff
    800028ec:	4b4080e7          	jalr	1204(ra) # 80001d9c <panic>

00000000800028f0 <freerange>:
    800028f0:	fc010113          	addi	sp,sp,-64
    800028f4:	000017b7          	lui	a5,0x1
    800028f8:	02913423          	sd	s1,40(sp)
    800028fc:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80002900:	009504b3          	add	s1,a0,s1
    80002904:	fffff537          	lui	a0,0xfffff
    80002908:	02813823          	sd	s0,48(sp)
    8000290c:	02113c23          	sd	ra,56(sp)
    80002910:	03213023          	sd	s2,32(sp)
    80002914:	01313c23          	sd	s3,24(sp)
    80002918:	01413823          	sd	s4,16(sp)
    8000291c:	01513423          	sd	s5,8(sp)
    80002920:	01613023          	sd	s6,0(sp)
    80002924:	04010413          	addi	s0,sp,64
    80002928:	00a4f4b3          	and	s1,s1,a0
    8000292c:	00f487b3          	add	a5,s1,a5
    80002930:	06f5e463          	bltu	a1,a5,80002998 <freerange+0xa8>
    80002934:	00003a97          	auipc	s5,0x3
    80002938:	caca8a93          	addi	s5,s5,-852 # 800055e0 <end>
    8000293c:	0954e263          	bltu	s1,s5,800029c0 <freerange+0xd0>
    80002940:	01100993          	li	s3,17
    80002944:	01b99993          	slli	s3,s3,0x1b
    80002948:	0734fc63          	bgeu	s1,s3,800029c0 <freerange+0xd0>
    8000294c:	00058a13          	mv	s4,a1
    80002950:	00002917          	auipc	s2,0x2
    80002954:	a3890913          	addi	s2,s2,-1480 # 80004388 <kmem>
    80002958:	00002b37          	lui	s6,0x2
    8000295c:	0140006f          	j	80002970 <freerange+0x80>
    80002960:	000017b7          	lui	a5,0x1
    80002964:	00f484b3          	add	s1,s1,a5
    80002968:	0554ec63          	bltu	s1,s5,800029c0 <freerange+0xd0>
    8000296c:	0534fa63          	bgeu	s1,s3,800029c0 <freerange+0xd0>
    80002970:	00001637          	lui	a2,0x1
    80002974:	00100593          	li	a1,1
    80002978:	00048513          	mv	a0,s1
    8000297c:	00000097          	auipc	ra,0x0
    80002980:	50c080e7          	jalr	1292(ra) # 80002e88 <__memset>
    80002984:	00093703          	ld	a4,0(s2)
    80002988:	016487b3          	add	a5,s1,s6
    8000298c:	00e4b023          	sd	a4,0(s1)
    80002990:	00993023          	sd	s1,0(s2)
    80002994:	fcfa76e3          	bgeu	s4,a5,80002960 <freerange+0x70>
    80002998:	03813083          	ld	ra,56(sp)
    8000299c:	03013403          	ld	s0,48(sp)
    800029a0:	02813483          	ld	s1,40(sp)
    800029a4:	02013903          	ld	s2,32(sp)
    800029a8:	01813983          	ld	s3,24(sp)
    800029ac:	01013a03          	ld	s4,16(sp)
    800029b0:	00813a83          	ld	s5,8(sp)
    800029b4:	00013b03          	ld	s6,0(sp)
    800029b8:	04010113          	addi	sp,sp,64
    800029bc:	00008067          	ret
    800029c0:	00002517          	auipc	a0,0x2
    800029c4:	83050513          	addi	a0,a0,-2000 # 800041f0 <digits+0x18>
    800029c8:	fffff097          	auipc	ra,0xfffff
    800029cc:	3d4080e7          	jalr	980(ra) # 80001d9c <panic>

00000000800029d0 <kfree>:
    800029d0:	fe010113          	addi	sp,sp,-32
    800029d4:	00813823          	sd	s0,16(sp)
    800029d8:	00113c23          	sd	ra,24(sp)
    800029dc:	00913423          	sd	s1,8(sp)
    800029e0:	02010413          	addi	s0,sp,32
    800029e4:	03451793          	slli	a5,a0,0x34
    800029e8:	04079c63          	bnez	a5,80002a40 <kfree+0x70>
    800029ec:	00003797          	auipc	a5,0x3
    800029f0:	bf478793          	addi	a5,a5,-1036 # 800055e0 <end>
    800029f4:	00050493          	mv	s1,a0
    800029f8:	04f56463          	bltu	a0,a5,80002a40 <kfree+0x70>
    800029fc:	01100793          	li	a5,17
    80002a00:	01b79793          	slli	a5,a5,0x1b
    80002a04:	02f57e63          	bgeu	a0,a5,80002a40 <kfree+0x70>
    80002a08:	00001637          	lui	a2,0x1
    80002a0c:	00100593          	li	a1,1
    80002a10:	00000097          	auipc	ra,0x0
    80002a14:	478080e7          	jalr	1144(ra) # 80002e88 <__memset>
    80002a18:	00002797          	auipc	a5,0x2
    80002a1c:	97078793          	addi	a5,a5,-1680 # 80004388 <kmem>
    80002a20:	0007b703          	ld	a4,0(a5)
    80002a24:	01813083          	ld	ra,24(sp)
    80002a28:	01013403          	ld	s0,16(sp)
    80002a2c:	00e4b023          	sd	a4,0(s1)
    80002a30:	0097b023          	sd	s1,0(a5)
    80002a34:	00813483          	ld	s1,8(sp)
    80002a38:	02010113          	addi	sp,sp,32
    80002a3c:	00008067          	ret
    80002a40:	00001517          	auipc	a0,0x1
    80002a44:	7b050513          	addi	a0,a0,1968 # 800041f0 <digits+0x18>
    80002a48:	fffff097          	auipc	ra,0xfffff
    80002a4c:	354080e7          	jalr	852(ra) # 80001d9c <panic>

0000000080002a50 <kalloc>:
    80002a50:	fe010113          	addi	sp,sp,-32
    80002a54:	00813823          	sd	s0,16(sp)
    80002a58:	00913423          	sd	s1,8(sp)
    80002a5c:	00113c23          	sd	ra,24(sp)
    80002a60:	02010413          	addi	s0,sp,32
    80002a64:	00002797          	auipc	a5,0x2
    80002a68:	92478793          	addi	a5,a5,-1756 # 80004388 <kmem>
    80002a6c:	0007b483          	ld	s1,0(a5)
    80002a70:	02048063          	beqz	s1,80002a90 <kalloc+0x40>
    80002a74:	0004b703          	ld	a4,0(s1)
    80002a78:	00001637          	lui	a2,0x1
    80002a7c:	00500593          	li	a1,5
    80002a80:	00048513          	mv	a0,s1
    80002a84:	00e7b023          	sd	a4,0(a5)
    80002a88:	00000097          	auipc	ra,0x0
    80002a8c:	400080e7          	jalr	1024(ra) # 80002e88 <__memset>
    80002a90:	01813083          	ld	ra,24(sp)
    80002a94:	01013403          	ld	s0,16(sp)
    80002a98:	00048513          	mv	a0,s1
    80002a9c:	00813483          	ld	s1,8(sp)
    80002aa0:	02010113          	addi	sp,sp,32
    80002aa4:	00008067          	ret

0000000080002aa8 <initlock>:
    80002aa8:	ff010113          	addi	sp,sp,-16
    80002aac:	00813423          	sd	s0,8(sp)
    80002ab0:	01010413          	addi	s0,sp,16
    80002ab4:	00813403          	ld	s0,8(sp)
    80002ab8:	00b53423          	sd	a1,8(a0)
    80002abc:	00052023          	sw	zero,0(a0)
    80002ac0:	00053823          	sd	zero,16(a0)
    80002ac4:	01010113          	addi	sp,sp,16
    80002ac8:	00008067          	ret

0000000080002acc <acquire>:
    80002acc:	fe010113          	addi	sp,sp,-32
    80002ad0:	00813823          	sd	s0,16(sp)
    80002ad4:	00913423          	sd	s1,8(sp)
    80002ad8:	00113c23          	sd	ra,24(sp)
    80002adc:	01213023          	sd	s2,0(sp)
    80002ae0:	02010413          	addi	s0,sp,32
    80002ae4:	00050493          	mv	s1,a0
    80002ae8:	10002973          	csrr	s2,sstatus
    80002aec:	100027f3          	csrr	a5,sstatus
    80002af0:	ffd7f793          	andi	a5,a5,-3
    80002af4:	10079073          	csrw	sstatus,a5
    80002af8:	fffff097          	auipc	ra,0xfffff
    80002afc:	8e8080e7          	jalr	-1816(ra) # 800013e0 <mycpu>
    80002b00:	07852783          	lw	a5,120(a0)
    80002b04:	06078e63          	beqz	a5,80002b80 <acquire+0xb4>
    80002b08:	fffff097          	auipc	ra,0xfffff
    80002b0c:	8d8080e7          	jalr	-1832(ra) # 800013e0 <mycpu>
    80002b10:	07852783          	lw	a5,120(a0)
    80002b14:	0004a703          	lw	a4,0(s1)
    80002b18:	0017879b          	addiw	a5,a5,1
    80002b1c:	06f52c23          	sw	a5,120(a0)
    80002b20:	04071063          	bnez	a4,80002b60 <acquire+0x94>
    80002b24:	00100713          	li	a4,1
    80002b28:	00070793          	mv	a5,a4
    80002b2c:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80002b30:	0007879b          	sext.w	a5,a5
    80002b34:	fe079ae3          	bnez	a5,80002b28 <acquire+0x5c>
    80002b38:	0ff0000f          	fence
    80002b3c:	fffff097          	auipc	ra,0xfffff
    80002b40:	8a4080e7          	jalr	-1884(ra) # 800013e0 <mycpu>
    80002b44:	01813083          	ld	ra,24(sp)
    80002b48:	01013403          	ld	s0,16(sp)
    80002b4c:	00a4b823          	sd	a0,16(s1)
    80002b50:	00013903          	ld	s2,0(sp)
    80002b54:	00813483          	ld	s1,8(sp)
    80002b58:	02010113          	addi	sp,sp,32
    80002b5c:	00008067          	ret
    80002b60:	0104b903          	ld	s2,16(s1)
    80002b64:	fffff097          	auipc	ra,0xfffff
    80002b68:	87c080e7          	jalr	-1924(ra) # 800013e0 <mycpu>
    80002b6c:	faa91ce3          	bne	s2,a0,80002b24 <acquire+0x58>
    80002b70:	00001517          	auipc	a0,0x1
    80002b74:	68850513          	addi	a0,a0,1672 # 800041f8 <digits+0x20>
    80002b78:	fffff097          	auipc	ra,0xfffff
    80002b7c:	224080e7          	jalr	548(ra) # 80001d9c <panic>
    80002b80:	00195913          	srli	s2,s2,0x1
    80002b84:	fffff097          	auipc	ra,0xfffff
    80002b88:	85c080e7          	jalr	-1956(ra) # 800013e0 <mycpu>
    80002b8c:	00197913          	andi	s2,s2,1
    80002b90:	07252e23          	sw	s2,124(a0)
    80002b94:	f75ff06f          	j	80002b08 <acquire+0x3c>

0000000080002b98 <release>:
    80002b98:	fe010113          	addi	sp,sp,-32
    80002b9c:	00813823          	sd	s0,16(sp)
    80002ba0:	00113c23          	sd	ra,24(sp)
    80002ba4:	00913423          	sd	s1,8(sp)
    80002ba8:	01213023          	sd	s2,0(sp)
    80002bac:	02010413          	addi	s0,sp,32
    80002bb0:	00052783          	lw	a5,0(a0)
    80002bb4:	00079a63          	bnez	a5,80002bc8 <release+0x30>
    80002bb8:	00001517          	auipc	a0,0x1
    80002bbc:	64850513          	addi	a0,a0,1608 # 80004200 <digits+0x28>
    80002bc0:	fffff097          	auipc	ra,0xfffff
    80002bc4:	1dc080e7          	jalr	476(ra) # 80001d9c <panic>
    80002bc8:	01053903          	ld	s2,16(a0)
    80002bcc:	00050493          	mv	s1,a0
    80002bd0:	fffff097          	auipc	ra,0xfffff
    80002bd4:	810080e7          	jalr	-2032(ra) # 800013e0 <mycpu>
    80002bd8:	fea910e3          	bne	s2,a0,80002bb8 <release+0x20>
    80002bdc:	0004b823          	sd	zero,16(s1)
    80002be0:	0ff0000f          	fence
    80002be4:	0f50000f          	fence	iorw,ow
    80002be8:	0804a02f          	amoswap.w	zero,zero,(s1)
    80002bec:	ffffe097          	auipc	ra,0xffffe
    80002bf0:	7f4080e7          	jalr	2036(ra) # 800013e0 <mycpu>
    80002bf4:	100027f3          	csrr	a5,sstatus
    80002bf8:	0027f793          	andi	a5,a5,2
    80002bfc:	04079a63          	bnez	a5,80002c50 <release+0xb8>
    80002c00:	07852783          	lw	a5,120(a0)
    80002c04:	02f05e63          	blez	a5,80002c40 <release+0xa8>
    80002c08:	fff7871b          	addiw	a4,a5,-1
    80002c0c:	06e52c23          	sw	a4,120(a0)
    80002c10:	00071c63          	bnez	a4,80002c28 <release+0x90>
    80002c14:	07c52783          	lw	a5,124(a0)
    80002c18:	00078863          	beqz	a5,80002c28 <release+0x90>
    80002c1c:	100027f3          	csrr	a5,sstatus
    80002c20:	0027e793          	ori	a5,a5,2
    80002c24:	10079073          	csrw	sstatus,a5
    80002c28:	01813083          	ld	ra,24(sp)
    80002c2c:	01013403          	ld	s0,16(sp)
    80002c30:	00813483          	ld	s1,8(sp)
    80002c34:	00013903          	ld	s2,0(sp)
    80002c38:	02010113          	addi	sp,sp,32
    80002c3c:	00008067          	ret
    80002c40:	00001517          	auipc	a0,0x1
    80002c44:	5e050513          	addi	a0,a0,1504 # 80004220 <digits+0x48>
    80002c48:	fffff097          	auipc	ra,0xfffff
    80002c4c:	154080e7          	jalr	340(ra) # 80001d9c <panic>
    80002c50:	00001517          	auipc	a0,0x1
    80002c54:	5b850513          	addi	a0,a0,1464 # 80004208 <digits+0x30>
    80002c58:	fffff097          	auipc	ra,0xfffff
    80002c5c:	144080e7          	jalr	324(ra) # 80001d9c <panic>

0000000080002c60 <holding>:
    80002c60:	00052783          	lw	a5,0(a0)
    80002c64:	00079663          	bnez	a5,80002c70 <holding+0x10>
    80002c68:	00000513          	li	a0,0
    80002c6c:	00008067          	ret
    80002c70:	fe010113          	addi	sp,sp,-32
    80002c74:	00813823          	sd	s0,16(sp)
    80002c78:	00913423          	sd	s1,8(sp)
    80002c7c:	00113c23          	sd	ra,24(sp)
    80002c80:	02010413          	addi	s0,sp,32
    80002c84:	01053483          	ld	s1,16(a0)
    80002c88:	ffffe097          	auipc	ra,0xffffe
    80002c8c:	758080e7          	jalr	1880(ra) # 800013e0 <mycpu>
    80002c90:	01813083          	ld	ra,24(sp)
    80002c94:	01013403          	ld	s0,16(sp)
    80002c98:	40a48533          	sub	a0,s1,a0
    80002c9c:	00153513          	seqz	a0,a0
    80002ca0:	00813483          	ld	s1,8(sp)
    80002ca4:	02010113          	addi	sp,sp,32
    80002ca8:	00008067          	ret

0000000080002cac <push_off>:
    80002cac:	fe010113          	addi	sp,sp,-32
    80002cb0:	00813823          	sd	s0,16(sp)
    80002cb4:	00113c23          	sd	ra,24(sp)
    80002cb8:	00913423          	sd	s1,8(sp)
    80002cbc:	02010413          	addi	s0,sp,32
    80002cc0:	100024f3          	csrr	s1,sstatus
    80002cc4:	100027f3          	csrr	a5,sstatus
    80002cc8:	ffd7f793          	andi	a5,a5,-3
    80002ccc:	10079073          	csrw	sstatus,a5
    80002cd0:	ffffe097          	auipc	ra,0xffffe
    80002cd4:	710080e7          	jalr	1808(ra) # 800013e0 <mycpu>
    80002cd8:	07852783          	lw	a5,120(a0)
    80002cdc:	02078663          	beqz	a5,80002d08 <push_off+0x5c>
    80002ce0:	ffffe097          	auipc	ra,0xffffe
    80002ce4:	700080e7          	jalr	1792(ra) # 800013e0 <mycpu>
    80002ce8:	07852783          	lw	a5,120(a0)
    80002cec:	01813083          	ld	ra,24(sp)
    80002cf0:	01013403          	ld	s0,16(sp)
    80002cf4:	0017879b          	addiw	a5,a5,1
    80002cf8:	06f52c23          	sw	a5,120(a0)
    80002cfc:	00813483          	ld	s1,8(sp)
    80002d00:	02010113          	addi	sp,sp,32
    80002d04:	00008067          	ret
    80002d08:	0014d493          	srli	s1,s1,0x1
    80002d0c:	ffffe097          	auipc	ra,0xffffe
    80002d10:	6d4080e7          	jalr	1748(ra) # 800013e0 <mycpu>
    80002d14:	0014f493          	andi	s1,s1,1
    80002d18:	06952e23          	sw	s1,124(a0)
    80002d1c:	fc5ff06f          	j	80002ce0 <push_off+0x34>

0000000080002d20 <pop_off>:
    80002d20:	ff010113          	addi	sp,sp,-16
    80002d24:	00813023          	sd	s0,0(sp)
    80002d28:	00113423          	sd	ra,8(sp)
    80002d2c:	01010413          	addi	s0,sp,16
    80002d30:	ffffe097          	auipc	ra,0xffffe
    80002d34:	6b0080e7          	jalr	1712(ra) # 800013e0 <mycpu>
    80002d38:	100027f3          	csrr	a5,sstatus
    80002d3c:	0027f793          	andi	a5,a5,2
    80002d40:	04079663          	bnez	a5,80002d8c <pop_off+0x6c>
    80002d44:	07852783          	lw	a5,120(a0)
    80002d48:	02f05a63          	blez	a5,80002d7c <pop_off+0x5c>
    80002d4c:	fff7871b          	addiw	a4,a5,-1
    80002d50:	06e52c23          	sw	a4,120(a0)
    80002d54:	00071c63          	bnez	a4,80002d6c <pop_off+0x4c>
    80002d58:	07c52783          	lw	a5,124(a0)
    80002d5c:	00078863          	beqz	a5,80002d6c <pop_off+0x4c>
    80002d60:	100027f3          	csrr	a5,sstatus
    80002d64:	0027e793          	ori	a5,a5,2
    80002d68:	10079073          	csrw	sstatus,a5
    80002d6c:	00813083          	ld	ra,8(sp)
    80002d70:	00013403          	ld	s0,0(sp)
    80002d74:	01010113          	addi	sp,sp,16
    80002d78:	00008067          	ret
    80002d7c:	00001517          	auipc	a0,0x1
    80002d80:	4a450513          	addi	a0,a0,1188 # 80004220 <digits+0x48>
    80002d84:	fffff097          	auipc	ra,0xfffff
    80002d88:	018080e7          	jalr	24(ra) # 80001d9c <panic>
    80002d8c:	00001517          	auipc	a0,0x1
    80002d90:	47c50513          	addi	a0,a0,1148 # 80004208 <digits+0x30>
    80002d94:	fffff097          	auipc	ra,0xfffff
    80002d98:	008080e7          	jalr	8(ra) # 80001d9c <panic>

0000000080002d9c <push_on>:
    80002d9c:	fe010113          	addi	sp,sp,-32
    80002da0:	00813823          	sd	s0,16(sp)
    80002da4:	00113c23          	sd	ra,24(sp)
    80002da8:	00913423          	sd	s1,8(sp)
    80002dac:	02010413          	addi	s0,sp,32
    80002db0:	100024f3          	csrr	s1,sstatus
    80002db4:	100027f3          	csrr	a5,sstatus
    80002db8:	0027e793          	ori	a5,a5,2
    80002dbc:	10079073          	csrw	sstatus,a5
    80002dc0:	ffffe097          	auipc	ra,0xffffe
    80002dc4:	620080e7          	jalr	1568(ra) # 800013e0 <mycpu>
    80002dc8:	07852783          	lw	a5,120(a0)
    80002dcc:	02078663          	beqz	a5,80002df8 <push_on+0x5c>
    80002dd0:	ffffe097          	auipc	ra,0xffffe
    80002dd4:	610080e7          	jalr	1552(ra) # 800013e0 <mycpu>
    80002dd8:	07852783          	lw	a5,120(a0)
    80002ddc:	01813083          	ld	ra,24(sp)
    80002de0:	01013403          	ld	s0,16(sp)
    80002de4:	0017879b          	addiw	a5,a5,1
    80002de8:	06f52c23          	sw	a5,120(a0)
    80002dec:	00813483          	ld	s1,8(sp)
    80002df0:	02010113          	addi	sp,sp,32
    80002df4:	00008067          	ret
    80002df8:	0014d493          	srli	s1,s1,0x1
    80002dfc:	ffffe097          	auipc	ra,0xffffe
    80002e00:	5e4080e7          	jalr	1508(ra) # 800013e0 <mycpu>
    80002e04:	0014f493          	andi	s1,s1,1
    80002e08:	06952e23          	sw	s1,124(a0)
    80002e0c:	fc5ff06f          	j	80002dd0 <push_on+0x34>

0000000080002e10 <pop_on>:
    80002e10:	ff010113          	addi	sp,sp,-16
    80002e14:	00813023          	sd	s0,0(sp)
    80002e18:	00113423          	sd	ra,8(sp)
    80002e1c:	01010413          	addi	s0,sp,16
    80002e20:	ffffe097          	auipc	ra,0xffffe
    80002e24:	5c0080e7          	jalr	1472(ra) # 800013e0 <mycpu>
    80002e28:	100027f3          	csrr	a5,sstatus
    80002e2c:	0027f793          	andi	a5,a5,2
    80002e30:	04078463          	beqz	a5,80002e78 <pop_on+0x68>
    80002e34:	07852783          	lw	a5,120(a0)
    80002e38:	02f05863          	blez	a5,80002e68 <pop_on+0x58>
    80002e3c:	fff7879b          	addiw	a5,a5,-1
    80002e40:	06f52c23          	sw	a5,120(a0)
    80002e44:	07853783          	ld	a5,120(a0)
    80002e48:	00079863          	bnez	a5,80002e58 <pop_on+0x48>
    80002e4c:	100027f3          	csrr	a5,sstatus
    80002e50:	ffd7f793          	andi	a5,a5,-3
    80002e54:	10079073          	csrw	sstatus,a5
    80002e58:	00813083          	ld	ra,8(sp)
    80002e5c:	00013403          	ld	s0,0(sp)
    80002e60:	01010113          	addi	sp,sp,16
    80002e64:	00008067          	ret
    80002e68:	00001517          	auipc	a0,0x1
    80002e6c:	3e050513          	addi	a0,a0,992 # 80004248 <digits+0x70>
    80002e70:	fffff097          	auipc	ra,0xfffff
    80002e74:	f2c080e7          	jalr	-212(ra) # 80001d9c <panic>
    80002e78:	00001517          	auipc	a0,0x1
    80002e7c:	3b050513          	addi	a0,a0,944 # 80004228 <digits+0x50>
    80002e80:	fffff097          	auipc	ra,0xfffff
    80002e84:	f1c080e7          	jalr	-228(ra) # 80001d9c <panic>

0000000080002e88 <__memset>:
    80002e88:	ff010113          	addi	sp,sp,-16
    80002e8c:	00813423          	sd	s0,8(sp)
    80002e90:	01010413          	addi	s0,sp,16
    80002e94:	1a060e63          	beqz	a2,80003050 <__memset+0x1c8>
    80002e98:	40a007b3          	neg	a5,a0
    80002e9c:	0077f793          	andi	a5,a5,7
    80002ea0:	00778693          	addi	a3,a5,7
    80002ea4:	00b00813          	li	a6,11
    80002ea8:	0ff5f593          	andi	a1,a1,255
    80002eac:	fff6071b          	addiw	a4,a2,-1
    80002eb0:	1b06e663          	bltu	a3,a6,8000305c <__memset+0x1d4>
    80002eb4:	1cd76463          	bltu	a4,a3,8000307c <__memset+0x1f4>
    80002eb8:	1a078e63          	beqz	a5,80003074 <__memset+0x1ec>
    80002ebc:	00b50023          	sb	a1,0(a0)
    80002ec0:	00100713          	li	a4,1
    80002ec4:	1ae78463          	beq	a5,a4,8000306c <__memset+0x1e4>
    80002ec8:	00b500a3          	sb	a1,1(a0)
    80002ecc:	00200713          	li	a4,2
    80002ed0:	1ae78a63          	beq	a5,a4,80003084 <__memset+0x1fc>
    80002ed4:	00b50123          	sb	a1,2(a0)
    80002ed8:	00300713          	li	a4,3
    80002edc:	18e78463          	beq	a5,a4,80003064 <__memset+0x1dc>
    80002ee0:	00b501a3          	sb	a1,3(a0)
    80002ee4:	00400713          	li	a4,4
    80002ee8:	1ae78263          	beq	a5,a4,8000308c <__memset+0x204>
    80002eec:	00b50223          	sb	a1,4(a0)
    80002ef0:	00500713          	li	a4,5
    80002ef4:	1ae78063          	beq	a5,a4,80003094 <__memset+0x20c>
    80002ef8:	00b502a3          	sb	a1,5(a0)
    80002efc:	00700713          	li	a4,7
    80002f00:	18e79e63          	bne	a5,a4,8000309c <__memset+0x214>
    80002f04:	00b50323          	sb	a1,6(a0)
    80002f08:	00700e93          	li	t4,7
    80002f0c:	00859713          	slli	a4,a1,0x8
    80002f10:	00e5e733          	or	a4,a1,a4
    80002f14:	01059e13          	slli	t3,a1,0x10
    80002f18:	01c76e33          	or	t3,a4,t3
    80002f1c:	01859313          	slli	t1,a1,0x18
    80002f20:	006e6333          	or	t1,t3,t1
    80002f24:	02059893          	slli	a7,a1,0x20
    80002f28:	40f60e3b          	subw	t3,a2,a5
    80002f2c:	011368b3          	or	a7,t1,a7
    80002f30:	02859813          	slli	a6,a1,0x28
    80002f34:	0108e833          	or	a6,a7,a6
    80002f38:	03059693          	slli	a3,a1,0x30
    80002f3c:	003e589b          	srliw	a7,t3,0x3
    80002f40:	00d866b3          	or	a3,a6,a3
    80002f44:	03859713          	slli	a4,a1,0x38
    80002f48:	00389813          	slli	a6,a7,0x3
    80002f4c:	00f507b3          	add	a5,a0,a5
    80002f50:	00e6e733          	or	a4,a3,a4
    80002f54:	000e089b          	sext.w	a7,t3
    80002f58:	00f806b3          	add	a3,a6,a5
    80002f5c:	00e7b023          	sd	a4,0(a5)
    80002f60:	00878793          	addi	a5,a5,8
    80002f64:	fed79ce3          	bne	a5,a3,80002f5c <__memset+0xd4>
    80002f68:	ff8e7793          	andi	a5,t3,-8
    80002f6c:	0007871b          	sext.w	a4,a5
    80002f70:	01d787bb          	addw	a5,a5,t4
    80002f74:	0ce88e63          	beq	a7,a4,80003050 <__memset+0x1c8>
    80002f78:	00f50733          	add	a4,a0,a5
    80002f7c:	00b70023          	sb	a1,0(a4)
    80002f80:	0017871b          	addiw	a4,a5,1
    80002f84:	0cc77663          	bgeu	a4,a2,80003050 <__memset+0x1c8>
    80002f88:	00e50733          	add	a4,a0,a4
    80002f8c:	00b70023          	sb	a1,0(a4)
    80002f90:	0027871b          	addiw	a4,a5,2
    80002f94:	0ac77e63          	bgeu	a4,a2,80003050 <__memset+0x1c8>
    80002f98:	00e50733          	add	a4,a0,a4
    80002f9c:	00b70023          	sb	a1,0(a4)
    80002fa0:	0037871b          	addiw	a4,a5,3
    80002fa4:	0ac77663          	bgeu	a4,a2,80003050 <__memset+0x1c8>
    80002fa8:	00e50733          	add	a4,a0,a4
    80002fac:	00b70023          	sb	a1,0(a4)
    80002fb0:	0047871b          	addiw	a4,a5,4
    80002fb4:	08c77e63          	bgeu	a4,a2,80003050 <__memset+0x1c8>
    80002fb8:	00e50733          	add	a4,a0,a4
    80002fbc:	00b70023          	sb	a1,0(a4)
    80002fc0:	0057871b          	addiw	a4,a5,5
    80002fc4:	08c77663          	bgeu	a4,a2,80003050 <__memset+0x1c8>
    80002fc8:	00e50733          	add	a4,a0,a4
    80002fcc:	00b70023          	sb	a1,0(a4)
    80002fd0:	0067871b          	addiw	a4,a5,6
    80002fd4:	06c77e63          	bgeu	a4,a2,80003050 <__memset+0x1c8>
    80002fd8:	00e50733          	add	a4,a0,a4
    80002fdc:	00b70023          	sb	a1,0(a4)
    80002fe0:	0077871b          	addiw	a4,a5,7
    80002fe4:	06c77663          	bgeu	a4,a2,80003050 <__memset+0x1c8>
    80002fe8:	00e50733          	add	a4,a0,a4
    80002fec:	00b70023          	sb	a1,0(a4)
    80002ff0:	0087871b          	addiw	a4,a5,8
    80002ff4:	04c77e63          	bgeu	a4,a2,80003050 <__memset+0x1c8>
    80002ff8:	00e50733          	add	a4,a0,a4
    80002ffc:	00b70023          	sb	a1,0(a4)
    80003000:	0097871b          	addiw	a4,a5,9
    80003004:	04c77663          	bgeu	a4,a2,80003050 <__memset+0x1c8>
    80003008:	00e50733          	add	a4,a0,a4
    8000300c:	00b70023          	sb	a1,0(a4)
    80003010:	00a7871b          	addiw	a4,a5,10
    80003014:	02c77e63          	bgeu	a4,a2,80003050 <__memset+0x1c8>
    80003018:	00e50733          	add	a4,a0,a4
    8000301c:	00b70023          	sb	a1,0(a4)
    80003020:	00b7871b          	addiw	a4,a5,11
    80003024:	02c77663          	bgeu	a4,a2,80003050 <__memset+0x1c8>
    80003028:	00e50733          	add	a4,a0,a4
    8000302c:	00b70023          	sb	a1,0(a4)
    80003030:	00c7871b          	addiw	a4,a5,12
    80003034:	00c77e63          	bgeu	a4,a2,80003050 <__memset+0x1c8>
    80003038:	00e50733          	add	a4,a0,a4
    8000303c:	00b70023          	sb	a1,0(a4)
    80003040:	00d7879b          	addiw	a5,a5,13
    80003044:	00c7f663          	bgeu	a5,a2,80003050 <__memset+0x1c8>
    80003048:	00f507b3          	add	a5,a0,a5
    8000304c:	00b78023          	sb	a1,0(a5)
    80003050:	00813403          	ld	s0,8(sp)
    80003054:	01010113          	addi	sp,sp,16
    80003058:	00008067          	ret
    8000305c:	00b00693          	li	a3,11
    80003060:	e55ff06f          	j	80002eb4 <__memset+0x2c>
    80003064:	00300e93          	li	t4,3
    80003068:	ea5ff06f          	j	80002f0c <__memset+0x84>
    8000306c:	00100e93          	li	t4,1
    80003070:	e9dff06f          	j	80002f0c <__memset+0x84>
    80003074:	00000e93          	li	t4,0
    80003078:	e95ff06f          	j	80002f0c <__memset+0x84>
    8000307c:	00000793          	li	a5,0
    80003080:	ef9ff06f          	j	80002f78 <__memset+0xf0>
    80003084:	00200e93          	li	t4,2
    80003088:	e85ff06f          	j	80002f0c <__memset+0x84>
    8000308c:	00400e93          	li	t4,4
    80003090:	e7dff06f          	j	80002f0c <__memset+0x84>
    80003094:	00500e93          	li	t4,5
    80003098:	e75ff06f          	j	80002f0c <__memset+0x84>
    8000309c:	00600e93          	li	t4,6
    800030a0:	e6dff06f          	j	80002f0c <__memset+0x84>

00000000800030a4 <__memmove>:
    800030a4:	ff010113          	addi	sp,sp,-16
    800030a8:	00813423          	sd	s0,8(sp)
    800030ac:	01010413          	addi	s0,sp,16
    800030b0:	0e060863          	beqz	a2,800031a0 <__memmove+0xfc>
    800030b4:	fff6069b          	addiw	a3,a2,-1
    800030b8:	0006881b          	sext.w	a6,a3
    800030bc:	0ea5e863          	bltu	a1,a0,800031ac <__memmove+0x108>
    800030c0:	00758713          	addi	a4,a1,7
    800030c4:	00a5e7b3          	or	a5,a1,a0
    800030c8:	40a70733          	sub	a4,a4,a0
    800030cc:	0077f793          	andi	a5,a5,7
    800030d0:	00f73713          	sltiu	a4,a4,15
    800030d4:	00174713          	xori	a4,a4,1
    800030d8:	0017b793          	seqz	a5,a5
    800030dc:	00e7f7b3          	and	a5,a5,a4
    800030e0:	10078863          	beqz	a5,800031f0 <__memmove+0x14c>
    800030e4:	00900793          	li	a5,9
    800030e8:	1107f463          	bgeu	a5,a6,800031f0 <__memmove+0x14c>
    800030ec:	0036581b          	srliw	a6,a2,0x3
    800030f0:	fff8081b          	addiw	a6,a6,-1
    800030f4:	02081813          	slli	a6,a6,0x20
    800030f8:	01d85893          	srli	a7,a6,0x1d
    800030fc:	00858813          	addi	a6,a1,8
    80003100:	00058793          	mv	a5,a1
    80003104:	00050713          	mv	a4,a0
    80003108:	01088833          	add	a6,a7,a6
    8000310c:	0007b883          	ld	a7,0(a5)
    80003110:	00878793          	addi	a5,a5,8
    80003114:	00870713          	addi	a4,a4,8
    80003118:	ff173c23          	sd	a7,-8(a4)
    8000311c:	ff0798e3          	bne	a5,a6,8000310c <__memmove+0x68>
    80003120:	ff867713          	andi	a4,a2,-8
    80003124:	02071793          	slli	a5,a4,0x20
    80003128:	0207d793          	srli	a5,a5,0x20
    8000312c:	00f585b3          	add	a1,a1,a5
    80003130:	40e686bb          	subw	a3,a3,a4
    80003134:	00f507b3          	add	a5,a0,a5
    80003138:	06e60463          	beq	a2,a4,800031a0 <__memmove+0xfc>
    8000313c:	0005c703          	lbu	a4,0(a1)
    80003140:	00e78023          	sb	a4,0(a5)
    80003144:	04068e63          	beqz	a3,800031a0 <__memmove+0xfc>
    80003148:	0015c603          	lbu	a2,1(a1)
    8000314c:	00100713          	li	a4,1
    80003150:	00c780a3          	sb	a2,1(a5)
    80003154:	04e68663          	beq	a3,a4,800031a0 <__memmove+0xfc>
    80003158:	0025c603          	lbu	a2,2(a1)
    8000315c:	00200713          	li	a4,2
    80003160:	00c78123          	sb	a2,2(a5)
    80003164:	02e68e63          	beq	a3,a4,800031a0 <__memmove+0xfc>
    80003168:	0035c603          	lbu	a2,3(a1)
    8000316c:	00300713          	li	a4,3
    80003170:	00c781a3          	sb	a2,3(a5)
    80003174:	02e68663          	beq	a3,a4,800031a0 <__memmove+0xfc>
    80003178:	0045c603          	lbu	a2,4(a1)
    8000317c:	00400713          	li	a4,4
    80003180:	00c78223          	sb	a2,4(a5)
    80003184:	00e68e63          	beq	a3,a4,800031a0 <__memmove+0xfc>
    80003188:	0055c603          	lbu	a2,5(a1)
    8000318c:	00500713          	li	a4,5
    80003190:	00c782a3          	sb	a2,5(a5)
    80003194:	00e68663          	beq	a3,a4,800031a0 <__memmove+0xfc>
    80003198:	0065c703          	lbu	a4,6(a1)
    8000319c:	00e78323          	sb	a4,6(a5)
    800031a0:	00813403          	ld	s0,8(sp)
    800031a4:	01010113          	addi	sp,sp,16
    800031a8:	00008067          	ret
    800031ac:	02061713          	slli	a4,a2,0x20
    800031b0:	02075713          	srli	a4,a4,0x20
    800031b4:	00e587b3          	add	a5,a1,a4
    800031b8:	f0f574e3          	bgeu	a0,a5,800030c0 <__memmove+0x1c>
    800031bc:	02069613          	slli	a2,a3,0x20
    800031c0:	02065613          	srli	a2,a2,0x20
    800031c4:	fff64613          	not	a2,a2
    800031c8:	00e50733          	add	a4,a0,a4
    800031cc:	00c78633          	add	a2,a5,a2
    800031d0:	fff7c683          	lbu	a3,-1(a5)
    800031d4:	fff78793          	addi	a5,a5,-1
    800031d8:	fff70713          	addi	a4,a4,-1
    800031dc:	00d70023          	sb	a3,0(a4)
    800031e0:	fec798e3          	bne	a5,a2,800031d0 <__memmove+0x12c>
    800031e4:	00813403          	ld	s0,8(sp)
    800031e8:	01010113          	addi	sp,sp,16
    800031ec:	00008067          	ret
    800031f0:	02069713          	slli	a4,a3,0x20
    800031f4:	02075713          	srli	a4,a4,0x20
    800031f8:	00170713          	addi	a4,a4,1
    800031fc:	00e50733          	add	a4,a0,a4
    80003200:	00050793          	mv	a5,a0
    80003204:	0005c683          	lbu	a3,0(a1)
    80003208:	00178793          	addi	a5,a5,1
    8000320c:	00158593          	addi	a1,a1,1
    80003210:	fed78fa3          	sb	a3,-1(a5)
    80003214:	fee798e3          	bne	a5,a4,80003204 <__memmove+0x160>
    80003218:	f89ff06f          	j	800031a0 <__memmove+0xfc>
	...
