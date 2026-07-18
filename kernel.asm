
kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00004117          	auipc	sp,0x4
    80000004:	66813103          	ld	sp,1640(sp) # 80004668 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	00001537          	lui	a0,0x1
    8000000c:	f14025f3          	csrr	a1,mhartid
    80000010:	00158593          	addi	a1,a1,1
    80000014:	02b50533          	mul	a0,a0,a1
    80000018:	00a10133          	add	sp,sp,a0
    8000001c:	169010ef          	jal	ra,80001984 <start>

0000000080000020 <spin>:
    80000020:	0000006f          	j	80000020 <spin>
	...

0000000080001000 <trapHandler>:
# s0-s11 ne cuvamo mi: njih po konvenciji cuva sam handleTrap ako ih koristi.

.align 4
.global trapHandler
trapHandler:
    addi sp, sp, -128      # 15 registara x 8B = 120, zaokruzeno na 128 (sp deljiv sa 16)
    80001000:	f8010113          	addi	sp,sp,-128
    sd ra, 0(sp)
    80001004:	00113023          	sd	ra,0(sp)
    sd t0, 8(sp)
    80001008:	00513423          	sd	t0,8(sp)
    sd t1, 16(sp)
    8000100c:	00613823          	sd	t1,16(sp)
    sd t2, 24(sp)
    80001010:	00713c23          	sd	t2,24(sp)
    sd t3, 32(sp)
    80001014:	03c13023          	sd	t3,32(sp)
    sd t4, 40(sp)
    80001018:	03d13423          	sd	t4,40(sp)
    sd t5, 48(sp)
    8000101c:	03e13823          	sd	t5,48(sp)
    sd t6, 56(sp)
    80001020:	03f13c23          	sd	t6,56(sp)
    sd a1, 64(sp)
    80001024:	04b13023          	sd	a1,64(sp)
    sd a2, 72(sp)
    80001028:	04c13423          	sd	a2,72(sp)
    sd a3, 80(sp)
    8000102c:	04d13823          	sd	a3,80(sp)
    sd a4, 88(sp)
    80001030:	04e13c23          	sd	a4,88(sp)
    sd a5, 96(sp)
    80001034:	06f13023          	sd	a5,96(sp)
    sd a6, 104(sp)
    80001038:	07013423          	sd	a6,104(sp)
    sd a7, 112(sp)
    8000103c:	07113823          	sd	a7,112(sp)

    call handleTrap        # a0..a3 = zateceni registri u trenutku trapa
    80001040:	17c000ef          	jal	ra,800011bc <handleTrap>

    ld ra, 0(sp)
    80001044:	00013083          	ld	ra,0(sp)
    ld t0, 8(sp)
    80001048:	00813283          	ld	t0,8(sp)
    ld t1, 16(sp)
    8000104c:	01013303          	ld	t1,16(sp)
    ld t2, 24(sp)
    80001050:	01813383          	ld	t2,24(sp)
    ld t3, 32(sp)
    80001054:	02013e03          	ld	t3,32(sp)
    ld t4, 40(sp)
    80001058:	02813e83          	ld	t4,40(sp)
    ld t5, 48(sp)
    8000105c:	03013f03          	ld	t5,48(sp)
    ld t6, 56(sp)
    80001060:	03813f83          	ld	t6,56(sp)
    ld a1, 64(sp)
    80001064:	04013583          	ld	a1,64(sp)
    ld a2, 72(sp)
    80001068:	04813603          	ld	a2,72(sp)
    ld a3, 80(sp)
    8000106c:	05013683          	ld	a3,80(sp)
    ld a4, 88(sp)
    80001070:	05813703          	ld	a4,88(sp)
    ld a5, 96(sp)
    80001074:	06013783          	ld	a5,96(sp)
    ld a6, 104(sp)
    80001078:	06813803          	ld	a6,104(sp)
    ld a7, 112(sp)
    8000107c:	07013883          	ld	a7,112(sp)
    addi sp, sp, 128
    80001080:	08010113          	addi	sp,sp,128
    sret
    80001084:	10200073          	sret
	...

0000000080001090 <_Z9mem_allocm>:
#include "../h/syscall_c.hpp"
#include "../lib/hw.h"

void* mem_alloc(size_t size) {
    80001090:	ff010113          	addi	sp,sp,-16
    80001094:	00813423          	sd	s0,8(sp)
    80001098:	01010413          	addi	s0,sp,16
    if (size == 0) return nullptr;
    8000109c:	02050063          	beqz	a0,800010bc <_Z9mem_allocm+0x2c>

    // abi poziv 0x01 prima velicinu u blokovima: zaokruzi bajtove navise
    size_t numBlocks = (size + MEM_BLOCK_SIZE - 1) / MEM_BLOCK_SIZE;
    800010a0:	03f50593          	addi	a1,a0,63 # 103f <_entry-0x7fffefc1>

    // spakuj registre pa ecall; povratna vrednost stize nazad u a0
    register uint64 code   asm("a0") = 0x01;
    800010a4:	00100513          	li	a0,1
    register uint64 blocks asm("a1") = numBlocks;
    800010a8:	0065d593          	srli	a1,a1,0x6
    asm volatile("ecall"
        : "=r"(code)
        : "r"(code), "r"(blocks)
        : "memory");
    800010ac:	00000073          	ecall

    return (void*)code;
}
    800010b0:	00813403          	ld	s0,8(sp)
    800010b4:	01010113          	addi	sp,sp,16
    800010b8:	00008067          	ret
    if (size == 0) return nullptr;
    800010bc:	00000513          	li	a0,0
    800010c0:	ff1ff06f          	j	800010b0 <_Z9mem_allocm+0x20>

00000000800010c4 <_Z5kputcc>:
#include "../h/print.hpp"

// posalji jedan znak kontroleru konzole (polling)
void kputc(char c) {
    800010c4:	ff010113          	addi	sp,sp,-16
    800010c8:	00813423          	sd	s0,8(sp)
    800010cc:	01010413          	addi	s0,sp,16
    // CONSOLE_STATUS je adresa (konstanta iz hw.h); da procitamo bajt sa te
    // adrese, kastujemo broj u pokazivac na volatile char pa dereferenciramo.
    // volatile: vrednost menja hardver, kompajler mora stvarno da cita
    // memoriju u svakom prolazu petlje, ne sme da kesira
    while ((*(volatile char*)CONSOLE_STATUS & (1 << 5)) == 0) {
    800010d0:	00003797          	auipc	a5,0x3
    800010d4:	f407b783          	ld	a5,-192(a5) # 80004010 <CONSOLE_STATUS>
    800010d8:	0007c783          	lbu	a5,0(a5)
    800010dc:	0ff7f793          	andi	a5,a5,255
    800010e0:	0207f793          	andi	a5,a5,32
    800010e4:	fe0786e3          	beqz	a5,800010d0 <_Z5kputcc+0xc>
        // bit 5 == 0 znaci "nisam spreman da primim znak za slanje"
    }
    // spreman: upisi bajt u registar za slanje
    *(volatile char*)CONSOLE_TX_DATA = c;
    800010e8:	00003797          	auipc	a5,0x3
    800010ec:	f207b783          	ld	a5,-224(a5) # 80004008 <CONSOLE_TX_DATA>
    800010f0:	00a78023          	sb	a0,0(a5)
}
    800010f4:	00813403          	ld	s0,8(sp)
    800010f8:	01010113          	addi	sp,sp,16
    800010fc:	00008067          	ret

0000000080001100 <_Z5kputsPKc>:

// ispisi ceo string, znak po znak
void kputs(const char* s) {
    80001100:	fe010113          	addi	sp,sp,-32
    80001104:	00113c23          	sd	ra,24(sp)
    80001108:	00813823          	sd	s0,16(sp)
    8000110c:	00913423          	sd	s1,8(sp)
    80001110:	02010413          	addi	s0,sp,32
    80001114:	00050493          	mv	s1,a0
    while (*s) kputc(*s++);
    80001118:	0004c503          	lbu	a0,0(s1)
    8000111c:	00050a63          	beqz	a0,80001130 <_Z5kputsPKc+0x30>
    80001120:	00148493          	addi	s1,s1,1
    80001124:	00000097          	auipc	ra,0x0
    80001128:	fa0080e7          	jalr	-96(ra) # 800010c4 <_Z5kputcc>
    8000112c:	fedff06f          	j	80001118 <_Z5kputsPKc+0x18>
}
    80001130:	01813083          	ld	ra,24(sp)
    80001134:	01013403          	ld	s0,16(sp)
    80001138:	00813483          	ld	s1,8(sp)
    8000113c:	02010113          	addi	sp,sp,32
    80001140:	00008067          	ret

0000000080001144 <_Z7kputhexm>:

