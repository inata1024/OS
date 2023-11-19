
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fda50513          	addi	a0,a0,-38 # ffffffffc0206010 <edata>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	42260613          	addi	a2,a2,1058 # ffffffffc0206460 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	5fe010ef          	jal	ra,ffffffffc020164c <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00001517          	auipc	a0,0x1
ffffffffc020005a:	60a50513          	addi	a0,a0,1546 # ffffffffc0201660 <etext+0x2>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	617000ef          	jal	ra,ffffffffc0200e80 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3fc000ef          	jal	ra,ffffffffc020046a <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	39a000ef          	jal	ra,ffffffffc020040c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e8000ef          	jal	ra,ffffffffc020045e <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200084:	3ce000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200088:	401c                	lw	a5,0(s0)
}
ffffffffc020008a:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
}
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200096:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000aa:	094010ef          	jal	ra,ffffffffc020113e <vprintfmt>
    return cnt;
}
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000da:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000dc:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000de:	060010ef          	jal	ra,ffffffffc020113e <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ea:	3680006f          	j	ffffffffc0200452 <cons_putc>

ffffffffc02000ee <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ee:	1101                	addi	sp,sp,-32
ffffffffc02000f0:	e822                	sd	s0,16(sp)
ffffffffc02000f2:	ec06                	sd	ra,24(sp)
ffffffffc02000f4:	e426                	sd	s1,8(sp)
ffffffffc02000f6:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f8:	00054503          	lbu	a0,0(a0)
ffffffffc02000fc:	c51d                	beqz	a0,ffffffffc020012a <cputs+0x3c>
ffffffffc02000fe:	0405                	addi	s0,s0,1
ffffffffc0200100:	4485                	li	s1,1
ffffffffc0200102:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200104:	34e000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200112:	f96d                	bnez	a0,ffffffffc0200104 <cputs+0x16>
ffffffffc0200114:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200118:	4529                	li	a0,10
ffffffffc020011a:	338000ef          	jal	ra,ffffffffc0200452 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011e:	8522                	mv	a0,s0
ffffffffc0200120:	60e2                	ld	ra,24(sp)
ffffffffc0200122:	6442                	ld	s0,16(sp)
ffffffffc0200124:	64a2                	ld	s1,8(sp)
ffffffffc0200126:	6105                	addi	sp,sp,32
ffffffffc0200128:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020012a:	4405                	li	s0,1
ffffffffc020012c:	b7f5                	j	ffffffffc0200118 <cputs+0x2a>

ffffffffc020012e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012e:	1141                	addi	sp,sp,-16
ffffffffc0200130:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200132:	328000ef          	jal	ra,ffffffffc020045a <cons_getc>
ffffffffc0200136:	dd75                	beqz	a0,ffffffffc0200132 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200138:	60a2                	ld	ra,8(sp)
ffffffffc020013a:	0141                	addi	sp,sp,16
ffffffffc020013c:	8082                	ret

ffffffffc020013e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200140:	00001517          	auipc	a0,0x1
ffffffffc0200144:	57050513          	addi	a0,a0,1392 # ffffffffc02016b0 <etext+0x52>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00001517          	auipc	a0,0x1
ffffffffc020015a:	57a50513          	addi	a0,a0,1402 # ffffffffc02016d0 <etext+0x72>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00001597          	auipc	a1,0x1
ffffffffc0200166:	4fc58593          	addi	a1,a1,1276 # ffffffffc020165e <etext>
ffffffffc020016a:	00001517          	auipc	a0,0x1
ffffffffc020016e:	58650513          	addi	a0,a0,1414 # ffffffffc02016f0 <etext+0x92>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00006597          	auipc	a1,0x6
ffffffffc020017a:	e9a58593          	addi	a1,a1,-358 # ffffffffc0206010 <edata>
ffffffffc020017e:	00001517          	auipc	a0,0x1
ffffffffc0200182:	59250513          	addi	a0,a0,1426 # ffffffffc0201710 <etext+0xb2>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00006597          	auipc	a1,0x6
ffffffffc020018e:	2d658593          	addi	a1,a1,726 # ffffffffc0206460 <end>
ffffffffc0200192:	00001517          	auipc	a0,0x1
ffffffffc0200196:	59e50513          	addi	a0,a0,1438 # ffffffffc0201730 <etext+0xd2>
ffffffffc020019a:	f1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019e:	00006597          	auipc	a1,0x6
ffffffffc02001a2:	6c158593          	addi	a1,a1,1729 # ffffffffc020685f <end+0x3ff>
ffffffffc02001a6:	00000797          	auipc	a5,0x0
ffffffffc02001aa:	e9078793          	addi	a5,a5,-368 # ffffffffc0200036 <kern_init>
ffffffffc02001ae:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b2:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b6:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b8:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001bc:	95be                	add	a1,a1,a5
ffffffffc02001be:	85a9                	srai	a1,a1,0xa
ffffffffc02001c0:	00001517          	auipc	a0,0x1
ffffffffc02001c4:	59050513          	addi	a0,a0,1424 # ffffffffc0201750 <etext+0xf2>
}
ffffffffc02001c8:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ca:	eedff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02001ce <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001ce:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001d0:	00001617          	auipc	a2,0x1
ffffffffc02001d4:	4b060613          	addi	a2,a2,1200 # ffffffffc0201680 <etext+0x22>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00001517          	auipc	a0,0x1
ffffffffc02001e0:	4bc50513          	addi	a0,a0,1212 # ffffffffc0201698 <etext+0x3a>
void print_stackframe(void) {
ffffffffc02001e4:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e6:	1c6000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001ea <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ea:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ec:	00001617          	auipc	a2,0x1
ffffffffc02001f0:	67460613          	addi	a2,a2,1652 # ffffffffc0201860 <commands+0xe0>
ffffffffc02001f4:	00001597          	auipc	a1,0x1
ffffffffc02001f8:	68c58593          	addi	a1,a1,1676 # ffffffffc0201880 <commands+0x100>
ffffffffc02001fc:	00001517          	auipc	a0,0x1
ffffffffc0200200:	68c50513          	addi	a0,a0,1676 # ffffffffc0201888 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00001617          	auipc	a2,0x1
ffffffffc020020e:	68e60613          	addi	a2,a2,1678 # ffffffffc0201898 <commands+0x118>
ffffffffc0200212:	00001597          	auipc	a1,0x1
ffffffffc0200216:	6ae58593          	addi	a1,a1,1710 # ffffffffc02018c0 <commands+0x140>
ffffffffc020021a:	00001517          	auipc	a0,0x1
ffffffffc020021e:	66e50513          	addi	a0,a0,1646 # ffffffffc0201888 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00001617          	auipc	a2,0x1
ffffffffc020022a:	6aa60613          	addi	a2,a2,1706 # ffffffffc02018d0 <commands+0x150>
ffffffffc020022e:	00001597          	auipc	a1,0x1
ffffffffc0200232:	6c258593          	addi	a1,a1,1730 # ffffffffc02018f0 <commands+0x170>
ffffffffc0200236:	00001517          	auipc	a0,0x1
ffffffffc020023a:	65250513          	addi	a0,a0,1618 # ffffffffc0201888 <commands+0x108>
ffffffffc020023e:	e79ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    }
    return 0;
}
ffffffffc0200242:	60a2                	ld	ra,8(sp)
ffffffffc0200244:	4501                	li	a0,0
ffffffffc0200246:	0141                	addi	sp,sp,16
ffffffffc0200248:	8082                	ret

ffffffffc020024a <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024a:	1141                	addi	sp,sp,-16
ffffffffc020024c:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020024e:	ef1ff0ef          	jal	ra,ffffffffc020013e <print_kerninfo>
    return 0;
}
ffffffffc0200252:	60a2                	ld	ra,8(sp)
ffffffffc0200254:	4501                	li	a0,0
ffffffffc0200256:	0141                	addi	sp,sp,16
ffffffffc0200258:	8082                	ret

ffffffffc020025a <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	1141                	addi	sp,sp,-16
ffffffffc020025c:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020025e:	f71ff0ef          	jal	ra,ffffffffc02001ce <print_stackframe>
    return 0;
}
ffffffffc0200262:	60a2                	ld	ra,8(sp)
ffffffffc0200264:	4501                	li	a0,0
ffffffffc0200266:	0141                	addi	sp,sp,16
ffffffffc0200268:	8082                	ret

ffffffffc020026a <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020026a:	7115                	addi	sp,sp,-224
ffffffffc020026c:	e962                	sd	s8,144(sp)
ffffffffc020026e:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200270:	00001517          	auipc	a0,0x1
ffffffffc0200274:	55850513          	addi	a0,a0,1368 # ffffffffc02017c8 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200278:	ed86                	sd	ra,216(sp)
ffffffffc020027a:	e9a2                	sd	s0,208(sp)
ffffffffc020027c:	e5a6                	sd	s1,200(sp)
ffffffffc020027e:	e1ca                	sd	s2,192(sp)
ffffffffc0200280:	fd4e                	sd	s3,184(sp)
ffffffffc0200282:	f952                	sd	s4,176(sp)
ffffffffc0200284:	f556                	sd	s5,168(sp)
ffffffffc0200286:	f15a                	sd	s6,160(sp)
ffffffffc0200288:	ed5e                	sd	s7,152(sp)
ffffffffc020028a:	e566                	sd	s9,136(sp)
ffffffffc020028c:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020028e:	e29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200292:	00001517          	auipc	a0,0x1
ffffffffc0200296:	55e50513          	addi	a0,a0,1374 # ffffffffc02017f0 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00001c97          	auipc	s9,0x1
ffffffffc02002ac:	4d8c8c93          	addi	s9,s9,1240 # ffffffffc0201780 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00001997          	auipc	s3,0x1
ffffffffc02002b4:	56898993          	addi	s3,s3,1384 # ffffffffc0201818 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00001917          	auipc	s2,0x1
ffffffffc02002bc:	56890913          	addi	s2,s2,1384 # ffffffffc0201820 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00001b17          	auipc	s6,0x1
ffffffffc02002c6:	566b0b13          	addi	s6,s6,1382 # ffffffffc0201828 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00001a97          	auipc	s5,0x1
ffffffffc02002ce:	5b6a8a93          	addi	s5,s5,1462 # ffffffffc0201880 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	1f4010ef          	jal	ra,ffffffffc02014ca <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	346010ef          	jal	ra,ffffffffc020162e <strchr>
ffffffffc02002ec:	c925                	beqz	a0,ffffffffc020035c <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002ee:	00144583          	lbu	a1,1(s0)
ffffffffc02002f2:	00040023          	sb	zero,0(s0)
ffffffffc02002f6:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002f8:	f5fd                	bnez	a1,ffffffffc02002e6 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002fa:	dce9                	beqz	s1,ffffffffc02002d4 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002fc:	6582                	ld	a1,0(sp)
ffffffffc02002fe:	00001d17          	auipc	s10,0x1
ffffffffc0200302:	482d0d13          	addi	s10,s10,1154 # ffffffffc0201780 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	2f8010ef          	jal	ra,ffffffffc0201604 <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	2e4010ef          	jal	ra,ffffffffc0201604 <strcmp>
ffffffffc0200324:	f57d                	bnez	a0,ffffffffc0200312 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200326:	00141793          	slli	a5,s0,0x1
ffffffffc020032a:	97a2                	add	a5,a5,s0
ffffffffc020032c:	078e                	slli	a5,a5,0x3
ffffffffc020032e:	97e6                	add	a5,a5,s9
ffffffffc0200330:	6b9c                	ld	a5,16(a5)
ffffffffc0200332:	8662                	mv	a2,s8
ffffffffc0200334:	002c                	addi	a1,sp,8
ffffffffc0200336:	fff4851b          	addiw	a0,s1,-1
ffffffffc020033a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020033c:	f8055ce3          	bgez	a0,ffffffffc02002d4 <kmonitor+0x6a>
}
ffffffffc0200340:	60ee                	ld	ra,216(sp)
ffffffffc0200342:	644e                	ld	s0,208(sp)
ffffffffc0200344:	64ae                	ld	s1,200(sp)
ffffffffc0200346:	690e                	ld	s2,192(sp)
ffffffffc0200348:	79ea                	ld	s3,184(sp)
ffffffffc020034a:	7a4a                	ld	s4,176(sp)
ffffffffc020034c:	7aaa                	ld	s5,168(sp)
ffffffffc020034e:	7b0a                	ld	s6,160(sp)
ffffffffc0200350:	6bea                	ld	s7,152(sp)
ffffffffc0200352:	6c4a                	ld	s8,144(sp)
ffffffffc0200354:	6caa                	ld	s9,136(sp)
ffffffffc0200356:	6d0a                	ld	s10,128(sp)
ffffffffc0200358:	612d                	addi	sp,sp,224
ffffffffc020035a:	8082                	ret
        if (*buf == '\0') {
ffffffffc020035c:	00044783          	lbu	a5,0(s0)
ffffffffc0200360:	dfc9                	beqz	a5,ffffffffc02002fa <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc0200362:	03448863          	beq	s1,s4,ffffffffc0200392 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc0200366:	00349793          	slli	a5,s1,0x3
ffffffffc020036a:	0118                	addi	a4,sp,128
ffffffffc020036c:	97ba                	add	a5,a5,a4
ffffffffc020036e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200372:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200376:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200378:	e591                	bnez	a1,ffffffffc0200384 <kmonitor+0x11a>
ffffffffc020037a:	b749                	j	ffffffffc02002fc <kmonitor+0x92>
            buf ++;
ffffffffc020037c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020037e:	00044583          	lbu	a1,0(s0)
ffffffffc0200382:	ddad                	beqz	a1,ffffffffc02002fc <kmonitor+0x92>
ffffffffc0200384:	854a                	mv	a0,s2
ffffffffc0200386:	2a8010ef          	jal	ra,ffffffffc020162e <strchr>
ffffffffc020038a:	d96d                	beqz	a0,ffffffffc020037c <kmonitor+0x112>
ffffffffc020038c:	00044583          	lbu	a1,0(s0)
ffffffffc0200390:	bf91                	j	ffffffffc02002e4 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020039a:	b7f1                	j	ffffffffc0200366 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	4aa50513          	addi	a0,a0,1194 # ffffffffc0201848 <commands+0xc8>
ffffffffc02003a6:	d11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return 0;
ffffffffc02003aa:	b72d                	j	ffffffffc02002d4 <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	06430313          	addi	t1,t1,100 # ffffffffc0206410 <is_panic>
ffffffffc02003b4:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	02031c63          	bnez	t1,ffffffffc0200400 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	8432                	mv	s0,a2
ffffffffc02003d0:	00006717          	auipc	a4,0x6
ffffffffc02003d4:	04f72023          	sw	a5,64(a4) # ffffffffc0206410 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d8:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003da:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003dc:	85aa                	mv	a1,a0
ffffffffc02003de:	00001517          	auipc	a0,0x1
ffffffffc02003e2:	52250513          	addi	a0,a0,1314 # ffffffffc0201900 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02003e6:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e8:	ccfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003ec:	65a2                	ld	a1,8(sp)
ffffffffc02003ee:	8522                	mv	a0,s0
ffffffffc02003f0:	ca7ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc02003f4:	00002517          	auipc	a0,0x2
ffffffffc02003f8:	9dc50513          	addi	a0,a0,-1572 # ffffffffc0201dd0 <commands+0x650>
ffffffffc02003fc:	cbbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200400:	064000ef          	jal	ra,ffffffffc0200464 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200404:	4501                	li	a0,0
ffffffffc0200406:	e65ff0ef          	jal	ra,ffffffffc020026a <kmonitor>
ffffffffc020040a:	bfed                	j	ffffffffc0200404 <__panic+0x58>

ffffffffc020040c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020040c:	1141                	addi	sp,sp,-16
ffffffffc020040e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200410:	02000793          	li	a5,32
ffffffffc0200414:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200418:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020041c:	67e1                	lui	a5,0x18
ffffffffc020041e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200422:	953e                	add	a0,a0,a5
ffffffffc0200424:	180010ef          	jal	ra,ffffffffc02015a4 <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00001517          	auipc	a0,0x1
ffffffffc0200436:	4ee50513          	addi	a0,a0,1262 # ffffffffc0201920 <commands+0x1a0>
}
ffffffffc020043a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020043c:	c7bff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc0200440 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200440:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200444:	67e1                	lui	a5,0x18
ffffffffc0200446:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020044a:	953e                	add	a0,a0,a5
ffffffffc020044c:	1580106f          	j	ffffffffc02015a4 <sbi_set_timer>

