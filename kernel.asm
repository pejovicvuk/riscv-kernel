
kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00004117          	auipc	sp,0x4
    80000004:	62813103          	ld	sp,1576(sp) # 80004628 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	00001537          	lui	a0,0x1
    8000000c:	f14025f3          	csrr	a1,mhartid
    80000010:	00158593          	addi	a1,a1,1
    80000014:	02b50533          	mul	a0,a0,a1
    80000018:	00a10133          	add	sp,sp,a0
    8000001c:	1dd010ef          	jal	ra,800019f8 <start>

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
    80001040:	1a4000ef          	jal	ra,800011e4 <handleTrap>

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

00000000800010c4 <_Z8mem_freePv>:

int mem_free(void* ptr) {
    800010c4:	ff010113          	addi	sp,sp,-16
    800010c8:	00813423          	sd	s0,8(sp)
    800010cc:	01010413          	addi	s0,sp,16
    800010d0:	00050593          	mv	a1,a0
    // abi poziv 0x02: a1 = pokazivac dobijen iz mem_alloc
    register uint64 code asm("a0") = 0x02;
    800010d4:	00200513          	li	a0,2
    register uint64 p    asm("a1") = (uint64)ptr;
    asm volatile("ecall"
        : "=r"(code)
        : "r"(code), "r"(p)
        : "memory");
    800010d8:	00000073          	ecall

    return (int)code;   // 0 = uspeh, negativno = greska
}
    800010dc:	0005051b          	sext.w	a0,a0
    800010e0:	00813403          	ld	s0,8(sp)
    800010e4:	01010113          	addi	sp,sp,16
    800010e8:	00008067          	ret

00000000800010ec <_Z5kputcc>:
#include "../h/print.hpp"

// posalji jedan znak kontroleru konzole (polling)
void kputc(char c) {
    800010ec:	ff010113          	addi	sp,sp,-16
    800010f0:	00813423          	sd	s0,8(sp)
    800010f4:	01010413          	addi	s0,sp,16
    // CONSOLE_STATUS je adresa (konstanta iz hw.h); da procitamo bajt sa te
    // adrese, kastujemo broj u pokazivac na volatile char pa dereferenciramo.
    // volatile: vrednost menja hardver, kompajler mora stvarno da cita
    // memoriju u svakom prolazu petlje, ne sme da kesira
    while ((*(volatile char*)CONSOLE_STATUS & (1 << 5)) == 0) {
    800010f8:	00003797          	auipc	a5,0x3
    800010fc:	f187b783          	ld	a5,-232(a5) # 80004010 <CONSOLE_STATUS>
    80001100:	0007c783          	lbu	a5,0(a5)
    80001104:	0ff7f793          	andi	a5,a5,255
    80001108:	0207f793          	andi	a5,a5,32
    8000110c:	fe0786e3          	beqz	a5,800010f8 <_Z5kputcc+0xc>
        // bit 5 == 0 znaci "nisam spreman da primim znak za slanje"
    }
    // spreman: upisi bajt u registar za slanje
    *(volatile char*)CONSOLE_TX_DATA = c;
    80001110:	00003797          	auipc	a5,0x3
    80001114:	ef87b783          	ld	a5,-264(a5) # 80004008 <CONSOLE_TX_DATA>
    80001118:	00a78023          	sb	a0,0(a5)
}
    8000111c:	00813403          	ld	s0,8(sp)
    80001120:	01010113          	addi	sp,sp,16
    80001124:	00008067          	ret

0000000080001128 <_Z5kputsPKc>:

// ispisi ceo string, znak po znak
void kputs(const char* s) {
    80001128:	fe010113          	addi	sp,sp,-32
    8000112c:	00113c23          	sd	ra,24(sp)
    80001130:	00813823          	sd	s0,16(sp)
    80001134:	00913423          	sd	s1,8(sp)
    80001138:	02010413          	addi	s0,sp,32
    8000113c:	00050493          	mv	s1,a0
    while (*s) kputc(*s++);
    80001140:	0004c503          	lbu	a0,0(s1)
    80001144:	00050a63          	beqz	a0,80001158 <_Z5kputsPKc+0x30>
    80001148:	00148493          	addi	s1,s1,1
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	fa0080e7          	jalr	-96(ra) # 800010ec <_Z5kputcc>
    80001154:	fedff06f          	j	80001140 <_Z5kputsPKc+0x18>
}
    80001158:	01813083          	ld	ra,24(sp)
    8000115c:	01013403          	ld	s0,16(sp)
    80001160:	00813483          	ld	s1,8(sp)
    80001164:	02010113          	addi	sp,sp,32
    80001168:	00008067          	ret

000000008000116c <_Z7kputhexm>:

// ispisi 64-bitni broj heksadecimalno (fiksno 16 cifara)
void kputhex(uint64 n) {
    8000116c:	fe010113          	addi	sp,sp,-32
    80001170:	00113c23          	sd	ra,24(sp)
    80001174:	00813823          	sd	s0,16(sp)
    80001178:	00913423          	sd	s1,8(sp)
    8000117c:	01213023          	sd	s2,0(sp)
    80001180:	02010413          	addi	s0,sp,32
    80001184:	00050913          	mv	s2,a0
    kputs("0x");
    80001188:	00003517          	auipc	a0,0x3
    8000118c:	e9850513          	addi	a0,a0,-360 # 80004020 <CONSOLE_STATUS+0x10>
    80001190:	00000097          	auipc	ra,0x0
    80001194:	f98080e7          	jalr	-104(ra) # 80001128 <_Z5kputsPKc>
    for (int shift = 60; shift >= 0; shift -= 4) {
    80001198:	03c00493          	li	s1,60
    8000119c:	0140006f          	j	800011b0 <_Z7kputhexm+0x44>
        uint64 digit = (n >> shift) & 0xF;
        char c;
        if (digit < 10) {
            c = '0' + digit;
        } else {
            c = 'a' + (digit - 10);
    800011a0:	05750513          	addi	a0,a0,87
        }
        kputc(c);
    800011a4:	00000097          	auipc	ra,0x0
    800011a8:	f48080e7          	jalr	-184(ra) # 800010ec <_Z5kputcc>
    for (int shift = 60; shift >= 0; shift -= 4) {
    800011ac:	ffc4849b          	addiw	s1,s1,-4
    800011b0:	0004ce63          	bltz	s1,800011cc <_Z7kputhexm+0x60>
        uint64 digit = (n >> shift) & 0xF;
    800011b4:	00995533          	srl	a0,s2,s1
    800011b8:	00f57513          	andi	a0,a0,15
        if (digit < 10) {
    800011bc:	00900793          	li	a5,9
    800011c0:	fea7e0e3          	bltu	a5,a0,800011a0 <_Z7kputhexm+0x34>
            c = '0' + digit;
    800011c4:	03050513          	addi	a0,a0,48
    800011c8:	fddff06f          	j	800011a4 <_Z7kputhexm+0x38>
    }
}
    800011cc:	01813083          	ld	ra,24(sp)
    800011d0:	01013403          	ld	s0,16(sp)
    800011d4:	00813483          	ld	s1,8(sp)
    800011d8:	00013903          	ld	s2,0(sp)
    800011dc:	02010113          	addi	sp,sp,32
    800011e0:	00008067          	ret

00000000800011e4 <handleTrap>:
#include "../h/memoryAllocator.hpp"

// zajednicki c deo prekidne rutine: cita scause i grana se na obradu.
// a0..a3 parametri se poklapaju sa registrima a0..a3 u trenutku trapa
// (trap.S ih ne dira pre call-a), pa abi argumente citamo direktno.
extern "C" uint64 handleTrap(uint64 a0, uint64 a1, uint64 a2, uint64 a3) {
    800011e4:	fd010113          	addi	sp,sp,-48
    800011e8:	02113423          	sd	ra,40(sp)
    800011ec:	02813023          	sd	s0,32(sp)
    800011f0:	00913c23          	sd	s1,24(sp)
    800011f4:	01213823          	sd	s2,16(sp)
    800011f8:	01313423          	sd	s3,8(sp)
    800011fc:	03010413          	addi	s0,sp,48
    80001200:	00050493          	mv	s1,a0
    uint64 cause;
    asm volatile("csrr %0, scause" : "=r"(cause));
    80001204:	14202973          	csrr	s2,scause

    uint64 topBit = cause >> 63;
    80001208:	03f95513          	srli	a0,s2,0x3f
    uint64 code   = cause & 0xff;
    8000120c:	0ff97793          	andi	a5,s2,255

    if (topBit == 1) {
    80001210:	08051863          	bnez	a0,800012a0 <handleTrap+0xbc>
            plic_complete(irq);
        }
        // sepc se ne dira: prekinuta instrukcija mora da se ponovi
        return a0;
    }
    else if (topBit == 0 && (code == 8 || code == 9)) {
    80001214:	00051863          	bnez	a0,80001224 <handleTrap+0x40>
    80001218:	ff878793          	addi	a5,a5,-8
    8000121c:	00100713          	li	a4,1
    80001220:	0af77e63          	bgeu	a4,a5,800012dc <handleTrap+0xf8>
    }

    // nepoznat uzrok (izuzetak koji ne umemo da obradimo): panika.
    // ne vracamo se - sepc bi pokazivao na istu instrukciju i vrteli bismo se.
    uint64 sepc;
    asm volatile("csrr %0, sepc" : "=r"(sepc));
    80001224:	141029f3          	csrr	s3,sepc
    kputs("PANIC: cause="); kputhex(cause);
    80001228:	00003517          	auipc	a0,0x3
    8000122c:	e0050513          	addi	a0,a0,-512 # 80004028 <CONSOLE_STATUS+0x18>
    80001230:	00000097          	auipc	ra,0x0
    80001234:	ef8080e7          	jalr	-264(ra) # 80001128 <_Z5kputsPKc>
    80001238:	00090513          	mv	a0,s2
    8000123c:	00000097          	auipc	ra,0x0
    80001240:	f30080e7          	jalr	-208(ra) # 8000116c <_Z7kputhexm>
    kputs(" sepc=");        kputhex(sepc);
    80001244:	00003517          	auipc	a0,0x3
    80001248:	df450513          	addi	a0,a0,-524 # 80004038 <CONSOLE_STATUS+0x28>
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	edc080e7          	jalr	-292(ra) # 80001128 <_Z5kputsPKc>
    80001254:	00098513          	mv	a0,s3
    80001258:	00000097          	auipc	ra,0x0
    8000125c:	f14080e7          	jalr	-236(ra) # 8000116c <_Z7kputhexm>
    kputs("\n");
    80001260:	00003517          	auipc	a0,0x3
    80001264:	fc850513          	addi	a0,a0,-56 # 80004228 <CONSOLE_STATUS+0x218>
    80001268:	00000097          	auipc	ra,0x0
    8000126c:	ec0080e7          	jalr	-320(ra) # 80001128 <_Z5kputsPKc>
    *(volatile int*)0x100000 = 0x5555;   // halt emulatora
    80001270:	00100737          	lui	a4,0x100
    80001274:	000057b7          	lui	a5,0x5
    80001278:	5557879b          	addiw	a5,a5,1365
    8000127c:	00f72023          	sw	a5,0(a4) # 100000 <_entry-0x7ff00000>
    return a0;
    80001280:	00048513          	mv	a0,s1
}
    80001284:	02813083          	ld	ra,40(sp)
    80001288:	02013403          	ld	s0,32(sp)
    8000128c:	01813483          	ld	s1,24(sp)
    80001290:	01013903          	ld	s2,16(sp)
    80001294:	00813983          	ld	s3,8(sp)
    80001298:	03010113          	addi	sp,sp,48
    8000129c:	00008067          	ret
        if (code == 1) {
    800012a0:	00100713          	li	a4,1
    800012a4:	00e78a63          	beq	a5,a4,800012b8 <handleTrap+0xd4>
        } else if (code == 9) {
    800012a8:	00900713          	li	a4,9
    800012ac:	00e78e63          	beq	a5,a4,800012c8 <handleTrap+0xe4>
        return a0;
    800012b0:	00048513          	mv	a0,s1
    800012b4:	fd1ff06f          	j	80001284 <handleTrap+0xa0>
            asm volatile("csrr %0, sip" : "=r"(sip));
    800012b8:	144027f3          	csrr	a5,sip
            sip &= ~(1UL << 1);
    800012bc:	ffd7f793          	andi	a5,a5,-3
            asm volatile("csrw sip, %0" : : "r"(sip));
    800012c0:	14479073          	csrw	sip,a5
    800012c4:	fedff06f          	j	800012b0 <handleTrap+0xcc>
            int irq = plic_claim();
    800012c8:	00001097          	auipc	ra,0x1
    800012cc:	f8c080e7          	jalr	-116(ra) # 80002254 <plic_claim>
            plic_complete(irq);
    800012d0:	00001097          	auipc	ra,0x1
    800012d4:	fbc080e7          	jalr	-68(ra) # 8000228c <plic_complete>
    800012d8:	fd9ff06f          	j	800012b0 <handleTrap+0xcc>
        switch (a0) {
    800012dc:	00100793          	li	a5,1
    800012e0:	00f48e63          	beq	s1,a5,800012fc <handleTrap+0x118>
    800012e4:	00200793          	li	a5,2
    800012e8:	02f48263          	beq	s1,a5,8000130c <handleTrap+0x128>
        asm volatile("csrr %0, sepc" : "=r"(sepc));
    800012ec:	141027f3          	csrr	a5,sepc
        sepc += 4;
    800012f0:	00478793          	addi	a5,a5,4 # 5004 <_entry-0x7fffaffc>
        asm volatile("csrw sepc, %0" : : "r"(sepc));
    800012f4:	14179073          	csrw	sepc,a5
        return ret;
    800012f8:	f8dff06f          	j	80001284 <handleTrap+0xa0>
                ret = (uint64)MemoryAllocator::alloc(a1 * MEM_BLOCK_SIZE);
    800012fc:	00659513          	slli	a0,a1,0x6
    80001300:	00000097          	auipc	ra,0x0
    80001304:	3c8080e7          	jalr	968(ra) # 800016c8 <_ZN15MemoryAllocator5allocEm>
                break;
    80001308:	fe5ff06f          	j	800012ec <handleTrap+0x108>
                ret = (uint64)MemoryAllocator::free((void*)a1);
    8000130c:	00058513          	mv	a0,a1
    80001310:	00000097          	auipc	ra,0x0
    80001314:	4f4080e7          	jalr	1268(ra) # 80001804 <_ZN15MemoryAllocator4freeEPv>
                break;
    80001318:	fd5ff06f          	j	800012ec <handleTrap+0x108>

000000008000131c <_Z8userMainv>:
// ovaj fajl se uklanja (duplikat simbola userMain)
#include "../h/syscall_c.hpp"
#include "../h/print.hpp"
#include "../h/memoryAllocator.hpp"

void userMain() {
    8000131c:	fd010113          	addi	sp,sp,-48
    80001320:	02113423          	sd	ra,40(sp)
    80001324:	02813023          	sd	s0,32(sp)
    80001328:	00913c23          	sd	s1,24(sp)
    8000132c:	01213823          	sd	s2,16(sp)
    80001330:	01313423          	sd	s3,8(sp)
    80001334:	03010413          	addi	s0,sp,48
    // tri alokacije razlicitih velicina kroz ecall
    void* p1 = mem_alloc(100);   // 100+16=116 -> 128B (2 bloka)
    80001338:	06400513          	li	a0,100
    8000133c:	00000097          	auipc	ra,0x0
    80001340:	d54080e7          	jalr	-684(ra) # 80001090 <_Z9mem_allocm>
    80001344:	00050913          	mv	s2,a0
    void* p2 = mem_alloc(200);   // 200+16=216 -> 256B (4 bloka)
    80001348:	0c800513          	li	a0,200
    8000134c:	00000097          	auipc	ra,0x0
    80001350:	d44080e7          	jalr	-700(ra) # 80001090 <_Z9mem_allocm>
    80001354:	00050993          	mv	s3,a0
    void* p3 = mem_alloc(50);    // 50+16=66   -> 128B (2 bloka)
    80001358:	03200513          	li	a0,50
    8000135c:	00000097          	auipc	ra,0x0
    80001360:	d34080e7          	jalr	-716(ra) # 80001090 <_Z9mem_allocm>
    80001364:	00050493          	mv	s1,a0
    kputs("p1 = "); kputhex((uint64)p1); kputs("\n");
    80001368:	00003517          	auipc	a0,0x3
    8000136c:	cd850513          	addi	a0,a0,-808 # 80004040 <CONSOLE_STATUS+0x30>
    80001370:	00000097          	auipc	ra,0x0
    80001374:	db8080e7          	jalr	-584(ra) # 80001128 <_Z5kputsPKc>
    80001378:	00090513          	mv	a0,s2
    8000137c:	00000097          	auipc	ra,0x0
    80001380:	df0080e7          	jalr	-528(ra) # 8000116c <_Z7kputhexm>
    80001384:	00003517          	auipc	a0,0x3
    80001388:	ea450513          	addi	a0,a0,-348 # 80004228 <CONSOLE_STATUS+0x218>
    8000138c:	00000097          	auipc	ra,0x0
    80001390:	d9c080e7          	jalr	-612(ra) # 80001128 <_Z5kputsPKc>
    kputs("p2 = "); kputhex((uint64)p2); kputs("\n");
    80001394:	00003517          	auipc	a0,0x3
    80001398:	cb450513          	addi	a0,a0,-844 # 80004048 <CONSOLE_STATUS+0x38>
    8000139c:	00000097          	auipc	ra,0x0
    800013a0:	d8c080e7          	jalr	-628(ra) # 80001128 <_Z5kputsPKc>
    800013a4:	00098513          	mv	a0,s3
    800013a8:	00000097          	auipc	ra,0x0
    800013ac:	dc4080e7          	jalr	-572(ra) # 8000116c <_Z7kputhexm>
    800013b0:	00003517          	auipc	a0,0x3
    800013b4:	e7850513          	addi	a0,a0,-392 # 80004228 <CONSOLE_STATUS+0x218>
    800013b8:	00000097          	auipc	ra,0x0
    800013bc:	d70080e7          	jalr	-656(ra) # 80001128 <_Z5kputsPKc>
    kputs("p3 = "); kputhex((uint64)p3); kputs("\n");
    800013c0:	00003517          	auipc	a0,0x3
    800013c4:	c9050513          	addi	a0,a0,-880 # 80004050 <CONSOLE_STATUS+0x40>
    800013c8:	00000097          	auipc	ra,0x0
    800013cc:	d60080e7          	jalr	-672(ra) # 80001128 <_Z5kputsPKc>
    800013d0:	00048513          	mv	a0,s1
    800013d4:	00000097          	auipc	ra,0x0
    800013d8:	d98080e7          	jalr	-616(ra) # 8000116c <_Z7kputhexm>
    800013dc:	00003517          	auipc	a0,0x3
    800013e0:	e4c50513          	addi	a0,a0,-436 # 80004228 <CONSOLE_STATUS+0x218>
    800013e4:	00000097          	auipc	ra,0x0
    800013e8:	d44080e7          	jalr	-700(ra) # 80001128 <_Z5kputsPKc>
    MemoryAllocator::printFreeList();   // ocekujemo: jedan veliki ostatak heapa
    800013ec:	00000097          	auipc	ra,0x0
    800013f0:	384080e7          	jalr	900(ra) # 80001770 <_ZN15MemoryAllocator13printFreeListEv>

    // oslobodi SREDNJI pa PRVI: rupa p2 i rupa p1 moraju da se spoje u jednu
    int r2 = mem_free(p2);
    800013f4:	00098513          	mv	a0,s3
    800013f8:	00000097          	auipc	ra,0x0
    800013fc:	ccc080e7          	jalr	-820(ra) # 800010c4 <_Z8mem_freePv>
    80001400:	00050993          	mv	s3,a0
    int r1 = mem_free(p1);
    80001404:	00090513          	mv	a0,s2
    80001408:	00000097          	auipc	ra,0x0
    8000140c:	cbc080e7          	jalr	-836(ra) # 800010c4 <_Z8mem_freePv>
    80001410:	00050913          	mv	s2,a0
    kputs("free(p2) = "); kputhex((uint64)r2); kputs("\n");
    80001414:	00003517          	auipc	a0,0x3
    80001418:	c4450513          	addi	a0,a0,-956 # 80004058 <CONSOLE_STATUS+0x48>
    8000141c:	00000097          	auipc	ra,0x0
    80001420:	d0c080e7          	jalr	-756(ra) # 80001128 <_Z5kputsPKc>
    80001424:	00098513          	mv	a0,s3
    80001428:	00000097          	auipc	ra,0x0
    8000142c:	d44080e7          	jalr	-700(ra) # 8000116c <_Z7kputhexm>
    80001430:	00003517          	auipc	a0,0x3
    80001434:	df850513          	addi	a0,a0,-520 # 80004228 <CONSOLE_STATUS+0x218>
    80001438:	00000097          	auipc	ra,0x0
    8000143c:	cf0080e7          	jalr	-784(ra) # 80001128 <_Z5kputsPKc>
    kputs("free(p1) = "); kputhex((uint64)r1); kputs("\n");
    80001440:	00003517          	auipc	a0,0x3
    80001444:	c2850513          	addi	a0,a0,-984 # 80004068 <CONSOLE_STATUS+0x58>
    80001448:	00000097          	auipc	ra,0x0
    8000144c:	ce0080e7          	jalr	-800(ra) # 80001128 <_Z5kputsPKc>
    80001450:	00090513          	mv	a0,s2
    80001454:	00000097          	auipc	ra,0x0
    80001458:	d18080e7          	jalr	-744(ra) # 8000116c <_Z7kputhexm>
    8000145c:	00003517          	auipc	a0,0x3
    80001460:	dcc50513          	addi	a0,a0,-564 # 80004228 <CONSOLE_STATUS+0x218>
    80001464:	00000097          	auipc	ra,0x0
    80001468:	cc4080e7          	jalr	-828(ra) # 80001128 <_Z5kputsPKc>
    MemoryAllocator::printFreeList();   // ocekujemo: [rupa p1+p2: 384B] + [veliki ostatak]
    8000146c:	00000097          	auipc	ra,0x0
    80001470:	304080e7          	jalr	772(ra) # 80001770 <_ZN15MemoryAllocator13printFreeListEv>

    // oslobodi i p3: sve mora da se stopi nazad u JEDAN blok
    int r3 = mem_free(p3);
    80001474:	00048513          	mv	a0,s1
    80001478:	00000097          	auipc	ra,0x0
    8000147c:	c4c080e7          	jalr	-948(ra) # 800010c4 <_Z8mem_freePv>
    80001480:	00050493          	mv	s1,a0
    kputs("free(p3) = "); kputhex((uint64)r3); kputs("\n");
    80001484:	00003517          	auipc	a0,0x3
    80001488:	bf450513          	addi	a0,a0,-1036 # 80004078 <CONSOLE_STATUS+0x68>
    8000148c:	00000097          	auipc	ra,0x0
    80001490:	c9c080e7          	jalr	-868(ra) # 80001128 <_Z5kputsPKc>
    80001494:	00048513          	mv	a0,s1
    80001498:	00000097          	auipc	ra,0x0
    8000149c:	cd4080e7          	jalr	-812(ra) # 8000116c <_Z7kputhexm>
    800014a0:	00003517          	auipc	a0,0x3
    800014a4:	d8850513          	addi	a0,a0,-632 # 80004228 <CONSOLE_STATUS+0x218>
    800014a8:	00000097          	auipc	ra,0x0
    800014ac:	c80080e7          	jalr	-896(ra) # 80001128 <_Z5kputsPKc>
    MemoryAllocator::printFreeList();   // ocekujemo: jedan jedini blok = ceo heap
    800014b0:	00000097          	auipc	ra,0x0
    800014b4:	2c0080e7          	jalr	704(ra) # 80001770 <_ZN15MemoryAllocator13printFreeListEv>
}
    800014b8:	02813083          	ld	ra,40(sp)
    800014bc:	02013403          	ld	s0,32(sp)
    800014c0:	01813483          	ld	s1,24(sp)
    800014c4:	01013903          	ld	s2,16(sp)
    800014c8:	00813983          	ld	s3,8(sp)
    800014cc:	03010113          	addi	sp,sp,48
    800014d0:	00008067          	ret

00000000800014d4 <_ZN3TCBnwEm>:
#include "../h/memoryAllocator.hpp"

TCB* TCB::running = nullptr;

// new/delete za tcb: direktno na alokator jezgra (bez ecall-a)
void* TCB::operator new(size_t size) {
    800014d4:	ff010113          	addi	sp,sp,-16
    800014d8:	00113423          	sd	ra,8(sp)
    800014dc:	00813023          	sd	s0,0(sp)
    800014e0:	01010413          	addi	s0,sp,16
    return MemoryAllocator::alloc(size);
    800014e4:	00000097          	auipc	ra,0x0
    800014e8:	1e4080e7          	jalr	484(ra) # 800016c8 <_ZN15MemoryAllocator5allocEm>
}
    800014ec:	00813083          	ld	ra,8(sp)
    800014f0:	00013403          	ld	s0,0(sp)
    800014f4:	01010113          	addi	sp,sp,16
    800014f8:	00008067          	ret

00000000800014fc <_ZN3TCBdlEPv>:
void TCB::operator delete(void* ptr) {
    800014fc:	ff010113          	addi	sp,sp,-16
    80001500:	00113423          	sd	ra,8(sp)
    80001504:	00813023          	sd	s0,0(sp)
    80001508:	01010413          	addi	s0,sp,16
    MemoryAllocator::free(ptr);
    8000150c:	00000097          	auipc	ra,0x0
    80001510:	2f8080e7          	jalr	760(ra) # 80001804 <_ZN15MemoryAllocator4freeEPv>
}
    80001514:	00813083          	ld	ra,8(sp)
    80001518:	00013403          	ld	s0,0(sp)
    8000151c:	01010113          	addi	sp,sp,16
    80001520:	00008067          	ret

0000000080001524 <_ZN3TCBC1EPFvPvES0_Pm>:

TCB::TCB(Body body, void* arg, uint64* stack)
    80001524:	ff010113          	addi	sp,sp,-16
    80001528:	00813423          	sd	s0,8(sp)
    8000152c:	01010413          	addi	s0,sp,16
    : body(body), arg(arg), stack(stack),
      context({0, 0}),   // pravi pocetni kontekst pravimo u sledecoj lekciji
      finished(false), next(nullptr)
    80001530:	00b53023          	sd	a1,0(a0)
    80001534:	00c53423          	sd	a2,8(a0)
    80001538:	00d53823          	sd	a3,16(a0)
    8000153c:	00053c23          	sd	zero,24(a0)
    80001540:	02053023          	sd	zero,32(a0)
    80001544:	02050423          	sb	zero,40(a0)
    80001548:	02053823          	sd	zero,48(a0)
{}
    8000154c:	00813403          	ld	s0,8(sp)
    80001550:	01010113          	addi	sp,sp,16
    80001554:	00008067          	ret

0000000080001558 <_ZN3TCB12createThreadEPFvPvES0_>:

TCB* TCB::createThread(Body body, void* arg) {
    80001558:	fd010113          	addi	sp,sp,-48
    8000155c:	02113423          	sd	ra,40(sp)
    80001560:	02813023          	sd	s0,32(sp)
    80001564:	00913c23          	sd	s1,24(sp)
    80001568:	01213823          	sd	s2,16(sp)
    8000156c:	01313423          	sd	s3,8(sp)
    80001570:	01413023          	sd	s4,0(sp)
    80001574:	03010413          	addi	s0,sp,48
    80001578:	00050993          	mv	s3,a0
    8000157c:	00058a13          	mv	s4,a1
    // stek niti: DEFAULT_STACK_SIZE bajtova iz hw.h
    uint64* stack = (uint64*)MemoryAllocator::alloc(DEFAULT_STACK_SIZE);
    80001580:	00001537          	lui	a0,0x1
    80001584:	00000097          	auipc	ra,0x0
    80001588:	144080e7          	jalr	324(ra) # 800016c8 <_ZN15MemoryAllocator5allocEm>
    8000158c:	00050493          	mv	s1,a0
    if (!stack) return nullptr;
    80001590:	06050063          	beqz	a0,800015f0 <_ZN3TCB12createThreadEPFvPvES0_+0x98>

    TCB* tcb = new TCB(body, arg, stack);
    80001594:	03800513          	li	a0,56
    80001598:	00000097          	auipc	ra,0x0
    8000159c:	f3c080e7          	jalr	-196(ra) # 800014d4 <_ZN3TCBnwEm>
    800015a0:	00050913          	mv	s2,a0
    800015a4:	00048693          	mv	a3,s1
    800015a8:	000a0613          	mv	a2,s4
    800015ac:	00098593          	mv	a1,s3
    800015b0:	00000097          	auipc	ra,0x0
    800015b4:	f74080e7          	jalr	-140(ra) # 80001524 <_ZN3TCBC1EPFvPvES0_Pm>
    if (!tcb) { MemoryAllocator::free(stack); return nullptr; }
    800015b8:	02090463          	beqz	s2,800015e0 <_ZN3TCB12createThreadEPFvPvES0_+0x88>

    // todo (lekcija 2): postaviti context.ra i context.sp tako da prvo
    // "odmrzavanje" ubaci nit u njeno telo
    return tcb;
}
    800015bc:	00090513          	mv	a0,s2
    800015c0:	02813083          	ld	ra,40(sp)
    800015c4:	02013403          	ld	s0,32(sp)
    800015c8:	01813483          	ld	s1,24(sp)
    800015cc:	01013903          	ld	s2,16(sp)
    800015d0:	00813983          	ld	s3,8(sp)
    800015d4:	00013a03          	ld	s4,0(sp)
    800015d8:	03010113          	addi	sp,sp,48
    800015dc:	00008067          	ret
    if (!tcb) { MemoryAllocator::free(stack); return nullptr; }
    800015e0:	00048513          	mv	a0,s1
    800015e4:	00000097          	auipc	ra,0x0
    800015e8:	220080e7          	jalr	544(ra) # 80001804 <_ZN15MemoryAllocator4freeEPv>
    800015ec:	fd1ff06f          	j	800015bc <_ZN3TCB12createThreadEPFvPvES0_+0x64>
    if (!stack) return nullptr;
    800015f0:	00050913          	mv	s2,a0
    800015f4:	fc9ff06f          	j	800015bc <_ZN3TCB12createThreadEPFvPvES0_+0x64>

00000000800015f8 <_ZN9Scheduler3putEP3TCB>:

TCB* Scheduler::head = nullptr;
TCB* Scheduler::tail = nullptr;

// stani na kraj reda
void Scheduler::put(TCB* thread) {
    800015f8:	ff010113          	addi	sp,sp,-16
    800015fc:	00813423          	sd	s0,8(sp)
    80001600:	01010413          	addi	s0,sp,16
    thread->next = nullptr;
    80001604:	02053823          	sd	zero,48(a0) # 1030 <_entry-0x7fffefd0>
    if (tail) {
    80001608:	00003797          	auipc	a5,0x3
    8000160c:	0407b783          	ld	a5,64(a5) # 80004648 <_ZN9Scheduler4tailE>
    80001610:	00078e63          	beqz	a5,8000162c <_ZN9Scheduler3putEP3TCB+0x34>
        tail->next = thread;   // dosadasnji poslednji pokaze na novog
    80001614:	02a7b823          	sd	a0,48(a5)
    } else {
        head = thread;         // red je bio prazan: novi je i prvi
    }
    tail = thread;             // novi je u svakom slucaju poslednji
    80001618:	00003797          	auipc	a5,0x3
    8000161c:	02a7b823          	sd	a0,48(a5) # 80004648 <_ZN9Scheduler4tailE>
}
    80001620:	00813403          	ld	s0,8(sp)
    80001624:	01010113          	addi	sp,sp,16
    80001628:	00008067          	ret
        head = thread;         // red je bio prazan: novi je i prvi
    8000162c:	00003797          	auipc	a5,0x3
    80001630:	02a7b223          	sd	a0,36(a5) # 80004650 <_ZN9Scheduler4headE>
    80001634:	fe5ff06f          	j	80001618 <_ZN9Scheduler3putEP3TCB+0x20>

0000000080001638 <_ZN9Scheduler3getEv>:

// skini nit sa cela reda
TCB* Scheduler::get() {
    80001638:	ff010113          	addi	sp,sp,-16
    8000163c:	00813423          	sd	s0,8(sp)
    80001640:	01010413          	addi	s0,sp,16
    TCB* thread = head;
    80001644:	00003517          	auipc	a0,0x3
    80001648:	00c53503          	ld	a0,12(a0) # 80004650 <_ZN9Scheduler4headE>
    if (!thread) return nullptr;   // prazan red
    8000164c:	00050c63          	beqz	a0,80001664 <_ZN9Scheduler3getEv+0x2c>
    head = head->next;
    80001650:	03053783          	ld	a5,48(a0)
    80001654:	00003717          	auipc	a4,0x3
    80001658:	fef73e23          	sd	a5,-4(a4) # 80004650 <_ZN9Scheduler4headE>
    if (!head) tail = nullptr;     // skinuli smo i poslednjeg
    8000165c:	00078a63          	beqz	a5,80001670 <_ZN9Scheduler3getEv+0x38>
    thread->next = nullptr;
    80001660:	02053823          	sd	zero,48(a0)
    return thread;
}
    80001664:	00813403          	ld	s0,8(sp)
    80001668:	01010113          	addi	sp,sp,16
    8000166c:	00008067          	ret
    if (!head) tail = nullptr;     // skinuli smo i poslednjeg
    80001670:	00003797          	auipc	a5,0x3
    80001674:	fc07bc23          	sd	zero,-40(a5) # 80004648 <_ZN9Scheduler4tailE>
    80001678:	fe9ff06f          	j	80001660 <_ZN9Scheduler3getEv+0x28>

000000008000167c <_ZN15MemoryAllocator4initEv>:
#include "../h/print.hpp"

MemoryAllocator::FreeBlock* MemoryAllocator::freeListHead = nullptr;

// ceo heap = jedan slobodan blok
void MemoryAllocator::init() {
    8000167c:	ff010113          	addi	sp,sp,-16
    80001680:	00813423          	sd	s0,8(sp)
    80001684:	01010413          	addi	s0,sp,16
    freeListHead = (FreeBlock*)HEAP_START_ADDR;
    80001688:	00003797          	auipc	a5,0x3
    8000168c:	f9078793          	addi	a5,a5,-112 # 80004618 <HEAP_START_ADDR>
    80001690:	0007b683          	ld	a3,0(a5)
    80001694:	00003717          	auipc	a4,0x3
    80001698:	fc470713          	addi	a4,a4,-60 # 80004658 <_ZN15MemoryAllocator12freeListHeadE>
    8000169c:	00d73023          	sd	a3,0(a4)
    freeListHead->next = nullptr;
    800016a0:	0006b023          	sd	zero,0(a3)
    freeListHead->size = (char*)HEAP_END_ADDR - (char*)HEAP_START_ADDR;
    800016a4:	0007b683          	ld	a3,0(a5)
    800016a8:	00073703          	ld	a4,0(a4)
    800016ac:	00003797          	auipc	a5,0x3
    800016b0:	f647b783          	ld	a5,-156(a5) # 80004610 <HEAP_END_ADDR>
    800016b4:	40d787b3          	sub	a5,a5,a3
    800016b8:	00f73423          	sd	a5,8(a4)
}
    800016bc:	00813403          	ld	s0,8(sp)
    800016c0:	01010113          	addi	sp,sp,16
    800016c4:	00008067          	ret

00000000800016c8 <_ZN15MemoryAllocator5allocEm>:

void* MemoryAllocator::alloc(size_t size){
    800016c8:	ff010113          	addi	sp,sp,-16
    800016cc:	00813423          	sd	s0,8(sp)
    800016d0:	01010413          	addi	s0,sp,16
    if (size == 0) {
    800016d4:	08050a63          	beqz	a0,80001768 <_ZN15MemoryAllocator5allocEm+0xa0>
        return nullptr;
    }
    // zaokruzivanje navise: ((n + B - 1) / B) * B; heder ukljucen u racun
    // da payload uvek bude >= size
    size_t n = size + sizeof(FreeBlock);
    size_t roundedSize = ((n + MEM_BLOCK_SIZE - 1) / MEM_BLOCK_SIZE) * MEM_BLOCK_SIZE;
    800016d8:	04f50513          	addi	a0,a0,79
    800016dc:	fc057713          	andi	a4,a0,-64

    // first-fit kroz slobodnu listu
    FreeBlock* curr = freeListHead;
    800016e0:	00003517          	auipc	a0,0x3
    800016e4:	f7853503          	ld	a0,-136(a0) # 80004658 <_ZN15MemoryAllocator12freeListHeadE>
    FreeBlock* prev = nullptr;
    800016e8:	00000693          	li	a3,0
    while(curr != nullptr){
    800016ec:	04050263          	beqz	a0,80001730 <_ZN15MemoryAllocator5allocEm+0x68>
        if(curr->size >= roundedSize){
    800016f0:	00853783          	ld	a5,8(a0)
    800016f4:	00e7f863          	bgeu	a5,a4,80001704 <_ZN15MemoryAllocator5allocEm+0x3c>
                    freeListHead = curr->next;
                }
            }
            return (char*)curr + sizeof(FreeBlock);
        }
        prev = curr;
    800016f8:	00050693          	mv	a3,a0
        curr = curr->next;
    800016fc:	00053503          	ld	a0,0(a0)
    while(curr != nullptr){
    80001700:	fedff06f          	j	800016ec <_ZN15MemoryAllocator5allocEm+0x24>
            size_t remainder = curr->size - roundedSize;
    80001704:	40e787b3          	sub	a5,a5,a4
            if (remainder >= MEM_BLOCK_SIZE) {
    80001708:	03f00613          	li	a2,63
    8000170c:	02f67e63          	bgeu	a2,a5,80001748 <_ZN15MemoryAllocator5allocEm+0x80>
                FreeBlock* newBlock = (FreeBlock*)((char*)curr + roundedSize);
    80001710:	00e50633          	add	a2,a0,a4
                newBlock->size = remainder;
    80001714:	00f63423          	sd	a5,8(a2)
                newBlock->next = curr->next;
    80001718:	00053783          	ld	a5,0(a0)
    8000171c:	00f63023          	sd	a5,0(a2)
                if (prev != nullptr) {
    80001720:	00068e63          	beqz	a3,8000173c <_ZN15MemoryAllocator5allocEm+0x74>
                    prev->next = newBlock;
    80001724:	00c6b023          	sd	a2,0(a3)
                curr->size = roundedSize;
    80001728:	00e53423          	sd	a4,8(a0)
            return (char*)curr + sizeof(FreeBlock);
    8000172c:	01050513          	addi	a0,a0,16
    }
    return nullptr;   // nema dovoljno velikog bloka
}
    80001730:	00813403          	ld	s0,8(sp)
    80001734:	01010113          	addi	sp,sp,16
    80001738:	00008067          	ret
                    freeListHead = newBlock;
    8000173c:	00003797          	auipc	a5,0x3
    80001740:	f0c7be23          	sd	a2,-228(a5) # 80004658 <_ZN15MemoryAllocator12freeListHeadE>
    80001744:	fe5ff06f          	j	80001728 <_ZN15MemoryAllocator5allocEm+0x60>
                if (prev != nullptr) {
    80001748:	00068863          	beqz	a3,80001758 <_ZN15MemoryAllocator5allocEm+0x90>
                    prev->next = curr->next;
    8000174c:	00053783          	ld	a5,0(a0)
    80001750:	00f6b023          	sd	a5,0(a3)
    80001754:	fd9ff06f          	j	8000172c <_ZN15MemoryAllocator5allocEm+0x64>
                    freeListHead = curr->next;
    80001758:	00053783          	ld	a5,0(a0)
    8000175c:	00003717          	auipc	a4,0x3
    80001760:	eef73e23          	sd	a5,-260(a4) # 80004658 <_ZN15MemoryAllocator12freeListHeadE>
    80001764:	fc9ff06f          	j	8000172c <_ZN15MemoryAllocator5allocEm+0x64>
        return nullptr;
    80001768:	00000513          	li	a0,0
    8000176c:	fc5ff06f          	j	80001730 <_ZN15MemoryAllocator5allocEm+0x68>

0000000080001770 <_ZN15MemoryAllocator13printFreeListEv>:

// debug ispis slobodne liste (nije deo resenja koje se predaje)
void MemoryAllocator::printFreeList() {
    80001770:	fe010113          	addi	sp,sp,-32
    80001774:	00113c23          	sd	ra,24(sp)
    80001778:	00813823          	sd	s0,16(sp)
    8000177c:	00913423          	sd	s1,8(sp)
    80001780:	02010413          	addi	s0,sp,32
    FreeBlock* curr = freeListHead;
    80001784:	00003497          	auipc	s1,0x3
    80001788:	ed44b483          	ld	s1,-300(s1) # 80004658 <_ZN15MemoryAllocator12freeListHeadE>
    kputs("free list:\n");
    8000178c:	00003517          	auipc	a0,0x3
    80001790:	8fc50513          	addi	a0,a0,-1796 # 80004088 <CONSOLE_STATUS+0x78>
    80001794:	00000097          	auipc	ra,0x0
    80001798:	994080e7          	jalr	-1644(ra) # 80001128 <_Z5kputsPKc>
    while (curr != nullptr) {
    8000179c:	04048a63          	beqz	s1,800017f0 <_ZN15MemoryAllocator13printFreeListEv+0x80>
        kputs("  blok na ");
    800017a0:	00003517          	auipc	a0,0x3
    800017a4:	8f850513          	addi	a0,a0,-1800 # 80004098 <CONSOLE_STATUS+0x88>
    800017a8:	00000097          	auipc	ra,0x0
    800017ac:	980080e7          	jalr	-1664(ra) # 80001128 <_Z5kputsPKc>
        kputhex((uint64)curr);
    800017b0:	00048513          	mv	a0,s1
    800017b4:	00000097          	auipc	ra,0x0
    800017b8:	9b8080e7          	jalr	-1608(ra) # 8000116c <_Z7kputhexm>
        kputs(", size: ");
    800017bc:	00003517          	auipc	a0,0x3
    800017c0:	8ec50513          	addi	a0,a0,-1812 # 800040a8 <CONSOLE_STATUS+0x98>
    800017c4:	00000097          	auipc	ra,0x0
    800017c8:	964080e7          	jalr	-1692(ra) # 80001128 <_Z5kputsPKc>
        kputhex(curr->size);
    800017cc:	0084b503          	ld	a0,8(s1)
    800017d0:	00000097          	auipc	ra,0x0
    800017d4:	99c080e7          	jalr	-1636(ra) # 8000116c <_Z7kputhexm>
        kputs("\n");
    800017d8:	00003517          	auipc	a0,0x3
    800017dc:	a5050513          	addi	a0,a0,-1456 # 80004228 <CONSOLE_STATUS+0x218>
    800017e0:	00000097          	auipc	ra,0x0
    800017e4:	948080e7          	jalr	-1720(ra) # 80001128 <_Z5kputsPKc>
        curr = curr->next;
    800017e8:	0004b483          	ld	s1,0(s1)
    while (curr != nullptr) {
    800017ec:	fb1ff06f          	j	8000179c <_ZN15MemoryAllocator13printFreeListEv+0x2c>
    }
}
    800017f0:	01813083          	ld	ra,24(sp)
    800017f4:	01013403          	ld	s0,16(sp)
    800017f8:	00813483          	ld	s1,8(sp)
    800017fc:	02010113          	addi	sp,sp,32
    80001800:	00008067          	ret

0000000080001804 <_ZN15MemoryAllocator4freeEPv>:

int MemoryAllocator::free(void* ptr){
    80001804:	ff010113          	addi	sp,sp,-16
    80001808:	00813423          	sd	s0,8(sp)
    8000180c:	01010413          	addi	s0,sp,16
    if (ptr == nullptr) return -1;
    80001810:	12050663          	beqz	a0,8000193c <_ZN15MemoryAllocator4freeEPv+0x138>
    FreeBlock* curr = freeListHead;
    80001814:	00003797          	auipc	a5,0x3
    80001818:	e447b783          	ld	a5,-444(a5) # 80004658 <_ZN15MemoryAllocator12freeListHeadE>
    FreeBlock* prev = nullptr;
    // heder zivi tacno ispred payload-a
    FreeBlock* block = (FreeBlock*)((char*)ptr - sizeof(FreeBlock));
    8000181c:	ff050693          	addi	a3,a0,-16
    FreeBlock* prev = nullptr;
    80001820:	00000713          	li	a4,0
    // nadji mesto po adresi (lista je sortirana da bi spajanje radilo)
    while(curr != nullptr && curr < block){
    80001824:	00078a63          	beqz	a5,80001838 <_ZN15MemoryAllocator4freeEPv+0x34>
    80001828:	00d7f863          	bgeu	a5,a3,80001838 <_ZN15MemoryAllocator4freeEPv+0x34>
        prev = curr;
    8000182c:	00078713          	mv	a4,a5
        curr = curr->next;
    80001830:	0007b783          	ld	a5,0(a5)
    while(curr != nullptr && curr < block){
    80001834:	ff1ff06f          	j	80001824 <_ZN15MemoryAllocator4freeEPv+0x20>
    }

    // da li se blok fizicki naslanja na suseda ispred/iza?
    bool mergePrev = (prev != nullptr) && ((char*)prev + prev->size == (char*)block);
    80001838:	04070263          	beqz	a4,8000187c <_ZN15MemoryAllocator4freeEPv+0x78>
    8000183c:	00873603          	ld	a2,8(a4)
    80001840:	00c70633          	add	a2,a4,a2
    80001844:	04d60063          	beq	a2,a3,80001884 <_ZN15MemoryAllocator4freeEPv+0x80>
    80001848:	00000613          	li	a2,0
    bool mergeNext = (curr != nullptr) && ((char*)block + block->size == (char*)curr);
    8000184c:	04078063          	beqz	a5,8000188c <_ZN15MemoryAllocator4freeEPv+0x88>
    80001850:	ff853583          	ld	a1,-8(a0)
    80001854:	00b685b3          	add	a1,a3,a1
    80001858:	02f58e63          	beq	a1,a5,80001894 <_ZN15MemoryAllocator4freeEPv+0x90>
    8000185c:	00000593          	li	a1,0

    if (!mergePrev && !mergeNext) {
    80001860:	04061663          	bnez	a2,800018ac <_ZN15MemoryAllocator4freeEPv+0xa8>
    80001864:	04059463          	bnez	a1,800018ac <_ZN15MemoryAllocator4freeEPv+0xa8>
        // nema spajanja: samo umetni izmedju prev i curr
        block->next = curr;
    80001868:	fef53823          	sd	a5,-16(a0)
        if (prev != nullptr) {
    8000186c:	02070863          	beqz	a4,8000189c <_ZN15MemoryAllocator4freeEPv+0x98>
            prev->next = block;
    80001870:	00d73023          	sd	a3,0(a4)
    } else {
        // spoji sa oba suseda
        prev->size += block->size + curr->size;
        prev->next = curr->next;
    }
    return 0;
    80001874:	00000513          	li	a0,0
    80001878:	0b80006f          	j	80001930 <_ZN15MemoryAllocator4freeEPv+0x12c>
    bool mergePrev = (prev != nullptr) && ((char*)prev + prev->size == (char*)block);
    8000187c:	00000613          	li	a2,0
    80001880:	fcdff06f          	j	8000184c <_ZN15MemoryAllocator4freeEPv+0x48>
    80001884:	00100613          	li	a2,1
    80001888:	fc5ff06f          	j	8000184c <_ZN15MemoryAllocator4freeEPv+0x48>
    bool mergeNext = (curr != nullptr) && ((char*)block + block->size == (char*)curr);
    8000188c:	00000593          	li	a1,0
    80001890:	fd1ff06f          	j	80001860 <_ZN15MemoryAllocator4freeEPv+0x5c>
    80001894:	00100593          	li	a1,1
    80001898:	fc9ff06f          	j	80001860 <_ZN15MemoryAllocator4freeEPv+0x5c>
            freeListHead = block;
    8000189c:	00003797          	auipc	a5,0x3
    800018a0:	dad7be23          	sd	a3,-580(a5) # 80004658 <_ZN15MemoryAllocator12freeListHeadE>
    return 0;
    800018a4:	00000513          	li	a0,0
    800018a8:	0880006f          	j	80001930 <_ZN15MemoryAllocator4freeEPv+0x12c>
    } else if (mergePrev && !mergeNext) {
    800018ac:	02060063          	beqz	a2,800018cc <_ZN15MemoryAllocator4freeEPv+0xc8>
    800018b0:	00059e63          	bnez	a1,800018cc <_ZN15MemoryAllocator4freeEPv+0xc8>
        prev->size += block->size;
    800018b4:	ff853683          	ld	a3,-8(a0)
    800018b8:	00873783          	ld	a5,8(a4)
    800018bc:	00d787b3          	add	a5,a5,a3
    800018c0:	00f73423          	sd	a5,8(a4)
    return 0;
    800018c4:	00000513          	li	a0,0
        prev->size += block->size;
    800018c8:	0680006f          	j	80001930 <_ZN15MemoryAllocator4freeEPv+0x12c>
    } else if (!mergePrev && mergeNext) {
    800018cc:	04061063          	bnez	a2,8000190c <_ZN15MemoryAllocator4freeEPv+0x108>
    800018d0:	02058e63          	beqz	a1,8000190c <_ZN15MemoryAllocator4freeEPv+0x108>
        block->size += curr->size;
    800018d4:	0087b583          	ld	a1,8(a5)
    800018d8:	ff853603          	ld	a2,-8(a0)
    800018dc:	00b60633          	add	a2,a2,a1
    800018e0:	fec53c23          	sd	a2,-8(a0)
        block->next = curr->next;
    800018e4:	0007b783          	ld	a5,0(a5)
    800018e8:	fef53823          	sd	a5,-16(a0)
        if (prev != nullptr) {
    800018ec:	00070863          	beqz	a4,800018fc <_ZN15MemoryAllocator4freeEPv+0xf8>
            prev->next = block;
    800018f0:	00d73023          	sd	a3,0(a4)
    return 0;
    800018f4:	00000513          	li	a0,0
    800018f8:	0380006f          	j	80001930 <_ZN15MemoryAllocator4freeEPv+0x12c>
            freeListHead = block;
    800018fc:	00003797          	auipc	a5,0x3
    80001900:	d4d7be23          	sd	a3,-676(a5) # 80004658 <_ZN15MemoryAllocator12freeListHeadE>
    return 0;
    80001904:	00000513          	li	a0,0
    80001908:	0280006f          	j	80001930 <_ZN15MemoryAllocator4freeEPv+0x12c>
        prev->size += block->size + curr->size;
    8000190c:	ff853683          	ld	a3,-8(a0)
    80001910:	0087b603          	ld	a2,8(a5)
    80001914:	00c68633          	add	a2,a3,a2
    80001918:	00873683          	ld	a3,8(a4)
    8000191c:	00c686b3          	add	a3,a3,a2
    80001920:	00d73423          	sd	a3,8(a4)
        prev->next = curr->next;
    80001924:	0007b783          	ld	a5,0(a5)
    80001928:	00f73023          	sd	a5,0(a4)
    return 0;
    8000192c:	00000513          	li	a0,0
}
    80001930:	00813403          	ld	s0,8(sp)
    80001934:	01010113          	addi	sp,sp,16
    80001938:	00008067          	ret
    if (ptr == nullptr) return -1;
    8000193c:	fff00513          	li	a0,-1
    80001940:	ff1ff06f          	j	80001930 <_ZN15MemoryAllocator4freeEPv+0x12c>

0000000080001944 <main>:

extern "C" void trapHandler();

void userMain();   // definisana u test fajlu

int main() {
    80001944:	fe010113          	addi	sp,sp,-32
    80001948:	00113c23          	sd	ra,24(sp)
    8000194c:	00813823          	sd	s0,16(sp)
    80001950:	00913423          	sd	s1,8(sp)
    80001954:	02010413          	addi	s0,sp,32
    kputs(">> kernel: starting\n");
    80001958:	00002517          	auipc	a0,0x2
    8000195c:	76050513          	addi	a0,a0,1888 # 800040b8 <CONSOLE_STATUS+0xa8>
    80001960:	fffff097          	auipc	ra,0xfffff
    80001964:	7c8080e7          	jalr	1992(ra) # 80001128 <_Z5kputsPKc>

    // stvec = adresa prekidne rutine: jedina kapija za ecall/izuzetke/prekide
    uint64 addr = (uint64)&trapHandler;
    80001968:	fffff797          	auipc	a5,0xfffff
    8000196c:	69878793          	addi	a5,a5,1688 # 80001000 <trapHandler>
    asm volatile("csrw stvec, %0" : : "r" (addr));
    80001970:	10579073          	csrw	stvec,a5

    // maskiraj prekide: sve radi u sistemskom rezimu, pa sstatus.sie=0
    // znaci "ne prekidaj me" (zahtevi se pamte u sip, ali ne stizu).
    // sret ovo ne kvari: sie<-spie, a spie je snimljena nula.
    uint64 sstatus;
    asm volatile("csrr %0, sstatus" : "=r"(sstatus));
    80001974:	100027f3          	csrr	a5,sstatus
    sstatus &= ~(1UL << 1);
    80001978:	ffd7f793          	andi	a5,a5,-3
    asm volatile("csrw sstatus, %0" : : "r"(sstatus));
    8000197c:	10079073          	csrw	sstatus,a5

    // dokaz da je maska stvarno upisana
    asm volatile("csrr %0, sstatus" : "=r"(sstatus));
    80001980:	100024f3          	csrr	s1,sstatus
    kputs(">> sstatus posle maske = "); kputhex(sstatus); kputs("\n");
    80001984:	00002517          	auipc	a0,0x2
    80001988:	74c50513          	addi	a0,a0,1868 # 800040d0 <CONSOLE_STATUS+0xc0>
    8000198c:	fffff097          	auipc	ra,0xfffff
    80001990:	79c080e7          	jalr	1948(ra) # 80001128 <_Z5kputsPKc>
    80001994:	00048513          	mv	a0,s1
    80001998:	fffff097          	auipc	ra,0xfffff
    8000199c:	7d4080e7          	jalr	2004(ra) # 8000116c <_Z7kputhexm>
    800019a0:	00003517          	auipc	a0,0x3
    800019a4:	88850513          	addi	a0,a0,-1912 # 80004228 <CONSOLE_STATUS+0x218>
    800019a8:	fffff097          	auipc	ra,0xfffff
    800019ac:	780080e7          	jalr	1920(ra) # 80001128 <_Z5kputsPKc>

    MemoryAllocator::init();
    800019b0:	00000097          	auipc	ra,0x0
    800019b4:	ccc080e7          	jalr	-820(ra) # 8000167c <_ZN15MemoryAllocator4initEv>

    userMain();    // privremeno: obican poziv funkcije; kasnije postaje
    800019b8:	00000097          	auipc	ra,0x0
    800019bc:	964080e7          	jalr	-1692(ra) # 8000131c <_Z8userMainv>
                   // telo prve niti koju pokrece jezgro

    kputs(">> kernel: userMain returned, halting\n");
    800019c0:	00002517          	auipc	a0,0x2
    800019c4:	73050513          	addi	a0,a0,1840 # 800040f0 <CONSOLE_STATUS+0xe0>
    800019c8:	fffff097          	auipc	ra,0xfffff
    800019cc:	760080e7          	jalr	1888(ra) # 80001128 <_Z5kputsPKc>

    // upis 0x5555 na 0x100000 gasi emulator (regularan kraj procesa)
    *(volatile int*)0x100000 = 0x5555;
    800019d0:	00100737          	lui	a4,0x100
    800019d4:	000057b7          	lui	a5,0x5
    800019d8:	5557879b          	addiw	a5,a5,1365
    800019dc:	00f72023          	sw	a5,0(a4) # 100000 <_entry-0x7ff00000>

    return 0;
}
    800019e0:	00000513          	li	a0,0
    800019e4:	01813083          	ld	ra,24(sp)
    800019e8:	01013403          	ld	s0,16(sp)
    800019ec:	00813483          	ld	s1,8(sp)
    800019f0:	02010113          	addi	sp,sp,32
    800019f4:	00008067          	ret

00000000800019f8 <start>:
    800019f8:	ff010113          	addi	sp,sp,-16
    800019fc:	00813423          	sd	s0,8(sp)
    80001a00:	01010413          	addi	s0,sp,16
    80001a04:	300027f3          	csrr	a5,mstatus
    80001a08:	ffffe737          	lui	a4,0xffffe
    80001a0c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fff8f1f>
    80001a10:	00e7f7b3          	and	a5,a5,a4
    80001a14:	00001737          	lui	a4,0x1
    80001a18:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80001a1c:	00e7e7b3          	or	a5,a5,a4
    80001a20:	30079073          	csrw	mstatus,a5
    80001a24:	00000797          	auipc	a5,0x0
    80001a28:	16078793          	addi	a5,a5,352 # 80001b84 <system_main>
    80001a2c:	34179073          	csrw	mepc,a5
    80001a30:	00000793          	li	a5,0
    80001a34:	18079073          	csrw	satp,a5
    80001a38:	000107b7          	lui	a5,0x10
    80001a3c:	fff78793          	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80001a40:	30279073          	csrw	medeleg,a5
    80001a44:	30379073          	csrw	mideleg,a5
    80001a48:	104027f3          	csrr	a5,sie
    80001a4c:	2227e793          	ori	a5,a5,546
    80001a50:	10479073          	csrw	sie,a5
    80001a54:	fff00793          	li	a5,-1
    80001a58:	00a7d793          	srli	a5,a5,0xa
    80001a5c:	3b079073          	csrw	pmpaddr0,a5
    80001a60:	00f00793          	li	a5,15
    80001a64:	3a079073          	csrw	pmpcfg0,a5
    80001a68:	f14027f3          	csrr	a5,mhartid
    80001a6c:	0200c737          	lui	a4,0x200c
    80001a70:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80001a74:	0007869b          	sext.w	a3,a5
    80001a78:	00269713          	slli	a4,a3,0x2
    80001a7c:	000f4637          	lui	a2,0xf4
    80001a80:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80001a84:	00d70733          	add	a4,a4,a3
    80001a88:	0037979b          	slliw	a5,a5,0x3
    80001a8c:	020046b7          	lui	a3,0x2004
    80001a90:	00d787b3          	add	a5,a5,a3
    80001a94:	00c585b3          	add	a1,a1,a2
    80001a98:	00371693          	slli	a3,a4,0x3
    80001a9c:	00003717          	auipc	a4,0x3
    80001aa0:	bf470713          	addi	a4,a4,-1036 # 80004690 <timer_scratch>
    80001aa4:	00b7b023          	sd	a1,0(a5)
    80001aa8:	00d70733          	add	a4,a4,a3
    80001aac:	00f73c23          	sd	a5,24(a4)
    80001ab0:	02c73023          	sd	a2,32(a4)
    80001ab4:	34071073          	csrw	mscratch,a4
    80001ab8:	00000797          	auipc	a5,0x0
    80001abc:	6e878793          	addi	a5,a5,1768 # 800021a0 <timervec>
    80001ac0:	30579073          	csrw	mtvec,a5
    80001ac4:	300027f3          	csrr	a5,mstatus
    80001ac8:	0087e793          	ori	a5,a5,8
    80001acc:	30079073          	csrw	mstatus,a5
    80001ad0:	304027f3          	csrr	a5,mie
    80001ad4:	0807e793          	ori	a5,a5,128
    80001ad8:	30479073          	csrw	mie,a5
    80001adc:	f14027f3          	csrr	a5,mhartid
    80001ae0:	0007879b          	sext.w	a5,a5
    80001ae4:	00078213          	mv	tp,a5
    80001ae8:	30200073          	mret
    80001aec:	00813403          	ld	s0,8(sp)
    80001af0:	01010113          	addi	sp,sp,16
    80001af4:	00008067          	ret

0000000080001af8 <timerinit>:
    80001af8:	ff010113          	addi	sp,sp,-16
    80001afc:	00813423          	sd	s0,8(sp)
    80001b00:	01010413          	addi	s0,sp,16
    80001b04:	f14027f3          	csrr	a5,mhartid
    80001b08:	0200c737          	lui	a4,0x200c
    80001b0c:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80001b10:	0007869b          	sext.w	a3,a5
    80001b14:	00269713          	slli	a4,a3,0x2
    80001b18:	000f4637          	lui	a2,0xf4
    80001b1c:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80001b20:	00d70733          	add	a4,a4,a3
    80001b24:	0037979b          	slliw	a5,a5,0x3
    80001b28:	020046b7          	lui	a3,0x2004
    80001b2c:	00d787b3          	add	a5,a5,a3
    80001b30:	00c585b3          	add	a1,a1,a2
    80001b34:	00371693          	slli	a3,a4,0x3
    80001b38:	00003717          	auipc	a4,0x3
    80001b3c:	b5870713          	addi	a4,a4,-1192 # 80004690 <timer_scratch>
    80001b40:	00b7b023          	sd	a1,0(a5)
    80001b44:	00d70733          	add	a4,a4,a3
    80001b48:	00f73c23          	sd	a5,24(a4)
    80001b4c:	02c73023          	sd	a2,32(a4)
    80001b50:	34071073          	csrw	mscratch,a4
    80001b54:	00000797          	auipc	a5,0x0
    80001b58:	64c78793          	addi	a5,a5,1612 # 800021a0 <timervec>
    80001b5c:	30579073          	csrw	mtvec,a5
    80001b60:	300027f3          	csrr	a5,mstatus
    80001b64:	0087e793          	ori	a5,a5,8
    80001b68:	30079073          	csrw	mstatus,a5
    80001b6c:	304027f3          	csrr	a5,mie
    80001b70:	0807e793          	ori	a5,a5,128
    80001b74:	30479073          	csrw	mie,a5
    80001b78:	00813403          	ld	s0,8(sp)
    80001b7c:	01010113          	addi	sp,sp,16
    80001b80:	00008067          	ret

0000000080001b84 <system_main>:
    80001b84:	fe010113          	addi	sp,sp,-32
    80001b88:	00813823          	sd	s0,16(sp)
    80001b8c:	00913423          	sd	s1,8(sp)
    80001b90:	00113c23          	sd	ra,24(sp)
    80001b94:	02010413          	addi	s0,sp,32
    80001b98:	00000097          	auipc	ra,0x0
    80001b9c:	0c4080e7          	jalr	196(ra) # 80001c5c <cpuid>
    80001ba0:	00003497          	auipc	s1,0x3
    80001ba4:	ac048493          	addi	s1,s1,-1344 # 80004660 <started>
    80001ba8:	02050263          	beqz	a0,80001bcc <system_main+0x48>
    80001bac:	0004a783          	lw	a5,0(s1)
    80001bb0:	0007879b          	sext.w	a5,a5
    80001bb4:	fe078ce3          	beqz	a5,80001bac <system_main+0x28>
    80001bb8:	0ff0000f          	fence
    80001bbc:	00002517          	auipc	a0,0x2
    80001bc0:	58c50513          	addi	a0,a0,1420 # 80004148 <CONSOLE_STATUS+0x138>
    80001bc4:	00001097          	auipc	ra,0x1
    80001bc8:	a78080e7          	jalr	-1416(ra) # 8000263c <panic>
    80001bcc:	00001097          	auipc	ra,0x1
    80001bd0:	9cc080e7          	jalr	-1588(ra) # 80002598 <consoleinit>
    80001bd4:	00001097          	auipc	ra,0x1
    80001bd8:	158080e7          	jalr	344(ra) # 80002d2c <printfinit>
    80001bdc:	00002517          	auipc	a0,0x2
    80001be0:	64c50513          	addi	a0,a0,1612 # 80004228 <CONSOLE_STATUS+0x218>
    80001be4:	00001097          	auipc	ra,0x1
    80001be8:	ab4080e7          	jalr	-1356(ra) # 80002698 <__printf>
    80001bec:	00002517          	auipc	a0,0x2
    80001bf0:	52c50513          	addi	a0,a0,1324 # 80004118 <CONSOLE_STATUS+0x108>
    80001bf4:	00001097          	auipc	ra,0x1
    80001bf8:	aa4080e7          	jalr	-1372(ra) # 80002698 <__printf>
    80001bfc:	00002517          	auipc	a0,0x2
    80001c00:	62c50513          	addi	a0,a0,1580 # 80004228 <CONSOLE_STATUS+0x218>
    80001c04:	00001097          	auipc	ra,0x1
    80001c08:	a94080e7          	jalr	-1388(ra) # 80002698 <__printf>
    80001c0c:	00001097          	auipc	ra,0x1
    80001c10:	4ac080e7          	jalr	1196(ra) # 800030b8 <kinit>
    80001c14:	00000097          	auipc	ra,0x0
    80001c18:	148080e7          	jalr	328(ra) # 80001d5c <trapinit>
    80001c1c:	00000097          	auipc	ra,0x0
    80001c20:	16c080e7          	jalr	364(ra) # 80001d88 <trapinithart>
    80001c24:	00000097          	auipc	ra,0x0
    80001c28:	5bc080e7          	jalr	1468(ra) # 800021e0 <plicinit>
    80001c2c:	00000097          	auipc	ra,0x0
    80001c30:	5dc080e7          	jalr	1500(ra) # 80002208 <plicinithart>
    80001c34:	00000097          	auipc	ra,0x0
    80001c38:	078080e7          	jalr	120(ra) # 80001cac <userinit>
    80001c3c:	0ff0000f          	fence
    80001c40:	00100793          	li	a5,1
    80001c44:	00002517          	auipc	a0,0x2
    80001c48:	4ec50513          	addi	a0,a0,1260 # 80004130 <CONSOLE_STATUS+0x120>
    80001c4c:	00f4a023          	sw	a5,0(s1)
    80001c50:	00001097          	auipc	ra,0x1
    80001c54:	a48080e7          	jalr	-1464(ra) # 80002698 <__printf>
    80001c58:	0000006f          	j	80001c58 <system_main+0xd4>

0000000080001c5c <cpuid>:
    80001c5c:	ff010113          	addi	sp,sp,-16
    80001c60:	00813423          	sd	s0,8(sp)
    80001c64:	01010413          	addi	s0,sp,16
    80001c68:	00020513          	mv	a0,tp
    80001c6c:	00813403          	ld	s0,8(sp)
    80001c70:	0005051b          	sext.w	a0,a0
    80001c74:	01010113          	addi	sp,sp,16
    80001c78:	00008067          	ret

0000000080001c7c <mycpu>:
    80001c7c:	ff010113          	addi	sp,sp,-16
    80001c80:	00813423          	sd	s0,8(sp)
    80001c84:	01010413          	addi	s0,sp,16
    80001c88:	00020793          	mv	a5,tp
    80001c8c:	00813403          	ld	s0,8(sp)
    80001c90:	0007879b          	sext.w	a5,a5
    80001c94:	00779793          	slli	a5,a5,0x7
    80001c98:	00004517          	auipc	a0,0x4
    80001c9c:	a2850513          	addi	a0,a0,-1496 # 800056c0 <cpus>
    80001ca0:	00f50533          	add	a0,a0,a5
    80001ca4:	01010113          	addi	sp,sp,16
    80001ca8:	00008067          	ret

0000000080001cac <userinit>:
    80001cac:	ff010113          	addi	sp,sp,-16
    80001cb0:	00813423          	sd	s0,8(sp)
    80001cb4:	01010413          	addi	s0,sp,16
    80001cb8:	00813403          	ld	s0,8(sp)
    80001cbc:	01010113          	addi	sp,sp,16
    80001cc0:	00000317          	auipc	t1,0x0
    80001cc4:	c8430067          	jr	-892(t1) # 80001944 <main>

0000000080001cc8 <either_copyout>:
    80001cc8:	ff010113          	addi	sp,sp,-16
    80001ccc:	00813023          	sd	s0,0(sp)
    80001cd0:	00113423          	sd	ra,8(sp)
    80001cd4:	01010413          	addi	s0,sp,16
    80001cd8:	02051663          	bnez	a0,80001d04 <either_copyout+0x3c>
    80001cdc:	00058513          	mv	a0,a1
    80001ce0:	00060593          	mv	a1,a2
    80001ce4:	0006861b          	sext.w	a2,a3
    80001ce8:	00002097          	auipc	ra,0x2
    80001cec:	c5c080e7          	jalr	-932(ra) # 80003944 <__memmove>
    80001cf0:	00813083          	ld	ra,8(sp)
    80001cf4:	00013403          	ld	s0,0(sp)
    80001cf8:	00000513          	li	a0,0
    80001cfc:	01010113          	addi	sp,sp,16
    80001d00:	00008067          	ret
    80001d04:	00002517          	auipc	a0,0x2
    80001d08:	46c50513          	addi	a0,a0,1132 # 80004170 <CONSOLE_STATUS+0x160>
    80001d0c:	00001097          	auipc	ra,0x1
    80001d10:	930080e7          	jalr	-1744(ra) # 8000263c <panic>

0000000080001d14 <either_copyin>:
    80001d14:	ff010113          	addi	sp,sp,-16
    80001d18:	00813023          	sd	s0,0(sp)
    80001d1c:	00113423          	sd	ra,8(sp)
    80001d20:	01010413          	addi	s0,sp,16
    80001d24:	02059463          	bnez	a1,80001d4c <either_copyin+0x38>
    80001d28:	00060593          	mv	a1,a2
    80001d2c:	0006861b          	sext.w	a2,a3
    80001d30:	00002097          	auipc	ra,0x2
    80001d34:	c14080e7          	jalr	-1004(ra) # 80003944 <__memmove>
    80001d38:	00813083          	ld	ra,8(sp)
    80001d3c:	00013403          	ld	s0,0(sp)
    80001d40:	00000513          	li	a0,0
    80001d44:	01010113          	addi	sp,sp,16
    80001d48:	00008067          	ret
    80001d4c:	00002517          	auipc	a0,0x2
    80001d50:	44c50513          	addi	a0,a0,1100 # 80004198 <CONSOLE_STATUS+0x188>
    80001d54:	00001097          	auipc	ra,0x1
    80001d58:	8e8080e7          	jalr	-1816(ra) # 8000263c <panic>

0000000080001d5c <trapinit>:
    80001d5c:	ff010113          	addi	sp,sp,-16
    80001d60:	00813423          	sd	s0,8(sp)
    80001d64:	01010413          	addi	s0,sp,16
    80001d68:	00813403          	ld	s0,8(sp)
    80001d6c:	00002597          	auipc	a1,0x2
    80001d70:	45458593          	addi	a1,a1,1108 # 800041c0 <CONSOLE_STATUS+0x1b0>
    80001d74:	00004517          	auipc	a0,0x4
    80001d78:	9cc50513          	addi	a0,a0,-1588 # 80005740 <tickslock>
    80001d7c:	01010113          	addi	sp,sp,16
    80001d80:	00001317          	auipc	t1,0x1
    80001d84:	5c830067          	jr	1480(t1) # 80003348 <initlock>

0000000080001d88 <trapinithart>:
    80001d88:	ff010113          	addi	sp,sp,-16
    80001d8c:	00813423          	sd	s0,8(sp)
    80001d90:	01010413          	addi	s0,sp,16
    80001d94:	00000797          	auipc	a5,0x0
    80001d98:	2fc78793          	addi	a5,a5,764 # 80002090 <kernelvec>
    80001d9c:	10579073          	csrw	stvec,a5
    80001da0:	00813403          	ld	s0,8(sp)
    80001da4:	01010113          	addi	sp,sp,16
    80001da8:	00008067          	ret

0000000080001dac <usertrap>:
    80001dac:	ff010113          	addi	sp,sp,-16
    80001db0:	00813423          	sd	s0,8(sp)
    80001db4:	01010413          	addi	s0,sp,16
    80001db8:	00813403          	ld	s0,8(sp)
    80001dbc:	01010113          	addi	sp,sp,16
    80001dc0:	00008067          	ret

0000000080001dc4 <usertrapret>:
    80001dc4:	ff010113          	addi	sp,sp,-16
    80001dc8:	00813423          	sd	s0,8(sp)
    80001dcc:	01010413          	addi	s0,sp,16
    80001dd0:	00813403          	ld	s0,8(sp)
    80001dd4:	01010113          	addi	sp,sp,16
    80001dd8:	00008067          	ret

0000000080001ddc <kerneltrap>:
    80001ddc:	fe010113          	addi	sp,sp,-32
    80001de0:	00813823          	sd	s0,16(sp)
    80001de4:	00113c23          	sd	ra,24(sp)
    80001de8:	00913423          	sd	s1,8(sp)
    80001dec:	02010413          	addi	s0,sp,32
    80001df0:	142025f3          	csrr	a1,scause
    80001df4:	100027f3          	csrr	a5,sstatus
    80001df8:	0027f793          	andi	a5,a5,2
    80001dfc:	10079c63          	bnez	a5,80001f14 <kerneltrap+0x138>
    80001e00:	142027f3          	csrr	a5,scause
    80001e04:	0207ce63          	bltz	a5,80001e40 <kerneltrap+0x64>
    80001e08:	00002517          	auipc	a0,0x2
    80001e0c:	40050513          	addi	a0,a0,1024 # 80004208 <CONSOLE_STATUS+0x1f8>
    80001e10:	00001097          	auipc	ra,0x1
    80001e14:	888080e7          	jalr	-1912(ra) # 80002698 <__printf>
    80001e18:	141025f3          	csrr	a1,sepc
    80001e1c:	14302673          	csrr	a2,stval
    80001e20:	00002517          	auipc	a0,0x2
    80001e24:	3f850513          	addi	a0,a0,1016 # 80004218 <CONSOLE_STATUS+0x208>
    80001e28:	00001097          	auipc	ra,0x1
    80001e2c:	870080e7          	jalr	-1936(ra) # 80002698 <__printf>
    80001e30:	00002517          	auipc	a0,0x2
    80001e34:	40050513          	addi	a0,a0,1024 # 80004230 <CONSOLE_STATUS+0x220>
    80001e38:	00001097          	auipc	ra,0x1
    80001e3c:	804080e7          	jalr	-2044(ra) # 8000263c <panic>
    80001e40:	0ff7f713          	andi	a4,a5,255
    80001e44:	00900693          	li	a3,9
    80001e48:	04d70063          	beq	a4,a3,80001e88 <kerneltrap+0xac>
    80001e4c:	fff00713          	li	a4,-1
    80001e50:	03f71713          	slli	a4,a4,0x3f
    80001e54:	00170713          	addi	a4,a4,1
    80001e58:	fae798e3          	bne	a5,a4,80001e08 <kerneltrap+0x2c>
    80001e5c:	00000097          	auipc	ra,0x0
    80001e60:	e00080e7          	jalr	-512(ra) # 80001c5c <cpuid>
    80001e64:	06050663          	beqz	a0,80001ed0 <kerneltrap+0xf4>
    80001e68:	144027f3          	csrr	a5,sip
    80001e6c:	ffd7f793          	andi	a5,a5,-3
    80001e70:	14479073          	csrw	sip,a5
    80001e74:	01813083          	ld	ra,24(sp)
    80001e78:	01013403          	ld	s0,16(sp)
    80001e7c:	00813483          	ld	s1,8(sp)
    80001e80:	02010113          	addi	sp,sp,32
    80001e84:	00008067          	ret
    80001e88:	00000097          	auipc	ra,0x0
    80001e8c:	3cc080e7          	jalr	972(ra) # 80002254 <plic_claim>
    80001e90:	00a00793          	li	a5,10
    80001e94:	00050493          	mv	s1,a0
    80001e98:	06f50863          	beq	a0,a5,80001f08 <kerneltrap+0x12c>
    80001e9c:	fc050ce3          	beqz	a0,80001e74 <kerneltrap+0x98>
    80001ea0:	00050593          	mv	a1,a0
    80001ea4:	00002517          	auipc	a0,0x2
    80001ea8:	34450513          	addi	a0,a0,836 # 800041e8 <CONSOLE_STATUS+0x1d8>
    80001eac:	00000097          	auipc	ra,0x0
    80001eb0:	7ec080e7          	jalr	2028(ra) # 80002698 <__printf>
    80001eb4:	01013403          	ld	s0,16(sp)
    80001eb8:	01813083          	ld	ra,24(sp)
    80001ebc:	00048513          	mv	a0,s1
    80001ec0:	00813483          	ld	s1,8(sp)
    80001ec4:	02010113          	addi	sp,sp,32
    80001ec8:	00000317          	auipc	t1,0x0
    80001ecc:	3c430067          	jr	964(t1) # 8000228c <plic_complete>
    80001ed0:	00004517          	auipc	a0,0x4
    80001ed4:	87050513          	addi	a0,a0,-1936 # 80005740 <tickslock>
    80001ed8:	00001097          	auipc	ra,0x1
    80001edc:	494080e7          	jalr	1172(ra) # 8000336c <acquire>
    80001ee0:	00002717          	auipc	a4,0x2
    80001ee4:	78470713          	addi	a4,a4,1924 # 80004664 <ticks>
    80001ee8:	00072783          	lw	a5,0(a4)
    80001eec:	00004517          	auipc	a0,0x4
    80001ef0:	85450513          	addi	a0,a0,-1964 # 80005740 <tickslock>
    80001ef4:	0017879b          	addiw	a5,a5,1
    80001ef8:	00f72023          	sw	a5,0(a4)
    80001efc:	00001097          	auipc	ra,0x1
    80001f00:	53c080e7          	jalr	1340(ra) # 80003438 <release>
    80001f04:	f65ff06f          	j	80001e68 <kerneltrap+0x8c>
    80001f08:	00001097          	auipc	ra,0x1
    80001f0c:	098080e7          	jalr	152(ra) # 80002fa0 <uartintr>
    80001f10:	fa5ff06f          	j	80001eb4 <kerneltrap+0xd8>
    80001f14:	00002517          	auipc	a0,0x2
    80001f18:	2b450513          	addi	a0,a0,692 # 800041c8 <CONSOLE_STATUS+0x1b8>
    80001f1c:	00000097          	auipc	ra,0x0
    80001f20:	720080e7          	jalr	1824(ra) # 8000263c <panic>

0000000080001f24 <clockintr>:
    80001f24:	fe010113          	addi	sp,sp,-32
    80001f28:	00813823          	sd	s0,16(sp)
    80001f2c:	00913423          	sd	s1,8(sp)
    80001f30:	00113c23          	sd	ra,24(sp)
    80001f34:	02010413          	addi	s0,sp,32
    80001f38:	00004497          	auipc	s1,0x4
    80001f3c:	80848493          	addi	s1,s1,-2040 # 80005740 <tickslock>
    80001f40:	00048513          	mv	a0,s1
    80001f44:	00001097          	auipc	ra,0x1
    80001f48:	428080e7          	jalr	1064(ra) # 8000336c <acquire>
    80001f4c:	00002717          	auipc	a4,0x2
    80001f50:	71870713          	addi	a4,a4,1816 # 80004664 <ticks>
    80001f54:	00072783          	lw	a5,0(a4)
    80001f58:	01013403          	ld	s0,16(sp)
    80001f5c:	01813083          	ld	ra,24(sp)
    80001f60:	00048513          	mv	a0,s1
    80001f64:	0017879b          	addiw	a5,a5,1
    80001f68:	00813483          	ld	s1,8(sp)
    80001f6c:	00f72023          	sw	a5,0(a4)
    80001f70:	02010113          	addi	sp,sp,32
    80001f74:	00001317          	auipc	t1,0x1
    80001f78:	4c430067          	jr	1220(t1) # 80003438 <release>

0000000080001f7c <devintr>:
    80001f7c:	142027f3          	csrr	a5,scause
    80001f80:	00000513          	li	a0,0
    80001f84:	0007c463          	bltz	a5,80001f8c <devintr+0x10>
    80001f88:	00008067          	ret
    80001f8c:	fe010113          	addi	sp,sp,-32
    80001f90:	00813823          	sd	s0,16(sp)
    80001f94:	00113c23          	sd	ra,24(sp)
    80001f98:	00913423          	sd	s1,8(sp)
    80001f9c:	02010413          	addi	s0,sp,32
    80001fa0:	0ff7f713          	andi	a4,a5,255
    80001fa4:	00900693          	li	a3,9
    80001fa8:	04d70c63          	beq	a4,a3,80002000 <devintr+0x84>
    80001fac:	fff00713          	li	a4,-1
    80001fb0:	03f71713          	slli	a4,a4,0x3f
    80001fb4:	00170713          	addi	a4,a4,1
    80001fb8:	00e78c63          	beq	a5,a4,80001fd0 <devintr+0x54>
    80001fbc:	01813083          	ld	ra,24(sp)
    80001fc0:	01013403          	ld	s0,16(sp)
    80001fc4:	00813483          	ld	s1,8(sp)
    80001fc8:	02010113          	addi	sp,sp,32
    80001fcc:	00008067          	ret
    80001fd0:	00000097          	auipc	ra,0x0
    80001fd4:	c8c080e7          	jalr	-884(ra) # 80001c5c <cpuid>
    80001fd8:	06050663          	beqz	a0,80002044 <devintr+0xc8>
    80001fdc:	144027f3          	csrr	a5,sip
    80001fe0:	ffd7f793          	andi	a5,a5,-3
    80001fe4:	14479073          	csrw	sip,a5
    80001fe8:	01813083          	ld	ra,24(sp)
    80001fec:	01013403          	ld	s0,16(sp)
    80001ff0:	00813483          	ld	s1,8(sp)
    80001ff4:	00200513          	li	a0,2
    80001ff8:	02010113          	addi	sp,sp,32
    80001ffc:	00008067          	ret
    80002000:	00000097          	auipc	ra,0x0
    80002004:	254080e7          	jalr	596(ra) # 80002254 <plic_claim>
    80002008:	00a00793          	li	a5,10
    8000200c:	00050493          	mv	s1,a0
    80002010:	06f50663          	beq	a0,a5,8000207c <devintr+0x100>
    80002014:	00100513          	li	a0,1
    80002018:	fa0482e3          	beqz	s1,80001fbc <devintr+0x40>
    8000201c:	00048593          	mv	a1,s1
    80002020:	00002517          	auipc	a0,0x2
    80002024:	1c850513          	addi	a0,a0,456 # 800041e8 <CONSOLE_STATUS+0x1d8>
    80002028:	00000097          	auipc	ra,0x0
    8000202c:	670080e7          	jalr	1648(ra) # 80002698 <__printf>
    80002030:	00048513          	mv	a0,s1
    80002034:	00000097          	auipc	ra,0x0
    80002038:	258080e7          	jalr	600(ra) # 8000228c <plic_complete>
    8000203c:	00100513          	li	a0,1
    80002040:	f7dff06f          	j	80001fbc <devintr+0x40>
    80002044:	00003517          	auipc	a0,0x3
    80002048:	6fc50513          	addi	a0,a0,1788 # 80005740 <tickslock>
    8000204c:	00001097          	auipc	ra,0x1
    80002050:	320080e7          	jalr	800(ra) # 8000336c <acquire>
    80002054:	00002717          	auipc	a4,0x2
    80002058:	61070713          	addi	a4,a4,1552 # 80004664 <ticks>
    8000205c:	00072783          	lw	a5,0(a4)
    80002060:	00003517          	auipc	a0,0x3
    80002064:	6e050513          	addi	a0,a0,1760 # 80005740 <tickslock>
    80002068:	0017879b          	addiw	a5,a5,1
    8000206c:	00f72023          	sw	a5,0(a4)
    80002070:	00001097          	auipc	ra,0x1
    80002074:	3c8080e7          	jalr	968(ra) # 80003438 <release>
    80002078:	f65ff06f          	j	80001fdc <devintr+0x60>
    8000207c:	00001097          	auipc	ra,0x1
    80002080:	f24080e7          	jalr	-220(ra) # 80002fa0 <uartintr>
    80002084:	fadff06f          	j	80002030 <devintr+0xb4>
	...

0000000080002090 <kernelvec>:
    80002090:	f0010113          	addi	sp,sp,-256
    80002094:	00113023          	sd	ra,0(sp)
    80002098:	00213423          	sd	sp,8(sp)
    8000209c:	00313823          	sd	gp,16(sp)
    800020a0:	00413c23          	sd	tp,24(sp)
    800020a4:	02513023          	sd	t0,32(sp)
    800020a8:	02613423          	sd	t1,40(sp)
    800020ac:	02713823          	sd	t2,48(sp)
    800020b0:	02813c23          	sd	s0,56(sp)
    800020b4:	04913023          	sd	s1,64(sp)
    800020b8:	04a13423          	sd	a0,72(sp)
    800020bc:	04b13823          	sd	a1,80(sp)
    800020c0:	04c13c23          	sd	a2,88(sp)
    800020c4:	06d13023          	sd	a3,96(sp)
    800020c8:	06e13423          	sd	a4,104(sp)
    800020cc:	06f13823          	sd	a5,112(sp)
    800020d0:	07013c23          	sd	a6,120(sp)
    800020d4:	09113023          	sd	a7,128(sp)
    800020d8:	09213423          	sd	s2,136(sp)
    800020dc:	09313823          	sd	s3,144(sp)
    800020e0:	09413c23          	sd	s4,152(sp)
    800020e4:	0b513023          	sd	s5,160(sp)
    800020e8:	0b613423          	sd	s6,168(sp)
    800020ec:	0b713823          	sd	s7,176(sp)
    800020f0:	0b813c23          	sd	s8,184(sp)
    800020f4:	0d913023          	sd	s9,192(sp)
    800020f8:	0da13423          	sd	s10,200(sp)
    800020fc:	0db13823          	sd	s11,208(sp)
    80002100:	0dc13c23          	sd	t3,216(sp)
    80002104:	0fd13023          	sd	t4,224(sp)
    80002108:	0fe13423          	sd	t5,232(sp)
    8000210c:	0ff13823          	sd	t6,240(sp)
    80002110:	ccdff0ef          	jal	ra,80001ddc <kerneltrap>
    80002114:	00013083          	ld	ra,0(sp)
    80002118:	00813103          	ld	sp,8(sp)
    8000211c:	01013183          	ld	gp,16(sp)
    80002120:	02013283          	ld	t0,32(sp)
    80002124:	02813303          	ld	t1,40(sp)
    80002128:	03013383          	ld	t2,48(sp)
    8000212c:	03813403          	ld	s0,56(sp)
    80002130:	04013483          	ld	s1,64(sp)
    80002134:	04813503          	ld	a0,72(sp)
    80002138:	05013583          	ld	a1,80(sp)
    8000213c:	05813603          	ld	a2,88(sp)
    80002140:	06013683          	ld	a3,96(sp)
    80002144:	06813703          	ld	a4,104(sp)
    80002148:	07013783          	ld	a5,112(sp)
    8000214c:	07813803          	ld	a6,120(sp)
    80002150:	08013883          	ld	a7,128(sp)
    80002154:	08813903          	ld	s2,136(sp)
    80002158:	09013983          	ld	s3,144(sp)
    8000215c:	09813a03          	ld	s4,152(sp)
    80002160:	0a013a83          	ld	s5,160(sp)
    80002164:	0a813b03          	ld	s6,168(sp)
    80002168:	0b013b83          	ld	s7,176(sp)
    8000216c:	0b813c03          	ld	s8,184(sp)
    80002170:	0c013c83          	ld	s9,192(sp)
    80002174:	0c813d03          	ld	s10,200(sp)
    80002178:	0d013d83          	ld	s11,208(sp)
    8000217c:	0d813e03          	ld	t3,216(sp)
    80002180:	0e013e83          	ld	t4,224(sp)
    80002184:	0e813f03          	ld	t5,232(sp)
    80002188:	0f013f83          	ld	t6,240(sp)
    8000218c:	10010113          	addi	sp,sp,256
    80002190:	10200073          	sret
    80002194:	00000013          	nop
    80002198:	00000013          	nop
    8000219c:	00000013          	nop

00000000800021a0 <timervec>:
    800021a0:	34051573          	csrrw	a0,mscratch,a0
    800021a4:	00b53023          	sd	a1,0(a0)
    800021a8:	00c53423          	sd	a2,8(a0)
    800021ac:	00d53823          	sd	a3,16(a0)
    800021b0:	01853583          	ld	a1,24(a0)
    800021b4:	02053603          	ld	a2,32(a0)
    800021b8:	0005b683          	ld	a3,0(a1)
    800021bc:	00c686b3          	add	a3,a3,a2
    800021c0:	00d5b023          	sd	a3,0(a1)
    800021c4:	00200593          	li	a1,2
    800021c8:	14459073          	csrw	sip,a1
    800021cc:	01053683          	ld	a3,16(a0)
    800021d0:	00853603          	ld	a2,8(a0)
    800021d4:	00053583          	ld	a1,0(a0)
    800021d8:	34051573          	csrrw	a0,mscratch,a0
    800021dc:	30200073          	mret

00000000800021e0 <plicinit>:
    800021e0:	ff010113          	addi	sp,sp,-16
    800021e4:	00813423          	sd	s0,8(sp)
    800021e8:	01010413          	addi	s0,sp,16
    800021ec:	00813403          	ld	s0,8(sp)
    800021f0:	0c0007b7          	lui	a5,0xc000
    800021f4:	00100713          	li	a4,1
    800021f8:	02e7a423          	sw	a4,40(a5) # c000028 <_entry-0x73ffffd8>
    800021fc:	00e7a223          	sw	a4,4(a5)
    80002200:	01010113          	addi	sp,sp,16
    80002204:	00008067          	ret

0000000080002208 <plicinithart>:
    80002208:	ff010113          	addi	sp,sp,-16
    8000220c:	00813023          	sd	s0,0(sp)
    80002210:	00113423          	sd	ra,8(sp)
    80002214:	01010413          	addi	s0,sp,16
    80002218:	00000097          	auipc	ra,0x0
    8000221c:	a44080e7          	jalr	-1468(ra) # 80001c5c <cpuid>
    80002220:	0085171b          	slliw	a4,a0,0x8
    80002224:	0c0027b7          	lui	a5,0xc002
    80002228:	00e787b3          	add	a5,a5,a4
    8000222c:	40200713          	li	a4,1026
    80002230:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>
    80002234:	00813083          	ld	ra,8(sp)
    80002238:	00013403          	ld	s0,0(sp)
    8000223c:	00d5151b          	slliw	a0,a0,0xd
    80002240:	0c2017b7          	lui	a5,0xc201
    80002244:	00a78533          	add	a0,a5,a0
    80002248:	00052023          	sw	zero,0(a0)
    8000224c:	01010113          	addi	sp,sp,16
    80002250:	00008067          	ret

0000000080002254 <plic_claim>:
    80002254:	ff010113          	addi	sp,sp,-16
    80002258:	00813023          	sd	s0,0(sp)
    8000225c:	00113423          	sd	ra,8(sp)
    80002260:	01010413          	addi	s0,sp,16
    80002264:	00000097          	auipc	ra,0x0
    80002268:	9f8080e7          	jalr	-1544(ra) # 80001c5c <cpuid>
    8000226c:	00813083          	ld	ra,8(sp)
    80002270:	00013403          	ld	s0,0(sp)
    80002274:	00d5151b          	slliw	a0,a0,0xd
    80002278:	0c2017b7          	lui	a5,0xc201
    8000227c:	00a78533          	add	a0,a5,a0
    80002280:	00452503          	lw	a0,4(a0)
    80002284:	01010113          	addi	sp,sp,16
    80002288:	00008067          	ret

000000008000228c <plic_complete>:
    8000228c:	fe010113          	addi	sp,sp,-32
    80002290:	00813823          	sd	s0,16(sp)
    80002294:	00913423          	sd	s1,8(sp)
    80002298:	00113c23          	sd	ra,24(sp)
    8000229c:	02010413          	addi	s0,sp,32
    800022a0:	00050493          	mv	s1,a0
    800022a4:	00000097          	auipc	ra,0x0
    800022a8:	9b8080e7          	jalr	-1608(ra) # 80001c5c <cpuid>
    800022ac:	01813083          	ld	ra,24(sp)
    800022b0:	01013403          	ld	s0,16(sp)
    800022b4:	00d5179b          	slliw	a5,a0,0xd
    800022b8:	0c201737          	lui	a4,0xc201
    800022bc:	00f707b3          	add	a5,a4,a5
    800022c0:	0097a223          	sw	s1,4(a5) # c201004 <_entry-0x73dfeffc>
    800022c4:	00813483          	ld	s1,8(sp)
    800022c8:	02010113          	addi	sp,sp,32
    800022cc:	00008067          	ret

00000000800022d0 <consolewrite>:
    800022d0:	fb010113          	addi	sp,sp,-80
    800022d4:	04813023          	sd	s0,64(sp)
    800022d8:	04113423          	sd	ra,72(sp)
    800022dc:	02913c23          	sd	s1,56(sp)
    800022e0:	03213823          	sd	s2,48(sp)
    800022e4:	03313423          	sd	s3,40(sp)
    800022e8:	03413023          	sd	s4,32(sp)
    800022ec:	01513c23          	sd	s5,24(sp)
    800022f0:	05010413          	addi	s0,sp,80
    800022f4:	06c05c63          	blez	a2,8000236c <consolewrite+0x9c>
    800022f8:	00060993          	mv	s3,a2
    800022fc:	00050a13          	mv	s4,a0
    80002300:	00058493          	mv	s1,a1
    80002304:	00000913          	li	s2,0
    80002308:	fff00a93          	li	s5,-1
    8000230c:	01c0006f          	j	80002328 <consolewrite+0x58>
    80002310:	fbf44503          	lbu	a0,-65(s0)
    80002314:	0019091b          	addiw	s2,s2,1
    80002318:	00148493          	addi	s1,s1,1
    8000231c:	00001097          	auipc	ra,0x1
    80002320:	a9c080e7          	jalr	-1380(ra) # 80002db8 <uartputc>
    80002324:	03298063          	beq	s3,s2,80002344 <consolewrite+0x74>
    80002328:	00048613          	mv	a2,s1
    8000232c:	00100693          	li	a3,1
    80002330:	000a0593          	mv	a1,s4
    80002334:	fbf40513          	addi	a0,s0,-65
    80002338:	00000097          	auipc	ra,0x0
    8000233c:	9dc080e7          	jalr	-1572(ra) # 80001d14 <either_copyin>
    80002340:	fd5518e3          	bne	a0,s5,80002310 <consolewrite+0x40>
    80002344:	04813083          	ld	ra,72(sp)
    80002348:	04013403          	ld	s0,64(sp)
    8000234c:	03813483          	ld	s1,56(sp)
    80002350:	02813983          	ld	s3,40(sp)
    80002354:	02013a03          	ld	s4,32(sp)
    80002358:	01813a83          	ld	s5,24(sp)
    8000235c:	00090513          	mv	a0,s2
    80002360:	03013903          	ld	s2,48(sp)
    80002364:	05010113          	addi	sp,sp,80
    80002368:	00008067          	ret
    8000236c:	00000913          	li	s2,0
    80002370:	fd5ff06f          	j	80002344 <consolewrite+0x74>

0000000080002374 <consoleread>:
    80002374:	f9010113          	addi	sp,sp,-112
    80002378:	06813023          	sd	s0,96(sp)
    8000237c:	04913c23          	sd	s1,88(sp)
    80002380:	05213823          	sd	s2,80(sp)
    80002384:	05313423          	sd	s3,72(sp)
    80002388:	05413023          	sd	s4,64(sp)
    8000238c:	03513c23          	sd	s5,56(sp)
    80002390:	03613823          	sd	s6,48(sp)
    80002394:	03713423          	sd	s7,40(sp)
    80002398:	03813023          	sd	s8,32(sp)
    8000239c:	06113423          	sd	ra,104(sp)
    800023a0:	01913c23          	sd	s9,24(sp)
    800023a4:	07010413          	addi	s0,sp,112
    800023a8:	00060b93          	mv	s7,a2
    800023ac:	00050913          	mv	s2,a0
    800023b0:	00058c13          	mv	s8,a1
    800023b4:	00060b1b          	sext.w	s6,a2
    800023b8:	00003497          	auipc	s1,0x3
    800023bc:	3a048493          	addi	s1,s1,928 # 80005758 <cons>
    800023c0:	00400993          	li	s3,4
    800023c4:	fff00a13          	li	s4,-1
    800023c8:	00a00a93          	li	s5,10
    800023cc:	05705e63          	blez	s7,80002428 <consoleread+0xb4>
    800023d0:	09c4a703          	lw	a4,156(s1)
    800023d4:	0984a783          	lw	a5,152(s1)
    800023d8:	0007071b          	sext.w	a4,a4
    800023dc:	08e78463          	beq	a5,a4,80002464 <consoleread+0xf0>
    800023e0:	07f7f713          	andi	a4,a5,127
    800023e4:	00e48733          	add	a4,s1,a4
    800023e8:	01874703          	lbu	a4,24(a4) # c201018 <_entry-0x73dfefe8>
    800023ec:	0017869b          	addiw	a3,a5,1
    800023f0:	08d4ac23          	sw	a3,152(s1)
    800023f4:	00070c9b          	sext.w	s9,a4
    800023f8:	0b370663          	beq	a4,s3,800024a4 <consoleread+0x130>
    800023fc:	00100693          	li	a3,1
    80002400:	f9f40613          	addi	a2,s0,-97
    80002404:	000c0593          	mv	a1,s8
    80002408:	00090513          	mv	a0,s2
    8000240c:	f8e40fa3          	sb	a4,-97(s0)
    80002410:	00000097          	auipc	ra,0x0
    80002414:	8b8080e7          	jalr	-1864(ra) # 80001cc8 <either_copyout>
    80002418:	01450863          	beq	a0,s4,80002428 <consoleread+0xb4>
    8000241c:	001c0c13          	addi	s8,s8,1
    80002420:	fffb8b9b          	addiw	s7,s7,-1
    80002424:	fb5c94e3          	bne	s9,s5,800023cc <consoleread+0x58>
    80002428:	000b851b          	sext.w	a0,s7
    8000242c:	06813083          	ld	ra,104(sp)
    80002430:	06013403          	ld	s0,96(sp)
    80002434:	05813483          	ld	s1,88(sp)
    80002438:	05013903          	ld	s2,80(sp)
    8000243c:	04813983          	ld	s3,72(sp)
    80002440:	04013a03          	ld	s4,64(sp)
    80002444:	03813a83          	ld	s5,56(sp)
    80002448:	02813b83          	ld	s7,40(sp)
    8000244c:	02013c03          	ld	s8,32(sp)
    80002450:	01813c83          	ld	s9,24(sp)
    80002454:	40ab053b          	subw	a0,s6,a0
    80002458:	03013b03          	ld	s6,48(sp)
    8000245c:	07010113          	addi	sp,sp,112
    80002460:	00008067          	ret
    80002464:	00001097          	auipc	ra,0x1
    80002468:	1d8080e7          	jalr	472(ra) # 8000363c <push_on>
    8000246c:	0984a703          	lw	a4,152(s1)
    80002470:	09c4a783          	lw	a5,156(s1)
    80002474:	0007879b          	sext.w	a5,a5
    80002478:	fef70ce3          	beq	a4,a5,80002470 <consoleread+0xfc>
    8000247c:	00001097          	auipc	ra,0x1
    80002480:	234080e7          	jalr	564(ra) # 800036b0 <pop_on>
    80002484:	0984a783          	lw	a5,152(s1)
    80002488:	07f7f713          	andi	a4,a5,127
    8000248c:	00e48733          	add	a4,s1,a4
    80002490:	01874703          	lbu	a4,24(a4)
    80002494:	0017869b          	addiw	a3,a5,1
    80002498:	08d4ac23          	sw	a3,152(s1)
    8000249c:	00070c9b          	sext.w	s9,a4
    800024a0:	f5371ee3          	bne	a4,s3,800023fc <consoleread+0x88>
    800024a4:	000b851b          	sext.w	a0,s7
    800024a8:	f96bf2e3          	bgeu	s7,s6,8000242c <consoleread+0xb8>
    800024ac:	08f4ac23          	sw	a5,152(s1)
    800024b0:	f7dff06f          	j	8000242c <consoleread+0xb8>

00000000800024b4 <consputc>:
    800024b4:	10000793          	li	a5,256
    800024b8:	00f50663          	beq	a0,a5,800024c4 <consputc+0x10>
    800024bc:	00001317          	auipc	t1,0x1
    800024c0:	9f430067          	jr	-1548(t1) # 80002eb0 <uartputc_sync>
    800024c4:	ff010113          	addi	sp,sp,-16
    800024c8:	00113423          	sd	ra,8(sp)
    800024cc:	00813023          	sd	s0,0(sp)
    800024d0:	01010413          	addi	s0,sp,16
    800024d4:	00800513          	li	a0,8
    800024d8:	00001097          	auipc	ra,0x1
    800024dc:	9d8080e7          	jalr	-1576(ra) # 80002eb0 <uartputc_sync>
    800024e0:	02000513          	li	a0,32
    800024e4:	00001097          	auipc	ra,0x1
    800024e8:	9cc080e7          	jalr	-1588(ra) # 80002eb0 <uartputc_sync>
    800024ec:	00013403          	ld	s0,0(sp)
    800024f0:	00813083          	ld	ra,8(sp)
    800024f4:	00800513          	li	a0,8
    800024f8:	01010113          	addi	sp,sp,16
    800024fc:	00001317          	auipc	t1,0x1
    80002500:	9b430067          	jr	-1612(t1) # 80002eb0 <uartputc_sync>

0000000080002504 <consoleintr>:
    80002504:	fe010113          	addi	sp,sp,-32
    80002508:	00813823          	sd	s0,16(sp)
    8000250c:	00913423          	sd	s1,8(sp)
    80002510:	01213023          	sd	s2,0(sp)
    80002514:	00113c23          	sd	ra,24(sp)
    80002518:	02010413          	addi	s0,sp,32
    8000251c:	00003917          	auipc	s2,0x3
    80002520:	23c90913          	addi	s2,s2,572 # 80005758 <cons>
    80002524:	00050493          	mv	s1,a0
    80002528:	00090513          	mv	a0,s2
    8000252c:	00001097          	auipc	ra,0x1
    80002530:	e40080e7          	jalr	-448(ra) # 8000336c <acquire>
    80002534:	02048c63          	beqz	s1,8000256c <consoleintr+0x68>
    80002538:	0a092783          	lw	a5,160(s2)
    8000253c:	09892703          	lw	a4,152(s2)
    80002540:	07f00693          	li	a3,127
    80002544:	40e7873b          	subw	a4,a5,a4
    80002548:	02e6e263          	bltu	a3,a4,8000256c <consoleintr+0x68>
    8000254c:	00d00713          	li	a4,13
    80002550:	04e48063          	beq	s1,a4,80002590 <consoleintr+0x8c>
    80002554:	07f7f713          	andi	a4,a5,127
    80002558:	00e90733          	add	a4,s2,a4
    8000255c:	0017879b          	addiw	a5,a5,1
    80002560:	0af92023          	sw	a5,160(s2)
    80002564:	00970c23          	sb	s1,24(a4)
    80002568:	08f92e23          	sw	a5,156(s2)
    8000256c:	01013403          	ld	s0,16(sp)
    80002570:	01813083          	ld	ra,24(sp)
    80002574:	00813483          	ld	s1,8(sp)
    80002578:	00013903          	ld	s2,0(sp)
    8000257c:	00003517          	auipc	a0,0x3
    80002580:	1dc50513          	addi	a0,a0,476 # 80005758 <cons>
    80002584:	02010113          	addi	sp,sp,32
    80002588:	00001317          	auipc	t1,0x1
    8000258c:	eb030067          	jr	-336(t1) # 80003438 <release>
    80002590:	00a00493          	li	s1,10
    80002594:	fc1ff06f          	j	80002554 <consoleintr+0x50>

0000000080002598 <consoleinit>:
    80002598:	fe010113          	addi	sp,sp,-32
    8000259c:	00113c23          	sd	ra,24(sp)
    800025a0:	00813823          	sd	s0,16(sp)
    800025a4:	00913423          	sd	s1,8(sp)
    800025a8:	02010413          	addi	s0,sp,32
    800025ac:	00003497          	auipc	s1,0x3
    800025b0:	1ac48493          	addi	s1,s1,428 # 80005758 <cons>
    800025b4:	00048513          	mv	a0,s1
    800025b8:	00002597          	auipc	a1,0x2
    800025bc:	c8858593          	addi	a1,a1,-888 # 80004240 <CONSOLE_STATUS+0x230>
    800025c0:	00001097          	auipc	ra,0x1
    800025c4:	d88080e7          	jalr	-632(ra) # 80003348 <initlock>
    800025c8:	00000097          	auipc	ra,0x0
    800025cc:	7ac080e7          	jalr	1964(ra) # 80002d74 <uartinit>
    800025d0:	01813083          	ld	ra,24(sp)
    800025d4:	01013403          	ld	s0,16(sp)
    800025d8:	00000797          	auipc	a5,0x0
    800025dc:	d9c78793          	addi	a5,a5,-612 # 80002374 <consoleread>
    800025e0:	0af4bc23          	sd	a5,184(s1)
    800025e4:	00000797          	auipc	a5,0x0
    800025e8:	cec78793          	addi	a5,a5,-788 # 800022d0 <consolewrite>
    800025ec:	0cf4b023          	sd	a5,192(s1)
    800025f0:	00813483          	ld	s1,8(sp)
    800025f4:	02010113          	addi	sp,sp,32
    800025f8:	00008067          	ret

00000000800025fc <console_read>:
    800025fc:	ff010113          	addi	sp,sp,-16
    80002600:	00813423          	sd	s0,8(sp)
    80002604:	01010413          	addi	s0,sp,16
    80002608:	00813403          	ld	s0,8(sp)
    8000260c:	00003317          	auipc	t1,0x3
    80002610:	20433303          	ld	t1,516(t1) # 80005810 <devsw+0x10>
    80002614:	01010113          	addi	sp,sp,16
    80002618:	00030067          	jr	t1

000000008000261c <console_write>:
    8000261c:	ff010113          	addi	sp,sp,-16
    80002620:	00813423          	sd	s0,8(sp)
    80002624:	01010413          	addi	s0,sp,16
    80002628:	00813403          	ld	s0,8(sp)
    8000262c:	00003317          	auipc	t1,0x3
    80002630:	1ec33303          	ld	t1,492(t1) # 80005818 <devsw+0x18>
    80002634:	01010113          	addi	sp,sp,16
    80002638:	00030067          	jr	t1

000000008000263c <panic>:
    8000263c:	fe010113          	addi	sp,sp,-32
    80002640:	00113c23          	sd	ra,24(sp)
    80002644:	00813823          	sd	s0,16(sp)
    80002648:	00913423          	sd	s1,8(sp)
    8000264c:	02010413          	addi	s0,sp,32
    80002650:	00050493          	mv	s1,a0
    80002654:	00002517          	auipc	a0,0x2
    80002658:	bf450513          	addi	a0,a0,-1036 # 80004248 <CONSOLE_STATUS+0x238>
    8000265c:	00003797          	auipc	a5,0x3
    80002660:	2407ae23          	sw	zero,604(a5) # 800058b8 <pr+0x18>
    80002664:	00000097          	auipc	ra,0x0
    80002668:	034080e7          	jalr	52(ra) # 80002698 <__printf>
    8000266c:	00048513          	mv	a0,s1
    80002670:	00000097          	auipc	ra,0x0
    80002674:	028080e7          	jalr	40(ra) # 80002698 <__printf>
    80002678:	00002517          	auipc	a0,0x2
    8000267c:	bb050513          	addi	a0,a0,-1104 # 80004228 <CONSOLE_STATUS+0x218>
    80002680:	00000097          	auipc	ra,0x0
    80002684:	018080e7          	jalr	24(ra) # 80002698 <__printf>
    80002688:	00100793          	li	a5,1
    8000268c:	00002717          	auipc	a4,0x2
    80002690:	fcf72e23          	sw	a5,-36(a4) # 80004668 <panicked>
    80002694:	0000006f          	j	80002694 <panic+0x58>

0000000080002698 <__printf>:
    80002698:	f3010113          	addi	sp,sp,-208
    8000269c:	08813023          	sd	s0,128(sp)
    800026a0:	07313423          	sd	s3,104(sp)
    800026a4:	09010413          	addi	s0,sp,144
    800026a8:	05813023          	sd	s8,64(sp)
    800026ac:	08113423          	sd	ra,136(sp)
    800026b0:	06913c23          	sd	s1,120(sp)
    800026b4:	07213823          	sd	s2,112(sp)
    800026b8:	07413023          	sd	s4,96(sp)
    800026bc:	05513c23          	sd	s5,88(sp)
    800026c0:	05613823          	sd	s6,80(sp)
    800026c4:	05713423          	sd	s7,72(sp)
    800026c8:	03913c23          	sd	s9,56(sp)
    800026cc:	03a13823          	sd	s10,48(sp)
    800026d0:	03b13423          	sd	s11,40(sp)
    800026d4:	00003317          	auipc	t1,0x3
    800026d8:	1cc30313          	addi	t1,t1,460 # 800058a0 <pr>
    800026dc:	01832c03          	lw	s8,24(t1)
    800026e0:	00b43423          	sd	a1,8(s0)
    800026e4:	00c43823          	sd	a2,16(s0)
    800026e8:	00d43c23          	sd	a3,24(s0)
    800026ec:	02e43023          	sd	a4,32(s0)
    800026f0:	02f43423          	sd	a5,40(s0)
    800026f4:	03043823          	sd	a6,48(s0)
    800026f8:	03143c23          	sd	a7,56(s0)
    800026fc:	00050993          	mv	s3,a0
    80002700:	4a0c1663          	bnez	s8,80002bac <__printf+0x514>
    80002704:	60098c63          	beqz	s3,80002d1c <__printf+0x684>
    80002708:	0009c503          	lbu	a0,0(s3)
    8000270c:	00840793          	addi	a5,s0,8
    80002710:	f6f43c23          	sd	a5,-136(s0)
    80002714:	00000493          	li	s1,0
    80002718:	22050063          	beqz	a0,80002938 <__printf+0x2a0>
    8000271c:	00002a37          	lui	s4,0x2
    80002720:	00018ab7          	lui	s5,0x18
    80002724:	000f4b37          	lui	s6,0xf4
    80002728:	00989bb7          	lui	s7,0x989
    8000272c:	70fa0a13          	addi	s4,s4,1807 # 270f <_entry-0x7fffd8f1>
    80002730:	69fa8a93          	addi	s5,s5,1695 # 1869f <_entry-0x7ffe7961>
    80002734:	23fb0b13          	addi	s6,s6,575 # f423f <_entry-0x7ff0bdc1>
    80002738:	67fb8b93          	addi	s7,s7,1663 # 98967f <_entry-0x7f676981>
    8000273c:	00148c9b          	addiw	s9,s1,1
    80002740:	02500793          	li	a5,37
    80002744:	01998933          	add	s2,s3,s9
    80002748:	38f51263          	bne	a0,a5,80002acc <__printf+0x434>
    8000274c:	00094783          	lbu	a5,0(s2)
    80002750:	00078c9b          	sext.w	s9,a5
    80002754:	1e078263          	beqz	a5,80002938 <__printf+0x2a0>
    80002758:	0024849b          	addiw	s1,s1,2
    8000275c:	07000713          	li	a4,112
    80002760:	00998933          	add	s2,s3,s1
    80002764:	38e78a63          	beq	a5,a4,80002af8 <__printf+0x460>
    80002768:	20f76863          	bltu	a4,a5,80002978 <__printf+0x2e0>
    8000276c:	42a78863          	beq	a5,a0,80002b9c <__printf+0x504>
    80002770:	06400713          	li	a4,100
    80002774:	40e79663          	bne	a5,a4,80002b80 <__printf+0x4e8>
    80002778:	f7843783          	ld	a5,-136(s0)
    8000277c:	0007a603          	lw	a2,0(a5)
    80002780:	00878793          	addi	a5,a5,8
    80002784:	f6f43c23          	sd	a5,-136(s0)
    80002788:	42064a63          	bltz	a2,80002bbc <__printf+0x524>
    8000278c:	00a00713          	li	a4,10
    80002790:	02e677bb          	remuw	a5,a2,a4
    80002794:	00002d97          	auipc	s11,0x2
    80002798:	adcd8d93          	addi	s11,s11,-1316 # 80004270 <digits>
    8000279c:	00900593          	li	a1,9
    800027a0:	0006051b          	sext.w	a0,a2
    800027a4:	00000c93          	li	s9,0
    800027a8:	02079793          	slli	a5,a5,0x20
    800027ac:	0207d793          	srli	a5,a5,0x20
    800027b0:	00fd87b3          	add	a5,s11,a5
    800027b4:	0007c783          	lbu	a5,0(a5)
    800027b8:	02e656bb          	divuw	a3,a2,a4
    800027bc:	f8f40023          	sb	a5,-128(s0)
    800027c0:	14c5d863          	bge	a1,a2,80002910 <__printf+0x278>
    800027c4:	06300593          	li	a1,99
    800027c8:	00100c93          	li	s9,1
    800027cc:	02e6f7bb          	remuw	a5,a3,a4
    800027d0:	02079793          	slli	a5,a5,0x20
    800027d4:	0207d793          	srli	a5,a5,0x20
    800027d8:	00fd87b3          	add	a5,s11,a5
    800027dc:	0007c783          	lbu	a5,0(a5)
    800027e0:	02e6d73b          	divuw	a4,a3,a4
    800027e4:	f8f400a3          	sb	a5,-127(s0)
    800027e8:	12a5f463          	bgeu	a1,a0,80002910 <__printf+0x278>
    800027ec:	00a00693          	li	a3,10
    800027f0:	00900593          	li	a1,9
    800027f4:	02d777bb          	remuw	a5,a4,a3
    800027f8:	02079793          	slli	a5,a5,0x20
    800027fc:	0207d793          	srli	a5,a5,0x20
    80002800:	00fd87b3          	add	a5,s11,a5
    80002804:	0007c503          	lbu	a0,0(a5)
    80002808:	02d757bb          	divuw	a5,a4,a3
    8000280c:	f8a40123          	sb	a0,-126(s0)
    80002810:	48e5f263          	bgeu	a1,a4,80002c94 <__printf+0x5fc>
    80002814:	06300513          	li	a0,99
    80002818:	02d7f5bb          	remuw	a1,a5,a3
    8000281c:	02059593          	slli	a1,a1,0x20
    80002820:	0205d593          	srli	a1,a1,0x20
    80002824:	00bd85b3          	add	a1,s11,a1
    80002828:	0005c583          	lbu	a1,0(a1)
    8000282c:	02d7d7bb          	divuw	a5,a5,a3
    80002830:	f8b401a3          	sb	a1,-125(s0)
    80002834:	48e57263          	bgeu	a0,a4,80002cb8 <__printf+0x620>
    80002838:	3e700513          	li	a0,999
    8000283c:	02d7f5bb          	remuw	a1,a5,a3
    80002840:	02059593          	slli	a1,a1,0x20
    80002844:	0205d593          	srli	a1,a1,0x20
    80002848:	00bd85b3          	add	a1,s11,a1
    8000284c:	0005c583          	lbu	a1,0(a1)
    80002850:	02d7d7bb          	divuw	a5,a5,a3
    80002854:	f8b40223          	sb	a1,-124(s0)
    80002858:	46e57663          	bgeu	a0,a4,80002cc4 <__printf+0x62c>
    8000285c:	02d7f5bb          	remuw	a1,a5,a3
    80002860:	02059593          	slli	a1,a1,0x20
    80002864:	0205d593          	srli	a1,a1,0x20
    80002868:	00bd85b3          	add	a1,s11,a1
    8000286c:	0005c583          	lbu	a1,0(a1)
    80002870:	02d7d7bb          	divuw	a5,a5,a3
    80002874:	f8b402a3          	sb	a1,-123(s0)
    80002878:	46ea7863          	bgeu	s4,a4,80002ce8 <__printf+0x650>
    8000287c:	02d7f5bb          	remuw	a1,a5,a3
    80002880:	02059593          	slli	a1,a1,0x20
    80002884:	0205d593          	srli	a1,a1,0x20
    80002888:	00bd85b3          	add	a1,s11,a1
    8000288c:	0005c583          	lbu	a1,0(a1)
    80002890:	02d7d7bb          	divuw	a5,a5,a3
    80002894:	f8b40323          	sb	a1,-122(s0)
    80002898:	3eeaf863          	bgeu	s5,a4,80002c88 <__printf+0x5f0>
    8000289c:	02d7f5bb          	remuw	a1,a5,a3
    800028a0:	02059593          	slli	a1,a1,0x20
    800028a4:	0205d593          	srli	a1,a1,0x20
    800028a8:	00bd85b3          	add	a1,s11,a1
    800028ac:	0005c583          	lbu	a1,0(a1)
    800028b0:	02d7d7bb          	divuw	a5,a5,a3
    800028b4:	f8b403a3          	sb	a1,-121(s0)
    800028b8:	42eb7e63          	bgeu	s6,a4,80002cf4 <__printf+0x65c>
    800028bc:	02d7f5bb          	remuw	a1,a5,a3
    800028c0:	02059593          	slli	a1,a1,0x20
    800028c4:	0205d593          	srli	a1,a1,0x20
    800028c8:	00bd85b3          	add	a1,s11,a1
    800028cc:	0005c583          	lbu	a1,0(a1)
    800028d0:	02d7d7bb          	divuw	a5,a5,a3
    800028d4:	f8b40423          	sb	a1,-120(s0)
    800028d8:	42ebfc63          	bgeu	s7,a4,80002d10 <__printf+0x678>
    800028dc:	02079793          	slli	a5,a5,0x20
    800028e0:	0207d793          	srli	a5,a5,0x20
    800028e4:	00fd8db3          	add	s11,s11,a5
    800028e8:	000dc703          	lbu	a4,0(s11)
    800028ec:	00a00793          	li	a5,10
    800028f0:	00900c93          	li	s9,9
    800028f4:	f8e404a3          	sb	a4,-119(s0)
    800028f8:	00065c63          	bgez	a2,80002910 <__printf+0x278>
    800028fc:	f9040713          	addi	a4,s0,-112
    80002900:	00f70733          	add	a4,a4,a5
    80002904:	02d00693          	li	a3,45
    80002908:	fed70823          	sb	a3,-16(a4)
    8000290c:	00078c93          	mv	s9,a5
    80002910:	f8040793          	addi	a5,s0,-128
    80002914:	01978cb3          	add	s9,a5,s9
    80002918:	f7f40d13          	addi	s10,s0,-129
    8000291c:	000cc503          	lbu	a0,0(s9)
    80002920:	fffc8c93          	addi	s9,s9,-1
    80002924:	00000097          	auipc	ra,0x0
    80002928:	b90080e7          	jalr	-1136(ra) # 800024b4 <consputc>
    8000292c:	ffac98e3          	bne	s9,s10,8000291c <__printf+0x284>
    80002930:	00094503          	lbu	a0,0(s2)
    80002934:	e00514e3          	bnez	a0,8000273c <__printf+0xa4>
    80002938:	1a0c1663          	bnez	s8,80002ae4 <__printf+0x44c>
    8000293c:	08813083          	ld	ra,136(sp)
    80002940:	08013403          	ld	s0,128(sp)
    80002944:	07813483          	ld	s1,120(sp)
    80002948:	07013903          	ld	s2,112(sp)
    8000294c:	06813983          	ld	s3,104(sp)
    80002950:	06013a03          	ld	s4,96(sp)
    80002954:	05813a83          	ld	s5,88(sp)
    80002958:	05013b03          	ld	s6,80(sp)
    8000295c:	04813b83          	ld	s7,72(sp)
    80002960:	04013c03          	ld	s8,64(sp)
    80002964:	03813c83          	ld	s9,56(sp)
    80002968:	03013d03          	ld	s10,48(sp)
    8000296c:	02813d83          	ld	s11,40(sp)
    80002970:	0d010113          	addi	sp,sp,208
    80002974:	00008067          	ret
    80002978:	07300713          	li	a4,115
    8000297c:	1ce78a63          	beq	a5,a4,80002b50 <__printf+0x4b8>
    80002980:	07800713          	li	a4,120
    80002984:	1ee79e63          	bne	a5,a4,80002b80 <__printf+0x4e8>
    80002988:	f7843783          	ld	a5,-136(s0)
    8000298c:	0007a703          	lw	a4,0(a5)
    80002990:	00878793          	addi	a5,a5,8
    80002994:	f6f43c23          	sd	a5,-136(s0)
    80002998:	28074263          	bltz	a4,80002c1c <__printf+0x584>
    8000299c:	00002d97          	auipc	s11,0x2
    800029a0:	8d4d8d93          	addi	s11,s11,-1836 # 80004270 <digits>
    800029a4:	00f77793          	andi	a5,a4,15
    800029a8:	00fd87b3          	add	a5,s11,a5
    800029ac:	0007c683          	lbu	a3,0(a5)
    800029b0:	00f00613          	li	a2,15
    800029b4:	0007079b          	sext.w	a5,a4
    800029b8:	f8d40023          	sb	a3,-128(s0)
    800029bc:	0047559b          	srliw	a1,a4,0x4
    800029c0:	0047569b          	srliw	a3,a4,0x4
    800029c4:	00000c93          	li	s9,0
    800029c8:	0ee65063          	bge	a2,a4,80002aa8 <__printf+0x410>
    800029cc:	00f6f693          	andi	a3,a3,15
    800029d0:	00dd86b3          	add	a3,s11,a3
    800029d4:	0006c683          	lbu	a3,0(a3) # 2004000 <_entry-0x7dffc000>
    800029d8:	0087d79b          	srliw	a5,a5,0x8
    800029dc:	00100c93          	li	s9,1
    800029e0:	f8d400a3          	sb	a3,-127(s0)
    800029e4:	0cb67263          	bgeu	a2,a1,80002aa8 <__printf+0x410>
    800029e8:	00f7f693          	andi	a3,a5,15
    800029ec:	00dd86b3          	add	a3,s11,a3
    800029f0:	0006c583          	lbu	a1,0(a3)
    800029f4:	00f00613          	li	a2,15
    800029f8:	0047d69b          	srliw	a3,a5,0x4
    800029fc:	f8b40123          	sb	a1,-126(s0)
    80002a00:	0047d593          	srli	a1,a5,0x4
    80002a04:	28f67e63          	bgeu	a2,a5,80002ca0 <__printf+0x608>
    80002a08:	00f6f693          	andi	a3,a3,15
    80002a0c:	00dd86b3          	add	a3,s11,a3
    80002a10:	0006c503          	lbu	a0,0(a3)
    80002a14:	0087d813          	srli	a6,a5,0x8
    80002a18:	0087d69b          	srliw	a3,a5,0x8
    80002a1c:	f8a401a3          	sb	a0,-125(s0)
    80002a20:	28b67663          	bgeu	a2,a1,80002cac <__printf+0x614>
    80002a24:	00f6f693          	andi	a3,a3,15
    80002a28:	00dd86b3          	add	a3,s11,a3
    80002a2c:	0006c583          	lbu	a1,0(a3)
    80002a30:	00c7d513          	srli	a0,a5,0xc
    80002a34:	00c7d69b          	srliw	a3,a5,0xc
    80002a38:	f8b40223          	sb	a1,-124(s0)
    80002a3c:	29067a63          	bgeu	a2,a6,80002cd0 <__printf+0x638>
    80002a40:	00f6f693          	andi	a3,a3,15
    80002a44:	00dd86b3          	add	a3,s11,a3
    80002a48:	0006c583          	lbu	a1,0(a3)
    80002a4c:	0107d813          	srli	a6,a5,0x10
    80002a50:	0107d69b          	srliw	a3,a5,0x10
    80002a54:	f8b402a3          	sb	a1,-123(s0)
    80002a58:	28a67263          	bgeu	a2,a0,80002cdc <__printf+0x644>
    80002a5c:	00f6f693          	andi	a3,a3,15
    80002a60:	00dd86b3          	add	a3,s11,a3
    80002a64:	0006c683          	lbu	a3,0(a3)
    80002a68:	0147d79b          	srliw	a5,a5,0x14
    80002a6c:	f8d40323          	sb	a3,-122(s0)
    80002a70:	21067663          	bgeu	a2,a6,80002c7c <__printf+0x5e4>
    80002a74:	02079793          	slli	a5,a5,0x20
    80002a78:	0207d793          	srli	a5,a5,0x20
    80002a7c:	00fd8db3          	add	s11,s11,a5
    80002a80:	000dc683          	lbu	a3,0(s11)
    80002a84:	00800793          	li	a5,8
    80002a88:	00700c93          	li	s9,7
    80002a8c:	f8d403a3          	sb	a3,-121(s0)
    80002a90:	00075c63          	bgez	a4,80002aa8 <__printf+0x410>
    80002a94:	f9040713          	addi	a4,s0,-112
    80002a98:	00f70733          	add	a4,a4,a5
    80002a9c:	02d00693          	li	a3,45
    80002aa0:	fed70823          	sb	a3,-16(a4)
    80002aa4:	00078c93          	mv	s9,a5
    80002aa8:	f8040793          	addi	a5,s0,-128
    80002aac:	01978cb3          	add	s9,a5,s9
    80002ab0:	f7f40d13          	addi	s10,s0,-129
    80002ab4:	000cc503          	lbu	a0,0(s9)
    80002ab8:	fffc8c93          	addi	s9,s9,-1
    80002abc:	00000097          	auipc	ra,0x0
    80002ac0:	9f8080e7          	jalr	-1544(ra) # 800024b4 <consputc>
    80002ac4:	ff9d18e3          	bne	s10,s9,80002ab4 <__printf+0x41c>
    80002ac8:	0100006f          	j	80002ad8 <__printf+0x440>
    80002acc:	00000097          	auipc	ra,0x0
    80002ad0:	9e8080e7          	jalr	-1560(ra) # 800024b4 <consputc>
    80002ad4:	000c8493          	mv	s1,s9
    80002ad8:	00094503          	lbu	a0,0(s2)
    80002adc:	c60510e3          	bnez	a0,8000273c <__printf+0xa4>
    80002ae0:	e40c0ee3          	beqz	s8,8000293c <__printf+0x2a4>
    80002ae4:	00003517          	auipc	a0,0x3
    80002ae8:	dbc50513          	addi	a0,a0,-580 # 800058a0 <pr>
    80002aec:	00001097          	auipc	ra,0x1
    80002af0:	94c080e7          	jalr	-1716(ra) # 80003438 <release>
    80002af4:	e49ff06f          	j	8000293c <__printf+0x2a4>
    80002af8:	f7843783          	ld	a5,-136(s0)
    80002afc:	03000513          	li	a0,48
    80002b00:	01000d13          	li	s10,16
    80002b04:	00878713          	addi	a4,a5,8
    80002b08:	0007bc83          	ld	s9,0(a5)
    80002b0c:	f6e43c23          	sd	a4,-136(s0)
    80002b10:	00000097          	auipc	ra,0x0
    80002b14:	9a4080e7          	jalr	-1628(ra) # 800024b4 <consputc>
    80002b18:	07800513          	li	a0,120
    80002b1c:	00000097          	auipc	ra,0x0
    80002b20:	998080e7          	jalr	-1640(ra) # 800024b4 <consputc>
    80002b24:	00001d97          	auipc	s11,0x1
    80002b28:	74cd8d93          	addi	s11,s11,1868 # 80004270 <digits>
    80002b2c:	03ccd793          	srli	a5,s9,0x3c
    80002b30:	00fd87b3          	add	a5,s11,a5
    80002b34:	0007c503          	lbu	a0,0(a5)
    80002b38:	fffd0d1b          	addiw	s10,s10,-1
    80002b3c:	004c9c93          	slli	s9,s9,0x4
    80002b40:	00000097          	auipc	ra,0x0
    80002b44:	974080e7          	jalr	-1676(ra) # 800024b4 <consputc>
    80002b48:	fe0d12e3          	bnez	s10,80002b2c <__printf+0x494>
    80002b4c:	f8dff06f          	j	80002ad8 <__printf+0x440>
    80002b50:	f7843783          	ld	a5,-136(s0)
    80002b54:	0007bc83          	ld	s9,0(a5)
    80002b58:	00878793          	addi	a5,a5,8
    80002b5c:	f6f43c23          	sd	a5,-136(s0)
    80002b60:	000c9a63          	bnez	s9,80002b74 <__printf+0x4dc>
    80002b64:	1080006f          	j	80002c6c <__printf+0x5d4>
    80002b68:	001c8c93          	addi	s9,s9,1
    80002b6c:	00000097          	auipc	ra,0x0
    80002b70:	948080e7          	jalr	-1720(ra) # 800024b4 <consputc>
    80002b74:	000cc503          	lbu	a0,0(s9)
    80002b78:	fe0518e3          	bnez	a0,80002b68 <__printf+0x4d0>
    80002b7c:	f5dff06f          	j	80002ad8 <__printf+0x440>
    80002b80:	02500513          	li	a0,37
    80002b84:	00000097          	auipc	ra,0x0
    80002b88:	930080e7          	jalr	-1744(ra) # 800024b4 <consputc>
    80002b8c:	000c8513          	mv	a0,s9
    80002b90:	00000097          	auipc	ra,0x0
    80002b94:	924080e7          	jalr	-1756(ra) # 800024b4 <consputc>
    80002b98:	f41ff06f          	j	80002ad8 <__printf+0x440>
    80002b9c:	02500513          	li	a0,37
    80002ba0:	00000097          	auipc	ra,0x0
    80002ba4:	914080e7          	jalr	-1772(ra) # 800024b4 <consputc>
    80002ba8:	f31ff06f          	j	80002ad8 <__printf+0x440>
    80002bac:	00030513          	mv	a0,t1
    80002bb0:	00000097          	auipc	ra,0x0
    80002bb4:	7bc080e7          	jalr	1980(ra) # 8000336c <acquire>
    80002bb8:	b4dff06f          	j	80002704 <__printf+0x6c>
    80002bbc:	40c0053b          	negw	a0,a2
    80002bc0:	00a00713          	li	a4,10
    80002bc4:	02e576bb          	remuw	a3,a0,a4
    80002bc8:	00001d97          	auipc	s11,0x1
    80002bcc:	6a8d8d93          	addi	s11,s11,1704 # 80004270 <digits>
    80002bd0:	ff700593          	li	a1,-9
    80002bd4:	02069693          	slli	a3,a3,0x20
    80002bd8:	0206d693          	srli	a3,a3,0x20
    80002bdc:	00dd86b3          	add	a3,s11,a3
    80002be0:	0006c683          	lbu	a3,0(a3)
    80002be4:	02e557bb          	divuw	a5,a0,a4
    80002be8:	f8d40023          	sb	a3,-128(s0)
    80002bec:	10b65e63          	bge	a2,a1,80002d08 <__printf+0x670>
    80002bf0:	06300593          	li	a1,99
    80002bf4:	02e7f6bb          	remuw	a3,a5,a4
    80002bf8:	02069693          	slli	a3,a3,0x20
    80002bfc:	0206d693          	srli	a3,a3,0x20
    80002c00:	00dd86b3          	add	a3,s11,a3
    80002c04:	0006c683          	lbu	a3,0(a3)
    80002c08:	02e7d73b          	divuw	a4,a5,a4
    80002c0c:	00200793          	li	a5,2
    80002c10:	f8d400a3          	sb	a3,-127(s0)
    80002c14:	bca5ece3          	bltu	a1,a0,800027ec <__printf+0x154>
    80002c18:	ce5ff06f          	j	800028fc <__printf+0x264>
    80002c1c:	40e007bb          	negw	a5,a4
    80002c20:	00001d97          	auipc	s11,0x1
    80002c24:	650d8d93          	addi	s11,s11,1616 # 80004270 <digits>
    80002c28:	00f7f693          	andi	a3,a5,15
    80002c2c:	00dd86b3          	add	a3,s11,a3
    80002c30:	0006c583          	lbu	a1,0(a3)
    80002c34:	ff100613          	li	a2,-15
    80002c38:	0047d69b          	srliw	a3,a5,0x4
    80002c3c:	f8b40023          	sb	a1,-128(s0)
    80002c40:	0047d59b          	srliw	a1,a5,0x4
    80002c44:	0ac75e63          	bge	a4,a2,80002d00 <__printf+0x668>
    80002c48:	00f6f693          	andi	a3,a3,15
    80002c4c:	00dd86b3          	add	a3,s11,a3
    80002c50:	0006c603          	lbu	a2,0(a3)
    80002c54:	00f00693          	li	a3,15
    80002c58:	0087d79b          	srliw	a5,a5,0x8
    80002c5c:	f8c400a3          	sb	a2,-127(s0)
    80002c60:	d8b6e4e3          	bltu	a3,a1,800029e8 <__printf+0x350>
    80002c64:	00200793          	li	a5,2
    80002c68:	e2dff06f          	j	80002a94 <__printf+0x3fc>
    80002c6c:	00001c97          	auipc	s9,0x1
    80002c70:	5e4c8c93          	addi	s9,s9,1508 # 80004250 <CONSOLE_STATUS+0x240>
    80002c74:	02800513          	li	a0,40
    80002c78:	ef1ff06f          	j	80002b68 <__printf+0x4d0>
    80002c7c:	00700793          	li	a5,7
    80002c80:	00600c93          	li	s9,6
    80002c84:	e0dff06f          	j	80002a90 <__printf+0x3f8>
    80002c88:	00700793          	li	a5,7
    80002c8c:	00600c93          	li	s9,6
    80002c90:	c69ff06f          	j	800028f8 <__printf+0x260>
    80002c94:	00300793          	li	a5,3
    80002c98:	00200c93          	li	s9,2
    80002c9c:	c5dff06f          	j	800028f8 <__printf+0x260>
    80002ca0:	00300793          	li	a5,3
    80002ca4:	00200c93          	li	s9,2
    80002ca8:	de9ff06f          	j	80002a90 <__printf+0x3f8>
    80002cac:	00400793          	li	a5,4
    80002cb0:	00300c93          	li	s9,3
    80002cb4:	dddff06f          	j	80002a90 <__printf+0x3f8>
    80002cb8:	00400793          	li	a5,4
    80002cbc:	00300c93          	li	s9,3
    80002cc0:	c39ff06f          	j	800028f8 <__printf+0x260>
    80002cc4:	00500793          	li	a5,5
    80002cc8:	00400c93          	li	s9,4
    80002ccc:	c2dff06f          	j	800028f8 <__printf+0x260>
    80002cd0:	00500793          	li	a5,5
    80002cd4:	00400c93          	li	s9,4
    80002cd8:	db9ff06f          	j	80002a90 <__printf+0x3f8>
    80002cdc:	00600793          	li	a5,6
    80002ce0:	00500c93          	li	s9,5
    80002ce4:	dadff06f          	j	80002a90 <__printf+0x3f8>
    80002ce8:	00600793          	li	a5,6
    80002cec:	00500c93          	li	s9,5
    80002cf0:	c09ff06f          	j	800028f8 <__printf+0x260>
    80002cf4:	00800793          	li	a5,8
    80002cf8:	00700c93          	li	s9,7
    80002cfc:	bfdff06f          	j	800028f8 <__printf+0x260>
    80002d00:	00100793          	li	a5,1
    80002d04:	d91ff06f          	j	80002a94 <__printf+0x3fc>
    80002d08:	00100793          	li	a5,1
    80002d0c:	bf1ff06f          	j	800028fc <__printf+0x264>
    80002d10:	00900793          	li	a5,9
    80002d14:	00800c93          	li	s9,8
    80002d18:	be1ff06f          	j	800028f8 <__printf+0x260>
    80002d1c:	00001517          	auipc	a0,0x1
    80002d20:	53c50513          	addi	a0,a0,1340 # 80004258 <CONSOLE_STATUS+0x248>
    80002d24:	00000097          	auipc	ra,0x0
    80002d28:	918080e7          	jalr	-1768(ra) # 8000263c <panic>

0000000080002d2c <printfinit>:
    80002d2c:	fe010113          	addi	sp,sp,-32
    80002d30:	00813823          	sd	s0,16(sp)
    80002d34:	00913423          	sd	s1,8(sp)
    80002d38:	00113c23          	sd	ra,24(sp)
    80002d3c:	02010413          	addi	s0,sp,32
    80002d40:	00003497          	auipc	s1,0x3
    80002d44:	b6048493          	addi	s1,s1,-1184 # 800058a0 <pr>
    80002d48:	00048513          	mv	a0,s1
    80002d4c:	00001597          	auipc	a1,0x1
    80002d50:	51c58593          	addi	a1,a1,1308 # 80004268 <CONSOLE_STATUS+0x258>
    80002d54:	00000097          	auipc	ra,0x0
    80002d58:	5f4080e7          	jalr	1524(ra) # 80003348 <initlock>
    80002d5c:	01813083          	ld	ra,24(sp)
    80002d60:	01013403          	ld	s0,16(sp)
    80002d64:	0004ac23          	sw	zero,24(s1)
    80002d68:	00813483          	ld	s1,8(sp)
    80002d6c:	02010113          	addi	sp,sp,32
    80002d70:	00008067          	ret

0000000080002d74 <uartinit>:
    80002d74:	ff010113          	addi	sp,sp,-16
    80002d78:	00813423          	sd	s0,8(sp)
    80002d7c:	01010413          	addi	s0,sp,16
    80002d80:	100007b7          	lui	a5,0x10000
    80002d84:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>
    80002d88:	f8000713          	li	a4,-128
    80002d8c:	00e781a3          	sb	a4,3(a5)
    80002d90:	00300713          	li	a4,3
    80002d94:	00e78023          	sb	a4,0(a5)
    80002d98:	000780a3          	sb	zero,1(a5)
    80002d9c:	00e781a3          	sb	a4,3(a5)
    80002da0:	00700693          	li	a3,7
    80002da4:	00d78123          	sb	a3,2(a5)
    80002da8:	00e780a3          	sb	a4,1(a5)
    80002dac:	00813403          	ld	s0,8(sp)
    80002db0:	01010113          	addi	sp,sp,16
    80002db4:	00008067          	ret

0000000080002db8 <uartputc>:
    80002db8:	00002797          	auipc	a5,0x2
    80002dbc:	8b07a783          	lw	a5,-1872(a5) # 80004668 <panicked>
    80002dc0:	00078463          	beqz	a5,80002dc8 <uartputc+0x10>
    80002dc4:	0000006f          	j	80002dc4 <uartputc+0xc>
    80002dc8:	fd010113          	addi	sp,sp,-48
    80002dcc:	02813023          	sd	s0,32(sp)
    80002dd0:	00913c23          	sd	s1,24(sp)
    80002dd4:	01213823          	sd	s2,16(sp)
    80002dd8:	01313423          	sd	s3,8(sp)
    80002ddc:	02113423          	sd	ra,40(sp)
    80002de0:	03010413          	addi	s0,sp,48
    80002de4:	00002917          	auipc	s2,0x2
    80002de8:	88c90913          	addi	s2,s2,-1908 # 80004670 <uart_tx_r>
    80002dec:	00093783          	ld	a5,0(s2)
    80002df0:	00002497          	auipc	s1,0x2
    80002df4:	88848493          	addi	s1,s1,-1912 # 80004678 <uart_tx_w>
    80002df8:	0004b703          	ld	a4,0(s1)
    80002dfc:	02078693          	addi	a3,a5,32
    80002e00:	00050993          	mv	s3,a0
    80002e04:	02e69c63          	bne	a3,a4,80002e3c <uartputc+0x84>
    80002e08:	00001097          	auipc	ra,0x1
    80002e0c:	834080e7          	jalr	-1996(ra) # 8000363c <push_on>
    80002e10:	00093783          	ld	a5,0(s2)
    80002e14:	0004b703          	ld	a4,0(s1)
    80002e18:	02078793          	addi	a5,a5,32
    80002e1c:	00e79463          	bne	a5,a4,80002e24 <uartputc+0x6c>
    80002e20:	0000006f          	j	80002e20 <uartputc+0x68>
    80002e24:	00001097          	auipc	ra,0x1
    80002e28:	88c080e7          	jalr	-1908(ra) # 800036b0 <pop_on>
    80002e2c:	00093783          	ld	a5,0(s2)
    80002e30:	0004b703          	ld	a4,0(s1)
    80002e34:	02078693          	addi	a3,a5,32
    80002e38:	fce688e3          	beq	a3,a4,80002e08 <uartputc+0x50>
    80002e3c:	01f77693          	andi	a3,a4,31
    80002e40:	00003597          	auipc	a1,0x3
    80002e44:	a8058593          	addi	a1,a1,-1408 # 800058c0 <uart_tx_buf>
    80002e48:	00d586b3          	add	a3,a1,a3
    80002e4c:	00170713          	addi	a4,a4,1
    80002e50:	01368023          	sb	s3,0(a3)
    80002e54:	00e4b023          	sd	a4,0(s1)
    80002e58:	10000637          	lui	a2,0x10000
    80002e5c:	02f71063          	bne	a4,a5,80002e7c <uartputc+0xc4>
    80002e60:	0340006f          	j	80002e94 <uartputc+0xdc>
    80002e64:	00074703          	lbu	a4,0(a4)
    80002e68:	00f93023          	sd	a5,0(s2)
    80002e6c:	00e60023          	sb	a4,0(a2) # 10000000 <_entry-0x70000000>
    80002e70:	00093783          	ld	a5,0(s2)
    80002e74:	0004b703          	ld	a4,0(s1)
    80002e78:	00f70e63          	beq	a4,a5,80002e94 <uartputc+0xdc>
    80002e7c:	00564683          	lbu	a3,5(a2)
    80002e80:	01f7f713          	andi	a4,a5,31
    80002e84:	00e58733          	add	a4,a1,a4
    80002e88:	0206f693          	andi	a3,a3,32
    80002e8c:	00178793          	addi	a5,a5,1
    80002e90:	fc069ae3          	bnez	a3,80002e64 <uartputc+0xac>
    80002e94:	02813083          	ld	ra,40(sp)
    80002e98:	02013403          	ld	s0,32(sp)
    80002e9c:	01813483          	ld	s1,24(sp)
    80002ea0:	01013903          	ld	s2,16(sp)
    80002ea4:	00813983          	ld	s3,8(sp)
    80002ea8:	03010113          	addi	sp,sp,48
    80002eac:	00008067          	ret

0000000080002eb0 <uartputc_sync>:
    80002eb0:	ff010113          	addi	sp,sp,-16
    80002eb4:	00813423          	sd	s0,8(sp)
    80002eb8:	01010413          	addi	s0,sp,16
    80002ebc:	00001717          	auipc	a4,0x1
    80002ec0:	7ac72703          	lw	a4,1964(a4) # 80004668 <panicked>
    80002ec4:	02071663          	bnez	a4,80002ef0 <uartputc_sync+0x40>
    80002ec8:	00050793          	mv	a5,a0
    80002ecc:	100006b7          	lui	a3,0x10000
    80002ed0:	0056c703          	lbu	a4,5(a3) # 10000005 <_entry-0x6ffffffb>
    80002ed4:	02077713          	andi	a4,a4,32
    80002ed8:	fe070ce3          	beqz	a4,80002ed0 <uartputc_sync+0x20>
    80002edc:	0ff7f793          	andi	a5,a5,255
    80002ee0:	00f68023          	sb	a5,0(a3)
    80002ee4:	00813403          	ld	s0,8(sp)
    80002ee8:	01010113          	addi	sp,sp,16
    80002eec:	00008067          	ret
    80002ef0:	0000006f          	j	80002ef0 <uartputc_sync+0x40>

0000000080002ef4 <uartstart>:
    80002ef4:	ff010113          	addi	sp,sp,-16
    80002ef8:	00813423          	sd	s0,8(sp)
    80002efc:	01010413          	addi	s0,sp,16
    80002f00:	00001617          	auipc	a2,0x1
    80002f04:	77060613          	addi	a2,a2,1904 # 80004670 <uart_tx_r>
    80002f08:	00001517          	auipc	a0,0x1
    80002f0c:	77050513          	addi	a0,a0,1904 # 80004678 <uart_tx_w>
    80002f10:	00063783          	ld	a5,0(a2)
    80002f14:	00053703          	ld	a4,0(a0)
    80002f18:	04f70263          	beq	a4,a5,80002f5c <uartstart+0x68>
    80002f1c:	100005b7          	lui	a1,0x10000
    80002f20:	00003817          	auipc	a6,0x3
    80002f24:	9a080813          	addi	a6,a6,-1632 # 800058c0 <uart_tx_buf>
    80002f28:	01c0006f          	j	80002f44 <uartstart+0x50>
    80002f2c:	0006c703          	lbu	a4,0(a3)
    80002f30:	00f63023          	sd	a5,0(a2)
    80002f34:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    80002f38:	00063783          	ld	a5,0(a2)
    80002f3c:	00053703          	ld	a4,0(a0)
    80002f40:	00f70e63          	beq	a4,a5,80002f5c <uartstart+0x68>
    80002f44:	01f7f713          	andi	a4,a5,31
    80002f48:	00e806b3          	add	a3,a6,a4
    80002f4c:	0055c703          	lbu	a4,5(a1)
    80002f50:	00178793          	addi	a5,a5,1
    80002f54:	02077713          	andi	a4,a4,32
    80002f58:	fc071ae3          	bnez	a4,80002f2c <uartstart+0x38>
    80002f5c:	00813403          	ld	s0,8(sp)
    80002f60:	01010113          	addi	sp,sp,16
    80002f64:	00008067          	ret

0000000080002f68 <uartgetc>:
    80002f68:	ff010113          	addi	sp,sp,-16
    80002f6c:	00813423          	sd	s0,8(sp)
    80002f70:	01010413          	addi	s0,sp,16
    80002f74:	10000737          	lui	a4,0x10000
    80002f78:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80002f7c:	0017f793          	andi	a5,a5,1
    80002f80:	00078c63          	beqz	a5,80002f98 <uartgetc+0x30>
    80002f84:	00074503          	lbu	a0,0(a4)
    80002f88:	0ff57513          	andi	a0,a0,255
    80002f8c:	00813403          	ld	s0,8(sp)
    80002f90:	01010113          	addi	sp,sp,16
    80002f94:	00008067          	ret
    80002f98:	fff00513          	li	a0,-1
    80002f9c:	ff1ff06f          	j	80002f8c <uartgetc+0x24>

0000000080002fa0 <uartintr>:
    80002fa0:	100007b7          	lui	a5,0x10000
    80002fa4:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80002fa8:	0017f793          	andi	a5,a5,1
    80002fac:	0a078463          	beqz	a5,80003054 <uartintr+0xb4>
    80002fb0:	fe010113          	addi	sp,sp,-32
    80002fb4:	00813823          	sd	s0,16(sp)
    80002fb8:	00913423          	sd	s1,8(sp)
    80002fbc:	00113c23          	sd	ra,24(sp)
    80002fc0:	02010413          	addi	s0,sp,32
    80002fc4:	100004b7          	lui	s1,0x10000
    80002fc8:	0004c503          	lbu	a0,0(s1) # 10000000 <_entry-0x70000000>
    80002fcc:	0ff57513          	andi	a0,a0,255
    80002fd0:	fffff097          	auipc	ra,0xfffff
    80002fd4:	534080e7          	jalr	1332(ra) # 80002504 <consoleintr>
    80002fd8:	0054c783          	lbu	a5,5(s1)
    80002fdc:	0017f793          	andi	a5,a5,1
    80002fe0:	fe0794e3          	bnez	a5,80002fc8 <uartintr+0x28>
    80002fe4:	00001617          	auipc	a2,0x1
    80002fe8:	68c60613          	addi	a2,a2,1676 # 80004670 <uart_tx_r>
    80002fec:	00001517          	auipc	a0,0x1
    80002ff0:	68c50513          	addi	a0,a0,1676 # 80004678 <uart_tx_w>
    80002ff4:	00063783          	ld	a5,0(a2)
    80002ff8:	00053703          	ld	a4,0(a0)
    80002ffc:	04f70263          	beq	a4,a5,80003040 <uartintr+0xa0>
    80003000:	100005b7          	lui	a1,0x10000
    80003004:	00003817          	auipc	a6,0x3
    80003008:	8bc80813          	addi	a6,a6,-1860 # 800058c0 <uart_tx_buf>
    8000300c:	01c0006f          	j	80003028 <uartintr+0x88>
    80003010:	0006c703          	lbu	a4,0(a3)
    80003014:	00f63023          	sd	a5,0(a2)
    80003018:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    8000301c:	00063783          	ld	a5,0(a2)
    80003020:	00053703          	ld	a4,0(a0)
    80003024:	00f70e63          	beq	a4,a5,80003040 <uartintr+0xa0>
    80003028:	01f7f713          	andi	a4,a5,31
    8000302c:	00e806b3          	add	a3,a6,a4
    80003030:	0055c703          	lbu	a4,5(a1)
    80003034:	00178793          	addi	a5,a5,1
    80003038:	02077713          	andi	a4,a4,32
    8000303c:	fc071ae3          	bnez	a4,80003010 <uartintr+0x70>
    80003040:	01813083          	ld	ra,24(sp)
    80003044:	01013403          	ld	s0,16(sp)
    80003048:	00813483          	ld	s1,8(sp)
    8000304c:	02010113          	addi	sp,sp,32
    80003050:	00008067          	ret
    80003054:	00001617          	auipc	a2,0x1
    80003058:	61c60613          	addi	a2,a2,1564 # 80004670 <uart_tx_r>
    8000305c:	00001517          	auipc	a0,0x1
    80003060:	61c50513          	addi	a0,a0,1564 # 80004678 <uart_tx_w>
    80003064:	00063783          	ld	a5,0(a2)
    80003068:	00053703          	ld	a4,0(a0)
    8000306c:	04f70263          	beq	a4,a5,800030b0 <uartintr+0x110>
    80003070:	100005b7          	lui	a1,0x10000
    80003074:	00003817          	auipc	a6,0x3
    80003078:	84c80813          	addi	a6,a6,-1972 # 800058c0 <uart_tx_buf>
    8000307c:	01c0006f          	j	80003098 <uartintr+0xf8>
    80003080:	0006c703          	lbu	a4,0(a3)
    80003084:	00f63023          	sd	a5,0(a2)
    80003088:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    8000308c:	00063783          	ld	a5,0(a2)
    80003090:	00053703          	ld	a4,0(a0)
    80003094:	02f70063          	beq	a4,a5,800030b4 <uartintr+0x114>
    80003098:	01f7f713          	andi	a4,a5,31
    8000309c:	00e806b3          	add	a3,a6,a4
    800030a0:	0055c703          	lbu	a4,5(a1)
    800030a4:	00178793          	addi	a5,a5,1
    800030a8:	02077713          	andi	a4,a4,32
    800030ac:	fc071ae3          	bnez	a4,80003080 <uartintr+0xe0>
    800030b0:	00008067          	ret
    800030b4:	00008067          	ret

00000000800030b8 <kinit>:
    800030b8:	fc010113          	addi	sp,sp,-64
    800030bc:	02913423          	sd	s1,40(sp)
    800030c0:	fffff7b7          	lui	a5,0xfffff
    800030c4:	00004497          	auipc	s1,0x4
    800030c8:	81b48493          	addi	s1,s1,-2021 # 800068df <end+0xfff>
    800030cc:	02813823          	sd	s0,48(sp)
    800030d0:	01313c23          	sd	s3,24(sp)
    800030d4:	00f4f4b3          	and	s1,s1,a5
    800030d8:	02113c23          	sd	ra,56(sp)
    800030dc:	03213023          	sd	s2,32(sp)
    800030e0:	01413823          	sd	s4,16(sp)
    800030e4:	01513423          	sd	s5,8(sp)
    800030e8:	04010413          	addi	s0,sp,64
    800030ec:	000017b7          	lui	a5,0x1
    800030f0:	01100993          	li	s3,17
    800030f4:	00f487b3          	add	a5,s1,a5
    800030f8:	01b99993          	slli	s3,s3,0x1b
    800030fc:	06f9e063          	bltu	s3,a5,8000315c <kinit+0xa4>
    80003100:	00002a97          	auipc	s5,0x2
    80003104:	7e0a8a93          	addi	s5,s5,2016 # 800058e0 <end>
    80003108:	0754ec63          	bltu	s1,s5,80003180 <kinit+0xc8>
    8000310c:	0734fa63          	bgeu	s1,s3,80003180 <kinit+0xc8>
    80003110:	00088a37          	lui	s4,0x88
    80003114:	fffa0a13          	addi	s4,s4,-1 # 87fff <_entry-0x7ff78001>
    80003118:	00001917          	auipc	s2,0x1
    8000311c:	56890913          	addi	s2,s2,1384 # 80004680 <kmem>
    80003120:	00ca1a13          	slli	s4,s4,0xc
    80003124:	0140006f          	j	80003138 <kinit+0x80>
    80003128:	000017b7          	lui	a5,0x1
    8000312c:	00f484b3          	add	s1,s1,a5
    80003130:	0554e863          	bltu	s1,s5,80003180 <kinit+0xc8>
    80003134:	0534f663          	bgeu	s1,s3,80003180 <kinit+0xc8>
    80003138:	00001637          	lui	a2,0x1
    8000313c:	00100593          	li	a1,1
    80003140:	00048513          	mv	a0,s1
    80003144:	00000097          	auipc	ra,0x0
    80003148:	5e4080e7          	jalr	1508(ra) # 80003728 <__memset>
    8000314c:	00093783          	ld	a5,0(s2)
    80003150:	00f4b023          	sd	a5,0(s1)
    80003154:	00993023          	sd	s1,0(s2)
    80003158:	fd4498e3          	bne	s1,s4,80003128 <kinit+0x70>
    8000315c:	03813083          	ld	ra,56(sp)
    80003160:	03013403          	ld	s0,48(sp)
    80003164:	02813483          	ld	s1,40(sp)
    80003168:	02013903          	ld	s2,32(sp)
    8000316c:	01813983          	ld	s3,24(sp)
    80003170:	01013a03          	ld	s4,16(sp)
    80003174:	00813a83          	ld	s5,8(sp)
    80003178:	04010113          	addi	sp,sp,64
    8000317c:	00008067          	ret
    80003180:	00001517          	auipc	a0,0x1
    80003184:	10850513          	addi	a0,a0,264 # 80004288 <digits+0x18>
    80003188:	fffff097          	auipc	ra,0xfffff
    8000318c:	4b4080e7          	jalr	1204(ra) # 8000263c <panic>

0000000080003190 <freerange>:
    80003190:	fc010113          	addi	sp,sp,-64
    80003194:	000017b7          	lui	a5,0x1
    80003198:	02913423          	sd	s1,40(sp)
    8000319c:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    800031a0:	009504b3          	add	s1,a0,s1
    800031a4:	fffff537          	lui	a0,0xfffff
    800031a8:	02813823          	sd	s0,48(sp)
    800031ac:	02113c23          	sd	ra,56(sp)
    800031b0:	03213023          	sd	s2,32(sp)
    800031b4:	01313c23          	sd	s3,24(sp)
    800031b8:	01413823          	sd	s4,16(sp)
    800031bc:	01513423          	sd	s5,8(sp)
    800031c0:	01613023          	sd	s6,0(sp)
    800031c4:	04010413          	addi	s0,sp,64
    800031c8:	00a4f4b3          	and	s1,s1,a0
    800031cc:	00f487b3          	add	a5,s1,a5
    800031d0:	06f5e463          	bltu	a1,a5,80003238 <freerange+0xa8>
    800031d4:	00002a97          	auipc	s5,0x2
    800031d8:	70ca8a93          	addi	s5,s5,1804 # 800058e0 <end>
    800031dc:	0954e263          	bltu	s1,s5,80003260 <freerange+0xd0>
    800031e0:	01100993          	li	s3,17
    800031e4:	01b99993          	slli	s3,s3,0x1b
    800031e8:	0734fc63          	bgeu	s1,s3,80003260 <freerange+0xd0>
    800031ec:	00058a13          	mv	s4,a1
    800031f0:	00001917          	auipc	s2,0x1
    800031f4:	49090913          	addi	s2,s2,1168 # 80004680 <kmem>
    800031f8:	00002b37          	lui	s6,0x2
    800031fc:	0140006f          	j	80003210 <freerange+0x80>
    80003200:	000017b7          	lui	a5,0x1
    80003204:	00f484b3          	add	s1,s1,a5
    80003208:	0554ec63          	bltu	s1,s5,80003260 <freerange+0xd0>
    8000320c:	0534fa63          	bgeu	s1,s3,80003260 <freerange+0xd0>
    80003210:	00001637          	lui	a2,0x1
    80003214:	00100593          	li	a1,1
    80003218:	00048513          	mv	a0,s1
    8000321c:	00000097          	auipc	ra,0x0
    80003220:	50c080e7          	jalr	1292(ra) # 80003728 <__memset>
    80003224:	00093703          	ld	a4,0(s2)
    80003228:	016487b3          	add	a5,s1,s6
    8000322c:	00e4b023          	sd	a4,0(s1)
    80003230:	00993023          	sd	s1,0(s2)
    80003234:	fcfa76e3          	bgeu	s4,a5,80003200 <freerange+0x70>
    80003238:	03813083          	ld	ra,56(sp)
    8000323c:	03013403          	ld	s0,48(sp)
    80003240:	02813483          	ld	s1,40(sp)
    80003244:	02013903          	ld	s2,32(sp)
    80003248:	01813983          	ld	s3,24(sp)
    8000324c:	01013a03          	ld	s4,16(sp)
    80003250:	00813a83          	ld	s5,8(sp)
    80003254:	00013b03          	ld	s6,0(sp)
    80003258:	04010113          	addi	sp,sp,64
    8000325c:	00008067          	ret
    80003260:	00001517          	auipc	a0,0x1
    80003264:	02850513          	addi	a0,a0,40 # 80004288 <digits+0x18>
    80003268:	fffff097          	auipc	ra,0xfffff
    8000326c:	3d4080e7          	jalr	980(ra) # 8000263c <panic>

0000000080003270 <kfree>:
    80003270:	fe010113          	addi	sp,sp,-32
    80003274:	00813823          	sd	s0,16(sp)
    80003278:	00113c23          	sd	ra,24(sp)
    8000327c:	00913423          	sd	s1,8(sp)
    80003280:	02010413          	addi	s0,sp,32
    80003284:	03451793          	slli	a5,a0,0x34
    80003288:	04079c63          	bnez	a5,800032e0 <kfree+0x70>
    8000328c:	00002797          	auipc	a5,0x2
    80003290:	65478793          	addi	a5,a5,1620 # 800058e0 <end>
    80003294:	00050493          	mv	s1,a0
    80003298:	04f56463          	bltu	a0,a5,800032e0 <kfree+0x70>
    8000329c:	01100793          	li	a5,17
    800032a0:	01b79793          	slli	a5,a5,0x1b
    800032a4:	02f57e63          	bgeu	a0,a5,800032e0 <kfree+0x70>
    800032a8:	00001637          	lui	a2,0x1
    800032ac:	00100593          	li	a1,1
    800032b0:	00000097          	auipc	ra,0x0
    800032b4:	478080e7          	jalr	1144(ra) # 80003728 <__memset>
    800032b8:	00001797          	auipc	a5,0x1
    800032bc:	3c878793          	addi	a5,a5,968 # 80004680 <kmem>
    800032c0:	0007b703          	ld	a4,0(a5)
    800032c4:	01813083          	ld	ra,24(sp)
    800032c8:	01013403          	ld	s0,16(sp)
    800032cc:	00e4b023          	sd	a4,0(s1)
    800032d0:	0097b023          	sd	s1,0(a5)
    800032d4:	00813483          	ld	s1,8(sp)
    800032d8:	02010113          	addi	sp,sp,32
    800032dc:	00008067          	ret
    800032e0:	00001517          	auipc	a0,0x1
    800032e4:	fa850513          	addi	a0,a0,-88 # 80004288 <digits+0x18>
    800032e8:	fffff097          	auipc	ra,0xfffff
    800032ec:	354080e7          	jalr	852(ra) # 8000263c <panic>

00000000800032f0 <kalloc>:
    800032f0:	fe010113          	addi	sp,sp,-32
    800032f4:	00813823          	sd	s0,16(sp)
    800032f8:	00913423          	sd	s1,8(sp)
    800032fc:	00113c23          	sd	ra,24(sp)
    80003300:	02010413          	addi	s0,sp,32
    80003304:	00001797          	auipc	a5,0x1
    80003308:	37c78793          	addi	a5,a5,892 # 80004680 <kmem>
    8000330c:	0007b483          	ld	s1,0(a5)
    80003310:	02048063          	beqz	s1,80003330 <kalloc+0x40>
    80003314:	0004b703          	ld	a4,0(s1)
    80003318:	00001637          	lui	a2,0x1
    8000331c:	00500593          	li	a1,5
    80003320:	00048513          	mv	a0,s1
    80003324:	00e7b023          	sd	a4,0(a5)
    80003328:	00000097          	auipc	ra,0x0
    8000332c:	400080e7          	jalr	1024(ra) # 80003728 <__memset>
    80003330:	01813083          	ld	ra,24(sp)
    80003334:	01013403          	ld	s0,16(sp)
    80003338:	00048513          	mv	a0,s1
    8000333c:	00813483          	ld	s1,8(sp)
    80003340:	02010113          	addi	sp,sp,32
    80003344:	00008067          	ret

0000000080003348 <initlock>:
    80003348:	ff010113          	addi	sp,sp,-16
    8000334c:	00813423          	sd	s0,8(sp)
    80003350:	01010413          	addi	s0,sp,16
    80003354:	00813403          	ld	s0,8(sp)
    80003358:	00b53423          	sd	a1,8(a0)
    8000335c:	00052023          	sw	zero,0(a0)
    80003360:	00053823          	sd	zero,16(a0)
    80003364:	01010113          	addi	sp,sp,16
    80003368:	00008067          	ret

000000008000336c <acquire>:
    8000336c:	fe010113          	addi	sp,sp,-32
    80003370:	00813823          	sd	s0,16(sp)
    80003374:	00913423          	sd	s1,8(sp)
    80003378:	00113c23          	sd	ra,24(sp)
    8000337c:	01213023          	sd	s2,0(sp)
    80003380:	02010413          	addi	s0,sp,32
    80003384:	00050493          	mv	s1,a0
    80003388:	10002973          	csrr	s2,sstatus
    8000338c:	100027f3          	csrr	a5,sstatus
    80003390:	ffd7f793          	andi	a5,a5,-3
    80003394:	10079073          	csrw	sstatus,a5
    80003398:	fffff097          	auipc	ra,0xfffff
    8000339c:	8e4080e7          	jalr	-1820(ra) # 80001c7c <mycpu>
    800033a0:	07852783          	lw	a5,120(a0)
    800033a4:	06078e63          	beqz	a5,80003420 <acquire+0xb4>
    800033a8:	fffff097          	auipc	ra,0xfffff
    800033ac:	8d4080e7          	jalr	-1836(ra) # 80001c7c <mycpu>
    800033b0:	07852783          	lw	a5,120(a0)
    800033b4:	0004a703          	lw	a4,0(s1)
    800033b8:	0017879b          	addiw	a5,a5,1
    800033bc:	06f52c23          	sw	a5,120(a0)
    800033c0:	04071063          	bnez	a4,80003400 <acquire+0x94>
    800033c4:	00100713          	li	a4,1
    800033c8:	00070793          	mv	a5,a4
    800033cc:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    800033d0:	0007879b          	sext.w	a5,a5
    800033d4:	fe079ae3          	bnez	a5,800033c8 <acquire+0x5c>
    800033d8:	0ff0000f          	fence
    800033dc:	fffff097          	auipc	ra,0xfffff
    800033e0:	8a0080e7          	jalr	-1888(ra) # 80001c7c <mycpu>
    800033e4:	01813083          	ld	ra,24(sp)
    800033e8:	01013403          	ld	s0,16(sp)
    800033ec:	00a4b823          	sd	a0,16(s1)
    800033f0:	00013903          	ld	s2,0(sp)
    800033f4:	00813483          	ld	s1,8(sp)
    800033f8:	02010113          	addi	sp,sp,32
    800033fc:	00008067          	ret
    80003400:	0104b903          	ld	s2,16(s1)
    80003404:	fffff097          	auipc	ra,0xfffff
    80003408:	878080e7          	jalr	-1928(ra) # 80001c7c <mycpu>
    8000340c:	faa91ce3          	bne	s2,a0,800033c4 <acquire+0x58>
    80003410:	00001517          	auipc	a0,0x1
    80003414:	e8050513          	addi	a0,a0,-384 # 80004290 <digits+0x20>
    80003418:	fffff097          	auipc	ra,0xfffff
    8000341c:	224080e7          	jalr	548(ra) # 8000263c <panic>
    80003420:	00195913          	srli	s2,s2,0x1
    80003424:	fffff097          	auipc	ra,0xfffff
    80003428:	858080e7          	jalr	-1960(ra) # 80001c7c <mycpu>
    8000342c:	00197913          	andi	s2,s2,1
    80003430:	07252e23          	sw	s2,124(a0)
    80003434:	f75ff06f          	j	800033a8 <acquire+0x3c>

0000000080003438 <release>:
    80003438:	fe010113          	addi	sp,sp,-32
    8000343c:	00813823          	sd	s0,16(sp)
    80003440:	00113c23          	sd	ra,24(sp)
    80003444:	00913423          	sd	s1,8(sp)
    80003448:	01213023          	sd	s2,0(sp)
    8000344c:	02010413          	addi	s0,sp,32
    80003450:	00052783          	lw	a5,0(a0)
    80003454:	00079a63          	bnez	a5,80003468 <release+0x30>
    80003458:	00001517          	auipc	a0,0x1
    8000345c:	e4050513          	addi	a0,a0,-448 # 80004298 <digits+0x28>
    80003460:	fffff097          	auipc	ra,0xfffff
    80003464:	1dc080e7          	jalr	476(ra) # 8000263c <panic>
    80003468:	01053903          	ld	s2,16(a0)
    8000346c:	00050493          	mv	s1,a0
    80003470:	fffff097          	auipc	ra,0xfffff
    80003474:	80c080e7          	jalr	-2036(ra) # 80001c7c <mycpu>
    80003478:	fea910e3          	bne	s2,a0,80003458 <release+0x20>
    8000347c:	0004b823          	sd	zero,16(s1)
    80003480:	0ff0000f          	fence
    80003484:	0f50000f          	fence	iorw,ow
    80003488:	0804a02f          	amoswap.w	zero,zero,(s1)
    8000348c:	ffffe097          	auipc	ra,0xffffe
    80003490:	7f0080e7          	jalr	2032(ra) # 80001c7c <mycpu>
    80003494:	100027f3          	csrr	a5,sstatus
    80003498:	0027f793          	andi	a5,a5,2
    8000349c:	04079a63          	bnez	a5,800034f0 <release+0xb8>
    800034a0:	07852783          	lw	a5,120(a0)
    800034a4:	02f05e63          	blez	a5,800034e0 <release+0xa8>
    800034a8:	fff7871b          	addiw	a4,a5,-1
    800034ac:	06e52c23          	sw	a4,120(a0)
    800034b0:	00071c63          	bnez	a4,800034c8 <release+0x90>
    800034b4:	07c52783          	lw	a5,124(a0)
    800034b8:	00078863          	beqz	a5,800034c8 <release+0x90>
    800034bc:	100027f3          	csrr	a5,sstatus
    800034c0:	0027e793          	ori	a5,a5,2
    800034c4:	10079073          	csrw	sstatus,a5
    800034c8:	01813083          	ld	ra,24(sp)
    800034cc:	01013403          	ld	s0,16(sp)
    800034d0:	00813483          	ld	s1,8(sp)
    800034d4:	00013903          	ld	s2,0(sp)
    800034d8:	02010113          	addi	sp,sp,32
    800034dc:	00008067          	ret
    800034e0:	00001517          	auipc	a0,0x1
    800034e4:	dd850513          	addi	a0,a0,-552 # 800042b8 <digits+0x48>
    800034e8:	fffff097          	auipc	ra,0xfffff
    800034ec:	154080e7          	jalr	340(ra) # 8000263c <panic>
    800034f0:	00001517          	auipc	a0,0x1
    800034f4:	db050513          	addi	a0,a0,-592 # 800042a0 <digits+0x30>
    800034f8:	fffff097          	auipc	ra,0xfffff
    800034fc:	144080e7          	jalr	324(ra) # 8000263c <panic>

0000000080003500 <holding>:
    80003500:	00052783          	lw	a5,0(a0)
    80003504:	00079663          	bnez	a5,80003510 <holding+0x10>
    80003508:	00000513          	li	a0,0
    8000350c:	00008067          	ret
    80003510:	fe010113          	addi	sp,sp,-32
    80003514:	00813823          	sd	s0,16(sp)
    80003518:	00913423          	sd	s1,8(sp)
    8000351c:	00113c23          	sd	ra,24(sp)
    80003520:	02010413          	addi	s0,sp,32
    80003524:	01053483          	ld	s1,16(a0)
    80003528:	ffffe097          	auipc	ra,0xffffe
    8000352c:	754080e7          	jalr	1876(ra) # 80001c7c <mycpu>
    80003530:	01813083          	ld	ra,24(sp)
    80003534:	01013403          	ld	s0,16(sp)
    80003538:	40a48533          	sub	a0,s1,a0
    8000353c:	00153513          	seqz	a0,a0
    80003540:	00813483          	ld	s1,8(sp)
    80003544:	02010113          	addi	sp,sp,32
    80003548:	00008067          	ret

000000008000354c <push_off>:
    8000354c:	fe010113          	addi	sp,sp,-32
    80003550:	00813823          	sd	s0,16(sp)
    80003554:	00113c23          	sd	ra,24(sp)
    80003558:	00913423          	sd	s1,8(sp)
    8000355c:	02010413          	addi	s0,sp,32
    80003560:	100024f3          	csrr	s1,sstatus
    80003564:	100027f3          	csrr	a5,sstatus
    80003568:	ffd7f793          	andi	a5,a5,-3
    8000356c:	10079073          	csrw	sstatus,a5
    80003570:	ffffe097          	auipc	ra,0xffffe
    80003574:	70c080e7          	jalr	1804(ra) # 80001c7c <mycpu>
    80003578:	07852783          	lw	a5,120(a0)
    8000357c:	02078663          	beqz	a5,800035a8 <push_off+0x5c>
    80003580:	ffffe097          	auipc	ra,0xffffe
    80003584:	6fc080e7          	jalr	1788(ra) # 80001c7c <mycpu>
    80003588:	07852783          	lw	a5,120(a0)
    8000358c:	01813083          	ld	ra,24(sp)
    80003590:	01013403          	ld	s0,16(sp)
    80003594:	0017879b          	addiw	a5,a5,1
    80003598:	06f52c23          	sw	a5,120(a0)
    8000359c:	00813483          	ld	s1,8(sp)
    800035a0:	02010113          	addi	sp,sp,32
    800035a4:	00008067          	ret
    800035a8:	0014d493          	srli	s1,s1,0x1
    800035ac:	ffffe097          	auipc	ra,0xffffe
    800035b0:	6d0080e7          	jalr	1744(ra) # 80001c7c <mycpu>
    800035b4:	0014f493          	andi	s1,s1,1
    800035b8:	06952e23          	sw	s1,124(a0)
    800035bc:	fc5ff06f          	j	80003580 <push_off+0x34>

00000000800035c0 <pop_off>:
    800035c0:	ff010113          	addi	sp,sp,-16
    800035c4:	00813023          	sd	s0,0(sp)
    800035c8:	00113423          	sd	ra,8(sp)
    800035cc:	01010413          	addi	s0,sp,16
    800035d0:	ffffe097          	auipc	ra,0xffffe
    800035d4:	6ac080e7          	jalr	1708(ra) # 80001c7c <mycpu>
    800035d8:	100027f3          	csrr	a5,sstatus
    800035dc:	0027f793          	andi	a5,a5,2
    800035e0:	04079663          	bnez	a5,8000362c <pop_off+0x6c>
    800035e4:	07852783          	lw	a5,120(a0)
    800035e8:	02f05a63          	blez	a5,8000361c <pop_off+0x5c>
    800035ec:	fff7871b          	addiw	a4,a5,-1
    800035f0:	06e52c23          	sw	a4,120(a0)
    800035f4:	00071c63          	bnez	a4,8000360c <pop_off+0x4c>
    800035f8:	07c52783          	lw	a5,124(a0)
    800035fc:	00078863          	beqz	a5,8000360c <pop_off+0x4c>
    80003600:	100027f3          	csrr	a5,sstatus
    80003604:	0027e793          	ori	a5,a5,2
    80003608:	10079073          	csrw	sstatus,a5
    8000360c:	00813083          	ld	ra,8(sp)
    80003610:	00013403          	ld	s0,0(sp)
    80003614:	01010113          	addi	sp,sp,16
    80003618:	00008067          	ret
    8000361c:	00001517          	auipc	a0,0x1
    80003620:	c9c50513          	addi	a0,a0,-868 # 800042b8 <digits+0x48>
    80003624:	fffff097          	auipc	ra,0xfffff
    80003628:	018080e7          	jalr	24(ra) # 8000263c <panic>
    8000362c:	00001517          	auipc	a0,0x1
    80003630:	c7450513          	addi	a0,a0,-908 # 800042a0 <digits+0x30>
    80003634:	fffff097          	auipc	ra,0xfffff
    80003638:	008080e7          	jalr	8(ra) # 8000263c <panic>

000000008000363c <push_on>:
    8000363c:	fe010113          	addi	sp,sp,-32
    80003640:	00813823          	sd	s0,16(sp)
    80003644:	00113c23          	sd	ra,24(sp)
    80003648:	00913423          	sd	s1,8(sp)
    8000364c:	02010413          	addi	s0,sp,32
    80003650:	100024f3          	csrr	s1,sstatus
    80003654:	100027f3          	csrr	a5,sstatus
    80003658:	0027e793          	ori	a5,a5,2
    8000365c:	10079073          	csrw	sstatus,a5
    80003660:	ffffe097          	auipc	ra,0xffffe
    80003664:	61c080e7          	jalr	1564(ra) # 80001c7c <mycpu>
    80003668:	07852783          	lw	a5,120(a0)
    8000366c:	02078663          	beqz	a5,80003698 <push_on+0x5c>
    80003670:	ffffe097          	auipc	ra,0xffffe
    80003674:	60c080e7          	jalr	1548(ra) # 80001c7c <mycpu>
    80003678:	07852783          	lw	a5,120(a0)
    8000367c:	01813083          	ld	ra,24(sp)
    80003680:	01013403          	ld	s0,16(sp)
    80003684:	0017879b          	addiw	a5,a5,1
    80003688:	06f52c23          	sw	a5,120(a0)
    8000368c:	00813483          	ld	s1,8(sp)
    80003690:	02010113          	addi	sp,sp,32
    80003694:	00008067          	ret
    80003698:	0014d493          	srli	s1,s1,0x1
    8000369c:	ffffe097          	auipc	ra,0xffffe
    800036a0:	5e0080e7          	jalr	1504(ra) # 80001c7c <mycpu>
    800036a4:	0014f493          	andi	s1,s1,1
    800036a8:	06952e23          	sw	s1,124(a0)
    800036ac:	fc5ff06f          	j	80003670 <push_on+0x34>

00000000800036b0 <pop_on>:
    800036b0:	ff010113          	addi	sp,sp,-16
    800036b4:	00813023          	sd	s0,0(sp)
    800036b8:	00113423          	sd	ra,8(sp)
    800036bc:	01010413          	addi	s0,sp,16
    800036c0:	ffffe097          	auipc	ra,0xffffe
    800036c4:	5bc080e7          	jalr	1468(ra) # 80001c7c <mycpu>
    800036c8:	100027f3          	csrr	a5,sstatus
    800036cc:	0027f793          	andi	a5,a5,2
    800036d0:	04078463          	beqz	a5,80003718 <pop_on+0x68>
    800036d4:	07852783          	lw	a5,120(a0)
    800036d8:	02f05863          	blez	a5,80003708 <pop_on+0x58>
    800036dc:	fff7879b          	addiw	a5,a5,-1
    800036e0:	06f52c23          	sw	a5,120(a0)
    800036e4:	07853783          	ld	a5,120(a0)
    800036e8:	00079863          	bnez	a5,800036f8 <pop_on+0x48>
    800036ec:	100027f3          	csrr	a5,sstatus
    800036f0:	ffd7f793          	andi	a5,a5,-3
    800036f4:	10079073          	csrw	sstatus,a5
    800036f8:	00813083          	ld	ra,8(sp)
    800036fc:	00013403          	ld	s0,0(sp)
    80003700:	01010113          	addi	sp,sp,16
    80003704:	00008067          	ret
    80003708:	00001517          	auipc	a0,0x1
    8000370c:	bd850513          	addi	a0,a0,-1064 # 800042e0 <digits+0x70>
    80003710:	fffff097          	auipc	ra,0xfffff
    80003714:	f2c080e7          	jalr	-212(ra) # 8000263c <panic>
    80003718:	00001517          	auipc	a0,0x1
    8000371c:	ba850513          	addi	a0,a0,-1112 # 800042c0 <digits+0x50>
    80003720:	fffff097          	auipc	ra,0xfffff
    80003724:	f1c080e7          	jalr	-228(ra) # 8000263c <panic>

0000000080003728 <__memset>:
    80003728:	ff010113          	addi	sp,sp,-16
    8000372c:	00813423          	sd	s0,8(sp)
    80003730:	01010413          	addi	s0,sp,16
    80003734:	1a060e63          	beqz	a2,800038f0 <__memset+0x1c8>
    80003738:	40a007b3          	neg	a5,a0
    8000373c:	0077f793          	andi	a5,a5,7
    80003740:	00778693          	addi	a3,a5,7
    80003744:	00b00813          	li	a6,11
    80003748:	0ff5f593          	andi	a1,a1,255
    8000374c:	fff6071b          	addiw	a4,a2,-1
    80003750:	1b06e663          	bltu	a3,a6,800038fc <__memset+0x1d4>
    80003754:	1cd76463          	bltu	a4,a3,8000391c <__memset+0x1f4>
    80003758:	1a078e63          	beqz	a5,80003914 <__memset+0x1ec>
    8000375c:	00b50023          	sb	a1,0(a0)
    80003760:	00100713          	li	a4,1
    80003764:	1ae78463          	beq	a5,a4,8000390c <__memset+0x1e4>
    80003768:	00b500a3          	sb	a1,1(a0)
    8000376c:	00200713          	li	a4,2
    80003770:	1ae78a63          	beq	a5,a4,80003924 <__memset+0x1fc>
    80003774:	00b50123          	sb	a1,2(a0)
    80003778:	00300713          	li	a4,3
    8000377c:	18e78463          	beq	a5,a4,80003904 <__memset+0x1dc>
    80003780:	00b501a3          	sb	a1,3(a0)
    80003784:	00400713          	li	a4,4
    80003788:	1ae78263          	beq	a5,a4,8000392c <__memset+0x204>
    8000378c:	00b50223          	sb	a1,4(a0)
    80003790:	00500713          	li	a4,5
    80003794:	1ae78063          	beq	a5,a4,80003934 <__memset+0x20c>
    80003798:	00b502a3          	sb	a1,5(a0)
    8000379c:	00700713          	li	a4,7
    800037a0:	18e79e63          	bne	a5,a4,8000393c <__memset+0x214>
    800037a4:	00b50323          	sb	a1,6(a0)
    800037a8:	00700e93          	li	t4,7
    800037ac:	00859713          	slli	a4,a1,0x8
    800037b0:	00e5e733          	or	a4,a1,a4
    800037b4:	01059e13          	slli	t3,a1,0x10
    800037b8:	01c76e33          	or	t3,a4,t3
    800037bc:	01859313          	slli	t1,a1,0x18
    800037c0:	006e6333          	or	t1,t3,t1
    800037c4:	02059893          	slli	a7,a1,0x20
    800037c8:	40f60e3b          	subw	t3,a2,a5
    800037cc:	011368b3          	or	a7,t1,a7
    800037d0:	02859813          	slli	a6,a1,0x28
    800037d4:	0108e833          	or	a6,a7,a6
    800037d8:	03059693          	slli	a3,a1,0x30
    800037dc:	003e589b          	srliw	a7,t3,0x3
    800037e0:	00d866b3          	or	a3,a6,a3
    800037e4:	03859713          	slli	a4,a1,0x38
    800037e8:	00389813          	slli	a6,a7,0x3
    800037ec:	00f507b3          	add	a5,a0,a5
    800037f0:	00e6e733          	or	a4,a3,a4
    800037f4:	000e089b          	sext.w	a7,t3
    800037f8:	00f806b3          	add	a3,a6,a5
    800037fc:	00e7b023          	sd	a4,0(a5)
    80003800:	00878793          	addi	a5,a5,8
    80003804:	fed79ce3          	bne	a5,a3,800037fc <__memset+0xd4>
    80003808:	ff8e7793          	andi	a5,t3,-8
    8000380c:	0007871b          	sext.w	a4,a5
    80003810:	01d787bb          	addw	a5,a5,t4
    80003814:	0ce88e63          	beq	a7,a4,800038f0 <__memset+0x1c8>
    80003818:	00f50733          	add	a4,a0,a5
    8000381c:	00b70023          	sb	a1,0(a4)
    80003820:	0017871b          	addiw	a4,a5,1
    80003824:	0cc77663          	bgeu	a4,a2,800038f0 <__memset+0x1c8>
    80003828:	00e50733          	add	a4,a0,a4
    8000382c:	00b70023          	sb	a1,0(a4)
    80003830:	0027871b          	addiw	a4,a5,2
    80003834:	0ac77e63          	bgeu	a4,a2,800038f0 <__memset+0x1c8>
    80003838:	00e50733          	add	a4,a0,a4
    8000383c:	00b70023          	sb	a1,0(a4)
    80003840:	0037871b          	addiw	a4,a5,3
    80003844:	0ac77663          	bgeu	a4,a2,800038f0 <__memset+0x1c8>
    80003848:	00e50733          	add	a4,a0,a4
    8000384c:	00b70023          	sb	a1,0(a4)
    80003850:	0047871b          	addiw	a4,a5,4
    80003854:	08c77e63          	bgeu	a4,a2,800038f0 <__memset+0x1c8>
    80003858:	00e50733          	add	a4,a0,a4
    8000385c:	00b70023          	sb	a1,0(a4)
    80003860:	0057871b          	addiw	a4,a5,5
    80003864:	08c77663          	bgeu	a4,a2,800038f0 <__memset+0x1c8>
    80003868:	00e50733          	add	a4,a0,a4
    8000386c:	00b70023          	sb	a1,0(a4)
    80003870:	0067871b          	addiw	a4,a5,6
    80003874:	06c77e63          	bgeu	a4,a2,800038f0 <__memset+0x1c8>
    80003878:	00e50733          	add	a4,a0,a4
    8000387c:	00b70023          	sb	a1,0(a4)
    80003880:	0077871b          	addiw	a4,a5,7
    80003884:	06c77663          	bgeu	a4,a2,800038f0 <__memset+0x1c8>
    80003888:	00e50733          	add	a4,a0,a4
    8000388c:	00b70023          	sb	a1,0(a4)
    80003890:	0087871b          	addiw	a4,a5,8
    80003894:	04c77e63          	bgeu	a4,a2,800038f0 <__memset+0x1c8>
    80003898:	00e50733          	add	a4,a0,a4
    8000389c:	00b70023          	sb	a1,0(a4)
    800038a0:	0097871b          	addiw	a4,a5,9
    800038a4:	04c77663          	bgeu	a4,a2,800038f0 <__memset+0x1c8>
    800038a8:	00e50733          	add	a4,a0,a4
    800038ac:	00b70023          	sb	a1,0(a4)
    800038b0:	00a7871b          	addiw	a4,a5,10
    800038b4:	02c77e63          	bgeu	a4,a2,800038f0 <__memset+0x1c8>
    800038b8:	00e50733          	add	a4,a0,a4
    800038bc:	00b70023          	sb	a1,0(a4)
    800038c0:	00b7871b          	addiw	a4,a5,11
    800038c4:	02c77663          	bgeu	a4,a2,800038f0 <__memset+0x1c8>
    800038c8:	00e50733          	add	a4,a0,a4
    800038cc:	00b70023          	sb	a1,0(a4)
    800038d0:	00c7871b          	addiw	a4,a5,12
    800038d4:	00c77e63          	bgeu	a4,a2,800038f0 <__memset+0x1c8>
    800038d8:	00e50733          	add	a4,a0,a4
    800038dc:	00b70023          	sb	a1,0(a4)
    800038e0:	00d7879b          	addiw	a5,a5,13
    800038e4:	00c7f663          	bgeu	a5,a2,800038f0 <__memset+0x1c8>
    800038e8:	00f507b3          	add	a5,a0,a5
    800038ec:	00b78023          	sb	a1,0(a5)
    800038f0:	00813403          	ld	s0,8(sp)
    800038f4:	01010113          	addi	sp,sp,16
    800038f8:	00008067          	ret
    800038fc:	00b00693          	li	a3,11
    80003900:	e55ff06f          	j	80003754 <__memset+0x2c>
    80003904:	00300e93          	li	t4,3
    80003908:	ea5ff06f          	j	800037ac <__memset+0x84>
    8000390c:	00100e93          	li	t4,1
    80003910:	e9dff06f          	j	800037ac <__memset+0x84>
    80003914:	00000e93          	li	t4,0
    80003918:	e95ff06f          	j	800037ac <__memset+0x84>
    8000391c:	00000793          	li	a5,0
    80003920:	ef9ff06f          	j	80003818 <__memset+0xf0>
    80003924:	00200e93          	li	t4,2
    80003928:	e85ff06f          	j	800037ac <__memset+0x84>
    8000392c:	00400e93          	li	t4,4
    80003930:	e7dff06f          	j	800037ac <__memset+0x84>
    80003934:	00500e93          	li	t4,5
    80003938:	e75ff06f          	j	800037ac <__memset+0x84>
    8000393c:	00600e93          	li	t4,6
    80003940:	e6dff06f          	j	800037ac <__memset+0x84>

0000000080003944 <__memmove>:
    80003944:	ff010113          	addi	sp,sp,-16
    80003948:	00813423          	sd	s0,8(sp)
    8000394c:	01010413          	addi	s0,sp,16
    80003950:	0e060863          	beqz	a2,80003a40 <__memmove+0xfc>
    80003954:	fff6069b          	addiw	a3,a2,-1
    80003958:	0006881b          	sext.w	a6,a3
    8000395c:	0ea5e863          	bltu	a1,a0,80003a4c <__memmove+0x108>
    80003960:	00758713          	addi	a4,a1,7
    80003964:	00a5e7b3          	or	a5,a1,a0
    80003968:	40a70733          	sub	a4,a4,a0
    8000396c:	0077f793          	andi	a5,a5,7
    80003970:	00f73713          	sltiu	a4,a4,15
    80003974:	00174713          	xori	a4,a4,1
    80003978:	0017b793          	seqz	a5,a5
    8000397c:	00e7f7b3          	and	a5,a5,a4
    80003980:	10078863          	beqz	a5,80003a90 <__memmove+0x14c>
    80003984:	00900793          	li	a5,9
    80003988:	1107f463          	bgeu	a5,a6,80003a90 <__memmove+0x14c>
    8000398c:	0036581b          	srliw	a6,a2,0x3
    80003990:	fff8081b          	addiw	a6,a6,-1
    80003994:	02081813          	slli	a6,a6,0x20
    80003998:	01d85893          	srli	a7,a6,0x1d
    8000399c:	00858813          	addi	a6,a1,8
    800039a0:	00058793          	mv	a5,a1
    800039a4:	00050713          	mv	a4,a0
    800039a8:	01088833          	add	a6,a7,a6
    800039ac:	0007b883          	ld	a7,0(a5)
    800039b0:	00878793          	addi	a5,a5,8
    800039b4:	00870713          	addi	a4,a4,8
    800039b8:	ff173c23          	sd	a7,-8(a4)
    800039bc:	ff0798e3          	bne	a5,a6,800039ac <__memmove+0x68>
    800039c0:	ff867713          	andi	a4,a2,-8
    800039c4:	02071793          	slli	a5,a4,0x20
    800039c8:	0207d793          	srli	a5,a5,0x20
    800039cc:	00f585b3          	add	a1,a1,a5
    800039d0:	40e686bb          	subw	a3,a3,a4
    800039d4:	00f507b3          	add	a5,a0,a5
    800039d8:	06e60463          	beq	a2,a4,80003a40 <__memmove+0xfc>
    800039dc:	0005c703          	lbu	a4,0(a1)
    800039e0:	00e78023          	sb	a4,0(a5)
    800039e4:	04068e63          	beqz	a3,80003a40 <__memmove+0xfc>
    800039e8:	0015c603          	lbu	a2,1(a1)
    800039ec:	00100713          	li	a4,1
    800039f0:	00c780a3          	sb	a2,1(a5)
    800039f4:	04e68663          	beq	a3,a4,80003a40 <__memmove+0xfc>
    800039f8:	0025c603          	lbu	a2,2(a1)
    800039fc:	00200713          	li	a4,2
    80003a00:	00c78123          	sb	a2,2(a5)
    80003a04:	02e68e63          	beq	a3,a4,80003a40 <__memmove+0xfc>
    80003a08:	0035c603          	lbu	a2,3(a1)
    80003a0c:	00300713          	li	a4,3
    80003a10:	00c781a3          	sb	a2,3(a5)
    80003a14:	02e68663          	beq	a3,a4,80003a40 <__memmove+0xfc>
    80003a18:	0045c603          	lbu	a2,4(a1)
    80003a1c:	00400713          	li	a4,4
    80003a20:	00c78223          	sb	a2,4(a5)
    80003a24:	00e68e63          	beq	a3,a4,80003a40 <__memmove+0xfc>
    80003a28:	0055c603          	lbu	a2,5(a1)
    80003a2c:	00500713          	li	a4,5
    80003a30:	00c782a3          	sb	a2,5(a5)
    80003a34:	00e68663          	beq	a3,a4,80003a40 <__memmove+0xfc>
    80003a38:	0065c703          	lbu	a4,6(a1)
    80003a3c:	00e78323          	sb	a4,6(a5)
    80003a40:	00813403          	ld	s0,8(sp)
    80003a44:	01010113          	addi	sp,sp,16
    80003a48:	00008067          	ret
    80003a4c:	02061713          	slli	a4,a2,0x20
    80003a50:	02075713          	srli	a4,a4,0x20
    80003a54:	00e587b3          	add	a5,a1,a4
    80003a58:	f0f574e3          	bgeu	a0,a5,80003960 <__memmove+0x1c>
    80003a5c:	02069613          	slli	a2,a3,0x20
    80003a60:	02065613          	srli	a2,a2,0x20
    80003a64:	fff64613          	not	a2,a2
    80003a68:	00e50733          	add	a4,a0,a4
    80003a6c:	00c78633          	add	a2,a5,a2
    80003a70:	fff7c683          	lbu	a3,-1(a5)
    80003a74:	fff78793          	addi	a5,a5,-1
    80003a78:	fff70713          	addi	a4,a4,-1
    80003a7c:	00d70023          	sb	a3,0(a4)
    80003a80:	fec798e3          	bne	a5,a2,80003a70 <__memmove+0x12c>
    80003a84:	00813403          	ld	s0,8(sp)
    80003a88:	01010113          	addi	sp,sp,16
    80003a8c:	00008067          	ret
    80003a90:	02069713          	slli	a4,a3,0x20
    80003a94:	02075713          	srli	a4,a4,0x20
    80003a98:	00170713          	addi	a4,a4,1
    80003a9c:	00e50733          	add	a4,a0,a4
    80003aa0:	00050793          	mv	a5,a0
    80003aa4:	0005c683          	lbu	a3,0(a1)
    80003aa8:	00178793          	addi	a5,a5,1
    80003aac:	00158593          	addi	a1,a1,1
    80003ab0:	fed78fa3          	sb	a3,-1(a5)
    80003ab4:	fee798e3          	bne	a5,a4,80003aa4 <__memmove+0x160>
    80003ab8:	f89ff06f          	j	80003a40 <__memmove+0xfc>
	...
