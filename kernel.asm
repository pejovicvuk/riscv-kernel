
kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00004117          	auipc	sp,0x4
    80000004:	7e813103          	ld	sp,2024(sp) # 800047e8 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	00001537          	lui	a0,0x1
    8000000c:	f14025f3          	csrr	a1,mhartid
    80000010:	00158593          	addi	a1,a1,1
    80000014:	02b50533          	mul	a0,a0,a1
    80000018:	00a10133          	add	sp,sp,a0
    8000001c:	581010ef          	jal	ra,80001d9c <start>

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
    80001040:	30c000ef          	jal	ra,8000134c <handleTrap>

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

0000000080001168 <_Z13thread_createPP7_threadPFvPvES2_>:

int thread_create(thread_t* handle, void (*start_routine)(void*), void* arg) {
    80001168:	fd010113          	addi	sp,sp,-48
    8000116c:	02113423          	sd	ra,40(sp)
    80001170:	02813023          	sd	s0,32(sp)
    80001174:	00913c23          	sd	s1,24(sp)
    80001178:	01213823          	sd	s2,16(sp)
    8000117c:	01313423          	sd	s3,8(sp)
    80001180:	03010413          	addi	s0,sp,48
    if (!handle || !start_routine) return -1;
    80001184:	06050a63          	beqz	a0,800011f8 <_Z13thread_createPP7_threadPFvPvES2_+0x90>
    80001188:	00050493          	mv	s1,a0
    8000118c:	00058913          	mv	s2,a1
    80001190:	00060993          	mv	s3,a2
    80001194:	06058663          	beqz	a1,80001200 <_Z13thread_createPP7_threadPFvPvES2_+0x98>

    // pdf, abi poziv 0x11: stek niti alocira OVAJ sloj (kroz mem_alloc,
    // dakle jos jedan ecall), pa ga prosledjuje jezgru kao 4. argument
    void* stackSpace = mem_alloc(DEFAULT_STACK_SIZE);
    80001198:	00001537          	lui	a0,0x1
    8000119c:	00000097          	auipc	ra,0x0
    800011a0:	f70080e7          	jalr	-144(ra) # 8000110c <_Z9mem_allocm>
    800011a4:	00050713          	mv	a4,a0
    if (!stackSpace) return -2;
    800011a8:	06050063          	beqz	a0,80001208 <_Z13thread_createPP7_threadPFvPvES2_+0xa0>

    register uint64 code asm("a0") = 0x11;
    800011ac:	01100513          	li	a0,17
    register uint64 h    asm("a1") = (uint64)handle;
    800011b0:	00048593          	mv	a1,s1
    register uint64 rt   asm("a2") = (uint64)start_routine;
    800011b4:	00090613          	mv	a2,s2
    register uint64 ag   asm("a3") = (uint64)arg;
    800011b8:	00098693          	mv	a3,s3
    register uint64 st   asm("a4") = (uint64)stackSpace;
    asm volatile("ecall"
        : "=r"(code)
        : "r"(code), "r"(h), "r"(rt), "r"(ag), "r"(st)
        : "memory");
    800011bc:	00000073          	ecall

    int result = (int)code;
    800011c0:	0005049b          	sext.w	s1,a0
    if (result != 0) mem_free(stackSpace);   // nit nije nastala - vrati stek
    800011c4:	02049263          	bnez	s1,800011e8 <_Z13thread_createPP7_threadPFvPvES2_+0x80>
    return result;
}
    800011c8:	00048513          	mv	a0,s1
    800011cc:	02813083          	ld	ra,40(sp)
    800011d0:	02013403          	ld	s0,32(sp)
    800011d4:	01813483          	ld	s1,24(sp)
    800011d8:	01013903          	ld	s2,16(sp)
    800011dc:	00813983          	ld	s3,8(sp)
    800011e0:	03010113          	addi	sp,sp,48
    800011e4:	00008067          	ret
    if (result != 0) mem_free(stackSpace);   // nit nije nastala - vrati stek
    800011e8:	00070513          	mv	a0,a4
    800011ec:	00000097          	auipc	ra,0x0
    800011f0:	f54080e7          	jalr	-172(ra) # 80001140 <_Z8mem_freePv>
    800011f4:	fd5ff06f          	j	800011c8 <_Z13thread_createPP7_threadPFvPvES2_+0x60>
    if (!handle || !start_routine) return -1;
    800011f8:	fff00493          	li	s1,-1
    800011fc:	fcdff06f          	j	800011c8 <_Z13thread_createPP7_threadPFvPvES2_+0x60>
    80001200:	fff00493          	li	s1,-1
    80001204:	fc5ff06f          	j	800011c8 <_Z13thread_createPP7_threadPFvPvES2_+0x60>
    if (!stackSpace) return -2;
    80001208:	ffe00493          	li	s1,-2
    8000120c:	fbdff06f          	j	800011c8 <_Z13thread_createPP7_threadPFvPvES2_+0x60>

0000000080001210 <_Z11thread_exitv>:

int thread_exit() {
    80001210:	ff010113          	addi	sp,sp,-16
    80001214:	00813423          	sd	s0,8(sp)
    80001218:	01010413          	addi	s0,sp,16
    register uint64 code asm("a0") = 0x12;
    8000121c:	01200513          	li	a0,18
    asm volatile("ecall" : "=r"(code) : "r"(code) : "memory");
    80001220:	00000073          	ecall
    return (int)code;   // dovde stize samo u slucaju neuspeha
}
    80001224:	0005051b          	sext.w	a0,a0
    80001228:	00813403          	ld	s0,8(sp)
    8000122c:	01010113          	addi	sp,sp,16
    80001230:	00008067          	ret

0000000080001234 <_Z15thread_dispatchv>:

void thread_dispatch() {
    80001234:	ff010113          	addi	sp,sp,-16
    80001238:	00813423          	sd	s0,8(sp)
    8000123c:	01010413          	addi	s0,sp,16
    register uint64 code asm("a0") = 0x13;
    80001240:	01300513          	li	a0,19
    asm volatile("ecall" : "=r"(code) : "r"(code) : "memory");
    80001244:	00000073          	ecall
}
    80001248:	00813403          	ld	s0,8(sp)
    8000124c:	01010113          	addi	sp,sp,16
    80001250:	00008067          	ret

0000000080001254 <_Z5kputcc>:
#include "../h/print.hpp"

// posalji jedan znak kontroleru konzole (polling)
void kputc(char c) {
    80001254:	ff010113          	addi	sp,sp,-16
    80001258:	00813423          	sd	s0,8(sp)
    8000125c:	01010413          	addi	s0,sp,16
    // CONSOLE_STATUS je adresa (konstanta iz hw.h); da procitamo bajt sa te
    // adrese, kastujemo broj u pokazivac na volatile char pa dereferenciramo.
    // volatile: vrednost menja hardver, kompajler mora stvarno da cita
    // memoriju u svakom prolazu petlje, ne sme da kesira
    while ((*(volatile char*)CONSOLE_STATUS & (1 << 5)) == 0) {
    80001260:	00003797          	auipc	a5,0x3
    80001264:	db07b783          	ld	a5,-592(a5) # 80004010 <CONSOLE_STATUS>
    80001268:	0007c783          	lbu	a5,0(a5)
    8000126c:	0ff7f793          	andi	a5,a5,255
    80001270:	0207f793          	andi	a5,a5,32
    80001274:	fe0786e3          	beqz	a5,80001260 <_Z5kputcc+0xc>
        // bit 5 == 0 znaci "nisam spreman da primim znak za slanje"
    }
    // spreman: upisi bajt u registar za slanje
    *(volatile char*)CONSOLE_TX_DATA = c;
    80001278:	00003797          	auipc	a5,0x3
    8000127c:	d907b783          	ld	a5,-624(a5) # 80004008 <CONSOLE_TX_DATA>
    80001280:	00a78023          	sb	a0,0(a5)
}
    80001284:	00813403          	ld	s0,8(sp)
    80001288:	01010113          	addi	sp,sp,16
    8000128c:	00008067          	ret

0000000080001290 <_Z5kputsPKc>:

// ispisi ceo string, znak po znak
void kputs(const char* s) {
    80001290:	fe010113          	addi	sp,sp,-32
    80001294:	00113c23          	sd	ra,24(sp)
    80001298:	00813823          	sd	s0,16(sp)
    8000129c:	00913423          	sd	s1,8(sp)
    800012a0:	02010413          	addi	s0,sp,32
    800012a4:	00050493          	mv	s1,a0
    while (*s) kputc(*s++);
    800012a8:	0004c503          	lbu	a0,0(s1)
    800012ac:	00050a63          	beqz	a0,800012c0 <_Z5kputsPKc+0x30>
    800012b0:	00148493          	addi	s1,s1,1
    800012b4:	00000097          	auipc	ra,0x0
    800012b8:	fa0080e7          	jalr	-96(ra) # 80001254 <_Z5kputcc>
    800012bc:	fedff06f          	j	800012a8 <_Z5kputsPKc+0x18>
}
    800012c0:	01813083          	ld	ra,24(sp)
    800012c4:	01013403          	ld	s0,16(sp)
    800012c8:	00813483          	ld	s1,8(sp)
    800012cc:	02010113          	addi	sp,sp,32
    800012d0:	00008067          	ret

00000000800012d4 <_Z7kputhexm>:

// ispisi 64-bitni broj heksadecimalno (fiksno 16 cifara)
void kputhex(uint64 n) {
    800012d4:	fe010113          	addi	sp,sp,-32
    800012d8:	00113c23          	sd	ra,24(sp)
    800012dc:	00813823          	sd	s0,16(sp)
    800012e0:	00913423          	sd	s1,8(sp)
    800012e4:	01213023          	sd	s2,0(sp)
    800012e8:	02010413          	addi	s0,sp,32
    800012ec:	00050913          	mv	s2,a0
    kputs("0x");
    800012f0:	00003517          	auipc	a0,0x3
    800012f4:	d3050513          	addi	a0,a0,-720 # 80004020 <CONSOLE_STATUS+0x10>
    800012f8:	00000097          	auipc	ra,0x0
    800012fc:	f98080e7          	jalr	-104(ra) # 80001290 <_Z5kputsPKc>
    for (int shift = 60; shift >= 0; shift -= 4) {
    80001300:	03c00493          	li	s1,60
    80001304:	0140006f          	j	80001318 <_Z7kputhexm+0x44>
        uint64 digit = (n >> shift) & 0xF;
        char c;
        if (digit < 10) {
            c = '0' + digit;
        } else {
            c = 'a' + (digit - 10);
    80001308:	05750513          	addi	a0,a0,87
        }
        kputc(c);
    8000130c:	00000097          	auipc	ra,0x0
    80001310:	f48080e7          	jalr	-184(ra) # 80001254 <_Z5kputcc>
    for (int shift = 60; shift >= 0; shift -= 4) {
    80001314:	ffc4849b          	addiw	s1,s1,-4
    80001318:	0004ce63          	bltz	s1,80001334 <_Z7kputhexm+0x60>
        uint64 digit = (n >> shift) & 0xF;
    8000131c:	00995533          	srl	a0,s2,s1
    80001320:	00f57513          	andi	a0,a0,15
        if (digit < 10) {
    80001324:	00900793          	li	a5,9
    80001328:	fea7e0e3          	bltu	a5,a0,80001308 <_Z7kputhexm+0x34>
            c = '0' + digit;
    8000132c:	03050513          	addi	a0,a0,48
    80001330:	fddff06f          	j	8000130c <_Z7kputhexm+0x38>
    }
}
    80001334:	01813083          	ld	ra,24(sp)
    80001338:	01013403          	ld	s0,16(sp)
    8000133c:	00813483          	ld	s1,8(sp)
    80001340:	00013903          	ld	s2,0(sp)
    80001344:	02010113          	addi	sp,sp,32
    80001348:	00008067          	ret

000000008000134c <handleTrap>:
#include "../h/tcb.hpp"

// zajednicki c deo prekidne rutine: cita scause i grana se na obradu.
// a0..a4 parametri se poklapaju sa registrima a0..a4 u trenutku trapa
// (trap.S ih ne dira pre call-a), pa abi argumente citamo direktno.
extern "C" uint64 handleTrap(uint64 a0, uint64 a1, uint64 a2, uint64 a3, uint64 a4) {
    8000134c:	fc010113          	addi	sp,sp,-64
    80001350:	02113c23          	sd	ra,56(sp)
    80001354:	02813823          	sd	s0,48(sp)
    80001358:	02913423          	sd	s1,40(sp)
    8000135c:	03213023          	sd	s2,32(sp)
    80001360:	01313c23          	sd	s3,24(sp)
    80001364:	01413823          	sd	s4,16(sp)
    80001368:	01513423          	sd	s5,8(sp)
    8000136c:	01613023          	sd	s6,0(sp)
    80001370:	04010413          	addi	s0,sp,64
    80001374:	00050493          	mv	s1,a0
    uint64 cause, sepc, sstatus;
    asm volatile("csrr %0, scause"  : "=r"(cause));
    80001378:	14202973          	csrr	s2,scause
    asm volatile("csrr %0, sepc"    : "=r"(sepc));
    8000137c:	14102a73          	csrr	s4,sepc
    asm volatile("csrr %0, sstatus" : "=r"(sstatus));
    80001380:	10002b73          	csrr	s6,sstatus
    // sepc i sstatus su DEO KONTEKSTA NITI: obrada moze da promeni nit
    // (dispatch), a dok ova nit spava, globalne csr registre ce puniti tudji
    // trapovi. zato ih odmah snimamo u lokalne promenljive (zive na steku ove
    // niti, parkiraju se s njom), a pred povratak vracamo bas nase vrednosti.

    uint64 topBit = cause >> 63;
    80001384:	03f95a93          	srli	s5,s2,0x3f
    uint64 code   = cause & 0xff;
    80001388:	0ff97793          	andi	a5,s2,255
    uint64 ret    = a0;

    if (topBit == 1) {
    8000138c:	0a0a9663          	bnez	s5,80001438 <handleTrap+0xec>
    80001390:	00058993          	mv	s3,a1
    80001394:	00060513          	mv	a0,a2
    80001398:	00068593          	mv	a1,a3
            int irq = plic_claim();
            plic_complete(irq);
        }
        // sepc se ne uvecava: prekinuta instrukcija mora da se ponovi
    }
    else if (topBit == 0 && (code == 8 || code == 9)) {
    8000139c:	000a9863          	bnez	s5,800013ac <handleTrap+0x60>
    800013a0:	ff878793          	addi	a5,a5,-8
    800013a4:	00100693          	li	a3,1
    800013a8:	0cf6f263          	bgeu	a3,a5,8000146c <handleTrap+0x120>
        }
    }
    else {
        // nepoznat uzrok (izuzetak koji ne umemo da obradimo): panika.
        // ne vracamo se - sepc bi pokazivao na istu instrukciju i vrteli bismo se.
        kputs("PANIC: cause="); kputhex(cause);
    800013ac:	00003517          	auipc	a0,0x3
    800013b0:	c7c50513          	addi	a0,a0,-900 # 80004028 <CONSOLE_STATUS+0x18>
    800013b4:	00000097          	auipc	ra,0x0
    800013b8:	edc080e7          	jalr	-292(ra) # 80001290 <_Z5kputsPKc>
    800013bc:	00090513          	mv	a0,s2
    800013c0:	00000097          	auipc	ra,0x0
    800013c4:	f14080e7          	jalr	-236(ra) # 800012d4 <_Z7kputhexm>
        kputs(" sepc=");        kputhex(sepc);
    800013c8:	00003517          	auipc	a0,0x3
    800013cc:	c7050513          	addi	a0,a0,-912 # 80004038 <CONSOLE_STATUS+0x28>
    800013d0:	00000097          	auipc	ra,0x0
    800013d4:	ec0080e7          	jalr	-320(ra) # 80001290 <_Z5kputsPKc>
    800013d8:	000a0513          	mv	a0,s4
    800013dc:	00000097          	auipc	ra,0x0
    800013e0:	ef8080e7          	jalr	-264(ra) # 800012d4 <_Z7kputhexm>
        kputs("\n");
    800013e4:	00003517          	auipc	a0,0x3
    800013e8:	e8c50513          	addi	a0,a0,-372 # 80004270 <CONSOLE_STATUS+0x260>
    800013ec:	00000097          	auipc	ra,0x0
    800013f0:	ea4080e7          	jalr	-348(ra) # 80001290 <_Z5kputsPKc>
        *(volatile int*)0x100000 = 0x5555;   // halt emulatora
    800013f4:	00100737          	lui	a4,0x100
    800013f8:	000057b7          	lui	a5,0x5
    800013fc:	5557879b          	addiw	a5,a5,1365
    80001400:	00f72023          	sw	a5,0(a4) # 100000 <_entry-0x7ff00000>
    }

    // svako se vraca sa SVOJIM vrednostima, ma koliko dugo spavao
    asm volatile("csrw sstatus, %0" : : "r"(sstatus));
    80001404:	100b1073          	csrw	sstatus,s6
    asm volatile("csrw sepc, %0"    : : "r"(sepc));
    80001408:	141a1073          	csrw	sepc,s4
    return ret;
}
    8000140c:	00048513          	mv	a0,s1
    80001410:	03813083          	ld	ra,56(sp)
    80001414:	03013403          	ld	s0,48(sp)
    80001418:	02813483          	ld	s1,40(sp)
    8000141c:	02013903          	ld	s2,32(sp)
    80001420:	01813983          	ld	s3,24(sp)
    80001424:	01013a03          	ld	s4,16(sp)
    80001428:	00813a83          	ld	s5,8(sp)
    8000142c:	00013b03          	ld	s6,0(sp)
    80001430:	04010113          	addi	sp,sp,64
    80001434:	00008067          	ret
        if (code == 1) {
    80001438:	00100713          	li	a4,1
    8000143c:	02e78063          	beq	a5,a4,8000145c <handleTrap+0x110>
        } else if (code == 9) {
    80001440:	00900713          	li	a4,9
    80001444:	fce790e3          	bne	a5,a4,80001404 <handleTrap+0xb8>
            int irq = plic_claim();
    80001448:	00001097          	auipc	ra,0x1
    8000144c:	1ac080e7          	jalr	428(ra) # 800025f4 <plic_claim>
            plic_complete(irq);
    80001450:	00001097          	auipc	ra,0x1
    80001454:	1dc080e7          	jalr	476(ra) # 8000262c <plic_complete>
    80001458:	fadff06f          	j	80001404 <handleTrap+0xb8>
            asm volatile("csrr %0, sip" : "=r"(sip));
    8000145c:	144027f3          	csrr	a5,sip
            sip &= ~(1UL << 1);
    80001460:	ffd7f793          	andi	a5,a5,-3
            asm volatile("csrw sip, %0" : : "r"(sip));
    80001464:	14479073          	csrw	sip,a5
    80001468:	f9dff06f          	j	80001404 <handleTrap+0xb8>
        sepc += 4;   // preskoci sam ecall - u lokalnoj kopiji!
    8000146c:	004a0a13          	addi	s4,s4,4
        switch (a0) {
    80001470:	01300793          	li	a5,19
    80001474:	0897ea63          	bltu	a5,s1,80001508 <handleTrap+0x1bc>
    80001478:	00249693          	slli	a3,s1,0x2
    8000147c:	00003617          	auipc	a2,0x3
    80001480:	bc460613          	addi	a2,a2,-1084 # 80004040 <CONSOLE_STATUS+0x30>
    80001484:	00c686b3          	add	a3,a3,a2
    80001488:	0006a783          	lw	a5,0(a3)
    8000148c:	00c787b3          	add	a5,a5,a2
    80001490:	00078067          	jr	a5 # 5000 <_entry-0x7fffb000>
                ret = (uint64)MemoryAllocator::alloc(a1 * MEM_BLOCK_SIZE);
    80001494:	00699513          	slli	a0,s3,0x6
    80001498:	00000097          	auipc	ra,0x0
    8000149c:	5b4080e7          	jalr	1460(ra) # 80001a4c <_ZN15MemoryAllocator5allocEm>
    800014a0:	00050493          	mv	s1,a0
                break;
    800014a4:	f61ff06f          	j	80001404 <handleTrap+0xb8>
                ret = (uint64)MemoryAllocator::free((void*)a1);
    800014a8:	00098513          	mv	a0,s3
    800014ac:	00000097          	auipc	ra,0x0
    800014b0:	6dc080e7          	jalr	1756(ra) # 80001b88 <_ZN15MemoryAllocator4freeEPv>
    800014b4:	00050493          	mv	s1,a0
                break;
    800014b8:	f4dff06f          	j	80001404 <handleTrap+0xb8>
                TCB* tcb = TCB::createThread((TCB::Body)a2, (void*)a3, (void*)a4, false);
    800014bc:	00000693          	li	a3,0
    800014c0:	00070613          	mv	a2,a4
    800014c4:	00000097          	auipc	ra,0x0
    800014c8:	2b0080e7          	jalr	688(ra) # 80001774 <_ZN3TCB12createThreadEPFvPvES0_S0_b>
                if (tcb) { *(TCB**)a1 = tcb; ret = 0; }
    800014cc:	04050263          	beqz	a0,80001510 <handleTrap+0x1c4>
    800014d0:	00a9b023          	sd	a0,0(s3)
    800014d4:	000a8493          	mv	s1,s5
    800014d8:	f2dff06f          	j	80001404 <handleTrap+0xb8>

    // sinhrona promena konteksta: tekuca nit ustupa procesor sledecoj iz reda
    static void dispatch();

    bool isFinished() const { return finished; }
    void setFinished(bool f) { finished = f; }
    800014dc:	00003797          	auipc	a5,0x3
    800014e0:	3347b783          	ld	a5,820(a5) # 80004810 <_ZN3TCB7runningE>
    800014e4:	00100713          	li	a4,1
    800014e8:	02e78423          	sb	a4,40(a5)
                TCB::dispatch();
    800014ec:	00000097          	auipc	ra,0x0
    800014f0:	36c080e7          	jalr	876(ra) # 80001858 <_ZN3TCB8dispatchEv>
                break;
    800014f4:	f11ff06f          	j	80001404 <handleTrap+0xb8>
                TCB::dispatch();
    800014f8:	00000097          	auipc	ra,0x0
    800014fc:	360080e7          	jalr	864(ra) # 80001858 <_ZN3TCB8dispatchEv>
                ret = 0;
    80001500:	000a8493          	mv	s1,s5
                break;
    80001504:	f01ff06f          	j	80001404 <handleTrap+0xb8>
        sepc += 4;   // preskoci sam ecall - u lokalnoj kopiji!
    80001508:	fff00493          	li	s1,-1
    8000150c:	ef9ff06f          	j	80001404 <handleTrap+0xb8>
                else     { ret = (uint64)-1; }
    80001510:	fff00493          	li	s1,-1
    80001514:	ef1ff06f          	j	80001404 <handleTrap+0xb8>

0000000080001518 <_ZL7workerBPv>:
        thread_dispatch();
    }
    doneA = true;
}