ffffffffc0200450 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200450:	8082                	ret

ffffffffc0200452 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200452:	0ff57513          	andi	a0,a0,255
ffffffffc0200456:	1320106f          	j	ffffffffc0201588 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	1660106f          	j	ffffffffc02015c0 <sbi_console_getchar>

ffffffffc020045e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200464:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200468:	8082                	ret

ffffffffc020046a <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020046a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020046e:	00000797          	auipc	a5,0x0
ffffffffc0200472:	30678793          	addi	a5,a5,774 # ffffffffc0200774 <__alltraps>
ffffffffc0200476:	10579073          	csrw	stvec,a5
}
ffffffffc020047a:	8082                	ret

ffffffffc020047c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020047e:	1141                	addi	sp,sp,-16
ffffffffc0200480:	e022                	sd	s0,0(sp)
ffffffffc0200482:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200484:	00001517          	auipc	a0,0x1
ffffffffc0200488:	5b450513          	addi	a0,a0,1460 # ffffffffc0201a38 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00001517          	auipc	a0,0x1
ffffffffc0200498:	5bc50513          	addi	a0,a0,1468 # ffffffffc0201a50 <commands+0x2d0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00001517          	auipc	a0,0x1
ffffffffc02004a6:	5c650513          	addi	a0,a0,1478 # ffffffffc0201a68 <commands+0x2e8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00001517          	auipc	a0,0x1
ffffffffc02004b4:	5d050513          	addi	a0,a0,1488 # ffffffffc0201a80 <commands+0x300>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00001517          	auipc	a0,0x1
ffffffffc02004c2:	5da50513          	addi	a0,a0,1498 # ffffffffc0201a98 <commands+0x318>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00001517          	auipc	a0,0x1
ffffffffc02004d0:	5e450513          	addi	a0,a0,1508 # ffffffffc0201ab0 <commands+0x330>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00001517          	auipc	a0,0x1
ffffffffc02004de:	5ee50513          	addi	a0,a0,1518 # ffffffffc0201ac8 <commands+0x348>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00001517          	auipc	a0,0x1
ffffffffc02004ec:	5f850513          	addi	a0,a0,1528 # ffffffffc0201ae0 <commands+0x360>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00001517          	auipc	a0,0x1
ffffffffc02004fa:	60250513          	addi	a0,a0,1538 # ffffffffc0201af8 <commands+0x378>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00001517          	auipc	a0,0x1
ffffffffc0200508:	60c50513          	addi	a0,a0,1548 # ffffffffc0201b10 <commands+0x390>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00001517          	auipc	a0,0x1
ffffffffc0200516:	61650513          	addi	a0,a0,1558 # ffffffffc0201b28 <commands+0x3a8>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00001517          	auipc	a0,0x1
ffffffffc0200524:	62050513          	addi	a0,a0,1568 # ffffffffc0201b40 <commands+0x3c0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00001517          	auipc	a0,0x1
ffffffffc0200532:	62a50513          	addi	a0,a0,1578 # ffffffffc0201b58 <commands+0x3d8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00001517          	auipc	a0,0x1
ffffffffc0200540:	63450513          	addi	a0,a0,1588 # ffffffffc0201b70 <commands+0x3f0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00001517          	auipc	a0,0x1
ffffffffc020054e:	63e50513          	addi	a0,a0,1598 # ffffffffc0201b88 <commands+0x408>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00001517          	auipc	a0,0x1
ffffffffc020055c:	64850513          	addi	a0,a0,1608 # ffffffffc0201ba0 <commands+0x420>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00001517          	auipc	a0,0x1
ffffffffc020056a:	65250513          	addi	a0,a0,1618 # ffffffffc0201bb8 <commands+0x438>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00001517          	auipc	a0,0x1
ffffffffc0200578:	65c50513          	addi	a0,a0,1628 # ffffffffc0201bd0 <commands+0x450>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00001517          	auipc	a0,0x1
ffffffffc0200586:	66650513          	addi	a0,a0,1638 # ffffffffc0201be8 <commands+0x468>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00001517          	auipc	a0,0x1
ffffffffc0200594:	67050513          	addi	a0,a0,1648 # ffffffffc0201c00 <commands+0x480>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00001517          	auipc	a0,0x1
ffffffffc02005a2:	67a50513          	addi	a0,a0,1658 # ffffffffc0201c18 <commands+0x498>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00001517          	auipc	a0,0x1
ffffffffc02005b0:	68450513          	addi	a0,a0,1668 # ffffffffc0201c30 <commands+0x4b0>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00001517          	auipc	a0,0x1
ffffffffc02005be:	68e50513          	addi	a0,a0,1678 # ffffffffc0201c48 <commands+0x4c8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00001517          	auipc	a0,0x1
ffffffffc02005cc:	69850513          	addi	a0,a0,1688 # ffffffffc0201c60 <commands+0x4e0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00001517          	auipc	a0,0x1
ffffffffc02005da:	6a250513          	addi	a0,a0,1698 # ffffffffc0201c78 <commands+0x4f8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00001517          	auipc	a0,0x1
ffffffffc02005e8:	6ac50513          	addi	a0,a0,1708 # ffffffffc0201c90 <commands+0x510>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00001517          	auipc	a0,0x1
ffffffffc02005f6:	6b650513          	addi	a0,a0,1718 # ffffffffc0201ca8 <commands+0x528>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00001517          	auipc	a0,0x1
ffffffffc0200604:	6c050513          	addi	a0,a0,1728 # ffffffffc0201cc0 <commands+0x540>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00001517          	auipc	a0,0x1
ffffffffc0200612:	6ca50513          	addi	a0,a0,1738 # ffffffffc0201cd8 <commands+0x558>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00001517          	auipc	a0,0x1
ffffffffc0200620:	6d450513          	addi	a0,a0,1748 # ffffffffc0201cf0 <commands+0x570>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00001517          	auipc	a0,0x1
ffffffffc020062e:	6de50513          	addi	a0,a0,1758 # ffffffffc0201d08 <commands+0x588>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00001517          	auipc	a0,0x1
ffffffffc0200640:	6e450513          	addi	a0,a0,1764 # ffffffffc0201d20 <commands+0x5a0>
}
ffffffffc0200644:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200646:	a71ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020064a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020064e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200650:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200652:	00001517          	auipc	a0,0x1
ffffffffc0200656:	6e650513          	addi	a0,a0,1766 # ffffffffc0201d38 <commands+0x5b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	a5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1bff0ef          	jal	ra,ffffffffc020047c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00001517          	auipc	a0,0x1
ffffffffc020066e:	6e650513          	addi	a0,a0,1766 # ffffffffc0201d50 <commands+0x5d0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00001517          	auipc	a0,0x1
ffffffffc020067e:	6ee50513          	addi	a0,a0,1774 # ffffffffc0201d68 <commands+0x5e8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00001517          	auipc	a0,0x1
ffffffffc020068e:	6f650513          	addi	a0,a0,1782 # ffffffffc0201d80 <commands+0x600>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00001517          	auipc	a0,0x1
ffffffffc02006a2:	6fa50513          	addi	a0,a0,1786 # ffffffffc0201d98 <commands+0x618>
}
ffffffffc02006a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a8:	a0fff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02006ac <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006ac:	11853783          	ld	a5,280(a0)
ffffffffc02006b0:	577d                	li	a4,-1
ffffffffc02006b2:	8305                	srli	a4,a4,0x1
ffffffffc02006b4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02006b6:	472d                	li	a4,11
ffffffffc02006b8:	08f76563          	bltu	a4,a5,ffffffffc0200742 <interrupt_handler+0x96>
ffffffffc02006bc:	00001717          	auipc	a4,0x1
ffffffffc02006c0:	28070713          	addi	a4,a4,640 # ffffffffc020193c <commands+0x1bc>
ffffffffc02006c4:	078a                	slli	a5,a5,0x2
ffffffffc02006c6:	97ba                	add	a5,a5,a4
ffffffffc02006c8:	439c                	lw	a5,0(a5)
ffffffffc02006ca:	97ba                	add	a5,a5,a4
ffffffffc02006cc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006ce:	00001517          	auipc	a0,0x1
ffffffffc02006d2:	30250513          	addi	a0,a0,770 # ffffffffc02019d0 <commands+0x250>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	2d650513          	addi	a0,a0,726 # ffffffffc02019b0 <commands+0x230>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	28a50513          	addi	a0,a0,650 # ffffffffc0201970 <commands+0x1f0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	2fe50513          	addi	a0,a0,766 # ffffffffc02019f0 <commands+0x270>
ffffffffc02006fa:	9bdff06f          	j	ffffffffc02000b6 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006fe:	1141                	addi	sp,sp,-16
ffffffffc0200700:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200702:	d3fff0ef          	jal	ra,ffffffffc0200440 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200706:	00006797          	auipc	a5,0x6
ffffffffc020070a:	d2a78793          	addi	a5,a5,-726 # ffffffffc0206430 <ticks>
ffffffffc020070e:	639c                	ld	a5,0(a5)
ffffffffc0200710:	06400713          	li	a4,100
ffffffffc0200714:	0785                	addi	a5,a5,1
ffffffffc0200716:	02e7f733          	remu	a4,a5,a4
ffffffffc020071a:	00006697          	auipc	a3,0x6
ffffffffc020071e:	d0f6bb23          	sd	a5,-746(a3) # ffffffffc0206430 <ticks>
ffffffffc0200722:	c315                	beqz	a4,ffffffffc0200746 <interrupt_handler+0x9a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200724:	60a2                	ld	ra,8(sp)
ffffffffc0200726:	0141                	addi	sp,sp,16
ffffffffc0200728:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020072a:	00001517          	auipc	a0,0x1
ffffffffc020072e:	2ee50513          	addi	a0,a0,750 # ffffffffc0201a18 <commands+0x298>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	25a50513          	addi	a0,a0,602 # ffffffffc0201990 <commands+0x210>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00001517          	auipc	a0,0x1
ffffffffc0200750:	2bc50513          	addi	a0,a0,700 # ffffffffc0201a08 <commands+0x288>
}
ffffffffc0200754:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200756:	961ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020075a <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc020075a:	11853783          	ld	a5,280(a0)
ffffffffc020075e:	0007c863          	bltz	a5,ffffffffc020076e <trap+0x14>
    switch (tf->cause) {
ffffffffc0200762:	472d                	li	a4,11
ffffffffc0200764:	00f76363          	bltu	a4,a5,ffffffffc020076a <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200768:	8082                	ret
            print_trapframe(tf);
ffffffffc020076a:	ee1ff06f          	j	ffffffffc020064a <print_trapframe>
        interrupt_handler(tf);
ffffffffc020076e:	f3fff06f          	j	ffffffffc02006ac <interrupt_handler>
	...

ffffffffc0200774 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200774:	14011073          	csrw	sscratch,sp
ffffffffc0200778:	712d                	addi	sp,sp,-288
ffffffffc020077a:	e002                	sd	zero,0(sp)
ffffffffc020077c:	e406                	sd	ra,8(sp)
ffffffffc020077e:	ec0e                	sd	gp,24(sp)
ffffffffc0200780:	f012                	sd	tp,32(sp)
ffffffffc0200782:	f416                	sd	t0,40(sp)
ffffffffc0200784:	f81a                	sd	t1,48(sp)
ffffffffc0200786:	fc1e                	sd	t2,56(sp)
ffffffffc0200788:	e0a2                	sd	s0,64(sp)
ffffffffc020078a:	e4a6                	sd	s1,72(sp)
ffffffffc020078c:	e8aa                	sd	a0,80(sp)
ffffffffc020078e:	ecae                	sd	a1,88(sp)
ffffffffc0200790:	f0b2                	sd	a2,96(sp)
ffffffffc0200792:	f4b6                	sd	a3,104(sp)
ffffffffc0200794:	f8ba                	sd	a4,112(sp)
ffffffffc0200796:	fcbe                	sd	a5,120(sp)
ffffffffc0200798:	e142                	sd	a6,128(sp)
ffffffffc020079a:	e546                	sd	a7,136(sp)
ffffffffc020079c:	e94a                	sd	s2,144(sp)
ffffffffc020079e:	ed4e                	sd	s3,152(sp)
ffffffffc02007a0:	f152                	sd	s4,160(sp)
ffffffffc02007a2:	f556                	sd	s5,168(sp)
ffffffffc02007a4:	f95a                	sd	s6,176(sp)
ffffffffc02007a6:	fd5e                	sd	s7,184(sp)
ffffffffc02007a8:	e1e2                	sd	s8,192(sp)
ffffffffc02007aa:	e5e6                	sd	s9,200(sp)
ffffffffc02007ac:	e9ea                	sd	s10,208(sp)
ffffffffc02007ae:	edee                	sd	s11,216(sp)
ffffffffc02007b0:	f1f2                	sd	t3,224(sp)
ffffffffc02007b2:	f5f6                	sd	t4,232(sp)
ffffffffc02007b4:	f9fa                	sd	t5,240(sp)
ffffffffc02007b6:	fdfe                	sd	t6,248(sp)
ffffffffc02007b8:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007bc:	100024f3          	csrr	s1,sstatus
ffffffffc02007c0:	14102973          	csrr	s2,sepc
ffffffffc02007c4:	143029f3          	csrr	s3,stval
ffffffffc02007c8:	14202a73          	csrr	s4,scause
ffffffffc02007cc:	e822                	sd	s0,16(sp)
ffffffffc02007ce:	e226                	sd	s1,256(sp)
ffffffffc02007d0:	e64a                	sd	s2,264(sp)
ffffffffc02007d2:	ea4e                	sd	s3,272(sp)
ffffffffc02007d4:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007d6:	850a                	mv	a0,sp
    jal trap
ffffffffc02007d8:	f83ff0ef          	jal	ra,ffffffffc020075a <trap>

ffffffffc02007dc <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007dc:	6492                	ld	s1,256(sp)
ffffffffc02007de:	6932                	ld	s2,264(sp)
ffffffffc02007e0:	10049073          	csrw	sstatus,s1
ffffffffc02007e4:	14191073          	csrw	sepc,s2
ffffffffc02007e8:	60a2                	ld	ra,8(sp)
ffffffffc02007ea:	61e2                	ld	gp,24(sp)
ffffffffc02007ec:	7202                	ld	tp,32(sp)
ffffffffc02007ee:	72a2                	ld	t0,40(sp)
ffffffffc02007f0:	7342                	ld	t1,48(sp)
ffffffffc02007f2:	73e2                	ld	t2,56(sp)
ffffffffc02007f4:	6406                	ld	s0,64(sp)
ffffffffc02007f6:	64a6                	ld	s1,72(sp)
ffffffffc02007f8:	6546                	ld	a0,80(sp)
ffffffffc02007fa:	65e6                	ld	a1,88(sp)
ffffffffc02007fc:	7606                	ld	a2,96(sp)
ffffffffc02007fe:	76a6                	ld	a3,104(sp)
ffffffffc0200800:	7746                	ld	a4,112(sp)
ffffffffc0200802:	77e6                	ld	a5,120(sp)
ffffffffc0200804:	680a                	ld	a6,128(sp)
ffffffffc0200806:	68aa                	ld	a7,136(sp)
ffffffffc0200808:	694a                	ld	s2,144(sp)
ffffffffc020080a:	69ea                	ld	s3,152(sp)
ffffffffc020080c:	7a0a                	ld	s4,160(sp)
ffffffffc020080e:	7aaa                	ld	s5,168(sp)
ffffffffc0200810:	7b4a                	ld	s6,176(sp)
ffffffffc0200812:	7bea                	ld	s7,184(sp)
ffffffffc0200814:	6c0e                	ld	s8,192(sp)
ffffffffc0200816:	6cae                	ld	s9,200(sp)
ffffffffc0200818:	6d4e                	ld	s10,208(sp)
ffffffffc020081a:	6dee                	ld	s11,216(sp)
ffffffffc020081c:	7e0e                	ld	t3,224(sp)
ffffffffc020081e:	7eae                	ld	t4,232(sp)
ffffffffc0200820:	7f4e                	ld	t5,240(sp)
ffffffffc0200822:	7fee                	ld	t6,248(sp)
ffffffffc0200824:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200826:	10200073          	sret

ffffffffc020082a <buddy_init>:
  //结束dump
  cprintf("--------------------------------\n");
}

