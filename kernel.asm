
kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00006117          	auipc	sp,0x6
    80000004:	d7013103          	ld	sp,-656(sp) # 80005d70 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	00001537          	lui	a0,0x1
    8000000c:	f14025f3          	csrr	a1,mhartid
    80000010:	00158593          	addi	a1,a1,1
    80000014:	02b50533          	mul	a0,a0,a1
    80000018:	00a10133          	add	sp,sp,a0
    8000001c:	4cd020ef          	jal	ra,80002ce8 <start>

0000000080000020 <spin>:
    80000020:	0000006f          	j	80000020 <spin>
	...

0000000080001000 <copy_and_swap>:
# a1 holds expected value
# a2 holds desired value
# a0 holds return value, 0 if successful, !0 otherwise
.global copy_and_swap
copy_and_swap:
    lr.w t0, (a0)          # Load original value.
    80001000:	100522af          	lr.w	t0,(a0)
    bne t0, a1, fail       # Doesn’t match, so fail.
    80001004:	00b29a63          	bne	t0,a1,80001018 <fail>
    sc.w t0, a2, (a0)      # Try to update.
    80001008:	18c522af          	sc.w	t0,a2,(a0)
    bnez t0, copy_and_swap # Retry if store-conditional failed.
    8000100c:	fe029ae3          	bnez	t0,80001000 <copy_and_swap>
    li a0, 0               # Set return to success.
    80001010:	00000513          	li	a0,0
    jr ra                  # Return.
    80001014:	00008067          	ret

0000000080001018 <fail>:
    fail:
    li a0, 1               # Set return to failure.
    80001018:	00100513          	li	a0,1
    8000101c:	00008067          	ret

0000000080001020 <trapHandler>:
# s0-s11 ne cuvamo mi: njih po konvenciji cuva sam handleTrap ako ih koristi.

.align 4
.global trapHandler
trapHandler:
    addi sp, sp, -128      # 15 registara x 8B = 120, zaokruzeno na 128 (sp deljiv sa 16)
    80001020:	f8010113          	addi	sp,sp,-128
    sd ra, 0(sp)
    80001024:	00113023          	sd	ra,0(sp)
    sd t0, 8(sp)
    80001028:	00513423          	sd	t0,8(sp)
    sd t1, 16(sp)
    8000102c:	00613823          	sd	t1,16(sp)
    sd t2, 24(sp)
    80001030:	00713c23          	sd	t2,24(sp)
    sd t3, 32(sp)
    80001034:	03c13023          	sd	t3,32(sp)
    sd t4, 40(sp)
    80001038:	03d13423          	sd	t4,40(sp)
    sd t5, 48(sp)
    8000103c:	03e13823          	sd	t5,48(sp)
    sd t6, 56(sp)
    80001040:	03f13c23          	sd	t6,56(sp)
    sd a1, 64(sp)
    80001044:	04b13023          	sd	a1,64(sp)
    sd a2, 72(sp)
    80001048:	04c13423          	sd	a2,72(sp)
    sd a3, 80(sp)
    8000104c:	04d13823          	sd	a3,80(sp)
    sd a4, 88(sp)
    80001050:	04e13c23          	sd	a4,88(sp)
    sd a5, 96(sp)
    80001054:	06f13023          	sd	a5,96(sp)
    sd a6, 104(sp)
    80001058:	07013423          	sd	a6,104(sp)
    sd a7, 112(sp)
    8000105c:	07113823          	sd	a7,112(sp)

    call handleTrap        # a0..a3 = zateceni registri u trenutku trapa
    80001060:	1e4010ef          	jal	ra,80002244 <handleTrap>

    ld ra, 0(sp)
    80001064:	00013083          	ld	ra,0(sp)
    ld t0, 8(sp)
    80001068:	00813283          	ld	t0,8(sp)
    ld t1, 16(sp)
    8000106c:	01013303          	ld	t1,16(sp)
    ld t2, 24(sp)
    80001070:	01813383          	ld	t2,24(sp)
    ld t3, 32(sp)
    80001074:	02013e03          	ld	t3,32(sp)
    ld t4, 40(sp)
    80001078:	02813e83          	ld	t4,40(sp)
    ld t5, 48(sp)
    8000107c:	03013f03          	ld	t5,48(sp)
    ld t6, 56(sp)
    80001080:	03813f83          	ld	t6,56(sp)
    ld a1, 64(sp)
    80001084:	04013583          	ld	a1,64(sp)
    ld a2, 72(sp)
    80001088:	04813603          	ld	a2,72(sp)
    ld a3, 80(sp)
    8000108c:	05013683          	ld	a3,80(sp)
    ld a4, 88(sp)
    80001090:	05813703          	ld	a4,88(sp)
    ld a5, 96(sp)
    80001094:	06013783          	ld	a5,96(sp)
    ld a6, 104(sp)
    80001098:	06813803          	ld	a6,104(sp)
    ld a7, 112(sp)
    8000109c:	07013883          	ld	a7,112(sp)
    addi sp, sp, 128
    800010a0:	08010113          	addi	sp,sp,128
    sret
    800010a4:	10200073          	sret
	...

00000000800010b0 <contextSwitch>:
# paznja: raspored polja mora da se poklapa sa strukturom Context u tcb.hpp
# (ra na pomeraju 0, sp na pomeraju 8).

.global contextSwitch
contextSwitch:
    addi sp, sp, -96       # mesto za 12 s-registara (12 x 8B)
    800010b0:	fa010113          	addi	sp,sp,-96
    sd s0, 0(sp)
    800010b4:	00813023          	sd	s0,0(sp)
    sd s1, 8(sp)
    800010b8:	00913423          	sd	s1,8(sp)
    sd s2, 16(sp)
    800010bc:	01213823          	sd	s2,16(sp)
    sd s3, 24(sp)
    800010c0:	01313c23          	sd	s3,24(sp)
    sd s4, 32(sp)
    800010c4:	03413023          	sd	s4,32(sp)
    sd s5, 40(sp)
    800010c8:	03513423          	sd	s5,40(sp)
    sd s6, 48(sp)
    800010cc:	03613823          	sd	s6,48(sp)
    sd s7, 56(sp)
    800010d0:	03713c23          	sd	s7,56(sp)
    sd s8, 64(sp)
    800010d4:	05813023          	sd	s8,64(sp)
    sd s9, 72(sp)
    800010d8:	05913423          	sd	s9,72(sp)
    sd s10, 80(sp)
    800010dc:	05a13823          	sd	s10,80(sp)
    sd s11, 88(sp)
    800010e0:	05b13c23          	sd	s11,88(sp)

    sd ra, 0(a0)           # stara nit: gde da nastavi kad se probudi
    800010e4:	00153023          	sd	ra,0(a0) # 1000 <_entry-0x7ffff000>
    sd sp, 8(a0)           # stara nit: rucka kofera        == zamrznuta
    800010e8:	00253423          	sd	sp,8(a0)

    ld ra, 0(a1)           # nova nit: odakle nastavlja
    800010ec:	0005b083          	ld	ra,0(a1)
    ld sp, 8(a1)           # nova nit: njen stek            == budi se
    800010f0:	0085b103          	ld	sp,8(a1)

    ld s0, 0(sp)
    800010f4:	00013403          	ld	s0,0(sp)
    ld s1, 8(sp)
    800010f8:	00813483          	ld	s1,8(sp)
    ld s2, 16(sp)
    800010fc:	01013903          	ld	s2,16(sp)
    ld s3, 24(sp)
    80001100:	01813983          	ld	s3,24(sp)
    ld s4, 32(sp)
    80001104:	02013a03          	ld	s4,32(sp)
    ld s5, 40(sp)
    80001108:	02813a83          	ld	s5,40(sp)
    ld s6, 48(sp)
    8000110c:	03013b03          	ld	s6,48(sp)
    ld s7, 56(sp)
    80001110:	03813b83          	ld	s7,56(sp)
    ld s8, 64(sp)
    80001114:	04013c03          	ld	s8,64(sp)
    ld s9, 72(sp)
    80001118:	04813c83          	ld	s9,72(sp)
    ld s10, 80(sp)
    8000111c:	05013d03          	ld	s10,80(sp)
    ld s11, 88(sp)
    80001120:	05813d83          	ld	s11,88(sp)
    addi sp, sp, 96
    80001124:	06010113          	addi	sp,sp,96
    ret                    # skok na ra nove niti: usao kao stara, izasao kao nova
    80001128:	00008067          	ret

000000008000112c <_ZL9fibonaccim>:
static volatile bool finishedA = false;
static volatile bool finishedB = false;
static volatile bool finishedC = false;
static volatile bool finishedD = false;

static uint64 fibonacci(uint64 n) {
    8000112c:	fe010113          	addi	sp,sp,-32
    80001130:	00113c23          	sd	ra,24(sp)
    80001134:	00813823          	sd	s0,16(sp)
    80001138:	00913423          	sd	s1,8(sp)
    8000113c:	01213023          	sd	s2,0(sp)
    80001140:	02010413          	addi	s0,sp,32
    80001144:	00050493          	mv	s1,a0
    if (n == 0 || n == 1) { return n; }
    80001148:	00100793          	li	a5,1
    8000114c:	02a7f863          	bgeu	a5,a0,8000117c <_ZL9fibonaccim+0x50>
    if (n % 10 == 0) { thread_dispatch(); }
    80001150:	00a00793          	li	a5,10
    80001154:	02f577b3          	remu	a5,a0,a5
    80001158:	02078e63          	beqz	a5,80001194 <_ZL9fibonaccim+0x68>
    return fibonacci(n - 1) + fibonacci(n - 2);
    8000115c:	fff48513          	addi	a0,s1,-1
    80001160:	00000097          	auipc	ra,0x0
    80001164:	fcc080e7          	jalr	-52(ra) # 8000112c <_ZL9fibonaccim>
    80001168:	00050913          	mv	s2,a0
    8000116c:	ffe48513          	addi	a0,s1,-2
    80001170:	00000097          	auipc	ra,0x0
    80001174:	fbc080e7          	jalr	-68(ra) # 8000112c <_ZL9fibonaccim>
    80001178:	00a90533          	add	a0,s2,a0
}
    8000117c:	01813083          	ld	ra,24(sp)
    80001180:	01013403          	ld	s0,16(sp)
    80001184:	00813483          	ld	s1,8(sp)
    80001188:	00013903          	ld	s2,0(sp)
    8000118c:	02010113          	addi	sp,sp,32
    80001190:	00008067          	ret
    if (n % 10 == 0) { thread_dispatch(); }
    80001194:	00001097          	auipc	ra,0x1
    80001198:	f50080e7          	jalr	-176(ra) # 800020e4 <_Z15thread_dispatchv>
    8000119c:	fc1ff06f          	j	8000115c <_ZL9fibonaccim+0x30>

00000000800011a0 <_ZL11workerBodyDPv>:
    printString("A finished!\n");
    finishedC = true;
    thread_dispatch();
}