static void workerB(void*) {
    80001518:	fe010113          	addi	sp,sp,-32
    8000151c:	00113c23          	sd	ra,24(sp)
    80001520:	00813823          	sd	s0,16(sp)
    80001524:	00913423          	sd	s1,8(sp)
    80001528:	02010413          	addi	s0,sp,32
    for (int i = 0; i < 5; i++) {
    8000152c:	00000493          	li	s1,0
    80001530:	00400793          	li	a5,4
    80001534:	0297c263          	blt	a5,s1,80001558 <_ZL7workerBPv+0x40>
        kputs("B");
    80001538:	00003517          	auipc	a0,0x3
    8000153c:	b5850513          	addi	a0,a0,-1192 # 80004090 <CONSOLE_STATUS+0x80>
    80001540:	00000097          	auipc	ra,0x0
    80001544:	d50080e7          	jalr	-688(ra) # 80001290 <_Z5kputsPKc>
        thread_dispatch();
    80001548:	00000097          	auipc	ra,0x0
    8000154c:	cec080e7          	jalr	-788(ra) # 80001234 <_Z15thread_dispatchv>
    for (int i = 0; i < 5; i++) {
    80001550:	0014849b          	addiw	s1,s1,1
    80001554:	fddff06f          	j	80001530 <_ZL7workerBPv+0x18>
    }
    doneB = true;
    80001558:	00100793          	li	a5,1
    8000155c:	00003717          	auipc	a4,0x3
    80001560:	2af70223          	sb	a5,676(a4) # 80004800 <_ZL5doneB>
}
    80001564:	01813083          	ld	ra,24(sp)
    80001568:	01013403          	ld	s0,16(sp)
    8000156c:	00813483          	ld	s1,8(sp)
    80001570:	02010113          	addi	sp,sp,32
    80001574:	00008067          	ret

0000000080001578 <_ZL7workerAPv>:
static void workerA(void*) {
    80001578:	fe010113          	addi	sp,sp,-32
    8000157c:	00113c23          	sd	ra,24(sp)
    80001580:	00813823          	sd	s0,16(sp)
    80001584:	00913423          	sd	s1,8(sp)
    80001588:	02010413          	addi	s0,sp,32
    asm volatile("csrr t6, sepc");
    8000158c:	14102ff3          	csrr	t6,sepc
    for (int i = 0; i < 5; i++) {
    80001590:	00000493          	li	s1,0
    80001594:	00400793          	li	a5,4
    80001598:	0297c263          	blt	a5,s1,800015bc <_ZL7workerAPv+0x44>
        kputs("A");
    8000159c:	00003517          	auipc	a0,0x3
    800015a0:	afc50513          	addi	a0,a0,-1284 # 80004098 <CONSOLE_STATUS+0x88>
    800015a4:	00000097          	auipc	ra,0x0
    800015a8:	cec080e7          	jalr	-788(ra) # 80001290 <_Z5kputsPKc>
        thread_dispatch();
    800015ac:	00000097          	auipc	ra,0x0
    800015b0:	c88080e7          	jalr	-888(ra) # 80001234 <_Z15thread_dispatchv>
    for (int i = 0; i < 5; i++) {
    800015b4:	0014849b          	addiw	s1,s1,1
    800015b8:	fddff06f          	j	80001594 <_ZL7workerAPv+0x1c>
    doneA = true;
    800015bc:	00100793          	li	a5,1
    800015c0:	00003717          	auipc	a4,0x3
    800015c4:	24f700a3          	sb	a5,577(a4) # 80004801 <_ZL5doneA>
}
    800015c8:	01813083          	ld	ra,24(sp)
    800015cc:	01013403          	ld	s0,16(sp)
    800015d0:	00813483          	ld	s1,8(sp)
    800015d4:	02010113          	addi	sp,sp,32
    800015d8:	00008067          	ret

00000000800015dc <_Z8userMainv>:

void userMain() {
    800015dc:	fe010113          	addi	sp,sp,-32
    800015e0:	00113c23          	sd	ra,24(sp)
    800015e4:	00813823          	sd	s0,16(sp)
    800015e8:	02010413          	addi	s0,sp,32
    thread_t a, b;
    thread_create(&a, workerA, nullptr);
    800015ec:	00000613          	li	a2,0
    800015f0:	00000597          	auipc	a1,0x0
    800015f4:	f8858593          	addi	a1,a1,-120 # 80001578 <_ZL7workerAPv>
    800015f8:	fe840513          	addi	a0,s0,-24
    800015fc:	00000097          	auipc	ra,0x0
    80001600:	b6c080e7          	jalr	-1172(ra) # 80001168 <_Z13thread_createPP7_threadPFvPvES2_>
    thread_create(&b, workerB, nullptr);
    80001604:	00000613          	li	a2,0
    80001608:	00000597          	auipc	a1,0x0
    8000160c:	f1058593          	addi	a1,a1,-240 # 80001518 <_ZL7workerBPv>
    80001610:	fe040513          	addi	a0,s0,-32
    80001614:	00000097          	auipc	ra,0x0
    80001618:	b54080e7          	jalr	-1196(ra) # 80001168 <_Z13thread_createPP7_threadPFvPvES2_>
    8000161c:	00c0006f          	j	80001628 <_Z8userMainv+0x4c>

    // main (nulta nit) vrti dispatch dok obe ne zavrse
    while (!doneA || !doneB) {
        thread_dispatch();
    80001620:	00000097          	auipc	ra,0x0
    80001624:	c14080e7          	jalr	-1004(ra) # 80001234 <_Z15thread_dispatchv>
    while (!doneA || !doneB) {
    80001628:	00003797          	auipc	a5,0x3
    8000162c:	1d97c783          	lbu	a5,473(a5) # 80004801 <_ZL5doneA>
    80001630:	fe0788e3          	beqz	a5,80001620 <_Z8userMainv+0x44>
    80001634:	00003797          	auipc	a5,0x3
    80001638:	1cc7c783          	lbu	a5,460(a5) # 80004800 <_ZL5doneB>
    8000163c:	fe0782e3          	beqz	a5,80001620 <_Z8userMainv+0x44>
    }
    kputs("\nobe niti zavrsile\n");
    80001640:	00003517          	auipc	a0,0x3
    80001644:	a6050513          	addi	a0,a0,-1440 # 800040a0 <CONSOLE_STATUS+0x90>
    80001648:	00000097          	auipc	ra,0x0
    8000164c:	c48080e7          	jalr	-952(ra) # 80001290 <_Z5kputsPKc>
}
    80001650:	01813083          	ld	ra,24(sp)
    80001654:	01013403          	ld	s0,16(sp)
    80001658:	02010113          	addi	sp,sp,32
    8000165c:	00008067          	ret

0000000080001660 <_ZN3TCB11userWrapperEv>:
}

// u-mode deo omotaca: OVO se izvrsava u korisnickom rezimu.
// tcb sme da CITA (isti adresni prostor, nema memorijske zastite -
// granica privilegija su instrukcije), ali u jezgro sme samo kroz ecall
void TCB::userWrapper() {
    80001660:	ff010113          	addi	sp,sp,-16
    80001664:	00113423          	sd	ra,8(sp)
    80001668:	00813023          	sd	s0,0(sp)
    8000166c:	01010413          	addi	s0,sp,16
    running->body(running->arg);
    80001670:	00003797          	auipc	a5,0x3
    80001674:	1a07b783          	ld	a5,416(a5) # 80004810 <_ZN3TCB7runningE>
    80001678:	0007b703          	ld	a4,0(a5)
    8000167c:	0087b503          	ld	a0,8(a5)
    80001680:	000700e7          	jalr	a4
    thread_exit();      // ecall - jedini legalan povratak u jezgro
    80001684:	00000097          	auipc	ra,0x0
    80001688:	b8c080e7          	jalr	-1140(ra) # 80001210 <_Z11thread_exitv>
    for (;;) {}         // nedostizno; osiguranje da se nikad ne "ispadne"
    8000168c:	0000006f          	j	8000168c <_ZN3TCB11userWrapperEv+0x2c>

0000000080001690 <_ZN3TCBnwEm>:
void* TCB::operator new(size_t size) {
    80001690:	ff010113          	addi	sp,sp,-16
    80001694:	00113423          	sd	ra,8(sp)
    80001698:	00813023          	sd	s0,0(sp)
    8000169c:	01010413          	addi	s0,sp,16
    return MemoryAllocator::alloc(size);
    800016a0:	00000097          	auipc	ra,0x0
    800016a4:	3ac080e7          	jalr	940(ra) # 80001a4c <_ZN15MemoryAllocator5allocEm>
}
    800016a8:	00813083          	ld	ra,8(sp)
    800016ac:	00013403          	ld	s0,0(sp)
    800016b0:	01010113          	addi	sp,sp,16
    800016b4:	00008067          	ret

00000000800016b8 <_ZN3TCBdlEPv>:
void TCB::operator delete(void* ptr) {
    800016b8:	ff010113          	addi	sp,sp,-16
    800016bc:	00113423          	sd	ra,8(sp)
    800016c0:	00813023          	sd	s0,0(sp)
    800016c4:	01010413          	addi	s0,sp,16
    MemoryAllocator::free(ptr);
    800016c8:	00000097          	auipc	ra,0x0
    800016cc:	4c0080e7          	jalr	1216(ra) # 80001b88 <_ZN15MemoryAllocator4freeEPv>
}
    800016d0:	00813083          	ld	ra,8(sp)
    800016d4:	00013403          	ld	s0,0(sp)
    800016d8:	01010113          	addi	sp,sp,16
    800016dc:	00008067          	ret

00000000800016e0 <_ZN3TCBC1EPFvPvES0_Pmb>:
TCB::TCB(Body body, void* arg, uint64* stack, bool systemLevel)
    800016e0:	ff010113          	addi	sp,sp,-16
    800016e4:	00813423          	sd	s0,8(sp)
    800016e8:	01010413          	addi	s0,sp,16
      finished(false), systemLevel(systemLevel), next(nullptr)
    800016ec:	00b53023          	sd	a1,0(a0)
    800016f0:	00c53423          	sd	a2,8(a0)
    800016f4:	00d53823          	sd	a3,16(a0)
    800016f8:	00053c23          	sd	zero,24(a0)
    800016fc:	02053023          	sd	zero,32(a0)
    80001700:	02050423          	sb	zero,40(a0)
    80001704:	02e504a3          	sb	a4,41(a0)
    80001708:	02053823          	sd	zero,48(a0)
{}
    8000170c:	00813403          	ld	s0,8(sp)
    80001710:	01010113          	addi	sp,sp,16
    80001714:	00008067          	ret

0000000080001718 <_ZN3TCB10reapZombieEv>:
    if (!zombie) return;
    80001718:	00003797          	auipc	a5,0x3
    8000171c:	0f07b783          	ld	a5,240(a5) # 80004808 <_ZN3TCB6zombieE>
    80001720:	04078863          	beqz	a5,80001770 <_ZN3TCB10reapZombieEv+0x58>
void TCB::reapZombie() {
    80001724:	ff010113          	addi	sp,sp,-16
    80001728:	00113423          	sd	ra,8(sp)
    8000172c:	00813023          	sd	s0,0(sp)
    80001730:	01010413          	addi	s0,sp,16
    if (zombie->stack) MemoryAllocator::free(zombie->stack);
    80001734:	0107b503          	ld	a0,16(a5)
    80001738:	00050663          	beqz	a0,80001744 <_ZN3TCB10reapZombieEv+0x2c>
    8000173c:	00000097          	auipc	ra,0x0
    80001740:	44c080e7          	jalr	1100(ra) # 80001b88 <_ZN15MemoryAllocator4freeEPv>
    delete zombie;
    80001744:	00003517          	auipc	a0,0x3
    80001748:	0c453503          	ld	a0,196(a0) # 80004808 <_ZN3TCB6zombieE>
    8000174c:	00050663          	beqz	a0,80001758 <_ZN3TCB10reapZombieEv+0x40>
    80001750:	00000097          	auipc	ra,0x0
    80001754:	f68080e7          	jalr	-152(ra) # 800016b8 <_ZN3TCBdlEPv>
    zombie = nullptr;
    80001758:	00003797          	auipc	a5,0x3
    8000175c:	0a07b823          	sd	zero,176(a5) # 80004808 <_ZN3TCB6zombieE>
}
    80001760:	00813083          	ld	ra,8(sp)
    80001764:	00013403          	ld	s0,0(sp)
    80001768:	01010113          	addi	sp,sp,16
    8000176c:	00008067          	ret
    80001770:	00008067          	ret

0000000080001774 <_ZN3TCB12createThreadEPFvPvES0_S0_b>:
}

TCB* TCB::createThread(Body body, void* arg, void* stackSpace, bool systemLevel) {
    80001774:	fc010113          	addi	sp,sp,-64
    80001778:	02113c23          	sd	ra,56(sp)
    8000177c:	02813823          	sd	s0,48(sp)
    80001780:	02913423          	sd	s1,40(sp)
    80001784:	03213023          	sd	s2,32(sp)
    80001788:	01313c23          	sd	s3,24(sp)
    8000178c:	01413823          	sd	s4,16(sp)
    80001790:	01513423          	sd	s5,8(sp)
    80001794:	04010413          	addi	s0,sp,64
    80001798:	00050993          	mv	s3,a0
    8000179c:	00058a13          	mv	s4,a1
    800017a0:	00060493          	mv	s1,a2
    800017a4:	00068a93          	mv	s5,a3
    // prava nit bez steka ne moze da postoji
    if (body && !stackSpace) return nullptr;
    800017a8:	00050463          	beqz	a0,800017b0 <_ZN3TCB12createThreadEPFvPvES0_S0_b+0x3c>
    800017ac:	0a060263          	beqz	a2,80001850 <_ZN3TCB12createThreadEPFvPvES0_S0_b+0xdc>

    TCB* tcb = new TCB(body, arg, (uint64*)stackSpace, systemLevel);
    800017b0:	03800513          	li	a0,56
    800017b4:	00000097          	auipc	ra,0x0
    800017b8:	edc080e7          	jalr	-292(ra) # 80001690 <_ZN3TCBnwEm>
    800017bc:	00050913          	mv	s2,a0
    800017c0:	000a8713          	mv	a4,s5
    800017c4:	00048693          	mv	a3,s1
    800017c8:	000a0613          	mv	a2,s4
    800017cc:	00098593          	mv	a1,s3
    800017d0:	00000097          	auipc	ra,0x0
    800017d4:	f10080e7          	jalr	-240(ra) # 800016e0 <_ZN3TCBC1EPFvPvES0_Pmb>
    if (!tcb) return nullptr;
    800017d8:	04090863          	beqz	s2,80001828 <_ZN3TCB12createThreadEPFvPvES0_S0_b+0xb4>

    if (body) {
    800017dc:	04098663          	beqz	s3,80001828 <_ZN3TCB12createThreadEPFvPvES0_S0_b+0xb4>
        // bootstrap: falsifikuj proslost niti da izgleda kao da je "zaspala"
        // na samom ulazu u threadWrapper. prvo budjenje (contextSwitch) ce:
        // pokupiti 12 laznih s-registara sa steka, pa ret na threadWrapper.
        uint64 top = (uint64)stackSpace + DEFAULT_STACK_SIZE;   // stek raste ka nizim adresama
        tcb->context.sp = top - 96;                             // mesto za 12 "s-registara"
    800017e0:	00001637          	lui	a2,0x1
    800017e4:	fa060613          	addi	a2,a2,-96 # fa0 <_entry-0x7ffff060>
    800017e8:	00c48633          	add	a2,s1,a2
    800017ec:	02c93023          	sd	a2,32(s2)
        uint64* fakeRegs = (uint64*)tcb->context.sp;
        for (int i = 0; i < 12; i++) fakeRegs[i] = 0;           // nit krece cistih ruku
    800017f0:	00000793          	li	a5,0
    800017f4:	00b00713          	li	a4,11
    800017f8:	00f74c63          	blt	a4,a5,80001810 <_ZN3TCB12createThreadEPFvPvES0_S0_b+0x9c>
    800017fc:	00379713          	slli	a4,a5,0x3
    80001800:	00e60733          	add	a4,a2,a4
    80001804:	00073023          	sd	zero,0(a4)
    80001808:	0017879b          	addiw	a5,a5,1
    8000180c:	fe9ff06f          	j	800017f4 <_ZN3TCB12createThreadEPFvPvES0_S0_b+0x80>
        tcb->context.ra = (uint64)&threadWrapper;
    80001810:	00000797          	auipc	a5,0x0
    80001814:	0f478793          	addi	a5,a5,244 # 80001904 <_ZN3TCB13threadWrapperEv>
    80001818:	00f93c23          	sd	a5,24(s2)

        Scheduler::put(tcb);
    8000181c:	00090513          	mv	a0,s2
    80001820:	00000097          	auipc	ra,0x0
    80001824:	15c080e7          	jalr	348(ra) # 8000197c <_ZN9Scheduler3putEP3TCB>
    }
    // nulta nit (body == nullptr, main): bez steka i bez reda - njen kontekst
    // ce prirodno upisati njen prvi contextSwitch
    return tcb;
}
    80001828:	00090513          	mv	a0,s2
    8000182c:	03813083          	ld	ra,56(sp)
    80001830:	03013403          	ld	s0,48(sp)
    80001834:	02813483          	ld	s1,40(sp)
    80001838:	02013903          	ld	s2,32(sp)
    8000183c:	01813983          	ld	s3,24(sp)
    80001840:	01013a03          	ld	s4,16(sp)
    80001844:	00813a83          	ld	s5,8(sp)
    80001848:	04010113          	addi	sp,sp,64
    8000184c:	00008067          	ret
    if (body && !stackSpace) return nullptr;
    80001850:	00060913          	mv	s2,a2
    80001854:	fd5ff06f          	j	80001828 <_ZN3TCB12createThreadEPFvPvES0_S0_b+0xb4>

0000000080001858 <_ZN3TCB8dispatchEv>:

// sinhrona promena konteksta: tekuca nit ustupa procesor
void TCB::dispatch() {
    80001858:	fe010113          	addi	sp,sp,-32
    8000185c:	00113c23          	sd	ra,24(sp)
    80001860:	00813823          	sd	s0,16(sp)
    80001864:	00913423          	sd	s1,8(sp)
    80001868:	01213023          	sd	s2,0(sp)
    8000186c:	02010413          	addi	s0,sp,32
    TCB* old = running;
    80001870:	00003917          	auipc	s2,0x3
    80001874:	fa093903          	ld	s2,-96(s2) # 80004810 <_ZN3TCB7runningE>
    if (!old->finished) Scheduler::put(old);
    80001878:	02894783          	lbu	a5,40(s2)
    8000187c:	04078a63          	beqz	a5,800018d0 <_ZN3TCB8dispatchEv+0x78>
    else zombie = old;   // jos stojimo na njegovom steku - ciscenje kasnije!
    80001880:	00003797          	auipc	a5,0x3
    80001884:	f927b423          	sd	s2,-120(a5) # 80004808 <_ZN3TCB6zombieE>

    TCB* next = Scheduler::get();
    80001888:	00000097          	auipc	ra,0x0
    8000188c:	134080e7          	jalr	308(ra) # 800019bc <_ZN9Scheduler3getEv>
    80001890:	00050493          	mv	s1,a0
    if (!next) {
    80001894:	04050663          	beqz	a0,800018e0 <_ZN3TCB8dispatchEv+0x88>
        // nema nijedne spremne niti, a tekuca je gotova: sistem nema sta da radi
        kputs("PANIC: nema spremnih niti\n");
        *(volatile int*)0x100000 = 0x5555;
    }

    running = next;
    80001898:	00003797          	auipc	a5,0x3
    8000189c:	f697bc23          	sd	s1,-136(a5) # 80004810 <_ZN3TCB7runningE>
    contextSwitch(&old->context, &running->context);
    800018a0:	01848593          	addi	a1,s1,24
    800018a4:	01890513          	addi	a0,s2,24
    800018a8:	fffff097          	auipc	ra,0xfffff
    800018ac:	7e8080e7          	jalr	2024(ra) # 80001090 <contextSwitch>
    // budjenje: sad smo na steku probudjene niti - bezbedno pocisti zombija
    reapZombie();
    800018b0:	00000097          	auipc	ra,0x0
    800018b4:	e68080e7          	jalr	-408(ra) # 80001718 <_ZN3TCB10reapZombieEv>
}
    800018b8:	01813083          	ld	ra,24(sp)
    800018bc:	01013403          	ld	s0,16(sp)
    800018c0:	00813483          	ld	s1,8(sp)
    800018c4:	00013903          	ld	s2,0(sp)
    800018c8:	02010113          	addi	sp,sp,32
    800018cc:	00008067          	ret
    if (!old->finished) Scheduler::put(old);
    800018d0:	00090513          	mv	a0,s2
    800018d4:	00000097          	auipc	ra,0x0
    800018d8:	0a8080e7          	jalr	168(ra) # 8000197c <_ZN9Scheduler3putEP3TCB>
    800018dc:	fadff06f          	j	80001888 <_ZN3TCB8dispatchEv+0x30>
        kputs("PANIC: nema spremnih niti\n");
    800018e0:	00002517          	auipc	a0,0x2
    800018e4:	7d850513          	addi	a0,a0,2008 # 800040b8 <CONSOLE_STATUS+0xa8>
    800018e8:	00000097          	auipc	ra,0x0
    800018ec:	9a8080e7          	jalr	-1624(ra) # 80001290 <_Z5kputsPKc>
        *(volatile int*)0x100000 = 0x5555;
    800018f0:	00100737          	lui	a4,0x100
    800018f4:	000057b7          	lui	a5,0x5
    800018f8:	5557879b          	addiw	a5,a5,1365
    800018fc:	00f72023          	sw	a5,0(a4) # 100000 <_entry-0x7ff00000>
    80001900:	f99ff06f          	j	80001898 <_ZN3TCB8dispatchEv+0x40>

0000000080001904 <_ZN3TCB13threadWrapperEv>:
void TCB::threadWrapper() {
    80001904:	ff010113          	addi	sp,sp,-16
    80001908:	00113423          	sd	ra,8(sp)
    8000190c:	00813023          	sd	s0,0(sp)
    80001910:	01010413          	addi	s0,sp,16
    reapZombie();   // i rodjenje je budjenje: pocisti eventualnog prethodnika
    80001914:	00000097          	auipc	ra,0x0
    80001918:	e04080e7          	jalr	-508(ra) # 80001718 <_ZN3TCB10reapZombieEv>
    if (running->systemLevel) {
    8000191c:	00003797          	auipc	a5,0x3
    80001920:	ef47b783          	ld	a5,-268(a5) # 80004810 <_ZN3TCB7runningE>
    80001924:	0297c703          	lbu	a4,41(a5)
    80001928:	02070463          	beqz	a4,80001950 <_ZN3TCB13threadWrapperEv+0x4c>
        running->body(running->arg);
    8000192c:	0007b703          	ld	a4,0(a5)
    80001930:	0087b503          	ld	a0,8(a5)
    80001934:	000700e7          	jalr	a4
        running->finished = true;
    80001938:	00003797          	auipc	a5,0x3
    8000193c:	ed87b783          	ld	a5,-296(a5) # 80004810 <_ZN3TCB7runningE>
    80001940:	00100713          	li	a4,1
    80001944:	02e78423          	sb	a4,40(a5)
        dispatch();     // odavde nema povratka
    80001948:	00000097          	auipc	ra,0x0
    8000194c:	f10080e7          	jalr	-240(ra) # 80001858 <_ZN3TCB8dispatchEv>
    uint64 target = (uint64)&userWrapper;
    80001950:	00000797          	auipc	a5,0x0
    80001954:	d1078793          	addi	a5,a5,-752 # 80001660 <_ZN3TCB11userWrapperEv>
    asm volatile("csrw sepc, %0" : : "r"(target));
    80001958:	14179073          	csrw	sepc,a5
    asm volatile("csrr %0, sstatus" : "=r"(sstatus));
    8000195c:	100027f3          	csrr	a5,sstatus
    sstatus &= ~(1UL << 8);                    // spp = 0: sret vodi u u-mode
    80001960:	eff7f793          	andi	a5,a5,-257
    asm volatile("csrw sstatus, %0" : : "r"(sstatus));
    80001964:	10079073          	csrw	sstatus,a5
    asm volatile("sret");                      // spust: dalje u userWrapper
    80001968:	10200073          	sret
}
    8000196c:	00813083          	ld	ra,8(sp)
    80001970:	00013403          	ld	s0,0(sp)
    80001974:	01010113          	addi	sp,sp,16
    80001978:	00008067          	ret

000000008000197c <_ZN9Scheduler3putEP3TCB>:

TCB* Scheduler::head = nullptr;
TCB* Scheduler::tail = nullptr;

// stani na kraj reda
void Scheduler::put(TCB* thread) {
    8000197c:	ff010113          	addi	sp,sp,-16
    80001980:	00813423          	sd	s0,8(sp)
    80001984:	01010413          	addi	s0,sp,16
    thread->next = nullptr;
    80001988:	02053823          	sd	zero,48(a0)
    if (tail) {
    8000198c:	00003797          	auipc	a5,0x3
    80001990:	e8c7b783          	ld	a5,-372(a5) # 80004818 <_ZN9Scheduler4tailE>
    80001994:	00078e63          	beqz	a5,800019b0 <_ZN9Scheduler3putEP3TCB+0x34>
        tail->next = thread;   // dosadasnji poslednji pokaze na novog
    80001998:	02a7b823          	sd	a0,48(a5)
    } else {
        head = thread;         // red je bio prazan: novi je i prvi
    }
    tail = thread;             // novi je u svakom slucaju poslednji
    8000199c:	00003797          	auipc	a5,0x3
    800019a0:	e6a7be23          	sd	a0,-388(a5) # 80004818 <_ZN9Scheduler4tailE>
}
    800019a4:	00813403          	ld	s0,8(sp)
    800019a8:	01010113          	addi	sp,sp,16
    800019ac:	00008067          	ret
        head = thread;         // red je bio prazan: novi je i prvi
    800019b0:	00003797          	auipc	a5,0x3
    800019b4:	e6a7b823          	sd	a0,-400(a5) # 80004820 <_ZN9Scheduler4headE>
    800019b8:	fe5ff06f          	j	8000199c <_ZN9Scheduler3putEP3TCB+0x20>

00000000800019bc <_ZN9Scheduler3getEv>:

// skini nit sa cela reda
TCB* Scheduler::get() {
    800019bc:	ff010113          	addi	sp,sp,-16
    800019c0:	00813423          	sd	s0,8(sp)
    800019c4:	01010413          	addi	s0,sp,16
    TCB* thread = head;
    800019c8:	00003517          	auipc	a0,0x3
    800019cc:	e5853503          	ld	a0,-424(a0) # 80004820 <_ZN9Scheduler4headE>
    if (!thread) return nullptr;   // prazan red
    800019d0:	00050c63          	beqz	a0,800019e8 <_ZN9Scheduler3getEv+0x2c>
    head = head->next;
    800019d4:	03053783          	ld	a5,48(a0)
    800019d8:	00003717          	auipc	a4,0x3
    800019dc:	e4f73423          	sd	a5,-440(a4) # 80004820 <_ZN9Scheduler4headE>
    if (!head) tail = nullptr;     // skinuli smo i poslednjeg
    800019e0:	00078a63          	beqz	a5,800019f4 <_ZN9Scheduler3getEv+0x38>
    thread->next = nullptr;
    800019e4:	02053823          	sd	zero,48(a0)
    return thread;
}
    800019e8:	00813403          	ld	s0,8(sp)
    800019ec:	01010113          	addi	sp,sp,16
    800019f0:	00008067          	ret
    if (!head) tail = nullptr;     // skinuli smo i poslednjeg
    800019f4:	00003797          	auipc	a5,0x3
    800019f8:	e207b223          	sd	zero,-476(a5) # 80004818 <_ZN9Scheduler4tailE>
    800019fc:	fe9ff06f          	j	800019e4 <_ZN9Scheduler3getEv+0x28>

0000000080001a00 <_ZN15MemoryAllocator4initEv>:
#include "../h/print.hpp"

MemoryAllocator::FreeBlock* MemoryAllocator::freeListHead = nullptr;

// ceo heap = jedan slobodan blok
void MemoryAllocator::init() {
    80001a00:	ff010113          	addi	sp,sp,-16
    80001a04:	00813423          	sd	s0,8(sp)
    80001a08:	01010413          	addi	s0,sp,16
    freeListHead = (FreeBlock*)HEAP_START_ADDR;
    80001a0c:	00003797          	auipc	a5,0x3
    80001a10:	dcc78793          	addi	a5,a5,-564 # 800047d8 <HEAP_START_ADDR>
    80001a14:	0007b683          	ld	a3,0(a5)
    80001a18:	00003717          	auipc	a4,0x3
    80001a1c:	e1070713          	addi	a4,a4,-496 # 80004828 <_ZN15MemoryAllocator12freeListHeadE>
    80001a20:	00d73023          	sd	a3,0(a4)
    freeListHead->next = nullptr;
    80001a24:	0006b023          	sd	zero,0(a3)
    freeListHead->size = (char*)HEAP_END_ADDR - (char*)HEAP_START_ADDR;
    80001a28:	0007b683          	ld	a3,0(a5)
    80001a2c:	00073703          	ld	a4,0(a4)
    80001a30:	00003797          	auipc	a5,0x3
    80001a34:	da07b783          	ld	a5,-608(a5) # 800047d0 <HEAP_END_ADDR>
    80001a38:	40d787b3          	sub	a5,a5,a3
    80001a3c:	00f73423          	sd	a5,8(a4)
}
    80001a40:	00813403          	ld	s0,8(sp)
    80001a44:	01010113          	addi	sp,sp,16
    80001a48:	00008067          	ret

0000000080001a4c <_ZN15MemoryAllocator5allocEm>:

void* MemoryAllocator::alloc(size_t size){
    80001a4c:	ff010113          	addi	sp,sp,-16
    80001a50:	00813423          	sd	s0,8(sp)
    80001a54:	01010413          	addi	s0,sp,16
    if (size == 0) {
    80001a58:	08050a63          	beqz	a0,80001aec <_ZN15MemoryAllocator5allocEm+0xa0>
        return nullptr;
    }
    // zaokruzivanje navise: ((n + B - 1) / B) * B; heder ukljucen u racun
    // da payload uvek bude >= size
    size_t n = size + sizeof(FreeBlock);
    size_t roundedSize = ((n + MEM_BLOCK_SIZE - 1) / MEM_BLOCK_SIZE) * MEM_BLOCK_SIZE;
    80001a5c:	04f50513          	addi	a0,a0,79
    80001a60:	fc057713          	andi	a4,a0,-64

    // first-fit kroz slobodnu listu
    FreeBlock* curr = freeListHead;
    80001a64:	00003517          	auipc	a0,0x3
    80001a68:	dc453503          	ld	a0,-572(a0) # 80004828 <_ZN15MemoryAllocator12freeListHeadE>
    FreeBlock* prev = nullptr;
    80001a6c:	00000693          	li	a3,0
    while(curr != nullptr){
    80001a70:	04050263          	beqz	a0,80001ab4 <_ZN15MemoryAllocator5allocEm+0x68>
        if(curr->size >= roundedSize){
    80001a74:	00853783          	ld	a5,8(a0)
    80001a78:	00e7f863          	bgeu	a5,a4,80001a88 <_ZN15MemoryAllocator5allocEm+0x3c>
                    freeListHead = curr->next;
                }
            }
            return (char*)curr + sizeof(FreeBlock);
        }
        prev = curr;
    80001a7c:	00050693          	mv	a3,a0
        curr = curr->next;
    80001a80:	00053503          	ld	a0,0(a0)
    while(curr != nullptr){
    80001a84:	fedff06f          	j	80001a70 <_ZN15MemoryAllocator5allocEm+0x24>
            size_t remainder = curr->size - roundedSize;
    80001a88:	40e787b3          	sub	a5,a5,a4
            if (remainder >= MEM_BLOCK_SIZE) {
    80001a8c:	03f00613          	li	a2,63
    80001a90:	02f67e63          	bgeu	a2,a5,80001acc <_ZN15MemoryAllocator5allocEm+0x80>
                FreeBlock* newBlock = (FreeBlock*)((char*)curr + roundedSize);
    80001a94:	00e50633          	add	a2,a0,a4
                newBlock->size = remainder;
    80001a98:	00f63423          	sd	a5,8(a2)
                newBlock->next = curr->next;
    80001a9c:	00053783          	ld	a5,0(a0)
    80001aa0:	00f63023          	sd	a5,0(a2)
                if (prev != nullptr) {
    80001aa4:	00068e63          	beqz	a3,80001ac0 <_ZN15MemoryAllocator5allocEm+0x74>
                    prev->next = newBlock;
    80001aa8:	00c6b023          	sd	a2,0(a3)
                curr->size = roundedSize;
    80001aac:	00e53423          	sd	a4,8(a0)
            return (char*)curr + sizeof(FreeBlock);
    80001ab0:	01050513          	addi	a0,a0,16
    }
    return nullptr;   // nema dovoljno velikog bloka
}
    80001ab4:	00813403          	ld	s0,8(sp)
    80001ab8:	01010113          	addi	sp,sp,16
    80001abc:	00008067          	ret
                    freeListHead = newBlock;
    80001ac0:	00003797          	auipc	a5,0x3
    80001ac4:	d6c7b423          	sd	a2,-664(a5) # 80004828 <_ZN15MemoryAllocator12freeListHeadE>
    80001ac8:	fe5ff06f          	j	80001aac <_ZN15MemoryAllocator5allocEm+0x60>
                if (prev != nullptr) {
    80001acc:	00068863          	beqz	a3,80001adc <_ZN15MemoryAllocator5allocEm+0x90>
                    prev->next = curr->next;
    80001ad0:	00053783          	ld	a5,0(a0)
    80001ad4:	00f6b023          	sd	a5,0(a3)
    80001ad8:	fd9ff06f          	j	80001ab0 <_ZN15MemoryAllocator5allocEm+0x64>
                    freeListHead = curr->next;
    80001adc:	00053783          	ld	a5,0(a0)
    80001ae0:	00003717          	auipc	a4,0x3
    80001ae4:	d4f73423          	sd	a5,-696(a4) # 80004828 <_ZN15MemoryAllocator12freeListHeadE>
    80001ae8:	fc9ff06f          	j	80001ab0 <_ZN15MemoryAllocator5allocEm+0x64>
        return nullptr;
    80001aec:	00000513          	li	a0,0
    80001af0:	fc5ff06f          	j	80001ab4 <_ZN15MemoryAllocator5allocEm+0x68>

0000000080001af4 <_ZN15MemoryAllocator13printFreeListEv>:

// debug ispis slobodne liste (nije deo resenja koje se predaje)
void MemoryAllocator::printFreeList() {
    80001af4:	fe010113          	addi	sp,sp,-32
    80001af8:	00113c23          	sd	ra,24(sp)
    80001afc:	00813823          	sd	s0,16(sp)
    80001b00:	00913423          	sd	s1,8(sp)
    80001b04:	02010413          	addi	s0,sp,32
    FreeBlock* curr = freeListHead;
    80001b08:	00003497          	auipc	s1,0x3
    80001b0c:	d204b483          	ld	s1,-736(s1) # 80004828 <_ZN15MemoryAllocator12freeListHeadE>
    kputs("free list:\n");
    80001b10:	00002517          	auipc	a0,0x2
    80001b14:	5c850513          	addi	a0,a0,1480 # 800040d8 <CONSOLE_STATUS+0xc8>
    80001b18:	fffff097          	auipc	ra,0xfffff
    80001b1c:	778080e7          	jalr	1912(ra) # 80001290 <_Z5kputsPKc>
    while (curr != nullptr) {
    80001b20:	04048a63          	beqz	s1,80001b74 <_ZN15MemoryAllocator13printFreeListEv+0x80>
        kputs("  blok na ");
    80001b24:	00002517          	auipc	a0,0x2
    80001b28:	5c450513          	addi	a0,a0,1476 # 800040e8 <CONSOLE_STATUS+0xd8>
    80001b2c:	fffff097          	auipc	ra,0xfffff
    80001b30:	764080e7          	jalr	1892(ra) # 80001290 <_Z5kputsPKc>
        kputhex((uint64)curr);
    80001b34:	00048513          	mv	a0,s1
    80001b38:	fffff097          	auipc	ra,0xfffff
    80001b3c:	79c080e7          	jalr	1948(ra) # 800012d4 <_Z7kputhexm>
        kputs(", size: ");
    80001b40:	00002517          	auipc	a0,0x2
    80001b44:	5b850513          	addi	a0,a0,1464 # 800040f8 <CONSOLE_STATUS+0xe8>
    80001b48:	fffff097          	auipc	ra,0xfffff
    80001b4c:	748080e7          	jalr	1864(ra) # 80001290 <_Z5kputsPKc>
        kputhex(curr->size);
    80001b50:	0084b503          	ld	a0,8(s1)
    80001b54:	fffff097          	auipc	ra,0xfffff
    80001b58:	780080e7          	jalr	1920(ra) # 800012d4 <_Z7kputhexm>
        kputs("\n");
    80001b5c:	00002517          	auipc	a0,0x2
    80001b60:	71450513          	addi	a0,a0,1812 # 80004270 <CONSOLE_STATUS+0x260>
    80001b64:	fffff097          	auipc	ra,0xfffff
    80001b68:	72c080e7          	jalr	1836(ra) # 80001290 <_Z5kputsPKc>
        curr = curr->next;
    80001b6c:	0004b483          	ld	s1,0(s1)
    while (curr != nullptr) {
    80001b70:	fb1ff06f          	j	80001b20 <_ZN15MemoryAllocator13printFreeListEv+0x2c>
    }
}
    80001b74:	01813083          	ld	ra,24(sp)
    80001b78:	01013403          	ld	s0,16(sp)
    80001b7c:	00813483          	ld	s1,8(sp)
    80001b80:	02010113          	addi	sp,sp,32
    80001b84:	00008067          	ret

0000000080001b88 <_ZN15MemoryAllocator4freeEPv>:

int MemoryAllocator::free(void* ptr){
    80001b88:	ff010113          	addi	sp,sp,-16
    80001b8c:	00813423          	sd	s0,8(sp)
    80001b90:	01010413          	addi	s0,sp,16
    if (ptr == nullptr) return -1;
    80001b94:	12050663          	beqz	a0,80001cc0 <_ZN15MemoryAllocator4freeEPv+0x138>
    FreeBlock* curr = freeListHead;
    80001b98:	00003797          	auipc	a5,0x3
    80001b9c:	c907b783          	ld	a5,-880(a5) # 80004828 <_ZN15MemoryAllocator12freeListHeadE>
    FreeBlock* prev = nullptr;
    // heder zivi tacno ispred payload-a
    FreeBlock* block = (FreeBlock*)((char*)ptr - sizeof(FreeBlock));
    80001ba0:	ff050693          	addi	a3,a0,-16
    FreeBlock* prev = nullptr;
    80001ba4:	00000713          	li	a4,0
    // nadji mesto po adresi (lista je sortirana da bi spajanje radilo)
    while(curr != nullptr && curr < block){
    80001ba8:	00078a63          	beqz	a5,80001bbc <_ZN15MemoryAllocator4freeEPv+0x34>
    80001bac:	00d7f863          	bgeu	a5,a3,80001bbc <_ZN15MemoryAllocator4freeEPv+0x34>
        prev = curr;
    80001bb0:	00078713          	mv	a4,a5
        curr = curr->next;
    80001bb4:	0007b783          	ld	a5,0(a5)
    while(curr != nullptr && curr < block){
    80001bb8:	ff1ff06f          	j	80001ba8 <_ZN15MemoryAllocator4freeEPv+0x20>
    }

    // da li se blok fizicki naslanja na suseda ispred/iza?
    bool mergePrev = (prev != nullptr) && ((char*)prev + prev->size == (char*)block);
    80001bbc:	04070263          	beqz	a4,80001c00 <_ZN15MemoryAllocator4freeEPv+0x78>
    80001bc0:	00873603          	ld	a2,8(a4)
    80001bc4:	00c70633          	add	a2,a4,a2
    80001bc8:	04d60063          	beq	a2,a3,80001c08 <_ZN15MemoryAllocator4freeEPv+0x80>
    80001bcc:	00000613          	li	a2,0
    bool mergeNext = (curr != nullptr) && ((char*)block + block->size == (char*)curr);
    80001bd0:	04078063          	beqz	a5,80001c10 <_ZN15MemoryAllocator4freeEPv+0x88>
    80001bd4:	ff853583          	ld	a1,-8(a0)
    80001bd8:	00b685b3          	add	a1,a3,a1
    80001bdc:	02f58e63          	beq	a1,a5,80001c18 <_ZN15MemoryAllocator4freeEPv+0x90>
    80001be0:	00000593          	li	a1,0

    if (!mergePrev && !mergeNext) {
    80001be4:	04061663          	bnez	a2,80001c30 <_ZN15MemoryAllocator4freeEPv+0xa8>
    80001be8:	04059463          	bnez	a1,80001c30 <_ZN15MemoryAllocator4freeEPv+0xa8>
        // nema spajanja: samo umetni izmedju prev i curr
        block->next = curr;
    80001bec:	fef53823          	sd	a5,-16(a0)
        if (prev != nullptr) {
    80001bf0:	02070863          	beqz	a4,80001c20 <_ZN15MemoryAllocator4freeEPv+0x98>
            prev->next = block;
    80001bf4:	00d73023          	sd	a3,0(a4)
    } else {
        // spoji sa oba suseda
        prev->size += block->size + curr->size;
        prev->next = curr->next;
    }
    return 0;
    80001bf8:	00000513          	li	a0,0
    80001bfc:	0b80006f          	j	80001cb4 <_ZN15MemoryAllocator4freeEPv+0x12c>
    bool mergePrev = (prev != nullptr) && ((char*)prev + prev->size == (char*)block);
    80001c00:	00000613          	li	a2,0
    80001c04:	fcdff06f          	j	80001bd0 <_ZN15MemoryAllocator4freeEPv+0x48>
    80001c08:	00100613          	li	a2,1
    80001c0c:	fc5ff06f          	j	80001bd0 <_ZN15MemoryAllocator4freeEPv+0x48>
    bool mergeNext = (curr != nullptr) && ((char*)block + block->size == (char*)curr);
    80001c10:	00000593          	li	a1,0
    80001c14:	fd1ff06f          	j	80001be4 <_ZN15MemoryAllocator4freeEPv+0x5c>
    80001c18:	00100593          	li	a1,1
    80001c1c:	fc9ff06f          	j	80001be4 <_ZN15MemoryAllocator4freeEPv+0x5c>
            freeListHead = block;
    80001c20:	00003797          	auipc	a5,0x3
    80001c24:	c0d7b423          	sd	a3,-1016(a5) # 80004828 <_ZN15MemoryAllocator12freeListHeadE>
    return 0;
    80001c28:	00000513          	li	a0,0
    80001c2c:	0880006f          	j	80001cb4 <_ZN15MemoryAllocator4freeEPv+0x12c>
    } else if (mergePrev && !mergeNext) {
    80001c30:	02060063          	beqz	a2,80001c50 <_ZN15MemoryAllocator4freeEPv+0xc8>
    80001c34:	00059e63          	bnez	a1,80001c50 <_ZN15MemoryAllocator4freeEPv+0xc8>
        prev->size += block->size;
    80001c38:	ff853683          	ld	a3,-8(a0)
    80001c3c:	00873783          	ld	a5,8(a4)
    80001c40:	00d787b3          	add	a5,a5,a3
    80001c44:	00f73423          	sd	a5,8(a4)
    return 0;
    80001c48:	00000513          	li	a0,0
        prev->size += block->size;
    80001c4c:	0680006f          	j	80001cb4 <_ZN15MemoryAllocator4freeEPv+0x12c>
    } else if (!mergePrev && mergeNext) {
    80001c50:	04061063          	bnez	a2,80001c90 <_ZN15MemoryAllocator4freeEPv+0x108>
    80001c54:	02058e63          	beqz	a1,80001c90 <_ZN15MemoryAllocator4freeEPv+0x108>
        block->size += curr->size;
    80001c58:	0087b583          	ld	a1,8(a5)
    80001c5c:	ff853603          	ld	a2,-8(a0)
    80001c60:	00b60633          	add	a2,a2,a1
    80001c64:	fec53c23          	sd	a2,-8(a0)
        block->next = curr->next;
    80001c68:	0007b783          	ld	a5,0(a5)
    80001c6c:	fef53823          	sd	a5,-16(a0)
        if (prev != nullptr) {
    80001c70:	00070863          	beqz	a4,80001c80 <_ZN15MemoryAllocator4freeEPv+0xf8>
            prev->next = block;
    80001c74:	00d73023          	sd	a3,0(a4)
    return 0;
    80001c78:	00000513          	li	a0,0
    80001c7c:	0380006f          	j	80001cb4 <_ZN15MemoryAllocator4freeEPv+0x12c>
            freeListHead = block;
    80001c80:	00003797          	auipc	a5,0x3
    80001c84:	bad7b423          	sd	a3,-1112(a5) # 80004828 <_ZN15MemoryAllocator12freeListHeadE>
    return 0;
    80001c88:	00000513          	li	a0,0
    80001c8c:	0280006f          	j	80001cb4 <_ZN15MemoryAllocator4freeEPv+0x12c>
        prev->size += block->size + curr->size;
    80001c90:	ff853683          	ld	a3,-8(a0)
    80001c94:	0087b603          	ld	a2,8(a5)
    80001c98:	00c68633          	add	a2,a3,a2
    80001c9c:	00873683          	ld	a3,8(a4)
    80001ca0:	00c686b3          	add	a3,a3,a2
    80001ca4:	00d73423          	sd	a3,8(a4)
        prev->next = curr->next;
    80001ca8:	0007b783          	ld	a5,0(a5)
    80001cac:	00f73023          	sd	a5,0(a4)
    return 0;
    80001cb0:	00000513          	li	a0,0
}
    80001cb4:	00813403          	ld	s0,8(sp)
    80001cb8:	01010113          	addi	sp,sp,16
    80001cbc:	00008067          	ret
    if (ptr == nullptr) return -1;
    80001cc0:	fff00513          	li	a0,-1
    80001cc4:	ff1ff06f          	j	80001cb4 <_ZN15MemoryAllocator4freeEPv+0x12c>

0000000080001cc8 <main>:

extern "C" void trapHandler();

void userMain();   // definisana u test fajlu

int main() {
    80001cc8:	fe010113          	addi	sp,sp,-32
    80001ccc:	00113c23          	sd	ra,24(sp)
    80001cd0:	00813823          	sd	s0,16(sp)
    80001cd4:	00913423          	sd	s1,8(sp)
    80001cd8:	02010413          	addi	s0,sp,32
    kputs(">> kernel: starting\n");
    80001cdc:	00002517          	auipc	a0,0x2
    80001ce0:	42c50513          	addi	a0,a0,1068 # 80004108 <CONSOLE_STATUS+0xf8>
    80001ce4:	fffff097          	auipc	ra,0xfffff
    80001ce8:	5ac080e7          	jalr	1452(ra) # 80001290 <_Z5kputsPKc>

    // stvec = adresa prekidne rutine: jedina kapija za ecall/izuzetke/prekide
    uint64 addr = (uint64)&trapHandler;
    80001cec:	fffff797          	auipc	a5,0xfffff
    80001cf0:	31478793          	addi	a5,a5,788 # 80001000 <trapHandler>
    asm volatile("csrw stvec, %0" : : "r" (addr));
    80001cf4:	10579073          	csrw	stvec,a5
    // maskiraj prekide PO VRSTI, u sie registru: ssie (tajmer, bit 1) +
    // seie (konzola, bit 9). sie vazi u OBA rezima - i u korisnickom,
    // gde se sstatus.SIE ignorise. zahtevi se pamte u sip, ali ne stizu.
    // u zadatku 4 se ovi biti samo ukljuce nazad.
    uint64 sie;
    asm volatile("csrr %0, sie" : "=r"(sie));
    80001cf8:	104027f3          	csrr	a5,sie
    sie &= ~((1UL << 1) | (1UL << 9));
    80001cfc:	dfd7f793          	andi	a5,a5,-515
    asm volatile("csrw sie, %0" : : "r"(sie));
    80001d00:	10479073          	csrw	sie,a5

    // dokaz da je maska stvarno upisana
    asm volatile("csrr %0, sie" : "=r"(sie));
    80001d04:	104024f3          	csrr	s1,sie
    kputs(">> sie posle maske = "); kputhex(sie); kputs("\n");
    80001d08:	00002517          	auipc	a0,0x2
    80001d0c:	41850513          	addi	a0,a0,1048 # 80004120 <CONSOLE_STATUS+0x110>
    80001d10:	fffff097          	auipc	ra,0xfffff
    80001d14:	580080e7          	jalr	1408(ra) # 80001290 <_Z5kputsPKc>
    80001d18:	00048513          	mv	a0,s1
    80001d1c:	fffff097          	auipc	ra,0xfffff
    80001d20:	5b8080e7          	jalr	1464(ra) # 800012d4 <_Z7kputhexm>
    80001d24:	00002517          	auipc	a0,0x2
    80001d28:	54c50513          	addi	a0,a0,1356 # 80004270 <CONSOLE_STATUS+0x260>
    80001d2c:	fffff097          	auipc	ra,0xfffff
    80001d30:	564080e7          	jalr	1380(ra) # 80001290 <_Z5kputsPKc>

    MemoryAllocator::init();
    80001d34:	00000097          	auipc	ra,0x0
    80001d38:	ccc080e7          	jalr	-820(ra) # 80001a00 <_ZN15MemoryAllocator4initEv>

    // main postaje "nulta" nit: dobija svoj tcb da ima gde da se zamrzne
    // kad prvi put ustupi procesor (kontekst mu se popuni pri prvom dispatch-u)
    TCB::running = TCB::createThread(nullptr, nullptr, nullptr, true);   // nulta nit je sistemska
    80001d3c:	00100693          	li	a3,1
    80001d40:	00000613          	li	a2,0
    80001d44:	00000593          	li	a1,0
    80001d48:	00000513          	li	a0,0
    80001d4c:	00000097          	auipc	ra,0x0
    80001d50:	a28080e7          	jalr	-1496(ra) # 80001774 <_ZN3TCB12createThreadEPFvPvES0_S0_b>
    80001d54:	00003797          	auipc	a5,0x3
    80001d58:	aaa7be23          	sd	a0,-1348(a5) # 80004810 <_ZN3TCB7runningE>

    userMain();    // privremeno: obican poziv funkcije; kasnije postaje
    80001d5c:	00000097          	auipc	ra,0x0
    80001d60:	880080e7          	jalr	-1920(ra) # 800015dc <_Z8userMainv>
                   // telo prve niti koju pokrece jezgro

    kputs(">> kernel: userMain returned, halting\n");
    80001d64:	00002517          	auipc	a0,0x2
    80001d68:	3d450513          	addi	a0,a0,980 # 80004138 <CONSOLE_STATUS+0x128>
    80001d6c:	fffff097          	auipc	ra,0xfffff
    80001d70:	524080e7          	jalr	1316(ra) # 80001290 <_Z5kputsPKc>

    // upis 0x5555 na 0x100000 gasi emulator (regularan kraj procesa)
    *(volatile int*)0x100000 = 0x5555;
    80001d74:	00100737          	lui	a4,0x100
    80001d78:	000057b7          	lui	a5,0x5
    80001d7c:	5557879b          	addiw	a5,a5,1365
    80001d80:	00f72023          	sw	a5,0(a4) # 100000 <_entry-0x7ff00000>

    return 0;
}
    80001d84:	00000513          	li	a0,0
    80001d88:	01813083          	ld	ra,24(sp)
    80001d8c:	01013403          	ld	s0,16(sp)
    80001d90:	00813483          	ld	s1,8(sp)
    80001d94:	02010113          	addi	sp,sp,32
    80001d98:	00008067          	ret

0000000080001d9c <start>:
    80001d9c:	ff010113          	addi	sp,sp,-16
    80001da0:	00813423          	sd	s0,8(sp)
    80001da4:	01010413          	addi	s0,sp,16
    80001da8:	300027f3          	csrr	a5,mstatus
    80001dac:	ffffe737          	lui	a4,0xffffe
    80001db0:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fff8d4f>
    80001db4:	00e7f7b3          	and	a5,a5,a4
    80001db8:	00001737          	lui	a4,0x1
    80001dbc:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80001dc0:	00e7e7b3          	or	a5,a5,a4
    80001dc4:	30079073          	csrw	mstatus,a5
    80001dc8:	00000797          	auipc	a5,0x0
    80001dcc:	16078793          	addi	a5,a5,352 # 80001f28 <system_main>
    80001dd0:	34179073          	csrw	mepc,a5
    80001dd4:	00000793          	li	a5,0
    80001dd8:	18079073          	csrw	satp,a5
    80001ddc:	000107b7          	lui	a5,0x10
    80001de0:	fff78793          	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80001de4:	30279073          	csrw	medeleg,a5
    80001de8:	30379073          	csrw	mideleg,a5
    80001dec:	104027f3          	csrr	a5,sie
    80001df0:	2227e793          	ori	a5,a5,546
    80001df4:	10479073          	csrw	sie,a5
    80001df8:	fff00793          	li	a5,-1
    80001dfc:	00a7d793          	srli	a5,a5,0xa
    80001e00:	3b079073          	csrw	pmpaddr0,a5
    80001e04:	00f00793          	li	a5,15
    80001e08:	3a079073          	csrw	pmpcfg0,a5
    80001e0c:	f14027f3          	csrr	a5,mhartid
    80001e10:	0200c737          	lui	a4,0x200c
    80001e14:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80001e18:	0007869b          	sext.w	a3,a5
    80001e1c:	00269713          	slli	a4,a3,0x2
    80001e20:	000f4637          	lui	a2,0xf4
    80001e24:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80001e28:	00d70733          	add	a4,a4,a3
    80001e2c:	0037979b          	slliw	a5,a5,0x3
    80001e30:	020046b7          	lui	a3,0x2004
    80001e34:	00d787b3          	add	a5,a5,a3
    80001e38:	00c585b3          	add	a1,a1,a2
    80001e3c:	00371693          	slli	a3,a4,0x3
    80001e40:	00003717          	auipc	a4,0x3
    80001e44:	a2070713          	addi	a4,a4,-1504 # 80004860 <timer_scratch>
    80001e48:	00b7b023          	sd	a1,0(a5)
    80001e4c:	00d70733          	add	a4,a4,a3
    80001e50:	00f73c23          	sd	a5,24(a4)
    80001e54:	02c73023          	sd	a2,32(a4)
    80001e58:	34071073          	csrw	mscratch,a4
    80001e5c:	00000797          	auipc	a5,0x0
    80001e60:	6e478793          	addi	a5,a5,1764 # 80002540 <timervec>
    80001e64:	30579073          	csrw	mtvec,a5
    80001e68:	300027f3          	csrr	a5,mstatus
    80001e6c:	0087e793          	ori	a5,a5,8
    80001e70:	30079073          	csrw	mstatus,a5
    80001e74:	304027f3          	csrr	a5,mie
    80001e78:	0807e793          	ori	a5,a5,128
    80001e7c:	30479073          	csrw	mie,a5
    80001e80:	f14027f3          	csrr	a5,mhartid
    80001e84:	0007879b          	sext.w	a5,a5
    80001e88:	00078213          	mv	tp,a5
    80001e8c:	30200073          	mret
    80001e90:	00813403          	ld	s0,8(sp)
    80001e94:	01010113          	addi	sp,sp,16
    80001e98:	00008067          	ret

0000000080001e9c <timerinit>:
    80001e9c:	ff010113          	addi	sp,sp,-16
    80001ea0:	00813423          	sd	s0,8(sp)
    80001ea4:	01010413          	addi	s0,sp,16
    80001ea8:	f14027f3          	csrr	a5,mhartid
    80001eac:	0200c737          	lui	a4,0x200c
    80001eb0:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80001eb4:	0007869b          	sext.w	a3,a5
    80001eb8:	00269713          	slli	a4,a3,0x2
    80001ebc:	000f4637          	lui	a2,0xf4
    80001ec0:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80001ec4:	00d70733          	add	a4,a4,a3
    80001ec8:	0037979b          	slliw	a5,a5,0x3
    80001ecc:	020046b7          	lui	a3,0x2004
    80001ed0:	00d787b3          	add	a5,a5,a3
    80001ed4:	00c585b3          	add	a1,a1,a2
    80001ed8:	00371693          	slli	a3,a4,0x3
    80001edc:	00003717          	auipc	a4,0x3
    80001ee0:	98470713          	addi	a4,a4,-1660 # 80004860 <timer_scratch>
    80001ee4:	00b7b023          	sd	a1,0(a5)
    80001ee8:	00d70733          	add	a4,a4,a3
    80001eec:	00f73c23          	sd	a5,24(a4)
    80001ef0:	02c73023          	sd	a2,32(a4)
    80001ef4:	34071073          	csrw	mscratch,a4
    80001ef8:	00000797          	auipc	a5,0x0
    80001efc:	64878793          	addi	a5,a5,1608 # 80002540 <timervec>
    80001f00:	30579073          	csrw	mtvec,a5
    80001f04:	300027f3          	csrr	a5,mstatus
    80001f08:	0087e793          	ori	a5,a5,8
    80001f0c:	30079073          	csrw	mstatus,a5
    80001f10:	304027f3          	csrr	a5,mie
    80001f14:	0807e793          	ori	a5,a5,128
    80001f18:	30479073          	csrw	mie,a5
    80001f1c:	00813403          	ld	s0,8(sp)
    80001f20:	01010113          	addi	sp,sp,16
    80001f24:	00008067          	ret

0000000080001f28 <system_main>:
    80001f28:	fe010113          	addi	sp,sp,-32
    80001f2c:	00813823          	sd	s0,16(sp)
    80001f30:	00913423          	sd	s1,8(sp)
    80001f34:	00113c23          	sd	ra,24(sp)
    80001f38:	02010413          	addi	s0,sp,32
    80001f3c:	00000097          	auipc	ra,0x0
    80001f40:	0c4080e7          	jalr	196(ra) # 80002000 <cpuid>
    80001f44:	00003497          	auipc	s1,0x3
    80001f48:	8ec48493          	addi	s1,s1,-1812 # 80004830 <started>
    80001f4c:	02050263          	beqz	a0,80001f70 <system_main+0x48>
    80001f50:	0004a783          	lw	a5,0(s1)
    80001f54:	0007879b          	sext.w	a5,a5
    80001f58:	fe078ce3          	beqz	a5,80001f50 <system_main+0x28>
    80001f5c:	0ff0000f          	fence
    80001f60:	00002517          	auipc	a0,0x2
    80001f64:	23050513          	addi	a0,a0,560 # 80004190 <CONSOLE_STATUS+0x180>
    80001f68:	00001097          	auipc	ra,0x1
    80001f6c:	a74080e7          	jalr	-1420(ra) # 800029dc <panic>
    80001f70:	00001097          	auipc	ra,0x1
    80001f74:	9c8080e7          	jalr	-1592(ra) # 80002938 <consoleinit>
    80001f78:	00001097          	auipc	ra,0x1
    80001f7c:	154080e7          	jalr	340(ra) # 800030cc <printfinit>
    80001f80:	00002517          	auipc	a0,0x2
    80001f84:	2f050513          	addi	a0,a0,752 # 80004270 <CONSOLE_STATUS+0x260>
    80001f88:	00001097          	auipc	ra,0x1
    80001f8c:	ab0080e7          	jalr	-1360(ra) # 80002a38 <__printf>
    80001f90:	00002517          	auipc	a0,0x2
    80001f94:	1d050513          	addi	a0,a0,464 # 80004160 <CONSOLE_STATUS+0x150>
    80001f98:	00001097          	auipc	ra,0x1
    80001f9c:	aa0080e7          	jalr	-1376(ra) # 80002a38 <__printf>
    80001fa0:	00002517          	auipc	a0,0x2
    80001fa4:	2d050513          	addi	a0,a0,720 # 80004270 <CONSOLE_STATUS+0x260>
    80001fa8:	00001097          	auipc	ra,0x1
    80001fac:	a90080e7          	jalr	-1392(ra) # 80002a38 <__printf>
    80001fb0:	00001097          	auipc	ra,0x1
    80001fb4:	4a8080e7          	jalr	1192(ra) # 80003458 <kinit>
    80001fb8:	00000097          	auipc	ra,0x0
    80001fbc:	148080e7          	jalr	328(ra) # 80002100 <trapinit>
    80001fc0:	00000097          	auipc	ra,0x0
    80001fc4:	16c080e7          	jalr	364(ra) # 8000212c <trapinithart>
    80001fc8:	00000097          	auipc	ra,0x0
    80001fcc:	5b8080e7          	jalr	1464(ra) # 80002580 <plicinit>
    80001fd0:	00000097          	auipc	ra,0x0
    80001fd4:	5d8080e7          	jalr	1496(ra) # 800025a8 <plicinithart>
    80001fd8:	00000097          	auipc	ra,0x0
    80001fdc:	078080e7          	jalr	120(ra) # 80002050 <userinit>
    80001fe0:	0ff0000f          	fence
    80001fe4:	00100793          	li	a5,1
    80001fe8:	00002517          	auipc	a0,0x2
    80001fec:	19050513          	addi	a0,a0,400 # 80004178 <CONSOLE_STATUS+0x168>
    80001ff0:	00f4a023          	sw	a5,0(s1)
    80001ff4:	00001097          	auipc	ra,0x1
    80001ff8:	a44080e7          	jalr	-1468(ra) # 80002a38 <__printf>
    80001ffc:	0000006f          	j	80001ffc <system_main+0xd4>

0000000080002000 <cpuid>:
    80002000:	ff010113          	addi	sp,sp,-16
    80002004:	00813423          	sd	s0,8(sp)
    80002008:	01010413          	addi	s0,sp,16
    8000200c:	00020513          	mv	a0,tp
    80002010:	00813403          	ld	s0,8(sp)
    80002014:	0005051b          	sext.w	a0,a0
    80002018:	01010113          	addi	sp,sp,16
    8000201c:	00008067          	ret

0000000080002020 <mycpu>:
    80002020:	ff010113          	addi	sp,sp,-16
    80002024:	00813423          	sd	s0,8(sp)
    80002028:	01010413          	addi	s0,sp,16
    8000202c:	00020793          	mv	a5,tp
    80002030:	00813403          	ld	s0,8(sp)
    80002034:	0007879b          	sext.w	a5,a5
    80002038:	00779793          	slli	a5,a5,0x7
    8000203c:	00004517          	auipc	a0,0x4
    80002040:	85450513          	addi	a0,a0,-1964 # 80005890 <cpus>
    80002044:	00f50533          	add	a0,a0,a5
    80002048:	01010113          	addi	sp,sp,16
    8000204c:	00008067          	ret

0000000080002050 <userinit>:
    80002050:	ff010113          	addi	sp,sp,-16
    80002054:	00813423          	sd	s0,8(sp)
    80002058:	01010413          	addi	s0,sp,16
    8000205c:	00813403          	ld	s0,8(sp)
    80002060:	01010113          	addi	sp,sp,16
    80002064:	00000317          	auipc	t1,0x0
    80002068:	c6430067          	jr	-924(t1) # 80001cc8 <main>

000000008000206c <either_copyout>:
    8000206c:	ff010113          	addi	sp,sp,-16
    80002070:	00813023          	sd	s0,0(sp)
    80002074:	00113423          	sd	ra,8(sp)
    80002078:	01010413          	addi	s0,sp,16
    8000207c:	02051663          	bnez	a0,800020a8 <either_copyout+0x3c>
    80002080:	00058513          	mv	a0,a1
    80002084:	00060593          	mv	a1,a2
    80002088:	0006861b          	sext.w	a2,a3
    8000208c:	00002097          	auipc	ra,0x2
    80002090:	c58080e7          	jalr	-936(ra) # 80003ce4 <__memmove>
    80002094:	00813083          	ld	ra,8(sp)
    80002098:	00013403          	ld	s0,0(sp)
    8000209c:	00000513          	li	a0,0
    800020a0:	01010113          	addi	sp,sp,16
    800020a4:	00008067          	ret
    800020a8:	00002517          	auipc	a0,0x2
    800020ac:	11050513          	addi	a0,a0,272 # 800041b8 <CONSOLE_STATUS+0x1a8>
    800020b0:	00001097          	auipc	ra,0x1
    800020b4:	92c080e7          	jalr	-1748(ra) # 800029dc <panic>

00000000800020b8 <either_copyin>:
    800020b8:	ff010113          	addi	sp,sp,-16
    800020bc:	00813023          	sd	s0,0(sp)
    800020c0:	00113423          	sd	ra,8(sp)
    800020c4:	01010413          	addi	s0,sp,16
    800020c8:	02059463          	bnez	a1,800020f0 <either_copyin+0x38>
    800020cc:	00060593          	mv	a1,a2
    800020d0:	0006861b          	sext.w	a2,a3
    800020d4:	00002097          	auipc	ra,0x2
    800020d8:	c10080e7          	jalr	-1008(ra) # 80003ce4 <__memmove>
    800020dc:	00813083          	ld	ra,8(sp)
    800020e0:	00013403          	ld	s0,0(sp)
    800020e4:	00000513          	li	a0,0
    800020e8:	01010113          	addi	sp,sp,16
    800020ec:	00008067          	ret
    800020f0:	00002517          	auipc	a0,0x2
    800020f4:	0f050513          	addi	a0,a0,240 # 800041e0 <CONSOLE_STATUS+0x1d0>
    800020f8:	00001097          	auipc	ra,0x1
    800020fc:	8e4080e7          	jalr	-1820(ra) # 800029dc <panic>

0000000080002100 <trapinit>:
    80002100:	ff010113          	addi	sp,sp,-16
    80002104:	00813423          	sd	s0,8(sp)
    80002108:	01010413          	addi	s0,sp,16
    8000210c:	00813403          	ld	s0,8(sp)
    80002110:	00002597          	auipc	a1,0x2
    80002114:	0f858593          	addi	a1,a1,248 # 80004208 <CONSOLE_STATUS+0x1f8>
    80002118:	00003517          	auipc	a0,0x3
    8000211c:	7f850513          	addi	a0,a0,2040 # 80005910 <tickslock>
    80002120:	01010113          	addi	sp,sp,16
    80002124:	00001317          	auipc	t1,0x1
    80002128:	5c430067          	jr	1476(t1) # 800036e8 <initlock>

000000008000212c <trapinithart>:
    8000212c:	ff010113          	addi	sp,sp,-16
    80002130:	00813423          	sd	s0,8(sp)
    80002134:	01010413          	addi	s0,sp,16
    80002138:	00000797          	auipc	a5,0x0
    8000213c:	2f878793          	addi	a5,a5,760 # 80002430 <kernelvec>
    80002140:	10579073          	csrw	stvec,a5
    80002144:	00813403          	ld	s0,8(sp)
    80002148:	01010113          	addi	sp,sp,16
    8000214c:	00008067          	ret

0000000080002150 <usertrap>:
    80002150:	ff010113          	addi	sp,sp,-16
    80002154:	00813423          	sd	s0,8(sp)
    80002158:	01010413          	addi	s0,sp,16
    8000215c:	00813403          	ld	s0,8(sp)
    80002160:	01010113          	addi	sp,sp,16
    80002164:	00008067          	ret

0000000080002168 <usertrapret>:
    80002168:	ff010113          	addi	sp,sp,-16
    8000216c:	00813423          	sd	s0,8(sp)
    80002170:	01010413          	addi	s0,sp,16
    80002174:	00813403          	ld	s0,8(sp)
    80002178:	01010113          	addi	sp,sp,16
    8000217c:	00008067          	ret

0000000080002180 <kerneltrap>:
    80002180:	fe010113          	addi	sp,sp,-32
    80002184:	00813823          	sd	s0,16(sp)
    80002188:	00113c23          	sd	ra,24(sp)
    8000218c:	00913423          	sd	s1,8(sp)
    80002190:	02010413          	addi	s0,sp,32
    80002194:	142025f3          	csrr	a1,scause
    80002198:	100027f3          	csrr	a5,sstatus
    8000219c:	0027f793          	andi	a5,a5,2
    800021a0:	10079c63          	bnez	a5,800022b8 <kerneltrap+0x138>
    800021a4:	142027f3          	csrr	a5,scause
    800021a8:	0207ce63          	bltz	a5,800021e4 <kerneltrap+0x64>
    800021ac:	00002517          	auipc	a0,0x2
    800021b0:	0a450513          	addi	a0,a0,164 # 80004250 <CONSOLE_STATUS+0x240>
    800021b4:	00001097          	auipc	ra,0x1
    800021b8:	884080e7          	jalr	-1916(ra) # 80002a38 <__printf>
    800021bc:	141025f3          	csrr	a1,sepc
    800021c0:	14302673          	csrr	a2,stval
    800021c4:	00002517          	auipc	a0,0x2
    800021c8:	09c50513          	addi	a0,a0,156 # 80004260 <CONSOLE_STATUS+0x250>
    800021cc:	00001097          	auipc	ra,0x1
    800021d0:	86c080e7          	jalr	-1940(ra) # 80002a38 <__printf>
    800021d4:	00002517          	auipc	a0,0x2
    800021d8:	0a450513          	addi	a0,a0,164 # 80004278 <CONSOLE_STATUS+0x268>
    800021dc:	00001097          	auipc	ra,0x1
    800021e0:	800080e7          	jalr	-2048(ra) # 800029dc <panic>
    800021e4:	0ff7f713          	andi	a4,a5,255
    800021e8:	00900693          	li	a3,9
    800021ec:	04d70063          	beq	a4,a3,8000222c <kerneltrap+0xac>
    800021f0:	fff00713          	li	a4,-1
    800021f4:	03f71713          	slli	a4,a4,0x3f
    800021f8:	00170713          	addi	a4,a4,1
    800021fc:	fae798e3          	bne	a5,a4,800021ac <kerneltrap+0x2c>
    80002200:	00000097          	auipc	ra,0x0
    80002204:	e00080e7          	jalr	-512(ra) # 80002000 <cpuid>
    80002208:	06050663          	beqz	a0,80002274 <kerneltrap+0xf4>
    8000220c:	144027f3          	csrr	a5,sip
    80002210:	ffd7f793          	andi	a5,a5,-3
    80002214:	14479073          	csrw	sip,a5
    80002218:	01813083          	ld	ra,24(sp)
    8000221c:	01013403          	ld	s0,16(sp)
    80002220:	00813483          	ld	s1,8(sp)
    80002224:	02010113          	addi	sp,sp,32
    80002228:	00008067          	ret
    8000222c:	00000097          	auipc	ra,0x0
    80002230:	3c8080e7          	jalr	968(ra) # 800025f4 <plic_claim>
    80002234:	00a00793          	li	a5,10
    80002238:	00050493          	mv	s1,a0
    8000223c:	06f50863          	beq	a0,a5,800022ac <kerneltrap+0x12c>
    80002240:	fc050ce3          	beqz	a0,80002218 <kerneltrap+0x98>
    80002244:	00050593          	mv	a1,a0
    80002248:	00002517          	auipc	a0,0x2
    8000224c:	fe850513          	addi	a0,a0,-24 # 80004230 <CONSOLE_STATUS+0x220>
    80002250:	00000097          	auipc	ra,0x0
    80002254:	7e8080e7          	jalr	2024(ra) # 80002a38 <__printf>
    80002258:	01013403          	ld	s0,16(sp)
    8000225c:	01813083          	ld	ra,24(sp)
    80002260:	00048513          	mv	a0,s1
    80002264:	00813483          	ld	s1,8(sp)
    80002268:	02010113          	addi	sp,sp,32
    8000226c:	00000317          	auipc	t1,0x0
    80002270:	3c030067          	jr	960(t1) # 8000262c <plic_complete>
    80002274:	00003517          	auipc	a0,0x3
    80002278:	69c50513          	addi	a0,a0,1692 # 80005910 <tickslock>
    8000227c:	00001097          	auipc	ra,0x1
    80002280:	490080e7          	jalr	1168(ra) # 8000370c <acquire>
    80002284:	00002717          	auipc	a4,0x2
    80002288:	5b070713          	addi	a4,a4,1456 # 80004834 <ticks>
    8000228c:	00072783          	lw	a5,0(a4)
    80002290:	00003517          	auipc	a0,0x3
    80002294:	68050513          	addi	a0,a0,1664 # 80005910 <tickslock>
    80002298:	0017879b          	addiw	a5,a5,1
    8000229c:	00f72023          	sw	a5,0(a4)
    800022a0:	00001097          	auipc	ra,0x1
    800022a4:	538080e7          	jalr	1336(ra) # 800037d8 <release>
    800022a8:	f65ff06f          	j	8000220c <kerneltrap+0x8c>
    800022ac:	00001097          	auipc	ra,0x1
    800022b0:	094080e7          	jalr	148(ra) # 80003340 <uartintr>
    800022b4:	fa5ff06f          	j	80002258 <kerneltrap+0xd8>
    800022b8:	00002517          	auipc	a0,0x2
    800022bc:	f5850513          	addi	a0,a0,-168 # 80004210 <CONSOLE_STATUS+0x200>
    800022c0:	00000097          	auipc	ra,0x0
    800022c4:	71c080e7          	jalr	1820(ra) # 800029dc <panic>

00000000800022c8 <clockintr>:
    800022c8:	fe010113          	addi	sp,sp,-32
    800022cc:	00813823          	sd	s0,16(sp)
    800022d0:	00913423          	sd	s1,8(sp)
    800022d4:	00113c23          	sd	ra,24(sp)
    800022d8:	02010413          	addi	s0,sp,32
    800022dc:	00003497          	auipc	s1,0x3
    800022e0:	63448493          	addi	s1,s1,1588 # 80005910 <tickslock>
    800022e4:	00048513          	mv	a0,s1
    800022e8:	00001097          	auipc	ra,0x1
    800022ec:	424080e7          	jalr	1060(ra) # 8000370c <acquire>
    800022f0:	00002717          	auipc	a4,0x2
    800022f4:	54470713          	addi	a4,a4,1348 # 80004834 <ticks>
    800022f8:	00072783          	lw	a5,0(a4)
    800022fc:	01013403          	ld	s0,16(sp)
    80002300:	01813083          	ld	ra,24(sp)
    80002304:	00048513          	mv	a0,s1
    80002308:	0017879b          	addiw	a5,a5,1
    8000230c:	00813483          	ld	s1,8(sp)
    80002310:	00f72023          	sw	a5,0(a4)
    80002314:	02010113          	addi	sp,sp,32
    80002318:	00001317          	auipc	t1,0x1
    8000231c:	4c030067          	jr	1216(t1) # 800037d8 <release>

0000000080002320 <devintr>:
    80002320:	142027f3          	csrr	a5,scause
    80002324:	00000513          	li	a0,0
    80002328:	0007c463          	bltz	a5,80002330 <devintr+0x10>
    8000232c:	00008067          	ret
    80002330:	fe010113          	addi	sp,sp,-32
    80002334:	00813823          	sd	s0,16(sp)
    80002338:	00113c23          	sd	ra,24(sp)
    8000233c:	00913423          	sd	s1,8(sp)
    80002340:	02010413          	addi	s0,sp,32
    80002344:	0ff7f713          	andi	a4,a5,255
    80002348:	00900693          	li	a3,9
    8000234c:	04d70c63          	beq	a4,a3,800023a4 <devintr+0x84>
    80002350:	fff00713          	li	a4,-1
    80002354:	03f71713          	slli	a4,a4,0x3f
    80002358:	00170713          	addi	a4,a4,1
    8000235c:	00e78c63          	beq	a5,a4,80002374 <devintr+0x54>
    80002360:	01813083          	ld	ra,24(sp)
    80002364:	01013403          	ld	s0,16(sp)
    80002368:	00813483          	ld	s1,8(sp)
    8000236c:	02010113          	addi	sp,sp,32
    80002370:	00008067          	ret
    80002374:	00000097          	auipc	ra,0x0
    80002378:	c8c080e7          	jalr	-884(ra) # 80002000 <cpuid>
    8000237c:	06050663          	beqz	a0,800023e8 <devintr+0xc8>
    80002380:	144027f3          	csrr	a5,sip
    80002384:	ffd7f793          	andi	a5,a5,-3
    80002388:	14479073          	csrw	sip,a5
    8000238c:	01813083          	ld	ra,24(sp)
    80002390:	01013403          	ld	s0,16(sp)
    80002394:	00813483          	ld	s1,8(sp)
    80002398:	00200513          	li	a0,2
    8000239c:	02010113          	addi	sp,sp,32
    800023a0:	00008067          	ret
    800023a4:	00000097          	auipc	ra,0x0
    800023a8:	250080e7          	jalr	592(ra) # 800025f4 <plic_claim>
    800023ac:	00a00793          	li	a5,10
    800023b0:	00050493          	mv	s1,a0
    800023b4:	06f50663          	beq	a0,a5,80002420 <devintr+0x100>
    800023b8:	00100513          	li	a0,1
    800023bc:	fa0482e3          	beqz	s1,80002360 <devintr+0x40>
    800023c0:	00048593          	mv	a1,s1
    800023c4:	00002517          	auipc	a0,0x2
    800023c8:	e6c50513          	addi	a0,a0,-404 # 80004230 <CONSOLE_STATUS+0x220>
    800023cc:	00000097          	auipc	ra,0x0
    800023d0:	66c080e7          	jalr	1644(ra) # 80002a38 <__printf>
    800023d4:	00048513          	mv	a0,s1
    800023d8:	00000097          	auipc	ra,0x0
    800023dc:	254080e7          	jalr	596(ra) # 8000262c <plic_complete>
    800023e0:	00100513          	li	a0,1
    800023e4:	f7dff06f          	j	80002360 <devintr+0x40>
    800023e8:	00003517          	auipc	a0,0x3
    800023ec:	52850513          	addi	a0,a0,1320 # 80005910 <tickslock>
    800023f0:	00001097          	auipc	ra,0x1
    800023f4:	31c080e7          	jalr	796(ra) # 8000370c <acquire>
    800023f8:	00002717          	auipc	a4,0x2
    800023fc:	43c70713          	addi	a4,a4,1084 # 80004834 <ticks>
    80002400:	00072783          	lw	a5,0(a4)
    80002404:	00003517          	auipc	a0,0x3
    80002408:	50c50513          	addi	a0,a0,1292 # 80005910 <tickslock>
    8000240c:	0017879b          	addiw	a5,a5,1
    80002410:	00f72023          	sw	a5,0(a4)
    80002414:	00001097          	auipc	ra,0x1
    80002418:	3c4080e7          	jalr	964(ra) # 800037d8 <release>
    8000241c:	f65ff06f          	j	80002380 <devintr+0x60>
    80002420:	00001097          	auipc	ra,0x1
    80002424:	f20080e7          	jalr	-224(ra) # 80003340 <uartintr>
    80002428:	fadff06f          	j	800023d4 <devintr+0xb4>
    8000242c:	0000                	unimp
	...

0000000080002430 <kernelvec>:
    80002430:	f0010113          	addi	sp,sp,-256
    80002434:	00113023          	sd	ra,0(sp)
    80002438:	00213423          	sd	sp,8(sp)
    8000243c:	00313823          	sd	gp,16(sp)
    80002440:	00413c23          	sd	tp,24(sp)
    80002444:	02513023          	sd	t0,32(sp)
    80002448:	02613423          	sd	t1,40(sp)
    8000244c:	02713823          	sd	t2,48(sp)
    80002450:	02813c23          	sd	s0,56(sp)
    80002454:	04913023          	sd	s1,64(sp)
    80002458:	04a13423          	sd	a0,72(sp)
    8000245c:	04b13823          	sd	a1,80(sp)
    80002460:	04c13c23          	sd	a2,88(sp)
    80002464:	06d13023          	sd	a3,96(sp)
    80002468:	06e13423          	sd	a4,104(sp)
    8000246c:	06f13823          	sd	a5,112(sp)
    80002470:	07013c23          	sd	a6,120(sp)
    80002474:	09113023          	sd	a7,128(sp)
    80002478:	09213423          	sd	s2,136(sp)
    8000247c:	09313823          	sd	s3,144(sp)
    80002480:	09413c23          	sd	s4,152(sp)
    80002484:	0b513023          	sd	s5,160(sp)
    80002488:	0b613423          	sd	s6,168(sp)
    8000248c:	0b713823          	sd	s7,176(sp)
    80002490:	0b813c23          	sd	s8,184(sp)
    80002494:	0d913023          	sd	s9,192(sp)
    80002498:	0da13423          	sd	s10,200(sp)
    8000249c:	0db13823          	sd	s11,208(sp)
    800024a0:	0dc13c23          	sd	t3,216(sp)
    800024a4:	0fd13023          	sd	t4,224(sp)
    800024a8:	0fe13423          	sd	t5,232(sp)
    800024ac:	0ff13823          	sd	t6,240(sp)
    800024b0:	cd1ff0ef          	jal	ra,80002180 <kerneltrap>
    800024b4:	00013083          	ld	ra,0(sp)
    800024b8:	00813103          	ld	sp,8(sp)
    800024bc:	01013183          	ld	gp,16(sp)
    800024c0:	02013283          	ld	t0,32(sp)
    800024c4:	02813303          	ld	t1,40(sp)
    800024c8:	03013383          	ld	t2,48(sp)
    800024cc:	03813403          	ld	s0,56(sp)
    800024d0:	04013483          	ld	s1,64(sp)
    800024d4:	04813503          	ld	a0,72(sp)
    800024d8:	05013583          	ld	a1,80(sp)
    800024dc:	05813603          	ld	a2,88(sp)
    800024e0:	06013683          	ld	a3,96(sp)
    800024e4:	06813703          	ld	a4,104(sp)
    800024e8:	07013783          	ld	a5,112(sp)
    800024ec:	07813803          	ld	a6,120(sp)
    800024f0:	08013883          	ld	a7,128(sp)
    800024f4:	08813903          	ld	s2,136(sp)
    800024f8:	09013983          	ld	s3,144(sp)
    800024fc:	09813a03          	ld	s4,152(sp)
    80002500:	0a013a83          	ld	s5,160(sp)
    80002504:	0a813b03          	ld	s6,168(sp)
    80002508:	0b013b83          	ld	s7,176(sp)
    8000250c:	0b813c03          	ld	s8,184(sp)
    80002510:	0c013c83          	ld	s9,192(sp)
    80002514:	0c813d03          	ld	s10,200(sp)
    80002518:	0d013d83          	ld	s11,208(sp)
    8000251c:	0d813e03          	ld	t3,216(sp)
    80002520:	0e013e83          	ld	t4,224(sp)
    80002524:	0e813f03          	ld	t5,232(sp)
    80002528:	0f013f83          	ld	t6,240(sp)
    8000252c:	10010113          	addi	sp,sp,256
    80002530:	10200073          	sret
    80002534:	00000013          	nop
    80002538:	00000013          	nop
    8000253c:	00000013          	nop

0000000080002540 <timervec>:
    80002540:	34051573          	csrrw	a0,mscratch,a0
    80002544:	00b53023          	sd	a1,0(a0)
    80002548:	00c53423          	sd	a2,8(a0)
    8000254c:	00d53823          	sd	a3,16(a0)
    80002550:	01853583          	ld	a1,24(a0)
    80002554:	02053603          	ld	a2,32(a0)
    80002558:	0005b683          	ld	a3,0(a1)
    8000255c:	00c686b3          	add	a3,a3,a2
    80002560:	00d5b023          	sd	a3,0(a1)
    80002564:	00200593          	li	a1,2
    80002568:	14459073          	csrw	sip,a1
    8000256c:	01053683          	ld	a3,16(a0)
    80002570:	00853603          	ld	a2,8(a0)
    80002574:	00053583          	ld	a1,0(a0)
    80002578:	34051573          	csrrw	a0,mscratch,a0
    8000257c:	30200073          	mret

0000000080002580 <plicinit>:
    80002580:	ff010113          	addi	sp,sp,-16
    80002584:	00813423          	sd	s0,8(sp)
    80002588:	01010413          	addi	s0,sp,16
    8000258c:	00813403          	ld	s0,8(sp)
    80002590:	0c0007b7          	lui	a5,0xc000
    80002594:	00100713          	li	a4,1
    80002598:	02e7a423          	sw	a4,40(a5) # c000028 <_entry-0x73ffffd8>
    8000259c:	00e7a223          	sw	a4,4(a5)
    800025a0:	01010113          	addi	sp,sp,16
    800025a4:	00008067          	ret

00000000800025a8 <plicinithart>:
    800025a8:	ff010113          	addi	sp,sp,-16
    800025ac:	00813023          	sd	s0,0(sp)
    800025b0:	00113423          	sd	ra,8(sp)
    800025b4:	01010413          	addi	s0,sp,16
    800025b8:	00000097          	auipc	ra,0x0
    800025bc:	a48080e7          	jalr	-1464(ra) # 80002000 <cpuid>
    800025c0:	0085171b          	slliw	a4,a0,0x8
    800025c4:	0c0027b7          	lui	a5,0xc002
    800025c8:	00e787b3          	add	a5,a5,a4
    800025cc:	40200713          	li	a4,1026
    800025d0:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>
    800025d4:	00813083          	ld	ra,8(sp)
    800025d8:	00013403          	ld	s0,0(sp)
    800025dc:	00d5151b          	slliw	a0,a0,0xd
    800025e0:	0c2017b7          	lui	a5,0xc201
    800025e4:	00a78533          	add	a0,a5,a0
    800025e8:	00052023          	sw	zero,0(a0)
    800025ec:	01010113          	addi	sp,sp,16
    800025f0:	00008067          	ret

00000000800025f4 <plic_claim>:
    800025f4:	ff010113          	addi	sp,sp,-16
    800025f8:	00813023          	sd	s0,0(sp)
    800025fc:	00113423          	sd	ra,8(sp)
    80002600:	01010413          	addi	s0,sp,16
    80002604:	00000097          	auipc	ra,0x0
    80002608:	9fc080e7          	jalr	-1540(ra) # 80002000 <cpuid>
    8000260c:	00813083          	ld	ra,8(sp)
    80002610:	00013403          	ld	s0,0(sp)
    80002614:	00d5151b          	slliw	a0,a0,0xd
    80002618:	0c2017b7          	lui	a5,0xc201
    8000261c:	00a78533          	add	a0,a5,a0
    80002620:	00452503          	lw	a0,4(a0)
    80002624:	01010113          	addi	sp,sp,16
    80002628:	00008067          	ret

000000008000262c <plic_complete>:
    8000262c:	fe010113          	addi	sp,sp,-32
    80002630:	00813823          	sd	s0,16(sp)
    80002634:	00913423          	sd	s1,8(sp)
    80002638:	00113c23          	sd	ra,24(sp)
    8000263c:	02010413          	addi	s0,sp,32
    80002640:	00050493          	mv	s1,a0
    80002644:	00000097          	auipc	ra,0x0
    80002648:	9bc080e7          	jalr	-1604(ra) # 80002000 <cpuid>
    8000264c:	01813083          	ld	ra,24(sp)
    80002650:	01013403          	ld	s0,16(sp)
    80002654:	00d5179b          	slliw	a5,a0,0xd
    80002658:	0c201737          	lui	a4,0xc201
    8000265c:	00f707b3          	add	a5,a4,a5
    80002660:	0097a223          	sw	s1,4(a5) # c201004 <_entry-0x73dfeffc>
    80002664:	00813483          	ld	s1,8(sp)
    80002668:	02010113          	addi	sp,sp,32
    8000266c:	00008067          	ret

0000000080002670 <consolewrite>:
    80002670:	fb010113          	addi	sp,sp,-80
    80002674:	04813023          	sd	s0,64(sp)
    80002678:	04113423          	sd	ra,72(sp)
    8000267c:	02913c23          	sd	s1,56(sp)
    80002680:	03213823          	sd	s2,48(sp)
    80002684:	03313423          	sd	s3,40(sp)
    80002688:	03413023          	sd	s4,32(sp)
    8000268c:	01513c23          	sd	s5,24(sp)
    80002690:	05010413          	addi	s0,sp,80
    80002694:	06c05c63          	blez	a2,8000270c <consolewrite+0x9c>
    80002698:	00060993          	mv	s3,a2
    8000269c:	00050a13          	mv	s4,a0
    800026a0:	00058493          	mv	s1,a1
    800026a4:	00000913          	li	s2,0
    800026a8:	fff00a93          	li	s5,-1
    800026ac:	01c0006f          	j	800026c8 <consolewrite+0x58>
    800026b0:	fbf44503          	lbu	a0,-65(s0)
    800026b4:	0019091b          	addiw	s2,s2,1
    800026b8:	00148493          	addi	s1,s1,1
    800026bc:	00001097          	auipc	ra,0x1
    800026c0:	a9c080e7          	jalr	-1380(ra) # 80003158 <uartputc>
    800026c4:	03298063          	beq	s3,s2,800026e4 <consolewrite+0x74>
    800026c8:	00048613          	mv	a2,s1
    800026cc:	00100693          	li	a3,1
    800026d0:	000a0593          	mv	a1,s4
    800026d4:	fbf40513          	addi	a0,s0,-65
    800026d8:	00000097          	auipc	ra,0x0
    800026dc:	9e0080e7          	jalr	-1568(ra) # 800020b8 <either_copyin>
    800026e0:	fd5518e3          	bne	a0,s5,800026b0 <consolewrite+0x40>
    800026e4:	04813083          	ld	ra,72(sp)
    800026e8:	04013403          	ld	s0,64(sp)
    800026ec:	03813483          	ld	s1,56(sp)
    800026f0:	02813983          	ld	s3,40(sp)
    800026f4:	02013a03          	ld	s4,32(sp)
    800026f8:	01813a83          	ld	s5,24(sp)
    800026fc:	00090513          	mv	a0,s2
    80002700:	03013903          	ld	s2,48(sp)
    80002704:	05010113          	addi	sp,sp,80
    80002708:	00008067          	ret
    8000270c:	00000913          	li	s2,0
    80002710:	fd5ff06f          	j	800026e4 <consolewrite+0x74>

0000000080002714 <consoleread>:
    80002714:	f9010113          	addi	sp,sp,-112
    80002718:	06813023          	sd	s0,96(sp)
    8000271c:	04913c23          	sd	s1,88(sp)
    80002720:	05213823          	sd	s2,80(sp)
    80002724:	05313423          	sd	s3,72(sp)
    80002728:	05413023          	sd	s4,64(sp)
    8000272c:	03513c23          	sd	s5,56(sp)
    80002730:	03613823          	sd	s6,48(sp)
    80002734:	03713423          	sd	s7,40(sp)
    80002738:	03813023          	sd	s8,32(sp)
    8000273c:	06113423          	sd	ra,104(sp)
    80002740:	01913c23          	sd	s9,24(sp)
    80002744:	07010413          	addi	s0,sp,112
    80002748:	00060b93          	mv	s7,a2
    8000274c:	00050913          	mv	s2,a0
    80002750:	00058c13          	mv	s8,a1
    80002754:	00060b1b          	sext.w	s6,a2
    80002758:	00003497          	auipc	s1,0x3
    8000275c:	1d048493          	addi	s1,s1,464 # 80005928 <cons>
    80002760:	00400993          	li	s3,4
    80002764:	fff00a13          	li	s4,-1
    80002768:	00a00a93          	li	s5,10
    8000276c:	05705e63          	blez	s7,800027c8 <consoleread+0xb4>
    80002770:	09c4a703          	lw	a4,156(s1)
    80002774:	0984a783          	lw	a5,152(s1)
    80002778:	0007071b          	sext.w	a4,a4
    8000277c:	08e78463          	beq	a5,a4,80002804 <consoleread+0xf0>
    80002780:	07f7f713          	andi	a4,a5,127
    80002784:	00e48733          	add	a4,s1,a4
    80002788:	01874703          	lbu	a4,24(a4) # c201018 <_entry-0x73dfefe8>
    8000278c:	0017869b          	addiw	a3,a5,1
    80002790:	08d4ac23          	sw	a3,152(s1)
    80002794:	00070c9b          	sext.w	s9,a4
    80002798:	0b370663          	beq	a4,s3,80002844 <consoleread+0x130>
    8000279c:	00100693          	li	a3,1
    800027a0:	f9f40613          	addi	a2,s0,-97
    800027a4:	000c0593          	mv	a1,s8
    800027a8:	00090513          	mv	a0,s2
    800027ac:	f8e40fa3          	sb	a4,-97(s0)
    800027b0:	00000097          	auipc	ra,0x0
    800027b4:	8bc080e7          	jalr	-1860(ra) # 8000206c <either_copyout>
    800027b8:	01450863          	beq	a0,s4,800027c8 <consoleread+0xb4>
    800027bc:	001c0c13          	addi	s8,s8,1
    800027c0:	fffb8b9b          	addiw	s7,s7,-1
    800027c4:	fb5c94e3          	bne	s9,s5,8000276c <consoleread+0x58>
    800027c8:	000b851b          	sext.w	a0,s7
    800027cc:	06813083          	ld	ra,104(sp)
    800027d0:	06013403          	ld	s0,96(sp)
    800027d4:	05813483          	ld	s1,88(sp)
    800027d8:	05013903          	ld	s2,80(sp)
    800027dc:	04813983          	ld	s3,72(sp)
    800027e0:	04013a03          	ld	s4,64(sp)
    800027e4:	03813a83          	ld	s5,56(sp)
    800027e8:	02813b83          	ld	s7,40(sp)
    800027ec:	02013c03          	ld	s8,32(sp)
    800027f0:	01813c83          	ld	s9,24(sp)
    800027f4:	40ab053b          	subw	a0,s6,a0
    800027f8:	03013b03          	ld	s6,48(sp)
    800027fc:	07010113          	addi	sp,sp,112
    80002800:	00008067          	ret
    80002804:	00001097          	auipc	ra,0x1
    80002808:	1d8080e7          	jalr	472(ra) # 800039dc <push_on>
    8000280c:	0984a703          	lw	a4,152(s1)
    80002810:	09c4a783          	lw	a5,156(s1)
    80002814:	0007879b          	sext.w	a5,a5
    80002818:	fef70ce3          	beq	a4,a5,80002810 <consoleread+0xfc>
    8000281c:	00001097          	auipc	ra,0x1
    80002820:	234080e7          	jalr	564(ra) # 80003a50 <pop_on>
    80002824:	0984a783          	lw	a5,152(s1)
    80002828:	07f7f713          	andi	a4,a5,127
    8000282c:	00e48733          	add	a4,s1,a4
    80002830:	01874703          	lbu	a4,24(a4)
    80002834:	0017869b          	addiw	a3,a5,1
    80002838:	08d4ac23          	sw	a3,152(s1)
    8000283c:	00070c9b          	sext.w	s9,a4
    80002840:	f5371ee3          	bne	a4,s3,8000279c <consoleread+0x88>
    80002844:	000b851b          	sext.w	a0,s7
    80002848:	f96bf2e3          	bgeu	s7,s6,800027cc <consoleread+0xb8>
    8000284c:	08f4ac23          	sw	a5,152(s1)
    80002850:	f7dff06f          	j	800027cc <consoleread+0xb8>

0000000080002854 <consputc>:
    80002854:	10000793          	li	a5,256
    80002858:	00f50663          	beq	a0,a5,80002864 <consputc+0x10>
    8000285c:	00001317          	auipc	t1,0x1
    80002860:	9f430067          	jr	-1548(t1) # 80003250 <uartputc_sync>
    80002864:	ff010113          	addi	sp,sp,-16
    80002868:	00113423          	sd	ra,8(sp)
    8000286c:	00813023          	sd	s0,0(sp)
    80002870:	01010413          	addi	s0,sp,16
    80002874:	00800513          	li	a0,8
    80002878:	00001097          	auipc	ra,0x1
    8000287c:	9d8080e7          	jalr	-1576(ra) # 80003250 <uartputc_sync>
    80002880:	02000513          	li	a0,32
    80002884:	00001097          	auipc	ra,0x1
    80002888:	9cc080e7          	jalr	-1588(ra) # 80003250 <uartputc_sync>
    8000288c:	00013403          	ld	s0,0(sp)
    80002890:	00813083          	ld	ra,8(sp)
    80002894:	00800513          	li	a0,8
    80002898:	01010113          	addi	sp,sp,16
    8000289c:	00001317          	auipc	t1,0x1
    800028a0:	9b430067          	jr	-1612(t1) # 80003250 <uartputc_sync>

00000000800028a4 <consoleintr>:
    800028a4:	fe010113          	addi	sp,sp,-32
    800028a8:	00813823          	sd	s0,16(sp)
    800028ac:	00913423          	sd	s1,8(sp)
    800028b0:	01213023          	sd	s2,0(sp)
    800028b4:	00113c23          	sd	ra,24(sp)
    800028b8:	02010413          	addi	s0,sp,32
    800028bc:	00003917          	auipc	s2,0x3
    800028c0:	06c90913          	addi	s2,s2,108 # 80005928 <cons>
    800028c4:	00050493          	mv	s1,a0
    800028c8:	00090513          	mv	a0,s2
    800028cc:	00001097          	auipc	ra,0x1
    800028d0:	e40080e7          	jalr	-448(ra) # 8000370c <acquire>
    800028d4:	02048c63          	beqz	s1,8000290c <consoleintr+0x68>
    800028d8:	0a092783          	lw	a5,160(s2)
    800028dc:	09892703          	lw	a4,152(s2)
    800028e0:	07f00693          	li	a3,127
    800028e4:	40e7873b          	subw	a4,a5,a4
    800028e8:	02e6e263          	bltu	a3,a4,8000290c <consoleintr+0x68>
    800028ec:	00d00713          	li	a4,13
    800028f0:	04e48063          	beq	s1,a4,80002930 <consoleintr+0x8c>
    800028f4:	07f7f713          	andi	a4,a5,127
    800028f8:	00e90733          	add	a4,s2,a4
    800028fc:	0017879b          	addiw	a5,a5,1
    80002900:	0af92023          	sw	a5,160(s2)
    80002904:	00970c23          	sb	s1,24(a4)
    80002908:	08f92e23          	sw	a5,156(s2)
    8000290c:	01013403          	ld	s0,16(sp)
    80002910:	01813083          	ld	ra,24(sp)
    80002914:	00813483          	ld	s1,8(sp)
    80002918:	00013903          	ld	s2,0(sp)
    8000291c:	00003517          	auipc	a0,0x3
    80002920:	00c50513          	addi	a0,a0,12 # 80005928 <cons>
    80002924:	02010113          	addi	sp,sp,32
    80002928:	00001317          	auipc	t1,0x1
    8000292c:	eb030067          	jr	-336(t1) # 800037d8 <release>
    80002930:	00a00493          	li	s1,10
    80002934:	fc1ff06f          	j	800028f4 <consoleintr+0x50>

0000000080002938 <consoleinit>:
    80002938:	fe010113          	addi	sp,sp,-32
    8000293c:	00113c23          	sd	ra,24(sp)
    80002940:	00813823          	sd	s0,16(sp)
    80002944:	00913423          	sd	s1,8(sp)
    80002948:	02010413          	addi	s0,sp,32
    8000294c:	00003497          	auipc	s1,0x3
    80002950:	fdc48493          	addi	s1,s1,-36 # 80005928 <cons>
    80002954:	00048513          	mv	a0,s1
    80002958:	00002597          	auipc	a1,0x2
    8000295c:	93058593          	addi	a1,a1,-1744 # 80004288 <CONSOLE_STATUS+0x278>
    80002960:	00001097          	auipc	ra,0x1
    80002964:	d88080e7          	jalr	-632(ra) # 800036e8 <initlock>
    80002968:	00000097          	auipc	ra,0x0
    8000296c:	7ac080e7          	jalr	1964(ra) # 80003114 <uartinit>
    80002970:	01813083          	ld	ra,24(sp)
    80002974:	01013403          	ld	s0,16(sp)
    80002978:	00000797          	auipc	a5,0x0
    8000297c:	d9c78793          	addi	a5,a5,-612 # 80002714 <consoleread>
    80002980:	0af4bc23          	sd	a5,184(s1)
    80002984:	00000797          	auipc	a5,0x0
    80002988:	cec78793          	addi	a5,a5,-788 # 80002670 <consolewrite>
    8000298c:	0cf4b023          	sd	a5,192(s1)
    80002990:	00813483          	ld	s1,8(sp)
    80002994:	02010113          	addi	sp,sp,32
    80002998:	00008067          	ret

000000008000299c <console_read>:
    8000299c:	ff010113          	addi	sp,sp,-16
    800029a0:	00813423          	sd	s0,8(sp)
    800029a4:	01010413          	addi	s0,sp,16
    800029a8:	00813403          	ld	s0,8(sp)
    800029ac:	00003317          	auipc	t1,0x3
    800029b0:	03433303          	ld	t1,52(t1) # 800059e0 <devsw+0x10>
    800029b4:	01010113          	addi	sp,sp,16
    800029b8:	00030067          	jr	t1

00000000800029bc <console_write>:
    800029bc:	ff010113          	addi	sp,sp,-16
    800029c0:	00813423          	sd	s0,8(sp)
    800029c4:	01010413          	addi	s0,sp,16
    800029c8:	00813403          	ld	s0,8(sp)
    800029cc:	00003317          	auipc	t1,0x3
    800029d0:	01c33303          	ld	t1,28(t1) # 800059e8 <devsw+0x18>
    800029d4:	01010113          	addi	sp,sp,16
    800029d8:	00030067          	jr	t1

00000000800029dc <panic>:
    800029dc:	fe010113          	addi	sp,sp,-32
    800029e0:	00113c23          	sd	ra,24(sp)
    800029e4:	00813823          	sd	s0,16(sp)
    800029e8:	00913423          	sd	s1,8(sp)
    800029ec:	02010413          	addi	s0,sp,32
    800029f0:	00050493          	mv	s1,a0
    800029f4:	00002517          	auipc	a0,0x2
    800029f8:	89c50513          	addi	a0,a0,-1892 # 80004290 <CONSOLE_STATUS+0x280>
    800029fc:	00003797          	auipc	a5,0x3
    80002a00:	0807a623          	sw	zero,140(a5) # 80005a88 <pr+0x18>
    80002a04:	00000097          	auipc	ra,0x0
    80002a08:	034080e7          	jalr	52(ra) # 80002a38 <__printf>
    80002a0c:	00048513          	mv	a0,s1
    80002a10:	00000097          	auipc	ra,0x0
    80002a14:	028080e7          	jalr	40(ra) # 80002a38 <__printf>
    80002a18:	00002517          	auipc	a0,0x2
    80002a1c:	85850513          	addi	a0,a0,-1960 # 80004270 <CONSOLE_STATUS+0x260>
    80002a20:	00000097          	auipc	ra,0x0
    80002a24:	018080e7          	jalr	24(ra) # 80002a38 <__printf>
    80002a28:	00100793          	li	a5,1
    80002a2c:	00002717          	auipc	a4,0x2
    80002a30:	e0f72623          	sw	a5,-500(a4) # 80004838 <panicked>
    80002a34:	0000006f          	j	80002a34 <panic+0x58>

0000000080002a38 <__printf>:
    80002a38:	f3010113          	addi	sp,sp,-208
    80002a3c:	08813023          	sd	s0,128(sp)
    80002a40:	07313423          	sd	s3,104(sp)
    80002a44:	09010413          	addi	s0,sp,144
    80002a48:	05813023          	sd	s8,64(sp)
    80002a4c:	08113423          	sd	ra,136(sp)
    80002a50:	06913c23          	sd	s1,120(sp)
    80002a54:	07213823          	sd	s2,112(sp)
    80002a58:	07413023          	sd	s4,96(sp)
    80002a5c:	05513c23          	sd	s5,88(sp)
    80002a60:	05613823          	sd	s6,80(sp)
    80002a64:	05713423          	sd	s7,72(sp)
    80002a68:	03913c23          	sd	s9,56(sp)
    80002a6c:	03a13823          	sd	s10,48(sp)
    80002a70:	03b13423          	sd	s11,40(sp)
    80002a74:	00003317          	auipc	t1,0x3
    80002a78:	ffc30313          	addi	t1,t1,-4 # 80005a70 <pr>
    80002a7c:	01832c03          	lw	s8,24(t1)
    80002a80:	00b43423          	sd	a1,8(s0)
    80002a84:	00c43823          	sd	a2,16(s0)
    80002a88:	00d43c23          	sd	a3,24(s0)
    80002a8c:	02e43023          	sd	a4,32(s0)
    80002a90:	02f43423          	sd	a5,40(s0)
    80002a94:	03043823          	sd	a6,48(s0)
    80002a98:	03143c23          	sd	a7,56(s0)
    80002a9c:	00050993          	mv	s3,a0
    80002aa0:	4a0c1663          	bnez	s8,80002f4c <__printf+0x514>
    80002aa4:	60098c63          	beqz	s3,800030bc <__printf+0x684>
    80002aa8:	0009c503          	lbu	a0,0(s3)
    80002aac:	00840793          	addi	a5,s0,8
    80002ab0:	f6f43c23          	sd	a5,-136(s0)
    80002ab4:	00000493          	li	s1,0
    80002ab8:	22050063          	beqz	a0,80002cd8 <__printf+0x2a0>
    80002abc:	00002a37          	lui	s4,0x2
    80002ac0:	00018ab7          	lui	s5,0x18
    80002ac4:	000f4b37          	lui	s6,0xf4
    80002ac8:	00989bb7          	lui	s7,0x989
    80002acc:	70fa0a13          	addi	s4,s4,1807 # 270f <_entry-0x7fffd8f1>
    80002ad0:	69fa8a93          	addi	s5,s5,1695 # 1869f <_entry-0x7ffe7961>
    80002ad4:	23fb0b13          	addi	s6,s6,575 # f423f <_entry-0x7ff0bdc1>
    80002ad8:	67fb8b93          	addi	s7,s7,1663 # 98967f <_entry-0x7f676981>
    80002adc:	00148c9b          	addiw	s9,s1,1
    80002ae0:	02500793          	li	a5,37
    80002ae4:	01998933          	add	s2,s3,s9
    80002ae8:	38f51263          	bne	a0,a5,80002e6c <__printf+0x434>
    80002aec:	00094783          	lbu	a5,0(s2)
    80002af0:	00078c9b          	sext.w	s9,a5
    80002af4:	1e078263          	beqz	a5,80002cd8 <__printf+0x2a0>
    80002af8:	0024849b          	addiw	s1,s1,2
    80002afc:	07000713          	li	a4,112
    80002b00:	00998933          	add	s2,s3,s1
    80002b04:	38e78a63          	beq	a5,a4,80002e98 <__printf+0x460>
    80002b08:	20f76863          	bltu	a4,a5,80002d18 <__printf+0x2e0>
    80002b0c:	42a78863          	beq	a5,a0,80002f3c <__printf+0x504>
    80002b10:	06400713          	li	a4,100
    80002b14:	40e79663          	bne	a5,a4,80002f20 <__printf+0x4e8>
    80002b18:	f7843783          	ld	a5,-136(s0)
    80002b1c:	0007a603          	lw	a2,0(a5)
    80002b20:	00878793          	addi	a5,a5,8
    80002b24:	f6f43c23          	sd	a5,-136(s0)
    80002b28:	42064a63          	bltz	a2,80002f5c <__printf+0x524>
    80002b2c:	00a00713          	li	a4,10
    80002b30:	02e677bb          	remuw	a5,a2,a4
    80002b34:	00001d97          	auipc	s11,0x1
    80002b38:	784d8d93          	addi	s11,s11,1924 # 800042b8 <digits>
    80002b3c:	00900593          	li	a1,9
    80002b40:	0006051b          	sext.w	a0,a2
    80002b44:	00000c93          	li	s9,0
    80002b48:	02079793          	slli	a5,a5,0x20
    80002b4c:	0207d793          	srli	a5,a5,0x20
    80002b50:	00fd87b3          	add	a5,s11,a5
    80002b54:	0007c783          	lbu	a5,0(a5)
    80002b58:	02e656bb          	divuw	a3,a2,a4
    80002b5c:	f8f40023          	sb	a5,-128(s0)
    80002b60:	14c5d863          	bge	a1,a2,80002cb0 <__printf+0x278>
    80002b64:	06300593          	li	a1,99
    80002b68:	00100c93          	li	s9,1
    80002b6c:	02e6f7bb          	remuw	a5,a3,a4
    80002b70:	02079793          	slli	a5,a5,0x20
    80002b74:	0207d793          	srli	a5,a5,0x20
    80002b78:	00fd87b3          	add	a5,s11,a5
    80002b7c:	0007c783          	lbu	a5,0(a5)
    80002b80:	02e6d73b          	divuw	a4,a3,a4
    80002b84:	f8f400a3          	sb	a5,-127(s0)
    80002b88:	12a5f463          	bgeu	a1,a0,80002cb0 <__printf+0x278>
    80002b8c:	00a00693          	li	a3,10
    80002b90:	00900593          	li	a1,9
    80002b94:	02d777bb          	remuw	a5,a4,a3
    80002b98:	02079793          	slli	a5,a5,0x20
    80002b9c:	0207d793          	srli	a5,a5,0x20
    80002ba0:	00fd87b3          	add	a5,s11,a5
    80002ba4:	0007c503          	lbu	a0,0(a5)
    80002ba8:	02d757bb          	divuw	a5,a4,a3
    80002bac:	f8a40123          	sb	a0,-126(s0)
    80002bb0:	48e5f263          	bgeu	a1,a4,80003034 <__printf+0x5fc>
    80002bb4:	06300513          	li	a0,99
    80002bb8:	02d7f5bb          	remuw	a1,a5,a3
    80002bbc:	02059593          	slli	a1,a1,0x20
    80002bc0:	0205d593          	srli	a1,a1,0x20
    80002bc4:	00bd85b3          	add	a1,s11,a1
    80002bc8:	0005c583          	lbu	a1,0(a1)
    80002bcc:	02d7d7bb          	divuw	a5,a5,a3
    80002bd0:	f8b401a3          	sb	a1,-125(s0)
    80002bd4:	48e57263          	bgeu	a0,a4,80003058 <__printf+0x620>
    80002bd8:	3e700513          	li	a0,999
    80002bdc:	02d7f5bb          	remuw	a1,a5,a3
    80002be0:	02059593          	slli	a1,a1,0x20
    80002be4:	0205d593          	srli	a1,a1,0x20
    80002be8:	00bd85b3          	add	a1,s11,a1
    80002bec:	0005c583          	lbu	a1,0(a1)
    80002bf0:	02d7d7bb          	divuw	a5,a5,a3
    80002bf4:	f8b40223          	sb	a1,-124(s0)
    80002bf8:	46e57663          	bgeu	a0,a4,80003064 <__printf+0x62c>
    80002bfc:	02d7f5bb          	remuw	a1,a5,a3
    80002c00:	02059593          	slli	a1,a1,0x20
    80002c04:	0205d593          	srli	a1,a1,0x20
    80002c08:	00bd85b3          	add	a1,s11,a1
    80002c0c:	0005c583          	lbu	a1,0(a1)
    80002c10:	02d7d7bb          	divuw	a5,a5,a3
    80002c14:	f8b402a3          	sb	a1,-123(s0)
    80002c18:	46ea7863          	bgeu	s4,a4,80003088 <__printf+0x650>
    80002c1c:	02d7f5bb          	remuw	a1,a5,a3
    80002c20:	02059593          	slli	a1,a1,0x20
    80002c24:	0205d593          	srli	a1,a1,0x20
    80002c28:	00bd85b3          	add	a1,s11,a1
    80002c2c:	0005c583          	lbu	a1,0(a1)
    80002c30:	02d7d7bb          	divuw	a5,a5,a3
    80002c34:	f8b40323          	sb	a1,-122(s0)
    80002c38:	3eeaf863          	bgeu	s5,a4,80003028 <__printf+0x5f0>
    80002c3c:	02d7f5bb          	remuw	a1,a5,a3
    80002c40:	02059593          	slli	a1,a1,0x20
    80002c44:	0205d593          	srli	a1,a1,0x20
    80002c48:	00bd85b3          	add	a1,s11,a1
    80002c4c:	0005c583          	lbu	a1,0(a1)
    80002c50:	02d7d7bb          	divuw	a5,a5,a3
    80002c54:	f8b403a3          	sb	a1,-121(s0)
    80002c58:	42eb7e63          	bgeu	s6,a4,80003094 <__printf+0x65c>
    80002c5c:	02d7f5bb          	remuw	a1,a5,a3
    80002c60:	02059593          	slli	a1,a1,0x20
    80002c64:	0205d593          	srli	a1,a1,0x20
    80002c68:	00bd85b3          	add	a1,s11,a1
    80002c6c:	0005c583          	lbu	a1,0(a1)
    80002c70:	02d7d7bb          	divuw	a5,a5,a3
    80002c74:	f8b40423          	sb	a1,-120(s0)
    80002c78:	42ebfc63          	bgeu	s7,a4,800030b0 <__printf+0x678>
    80002c7c:	02079793          	slli	a5,a5,0x20
    80002c80:	0207d793          	srli	a5,a5,0x20
    80002c84:	00fd8db3          	add	s11,s11,a5
    80002c88:	000dc703          	lbu	a4,0(s11)
    80002c8c:	00a00793          	li	a5,10
    80002c90:	00900c93          	li	s9,9
    80002c94:	f8e404a3          	sb	a4,-119(s0)
    80002c98:	00065c63          	bgez	a2,80002cb0 <__printf+0x278>
    80002c9c:	f9040713          	addi	a4,s0,-112
    80002ca0:	00f70733          	add	a4,a4,a5
    80002ca4:	02d00693          	li	a3,45
    80002ca8:	fed70823          	sb	a3,-16(a4)
    80002cac:	00078c93          	mv	s9,a5
    80002cb0:	f8040793          	addi	a5,s0,-128
    80002cb4:	01978cb3          	add	s9,a5,s9
    80002cb8:	f7f40d13          	addi	s10,s0,-129
    80002cbc:	000cc503          	lbu	a0,0(s9)
    80002cc0:	fffc8c93          	addi	s9,s9,-1
    80002cc4:	00000097          	auipc	ra,0x0
    80002cc8:	b90080e7          	jalr	-1136(ra) # 80002854 <consputc>
    80002ccc:	ffac98e3          	bne	s9,s10,80002cbc <__printf+0x284>
    80002cd0:	00094503          	lbu	a0,0(s2)
    80002cd4:	e00514e3          	bnez	a0,80002adc <__printf+0xa4>
    80002cd8:	1a0c1663          	bnez	s8,80002e84 <__printf+0x44c>
    80002cdc:	08813083          	ld	ra,136(sp)
    80002ce0:	08013403          	ld	s0,128(sp)
    80002ce4:	07813483          	ld	s1,120(sp)
    80002ce8:	07013903          	ld	s2,112(sp)
    80002cec:	06813983          	ld	s3,104(sp)
    80002cf0:	06013a03          	ld	s4,96(sp)
    80002cf4:	05813a83          	ld	s5,88(sp)
    80002cf8:	05013b03          	ld	s6,80(sp)
    80002cfc:	04813b83          	ld	s7,72(sp)
    80002d00:	04013c03          	ld	s8,64(sp)
    80002d04:	03813c83          	ld	s9,56(sp)
    80002d08:	03013d03          	ld	s10,48(sp)
    80002d0c:	02813d83          	ld	s11,40(sp)
    80002d10:	0d010113          	addi	sp,sp,208
    80002d14:	00008067          	ret
    80002d18:	07300713          	li	a4,115
    80002d1c:	1ce78a63          	beq	a5,a4,80002ef0 <__printf+0x4b8>
    80002d20:	07800713          	li	a4,120
    80002d24:	1ee79e63          	bne	a5,a4,80002f20 <__printf+0x4e8>
    80002d28:	f7843783          	ld	a5,-136(s0)
    80002d2c:	0007a703          	lw	a4,0(a5)
    80002d30:	00878793          	addi	a5,a5,8
    80002d34:	f6f43c23          	sd	a5,-136(s0)
    80002d38:	28074263          	bltz	a4,80002fbc <__printf+0x584>
    80002d3c:	00001d97          	auipc	s11,0x1
    80002d40:	57cd8d93          	addi	s11,s11,1404 # 800042b8 <digits>
    80002d44:	00f77793          	andi	a5,a4,15
    80002d48:	00fd87b3          	add	a5,s11,a5
    80002d4c:	0007c683          	lbu	a3,0(a5)
    80002d50:	00f00613          	li	a2,15
    80002d54:	0007079b          	sext.w	a5,a4
    80002d58:	f8d40023          	sb	a3,-128(s0)
    80002d5c:	0047559b          	srliw	a1,a4,0x4
    80002d60:	0047569b          	srliw	a3,a4,0x4
    80002d64:	00000c93          	li	s9,0
    80002d68:	0ee65063          	bge	a2,a4,80002e48 <__printf+0x410>
    80002d6c:	00f6f693          	andi	a3,a3,15
    80002d70:	00dd86b3          	add	a3,s11,a3
    80002d74:	0006c683          	lbu	a3,0(a3) # 2004000 <_entry-0x7dffc000>
    80002d78:	0087d79b          	srliw	a5,a5,0x8
    80002d7c:	00100c93          	li	s9,1
    80002d80:	f8d400a3          	sb	a3,-127(s0)
    80002d84:	0cb67263          	bgeu	a2,a1,80002e48 <__printf+0x410>
    80002d88:	00f7f693          	andi	a3,a5,15
    80002d8c:	00dd86b3          	add	a3,s11,a3
    80002d90:	0006c583          	lbu	a1,0(a3)
    80002d94:	00f00613          	li	a2,15
    80002d98:	0047d69b          	srliw	a3,a5,0x4
    80002d9c:	f8b40123          	sb	a1,-126(s0)
    80002da0:	0047d593          	srli	a1,a5,0x4
    80002da4:	28f67e63          	bgeu	a2,a5,80003040 <__printf+0x608>
    80002da8:	00f6f693          	andi	a3,a3,15
    80002dac:	00dd86b3          	add	a3,s11,a3
    80002db0:	0006c503          	lbu	a0,0(a3)
    80002db4:	0087d813          	srli	a6,a5,0x8
    80002db8:	0087d69b          	srliw	a3,a5,0x8
    80002dbc:	f8a401a3          	sb	a0,-125(s0)
    80002dc0:	28b67663          	bgeu	a2,a1,8000304c <__printf+0x614>
    80002dc4:	00f6f693          	andi	a3,a3,15
    80002dc8:	00dd86b3          	add	a3,s11,a3
    80002dcc:	0006c583          	lbu	a1,0(a3)
    80002dd0:	00c7d513          	srli	a0,a5,0xc
    80002dd4:	00c7d69b          	srliw	a3,a5,0xc
    80002dd8:	f8b40223          	sb	a1,-124(s0)
    80002ddc:	29067a63          	bgeu	a2,a6,80003070 <__printf+0x638>
    80002de0:	00f6f693          	andi	a3,a3,15
    80002de4:	00dd86b3          	add	a3,s11,a3
    80002de8:	0006c583          	lbu	a1,0(a3)
    80002dec:	0107d813          	srli	a6,a5,0x10
    80002df0:	0107d69b          	srliw	a3,a5,0x10
    80002df4:	f8b402a3          	sb	a1,-123(s0)
    80002df8:	28a67263          	bgeu	a2,a0,8000307c <__printf+0x644>
    80002dfc:	00f6f693          	andi	a3,a3,15
    80002e00:	00dd86b3          	add	a3,s11,a3
    80002e04:	0006c683          	lbu	a3,0(a3)
    80002e08:	0147d79b          	srliw	a5,a5,0x14
    80002e0c:	f8d40323          	sb	a3,-122(s0)
    80002e10:	21067663          	bgeu	a2,a6,8000301c <__printf+0x5e4>
    80002e14:	02079793          	slli	a5,a5,0x20
    80002e18:	0207d793          	srli	a5,a5,0x20
    80002e1c:	00fd8db3          	add	s11,s11,a5
    80002e20:	000dc683          	lbu	a3,0(s11)
    80002e24:	00800793          	li	a5,8
    80002e28:	00700c93          	li	s9,7
    80002e2c:	f8d403a3          	sb	a3,-121(s0)
    80002e30:	00075c63          	bgez	a4,80002e48 <__printf+0x410>
    80002e34:	f9040713          	addi	a4,s0,-112
    80002e38:	00f70733          	add	a4,a4,a5
    80002e3c:	02d00693          	li	a3,45
    80002e40:	fed70823          	sb	a3,-16(a4)
    80002e44:	00078c93          	mv	s9,a5
    80002e48:	f8040793          	addi	a5,s0,-128
    80002e4c:	01978cb3          	add	s9,a5,s9
    80002e50:	f7f40d13          	addi	s10,s0,-129
    80002e54:	000cc503          	lbu	a0,0(s9)
    80002e58:	fffc8c93          	addi	s9,s9,-1
    80002e5c:	00000097          	auipc	ra,0x0
    80002e60:	9f8080e7          	jalr	-1544(ra) # 80002854 <consputc>
    80002e64:	ff9d18e3          	bne	s10,s9,80002e54 <__printf+0x41c>
    80002e68:	0100006f          	j	80002e78 <__printf+0x440>
    80002e6c:	00000097          	auipc	ra,0x0
    80002e70:	9e8080e7          	jalr	-1560(ra) # 80002854 <consputc>
    80002e74:	000c8493          	mv	s1,s9
    80002e78:	00094503          	lbu	a0,0(s2)
    80002e7c:	c60510e3          	bnez	a0,80002adc <__printf+0xa4>
    80002e80:	e40c0ee3          	beqz	s8,80002cdc <__printf+0x2a4>
    80002e84:	00003517          	auipc	a0,0x3
    80002e88:	bec50513          	addi	a0,a0,-1044 # 80005a70 <pr>
    80002e8c:	00001097          	auipc	ra,0x1
    80002e90:	94c080e7          	jalr	-1716(ra) # 800037d8 <release>
    80002e94:	e49ff06f          	j	80002cdc <__printf+0x2a4>
    80002e98:	f7843783          	ld	a5,-136(s0)
    80002e9c:	03000513          	li	a0,48
    80002ea0:	01000d13          	li	s10,16
    80002ea4:	00878713          	addi	a4,a5,8
    80002ea8:	0007bc83          	ld	s9,0(a5)
    80002eac:	f6e43c23          	sd	a4,-136(s0)
    80002eb0:	00000097          	auipc	ra,0x0
    80002eb4:	9a4080e7          	jalr	-1628(ra) # 80002854 <consputc>
    80002eb8:	07800513          	li	a0,120
    80002ebc:	00000097          	auipc	ra,0x0
    80002ec0:	998080e7          	jalr	-1640(ra) # 80002854 <consputc>
    80002ec4:	00001d97          	auipc	s11,0x1
    80002ec8:	3f4d8d93          	addi	s11,s11,1012 # 800042b8 <digits>
    80002ecc:	03ccd793          	srli	a5,s9,0x3c
    80002ed0:	00fd87b3          	add	a5,s11,a5
    80002ed4:	0007c503          	lbu	a0,0(a5)
    80002ed8:	fffd0d1b          	addiw	s10,s10,-1
    80002edc:	004c9c93          	slli	s9,s9,0x4
    80002ee0:	00000097          	auipc	ra,0x0
    80002ee4:	974080e7          	jalr	-1676(ra) # 80002854 <consputc>
    80002ee8:	fe0d12e3          	bnez	s10,80002ecc <__printf+0x494>
    80002eec:	f8dff06f          	j	80002e78 <__printf+0x440>
    80002ef0:	f7843783          	ld	a5,-136(s0)
    80002ef4:	0007bc83          	ld	s9,0(a5)
    80002ef8:	00878793          	addi	a5,a5,8
    80002efc:	f6f43c23          	sd	a5,-136(s0)
    80002f00:	000c9a63          	bnez	s9,80002f14 <__printf+0x4dc>
    80002f04:	1080006f          	j	8000300c <__printf+0x5d4>
    80002f08:	001c8c93          	addi	s9,s9,1
    80002f0c:	00000097          	auipc	ra,0x0
    80002f10:	948080e7          	jalr	-1720(ra) # 80002854 <consputc>
    80002f14:	000cc503          	lbu	a0,0(s9)
    80002f18:	fe0518e3          	bnez	a0,80002f08 <__printf+0x4d0>
    80002f1c:	f5dff06f          	j	80002e78 <__printf+0x440>
    80002f20:	02500513          	li	a0,37
    80002f24:	00000097          	auipc	ra,0x0
    80002f28:	930080e7          	jalr	-1744(ra) # 80002854 <consputc>
    80002f2c:	000c8513          	mv	a0,s9
    80002f30:	00000097          	auipc	ra,0x0
    80002f34:	924080e7          	jalr	-1756(ra) # 80002854 <consputc>
    80002f38:	f41ff06f          	j	80002e78 <__printf+0x440>
    80002f3c:	02500513          	li	a0,37
    80002f40:	00000097          	auipc	ra,0x0
    80002f44:	914080e7          	jalr	-1772(ra) # 80002854 <consputc>
    80002f48:	f31ff06f          	j	80002e78 <__printf+0x440>
    80002f4c:	00030513          	mv	a0,t1
    80002f50:	00000097          	auipc	ra,0x0
    80002f54:	7bc080e7          	jalr	1980(ra) # 8000370c <acquire>
    80002f58:	b4dff06f          	j	80002aa4 <__printf+0x6c>
    80002f5c:	40c0053b          	negw	a0,a2
    80002f60:	00a00713          	li	a4,10
    80002f64:	02e576bb          	remuw	a3,a0,a4
    80002f68:	00001d97          	auipc	s11,0x1
    80002f6c:	350d8d93          	addi	s11,s11,848 # 800042b8 <digits>
    80002f70:	ff700593          	li	a1,-9
    80002f74:	02069693          	slli	a3,a3,0x20
    80002f78:	0206d693          	srli	a3,a3,0x20
    80002f7c:	00dd86b3          	add	a3,s11,a3
    80002f80:	0006c683          	lbu	a3,0(a3)
    80002f84:	02e557bb          	divuw	a5,a0,a4
    80002f88:	f8d40023          	sb	a3,-128(s0)
    80002f8c:	10b65e63          	bge	a2,a1,800030a8 <__printf+0x670>
    80002f90:	06300593          	li	a1,99
    80002f94:	02e7f6bb          	remuw	a3,a5,a4
    80002f98:	02069693          	slli	a3,a3,0x20
    80002f9c:	0206d693          	srli	a3,a3,0x20
    80002fa0:	00dd86b3          	add	a3,s11,a3
    80002fa4:	0006c683          	lbu	a3,0(a3)
    80002fa8:	02e7d73b          	divuw	a4,a5,a4
    80002fac:	00200793          	li	a5,2
    80002fb0:	f8d400a3          	sb	a3,-127(s0)
    80002fb4:	bca5ece3          	bltu	a1,a0,80002b8c <__printf+0x154>
    80002fb8:	ce5ff06f          	j	80002c9c <__printf+0x264>
    80002fbc:	40e007bb          	negw	a5,a4
    80002fc0:	00001d97          	auipc	s11,0x1
    80002fc4:	2f8d8d93          	addi	s11,s11,760 # 800042b8 <digits>
    80002fc8:	00f7f693          	andi	a3,a5,15
    80002fcc:	00dd86b3          	add	a3,s11,a3
    80002fd0:	0006c583          	lbu	a1,0(a3)
    80002fd4:	ff100613          	li	a2,-15
    80002fd8:	0047d69b          	srliw	a3,a5,0x4
    80002fdc:	f8b40023          	sb	a1,-128(s0)
    80002fe0:	0047d59b          	srliw	a1,a5,0x4
    80002fe4:	0ac75e63          	bge	a4,a2,800030a0 <__printf+0x668>
    80002fe8:	00f6f693          	andi	a3,a3,15
    80002fec:	00dd86b3          	add	a3,s11,a3
    80002ff0:	0006c603          	lbu	a2,0(a3)
    80002ff4:	00f00693          	li	a3,15
    80002ff8:	0087d79b          	srliw	a5,a5,0x8
    80002ffc:	f8c400a3          	sb	a2,-127(s0)
    80003000:	d8b6e4e3          	bltu	a3,a1,80002d88 <__printf+0x350>
    80003004:	00200793          	li	a5,2
    80003008:	e2dff06f          	j	80002e34 <__printf+0x3fc>
    8000300c:	00001c97          	auipc	s9,0x1
    80003010:	28cc8c93          	addi	s9,s9,652 # 80004298 <CONSOLE_STATUS+0x288>
    80003014:	02800513          	li	a0,40
    80003018:	ef1ff06f          	j	80002f08 <__printf+0x4d0>
    8000301c:	00700793          	li	a5,7
    80003020:	00600c93          	li	s9,6
    80003024:	e0dff06f          	j	80002e30 <__printf+0x3f8>
    80003028:	00700793          	li	a5,7
    8000302c:	00600c93          	li	s9,6
    80003030:	c69ff06f          	j	80002c98 <__printf+0x260>
    80003034:	00300793          	li	a5,3
    80003038:	00200c93          	li	s9,2
    8000303c:	c5dff06f          	j	80002c98 <__printf+0x260>
    80003040:	00300793          	li	a5,3
    80003044:	00200c93          	li	s9,2
    80003048:	de9ff06f          	j	80002e30 <__printf+0x3f8>
    8000304c:	00400793          	li	a5,4
    80003050:	00300c93          	li	s9,3
    80003054:	dddff06f          	j	80002e30 <__printf+0x3f8>
    80003058:	00400793          	li	a5,4
    8000305c:	00300c93          	li	s9,3
    80003060:	c39ff06f          	j	80002c98 <__printf+0x260>
    80003064:	00500793          	li	a5,5
    80003068:	00400c93          	li	s9,4
    8000306c:	c2dff06f          	j	80002c98 <__printf+0x260>
    80003070:	00500793          	li	a5,5
    80003074:	00400c93          	li	s9,4
    80003078:	db9ff06f          	j	80002e30 <__printf+0x3f8>
    8000307c:	00600793          	li	a5,6
    80003080:	00500c93          	li	s9,5
    80003084:	dadff06f          	j	80002e30 <__printf+0x3f8>
    80003088:	00600793          	li	a5,6
    8000308c:	00500c93          	li	s9,5
    80003090:	c09ff06f          	j	80002c98 <__printf+0x260>
    80003094:	00800793          	li	a5,8
    80003098:	00700c93          	li	s9,7
    8000309c:	bfdff06f          	j	80002c98 <__printf+0x260>
    800030a0:	00100793          	li	a5,1
    800030a4:	d91ff06f          	j	80002e34 <__printf+0x3fc>
    800030a8:	00100793          	li	a5,1
    800030ac:	bf1ff06f          	j	80002c9c <__printf+0x264>
    800030b0:	00900793          	li	a5,9
    800030b4:	00800c93          	li	s9,8
    800030b8:	be1ff06f          	j	80002c98 <__printf+0x260>
    800030bc:	00001517          	auipc	a0,0x1
    800030c0:	1e450513          	addi	a0,a0,484 # 800042a0 <CONSOLE_STATUS+0x290>
    800030c4:	00000097          	auipc	ra,0x0
    800030c8:	918080e7          	jalr	-1768(ra) # 800029dc <panic>

00000000800030cc <printfinit>:
    800030cc:	fe010113          	addi	sp,sp,-32
    800030d0:	00813823          	sd	s0,16(sp)
    800030d4:	00913423          	sd	s1,8(sp)
    800030d8:	00113c23          	sd	ra,24(sp)
    800030dc:	02010413          	addi	s0,sp,32
    800030e0:	00003497          	auipc	s1,0x3
    800030e4:	99048493          	addi	s1,s1,-1648 # 80005a70 <pr>
    800030e8:	00048513          	mv	a0,s1
    800030ec:	00001597          	auipc	a1,0x1
    800030f0:	1c458593          	addi	a1,a1,452 # 800042b0 <CONSOLE_STATUS+0x2a0>
    800030f4:	00000097          	auipc	ra,0x0
    800030f8:	5f4080e7          	jalr	1524(ra) # 800036e8 <initlock>
    800030fc:	01813083          	ld	ra,24(sp)
    80003100:	01013403          	ld	s0,16(sp)
    80003104:	0004ac23          	sw	zero,24(s1)
    80003108:	00813483          	ld	s1,8(sp)
    8000310c:	02010113          	addi	sp,sp,32
    80003110:	00008067          	ret

0000000080003114 <uartinit>:
    80003114:	ff010113          	addi	sp,sp,-16
    80003118:	00813423          	sd	s0,8(sp)
    8000311c:	01010413          	addi	s0,sp,16
    80003120:	100007b7          	lui	a5,0x10000
    80003124:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>
    80003128:	f8000713          	li	a4,-128
    8000312c:	00e781a3          	sb	a4,3(a5)
    80003130:	00300713          	li	a4,3
    80003134:	00e78023          	sb	a4,0(a5)
    80003138:	000780a3          	sb	zero,1(a5)
    8000313c:	00e781a3          	sb	a4,3(a5)
    80003140:	00700693          	li	a3,7
    80003144:	00d78123          	sb	a3,2(a5)
    80003148:	00e780a3          	sb	a4,1(a5)
    8000314c:	00813403          	ld	s0,8(sp)
    80003150:	01010113          	addi	sp,sp,16
    80003154:	00008067          	ret

0000000080003158 <uartputc>:
    80003158:	00001797          	auipc	a5,0x1
    8000315c:	6e07a783          	lw	a5,1760(a5) # 80004838 <panicked>
    80003160:	00078463          	beqz	a5,80003168 <uartputc+0x10>
    80003164:	0000006f          	j	80003164 <uartputc+0xc>
    80003168:	fd010113          	addi	sp,sp,-48
    8000316c:	02813023          	sd	s0,32(sp)
    80003170:	00913c23          	sd	s1,24(sp)
    80003174:	01213823          	sd	s2,16(sp)
    80003178:	01313423          	sd	s3,8(sp)
    8000317c:	02113423          	sd	ra,40(sp)
    80003180:	03010413          	addi	s0,sp,48
    80003184:	00001917          	auipc	s2,0x1
    80003188:	6bc90913          	addi	s2,s2,1724 # 80004840 <uart_tx_r>
    8000318c:	00093783          	ld	a5,0(s2)
    80003190:	00001497          	auipc	s1,0x1
    80003194:	6b848493          	addi	s1,s1,1720 # 80004848 <uart_tx_w>
    80003198:	0004b703          	ld	a4,0(s1)
    8000319c:	02078693          	addi	a3,a5,32
    800031a0:	00050993          	mv	s3,a0
    800031a4:	02e69c63          	bne	a3,a4,800031dc <uartputc+0x84>
    800031a8:	00001097          	auipc	ra,0x1
    800031ac:	834080e7          	jalr	-1996(ra) # 800039dc <push_on>
    800031b0:	00093783          	ld	a5,0(s2)
    800031b4:	0004b703          	ld	a4,0(s1)
    800031b8:	02078793          	addi	a5,a5,32
    800031bc:	00e79463          	bne	a5,a4,800031c4 <uartputc+0x6c>
    800031c0:	0000006f          	j	800031c0 <uartputc+0x68>
    800031c4:	00001097          	auipc	ra,0x1
    800031c8:	88c080e7          	jalr	-1908(ra) # 80003a50 <pop_on>
    800031cc:	00093783          	ld	a5,0(s2)
    800031d0:	0004b703          	ld	a4,0(s1)
    800031d4:	02078693          	addi	a3,a5,32
    800031d8:	fce688e3          	beq	a3,a4,800031a8 <uartputc+0x50>
    800031dc:	01f77693          	andi	a3,a4,31
    800031e0:	00003597          	auipc	a1,0x3
    800031e4:	8b058593          	addi	a1,a1,-1872 # 80005a90 <uart_tx_buf>
    800031e8:	00d586b3          	add	a3,a1,a3
    800031ec:	00170713          	addi	a4,a4,1
    800031f0:	01368023          	sb	s3,0(a3)
    800031f4:	00e4b023          	sd	a4,0(s1)
    800031f8:	10000637          	lui	a2,0x10000
    800031fc:	02f71063          	bne	a4,a5,8000321c <uartputc+0xc4>
    80003200:	0340006f          	j	80003234 <uartputc+0xdc>
    80003204:	00074703          	lbu	a4,0(a4)
    80003208:	00f93023          	sd	a5,0(s2)
    8000320c:	00e60023          	sb	a4,0(a2) # 10000000 <_entry-0x70000000>
    80003210:	00093783          	ld	a5,0(s2)
    80003214:	0004b703          	ld	a4,0(s1)
    80003218:	00f70e63          	beq	a4,a5,80003234 <uartputc+0xdc>
    8000321c:	00564683          	lbu	a3,5(a2)
    80003220:	01f7f713          	andi	a4,a5,31
    80003224:	00e58733          	add	a4,a1,a4
    80003228:	0206f693          	andi	a3,a3,32
    8000322c:	00178793          	addi	a5,a5,1
    80003230:	fc069ae3          	bnez	a3,80003204 <uartputc+0xac>
    80003234:	02813083          	ld	ra,40(sp)
    80003238:	02013403          	ld	s0,32(sp)
    8000323c:	01813483          	ld	s1,24(sp)
    80003240:	01013903          	ld	s2,16(sp)
    80003244:	00813983          	ld	s3,8(sp)
    80003248:	03010113          	addi	sp,sp,48
    8000324c:	00008067          	ret

0000000080003250 <uartputc_sync>:
    80003250:	ff010113          	addi	sp,sp,-16
    80003254:	00813423          	sd	s0,8(sp)
    80003258:	01010413          	addi	s0,sp,16
    8000325c:	00001717          	auipc	a4,0x1
    80003260:	5dc72703          	lw	a4,1500(a4) # 80004838 <panicked>
    80003264:	02071663          	bnez	a4,80003290 <uartputc_sync+0x40>
    80003268:	00050793          	mv	a5,a0
    8000326c:	100006b7          	lui	a3,0x10000
    80003270:	0056c703          	lbu	a4,5(a3) # 10000005 <_entry-0x6ffffffb>
    80003274:	02077713          	andi	a4,a4,32
    80003278:	fe070ce3          	beqz	a4,80003270 <uartputc_sync+0x20>
    8000327c:	0ff7f793          	andi	a5,a5,255
    80003280:	00f68023          	sb	a5,0(a3)
    80003284:	00813403          	ld	s0,8(sp)
    80003288:	01010113          	addi	sp,sp,16
    8000328c:	00008067          	ret
    80003290:	0000006f          	j	80003290 <uartputc_sync+0x40>

0000000080003294 <uartstart>:
    80003294:	ff010113          	addi	sp,sp,-16
    80003298:	00813423          	sd	s0,8(sp)
    8000329c:	01010413          	addi	s0,sp,16
    800032a0:	00001617          	auipc	a2,0x1
    800032a4:	5a060613          	addi	a2,a2,1440 # 80004840 <uart_tx_r>
    800032a8:	00001517          	auipc	a0,0x1
    800032ac:	5a050513          	addi	a0,a0,1440 # 80004848 <uart_tx_w>
    800032b0:	00063783          	ld	a5,0(a2)
    800032b4:	00053703          	ld	a4,0(a0)
    800032b8:	04f70263          	beq	a4,a5,800032fc <uartstart+0x68>
    800032bc:	100005b7          	lui	a1,0x10000
    800032c0:	00002817          	auipc	a6,0x2
    800032c4:	7d080813          	addi	a6,a6,2000 # 80005a90 <uart_tx_buf>
    800032c8:	01c0006f          	j	800032e4 <uartstart+0x50>
    800032cc:	0006c703          	lbu	a4,0(a3)
    800032d0:	00f63023          	sd	a5,0(a2)
    800032d4:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    800032d8:	00063783          	ld	a5,0(a2)
    800032dc:	00053703          	ld	a4,0(a0)
    800032e0:	00f70e63          	beq	a4,a5,800032fc <uartstart+0x68>
    800032e4:	01f7f713          	andi	a4,a5,31
    800032e8:	00e806b3          	add	a3,a6,a4
    800032ec:	0055c703          	lbu	a4,5(a1)
    800032f0:	00178793          	addi	a5,a5,1
    800032f4:	02077713          	andi	a4,a4,32
    800032f8:	fc071ae3          	bnez	a4,800032cc <uartstart+0x38>
    800032fc:	00813403          	ld	s0,8(sp)
    80003300:	01010113          	addi	sp,sp,16
    80003304:	00008067          	ret

0000000080003308 <uartgetc>:
    80003308:	ff010113          	addi	sp,sp,-16
    8000330c:	00813423          	sd	s0,8(sp)
    80003310:	01010413          	addi	s0,sp,16
    80003314:	10000737          	lui	a4,0x10000
    80003318:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000331c:	0017f793          	andi	a5,a5,1
    80003320:	00078c63          	beqz	a5,80003338 <uartgetc+0x30>
    80003324:	00074503          	lbu	a0,0(a4)
    80003328:	0ff57513          	andi	a0,a0,255
    8000332c:	00813403          	ld	s0,8(sp)
    80003330:	01010113          	addi	sp,sp,16
    80003334:	00008067          	ret
    80003338:	fff00513          	li	a0,-1
    8000333c:	ff1ff06f          	j	8000332c <uartgetc+0x24>

0000000080003340 <uartintr>:
    80003340:	100007b7          	lui	a5,0x10000
    80003344:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80003348:	0017f793          	andi	a5,a5,1
    8000334c:	0a078463          	beqz	a5,800033f4 <uartintr+0xb4>
    80003350:	fe010113          	addi	sp,sp,-32
    80003354:	00813823          	sd	s0,16(sp)
    80003358:	00913423          	sd	s1,8(sp)
    8000335c:	00113c23          	sd	ra,24(sp)
    80003360:	02010413          	addi	s0,sp,32
    80003364:	100004b7          	lui	s1,0x10000
    80003368:	0004c503          	lbu	a0,0(s1) # 10000000 <_entry-0x70000000>
    8000336c:	0ff57513          	andi	a0,a0,255
    80003370:	fffff097          	auipc	ra,0xfffff
    80003374:	534080e7          	jalr	1332(ra) # 800028a4 <consoleintr>
    80003378:	0054c783          	lbu	a5,5(s1)
    8000337c:	0017f793          	andi	a5,a5,1
    80003380:	fe0794e3          	bnez	a5,80003368 <uartintr+0x28>
    80003384:	00001617          	auipc	a2,0x1
    80003388:	4bc60613          	addi	a2,a2,1212 # 80004840 <uart_tx_r>
    8000338c:	00001517          	auipc	a0,0x1
    80003390:	4bc50513          	addi	a0,a0,1212 # 80004848 <uart_tx_w>
    80003394:	00063783          	ld	a5,0(a2)
    80003398:	00053703          	ld	a4,0(a0)
    8000339c:	04f70263          	beq	a4,a5,800033e0 <uartintr+0xa0>
    800033a0:	100005b7          	lui	a1,0x10000
    800033a4:	00002817          	auipc	a6,0x2
    800033a8:	6ec80813          	addi	a6,a6,1772 # 80005a90 <uart_tx_buf>
    800033ac:	01c0006f          	j	800033c8 <uartintr+0x88>
    800033b0:	0006c703          	lbu	a4,0(a3)
    800033b4:	00f63023          	sd	a5,0(a2)
    800033b8:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    800033bc:	00063783          	ld	a5,0(a2)
    800033c0:	00053703          	ld	a4,0(a0)
    800033c4:	00f70e63          	beq	a4,a5,800033e0 <uartintr+0xa0>
    800033c8:	01f7f713          	andi	a4,a5,31
    800033cc:	00e806b3          	add	a3,a6,a4
    800033d0:	0055c703          	lbu	a4,5(a1)
    800033d4:	00178793          	addi	a5,a5,1
    800033d8:	02077713          	andi	a4,a4,32
    800033dc:	fc071ae3          	bnez	a4,800033b0 <uartintr+0x70>
    800033e0:	01813083          	ld	ra,24(sp)
    800033e4:	01013403          	ld	s0,16(sp)
    800033e8:	00813483          	ld	s1,8(sp)
    800033ec:	02010113          	addi	sp,sp,32
    800033f0:	00008067          	ret
    800033f4:	00001617          	auipc	a2,0x1
    800033f8:	44c60613          	addi	a2,a2,1100 # 80004840 <uart_tx_r>
    800033fc:	00001517          	auipc	a0,0x1
    80003400:	44c50513          	addi	a0,a0,1100 # 80004848 <uart_tx_w>
    80003404:	00063783          	ld	a5,0(a2)
    80003408:	00053703          	ld	a4,0(a0)
    8000340c:	04f70263          	beq	a4,a5,80003450 <uartintr+0x110>
    80003410:	100005b7          	lui	a1,0x10000
    80003414:	00002817          	auipc	a6,0x2
    80003418:	67c80813          	addi	a6,a6,1660 # 80005a90 <uart_tx_buf>
    8000341c:	01c0006f          	j	80003438 <uartintr+0xf8>
    80003420:	0006c703          	lbu	a4,0(a3)
    80003424:	00f63023          	sd	a5,0(a2)
    80003428:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    8000342c:	00063783          	ld	a5,0(a2)
    80003430:	00053703          	ld	a4,0(a0)
    80003434:	02f70063          	beq	a4,a5,80003454 <uartintr+0x114>
    80003438:	01f7f713          	andi	a4,a5,31
    8000343c:	00e806b3          	add	a3,a6,a4
    80003440:	0055c703          	lbu	a4,5(a1)
    80003444:	00178793          	addi	a5,a5,1
    80003448:	02077713          	andi	a4,a4,32
    8000344c:	fc071ae3          	bnez	a4,80003420 <uartintr+0xe0>
    80003450:	00008067          	ret
    80003454:	00008067          	ret

0000000080003458 <kinit>:
    80003458:	fc010113          	addi	sp,sp,-64
    8000345c:	02913423          	sd	s1,40(sp)
    80003460:	fffff7b7          	lui	a5,0xfffff
    80003464:	00003497          	auipc	s1,0x3
    80003468:	64b48493          	addi	s1,s1,1611 # 80006aaf <end+0xfff>
    8000346c:	02813823          	sd	s0,48(sp)
    80003470:	01313c23          	sd	s3,24(sp)
    80003474:	00f4f4b3          	and	s1,s1,a5
    80003478:	02113c23          	sd	ra,56(sp)
    8000347c:	03213023          	sd	s2,32(sp)
    80003480:	01413823          	sd	s4,16(sp)
    80003484:	01513423          	sd	s5,8(sp)
    80003488:	04010413          	addi	s0,sp,64
    8000348c:	000017b7          	lui	a5,0x1
    80003490:	01100993          	li	s3,17
    80003494:	00f487b3          	add	a5,s1,a5
    80003498:	01b99993          	slli	s3,s3,0x1b
    8000349c:	06f9e063          	bltu	s3,a5,800034fc <kinit+0xa4>
    800034a0:	00002a97          	auipc	s5,0x2
    800034a4:	610a8a93          	addi	s5,s5,1552 # 80005ab0 <end>
    800034a8:	0754ec63          	bltu	s1,s5,80003520 <kinit+0xc8>
    800034ac:	0734fa63          	bgeu	s1,s3,80003520 <kinit+0xc8>
    800034b0:	00088a37          	lui	s4,0x88
    800034b4:	fffa0a13          	addi	s4,s4,-1 # 87fff <_entry-0x7ff78001>
    800034b8:	00001917          	auipc	s2,0x1
    800034bc:	39890913          	addi	s2,s2,920 # 80004850 <kmem>
    800034c0:	00ca1a13          	slli	s4,s4,0xc
    800034c4:	0140006f          	j	800034d8 <kinit+0x80>
    800034c8:	000017b7          	lui	a5,0x1
    800034cc:	00f484b3          	add	s1,s1,a5
    800034d0:	0554e863          	bltu	s1,s5,80003520 <kinit+0xc8>
    800034d4:	0534f663          	bgeu	s1,s3,80003520 <kinit+0xc8>
    800034d8:	00001637          	lui	a2,0x1
    800034dc:	00100593          	li	a1,1
    800034e0:	00048513          	mv	a0,s1
    800034e4:	00000097          	auipc	ra,0x0
    800034e8:	5e4080e7          	jalr	1508(ra) # 80003ac8 <__memset>
    800034ec:	00093783          	ld	a5,0(s2)
    800034f0:	00f4b023          	sd	a5,0(s1)
    800034f4:	00993023          	sd	s1,0(s2)
    800034f8:	fd4498e3          	bne	s1,s4,800034c8 <kinit+0x70>
    800034fc:	03813083          	ld	ra,56(sp)
    80003500:	03013403          	ld	s0,48(sp)
    80003504:	02813483          	ld	s1,40(sp)
    80003508:	02013903          	ld	s2,32(sp)
    8000350c:	01813983          	ld	s3,24(sp)
    80003510:	01013a03          	ld	s4,16(sp)
    80003514:	00813a83          	ld	s5,8(sp)
    80003518:	04010113          	addi	sp,sp,64
    8000351c:	00008067          	ret
    80003520:	00001517          	auipc	a0,0x1
    80003524:	db050513          	addi	a0,a0,-592 # 800042d0 <digits+0x18>
    80003528:	fffff097          	auipc	ra,0xfffff
    8000352c:	4b4080e7          	jalr	1204(ra) # 800029dc <panic>

0000000080003530 <freerange>:
    80003530:	fc010113          	addi	sp,sp,-64
    80003534:	000017b7          	lui	a5,0x1
    80003538:	02913423          	sd	s1,40(sp)
    8000353c:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80003540:	009504b3          	add	s1,a0,s1
    80003544:	fffff537          	lui	a0,0xfffff
    80003548:	02813823          	sd	s0,48(sp)
    8000354c:	02113c23          	sd	ra,56(sp)
    80003550:	03213023          	sd	s2,32(sp)
    80003554:	01313c23          	sd	s3,24(sp)
    80003558:	01413823          	sd	s4,16(sp)
    8000355c:	01513423          	sd	s5,8(sp)
    80003560:	01613023          	sd	s6,0(sp)
    80003564:	04010413          	addi	s0,sp,64
    80003568:	00a4f4b3          	and	s1,s1,a0
    8000356c:	00f487b3          	add	a5,s1,a5
    80003570:	06f5e463          	bltu	a1,a5,800035d8 <freerange+0xa8>
    80003574:	00002a97          	auipc	s5,0x2
    80003578:	53ca8a93          	addi	s5,s5,1340 # 80005ab0 <end>
    8000357c:	0954e263          	bltu	s1,s5,80003600 <freerange+0xd0>
    80003580:	01100993          	li	s3,17
    80003584:	01b99993          	slli	s3,s3,0x1b
    80003588:	0734fc63          	bgeu	s1,s3,80003600 <freerange+0xd0>
    8000358c:	00058a13          	mv	s4,a1
    80003590:	00001917          	auipc	s2,0x1
    80003594:	2c090913          	addi	s2,s2,704 # 80004850 <kmem>
    80003598:	00002b37          	lui	s6,0x2
    8000359c:	0140006f          	j	800035b0 <freerange+0x80>
    800035a0:	000017b7          	lui	a5,0x1
    800035a4:	00f484b3          	add	s1,s1,a5
    800035a8:	0554ec63          	bltu	s1,s5,80003600 <freerange+0xd0>
    800035ac:	0534fa63          	bgeu	s1,s3,80003600 <freerange+0xd0>
    800035b0:	00001637          	lui	a2,0x1
    800035b4:	00100593          	li	a1,1
    800035b8:	00048513          	mv	a0,s1
    800035bc:	00000097          	auipc	ra,0x0
    800035c0:	50c080e7          	jalr	1292(ra) # 80003ac8 <__memset>
    800035c4:	00093703          	ld	a4,0(s2)
    800035c8:	016487b3          	add	a5,s1,s6
    800035cc:	00e4b023          	sd	a4,0(s1)
    800035d0:	00993023          	sd	s1,0(s2)
    800035d4:	fcfa76e3          	bgeu	s4,a5,800035a0 <freerange+0x70>
    800035d8:	03813083          	ld	ra,56(sp)
    800035dc:	03013403          	ld	s0,48(sp)
    800035e0:	02813483          	ld	s1,40(sp)
    800035e4:	02013903          	ld	s2,32(sp)
    800035e8:	01813983          	ld	s3,24(sp)
    800035ec:	01013a03          	ld	s4,16(sp)
    800035f0:	00813a83          	ld	s5,8(sp)
    800035f4:	00013b03          	ld	s6,0(sp)
    800035f8:	04010113          	addi	sp,sp,64
    800035fc:	00008067          	ret
    80003600:	00001517          	auipc	a0,0x1
    80003604:	cd050513          	addi	a0,a0,-816 # 800042d0 <digits+0x18>
    80003608:	fffff097          	auipc	ra,0xfffff
    8000360c:	3d4080e7          	jalr	980(ra) # 800029dc <panic>

0000000080003610 <kfree>:
    80003610:	fe010113          	addi	sp,sp,-32
    80003614:	00813823          	sd	s0,16(sp)
    80003618:	00113c23          	sd	ra,24(sp)
    8000361c:	00913423          	sd	s1,8(sp)
    80003620:	02010413          	addi	s0,sp,32
    80003624:	03451793          	slli	a5,a0,0x34
    80003628:	04079c63          	bnez	a5,80003680 <kfree+0x70>
    8000362c:	00002797          	auipc	a5,0x2
    80003630:	48478793          	addi	a5,a5,1156 # 80005ab0 <end>
    80003634:	00050493          	mv	s1,a0
    80003638:	04f56463          	bltu	a0,a5,80003680 <kfree+0x70>
    8000363c:	01100793          	li	a5,17
    80003640:	01b79793          	slli	a5,a5,0x1b
    80003644:	02f57e63          	bgeu	a0,a5,80003680 <kfree+0x70>
    80003648:	00001637          	lui	a2,0x1
    8000364c:	00100593          	li	a1,1
    80003650:	00000097          	auipc	ra,0x0
    80003654:	478080e7          	jalr	1144(ra) # 80003ac8 <__memset>
    80003658:	00001797          	auipc	a5,0x1
    8000365c:	1f878793          	addi	a5,a5,504 # 80004850 <kmem>
    80003660:	0007b703          	ld	a4,0(a5)
    80003664:	01813083          	ld	ra,24(sp)
    80003668:	01013403          	ld	s0,16(sp)
    8000366c:	00e4b023          	sd	a4,0(s1)
    80003670:	0097b023          	sd	s1,0(a5)
    80003674:	00813483          	ld	s1,8(sp)
    80003678:	02010113          	addi	sp,sp,32
    8000367c:	00008067          	ret
    80003680:	00001517          	auipc	a0,0x1
    80003684:	c5050513          	addi	a0,a0,-944 # 800042d0 <digits+0x18>
    80003688:	fffff097          	auipc	ra,0xfffff
    8000368c:	354080e7          	jalr	852(ra) # 800029dc <panic>

0000000080003690 <kalloc>:
    80003690:	fe010113          	addi	sp,sp,-32
    80003694:	00813823          	sd	s0,16(sp)
    80003698:	00913423          	sd	s1,8(sp)
    8000369c:	00113c23          	sd	ra,24(sp)
    800036a0:	02010413          	addi	s0,sp,32
    800036a4:	00001797          	auipc	a5,0x1
    800036a8:	1ac78793          	addi	a5,a5,428 # 80004850 <kmem>
    800036ac:	0007b483          	ld	s1,0(a5)
    800036b0:	02048063          	beqz	s1,800036d0 <kalloc+0x40>
    800036b4:	0004b703          	ld	a4,0(s1)
    800036b8:	00001637          	lui	a2,0x1
    800036bc:	00500593          	li	a1,5
    800036c0:	00048513          	mv	a0,s1
    800036c4:	00e7b023          	sd	a4,0(a5)
    800036c8:	00000097          	auipc	ra,0x0
    800036cc:	400080e7          	jalr	1024(ra) # 80003ac8 <__memset>
    800036d0:	01813083          	ld	ra,24(sp)
    800036d4:	01013403          	ld	s0,16(sp)
    800036d8:	00048513          	mv	a0,s1
    800036dc:	00813483          	ld	s1,8(sp)
    800036e0:	02010113          	addi	sp,sp,32
    800036e4:	00008067          	ret

00000000800036e8 <initlock>:
    800036e8:	ff010113          	addi	sp,sp,-16
    800036ec:	00813423          	sd	s0,8(sp)
    800036f0:	01010413          	addi	s0,sp,16
    800036f4:	00813403          	ld	s0,8(sp)
    800036f8:	00b53423          	sd	a1,8(a0)
    800036fc:	00052023          	sw	zero,0(a0)
    80003700:	00053823          	sd	zero,16(a0)
    80003704:	01010113          	addi	sp,sp,16
    80003708:	00008067          	ret

000000008000370c <acquire>:
    8000370c:	fe010113          	addi	sp,sp,-32
    80003710:	00813823          	sd	s0,16(sp)
    80003714:	00913423          	sd	s1,8(sp)
    80003718:	00113c23          	sd	ra,24(sp)
    8000371c:	01213023          	sd	s2,0(sp)
    80003720:	02010413          	addi	s0,sp,32
    80003724:	00050493          	mv	s1,a0
    80003728:	10002973          	csrr	s2,sstatus
    8000372c:	100027f3          	csrr	a5,sstatus
    80003730:	ffd7f793          	andi	a5,a5,-3
    80003734:	10079073          	csrw	sstatus,a5
    80003738:	fffff097          	auipc	ra,0xfffff
    8000373c:	8e8080e7          	jalr	-1816(ra) # 80002020 <mycpu>
    80003740:	07852783          	lw	a5,120(a0)
    80003744:	06078e63          	beqz	a5,800037c0 <acquire+0xb4>
    80003748:	fffff097          	auipc	ra,0xfffff
    8000374c:	8d8080e7          	jalr	-1832(ra) # 80002020 <mycpu>
    80003750:	07852783          	lw	a5,120(a0)
    80003754:	0004a703          	lw	a4,0(s1)
    80003758:	0017879b          	addiw	a5,a5,1
    8000375c:	06f52c23          	sw	a5,120(a0)
    80003760:	04071063          	bnez	a4,800037a0 <acquire+0x94>
    80003764:	00100713          	li	a4,1
    80003768:	00070793          	mv	a5,a4
    8000376c:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80003770:	0007879b          	sext.w	a5,a5
    80003774:	fe079ae3          	bnez	a5,80003768 <acquire+0x5c>
    80003778:	0ff0000f          	fence
    8000377c:	fffff097          	auipc	ra,0xfffff
    80003780:	8a4080e7          	jalr	-1884(ra) # 80002020 <mycpu>
    80003784:	01813083          	ld	ra,24(sp)
    80003788:	01013403          	ld	s0,16(sp)
    8000378c:	00a4b823          	sd	a0,16(s1)
    80003790:	00013903          	ld	s2,0(sp)
    80003794:	00813483          	ld	s1,8(sp)
    80003798:	02010113          	addi	sp,sp,32
    8000379c:	00008067          	ret
    800037a0:	0104b903          	ld	s2,16(s1)
    800037a4:	fffff097          	auipc	ra,0xfffff
    800037a8:	87c080e7          	jalr	-1924(ra) # 80002020 <mycpu>
    800037ac:	faa91ce3          	bne	s2,a0,80003764 <acquire+0x58>
    800037b0:	00001517          	auipc	a0,0x1
    800037b4:	b2850513          	addi	a0,a0,-1240 # 800042d8 <digits+0x20>
    800037b8:	fffff097          	auipc	ra,0xfffff
    800037bc:	224080e7          	jalr	548(ra) # 800029dc <panic>
    800037c0:	00195913          	srli	s2,s2,0x1
    800037c4:	fffff097          	auipc	ra,0xfffff
    800037c8:	85c080e7          	jalr	-1956(ra) # 80002020 <mycpu>
    800037cc:	00197913          	andi	s2,s2,1
    800037d0:	07252e23          	sw	s2,124(a0)
    800037d4:	f75ff06f          	j	80003748 <acquire+0x3c>

00000000800037d8 <release>:
    800037d8:	fe010113          	addi	sp,sp,-32
    800037dc:	00813823          	sd	s0,16(sp)
    800037e0:	00113c23          	sd	ra,24(sp)
    800037e4:	00913423          	sd	s1,8(sp)
    800037e8:	01213023          	sd	s2,0(sp)
    800037ec:	02010413          	addi	s0,sp,32
    800037f0:	00052783          	lw	a5,0(a0)
    800037f4:	00079a63          	bnez	a5,80003808 <release+0x30>
    800037f8:	00001517          	auipc	a0,0x1
    800037fc:	ae850513          	addi	a0,a0,-1304 # 800042e0 <digits+0x28>
    80003800:	fffff097          	auipc	ra,0xfffff
    80003804:	1dc080e7          	jalr	476(ra) # 800029dc <panic>
    80003808:	01053903          	ld	s2,16(a0)
    8000380c:	00050493          	mv	s1,a0
    80003810:	fffff097          	auipc	ra,0xfffff
    80003814:	810080e7          	jalr	-2032(ra) # 80002020 <mycpu>
    80003818:	fea910e3          	bne	s2,a0,800037f8 <release+0x20>
    8000381c:	0004b823          	sd	zero,16(s1)
    80003820:	0ff0000f          	fence
    80003824:	0f50000f          	fence	iorw,ow
    80003828:	0804a02f          	amoswap.w	zero,zero,(s1)
    8000382c:	ffffe097          	auipc	ra,0xffffe
    80003830:	7f4080e7          	jalr	2036(ra) # 80002020 <mycpu>
    80003834:	100027f3          	csrr	a5,sstatus
    80003838:	0027f793          	andi	a5,a5,2
    8000383c:	04079a63          	bnez	a5,80003890 <release+0xb8>
    80003840:	07852783          	lw	a5,120(a0)
    80003844:	02f05e63          	blez	a5,80003880 <release+0xa8>
    80003848:	fff7871b          	addiw	a4,a5,-1
    8000384c:	06e52c23          	sw	a4,120(a0)
    80003850:	00071c63          	bnez	a4,80003868 <release+0x90>
    80003854:	07c52783          	lw	a5,124(a0)
    80003858:	00078863          	beqz	a5,80003868 <release+0x90>
    8000385c:	100027f3          	csrr	a5,sstatus
    80003860:	0027e793          	ori	a5,a5,2
    80003864:	10079073          	csrw	sstatus,a5
    80003868:	01813083          	ld	ra,24(sp)
    8000386c:	01013403          	ld	s0,16(sp)
    80003870:	00813483          	ld	s1,8(sp)
    80003874:	00013903          	ld	s2,0(sp)
    80003878:	02010113          	addi	sp,sp,32
    8000387c:	00008067          	ret
    80003880:	00001517          	auipc	a0,0x1
    80003884:	a8050513          	addi	a0,a0,-1408 # 80004300 <digits+0x48>
    80003888:	fffff097          	auipc	ra,0xfffff
    8000388c:	154080e7          	jalr	340(ra) # 800029dc <panic>
    80003890:	00001517          	auipc	a0,0x1
    80003894:	a5850513          	addi	a0,a0,-1448 # 800042e8 <digits+0x30>
    80003898:	fffff097          	auipc	ra,0xfffff
    8000389c:	144080e7          	jalr	324(ra) # 800029dc <panic>

00000000800038a0 <holding>:
    800038a0:	00052783          	lw	a5,0(a0)
    800038a4:	00079663          	bnez	a5,800038b0 <holding+0x10>
    800038a8:	00000513          	li	a0,0
    800038ac:	00008067          	ret
    800038b0:	fe010113          	addi	sp,sp,-32
    800038b4:	00813823          	sd	s0,16(sp)
    800038b8:	00913423          	sd	s1,8(sp)
    800038bc:	00113c23          	sd	ra,24(sp)
    800038c0:	02010413          	addi	s0,sp,32
    800038c4:	01053483          	ld	s1,16(a0)
    800038c8:	ffffe097          	auipc	ra,0xffffe
    800038cc:	758080e7          	jalr	1880(ra) # 80002020 <mycpu>
    800038d0:	01813083          	ld	ra,24(sp)
    800038d4:	01013403          	ld	s0,16(sp)
    800038d8:	40a48533          	sub	a0,s1,a0
    800038dc:	00153513          	seqz	a0,a0
    800038e0:	00813483          	ld	s1,8(sp)
    800038e4:	02010113          	addi	sp,sp,32
    800038e8:	00008067          	ret

00000000800038ec <push_off>:
    800038ec:	fe010113          	addi	sp,sp,-32
    800038f0:	00813823          	sd	s0,16(sp)
    800038f4:	00113c23          	sd	ra,24(sp)
    800038f8:	00913423          	sd	s1,8(sp)
    800038fc:	02010413          	addi	s0,sp,32
    80003900:	100024f3          	csrr	s1,sstatus
    80003904:	100027f3          	csrr	a5,sstatus
    80003908:	ffd7f793          	andi	a5,a5,-3
    8000390c:	10079073          	csrw	sstatus,a5
    80003910:	ffffe097          	auipc	ra,0xffffe
    80003914:	710080e7          	jalr	1808(ra) # 80002020 <mycpu>
    80003918:	07852783          	lw	a5,120(a0)
    8000391c:	02078663          	beqz	a5,80003948 <push_off+0x5c>
    80003920:	ffffe097          	auipc	ra,0xffffe
    80003924:	700080e7          	jalr	1792(ra) # 80002020 <mycpu>
    80003928:	07852783          	lw	a5,120(a0)
    8000392c:	01813083          	ld	ra,24(sp)
    80003930:	01013403          	ld	s0,16(sp)
    80003934:	0017879b          	addiw	a5,a5,1
    80003938:	06f52c23          	sw	a5,120(a0)
    8000393c:	00813483          	ld	s1,8(sp)
    80003940:	02010113          	addi	sp,sp,32
    80003944:	00008067          	ret
    80003948:	0014d493          	srli	s1,s1,0x1
    8000394c:	ffffe097          	auipc	ra,0xffffe
    80003950:	6d4080e7          	jalr	1748(ra) # 80002020 <mycpu>
    80003954:	0014f493          	andi	s1,s1,1
    80003958:	06952e23          	sw	s1,124(a0)
    8000395c:	fc5ff06f          	j	80003920 <push_off+0x34>

0000000080003960 <pop_off>:
    80003960:	ff010113          	addi	sp,sp,-16
    80003964:	00813023          	sd	s0,0(sp)
    80003968:	00113423          	sd	ra,8(sp)
    8000396c:	01010413          	addi	s0,sp,16
    80003970:	ffffe097          	auipc	ra,0xffffe
    80003974:	6b0080e7          	jalr	1712(ra) # 80002020 <mycpu>
    80003978:	100027f3          	csrr	a5,sstatus
    8000397c:	0027f793          	andi	a5,a5,2
    80003980:	04079663          	bnez	a5,800039cc <pop_off+0x6c>
    80003984:	07852783          	lw	a5,120(a0)
    80003988:	02f05a63          	blez	a5,800039bc <pop_off+0x5c>
    8000398c:	fff7871b          	addiw	a4,a5,-1
    80003990:	06e52c23          	sw	a4,120(a0)
    80003994:	00071c63          	bnez	a4,800039ac <pop_off+0x4c>
    80003998:	07c52783          	lw	a5,124(a0)
    8000399c:	00078863          	beqz	a5,800039ac <pop_off+0x4c>
    800039a0:	100027f3          	csrr	a5,sstatus
    800039a4:	0027e793          	ori	a5,a5,2
    800039a8:	10079073          	csrw	sstatus,a5
    800039ac:	00813083          	ld	ra,8(sp)
    800039b0:	00013403          	ld	s0,0(sp)
    800039b4:	01010113          	addi	sp,sp,16
    800039b8:	00008067          	ret
    800039bc:	00001517          	auipc	a0,0x1
    800039c0:	94450513          	addi	a0,a0,-1724 # 80004300 <digits+0x48>
    800039c4:	fffff097          	auipc	ra,0xfffff
    800039c8:	018080e7          	jalr	24(ra) # 800029dc <panic>
    800039cc:	00001517          	auipc	a0,0x1
    800039d0:	91c50513          	addi	a0,a0,-1764 # 800042e8 <digits+0x30>
    800039d4:	fffff097          	auipc	ra,0xfffff
    800039d8:	008080e7          	jalr	8(ra) # 800029dc <panic>

00000000800039dc <push_on>:
    800039dc:	fe010113          	addi	sp,sp,-32
    800039e0:	00813823          	sd	s0,16(sp)
    800039e4:	00113c23          	sd	ra,24(sp)
    800039e8:	00913423          	sd	s1,8(sp)
    800039ec:	02010413          	addi	s0,sp,32
    800039f0:	100024f3          	csrr	s1,sstatus
    800039f4:	100027f3          	csrr	a5,sstatus
    800039f8:	0027e793          	ori	a5,a5,2
    800039fc:	10079073          	csrw	sstatus,a5
    80003a00:	ffffe097          	auipc	ra,0xffffe
    80003a04:	620080e7          	jalr	1568(ra) # 80002020 <mycpu>
    80003a08:	07852783          	lw	a5,120(a0)
    80003a0c:	02078663          	beqz	a5,80003a38 <push_on+0x5c>
    80003a10:	ffffe097          	auipc	ra,0xffffe
    80003a14:	610080e7          	jalr	1552(ra) # 80002020 <mycpu>
    80003a18:	07852783          	lw	a5,120(a0)
    80003a1c:	01813083          	ld	ra,24(sp)
    80003a20:	01013403          	ld	s0,16(sp)
    80003a24:	0017879b          	addiw	a5,a5,1
    80003a28:	06f52c23          	sw	a5,120(a0)
    80003a2c:	00813483          	ld	s1,8(sp)
    80003a30:	02010113          	addi	sp,sp,32
    80003a34:	00008067          	ret
    80003a38:	0014d493          	srli	s1,s1,0x1
    80003a3c:	ffffe097          	auipc	ra,0xffffe
    80003a40:	5e4080e7          	jalr	1508(ra) # 80002020 <mycpu>
    80003a44:	0014f493          	andi	s1,s1,1
    80003a48:	06952e23          	sw	s1,124(a0)
    80003a4c:	fc5ff06f          	j	80003a10 <push_on+0x34>

0000000080003a50 <pop_on>:
    80003a50:	ff010113          	addi	sp,sp,-16
    80003a54:	00813023          	sd	s0,0(sp)
    80003a58:	00113423          	sd	ra,8(sp)
    80003a5c:	01010413          	addi	s0,sp,16
    80003a60:	ffffe097          	auipc	ra,0xffffe
    80003a64:	5c0080e7          	jalr	1472(ra) # 80002020 <mycpu>
    80003a68:	100027f3          	csrr	a5,sstatus
    80003a6c:	0027f793          	andi	a5,a5,2
    80003a70:	04078463          	beqz	a5,80003ab8 <pop_on+0x68>
    80003a74:	07852783          	lw	a5,120(a0)
    80003a78:	02f05863          	blez	a5,80003aa8 <pop_on+0x58>
    80003a7c:	fff7879b          	addiw	a5,a5,-1
    80003a80:	06f52c23          	sw	a5,120(a0)
    80003a84:	07853783          	ld	a5,120(a0)
    80003a88:	00079863          	bnez	a5,80003a98 <pop_on+0x48>
    80003a8c:	100027f3          	csrr	a5,sstatus
    80003a90:	ffd7f793          	andi	a5,a5,-3
    80003a94:	10079073          	csrw	sstatus,a5
    80003a98:	00813083          	ld	ra,8(sp)
    80003a9c:	00013403          	ld	s0,0(sp)
    80003aa0:	01010113          	addi	sp,sp,16
    80003aa4:	00008067          	ret
    80003aa8:	00001517          	auipc	a0,0x1
    80003aac:	88050513          	addi	a0,a0,-1920 # 80004328 <digits+0x70>
    80003ab0:	fffff097          	auipc	ra,0xfffff
    80003ab4:	f2c080e7          	jalr	-212(ra) # 800029dc <panic>
    80003ab8:	00001517          	auipc	a0,0x1
    80003abc:	85050513          	addi	a0,a0,-1968 # 80004308 <digits+0x50>
    80003ac0:	fffff097          	auipc	ra,0xfffff
    80003ac4:	f1c080e7          	jalr	-228(ra) # 800029dc <panic>

0000000080003ac8 <__memset>:
    80003ac8:	ff010113          	addi	sp,sp,-16
    80003acc:	00813423          	sd	s0,8(sp)
    80003ad0:	01010413          	addi	s0,sp,16
    80003ad4:	1a060e63          	beqz	a2,80003c90 <__memset+0x1c8>
    80003ad8:	40a007b3          	neg	a5,a0
    80003adc:	0077f793          	andi	a5,a5,7
    80003ae0:	00778693          	addi	a3,a5,7
    80003ae4:	00b00813          	li	a6,11
    80003ae8:	0ff5f593          	andi	a1,a1,255
    80003aec:	fff6071b          	addiw	a4,a2,-1
    80003af0:	1b06e663          	bltu	a3,a6,80003c9c <__memset+0x1d4>
    80003af4:	1cd76463          	bltu	a4,a3,80003cbc <__memset+0x1f4>
    80003af8:	1a078e63          	beqz	a5,80003cb4 <__memset+0x1ec>
    80003afc:	00b50023          	sb	a1,0(a0)
    80003b00:	00100713          	li	a4,1
    80003b04:	1ae78463          	beq	a5,a4,80003cac <__memset+0x1e4>
    80003b08:	00b500a3          	sb	a1,1(a0)
    80003b0c:	00200713          	li	a4,2
    80003b10:	1ae78a63          	beq	a5,a4,80003cc4 <__memset+0x1fc>
    80003b14:	00b50123          	sb	a1,2(a0)
    80003b18:	00300713          	li	a4,3
    80003b1c:	18e78463          	beq	a5,a4,80003ca4 <__memset+0x1dc>
    80003b20:	00b501a3          	sb	a1,3(a0)
    80003b24:	00400713          	li	a4,4
    80003b28:	1ae78263          	beq	a5,a4,80003ccc <__memset+0x204>
    80003b2c:	00b50223          	sb	a1,4(a0)
    80003b30:	00500713          	li	a4,5
    80003b34:	1ae78063          	beq	a5,a4,80003cd4 <__memset+0x20c>
    80003b38:	00b502a3          	sb	a1,5(a0)
    80003b3c:	00700713          	li	a4,7
    80003b40:	18e79e63          	bne	a5,a4,80003cdc <__memset+0x214>
    80003b44:	00b50323          	sb	a1,6(a0)
    80003b48:	00700e93          	li	t4,7
    80003b4c:	00859713          	slli	a4,a1,0x8
    80003b50:	00e5e733          	or	a4,a1,a4
    80003b54:	01059e13          	slli	t3,a1,0x10
    80003b58:	01c76e33          	or	t3,a4,t3
    80003b5c:	01859313          	slli	t1,a1,0x18
    80003b60:	006e6333          	or	t1,t3,t1
    80003b64:	02059893          	slli	a7,a1,0x20
    80003b68:	40f60e3b          	subw	t3,a2,a5
    80003b6c:	011368b3          	or	a7,t1,a7
    80003b70:	02859813          	slli	a6,a1,0x28
    80003b74:	0108e833          	or	a6,a7,a6
    80003b78:	03059693          	slli	a3,a1,0x30
    80003b7c:	003e589b          	srliw	a7,t3,0x3
    80003b80:	00d866b3          	or	a3,a6,a3
    80003b84:	03859713          	slli	a4,a1,0x38
    80003b88:	00389813          	slli	a6,a7,0x3
    80003b8c:	00f507b3          	add	a5,a0,a5
    80003b90:	00e6e733          	or	a4,a3,a4
    80003b94:	000e089b          	sext.w	a7,t3
    80003b98:	00f806b3          	add	a3,a6,a5
    80003b9c:	00e7b023          	sd	a4,0(a5)
    80003ba0:	00878793          	addi	a5,a5,8
    80003ba4:	fed79ce3          	bne	a5,a3,80003b9c <__memset+0xd4>
    80003ba8:	ff8e7793          	andi	a5,t3,-8
    80003bac:	0007871b          	sext.w	a4,a5
    80003bb0:	01d787bb          	addw	a5,a5,t4
    80003bb4:	0ce88e63          	beq	a7,a4,80003c90 <__memset+0x1c8>
    80003bb8:	00f50733          	add	a4,a0,a5
    80003bbc:	00b70023          	sb	a1,0(a4)
    80003bc0:	0017871b          	addiw	a4,a5,1
    80003bc4:	0cc77663          	bgeu	a4,a2,80003c90 <__memset+0x1c8>
    80003bc8:	00e50733          	add	a4,a0,a4
    80003bcc:	00b70023          	sb	a1,0(a4)
    80003bd0:	0027871b          	addiw	a4,a5,2
    80003bd4:	0ac77e63          	bgeu	a4,a2,80003c90 <__memset+0x1c8>
    80003bd8:	00e50733          	add	a4,a0,a4
    80003bdc:	00b70023          	sb	a1,0(a4)
    80003be0:	0037871b          	addiw	a4,a5,3
    80003be4:	0ac77663          	bgeu	a4,a2,80003c90 <__memset+0x1c8>
    80003be8:	00e50733          	add	a4,a0,a4
    80003bec:	00b70023          	sb	a1,0(a4)
    80003bf0:	0047871b          	addiw	a4,a5,4
    80003bf4:	08c77e63          	bgeu	a4,a2,80003c90 <__memset+0x1c8>
    80003bf8:	00e50733          	add	a4,a0,a4
    80003bfc:	00b70023          	sb	a1,0(a4)
    80003c00:	0057871b          	addiw	a4,a5,5
    80003c04:	08c77663          	bgeu	a4,a2,80003c90 <__memset+0x1c8>
    80003c08:	00e50733          	add	a4,a0,a4
    80003c0c:	00b70023          	sb	a1,0(a4)
    80003c10:	0067871b          	addiw	a4,a5,6
    80003c14:	06c77e63          	bgeu	a4,a2,80003c90 <__memset+0x1c8>
    80003c18:	00e50733          	add	a4,a0,a4
    80003c1c:	00b70023          	sb	a1,0(a4)
    80003c20:	0077871b          	addiw	a4,a5,7
    80003c24:	06c77663          	bgeu	a4,a2,80003c90 <__memset+0x1c8>
    80003c28:	00e50733          	add	a4,a0,a4
    80003c2c:	00b70023          	sb	a1,0(a4)
    80003c30:	0087871b          	addiw	a4,a5,8
    80003c34:	04c77e63          	bgeu	a4,a2,80003c90 <__memset+0x1c8>
    80003c38:	00e50733          	add	a4,a0,a4
    80003c3c:	00b70023          	sb	a1,0(a4)
    80003c40:	0097871b          	addiw	a4,a5,9
    80003c44:	04c77663          	bgeu	a4,a2,80003c90 <__memset+0x1c8>
    80003c48:	00e50733          	add	a4,a0,a4
    80003c4c:	00b70023          	sb	a1,0(a4)
    80003c50:	00a7871b          	addiw	a4,a5,10
    80003c54:	02c77e63          	bgeu	a4,a2,80003c90 <__memset+0x1c8>
    80003c58:	00e50733          	add	a4,a0,a4
    80003c5c:	00b70023          	sb	a1,0(a4)
    80003c60:	00b7871b          	addiw	a4,a5,11
    80003c64:	02c77663          	bgeu	a4,a2,80003c90 <__memset+0x1c8>
    80003c68:	00e50733          	add	a4,a0,a4
    80003c6c:	00b70023          	sb	a1,0(a4)
    80003c70:	00c7871b          	addiw	a4,a5,12
    80003c74:	00c77e63          	bgeu	a4,a2,80003c90 <__memset+0x1c8>
    80003c78:	00e50733          	add	a4,a0,a4
    80003c7c:	00b70023          	sb	a1,0(a4)
    80003c80:	00d7879b          	addiw	a5,a5,13
    80003c84:	00c7f663          	bgeu	a5,a2,80003c90 <__memset+0x1c8>
    80003c88:	00f507b3          	add	a5,a0,a5
    80003c8c:	00b78023          	sb	a1,0(a5)
    80003c90:	00813403          	ld	s0,8(sp)
    80003c94:	01010113          	addi	sp,sp,16
    80003c98:	00008067          	ret
    80003c9c:	00b00693          	li	a3,11
    80003ca0:	e55ff06f          	j	80003af4 <__memset+0x2c>
    80003ca4:	00300e93          	li	t4,3
    80003ca8:	ea5ff06f          	j	80003b4c <__memset+0x84>
    80003cac:	00100e93          	li	t4,1
    80003cb0:	e9dff06f          	j	80003b4c <__memset+0x84>
    80003cb4:	00000e93          	li	t4,0
    80003cb8:	e95ff06f          	j	80003b4c <__memset+0x84>
    80003cbc:	00000793          	li	a5,0
    80003cc0:	ef9ff06f          	j	80003bb8 <__memset+0xf0>
    80003cc4:	00200e93          	li	t4,2
    80003cc8:	e85ff06f          	j	80003b4c <__memset+0x84>
    80003ccc:	00400e93          	li	t4,4
    80003cd0:	e7dff06f          	j	80003b4c <__memset+0x84>
    80003cd4:	00500e93          	li	t4,5
    80003cd8:	e75ff06f          	j	80003b4c <__memset+0x84>
    80003cdc:	00600e93          	li	t4,6
    80003ce0:	e6dff06f          	j	80003b4c <__memset+0x84>

0000000080003ce4 <__memmove>:
    80003ce4:	ff010113          	addi	sp,sp,-16
    80003ce8:	00813423          	sd	s0,8(sp)
    80003cec:	01010413          	addi	s0,sp,16
    80003cf0:	0e060863          	beqz	a2,80003de0 <__memmove+0xfc>
    80003cf4:	fff6069b          	addiw	a3,a2,-1
    80003cf8:	0006881b          	sext.w	a6,a3
    80003cfc:	0ea5e863          	bltu	a1,a0,80003dec <__memmove+0x108>
    80003d00:	00758713          	addi	a4,a1,7
    80003d04:	00a5e7b3          	or	a5,a1,a0
    80003d08:	40a70733          	sub	a4,a4,a0
    80003d0c:	0077f793          	andi	a5,a5,7
    80003d10:	00f73713          	sltiu	a4,a4,15
    80003d14:	00174713          	xori	a4,a4,1
    80003d18:	0017b793          	seqz	a5,a5
    80003d1c:	00e7f7b3          	and	a5,a5,a4
    80003d20:	10078863          	beqz	a5,80003e30 <__memmove+0x14c>
    80003d24:	00900793          	li	a5,9
    80003d28:	1107f463          	bgeu	a5,a6,80003e30 <__memmove+0x14c>
    80003d2c:	0036581b          	srliw	a6,a2,0x3
    80003d30:	fff8081b          	addiw	a6,a6,-1
    80003d34:	02081813          	slli	a6,a6,0x20
    80003d38:	01d85893          	srli	a7,a6,0x1d
    80003d3c:	00858813          	addi	a6,a1,8
    80003d40:	00058793          	mv	a5,a1
    80003d44:	00050713          	mv	a4,a0
    80003d48:	01088833          	add	a6,a7,a6
    80003d4c:	0007b883          	ld	a7,0(a5)
    80003d50:	00878793          	addi	a5,a5,8
    80003d54:	00870713          	addi	a4,a4,8
    80003d58:	ff173c23          	sd	a7,-8(a4)
    80003d5c:	ff0798e3          	bne	a5,a6,80003d4c <__memmove+0x68>
    80003d60:	ff867713          	andi	a4,a2,-8
    80003d64:	02071793          	slli	a5,a4,0x20
    80003d68:	0207d793          	srli	a5,a5,0x20
    80003d6c:	00f585b3          	add	a1,a1,a5
    80003d70:	40e686bb          	subw	a3,a3,a4
    80003d74:	00f507b3          	add	a5,a0,a5
    80003d78:	06e60463          	beq	a2,a4,80003de0 <__memmove+0xfc>
    80003d7c:	0005c703          	lbu	a4,0(a1)
    80003d80:	00e78023          	sb	a4,0(a5)
    80003d84:	04068e63          	beqz	a3,80003de0 <__memmove+0xfc>
    80003d88:	0015c603          	lbu	a2,1(a1)
    80003d8c:	00100713          	li	a4,1
    80003d90:	00c780a3          	sb	a2,1(a5)
    80003d94:	04e68663          	beq	a3,a4,80003de0 <__memmove+0xfc>
    80003d98:	0025c603          	lbu	a2,2(a1)
    80003d9c:	00200713          	li	a4,2
    80003da0:	00c78123          	sb	a2,2(a5)
    80003da4:	02e68e63          	beq	a3,a4,80003de0 <__memmove+0xfc>
    80003da8:	0035c603          	lbu	a2,3(a1)
    80003dac:	00300713          	li	a4,3
    80003db0:	00c781a3          	sb	a2,3(a5)
    80003db4:	02e68663          	beq	a3,a4,80003de0 <__memmove+0xfc>
    80003db8:	0045c603          	lbu	a2,4(a1)
    80003dbc:	00400713          	li	a4,4
    80003dc0:	00c78223          	sb	a2,4(a5)
    80003dc4:	00e68e63          	beq	a3,a4,80003de0 <__memmove+0xfc>
    80003dc8:	0055c603          	lbu	a2,5(a1)
    80003dcc:	00500713          	li	a4,5
    80003dd0:	00c782a3          	sb	a2,5(a5)
    80003dd4:	00e68663          	beq	a3,a4,80003de0 <__memmove+0xfc>
    80003dd8:	0065c703          	lbu	a4,6(a1)
    80003ddc:	00e78323          	sb	a4,6(a5)
    80003de0:	00813403          	ld	s0,8(sp)
    80003de4:	01010113          	addi	sp,sp,16
    80003de8:	00008067          	ret
    80003dec:	02061713          	slli	a4,a2,0x20
    80003df0:	02075713          	srli	a4,a4,0x20
    80003df4:	00e587b3          	add	a5,a1,a4
    80003df8:	f0f574e3          	bgeu	a0,a5,80003d00 <__memmove+0x1c>
    80003dfc:	02069613          	slli	a2,a3,0x20
    80003e00:	02065613          	srli	a2,a2,0x20
    80003e04:	fff64613          	not	a2,a2
    80003e08:	00e50733          	add	a4,a0,a4
    80003e0c:	00c78633          	add	a2,a5,a2
    80003e10:	fff7c683          	lbu	a3,-1(a5)
    80003e14:	fff78793          	addi	a5,a5,-1
    80003e18:	fff70713          	addi	a4,a4,-1
    80003e1c:	00d70023          	sb	a3,0(a4)
    80003e20:	fec798e3          	bne	a5,a2,80003e10 <__memmove+0x12c>
    80003e24:	00813403          	ld	s0,8(sp)
    80003e28:	01010113          	addi	sp,sp,16
    80003e2c:	00008067          	ret
    80003e30:	02069713          	slli	a4,a3,0x20
    80003e34:	02075713          	srli	a4,a4,0x20
    80003e38:	00170713          	addi	a4,a4,1
    80003e3c:	00e50733          	add	a4,a0,a4
    80003e40:	00050793          	mv	a5,a0
    80003e44:	0005c683          	lbu	a3,0(a1)
    80003e48:	00178793          	addi	a5,a5,1
    80003e4c:	00158593          	addi	a1,a1,1
    80003e50:	fed78fa3          	sb	a3,-1(a5)
    80003e54:	fee798e3          	bne	a5,a4,80003e44 <__memmove+0x160>
    80003e58:	f89ff06f          	j	80003de0 <__memmove+0xfc>
	...