static void
buddy_init(void) {}
ffffffffc020082a:	8082                	ret

ffffffffc020082c <buddy_nr_free_pages>:
    buddy2_free(buddy, (int)(base - buddy->base));
}

static size_t
buddy_nr_free_pages(void) {
    return buddy->longest[0];
ffffffffc020082c:	00006797          	auipc	a5,0x6
ffffffffc0200830:	c2478793          	addi	a5,a5,-988 # ffffffffc0206450 <buddy>
ffffffffc0200834:	639c                	ld	a5,0(a5)
ffffffffc0200836:	6b9c                	ld	a5,16(a5)
}
ffffffffc0200838:	0007e503          	lwu	a0,0(a5)
ffffffffc020083c:	8082                	ret

ffffffffc020083e <buddy_init_memmap>:
buddy_init_memmap(struct Page *base, size_t size) {
ffffffffc020083e:	715d                	addi	sp,sp,-80
ffffffffc0200840:	ec56                	sd	s5,24(sp)
    buddy->longest = (unsigned *)((unsigned long)(buddy + sizeof(struct buddy2)));
ffffffffc0200842:	00006a97          	auipc	s5,0x6
ffffffffc0200846:	c0ea8a93          	addi	s5,s5,-1010 # ffffffffc0206450 <buddy>
ffffffffc020084a:	000ab703          	ld	a4,0(s5)
buddy_init_memmap(struct Page *base, size_t size) {
ffffffffc020084e:	e0a2                	sd	s0,64(sp)
ffffffffc0200850:	f84a                	sd	s2,48(sp)
    buddy->longest = (unsigned *)((unsigned long)(buddy + sizeof(struct buddy2)));
ffffffffc0200852:	24070793          	addi	a5,a4,576
    buddy->longest = (unsigned *)((((unsigned long)buddy->longest >> 4) + 1) << 4);
ffffffffc0200856:	9bc1                	andi	a5,a5,-16
buddy_init_memmap(struct Page *base, size_t size) {
ffffffffc0200858:	f44e                	sd	s3,40(sp)
ffffffffc020085a:	f052                	sd	s4,32(sp)
ffffffffc020085c:	e85a                	sd	s6,16(sp)
ffffffffc020085e:	e45e                	sd	s7,8(sp)
ffffffffc0200860:	e486                	sd	ra,72(sp)
ffffffffc0200862:	fc26                	sd	s1,56(sp)
    buddy->size = size;
ffffffffc0200864:	0005869b          	sext.w	a3,a1
    buddy->longest = (unsigned *)((((unsigned long)buddy->longest >> 4) + 1) << 4);
ffffffffc0200868:	07c1                	addi	a5,a5,16
    for(i = 0;i < 2 * size - 1;i++)
ffffffffc020086a:	00159993          	slli	s3,a1,0x1
    buddy->longest = (unsigned *)((((unsigned long)buddy->longest >> 4) + 1) << 4);
ffffffffc020086e:	eb1c                	sd	a5,16(a4)
buddy_init_memmap(struct Page *base, size_t size) {
ffffffffc0200870:	8a2e                	mv	s4,a1
ffffffffc0200872:	8baa                	mv	s7,a0
    node_size = size * 2;
ffffffffc0200874:	0016991b          	slliw	s2,a3,0x1
    buddy->size = size;
ffffffffc0200878:	c714                	sw	a3,8(a4)
    buddy->base = base;
ffffffffc020087a:	e308                	sd	a0,0(a4)
    for(i = 0;i < 2 * size - 1;i++)
ffffffffc020087c:	39fd                	addiw	s3,s3,-1
ffffffffc020087e:	4401                	li	s0,0
ffffffffc0200880:	4781                	li	a5,0
            cprintf("%d\n",node_size);
ffffffffc0200882:	00001b17          	auipc	s6,0x1
ffffffffc0200886:	57eb0b13          	addi	s6,s6,1406 # ffffffffc0201e00 <commands+0x680>
ffffffffc020088a:	a819                	j	ffffffffc02008a0 <buddy_init_memmap+0x62>
        buddy->longest[i] = node_size;
ffffffffc020088c:	000ab703          	ld	a4,0(s5)
ffffffffc0200890:	87a6                	mv	a5,s1
ffffffffc0200892:	6b18                	ld	a4,16(a4)
ffffffffc0200894:	9722                	add	a4,a4,s0
ffffffffc0200896:	01272023          	sw	s2,0(a4)
ffffffffc020089a:	0411                	addi	s0,s0,4
    for(i = 0;i < 2 * size - 1;i++)
ffffffffc020089c:	03348663          	beq	s1,s3,ffffffffc02008c8 <buddy_init_memmap+0x8a>
        if(IS_POWER_OF_2(i+1))
ffffffffc02008a0:	0017849b          	addiw	s1,a5,1
ffffffffc02008a4:	8fe5                	and	a5,a5,s1
ffffffffc02008a6:	f3fd                	bnez	a5,ffffffffc020088c <buddy_init_memmap+0x4e>
            cprintf("%d\n",node_size);
ffffffffc02008a8:	85ca                	mv	a1,s2
ffffffffc02008aa:	855a                	mv	a0,s6
ffffffffc02008ac:	80bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
        buddy->longest[i] = node_size;
ffffffffc02008b0:	000ab703          	ld	a4,0(s5)
            node_size /= 2;
ffffffffc02008b4:	0019591b          	srliw	s2,s2,0x1
        buddy->longest[i] = node_size;
ffffffffc02008b8:	87a6                	mv	a5,s1
ffffffffc02008ba:	6b18                	ld	a4,16(a4)
ffffffffc02008bc:	9722                	add	a4,a4,s0
ffffffffc02008be:	01272023          	sw	s2,0(a4)
ffffffffc02008c2:	0411                	addi	s0,s0,4
    for(i = 0;i < 2 * size - 1;i++)
ffffffffc02008c4:	fd349ee3          	bne	s1,s3,ffffffffc02008a0 <buddy_init_memmap+0x62>
    for (; p != base + size; p ++) {
ffffffffc02008c8:	002a1693          	slli	a3,s4,0x2
ffffffffc02008cc:	96d2                	add	a3,a3,s4
ffffffffc02008ce:	068e                	slli	a3,a3,0x3
ffffffffc02008d0:	96de                	add	a3,a3,s7
ffffffffc02008d2:	02db8363          	beq	s7,a3,ffffffffc02008f8 <buddy_init_memmap+0xba>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02008d6:	008bb783          	ld	a5,8(s7)
        assert(PageReserved(p));
ffffffffc02008da:	8b85                	andi	a5,a5,1
ffffffffc02008dc:	cf95                	beqz	a5,ffffffffc0200918 <buddy_init_memmap+0xda>
ffffffffc02008de:	87de                	mv	a5,s7
ffffffffc02008e0:	a021                	j	ffffffffc02008e8 <buddy_init_memmap+0xaa>
ffffffffc02008e2:	6798                	ld	a4,8(a5)
ffffffffc02008e4:	8b05                	andi	a4,a4,1
ffffffffc02008e6:	cb0d                	beqz	a4,ffffffffc0200918 <buddy_init_memmap+0xda>
        p->flags = 0;
ffffffffc02008e8:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02008ec:	0007a023          	sw	zero,0(a5)
    for (; p != base + size; p ++) {
ffffffffc02008f0:	02878793          	addi	a5,a5,40
ffffffffc02008f4:	fed797e3          	bne	a5,a3,ffffffffc02008e2 <buddy_init_memmap+0xa4>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02008f8:	4789                	li	a5,2
ffffffffc02008fa:	008b8713          	addi	a4,s7,8
ffffffffc02008fe:	40f7302f          	amoor.d	zero,a5,(a4)
}
ffffffffc0200902:	60a6                	ld	ra,72(sp)
ffffffffc0200904:	6406                	ld	s0,64(sp)
ffffffffc0200906:	74e2                	ld	s1,56(sp)
ffffffffc0200908:	7942                	ld	s2,48(sp)
ffffffffc020090a:	79a2                	ld	s3,40(sp)
ffffffffc020090c:	7a02                	ld	s4,32(sp)
ffffffffc020090e:	6ae2                	ld	s5,24(sp)
ffffffffc0200910:	6b42                	ld	s6,16(sp)
ffffffffc0200912:	6ba2                	ld	s7,8(sp)
ffffffffc0200914:	6161                	addi	sp,sp,80
ffffffffc0200916:	8082                	ret
        assert(PageReserved(p));
ffffffffc0200918:	00001697          	auipc	a3,0x1
ffffffffc020091c:	5d868693          	addi	a3,a3,1496 # ffffffffc0201ef0 <commands+0x770>
ffffffffc0200920:	00001617          	auipc	a2,0x1
ffffffffc0200924:	5e060613          	addi	a2,a2,1504 # ffffffffc0201f00 <commands+0x780>
ffffffffc0200928:	04100593          	li	a1,65
ffffffffc020092c:	00001517          	auipc	a0,0x1
ffffffffc0200930:	5ec50513          	addi	a0,a0,1516 # ffffffffc0201f18 <commands+0x798>
ffffffffc0200934:	a79ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200938 <buddy2_alloc>:
    if(self == NULL)
ffffffffc0200938:	c575                	beqz	a0,ffffffffc0200a24 <buddy2_alloc+0xec>
    if(size <= 0)
ffffffffc020093a:	4805                	li	a6,1
ffffffffc020093c:	00b05963          	blez	a1,ffffffffc020094e <buddy2_alloc+0x16>
    else if(!IS_POWER_OF_2(size))
ffffffffc0200940:	fff5879b          	addiw	a5,a1,-1
ffffffffc0200944:	8fed                	and	a5,a5,a1
ffffffffc0200946:	2781                	sext.w	a5,a5
ffffffffc0200948:	0005881b          	sext.w	a6,a1
ffffffffc020094c:	ebd9                	bnez	a5,ffffffffc02009e2 <buddy2_alloc+0xaa>
    if(self->longest[index] < size)
ffffffffc020094e:	6910                	ld	a2,16(a0)
ffffffffc0200950:	421c                	lw	a5,0(a2)
ffffffffc0200952:	0d07e963          	bltu	a5,a6,ffffffffc0200a24 <buddy2_alloc+0xec>
    for(node_size = self->size;node_size != size;node_size /= 2){
ffffffffc0200956:	4514                	lw	a3,8(a0)
ffffffffc0200958:	0b068f63          	beq	a3,a6,ffffffffc0200a16 <buddy2_alloc+0xde>
    unsigned index = 0;
ffffffffc020095c:	4781                	li	a5,0
        if(self->longest[LEFT_LEAF(index)] >= size)
ffffffffc020095e:	0017959b          	slliw	a1,a5,0x1
ffffffffc0200962:	0015879b          	addiw	a5,a1,1
ffffffffc0200966:	02079713          	slli	a4,a5,0x20
ffffffffc020096a:	8379                	srli	a4,a4,0x1e
ffffffffc020096c:	9732                	add	a4,a4,a2
ffffffffc020096e:	4318                	lw	a4,0(a4)
    for(node_size = self->size;node_size != size;node_size /= 2){
ffffffffc0200970:	0016d69b          	srliw	a3,a3,0x1
        if(self->longest[LEFT_LEAF(index)] >= size)
ffffffffc0200974:	01077463          	bleu	a6,a4,ffffffffc020097c <buddy2_alloc+0x44>
            index = RIGHT_LEAF(index);
ffffffffc0200978:	0025879b          	addiw	a5,a1,2
    for(node_size = self->size;node_size != size;node_size /= 2){
ffffffffc020097c:	ff0691e3          	bne	a3,a6,ffffffffc020095e <buddy2_alloc+0x26>
    offset = (index + 1) * node_size - self->size;
ffffffffc0200980:	0017871b          	addiw	a4,a5,1
ffffffffc0200984:	02d706bb          	mulw	a3,a4,a3
    self->longest[index] = 0;
ffffffffc0200988:	02079593          	slli	a1,a5,0x20
ffffffffc020098c:	81f9                	srli	a1,a1,0x1e
ffffffffc020098e:	95b2                	add	a1,a1,a2
ffffffffc0200990:	0005a023          	sw	zero,0(a1)
    offset = (index + 1) * node_size - self->size;
ffffffffc0200994:	4508                	lw	a0,8(a0)
ffffffffc0200996:	40a6853b          	subw	a0,a3,a0
    while(index){
ffffffffc020099a:	e781                	bnez	a5,ffffffffc02009a2 <buddy2_alloc+0x6a>
ffffffffc020099c:	a089                	j	ffffffffc02009de <buddy2_alloc+0xa6>
ffffffffc020099e:	0017871b          	addiw	a4,a5,1
        index = PARENT(index);
ffffffffc02009a2:	0017579b          	srliw	a5,a4,0x1
ffffffffc02009a6:	37fd                	addiw	a5,a5,-1
        self->longest[index] = MAX(self->longest[LEFT_LEAF(index)],self->longest[RIGHT_LEAF(index)]);
ffffffffc02009a8:	0017969b          	slliw	a3,a5,0x1
ffffffffc02009ac:	9b79                	andi	a4,a4,-2
ffffffffc02009ae:	2685                	addiw	a3,a3,1
ffffffffc02009b0:	1682                	slli	a3,a3,0x20
ffffffffc02009b2:	1702                	slli	a4,a4,0x20
ffffffffc02009b4:	9281                	srli	a3,a3,0x20
ffffffffc02009b6:	9301                	srli	a4,a4,0x20
ffffffffc02009b8:	068a                	slli	a3,a3,0x2
ffffffffc02009ba:	070a                	slli	a4,a4,0x2
ffffffffc02009bc:	9732                	add	a4,a4,a2
ffffffffc02009be:	96b2                	add	a3,a3,a2
ffffffffc02009c0:	430c                	lw	a1,0(a4)
ffffffffc02009c2:	4294                	lw	a3,0(a3)
ffffffffc02009c4:	02079713          	slli	a4,a5,0x20
ffffffffc02009c8:	8379                	srli	a4,a4,0x1e
ffffffffc02009ca:	0006889b          	sext.w	a7,a3
ffffffffc02009ce:	0005881b          	sext.w	a6,a1
ffffffffc02009d2:	9732                	add	a4,a4,a2
ffffffffc02009d4:	0108f363          	bleu	a6,a7,ffffffffc02009da <buddy2_alloc+0xa2>
ffffffffc02009d8:	86ae                	mv	a3,a1
ffffffffc02009da:	c314                	sw	a3,0(a4)
    while(index){
ffffffffc02009dc:	f3e9                	bnez	a5,ffffffffc020099e <buddy2_alloc+0x66>
    return offset;
ffffffffc02009de:	2501                	sext.w	a0,a0
ffffffffc02009e0:	8082                	ret
    size |= size >> 1;
ffffffffc02009e2:	0018579b          	srliw	a5,a6,0x1
ffffffffc02009e6:	00f86833          	or	a6,a6,a5
ffffffffc02009ea:	2801                	sext.w	a6,a6
    size |= size >> 2;
ffffffffc02009ec:	0028579b          	srliw	a5,a6,0x2
ffffffffc02009f0:	00f86833          	or	a6,a6,a5
ffffffffc02009f4:	2801                	sext.w	a6,a6
    size |= size >> 4;
ffffffffc02009f6:	0048579b          	srliw	a5,a6,0x4
ffffffffc02009fa:	00f86833          	or	a6,a6,a5
ffffffffc02009fe:	2801                	sext.w	a6,a6
    size |= size >> 8;
ffffffffc0200a00:	0088579b          	srliw	a5,a6,0x8
ffffffffc0200a04:	00f86833          	or	a6,a6,a5
ffffffffc0200a08:	2801                	sext.w	a6,a6
    size |= size >> 16;
ffffffffc0200a0a:	0108579b          	srliw	a5,a6,0x10
ffffffffc0200a0e:	00f86833          	or	a6,a6,a5
    return size+1;    
ffffffffc0200a12:	2805                	addiw	a6,a6,1
ffffffffc0200a14:	bf2d                	j	ffffffffc020094e <buddy2_alloc+0x16>
    self->longest[index] = 0;
ffffffffc0200a16:	00062023          	sw	zero,0(a2)
    offset = (index + 1) * node_size - self->size;
ffffffffc0200a1a:	4508                	lw	a0,8(a0)
ffffffffc0200a1c:	40a8053b          	subw	a0,a6,a0
    return offset;
ffffffffc0200a20:	2501                	sext.w	a0,a0
ffffffffc0200a22:	8082                	ret
        return -1;
ffffffffc0200a24:	557d                	li	a0,-1
}
ffffffffc0200a26:	8082                	ret

ffffffffc0200a28 <buddy_alloc_pages>:
buddy_alloc_pages(size_t n) {
ffffffffc0200a28:	1141                	addi	sp,sp,-16
ffffffffc0200a2a:	e022                	sd	s0,0(sp)
    int offset = buddy2_alloc(buddy, n);
ffffffffc0200a2c:	00006417          	auipc	s0,0x6
ffffffffc0200a30:	a2440413          	addi	s0,s0,-1500 # ffffffffc0206450 <buddy>
ffffffffc0200a34:	0005059b          	sext.w	a1,a0
ffffffffc0200a38:	6008                	ld	a0,0(s0)
buddy_alloc_pages(size_t n) {
ffffffffc0200a3a:	e406                	sd	ra,8(sp)
    int offset = buddy2_alloc(buddy, n);
ffffffffc0200a3c:	efdff0ef          	jal	ra,ffffffffc0200938 <buddy2_alloc>
    struct Page *page = buddy->base + offset;
ffffffffc0200a40:	6018                	ld	a4,0(s0)
ffffffffc0200a42:	00251793          	slli	a5,a0,0x2
ffffffffc0200a46:	953e                	add	a0,a0,a5
ffffffffc0200a48:	631c                	ld	a5,0(a4)
ffffffffc0200a4a:	050e                	slli	a0,a0,0x3
ffffffffc0200a4c:	953e                	add	a0,a0,a5
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200a4e:	00850713          	addi	a4,a0,8
ffffffffc0200a52:	57f5                	li	a5,-3
ffffffffc0200a54:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc0200a58:	60a2                	ld	ra,8(sp)
ffffffffc0200a5a:	6402                	ld	s0,0(sp)
ffffffffc0200a5c:	0141                	addi	sp,sp,16
ffffffffc0200a5e:	8082                	ret

ffffffffc0200a60 <buddy2_free>:
    assert(self && offset >= 0 && offset < self->size);
ffffffffc0200a60:	c145                	beqz	a0,ffffffffc0200b00 <buddy2_free+0xa0>
ffffffffc0200a62:	0805cf63          	bltz	a1,ffffffffc0200b00 <buddy2_free+0xa0>
ffffffffc0200a66:	4518                	lw	a4,8(a0)
ffffffffc0200a68:	2581                	sext.w	a1,a1
ffffffffc0200a6a:	08e5fb63          	bleu	a4,a1,ffffffffc0200b00 <buddy2_free+0xa0>
    index = offset + self->size - 1;
ffffffffc0200a6e:	fff5879b          	addiw	a5,a1,-1
ffffffffc0200a72:	9fb9                	addw	a5,a5,a4
    for(; self->longest[index]; index = PARENT(index)){
ffffffffc0200a74:	6908                	ld	a0,16(a0)
ffffffffc0200a76:	02079713          	slli	a4,a5,0x20
ffffffffc0200a7a:	8379                	srli	a4,a4,0x1e
ffffffffc0200a7c:	972a                	add	a4,a4,a0
ffffffffc0200a7e:	4314                	lw	a3,0(a4)
ffffffffc0200a80:	cea5                	beqz	a3,ffffffffc0200af8 <buddy2_free+0x98>
        node_size *= 2;
ffffffffc0200a82:	4689                	li	a3,2
        if(index == 0)
ffffffffc0200a84:	e789                	bnez	a5,ffffffffc0200a8e <buddy2_free+0x2e>
ffffffffc0200a86:	a8a5                	j	ffffffffc0200afe <buddy2_free+0x9e>
        node_size *= 2;
ffffffffc0200a88:	0016969b          	slliw	a3,a3,0x1
        if(index == 0)
ffffffffc0200a8c:	c3bd                	beqz	a5,ffffffffc0200af2 <buddy2_free+0x92>
    for(; self->longest[index]; index = PARENT(index)){
ffffffffc0200a8e:	2785                	addiw	a5,a5,1
ffffffffc0200a90:	0017d79b          	srliw	a5,a5,0x1
ffffffffc0200a94:	37fd                	addiw	a5,a5,-1
ffffffffc0200a96:	02079713          	slli	a4,a5,0x20
ffffffffc0200a9a:	8379                	srli	a4,a4,0x1e
ffffffffc0200a9c:	972a                	add	a4,a4,a0
ffffffffc0200a9e:	4310                	lw	a2,0(a4)
ffffffffc0200aa0:	f665                	bnez	a2,ffffffffc0200a88 <buddy2_free+0x28>
    self->longest[index] = node_size;
ffffffffc0200aa2:	c314                	sw	a3,0(a4)
    while(index){
ffffffffc0200aa4:	c7b9                	beqz	a5,ffffffffc0200af2 <buddy2_free+0x92>
        index = PARENT(index);
ffffffffc0200aa6:	2785                	addiw	a5,a5,1
ffffffffc0200aa8:	0017d59b          	srliw	a1,a5,0x1
ffffffffc0200aac:	35fd                	addiw	a1,a1,-1
        left_longest = self->longest[LEFT_LEAF(index)];
ffffffffc0200aae:	0015961b          	slliw	a2,a1,0x1
        right_longest = self->longest[RIGHT_LEAF(index)];
ffffffffc0200ab2:	ffe7f713          	andi	a4,a5,-2
        left_longest = self->longest[LEFT_LEAF(index)];
ffffffffc0200ab6:	2605                	addiw	a2,a2,1
ffffffffc0200ab8:	1602                	slli	a2,a2,0x20
        right_longest = self->longest[RIGHT_LEAF(index)];
ffffffffc0200aba:	1702                	slli	a4,a4,0x20
        left_longest = self->longest[LEFT_LEAF(index)];
ffffffffc0200abc:	9201                	srli	a2,a2,0x20
        right_longest = self->longest[RIGHT_LEAF(index)];
ffffffffc0200abe:	9301                	srli	a4,a4,0x20
        left_longest = self->longest[LEFT_LEAF(index)];
ffffffffc0200ac0:	060a                	slli	a2,a2,0x2
        right_longest = self->longest[RIGHT_LEAF(index)];
ffffffffc0200ac2:	070a                	slli	a4,a4,0x2
ffffffffc0200ac4:	972a                	add	a4,a4,a0
        left_longest = self->longest[LEFT_LEAF(index)];
ffffffffc0200ac6:	962a                	add	a2,a2,a0
        right_longest = self->longest[RIGHT_LEAF(index)];
ffffffffc0200ac8:	00072803          	lw	a6,0(a4)
        left_longest = self->longest[LEFT_LEAF(index)];
ffffffffc0200acc:	4210                	lw	a2,0(a2)
ffffffffc0200ace:	02059713          	slli	a4,a1,0x20
ffffffffc0200ad2:	8379                	srli	a4,a4,0x1e
        node_size *= 2;
ffffffffc0200ad4:	0016969b          	slliw	a3,a3,0x1
        if(left_longest + right_longest == node_size)
ffffffffc0200ad8:	0106033b          	addw	t1,a2,a6
        index = PARENT(index);
ffffffffc0200adc:	0005879b          	sext.w	a5,a1
        if(left_longest + right_longest == node_size)
ffffffffc0200ae0:	972a                	add	a4,a4,a0
ffffffffc0200ae2:	00d30963          	beq	t1,a3,ffffffffc0200af4 <buddy2_free+0x94>
            self->longest[index] = MAX(left_longest,right_longest);
ffffffffc0200ae6:	85b2                	mv	a1,a2
ffffffffc0200ae8:	01067363          	bleu	a6,a2,ffffffffc0200aee <buddy2_free+0x8e>
ffffffffc0200aec:	85c2                	mv	a1,a6
ffffffffc0200aee:	c30c                	sw	a1,0(a4)
    while(index){
ffffffffc0200af0:	fbdd                	bnez	a5,ffffffffc0200aa6 <buddy2_free+0x46>
ffffffffc0200af2:	8082                	ret
            self->longest[index] = node_size;
ffffffffc0200af4:	c314                	sw	a3,0(a4)
ffffffffc0200af6:	b77d                	j	ffffffffc0200aa4 <buddy2_free+0x44>
    node_size = 1;
ffffffffc0200af8:	4685                	li	a3,1
    self->longest[index] = node_size;
ffffffffc0200afa:	c314                	sw	a3,0(a4)
ffffffffc0200afc:	b765                	j	ffffffffc0200aa4 <buddy2_free+0x44>
ffffffffc0200afe:	8082                	ret
void buddy2_free(struct buddy2* self, int offset){
ffffffffc0200b00:	1141                	addi	sp,sp,-16
    assert(self && offset >= 0 && offset < self->size);
ffffffffc0200b02:	00001697          	auipc	a3,0x1
ffffffffc0200b06:	30668693          	addi	a3,a3,774 # ffffffffc0201e08 <commands+0x688>
ffffffffc0200b0a:	00001617          	auipc	a2,0x1
ffffffffc0200b0e:	3f660613          	addi	a2,a2,1014 # ffffffffc0201f00 <commands+0x780>
ffffffffc0200b12:	07800593          	li	a1,120
ffffffffc0200b16:	00001517          	auipc	a0,0x1
ffffffffc0200b1a:	40250513          	addi	a0,a0,1026 # ffffffffc0201f18 <commands+0x798>
void buddy2_free(struct buddy2* self, int offset){
ffffffffc0200b1e:	e406                	sd	ra,8(sp)
    assert(self && offset >= 0 && offset < self->size);
ffffffffc0200b20:	88dff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200b24 <buddy_free_pages>:
buddy_free_pages(struct Page *base, size_t n) {
ffffffffc0200b24:	1141                	addi	sp,sp,-16
ffffffffc0200b26:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200b28:	c9c9                	beqz	a1,ffffffffc0200bba <buddy_free_pages+0x96>
    for (; p != base + n; p ++) {
ffffffffc0200b2a:	00259793          	slli	a5,a1,0x2
ffffffffc0200b2e:	00b786b3          	add	a3,a5,a1
ffffffffc0200b32:	068e                	slli	a3,a3,0x3
ffffffffc0200b34:	96aa                	add	a3,a3,a0
ffffffffc0200b36:	862a                	mv	a2,a0
ffffffffc0200b38:	02d50963          	beq	a0,a3,ffffffffc0200b6a <buddy_free_pages+0x46>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b3c:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200b3e:	8b85                	andi	a5,a5,1
ffffffffc0200b40:	efa9                	bnez	a5,ffffffffc0200b9a <buddy_free_pages+0x76>
ffffffffc0200b42:	651c                	ld	a5,8(a0)
ffffffffc0200b44:	8385                	srli	a5,a5,0x1
ffffffffc0200b46:	8b85                	andi	a5,a5,1
ffffffffc0200b48:	eba9                	bnez	a5,ffffffffc0200b9a <buddy_free_pages+0x76>
ffffffffc0200b4a:	87aa                	mv	a5,a0
ffffffffc0200b4c:	a039                	j	ffffffffc0200b5a <buddy_free_pages+0x36>
ffffffffc0200b4e:	6798                	ld	a4,8(a5)
ffffffffc0200b50:	8b05                	andi	a4,a4,1
ffffffffc0200b52:	e721                	bnez	a4,ffffffffc0200b9a <buddy_free_pages+0x76>
ffffffffc0200b54:	6798                	ld	a4,8(a5)
ffffffffc0200b56:	8b09                	andi	a4,a4,2
ffffffffc0200b58:	e329                	bnez	a4,ffffffffc0200b9a <buddy_free_pages+0x76>
        p->flags = 0;
ffffffffc0200b5a:	0007b423          	sd	zero,8(a5)
ffffffffc0200b5e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200b62:	02878793          	addi	a5,a5,40
ffffffffc0200b66:	fed794e3          	bne	a5,a3,ffffffffc0200b4e <buddy_free_pages+0x2a>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200b6a:	4789                	li	a5,2
ffffffffc0200b6c:	00860713          	addi	a4,a2,8
ffffffffc0200b70:	40f7302f          	amoor.d	zero,a5,(a4)
    buddy2_free(buddy, (int)(base - buddy->base));
ffffffffc0200b74:	00006797          	auipc	a5,0x6
ffffffffc0200b78:	8dc78793          	addi	a5,a5,-1828 # ffffffffc0206450 <buddy>
ffffffffc0200b7c:	6388                	ld	a0,0(a5)
ffffffffc0200b7e:	00001797          	auipc	a5,0x1
ffffffffc0200b82:	33a78793          	addi	a5,a5,826 # ffffffffc0201eb8 <commands+0x738>
}
ffffffffc0200b86:	60a2                	ld	ra,8(sp)
    buddy2_free(buddy, (int)(base - buddy->base));
ffffffffc0200b88:	610c                	ld	a1,0(a0)
ffffffffc0200b8a:	8e0d                	sub	a2,a2,a1
ffffffffc0200b8c:	638c                	ld	a1,0(a5)
ffffffffc0200b8e:	860d                	srai	a2,a2,0x3
ffffffffc0200b90:	02b605bb          	mulw	a1,a2,a1
}
ffffffffc0200b94:	0141                	addi	sp,sp,16
    buddy2_free(buddy, (int)(base - buddy->base));
ffffffffc0200b96:	ecbff06f          	j	ffffffffc0200a60 <buddy2_free>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200b9a:	00001697          	auipc	a3,0x1
ffffffffc0200b9e:	32668693          	addi	a3,a3,806 # ffffffffc0201ec0 <commands+0x740>
ffffffffc0200ba2:	00001617          	auipc	a2,0x1
ffffffffc0200ba6:	35e60613          	addi	a2,a2,862 # ffffffffc0201f00 <commands+0x780>
ffffffffc0200baa:	0d000593          	li	a1,208
ffffffffc0200bae:	00001517          	auipc	a0,0x1
ffffffffc0200bb2:	36a50513          	addi	a0,a0,874 # ffffffffc0201f18 <commands+0x798>
ffffffffc0200bb6:	ff6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200bba:	00001697          	auipc	a3,0x1
ffffffffc0200bbe:	32e68693          	addi	a3,a3,814 # ffffffffc0201ee8 <commands+0x768>
ffffffffc0200bc2:	00001617          	auipc	a2,0x1
ffffffffc0200bc6:	33e60613          	addi	a2,a2,830 # ffffffffc0201f00 <commands+0x780>
ffffffffc0200bca:	0cd00593          	li	a1,205
ffffffffc0200bce:	00001517          	auipc	a0,0x1
ffffffffc0200bd2:	34a50513          	addi	a0,a0,842 # ffffffffc0201f18 <commands+0x798>
ffffffffc0200bd6:	fd6ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200bda <buddy2_dump>:
void buddy2_dump(struct buddy2* self) {
ffffffffc0200bda:	7179                	addi	sp,sp,-48
ffffffffc0200bdc:	e44e                	sd	s3,8(sp)
ffffffffc0200bde:	e052                	sd	s4,0(sp)
ffffffffc0200be0:	89aa                	mv	s3,a0
  node_size = self->size * 2;
ffffffffc0200be2:	00852a03          	lw	s4,8(a0)
  cprintf("--------------------------------\n");
ffffffffc0200be6:	00001517          	auipc	a0,0x1
ffffffffc0200bea:	1ca50513          	addi	a0,a0,458 # ffffffffc0201db0 <commands+0x630>
void buddy2_dump(struct buddy2* self) {
ffffffffc0200bee:	f022                	sd	s0,32(sp)
ffffffffc0200bf0:	ec26                	sd	s1,24(sp)
ffffffffc0200bf2:	e84a                	sd	s2,16(sp)
ffffffffc0200bf4:	f406                	sd	ra,40(sp)
  cprintf("--------------------------------\n");
ffffffffc0200bf6:	cc0ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200bfa:	0089a803          	lw	a6,8(s3)
  for (i = 0; i < 2 * self->size - 1; ++i) {
ffffffffc0200bfe:	4401                	li	s0,0
ffffffffc0200c00:	0004059b          	sext.w	a1,s0
ffffffffc0200c04:	0018189b          	slliw	a7,a6,0x1
ffffffffc0200c08:	0015861b          	addiw	a2,a1,1
    if ( IS_POWER_OF_2(i+1) )
ffffffffc0200c0c:	00c5f733          	and	a4,a1,a2
  for (i = 0; i < 2 * self->size - 1; ++i) {
ffffffffc0200c10:	fff8879b          	addiw	a5,a7,-1
  node_size = self->size * 2;
ffffffffc0200c14:	001a1a1b          	slliw	s4,s4,0x1
        cprintf("[%d, %d) size = %d\n", offset, offset + node_size, node_size);
ffffffffc0200c18:	00001917          	auipc	s2,0x1
ffffffffc0200c1c:	1d890913          	addi	s2,s2,472 # ffffffffc0201df0 <commands+0x670>
        cprintf("[%d, %d) size = 1\n", i - self->size + 1, i - self->size + 2);
ffffffffc0200c20:	00001497          	auipc	s1,0x1
ffffffffc0200c24:	1b848493          	addi	s1,s1,440 # ffffffffc0201dd8 <commands+0x658>
    if ( self->longest[i] == 0 ) {
ffffffffc0200c28:	00241693          	slli	a3,s0,0x2
    if ( IS_POWER_OF_2(i+1) )
ffffffffc0200c2c:	2701                	sext.w	a4,a4
      if (i >=  self->size - 1) {
ffffffffc0200c2e:	fff8051b          	addiw	a0,a6,-1
  for (i = 0; i < 2 * self->size - 1; ++i) {
ffffffffc0200c32:	04f5f563          	bleu	a5,a1,ffffffffc0200c7c <buddy2_dump+0xa2>
    if ( IS_POWER_OF_2(i+1) )
ffffffffc0200c36:	e319                	bnez	a4,ffffffffc0200c3c <buddy2_dump+0x62>
      node_size /= 2;
ffffffffc0200c38:	001a5a1b          	srliw	s4,s4,0x1
    if ( self->longest[i] == 0 ) {
ffffffffc0200c3c:	0109b703          	ld	a4,16(s3)
ffffffffc0200c40:	96ba                	add	a3,a3,a4
ffffffffc0200c42:	429c                	lw	a5,0(a3)
ffffffffc0200c44:	ef81                	bnez	a5,ffffffffc0200c5c <buddy2_dump+0x82>
      else if (self->longest[LEFT_LEAF(i)] && self->longest[RIGHT_LEAF(i)]) {
ffffffffc0200c46:	0015979b          	slliw	a5,a1,0x1
ffffffffc0200c4a:	0785                	addi	a5,a5,1
ffffffffc0200c4c:	078a                	slli	a5,a5,0x2
ffffffffc0200c4e:	97ba                	add	a5,a5,a4
      if (i >=  self->size - 1) {
ffffffffc0200c50:	04a5f363          	bleu	a0,a1,ffffffffc0200c96 <buddy2_dump+0xbc>
      else if (self->longest[LEFT_LEAF(i)] && self->longest[RIGHT_LEAF(i)]) {
ffffffffc0200c54:	4398                	lw	a4,0(a5)
ffffffffc0200c56:	c319                	beqz	a4,ffffffffc0200c5c <buddy2_dump+0x82>
ffffffffc0200c58:	43dc                	lw	a5,4(a5)
ffffffffc0200c5a:	efa1                	bnez	a5,ffffffffc0200cb2 <buddy2_dump+0xd8>
ffffffffc0200c5c:	0405                	addi	s0,s0,1
      if (i >=  self->size - 1) {
ffffffffc0200c5e:	0004059b          	sext.w	a1,s0
ffffffffc0200c62:	0015861b          	addiw	a2,a1,1
    if ( IS_POWER_OF_2(i+1) )
ffffffffc0200c66:	00c5f733          	and	a4,a1,a2
  for (i = 0; i < 2 * self->size - 1; ++i) {
ffffffffc0200c6a:	fff8879b          	addiw	a5,a7,-1
    if ( self->longest[i] == 0 ) {
ffffffffc0200c6e:	00241693          	slli	a3,s0,0x2
    if ( IS_POWER_OF_2(i+1) )
ffffffffc0200c72:	2701                	sext.w	a4,a4
      if (i >=  self->size - 1) {
ffffffffc0200c74:	fff8051b          	addiw	a0,a6,-1
  for (i = 0; i < 2 * self->size - 1; ++i) {
ffffffffc0200c78:	faf5efe3          	bltu	a1,a5,ffffffffc0200c36 <buddy2_dump+0x5c>
}
ffffffffc0200c7c:	7402                	ld	s0,32(sp)
ffffffffc0200c7e:	70a2                	ld	ra,40(sp)
ffffffffc0200c80:	64e2                	ld	s1,24(sp)
ffffffffc0200c82:	6942                	ld	s2,16(sp)
ffffffffc0200c84:	69a2                	ld	s3,8(sp)
ffffffffc0200c86:	6a02                	ld	s4,0(sp)
  cprintf("--------------------------------\n");
ffffffffc0200c88:	00001517          	auipc	a0,0x1
ffffffffc0200c8c:	12850513          	addi	a0,a0,296 # ffffffffc0201db0 <commands+0x630>
}
ffffffffc0200c90:	6145                	addi	sp,sp,48
  cprintf("--------------------------------\n");
ffffffffc0200c92:	c24ff06f          	j	ffffffffc02000b6 <cprintf>
        cprintf("[%d, %d) size = 1\n", i - self->size + 1, i - self->size + 2);
ffffffffc0200c96:	410585bb          	subw	a1,a1,a6
ffffffffc0200c9a:	0025861b          	addiw	a2,a1,2
ffffffffc0200c9e:	8526                	mv	a0,s1
ffffffffc0200ca0:	2585                	addiw	a1,a1,1
ffffffffc0200ca2:	c14ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200ca6:	0089a803          	lw	a6,8(s3)
ffffffffc0200caa:	0405                	addi	s0,s0,1
ffffffffc0200cac:	0018189b          	slliw	a7,a6,0x1
ffffffffc0200cb0:	b77d                	j	ffffffffc0200c5e <buddy2_dump+0x84>
        offset = (i+1) * node_size - self->size;
ffffffffc0200cb2:	02ca063b          	mulw	a2,s4,a2
        cprintf("[%d, %d) size = %d\n", offset, offset + node_size, node_size);
ffffffffc0200cb6:	86d2                	mv	a3,s4
ffffffffc0200cb8:	854a                	mv	a0,s2
ffffffffc0200cba:	0405                	addi	s0,s0,1
        offset = (i+1) * node_size - self->size;
ffffffffc0200cbc:	410605bb          	subw	a1,a2,a6
        cprintf("[%d, %d) size = %d\n", offset, offset + node_size, node_size);
ffffffffc0200cc0:	0145863b          	addw	a2,a1,s4
ffffffffc0200cc4:	bf2ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200cc8:	0089a803          	lw	a6,8(s3)
ffffffffc0200ccc:	0018189b          	slliw	a7,a6,0x1
ffffffffc0200cd0:	b779                	j	ffffffffc0200c5e <buddy2_dump+0x84>

ffffffffc0200cd2 <buddy_check>:

static void
buddy_check(void) {
ffffffffc0200cd2:	7179                	addi	sp,sp,-48
    // free_pages(p1, 255);
    // buddy2_dump(buddy);
    // free_pages(p2, 513);
    // buddy2_dump(buddy);

    assert((p0 = alloc_pages(70)) != NULL);
ffffffffc0200cd4:	04600513          	li	a0,70
buddy_check(void) {
ffffffffc0200cd8:	f406                	sd	ra,40(sp)
ffffffffc0200cda:	f022                	sd	s0,32(sp)
ffffffffc0200cdc:	ec26                	sd	s1,24(sp)
ffffffffc0200cde:	e84a                	sd	s2,16(sp)
ffffffffc0200ce0:	e44e                	sd	s3,8(sp)
    assert((p0 = alloc_pages(70)) != NULL);
ffffffffc0200ce2:	114000ef          	jal	ra,ffffffffc0200df6 <alloc_pages>
ffffffffc0200ce6:	c941                	beqz	a0,ffffffffc0200d76 <buddy_check+0xa4>
    buddy2_dump(buddy);
ffffffffc0200ce8:	00005417          	auipc	s0,0x5
ffffffffc0200cec:	76840413          	addi	s0,s0,1896 # ffffffffc0206450 <buddy>
ffffffffc0200cf0:	84aa                	mv	s1,a0
ffffffffc0200cf2:	6008                	ld	a0,0(s0)
ffffffffc0200cf4:	ee7ff0ef          	jal	ra,ffffffffc0200bda <buddy2_dump>
    assert((p1 = alloc_pages(35)) != NULL);
ffffffffc0200cf8:	02300513          	li	a0,35
ffffffffc0200cfc:	0fa000ef          	jal	ra,ffffffffc0200df6 <alloc_pages>
ffffffffc0200d00:	89aa                	mv	s3,a0
ffffffffc0200d02:	0c050a63          	beqz	a0,ffffffffc0200dd6 <buddy_check+0x104>
    buddy2_dump(buddy);
ffffffffc0200d06:	6008                	ld	a0,0(s0)
ffffffffc0200d08:	ed3ff0ef          	jal	ra,ffffffffc0200bda <buddy2_dump>
    assert((p2 = alloc_pages(80)) != NULL);
ffffffffc0200d0c:	05000513          	li	a0,80
ffffffffc0200d10:	0e6000ef          	jal	ra,ffffffffc0200df6 <alloc_pages>
ffffffffc0200d14:	892a                	mv	s2,a0
ffffffffc0200d16:	c145                	beqz	a0,ffffffffc0200db6 <buddy_check+0xe4>
    buddy2_dump(buddy);
ffffffffc0200d18:	6008                	ld	a0,0(s0)
ffffffffc0200d1a:	ec1ff0ef          	jal	ra,ffffffffc0200bda <buddy2_dump>

    free_pages(p0, 70);
ffffffffc0200d1e:	04600593          	li	a1,70
ffffffffc0200d22:	8526                	mv	a0,s1
ffffffffc0200d24:	116000ef          	jal	ra,ffffffffc0200e3a <free_pages>
    buddy2_dump(buddy);
ffffffffc0200d28:	6008                	ld	a0,0(s0)
ffffffffc0200d2a:	eb1ff0ef          	jal	ra,ffffffffc0200bda <buddy2_dump>
    assert((p3 = alloc_pages(60)) != NULL);
ffffffffc0200d2e:	03c00513          	li	a0,60
ffffffffc0200d32:	0c4000ef          	jal	ra,ffffffffc0200df6 <alloc_pages>
ffffffffc0200d36:	84aa                	mv	s1,a0
ffffffffc0200d38:	cd39                	beqz	a0,ffffffffc0200d96 <buddy_check+0xc4>
    buddy2_dump(buddy);
ffffffffc0200d3a:	6008                	ld	a0,0(s0)
ffffffffc0200d3c:	e9fff0ef          	jal	ra,ffffffffc0200bda <buddy2_dump>
    free_pages(p1, 35);
ffffffffc0200d40:	02300593          	li	a1,35
ffffffffc0200d44:	854e                	mv	a0,s3
ffffffffc0200d46:	0f4000ef          	jal	ra,ffffffffc0200e3a <free_pages>
    buddy2_dump(buddy);
ffffffffc0200d4a:	6008                	ld	a0,0(s0)
ffffffffc0200d4c:	e8fff0ef          	jal	ra,ffffffffc0200bda <buddy2_dump>
    free_pages(p3, 60);
ffffffffc0200d50:	03c00593          	li	a1,60
ffffffffc0200d54:	8526                	mv	a0,s1
ffffffffc0200d56:	0e4000ef          	jal	ra,ffffffffc0200e3a <free_pages>
    buddy2_dump(buddy);
ffffffffc0200d5a:	6008                	ld	a0,0(s0)
ffffffffc0200d5c:	e7fff0ef          	jal	ra,ffffffffc0200bda <buddy2_dump>
    free_pages(p2, 80);

}
ffffffffc0200d60:	7402                	ld	s0,32(sp)
ffffffffc0200d62:	70a2                	ld	ra,40(sp)
ffffffffc0200d64:	64e2                	ld	s1,24(sp)
ffffffffc0200d66:	69a2                	ld	s3,8(sp)
    free_pages(p2, 80);
ffffffffc0200d68:	854a                	mv	a0,s2
}
ffffffffc0200d6a:	6942                	ld	s2,16(sp)
    free_pages(p2, 80);
ffffffffc0200d6c:	05000593          	li	a1,80
}
ffffffffc0200d70:	6145                	addi	sp,sp,48
    free_pages(p2, 80);
ffffffffc0200d72:	0c80006f          	j	ffffffffc0200e3a <free_pages>
    assert((p0 = alloc_pages(70)) != NULL);
ffffffffc0200d76:	00001697          	auipc	a3,0x1
ffffffffc0200d7a:	0c268693          	addi	a3,a3,194 # ffffffffc0201e38 <commands+0x6b8>
ffffffffc0200d7e:	00001617          	auipc	a2,0x1
ffffffffc0200d82:	18260613          	addi	a2,a2,386 # ffffffffc0201f00 <commands+0x780>
ffffffffc0200d86:	0f700593          	li	a1,247
ffffffffc0200d8a:	00001517          	auipc	a0,0x1
ffffffffc0200d8e:	18e50513          	addi	a0,a0,398 # ffffffffc0201f18 <commands+0x798>
ffffffffc0200d92:	e1aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p3 = alloc_pages(60)) != NULL);
ffffffffc0200d96:	00001697          	auipc	a3,0x1
ffffffffc0200d9a:	10268693          	addi	a3,a3,258 # ffffffffc0201e98 <commands+0x718>
ffffffffc0200d9e:	00001617          	auipc	a2,0x1
ffffffffc0200da2:	16260613          	addi	a2,a2,354 # ffffffffc0201f00 <commands+0x780>
ffffffffc0200da6:	10000593          	li	a1,256
ffffffffc0200daa:	00001517          	auipc	a0,0x1
ffffffffc0200dae:	16e50513          	addi	a0,a0,366 # ffffffffc0201f18 <commands+0x798>
ffffffffc0200db2:	dfaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_pages(80)) != NULL);
ffffffffc0200db6:	00001697          	auipc	a3,0x1
ffffffffc0200dba:	0c268693          	addi	a3,a3,194 # ffffffffc0201e78 <commands+0x6f8>
ffffffffc0200dbe:	00001617          	auipc	a2,0x1
ffffffffc0200dc2:	14260613          	addi	a2,a2,322 # ffffffffc0201f00 <commands+0x780>
ffffffffc0200dc6:	0fb00593          	li	a1,251
ffffffffc0200dca:	00001517          	auipc	a0,0x1
ffffffffc0200dce:	14e50513          	addi	a0,a0,334 # ffffffffc0201f18 <commands+0x798>
ffffffffc0200dd2:	ddaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(35)) != NULL);
ffffffffc0200dd6:	00001697          	auipc	a3,0x1
ffffffffc0200dda:	08268693          	addi	a3,a3,130 # ffffffffc0201e58 <commands+0x6d8>
ffffffffc0200dde:	00001617          	auipc	a2,0x1
ffffffffc0200de2:	12260613          	addi	a2,a2,290 # ffffffffc0201f00 <commands+0x780>
ffffffffc0200de6:	0f900593          	li	a1,249
ffffffffc0200dea:	00001517          	auipc	a0,0x1
ffffffffc0200dee:	12e50513          	addi	a0,a0,302 # ffffffffc0201f18 <commands+0x798>
ffffffffc0200df2:	dbaff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200df6 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200df6:	100027f3          	csrr	a5,sstatus
ffffffffc0200dfa:	8b89                	andi	a5,a5,2
ffffffffc0200dfc:	eb89                	bnez	a5,ffffffffc0200e0e <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200dfe:	00005797          	auipc	a5,0x5
ffffffffc0200e02:	64278793          	addi	a5,a5,1602 # ffffffffc0206440 <pmm_manager>
ffffffffc0200e06:	639c                	ld	a5,0(a5)
ffffffffc0200e08:	0187b303          	ld	t1,24(a5)
ffffffffc0200e0c:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc0200e0e:	1141                	addi	sp,sp,-16
ffffffffc0200e10:	e406                	sd	ra,8(sp)
ffffffffc0200e12:	e022                	sd	s0,0(sp)
ffffffffc0200e14:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0200e16:	e4eff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200e1a:	00005797          	auipc	a5,0x5
ffffffffc0200e1e:	62678793          	addi	a5,a5,1574 # ffffffffc0206440 <pmm_manager>
ffffffffc0200e22:	639c                	ld	a5,0(a5)
ffffffffc0200e24:	8522                	mv	a0,s0
ffffffffc0200e26:	6f9c                	ld	a5,24(a5)
ffffffffc0200e28:	9782                	jalr	a5
ffffffffc0200e2a:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200e2c:	e32ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200e30:	8522                	mv	a0,s0
ffffffffc0200e32:	60a2                	ld	ra,8(sp)
ffffffffc0200e34:	6402                	ld	s0,0(sp)
ffffffffc0200e36:	0141                	addi	sp,sp,16
ffffffffc0200e38:	8082                	ret

ffffffffc0200e3a <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200e3a:	100027f3          	csrr	a5,sstatus
ffffffffc0200e3e:	8b89                	andi	a5,a5,2
ffffffffc0200e40:	eb89                	bnez	a5,ffffffffc0200e52 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200e42:	00005797          	auipc	a5,0x5
ffffffffc0200e46:	5fe78793          	addi	a5,a5,1534 # ffffffffc0206440 <pmm_manager>
ffffffffc0200e4a:	639c                	ld	a5,0(a5)
ffffffffc0200e4c:	0207b303          	ld	t1,32(a5)
ffffffffc0200e50:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200e52:	1101                	addi	sp,sp,-32
ffffffffc0200e54:	ec06                	sd	ra,24(sp)
ffffffffc0200e56:	e822                	sd	s0,16(sp)
ffffffffc0200e58:	e426                	sd	s1,8(sp)
ffffffffc0200e5a:	842a                	mv	s0,a0
ffffffffc0200e5c:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200e5e:	e06ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200e62:	00005797          	auipc	a5,0x5
ffffffffc0200e66:	5de78793          	addi	a5,a5,1502 # ffffffffc0206440 <pmm_manager>
ffffffffc0200e6a:	639c                	ld	a5,0(a5)
ffffffffc0200e6c:	85a6                	mv	a1,s1
ffffffffc0200e6e:	8522                	mv	a0,s0
ffffffffc0200e70:	739c                	ld	a5,32(a5)
ffffffffc0200e72:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200e74:	6442                	ld	s0,16(sp)
ffffffffc0200e76:	60e2                	ld	ra,24(sp)
ffffffffc0200e78:	64a2                	ld	s1,8(sp)
ffffffffc0200e7a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200e7c:	de2ff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc0200e80 <pmm_init>:
        init_memmap(pa2page(mem_begin), total_pages);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200e80:	1101                	addi	sp,sp,-32
ffffffffc0200e82:	e04a                	sd	s2,0(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200e84:	00001917          	auipc	s2,0x1
ffffffffc0200e88:	0ac90913          	addi	s2,s2,172 # ffffffffc0201f30 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200e8c:	00093583          	ld	a1,0(s2)
ffffffffc0200e90:	00001517          	auipc	a0,0x1
ffffffffc0200e94:	0f050513          	addi	a0,a0,240 # ffffffffc0201f80 <buddy_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc0200e98:	ec06                	sd	ra,24(sp)
ffffffffc0200e9a:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200e9c:	00005797          	auipc	a5,0x5
ffffffffc0200ea0:	5b27b223          	sd	s2,1444(a5) # ffffffffc0206440 <pmm_manager>
void pmm_init(void) {
ffffffffc0200ea4:	e426                	sd	s1,8(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200ea6:	00005417          	auipc	s0,0x5
ffffffffc0200eaa:	59a40413          	addi	s0,s0,1434 # ffffffffc0206440 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200eae:	a08ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc0200eb2:	601c                	ld	a5,0(s0)
ffffffffc0200eb4:	679c                	ld	a5,8(a5)
ffffffffc0200eb6:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200eb8:	57f5                	li	a5,-3
ffffffffc0200eba:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200ebc:	00001517          	auipc	a0,0x1
ffffffffc0200ec0:	0dc50513          	addi	a0,a0,220 # ffffffffc0201f98 <buddy_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200ec4:	00005717          	auipc	a4,0x5
ffffffffc0200ec8:	58f73223          	sd	a5,1412(a4) # ffffffffc0206448 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0200ecc:	9eaff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200ed0:	46c5                	li	a3,17
ffffffffc0200ed2:	06ee                	slli	a3,a3,0x1b
ffffffffc0200ed4:	40100613          	li	a2,1025
ffffffffc0200ed8:	16fd                	addi	a3,a3,-1
ffffffffc0200eda:	07e005b7          	lui	a1,0x7e00
ffffffffc0200ede:	0656                	slli	a2,a2,0x15
ffffffffc0200ee0:	00001517          	auipc	a0,0x1
ffffffffc0200ee4:	0d050513          	addi	a0,a0,208 # ffffffffc0201fb0 <buddy_pmm_manager+0x80>
ffffffffc0200ee8:	9ceff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200eec:	777d                	lui	a4,0xfffff
ffffffffc0200eee:	00006797          	auipc	a5,0x6
ffffffffc0200ef2:	57178793          	addi	a5,a5,1393 # ffffffffc020745f <end+0xfff>
ffffffffc0200ef6:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200ef8:	00088737          	lui	a4,0x88
ffffffffc0200efc:	00005697          	auipc	a3,0x5
ffffffffc0200f00:	50e6be23          	sd	a4,1308(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200f04:	00005717          	auipc	a4,0x5
ffffffffc0200f08:	54f73a23          	sd	a5,1364(a4) # ffffffffc0206458 <pages>
ffffffffc0200f0c:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200f0e:	4701                	li	a4,0
ffffffffc0200f10:	00005897          	auipc	a7,0x5
ffffffffc0200f14:	50888893          	addi	a7,a7,1288 # ffffffffc0206418 <npage>
ffffffffc0200f18:	00005597          	auipc	a1,0x5
ffffffffc0200f1c:	54058593          	addi	a1,a1,1344 # ffffffffc0206458 <pages>
ffffffffc0200f20:	4805                	li	a6,1
ffffffffc0200f22:	fff80537          	lui	a0,0xfff80
ffffffffc0200f26:	a011                	j	ffffffffc0200f2a <pmm_init+0xaa>
ffffffffc0200f28:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc0200f2a:	97b6                	add	a5,a5,a3
ffffffffc0200f2c:	07a1                	addi	a5,a5,8
ffffffffc0200f2e:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200f32:	0008b603          	ld	a2,0(a7)
ffffffffc0200f36:	0705                	addi	a4,a4,1
ffffffffc0200f38:	02868693          	addi	a3,a3,40
ffffffffc0200f3c:	00a607b3          	add	a5,a2,a0
ffffffffc0200f40:	fef764e3          	bltu	a4,a5,ffffffffc0200f28 <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200f44:	6198                	ld	a4,0(a1)
ffffffffc0200f46:	00261793          	slli	a5,a2,0x2
ffffffffc0200f4a:	97b2                	add	a5,a5,a2
ffffffffc0200f4c:	078e                	slli	a5,a5,0x3
ffffffffc0200f4e:	97ba                	add	a5,a5,a4
ffffffffc0200f50:	fec006b7          	lui	a3,0xfec00
ffffffffc0200f54:	96be                	add	a3,a3,a5
ffffffffc0200f56:	c0200537          	lui	a0,0xc0200
ffffffffc0200f5a:	10a6ec63          	bltu	a3,a0,ffffffffc0201072 <pmm_init+0x1f2>
    if(pmm_manager == &buddy_pmm_manager){
ffffffffc0200f5e:	00043803          	ld	a6,0(s0)
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200f62:	00005497          	auipc	s1,0x5
ffffffffc0200f66:	4e648493          	addi	s1,s1,1254 # ffffffffc0206448 <va_pa_offset>
ffffffffc0200f6a:	0004b883          	ld	a7,0(s1)
    if(pmm_manager == &buddy_pmm_manager){
ffffffffc0200f6e:	09280b63          	beq	a6,s2,ffffffffc0201004 <pmm_init+0x184>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200f72:	6785                	lui	a5,0x1
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200f74:	411686b3          	sub	a3,a3,a7
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200f78:	17fd                	addi	a5,a5,-1
ffffffffc0200f7a:	75fd                	lui	a1,0xfffff
ffffffffc0200f7c:	97b6                	add	a5,a5,a3
ffffffffc0200f7e:	8fed                	and	a5,a5,a1
    (mem_end - mem_begin) / PGSIZE;
ffffffffc0200f80:	45c5                	li	a1,17
ffffffffc0200f82:	05ee                	slli	a1,a1,0x1b
ffffffffc0200f84:	8d9d                	sub	a1,a1,a5
ffffffffc0200f86:	81b1                	srli	a1,a1,0xc
    int total_pages = (pmm_manager == &buddy_pmm_manager) ? 
ffffffffc0200f88:	2581                	sext.w	a1,a1
    if (freemem < mem_end) {
ffffffffc0200f8a:	4545                	li	a0,17
ffffffffc0200f8c:	056e                	slli	a0,a0,0x1b
ffffffffc0200f8e:	04a6ea63          	bltu	a3,a0,ffffffffc0200fe2 <pmm_init+0x162>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200f92:	03083783          	ld	a5,48(a6)
ffffffffc0200f96:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200f98:	00001517          	auipc	a0,0x1
ffffffffc0200f9c:	0b050513          	addi	a0,a0,176 # ffffffffc0202048 <buddy_pmm_manager+0x118>
ffffffffc0200fa0:	916ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200fa4:	00004697          	auipc	a3,0x4
ffffffffc0200fa8:	05c68693          	addi	a3,a3,92 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200fac:	00005797          	auipc	a5,0x5
ffffffffc0200fb0:	46d7ba23          	sd	a3,1140(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200fb4:	c02007b7          	lui	a5,0xc0200
ffffffffc0200fb8:	0cf6e963          	bltu	a3,a5,ffffffffc020108a <pmm_init+0x20a>
ffffffffc0200fbc:	609c                	ld	a5,0(s1)
}
ffffffffc0200fbe:	6442                	ld	s0,16(sp)
ffffffffc0200fc0:	60e2                	ld	ra,24(sp)
ffffffffc0200fc2:	64a2                	ld	s1,8(sp)
ffffffffc0200fc4:	6902                	ld	s2,0(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200fc6:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc0200fc8:	8e9d                	sub	a3,a3,a5
ffffffffc0200fca:	00005797          	auipc	a5,0x5
ffffffffc0200fce:	46d7b723          	sd	a3,1134(a5) # ffffffffc0206438 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200fd2:	00001517          	auipc	a0,0x1
ffffffffc0200fd6:	09650513          	addi	a0,a0,150 # ffffffffc0202068 <buddy_pmm_manager+0x138>
ffffffffc0200fda:	8636                	mv	a2,a3
}
ffffffffc0200fdc:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200fde:	8d8ff06f          	j	ffffffffc02000b6 <cprintf>
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200fe2:	83b1                	srli	a5,a5,0xc
ffffffffc0200fe4:	0ac7ff63          	bleu	a2,a5,ffffffffc02010a2 <pmm_init+0x222>
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200fe8:	fff80537          	lui	a0,0xfff80
ffffffffc0200fec:	97aa                	add	a5,a5,a0
ffffffffc0200fee:	00279513          	slli	a0,a5,0x2
ffffffffc0200ff2:	953e                	add	a0,a0,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0200ff4:	01083783          	ld	a5,16(a6)
ffffffffc0200ff8:	050e                	slli	a0,a0,0x3
ffffffffc0200ffa:	953a                	add	a0,a0,a4
ffffffffc0200ffc:	9782                	jalr	a5
ffffffffc0200ffe:	00043803          	ld	a6,0(s0)
ffffffffc0201002:	bf41                	j	ffffffffc0200f92 <pmm_init+0x112>
        ROUNDUP((void *)((uintptr_t)pages + sizeof(struct Page) * (npage - nbase)), PGSIZE);
ffffffffc0201004:	fec016b7          	lui	a3,0xfec01
ffffffffc0201008:	16fd                	addi	a3,a3,-1
        freemem = PADDR((uintptr_t)buddy +
ffffffffc020100a:	ffc00337          	lui	t1,0xffc00
        ROUNDUP((void *)((uintptr_t)pages + sizeof(struct Page) * (npage - nbase)), PGSIZE);
ffffffffc020100e:	97b6                	add	a5,a5,a3
ffffffffc0201010:	7e7d                	lui	t3,0xfffff
        freemem = PADDR((uintptr_t)buddy +
ffffffffc0201012:	00361593          	slli	a1,a2,0x3
ffffffffc0201016:	0321                	addi	t1,t1,8
ffffffffc0201018:	01c7f6b3          	and	a3,a5,t3
ffffffffc020101c:	959a                	add	a1,a1,t1
        buddy = (struct buddy2 *)
ffffffffc020101e:	00005797          	auipc	a5,0x5
ffffffffc0201022:	42d7b923          	sd	a3,1074(a5) # ffffffffc0206450 <buddy>
        freemem = PADDR((uintptr_t)buddy +
ffffffffc0201026:	96ae                	add	a3,a3,a1
ffffffffc0201028:	08a6e963          	bltu	a3,a0,ffffffffc02010ba <pmm_init+0x23a>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020102c:	6785                	lui	a5,0x1
        freemem = PADDR((uintptr_t)buddy +
ffffffffc020102e:	411686b3          	sub	a3,a3,a7
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201032:	17fd                	addi	a5,a5,-1
ffffffffc0201034:	97b6                	add	a5,a5,a3
    fixsize((unsigned)((mem_end - mem_begin) / PGSIZE)) / 2 :
ffffffffc0201036:	45c5                	li	a1,17
ffffffffc0201038:	01c7f7b3          	and	a5,a5,t3
ffffffffc020103c:	05ee                	slli	a1,a1,0x1b
ffffffffc020103e:	8d9d                	sub	a1,a1,a5
ffffffffc0201040:	81b1                	srli	a1,a1,0xc
ffffffffc0201042:	2581                	sext.w	a1,a1
    size |= size >> 1;
ffffffffc0201044:	0015d51b          	srliw	a0,a1,0x1
ffffffffc0201048:	8dc9                	or	a1,a1,a0
ffffffffc020104a:	2581                	sext.w	a1,a1
    size |= size >> 2;
ffffffffc020104c:	0025d51b          	srliw	a0,a1,0x2
ffffffffc0201050:	8dc9                	or	a1,a1,a0
ffffffffc0201052:	2581                	sext.w	a1,a1
    size |= size >> 4;
ffffffffc0201054:	0045d51b          	srliw	a0,a1,0x4
ffffffffc0201058:	8dc9                	or	a1,a1,a0
ffffffffc020105a:	2581                	sext.w	a1,a1
    size |= size >> 8;
ffffffffc020105c:	0085d51b          	srliw	a0,a1,0x8
ffffffffc0201060:	8dc9                	or	a1,a1,a0
ffffffffc0201062:	2581                	sext.w	a1,a1
    size |= size >> 16;
ffffffffc0201064:	0105d51b          	srliw	a0,a1,0x10
ffffffffc0201068:	8dc9                	or	a1,a1,a0
    return size+1;    
ffffffffc020106a:	2585                	addiw	a1,a1,1
    int total_pages = (pmm_manager == &buddy_pmm_manager) ? 
ffffffffc020106c:	0015d59b          	srliw	a1,a1,0x1
ffffffffc0201070:	bf29                	j	ffffffffc0200f8a <pmm_init+0x10a>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201072:	00001617          	auipc	a2,0x1
ffffffffc0201076:	f6e60613          	addi	a2,a2,-146 # ffffffffc0201fe0 <buddy_pmm_manager+0xb0>
ffffffffc020107a:	07d00593          	li	a1,125
ffffffffc020107e:	00001517          	auipc	a0,0x1
ffffffffc0201082:	f8a50513          	addi	a0,a0,-118 # ffffffffc0202008 <buddy_pmm_manager+0xd8>
ffffffffc0201086:	b26ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020108a:	00001617          	auipc	a2,0x1
ffffffffc020108e:	f5660613          	addi	a2,a2,-170 # ffffffffc0201fe0 <buddy_pmm_manager+0xb0>
ffffffffc0201092:	0ac00593          	li	a1,172
ffffffffc0201096:	00001517          	auipc	a0,0x1
ffffffffc020109a:	f7250513          	addi	a0,a0,-142 # ffffffffc0202008 <buddy_pmm_manager+0xd8>
ffffffffc020109e:	b0eff0ef          	jal	ra,ffffffffc02003ac <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02010a2:	00001617          	auipc	a2,0x1
ffffffffc02010a6:	f7660613          	addi	a2,a2,-138 # ffffffffc0202018 <buddy_pmm_manager+0xe8>
ffffffffc02010aa:	06c00593          	li	a1,108
ffffffffc02010ae:	00001517          	auipc	a0,0x1
ffffffffc02010b2:	f8a50513          	addi	a0,a0,-118 # ffffffffc0202038 <buddy_pmm_manager+0x108>
ffffffffc02010b6:	af6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
        freemem = PADDR((uintptr_t)buddy +
ffffffffc02010ba:	00001617          	auipc	a2,0x1
ffffffffc02010be:	f2660613          	addi	a2,a2,-218 # ffffffffc0201fe0 <buddy_pmm_manager+0xb0>
ffffffffc02010c2:	08800593          	li	a1,136
ffffffffc02010c6:	00001517          	auipc	a0,0x1
ffffffffc02010ca:	f4250513          	addi	a0,a0,-190 # ffffffffc0202008 <buddy_pmm_manager+0xd8>
ffffffffc02010ce:	adeff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02010d2 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02010d2:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02010d6:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02010d8:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02010dc:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02010de:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02010e2:	f022                	sd	s0,32(sp)
ffffffffc02010e4:	ec26                	sd	s1,24(sp)
ffffffffc02010e6:	e84a                	sd	s2,16(sp)
ffffffffc02010e8:	f406                	sd	ra,40(sp)
ffffffffc02010ea:	e44e                	sd	s3,8(sp)
ffffffffc02010ec:	84aa                	mv	s1,a0
ffffffffc02010ee:	892e                	mv	s2,a1
ffffffffc02010f0:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02010f4:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc02010f6:	03067e63          	bleu	a6,a2,ffffffffc0201132 <printnum+0x60>
ffffffffc02010fa:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02010fc:	00805763          	blez	s0,ffffffffc020110a <printnum+0x38>
ffffffffc0201100:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201102:	85ca                	mv	a1,s2
ffffffffc0201104:	854e                	mv	a0,s3
ffffffffc0201106:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201108:	fc65                	bnez	s0,ffffffffc0201100 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020110a:	1a02                	slli	s4,s4,0x20
ffffffffc020110c:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201110:	00001797          	auipc	a5,0x1
ffffffffc0201114:	12878793          	addi	a5,a5,296 # ffffffffc0202238 <error_string+0x38>
ffffffffc0201118:	9a3e                	add	s4,s4,a5
}
ffffffffc020111a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020111c:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201120:	70a2                	ld	ra,40(sp)
ffffffffc0201122:	69a2                	ld	s3,8(sp)
ffffffffc0201124:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201126:	85ca                	mv	a1,s2
ffffffffc0201128:	8326                	mv	t1,s1
}
ffffffffc020112a:	6942                	ld	s2,16(sp)
ffffffffc020112c:	64e2                	ld	s1,24(sp)
ffffffffc020112e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201130:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201132:	03065633          	divu	a2,a2,a6
ffffffffc0201136:	8722                	mv	a4,s0
ffffffffc0201138:	f9bff0ef          	jal	ra,ffffffffc02010d2 <printnum>
ffffffffc020113c:	b7f9                	j	ffffffffc020110a <printnum+0x38>

ffffffffc020113e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020113e:	7119                	addi	sp,sp,-128
ffffffffc0201140:	f4a6                	sd	s1,104(sp)
ffffffffc0201142:	f0ca                	sd	s2,96(sp)
ffffffffc0201144:	e8d2                	sd	s4,80(sp)
ffffffffc0201146:	e4d6                	sd	s5,72(sp)
ffffffffc0201148:	e0da                	sd	s6,64(sp)
ffffffffc020114a:	fc5e                	sd	s7,56(sp)
ffffffffc020114c:	f862                	sd	s8,48(sp)
ffffffffc020114e:	f06a                	sd	s10,32(sp)
ffffffffc0201150:	fc86                	sd	ra,120(sp)
ffffffffc0201152:	f8a2                	sd	s0,112(sp)
ffffffffc0201154:	ecce                	sd	s3,88(sp)
ffffffffc0201156:	f466                	sd	s9,40(sp)
ffffffffc0201158:	ec6e                	sd	s11,24(sp)
ffffffffc020115a:	892a                	mv	s2,a0
ffffffffc020115c:	84ae                	mv	s1,a1
ffffffffc020115e:	8d32                	mv	s10,a2
ffffffffc0201160:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201162:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201164:	00001a17          	auipc	s4,0x1
ffffffffc0201168:	f44a0a13          	addi	s4,s4,-188 # ffffffffc02020a8 <buddy_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020116c:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201170:	00001c17          	auipc	s8,0x1
ffffffffc0201174:	090c0c13          	addi	s8,s8,144 # ffffffffc0202200 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201178:	000d4503          	lbu	a0,0(s10)
ffffffffc020117c:	02500793          	li	a5,37
ffffffffc0201180:	001d0413          	addi	s0,s10,1
ffffffffc0201184:	00f50e63          	beq	a0,a5,ffffffffc02011a0 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0201188:	c521                	beqz	a0,ffffffffc02011d0 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020118a:	02500993          	li	s3,37
ffffffffc020118e:	a011                	j	ffffffffc0201192 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0201190:	c121                	beqz	a0,ffffffffc02011d0 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0201192:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201194:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201196:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201198:	fff44503          	lbu	a0,-1(s0)
ffffffffc020119c:	ff351ae3          	bne	a0,s3,ffffffffc0201190 <vprintfmt+0x52>
ffffffffc02011a0:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02011a4:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02011a8:	4981                	li	s3,0
ffffffffc02011aa:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02011ac:	5cfd                	li	s9,-1
ffffffffc02011ae:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011b0:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc02011b4:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011b6:	fdd6069b          	addiw	a3,a2,-35
ffffffffc02011ba:	0ff6f693          	andi	a3,a3,255
ffffffffc02011be:	00140d13          	addi	s10,s0,1
ffffffffc02011c2:	20d5e563          	bltu	a1,a3,ffffffffc02013cc <vprintfmt+0x28e>
ffffffffc02011c6:	068a                	slli	a3,a3,0x2
ffffffffc02011c8:	96d2                	add	a3,a3,s4
ffffffffc02011ca:	4294                	lw	a3,0(a3)
ffffffffc02011cc:	96d2                	add	a3,a3,s4
ffffffffc02011ce:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02011d0:	70e6                	ld	ra,120(sp)
ffffffffc02011d2:	7446                	ld	s0,112(sp)
ffffffffc02011d4:	74a6                	ld	s1,104(sp)
ffffffffc02011d6:	7906                	ld	s2,96(sp)
ffffffffc02011d8:	69e6                	ld	s3,88(sp)
ffffffffc02011da:	6a46                	ld	s4,80(sp)
ffffffffc02011dc:	6aa6                	ld	s5,72(sp)
ffffffffc02011de:	6b06                	ld	s6,64(sp)
ffffffffc02011e0:	7be2                	ld	s7,56(sp)
ffffffffc02011e2:	7c42                	ld	s8,48(sp)
ffffffffc02011e4:	7ca2                	ld	s9,40(sp)
ffffffffc02011e6:	7d02                	ld	s10,32(sp)
ffffffffc02011e8:	6de2                	ld	s11,24(sp)
ffffffffc02011ea:	6109                	addi	sp,sp,128
ffffffffc02011ec:	8082                	ret
    if (lflag >= 2) {
ffffffffc02011ee:	4705                	li	a4,1
ffffffffc02011f0:	008a8593          	addi	a1,s5,8
ffffffffc02011f4:	01074463          	blt	a4,a6,ffffffffc02011fc <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc02011f8:	26080363          	beqz	a6,ffffffffc020145e <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc02011fc:	000ab603          	ld	a2,0(s5)
ffffffffc0201200:	46c1                	li	a3,16
ffffffffc0201202:	8aae                	mv	s5,a1
ffffffffc0201204:	a06d                	j	ffffffffc02012ae <vprintfmt+0x170>
            goto reswitch;
ffffffffc0201206:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020120a:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020120c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020120e:	b765                	j	ffffffffc02011b6 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0201210:	000aa503          	lw	a0,0(s5)
ffffffffc0201214:	85a6                	mv	a1,s1
ffffffffc0201216:	0aa1                	addi	s5,s5,8
ffffffffc0201218:	9902                	jalr	s2
            break;
ffffffffc020121a:	bfb9                	j	ffffffffc0201178 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020121c:	4705                	li	a4,1
ffffffffc020121e:	008a8993          	addi	s3,s5,8
ffffffffc0201222:	01074463          	blt	a4,a6,ffffffffc020122a <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0201226:	22080463          	beqz	a6,ffffffffc020144e <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc020122a:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc020122e:	24044463          	bltz	s0,ffffffffc0201476 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0201232:	8622                	mv	a2,s0
ffffffffc0201234:	8ace                	mv	s5,s3
ffffffffc0201236:	46a9                	li	a3,10
ffffffffc0201238:	a89d                	j	ffffffffc02012ae <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc020123a:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020123e:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201240:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0201242:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201246:	8fb5                	xor	a5,a5,a3
ffffffffc0201248:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020124c:	1ad74363          	blt	a4,a3,ffffffffc02013f2 <vprintfmt+0x2b4>
ffffffffc0201250:	00369793          	slli	a5,a3,0x3
ffffffffc0201254:	97e2                	add	a5,a5,s8
ffffffffc0201256:	639c                	ld	a5,0(a5)
ffffffffc0201258:	18078d63          	beqz	a5,ffffffffc02013f2 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc020125c:	86be                	mv	a3,a5
ffffffffc020125e:	00001617          	auipc	a2,0x1
ffffffffc0201262:	08a60613          	addi	a2,a2,138 # ffffffffc02022e8 <error_string+0xe8>
ffffffffc0201266:	85a6                	mv	a1,s1
ffffffffc0201268:	854a                	mv	a0,s2
ffffffffc020126a:	240000ef          	jal	ra,ffffffffc02014aa <printfmt>
ffffffffc020126e:	b729                	j	ffffffffc0201178 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0201270:	00144603          	lbu	a2,1(s0)
ffffffffc0201274:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201276:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201278:	bf3d                	j	ffffffffc02011b6 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc020127a:	4705                	li	a4,1
ffffffffc020127c:	008a8593          	addi	a1,s5,8
ffffffffc0201280:	01074463          	blt	a4,a6,ffffffffc0201288 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0201284:	1e080263          	beqz	a6,ffffffffc0201468 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0201288:	000ab603          	ld	a2,0(s5)
ffffffffc020128c:	46a1                	li	a3,8
ffffffffc020128e:	8aae                	mv	s5,a1
ffffffffc0201290:	a839                	j	ffffffffc02012ae <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0201292:	03000513          	li	a0,48
ffffffffc0201296:	85a6                	mv	a1,s1
ffffffffc0201298:	e03e                	sd	a5,0(sp)
ffffffffc020129a:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020129c:	85a6                	mv	a1,s1
ffffffffc020129e:	07800513          	li	a0,120
ffffffffc02012a2:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02012a4:	0aa1                	addi	s5,s5,8
ffffffffc02012a6:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02012aa:	6782                	ld	a5,0(sp)
ffffffffc02012ac:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02012ae:	876e                	mv	a4,s11
ffffffffc02012b0:	85a6                	mv	a1,s1
ffffffffc02012b2:	854a                	mv	a0,s2
ffffffffc02012b4:	e1fff0ef          	jal	ra,ffffffffc02010d2 <printnum>
            break;
ffffffffc02012b8:	b5c1                	j	ffffffffc0201178 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02012ba:	000ab603          	ld	a2,0(s5)
ffffffffc02012be:	0aa1                	addi	s5,s5,8
ffffffffc02012c0:	1c060663          	beqz	a2,ffffffffc020148c <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc02012c4:	00160413          	addi	s0,a2,1
ffffffffc02012c8:	17b05c63          	blez	s11,ffffffffc0201440 <vprintfmt+0x302>
ffffffffc02012cc:	02d00593          	li	a1,45
ffffffffc02012d0:	14b79263          	bne	a5,a1,ffffffffc0201414 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02012d4:	00064783          	lbu	a5,0(a2)
ffffffffc02012d8:	0007851b          	sext.w	a0,a5
ffffffffc02012dc:	c905                	beqz	a0,ffffffffc020130c <vprintfmt+0x1ce>
ffffffffc02012de:	000cc563          	bltz	s9,ffffffffc02012e8 <vprintfmt+0x1aa>
ffffffffc02012e2:	3cfd                	addiw	s9,s9,-1
ffffffffc02012e4:	036c8263          	beq	s9,s6,ffffffffc0201308 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc02012e8:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02012ea:	18098463          	beqz	s3,ffffffffc0201472 <vprintfmt+0x334>
ffffffffc02012ee:	3781                	addiw	a5,a5,-32
ffffffffc02012f0:	18fbf163          	bleu	a5,s7,ffffffffc0201472 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc02012f4:	03f00513          	li	a0,63
ffffffffc02012f8:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02012fa:	0405                	addi	s0,s0,1
ffffffffc02012fc:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201300:	3dfd                	addiw	s11,s11,-1
ffffffffc0201302:	0007851b          	sext.w	a0,a5
ffffffffc0201306:	fd61                	bnez	a0,ffffffffc02012de <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0201308:	e7b058e3          	blez	s11,ffffffffc0201178 <vprintfmt+0x3a>
ffffffffc020130c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020130e:	85a6                	mv	a1,s1
ffffffffc0201310:	02000513          	li	a0,32
ffffffffc0201314:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201316:	e60d81e3          	beqz	s11,ffffffffc0201178 <vprintfmt+0x3a>
ffffffffc020131a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020131c:	85a6                	mv	a1,s1
ffffffffc020131e:	02000513          	li	a0,32
ffffffffc0201322:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201324:	fe0d94e3          	bnez	s11,ffffffffc020130c <vprintfmt+0x1ce>
ffffffffc0201328:	bd81                	j	ffffffffc0201178 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020132a:	4705                	li	a4,1
ffffffffc020132c:	008a8593          	addi	a1,s5,8
ffffffffc0201330:	01074463          	blt	a4,a6,ffffffffc0201338 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0201334:	12080063          	beqz	a6,ffffffffc0201454 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0201338:	000ab603          	ld	a2,0(s5)
ffffffffc020133c:	46a9                	li	a3,10
ffffffffc020133e:	8aae                	mv	s5,a1
ffffffffc0201340:	b7bd                	j	ffffffffc02012ae <vprintfmt+0x170>
ffffffffc0201342:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0201346:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020134a:	846a                	mv	s0,s10
ffffffffc020134c:	b5ad                	j	ffffffffc02011b6 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc020134e:	85a6                	mv	a1,s1
ffffffffc0201350:	02500513          	li	a0,37
ffffffffc0201354:	9902                	jalr	s2
            break;
ffffffffc0201356:	b50d                	j	ffffffffc0201178 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0201358:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc020135c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201360:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201362:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0201364:	e40dd9e3          	bgez	s11,ffffffffc02011b6 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0201368:	8de6                	mv	s11,s9
ffffffffc020136a:	5cfd                	li	s9,-1
ffffffffc020136c:	b5a9                	j	ffffffffc02011b6 <vprintfmt+0x78>
            goto reswitch;
ffffffffc020136e:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0201372:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201376:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201378:	bd3d                	j	ffffffffc02011b6 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc020137a:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc020137e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201382:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201384:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201388:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020138c:	fcd56ce3          	bltu	a0,a3,ffffffffc0201364 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0201390:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201392:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0201396:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020139a:	0196873b          	addw	a4,a3,s9
ffffffffc020139e:	0017171b          	slliw	a4,a4,0x1
ffffffffc02013a2:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc02013a6:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02013aa:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02013ae:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02013b2:	fcd57fe3          	bleu	a3,a0,ffffffffc0201390 <vprintfmt+0x252>
ffffffffc02013b6:	b77d                	j	ffffffffc0201364 <vprintfmt+0x226>
            if (width < 0)
ffffffffc02013b8:	fffdc693          	not	a3,s11
ffffffffc02013bc:	96fd                	srai	a3,a3,0x3f
ffffffffc02013be:	00ddfdb3          	and	s11,s11,a3
ffffffffc02013c2:	00144603          	lbu	a2,1(s0)
ffffffffc02013c6:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013c8:	846a                	mv	s0,s10
ffffffffc02013ca:	b3f5                	j	ffffffffc02011b6 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc02013cc:	85a6                	mv	a1,s1
ffffffffc02013ce:	02500513          	li	a0,37
ffffffffc02013d2:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02013d4:	fff44703          	lbu	a4,-1(s0)
ffffffffc02013d8:	02500793          	li	a5,37
ffffffffc02013dc:	8d22                	mv	s10,s0
ffffffffc02013de:	d8f70de3          	beq	a4,a5,ffffffffc0201178 <vprintfmt+0x3a>
ffffffffc02013e2:	02500713          	li	a4,37
ffffffffc02013e6:	1d7d                	addi	s10,s10,-1
ffffffffc02013e8:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02013ec:	fee79de3          	bne	a5,a4,ffffffffc02013e6 <vprintfmt+0x2a8>
ffffffffc02013f0:	b361                	j	ffffffffc0201178 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02013f2:	00001617          	auipc	a2,0x1
ffffffffc02013f6:	ee660613          	addi	a2,a2,-282 # ffffffffc02022d8 <error_string+0xd8>
ffffffffc02013fa:	85a6                	mv	a1,s1
ffffffffc02013fc:	854a                	mv	a0,s2
ffffffffc02013fe:	0ac000ef          	jal	ra,ffffffffc02014aa <printfmt>
ffffffffc0201402:	bb9d                	j	ffffffffc0201178 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201404:	00001617          	auipc	a2,0x1
ffffffffc0201408:	ecc60613          	addi	a2,a2,-308 # ffffffffc02022d0 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc020140c:	00001417          	auipc	s0,0x1
ffffffffc0201410:	ec540413          	addi	s0,s0,-315 # ffffffffc02022d1 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201414:	8532                	mv	a0,a2
ffffffffc0201416:	85e6                	mv	a1,s9
ffffffffc0201418:	e032                	sd	a2,0(sp)
ffffffffc020141a:	e43e                	sd	a5,8(sp)
ffffffffc020141c:	1c2000ef          	jal	ra,ffffffffc02015de <strnlen>
ffffffffc0201420:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201424:	6602                	ld	a2,0(sp)
ffffffffc0201426:	01b05d63          	blez	s11,ffffffffc0201440 <vprintfmt+0x302>
ffffffffc020142a:	67a2                	ld	a5,8(sp)
ffffffffc020142c:	2781                	sext.w	a5,a5
ffffffffc020142e:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0201430:	6522                	ld	a0,8(sp)
ffffffffc0201432:	85a6                	mv	a1,s1
ffffffffc0201434:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201436:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201438:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020143a:	6602                	ld	a2,0(sp)
ffffffffc020143c:	fe0d9ae3          	bnez	s11,ffffffffc0201430 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201440:	00064783          	lbu	a5,0(a2)
ffffffffc0201444:	0007851b          	sext.w	a0,a5
ffffffffc0201448:	e8051be3          	bnez	a0,ffffffffc02012de <vprintfmt+0x1a0>
ffffffffc020144c:	b335                	j	ffffffffc0201178 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc020144e:	000aa403          	lw	s0,0(s5)
ffffffffc0201452:	bbf1                	j	ffffffffc020122e <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0201454:	000ae603          	lwu	a2,0(s5)
ffffffffc0201458:	46a9                	li	a3,10
ffffffffc020145a:	8aae                	mv	s5,a1
ffffffffc020145c:	bd89                	j	ffffffffc02012ae <vprintfmt+0x170>
ffffffffc020145e:	000ae603          	lwu	a2,0(s5)
ffffffffc0201462:	46c1                	li	a3,16
ffffffffc0201464:	8aae                	mv	s5,a1
ffffffffc0201466:	b5a1                	j	ffffffffc02012ae <vprintfmt+0x170>
ffffffffc0201468:	000ae603          	lwu	a2,0(s5)
ffffffffc020146c:	46a1                	li	a3,8
ffffffffc020146e:	8aae                	mv	s5,a1
ffffffffc0201470:	bd3d                	j	ffffffffc02012ae <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0201472:	9902                	jalr	s2
ffffffffc0201474:	b559                	j	ffffffffc02012fa <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0201476:	85a6                	mv	a1,s1
ffffffffc0201478:	02d00513          	li	a0,45
ffffffffc020147c:	e03e                	sd	a5,0(sp)
ffffffffc020147e:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201480:	8ace                	mv	s5,s3
ffffffffc0201482:	40800633          	neg	a2,s0
ffffffffc0201486:	46a9                	li	a3,10
ffffffffc0201488:	6782                	ld	a5,0(sp)
ffffffffc020148a:	b515                	j	ffffffffc02012ae <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc020148c:	01b05663          	blez	s11,ffffffffc0201498 <vprintfmt+0x35a>
ffffffffc0201490:	02d00693          	li	a3,45
ffffffffc0201494:	f6d798e3          	bne	a5,a3,ffffffffc0201404 <vprintfmt+0x2c6>
ffffffffc0201498:	00001417          	auipc	s0,0x1
ffffffffc020149c:	e3940413          	addi	s0,s0,-455 # ffffffffc02022d1 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02014a0:	02800513          	li	a0,40
ffffffffc02014a4:	02800793          	li	a5,40
ffffffffc02014a8:	bd1d                	j	ffffffffc02012de <vprintfmt+0x1a0>

ffffffffc02014aa <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02014aa:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02014ac:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02014b0:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02014b2:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02014b4:	ec06                	sd	ra,24(sp)
ffffffffc02014b6:	f83a                	sd	a4,48(sp)
ffffffffc02014b8:	fc3e                	sd	a5,56(sp)
ffffffffc02014ba:	e0c2                	sd	a6,64(sp)
ffffffffc02014bc:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02014be:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02014c0:	c7fff0ef          	jal	ra,ffffffffc020113e <vprintfmt>
}
ffffffffc02014c4:	60e2                	ld	ra,24(sp)
ffffffffc02014c6:	6161                	addi	sp,sp,80
ffffffffc02014c8:	8082                	ret

ffffffffc02014ca <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02014ca:	715d                	addi	sp,sp,-80
ffffffffc02014cc:	e486                	sd	ra,72(sp)
ffffffffc02014ce:	e0a2                	sd	s0,64(sp)
ffffffffc02014d0:	fc26                	sd	s1,56(sp)
ffffffffc02014d2:	f84a                	sd	s2,48(sp)
ffffffffc02014d4:	f44e                	sd	s3,40(sp)
ffffffffc02014d6:	f052                	sd	s4,32(sp)
ffffffffc02014d8:	ec56                	sd	s5,24(sp)
ffffffffc02014da:	e85a                	sd	s6,16(sp)
ffffffffc02014dc:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02014de:	c901                	beqz	a0,ffffffffc02014ee <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02014e0:	85aa                	mv	a1,a0
ffffffffc02014e2:	00001517          	auipc	a0,0x1
ffffffffc02014e6:	e0650513          	addi	a0,a0,-506 # ffffffffc02022e8 <error_string+0xe8>
ffffffffc02014ea:	bcdfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc02014ee:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02014f0:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02014f2:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02014f4:	4aa9                	li	s5,10
ffffffffc02014f6:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02014f8:	00005b97          	auipc	s7,0x5
ffffffffc02014fc:	b18b8b93          	addi	s7,s7,-1256 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201500:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201504:	c2bfe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201508:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020150a:	00054b63          	bltz	a0,ffffffffc0201520 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020150e:	00a95b63          	ble	a0,s2,ffffffffc0201524 <readline+0x5a>
ffffffffc0201512:	029a5463          	ble	s1,s4,ffffffffc020153a <readline+0x70>
        c = getchar();
ffffffffc0201516:	c19fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc020151a:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020151c:	fe0559e3          	bgez	a0,ffffffffc020150e <readline+0x44>
            return NULL;
ffffffffc0201520:	4501                	li	a0,0
ffffffffc0201522:	a099                	j	ffffffffc0201568 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0201524:	03341463          	bne	s0,s3,ffffffffc020154c <readline+0x82>
ffffffffc0201528:	e8b9                	bnez	s1,ffffffffc020157e <readline+0xb4>
        c = getchar();
ffffffffc020152a:	c05fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc020152e:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201530:	fe0548e3          	bltz	a0,ffffffffc0201520 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201534:	fea958e3          	ble	a0,s2,ffffffffc0201524 <readline+0x5a>
ffffffffc0201538:	4481                	li	s1,0
            cputchar(c);
ffffffffc020153a:	8522                	mv	a0,s0
ffffffffc020153c:	baffe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc0201540:	009b87b3          	add	a5,s7,s1
ffffffffc0201544:	00878023          	sb	s0,0(a5)
ffffffffc0201548:	2485                	addiw	s1,s1,1
ffffffffc020154a:	bf6d                	j	ffffffffc0201504 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc020154c:	01540463          	beq	s0,s5,ffffffffc0201554 <readline+0x8a>
ffffffffc0201550:	fb641ae3          	bne	s0,s6,ffffffffc0201504 <readline+0x3a>
            cputchar(c);
ffffffffc0201554:	8522                	mv	a0,s0
ffffffffc0201556:	b95fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc020155a:	00005517          	auipc	a0,0x5
ffffffffc020155e:	ab650513          	addi	a0,a0,-1354 # ffffffffc0206010 <edata>
ffffffffc0201562:	94aa                	add	s1,s1,a0
ffffffffc0201564:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201568:	60a6                	ld	ra,72(sp)
ffffffffc020156a:	6406                	ld	s0,64(sp)
ffffffffc020156c:	74e2                	ld	s1,56(sp)
ffffffffc020156e:	7942                	ld	s2,48(sp)
ffffffffc0201570:	79a2                	ld	s3,40(sp)
ffffffffc0201572:	7a02                	ld	s4,32(sp)
ffffffffc0201574:	6ae2                	ld	s5,24(sp)
ffffffffc0201576:	6b42                	ld	s6,16(sp)
ffffffffc0201578:	6ba2                	ld	s7,8(sp)
ffffffffc020157a:	6161                	addi	sp,sp,80
ffffffffc020157c:	8082                	ret
            cputchar(c);
ffffffffc020157e:	4521                	li	a0,8
ffffffffc0201580:	b6bfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc0201584:	34fd                	addiw	s1,s1,-1
ffffffffc0201586:	bfbd                	j	ffffffffc0201504 <readline+0x3a>

ffffffffc0201588 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201588:	00005797          	auipc	a5,0x5
ffffffffc020158c:	a8078793          	addi	a5,a5,-1408 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201590:	6398                	ld	a4,0(a5)
ffffffffc0201592:	4781                	li	a5,0
ffffffffc0201594:	88ba                	mv	a7,a4
ffffffffc0201596:	852a                	mv	a0,a0
ffffffffc0201598:	85be                	mv	a1,a5
ffffffffc020159a:	863e                	mv	a2,a5
ffffffffc020159c:	00000073          	ecall
ffffffffc02015a0:	87aa                	mv	a5,a0
}
ffffffffc02015a2:	8082                	ret

ffffffffc02015a4 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc02015a4:	00005797          	auipc	a5,0x5
ffffffffc02015a8:	e8478793          	addi	a5,a5,-380 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc02015ac:	6398                	ld	a4,0(a5)
ffffffffc02015ae:	4781                	li	a5,0
ffffffffc02015b0:	88ba                	mv	a7,a4
ffffffffc02015b2:	852a                	mv	a0,a0
ffffffffc02015b4:	85be                	mv	a1,a5
ffffffffc02015b6:	863e                	mv	a2,a5
ffffffffc02015b8:	00000073          	ecall
ffffffffc02015bc:	87aa                	mv	a5,a0
}
ffffffffc02015be:	8082                	ret

ffffffffc02015c0 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc02015c0:	00005797          	auipc	a5,0x5
ffffffffc02015c4:	a4078793          	addi	a5,a5,-1472 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc02015c8:	639c                	ld	a5,0(a5)
ffffffffc02015ca:	4501                	li	a0,0
ffffffffc02015cc:	88be                	mv	a7,a5
ffffffffc02015ce:	852a                	mv	a0,a0
ffffffffc02015d0:	85aa                	mv	a1,a0
ffffffffc02015d2:	862a                	mv	a2,a0
ffffffffc02015d4:	00000073          	ecall
ffffffffc02015d8:	852a                	mv	a0,a0
ffffffffc02015da:	2501                	sext.w	a0,a0
ffffffffc02015dc:	8082                	ret

ffffffffc02015de <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc02015de:	c185                	beqz	a1,ffffffffc02015fe <strnlen+0x20>
ffffffffc02015e0:	00054783          	lbu	a5,0(a0)
ffffffffc02015e4:	cf89                	beqz	a5,ffffffffc02015fe <strnlen+0x20>
    size_t cnt = 0;
ffffffffc02015e6:	4781                	li	a5,0
ffffffffc02015e8:	a021                	j	ffffffffc02015f0 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02015ea:	00074703          	lbu	a4,0(a4)
ffffffffc02015ee:	c711                	beqz	a4,ffffffffc02015fa <strnlen+0x1c>
        cnt ++;
ffffffffc02015f0:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02015f2:	00f50733          	add	a4,a0,a5
ffffffffc02015f6:	fef59ae3          	bne	a1,a5,ffffffffc02015ea <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02015fa:	853e                	mv	a0,a5
ffffffffc02015fc:	8082                	ret
    size_t cnt = 0;
ffffffffc02015fe:	4781                	li	a5,0
}
ffffffffc0201600:	853e                	mv	a0,a5
ffffffffc0201602:	8082                	ret

ffffffffc0201604 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201604:	00054783          	lbu	a5,0(a0)
ffffffffc0201608:	0005c703          	lbu	a4,0(a1) # fffffffffffff000 <end+0x3fdf8ba0>
ffffffffc020160c:	cb91                	beqz	a5,ffffffffc0201620 <strcmp+0x1c>
ffffffffc020160e:	00e79c63          	bne	a5,a4,ffffffffc0201626 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201612:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201614:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201618:	0585                	addi	a1,a1,1
ffffffffc020161a:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020161e:	fbe5                	bnez	a5,ffffffffc020160e <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201620:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201622:	9d19                	subw	a0,a0,a4
ffffffffc0201624:	8082                	ret
ffffffffc0201626:	0007851b          	sext.w	a0,a5
ffffffffc020162a:	9d19                	subw	a0,a0,a4
ffffffffc020162c:	8082                	ret

ffffffffc020162e <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020162e:	00054783          	lbu	a5,0(a0)
ffffffffc0201632:	cb91                	beqz	a5,ffffffffc0201646 <strchr+0x18>
        if (*s == c) {
ffffffffc0201634:	00b79563          	bne	a5,a1,ffffffffc020163e <strchr+0x10>
ffffffffc0201638:	a809                	j	ffffffffc020164a <strchr+0x1c>
ffffffffc020163a:	00b78763          	beq	a5,a1,ffffffffc0201648 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc020163e:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201640:	00054783          	lbu	a5,0(a0)
ffffffffc0201644:	fbfd                	bnez	a5,ffffffffc020163a <strchr+0xc>
    }
    return NULL;
ffffffffc0201646:	4501                	li	a0,0
}
ffffffffc0201648:	8082                	ret
ffffffffc020164a:	8082                	ret

ffffffffc020164c <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020164c:	ca01                	beqz	a2,ffffffffc020165c <memset+0x10>
ffffffffc020164e:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201650:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201652:	0785                	addi	a5,a5,1
ffffffffc0201654:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201658:	fec79de3          	bne	a5,a2,ffffffffc0201652 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020165c:	8082                	ret