static void workerBodyD(void* arg) {
    800011a0:	fe010113          	addi	sp,sp,-32
    800011a4:	00113c23          	sd	ra,24(sp)
    800011a8:	00813823          	sd	s0,16(sp)
    800011ac:	00913423          	sd	s1,8(sp)
    800011b0:	01213023          	sd	s2,0(sp)
    800011b4:	02010413          	addi	s0,sp,32
    uint8 i = 10;
    800011b8:	00a00493          	li	s1,10
    800011bc:	0400006f          	j	800011fc <_ZL11workerBodyDPv+0x5c>
    for (; i < 13; i++) {
        printString("D: i="); printInt(i); printString("\n");
    800011c0:	00004517          	auipc	a0,0x4
    800011c4:	e6050513          	addi	a0,a0,-416 # 80005020 <CONSOLE_STATUS+0x10>
    800011c8:	00000097          	auipc	ra,0x0
    800011cc:	53c080e7          	jalr	1340(ra) # 80001704 <_Z11printStringPKc>
    800011d0:	00000613          	li	a2,0
    800011d4:	00a00593          	li	a1,10
    800011d8:	00048513          	mv	a0,s1
    800011dc:	00000097          	auipc	ra,0x0
    800011e0:	6d8080e7          	jalr	1752(ra) # 800018b4 <_Z8printIntiii>
    800011e4:	00004517          	auipc	a0,0x4
    800011e8:	2e450513          	addi	a0,a0,740 # 800054c8 <CONSOLE_STATUS+0x4b8>
    800011ec:	00000097          	auipc	ra,0x0
    800011f0:	518080e7          	jalr	1304(ra) # 80001704 <_Z11printStringPKc>
    for (; i < 13; i++) {
    800011f4:	0014849b          	addiw	s1,s1,1
    800011f8:	0ff4f493          	andi	s1,s1,255
    800011fc:	00c00793          	li	a5,12
    80001200:	fc97f0e3          	bgeu	a5,s1,800011c0 <_ZL11workerBodyDPv+0x20>
    }

    printString("D: dispatch\n");
    80001204:	00004517          	auipc	a0,0x4
    80001208:	e2450513          	addi	a0,a0,-476 # 80005028 <CONSOLE_STATUS+0x18>
    8000120c:	00000097          	auipc	ra,0x0
    80001210:	4f8080e7          	jalr	1272(ra) # 80001704 <_Z11printStringPKc>
    __asm__ ("li t1, 5");
    80001214:	00500313          	li	t1,5
    thread_dispatch();
    80001218:	00001097          	auipc	ra,0x1
    8000121c:	ecc080e7          	jalr	-308(ra) # 800020e4 <_Z15thread_dispatchv>

    uint64 result = fibonacci(16);
    80001220:	01000513          	li	a0,16
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f08080e7          	jalr	-248(ra) # 8000112c <_ZL9fibonaccim>
    8000122c:	00050913          	mv	s2,a0
    printString("D: fibonaci="); printInt(result); printString("\n");
    80001230:	00004517          	auipc	a0,0x4
    80001234:	e0850513          	addi	a0,a0,-504 # 80005038 <CONSOLE_STATUS+0x28>
    80001238:	00000097          	auipc	ra,0x0
    8000123c:	4cc080e7          	jalr	1228(ra) # 80001704 <_Z11printStringPKc>
    80001240:	00000613          	li	a2,0
    80001244:	00a00593          	li	a1,10
    80001248:	0009051b          	sext.w	a0,s2
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	668080e7          	jalr	1640(ra) # 800018b4 <_Z8printIntiii>
    80001254:	00004517          	auipc	a0,0x4
    80001258:	27450513          	addi	a0,a0,628 # 800054c8 <CONSOLE_STATUS+0x4b8>
    8000125c:	00000097          	auipc	ra,0x0
    80001260:	4a8080e7          	jalr	1192(ra) # 80001704 <_Z11printStringPKc>
    80001264:	0400006f          	j	800012a4 <_ZL11workerBodyDPv+0x104>

    for (; i < 16; i++) {
        printString("D: i="); printInt(i); printString("\n");
    80001268:	00004517          	auipc	a0,0x4
    8000126c:	db850513          	addi	a0,a0,-584 # 80005020 <CONSOLE_STATUS+0x10>
    80001270:	00000097          	auipc	ra,0x0
    80001274:	494080e7          	jalr	1172(ra) # 80001704 <_Z11printStringPKc>
    80001278:	00000613          	li	a2,0
    8000127c:	00a00593          	li	a1,10
    80001280:	00048513          	mv	a0,s1
    80001284:	00000097          	auipc	ra,0x0
    80001288:	630080e7          	jalr	1584(ra) # 800018b4 <_Z8printIntiii>
    8000128c:	00004517          	auipc	a0,0x4
    80001290:	23c50513          	addi	a0,a0,572 # 800054c8 <CONSOLE_STATUS+0x4b8>
    80001294:	00000097          	auipc	ra,0x0
    80001298:	470080e7          	jalr	1136(ra) # 80001704 <_Z11printStringPKc>
    for (; i < 16; i++) {
    8000129c:	0014849b          	addiw	s1,s1,1
    800012a0:	0ff4f493          	andi	s1,s1,255
    800012a4:	00f00793          	li	a5,15
    800012a8:	fc97f0e3          	bgeu	a5,s1,80001268 <_ZL11workerBodyDPv+0xc8>
    }

    printString("D finished!\n");
    800012ac:	00004517          	auipc	a0,0x4
    800012b0:	d9c50513          	addi	a0,a0,-612 # 80005048 <CONSOLE_STATUS+0x38>
    800012b4:	00000097          	auipc	ra,0x0
    800012b8:	450080e7          	jalr	1104(ra) # 80001704 <_Z11printStringPKc>
    finishedD = true;
    800012bc:	00100793          	li	a5,1
    800012c0:	00005717          	auipc	a4,0x5
    800012c4:	acf70823          	sb	a5,-1328(a4) # 80005d90 <_ZL9finishedD>
    thread_dispatch();
    800012c8:	00001097          	auipc	ra,0x1
    800012cc:	e1c080e7          	jalr	-484(ra) # 800020e4 <_Z15thread_dispatchv>
}
    800012d0:	01813083          	ld	ra,24(sp)
    800012d4:	01013403          	ld	s0,16(sp)
    800012d8:	00813483          	ld	s1,8(sp)
    800012dc:	00013903          	ld	s2,0(sp)
    800012e0:	02010113          	addi	sp,sp,32
    800012e4:	00008067          	ret

00000000800012e8 <_ZL11workerBodyCPv>:
static void workerBodyC(void* arg) {
    800012e8:	fe010113          	addi	sp,sp,-32
    800012ec:	00113c23          	sd	ra,24(sp)
    800012f0:	00813823          	sd	s0,16(sp)
    800012f4:	00913423          	sd	s1,8(sp)
    800012f8:	01213023          	sd	s2,0(sp)
    800012fc:	02010413          	addi	s0,sp,32
    uint8 i = 0;
    80001300:	00000493          	li	s1,0
    80001304:	0400006f          	j	80001344 <_ZL11workerBodyCPv+0x5c>
        printString("C: i="); printInt(i); printString("\n");
    80001308:	00004517          	auipc	a0,0x4
    8000130c:	d5050513          	addi	a0,a0,-688 # 80005058 <CONSOLE_STATUS+0x48>
    80001310:	00000097          	auipc	ra,0x0
    80001314:	3f4080e7          	jalr	1012(ra) # 80001704 <_Z11printStringPKc>
    80001318:	00000613          	li	a2,0
    8000131c:	00a00593          	li	a1,10
    80001320:	00048513          	mv	a0,s1
    80001324:	00000097          	auipc	ra,0x0
    80001328:	590080e7          	jalr	1424(ra) # 800018b4 <_Z8printIntiii>
    8000132c:	00004517          	auipc	a0,0x4
    80001330:	19c50513          	addi	a0,a0,412 # 800054c8 <CONSOLE_STATUS+0x4b8>
    80001334:	00000097          	auipc	ra,0x0
    80001338:	3d0080e7          	jalr	976(ra) # 80001704 <_Z11printStringPKc>
    for (; i < 3; i++) {
    8000133c:	0014849b          	addiw	s1,s1,1
    80001340:	0ff4f493          	andi	s1,s1,255
    80001344:	00200793          	li	a5,2
    80001348:	fc97f0e3          	bgeu	a5,s1,80001308 <_ZL11workerBodyCPv+0x20>
    printString("C: dispatch\n");
    8000134c:	00004517          	auipc	a0,0x4
    80001350:	d1450513          	addi	a0,a0,-748 # 80005060 <CONSOLE_STATUS+0x50>
    80001354:	00000097          	auipc	ra,0x0
    80001358:	3b0080e7          	jalr	944(ra) # 80001704 <_Z11printStringPKc>
    __asm__ ("li t1, 7");
    8000135c:	00700313          	li	t1,7
    thread_dispatch();
    80001360:	00001097          	auipc	ra,0x1
    80001364:	d84080e7          	jalr	-636(ra) # 800020e4 <_Z15thread_dispatchv>
    __asm__ ("mv %[t1], t1" : [t1] "=r"(t1));
    80001368:	00030913          	mv	s2,t1
    printString("C: t1="); printInt(t1); printString("\n");
    8000136c:	00004517          	auipc	a0,0x4
    80001370:	d0450513          	addi	a0,a0,-764 # 80005070 <CONSOLE_STATUS+0x60>
    80001374:	00000097          	auipc	ra,0x0
    80001378:	390080e7          	jalr	912(ra) # 80001704 <_Z11printStringPKc>
    8000137c:	00000613          	li	a2,0
    80001380:	00a00593          	li	a1,10
    80001384:	0009051b          	sext.w	a0,s2
    80001388:	00000097          	auipc	ra,0x0
    8000138c:	52c080e7          	jalr	1324(ra) # 800018b4 <_Z8printIntiii>
    80001390:	00004517          	auipc	a0,0x4
    80001394:	13850513          	addi	a0,a0,312 # 800054c8 <CONSOLE_STATUS+0x4b8>
    80001398:	00000097          	auipc	ra,0x0
    8000139c:	36c080e7          	jalr	876(ra) # 80001704 <_Z11printStringPKc>
    uint64 result = fibonacci(12);
    800013a0:	00c00513          	li	a0,12
    800013a4:	00000097          	auipc	ra,0x0
    800013a8:	d88080e7          	jalr	-632(ra) # 8000112c <_ZL9fibonaccim>
    800013ac:	00050913          	mv	s2,a0
    printString("C: fibonaci="); printInt(result); printString("\n");
    800013b0:	00004517          	auipc	a0,0x4
    800013b4:	cc850513          	addi	a0,a0,-824 # 80005078 <CONSOLE_STATUS+0x68>
    800013b8:	00000097          	auipc	ra,0x0
    800013bc:	34c080e7          	jalr	844(ra) # 80001704 <_Z11printStringPKc>
    800013c0:	00000613          	li	a2,0
    800013c4:	00a00593          	li	a1,10
    800013c8:	0009051b          	sext.w	a0,s2
    800013cc:	00000097          	auipc	ra,0x0
    800013d0:	4e8080e7          	jalr	1256(ra) # 800018b4 <_Z8printIntiii>
    800013d4:	00004517          	auipc	a0,0x4
    800013d8:	0f450513          	addi	a0,a0,244 # 800054c8 <CONSOLE_STATUS+0x4b8>
    800013dc:	00000097          	auipc	ra,0x0
    800013e0:	328080e7          	jalr	808(ra) # 80001704 <_Z11printStringPKc>
    800013e4:	0400006f          	j	80001424 <_ZL11workerBodyCPv+0x13c>
        printString("C: i="); printInt(i); printString("\n");
    800013e8:	00004517          	auipc	a0,0x4
    800013ec:	c7050513          	addi	a0,a0,-912 # 80005058 <CONSOLE_STATUS+0x48>
    800013f0:	00000097          	auipc	ra,0x0
    800013f4:	314080e7          	jalr	788(ra) # 80001704 <_Z11printStringPKc>
    800013f8:	00000613          	li	a2,0
    800013fc:	00a00593          	li	a1,10
    80001400:	00048513          	mv	a0,s1
    80001404:	00000097          	auipc	ra,0x0
    80001408:	4b0080e7          	jalr	1200(ra) # 800018b4 <_Z8printIntiii>
    8000140c:	00004517          	auipc	a0,0x4
    80001410:	0bc50513          	addi	a0,a0,188 # 800054c8 <CONSOLE_STATUS+0x4b8>
    80001414:	00000097          	auipc	ra,0x0
    80001418:	2f0080e7          	jalr	752(ra) # 80001704 <_Z11printStringPKc>
    for (; i < 6; i++) {
    8000141c:	0014849b          	addiw	s1,s1,1
    80001420:	0ff4f493          	andi	s1,s1,255
    80001424:	00500793          	li	a5,5
    80001428:	fc97f0e3          	bgeu	a5,s1,800013e8 <_ZL11workerBodyCPv+0x100>
    printString("A finished!\n");
    8000142c:	00004517          	auipc	a0,0x4
    80001430:	c5c50513          	addi	a0,a0,-932 # 80005088 <CONSOLE_STATUS+0x78>
    80001434:	00000097          	auipc	ra,0x0
    80001438:	2d0080e7          	jalr	720(ra) # 80001704 <_Z11printStringPKc>
    finishedC = true;
    8000143c:	00100793          	li	a5,1
    80001440:	00005717          	auipc	a4,0x5
    80001444:	94f708a3          	sb	a5,-1711(a4) # 80005d91 <_ZL9finishedC>
    thread_dispatch();
    80001448:	00001097          	auipc	ra,0x1
    8000144c:	c9c080e7          	jalr	-868(ra) # 800020e4 <_Z15thread_dispatchv>
}
    80001450:	01813083          	ld	ra,24(sp)
    80001454:	01013403          	ld	s0,16(sp)
    80001458:	00813483          	ld	s1,8(sp)
    8000145c:	00013903          	ld	s2,0(sp)
    80001460:	02010113          	addi	sp,sp,32
    80001464:	00008067          	ret

0000000080001468 <_ZL11workerBodyBPv>:
static void workerBodyB(void* arg) {
    80001468:	fe010113          	addi	sp,sp,-32
    8000146c:	00113c23          	sd	ra,24(sp)
    80001470:	00813823          	sd	s0,16(sp)
    80001474:	00913423          	sd	s1,8(sp)
    80001478:	01213023          	sd	s2,0(sp)
    8000147c:	02010413          	addi	s0,sp,32
    for (uint64 i = 0; i < 16; i++) {
    80001480:	00000913          	li	s2,0
    80001484:	0380006f          	j	800014bc <_ZL11workerBodyBPv+0x54>
            thread_dispatch();
    80001488:	00001097          	auipc	ra,0x1
    8000148c:	c5c080e7          	jalr	-932(ra) # 800020e4 <_Z15thread_dispatchv>
        for (uint64 j = 0; j < 10000; j++) {
    80001490:	00148493          	addi	s1,s1,1
    80001494:	000027b7          	lui	a5,0x2
    80001498:	70f78793          	addi	a5,a5,1807 # 270f <_entry-0x7fffd8f1>
    8000149c:	0097ee63          	bltu	a5,s1,800014b8 <_ZL11workerBodyBPv+0x50>
            for (uint64 k = 0; k < 30000; k++) { /* busy wait */ }
    800014a0:	00000713          	li	a4,0
    800014a4:	000077b7          	lui	a5,0x7
    800014a8:	52f78793          	addi	a5,a5,1327 # 752f <_entry-0x7fff8ad1>
    800014ac:	fce7eee3          	bltu	a5,a4,80001488 <_ZL11workerBodyBPv+0x20>
    800014b0:	00170713          	addi	a4,a4,1
    800014b4:	ff1ff06f          	j	800014a4 <_ZL11workerBodyBPv+0x3c>
    for (uint64 i = 0; i < 16; i++) {
    800014b8:	00190913          	addi	s2,s2,1
    800014bc:	00f00793          	li	a5,15
    800014c0:	0527e063          	bltu	a5,s2,80001500 <_ZL11workerBodyBPv+0x98>
        printString("B: i="); printInt(i); printString("\n");
    800014c4:	00004517          	auipc	a0,0x4
    800014c8:	bd450513          	addi	a0,a0,-1068 # 80005098 <CONSOLE_STATUS+0x88>
    800014cc:	00000097          	auipc	ra,0x0
    800014d0:	238080e7          	jalr	568(ra) # 80001704 <_Z11printStringPKc>
    800014d4:	00000613          	li	a2,0
    800014d8:	00a00593          	li	a1,10
    800014dc:	0009051b          	sext.w	a0,s2
    800014e0:	00000097          	auipc	ra,0x0
    800014e4:	3d4080e7          	jalr	980(ra) # 800018b4 <_Z8printIntiii>
    800014e8:	00004517          	auipc	a0,0x4
    800014ec:	fe050513          	addi	a0,a0,-32 # 800054c8 <CONSOLE_STATUS+0x4b8>
    800014f0:	00000097          	auipc	ra,0x0
    800014f4:	214080e7          	jalr	532(ra) # 80001704 <_Z11printStringPKc>
        for (uint64 j = 0; j < 10000; j++) {
    800014f8:	00000493          	li	s1,0
    800014fc:	f99ff06f          	j	80001494 <_ZL11workerBodyBPv+0x2c>
    printString("B finished!\n");
    80001500:	00004517          	auipc	a0,0x4
    80001504:	ba050513          	addi	a0,a0,-1120 # 800050a0 <CONSOLE_STATUS+0x90>
    80001508:	00000097          	auipc	ra,0x0
    8000150c:	1fc080e7          	jalr	508(ra) # 80001704 <_Z11printStringPKc>
    finishedB = true;
    80001510:	00100793          	li	a5,1
    80001514:	00005717          	auipc	a4,0x5
    80001518:	86f70f23          	sb	a5,-1922(a4) # 80005d92 <_ZL9finishedB>
    thread_dispatch();
    8000151c:	00001097          	auipc	ra,0x1
    80001520:	bc8080e7          	jalr	-1080(ra) # 800020e4 <_Z15thread_dispatchv>
}
    80001524:	01813083          	ld	ra,24(sp)
    80001528:	01013403          	ld	s0,16(sp)
    8000152c:	00813483          	ld	s1,8(sp)
    80001530:	00013903          	ld	s2,0(sp)
    80001534:	02010113          	addi	sp,sp,32
    80001538:	00008067          	ret

000000008000153c <_ZL11workerBodyAPv>:
static void workerBodyA(void* arg) {
    8000153c:	fe010113          	addi	sp,sp,-32
    80001540:	00113c23          	sd	ra,24(sp)
    80001544:	00813823          	sd	s0,16(sp)
    80001548:	00913423          	sd	s1,8(sp)
    8000154c:	01213023          	sd	s2,0(sp)
    80001550:	02010413          	addi	s0,sp,32
    for (uint64 i = 0; i < 10; i++) {
    80001554:	00000913          	li	s2,0
    80001558:	0380006f          	j	80001590 <_ZL11workerBodyAPv+0x54>
            thread_dispatch();
    8000155c:	00001097          	auipc	ra,0x1
    80001560:	b88080e7          	jalr	-1144(ra) # 800020e4 <_Z15thread_dispatchv>
        for (uint64 j = 0; j < 10000; j++) {
    80001564:	00148493          	addi	s1,s1,1
    80001568:	000027b7          	lui	a5,0x2
    8000156c:	70f78793          	addi	a5,a5,1807 # 270f <_entry-0x7fffd8f1>
    80001570:	0097ee63          	bltu	a5,s1,8000158c <_ZL11workerBodyAPv+0x50>
            for (uint64 k = 0; k < 30000; k++) { /* busy wait */ }
    80001574:	00000713          	li	a4,0
    80001578:	000077b7          	lui	a5,0x7
    8000157c:	52f78793          	addi	a5,a5,1327 # 752f <_entry-0x7fff8ad1>
    80001580:	fce7eee3          	bltu	a5,a4,8000155c <_ZL11workerBodyAPv+0x20>
    80001584:	00170713          	addi	a4,a4,1
    80001588:	ff1ff06f          	j	80001578 <_ZL11workerBodyAPv+0x3c>
    for (uint64 i = 0; i < 10; i++) {
    8000158c:	00190913          	addi	s2,s2,1
    80001590:	00900793          	li	a5,9
    80001594:	0527e063          	bltu	a5,s2,800015d4 <_ZL11workerBodyAPv+0x98>
        printString("A: i="); printInt(i); printString("\n");
    80001598:	00004517          	auipc	a0,0x4
    8000159c:	b1850513          	addi	a0,a0,-1256 # 800050b0 <CONSOLE_STATUS+0xa0>
    800015a0:	00000097          	auipc	ra,0x0
    800015a4:	164080e7          	jalr	356(ra) # 80001704 <_Z11printStringPKc>
    800015a8:	00000613          	li	a2,0
    800015ac:	00a00593          	li	a1,10
    800015b0:	0009051b          	sext.w	a0,s2
    800015b4:	00000097          	auipc	ra,0x0
    800015b8:	300080e7          	jalr	768(ra) # 800018b4 <_Z8printIntiii>
    800015bc:	00004517          	auipc	a0,0x4
    800015c0:	f0c50513          	addi	a0,a0,-244 # 800054c8 <CONSOLE_STATUS+0x4b8>
    800015c4:	00000097          	auipc	ra,0x0
    800015c8:	140080e7          	jalr	320(ra) # 80001704 <_Z11printStringPKc>
        for (uint64 j = 0; j < 10000; j++) {
    800015cc:	00000493          	li	s1,0
    800015d0:	f99ff06f          	j	80001568 <_ZL11workerBodyAPv+0x2c>
    printString("A finished!\n");
    800015d4:	00004517          	auipc	a0,0x4
    800015d8:	ab450513          	addi	a0,a0,-1356 # 80005088 <CONSOLE_STATUS+0x78>
    800015dc:	00000097          	auipc	ra,0x0
    800015e0:	128080e7          	jalr	296(ra) # 80001704 <_Z11printStringPKc>
    finishedA = true;
    800015e4:	00100793          	li	a5,1
    800015e8:	00004717          	auipc	a4,0x4
    800015ec:	7af705a3          	sb	a5,1963(a4) # 80005d93 <_ZL9finishedA>
}
    800015f0:	01813083          	ld	ra,24(sp)
    800015f4:	01013403          	ld	s0,16(sp)
    800015f8:	00813483          	ld	s1,8(sp)
    800015fc:	00013903          	ld	s2,0(sp)
    80001600:	02010113          	addi	sp,sp,32
    80001604:	00008067          	ret

0000000080001608 <_Z18Threads_C_API_testv>:


void Threads_C_API_test() {
    80001608:	fd010113          	addi	sp,sp,-48
    8000160c:	02113423          	sd	ra,40(sp)
    80001610:	02813023          	sd	s0,32(sp)
    80001614:	03010413          	addi	s0,sp,48
    thread_t threads[4];
    thread_create(&threads[0], workerBodyA, nullptr);
    80001618:	00000613          	li	a2,0
    8000161c:	00000597          	auipc	a1,0x0
    80001620:	f2058593          	addi	a1,a1,-224 # 8000153c <_ZL11workerBodyAPv>
    80001624:	fd040513          	addi	a0,s0,-48
    80001628:	00001097          	auipc	ra,0x1
    8000162c:	9f0080e7          	jalr	-1552(ra) # 80002018 <_Z13thread_createPP7_threadPFvPvES2_>
    printString("ThreadA created\n");
    80001630:	00004517          	auipc	a0,0x4
    80001634:	a8850513          	addi	a0,a0,-1400 # 800050b8 <CONSOLE_STATUS+0xa8>
    80001638:	00000097          	auipc	ra,0x0
    8000163c:	0cc080e7          	jalr	204(ra) # 80001704 <_Z11printStringPKc>

    thread_create(&threads[1], workerBodyB, nullptr);
    80001640:	00000613          	li	a2,0
    80001644:	00000597          	auipc	a1,0x0
    80001648:	e2458593          	addi	a1,a1,-476 # 80001468 <_ZL11workerBodyBPv>
    8000164c:	fd840513          	addi	a0,s0,-40
    80001650:	00001097          	auipc	ra,0x1
    80001654:	9c8080e7          	jalr	-1592(ra) # 80002018 <_Z13thread_createPP7_threadPFvPvES2_>
    printString("ThreadB created\n");
    80001658:	00004517          	auipc	a0,0x4
    8000165c:	a7850513          	addi	a0,a0,-1416 # 800050d0 <CONSOLE_STATUS+0xc0>
    80001660:	00000097          	auipc	ra,0x0
    80001664:	0a4080e7          	jalr	164(ra) # 80001704 <_Z11printStringPKc>

    thread_create(&threads[2], workerBodyC, nullptr);
    80001668:	00000613          	li	a2,0
    8000166c:	00000597          	auipc	a1,0x0
    80001670:	c7c58593          	addi	a1,a1,-900 # 800012e8 <_ZL11workerBodyCPv>
    80001674:	fe040513          	addi	a0,s0,-32
    80001678:	00001097          	auipc	ra,0x1
    8000167c:	9a0080e7          	jalr	-1632(ra) # 80002018 <_Z13thread_createPP7_threadPFvPvES2_>
    printString("ThreadC created\n");
    80001680:	00004517          	auipc	a0,0x4
    80001684:	a6850513          	addi	a0,a0,-1432 # 800050e8 <CONSOLE_STATUS+0xd8>
    80001688:	00000097          	auipc	ra,0x0
    8000168c:	07c080e7          	jalr	124(ra) # 80001704 <_Z11printStringPKc>

    thread_create(&threads[3], workerBodyD, nullptr);
    80001690:	00000613          	li	a2,0
    80001694:	00000597          	auipc	a1,0x0
    80001698:	b0c58593          	addi	a1,a1,-1268 # 800011a0 <_ZL11workerBodyDPv>
    8000169c:	fe840513          	addi	a0,s0,-24
    800016a0:	00001097          	auipc	ra,0x1
    800016a4:	978080e7          	jalr	-1672(ra) # 80002018 <_Z13thread_createPP7_threadPFvPvES2_>
    printString("ThreadD created\n");
    800016a8:	00004517          	auipc	a0,0x4
    800016ac:	a5850513          	addi	a0,a0,-1448 # 80005100 <CONSOLE_STATUS+0xf0>
    800016b0:	00000097          	auipc	ra,0x0
    800016b4:	054080e7          	jalr	84(ra) # 80001704 <_Z11printStringPKc>
    800016b8:	00c0006f          	j	800016c4 <_Z18Threads_C_API_testv+0xbc>

    while (!(finishedA && finishedB && finishedC && finishedD)) {
        thread_dispatch();
    800016bc:	00001097          	auipc	ra,0x1
    800016c0:	a28080e7          	jalr	-1496(ra) # 800020e4 <_Z15thread_dispatchv>
    while (!(finishedA && finishedB && finishedC && finishedD)) {
    800016c4:	00004797          	auipc	a5,0x4
    800016c8:	6cf7c783          	lbu	a5,1743(a5) # 80005d93 <_ZL9finishedA>
    800016cc:	fe0788e3          	beqz	a5,800016bc <_Z18Threads_C_API_testv+0xb4>
    800016d0:	00004797          	auipc	a5,0x4
    800016d4:	6c27c783          	lbu	a5,1730(a5) # 80005d92 <_ZL9finishedB>
    800016d8:	fe0782e3          	beqz	a5,800016bc <_Z18Threads_C_API_testv+0xb4>
    800016dc:	00004797          	auipc	a5,0x4
    800016e0:	6b57c783          	lbu	a5,1717(a5) # 80005d91 <_ZL9finishedC>
    800016e4:	fc078ce3          	beqz	a5,800016bc <_Z18Threads_C_API_testv+0xb4>
    800016e8:	00004797          	auipc	a5,0x4
    800016ec:	6a87c783          	lbu	a5,1704(a5) # 80005d90 <_ZL9finishedD>
    800016f0:	fc0786e3          	beqz	a5,800016bc <_Z18Threads_C_API_testv+0xb4>
    }

}
    800016f4:	02813083          	ld	ra,40(sp)
    800016f8:	02013403          	ld	s0,32(sp)
    800016fc:	03010113          	addi	sp,sp,48
    80001700:	00008067          	ret

0000000080001704 <_Z11printStringPKc>:

#define LOCK() while(copy_and_swap(lockPrint, 0, 1)) thread_dispatch()
#define UNLOCK() while(copy_and_swap(lockPrint, 1, 0))

void printString(char const *string)
{
    80001704:	fe010113          	addi	sp,sp,-32
    80001708:	00113c23          	sd	ra,24(sp)
    8000170c:	00813823          	sd	s0,16(sp)
    80001710:	00913423          	sd	s1,8(sp)
    80001714:	02010413          	addi	s0,sp,32
    80001718:	00050493          	mv	s1,a0
    LOCK();
    8000171c:	00100613          	li	a2,1
    80001720:	00000593          	li	a1,0
    80001724:	00004517          	auipc	a0,0x4
    80001728:	67450513          	addi	a0,a0,1652 # 80005d98 <lockPrint>
    8000172c:	00000097          	auipc	ra,0x0
    80001730:	8d4080e7          	jalr	-1836(ra) # 80001000 <copy_and_swap>
    80001734:	00050863          	beqz	a0,80001744 <_Z11printStringPKc+0x40>
    80001738:	00001097          	auipc	ra,0x1
    8000173c:	9ac080e7          	jalr	-1620(ra) # 800020e4 <_Z15thread_dispatchv>
    80001740:	fddff06f          	j	8000171c <_Z11printStringPKc+0x18>
    while (*string != '\0')
    80001744:	0004c503          	lbu	a0,0(s1)
    80001748:	00050a63          	beqz	a0,8000175c <_Z11printStringPKc+0x58>
    {
        putc(*string);
    8000174c:	00001097          	auipc	ra,0x1
    80001750:	9dc080e7          	jalr	-1572(ra) # 80002128 <_Z4putcc>
        string++;
    80001754:	00148493          	addi	s1,s1,1
    while (*string != '\0')
    80001758:	fedff06f          	j	80001744 <_Z11printStringPKc+0x40>
    }
    UNLOCK();
    8000175c:	00000613          	li	a2,0
    80001760:	00100593          	li	a1,1
    80001764:	00004517          	auipc	a0,0x4
    80001768:	63450513          	addi	a0,a0,1588 # 80005d98 <lockPrint>
    8000176c:	00000097          	auipc	ra,0x0
    80001770:	894080e7          	jalr	-1900(ra) # 80001000 <copy_and_swap>
    80001774:	fe0514e3          	bnez	a0,8000175c <_Z11printStringPKc+0x58>
}
    80001778:	01813083          	ld	ra,24(sp)
    8000177c:	01013403          	ld	s0,16(sp)
    80001780:	00813483          	ld	s1,8(sp)
    80001784:	02010113          	addi	sp,sp,32
    80001788:	00008067          	ret

000000008000178c <_Z9getStringPci>:

char* getString(char *buf, int max) {
    8000178c:	fd010113          	addi	sp,sp,-48
    80001790:	02113423          	sd	ra,40(sp)
    80001794:	02813023          	sd	s0,32(sp)
    80001798:	00913c23          	sd	s1,24(sp)
    8000179c:	01213823          	sd	s2,16(sp)
    800017a0:	01313423          	sd	s3,8(sp)
    800017a4:	01413023          	sd	s4,0(sp)
    800017a8:	03010413          	addi	s0,sp,48
    800017ac:	00050993          	mv	s3,a0
    800017b0:	00058a13          	mv	s4,a1
    LOCK();
    800017b4:	00100613          	li	a2,1
    800017b8:	00000593          	li	a1,0
    800017bc:	00004517          	auipc	a0,0x4
    800017c0:	5dc50513          	addi	a0,a0,1500 # 80005d98 <lockPrint>
    800017c4:	00000097          	auipc	ra,0x0
    800017c8:	83c080e7          	jalr	-1988(ra) # 80001000 <copy_and_swap>
    800017cc:	00050863          	beqz	a0,800017dc <_Z9getStringPci+0x50>
    800017d0:	00001097          	auipc	ra,0x1
    800017d4:	914080e7          	jalr	-1772(ra) # 800020e4 <_Z15thread_dispatchv>
    800017d8:	fddff06f          	j	800017b4 <_Z9getStringPci+0x28>
    int i, cc;
    char c;

    for(i=0; i+1 < max; ){
    800017dc:	00000913          	li	s2,0
    800017e0:	00090493          	mv	s1,s2
    800017e4:	0019091b          	addiw	s2,s2,1
    800017e8:	03495a63          	bge	s2,s4,8000181c <_Z9getStringPci+0x90>
        cc = getc();
    800017ec:	00001097          	auipc	ra,0x1
    800017f0:	918080e7          	jalr	-1768(ra) # 80002104 <_Z4getcv>
        if(cc < 1)
    800017f4:	02050463          	beqz	a0,8000181c <_Z9getStringPci+0x90>
            break;
        c = cc;
        buf[i++] = c;
    800017f8:	009984b3          	add	s1,s3,s1
    800017fc:	00a48023          	sb	a0,0(s1)
        if(c == '\n' || c == '\r')
    80001800:	00a00793          	li	a5,10
    80001804:	00f50a63          	beq	a0,a5,80001818 <_Z9getStringPci+0x8c>
    80001808:	00d00793          	li	a5,13
    8000180c:	fcf51ae3          	bne	a0,a5,800017e0 <_Z9getStringPci+0x54>
        buf[i++] = c;
    80001810:	00090493          	mv	s1,s2
    80001814:	0080006f          	j	8000181c <_Z9getStringPci+0x90>
    80001818:	00090493          	mv	s1,s2
            break;
    }
    buf[i] = '\0';
    8000181c:	009984b3          	add	s1,s3,s1
    80001820:	00048023          	sb	zero,0(s1)

    UNLOCK();
    80001824:	00000613          	li	a2,0
    80001828:	00100593          	li	a1,1
    8000182c:	00004517          	auipc	a0,0x4
    80001830:	56c50513          	addi	a0,a0,1388 # 80005d98 <lockPrint>
    80001834:	fffff097          	auipc	ra,0xfffff
    80001838:	7cc080e7          	jalr	1996(ra) # 80001000 <copy_and_swap>
    8000183c:	fe0514e3          	bnez	a0,80001824 <_Z9getStringPci+0x98>
    return buf;
}
    80001840:	00098513          	mv	a0,s3
    80001844:	02813083          	ld	ra,40(sp)
    80001848:	02013403          	ld	s0,32(sp)
    8000184c:	01813483          	ld	s1,24(sp)
    80001850:	01013903          	ld	s2,16(sp)
    80001854:	00813983          	ld	s3,8(sp)
    80001858:	00013a03          	ld	s4,0(sp)
    8000185c:	03010113          	addi	sp,sp,48
    80001860:	00008067          	ret

0000000080001864 <_Z11stringToIntPKc>:

int stringToInt(const char *s) {
    80001864:	ff010113          	addi	sp,sp,-16
    80001868:	00813423          	sd	s0,8(sp)
    8000186c:	01010413          	addi	s0,sp,16
    80001870:	00050693          	mv	a3,a0
    int n;

    n = 0;
    80001874:	00000513          	li	a0,0
    while ('0' <= *s && *s <= '9')
    80001878:	0006c603          	lbu	a2,0(a3)
    8000187c:	fd06071b          	addiw	a4,a2,-48
    80001880:	0ff77713          	andi	a4,a4,255
    80001884:	00900793          	li	a5,9
    80001888:	02e7e063          	bltu	a5,a4,800018a8 <_Z11stringToIntPKc+0x44>
        n = n * 10 + *s++ - '0';
    8000188c:	0025179b          	slliw	a5,a0,0x2
    80001890:	00a787bb          	addw	a5,a5,a0
    80001894:	0017979b          	slliw	a5,a5,0x1
    80001898:	00168693          	addi	a3,a3,1
    8000189c:	00c787bb          	addw	a5,a5,a2
    800018a0:	fd07851b          	addiw	a0,a5,-48
    while ('0' <= *s && *s <= '9')
    800018a4:	fd5ff06f          	j	80001878 <_Z11stringToIntPKc+0x14>
    return n;
}
    800018a8:	00813403          	ld	s0,8(sp)
    800018ac:	01010113          	addi	sp,sp,16
    800018b0:	00008067          	ret

00000000800018b4 <_Z8printIntiii>:

char digits[] = "0123456789ABCDEF";

void printInt(int xx, int base, int sgn)
{
    800018b4:	fc010113          	addi	sp,sp,-64
    800018b8:	02113c23          	sd	ra,56(sp)
    800018bc:	02813823          	sd	s0,48(sp)
    800018c0:	02913423          	sd	s1,40(sp)
    800018c4:	03213023          	sd	s2,32(sp)
    800018c8:	01313c23          	sd	s3,24(sp)
    800018cc:	04010413          	addi	s0,sp,64
    800018d0:	00050493          	mv	s1,a0
    800018d4:	00058913          	mv	s2,a1
    800018d8:	00060993          	mv	s3,a2
    LOCK();
    800018dc:	00100613          	li	a2,1
    800018e0:	00000593          	li	a1,0
    800018e4:	00004517          	auipc	a0,0x4
    800018e8:	4b450513          	addi	a0,a0,1204 # 80005d98 <lockPrint>
    800018ec:	fffff097          	auipc	ra,0xfffff
    800018f0:	714080e7          	jalr	1812(ra) # 80001000 <copy_and_swap>
    800018f4:	00050863          	beqz	a0,80001904 <_Z8printIntiii+0x50>
    800018f8:	00000097          	auipc	ra,0x0
    800018fc:	7ec080e7          	jalr	2028(ra) # 800020e4 <_Z15thread_dispatchv>
    80001900:	fddff06f          	j	800018dc <_Z8printIntiii+0x28>
    char buf[16];
    int i, neg;
    uint x;

    neg = 0;
    if(sgn && xx < 0){
    80001904:	00098463          	beqz	s3,8000190c <_Z8printIntiii+0x58>
    80001908:	0804c463          	bltz	s1,80001990 <_Z8printIntiii+0xdc>
        neg = 1;
        x = -xx;
    } else {
        x = xx;
    8000190c:	0004851b          	sext.w	a0,s1
    neg = 0;
    80001910:	00000593          	li	a1,0
    }

    i = 0;
    80001914:	00000493          	li	s1,0
    do{
        buf[i++] = digits[x % base];
    80001918:	0009079b          	sext.w	a5,s2
    8000191c:	0325773b          	remuw	a4,a0,s2
    80001920:	00048613          	mv	a2,s1
    80001924:	0014849b          	addiw	s1,s1,1
    80001928:	02071693          	slli	a3,a4,0x20
    8000192c:	0206d693          	srli	a3,a3,0x20
    80001930:	00004717          	auipc	a4,0x4
    80001934:	42070713          	addi	a4,a4,1056 # 80005d50 <digits>
    80001938:	00d70733          	add	a4,a4,a3
    8000193c:	00074683          	lbu	a3,0(a4)
    80001940:	fd040713          	addi	a4,s0,-48
    80001944:	00c70733          	add	a4,a4,a2
    80001948:	fed70823          	sb	a3,-16(a4)
    }while((x /= base) != 0);
    8000194c:	0005071b          	sext.w	a4,a0
    80001950:	0325553b          	divuw	a0,a0,s2
    80001954:	fcf772e3          	bgeu	a4,a5,80001918 <_Z8printIntiii+0x64>
    if(neg)
    80001958:	00058c63          	beqz	a1,80001970 <_Z8printIntiii+0xbc>
        buf[i++] = '-';
    8000195c:	fd040793          	addi	a5,s0,-48
    80001960:	009784b3          	add	s1,a5,s1
    80001964:	02d00793          	li	a5,45
    80001968:	fef48823          	sb	a5,-16(s1)
    8000196c:	0026049b          	addiw	s1,a2,2

    while(--i >= 0)
    80001970:	fff4849b          	addiw	s1,s1,-1
    80001974:	0204c463          	bltz	s1,8000199c <_Z8printIntiii+0xe8>
        putc(buf[i]);
    80001978:	fd040793          	addi	a5,s0,-48
    8000197c:	009787b3          	add	a5,a5,s1
    80001980:	ff07c503          	lbu	a0,-16(a5)
    80001984:	00000097          	auipc	ra,0x0
    80001988:	7a4080e7          	jalr	1956(ra) # 80002128 <_Z4putcc>
    8000198c:	fe5ff06f          	j	80001970 <_Z8printIntiii+0xbc>
        x = -xx;
    80001990:	4090053b          	negw	a0,s1
        neg = 1;
    80001994:	00100593          	li	a1,1
        x = -xx;
    80001998:	f7dff06f          	j	80001914 <_Z8printIntiii+0x60>

    UNLOCK();
    8000199c:	00000613          	li	a2,0
    800019a0:	00100593          	li	a1,1
    800019a4:	00004517          	auipc	a0,0x4
    800019a8:	3f450513          	addi	a0,a0,1012 # 80005d98 <lockPrint>
    800019ac:	fffff097          	auipc	ra,0xfffff
    800019b0:	654080e7          	jalr	1620(ra) # 80001000 <copy_and_swap>
    800019b4:	fe0514e3          	bnez	a0,8000199c <_Z8printIntiii+0xe8>
    800019b8:	03813083          	ld	ra,56(sp)
    800019bc:	03013403          	ld	s0,48(sp)
    800019c0:	02813483          	ld	s1,40(sp)
    800019c4:	02013903          	ld	s2,32(sp)
    800019c8:	01813983          	ld	s3,24(sp)
    800019cc:	04010113          	addi	sp,sp,64
    800019d0:	00008067          	ret

00000000800019d4 <_ZL9fibonaccim>:
static volatile bool finishedA = false;
static volatile bool finishedB = false;
static volatile bool finishedC = false;
static volatile bool finishedD = false;

static uint64 fibonacci(uint64 n) {
    800019d4:	fe010113          	addi	sp,sp,-32
    800019d8:	00113c23          	sd	ra,24(sp)
    800019dc:	00813823          	sd	s0,16(sp)
    800019e0:	00913423          	sd	s1,8(sp)
    800019e4:	01213023          	sd	s2,0(sp)
    800019e8:	02010413          	addi	s0,sp,32
    800019ec:	00050493          	mv	s1,a0
    if (n == 0 || n == 1) { return n; }
    800019f0:	00100793          	li	a5,1
    800019f4:	02a7f863          	bgeu	a5,a0,80001a24 <_ZL9fibonaccim+0x50>
    if (n % 10 == 0) { thread_dispatch(); }
    800019f8:	00a00793          	li	a5,10
    800019fc:	02f577b3          	remu	a5,a0,a5
    80001a00:	02078e63          	beqz	a5,80001a3c <_ZL9fibonaccim+0x68>
    return fibonacci(n - 1) + fibonacci(n - 2);
    80001a04:	fff48513          	addi	a0,s1,-1
    80001a08:	00000097          	auipc	ra,0x0
    80001a0c:	fcc080e7          	jalr	-52(ra) # 800019d4 <_ZL9fibonaccim>
    80001a10:	00050913          	mv	s2,a0
    80001a14:	ffe48513          	addi	a0,s1,-2
    80001a18:	00000097          	auipc	ra,0x0
    80001a1c:	fbc080e7          	jalr	-68(ra) # 800019d4 <_ZL9fibonaccim>
    80001a20:	00a90533          	add	a0,s2,a0
}
    80001a24:	01813083          	ld	ra,24(sp)
    80001a28:	01013403          	ld	s0,16(sp)
    80001a2c:	00813483          	ld	s1,8(sp)
    80001a30:	00013903          	ld	s2,0(sp)
    80001a34:	02010113          	addi	sp,sp,32
    80001a38:	00008067          	ret
    if (n % 10 == 0) { thread_dispatch(); }
    80001a3c:	00000097          	auipc	ra,0x0
    80001a40:	6a8080e7          	jalr	1704(ra) # 800020e4 <_Z15thread_dispatchv>
    80001a44:	fc1ff06f          	j	80001a04 <_ZL9fibonaccim+0x30>

0000000080001a48 <_ZL11workerBodyDPv>:
    printString("A finished!\n");
    finishedC = true;
    thread_dispatch();
}

static void workerBodyD(void* arg) {
    80001a48:	fe010113          	addi	sp,sp,-32
    80001a4c:	00113c23          	sd	ra,24(sp)
    80001a50:	00813823          	sd	s0,16(sp)
    80001a54:	00913423          	sd	s1,8(sp)
    80001a58:	01213023          	sd	s2,0(sp)
    80001a5c:	02010413          	addi	s0,sp,32
    uint8 i = 10;
    80001a60:	00a00493          	li	s1,10
    80001a64:	0400006f          	j	80001aa4 <_ZL11workerBodyDPv+0x5c>
    for (; i < 13; i++) {
        printString("D: i="); printInt(i); printString("\n");
    80001a68:	00003517          	auipc	a0,0x3
    80001a6c:	5b850513          	addi	a0,a0,1464 # 80005020 <CONSOLE_STATUS+0x10>
    80001a70:	00000097          	auipc	ra,0x0
    80001a74:	c94080e7          	jalr	-876(ra) # 80001704 <_Z11printStringPKc>
    80001a78:	00000613          	li	a2,0
    80001a7c:	00a00593          	li	a1,10
    80001a80:	00048513          	mv	a0,s1
    80001a84:	00000097          	auipc	ra,0x0
    80001a88:	e30080e7          	jalr	-464(ra) # 800018b4 <_Z8printIntiii>
    80001a8c:	00004517          	auipc	a0,0x4
    80001a90:	a3c50513          	addi	a0,a0,-1476 # 800054c8 <CONSOLE_STATUS+0x4b8>
    80001a94:	00000097          	auipc	ra,0x0
    80001a98:	c70080e7          	jalr	-912(ra) # 80001704 <_Z11printStringPKc>
    for (; i < 13; i++) {
    80001a9c:	0014849b          	addiw	s1,s1,1
    80001aa0:	0ff4f493          	andi	s1,s1,255
    80001aa4:	00c00793          	li	a5,12
    80001aa8:	fc97f0e3          	bgeu	a5,s1,80001a68 <_ZL11workerBodyDPv+0x20>
    }

    printString("D: dispatch\n");
    80001aac:	00003517          	auipc	a0,0x3
    80001ab0:	57c50513          	addi	a0,a0,1404 # 80005028 <CONSOLE_STATUS+0x18>
    80001ab4:	00000097          	auipc	ra,0x0
    80001ab8:	c50080e7          	jalr	-944(ra) # 80001704 <_Z11printStringPKc>
    __asm__ ("li t1, 5");
    80001abc:	00500313          	li	t1,5
    thread_dispatch();
    80001ac0:	00000097          	auipc	ra,0x0
    80001ac4:	624080e7          	jalr	1572(ra) # 800020e4 <_Z15thread_dispatchv>

    uint64 result = fibonacci(16);
    80001ac8:	01000513          	li	a0,16
    80001acc:	00000097          	auipc	ra,0x0
    80001ad0:	f08080e7          	jalr	-248(ra) # 800019d4 <_ZL9fibonaccim>
    80001ad4:	00050913          	mv	s2,a0
    printString("D: fibonaci="); printInt(result); printString("\n");
    80001ad8:	00003517          	auipc	a0,0x3
    80001adc:	56050513          	addi	a0,a0,1376 # 80005038 <CONSOLE_STATUS+0x28>
    80001ae0:	00000097          	auipc	ra,0x0
    80001ae4:	c24080e7          	jalr	-988(ra) # 80001704 <_Z11printStringPKc>
    80001ae8:	00000613          	li	a2,0
    80001aec:	00a00593          	li	a1,10
    80001af0:	0009051b          	sext.w	a0,s2
    80001af4:	00000097          	auipc	ra,0x0
    80001af8:	dc0080e7          	jalr	-576(ra) # 800018b4 <_Z8printIntiii>
    80001afc:	00004517          	auipc	a0,0x4
    80001b00:	9cc50513          	addi	a0,a0,-1588 # 800054c8 <CONSOLE_STATUS+0x4b8>
    80001b04:	00000097          	auipc	ra,0x0
    80001b08:	c00080e7          	jalr	-1024(ra) # 80001704 <_Z11printStringPKc>
    80001b0c:	0400006f          	j	80001b4c <_ZL11workerBodyDPv+0x104>

    for (; i < 16; i++) {
        printString("D: i="); printInt(i); printString("\n");
    80001b10:	00003517          	auipc	a0,0x3
    80001b14:	51050513          	addi	a0,a0,1296 # 80005020 <CONSOLE_STATUS+0x10>
    80001b18:	00000097          	auipc	ra,0x0
    80001b1c:	bec080e7          	jalr	-1044(ra) # 80001704 <_Z11printStringPKc>
    80001b20:	00000613          	li	a2,0
    80001b24:	00a00593          	li	a1,10
    80001b28:	00048513          	mv	a0,s1
    80001b2c:	00000097          	auipc	ra,0x0
    80001b30:	d88080e7          	jalr	-632(ra) # 800018b4 <_Z8printIntiii>
    80001b34:	00004517          	auipc	a0,0x4
    80001b38:	99450513          	addi	a0,a0,-1644 # 800054c8 <CONSOLE_STATUS+0x4b8>
    80001b3c:	00000097          	auipc	ra,0x0
    80001b40:	bc8080e7          	jalr	-1080(ra) # 80001704 <_Z11printStringPKc>
    for (; i < 16; i++) {
    80001b44:	0014849b          	addiw	s1,s1,1
    80001b48:	0ff4f493          	andi	s1,s1,255
    80001b4c:	00f00793          	li	a5,15
    80001b50:	fc97f0e3          	bgeu	a5,s1,80001b10 <_ZL11workerBodyDPv+0xc8>
    }

    printString("D finished!\n");
    80001b54:	00003517          	auipc	a0,0x3
    80001b58:	4f450513          	addi	a0,a0,1268 # 80005048 <CONSOLE_STATUS+0x38>
    80001b5c:	00000097          	auipc	ra,0x0
    80001b60:	ba8080e7          	jalr	-1112(ra) # 80001704 <_Z11printStringPKc>
    finishedD = true;
    80001b64:	00100793          	li	a5,1
    80001b68:	00004717          	auipc	a4,0x4
    80001b6c:	22f70c23          	sb	a5,568(a4) # 80005da0 <_ZL9finishedD>
    thread_dispatch();
    80001b70:	00000097          	auipc	ra,0x0
    80001b74:	574080e7          	jalr	1396(ra) # 800020e4 <_Z15thread_dispatchv>
}
    80001b78:	01813083          	ld	ra,24(sp)
    80001b7c:	01013403          	ld	s0,16(sp)
    80001b80:	00813483          	ld	s1,8(sp)
    80001b84:	00013903          	ld	s2,0(sp)
    80001b88:	02010113          	addi	sp,sp,32
    80001b8c:	00008067          	ret

0000000080001b90 <_ZL11workerBodyCPv>:
static void workerBodyC(void* arg) {
    80001b90:	fe010113          	addi	sp,sp,-32
    80001b94:	00113c23          	sd	ra,24(sp)
    80001b98:	00813823          	sd	s0,16(sp)
    80001b9c:	00913423          	sd	s1,8(sp)
    80001ba0:	01213023          	sd	s2,0(sp)
    80001ba4:	02010413          	addi	s0,sp,32
    uint8 i = 0;
    80001ba8:	00000493          	li	s1,0
    80001bac:	0400006f          	j	80001bec <_ZL11workerBodyCPv+0x5c>
        printString("C: i="); printInt(i); printString("\n");
    80001bb0:	00003517          	auipc	a0,0x3
    80001bb4:	4a850513          	addi	a0,a0,1192 # 80005058 <CONSOLE_STATUS+0x48>
    80001bb8:	00000097          	auipc	ra,0x0
    80001bbc:	b4c080e7          	jalr	-1204(ra) # 80001704 <_Z11printStringPKc>
    80001bc0:	00000613          	li	a2,0
    80001bc4:	00a00593          	li	a1,10
    80001bc8:	00048513          	mv	a0,s1
    80001bcc:	00000097          	auipc	ra,0x0
    80001bd0:	ce8080e7          	jalr	-792(ra) # 800018b4 <_Z8printIntiii>
    80001bd4:	00004517          	auipc	a0,0x4
    80001bd8:	8f450513          	addi	a0,a0,-1804 # 800054c8 <CONSOLE_STATUS+0x4b8>
    80001bdc:	00000097          	auipc	ra,0x0
    80001be0:	b28080e7          	jalr	-1240(ra) # 80001704 <_Z11printStringPKc>
    for (; i < 3; i++) {
    80001be4:	0014849b          	addiw	s1,s1,1
    80001be8:	0ff4f493          	andi	s1,s1,255
    80001bec:	00200793          	li	a5,2
    80001bf0:	fc97f0e3          	bgeu	a5,s1,80001bb0 <_ZL11workerBodyCPv+0x20>
    printString("C: dispatch\n");
    80001bf4:	00003517          	auipc	a0,0x3
    80001bf8:	46c50513          	addi	a0,a0,1132 # 80005060 <CONSOLE_STATUS+0x50>
    80001bfc:	00000097          	auipc	ra,0x0
    80001c00:	b08080e7          	jalr	-1272(ra) # 80001704 <_Z11printStringPKc>
    __asm__ ("li t1, 7");
    80001c04:	00700313          	li	t1,7
    thread_dispatch();
    80001c08:	00000097          	auipc	ra,0x0
    80001c0c:	4dc080e7          	jalr	1244(ra) # 800020e4 <_Z15thread_dispatchv>
    __asm__ ("mv %[t1], t1" : [t1] "=r"(t1));
    80001c10:	00030913          	mv	s2,t1
    printString("C: t1="); printInt(t1); printString("\n");
    80001c14:	00003517          	auipc	a0,0x3
    80001c18:	45c50513          	addi	a0,a0,1116 # 80005070 <CONSOLE_STATUS+0x60>
    80001c1c:	00000097          	auipc	ra,0x0
    80001c20:	ae8080e7          	jalr	-1304(ra) # 80001704 <_Z11printStringPKc>
    80001c24:	00000613          	li	a2,0
    80001c28:	00a00593          	li	a1,10
    80001c2c:	0009051b          	sext.w	a0,s2
    80001c30:	00000097          	auipc	ra,0x0
    80001c34:	c84080e7          	jalr	-892(ra) # 800018b4 <_Z8printIntiii>
    80001c38:	00004517          	auipc	a0,0x4
    80001c3c:	89050513          	addi	a0,a0,-1904 # 800054c8 <CONSOLE_STATUS+0x4b8>
    80001c40:	00000097          	auipc	ra,0x0
    80001c44:	ac4080e7          	jalr	-1340(ra) # 80001704 <_Z11printStringPKc>
    uint64 result = fibonacci(12);
    80001c48:	00c00513          	li	a0,12
    80001c4c:	00000097          	auipc	ra,0x0
    80001c50:	d88080e7          	jalr	-632(ra) # 800019d4 <_ZL9fibonaccim>
    80001c54:	00050913          	mv	s2,a0
    printString("C: fibonaci="); printInt(result); printString("\n");
    80001c58:	00003517          	auipc	a0,0x3
    80001c5c:	42050513          	addi	a0,a0,1056 # 80005078 <CONSOLE_STATUS+0x68>
    80001c60:	00000097          	auipc	ra,0x0
    80001c64:	aa4080e7          	jalr	-1372(ra) # 80001704 <_Z11printStringPKc>
    80001c68:	00000613          	li	a2,0
    80001c6c:	00a00593          	li	a1,10
    80001c70:	0009051b          	sext.w	a0,s2
    80001c74:	00000097          	auipc	ra,0x0
    80001c78:	c40080e7          	jalr	-960(ra) # 800018b4 <_Z8printIntiii>
    80001c7c:	00004517          	auipc	a0,0x4
    80001c80:	84c50513          	addi	a0,a0,-1972 # 800054c8 <CONSOLE_STATUS+0x4b8>
    80001c84:	00000097          	auipc	ra,0x0
    80001c88:	a80080e7          	jalr	-1408(ra) # 80001704 <_Z11printStringPKc>
    80001c8c:	0400006f          	j	80001ccc <_ZL11workerBodyCPv+0x13c>
        printString("C: i="); printInt(i); printString("\n");
    80001c90:	00003517          	auipc	a0,0x3
    80001c94:	3c850513          	addi	a0,a0,968 # 80005058 <CONSOLE_STATUS+0x48>
    80001c98:	00000097          	auipc	ra,0x0
    80001c9c:	a6c080e7          	jalr	-1428(ra) # 80001704 <_Z11printStringPKc>
    80001ca0:	00000613          	li	a2,0
    80001ca4:	00a00593          	li	a1,10
    80001ca8:	00048513          	mv	a0,s1
    80001cac:	00000097          	auipc	ra,0x0
    80001cb0:	c08080e7          	jalr	-1016(ra) # 800018b4 <_Z8printIntiii>
    80001cb4:	00004517          	auipc	a0,0x4
    80001cb8:	81450513          	addi	a0,a0,-2028 # 800054c8 <CONSOLE_STATUS+0x4b8>
    80001cbc:	00000097          	auipc	ra,0x0
    80001cc0:	a48080e7          	jalr	-1464(ra) # 80001704 <_Z11printStringPKc>
    for (; i < 6; i++) {
    80001cc4:	0014849b          	addiw	s1,s1,1
    80001cc8:	0ff4f493          	andi	s1,s1,255
    80001ccc:	00500793          	li	a5,5
    80001cd0:	fc97f0e3          	bgeu	a5,s1,80001c90 <_ZL11workerBodyCPv+0x100>
    printString("A finished!\n");
    80001cd4:	00003517          	auipc	a0,0x3
    80001cd8:	3b450513          	addi	a0,a0,948 # 80005088 <CONSOLE_STATUS+0x78>
    80001cdc:	00000097          	auipc	ra,0x0
    80001ce0:	a28080e7          	jalr	-1496(ra) # 80001704 <_Z11printStringPKc>
    finishedC = true;
    80001ce4:	00100793          	li	a5,1
    80001ce8:	00004717          	auipc	a4,0x4
    80001cec:	0af70ca3          	sb	a5,185(a4) # 80005da1 <_ZL9finishedC>
    thread_dispatch();
    80001cf0:	00000097          	auipc	ra,0x0
    80001cf4:	3f4080e7          	jalr	1012(ra) # 800020e4 <_Z15thread_dispatchv>
}
    80001cf8:	01813083          	ld	ra,24(sp)
    80001cfc:	01013403          	ld	s0,16(sp)
    80001d00:	00813483          	ld	s1,8(sp)
    80001d04:	00013903          	ld	s2,0(sp)
    80001d08:	02010113          	addi	sp,sp,32
    80001d0c:	00008067          	ret

0000000080001d10 <_ZL11workerBodyBPv>:
static void workerBodyB(void* arg) {
    80001d10:	fe010113          	addi	sp,sp,-32
    80001d14:	00113c23          	sd	ra,24(sp)
    80001d18:	00813823          	sd	s0,16(sp)
    80001d1c:	00913423          	sd	s1,8(sp)
    80001d20:	01213023          	sd	s2,0(sp)
    80001d24:	02010413          	addi	s0,sp,32
    for (uint64 i = 0; i < 16; i++) {
    80001d28:	00000913          	li	s2,0
    80001d2c:	0400006f          	j	80001d6c <_ZL11workerBodyBPv+0x5c>
            thread_dispatch();
    80001d30:	00000097          	auipc	ra,0x0
    80001d34:	3b4080e7          	jalr	948(ra) # 800020e4 <_Z15thread_dispatchv>
        for (uint64 j = 0; j < 10000; j++) {
    80001d38:	00148493          	addi	s1,s1,1
    80001d3c:	000027b7          	lui	a5,0x2
    80001d40:	70f78793          	addi	a5,a5,1807 # 270f <_entry-0x7fffd8f1>
    80001d44:	0097ee63          	bltu	a5,s1,80001d60 <_ZL11workerBodyBPv+0x50>
            for (uint64 k = 0; k < 30000; k++) { /* busy wait */ }
    80001d48:	00000713          	li	a4,0
    80001d4c:	000077b7          	lui	a5,0x7
    80001d50:	52f78793          	addi	a5,a5,1327 # 752f <_entry-0x7fff8ad1>
    80001d54:	fce7eee3          	bltu	a5,a4,80001d30 <_ZL11workerBodyBPv+0x20>
    80001d58:	00170713          	addi	a4,a4,1
    80001d5c:	ff1ff06f          	j	80001d4c <_ZL11workerBodyBPv+0x3c>
        if (i == 10) {
    80001d60:	00a00793          	li	a5,10
    80001d64:	04f90663          	beq	s2,a5,80001db0 <_ZL11workerBodyBPv+0xa0>
    for (uint64 i = 0; i < 16; i++) {
    80001d68:	00190913          	addi	s2,s2,1
    80001d6c:	00f00793          	li	a5,15
    80001d70:	0527e463          	bltu	a5,s2,80001db8 <_ZL11workerBodyBPv+0xa8>
        printString("B: i="); printInt(i); printString("\n");
    80001d74:	00003517          	auipc	a0,0x3
    80001d78:	32450513          	addi	a0,a0,804 # 80005098 <CONSOLE_STATUS+0x88>
    80001d7c:	00000097          	auipc	ra,0x0
    80001d80:	988080e7          	jalr	-1656(ra) # 80001704 <_Z11printStringPKc>
    80001d84:	00000613          	li	a2,0
    80001d88:	00a00593          	li	a1,10
    80001d8c:	0009051b          	sext.w	a0,s2
    80001d90:	00000097          	auipc	ra,0x0
    80001d94:	b24080e7          	jalr	-1244(ra) # 800018b4 <_Z8printIntiii>
    80001d98:	00003517          	auipc	a0,0x3
    80001d9c:	73050513          	addi	a0,a0,1840 # 800054c8 <CONSOLE_STATUS+0x4b8>
    80001da0:	00000097          	auipc	ra,0x0
    80001da4:	964080e7          	jalr	-1692(ra) # 80001704 <_Z11printStringPKc>
        for (uint64 j = 0; j < 10000; j++) {
    80001da8:	00000493          	li	s1,0
    80001dac:	f91ff06f          	j	80001d3c <_ZL11workerBodyBPv+0x2c>
            asm volatile("csrr t6, sepc");
    80001db0:	14102ff3          	csrr	t6,sepc
    80001db4:	fb5ff06f          	j	80001d68 <_ZL11workerBodyBPv+0x58>
    printString("B finished!\n");
    80001db8:	00003517          	auipc	a0,0x3
    80001dbc:	2e850513          	addi	a0,a0,744 # 800050a0 <CONSOLE_STATUS+0x90>
    80001dc0:	00000097          	auipc	ra,0x0
    80001dc4:	944080e7          	jalr	-1724(ra) # 80001704 <_Z11printStringPKc>
    finishedB = true;
    80001dc8:	00100793          	li	a5,1
    80001dcc:	00004717          	auipc	a4,0x4
    80001dd0:	fcf70b23          	sb	a5,-42(a4) # 80005da2 <_ZL9finishedB>
    thread_dispatch();
    80001dd4:	00000097          	auipc	ra,0x0
    80001dd8:	310080e7          	jalr	784(ra) # 800020e4 <_Z15thread_dispatchv>
}
    80001ddc:	01813083          	ld	ra,24(sp)
    80001de0:	01013403          	ld	s0,16(sp)
    80001de4:	00813483          	ld	s1,8(sp)
    80001de8:	00013903          	ld	s2,0(sp)
    80001dec:	02010113          	addi	sp,sp,32
    80001df0:	00008067          	ret

0000000080001df4 <_ZL11workerBodyAPv>:
static void workerBodyA(void* arg) {
    80001df4:	fe010113          	addi	sp,sp,-32
    80001df8:	00113c23          	sd	ra,24(sp)
    80001dfc:	00813823          	sd	s0,16(sp)
    80001e00:	00913423          	sd	s1,8(sp)
    80001e04:	01213023          	sd	s2,0(sp)
    80001e08:	02010413          	addi	s0,sp,32
    for (uint64 i = 0; i < 10; i++) {
    80001e0c:	00000913          	li	s2,0
    80001e10:	0380006f          	j	80001e48 <_ZL11workerBodyAPv+0x54>
            thread_dispatch();
    80001e14:	00000097          	auipc	ra,0x0
    80001e18:	2d0080e7          	jalr	720(ra) # 800020e4 <_Z15thread_dispatchv>
        for (uint64 j = 0; j < 10000; j++) {
    80001e1c:	00148493          	addi	s1,s1,1
    80001e20:	000027b7          	lui	a5,0x2
    80001e24:	70f78793          	addi	a5,a5,1807 # 270f <_entry-0x7fffd8f1>
    80001e28:	0097ee63          	bltu	a5,s1,80001e44 <_ZL11workerBodyAPv+0x50>
            for (uint64 k = 0; k < 30000; k++) { /* busy wait */ }
    80001e2c:	00000713          	li	a4,0
    80001e30:	000077b7          	lui	a5,0x7
    80001e34:	52f78793          	addi	a5,a5,1327 # 752f <_entry-0x7fff8ad1>
    80001e38:	fce7eee3          	bltu	a5,a4,80001e14 <_ZL11workerBodyAPv+0x20>
    80001e3c:	00170713          	addi	a4,a4,1
    80001e40:	ff1ff06f          	j	80001e30 <_ZL11workerBodyAPv+0x3c>
    for (uint64 i = 0; i < 10; i++) {
    80001e44:	00190913          	addi	s2,s2,1
    80001e48:	00900793          	li	a5,9
    80001e4c:	0527e063          	bltu	a5,s2,80001e8c <_ZL11workerBodyAPv+0x98>
        printString("A: i="); printInt(i); printString("\n");
    80001e50:	00003517          	auipc	a0,0x3
    80001e54:	26050513          	addi	a0,a0,608 # 800050b0 <CONSOLE_STATUS+0xa0>
    80001e58:	00000097          	auipc	ra,0x0
    80001e5c:	8ac080e7          	jalr	-1876(ra) # 80001704 <_Z11printStringPKc>
    80001e60:	00000613          	li	a2,0
    80001e64:	00a00593          	li	a1,10
    80001e68:	0009051b          	sext.w	a0,s2
    80001e6c:	00000097          	auipc	ra,0x0
    80001e70:	a48080e7          	jalr	-1464(ra) # 800018b4 <_Z8printIntiii>
    80001e74:	00003517          	auipc	a0,0x3
    80001e78:	65450513          	addi	a0,a0,1620 # 800054c8 <CONSOLE_STATUS+0x4b8>
    80001e7c:	00000097          	auipc	ra,0x0
    80001e80:	888080e7          	jalr	-1912(ra) # 80001704 <_Z11printStringPKc>
        for (uint64 j = 0; j < 10000; j++) {
    80001e84:	00000493          	li	s1,0
    80001e88:	f99ff06f          	j	80001e20 <_ZL11workerBodyAPv+0x2c>
    printString("A finished!\n");
    80001e8c:	00003517          	auipc	a0,0x3
    80001e90:	1fc50513          	addi	a0,a0,508 # 80005088 <CONSOLE_STATUS+0x78>
    80001e94:	00000097          	auipc	ra,0x0
    80001e98:	870080e7          	jalr	-1936(ra) # 80001704 <_Z11printStringPKc>
    finishedA = true;
    80001e9c:	00100793          	li	a5,1
    80001ea0:	00004717          	auipc	a4,0x4
    80001ea4:	f0f701a3          	sb	a5,-253(a4) # 80005da3 <_ZL9finishedA>
}
    80001ea8:	01813083          	ld	ra,24(sp)
    80001eac:	01013403          	ld	s0,16(sp)
    80001eb0:	00813483          	ld	s1,8(sp)
    80001eb4:	00013903          	ld	s2,0(sp)
    80001eb8:	02010113          	addi	sp,sp,32
    80001ebc:	00008067          	ret

0000000080001ec0 <_Z16System_Mode_testv>:


void System_Mode_test() {
    80001ec0:	fd010113          	addi	sp,sp,-48
    80001ec4:	02113423          	sd	ra,40(sp)
    80001ec8:	02813023          	sd	s0,32(sp)
    80001ecc:	03010413          	addi	s0,sp,48
    thread_t threads[4];
    thread_create(&threads[0], workerBodyA, nullptr);
    80001ed0:	00000613          	li	a2,0
    80001ed4:	00000597          	auipc	a1,0x0
    80001ed8:	f2058593          	addi	a1,a1,-224 # 80001df4 <_ZL11workerBodyAPv>
    80001edc:	fd040513          	addi	a0,s0,-48
    80001ee0:	00000097          	auipc	ra,0x0
    80001ee4:	138080e7          	jalr	312(ra) # 80002018 <_Z13thread_createPP7_threadPFvPvES2_>
    printString("ThreadA created\n");
    80001ee8:	00003517          	auipc	a0,0x3
    80001eec:	1d050513          	addi	a0,a0,464 # 800050b8 <CONSOLE_STATUS+0xa8>
    80001ef0:	00000097          	auipc	ra,0x0
    80001ef4:	814080e7          	jalr	-2028(ra) # 80001704 <_Z11printStringPKc>

    thread_create(&threads[1], workerBodyB, nullptr);
    80001ef8:	00000613          	li	a2,0
    80001efc:	00000597          	auipc	a1,0x0
    80001f00:	e1458593          	addi	a1,a1,-492 # 80001d10 <_ZL11workerBodyBPv>
    80001f04:	fd840513          	addi	a0,s0,-40
    80001f08:	00000097          	auipc	ra,0x0
    80001f0c:	110080e7          	jalr	272(ra) # 80002018 <_Z13thread_createPP7_threadPFvPvES2_>
    printString("ThreadB created\n");
    80001f10:	00003517          	auipc	a0,0x3
    80001f14:	1c050513          	addi	a0,a0,448 # 800050d0 <CONSOLE_STATUS+0xc0>
    80001f18:	fffff097          	auipc	ra,0xfffff
    80001f1c:	7ec080e7          	jalr	2028(ra) # 80001704 <_Z11printStringPKc>

    thread_create(&threads[2], workerBodyC, nullptr);
    80001f20:	00000613          	li	a2,0
    80001f24:	00000597          	auipc	a1,0x0
    80001f28:	c6c58593          	addi	a1,a1,-916 # 80001b90 <_ZL11workerBodyCPv>
    80001f2c:	fe040513          	addi	a0,s0,-32
    80001f30:	00000097          	auipc	ra,0x0
    80001f34:	0e8080e7          	jalr	232(ra) # 80002018 <_Z13thread_createPP7_threadPFvPvES2_>
    printString("ThreadC created\n");
    80001f38:	00003517          	auipc	a0,0x3
    80001f3c:	1b050513          	addi	a0,a0,432 # 800050e8 <CONSOLE_STATUS+0xd8>
    80001f40:	fffff097          	auipc	ra,0xfffff
    80001f44:	7c4080e7          	jalr	1988(ra) # 80001704 <_Z11printStringPKc>

    thread_create(&threads[3], workerBodyD, nullptr);
    80001f48:	00000613          	li	a2,0
    80001f4c:	00000597          	auipc	a1,0x0
    80001f50:	afc58593          	addi	a1,a1,-1284 # 80001a48 <_ZL11workerBodyDPv>
    80001f54:	fe840513          	addi	a0,s0,-24
    80001f58:	00000097          	auipc	ra,0x0
    80001f5c:	0c0080e7          	jalr	192(ra) # 80002018 <_Z13thread_createPP7_threadPFvPvES2_>
    printString("ThreadD created\n");
    80001f60:	00003517          	auipc	a0,0x3
    80001f64:	1a050513          	addi	a0,a0,416 # 80005100 <CONSOLE_STATUS+0xf0>
    80001f68:	fffff097          	auipc	ra,0xfffff
    80001f6c:	79c080e7          	jalr	1948(ra) # 80001704 <_Z11printStringPKc>
    80001f70:	00c0006f          	j	80001f7c <_Z16System_Mode_testv+0xbc>

    while (!(finishedA && finishedB && finishedC && finishedD)) {
        thread_dispatch();
    80001f74:	00000097          	auipc	ra,0x0
    80001f78:	170080e7          	jalr	368(ra) # 800020e4 <_Z15thread_dispatchv>
    while (!(finishedA && finishedB && finishedC && finishedD)) {
    80001f7c:	00004797          	auipc	a5,0x4
    80001f80:	e277c783          	lbu	a5,-473(a5) # 80005da3 <_ZL9finishedA>
    80001f84:	fe0788e3          	beqz	a5,80001f74 <_Z16System_Mode_testv+0xb4>
    80001f88:	00004797          	auipc	a5,0x4
    80001f8c:	e1a7c783          	lbu	a5,-486(a5) # 80005da2 <_ZL9finishedB>
    80001f90:	fe0782e3          	beqz	a5,80001f74 <_Z16System_Mode_testv+0xb4>
    80001f94:	00004797          	auipc	a5,0x4
    80001f98:	e0d7c783          	lbu	a5,-499(a5) # 80005da1 <_ZL9finishedC>
    80001f9c:	fc078ce3          	beqz	a5,80001f74 <_Z16System_Mode_testv+0xb4>
    80001fa0:	00004797          	auipc	a5,0x4
    80001fa4:	e007c783          	lbu	a5,-512(a5) # 80005da0 <_ZL9finishedD>
    80001fa8:	fc0786e3          	beqz	a5,80001f74 <_Z16System_Mode_testv+0xb4>
    }

}
    80001fac:	02813083          	ld	ra,40(sp)
    80001fb0:	02013403          	ld	s0,32(sp)
    80001fb4:	03010113          	addi	sp,sp,48
    80001fb8:	00008067          	ret

0000000080001fbc <_Z9mem_allocm>:
#include "../h/syscall_c.h"
#include "../lib/hw.h"

void* mem_alloc(size_t size) {
    80001fbc:	ff010113          	addi	sp,sp,-16
    80001fc0:	00813423          	sd	s0,8(sp)
    80001fc4:	01010413          	addi	s0,sp,16
    if (size == 0) return nullptr;
    80001fc8:	02050063          	beqz	a0,80001fe8 <_Z9mem_allocm+0x2c>

    // abi poziv 0x01 prima velicinu u blokovima: zaokruzi bajtove navise
    size_t numBlocks = (size + MEM_BLOCK_SIZE - 1) / MEM_BLOCK_SIZE;
    80001fcc:	03f50593          	addi	a1,a0,63

    // spakuj registre pa ecall; povratna vrednost stize nazad u a0
    register uint64 code   asm("a0") = 0x01;
    80001fd0:	00100513          	li	a0,1
    register uint64 blocks asm("a1") = numBlocks;
    80001fd4:	0065d593          	srli	a1,a1,0x6
    asm volatile("ecall"
        : "=r"(code)
        : "r"(code), "r"(blocks)
        : "memory");
    80001fd8:	00000073          	ecall

    return (void*)code;
}
    80001fdc:	00813403          	ld	s0,8(sp)
    80001fe0:	01010113          	addi	sp,sp,16
    80001fe4:	00008067          	ret
    if (size == 0) return nullptr;
    80001fe8:	00000513          	li	a0,0
    80001fec:	ff1ff06f          	j	80001fdc <_Z9mem_allocm+0x20>

0000000080001ff0 <_Z8mem_freePv>:

int mem_free(void* ptr) {
    80001ff0:	ff010113          	addi	sp,sp,-16
    80001ff4:	00813423          	sd	s0,8(sp)
    80001ff8:	01010413          	addi	s0,sp,16
    80001ffc:	00050593          	mv	a1,a0
    // abi poziv 0x02: a1 = pokazivac dobijen iz mem_alloc
    register uint64 code asm("a0") = 0x02;
    80002000:	00200513          	li	a0,2
    register uint64 p    asm("a1") = (uint64)ptr;
    asm volatile("ecall"
        : "=r"(code)
        : "r"(code), "r"(p)
        : "memory");
    80002004:	00000073          	ecall

    return (int)code;   // 0 = uspeh, negativno = greska
}
    80002008:	0005051b          	sext.w	a0,a0
    8000200c:	00813403          	ld	s0,8(sp)
    80002010:	01010113          	addi	sp,sp,16
    80002014:	00008067          	ret

0000000080002018 <_Z13thread_createPP7_threadPFvPvES2_>:

int thread_create(thread_t* handle, void (*start_routine)(void*), void* arg) {
    80002018:	fd010113          	addi	sp,sp,-48
    8000201c:	02113423          	sd	ra,40(sp)
    80002020:	02813023          	sd	s0,32(sp)
    80002024:	00913c23          	sd	s1,24(sp)
    80002028:	01213823          	sd	s2,16(sp)
    8000202c:	01313423          	sd	s3,8(sp)
    80002030:	03010413          	addi	s0,sp,48
    if (!handle || !start_routine) return -1;
    80002034:	06050a63          	beqz	a0,800020a8 <_Z13thread_createPP7_threadPFvPvES2_+0x90>
    80002038:	00050493          	mv	s1,a0
    8000203c:	00058913          	mv	s2,a1
    80002040:	00060993          	mv	s3,a2
    80002044:	06058663          	beqz	a1,800020b0 <_Z13thread_createPP7_threadPFvPvES2_+0x98>

    // pdf, abi poziv 0x11: stek niti alocira OVAJ sloj (kroz mem_alloc,
    // dakle jos jedan ecall), pa ga prosledjuje jezgru kao 4. argument
    void* stackSpace = mem_alloc(DEFAULT_STACK_SIZE);
    80002048:	00001537          	lui	a0,0x1
    8000204c:	00000097          	auipc	ra,0x0
    80002050:	f70080e7          	jalr	-144(ra) # 80001fbc <_Z9mem_allocm>
    80002054:	00050713          	mv	a4,a0
    if (!stackSpace) return -2;
    80002058:	06050063          	beqz	a0,800020b8 <_Z13thread_createPP7_threadPFvPvES2_+0xa0>

    register uint64 code asm("a0") = 0x11;
    8000205c:	01100513          	li	a0,17
    register uint64 h    asm("a1") = (uint64)handle;
    80002060:	00048593          	mv	a1,s1
    register uint64 rt   asm("a2") = (uint64)start_routine;
    80002064:	00090613          	mv	a2,s2
    register uint64 ag   asm("a3") = (uint64)arg;
    80002068:	00098693          	mv	a3,s3
    register uint64 st   asm("a4") = (uint64)stackSpace;
    asm volatile("ecall"
        : "=r"(code)
        : "r"(code), "r"(h), "r"(rt), "r"(ag), "r"(st)
        : "memory");
    8000206c:	00000073          	ecall

    int result = (int)code;
    80002070:	0005049b          	sext.w	s1,a0
    if (result != 0) mem_free(stackSpace);   // nit nije nastala - vrati stek
    80002074:	02049263          	bnez	s1,80002098 <_Z13thread_createPP7_threadPFvPvES2_+0x80>
    return result;
}
    80002078:	00048513          	mv	a0,s1
    8000207c:	02813083          	ld	ra,40(sp)
    80002080:	02013403          	ld	s0,32(sp)
    80002084:	01813483          	ld	s1,24(sp)
    80002088:	01013903          	ld	s2,16(sp)
    8000208c:	00813983          	ld	s3,8(sp)
    80002090:	03010113          	addi	sp,sp,48
    80002094:	00008067          	ret
    if (result != 0) mem_free(stackSpace);   // nit nije nastala - vrati stek
    80002098:	00070513          	mv	a0,a4
    8000209c:	00000097          	auipc	ra,0x0
    800020a0:	f54080e7          	jalr	-172(ra) # 80001ff0 <_Z8mem_freePv>
    800020a4:	fd5ff06f          	j	80002078 <_Z13thread_createPP7_threadPFvPvES2_+0x60>
    if (!handle || !start_routine) return -1;
    800020a8:	fff00493          	li	s1,-1
    800020ac:	fcdff06f          	j	80002078 <_Z13thread_createPP7_threadPFvPvES2_+0x60>
    800020b0:	fff00493          	li	s1,-1
    800020b4:	fc5ff06f          	j	80002078 <_Z13thread_createPP7_threadPFvPvES2_+0x60>
    if (!stackSpace) return -2;
    800020b8:	ffe00493          	li	s1,-2
    800020bc:	fbdff06f          	j	80002078 <_Z13thread_createPP7_threadPFvPvES2_+0x60>

00000000800020c0 <_Z11thread_exitv>:

int thread_exit() {
    800020c0:	ff010113          	addi	sp,sp,-16
    800020c4:	00813423          	sd	s0,8(sp)
    800020c8:	01010413          	addi	s0,sp,16
    register uint64 code asm("a0") = 0x12;
    800020cc:	01200513          	li	a0,18
    asm volatile("ecall" : "=r"(code) : "r"(code) : "memory");
    800020d0:	00000073          	ecall
    return (int)code;   // dovde stize samo u slucaju neuspeha
}
    800020d4:	0005051b          	sext.w	a0,a0
    800020d8:	00813403          	ld	s0,8(sp)
    800020dc:	01010113          	addi	sp,sp,16
    800020e0:	00008067          	ret

00000000800020e4 <_Z15thread_dispatchv>:

void thread_dispatch() {
    800020e4:	ff010113          	addi	sp,sp,-16
    800020e8:	00813423          	sd	s0,8(sp)
    800020ec:	01010413          	addi	s0,sp,16
    register uint64 code asm("a0") = 0x13;
    800020f0:	01300513          	li	a0,19
    asm volatile("ecall" : "=r"(code) : "r"(code) : "memory");
    800020f4:	00000073          	ecall
}
    800020f8:	00813403          	ld	s0,8(sp)
    800020fc:	01010113          	addi	sp,sp,16
    80002100:	00008067          	ret

0000000080002104 <_Z4getcv>:

char getc() {
    80002104:	ff010113          	addi	sp,sp,-16
    80002108:	00813423          	sd	s0,8(sp)
    8000210c:	01010413          	addi	s0,sp,16
    register uint64 code asm("a0") = 0x41;
    80002110:	04100513          	li	a0,65
    asm volatile("ecall" : "=r"(code) : "r"(code) : "memory");
    80002114:	00000073          	ecall
    return (char)code;
}
    80002118:	0ff57513          	andi	a0,a0,255
    8000211c:	00813403          	ld	s0,8(sp)
    80002120:	01010113          	addi	sp,sp,16
    80002124:	00008067          	ret

0000000080002128 <_Z4putcc>:

void putc(char c) {
    80002128:	ff010113          	addi	sp,sp,-16
    8000212c:	00813423          	sd	s0,8(sp)
    80002130:	01010413          	addi	s0,sp,16
    80002134:	00050593          	mv	a1,a0
    register uint64 code asm("a0") = 0x42;
    80002138:	04200513          	li	a0,66
    register uint64 ch   asm("a1") = (uint64)c;
    asm volatile("ecall" : "=r"(code) : "r"(code), "r"(ch) : "memory");
    8000213c:	00000073          	ecall
}
    80002140:	00813403          	ld	s0,8(sp)
    80002144:	01010113          	addi	sp,sp,16
    80002148:	00008067          	ret

000000008000214c <_Z5kputcc>:
#include "../h/print.hpp"

// posalji jedan znak kontroleru konzole (polling)
void kputc(char c) {
    8000214c:	ff010113          	addi	sp,sp,-16
    80002150:	00813423          	sd	s0,8(sp)
    80002154:	01010413          	addi	s0,sp,16
    // CONSOLE_STATUS je adresa (konstanta iz hw.h); da procitamo bajt sa te
    // adrese, kastujemo broj u pokazivac na volatile char pa dereferenciramo.
    // volatile: vrednost menja hardver, kompajler mora stvarno da cita
    // memoriju u svakom prolazu petlje, ne sme da kesira
    while ((*(volatile char*)CONSOLE_STATUS & (1 << 5)) == 0) {
    80002158:	00003797          	auipc	a5,0x3
    8000215c:	eb87b783          	ld	a5,-328(a5) # 80005010 <CONSOLE_STATUS>
    80002160:	0007c783          	lbu	a5,0(a5)
    80002164:	0ff7f793          	andi	a5,a5,255
    80002168:	0207f793          	andi	a5,a5,32
    8000216c:	fe0786e3          	beqz	a5,80002158 <_Z5kputcc+0xc>
        // bit 5 == 0 znaci "nisam spreman da primim znak za slanje"
    }
    // spreman: upisi bajt u registar za slanje
    *(volatile char*)CONSOLE_TX_DATA = c;
    80002170:	00003797          	auipc	a5,0x3
    80002174:	e987b783          	ld	a5,-360(a5) # 80005008 <CONSOLE_TX_DATA>
    80002178:	00a78023          	sb	a0,0(a5)
}
    8000217c:	00813403          	ld	s0,8(sp)
    80002180:	01010113          	addi	sp,sp,16
    80002184:	00008067          	ret

0000000080002188 <_Z5kputsPKc>:

// ispisi ceo string, znak po znak
void kputs(const char* s) {
    80002188:	fe010113          	addi	sp,sp,-32
    8000218c:	00113c23          	sd	ra,24(sp)
    80002190:	00813823          	sd	s0,16(sp)
    80002194:	00913423          	sd	s1,8(sp)
    80002198:	02010413          	addi	s0,sp,32
    8000219c:	00050493          	mv	s1,a0
    while (*s) kputc(*s++);
    800021a0:	0004c503          	lbu	a0,0(s1)
    800021a4:	00050a63          	beqz	a0,800021b8 <_Z5kputsPKc+0x30>
    800021a8:	00148493          	addi	s1,s1,1
    800021ac:	00000097          	auipc	ra,0x0
    800021b0:	fa0080e7          	jalr	-96(ra) # 8000214c <_Z5kputcc>
    800021b4:	fedff06f          	j	800021a0 <_Z5kputsPKc+0x18>
}
    800021b8:	01813083          	ld	ra,24(sp)
    800021bc:	01013403          	ld	s0,16(sp)
    800021c0:	00813483          	ld	s1,8(sp)
    800021c4:	02010113          	addi	sp,sp,32
    800021c8:	00008067          	ret

00000000800021cc <_Z7kputhexm>:

// ispisi 64-bitni broj heksadecimalno (fiksno 16 cifara)
void kputhex(uint64 n) {
    800021cc:	fe010113          	addi	sp,sp,-32
    800021d0:	00113c23          	sd	ra,24(sp)
    800021d4:	00813823          	sd	s0,16(sp)
    800021d8:	00913423          	sd	s1,8(sp)
    800021dc:	01213023          	sd	s2,0(sp)
    800021e0:	02010413          	addi	s0,sp,32
    800021e4:	00050913          	mv	s2,a0
    kputs("0x");
    800021e8:	00003517          	auipc	a0,0x3
    800021ec:	f3050513          	addi	a0,a0,-208 # 80005118 <CONSOLE_STATUS+0x108>
    800021f0:	00000097          	auipc	ra,0x0
    800021f4:	f98080e7          	jalr	-104(ra) # 80002188 <_Z5kputsPKc>
    for (int shift = 60; shift >= 0; shift -= 4) {
    800021f8:	03c00493          	li	s1,60
    800021fc:	0140006f          	j	80002210 <_Z7kputhexm+0x44>
        uint64 digit = (n >> shift) & 0xF;
        char c;
        if (digit < 10) {
            c = '0' + digit;
        } else {
            c = 'a' + (digit - 10);
    80002200:	05750513          	addi	a0,a0,87
        }
        kputc(c);
    80002204:	00000097          	auipc	ra,0x0
    80002208:	f48080e7          	jalr	-184(ra) # 8000214c <_Z5kputcc>
    for (int shift = 60; shift >= 0; shift -= 4) {
    8000220c:	ffc4849b          	addiw	s1,s1,-4
    80002210:	0004ce63          	bltz	s1,8000222c <_Z7kputhexm+0x60>
        uint64 digit = (n >> shift) & 0xF;
    80002214:	00995533          	srl	a0,s2,s1
    80002218:	00f57513          	andi	a0,a0,15
        if (digit < 10) {
    8000221c:	00900793          	li	a5,9
    80002220:	fea7e0e3          	bltu	a5,a0,80002200 <_Z7kputhexm+0x34>
            c = '0' + digit;
    80002224:	03050513          	addi	a0,a0,48
    80002228:	fddff06f          	j	80002204 <_Z7kputhexm+0x38>
    }
}
    8000222c:	01813083          	ld	ra,24(sp)
    80002230:	01013403          	ld	s0,16(sp)
    80002234:	00813483          	ld	s1,8(sp)
    80002238:	00013903          	ld	s2,0(sp)
    8000223c:	02010113          	addi	sp,sp,32
    80002240:	00008067          	ret

0000000080002244 <handleTrap>:
#include "../h/tcb.hpp"

// zajednicki c deo prekidne rutine: cita scause i grana se na obradu.
// a0..a4 parametri se poklapaju sa registrima a0..a4 u trenutku trapa
// (trap.S ih ne dira pre call-a), pa abi argumente citamo direktno.
extern "C" uint64 handleTrap(uint64 a0, uint64 a1, uint64 a2, uint64 a3, uint64 a4) {
    80002244:	fc010113          	addi	sp,sp,-64
    80002248:	02113c23          	sd	ra,56(sp)
    8000224c:	02813823          	sd	s0,48(sp)
    80002250:	02913423          	sd	s1,40(sp)
    80002254:	03213023          	sd	s2,32(sp)
    80002258:	01313c23          	sd	s3,24(sp)
    8000225c:	01413823          	sd	s4,16(sp)
    80002260:	01513423          	sd	s5,8(sp)
    80002264:	01613023          	sd	s6,0(sp)
    80002268:	04010413          	addi	s0,sp,64
    8000226c:	00050493          	mv	s1,a0
    uint64 cause, sepc, sstatus;
    asm volatile("csrr %0, scause"  : "=r"(cause));
    80002270:	14202973          	csrr	s2,scause
    asm volatile("csrr %0, sepc"    : "=r"(sepc));
    80002274:	14102a73          	csrr	s4,sepc
    asm volatile("csrr %0, sstatus" : "=r"(sstatus));
    80002278:	10002b73          	csrr	s6,sstatus
    // sepc i sstatus su DEO KONTEKSTA NITI: obrada moze da promeni nit
    // (dispatch), a dok ova nit spava, globalne csr registre ce puniti tudji
    // trapovi. zato ih odmah snimamo u lokalne promenljive (zive na steku ove
    // niti, parkiraju se s njom), a pred povratak vracamo bas nase vrednosti.

    uint64 topBit = cause >> 63;
    8000227c:	03f95a93          	srli	s5,s2,0x3f
    uint64 code   = cause & 0xff;
    80002280:	0ff97793          	andi	a5,s2,255
    uint64 ret    = a0;

    if (topBit == 1) {
    80002284:	0a0a9663          	bnez	s5,80002330 <handleTrap+0xec>
    80002288:	00058993          	mv	s3,a1
    8000228c:	00060513          	mv	a0,a2
    80002290:	00068593          	mv	a1,a3
            int irq = plic_claim();
            plic_complete(irq);
        }
        // sepc se ne uvecava: prekinuta instrukcija mora da se ponovi
    }
    else if (topBit == 0 && (code == 8 || code == 9)) {
    80002294:	000a9863          	bnez	s5,800022a4 <handleTrap+0x60>
    80002298:	ff878793          	addi	a5,a5,-8
    8000229c:	00100693          	li	a3,1
    800022a0:	0cf6f263          	bgeu	a3,a5,80002364 <handleTrap+0x120>
        }
    }
    else {
        // nepoznat uzrok (izuzetak koji ne umemo da obradimo): panika.
        // ne vracamo se - sepc bi pokazivao na istu instrukciju i vrteli bismo se.
        kputs("PANIC: cause="); kputhex(cause);
    800022a4:	00003517          	auipc	a0,0x3
    800022a8:	e7c50513          	addi	a0,a0,-388 # 80005120 <CONSOLE_STATUS+0x110>
    800022ac:	00000097          	auipc	ra,0x0
    800022b0:	edc080e7          	jalr	-292(ra) # 80002188 <_Z5kputsPKc>
    800022b4:	00090513          	mv	a0,s2
    800022b8:	00000097          	auipc	ra,0x0
    800022bc:	f14080e7          	jalr	-236(ra) # 800021cc <_Z7kputhexm>
        kputs(" sepc=");        kputhex(sepc);
    800022c0:	00003517          	auipc	a0,0x3
    800022c4:	e7050513          	addi	a0,a0,-400 # 80005130 <CONSOLE_STATUS+0x120>
    800022c8:	00000097          	auipc	ra,0x0
    800022cc:	ec0080e7          	jalr	-320(ra) # 80002188 <_Z5kputsPKc>
    800022d0:	000a0513          	mv	a0,s4
    800022d4:	00000097          	auipc	ra,0x0
    800022d8:	ef8080e7          	jalr	-264(ra) # 800021cc <_Z7kputhexm>
        kputs("\n");
    800022dc:	00003517          	auipc	a0,0x3
    800022e0:	1ec50513          	addi	a0,a0,492 # 800054c8 <CONSOLE_STATUS+0x4b8>
    800022e4:	00000097          	auipc	ra,0x0
    800022e8:	ea4080e7          	jalr	-348(ra) # 80002188 <_Z5kputsPKc>
        *(volatile int*)0x100000 = 0x5555;   // halt emulatora
    800022ec:	00100737          	lui	a4,0x100
    800022f0:	000057b7          	lui	a5,0x5
    800022f4:	5557879b          	addiw	a5,a5,1365
    800022f8:	00f72023          	sw	a5,0(a4) # 100000 <_entry-0x7ff00000>
    }

    // svako se vraca sa SVOJIM vrednostima, ma koliko dugo spavao
    asm volatile("csrw sstatus, %0" : : "r"(sstatus));
    800022fc:	100b1073          	csrw	sstatus,s6
    asm volatile("csrw sepc, %0"    : : "r"(sepc));
    80002300:	141a1073          	csrw	sepc,s4
    return ret;
}
    80002304:	00048513          	mv	a0,s1
    80002308:	03813083          	ld	ra,56(sp)
    8000230c:	03013403          	ld	s0,48(sp)
    80002310:	02813483          	ld	s1,40(sp)
    80002314:	02013903          	ld	s2,32(sp)
    80002318:	01813983          	ld	s3,24(sp)
    8000231c:	01013a03          	ld	s4,16(sp)
    80002320:	00813a83          	ld	s5,8(sp)
    80002324:	00013b03          	ld	s6,0(sp)
    80002328:	04010113          	addi	sp,sp,64
    8000232c:	00008067          	ret
        if (code == 1) {
    80002330:	00100713          	li	a4,1
    80002334:	02e78063          	beq	a5,a4,80002354 <handleTrap+0x110>
        } else if (code == 9) {
    80002338:	00900713          	li	a4,9
    8000233c:	fce790e3          	bne	a5,a4,800022fc <handleTrap+0xb8>
            int irq = plic_claim();
    80002340:	00001097          	auipc	ra,0x1
    80002344:	204080e7          	jalr	516(ra) # 80003544 <plic_claim>
            plic_complete(irq);
    80002348:	00001097          	auipc	ra,0x1
    8000234c:	234080e7          	jalr	564(ra) # 8000357c <plic_complete>
    80002350:	fadff06f          	j	800022fc <handleTrap+0xb8>
            asm volatile("csrr %0, sip" : "=r"(sip));
    80002354:	144027f3          	csrr	a5,sip
            sip &= ~(1UL << 1);
    80002358:	ffd7f793          	andi	a5,a5,-3
            asm volatile("csrw sip, %0" : : "r"(sip));
    8000235c:	14479073          	csrw	sip,a5
    80002360:	f9dff06f          	j	800022fc <handleTrap+0xb8>
        sepc += 4;   // preskoci sam ecall - u lokalnoj kopiji!
    80002364:	004a0a13          	addi	s4,s4,4
        switch (a0) {
    80002368:	01300793          	li	a5,19
    8000236c:	0297e463          	bltu	a5,s1,80002394 <handleTrap+0x150>
    80002370:	10048463          	beqz	s1,80002478 <handleTrap+0x234>
    80002374:	1097e663          	bltu	a5,s1,80002480 <handleTrap+0x23c>
    80002378:	00249813          	slli	a6,s1,0x2
    8000237c:	00003697          	auipc	a3,0x3
    80002380:	dbc68693          	addi	a3,a3,-580 # 80005138 <CONSOLE_STATUS+0x128>
    80002384:	00d80833          	add	a6,a6,a3
    80002388:	00082783          	lw	a5,0(a6)
    8000238c:	00d787b3          	add	a5,a5,a3
    80002390:	00078067          	jr	a5 # 5000 <_entry-0x7fffb000>
    80002394:	04100793          	li	a5,65
    80002398:	0af48c63          	beq	s1,a5,80002450 <handleTrap+0x20c>
    8000239c:	04200793          	li	a5,66
    800023a0:	02f49a63          	bne	s1,a5,800023d4 <handleTrap+0x190>
                while ((*(volatile char*)CONSOLE_STATUS & CONSOLE_TX_STATUS_BIT) == 0) {}
    800023a4:	00003797          	auipc	a5,0x3
    800023a8:	c6c7b783          	ld	a5,-916(a5) # 80005010 <CONSOLE_STATUS>
    800023ac:	0007c783          	lbu	a5,0(a5)
    800023b0:	0ff7f793          	andi	a5,a5,255
    800023b4:	0207f793          	andi	a5,a5,32
    800023b8:	fe0786e3          	beqz	a5,800023a4 <handleTrap+0x160>
                *(volatile char*)CONSOLE_TX_DATA = (char)a1;
    800023bc:	0ff9f993          	andi	s3,s3,255
    800023c0:	00003797          	auipc	a5,0x3
    800023c4:	c487b783          	ld	a5,-952(a5) # 80005008 <CONSOLE_TX_DATA>
    800023c8:	01378023          	sb	s3,0(a5)
                ret = 0;
    800023cc:	000a8493          	mv	s1,s5
                break;
    800023d0:	f2dff06f          	j	800022fc <handleTrap+0xb8>
        switch (a0) {
    800023d4:	fff00493          	li	s1,-1
    800023d8:	f25ff06f          	j	800022fc <handleTrap+0xb8>
                ret = (uint64)MemoryAllocator::alloc(a1 * MEM_BLOCK_SIZE);
    800023dc:	00699513          	slli	a0,s3,0x6
    800023e0:	00000097          	auipc	ra,0x0
    800023e4:	5b8080e7          	jalr	1464(ra) # 80002998 <_ZN15MemoryAllocator5allocEm>
    800023e8:	00050493          	mv	s1,a0
                break;
    800023ec:	f11ff06f          	j	800022fc <handleTrap+0xb8>
                ret = (uint64)MemoryAllocator::free((void*)a1);
    800023f0:	00098513          	mv	a0,s3
    800023f4:	00000097          	auipc	ra,0x0
    800023f8:	6e0080e7          	jalr	1760(ra) # 80002ad4 <_ZN15MemoryAllocator4freeEPv>
    800023fc:	00050493          	mv	s1,a0
                break;
    80002400:	efdff06f          	j	800022fc <handleTrap+0xb8>
                TCB* tcb = TCB::createThread((TCB::Body)a2, (void*)a3, (void*)a4, false);
    80002404:	00000693          	li	a3,0
    80002408:	00070613          	mv	a2,a4
    8000240c:	00000097          	auipc	ra,0x0
    80002410:	2b4080e7          	jalr	692(ra) # 800026c0 <_ZN3TCB12createThreadEPFvPvES0_S0_b>
                if (tcb) { *(TCB**)a1 = tcb; ret = 0; }
    80002414:	06050a63          	beqz	a0,80002488 <handleTrap+0x244>
    80002418:	00a9b023          	sd	a0,0(s3)
    8000241c:	000a8493          	mv	s1,s5
    80002420:	eddff06f          	j	800022fc <handleTrap+0xb8>

    // sinhrona promena konteksta: tekuca nit ustupa procesor sledecoj iz reda
    static void dispatch();

    bool isFinished() const { return finished; }
    void setFinished(bool f) { finished = f; }
    80002424:	00004797          	auipc	a5,0x4
    80002428:	98c7b783          	ld	a5,-1652(a5) # 80005db0 <_ZN3TCB7runningE>
    8000242c:	00100713          	li	a4,1
    80002430:	02e78423          	sb	a4,40(a5)
                TCB::dispatch();
    80002434:	00000097          	auipc	ra,0x0
    80002438:	370080e7          	jalr	880(ra) # 800027a4 <_ZN3TCB8dispatchEv>
                break;
    8000243c:	ec1ff06f          	j	800022fc <handleTrap+0xb8>
                TCB::dispatch();
    80002440:	00000097          	auipc	ra,0x0
    80002444:	364080e7          	jalr	868(ra) # 800027a4 <_ZN3TCB8dispatchEv>
                ret = 0;
    80002448:	000a8493          	mv	s1,s5
                break;
    8000244c:	eb1ff06f          	j	800022fc <handleTrap+0xb8>
                while ((*(volatile char*)CONSOLE_STATUS & CONSOLE_RX_STATUS_BIT) == 0) {}
    80002450:	00003797          	auipc	a5,0x3
    80002454:	bc07b783          	ld	a5,-1088(a5) # 80005010 <CONSOLE_STATUS>
    80002458:	0007c783          	lbu	a5,0(a5)
    8000245c:	0017f793          	andi	a5,a5,1
    80002460:	fe0788e3          	beqz	a5,80002450 <handleTrap+0x20c>
                ret = (uint64)(*(volatile char*)CONSOLE_RX_DATA);
    80002464:	00003797          	auipc	a5,0x3
    80002468:	b9c7b783          	ld	a5,-1124(a5) # 80005000 <CONSOLE_RX_DATA>
    8000246c:	0007c483          	lbu	s1,0(a5)
    80002470:	0ff4f493          	andi	s1,s1,255
                break;
    80002474:	e89ff06f          	j	800022fc <handleTrap+0xb8>
        switch (a0) {
    80002478:	fff00493          	li	s1,-1
    8000247c:	e81ff06f          	j	800022fc <handleTrap+0xb8>
    80002480:	fff00493          	li	s1,-1
    80002484:	e79ff06f          	j	800022fc <handleTrap+0xb8>
                else     { ret = (uint64)-1; }
    80002488:	fff00493          	li	s1,-1
    8000248c:	e71ff06f          	j	800022fc <handleTrap+0xb8>

0000000080002490 <_Z8userMainv>:
// #include "../test/Threads_CPP_API_test.hpp"
// TEST 7 (zadatak 2., testiranje da li se korisnicki kod izvrsava u korisnickom rezimu)
#include "../test/System_Mode_test.hpp"
#endif

void userMain() {
    80002490:	fe010113          	addi	sp,sp,-32
    80002494:	00113c23          	sd	ra,24(sp)
    80002498:	00813823          	sd	s0,16(sp)
    8000249c:	00913423          	sd	s1,8(sp)
    800024a0:	01213023          	sd	s2,0(sp)
    800024a4:	02010413          	addi	s0,sp,32
    printString("Unesite broj testa? [1-7]\n");
    800024a8:	00003517          	auipc	a0,0x3
    800024ac:	ce050513          	addi	a0,a0,-800 # 80005188 <CONSOLE_STATUS+0x178>
    800024b0:	fffff097          	auipc	ra,0xfffff
    800024b4:	254080e7          	jalr	596(ra) # 80001704 <_Z11printStringPKc>
    int test = getc() - '0';
    800024b8:	00000097          	auipc	ra,0x0
    800024bc:	c4c080e7          	jalr	-948(ra) # 80002104 <_Z4getcv>
    800024c0:	0005091b          	sext.w	s2,a0
    800024c4:	fd05049b          	addiw	s1,a0,-48
    getc(); // enter posle broja
    800024c8:	00000097          	auipc	ra,0x0
    800024cc:	c3c080e7          	jalr	-964(ra) # 80002104 <_Z4getcv>
            printString("Nije navedeno da je zadatak 2 implementiran\n");
            return;
        }
    }

    if (test >= 3 && test <= 4) {
    800024d0:	fcd9071b          	addiw	a4,s2,-51
    800024d4:	00100793          	li	a5,1
    800024d8:	02e7fe63          	bgeu	a5,a4,80002514 <_Z8userMainv+0x84>
            printString("Nije navedeno da je zadatak 3 implementiran\n");
            return;
        }
    }

    if (test >= 5 && test <= 6) {
    800024dc:	fcb9091b          	addiw	s2,s2,-53
    800024e0:	00100793          	li	a5,1
    800024e4:	0527f263          	bgeu	a5,s2,80002528 <_Z8userMainv+0x98>
            printString("Nije navedeno da je zadatak 4 implementiran\n");
            return;
        }
    }

    switch (test) {
    800024e8:	00200793          	li	a5,2
    800024ec:	08f48063          	beq	s1,a5,8000256c <_Z8userMainv+0xdc>
    800024f0:	00700793          	li	a5,7
    800024f4:	08f48663          	beq	s1,a5,80002580 <_Z8userMainv+0xf0>
    800024f8:	00100793          	li	a5,1
    800024fc:	04f48063          	beq	s1,a5,8000253c <_Z8userMainv+0xac>
            printString("Test se nije uspesno zavrsio\n");
            printString("TEST 7 (zadatak 2., testiranje da li se korisnicki kod izvrsava u korisnickom rezimu)\n");
#endif
            break;
        default:
            printString("Niste uneli odgovarajuci broj za test\n");
    80002500:	00003517          	auipc	a0,0x3
    80002504:	de850513          	addi	a0,a0,-536 # 800052e8 <CONSOLE_STATUS+0x2d8>
    80002508:	fffff097          	auipc	ra,0xfffff
    8000250c:	1fc080e7          	jalr	508(ra) # 80001704 <_Z11printStringPKc>
    80002510:	0440006f          	j	80002554 <_Z8userMainv+0xc4>
            printString("Nije navedeno da je zadatak 3 implementiran\n");
    80002514:	00003517          	auipc	a0,0x3
    80002518:	c9450513          	addi	a0,a0,-876 # 800051a8 <CONSOLE_STATUS+0x198>
    8000251c:	fffff097          	auipc	ra,0xfffff
    80002520:	1e8080e7          	jalr	488(ra) # 80001704 <_Z11printStringPKc>
            return;
    80002524:	0300006f          	j	80002554 <_Z8userMainv+0xc4>
            printString("Nije navedeno da je zadatak 4 implementiran\n");
    80002528:	00003517          	auipc	a0,0x3
    8000252c:	cb050513          	addi	a0,a0,-848 # 800051d8 <CONSOLE_STATUS+0x1c8>
    80002530:	fffff097          	auipc	ra,0xfffff
    80002534:	1d4080e7          	jalr	468(ra) # 80001704 <_Z11printStringPKc>
            return;
    80002538:	01c0006f          	j	80002554 <_Z8userMainv+0xc4>
            Threads_C_API_test();
    8000253c:	fffff097          	auipc	ra,0xfffff
    80002540:	0cc080e7          	jalr	204(ra) # 80001608 <_Z18Threads_C_API_testv>
            printString("TEST 1 (zadatak 2, niti C API i sinhrona promena konteksta)\n");
    80002544:	00003517          	auipc	a0,0x3
    80002548:	cc450513          	addi	a0,a0,-828 # 80005208 <CONSOLE_STATUS+0x1f8>
    8000254c:	fffff097          	auipc	ra,0xfffff
    80002550:	1b8080e7          	jalr	440(ra) # 80001704 <_Z11printStringPKc>
    }
}
    80002554:	01813083          	ld	ra,24(sp)
    80002558:	01013403          	ld	s0,16(sp)
    8000255c:	00813483          	ld	s1,8(sp)
    80002560:	00013903          	ld	s2,0(sp)
    80002564:	02010113          	addi	sp,sp,32
    80002568:	00008067          	ret
            printString("TEST 2: c++ api jos nije implementiran\n");
    8000256c:	00003517          	auipc	a0,0x3
    80002570:	cdc50513          	addi	a0,a0,-804 # 80005248 <CONSOLE_STATUS+0x238>
    80002574:	fffff097          	auipc	ra,0xfffff
    80002578:	190080e7          	jalr	400(ra) # 80001704 <_Z11printStringPKc>
            break;
    8000257c:	fd9ff06f          	j	80002554 <_Z8userMainv+0xc4>
            System_Mode_test();
    80002580:	00000097          	auipc	ra,0x0
    80002584:	940080e7          	jalr	-1728(ra) # 80001ec0 <_Z16System_Mode_testv>
            printString("Test se nije uspesno zavrsio\n");
    80002588:	00003517          	auipc	a0,0x3
    8000258c:	ce850513          	addi	a0,a0,-792 # 80005270 <CONSOLE_STATUS+0x260>
    80002590:	fffff097          	auipc	ra,0xfffff
    80002594:	174080e7          	jalr	372(ra) # 80001704 <_Z11printStringPKc>
            printString("TEST 7 (zadatak 2., testiranje da li se korisnicki kod izvrsava u korisnickom rezimu)\n");
    80002598:	00003517          	auipc	a0,0x3
    8000259c:	cf850513          	addi	a0,a0,-776 # 80005290 <CONSOLE_STATUS+0x280>
    800025a0:	fffff097          	auipc	ra,0xfffff
    800025a4:	164080e7          	jalr	356(ra) # 80001704 <_Z11printStringPKc>
            break;
    800025a8:	fadff06f          	j	80002554 <_Z8userMainv+0xc4>

00000000800025ac <_ZN3TCB11userWrapperEv>:
}

// u-mode deo omotaca: OVO se izvrsava u korisnickom rezimu.
// tcb sme da CITA (isti adresni prostor, nema memorijske zastite -
// granica privilegija su instrukcije), ali u jezgro sme samo kroz ecall
void TCB::userWrapper() {
    800025ac:	ff010113          	addi	sp,sp,-16
    800025b0:	00113423          	sd	ra,8(sp)
    800025b4:	00813023          	sd	s0,0(sp)
    800025b8:	01010413          	addi	s0,sp,16
    running->body(running->arg);
    800025bc:	00003797          	auipc	a5,0x3
    800025c0:	7f47b783          	ld	a5,2036(a5) # 80005db0 <_ZN3TCB7runningE>
    800025c4:	0007b703          	ld	a4,0(a5)
    800025c8:	0087b503          	ld	a0,8(a5)
    800025cc:	000700e7          	jalr	a4
    thread_exit();      // ecall - jedini legalan povratak u jezgro
    800025d0:	00000097          	auipc	ra,0x0
    800025d4:	af0080e7          	jalr	-1296(ra) # 800020c0 <_Z11thread_exitv>
    for (;;) {}         // nedostizno; osiguranje da se nikad ne "ispadne"
    800025d8:	0000006f          	j	800025d8 <_ZN3TCB11userWrapperEv+0x2c>

00000000800025dc <_ZN3TCBnwEm>:
void* TCB::operator new(size_t size) {
    800025dc:	ff010113          	addi	sp,sp,-16
    800025e0:	00113423          	sd	ra,8(sp)
    800025e4:	00813023          	sd	s0,0(sp)
    800025e8:	01010413          	addi	s0,sp,16
    return MemoryAllocator::alloc(size);
    800025ec:	00000097          	auipc	ra,0x0
    800025f0:	3ac080e7          	jalr	940(ra) # 80002998 <_ZN15MemoryAllocator5allocEm>
}
    800025f4:	00813083          	ld	ra,8(sp)
    800025f8:	00013403          	ld	s0,0(sp)
    800025fc:	01010113          	addi	sp,sp,16
    80002600:	00008067          	ret

0000000080002604 <_ZN3TCBdlEPv>:
void TCB::operator delete(void* ptr) {
    80002604:	ff010113          	addi	sp,sp,-16
    80002608:	00113423          	sd	ra,8(sp)
    8000260c:	00813023          	sd	s0,0(sp)
    80002610:	01010413          	addi	s0,sp,16
    MemoryAllocator::free(ptr);
    80002614:	00000097          	auipc	ra,0x0
    80002618:	4c0080e7          	jalr	1216(ra) # 80002ad4 <_ZN15MemoryAllocator4freeEPv>
}
    8000261c:	00813083          	ld	ra,8(sp)
    80002620:	00013403          	ld	s0,0(sp)
    80002624:	01010113          	addi	sp,sp,16
    80002628:	00008067          	ret

000000008000262c <_ZN3TCBC1EPFvPvES0_Pmb>:
TCB::TCB(Body body, void* arg, uint64* stack, bool systemLevel)
    8000262c:	ff010113          	addi	sp,sp,-16
    80002630:	00813423          	sd	s0,8(sp)
    80002634:	01010413          	addi	s0,sp,16
      finished(false), systemLevel(systemLevel), next(nullptr)
    80002638:	00b53023          	sd	a1,0(a0)
    8000263c:	00c53423          	sd	a2,8(a0)
    80002640:	00d53823          	sd	a3,16(a0)
    80002644:	00053c23          	sd	zero,24(a0)
    80002648:	02053023          	sd	zero,32(a0)
    8000264c:	02050423          	sb	zero,40(a0)
    80002650:	02e504a3          	sb	a4,41(a0)
    80002654:	02053823          	sd	zero,48(a0)
{}
    80002658:	00813403          	ld	s0,8(sp)
    8000265c:	01010113          	addi	sp,sp,16
    80002660:	00008067          	ret

0000000080002664 <_ZN3TCB10reapZombieEv>:
    if (!zombie) return;
    80002664:	00003797          	auipc	a5,0x3
    80002668:	7447b783          	ld	a5,1860(a5) # 80005da8 <_ZN3TCB6zombieE>
    8000266c:	04078863          	beqz	a5,800026bc <_ZN3TCB10reapZombieEv+0x58>
void TCB::reapZombie() {
    80002670:	ff010113          	addi	sp,sp,-16
    80002674:	00113423          	sd	ra,8(sp)
    80002678:	00813023          	sd	s0,0(sp)
    8000267c:	01010413          	addi	s0,sp,16
    if (zombie->stack) MemoryAllocator::free(zombie->stack);
    80002680:	0107b503          	ld	a0,16(a5)
    80002684:	00050663          	beqz	a0,80002690 <_ZN3TCB10reapZombieEv+0x2c>
    80002688:	00000097          	auipc	ra,0x0
    8000268c:	44c080e7          	jalr	1100(ra) # 80002ad4 <_ZN15MemoryAllocator4freeEPv>
    delete zombie;
    80002690:	00003517          	auipc	a0,0x3
    80002694:	71853503          	ld	a0,1816(a0) # 80005da8 <_ZN3TCB6zombieE>
    80002698:	00050663          	beqz	a0,800026a4 <_ZN3TCB10reapZombieEv+0x40>
    8000269c:	00000097          	auipc	ra,0x0
    800026a0:	f68080e7          	jalr	-152(ra) # 80002604 <_ZN3TCBdlEPv>
    zombie = nullptr;
    800026a4:	00003797          	auipc	a5,0x3
    800026a8:	7007b223          	sd	zero,1796(a5) # 80005da8 <_ZN3TCB6zombieE>
}
    800026ac:	00813083          	ld	ra,8(sp)
    800026b0:	00013403          	ld	s0,0(sp)
    800026b4:	01010113          	addi	sp,sp,16
    800026b8:	00008067          	ret
    800026bc:	00008067          	ret

00000000800026c0 <_ZN3TCB12createThreadEPFvPvES0_S0_b>:
}

TCB* TCB::createThread(Body body, void* arg, void* stackSpace, bool systemLevel) {
    800026c0:	fc010113          	addi	sp,sp,-64
    800026c4:	02113c23          	sd	ra,56(sp)
    800026c8:	02813823          	sd	s0,48(sp)
    800026cc:	02913423          	sd	s1,40(sp)
    800026d0:	03213023          	sd	s2,32(sp)
    800026d4:	01313c23          	sd	s3,24(sp)
    800026d8:	01413823          	sd	s4,16(sp)
    800026dc:	01513423          	sd	s5,8(sp)
    800026e0:	04010413          	addi	s0,sp,64
    800026e4:	00050993          	mv	s3,a0
    800026e8:	00058a13          	mv	s4,a1
    800026ec:	00060493          	mv	s1,a2
    800026f0:	00068a93          	mv	s5,a3
    // prava nit bez steka ne moze da postoji
    if (body && !stackSpace) return nullptr;
    800026f4:	00050463          	beqz	a0,800026fc <_ZN3TCB12createThreadEPFvPvES0_S0_b+0x3c>
    800026f8:	0a060263          	beqz	a2,8000279c <_ZN3TCB12createThreadEPFvPvES0_S0_b+0xdc>

    TCB* tcb = new TCB(body, arg, (uint64*)stackSpace, systemLevel);
    800026fc:	03800513          	li	a0,56
    80002700:	00000097          	auipc	ra,0x0
    80002704:	edc080e7          	jalr	-292(ra) # 800025dc <_ZN3TCBnwEm>
    80002708:	00050913          	mv	s2,a0
    8000270c:	000a8713          	mv	a4,s5
    80002710:	00048693          	mv	a3,s1
    80002714:	000a0613          	mv	a2,s4
    80002718:	00098593          	mv	a1,s3
    8000271c:	00000097          	auipc	ra,0x0
    80002720:	f10080e7          	jalr	-240(ra) # 8000262c <_ZN3TCBC1EPFvPvES0_Pmb>
    if (!tcb) return nullptr;
    80002724:	04090863          	beqz	s2,80002774 <_ZN3TCB12createThreadEPFvPvES0_S0_b+0xb4>

    if (body) {
    80002728:	04098663          	beqz	s3,80002774 <_ZN3TCB12createThreadEPFvPvES0_S0_b+0xb4>
        // bootstrap: falsifikuj proslost niti da izgleda kao da je "zaspala"
        // na samom ulazu u threadWrapper. prvo budjenje (contextSwitch) ce:
        // pokupiti 12 laznih s-registara sa steka, pa ret na threadWrapper.
        uint64 top = (uint64)stackSpace + DEFAULT_STACK_SIZE;   // stek raste ka nizim adresama
        tcb->context.sp = top - 96;                             // mesto za 12 "s-registara"
    8000272c:	00001637          	lui	a2,0x1
    80002730:	fa060613          	addi	a2,a2,-96 # fa0 <_entry-0x7ffff060>
    80002734:	00c48633          	add	a2,s1,a2
    80002738:	02c93023          	sd	a2,32(s2)
        uint64* fakeRegs = (uint64*)tcb->context.sp;
        for (int i = 0; i < 12; i++) fakeRegs[i] = 0;           // nit krece cistih ruku
    8000273c:	00000793          	li	a5,0
    80002740:	00b00713          	li	a4,11
    80002744:	00f74c63          	blt	a4,a5,8000275c <_ZN3TCB12createThreadEPFvPvES0_S0_b+0x9c>
    80002748:	00379713          	slli	a4,a5,0x3
    8000274c:	00e60733          	add	a4,a2,a4
    80002750:	00073023          	sd	zero,0(a4)
    80002754:	0017879b          	addiw	a5,a5,1
    80002758:	fe9ff06f          	j	80002740 <_ZN3TCB12createThreadEPFvPvES0_S0_b+0x80>
        tcb->context.ra = (uint64)&threadWrapper;
    8000275c:	00000797          	auipc	a5,0x0
    80002760:	0f478793          	addi	a5,a5,244 # 80002850 <_ZN3TCB13threadWrapperEv>
    80002764:	00f93c23          	sd	a5,24(s2)

        Scheduler::put(tcb);
    80002768:	00090513          	mv	a0,s2
    8000276c:	00000097          	auipc	ra,0x0
    80002770:	15c080e7          	jalr	348(ra) # 800028c8 <_ZN9Scheduler3putEP3TCB>
    }
    // nulta nit (body == nullptr, main): bez steka i bez reda - njen kontekst
    // ce prirodno upisati njen prvi contextSwitch
    return tcb;
}
    80002774:	00090513          	mv	a0,s2
    80002778:	03813083          	ld	ra,56(sp)
    8000277c:	03013403          	ld	s0,48(sp)
    80002780:	02813483          	ld	s1,40(sp)
    80002784:	02013903          	ld	s2,32(sp)
    80002788:	01813983          	ld	s3,24(sp)
    8000278c:	01013a03          	ld	s4,16(sp)
    80002790:	00813a83          	ld	s5,8(sp)
    80002794:	04010113          	addi	sp,sp,64
    80002798:	00008067          	ret
    if (body && !stackSpace) return nullptr;
    8000279c:	00060913          	mv	s2,a2
    800027a0:	fd5ff06f          	j	80002774 <_ZN3TCB12createThreadEPFvPvES0_S0_b+0xb4>

00000000800027a4 <_ZN3TCB8dispatchEv>:

// sinhrona promena konteksta: tekuca nit ustupa procesor
void TCB::dispatch() {
    800027a4:	fe010113          	addi	sp,sp,-32
    800027a8:	00113c23          	sd	ra,24(sp)
    800027ac:	00813823          	sd	s0,16(sp)
    800027b0:	00913423          	sd	s1,8(sp)
    800027b4:	01213023          	sd	s2,0(sp)
    800027b8:	02010413          	addi	s0,sp,32
    TCB* old = running;
    800027bc:	00003917          	auipc	s2,0x3
    800027c0:	5f493903          	ld	s2,1524(s2) # 80005db0 <_ZN3TCB7runningE>
    if (!old->finished) Scheduler::put(old);
    800027c4:	02894783          	lbu	a5,40(s2)
    800027c8:	04078a63          	beqz	a5,8000281c <_ZN3TCB8dispatchEv+0x78>
    else zombie = old;   // jos stojimo na njegovom steku - ciscenje kasnije!
    800027cc:	00003797          	auipc	a5,0x3
    800027d0:	5d27be23          	sd	s2,1500(a5) # 80005da8 <_ZN3TCB6zombieE>

    TCB* next = Scheduler::get();
    800027d4:	00000097          	auipc	ra,0x0
    800027d8:	134080e7          	jalr	308(ra) # 80002908 <_ZN9Scheduler3getEv>
    800027dc:	00050493          	mv	s1,a0
    if (!next) {
    800027e0:	04050663          	beqz	a0,8000282c <_ZN3TCB8dispatchEv+0x88>
        // nema nijedne spremne niti, a tekuca je gotova: sistem nema sta da radi
        kputs("PANIC: nema spremnih niti\n");
        *(volatile int*)0x100000 = 0x5555;
    }

    running = next;
    800027e4:	00003797          	auipc	a5,0x3
    800027e8:	5c97b623          	sd	s1,1484(a5) # 80005db0 <_ZN3TCB7runningE>
    contextSwitch(&old->context, &running->context);
    800027ec:	01848593          	addi	a1,s1,24
    800027f0:	01890513          	addi	a0,s2,24
    800027f4:	fffff097          	auipc	ra,0xfffff
    800027f8:	8bc080e7          	jalr	-1860(ra) # 800010b0 <contextSwitch>
    // budjenje: sad smo na steku probudjene niti - bezbedno pocisti zombija
    reapZombie();
    800027fc:	00000097          	auipc	ra,0x0
    80002800:	e68080e7          	jalr	-408(ra) # 80002664 <_ZN3TCB10reapZombieEv>
}
    80002804:	01813083          	ld	ra,24(sp)
    80002808:	01013403          	ld	s0,16(sp)
    8000280c:	00813483          	ld	s1,8(sp)
    80002810:	00013903          	ld	s2,0(sp)
    80002814:	02010113          	addi	sp,sp,32
    80002818:	00008067          	ret
    if (!old->finished) Scheduler::put(old);
    8000281c:	00090513          	mv	a0,s2
    80002820:	00000097          	auipc	ra,0x0
    80002824:	0a8080e7          	jalr	168(ra) # 800028c8 <_ZN9Scheduler3putEP3TCB>
    80002828:	fadff06f          	j	800027d4 <_ZN3TCB8dispatchEv+0x30>
        kputs("PANIC: nema spremnih niti\n");
    8000282c:	00003517          	auipc	a0,0x3
    80002830:	ae450513          	addi	a0,a0,-1308 # 80005310 <CONSOLE_STATUS+0x300>
    80002834:	00000097          	auipc	ra,0x0
    80002838:	954080e7          	jalr	-1708(ra) # 80002188 <_Z5kputsPKc>
        *(volatile int*)0x100000 = 0x5555;
    8000283c:	00100737          	lui	a4,0x100
    80002840:	000057b7          	lui	a5,0x5
    80002844:	5557879b          	addiw	a5,a5,1365
    80002848:	00f72023          	sw	a5,0(a4) # 100000 <_entry-0x7ff00000>
    8000284c:	f99ff06f          	j	800027e4 <_ZN3TCB8dispatchEv+0x40>

0000000080002850 <_ZN3TCB13threadWrapperEv>:
void TCB::threadWrapper() {
    80002850:	ff010113          	addi	sp,sp,-16
    80002854:	00113423          	sd	ra,8(sp)
    80002858:	00813023          	sd	s0,0(sp)
    8000285c:	01010413          	addi	s0,sp,16
    reapZombie();   // i rodjenje je budjenje: pocisti eventualnog prethodnika
    80002860:	00000097          	auipc	ra,0x0
    80002864:	e04080e7          	jalr	-508(ra) # 80002664 <_ZN3TCB10reapZombieEv>
    if (running->systemLevel) {
    80002868:	00003797          	auipc	a5,0x3
    8000286c:	5487b783          	ld	a5,1352(a5) # 80005db0 <_ZN3TCB7runningE>
    80002870:	0297c703          	lbu	a4,41(a5)
    80002874:	02070463          	beqz	a4,8000289c <_ZN3TCB13threadWrapperEv+0x4c>
        running->body(running->arg);
    80002878:	0007b703          	ld	a4,0(a5)
    8000287c:	0087b503          	ld	a0,8(a5)
    80002880:	000700e7          	jalr	a4
        running->finished = true;
    80002884:	00003797          	auipc	a5,0x3
    80002888:	52c7b783          	ld	a5,1324(a5) # 80005db0 <_ZN3TCB7runningE>
    8000288c:	00100713          	li	a4,1
    80002890:	02e78423          	sb	a4,40(a5)
        dispatch();     // odavde nema povratka
    80002894:	00000097          	auipc	ra,0x0
    80002898:	f10080e7          	jalr	-240(ra) # 800027a4 <_ZN3TCB8dispatchEv>
    uint64 target = (uint64)&userWrapper;
    8000289c:	00000797          	auipc	a5,0x0
    800028a0:	d1078793          	addi	a5,a5,-752 # 800025ac <_ZN3TCB11userWrapperEv>
    asm volatile("csrw sepc, %0" : : "r"(target));
    800028a4:	14179073          	csrw	sepc,a5
    asm volatile("csrr %0, sstatus" : "=r"(sstatus));
    800028a8:	100027f3          	csrr	a5,sstatus
    sstatus &= ~(1UL << 8);                    // spp = 0: sret vodi u u-mode
    800028ac:	eff7f793          	andi	a5,a5,-257
    asm volatile("csrw sstatus, %0" : : "r"(sstatus));
    800028b0:	10079073          	csrw	sstatus,a5
    asm volatile("sret");                      // spust: dalje u userWrapper
    800028b4:	10200073          	sret
}
    800028b8:	00813083          	ld	ra,8(sp)
    800028bc:	00013403          	ld	s0,0(sp)
    800028c0:	01010113          	addi	sp,sp,16
    800028c4:	00008067          	ret

00000000800028c8 <_ZN9Scheduler3putEP3TCB>:

TCB* Scheduler::head = nullptr;
TCB* Scheduler::tail = nullptr;

// stani na kraj reda
void Scheduler::put(TCB* thread) {
    800028c8:	ff010113          	addi	sp,sp,-16
    800028cc:	00813423          	sd	s0,8(sp)
    800028d0:	01010413          	addi	s0,sp,16
    thread->next = nullptr;
    800028d4:	02053823          	sd	zero,48(a0)
    if (tail) {
    800028d8:	00003797          	auipc	a5,0x3
    800028dc:	4e07b783          	ld	a5,1248(a5) # 80005db8 <_ZN9Scheduler4tailE>
    800028e0:	00078e63          	beqz	a5,800028fc <_ZN9Scheduler3putEP3TCB+0x34>
        tail->next = thread;   // dosadasnji poslednji pokaze na novog
    800028e4:	02a7b823          	sd	a0,48(a5)
    } else {
        head = thread;         // red je bio prazan: novi je i prvi
    }
    tail = thread;             // novi je u svakom slucaju poslednji
    800028e8:	00003797          	auipc	a5,0x3
    800028ec:	4ca7b823          	sd	a0,1232(a5) # 80005db8 <_ZN9Scheduler4tailE>
}
    800028f0:	00813403          	ld	s0,8(sp)
    800028f4:	01010113          	addi	sp,sp,16
    800028f8:	00008067          	ret
        head = thread;         // red je bio prazan: novi je i prvi
    800028fc:	00003797          	auipc	a5,0x3
    80002900:	4ca7b223          	sd	a0,1220(a5) # 80005dc0 <_ZN9Scheduler4headE>
    80002904:	fe5ff06f          	j	800028e8 <_ZN9Scheduler3putEP3TCB+0x20>

0000000080002908 <_ZN9Scheduler3getEv>:

// skini nit sa cela reda
TCB* Scheduler::get() {
    80002908:	ff010113          	addi	sp,sp,-16
    8000290c:	00813423          	sd	s0,8(sp)
    80002910:	01010413          	addi	s0,sp,16
    TCB* thread = head;
    80002914:	00003517          	auipc	a0,0x3
    80002918:	4ac53503          	ld	a0,1196(a0) # 80005dc0 <_ZN9Scheduler4headE>
    if (!thread) return nullptr;   // prazan red
    8000291c:	00050c63          	beqz	a0,80002934 <_ZN9Scheduler3getEv+0x2c>
    head = head->next;
    80002920:	03053783          	ld	a5,48(a0)
    80002924:	00003717          	auipc	a4,0x3
    80002928:	48f73e23          	sd	a5,1180(a4) # 80005dc0 <_ZN9Scheduler4headE>
    if (!head) tail = nullptr;     // skinuli smo i poslednjeg
    8000292c:	00078a63          	beqz	a5,80002940 <_ZN9Scheduler3getEv+0x38>
    thread->next = nullptr;
    80002930:	02053823          	sd	zero,48(a0)
    return thread;
}
    80002934:	00813403          	ld	s0,8(sp)
    80002938:	01010113          	addi	sp,sp,16
    8000293c:	00008067          	ret
    if (!head) tail = nullptr;     // skinuli smo i poslednjeg
    80002940:	00003797          	auipc	a5,0x3
    80002944:	4607bc23          	sd	zero,1144(a5) # 80005db8 <_ZN9Scheduler4tailE>
    80002948:	fe9ff06f          	j	80002930 <_ZN9Scheduler3getEv+0x28>

000000008000294c <_ZN15MemoryAllocator4initEv>:
#include "../h/print.hpp"

MemoryAllocator::FreeBlock* MemoryAllocator::freeListHead = nullptr;

// ceo heap = jedan slobodan blok
void MemoryAllocator::init() {
    8000294c:	ff010113          	addi	sp,sp,-16
    80002950:	00813423          	sd	s0,8(sp)
    80002954:	01010413          	addi	s0,sp,16
    freeListHead = (FreeBlock*)HEAP_START_ADDR;
    80002958:	00003797          	auipc	a5,0x3
    8000295c:	3f078793          	addi	a5,a5,1008 # 80005d48 <HEAP_START_ADDR>
    80002960:	0007b683          	ld	a3,0(a5)
    80002964:	00003717          	auipc	a4,0x3
    80002968:	46470713          	addi	a4,a4,1124 # 80005dc8 <_ZN15MemoryAllocator12freeListHeadE>
    8000296c:	00d73023          	sd	a3,0(a4)
    freeListHead->next = nullptr;
    80002970:	0006b023          	sd	zero,0(a3)
    freeListHead->size = (char*)HEAP_END_ADDR - (char*)HEAP_START_ADDR;
    80002974:	0007b683          	ld	a3,0(a5)
    80002978:	00073703          	ld	a4,0(a4)
    8000297c:	00003797          	auipc	a5,0x3
    80002980:	3c47b783          	ld	a5,964(a5) # 80005d40 <HEAP_END_ADDR>
    80002984:	40d787b3          	sub	a5,a5,a3
    80002988:	00f73423          	sd	a5,8(a4)
}
    8000298c:	00813403          	ld	s0,8(sp)
    80002990:	01010113          	addi	sp,sp,16
    80002994:	00008067          	ret

0000000080002998 <_ZN15MemoryAllocator5allocEm>:

void* MemoryAllocator::alloc(size_t size){
    80002998:	ff010113          	addi	sp,sp,-16
    8000299c:	00813423          	sd	s0,8(sp)
    800029a0:	01010413          	addi	s0,sp,16
    if (size == 0) {
    800029a4:	08050a63          	beqz	a0,80002a38 <_ZN15MemoryAllocator5allocEm+0xa0>
        return nullptr;
    }
    // zaokruzivanje navise: ((n + B - 1) / B) * B; heder ukljucen u racun
    // da payload uvek bude >= size
    size_t n = size + sizeof(FreeBlock);
    size_t roundedSize = ((n + MEM_BLOCK_SIZE - 1) / MEM_BLOCK_SIZE) * MEM_BLOCK_SIZE;
    800029a8:	04f50513          	addi	a0,a0,79
    800029ac:	fc057713          	andi	a4,a0,-64

    // first-fit kroz slobodnu listu
    FreeBlock* curr = freeListHead;
    800029b0:	00003517          	auipc	a0,0x3
    800029b4:	41853503          	ld	a0,1048(a0) # 80005dc8 <_ZN15MemoryAllocator12freeListHeadE>
    FreeBlock* prev = nullptr;
    800029b8:	00000693          	li	a3,0
    while(curr != nullptr){
    800029bc:	04050263          	beqz	a0,80002a00 <_ZN15MemoryAllocator5allocEm+0x68>
        if(curr->size >= roundedSize){
    800029c0:	00853783          	ld	a5,8(a0)
    800029c4:	00e7f863          	bgeu	a5,a4,800029d4 <_ZN15MemoryAllocator5allocEm+0x3c>
                    freeListHead = curr->next;
                }
            }
            return (char*)curr + sizeof(FreeBlock);
        }
        prev = curr;
    800029c8:	00050693          	mv	a3,a0
        curr = curr->next;
    800029cc:	00053503          	ld	a0,0(a0)
    while(curr != nullptr){
    800029d0:	fedff06f          	j	800029bc <_ZN15MemoryAllocator5allocEm+0x24>
            size_t remainder = curr->size - roundedSize;
    800029d4:	40e787b3          	sub	a5,a5,a4
            if (remainder >= MEM_BLOCK_SIZE) {
    800029d8:	03f00613          	li	a2,63
    800029dc:	02f67e63          	bgeu	a2,a5,80002a18 <_ZN15MemoryAllocator5allocEm+0x80>
                FreeBlock* newBlock = (FreeBlock*)((char*)curr + roundedSize);
    800029e0:	00e50633          	add	a2,a0,a4
                newBlock->size = remainder;
    800029e4:	00f63423          	sd	a5,8(a2)
                newBlock->next = curr->next;
    800029e8:	00053783          	ld	a5,0(a0)
    800029ec:	00f63023          	sd	a5,0(a2)
                if (prev != nullptr) {
    800029f0:	00068e63          	beqz	a3,80002a0c <_ZN15MemoryAllocator5allocEm+0x74>
                    prev->next = newBlock;
    800029f4:	00c6b023          	sd	a2,0(a3)
                curr->size = roundedSize;
    800029f8:	00e53423          	sd	a4,8(a0)
            return (char*)curr + sizeof(FreeBlock);
    800029fc:	01050513          	addi	a0,a0,16
    }
    return nullptr;   // nema dovoljno velikog bloka
}
    80002a00:	00813403          	ld	s0,8(sp)
    80002a04:	01010113          	addi	sp,sp,16
    80002a08:	00008067          	ret
                    freeListHead = newBlock;
    80002a0c:	00003797          	auipc	a5,0x3
    80002a10:	3ac7be23          	sd	a2,956(a5) # 80005dc8 <_ZN15MemoryAllocator12freeListHeadE>
    80002a14:	fe5ff06f          	j	800029f8 <_ZN15MemoryAllocator5allocEm+0x60>
                if (prev != nullptr) {
    80002a18:	00068863          	beqz	a3,80002a28 <_ZN15MemoryAllocator5allocEm+0x90>
                    prev->next = curr->next;
    80002a1c:	00053783          	ld	a5,0(a0)
    80002a20:	00f6b023          	sd	a5,0(a3)
    80002a24:	fd9ff06f          	j	800029fc <_ZN15MemoryAllocator5allocEm+0x64>
                    freeListHead = curr->next;
    80002a28:	00053783          	ld	a5,0(a0)
    80002a2c:	00003717          	auipc	a4,0x3
    80002a30:	38f73e23          	sd	a5,924(a4) # 80005dc8 <_ZN15MemoryAllocator12freeListHeadE>
    80002a34:	fc9ff06f          	j	800029fc <_ZN15MemoryAllocator5allocEm+0x64>
        return nullptr;
    80002a38:	00000513          	li	a0,0
    80002a3c:	fc5ff06f          	j	80002a00 <_ZN15MemoryAllocator5allocEm+0x68>

0000000080002a40 <_ZN15MemoryAllocator13printFreeListEv>:

// debug ispis slobodne liste (nije deo resenja koje se predaje)
void MemoryAllocator::printFreeList() {
    80002a40:	fe010113          	addi	sp,sp,-32
    80002a44:	00113c23          	sd	ra,24(sp)
    80002a48:	00813823          	sd	s0,16(sp)
    80002a4c:	00913423          	sd	s1,8(sp)
    80002a50:	02010413          	addi	s0,sp,32
    FreeBlock* curr = freeListHead;
    80002a54:	00003497          	auipc	s1,0x3
    80002a58:	3744b483          	ld	s1,884(s1) # 80005dc8 <_ZN15MemoryAllocator12freeListHeadE>
    kputs("free list:\n");
    80002a5c:	00003517          	auipc	a0,0x3
    80002a60:	8d450513          	addi	a0,a0,-1836 # 80005330 <CONSOLE_STATUS+0x320>
    80002a64:	fffff097          	auipc	ra,0xfffff
    80002a68:	724080e7          	jalr	1828(ra) # 80002188 <_Z5kputsPKc>
    while (curr != nullptr) {
    80002a6c:	04048a63          	beqz	s1,80002ac0 <_ZN15MemoryAllocator13printFreeListEv+0x80>
        kputs("  blok na ");
    80002a70:	00003517          	auipc	a0,0x3
    80002a74:	8d050513          	addi	a0,a0,-1840 # 80005340 <CONSOLE_STATUS+0x330>
    80002a78:	fffff097          	auipc	ra,0xfffff
    80002a7c:	710080e7          	jalr	1808(ra) # 80002188 <_Z5kputsPKc>
        kputhex((uint64)curr);
    80002a80:	00048513          	mv	a0,s1
    80002a84:	fffff097          	auipc	ra,0xfffff
    80002a88:	748080e7          	jalr	1864(ra) # 800021cc <_Z7kputhexm>
        kputs(", size: ");
    80002a8c:	00003517          	auipc	a0,0x3
    80002a90:	8c450513          	addi	a0,a0,-1852 # 80005350 <CONSOLE_STATUS+0x340>
    80002a94:	fffff097          	auipc	ra,0xfffff
    80002a98:	6f4080e7          	jalr	1780(ra) # 80002188 <_Z5kputsPKc>
        kputhex(curr->size);
    80002a9c:	0084b503          	ld	a0,8(s1)
    80002aa0:	fffff097          	auipc	ra,0xfffff
    80002aa4:	72c080e7          	jalr	1836(ra) # 800021cc <_Z7kputhexm>
        kputs("\n");
    80002aa8:	00003517          	auipc	a0,0x3
    80002aac:	a2050513          	addi	a0,a0,-1504 # 800054c8 <CONSOLE_STATUS+0x4b8>
    80002ab0:	fffff097          	auipc	ra,0xfffff
    80002ab4:	6d8080e7          	jalr	1752(ra) # 80002188 <_Z5kputsPKc>
        curr = curr->next;
    80002ab8:	0004b483          	ld	s1,0(s1)
    while (curr != nullptr) {
    80002abc:	fb1ff06f          	j	80002a6c <_ZN15MemoryAllocator13printFreeListEv+0x2c>
    }
}
    80002ac0:	01813083          	ld	ra,24(sp)
    80002ac4:	01013403          	ld	s0,16(sp)
    80002ac8:	00813483          	ld	s1,8(sp)
    80002acc:	02010113          	addi	sp,sp,32
    80002ad0:	00008067          	ret

0000000080002ad4 <_ZN15MemoryAllocator4freeEPv>:

int MemoryAllocator::free(void* ptr){
    80002ad4:	ff010113          	addi	sp,sp,-16
    80002ad8:	00813423          	sd	s0,8(sp)
    80002adc:	01010413          	addi	s0,sp,16
    if (ptr == nullptr) return -1;
    80002ae0:	12050663          	beqz	a0,80002c0c <_ZN15MemoryAllocator4freeEPv+0x138>
    FreeBlock* curr = freeListHead;
    80002ae4:	00003797          	auipc	a5,0x3
    80002ae8:	2e47b783          	ld	a5,740(a5) # 80005dc8 <_ZN15MemoryAllocator12freeListHeadE>
    FreeBlock* prev = nullptr;
    // heder zivi tacno ispred payload-a
    FreeBlock* block = (FreeBlock*)((char*)ptr - sizeof(FreeBlock));
    80002aec:	ff050693          	addi	a3,a0,-16
    FreeBlock* prev = nullptr;
    80002af0:	00000713          	li	a4,0
    // nadji mesto po adresi (lista je sortirana da bi spajanje radilo)
    while(curr != nullptr && curr < block){
    80002af4:	00078a63          	beqz	a5,80002b08 <_ZN15MemoryAllocator4freeEPv+0x34>
    80002af8:	00d7f863          	bgeu	a5,a3,80002b08 <_ZN15MemoryAllocator4freeEPv+0x34>
        prev = curr;
    80002afc:	00078713          	mv	a4,a5
        curr = curr->next;
    80002b00:	0007b783          	ld	a5,0(a5)
    while(curr != nullptr && curr < block){
    80002b04:	ff1ff06f          	j	80002af4 <_ZN15MemoryAllocator4freeEPv+0x20>
    }

    // da li se blok fizicki naslanja na suseda ispred/iza?
    bool mergePrev = (prev != nullptr) && ((char*)prev + prev->size == (char*)block);
    80002b08:	04070263          	beqz	a4,80002b4c <_ZN15MemoryAllocator4freeEPv+0x78>
    80002b0c:	00873603          	ld	a2,8(a4)
    80002b10:	00c70633          	add	a2,a4,a2
    80002b14:	04d60063          	beq	a2,a3,80002b54 <_ZN15MemoryAllocator4freeEPv+0x80>
    80002b18:	00000613          	li	a2,0
    bool mergeNext = (curr != nullptr) && ((char*)block + block->size == (char*)curr);
    80002b1c:	04078063          	beqz	a5,80002b5c <_ZN15MemoryAllocator4freeEPv+0x88>
    80002b20:	ff853583          	ld	a1,-8(a0)
    80002b24:	00b685b3          	add	a1,a3,a1
    80002b28:	02f58e63          	beq	a1,a5,80002b64 <_ZN15MemoryAllocator4freeEPv+0x90>
    80002b2c:	00000593          	li	a1,0

    if (!mergePrev && !mergeNext) {
    80002b30:	04061663          	bnez	a2,80002b7c <_ZN15MemoryAllocator4freeEPv+0xa8>
    80002b34:	04059463          	bnez	a1,80002b7c <_ZN15MemoryAllocator4freeEPv+0xa8>
        // nema spajanja: samo umetni izmedju prev i curr
        block->next = curr;
    80002b38:	fef53823          	sd	a5,-16(a0)
        if (prev != nullptr) {
    80002b3c:	02070863          	beqz	a4,80002b6c <_ZN15MemoryAllocator4freeEPv+0x98>
            prev->next = block;
    80002b40:	00d73023          	sd	a3,0(a4)
    } else {
        // spoji sa oba suseda
        prev->size += block->size + curr->size;
        prev->next = curr->next;
    }
    return 0;
    80002b44:	00000513          	li	a0,0
    80002b48:	0b80006f          	j	80002c00 <_ZN15MemoryAllocator4freeEPv+0x12c>
    bool mergePrev = (prev != nullptr) && ((char*)prev + prev->size == (char*)block);
    80002b4c:	00000613          	li	a2,0
    80002b50:	fcdff06f          	j	80002b1c <_ZN15MemoryAllocator4freeEPv+0x48>
    80002b54:	00100613          	li	a2,1
    80002b58:	fc5ff06f          	j	80002b1c <_ZN15MemoryAllocator4freeEPv+0x48>
    bool mergeNext = (curr != nullptr) && ((char*)block + block->size == (char*)curr);
    80002b5c:	00000593          	li	a1,0
    80002b60:	fd1ff06f          	j	80002b30 <_ZN15MemoryAllocator4freeEPv+0x5c>
    80002b64:	00100593          	li	a1,1
    80002b68:	fc9ff06f          	j	80002b30 <_ZN15MemoryAllocator4freeEPv+0x5c>
            freeListHead = block;
    80002b6c:	00003797          	auipc	a5,0x3
    80002b70:	24d7be23          	sd	a3,604(a5) # 80005dc8 <_ZN15MemoryAllocator12freeListHeadE>
    return 0;
    80002b74:	00000513          	li	a0,0
    80002b78:	0880006f          	j	80002c00 <_ZN15MemoryAllocator4freeEPv+0x12c>
    } else if (mergePrev && !mergeNext) {
    80002b7c:	02060063          	beqz	a2,80002b9c <_ZN15MemoryAllocator4freeEPv+0xc8>
    80002b80:	00059e63          	bnez	a1,80002b9c <_ZN15MemoryAllocator4freeEPv+0xc8>
        prev->size += block->size;
    80002b84:	ff853683          	ld	a3,-8(a0)
    80002b88:	00873783          	ld	a5,8(a4)
    80002b8c:	00d787b3          	add	a5,a5,a3
    80002b90:	00f73423          	sd	a5,8(a4)
    return 0;
    80002b94:	00000513          	li	a0,0
        prev->size += block->size;
    80002b98:	0680006f          	j	80002c00 <_ZN15MemoryAllocator4freeEPv+0x12c>
    } else if (!mergePrev && mergeNext) {
    80002b9c:	04061063          	bnez	a2,80002bdc <_ZN15MemoryAllocator4freeEPv+0x108>
    80002ba0:	02058e63          	beqz	a1,80002bdc <_ZN15MemoryAllocator4freeEPv+0x108>
        block->size += curr->size;
    80002ba4:	0087b583          	ld	a1,8(a5)
    80002ba8:	ff853603          	ld	a2,-8(a0)
    80002bac:	00b60633          	add	a2,a2,a1
    80002bb0:	fec53c23          	sd	a2,-8(a0)
        block->next = curr->next;
    80002bb4:	0007b783          	ld	a5,0(a5)
    80002bb8:	fef53823          	sd	a5,-16(a0)
        if (prev != nullptr) {
    80002bbc:	00070863          	beqz	a4,80002bcc <_ZN15MemoryAllocator4freeEPv+0xf8>
            prev->next = block;
    80002bc0:	00d73023          	sd	a3,0(a4)
    return 0;
    80002bc4:	00000513          	li	a0,0
    80002bc8:	0380006f          	j	80002c00 <_ZN15MemoryAllocator4freeEPv+0x12c>
            freeListHead = block;
    80002bcc:	00003797          	auipc	a5,0x3
    80002bd0:	1ed7be23          	sd	a3,508(a5) # 80005dc8 <_ZN15MemoryAllocator12freeListHeadE>
    return 0;
    80002bd4:	00000513          	li	a0,0
    80002bd8:	0280006f          	j	80002c00 <_ZN15MemoryAllocator4freeEPv+0x12c>
        prev->size += block->size + curr->size;
    80002bdc:	ff853683          	ld	a3,-8(a0)
    80002be0:	0087b603          	ld	a2,8(a5)
    80002be4:	00c68633          	add	a2,a3,a2
    80002be8:	00873683          	ld	a3,8(a4)
    80002bec:	00c686b3          	add	a3,a3,a2
    80002bf0:	00d73423          	sd	a3,8(a4)
        prev->next = curr->next;
    80002bf4:	0007b783          	ld	a5,0(a5)
    80002bf8:	00f73023          	sd	a5,0(a4)
    return 0;
    80002bfc:	00000513          	li	a0,0
}
    80002c00:	00813403          	ld	s0,8(sp)
    80002c04:	01010113          	addi	sp,sp,16
    80002c08:	00008067          	ret
    if (ptr == nullptr) return -1;
    80002c0c:	fff00513          	li	a0,-1
    80002c10:	ff1ff06f          	j	80002c00 <_ZN15MemoryAllocator4freeEPv+0x12c>

0000000080002c14 <main>:

extern "C" void trapHandler();

void userMain();   // definisana u test fajlu

int main() {
    80002c14:	fe010113          	addi	sp,sp,-32
    80002c18:	00113c23          	sd	ra,24(sp)
    80002c1c:	00813823          	sd	s0,16(sp)
    80002c20:	00913423          	sd	s1,8(sp)
    80002c24:	02010413          	addi	s0,sp,32
    kputs(">> kernel: starting\n");
    80002c28:	00002517          	auipc	a0,0x2
    80002c2c:	73850513          	addi	a0,a0,1848 # 80005360 <CONSOLE_STATUS+0x350>
    80002c30:	fffff097          	auipc	ra,0xfffff
    80002c34:	558080e7          	jalr	1368(ra) # 80002188 <_Z5kputsPKc>

    // stvec = adresa prekidne rutine: jedina kapija za ecall/izuzetke/prekide
    uint64 addr = (uint64)&trapHandler;
    80002c38:	ffffe797          	auipc	a5,0xffffe
    80002c3c:	3e878793          	addi	a5,a5,1000 # 80001020 <trapHandler>
    asm volatile("csrw stvec, %0" : : "r" (addr));
    80002c40:	10579073          	csrw	stvec,a5
    // maskiraj prekide PO VRSTI, u sie registru: ssie (tajmer, bit 1) +
    // seie (konzola, bit 9). sie vazi u OBA rezima - i u korisnickom,
    // gde se sstatus.SIE ignorise. zahtevi se pamte u sip, ali ne stizu.
    // u zadatku 4 se ovi biti samo ukljuce nazad.
    uint64 sie;
    asm volatile("csrr %0, sie" : "=r"(sie));
    80002c44:	104027f3          	csrr	a5,sie
    sie &= ~((1UL << 1) | (1UL << 9));
    80002c48:	dfd7f793          	andi	a5,a5,-515
    asm volatile("csrw sie, %0" : : "r"(sie));
    80002c4c:	10479073          	csrw	sie,a5

    // dokaz da je maska stvarno upisana
    asm volatile("csrr %0, sie" : "=r"(sie));
    80002c50:	104024f3          	csrr	s1,sie
    kputs(">> sie posle maske = "); kputhex(sie); kputs("\n");
    80002c54:	00002517          	auipc	a0,0x2
    80002c58:	72450513          	addi	a0,a0,1828 # 80005378 <CONSOLE_STATUS+0x368>
    80002c5c:	fffff097          	auipc	ra,0xfffff
    80002c60:	52c080e7          	jalr	1324(ra) # 80002188 <_Z5kputsPKc>
    80002c64:	00048513          	mv	a0,s1
    80002c68:	fffff097          	auipc	ra,0xfffff
    80002c6c:	564080e7          	jalr	1380(ra) # 800021cc <_Z7kputhexm>
    80002c70:	00003517          	auipc	a0,0x3
    80002c74:	85850513          	addi	a0,a0,-1960 # 800054c8 <CONSOLE_STATUS+0x4b8>
    80002c78:	fffff097          	auipc	ra,0xfffff
    80002c7c:	510080e7          	jalr	1296(ra) # 80002188 <_Z5kputsPKc>

    MemoryAllocator::init();
    80002c80:	00000097          	auipc	ra,0x0
    80002c84:	ccc080e7          	jalr	-820(ra) # 8000294c <_ZN15MemoryAllocator4initEv>

    // main postaje "nulta" nit: dobija svoj tcb da ima gde da se zamrzne
    // kad prvi put ustupi procesor (kontekst mu se popuni pri prvom dispatch-u)
    TCB::running = TCB::createThread(nullptr, nullptr, nullptr, true);   // nulta nit je sistemska
    80002c88:	00100693          	li	a3,1
    80002c8c:	00000613          	li	a2,0
    80002c90:	00000593          	li	a1,0
    80002c94:	00000513          	li	a0,0
    80002c98:	00000097          	auipc	ra,0x0
    80002c9c:	a28080e7          	jalr	-1496(ra) # 800026c0 <_ZN3TCB12createThreadEPFvPvES0_S0_b>
    80002ca0:	00003797          	auipc	a5,0x3
    80002ca4:	10a7b823          	sd	a0,272(a5) # 80005db0 <_ZN3TCB7runningE>

    userMain();    // privremeno: obican poziv funkcije; kasnije postaje
    80002ca8:	fffff097          	auipc	ra,0xfffff
    80002cac:	7e8080e7          	jalr	2024(ra) # 80002490 <_Z8userMainv>
                   // telo prve niti koju pokrece jezgro

    kputs(">> kernel: userMain returned, halting\n");
    80002cb0:	00002517          	auipc	a0,0x2
    80002cb4:	6e050513          	addi	a0,a0,1760 # 80005390 <CONSOLE_STATUS+0x380>
    80002cb8:	fffff097          	auipc	ra,0xfffff
    80002cbc:	4d0080e7          	jalr	1232(ra) # 80002188 <_Z5kputsPKc>

    // upis 0x5555 na 0x100000 gasi emulator (regularan kraj procesa)
    *(volatile int*)0x100000 = 0x5555;
    80002cc0:	00100737          	lui	a4,0x100
    80002cc4:	000057b7          	lui	a5,0x5
    80002cc8:	5557879b          	addiw	a5,a5,1365
    80002ccc:	00f72023          	sw	a5,0(a4) # 100000 <_entry-0x7ff00000>

    return 0;
}
    80002cd0:	00000513          	li	a0,0
    80002cd4:	01813083          	ld	ra,24(sp)
    80002cd8:	01013403          	ld	s0,16(sp)
    80002cdc:	00813483          	ld	s1,8(sp)
    80002ce0:	02010113          	addi	sp,sp,32
    80002ce4:	00008067          	ret

0000000080002ce8 <start>:
    80002ce8:	ff010113          	addi	sp,sp,-16
    80002cec:	00813423          	sd	s0,8(sp)
    80002cf0:	01010413          	addi	s0,sp,16
    80002cf4:	300027f3          	csrr	a5,mstatus
    80002cf8:	ffffe737          	lui	a4,0xffffe
    80002cfc:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fff77af>
    80002d00:	00e7f7b3          	and	a5,a5,a4
    80002d04:	00001737          	lui	a4,0x1
    80002d08:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80002d0c:	00e7e7b3          	or	a5,a5,a4
    80002d10:	30079073          	csrw	mstatus,a5
    80002d14:	00000797          	auipc	a5,0x0
    80002d18:	16078793          	addi	a5,a5,352 # 80002e74 <system_main>
    80002d1c:	34179073          	csrw	mepc,a5
    80002d20:	00000793          	li	a5,0
    80002d24:	18079073          	csrw	satp,a5
    80002d28:	000107b7          	lui	a5,0x10
    80002d2c:	fff78793          	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80002d30:	30279073          	csrw	medeleg,a5
    80002d34:	30379073          	csrw	mideleg,a5
    80002d38:	104027f3          	csrr	a5,sie
    80002d3c:	2227e793          	ori	a5,a5,546
    80002d40:	10479073          	csrw	sie,a5
    80002d44:	fff00793          	li	a5,-1
    80002d48:	00a7d793          	srli	a5,a5,0xa
    80002d4c:	3b079073          	csrw	pmpaddr0,a5
    80002d50:	00f00793          	li	a5,15
    80002d54:	3a079073          	csrw	pmpcfg0,a5
    80002d58:	f14027f3          	csrr	a5,mhartid
    80002d5c:	0200c737          	lui	a4,0x200c
    80002d60:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80002d64:	0007869b          	sext.w	a3,a5
    80002d68:	00269713          	slli	a4,a3,0x2
    80002d6c:	000f4637          	lui	a2,0xf4
    80002d70:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80002d74:	00d70733          	add	a4,a4,a3
    80002d78:	0037979b          	slliw	a5,a5,0x3
    80002d7c:	020046b7          	lui	a3,0x2004
    80002d80:	00d787b3          	add	a5,a5,a3
    80002d84:	00c585b3          	add	a1,a1,a2
    80002d88:	00371693          	slli	a3,a4,0x3
    80002d8c:	00003717          	auipc	a4,0x3
    80002d90:	07470713          	addi	a4,a4,116 # 80005e00 <timer_scratch>
    80002d94:	00b7b023          	sd	a1,0(a5)
    80002d98:	00d70733          	add	a4,a4,a3
    80002d9c:	00f73c23          	sd	a5,24(a4)
    80002da0:	02c73023          	sd	a2,32(a4)
    80002da4:	34071073          	csrw	mscratch,a4
    80002da8:	00000797          	auipc	a5,0x0
    80002dac:	6e878793          	addi	a5,a5,1768 # 80003490 <timervec>
    80002db0:	30579073          	csrw	mtvec,a5
    80002db4:	300027f3          	csrr	a5,mstatus
    80002db8:	0087e793          	ori	a5,a5,8
    80002dbc:	30079073          	csrw	mstatus,a5
    80002dc0:	304027f3          	csrr	a5,mie
    80002dc4:	0807e793          	ori	a5,a5,128
    80002dc8:	30479073          	csrw	mie,a5
    80002dcc:	f14027f3          	csrr	a5,mhartid
    80002dd0:	0007879b          	sext.w	a5,a5
    80002dd4:	00078213          	mv	tp,a5
    80002dd8:	30200073          	mret
    80002ddc:	00813403          	ld	s0,8(sp)
    80002de0:	01010113          	addi	sp,sp,16
    80002de4:	00008067          	ret

0000000080002de8 <timerinit>:
    80002de8:	ff010113          	addi	sp,sp,-16
    80002dec:	00813423          	sd	s0,8(sp)
    80002df0:	01010413          	addi	s0,sp,16
    80002df4:	f14027f3          	csrr	a5,mhartid
    80002df8:	0200c737          	lui	a4,0x200c
    80002dfc:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80002e00:	0007869b          	sext.w	a3,a5
    80002e04:	00269713          	slli	a4,a3,0x2
    80002e08:	000f4637          	lui	a2,0xf4
    80002e0c:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80002e10:	00d70733          	add	a4,a4,a3
    80002e14:	0037979b          	slliw	a5,a5,0x3
    80002e18:	020046b7          	lui	a3,0x2004
    80002e1c:	00d787b3          	add	a5,a5,a3
    80002e20:	00c585b3          	add	a1,a1,a2
    80002e24:	00371693          	slli	a3,a4,0x3
    80002e28:	00003717          	auipc	a4,0x3
    80002e2c:	fd870713          	addi	a4,a4,-40 # 80005e00 <timer_scratch>
    80002e30:	00b7b023          	sd	a1,0(a5)
    80002e34:	00d70733          	add	a4,a4,a3
    80002e38:	00f73c23          	sd	a5,24(a4)
    80002e3c:	02c73023          	sd	a2,32(a4)
    80002e40:	34071073          	csrw	mscratch,a4
    80002e44:	00000797          	auipc	a5,0x0
    80002e48:	64c78793          	addi	a5,a5,1612 # 80003490 <timervec>
    80002e4c:	30579073          	csrw	mtvec,a5
    80002e50:	300027f3          	csrr	a5,mstatus
    80002e54:	0087e793          	ori	a5,a5,8
    80002e58:	30079073          	csrw	mstatus,a5
    80002e5c:	304027f3          	csrr	a5,mie
    80002e60:	0807e793          	ori	a5,a5,128
    80002e64:	30479073          	csrw	mie,a5
    80002e68:	00813403          	ld	s0,8(sp)
    80002e6c:	01010113          	addi	sp,sp,16
    80002e70:	00008067          	ret

0000000080002e74 <system_main>:
    80002e74:	fe010113          	addi	sp,sp,-32
    80002e78:	00813823          	sd	s0,16(sp)
    80002e7c:	00913423          	sd	s1,8(sp)
    80002e80:	00113c23          	sd	ra,24(sp)
    80002e84:	02010413          	addi	s0,sp,32
    80002e88:	00000097          	auipc	ra,0x0
    80002e8c:	0c4080e7          	jalr	196(ra) # 80002f4c <cpuid>
    80002e90:	00003497          	auipc	s1,0x3
    80002e94:	f4048493          	addi	s1,s1,-192 # 80005dd0 <started>
    80002e98:	02050263          	beqz	a0,80002ebc <system_main+0x48>
    80002e9c:	0004a783          	lw	a5,0(s1)
    80002ea0:	0007879b          	sext.w	a5,a5
    80002ea4:	fe078ce3          	beqz	a5,80002e9c <system_main+0x28>
    80002ea8:	0ff0000f          	fence
    80002eac:	00002517          	auipc	a0,0x2
    80002eb0:	53c50513          	addi	a0,a0,1340 # 800053e8 <CONSOLE_STATUS+0x3d8>
    80002eb4:	00001097          	auipc	ra,0x1
    80002eb8:	a78080e7          	jalr	-1416(ra) # 8000392c <panic>
    80002ebc:	00001097          	auipc	ra,0x1
    80002ec0:	9cc080e7          	jalr	-1588(ra) # 80003888 <consoleinit>
    80002ec4:	00001097          	auipc	ra,0x1
    80002ec8:	158080e7          	jalr	344(ra) # 8000401c <printfinit>
    80002ecc:	00002517          	auipc	a0,0x2
    80002ed0:	5fc50513          	addi	a0,a0,1532 # 800054c8 <CONSOLE_STATUS+0x4b8>
    80002ed4:	00001097          	auipc	ra,0x1
    80002ed8:	ab4080e7          	jalr	-1356(ra) # 80003988 <__printf>
    80002edc:	00002517          	auipc	a0,0x2
    80002ee0:	4dc50513          	addi	a0,a0,1244 # 800053b8 <CONSOLE_STATUS+0x3a8>
    80002ee4:	00001097          	auipc	ra,0x1
    80002ee8:	aa4080e7          	jalr	-1372(ra) # 80003988 <__printf>
    80002eec:	00002517          	auipc	a0,0x2
    80002ef0:	5dc50513          	addi	a0,a0,1500 # 800054c8 <CONSOLE_STATUS+0x4b8>
    80002ef4:	00001097          	auipc	ra,0x1
    80002ef8:	a94080e7          	jalr	-1388(ra) # 80003988 <__printf>
    80002efc:	00001097          	auipc	ra,0x1
    80002f00:	4ac080e7          	jalr	1196(ra) # 800043a8 <kinit>
    80002f04:	00000097          	auipc	ra,0x0
    80002f08:	148080e7          	jalr	328(ra) # 8000304c <trapinit>
    80002f0c:	00000097          	auipc	ra,0x0
    80002f10:	16c080e7          	jalr	364(ra) # 80003078 <trapinithart>
    80002f14:	00000097          	auipc	ra,0x0
    80002f18:	5bc080e7          	jalr	1468(ra) # 800034d0 <plicinit>
    80002f1c:	00000097          	auipc	ra,0x0
    80002f20:	5dc080e7          	jalr	1500(ra) # 800034f8 <plicinithart>
    80002f24:	00000097          	auipc	ra,0x0
    80002f28:	078080e7          	jalr	120(ra) # 80002f9c <userinit>
    80002f2c:	0ff0000f          	fence
    80002f30:	00100793          	li	a5,1
    80002f34:	00002517          	auipc	a0,0x2
    80002f38:	49c50513          	addi	a0,a0,1180 # 800053d0 <CONSOLE_STATUS+0x3c0>
    80002f3c:	00f4a023          	sw	a5,0(s1)
    80002f40:	00001097          	auipc	ra,0x1
    80002f44:	a48080e7          	jalr	-1464(ra) # 80003988 <__printf>
    80002f48:	0000006f          	j	80002f48 <system_main+0xd4>

0000000080002f4c <cpuid>:
    80002f4c:	ff010113          	addi	sp,sp,-16
    80002f50:	00813423          	sd	s0,8(sp)
    80002f54:	01010413          	addi	s0,sp,16
    80002f58:	00020513          	mv	a0,tp
    80002f5c:	00813403          	ld	s0,8(sp)
    80002f60:	0005051b          	sext.w	a0,a0
    80002f64:	01010113          	addi	sp,sp,16
    80002f68:	00008067          	ret

0000000080002f6c <mycpu>:
    80002f6c:	ff010113          	addi	sp,sp,-16
    80002f70:	00813423          	sd	s0,8(sp)
    80002f74:	01010413          	addi	s0,sp,16
    80002f78:	00020793          	mv	a5,tp
    80002f7c:	00813403          	ld	s0,8(sp)
    80002f80:	0007879b          	sext.w	a5,a5
    80002f84:	00779793          	slli	a5,a5,0x7
    80002f88:	00004517          	auipc	a0,0x4
    80002f8c:	ea850513          	addi	a0,a0,-344 # 80006e30 <cpus>
    80002f90:	00f50533          	add	a0,a0,a5
    80002f94:	01010113          	addi	sp,sp,16
    80002f98:	00008067          	ret

0000000080002f9c <userinit>:
    80002f9c:	ff010113          	addi	sp,sp,-16
    80002fa0:	00813423          	sd	s0,8(sp)
    80002fa4:	01010413          	addi	s0,sp,16
    80002fa8:	00813403          	ld	s0,8(sp)
    80002fac:	01010113          	addi	sp,sp,16
    80002fb0:	00000317          	auipc	t1,0x0
    80002fb4:	c6430067          	jr	-924(t1) # 80002c14 <main>

0000000080002fb8 <either_copyout>:
    80002fb8:	ff010113          	addi	sp,sp,-16
    80002fbc:	00813023          	sd	s0,0(sp)
    80002fc0:	00113423          	sd	ra,8(sp)
    80002fc4:	01010413          	addi	s0,sp,16
    80002fc8:	02051663          	bnez	a0,80002ff4 <either_copyout+0x3c>
    80002fcc:	00058513          	mv	a0,a1
    80002fd0:	00060593          	mv	a1,a2
    80002fd4:	0006861b          	sext.w	a2,a3
    80002fd8:	00002097          	auipc	ra,0x2
    80002fdc:	c5c080e7          	jalr	-932(ra) # 80004c34 <__memmove>
    80002fe0:	00813083          	ld	ra,8(sp)
    80002fe4:	00013403          	ld	s0,0(sp)
    80002fe8:	00000513          	li	a0,0
    80002fec:	01010113          	addi	sp,sp,16
    80002ff0:	00008067          	ret
    80002ff4:	00002517          	auipc	a0,0x2
    80002ff8:	41c50513          	addi	a0,a0,1052 # 80005410 <CONSOLE_STATUS+0x400>
    80002ffc:	00001097          	auipc	ra,0x1
    80003000:	930080e7          	jalr	-1744(ra) # 8000392c <panic>

0000000080003004 <either_copyin>:
    80003004:	ff010113          	addi	sp,sp,-16
    80003008:	00813023          	sd	s0,0(sp)
    8000300c:	00113423          	sd	ra,8(sp)
    80003010:	01010413          	addi	s0,sp,16
    80003014:	02059463          	bnez	a1,8000303c <either_copyin+0x38>
    80003018:	00060593          	mv	a1,a2
    8000301c:	0006861b          	sext.w	a2,a3
    80003020:	00002097          	auipc	ra,0x2
    80003024:	c14080e7          	jalr	-1004(ra) # 80004c34 <__memmove>
    80003028:	00813083          	ld	ra,8(sp)
    8000302c:	00013403          	ld	s0,0(sp)
    80003030:	00000513          	li	a0,0
    80003034:	01010113          	addi	sp,sp,16
    80003038:	00008067          	ret
    8000303c:	00002517          	auipc	a0,0x2
    80003040:	3fc50513          	addi	a0,a0,1020 # 80005438 <CONSOLE_STATUS+0x428>
    80003044:	00001097          	auipc	ra,0x1
    80003048:	8e8080e7          	jalr	-1816(ra) # 8000392c <panic>

000000008000304c <trapinit>:
    8000304c:	ff010113          	addi	sp,sp,-16
    80003050:	00813423          	sd	s0,8(sp)
    80003054:	01010413          	addi	s0,sp,16
    80003058:	00813403          	ld	s0,8(sp)
    8000305c:	00002597          	auipc	a1,0x2
    80003060:	40458593          	addi	a1,a1,1028 # 80005460 <CONSOLE_STATUS+0x450>
    80003064:	00004517          	auipc	a0,0x4
    80003068:	e4c50513          	addi	a0,a0,-436 # 80006eb0 <tickslock>
    8000306c:	01010113          	addi	sp,sp,16
    80003070:	00001317          	auipc	t1,0x1
    80003074:	5c830067          	jr	1480(t1) # 80004638 <initlock>

0000000080003078 <trapinithart>:
    80003078:	ff010113          	addi	sp,sp,-16
    8000307c:	00813423          	sd	s0,8(sp)
    80003080:	01010413          	addi	s0,sp,16
    80003084:	00000797          	auipc	a5,0x0
    80003088:	2fc78793          	addi	a5,a5,764 # 80003380 <kernelvec>
    8000308c:	10579073          	csrw	stvec,a5
    80003090:	00813403          	ld	s0,8(sp)
    80003094:	01010113          	addi	sp,sp,16
    80003098:	00008067          	ret

000000008000309c <usertrap>:
    8000309c:	ff010113          	addi	sp,sp,-16
    800030a0:	00813423          	sd	s0,8(sp)
    800030a4:	01010413          	addi	s0,sp,16
    800030a8:	00813403          	ld	s0,8(sp)
    800030ac:	01010113          	addi	sp,sp,16
    800030b0:	00008067          	ret

00000000800030b4 <usertrapret>:
    800030b4:	ff010113          	addi	sp,sp,-16
    800030b8:	00813423          	sd	s0,8(sp)
    800030bc:	01010413          	addi	s0,sp,16
    800030c0:	00813403          	ld	s0,8(sp)
    800030c4:	01010113          	addi	sp,sp,16
    800030c8:	00008067          	ret

00000000800030cc <kerneltrap>:
    800030cc:	fe010113          	addi	sp,sp,-32
    800030d0:	00813823          	sd	s0,16(sp)
    800030d4:	00113c23          	sd	ra,24(sp)
    800030d8:	00913423          	sd	s1,8(sp)
    800030dc:	02010413          	addi	s0,sp,32
    800030e0:	142025f3          	csrr	a1,scause
    800030e4:	100027f3          	csrr	a5,sstatus
    800030e8:	0027f793          	andi	a5,a5,2
    800030ec:	10079c63          	bnez	a5,80003204 <kerneltrap+0x138>
    800030f0:	142027f3          	csrr	a5,scause
    800030f4:	0207ce63          	bltz	a5,80003130 <kerneltrap+0x64>
    800030f8:	00002517          	auipc	a0,0x2
    800030fc:	3b050513          	addi	a0,a0,944 # 800054a8 <CONSOLE_STATUS+0x498>
    80003100:	00001097          	auipc	ra,0x1
    80003104:	888080e7          	jalr	-1912(ra) # 80003988 <__printf>
    80003108:	141025f3          	csrr	a1,sepc
    8000310c:	14302673          	csrr	a2,stval
    80003110:	00002517          	auipc	a0,0x2
    80003114:	3a850513          	addi	a0,a0,936 # 800054b8 <CONSOLE_STATUS+0x4a8>
    80003118:	00001097          	auipc	ra,0x1
    8000311c:	870080e7          	jalr	-1936(ra) # 80003988 <__printf>
    80003120:	00002517          	auipc	a0,0x2
    80003124:	3b050513          	addi	a0,a0,944 # 800054d0 <CONSOLE_STATUS+0x4c0>
    80003128:	00001097          	auipc	ra,0x1
    8000312c:	804080e7          	jalr	-2044(ra) # 8000392c <panic>
    80003130:	0ff7f713          	andi	a4,a5,255
    80003134:	00900693          	li	a3,9
    80003138:	04d70063          	beq	a4,a3,80003178 <kerneltrap+0xac>
    8000313c:	fff00713          	li	a4,-1
    80003140:	03f71713          	slli	a4,a4,0x3f
    80003144:	00170713          	addi	a4,a4,1
    80003148:	fae798e3          	bne	a5,a4,800030f8 <kerneltrap+0x2c>
    8000314c:	00000097          	auipc	ra,0x0
    80003150:	e00080e7          	jalr	-512(ra) # 80002f4c <cpuid>
    80003154:	06050663          	beqz	a0,800031c0 <kerneltrap+0xf4>
    80003158:	144027f3          	csrr	a5,sip
    8000315c:	ffd7f793          	andi	a5,a5,-3
    80003160:	14479073          	csrw	sip,a5
    80003164:	01813083          	ld	ra,24(sp)
    80003168:	01013403          	ld	s0,16(sp)
    8000316c:	00813483          	ld	s1,8(sp)
    80003170:	02010113          	addi	sp,sp,32
    80003174:	00008067          	ret
    80003178:	00000097          	auipc	ra,0x0
    8000317c:	3cc080e7          	jalr	972(ra) # 80003544 <plic_claim>
    80003180:	00a00793          	li	a5,10
    80003184:	00050493          	mv	s1,a0
    80003188:	06f50863          	beq	a0,a5,800031f8 <kerneltrap+0x12c>
    8000318c:	fc050ce3          	beqz	a0,80003164 <kerneltrap+0x98>
    80003190:	00050593          	mv	a1,a0
    80003194:	00002517          	auipc	a0,0x2
    80003198:	2f450513          	addi	a0,a0,756 # 80005488 <CONSOLE_STATUS+0x478>
    8000319c:	00000097          	auipc	ra,0x0
    800031a0:	7ec080e7          	jalr	2028(ra) # 80003988 <__printf>
    800031a4:	01013403          	ld	s0,16(sp)
    800031a8:	01813083          	ld	ra,24(sp)
    800031ac:	00048513          	mv	a0,s1
    800031b0:	00813483          	ld	s1,8(sp)
    800031b4:	02010113          	addi	sp,sp,32
    800031b8:	00000317          	auipc	t1,0x0
    800031bc:	3c430067          	jr	964(t1) # 8000357c <plic_complete>
    800031c0:	00004517          	auipc	a0,0x4
    800031c4:	cf050513          	addi	a0,a0,-784 # 80006eb0 <tickslock>
    800031c8:	00001097          	auipc	ra,0x1
    800031cc:	494080e7          	jalr	1172(ra) # 8000465c <acquire>
    800031d0:	00003717          	auipc	a4,0x3
    800031d4:	c0470713          	addi	a4,a4,-1020 # 80005dd4 <ticks>
    800031d8:	00072783          	lw	a5,0(a4)
    800031dc:	00004517          	auipc	a0,0x4
    800031e0:	cd450513          	addi	a0,a0,-812 # 80006eb0 <tickslock>
    800031e4:	0017879b          	addiw	a5,a5,1
    800031e8:	00f72023          	sw	a5,0(a4)
    800031ec:	00001097          	auipc	ra,0x1
    800031f0:	53c080e7          	jalr	1340(ra) # 80004728 <release>
    800031f4:	f65ff06f          	j	80003158 <kerneltrap+0x8c>
    800031f8:	00001097          	auipc	ra,0x1
    800031fc:	098080e7          	jalr	152(ra) # 80004290 <uartintr>
    80003200:	fa5ff06f          	j	800031a4 <kerneltrap+0xd8>
    80003204:	00002517          	auipc	a0,0x2
    80003208:	26450513          	addi	a0,a0,612 # 80005468 <CONSOLE_STATUS+0x458>
    8000320c:	00000097          	auipc	ra,0x0
    80003210:	720080e7          	jalr	1824(ra) # 8000392c <panic>

0000000080003214 <clockintr>:
    80003214:	fe010113          	addi	sp,sp,-32
    80003218:	00813823          	sd	s0,16(sp)
    8000321c:	00913423          	sd	s1,8(sp)
    80003220:	00113c23          	sd	ra,24(sp)
    80003224:	02010413          	addi	s0,sp,32
    80003228:	00004497          	auipc	s1,0x4
    8000322c:	c8848493          	addi	s1,s1,-888 # 80006eb0 <tickslock>
    80003230:	00048513          	mv	a0,s1
    80003234:	00001097          	auipc	ra,0x1
    80003238:	428080e7          	jalr	1064(ra) # 8000465c <acquire>
    8000323c:	00003717          	auipc	a4,0x3
    80003240:	b9870713          	addi	a4,a4,-1128 # 80005dd4 <ticks>
    80003244:	00072783          	lw	a5,0(a4)
    80003248:	01013403          	ld	s0,16(sp)
    8000324c:	01813083          	ld	ra,24(sp)
    80003250:	00048513          	mv	a0,s1
    80003254:	0017879b          	addiw	a5,a5,1
    80003258:	00813483          	ld	s1,8(sp)
    8000325c:	00f72023          	sw	a5,0(a4)
    80003260:	02010113          	addi	sp,sp,32
    80003264:	00001317          	auipc	t1,0x1
    80003268:	4c430067          	jr	1220(t1) # 80004728 <release>

000000008000326c <devintr>:
    8000326c:	142027f3          	csrr	a5,scause
    80003270:	00000513          	li	a0,0
    80003274:	0007c463          	bltz	a5,8000327c <devintr+0x10>
    80003278:	00008067          	ret
    8000327c:	fe010113          	addi	sp,sp,-32
    80003280:	00813823          	sd	s0,16(sp)
    80003284:	00113c23          	sd	ra,24(sp)
    80003288:	00913423          	sd	s1,8(sp)
    8000328c:	02010413          	addi	s0,sp,32
    80003290:	0ff7f713          	andi	a4,a5,255
    80003294:	00900693          	li	a3,9
    80003298:	04d70c63          	beq	a4,a3,800032f0 <devintr+0x84>
    8000329c:	fff00713          	li	a4,-1
    800032a0:	03f71713          	slli	a4,a4,0x3f
    800032a4:	00170713          	addi	a4,a4,1
    800032a8:	00e78c63          	beq	a5,a4,800032c0 <devintr+0x54>
    800032ac:	01813083          	ld	ra,24(sp)
    800032b0:	01013403          	ld	s0,16(sp)
    800032b4:	00813483          	ld	s1,8(sp)
    800032b8:	02010113          	addi	sp,sp,32
    800032bc:	00008067          	ret
    800032c0:	00000097          	auipc	ra,0x0
    800032c4:	c8c080e7          	jalr	-884(ra) # 80002f4c <cpuid>
    800032c8:	06050663          	beqz	a0,80003334 <devintr+0xc8>
    800032cc:	144027f3          	csrr	a5,sip
    800032d0:	ffd7f793          	andi	a5,a5,-3
    800032d4:	14479073          	csrw	sip,a5
    800032d8:	01813083          	ld	ra,24(sp)
    800032dc:	01013403          	ld	s0,16(sp)
    800032e0:	00813483          	ld	s1,8(sp)
    800032e4:	00200513          	li	a0,2
    800032e8:	02010113          	addi	sp,sp,32
    800032ec:	00008067          	ret
    800032f0:	00000097          	auipc	ra,0x0
    800032f4:	254080e7          	jalr	596(ra) # 80003544 <plic_claim>
    800032f8:	00a00793          	li	a5,10
    800032fc:	00050493          	mv	s1,a0
    80003300:	06f50663          	beq	a0,a5,8000336c <devintr+0x100>
    80003304:	00100513          	li	a0,1
    80003308:	fa0482e3          	beqz	s1,800032ac <devintr+0x40>
    8000330c:	00048593          	mv	a1,s1
    80003310:	00002517          	auipc	a0,0x2
    80003314:	17850513          	addi	a0,a0,376 # 80005488 <CONSOLE_STATUS+0x478>
    80003318:	00000097          	auipc	ra,0x0
    8000331c:	670080e7          	jalr	1648(ra) # 80003988 <__printf>
    80003320:	00048513          	mv	a0,s1
    80003324:	00000097          	auipc	ra,0x0
    80003328:	258080e7          	jalr	600(ra) # 8000357c <plic_complete>
    8000332c:	00100513          	li	a0,1
    80003330:	f7dff06f          	j	800032ac <devintr+0x40>
    80003334:	00004517          	auipc	a0,0x4
    80003338:	b7c50513          	addi	a0,a0,-1156 # 80006eb0 <tickslock>
    8000333c:	00001097          	auipc	ra,0x1
    80003340:	320080e7          	jalr	800(ra) # 8000465c <acquire>
    80003344:	00003717          	auipc	a4,0x3
    80003348:	a9070713          	addi	a4,a4,-1392 # 80005dd4 <ticks>
    8000334c:	00072783          	lw	a5,0(a4)
    80003350:	00004517          	auipc	a0,0x4
    80003354:	b6050513          	addi	a0,a0,-1184 # 80006eb0 <tickslock>
    80003358:	0017879b          	addiw	a5,a5,1
    8000335c:	00f72023          	sw	a5,0(a4)
    80003360:	00001097          	auipc	ra,0x1
    80003364:	3c8080e7          	jalr	968(ra) # 80004728 <release>
    80003368:	f65ff06f          	j	800032cc <devintr+0x60>
    8000336c:	00001097          	auipc	ra,0x1
    80003370:	f24080e7          	jalr	-220(ra) # 80004290 <uartintr>
    80003374:	fadff06f          	j	80003320 <devintr+0xb4>
	...

0000000080003380 <kernelvec>:
    80003380:	f0010113          	addi	sp,sp,-256
    80003384:	00113023          	sd	ra,0(sp)
    80003388:	00213423          	sd	sp,8(sp)
    8000338c:	00313823          	sd	gp,16(sp)
    80003390:	00413c23          	sd	tp,24(sp)
    80003394:	02513023          	sd	t0,32(sp)
    80003398:	02613423          	sd	t1,40(sp)
    8000339c:	02713823          	sd	t2,48(sp)
    800033a0:	02813c23          	sd	s0,56(sp)
    800033a4:	04913023          	sd	s1,64(sp)
    800033a8:	04a13423          	sd	a0,72(sp)
    800033ac:	04b13823          	sd	a1,80(sp)
    800033b0:	04c13c23          	sd	a2,88(sp)
    800033b4:	06d13023          	sd	a3,96(sp)
    800033b8:	06e13423          	sd	a4,104(sp)
    800033bc:	06f13823          	sd	a5,112(sp)
    800033c0:	07013c23          	sd	a6,120(sp)
    800033c4:	09113023          	sd	a7,128(sp)
    800033c8:	09213423          	sd	s2,136(sp)
    800033cc:	09313823          	sd	s3,144(sp)
    800033d0:	09413c23          	sd	s4,152(sp)
    800033d4:	0b513023          	sd	s5,160(sp)
    800033d8:	0b613423          	sd	s6,168(sp)
    800033dc:	0b713823          	sd	s7,176(sp)
    800033e0:	0b813c23          	sd	s8,184(sp)
    800033e4:	0d913023          	sd	s9,192(sp)
    800033e8:	0da13423          	sd	s10,200(sp)
    800033ec:	0db13823          	sd	s11,208(sp)
    800033f0:	0dc13c23          	sd	t3,216(sp)
    800033f4:	0fd13023          	sd	t4,224(sp)
    800033f8:	0fe13423          	sd	t5,232(sp)
    800033fc:	0ff13823          	sd	t6,240(sp)
    80003400:	ccdff0ef          	jal	ra,800030cc <kerneltrap>
    80003404:	00013083          	ld	ra,0(sp)
    80003408:	00813103          	ld	sp,8(sp)
    8000340c:	01013183          	ld	gp,16(sp)
    80003410:	02013283          	ld	t0,32(sp)
    80003414:	02813303          	ld	t1,40(sp)
    80003418:	03013383          	ld	t2,48(sp)
    8000341c:	03813403          	ld	s0,56(sp)
    80003420:	04013483          	ld	s1,64(sp)
    80003424:	04813503          	ld	a0,72(sp)
    80003428:	05013583          	ld	a1,80(sp)
    8000342c:	05813603          	ld	a2,88(sp)
    80003430:	06013683          	ld	a3,96(sp)
    80003434:	06813703          	ld	a4,104(sp)
    80003438:	07013783          	ld	a5,112(sp)
    8000343c:	07813803          	ld	a6,120(sp)
    80003440:	08013883          	ld	a7,128(sp)
    80003444:	08813903          	ld	s2,136(sp)
    80003448:	09013983          	ld	s3,144(sp)
    8000344c:	09813a03          	ld	s4,152(sp)
    80003450:	0a013a83          	ld	s5,160(sp)
    80003454:	0a813b03          	ld	s6,168(sp)
    80003458:	0b013b83          	ld	s7,176(sp)
    8000345c:	0b813c03          	ld	s8,184(sp)
    80003460:	0c013c83          	ld	s9,192(sp)
    80003464:	0c813d03          	ld	s10,200(sp)
    80003468:	0d013d83          	ld	s11,208(sp)
    8000346c:	0d813e03          	ld	t3,216(sp)
    80003470:	0e013e83          	ld	t4,224(sp)
    80003474:	0e813f03          	ld	t5,232(sp)
    80003478:	0f013f83          	ld	t6,240(sp)
    8000347c:	10010113          	addi	sp,sp,256
    80003480:	10200073          	sret
    80003484:	00000013          	nop
    80003488:	00000013          	nop
    8000348c:	00000013          	nop

0000000080003490 <timervec>:
    80003490:	34051573          	csrrw	a0,mscratch,a0
    80003494:	00b53023          	sd	a1,0(a0)
    80003498:	00c53423          	sd	a2,8(a0)
    8000349c:	00d53823          	sd	a3,16(a0)
    800034a0:	01853583          	ld	a1,24(a0)
    800034a4:	02053603          	ld	a2,32(a0)
    800034a8:	0005b683          	ld	a3,0(a1)
    800034ac:	00c686b3          	add	a3,a3,a2
    800034b0:	00d5b023          	sd	a3,0(a1)
    800034b4:	00200593          	li	a1,2
    800034b8:	14459073          	csrw	sip,a1
    800034bc:	01053683          	ld	a3,16(a0)
    800034c0:	00853603          	ld	a2,8(a0)
    800034c4:	00053583          	ld	a1,0(a0)
    800034c8:	34051573          	csrrw	a0,mscratch,a0
    800034cc:	30200073          	mret

00000000800034d0 <plicinit>:
    800034d0:	ff010113          	addi	sp,sp,-16
    800034d4:	00813423          	sd	s0,8(sp)
    800034d8:	01010413          	addi	s0,sp,16
    800034dc:	00813403          	ld	s0,8(sp)
    800034e0:	0c0007b7          	lui	a5,0xc000
    800034e4:	00100713          	li	a4,1
    800034e8:	02e7a423          	sw	a4,40(a5) # c000028 <_entry-0x73ffffd8>
    800034ec:	00e7a223          	sw	a4,4(a5)
    800034f0:	01010113          	addi	sp,sp,16
    800034f4:	00008067          	ret

00000000800034f8 <plicinithart>:
    800034f8:	ff010113          	addi	sp,sp,-16
    800034fc:	00813023          	sd	s0,0(sp)
    80003500:	00113423          	sd	ra,8(sp)
    80003504:	01010413          	addi	s0,sp,16
    80003508:	00000097          	auipc	ra,0x0
    8000350c:	a44080e7          	jalr	-1468(ra) # 80002f4c <cpuid>
    80003510:	0085171b          	slliw	a4,a0,0x8
    80003514:	0c0027b7          	lui	a5,0xc002
    80003518:	00e787b3          	add	a5,a5,a4
    8000351c:	40200713          	li	a4,1026
    80003520:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>
    80003524:	00813083          	ld	ra,8(sp)
    80003528:	00013403          	ld	s0,0(sp)
    8000352c:	00d5151b          	slliw	a0,a0,0xd
    80003530:	0c2017b7          	lui	a5,0xc201
    80003534:	00a78533          	add	a0,a5,a0
    80003538:	00052023          	sw	zero,0(a0)
    8000353c:	01010113          	addi	sp,sp,16
    80003540:	00008067          	ret

0000000080003544 <plic_claim>:
    80003544:	ff010113          	addi	sp,sp,-16
    80003548:	00813023          	sd	s0,0(sp)
    8000354c:	00113423          	sd	ra,8(sp)
    80003550:	01010413          	addi	s0,sp,16
    80003554:	00000097          	auipc	ra,0x0
    80003558:	9f8080e7          	jalr	-1544(ra) # 80002f4c <cpuid>
    8000355c:	00813083          	ld	ra,8(sp)
    80003560:	00013403          	ld	s0,0(sp)
    80003564:	00d5151b          	slliw	a0,a0,0xd
    80003568:	0c2017b7          	lui	a5,0xc201
    8000356c:	00a78533          	add	a0,a5,a0
    80003570:	00452503          	lw	a0,4(a0)
    80003574:	01010113          	addi	sp,sp,16
    80003578:	00008067          	ret

000000008000357c <plic_complete>:
    8000357c:	fe010113          	addi	sp,sp,-32
    80003580:	00813823          	sd	s0,16(sp)
    80003584:	00913423          	sd	s1,8(sp)
    80003588:	00113c23          	sd	ra,24(sp)
    8000358c:	02010413          	addi	s0,sp,32
    80003590:	00050493          	mv	s1,a0
    80003594:	00000097          	auipc	ra,0x0
    80003598:	9b8080e7          	jalr	-1608(ra) # 80002f4c <cpuid>
    8000359c:	01813083          	ld	ra,24(sp)
    800035a0:	01013403          	ld	s0,16(sp)
    800035a4:	00d5179b          	slliw	a5,a0,0xd
    800035a8:	0c201737          	lui	a4,0xc201
    800035ac:	00f707b3          	add	a5,a4,a5
    800035b0:	0097a223          	sw	s1,4(a5) # c201004 <_entry-0x73dfeffc>
    800035b4:	00813483          	ld	s1,8(sp)
    800035b8:	02010113          	addi	sp,sp,32
    800035bc:	00008067          	ret

00000000800035c0 <consolewrite>:
    800035c0:	fb010113          	addi	sp,sp,-80
    800035c4:	04813023          	sd	s0,64(sp)
    800035c8:	04113423          	sd	ra,72(sp)
    800035cc:	02913c23          	sd	s1,56(sp)
    800035d0:	03213823          	sd	s2,48(sp)
    800035d4:	03313423          	sd	s3,40(sp)
    800035d8:	03413023          	sd	s4,32(sp)
    800035dc:	01513c23          	sd	s5,24(sp)
    800035e0:	05010413          	addi	s0,sp,80
    800035e4:	06c05c63          	blez	a2,8000365c <consolewrite+0x9c>
    800035e8:	00060993          	mv	s3,a2
    800035ec:	00050a13          	mv	s4,a0
    800035f0:	00058493          	mv	s1,a1
    800035f4:	00000913          	li	s2,0
    800035f8:	fff00a93          	li	s5,-1
    800035fc:	01c0006f          	j	80003618 <consolewrite+0x58>
    80003600:	fbf44503          	lbu	a0,-65(s0)
    80003604:	0019091b          	addiw	s2,s2,1
    80003608:	00148493          	addi	s1,s1,1
    8000360c:	00001097          	auipc	ra,0x1
    80003610:	a9c080e7          	jalr	-1380(ra) # 800040a8 <uartputc>
    80003614:	03298063          	beq	s3,s2,80003634 <consolewrite+0x74>
    80003618:	00048613          	mv	a2,s1
    8000361c:	00100693          	li	a3,1
    80003620:	000a0593          	mv	a1,s4
    80003624:	fbf40513          	addi	a0,s0,-65
    80003628:	00000097          	auipc	ra,0x0
    8000362c:	9dc080e7          	jalr	-1572(ra) # 80003004 <either_copyin>
    80003630:	fd5518e3          	bne	a0,s5,80003600 <consolewrite+0x40>
    80003634:	04813083          	ld	ra,72(sp)
    80003638:	04013403          	ld	s0,64(sp)
    8000363c:	03813483          	ld	s1,56(sp)
    80003640:	02813983          	ld	s3,40(sp)
    80003644:	02013a03          	ld	s4,32(sp)
    80003648:	01813a83          	ld	s5,24(sp)
    8000364c:	00090513          	mv	a0,s2
    80003650:	03013903          	ld	s2,48(sp)
    80003654:	05010113          	addi	sp,sp,80
    80003658:	00008067          	ret
    8000365c:	00000913          	li	s2,0
    80003660:	fd5ff06f          	j	80003634 <consolewrite+0x74>

0000000080003664 <consoleread>:
    80003664:	f9010113          	addi	sp,sp,-112
    80003668:	06813023          	sd	s0,96(sp)
    8000366c:	04913c23          	sd	s1,88(sp)
    80003670:	05213823          	sd	s2,80(sp)
    80003674:	05313423          	sd	s3,72(sp)
    80003678:	05413023          	sd	s4,64(sp)
    8000367c:	03513c23          	sd	s5,56(sp)
    80003680:	03613823          	sd	s6,48(sp)
    80003684:	03713423          	sd	s7,40(sp)
    80003688:	03813023          	sd	s8,32(sp)
    8000368c:	06113423          	sd	ra,104(sp)
    80003690:	01913c23          	sd	s9,24(sp)
    80003694:	07010413          	addi	s0,sp,112
    80003698:	00060b93          	mv	s7,a2
    8000369c:	00050913          	mv	s2,a0
    800036a0:	00058c13          	mv	s8,a1
    800036a4:	00060b1b          	sext.w	s6,a2
    800036a8:	00004497          	auipc	s1,0x4
    800036ac:	82048493          	addi	s1,s1,-2016 # 80006ec8 <cons>
    800036b0:	00400993          	li	s3,4
    800036b4:	fff00a13          	li	s4,-1
    800036b8:	00a00a93          	li	s5,10
    800036bc:	05705e63          	blez	s7,80003718 <consoleread+0xb4>
    800036c0:	09c4a703          	lw	a4,156(s1)
    800036c4:	0984a783          	lw	a5,152(s1)
    800036c8:	0007071b          	sext.w	a4,a4
    800036cc:	08e78463          	beq	a5,a4,80003754 <consoleread+0xf0>
    800036d0:	07f7f713          	andi	a4,a5,127
    800036d4:	00e48733          	add	a4,s1,a4
    800036d8:	01874703          	lbu	a4,24(a4) # c201018 <_entry-0x73dfefe8>
    800036dc:	0017869b          	addiw	a3,a5,1
    800036e0:	08d4ac23          	sw	a3,152(s1)
    800036e4:	00070c9b          	sext.w	s9,a4
    800036e8:	0b370663          	beq	a4,s3,80003794 <consoleread+0x130>
    800036ec:	00100693          	li	a3,1
    800036f0:	f9f40613          	addi	a2,s0,-97
    800036f4:	000c0593          	mv	a1,s8
    800036f8:	00090513          	mv	a0,s2
    800036fc:	f8e40fa3          	sb	a4,-97(s0)
    80003700:	00000097          	auipc	ra,0x0
    80003704:	8b8080e7          	jalr	-1864(ra) # 80002fb8 <either_copyout>
    80003708:	01450863          	beq	a0,s4,80003718 <consoleread+0xb4>
    8000370c:	001c0c13          	addi	s8,s8,1
    80003710:	fffb8b9b          	addiw	s7,s7,-1
    80003714:	fb5c94e3          	bne	s9,s5,800036bc <consoleread+0x58>
    80003718:	000b851b          	sext.w	a0,s7
    8000371c:	06813083          	ld	ra,104(sp)
    80003720:	06013403          	ld	s0,96(sp)
    80003724:	05813483          	ld	s1,88(sp)
    80003728:	05013903          	ld	s2,80(sp)
    8000372c:	04813983          	ld	s3,72(sp)
    80003730:	04013a03          	ld	s4,64(sp)
    80003734:	03813a83          	ld	s5,56(sp)
    80003738:	02813b83          	ld	s7,40(sp)
    8000373c:	02013c03          	ld	s8,32(sp)
    80003740:	01813c83          	ld	s9,24(sp)
    80003744:	40ab053b          	subw	a0,s6,a0
    80003748:	03013b03          	ld	s6,48(sp)
    8000374c:	07010113          	addi	sp,sp,112
    80003750:	00008067          	ret
    80003754:	00001097          	auipc	ra,0x1
    80003758:	1d8080e7          	jalr	472(ra) # 8000492c <push_on>
    8000375c:	0984a703          	lw	a4,152(s1)
    80003760:	09c4a783          	lw	a5,156(s1)
    80003764:	0007879b          	sext.w	a5,a5
    80003768:	fef70ce3          	beq	a4,a5,80003760 <consoleread+0xfc>
    8000376c:	00001097          	auipc	ra,0x1
    80003770:	234080e7          	jalr	564(ra) # 800049a0 <pop_on>
    80003774:	0984a783          	lw	a5,152(s1)
    80003778:	07f7f713          	andi	a4,a5,127
    8000377c:	00e48733          	add	a4,s1,a4
    80003780:	01874703          	lbu	a4,24(a4)
    80003784:	0017869b          	addiw	a3,a5,1
    80003788:	08d4ac23          	sw	a3,152(s1)
    8000378c:	00070c9b          	sext.w	s9,a4
    80003790:	f5371ee3          	bne	a4,s3,800036ec <consoleread+0x88>
    80003794:	000b851b          	sext.w	a0,s7
    80003798:	f96bf2e3          	bgeu	s7,s6,8000371c <consoleread+0xb8>
    8000379c:	08f4ac23          	sw	a5,152(s1)
    800037a0:	f7dff06f          	j	8000371c <consoleread+0xb8>

00000000800037a4 <consputc>:
    800037a4:	10000793          	li	a5,256
    800037a8:	00f50663          	beq	a0,a5,800037b4 <consputc+0x10>
    800037ac:	00001317          	auipc	t1,0x1
    800037b0:	9f430067          	jr	-1548(t1) # 800041a0 <uartputc_sync>
    800037b4:	ff010113          	addi	sp,sp,-16
    800037b8:	00113423          	sd	ra,8(sp)
    800037bc:	00813023          	sd	s0,0(sp)
    800037c0:	01010413          	addi	s0,sp,16
    800037c4:	00800513          	li	a0,8
    800037c8:	00001097          	auipc	ra,0x1
    800037cc:	9d8080e7          	jalr	-1576(ra) # 800041a0 <uartputc_sync>
    800037d0:	02000513          	li	a0,32
    800037d4:	00001097          	auipc	ra,0x1
    800037d8:	9cc080e7          	jalr	-1588(ra) # 800041a0 <uartputc_sync>
    800037dc:	00013403          	ld	s0,0(sp)
    800037e0:	00813083          	ld	ra,8(sp)
    800037e4:	00800513          	li	a0,8
    800037e8:	01010113          	addi	sp,sp,16
    800037ec:	00001317          	auipc	t1,0x1
    800037f0:	9b430067          	jr	-1612(t1) # 800041a0 <uartputc_sync>

00000000800037f4 <consoleintr>:
    800037f4:	fe010113          	addi	sp,sp,-32
    800037f8:	00813823          	sd	s0,16(sp)
    800037fc:	00913423          	sd	s1,8(sp)
    80003800:	01213023          	sd	s2,0(sp)
    80003804:	00113c23          	sd	ra,24(sp)
    80003808:	02010413          	addi	s0,sp,32
    8000380c:	00003917          	auipc	s2,0x3
    80003810:	6bc90913          	addi	s2,s2,1724 # 80006ec8 <cons>
    80003814:	00050493          	mv	s1,a0
    80003818:	00090513          	mv	a0,s2
    8000381c:	00001097          	auipc	ra,0x1
    80003820:	e40080e7          	jalr	-448(ra) # 8000465c <acquire>
    80003824:	02048c63          	beqz	s1,8000385c <consoleintr+0x68>
    80003828:	0a092783          	lw	a5,160(s2)
    8000382c:	09892703          	lw	a4,152(s2)
    80003830:	07f00693          	li	a3,127
    80003834:	40e7873b          	subw	a4,a5,a4
    80003838:	02e6e263          	bltu	a3,a4,8000385c <consoleintr+0x68>
    8000383c:	00d00713          	li	a4,13
    80003840:	04e48063          	beq	s1,a4,80003880 <consoleintr+0x8c>
    80003844:	07f7f713          	andi	a4,a5,127
    80003848:	00e90733          	add	a4,s2,a4
    8000384c:	0017879b          	addiw	a5,a5,1
    80003850:	0af92023          	sw	a5,160(s2)
    80003854:	00970c23          	sb	s1,24(a4)
    80003858:	08f92e23          	sw	a5,156(s2)
    8000385c:	01013403          	ld	s0,16(sp)
    80003860:	01813083          	ld	ra,24(sp)
    80003864:	00813483          	ld	s1,8(sp)
    80003868:	00013903          	ld	s2,0(sp)
    8000386c:	00003517          	auipc	a0,0x3
    80003870:	65c50513          	addi	a0,a0,1628 # 80006ec8 <cons>
    80003874:	02010113          	addi	sp,sp,32
    80003878:	00001317          	auipc	t1,0x1
    8000387c:	eb030067          	jr	-336(t1) # 80004728 <release>
    80003880:	00a00493          	li	s1,10
    80003884:	fc1ff06f          	j	80003844 <consoleintr+0x50>

0000000080003888 <consoleinit>:
    80003888:	fe010113          	addi	sp,sp,-32
    8000388c:	00113c23          	sd	ra,24(sp)
    80003890:	00813823          	sd	s0,16(sp)
    80003894:	00913423          	sd	s1,8(sp)
    80003898:	02010413          	addi	s0,sp,32
    8000389c:	00003497          	auipc	s1,0x3
    800038a0:	62c48493          	addi	s1,s1,1580 # 80006ec8 <cons>
    800038a4:	00048513          	mv	a0,s1
    800038a8:	00002597          	auipc	a1,0x2
    800038ac:	c3858593          	addi	a1,a1,-968 # 800054e0 <CONSOLE_STATUS+0x4d0>
    800038b0:	00001097          	auipc	ra,0x1
    800038b4:	d88080e7          	jalr	-632(ra) # 80004638 <initlock>
    800038b8:	00000097          	auipc	ra,0x0
    800038bc:	7ac080e7          	jalr	1964(ra) # 80004064 <uartinit>
    800038c0:	01813083          	ld	ra,24(sp)
    800038c4:	01013403          	ld	s0,16(sp)
    800038c8:	00000797          	auipc	a5,0x0
    800038cc:	d9c78793          	addi	a5,a5,-612 # 80003664 <consoleread>
    800038d0:	0af4bc23          	sd	a5,184(s1)
    800038d4:	00000797          	auipc	a5,0x0
    800038d8:	cec78793          	addi	a5,a5,-788 # 800035c0 <consolewrite>
    800038dc:	0cf4b023          	sd	a5,192(s1)
    800038e0:	00813483          	ld	s1,8(sp)
    800038e4:	02010113          	addi	sp,sp,32
    800038e8:	00008067          	ret

00000000800038ec <console_read>:
    800038ec:	ff010113          	addi	sp,sp,-16
    800038f0:	00813423          	sd	s0,8(sp)
    800038f4:	01010413          	addi	s0,sp,16
    800038f8:	00813403          	ld	s0,8(sp)
    800038fc:	00003317          	auipc	t1,0x3
    80003900:	68433303          	ld	t1,1668(t1) # 80006f80 <devsw+0x10>
    80003904:	01010113          	addi	sp,sp,16
    80003908:	00030067          	jr	t1

000000008000390c <console_write>:
    8000390c:	ff010113          	addi	sp,sp,-16
    80003910:	00813423          	sd	s0,8(sp)
    80003914:	01010413          	addi	s0,sp,16
    80003918:	00813403          	ld	s0,8(sp)
    8000391c:	00003317          	auipc	t1,0x3
    80003920:	66c33303          	ld	t1,1644(t1) # 80006f88 <devsw+0x18>
    80003924:	01010113          	addi	sp,sp,16
    80003928:	00030067          	jr	t1

000000008000392c <panic>:
    8000392c:	fe010113          	addi	sp,sp,-32
    80003930:	00113c23          	sd	ra,24(sp)
    80003934:	00813823          	sd	s0,16(sp)
    80003938:	00913423          	sd	s1,8(sp)
    8000393c:	02010413          	addi	s0,sp,32
    80003940:	00050493          	mv	s1,a0
    80003944:	00002517          	auipc	a0,0x2
    80003948:	ba450513          	addi	a0,a0,-1116 # 800054e8 <CONSOLE_STATUS+0x4d8>
    8000394c:	00003797          	auipc	a5,0x3
    80003950:	6c07ae23          	sw	zero,1756(a5) # 80007028 <pr+0x18>
    80003954:	00000097          	auipc	ra,0x0
    80003958:	034080e7          	jalr	52(ra) # 80003988 <__printf>
    8000395c:	00048513          	mv	a0,s1
    80003960:	00000097          	auipc	ra,0x0
    80003964:	028080e7          	jalr	40(ra) # 80003988 <__printf>
    80003968:	00002517          	auipc	a0,0x2
    8000396c:	b6050513          	addi	a0,a0,-1184 # 800054c8 <CONSOLE_STATUS+0x4b8>
    80003970:	00000097          	auipc	ra,0x0
    80003974:	018080e7          	jalr	24(ra) # 80003988 <__printf>
    80003978:	00100793          	li	a5,1
    8000397c:	00002717          	auipc	a4,0x2
    80003980:	44f72e23          	sw	a5,1116(a4) # 80005dd8 <panicked>
    80003984:	0000006f          	j	80003984 <panic+0x58>

0000000080003988 <__printf>:
    80003988:	f3010113          	addi	sp,sp,-208
    8000398c:	08813023          	sd	s0,128(sp)
    80003990:	07313423          	sd	s3,104(sp)
    80003994:	09010413          	addi	s0,sp,144
    80003998:	05813023          	sd	s8,64(sp)
    8000399c:	08113423          	sd	ra,136(sp)
    800039a0:	06913c23          	sd	s1,120(sp)
    800039a4:	07213823          	sd	s2,112(sp)
    800039a8:	07413023          	sd	s4,96(sp)
    800039ac:	05513c23          	sd	s5,88(sp)
    800039b0:	05613823          	sd	s6,80(sp)
    800039b4:	05713423          	sd	s7,72(sp)
    800039b8:	03913c23          	sd	s9,56(sp)
    800039bc:	03a13823          	sd	s10,48(sp)
    800039c0:	03b13423          	sd	s11,40(sp)
    800039c4:	00003317          	auipc	t1,0x3
    800039c8:	64c30313          	addi	t1,t1,1612 # 80007010 <pr>
    800039cc:	01832c03          	lw	s8,24(t1)
    800039d0:	00b43423          	sd	a1,8(s0)
    800039d4:	00c43823          	sd	a2,16(s0)
    800039d8:	00d43c23          	sd	a3,24(s0)
    800039dc:	02e43023          	sd	a4,32(s0)
    800039e0:	02f43423          	sd	a5,40(s0)
    800039e4:	03043823          	sd	a6,48(s0)
    800039e8:	03143c23          	sd	a7,56(s0)
    800039ec:	00050993          	mv	s3,a0
    800039f0:	4a0c1663          	bnez	s8,80003e9c <__printf+0x514>
    800039f4:	60098c63          	beqz	s3,8000400c <__printf+0x684>
    800039f8:	0009c503          	lbu	a0,0(s3)
    800039fc:	00840793          	addi	a5,s0,8
    80003a00:	f6f43c23          	sd	a5,-136(s0)
    80003a04:	00000493          	li	s1,0
    80003a08:	22050063          	beqz	a0,80003c28 <__printf+0x2a0>
    80003a0c:	00002a37          	lui	s4,0x2
    80003a10:	00018ab7          	lui	s5,0x18
    80003a14:	000f4b37          	lui	s6,0xf4
    80003a18:	00989bb7          	lui	s7,0x989
    80003a1c:	70fa0a13          	addi	s4,s4,1807 # 270f <_entry-0x7fffd8f1>
    80003a20:	69fa8a93          	addi	s5,s5,1695 # 1869f <_entry-0x7ffe7961>
    80003a24:	23fb0b13          	addi	s6,s6,575 # f423f <_entry-0x7ff0bdc1>
    80003a28:	67fb8b93          	addi	s7,s7,1663 # 98967f <_entry-0x7f676981>
    80003a2c:	00148c9b          	addiw	s9,s1,1
    80003a30:	02500793          	li	a5,37
    80003a34:	01998933          	add	s2,s3,s9
    80003a38:	38f51263          	bne	a0,a5,80003dbc <__printf+0x434>
    80003a3c:	00094783          	lbu	a5,0(s2)
    80003a40:	00078c9b          	sext.w	s9,a5
    80003a44:	1e078263          	beqz	a5,80003c28 <__printf+0x2a0>
    80003a48:	0024849b          	addiw	s1,s1,2
    80003a4c:	07000713          	li	a4,112
    80003a50:	00998933          	add	s2,s3,s1
    80003a54:	38e78a63          	beq	a5,a4,80003de8 <__printf+0x460>
    80003a58:	20f76863          	bltu	a4,a5,80003c68 <__printf+0x2e0>
    80003a5c:	42a78863          	beq	a5,a0,80003e8c <__printf+0x504>
    80003a60:	06400713          	li	a4,100
    80003a64:	40e79663          	bne	a5,a4,80003e70 <__printf+0x4e8>
    80003a68:	f7843783          	ld	a5,-136(s0)
    80003a6c:	0007a603          	lw	a2,0(a5)
    80003a70:	00878793          	addi	a5,a5,8
    80003a74:	f6f43c23          	sd	a5,-136(s0)
    80003a78:	42064a63          	bltz	a2,80003eac <__printf+0x524>
    80003a7c:	00a00713          	li	a4,10
    80003a80:	02e677bb          	remuw	a5,a2,a4
    80003a84:	00002d97          	auipc	s11,0x2
    80003a88:	a8cd8d93          	addi	s11,s11,-1396 # 80005510 <digits>
    80003a8c:	00900593          	li	a1,9
    80003a90:	0006051b          	sext.w	a0,a2
    80003a94:	00000c93          	li	s9,0
    80003a98:	02079793          	slli	a5,a5,0x20
    80003a9c:	0207d793          	srli	a5,a5,0x20
    80003aa0:	00fd87b3          	add	a5,s11,a5
    80003aa4:	0007c783          	lbu	a5,0(a5)
    80003aa8:	02e656bb          	divuw	a3,a2,a4
    80003aac:	f8f40023          	sb	a5,-128(s0)
    80003ab0:	14c5d863          	bge	a1,a2,80003c00 <__printf+0x278>
    80003ab4:	06300593          	li	a1,99
    80003ab8:	00100c93          	li	s9,1
    80003abc:	02e6f7bb          	remuw	a5,a3,a4
    80003ac0:	02079793          	slli	a5,a5,0x20
    80003ac4:	0207d793          	srli	a5,a5,0x20
    80003ac8:	00fd87b3          	add	a5,s11,a5
    80003acc:	0007c783          	lbu	a5,0(a5)
    80003ad0:	02e6d73b          	divuw	a4,a3,a4
    80003ad4:	f8f400a3          	sb	a5,-127(s0)
    80003ad8:	12a5f463          	bgeu	a1,a0,80003c00 <__printf+0x278>
    80003adc:	00a00693          	li	a3,10
    80003ae0:	00900593          	li	a1,9
    80003ae4:	02d777bb          	remuw	a5,a4,a3
    80003ae8:	02079793          	slli	a5,a5,0x20
    80003aec:	0207d793          	srli	a5,a5,0x20
    80003af0:	00fd87b3          	add	a5,s11,a5
    80003af4:	0007c503          	lbu	a0,0(a5)
    80003af8:	02d757bb          	divuw	a5,a4,a3
    80003afc:	f8a40123          	sb	a0,-126(s0)
    80003b00:	48e5f263          	bgeu	a1,a4,80003f84 <__printf+0x5fc>
    80003b04:	06300513          	li	a0,99
    80003b08:	02d7f5bb          	remuw	a1,a5,a3
    80003b0c:	02059593          	slli	a1,a1,0x20
    80003b10:	0205d593          	srli	a1,a1,0x20
    80003b14:	00bd85b3          	add	a1,s11,a1
    80003b18:	0005c583          	lbu	a1,0(a1)
    80003b1c:	02d7d7bb          	divuw	a5,a5,a3
    80003b20:	f8b401a3          	sb	a1,-125(s0)
    80003b24:	48e57263          	bgeu	a0,a4,80003fa8 <__printf+0x620>
    80003b28:	3e700513          	li	a0,999
    80003b2c:	02d7f5bb          	remuw	a1,a5,a3
    80003b30:	02059593          	slli	a1,a1,0x20
    80003b34:	0205d593          	srli	a1,a1,0x20
    80003b38:	00bd85b3          	add	a1,s11,a1
    80003b3c:	0005c583          	lbu	a1,0(a1)
    80003b40:	02d7d7bb          	divuw	a5,a5,a3
    80003b44:	f8b40223          	sb	a1,-124(s0)
    80003b48:	46e57663          	bgeu	a0,a4,80003fb4 <__printf+0x62c>
    80003b4c:	02d7f5bb          	remuw	a1,a5,a3
    80003b50:	02059593          	slli	a1,a1,0x20
    80003b54:	0205d593          	srli	a1,a1,0x20
    80003b58:	00bd85b3          	add	a1,s11,a1
    80003b5c:	0005c583          	lbu	a1,0(a1)
    80003b60:	02d7d7bb          	divuw	a5,a5,a3
    80003b64:	f8b402a3          	sb	a1,-123(s0)
    80003b68:	46ea7863          	bgeu	s4,a4,80003fd8 <__printf+0x650>
    80003b6c:	02d7f5bb          	remuw	a1,a5,a3
    80003b70:	02059593          	slli	a1,a1,0x20
    80003b74:	0205d593          	srli	a1,a1,0x20
    80003b78:	00bd85b3          	add	a1,s11,a1
    80003b7c:	0005c583          	lbu	a1,0(a1)
    80003b80:	02d7d7bb          	divuw	a5,a5,a3
    80003b84:	f8b40323          	sb	a1,-122(s0)
    80003b88:	3eeaf863          	bgeu	s5,a4,80003f78 <__printf+0x5f0>
    80003b8c:	02d7f5bb          	remuw	a1,a5,a3
    80003b90:	02059593          	slli	a1,a1,0x20
    80003b94:	0205d593          	srli	a1,a1,0x20
    80003b98:	00bd85b3          	add	a1,s11,a1
    80003b9c:	0005c583          	lbu	a1,0(a1)
    80003ba0:	02d7d7bb          	divuw	a5,a5,a3
    80003ba4:	f8b403a3          	sb	a1,-121(s0)
    80003ba8:	42eb7e63          	bgeu	s6,a4,80003fe4 <__printf+0x65c>
    80003bac:	02d7f5bb          	remuw	a1,a5,a3
    80003bb0:	02059593          	slli	a1,a1,0x20
    80003bb4:	0205d593          	srli	a1,a1,0x20
    80003bb8:	00bd85b3          	add	a1,s11,a1
    80003bbc:	0005c583          	lbu	a1,0(a1)
    80003bc0:	02d7d7bb          	divuw	a5,a5,a3
    80003bc4:	f8b40423          	sb	a1,-120(s0)
    80003bc8:	42ebfc63          	bgeu	s7,a4,80004000 <__printf+0x678>
    80003bcc:	02079793          	slli	a5,a5,0x20
    80003bd0:	0207d793          	srli	a5,a5,0x20
    80003bd4:	00fd8db3          	add	s11,s11,a5
    80003bd8:	000dc703          	lbu	a4,0(s11)
    80003bdc:	00a00793          	li	a5,10
    80003be0:	00900c93          	li	s9,9
    80003be4:	f8e404a3          	sb	a4,-119(s0)
    80003be8:	00065c63          	bgez	a2,80003c00 <__printf+0x278>
    80003bec:	f9040713          	addi	a4,s0,-112
    80003bf0:	00f70733          	add	a4,a4,a5
    80003bf4:	02d00693          	li	a3,45
    80003bf8:	fed70823          	sb	a3,-16(a4)
    80003bfc:	00078c93          	mv	s9,a5
    80003c00:	f8040793          	addi	a5,s0,-128
    80003c04:	01978cb3          	add	s9,a5,s9
    80003c08:	f7f40d13          	addi	s10,s0,-129
    80003c0c:	000cc503          	lbu	a0,0(s9)
    80003c10:	fffc8c93          	addi	s9,s9,-1
    80003c14:	00000097          	auipc	ra,0x0
    80003c18:	b90080e7          	jalr	-1136(ra) # 800037a4 <consputc>
    80003c1c:	ffac98e3          	bne	s9,s10,80003c0c <__printf+0x284>
    80003c20:	00094503          	lbu	a0,0(s2)
    80003c24:	e00514e3          	bnez	a0,80003a2c <__printf+0xa4>
    80003c28:	1a0c1663          	bnez	s8,80003dd4 <__printf+0x44c>
    80003c2c:	08813083          	ld	ra,136(sp)
    80003c30:	08013403          	ld	s0,128(sp)
    80003c34:	07813483          	ld	s1,120(sp)
    80003c38:	07013903          	ld	s2,112(sp)
    80003c3c:	06813983          	ld	s3,104(sp)
    80003c40:	06013a03          	ld	s4,96(sp)
    80003c44:	05813a83          	ld	s5,88(sp)
    80003c48:	05013b03          	ld	s6,80(sp)
    80003c4c:	04813b83          	ld	s7,72(sp)
    80003c50:	04013c03          	ld	s8,64(sp)
    80003c54:	03813c83          	ld	s9,56(sp)
    80003c58:	03013d03          	ld	s10,48(sp)
    80003c5c:	02813d83          	ld	s11,40(sp)
    80003c60:	0d010113          	addi	sp,sp,208
    80003c64:	00008067          	ret
    80003c68:	07300713          	li	a4,115
    80003c6c:	1ce78a63          	beq	a5,a4,80003e40 <__printf+0x4b8>
    80003c70:	07800713          	li	a4,120
    80003c74:	1ee79e63          	bne	a5,a4,80003e70 <__printf+0x4e8>
    80003c78:	f7843783          	ld	a5,-136(s0)
    80003c7c:	0007a703          	lw	a4,0(a5)
    80003c80:	00878793          	addi	a5,a5,8
    80003c84:	f6f43c23          	sd	a5,-136(s0)
    80003c88:	28074263          	bltz	a4,80003f0c <__printf+0x584>
    80003c8c:	00002d97          	auipc	s11,0x2
    80003c90:	884d8d93          	addi	s11,s11,-1916 # 80005510 <digits>
    80003c94:	00f77793          	andi	a5,a4,15
    80003c98:	00fd87b3          	add	a5,s11,a5
    80003c9c:	0007c683          	lbu	a3,0(a5)
    80003ca0:	00f00613          	li	a2,15
    80003ca4:	0007079b          	sext.w	a5,a4
    80003ca8:	f8d40023          	sb	a3,-128(s0)
    80003cac:	0047559b          	srliw	a1,a4,0x4
    80003cb0:	0047569b          	srliw	a3,a4,0x4
    80003cb4:	00000c93          	li	s9,0
    80003cb8:	0ee65063          	bge	a2,a4,80003d98 <__printf+0x410>
    80003cbc:	00f6f693          	andi	a3,a3,15
    80003cc0:	00dd86b3          	add	a3,s11,a3
    80003cc4:	0006c683          	lbu	a3,0(a3) # 2004000 <_entry-0x7dffc000>
    80003cc8:	0087d79b          	srliw	a5,a5,0x8
    80003ccc:	00100c93          	li	s9,1
    80003cd0:	f8d400a3          	sb	a3,-127(s0)
    80003cd4:	0cb67263          	bgeu	a2,a1,80003d98 <__printf+0x410>
    80003cd8:	00f7f693          	andi	a3,a5,15
    80003cdc:	00dd86b3          	add	a3,s11,a3
    80003ce0:	0006c583          	lbu	a1,0(a3)
    80003ce4:	00f00613          	li	a2,15
    80003ce8:	0047d69b          	srliw	a3,a5,0x4
    80003cec:	f8b40123          	sb	a1,-126(s0)
    80003cf0:	0047d593          	srli	a1,a5,0x4
    80003cf4:	28f67e63          	bgeu	a2,a5,80003f90 <__printf+0x608>
    80003cf8:	00f6f693          	andi	a3,a3,15
    80003cfc:	00dd86b3          	add	a3,s11,a3
    80003d00:	0006c503          	lbu	a0,0(a3)
    80003d04:	0087d813          	srli	a6,a5,0x8
    80003d08:	0087d69b          	srliw	a3,a5,0x8
    80003d0c:	f8a401a3          	sb	a0,-125(s0)
    80003d10:	28b67663          	bgeu	a2,a1,80003f9c <__printf+0x614>
    80003d14:	00f6f693          	andi	a3,a3,15
    80003d18:	00dd86b3          	add	a3,s11,a3
    80003d1c:	0006c583          	lbu	a1,0(a3)
    80003d20:	00c7d513          	srli	a0,a5,0xc
    80003d24:	00c7d69b          	srliw	a3,a5,0xc
    80003d28:	f8b40223          	sb	a1,-124(s0)
    80003d2c:	29067a63          	bgeu	a2,a6,80003fc0 <__printf+0x638>
    80003d30:	00f6f693          	andi	a3,a3,15
    80003d34:	00dd86b3          	add	a3,s11,a3
    80003d38:	0006c583          	lbu	a1,0(a3)
    80003d3c:	0107d813          	srli	a6,a5,0x10
    80003d40:	0107d69b          	srliw	a3,a5,0x10
    80003d44:	f8b402a3          	sb	a1,-123(s0)
    80003d48:	28a67263          	bgeu	a2,a0,80003fcc <__printf+0x644>
    80003d4c:	00f6f693          	andi	a3,a3,15
    80003d50:	00dd86b3          	add	a3,s11,a3
    80003d54:	0006c683          	lbu	a3,0(a3)
    80003d58:	0147d79b          	srliw	a5,a5,0x14
    80003d5c:	f8d40323          	sb	a3,-122(s0)
    80003d60:	21067663          	bgeu	a2,a6,80003f6c <__printf+0x5e4>
    80003d64:	02079793          	slli	a5,a5,0x20
    80003d68:	0207d793          	srli	a5,a5,0x20
    80003d6c:	00fd8db3          	add	s11,s11,a5
    80003d70:	000dc683          	lbu	a3,0(s11)
    80003d74:	00800793          	li	a5,8
    80003d78:	00700c93          	li	s9,7
    80003d7c:	f8d403a3          	sb	a3,-121(s0)
    80003d80:	00075c63          	bgez	a4,80003d98 <__printf+0x410>
    80003d84:	f9040713          	addi	a4,s0,-112
    80003d88:	00f70733          	add	a4,a4,a5
    80003d8c:	02d00693          	li	a3,45
    80003d90:	fed70823          	sb	a3,-16(a4)
    80003d94:	00078c93          	mv	s9,a5
    80003d98:	f8040793          	addi	a5,s0,-128
    80003d9c:	01978cb3          	add	s9,a5,s9
    80003da0:	f7f40d13          	addi	s10,s0,-129
    80003da4:	000cc503          	lbu	a0,0(s9)
    80003da8:	fffc8c93          	addi	s9,s9,-1
    80003dac:	00000097          	auipc	ra,0x0
    80003db0:	9f8080e7          	jalr	-1544(ra) # 800037a4 <consputc>
    80003db4:	ff9d18e3          	bne	s10,s9,80003da4 <__printf+0x41c>
    80003db8:	0100006f          	j	80003dc8 <__printf+0x440>
    80003dbc:	00000097          	auipc	ra,0x0
    80003dc0:	9e8080e7          	jalr	-1560(ra) # 800037a4 <consputc>
    80003dc4:	000c8493          	mv	s1,s9
    80003dc8:	00094503          	lbu	a0,0(s2)
    80003dcc:	c60510e3          	bnez	a0,80003a2c <__printf+0xa4>
    80003dd0:	e40c0ee3          	beqz	s8,80003c2c <__printf+0x2a4>
    80003dd4:	00003517          	auipc	a0,0x3
    80003dd8:	23c50513          	addi	a0,a0,572 # 80007010 <pr>
    80003ddc:	00001097          	auipc	ra,0x1
    80003de0:	94c080e7          	jalr	-1716(ra) # 80004728 <release>
    80003de4:	e49ff06f          	j	80003c2c <__printf+0x2a4>
    80003de8:	f7843783          	ld	a5,-136(s0)
    80003dec:	03000513          	li	a0,48
    80003df0:	01000d13          	li	s10,16
    80003df4:	00878713          	addi	a4,a5,8
    80003df8:	0007bc83          	ld	s9,0(a5)
    80003dfc:	f6e43c23          	sd	a4,-136(s0)
    80003e00:	00000097          	auipc	ra,0x0
    80003e04:	9a4080e7          	jalr	-1628(ra) # 800037a4 <consputc>
    80003e08:	07800513          	li	a0,120
    80003e0c:	00000097          	auipc	ra,0x0
    80003e10:	998080e7          	jalr	-1640(ra) # 800037a4 <consputc>
    80003e14:	00001d97          	auipc	s11,0x1
    80003e18:	6fcd8d93          	addi	s11,s11,1788 # 80005510 <digits>
    80003e1c:	03ccd793          	srli	a5,s9,0x3c
    80003e20:	00fd87b3          	add	a5,s11,a5
    80003e24:	0007c503          	lbu	a0,0(a5)
    80003e28:	fffd0d1b          	addiw	s10,s10,-1
    80003e2c:	004c9c93          	slli	s9,s9,0x4
    80003e30:	00000097          	auipc	ra,0x0
    80003e34:	974080e7          	jalr	-1676(ra) # 800037a4 <consputc>
    80003e38:	fe0d12e3          	bnez	s10,80003e1c <__printf+0x494>
    80003e3c:	f8dff06f          	j	80003dc8 <__printf+0x440>
    80003e40:	f7843783          	ld	a5,-136(s0)
    80003e44:	0007bc83          	ld	s9,0(a5)
    80003e48:	00878793          	addi	a5,a5,8
    80003e4c:	f6f43c23          	sd	a5,-136(s0)
    80003e50:	000c9a63          	bnez	s9,80003e64 <__printf+0x4dc>
    80003e54:	1080006f          	j	80003f5c <__printf+0x5d4>
    80003e58:	001c8c93          	addi	s9,s9,1
    80003e5c:	00000097          	auipc	ra,0x0
    80003e60:	948080e7          	jalr	-1720(ra) # 800037a4 <consputc>
    80003e64:	000cc503          	lbu	a0,0(s9)
    80003e68:	fe0518e3          	bnez	a0,80003e58 <__printf+0x4d0>
    80003e6c:	f5dff06f          	j	80003dc8 <__printf+0x440>
    80003e70:	02500513          	li	a0,37
    80003e74:	00000097          	auipc	ra,0x0
    80003e78:	930080e7          	jalr	-1744(ra) # 800037a4 <consputc>
    80003e7c:	000c8513          	mv	a0,s9
    80003e80:	00000097          	auipc	ra,0x0
    80003e84:	924080e7          	jalr	-1756(ra) # 800037a4 <consputc>
    80003e88:	f41ff06f          	j	80003dc8 <__printf+0x440>
    80003e8c:	02500513          	li	a0,37
    80003e90:	00000097          	auipc	ra,0x0
    80003e94:	914080e7          	jalr	-1772(ra) # 800037a4 <consputc>
    80003e98:	f31ff06f          	j	80003dc8 <__printf+0x440>
    80003e9c:	00030513          	mv	a0,t1
    80003ea0:	00000097          	auipc	ra,0x0
    80003ea4:	7bc080e7          	jalr	1980(ra) # 8000465c <acquire>
    80003ea8:	b4dff06f          	j	800039f4 <__printf+0x6c>
    80003eac:	40c0053b          	negw	a0,a2
    80003eb0:	00a00713          	li	a4,10
    80003eb4:	02e576bb          	remuw	a3,a0,a4
    80003eb8:	00001d97          	auipc	s11,0x1
    80003ebc:	658d8d93          	addi	s11,s11,1624 # 80005510 <digits>
    80003ec0:	ff700593          	li	a1,-9
    80003ec4:	02069693          	slli	a3,a3,0x20
    80003ec8:	0206d693          	srli	a3,a3,0x20
    80003ecc:	00dd86b3          	add	a3,s11,a3
    80003ed0:	0006c683          	lbu	a3,0(a3)
    80003ed4:	02e557bb          	divuw	a5,a0,a4
    80003ed8:	f8d40023          	sb	a3,-128(s0)
    80003edc:	10b65e63          	bge	a2,a1,80003ff8 <__printf+0x670>
    80003ee0:	06300593          	li	a1,99
    80003ee4:	02e7f6bb          	remuw	a3,a5,a4
    80003ee8:	02069693          	slli	a3,a3,0x20
    80003eec:	0206d693          	srli	a3,a3,0x20
    80003ef0:	00dd86b3          	add	a3,s11,a3
    80003ef4:	0006c683          	lbu	a3,0(a3)
    80003ef8:	02e7d73b          	divuw	a4,a5,a4
    80003efc:	00200793          	li	a5,2
    80003f00:	f8d400a3          	sb	a3,-127(s0)
    80003f04:	bca5ece3          	bltu	a1,a0,80003adc <__printf+0x154>
    80003f08:	ce5ff06f          	j	80003bec <__printf+0x264>
    80003f0c:	40e007bb          	negw	a5,a4
    80003f10:	00001d97          	auipc	s11,0x1
    80003f14:	600d8d93          	addi	s11,s11,1536 # 80005510 <digits>
    80003f18:	00f7f693          	andi	a3,a5,15
    80003f1c:	00dd86b3          	add	a3,s11,a3
    80003f20:	0006c583          	lbu	a1,0(a3)
    80003f24:	ff100613          	li	a2,-15
    80003f28:	0047d69b          	srliw	a3,a5,0x4
    80003f2c:	f8b40023          	sb	a1,-128(s0)
    80003f30:	0047d59b          	srliw	a1,a5,0x4
    80003f34:	0ac75e63          	bge	a4,a2,80003ff0 <__printf+0x668>
    80003f38:	00f6f693          	andi	a3,a3,15
    80003f3c:	00dd86b3          	add	a3,s11,a3
    80003f40:	0006c603          	lbu	a2,0(a3)
    80003f44:	00f00693          	li	a3,15
    80003f48:	0087d79b          	srliw	a5,a5,0x8
    80003f4c:	f8c400a3          	sb	a2,-127(s0)
    80003f50:	d8b6e4e3          	bltu	a3,a1,80003cd8 <__printf+0x350>
    80003f54:	00200793          	li	a5,2
    80003f58:	e2dff06f          	j	80003d84 <__printf+0x3fc>
    80003f5c:	00001c97          	auipc	s9,0x1
    80003f60:	594c8c93          	addi	s9,s9,1428 # 800054f0 <CONSOLE_STATUS+0x4e0>
    80003f64:	02800513          	li	a0,40
    80003f68:	ef1ff06f          	j	80003e58 <__printf+0x4d0>
    80003f6c:	00700793          	li	a5,7
    80003f70:	00600c93          	li	s9,6
    80003f74:	e0dff06f          	j	80003d80 <__printf+0x3f8>
    80003f78:	00700793          	li	a5,7
    80003f7c:	00600c93          	li	s9,6
    80003f80:	c69ff06f          	j	80003be8 <__printf+0x260>
    80003f84:	00300793          	li	a5,3
    80003f88:	00200c93          	li	s9,2
    80003f8c:	c5dff06f          	j	80003be8 <__printf+0x260>
    80003f90:	00300793          	li	a5,3
    80003f94:	00200c93          	li	s9,2
    80003f98:	de9ff06f          	j	80003d80 <__printf+0x3f8>
    80003f9c:	00400793          	li	a5,4
    80003fa0:	00300c93          	li	s9,3
    80003fa4:	dddff06f          	j	80003d80 <__printf+0x3f8>
    80003fa8:	00400793          	li	a5,4
    80003fac:	00300c93          	li	s9,3
    80003fb0:	c39ff06f          	j	80003be8 <__printf+0x260>
    80003fb4:	00500793          	li	a5,5
    80003fb8:	00400c93          	li	s9,4
    80003fbc:	c2dff06f          	j	80003be8 <__printf+0x260>
    80003fc0:	00500793          	li	a5,5
    80003fc4:	00400c93          	li	s9,4
    80003fc8:	db9ff06f          	j	80003d80 <__printf+0x3f8>
    80003fcc:	00600793          	li	a5,6
    80003fd0:	00500c93          	li	s9,5
    80003fd4:	dadff06f          	j	80003d80 <__printf+0x3f8>
    80003fd8:	00600793          	li	a5,6
    80003fdc:	00500c93          	li	s9,5
    80003fe0:	c09ff06f          	j	80003be8 <__printf+0x260>
    80003fe4:	00800793          	li	a5,8
    80003fe8:	00700c93          	li	s9,7
    80003fec:	bfdff06f          	j	80003be8 <__printf+0x260>
    80003ff0:	00100793          	li	a5,1
    80003ff4:	d91ff06f          	j	80003d84 <__printf+0x3fc>
    80003ff8:	00100793          	li	a5,1
    80003ffc:	bf1ff06f          	j	80003bec <__printf+0x264>
    80004000:	00900793          	li	a5,9
    80004004:	00800c93          	li	s9,8
    80004008:	be1ff06f          	j	80003be8 <__printf+0x260>
    8000400c:	00001517          	auipc	a0,0x1
    80004010:	4ec50513          	addi	a0,a0,1260 # 800054f8 <CONSOLE_STATUS+0x4e8>
    80004014:	00000097          	auipc	ra,0x0
    80004018:	918080e7          	jalr	-1768(ra) # 8000392c <panic>

000000008000401c <printfinit>:
    8000401c:	fe010113          	addi	sp,sp,-32
    80004020:	00813823          	sd	s0,16(sp)
    80004024:	00913423          	sd	s1,8(sp)
    80004028:	00113c23          	sd	ra,24(sp)
    8000402c:	02010413          	addi	s0,sp,32
    80004030:	00003497          	auipc	s1,0x3
    80004034:	fe048493          	addi	s1,s1,-32 # 80007010 <pr>
    80004038:	00048513          	mv	a0,s1
    8000403c:	00001597          	auipc	a1,0x1
    80004040:	4cc58593          	addi	a1,a1,1228 # 80005508 <CONSOLE_STATUS+0x4f8>
    80004044:	00000097          	auipc	ra,0x0
    80004048:	5f4080e7          	jalr	1524(ra) # 80004638 <initlock>
    8000404c:	01813083          	ld	ra,24(sp)
    80004050:	01013403          	ld	s0,16(sp)
    80004054:	0004ac23          	sw	zero,24(s1)
    80004058:	00813483          	ld	s1,8(sp)
    8000405c:	02010113          	addi	sp,sp,32
    80004060:	00008067          	ret

0000000080004064 <uartinit>:
    80004064:	ff010113          	addi	sp,sp,-16
    80004068:	00813423          	sd	s0,8(sp)
    8000406c:	01010413          	addi	s0,sp,16
    80004070:	100007b7          	lui	a5,0x10000
    80004074:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>
    80004078:	f8000713          	li	a4,-128
    8000407c:	00e781a3          	sb	a4,3(a5)
    80004080:	00300713          	li	a4,3
    80004084:	00e78023          	sb	a4,0(a5)
    80004088:	000780a3          	sb	zero,1(a5)
    8000408c:	00e781a3          	sb	a4,3(a5)
    80004090:	00700693          	li	a3,7
    80004094:	00d78123          	sb	a3,2(a5)
    80004098:	00e780a3          	sb	a4,1(a5)
    8000409c:	00813403          	ld	s0,8(sp)
    800040a0:	01010113          	addi	sp,sp,16
    800040a4:	00008067          	ret

00000000800040a8 <uartputc>:
    800040a8:	00002797          	auipc	a5,0x2
    800040ac:	d307a783          	lw	a5,-720(a5) # 80005dd8 <panicked>
    800040b0:	00078463          	beqz	a5,800040b8 <uartputc+0x10>
    800040b4:	0000006f          	j	800040b4 <uartputc+0xc>
    800040b8:	fd010113          	addi	sp,sp,-48
    800040bc:	02813023          	sd	s0,32(sp)
    800040c0:	00913c23          	sd	s1,24(sp)
    800040c4:	01213823          	sd	s2,16(sp)
    800040c8:	01313423          	sd	s3,8(sp)
    800040cc:	02113423          	sd	ra,40(sp)
    800040d0:	03010413          	addi	s0,sp,48
    800040d4:	00002917          	auipc	s2,0x2
    800040d8:	d0c90913          	addi	s2,s2,-756 # 80005de0 <uart_tx_r>
    800040dc:	00093783          	ld	a5,0(s2)
    800040e0:	00002497          	auipc	s1,0x2
    800040e4:	d0848493          	addi	s1,s1,-760 # 80005de8 <uart_tx_w>
    800040e8:	0004b703          	ld	a4,0(s1)
    800040ec:	02078693          	addi	a3,a5,32
    800040f0:	00050993          	mv	s3,a0
    800040f4:	02e69c63          	bne	a3,a4,8000412c <uartputc+0x84>
    800040f8:	00001097          	auipc	ra,0x1
    800040fc:	834080e7          	jalr	-1996(ra) # 8000492c <push_on>
    80004100:	00093783          	ld	a5,0(s2)
    80004104:	0004b703          	ld	a4,0(s1)
    80004108:	02078793          	addi	a5,a5,32
    8000410c:	00e79463          	bne	a5,a4,80004114 <uartputc+0x6c>
    80004110:	0000006f          	j	80004110 <uartputc+0x68>
    80004114:	00001097          	auipc	ra,0x1
    80004118:	88c080e7          	jalr	-1908(ra) # 800049a0 <pop_on>
    8000411c:	00093783          	ld	a5,0(s2)
    80004120:	0004b703          	ld	a4,0(s1)
    80004124:	02078693          	addi	a3,a5,32
    80004128:	fce688e3          	beq	a3,a4,800040f8 <uartputc+0x50>
    8000412c:	01f77693          	andi	a3,a4,31
    80004130:	00003597          	auipc	a1,0x3
    80004134:	f0058593          	addi	a1,a1,-256 # 80007030 <uart_tx_buf>
    80004138:	00d586b3          	add	a3,a1,a3
    8000413c:	00170713          	addi	a4,a4,1
    80004140:	01368023          	sb	s3,0(a3)
    80004144:	00e4b023          	sd	a4,0(s1)
    80004148:	10000637          	lui	a2,0x10000
    8000414c:	02f71063          	bne	a4,a5,8000416c <uartputc+0xc4>
    80004150:	0340006f          	j	80004184 <uartputc+0xdc>
    80004154:	00074703          	lbu	a4,0(a4)
    80004158:	00f93023          	sd	a5,0(s2)
    8000415c:	00e60023          	sb	a4,0(a2) # 10000000 <_entry-0x70000000>
    80004160:	00093783          	ld	a5,0(s2)
    80004164:	0004b703          	ld	a4,0(s1)
    80004168:	00f70e63          	beq	a4,a5,80004184 <uartputc+0xdc>
    8000416c:	00564683          	lbu	a3,5(a2)
    80004170:	01f7f713          	andi	a4,a5,31
    80004174:	00e58733          	add	a4,a1,a4
    80004178:	0206f693          	andi	a3,a3,32
    8000417c:	00178793          	addi	a5,a5,1
    80004180:	fc069ae3          	bnez	a3,80004154 <uartputc+0xac>
    80004184:	02813083          	ld	ra,40(sp)
    80004188:	02013403          	ld	s0,32(sp)
    8000418c:	01813483          	ld	s1,24(sp)
    80004190:	01013903          	ld	s2,16(sp)
    80004194:	00813983          	ld	s3,8(sp)
    80004198:	03010113          	addi	sp,sp,48
    8000419c:	00008067          	ret

00000000800041a0 <uartputc_sync>:
    800041a0:	ff010113          	addi	sp,sp,-16
    800041a4:	00813423          	sd	s0,8(sp)
    800041a8:	01010413          	addi	s0,sp,16
    800041ac:	00002717          	auipc	a4,0x2
    800041b0:	c2c72703          	lw	a4,-980(a4) # 80005dd8 <panicked>
    800041b4:	02071663          	bnez	a4,800041e0 <uartputc_sync+0x40>
    800041b8:	00050793          	mv	a5,a0
    800041bc:	100006b7          	lui	a3,0x10000
    800041c0:	0056c703          	lbu	a4,5(a3) # 10000005 <_entry-0x6ffffffb>
    800041c4:	02077713          	andi	a4,a4,32
    800041c8:	fe070ce3          	beqz	a4,800041c0 <uartputc_sync+0x20>
    800041cc:	0ff7f793          	andi	a5,a5,255
    800041d0:	00f68023          	sb	a5,0(a3)
    800041d4:	00813403          	ld	s0,8(sp)
    800041d8:	01010113          	addi	sp,sp,16
    800041dc:	00008067          	ret
    800041e0:	0000006f          	j	800041e0 <uartputc_sync+0x40>

00000000800041e4 <uartstart>:
    800041e4:	ff010113          	addi	sp,sp,-16
    800041e8:	00813423          	sd	s0,8(sp)
    800041ec:	01010413          	addi	s0,sp,16
    800041f0:	00002617          	auipc	a2,0x2
    800041f4:	bf060613          	addi	a2,a2,-1040 # 80005de0 <uart_tx_r>
    800041f8:	00002517          	auipc	a0,0x2
    800041fc:	bf050513          	addi	a0,a0,-1040 # 80005de8 <uart_tx_w>
    80004200:	00063783          	ld	a5,0(a2)
    80004204:	00053703          	ld	a4,0(a0)
    80004208:	04f70263          	beq	a4,a5,8000424c <uartstart+0x68>
    8000420c:	100005b7          	lui	a1,0x10000
    80004210:	00003817          	auipc	a6,0x3
    80004214:	e2080813          	addi	a6,a6,-480 # 80007030 <uart_tx_buf>
    80004218:	01c0006f          	j	80004234 <uartstart+0x50>
    8000421c:	0006c703          	lbu	a4,0(a3)
    80004220:	00f63023          	sd	a5,0(a2)
    80004224:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    80004228:	00063783          	ld	a5,0(a2)
    8000422c:	00053703          	ld	a4,0(a0)
    80004230:	00f70e63          	beq	a4,a5,8000424c <uartstart+0x68>
    80004234:	01f7f713          	andi	a4,a5,31
    80004238:	00e806b3          	add	a3,a6,a4
    8000423c:	0055c703          	lbu	a4,5(a1)
    80004240:	00178793          	addi	a5,a5,1
    80004244:	02077713          	andi	a4,a4,32
    80004248:	fc071ae3          	bnez	a4,8000421c <uartstart+0x38>
    8000424c:	00813403          	ld	s0,8(sp)
    80004250:	01010113          	addi	sp,sp,16
    80004254:	00008067          	ret

0000000080004258 <uartgetc>:
    80004258:	ff010113          	addi	sp,sp,-16
    8000425c:	00813423          	sd	s0,8(sp)
    80004260:	01010413          	addi	s0,sp,16
    80004264:	10000737          	lui	a4,0x10000
    80004268:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000426c:	0017f793          	andi	a5,a5,1
    80004270:	00078c63          	beqz	a5,80004288 <uartgetc+0x30>
    80004274:	00074503          	lbu	a0,0(a4)
    80004278:	0ff57513          	andi	a0,a0,255
    8000427c:	00813403          	ld	s0,8(sp)
    80004280:	01010113          	addi	sp,sp,16
    80004284:	00008067          	ret
    80004288:	fff00513          	li	a0,-1
    8000428c:	ff1ff06f          	j	8000427c <uartgetc+0x24>

0000000080004290 <uartintr>:
    80004290:	100007b7          	lui	a5,0x10000
    80004294:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80004298:	0017f793          	andi	a5,a5,1
    8000429c:	0a078463          	beqz	a5,80004344 <uartintr+0xb4>
    800042a0:	fe010113          	addi	sp,sp,-32
    800042a4:	00813823          	sd	s0,16(sp)
    800042a8:	00913423          	sd	s1,8(sp)
    800042ac:	00113c23          	sd	ra,24(sp)
    800042b0:	02010413          	addi	s0,sp,32
    800042b4:	100004b7          	lui	s1,0x10000
    800042b8:	0004c503          	lbu	a0,0(s1) # 10000000 <_entry-0x70000000>
    800042bc:	0ff57513          	andi	a0,a0,255
    800042c0:	fffff097          	auipc	ra,0xfffff
    800042c4:	534080e7          	jalr	1332(ra) # 800037f4 <consoleintr>
    800042c8:	0054c783          	lbu	a5,5(s1)
    800042cc:	0017f793          	andi	a5,a5,1
    800042d0:	fe0794e3          	bnez	a5,800042b8 <uartintr+0x28>
    800042d4:	00002617          	auipc	a2,0x2
    800042d8:	b0c60613          	addi	a2,a2,-1268 # 80005de0 <uart_tx_r>
    800042dc:	00002517          	auipc	a0,0x2
    800042e0:	b0c50513          	addi	a0,a0,-1268 # 80005de8 <uart_tx_w>
    800042e4:	00063783          	ld	a5,0(a2)
    800042e8:	00053703          	ld	a4,0(a0)
    800042ec:	04f70263          	beq	a4,a5,80004330 <uartintr+0xa0>
    800042f0:	100005b7          	lui	a1,0x10000
    800042f4:	00003817          	auipc	a6,0x3
    800042f8:	d3c80813          	addi	a6,a6,-708 # 80007030 <uart_tx_buf>
    800042fc:	01c0006f          	j	80004318 <uartintr+0x88>
    80004300:	0006c703          	lbu	a4,0(a3)
    80004304:	00f63023          	sd	a5,0(a2)
    80004308:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    8000430c:	00063783          	ld	a5,0(a2)
    80004310:	00053703          	ld	a4,0(a0)
    80004314:	00f70e63          	beq	a4,a5,80004330 <uartintr+0xa0>
    80004318:	01f7f713          	andi	a4,a5,31
    8000431c:	00e806b3          	add	a3,a6,a4
    80004320:	0055c703          	lbu	a4,5(a1)
    80004324:	00178793          	addi	a5,a5,1
    80004328:	02077713          	andi	a4,a4,32
    8000432c:	fc071ae3          	bnez	a4,80004300 <uartintr+0x70>
    80004330:	01813083          	ld	ra,24(sp)
    80004334:	01013403          	ld	s0,16(sp)
    80004338:	00813483          	ld	s1,8(sp)
    8000433c:	02010113          	addi	sp,sp,32
    80004340:	00008067          	ret
    80004344:	00002617          	auipc	a2,0x2
    80004348:	a9c60613          	addi	a2,a2,-1380 # 80005de0 <uart_tx_r>
    8000434c:	00002517          	auipc	a0,0x2
    80004350:	a9c50513          	addi	a0,a0,-1380 # 80005de8 <uart_tx_w>
    80004354:	00063783          	ld	a5,0(a2)
    80004358:	00053703          	ld	a4,0(a0)
    8000435c:	04f70263          	beq	a4,a5,800043a0 <uartintr+0x110>
    80004360:	100005b7          	lui	a1,0x10000
    80004364:	00003817          	auipc	a6,0x3
    80004368:	ccc80813          	addi	a6,a6,-820 # 80007030 <uart_tx_buf>
    8000436c:	01c0006f          	j	80004388 <uartintr+0xf8>
    80004370:	0006c703          	lbu	a4,0(a3)
    80004374:	00f63023          	sd	a5,0(a2)
    80004378:	00e58023          	sb	a4,0(a1) # 10000000 <_entry-0x70000000>
    8000437c:	00063783          	ld	a5,0(a2)
    80004380:	00053703          	ld	a4,0(a0)
    80004384:	02f70063          	beq	a4,a5,800043a4 <uartintr+0x114>
    80004388:	01f7f713          	andi	a4,a5,31
    8000438c:	00e806b3          	add	a3,a6,a4
    80004390:	0055c703          	lbu	a4,5(a1)
    80004394:	00178793          	addi	a5,a5,1
    80004398:	02077713          	andi	a4,a4,32
    8000439c:	fc071ae3          	bnez	a4,80004370 <uartintr+0xe0>
    800043a0:	00008067          	ret
    800043a4:	00008067          	ret

00000000800043a8 <kinit>:
    800043a8:	fc010113          	addi	sp,sp,-64
    800043ac:	02913423          	sd	s1,40(sp)
    800043b0:	fffff7b7          	lui	a5,0xfffff
    800043b4:	00004497          	auipc	s1,0x4
    800043b8:	c9b48493          	addi	s1,s1,-869 # 8000804f <end+0xfff>
    800043bc:	02813823          	sd	s0,48(sp)
    800043c0:	01313c23          	sd	s3,24(sp)
    800043c4:	00f4f4b3          	and	s1,s1,a5
    800043c8:	02113c23          	sd	ra,56(sp)
    800043cc:	03213023          	sd	s2,32(sp)
    800043d0:	01413823          	sd	s4,16(sp)
    800043d4:	01513423          	sd	s5,8(sp)
    800043d8:	04010413          	addi	s0,sp,64
    800043dc:	000017b7          	lui	a5,0x1
    800043e0:	01100993          	li	s3,17
    800043e4:	00f487b3          	add	a5,s1,a5
    800043e8:	01b99993          	slli	s3,s3,0x1b
    800043ec:	06f9e063          	bltu	s3,a5,8000444c <kinit+0xa4>
    800043f0:	00003a97          	auipc	s5,0x3
    800043f4:	c60a8a93          	addi	s5,s5,-928 # 80007050 <end>
    800043f8:	0754ec63          	bltu	s1,s5,80004470 <kinit+0xc8>
    800043fc:	0734fa63          	bgeu	s1,s3,80004470 <kinit+0xc8>
    80004400:	00088a37          	lui	s4,0x88
    80004404:	fffa0a13          	addi	s4,s4,-1 # 87fff <_entry-0x7ff78001>
    80004408:	00002917          	auipc	s2,0x2
    8000440c:	9e890913          	addi	s2,s2,-1560 # 80005df0 <kmem>
    80004410:	00ca1a13          	slli	s4,s4,0xc
    80004414:	0140006f          	j	80004428 <kinit+0x80>
    80004418:	000017b7          	lui	a5,0x1
    8000441c:	00f484b3          	add	s1,s1,a5
    80004420:	0554e863          	bltu	s1,s5,80004470 <kinit+0xc8>
    80004424:	0534f663          	bgeu	s1,s3,80004470 <kinit+0xc8>
    80004428:	00001637          	lui	a2,0x1
    8000442c:	00100593          	li	a1,1
    80004430:	00048513          	mv	a0,s1
    80004434:	00000097          	auipc	ra,0x0
    80004438:	5e4080e7          	jalr	1508(ra) # 80004a18 <__memset>
    8000443c:	00093783          	ld	a5,0(s2)
    80004440:	00f4b023          	sd	a5,0(s1)
    80004444:	00993023          	sd	s1,0(s2)
    80004448:	fd4498e3          	bne	s1,s4,80004418 <kinit+0x70>
    8000444c:	03813083          	ld	ra,56(sp)
    80004450:	03013403          	ld	s0,48(sp)
    80004454:	02813483          	ld	s1,40(sp)
    80004458:	02013903          	ld	s2,32(sp)
    8000445c:	01813983          	ld	s3,24(sp)
    80004460:	01013a03          	ld	s4,16(sp)
    80004464:	00813a83          	ld	s5,8(sp)
    80004468:	04010113          	addi	sp,sp,64
    8000446c:	00008067          	ret
    80004470:	00001517          	auipc	a0,0x1
    80004474:	0b850513          	addi	a0,a0,184 # 80005528 <digits+0x18>
    80004478:	fffff097          	auipc	ra,0xfffff
    8000447c:	4b4080e7          	jalr	1204(ra) # 8000392c <panic>

0000000080004480 <freerange>:
    80004480:	fc010113          	addi	sp,sp,-64
    80004484:	000017b7          	lui	a5,0x1
    80004488:	02913423          	sd	s1,40(sp)
    8000448c:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80004490:	009504b3          	add	s1,a0,s1
    80004494:	fffff537          	lui	a0,0xfffff
    80004498:	02813823          	sd	s0,48(sp)
    8000449c:	02113c23          	sd	ra,56(sp)
    800044a0:	03213023          	sd	s2,32(sp)
    800044a4:	01313c23          	sd	s3,24(sp)
    800044a8:	01413823          	sd	s4,16(sp)
    800044ac:	01513423          	sd	s5,8(sp)
    800044b0:	01613023          	sd	s6,0(sp)
    800044b4:	04010413          	addi	s0,sp,64
    800044b8:	00a4f4b3          	and	s1,s1,a0
    800044bc:	00f487b3          	add	a5,s1,a5
    800044c0:	06f5e463          	bltu	a1,a5,80004528 <freerange+0xa8>
    800044c4:	00003a97          	auipc	s5,0x3
    800044c8:	b8ca8a93          	addi	s5,s5,-1140 # 80007050 <end>
    800044cc:	0954e263          	bltu	s1,s5,80004550 <freerange+0xd0>
    800044d0:	01100993          	li	s3,17
    800044d4:	01b99993          	slli	s3,s3,0x1b
    800044d8:	0734fc63          	bgeu	s1,s3,80004550 <freerange+0xd0>
    800044dc:	00058a13          	mv	s4,a1
    800044e0:	00002917          	auipc	s2,0x2
    800044e4:	91090913          	addi	s2,s2,-1776 # 80005df0 <kmem>
    800044e8:	00002b37          	lui	s6,0x2
    800044ec:	0140006f          	j	80004500 <freerange+0x80>
    800044f0:	000017b7          	lui	a5,0x1
    800044f4:	00f484b3          	add	s1,s1,a5
    800044f8:	0554ec63          	bltu	s1,s5,80004550 <freerange+0xd0>
    800044fc:	0534fa63          	bgeu	s1,s3,80004550 <freerange+0xd0>
    80004500:	00001637          	lui	a2,0x1
    80004504:	00100593          	li	a1,1
    80004508:	00048513          	mv	a0,s1
    8000450c:	00000097          	auipc	ra,0x0
    80004510:	50c080e7          	jalr	1292(ra) # 80004a18 <__memset>
    80004514:	00093703          	ld	a4,0(s2)
    80004518:	016487b3          	add	a5,s1,s6
    8000451c:	00e4b023          	sd	a4,0(s1)
    80004520:	00993023          	sd	s1,0(s2)
    80004524:	fcfa76e3          	bgeu	s4,a5,800044f0 <freerange+0x70>
    80004528:	03813083          	ld	ra,56(sp)
    8000452c:	03013403          	ld	s0,48(sp)
    80004530:	02813483          	ld	s1,40(sp)
    80004534:	02013903          	ld	s2,32(sp)
    80004538:	01813983          	ld	s3,24(sp)
    8000453c:	01013a03          	ld	s4,16(sp)
    80004540:	00813a83          	ld	s5,8(sp)
    80004544:	00013b03          	ld	s6,0(sp)
    80004548:	04010113          	addi	sp,sp,64
    8000454c:	00008067          	ret
    80004550:	00001517          	auipc	a0,0x1
    80004554:	fd850513          	addi	a0,a0,-40 # 80005528 <digits+0x18>
    80004558:	fffff097          	auipc	ra,0xfffff
    8000455c:	3d4080e7          	jalr	980(ra) # 8000392c <panic>

0000000080004560 <kfree>:
    80004560:	fe010113          	addi	sp,sp,-32
    80004564:	00813823          	sd	s0,16(sp)
    80004568:	00113c23          	sd	ra,24(sp)
    8000456c:	00913423          	sd	s1,8(sp)
    80004570:	02010413          	addi	s0,sp,32
    80004574:	03451793          	slli	a5,a0,0x34
    80004578:	04079c63          	bnez	a5,800045d0 <kfree+0x70>
    8000457c:	00003797          	auipc	a5,0x3
    80004580:	ad478793          	addi	a5,a5,-1324 # 80007050 <end>
    80004584:	00050493          	mv	s1,a0
    80004588:	04f56463          	bltu	a0,a5,800045d0 <kfree+0x70>
    8000458c:	01100793          	li	a5,17
    80004590:	01b79793          	slli	a5,a5,0x1b
    80004594:	02f57e63          	bgeu	a0,a5,800045d0 <kfree+0x70>
    80004598:	00001637          	lui	a2,0x1
    8000459c:	00100593          	li	a1,1
    800045a0:	00000097          	auipc	ra,0x0
    800045a4:	478080e7          	jalr	1144(ra) # 80004a18 <__memset>
    800045a8:	00002797          	auipc	a5,0x2
    800045ac:	84878793          	addi	a5,a5,-1976 # 80005df0 <kmem>
    800045b0:	0007b703          	ld	a4,0(a5)
    800045b4:	01813083          	ld	ra,24(sp)
    800045b8:	01013403          	ld	s0,16(sp)
    800045bc:	00e4b023          	sd	a4,0(s1)
    800045c0:	0097b023          	sd	s1,0(a5)
    800045c4:	00813483          	ld	s1,8(sp)
    800045c8:	02010113          	addi	sp,sp,32
    800045cc:	00008067          	ret
    800045d0:	00001517          	auipc	a0,0x1
    800045d4:	f5850513          	addi	a0,a0,-168 # 80005528 <digits+0x18>
    800045d8:	fffff097          	auipc	ra,0xfffff
    800045dc:	354080e7          	jalr	852(ra) # 8000392c <panic>

00000000800045e0 <kalloc>:
    800045e0:	fe010113          	addi	sp,sp,-32
    800045e4:	00813823          	sd	s0,16(sp)
    800045e8:	00913423          	sd	s1,8(sp)
    800045ec:	00113c23          	sd	ra,24(sp)
    800045f0:	02010413          	addi	s0,sp,32
    800045f4:	00001797          	auipc	a5,0x1
    800045f8:	7fc78793          	addi	a5,a5,2044 # 80005df0 <kmem>
    800045fc:	0007b483          	ld	s1,0(a5)
    80004600:	02048063          	beqz	s1,80004620 <kalloc+0x40>
    80004604:	0004b703          	ld	a4,0(s1)
    80004608:	00001637          	lui	a2,0x1
    8000460c:	00500593          	li	a1,5
    80004610:	00048513          	mv	a0,s1
    80004614:	00e7b023          	sd	a4,0(a5)
    80004618:	00000097          	auipc	ra,0x0
    8000461c:	400080e7          	jalr	1024(ra) # 80004a18 <__memset>
    80004620:	01813083          	ld	ra,24(sp)
    80004624:	01013403          	ld	s0,16(sp)
    80004628:	00048513          	mv	a0,s1
    8000462c:	00813483          	ld	s1,8(sp)
    80004630:	02010113          	addi	sp,sp,32
    80004634:	00008067          	ret

0000000080004638 <initlock>:
    80004638:	ff010113          	addi	sp,sp,-16
    8000463c:	00813423          	sd	s0,8(sp)
    80004640:	01010413          	addi	s0,sp,16
    80004644:	00813403          	ld	s0,8(sp)
    80004648:	00b53423          	sd	a1,8(a0)
    8000464c:	00052023          	sw	zero,0(a0)
    80004650:	00053823          	sd	zero,16(a0)
    80004654:	01010113          	addi	sp,sp,16
    80004658:	00008067          	ret

000000008000465c <acquire>:
    8000465c:	fe010113          	addi	sp,sp,-32
    80004660:	00813823          	sd	s0,16(sp)
    80004664:	00913423          	sd	s1,8(sp)
    80004668:	00113c23          	sd	ra,24(sp)
    8000466c:	01213023          	sd	s2,0(sp)
    80004670:	02010413          	addi	s0,sp,32
    80004674:	00050493          	mv	s1,a0
    80004678:	10002973          	csrr	s2,sstatus
    8000467c:	100027f3          	csrr	a5,sstatus
    80004680:	ffd7f793          	andi	a5,a5,-3
    80004684:	10079073          	csrw	sstatus,a5
    80004688:	fffff097          	auipc	ra,0xfffff
    8000468c:	8e4080e7          	jalr	-1820(ra) # 80002f6c <mycpu>
    80004690:	07852783          	lw	a5,120(a0)
    80004694:	06078e63          	beqz	a5,80004710 <acquire+0xb4>
    80004698:	fffff097          	auipc	ra,0xfffff
    8000469c:	8d4080e7          	jalr	-1836(ra) # 80002f6c <mycpu>
    800046a0:	07852783          	lw	a5,120(a0)
    800046a4:	0004a703          	lw	a4,0(s1)
    800046a8:	0017879b          	addiw	a5,a5,1
    800046ac:	06f52c23          	sw	a5,120(a0)
    800046b0:	04071063          	bnez	a4,800046f0 <acquire+0x94>
    800046b4:	00100713          	li	a4,1
    800046b8:	00070793          	mv	a5,a4
    800046bc:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    800046c0:	0007879b          	sext.w	a5,a5
    800046c4:	fe079ae3          	bnez	a5,800046b8 <acquire+0x5c>
    800046c8:	0ff0000f          	fence
    800046cc:	fffff097          	auipc	ra,0xfffff
    800046d0:	8a0080e7          	jalr	-1888(ra) # 80002f6c <mycpu>
    800046d4:	01813083          	ld	ra,24(sp)
    800046d8:	01013403          	ld	s0,16(sp)
    800046dc:	00a4b823          	sd	a0,16(s1)
    800046e0:	00013903          	ld	s2,0(sp)
    800046e4:	00813483          	ld	s1,8(sp)
    800046e8:	02010113          	addi	sp,sp,32
    800046ec:	00008067          	ret
    800046f0:	0104b903          	ld	s2,16(s1)
    800046f4:	fffff097          	auipc	ra,0xfffff
    800046f8:	878080e7          	jalr	-1928(ra) # 80002f6c <mycpu>
    800046fc:	faa91ce3          	bne	s2,a0,800046b4 <acquire+0x58>
    80004700:	00001517          	auipc	a0,0x1
    80004704:	e3050513          	addi	a0,a0,-464 # 80005530 <digits+0x20>
    80004708:	fffff097          	auipc	ra,0xfffff
    8000470c:	224080e7          	jalr	548(ra) # 8000392c <panic>
    80004710:	00195913          	srli	s2,s2,0x1
    80004714:	fffff097          	auipc	ra,0xfffff
    80004718:	858080e7          	jalr	-1960(ra) # 80002f6c <mycpu>
    8000471c:	00197913          	andi	s2,s2,1
    80004720:	07252e23          	sw	s2,124(a0)
    80004724:	f75ff06f          	j	80004698 <acquire+0x3c>

0000000080004728 <release>:
    80004728:	fe010113          	addi	sp,sp,-32
    8000472c:	00813823          	sd	s0,16(sp)
    80004730:	00113c23          	sd	ra,24(sp)
    80004734:	00913423          	sd	s1,8(sp)
    80004738:	01213023          	sd	s2,0(sp)
    8000473c:	02010413          	addi	s0,sp,32
    80004740:	00052783          	lw	a5,0(a0)
    80004744:	00079a63          	bnez	a5,80004758 <release+0x30>
    80004748:	00001517          	auipc	a0,0x1
    8000474c:	df050513          	addi	a0,a0,-528 # 80005538 <digits+0x28>
    80004750:	fffff097          	auipc	ra,0xfffff
    80004754:	1dc080e7          	jalr	476(ra) # 8000392c <panic>
    80004758:	01053903          	ld	s2,16(a0)
    8000475c:	00050493          	mv	s1,a0
    80004760:	fffff097          	auipc	ra,0xfffff
    80004764:	80c080e7          	jalr	-2036(ra) # 80002f6c <mycpu>
    80004768:	fea910e3          	bne	s2,a0,80004748 <release+0x20>
    8000476c:	0004b823          	sd	zero,16(s1)
    80004770:	0ff0000f          	fence
    80004774:	0f50000f          	fence	iorw,ow
    80004778:	0804a02f          	amoswap.w	zero,zero,(s1)
    8000477c:	ffffe097          	auipc	ra,0xffffe
    80004780:	7f0080e7          	jalr	2032(ra) # 80002f6c <mycpu>
    80004784:	100027f3          	csrr	a5,sstatus
    80004788:	0027f793          	andi	a5,a5,2
    8000478c:	04079a63          	bnez	a5,800047e0 <release+0xb8>
    80004790:	07852783          	lw	a5,120(a0)
    80004794:	02f05e63          	blez	a5,800047d0 <release+0xa8>
    80004798:	fff7871b          	addiw	a4,a5,-1
    8000479c:	06e52c23          	sw	a4,120(a0)
    800047a0:	00071c63          	bnez	a4,800047b8 <release+0x90>
    800047a4:	07c52783          	lw	a5,124(a0)
    800047a8:	00078863          	beqz	a5,800047b8 <release+0x90>
    800047ac:	100027f3          	csrr	a5,sstatus
    800047b0:	0027e793          	ori	a5,a5,2
    800047b4:	10079073          	csrw	sstatus,a5
    800047b8:	01813083          	ld	ra,24(sp)
    800047bc:	01013403          	ld	s0,16(sp)
    800047c0:	00813483          	ld	s1,8(sp)
    800047c4:	00013903          	ld	s2,0(sp)
    800047c8:	02010113          	addi	sp,sp,32
    800047cc:	00008067          	ret
    800047d0:	00001517          	auipc	a0,0x1
    800047d4:	d8850513          	addi	a0,a0,-632 # 80005558 <digits+0x48>
    800047d8:	fffff097          	auipc	ra,0xfffff
    800047dc:	154080e7          	jalr	340(ra) # 8000392c <panic>
    800047e0:	00001517          	auipc	a0,0x1
    800047e4:	d6050513          	addi	a0,a0,-672 # 80005540 <digits+0x30>
    800047e8:	fffff097          	auipc	ra,0xfffff
    800047ec:	144080e7          	jalr	324(ra) # 8000392c <panic>

00000000800047f0 <holding>:
    800047f0:	00052783          	lw	a5,0(a0)
    800047f4:	00079663          	bnez	a5,80004800 <holding+0x10>
    800047f8:	00000513          	li	a0,0
    800047fc:	00008067          	ret
    80004800:	fe010113          	addi	sp,sp,-32
    80004804:	00813823          	sd	s0,16(sp)
    80004808:	00913423          	sd	s1,8(sp)
    8000480c:	00113c23          	sd	ra,24(sp)
    80004810:	02010413          	addi	s0,sp,32
    80004814:	01053483          	ld	s1,16(a0)
    80004818:	ffffe097          	auipc	ra,0xffffe
    8000481c:	754080e7          	jalr	1876(ra) # 80002f6c <mycpu>
    80004820:	01813083          	ld	ra,24(sp)
    80004824:	01013403          	ld	s0,16(sp)
    80004828:	40a48533          	sub	a0,s1,a0
    8000482c:	00153513          	seqz	a0,a0
    80004830:	00813483          	ld	s1,8(sp)
    80004834:	02010113          	addi	sp,sp,32
    80004838:	00008067          	ret

000000008000483c <push_off>:
    8000483c:	fe010113          	addi	sp,sp,-32
    80004840:	00813823          	sd	s0,16(sp)
    80004844:	00113c23          	sd	ra,24(sp)
    80004848:	00913423          	sd	s1,8(sp)
    8000484c:	02010413          	addi	s0,sp,32
    80004850:	100024f3          	csrr	s1,sstatus
    80004854:	100027f3          	csrr	a5,sstatus
    80004858:	ffd7f793          	andi	a5,a5,-3
    8000485c:	10079073          	csrw	sstatus,a5
    80004860:	ffffe097          	auipc	ra,0xffffe
    80004864:	70c080e7          	jalr	1804(ra) # 80002f6c <mycpu>
    80004868:	07852783          	lw	a5,120(a0)
    8000486c:	02078663          	beqz	a5,80004898 <push_off+0x5c>
    80004870:	ffffe097          	auipc	ra,0xffffe
    80004874:	6fc080e7          	jalr	1788(ra) # 80002f6c <mycpu>
    80004878:	07852783          	lw	a5,120(a0)
    8000487c:	01813083          	ld	ra,24(sp)
    80004880:	01013403          	ld	s0,16(sp)
    80004884:	0017879b          	addiw	a5,a5,1
    80004888:	06f52c23          	sw	a5,120(a0)
    8000488c:	00813483          	ld	s1,8(sp)
    80004890:	02010113          	addi	sp,sp,32
    80004894:	00008067          	ret
    80004898:	0014d493          	srli	s1,s1,0x1
    8000489c:	ffffe097          	auipc	ra,0xffffe
    800048a0:	6d0080e7          	jalr	1744(ra) # 80002f6c <mycpu>
    800048a4:	0014f493          	andi	s1,s1,1
    800048a8:	06952e23          	sw	s1,124(a0)
    800048ac:	fc5ff06f          	j	80004870 <push_off+0x34>

00000000800048b0 <pop_off>:
    800048b0:	ff010113          	addi	sp,sp,-16
    800048b4:	00813023          	sd	s0,0(sp)
    800048b8:	00113423          	sd	ra,8(sp)
    800048bc:	01010413          	addi	s0,sp,16
    800048c0:	ffffe097          	auipc	ra,0xffffe
    800048c4:	6ac080e7          	jalr	1708(ra) # 80002f6c <mycpu>
    800048c8:	100027f3          	csrr	a5,sstatus
    800048cc:	0027f793          	andi	a5,a5,2
    800048d0:	04079663          	bnez	a5,8000491c <pop_off+0x6c>
    800048d4:	07852783          	lw	a5,120(a0)
    800048d8:	02f05a63          	blez	a5,8000490c <pop_off+0x5c>
    800048dc:	fff7871b          	addiw	a4,a5,-1
    800048e0:	06e52c23          	sw	a4,120(a0)
    800048e4:	00071c63          	bnez	a4,800048fc <pop_off+0x4c>
    800048e8:	07c52783          	lw	a5,124(a0)
    800048ec:	00078863          	beqz	a5,800048fc <pop_off+0x4c>
    800048f0:	100027f3          	csrr	a5,sstatus
    800048f4:	0027e793          	ori	a5,a5,2
    800048f8:	10079073          	csrw	sstatus,a5
    800048fc:	00813083          	ld	ra,8(sp)
    80004900:	00013403          	ld	s0,0(sp)
    80004904:	01010113          	addi	sp,sp,16
    80004908:	00008067          	ret
    8000490c:	00001517          	auipc	a0,0x1
    80004910:	c4c50513          	addi	a0,a0,-948 # 80005558 <digits+0x48>
    80004914:	fffff097          	auipc	ra,0xfffff
    80004918:	018080e7          	jalr	24(ra) # 8000392c <panic>
    8000491c:	00001517          	auipc	a0,0x1
    80004920:	c2450513          	addi	a0,a0,-988 # 80005540 <digits+0x30>
    80004924:	fffff097          	auipc	ra,0xfffff
    80004928:	008080e7          	jalr	8(ra) # 8000392c <panic>

000000008000492c <push_on>:
    8000492c:	fe010113          	addi	sp,sp,-32
    80004930:	00813823          	sd	s0,16(sp)
    80004934:	00113c23          	sd	ra,24(sp)
    80004938:	00913423          	sd	s1,8(sp)
    8000493c:	02010413          	addi	s0,sp,32
    80004940:	100024f3          	csrr	s1,sstatus
    80004944:	100027f3          	csrr	a5,sstatus
    80004948:	0027e793          	ori	a5,a5,2
    8000494c:	10079073          	csrw	sstatus,a5
    80004950:	ffffe097          	auipc	ra,0xffffe
    80004954:	61c080e7          	jalr	1564(ra) # 80002f6c <mycpu>
    80004958:	07852783          	lw	a5,120(a0)
    8000495c:	02078663          	beqz	a5,80004988 <push_on+0x5c>
    80004960:	ffffe097          	auipc	ra,0xffffe
    80004964:	60c080e7          	jalr	1548(ra) # 80002f6c <mycpu>
    80004968:	07852783          	lw	a5,120(a0)
    8000496c:	01813083          	ld	ra,24(sp)
    80004970:	01013403          	ld	s0,16(sp)
    80004974:	0017879b          	addiw	a5,a5,1
    80004978:	06f52c23          	sw	a5,120(a0)
    8000497c:	00813483          	ld	s1,8(sp)
    80004980:	02010113          	addi	sp,sp,32
    80004984:	00008067          	ret
    80004988:	0014d493          	srli	s1,s1,0x1
    8000498c:	ffffe097          	auipc	ra,0xffffe
    80004990:	5e0080e7          	jalr	1504(ra) # 80002f6c <mycpu>
    80004994:	0014f493          	andi	s1,s1,1
    80004998:	06952e23          	sw	s1,124(a0)
    8000499c:	fc5ff06f          	j	80004960 <push_on+0x34>

00000000800049a0 <pop_on>:
    800049a0:	ff010113          	addi	sp,sp,-16
    800049a4:	00813023          	sd	s0,0(sp)
    800049a8:	00113423          	sd	ra,8(sp)
    800049ac:	01010413          	addi	s0,sp,16
    800049b0:	ffffe097          	auipc	ra,0xffffe
    800049b4:	5bc080e7          	jalr	1468(ra) # 80002f6c <mycpu>
    800049b8:	100027f3          	csrr	a5,sstatus
    800049bc:	0027f793          	andi	a5,a5,2
    800049c0:	04078463          	beqz	a5,80004a08 <pop_on+0x68>
    800049c4:	07852783          	lw	a5,120(a0)
    800049c8:	02f05863          	blez	a5,800049f8 <pop_on+0x58>
    800049cc:	fff7879b          	addiw	a5,a5,-1
    800049d0:	06f52c23          	sw	a5,120(a0)
    800049d4:	07853783          	ld	a5,120(a0)
    800049d8:	00079863          	bnez	a5,800049e8 <pop_on+0x48>
    800049dc:	100027f3          	csrr	a5,sstatus
    800049e0:	ffd7f793          	andi	a5,a5,-3
    800049e4:	10079073          	csrw	sstatus,a5
    800049e8:	00813083          	ld	ra,8(sp)
    800049ec:	00013403          	ld	s0,0(sp)
    800049f0:	01010113          	addi	sp,sp,16
    800049f4:	00008067          	ret
    800049f8:	00001517          	auipc	a0,0x1
    800049fc:	b8850513          	addi	a0,a0,-1144 # 80005580 <digits+0x70>
    80004a00:	fffff097          	auipc	ra,0xfffff
    80004a04:	f2c080e7          	jalr	-212(ra) # 8000392c <panic>
    80004a08:	00001517          	auipc	a0,0x1
    80004a0c:	b5850513          	addi	a0,a0,-1192 # 80005560 <digits+0x50>
    80004a10:	fffff097          	auipc	ra,0xfffff
    80004a14:	f1c080e7          	jalr	-228(ra) # 8000392c <panic>

0000000080004a18 <__memset>:
    80004a18:	ff010113          	addi	sp,sp,-16
    80004a1c:	00813423          	sd	s0,8(sp)
    80004a20:	01010413          	addi	s0,sp,16
    80004a24:	1a060e63          	beqz	a2,80004be0 <__memset+0x1c8>
    80004a28:	40a007b3          	neg	a5,a0
    80004a2c:	0077f793          	andi	a5,a5,7
    80004a30:	00778693          	addi	a3,a5,7
    80004a34:	00b00813          	li	a6,11
    80004a38:	0ff5f593          	andi	a1,a1,255
    80004a3c:	fff6071b          	addiw	a4,a2,-1
    80004a40:	1b06e663          	bltu	a3,a6,80004bec <__memset+0x1d4>
    80004a44:	1cd76463          	bltu	a4,a3,80004c0c <__memset+0x1f4>
    80004a48:	1a078e63          	beqz	a5,80004c04 <__memset+0x1ec>
    80004a4c:	00b50023          	sb	a1,0(a0)
    80004a50:	00100713          	li	a4,1
    80004a54:	1ae78463          	beq	a5,a4,80004bfc <__memset+0x1e4>
    80004a58:	00b500a3          	sb	a1,1(a0)
    80004a5c:	00200713          	li	a4,2
    80004a60:	1ae78a63          	beq	a5,a4,80004c14 <__memset+0x1fc>
    80004a64:	00b50123          	sb	a1,2(a0)
    80004a68:	00300713          	li	a4,3
    80004a6c:	18e78463          	beq	a5,a4,80004bf4 <__memset+0x1dc>
    80004a70:	00b501a3          	sb	a1,3(a0)
    80004a74:	00400713          	li	a4,4
    80004a78:	1ae78263          	beq	a5,a4,80004c1c <__memset+0x204>
    80004a7c:	00b50223          	sb	a1,4(a0)
    80004a80:	00500713          	li	a4,5
    80004a84:	1ae78063          	beq	a5,a4,80004c24 <__memset+0x20c>
    80004a88:	00b502a3          	sb	a1,5(a0)
    80004a8c:	00700713          	li	a4,7
    80004a90:	18e79e63          	bne	a5,a4,80004c2c <__memset+0x214>
    80004a94:	00b50323          	sb	a1,6(a0)
    80004a98:	00700e93          	li	t4,7
    80004a9c:	00859713          	slli	a4,a1,0x8
    80004aa0:	00e5e733          	or	a4,a1,a4
    80004aa4:	01059e13          	slli	t3,a1,0x10
    80004aa8:	01c76e33          	or	t3,a4,t3
    80004aac:	01859313          	slli	t1,a1,0x18
    80004ab0:	006e6333          	or	t1,t3,t1
    80004ab4:	02059893          	slli	a7,a1,0x20
    80004ab8:	40f60e3b          	subw	t3,a2,a5
    80004abc:	011368b3          	or	a7,t1,a7
    80004ac0:	02859813          	slli	a6,a1,0x28
    80004ac4:	0108e833          	or	a6,a7,a6
    80004ac8:	03059693          	slli	a3,a1,0x30
    80004acc:	003e589b          	srliw	a7,t3,0x3
    80004ad0:	00d866b3          	or	a3,a6,a3
    80004ad4:	03859713          	slli	a4,a1,0x38
    80004ad8:	00389813          	slli	a6,a7,0x3
    80004adc:	00f507b3          	add	a5,a0,a5
    80004ae0:	00e6e733          	or	a4,a3,a4
    80004ae4:	000e089b          	sext.w	a7,t3
    80004ae8:	00f806b3          	add	a3,a6,a5
    80004aec:	00e7b023          	sd	a4,0(a5)
    80004af0:	00878793          	addi	a5,a5,8
    80004af4:	fed79ce3          	bne	a5,a3,80004aec <__memset+0xd4>
    80004af8:	ff8e7793          	andi	a5,t3,-8
    80004afc:	0007871b          	sext.w	a4,a5
    80004b00:	01d787bb          	addw	a5,a5,t4
    80004b04:	0ce88e63          	beq	a7,a4,80004be0 <__memset+0x1c8>
    80004b08:	00f50733          	add	a4,a0,a5
    80004b0c:	00b70023          	sb	a1,0(a4)
    80004b10:	0017871b          	addiw	a4,a5,1
    80004b14:	0cc77663          	bgeu	a4,a2,80004be0 <__memset+0x1c8>
    80004b18:	00e50733          	add	a4,a0,a4
    80004b1c:	00b70023          	sb	a1,0(a4)
    80004b20:	0027871b          	addiw	a4,a5,2
    80004b24:	0ac77e63          	bgeu	a4,a2,80004be0 <__memset+0x1c8>
    80004b28:	00e50733          	add	a4,a0,a4
    80004b2c:	00b70023          	sb	a1,0(a4)
    80004b30:	0037871b          	addiw	a4,a5,3
    80004b34:	0ac77663          	bgeu	a4,a2,80004be0 <__memset+0x1c8>
    80004b38:	00e50733          	add	a4,a0,a4
    80004b3c:	00b70023          	sb	a1,0(a4)
    80004b40:	0047871b          	addiw	a4,a5,4
    80004b44:	08c77e63          	bgeu	a4,a2,80004be0 <__memset+0x1c8>
    80004b48:	00e50733          	add	a4,a0,a4
    80004b4c:	00b70023          	sb	a1,0(a4)
    80004b50:	0057871b          	addiw	a4,a5,5
    80004b54:	08c77663          	bgeu	a4,a2,80004be0 <__memset+0x1c8>
    80004b58:	00e50733          	add	a4,a0,a4
    80004b5c:	00b70023          	sb	a1,0(a4)
    80004b60:	0067871b          	addiw	a4,a5,6
    80004b64:	06c77e63          	bgeu	a4,a2,80004be0 <__memset+0x1c8>
    80004b68:	00e50733          	add	a4,a0,a4
    80004b6c:	00b70023          	sb	a1,0(a4)
    80004b70:	0077871b          	addiw	a4,a5,7
    80004b74:	06c77663          	bgeu	a4,a2,80004be0 <__memset+0x1c8>
    80004b78:	00e50733          	add	a4,a0,a4
    80004b7c:	00b70023          	sb	a1,0(a4)
    80004b80:	0087871b          	addiw	a4,a5,8
    80004b84:	04c77e63          	bgeu	a4,a2,80004be0 <__memset+0x1c8>
    80004b88:	00e50733          	add	a4,a0,a4
    80004b8c:	00b70023          	sb	a1,0(a4)
    80004b90:	0097871b          	addiw	a4,a5,9
    80004b94:	04c77663          	bgeu	a4,a2,80004be0 <__memset+0x1c8>
    80004b98:	00e50733          	add	a4,a0,a4
    80004b9c:	00b70023          	sb	a1,0(a4)
    80004ba0:	00a7871b          	addiw	a4,a5,10
    80004ba4:	02c77e63          	bgeu	a4,a2,80004be0 <__memset+0x1c8>
    80004ba8:	00e50733          	add	a4,a0,a4
    80004bac:	00b70023          	sb	a1,0(a4)
    80004bb0:	00b7871b          	addiw	a4,a5,11
    80004bb4:	02c77663          	bgeu	a4,a2,80004be0 <__memset+0x1c8>
    80004bb8:	00e50733          	add	a4,a0,a4
    80004bbc:	00b70023          	sb	a1,0(a4)
    80004bc0:	00c7871b          	addiw	a4,a5,12
    80004bc4:	00c77e63          	bgeu	a4,a2,80004be0 <__memset+0x1c8>
    80004bc8:	00e50733          	add	a4,a0,a4
    80004bcc:	00b70023          	sb	a1,0(a4)
    80004bd0:	00d7879b          	addiw	a5,a5,13
    80004bd4:	00c7f663          	bgeu	a5,a2,80004be0 <__memset+0x1c8>
    80004bd8:	00f507b3          	add	a5,a0,a5
    80004bdc:	00b78023          	sb	a1,0(a5)
    80004be0:	00813403          	ld	s0,8(sp)
    80004be4:	01010113          	addi	sp,sp,16
    80004be8:	00008067          	ret
    80004bec:	00b00693          	li	a3,11
    80004bf0:	e55ff06f          	j	80004a44 <__memset+0x2c>
    80004bf4:	00300e93          	li	t4,3
    80004bf8:	ea5ff06f          	j	80004a9c <__memset+0x84>
    80004bfc:	00100e93          	li	t4,1
    80004c00:	e9dff06f          	j	80004a9c <__memset+0x84>
    80004c04:	00000e93          	li	t4,0
    80004c08:	e95ff06f          	j	80004a9c <__memset+0x84>
    80004c0c:	00000793          	li	a5,0
    80004c10:	ef9ff06f          	j	80004b08 <__memset+0xf0>
    80004c14:	00200e93          	li	t4,2
    80004c18:	e85ff06f          	j	80004a9c <__memset+0x84>
    80004c1c:	00400e93          	li	t4,4
    80004c20:	e7dff06f          	j	80004a9c <__memset+0x84>
    80004c24:	00500e93          	li	t4,5
    80004c28:	e75ff06f          	j	80004a9c <__memset+0x84>
    80004c2c:	00600e93          	li	t4,6
    80004c30:	e6dff06f          	j	80004a9c <__memset+0x84>

0000000080004c34 <__memmove>:
    80004c34:	ff010113          	addi	sp,sp,-16
    80004c38:	00813423          	sd	s0,8(sp)
    80004c3c:	01010413          	addi	s0,sp,16
    80004c40:	0e060863          	beqz	a2,80004d30 <__memmove+0xfc>
    80004c44:	fff6069b          	addiw	a3,a2,-1
    80004c48:	0006881b          	sext.w	a6,a3
    80004c4c:	0ea5e863          	bltu	a1,a0,80004d3c <__memmove+0x108>
    80004c50:	00758713          	addi	a4,a1,7
    80004c54:	00a5e7b3          	or	a5,a1,a0
    80004c58:	40a70733          	sub	a4,a4,a0
    80004c5c:	0077f793          	andi	a5,a5,7
    80004c60:	00f73713          	sltiu	a4,a4,15
    80004c64:	00174713          	xori	a4,a4,1
    80004c68:	0017b793          	seqz	a5,a5
    80004c6c:	00e7f7b3          	and	a5,a5,a4
    80004c70:	10078863          	beqz	a5,80004d80 <__memmove+0x14c>
    80004c74:	00900793          	li	a5,9
    80004c78:	1107f463          	bgeu	a5,a6,80004d80 <__memmove+0x14c>
    80004c7c:	0036581b          	srliw	a6,a2,0x3
    80004c80:	fff8081b          	addiw	a6,a6,-1
    80004c84:	02081813          	slli	a6,a6,0x20
    80004c88:	01d85893          	srli	a7,a6,0x1d
    80004c8c:	00858813          	addi	a6,a1,8
    80004c90:	00058793          	mv	a5,a1
    80004c94:	00050713          	mv	a4,a0
    80004c98:	01088833          	add	a6,a7,a6
    80004c9c:	0007b883          	ld	a7,0(a5)
    80004ca0:	00878793          	addi	a5,a5,8
    80004ca4:	00870713          	addi	a4,a4,8
    80004ca8:	ff173c23          	sd	a7,-8(a4)
    80004cac:	ff0798e3          	bne	a5,a6,80004c9c <__memmove+0x68>
    80004cb0:	ff867713          	andi	a4,a2,-8
    80004cb4:	02071793          	slli	a5,a4,0x20
    80004cb8:	0207d793          	srli	a5,a5,0x20
    80004cbc:	00f585b3          	add	a1,a1,a5
    80004cc0:	40e686bb          	subw	a3,a3,a4
    80004cc4:	00f507b3          	add	a5,a0,a5
    80004cc8:	06e60463          	beq	a2,a4,80004d30 <__memmove+0xfc>
    80004ccc:	0005c703          	lbu	a4,0(a1)
    80004cd0:	00e78023          	sb	a4,0(a5)
    80004cd4:	04068e63          	beqz	a3,80004d30 <__memmove+0xfc>
    80004cd8:	0015c603          	lbu	a2,1(a1)
    80004cdc:	00100713          	li	a4,1
    80004ce0:	00c780a3          	sb	a2,1(a5)
    80004ce4:	04e68663          	beq	a3,a4,80004d30 <__memmove+0xfc>
    80004ce8:	0025c603          	lbu	a2,2(a1)
    80004cec:	00200713          	li	a4,2
    80004cf0:	00c78123          	sb	a2,2(a5)
    80004cf4:	02e68e63          	beq	a3,a4,80004d30 <__memmove+0xfc>
    80004cf8:	0035c603          	lbu	a2,3(a1)
    80004cfc:	00300713          	li	a4,3
    80004d00:	00c781a3          	sb	a2,3(a5)
    80004d04:	02e68663          	beq	a3,a4,80004d30 <__memmove+0xfc>
    80004d08:	0045c603          	lbu	a2,4(a1)
    80004d0c:	00400713          	li	a4,4
    80004d10:	00c78223          	sb	a2,4(a5)
    80004d14:	00e68e63          	beq	a3,a4,80004d30 <__memmove+0xfc>
    80004d18:	0055c603          	lbu	a2,5(a1)
    80004d1c:	00500713          	li	a4,5
    80004d20:	00c782a3          	sb	a2,5(a5)
    80004d24:	00e68663          	beq	a3,a4,80004d30 <__memmove+0xfc>
    80004d28:	0065c703          	lbu	a4,6(a1)
    80004d2c:	00e78323          	sb	a4,6(a5)
    80004d30:	00813403          	ld	s0,8(sp)
    80004d34:	01010113          	addi	sp,sp,16
    80004d38:	00008067          	ret
    80004d3c:	02061713          	slli	a4,a2,0x20
    80004d40:	02075713          	srli	a4,a4,0x20
    80004d44:	00e587b3          	add	a5,a1,a4
    80004d48:	f0f574e3          	bgeu	a0,a5,80004c50 <__memmove+0x1c>
    80004d4c:	02069613          	slli	a2,a3,0x20
    80004d50:	02065613          	srli	a2,a2,0x20
    80004d54:	fff64613          	not	a2,a2
    80004d58:	00e50733          	add	a4,a0,a4
    80004d5c:	00c78633          	add	a2,a5,a2
    80004d60:	fff7c683          	lbu	a3,-1(a5)
    80004d64:	fff78793          	addi	a5,a5,-1
    80004d68:	fff70713          	addi	a4,a4,-1
    80004d6c:	00d70023          	sb	a3,0(a4)
    80004d70:	fec798e3          	bne	a5,a2,80004d60 <__memmove+0x12c>
    80004d74:	00813403          	ld	s0,8(sp)
    80004d78:	01010113          	addi	sp,sp,16
    80004d7c:	00008067          	ret
    80004d80:	02069713          	slli	a4,a3,0x20
    80004d84:	02075713          	srli	a4,a4,0x20
    80004d88:	00170713          	addi	a4,a4,1
    80004d8c:	00e50733          	add	a4,a0,a4
    80004d90:	00050793          	mv	a5,a0
    80004d94:	0005c683          	lbu	a3,0(a1)
    80004d98:	00178793          	addi	a5,a5,1
    80004d9c:	00158593          	addi	a1,a1,1
    80004da0:	fed78fa3          	sb	a3,-1(a5)
    80004da4:	fee798e3          	bne	a5,a4,80004d94 <__memmove+0x160>
    80004da8:	f89ff06f          	j	80004d30 <__memmove+0xfc>
	...