// ispisi 64-bitni broj heksadecimalno (fiksno 16 cifara)
void kputhex(uint64 n) {
    80001144:	fe010113          	addi	sp,sp,-32
    80001148:	00113c23          	sd	ra,24(sp)
    8000114c:	00813823          	sd	s0,16(sp)
    80001150:	00913423          	sd	s1,8(sp)
    80001154:	01213023          	sd	s2,0(sp)
    80001158:	02010413          	addi	s0,sp,32
    8000115c:	00050913          	mv	s2,a0
    kputs("0x");
    80001160:	00003517          	auipc	a0,0x3
    80001164:	ec050513          	addi	a0,a0,-320 # 80004020 <CONSOLE_STATUS+0x10>
    80001168:	00000097          	auipc	ra,0x0
    8000116c:	f98080e7          	jalr	-104(ra) # 80001100 <_Z5kputsPKc>
    for (int shift = 60; shift >= 0; shift -= 4) {
    80001170:	03c00493          	li	s1,60
    80001174:	0140006f          	j	80001188 <_Z7kputhexm+0x44>
        uint64 digit = (n >> shift) & 0xF;
        char c;
        if (digit < 10) {
            c = '0' + digit;
        } else {
            c = 'a' + (digit - 10);
    80001178:	05750513          	addi	a0,a0,87
        }
        kputc(c);
    8000117c:	00000097          	auipc	ra,0x0
    80001180:	f48080e7          	jalr	-184(ra) # 800010c4 <_Z5kputcc>
    for (int shift = 60; shift >= 0; shift -= 4) {
    80001184:	ffc4849b          	addiw	s1,s1,-4
    80001188:	0004ce63          	bltz	s1,800011a4 <_Z7kputhexm+0x60>
        uint64 digit = (n >> shift) & 0xF;
    8000118c:	00995533          	srl	a0,s2,s1
    80001190:	00f57513          	andi	a0,a0,15
        if (digit < 10) {
    80001194:	00900793          	li	a5,9
    80001198:	fea7e0e3          	bltu	a5,a0,80001178 <_Z7kputhexm+0x34>
            c = '0' + digit;
    8000119c:	03050513          	addi	a0,a0,48
    800011a0:	fddff06f          	j	8000117c <_Z7kputhexm+0x38>
    }
}
    800011a4:	01813083          	ld	ra,24(sp)
    800011a8:	01013403          	ld	s0,16(sp)
    800011ac:	00813483          	ld	s1,8(sp)
    800011b0:	00013903          	ld	s2,0(sp)
    800011b4:	02010113          	addi	sp,sp,32
    800011b8:	00008067          	ret

00000000800011bc <handleTrap>:
#include "../h/memoryAllocator.hpp"

// zajednicki c deo prekidne rutine: cita scause i grana se na obradu.
// a0..a3 parametri se poklapaju sa registrima a0..a3 u trenutku trapa
// (trap.S ih ne dira pre call-a), pa abi argumente citamo direktno.
extern "C" uint64 handleTrap(uint64 a0, uint64 a1, uint64 a2, uint64 a3) {
    800011bc:	fd010113          	addi	sp,sp,-48
    800011c0:	02113423          	sd	ra,40(sp)
    800011c4:	02813023          	sd	s0,32(sp)
    800011c8:	00913c23          	sd	s1,24(sp)
    800011cc:	01213823          	sd	s2,16(sp)
    800011d0:	01313423          	sd	s3,8(sp)
    800011d4:	01413023          	sd	s4,0(sp)
    800011d8:	03010413          	addi	s0,sp,48
    800011dc:	00050993          	mv	s3,a0
    800011e0:	00058a13          	mv	s4,a1
    uint64 cause;
    asm volatile("csrr %0, scause" : "=r"(cause));
    800011e4:	14202973          	csrr	s2,scause
    kputs("c="); kputhex(cause); kputs(" ");   // debug: ceo scause, top bit = prekid/izuzetak
    800011e8:	00003517          	auipc	a0,0x3
    800011ec:	e4050513          	addi	a0,a0,-448 # 80004028 <CONSOLE_STATUS+0x18>
    800011f0:	00000097          	auipc	ra,0x0
    800011f4:	f10080e7          	jalr	-240(ra) # 80001100 <_Z5kputsPKc>
    800011f8:	00090513          	mv	a0,s2
    800011fc:	00000097          	auipc	ra,0x0
    80001200:	f48080e7          	jalr	-184(ra) # 80001144 <_Z7kputhexm>
    80001204:	00003517          	auipc	a0,0x3
    80001208:	f4c50513          	addi	a0,a0,-180 # 80004150 <CONSOLE_STATUS+0x140>
    8000120c:	00000097          	auipc	ra,0x0
    80001210:	ef4080e7          	jalr	-268(ra) # 80001100 <_Z5kputsPKc>

    uint64 topBit = cause >> 63;
    80001214:	03f95493          	srli	s1,s2,0x3f
    uint64 code   = cause & 0xff;
    80001218:	0ff97793          	andi	a5,s2,255

    if (topBit == 1) {
    8000121c:	08049c63          	bnez	s1,800012b4 <handleTrap+0xf8>
            plic_complete(irq);
        }
        // sepc se ne dira: prekinuta instrukcija mora da se ponovi
        return a0;
    }
    else if (topBit == 0 && (code == 8 || code == 9)) {
    80001220:	00049863          	bnez	s1,80001230 <handleTrap+0x74>
    80001224:	ff878793          	addi	a5,a5,-8
    80001228:	00100713          	li	a4,1
    8000122c:	0cf77263          	bgeu	a4,a5,800012f0 <handleTrap+0x134>
    }

    // nepoznat uzrok (izuzetak koji ne umemo da obradimo): panika.
    // ne vracamo se - sepc bi pokazivao na istu instrukciju i vrteli bismo se.
    uint64 sepc;
    asm volatile("csrr %0, sepc" : "=r"(sepc));
    80001230:	141024f3          	csrr	s1,sepc
    kputs("PANIC: cause="); kputhex(cause);
    80001234:	00003517          	auipc	a0,0x3
    80001238:	e5c50513          	addi	a0,a0,-420 # 80004090 <CONSOLE_STATUS+0x80>
    8000123c:	00000097          	auipc	ra,0x0
    80001240:	ec4080e7          	jalr	-316(ra) # 80001100 <_Z5kputsPKc>
    80001244:	00090513          	mv	a0,s2
    80001248:	00000097          	auipc	ra,0x0
    8000124c:	efc080e7          	jalr	-260(ra) # 80001144 <_Z7kputhexm>
    kputs(" sepc=");        kputhex(sepc);
    80001250:	00003517          	auipc	a0,0x3
    80001254:	e5050513          	addi	a0,a0,-432 # 800040a0 <CONSOLE_STATUS+0x90>
    80001258:	00000097          	auipc	ra,0x0
    8000125c:	ea8080e7          	jalr	-344(ra) # 80001100 <_Z5kputsPKc>
    80001260:	00048513          	mv	a0,s1
    80001264:	00000097          	auipc	ra,0x0
    80001268:	ee0080e7          	jalr	-288(ra) # 80001144 <_Z7kputhexm>
    kputs("\n");
    8000126c:	00003517          	auipc	a0,0x3
    80001270:	e4c50513          	addi	a0,a0,-436 # 800040b8 <CONSOLE_STATUS+0xa8>
    80001274:	00000097          	auipc	ra,0x0
    80001278:	e8c080e7          	jalr	-372(ra) # 80001100 <_Z5kputsPKc>
    *(volatile int*)0x100000 = 0x5555;   // halt emulatora
    8000127c:	00100737          	lui	a4,0x100
    80001280:	000057b7          	lui	a5,0x5
    80001284:	5557879b          	addiw	a5,a5,1365
    80001288:	00f72023          	sw	a5,0(a4) # 100000 <_entry-0x7ff00000>
    return a0;
    8000128c:	00098493          	mv	s1,s3
}
    80001290:	00048513          	mv	a0,s1
    80001294:	02813083          	ld	ra,40(sp)
    80001298:	02013403          	ld	s0,32(sp)
    8000129c:	01813483          	ld	s1,24(sp)
    800012a0:	01013903          	ld	s2,16(sp)
    800012a4:	00813983          	ld	s3,8(sp)
    800012a8:	00013a03          	ld	s4,0(sp)
    800012ac:	03010113          	addi	sp,sp,48
    800012b0:	00008067          	ret
        if (code == 1) {
    800012b4:	00100713          	li	a4,1
    800012b8:	00e78a63          	beq	a5,a4,800012cc <handleTrap+0x110>
        } else if (code == 9) {
    800012bc:	00900713          	li	a4,9
    800012c0:	00e78e63          	beq	a5,a4,800012dc <handleTrap+0x120>
        return a0;
    800012c4:	00098493          	mv	s1,s3
    800012c8:	fc9ff06f          	j	80001290 <handleTrap+0xd4>
            asm volatile("csrr %0, sip" : "=r"(sip));
    800012cc:	144027f3          	csrr	a5,sip
            sip &= ~(1UL << 1);
    800012d0:	ffd7f793          	andi	a5,a5,-3
            asm volatile("csrw sip, %0" : : "r"(sip));
    800012d4:	14479073          	csrw	sip,a5
    800012d8:	fedff06f          	j	800012c4 <handleTrap+0x108>
            int irq = plic_claim();
    800012dc:	00001097          	auipc	ra,0x1
    800012e0:	f08080e7          	jalr	-248(ra) # 800021e4 <plic_claim>
            plic_complete(irq);
    800012e4:	00001097          	auipc	ra,0x1
    800012e8:	f38080e7          	jalr	-200(ra) # 8000221c <plic_complete>
    800012ec:	fd9ff06f          	j	800012c4 <handleTrap+0x108>
        kputs("   [ECALL] a0="); kputhex(a0); kputs("\n");
    800012f0:	00003517          	auipc	a0,0x3
    800012f4:	d4050513          	addi	a0,a0,-704 # 80004030 <CONSOLE_STATUS+0x20>
    800012f8:	00000097          	auipc	ra,0x0
    800012fc:	e08080e7          	jalr	-504(ra) # 80001100 <_Z5kputsPKc>
    80001300:	00098513          	mv	a0,s3
    80001304:	00000097          	auipc	ra,0x0
    80001308:	e40080e7          	jalr	-448(ra) # 80001144 <_Z7kputhexm>
    8000130c:	00003517          	auipc	a0,0x3
    80001310:	dac50513          	addi	a0,a0,-596 # 800040b8 <CONSOLE_STATUS+0xa8>
    80001314:	00000097          	auipc	ra,0x0
    80001318:	dec080e7          	jalr	-532(ra) # 80001100 <_Z5kputsPKc>
        switch (a0) {
    8000131c:	00100793          	li	a5,1
    80001320:	02f98e63          	beq	s3,a5,8000135c <handleTrap+0x1a0>
    80001324:	00200793          	li	a5,2
    80001328:	0af98063          	beq	s3,a5,800013c8 <handleTrap+0x20c>
        kputs("   pre sepc\n");
    8000132c:	00003517          	auipc	a0,0x3
    80001330:	d4450513          	addi	a0,a0,-700 # 80004070 <CONSOLE_STATUS+0x60>
    80001334:	00000097          	auipc	ra,0x0
    80001338:	dcc080e7          	jalr	-564(ra) # 80001100 <_Z5kputsPKc>
        asm volatile("csrr %0, sepc" : "=r"(sepc));
    8000133c:	141027f3          	csrr	a5,sepc
        sepc += 4;
    80001340:	00478793          	addi	a5,a5,4 # 5004 <_entry-0x7fffaffc>
        asm volatile("csrw sepc, %0" : : "r"(sepc));
    80001344:	14179073          	csrw	sepc,a5
        kputs("   pre return\n");
    80001348:	00003517          	auipc	a0,0x3
    8000134c:	d3850513          	addi	a0,a0,-712 # 80004080 <CONSOLE_STATUS+0x70>
    80001350:	00000097          	auipc	ra,0x0
    80001354:	db0080e7          	jalr	-592(ra) # 80001100 <_Z5kputsPKc>
        return ret;
    80001358:	f39ff06f          	j	80001290 <handleTrap+0xd4>
                kputs("   pre alloc, a1="); kputhex(a1); kputs("\n");
    8000135c:	00003517          	auipc	a0,0x3
    80001360:	ce450513          	addi	a0,a0,-796 # 80004040 <CONSOLE_STATUS+0x30>
    80001364:	00000097          	auipc	ra,0x0
    80001368:	d9c080e7          	jalr	-612(ra) # 80001100 <_Z5kputsPKc>
    8000136c:	000a0513          	mv	a0,s4
    80001370:	00000097          	auipc	ra,0x0
    80001374:	dd4080e7          	jalr	-556(ra) # 80001144 <_Z7kputhexm>
    80001378:	00003517          	auipc	a0,0x3
    8000137c:	d4050513          	addi	a0,a0,-704 # 800040b8 <CONSOLE_STATUS+0xa8>
    80001380:	00000097          	auipc	ra,0x0
    80001384:	d80080e7          	jalr	-640(ra) # 80001100 <_Z5kputsPKc>
                ret = (uint64)MemoryAllocator::alloc(a1 * MEM_BLOCK_SIZE);
    80001388:	006a1513          	slli	a0,s4,0x6
    8000138c:	00000097          	auipc	ra,0x0
    80001390:	2c8080e7          	jalr	712(ra) # 80001654 <_ZN15MemoryAllocator5allocEm>
    80001394:	00050493          	mv	s1,a0
                kputs("   posle alloc, ret="); kputhex(ret); kputs("\n");
    80001398:	00003517          	auipc	a0,0x3
    8000139c:	cc050513          	addi	a0,a0,-832 # 80004058 <CONSOLE_STATUS+0x48>
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	d60080e7          	jalr	-672(ra) # 80001100 <_Z5kputsPKc>
    800013a8:	00048513          	mv	a0,s1
    800013ac:	00000097          	auipc	ra,0x0
    800013b0:	d98080e7          	jalr	-616(ra) # 80001144 <_Z7kputhexm>
    800013b4:	00003517          	auipc	a0,0x3
    800013b8:	d0450513          	addi	a0,a0,-764 # 800040b8 <CONSOLE_STATUS+0xa8>
    800013bc:	00000097          	auipc	ra,0x0
    800013c0:	d44080e7          	jalr	-700(ra) # 80001100 <_Z5kputsPKc>
                break;
    800013c4:	f69ff06f          	j	8000132c <handleTrap+0x170>
                ret = (uint64)MemoryAllocator::free((void*)a1);
    800013c8:	000a0513          	mv	a0,s4
    800013cc:	00000097          	auipc	ra,0x0
    800013d0:	3c4080e7          	jalr	964(ra) # 80001790 <_ZN15MemoryAllocator4freeEPv>
    800013d4:	00050493          	mv	s1,a0
                break;
    800013d8:	f55ff06f          	j	8000132c <handleTrap+0x170>

00000000800013dc <_Z8userMainv>:
// privremeni test program; kad se uveze pravi app.lib sa testovima,
// ovaj fajl se uklanja (duplikat simbola userMain)
#include "../h/syscall_c.hpp"
#include "../h/print.hpp"

void userMain() {
    800013dc:	fe010113          	addi	sp,sp,-32
    800013e0:	00113c23          	sd	ra,24(sp)
    800013e4:	00813823          	sd	s0,16(sp)
    800013e8:	00913423          	sd	s1,8(sp)
    800013ec:	02010413          	addi	s0,sp,32
    kputs("   pre mem_alloc\n");
    800013f0:	00003517          	auipc	a0,0x3
    800013f4:	cb850513          	addi	a0,a0,-840 # 800040a8 <CONSOLE_STATUS+0x98>
    800013f8:	00000097          	auipc	ra,0x0
    800013fc:	d08080e7          	jalr	-760(ra) # 80001100 <_Z5kputsPKc>
    void* p = mem_alloc(100);
    80001400:	06400513          	li	a0,100
    80001404:	00000097          	auipc	ra,0x0
    80001408:	c8c080e7          	jalr	-884(ra) # 80001090 <_Z9mem_allocm>
    8000140c:	00050493          	mv	s1,a0
    kputs("   posle mem_alloc\n");
    80001410:	00003517          	auipc	a0,0x3
    80001414:	cb050513          	addi	a0,a0,-848 # 800040c0 <CONSOLE_STATUS+0xb0>
    80001418:	00000097          	auipc	ra,0x0
    8000141c:	ce8080e7          	jalr	-792(ra) # 80001100 <_Z5kputsPKc>
    kputs("   p (preko ecall) = "); kputhex((uint64)p); kputs("\n");
    80001420:	00003517          	auipc	a0,0x3
    80001424:	cb850513          	addi	a0,a0,-840 # 800040d8 <CONSOLE_STATUS+0xc8>
    80001428:	00000097          	auipc	ra,0x0
    8000142c:	cd8080e7          	jalr	-808(ra) # 80001100 <_Z5kputsPKc>
    80001430:	00048513          	mv	a0,s1
    80001434:	00000097          	auipc	ra,0x0
    80001438:	d10080e7          	jalr	-752(ra) # 80001144 <_Z7kputhexm>
    8000143c:	00003517          	auipc	a0,0x3
    80001440:	c7c50513          	addi	a0,a0,-900 # 800040b8 <CONSOLE_STATUS+0xa8>
    80001444:	00000097          	auipc	ra,0x0
    80001448:	cbc080e7          	jalr	-836(ra) # 80001100 <_Z5kputsPKc>
}
    8000144c:	01813083          	ld	ra,24(sp)
    80001450:	01013403          	ld	s0,16(sp)
    80001454:	00813483          	ld	s1,8(sp)
    80001458:	02010113          	addi	sp,sp,32
    8000145c:	00008067          	ret

0000000080001460 <_ZN3TCBnwEm>:
#include "../h/memoryAllocator.hpp"

TCB* TCB::running = nullptr;

// new/delete za tcb: direktno na alokator jezgra (bez ecall-a)
void* TCB::operator new(size_t size) {
    80001460:	ff010113          	addi	sp,sp,-16
    80001464:	00113423          	sd	ra,8(sp)
    80001468:	00813023          	sd	s0,0(sp)
    8000146c:	01010413          	addi	s0,sp,16
    return MemoryAllocator::alloc(size);
    80001470:	00000097          	auipc	ra,0x0
    80001474:	1e4080e7          	jalr	484(ra) # 80001654 <_ZN15MemoryAllocator5allocEm>
}
    80001478:	00813083          	ld	ra,8(sp)
    8000147c:	00013403          	ld	s0,0(sp)
    80001480:	01010113          	addi	sp,sp,16
    80001484:	00008067          	ret

0000000080001488 <_ZN3TCBdlEPv>:
void TCB::operator delete(void* ptr) {
    80001488:	ff010113          	addi	sp,sp,-16
    8000148c:	00113423          	sd	ra,8(sp)
    80001490:	00813023          	sd	s0,0(sp)
    80001494:	01010413          	addi	s0,sp,16
    MemoryAllocator::free(ptr);
    80001498:	00000097          	auipc	ra,0x0
    8000149c:	2f8080e7          	jalr	760(ra) # 80001790 <_ZN15MemoryAllocator4freeEPv>
}
    800014a0:	00813083          	ld	ra,8(sp)
    800014a4:	00013403          	ld	s0,0(sp)
    800014a8:	01010113          	addi	sp,sp,16
    800014ac:	00008067          	ret

00000000800014b0 <_ZN3TCBC1EPFvPvES0_Pm>:

TCB::TCB(Body body, void* arg, uint64* stack)
    800014b0:	ff010113          	addi	sp,sp,-16
    800014b4:	00813423          	sd	s0,8(sp)
    800014b8:	01010413          	addi	s0,sp,16
    : body(body), arg(arg), stack(stack),
      context({0, 0}),   // pravi pocetni kontekst pravimo u sledecoj lekciji
      finished(false), next(nullptr)
    800014bc:	00b53023          	sd	a1,0(a0)
    800014c0:	00c53423          	sd	a2,8(a0)
    800014c4:	00d53823          	sd	a3,16(a0)
    800014c8:	00053c23          	sd	zero,24(a0)
    800014cc:	02053023          	sd	zero,32(a0)
    800014d0:	02050423          	sb	zero,40(a0)
    800014d4:	02053823          	sd	zero,48(a0)
{}
    800014d8:	00813403          	ld	s0,8(sp)
    800014dc:	01010113          	addi	sp,sp,16
    800014e0:	00008067          	ret

00000000800014e4 <_ZN3TCB12createThreadEPFvPvES0_>:

TCB* TCB::createThread(Body body, void* arg) {
    800014e4:	fd010113          	addi	sp,sp,-48
    800014e8:	02113423          	sd	ra,40(sp)
    800014ec:	02813023          	sd	s0,32(sp)
    800014f0:	00913c23          	sd	s1,24(sp)
    800014f4:	01213823          	sd	s2,16(sp)
    800014f8:	01313423          	sd	s3,8(sp)
    800014fc:	01413023          	sd	s4,0(sp)
    80001500:	03010413          	addi	s0,sp,48
    80001504:	00050993          	mv	s3,a0
    80001508:	00058a13          	mv	s4,a1
    // stek niti: DEFAULT_STACK_SIZE bajtova iz hw.h
    uint64* stack = (uint64*)MemoryAllocator::alloc(DEFAULT_STACK_SIZE);
    8000150c:	00001537          	lui	a0,0x1
    80001510:	00000097          	auipc	ra,0x0
    80001514:	144080e7          	jalr	324(ra) # 80001654 <_ZN15MemoryAllocator5allocEm>
    80001518:	00050493          	mv	s1,a0
    if (!stack) return nullptr;
    8000151c:	06050063          	beqz	a0,8000157c <_ZN3TCB12createThreadEPFvPvES0_+0x98>

    TCB* tcb = new TCB(body, arg, stack);
    80001520:	03800513          	li	a0,56
    80001524:	00000097          	auipc	ra,0x0
    80001528:	f3c080e7          	jalr	-196(ra) # 80001460 <_ZN3TCBnwEm>
    8000152c:	00050913          	mv	s2,a0
    80001530:	00048693          	mv	a3,s1
    80001534:	000a0613          	mv	a2,s4
    80001538:	00098593          	mv	a1,s3
    8000153c:	00000097          	auipc	ra,0x0
    80001540:	f74080e7          	jalr	-140(ra) # 800014b0 <_ZN3TCBC1EPFvPvES0_Pm>
    if (!tcb) { MemoryAllocator::free(stack); return nullptr; }
    80001544:	02090463          	beqz	s2,8000156c <_ZN3TCB12createThreadEPFvPvES0_+0x88>

    // todo (lekcija 2): postaviti context.ra i context.sp tako da prvo
    // "odmrzavanje" ubaci nit u njeno telo
    return tcb;
}
    80001548:	00090513          	mv	a0,s2
    8000154c:	02813083          	ld	ra,40(sp)
    80001550:	02013403          	ld	s0,32(sp)
    80001554:	01813483          	ld	s1,24(sp)
    80001558:	01013903          	ld	s2,16(sp)
    8000155c:	00813983          	ld	s3,8(sp)
    80001560:	00013a03          	ld	s4,0(sp)
    80001564:	03010113          	addi	sp,sp,48
    80001568:	00008067          	ret
    if (!tcb) { MemoryAllocator::free(stack); return nullptr; }
    8000156c:	00048513          	mv	a0,s1
    80001570:	00000097          	auipc	ra,0x0
    80001574:	220080e7          	jalr	544(ra) # 80001790 <_ZN15MemoryAllocator4freeEPv>
    80001578:	fd1ff06f          	j	80001548 <_ZN3TCB12createThreadEPFvPvES0_+0x64>
    if (!stack) return nullptr;
    8000157c:	00050913          	mv	s2,a0
    80001580:	fc9ff06f          	j	80001548 <_ZN3TCB12createThreadEPFvPvES0_+0x64>

0000000080001584 <_ZN9Scheduler3putEP3TCB>:

TCB* Scheduler::head = nullptr;
TCB* Scheduler::tail = nullptr;

// stani na kraj reda
void Scheduler::put(TCB* thread) {
    80001584:	ff010113          	addi	sp,sp,-16
    80001588:	00813423          	sd	s0,8(sp)
    8000158c:	01010413          	addi	s0,sp,16
    thread->next = nullptr;
    80001590:	02053823          	sd	zero,48(a0) # 1030 <_entry-0x7fffefd0>
    if (tail) {
    80001594:	00003797          	auipc	a5,0x3
    80001598:	0f47b783          	ld	a5,244(a5) # 80004688 <_ZN9Scheduler4tailE>
    8000159c:	00078e63          	beqz	a5,800015b8 <_ZN9Scheduler3putEP3TCB+0x34>
        tail->next = thread;   // dosadasnji poslednji pokaze na novog
    800015a0:	02a7b823          	sd	a0,48(a5)
    } else {
        head = thread;         // red je bio prazan: novi je i prvi
    }
    tail = thread;             // novi je u svakom slucaju poslednji
    800015a4:	00003797          	auipc	a5,0x3
    800015a8:	0ea7b223          	sd	a0,228(a5) # 80004688 <_ZN9Scheduler4tailE>
}
    800015ac:	00813403          	ld	s0,8(sp)
    800015b0:	01010113          	addi	sp,sp,16
    800015b4:	00008067          	ret
        head = thread;         // red je bio prazan: novi je i prvi
    800015b8:	00003797          	auipc	a5,0x3
    800015bc:	0ca7bc23          	sd	a0,216(a5) # 80004690 <_ZN9Scheduler4headE>
    800015c0:	fe5ff06f          	j	800015a4 <_ZN9Scheduler3putEP3TCB+0x20>

00000000800015c4 <_ZN9Scheduler3getEv>:

// skini nit sa cela reda
TCB* Scheduler::get() {
    800015c4:	ff010113          	addi	sp,sp,-16
    800015c8:	00813423          	sd	s0,8(sp)
    800015cc:	01010413          	addi	s0,sp,16
    TCB* thread = head;
    800015d0:	00003517          	auipc	a0,0x3
    800015d4:	0c053503          	ld	a0,192(a0) # 80004690 <_ZN9Scheduler4headE>
    if (!thread) return nullptr;   // prazan red
    800015d8:	00050c63          	beqz	a0,800015f0 <_ZN9Scheduler3getEv+0x2c>
    head = head->next;
    800015dc:	03053783          	ld	a5,48(a0)
    800015e0:	00003717          	auipc	a4,0x3
    800015e4:	0af73823          	sd	a5,176(a4) # 80004690 <_ZN9Scheduler4headE>
    if (!head) tail = nullptr;     // skinuli smo i poslednjeg
    800015e8:	00078a63          	beqz	a5,800015fc <_ZN9Scheduler3getEv+0x38>
    thread->next = nullptr;
    800015ec:	02053823          	sd	zero,48(a0)
    return thread;
}
    800015f0:	00813403          	ld	s0,8(sp)
    800015f4:	01010113          	addi	sp,sp,16
    800015f8:	00008067          	ret
    if (!head) tail = nullptr;     // skinuli smo i poslednjeg
    800015fc:	00003797          	auipc	a5,0x3
    80001600:	0807b623          	sd	zero,140(a5) # 80004688 <_ZN9Scheduler4tailE>
    80001604:	fe9ff06f          	j	800015ec <_ZN9Scheduler3getEv+0x28>

0000000080001608 <_ZN15MemoryAllocator4initEv>:
#include "../h/print.hpp"

MemoryAllocator::FreeBlock* MemoryAllocator::freeListHead = nullptr;

// ceo heap = jedan slobodan blok
void MemoryAllocator::init() {
    80001608:	ff010113          	addi	sp,sp,-16
    8000160c:	00813423          	sd	s0,8(sp)
    80001610:	01010413          	addi	s0,sp,16
    freeListHead = (FreeBlock*)HEAP_START_ADDR;
    80001614:	00003797          	auipc	a5,0x3
    80001618:	04478793          	addi	a5,a5,68 # 80004658 <HEAP_START_ADDR>
    8000161c:	0007b683          	ld	a3,0(a5)
    80001620:	00003717          	auipc	a4,0x3
    80001624:	07870713          	addi	a4,a4,120 # 80004698 <_ZN15MemoryAllocator12freeListHeadE>
    80001628:	00d73023          	sd	a3,0(a4)
    freeListHead->next = nullptr;
    8000162c:	0006b023          	sd	zero,0(a3)
    freeListHead->size = (char*)HEAP_END_ADDR - (char*)HEAP_START_ADDR;
    80001630:	0007b683          	ld	a3,0(a5)
    80001634:	00073703          	ld	a4,0(a4)
    80001638:	00003797          	auipc	a5,0x3
    8000163c:	0187b783          	ld	a5,24(a5) # 80004650 <HEAP_END_ADDR>
    80001640:	40d787b3          	sub	a5,a5,a3
    80001644:	00f73423          	sd	a5,8(a4)
}
    80001648:	00813403          	ld	s0,8(sp)
    8000164c:	01010113          	addi	sp,sp,16
    80001650:	00008067          	ret

0000000080001654 <_ZN15MemoryAllocator5allocEm>:

void* MemoryAllocator::alloc(size_t size){
    80001654:	ff010113          	addi	sp,sp,-16
    80001658:	00813423          	sd	s0,8(sp)
    8000165c:	01010413          	addi	s0,sp,16
    if (size == 0) {
    80001660:	08050a63          	beqz	a0,800016f4 <_ZN15MemoryAllocator5allocEm+0xa0>
        return nullptr;
    }
    // zaokruzivanje navise: ((n + B - 1) / B) * B; heder ukljucen u racun
    // da payload uvek bude >= size
    size_t n = size + sizeof(FreeBlock);
    size_t roundedSize = ((n + MEM_BLOCK_SIZE - 1) / MEM_BLOCK_SIZE) * MEM_BLOCK_SIZE;
    80001664:	04f50513          	addi	a0,a0,79
    80001668:	fc057713          	andi	a4,a0,-64

    // first-fit kroz slobodnu listu
    FreeBlock* curr = freeListHead;
    8000166c:	00003517          	auipc	a0,0x3
    80001670:	02c53503          	ld	a0,44(a0) # 80004698 <_ZN15MemoryAllocator12freeListHeadE>
    FreeBlock* prev = nullptr;
    80001674:	00000693          	li	a3,0
    while(curr != nullptr){
    80001678:	04050263          	beqz	a0,800016bc <_ZN15MemoryAllocator5allocEm+0x68>
        if(curr->size >= roundedSize){
    8000167c:	00853783          	ld	a5,8(a0)
    80001680:	00e7f863          	bgeu	a5,a4,80001690 <_ZN15MemoryAllocator5allocEm+0x3c>
                    freeListHead = curr->next;
                }
            }
            return (char*)curr + sizeof(FreeBlock);
        }
        prev = curr;
    80001684:	00050693          	mv	a3,a0
        curr = curr->next;
    80001688:	00053503          	ld	a0,0(a0)
    while(curr != nullptr){
    8000168c:	fedff06f          	j	80001678 <_ZN15MemoryAllocator5allocEm+0x24>
            size_t remainder = curr->size - roundedSize;
    80001690:	40e787b3          	sub	a5,a5,a4
            if (remainder >= MEM_BLOCK_SIZE) {
    80001694:	03f00613          	li	a2,63
    80001698:	02f67e63          	bgeu	a2,a5,800016d4 <_ZN15MemoryAllocator5allocEm+0x80>
                FreeBlock* newBlock = (FreeBlock*)((char*)curr + roundedSize);
    8000169c:	00e50633          	add	a2,a0,a4
                newBlock->size = remainder;
    800016a0:	00f63423          	sd	a5,8(a2)
                newBlock->next = curr->next;
    800016a4:	00053783          	ld	a5,0(a0)
    800016a8:	00f63023          	sd	a5,0(a2)
                if (prev != nullptr) {
    800016ac:	00068e63          	beqz	a3,800016c8 <_ZN15MemoryAllocator5allocEm+0x74>
                    prev->next = newBlock;
    800016b0:	00c6b023          	sd	a2,0(a3)
                curr->size = roundedSize;
    800016b4:	00e53423          	sd	a4,8(a0)
            return (char*)curr + sizeof(FreeBlock);
    800016b8:	01050513          	addi	a0,a0,16
    }
    return nullptr;   // nema dovoljno velikog bloka
}
    800016bc:	00813403          	ld	s0,8(sp)
    800016c0:	01010113          	addi	sp,sp,16
    800016c4:	00008067          	ret
                    freeListHead = newBlock;
    800016c8:	00003797          	auipc	a5,0x3
    800016cc:	fcc7b823          	sd	a2,-48(a5) # 80004698 <_ZN15MemoryAllocator12freeListHeadE>
    800016d0:	fe5ff06f          	j	800016b4 <_ZN15MemoryAllocator5allocEm+0x60>
                if (prev != nullptr) {
    800016d4:	00068863          	beqz	a3,800016e4 <_ZN15MemoryAllocator5allocEm+0x90>
                    prev->next = curr->next;
    800016d8:	00053783          	ld	a5,0(a0)
    800016dc:	00f6b023          	sd	a5,0(a3)
    800016e0:	fd9ff06f          	j	800016b8 <_ZN15MemoryAllocator5allocEm+0x64>
                    freeListHead = curr->next;
    800016e4:	00053783          	ld	a5,0(a0)
    800016e8:	00003717          	auipc	a4,0x3
    800016ec:	faf73823          	sd	a5,-80(a4) # 80004698 <_ZN15MemoryAllocator12freeListHeadE>
    800016f0:	fc9ff06f          	j	800016b8 <_ZN15MemoryAllocator5allocEm+0x64>
        return nullptr;
    800016f4:	00000513          	li	a0,0
    800016f8:	fc5ff06f          	j	800016bc <_ZN15MemoryAllocator5allocEm+0x68>

00000000800016fc <_ZN15MemoryAllocator13printFreeListEv>:

// debug ispis slobodne liste (nije deo resenja koje se predaje)
void MemoryAllocator::printFreeList() {
    800016fc:	fe010113          	addi	sp,sp,-32
    80001700:	00113c23          	sd	ra,24(sp)
    80001704:	00813823          	sd	s0,16(sp)
    80001708:	00913423          	sd	s1,8(sp)
    8000170c:	02010413          	addi	s0,sp,32
    FreeBlock* curr = freeListHead;
    80001710:	00003497          	auipc	s1,0x3
    80001714:	f884b483          	ld	s1,-120(s1) # 80004698 <_ZN15MemoryAllocator12freeListHeadE>
    kputs("free list:\n");
    80001718:	00003517          	auipc	a0,0x3
    8000171c:	9d850513          	addi	a0,a0,-1576 # 800040f0 <CONSOLE_STATUS+0xe0>
    80001720:	00000097          	auipc	ra,0x0
    80001724:	9e0080e7          	jalr	-1568(ra) # 80001100 <_Z5kputsPKc>
    while (curr != nullptr) {
    80001728:	04048a63          	beqz	s1,8000177c <_ZN15MemoryAllocator13printFreeListEv+0x80>
        kputs("  blok na ");
    8000172c:	00003517          	auipc	a0,0x3
    80001730:	9d450513          	addi	a0,a0,-1580 # 80004100 <CONSOLE_STATUS+0xf0>
    80001734:	00000097          	auipc	ra,0x0
    80001738:	9cc080e7          	jalr	-1588(ra) # 80001100 <_Z5kputsPKc>
        kputhex((uint64)curr);
    8000173c:	00048513          	mv	a0,s1
    80001740:	00000097          	auipc	ra,0x0
    80001744:	a04080e7          	jalr	-1532(ra) # 80001144 <_Z7kputhexm>
        kputs(", size: ");
    80001748:	00003517          	auipc	a0,0x3
    8000174c:	9c850513          	addi	a0,a0,-1592 # 80004110 <CONSOLE_STATUS+0x100>
    80001750:	00000097          	auipc	ra,0x0
    80001754:	9b0080e7          	jalr	-1616(ra) # 80001100 <_Z5kputsPKc>
        kputhex(curr->size);
    80001758:	0084b503          	ld	a0,8(s1)
    8000175c:	00000097          	auipc	ra,0x0
    80001760:	9e8080e7          	jalr	-1560(ra) # 80001144 <_Z7kputhexm>
        kputs("\n");
    80001764:	00003517          	auipc	a0,0x3
    80001768:	95450513          	addi	a0,a0,-1708 # 800040b8 <CONSOLE_STATUS+0xa8>
    8000176c:	00000097          	auipc	ra,0x0
    80001770:	994080e7          	jalr	-1644(ra) # 80001100 <_Z5kputsPKc>
        curr = curr->next;
    80001774:	0004b483          	ld	s1,0(s1)
    while (curr != nullptr) {
    80001778:	fb1ff06f          	j	80001728 <_ZN15MemoryAllocator13printFreeListEv+0x2c>
    }
}
    8000177c:	01813083          	ld	ra,24(sp)
    80001780:	01013403          	ld	s0,16(sp)
    80001784:	00813483          	ld	s1,8(sp)
    80001788:	02010113          	addi	sp,sp,32
    8000178c:	00008067          	ret

0000000080001790 <_ZN15MemoryAllocator4freeEPv>:

int MemoryAllocator::free(void* ptr){
    80001790:	ff010113          	addi	sp,sp,-16
    80001794:	00813423          	sd	s0,8(sp)
    80001798:	01010413          	addi	s0,sp,16
    if (ptr == nullptr) return -1;
    8000179c:	12050663          	beqz	a0,800018c8 <_ZN15MemoryAllocator4freeEPv+0x138>
    FreeBlock* curr = freeListHead;
    800017a0:	00003797          	auipc	a5,0x3
    800017a4:	ef87b783          	ld	a5,-264(a5) # 80004698 <_ZN15MemoryAllocator12freeListHeadE>
    FreeBlock* prev = nullptr;
    // heder zivi tacno ispred payload-a
    FreeBlock* block = (FreeBlock*)((char*)ptr - sizeof(FreeBlock));
    800017a8:	ff050693          	addi	a3,a0,-16
    FreeBlock* prev = nullptr;
    800017ac:	00000713          	li	a4,0
    // nadji mesto po adresi (lista je sortirana da bi spajanje radilo)
    while(curr != nullptr && curr < block){
    800017b0:	00078a63          	beqz	a5,800017c4 <_ZN15MemoryAllocator4freeEPv+0x34>
    800017b4:	00d7f863          	bgeu	a5,a3,800017c4 <_ZN15MemoryAllocator4freeEPv+0x34>
        prev = curr;
    800017b8:	00078713          	mv	a4,a5
        curr = curr->next;
    800017bc:	0007b783          	ld	a5,0(a5)
    while(curr != nullptr && curr < block){
    800017c0:	ff1ff06f          	j	800017b0 <_ZN15MemoryAllocator4freeEPv+0x20>
    }

    // da li se blok fizicki naslanja na suseda ispred/iza?
    bool mergePrev = (prev != nullptr) && ((char*)prev + prev->size == (char*)block);
    800017c4:	04070263          	beqz	a4,80001808 <_ZN15MemoryAllocator4freeEPv+0x78>
    800017c8:	00873603          	ld	a2,8(a4)
    800017cc:	00c70633          	add	a2,a4,a2
    800017d0:	04d60063          	beq	a2,a3,80001810 <_ZN15MemoryAllocator4freeEPv+0x80>
    800017d4:	00000613          	li	a2,0
    bool mergeNext = (curr != nullptr) && ((char*)block + block->size == (char*)curr);
    800017d8:	04078063          	beqz	a5,80001818 <_ZN15MemoryAllocator4freeEPv+0x88>
    800017dc:	ff853583          	ld	a1,-8(a0)
    800017e0:	00b685b3          	add	a1,a3,a1
    800017e4:	02f58e63          	beq	a1,a5,80001820 <_ZN15MemoryAllocator4freeEPv+0x90>
    800017e8:	00000593          	li	a1,0

    if (!mergePrev && !mergeNext) {
    800017ec:	04061663          	bnez	a2,80001838 <_ZN15MemoryAllocator4freeEPv+0xa8>
    800017f0:	04059463          	bnez	a1,80001838 <_ZN15MemoryAllocator4freeEPv+0xa8>
        // nema spajanja: samo umetni izmedju prev i curr
        block->next = curr;
    800017f4:	fef53823          	sd	a5,-16(a0)
        if (prev != nullptr) {
    800017f8:	02070863          	beqz	a4,80001828 <_ZN15MemoryAllocator4freeEPv+0x98>
            prev->next = block;
    800017fc:	00d73023          	sd	a3,0(a4)
    } else {
        // spoji sa oba suseda
        prev->size += block->size + curr->size;
        prev->next = curr->next;
    }
    return 0;
    80001800:	00000513          	li	a0,0
    80001804:	0b80006f          	j	800018bc <_ZN15MemoryAllocator4freeEPv+0x12c>
    bool mergePrev = (prev != nullptr) && ((char*)prev + prev->size == (char*)block);
    80001808:	00000613          	li	a2,0
    8000180c:	fcdff06f          	j	800017d8 <_ZN15MemoryAllocator4freeEPv+0x48>
    80001810:	00100613          	li	a2,1
    80001814:	fc5ff06f          	j	800017d8 <_ZN15MemoryAllocator4freeEPv+0x48>
    bool mergeNext = (curr != nullptr) && ((char*)block + block->size == (char*)curr);
    80001818:	00000593          	li	a1,0
    8000181c:	fd1ff06f          	j	800017ec <_ZN15MemoryAllocator4freeEPv+0x5c>
    80001820:	00100593          	li	a1,1
    80001824:	fc9ff06f          	j	800017ec <_ZN15MemoryAllocator4freeEPv+0x5c>
            freeListHead = block;
    80001828:	00003797          	auipc	a5,0x3
    8000182c:	e6d7b823          	sd	a3,-400(a5) # 80004698 <_ZN15MemoryAllocator12freeListHeadE>
    return 0;
    80001830:	00000513          	li	a0,0
    80001834:	0880006f          	j	800018bc <_ZN15MemoryAllocator4freeEPv+0x12c>
    } else if (mergePrev && !mergeNext) {
    80001838:	02060063          	beqz	a2,80001858 <_ZN15MemoryAllocator4freeEPv+0xc8>
    8000183c:	00059e63          	bnez	a1,80001858 <_ZN15MemoryAllocator4freeEPv+0xc8>
        prev->size += block->size;
    80001840:	ff853683          	ld	a3,-8(a0)
    80001844:	00873783          	ld	a5,8(a4)
    80001848:	00d787b3          	add	a5,a5,a3
    8000184c:	00f73423          	sd	a5,8(a4)
    return 0;
    80001850:	00000513          	li	a0,0
        prev->size += block->size;
    80001854:	0680006f          	j	800018bc <_ZN15MemoryAllocator4freeEPv+0x12c>
    } else if (!mergePrev && mergeNext) {
    80001858:	04061063          	bnez	a2,80001898 <_ZN15MemoryAllocator4freeEPv+0x108>
    8000185c:	02058e63          	beqz	a1,80001898 <_ZN15MemoryAllocator4freeEPv+0x108>
        block->size += curr->size;
    80001860:	0087b583          	ld	a1,8(a5)
    80001864:	ff853603          	ld	a2,-8(a0)
    80001868:	00b60633          	add	a2,a2,a1
    8000186c:	fec53c23          	sd	a2,-8(a0)
        block->next = curr->next;
    80001870:	0007b783          	ld	a5,0(a5)
    80001874:	fef53823          	sd	a5,-16(a0)
        if (prev != nullptr) {
    80001878:	00070863          	beqz	a4,80001888 <_ZN15MemoryAllocator4freeEPv+0xf8>
            prev->next = block;
    8000187c:	00d73023          	sd	a3,0(a4)
    return 0;
    80001880:	00000513          	li	a0,0
    80001884:	0380006f          	j	800018bc <_ZN15MemoryAllocator4freeEPv+0x12c>
            freeListHead = block;
    80001888:	00003797          	auipc	a5,0x3
    8000188c:	e0d7b823          	sd	a3,-496(a5) # 80004698 <_ZN15MemoryAllocator12freeListHeadE>
    return 0;
    80001890:	00000513          	li	a0,0
    80001894:	0280006f          	j	800018bc <_ZN15MemoryAllocator4freeEPv+0x12c>
        prev->size += block->size + curr->size;
    80001898:	ff853683          	ld	a3,-8(a0)
    8000189c:	0087b603          	ld	a2,8(a5)
    800018a0:	00c68633          	add	a2,a3,a2
    800018a4:	00873683          	ld	a3,8(a4)
    800018a8:	00c686b3          	add	a3,a3,a2
    800018ac:	00d73423          	sd	a3,8(a4)
        prev->next = curr->next;
    800018b0:	0007b783          	ld	a5,0(a5)
    800018b4:	00f73023          	sd	a5,0(a4)
    return 0;
    800018b8:	00000513          	li	a0,0
}
    800018bc:	00813403          	ld	s0,8(sp)
    800018c0:	01010113          	addi	sp,sp,16
    800018c4:	00008067          	ret
    if (ptr == nullptr) return -1;
    800018c8:	fff00513          	li	a0,-1
    800018cc:	ff1ff06f          	j	800018bc <_ZN15MemoryAllocator4freeEPv+0x12c>

00000000800018d0 <main>:

extern "C" void trapHandler();

void userMain();   // definisana u test fajlu

int main() {
    800018d0:	fe010113          	addi	sp,sp,-32
    800018d4:	00113c23          	sd	ra,24(sp)
    800018d8:	00813823          	sd	s0,16(sp)
    800018dc:	00913423          	sd	s1,8(sp)
    800018e0:	02010413          	addi	s0,sp,32
    kputs(">> kernel: starting\n");
    800018e4:	00003517          	auipc	a0,0x3
    800018e8:	83c50513          	addi	a0,a0,-1988 # 80004120 <CONSOLE_STATUS+0x110>
    800018ec:	00000097          	auipc	ra,0x0
    800018f0:	814080e7          	jalr	-2028(ra) # 80001100 <_Z5kputsPKc>

    // stvec = adresa prekidne rutine: jedina kapija za ecall/izuzetke/prekide
    uint64 addr = (uint64)&trapHandler;
    800018f4:	fffff797          	auipc	a5,0xfffff
    800018f8:	70c78793          	addi	a5,a5,1804 # 80001000 <trapHandler>
    asm volatile("csrw stvec, %0" : : "r" (addr));
    800018fc:	10579073          	csrw	stvec,a5

    // maskiraj prekide: sve radi u sistemskom rezimu, pa sstatus.sie=0
    // znaci "ne prekidaj me" (zahtevi se pamte u sip, ali ne stizu).
    // sret ovo ne kvari: sie<-spie, a spie je snimljena nula.
    uint64 sstatus;
    asm volatile("csrr %0, sstatus" : "=r"(sstatus));
    80001900:	100027f3          	csrr	a5,sstatus
    sstatus &= ~(1UL << 1);
    80001904:	ffd7f793          	andi	a5,a5,-3
    asm volatile("csrw sstatus, %0" : : "r"(sstatus));
    80001908:	10079073          	csrw	sstatus,a5

    // dokaz da je maska stvarno upisana
    asm volatile("csrr %0, sstatus" : "=r"(sstatus));
    8000190c:	100024f3          	csrr	s1,sstatus
    kputs(">> sstatus posle maske = "); kputhex(sstatus); kputs("\n");
    80001910:	00003517          	auipc	a0,0x3
    80001914:	82850513          	addi	a0,a0,-2008 # 80004138 <CONSOLE_STATUS+0x128>
    80001918:	fffff097          	auipc	ra,0xfffff
    8000191c:	7e8080e7          	jalr	2024(ra) # 80001100 <_Z5kputsPKc>
    80001920:	00048513          	mv	a0,s1
    80001924:	00000097          	auipc	ra,0x0
    80001928:	820080e7          	jalr	-2016(ra) # 80001144 <_Z7kputhexm>
    8000192c:	00002517          	auipc	a0,0x2
    80001930:	78c50513          	addi	a0,a0,1932 # 800040b8 <CONSOLE_STATUS+0xa8>
    80001934:	fffff097          	auipc	ra,0xfffff
    80001938:	7cc080e7          	jalr	1996(ra) # 80001100 <_Z5kputsPKc>

    MemoryAllocator::init();
    8000193c:	00000097          	auipc	ra,0x0
    80001940:	ccc080e7          	jalr	-820(ra) # 80001608 <_ZN15MemoryAllocator4initEv>

    userMain();    // privremeno: obican poziv funkcije; kasnije postaje
    80001944:	00000097          	auipc	ra,0x0
    80001948:	a98080e7          	jalr	-1384(ra) # 800013dc <_Z8userMainv>
                   // telo prve niti koju pokrece jezgro

    kputs(">> kernel: userMain returned, halting\n");
    8000194c:	00003517          	auipc	a0,0x3
    80001950:	80c50513          	addi	a0,a0,-2036 # 80004158 <CONSOLE_STATUS+0x148>
    80001954:	fffff097          	auipc	ra,0xfffff
    80001958:	7ac080e7          	jalr	1964(ra) # 80001100 <_Z5kputsPKc>

    // upis 0x5555 na 0x100000 gasi emulator (regularan kraj procesa)
    *(volatile int*)0x100000 = 0x5555;
    8000195c:	00100737          	lui	a4,0x100
    80001960:	000057b7          	lui	a5,0x5
    80001964:	5557879b          	addiw	a5,a5,1365
    80001968:	00f72023          	sw	a5,0(a4) # 100000 <_entry-0x7ff00000>

    return 0;
}
    8000196c:	00000513          	li	a0,0
    80001970:	01813083          	ld	ra,24(sp)
    80001974:	01013403          	ld	s0,16(sp)
    80001978:	00813483          	ld	s1,8(sp)
    8000197c:	02010113          	addi	sp,sp,32
    80001980:	00008067          	ret

0000000080001984 <start>:
    80001984:	ff010113          	addi	sp,sp,-16
    80001988:	00813423          	sd	s0,8(sp)
    8000198c:	01010413          	addi	s0,sp,16
    80001990:	300027f3          	csrr	a5,mstatus
    80001994:	ffffe737          	lui	a4,0xffffe
    80001998:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fff8edf>
    8000199c:	00e7f7b3          	and	a5,a5,a4
    800019a0:	00001737          	lui	a4,0x1
    800019a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800019a8:	00e7e7b3          	or	a5,a5,a4
    800019ac:	30079073          	csrw	mstatus,a5
    800019b0:	00000797          	auipc	a5,0x0
    800019b4:	16078793          	addi	a5,a5,352 # 80001b10 <system_main>
    800019b8:	34179073          	csrw	mepc,a5
    800019bc:	00000793          	li	a5,0
    800019c0:	18079073          	csrw	satp,a5
    800019c4:	000107b7          	lui	a5,0x10
    800019c8:	fff78793          	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800019cc:	30279073          	csrw	medeleg,a5
    800019d0:	30379073          	csrw	mideleg,a5
    800019d4:	104027f3          	csrr	a5,sie
    800019d8:	2227e793          	ori	a5,a5,546
    800019dc:	10479073          	csrw	sie,a5
    800019e0:	fff00793          	li	a5,-1
    800019e4:	00a7d793          	srli	a5,a5,0xa
    800019e8:	3b079073          	csrw	pmpaddr0,a5
    800019ec:	00f00793          	li	a5,15
    800019f0:	3a079073          	csrw	pmpcfg0,a5
    800019f4:	f14027f3          	csrr	a5,mhartid
    800019f8:	0200c737          	lui	a4,0x200c
    800019fc:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80001a00:	0007869b          	sext.w	a3,a5
    80001a04:	00269713          	slli	a4,a3,0x2
    80001a08:	000f4637          	lui	a2,0xf4
    80001a0c:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80001a10:	00d70733          	add	a4,a4,a3
    80001a14:	0037979b          	slliw	a5,a5,0x3
    80001a18:	020046b7          	lui	a3,0x2004
    80001a1c:	00d787b3          	add	a5,a5,a3
    80001a20:	00c585b3          	add	a1,a1,a2
    80001a24:	00371693          	slli	a3,a4,0x3
    80001a28:	00003717          	auipc	a4,0x3
    80001a2c:	ca870713          	addi	a4,a4,-856 # 800046d0 <timer_scratch>
    80001a30:	00b7b023          	sd	a1,0(a5)
    80001a34:	00d70733          	add	a4,a4,a3
    80001a38:	00f73c23          	sd	a5,24(a4)
    80001a3c:	02c73023          	sd	a2,32(a4)
    80001a40:	34071073          	csrw	mscratch,a4
    80001a44:	00000797          	auipc	a5,0x0
    80001a48:	6ec78793          	addi	a5,a5,1772 # 80002130 <timervec>
    80001a4c:	30579073          	csrw	mtvec,a5
    80001a50:	300027f3          	csrr	a5,mstatus
    80001a54:	0087e793          	ori	a5,a5,8
    80001a58:	30079073          	csrw	mstatus,a5
    80001a5c:	304027f3          	csrr	a5,mie
    80001a60:	0807e793          	ori	a5,a5,128
    80001a64:	30479073          	csrw	mie,a5
    80001a68:	f14027f3          	csrr	a5,mhartid
    80001a6c:	0007879b          	sext.w	a5,a5
    80001a70:	00078213          	mv	tp,a5
    80001a74:	30200073          	mret
    80001a78:	00813403          	ld	s0,8(sp)
    80001a7c:	01010113          	addi	sp,sp,16
    80001a80:	00008067          	ret

0000000080001a84 <timerinit>:
    80001a84:	ff010113          	addi	sp,sp,-16
    80001a88:	00813423          	sd	s0,8(sp)
    80001a8c:	01010413          	addi	s0,sp,16
    80001a90:	f14027f3          	csrr	a5,mhartid
    80001a94:	0200c737          	lui	a4,0x200c
    80001a98:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80001a9c:	0007869b          	sext.w	a3,a5
    80001aa0:	00269713          	slli	a4,a3,0x2
    80001aa4:	000f4637          	lui	a2,0xf4
    80001aa8:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80001aac:	00d70733          	add	a4,a4,a3
    80001ab0:	0037979b          	slliw	a5,a5,0x3
    80001ab4:	020046b7          	lui	a3,0x2004
    80001ab8:	00d787b3          	add	a5,a5,a3
    80001abc:	00c585b3          	add	a1,a1,a2
    80001ac0:	00371693          	slli	a3,a4,0x3
    80001ac4:	00003717          	auipc	a4,0x3
    80001ac8:	c0c70713          	addi	a4,a4,-1012 # 800046d0 <timer_scratch>
    80001acc:	00b7b023          	sd	a1,0(a5)
    80001ad0:	00d70733          	add	a4,a4,a3
    80001ad4:	00f73c23          	sd	a5,24(a4)
    80001ad8:	02c73023          	sd	a2,32(a4)
    80001adc:	34071073          	csrw	mscratch,a4
    80001ae0:	00000797          	auipc	a5,0x0
    80001ae4:	65078793          	addi	a5,a5,1616 # 80002130 <timervec>
    80001ae8:	30579073          	csrw	mtvec,a5
    80001aec:	300027f3          	csrr	a5,mstatus
    80001af0:	0087e793          	ori	a5,a5,8
    80001af4:	30079073          	csrw	mstatus,a5
    80001af8:	304027f3          	csrr	a5,mie
    80001afc:	0807e793          	ori	a5,a5,128
    80001b00:	30479073          	csrw	mie,a5
    80001b04:	00813403          	ld	s0,8(sp)
    80001b08:	01010113          	addi	sp,sp,16
    80001b0c:	00008067          	ret

0000000080001b10 <system_main>:
    80001b10:	fe010113          	addi	sp,sp,-32
    80001b14:	00813823          	sd	s0,16(sp)
    80001b18:	00913423          	sd	s1,8(sp)
    80001b1c:	00113c23          	sd	ra,24(sp)
    80001b20:	02010413          	addi	s0,sp,32
    80001b24:	00000097          	auipc	ra,0x0
    80001b28:	0c4080e7          	jalr	196(ra) # 80001be8 <cpuid>
    80001b2c:	00003497          	auipc	s1,0x3
    80001b30:	b7448493          	addi	s1,s1,-1164 # 800046a0 <started>
    80001b34:	02050263          	beqz	a0,80001b58 <system_main+0x48>
    80001b38:	0004a783          	lw	a5,0(s1)
    80001b3c:	0007879b          	sext.w	a5,a5
    80001b40:	fe078ce3          	beqz	a5,80001b38 <system_main+0x28>
    80001b44:	0ff0000f          	fence
    80001b48:	00002517          	auipc	a0,0x2
    80001b4c:	66850513          	addi	a0,a0,1640 # 800041b0 <CONSOLE_STATUS+0x1a0>
    80001b50:	00001097          	auipc	ra,0x1
    80001b54:	a7c080e7          	jalr	-1412(ra) # 800025cc <panic>
    80001b58:	00001097          	auipc	ra,0x1
    80001b5c:	9d0080e7          	jalr	-1584(ra) # 80002528 <consoleinit>
    80001b60:	00001097          	auipc	ra,0x1
    80001b64:	15c080e7          	jalr	348(ra) # 80002cbc <printfinit>
    80001b68:	00002517          	auipc	a0,0x2
    80001b6c:	55050513          	addi	a0,a0,1360 # 800040b8 <CONSOLE_STATUS+0xa8>
    80001b70:	00001097          	auipc	ra,0x1
    80001b74:	ab8080e7          	jalr	-1352(ra) # 80002628 <__printf>
    80001b78:	00002517          	auipc	a0,0x2
    80001b7c:	60850513          	addi	a0,a0,1544 # 80004180 <CONSOLE_STATUS+0x170>
    80001b80:	00001097          	auipc	ra,0x1
    80001b84:	aa8080e7          	jalr	-1368(ra) # 80002628 <__printf>
    80001b88:	00002517          	auipc	a0,0x2
    80001b8c:	53050513          	addi	a0,a0,1328 # 800040b8 <CONSOLE_STATUS+0xa8>
    80001b90:	00001097          	auipc	ra,0x1
    80001b94:	a98080e7          	jalr	-1384(ra) # 80002628 <__printf>
    80001b98:	00001097          	auipc	ra,0x1
    80001b9c:	4b0080e7          	jalr	1200(ra) # 80003048 <kinit>
    80001ba0:	00000097          	auipc	ra,0x0
    80001ba4:	148080e7          	jalr	328(ra) # 80001ce8 <trapinit>
    80001ba8:	00000097          	auipc	ra,0x0
    80001bac:	16c080e7          	jalr	364(ra) # 80001d14 <trapinithart>
    80001bb0:	00000097          	auipc	ra,0x0
    80001bb4:	5c0080e7          	jalr	1472(ra) # 80002170 <plicinit>
    80001bb8:	00000097          	auipc	ra,0x0
    80001bbc:	5e0080e7          	jalr	1504(ra) # 80002198 <plicinithart>
    80001bc0:	00000097          	auipc	ra,0x0
    80001bc4:	078080e7          	jalr	120(ra) # 80001c38 <userinit>
    80001bc8:	0ff0000f          	fence
    80001bcc:	00100793          	li	a5,1
    80001bd0:	00002517          	auipc	a0,0x2
    80001bd4:	5c850513          	addi	a0,a0,1480 # 80004198 <CONSOLE_STATUS+0x188>
    80001bd8:	00f4a023          	sw	a5,0(s1)
    80001bdc:	00001097          	auipc	ra,0x1
    80001be0:	a4c080e7          	jalr	-1460(ra) # 80002628 <__printf>
    80001be4:	0000006f          	j	80001be4 <system_main+0xd4>

0000000080001be8 <cpuid>:
    80001be8:	ff010113          	addi	sp,sp,-16
    80001bec:	00813423          	sd	s0,8(sp)
    80001bf0:	01010413          	addi	s0,sp,16
    80001bf4:	00020513          	mv	a0,tp
    80001bf8:	00813403          	ld	s0,8(sp)
    80001bfc:	0005051b          	sext.w	a0,a0
    80001c00:	01010113          	addi	sp,sp,16
    80001c04:	00008067          	ret

0000000080001c08 <mycpu>:
    80001c08:	ff010113          	addi	sp,sp,-16
    80001c0c:	00813423          	sd	s0,8(sp)
    80001c10:	01010413          	addi	s0,sp,16
    80001c14:	00020793          	mv	a5,tp
    80001c18:	00813403          	ld	s0,8(sp)
    80001c1c:	0007879b          	sext.w	a5,a5
    80001c20:	00779793          	slli	a5,a5,0x7
    80001c24:	00004517          	auipc	a0,0x4
    80001c28:	adc50513          	addi	a0,a0,-1316 # 80005700 <cpus>
    80001c2c:	00f50533          	add	a0,a0,a5
    80001c30:	01010113          	addi	sp,sp,16
    80001c34:	00008067          	ret

0000000080001c38 <userinit>:
    80001c38:	ff010113          	addi	sp,sp,-16
    80001c3c:	00813423          	sd	s0,8(sp)
    80001c40:	01010413          	addi	s0,sp,16
    80001c44:	00813403          	ld	s0,8(sp)
    80001c48:	01010113          	addi	sp,sp,16
    80001c4c:	00000317          	auipc	t1,0x0
    80001c50:	c8430067          	jr	-892(t1) # 800018d0 <main>

0000000080001c54 <either_copyout>:
    80001c54:	ff010113          	addi	sp,sp,-16
    80001c58:	00813023          	sd	s0,0(sp)
    80001c5c:	00113423          	sd	ra,8(sp)
    80001c60:	01010413          	addi	s0,sp,16
    80001c64:	02051663          	bnez	a0,80001c90 <either_copyout+0x3c>
    80001c68:	00058513          	mv	a0,a1
    80001c6c:	00060593          	mv	a1,a2
    80001c70:	0006861b          	sext.w	a2,a3
    80001c74:	00002097          	auipc	ra,0x2
    80001c78:	c60080e7          	jalr	-928(ra) # 800038d4 <__memmove>
    80001c7c:	00813083          	ld	ra,8(sp)
    80001c80:	00013403          	ld	s0,0(sp)
    80001c84:	00000513          	li	a0,0
    80001c88:	01010113          	addi	sp,sp,16
    80001c8c:	00008067          	ret
    80001c90:	00002517          	auipc	a0,0x2
    80001c94:	54850513          	addi	a0,a0,1352 # 800041d8 <CONSOLE_STATUS+0x1c8>
    80001c98:	00001097          	auipc	ra,0x1
    80001c9c:	934080e7          	jalr	-1740(ra) # 800025cc <panic>

0000000080001ca0 <either_copyin>:
    80001ca0:	ff010113          	addi	sp,sp,-16
    80001ca4:	00813023          	sd	s0,0(sp)
    80001ca8:	00113423          	sd	ra,8(sp)
    80001cac:	01010413          	addi	s0,sp,16
    80001cb0:	02059463          	bnez	a1,80001cd8 <either_copyin+0x38>
    80001cb4:	00060593          	mv	a1,a2
    80001cb8:	0006861b          	sext.w	a2,a3
    80001cbc:	00002097          	auipc	ra,0x2
    80001cc0:	c18080e7          	jalr	-1000(ra) # 800038d4 <__memmove>
    80001cc4:	00813083          	ld	ra,8(sp)
    80001cc8:	00013403          	ld	s0,0(sp)
    80001ccc:	00000513          	li	a0,0
    80001cd0:	01010113          	addi	sp,sp,16
    80001cd4:	00008067          	ret
    80001cd8:	00002517          	auipc	a0,0x2
    80001cdc:	52850513          	addi	a0,a0,1320 # 80004200 <CONSOLE_STATUS+0x1f0>
    80001ce0:	00001097          	auipc	ra,0x1
    80001ce4:	8ec080e7          	jalr	-1812(ra) # 800025cc <panic>

0000000080001ce8 <trapinit>:
    80001ce8:	ff010113          	addi	sp,sp,-16
    80001cec:	00813423          	sd	s0,8(sp)
    80001cf0:	01010413          	addi	s0,sp,16
    80001cf4:	00813403          	ld	s0,8(sp)
    80001cf8:	00002597          	auipc	a1,0x2
    80001cfc:	53058593          	addi	a1,a1,1328 # 80004228 <CONSOLE_STATUS+0x218>
    80001d00:	00004517          	auipc	a0,0x4
    80001d04:	a8050513          	addi	a0,a0,-1408 # 80005780 <tickslock>
    80001d08:	01010113          	addi	sp,sp,16
    80001d0c:	00001317          	auipc	t1,0x1
    80001d10:	5cc30067          	jr	1484(t1) # 800032d8 <initlock>

0000000080001d14 <trapinithart>:
    80001d14:	ff010113          	addi	sp,sp,-16
    80001d18:	00813423          	sd	s0,8(sp)
    80001d1c:	01010413          	addi	s0,sp,16
    80001d20:	00000797          	auipc	a5,0x0
    80001d24:	30078793          	addi	a5,a5,768 # 80002020 <kernelvec>
    80001d28:	10579073          	csrw	stvec,a5
    80001d2c:	00813403          	ld	s0,8(sp)
    80001d30:	01010113          	addi	sp,sp,16
    80001d34:	00008067          	ret

0000000080001d38 <usertrap>:
    80001d38:	ff010113          	addi	sp,sp,-16
    80001d3c:	00813423          	sd	s0,8(sp)
    80001d40:	01010413          	addi	s0,sp,16
    80001d44:	00813403          	ld	s0,8(sp)
    80001d48:	01010113          	addi	sp,sp,16
    80001d4c:	00008067          	ret

0000000080001d50 <usertrapret>:
    80001d50:	ff010113          	addi	sp,sp,-16
    80001d54:	00813423          	sd	s0,8(sp)
    80001d58:	01010413          	addi	s0,sp,16
    80001d5c:	00813403          	ld	s0,8(sp)
    80001d60:	01010113          	addi	sp,sp,16
    80001d64:	00008067          	ret

0000000080001d68 <kerneltrap>:
    80001d68:	fe010113          	addi	sp,sp,-32
    80001d6c:	00813823          	sd	s0,16(sp)
    80001d70:	00113c23          	sd	ra,24(sp)
    80001d74:	00913423          	sd	s1,8(sp)
    80001d78:	02010413          	addi	s0,sp,32
    80001d7c:	142025f3          	csrr	a1,scause
    80001d80:	100027f3          	csrr	a5,sstatus
    80001d84:	0027f793          	andi	a5,a5,2
    80001d88:	10079c63          	bnez	a5,80001ea0 <kerneltrap+0x138>
    80001d8c:	142027f3          	csrr	a5,scause
    80001d90:	0207ce63          	bltz	a5,80001dcc <kerneltrap+0x64>
    80001d94:	00002517          	auipc	a0,0x2
    80001d98:	4dc50513          	addi	a0,a0,1244 # 80004270 <CONSOLE_STATUS+0x260>
    80001d9c:	00001097          	auipc	ra,0x1
    80001da0:	88c080e7          	jalr	-1908(ra) # 80002628 <__printf>
    80001da4:	141025f3          	csrr	a1,sepc
    80001da8:	14302673          	csrr	a2,stval
    80001dac:	00002517          	auipc	a0,0x2
    80001db0:	4d450513          	addi	a0,a0,1236 # 80004280 <CONSOLE_STATUS+0x270>
    80001db4:	00001097          	auipc	ra,0x1
    80001db8:	874080e7          	jalr	-1932(ra) # 80002628 <__printf>
    80001dbc:	00002517          	auipc	a0,0x2
    80001dc0:	4dc50513          	addi	a0,a0,1244 # 80004298 <CONSOLE_STATUS+0x288>
    80001dc4:	00001097          	auipc	ra,0x1
    80001dc8:	808080e7          	jalr	-2040(ra) # 800025cc <panic>
    80001dcc:	0ff7f713          	andi	a4,a5,255
    80001dd0:	00900693          	li	a3,9
    80001dd4:	04d70063          	beq	a4,a3,80001e14 <kerneltrap+0xac>
    80001dd8:	fff00713          	li	a4,-1
    80001ddc:	03f71713          	slli	a4,a4,0x3f
    80001de0:	00170713          	addi	a4,a4,1
    80001de4:	fae798e3          	bne	a5,a4,80001d94 <kerneltrap+0x2c>
    80001de8:	00000097          	auipc	ra,0x0
    80001dec:	e00080e7          	jalr	-512(ra) # 80001be8 <cpuid>
    80001df0:	06050663          	beqz	a0,80001e5c <kerneltrap+0xf4>
    80001df4:	144027f3          	csrr	a5,sip
    80001df8:	ffd7f793          	andi	a5,a5,-3
    80001dfc:	14479073          	csrw	sip,a5
    80001e00:	01813083          	ld	ra,24(sp)
    80001e04:	01013403          	ld	s0,16(sp)
    80001e08:	00813483          	ld	s1,8(sp)
    80001e0c:	02010113          	addi	sp,sp,32
    80001e10:	00008067          	ret
    80001e14:	00000097          	auipc	ra,0x0
    80001e18:	3d0080e7          	jalr	976(ra) # 800021e4 <plic_claim>
    80001e1c:	00a00793          	li	a5,10
    80001e20:	00050493          	mv	s1,a0
    80001e24:	06f50863          	beq	a0,a5,80001e94 <kerneltrap+0x12c>
    80001e28:	fc050ce3          	beqz	a0,80001e00 <kerneltrap+0x98>
    80001e2c:	00050593          	mv	a1,a0
    80001e30:	00002517          	auipc	a0,0x2
    80001e34:	42050513          	addi	a0,a0,1056 # 80004250 <CONSOLE_STATUS+0x240>
    80001e38:	00000097          	auipc	ra,0x0
    80001e3c:	7f0080e7          	jalr	2032(ra) # 80002628 <__printf>
    80001e40:	01013403          	ld	s0,16(sp)
    80001e44:	01813083          	ld	ra,24(sp)
    80001e48:	00048513          	mv	a0,s1
    80001e4c:	00813483          	ld	s1,8(sp)
    80001e50:	02010113          	addi	sp,sp,32
    80001e54:	00000317          	auipc	t1,0x0
    80001e58:	3c830067          	jr	968(t1) # 8000221c <plic_complete>
    80001e5c:	00004517          	auipc	a0,0x4
    80001e60:	92450513          	addi	a0,a0,-1756 # 80005780 <tickslock>
    80001e64:	00001097          	auipc	ra,0x1
    80001e68:	498080e7          	jalr	1176(ra) # 800032fc <acquire>
    80001e6c:	00003717          	auipc	a4,0x3
    80001e70:	83870713          	addi	a4,a4,-1992 # 800046a4 <ticks>
    80001e74:	00072783          	lw	a5,0(a4)
    80001e78:	00004517          	auipc	a0,0x4
    80001e7c:	90850513          	addi	a0,a0,-1784 # 80005780 <tickslock>
    80001e80:	0017879b          	addiw	a5,a5,1
    80001e84:	00f72023          	sw	a5,0(a4)
    80001e88:	00001097          	auipc	ra,0x1
    80001e8c:	540080e7          	jalr	1344(ra) # 800033c8 <release>
    80001e90:	f65ff06f          	j	80001df4 <kerneltrap+0x8c>
    80001e94:	00001097          	auipc	ra,0x1
    80001e98:	09c080e7          	jalr	156(ra) # 80002f30 <uartintr>
    80001e9c:	fa5ff06f          	j	80001e40 <kerneltrap+0xd8>
    80001ea0:	00002517          	auipc	a0,0x2
    80001ea4:	39050513          	addi	a0,a0,912 # 80004230 <CONSOLE_STATUS+0x220>
    80001ea8:	00000097          	auipc	ra,0x0
    80001eac:	724080e7          	jalr	1828(ra) # 800025cc <panic>

0000000080001eb0 <clockintr>:
    80001eb0:	fe010113          	addi	sp,sp,-32
    80001eb4:	00813823          	sd	s0,16(sp)
    80001eb8:	00913423          	sd	s1,8(sp)
    80001ebc:	00113c23          	sd	ra,24(sp)
    80001ec0:	02010413          	addi	s0,sp,32
    80001ec4:	00004497          	auipc	s1,0x4
    80001ec8:	8bc48493          	addi	s1,s1,-1860 # 80005780 <tickslock>
    80001ecc:	00048513          	mv	a0,s1
    80001ed0:	00001097          	auipc	ra,0x1
    80001ed4:	42c080e7          	jalr	1068(ra) # 800032fc <acquire>
    80001ed8:	00002717          	auipc	a4,0x2
    80001edc:	7cc70713          	addi	a4,a4,1996 # 800046a4 <ticks>
    80001ee0:	00072783          	lw	a5,0(a4)
    80001ee4:	01013403          	ld	s0,16(sp)
    80001ee8:	01813083          	ld	ra,24(sp)
    80001eec:	00048513          	mv	a0,s1
    80001ef0:	0017879b          	addiw	a5,a5,1
    80001ef4:	00813483          	ld	s1,8(sp)
    80001ef8:	00f72023          	sw	a5,0(a4)
    80001efc:	02010113          	addi	sp,sp,32
    80001f00:	00001317          	auipc	t1,0x1
    80001f04:	4c830067          	jr	1224(t1) # 800033c8 <release>

0000000080001f08 <devintr>:
    80001f08:	142027f3          	csrr	a5,scause
    80001f0c:	00000513          	li	a0,0
    80001f10:	0007c463          	bltz	a5,80001f18 <devintr+0x10>
    80001f14:	00008067          	ret
    80001f18:	fe010113          	addi	sp,sp,-32
    80001f1c:	00813823          	sd	s0,16(sp)
    80001f20:	00113c23          	sd	ra,24(sp)
    80001f24:	00913423          	sd	s1,8(sp)
    80001f28:	02010413          	addi	s0,sp,32
    80001f2c:	0ff7f713          	andi	a4,a5,255
    80001f30:	00900693          	li	a3,9
    80001f34:	04d70c63          	beq	a4,a3,80001f8c <devintr+0x84>
    80001f38:	fff00713          	li	a4,-1
    80001f3c:	03f71713          	slli	a4,a4,0x3f
    80001f40:	00170713          	addi	a4,a4,1
    80001f44:	00e78c63          	beq	a5,a4,80001f5c <devintr+0x54>
    80001f48:	01813083          	ld	ra,24(sp)
    80001f4c:	01013403          	ld	s0,16(sp)
    80001f50:	00813483          	ld	s1,8(sp)
    80001f54:	02010113          	addi	sp,sp,32
    80001f58:	00008067          	ret
    80001f5c:	00000097          	auipc	ra,0x0
    80001f60:	c8c080e7          	jalr	-884(ra) # 80001be8 <cpuid>
    80001f64:	06050663          	beqz	a0,80001fd0 <devintr+0xc8>
    80001f68:	144027f3          	csrr	a5,sip
    80001f6c:	ffd7f793          	andi	a5,a5,-3
    80001f70:	14479073          	csrw	sip,a5
    80001f74:	01813083          	ld	ra,24(sp)
    80001f78:	01013403          	ld	s0,16(sp)
    80001f7c:	00813483          	ld	s1,8(sp)
    80001f80:	00200513          	li	a0,2
    80001f84:	02010113          	addi	sp,sp,32
    80001f88:	00008067          	ret
    80001f8c:	00000097          	auipc	ra,0x0
    80001f90:	258080e7          	jalr	600(ra) # 800021e4 <plic_claim>
    80001f94:	00a00793          	li	a5,10
    80001f98:	00050493          	mv	s1,a0
    80001f9c:	06f50663          	beq	a0,a5,80002008 <devintr+0x100>
    80001fa0:	00100513          	li	a0,1
    80001fa4:	fa0482e3          	beqz	s1,80001f48 <devintr+0x40>
    80001fa8:	00048593          	mv	a1,s1
    80001fac:	00002517          	auipc	a0,0x2
    80001fb0:	2a450513          	addi	a0,a0,676 # 80004250 <CONSOLE_STATUS+0x240>
    80001fb4:	00000097          	auipc	ra,0x0
    80001fb8:	674080e7          	jalr	1652(ra) # 80002628 <__printf>
    80001fbc:	00048513          	mv	a0,s1
    80001fc0:	00000097          	auipc	ra,0x0
    80001fc4:	25c080e7          	jalr	604(ra) # 8000221c <plic_complete>
    80001fc8:	00100513          	li	a0,1
    80001fcc:	f7dff06f          	j	80001f48 <devintr+0x40>
    80001fd0:	00003517          	auipc	a0,0x3
    80001fd4:	7b050513          	addi	a0,a0,1968 # 80005780 <tickslock>
    80001fd8:	00001097          	auipc	ra,0x1
    80001fdc:	324080e7          	jalr	804(ra) # 800032fc <acquire>
    80001fe0:	00002717          	auipc	a4,0x2
    80001fe4:	6c470713          	addi	a4,a4,1732 # 800046a4 <ticks>
    80001fe8:	00072783          	lw	a5,0(a4)
    80001fec:	00003517          	auipc	a0,0x3
    80001ff0:	79450513          	addi	a0,a0,1940 # 80005780 <tickslock>
    80001ff4:	0017879b          	addiw	a5,a5,1
    80001ff8:	00f72023          	sw	a5,0(a4)
    80001ffc:	00001097          	auipc	ra,0x1
    80002000:	3cc080e7          	jalr	972(ra) # 800033c8 <release>
    80002004:	f65ff06f          	j	80001f68 <devintr+0x60>
    80002008:	00001097          	auipc	ra,0x1
    8000200c:	f28080e7          	jalr	-216(ra) # 80002f30 <uartintr>
    80002010:	fadff06f          	j	80001fbc <devintr+0xb4>
	...

0000000080002020 <kernelvec>:
    80002020:	f0010113          	addi	sp,sp,-256
    80002024:	00113023          	sd	ra,0(sp)
    80002028:	00213423          	sd	sp,8(sp)
    8000202c:	00313823          	sd	gp,16(sp)
    80002030:	00413c23          	sd	tp,24(sp)
    80002034:	02513023          	sd	t0,32(sp)
    80002038:	02613423          	sd	t1,40(sp)
    8000203c:	02713823          	sd	t2,48(sp)
    80002040:	02813c23          	sd	s0,56(sp)
    80002044:	04913023          	sd	s1,64(sp)
    80002048:	04a13423          	sd	a0,72(sp)
    8000204c:	04b13823          	sd	a1,80(sp)
    80002050:	04c13c23          	sd	a2,88(sp)
    80002054:	06d13023          	sd	a3,96(sp)
    80002058:	06e13423          	sd	a4,104(sp)
    8000205c:	06f13823          	sd	a5,112(sp)
    80002060:	07013c23          	sd	a6,120(sp)
    80002064:	09113023          	sd	a7,128(sp)
    80002068:	09213423          	sd	s2,136(sp)
    8000206c:	09313823          	sd	s3,144(sp)
    80002070:	09413c23          	sd	s4,152(sp)
    80002074:	0b513023          	sd	s5,160(sp)
    80002078:	0b613423          	sd	s6,168(sp)
    8000207c:	0b713823          	sd	s7,176(sp)
    80002080:	0b813c23          	sd	s8,184(sp)
    80002084:	0d913023          	sd	s9,192(sp)
    80002088:	0da13423          	sd	s10,200(sp)
    8000208c:	0db13823          	sd	s11,208(sp)
    80002090:	0dc13c23          	sd	t3,216(sp)
    80002094:	0fd13023          	sd	t4,224(sp)
    80002098:	0fe13423          	sd	t5,232(sp)
    8000209c:	0ff13823          	sd	t6,240(sp)
    800020a0:	cc9ff0ef          	jal	ra,80001d68 <kerneltrap>
    800020a4:	00013083          	ld	ra,0(sp)
    800020a8:	00813103          	ld	sp,8(sp)
    800020ac:	01013183          	ld	gp,16(sp)
    800020b0:	02013283          	ld	t0,32(sp)
    800020b4:	02813303          	ld	t1,40(sp)
    800020b8:	03013383          	ld	t2,48(sp)
    800020bc:	03813403          	ld	s0,56(sp)
    800020c0:	04013483          	ld	s1,64(sp)
    800020c4:	04813503          	ld	a0,72(sp)
    800020c8:	05013583          	ld	a1,80(sp)
    800020cc:	05813603          	ld	a2,88(sp)
    800020d0:	06013683          	ld	a3,96(sp)
    800020d4:	06813703          	ld	a4,104(sp)
    800020d8:	07013783          	ld	a5,112(sp)
    800020dc:	07813803          	ld	a6,120(sp)
    800020e0:	08013883          	ld	a7,128(sp)
    800020e4:	08813903          	ld	s2,136(sp)
    800020e8:	09013983          	ld	s3,144(sp)
    800020ec:	09813a03          	ld	s4,152(sp)
    800020f0:	0a013a83          	ld	s5,160(sp)
    800020f4:	0a813b03          	ld	s6,168(sp)
    800020f8:	0b013b83          	ld	s7,176(sp)
    800020fc:	0b813c03          	ld	s8,184(sp)
    80002100:	0c013c83          	ld	s9,192(sp)
    80002104:	0c813d03          	ld	s10,200(sp)
    80002108:	0d013d83          	ld	s11,208(sp)
    8000210c:	0d813e03          	ld	t3,216(sp)
    80002110:	0e013e83          	ld	t4,224(sp)
    80002114:	0e813f03          	ld	t5,232(sp)
    80002118:	0f013f83          	ld	t6,240(sp)
    8000211c:	10010113          	addi	sp,sp,256
    80002120:	10200073          	sret
    80002124:	00000013          	nop
    80002128:	00000013          	nop
    8000212c:	00000013          	nop

0000000080002130 <timervec>:
    80002130:	34051573          	csrrw	a0,mscratch,a0
    80002134:	00b53023          	sd	a1,0(a0)
    80002138:	00c53423          	sd	a2,8(a0)
    8000213c:	00d53823          	sd	a3,16(a0)
    80002140:	01853583          	ld	a1,24(a0)
    80002144:	02053603          	ld	a2,32(a0)
    80002148:	0005b683          	ld	a3,0(a1)
    8000214c:	00c686b3          	add	a3,a3,a2
    80002150:	00d5b023          	sd	a3,0(a1)
    80002154:	00200593          	li	a1,2
    80002158:	14459073          	csrw	sip,a1
    8000215c:	01053683          	ld	a3,16(a0)
    80002160:	00853603          	ld	a2,8(a0)
    80002164:	00053583          	ld	a1,0(a0)
    80002168:	34051573          	csrrw	a0,mscratch,a0
    8000216c:	30200073          	mret

0000000080002170 <plicinit>:
    80002170:	ff010113          	addi	sp,sp,-16
    80002174:	00813423          	sd	s0,8(sp)
    80002178:	01010413          	addi	s0,sp,16
    8000217c:	00813403          	ld	s0,8(sp)
    80002180:	0c0007b7          	lui	a5,0xc000
    80002184:	00100713          	li	a4,1
    80002188:	02e7a423          	sw	a4,40(a5) # c000028 <_entry-0x73ffffd8>
    8000218c:	00e7a223          	sw	a4,4(a5)
    80002190:	01010113          	addi	sp,sp,16
    80002194:	00008067          	ret

0000000080002198 <plicinithart>:
    80002198:	ff010113          	addi	sp,sp,-16
    8000219c:	00813023          	sd	s0,0(sp)
    800021a0:	00113423          	sd	ra,8(sp)
    800021a4:	01010413          	addi	s0,sp,16
    800021a8:	00000097          	auipc	ra,0x0
    800021ac:	a40080e7          	jalr	-1472(ra) # 80001be8 <cpuid>
    800021b0:	0085171b          	slliw	a4,a0,0x8
    800021b4:	0c0027b7          	lui	a5,0xc002
    800021b8:	00e787b3          	add	a5,a5,a4
    800021bc:	40200713          	li	a4,1026
    800021c0:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>
    800021c4:	00813083          	ld	ra,8(sp)
    800021c8:	00013403          	ld	s0,0(sp)
    800021cc:	00d5151b          	slliw	a0,a0,0xd
    800021d0:	0c2017b7          	lui	a5,0xc201
    800021d4:	00a78533          	add	a0,a5,a0
    800021d8:	00052023          	sw	zero,0(a0)
    800021dc:	01010113          	addi	sp,sp,16
    800021e0:	00008067          	ret

00000000800021e4 <plic_claim>:
    800021e4:	ff010113          	addi	sp,sp,-16
    800021e8:	00813023          	sd	s0,0(sp)
    800021ec:	00113423          	sd	ra,8(sp)
    800021f0:	01010413          	addi	s0,sp,16
    800021f4:	00000097          	auipc	ra,0x0
    800021f8:	9f4080e7          	jalr	-1548(ra) # 80001be8 <cpuid>
    800021fc:	00813083          	ld	ra,8(sp)
    80002200:	00013403          	ld	s0,0(sp)
    80002204:	00d5151b          	slliw	a0,a0,0xd
    80002208:	0c2017b7          	lui	a5,0xc201
    8000220c:	00a78533          	add	a0,a5,a0
    80002210:	00452503          	lw	a0,4(a0)
    80002214:	01010113          	addi	sp,sp,16
    80002218:	00008067          	ret

000000008000221c <plic_complete>:
    8000221c:	fe010113          	addi	sp,sp,-32
    80002220:	00813823          	sd	s0,16(sp)
    80002224:	00913423          	sd	s1,8(sp)
    80002228:	00113c23          	sd	ra,24(sp)
    8000222c:	02010413          	addi	s0,sp,32
    80002230:	00050493          	mv	s1,a0
    80002234:	00000097          	auipc	ra,0x0
    80002238:	9b4080e7          	jalr	-1612(ra) # 80001be8 <cpuid>
    8000223c:	01813083          	ld	ra,24(sp)
    80002240:	01013403          	ld	s0,16(sp)
    80002244:	00d5179b          	slliw	a5,a0,0xd
    80002248:	0c201737          	lui	a4,0xc201
    8000224c:	00f707b3          	add	a5,a4,a5
    80002250:	0097a223          	sw	s1,4(a5) # c201004 <_entry-0x73dfeffc>
    80002254:	00813483          	ld	s1,8(sp)
    80002258:	02010113          	addi	sp,sp,32
    8000225c:	00008067          	ret

0000000080002260 <consolewrite>:
    80002260:	fb010113          	addi	sp,sp,-80
    80002264:	04813023          	sd	s0,64(sp)
    80002268:	04113423          	sd	ra,72(sp)
    8000226c:	02913c23          	sd	s1,56(sp)
    80002270:	03213823          	sd	s2,48(sp)
    80002274:	03313423          	sd	s3,40(sp)
    80002278:	03413023          	sd	s4,32(sp)
    8000227c:	01513c23          	sd	s5,24(sp)
    80002280:	05010413          	addi	s0,sp,80
    80002284:	06c05c63          	blez	a2,800022fc <consolewrite+0x9c>
    80002288:	00060993          	mv	s3,a2
    8000228c:	00050a13          	mv	s4,a0
    80002290:	00058493          	mv	s1,a1
    80002294:	00000913          	li	s2,0
    80002298:	fff00a93          	li	s5,-1
    8000229c:	01c0006f          	j	800022b8 <consolewrite+0x58>
    800022a0:	fbf44503          	lbu	a0,-65(s0)
    800022a4:	0019091b          	addiw	s2,s2,1
    800022a8:	00148493          	addi	s1,s1,1
    800022ac:	00001097          	auipc	ra,0x1
    800022b0:	a9c080e7          	jalr	-1380(ra) # 80002d48 <uartputc>
    800022b4:	03298063          	beq	s3,s2,800022d4 <consolewrite+0x74>
    800022b8:	00048613          	mv	a2,s1
    800022bc:	00100693          	li	a3,1
    800022c0:	000a0593          	mv	a1,s4
    800022c4:	fbf40513          	addi	a0,s0,-65
    800022c8:	00000097          	auipc	ra,0x0
    800022cc:	9d8080e7          	jalr	-1576(ra) # 80001ca0 <either_copyin>
    800022d0:	fd5518e3          	bne	a0,s5,800022a0 <consolewrite+0x40>
    800022d4:	04813083          	ld	ra,72(sp)
    800022d8:	04013403          	ld	s0,64(sp)
    800022dc:	03813483          	ld	s1,56(sp)
    800022e0:	02813983          	ld	s3,40(sp)
    800022e4:	02013a03          	ld	s4,32(sp)
    800022e8:	01813a83          	ld	s5,24(sp)
    800022ec:	00090513          	mv	a0,s2
    800022f0:	03013903          	ld	s2,48(sp)
    800022f4:	05010113          	addi	sp,sp,80
    800022f8:	00008067          	ret
    800022fc:	00000913          	li	s2,0
    80002300:	fd5ff06f          	j	800022d4 <consolewrite+0x74>

0000000080002304 <consoleread>:
    80002304:	f9010113          	addi	sp,sp,-112
    80002308:	06813023          	sd	s0,96(sp)
    8000230c:	04913c23          	sd	s1,88(sp)
    80002310:	05213823          	sd	s2,80(sp)
    80002314:	05313423          	sd	s3,72(sp)
    80002318:	05413023          	sd	s4,64(sp)
    8000231c:	03513c23          	sd	s5,56(sp)
    80002320:	03613823          	sd	s6,48(sp)
    80002324:	03713423          	sd	s7,40(sp)
    80002328:	03813023          	sd	s8,32(sp)
    8000232c:	06113423          	sd	ra,104(sp)
    80002330:	01913c23          	sd	s9,24(sp)
    80002334:	07010413          	addi	s0,sp,112
    80002338:	00060b93          	mv	s7,a2
    8000233c:	00050913          	mv	s2,a0
    80002340:	00058c13          	mv	s8,a1
    80002344:	00060b1b          	sext.w	s6,a2
    80002348:	00003497          	auipc	s1,0x3
    8000234c:	45048493          	addi	s1,s1,1104 # 80005798 <cons>
    80002350:	00400993          	li	s3,4
    80002354:	fff00a13          	li	s4,-1
    80002358:	00a00a93          	li	s5,10
    8000235c:	05705e63          	blez	s7,800023b8 <consoleread+0xb4>
    80002360:	09c4a703          	lw	a4,156(s1)
    80002364:	0984a783          	lw	a5,152(s1)
    80002368:	0007071b          	sext.w	a4,a4
    8000236c:	08e78463          	beq	a5,a4,800023f4 <consoleread+0xf0>
    80002370:	07f7f713          	andi	a4,a5,127
    80002374:	00e48733          	add	a4,s1,a4
    80002378:	01874703          	lbu	a4,24(a4) # c201018 <_entry-0x73dfefe8>
    8000237c:	0017869b          	addiw	a3,a5,1
    80002380:	08d4ac23          	sw	a3,152(s1)
    80002384:	00070c9b          	sext.w	s9,a4
    80002388:	0b370663          	beq	a4,s3,80002434 <consoleread+0x130>
    8000238c:	00100693          	li	a3,1
    80002390:	f9f40613          	addi	a2,s0,-97
    80002394:	000c0593          	mv	a1,s8
    80002398:	00090513          	mv	a0,s2
    8000239c:	f8e40fa3          	sb	a4,-97(s0)
    800023a0:	00000097          	auipc	ra,0x0
    800023a4:	8b4080e7          	jalr	-1868(ra) # 80001c54 <either_copyout>
    800023a8:	01450863          	beq	a0,s4,800023b8 <consoleread+0xb4>
    800023ac:	001c0c13          	addi	s8,s8,1
    800023b0:	fffb8b9b          	addiw	s7,s7,-1
    800023b4:	fb5c94e3          	bne	s9,s5,8000235c <consoleread+0x58>
    800023b8:	000b851b          	sext.w	a0,s7
    800023bc:	06813083          	ld	ra,104(sp)
    800023c0:	06013403          	ld	s0,96(sp)
    800023c4:	05813483          	ld	s1,88(sp)
    800023c8:	05013903          	ld	s2,80(sp)
    800023cc:	04813983          	ld	s3,72(sp)
    800023d0:	04013a03          	ld	s4,64(sp)
    800023d4:	03813a83          	ld	s5,56(sp)
    800023d8:	02813b83          	ld	s7,40(sp)
    800023dc:	02013c03          	ld	s8,32(sp)
    800023e0:	01813c83          	ld	s9,24(sp)
    800023e4:	40ab053b          	subw	a0,s6,a0
    800023e8:	03013b03          	ld	s6,48(sp)
    800023ec:	07010113          	addi	sp,sp,112
    800023f0:	00008067          	ret
    800023f4:	00001097          	auipc	ra,0x1
    800023f8:	1d8080e7          	jalr	472(ra) # 800035cc <push_on>
    800023fc:	0984a703          	lw	a4,152(s1)
    80002400:	09c4a783          	lw	a5,156(s1)
    80002404:	0007879b          	sext.w	a5,a5
    80002408:	fef70ce3          	beq	a4,a5,80002400 <consoleread+0xfc>
    8000240c:	00001097          	auipc	ra,0x1
    80002410:	234080e7          	jalr	564(ra) # 80003640 <pop_on>
    80002414:	0984a783          	lw	a5,152(s1)
    80002418:	07f7f713          	andi	a4,a5,127
    8000241c:	00e48733          	add	a4,s1,a4
    80002420:	01874703          	lbu	a4,24(a4)
    80002424:	0017869b          	addiw	a3,a5,1
    80002428:	08d4ac23          	sw	a3,152(s1)
    8000242c:	00070c9b          	sext.w	s9,a4
    80002430:	f5371ee3          	bne	a4,s3,8000238c <consoleread+0x88>
    80002434:	000b851b          	sext.w	a0,s7
    80002438:	f96bf2e3          	bgeu	s7,s6,800023bc <consoleread+0xb8>
    8000243c:	08f4ac23          	sw	a5,152(s1)
    80002440:	f7dff06f          	j	800023bc <consoleread+0xb8>

0000000080002444 <consputc>:
    80002444:	10000793          	li	a5,256
    80002448:	00f50663          	beq	a0,a5,80002454 <consputc+0x10>
    8000244c:	00001317          	auipc	t1,0x1
    80002450:	9f430067          	jr	-1548(t1) # 80002e40 <uartputc_sync>
    80002454:	ff010113          	addi	sp,sp,-16
    80002458:	00113423          	sd	ra,8(sp)
    8000245c:	00813023          	sd	s0,0(sp)
    80002460:	01010413          	addi	s0,sp,16
    80002464:	00800513          	li	a0,8
    80002468:	00001097          	auipc	ra,0x1
    8000246c:	9d8080e7          	jalr	-1576(ra) # 80002e40 <uartputc_sync>
    80002470:	02000513          	li	a0,32
    80002474:	00001097          	auipc	ra,0x1
    80002478:	9cc080e7          	jalr	-1588(ra) # 80002e40 <uartputc_sync>
    8000247c:	00013403          	ld	s0,0(sp)
    80002480:	00813083          	ld	ra,8(sp)
    80002484:	00800513          	li	a0,8
    80002488:	01010113          	addi	sp,sp,16
    8000248c:	00001317          	auipc	t1,0x1
    80002490:	9b430067          	jr	-1612(t1) # 80002e40 <uartputc_sync>

0000000080002494 <consoleintr>:
    80002494:	fe010113          	addi	sp,sp,-32
    80002498:	00813823          	sd	s0,16(sp)
    8000249c:	00913423          	sd	s1,8(sp)
    800024a0:	01213023          	sd	s2,0(sp)
    800024a4:	00113c23          	sd	ra,24(sp)
    800024a8:	02010413          	addi	s0,sp,32
    800024ac:	00003917          	auipc	s2,0x3
    800024b0:	2ec90913          	addi	s2,s2,748 # 80005798 <cons>
    800024b4:	00050493          	mv	s1,a0
    800024b8:	00090513          	mv	a0,s2
    800024bc:	00001097          	auipc	ra,0x1
    800024c0:	e40080e7          	jalr	-448(ra) # 800032fc <acquire>
    800024c4:	02048c63          	beqz	s1,800024fc <consoleintr+0x68>
    800024c8:	0a092783          	lw	a5,160(s2)
    800024cc:	09892703          	lw	a4,152(s2)
    800024d0:	07f00693          	li	a3,127
    800024d4:	40e7873b          	subw	a4,a5,a4
    800024d8:	02e6e263          	bltu	a3,a4,800024fc <consoleintr+0x68>
    800024dc:	00d00713          	li	a4,13
    800024e0:	04e48063          	beq	s1,a4,80002520 <consoleintr+0x8c>
    800024e4:	07f7f713          	andi	a4,a5,127
    800024e8:	00e90733          	add	a4,s2,a4
    800024ec:	0017879b          	addiw	a5,a5,1
    800024f0:	0af92023          	sw	a5,160(s2)
    800024f4:	00970c23          	sb	s1,24(a4)
    800024f8:	08f92e23          	sw	a5,156(s2)
    800024fc:	01013403          	ld	s0,16(sp)
    80002500:	01813083          	ld	ra,24(sp)
    80002504:	00813483          	ld	s1,8(sp)
    80002508:	00013903          	ld	s2,0(sp)
    8000250c:	00003517          	auipc	a0,0x3
    80002510:	28c50513          	addi	a0,a0,652 # 80005798 <cons>
    80002514:	02010113          	addi	sp,sp,32
    80002518:	00001317          	auipc	t1,0x1
    8000251c:	eb030067          	jr	-336(t1) # 800033c8 <release>
    80002520:	00a00493          	li	s1,10
    80002524:	fc1ff06f          	j	800024e4 <consoleintr+0x50>

0000000080002528 <consoleinit>:
    80002528:	fe010113          	addi	sp,sp,-32
    8000252c:	00113c23          	sd	ra,24(sp)
    80002530:	00813823          	sd	s0,16(sp)
    80002534:	00913423          	sd	s1,8(sp)
    80002538:	02010413          	addi	s0,sp,32
    8000253c:	00003497          	auipc	s1,0x3
    80002540:	25c48493          	addi	s1,s1,604 # 80005798 <cons>
    80002544:	00048513          	mv	a0,s1
    80002548:	00002597          	auipc	a1,0x2
    8000254c:	d6058593          	addi	a1,a1,-672 # 800042a8 <CONSOLE_STATUS+0x298>
    80002550:	00001097          	auipc	ra,0x1
    80002554:	d88080e7          	jalr	-632(ra) # 800032d8 <initlock>
    80002558:	00000097          	auipc	ra,0x0
    8000255c:	7ac080e7          	jalr	1964(ra) # 80002d04 <uartinit>
    80002560:	01813083          	ld	ra,24(sp)
    80002564:	01013403          	ld	s0,16(sp)
    80002568:	00000797          	auipc	a5,0x0
    8000256c:	d9c78793          	addi	a5,a5,-612 # 80002304 <consoleread>
    80002570:	0af4bc23          	sd	a5,184(s1)
    80002574:	00000797          	auipc	a5,0x0
    80002578:	cec78793          	addi	a5,a5,-788 # 80002260 <consolewrite>
    8000257c:	0cf4b023          	sd	a5,192(s1)
    80002580:	00813483          	ld	s1,8(sp)
    80002584:	02010113          	addi	sp,sp,32
    80002588:	00008067          	ret

000000008000258c <console_read>:
    8000258c:	ff010113          	addi	sp,sp,-16
    80002590:	00813423          	sd	s0,8(sp)
    80002594:	01010413          	addi	s0,sp,16
    80002598:	00813403          	ld	s0,8(sp)
    8000259c:	00003317          	auipc	t1,0x3
    800025a0:	2b433303          	ld	t1,692(t1) # 80005850 <devsw+0x10>
    800025a4:	01010113          	addi	sp,sp,16
    800025a8:	00030067          	jr	t1

00000000800025ac <console_write>:
    800025ac:	ff010113          	addi	sp,sp,-16
    800025b0:	00813423          	sd	s0,8(sp)
    800025b4:	01010413          	addi	s0,sp,16
    800025b8:	00813403          	ld	s0,8(sp)
    800025bc:	00003317          	auipc	t1,0x3
    800025c0:	29c33303          	ld	t1,668(t1) # 80005858 <devsw+0x18>
    800025c4:	01010113          	addi	sp,sp,16
    800025c8:	00030067          	jr	t1

00000000800025cc <panic>:
    800025cc:	fe010113          	addi	sp,sp,-32
    800025d0:	00113c23          	sd	ra,24(sp)
    800025d4:	00813823          	sd	s0,16(sp)
    800025d8:	00913423          	sd	s1,8(sp)
    800025dc:	02010413          	addi	s0,sp,32
    800025e0:	00050493          	mv	s1,a0
    800025e4:	00002517          	auipc	a0,0x2
    800025e8:	ccc50513          	addi	a0,a0,-820 # 800042b0 <CONSOLE_STATUS+0x2a0>
    800025ec:	00003797          	auipc	a5,0x3
    800025f0:	3007a623          	sw	zero,780(a5) # 800058f8 <pr+0x18>
    800025f4:	00000097          	auipc	ra,0x0
    800025f8:	034080e7          	jalr	52(ra) # 80002628 <__printf>
    800025fc:	00048513          	mv	a0,s1
    80002600:	00000097          	auipc	ra,0x0
    80002604:	028080e7          	jalr	40(ra) # 80002628 <__printf>
    80002608:	00002517          	auipc	a0,0x2
    8000260c:	ab050513          	addi	a0,a0,-1360 # 800040b8 <CONSOLE_STATUS+0xa8>
    80002610:	00000097          	auipc	ra,0x0
    80002614:	018080e7          	jalr	24(ra) # 80002628 <__printf>
    80002618:	00100793          	li	a5,1
    8000261c:	00002717          	auipc	a4,0x2
    80002620:	08f72623          	sw	a5,140(a4) # 800046a8 <panicked>
    80002624:	0000006f          	j	80002624 <panic+0x58>

0000000080002628 <__printf>:
    80002628:	f3010113          	addi	sp,sp,-208
    8000262c:	08813023          	sd	s0,128(sp)
    80002630:	07313423          	sd	s3,104(sp)
    80002634:	09010413          	addi	s0,sp,144
    80002638:	05813023          	sd	s8,64(sp)
    8000263c:	08113423          	sd	ra,136(sp)
    80002640:	06913c23          	sd	s1,120(sp)
    80002644:	07213823          	sd	s2,112(sp)
    80002648:	07413023          	sd	s4,96(sp)
    8000264c:	05513c23          	sd	s5,88(sp)
    80002650:	05613823          	sd	s6,80(sp)
    80002654:	05713423          	sd	s7,72(sp)
    80002658:	03913c23          	sd	s9,56(sp)
    8000265c:	03a13823          	sd	s10,48(sp)
    80002660:	03b13423          	sd	s11,40(sp)
    80002664:	00003317          	auipc	t1,0x3
    80002668:	27c30313          	addi	t1,t1,636 # 800058e0 <pr>
    8000266c:	01832c03          	lw	s8,24(t1)
    80002670:	00b43423          	sd	a1,8(s0)
    80002674:	00c43823          	sd	a2,16(s0)
    80002678:	00d43c23          	sd	a3,24(s0)
    8000267c:	02e43023          	sd	a4,32(s0)
    80002680:	02f43423          	sd	a5,40(s0)
    80002684:	03043823          	sd	a6,48(s0)
    80002688:	03143c23          	sd	a7,56(s0)
    8000268c:	00050993          	mv	s3,a0
    80002690:	4a0c1663          	bnez	s8,80002b3c <__printf+0x514>
    80002694:	60098c63          	beqz	s3,80002cac <__printf+0x684>
    80002698:	0009c503          	lbu	a0,0(s3)
    8000269c:	00840793          	addi	a5,s0,8
    800026a0:	f6f43c23          	sd	a5,-136(s0)
    800026a4:	00000493          	li	s1,0
    800026a8:	22050063          	beqz	a0,800028c8 <__printf+0x2a0>
    800026ac:	00002a37          	lui	s4,0x2
    800026b0:	00018ab7          	lui	s5,0x18
    800026b4:	000f4b37          	lui	s6,0xf4
    800026b8:	00989bb7          	lui	s7,0x989
    800026bc:	70fa0a13          	addi	s4,s4,1807 # 270f <_entry-0x7fffd8f1>
    800026c0:	69fa8a93          	addi	s5,s5,1695 # 1869f <_entry-0x7ffe7961>
    800026c4:	23fb0b13          	addi	s6,s6,575 # f423f <_entry-0x7ff0bdc1>
    800026c8:	67fb8b93          	addi	s7,s7,1663 # 98967f <_entry-0x7f676981>
    800026cc:	00148c9b          	addiw	s9,s1,1
    800026d0:	02500793          	li	a5,37
    800026d4:	01998933          	add	s2,s3,s9
    800026d8:	38f51263          	bne	a0,a5,80002a5c <__printf+0x434>
    800026dc:	00094783          	lbu	a5,0(s2)
    800026e0:	00078c9b          	sext.w	s9,a5
    800026e4:	1e078263          	beqz	a5,800028c8 <__printf+0x2a0>
    800026e8:	0024849b          	addiw	s1,s1,2
    800026ec:	07000713          	li	a4,112
    800026f0:	00998933          	add	s2,s3,s1
    800026f4:	38e78a63          	beq	a5,a4,80002a88 <__printf+0x460>
    800026f8:	20f76863          	bltu	a4,a5,80002908 <__printf+0x2e0>
    800026fc:	42a78863          	beq	a5,a0,80002b2c <__printf+0x504>
    80002700:	06400713          	li	a4,100
    80002704:	40e79663          	bne	a5,a4,80002b10 <__printf+0x4e8>
    80002708:	f7843783          	ld	a5,-136(s0)
    8000270c:	0007a603          	lw	a2,0(a5)
    80002710:	00878793          	addi	a5,a5,8
    80002714:	f6f43c23          	sd	a5,-136(s0)
    80002718:	42064a63          	bltz	a2,80002b4c <__printf+0x524>
    8000271c:	00a00713          	li	a4,10
    80002720:	02e677bb          	remuw	a5,a2,a4
    80002724:	00002d97          	auipc	s11,0x2
    80002728:	bb4d8d93          	addi	s11,s11,-1100 # 800042d8 <digits>
    8000272c:	00900593          	li	a1,9
    80002730:	0006051b          	sext.w	a0,a2
    80002734:	00000c93          	li	s9,0
    80002738:	02079793          	slli	a5,a5,0x20
    8000273c:	0207d793          	srli	a5,a5,0x20
    80002740:	00fd87b3          	add	a5,s11,a5
    80002744:	0007c783          	lbu	a5,0(a5)
    80002748:	02e656bb          	divuw	a3,a2,a4
    8000274c:	f8f40023          	sb	a5,-128(s0)
    80002750:	14c5d863          	bge	a1,a2,800028a0 <__printf+0x278>
    80002754:	06300593          	li	a1,99
    80002758:	00100c93          	li	s9,1
    8000275c:	02e6f7bb          	remuw	a5,a3,a4
    80002760:	02079793          	slli	a5,a5,0x20
    80002764:	0207d793          	srli	a5,a5,0x20
    80002768:	00fd87b3          	add	a5,s11,a5
    8000276c:	0007c783          	lbu	a5,0(a5)
    80002770:	02e6d73b          	divuw	a4,a3,a4
    80002774:	f8f400a3          	sb	a5,-127(s0)
    80002778:	12a5f463          	bgeu	a1,a0,800028a0 <__printf+0x278>
    8000277c:	00a00693          	li	a3,10
    80002780:	00900593          	li	a1,9
    80002784:	02d777bb          	remuw	a5,a4,a3
    80002788:	02079793          	slli	a5,a5,0x20
    8000278c:	0207d793          	srli	a5,a5,0x20
    80002790:	00fd87b3          	add	a5,s11,a5
    80002794:	0007c503          	lbu	a0,0(a5)
    80002798:	02d757bb          	divuw	a5,a4,a3
    8000279c:	f8a40123          	sb	a0,-126(s0)
    800027a0:	48e5f263          	bgeu	a1,a4,80002c24 <__printf+0x5fc>
    800027a4:	06300513          	li	a0,99
    800027a8:	02d7f5bb          	remuw	a1,a5,a3
    800027ac:	02059593          	slli	a1,a1,0x20
    800027b0:	0205d593          	srli	a1,a1,0x20
    800027b4:	00bd85b3          	add	a1,s11,a1
    800027b8:	0005c583          	lbu	a1,0(a1)
    800027bc:	02d7d7bb          	divuw	a5,a5,a3
    800027c0:	f8b401a3          	sb	a1,-125(s0)
    800027c4:	48e57263          	bgeu	a0,a4,80002c48 <__printf+0x620>
    800027c8:	3e700513          	li	a0,999
    800027cc:	02d7f5bb          	remuw	a1,a5,a3
    800027d0:	02059593          	slli	a1,a1,0x20
    800027d4:	0205d593          	srli	a1,a1,0x20
    800027d8:	00bd85b3          	add	a1,s11,a1
    800027dc:	0005c583          	lbu	a1,0(a1)
    800027e0:	02d7d7bb          	divuw	a5,a5,a3
    800027e4:	f8b40223          	sb	a1,-124(s0)
    800027e8:	46e57663          	bgeu	a0,a4,80002c54 <__printf+0x62c>
    800027ec:	02d7f5bb          	remuw	a1,a5,a3
    800027f0:	02059593          	slli	a1,a1,0x20
    800027f4:	0205d593          	srli	a1,a1,0x20
    800027f8:	00bd85b3          	add	a1,s11,a1
    800027fc:	0005c583          	lbu	a1,0(a1)
    80002800:	02d7d7bb          	divuw	a5,a5,a3
    80002804:	f8b402a3          	sb	a1,-123(s0)
    80002808:	46ea7863          	bgeu	s4,a4,80002c78 <__printf+0x650>
    8000280c:	02d7f5bb          	remuw	a1,a5,a3
    80002810:	02059593          	slli	a1,a1,0x20
    80002814:	0205d593          	srli	a1,a1,0x20
    80002818:	00bd85b3          	add	a1,s11,a1
    8000281c:	0005c583          	lbu	a1,0(a1)
    80002820:	02d7d7bb          	divuw	a5,a5,a3
    80002824:	f8b40323          	sb	a1,-122(s0)
    80002828:	3eeaf863          	bgeu	s5,a4,80002c18 <__printf+0x5f0>
    8000282c:	02d7f5bb          	remuw	a1,a5,a3
    80002830:	02059593          	slli	a1,a1,0x20
    80002834:	0205d593          	srli	a1,a1,0x20
    80002838:	00bd85b3          	add	a1,s11,a1
    8000283c:	0005c583          	lbu	a1,0(a1)
    80002840:	02d7d7bb          	divuw	a5,a5,a3
    80002844:	f8b403a3          	sb	a1,-121(s0)
    80002848:	42eb7e63          	bgeu	s6,a4,80002c84 <__printf+0x65c>
    8000284c:	02d7f5bb          	remuw	a1,a5,a3
    80002850:	02059593          	slli	a1,a1,0x20
    80002854:	0205d593          	srli	a1,a1,0x20
    80002858:	00bd85b3          	add	a1,s11,a1
    8000285c:	0005c583          	lbu	a1,0(a1)
    80002860:	02d7d7bb          	divuw	a5,a5,a3
    80002864:	f8b40423          	sb	a1,-120(s0)
    80002868:	42ebfc63          	bgeu	s7,a4,80002ca0 <__printf+0x678>
    8000286c:	02079793          	slli	a5,a5,0x20
    80002870:	0207d793          	srli	a5,a5,0x20
    80002874:	00fd8db3          	add	s11,s11,a5
    80002878:	000dc703          	lbu	a4,0(s11)
    8000287c:	00a00793          	li	a5,10
    80002880:	00900c93          	li	s9,9
    80002884:	f8e404a3          	sb	a4,-119(s0)
    80002888:	00065c63          	bgez	a2,800028a0 <__printf+0x278>
    8000288c:	f9040713          	addi	a4,s0,-112
    80002890:	00f70733          	add	a4,a4,a5
    80002894:	02d00693          	li	a3,45
    80002898:	fed70823          	sb	a3,-16(a4)
    8000289c:	00078c93          	mv	s9,a5
    800028a0:	f8040793          	addi	a5,s0,-128
    800028a4:	01978cb3          	add	s9,a5,s9
    800028a8:	f7f40d13          	addi	s10,s0,-129
    800028ac:	000cc503          	lbu	a0,0(s9)
    800028b0:	fffc8c93          	addi	s9,s9,-1
    800028b4:	00000097          	auipc	ra,0x0
    800028b8:	b90080e7          	jalr	-1136(ra) # 80002444 <consputc>
    800028bc:	ffac98e3          	bne	s9,s10,800028ac <__printf+0x284>
    800028c0:	00094503          	lbu	a0,0(s2)
    800028c4:	e00514e3          	bnez	a0,800026cc <__printf+0xa4>
    800028c8:	1a0c1663          	bnez	s8,80002a74 <__printf+0x44c>
    800028cc:	08813083          	ld	ra,136(sp)
    800028d0:	08013403          	ld	s0,128(sp)
    800028d4:	07813483          	ld	s1,120(sp)
    800028d8:	07013903          	ld	s2,112(sp)
    800028dc:	06813983          	ld	s3,104(sp)
    800028e0:	06013a03          	ld	s4,96(sp)
    800028e4:	05813a83          	ld	s5,88(sp)
    800028e8:	05013b03          	ld	s6,80(sp)
    800028ec:	04813b83          	ld	s7,72(sp)
    800028f0:	04013c03          	ld	s8,64(sp)
    800028f4:	03813c83          	ld	s9,56(sp)
    800028f8:	03013d03          	ld	s10,48(sp)
    800028fc:	02813d83          	ld	s11,40(sp)
    80002900:	0d010113          	addi	sp,sp,208
    80002904:	00008067          	ret
    80002908:	07300713          	li	a4,115
    8000290c:	1ce78a63          	beq	a5,a4,80002ae0 <__printf+0x4b8>
    80002910:	07800713          	li	a4,120
    80002914:	1ee79e63          	bne	a5,a4,80002b10 <__printf+0x4e8>
    80002918:	f7843783          	ld	a5,-136(s0)
    8000291c:	0007a703          	lw	a4,0(a5)
    80002920:	00878793          	addi	a5,a5,8
    80002924:	f6f43c23          	sd	a5,-136(s0)
    80002928:	28074263          	bltz	a4,80002bac <__printf+0x584>
    8000292c:	00002d97          	auipc	s11,0x2
    80002930:	9acd8d93          	addi	s11,s11,-1620 # 800042d8 <digits>
    80002934:	00f77793          	andi	a5,a4,15
    80002938:	00fd87b3          	add	a5,s11,a5
    8000293c:	0007c683          	lbu	a3,0(a5)
    80002940:	00f00613          	li	a2,15
    80002944:	0007079b          	sext.w	a5,a4
    80002948:	f8d40023          	sb	a3,-128(s0)
    8000294c:	0047559b          	srliw	a1,a4,0x4
    80002950:	0047569b          	srliw	a3,a4,0x4
    80002954:	00000c93          	li	s9,0
    80002958:	0ee65063          	bge	a2,a4,80002a38 <__printf+0x410>
    8000295c:	00f6f693          	andi	a3,a3,15
    80002960:	00dd86b3          	add	a3,s11,a3
    80002964:	0006c683          	lbu	a3,0(a3) # 2004000 <_entry-0x7dffc000>
    80002968:	0087d79b          	srliw	a5,a5,0x8
    8000296c:	00100c93          	li	s9,1
    80002970:	f8d400a3          	sb	a3,-127(s0)
    80002974:	0cb67263          	bgeu	a2,a1,80002a38 <__printf+0x410>
    80002978:	00f7f693          	andi	a3,a5,15
    8000297c:	00dd86b3          	add	a3,s11,a3
    80002980:	0006c583          	lbu	a1,0(a3)
    80002984:	00f00613          	li	a2,15
    80002988:	0047d69b          	srliw	a3,a5,0x4
    8000298c:	f8b40123          	sb	a1,-126(s0)
    80002990:	0047d593          	srli	a1,a5,0x4
    80002994:	28f67e63          	bgeu	a2,a5,80002c30 <__printf+0x608>
    80002998:	00f6f693          	andi	a3,a3,15
    8000299c:	00dd86b3          	add	a3,s11,a3
    800029a0:	0006c503          	lbu	a0,0(a3)
    800029a4:	0087d813          	srli	a6,a5,0x8
    800029a8:	0087d69b          	srliw	a3,a5,0x8
    800029ac:	f8a401a3          	sb	a0,-125(s0)
    800029b0:	28b67663          	bgeu	a2,a1,80002c3c <__printf+0x614>
    800029b4:	00f6f693          	andi	a3,a3,15
    800029b8:	00dd86b3          	add	a3,s11,a3
    800029bc:	0006c583          	lbu	a1,0(a3)
    800029c0:	00c7d513          	srli	a0,a5,0xc
    800029c4:	00c7d69b          	srliw	a3,a5,0xc
    800029c8:	f8b40223          	sb	a1,-124(s0)
    800029cc:	29067a63          	bgeu	a2,a6,80002c60 <__printf+0x638>
    800029d0:	00f6f693          	andi	a3,a3,15
    800029d4:	00dd86b3          	add	a3,s11,a3
    800029d8:	0006c583          	lbu	a1,0(a3)
    800029dc:	0107d813          	srli	a6,a5,0x10
    800029e0:	0107d69b          	srliw	a3,a5,0x10
    800029e4:	f8b402a3          	sb	a1,-123(s0)
    800029e8:	28a67263          	bgeu	a2,a0,80002c6c <__printf+0x644>
    800029ec:	00f6f693          	andi	a3,a3,15
    800029f0:	00dd86b3          	add	a3,s11,a3
    800029f4:	0006c683          	lbu	a3,0(a3)
    800029f8:	0147d79b          	srliw	a5,a5,0x14
    800029fc:	f8d40323          	sb	a3,-122(s0)
    80002a00:	21067663          	bgeu	a2,a6,80002c0c <__printf+0x5e4>
    80002a04:	02079793          	slli	a5,a5,0x20
    80002a08:	0207d793          	srli	a5,a5,0x20
    80002a0c:	00fd8db3          	add	s11,s11,a5
    80002a10:	000dc683          	lbu	a3,0(s11)
    80002a14:	00800793          	li	a5,8
    80002a18:	00700c93          	li	s9,7
    80002a1c:	f8d403a3          	sb	a3,-121(s0)
    80002a20:	00075c63          	bgez	a4,80002a38 <__printf+0x410>
    80002a24:	f9040713          	addi	a4,s0,-112
    80002a28:	00f70733          	add	a4,a4,a5
    80002a2c:	02d00693          	li	a3,45
    80002a30:	fed70823          	sb	a3,-16(a4)
    80002a34:	00078c93          	mv	s9,a5
    80002a38:	f8040793          	addi	a5,s0,-128
    80002a3c:	01978cb3          	add	s9,a5,s9
    80002a40:	f7f40d13          	addi	s10,s0,-129
    80002a44:	000cc503          	lbu	a0,0(s9)
    80002a48:	fffc8c93          	addi	s9,s9,-1
    80002a4c:	00000097          	auipc	ra,0x0
    80002a50:	9f8080e7          	jalr	-1544(ra) # 80002444 <consputc>
    80002a54:	ff9d18e3          	bne	s10,s9,80002a44 <__printf+0x41c>
    80002a58:	0100006f          	j	80002a68 <__printf+0x440>
    80002a5c:	00000097          	auipc	ra,0x0
    80002a60:	9e8080e7          	jalr	-1560(ra) # 80002444 <consputc>
    80002a64:	000c8493          	mv	s1,s9
    80002a68:	00094503          	lbu	a0,0(s2)
    80002a6c:	c60510e3          	bnez	a0,800026cc <__printf+0xa4>
    80002a70:	e40c0ee3          	beqz	s8,800028cc <__printf+0x2a4>
    80002a74:	00003517          	auipc	a0,0x3
    80002a78:	e6c50513          	addi	a0,a0,-404 # 800058e0 <pr>
    80002a7c:	00001097          	auipc	ra,0x1
    80002a80:	94c080e7          	jalr	-1716(ra) # 800033c8 <release>
    80002a84:	e49ff06f          	j	800028cc <__printf+0x2a4>
    80002a88:	f7843783          	ld	a5,-136(s0)
    80002a8c:	03000513          	li	a0,48
    80002a90:	01000d13          	li	s10,16
    80002a94:	00878713          	addi	a4,a5,8
    80002a98:	0007bc83          	ld	s9,0(a5)
    80002a9c:	f6e43c23          	sd	a4,-136(s0)
    80002aa0:	00000097          	auipc	ra,0x0
    80002aa4:	9a4080e7          	jalr	-1628(ra) # 80002444 <consputc>
    80002aa8:	07800513          	li	a0,120
    80002aac:	00000097          	auipc	ra,0x0
    80002ab0:	998080e7          	jalr	-1640(ra) # 80002444 <consputc>
    80002ab4:	00002d97          	auipc	s11,0x2
    80002ab8:	824d8d93          	addi	s11,s11,-2012 # 800042d8 <digits>
    80002abc:	03ccd793          	srli	a5,s9,0x3c
    80002ac0:	00fd87b3          	add	a5,s11,a5
    80002ac4:	0007c503          	lbu	a0,0(a5)
    80002ac8:	fffd0d1b          	addiw	s10,s10,-1
    80002acc:	004c9c93          	slli	s9,s9,0x4
    80002ad0:	00000097          	auipc	ra,0x0
    80002ad4:	974080e7          	jalr	-1676(ra) # 80002444 <consputc>
    80002ad8:	fe0d12e3          	bnez	s10,80002abc <__printf+0x494>
    80002adc:	f8dff06f          	j	80002a68 <__printf+0x440>
    80002ae0:	f7843783          	ld	a5,-136(s0)
    80002ae4:	0007bc83          	ld	s9,0(a5)
    80002ae8:	00878793          	addi	a5,a5,8
    80002aec:	f6f43c23          	sd	a5,-136(s0)
    80002af0:	000c9a63          	bnez	s9,80002b04 <__printf+0x4dc>
    80002af4:	1080006f          	j	80002bfc <__printf+0x5d4>
    80002af8:	001c8c93          	addi	s9,s9,1
    80002afc:	00000097          	auipc	ra,0x0
    80002b00:	948080e7          	jalr	-1720(ra) # 80002444 <consputc>
    80002b04:	000cc503          	lbu	a0,0(s9)
    80002b08:	fe0518e3          	bnez	a0,80002af8 <__printf+0x4d0>
    80002b0c:	f5dff06f          	j	80002a68 <__printf+0x440>
    80002b10:	02500513          	li	a0,37
    80002b14:	00000097          	auipc	ra,0x0
    80002b18:	930080e7          	jalr	-1744(ra) # 80002444 <consputc>
    80002b1c:	000c8513          	mv	a0,s9
    80002b20:	00000097          	auipc	ra,0x0
    80002b24:	924080e7          	jalr	-1756(ra) # 80002444 <consputc>
    80002b28:	f41ff06f          	j	80002a68 <__printf+0x440>
    80002b2c:	02500513          	li	a0,37
    80002b30:	00000097          	auipc	ra,0x0
    80002b34:	914080e7          	jalr	-1772(ra) # 80002444 <consputc>
    80002b38:	f31ff06f          	j	80002a68 <__printf+0x440>
    80002b3c:	00030513          	mv	a0,t1
    80002b40:	00000097          	auipc	ra,0x0
    80002b44:	7bc080e7          	jalr	1980(ra) # 800032fc <acquire>
    80002b48:	b4dff06f          	j	80002694 <__printf+0x6c>
    80002b4c:	40c0053b          	negw	a0,a2
    80002b50:	00a00713          	li	a4,10
    80002b54:	02e576bb          	remuw	a3,a0,a4
    80002b58:	00001d97          	auipc	s11,0x1
    80002b5c:	780d8d93          	addi	s11,s11,1920 # 800042d8 <digits>
    80002b60:	ff700593          	li	a1,-9
    80002b64:	02069693          	slli	a3,a3,0x20
    80002b68:	0206d693          	srli	a3,a3,0x20
    80002b6c:	00dd86b3          	add	a3,s11,a3
    80002b70:	0006c683          	lbu	a3,0(a3)
    80002b74:	02e557bb          	divuw	a5,a0,a4
    80002b78:	f8d40023          	sb	a3,-128(s0)
    80002b7c:	10b65e63          	bge	a2,a1,80002c98 <__printf+0x670>
    80002b80:	06300593          	li	a1,99
    80002b84:	02e7f6bb          	remuw	a3,a5,a4
    80002b88:	02069693          	slli	a3,a3,0x20
    80002b8c:	0206d693          	srli	a3,a3,0x20
    80002b90:	00dd86b3          	add	a3,s11,a3
    80002b94:	0006c683          	lbu	a3,0(a3)
    80002b98:	02e7d73b          	divuw	a4,a5,a4
    80002b9c:	00200793          	li	a5,2
    80002ba0:	f8d400a3          	sb	a3,-127(s0)
    80002ba4:	bca5ece3          	bltu	a1,a0,8000277c <__printf+0x154>
    80002ba8:	ce5ff06f          	j	8000288c <__printf+0x264>
    80002bac:	40e007bb          	negw	a5,a4
    80002bb0:	00001d97          	auipc	s11,0x1
    80002bb4:	728d8d93          	addi	s11,s11,1832 # 800042d8 <digits>
    80002bb8:	00f7f693          	andi	a3,a5,15
    80002bbc:	00dd86b3          	add	a3,s11,a3
    80002bc0:	0006c583          	lbu	a1,0(a3)
    80002bc4:	ff100613          	li	a2,-15
    80002bc8:	0047d69b          	srliw	a3,a5,0x4
    80002bcc:	f8b40023          	sb	a1,-128(s0)
    80002bd0:	0047d59b          	srliw	a1,a5,0x4
    80002bd4:	0ac75e63          	bge	a4,a2,80002c90 <__printf+0x668>
    80002bd8:	00f6f693          	andi	a3,a3,15
    80002bdc:	00dd86b3          	add	a3,s11,a3
    80002be0:	0006c603          	lbu	a2,0(a3)
    80002be4:	00f00693          	li	a3,15
    80002be8:	0087d79b          	srliw	a5,a5,0x8
    80002bec:	f8c400a3          	sb	a2,-127(s0)
    80002bf0:	d8b6e4e3          	bltu	a3,a1,80002978 <__printf+0x350>
    80002bf4:	00200793          	li	a5,2
    80002bf8:	e2dff06f          	j	80002a24 <__printf+0x3fc>
    80002bfc:	00001c97          	auipc	s9,0x1
    80002c00:	6bcc8c93          	addi	s9,s9,1724 # 800042b8 <CONSOLE_STATUS+0x2a8>
    80002c04:	02800513          	li	a0,40
    80002c08:	ef1ff06f          	j	80002af8 <__printf+0x4d0>
    80002c0c:	00700793          	li	a5,7
    80002c10:	00600c93          	li	s9,6
    80002c14:	e0dff06f          	j	80002a20 <__printf+0x3f8>
    80002c18:	00700793          	li	a5,7
    80002c1c:	00600c93          	li	s9,6
    80002c20:	c69ff06f          	j	80002888 <__printf+0x260>
    80002c24:	00300793          	li	a5,3
    80002c28:	00200c93          	li	s9,2
    80002c2c:	c5dff06f          	j	80002888 <__printf+0x260>
    80002c30:	00300793          	li	a5,3
    80002c34:	00200c93          	li	s9,2
    80002c38:	de9ff06f          	j	80002a20 <__printf+0x3f8>
    80002c3c:	00400793          	li	a5,4
    80002c40:	00300c93          	li	s9,3
    80002c44:	dddff06f          	j	80002a20 <__printf+0x3f8>
    80002c48:	00400793          	li	a5,4
    80002c4c:	00300c93          	li	s9,3
    80002c50:	c39ff06f          	j	80002888 <__printf+0x260>
    80002c54:	00500793          	li	a5,5
    80002c58:	00400c93          	li	s9,4
    80002c5c:	c2dff06f          	j	80002888 <__printf+0x260>
    80002c60:	00500793          	li	a5,5
    80002c64:	00400c93          	li	s9,4
    80002c68:	db9ff06f          	j	80002a20 <__printf+0x3f8>
    80002c6c:	00600793          	li	a5,6
    80002c70:	00500c93          	li	s9,5
    80002c74:	dadff06f          	j	80002a20 <__printf+0x3f8>
    80002c78:	00600793          	li	a5,6
    80002c7c:	00500c93          	li	s9,5
    80002c80:	c09ff06f          	j	80002888 <__printf+0x260>
    80002c84:	00800793          	li	a5,8
    80002c88:	00700c93          	li	s9,7
    80002c8c:	bfdff06f          	j	80002888 <__printf+0x260>
    80002c90:	00100793          	li	a5,1
    80002c94:	d91ff06f          	j	80002a24 <__printf+0x3fc>
    80002c98:	00100793          	li	a5,1
    80002c9c:	bf1ff06f          	j	8000288c <__printf+0x264>
    80002ca0:	00900793          	li	a5,9
    80002ca4:	00800c93          	li	s9,8
    80002ca8:	be1ff06f          	j	80002888 <__printf+0x260>
    80002cac:	00001517          	auipc	a0,0x1
    80002cb0:	61450513          	addi	a0,a0,1556 # 800042c0 <CONSOLE_STATUS+0x2b0>
    80002cb4:	00000097          	auipc	ra,0x0
    80002cb8:	918080e7          	jalr	-1768(ra) # 800025cc <panic>

0000000080002cbc <printfinit>:
    80002cbc:	fe010113          	addi	sp,sp,-32
    80002cc0:	00813823          	sd	s0,16(sp)
    80002cc4:	00913423          	sd	s1,8(sp)
    80002cc8:	00113c23          	sd	ra,24(sp)
    80002ccc:	02010413          	addi	s0,sp,32
    80002cd0:	00003497          	auipc	s1,0x3
    80002cd4:	c1048493          	addi	s1,s1,-1008 # 800058e0 <pr>
    80002cd8:	00048513          	mv	a0,s1
    80002cdc:	00001597          	auipc	a1,0x1
    80002ce0:	5f458593          	addi	a1,a1,1524 # 800042d0 <CONSOLE_STATUS+0x2c0>
    80002ce4:	00000097          	auipc	ra,0x0
    80002ce8:	5f4080e7          	jalr	1524(ra) # 800032d8 <initlock>
    80002cec:	01813083          	ld	ra,24(sp)
    80002cf0:	01013403          	ld	s0,16(sp)
    80002cf4:	0004ac23          	sw	zero,24(s1)
    80002cf8:	00813483          	ld	s1,8(sp)
    80002cfc:	02010113          	addi	sp,sp,32
    80002d00:	00008067          	ret

0000000080002d04 <uartinit>:
    80002d04:	ff010113          	addi	sp,sp,-16
    80002d08:	00813423          	sd	s0,8(sp)
    80002d0c:	01010413          	addi	s0,sp,16
    80002d10:	100007b7          	lui	a5,0x10000
    80002d14:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>
    80002d18:	f8000713          	li	a4,-128
    80002d1c:	00e781a3          	sb	a4,3(a5)
    80002d20:	00300713          	li	a4,3
    80002d24:	00e78023          	sb	a4,0(a5)
    80002d28:	000780a3          	sb	zero,1(a5)
    80002d2c:	00e781a3          	sb	a4,3(a5)
    80002d30:	00700693          	li	a3,7
    80002d34:	00d78123          	sb	a3,2(a5)
    80002d38:	00e780a3          	sb	a4,1(a5)
    80002d3c:	00813403          	ld	s0,8(sp)
    80002d40:	01010113          	addi	sp,sp,16
    80002d44:	00008067          	ret

0000000080002d48 <uartputc>:
    80002d48:	00002797          	auipc	a5,0x2
    80002d4c:	9607a783          	lw	a5,-1696(a5) # 800046a8 <panicked>
    80002d50:	00078463          	beqz	a5,80002d58 <uartputc+0x10>
    80002d54:	0000006f          	j	80002d54 <uartputc+0xc>
    80002d58:	fd010113          	addi	sp,sp,-48
    80002d5c:	02813023          	sd	s0,32(sp)
    80002d60:	00913c23          	sd	s1,24(sp)
    80002d64:	01213823          	sd	s2,16(sp)
    80002d68:	01313423          	sd	s3,8(sp)
    80002d6c:	02113423          	sd	ra,40(sp)
    80002d70:	03010413          	addi	s0,sp,48
    80002d74:	00002917          	auipc	s2,0x2
    80002d78:	93c90913          	addi	s2,s2,-1732 # 800046b0 <uart_tx_r>
    80002d7c:	00093783          	ld	a5,0(s2)
    80002d80:	00002497          	auipc	s1,0x2
    80002d84:	93848493          	addi	s1,s1,-1736 # 800046b8 <uart_tx_w>
    80002d88:	0004b703          	ld	a4,0(s1)
    80002d8c:	02078693          	addi	a3,a5,32
    80002d90:	00050993          	mv	s3,a0
    80002d94:	02e69c63          	bne	a3,a4,80002dcc <uartputc+0x84>
    80002d98:	00001097          	auipc	ra,0x1
    80002d9c:	834080e7          	jalr	-1996(ra) # 800035cc <push_on>
    80002da0:	00093783          	ld	a5,0(s2)
    80002da4:	0004b703          	ld	a4,0(s1)
    80002da8:	02078793          	addi	a5,a5,32
    80002dac:	00e79463          	bne	a5,a4,80002db4 <uartputc+0x6c>
    80002db0:	0000006f          	j	80002db0 <uartputc+0x68>
    80002db4:	00001097          	auipc	ra,0x1
    80002db8:	88c080e7          	jalr	-1908(ra) # 80003640 <pop_on>
    80002dbc:	00093783          	ld	a5,0(s2)
    80002dc0:	0004b703          	ld	a4,0(s1)
    80002dc4:	02078693          	addi	a3,a5,32
    80002dc8:	fce688e3          	beq	a3,a4,80002d98 <uartputc+0x50>
    80002dcc:	01f77693          	andi	a3,a4,31
    80002dd0:	00003597          	auipc	a1,0x3
    80002dd4:	b3058593          	addi	a1,a1,-1232 # 80005900 <uart_tx_buf>
    80002dd8:	00d586b3          	add	a3,a1,a3
    80002ddc:	00170713          	addi	a4,a4,1
    80002de0:	01368023          	sb	s3,0(a3)
    80002de4:	00e4b023          	sd	a4,0(s1)
    80002de8:	10000637          	lui	a2,0x10000
    80002dec:	02f71063          	bne	a4,a5,80002e0c <uartputc+0xc4>
    80002df0:	0340006f          	j	80002e24 <uartputc+0xdc>
    80002df4:	00074703          	lbu	a4,0(a4)
    80002df8:	00f93023          	sd	a5,0(s2)
    80002dfc:	00e60023          	sb	a4,0(a2) # 10000000 <_entry-0x70000000>
    80002e00:	00093783          	ld	a5,0(s2)
    80002e04:	0004b703          	ld	a4,0(s1)
    80002e08:	00f70e63          	beq	a4,a5,80002e24 <uartputc+0xdc>
    80002e0c:	00564683          	lbu	a3,5(a2)
    80002e10:	01f7f713          	andi	a4,a5,31
    80002e14:	00e58733          	add	a4,a1,a4
    80002e18:	0206f693          	andi	a3,a3,32
    80002e1c:	00178793          	addi	a5,a5,1
    80002e20:	fc069ae3          	bnez	a3,80002df4 <uartputc+0xac>
    80002e24:	02813083          	ld	ra,40(sp)
    80002e28:	02013403          	ld	s0,32(sp)
    80002e2c:	01813483          	ld	s1,24(sp)
    80002e30:	01013903          	ld	s2,16(sp)
    80002e34:	00813983          	ld	s3,8(sp)
    80002e38:	03010113          	addi	sp,sp,48
    80002e3c:	00008067          	ret

0000000080002e40 <uartputc_sync>:
    80002e40:	ff010113          	addi	sp,sp,-16
    80002e44:	00813423          	sd	s0,8(sp)
    80002e48:	01010413          	addi	s0,sp,16
    80002e4c:	00002717          	auipc	a4,0x2
    80002e50:	85c72703          	lw	a4,-1956(a4) # 800046a8 <panicked>
    80002e54:	02071663          	bnez	a4,80002e80 <uartputc_sync+0x40>
    80002e58:	00050793          	mv	a5,a0
    80002e5c:	100006b7          	lui	a3,0x10000
    80002e60:	0056c703          	lbu	a4,5(a3) # 10000005 <_entry-0x6ffffffb>
    80002e64:	02077713          	andi	a4,a4,32
    80002e68:	fe070ce3          	beqz	a4,80002e60 <uartputc_sync+0x20>
    80002e6c:	0ff7f793          	andi	a5,a5,255
    80002e70:	00f68023          	sb	a5,0(a3)
    80002e74:	00813403          	ld	s0,8(sp)
    80002e78:	01010113          	addi	sp,sp,16
    80002e7c:	00008067          	ret
    80002e80:	0000006f          	j	80002e80 <uartputc_sync+0x40>

0000000080002e84 <uartstart>:
    80002e84:	ff010113          	addi	sp,sp,-16
    80002e88:	00813423          	sd	s0,8(sp)
    80002e8c:	01010413          	addi	s0,sp,16
    80002e90:	00002617          	auipc	a2,0x2
    80002e94:	82060613          	addi	a2,a2,-2016 # 800046b0 <uart_tx_r>
    80002e98:	00002517          	auipc	a0,0x2
    80002e9c:	82050513          	addi	a0,a0,-2016 # 800046b8 <uart_tx_w>
    80002ea0:	00063783          	ld	a5,0(a2)
    80002ea4:	00053703          	ld	a4,0(a0)
    80002ea8:	04f70263          	beq	a4,a5,80002eec <uartstart+0x68>
    80002eac:	100005b7          	lui	a1,0x10000
    80002eb0:	00003817          	auipc	a6,0x3
    80002eb4:	a5080813          	addi	a6,a6,-1456 # 80005900 <uart_tx_buf>
    80002eb8:	01c0006f          	j	80002ed4 <uartstart+0x50>
    80002ebc:	0006c703          	lbu	a4,0(a3)
    80002ec0:	00f63023          	sd	a5,0(a2)
    80002ec4:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    80002ec8:	00063783          	ld	a5,0(a2)
    80002ecc:	00053703          	ld	a4,0(a0)
    80002ed0:	00f70e63          	beq	a4,a5,80002eec <uartstart+0x68>
    80002ed4:	01f7f713          	andi	a4,a5,31
    80002ed8:	00e806b3          	add	a3,a6,a4
    80002edc:	0055c703          	lbu	a4,5(a1)
    80002ee0:	00178793          	addi	a5,a5,1
    80002ee4:	02077713          	andi	a4,a4,32
    80002ee8:	fc071ae3          	bnez	a4,80002ebc <uartstart+0x38>
    80002eec:	00813403          	ld	s0,8(sp)
    80002ef0:	01010113          	addi	sp,sp,16
    80002ef4:	00008067          	ret

0000000080002ef8 <uartgetc>:
    80002ef8:	ff010113          	addi	sp,sp,-16
    80002efc:	00813423          	sd	s0,8(sp)
    80002f00:	01010413          	addi	s0,sp,16
    80002f04:	10000737          	lui	a4,0x10000
    80002f08:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80002f0c:	0017f793          	andi	a5,a5,1
    80002f10:	00078c63          	beqz	a5,80002f28 <uartgetc+0x30>
    80002f14:	00074503          	lbu	a0,0(a4)
    80002f18:	0ff57513          	andi	a0,a0,255
    80002f1c:	00813403          	ld	s0,8(sp)
    80002f20:	01010113          	addi	sp,sp,16
    80002f24:	00008067          	ret
    80002f28:	fff00513          	li	a0,-1
    80002f2c:	ff1ff06f          	j	80002f1c <uartgetc+0x24>

0000000080002f30 <uartintr>:
    80002f30:	100007b7          	lui	a5,0x10000
    80002f34:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80002f38:	0017f793          	andi	a5,a5,1
    80002f3c:	0a078463          	beqz	a5,80002fe4 <uartintr+0xb4>
    80002f40:	fe010113          	addi	sp,sp,-32
    80002f44:	00813823          	sd	s0,16(sp)
    80002f48:	00913423          	sd	s1,8(sp)
    80002f4c:	00113c23          	sd	ra,24(sp)
    80002f50:	02010413          	addi	s0,sp,32
    80002f54:	100004b7          	lui	s1,0x10000
    80002f58:	0004c503          	lbu	a0,0(s1) # 10000000 <_entry-0x70000000>
    80002f5c:	0ff57513          	andi	a0,a0,255
    80002f60:	fffff097          	auipc	ra,0xfffff
    80002f64:	534080e7          	jalr	1332(ra) # 80002494 <consoleintr>
    80002f68:	0054c783          	lbu	a5,5(s1)
    80002f6c:	0017f793          	andi	a5,a5,1
    80002f70:	fe0794e3          	bnez	a5,80002f58 <uartintr+0x28>
    80002f74:	00001617          	auipc	a2,0x1
    80002f78:	73c60613          	addi	a2,a2,1852 # 800046b0 <uart_tx_r>
    80002f7c:	00001517          	auipc	a0,0x1
    80002f80:	73c50513          	addi	a0,a0,1852 # 800046b8 <uart_tx_w>
    80002f84:	00063783          	ld	a5,0(a2)
    80002f88:	00053703          	ld	a4,0(a0)
    80002f8c:	04f70263          	beq	a4,a5,80002fd0 <uartintr+0xa0>
    80002f90:	100005b7          	lui	a1,0x10000
    80002f94:	00003817          	auipc	a6,0x3
    80002f98:	96c80813          	addi	a6,a6,-1684 # 80005900 <uart_tx_buf>
    80002f9c:	01c0006f          	j	80002fb8 <uartintr+0x88>
    80002fa0:	0006c703          	lbu	a4,0(a3)
    80002fa4:	00f63023          	sd	a5,0(a2)
    80002fa8:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    80002fac:	00063783          	ld	a5,0(a2)
    80002fb0:	00053703          	ld	a4,0(a0)
    80002fb4:	00f70e63          	beq	a4,a5,80002fd0 <uartintr+0xa0>
    80002fb8:	01f7f713          	andi	a4,a5,31
    80002fbc:	00e806b3          	add	a3,a6,a4
    80002fc0:	0055c703          	lbu	a4,5(a1)
    80002fc4:	00178793          	addi	a5,a5,1
    80002fc8:	02077713          	andi	a4,a4,32
    80002fcc:	fc071ae3          	bnez	a4,80002fa0 <uartintr+0x70>
    80002fd0:	01813083          	ld	ra,24(sp)
    80002fd4:	01013403          	ld	s0,16(sp)
    80002fd8:	00813483          	ld	s1,8(sp)
    80002fdc:	02010113          	addi	sp,sp,32
    80002fe0:	00008067          	ret
    80002fe4:	00001617          	auipc	a2,0x1
    80002fe8:	6cc60613          	addi	a2,a2,1740 # 800046b0 <uart_tx_r>
    80002fec:	00001517          	auipc	a0,0x1
    80002ff0:	6cc50513          	addi	a0,a0,1740 # 800046b8 <uart_tx_w>
    80002ff4:	00063783          	ld	a5,0(a2)
    80002ff8:	00053703          	ld	a4,0(a0)
    80002ffc:	04f70263          	beq	a4,a5,80003040 <uartintr+0x110>
    80003000:	100005b7          	lui	a1,0x10000
    80003004:	00003817          	auipc	a6,0x3
    80003008:	8fc80813          	addi	a6,a6,-1796 # 80005900 <uart_tx_buf>
    8000300c:	01c0006f          	j	80003028 <uartintr+0xf8>
    80003010:	0006c703          	lbu	a4,0(a3)
    80003014:	00f63023          	sd	a5,0(a2)
    80003018:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    8000301c:	00063783          	ld	a5,0(a2)
    80003020:	00053703          	ld	a4,0(a0)
    80003024:	02f70063          	beq	a4,a5,80003044 <uartintr+0x114>
    80003028:	01f7f713          	andi	a4,a5,31
    8000302c:	00e806b3          	add	a3,a6,a4
    80003030:	0055c703          	lbu	a4,5(a1)
    80003034:	00178793          	addi	a5,a5,1
    80003038:	02077713          	andi	a4,a4,32
    8000303c:	fc071ae3          	bnez	a4,80003010 <uartintr+0xe0>
    80003040:	00008067          	ret
    80003044:	00008067          	ret

0000000080003048 <kinit>:
    80003048:	fc010113          	addi	sp,sp,-64
    8000304c:	02913423          	sd	s1,40(sp)
    80003050:	fffff7b7          	lui	a5,0xfffff
    80003054:	00004497          	auipc	s1,0x4
    80003058:	8cb48493          	addi	s1,s1,-1845 # 8000691f <end+0xfff>
    8000305c:	02813823          	sd	s0,48(sp)
    80003060:	01313c23          	sd	s3,24(sp)
    80003064:	00f4f4b3          	and	s1,s1,a5
    80003068:	02113c23          	sd	ra,56(sp)
    8000306c:	03213023          	sd	s2,32(sp)
    80003070:	01413823          	sd	s4,16(sp)
    80003074:	01513423          	sd	s5,8(sp)
    80003078:	04010413          	addi	s0,sp,64
    8000307c:	000017b7          	lui	a5,0x1
    80003080:	01100993          	li	s3,17
    80003084:	00f487b3          	add	a5,s1,a5
    80003088:	01b99993          	slli	s3,s3,0x1b
    8000308c:	06f9e063          	bltu	s3,a5,800030ec <kinit+0xa4>
    80003090:	00003a97          	auipc	s5,0x3
    80003094:	890a8a93          	addi	s5,s5,-1904 # 80005920 <end>
    80003098:	0754ec63          	bltu	s1,s5,80003110 <kinit+0xc8>
    8000309c:	0734fa63          	bgeu	s1,s3,80003110 <kinit+0xc8>
    800030a0:	00088a37          	lui	s4,0x88
    800030a4:	fffa0a13          	addi	s4,s4,-1 # 87fff <_entry-0x7ff78001>
    800030a8:	00001917          	auipc	s2,0x1
    800030ac:	61890913          	addi	s2,s2,1560 # 800046c0 <kmem>
    800030b0:	00ca1a13          	slli	s4,s4,0xc
    800030b4:	0140006f          	j	800030c8 <kinit+0x80>
    800030b8:	000017b7          	lui	a5,0x1
    800030bc:	00f484b3          	add	s1,s1,a5
    800030c0:	0554e863          	bltu	s1,s5,80003110 <kinit+0xc8>
    800030c4:	0534f663          	bgeu	s1,s3,80003110 <kinit+0xc8>
    800030c8:	00001637          	lui	a2,0x1
    800030cc:	00100593          	li	a1,1
    800030d0:	00048513          	mv	a0,s1
    800030d4:	00000097          	auipc	ra,0x0
    800030d8:	5e4080e7          	jalr	1508(ra) # 800036b8 <__memset>
    800030dc:	00093783          	ld	a5,0(s2)
    800030e0:	00f4b023          	sd	a5,0(s1)
    800030e4:	00993023          	sd	s1,0(s2)
    800030e8:	fd4498e3          	bne	s1,s4,800030b8 <kinit+0x70>
    800030ec:	03813083          	ld	ra,56(sp)
    800030f0:	03013403          	ld	s0,48(sp)
    800030f4:	02813483          	ld	s1,40(sp)
    800030f8:	02013903          	ld	s2,32(sp)
    800030fc:	01813983          	ld	s3,24(sp)
    80003100:	01013a03          	ld	s4,16(sp)
    80003104:	00813a83          	ld	s5,8(sp)
    80003108:	04010113          	addi	sp,sp,64
    8000310c:	00008067          	ret
    80003110:	00001517          	auipc	a0,0x1
    80003114:	1e050513          	addi	a0,a0,480 # 800042f0 <digits+0x18>
    80003118:	fffff097          	auipc	ra,0xfffff
    8000311c:	4b4080e7          	jalr	1204(ra) # 800025cc <panic>

0000000080003120 <freerange>:
    80003120:	fc010113          	addi	sp,sp,-64
    80003124:	000017b7          	lui	a5,0x1
    80003128:	02913423          	sd	s1,40(sp)
    8000312c:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80003130:	009504b3          	add	s1,a0,s1
    80003134:	fffff537          	lui	a0,0xfffff
    80003138:	02813823          	sd	s0,48(sp)
    8000313c:	02113c23          	sd	ra,56(sp)
    80003140:	03213023          	sd	s2,32(sp)
    80003144:	01313c23          	sd	s3,24(sp)
    80003148:	01413823          	sd	s4,16(sp)
    8000314c:	01513423          	sd	s5,8(sp)
    80003150:	01613023          	sd	s6,0(sp)
    80003154:	04010413          	addi	s0,sp,64
    80003158:	00a4f4b3          	and	s1,s1,a0
    8000315c:	00f487b3          	add	a5,s1,a5
    80003160:	06f5e463          	bltu	a1,a5,800031c8 <freerange+0xa8>
    80003164:	00002a97          	auipc	s5,0x2
    80003168:	7bca8a93          	addi	s5,s5,1980 # 80005920 <end>
    8000316c:	0954e263          	bltu	s1,s5,800031f0 <freerange+0xd0>
    80003170:	01100993          	li	s3,17
    80003174:	01b99993          	slli	s3,s3,0x1b
    80003178:	0734fc63          	bgeu	s1,s3,800031f0 <freerange+0xd0>
    8000317c:	00058a13          	mv	s4,a1
    80003180:	00001917          	auipc	s2,0x1
    80003184:	54090913          	addi	s2,s2,1344 # 800046c0 <kmem>
    80003188:	00002b37          	lui	s6,0x2
    8000318c:	0140006f          	j	800031a0 <freerange+0x80>
    80003190:	000017b7          	lui	a5,0x1
    80003194:	00f484b3          	add	s1,s1,a5
    80003198:	0554ec63          	bltu	s1,s5,800031f0 <freerange+0xd0>
    8000319c:	0534fa63          	bgeu	s1,s3,800031f0 <freerange+0xd0>
    800031a0:	00001637          	lui	a2,0x1
    800031a4:	00100593          	li	a1,1
    800031a8:	00048513          	mv	a0,s1
    800031ac:	00000097          	auipc	ra,0x0
    800031b0:	50c080e7          	jalr	1292(ra) # 800036b8 <__memset>
    800031b4:	00093703          	ld	a4,0(s2)
    800031b8:	016487b3          	add	a5,s1,s6
    800031bc:	00e4b023          	sd	a4,0(s1)
    800031c0:	00993023          	sd	s1,0(s2)
    800031c4:	fcfa76e3          	bgeu	s4,a5,80003190 <freerange+0x70>
    800031c8:	03813083          	ld	ra,56(sp)
    800031cc:	03013403          	ld	s0,48(sp)
    800031d0:	02813483          	ld	s1,40(sp)
    800031d4:	02013903          	ld	s2,32(sp)
    800031d8:	01813983          	ld	s3,24(sp)
    800031dc:	01013a03          	ld	s4,16(sp)
    800031e0:	00813a83          	ld	s5,8(sp)
    800031e4:	00013b03          	ld	s6,0(sp)
    800031e8:	04010113          	addi	sp,sp,64
    800031ec:	00008067          	ret
    800031f0:	00001517          	auipc	a0,0x1
    800031f4:	10050513          	addi	a0,a0,256 # 800042f0 <digits+0x18>
    800031f8:	fffff097          	auipc	ra,0xfffff
    800031fc:	3d4080e7          	jalr	980(ra) # 800025cc <panic>

0000000080003200 <kfree>:
    80003200:	fe010113          	addi	sp,sp,-32
    80003204:	00813823          	sd	s0,16(sp)
    80003208:	00113c23          	sd	ra,24(sp)
    8000320c:	00913423          	sd	s1,8(sp)
    80003210:	02010413          	addi	s0,sp,32
    80003214:	03451793          	slli	a5,a0,0x34
    80003218:	04079c63          	bnez	a5,80003270 <kfree+0x70>
    8000321c:	00002797          	auipc	a5,0x2
    80003220:	70478793          	addi	a5,a5,1796 # 80005920 <end>
    80003224:	00050493          	mv	s1,a0
    80003228:	04f56463          	bltu	a0,a5,80003270 <kfree+0x70>
    8000322c:	01100793          	li	a5,17
    80003230:	01b79793          	slli	a5,a5,0x1b
    80003234:	02f57e63          	bgeu	a0,a5,80003270 <kfree+0x70>
    80003238:	00001637          	lui	a2,0x1
    8000323c:	00100593          	li	a1,1
    80003240:	00000097          	auipc	ra,0x0
    80003244:	478080e7          	jalr	1144(ra) # 800036b8 <__memset>
    80003248:	00001797          	auipc	a5,0x1
    8000324c:	47878793          	addi	a5,a5,1144 # 800046c0 <kmem>
    80003250:	0007b703          	ld	a4,0(a5)
    80003254:	01813083          	ld	ra,24(sp)
    80003258:	01013403          	ld	s0,16(sp)
    8000325c:	00e4b023          	sd	a4,0(s1)
    80003260:	0097b023          	sd	s1,0(a5)
    80003264:	00813483          	ld	s1,8(sp)
    80003268:	02010113          	addi	sp,sp,32
    8000326c:	00008067          	ret
    80003270:	00001517          	auipc	a0,0x1
    80003274:	08050513          	addi	a0,a0,128 # 800042f0 <digits+0x18>
    80003278:	fffff097          	auipc	ra,0xfffff
    8000327c:	354080e7          	jalr	852(ra) # 800025cc <panic>

0000000080003280 <kalloc>:
    80003280:	fe010113          	addi	sp,sp,-32
    80003284:	00813823          	sd	s0,16(sp)
    80003288:	00913423          	sd	s1,8(sp)
    8000328c:	00113c23          	sd	ra,24(sp)
    80003290:	02010413          	addi	s0,sp,32
    80003294:	00001797          	auipc	a5,0x1
    80003298:	42c78793          	addi	a5,a5,1068 # 800046c0 <kmem>
    8000329c:	0007b483          	ld	s1,0(a5)
    800032a0:	02048063          	beqz	s1,800032c0 <kalloc+0x40>
    800032a4:	0004b703          	ld	a4,0(s1)
    800032a8:	00001637          	lui	a2,0x1
    800032ac:	00500593          	li	a1,5
    800032b0:	00048513          	mv	a0,s1
    800032b4:	00e7b023          	sd	a4,0(a5)
    800032b8:	00000097          	auipc	ra,0x0
    800032bc:	400080e7          	jalr	1024(ra) # 800036b8 <__memset>
    800032c0:	01813083          	ld	ra,24(sp)
    800032c4:	01013403          	ld	s0,16(sp)
    800032c8:	00048513          	mv	a0,s1
    800032cc:	00813483          	ld	s1,8(sp)
    800032d0:	02010113          	addi	sp,sp,32
    800032d4:	00008067          	ret

00000000800032d8 <initlock>:
    800032d8:	ff010113          	addi	sp,sp,-16
    800032dc:	00813423          	sd	s0,8(sp)
    800032e0:	01010413          	addi	s0,sp,16
    800032e4:	00813403          	ld	s0,8(sp)
    800032e8:	00b53423          	sd	a1,8(a0)
    800032ec:	00052023          	sw	zero,0(a0)
    800032f0:	00053823          	sd	zero,16(a0)
    800032f4:	01010113          	addi	sp,sp,16
    800032f8:	00008067          	ret

00000000800032fc <acquire>:
    800032fc:	fe010113          	addi	sp,sp,-32
    80003300:	00813823          	sd	s0,16(sp)
    80003304:	00913423          	sd	s1,8(sp)
    80003308:	00113c23          	sd	ra,24(sp)
    8000330c:	01213023          	sd	s2,0(sp)
    80003310:	02010413          	addi	s0,sp,32
    80003314:	00050493          	mv	s1,a0
    80003318:	10002973          	csrr	s2,sstatus
    8000331c:	100027f3          	csrr	a5,sstatus
    80003320:	ffd7f793          	andi	a5,a5,-3
    80003324:	10079073          	csrw	sstatus,a5
    80003328:	fffff097          	auipc	ra,0xfffff
    8000332c:	8e0080e7          	jalr	-1824(ra) # 80001c08 <mycpu>
    80003330:	07852783          	lw	a5,120(a0)
    80003334:	06078e63          	beqz	a5,800033b0 <acquire+0xb4>
    80003338:	fffff097          	auipc	ra,0xfffff
    8000333c:	8d0080e7          	jalr	-1840(ra) # 80001c08 <mycpu>
    80003340:	07852783          	lw	a5,120(a0)
    80003344:	0004a703          	lw	a4,0(s1)
    80003348:	0017879b          	addiw	a5,a5,1
    8000334c:	06f52c23          	sw	a5,120(a0)
    80003350:	04071063          	bnez	a4,80003390 <acquire+0x94>
    80003354:	00100713          	li	a4,1
    80003358:	00070793          	mv	a5,a4
    8000335c:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80003360:	0007879b          	sext.w	a5,a5
    80003364:	fe079ae3          	bnez	a5,80003358 <acquire+0x5c>
    80003368:	0ff0000f          	fence
    8000336c:	fffff097          	auipc	ra,0xfffff
    80003370:	89c080e7          	jalr	-1892(ra) # 80001c08 <mycpu>
    80003374:	01813083          	ld	ra,24(sp)
    80003378:	01013403          	ld	s0,16(sp)
    8000337c:	00a4b823          	sd	a0,16(s1)
    80003380:	00013903          	ld	s2,0(sp)
    80003384:	00813483          	ld	s1,8(sp)
    80003388:	02010113          	addi	sp,sp,32
    8000338c:	00008067          	ret
    80003390:	0104b903          	ld	s2,16(s1)
    80003394:	fffff097          	auipc	ra,0xfffff
    80003398:	874080e7          	jalr	-1932(ra) # 80001c08 <mycpu>
    8000339c:	faa91ce3          	bne	s2,a0,80003354 <acquire+0x58>
    800033a0:	00001517          	auipc	a0,0x1
    800033a4:	f5850513          	addi	a0,a0,-168 # 800042f8 <digits+0x20>
    800033a8:	fffff097          	auipc	ra,0xfffff
    800033ac:	224080e7          	jalr	548(ra) # 800025cc <panic>
    800033b0:	00195913          	srli	s2,s2,0x1
    800033b4:	fffff097          	auipc	ra,0xfffff
    800033b8:	854080e7          	jalr	-1964(ra) # 80001c08 <mycpu>
    800033bc:	00197913          	andi	s2,s2,1
    800033c0:	07252e23          	sw	s2,124(a0)
    800033c4:	f75ff06f          	j	80003338 <acquire+0x3c>

00000000800033c8 <release>:
    800033c8:	fe010113          	addi	sp,sp,-32
    800033cc:	00813823          	sd	s0,16(sp)
    800033d0:	00113c23          	sd	ra,24(sp)
    800033d4:	00913423          	sd	s1,8(sp)
    800033d8:	01213023          	sd	s2,0(sp)
    800033dc:	02010413          	addi	s0,sp,32
    800033e0:	00052783          	lw	a5,0(a0)
    800033e4:	00079a63          	bnez	a5,800033f8 <release+0x30>
    800033e8:	00001517          	auipc	a0,0x1
    800033ec:	f1850513          	addi	a0,a0,-232 # 80004300 <digits+0x28>
    800033f0:	fffff097          	auipc	ra,0xfffff
    800033f4:	1dc080e7          	jalr	476(ra) # 800025cc <panic>
    800033f8:	01053903          	ld	s2,16(a0)
    800033fc:	00050493          	mv	s1,a0
    80003400:	fffff097          	auipc	ra,0xfffff
    80003404:	808080e7          	jalr	-2040(ra) # 80001c08 <mycpu>
    80003408:	fea910e3          	bne	s2,a0,800033e8 <release+0x20>
    8000340c:	0004b823          	sd	zero,16(s1)
    80003410:	0ff0000f          	fence
    80003414:	0f50000f          	fence	iorw,ow
    80003418:	0804a02f          	amoswap.w	zero,zero,(s1)
    8000341c:	ffffe097          	auipc	ra,0xffffe
    80003420:	7ec080e7          	jalr	2028(ra) # 80001c08 <mycpu>
    80003424:	100027f3          	csrr	a5,sstatus
    80003428:	0027f793          	andi	a5,a5,2
    8000342c:	04079a63          	bnez	a5,80003480 <release+0xb8>
    80003430:	07852783          	lw	a5,120(a0)
    80003434:	02f05e63          	blez	a5,80003470 <release+0xa8>
    80003438:	fff7871b          	addiw	a4,a5,-1
    8000343c:	06e52c23          	sw	a4,120(a0)
    80003440:	00071c63          	bnez	a4,80003458 <release+0x90>
    80003444:	07c52783          	lw	a5,124(a0)
    80003448:	00078863          	beqz	a5,80003458 <release+0x90>
    8000344c:	100027f3          	csrr	a5,sstatus
    80003450:	0027e793          	ori	a5,a5,2
    80003454:	10079073          	csrw	sstatus,a5
    80003458:	01813083          	ld	ra,24(sp)
    8000345c:	01013403          	ld	s0,16(sp)
    80003460:	00813483          	ld	s1,8(sp)
    80003464:	00013903          	ld	s2,0(sp)
    80003468:	02010113          	addi	sp,sp,32
    8000346c:	00008067          	ret
    80003470:	00001517          	auipc	a0,0x1
    80003474:	eb050513          	addi	a0,a0,-336 # 80004320 <digits+0x48>
    80003478:	fffff097          	auipc	ra,0xfffff
    8000347c:	154080e7          	jalr	340(ra) # 800025cc <panic>
    80003480:	00001517          	auipc	a0,0x1
    80003484:	e8850513          	addi	a0,a0,-376 # 80004308 <digits+0x30>
    80003488:	fffff097          	auipc	ra,0xfffff
    8000348c:	144080e7          	jalr	324(ra) # 800025cc <panic>

0000000080003490 <holding>:
    80003490:	00052783          	lw	a5,0(a0)
    80003494:	00079663          	bnez	a5,800034a0 <holding+0x10>
    80003498:	00000513          	li	a0,0
    8000349c:	00008067          	ret
    800034a0:	fe010113          	addi	sp,sp,-32
    800034a4:	00813823          	sd	s0,16(sp)
    800034a8:	00913423          	sd	s1,8(sp)
    800034ac:	00113c23          	sd	ra,24(sp)
    800034b0:	02010413          	addi	s0,sp,32
    800034b4:	01053483          	ld	s1,16(a0)
    800034b8:	ffffe097          	auipc	ra,0xffffe
    800034bc:	750080e7          	jalr	1872(ra) # 80001c08 <mycpu>
    800034c0:	01813083          	ld	ra,24(sp)
    800034c4:	01013403          	ld	s0,16(sp)
    800034c8:	40a48533          	sub	a0,s1,a0
    800034cc:	00153513          	seqz	a0,a0
    800034d0:	00813483          	ld	s1,8(sp)
    800034d4:	02010113          	addi	sp,sp,32
    800034d8:	00008067          	ret

00000000800034dc <push_off>:
    800034dc:	fe010113          	addi	sp,sp,-32
    800034e0:	00813823          	sd	s0,16(sp)
    800034e4:	00113c23          	sd	ra,24(sp)
    800034e8:	00913423          	sd	s1,8(sp)
    800034ec:	02010413          	addi	s0,sp,32
    800034f0:	100024f3          	csrr	s1,sstatus
    800034f4:	100027f3          	csrr	a5,sstatus
    800034f8:	ffd7f793          	andi	a5,a5,-3
    800034fc:	10079073          	csrw	sstatus,a5
    80003500:	ffffe097          	auipc	ra,0xffffe
    80003504:	708080e7          	jalr	1800(ra) # 80001c08 <mycpu>
    80003508:	07852783          	lw	a5,120(a0)
    8000350c:	02078663          	beqz	a5,80003538 <push_off+0x5c>
    80003510:	ffffe097          	auipc	ra,0xffffe
    80003514:	6f8080e7          	jalr	1784(ra) # 80001c08 <mycpu>
    80003518:	07852783          	lw	a5,120(a0)
    8000351c:	01813083          	ld	ra,24(sp)
    80003520:	01013403          	ld	s0,16(sp)
    80003524:	0017879b          	addiw	a5,a5,1
    80003528:	06f52c23          	sw	a5,120(a0)
    8000352c:	00813483          	ld	s1,8(sp)
    80003530:	02010113          	addi	sp,sp,32
    80003534:	00008067          	ret
    80003538:	0014d493          	srli	s1,s1,0x1
    8000353c:	ffffe097          	auipc	ra,0xffffe
    80003540:	6cc080e7          	jalr	1740(ra) # 80001c08 <mycpu>
    80003544:	0014f493          	andi	s1,s1,1
    80003548:	06952e23          	sw	s1,124(a0)
    8000354c:	fc5ff06f          	j	80003510 <push_off+0x34>

0000000080003550 <pop_off>:
    80003550:	ff010113          	addi	sp,sp,-16
    80003554:	00813023          	sd	s0,0(sp)
    80003558:	00113423          	sd	ra,8(sp)
    8000355c:	01010413          	addi	s0,sp,16
    80003560:	ffffe097          	auipc	ra,0xffffe
    80003564:	6a8080e7          	jalr	1704(ra) # 80001c08 <mycpu>
    80003568:	100027f3          	csrr	a5,sstatus
    8000356c:	0027f793          	andi	a5,a5,2
    80003570:	04079663          	bnez	a5,800035bc <pop_off+0x6c>
    80003574:	07852783          	lw	a5,120(a0)
    80003578:	02f05a63          	blez	a5,800035ac <pop_off+0x5c>
    8000357c:	fff7871b          	addiw	a4,a5,-1
    80003580:	06e52c23          	sw	a4,120(a0)
    80003584:	00071c63          	bnez	a4,8000359c <pop_off+0x4c>
    80003588:	07c52783          	lw	a5,124(a0)
    8000358c:	00078863          	beqz	a5,8000359c <pop_off+0x4c>
    80003590:	100027f3          	csrr	a5,sstatus
    80003594:	0027e793          	ori	a5,a5,2
    80003598:	10079073          	csrw	sstatus,a5
    8000359c:	00813083          	ld	ra,8(sp)
    800035a0:	00013403          	ld	s0,0(sp)
    800035a4:	01010113          	addi	sp,sp,16
    800035a8:	00008067          	ret
    800035ac:	00001517          	auipc	a0,0x1
    800035b0:	d7450513          	addi	a0,a0,-652 # 80004320 <digits+0x48>
    800035b4:	fffff097          	auipc	ra,0xfffff
    800035b8:	018080e7          	jalr	24(ra) # 800025cc <panic>
    800035bc:	00001517          	auipc	a0,0x1
    800035c0:	d4c50513          	addi	a0,a0,-692 # 80004308 <digits+0x30>
    800035c4:	fffff097          	auipc	ra,0xfffff
    800035c8:	008080e7          	jalr	8(ra) # 800025cc <panic>

00000000800035cc <push_on>:
    800035cc:	fe010113          	addi	sp,sp,-32
    800035d0:	00813823          	sd	s0,16(sp)
    800035d4:	00113c23          	sd	ra,24(sp)
    800035d8:	00913423          	sd	s1,8(sp)
    800035dc:	02010413          	addi	s0,sp,32
    800035e0:	100024f3          	csrr	s1,sstatus
    800035e4:	100027f3          	csrr	a5,sstatus
    800035e8:	0027e793          	ori	a5,a5,2
    800035ec:	10079073          	csrw	sstatus,a5
    800035f0:	ffffe097          	auipc	ra,0xffffe
    800035f4:	618080e7          	jalr	1560(ra) # 80001c08 <mycpu>
    800035f8:	07852783          	lw	a5,120(a0)
    800035fc:	02078663          	beqz	a5,80003628 <push_on+0x5c>
    80003600:	ffffe097          	auipc	ra,0xffffe
    80003604:	608080e7          	jalr	1544(ra) # 80001c08 <mycpu>
    80003608:	07852783          	lw	a5,120(a0)
    8000360c:	01813083          	ld	ra,24(sp)
    80003610:	01013403          	ld	s0,16(sp)
    80003614:	0017879b          	addiw	a5,a5,1
    80003618:	06f52c23          	sw	a5,120(a0)
    8000361c:	00813483          	ld	s1,8(sp)
    80003620:	02010113          	addi	sp,sp,32
    80003624:	00008067          	ret
    80003628:	0014d493          	srli	s1,s1,0x1
    8000362c:	ffffe097          	auipc	ra,0xffffe
    80003630:	5dc080e7          	jalr	1500(ra) # 80001c08 <mycpu>
    80003634:	0014f493          	andi	s1,s1,1
    80003638:	06952e23          	sw	s1,124(a0)
    8000363c:	fc5ff06f          	j	80003600 <push_on+0x34>

0000000080003640 <pop_on>:
    80003640:	ff010113          	addi	sp,sp,-16
    80003644:	00813023          	sd	s0,0(sp)
    80003648:	00113423          	sd	ra,8(sp)
    8000364c:	01010413          	addi	s0,sp,16
    80003650:	ffffe097          	auipc	ra,0xffffe
    80003654:	5b8080e7          	jalr	1464(ra) # 80001c08 <mycpu>
    80003658:	100027f3          	csrr	a5,sstatus
    8000365c:	0027f793          	andi	a5,a5,2
    80003660:	04078463          	beqz	a5,800036a8 <pop_on+0x68>
    80003664:	07852783          	lw	a5,120(a0)
    80003668:	02f05863          	blez	a5,80003698 <pop_on+0x58>
    8000366c:	fff7879b          	addiw	a5,a5,-1
    80003670:	06f52c23          	sw	a5,120(a0)
    80003674:	07853783          	ld	a5,120(a0)
    80003678:	00079863          	bnez	a5,80003688 <pop_on+0x48>
    8000367c:	100027f3          	csrr	a5,sstatus
    80003680:	ffd7f793          	andi	a5,a5,-3
    80003684:	10079073          	csrw	sstatus,a5
    80003688:	00813083          	ld	ra,8(sp)
    8000368c:	00013403          	ld	s0,0(sp)
    80003690:	01010113          	addi	sp,sp,16
    80003694:	00008067          	ret
    80003698:	00001517          	auipc	a0,0x1
    8000369c:	cb050513          	addi	a0,a0,-848 # 80004348 <digits+0x70>
    800036a0:	fffff097          	auipc	ra,0xfffff
    800036a4:	f2c080e7          	jalr	-212(ra) # 800025cc <panic>
    800036a8:	00001517          	auipc	a0,0x1
    800036ac:	c8050513          	addi	a0,a0,-896 # 80004328 <digits+0x50>
    800036b0:	fffff097          	auipc	ra,0xfffff
    800036b4:	f1c080e7          	jalr	-228(ra) # 800025cc <panic>

00000000800036b8 <__memset>:
    800036b8:	ff010113          	addi	sp,sp,-16
    800036bc:	00813423          	sd	s0,8(sp)
    800036c0:	01010413          	addi	s0,sp,16
    800036c4:	1a060e63          	beqz	a2,80003880 <__memset+0x1c8>
    800036c8:	40a007b3          	neg	a5,a0
    800036cc:	0077f793          	andi	a5,a5,7
    800036d0:	00778693          	addi	a3,a5,7
    800036d4:	00b00813          	li	a6,11
    800036d8:	0ff5f593          	andi	a1,a1,255
    800036dc:	fff6071b          	addiw	a4,a2,-1
    800036e0:	1b06e663          	bltu	a3,a6,8000388c <__memset+0x1d4>
    800036e4:	1cd76463          	bltu	a4,a3,800038ac <__memset+0x1f4>
    800036e8:	1a078e63          	beqz	a5,800038a4 <__memset+0x1ec>
    800036ec:	00b50023          	sb	a1,0(a0)
    800036f0:	00100713          	li	a4,1
    800036f4:	1ae78463          	beq	a5,a4,8000389c <__memset+0x1e4>
    800036f8:	00b500a3          	sb	a1,1(a0)
    800036fc:	00200713          	li	a4,2
    80003700:	1ae78a63          	beq	a5,a4,800038b4 <__memset+0x1fc>
    80003704:	00b50123          	sb	a1,2(a0)
    80003708:	00300713          	li	a4,3
    8000370c:	18e78463          	beq	a5,a4,80003894 <__memset+0x1dc>
    80003710:	00b501a3          	sb	a1,3(a0)
    80003714:	00400713          	li	a4,4
    80003718:	1ae78263          	beq	a5,a4,800038bc <__memset+0x204>
    8000371c:	00b50223          	sb	a1,4(a0)
    80003720:	00500713          	li	a4,5
    80003724:	1ae78063          	beq	a5,a4,800038c4 <__memset+0x20c>
    80003728:	00b502a3          	sb	a1,5(a0)
    8000372c:	00700713          	li	a4,7
    80003730:	18e79e63          	bne	a5,a4,800038cc <__memset+0x214>
    80003734:	00b50323          	sb	a1,6(a0)
    80003738:	00700e93          	li	t4,7
    8000373c:	00859713          	slli	a4,a1,0x8
    80003740:	00e5e733          	or	a4,a1,a4
    80003744:	01059e13          	slli	t3,a1,0x10
    80003748:	01c76e33          	or	t3,a4,t3
    8000374c:	01859313          	slli	t1,a1,0x18
    80003750:	006e6333          	or	t1,t3,t1
    80003754:	02059893          	slli	a7,a1,0x20
    80003758:	40f60e3b          	subw	t3,a2,a5
    8000375c:	011368b3          	or	a7,t1,a7
    80003760:	02859813          	slli	a6,a1,0x28
    80003764:	0108e833          	or	a6,a7,a6
    80003768:	03059693          	slli	a3,a1,0x30
    8000376c:	003e589b          	srliw	a7,t3,0x3
    80003770:	00d866b3          	or	a3,a6,a3
    80003774:	03859713          	slli	a4,a1,0x38
    80003778:	00389813          	slli	a6,a7,0x3
    8000377c:	00f507b3          	add	a5,a0,a5
    80003780:	00e6e733          	or	a4,a3,a4
    80003784:	000e089b          	sext.w	a7,t3
    80003788:	00f806b3          	add	a3,a6,a5
    8000378c:	00e7b023          	sd	a4,0(a5)
    80003790:	00878793          	addi	a5,a5,8
    80003794:	fed79ce3          	bne	a5,a3,8000378c <__memset+0xd4>
    80003798:	ff8e7793          	andi	a5,t3,-8
    8000379c:	0007871b          	sext.w	a4,a5
    800037a0:	01d787bb          	addw	a5,a5,t4
    800037a4:	0ce88e63          	beq	a7,a4,80003880 <__memset+0x1c8>
    800037a8:	00f50733          	add	a4,a0,a5
    800037ac:	00b70023          	sb	a1,0(a4)
    800037b0:	0017871b          	addiw	a4,a5,1
    800037b4:	0cc77663          	bgeu	a4,a2,80003880 <__memset+0x1c8>
    800037b8:	00e50733          	add	a4,a0,a4
    800037bc:	00b70023          	sb	a1,0(a4)
    800037c0:	0027871b          	addiw	a4,a5,2
    800037c4:	0ac77e63          	bgeu	a4,a2,80003880 <__memset+0x1c8>
    800037c8:	00e50733          	add	a4,a0,a4
    800037cc:	00b70023          	sb	a1,0(a4)
    800037d0:	0037871b          	addiw	a4,a5,3
    800037d4:	0ac77663          	bgeu	a4,a2,80003880 <__memset+0x1c8>
    800037d8:	00e50733          	add	a4,a0,a4
    800037dc:	00b70023          	sb	a1,0(a4)
    800037e0:	0047871b          	addiw	a4,a5,4
    800037e4:	08c77e63          	bgeu	a4,a2,80003880 <__memset+0x1c8>
    800037e8:	00e50733          	add	a4,a0,a4
    800037ec:	00b70023          	sb	a1,0(a4)
    800037f0:	0057871b          	addiw	a4,a5,5
    800037f4:	08c77663          	bgeu	a4,a2,80003880 <__memset+0x1c8>
    800037f8:	00e50733          	add	a4,a0,a4
    800037fc:	00b70023          	sb	a1,0(a4)
    80003800:	0067871b          	addiw	a4,a5,6
    80003804:	06c77e63          	bgeu	a4,a2,80003880 <__memset+0x1c8>
    80003808:	00e50733          	add	a4,a0,a4
    8000380c:	00b70023          	sb	a1,0(a4)
    80003810:	0077871b          	addiw	a4,a5,7
    80003814:	06c77663          	bgeu	a4,a2,80003880 <__memset+0x1c8>
    80003818:	00e50733          	add	a4,a0,a4
    8000381c:	00b70023          	sb	a1,0(a4)
    80003820:	0087871b          	addiw	a4,a5,8
    80003824:	04c77e63          	bgeu	a4,a2,80003880 <__memset+0x1c8>
    80003828:	00e50733          	add	a4,a0,a4
    8000382c:	00b70023          	sb	a1,0(a4)
    80003830:	0097871b          	addiw	a4,a5,9
    80003834:	04c77663          	bgeu	a4,a2,80003880 <__memset+0x1c8>
    80003838:	00e50733          	add	a4,a0,a4
    8000383c:	00b70023          	sb	a1,0(a4)
    80003840:	00a7871b          	addiw	a4,a5,10
    80003844:	02c77e63          	bgeu	a4,a2,80003880 <__memset+0x1c8>
    80003848:	00e50733          	add	a4,a0,a4
    8000384c:	00b70023          	sb	a1,0(a4)
    80003850:	00b7871b          	addiw	a4,a5,11
    80003854:	02c77663          	bgeu	a4,a2,80003880 <__memset+0x1c8>
    80003858:	00e50733          	add	a4,a0,a4
    8000385c:	00b70023          	sb	a1,0(a4)
    80003860:	00c7871b          	addiw	a4,a5,12
    80003864:	00c77e63          	bgeu	a4,a2,80003880 <__memset+0x1c8>
    80003868:	00e50733          	add	a4,a0,a4
    8000386c:	00b70023          	sb	a1,0(a4)
    80003870:	00d7879b          	addiw	a5,a5,13
    80003874:	00c7f663          	bgeu	a5,a2,80003880 <__memset+0x1c8>
    80003878:	00f507b3          	add	a5,a0,a5
    8000387c:	00b78023          	sb	a1,0(a5)
    80003880:	00813403          	ld	s0,8(sp)
    80003884:	01010113          	addi	sp,sp,16
    80003888:	00008067          	ret
    8000388c:	00b00693          	li	a3,11
    80003890:	e55ff06f          	j	800036e4 <__memset+0x2c>
    80003894:	00300e93          	li	t4,3
    80003898:	ea5ff06f          	j	8000373c <__memset+0x84>
    8000389c:	00100e93          	li	t4,1
    800038a0:	e9dff06f          	j	8000373c <__memset+0x84>
    800038a4:	00000e93          	li	t4,0
    800038a8:	e95ff06f          	j	8000373c <__memset+0x84>
    800038ac:	00000793          	li	a5,0
    800038b0:	ef9ff06f          	j	800037a8 <__memset+0xf0>
    800038b4:	00200e93          	li	t4,2
    800038b8:	e85ff06f          	j	8000373c <__memset+0x84>
    800038bc:	00400e93          	li	t4,4
    800038c0:	e7dff06f          	j	8000373c <__memset+0x84>
    800038c4:	00500e93          	li	t4,5
    800038c8:	e75ff06f          	j	8000373c <__memset+0x84>
    800038cc:	00600e93          	li	t4,6
    800038d0:	e6dff06f          	j	8000373c <__memset+0x84>

00000000800038d4 <__memmove>:
    800038d4:	ff010113          	addi	sp,sp,-16
    800038d8:	00813423          	sd	s0,8(sp)
    800038dc:	01010413          	addi	s0,sp,16
    800038e0:	0e060863          	beqz	a2,800039d0 <__memmove+0xfc>
    800038e4:	fff6069b          	addiw	a3,a2,-1
    800038e8:	0006881b          	sext.w	a6,a3
    800038ec:	0ea5e863          	bltu	a1,a0,800039dc <__memmove+0x108>
    800038f0:	00758713          	addi	a4,a1,7
    800038f4:	00a5e7b3          	or	a5,a1,a0
    800038f8:	40a70733          	sub	a4,a4,a0
    800038fc:	0077f793          	andi	a5,a5,7
    80003900:	00f73713          	sltiu	a4,a4,15
    80003904:	00174713          	xori	a4,a4,1
    80003908:	0017b793          	seqz	a5,a5
    8000390c:	00e7f7b3          	and	a5,a5,a4
    80003910:	10078863          	beqz	a5,80003a20 <__memmove+0x14c>
    80003914:	00900793          	li	a5,9
    80003918:	1107f463          	bgeu	a5,a6,80003a20 <__memmove+0x14c>
    8000391c:	0036581b          	srliw	a6,a2,0x3
    80003920:	fff8081b          	addiw	a6,a6,-1
    80003924:	02081813          	slli	a6,a6,0x20
    80003928:	01d85893          	srli	a7,a6,0x1d
    8000392c:	00858813          	addi	a6,a1,8
    80003930:	00058793          	mv	a5,a1
    80003934:	00050713          	mv	a4,a0
    80003938:	01088833          	add	a6,a7,a6
    8000393c:	0007b883          	ld	a7,0(a5)
    80003940:	00878793          	addi	a5,a5,8
    80003944:	00870713          	addi	a4,a4,8
    80003948:	ff173c23          	sd	a7,-8(a4)
    8000394c:	ff0798e3          	bne	a5,a6,8000393c <__memmove+0x68>
    80003950:	ff867713          	andi	a4,a2,-8
    80003954:	02071793          	slli	a5,a4,0x20
    80003958:	0207d793          	srli	a5,a5,0x20
    8000395c:	00f585b3          	add	a1,a1,a5
    80003960:	40e686bb          	subw	a3,a3,a4
    80003964:	00f507b3          	add	a5,a0,a5
    80003968:	06e60463          	beq	a2,a4,800039d0 <__memmove+0xfc>
    8000396c:	0005c703          	lbu	a4,0(a1)
    80003970:	00e78023          	sb	a4,0(a5)
    80003974:	04068e63          	beqz	a3,800039d0 <__memmove+0xfc>
    80003978:	0015c603          	lbu	a2,1(a1)
    8000397c:	00100713          	li	a4,1
    80003980:	00c780a3          	sb	a2,1(a5)
    80003984:	04e68663          	beq	a3,a4,800039d0 <__memmove+0xfc>
    80003988:	0025c603          	lbu	a2,2(a1)
    8000398c:	00200713          	li	a4,2
    80003990:	00c78123          	sb	a2,2(a5)
    80003994:	02e68e63          	beq	a3,a4,800039d0 <__memmove+0xfc>
    80003998:	0035c603          	lbu	a2,3(a1)
    8000399c:	00300713          	li	a4,3
    800039a0:	00c781a3          	sb	a2,3(a5)
    800039a4:	02e68663          	beq	a3,a4,800039d0 <__memmove+0xfc>
    800039a8:	0045c603          	lbu	a2,4(a1)
    800039ac:	00400713          	li	a4,4
    800039b0:	00c78223          	sb	a2,4(a5)
    800039b4:	00e68e63          	beq	a3,a4,800039d0 <__memmove+0xfc>
    800039b8:	0055c603          	lbu	a2,5(a1)
    800039bc:	00500713          	li	a4,5
    800039c0:	00c782a3          	sb	a2,5(a5)
    800039c4:	00e68663          	beq	a3,a4,800039d0 <__memmove+0xfc>
    800039c8:	0065c703          	lbu	a4,6(a1)
    800039cc:	00e78323          	sb	a4,6(a5)
    800039d0:	00813403          	ld	s0,8(sp)
    800039d4:	01010113          	addi	sp,sp,16
    800039d8:	00008067          	ret
    800039dc:	02061713          	slli	a4,a2,0x20
    800039e0:	02075713          	srli	a4,a4,0x20
    800039e4:	00e587b3          	add	a5,a1,a4
    800039e8:	f0f574e3          	bgeu	a0,a5,800038f0 <__memmove+0x1c>
    800039ec:	02069613          	slli	a2,a3,0x20
    800039f0:	02065613          	srli	a2,a2,0x20
    800039f4:	fff64613          	not	a2,a2
    800039f8:	00e50733          	add	a4,a0,a4
    800039fc:	00c78633          	add	a2,a5,a2
    80003a00:	fff7c683          	lbu	a3,-1(a5)
    80003a04:	fff78793          	addi	a5,a5,-1
    80003a08:	fff70713          	addi	a4,a4,-1
    80003a0c:	00d70023          	sb	a3,0(a4)
    80003a10:	fec798e3          	bne	a5,a2,80003a00 <__memmove+0x12c>
    80003a14:	00813403          	ld	s0,8(sp)
    80003a18:	01010113          	addi	sp,sp,16
    80003a1c:	00008067          	ret
    80003a20:	02069713          	slli	a4,a3,0x20
    80003a24:	02075713          	srli	a4,a4,0x20
    80003a28:	00170713          	addi	a4,a4,1
    80003a2c:	00e50733          	add	a4,a0,a4
    80003a30:	00050793          	mv	a5,a0
    80003a34:	0005c683          	lbu	a3,0(a1)
    80003a38:	00178793          	addi	a5,a5,1
    80003a3c:	00158593          	addi	a1,a1,1
    80003a40:	fed78fa3          	sb	a3,-1(a5)
    80003a44:	fee798e3          	bne	a5,a4,80003a34 <__memmove+0x160>
    80003a48:	f89ff06f          	j	800039d0 <__memmove+0xfc>
	...
