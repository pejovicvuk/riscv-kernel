
kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00004117          	auipc	sp,0x4
    80000004:	6d813103          	ld	sp,1752(sp) # 800046d8 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	00001537          	lui	a0,0x1
    8000000c:	f14025f3          	csrr	a1,mhartid
    80000010:	00158593          	addi	a1,a1,1
    80000014:	02b50533          	mul	a0,a0,a1
    80000018:	00a10133          	add	sp,sp,a0
    8000001c:	329010ef          	jal	ra,80001b44 <start>

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
    80001040:	220000ef          	jal	ra,80001260 <handleTrap>

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

0000000080001090 <contextSwitch>:
# paznja: raspored polja mora da se poklapa sa strukturom Context u tcb.hpp
# (ra na pomeraju 0, sp na pomeraju 8).

.global contextSwitch
contextSwitch:
    addi sp, sp, -96       # mesto za 12 s-registara (12 x 8B)
    80001090:	fa010113          	addi	sp,sp,-96
    sd s0, 0(sp)
    80001094:	00813023          	sd	s0,0(sp)
    sd s1, 8(sp)
    80001098:	00913423          	sd	s1,8(sp)
    sd s2, 16(sp)
    8000109c:	01213823          	sd	s2,16(sp)
    sd s3, 24(sp)
    800010a0:	01313c23          	sd	s3,24(sp)
    sd s4, 32(sp)
    800010a4:	03413023          	sd	s4,32(sp)
    sd s5, 40(sp)
    800010a8:	03513423          	sd	s5,40(sp)
    sd s6, 48(sp)
    800010ac:	03613823          	sd	s6,48(sp)
    sd s7, 56(sp)
    800010b0:	03713c23          	sd	s7,56(sp)
    sd s8, 64(sp)
    800010b4:	05813023          	sd	s8,64(sp)
    sd s9, 72(sp)
    800010b8:	05913423          	sd	s9,72(sp)
    sd s10, 80(sp)
    800010bc:	05a13823          	sd	s10,80(sp)
    sd s11, 88(sp)
    800010c0:	05b13c23          	sd	s11,88(sp)

    sd ra, 0(a0)           # stara nit: gde da nastavi kad se probudi
    800010c4:	00153023          	sd	ra,0(a0) # 1000 <_entry-0x7ffff000>
    sd sp, 8(a0)           # stara nit: rucka kofera        == zamrznuta
    800010c8:	00253423          	sd	sp,8(a0)

    ld ra, 0(a1)           # nova nit: odakle nastavlja
    800010cc:	0005b083          	ld	ra,0(a1)
    ld sp, 8(a1)           # nova nit: njen stek            == budi se
    800010d0:	0085b103          	ld	sp,8(a1)

    ld s0, 0(sp)
    800010d4:	00013403          	ld	s0,0(sp)
    ld s1, 8(sp)
    800010d8:	00813483          	ld	s1,8(sp)
    ld s2, 16(sp)
    800010dc:	01013903          	ld	s2,16(sp)
    ld s3, 24(sp)
    800010e0:	01813983          	ld	s3,24(sp)
    ld s4, 32(sp)
    800010e4:	02013a03          	ld	s4,32(sp)
    ld s5, 40(sp)
    800010e8:	02813a83          	ld	s5,40(sp)
    ld s6, 48(sp)
    800010ec:	03013b03          	ld	s6,48(sp)
    ld s7, 56(sp)
    800010f0:	03813b83          	ld	s7,56(sp)
    ld s8, 64(sp)
    800010f4:	04013c03          	ld	s8,64(sp)
    ld s9, 72(sp)
    800010f8:	04813c83          	ld	s9,72(sp)
    ld s10, 80(sp)
    800010fc:	05013d03          	ld	s10,80(sp)
    ld s11, 88(sp)
    80001100:	05813d83          	ld	s11,88(sp)
    addi sp, sp, 96
    80001104:	06010113          	addi	sp,sp,96
    ret                    # skok na ra nove niti: usao kao stara, izasao kao nova
    80001108:	00008067          	ret

000000008000110c <_Z9mem_allocm>:
#include "../h/syscall_c.hpp"
#include "../lib/hw.h"

void* mem_alloc(size_t size) {
    8000110c:	ff010113          	addi	sp,sp,-16
    80001110:	00813423          	sd	s0,8(sp)
    80001114:	01010413          	addi	s0,sp,16
    if (size == 0) return nullptr;
    80001118:	02050063          	beqz	a0,80001138 <_Z9mem_allocm+0x2c>

    // abi poziv 0x01 prima velicinu u blokovima: zaokruzi bajtove navise
    size_t numBlocks = (size + MEM_BLOCK_SIZE - 1) / MEM_BLOCK_SIZE;
    8000111c:	03f50593          	addi	a1,a0,63

    // spakuj registre pa ecall; povratna vrednost stize nazad u a0
    register uint64 code   asm("a0") = 0x01;
    80001120:	00100513          	li	a0,1
    register uint64 blocks asm("a1") = numBlocks;
    80001124:	0065d593          	srli	a1,a1,0x6
    asm volatile("ecall"
        : "=r"(code)
        : "r"(code), "r"(blocks)
        : "memory");
    80001128:	00000073          	ecall

    return (void*)code;
}
    8000112c:	00813403          	ld	s0,8(sp)
    80001130:	01010113          	addi	sp,sp,16
    80001134:	00008067          	ret
    if (size == 0) return nullptr;
    80001138:	00000513          	li	a0,0
    8000113c:	ff1ff06f          	j	8000112c <_Z9mem_allocm+0x20>

0000000080001140 <_Z8mem_freePv>:

int mem_free(void* ptr) {
    80001140:	ff010113          	addi	sp,sp,-16
    80001144:	00813423          	sd	s0,8(sp)
    80001148:	01010413          	addi	s0,sp,16
    8000114c:	00050593          	mv	a1,a0
    // abi poziv 0x02: a1 = pokazivac dobijen iz mem_alloc
    register uint64 code asm("a0") = 0x02;
    80001150:	00200513          	li	a0,2
    register uint64 p    asm("a1") = (uint64)ptr;
    asm volatile("ecall"
        : "=r"(code)
        : "r"(code), "r"(p)
        : "memory");
    80001154:	00000073          	ecall

    return (int)code;   // 0 = uspeh, negativno = greska
}
    80001158:	0005051b          	sext.w	a0,a0
    8000115c:	00813403          	ld	s0,8(sp)
    80001160:	01010113          	addi	sp,sp,16
    80001164:	00008067          	ret

0000000080001168 <_Z5kputcc>:
#include "../h/print.hpp"

// posalji jedan znak kontroleru konzole (polling)
void kputc(char c) {
    80001168:	ff010113          	addi	sp,sp,-16
    8000116c:	00813423          	sd	s0,8(sp)
    80001170:	01010413          	addi	s0,sp,16
    // CONSOLE_STATUS je adresa (konstanta iz hw.h); da procitamo bajt sa te
    // adrese, kastujemo broj u pokazivac na volatile char pa dereferenciramo.
    // volatile: vrednost menja hardver, kompajler mora stvarno da cita
    // memoriju u svakom prolazu petlje, ne sme da kesira
    while ((*(volatile char*)CONSOLE_STATUS & (1 << 5)) == 0) {
    80001174:	00003797          	auipc	a5,0x3
    80001178:	e9c7b783          	ld	a5,-356(a5) # 80004010 <CONSOLE_STATUS>
    8000117c:	0007c783          	lbu	a5,0(a5)
    80001180:	0ff7f793          	andi	a5,a5,255
    80001184:	0207f793          	andi	a5,a5,32
    80001188:	fe0786e3          	beqz	a5,80001174 <_Z5kputcc+0xc>
        // bit 5 == 0 znaci "nisam spreman da primim znak za slanje"
    }
    // spreman: upisi bajt u registar za slanje
    *(volatile char*)CONSOLE_TX_DATA = c;
    8000118c:	00003797          	auipc	a5,0x3
    80001190:	e7c7b783          	ld	a5,-388(a5) # 80004008 <CONSOLE_TX_DATA>
    80001194:	00a78023          	sb	a0,0(a5)
}
    80001198:	00813403          	ld	s0,8(sp)
    8000119c:	01010113          	addi	sp,sp,16
    800011a0:	00008067          	ret

00000000800011a4 <_Z5kputsPKc>:

// ispisi ceo string, znak po znak
void kputs(const char* s) {
    800011a4:	fe010113          	addi	sp,sp,-32
    800011a8:	00113c23          	sd	ra,24(sp)
    800011ac:	00813823          	sd	s0,16(sp)
    800011b0:	00913423          	sd	s1,8(sp)
    800011b4:	02010413          	addi	s0,sp,32
    800011b8:	00050493          	mv	s1,a0
    while (*s) kputc(*s++);
    800011bc:	0004c503          	lbu	a0,0(s1)
    800011c0:	00050a63          	beqz	a0,800011d4 <_Z5kputsPKc+0x30>
    800011c4:	00148493          	addi	s1,s1,1
    800011c8:	00000097          	auipc	ra,0x0
    800011cc:	fa0080e7          	jalr	-96(ra) # 80001168 <_Z5kputcc>
    800011d0:	fedff06f          	j	800011bc <_Z5kputsPKc+0x18>
}
    800011d4:	01813083          	ld	ra,24(sp)
    800011d8:	01013403          	ld	s0,16(sp)
    800011dc:	00813483          	ld	s1,8(sp)
    800011e0:	02010113          	addi	sp,sp,32
    800011e4:	00008067          	ret

00000000800011e8 <_Z7kputhexm>:

// ispisi 64-bitni broj heksadecimalno (fiksno 16 cifara)
void kputhex(uint64 n) {
    800011e8:	fe010113          	addi	sp,sp,-32
    800011ec:	00113c23          	sd	ra,24(sp)
    800011f0:	00813823          	sd	s0,16(sp)
    800011f4:	00913423          	sd	s1,8(sp)
    800011f8:	01213023          	sd	s2,0(sp)
    800011fc:	02010413          	addi	s0,sp,32
    80001200:	00050913          	mv	s2,a0
    kputs("0x");
    80001204:	00003517          	auipc	a0,0x3
    80001208:	e1c50513          	addi	a0,a0,-484 # 80004020 <CONSOLE_STATUS+0x10>
    8000120c:	00000097          	auipc	ra,0x0
    80001210:	f98080e7          	jalr	-104(ra) # 800011a4 <_Z5kputsPKc>
    for (int shift = 60; shift >= 0; shift -= 4) {
    80001214:	03c00493          	li	s1,60
    80001218:	0140006f          	j	8000122c <_Z7kputhexm+0x44>
        uint64 digit = (n >> shift) & 0xF;
        char c;
        if (digit < 10) {
            c = '0' + digit;
        } else {
            c = 'a' + (digit - 10);
    8000121c:	05750513          	addi	a0,a0,87
        }
        kputc(c);
    80001220:	00000097          	auipc	ra,0x0
    80001224:	f48080e7          	jalr	-184(ra) # 80001168 <_Z5kputcc>
    for (int shift = 60; shift >= 0; shift -= 4) {
    80001228:	ffc4849b          	addiw	s1,s1,-4
    8000122c:	0004ce63          	bltz	s1,80001248 <_Z7kputhexm+0x60>
        uint64 digit = (n >> shift) & 0xF;
    80001230:	00995533          	srl	a0,s2,s1
    80001234:	00f57513          	andi	a0,a0,15
        if (digit < 10) {
    80001238:	00900793          	li	a5,9
    8000123c:	fea7e0e3          	bltu	a5,a0,8000121c <_Z7kputhexm+0x34>
            c = '0' + digit;
    80001240:	03050513          	addi	a0,a0,48
    80001244:	fddff06f          	j	80001220 <_Z7kputhexm+0x38>
    }
}
    80001248:	01813083          	ld	ra,24(sp)
    8000124c:	01013403          	ld	s0,16(sp)
    80001250:	00813483          	ld	s1,8(sp)
    80001254:	00013903          	ld	s2,0(sp)
    80001258:	02010113          	addi	sp,sp,32
    8000125c:	00008067          	ret

0000000080001260 <handleTrap>:
#include "../h/memoryAllocator.hpp"

// zajednicki c deo prekidne rutine: cita scause i grana se na obradu.
// a0..a3 parametri se poklapaju sa registrima a0..a3 u trenutku trapa
// (trap.S ih ne dira pre call-a), pa abi argumente citamo direktno.
extern "C" uint64 handleTrap(uint64 a0, uint64 a1, uint64 a2, uint64 a3) {
    80001260:	fd010113          	addi	sp,sp,-48
    80001264:	02113423          	sd	ra,40(sp)
    80001268:	02813023          	sd	s0,32(sp)
    8000126c:	00913c23          	sd	s1,24(sp)
    80001270:	01213823          	sd	s2,16(sp)
    80001274:	01313423          	sd	s3,8(sp)
    80001278:	03010413          	addi	s0,sp,48
    8000127c:	00050493          	mv	s1,a0
    uint64 cause;
    asm volatile("csrr %0, scause" : "=r"(cause));
    80001280:	14202973          	csrr	s2,scause

    uint64 topBit = cause >> 63;
    80001284:	03f95513          	srli	a0,s2,0x3f
    uint64 code   = cause & 0xff;
    80001288:	0ff97793          	andi	a5,s2,255

    if (topBit == 1) {
    8000128c:	08051863          	bnez	a0,8000131c <handleTrap+0xbc>
            plic_complete(irq);
        }
        // sepc se ne dira: prekinuta instrukcija mora da se ponovi
        return a0;
    }
    else if (topBit == 0 && (code == 8 || code == 9)) {
    80001290:	00051863          	bnez	a0,800012a0 <handleTrap+0x40>
    80001294:	ff878793          	addi	a5,a5,-8
    80001298:	00100713          	li	a4,1
    8000129c:	0af77e63          	bgeu	a4,a5,80001358 <handleTrap+0xf8>
    }

    // nepoznat uzrok (izuzetak koji ne umemo da obradimo): panika.
    // ne vracamo se - sepc bi pokazivao na istu instrukciju i vrteli bismo se.
    uint64 sepc;
    asm volatile("csrr %0, sepc" : "=r"(sepc));
    800012a0:	141029f3          	csrr	s3,sepc
    kputs("PANIC: cause="); kputhex(cause);
    800012a4:	00003517          	auipc	a0,0x3
    800012a8:	d8450513          	addi	a0,a0,-636 # 80004028 <CONSOLE_STATUS+0x18>
    800012ac:	00000097          	auipc	ra,0x0
    800012b0:	ef8080e7          	jalr	-264(ra) # 800011a4 <_Z5kputsPKc>
    800012b4:	00090513          	mv	a0,s2
    800012b8:	00000097          	auipc	ra,0x0
    800012bc:	f30080e7          	jalr	-208(ra) # 800011e8 <_Z7kputhexm>
    kputs(" sepc=");        kputhex(sepc);
    800012c0:	00003517          	auipc	a0,0x3
    800012c4:	d7850513          	addi	a0,a0,-648 # 80004038 <CONSOLE_STATUS+0x28>
    800012c8:	00000097          	auipc	ra,0x0
    800012cc:	edc080e7          	jalr	-292(ra) # 800011a4 <_Z5kputsPKc>
    800012d0:	00098513          	mv	a0,s3
    800012d4:	00000097          	auipc	ra,0x0
    800012d8:	f14080e7          	jalr	-236(ra) # 800011e8 <_Z7kputhexm>
    kputs("\n");
    800012dc:	00003517          	auipc	a0,0x3
    800012e0:	f4c50513          	addi	a0,a0,-180 # 80004228 <CONSOLE_STATUS+0x218>
    800012e4:	00000097          	auipc	ra,0x0
    800012e8:	ec0080e7          	jalr	-320(ra) # 800011a4 <_Z5kputsPKc>
    *(volatile int*)0x100000 = 0x5555;   // halt emulatora
    800012ec:	00100737          	lui	a4,0x100
    800012f0:	000057b7          	lui	a5,0x5
    800012f4:	5557879b          	addiw	a5,a5,1365
    800012f8:	00f72023          	sw	a5,0(a4) # 100000 <_entry-0x7ff00000>
    return a0;
    800012fc:	00048513          	mv	a0,s1
}
    80001300:	02813083          	ld	ra,40(sp)
    80001304:	02013403          	ld	s0,32(sp)
    80001308:	01813483          	ld	s1,24(sp)
    8000130c:	01013903          	ld	s2,16(sp)
    80001310:	00813983          	ld	s3,8(sp)
    80001314:	03010113          	addi	sp,sp,48
    80001318:	00008067          	ret
        if (code == 1) {
    8000131c:	00100713          	li	a4,1
    80001320:	00e78a63          	beq	a5,a4,80001334 <handleTrap+0xd4>
        } else if (code == 9) {
    80001324:	00900713          	li	a4,9
    80001328:	00e78e63          	beq	a5,a4,80001344 <handleTrap+0xe4>
        return a0;
    8000132c:	00048513          	mv	a0,s1
    80001330:	fd1ff06f          	j	80001300 <handleTrap+0xa0>
            asm volatile("csrr %0, sip" : "=r"(sip));
    80001334:	144027f3          	csrr	a5,sip
            sip &= ~(1UL << 1);
    80001338:	ffd7f793          	andi	a5,a5,-3
            asm volatile("csrw sip, %0" : : "r"(sip));
    8000133c:	14479073          	csrw	sip,a5
    80001340:	fedff06f          	j	8000132c <handleTrap+0xcc>
            int irq = plic_claim();
    80001344:	00001097          	auipc	ra,0x1
    80001348:	060080e7          	jalr	96(ra) # 800023a4 <plic_claim>
            plic_complete(irq);
    8000134c:	00001097          	auipc	ra,0x1
    80001350:	090080e7          	jalr	144(ra) # 800023dc <plic_complete>
    80001354:	fd9ff06f          	j	8000132c <handleTrap+0xcc>
        switch (a0) {
    80001358:	00100793          	li	a5,1
    8000135c:	00f48e63          	beq	s1,a5,80001378 <handleTrap+0x118>
    80001360:	00200793          	li	a5,2
    80001364:	02f48263          	beq	s1,a5,80001388 <handleTrap+0x128>
        asm volatile("csrr %0, sepc" : "=r"(sepc));
    80001368:	141027f3          	csrr	a5,sepc
        sepc += 4;
    8000136c:	00478793          	addi	a5,a5,4 # 5004 <_entry-0x7fffaffc>
        asm volatile("csrw sepc, %0" : : "r"(sepc));
    80001370:	14179073          	csrw	sepc,a5
        return ret;
    80001374:	f8dff06f          	j	80001300 <handleTrap+0xa0>
                ret = (uint64)MemoryAllocator::alloc(a1 * MEM_BLOCK_SIZE);
    80001378:	00659513          	slli	a0,a1,0x6
    8000137c:	00000097          	auipc	ra,0x0
    80001380:	480080e7          	jalr	1152(ra) # 800017fc <_ZN15MemoryAllocator5allocEm>
                break;
    80001384:	fe5ff06f          	j	80001368 <handleTrap+0x108>
                ret = (uint64)MemoryAllocator::free((void*)a1);
    80001388:	00058513          	mv	a0,a1
    8000138c:	00000097          	auipc	ra,0x0
    80001390:	5ac080e7          	jalr	1452(ra) # 80001938 <_ZN15MemoryAllocator4freeEPv>
                break;
    80001394:	fd5ff06f          	j	80001368 <handleTrap+0x108>

0000000080001398 <_ZL7workerBPv>:
        kputs("A");
        TCB::dispatch();
    }
}

static void workerB(void*) {
    80001398:	fe010113          	addi	sp,sp,-32
    8000139c:	00113c23          	sd	ra,24(sp)
    800013a0:	00813823          	sd	s0,16(sp)
    800013a4:	00913423          	sd	s1,8(sp)
    800013a8:	02010413          	addi	s0,sp,32
    for (int i = 0; i < 5; i++) {
    800013ac:	00000493          	li	s1,0
    800013b0:	00400793          	li	a5,4
    800013b4:	0297c263          	blt	a5,s1,800013d8 <_ZL7workerBPv+0x40>
        kputs("B");
    800013b8:	00003517          	auipc	a0,0x3
    800013bc:	c8850513          	addi	a0,a0,-888 # 80004040 <CONSOLE_STATUS+0x30>
    800013c0:	00000097          	auipc	ra,0x0
    800013c4:	de4080e7          	jalr	-540(ra) # 800011a4 <_Z5kputsPKc>
        TCB::dispatch();
    800013c8:	00000097          	auipc	ra,0x0
    800013cc:	274080e7          	jalr	628(ra) # 8000163c <_ZN3TCB8dispatchEv>
    for (int i = 0; i < 5; i++) {
    800013d0:	0014849b          	addiw	s1,s1,1
    800013d4:	fddff06f          	j	800013b0 <_ZL7workerBPv+0x18>
    }
}
    800013d8:	01813083          	ld	ra,24(sp)
    800013dc:	01013403          	ld	s0,16(sp)
    800013e0:	00813483          	ld	s1,8(sp)
    800013e4:	02010113          	addi	sp,sp,32
    800013e8:	00008067          	ret

00000000800013ec <_ZL7workerAPv>:
static void workerA(void*) {
    800013ec:	fe010113          	addi	sp,sp,-32
    800013f0:	00113c23          	sd	ra,24(sp)
    800013f4:	00813823          	sd	s0,16(sp)
    800013f8:	00913423          	sd	s1,8(sp)
    800013fc:	02010413          	addi	s0,sp,32
    for (int i = 0; i < 5; i++) {
    80001400:	00000493          	li	s1,0
    80001404:	00400793          	li	a5,4
    80001408:	0297c263          	blt	a5,s1,8000142c <_ZL7workerAPv+0x40>
        kputs("A");
    8000140c:	00003517          	auipc	a0,0x3
    80001410:	c3c50513          	addi	a0,a0,-964 # 80004048 <CONSOLE_STATUS+0x38>
    80001414:	00000097          	auipc	ra,0x0
    80001418:	d90080e7          	jalr	-624(ra) # 800011a4 <_Z5kputsPKc>
        TCB::dispatch();
    8000141c:	00000097          	auipc	ra,0x0
    80001420:	220080e7          	jalr	544(ra) # 8000163c <_ZN3TCB8dispatchEv>
    for (int i = 0; i < 5; i++) {
    80001424:	0014849b          	addiw	s1,s1,1
    80001428:	fddff06f          	j	80001404 <_ZL7workerAPv+0x18>
}
    8000142c:	01813083          	ld	ra,24(sp)
    80001430:	01013403          	ld	s0,16(sp)
    80001434:	00813483          	ld	s1,8(sp)
    80001438:	02010113          	addi	sp,sp,32
    8000143c:	00008067          	ret

0000000080001440 <_Z8userMainv>:

void userMain() {
    80001440:	fe010113          	addi	sp,sp,-32
    80001444:	00113c23          	sd	ra,24(sp)
    80001448:	00813823          	sd	s0,16(sp)
    8000144c:	00913423          	sd	s1,8(sp)
    80001450:	01213023          	sd	s2,0(sp)
    80001454:	02010413          	addi	s0,sp,32
    TCB* a = TCB::createThread(workerA, nullptr);
    80001458:	00000593          	li	a1,0
    8000145c:	00000517          	auipc	a0,0x0
    80001460:	f9050513          	addi	a0,a0,-112 # 800013ec <_ZL7workerAPv>
    80001464:	00000097          	auipc	ra,0x0
    80001468:	0ec080e7          	jalr	236(ra) # 80001550 <_ZN3TCB12createThreadEPFvPvES0_>
    8000146c:	00050493          	mv	s1,a0
    TCB* b = TCB::createThread(workerB, nullptr);
    80001470:	00000593          	li	a1,0
    80001474:	00000517          	auipc	a0,0x0
    80001478:	f2450513          	addi	a0,a0,-220 # 80001398 <_ZL7workerBPv>
    8000147c:	00000097          	auipc	ra,0x0
    80001480:	0d4080e7          	jalr	212(ra) # 80001550 <_ZN3TCB12createThreadEPFvPvES0_>
    80001484:	00050913          	mv	s2,a0
    80001488:	00c0006f          	j	80001494 <_Z8userMainv+0x54>

    // main (nulta nit) vrti dispatch dok obe ne zavrse
    while (!a->isFinished() || !b->isFinished()) {
        TCB::dispatch();
    8000148c:	00000097          	auipc	ra,0x0
    80001490:	1b0080e7          	jalr	432(ra) # 8000163c <_ZN3TCB8dispatchEv>
    static TCB* createThread(Body body, void* arg);

    // sinhrona promena konteksta: tekuca nit ustupa procesor sledecoj iz reda
    static void dispatch();

    bool isFinished() const { return finished; }
    80001494:	0284c783          	lbu	a5,40(s1)
    while (!a->isFinished() || !b->isFinished()) {
    80001498:	fe078ae3          	beqz	a5,8000148c <_Z8userMainv+0x4c>
    8000149c:	02894783          	lbu	a5,40(s2)
    800014a0:	fe0786e3          	beqz	a5,8000148c <_Z8userMainv+0x4c>
    }
    kputs("\nobe niti zavrsile\n");
    800014a4:	00003517          	auipc	a0,0x3
    800014a8:	bac50513          	addi	a0,a0,-1108 # 80004050 <CONSOLE_STATUS+0x40>
    800014ac:	00000097          	auipc	ra,0x0
    800014b0:	cf8080e7          	jalr	-776(ra) # 800011a4 <_Z5kputsPKc>
}
    800014b4:	01813083          	ld	ra,24(sp)
    800014b8:	01013403          	ld	s0,16(sp)
    800014bc:	00813483          	ld	s1,8(sp)
    800014c0:	00013903          	ld	s2,0(sp)
    800014c4:	02010113          	addi	sp,sp,32
    800014c8:	00008067          	ret

00000000800014cc <_ZN3TCBnwEm>:
extern "C" void contextSwitch(TCB::Context* oldCtx, TCB::Context* newCtx);

TCB* TCB::running = nullptr;

// new/delete za tcb: direktno na alokator jezgra (bez ecall-a)
void* TCB::operator new(size_t size) {
    800014cc:	ff010113          	addi	sp,sp,-16
    800014d0:	00113423          	sd	ra,8(sp)
    800014d4:	00813023          	sd	s0,0(sp)
    800014d8:	01010413          	addi	s0,sp,16
    return MemoryAllocator::alloc(size);
    800014dc:	00000097          	auipc	ra,0x0
    800014e0:	320080e7          	jalr	800(ra) # 800017fc <_ZN15MemoryAllocator5allocEm>
}
    800014e4:	00813083          	ld	ra,8(sp)
    800014e8:	00013403          	ld	s0,0(sp)
    800014ec:	01010113          	addi	sp,sp,16
    800014f0:	00008067          	ret

00000000800014f4 <_ZN3TCBdlEPv>:
void TCB::operator delete(void* ptr) {
    800014f4:	ff010113          	addi	sp,sp,-16
    800014f8:	00113423          	sd	ra,8(sp)
    800014fc:	00813023          	sd	s0,0(sp)
    80001500:	01010413          	addi	s0,sp,16
    MemoryAllocator::free(ptr);
    80001504:	00000097          	auipc	ra,0x0
    80001508:	434080e7          	jalr	1076(ra) # 80001938 <_ZN15MemoryAllocator4freeEPv>
}
    8000150c:	00813083          	ld	ra,8(sp)
    80001510:	00013403          	ld	s0,0(sp)
    80001514:	01010113          	addi	sp,sp,16
    80001518:	00008067          	ret

000000008000151c <_ZN3TCBC1EPFvPvES0_Pm>:

TCB::TCB(Body body, void* arg, uint64* stack)
    8000151c:	ff010113          	addi	sp,sp,-16
    80001520:	00813423          	sd	s0,8(sp)
    80001524:	01010413          	addi	s0,sp,16
    : body(body), arg(arg), stack(stack),
      context({0, 0}),
      finished(false), next(nullptr)
    80001528:	00b53023          	sd	a1,0(a0)
    8000152c:	00c53423          	sd	a2,8(a0)
    80001530:	00d53823          	sd	a3,16(a0)
    80001534:	00053c23          	sd	zero,24(a0)
    80001538:	02053023          	sd	zero,32(a0)
    8000153c:	02050423          	sb	zero,40(a0)
    80001540:	02053823          	sd	zero,48(a0)
{}
    80001544:	00813403          	ld	s0,8(sp)
    80001548:	01010113          	addi	sp,sp,16
    8000154c:	00008067          	ret

0000000080001550 <_ZN3TCB12createThreadEPFvPvES0_>:
    running->body(running->arg);
    running->finished = true;
    dispatch();   // odavde nema povratka
}

TCB* TCB::createThread(Body body, void* arg) {
    80001550:	fd010113          	addi	sp,sp,-48
    80001554:	02113423          	sd	ra,40(sp)
    80001558:	02813023          	sd	s0,32(sp)
    8000155c:	00913c23          	sd	s1,24(sp)
    80001560:	01213823          	sd	s2,16(sp)
    80001564:	01313423          	sd	s3,8(sp)
    80001568:	01413023          	sd	s4,0(sp)
    8000156c:	03010413          	addi	s0,sp,48
    80001570:	00050993          	mv	s3,a0
    80001574:	00058a13          	mv	s4,a1
    // stek niti: DEFAULT_STACK_SIZE bajtova iz hw.h
    uint64* stack = (uint64*)MemoryAllocator::alloc(DEFAULT_STACK_SIZE);
    80001578:	00001537          	lui	a0,0x1
    8000157c:	00000097          	auipc	ra,0x0
    80001580:	280080e7          	jalr	640(ra) # 800017fc <_ZN15MemoryAllocator5allocEm>
    80001584:	00050493          	mv	s1,a0
    if (!stack) return nullptr;
    80001588:	0a050663          	beqz	a0,80001634 <_ZN3TCB12createThreadEPFvPvES0_+0xe4>

    TCB* tcb = new TCB(body, arg, stack);
    8000158c:	03800513          	li	a0,56
    80001590:	00000097          	auipc	ra,0x0
    80001594:	f3c080e7          	jalr	-196(ra) # 800014cc <_ZN3TCBnwEm>
    80001598:	00050913          	mv	s2,a0
    8000159c:	00048693          	mv	a3,s1
    800015a0:	000a0613          	mv	a2,s4
    800015a4:	00098593          	mv	a1,s3
    800015a8:	00000097          	auipc	ra,0x0
    800015ac:	f74080e7          	jalr	-140(ra) # 8000151c <_ZN3TCBC1EPFvPvES0_Pm>
    if (!tcb) { MemoryAllocator::free(stack); return nullptr; }
    800015b0:	02090a63          	beqz	s2,800015e4 <_ZN3TCB12createThreadEPFvPvES0_+0x94>

    // bootstrap: falsifikuj proslost niti da izgleda kao da je "zaspala"
    // na samom ulazu u threadWrapper. prvo budjenje (contextSwitch) ce:
    // pokupiti 12 laznih s-registara sa steka, pa ret na threadWrapper.
    uint64 top = (uint64)stack + DEFAULT_STACK_SIZE;   // stek raste ka nizim adresama
    tcb->context.sp = top - 96;                        // mesto za 12 "s-registara"
    800015b4:	000016b7          	lui	a3,0x1
    800015b8:	fa068693          	addi	a3,a3,-96 # fa0 <_entry-0x7ffff060>
    800015bc:	00d486b3          	add	a3,s1,a3
    800015c0:	02d93023          	sd	a3,32(s2)
    uint64* fakeRegs = (uint64*)tcb->context.sp;
    for (int i = 0; i < 12; i++) fakeRegs[i] = 0;      // nit krece cistih ruku
    800015c4:	00000793          	li	a5,0
    800015c8:	00b00713          	li	a4,11
    800015cc:	02f74463          	blt	a4,a5,800015f4 <_ZN3TCB12createThreadEPFvPvES0_+0xa4>
    800015d0:	00379713          	slli	a4,a5,0x3
    800015d4:	00e68733          	add	a4,a3,a4
    800015d8:	00073023          	sd	zero,0(a4)
    800015dc:	0017879b          	addiw	a5,a5,1
    800015e0:	fe9ff06f          	j	800015c8 <_ZN3TCB12createThreadEPFvPvES0_+0x78>
    if (!tcb) { MemoryAllocator::free(stack); return nullptr; }
    800015e4:	00048513          	mv	a0,s1
    800015e8:	00000097          	auipc	ra,0x0
    800015ec:	350080e7          	jalr	848(ra) # 80001938 <_ZN15MemoryAllocator4freeEPv>
    800015f0:	0200006f          	j	80001610 <_ZN3TCB12createThreadEPFvPvES0_+0xc0>
    tcb->context.ra = (uint64)&threadWrapper;
    800015f4:	00000797          	auipc	a5,0x0
    800015f8:	0e478793          	addi	a5,a5,228 # 800016d8 <_ZN3TCB13threadWrapperEv>
    800015fc:	00f93c23          	sd	a5,24(s2)

    // main-ova nulta nit (body == nullptr) se ne raspredjuje kroz red
    if (body) Scheduler::put(tcb);
    80001600:	00098863          	beqz	s3,80001610 <_ZN3TCB12createThreadEPFvPvES0_+0xc0>
    80001604:	00090513          	mv	a0,s2
    80001608:	00000097          	auipc	ra,0x0
    8000160c:	124080e7          	jalr	292(ra) # 8000172c <_ZN9Scheduler3putEP3TCB>
    return tcb;
}
    80001610:	00090513          	mv	a0,s2
    80001614:	02813083          	ld	ra,40(sp)
    80001618:	02013403          	ld	s0,32(sp)
    8000161c:	01813483          	ld	s1,24(sp)
    80001620:	01013903          	ld	s2,16(sp)
    80001624:	00813983          	ld	s3,8(sp)
    80001628:	00013a03          	ld	s4,0(sp)
    8000162c:	03010113          	addi	sp,sp,48
    80001630:	00008067          	ret
    if (!stack) return nullptr;
    80001634:	00050913          	mv	s2,a0
    80001638:	fd9ff06f          	j	80001610 <_ZN3TCB12createThreadEPFvPvES0_+0xc0>

000000008000163c <_ZN3TCB8dispatchEv>:

// sinhrona promena konteksta: tekuca nit ustupa procesor
void TCB::dispatch() {
    8000163c:	fe010113          	addi	sp,sp,-32
    80001640:	00113c23          	sd	ra,24(sp)
    80001644:	00813823          	sd	s0,16(sp)
    80001648:	00913423          	sd	s1,8(sp)
    8000164c:	01213023          	sd	s2,0(sp)
    80001650:	02010413          	addi	s0,sp,32
    TCB* old = running;
    80001654:	00003917          	auipc	s2,0x3
    80001658:	09c93903          	ld	s2,156(s2) # 800046f0 <_ZN3TCB7runningE>
    if (!old->finished) Scheduler::put(old);   // gotova nit se ne vraca u red
    8000165c:	02894783          	lbu	a5,40(s2)
    80001660:	04078263          	beqz	a5,800016a4 <_ZN3TCB8dispatchEv+0x68>

    TCB* next = Scheduler::get();
    80001664:	00000097          	auipc	ra,0x0
    80001668:	108080e7          	jalr	264(ra) # 8000176c <_ZN9Scheduler3getEv>
    8000166c:	00050493          	mv	s1,a0
    if (!next) {
    80001670:	04050263          	beqz	a0,800016b4 <_ZN3TCB8dispatchEv+0x78>
        // nema nijedne spremne niti, a tekuca je gotova: sistem nema sta da radi
        kputs("PANIC: nema spremnih niti\n");
        *(volatile int*)0x100000 = 0x5555;
    }

    running = next;
    80001674:	00003797          	auipc	a5,0x3
    80001678:	0697be23          	sd	s1,124(a5) # 800046f0 <_ZN3TCB7runningE>
    contextSwitch(&old->context, &running->context);
    8000167c:	01848593          	addi	a1,s1,24
    80001680:	01890513          	addi	a0,s2,24
    80001684:	00000097          	auipc	ra,0x0
    80001688:	a0c080e7          	jalr	-1524(ra) # 80001090 <contextSwitch>
    // odavde se nastavlja tek kad neko VRATI procesor staroj niti
}
    8000168c:	01813083          	ld	ra,24(sp)
    80001690:	01013403          	ld	s0,16(sp)
    80001694:	00813483          	ld	s1,8(sp)
    80001698:	00013903          	ld	s2,0(sp)
    8000169c:	02010113          	addi	sp,sp,32
    800016a0:	00008067          	ret
    if (!old->finished) Scheduler::put(old);   // gotova nit se ne vraca u red
    800016a4:	00090513          	mv	a0,s2
    800016a8:	00000097          	auipc	ra,0x0
    800016ac:	084080e7          	jalr	132(ra) # 8000172c <_ZN9Scheduler3putEP3TCB>
    800016b0:	fb5ff06f          	j	80001664 <_ZN3TCB8dispatchEv+0x28>
        kputs("PANIC: nema spremnih niti\n");
    800016b4:	00003517          	auipc	a0,0x3
    800016b8:	9b450513          	addi	a0,a0,-1612 # 80004068 <CONSOLE_STATUS+0x58>
    800016bc:	00000097          	auipc	ra,0x0
    800016c0:	ae8080e7          	jalr	-1304(ra) # 800011a4 <_Z5kputsPKc>
        *(volatile int*)0x100000 = 0x5555;
    800016c4:	00100737          	lui	a4,0x100
    800016c8:	000057b7          	lui	a5,0x5
    800016cc:	5557879b          	addiw	a5,a5,1365
    800016d0:	00f72023          	sw	a5,0(a4) # 100000 <_entry-0x7ff00000>
    800016d4:	fa1ff06f          	j	80001674 <_ZN3TCB8dispatchEv+0x38>

00000000800016d8 <_ZN3TCB13threadWrapperEv>:
void TCB::threadWrapper() {
    800016d8:	fe010113          	addi	sp,sp,-32
    800016dc:	00113c23          	sd	ra,24(sp)
    800016e0:	00813823          	sd	s0,16(sp)
    800016e4:	00913423          	sd	s1,8(sp)
    800016e8:	02010413          	addi	s0,sp,32
    running->body(running->arg);
    800016ec:	00003497          	auipc	s1,0x3
    800016f0:	00448493          	addi	s1,s1,4 # 800046f0 <_ZN3TCB7runningE>
    800016f4:	0004b783          	ld	a5,0(s1)
    800016f8:	0007b703          	ld	a4,0(a5) # 5000 <_entry-0x7fffb000>
    800016fc:	0087b503          	ld	a0,8(a5)
    80001700:	000700e7          	jalr	a4
    running->finished = true;
    80001704:	0004b783          	ld	a5,0(s1)
    80001708:	00100713          	li	a4,1
    8000170c:	02e78423          	sb	a4,40(a5)
    dispatch();   // odavde nema povratka
    80001710:	00000097          	auipc	ra,0x0
    80001714:	f2c080e7          	jalr	-212(ra) # 8000163c <_ZN3TCB8dispatchEv>
}
    80001718:	01813083          	ld	ra,24(sp)
    8000171c:	01013403          	ld	s0,16(sp)
    80001720:	00813483          	ld	s1,8(sp)
    80001724:	02010113          	addi	sp,sp,32
    80001728:	00008067          	ret

000000008000172c <_ZN9Scheduler3putEP3TCB>:

TCB* Scheduler::head = nullptr;
TCB* Scheduler::tail = nullptr;

// stani na kraj reda
void Scheduler::put(TCB* thread) {
    8000172c:	ff010113          	addi	sp,sp,-16
    80001730:	00813423          	sd	s0,8(sp)
    80001734:	01010413          	addi	s0,sp,16
    thread->next = nullptr;
    80001738:	02053823          	sd	zero,48(a0)
    if (tail) {
    8000173c:	00003797          	auipc	a5,0x3
    80001740:	fbc7b783          	ld	a5,-68(a5) # 800046f8 <_ZN9Scheduler4tailE>
    80001744:	00078e63          	beqz	a5,80001760 <_ZN9Scheduler3putEP3TCB+0x34>
        tail->next = thread;   // dosadasnji poslednji pokaze na novog
    80001748:	02a7b823          	sd	a0,48(a5)
    } else {
        head = thread;         // red je bio prazan: novi je i prvi
    }
    tail = thread;             // novi je u svakom slucaju poslednji
    8000174c:	00003797          	auipc	a5,0x3
    80001750:	faa7b623          	sd	a0,-84(a5) # 800046f8 <_ZN9Scheduler4tailE>
}
    80001754:	00813403          	ld	s0,8(sp)
    80001758:	01010113          	addi	sp,sp,16
    8000175c:	00008067          	ret
        head = thread;         // red je bio prazan: novi je i prvi
    80001760:	00003797          	auipc	a5,0x3
    80001764:	faa7b023          	sd	a0,-96(a5) # 80004700 <_ZN9Scheduler4headE>
    80001768:	fe5ff06f          	j	8000174c <_ZN9Scheduler3putEP3TCB+0x20>

000000008000176c <_ZN9Scheduler3getEv>:

// skini nit sa cela reda
TCB* Scheduler::get() {
    8000176c:	ff010113          	addi	sp,sp,-16
    80001770:	00813423          	sd	s0,8(sp)
    80001774:	01010413          	addi	s0,sp,16
    TCB* thread = head;
    80001778:	00003517          	auipc	a0,0x3
    8000177c:	f8853503          	ld	a0,-120(a0) # 80004700 <_ZN9Scheduler4headE>
    if (!thread) return nullptr;   // prazan red
    80001780:	00050c63          	beqz	a0,80001798 <_ZN9Scheduler3getEv+0x2c>
    head = head->next;
    80001784:	03053783          	ld	a5,48(a0)
    80001788:	00003717          	auipc	a4,0x3
    8000178c:	f6f73c23          	sd	a5,-136(a4) # 80004700 <_ZN9Scheduler4headE>
    if (!head) tail = nullptr;     // skinuli smo i poslednjeg
    80001790:	00078a63          	beqz	a5,800017a4 <_ZN9Scheduler3getEv+0x38>
    thread->next = nullptr;
    80001794:	02053823          	sd	zero,48(a0)
    return thread;
}
    80001798:	00813403          	ld	s0,8(sp)
    8000179c:	01010113          	addi	sp,sp,16
    800017a0:	00008067          	ret
    if (!head) tail = nullptr;     // skinuli smo i poslednjeg
    800017a4:	00003797          	auipc	a5,0x3
    800017a8:	f407ba23          	sd	zero,-172(a5) # 800046f8 <_ZN9Scheduler4tailE>
    800017ac:	fe9ff06f          	j	80001794 <_ZN9Scheduler3getEv+0x28>

00000000800017b0 <_ZN15MemoryAllocator4initEv>:
#include "../h/print.hpp"

MemoryAllocator::FreeBlock* MemoryAllocator::freeListHead = nullptr;

// ceo heap = jedan slobodan blok
void MemoryAllocator::init() {
    800017b0:	ff010113          	addi	sp,sp,-16
    800017b4:	00813423          	sd	s0,8(sp)
    800017b8:	01010413          	addi	s0,sp,16
    freeListHead = (FreeBlock*)HEAP_START_ADDR;
    800017bc:	00003797          	auipc	a5,0x3
    800017c0:	f0c78793          	addi	a5,a5,-244 # 800046c8 <HEAP_START_ADDR>
    800017c4:	0007b683          	ld	a3,0(a5)
    800017c8:	00003717          	auipc	a4,0x3
    800017cc:	f4070713          	addi	a4,a4,-192 # 80004708 <_ZN15MemoryAllocator12freeListHeadE>
    800017d0:	00d73023          	sd	a3,0(a4)
    freeListHead->next = nullptr;
    800017d4:	0006b023          	sd	zero,0(a3)
    freeListHead->size = (char*)HEAP_END_ADDR - (char*)HEAP_START_ADDR;
    800017d8:	0007b683          	ld	a3,0(a5)
    800017dc:	00073703          	ld	a4,0(a4)
    800017e0:	00003797          	auipc	a5,0x3
    800017e4:	ee07b783          	ld	a5,-288(a5) # 800046c0 <HEAP_END_ADDR>
    800017e8:	40d787b3          	sub	a5,a5,a3
    800017ec:	00f73423          	sd	a5,8(a4)
}
    800017f0:	00813403          	ld	s0,8(sp)
    800017f4:	01010113          	addi	sp,sp,16
    800017f8:	00008067          	ret

00000000800017fc <_ZN15MemoryAllocator5allocEm>:

void* MemoryAllocator::alloc(size_t size){
    800017fc:	ff010113          	addi	sp,sp,-16
    80001800:	00813423          	sd	s0,8(sp)
    80001804:	01010413          	addi	s0,sp,16
    if (size == 0) {
    80001808:	08050a63          	beqz	a0,8000189c <_ZN15MemoryAllocator5allocEm+0xa0>
        return nullptr;
    }
    // zaokruzivanje navise: ((n + B - 1) / B) * B; heder ukljucen u racun
    // da payload uvek bude >= size
    size_t n = size + sizeof(FreeBlock);
    size_t roundedSize = ((n + MEM_BLOCK_SIZE - 1) / MEM_BLOCK_SIZE) * MEM_BLOCK_SIZE;
    8000180c:	04f50513          	addi	a0,a0,79
    80001810:	fc057713          	andi	a4,a0,-64

    // first-fit kroz slobodnu listu
    FreeBlock* curr = freeListHead;
    80001814:	00003517          	auipc	a0,0x3
    80001818:	ef453503          	ld	a0,-268(a0) # 80004708 <_ZN15MemoryAllocator12freeListHeadE>
    FreeBlock* prev = nullptr;
    8000181c:	00000693          	li	a3,0
    while(curr != nullptr){
    80001820:	04050263          	beqz	a0,80001864 <_ZN15MemoryAllocator5allocEm+0x68>
        if(curr->size >= roundedSize){
    80001824:	00853783          	ld	a5,8(a0)
    80001828:	00e7f863          	bgeu	a5,a4,80001838 <_ZN15MemoryAllocator5allocEm+0x3c>
                    freeListHead = curr->next;
                }
            }
            return (char*)curr + sizeof(FreeBlock);
        }
        prev = curr;
    8000182c:	00050693          	mv	a3,a0
        curr = curr->next;
    80001830:	00053503          	ld	a0,0(a0)
    while(curr != nullptr){
    80001834:	fedff06f          	j	80001820 <_ZN15MemoryAllocator5allocEm+0x24>
            size_t remainder = curr->size - roundedSize;
    80001838:	40e787b3          	sub	a5,a5,a4
            if (remainder >= MEM_BLOCK_SIZE) {
    8000183c:	03f00613          	li	a2,63
    80001840:	02f67e63          	bgeu	a2,a5,8000187c <_ZN15MemoryAllocator5allocEm+0x80>
                FreeBlock* newBlock = (FreeBlock*)((char*)curr + roundedSize);
    80001844:	00e50633          	add	a2,a0,a4
                newBlock->size = remainder;
    80001848:	00f63423          	sd	a5,8(a2)
                newBlock->next = curr->next;
    8000184c:	00053783          	ld	a5,0(a0)
    80001850:	00f63023          	sd	a5,0(a2)
                if (prev != nullptr) {
    80001854:	00068e63          	beqz	a3,80001870 <_ZN15MemoryAllocator5allocEm+0x74>
                    prev->next = newBlock;
    80001858:	00c6b023          	sd	a2,0(a3)
                curr->size = roundedSize;
    8000185c:	00e53423          	sd	a4,8(a0)
            return (char*)curr + sizeof(FreeBlock);
    80001860:	01050513          	addi	a0,a0,16
    }
    return nullptr;   // nema dovoljno velikog bloka
}
    80001864:	00813403          	ld	s0,8(sp)
    80001868:	01010113          	addi	sp,sp,16
    8000186c:	00008067          	ret
                    freeListHead = newBlock;
    80001870:	00003797          	auipc	a5,0x3
    80001874:	e8c7bc23          	sd	a2,-360(a5) # 80004708 <_ZN15MemoryAllocator12freeListHeadE>
    80001878:	fe5ff06f          	j	8000185c <_ZN15MemoryAllocator5allocEm+0x60>
                if (prev != nullptr) {
    8000187c:	00068863          	beqz	a3,8000188c <_ZN15MemoryAllocator5allocEm+0x90>
                    prev->next = curr->next;
    80001880:	00053783          	ld	a5,0(a0)
    80001884:	00f6b023          	sd	a5,0(a3)
    80001888:	fd9ff06f          	j	80001860 <_ZN15MemoryAllocator5allocEm+0x64>
                    freeListHead = curr->next;
    8000188c:	00053783          	ld	a5,0(a0)
    80001890:	00003717          	auipc	a4,0x3
    80001894:	e6f73c23          	sd	a5,-392(a4) # 80004708 <_ZN15MemoryAllocator12freeListHeadE>
    80001898:	fc9ff06f          	j	80001860 <_ZN15MemoryAllocator5allocEm+0x64>
        return nullptr;
    8000189c:	00000513          	li	a0,0
    800018a0:	fc5ff06f          	j	80001864 <_ZN15MemoryAllocator5allocEm+0x68>

00000000800018a4 <_ZN15MemoryAllocator13printFreeListEv>:

// debug ispis slobodne liste (nije deo resenja koje se predaje)
void MemoryAllocator::printFreeList() {
    800018a4:	fe010113          	addi	sp,sp,-32
    800018a8:	00113c23          	sd	ra,24(sp)
    800018ac:	00813823          	sd	s0,16(sp)
    800018b0:	00913423          	sd	s1,8(sp)
    800018b4:	02010413          	addi	s0,sp,32
    FreeBlock* curr = freeListHead;
    800018b8:	00003497          	auipc	s1,0x3
    800018bc:	e504b483          	ld	s1,-432(s1) # 80004708 <_ZN15MemoryAllocator12freeListHeadE>
    kputs("free list:\n");
    800018c0:	00002517          	auipc	a0,0x2
    800018c4:	7c850513          	addi	a0,a0,1992 # 80004088 <CONSOLE_STATUS+0x78>
    800018c8:	00000097          	auipc	ra,0x0
    800018cc:	8dc080e7          	jalr	-1828(ra) # 800011a4 <_Z5kputsPKc>
    while (curr != nullptr) {
    800018d0:	04048a63          	beqz	s1,80001924 <_ZN15MemoryAllocator13printFreeListEv+0x80>
        kputs("  blok na ");
    800018d4:	00002517          	auipc	a0,0x2
    800018d8:	7c450513          	addi	a0,a0,1988 # 80004098 <CONSOLE_STATUS+0x88>
    800018dc:	00000097          	auipc	ra,0x0
    800018e0:	8c8080e7          	jalr	-1848(ra) # 800011a4 <_Z5kputsPKc>
        kputhex((uint64)curr);
    800018e4:	00048513          	mv	a0,s1
    800018e8:	00000097          	auipc	ra,0x0
    800018ec:	900080e7          	jalr	-1792(ra) # 800011e8 <_Z7kputhexm>
        kputs(", size: ");
    800018f0:	00002517          	auipc	a0,0x2
    800018f4:	7b850513          	addi	a0,a0,1976 # 800040a8 <CONSOLE_STATUS+0x98>
    800018f8:	00000097          	auipc	ra,0x0
    800018fc:	8ac080e7          	jalr	-1876(ra) # 800011a4 <_Z5kputsPKc>
        kputhex(curr->size);
    80001900:	0084b503          	ld	a0,8(s1)
    80001904:	00000097          	auipc	ra,0x0
    80001908:	8e4080e7          	jalr	-1820(ra) # 800011e8 <_Z7kputhexm>
        kputs("\n");
    8000190c:	00003517          	auipc	a0,0x3
    80001910:	91c50513          	addi	a0,a0,-1764 # 80004228 <CONSOLE_STATUS+0x218>
    80001914:	00000097          	auipc	ra,0x0
    80001918:	890080e7          	jalr	-1904(ra) # 800011a4 <_Z5kputsPKc>
        curr = curr->next;
    8000191c:	0004b483          	ld	s1,0(s1)
    while (curr != nullptr) {
    80001920:	fb1ff06f          	j	800018d0 <_ZN15MemoryAllocator13printFreeListEv+0x2c>
    }
}
    80001924:	01813083          	ld	ra,24(sp)
    80001928:	01013403          	ld	s0,16(sp)
    8000192c:	00813483          	ld	s1,8(sp)
    80001930:	02010113          	addi	sp,sp,32
    80001934:	00008067          	ret

0000000080001938 <_ZN15MemoryAllocator4freeEPv>:

int MemoryAllocator::free(void* ptr){
    80001938:	ff010113          	addi	sp,sp,-16
    8000193c:	00813423          	sd	s0,8(sp)
    80001940:	01010413          	addi	s0,sp,16
    if (ptr == nullptr) return -1;
    80001944:	12050663          	beqz	a0,80001a70 <_ZN15MemoryAllocator4freeEPv+0x138>
    FreeBlock* curr = freeListHead;
    80001948:	00003797          	auipc	a5,0x3
    8000194c:	dc07b783          	ld	a5,-576(a5) # 80004708 <_ZN15MemoryAllocator12freeListHeadE>
    FreeBlock* prev = nullptr;
    // heder zivi tacno ispred payload-a
    FreeBlock* block = (FreeBlock*)((char*)ptr - sizeof(FreeBlock));
    80001950:	ff050693          	addi	a3,a0,-16
    FreeBlock* prev = nullptr;
    80001954:	00000713          	li	a4,0
    // nadji mesto po adresi (lista je sortirana da bi spajanje radilo)
    while(curr != nullptr && curr < block){
    80001958:	00078a63          	beqz	a5,8000196c <_ZN15MemoryAllocator4freeEPv+0x34>
    8000195c:	00d7f863          	bgeu	a5,a3,8000196c <_ZN15MemoryAllocator4freeEPv+0x34>
        prev = curr;
    80001960:	00078713          	mv	a4,a5
        curr = curr->next;
    80001964:	0007b783          	ld	a5,0(a5)
    while(curr != nullptr && curr < block){
    80001968:	ff1ff06f          	j	80001958 <_ZN15MemoryAllocator4freeEPv+0x20>
    }

    // da li se blok fizicki naslanja na suseda ispred/iza?
    bool mergePrev = (prev != nullptr) && ((char*)prev + prev->size == (char*)block);
    8000196c:	04070263          	beqz	a4,800019b0 <_ZN15MemoryAllocator4freeEPv+0x78>
    80001970:	00873603          	ld	a2,8(a4)
    80001974:	00c70633          	add	a2,a4,a2
    80001978:	04d60063          	beq	a2,a3,800019b8 <_ZN15MemoryAllocator4freeEPv+0x80>
    8000197c:	00000613          	li	a2,0
    bool mergeNext = (curr != nullptr) && ((char*)block + block->size == (char*)curr);
    80001980:	04078063          	beqz	a5,800019c0 <_ZN15MemoryAllocator4freeEPv+0x88>
    80001984:	ff853583          	ld	a1,-8(a0)
    80001988:	00b685b3          	add	a1,a3,a1
    8000198c:	02f58e63          	beq	a1,a5,800019c8 <_ZN15MemoryAllocator4freeEPv+0x90>
    80001990:	00000593          	li	a1,0

    if (!mergePrev && !mergeNext) {
    80001994:	04061663          	bnez	a2,800019e0 <_ZN15MemoryAllocator4freeEPv+0xa8>
    80001998:	04059463          	bnez	a1,800019e0 <_ZN15MemoryAllocator4freeEPv+0xa8>
        // nema spajanja: samo umetni izmedju prev i curr
        block->next = curr;
    8000199c:	fef53823          	sd	a5,-16(a0)
        if (prev != nullptr) {
    800019a0:	02070863          	beqz	a4,800019d0 <_ZN15MemoryAllocator4freeEPv+0x98>
            prev->next = block;
    800019a4:	00d73023          	sd	a3,0(a4)
    } else {
        // spoji sa oba suseda
        prev->size += block->size + curr->size;
        prev->next = curr->next;
    }
    return 0;
    800019a8:	00000513          	li	a0,0
    800019ac:	0b80006f          	j	80001a64 <_ZN15MemoryAllocator4freeEPv+0x12c>
    bool mergePrev = (prev != nullptr) && ((char*)prev + prev->size == (char*)block);
    800019b0:	00000613          	li	a2,0
    800019b4:	fcdff06f          	j	80001980 <_ZN15MemoryAllocator4freeEPv+0x48>
    800019b8:	00100613          	li	a2,1
    800019bc:	fc5ff06f          	j	80001980 <_ZN15MemoryAllocator4freeEPv+0x48>
    bool mergeNext = (curr != nullptr) && ((char*)block + block->size == (char*)curr);
    800019c0:	00000593          	li	a1,0
    800019c4:	fd1ff06f          	j	80001994 <_ZN15MemoryAllocator4freeEPv+0x5c>
    800019c8:	00100593          	li	a1,1
    800019cc:	fc9ff06f          	j	80001994 <_ZN15MemoryAllocator4freeEPv+0x5c>
            freeListHead = block;
    800019d0:	00003797          	auipc	a5,0x3
    800019d4:	d2d7bc23          	sd	a3,-712(a5) # 80004708 <_ZN15MemoryAllocator12freeListHeadE>
    return 0;
    800019d8:	00000513          	li	a0,0
    800019dc:	0880006f          	j	80001a64 <_ZN15MemoryAllocator4freeEPv+0x12c>
    } else if (mergePrev && !mergeNext) {
    800019e0:	02060063          	beqz	a2,80001a00 <_ZN15MemoryAllocator4freeEPv+0xc8>
    800019e4:	00059e63          	bnez	a1,80001a00 <_ZN15MemoryAllocator4freeEPv+0xc8>
        prev->size += block->size;
    800019e8:	ff853683          	ld	a3,-8(a0)
    800019ec:	00873783          	ld	a5,8(a4)
    800019f0:	00d787b3          	add	a5,a5,a3
    800019f4:	00f73423          	sd	a5,8(a4)
    return 0;
    800019f8:	00000513          	li	a0,0
        prev->size += block->size;
    800019fc:	0680006f          	j	80001a64 <_ZN15MemoryAllocator4freeEPv+0x12c>
    } else if (!mergePrev && mergeNext) {
    80001a00:	04061063          	bnez	a2,80001a40 <_ZN15MemoryAllocator4freeEPv+0x108>
    80001a04:	02058e63          	beqz	a1,80001a40 <_ZN15MemoryAllocator4freeEPv+0x108>
        block->size += curr->size;
    80001a08:	0087b583          	ld	a1,8(a5)
    80001a0c:	ff853603          	ld	a2,-8(a0)
    80001a10:	00b60633          	add	a2,a2,a1
    80001a14:	fec53c23          	sd	a2,-8(a0)
        block->next = curr->next;
    80001a18:	0007b783          	ld	a5,0(a5)
    80001a1c:	fef53823          	sd	a5,-16(a0)
        if (prev != nullptr) {
    80001a20:	00070863          	beqz	a4,80001a30 <_ZN15MemoryAllocator4freeEPv+0xf8>
            prev->next = block;
    80001a24:	00d73023          	sd	a3,0(a4)
    return 0;
    80001a28:	00000513          	li	a0,0
    80001a2c:	0380006f          	j	80001a64 <_ZN15MemoryAllocator4freeEPv+0x12c>
            freeListHead = block;
    80001a30:	00003797          	auipc	a5,0x3
    80001a34:	ccd7bc23          	sd	a3,-808(a5) # 80004708 <_ZN15MemoryAllocator12freeListHeadE>
    return 0;
    80001a38:	00000513          	li	a0,0
    80001a3c:	0280006f          	j	80001a64 <_ZN15MemoryAllocator4freeEPv+0x12c>
        prev->size += block->size + curr->size;
    80001a40:	ff853683          	ld	a3,-8(a0)
    80001a44:	0087b603          	ld	a2,8(a5)
    80001a48:	00c68633          	add	a2,a3,a2
    80001a4c:	00873683          	ld	a3,8(a4)
    80001a50:	00c686b3          	add	a3,a3,a2
    80001a54:	00d73423          	sd	a3,8(a4)
        prev->next = curr->next;
    80001a58:	0007b783          	ld	a5,0(a5)
    80001a5c:	00f73023          	sd	a5,0(a4)
    return 0;
    80001a60:	00000513          	li	a0,0
}
    80001a64:	00813403          	ld	s0,8(sp)
    80001a68:	01010113          	addi	sp,sp,16
    80001a6c:	00008067          	ret
    if (ptr == nullptr) return -1;
    80001a70:	fff00513          	li	a0,-1
    80001a74:	ff1ff06f          	j	80001a64 <_ZN15MemoryAllocator4freeEPv+0x12c>

0000000080001a78 <main>:

extern "C" void trapHandler();

void userMain();   // definisana u test fajlu

int main() {
    80001a78:	fe010113          	addi	sp,sp,-32
    80001a7c:	00113c23          	sd	ra,24(sp)
    80001a80:	00813823          	sd	s0,16(sp)
    80001a84:	00913423          	sd	s1,8(sp)
    80001a88:	02010413          	addi	s0,sp,32
    kputs(">> kernel: starting\n");
    80001a8c:	00002517          	auipc	a0,0x2
    80001a90:	62c50513          	addi	a0,a0,1580 # 800040b8 <CONSOLE_STATUS+0xa8>
    80001a94:	fffff097          	auipc	ra,0xfffff
    80001a98:	710080e7          	jalr	1808(ra) # 800011a4 <_Z5kputsPKc>

    // stvec = adresa prekidne rutine: jedina kapija za ecall/izuzetke/prekide
    uint64 addr = (uint64)&trapHandler;
    80001a9c:	fffff797          	auipc	a5,0xfffff
    80001aa0:	56478793          	addi	a5,a5,1380 # 80001000 <trapHandler>
    asm volatile("csrw stvec, %0" : : "r" (addr));
    80001aa4:	10579073          	csrw	stvec,a5

    // maskiraj prekide: sve radi u sistemskom rezimu, pa sstatus.sie=0
    // znaci "ne prekidaj me" (zahtevi se pamte u sip, ali ne stizu).
    // sret ovo ne kvari: sie<-spie, a spie je snimljena nula.
    uint64 sstatus;
    asm volatile("csrr %0, sstatus" : "=r"(sstatus));
    80001aa8:	100027f3          	csrr	a5,sstatus
    sstatus &= ~(1UL << 1);
    80001aac:	ffd7f793          	andi	a5,a5,-3
    asm volatile("csrw sstatus, %0" : : "r"(sstatus));
    80001ab0:	10079073          	csrw	sstatus,a5

    // dokaz da je maska stvarno upisana
    asm volatile("csrr %0, sstatus" : "=r"(sstatus));
    80001ab4:	100024f3          	csrr	s1,sstatus
    kputs(">> sstatus posle maske = "); kputhex(sstatus); kputs("\n");
    80001ab8:	00002517          	auipc	a0,0x2
    80001abc:	61850513          	addi	a0,a0,1560 # 800040d0 <CONSOLE_STATUS+0xc0>
    80001ac0:	fffff097          	auipc	ra,0xfffff
    80001ac4:	6e4080e7          	jalr	1764(ra) # 800011a4 <_Z5kputsPKc>
    80001ac8:	00048513          	mv	a0,s1
    80001acc:	fffff097          	auipc	ra,0xfffff
    80001ad0:	71c080e7          	jalr	1820(ra) # 800011e8 <_Z7kputhexm>
    80001ad4:	00002517          	auipc	a0,0x2
    80001ad8:	75450513          	addi	a0,a0,1876 # 80004228 <CONSOLE_STATUS+0x218>
    80001adc:	fffff097          	auipc	ra,0xfffff
    80001ae0:	6c8080e7          	jalr	1736(ra) # 800011a4 <_Z5kputsPKc>

    MemoryAllocator::init();
    80001ae4:	00000097          	auipc	ra,0x0
    80001ae8:	ccc080e7          	jalr	-820(ra) # 800017b0 <_ZN15MemoryAllocator4initEv>

    // main postaje "nulta" nit: dobija svoj tcb da ima gde da se zamrzne
    // kad prvi put ustupi procesor (kontekst mu se popuni pri prvom dispatch-u)
    TCB::running = TCB::createThread(nullptr, nullptr);
    80001aec:	00000593          	li	a1,0
    80001af0:	00000513          	li	a0,0
    80001af4:	00000097          	auipc	ra,0x0
    80001af8:	a5c080e7          	jalr	-1444(ra) # 80001550 <_ZN3TCB12createThreadEPFvPvES0_>
    80001afc:	00003797          	auipc	a5,0x3
    80001b00:	bea7ba23          	sd	a0,-1036(a5) # 800046f0 <_ZN3TCB7runningE>

    userMain();    // privremeno: obican poziv funkcije; kasnije postaje
    80001b04:	00000097          	auipc	ra,0x0
    80001b08:	93c080e7          	jalr	-1732(ra) # 80001440 <_Z8userMainv>
                   // telo prve niti koju pokrece jezgro

    kputs(">> kernel: userMain returned, halting\n");
    80001b0c:	00002517          	auipc	a0,0x2
    80001b10:	5e450513          	addi	a0,a0,1508 # 800040f0 <CONSOLE_STATUS+0xe0>
    80001b14:	fffff097          	auipc	ra,0xfffff
    80001b18:	690080e7          	jalr	1680(ra) # 800011a4 <_Z5kputsPKc>

    // upis 0x5555 na 0x100000 gasi emulator (regularan kraj procesa)
    *(volatile int*)0x100000 = 0x5555;
    80001b1c:	00100737          	lui	a4,0x100
    80001b20:	000057b7          	lui	a5,0x5
    80001b24:	5557879b          	addiw	a5,a5,1365
    80001b28:	00f72023          	sw	a5,0(a4) # 100000 <_entry-0x7ff00000>

    return 0;
}
    80001b2c:	00000513          	li	a0,0
    80001b30:	01813083          	ld	ra,24(sp)
    80001b34:	01013403          	ld	s0,16(sp)
    80001b38:	00813483          	ld	s1,8(sp)
    80001b3c:	02010113          	addi	sp,sp,32
    80001b40:	00008067          	ret

0000000080001b44 <start>:
    80001b44:	ff010113          	addi	sp,sp,-16
    80001b48:	00813423          	sd	s0,8(sp)
    80001b4c:	01010413          	addi	s0,sp,16
    80001b50:	300027f3          	csrr	a5,mstatus
    80001b54:	ffffe737          	lui	a4,0xffffe
    80001b58:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fff8e6f>
    80001b5c:	00e7f7b3          	and	a5,a5,a4
    80001b60:	00001737          	lui	a4,0x1
    80001b64:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80001b68:	00e7e7b3          	or	a5,a5,a4
    80001b6c:	30079073          	csrw	mstatus,a5
    80001b70:	00000797          	auipc	a5,0x0
    80001b74:	16078793          	addi	a5,a5,352 # 80001cd0 <system_main>
    80001b78:	34179073          	csrw	mepc,a5
    80001b7c:	00000793          	li	a5,0
    80001b80:	18079073          	csrw	satp,a5
    80001b84:	000107b7          	lui	a5,0x10
    80001b88:	fff78793          	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80001b8c:	30279073          	csrw	medeleg,a5
    80001b90:	30379073          	csrw	mideleg,a5
    80001b94:	104027f3          	csrr	a5,sie
    80001b98:	2227e793          	ori	a5,a5,546
    80001b9c:	10479073          	csrw	sie,a5
    80001ba0:	fff00793          	li	a5,-1
    80001ba4:	00a7d793          	srli	a5,a5,0xa
    80001ba8:	3b079073          	csrw	pmpaddr0,a5
    80001bac:	00f00793          	li	a5,15
    80001bb0:	3a079073          	csrw	pmpcfg0,a5
    80001bb4:	f14027f3          	csrr	a5,mhartid
    80001bb8:	0200c737          	lui	a4,0x200c
    80001bbc:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80001bc0:	0007869b          	sext.w	a3,a5
    80001bc4:	00269713          	slli	a4,a3,0x2
    80001bc8:	000f4637          	lui	a2,0xf4
    80001bcc:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80001bd0:	00d70733          	add	a4,a4,a3
    80001bd4:	0037979b          	slliw	a5,a5,0x3
    80001bd8:	020046b7          	lui	a3,0x2004
    80001bdc:	00d787b3          	add	a5,a5,a3
    80001be0:	00c585b3          	add	a1,a1,a2
    80001be4:	00371693          	slli	a3,a4,0x3
    80001be8:	00003717          	auipc	a4,0x3
    80001bec:	b5870713          	addi	a4,a4,-1192 # 80004740 <timer_scratch>
    80001bf0:	00b7b023          	sd	a1,0(a5)
    80001bf4:	00d70733          	add	a4,a4,a3
    80001bf8:	00f73c23          	sd	a5,24(a4)
    80001bfc:	02c73023          	sd	a2,32(a4)
    80001c00:	34071073          	csrw	mscratch,a4
    80001c04:	00000797          	auipc	a5,0x0
    80001c08:	6ec78793          	addi	a5,a5,1772 # 800022f0 <timervec>
    80001c0c:	30579073          	csrw	mtvec,a5
    80001c10:	300027f3          	csrr	a5,mstatus
    80001c14:	0087e793          	ori	a5,a5,8
    80001c18:	30079073          	csrw	mstatus,a5
    80001c1c:	304027f3          	csrr	a5,mie
    80001c20:	0807e793          	ori	a5,a5,128
    80001c24:	30479073          	csrw	mie,a5
    80001c28:	f14027f3          	csrr	a5,mhartid
    80001c2c:	0007879b          	sext.w	a5,a5
    80001c30:	00078213          	mv	tp,a5
    80001c34:	30200073          	mret
    80001c38:	00813403          	ld	s0,8(sp)
    80001c3c:	01010113          	addi	sp,sp,16
    80001c40:	00008067          	ret

0000000080001c44 <timerinit>:
    80001c44:	ff010113          	addi	sp,sp,-16
    80001c48:	00813423          	sd	s0,8(sp)
    80001c4c:	01010413          	addi	s0,sp,16
    80001c50:	f14027f3          	csrr	a5,mhartid
    80001c54:	0200c737          	lui	a4,0x200c
    80001c58:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80001c5c:	0007869b          	sext.w	a3,a5
    80001c60:	00269713          	slli	a4,a3,0x2
    80001c64:	000f4637          	lui	a2,0xf4
    80001c68:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80001c6c:	00d70733          	add	a4,a4,a3
    80001c70:	0037979b          	slliw	a5,a5,0x3
    80001c74:	020046b7          	lui	a3,0x2004
    80001c78:	00d787b3          	add	a5,a5,a3
    80001c7c:	00c585b3          	add	a1,a1,a2
    80001c80:	00371693          	slli	a3,a4,0x3
    80001c84:	00003717          	auipc	a4,0x3
    80001c88:	abc70713          	addi	a4,a4,-1348 # 80004740 <timer_scratch>
    80001c8c:	00b7b023          	sd	a1,0(a5)
    80001c90:	00d70733          	add	a4,a4,a3
    80001c94:	00f73c23          	sd	a5,24(a4)
    80001c98:	02c73023          	sd	a2,32(a4)
    80001c9c:	34071073          	csrw	mscratch,a4
    80001ca0:	00000797          	auipc	a5,0x0
    80001ca4:	65078793          	addi	a5,a5,1616 # 800022f0 <timervec>
    80001ca8:	30579073          	csrw	mtvec,a5
    80001cac:	300027f3          	csrr	a5,mstatus
    80001cb0:	0087e793          	ori	a5,a5,8
    80001cb4:	30079073          	csrw	mstatus,a5
    80001cb8:	304027f3          	csrr	a5,mie
    80001cbc:	0807e793          	ori	a5,a5,128
    80001cc0:	30479073          	csrw	mie,a5
    80001cc4:	00813403          	ld	s0,8(sp)
    80001cc8:	01010113          	addi	sp,sp,16
    80001ccc:	00008067          	ret

0000000080001cd0 <system_main>:
    80001cd0:	fe010113          	addi	sp,sp,-32
    80001cd4:	00813823          	sd	s0,16(sp)
    80001cd8:	00913423          	sd	s1,8(sp)
    80001cdc:	00113c23          	sd	ra,24(sp)
    80001ce0:	02010413          	addi	s0,sp,32
    80001ce4:	00000097          	auipc	ra,0x0
    80001ce8:	0c4080e7          	jalr	196(ra) # 80001da8 <cpuid>
    80001cec:	00003497          	auipc	s1,0x3
    80001cf0:	a2448493          	addi	s1,s1,-1500 # 80004710 <started>
    80001cf4:	02050263          	beqz	a0,80001d18 <system_main+0x48>
    80001cf8:	0004a783          	lw	a5,0(s1)
    80001cfc:	0007879b          	sext.w	a5,a5
    80001d00:	fe078ce3          	beqz	a5,80001cf8 <system_main+0x28>
    80001d04:	0ff0000f          	fence
    80001d08:	00002517          	auipc	a0,0x2
    80001d0c:	44050513          	addi	a0,a0,1088 # 80004148 <CONSOLE_STATUS+0x138>
    80001d10:	00001097          	auipc	ra,0x1
    80001d14:	a7c080e7          	jalr	-1412(ra) # 8000278c <panic>
    80001d18:	00001097          	auipc	ra,0x1
    80001d1c:	9d0080e7          	jalr	-1584(ra) # 800026e8 <consoleinit>
    80001d20:	00001097          	auipc	ra,0x1
    80001d24:	15c080e7          	jalr	348(ra) # 80002e7c <printfinit>
    80001d28:	00002517          	auipc	a0,0x2
    80001d2c:	50050513          	addi	a0,a0,1280 # 80004228 <CONSOLE_STATUS+0x218>
    80001d30:	00001097          	auipc	ra,0x1
    80001d34:	ab8080e7          	jalr	-1352(ra) # 800027e8 <__printf>
    80001d38:	00002517          	auipc	a0,0x2
    80001d3c:	3e050513          	addi	a0,a0,992 # 80004118 <CONSOLE_STATUS+0x108>
    80001d40:	00001097          	auipc	ra,0x1
    80001d44:	aa8080e7          	jalr	-1368(ra) # 800027e8 <__printf>
    80001d48:	00002517          	auipc	a0,0x2
    80001d4c:	4e050513          	addi	a0,a0,1248 # 80004228 <CONSOLE_STATUS+0x218>
    80001d50:	00001097          	auipc	ra,0x1
    80001d54:	a98080e7          	jalr	-1384(ra) # 800027e8 <__printf>
    80001d58:	00001097          	auipc	ra,0x1
    80001d5c:	4b0080e7          	jalr	1200(ra) # 80003208 <kinit>
    80001d60:	00000097          	auipc	ra,0x0
    80001d64:	148080e7          	jalr	328(ra) # 80001ea8 <trapinit>
    80001d68:	00000097          	auipc	ra,0x0
    80001d6c:	16c080e7          	jalr	364(ra) # 80001ed4 <trapinithart>
    80001d70:	00000097          	auipc	ra,0x0
    80001d74:	5c0080e7          	jalr	1472(ra) # 80002330 <plicinit>
    80001d78:	00000097          	auipc	ra,0x0
    80001d7c:	5e0080e7          	jalr	1504(ra) # 80002358 <plicinithart>
    80001d80:	00000097          	auipc	ra,0x0
    80001d84:	078080e7          	jalr	120(ra) # 80001df8 <userinit>
    80001d88:	0ff0000f          	fence
    80001d8c:	00100793          	li	a5,1
    80001d90:	00002517          	auipc	a0,0x2
    80001d94:	3a050513          	addi	a0,a0,928 # 80004130 <CONSOLE_STATUS+0x120>
    80001d98:	00f4a023          	sw	a5,0(s1)
    80001d9c:	00001097          	auipc	ra,0x1
    80001da0:	a4c080e7          	jalr	-1460(ra) # 800027e8 <__printf>
    80001da4:	0000006f          	j	80001da4 <system_main+0xd4>

0000000080001da8 <cpuid>:
    80001da8:	ff010113          	addi	sp,sp,-16
    80001dac:	00813423          	sd	s0,8(sp)
    80001db0:	01010413          	addi	s0,sp,16
    80001db4:	00020513          	mv	a0,tp
    80001db8:	00813403          	ld	s0,8(sp)
    80001dbc:	0005051b          	sext.w	a0,a0
    80001dc0:	01010113          	addi	sp,sp,16
    80001dc4:	00008067          	ret

0000000080001dc8 <mycpu>:
    80001dc8:	ff010113          	addi	sp,sp,-16
    80001dcc:	00813423          	sd	s0,8(sp)
    80001dd0:	01010413          	addi	s0,sp,16
    80001dd4:	00020793          	mv	a5,tp
    80001dd8:	00813403          	ld	s0,8(sp)
    80001ddc:	0007879b          	sext.w	a5,a5
    80001de0:	00779793          	slli	a5,a5,0x7
    80001de4:	00004517          	auipc	a0,0x4
    80001de8:	98c50513          	addi	a0,a0,-1652 # 80005770 <cpus>
    80001dec:	00f50533          	add	a0,a0,a5
    80001df0:	01010113          	addi	sp,sp,16
    80001df4:	00008067          	ret

0000000080001df8 <userinit>:
    80001df8:	ff010113          	addi	sp,sp,-16
    80001dfc:	00813423          	sd	s0,8(sp)
    80001e00:	01010413          	addi	s0,sp,16
    80001e04:	00813403          	ld	s0,8(sp)
    80001e08:	01010113          	addi	sp,sp,16
    80001e0c:	00000317          	auipc	t1,0x0
    80001e10:	c6c30067          	jr	-916(t1) # 80001a78 <main>

0000000080001e14 <either_copyout>:
    80001e14:	ff010113          	addi	sp,sp,-16
    80001e18:	00813023          	sd	s0,0(sp)
    80001e1c:	00113423          	sd	ra,8(sp)
    80001e20:	01010413          	addi	s0,sp,16
    80001e24:	02051663          	bnez	a0,80001e50 <either_copyout+0x3c>
    80001e28:	00058513          	mv	a0,a1
    80001e2c:	00060593          	mv	a1,a2
    80001e30:	0006861b          	sext.w	a2,a3
    80001e34:	00002097          	auipc	ra,0x2
    80001e38:	c60080e7          	jalr	-928(ra) # 80003a94 <__memmove>
    80001e3c:	00813083          	ld	ra,8(sp)
    80001e40:	00013403          	ld	s0,0(sp)
    80001e44:	00000513          	li	a0,0
    80001e48:	01010113          	addi	sp,sp,16
    80001e4c:	00008067          	ret
    80001e50:	00002517          	auipc	a0,0x2
    80001e54:	32050513          	addi	a0,a0,800 # 80004170 <CONSOLE_STATUS+0x160>
    80001e58:	00001097          	auipc	ra,0x1
    80001e5c:	934080e7          	jalr	-1740(ra) # 8000278c <panic>

0000000080001e60 <either_copyin>:
    80001e60:	ff010113          	addi	sp,sp,-16
    80001e64:	00813023          	sd	s0,0(sp)
    80001e68:	00113423          	sd	ra,8(sp)
    80001e6c:	01010413          	addi	s0,sp,16
    80001e70:	02059463          	bnez	a1,80001e98 <either_copyin+0x38>
    80001e74:	00060593          	mv	a1,a2
    80001e78:	0006861b          	sext.w	a2,a3
    80001e7c:	00002097          	auipc	ra,0x2
    80001e80:	c18080e7          	jalr	-1000(ra) # 80003a94 <__memmove>
    80001e84:	00813083          	ld	ra,8(sp)
    80001e88:	00013403          	ld	s0,0(sp)
    80001e8c:	00000513          	li	a0,0
    80001e90:	01010113          	addi	sp,sp,16
    80001e94:	00008067          	ret
    80001e98:	00002517          	auipc	a0,0x2
    80001e9c:	30050513          	addi	a0,a0,768 # 80004198 <CONSOLE_STATUS+0x188>
    80001ea0:	00001097          	auipc	ra,0x1
    80001ea4:	8ec080e7          	jalr	-1812(ra) # 8000278c <panic>

0000000080001ea8 <trapinit>:
    80001ea8:	ff010113          	addi	sp,sp,-16
    80001eac:	00813423          	sd	s0,8(sp)
    80001eb0:	01010413          	addi	s0,sp,16
    80001eb4:	00813403          	ld	s0,8(sp)
    80001eb8:	00002597          	auipc	a1,0x2
    80001ebc:	30858593          	addi	a1,a1,776 # 800041c0 <CONSOLE_STATUS+0x1b0>
    80001ec0:	00004517          	auipc	a0,0x4
    80001ec4:	93050513          	addi	a0,a0,-1744 # 800057f0 <tickslock>
    80001ec8:	01010113          	addi	sp,sp,16
    80001ecc:	00001317          	auipc	t1,0x1
    80001ed0:	5cc30067          	jr	1484(t1) # 80003498 <initlock>

0000000080001ed4 <trapinithart>:
    80001ed4:	ff010113          	addi	sp,sp,-16
    80001ed8:	00813423          	sd	s0,8(sp)
    80001edc:	01010413          	addi	s0,sp,16
    80001ee0:	00000797          	auipc	a5,0x0
    80001ee4:	30078793          	addi	a5,a5,768 # 800021e0 <kernelvec>
    80001ee8:	10579073          	csrw	stvec,a5
    80001eec:	00813403          	ld	s0,8(sp)
    80001ef0:	01010113          	addi	sp,sp,16
    80001ef4:	00008067          	ret

0000000080001ef8 <usertrap>:
    80001ef8:	ff010113          	addi	sp,sp,-16
    80001efc:	00813423          	sd	s0,8(sp)
    80001f00:	01010413          	addi	s0,sp,16
    80001f04:	00813403          	ld	s0,8(sp)
    80001f08:	01010113          	addi	sp,sp,16
    80001f0c:	00008067          	ret

0000000080001f10 <usertrapret>:
    80001f10:	ff010113          	addi	sp,sp,-16
    80001f14:	00813423          	sd	s0,8(sp)
    80001f18:	01010413          	addi	s0,sp,16
    80001f1c:	00813403          	ld	s0,8(sp)
    80001f20:	01010113          	addi	sp,sp,16
    80001f24:	00008067          	ret

0000000080001f28 <kerneltrap>:
    80001f28:	fe010113          	addi	sp,sp,-32
    80001f2c:	00813823          	sd	s0,16(sp)
    80001f30:	00113c23          	sd	ra,24(sp)
    80001f34:	00913423          	sd	s1,8(sp)
    80001f38:	02010413          	addi	s0,sp,32
    80001f3c:	142025f3          	csrr	a1,scause
    80001f40:	100027f3          	csrr	a5,sstatus
    80001f44:	0027f793          	andi	a5,a5,2
    80001f48:	10079c63          	bnez	a5,80002060 <kerneltrap+0x138>
    80001f4c:	142027f3          	csrr	a5,scause
    80001f50:	0207ce63          	bltz	a5,80001f8c <kerneltrap+0x64>
    80001f54:	00002517          	auipc	a0,0x2
    80001f58:	2b450513          	addi	a0,a0,692 # 80004208 <CONSOLE_STATUS+0x1f8>
    80001f5c:	00001097          	auipc	ra,0x1
    80001f60:	88c080e7          	jalr	-1908(ra) # 800027e8 <__printf>
    80001f64:	141025f3          	csrr	a1,sepc
    80001f68:	14302673          	csrr	a2,stval
    80001f6c:	00002517          	auipc	a0,0x2
    80001f70:	2ac50513          	addi	a0,a0,684 # 80004218 <CONSOLE_STATUS+0x208>
    80001f74:	00001097          	auipc	ra,0x1
    80001f78:	874080e7          	jalr	-1932(ra) # 800027e8 <__printf>
    80001f7c:	00002517          	auipc	a0,0x2
    80001f80:	2b450513          	addi	a0,a0,692 # 80004230 <CONSOLE_STATUS+0x220>
    80001f84:	00001097          	auipc	ra,0x1
    80001f88:	808080e7          	jalr	-2040(ra) # 8000278c <panic>
    80001f8c:	0ff7f713          	andi	a4,a5,255
    80001f90:	00900693          	li	a3,9
    80001f94:	04d70063          	beq	a4,a3,80001fd4 <kerneltrap+0xac>
    80001f98:	fff00713          	li	a4,-1
    80001f9c:	03f71713          	slli	a4,a4,0x3f
    80001fa0:	00170713          	addi	a4,a4,1
    80001fa4:	fae798e3          	bne	a5,a4,80001f54 <kerneltrap+0x2c>
    80001fa8:	00000097          	auipc	ra,0x0
    80001fac:	e00080e7          	jalr	-512(ra) # 80001da8 <cpuid>
    80001fb0:	06050663          	beqz	a0,8000201c <kerneltrap+0xf4>
    80001fb4:	144027f3          	csrr	a5,sip
    80001fb8:	ffd7f793          	andi	a5,a5,-3
    80001fbc:	14479073          	csrw	sip,a5
    80001fc0:	01813083          	ld	ra,24(sp)
    80001fc4:	01013403          	ld	s0,16(sp)
    80001fc8:	00813483          	ld	s1,8(sp)
    80001fcc:	02010113          	addi	sp,sp,32
    80001fd0:	00008067          	ret
    80001fd4:	00000097          	auipc	ra,0x0
    80001fd8:	3d0080e7          	jalr	976(ra) # 800023a4 <plic_claim>
    80001fdc:	00a00793          	li	a5,10
    80001fe0:	00050493          	mv	s1,a0
    80001fe4:	06f50863          	beq	a0,a5,80002054 <kerneltrap+0x12c>
    80001fe8:	fc050ce3          	beqz	a0,80001fc0 <kerneltrap+0x98>
    80001fec:	00050593          	mv	a1,a0
    80001ff0:	00002517          	auipc	a0,0x2
    80001ff4:	1f850513          	addi	a0,a0,504 # 800041e8 <CONSOLE_STATUS+0x1d8>
    80001ff8:	00000097          	auipc	ra,0x0
    80001ffc:	7f0080e7          	jalr	2032(ra) # 800027e8 <__printf>
    80002000:	01013403          	ld	s0,16(sp)
    80002004:	01813083          	ld	ra,24(sp)
    80002008:	00048513          	mv	a0,s1
    8000200c:	00813483          	ld	s1,8(sp)
    80002010:	02010113          	addi	sp,sp,32
    80002014:	00000317          	auipc	t1,0x0
    80002018:	3c830067          	jr	968(t1) # 800023dc <plic_complete>
    8000201c:	00003517          	auipc	a0,0x3
    80002020:	7d450513          	addi	a0,a0,2004 # 800057f0 <tickslock>
    80002024:	00001097          	auipc	ra,0x1
    80002028:	498080e7          	jalr	1176(ra) # 800034bc <acquire>
    8000202c:	00002717          	auipc	a4,0x2
    80002030:	6e870713          	addi	a4,a4,1768 # 80004714 <ticks>
    80002034:	00072783          	lw	a5,0(a4)
    80002038:	00003517          	auipc	a0,0x3
    8000203c:	7b850513          	addi	a0,a0,1976 # 800057f0 <tickslock>
    80002040:	0017879b          	addiw	a5,a5,1
    80002044:	00f72023          	sw	a5,0(a4)
    80002048:	00001097          	auipc	ra,0x1
    8000204c:	540080e7          	jalr	1344(ra) # 80003588 <release>
    80002050:	f65ff06f          	j	80001fb4 <kerneltrap+0x8c>
    80002054:	00001097          	auipc	ra,0x1
    80002058:	09c080e7          	jalr	156(ra) # 800030f0 <uartintr>
    8000205c:	fa5ff06f          	j	80002000 <kerneltrap+0xd8>
    80002060:	00002517          	auipc	a0,0x2
    80002064:	16850513          	addi	a0,a0,360 # 800041c8 <CONSOLE_STATUS+0x1b8>
    80002068:	00000097          	auipc	ra,0x0
    8000206c:	724080e7          	jalr	1828(ra) # 8000278c <panic>

0000000080002070 <clockintr>:
    80002070:	fe010113          	addi	sp,sp,-32
    80002074:	00813823          	sd	s0,16(sp)
    80002078:	00913423          	sd	s1,8(sp)
    8000207c:	00113c23          	sd	ra,24(sp)
    80002080:	02010413          	addi	s0,sp,32
    80002084:	00003497          	auipc	s1,0x3
    80002088:	76c48493          	addi	s1,s1,1900 # 800057f0 <tickslock>
    8000208c:	00048513          	mv	a0,s1
    80002090:	00001097          	auipc	ra,0x1
    80002094:	42c080e7          	jalr	1068(ra) # 800034bc <acquire>
    80002098:	00002717          	auipc	a4,0x2
    8000209c:	67c70713          	addi	a4,a4,1660 # 80004714 <ticks>
    800020a0:	00072783          	lw	a5,0(a4)
    800020a4:	01013403          	ld	s0,16(sp)
    800020a8:	01813083          	ld	ra,24(sp)
    800020ac:	00048513          	mv	a0,s1
    800020b0:	0017879b          	addiw	a5,a5,1
    800020b4:	00813483          	ld	s1,8(sp)
    800020b8:	00f72023          	sw	a5,0(a4)
    800020bc:	02010113          	addi	sp,sp,32
    800020c0:	00001317          	auipc	t1,0x1
    800020c4:	4c830067          	jr	1224(t1) # 80003588 <release>

00000000800020c8 <devintr>:
    800020c8:	142027f3          	csrr	a5,scause
    800020cc:	00000513          	li	a0,0
    800020d0:	0007c463          	bltz	a5,800020d8 <devintr+0x10>
    800020d4:	00008067          	ret
    800020d8:	fe010113          	addi	sp,sp,-32
    800020dc:	00813823          	sd	s0,16(sp)
    800020e0:	00113c23          	sd	ra,24(sp)
    800020e4:	00913423          	sd	s1,8(sp)
    800020e8:	02010413          	addi	s0,sp,32
    800020ec:	0ff7f713          	andi	a4,a5,255
    800020f0:	00900693          	li	a3,9
    800020f4:	04d70c63          	beq	a4,a3,8000214c <devintr+0x84>
    800020f8:	fff00713          	li	a4,-1
    800020fc:	03f71713          	slli	a4,a4,0x3f
    80002100:	00170713          	addi	a4,a4,1
    80002104:	00e78c63          	beq	a5,a4,8000211c <devintr+0x54>
    80002108:	01813083          	ld	ra,24(sp)
    8000210c:	01013403          	ld	s0,16(sp)
    80002110:	00813483          	ld	s1,8(sp)
    80002114:	02010113          	addi	sp,sp,32
    80002118:	00008067          	ret
    8000211c:	00000097          	auipc	ra,0x0
    80002120:	c8c080e7          	jalr	-884(ra) # 80001da8 <cpuid>
    80002124:	06050663          	beqz	a0,80002190 <devintr+0xc8>
    80002128:	144027f3          	csrr	a5,sip
    8000212c:	ffd7f793          	andi	a5,a5,-3
    80002130:	14479073          	csrw	sip,a5
    80002134:	01813083          	ld	ra,24(sp)
    80002138:	01013403          	ld	s0,16(sp)
    8000213c:	00813483          	ld	s1,8(sp)
    80002140:	00200513          	li	a0,2
    80002144:	02010113          	addi	sp,sp,32
    80002148:	00008067          	ret
    8000214c:	00000097          	auipc	ra,0x0
    80002150:	258080e7          	jalr	600(ra) # 800023a4 <plic_claim>
    80002154:	00a00793          	li	a5,10
    80002158:	00050493          	mv	s1,a0
    8000215c:	06f50663          	beq	a0,a5,800021c8 <devintr+0x100>
    80002160:	00100513          	li	a0,1
    80002164:	fa0482e3          	beqz	s1,80002108 <devintr+0x40>
    80002168:	00048593          	mv	a1,s1
    8000216c:	00002517          	auipc	a0,0x2
    80002170:	07c50513          	addi	a0,a0,124 # 800041e8 <CONSOLE_STATUS+0x1d8>
    80002174:	00000097          	auipc	ra,0x0
    80002178:	674080e7          	jalr	1652(ra) # 800027e8 <__printf>
    8000217c:	00048513          	mv	a0,s1
    80002180:	00000097          	auipc	ra,0x0
    80002184:	25c080e7          	jalr	604(ra) # 800023dc <plic_complete>
    80002188:	00100513          	li	a0,1
    8000218c:	f7dff06f          	j	80002108 <devintr+0x40>
    80002190:	00003517          	auipc	a0,0x3
    80002194:	66050513          	addi	a0,a0,1632 # 800057f0 <tickslock>
    80002198:	00001097          	auipc	ra,0x1
    8000219c:	324080e7          	jalr	804(ra) # 800034bc <acquire>
    800021a0:	00002717          	auipc	a4,0x2
    800021a4:	57470713          	addi	a4,a4,1396 # 80004714 <ticks>
    800021a8:	00072783          	lw	a5,0(a4)
    800021ac:	00003517          	auipc	a0,0x3
    800021b0:	64450513          	addi	a0,a0,1604 # 800057f0 <tickslock>
    800021b4:	0017879b          	addiw	a5,a5,1
    800021b8:	00f72023          	sw	a5,0(a4)
    800021bc:	00001097          	auipc	ra,0x1
    800021c0:	3cc080e7          	jalr	972(ra) # 80003588 <release>
    800021c4:	f65ff06f          	j	80002128 <devintr+0x60>
    800021c8:	00001097          	auipc	ra,0x1
    800021cc:	f28080e7          	jalr	-216(ra) # 800030f0 <uartintr>
    800021d0:	fadff06f          	j	8000217c <devintr+0xb4>
	...

00000000800021e0 <kernelvec>:
    800021e0:	f0010113          	addi	sp,sp,-256
    800021e4:	00113023          	sd	ra,0(sp)
    800021e8:	00213423          	sd	sp,8(sp)
    800021ec:	00313823          	sd	gp,16(sp)
    800021f0:	00413c23          	sd	tp,24(sp)
    800021f4:	02513023          	sd	t0,32(sp)
    800021f8:	02613423          	sd	t1,40(sp)
    800021fc:	02713823          	sd	t2,48(sp)
    80002200:	02813c23          	sd	s0,56(sp)
    80002204:	04913023          	sd	s1,64(sp)
    80002208:	04a13423          	sd	a0,72(sp)
    8000220c:	04b13823          	sd	a1,80(sp)
    80002210:	04c13c23          	sd	a2,88(sp)
    80002214:	06d13023          	sd	a3,96(sp)
    80002218:	06e13423          	sd	a4,104(sp)
    8000221c:	06f13823          	sd	a5,112(sp)
    80002220:	07013c23          	sd	a6,120(sp)
    80002224:	09113023          	sd	a7,128(sp)
    80002228:	09213423          	sd	s2,136(sp)
    8000222c:	09313823          	sd	s3,144(sp)
    80002230:	09413c23          	sd	s4,152(sp)
    80002234:	0b513023          	sd	s5,160(sp)
    80002238:	0b613423          	sd	s6,168(sp)
    8000223c:	0b713823          	sd	s7,176(sp)
    80002240:	0b813c23          	sd	s8,184(sp)
    80002244:	0d913023          	sd	s9,192(sp)
    80002248:	0da13423          	sd	s10,200(sp)
    8000224c:	0db13823          	sd	s11,208(sp)
    80002250:	0dc13c23          	sd	t3,216(sp)
    80002254:	0fd13023          	sd	t4,224(sp)
    80002258:	0fe13423          	sd	t5,232(sp)
    8000225c:	0ff13823          	sd	t6,240(sp)
    80002260:	cc9ff0ef          	jal	ra,80001f28 <kerneltrap>
    80002264:	00013083          	ld	ra,0(sp)
    80002268:	00813103          	ld	sp,8(sp)
    8000226c:	01013183          	ld	gp,16(sp)
    80002270:	02013283          	ld	t0,32(sp)
    80002274:	02813303          	ld	t1,40(sp)
    80002278:	03013383          	ld	t2,48(sp)
    8000227c:	03813403          	ld	s0,56(sp)
    80002280:	04013483          	ld	s1,64(sp)
    80002284:	04813503          	ld	a0,72(sp)
    80002288:	05013583          	ld	a1,80(sp)
    8000228c:	05813603          	ld	a2,88(sp)
    80002290:	06013683          	ld	a3,96(sp)
    80002294:	06813703          	ld	a4,104(sp)
    80002298:	07013783          	ld	a5,112(sp)
    8000229c:	07813803          	ld	a6,120(sp)
    800022a0:	08013883          	ld	a7,128(sp)
    800022a4:	08813903          	ld	s2,136(sp)
    800022a8:	09013983          	ld	s3,144(sp)
    800022ac:	09813a03          	ld	s4,152(sp)
    800022b0:	0a013a83          	ld	s5,160(sp)
    800022b4:	0a813b03          	ld	s6,168(sp)
    800022b8:	0b013b83          	ld	s7,176(sp)
    800022bc:	0b813c03          	ld	s8,184(sp)
    800022c0:	0c013c83          	ld	s9,192(sp)
    800022c4:	0c813d03          	ld	s10,200(sp)
    800022c8:	0d013d83          	ld	s11,208(sp)
    800022cc:	0d813e03          	ld	t3,216(sp)
    800022d0:	0e013e83          	ld	t4,224(sp)
    800022d4:	0e813f03          	ld	t5,232(sp)
    800022d8:	0f013f83          	ld	t6,240(sp)
    800022dc:	10010113          	addi	sp,sp,256
    800022e0:	10200073          	sret
    800022e4:	00000013          	nop
    800022e8:	00000013          	nop
    800022ec:	00000013          	nop

00000000800022f0 <timervec>:
    800022f0:	34051573          	csrrw	a0,mscratch,a0
    800022f4:	00b53023          	sd	a1,0(a0)
    800022f8:	00c53423          	sd	a2,8(a0)
    800022fc:	00d53823          	sd	a3,16(a0)
    80002300:	01853583          	ld	a1,24(a0)
    80002304:	02053603          	ld	a2,32(a0)
    80002308:	0005b683          	ld	a3,0(a1)
    8000230c:	00c686b3          	add	a3,a3,a2
    80002310:	00d5b023          	sd	a3,0(a1)
    80002314:	00200593          	li	a1,2
    80002318:	14459073          	csrw	sip,a1
    8000231c:	01053683          	ld	a3,16(a0)
    80002320:	00853603          	ld	a2,8(a0)
    80002324:	00053583          	ld	a1,0(a0)
    80002328:	34051573          	csrrw	a0,mscratch,a0
    8000232c:	30200073          	mret

0000000080002330 <plicinit>:
    80002330:	ff010113          	addi	sp,sp,-16
    80002334:	00813423          	sd	s0,8(sp)
    80002338:	01010413          	addi	s0,sp,16
    8000233c:	00813403          	ld	s0,8(sp)
    80002340:	0c0007b7          	lui	a5,0xc000
    80002344:	00100713          	li	a4,1
    80002348:	02e7a423          	sw	a4,40(a5) # c000028 <_entry-0x73ffffd8>
    8000234c:	00e7a223          	sw	a4,4(a5)
    80002350:	01010113          	addi	sp,sp,16
    80002354:	00008067          	ret

0000000080002358 <plicinithart>:
    80002358:	ff010113          	addi	sp,sp,-16
    8000235c:	00813023          	sd	s0,0(sp)
    80002360:	00113423          	sd	ra,8(sp)
    80002364:	01010413          	addi	s0,sp,16
    80002368:	00000097          	auipc	ra,0x0
    8000236c:	a40080e7          	jalr	-1472(ra) # 80001da8 <cpuid>
    80002370:	0085171b          	slliw	a4,a0,0x8
    80002374:	0c0027b7          	lui	a5,0xc002
    80002378:	00e787b3          	add	a5,a5,a4
    8000237c:	40200713          	li	a4,1026
    80002380:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>
    80002384:	00813083          	ld	ra,8(sp)
    80002388:	00013403          	ld	s0,0(sp)
    8000238c:	00d5151b          	slliw	a0,a0,0xd
    80002390:	0c2017b7          	lui	a5,0xc201
    80002394:	00a78533          	add	a0,a5,a0
    80002398:	00052023          	sw	zero,0(a0)
    8000239c:	01010113          	addi	sp,sp,16
    800023a0:	00008067          	ret

00000000800023a4 <plic_claim>:
    800023a4:	ff010113          	addi	sp,sp,-16
    800023a8:	00813023          	sd	s0,0(sp)
    800023ac:	00113423          	sd	ra,8(sp)
    800023b0:	01010413          	addi	s0,sp,16
    800023b4:	00000097          	auipc	ra,0x0
    800023b8:	9f4080e7          	jalr	-1548(ra) # 80001da8 <cpuid>
    800023bc:	00813083          	ld	ra,8(sp)
    800023c0:	00013403          	ld	s0,0(sp)
    800023c4:	00d5151b          	slliw	a0,a0,0xd
    800023c8:	0c2017b7          	lui	a5,0xc201
    800023cc:	00a78533          	add	a0,a5,a0
    800023d0:	00452503          	lw	a0,4(a0)
    800023d4:	01010113          	addi	sp,sp,16
    800023d8:	00008067          	ret

00000000800023dc <plic_complete>:
    800023dc:	fe010113          	addi	sp,sp,-32
    800023e0:	00813823          	sd	s0,16(sp)
    800023e4:	00913423          	sd	s1,8(sp)
    800023e8:	00113c23          	sd	ra,24(sp)
    800023ec:	02010413          	addi	s0,sp,32
    800023f0:	00050493          	mv	s1,a0
    800023f4:	00000097          	auipc	ra,0x0
    800023f8:	9b4080e7          	jalr	-1612(ra) # 80001da8 <cpuid>
    800023fc:	01813083          	ld	ra,24(sp)
    80002400:	01013403          	ld	s0,16(sp)
    80002404:	00d5179b          	slliw	a5,a0,0xd
    80002408:	0c201737          	lui	a4,0xc201
    8000240c:	00f707b3          	add	a5,a4,a5
    80002410:	0097a223          	sw	s1,4(a5) # c201004 <_entry-0x73dfeffc>
    80002414:	00813483          	ld	s1,8(sp)
    80002418:	02010113          	addi	sp,sp,32
    8000241c:	00008067          	ret

0000000080002420 <consolewrite>:
    80002420:	fb010113          	addi	sp,sp,-80
    80002424:	04813023          	sd	s0,64(sp)
    80002428:	04113423          	sd	ra,72(sp)
    8000242c:	02913c23          	sd	s1,56(sp)
    80002430:	03213823          	sd	s2,48(sp)
    80002434:	03313423          	sd	s3,40(sp)
    80002438:	03413023          	sd	s4,32(sp)
    8000243c:	01513c23          	sd	s5,24(sp)
    80002440:	05010413          	addi	s0,sp,80
    80002444:	06c05c63          	blez	a2,800024bc <consolewrite+0x9c>
    80002448:	00060993          	mv	s3,a2
    8000244c:	00050a13          	mv	s4,a0
    80002450:	00058493          	mv	s1,a1
    80002454:	00000913          	li	s2,0
    80002458:	fff00a93          	li	s5,-1
    8000245c:	01c0006f          	j	80002478 <consolewrite+0x58>
    80002460:	fbf44503          	lbu	a0,-65(s0)
    80002464:	0019091b          	addiw	s2,s2,1
    80002468:	00148493          	addi	s1,s1,1
    8000246c:	00001097          	auipc	ra,0x1
    80002470:	a9c080e7          	jalr	-1380(ra) # 80002f08 <uartputc>
    80002474:	03298063          	beq	s3,s2,80002494 <consolewrite+0x74>
    80002478:	00048613          	mv	a2,s1
    8000247c:	00100693          	li	a3,1
    80002480:	000a0593          	mv	a1,s4
    80002484:	fbf40513          	addi	a0,s0,-65
    80002488:	00000097          	auipc	ra,0x0
    8000248c:	9d8080e7          	jalr	-1576(ra) # 80001e60 <either_copyin>
    80002490:	fd5518e3          	bne	a0,s5,80002460 <consolewrite+0x40>
    80002494:	04813083          	ld	ra,72(sp)
    80002498:	04013403          	ld	s0,64(sp)
    8000249c:	03813483          	ld	s1,56(sp)
    800024a0:	02813983          	ld	s3,40(sp)
    800024a4:	02013a03          	ld	s4,32(sp)
    800024a8:	01813a83          	ld	s5,24(sp)
    800024ac:	00090513          	mv	a0,s2
    800024b0:	03013903          	ld	s2,48(sp)
    800024b4:	05010113          	addi	sp,sp,80
    800024b8:	00008067          	ret
    800024bc:	00000913          	li	s2,0
    800024c0:	fd5ff06f          	j	80002494 <consolewrite+0x74>

00000000800024c4 <consoleread>:
    800024c4:	f9010113          	addi	sp,sp,-112
    800024c8:	06813023          	sd	s0,96(sp)
    800024cc:	04913c23          	sd	s1,88(sp)
    800024d0:	05213823          	sd	s2,80(sp)
    800024d4:	05313423          	sd	s3,72(sp)
    800024d8:	05413023          	sd	s4,64(sp)
    800024dc:	03513c23          	sd	s5,56(sp)
    800024e0:	03613823          	sd	s6,48(sp)
    800024e4:	03713423          	sd	s7,40(sp)
    800024e8:	03813023          	sd	s8,32(sp)
    800024ec:	06113423          	sd	ra,104(sp)
    800024f0:	01913c23          	sd	s9,24(sp)
    800024f4:	07010413          	addi	s0,sp,112
    800024f8:	00060b93          	mv	s7,a2
    800024fc:	00050913          	mv	s2,a0
    80002500:	00058c13          	mv	s8,a1
    80002504:	00060b1b          	sext.w	s6,a2
    80002508:	00003497          	auipc	s1,0x3
    8000250c:	30048493          	addi	s1,s1,768 # 80005808 <cons>
    80002510:	00400993          	li	s3,4
    80002514:	fff00a13          	li	s4,-1
    80002518:	00a00a93          	li	s5,10
    8000251c:	05705e63          	blez	s7,80002578 <consoleread+0xb4>
    80002520:	09c4a703          	lw	a4,156(s1)
    80002524:	0984a783          	lw	a5,152(s1)
    80002528:	0007071b          	sext.w	a4,a4
    8000252c:	08e78463          	beq	a5,a4,800025b4 <consoleread+0xf0>
    80002530:	07f7f713          	andi	a4,a5,127
    80002534:	00e48733          	add	a4,s1,a4
    80002538:	01874703          	lbu	a4,24(a4) # c201018 <_entry-0x73dfefe8>
    8000253c:	0017869b          	addiw	a3,a5,1
    80002540:	08d4ac23          	sw	a3,152(s1)
    80002544:	00070c9b          	sext.w	s9,a4
    80002548:	0b370663          	beq	a4,s3,800025f4 <consoleread+0x130>
    8000254c:	00100693          	li	a3,1
    80002550:	f9f40613          	addi	a2,s0,-97
    80002554:	000c0593          	mv	a1,s8
    80002558:	00090513          	mv	a0,s2
    8000255c:	f8e40fa3          	sb	a4,-97(s0)
    80002560:	00000097          	auipc	ra,0x0
    80002564:	8b4080e7          	jalr	-1868(ra) # 80001e14 <either_copyout>
    80002568:	01450863          	beq	a0,s4,80002578 <consoleread+0xb4>
    8000256c:	001c0c13          	addi	s8,s8,1
    80002570:	fffb8b9b          	addiw	s7,s7,-1
    80002574:	fb5c94e3          	bne	s9,s5,8000251c <consoleread+0x58>
    80002578:	000b851b          	sext.w	a0,s7
    8000257c:	06813083          	ld	ra,104(sp)
    80002580:	06013403          	ld	s0,96(sp)
    80002584:	05813483          	ld	s1,88(sp)
    80002588:	05013903          	ld	s2,80(sp)
    8000258c:	04813983          	ld	s3,72(sp)
    80002590:	04013a03          	ld	s4,64(sp)
    80002594:	03813a83          	ld	s5,56(sp)
    80002598:	02813b83          	ld	s7,40(sp)
    8000259c:	02013c03          	ld	s8,32(sp)
    800025a0:	01813c83          	ld	s9,24(sp)
    800025a4:	40ab053b          	subw	a0,s6,a0
    800025a8:	03013b03          	ld	s6,48(sp)
    800025ac:	07010113          	addi	sp,sp,112
    800025b0:	00008067          	ret
    800025b4:	00001097          	auipc	ra,0x1
    800025b8:	1d8080e7          	jalr	472(ra) # 8000378c <push_on>
    800025bc:	0984a703          	lw	a4,152(s1)
    800025c0:	09c4a783          	lw	a5,156(s1)
    800025c4:	0007879b          	sext.w	a5,a5
    800025c8:	fef70ce3          	beq	a4,a5,800025c0 <consoleread+0xfc>
    800025cc:	00001097          	auipc	ra,0x1
    800025d0:	234080e7          	jalr	564(ra) # 80003800 <pop_on>
    800025d4:	0984a783          	lw	a5,152(s1)
    800025d8:	07f7f713          	andi	a4,a5,127
    800025dc:	00e48733          	add	a4,s1,a4
    800025e0:	01874703          	lbu	a4,24(a4)
    800025e4:	0017869b          	addiw	a3,a5,1
    800025e8:	08d4ac23          	sw	a3,152(s1)
    800025ec:	00070c9b          	sext.w	s9,a4
    800025f0:	f5371ee3          	bne	a4,s3,8000254c <consoleread+0x88>
    800025f4:	000b851b          	sext.w	a0,s7
    800025f8:	f96bf2e3          	bgeu	s7,s6,8000257c <consoleread+0xb8>
    800025fc:	08f4ac23          	sw	a5,152(s1)
    80002600:	f7dff06f          	j	8000257c <consoleread+0xb8>

0000000080002604 <consputc>:
    80002604:	10000793          	li	a5,256
    80002608:	00f50663          	beq	a0,a5,80002614 <consputc+0x10>
    8000260c:	00001317          	auipc	t1,0x1
    80002610:	9f430067          	jr	-1548(t1) # 80003000 <uartputc_sync>
    80002614:	ff010113          	addi	sp,sp,-16
    80002618:	00113423          	sd	ra,8(sp)
    8000261c:	00813023          	sd	s0,0(sp)
    80002620:	01010413          	addi	s0,sp,16
    80002624:	00800513          	li	a0,8
    80002628:	00001097          	auipc	ra,0x1
    8000262c:	9d8080e7          	jalr	-1576(ra) # 80003000 <uartputc_sync>
    80002630:	02000513          	li	a0,32
    80002634:	00001097          	auipc	ra,0x1
    80002638:	9cc080e7          	jalr	-1588(ra) # 80003000 <uartputc_sync>
    8000263c:	00013403          	ld	s0,0(sp)
    80002640:	00813083          	ld	ra,8(sp)
    80002644:	00800513          	li	a0,8
    80002648:	01010113          	addi	sp,sp,16
    8000264c:	00001317          	auipc	t1,0x1
    80002650:	9b430067          	jr	-1612(t1) # 80003000 <uartputc_sync>

0000000080002654 <consoleintr>:
    80002654:	fe010113          	addi	sp,sp,-32
    80002658:	00813823          	sd	s0,16(sp)
    8000265c:	00913423          	sd	s1,8(sp)
    80002660:	01213023          	sd	s2,0(sp)
    80002664:	00113c23          	sd	ra,24(sp)
    80002668:	02010413          	addi	s0,sp,32
    8000266c:	00003917          	auipc	s2,0x3
    80002670:	19c90913          	addi	s2,s2,412 # 80005808 <cons>
    80002674:	00050493          	mv	s1,a0
    80002678:	00090513          	mv	a0,s2
    8000267c:	00001097          	auipc	ra,0x1
    80002680:	e40080e7          	jalr	-448(ra) # 800034bc <acquire>
    80002684:	02048c63          	beqz	s1,800026bc <consoleintr+0x68>
    80002688:	0a092783          	lw	a5,160(s2)
    8000268c:	09892703          	lw	a4,152(s2)
    80002690:	07f00693          	li	a3,127
    80002694:	40e7873b          	subw	a4,a5,a4
    80002698:	02e6e263          	bltu	a3,a4,800026bc <consoleintr+0x68>
    8000269c:	00d00713          	li	a4,13
    800026a0:	04e48063          	beq	s1,a4,800026e0 <consoleintr+0x8c>
    800026a4:	07f7f713          	andi	a4,a5,127
    800026a8:	00e90733          	add	a4,s2,a4
    800026ac:	0017879b          	addiw	a5,a5,1
    800026b0:	0af92023          	sw	a5,160(s2)
    800026b4:	00970c23          	sb	s1,24(a4)
    800026b8:	08f92e23          	sw	a5,156(s2)
    800026bc:	01013403          	ld	s0,16(sp)
    800026c0:	01813083          	ld	ra,24(sp)
    800026c4:	00813483          	ld	s1,8(sp)
    800026c8:	00013903          	ld	s2,0(sp)
    800026cc:	00003517          	auipc	a0,0x3
    800026d0:	13c50513          	addi	a0,a0,316 # 80005808 <cons>
    800026d4:	02010113          	addi	sp,sp,32
    800026d8:	00001317          	auipc	t1,0x1
    800026dc:	eb030067          	jr	-336(t1) # 80003588 <release>
    800026e0:	00a00493          	li	s1,10
    800026e4:	fc1ff06f          	j	800026a4 <consoleintr+0x50>

00000000800026e8 <consoleinit>:
    800026e8:	fe010113          	addi	sp,sp,-32
    800026ec:	00113c23          	sd	ra,24(sp)
    800026f0:	00813823          	sd	s0,16(sp)
    800026f4:	00913423          	sd	s1,8(sp)
    800026f8:	02010413          	addi	s0,sp,32
    800026fc:	00003497          	auipc	s1,0x3
    80002700:	10c48493          	addi	s1,s1,268 # 80005808 <cons>
    80002704:	00048513          	mv	a0,s1
    80002708:	00002597          	auipc	a1,0x2
    8000270c:	b3858593          	addi	a1,a1,-1224 # 80004240 <CONSOLE_STATUS+0x230>
    80002710:	00001097          	auipc	ra,0x1
    80002714:	d88080e7          	jalr	-632(ra) # 80003498 <initlock>
    80002718:	00000097          	auipc	ra,0x0
    8000271c:	7ac080e7          	jalr	1964(ra) # 80002ec4 <uartinit>
    80002720:	01813083          	ld	ra,24(sp)
    80002724:	01013403          	ld	s0,16(sp)
    80002728:	00000797          	auipc	a5,0x0
    8000272c:	d9c78793          	addi	a5,a5,-612 # 800024c4 <consoleread>
    80002730:	0af4bc23          	sd	a5,184(s1)
    80002734:	00000797          	auipc	a5,0x0
    80002738:	cec78793          	addi	a5,a5,-788 # 80002420 <consolewrite>
    8000273c:	0cf4b023          	sd	a5,192(s1)
    80002740:	00813483          	ld	s1,8(sp)
    80002744:	02010113          	addi	sp,sp,32
    80002748:	00008067          	ret

000000008000274c <console_read>:
    8000274c:	ff010113          	addi	sp,sp,-16
    80002750:	00813423          	sd	s0,8(sp)
    80002754:	01010413          	addi	s0,sp,16
    80002758:	00813403          	ld	s0,8(sp)
    8000275c:	00003317          	auipc	t1,0x3
    80002760:	16433303          	ld	t1,356(t1) # 800058c0 <devsw+0x10>
    80002764:	01010113          	addi	sp,sp,16
    80002768:	00030067          	jr	t1

000000008000276c <console_write>:
    8000276c:	ff010113          	addi	sp,sp,-16
    80002770:	00813423          	sd	s0,8(sp)
    80002774:	01010413          	addi	s0,sp,16
    80002778:	00813403          	ld	s0,8(sp)
    8000277c:	00003317          	auipc	t1,0x3
    80002780:	14c33303          	ld	t1,332(t1) # 800058c8 <devsw+0x18>
    80002784:	01010113          	addi	sp,sp,16
    80002788:	00030067          	jr	t1

000000008000278c <panic>:
    8000278c:	fe010113          	addi	sp,sp,-32
    80002790:	00113c23          	sd	ra,24(sp)
    80002794:	00813823          	sd	s0,16(sp)
    80002798:	00913423          	sd	s1,8(sp)
    8000279c:	02010413          	addi	s0,sp,32
    800027a0:	00050493          	mv	s1,a0
    800027a4:	00002517          	auipc	a0,0x2
    800027a8:	aa450513          	addi	a0,a0,-1372 # 80004248 <CONSOLE_STATUS+0x238>
    800027ac:	00003797          	auipc	a5,0x3
    800027b0:	1a07ae23          	sw	zero,444(a5) # 80005968 <pr+0x18>
    800027b4:	00000097          	auipc	ra,0x0
    800027b8:	034080e7          	jalr	52(ra) # 800027e8 <__printf>
    800027bc:	00048513          	mv	a0,s1
    800027c0:	00000097          	auipc	ra,0x0
    800027c4:	028080e7          	jalr	40(ra) # 800027e8 <__printf>
    800027c8:	00002517          	auipc	a0,0x2
    800027cc:	a6050513          	addi	a0,a0,-1440 # 80004228 <CONSOLE_STATUS+0x218>
    800027d0:	00000097          	auipc	ra,0x0
    800027d4:	018080e7          	jalr	24(ra) # 800027e8 <__printf>
    800027d8:	00100793          	li	a5,1
    800027dc:	00002717          	auipc	a4,0x2
    800027e0:	f2f72e23          	sw	a5,-196(a4) # 80004718 <panicked>
    800027e4:	0000006f          	j	800027e4 <panic+0x58>

00000000800027e8 <__printf>:
    800027e8:	f3010113          	addi	sp,sp,-208
    800027ec:	08813023          	sd	s0,128(sp)
    800027f0:	07313423          	sd	s3,104(sp)
    800027f4:	09010413          	addi	s0,sp,144
    800027f8:	05813023          	sd	s8,64(sp)
    800027fc:	08113423          	sd	ra,136(sp)
    80002800:	06913c23          	sd	s1,120(sp)
    80002804:	07213823          	sd	s2,112(sp)
    80002808:	07413023          	sd	s4,96(sp)
    8000280c:	05513c23          	sd	s5,88(sp)
    80002810:	05613823          	sd	s6,80(sp)
    80002814:	05713423          	sd	s7,72(sp)
    80002818:	03913c23          	sd	s9,56(sp)
    8000281c:	03a13823          	sd	s10,48(sp)
    80002820:	03b13423          	sd	s11,40(sp)
    80002824:	00003317          	auipc	t1,0x3
    80002828:	12c30313          	addi	t1,t1,300 # 80005950 <pr>
    8000282c:	01832c03          	lw	s8,24(t1)
    80002830:	00b43423          	sd	a1,8(s0)
    80002834:	00c43823          	sd	a2,16(s0)
    80002838:	00d43c23          	sd	a3,24(s0)
    8000283c:	02e43023          	sd	a4,32(s0)
    80002840:	02f43423          	sd	a5,40(s0)
    80002844:	03043823          	sd	a6,48(s0)
    80002848:	03143c23          	sd	a7,56(s0)
    8000284c:	00050993          	mv	s3,a0
    80002850:	4a0c1663          	bnez	s8,80002cfc <__printf+0x514>
    80002854:	60098c63          	beqz	s3,80002e6c <__printf+0x684>
    80002858:	0009c503          	lbu	a0,0(s3)
    8000285c:	00840793          	addi	a5,s0,8
    80002860:	f6f43c23          	sd	a5,-136(s0)
    80002864:	00000493          	li	s1,0
    80002868:	22050063          	beqz	a0,80002a88 <__printf+0x2a0>
    8000286c:	00002a37          	lui	s4,0x2
    80002870:	00018ab7          	lui	s5,0x18
    80002874:	000f4b37          	lui	s6,0xf4
    80002878:	00989bb7          	lui	s7,0x989
    8000287c:	70fa0a13          	addi	s4,s4,1807 # 270f <_entry-0x7fffd8f1>
    80002880:	69fa8a93          	addi	s5,s5,1695 # 1869f <_entry-0x7ffe7961>
    80002884:	23fb0b13          	addi	s6,s6,575 # f423f <_entry-0x7ff0bdc1>
    80002888:	67fb8b93          	addi	s7,s7,1663 # 98967f <_entry-0x7f676981>
    8000288c:	00148c9b          	addiw	s9,s1,1
    80002890:	02500793          	li	a5,37
    80002894:	01998933          	add	s2,s3,s9
    80002898:	38f51263          	bne	a0,a5,80002c1c <__printf+0x434>
    8000289c:	00094783          	lbu	a5,0(s2)
    800028a0:	00078c9b          	sext.w	s9,a5
    800028a4:	1e078263          	beqz	a5,80002a88 <__printf+0x2a0>
    800028a8:	0024849b          	addiw	s1,s1,2
    800028ac:	07000713          	li	a4,112
    800028b0:	00998933          	add	s2,s3,s1
    800028b4:	38e78a63          	beq	a5,a4,80002c48 <__printf+0x460>
    800028b8:	20f76863          	bltu	a4,a5,80002ac8 <__printf+0x2e0>
    800028bc:	42a78863          	beq	a5,a0,80002cec <__printf+0x504>
    800028c0:	06400713          	li	a4,100
    800028c4:	40e79663          	bne	a5,a4,80002cd0 <__printf+0x4e8>
    800028c8:	f7843783          	ld	a5,-136(s0)
    800028cc:	0007a603          	lw	a2,0(a5)
    800028d0:	00878793          	addi	a5,a5,8
    800028d4:	f6f43c23          	sd	a5,-136(s0)
    800028d8:	42064a63          	bltz	a2,80002d0c <__printf+0x524>
    800028dc:	00a00713          	li	a4,10
    800028e0:	02e677bb          	remuw	a5,a2,a4
    800028e4:	00002d97          	auipc	s11,0x2
    800028e8:	98cd8d93          	addi	s11,s11,-1652 # 80004270 <digits>
    800028ec:	00900593          	li	a1,9
    800028f0:	0006051b          	sext.w	a0,a2
    800028f4:	00000c93          	li	s9,0
    800028f8:	02079793          	slli	a5,a5,0x20
    800028fc:	0207d793          	srli	a5,a5,0x20
    80002900:	00fd87b3          	add	a5,s11,a5
    80002904:	0007c783          	lbu	a5,0(a5)
    80002908:	02e656bb          	divuw	a3,a2,a4
    8000290c:	f8f40023          	sb	a5,-128(s0)
    80002910:	14c5d863          	bge	a1,a2,80002a60 <__printf+0x278>
    80002914:	06300593          	li	a1,99
    80002918:	00100c93          	li	s9,1
    8000291c:	02e6f7bb          	remuw	a5,a3,a4
    80002920:	02079793          	slli	a5,a5,0x20
    80002924:	0207d793          	srli	a5,a5,0x20
    80002928:	00fd87b3          	add	a5,s11,a5
    8000292c:	0007c783          	lbu	a5,0(a5)
    80002930:	02e6d73b          	divuw	a4,a3,a4
    80002934:	f8f400a3          	sb	a5,-127(s0)
    80002938:	12a5f463          	bgeu	a1,a0,80002a60 <__printf+0x278>
    8000293c:	00a00693          	li	a3,10
    80002940:	00900593          	li	a1,9
    80002944:	02d777bb          	remuw	a5,a4,a3
    80002948:	02079793          	slli	a5,a5,0x20
    8000294c:	0207d793          	srli	a5,a5,0x20
    80002950:	00fd87b3          	add	a5,s11,a5
    80002954:	0007c503          	lbu	a0,0(a5)
    80002958:	02d757bb          	divuw	a5,a4,a3
    8000295c:	f8a40123          	sb	a0,-126(s0)
    80002960:	48e5f263          	bgeu	a1,a4,80002de4 <__printf+0x5fc>
    80002964:	06300513          	li	a0,99
    80002968:	02d7f5bb          	remuw	a1,a5,a3
    8000296c:	02059593          	slli	a1,a1,0x20
    80002970:	0205d593          	srli	a1,a1,0x20
    80002974:	00bd85b3          	add	a1,s11,a1
    80002978:	0005c583          	lbu	a1,0(a1)
    8000297c:	02d7d7bb          	divuw	a5,a5,a3
    80002980:	f8b401a3          	sb	a1,-125(s0)
    80002984:	48e57263          	bgeu	a0,a4,80002e08 <__printf+0x620>
    80002988:	3e700513          	li	a0,999
    8000298c:	02d7f5bb          	remuw	a1,a5,a3
    80002990:	02059593          	slli	a1,a1,0x20
    80002994:	0205d593          	srli	a1,a1,0x20
    80002998:	00bd85b3          	add	a1,s11,a1
    8000299c:	0005c583          	lbu	a1,0(a1)
    800029a0:	02d7d7bb          	divuw	a5,a5,a3
    800029a4:	f8b40223          	sb	a1,-124(s0)
    800029a8:	46e57663          	bgeu	a0,a4,80002e14 <__printf+0x62c>
    800029ac:	02d7f5bb          	remuw	a1,a5,a3
    800029b0:	02059593          	slli	a1,a1,0x20
    800029b4:	0205d593          	srli	a1,a1,0x20
    800029b8:	00bd85b3          	add	a1,s11,a1
    800029bc:	0005c583          	lbu	a1,0(a1)
    800029c0:	02d7d7bb          	divuw	a5,a5,a3
    800029c4:	f8b402a3          	sb	a1,-123(s0)
    800029c8:	46ea7863          	bgeu	s4,a4,80002e38 <__printf+0x650>
    800029cc:	02d7f5bb          	remuw	a1,a5,a3
    800029d0:	02059593          	slli	a1,a1,0x20
    800029d4:	0205d593          	srli	a1,a1,0x20
    800029d8:	00bd85b3          	add	a1,s11,a1
    800029dc:	0005c583          	lbu	a1,0(a1)
    800029e0:	02d7d7bb          	divuw	a5,a5,a3
    800029e4:	f8b40323          	sb	a1,-122(s0)
    800029e8:	3eeaf863          	bgeu	s5,a4,80002dd8 <__printf+0x5f0>
    800029ec:	02d7f5bb          	remuw	a1,a5,a3
    800029f0:	02059593          	slli	a1,a1,0x20
    800029f4:	0205d593          	srli	a1,a1,0x20
    800029f8:	00bd85b3          	add	a1,s11,a1
    800029fc:	0005c583          	lbu	a1,0(a1)
    80002a00:	02d7d7bb          	divuw	a5,a5,a3
    80002a04:	f8b403a3          	sb	a1,-121(s0)
    80002a08:	42eb7e63          	bgeu	s6,a4,80002e44 <__printf+0x65c>
    80002a0c:	02d7f5bb          	remuw	a1,a5,a3
    80002a10:	02059593          	slli	a1,a1,0x20
    80002a14:	0205d593          	srli	a1,a1,0x20
    80002a18:	00bd85b3          	add	a1,s11,a1
    80002a1c:	0005c583          	lbu	a1,0(a1)
    80002a20:	02d7d7bb          	divuw	a5,a5,a3
    80002a24:	f8b40423          	sb	a1,-120(s0)
    80002a28:	42ebfc63          	bgeu	s7,a4,80002e60 <__printf+0x678>
    80002a2c:	02079793          	slli	a5,a5,0x20
    80002a30:	0207d793          	srli	a5,a5,0x20
    80002a34:	00fd8db3          	add	s11,s11,a5
    80002a38:	000dc703          	lbu	a4,0(s11)
    80002a3c:	00a00793          	li	a5,10
    80002a40:	00900c93          	li	s9,9
    80002a44:	f8e404a3          	sb	a4,-119(s0)
    80002a48:	00065c63          	bgez	a2,80002a60 <__printf+0x278>
    80002a4c:	f9040713          	addi	a4,s0,-112
    80002a50:	00f70733          	add	a4,a4,a5
    80002a54:	02d00693          	li	a3,45
    80002a58:	fed70823          	sb	a3,-16(a4)
    80002a5c:	00078c93          	mv	s9,a5
    80002a60:	f8040793          	addi	a5,s0,-128
    80002a64:	01978cb3          	add	s9,a5,s9
    80002a68:	f7f40d13          	addi	s10,s0,-129
    80002a6c:	000cc503          	lbu	a0,0(s9)
    80002a70:	fffc8c93          	addi	s9,s9,-1
    80002a74:	00000097          	auipc	ra,0x0
    80002a78:	b90080e7          	jalr	-1136(ra) # 80002604 <consputc>
    80002a7c:	ffac98e3          	bne	s9,s10,80002a6c <__printf+0x284>
    80002a80:	00094503          	lbu	a0,0(s2)
    80002a84:	e00514e3          	bnez	a0,8000288c <__printf+0xa4>
    80002a88:	1a0c1663          	bnez	s8,80002c34 <__printf+0x44c>
    80002a8c:	08813083          	ld	ra,136(sp)
    80002a90:	08013403          	ld	s0,128(sp)
    80002a94:	07813483          	ld	s1,120(sp)
    80002a98:	07013903          	ld	s2,112(sp)
    80002a9c:	06813983          	ld	s3,104(sp)
    80002aa0:	06013a03          	ld	s4,96(sp)
    80002aa4:	05813a83          	ld	s5,88(sp)
    80002aa8:	05013b03          	ld	s6,80(sp)
    80002aac:	04813b83          	ld	s7,72(sp)
    80002ab0:	04013c03          	ld	s8,64(sp)
    80002ab4:	03813c83          	ld	s9,56(sp)
    80002ab8:	03013d03          	ld	s10,48(sp)
    80002abc:	02813d83          	ld	s11,40(sp)
    80002ac0:	0d010113          	addi	sp,sp,208
    80002ac4:	00008067          	ret
    80002ac8:	07300713          	li	a4,115
    80002acc:	1ce78a63          	beq	a5,a4,80002ca0 <__printf+0x4b8>
    80002ad0:	07800713          	li	a4,120
    80002ad4:	1ee79e63          	bne	a5,a4,80002cd0 <__printf+0x4e8>
    80002ad8:	f7843783          	ld	a5,-136(s0)
    80002adc:	0007a703          	lw	a4,0(a5)
    80002ae0:	00878793          	addi	a5,a5,8
    80002ae4:	f6f43c23          	sd	a5,-136(s0)
    80002ae8:	28074263          	bltz	a4,80002d6c <__printf+0x584>
    80002aec:	00001d97          	auipc	s11,0x1
    80002af0:	784d8d93          	addi	s11,s11,1924 # 80004270 <digits>
    80002af4:	00f77793          	andi	a5,a4,15
    80002af8:	00fd87b3          	add	a5,s11,a5
    80002afc:	0007c683          	lbu	a3,0(a5)
    80002b00:	00f00613          	li	a2,15
    80002b04:	0007079b          	sext.w	a5,a4
    80002b08:	f8d40023          	sb	a3,-128(s0)
    80002b0c:	0047559b          	srliw	a1,a4,0x4
    80002b10:	0047569b          	srliw	a3,a4,0x4
    80002b14:	00000c93          	li	s9,0
    80002b18:	0ee65063          	bge	a2,a4,80002bf8 <__printf+0x410>
    80002b1c:	00f6f693          	andi	a3,a3,15
    80002b20:	00dd86b3          	add	a3,s11,a3
    80002b24:	0006c683          	lbu	a3,0(a3) # 2004000 <_entry-0x7dffc000>
    80002b28:	0087d79b          	srliw	a5,a5,0x8
    80002b2c:	00100c93          	li	s9,1
    80002b30:	f8d400a3          	sb	a3,-127(s0)
    80002b34:	0cb67263          	bgeu	a2,a1,80002bf8 <__printf+0x410>
    80002b38:	00f7f693          	andi	a3,a5,15
    80002b3c:	00dd86b3          	add	a3,s11,a3
    80002b40:	0006c583          	lbu	a1,0(a3)
    80002b44:	00f00613          	li	a2,15
    80002b48:	0047d69b          	srliw	a3,a5,0x4
    80002b4c:	f8b40123          	sb	a1,-126(s0)
    80002b50:	0047d593          	srli	a1,a5,0x4
    80002b54:	28f67e63          	bgeu	a2,a5,80002df0 <__printf+0x608>
    80002b58:	00f6f693          	andi	a3,a3,15
    80002b5c:	00dd86b3          	add	a3,s11,a3
    80002b60:	0006c503          	lbu	a0,0(a3)
    80002b64:	0087d813          	srli	a6,a5,0x8
    80002b68:	0087d69b          	srliw	a3,a5,0x8
    80002b6c:	f8a401a3          	sb	a0,-125(s0)
    80002b70:	28b67663          	bgeu	a2,a1,80002dfc <__printf+0x614>
    80002b74:	00f6f693          	andi	a3,a3,15
    80002b78:	00dd86b3          	add	a3,s11,a3
    80002b7c:	0006c583          	lbu	a1,0(a3)
    80002b80:	00c7d513          	srli	a0,a5,0xc
    80002b84:	00c7d69b          	srliw	a3,a5,0xc
    80002b88:	f8b40223          	sb	a1,-124(s0)
    80002b8c:	29067a63          	bgeu	a2,a6,80002e20 <__printf+0x638>
    80002b90:	00f6f693          	andi	a3,a3,15
    80002b94:	00dd86b3          	add	a3,s11,a3
    80002b98:	0006c583          	lbu	a1,0(a3)
    80002b9c:	0107d813          	srli	a6,a5,0x10
    80002ba0:	0107d69b          	srliw	a3,a5,0x10
    80002ba4:	f8b402a3          	sb	a1,-123(s0)
    80002ba8:	28a67263          	bgeu	a2,a0,80002e2c <__printf+0x644>
    80002bac:	00f6f693          	andi	a3,a3,15
    80002bb0:	00dd86b3          	add	a3,s11,a3
    80002bb4:	0006c683          	lbu	a3,0(a3)
    80002bb8:	0147d79b          	srliw	a5,a5,0x14
    80002bbc:	f8d40323          	sb	a3,-122(s0)
    80002bc0:	21067663          	bgeu	a2,a6,80002dcc <__printf+0x5e4>
    80002bc4:	02079793          	slli	a5,a5,0x20
    80002bc8:	0207d793          	srli	a5,a5,0x20
    80002bcc:	00fd8db3          	add	s11,s11,a5
    80002bd0:	000dc683          	lbu	a3,0(s11)
    80002bd4:	00800793          	li	a5,8
    80002bd8:	00700c93          	li	s9,7
    80002bdc:	f8d403a3          	sb	a3,-121(s0)
    80002be0:	00075c63          	bgez	a4,80002bf8 <__printf+0x410>
    80002be4:	f9040713          	addi	a4,s0,-112
    80002be8:	00f70733          	add	a4,a4,a5
    80002bec:	02d00693          	li	a3,45
    80002bf0:	fed70823          	sb	a3,-16(a4)
    80002bf4:	00078c93          	mv	s9,a5
    80002bf8:	f8040793          	addi	a5,s0,-128
    80002bfc:	01978cb3          	add	s9,a5,s9
    80002c00:	f7f40d13          	addi	s10,s0,-129
    80002c04:	000cc503          	lbu	a0,0(s9)
    80002c08:	fffc8c93          	addi	s9,s9,-1
    80002c0c:	00000097          	auipc	ra,0x0
    80002c10:	9f8080e7          	jalr	-1544(ra) # 80002604 <consputc>
    80002c14:	ff9d18e3          	bne	s10,s9,80002c04 <__printf+0x41c>
    80002c18:	0100006f          	j	80002c28 <__printf+0x440>
    80002c1c:	00000097          	auipc	ra,0x0
    80002c20:	9e8080e7          	jalr	-1560(ra) # 80002604 <consputc>
    80002c24:	000c8493          	mv	s1,s9
    80002c28:	00094503          	lbu	a0,0(s2)
    80002c2c:	c60510e3          	bnez	a0,8000288c <__printf+0xa4>
    80002c30:	e40c0ee3          	beqz	s8,80002a8c <__printf+0x2a4>
    80002c34:	00003517          	auipc	a0,0x3
    80002c38:	d1c50513          	addi	a0,a0,-740 # 80005950 <pr>
    80002c3c:	00001097          	auipc	ra,0x1
    80002c40:	94c080e7          	jalr	-1716(ra) # 80003588 <release>
    80002c44:	e49ff06f          	j	80002a8c <__printf+0x2a4>
    80002c48:	f7843783          	ld	a5,-136(s0)
    80002c4c:	03000513          	li	a0,48
    80002c50:	01000d13          	li	s10,16
    80002c54:	00878713          	addi	a4,a5,8
    80002c58:	0007bc83          	ld	s9,0(a5)
    80002c5c:	f6e43c23          	sd	a4,-136(s0)
    80002c60:	00000097          	auipc	ra,0x0
    80002c64:	9a4080e7          	jalr	-1628(ra) # 80002604 <consputc>
    80002c68:	07800513          	li	a0,120
    80002c6c:	00000097          	auipc	ra,0x0
    80002c70:	998080e7          	jalr	-1640(ra) # 80002604 <consputc>
    80002c74:	00001d97          	auipc	s11,0x1
    80002c78:	5fcd8d93          	addi	s11,s11,1532 # 80004270 <digits>
    80002c7c:	03ccd793          	srli	a5,s9,0x3c
    80002c80:	00fd87b3          	add	a5,s11,a5
    80002c84:	0007c503          	lbu	a0,0(a5)
    80002c88:	fffd0d1b          	addiw	s10,s10,-1
    80002c8c:	004c9c93          	slli	s9,s9,0x4
    80002c90:	00000097          	auipc	ra,0x0
    80002c94:	974080e7          	jalr	-1676(ra) # 80002604 <consputc>
    80002c98:	fe0d12e3          	bnez	s10,80002c7c <__printf+0x494>
    80002c9c:	f8dff06f          	j	80002c28 <__printf+0x440>
    80002ca0:	f7843783          	ld	a5,-136(s0)
    80002ca4:	0007bc83          	ld	s9,0(a5)
    80002ca8:	00878793          	addi	a5,a5,8
    80002cac:	f6f43c23          	sd	a5,-136(s0)
    80002cb0:	000c9a63          	bnez	s9,80002cc4 <__printf+0x4dc>
    80002cb4:	1080006f          	j	80002dbc <__printf+0x5d4>
    80002cb8:	001c8c93          	addi	s9,s9,1
    80002cbc:	00000097          	auipc	ra,0x0
    80002cc0:	948080e7          	jalr	-1720(ra) # 80002604 <consputc>
    80002cc4:	000cc503          	lbu	a0,0(s9)
    80002cc8:	fe0518e3          	bnez	a0,80002cb8 <__printf+0x4d0>
    80002ccc:	f5dff06f          	j	80002c28 <__printf+0x440>
    80002cd0:	02500513          	li	a0,37
    80002cd4:	00000097          	auipc	ra,0x0
    80002cd8:	930080e7          	jalr	-1744(ra) # 80002604 <consputc>
    80002cdc:	000c8513          	mv	a0,s9
    80002ce0:	00000097          	auipc	ra,0x0
    80002ce4:	924080e7          	jalr	-1756(ra) # 80002604 <consputc>
    80002ce8:	f41ff06f          	j	80002c28 <__printf+0x440>
    80002cec:	02500513          	li	a0,37
    80002cf0:	00000097          	auipc	ra,0x0
    80002cf4:	914080e7          	jalr	-1772(ra) # 80002604 <consputc>
    80002cf8:	f31ff06f          	j	80002c28 <__printf+0x440>
    80002cfc:	00030513          	mv	a0,t1
    80002d00:	00000097          	auipc	ra,0x0
    80002d04:	7bc080e7          	jalr	1980(ra) # 800034bc <acquire>
    80002d08:	b4dff06f          	j	80002854 <__printf+0x6c>
    80002d0c:	40c0053b          	negw	a0,a2
    80002d10:	00a00713          	li	a4,10
    80002d14:	02e576bb          	remuw	a3,a0,a4
    80002d18:	00001d97          	auipc	s11,0x1
    80002d1c:	558d8d93          	addi	s11,s11,1368 # 80004270 <digits>
    80002d20:	ff700593          	li	a1,-9
    80002d24:	02069693          	slli	a3,a3,0x20
    80002d28:	0206d693          	srli	a3,a3,0x20
    80002d2c:	00dd86b3          	add	a3,s11,a3
    80002d30:	0006c683          	lbu	a3,0(a3)
    80002d34:	02e557bb          	divuw	a5,a0,a4
    80002d38:	f8d40023          	sb	a3,-128(s0)
    80002d3c:	10b65e63          	bge	a2,a1,80002e58 <__printf+0x670>
    80002d40:	06300593          	li	a1,99
    80002d44:	02e7f6bb          	remuw	a3,a5,a4
    80002d48:	02069693          	slli	a3,a3,0x20
    80002d4c:	0206d693          	srli	a3,a3,0x20
    80002d50:	00dd86b3          	add	a3,s11,a3
    80002d54:	0006c683          	lbu	a3,0(a3)
    80002d58:	02e7d73b          	divuw	a4,a5,a4
    80002d5c:	00200793          	li	a5,2
    80002d60:	f8d400a3          	sb	a3,-127(s0)
    80002d64:	bca5ece3          	bltu	a1,a0,8000293c <__printf+0x154>
    80002d68:	ce5ff06f          	j	80002a4c <__printf+0x264>
    80002d6c:	40e007bb          	negw	a5,a4
    80002d70:	00001d97          	auipc	s11,0x1
    80002d74:	500d8d93          	addi	s11,s11,1280 # 80004270 <digits>
    80002d78:	00f7f693          	andi	a3,a5,15
    80002d7c:	00dd86b3          	add	a3,s11,a3
    80002d80:	0006c583          	lbu	a1,0(a3)
    80002d84:	ff100613          	li	a2,-15
    80002d88:	0047d69b          	srliw	a3,a5,0x4
    80002d8c:	f8b40023          	sb	a1,-128(s0)
    80002d90:	0047d59b          	srliw	a1,a5,0x4
    80002d94:	0ac75e63          	bge	a4,a2,80002e50 <__printf+0x668>
    80002d98:	00f6f693          	andi	a3,a3,15
    80002d9c:	00dd86b3          	add	a3,s11,a3
    80002da0:	0006c603          	lbu	a2,0(a3)
    80002da4:	00f00693          	li	a3,15
    80002da8:	0087d79b          	srliw	a5,a5,0x8
    80002dac:	f8c400a3          	sb	a2,-127(s0)
    80002db0:	d8b6e4e3          	bltu	a3,a1,80002b38 <__printf+0x350>
    80002db4:	00200793          	li	a5,2
    80002db8:	e2dff06f          	j	80002be4 <__printf+0x3fc>
    80002dbc:	00001c97          	auipc	s9,0x1
    80002dc0:	494c8c93          	addi	s9,s9,1172 # 80004250 <CONSOLE_STATUS+0x240>
    80002dc4:	02800513          	li	a0,40
    80002dc8:	ef1ff06f          	j	80002cb8 <__printf+0x4d0>
    80002dcc:	00700793          	li	a5,7
    80002dd0:	00600c93          	li	s9,6
    80002dd4:	e0dff06f          	j	80002be0 <__printf+0x3f8>
    80002dd8:	00700793          	li	a5,7
    80002ddc:	00600c93          	li	s9,6
    80002de0:	c69ff06f          	j	80002a48 <__printf+0x260>
    80002de4:	00300793          	li	a5,3
    80002de8:	00200c93          	li	s9,2
    80002dec:	c5dff06f          	j	80002a48 <__printf+0x260>
    80002df0:	00300793          	li	a5,3
    80002df4:	00200c93          	li	s9,2
    80002df8:	de9ff06f          	j	80002be0 <__printf+0x3f8>
    80002dfc:	00400793          	li	a5,4
    80002e00:	00300c93          	li	s9,3
    80002e04:	dddff06f          	j	80002be0 <__printf+0x3f8>
    80002e08:	00400793          	li	a5,4
    80002e0c:	00300c93          	li	s9,3
    80002e10:	c39ff06f          	j	80002a48 <__printf+0x260>
    80002e14:	00500793          	li	a5,5
    80002e18:	00400c93          	li	s9,4
    80002e1c:	c2dff06f          	j	80002a48 <__printf+0x260>
    80002e20:	00500793          	li	a5,5
    80002e24:	00400c93          	li	s9,4
    80002e28:	db9ff06f          	j	80002be0 <__printf+0x3f8>
    80002e2c:	00600793          	li	a5,6
    80002e30:	00500c93          	li	s9,5
    80002e34:	dadff06f          	j	80002be0 <__printf+0x3f8>
    80002e38:	00600793          	li	a5,6
    80002e3c:	00500c93          	li	s9,5
    80002e40:	c09ff06f          	j	80002a48 <__printf+0x260>
    80002e44:	00800793          	li	a5,8
    80002e48:	00700c93          	li	s9,7
    80002e4c:	bfdff06f          	j	80002a48 <__printf+0x260>
    80002e50:	00100793          	li	a5,1
    80002e54:	d91ff06f          	j	80002be4 <__printf+0x3fc>
    80002e58:	00100793          	li	a5,1
    80002e5c:	bf1ff06f          	j	80002a4c <__printf+0x264>
    80002e60:	00900793          	li	a5,9
    80002e64:	00800c93          	li	s9,8
    80002e68:	be1ff06f          	j	80002a48 <__printf+0x260>
    80002e6c:	00001517          	auipc	a0,0x1
    80002e70:	3ec50513          	addi	a0,a0,1004 # 80004258 <CONSOLE_STATUS+0x248>
    80002e74:	00000097          	auipc	ra,0x0
    80002e78:	918080e7          	jalr	-1768(ra) # 8000278c <panic>

0000000080002e7c <printfinit>:
    80002e7c:	fe010113          	addi	sp,sp,-32
    80002e80:	00813823          	sd	s0,16(sp)
    80002e84:	00913423          	sd	s1,8(sp)
    80002e88:	00113c23          	sd	ra,24(sp)
    80002e8c:	02010413          	addi	s0,sp,32
    80002e90:	00003497          	auipc	s1,0x3
    80002e94:	ac048493          	addi	s1,s1,-1344 # 80005950 <pr>
    80002e98:	00048513          	mv	a0,s1
    80002e9c:	00001597          	auipc	a1,0x1
    80002ea0:	3cc58593          	addi	a1,a1,972 # 80004268 <CONSOLE_STATUS+0x258>
    80002ea4:	00000097          	auipc	ra,0x0
    80002ea8:	5f4080e7          	jalr	1524(ra) # 80003498 <initlock>
    80002eac:	01813083          	ld	ra,24(sp)
    80002eb0:	01013403          	ld	s0,16(sp)
    80002eb4:	0004ac23          	sw	zero,24(s1)
    80002eb8:	00813483          	ld	s1,8(sp)
    80002ebc:	02010113          	addi	sp,sp,32
    80002ec0:	00008067          	ret

0000000080002ec4 <uartinit>:
    80002ec4:	ff010113          	addi	sp,sp,-16
    80002ec8:	00813423          	sd	s0,8(sp)
    80002ecc:	01010413          	addi	s0,sp,16
    80002ed0:	100007b7          	lui	a5,0x10000
    80002ed4:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>
    80002ed8:	f8000713          	li	a4,-128
    80002edc:	00e781a3          	sb	a4,3(a5)
    80002ee0:	00300713          	li	a4,3
    80002ee4:	00e78023          	sb	a4,0(a5)
    80002ee8:	000780a3          	sb	zero,1(a5)
    80002eec:	00e781a3          	sb	a4,3(a5)
    80002ef0:	00700693          	li	a3,7
    80002ef4:	00d78123          	sb	a3,2(a5)
    80002ef8:	00e780a3          	sb	a4,1(a5)
    80002efc:	00813403          	ld	s0,8(sp)
    80002f00:	01010113          	addi	sp,sp,16
    80002f04:	00008067          	ret

0000000080002f08 <uartputc>:
    80002f08:	00002797          	auipc	a5,0x2
    80002f0c:	8107a783          	lw	a5,-2032(a5) # 80004718 <panicked>
    80002f10:	00078463          	beqz	a5,80002f18 <uartputc+0x10>
    80002f14:	0000006f          	j	80002f14 <uartputc+0xc>
    80002f18:	fd010113          	addi	sp,sp,-48
    80002f1c:	02813023          	sd	s0,32(sp)
    80002f20:	00913c23          	sd	s1,24(sp)
    80002f24:	01213823          	sd	s2,16(sp)
    80002f28:	01313423          	sd	s3,8(sp)
    80002f2c:	02113423          	sd	ra,40(sp)
    80002f30:	03010413          	addi	s0,sp,48
    80002f34:	00001917          	auipc	s2,0x1
    80002f38:	7ec90913          	addi	s2,s2,2028 # 80004720 <uart_tx_r>
    80002f3c:	00093783          	ld	a5,0(s2)
    80002f40:	00001497          	auipc	s1,0x1
    80002f44:	7e848493          	addi	s1,s1,2024 # 80004728 <uart_tx_w>
    80002f48:	0004b703          	ld	a4,0(s1)
    80002f4c:	02078693          	addi	a3,a5,32
    80002f50:	00050993          	mv	s3,a0
    80002f54:	02e69c63          	bne	a3,a4,80002f8c <uartputc+0x84>
    80002f58:	00001097          	auipc	ra,0x1
    80002f5c:	834080e7          	jalr	-1996(ra) # 8000378c <push_on>
    80002f60:	00093783          	ld	a5,0(s2)
    80002f64:	0004b703          	ld	a4,0(s1)
    80002f68:	02078793          	addi	a5,a5,32
    80002f6c:	00e79463          	bne	a5,a4,80002f74 <uartputc+0x6c>
    80002f70:	0000006f          	j	80002f70 <uartputc+0x68>
    80002f74:	00001097          	auipc	ra,0x1
    80002f78:	88c080e7          	jalr	-1908(ra) # 80003800 <pop_on>
    80002f7c:	00093783          	ld	a5,0(s2)
    80002f80:	0004b703          	ld	a4,0(s1)
    80002f84:	02078693          	addi	a3,a5,32
    80002f88:	fce688e3          	beq	a3,a4,80002f58 <uartputc+0x50>
    80002f8c:	01f77693          	andi	a3,a4,31
    80002f90:	00003597          	auipc	a1,0x3
    80002f94:	9e058593          	addi	a1,a1,-1568 # 80005970 <uart_tx_buf>
    80002f98:	00d586b3          	add	a3,a1,a3
    80002f9c:	00170713          	addi	a4,a4,1
    80002fa0:	01368023          	sb	s3,0(a3)
    80002fa4:	00e4b023          	sd	a4,0(s1)
    80002fa8:	10000637          	lui	a2,0x10000
    80002fac:	02f71063          	bne	a4,a5,80002fcc <uartputc+0xc4>
    80002fb0:	0340006f          	j	80002fe4 <uartputc+0xdc>
    80002fb4:	00074703          	lbu	a4,0(a4)
    80002fb8:	00f93023          	sd	a5,0(s2)
    80002fbc:	00e60023          	sb	a4,0(a2) # 10000000 <_entry-0x70000000>
    80002fc0:	00093783          	ld	a5,0(s2)
    80002fc4:	0004b703          	ld	a4,0(s1)
    80002fc8:	00f70e63          	beq	a4,a5,80002fe4 <uartputc+0xdc>
    80002fcc:	00564683          	lbu	a3,5(a2)
    80002fd0:	01f7f713          	andi	a4,a5,31
    80002fd4:	00e58733          	add	a4,a1,a4
    80002fd8:	0206f693          	andi	a3,a3,32
    80002fdc:	00178793          	addi	a5,a5,1
    80002fe0:	fc069ae3          	bnez	a3,80002fb4 <uartputc+0xac>
    80002fe4:	02813083          	ld	ra,40(sp)
    80002fe8:	02013403          	ld	s0,32(sp)
    80002fec:	01813483          	ld	s1,24(sp)
    80002ff0:	01013903          	ld	s2,16(sp)
    80002ff4:	00813983          	ld	s3,8(sp)
    80002ff8:	03010113          	addi	sp,sp,48
    80002ffc:	00008067          	ret

0000000080003000 <uartputc_sync>:
    80003000:	ff010113          	addi	sp,sp,-16
    80003004:	00813423          	sd	s0,8(sp)
    80003008:	01010413          	addi	s0,sp,16
    8000300c:	00001717          	auipc	a4,0x1
    80003010:	70c72703          	lw	a4,1804(a4) # 80004718 <panicked>
    80003014:	02071663          	bnez	a4,80003040 <uartputc_sync+0x40>
    80003018:	00050793          	mv	a5,a0
    8000301c:	100006b7          	lui	a3,0x10000
    80003020:	0056c703          	lbu	a4,5(a3) # 10000005 <_entry-0x6ffffffb>
    80003024:	02077713          	andi	a4,a4,32
    80003028:	fe070ce3          	beqz	a4,80003020 <uartputc_sync+0x20>
    8000302c:	0ff7f793          	andi	a5,a5,255
    80003030:	00f68023          	sb	a5,0(a3)
    80003034:	00813403          	ld	s0,8(sp)
    80003038:	01010113          	addi	sp,sp,16
    8000303c:	00008067          	ret
    80003040:	0000006f          	j	80003040 <uartputc_sync+0x40>

0000000080003044 <uartstart>:
    80003044:	ff010113          	addi	sp,sp,-16
    80003048:	00813423          	sd	s0,8(sp)
    8000304c:	01010413          	addi	s0,sp,16
    80003050:	00001617          	auipc	a2,0x1
    80003054:	6d060613          	addi	a2,a2,1744 # 80004720 <uart_tx_r>
    80003058:	00001517          	auipc	a0,0x1
    8000305c:	6d050513          	addi	a0,a0,1744 # 80004728 <uart_tx_w>
    80003060:	00063783          	ld	a5,0(a2)
    80003064:	00053703          	ld	a4,0(a0)
    80003068:	04f70263          	beq	a4,a5,800030ac <uartstart+0x68>
    8000306c:	100005b7          	lui	a1,0x10000
    80003070:	00003817          	auipc	a6,0x3
    80003074:	90080813          	addi	a6,a6,-1792 # 80005970 <uart_tx_buf>
    80003078:	01c0006f          	j	80003094 <uartstart+0x50>
    8000307c:	0006c703          	lbu	a4,0(a3)
    80003080:	00f63023          	sd	a5,0(a2)
    80003084:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    80003088:	00063783          	ld	a5,0(a2)
    8000308c:	00053703          	ld	a4,0(a0)
    80003090:	00f70e63          	beq	a4,a5,800030ac <uartstart+0x68>
    80003094:	01f7f713          	andi	a4,a5,31
    80003098:	00e806b3          	add	a3,a6,a4
    8000309c:	0055c703          	lbu	a4,5(a1)
    800030a0:	00178793          	addi	a5,a5,1
    800030a4:	02077713          	andi	a4,a4,32
    800030a8:	fc071ae3          	bnez	a4,8000307c <uartstart+0x38>
    800030ac:	00813403          	ld	s0,8(sp)
    800030b0:	01010113          	addi	sp,sp,16
    800030b4:	00008067          	ret

00000000800030b8 <uartgetc>:
    800030b8:	ff010113          	addi	sp,sp,-16
    800030bc:	00813423          	sd	s0,8(sp)
    800030c0:	01010413          	addi	s0,sp,16
    800030c4:	10000737          	lui	a4,0x10000
    800030c8:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800030cc:	0017f793          	andi	a5,a5,1
    800030d0:	00078c63          	beqz	a5,800030e8 <uartgetc+0x30>
    800030d4:	00074503          	lbu	a0,0(a4)
    800030d8:	0ff57513          	andi	a0,a0,255
    800030dc:	00813403          	ld	s0,8(sp)
    800030e0:	01010113          	addi	sp,sp,16
    800030e4:	00008067          	ret
    800030e8:	fff00513          	li	a0,-1
    800030ec:	ff1ff06f          	j	800030dc <uartgetc+0x24>

00000000800030f0 <uartintr>:
    800030f0:	100007b7          	lui	a5,0x10000
    800030f4:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800030f8:	0017f793          	andi	a5,a5,1
    800030fc:	0a078463          	beqz	a5,800031a4 <uartintr+0xb4>
    80003100:	fe010113          	addi	sp,sp,-32
    80003104:	00813823          	sd	s0,16(sp)
    80003108:	00913423          	sd	s1,8(sp)
    8000310c:	00113c23          	sd	ra,24(sp)
    80003110:	02010413          	addi	s0,sp,32
    80003114:	100004b7          	lui	s1,0x10000
    80003118:	0004c503          	lbu	a0,0(s1) # 10000000 <_entry-0x70000000>
    8000311c:	0ff57513          	andi	a0,a0,255
    80003120:	fffff097          	auipc	ra,0xfffff
    80003124:	534080e7          	jalr	1332(ra) # 80002654 <consoleintr>
    80003128:	0054c783          	lbu	a5,5(s1)
    8000312c:	0017f793          	andi	a5,a5,1
    80003130:	fe0794e3          	bnez	a5,80003118 <uartintr+0x28>
    80003134:	00001617          	auipc	a2,0x1
    80003138:	5ec60613          	addi	a2,a2,1516 # 80004720 <uart_tx_r>
    8000313c:	00001517          	auipc	a0,0x1
    80003140:	5ec50513          	addi	a0,a0,1516 # 80004728 <uart_tx_w>
    80003144:	00063783          	ld	a5,0(a2)
    80003148:	00053703          	ld	a4,0(a0)
    8000314c:	04f70263          	beq	a4,a5,80003190 <uartintr+0xa0>
    80003150:	100005b7          	lui	a1,0x10000
    80003154:	00003817          	auipc	a6,0x3
    80003158:	81c80813          	addi	a6,a6,-2020 # 80005970 <uart_tx_buf>
    8000315c:	01c0006f          	j	80003178 <uartintr+0x88>
    80003160:	0006c703          	lbu	a4,0(a3)
    80003164:	00f63023          	sd	a5,0(a2)
    80003168:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    8000316c:	00063783          	ld	a5,0(a2)
    80003170:	00053703          	ld	a4,0(a0)
    80003174:	00f70e63          	beq	a4,a5,80003190 <uartintr+0xa0>
    80003178:	01f7f713          	andi	a4,a5,31
    8000317c:	00e806b3          	add	a3,a6,a4
    80003180:	0055c703          	lbu	a4,5(a1)
    80003184:	00178793          	addi	a5,a5,1
    80003188:	02077713          	andi	a4,a4,32
    8000318c:	fc071ae3          	bnez	a4,80003160 <uartintr+0x70>
    80003190:	01813083          	ld	ra,24(sp)
    80003194:	01013403          	ld	s0,16(sp)
    80003198:	00813483          	ld	s1,8(sp)
    8000319c:	02010113          	addi	sp,sp,32
    800031a0:	00008067          	ret
    800031a4:	00001617          	auipc	a2,0x1
    800031a8:	57c60613          	addi	a2,a2,1404 # 80004720 <uart_tx_r>
    800031ac:	00001517          	auipc	a0,0x1
    800031b0:	57c50513          	addi	a0,a0,1404 # 80004728 <uart_tx_w>
    800031b4:	00063783          	ld	a5,0(a2)
    800031b8:	00053703          	ld	a4,0(a0)
    800031bc:	04f70263          	beq	a4,a5,80003200 <uartintr+0x110>
    800031c0:	100005b7          	lui	a1,0x10000
    800031c4:	00002817          	auipc	a6,0x2
    800031c8:	7ac80813          	addi	a6,a6,1964 # 80005970 <uart_tx_buf>
    800031cc:	01c0006f          	j	800031e8 <uartintr+0xf8>
    800031d0:	0006c703          	lbu	a4,0(a3)
    800031d4:	00f63023          	sd	a5,0(a2)
    800031d8:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    800031dc:	00063783          	ld	a5,0(a2)
    800031e0:	00053703          	ld	a4,0(a0)
    800031e4:	02f70063          	beq	a4,a5,80003204 <uartintr+0x114>
    800031e8:	01f7f713          	andi	a4,a5,31
    800031ec:	00e806b3          	add	a3,a6,a4
    800031f0:	0055c703          	lbu	a4,5(a1)
    800031f4:	00178793          	addi	a5,a5,1
    800031f8:	02077713          	andi	a4,a4,32
    800031fc:	fc071ae3          	bnez	a4,800031d0 <uartintr+0xe0>
    80003200:	00008067          	ret
    80003204:	00008067          	ret

0000000080003208 <kinit>:
    80003208:	fc010113          	addi	sp,sp,-64
    8000320c:	02913423          	sd	s1,40(sp)
    80003210:	fffff7b7          	lui	a5,0xfffff
    80003214:	00003497          	auipc	s1,0x3
    80003218:	77b48493          	addi	s1,s1,1915 # 8000698f <end+0xfff>
    8000321c:	02813823          	sd	s0,48(sp)
    80003220:	01313c23          	sd	s3,24(sp)
    80003224:	00f4f4b3          	and	s1,s1,a5
    80003228:	02113c23          	sd	ra,56(sp)
    8000322c:	03213023          	sd	s2,32(sp)
    80003230:	01413823          	sd	s4,16(sp)
    80003234:	01513423          	sd	s5,8(sp)
    80003238:	04010413          	addi	s0,sp,64
    8000323c:	000017b7          	lui	a5,0x1
    80003240:	01100993          	li	s3,17
    80003244:	00f487b3          	add	a5,s1,a5
    80003248:	01b99993          	slli	s3,s3,0x1b
    8000324c:	06f9e063          	bltu	s3,a5,800032ac <kinit+0xa4>
    80003250:	00002a97          	auipc	s5,0x2
    80003254:	740a8a93          	addi	s5,s5,1856 # 80005990 <end>
    80003258:	0754ec63          	bltu	s1,s5,800032d0 <kinit+0xc8>
    8000325c:	0734fa63          	bgeu	s1,s3,800032d0 <kinit+0xc8>
    80003260:	00088a37          	lui	s4,0x88
    80003264:	fffa0a13          	addi	s4,s4,-1 # 87fff <_entry-0x7ff78001>
    80003268:	00001917          	auipc	s2,0x1
    8000326c:	4c890913          	addi	s2,s2,1224 # 80004730 <kmem>
    80003270:	00ca1a13          	slli	s4,s4,0xc
    80003274:	0140006f          	j	80003288 <kinit+0x80>
    80003278:	000017b7          	lui	a5,0x1
    8000327c:	00f484b3          	add	s1,s1,a5
    80003280:	0554e863          	bltu	s1,s5,800032d0 <kinit+0xc8>
    80003284:	0534f663          	bgeu	s1,s3,800032d0 <kinit+0xc8>
    80003288:	00001637          	lui	a2,0x1
    8000328c:	00100593          	li	a1,1
    80003290:	00048513          	mv	a0,s1
    80003294:	00000097          	auipc	ra,0x0
    80003298:	5e4080e7          	jalr	1508(ra) # 80003878 <__memset>
    8000329c:	00093783          	ld	a5,0(s2)
    800032a0:	00f4b023          	sd	a5,0(s1)
    800032a4:	00993023          	sd	s1,0(s2)
    800032a8:	fd4498e3          	bne	s1,s4,80003278 <kinit+0x70>
    800032ac:	03813083          	ld	ra,56(sp)
    800032b0:	03013403          	ld	s0,48(sp)
    800032b4:	02813483          	ld	s1,40(sp)
    800032b8:	02013903          	ld	s2,32(sp)
    800032bc:	01813983          	ld	s3,24(sp)
    800032c0:	01013a03          	ld	s4,16(sp)
    800032c4:	00813a83          	ld	s5,8(sp)
    800032c8:	04010113          	addi	sp,sp,64
    800032cc:	00008067          	ret
    800032d0:	00001517          	auipc	a0,0x1
    800032d4:	fb850513          	addi	a0,a0,-72 # 80004288 <digits+0x18>
    800032d8:	fffff097          	auipc	ra,0xfffff
    800032dc:	4b4080e7          	jalr	1204(ra) # 8000278c <panic>

00000000800032e0 <freerange>:
    800032e0:	fc010113          	addi	sp,sp,-64
    800032e4:	000017b7          	lui	a5,0x1
    800032e8:	02913423          	sd	s1,40(sp)
    800032ec:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    800032f0:	009504b3          	add	s1,a0,s1
    800032f4:	fffff537          	lui	a0,0xfffff
    800032f8:	02813823          	sd	s0,48(sp)
    800032fc:	02113c23          	sd	ra,56(sp)
    80003300:	03213023          	sd	s2,32(sp)
    80003304:	01313c23          	sd	s3,24(sp)
    80003308:	01413823          	sd	s4,16(sp)
    8000330c:	01513423          	sd	s5,8(sp)
    80003310:	01613023          	sd	s6,0(sp)
    80003314:	04010413          	addi	s0,sp,64
    80003318:	00a4f4b3          	and	s1,s1,a0
    8000331c:	00f487b3          	add	a5,s1,a5
    80003320:	06f5e463          	bltu	a1,a5,80003388 <freerange+0xa8>
    80003324:	00002a97          	auipc	s5,0x2
    80003328:	66ca8a93          	addi	s5,s5,1644 # 80005990 <end>
    8000332c:	0954e263          	bltu	s1,s5,800033b0 <freerange+0xd0>
    80003330:	01100993          	li	s3,17
    80003334:	01b99993          	slli	s3,s3,0x1b
    80003338:	0734fc63          	bgeu	s1,s3,800033b0 <freerange+0xd0>
    8000333c:	00058a13          	mv	s4,a1
    80003340:	00001917          	auipc	s2,0x1
    80003344:	3f090913          	addi	s2,s2,1008 # 80004730 <kmem>
    80003348:	00002b37          	lui	s6,0x2
    8000334c:	0140006f          	j	80003360 <freerange+0x80>
    80003350:	000017b7          	lui	a5,0x1
    80003354:	00f484b3          	add	s1,s1,a5
    80003358:	0554ec63          	bltu	s1,s5,800033b0 <freerange+0xd0>
    8000335c:	0534fa63          	bgeu	s1,s3,800033b0 <freerange+0xd0>
    80003360:	00001637          	lui	a2,0x1
    80003364:	00100593          	li	a1,1
    80003368:	00048513          	mv	a0,s1
    8000336c:	00000097          	auipc	ra,0x0
    80003370:	50c080e7          	jalr	1292(ra) # 80003878 <__memset>
    80003374:	00093703          	ld	a4,0(s2)
    80003378:	016487b3          	add	a5,s1,s6
    8000337c:	00e4b023          	sd	a4,0(s1)
    80003380:	00993023          	sd	s1,0(s2)
    80003384:	fcfa76e3          	bgeu	s4,a5,80003350 <freerange+0x70>
    80003388:	03813083          	ld	ra,56(sp)
    8000338c:	03013403          	ld	s0,48(sp)
    80003390:	02813483          	ld	s1,40(sp)
    80003394:	02013903          	ld	s2,32(sp)
    80003398:	01813983          	ld	s3,24(sp)
    8000339c:	01013a03          	ld	s4,16(sp)
    800033a0:	00813a83          	ld	s5,8(sp)
    800033a4:	00013b03          	ld	s6,0(sp)
    800033a8:	04010113          	addi	sp,sp,64
    800033ac:	00008067          	ret
    800033b0:	00001517          	auipc	a0,0x1
    800033b4:	ed850513          	addi	a0,a0,-296 # 80004288 <digits+0x18>
    800033b8:	fffff097          	auipc	ra,0xfffff
    800033bc:	3d4080e7          	jalr	980(ra) # 8000278c <panic>

00000000800033c0 <kfree>:
    800033c0:	fe010113          	addi	sp,sp,-32
    800033c4:	00813823          	sd	s0,16(sp)
    800033c8:	00113c23          	sd	ra,24(sp)
    800033cc:	00913423          	sd	s1,8(sp)
    800033d0:	02010413          	addi	s0,sp,32
    800033d4:	03451793          	slli	a5,a0,0x34
    800033d8:	04079c63          	bnez	a5,80003430 <kfree+0x70>
    800033dc:	00002797          	auipc	a5,0x2
    800033e0:	5b478793          	addi	a5,a5,1460 # 80005990 <end>
    800033e4:	00050493          	mv	s1,a0
    800033e8:	04f56463          	bltu	a0,a5,80003430 <kfree+0x70>
    800033ec:	01100793          	li	a5,17
    800033f0:	01b79793          	slli	a5,a5,0x1b
    800033f4:	02f57e63          	bgeu	a0,a5,80003430 <kfree+0x70>
    800033f8:	00001637          	lui	a2,0x1
    800033fc:	00100593          	li	a1,1
    80003400:	00000097          	auipc	ra,0x0
    80003404:	478080e7          	jalr	1144(ra) # 80003878 <__memset>
    80003408:	00001797          	auipc	a5,0x1
    8000340c:	32878793          	addi	a5,a5,808 # 80004730 <kmem>
    80003410:	0007b703          	ld	a4,0(a5)
    80003414:	01813083          	ld	ra,24(sp)
    80003418:	01013403          	ld	s0,16(sp)
    8000341c:	00e4b023          	sd	a4,0(s1)
    80003420:	0097b023          	sd	s1,0(a5)
    80003424:	00813483          	ld	s1,8(sp)
    80003428:	02010113          	addi	sp,sp,32
    8000342c:	00008067          	ret
    80003430:	00001517          	auipc	a0,0x1
    80003434:	e5850513          	addi	a0,a0,-424 # 80004288 <digits+0x18>
    80003438:	fffff097          	auipc	ra,0xfffff
    8000343c:	354080e7          	jalr	852(ra) # 8000278c <panic>

0000000080003440 <kalloc>:
    80003440:	fe010113          	addi	sp,sp,-32
    80003444:	00813823          	sd	s0,16(sp)
    80003448:	00913423          	sd	s1,8(sp)
    8000344c:	00113c23          	sd	ra,24(sp)
    80003450:	02010413          	addi	s0,sp,32
    80003454:	00001797          	auipc	a5,0x1
    80003458:	2dc78793          	addi	a5,a5,732 # 80004730 <kmem>
    8000345c:	0007b483          	ld	s1,0(a5)
    80003460:	02048063          	beqz	s1,80003480 <kalloc+0x40>
    80003464:	0004b703          	ld	a4,0(s1)
    80003468:	00001637          	lui	a2,0x1
    8000346c:	00500593          	li	a1,5
    80003470:	00048513          	mv	a0,s1
    80003474:	00e7b023          	sd	a4,0(a5)
    80003478:	00000097          	auipc	ra,0x0
    8000347c:	400080e7          	jalr	1024(ra) # 80003878 <__memset>
    80003480:	01813083          	ld	ra,24(sp)
    80003484:	01013403          	ld	s0,16(sp)
    80003488:	00048513          	mv	a0,s1
    8000348c:	00813483          	ld	s1,8(sp)
    80003490:	02010113          	addi	sp,sp,32
    80003494:	00008067          	ret

0000000080003498 <initlock>:
    80003498:	ff010113          	addi	sp,sp,-16
    8000349c:	00813423          	sd	s0,8(sp)
    800034a0:	01010413          	addi	s0,sp,16
    800034a4:	00813403          	ld	s0,8(sp)
    800034a8:	00b53423          	sd	a1,8(a0)
    800034ac:	00052023          	sw	zero,0(a0)
    800034b0:	00053823          	sd	zero,16(a0)
    800034b4:	01010113          	addi	sp,sp,16
    800034b8:	00008067          	ret

00000000800034bc <acquire>:
    800034bc:	fe010113          	addi	sp,sp,-32
    800034c0:	00813823          	sd	s0,16(sp)
    800034c4:	00913423          	sd	s1,8(sp)
    800034c8:	00113c23          	sd	ra,24(sp)
    800034cc:	01213023          	sd	s2,0(sp)
    800034d0:	02010413          	addi	s0,sp,32
    800034d4:	00050493          	mv	s1,a0
    800034d8:	10002973          	csrr	s2,sstatus
    800034dc:	100027f3          	csrr	a5,sstatus
    800034e0:	ffd7f793          	andi	a5,a5,-3
    800034e4:	10079073          	csrw	sstatus,a5
    800034e8:	fffff097          	auipc	ra,0xfffff
    800034ec:	8e0080e7          	jalr	-1824(ra) # 80001dc8 <mycpu>
    800034f0:	07852783          	lw	a5,120(a0)
    800034f4:	06078e63          	beqz	a5,80003570 <acquire+0xb4>
    800034f8:	fffff097          	auipc	ra,0xfffff
    800034fc:	8d0080e7          	jalr	-1840(ra) # 80001dc8 <mycpu>
    80003500:	07852783          	lw	a5,120(a0)
    80003504:	0004a703          	lw	a4,0(s1)
    80003508:	0017879b          	addiw	a5,a5,1
    8000350c:	06f52c23          	sw	a5,120(a0)
    80003510:	04071063          	bnez	a4,80003550 <acquire+0x94>
    80003514:	00100713          	li	a4,1
    80003518:	00070793          	mv	a5,a4
    8000351c:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80003520:	0007879b          	sext.w	a5,a5
    80003524:	fe079ae3          	bnez	a5,80003518 <acquire+0x5c>
    80003528:	0ff0000f          	fence
    8000352c:	fffff097          	auipc	ra,0xfffff
    80003530:	89c080e7          	jalr	-1892(ra) # 80001dc8 <mycpu>
    80003534:	01813083          	ld	ra,24(sp)
    80003538:	01013403          	ld	s0,16(sp)
    8000353c:	00a4b823          	sd	a0,16(s1)
    80003540:	00013903          	ld	s2,0(sp)
    80003544:	00813483          	ld	s1,8(sp)
    80003548:	02010113          	addi	sp,sp,32
    8000354c:	00008067          	ret
    80003550:	0104b903          	ld	s2,16(s1)
    80003554:	fffff097          	auipc	ra,0xfffff
    80003558:	874080e7          	jalr	-1932(ra) # 80001dc8 <mycpu>
    8000355c:	faa91ce3          	bne	s2,a0,80003514 <acquire+0x58>
    80003560:	00001517          	auipc	a0,0x1
    80003564:	d3050513          	addi	a0,a0,-720 # 80004290 <digits+0x20>
    80003568:	fffff097          	auipc	ra,0xfffff
    8000356c:	224080e7          	jalr	548(ra) # 8000278c <panic>
    80003570:	00195913          	srli	s2,s2,0x1
    80003574:	fffff097          	auipc	ra,0xfffff
    80003578:	854080e7          	jalr	-1964(ra) # 80001dc8 <mycpu>
    8000357c:	00197913          	andi	s2,s2,1
    80003580:	07252e23          	sw	s2,124(a0)
    80003584:	f75ff06f          	j	800034f8 <acquire+0x3c>

0000000080003588 <release>:
    80003588:	fe010113          	addi	sp,sp,-32
    8000358c:	00813823          	sd	s0,16(sp)
    80003590:	00113c23          	sd	ra,24(sp)
    80003594:	00913423          	sd	s1,8(sp)
    80003598:	01213023          	sd	s2,0(sp)
    8000359c:	02010413          	addi	s0,sp,32
    800035a0:	00052783          	lw	a5,0(a0)
    800035a4:	00079a63          	bnez	a5,800035b8 <release+0x30>
    800035a8:	00001517          	auipc	a0,0x1
    800035ac:	cf050513          	addi	a0,a0,-784 # 80004298 <digits+0x28>
    800035b0:	fffff097          	auipc	ra,0xfffff
    800035b4:	1dc080e7          	jalr	476(ra) # 8000278c <panic>
    800035b8:	01053903          	ld	s2,16(a0)
    800035bc:	00050493          	mv	s1,a0
    800035c0:	fffff097          	auipc	ra,0xfffff
    800035c4:	808080e7          	jalr	-2040(ra) # 80001dc8 <mycpu>
    800035c8:	fea910e3          	bne	s2,a0,800035a8 <release+0x20>
    800035cc:	0004b823          	sd	zero,16(s1)
    800035d0:	0ff0000f          	fence
    800035d4:	0f50000f          	fence	iorw,ow
    800035d8:	0804a02f          	amoswap.w	zero,zero,(s1)
    800035dc:	ffffe097          	auipc	ra,0xffffe
    800035e0:	7ec080e7          	jalr	2028(ra) # 80001dc8 <mycpu>
    800035e4:	100027f3          	csrr	a5,sstatus
    800035e8:	0027f793          	andi	a5,a5,2
    800035ec:	04079a63          	bnez	a5,80003640 <release+0xb8>
    800035f0:	07852783          	lw	a5,120(a0)
    800035f4:	02f05e63          	blez	a5,80003630 <release+0xa8>
    800035f8:	fff7871b          	addiw	a4,a5,-1
    800035fc:	06e52c23          	sw	a4,120(a0)
    80003600:	00071c63          	bnez	a4,80003618 <release+0x90>
    80003604:	07c52783          	lw	a5,124(a0)
    80003608:	00078863          	beqz	a5,80003618 <release+0x90>
    8000360c:	100027f3          	csrr	a5,sstatus
    80003610:	0027e793          	ori	a5,a5,2
    80003614:	10079073          	csrw	sstatus,a5
    80003618:	01813083          	ld	ra,24(sp)
    8000361c:	01013403          	ld	s0,16(sp)
    80003620:	00813483          	ld	s1,8(sp)
    80003624:	00013903          	ld	s2,0(sp)
    80003628:	02010113          	addi	sp,sp,32
    8000362c:	00008067          	ret
    80003630:	00001517          	auipc	a0,0x1
    80003634:	c8850513          	addi	a0,a0,-888 # 800042b8 <digits+0x48>
    80003638:	fffff097          	auipc	ra,0xfffff
    8000363c:	154080e7          	jalr	340(ra) # 8000278c <panic>
    80003640:	00001517          	auipc	a0,0x1
    80003644:	c6050513          	addi	a0,a0,-928 # 800042a0 <digits+0x30>
    80003648:	fffff097          	auipc	ra,0xfffff
    8000364c:	144080e7          	jalr	324(ra) # 8000278c <panic>

0000000080003650 <holding>:
    80003650:	00052783          	lw	a5,0(a0)
    80003654:	00079663          	bnez	a5,80003660 <holding+0x10>
    80003658:	00000513          	li	a0,0
    8000365c:	00008067          	ret
    80003660:	fe010113          	addi	sp,sp,-32
    80003664:	00813823          	sd	s0,16(sp)
    80003668:	00913423          	sd	s1,8(sp)
    8000366c:	00113c23          	sd	ra,24(sp)
    80003670:	02010413          	addi	s0,sp,32
    80003674:	01053483          	ld	s1,16(a0)
    80003678:	ffffe097          	auipc	ra,0xffffe
    8000367c:	750080e7          	jalr	1872(ra) # 80001dc8 <mycpu>
    80003680:	01813083          	ld	ra,24(sp)
    80003684:	01013403          	ld	s0,16(sp)
    80003688:	40a48533          	sub	a0,s1,a0
    8000368c:	00153513          	seqz	a0,a0
    80003690:	00813483          	ld	s1,8(sp)
    80003694:	02010113          	addi	sp,sp,32
    80003698:	00008067          	ret

000000008000369c <push_off>:
    8000369c:	fe010113          	addi	sp,sp,-32
    800036a0:	00813823          	sd	s0,16(sp)
    800036a4:	00113c23          	sd	ra,24(sp)
    800036a8:	00913423          	sd	s1,8(sp)
    800036ac:	02010413          	addi	s0,sp,32
    800036b0:	100024f3          	csrr	s1,sstatus
    800036b4:	100027f3          	csrr	a5,sstatus
    800036b8:	ffd7f793          	andi	a5,a5,-3
    800036bc:	10079073          	csrw	sstatus,a5
    800036c0:	ffffe097          	auipc	ra,0xffffe
    800036c4:	708080e7          	jalr	1800(ra) # 80001dc8 <mycpu>
    800036c8:	07852783          	lw	a5,120(a0)
    800036cc:	02078663          	beqz	a5,800036f8 <push_off+0x5c>
    800036d0:	ffffe097          	auipc	ra,0xffffe
    800036d4:	6f8080e7          	jalr	1784(ra) # 80001dc8 <mycpu>
    800036d8:	07852783          	lw	a5,120(a0)
    800036dc:	01813083          	ld	ra,24(sp)
    800036e0:	01013403          	ld	s0,16(sp)
    800036e4:	0017879b          	addiw	a5,a5,1
    800036e8:	06f52c23          	sw	a5,120(a0)
    800036ec:	00813483          	ld	s1,8(sp)
    800036f0:	02010113          	addi	sp,sp,32
    800036f4:	00008067          	ret
    800036f8:	0014d493          	srli	s1,s1,0x1
    800036fc:	ffffe097          	auipc	ra,0xffffe
    80003700:	6cc080e7          	jalr	1740(ra) # 80001dc8 <mycpu>
    80003704:	0014f493          	andi	s1,s1,1
    80003708:	06952e23          	sw	s1,124(a0)
    8000370c:	fc5ff06f          	j	800036d0 <push_off+0x34>

0000000080003710 <pop_off>:
    80003710:	ff010113          	addi	sp,sp,-16
    80003714:	00813023          	sd	s0,0(sp)
    80003718:	00113423          	sd	ra,8(sp)
    8000371c:	01010413          	addi	s0,sp,16
    80003720:	ffffe097          	auipc	ra,0xffffe
    80003724:	6a8080e7          	jalr	1704(ra) # 80001dc8 <mycpu>
    80003728:	100027f3          	csrr	a5,sstatus
    8000372c:	0027f793          	andi	a5,a5,2
    80003730:	04079663          	bnez	a5,8000377c <pop_off+0x6c>
    80003734:	07852783          	lw	a5,120(a0)
    80003738:	02f05a63          	blez	a5,8000376c <pop_off+0x5c>
    8000373c:	fff7871b          	addiw	a4,a5,-1
    80003740:	06e52c23          	sw	a4,120(a0)
    80003744:	00071c63          	bnez	a4,8000375c <pop_off+0x4c>
    80003748:	07c52783          	lw	a5,124(a0)
    8000374c:	00078863          	beqz	a5,8000375c <pop_off+0x4c>
    80003750:	100027f3          	csrr	a5,sstatus
    80003754:	0027e793          	ori	a5,a5,2
    80003758:	10079073          	csrw	sstatus,a5
    8000375c:	00813083          	ld	ra,8(sp)
    80003760:	00013403          	ld	s0,0(sp)
    80003764:	01010113          	addi	sp,sp,16
    80003768:	00008067          	ret
    8000376c:	00001517          	auipc	a0,0x1
    80003770:	b4c50513          	addi	a0,a0,-1204 # 800042b8 <digits+0x48>
    80003774:	fffff097          	auipc	ra,0xfffff
    80003778:	018080e7          	jalr	24(ra) # 8000278c <panic>
    8000377c:	00001517          	auipc	a0,0x1
    80003780:	b2450513          	addi	a0,a0,-1244 # 800042a0 <digits+0x30>
    80003784:	fffff097          	auipc	ra,0xfffff
    80003788:	008080e7          	jalr	8(ra) # 8000278c <panic>

000000008000378c <push_on>:
    8000378c:	fe010113          	addi	sp,sp,-32
    80003790:	00813823          	sd	s0,16(sp)
    80003794:	00113c23          	sd	ra,24(sp)
    80003798:	00913423          	sd	s1,8(sp)
    8000379c:	02010413          	addi	s0,sp,32
    800037a0:	100024f3          	csrr	s1,sstatus
    800037a4:	100027f3          	csrr	a5,sstatus
    800037a8:	0027e793          	ori	a5,a5,2
    800037ac:	10079073          	csrw	sstatus,a5
    800037b0:	ffffe097          	auipc	ra,0xffffe
    800037b4:	618080e7          	jalr	1560(ra) # 80001dc8 <mycpu>
    800037b8:	07852783          	lw	a5,120(a0)
    800037bc:	02078663          	beqz	a5,800037e8 <push_on+0x5c>
    800037c0:	ffffe097          	auipc	ra,0xffffe
    800037c4:	608080e7          	jalr	1544(ra) # 80001dc8 <mycpu>
    800037c8:	07852783          	lw	a5,120(a0)
    800037cc:	01813083          	ld	ra,24(sp)
    800037d0:	01013403          	ld	s0,16(sp)
    800037d4:	0017879b          	addiw	a5,a5,1
    800037d8:	06f52c23          	sw	a5,120(a0)
    800037dc:	00813483          	ld	s1,8(sp)
    800037e0:	02010113          	addi	sp,sp,32
    800037e4:	00008067          	ret
    800037e8:	0014d493          	srli	s1,s1,0x1
    800037ec:	ffffe097          	auipc	ra,0xffffe
    800037f0:	5dc080e7          	jalr	1500(ra) # 80001dc8 <mycpu>
    800037f4:	0014f493          	andi	s1,s1,1
    800037f8:	06952e23          	sw	s1,124(a0)
    800037fc:	fc5ff06f          	j	800037c0 <push_on+0x34>

0000000080003800 <pop_on>:
    80003800:	ff010113          	addi	sp,sp,-16
    80003804:	00813023          	sd	s0,0(sp)
    80003808:	00113423          	sd	ra,8(sp)
    8000380c:	01010413          	addi	s0,sp,16
    80003810:	ffffe097          	auipc	ra,0xffffe
    80003814:	5b8080e7          	jalr	1464(ra) # 80001dc8 <mycpu>
    80003818:	100027f3          	csrr	a5,sstatus
    8000381c:	0027f793          	andi	a5,a5,2
    80003820:	04078463          	beqz	a5,80003868 <pop_on+0x68>
    80003824:	07852783          	lw	a5,120(a0)
    80003828:	02f05863          	blez	a5,80003858 <pop_on+0x58>
    8000382c:	fff7879b          	addiw	a5,a5,-1
    80003830:	06f52c23          	sw	a5,120(a0)
    80003834:	07853783          	ld	a5,120(a0)
    80003838:	00079863          	bnez	a5,80003848 <pop_on+0x48>
    8000383c:	100027f3          	csrr	a5,sstatus
    80003840:	ffd7f793          	andi	a5,a5,-3
    80003844:	10079073          	csrw	sstatus,a5
    80003848:	00813083          	ld	ra,8(sp)
    8000384c:	00013403          	ld	s0,0(sp)
    80003850:	01010113          	addi	sp,sp,16
    80003854:	00008067          	ret
    80003858:	00001517          	auipc	a0,0x1
    8000385c:	a8850513          	addi	a0,a0,-1400 # 800042e0 <digits+0x70>
    80003860:	fffff097          	auipc	ra,0xfffff
    80003864:	f2c080e7          	jalr	-212(ra) # 8000278c <panic>
    80003868:	00001517          	auipc	a0,0x1
    8000386c:	a5850513          	addi	a0,a0,-1448 # 800042c0 <digits+0x50>
    80003870:	fffff097          	auipc	ra,0xfffff
    80003874:	f1c080e7          	jalr	-228(ra) # 8000278c <panic>

0000000080003878 <__memset>:
    80003878:	ff010113          	addi	sp,sp,-16
    8000387c:	00813423          	sd	s0,8(sp)
    80003880:	01010413          	addi	s0,sp,16
    80003884:	1a060e63          	beqz	a2,80003a40 <__memset+0x1c8>
    80003888:	40a007b3          	neg	a5,a0
    8000388c:	0077f793          	andi	a5,a5,7
    80003890:	00778693          	addi	a3,a5,7
    80003894:	00b00813          	li	a6,11
    80003898:	0ff5f593          	andi	a1,a1,255
    8000389c:	fff6071b          	addiw	a4,a2,-1
    800038a0:	1b06e663          	bltu	a3,a6,80003a4c <__memset+0x1d4>
    800038a4:	1cd76463          	bltu	a4,a3,80003a6c <__memset+0x1f4>
    800038a8:	1a078e63          	beqz	a5,80003a64 <__memset+0x1ec>
    800038ac:	00b50023          	sb	a1,0(a0)
    800038b0:	00100713          	li	a4,1
    800038b4:	1ae78463          	beq	a5,a4,80003a5c <__memset+0x1e4>
    800038b8:	00b500a3          	sb	a1,1(a0)
    800038bc:	00200713          	li	a4,2
    800038c0:	1ae78a63          	beq	a5,a4,80003a74 <__memset+0x1fc>
    800038c4:	00b50123          	sb	a1,2(a0)
    800038c8:	00300713          	li	a4,3
    800038cc:	18e78463          	beq	a5,a4,80003a54 <__memset+0x1dc>
    800038d0:	00b501a3          	sb	a1,3(a0)
    800038d4:	00400713          	li	a4,4
    800038d8:	1ae78263          	beq	a5,a4,80003a7c <__memset+0x204>
    800038dc:	00b50223          	sb	a1,4(a0)
    800038e0:	00500713          	li	a4,5
    800038e4:	1ae78063          	beq	a5,a4,80003a84 <__memset+0x20c>
    800038e8:	00b502a3          	sb	a1,5(a0)
    800038ec:	00700713          	li	a4,7
    800038f0:	18e79e63          	bne	a5,a4,80003a8c <__memset+0x214>
    800038f4:	00b50323          	sb	a1,6(a0)
    800038f8:	00700e93          	li	t4,7
    800038fc:	00859713          	slli	a4,a1,0x8
    80003900:	00e5e733          	or	a4,a1,a4
    80003904:	01059e13          	slli	t3,a1,0x10
    80003908:	01c76e33          	or	t3,a4,t3
    8000390c:	01859313          	slli	t1,a1,0x18
    80003910:	006e6333          	or	t1,t3,t1
    80003914:	02059893          	slli	a7,a1,0x20
    80003918:	40f60e3b          	subw	t3,a2,a5
    8000391c:	011368b3          	or	a7,t1,a7
    80003920:	02859813          	slli	a6,a1,0x28
    80003924:	0108e833          	or	a6,a7,a6
    80003928:	03059693          	slli	a3,a1,0x30
    8000392c:	003e589b          	srliw	a7,t3,0x3
    80003930:	00d866b3          	or	a3,a6,a3
    80003934:	03859713          	slli	a4,a1,0x38
    80003938:	00389813          	slli	a6,a7,0x3
    8000393c:	00f507b3          	add	a5,a0,a5
    80003940:	00e6e733          	or	a4,a3,a4
    80003944:	000e089b          	sext.w	a7,t3
    80003948:	00f806b3          	add	a3,a6,a5
    8000394c:	00e7b023          	sd	a4,0(a5)
    80003950:	00878793          	addi	a5,a5,8
    80003954:	fed79ce3          	bne	a5,a3,8000394c <__memset+0xd4>
    80003958:	ff8e7793          	andi	a5,t3,-8
    8000395c:	0007871b          	sext.w	a4,a5
    80003960:	01d787bb          	addw	a5,a5,t4
    80003964:	0ce88e63          	beq	a7,a4,80003a40 <__memset+0x1c8>
    80003968:	00f50733          	add	a4,a0,a5
    8000396c:	00b70023          	sb	a1,0(a4)
    80003970:	0017871b          	addiw	a4,a5,1
    80003974:	0cc77663          	bgeu	a4,a2,80003a40 <__memset+0x1c8>
    80003978:	00e50733          	add	a4,a0,a4
    8000397c:	00b70023          	sb	a1,0(a4)
    80003980:	0027871b          	addiw	a4,a5,2
    80003984:	0ac77e63          	bgeu	a4,a2,80003a40 <__memset+0x1c8>
    80003988:	00e50733          	add	a4,a0,a4
    8000398c:	00b70023          	sb	a1,0(a4)
    80003990:	0037871b          	addiw	a4,a5,3
    80003994:	0ac77663          	bgeu	a4,a2,80003a40 <__memset+0x1c8>
    80003998:	00e50733          	add	a4,a0,a4
    8000399c:	00b70023          	sb	a1,0(a4)
    800039a0:	0047871b          	addiw	a4,a5,4
    800039a4:	08c77e63          	bgeu	a4,a2,80003a40 <__memset+0x1c8>
    800039a8:	00e50733          	add	a4,a0,a4
    800039ac:	00b70023          	sb	a1,0(a4)
    800039b0:	0057871b          	addiw	a4,a5,5
    800039b4:	08c77663          	bgeu	a4,a2,80003a40 <__memset+0x1c8>
    800039b8:	00e50733          	add	a4,a0,a4
    800039bc:	00b70023          	sb	a1,0(a4)
    800039c0:	0067871b          	addiw	a4,a5,6
    800039c4:	06c77e63          	bgeu	a4,a2,80003a40 <__memset+0x1c8>
    800039c8:	00e50733          	add	a4,a0,a4
    800039cc:	00b70023          	sb	a1,0(a4)
    800039d0:	0077871b          	addiw	a4,a5,7
    800039d4:	06c77663          	bgeu	a4,a2,80003a40 <__memset+0x1c8>
    800039d8:	00e50733          	add	a4,a0,a4
    800039dc:	00b70023          	sb	a1,0(a4)
    800039e0:	0087871b          	addiw	a4,a5,8
    800039e4:	04c77e63          	bgeu	a4,a2,80003a40 <__memset+0x1c8>
    800039e8:	00e50733          	add	a4,a0,a4
    800039ec:	00b70023          	sb	a1,0(a4)
    800039f0:	0097871b          	addiw	a4,a5,9
    800039f4:	04c77663          	bgeu	a4,a2,80003a40 <__memset+0x1c8>
    800039f8:	00e50733          	add	a4,a0,a4
    800039fc:	00b70023          	sb	a1,0(a4)
    80003a00:	00a7871b          	addiw	a4,a5,10
    80003a04:	02c77e63          	bgeu	a4,a2,80003a40 <__memset+0x1c8>
    80003a08:	00e50733          	add	a4,a0,a4
    80003a0c:	00b70023          	sb	a1,0(a4)
    80003a10:	00b7871b          	addiw	a4,a5,11
    80003a14:	02c77663          	bgeu	a4,a2,80003a40 <__memset+0x1c8>
    80003a18:	00e50733          	add	a4,a0,a4
    80003a1c:	00b70023          	sb	a1,0(a4)
    80003a20:	00c7871b          	addiw	a4,a5,12
    80003a24:	00c77e63          	bgeu	a4,a2,80003a40 <__memset+0x1c8>
    80003a28:	00e50733          	add	a4,a0,a4
    80003a2c:	00b70023          	sb	a1,0(a4)
    80003a30:	00d7879b          	addiw	a5,a5,13
    80003a34:	00c7f663          	bgeu	a5,a2,80003a40 <__memset+0x1c8>
    80003a38:	00f507b3          	add	a5,a0,a5
    80003a3c:	00b78023          	sb	a1,0(a5)
    80003a40:	00813403          	ld	s0,8(sp)
    80003a44:	01010113          	addi	sp,sp,16
    80003a48:	00008067          	ret
    80003a4c:	00b00693          	li	a3,11
    80003a50:	e55ff06f          	j	800038a4 <__memset+0x2c>
    80003a54:	00300e93          	li	t4,3
    80003a58:	ea5ff06f          	j	800038fc <__memset+0x84>
    80003a5c:	00100e93          	li	t4,1
    80003a60:	e9dff06f          	j	800038fc <__memset+0x84>
    80003a64:	00000e93          	li	t4,0
    80003a68:	e95ff06f          	j	800038fc <__memset+0x84>
    80003a6c:	00000793          	li	a5,0
    80003a70:	ef9ff06f          	j	80003968 <__memset+0xf0>
    80003a74:	00200e93          	li	t4,2
    80003a78:	e85ff06f          	j	800038fc <__memset+0x84>
    80003a7c:	00400e93          	li	t4,4
    80003a80:	e7dff06f          	j	800038fc <__memset+0x84>
    80003a84:	00500e93          	li	t4,5
    80003a88:	e75ff06f          	j	800038fc <__memset+0x84>
    80003a8c:	00600e93          	li	t4,6
    80003a90:	e6dff06f          	j	800038fc <__memset+0x84>

0000000080003a94 <__memmove>:
    80003a94:	ff010113          	addi	sp,sp,-16
    80003a98:	00813423          	sd	s0,8(sp)
    80003a9c:	01010413          	addi	s0,sp,16
    80003aa0:	0e060863          	beqz	a2,80003b90 <__memmove+0xfc>
    80003aa4:	fff6069b          	addiw	a3,a2,-1
    80003aa8:	0006881b          	sext.w	a6,a3
    80003aac:	0ea5e863          	bltu	a1,a0,80003b9c <__memmove+0x108>
    80003ab0:	00758713          	addi	a4,a1,7
    80003ab4:	00a5e7b3          	or	a5,a1,a0
    80003ab8:	40a70733          	sub	a4,a4,a0
    80003abc:	0077f793          	andi	a5,a5,7
    80003ac0:	00f73713          	sltiu	a4,a4,15
    80003ac4:	00174713          	xori	a4,a4,1
    80003ac8:	0017b793          	seqz	a5,a5
    80003acc:	00e7f7b3          	and	a5,a5,a4
    80003ad0:	10078863          	beqz	a5,80003be0 <__memmove+0x14c>
    80003ad4:	00900793          	li	a5,9
    80003ad8:	1107f463          	bgeu	a5,a6,80003be0 <__memmove+0x14c>
    80003adc:	0036581b          	srliw	a6,a2,0x3
    80003ae0:	fff8081b          	addiw	a6,a6,-1
    80003ae4:	02081813          	slli	a6,a6,0x20
    80003ae8:	01d85893          	srli	a7,a6,0x1d
    80003aec:	00858813          	addi	a6,a1,8
    80003af0:	00058793          	mv	a5,a1
    80003af4:	00050713          	mv	a4,a0
    80003af8:	01088833          	add	a6,a7,a6
    80003afc:	0007b883          	ld	a7,0(a5)
    80003b00:	00878793          	addi	a5,a5,8
    80003b04:	00870713          	addi	a4,a4,8
    80003b08:	ff173c23          	sd	a7,-8(a4)
    80003b0c:	ff0798e3          	bne	a5,a6,80003afc <__memmove+0x68>
    80003b10:	ff867713          	andi	a4,a2,-8
    80003b14:	02071793          	slli	a5,a4,0x20
    80003b18:	0207d793          	srli	a5,a5,0x20
    80003b1c:	00f585b3          	add	a1,a1,a5
    80003b20:	40e686bb          	subw	a3,a3,a4
    80003b24:	00f507b3          	add	a5,a0,a5
    80003b28:	06e60463          	beq	a2,a4,80003b90 <__memmove+0xfc>
    80003b2c:	0005c703          	lbu	a4,0(a1)
    80003b30:	00e78023          	sb	a4,0(a5)
    80003b34:	04068e63          	beqz	a3,80003b90 <__memmove+0xfc>
    80003b38:	0015c603          	lbu	a2,1(a1)
    80003b3c:	00100713          	li	a4,1
    80003b40:	00c780a3          	sb	a2,1(a5)
    80003b44:	04e68663          	beq	a3,a4,80003b90 <__memmove+0xfc>
    80003b48:	0025c603          	lbu	a2,2(a1)
    80003b4c:	00200713          	li	a4,2
    80003b50:	00c78123          	sb	a2,2(a5)
    80003b54:	02e68e63          	beq	a3,a4,80003b90 <__memmove+0xfc>
    80003b58:	0035c603          	lbu	a2,3(a1)
    80003b5c:	00300713          	li	a4,3
    80003b60:	00c781a3          	sb	a2,3(a5)
    80003b64:	02e68663          	beq	a3,a4,80003b90 <__memmove+0xfc>
    80003b68:	0045c603          	lbu	a2,4(a1)
    80003b6c:	00400713          	li	a4,4
    80003b70:	00c78223          	sb	a2,4(a5)
    80003b74:	00e68e63          	beq	a3,a4,80003b90 <__memmove+0xfc>
    80003b78:	0055c603          	lbu	a2,5(a1)
    80003b7c:	00500713          	li	a4,5
    80003b80:	00c782a3          	sb	a2,5(a5)
    80003b84:	00e68663          	beq	a3,a4,80003b90 <__memmove+0xfc>
    80003b88:	0065c703          	lbu	a4,6(a1)
    80003b8c:	00e78323          	sb	a4,6(a5)
    80003b90:	00813403          	ld	s0,8(sp)
    80003b94:	01010113          	addi	sp,sp,16
    80003b98:	00008067          	ret
    80003b9c:	02061713          	slli	a4,a2,0x20
    80003ba0:	02075713          	srli	a4,a4,0x20
    80003ba4:	00e587b3          	add	a5,a1,a4
    80003ba8:	f0f574e3          	bgeu	a0,a5,80003ab0 <__memmove+0x1c>
    80003bac:	02069613          	slli	a2,a3,0x20
    80003bb0:	02065613          	srli	a2,a2,0x20
    80003bb4:	fff64613          	not	a2,a2
    80003bb8:	00e50733          	add	a4,a0,a4
    80003bbc:	00c78633          	add	a2,a5,a2
    80003bc0:	fff7c683          	lbu	a3,-1(a5)
    80003bc4:	fff78793          	addi	a5,a5,-1
    80003bc8:	fff70713          	addi	a4,a4,-1
    80003bcc:	00d70023          	sb	a3,0(a4)
    80003bd0:	fec798e3          	bne	a5,a2,80003bc0 <__memmove+0x12c>
    80003bd4:	00813403          	ld	s0,8(sp)
    80003bd8:	01010113          	addi	sp,sp,16
    80003bdc:	00008067          	ret
    80003be0:	02069713          	slli	a4,a3,0x20
    80003be4:	02075713          	srli	a4,a4,0x20
    80003be8:	00170713          	addi	a4,a4,1
    80003bec:	00e50733          	add	a4,a0,a4
    80003bf0:	00050793          	mv	a5,a0
    80003bf4:	0005c683          	lbu	a3,0(a1)
    80003bf8:	00178793          	addi	a5,a5,1
    80003bfc:	00158593          	addi	a1,a1,1
    80003c00:	fed78fa3          	sb	a3,-1(a5)
    80003c04:	fee798e3          	bne	a5,a4,80003bf4 <__memmove+0x160>
    80003c08:	f89ff06f          	j	80003b90 <__memmove+0xfc>
	...
