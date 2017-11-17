
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 10 12 00       	mov    $0x121000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 10 12 f0       	mov    $0xf0121000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 b2 00 00 00       	call   f01000f0 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#define ANSI_COLOR_RESET   "\x1b[0m"

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 40 6d 10 f0       	push   $0xf0106d40
f0100050:	e8 44 3f 00 00       	call   f0103f99 <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7f 27                	jg     f0100083 <test_backtrace+0x43>
		test_backtrace(x-1);
	else
		mon_backtrace(0, 0, 0);
f010005c:	83 ec 04             	sub    $0x4,%esp
f010005f:	6a 00                	push   $0x0
f0100061:	6a 00                	push   $0x0
f0100063:	6a 00                	push   $0x0
f0100065:	e8 3c 0d 00 00       	call   f0100da6 <mon_backtrace>
f010006a:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010006d:	83 ec 08             	sub    $0x8,%esp
f0100070:	53                   	push   %ebx
f0100071:	68 5c 6d 10 f0       	push   $0xf0106d5c
f0100076:	e8 1e 3f 00 00       	call   f0103f99 <cprintf>
}
f010007b:	83 c4 10             	add    $0x10,%esp
f010007e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100081:	c9                   	leave  
f0100082:	c3                   	ret    
		test_backtrace(x-1);
f0100083:	83 ec 0c             	sub    $0xc,%esp
f0100086:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100089:	50                   	push   %eax
f010008a:	e8 b1 ff ff ff       	call   f0100040 <test_backtrace>
f010008f:	83 c4 10             	add    $0x10,%esp
f0100092:	eb d9                	jmp    f010006d <test_backtrace+0x2d>

f0100094 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	56                   	push   %esi
f0100098:	53                   	push   %ebx
f0100099:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010009c:	83 3d 80 5e 2a f0 00 	cmpl   $0x0,0xf02a5e80
f01000a3:	74 0f                	je     f01000b4 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000a5:	83 ec 0c             	sub    $0xc,%esp
f01000a8:	6a 00                	push   $0x0
f01000aa:	e8 a4 0d 00 00       	call   f0100e53 <monitor>
f01000af:	83 c4 10             	add    $0x10,%esp
f01000b2:	eb f1                	jmp    f01000a5 <_panic+0x11>
	panicstr = fmt;
f01000b4:	89 35 80 5e 2a f0    	mov    %esi,0xf02a5e80
	asm volatile("cli; cld");
f01000ba:	fa                   	cli    
f01000bb:	fc                   	cld    
	va_start(ap, fmt);
f01000bc:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f01000bf:	e8 5e 66 00 00       	call   f0106722 <cpunum>
f01000c4:	ff 75 0c             	pushl  0xc(%ebp)
f01000c7:	ff 75 08             	pushl  0x8(%ebp)
f01000ca:	50                   	push   %eax
f01000cb:	68 44 6e 10 f0       	push   $0xf0106e44
f01000d0:	e8 c4 3e 00 00       	call   f0103f99 <cprintf>
	vcprintf(fmt, ap);
f01000d5:	83 c4 08             	add    $0x8,%esp
f01000d8:	53                   	push   %ebx
f01000d9:	56                   	push   %esi
f01000da:	e8 94 3e 00 00       	call   f0103f73 <vcprintf>
	cprintf("\n");
f01000df:	c7 04 24 fb 71 10 f0 	movl   $0xf01071fb,(%esp)
f01000e6:	e8 ae 3e 00 00       	call   f0103f99 <cprintf>
f01000eb:	83 c4 10             	add    $0x10,%esp
f01000ee:	eb b5                	jmp    f01000a5 <_panic+0x11>

f01000f0 <i386_init>:
{
f01000f0:	55                   	push   %ebp
f01000f1:	89 e5                	mov    %esp,%ebp
f01000f3:	53                   	push   %ebx
f01000f4:	83 ec 08             	sub    $0x8,%esp
	memset(edata, 0, end - edata);
f01000f7:	b8 08 70 2e f0       	mov    $0xf02e7008,%eax
f01000fc:	2d 34 45 2a f0       	sub    $0xf02a4534,%eax
f0100101:	50                   	push   %eax
f0100102:	6a 00                	push   $0x0
f0100104:	68 34 45 2a f0       	push   $0xf02a4534
f0100109:	e8 0a 5f 00 00       	call   f0106018 <memset>
	cons_init();
f010010e:	e8 fa 05 00 00       	call   f010070d <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f0100113:	83 c4 08             	add    $0x8,%esp
f0100116:	68 ac 1a 00 00       	push   $0x1aac
f010011b:	68 77 6d 10 f0       	push   $0xf0106d77
f0100120:	e8 74 3e 00 00       	call   f0103f99 <cprintf>
	mem_init();
f0100125:	e8 13 17 00 00       	call   f010183d <mem_init>
	cprintf(ANSI_COLOR_RED     "This text is RED!"     ANSI_COLOR_RESET "\n");
f010012a:	c7 04 24 92 6d 10 f0 	movl   $0xf0106d92,(%esp)
f0100131:	e8 63 3e 00 00       	call   f0103f99 <cprintf>
	cprintf(ANSI_COLOR_GREEN   "This text is GREEN!"   ANSI_COLOR_RESET "\n");
f0100136:	c7 04 24 ae 6d 10 f0 	movl   $0xf0106dae,(%esp)
f010013d:	e8 57 3e 00 00       	call   f0103f99 <cprintf>
	cprintf(ANSI_COLOR_YELLOW  "This text is YELLOW!"  ANSI_COLOR_RESET "\n");
f0100142:	c7 04 24 68 6e 10 f0 	movl   $0xf0106e68,(%esp)
f0100149:	e8 4b 3e 00 00       	call   f0103f99 <cprintf>
	cprintf(ANSI_COLOR_BLUE    "This text is BLUE!"    ANSI_COLOR_RESET "\n");
f010014e:	c7 04 24 cc 6d 10 f0 	movl   $0xf0106dcc,(%esp)
f0100155:	e8 3f 3e 00 00       	call   f0103f99 <cprintf>
	cprintf(ANSI_COLOR_MAGENTA "This text is MAGENTA!" ANSI_COLOR_RESET "\n");
f010015a:	c7 04 24 88 6e 10 f0 	movl   $0xf0106e88,(%esp)
f0100161:	e8 33 3e 00 00       	call   f0103f99 <cprintf>
	cprintf(ANSI_COLOR_CYAN    "This text is CYAN!"    ANSI_COLOR_RESET "\n");
f0100166:	c7 04 24 e9 6d 10 f0 	movl   $0xf0106de9,(%esp)
f010016d:	e8 27 3e 00 00       	call   f0103f99 <cprintf>
	test_backtrace(5);
f0100172:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100179:	e8 c2 fe ff ff       	call   f0100040 <test_backtrace>
	env_init();
f010017e:	e8 d6 34 00 00       	call   f0103659 <env_init>
	trap_init();
f0100183:	e8 c5 3e 00 00       	call   f010404d <trap_init>
	mp_init();
f0100188:	e8 7e 62 00 00       	call   f010640b <mp_init>
	lapic_init();
f010018d:	e8 ab 65 00 00       	call   f010673d <lapic_init>
	pic_init();
f0100192:	e8 29 3d 00 00       	call   f0103ec0 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100197:	c7 04 24 c0 33 12 f0 	movl   $0xf01233c0,(%esp)
f010019e:	e8 f3 67 00 00       	call   f0106996 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01001a3:	83 c4 10             	add    $0x10,%esp
f01001a6:	83 3d 88 5e 2a f0 07 	cmpl   $0x7,0xf02a5e88
f01001ad:	76 27                	jbe    f01001d6 <i386_init+0xe6>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001af:	83 ec 04             	sub    $0x4,%esp
f01001b2:	b8 72 63 10 f0       	mov    $0xf0106372,%eax
f01001b7:	2d f8 62 10 f0       	sub    $0xf01062f8,%eax
f01001bc:	50                   	push   %eax
f01001bd:	68 f8 62 10 f0       	push   $0xf01062f8
f01001c2:	68 00 70 00 f0       	push   $0xf0007000
f01001c7:	e8 99 5e 00 00       	call   f0106065 <memmove>
f01001cc:	83 c4 10             	add    $0x10,%esp
	for (c = cpus; c < cpus + ncpu; c++) {
f01001cf:	bb 20 60 2a f0       	mov    $0xf02a6020,%ebx
f01001d4:	eb 19                	jmp    f01001ef <i386_init+0xff>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001d6:	68 00 70 00 00       	push   $0x7000
f01001db:	68 a8 6e 10 f0       	push   $0xf0106ea8
f01001e0:	6a 76                	push   $0x76
f01001e2:	68 06 6e 10 f0       	push   $0xf0106e06
f01001e7:	e8 a8 fe ff ff       	call   f0100094 <_panic>
f01001ec:	83 c3 74             	add    $0x74,%ebx
f01001ef:	8b 15 c4 63 2a f0    	mov    0xf02a63c4,%edx
f01001f5:	8d 04 12             	lea    (%edx,%edx,1),%eax
f01001f8:	01 d0                	add    %edx,%eax
f01001fa:	01 c0                	add    %eax,%eax
f01001fc:	01 d0                	add    %edx,%eax
f01001fe:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100201:	8d 04 85 20 60 2a f0 	lea    -0xfd59fe0(,%eax,4),%eax
f0100208:	39 c3                	cmp    %eax,%ebx
f010020a:	73 6d                	jae    f0100279 <i386_init+0x189>
		if (c == cpus + cpunum())  // We've started already.
f010020c:	e8 11 65 00 00       	call   f0106722 <cpunum>
f0100211:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100214:	01 c2                	add    %eax,%edx
f0100216:	01 d2                	add    %edx,%edx
f0100218:	01 c2                	add    %eax,%edx
f010021a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010021d:	8d 04 85 20 60 2a f0 	lea    -0xfd59fe0(,%eax,4),%eax
f0100224:	39 c3                	cmp    %eax,%ebx
f0100226:	74 c4                	je     f01001ec <i386_init+0xfc>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100228:	89 d8                	mov    %ebx,%eax
f010022a:	2d 20 60 2a f0       	sub    $0xf02a6020,%eax
f010022f:	c1 f8 02             	sar    $0x2,%eax
f0100232:	89 c2                	mov    %eax,%edx
f0100234:	c1 e0 07             	shl    $0x7,%eax
f0100237:	29 d0                	sub    %edx,%eax
f0100239:	8d 0c c2             	lea    (%edx,%eax,8),%ecx
f010023c:	89 c8                	mov    %ecx,%eax
f010023e:	c1 e0 0e             	shl    $0xe,%eax
f0100241:	29 c8                	sub    %ecx,%eax
f0100243:	c1 e0 04             	shl    $0x4,%eax
f0100246:	01 d0                	add    %edx,%eax
f0100248:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010024b:	c1 e0 0f             	shl    $0xf,%eax
f010024e:	05 00 f0 2a f0       	add    $0xf02af000,%eax
f0100253:	a3 84 5e 2a f0       	mov    %eax,0xf02a5e84
		lapic_startap(c->cpu_id, PADDR(code));
f0100258:	83 ec 08             	sub    $0x8,%esp
f010025b:	68 00 70 00 00       	push   $0x7000
f0100260:	0f b6 03             	movzbl (%ebx),%eax
f0100263:	50                   	push   %eax
f0100264:	e8 2e 66 00 00       	call   f0106897 <lapic_startap>
f0100269:	83 c4 10             	add    $0x10,%esp
		while(c->cpu_status != CPU_STARTED)
f010026c:	8b 43 04             	mov    0x4(%ebx),%eax
f010026f:	83 f8 01             	cmp    $0x1,%eax
f0100272:	75 f8                	jne    f010026c <i386_init+0x17c>
f0100274:	e9 73 ff ff ff       	jmp    f01001ec <i386_init+0xfc>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100279:	83 ec 08             	sub    $0x8,%esp
f010027c:	6a 00                	push   $0x0
f010027e:	68 c0 77 21 f0       	push   $0xf02177c0
f0100283:	e8 23 36 00 00       	call   f01038ab <env_create>
	kbd_intr();
f0100288:	e8 24 04 00 00       	call   f01006b1 <kbd_intr>
	sched_yield();
f010028d:	e8 82 4b 00 00       	call   f0104e14 <sched_yield>

f0100292 <mp_main>:
{
f0100292:	55                   	push   %ebp
f0100293:	89 e5                	mov    %esp,%ebp
f0100295:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f0100298:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f010029d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01002a2:	77 15                	ja     f01002b9 <mp_main+0x27>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01002a4:	50                   	push   %eax
f01002a5:	68 cc 6e 10 f0       	push   $0xf0106ecc
f01002aa:	68 8d 00 00 00       	push   $0x8d
f01002af:	68 06 6e 10 f0       	push   $0xf0106e06
f01002b4:	e8 db fd ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01002b9:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01002be:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01002c1:	e8 5c 64 00 00       	call   f0106722 <cpunum>
f01002c6:	83 ec 08             	sub    $0x8,%esp
f01002c9:	50                   	push   %eax
f01002ca:	68 12 6e 10 f0       	push   $0xf0106e12
f01002cf:	e8 c5 3c 00 00       	call   f0103f99 <cprintf>
	lapic_init();
f01002d4:	e8 64 64 00 00       	call   f010673d <lapic_init>
	env_init_percpu();
f01002d9:	e8 4b 33 00 00       	call   f0103629 <env_init_percpu>
	trap_init_percpu();
f01002de:	e8 ca 3c 00 00       	call   f0103fad <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01002e3:	e8 3a 64 00 00       	call   f0106722 <cpunum>
f01002e8:	6b d0 74             	imul   $0x74,%eax,%edx
f01002eb:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01002ee:	b8 01 00 00 00       	mov    $0x1,%eax
f01002f3:	f0 87 82 20 60 2a f0 	lock xchg %eax,-0xfd59fe0(%edx)
f01002fa:	c7 04 24 c0 33 12 f0 	movl   $0xf01233c0,(%esp)
f0100301:	e8 90 66 00 00       	call   f0106996 <spin_lock>
	sched_yield();
f0100306:	e8 09 4b 00 00       	call   f0104e14 <sched_yield>

f010030b <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010030b:	55                   	push   %ebp
f010030c:	89 e5                	mov    %esp,%ebp
f010030e:	53                   	push   %ebx
f010030f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100312:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100315:	ff 75 0c             	pushl  0xc(%ebp)
f0100318:	ff 75 08             	pushl  0x8(%ebp)
f010031b:	68 28 6e 10 f0       	push   $0xf0106e28
f0100320:	e8 74 3c 00 00       	call   f0103f99 <cprintf>
	vcprintf(fmt, ap);
f0100325:	83 c4 08             	add    $0x8,%esp
f0100328:	53                   	push   %ebx
f0100329:	ff 75 10             	pushl  0x10(%ebp)
f010032c:	e8 42 3c 00 00       	call   f0103f73 <vcprintf>
	cprintf("\n");
f0100331:	c7 04 24 fb 71 10 f0 	movl   $0xf01071fb,(%esp)
f0100338:	e8 5c 3c 00 00       	call   f0103f99 <cprintf>
	va_end(ap);
}
f010033d:	83 c4 10             	add    $0x10,%esp
f0100340:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100343:	c9                   	leave  
f0100344:	c3                   	ret    

f0100345 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100345:	55                   	push   %ebp
f0100346:	89 e5                	mov    %esp,%ebp
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100348:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010034d:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010034e:	a8 01                	test   $0x1,%al
f0100350:	74 0b                	je     f010035d <serial_proc_data+0x18>
f0100352:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100357:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100358:	0f b6 c0             	movzbl %al,%eax
}
f010035b:	5d                   	pop    %ebp
f010035c:	c3                   	ret    
		return -1;
f010035d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100362:	eb f7                	jmp    f010035b <serial_proc_data+0x16>

f0100364 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100364:	55                   	push   %ebp
f0100365:	89 e5                	mov    %esp,%ebp
f0100367:	53                   	push   %ebx
f0100368:	83 ec 04             	sub    $0x4,%esp
f010036b:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010036d:	ff d3                	call   *%ebx
f010036f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100372:	74 2d                	je     f01003a1 <cons_intr+0x3d>
		if (c == 0)
f0100374:	85 c0                	test   %eax,%eax
f0100376:	74 f5                	je     f010036d <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f0100378:	8b 0d 24 52 2a f0    	mov    0xf02a5224,%ecx
f010037e:	8d 51 01             	lea    0x1(%ecx),%edx
f0100381:	89 15 24 52 2a f0    	mov    %edx,0xf02a5224
f0100387:	88 81 20 50 2a f0    	mov    %al,-0xfd5afe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010038d:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100393:	75 d8                	jne    f010036d <cons_intr+0x9>
			cons.wpos = 0;
f0100395:	c7 05 24 52 2a f0 00 	movl   $0x0,0xf02a5224
f010039c:	00 00 00 
f010039f:	eb cc                	jmp    f010036d <cons_intr+0x9>
	}
}
f01003a1:	83 c4 04             	add    $0x4,%esp
f01003a4:	5b                   	pop    %ebx
f01003a5:	5d                   	pop    %ebp
f01003a6:	c3                   	ret    

f01003a7 <kbd_proc_data>:
{
f01003a7:	55                   	push   %ebp
f01003a8:	89 e5                	mov    %esp,%ebp
f01003aa:	53                   	push   %ebx
f01003ab:	83 ec 04             	sub    $0x4,%esp
f01003ae:	ba 64 00 00 00       	mov    $0x64,%edx
f01003b3:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01003b4:	a8 01                	test   $0x1,%al
f01003b6:	0f 84 f1 00 00 00    	je     f01004ad <kbd_proc_data+0x106>
	if (stat & KBS_TERR)
f01003bc:	a8 20                	test   $0x20,%al
f01003be:	0f 85 f0 00 00 00    	jne    f01004b4 <kbd_proc_data+0x10d>
f01003c4:	ba 60 00 00 00       	mov    $0x60,%edx
f01003c9:	ec                   	in     (%dx),%al
f01003ca:	88 c2                	mov    %al,%dl
	if (data == 0xE0) {
f01003cc:	3c e0                	cmp    $0xe0,%al
f01003ce:	0f 84 8a 00 00 00    	je     f010045e <kbd_proc_data+0xb7>
	} else if (data & 0x80) {
f01003d4:	84 c0                	test   %al,%al
f01003d6:	0f 88 95 00 00 00    	js     f0100471 <kbd_proc_data+0xca>
	} else if (shift & E0ESC) {
f01003dc:	8b 0d 00 50 2a f0    	mov    0xf02a5000,%ecx
f01003e2:	f6 c1 40             	test   $0x40,%cl
f01003e5:	74 0e                	je     f01003f5 <kbd_proc_data+0x4e>
		data |= 0x80;
f01003e7:	83 c8 80             	or     $0xffffff80,%eax
f01003ea:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f01003ec:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003ef:	89 0d 00 50 2a f0    	mov    %ecx,0xf02a5000
	shift |= shiftcode[data];
f01003f5:	0f b6 d2             	movzbl %dl,%edx
f01003f8:	0f b6 82 40 70 10 f0 	movzbl -0xfef8fc0(%edx),%eax
f01003ff:	0b 05 00 50 2a f0    	or     0xf02a5000,%eax
	shift ^= togglecode[data];
f0100405:	0f b6 8a 40 6f 10 f0 	movzbl -0xfef90c0(%edx),%ecx
f010040c:	31 c8                	xor    %ecx,%eax
f010040e:	a3 00 50 2a f0       	mov    %eax,0xf02a5000
	c = charcode[shift & (CTL | SHIFT)][data];
f0100413:	89 c1                	mov    %eax,%ecx
f0100415:	83 e1 03             	and    $0x3,%ecx
f0100418:	8b 0c 8d 20 6f 10 f0 	mov    -0xfef90e0(,%ecx,4),%ecx
f010041f:	8a 14 11             	mov    (%ecx,%edx,1),%dl
f0100422:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100425:	a8 08                	test   $0x8,%al
f0100427:	74 0d                	je     f0100436 <kbd_proc_data+0x8f>
		if ('a' <= c && c <= 'z')
f0100429:	89 da                	mov    %ebx,%edx
f010042b:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010042e:	83 f9 19             	cmp    $0x19,%ecx
f0100431:	77 6d                	ja     f01004a0 <kbd_proc_data+0xf9>
			c += 'A' - 'a';
f0100433:	83 eb 20             	sub    $0x20,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100436:	f7 d0                	not    %eax
f0100438:	a8 06                	test   $0x6,%al
f010043a:	75 2e                	jne    f010046a <kbd_proc_data+0xc3>
f010043c:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100442:	75 26                	jne    f010046a <kbd_proc_data+0xc3>
		cprintf("Rebooting!\n");
f0100444:	83 ec 0c             	sub    $0xc,%esp
f0100447:	68 f0 6e 10 f0       	push   $0xf0106ef0
f010044c:	e8 48 3b 00 00       	call   f0103f99 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100451:	b0 03                	mov    $0x3,%al
f0100453:	ba 92 00 00 00       	mov    $0x92,%edx
f0100458:	ee                   	out    %al,(%dx)
f0100459:	83 c4 10             	add    $0x10,%esp
f010045c:	eb 0c                	jmp    f010046a <kbd_proc_data+0xc3>
		shift |= E0ESC;
f010045e:	83 0d 00 50 2a f0 40 	orl    $0x40,0xf02a5000
		return 0;
f0100465:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f010046a:	89 d8                	mov    %ebx,%eax
f010046c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010046f:	c9                   	leave  
f0100470:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100471:	8b 0d 00 50 2a f0    	mov    0xf02a5000,%ecx
f0100477:	f6 c1 40             	test   $0x40,%cl
f010047a:	75 05                	jne    f0100481 <kbd_proc_data+0xda>
f010047c:	83 e0 7f             	and    $0x7f,%eax
f010047f:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f0100481:	0f b6 d2             	movzbl %dl,%edx
f0100484:	8a 82 40 70 10 f0    	mov    -0xfef8fc0(%edx),%al
f010048a:	83 c8 40             	or     $0x40,%eax
f010048d:	0f b6 c0             	movzbl %al,%eax
f0100490:	f7 d0                	not    %eax
f0100492:	21 c8                	and    %ecx,%eax
f0100494:	a3 00 50 2a f0       	mov    %eax,0xf02a5000
		return 0;
f0100499:	bb 00 00 00 00       	mov    $0x0,%ebx
f010049e:	eb ca                	jmp    f010046a <kbd_proc_data+0xc3>
		else if ('A' <= c && c <= 'Z')
f01004a0:	83 ea 41             	sub    $0x41,%edx
f01004a3:	83 fa 19             	cmp    $0x19,%edx
f01004a6:	77 8e                	ja     f0100436 <kbd_proc_data+0x8f>
			c += 'a' - 'A';
f01004a8:	83 c3 20             	add    $0x20,%ebx
f01004ab:	eb 89                	jmp    f0100436 <kbd_proc_data+0x8f>
		return -1;
f01004ad:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01004b2:	eb b6                	jmp    f010046a <kbd_proc_data+0xc3>
		return -1;
f01004b4:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01004b9:	eb af                	jmp    f010046a <kbd_proc_data+0xc3>

f01004bb <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01004bb:	55                   	push   %ebp
f01004bc:	89 e5                	mov    %esp,%ebp
f01004be:	57                   	push   %edi
f01004bf:	56                   	push   %esi
f01004c0:	53                   	push   %ebx
f01004c1:	83 ec 1c             	sub    $0x1c,%esp
f01004c4:	89 c7                	mov    %eax,%edi
f01004c6:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004cb:	be fd 03 00 00       	mov    $0x3fd,%esi
f01004d0:	b9 84 00 00 00       	mov    $0x84,%ecx
f01004d5:	eb 06                	jmp    f01004dd <cons_putc+0x22>
f01004d7:	89 ca                	mov    %ecx,%edx
f01004d9:	ec                   	in     (%dx),%al
f01004da:	ec                   	in     (%dx),%al
f01004db:	ec                   	in     (%dx),%al
f01004dc:	ec                   	in     (%dx),%al
f01004dd:	89 f2                	mov    %esi,%edx
f01004df:	ec                   	in     (%dx),%al
	for (i = 0;
f01004e0:	a8 20                	test   $0x20,%al
f01004e2:	75 03                	jne    f01004e7 <cons_putc+0x2c>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01004e4:	4b                   	dec    %ebx
f01004e5:	75 f0                	jne    f01004d7 <cons_putc+0x1c>
	outb(COM1 + COM_TX, c);
f01004e7:	89 f8                	mov    %edi,%eax
f01004e9:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004ec:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01004f1:	ee                   	out    %al,(%dx)
f01004f2:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004f7:	be 79 03 00 00       	mov    $0x379,%esi
f01004fc:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100501:	eb 06                	jmp    f0100509 <cons_putc+0x4e>
f0100503:	89 ca                	mov    %ecx,%edx
f0100505:	ec                   	in     (%dx),%al
f0100506:	ec                   	in     (%dx),%al
f0100507:	ec                   	in     (%dx),%al
f0100508:	ec                   	in     (%dx),%al
f0100509:	89 f2                	mov    %esi,%edx
f010050b:	ec                   	in     (%dx),%al
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010050c:	84 c0                	test   %al,%al
f010050e:	78 03                	js     f0100513 <cons_putc+0x58>
f0100510:	4b                   	dec    %ebx
f0100511:	75 f0                	jne    f0100503 <cons_putc+0x48>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100513:	ba 78 03 00 00       	mov    $0x378,%edx
f0100518:	8a 45 e7             	mov    -0x19(%ebp),%al
f010051b:	ee                   	out    %al,(%dx)
f010051c:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100521:	b0 0d                	mov    $0xd,%al
f0100523:	ee                   	out    %al,(%dx)
f0100524:	b0 08                	mov    $0x8,%al
f0100526:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f0100527:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f010052d:	75 06                	jne    f0100535 <cons_putc+0x7a>
		c |= 0x0700;
f010052f:	81 cf 00 07 00 00    	or     $0x700,%edi
	switch (c & 0xff) {
f0100535:	89 f8                	mov    %edi,%eax
f0100537:	0f b6 c0             	movzbl %al,%eax
f010053a:	83 f8 09             	cmp    $0x9,%eax
f010053d:	0f 84 b1 00 00 00    	je     f01005f4 <cons_putc+0x139>
f0100543:	83 f8 09             	cmp    $0x9,%eax
f0100546:	7e 70                	jle    f01005b8 <cons_putc+0xfd>
f0100548:	83 f8 0a             	cmp    $0xa,%eax
f010054b:	0f 84 96 00 00 00    	je     f01005e7 <cons_putc+0x12c>
f0100551:	83 f8 0d             	cmp    $0xd,%eax
f0100554:	0f 85 d1 00 00 00    	jne    f010062b <cons_putc+0x170>
		crt_pos -= (crt_pos % CRT_COLS);
f010055a:	66 8b 0d 28 52 2a f0 	mov    0xf02a5228,%cx
f0100561:	bb 50 00 00 00       	mov    $0x50,%ebx
f0100566:	89 c8                	mov    %ecx,%eax
f0100568:	ba 00 00 00 00       	mov    $0x0,%edx
f010056d:	66 f7 f3             	div    %bx
f0100570:	29 d1                	sub    %edx,%ecx
f0100572:	66 89 0d 28 52 2a f0 	mov    %cx,0xf02a5228
	if (crt_pos >= CRT_SIZE) {
f0100579:	66 81 3d 28 52 2a f0 	cmpw   $0x7cf,0xf02a5228
f0100580:	cf 07 
f0100582:	0f 87 c5 00 00 00    	ja     f010064d <cons_putc+0x192>
	outb(addr_6845, 14);
f0100588:	8b 0d 30 52 2a f0    	mov    0xf02a5230,%ecx
f010058e:	b0 0e                	mov    $0xe,%al
f0100590:	89 ca                	mov    %ecx,%edx
f0100592:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100593:	8d 59 01             	lea    0x1(%ecx),%ebx
f0100596:	66 a1 28 52 2a f0    	mov    0xf02a5228,%ax
f010059c:	66 c1 e8 08          	shr    $0x8,%ax
f01005a0:	89 da                	mov    %ebx,%edx
f01005a2:	ee                   	out    %al,(%dx)
f01005a3:	b0 0f                	mov    $0xf,%al
f01005a5:	89 ca                	mov    %ecx,%edx
f01005a7:	ee                   	out    %al,(%dx)
f01005a8:	a0 28 52 2a f0       	mov    0xf02a5228,%al
f01005ad:	89 da                	mov    %ebx,%edx
f01005af:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005b3:	5b                   	pop    %ebx
f01005b4:	5e                   	pop    %esi
f01005b5:	5f                   	pop    %edi
f01005b6:	5d                   	pop    %ebp
f01005b7:	c3                   	ret    
	switch (c & 0xff) {
f01005b8:	83 f8 08             	cmp    $0x8,%eax
f01005bb:	75 6e                	jne    f010062b <cons_putc+0x170>
		if (crt_pos > 0) {
f01005bd:	66 a1 28 52 2a f0    	mov    0xf02a5228,%ax
f01005c3:	66 85 c0             	test   %ax,%ax
f01005c6:	74 c0                	je     f0100588 <cons_putc+0xcd>
			crt_pos--;
f01005c8:	48                   	dec    %eax
f01005c9:	66 a3 28 52 2a f0    	mov    %ax,0xf02a5228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01005cf:	0f b7 c0             	movzwl %ax,%eax
f01005d2:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f01005d8:	83 cf 20             	or     $0x20,%edi
f01005db:	8b 15 2c 52 2a f0    	mov    0xf02a522c,%edx
f01005e1:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01005e5:	eb 92                	jmp    f0100579 <cons_putc+0xbe>
		crt_pos += CRT_COLS;
f01005e7:	66 83 05 28 52 2a f0 	addw   $0x50,0xf02a5228
f01005ee:	50 
f01005ef:	e9 66 ff ff ff       	jmp    f010055a <cons_putc+0x9f>
		cons_putc(' ');
f01005f4:	b8 20 00 00 00       	mov    $0x20,%eax
f01005f9:	e8 bd fe ff ff       	call   f01004bb <cons_putc>
		cons_putc(' ');
f01005fe:	b8 20 00 00 00       	mov    $0x20,%eax
f0100603:	e8 b3 fe ff ff       	call   f01004bb <cons_putc>
		cons_putc(' ');
f0100608:	b8 20 00 00 00       	mov    $0x20,%eax
f010060d:	e8 a9 fe ff ff       	call   f01004bb <cons_putc>
		cons_putc(' ');
f0100612:	b8 20 00 00 00       	mov    $0x20,%eax
f0100617:	e8 9f fe ff ff       	call   f01004bb <cons_putc>
		cons_putc(' ');
f010061c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100621:	e8 95 fe ff ff       	call   f01004bb <cons_putc>
f0100626:	e9 4e ff ff ff       	jmp    f0100579 <cons_putc+0xbe>
		crt_buf[crt_pos++] = c;		/* write the character */
f010062b:	66 a1 28 52 2a f0    	mov    0xf02a5228,%ax
f0100631:	8d 50 01             	lea    0x1(%eax),%edx
f0100634:	66 89 15 28 52 2a f0 	mov    %dx,0xf02a5228
f010063b:	0f b7 c0             	movzwl %ax,%eax
f010063e:	8b 15 2c 52 2a f0    	mov    0xf02a522c,%edx
f0100644:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100648:	e9 2c ff ff ff       	jmp    f0100579 <cons_putc+0xbe>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010064d:	a1 2c 52 2a f0       	mov    0xf02a522c,%eax
f0100652:	83 ec 04             	sub    $0x4,%esp
f0100655:	68 00 0f 00 00       	push   $0xf00
f010065a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100660:	52                   	push   %edx
f0100661:	50                   	push   %eax
f0100662:	e8 fe 59 00 00       	call   f0106065 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100667:	8b 15 2c 52 2a f0    	mov    0xf02a522c,%edx
f010066d:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100673:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100679:	83 c4 10             	add    $0x10,%esp
f010067c:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100681:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100684:	39 d0                	cmp    %edx,%eax
f0100686:	75 f4                	jne    f010067c <cons_putc+0x1c1>
		crt_pos -= CRT_COLS;
f0100688:	66 83 2d 28 52 2a f0 	subw   $0x50,0xf02a5228
f010068f:	50 
f0100690:	e9 f3 fe ff ff       	jmp    f0100588 <cons_putc+0xcd>

f0100695 <serial_intr>:
	if (serial_exists)
f0100695:	80 3d 34 52 2a f0 00 	cmpb   $0x0,0xf02a5234
f010069c:	75 01                	jne    f010069f <serial_intr+0xa>
f010069e:	c3                   	ret    
{
f010069f:	55                   	push   %ebp
f01006a0:	89 e5                	mov    %esp,%ebp
f01006a2:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01006a5:	b8 45 03 10 f0       	mov    $0xf0100345,%eax
f01006aa:	e8 b5 fc ff ff       	call   f0100364 <cons_intr>
}
f01006af:	c9                   	leave  
f01006b0:	c3                   	ret    

f01006b1 <kbd_intr>:
{
f01006b1:	55                   	push   %ebp
f01006b2:	89 e5                	mov    %esp,%ebp
f01006b4:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01006b7:	b8 a7 03 10 f0       	mov    $0xf01003a7,%eax
f01006bc:	e8 a3 fc ff ff       	call   f0100364 <cons_intr>
}
f01006c1:	c9                   	leave  
f01006c2:	c3                   	ret    

f01006c3 <cons_getc>:
{
f01006c3:	55                   	push   %ebp
f01006c4:	89 e5                	mov    %esp,%ebp
f01006c6:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f01006c9:	e8 c7 ff ff ff       	call   f0100695 <serial_intr>
	kbd_intr();
f01006ce:	e8 de ff ff ff       	call   f01006b1 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01006d3:	a1 20 52 2a f0       	mov    0xf02a5220,%eax
f01006d8:	3b 05 24 52 2a f0    	cmp    0xf02a5224,%eax
f01006de:	74 26                	je     f0100706 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01006e0:	8d 50 01             	lea    0x1(%eax),%edx
f01006e3:	89 15 20 52 2a f0    	mov    %edx,0xf02a5220
f01006e9:	0f b6 80 20 50 2a f0 	movzbl -0xfd5afe0(%eax),%eax
		if (cons.rpos == CONSBUFSIZE)
f01006f0:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01006f6:	74 02                	je     f01006fa <cons_getc+0x37>
}
f01006f8:	c9                   	leave  
f01006f9:	c3                   	ret    
			cons.rpos = 0;
f01006fa:	c7 05 20 52 2a f0 00 	movl   $0x0,0xf02a5220
f0100701:	00 00 00 
f0100704:	eb f2                	jmp    f01006f8 <cons_getc+0x35>
	return 0;
f0100706:	b8 00 00 00 00       	mov    $0x0,%eax
f010070b:	eb eb                	jmp    f01006f8 <cons_getc+0x35>

f010070d <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f010070d:	55                   	push   %ebp
f010070e:	89 e5                	mov    %esp,%ebp
f0100710:	57                   	push   %edi
f0100711:	56                   	push   %esi
f0100712:	53                   	push   %ebx
f0100713:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f0100716:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f010071d:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100724:	5a a5 
	if (*cp != 0xA55A) {
f0100726:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f010072c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100730:	0f 84 c8 00 00 00    	je     f01007fe <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f0100736:	c7 05 30 52 2a f0 b4 	movl   $0x3b4,0xf02a5230
f010073d:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100740:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f0100745:	8b 3d 30 52 2a f0    	mov    0xf02a5230,%edi
f010074b:	b0 0e                	mov    $0xe,%al
f010074d:	89 fa                	mov    %edi,%edx
f010074f:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100750:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100753:	89 ca                	mov    %ecx,%edx
f0100755:	ec                   	in     (%dx),%al
f0100756:	0f b6 c0             	movzbl %al,%eax
f0100759:	c1 e0 08             	shl    $0x8,%eax
f010075c:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010075e:	b0 0f                	mov    $0xf,%al
f0100760:	89 fa                	mov    %edi,%edx
f0100762:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100763:	89 ca                	mov    %ecx,%edx
f0100765:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100766:	89 35 2c 52 2a f0    	mov    %esi,0xf02a522c
	pos |= inb(addr_6845 + 1);
f010076c:	0f b6 c0             	movzbl %al,%eax
f010076f:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f0100771:	66 a3 28 52 2a f0    	mov    %ax,0xf02a5228
	kbd_intr();
f0100777:	e8 35 ff ff ff       	call   f01006b1 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f010077c:	83 ec 0c             	sub    $0xc,%esp
f010077f:	66 a1 a8 33 12 f0    	mov    0xf01233a8,%ax
f0100785:	25 fd ff 00 00       	and    $0xfffd,%eax
f010078a:	50                   	push   %eax
f010078b:	e8 b8 36 00 00       	call   f0103e48 <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100790:	b1 00                	mov    $0x0,%cl
f0100792:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100797:	88 c8                	mov    %cl,%al
f0100799:	89 da                	mov    %ebx,%edx
f010079b:	ee                   	out    %al,(%dx)
f010079c:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01007a1:	b0 80                	mov    $0x80,%al
f01007a3:	89 fa                	mov    %edi,%edx
f01007a5:	ee                   	out    %al,(%dx)
f01007a6:	b0 0c                	mov    $0xc,%al
f01007a8:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01007ad:	ee                   	out    %al,(%dx)
f01007ae:	be f9 03 00 00       	mov    $0x3f9,%esi
f01007b3:	88 c8                	mov    %cl,%al
f01007b5:	89 f2                	mov    %esi,%edx
f01007b7:	ee                   	out    %al,(%dx)
f01007b8:	b0 03                	mov    $0x3,%al
f01007ba:	89 fa                	mov    %edi,%edx
f01007bc:	ee                   	out    %al,(%dx)
f01007bd:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01007c2:	88 c8                	mov    %cl,%al
f01007c4:	ee                   	out    %al,(%dx)
f01007c5:	b0 01                	mov    $0x1,%al
f01007c7:	89 f2                	mov    %esi,%edx
f01007c9:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01007ca:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01007cf:	ec                   	in     (%dx),%al
f01007d0:	88 c1                	mov    %al,%cl
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01007d2:	83 c4 10             	add    $0x10,%esp
f01007d5:	3c ff                	cmp    $0xff,%al
f01007d7:	0f 95 05 34 52 2a f0 	setne  0xf02a5234
f01007de:	89 da                	mov    %ebx,%edx
f01007e0:	ec                   	in     (%dx),%al
f01007e1:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01007e6:	ec                   	in     (%dx),%al
	if (serial_exists)
f01007e7:	80 f9 ff             	cmp    $0xff,%cl
f01007ea:	75 2d                	jne    f0100819 <cons_init+0x10c>
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
		cprintf("Serial port does not exist!\n");
f01007ec:	83 ec 0c             	sub    $0xc,%esp
f01007ef:	68 fc 6e 10 f0       	push   $0xf0106efc
f01007f4:	e8 a0 37 00 00       	call   f0103f99 <cprintf>
f01007f9:	83 c4 10             	add    $0x10,%esp
}
f01007fc:	eb 3b                	jmp    f0100839 <cons_init+0x12c>
		*cp = was;
f01007fe:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100805:	c7 05 30 52 2a f0 d4 	movl   $0x3d4,0xf02a5230
f010080c:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010080f:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f0100814:	e9 2c ff ff ff       	jmp    f0100745 <cons_init+0x38>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f0100819:	83 ec 0c             	sub    $0xc,%esp
f010081c:	66 a1 a8 33 12 f0    	mov    0xf01233a8,%ax
f0100822:	25 ef ff 00 00       	and    $0xffef,%eax
f0100827:	50                   	push   %eax
f0100828:	e8 1b 36 00 00       	call   f0103e48 <irq_setmask_8259A>
	if (!serial_exists)
f010082d:	83 c4 10             	add    $0x10,%esp
f0100830:	80 3d 34 52 2a f0 00 	cmpb   $0x0,0xf02a5234
f0100837:	74 b3                	je     f01007ec <cons_init+0xdf>
}
f0100839:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010083c:	5b                   	pop    %ebx
f010083d:	5e                   	pop    %esi
f010083e:	5f                   	pop    %edi
f010083f:	5d                   	pop    %ebp
f0100840:	c3                   	ret    

f0100841 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100841:	55                   	push   %ebp
f0100842:	89 e5                	mov    %esp,%ebp
f0100844:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100847:	8b 45 08             	mov    0x8(%ebp),%eax
f010084a:	e8 6c fc ff ff       	call   f01004bb <cons_putc>
}
f010084f:	c9                   	leave  
f0100850:	c3                   	ret    

f0100851 <getchar>:

int
getchar(void)
{
f0100851:	55                   	push   %ebp
f0100852:	89 e5                	mov    %esp,%ebp
f0100854:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100857:	e8 67 fe ff ff       	call   f01006c3 <cons_getc>
f010085c:	85 c0                	test   %eax,%eax
f010085e:	74 f7                	je     f0100857 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100860:	c9                   	leave  
f0100861:	c3                   	ret    

f0100862 <iscons>:

int
iscons(int fdnum)
{
f0100862:	55                   	push   %ebp
f0100863:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100865:	b8 01 00 00 00       	mov    $0x1,%eax
f010086a:	5d                   	pop    %ebp
f010086b:	c3                   	ret    

f010086c <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010086c:	55                   	push   %ebp
f010086d:	89 e5                	mov    %esp,%ebp
f010086f:	56                   	push   %esi
f0100870:	53                   	push   %ebx
f0100871:	bb 20 76 10 f0       	mov    $0xf0107620,%ebx
f0100876:	be 5c 76 10 f0       	mov    $0xf010765c,%esi
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010087b:	83 ec 04             	sub    $0x4,%esp
f010087e:	ff 73 04             	pushl  0x4(%ebx)
f0100881:	ff 33                	pushl  (%ebx)
f0100883:	68 40 71 10 f0       	push   $0xf0107140
f0100888:	e8 0c 37 00 00       	call   f0103f99 <cprintf>
f010088d:	83 c3 0c             	add    $0xc,%ebx
	for (i = 0; i < ARRAY_SIZE(commands); i++)
f0100890:	83 c4 10             	add    $0x10,%esp
f0100893:	39 f3                	cmp    %esi,%ebx
f0100895:	75 e4                	jne    f010087b <mon_help+0xf>
	return 0;
}
f0100897:	b8 00 00 00 00       	mov    $0x0,%eax
f010089c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010089f:	5b                   	pop    %ebx
f01008a0:	5e                   	pop    %esi
f01008a1:	5d                   	pop    %ebp
f01008a2:	c3                   	ret    

f01008a3 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01008a3:	55                   	push   %ebp
f01008a4:	89 e5                	mov    %esp,%ebp
f01008a6:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01008a9:	68 49 71 10 f0       	push   $0xf0107149
f01008ae:	e8 e6 36 00 00       	call   f0103f99 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01008b3:	83 c4 08             	add    $0x8,%esp
f01008b6:	68 0c 00 10 00       	push   $0x10000c
f01008bb:	68 a0 72 10 f0       	push   $0xf01072a0
f01008c0:	e8 d4 36 00 00       	call   f0103f99 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01008c5:	83 c4 0c             	add    $0xc,%esp
f01008c8:	68 0c 00 10 00       	push   $0x10000c
f01008cd:	68 0c 00 10 f0       	push   $0xf010000c
f01008d2:	68 c8 72 10 f0       	push   $0xf01072c8
f01008d7:	e8 bd 36 00 00       	call   f0103f99 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01008dc:	83 c4 0c             	add    $0xc,%esp
f01008df:	68 3c 6d 10 00       	push   $0x106d3c
f01008e4:	68 3c 6d 10 f0       	push   $0xf0106d3c
f01008e9:	68 ec 72 10 f0       	push   $0xf01072ec
f01008ee:	e8 a6 36 00 00       	call   f0103f99 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01008f3:	83 c4 0c             	add    $0xc,%esp
f01008f6:	68 34 45 2a 00       	push   $0x2a4534
f01008fb:	68 34 45 2a f0       	push   $0xf02a4534
f0100900:	68 10 73 10 f0       	push   $0xf0107310
f0100905:	e8 8f 36 00 00       	call   f0103f99 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010090a:	83 c4 0c             	add    $0xc,%esp
f010090d:	68 08 70 2e 00       	push   $0x2e7008
f0100912:	68 08 70 2e f0       	push   $0xf02e7008
f0100917:	68 34 73 10 f0       	push   $0xf0107334
f010091c:	e8 78 36 00 00       	call   f0103f99 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100921:	b8 07 74 2e f0       	mov    $0xf02e7407,%eax
f0100926:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f010092b:	83 c4 08             	add    $0x8,%esp
f010092e:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100933:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100939:	85 c0                	test   %eax,%eax
f010093b:	0f 48 c2             	cmovs  %edx,%eax
f010093e:	c1 f8 0a             	sar    $0xa,%eax
f0100941:	50                   	push   %eax
f0100942:	68 58 73 10 f0       	push   $0xf0107358
f0100947:	e8 4d 36 00 00       	call   f0103f99 <cprintf>
	return 0;
}
f010094c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100951:	c9                   	leave  
f0100952:	c3                   	ret    

f0100953 <mon_showmap>:
	}
	return 0;
}

int 
mon_showmap(int argc, char **argv, struct Trapframe *tf) {
f0100953:	55                   	push   %ebp
f0100954:	89 e5                	mov    %esp,%ebp
f0100956:	56                   	push   %esi
f0100957:	53                   	push   %ebx
f0100958:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc <= 2) {
f010095b:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f010095f:	7f 15                	jg     f0100976 <mon_showmap+0x23>
		cprintf("Usage: showmap l r\n");
f0100961:	83 ec 0c             	sub    $0xc,%esp
f0100964:	68 62 71 10 f0       	push   $0xf0107162
f0100969:	e8 2b 36 00 00       	call   f0103f99 <cprintf>
		return 0;
f010096e:	83 c4 10             	add    $0x10,%esp
f0100971:	e9 a6 00 00 00       	jmp    f0100a1c <mon_showmap+0xc9>
	}
	uintptr_t l = strtoul(argv[1], NULL, 0), 
f0100976:	83 ec 04             	sub    $0x4,%esp
f0100979:	6a 00                	push   $0x0
f010097b:	6a 00                	push   $0x0
f010097d:	ff 76 04             	pushl  0x4(%esi)
f0100980:	e8 95 58 00 00       	call   f010621a <strtoul>
f0100985:	89 c3                	mov    %eax,%ebx
		 	  r = strtoul(argv[2], NULL, 0); // In string.h
f0100987:	83 c4 0c             	add    $0xc,%esp
f010098a:	6a 00                	push   $0x0
f010098c:	6a 00                	push   $0x0
f010098e:	ff 76 08             	pushl  0x8(%esi)
f0100991:	e8 84 58 00 00       	call   f010621a <strtoul>
	if (l > r) {
f0100996:	83 c4 10             	add    $0x10,%esp
f0100999:	39 c3                	cmp    %eax,%ebx
f010099b:	76 12                	jbe    f01009af <mon_showmap+0x5c>
		cprintf("Invalid range; aborting.\n");
f010099d:	83 ec 0c             	sub    $0xc,%esp
f01009a0:	68 76 71 10 f0       	push   $0xf0107176
f01009a5:	e8 ef 35 00 00       	call   f0103f99 <cprintf>
		return 0;
f01009aa:	83 c4 10             	add    $0x10,%esp
f01009ad:	eb 6d                	jmp    f0100a1c <mon_showmap+0xc9>
	}
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f01009af:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f01009b5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f01009bb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009c0:	89 c6                	mov    %eax,%esi
f01009c2:	eb 54                	jmp    f0100a18 <mon_showmap+0xc5>
		pte_t* pte = pgdir_walk(kern_pgdir, (void*) sz, 0);
f01009c4:	83 ec 04             	sub    $0x4,%esp
f01009c7:	6a 00                	push   $0x0
f01009c9:	53                   	push   %ebx
f01009ca:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f01009d0:	e8 31 0b 00 00       	call   f0101506 <pgdir_walk>
		if (pte == NULL || !*pte)
f01009d5:	83 c4 10             	add    $0x10,%esp
f01009d8:	85 c0                	test   %eax,%eax
f01009da:	74 06                	je     f01009e2 <mon_showmap+0x8f>
f01009dc:	8b 10                	mov    (%eax),%edx
f01009de:	85 d2                	test   %edx,%edx
f01009e0:	75 13                	jne    f01009f5 <mon_showmap+0xa2>
			cprintf("0x%08x -> ----------; perm = ---\n", sz);
f01009e2:	83 ec 08             	sub    $0x8,%esp
f01009e5:	53                   	push   %ebx
f01009e6:	68 84 73 10 f0       	push   $0xf0107384
f01009eb:	e8 a9 35 00 00       	call   f0103f99 <cprintf>
f01009f0:	83 c4 10             	add    $0x10,%esp
f01009f3:	eb 1d                	jmp    f0100a12 <mon_showmap+0xbf>
		else 
			cprintf("0x%08x -> 0x%08x; perm = 0x%03x\n", 
f01009f5:	89 d0                	mov    %edx,%eax
f01009f7:	25 ff 0f 00 00       	and    $0xfff,%eax
f01009fc:	50                   	push   %eax
f01009fd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a03:	52                   	push   %edx
f0100a04:	53                   	push   %ebx
f0100a05:	68 a8 73 10 f0       	push   $0xf01073a8
f0100a0a:	e8 8a 35 00 00       	call   f0103f99 <cprintf>
f0100a0f:	83 c4 10             	add    $0x10,%esp
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f0100a12:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100a18:	39 f3                	cmp    %esi,%ebx
f0100a1a:	76 a8                	jbe    f01009c4 <mon_showmap+0x71>
					sz, PTE_ADDR(*pte), *pte & 0xFFF);
	}
	return 0;
}
f0100a1c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a21:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100a24:	5b                   	pop    %ebx
f0100a25:	5e                   	pop    %esi
f0100a26:	5d                   	pop    %ebp
f0100a27:	c3                   	ret    

f0100a28 <mon_chmod>:

int
mon_chmod(int argc, char **argv, struct Trapframe *tf) {
f0100a28:	55                   	push   %ebp
f0100a29:	89 e5                	mov    %esp,%ebp
f0100a2b:	57                   	push   %edi
f0100a2c:	56                   	push   %esi
f0100a2d:	53                   	push   %ebx
f0100a2e:	83 ec 1c             	sub    $0x1c,%esp
f0100a31:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100a34:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc <= 2) {
f0100a37:	83 ff 02             	cmp    $0x2,%edi
f0100a3a:	7f 15                	jg     f0100a51 <mon_chmod+0x29>
		cprintf("Usage: chmod mod l [r] [-v]\n");
f0100a3c:	83 ec 0c             	sub    $0xc,%esp
f0100a3f:	68 90 71 10 f0       	push   $0xf0107190
f0100a44:	e8 50 35 00 00       	call   f0103f99 <cprintf>
		return 0;
f0100a49:	83 c4 10             	add    $0x10,%esp
f0100a4c:	e9 4e 01 00 00       	jmp    f0100b9f <mon_chmod+0x177>
	}
	uintptr_t mod = strtoul(argv[1], NULL, 0),  
f0100a51:	83 ec 04             	sub    $0x4,%esp
f0100a54:	6a 00                	push   $0x0
f0100a56:	6a 00                	push   $0x0
f0100a58:	ff 76 04             	pushl  0x4(%esi)
f0100a5b:	e8 ba 57 00 00       	call   f010621a <strtoul>
f0100a60:	89 45 e0             	mov    %eax,-0x20(%ebp)
			  l = strtoul(argv[2], NULL, 0), 
f0100a63:	83 c4 0c             	add    $0xc,%esp
f0100a66:	6a 00                	push   $0x0
f0100a68:	6a 00                	push   $0x0
f0100a6a:	ff 76 08             	pushl  0x8(%esi)
f0100a6d:	e8 a8 57 00 00       	call   f010621a <strtoul>
f0100a72:	89 c3                	mov    %eax,%ebx
			  r = argc >= 4 ? strtoul(argv[3], NULL, 0) : l;
f0100a74:	83 c4 10             	add    $0x10,%esp
f0100a77:	83 ff 03             	cmp    $0x3,%edi
f0100a7a:	0f 8e 05 01 00 00    	jle    f0100b85 <mon_chmod+0x15d>
f0100a80:	83 ec 04             	sub    $0x4,%esp
f0100a83:	6a 00                	push   $0x0
f0100a85:	6a 00                	push   $0x0
f0100a87:	ff 76 0c             	pushl  0xc(%esi)
f0100a8a:	e8 8b 57 00 00       	call   f010621a <strtoul>
f0100a8f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
f0100a92:	83 c4 08             	add    $0x8,%esp
f0100a95:	68 ad 71 10 f0       	push   $0xf01071ad
f0100a9a:	ff 76 0c             	pushl  0xc(%esi)
f0100a9d:	e8 db 54 00 00       	call   f0105f7d <strcmp>
f0100aa2:	83 c4 10             	add    $0x10,%esp
f0100aa5:	85 c0                	test   %eax,%eax
f0100aa7:	0f 94 c0             	sete   %al
f0100aaa:	0f b6 c0             	movzbl %al,%eax
f0100aad:	89 c7                	mov    %eax,%edi
	if (mod > 0xFFF) {
f0100aaf:	81 7d e0 ff 0f 00 00 	cmpl   $0xfff,-0x20(%ebp)
f0100ab6:	76 15                	jbe    f0100acd <mon_chmod+0xa5>
		cprintf("Permission exceeds 0xfff; aborting.\n");
f0100ab8:	83 ec 0c             	sub    $0xc,%esp
f0100abb:	68 cc 73 10 f0       	push   $0xf01073cc
f0100ac0:	e8 d4 34 00 00       	call   f0103f99 <cprintf>
		return 0;
f0100ac5:	83 c4 10             	add    $0x10,%esp
f0100ac8:	e9 d2 00 00 00       	jmp    f0100b9f <mon_chmod+0x177>
	}
	if (l > r) {
f0100acd:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0100ad0:	76 15                	jbe    f0100ae7 <mon_chmod+0xbf>
		cprintf("Invalid range; aborting.\n");
f0100ad2:	83 ec 0c             	sub    $0xc,%esp
f0100ad5:	68 76 71 10 f0       	push   $0xf0107176
f0100ada:	e8 ba 34 00 00       	call   f0103f99 <cprintf>
		return 0;
f0100adf:	83 c4 10             	add    $0x10,%esp
f0100ae2:	e9 b8 00 00 00       	jmp    f0100b9f <mon_chmod+0x177>
	}
	if (!(mod & PTE_P)) {
f0100ae7:	f6 45 e0 01          	testb  $0x1,-0x20(%ebp)
f0100aeb:	75 14                	jne    f0100b01 <mon_chmod+0xd9>
		cprintf("Warning: PTE_P flag is not provided; added automatically.");
f0100aed:	83 ec 0c             	sub    $0xc,%esp
f0100af0:	68 f4 73 10 f0       	push   $0xf01073f4
f0100af5:	e8 9f 34 00 00       	call   f0103f99 <cprintf>
		mod |= PTE_P;
f0100afa:	83 4d e0 01          	orl    $0x1,-0x20(%ebp)
f0100afe:	83 c4 10             	add    $0x10,%esp
	}
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f0100b01:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f0100b07:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0100b0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b10:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b15:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100b18:	eb 64                	jmp    f0100b7e <mon_chmod+0x156>
		pte_t* pte = pgdir_walk(kern_pgdir, (void*) sz, 0);
f0100b1a:	83 ec 04             	sub    $0x4,%esp
f0100b1d:	6a 00                	push   $0x0
f0100b1f:	53                   	push   %ebx
f0100b20:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f0100b26:	e8 db 09 00 00       	call   f0101506 <pgdir_walk>
f0100b2b:	89 c6                	mov    %eax,%esi
		if (pte == NULL || !*pte) {
f0100b2d:	83 c4 10             	add    $0x10,%esp
f0100b30:	85 c0                	test   %eax,%eax
f0100b32:	74 06                	je     f0100b3a <mon_chmod+0x112>
f0100b34:	8b 00                	mov    (%eax),%eax
f0100b36:	85 c0                	test   %eax,%eax
f0100b38:	75 17                	jne    f0100b51 <mon_chmod+0x129>
			if (verbose)
f0100b3a:	85 ff                	test   %edi,%edi
f0100b3c:	74 3a                	je     f0100b78 <mon_chmod+0x150>
				cprintf("Page va = 0x%08x is not mapped; skipping.\n", sz);
f0100b3e:	83 ec 08             	sub    $0x8,%esp
f0100b41:	53                   	push   %ebx
f0100b42:	68 30 74 10 f0       	push   $0xf0107430
f0100b47:	e8 4d 34 00 00       	call   f0103f99 <cprintf>
f0100b4c:	83 c4 10             	add    $0x10,%esp
f0100b4f:	eb 27                	jmp    f0100b78 <mon_chmod+0x150>
		}
		else {
			if (verbose) 
f0100b51:	85 ff                	test   %edi,%edi
f0100b53:	74 17                	je     f0100b6c <mon_chmod+0x144>
				cprintf("Page va = 0x%08x perm = 0x%03x changed to 0x%03x\n", 
f0100b55:	ff 75 e0             	pushl  -0x20(%ebp)
f0100b58:	25 ff 0f 00 00       	and    $0xfff,%eax
f0100b5d:	50                   	push   %eax
f0100b5e:	53                   	push   %ebx
f0100b5f:	68 5c 74 10 f0       	push   $0xf010745c
f0100b64:	e8 30 34 00 00       	call   f0103f99 <cprintf>
f0100b69:	83 c4 10             	add    $0x10,%esp
						sz, *pte & 0xFFF, mod);
			*pte = PTE_ADDR(*pte) | mod;
f0100b6c:	8b 06                	mov    (%esi),%eax
f0100b6e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b73:	0b 45 e0             	or     -0x20(%ebp),%eax
f0100b76:	89 06                	mov    %eax,(%esi)
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f0100b78:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100b7e:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0100b81:	76 97                	jbe    f0100b1a <mon_chmod+0xf2>
f0100b83:	eb 1a                	jmp    f0100b9f <mon_chmod+0x177>
	if (mod > 0xFFF) {
f0100b85:	81 7d e0 ff 0f 00 00 	cmpl   $0xfff,-0x20(%ebp)
f0100b8c:	0f 87 26 ff ff ff    	ja     f0100ab8 <mon_chmod+0x90>
			  r = argc >= 4 ? strtoul(argv[3], NULL, 0) : l;
f0100b92:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
f0100b95:	bf 00 00 00 00       	mov    $0x0,%edi
f0100b9a:	e9 48 ff ff ff       	jmp    f0100ae7 <mon_chmod+0xbf>
		}
	}
	return 0;
}
f0100b9f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ba4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ba7:	5b                   	pop    %ebx
f0100ba8:	5e                   	pop    %esi
f0100ba9:	5f                   	pop    %edi
f0100baa:	5d                   	pop    %ebp
f0100bab:	c3                   	ret    

f0100bac <mon_dump>:

int
mon_dump(int argc, char **argv, struct Trapframe *tf) {
f0100bac:	55                   	push   %ebp
f0100bad:	89 e5                	mov    %esp,%ebp
f0100baf:	57                   	push   %edi
f0100bb0:	56                   	push   %esi
f0100bb1:	53                   	push   %ebx
f0100bb2:	83 ec 1c             	sub    $0x1c,%esp
f0100bb5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (argc <= 2 || argc > 4) {
f0100bb8:	8d 43 fd             	lea    -0x3(%ebx),%eax
f0100bbb:	83 f8 01             	cmp    $0x1,%eax
f0100bbe:	76 15                	jbe    f0100bd5 <mon_dump+0x29>
		cprintf("Usage: dump l r [-v/-p]\n");
f0100bc0:	83 ec 0c             	sub    $0xc,%esp
f0100bc3:	68 b0 71 10 f0       	push   $0xf01071b0
f0100bc8:	e8 cc 33 00 00       	call   f0103f99 <cprintf>
		return 0;
f0100bcd:	83 c4 10             	add    $0x10,%esp
f0100bd0:	e9 c4 01 00 00       	jmp    f0100d99 <mon_dump+0x1ed>
	}
	unsigned long l = strtoul(argv[1], NULL, 0),
f0100bd5:	83 ec 04             	sub    $0x4,%esp
f0100bd8:	6a 00                	push   $0x0
f0100bda:	6a 00                	push   $0x0
f0100bdc:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100bdf:	ff 70 04             	pushl  0x4(%eax)
f0100be2:	e8 33 56 00 00       	call   f010621a <strtoul>
f0100be7:	89 c6                	mov    %eax,%esi
			  	  r = strtoul(argv[2], NULL, 0);
f0100be9:	83 c4 0c             	add    $0xc,%esp
f0100bec:	6a 00                	push   $0x0
f0100bee:	6a 00                	push   $0x0
f0100bf0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100bf3:	ff 70 08             	pushl  0x8(%eax)
f0100bf6:	e8 1f 56 00 00       	call   f010621a <strtoul>
f0100bfb:	89 c7                	mov    %eax,%edi
	int virtual;  // If 0 then physical
	if (argc <= 3)
f0100bfd:	83 c4 10             	add    $0x10,%esp
f0100c00:	83 fb 03             	cmp    $0x3,%ebx
f0100c03:	7f 15                	jg     f0100c1a <mon_dump+0x6e>
		cprintf("Defaulting to virtual address.\n");
f0100c05:	83 ec 0c             	sub    $0xc,%esp
f0100c08:	68 90 74 10 f0       	push   $0xf0107490
f0100c0d:	e8 87 33 00 00       	call   f0103f99 <cprintf>
f0100c12:	83 c4 10             	add    $0x10,%esp
f0100c15:	e9 9e 00 00 00       	jmp    f0100cb8 <mon_dump+0x10c>
	else if (!strcmp(argv[3], "-p"))
f0100c1a:	83 ec 08             	sub    $0x8,%esp
f0100c1d:	68 c9 71 10 f0       	push   $0xf01071c9
f0100c22:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c25:	ff 70 0c             	pushl  0xc(%eax)
f0100c28:	e8 50 53 00 00       	call   f0105f7d <strcmp>
f0100c2d:	83 c4 10             	add    $0x10,%esp
f0100c30:	85 c0                	test   %eax,%eax
f0100c32:	75 4f                	jne    f0100c83 <mon_dump+0xd7>
	if (PGNUM(pa) >= npages)
f0100c34:	a1 88 5e 2a f0       	mov    0xf02a5e88,%eax
f0100c39:	89 f2                	mov    %esi,%edx
f0100c3b:	c1 ea 0c             	shr    $0xc,%edx
f0100c3e:	39 c2                	cmp    %eax,%edx
f0100c40:	72 15                	jb     f0100c57 <mon_dump+0xab>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c42:	56                   	push   %esi
f0100c43:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0100c48:	68 9d 00 00 00       	push   $0x9d
f0100c4d:	68 cc 71 10 f0       	push   $0xf01071cc
f0100c52:	e8 3d f4 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0100c57:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
	if (PGNUM(pa) >= npages)
f0100c5d:	89 fa                	mov    %edi,%edx
f0100c5f:	c1 ea 0c             	shr    $0xc,%edx
f0100c62:	39 c2                	cmp    %eax,%edx
f0100c64:	72 15                	jb     f0100c7b <mon_dump+0xcf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c66:	57                   	push   %edi
f0100c67:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0100c6c:	68 9d 00 00 00       	push   $0x9d
f0100c71:	68 cc 71 10 f0       	push   $0xf01071cc
f0100c76:	e8 19 f4 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0100c7b:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
f0100c81:	eb 35                	jmp    f0100cb8 <mon_dump+0x10c>
		l = (unsigned long)KADDR(l), r = (unsigned long)KADDR(r);
	else if (strcmp(argv[3], "-v")) {
f0100c83:	83 ec 08             	sub    $0x8,%esp
f0100c86:	68 ad 71 10 f0       	push   $0xf01071ad
f0100c8b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c8e:	ff 70 0c             	pushl  0xc(%eax)
f0100c91:	e8 e7 52 00 00       	call   f0105f7d <strcmp>
f0100c96:	83 c4 10             	add    $0x10,%esp
f0100c99:	85 c0                	test   %eax,%eax
f0100c9b:	74 1b                	je     f0100cb8 <mon_dump+0x10c>
		cprintf("Unknown flag %s at position 3; aborting.\n", argv[3]);
f0100c9d:	83 ec 08             	sub    $0x8,%esp
f0100ca0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100ca3:	ff 70 0c             	pushl  0xc(%eax)
f0100ca6:	68 b0 74 10 f0       	push   $0xf01074b0
f0100cab:	e8 e9 32 00 00       	call   f0103f99 <cprintf>
		return 0;
f0100cb0:	83 c4 10             	add    $0x10,%esp
f0100cb3:	e9 e1 00 00 00       	jmp    f0100d99 <mon_dump+0x1ed>
	}
	uintptr_t ptr;
	for (ptr = ROUNDDOWN(l, 16); ptr <= r; ptr += 16) {
f0100cb8:	83 e6 f0             	and    $0xfffffff0,%esi
f0100cbb:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0100cbe:	83 c6 10             	add    $0x10,%esi
f0100cc1:	e9 b1 00 00 00       	jmp    f0100d77 <mon_dump+0x1cb>
		cprintf("%08x  ", ptr);
f0100cc6:	83 ec 08             	sub    $0x8,%esp
f0100cc9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100ccc:	53                   	push   %ebx
f0100ccd:	68 db 71 10 f0       	push   $0xf01071db
f0100cd2:	e8 c2 32 00 00       	call   f0103f99 <cprintf>
f0100cd7:	83 c4 10             	add    $0x10,%esp
		for (int i = 0; i < 16; i++) {
			if (ptr + i <= r)
f0100cda:	39 df                	cmp    %ebx,%edi
f0100cdc:	72 16                	jb     f0100cf4 <mon_dump+0x148>
				cprintf("%02x ", *(unsigned char*)(ptr + i));
f0100cde:	83 ec 08             	sub    $0x8,%esp
f0100ce1:	0f b6 03             	movzbl (%ebx),%eax
f0100ce4:	50                   	push   %eax
f0100ce5:	68 e2 71 10 f0       	push   $0xf01071e2
f0100cea:	e8 aa 32 00 00       	call   f0103f99 <cprintf>
f0100cef:	83 c4 10             	add    $0x10,%esp
f0100cf2:	eb 10                	jmp    f0100d04 <mon_dump+0x158>
			else 
				cprintf("   ");
f0100cf4:	83 ec 0c             	sub    $0xc,%esp
f0100cf7:	68 e8 71 10 f0       	push   $0xf01071e8
f0100cfc:	e8 98 32 00 00       	call   f0103f99 <cprintf>
f0100d01:	83 c4 10             	add    $0x10,%esp
f0100d04:	83 c3 01             	add    $0x1,%ebx
		for (int i = 0; i < 16; i++) {
f0100d07:	39 f3                	cmp    %esi,%ebx
f0100d09:	75 cf                	jne    f0100cda <mon_dump+0x12e>
		}
		cprintf(" |");
f0100d0b:	83 ec 0c             	sub    $0xc,%esp
f0100d0e:	68 ec 71 10 f0       	push   $0xf01071ec
f0100d13:	e8 81 32 00 00       	call   f0103f99 <cprintf>
f0100d18:	83 c4 10             	add    $0x10,%esp
f0100d1b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		for (int i = 0; i < 16; i++) {
			if (ptr + i <= r) {
f0100d1e:	39 df                	cmp    %ebx,%edi
f0100d20:	72 27                	jb     f0100d49 <mon_dump+0x19d>
				char ch = *(char*)(ptr + i);
f0100d22:	0f b6 03             	movzbl (%ebx),%eax
				cprintf("%c", (ch >= ' ' && ch <= '~') ? ch : '.');
f0100d25:	8d 50 e0             	lea    -0x20(%eax),%edx
f0100d28:	0f be c0             	movsbl %al,%eax
f0100d2b:	80 fa 5e             	cmp    $0x5e,%dl
f0100d2e:	b9 2e 00 00 00       	mov    $0x2e,%ecx
f0100d33:	0f 47 c1             	cmova  %ecx,%eax
f0100d36:	83 ec 08             	sub    $0x8,%esp
f0100d39:	50                   	push   %eax
f0100d3a:	68 ef 71 10 f0       	push   $0xf01071ef
f0100d3f:	e8 55 32 00 00       	call   f0103f99 <cprintf>
f0100d44:	83 c4 10             	add    $0x10,%esp
f0100d47:	eb 10                	jmp    f0100d59 <mon_dump+0x1ad>
			}
			else 
				cprintf(" ");
f0100d49:	83 ec 0c             	sub    $0xc,%esp
f0100d4c:	68 2c 72 10 f0       	push   $0xf010722c
f0100d51:	e8 43 32 00 00       	call   f0103f99 <cprintf>
f0100d56:	83 c4 10             	add    $0x10,%esp
f0100d59:	83 c3 01             	add    $0x1,%ebx
		for (int i = 0; i < 16; i++) {
f0100d5c:	39 f3                	cmp    %esi,%ebx
f0100d5e:	75 be                	jne    f0100d1e <mon_dump+0x172>
		}
		cprintf("|\n");
f0100d60:	83 ec 0c             	sub    $0xc,%esp
f0100d63:	68 f2 71 10 f0       	push   $0xf01071f2
f0100d68:	e8 2c 32 00 00       	call   f0103f99 <cprintf>
	for (ptr = ROUNDDOWN(l, 16); ptr <= r; ptr += 16) {
f0100d6d:	83 45 e4 10          	addl   $0x10,-0x1c(%ebp)
f0100d71:	83 c6 10             	add    $0x10,%esi
f0100d74:	83 c4 10             	add    $0x10,%esp
f0100d77:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0100d7a:	0f 83 46 ff ff ff    	jae    f0100cc6 <mon_dump+0x11a>
	}
	if (ROUNDDOWN(r, 16) != r)
f0100d80:	f7 c7 0f 00 00 00    	test   $0xf,%edi
f0100d86:	74 11                	je     f0100d99 <mon_dump+0x1ed>
		cprintf("%08x  \n", r);
f0100d88:	83 ec 08             	sub    $0x8,%esp
f0100d8b:	57                   	push   %edi
f0100d8c:	68 f5 71 10 f0       	push   $0xf01071f5
f0100d91:	e8 03 32 00 00       	call   f0103f99 <cprintf>
f0100d96:	83 c4 10             	add    $0x10,%esp
	return 0;
}
f0100d99:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100da1:	5b                   	pop    %ebx
f0100da2:	5e                   	pop    %esi
f0100da3:	5f                   	pop    %edi
f0100da4:	5d                   	pop    %ebp
f0100da5:	c3                   	ret    

f0100da6 <mon_backtrace>:
{
f0100da6:	55                   	push   %ebp
f0100da7:	89 e5                	mov    %esp,%ebp
f0100da9:	57                   	push   %edi
f0100daa:	56                   	push   %esi
f0100dab:	53                   	push   %ebx
f0100dac:	83 ec 38             	sub    $0x38,%esp
	cprintf("Stack backtrace:\n");
f0100daf:	68 fd 71 10 f0       	push   $0xf01071fd
f0100db4:	e8 e0 31 00 00       	call   f0103f99 <cprintf>
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100db9:	89 e8                	mov    %ebp,%eax
	while (ebp != 0) {
f0100dbb:	83 c4 10             	add    $0x10,%esp
f0100dbe:	e9 80 00 00 00       	jmp    f0100e43 <mon_backtrace+0x9d>
		prev_ebp = *(int*)ebp;
f0100dc3:	8b 38                	mov    (%eax),%edi
		eip = *((int*)ebp + 1);
f0100dc5:	8b 70 04             	mov    0x4(%eax),%esi
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, 
f0100dc8:	ff 70 18             	pushl  0x18(%eax)
f0100dcb:	ff 70 14             	pushl  0x14(%eax)
f0100dce:	ff 70 10             	pushl  0x10(%eax)
f0100dd1:	ff 70 0c             	pushl  0xc(%eax)
f0100dd4:	ff 70 08             	pushl  0x8(%eax)
f0100dd7:	56                   	push   %esi
f0100dd8:	50                   	push   %eax
f0100dd9:	68 dc 74 10 f0       	push   $0xf01074dc
f0100dde:	e8 b6 31 00 00       	call   f0103f99 <cprintf>
		int code = debuginfo_eip((uintptr_t)eip, &info);
f0100de3:	83 c4 18             	add    $0x18,%esp
f0100de6:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100de9:	50                   	push   %eax
f0100dea:	56                   	push   %esi
f0100deb:	e8 b2 47 00 00       	call   f01055a2 <debuginfo_eip>
		cprintf("         %s:%d: ", info.eip_file, info.eip_line);
f0100df0:	83 c4 0c             	add    $0xc,%esp
f0100df3:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100df6:	ff 75 d0             	pushl  -0x30(%ebp)
f0100df9:	68 0f 72 10 f0       	push   $0xf010720f
f0100dfe:	e8 96 31 00 00       	call   f0103f99 <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f0100e03:	83 c4 10             	add    $0x10,%esp
f0100e06:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e0b:	eb 1b                	jmp    f0100e28 <mon_backtrace+0x82>
			cprintf("%c", info.eip_fn_name[i]);
f0100e0d:	83 ec 08             	sub    $0x8,%esp
f0100e10:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e13:	0f be 04 18          	movsbl (%eax,%ebx,1),%eax
f0100e17:	50                   	push   %eax
f0100e18:	68 ef 71 10 f0       	push   $0xf01071ef
f0100e1d:	e8 77 31 00 00       	call   f0103f99 <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f0100e22:	83 c3 01             	add    $0x1,%ebx
f0100e25:	83 c4 10             	add    $0x10,%esp
f0100e28:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
f0100e2b:	7c e0                	jl     f0100e0d <mon_backtrace+0x67>
		cprintf("+%d\n", eip - info.eip_fn_addr);
f0100e2d:	83 ec 08             	sub    $0x8,%esp
f0100e30:	2b 75 e0             	sub    -0x20(%ebp),%esi
f0100e33:	56                   	push   %esi
f0100e34:	68 20 72 10 f0       	push   $0xf0107220
f0100e39:	e8 5b 31 00 00       	call   f0103f99 <cprintf>
f0100e3e:	83 c4 10             	add    $0x10,%esp
		ebp = prev_ebp;
f0100e41:	89 f8                	mov    %edi,%eax
	while (ebp != 0) {
f0100e43:	85 c0                	test   %eax,%eax
f0100e45:	0f 85 78 ff ff ff    	jne    f0100dc3 <mon_backtrace+0x1d>
}
f0100e4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e4e:	5b                   	pop    %ebx
f0100e4f:	5e                   	pop    %esi
f0100e50:	5f                   	pop    %edi
f0100e51:	5d                   	pop    %ebp
f0100e52:	c3                   	ret    

f0100e53 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100e53:	55                   	push   %ebp
f0100e54:	89 e5                	mov    %esp,%ebp
f0100e56:	57                   	push   %edi
f0100e57:	56                   	push   %esi
f0100e58:	53                   	push   %ebx
f0100e59:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100e5c:	68 14 75 10 f0       	push   $0xf0107514
f0100e61:	e8 33 31 00 00       	call   f0103f99 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100e66:	c7 04 24 38 75 10 f0 	movl   $0xf0107538,(%esp)
f0100e6d:	e8 27 31 00 00       	call   f0103f99 <cprintf>

	if (tf != NULL)
f0100e72:	83 c4 10             	add    $0x10,%esp
f0100e75:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100e79:	74 0e                	je     f0100e89 <monitor+0x36>
		print_trapframe(tf);
f0100e7b:	83 ec 0c             	sub    $0xc,%esp
f0100e7e:	ff 75 08             	pushl  0x8(%ebp)
f0100e81:	e8 43 38 00 00       	call   f01046c9 <print_trapframe>
f0100e86:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100e89:	83 ec 0c             	sub    $0xc,%esp
f0100e8c:	68 25 72 10 f0       	push   $0xf0107225
f0100e91:	e8 0d 4f 00 00       	call   f0105da3 <readline>
f0100e96:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100e98:	83 c4 10             	add    $0x10,%esp
f0100e9b:	85 c0                	test   %eax,%eax
f0100e9d:	74 ea                	je     f0100e89 <monitor+0x36>
	argv[argc] = 0;
f0100e9f:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100ea6:	be 00 00 00 00       	mov    $0x0,%esi
f0100eab:	eb 0a                	jmp    f0100eb7 <monitor+0x64>
			*buf++ = 0;
f0100ead:	c6 03 00             	movb   $0x0,(%ebx)
f0100eb0:	89 f7                	mov    %esi,%edi
f0100eb2:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100eb5:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100eb7:	0f b6 03             	movzbl (%ebx),%eax
f0100eba:	84 c0                	test   %al,%al
f0100ebc:	74 63                	je     f0100f21 <monitor+0xce>
f0100ebe:	83 ec 08             	sub    $0x8,%esp
f0100ec1:	0f be c0             	movsbl %al,%eax
f0100ec4:	50                   	push   %eax
f0100ec5:	68 29 72 10 f0       	push   $0xf0107229
f0100eca:	e8 0c 51 00 00       	call   f0105fdb <strchr>
f0100ecf:	83 c4 10             	add    $0x10,%esp
f0100ed2:	85 c0                	test   %eax,%eax
f0100ed4:	75 d7                	jne    f0100ead <monitor+0x5a>
		if (*buf == 0)
f0100ed6:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100ed9:	74 46                	je     f0100f21 <monitor+0xce>
		if (argc == MAXARGS-1) {
f0100edb:	83 fe 0f             	cmp    $0xf,%esi
f0100ede:	75 14                	jne    f0100ef4 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100ee0:	83 ec 08             	sub    $0x8,%esp
f0100ee3:	6a 10                	push   $0x10
f0100ee5:	68 2e 72 10 f0       	push   $0xf010722e
f0100eea:	e8 aa 30 00 00       	call   f0103f99 <cprintf>
f0100eef:	83 c4 10             	add    $0x10,%esp
f0100ef2:	eb 95                	jmp    f0100e89 <monitor+0x36>
		argv[argc++] = buf;
f0100ef4:	8d 7e 01             	lea    0x1(%esi),%edi
f0100ef7:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100efb:	eb 03                	jmp    f0100f00 <monitor+0xad>
			buf++;
f0100efd:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100f00:	0f b6 03             	movzbl (%ebx),%eax
f0100f03:	84 c0                	test   %al,%al
f0100f05:	74 ae                	je     f0100eb5 <monitor+0x62>
f0100f07:	83 ec 08             	sub    $0x8,%esp
f0100f0a:	0f be c0             	movsbl %al,%eax
f0100f0d:	50                   	push   %eax
f0100f0e:	68 29 72 10 f0       	push   $0xf0107229
f0100f13:	e8 c3 50 00 00       	call   f0105fdb <strchr>
f0100f18:	83 c4 10             	add    $0x10,%esp
f0100f1b:	85 c0                	test   %eax,%eax
f0100f1d:	74 de                	je     f0100efd <monitor+0xaa>
f0100f1f:	eb 94                	jmp    f0100eb5 <monitor+0x62>
	argv[argc] = 0;
f0100f21:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100f28:	00 
	if (argc == 0)
f0100f29:	85 f6                	test   %esi,%esi
f0100f2b:	0f 84 58 ff ff ff    	je     f0100e89 <monitor+0x36>
f0100f31:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f0100f36:	83 ec 08             	sub    $0x8,%esp
f0100f39:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100f3c:	ff 34 85 20 76 10 f0 	pushl  -0xfef89e0(,%eax,4)
f0100f43:	ff 75 a8             	pushl  -0x58(%ebp)
f0100f46:	e8 32 50 00 00       	call   f0105f7d <strcmp>
f0100f4b:	83 c4 10             	add    $0x10,%esp
f0100f4e:	85 c0                	test   %eax,%eax
f0100f50:	75 21                	jne    f0100f73 <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f0100f52:	83 ec 04             	sub    $0x4,%esp
f0100f55:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100f58:	ff 75 08             	pushl  0x8(%ebp)
f0100f5b:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100f5e:	52                   	push   %edx
f0100f5f:	56                   	push   %esi
f0100f60:	ff 14 85 28 76 10 f0 	call   *-0xfef89d8(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100f67:	83 c4 10             	add    $0x10,%esp
f0100f6a:	85 c0                	test   %eax,%eax
f0100f6c:	78 25                	js     f0100f93 <monitor+0x140>
f0100f6e:	e9 16 ff ff ff       	jmp    f0100e89 <monitor+0x36>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100f73:	83 c3 01             	add    $0x1,%ebx
f0100f76:	83 fb 05             	cmp    $0x5,%ebx
f0100f79:	75 bb                	jne    f0100f36 <monitor+0xe3>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100f7b:	83 ec 08             	sub    $0x8,%esp
f0100f7e:	ff 75 a8             	pushl  -0x58(%ebp)
f0100f81:	68 4b 72 10 f0       	push   $0xf010724b
f0100f86:	e8 0e 30 00 00       	call   f0103f99 <cprintf>
f0100f8b:	83 c4 10             	add    $0x10,%esp
f0100f8e:	e9 f6 fe ff ff       	jmp    f0100e89 <monitor+0x36>
				break;
	}
}
f0100f93:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f96:	5b                   	pop    %ebx
f0100f97:	5e                   	pop    %esi
f0100f98:	5f                   	pop    %edi
f0100f99:	5d                   	pop    %ebp
f0100f9a:	c3                   	ret    

f0100f9b <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100f9b:	55                   	push   %ebp
f0100f9c:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100f9e:	83 3d 38 52 2a f0 00 	cmpl   $0x0,0xf02a5238
f0100fa5:	74 1f                	je     f0100fc6 <boot_alloc+0x2b>
	}

	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	if (!n)
f0100fa7:	85 c0                	test   %eax,%eax
f0100fa9:	74 2e                	je     f0100fd9 <boot_alloc+0x3e>
		return (void*)nextfree;
	else {
		result = nextfree;
f0100fab:	8b 15 38 52 2a f0    	mov    0xf02a5238,%edx
		nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100fb1:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100fb8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100fbd:	a3 38 52 2a f0       	mov    %eax,0xf02a5238
		return (void*)result;
	}
}
f0100fc2:	89 d0                	mov    %edx,%eax
f0100fc4:	5d                   	pop    %ebp
f0100fc5:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100fc6:	ba 07 80 2e f0       	mov    $0xf02e8007,%edx
f0100fcb:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100fd1:	89 15 38 52 2a f0    	mov    %edx,0xf02a5238
f0100fd7:	eb ce                	jmp    f0100fa7 <boot_alloc+0xc>
		return (void*)nextfree;
f0100fd9:	8b 15 38 52 2a f0    	mov    0xf02a5238,%edx
f0100fdf:	eb e1                	jmp    f0100fc2 <boot_alloc+0x27>

f0100fe1 <nvram_read>:
{
f0100fe1:	55                   	push   %ebp
f0100fe2:	89 e5                	mov    %esp,%ebp
f0100fe4:	56                   	push   %esi
f0100fe5:	53                   	push   %ebx
f0100fe6:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100fe8:	83 ec 0c             	sub    $0xc,%esp
f0100feb:	50                   	push   %eax
f0100fec:	e8 29 2e 00 00       	call   f0103e1a <mc146818_read>
f0100ff1:	89 c3                	mov    %eax,%ebx
f0100ff3:	46                   	inc    %esi
f0100ff4:	89 34 24             	mov    %esi,(%esp)
f0100ff7:	e8 1e 2e 00 00       	call   f0103e1a <mc146818_read>
f0100ffc:	c1 e0 08             	shl    $0x8,%eax
f0100fff:	09 d8                	or     %ebx,%eax
}
f0101001:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101004:	5b                   	pop    %ebx
f0101005:	5e                   	pop    %esi
f0101006:	5d                   	pop    %ebp
f0101007:	c3                   	ret    

f0101008 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0101008:	89 d1                	mov    %edx,%ecx
f010100a:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f010100d:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0101010:	a8 01                	test   $0x1,%al
f0101012:	74 47                	je     f010105b <check_va2pa+0x53>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0101014:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101019:	89 c1                	mov    %eax,%ecx
f010101b:	c1 e9 0c             	shr    $0xc,%ecx
f010101e:	3b 0d 88 5e 2a f0    	cmp    0xf02a5e88,%ecx
f0101024:	73 1a                	jae    f0101040 <check_va2pa+0x38>
	if (!(p[PTX(va)] & PTE_P))
f0101026:	c1 ea 0c             	shr    $0xc,%edx
f0101029:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010102f:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0101036:	a8 01                	test   $0x1,%al
f0101038:	74 27                	je     f0101061 <check_va2pa+0x59>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f010103a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010103f:	c3                   	ret    
{
f0101040:	55                   	push   %ebp
f0101041:	89 e5                	mov    %esp,%ebp
f0101043:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101046:	50                   	push   %eax
f0101047:	68 a8 6e 10 f0       	push   $0xf0106ea8
f010104c:	68 6f 03 00 00       	push   $0x36f
f0101051:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101056:	e8 39 f0 ff ff       	call   f0100094 <_panic>
		return ~0;
f010105b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101060:	c3                   	ret    
		return ~0;
f0101061:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0101066:	c3                   	ret    

f0101067 <check_page_free_list>:
{
f0101067:	55                   	push   %ebp
f0101068:	89 e5                	mov    %esp,%ebp
f010106a:	57                   	push   %edi
f010106b:	56                   	push   %esi
f010106c:	53                   	push   %ebx
f010106d:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101070:	84 c0                	test   %al,%al
f0101072:	0f 85 80 02 00 00    	jne    f01012f8 <check_page_free_list+0x291>
	if (!page_free_list)
f0101078:	83 3d 40 52 2a f0 00 	cmpl   $0x0,0xf02a5240
f010107f:	74 0a                	je     f010108b <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101081:	be 00 04 00 00       	mov    $0x400,%esi
f0101086:	e9 c8 02 00 00       	jmp    f0101353 <check_page_free_list+0x2ec>
		panic("'page_free_list' is a null pointer!");
f010108b:	83 ec 04             	sub    $0x4,%esp
f010108e:	68 5c 76 10 f0       	push   $0xf010765c
f0101093:	68 a2 02 00 00       	push   $0x2a2
f0101098:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010109d:	e8 f2 ef ff ff       	call   f0100094 <_panic>
f01010a2:	50                   	push   %eax
f01010a3:	68 a8 6e 10 f0       	push   $0xf0106ea8
f01010a8:	6a 58                	push   $0x58
f01010aa:	68 89 7f 10 f0       	push   $0xf0107f89
f01010af:	e8 e0 ef ff ff       	call   f0100094 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01010b4:	8b 1b                	mov    (%ebx),%ebx
f01010b6:	85 db                	test   %ebx,%ebx
f01010b8:	74 41                	je     f01010fb <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010ba:	89 d8                	mov    %ebx,%eax
f01010bc:	2b 05 90 5e 2a f0    	sub    0xf02a5e90,%eax
f01010c2:	c1 f8 03             	sar    $0x3,%eax
f01010c5:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f01010c8:	89 c2                	mov    %eax,%edx
f01010ca:	c1 ea 16             	shr    $0x16,%edx
f01010cd:	39 f2                	cmp    %esi,%edx
f01010cf:	73 e3                	jae    f01010b4 <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f01010d1:	89 c2                	mov    %eax,%edx
f01010d3:	c1 ea 0c             	shr    $0xc,%edx
f01010d6:	3b 15 88 5e 2a f0    	cmp    0xf02a5e88,%edx
f01010dc:	73 c4                	jae    f01010a2 <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f01010de:	83 ec 04             	sub    $0x4,%esp
f01010e1:	68 80 00 00 00       	push   $0x80
f01010e6:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f01010eb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010f0:	50                   	push   %eax
f01010f1:	e8 22 4f 00 00       	call   f0106018 <memset>
f01010f6:	83 c4 10             	add    $0x10,%esp
f01010f9:	eb b9                	jmp    f01010b4 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f01010fb:	b8 00 00 00 00       	mov    $0x0,%eax
f0101100:	e8 96 fe ff ff       	call   f0100f9b <boot_alloc>
f0101105:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101108:	8b 15 40 52 2a f0    	mov    0xf02a5240,%edx
		assert(pp >= pages);
f010110e:	8b 0d 90 5e 2a f0    	mov    0xf02a5e90,%ecx
		assert(pp < pages + npages);
f0101114:	a1 88 5e 2a f0       	mov    0xf02a5e88,%eax
f0101119:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010111c:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f010111f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101122:	89 4d d0             	mov    %ecx,-0x30(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0101125:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010112a:	e9 00 01 00 00       	jmp    f010122f <check_page_free_list+0x1c8>
		assert(pp >= pages);
f010112f:	68 97 7f 10 f0       	push   $0xf0107f97
f0101134:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101139:	68 bc 02 00 00       	push   $0x2bc
f010113e:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101143:	e8 4c ef ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0101148:	68 b8 7f 10 f0       	push   $0xf0107fb8
f010114d:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101152:	68 bd 02 00 00       	push   $0x2bd
f0101157:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010115c:	e8 33 ef ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101161:	68 80 76 10 f0       	push   $0xf0107680
f0101166:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010116b:	68 be 02 00 00       	push   $0x2be
f0101170:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101175:	e8 1a ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != 0);
f010117a:	68 cc 7f 10 f0       	push   $0xf0107fcc
f010117f:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101184:	68 c1 02 00 00       	push   $0x2c1
f0101189:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010118e:	e8 01 ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101193:	68 dd 7f 10 f0       	push   $0xf0107fdd
f0101198:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010119d:	68 c2 02 00 00       	push   $0x2c2
f01011a2:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01011a7:	e8 e8 ee ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01011ac:	68 b4 76 10 f0       	push   $0xf01076b4
f01011b1:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01011b6:	68 c3 02 00 00       	push   $0x2c3
f01011bb:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01011c0:	e8 cf ee ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01011c5:	68 f6 7f 10 f0       	push   $0xf0107ff6
f01011ca:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01011cf:	68 c4 02 00 00       	push   $0x2c4
f01011d4:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01011d9:	e8 b6 ee ff ff       	call   f0100094 <_panic>
	if (PGNUM(pa) >= npages)
f01011de:	89 c7                	mov    %eax,%edi
f01011e0:	c1 ef 0c             	shr    $0xc,%edi
f01011e3:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f01011e6:	76 19                	jbe    f0101201 <check_page_free_list+0x19a>
	return (void *)(pa + KERNBASE);
f01011e8:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01011ee:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f01011f1:	77 20                	ja     f0101213 <check_page_free_list+0x1ac>
		assert(page2pa(pp) != MPENTRY_PADDR);
f01011f3:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01011f8:	0f 84 92 00 00 00    	je     f0101290 <check_page_free_list+0x229>
			++nfree_extmem;
f01011fe:	43                   	inc    %ebx
f01011ff:	eb 2c                	jmp    f010122d <check_page_free_list+0x1c6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101201:	50                   	push   %eax
f0101202:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0101207:	6a 58                	push   $0x58
f0101209:	68 89 7f 10 f0       	push   $0xf0107f89
f010120e:	e8 81 ee ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101213:	68 d8 76 10 f0       	push   $0xf01076d8
f0101218:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010121d:	68 c5 02 00 00       	push   $0x2c5
f0101222:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101227:	e8 68 ee ff ff       	call   f0100094 <_panic>
			++nfree_basemem;
f010122c:	46                   	inc    %esi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010122d:	8b 12                	mov    (%edx),%edx
f010122f:	85 d2                	test   %edx,%edx
f0101231:	74 76                	je     f01012a9 <check_page_free_list+0x242>
		assert(pp >= pages);
f0101233:	39 d1                	cmp    %edx,%ecx
f0101235:	0f 87 f4 fe ff ff    	ja     f010112f <check_page_free_list+0xc8>
		assert(pp < pages + npages);
f010123b:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f010123e:	0f 86 04 ff ff ff    	jbe    f0101148 <check_page_free_list+0xe1>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101244:	89 d0                	mov    %edx,%eax
f0101246:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101249:	a8 07                	test   $0x7,%al
f010124b:	0f 85 10 ff ff ff    	jne    f0101161 <check_page_free_list+0xfa>
	return (pp - pages) << PGSHIFT;
f0101251:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0101254:	c1 e0 0c             	shl    $0xc,%eax
f0101257:	0f 84 1d ff ff ff    	je     f010117a <check_page_free_list+0x113>
		assert(page2pa(pp) != IOPHYSMEM);
f010125d:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101262:	0f 84 2b ff ff ff    	je     f0101193 <check_page_free_list+0x12c>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101268:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f010126d:	0f 84 39 ff ff ff    	je     f01011ac <check_page_free_list+0x145>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101273:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101278:	0f 84 47 ff ff ff    	je     f01011c5 <check_page_free_list+0x15e>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010127e:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101283:	0f 87 55 ff ff ff    	ja     f01011de <check_page_free_list+0x177>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101289:	3d 00 70 00 00       	cmp    $0x7000,%eax
f010128e:	75 9c                	jne    f010122c <check_page_free_list+0x1c5>
f0101290:	68 10 80 10 f0       	push   $0xf0108010
f0101295:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010129a:	68 c7 02 00 00       	push   $0x2c7
f010129f:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01012a4:	e8 eb ed ff ff       	call   f0100094 <_panic>
	assert(nfree_basemem > 0);
f01012a9:	85 f6                	test   %esi,%esi
f01012ab:	7e 19                	jle    f01012c6 <check_page_free_list+0x25f>
	assert(nfree_extmem > 0);
f01012ad:	85 db                	test   %ebx,%ebx
f01012af:	7e 2e                	jle    f01012df <check_page_free_list+0x278>
	cprintf("check_page_free_list() succeeded!\n");
f01012b1:	83 ec 0c             	sub    $0xc,%esp
f01012b4:	68 20 77 10 f0       	push   $0xf0107720
f01012b9:	e8 db 2c 00 00       	call   f0103f99 <cprintf>
}
f01012be:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012c1:	5b                   	pop    %ebx
f01012c2:	5e                   	pop    %esi
f01012c3:	5f                   	pop    %edi
f01012c4:	5d                   	pop    %ebp
f01012c5:	c3                   	ret    
	assert(nfree_basemem > 0);
f01012c6:	68 2d 80 10 f0       	push   $0xf010802d
f01012cb:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01012d0:	68 cf 02 00 00       	push   $0x2cf
f01012d5:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01012da:	e8 b5 ed ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f01012df:	68 3f 80 10 f0       	push   $0xf010803f
f01012e4:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01012e9:	68 d0 02 00 00       	push   $0x2d0
f01012ee:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01012f3:	e8 9c ed ff ff       	call   f0100094 <_panic>
	if (!page_free_list)
f01012f8:	a1 40 52 2a f0       	mov    0xf02a5240,%eax
f01012fd:	85 c0                	test   %eax,%eax
f01012ff:	0f 84 86 fd ff ff    	je     f010108b <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0101305:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0101308:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010130b:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010130e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101311:	89 c2                	mov    %eax,%edx
f0101313:	2b 15 90 5e 2a f0    	sub    0xf02a5e90,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit; 
f0101319:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f010131f:	0f 95 c2             	setne  %dl
f0101322:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0101325:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0101329:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f010132b:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f010132f:	8b 00                	mov    (%eax),%eax
f0101331:	85 c0                	test   %eax,%eax
f0101333:	75 dc                	jne    f0101311 <check_page_free_list+0x2aa>
		*tp[1] = 0;
f0101335:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101338:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f010133e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101341:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101344:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101346:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101349:	a3 40 52 2a f0       	mov    %eax,0xf02a5240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010134e:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101353:	8b 1d 40 52 2a f0    	mov    0xf02a5240,%ebx
f0101359:	e9 58 fd ff ff       	jmp    f01010b6 <check_page_free_list+0x4f>

f010135e <page_init>:
{
f010135e:	55                   	push   %ebp
f010135f:	89 e5                	mov    %esp,%ebp
f0101361:	57                   	push   %edi
f0101362:	56                   	push   %esi
f0101363:	53                   	push   %ebx
f0101364:	83 ec 1c             	sub    $0x1c,%esp
	physaddr_t free = (physaddr_t) PADDR(boot_alloc(0));
f0101367:	b8 00 00 00 00       	mov    $0x0,%eax
f010136c:	e8 2a fc ff ff       	call   f0100f9b <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0101371:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101376:	76 32                	jbe    f01013aa <page_init+0x4c>
	return (physaddr_t)kva - KERNBASE;
f0101378:	05 00 00 00 10       	add    $0x10000000,%eax
f010137d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	size_t core_code_end = MPENTRY_PADDR + mpentry_end - mpentry_start;
f0101380:	b8 72 d3 10 f0       	mov    $0xf010d372,%eax
f0101385:	2d f8 62 10 f0       	sub    $0xf01062f8,%eax
f010138a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if (i >= npages_basemem && len < free)
f010138d:	8b 1d 44 52 2a f0    	mov    0xf02a5244,%ebx
f0101393:	8b 0d 40 52 2a f0    	mov    0xf02a5240,%ecx
	for (i = 1, len = PGSIZE; i < npages; i++, len += PGSIZE) {
f0101399:	bf 00 00 00 00       	mov    $0x0,%edi
f010139e:	b8 01 00 00 00       	mov    $0x1,%eax
		page_free_list = &pages[i];
f01013a3:	be 01 00 00 00       	mov    $0x1,%esi
	for (i = 1, len = PGSIZE; i < npages; i++, len += PGSIZE) {
f01013a8:	eb 37                	jmp    f01013e1 <page_init+0x83>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013aa:	50                   	push   %eax
f01013ab:	68 cc 6e 10 f0       	push   $0xf0106ecc
f01013b0:	68 3e 01 00 00       	push   $0x13e
f01013b5:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01013ba:	e8 d5 ec ff ff       	call   f0100094 <_panic>
		pages[i].pp_ref = 0;
f01013bf:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01013c6:	89 d7                	mov    %edx,%edi
f01013c8:	03 3d 90 5e 2a f0    	add    0xf02a5e90,%edi
f01013ce:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
		pages[i].pp_link = page_free_list;
f01013d4:	89 0f                	mov    %ecx,(%edi)
		page_free_list = &pages[i];
f01013d6:	89 d1                	mov    %edx,%ecx
f01013d8:	03 0d 90 5e 2a f0    	add    0xf02a5e90,%ecx
f01013de:	89 f7                	mov    %esi,%edi
	for (i = 1, len = PGSIZE; i < npages; i++, len += PGSIZE) {
f01013e0:	40                   	inc    %eax
f01013e1:	39 05 88 5e 2a f0    	cmp    %eax,0xf02a5e88
f01013e7:	76 1d                	jbe    f0101406 <page_init+0xa8>
f01013e9:	89 c2                	mov    %eax,%edx
f01013eb:	c1 e2 0c             	shl    $0xc,%edx
		if (len >= MPENTRY_PADDR && len < core_code_end) // We're in multicore code
f01013ee:	81 fa ff 6f 00 00    	cmp    $0x6fff,%edx
f01013f4:	76 05                	jbe    f01013fb <page_init+0x9d>
f01013f6:	39 55 e4             	cmp    %edx,-0x1c(%ebp)
f01013f9:	77 e5                	ja     f01013e0 <page_init+0x82>
		if (i >= npages_basemem && len < free)
f01013fb:	39 c3                	cmp    %eax,%ebx
f01013fd:	77 c0                	ja     f01013bf <page_init+0x61>
f01013ff:	39 55 e0             	cmp    %edx,-0x20(%ebp)
f0101402:	76 bb                	jbe    f01013bf <page_init+0x61>
f0101404:	eb da                	jmp    f01013e0 <page_init+0x82>
f0101406:	89 f8                	mov    %edi,%eax
f0101408:	84 c0                	test   %al,%al
f010140a:	75 08                	jne    f0101414 <page_init+0xb6>
}
f010140c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010140f:	5b                   	pop    %ebx
f0101410:	5e                   	pop    %esi
f0101411:	5f                   	pop    %edi
f0101412:	5d                   	pop    %ebp
f0101413:	c3                   	ret    
f0101414:	89 0d 40 52 2a f0    	mov    %ecx,0xf02a5240
f010141a:	eb f0                	jmp    f010140c <page_init+0xae>

f010141c <page_alloc>:
{
f010141c:	55                   	push   %ebp
f010141d:	89 e5                	mov    %esp,%ebp
f010141f:	53                   	push   %ebx
f0101420:	83 ec 04             	sub    $0x4,%esp
	struct PageInfo* next = page_free_list;
f0101423:	8b 1d 40 52 2a f0    	mov    0xf02a5240,%ebx
	if (!next)
f0101429:	85 db                	test   %ebx,%ebx
f010142b:	74 13                	je     f0101440 <page_alloc+0x24>
	page_free_list = page_free_list->pp_link;
f010142d:	8b 03                	mov    (%ebx),%eax
f010142f:	a3 40 52 2a f0       	mov    %eax,0xf02a5240
	next->pp_link = NULL;
f0101434:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f010143a:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010143e:	75 07                	jne    f0101447 <page_alloc+0x2b>
}
f0101440:	89 d8                	mov    %ebx,%eax
f0101442:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101445:	c9                   	leave  
f0101446:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0101447:	89 d8                	mov    %ebx,%eax
f0101449:	2b 05 90 5e 2a f0    	sub    0xf02a5e90,%eax
f010144f:	c1 f8 03             	sar    $0x3,%eax
f0101452:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101455:	89 c2                	mov    %eax,%edx
f0101457:	c1 ea 0c             	shr    $0xc,%edx
f010145a:	3b 15 88 5e 2a f0    	cmp    0xf02a5e88,%edx
f0101460:	73 1a                	jae    f010147c <page_alloc+0x60>
		memset(content, 0, PGSIZE);
f0101462:	83 ec 04             	sub    $0x4,%esp
f0101465:	68 00 10 00 00       	push   $0x1000
f010146a:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f010146c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101471:	50                   	push   %eax
f0101472:	e8 a1 4b 00 00       	call   f0106018 <memset>
f0101477:	83 c4 10             	add    $0x10,%esp
f010147a:	eb c4                	jmp    f0101440 <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010147c:	50                   	push   %eax
f010147d:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0101482:	6a 58                	push   $0x58
f0101484:	68 89 7f 10 f0       	push   $0xf0107f89
f0101489:	e8 06 ec ff ff       	call   f0100094 <_panic>

f010148e <page_free>:
{
f010148e:	55                   	push   %ebp
f010148f:	89 e5                	mov    %esp,%ebp
f0101491:	83 ec 08             	sub    $0x8,%esp
f0101494:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref)
f0101497:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010149c:	75 14                	jne    f01014b2 <page_free+0x24>
	if (pp->pp_link)
f010149e:	83 38 00             	cmpl   $0x0,(%eax)
f01014a1:	75 26                	jne    f01014c9 <page_free+0x3b>
	pp->pp_link = page_free_list;
f01014a3:	8b 15 40 52 2a f0    	mov    0xf02a5240,%edx
f01014a9:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f01014ab:	a3 40 52 2a f0       	mov    %eax,0xf02a5240
}
f01014b0:	c9                   	leave  
f01014b1:	c3                   	ret    
		panic("Ref count is non-zero");
f01014b2:	83 ec 04             	sub    $0x4,%esp
f01014b5:	68 50 80 10 f0       	push   $0xf0108050
f01014ba:	68 70 01 00 00       	push   $0x170
f01014bf:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01014c4:	e8 cb eb ff ff       	call   f0100094 <_panic>
		panic("Page is double-freed");
f01014c9:	83 ec 04             	sub    $0x4,%esp
f01014cc:	68 66 80 10 f0       	push   $0xf0108066
f01014d1:	68 72 01 00 00       	push   $0x172
f01014d6:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01014db:	e8 b4 eb ff ff       	call   f0100094 <_panic>

f01014e0 <page_decref>:
{
f01014e0:	55                   	push   %ebp
f01014e1:	89 e5                	mov    %esp,%ebp
f01014e3:	83 ec 08             	sub    $0x8,%esp
f01014e6:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01014e9:	8b 42 04             	mov    0x4(%edx),%eax
f01014ec:	48                   	dec    %eax
f01014ed:	66 89 42 04          	mov    %ax,0x4(%edx)
f01014f1:	66 85 c0             	test   %ax,%ax
f01014f4:	74 02                	je     f01014f8 <page_decref+0x18>
}
f01014f6:	c9                   	leave  
f01014f7:	c3                   	ret    
		page_free(pp);
f01014f8:	83 ec 0c             	sub    $0xc,%esp
f01014fb:	52                   	push   %edx
f01014fc:	e8 8d ff ff ff       	call   f010148e <page_free>
f0101501:	83 c4 10             	add    $0x10,%esp
}
f0101504:	eb f0                	jmp    f01014f6 <page_decref+0x16>

f0101506 <pgdir_walk>:
{
f0101506:	55                   	push   %ebp
f0101507:	89 e5                	mov    %esp,%ebp
f0101509:	57                   	push   %edi
f010150a:	56                   	push   %esi
f010150b:	53                   	push   %ebx
f010150c:	83 ec 1c             	sub    $0x1c,%esp
	pde_t pd_entry = (pde_t)pgdir[PDX(va)];
f010150f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101512:	c1 eb 16             	shr    $0x16,%ebx
f0101515:	c1 e3 02             	shl    $0x2,%ebx
f0101518:	03 5d 08             	add    0x8(%ebp),%ebx
f010151b:	8b 03                	mov    (%ebx),%eax
	if (pd_entry) {
f010151d:	85 c0                	test   %eax,%eax
f010151f:	74 42                	je     f0101563 <pgdir_walk+0x5d>
		pte_t* pt_base = KADDR(PTE_ADDR(pd_entry));
f0101521:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101526:	89 c2                	mov    %eax,%edx
f0101528:	c1 ea 0c             	shr    $0xc,%edx
f010152b:	39 15 88 5e 2a f0    	cmp    %edx,0xf02a5e88
f0101531:	76 1b                	jbe    f010154e <pgdir_walk+0x48>
		return pt_base + PTX(va);
f0101533:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101536:	c1 ea 0a             	shr    $0xa,%edx
f0101539:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f010153f:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
}
f0101546:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101549:	5b                   	pop    %ebx
f010154a:	5e                   	pop    %esi
f010154b:	5f                   	pop    %edi
f010154c:	5d                   	pop    %ebp
f010154d:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010154e:	50                   	push   %eax
f010154f:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0101554:	68 9d 01 00 00       	push   $0x19d
f0101559:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010155e:	e8 31 eb ff ff       	call   f0100094 <_panic>
	else if (create) {
f0101563:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101567:	0f 84 9c 00 00 00    	je     f0101609 <pgdir_walk+0x103>
		struct PageInfo *new_pt = page_alloc(0);
f010156d:	83 ec 0c             	sub    $0xc,%esp
f0101570:	6a 00                	push   $0x0
f0101572:	e8 a5 fe ff ff       	call   f010141c <page_alloc>
f0101577:	89 c7                	mov    %eax,%edi
		if (new_pt) {
f0101579:	83 c4 10             	add    $0x10,%esp
f010157c:	85 c0                	test   %eax,%eax
f010157e:	0f 84 8f 00 00 00    	je     f0101613 <pgdir_walk+0x10d>
	return (pp - pages) << PGSHIFT;
f0101584:	2b 05 90 5e 2a f0    	sub    0xf02a5e90,%eax
f010158a:	c1 f8 03             	sar    $0x3,%eax
f010158d:	c1 e0 0c             	shl    $0xc,%eax
f0101590:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (PGNUM(pa) >= npages)
f0101593:	c1 e8 0c             	shr    $0xc,%eax
f0101596:	3b 05 88 5e 2a f0    	cmp    0xf02a5e88,%eax
f010159c:	73 42                	jae    f01015e0 <pgdir_walk+0xda>
	return (void *)(pa + KERNBASE);
f010159e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01015a1:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
			memset(content, 0, PGSIZE);
f01015a7:	83 ec 04             	sub    $0x4,%esp
f01015aa:	68 00 10 00 00       	push   $0x1000
f01015af:	6a 00                	push   $0x0
f01015b1:	56                   	push   %esi
f01015b2:	e8 61 4a 00 00       	call   f0106018 <memset>
			new_pt->pp_ref++;
f01015b7:	66 ff 47 04          	incw   0x4(%edi)
	if ((uint32_t)kva < KERNBASE)
f01015bb:	83 c4 10             	add    $0x10,%esp
f01015be:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01015c4:	76 2e                	jbe    f01015f4 <pgdir_walk+0xee>
			pgdir[PDX(va)] = PADDR(content) | 0xF; // Set all permissions.
f01015c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01015c9:	83 c8 0f             	or     $0xf,%eax
f01015cc:	89 03                	mov    %eax,(%ebx)
			return (pte_t*) content + PTX(va);
f01015ce:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015d1:	c1 e8 0a             	shr    $0xa,%eax
f01015d4:	25 fc 0f 00 00       	and    $0xffc,%eax
f01015d9:	01 f0                	add    %esi,%eax
f01015db:	e9 66 ff ff ff       	jmp    f0101546 <pgdir_walk+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015e0:	ff 75 e4             	pushl  -0x1c(%ebp)
f01015e3:	68 a8 6e 10 f0       	push   $0xf0106ea8
f01015e8:	6a 58                	push   $0x58
f01015ea:	68 89 7f 10 f0       	push   $0xf0107f89
f01015ef:	e8 a0 ea ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01015f4:	56                   	push   %esi
f01015f5:	68 cc 6e 10 f0       	push   $0xf0106ecc
f01015fa:	68 a6 01 00 00       	push   $0x1a6
f01015ff:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101604:	e8 8b ea ff ff       	call   f0100094 <_panic>
	return NULL;
f0101609:	b8 00 00 00 00       	mov    $0x0,%eax
f010160e:	e9 33 ff ff ff       	jmp    f0101546 <pgdir_walk+0x40>
f0101613:	b8 00 00 00 00       	mov    $0x0,%eax
f0101618:	e9 29 ff ff ff       	jmp    f0101546 <pgdir_walk+0x40>

f010161d <boot_map_region>:
{
f010161d:	55                   	push   %ebp
f010161e:	89 e5                	mov    %esp,%ebp
f0101620:	57                   	push   %edi
f0101621:	56                   	push   %esi
f0101622:	53                   	push   %ebx
f0101623:	83 ec 1c             	sub    $0x1c,%esp
f0101626:	89 c7                	mov    %eax,%edi
f0101628:	89 d6                	mov    %edx,%esi
f010162a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f010162d:	bb 00 00 00 00       	mov    $0x0,%ebx
		*page_entry = (pa + size0) | perm | PTE_P;
f0101632:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101635:	83 c8 01             	or     $0x1,%eax
f0101638:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f010163b:	eb 22                	jmp    f010165f <boot_map_region+0x42>
		pte_t *page_entry = pgdir_walk(pgdir, (void*) va + size0, 1);
f010163d:	83 ec 04             	sub    $0x4,%esp
f0101640:	6a 01                	push   $0x1
f0101642:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f0101645:	50                   	push   %eax
f0101646:	57                   	push   %edi
f0101647:	e8 ba fe ff ff       	call   f0101506 <pgdir_walk>
		*page_entry = (pa + size0) | perm | PTE_P;
f010164c:	89 da                	mov    %ebx,%edx
f010164e:	03 55 08             	add    0x8(%ebp),%edx
f0101651:	0b 55 e0             	or     -0x20(%ebp),%edx
f0101654:	89 10                	mov    %edx,(%eax)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f0101656:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010165c:	83 c4 10             	add    $0x10,%esp
f010165f:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101662:	72 d9                	jb     f010163d <boot_map_region+0x20>
}
f0101664:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101667:	5b                   	pop    %ebx
f0101668:	5e                   	pop    %esi
f0101669:	5f                   	pop    %edi
f010166a:	5d                   	pop    %ebp
f010166b:	c3                   	ret    

f010166c <page_lookup>:
{
f010166c:	55                   	push   %ebp
f010166d:	89 e5                	mov    %esp,%ebp
f010166f:	53                   	push   %ebx
f0101670:	83 ec 08             	sub    $0x8,%esp
f0101673:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *page_entry = pgdir_walk(pgdir, (void*) va, 0);
f0101676:	6a 00                	push   $0x0
f0101678:	ff 75 0c             	pushl  0xc(%ebp)
f010167b:	ff 75 08             	pushl  0x8(%ebp)
f010167e:	e8 83 fe ff ff       	call   f0101506 <pgdir_walk>
	if (!page_entry || !*page_entry)
f0101683:	83 c4 10             	add    $0x10,%esp
f0101686:	85 c0                	test   %eax,%eax
f0101688:	74 3a                	je     f01016c4 <page_lookup+0x58>
f010168a:	83 38 00             	cmpl   $0x0,(%eax)
f010168d:	74 3c                	je     f01016cb <page_lookup+0x5f>
	if (pte_store)
f010168f:	85 db                	test   %ebx,%ebx
f0101691:	74 02                	je     f0101695 <page_lookup+0x29>
		*pte_store = page_entry;
f0101693:	89 03                	mov    %eax,(%ebx)
f0101695:	8b 00                	mov    (%eax),%eax
f0101697:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010169a:	39 05 88 5e 2a f0    	cmp    %eax,0xf02a5e88
f01016a0:	76 0e                	jbe    f01016b0 <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01016a2:	8b 15 90 5e 2a f0    	mov    0xf02a5e90,%edx
f01016a8:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f01016ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01016ae:	c9                   	leave  
f01016af:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01016b0:	83 ec 04             	sub    $0x4,%esp
f01016b3:	68 44 77 10 f0       	push   $0xf0107744
f01016b8:	6a 51                	push   $0x51
f01016ba:	68 89 7f 10 f0       	push   $0xf0107f89
f01016bf:	e8 d0 e9 ff ff       	call   f0100094 <_panic>
		return NULL;
f01016c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01016c9:	eb e0                	jmp    f01016ab <page_lookup+0x3f>
f01016cb:	b8 00 00 00 00       	mov    $0x0,%eax
f01016d0:	eb d9                	jmp    f01016ab <page_lookup+0x3f>

f01016d2 <tlb_invalidate>:
{
f01016d2:	55                   	push   %ebp
f01016d3:	89 e5                	mov    %esp,%ebp
f01016d5:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f01016d8:	e8 45 50 00 00       	call   f0106722 <cpunum>
f01016dd:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01016e0:	01 c2                	add    %eax,%edx
f01016e2:	01 d2                	add    %edx,%edx
f01016e4:	01 c2                	add    %eax,%edx
f01016e6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01016e9:	83 3c 85 28 60 2a f0 	cmpl   $0x0,-0xfd59fd8(,%eax,4)
f01016f0:	00 
f01016f1:	74 20                	je     f0101713 <tlb_invalidate+0x41>
f01016f3:	e8 2a 50 00 00       	call   f0106722 <cpunum>
f01016f8:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01016fb:	01 c2                	add    %eax,%edx
f01016fd:	01 d2                	add    %edx,%edx
f01016ff:	01 c2                	add    %eax,%edx
f0101701:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0101704:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f010170b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010170e:	39 48 60             	cmp    %ecx,0x60(%eax)
f0101711:	75 06                	jne    f0101719 <tlb_invalidate+0x47>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101713:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101716:	0f 01 38             	invlpg (%eax)
}
f0101719:	c9                   	leave  
f010171a:	c3                   	ret    

f010171b <page_remove>:
{
f010171b:	55                   	push   %ebp
f010171c:	89 e5                	mov    %esp,%ebp
f010171e:	57                   	push   %edi
f010171f:	56                   	push   %esi
f0101720:	53                   	push   %ebx
f0101721:	83 ec 20             	sub    $0x20,%esp
f0101724:	8b 75 08             	mov    0x8(%ebp),%esi
f0101727:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct PageInfo *pp = page_lookup(pgdir, va, &pte_store);
f010172a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010172d:	50                   	push   %eax
f010172e:	57                   	push   %edi
f010172f:	56                   	push   %esi
f0101730:	e8 37 ff ff ff       	call   f010166c <page_lookup>
	if (!pp)
f0101735:	83 c4 10             	add    $0x10,%esp
f0101738:	85 c0                	test   %eax,%eax
f010173a:	74 23                	je     f010175f <page_remove+0x44>
f010173c:	89 c3                	mov    %eax,%ebx
	pp->pp_ref--;
f010173e:	66 ff 48 04          	decw   0x4(%eax)
	*pte_store = 0;
f0101742:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101745:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f010174b:	83 ec 08             	sub    $0x8,%esp
f010174e:	57                   	push   %edi
f010174f:	56                   	push   %esi
f0101750:	e8 7d ff ff ff       	call   f01016d2 <tlb_invalidate>
	if (!pp->pp_ref)
f0101755:	83 c4 10             	add    $0x10,%esp
f0101758:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010175d:	74 08                	je     f0101767 <page_remove+0x4c>
}
f010175f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101762:	5b                   	pop    %ebx
f0101763:	5e                   	pop    %esi
f0101764:	5f                   	pop    %edi
f0101765:	5d                   	pop    %ebp
f0101766:	c3                   	ret    
		page_free(pp);
f0101767:	83 ec 0c             	sub    $0xc,%esp
f010176a:	53                   	push   %ebx
f010176b:	e8 1e fd ff ff       	call   f010148e <page_free>
f0101770:	83 c4 10             	add    $0x10,%esp
f0101773:	eb ea                	jmp    f010175f <page_remove+0x44>

f0101775 <page_insert>:
{
f0101775:	55                   	push   %ebp
f0101776:	89 e5                	mov    %esp,%ebp
f0101778:	57                   	push   %edi
f0101779:	56                   	push   %esi
f010177a:	53                   	push   %ebx
f010177b:	83 ec 10             	sub    $0x10,%esp
f010177e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101781:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *page_entry = pgdir_walk(pgdir, (void*) va, 1);
f0101784:	6a 01                	push   $0x1
f0101786:	57                   	push   %edi
f0101787:	ff 75 08             	pushl  0x8(%ebp)
f010178a:	e8 77 fd ff ff       	call   f0101506 <pgdir_walk>
	if (!page_entry)
f010178f:	83 c4 10             	add    $0x10,%esp
f0101792:	85 c0                	test   %eax,%eax
f0101794:	74 3f                	je     f01017d5 <page_insert+0x60>
f0101796:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f0101798:	66 ff 43 04          	incw   0x4(%ebx)
	if (*page_entry) 
f010179c:	83 38 00             	cmpl   $0x0,(%eax)
f010179f:	75 23                	jne    f01017c4 <page_insert+0x4f>
	return (pp - pages) << PGSHIFT;
f01017a1:	2b 1d 90 5e 2a f0    	sub    0xf02a5e90,%ebx
f01017a7:	c1 fb 03             	sar    $0x3,%ebx
f01017aa:	c1 e3 0c             	shl    $0xc,%ebx
	*page_entry = page2pa(pp) | perm | PTE_P;
f01017ad:	8b 45 14             	mov    0x14(%ebp),%eax
f01017b0:	83 c8 01             	or     $0x1,%eax
f01017b3:	09 c3                	or     %eax,%ebx
f01017b5:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01017b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01017bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01017bf:	5b                   	pop    %ebx
f01017c0:	5e                   	pop    %esi
f01017c1:	5f                   	pop    %edi
f01017c2:	5d                   	pop    %ebp
f01017c3:	c3                   	ret    
		page_remove(pgdir, va);
f01017c4:	83 ec 08             	sub    $0x8,%esp
f01017c7:	57                   	push   %edi
f01017c8:	ff 75 08             	pushl  0x8(%ebp)
f01017cb:	e8 4b ff ff ff       	call   f010171b <page_remove>
f01017d0:	83 c4 10             	add    $0x10,%esp
f01017d3:	eb cc                	jmp    f01017a1 <page_insert+0x2c>
		return -E_NO_MEM;  // Has no page table AND cannot be allocated
f01017d5:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01017da:	eb e0                	jmp    f01017bc <page_insert+0x47>

f01017dc <mmio_map_region>:
{
f01017dc:	55                   	push   %ebp
f01017dd:	89 e5                	mov    %esp,%ebp
f01017df:	53                   	push   %ebx
f01017e0:	83 ec 04             	sub    $0x4,%esp
	size_t size_up = ROUNDUP(size, PGSIZE);
f01017e3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01017e6:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01017ec:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (base >= MMIOLIM)
f01017f2:	8b 15 00 33 12 f0    	mov    0xf0123300,%edx
f01017f8:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01017fe:	77 26                	ja     f0101826 <mmio_map_region+0x4a>
	boot_map_region(kern_pgdir, base, size_up, pa, PTE_PCD|PTE_PWT|PTE_W);
f0101800:	83 ec 08             	sub    $0x8,%esp
f0101803:	6a 1a                	push   $0x1a
f0101805:	ff 75 08             	pushl  0x8(%ebp)
f0101808:	89 d9                	mov    %ebx,%ecx
f010180a:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f010180f:	e8 09 fe ff ff       	call   f010161d <boot_map_region>
	base += size_up;
f0101814:	a1 00 33 12 f0       	mov    0xf0123300,%eax
f0101819:	01 c3                	add    %eax,%ebx
f010181b:	89 1d 00 33 12 f0    	mov    %ebx,0xf0123300
}
f0101821:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101824:	c9                   	leave  
f0101825:	c3                   	ret    
		panic("MMIO overflowed!");
f0101826:	83 ec 04             	sub    $0x4,%esp
f0101829:	68 7b 80 10 f0       	push   $0xf010807b
f010182e:	68 48 02 00 00       	push   $0x248
f0101833:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101838:	e8 57 e8 ff ff       	call   f0100094 <_panic>

f010183d <mem_init>:
{
f010183d:	55                   	push   %ebp
f010183e:	89 e5                	mov    %esp,%ebp
f0101840:	57                   	push   %edi
f0101841:	56                   	push   %esi
f0101842:	53                   	push   %ebx
f0101843:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0101846:	b8 15 00 00 00       	mov    $0x15,%eax
f010184b:	e8 91 f7 ff ff       	call   f0100fe1 <nvram_read>
f0101850:	89 c6                	mov    %eax,%esi
	extmem = nvram_read(NVRAM_EXTLO);
f0101852:	b8 17 00 00 00       	mov    $0x17,%eax
f0101857:	e8 85 f7 ff ff       	call   f0100fe1 <nvram_read>
f010185c:	89 c3                	mov    %eax,%ebx
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010185e:	b8 34 00 00 00       	mov    $0x34,%eax
f0101863:	e8 79 f7 ff ff       	call   f0100fe1 <nvram_read>
	if (ext16mem)
f0101868:	c1 e0 06             	shl    $0x6,%eax
f010186b:	75 10                	jne    f010187d <mem_init+0x40>
	else if (extmem)
f010186d:	85 db                	test   %ebx,%ebx
f010186f:	0f 84 e6 00 00 00    	je     f010195b <mem_init+0x11e>
		totalmem = 1 * 1024 + extmem;
f0101875:	8d 83 00 04 00 00    	lea    0x400(%ebx),%eax
f010187b:	eb 05                	jmp    f0101882 <mem_init+0x45>
		totalmem = 16 * 1024 + ext16mem;
f010187d:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101882:	89 c2                	mov    %eax,%edx
f0101884:	c1 ea 02             	shr    $0x2,%edx
f0101887:	89 15 88 5e 2a f0    	mov    %edx,0xf02a5e88
	npages_basemem = basemem / (PGSIZE / 1024);
f010188d:	89 f2                	mov    %esi,%edx
f010188f:	c1 ea 02             	shr    $0x2,%edx
f0101892:	89 15 44 52 2a f0    	mov    %edx,0xf02a5244
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101898:	89 c2                	mov    %eax,%edx
f010189a:	29 f2                	sub    %esi,%edx
f010189c:	52                   	push   %edx
f010189d:	56                   	push   %esi
f010189e:	50                   	push   %eax
f010189f:	68 64 77 10 f0       	push   $0xf0107764
f01018a4:	e8 f0 26 00 00       	call   f0103f99 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01018a9:	b8 00 10 00 00       	mov    $0x1000,%eax
f01018ae:	e8 e8 f6 ff ff       	call   f0100f9b <boot_alloc>
f01018b3:	a3 8c 5e 2a f0       	mov    %eax,0xf02a5e8c
	memset(kern_pgdir, 0, PGSIZE);
f01018b8:	83 c4 0c             	add    $0xc,%esp
f01018bb:	68 00 10 00 00       	push   $0x1000
f01018c0:	6a 00                	push   $0x0
f01018c2:	50                   	push   %eax
f01018c3:	e8 50 47 00 00       	call   f0106018 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01018c8:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01018cd:	83 c4 10             	add    $0x10,%esp
f01018d0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01018d5:	0f 86 87 00 00 00    	jbe    f0101962 <mem_init+0x125>
	return (physaddr_t)kva - KERNBASE;
f01018db:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01018e1:	83 ca 05             	or     $0x5,%edx
f01018e4:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo)*npages);
f01018ea:	a1 88 5e 2a f0       	mov    0xf02a5e88,%eax
f01018ef:	c1 e0 03             	shl    $0x3,%eax
f01018f2:	e8 a4 f6 ff ff       	call   f0100f9b <boot_alloc>
f01018f7:	a3 90 5e 2a f0       	mov    %eax,0xf02a5e90
	memset(pages, 0, sizeof(struct PageInfo)*npages);
f01018fc:	83 ec 04             	sub    $0x4,%esp
f01018ff:	8b 0d 88 5e 2a f0    	mov    0xf02a5e88,%ecx
f0101905:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f010190c:	52                   	push   %edx
f010190d:	6a 00                	push   $0x0
f010190f:	50                   	push   %eax
f0101910:	e8 03 47 00 00       	call   f0106018 <memset>
	envs = (struct Env *) boot_alloc(sizeof(struct Env)*NENV);
f0101915:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010191a:	e8 7c f6 ff ff       	call   f0100f9b <boot_alloc>
f010191f:	a3 48 52 2a f0       	mov    %eax,0xf02a5248
	memset(envs, 0, sizeof(struct Env)*NENV);
f0101924:	83 c4 0c             	add    $0xc,%esp
f0101927:	68 00 f0 01 00       	push   $0x1f000
f010192c:	6a 00                	push   $0x0
f010192e:	50                   	push   %eax
f010192f:	e8 e4 46 00 00       	call   f0106018 <memset>
	page_init();
f0101934:	e8 25 fa ff ff       	call   f010135e <page_init>
	check_page_free_list(1);
f0101939:	b8 01 00 00 00       	mov    $0x1,%eax
f010193e:	e8 24 f7 ff ff       	call   f0101067 <check_page_free_list>
	if (!pages)
f0101943:	83 c4 10             	add    $0x10,%esp
f0101946:	83 3d 90 5e 2a f0 00 	cmpl   $0x0,0xf02a5e90
f010194d:	74 28                	je     f0101977 <mem_init+0x13a>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010194f:	a1 40 52 2a f0       	mov    0xf02a5240,%eax
f0101954:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101959:	eb 36                	jmp    f0101991 <mem_init+0x154>
		totalmem = basemem;
f010195b:	89 f0                	mov    %esi,%eax
f010195d:	e9 20 ff ff ff       	jmp    f0101882 <mem_init+0x45>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101962:	50                   	push   %eax
f0101963:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0101968:	68 94 00 00 00       	push   $0x94
f010196d:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101972:	e8 1d e7 ff ff       	call   f0100094 <_panic>
		panic("'pages' is a null pointer!");
f0101977:	83 ec 04             	sub    $0x4,%esp
f010197a:	68 8c 80 10 f0       	push   $0xf010808c
f010197f:	68 e3 02 00 00       	push   $0x2e3
f0101984:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101989:	e8 06 e7 ff ff       	call   f0100094 <_panic>
		++nfree;
f010198e:	43                   	inc    %ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010198f:	8b 00                	mov    (%eax),%eax
f0101991:	85 c0                	test   %eax,%eax
f0101993:	75 f9                	jne    f010198e <mem_init+0x151>
	assert((pp0 = page_alloc(0)));
f0101995:	83 ec 0c             	sub    $0xc,%esp
f0101998:	6a 00                	push   $0x0
f010199a:	e8 7d fa ff ff       	call   f010141c <page_alloc>
f010199f:	89 c7                	mov    %eax,%edi
f01019a1:	83 c4 10             	add    $0x10,%esp
f01019a4:	85 c0                	test   %eax,%eax
f01019a6:	0f 84 10 02 00 00    	je     f0101bbc <mem_init+0x37f>
	assert((pp1 = page_alloc(0)));
f01019ac:	83 ec 0c             	sub    $0xc,%esp
f01019af:	6a 00                	push   $0x0
f01019b1:	e8 66 fa ff ff       	call   f010141c <page_alloc>
f01019b6:	89 c6                	mov    %eax,%esi
f01019b8:	83 c4 10             	add    $0x10,%esp
f01019bb:	85 c0                	test   %eax,%eax
f01019bd:	0f 84 12 02 00 00    	je     f0101bd5 <mem_init+0x398>
	assert((pp2 = page_alloc(0)));
f01019c3:	83 ec 0c             	sub    $0xc,%esp
f01019c6:	6a 00                	push   $0x0
f01019c8:	e8 4f fa ff ff       	call   f010141c <page_alloc>
f01019cd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019d0:	83 c4 10             	add    $0x10,%esp
f01019d3:	85 c0                	test   %eax,%eax
f01019d5:	0f 84 13 02 00 00    	je     f0101bee <mem_init+0x3b1>
	assert(pp1 && pp1 != pp0);
f01019db:	39 f7                	cmp    %esi,%edi
f01019dd:	0f 84 24 02 00 00    	je     f0101c07 <mem_init+0x3ca>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019e3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019e6:	39 c6                	cmp    %eax,%esi
f01019e8:	0f 84 32 02 00 00    	je     f0101c20 <mem_init+0x3e3>
f01019ee:	39 c7                	cmp    %eax,%edi
f01019f0:	0f 84 2a 02 00 00    	je     f0101c20 <mem_init+0x3e3>
	return (pp - pages) << PGSHIFT;
f01019f6:	8b 0d 90 5e 2a f0    	mov    0xf02a5e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01019fc:	8b 15 88 5e 2a f0    	mov    0xf02a5e88,%edx
f0101a02:	c1 e2 0c             	shl    $0xc,%edx
f0101a05:	89 f8                	mov    %edi,%eax
f0101a07:	29 c8                	sub    %ecx,%eax
f0101a09:	c1 f8 03             	sar    $0x3,%eax
f0101a0c:	c1 e0 0c             	shl    $0xc,%eax
f0101a0f:	39 d0                	cmp    %edx,%eax
f0101a11:	0f 83 22 02 00 00    	jae    f0101c39 <mem_init+0x3fc>
f0101a17:	89 f0                	mov    %esi,%eax
f0101a19:	29 c8                	sub    %ecx,%eax
f0101a1b:	c1 f8 03             	sar    $0x3,%eax
f0101a1e:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101a21:	39 c2                	cmp    %eax,%edx
f0101a23:	0f 86 29 02 00 00    	jbe    f0101c52 <mem_init+0x415>
f0101a29:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a2c:	29 c8                	sub    %ecx,%eax
f0101a2e:	c1 f8 03             	sar    $0x3,%eax
f0101a31:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101a34:	39 c2                	cmp    %eax,%edx
f0101a36:	0f 86 2f 02 00 00    	jbe    f0101c6b <mem_init+0x42e>
	fl = page_free_list;
f0101a3c:	a1 40 52 2a f0       	mov    0xf02a5240,%eax
f0101a41:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101a44:	c7 05 40 52 2a f0 00 	movl   $0x0,0xf02a5240
f0101a4b:	00 00 00 
	assert(!page_alloc(0));
f0101a4e:	83 ec 0c             	sub    $0xc,%esp
f0101a51:	6a 00                	push   $0x0
f0101a53:	e8 c4 f9 ff ff       	call   f010141c <page_alloc>
f0101a58:	83 c4 10             	add    $0x10,%esp
f0101a5b:	85 c0                	test   %eax,%eax
f0101a5d:	0f 85 21 02 00 00    	jne    f0101c84 <mem_init+0x447>
	page_free(pp0);
f0101a63:	83 ec 0c             	sub    $0xc,%esp
f0101a66:	57                   	push   %edi
f0101a67:	e8 22 fa ff ff       	call   f010148e <page_free>
	page_free(pp1);
f0101a6c:	89 34 24             	mov    %esi,(%esp)
f0101a6f:	e8 1a fa ff ff       	call   f010148e <page_free>
	page_free(pp2);
f0101a74:	83 c4 04             	add    $0x4,%esp
f0101a77:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a7a:	e8 0f fa ff ff       	call   f010148e <page_free>
	assert((pp0 = page_alloc(0)));
f0101a7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a86:	e8 91 f9 ff ff       	call   f010141c <page_alloc>
f0101a8b:	89 c6                	mov    %eax,%esi
f0101a8d:	83 c4 10             	add    $0x10,%esp
f0101a90:	85 c0                	test   %eax,%eax
f0101a92:	0f 84 05 02 00 00    	je     f0101c9d <mem_init+0x460>
	assert((pp1 = page_alloc(0)));
f0101a98:	83 ec 0c             	sub    $0xc,%esp
f0101a9b:	6a 00                	push   $0x0
f0101a9d:	e8 7a f9 ff ff       	call   f010141c <page_alloc>
f0101aa2:	89 c7                	mov    %eax,%edi
f0101aa4:	83 c4 10             	add    $0x10,%esp
f0101aa7:	85 c0                	test   %eax,%eax
f0101aa9:	0f 84 07 02 00 00    	je     f0101cb6 <mem_init+0x479>
	assert((pp2 = page_alloc(0)));
f0101aaf:	83 ec 0c             	sub    $0xc,%esp
f0101ab2:	6a 00                	push   $0x0
f0101ab4:	e8 63 f9 ff ff       	call   f010141c <page_alloc>
f0101ab9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101abc:	83 c4 10             	add    $0x10,%esp
f0101abf:	85 c0                	test   %eax,%eax
f0101ac1:	0f 84 08 02 00 00    	je     f0101ccf <mem_init+0x492>
	assert(pp1 && pp1 != pp0);
f0101ac7:	39 fe                	cmp    %edi,%esi
f0101ac9:	0f 84 19 02 00 00    	je     f0101ce8 <mem_init+0x4ab>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101acf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ad2:	39 c7                	cmp    %eax,%edi
f0101ad4:	0f 84 27 02 00 00    	je     f0101d01 <mem_init+0x4c4>
f0101ada:	39 c6                	cmp    %eax,%esi
f0101adc:	0f 84 1f 02 00 00    	je     f0101d01 <mem_init+0x4c4>
	assert(!page_alloc(0));
f0101ae2:	83 ec 0c             	sub    $0xc,%esp
f0101ae5:	6a 00                	push   $0x0
f0101ae7:	e8 30 f9 ff ff       	call   f010141c <page_alloc>
f0101aec:	83 c4 10             	add    $0x10,%esp
f0101aef:	85 c0                	test   %eax,%eax
f0101af1:	0f 85 23 02 00 00    	jne    f0101d1a <mem_init+0x4dd>
f0101af7:	89 f0                	mov    %esi,%eax
f0101af9:	2b 05 90 5e 2a f0    	sub    0xf02a5e90,%eax
f0101aff:	c1 f8 03             	sar    $0x3,%eax
f0101b02:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101b05:	89 c2                	mov    %eax,%edx
f0101b07:	c1 ea 0c             	shr    $0xc,%edx
f0101b0a:	3b 15 88 5e 2a f0    	cmp    0xf02a5e88,%edx
f0101b10:	0f 83 1d 02 00 00    	jae    f0101d33 <mem_init+0x4f6>
	memset(page2kva(pp0), 1, PGSIZE);
f0101b16:	83 ec 04             	sub    $0x4,%esp
f0101b19:	68 00 10 00 00       	push   $0x1000
f0101b1e:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101b20:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101b25:	50                   	push   %eax
f0101b26:	e8 ed 44 00 00       	call   f0106018 <memset>
	page_free(pp0);
f0101b2b:	89 34 24             	mov    %esi,(%esp)
f0101b2e:	e8 5b f9 ff ff       	call   f010148e <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101b33:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101b3a:	e8 dd f8 ff ff       	call   f010141c <page_alloc>
f0101b3f:	83 c4 10             	add    $0x10,%esp
f0101b42:	85 c0                	test   %eax,%eax
f0101b44:	0f 84 fb 01 00 00    	je     f0101d45 <mem_init+0x508>
	assert(pp && pp0 == pp);
f0101b4a:	39 c6                	cmp    %eax,%esi
f0101b4c:	0f 85 0c 02 00 00    	jne    f0101d5e <mem_init+0x521>
	return (pp - pages) << PGSHIFT;
f0101b52:	89 f2                	mov    %esi,%edx
f0101b54:	2b 15 90 5e 2a f0    	sub    0xf02a5e90,%edx
f0101b5a:	c1 fa 03             	sar    $0x3,%edx
f0101b5d:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101b60:	89 d0                	mov    %edx,%eax
f0101b62:	c1 e8 0c             	shr    $0xc,%eax
f0101b65:	3b 05 88 5e 2a f0    	cmp    0xf02a5e88,%eax
f0101b6b:	0f 83 06 02 00 00    	jae    f0101d77 <mem_init+0x53a>
	return (void *)(pa + KERNBASE);
f0101b71:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101b77:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101b7d:	80 38 00             	cmpb   $0x0,(%eax)
f0101b80:	0f 85 03 02 00 00    	jne    f0101d89 <mem_init+0x54c>
f0101b86:	40                   	inc    %eax
	for (i = 0; i < PGSIZE; i++)
f0101b87:	39 d0                	cmp    %edx,%eax
f0101b89:	75 f2                	jne    f0101b7d <mem_init+0x340>
	page_free_list = fl;
f0101b8b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b8e:	a3 40 52 2a f0       	mov    %eax,0xf02a5240
	page_free(pp0);
f0101b93:	83 ec 0c             	sub    $0xc,%esp
f0101b96:	56                   	push   %esi
f0101b97:	e8 f2 f8 ff ff       	call   f010148e <page_free>
	page_free(pp1);
f0101b9c:	89 3c 24             	mov    %edi,(%esp)
f0101b9f:	e8 ea f8 ff ff       	call   f010148e <page_free>
	page_free(pp2);
f0101ba4:	83 c4 04             	add    $0x4,%esp
f0101ba7:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101baa:	e8 df f8 ff ff       	call   f010148e <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101baf:	a1 40 52 2a f0       	mov    0xf02a5240,%eax
f0101bb4:	83 c4 10             	add    $0x10,%esp
f0101bb7:	e9 e9 01 00 00       	jmp    f0101da5 <mem_init+0x568>
	assert((pp0 = page_alloc(0)));
f0101bbc:	68 a7 80 10 f0       	push   $0xf01080a7
f0101bc1:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101bc6:	68 eb 02 00 00       	push   $0x2eb
f0101bcb:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101bd0:	e8 bf e4 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101bd5:	68 bd 80 10 f0       	push   $0xf01080bd
f0101bda:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101bdf:	68 ec 02 00 00       	push   $0x2ec
f0101be4:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101be9:	e8 a6 e4 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101bee:	68 d3 80 10 f0       	push   $0xf01080d3
f0101bf3:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101bf8:	68 ed 02 00 00       	push   $0x2ed
f0101bfd:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101c02:	e8 8d e4 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f0101c07:	68 e9 80 10 f0       	push   $0xf01080e9
f0101c0c:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101c11:	68 f0 02 00 00       	push   $0x2f0
f0101c16:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101c1b:	e8 74 e4 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c20:	68 a0 77 10 f0       	push   $0xf01077a0
f0101c25:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101c2a:	68 f1 02 00 00       	push   $0x2f1
f0101c2f:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101c34:	e8 5b e4 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101c39:	68 fb 80 10 f0       	push   $0xf01080fb
f0101c3e:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101c43:	68 f2 02 00 00       	push   $0x2f2
f0101c48:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101c4d:	e8 42 e4 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101c52:	68 18 81 10 f0       	push   $0xf0108118
f0101c57:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101c5c:	68 f3 02 00 00       	push   $0x2f3
f0101c61:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101c66:	e8 29 e4 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101c6b:	68 35 81 10 f0       	push   $0xf0108135
f0101c70:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101c75:	68 f4 02 00 00       	push   $0x2f4
f0101c7a:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101c7f:	e8 10 e4 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101c84:	68 52 81 10 f0       	push   $0xf0108152
f0101c89:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101c8e:	68 fb 02 00 00       	push   $0x2fb
f0101c93:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101c98:	e8 f7 e3 ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0101c9d:	68 a7 80 10 f0       	push   $0xf01080a7
f0101ca2:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101ca7:	68 02 03 00 00       	push   $0x302
f0101cac:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101cb1:	e8 de e3 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101cb6:	68 bd 80 10 f0       	push   $0xf01080bd
f0101cbb:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101cc0:	68 03 03 00 00       	push   $0x303
f0101cc5:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101cca:	e8 c5 e3 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101ccf:	68 d3 80 10 f0       	push   $0xf01080d3
f0101cd4:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101cd9:	68 04 03 00 00       	push   $0x304
f0101cde:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101ce3:	e8 ac e3 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f0101ce8:	68 e9 80 10 f0       	push   $0xf01080e9
f0101ced:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101cf2:	68 06 03 00 00       	push   $0x306
f0101cf7:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101cfc:	e8 93 e3 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101d01:	68 a0 77 10 f0       	push   $0xf01077a0
f0101d06:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101d0b:	68 07 03 00 00       	push   $0x307
f0101d10:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101d15:	e8 7a e3 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101d1a:	68 52 81 10 f0       	push   $0xf0108152
f0101d1f:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101d24:	68 08 03 00 00       	push   $0x308
f0101d29:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101d2e:	e8 61 e3 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d33:	50                   	push   %eax
f0101d34:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0101d39:	6a 58                	push   $0x58
f0101d3b:	68 89 7f 10 f0       	push   $0xf0107f89
f0101d40:	e8 4f e3 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101d45:	68 61 81 10 f0       	push   $0xf0108161
f0101d4a:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101d4f:	68 0d 03 00 00       	push   $0x30d
f0101d54:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101d59:	e8 36 e3 ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f0101d5e:	68 7f 81 10 f0       	push   $0xf010817f
f0101d63:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101d68:	68 0e 03 00 00       	push   $0x30e
f0101d6d:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101d72:	e8 1d e3 ff ff       	call   f0100094 <_panic>
f0101d77:	52                   	push   %edx
f0101d78:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0101d7d:	6a 58                	push   $0x58
f0101d7f:	68 89 7f 10 f0       	push   $0xf0107f89
f0101d84:	e8 0b e3 ff ff       	call   f0100094 <_panic>
		assert(c[i] == 0);
f0101d89:	68 8f 81 10 f0       	push   $0xf010818f
f0101d8e:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101d93:	68 11 03 00 00       	push   $0x311
f0101d98:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101d9d:	e8 f2 e2 ff ff       	call   f0100094 <_panic>
		--nfree;
f0101da2:	4b                   	dec    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101da3:	8b 00                	mov    (%eax),%eax
f0101da5:	85 c0                	test   %eax,%eax
f0101da7:	75 f9                	jne    f0101da2 <mem_init+0x565>
	assert(nfree == 0);
f0101da9:	85 db                	test   %ebx,%ebx
f0101dab:	0f 85 87 09 00 00    	jne    f0102738 <mem_init+0xefb>
	cprintf("check_page_alloc() succeeded!\n");
f0101db1:	83 ec 0c             	sub    $0xc,%esp
f0101db4:	68 c0 77 10 f0       	push   $0xf01077c0
f0101db9:	e8 db 21 00 00       	call   f0103f99 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101dbe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101dc5:	e8 52 f6 ff ff       	call   f010141c <page_alloc>
f0101dca:	89 c7                	mov    %eax,%edi
f0101dcc:	83 c4 10             	add    $0x10,%esp
f0101dcf:	85 c0                	test   %eax,%eax
f0101dd1:	0f 84 7a 09 00 00    	je     f0102751 <mem_init+0xf14>
	assert((pp1 = page_alloc(0)));
f0101dd7:	83 ec 0c             	sub    $0xc,%esp
f0101dda:	6a 00                	push   $0x0
f0101ddc:	e8 3b f6 ff ff       	call   f010141c <page_alloc>
f0101de1:	89 c3                	mov    %eax,%ebx
f0101de3:	83 c4 10             	add    $0x10,%esp
f0101de6:	85 c0                	test   %eax,%eax
f0101de8:	0f 84 7c 09 00 00    	je     f010276a <mem_init+0xf2d>
	assert((pp2 = page_alloc(0)));
f0101dee:	83 ec 0c             	sub    $0xc,%esp
f0101df1:	6a 00                	push   $0x0
f0101df3:	e8 24 f6 ff ff       	call   f010141c <page_alloc>
f0101df8:	89 c6                	mov    %eax,%esi
f0101dfa:	83 c4 10             	add    $0x10,%esp
f0101dfd:	85 c0                	test   %eax,%eax
f0101dff:	0f 84 7e 09 00 00    	je     f0102783 <mem_init+0xf46>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101e05:	39 df                	cmp    %ebx,%edi
f0101e07:	0f 84 8f 09 00 00    	je     f010279c <mem_init+0xf5f>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101e0d:	39 c3                	cmp    %eax,%ebx
f0101e0f:	0f 84 a0 09 00 00    	je     f01027b5 <mem_init+0xf78>
f0101e15:	39 c7                	cmp    %eax,%edi
f0101e17:	0f 84 98 09 00 00    	je     f01027b5 <mem_init+0xf78>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101e1d:	a1 40 52 2a f0       	mov    0xf02a5240,%eax
f0101e22:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f0101e25:	c7 05 40 52 2a f0 00 	movl   $0x0,0xf02a5240
f0101e2c:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101e2f:	83 ec 0c             	sub    $0xc,%esp
f0101e32:	6a 00                	push   $0x0
f0101e34:	e8 e3 f5 ff ff       	call   f010141c <page_alloc>
f0101e39:	83 c4 10             	add    $0x10,%esp
f0101e3c:	85 c0                	test   %eax,%eax
f0101e3e:	0f 85 8a 09 00 00    	jne    f01027ce <mem_init+0xf91>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101e44:	83 ec 04             	sub    $0x4,%esp
f0101e47:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101e4a:	50                   	push   %eax
f0101e4b:	6a 00                	push   $0x0
f0101e4d:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f0101e53:	e8 14 f8 ff ff       	call   f010166c <page_lookup>
f0101e58:	83 c4 10             	add    $0x10,%esp
f0101e5b:	85 c0                	test   %eax,%eax
f0101e5d:	0f 85 84 09 00 00    	jne    f01027e7 <mem_init+0xfaa>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101e63:	6a 02                	push   $0x2
f0101e65:	6a 00                	push   $0x0
f0101e67:	53                   	push   %ebx
f0101e68:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f0101e6e:	e8 02 f9 ff ff       	call   f0101775 <page_insert>
f0101e73:	83 c4 10             	add    $0x10,%esp
f0101e76:	85 c0                	test   %eax,%eax
f0101e78:	0f 89 82 09 00 00    	jns    f0102800 <mem_init+0xfc3>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101e7e:	83 ec 0c             	sub    $0xc,%esp
f0101e81:	57                   	push   %edi
f0101e82:	e8 07 f6 ff ff       	call   f010148e <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101e87:	6a 02                	push   $0x2
f0101e89:	6a 00                	push   $0x0
f0101e8b:	53                   	push   %ebx
f0101e8c:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f0101e92:	e8 de f8 ff ff       	call   f0101775 <page_insert>
f0101e97:	83 c4 20             	add    $0x20,%esp
f0101e9a:	85 c0                	test   %eax,%eax
f0101e9c:	0f 85 77 09 00 00    	jne    f0102819 <mem_init+0xfdc>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101ea2:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f0101ea7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	return (pp - pages) << PGSHIFT;
f0101eaa:	8b 0d 90 5e 2a f0    	mov    0xf02a5e90,%ecx
f0101eb0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101eb3:	8b 00                	mov    (%eax),%eax
f0101eb5:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101eb8:	89 c2                	mov    %eax,%edx
f0101eba:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101ec0:	89 f8                	mov    %edi,%eax
f0101ec2:	29 c8                	sub    %ecx,%eax
f0101ec4:	c1 f8 03             	sar    $0x3,%eax
f0101ec7:	c1 e0 0c             	shl    $0xc,%eax
f0101eca:	39 c2                	cmp    %eax,%edx
f0101ecc:	0f 85 60 09 00 00    	jne    f0102832 <mem_init+0xff5>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101ed2:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ed7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101eda:	e8 29 f1 ff ff       	call   f0101008 <check_va2pa>
f0101edf:	89 da                	mov    %ebx,%edx
f0101ee1:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101ee4:	c1 fa 03             	sar    $0x3,%edx
f0101ee7:	c1 e2 0c             	shl    $0xc,%edx
f0101eea:	39 d0                	cmp    %edx,%eax
f0101eec:	0f 85 59 09 00 00    	jne    f010284b <mem_init+0x100e>
	assert(pp1->pp_ref == 1);
f0101ef2:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ef7:	0f 85 67 09 00 00    	jne    f0102864 <mem_init+0x1027>
	assert(pp0->pp_ref == 1);
f0101efd:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101f02:	0f 85 75 09 00 00    	jne    f010287d <mem_init+0x1040>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f08:	6a 02                	push   $0x2
f0101f0a:	68 00 10 00 00       	push   $0x1000
f0101f0f:	56                   	push   %esi
f0101f10:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f13:	e8 5d f8 ff ff       	call   f0101775 <page_insert>
f0101f18:	83 c4 10             	add    $0x10,%esp
f0101f1b:	85 c0                	test   %eax,%eax
f0101f1d:	0f 85 73 09 00 00    	jne    f0102896 <mem_init+0x1059>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f23:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f28:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f0101f2d:	e8 d6 f0 ff ff       	call   f0101008 <check_va2pa>
f0101f32:	89 f2                	mov    %esi,%edx
f0101f34:	2b 15 90 5e 2a f0    	sub    0xf02a5e90,%edx
f0101f3a:	c1 fa 03             	sar    $0x3,%edx
f0101f3d:	c1 e2 0c             	shl    $0xc,%edx
f0101f40:	39 d0                	cmp    %edx,%eax
f0101f42:	0f 85 67 09 00 00    	jne    f01028af <mem_init+0x1072>
	assert(pp2->pp_ref == 1);
f0101f48:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f4d:	0f 85 75 09 00 00    	jne    f01028c8 <mem_init+0x108b>

	// should be no free memory
	assert(!page_alloc(0));
f0101f53:	83 ec 0c             	sub    $0xc,%esp
f0101f56:	6a 00                	push   $0x0
f0101f58:	e8 bf f4 ff ff       	call   f010141c <page_alloc>
f0101f5d:	83 c4 10             	add    $0x10,%esp
f0101f60:	85 c0                	test   %eax,%eax
f0101f62:	0f 85 79 09 00 00    	jne    f01028e1 <mem_init+0x10a4>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f68:	6a 02                	push   $0x2
f0101f6a:	68 00 10 00 00       	push   $0x1000
f0101f6f:	56                   	push   %esi
f0101f70:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f0101f76:	e8 fa f7 ff ff       	call   f0101775 <page_insert>
f0101f7b:	83 c4 10             	add    $0x10,%esp
f0101f7e:	85 c0                	test   %eax,%eax
f0101f80:	0f 85 74 09 00 00    	jne    f01028fa <mem_init+0x10bd>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f86:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f8b:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f0101f90:	e8 73 f0 ff ff       	call   f0101008 <check_va2pa>
f0101f95:	89 f2                	mov    %esi,%edx
f0101f97:	2b 15 90 5e 2a f0    	sub    0xf02a5e90,%edx
f0101f9d:	c1 fa 03             	sar    $0x3,%edx
f0101fa0:	c1 e2 0c             	shl    $0xc,%edx
f0101fa3:	39 d0                	cmp    %edx,%eax
f0101fa5:	0f 85 68 09 00 00    	jne    f0102913 <mem_init+0x10d6>
	assert(pp2->pp_ref == 1);
f0101fab:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101fb0:	0f 85 76 09 00 00    	jne    f010292c <mem_init+0x10ef>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101fb6:	83 ec 0c             	sub    $0xc,%esp
f0101fb9:	6a 00                	push   $0x0
f0101fbb:	e8 5c f4 ff ff       	call   f010141c <page_alloc>
f0101fc0:	83 c4 10             	add    $0x10,%esp
f0101fc3:	85 c0                	test   %eax,%eax
f0101fc5:	0f 85 7a 09 00 00    	jne    f0102945 <mem_init+0x1108>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101fcb:	8b 15 8c 5e 2a f0    	mov    0xf02a5e8c,%edx
f0101fd1:	8b 02                	mov    (%edx),%eax
f0101fd3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101fd8:	89 c1                	mov    %eax,%ecx
f0101fda:	c1 e9 0c             	shr    $0xc,%ecx
f0101fdd:	3b 0d 88 5e 2a f0    	cmp    0xf02a5e88,%ecx
f0101fe3:	0f 83 75 09 00 00    	jae    f010295e <mem_init+0x1121>
	return (void *)(pa + KERNBASE);
f0101fe9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101fee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101ff1:	83 ec 04             	sub    $0x4,%esp
f0101ff4:	6a 00                	push   $0x0
f0101ff6:	68 00 10 00 00       	push   $0x1000
f0101ffb:	52                   	push   %edx
f0101ffc:	e8 05 f5 ff ff       	call   f0101506 <pgdir_walk>
f0102001:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102004:	8d 51 04             	lea    0x4(%ecx),%edx
f0102007:	83 c4 10             	add    $0x10,%esp
f010200a:	39 d0                	cmp    %edx,%eax
f010200c:	0f 85 61 09 00 00    	jne    f0102973 <mem_init+0x1136>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102012:	6a 06                	push   $0x6
f0102014:	68 00 10 00 00       	push   $0x1000
f0102019:	56                   	push   %esi
f010201a:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f0102020:	e8 50 f7 ff ff       	call   f0101775 <page_insert>
f0102025:	83 c4 10             	add    $0x10,%esp
f0102028:	85 c0                	test   %eax,%eax
f010202a:	0f 85 5c 09 00 00    	jne    f010298c <mem_init+0x114f>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102030:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f0102035:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102038:	ba 00 10 00 00       	mov    $0x1000,%edx
f010203d:	e8 c6 ef ff ff       	call   f0101008 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0102042:	89 f2                	mov    %esi,%edx
f0102044:	2b 15 90 5e 2a f0    	sub    0xf02a5e90,%edx
f010204a:	c1 fa 03             	sar    $0x3,%edx
f010204d:	c1 e2 0c             	shl    $0xc,%edx
f0102050:	39 d0                	cmp    %edx,%eax
f0102052:	0f 85 4d 09 00 00    	jne    f01029a5 <mem_init+0x1168>
	assert(pp2->pp_ref == 1);
f0102058:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010205d:	0f 85 5b 09 00 00    	jne    f01029be <mem_init+0x1181>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102063:	83 ec 04             	sub    $0x4,%esp
f0102066:	6a 00                	push   $0x0
f0102068:	68 00 10 00 00       	push   $0x1000
f010206d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102070:	e8 91 f4 ff ff       	call   f0101506 <pgdir_walk>
f0102075:	83 c4 10             	add    $0x10,%esp
f0102078:	f6 00 04             	testb  $0x4,(%eax)
f010207b:	0f 84 56 09 00 00    	je     f01029d7 <mem_init+0x119a>
	assert(kern_pgdir[0] & PTE_U);
f0102081:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f0102086:	f6 00 04             	testb  $0x4,(%eax)
f0102089:	0f 84 61 09 00 00    	je     f01029f0 <mem_init+0x11b3>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010208f:	6a 02                	push   $0x2
f0102091:	68 00 10 00 00       	push   $0x1000
f0102096:	56                   	push   %esi
f0102097:	50                   	push   %eax
f0102098:	e8 d8 f6 ff ff       	call   f0101775 <page_insert>
f010209d:	83 c4 10             	add    $0x10,%esp
f01020a0:	85 c0                	test   %eax,%eax
f01020a2:	0f 85 61 09 00 00    	jne    f0102a09 <mem_init+0x11cc>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01020a8:	83 ec 04             	sub    $0x4,%esp
f01020ab:	6a 00                	push   $0x0
f01020ad:	68 00 10 00 00       	push   $0x1000
f01020b2:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f01020b8:	e8 49 f4 ff ff       	call   f0101506 <pgdir_walk>
f01020bd:	83 c4 10             	add    $0x10,%esp
f01020c0:	f6 00 02             	testb  $0x2,(%eax)
f01020c3:	0f 84 59 09 00 00    	je     f0102a22 <mem_init+0x11e5>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020c9:	83 ec 04             	sub    $0x4,%esp
f01020cc:	6a 00                	push   $0x0
f01020ce:	68 00 10 00 00       	push   $0x1000
f01020d3:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f01020d9:	e8 28 f4 ff ff       	call   f0101506 <pgdir_walk>
f01020de:	83 c4 10             	add    $0x10,%esp
f01020e1:	f6 00 04             	testb  $0x4,(%eax)
f01020e4:	0f 85 51 09 00 00    	jne    f0102a3b <mem_init+0x11fe>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01020ea:	6a 02                	push   $0x2
f01020ec:	68 00 00 40 00       	push   $0x400000
f01020f1:	57                   	push   %edi
f01020f2:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f01020f8:	e8 78 f6 ff ff       	call   f0101775 <page_insert>
f01020fd:	83 c4 10             	add    $0x10,%esp
f0102100:	85 c0                	test   %eax,%eax
f0102102:	0f 89 4c 09 00 00    	jns    f0102a54 <mem_init+0x1217>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102108:	6a 02                	push   $0x2
f010210a:	68 00 10 00 00       	push   $0x1000
f010210f:	53                   	push   %ebx
f0102110:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f0102116:	e8 5a f6 ff ff       	call   f0101775 <page_insert>
f010211b:	83 c4 10             	add    $0x10,%esp
f010211e:	85 c0                	test   %eax,%eax
f0102120:	0f 85 47 09 00 00    	jne    f0102a6d <mem_init+0x1230>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102126:	83 ec 04             	sub    $0x4,%esp
f0102129:	6a 00                	push   $0x0
f010212b:	68 00 10 00 00       	push   $0x1000
f0102130:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f0102136:	e8 cb f3 ff ff       	call   f0101506 <pgdir_walk>
f010213b:	83 c4 10             	add    $0x10,%esp
f010213e:	f6 00 04             	testb  $0x4,(%eax)
f0102141:	0f 85 3f 09 00 00    	jne    f0102a86 <mem_init+0x1249>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102147:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f010214c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010214f:	ba 00 00 00 00       	mov    $0x0,%edx
f0102154:	e8 af ee ff ff       	call   f0101008 <check_va2pa>
f0102159:	89 c1                	mov    %eax,%ecx
f010215b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010215e:	89 d8                	mov    %ebx,%eax
f0102160:	2b 05 90 5e 2a f0    	sub    0xf02a5e90,%eax
f0102166:	c1 f8 03             	sar    $0x3,%eax
f0102169:	c1 e0 0c             	shl    $0xc,%eax
f010216c:	39 c1                	cmp    %eax,%ecx
f010216e:	0f 85 2b 09 00 00    	jne    f0102a9f <mem_init+0x1262>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102174:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102179:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010217c:	e8 87 ee ff ff       	call   f0101008 <check_va2pa>
f0102181:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102184:	0f 85 2e 09 00 00    	jne    f0102ab8 <mem_init+0x127b>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010218a:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f010218f:	0f 85 3c 09 00 00    	jne    f0102ad1 <mem_init+0x1294>
	assert(pp2->pp_ref == 0);
f0102195:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010219a:	0f 85 4a 09 00 00    	jne    f0102aea <mem_init+0x12ad>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01021a0:	83 ec 0c             	sub    $0xc,%esp
f01021a3:	6a 00                	push   $0x0
f01021a5:	e8 72 f2 ff ff       	call   f010141c <page_alloc>
f01021aa:	83 c4 10             	add    $0x10,%esp
f01021ad:	85 c0                	test   %eax,%eax
f01021af:	0f 84 4e 09 00 00    	je     f0102b03 <mem_init+0x12c6>
f01021b5:	39 c6                	cmp    %eax,%esi
f01021b7:	0f 85 46 09 00 00    	jne    f0102b03 <mem_init+0x12c6>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01021bd:	83 ec 08             	sub    $0x8,%esp
f01021c0:	6a 00                	push   $0x0
f01021c2:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f01021c8:	e8 4e f5 ff ff       	call   f010171b <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01021cd:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f01021d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01021d5:	ba 00 00 00 00       	mov    $0x0,%edx
f01021da:	e8 29 ee ff ff       	call   f0101008 <check_va2pa>
f01021df:	83 c4 10             	add    $0x10,%esp
f01021e2:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021e5:	0f 85 31 09 00 00    	jne    f0102b1c <mem_init+0x12df>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01021eb:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021f0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021f3:	e8 10 ee ff ff       	call   f0101008 <check_va2pa>
f01021f8:	89 da                	mov    %ebx,%edx
f01021fa:	2b 15 90 5e 2a f0    	sub    0xf02a5e90,%edx
f0102200:	c1 fa 03             	sar    $0x3,%edx
f0102203:	c1 e2 0c             	shl    $0xc,%edx
f0102206:	39 d0                	cmp    %edx,%eax
f0102208:	0f 85 27 09 00 00    	jne    f0102b35 <mem_init+0x12f8>
	assert(pp1->pp_ref == 1);
f010220e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102213:	0f 85 35 09 00 00    	jne    f0102b4e <mem_init+0x1311>
	assert(pp2->pp_ref == 0);
f0102219:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010221e:	0f 85 43 09 00 00    	jne    f0102b67 <mem_init+0x132a>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102224:	6a 00                	push   $0x0
f0102226:	68 00 10 00 00       	push   $0x1000
f010222b:	53                   	push   %ebx
f010222c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010222f:	e8 41 f5 ff ff       	call   f0101775 <page_insert>
f0102234:	83 c4 10             	add    $0x10,%esp
f0102237:	85 c0                	test   %eax,%eax
f0102239:	0f 85 41 09 00 00    	jne    f0102b80 <mem_init+0x1343>
	assert(pp1->pp_ref);
f010223f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102244:	0f 84 4f 09 00 00    	je     f0102b99 <mem_init+0x135c>
	assert(pp1->pp_link == NULL);
f010224a:	83 3b 00             	cmpl   $0x0,(%ebx)
f010224d:	0f 85 5f 09 00 00    	jne    f0102bb2 <mem_init+0x1375>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102253:	83 ec 08             	sub    $0x8,%esp
f0102256:	68 00 10 00 00       	push   $0x1000
f010225b:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f0102261:	e8 b5 f4 ff ff       	call   f010171b <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102266:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f010226b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010226e:	ba 00 00 00 00       	mov    $0x0,%edx
f0102273:	e8 90 ed ff ff       	call   f0101008 <check_va2pa>
f0102278:	83 c4 10             	add    $0x10,%esp
f010227b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010227e:	0f 85 47 09 00 00    	jne    f0102bcb <mem_init+0x138e>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102284:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102289:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010228c:	e8 77 ed ff ff       	call   f0101008 <check_va2pa>
f0102291:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102294:	0f 85 4a 09 00 00    	jne    f0102be4 <mem_init+0x13a7>
	assert(pp1->pp_ref == 0);
f010229a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010229f:	0f 85 58 09 00 00    	jne    f0102bfd <mem_init+0x13c0>
	assert(pp2->pp_ref == 0);
f01022a5:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01022aa:	0f 85 66 09 00 00    	jne    f0102c16 <mem_init+0x13d9>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01022b0:	83 ec 0c             	sub    $0xc,%esp
f01022b3:	6a 00                	push   $0x0
f01022b5:	e8 62 f1 ff ff       	call   f010141c <page_alloc>
f01022ba:	83 c4 10             	add    $0x10,%esp
f01022bd:	85 c0                	test   %eax,%eax
f01022bf:	0f 84 6a 09 00 00    	je     f0102c2f <mem_init+0x13f2>
f01022c5:	39 c3                	cmp    %eax,%ebx
f01022c7:	0f 85 62 09 00 00    	jne    f0102c2f <mem_init+0x13f2>

	// should be no free memory
	assert(!page_alloc(0));
f01022cd:	83 ec 0c             	sub    $0xc,%esp
f01022d0:	6a 00                	push   $0x0
f01022d2:	e8 45 f1 ff ff       	call   f010141c <page_alloc>
f01022d7:	83 c4 10             	add    $0x10,%esp
f01022da:	85 c0                	test   %eax,%eax
f01022dc:	0f 85 66 09 00 00    	jne    f0102c48 <mem_init+0x140b>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022e2:	8b 0d 8c 5e 2a f0    	mov    0xf02a5e8c,%ecx
f01022e8:	8b 11                	mov    (%ecx),%edx
f01022ea:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01022f0:	89 f8                	mov    %edi,%eax
f01022f2:	2b 05 90 5e 2a f0    	sub    0xf02a5e90,%eax
f01022f8:	c1 f8 03             	sar    $0x3,%eax
f01022fb:	c1 e0 0c             	shl    $0xc,%eax
f01022fe:	39 c2                	cmp    %eax,%edx
f0102300:	0f 85 5b 09 00 00    	jne    f0102c61 <mem_init+0x1424>
	kern_pgdir[0] = 0;
f0102306:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010230c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102311:	0f 85 63 09 00 00    	jne    f0102c7a <mem_init+0x143d>
	pp0->pp_ref = 0;
f0102317:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010231d:	83 ec 0c             	sub    $0xc,%esp
f0102320:	57                   	push   %edi
f0102321:	e8 68 f1 ff ff       	call   f010148e <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102326:	83 c4 0c             	add    $0xc,%esp
f0102329:	6a 01                	push   $0x1
f010232b:	68 00 10 40 00       	push   $0x401000
f0102330:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f0102336:	e8 cb f1 ff ff       	call   f0101506 <pgdir_walk>
f010233b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010233e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102341:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f0102346:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102349:	8b 50 04             	mov    0x4(%eax),%edx
f010234c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0102352:	a1 88 5e 2a f0       	mov    0xf02a5e88,%eax
f0102357:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010235a:	89 d1                	mov    %edx,%ecx
f010235c:	c1 e9 0c             	shr    $0xc,%ecx
f010235f:	83 c4 10             	add    $0x10,%esp
f0102362:	39 c1                	cmp    %eax,%ecx
f0102364:	0f 83 29 09 00 00    	jae    f0102c93 <mem_init+0x1456>
	assert(ptep == ptep1 + PTX(va));
f010236a:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102370:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0102373:	0f 85 2f 09 00 00    	jne    f0102ca8 <mem_init+0x146b>
	kern_pgdir[PDX(va)] = 0;
f0102379:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010237c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102383:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
	return (pp - pages) << PGSHIFT;
f0102389:	89 f8                	mov    %edi,%eax
f010238b:	2b 05 90 5e 2a f0    	sub    0xf02a5e90,%eax
f0102391:	c1 f8 03             	sar    $0x3,%eax
f0102394:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102397:	89 c2                	mov    %eax,%edx
f0102399:	c1 ea 0c             	shr    $0xc,%edx
f010239c:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f010239f:	0f 86 1c 09 00 00    	jbe    f0102cc1 <mem_init+0x1484>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01023a5:	83 ec 04             	sub    $0x4,%esp
f01023a8:	68 00 10 00 00       	push   $0x1000
f01023ad:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01023b2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01023b7:	50                   	push   %eax
f01023b8:	e8 5b 3c 00 00       	call   f0106018 <memset>
	page_free(pp0);
f01023bd:	89 3c 24             	mov    %edi,(%esp)
f01023c0:	e8 c9 f0 ff ff       	call   f010148e <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01023c5:	83 c4 0c             	add    $0xc,%esp
f01023c8:	6a 01                	push   $0x1
f01023ca:	6a 00                	push   $0x0
f01023cc:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f01023d2:	e8 2f f1 ff ff       	call   f0101506 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f01023d7:	89 fa                	mov    %edi,%edx
f01023d9:	2b 15 90 5e 2a f0    	sub    0xf02a5e90,%edx
f01023df:	c1 fa 03             	sar    $0x3,%edx
f01023e2:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01023e5:	89 d0                	mov    %edx,%eax
f01023e7:	c1 e8 0c             	shr    $0xc,%eax
f01023ea:	83 c4 10             	add    $0x10,%esp
f01023ed:	3b 05 88 5e 2a f0    	cmp    0xf02a5e88,%eax
f01023f3:	0f 83 da 08 00 00    	jae    f0102cd3 <mem_init+0x1496>
	return (void *)(pa + KERNBASE);
f01023f9:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01023ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102402:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102408:	f6 00 01             	testb  $0x1,(%eax)
f010240b:	0f 85 d4 08 00 00    	jne    f0102ce5 <mem_init+0x14a8>
f0102411:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0102414:	39 d0                	cmp    %edx,%eax
f0102416:	75 f0                	jne    f0102408 <mem_init+0xbcb>
	kern_pgdir[0] = 0;
f0102418:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f010241d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102423:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102429:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010242c:	a3 40 52 2a f0       	mov    %eax,0xf02a5240

	// free the pages we took
	page_free(pp0);
f0102431:	83 ec 0c             	sub    $0xc,%esp
f0102434:	57                   	push   %edi
f0102435:	e8 54 f0 ff ff       	call   f010148e <page_free>
	page_free(pp1);
f010243a:	89 1c 24             	mov    %ebx,(%esp)
f010243d:	e8 4c f0 ff ff       	call   f010148e <page_free>
	page_free(pp2);
f0102442:	89 34 24             	mov    %esi,(%esp)
f0102445:	e8 44 f0 ff ff       	call   f010148e <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010244a:	83 c4 08             	add    $0x8,%esp
f010244d:	68 01 10 00 00       	push   $0x1001
f0102452:	6a 00                	push   $0x0
f0102454:	e8 83 f3 ff ff       	call   f01017dc <mmio_map_region>
f0102459:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f010245b:	83 c4 08             	add    $0x8,%esp
f010245e:	68 00 10 00 00       	push   $0x1000
f0102463:	6a 00                	push   $0x0
f0102465:	e8 72 f3 ff ff       	call   f01017dc <mmio_map_region>
f010246a:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f010246c:	83 c4 10             	add    $0x10,%esp
f010246f:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102475:	0f 86 83 08 00 00    	jbe    f0102cfe <mem_init+0x14c1>
f010247b:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102481:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102486:	0f 87 72 08 00 00    	ja     f0102cfe <mem_init+0x14c1>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f010248c:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102492:	0f 86 7f 08 00 00    	jbe    f0102d17 <mem_init+0x14da>
f0102498:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f010249e:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01024a4:	0f 87 6d 08 00 00    	ja     f0102d17 <mem_init+0x14da>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01024aa:	89 da                	mov    %ebx,%edx
f01024ac:	09 f2                	or     %esi,%edx
f01024ae:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01024b4:	0f 85 76 08 00 00    	jne    f0102d30 <mem_init+0x14f3>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01024ba:	39 c6                	cmp    %eax,%esi
f01024bc:	0f 82 87 08 00 00    	jb     f0102d49 <mem_init+0x150c>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01024c2:	8b 3d 8c 5e 2a f0    	mov    0xf02a5e8c,%edi
f01024c8:	89 da                	mov    %ebx,%edx
f01024ca:	89 f8                	mov    %edi,%eax
f01024cc:	e8 37 eb ff ff       	call   f0101008 <check_va2pa>
f01024d1:	85 c0                	test   %eax,%eax
f01024d3:	0f 85 89 08 00 00    	jne    f0102d62 <mem_init+0x1525>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01024d9:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01024df:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01024e2:	89 c2                	mov    %eax,%edx
f01024e4:	89 f8                	mov    %edi,%eax
f01024e6:	e8 1d eb ff ff       	call   f0101008 <check_va2pa>
f01024eb:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01024f0:	0f 85 85 08 00 00    	jne    f0102d7b <mem_init+0x153e>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01024f6:	89 f2                	mov    %esi,%edx
f01024f8:	89 f8                	mov    %edi,%eax
f01024fa:	e8 09 eb ff ff       	call   f0101008 <check_va2pa>
f01024ff:	85 c0                	test   %eax,%eax
f0102501:	0f 85 8d 08 00 00    	jne    f0102d94 <mem_init+0x1557>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102507:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f010250d:	89 f8                	mov    %edi,%eax
f010250f:	e8 f4 ea ff ff       	call   f0101008 <check_va2pa>
f0102514:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102517:	0f 85 90 08 00 00    	jne    f0102dad <mem_init+0x1570>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010251d:	83 ec 04             	sub    $0x4,%esp
f0102520:	6a 00                	push   $0x0
f0102522:	53                   	push   %ebx
f0102523:	57                   	push   %edi
f0102524:	e8 dd ef ff ff       	call   f0101506 <pgdir_walk>
f0102529:	83 c4 10             	add    $0x10,%esp
f010252c:	f6 00 1a             	testb  $0x1a,(%eax)
f010252f:	0f 84 91 08 00 00    	je     f0102dc6 <mem_init+0x1589>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102535:	83 ec 04             	sub    $0x4,%esp
f0102538:	6a 00                	push   $0x0
f010253a:	53                   	push   %ebx
f010253b:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f0102541:	e8 c0 ef ff ff       	call   f0101506 <pgdir_walk>
f0102546:	83 c4 10             	add    $0x10,%esp
f0102549:	f6 00 04             	testb  $0x4,(%eax)
f010254c:	0f 85 8d 08 00 00    	jne    f0102ddf <mem_init+0x15a2>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102552:	83 ec 04             	sub    $0x4,%esp
f0102555:	6a 00                	push   $0x0
f0102557:	53                   	push   %ebx
f0102558:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f010255e:	e8 a3 ef ff ff       	call   f0101506 <pgdir_walk>
f0102563:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102569:	83 c4 0c             	add    $0xc,%esp
f010256c:	6a 00                	push   $0x0
f010256e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102571:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f0102577:	e8 8a ef ff ff       	call   f0101506 <pgdir_walk>
f010257c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102582:	83 c4 0c             	add    $0xc,%esp
f0102585:	6a 00                	push   $0x0
f0102587:	56                   	push   %esi
f0102588:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f010258e:	e8 73 ef ff ff       	call   f0101506 <pgdir_walk>
f0102593:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102599:	c7 04 24 82 82 10 f0 	movl   $0xf0108282,(%esp)
f01025a0:	e8 f4 19 00 00       	call   f0103f99 <cprintf>
	pginfo_sz = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01025a5:	a1 88 5e 2a f0       	mov    0xf02a5e88,%eax
f01025aa:	8d 0c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ecx
f01025b1:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_region(kern_pgdir, UPAGES, pginfo_sz, PADDR(pages), PTE_U | PTE_P);
f01025b7:	a1 90 5e 2a f0       	mov    0xf02a5e90,%eax
	if ((uint32_t)kva < KERNBASE)
f01025bc:	83 c4 10             	add    $0x10,%esp
f01025bf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025c4:	0f 86 2e 08 00 00    	jbe    f0102df8 <mem_init+0x15bb>
f01025ca:	83 ec 08             	sub    $0x8,%esp
f01025cd:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01025cf:	05 00 00 00 10       	add    $0x10000000,%eax
f01025d4:	50                   	push   %eax
f01025d5:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01025da:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f01025df:	e8 39 f0 ff ff       	call   f010161d <boot_map_region>
	env_sz = ROUNDUP(npages*sizeof(struct Env), PGSIZE);
f01025e4:	8b 15 88 5e 2a f0    	mov    0xf02a5e88,%edx
f01025ea:	89 d0                	mov    %edx,%eax
f01025ec:	c1 e0 05             	shl    $0x5,%eax
f01025ef:	29 d0                	sub    %edx,%eax
f01025f1:	8d 0c 85 ff 0f 00 00 	lea    0xfff(,%eax,4),%ecx
f01025f8:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_region(kern_pgdir, UENVS, env_sz, PADDR(envs), PTE_U | PTE_P);
f01025fe:	a1 48 52 2a f0       	mov    0xf02a5248,%eax
	if ((uint32_t)kva < KERNBASE)
f0102603:	83 c4 10             	add    $0x10,%esp
f0102606:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010260b:	0f 86 fc 07 00 00    	jbe    f0102e0d <mem_init+0x15d0>
f0102611:	83 ec 08             	sub    $0x8,%esp
f0102614:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102616:	05 00 00 00 10       	add    $0x10000000,%eax
f010261b:	50                   	push   %eax
f010261c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102621:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f0102626:	e8 f2 ef ff ff       	call   f010161d <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f010262b:	83 c4 10             	add    $0x10,%esp
f010262e:	b8 00 90 11 f0       	mov    $0xf0119000,%eax
f0102633:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102638:	0f 86 e4 07 00 00    	jbe    f0102e22 <mem_init+0x15e5>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, 
f010263e:	83 ec 08             	sub    $0x8,%esp
f0102641:	6a 03                	push   $0x3
f0102643:	68 00 90 11 00       	push   $0x119000
f0102648:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010264d:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102652:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f0102657:	e8 c1 ef ff ff       	call   f010161d <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 1 << 28, // 2^32 - 0xf0000000
f010265c:	83 c4 08             	add    $0x8,%esp
f010265f:	6a 03                	push   $0x3
f0102661:	6a 00                	push   $0x0
f0102663:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102668:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010266d:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f0102672:	e8 a6 ef ff ff       	call   f010161d <boot_map_region>
f0102677:	c7 45 c8 00 70 2a f0 	movl   $0xf02a7000,-0x38(%ebp)
f010267e:	be 00 70 2e f0       	mov    $0xf02e7000,%esi
f0102683:	83 c4 10             	add    $0x10,%esp
f0102686:	bf 00 70 2a f0       	mov    $0xf02a7000,%edi
f010268b:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
f0102690:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0102696:	0f 86 9b 07 00 00    	jbe    f0102e37 <mem_init+0x15fa>
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, 
f010269c:	83 ec 08             	sub    $0x8,%esp
f010269f:	6a 02                	push   $0x2
f01026a1:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01026a7:	50                   	push   %eax
f01026a8:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01026ad:	89 da                	mov    %ebx,%edx
f01026af:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f01026b4:	e8 64 ef ff ff       	call   f010161d <boot_map_region>
f01026b9:	81 c7 00 80 00 00    	add    $0x8000,%edi
f01026bf:	81 eb 00 00 01 00    	sub    $0x10000,%ebx
	for (size_t i = 0; i < NCPU; i++) { // `ncpu` is not set yet, we just use NCPU = 8.
f01026c5:	83 c4 10             	add    $0x10,%esp
f01026c8:	39 f7                	cmp    %esi,%edi
f01026ca:	75 c4                	jne    f0102690 <mem_init+0xe53>
f01026cc:	89 7d c4             	mov    %edi,-0x3c(%ebp)
	pgdir = kern_pgdir;
f01026cf:	8b 3d 8c 5e 2a f0    	mov    0xf02a5e8c,%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01026d5:	a1 88 5e 2a f0       	mov    0xf02a5e88,%eax
f01026da:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01026dd:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01026e4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01026e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01026ec:	a1 90 5e 2a f0       	mov    0xf02a5e90,%eax
f01026f1:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01026f4:	89 45 d0             	mov    %eax,-0x30(%ebp)
	return (physaddr_t)kva - KERNBASE;
f01026f7:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
	for (i = 0; i < n; i += PGSIZE) 
f01026fd:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102702:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102705:	0f 86 71 07 00 00    	jbe    f0102e7c <mem_init+0x163f>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010270b:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102711:	89 f8                	mov    %edi,%eax
f0102713:	e8 f0 e8 ff ff       	call   f0101008 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102718:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010271f:	0f 86 27 07 00 00    	jbe    f0102e4c <mem_init+0x160f>
f0102725:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f0102728:	39 d0                	cmp    %edx,%eax
f010272a:	0f 85 33 07 00 00    	jne    f0102e63 <mem_init+0x1626>
	for (i = 0; i < n; i += PGSIZE) 
f0102730:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102736:	eb ca                	jmp    f0102702 <mem_init+0xec5>
	assert(nfree == 0);
f0102738:	68 99 81 10 f0       	push   $0xf0108199
f010273d:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102742:	68 1e 03 00 00       	push   $0x31e
f0102747:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010274c:	e8 43 d9 ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0102751:	68 a7 80 10 f0       	push   $0xf01080a7
f0102756:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010275b:	68 84 03 00 00       	push   $0x384
f0102760:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102765:	e8 2a d9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f010276a:	68 bd 80 10 f0       	push   $0xf01080bd
f010276f:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102774:	68 85 03 00 00       	push   $0x385
f0102779:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010277e:	e8 11 d9 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0102783:	68 d3 80 10 f0       	push   $0xf01080d3
f0102788:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010278d:	68 86 03 00 00       	push   $0x386
f0102792:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102797:	e8 f8 d8 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f010279c:	68 e9 80 10 f0       	push   $0xf01080e9
f01027a1:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01027a6:	68 89 03 00 00       	push   $0x389
f01027ab:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01027b0:	e8 df d8 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01027b5:	68 a0 77 10 f0       	push   $0xf01077a0
f01027ba:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01027bf:	68 8a 03 00 00       	push   $0x38a
f01027c4:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01027c9:	e8 c6 d8 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01027ce:	68 52 81 10 f0       	push   $0xf0108152
f01027d3:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01027d8:	68 91 03 00 00       	push   $0x391
f01027dd:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01027e2:	e8 ad d8 ff ff       	call   f0100094 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01027e7:	68 e0 77 10 f0       	push   $0xf01077e0
f01027ec:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01027f1:	68 94 03 00 00       	push   $0x394
f01027f6:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01027fb:	e8 94 d8 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102800:	68 18 78 10 f0       	push   $0xf0107818
f0102805:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010280a:	68 97 03 00 00       	push   $0x397
f010280f:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102814:	e8 7b d8 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102819:	68 48 78 10 f0       	push   $0xf0107848
f010281e:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102823:	68 9b 03 00 00       	push   $0x39b
f0102828:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010282d:	e8 62 d8 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102832:	68 78 78 10 f0       	push   $0xf0107878
f0102837:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010283c:	68 9c 03 00 00       	push   $0x39c
f0102841:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102846:	e8 49 d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010284b:	68 a0 78 10 f0       	push   $0xf01078a0
f0102850:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102855:	68 9d 03 00 00       	push   $0x39d
f010285a:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010285f:	e8 30 d8 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102864:	68 a4 81 10 f0       	push   $0xf01081a4
f0102869:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010286e:	68 9e 03 00 00       	push   $0x39e
f0102873:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102878:	e8 17 d8 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f010287d:	68 b5 81 10 f0       	push   $0xf01081b5
f0102882:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102887:	68 9f 03 00 00       	push   $0x39f
f010288c:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102891:	e8 fe d7 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102896:	68 d0 78 10 f0       	push   $0xf01078d0
f010289b:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01028a0:	68 a2 03 00 00       	push   $0x3a2
f01028a5:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01028aa:	e8 e5 d7 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01028af:	68 0c 79 10 f0       	push   $0xf010790c
f01028b4:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01028b9:	68 a3 03 00 00       	push   $0x3a3
f01028be:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01028c3:	e8 cc d7 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f01028c8:	68 c6 81 10 f0       	push   $0xf01081c6
f01028cd:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01028d2:	68 a4 03 00 00       	push   $0x3a4
f01028d7:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01028dc:	e8 b3 d7 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01028e1:	68 52 81 10 f0       	push   $0xf0108152
f01028e6:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01028eb:	68 a7 03 00 00       	push   $0x3a7
f01028f0:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01028f5:	e8 9a d7 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01028fa:	68 d0 78 10 f0       	push   $0xf01078d0
f01028ff:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102904:	68 aa 03 00 00       	push   $0x3aa
f0102909:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010290e:	e8 81 d7 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102913:	68 0c 79 10 f0       	push   $0xf010790c
f0102918:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010291d:	68 ab 03 00 00       	push   $0x3ab
f0102922:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102927:	e8 68 d7 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f010292c:	68 c6 81 10 f0       	push   $0xf01081c6
f0102931:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102936:	68 ac 03 00 00       	push   $0x3ac
f010293b:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102940:	e8 4f d7 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0102945:	68 52 81 10 f0       	push   $0xf0108152
f010294a:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010294f:	68 b0 03 00 00       	push   $0x3b0
f0102954:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102959:	e8 36 d7 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010295e:	50                   	push   %eax
f010295f:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0102964:	68 b3 03 00 00       	push   $0x3b3
f0102969:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010296e:	e8 21 d7 ff ff       	call   f0100094 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102973:	68 3c 79 10 f0       	push   $0xf010793c
f0102978:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010297d:	68 b4 03 00 00       	push   $0x3b4
f0102982:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102987:	e8 08 d7 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010298c:	68 7c 79 10 f0       	push   $0xf010797c
f0102991:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102996:	68 b7 03 00 00       	push   $0x3b7
f010299b:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01029a0:	e8 ef d6 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01029a5:	68 0c 79 10 f0       	push   $0xf010790c
f01029aa:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01029af:	68 b8 03 00 00       	push   $0x3b8
f01029b4:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01029b9:	e8 d6 d6 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f01029be:	68 c6 81 10 f0       	push   $0xf01081c6
f01029c3:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01029c8:	68 b9 03 00 00       	push   $0x3b9
f01029cd:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01029d2:	e8 bd d6 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01029d7:	68 bc 79 10 f0       	push   $0xf01079bc
f01029dc:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01029e1:	68 ba 03 00 00       	push   $0x3ba
f01029e6:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01029eb:	e8 a4 d6 ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01029f0:	68 d7 81 10 f0       	push   $0xf01081d7
f01029f5:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01029fa:	68 bb 03 00 00       	push   $0x3bb
f01029ff:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102a04:	e8 8b d6 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102a09:	68 d0 78 10 f0       	push   $0xf01078d0
f0102a0e:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102a13:	68 be 03 00 00       	push   $0x3be
f0102a18:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102a1d:	e8 72 d6 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102a22:	68 f0 79 10 f0       	push   $0xf01079f0
f0102a27:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102a2c:	68 bf 03 00 00       	push   $0x3bf
f0102a31:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102a36:	e8 59 d6 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102a3b:	68 24 7a 10 f0       	push   $0xf0107a24
f0102a40:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102a45:	68 c0 03 00 00       	push   $0x3c0
f0102a4a:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102a4f:	e8 40 d6 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102a54:	68 5c 7a 10 f0       	push   $0xf0107a5c
f0102a59:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102a5e:	68 c3 03 00 00       	push   $0x3c3
f0102a63:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102a68:	e8 27 d6 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102a6d:	68 94 7a 10 f0       	push   $0xf0107a94
f0102a72:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102a77:	68 c6 03 00 00       	push   $0x3c6
f0102a7c:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102a81:	e8 0e d6 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102a86:	68 24 7a 10 f0       	push   $0xf0107a24
f0102a8b:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102a90:	68 c7 03 00 00       	push   $0x3c7
f0102a95:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102a9a:	e8 f5 d5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102a9f:	68 d0 7a 10 f0       	push   $0xf0107ad0
f0102aa4:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102aa9:	68 ca 03 00 00       	push   $0x3ca
f0102aae:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102ab3:	e8 dc d5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102ab8:	68 fc 7a 10 f0       	push   $0xf0107afc
f0102abd:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102ac2:	68 cb 03 00 00       	push   $0x3cb
f0102ac7:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102acc:	e8 c3 d5 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 2);
f0102ad1:	68 ed 81 10 f0       	push   $0xf01081ed
f0102ad6:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102adb:	68 cd 03 00 00       	push   $0x3cd
f0102ae0:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102ae5:	e8 aa d5 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102aea:	68 fe 81 10 f0       	push   $0xf01081fe
f0102aef:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102af4:	68 ce 03 00 00       	push   $0x3ce
f0102af9:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102afe:	e8 91 d5 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102b03:	68 2c 7b 10 f0       	push   $0xf0107b2c
f0102b08:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102b0d:	68 d1 03 00 00       	push   $0x3d1
f0102b12:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102b17:	e8 78 d5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102b1c:	68 50 7b 10 f0       	push   $0xf0107b50
f0102b21:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102b26:	68 d5 03 00 00       	push   $0x3d5
f0102b2b:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102b30:	e8 5f d5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102b35:	68 fc 7a 10 f0       	push   $0xf0107afc
f0102b3a:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102b3f:	68 d6 03 00 00       	push   $0x3d6
f0102b44:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102b49:	e8 46 d5 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102b4e:	68 a4 81 10 f0       	push   $0xf01081a4
f0102b53:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102b58:	68 d7 03 00 00       	push   $0x3d7
f0102b5d:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102b62:	e8 2d d5 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102b67:	68 fe 81 10 f0       	push   $0xf01081fe
f0102b6c:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102b71:	68 d8 03 00 00       	push   $0x3d8
f0102b76:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102b7b:	e8 14 d5 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102b80:	68 74 7b 10 f0       	push   $0xf0107b74
f0102b85:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102b8a:	68 db 03 00 00       	push   $0x3db
f0102b8f:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102b94:	e8 fb d4 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f0102b99:	68 0f 82 10 f0       	push   $0xf010820f
f0102b9e:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102ba3:	68 dc 03 00 00       	push   $0x3dc
f0102ba8:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102bad:	e8 e2 d4 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f0102bb2:	68 1b 82 10 f0       	push   $0xf010821b
f0102bb7:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102bbc:	68 dd 03 00 00       	push   $0x3dd
f0102bc1:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102bc6:	e8 c9 d4 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102bcb:	68 50 7b 10 f0       	push   $0xf0107b50
f0102bd0:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102bd5:	68 e1 03 00 00       	push   $0x3e1
f0102bda:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102bdf:	e8 b0 d4 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102be4:	68 ac 7b 10 f0       	push   $0xf0107bac
f0102be9:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102bee:	68 e2 03 00 00       	push   $0x3e2
f0102bf3:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102bf8:	e8 97 d4 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102bfd:	68 30 82 10 f0       	push   $0xf0108230
f0102c02:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102c07:	68 e3 03 00 00       	push   $0x3e3
f0102c0c:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102c11:	e8 7e d4 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102c16:	68 fe 81 10 f0       	push   $0xf01081fe
f0102c1b:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102c20:	68 e4 03 00 00       	push   $0x3e4
f0102c25:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102c2a:	e8 65 d4 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102c2f:	68 d4 7b 10 f0       	push   $0xf0107bd4
f0102c34:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102c39:	68 e7 03 00 00       	push   $0x3e7
f0102c3e:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102c43:	e8 4c d4 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0102c48:	68 52 81 10 f0       	push   $0xf0108152
f0102c4d:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102c52:	68 ea 03 00 00       	push   $0x3ea
f0102c57:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102c5c:	e8 33 d4 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c61:	68 78 78 10 f0       	push   $0xf0107878
f0102c66:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102c6b:	68 ed 03 00 00       	push   $0x3ed
f0102c70:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102c75:	e8 1a d4 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0102c7a:	68 b5 81 10 f0       	push   $0xf01081b5
f0102c7f:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102c84:	68 ef 03 00 00       	push   $0x3ef
f0102c89:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102c8e:	e8 01 d4 ff ff       	call   f0100094 <_panic>
f0102c93:	52                   	push   %edx
f0102c94:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0102c99:	68 f6 03 00 00       	push   $0x3f6
f0102c9e:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102ca3:	e8 ec d3 ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102ca8:	68 41 82 10 f0       	push   $0xf0108241
f0102cad:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102cb2:	68 f7 03 00 00       	push   $0x3f7
f0102cb7:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102cbc:	e8 d3 d3 ff ff       	call   f0100094 <_panic>
f0102cc1:	50                   	push   %eax
f0102cc2:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0102cc7:	6a 58                	push   $0x58
f0102cc9:	68 89 7f 10 f0       	push   $0xf0107f89
f0102cce:	e8 c1 d3 ff ff       	call   f0100094 <_panic>
f0102cd3:	52                   	push   %edx
f0102cd4:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0102cd9:	6a 58                	push   $0x58
f0102cdb:	68 89 7f 10 f0       	push   $0xf0107f89
f0102ce0:	e8 af d3 ff ff       	call   f0100094 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102ce5:	68 59 82 10 f0       	push   $0xf0108259
f0102cea:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102cef:	68 01 04 00 00       	push   $0x401
f0102cf4:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102cf9:	e8 96 d3 ff ff       	call   f0100094 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102cfe:	68 f8 7b 10 f0       	push   $0xf0107bf8
f0102d03:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102d08:	68 11 04 00 00       	push   $0x411
f0102d0d:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102d12:	e8 7d d3 ff ff       	call   f0100094 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102d17:	68 20 7c 10 f0       	push   $0xf0107c20
f0102d1c:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102d21:	68 12 04 00 00       	push   $0x412
f0102d26:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102d2b:	e8 64 d3 ff ff       	call   f0100094 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102d30:	68 48 7c 10 f0       	push   $0xf0107c48
f0102d35:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102d3a:	68 14 04 00 00       	push   $0x414
f0102d3f:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102d44:	e8 4b d3 ff ff       	call   f0100094 <_panic>
	assert(mm1 + 8096 <= mm2);
f0102d49:	68 70 82 10 f0       	push   $0xf0108270
f0102d4e:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102d53:	68 16 04 00 00       	push   $0x416
f0102d58:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102d5d:	e8 32 d3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102d62:	68 70 7c 10 f0       	push   $0xf0107c70
f0102d67:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102d6c:	68 18 04 00 00       	push   $0x418
f0102d71:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102d76:	e8 19 d3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102d7b:	68 94 7c 10 f0       	push   $0xf0107c94
f0102d80:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102d85:	68 19 04 00 00       	push   $0x419
f0102d8a:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102d8f:	e8 00 d3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102d94:	68 c4 7c 10 f0       	push   $0xf0107cc4
f0102d99:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102d9e:	68 1a 04 00 00       	push   $0x41a
f0102da3:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102da8:	e8 e7 d2 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102dad:	68 e8 7c 10 f0       	push   $0xf0107ce8
f0102db2:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102db7:	68 1b 04 00 00       	push   $0x41b
f0102dbc:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102dc1:	e8 ce d2 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102dc6:	68 14 7d 10 f0       	push   $0xf0107d14
f0102dcb:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102dd0:	68 1d 04 00 00       	push   $0x41d
f0102dd5:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102dda:	e8 b5 d2 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102ddf:	68 58 7d 10 f0       	push   $0xf0107d58
f0102de4:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102de9:	68 1e 04 00 00       	push   $0x41e
f0102dee:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102df3:	e8 9c d2 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102df8:	50                   	push   %eax
f0102df9:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0102dfe:	68 bd 00 00 00       	push   $0xbd
f0102e03:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102e08:	e8 87 d2 ff ff       	call   f0100094 <_panic>
f0102e0d:	50                   	push   %eax
f0102e0e:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0102e13:	68 c7 00 00 00       	push   $0xc7
f0102e18:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102e1d:	e8 72 d2 ff ff       	call   f0100094 <_panic>
f0102e22:	50                   	push   %eax
f0102e23:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0102e28:	68 d4 00 00 00       	push   $0xd4
f0102e2d:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102e32:	e8 5d d2 ff ff       	call   f0100094 <_panic>
f0102e37:	57                   	push   %edi
f0102e38:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0102e3d:	68 14 01 00 00       	push   $0x114
f0102e42:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102e47:	e8 48 d2 ff ff       	call   f0100094 <_panic>
f0102e4c:	ff 75 c0             	pushl  -0x40(%ebp)
f0102e4f:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0102e54:	68 36 03 00 00       	push   $0x336
f0102e59:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102e5e:	e8 31 d2 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e63:	68 8c 7d 10 f0       	push   $0xf0107d8c
f0102e68:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102e6d:	68 36 03 00 00       	push   $0x336
f0102e72:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102e77:	e8 18 d2 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102e7c:	a1 48 52 2a f0       	mov    0xf02a5248,%eax
f0102e81:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((uint32_t)kva < KERNBASE)
f0102e84:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102e87:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102e8c:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f0102e92:	89 da                	mov    %ebx,%edx
f0102e94:	89 f8                	mov    %edi,%eax
f0102e96:	e8 6d e1 ff ff       	call   f0101008 <check_va2pa>
f0102e9b:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102ea2:	76 22                	jbe    f0102ec6 <mem_init+0x1689>
f0102ea4:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102ea7:	39 d0                	cmp    %edx,%eax
f0102ea9:	75 32                	jne    f0102edd <mem_init+0x16a0>
f0102eab:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f0102eb1:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102eb7:	75 d9                	jne    f0102e92 <mem_init+0x1655>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102eb9:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102ebc:	c1 e6 0c             	shl    $0xc,%esi
f0102ebf:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102ec4:	eb 4b                	jmp    f0102f11 <mem_init+0x16d4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ec6:	ff 75 d0             	pushl  -0x30(%ebp)
f0102ec9:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0102ece:	68 3b 03 00 00       	push   $0x33b
f0102ed3:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102ed8:	e8 b7 d1 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102edd:	68 c0 7d 10 f0       	push   $0xf0107dc0
f0102ee2:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102ee7:	68 3b 03 00 00       	push   $0x33b
f0102eec:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102ef1:	e8 9e d1 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102ef6:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102efc:	89 f8                	mov    %edi,%eax
f0102efe:	e8 05 e1 ff ff       	call   f0101008 <check_va2pa>
f0102f03:	39 c3                	cmp    %eax,%ebx
f0102f05:	0f 85 f5 00 00 00    	jne    f0103000 <mem_init+0x17c3>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102f0b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f11:	39 f3                	cmp    %esi,%ebx
f0102f13:	72 e1                	jb     f0102ef6 <mem_init+0x16b9>
f0102f15:	c7 45 d4 00 70 2a f0 	movl   $0xf02a7000,-0x2c(%ebp)
f0102f1c:	c7 45 cc 00 80 ff ef 	movl   $0xefff8000,-0x34(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102f23:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f26:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0102f29:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0102f2c:	8d 83 00 80 00 00    	lea    0x8000(%ebx),%eax
f0102f32:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102f35:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102f38:	8d b0 00 80 00 20    	lea    0x20008000(%eax),%esi
f0102f3e:	89 da                	mov    %ebx,%edx
f0102f40:	89 f8                	mov    %edi,%eax
f0102f42:	e8 c1 e0 ff ff       	call   f0101008 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102f47:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102f4e:	0f 86 c5 00 00 00    	jbe    f0103019 <mem_init+0x17dc>
f0102f54:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102f57:	39 d0                	cmp    %edx,%eax
f0102f59:	0f 85 d1 00 00 00    	jne    f0103030 <mem_init+0x17f3>
f0102f5f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102f65:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102f68:	75 d4                	jne    f0102f3e <mem_init+0x1701>
f0102f6a:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102f6d:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102f73:	89 da                	mov    %ebx,%edx
f0102f75:	89 f8                	mov    %edi,%eax
f0102f77:	e8 8c e0 ff ff       	call   f0101008 <check_va2pa>
f0102f7c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102f7f:	0f 85 c4 00 00 00    	jne    f0103049 <mem_init+0x180c>
f0102f85:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102f8b:	39 f3                	cmp    %esi,%ebx
f0102f8d:	75 e4                	jne    f0102f73 <mem_init+0x1736>
f0102f8f:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102f96:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102f9d:	81 45 d4 00 80 00 00 	addl   $0x8000,-0x2c(%ebp)
f0102fa4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	for (n = 0; n < NCPU; n++) {
f0102fa7:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
f0102faa:	0f 85 73 ff ff ff    	jne    f0102f23 <mem_init+0x16e6>
	for (i = 0; i < NPDENTRIES; i++) {
f0102fb0:	b8 00 00 00 00       	mov    $0x0,%eax
			if (i >= PDX(KERNBASE)) {
f0102fb5:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102fba:	0f 87 a2 00 00 00    	ja     f0103062 <mem_init+0x1825>
				assert(pgdir[i] == 0);
f0102fc0:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102fc4:	0f 85 db 00 00 00    	jne    f01030a5 <mem_init+0x1868>
	for (i = 0; i < NPDENTRIES; i++) {
f0102fca:	40                   	inc    %eax
f0102fcb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102fd0:	0f 87 e8 00 00 00    	ja     f01030be <mem_init+0x1881>
		switch (i) {
f0102fd6:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102fdc:	83 fa 04             	cmp    $0x4,%edx
f0102fdf:	77 d4                	ja     f0102fb5 <mem_init+0x1778>
			assert(pgdir[i] & PTE_P);
f0102fe1:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102fe5:	75 e3                	jne    f0102fca <mem_init+0x178d>
f0102fe7:	68 9b 82 10 f0       	push   $0xf010829b
f0102fec:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102ff1:	68 54 03 00 00       	push   $0x354
f0102ff6:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102ffb:	e8 94 d0 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0103000:	68 f4 7d 10 f0       	push   $0xf0107df4
f0103005:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010300a:	68 3f 03 00 00       	push   $0x33f
f010300f:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0103014:	e8 7b d0 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103019:	ff 75 c0             	pushl  -0x40(%ebp)
f010301c:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0103021:	68 47 03 00 00       	push   $0x347
f0103026:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010302b:	e8 64 d0 ff ff       	call   f0100094 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103030:	68 1c 7e 10 f0       	push   $0xf0107e1c
f0103035:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010303a:	68 47 03 00 00       	push   $0x347
f010303f:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0103044:	e8 4b d0 ff ff       	call   f0100094 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0103049:	68 64 7e 10 f0       	push   $0xf0107e64
f010304e:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0103053:	68 49 03 00 00       	push   $0x349
f0103058:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010305d:	e8 32 d0 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_P);
f0103062:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103065:	f6 c2 01             	test   $0x1,%dl
f0103068:	74 22                	je     f010308c <mem_init+0x184f>
				assert(pgdir[i] & PTE_W);
f010306a:	f6 c2 02             	test   $0x2,%dl
f010306d:	0f 85 57 ff ff ff    	jne    f0102fca <mem_init+0x178d>
f0103073:	68 ac 82 10 f0       	push   $0xf01082ac
f0103078:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010307d:	68 59 03 00 00       	push   $0x359
f0103082:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0103087:	e8 08 d0 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_P);
f010308c:	68 9b 82 10 f0       	push   $0xf010829b
f0103091:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0103096:	68 58 03 00 00       	push   $0x358
f010309b:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01030a0:	e8 ef cf ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] == 0);
f01030a5:	68 bd 82 10 f0       	push   $0xf01082bd
f01030aa:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01030af:	68 5b 03 00 00       	push   $0x35b
f01030b4:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01030b9:	e8 d6 cf ff ff       	call   f0100094 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f01030be:	83 ec 0c             	sub    $0xc,%esp
f01030c1:	68 88 7e 10 f0       	push   $0xf0107e88
f01030c6:	e8 ce 0e 00 00       	call   f0103f99 <cprintf>
	lcr3(PADDR(kern_pgdir));
f01030cb:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01030d0:	83 c4 10             	add    $0x10,%esp
f01030d3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030d8:	0f 86 fe 01 00 00    	jbe    f01032dc <mem_init+0x1a9f>
	return (physaddr_t)kva - KERNBASE;
f01030de:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01030e3:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f01030e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01030eb:	e8 77 df ff ff       	call   f0101067 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01030f0:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01030f3:	83 e0 f3             	and    $0xfffffff3,%eax
f01030f6:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01030fb:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01030fe:	83 ec 0c             	sub    $0xc,%esp
f0103101:	6a 00                	push   $0x0
f0103103:	e8 14 e3 ff ff       	call   f010141c <page_alloc>
f0103108:	89 c3                	mov    %eax,%ebx
f010310a:	83 c4 10             	add    $0x10,%esp
f010310d:	85 c0                	test   %eax,%eax
f010310f:	0f 84 dc 01 00 00    	je     f01032f1 <mem_init+0x1ab4>
	assert((pp1 = page_alloc(0)));
f0103115:	83 ec 0c             	sub    $0xc,%esp
f0103118:	6a 00                	push   $0x0
f010311a:	e8 fd e2 ff ff       	call   f010141c <page_alloc>
f010311f:	89 c7                	mov    %eax,%edi
f0103121:	83 c4 10             	add    $0x10,%esp
f0103124:	85 c0                	test   %eax,%eax
f0103126:	0f 84 de 01 00 00    	je     f010330a <mem_init+0x1acd>
	assert((pp2 = page_alloc(0)));
f010312c:	83 ec 0c             	sub    $0xc,%esp
f010312f:	6a 00                	push   $0x0
f0103131:	e8 e6 e2 ff ff       	call   f010141c <page_alloc>
f0103136:	89 c6                	mov    %eax,%esi
f0103138:	83 c4 10             	add    $0x10,%esp
f010313b:	85 c0                	test   %eax,%eax
f010313d:	0f 84 e0 01 00 00    	je     f0103323 <mem_init+0x1ae6>
	page_free(pp0);
f0103143:	83 ec 0c             	sub    $0xc,%esp
f0103146:	53                   	push   %ebx
f0103147:	e8 42 e3 ff ff       	call   f010148e <page_free>
	return (pp - pages) << PGSHIFT;
f010314c:	89 f8                	mov    %edi,%eax
f010314e:	2b 05 90 5e 2a f0    	sub    0xf02a5e90,%eax
f0103154:	c1 f8 03             	sar    $0x3,%eax
f0103157:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010315a:	89 c2                	mov    %eax,%edx
f010315c:	c1 ea 0c             	shr    $0xc,%edx
f010315f:	83 c4 10             	add    $0x10,%esp
f0103162:	3b 15 88 5e 2a f0    	cmp    0xf02a5e88,%edx
f0103168:	0f 83 ce 01 00 00    	jae    f010333c <mem_init+0x1aff>
	memset(page2kva(pp1), 1, PGSIZE);
f010316e:	83 ec 04             	sub    $0x4,%esp
f0103171:	68 00 10 00 00       	push   $0x1000
f0103176:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0103178:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010317d:	50                   	push   %eax
f010317e:	e8 95 2e 00 00       	call   f0106018 <memset>
	return (pp - pages) << PGSHIFT;
f0103183:	89 f0                	mov    %esi,%eax
f0103185:	2b 05 90 5e 2a f0    	sub    0xf02a5e90,%eax
f010318b:	c1 f8 03             	sar    $0x3,%eax
f010318e:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0103191:	89 c2                	mov    %eax,%edx
f0103193:	c1 ea 0c             	shr    $0xc,%edx
f0103196:	83 c4 10             	add    $0x10,%esp
f0103199:	3b 15 88 5e 2a f0    	cmp    0xf02a5e88,%edx
f010319f:	0f 83 a9 01 00 00    	jae    f010334e <mem_init+0x1b11>
	memset(page2kva(pp2), 2, PGSIZE);
f01031a5:	83 ec 04             	sub    $0x4,%esp
f01031a8:	68 00 10 00 00       	push   $0x1000
f01031ad:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f01031af:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01031b4:	50                   	push   %eax
f01031b5:	e8 5e 2e 00 00       	call   f0106018 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01031ba:	6a 02                	push   $0x2
f01031bc:	68 00 10 00 00       	push   $0x1000
f01031c1:	57                   	push   %edi
f01031c2:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f01031c8:	e8 a8 e5 ff ff       	call   f0101775 <page_insert>
	assert(pp1->pp_ref == 1);
f01031cd:	83 c4 20             	add    $0x20,%esp
f01031d0:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01031d5:	0f 85 85 01 00 00    	jne    f0103360 <mem_init+0x1b23>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01031db:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01031e2:	01 01 01 
f01031e5:	0f 85 8e 01 00 00    	jne    f0103379 <mem_init+0x1b3c>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01031eb:	6a 02                	push   $0x2
f01031ed:	68 00 10 00 00       	push   $0x1000
f01031f2:	56                   	push   %esi
f01031f3:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f01031f9:	e8 77 e5 ff ff       	call   f0101775 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01031fe:	83 c4 10             	add    $0x10,%esp
f0103201:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103208:	02 02 02 
f010320b:	0f 85 81 01 00 00    	jne    f0103392 <mem_init+0x1b55>
	assert(pp2->pp_ref == 1);
f0103211:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103216:	0f 85 8f 01 00 00    	jne    f01033ab <mem_init+0x1b6e>
	assert(pp1->pp_ref == 0);
f010321c:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103221:	0f 85 9d 01 00 00    	jne    f01033c4 <mem_init+0x1b87>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103227:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010322e:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0103231:	89 f0                	mov    %esi,%eax
f0103233:	2b 05 90 5e 2a f0    	sub    0xf02a5e90,%eax
f0103239:	c1 f8 03             	sar    $0x3,%eax
f010323c:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010323f:	89 c2                	mov    %eax,%edx
f0103241:	c1 ea 0c             	shr    $0xc,%edx
f0103244:	3b 15 88 5e 2a f0    	cmp    0xf02a5e88,%edx
f010324a:	0f 83 8d 01 00 00    	jae    f01033dd <mem_init+0x1ba0>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103250:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103257:	03 03 03 
f010325a:	0f 85 8f 01 00 00    	jne    f01033ef <mem_init+0x1bb2>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103260:	83 ec 08             	sub    $0x8,%esp
f0103263:	68 00 10 00 00       	push   $0x1000
f0103268:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f010326e:	e8 a8 e4 ff ff       	call   f010171b <page_remove>
	assert(pp2->pp_ref == 0);
f0103273:	83 c4 10             	add    $0x10,%esp
f0103276:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010327b:	0f 85 87 01 00 00    	jne    f0103408 <mem_init+0x1bcb>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103281:	8b 0d 8c 5e 2a f0    	mov    0xf02a5e8c,%ecx
f0103287:	8b 11                	mov    (%ecx),%edx
f0103289:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f010328f:	89 d8                	mov    %ebx,%eax
f0103291:	2b 05 90 5e 2a f0    	sub    0xf02a5e90,%eax
f0103297:	c1 f8 03             	sar    $0x3,%eax
f010329a:	c1 e0 0c             	shl    $0xc,%eax
f010329d:	39 c2                	cmp    %eax,%edx
f010329f:	0f 85 7c 01 00 00    	jne    f0103421 <mem_init+0x1be4>
	kern_pgdir[0] = 0;
f01032a5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01032ab:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01032b0:	0f 85 84 01 00 00    	jne    f010343a <mem_init+0x1bfd>
	pp0->pp_ref = 0;
f01032b6:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f01032bc:	83 ec 0c             	sub    $0xc,%esp
f01032bf:	53                   	push   %ebx
f01032c0:	e8 c9 e1 ff ff       	call   f010148e <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01032c5:	c7 04 24 1c 7f 10 f0 	movl   $0xf0107f1c,(%esp)
f01032cc:	e8 c8 0c 00 00       	call   f0103f99 <cprintf>
}
f01032d1:	83 c4 10             	add    $0x10,%esp
f01032d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01032d7:	5b                   	pop    %ebx
f01032d8:	5e                   	pop    %esi
f01032d9:	5f                   	pop    %edi
f01032da:	5d                   	pop    %ebp
f01032db:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032dc:	50                   	push   %eax
f01032dd:	68 cc 6e 10 f0       	push   $0xf0106ecc
f01032e2:	68 ed 00 00 00       	push   $0xed
f01032e7:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01032ec:	e8 a3 cd ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f01032f1:	68 a7 80 10 f0       	push   $0xf01080a7
f01032f6:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01032fb:	68 33 04 00 00       	push   $0x433
f0103300:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0103305:	e8 8a cd ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f010330a:	68 bd 80 10 f0       	push   $0xf01080bd
f010330f:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0103314:	68 34 04 00 00       	push   $0x434
f0103319:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010331e:	e8 71 cd ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0103323:	68 d3 80 10 f0       	push   $0xf01080d3
f0103328:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010332d:	68 35 04 00 00       	push   $0x435
f0103332:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0103337:	e8 58 cd ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010333c:	50                   	push   %eax
f010333d:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0103342:	6a 58                	push   $0x58
f0103344:	68 89 7f 10 f0       	push   $0xf0107f89
f0103349:	e8 46 cd ff ff       	call   f0100094 <_panic>
f010334e:	50                   	push   %eax
f010334f:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0103354:	6a 58                	push   $0x58
f0103356:	68 89 7f 10 f0       	push   $0xf0107f89
f010335b:	e8 34 cd ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0103360:	68 a4 81 10 f0       	push   $0xf01081a4
f0103365:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010336a:	68 3a 04 00 00       	push   $0x43a
f010336f:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0103374:	e8 1b cd ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103379:	68 a8 7e 10 f0       	push   $0xf0107ea8
f010337e:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0103383:	68 3b 04 00 00       	push   $0x43b
f0103388:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010338d:	e8 02 cd ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103392:	68 cc 7e 10 f0       	push   $0xf0107ecc
f0103397:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010339c:	68 3d 04 00 00       	push   $0x43d
f01033a1:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01033a6:	e8 e9 cc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f01033ab:	68 c6 81 10 f0       	push   $0xf01081c6
f01033b0:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01033b5:	68 3e 04 00 00       	push   $0x43e
f01033ba:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01033bf:	e8 d0 cc ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f01033c4:	68 30 82 10 f0       	push   $0xf0108230
f01033c9:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01033ce:	68 3f 04 00 00       	push   $0x43f
f01033d3:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01033d8:	e8 b7 cc ff ff       	call   f0100094 <_panic>
f01033dd:	50                   	push   %eax
f01033de:	68 a8 6e 10 f0       	push   $0xf0106ea8
f01033e3:	6a 58                	push   $0x58
f01033e5:	68 89 7f 10 f0       	push   $0xf0107f89
f01033ea:	e8 a5 cc ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01033ef:	68 f0 7e 10 f0       	push   $0xf0107ef0
f01033f4:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01033f9:	68 41 04 00 00       	push   $0x441
f01033fe:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0103403:	e8 8c cc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0103408:	68 fe 81 10 f0       	push   $0xf01081fe
f010340d:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0103412:	68 43 04 00 00       	push   $0x443
f0103417:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010341c:	e8 73 cc ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103421:	68 78 78 10 f0       	push   $0xf0107878
f0103426:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010342b:	68 46 04 00 00       	push   $0x446
f0103430:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0103435:	e8 5a cc ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f010343a:	68 b5 81 10 f0       	push   $0xf01081b5
f010343f:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0103444:	68 48 04 00 00       	push   $0x448
f0103449:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010344e:	e8 41 cc ff ff       	call   f0100094 <_panic>

f0103453 <user_mem_check>:
{
f0103453:	55                   	push   %ebp
f0103454:	89 e5                	mov    %esp,%ebp
f0103456:	57                   	push   %edi
f0103457:	56                   	push   %esi
f0103458:	53                   	push   %ebx
f0103459:	83 ec 1c             	sub    $0x1c,%esp
f010345c:	8b 7d 08             	mov    0x8(%ebp),%edi
	void *l = ROUNDDOWN((void*)va, PGSIZE), *r = ROUNDUP((void*)va + len, PGSIZE);
f010345f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103462:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103465:	89 c3                	mov    %eax,%ebx
f0103467:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010346d:	89 c6                	mov    %eax,%esi
f010346f:	03 75 10             	add    0x10(%ebp),%esi
f0103472:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
f0103478:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for (; l < r; l += PGSIZE) {
f010347e:	39 f3                	cmp    %esi,%ebx
f0103480:	0f 83 83 00 00 00    	jae    f0103509 <user_mem_check+0xb6>
		if ((uintptr_t)l >= ULIM) {// Higher than ULIM
f0103486:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103489:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010348f:	77 2d                	ja     f01034be <user_mem_check+0x6b>
		pte_t* pte = pgdir_walk(env->env_pgdir, l, 0);
f0103491:	83 ec 04             	sub    $0x4,%esp
f0103494:	6a 00                	push   $0x0
f0103496:	53                   	push   %ebx
f0103497:	ff 77 60             	pushl  0x60(%edi)
f010349a:	e8 67 e0 ff ff       	call   f0101506 <pgdir_walk>
		if (!pte) {
f010349f:	83 c4 10             	add    $0x10,%esp
f01034a2:	85 c0                	test   %eax,%eax
f01034a4:	74 2f                	je     f01034d5 <user_mem_check+0x82>
		uint32_t given_perm = *pte & 0xFFF;
f01034a6:	8b 00                	mov    (%eax),%eax
f01034a8:	25 ff 0f 00 00       	and    $0xfff,%eax
		if ((given_perm | perm) > given_perm) {
f01034ad:	89 c2                	mov    %eax,%edx
f01034af:	0b 55 14             	or     0x14(%ebp),%edx
f01034b2:	39 c2                	cmp    %eax,%edx
f01034b4:	77 39                	ja     f01034ef <user_mem_check+0x9c>
	for (; l < r; l += PGSIZE) {
f01034b6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01034bc:	eb c0                	jmp    f010347e <user_mem_check+0x2b>
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f01034be:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f01034c1:	72 03                	jb     f01034c6 <user_mem_check+0x73>
		if ((uintptr_t)l >= ULIM) {// Higher than ULIM
f01034c3:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f01034c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034c9:	a3 3c 52 2a f0       	mov    %eax,0xf02a523c
			return -E_FAULT;
f01034ce:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034d3:	eb 39                	jmp    f010350e <user_mem_check+0xbb>
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f01034d5:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f01034d8:	72 06                	jb     f01034e0 <user_mem_check+0x8d>
		if ((uintptr_t)l >= ULIM) {// Higher than ULIM
f01034da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01034dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f01034e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034e3:	a3 3c 52 2a f0       	mov    %eax,0xf02a523c
			return -E_FAULT;
f01034e8:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034ed:	eb 1f                	jmp    f010350e <user_mem_check+0xbb>
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f01034ef:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f01034f2:	72 06                	jb     f01034fa <user_mem_check+0xa7>
		if ((uintptr_t)l >= ULIM) {// Higher than ULIM
f01034f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01034f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f01034fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034fd:	a3 3c 52 2a f0       	mov    %eax,0xf02a523c
			return -E_FAULT;
f0103502:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103507:	eb 05                	jmp    f010350e <user_mem_check+0xbb>
	return 0;
f0103509:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010350e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103511:	5b                   	pop    %ebx
f0103512:	5e                   	pop    %esi
f0103513:	5f                   	pop    %edi
f0103514:	5d                   	pop    %ebp
f0103515:	c3                   	ret    

f0103516 <user_mem_assert>:
{
f0103516:	55                   	push   %ebp
f0103517:	89 e5                	mov    %esp,%ebp
f0103519:	53                   	push   %ebx
f010351a:	83 ec 04             	sub    $0x4,%esp
f010351d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103520:	8b 45 14             	mov    0x14(%ebp),%eax
f0103523:	83 c8 04             	or     $0x4,%eax
f0103526:	50                   	push   %eax
f0103527:	ff 75 10             	pushl  0x10(%ebp)
f010352a:	ff 75 0c             	pushl  0xc(%ebp)
f010352d:	53                   	push   %ebx
f010352e:	e8 20 ff ff ff       	call   f0103453 <user_mem_check>
f0103533:	83 c4 10             	add    $0x10,%esp
f0103536:	85 c0                	test   %eax,%eax
f0103538:	78 05                	js     f010353f <user_mem_assert+0x29>
}
f010353a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010353d:	c9                   	leave  
f010353e:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f010353f:	83 ec 04             	sub    $0x4,%esp
f0103542:	ff 35 3c 52 2a f0    	pushl  0xf02a523c
f0103548:	ff 73 48             	pushl  0x48(%ebx)
f010354b:	68 48 7f 10 f0       	push   $0xf0107f48
f0103550:	e8 44 0a 00 00       	call   f0103f99 <cprintf>
		env_destroy(env);	// may not return
f0103555:	89 1c 24             	mov    %ebx,(%esp)
f0103558:	e8 f4 06 00 00       	call   f0103c51 <env_destroy>
f010355d:	83 c4 10             	add    $0x10,%esp
}
f0103560:	eb d8                	jmp    f010353a <user_mem_assert+0x24>

f0103562 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103562:	55                   	push   %ebp
f0103563:	89 e5                	mov    %esp,%ebp
f0103565:	56                   	push   %esi
f0103566:	53                   	push   %ebx
f0103567:	8b 45 08             	mov    0x8(%ebp),%eax
f010356a:	8b 75 10             	mov    0x10(%ebp),%esi
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010356d:	85 c0                	test   %eax,%eax
f010356f:	74 37                	je     f01035a8 <envid2env+0x46>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103571:	89 c1                	mov    %eax,%ecx
f0103573:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f0103579:	89 ca                	mov    %ecx,%edx
f010357b:	c1 e2 05             	shl    $0x5,%edx
f010357e:	29 ca                	sub    %ecx,%edx
f0103580:	8b 0d 48 52 2a f0    	mov    0xf02a5248,%ecx
f0103586:	8d 1c 91             	lea    (%ecx,%edx,4),%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103589:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f010358d:	74 3d                	je     f01035cc <envid2env+0x6a>
f010358f:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103592:	75 38                	jne    f01035cc <envid2env+0x6a>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103594:	89 f0                	mov    %esi,%eax
f0103596:	84 c0                	test   %al,%al
f0103598:	75 42                	jne    f01035dc <envid2env+0x7a>
		*env_store = 0;
		return -E_BAD_ENV;
	}

	*env_store = e;
f010359a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010359d:	89 18                	mov    %ebx,(%eax)
	return 0;
f010359f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01035a4:	5b                   	pop    %ebx
f01035a5:	5e                   	pop    %esi
f01035a6:	5d                   	pop    %ebp
f01035a7:	c3                   	ret    
		*env_store = curenv;
f01035a8:	e8 75 31 00 00       	call   f0106722 <cpunum>
f01035ad:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01035b0:	01 c2                	add    %eax,%edx
f01035b2:	01 d2                	add    %edx,%edx
f01035b4:	01 c2                	add    %eax,%edx
f01035b6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01035b9:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f01035c0:	8b 75 0c             	mov    0xc(%ebp),%esi
f01035c3:	89 06                	mov    %eax,(%esi)
		return 0;
f01035c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01035ca:	eb d8                	jmp    f01035a4 <envid2env+0x42>
		*env_store = 0;
f01035cc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035cf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01035d5:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01035da:	eb c8                	jmp    f01035a4 <envid2env+0x42>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01035dc:	e8 41 31 00 00       	call   f0106722 <cpunum>
f01035e1:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01035e4:	01 c2                	add    %eax,%edx
f01035e6:	01 d2                	add    %edx,%edx
f01035e8:	01 c2                	add    %eax,%edx
f01035ea:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01035ed:	39 1c 85 28 60 2a f0 	cmp    %ebx,-0xfd59fd8(,%eax,4)
f01035f4:	74 a4                	je     f010359a <envid2env+0x38>
f01035f6:	8b 73 4c             	mov    0x4c(%ebx),%esi
f01035f9:	e8 24 31 00 00       	call   f0106722 <cpunum>
f01035fe:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103601:	01 c2                	add    %eax,%edx
f0103603:	01 d2                	add    %edx,%edx
f0103605:	01 c2                	add    %eax,%edx
f0103607:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010360a:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f0103611:	3b 70 48             	cmp    0x48(%eax),%esi
f0103614:	74 84                	je     f010359a <envid2env+0x38>
		*env_store = 0;
f0103616:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103619:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010361f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103624:	e9 7b ff ff ff       	jmp    f01035a4 <envid2env+0x42>

f0103629 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103629:	55                   	push   %ebp
f010362a:	89 e5                	mov    %esp,%ebp
	asm volatile("lgdt (%0)" : : "r" (p));
f010362c:	b8 20 33 12 f0       	mov    $0xf0123320,%eax
f0103631:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103634:	b8 23 00 00 00       	mov    $0x23,%eax
f0103639:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f010363b:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f010363d:	b8 10 00 00 00       	mov    $0x10,%eax
f0103642:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103644:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103646:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103648:	ea 4f 36 10 f0 08 00 	ljmp   $0x8,$0xf010364f
	asm volatile("lldt %0" : : "r" (sel));
f010364f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103654:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103657:	5d                   	pop    %ebp
f0103658:	c3                   	ret    

f0103659 <env_init>:
{
f0103659:	55                   	push   %ebp
f010365a:	89 e5                	mov    %esp,%ebp
f010365c:	56                   	push   %esi
f010365d:	53                   	push   %ebx
		envs[i].env_link = env_free_list;
f010365e:	8b 35 48 52 2a f0    	mov    0xf02a5248,%esi
f0103664:	8b 15 4c 52 2a f0    	mov    0xf02a524c,%edx
f010366a:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103670:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0103673:	89 c1                	mov    %eax,%ecx
f0103675:	89 50 44             	mov    %edx,0x44(%eax)
f0103678:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[i];
f010367b:	89 ca                	mov    %ecx,%edx
	for (int i = NENV - 1; i >= 0; i--) { // Be sure not to use size_t
f010367d:	39 d8                	cmp    %ebx,%eax
f010367f:	75 f2                	jne    f0103673 <env_init+0x1a>
f0103681:	89 35 4c 52 2a f0    	mov    %esi,0xf02a524c
	env_init_percpu();
f0103687:	e8 9d ff ff ff       	call   f0103629 <env_init_percpu>
}
f010368c:	5b                   	pop    %ebx
f010368d:	5e                   	pop    %esi
f010368e:	5d                   	pop    %ebp
f010368f:	c3                   	ret    

f0103690 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103690:	55                   	push   %ebp
f0103691:	89 e5                	mov    %esp,%ebp
f0103693:	56                   	push   %esi
f0103694:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;
	if (!(e = env_free_list))
f0103695:	8b 1d 4c 52 2a f0    	mov    0xf02a524c,%ebx
f010369b:	85 db                	test   %ebx,%ebx
f010369d:	0f 84 fa 01 00 00    	je     f010389d <env_alloc+0x20d>
	if (!(p = page_alloc(ALLOC_ZERO)))
f01036a3:	83 ec 0c             	sub    $0xc,%esp
f01036a6:	6a 01                	push   $0x1
f01036a8:	e8 6f dd ff ff       	call   f010141c <page_alloc>
f01036ad:	89 c6                	mov    %eax,%esi
f01036af:	83 c4 10             	add    $0x10,%esp
f01036b2:	85 c0                	test   %eax,%eax
f01036b4:	0f 84 ea 01 00 00    	je     f01038a4 <env_alloc+0x214>
	return (pp - pages) << PGSHIFT;
f01036ba:	2b 05 90 5e 2a f0    	sub    0xf02a5e90,%eax
f01036c0:	c1 f8 03             	sar    $0x3,%eax
f01036c3:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01036c6:	89 c2                	mov    %eax,%edx
f01036c8:	c1 ea 0c             	shr    $0xc,%edx
f01036cb:	3b 15 88 5e 2a f0    	cmp    0xf02a5e88,%edx
f01036d1:	0f 83 7c 01 00 00    	jae    f0103853 <env_alloc+0x1c3>
	memset(page2kva(p), 0, PGSIZE);
f01036d7:	83 ec 04             	sub    $0x4,%esp
f01036da:	68 00 10 00 00       	push   $0x1000
f01036df:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01036e1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01036e6:	50                   	push   %eax
f01036e7:	e8 2c 29 00 00       	call   f0106018 <memset>
	p->pp_ref++;
f01036ec:	66 ff 46 04          	incw   0x4(%esi)
	return (pp - pages) << PGSHIFT;
f01036f0:	2b 35 90 5e 2a f0    	sub    0xf02a5e90,%esi
f01036f6:	c1 fe 03             	sar    $0x3,%esi
f01036f9:	c1 e6 0c             	shl    $0xc,%esi
	if (PGNUM(pa) >= npages)
f01036fc:	89 f0                	mov    %esi,%eax
f01036fe:	c1 e8 0c             	shr    $0xc,%eax
f0103701:	83 c4 10             	add    $0x10,%esp
f0103704:	3b 05 88 5e 2a f0    	cmp    0xf02a5e88,%eax
f010370a:	0f 83 55 01 00 00    	jae    f0103865 <env_alloc+0x1d5>
	return (void *)(pa + KERNBASE);
f0103710:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f0103716:	89 73 60             	mov    %esi,0x60(%ebx)
	e->env_pgdir = page2kva(p);
f0103719:	b8 ec 0e 00 00       	mov    $0xeec,%eax
		e->env_pgdir[pgt] = kern_pgdir[pgt];
f010371e:	8b 15 8c 5e 2a f0    	mov    0xf02a5e8c,%edx
f0103724:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0103727:	8b 53 60             	mov    0x60(%ebx),%edx
f010372a:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f010372d:	83 c0 04             	add    $0x4,%eax
	for (size_t pgt = PDX(UTOP); pgt < PGSIZE / sizeof(pde_t); pgt++)
f0103730:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103735:	75 e7                	jne    f010371e <env_alloc+0x8e>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103737:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f010373a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010373f:	0f 86 32 01 00 00    	jbe    f0103877 <env_alloc+0x1e7>
	return (physaddr_t)kva - KERNBASE;
f0103745:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010374b:	83 ca 05             	or     $0x5,%edx
f010374e:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103754:	8b 43 48             	mov    0x48(%ebx),%eax
f0103757:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010375c:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103761:	89 c2                	mov    %eax,%edx
f0103763:	0f 8e 23 01 00 00    	jle    f010388c <env_alloc+0x1fc>
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f0103769:	89 d8                	mov    %ebx,%eax
f010376b:	2b 05 48 52 2a f0    	sub    0xf02a5248,%eax
f0103771:	c1 f8 02             	sar    $0x2,%eax
f0103774:	89 c1                	mov    %eax,%ecx
f0103776:	c1 e0 05             	shl    $0x5,%eax
f0103779:	01 c8                	add    %ecx,%eax
f010377b:	c1 e0 05             	shl    $0x5,%eax
f010377e:	01 c8                	add    %ecx,%eax
f0103780:	89 c6                	mov    %eax,%esi
f0103782:	c1 e6 0f             	shl    $0xf,%esi
f0103785:	01 f0                	add    %esi,%eax
f0103787:	c1 e0 05             	shl    $0x5,%eax
f010378a:	01 c8                	add    %ecx,%eax
f010378c:	f7 d8                	neg    %eax
f010378e:	09 d0                	or     %edx,%eax
f0103790:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103793:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103796:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103799:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01037a0:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01037a7:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01037ae:	83 ec 04             	sub    $0x4,%esp
f01037b1:	6a 44                	push   $0x44
f01037b3:	6a 00                	push   $0x0
f01037b5:	53                   	push   %ebx
f01037b6:	e8 5d 28 00 00       	call   f0106018 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01037bb:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01037c1:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01037c7:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01037cd:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01037d4:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	e->env_tf.tf_eflags = FL_IF;  // This is the only flag till now.
f01037da:	c7 43 38 00 02 00 00 	movl   $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01037e1:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01037e8:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01037ec:	8b 43 44             	mov    0x44(%ebx),%eax
f01037ef:	a3 4c 52 2a f0       	mov    %eax,0xf02a524c
	*newenv_store = e;
f01037f4:	8b 45 08             	mov    0x8(%ebp),%eax
f01037f7:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01037f9:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01037fc:	e8 21 2f 00 00       	call   f0106722 <cpunum>
f0103801:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103804:	01 c2                	add    %eax,%edx
f0103806:	01 d2                	add    %edx,%edx
f0103808:	01 c2                	add    %eax,%edx
f010380a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010380d:	83 c4 10             	add    $0x10,%esp
f0103810:	83 3c 85 28 60 2a f0 	cmpl   $0x0,-0xfd59fd8(,%eax,4)
f0103817:	00 
f0103818:	74 7c                	je     f0103896 <env_alloc+0x206>
f010381a:	e8 03 2f 00 00       	call   f0106722 <cpunum>
f010381f:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103822:	01 c2                	add    %eax,%edx
f0103824:	01 d2                	add    %edx,%edx
f0103826:	01 c2                	add    %eax,%edx
f0103828:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010382b:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f0103832:	8b 40 48             	mov    0x48(%eax),%eax
f0103835:	83 ec 04             	sub    $0x4,%esp
f0103838:	53                   	push   %ebx
f0103839:	50                   	push   %eax
f010383a:	68 fa 82 10 f0       	push   $0xf01082fa
f010383f:	e8 55 07 00 00       	call   f0103f99 <cprintf>
	return 0;
f0103844:	83 c4 10             	add    $0x10,%esp
f0103847:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010384c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010384f:	5b                   	pop    %ebx
f0103850:	5e                   	pop    %esi
f0103851:	5d                   	pop    %ebp
f0103852:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103853:	50                   	push   %eax
f0103854:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0103859:	6a 58                	push   $0x58
f010385b:	68 89 7f 10 f0       	push   $0xf0107f89
f0103860:	e8 2f c8 ff ff       	call   f0100094 <_panic>
f0103865:	56                   	push   %esi
f0103866:	68 a8 6e 10 f0       	push   $0xf0106ea8
f010386b:	6a 58                	push   $0x58
f010386d:	68 89 7f 10 f0       	push   $0xf0107f89
f0103872:	e8 1d c8 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103877:	50                   	push   %eax
f0103878:	68 cc 6e 10 f0       	push   $0xf0106ecc
f010387d:	68 c7 00 00 00       	push   $0xc7
f0103882:	68 ef 82 10 f0       	push   $0xf01082ef
f0103887:	e8 08 c8 ff ff       	call   f0100094 <_panic>
		generation = 1 << ENVGENSHIFT;
f010388c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103891:	e9 d3 fe ff ff       	jmp    f0103769 <env_alloc+0xd9>
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103896:	b8 00 00 00 00       	mov    $0x0,%eax
f010389b:	eb 98                	jmp    f0103835 <env_alloc+0x1a5>
		return -E_NO_FREE_ENV;
f010389d:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01038a2:	eb a8                	jmp    f010384c <env_alloc+0x1bc>
		return -E_NO_MEM;
f01038a4:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01038a9:	eb a1                	jmp    f010384c <env_alloc+0x1bc>

f01038ab <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01038ab:	55                   	push   %ebp
f01038ac:	89 e5                	mov    %esp,%ebp
f01038ae:	57                   	push   %edi
f01038af:	56                   	push   %esi
f01038b0:	53                   	push   %ebx
f01038b1:	83 ec 34             	sub    $0x34,%esp
	// LAB 3: Your code here.
	struct Env* newenv;
	int r = env_alloc(&newenv, 0);
f01038b4:	6a 00                	push   $0x0
f01038b6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01038b9:	50                   	push   %eax
f01038ba:	e8 d1 fd ff ff       	call   f0103690 <env_alloc>
	if (r)
f01038bf:	83 c4 10             	add    $0x10,%esp
f01038c2:	85 c0                	test   %eax,%eax
f01038c4:	75 47                	jne    f010390d <env_create+0x62>
		panic("Environment allocation faulted: %e", r);
	load_icode(newenv, binary);
f01038c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	if (elf->e_magic != ELF_MAGIC)
f01038c9:	8b 45 08             	mov    0x8(%ebp),%eax
f01038cc:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f01038d2:	75 4e                	jne    f0103922 <env_create+0x77>
	struct Proghdr *ph = (struct Proghdr *) (binary + elf->e_phoff), 
f01038d4:	8b 45 08             	mov    0x8(%ebp),%eax
f01038d7:	89 c6                	mov    %eax,%esi
f01038d9:	03 70 1c             	add    0x1c(%eax),%esi
				   *eph = ph + elf->e_phnum;
f01038dc:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
f01038e0:	c1 e0 05             	shl    $0x5,%eax
f01038e3:	01 f0                	add    %esi,%eax
f01038e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	pte_t pgdir_pte = *pgdir_walk(kern_pgdir, e->env_pgdir, 0);
f01038e8:	83 ec 04             	sub    $0x4,%esp
f01038eb:	6a 00                	push   $0x0
f01038ed:	ff 77 60             	pushl  0x60(%edi)
f01038f0:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f01038f6:	e8 0b dc ff ff       	call   f0101506 <pgdir_walk>
	physaddr_t pgdir_phy = PTE_ADDR(pgdir_pte);
f01038fb:	8b 00                	mov    (%eax),%eax
f01038fd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103902:	0f 22 d8             	mov    %eax,%cr3
f0103905:	83 c4 10             	add    $0x10,%esp
f0103908:	e9 8f 00 00 00       	jmp    f010399c <env_create+0xf1>
		panic("Environment allocation faulted: %e", r);
f010390d:	50                   	push   %eax
f010390e:	68 cc 82 10 f0       	push   $0xf01082cc
f0103913:	68 a0 01 00 00       	push   $0x1a0
f0103918:	68 ef 82 10 f0       	push   $0xf01082ef
f010391d:	e8 72 c7 ff ff       	call   f0100094 <_panic>
		panic("Not a valid elf binary!");
f0103922:	83 ec 04             	sub    $0x4,%esp
f0103925:	68 0f 83 10 f0       	push   $0xf010830f
f010392a:	68 64 01 00 00       	push   $0x164
f010392f:	68 ef 82 10 f0       	push   $0xf01082ef
f0103934:	e8 5b c7 ff ff       	call   f0100094 <_panic>
			panic("No free page for allocation.");
f0103939:	83 ec 04             	sub    $0x4,%esp
f010393c:	68 27 83 10 f0       	push   $0xf0108327
f0103941:	68 22 01 00 00       	push   $0x122
f0103946:	68 ef 82 10 f0       	push   $0xf01082ef
f010394b:	e8 44 c7 ff ff       	call   f0100094 <_panic>
			panic("Page insertion result: %e", r);
f0103950:	ff 75 cc             	pushl  -0x34(%ebp)
f0103953:	68 44 83 10 f0       	push   $0xf0108344
f0103958:	68 25 01 00 00       	push   $0x125
f010395d:	68 ef 82 10 f0       	push   $0xf01082ef
f0103962:	e8 2d c7 ff ff       	call   f0100094 <_panic>
f0103967:	8b 75 d0             	mov    -0x30(%ebp),%esi
			memmove((void*)ph0->p_va, binary + ph0->p_offset, ph0->p_filesz);
f010396a:	83 ec 04             	sub    $0x4,%esp
f010396d:	ff 76 10             	pushl  0x10(%esi)
f0103970:	8b 45 08             	mov    0x8(%ebp),%eax
f0103973:	03 46 04             	add    0x4(%esi),%eax
f0103976:	50                   	push   %eax
f0103977:	ff 76 08             	pushl  0x8(%esi)
f010397a:	e8 e6 26 00 00       	call   f0106065 <memmove>
					ph0->p_memsz - ph0->p_filesz);
f010397f:	8b 46 10             	mov    0x10(%esi),%eax
			memset((void*)ph0->p_va + ph0->p_filesz, 0, 
f0103982:	83 c4 0c             	add    $0xc,%esp
f0103985:	8b 56 14             	mov    0x14(%esi),%edx
f0103988:	29 c2                	sub    %eax,%edx
f010398a:	52                   	push   %edx
f010398b:	6a 00                	push   $0x0
f010398d:	03 46 08             	add    0x8(%esi),%eax
f0103990:	50                   	push   %eax
f0103991:	e8 82 26 00 00       	call   f0106018 <memset>
f0103996:	83 c4 10             	add    $0x10,%esp
	for (struct Proghdr* ph0 = ph; ph0 < eph; ph0++) {
f0103999:	83 c6 20             	add    $0x20,%esi
f010399c:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f010399f:	76 5d                	jbe    f01039fe <env_create+0x153>
		if (ph0->p_type == ELF_PROG_LOAD) {
f01039a1:	83 3e 01             	cmpl   $0x1,(%esi)
f01039a4:	75 f3                	jne    f0103999 <env_create+0xee>
			region_alloc(e, (void*)ph0->p_va, ph0->p_memsz);
f01039a6:	8b 46 08             	mov    0x8(%esi),%eax
	uintptr_t l = ROUNDDOWN((uintptr_t)va, PGSIZE), 
f01039a9:	89 c3                	mov    %eax,%ebx
f01039ab:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
			  r = ROUNDUP((uintptr_t)(va + len), PGSIZE);
f01039b1:	03 46 14             	add    0x14(%esi),%eax
f01039b4:	05 ff 0f 00 00       	add    $0xfff,%eax
f01039b9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01039be:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01039c1:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01039c4:	89 c6                	mov    %eax,%esi
	for (uintptr_t ptr = l; ptr < r; ptr += PGSIZE) {
f01039c6:	39 de                	cmp    %ebx,%esi
f01039c8:	76 9d                	jbe    f0103967 <env_create+0xbc>
		struct PageInfo *pg = page_alloc(0);
f01039ca:	83 ec 0c             	sub    $0xc,%esp
f01039cd:	6a 00                	push   $0x0
f01039cf:	e8 48 da ff ff       	call   f010141c <page_alloc>
		if (!pg)
f01039d4:	83 c4 10             	add    $0x10,%esp
f01039d7:	85 c0                	test   %eax,%eax
f01039d9:	0f 84 5a ff ff ff    	je     f0103939 <env_create+0x8e>
		int res = page_insert(e->env_pgdir, pg, (void*)ptr, PTE_U | PTE_W);
f01039df:	6a 06                	push   $0x6
f01039e1:	53                   	push   %ebx
f01039e2:	50                   	push   %eax
f01039e3:	ff 77 60             	pushl  0x60(%edi)
f01039e6:	e8 8a dd ff ff       	call   f0101775 <page_insert>
		if (res)
f01039eb:	83 c4 10             	add    $0x10,%esp
f01039ee:	85 c0                	test   %eax,%eax
f01039f0:	0f 85 5a ff ff ff    	jne    f0103950 <env_create+0xa5>
	for (uintptr_t ptr = l; ptr < r; ptr += PGSIZE) {
f01039f6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01039fc:	eb c8                	jmp    f01039c6 <env_create+0x11b>
	e->env_tf.tf_eip = elf->e_entry;
f01039fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a01:	8b 40 18             	mov    0x18(%eax),%eax
f0103a04:	89 47 30             	mov    %eax,0x30(%edi)
	lcr3(PADDR(kern_pgdir));
f0103a07:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103a0c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a11:	76 38                	jbe    f0103a4b <env_create+0x1a0>
	return (physaddr_t)kva - KERNBASE;
f0103a13:	05 00 00 00 10       	add    $0x10000000,%eax
f0103a18:	0f 22 d8             	mov    %eax,%cr3
	struct PageInfo *stack_page = page_alloc(ALLOC_ZERO);
f0103a1b:	83 ec 0c             	sub    $0xc,%esp
f0103a1e:	6a 01                	push   $0x1
f0103a20:	e8 f7 d9 ff ff       	call   f010141c <page_alloc>
	if (!stack_page)
f0103a25:	83 c4 10             	add    $0x10,%esp
f0103a28:	85 c0                	test   %eax,%eax
f0103a2a:	74 34                	je     f0103a60 <env_create+0x1b5>
	int r = page_insert(e->env_pgdir, stack_page, (void*)USTACKTOP - PGSIZE, PTE_U | PTE_W);
f0103a2c:	6a 06                	push   $0x6
f0103a2e:	68 00 d0 bf ee       	push   $0xeebfd000
f0103a33:	50                   	push   %eax
f0103a34:	ff 77 60             	pushl  0x60(%edi)
f0103a37:	e8 39 dd ff ff       	call   f0101775 <page_insert>
	if (r)
f0103a3c:	83 c4 10             	add    $0x10,%esp
f0103a3f:	85 c0                	test   %eax,%eax
f0103a41:	75 34                	jne    f0103a77 <env_create+0x1cc>
	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
}
f0103a43:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103a46:	5b                   	pop    %ebx
f0103a47:	5e                   	pop    %esi
f0103a48:	5f                   	pop    %edi
f0103a49:	5d                   	pop    %ebp
f0103a4a:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a4b:	50                   	push   %eax
f0103a4c:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0103a51:	68 84 01 00 00       	push   $0x184
f0103a56:	68 ef 82 10 f0       	push   $0xf01082ef
f0103a5b:	e8 34 c6 ff ff       	call   f0100094 <_panic>
		panic("No free page for allocation.");
f0103a60:	83 ec 04             	sub    $0x4,%esp
f0103a63:	68 27 83 10 f0       	push   $0xf0108327
f0103a68:	68 8c 01 00 00       	push   $0x18c
f0103a6d:	68 ef 82 10 f0       	push   $0xf01082ef
f0103a72:	e8 1d c6 ff ff       	call   f0100094 <_panic>
		panic("Page insertion result: %e", r);
f0103a77:	50                   	push   %eax
f0103a78:	68 44 83 10 f0       	push   $0xf0108344
f0103a7d:	68 8f 01 00 00       	push   $0x18f
f0103a82:	68 ef 82 10 f0       	push   $0xf01082ef
f0103a87:	e8 08 c6 ff ff       	call   f0100094 <_panic>

f0103a8c <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103a8c:	55                   	push   %ebp
f0103a8d:	89 e5                	mov    %esp,%ebp
f0103a8f:	57                   	push   %edi
f0103a90:	56                   	push   %esi
f0103a91:	53                   	push   %ebx
f0103a92:	83 ec 1c             	sub    $0x1c,%esp
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103a95:	e8 88 2c 00 00       	call   f0106722 <cpunum>
f0103a9a:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103a9d:	01 c2                	add    %eax,%edx
f0103a9f:	01 d2                	add    %edx,%edx
f0103aa1:	01 c2                	add    %eax,%edx
f0103aa3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103aa6:	8b 55 08             	mov    0x8(%ebp),%edx
f0103aa9:	39 14 85 28 60 2a f0 	cmp    %edx,-0xfd59fd8(,%eax,4)
f0103ab0:	75 38                	jne    f0103aea <env_free+0x5e>
		lcr3(PADDR(kern_pgdir));
f0103ab2:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103ab7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103abc:	76 17                	jbe    f0103ad5 <env_free+0x49>
	return (physaddr_t)kva - KERNBASE;
f0103abe:	05 00 00 00 10       	add    $0x10000000,%eax
f0103ac3:	0f 22 d8             	mov    %eax,%cr3
f0103ac6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0103acd:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103ad0:	e9 9b 00 00 00       	jmp    f0103b70 <env_free+0xe4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ad5:	50                   	push   %eax
f0103ad6:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0103adb:	68 b4 01 00 00       	push   $0x1b4
f0103ae0:	68 ef 82 10 f0       	push   $0xf01082ef
f0103ae5:	e8 aa c5 ff ff       	call   f0100094 <_panic>
f0103aea:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0103af1:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103af4:	eb 7a                	jmp    f0103b70 <env_free+0xe4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103af6:	50                   	push   %eax
f0103af7:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0103afc:	68 c3 01 00 00       	push   $0x1c3
f0103b01:	68 ef 82 10 f0       	push   $0xf01082ef
f0103b06:	e8 89 c5 ff ff       	call   f0100094 <_panic>
f0103b0b:	83 c3 04             	add    $0x4,%ebx
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103b0e:	39 de                	cmp    %ebx,%esi
f0103b10:	74 21                	je     f0103b33 <env_free+0xa7>
			if (pt[pteno] & PTE_P)
f0103b12:	f6 03 01             	testb  $0x1,(%ebx)
f0103b15:	74 f4                	je     f0103b0b <env_free+0x7f>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b17:	83 ec 08             	sub    $0x8,%esp
f0103b1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b1d:	01 d8                	add    %ebx,%eax
f0103b1f:	c1 e0 0a             	shl    $0xa,%eax
f0103b22:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103b25:	50                   	push   %eax
f0103b26:	ff 77 60             	pushl  0x60(%edi)
f0103b29:	e8 ed db ff ff       	call   f010171b <page_remove>
f0103b2e:	83 c4 10             	add    $0x10,%esp
f0103b31:	eb d8                	jmp    f0103b0b <env_free+0x7f>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103b33:	8b 47 60             	mov    0x60(%edi),%eax
f0103b36:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b39:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103b40:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103b43:	3b 05 88 5e 2a f0    	cmp    0xf02a5e88,%eax
f0103b49:	73 6a                	jae    f0103bb5 <env_free+0x129>
		page_decref(pa2page(pa));
f0103b4b:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103b4e:	a1 90 5e 2a f0       	mov    0xf02a5e90,%eax
f0103b53:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103b56:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103b59:	50                   	push   %eax
f0103b5a:	e8 81 d9 ff ff       	call   f01014e0 <page_decref>
f0103b5f:	83 c4 10             	add    $0x10,%esp
f0103b62:	83 45 dc 04          	addl   $0x4,-0x24(%ebp)
f0103b66:	8b 45 dc             	mov    -0x24(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103b69:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103b6e:	74 59                	je     f0103bc9 <env_free+0x13d>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103b70:	8b 47 60             	mov    0x60(%edi),%eax
f0103b73:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b76:	8b 04 10             	mov    (%eax,%edx,1),%eax
f0103b79:	a8 01                	test   $0x1,%al
f0103b7b:	74 e5                	je     f0103b62 <env_free+0xd6>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103b7d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0103b82:	89 c2                	mov    %eax,%edx
f0103b84:	c1 ea 0c             	shr    $0xc,%edx
f0103b87:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0103b8a:	39 15 88 5e 2a f0    	cmp    %edx,0xf02a5e88
f0103b90:	0f 86 60 ff ff ff    	jbe    f0103af6 <env_free+0x6a>
	return (void *)(pa + KERNBASE);
f0103b96:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b9c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b9f:	c1 e2 14             	shl    $0x14,%edx
f0103ba2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103ba5:	8d b0 00 10 00 f0    	lea    -0xffff000(%eax),%esi
f0103bab:	f7 d8                	neg    %eax
f0103bad:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103bb0:	e9 5d ff ff ff       	jmp    f0103b12 <env_free+0x86>
		panic("pa2page called with invalid pa");
f0103bb5:	83 ec 04             	sub    $0x4,%esp
f0103bb8:	68 44 77 10 f0       	push   $0xf0107744
f0103bbd:	6a 51                	push   $0x51
f0103bbf:	68 89 7f 10 f0       	push   $0xf0107f89
f0103bc4:	e8 cb c4 ff ff       	call   f0100094 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103bc9:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bcc:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103bcf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103bd4:	76 52                	jbe    f0103c28 <env_free+0x19c>
	e->env_pgdir = 0;
f0103bd6:	8b 55 08             	mov    0x8(%ebp),%edx
f0103bd9:	c7 42 60 00 00 00 00 	movl   $0x0,0x60(%edx)
	return (physaddr_t)kva - KERNBASE;
f0103be0:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103be5:	c1 e8 0c             	shr    $0xc,%eax
f0103be8:	3b 05 88 5e 2a f0    	cmp    0xf02a5e88,%eax
f0103bee:	73 4d                	jae    f0103c3d <env_free+0x1b1>
	page_decref(pa2page(pa));
f0103bf0:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103bf3:	8b 15 90 5e 2a f0    	mov    0xf02a5e90,%edx
f0103bf9:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103bfc:	50                   	push   %eax
f0103bfd:	e8 de d8 ff ff       	call   f01014e0 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103c02:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c05:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f0103c0c:	a1 4c 52 2a f0       	mov    0xf02a524c,%eax
f0103c11:	8b 55 08             	mov    0x8(%ebp),%edx
f0103c14:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f0103c17:	89 15 4c 52 2a f0    	mov    %edx,0xf02a524c
}
f0103c1d:	83 c4 10             	add    $0x10,%esp
f0103c20:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103c23:	5b                   	pop    %ebx
f0103c24:	5e                   	pop    %esi
f0103c25:	5f                   	pop    %edi
f0103c26:	5d                   	pop    %ebp
f0103c27:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103c28:	50                   	push   %eax
f0103c29:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0103c2e:	68 d1 01 00 00       	push   $0x1d1
f0103c33:	68 ef 82 10 f0       	push   $0xf01082ef
f0103c38:	e8 57 c4 ff ff       	call   f0100094 <_panic>
		panic("pa2page called with invalid pa");
f0103c3d:	83 ec 04             	sub    $0x4,%esp
f0103c40:	68 44 77 10 f0       	push   $0xf0107744
f0103c45:	6a 51                	push   $0x51
f0103c47:	68 89 7f 10 f0       	push   $0xf0107f89
f0103c4c:	e8 43 c4 ff ff       	call   f0100094 <_panic>

f0103c51 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103c51:	55                   	push   %ebp
f0103c52:	89 e5                	mov    %esp,%ebp
f0103c54:	53                   	push   %ebx
f0103c55:	83 ec 04             	sub    $0x4,%esp
f0103c58:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103c5b:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103c5f:	74 2b                	je     f0103c8c <env_destroy+0x3b>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f0103c61:	83 ec 0c             	sub    $0xc,%esp
f0103c64:	53                   	push   %ebx
f0103c65:	e8 22 fe ff ff       	call   f0103a8c <env_free>

	if (curenv == e) {
f0103c6a:	e8 b3 2a 00 00       	call   f0106722 <cpunum>
f0103c6f:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103c72:	01 c2                	add    %eax,%edx
f0103c74:	01 d2                	add    %edx,%edx
f0103c76:	01 c2                	add    %eax,%edx
f0103c78:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c7b:	83 c4 10             	add    $0x10,%esp
f0103c7e:	39 1c 85 28 60 2a f0 	cmp    %ebx,-0xfd59fd8(,%eax,4)
f0103c85:	74 28                	je     f0103caf <env_destroy+0x5e>
		curenv = NULL;
		sched_yield();
	}
}
f0103c87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103c8a:	c9                   	leave  
f0103c8b:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103c8c:	e8 91 2a 00 00       	call   f0106722 <cpunum>
f0103c91:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103c94:	01 c2                	add    %eax,%edx
f0103c96:	01 d2                	add    %edx,%edx
f0103c98:	01 c2                	add    %eax,%edx
f0103c9a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c9d:	39 1c 85 28 60 2a f0 	cmp    %ebx,-0xfd59fd8(,%eax,4)
f0103ca4:	74 bb                	je     f0103c61 <env_destroy+0x10>
		e->env_status = ENV_DYING;
f0103ca6:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103cad:	eb d8                	jmp    f0103c87 <env_destroy+0x36>
		curenv = NULL;
f0103caf:	e8 6e 2a 00 00       	call   f0106722 <cpunum>
f0103cb4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cb7:	c7 80 28 60 2a f0 00 	movl   $0x0,-0xfd59fd8(%eax)
f0103cbe:	00 00 00 
		sched_yield();
f0103cc1:	e8 4e 11 00 00       	call   f0104e14 <sched_yield>

f0103cc6 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103cc6:	55                   	push   %ebp
f0103cc7:	89 e5                	mov    %esp,%ebp
f0103cc9:	53                   	push   %ebx
f0103cca:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103ccd:	e8 50 2a 00 00       	call   f0106722 <cpunum>
f0103cd2:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103cd5:	01 c2                	add    %eax,%edx
f0103cd7:	01 d2                	add    %edx,%edx
f0103cd9:	01 c2                	add    %eax,%edx
f0103cdb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103cde:	8b 1c 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%ebx
f0103ce5:	e8 38 2a 00 00       	call   f0106722 <cpunum>
f0103cea:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0103ced:	8b 65 08             	mov    0x8(%ebp),%esp
f0103cf0:	61                   	popa   
f0103cf1:	07                   	pop    %es
f0103cf2:	1f                   	pop    %ds
f0103cf3:	83 c4 08             	add    $0x8,%esp
f0103cf6:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103cf7:	83 ec 04             	sub    $0x4,%esp
f0103cfa:	68 5e 83 10 f0       	push   $0xf010835e
f0103cff:	68 08 02 00 00       	push   $0x208
f0103d04:	68 ef 82 10 f0       	push   $0xf01082ef
f0103d09:	e8 86 c3 ff ff       	call   f0100094 <_panic>

f0103d0e <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103d0e:	55                   	push   %ebp
f0103d0f:	89 e5                	mov    %esp,%ebp
f0103d11:	83 ec 08             	sub    $0x8,%esp
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// Unset curenv running before going to new env.
	if (curenv && curenv->env_status == ENV_RUNNING) {
f0103d14:	e8 09 2a 00 00       	call   f0106722 <cpunum>
f0103d19:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103d1c:	01 c2                	add    %eax,%edx
f0103d1e:	01 d2                	add    %edx,%edx
f0103d20:	01 c2                	add    %eax,%edx
f0103d22:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d25:	83 3c 85 28 60 2a f0 	cmpl   $0x0,-0xfd59fd8(,%eax,4)
f0103d2c:	00 
f0103d2d:	74 18                	je     f0103d47 <env_run+0x39>
f0103d2f:	e8 ee 29 00 00       	call   f0106722 <cpunum>
f0103d34:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d37:	8b 80 28 60 2a f0    	mov    -0xfd59fd8(%eax),%eax
f0103d3d:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103d41:	0f 84 8c 00 00 00    	je     f0103dd3 <env_run+0xc5>
		curenv->env_status = ENV_RUNNABLE;
	}

	curenv = e;
f0103d47:	e8 d6 29 00 00       	call   f0106722 <cpunum>
f0103d4c:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103d4f:	01 c2                	add    %eax,%edx
f0103d51:	01 d2                	add    %edx,%edx
f0103d53:	01 c2                	add    %eax,%edx
f0103d55:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d58:	8b 55 08             	mov    0x8(%ebp),%edx
f0103d5b:	89 14 85 28 60 2a f0 	mov    %edx,-0xfd59fd8(,%eax,4)
	curenv->env_status = ENV_RUNNING;
f0103d62:	e8 bb 29 00 00       	call   f0106722 <cpunum>
f0103d67:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103d6a:	01 c2                	add    %eax,%edx
f0103d6c:	01 d2                	add    %edx,%edx
f0103d6e:	01 c2                	add    %eax,%edx
f0103d70:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d73:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f0103d7a:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++; // Incremetn run count
f0103d81:	e8 9c 29 00 00       	call   f0106722 <cpunum>
f0103d86:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103d89:	01 c2                	add    %eax,%edx
f0103d8b:	01 d2                	add    %edx,%edx
f0103d8d:	01 c2                	add    %eax,%edx
f0103d8f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d92:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f0103d99:	ff 40 58             	incl   0x58(%eax)

	// Jump to user env pgdir
	lcr3(PADDR(curenv->env_pgdir));
f0103d9c:	e8 81 29 00 00       	call   f0106722 <cpunum>
f0103da1:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103da4:	01 c2                	add    %eax,%edx
f0103da6:	01 d2                	add    %edx,%edx
f0103da8:	01 c2                	add    %eax,%edx
f0103daa:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103dad:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f0103db4:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103db7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103dbc:	77 2f                	ja     f0103ded <env_run+0xdf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103dbe:	50                   	push   %eax
f0103dbf:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0103dc4:	68 2f 02 00 00       	push   $0x22f
f0103dc9:	68 ef 82 10 f0       	push   $0xf01082ef
f0103dce:	e8 c1 c2 ff ff       	call   f0100094 <_panic>
		curenv->env_status = ENV_RUNNABLE;
f0103dd3:	e8 4a 29 00 00       	call   f0106722 <cpunum>
f0103dd8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ddb:	8b 80 28 60 2a f0    	mov    -0xfd59fd8(%eax),%eax
f0103de1:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0103de8:	e9 5a ff ff ff       	jmp    f0103d47 <env_run+0x39>
	return (physaddr_t)kva - KERNBASE;
f0103ded:	05 00 00 00 10       	add    $0x10000000,%eax
f0103df2:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103df5:	83 ec 0c             	sub    $0xc,%esp
f0103df8:	68 c0 33 12 f0       	push   $0xf01233c0
f0103dfd:	e8 41 2c 00 00       	call   f0106a43 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103e02:	f3 90                	pause  

	// Unlock the kernel if we're heading user mode.
	unlock_kernel();

	// Do the final work.
	env_pop_tf(&curenv->env_tf);  // Does not return.
f0103e04:	e8 19 29 00 00       	call   f0106722 <cpunum>
f0103e09:	83 c4 04             	add    $0x4,%esp
f0103e0c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e0f:	ff b0 28 60 2a f0    	pushl  -0xfd59fd8(%eax)
f0103e15:	e8 ac fe ff ff       	call   f0103cc6 <env_pop_tf>

f0103e1a <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103e1a:	55                   	push   %ebp
f0103e1b:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e1d:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e22:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e25:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103e26:	ba 71 00 00 00       	mov    $0x71,%edx
f0103e2b:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103e2c:	0f b6 c0             	movzbl %al,%eax
}
f0103e2f:	5d                   	pop    %ebp
f0103e30:	c3                   	ret    

f0103e31 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103e31:	55                   	push   %ebp
f0103e32:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e34:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e39:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e3c:	ee                   	out    %al,(%dx)
f0103e3d:	ba 71 00 00 00       	mov    $0x71,%edx
f0103e42:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e45:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103e46:	5d                   	pop    %ebp
f0103e47:	c3                   	ret    

f0103e48 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103e48:	55                   	push   %ebp
f0103e49:	89 e5                	mov    %esp,%ebp
f0103e4b:	56                   	push   %esi
f0103e4c:	53                   	push   %ebx
f0103e4d:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103e50:	66 a3 a8 33 12 f0    	mov    %ax,0xf01233a8
	if (!didinit)
f0103e56:	80 3d 50 52 2a f0 00 	cmpb   $0x0,0xf02a5250
f0103e5d:	74 5a                	je     f0103eb9 <irq_setmask_8259A+0x71>
f0103e5f:	89 c6                	mov    %eax,%esi
f0103e61:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e66:	ee                   	out    %al,(%dx)
f0103e67:	66 c1 e8 08          	shr    $0x8,%ax
f0103e6b:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103e70:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103e71:	83 ec 0c             	sub    $0xc,%esp
f0103e74:	68 6a 83 10 f0       	push   $0xf010836a
f0103e79:	e8 1b 01 00 00       	call   f0103f99 <cprintf>
f0103e7e:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103e81:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103e86:	0f b7 f6             	movzwl %si,%esi
f0103e89:	f7 d6                	not    %esi
f0103e8b:	0f a3 de             	bt     %ebx,%esi
f0103e8e:	73 11                	jae    f0103ea1 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103e90:	83 ec 08             	sub    $0x8,%esp
f0103e93:	53                   	push   %ebx
f0103e94:	68 3f 88 10 f0       	push   $0xf010883f
f0103e99:	e8 fb 00 00 00       	call   f0103f99 <cprintf>
f0103e9e:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103ea1:	83 c3 01             	add    $0x1,%ebx
f0103ea4:	83 fb 10             	cmp    $0x10,%ebx
f0103ea7:	75 e2                	jne    f0103e8b <irq_setmask_8259A+0x43>
	cprintf("\n");
f0103ea9:	83 ec 0c             	sub    $0xc,%esp
f0103eac:	68 fb 71 10 f0       	push   $0xf01071fb
f0103eb1:	e8 e3 00 00 00       	call   f0103f99 <cprintf>
f0103eb6:	83 c4 10             	add    $0x10,%esp
}
f0103eb9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103ebc:	5b                   	pop    %ebx
f0103ebd:	5e                   	pop    %esi
f0103ebe:	5d                   	pop    %ebp
f0103ebf:	c3                   	ret    

f0103ec0 <pic_init>:
	didinit = 1;
f0103ec0:	c6 05 50 52 2a f0 01 	movb   $0x1,0xf02a5250
f0103ec7:	ba 21 00 00 00       	mov    $0x21,%edx
f0103ecc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ed1:	ee                   	out    %al,(%dx)
f0103ed2:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103ed7:	ee                   	out    %al,(%dx)
f0103ed8:	ba 20 00 00 00       	mov    $0x20,%edx
f0103edd:	b8 11 00 00 00       	mov    $0x11,%eax
f0103ee2:	ee                   	out    %al,(%dx)
f0103ee3:	ba 21 00 00 00       	mov    $0x21,%edx
f0103ee8:	b8 20 00 00 00       	mov    $0x20,%eax
f0103eed:	ee                   	out    %al,(%dx)
f0103eee:	b8 04 00 00 00       	mov    $0x4,%eax
f0103ef3:	ee                   	out    %al,(%dx)
f0103ef4:	b8 03 00 00 00       	mov    $0x3,%eax
f0103ef9:	ee                   	out    %al,(%dx)
f0103efa:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103eff:	b8 11 00 00 00       	mov    $0x11,%eax
f0103f04:	ee                   	out    %al,(%dx)
f0103f05:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103f0a:	b8 28 00 00 00       	mov    $0x28,%eax
f0103f0f:	ee                   	out    %al,(%dx)
f0103f10:	b8 02 00 00 00       	mov    $0x2,%eax
f0103f15:	ee                   	out    %al,(%dx)
f0103f16:	b8 01 00 00 00       	mov    $0x1,%eax
f0103f1b:	ee                   	out    %al,(%dx)
f0103f1c:	ba 20 00 00 00       	mov    $0x20,%edx
f0103f21:	b8 68 00 00 00       	mov    $0x68,%eax
f0103f26:	ee                   	out    %al,(%dx)
f0103f27:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f2c:	ee                   	out    %al,(%dx)
f0103f2d:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103f32:	b8 68 00 00 00       	mov    $0x68,%eax
f0103f37:	ee                   	out    %al,(%dx)
f0103f38:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f3d:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103f3e:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f0103f45:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103f49:	74 13                	je     f0103f5e <pic_init+0x9e>
{
f0103f4b:	55                   	push   %ebp
f0103f4c:	89 e5                	mov    %esp,%ebp
f0103f4e:	83 ec 14             	sub    $0x14,%esp
		irq_setmask_8259A(irq_mask_8259A);
f0103f51:	0f b7 c0             	movzwl %ax,%eax
f0103f54:	50                   	push   %eax
f0103f55:	e8 ee fe ff ff       	call   f0103e48 <irq_setmask_8259A>
f0103f5a:	83 c4 10             	add    $0x10,%esp
}
f0103f5d:	c9                   	leave  
f0103f5e:	f3 c3                	repz ret 

f0103f60 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103f60:	55                   	push   %ebp
f0103f61:	89 e5                	mov    %esp,%ebp
f0103f63:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103f66:	ff 75 08             	pushl  0x8(%ebp)
f0103f69:	e8 d3 c8 ff ff       	call   f0100841 <cputchar>
	*cnt++;
}
f0103f6e:	83 c4 10             	add    $0x10,%esp
f0103f71:	c9                   	leave  
f0103f72:	c3                   	ret    

f0103f73 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103f73:	55                   	push   %ebp
f0103f74:	89 e5                	mov    %esp,%ebp
f0103f76:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103f79:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103f80:	ff 75 0c             	pushl  0xc(%ebp)
f0103f83:	ff 75 08             	pushl  0x8(%ebp)
f0103f86:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103f89:	50                   	push   %eax
f0103f8a:	68 60 3f 10 f0       	push   $0xf0103f60
f0103f8f:	e8 36 19 00 00       	call   f01058ca <vprintfmt>
	return cnt;
}
f0103f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f97:	c9                   	leave  
f0103f98:	c3                   	ret    

f0103f99 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103f99:	55                   	push   %ebp
f0103f9a:	89 e5                	mov    %esp,%ebp
f0103f9c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103f9f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103fa2:	50                   	push   %eax
f0103fa3:	ff 75 08             	pushl  0x8(%ebp)
f0103fa6:	e8 c8 ff ff ff       	call   f0103f73 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103fab:	c9                   	leave  
f0103fac:	c3                   	ret    

f0103fad <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103fad:	55                   	push   %ebp
f0103fae:	89 e5                	mov    %esp,%ebp
f0103fb0:	57                   	push   %edi
f0103fb1:	56                   	push   %esi
f0103fb2:	53                   	push   %ebx
f0103fb3:	83 ec 0c             	sub    $0xc,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	struct Taskstate* ts = &thiscpu->cpu_ts;
f0103fb6:	e8 67 27 00 00       	call   f0106722 <cpunum>
f0103fbb:	89 c6                	mov    %eax,%esi
f0103fbd:	8d 1c 00             	lea    (%eax,%eax,1),%ebx
f0103fc0:	01 c3                	add    %eax,%ebx
f0103fc2:	01 db                	add    %ebx,%ebx
f0103fc4:	01 c3                	add    %eax,%ebx
f0103fc6:	c1 e3 02             	shl    $0x2,%ebx
f0103fc9:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0103fcc:	8d 3c 85 2c 60 2a f0 	lea    -0xfd59fd4(,%eax,4),%edi
	ts->ts_esp0 = KSTACKTOP - cpunum() * (KSTKSIZE + KSTKGAP);
f0103fd3:	e8 4a 27 00 00       	call   f0106722 <cpunum>
f0103fd8:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f0103fdb:	8d 14 95 20 60 2a f0 	lea    -0xfd59fe0(,%edx,4),%edx
f0103fe2:	c1 e0 10             	shl    $0x10,%eax
f0103fe5:	89 c1                	mov    %eax,%ecx
f0103fe7:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f0103fec:	29 c8                	sub    %ecx,%eax
f0103fee:	89 42 10             	mov    %eax,0x10(%edx)
	ts->ts_ss0 = GD_KD;
f0103ff1:	66 c7 42 14 10 00    	movw   $0x10,0x14(%edx)
	ts->ts_iomb = sizeof(struct Taskstate);
f0103ff7:	01 f3                	add    %esi,%ebx
f0103ff9:	66 c7 04 9d 92 60 2a 	movw   $0x68,-0xfd59f6e(,%ebx,4)
f0104000:	f0 68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) ts,
f0104003:	66 c7 05 68 33 12 f0 	movw   $0x67,0xf0123368
f010400a:	67 00 
f010400c:	66 89 3d 6a 33 12 f0 	mov    %di,0xf012336a
f0104013:	89 f8                	mov    %edi,%eax
f0104015:	c1 e8 10             	shr    $0x10,%eax
f0104018:	a2 6c 33 12 f0       	mov    %al,0xf012336c
f010401d:	c6 05 6e 33 12 f0 40 	movb   $0x40,0xf012336e
f0104024:	89 f8                	mov    %edi,%eax
f0104026:	c1 e8 18             	shr    $0x18,%eax
f0104029:	a2 6f 33 12 f0       	mov    %al,0xf012336f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f010402e:	c6 05 6d 33 12 f0 89 	movb   $0x89,0xf012336d
	asm volatile("ltr %0" : : "r" (sel));
f0104035:	b8 28 00 00 00       	mov    $0x28,%eax
f010403a:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f010403d:	b8 ac 33 12 f0       	mov    $0xf01233ac,%eax
f0104042:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0104045:	83 c4 0c             	add    $0xc,%esp
f0104048:	5b                   	pop    %ebx
f0104049:	5e                   	pop    %esi
f010404a:	5f                   	pop    %edi
f010404b:	5d                   	pop    %ebp
f010404c:	c3                   	ret    

f010404d <trap_init>:
{
f010404d:	55                   	push   %ebp
f010404e:	89 e5                	mov    %esp,%ebp
f0104050:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE],  0, GD_KT, (void*)H_DIVIDE, 0);   
f0104053:	b8 1a 4c 10 f0       	mov    $0xf0104c1a,%eax
f0104058:	66 a3 60 52 2a f0    	mov    %ax,0xf02a5260
f010405e:	66 c7 05 62 52 2a f0 	movw   $0x8,0xf02a5262
f0104065:	08 00 
f0104067:	c6 05 64 52 2a f0 00 	movb   $0x0,0xf02a5264
f010406e:	c6 05 65 52 2a f0 8e 	movb   $0x8e,0xf02a5265
f0104075:	c1 e8 10             	shr    $0x10,%eax
f0104078:	66 a3 66 52 2a f0    	mov    %ax,0xf02a5266
	SETGATE(idt[T_DEBUG],   0, GD_KT, (void*)H_DEBUG,  0);  
f010407e:	b8 24 4c 10 f0       	mov    $0xf0104c24,%eax
f0104083:	66 a3 68 52 2a f0    	mov    %ax,0xf02a5268
f0104089:	66 c7 05 6a 52 2a f0 	movw   $0x8,0xf02a526a
f0104090:	08 00 
f0104092:	c6 05 6c 52 2a f0 00 	movb   $0x0,0xf02a526c
f0104099:	c6 05 6d 52 2a f0 8e 	movb   $0x8e,0xf02a526d
f01040a0:	c1 e8 10             	shr    $0x10,%eax
f01040a3:	66 a3 6e 52 2a f0    	mov    %ax,0xf02a526e
	SETGATE(idt[T_NMI],     0, GD_KT, (void*)H_NMI,    0);
f01040a9:	b8 2e 4c 10 f0       	mov    $0xf0104c2e,%eax
f01040ae:	66 a3 70 52 2a f0    	mov    %ax,0xf02a5270
f01040b4:	66 c7 05 72 52 2a f0 	movw   $0x8,0xf02a5272
f01040bb:	08 00 
f01040bd:	c6 05 74 52 2a f0 00 	movb   $0x0,0xf02a5274
f01040c4:	c6 05 75 52 2a f0 8e 	movb   $0x8e,0xf02a5275
f01040cb:	c1 e8 10             	shr    $0x10,%eax
f01040ce:	66 a3 76 52 2a f0    	mov    %ax,0xf02a5276
	SETGATE(idt[T_BRKPT],   0, GD_KT, (void*)H_BRKPT,  3);  // User level previlege (3)
f01040d4:	b8 38 4c 10 f0       	mov    $0xf0104c38,%eax
f01040d9:	66 a3 78 52 2a f0    	mov    %ax,0xf02a5278
f01040df:	66 c7 05 7a 52 2a f0 	movw   $0x8,0xf02a527a
f01040e6:	08 00 
f01040e8:	c6 05 7c 52 2a f0 00 	movb   $0x0,0xf02a527c
f01040ef:	c6 05 7d 52 2a f0 ee 	movb   $0xee,0xf02a527d
f01040f6:	c1 e8 10             	shr    $0x10,%eax
f01040f9:	66 a3 7e 52 2a f0    	mov    %ax,0xf02a527e
	SETGATE(idt[T_OFLOW],   0, GD_KT, (void*)H_OFLOW,  0);  
f01040ff:	b8 42 4c 10 f0       	mov    $0xf0104c42,%eax
f0104104:	66 a3 80 52 2a f0    	mov    %ax,0xf02a5280
f010410a:	66 c7 05 82 52 2a f0 	movw   $0x8,0xf02a5282
f0104111:	08 00 
f0104113:	c6 05 84 52 2a f0 00 	movb   $0x0,0xf02a5284
f010411a:	c6 05 85 52 2a f0 8e 	movb   $0x8e,0xf02a5285
f0104121:	c1 e8 10             	shr    $0x10,%eax
f0104124:	66 a3 86 52 2a f0    	mov    %ax,0xf02a5286
	SETGATE(idt[T_BOUND],   0, GD_KT, (void*)H_BOUND,  0);  
f010412a:	b8 4c 4c 10 f0       	mov    $0xf0104c4c,%eax
f010412f:	66 a3 88 52 2a f0    	mov    %ax,0xf02a5288
f0104135:	66 c7 05 8a 52 2a f0 	movw   $0x8,0xf02a528a
f010413c:	08 00 
f010413e:	c6 05 8c 52 2a f0 00 	movb   $0x0,0xf02a528c
f0104145:	c6 05 8d 52 2a f0 8e 	movb   $0x8e,0xf02a528d
f010414c:	c1 e8 10             	shr    $0x10,%eax
f010414f:	66 a3 8e 52 2a f0    	mov    %ax,0xf02a528e
	SETGATE(idt[T_ILLOP],   0, GD_KT, (void*)H_ILLOP,  0);  
f0104155:	b8 56 4c 10 f0       	mov    $0xf0104c56,%eax
f010415a:	66 a3 90 52 2a f0    	mov    %ax,0xf02a5290
f0104160:	66 c7 05 92 52 2a f0 	movw   $0x8,0xf02a5292
f0104167:	08 00 
f0104169:	c6 05 94 52 2a f0 00 	movb   $0x0,0xf02a5294
f0104170:	c6 05 95 52 2a f0 8e 	movb   $0x8e,0xf02a5295
f0104177:	c1 e8 10             	shr    $0x10,%eax
f010417a:	66 a3 96 52 2a f0    	mov    %ax,0xf02a5296
	SETGATE(idt[T_DEVICE],  0, GD_KT, (void*)H_DEVICE, 0);   
f0104180:	b8 60 4c 10 f0       	mov    $0xf0104c60,%eax
f0104185:	66 a3 98 52 2a f0    	mov    %ax,0xf02a5298
f010418b:	66 c7 05 9a 52 2a f0 	movw   $0x8,0xf02a529a
f0104192:	08 00 
f0104194:	c6 05 9c 52 2a f0 00 	movb   $0x0,0xf02a529c
f010419b:	c6 05 9d 52 2a f0 8e 	movb   $0x8e,0xf02a529d
f01041a2:	c1 e8 10             	shr    $0x10,%eax
f01041a5:	66 a3 9e 52 2a f0    	mov    %ax,0xf02a529e
	SETGATE(idt[T_DBLFLT],  0, GD_KT, (void*)H_DBLFLT, 0);   
f01041ab:	b8 6a 4c 10 f0       	mov    $0xf0104c6a,%eax
f01041b0:	66 a3 a0 52 2a f0    	mov    %ax,0xf02a52a0
f01041b6:	66 c7 05 a2 52 2a f0 	movw   $0x8,0xf02a52a2
f01041bd:	08 00 
f01041bf:	c6 05 a4 52 2a f0 00 	movb   $0x0,0xf02a52a4
f01041c6:	c6 05 a5 52 2a f0 8e 	movb   $0x8e,0xf02a52a5
f01041cd:	c1 e8 10             	shr    $0x10,%eax
f01041d0:	66 a3 a6 52 2a f0    	mov    %ax,0xf02a52a6
	SETGATE(idt[T_TSS],     0, GD_KT, (void*)H_TSS,    0);
f01041d6:	b8 72 4c 10 f0       	mov    $0xf0104c72,%eax
f01041db:	66 a3 b0 52 2a f0    	mov    %ax,0xf02a52b0
f01041e1:	66 c7 05 b2 52 2a f0 	movw   $0x8,0xf02a52b2
f01041e8:	08 00 
f01041ea:	c6 05 b4 52 2a f0 00 	movb   $0x0,0xf02a52b4
f01041f1:	c6 05 b5 52 2a f0 8e 	movb   $0x8e,0xf02a52b5
f01041f8:	c1 e8 10             	shr    $0x10,%eax
f01041fb:	66 a3 b6 52 2a f0    	mov    %ax,0xf02a52b6
	SETGATE(idt[T_SEGNP],   0, GD_KT, (void*)H_SEGNP,  0);  
f0104201:	b8 7a 4c 10 f0       	mov    $0xf0104c7a,%eax
f0104206:	66 a3 b8 52 2a f0    	mov    %ax,0xf02a52b8
f010420c:	66 c7 05 ba 52 2a f0 	movw   $0x8,0xf02a52ba
f0104213:	08 00 
f0104215:	c6 05 bc 52 2a f0 00 	movb   $0x0,0xf02a52bc
f010421c:	c6 05 bd 52 2a f0 8e 	movb   $0x8e,0xf02a52bd
f0104223:	c1 e8 10             	shr    $0x10,%eax
f0104226:	66 a3 be 52 2a f0    	mov    %ax,0xf02a52be
	SETGATE(idt[T_STACK],   0, GD_KT, (void*)H_STACK,  0);  
f010422c:	b8 82 4c 10 f0       	mov    $0xf0104c82,%eax
f0104231:	66 a3 c0 52 2a f0    	mov    %ax,0xf02a52c0
f0104237:	66 c7 05 c2 52 2a f0 	movw   $0x8,0xf02a52c2
f010423e:	08 00 
f0104240:	c6 05 c4 52 2a f0 00 	movb   $0x0,0xf02a52c4
f0104247:	c6 05 c5 52 2a f0 8e 	movb   $0x8e,0xf02a52c5
f010424e:	c1 e8 10             	shr    $0x10,%eax
f0104251:	66 a3 c6 52 2a f0    	mov    %ax,0xf02a52c6
	SETGATE(idt[T_GPFLT],   0, GD_KT, (void*)H_GPFLT,  0);  
f0104257:	b8 8a 4c 10 f0       	mov    $0xf0104c8a,%eax
f010425c:	66 a3 c8 52 2a f0    	mov    %ax,0xf02a52c8
f0104262:	66 c7 05 ca 52 2a f0 	movw   $0x8,0xf02a52ca
f0104269:	08 00 
f010426b:	c6 05 cc 52 2a f0 00 	movb   $0x0,0xf02a52cc
f0104272:	c6 05 cd 52 2a f0 8e 	movb   $0x8e,0xf02a52cd
f0104279:	c1 e8 10             	shr    $0x10,%eax
f010427c:	66 a3 ce 52 2a f0    	mov    %ax,0xf02a52ce
	SETGATE(idt[T_PGFLT],   0, GD_KT, (void*)H_PGFLT,  0);  
f0104282:	b8 92 4c 10 f0       	mov    $0xf0104c92,%eax
f0104287:	66 a3 d0 52 2a f0    	mov    %ax,0xf02a52d0
f010428d:	66 c7 05 d2 52 2a f0 	movw   $0x8,0xf02a52d2
f0104294:	08 00 
f0104296:	c6 05 d4 52 2a f0 00 	movb   $0x0,0xf02a52d4
f010429d:	c6 05 d5 52 2a f0 8e 	movb   $0x8e,0xf02a52d5
f01042a4:	c1 e8 10             	shr    $0x10,%eax
f01042a7:	66 a3 d6 52 2a f0    	mov    %ax,0xf02a52d6
	SETGATE(idt[T_FPERR],   0, GD_KT, (void*)H_FPERR,  0);  
f01042ad:	b8 96 4c 10 f0       	mov    $0xf0104c96,%eax
f01042b2:	66 a3 e0 52 2a f0    	mov    %ax,0xf02a52e0
f01042b8:	66 c7 05 e2 52 2a f0 	movw   $0x8,0xf02a52e2
f01042bf:	08 00 
f01042c1:	c6 05 e4 52 2a f0 00 	movb   $0x0,0xf02a52e4
f01042c8:	c6 05 e5 52 2a f0 8e 	movb   $0x8e,0xf02a52e5
f01042cf:	c1 e8 10             	shr    $0x10,%eax
f01042d2:	66 a3 e6 52 2a f0    	mov    %ax,0xf02a52e6
	SETGATE(idt[T_ALIGN],   0, GD_KT, (void*)H_ALIGN,  0);  
f01042d8:	b8 9c 4c 10 f0       	mov    $0xf0104c9c,%eax
f01042dd:	66 a3 e8 52 2a f0    	mov    %ax,0xf02a52e8
f01042e3:	66 c7 05 ea 52 2a f0 	movw   $0x8,0xf02a52ea
f01042ea:	08 00 
f01042ec:	c6 05 ec 52 2a f0 00 	movb   $0x0,0xf02a52ec
f01042f3:	c6 05 ed 52 2a f0 8e 	movb   $0x8e,0xf02a52ed
f01042fa:	c1 e8 10             	shr    $0x10,%eax
f01042fd:	66 a3 ee 52 2a f0    	mov    %ax,0xf02a52ee
	SETGATE(idt[T_MCHK],    0, GD_KT, (void*)H_MCHK,   0); 
f0104303:	b8 a2 4c 10 f0       	mov    $0xf0104ca2,%eax
f0104308:	66 a3 f0 52 2a f0    	mov    %ax,0xf02a52f0
f010430e:	66 c7 05 f2 52 2a f0 	movw   $0x8,0xf02a52f2
f0104315:	08 00 
f0104317:	c6 05 f4 52 2a f0 00 	movb   $0x0,0xf02a52f4
f010431e:	c6 05 f5 52 2a f0 8e 	movb   $0x8e,0xf02a52f5
f0104325:	c1 e8 10             	shr    $0x10,%eax
f0104328:	66 a3 f6 52 2a f0    	mov    %ax,0xf02a52f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, (void*)H_SIMDERR,0);  
f010432e:	b8 a8 4c 10 f0       	mov    $0xf0104ca8,%eax
f0104333:	66 a3 f8 52 2a f0    	mov    %ax,0xf02a52f8
f0104339:	66 c7 05 fa 52 2a f0 	movw   $0x8,0xf02a52fa
f0104340:	08 00 
f0104342:	c6 05 fc 52 2a f0 00 	movb   $0x0,0xf02a52fc
f0104349:	c6 05 fd 52 2a f0 8e 	movb   $0x8e,0xf02a52fd
f0104350:	c1 e8 10             	shr    $0x10,%eax
f0104353:	66 a3 fe 52 2a f0    	mov    %ax,0xf02a52fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, (void*)H_SYSCALL,3);  // System call
f0104359:	b8 ae 4c 10 f0       	mov    $0xf0104cae,%eax
f010435e:	66 a3 e0 53 2a f0    	mov    %ax,0xf02a53e0
f0104364:	66 c7 05 e2 53 2a f0 	movw   $0x8,0xf02a53e2
f010436b:	08 00 
f010436d:	c6 05 e4 53 2a f0 00 	movb   $0x0,0xf02a53e4
f0104374:	c6 05 e5 53 2a f0 ee 	movb   $0xee,0xf02a53e5
f010437b:	c1 e8 10             	shr    $0x10,%eax
f010437e:	66 a3 e6 53 2a f0    	mov    %ax,0xf02a53e6
	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER],    0, GD_KT, (void*)H_TIMER,  0);
f0104384:	b8 b4 4c 10 f0       	mov    $0xf0104cb4,%eax
f0104389:	66 a3 60 53 2a f0    	mov    %ax,0xf02a5360
f010438f:	66 c7 05 62 53 2a f0 	movw   $0x8,0xf02a5362
f0104396:	08 00 
f0104398:	c6 05 64 53 2a f0 00 	movb   $0x0,0xf02a5364
f010439f:	c6 05 65 53 2a f0 8e 	movb   $0x8e,0xf02a5365
f01043a6:	c1 e8 10             	shr    $0x10,%eax
f01043a9:	66 a3 66 53 2a f0    	mov    %ax,0xf02a5366
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD],      0, GD_KT, (void*)H_KBD,    0);
f01043af:	b8 ba 4c 10 f0       	mov    $0xf0104cba,%eax
f01043b4:	66 a3 68 53 2a f0    	mov    %ax,0xf02a5368
f01043ba:	66 c7 05 6a 53 2a f0 	movw   $0x8,0xf02a536a
f01043c1:	08 00 
f01043c3:	c6 05 6c 53 2a f0 00 	movb   $0x0,0xf02a536c
f01043ca:	c6 05 6d 53 2a f0 8e 	movb   $0x8e,0xf02a536d
f01043d1:	c1 e8 10             	shr    $0x10,%eax
f01043d4:	66 a3 6e 53 2a f0    	mov    %ax,0xf02a536e
	SETGATE(idt[IRQ_OFFSET + 2],            0, GD_KT, (void*)H_IRQ2,   0);
f01043da:	b8 c0 4c 10 f0       	mov    $0xf0104cc0,%eax
f01043df:	66 a3 70 53 2a f0    	mov    %ax,0xf02a5370
f01043e5:	66 c7 05 72 53 2a f0 	movw   $0x8,0xf02a5372
f01043ec:	08 00 
f01043ee:	c6 05 74 53 2a f0 00 	movb   $0x0,0xf02a5374
f01043f5:	c6 05 75 53 2a f0 8e 	movb   $0x8e,0xf02a5375
f01043fc:	c1 e8 10             	shr    $0x10,%eax
f01043ff:	66 a3 76 53 2a f0    	mov    %ax,0xf02a5376
	SETGATE(idt[IRQ_OFFSET + 3],            0, GD_KT, (void*)H_IRQ3,   0);
f0104405:	b8 c6 4c 10 f0       	mov    $0xf0104cc6,%eax
f010440a:	66 a3 78 53 2a f0    	mov    %ax,0xf02a5378
f0104410:	66 c7 05 7a 53 2a f0 	movw   $0x8,0xf02a537a
f0104417:	08 00 
f0104419:	c6 05 7c 53 2a f0 00 	movb   $0x0,0xf02a537c
f0104420:	c6 05 7d 53 2a f0 8e 	movb   $0x8e,0xf02a537d
f0104427:	c1 e8 10             	shr    $0x10,%eax
f010442a:	66 a3 7e 53 2a f0    	mov    %ax,0xf02a537e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL],   0, GD_KT, (void*)H_SERIAL, 0);
f0104430:	b8 cc 4c 10 f0       	mov    $0xf0104ccc,%eax
f0104435:	66 a3 80 53 2a f0    	mov    %ax,0xf02a5380
f010443b:	66 c7 05 82 53 2a f0 	movw   $0x8,0xf02a5382
f0104442:	08 00 
f0104444:	c6 05 84 53 2a f0 00 	movb   $0x0,0xf02a5384
f010444b:	c6 05 85 53 2a f0 8e 	movb   $0x8e,0xf02a5385
f0104452:	c1 e8 10             	shr    $0x10,%eax
f0104455:	66 a3 86 53 2a f0    	mov    %ax,0xf02a5386
	SETGATE(idt[IRQ_OFFSET + 5],            0, GD_KT, (void*)H_IRQ5,   0);
f010445b:	b8 d2 4c 10 f0       	mov    $0xf0104cd2,%eax
f0104460:	66 a3 88 53 2a f0    	mov    %ax,0xf02a5388
f0104466:	66 c7 05 8a 53 2a f0 	movw   $0x8,0xf02a538a
f010446d:	08 00 
f010446f:	c6 05 8c 53 2a f0 00 	movb   $0x0,0xf02a538c
f0104476:	c6 05 8d 53 2a f0 8e 	movb   $0x8e,0xf02a538d
f010447d:	c1 e8 10             	shr    $0x10,%eax
f0104480:	66 a3 8e 53 2a f0    	mov    %ax,0xf02a538e
	SETGATE(idt[IRQ_OFFSET + 6],            0, GD_KT, (void*)H_IRQ6,   0);
f0104486:	b8 d8 4c 10 f0       	mov    $0xf0104cd8,%eax
f010448b:	66 a3 90 53 2a f0    	mov    %ax,0xf02a5390
f0104491:	66 c7 05 92 53 2a f0 	movw   $0x8,0xf02a5392
f0104498:	08 00 
f010449a:	c6 05 94 53 2a f0 00 	movb   $0x0,0xf02a5394
f01044a1:	c6 05 95 53 2a f0 8e 	movb   $0x8e,0xf02a5395
f01044a8:	c1 e8 10             	shr    $0x10,%eax
f01044ab:	66 a3 96 53 2a f0    	mov    %ax,0xf02a5396
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, (void*)H_SPUR,   0);
f01044b1:	b8 de 4c 10 f0       	mov    $0xf0104cde,%eax
f01044b6:	66 a3 98 53 2a f0    	mov    %ax,0xf02a5398
f01044bc:	66 c7 05 9a 53 2a f0 	movw   $0x8,0xf02a539a
f01044c3:	08 00 
f01044c5:	c6 05 9c 53 2a f0 00 	movb   $0x0,0xf02a539c
f01044cc:	c6 05 9d 53 2a f0 8e 	movb   $0x8e,0xf02a539d
f01044d3:	c1 e8 10             	shr    $0x10,%eax
f01044d6:	66 a3 9e 53 2a f0    	mov    %ax,0xf02a539e
	SETGATE(idt[IRQ_OFFSET + 8],            0, GD_KT, (void*)H_IRQ8,   0);
f01044dc:	b8 e4 4c 10 f0       	mov    $0xf0104ce4,%eax
f01044e1:	66 a3 a0 53 2a f0    	mov    %ax,0xf02a53a0
f01044e7:	66 c7 05 a2 53 2a f0 	movw   $0x8,0xf02a53a2
f01044ee:	08 00 
f01044f0:	c6 05 a4 53 2a f0 00 	movb   $0x0,0xf02a53a4
f01044f7:	c6 05 a5 53 2a f0 8e 	movb   $0x8e,0xf02a53a5
f01044fe:	c1 e8 10             	shr    $0x10,%eax
f0104501:	66 a3 a6 53 2a f0    	mov    %ax,0xf02a53a6
	SETGATE(idt[IRQ_OFFSET + 9],            0, GD_KT, (void*)H_IRQ9,   0);
f0104507:	b8 ea 4c 10 f0       	mov    $0xf0104cea,%eax
f010450c:	66 a3 a8 53 2a f0    	mov    %ax,0xf02a53a8
f0104512:	66 c7 05 aa 53 2a f0 	movw   $0x8,0xf02a53aa
f0104519:	08 00 
f010451b:	c6 05 ac 53 2a f0 00 	movb   $0x0,0xf02a53ac
f0104522:	c6 05 ad 53 2a f0 8e 	movb   $0x8e,0xf02a53ad
f0104529:	c1 e8 10             	shr    $0x10,%eax
f010452c:	66 a3 ae 53 2a f0    	mov    %ax,0xf02a53ae
	SETGATE(idt[IRQ_OFFSET + 10],           0, GD_KT, (void*)H_IRQ10,  0);
f0104532:	b8 f0 4c 10 f0       	mov    $0xf0104cf0,%eax
f0104537:	66 a3 b0 53 2a f0    	mov    %ax,0xf02a53b0
f010453d:	66 c7 05 b2 53 2a f0 	movw   $0x8,0xf02a53b2
f0104544:	08 00 
f0104546:	c6 05 b4 53 2a f0 00 	movb   $0x0,0xf02a53b4
f010454d:	c6 05 b5 53 2a f0 8e 	movb   $0x8e,0xf02a53b5
f0104554:	c1 e8 10             	shr    $0x10,%eax
f0104557:	66 a3 b6 53 2a f0    	mov    %ax,0xf02a53b6
	SETGATE(idt[IRQ_OFFSET + 11],           0, GD_KT, (void*)H_IRQ11,  0);
f010455d:	b8 f6 4c 10 f0       	mov    $0xf0104cf6,%eax
f0104562:	66 a3 b8 53 2a f0    	mov    %ax,0xf02a53b8
f0104568:	66 c7 05 ba 53 2a f0 	movw   $0x8,0xf02a53ba
f010456f:	08 00 
f0104571:	c6 05 bc 53 2a f0 00 	movb   $0x0,0xf02a53bc
f0104578:	c6 05 bd 53 2a f0 8e 	movb   $0x8e,0xf02a53bd
f010457f:	c1 e8 10             	shr    $0x10,%eax
f0104582:	66 a3 be 53 2a f0    	mov    %ax,0xf02a53be
	SETGATE(idt[IRQ_OFFSET + 12],           0, GD_KT, (void*)H_IRQ12,  0);
f0104588:	b8 fc 4c 10 f0       	mov    $0xf0104cfc,%eax
f010458d:	66 a3 c0 53 2a f0    	mov    %ax,0xf02a53c0
f0104593:	66 c7 05 c2 53 2a f0 	movw   $0x8,0xf02a53c2
f010459a:	08 00 
f010459c:	c6 05 c4 53 2a f0 00 	movb   $0x0,0xf02a53c4
f01045a3:	c6 05 c5 53 2a f0 8e 	movb   $0x8e,0xf02a53c5
f01045aa:	c1 e8 10             	shr    $0x10,%eax
f01045ad:	66 a3 c6 53 2a f0    	mov    %ax,0xf02a53c6
	SETGATE(idt[IRQ_OFFSET + 13],           0, GD_KT, (void*)H_IRQ13,  0);
f01045b3:	b8 02 4d 10 f0       	mov    $0xf0104d02,%eax
f01045b8:	66 a3 c8 53 2a f0    	mov    %ax,0xf02a53c8
f01045be:	66 c7 05 ca 53 2a f0 	movw   $0x8,0xf02a53ca
f01045c5:	08 00 
f01045c7:	c6 05 cc 53 2a f0 00 	movb   $0x0,0xf02a53cc
f01045ce:	c6 05 cd 53 2a f0 8e 	movb   $0x8e,0xf02a53cd
f01045d5:	c1 e8 10             	shr    $0x10,%eax
f01045d8:	66 a3 ce 53 2a f0    	mov    %ax,0xf02a53ce
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE],      0, GD_KT, (void*)H_IDE,    0);
f01045de:	b8 08 4d 10 f0       	mov    $0xf0104d08,%eax
f01045e3:	66 a3 d0 53 2a f0    	mov    %ax,0xf02a53d0
f01045e9:	66 c7 05 d2 53 2a f0 	movw   $0x8,0xf02a53d2
f01045f0:	08 00 
f01045f2:	c6 05 d4 53 2a f0 00 	movb   $0x0,0xf02a53d4
f01045f9:	c6 05 d5 53 2a f0 8e 	movb   $0x8e,0xf02a53d5
f0104600:	c1 e8 10             	shr    $0x10,%eax
f0104603:	66 a3 d6 53 2a f0    	mov    %ax,0xf02a53d6
	SETGATE(idt[IRQ_OFFSET + 15],           0, GD_KT, (void*)H_IRQ15,  0);
f0104609:	b8 0e 4d 10 f0       	mov    $0xf0104d0e,%eax
f010460e:	66 a3 d8 53 2a f0    	mov    %ax,0xf02a53d8
f0104614:	66 c7 05 da 53 2a f0 	movw   $0x8,0xf02a53da
f010461b:	08 00 
f010461d:	c6 05 dc 53 2a f0 00 	movb   $0x0,0xf02a53dc
f0104624:	c6 05 dd 53 2a f0 8e 	movb   $0x8e,0xf02a53dd
f010462b:	c1 e8 10             	shr    $0x10,%eax
f010462e:	66 a3 de 53 2a f0    	mov    %ax,0xf02a53de
	trap_init_percpu();
f0104634:	e8 74 f9 ff ff       	call   f0103fad <trap_init_percpu>
}
f0104639:	c9                   	leave  
f010463a:	c3                   	ret    

f010463b <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f010463b:	55                   	push   %ebp
f010463c:	89 e5                	mov    %esp,%ebp
f010463e:	53                   	push   %ebx
f010463f:	83 ec 0c             	sub    $0xc,%esp
f0104642:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0104645:	ff 33                	pushl  (%ebx)
f0104647:	68 7e 83 10 f0       	push   $0xf010837e
f010464c:	e8 48 f9 ff ff       	call   f0103f99 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104651:	83 c4 08             	add    $0x8,%esp
f0104654:	ff 73 04             	pushl  0x4(%ebx)
f0104657:	68 8d 83 10 f0       	push   $0xf010838d
f010465c:	e8 38 f9 ff ff       	call   f0103f99 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104661:	83 c4 08             	add    $0x8,%esp
f0104664:	ff 73 08             	pushl  0x8(%ebx)
f0104667:	68 9c 83 10 f0       	push   $0xf010839c
f010466c:	e8 28 f9 ff ff       	call   f0103f99 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104671:	83 c4 08             	add    $0x8,%esp
f0104674:	ff 73 0c             	pushl  0xc(%ebx)
f0104677:	68 ab 83 10 f0       	push   $0xf01083ab
f010467c:	e8 18 f9 ff ff       	call   f0103f99 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104681:	83 c4 08             	add    $0x8,%esp
f0104684:	ff 73 10             	pushl  0x10(%ebx)
f0104687:	68 ba 83 10 f0       	push   $0xf01083ba
f010468c:	e8 08 f9 ff ff       	call   f0103f99 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104691:	83 c4 08             	add    $0x8,%esp
f0104694:	ff 73 14             	pushl  0x14(%ebx)
f0104697:	68 c9 83 10 f0       	push   $0xf01083c9
f010469c:	e8 f8 f8 ff ff       	call   f0103f99 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01046a1:	83 c4 08             	add    $0x8,%esp
f01046a4:	ff 73 18             	pushl  0x18(%ebx)
f01046a7:	68 d8 83 10 f0       	push   $0xf01083d8
f01046ac:	e8 e8 f8 ff ff       	call   f0103f99 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01046b1:	83 c4 08             	add    $0x8,%esp
f01046b4:	ff 73 1c             	pushl  0x1c(%ebx)
f01046b7:	68 e7 83 10 f0       	push   $0xf01083e7
f01046bc:	e8 d8 f8 ff ff       	call   f0103f99 <cprintf>
}
f01046c1:	83 c4 10             	add    $0x10,%esp
f01046c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01046c7:	c9                   	leave  
f01046c8:	c3                   	ret    

f01046c9 <print_trapframe>:
{
f01046c9:	55                   	push   %ebp
f01046ca:	89 e5                	mov    %esp,%ebp
f01046cc:	53                   	push   %ebx
f01046cd:	83 ec 04             	sub    $0x4,%esp
f01046d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01046d3:	e8 4a 20 00 00       	call   f0106722 <cpunum>
f01046d8:	83 ec 04             	sub    $0x4,%esp
f01046db:	50                   	push   %eax
f01046dc:	53                   	push   %ebx
f01046dd:	68 4b 84 10 f0       	push   $0xf010844b
f01046e2:	e8 b2 f8 ff ff       	call   f0103f99 <cprintf>
	print_regs(&tf->tf_regs);
f01046e7:	89 1c 24             	mov    %ebx,(%esp)
f01046ea:	e8 4c ff ff ff       	call   f010463b <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01046ef:	83 c4 08             	add    $0x8,%esp
f01046f2:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01046f6:	50                   	push   %eax
f01046f7:	68 69 84 10 f0       	push   $0xf0108469
f01046fc:	e8 98 f8 ff ff       	call   f0103f99 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104701:	83 c4 08             	add    $0x8,%esp
f0104704:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0104708:	50                   	push   %eax
f0104709:	68 7c 84 10 f0       	push   $0xf010847c
f010470e:	e8 86 f8 ff ff       	call   f0103f99 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104713:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0104716:	83 c4 10             	add    $0x10,%esp
f0104719:	83 f8 13             	cmp    $0x13,%eax
f010471c:	76 1c                	jbe    f010473a <print_trapframe+0x71>
	if (trapno == T_SYSCALL)
f010471e:	83 f8 30             	cmp    $0x30,%eax
f0104721:	0f 84 cf 00 00 00    	je     f01047f6 <print_trapframe+0x12d>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104727:	8d 50 e0             	lea    -0x20(%eax),%edx
f010472a:	83 fa 0f             	cmp    $0xf,%edx
f010472d:	0f 86 cd 00 00 00    	jbe    f0104800 <print_trapframe+0x137>
	return "(unknown trap)";
f0104733:	ba 15 84 10 f0       	mov    $0xf0108415,%edx
f0104738:	eb 07                	jmp    f0104741 <print_trapframe+0x78>
		return excnames[trapno];
f010473a:	8b 14 85 20 87 10 f0 	mov    -0xfef78e0(,%eax,4),%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104741:	83 ec 04             	sub    $0x4,%esp
f0104744:	52                   	push   %edx
f0104745:	50                   	push   %eax
f0104746:	68 8f 84 10 f0       	push   $0xf010848f
f010474b:	e8 49 f8 ff ff       	call   f0103f99 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104750:	83 c4 10             	add    $0x10,%esp
f0104753:	39 1d 60 5a 2a f0    	cmp    %ebx,0xf02a5a60
f0104759:	0f 84 ab 00 00 00    	je     f010480a <print_trapframe+0x141>
	cprintf("  err  0x%08x", tf->tf_err);
f010475f:	83 ec 08             	sub    $0x8,%esp
f0104762:	ff 73 2c             	pushl  0x2c(%ebx)
f0104765:	68 b0 84 10 f0       	push   $0xf01084b0
f010476a:	e8 2a f8 ff ff       	call   f0103f99 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f010476f:	83 c4 10             	add    $0x10,%esp
f0104772:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104776:	0f 85 cf 00 00 00    	jne    f010484b <print_trapframe+0x182>
			tf->tf_err & 1 ? "protection" : "not-present");
f010477c:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f010477f:	a8 01                	test   $0x1,%al
f0104781:	0f 85 a6 00 00 00    	jne    f010482d <print_trapframe+0x164>
f0104787:	b9 2f 84 10 f0       	mov    $0xf010842f,%ecx
f010478c:	a8 02                	test   $0x2,%al
f010478e:	0f 85 a3 00 00 00    	jne    f0104837 <print_trapframe+0x16e>
f0104794:	ba 41 84 10 f0       	mov    $0xf0108441,%edx
f0104799:	a8 04                	test   $0x4,%al
f010479b:	0f 85 a0 00 00 00    	jne    f0104841 <print_trapframe+0x178>
f01047a1:	b8 7b 85 10 f0       	mov    $0xf010857b,%eax
f01047a6:	51                   	push   %ecx
f01047a7:	52                   	push   %edx
f01047a8:	50                   	push   %eax
f01047a9:	68 be 84 10 f0       	push   $0xf01084be
f01047ae:	e8 e6 f7 ff ff       	call   f0103f99 <cprintf>
f01047b3:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01047b6:	83 ec 08             	sub    $0x8,%esp
f01047b9:	ff 73 30             	pushl  0x30(%ebx)
f01047bc:	68 cd 84 10 f0       	push   $0xf01084cd
f01047c1:	e8 d3 f7 ff ff       	call   f0103f99 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01047c6:	83 c4 08             	add    $0x8,%esp
f01047c9:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01047cd:	50                   	push   %eax
f01047ce:	68 dc 84 10 f0       	push   $0xf01084dc
f01047d3:	e8 c1 f7 ff ff       	call   f0103f99 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01047d8:	83 c4 08             	add    $0x8,%esp
f01047db:	ff 73 38             	pushl  0x38(%ebx)
f01047de:	68 ef 84 10 f0       	push   $0xf01084ef
f01047e3:	e8 b1 f7 ff ff       	call   f0103f99 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01047e8:	83 c4 10             	add    $0x10,%esp
f01047eb:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01047ef:	75 6f                	jne    f0104860 <print_trapframe+0x197>
}
f01047f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01047f4:	c9                   	leave  
f01047f5:	c3                   	ret    
		return "System call";
f01047f6:	ba f6 83 10 f0       	mov    $0xf01083f6,%edx
f01047fb:	e9 41 ff ff ff       	jmp    f0104741 <print_trapframe+0x78>
		return "Hardware Interrupt";
f0104800:	ba 02 84 10 f0       	mov    $0xf0108402,%edx
f0104805:	e9 37 ff ff ff       	jmp    f0104741 <print_trapframe+0x78>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010480a:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010480e:	0f 85 4b ff ff ff    	jne    f010475f <print_trapframe+0x96>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0104814:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104817:	83 ec 08             	sub    $0x8,%esp
f010481a:	50                   	push   %eax
f010481b:	68 a1 84 10 f0       	push   $0xf01084a1
f0104820:	e8 74 f7 ff ff       	call   f0103f99 <cprintf>
f0104825:	83 c4 10             	add    $0x10,%esp
f0104828:	e9 32 ff ff ff       	jmp    f010475f <print_trapframe+0x96>
		cprintf(" [%s, %s, %s]\n",
f010482d:	b9 24 84 10 f0       	mov    $0xf0108424,%ecx
f0104832:	e9 55 ff ff ff       	jmp    f010478c <print_trapframe+0xc3>
f0104837:	ba 3b 84 10 f0       	mov    $0xf010843b,%edx
f010483c:	e9 58 ff ff ff       	jmp    f0104799 <print_trapframe+0xd0>
f0104841:	b8 46 84 10 f0       	mov    $0xf0108446,%eax
f0104846:	e9 5b ff ff ff       	jmp    f01047a6 <print_trapframe+0xdd>
		cprintf("\n");
f010484b:	83 ec 0c             	sub    $0xc,%esp
f010484e:	68 fb 71 10 f0       	push   $0xf01071fb
f0104853:	e8 41 f7 ff ff       	call   f0103f99 <cprintf>
f0104858:	83 c4 10             	add    $0x10,%esp
f010485b:	e9 56 ff ff ff       	jmp    f01047b6 <print_trapframe+0xed>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104860:	83 ec 08             	sub    $0x8,%esp
f0104863:	ff 73 3c             	pushl  0x3c(%ebx)
f0104866:	68 fe 84 10 f0       	push   $0xf01084fe
f010486b:	e8 29 f7 ff ff       	call   f0103f99 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104870:	83 c4 08             	add    $0x8,%esp
f0104873:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104877:	50                   	push   %eax
f0104878:	68 0d 85 10 f0       	push   $0xf010850d
f010487d:	e8 17 f7 ff ff       	call   f0103f99 <cprintf>
f0104882:	83 c4 10             	add    $0x10,%esp
}
f0104885:	e9 67 ff ff ff       	jmp    f01047f1 <print_trapframe+0x128>

f010488a <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010488a:	55                   	push   %ebp
f010488b:	89 e5                	mov    %esp,%ebp
f010488d:	57                   	push   %edi
f010488e:	56                   	push   %esi
f010488f:	53                   	push   %ebx
f0104890:	83 ec 1c             	sub    $0x1c,%esp
f0104893:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104896:	0f 20 d6             	mov    %cr2,%esi

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	uint16_t cs = tf->tf_cs;
	if ((cs & 0xFF) == GD_KT) { // code segment descriptor is kernel
f0104899:	80 7b 34 08          	cmpb   $0x8,0x34(%ebx)
f010489d:	0f 84 ad 00 00 00    	je     f0104950 <page_fault_handler+0xc6>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').


	if (!curenv->env_pgfault_upcall) {
f01048a3:	e8 7a 1e 00 00       	call   f0106722 <cpunum>
f01048a8:	6b c0 74             	imul   $0x74,%eax,%eax
f01048ab:	8b 80 28 60 2a f0    	mov    -0xfd59fd8(%eax),%eax
f01048b1:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f01048b5:	0f 84 b3 00 00 00    	je     f010496e <page_fault_handler+0xe4>
		print_trapframe(tf);
		env_destroy(curenv);
	}

	// Backup the current stack pointer.
	uintptr_t esp = tf->tf_esp;
f01048bb:	8b 4b 3c             	mov    0x3c(%ebx),%ecx
f01048be:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	
	// Get stack point to the right place.
	// Then, check whether the user can write memory there.
	// If not, curenv will be destroyed, and things are simpler.
	if (tf->tf_esp < UXSTACKTOP && tf->tf_esp >= UXSTACKTOP - PGSIZE) {
f01048c1:	8d 81 00 10 40 11    	lea    0x11401000(%ecx),%eax
f01048c7:	3d ff 0f 00 00       	cmp    $0xfff,%eax
f01048cc:	0f 87 e2 00 00 00    	ja     f01049b4 <page_fault_handler+0x12a>
		tf->tf_esp -= 4 + sizeof(struct UTrapframe);
f01048d2:	8d 79 c8             	lea    -0x38(%ecx),%edi
f01048d5:	89 7b 3c             	mov    %edi,0x3c(%ebx)
		user_mem_assert(curenv, (void*)tf->tf_esp, 4 + sizeof(struct UTrapframe), PTE_W | PTE_U);
f01048d8:	e8 45 1e 00 00       	call   f0106722 <cpunum>
f01048dd:	6a 06                	push   $0x6
f01048df:	6a 38                	push   $0x38
f01048e1:	57                   	push   %edi
f01048e2:	6b c0 74             	imul   $0x74,%eax,%eax
f01048e5:	ff b0 28 60 2a f0    	pushl  -0xfd59fd8(%eax)
f01048eb:	e8 26 ec ff ff       	call   f0103516 <user_mem_assert>
		// FIXME
		*((uint32_t*)esp - 1) = 0;  // We also set the int padding to 0.
f01048f0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01048f3:	c7 41 fc 00 00 00 00 	movl   $0x0,-0x4(%ecx)
f01048fa:	83 c4 10             	add    $0x10,%esp
		tf->tf_esp = UXSTACKTOP - sizeof(struct UTrapframe);
		user_mem_assert(curenv, (void*)tf->tf_esp, sizeof(struct UTrapframe), PTE_W | PTE_U);
	}

	// Fill in UTrapframe data
	struct UTrapframe* utf = (struct UTrapframe*)tf->tf_esp;
f01048fd:	8b 43 3c             	mov    0x3c(%ebx),%eax
	utf->utf_fault_va = fault_va;
f0104900:	89 30                	mov    %esi,(%eax)
	utf->utf_err = tf->tf_err;
f0104902:	8b 53 2c             	mov    0x2c(%ebx),%edx
f0104905:	89 50 04             	mov    %edx,0x4(%eax)
	utf->utf_regs = tf->tf_regs;
f0104908:	8d 78 08             	lea    0x8(%eax),%edi
f010490b:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104910:	89 de                	mov    %ebx,%esi
f0104912:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	utf->utf_eip = tf->tf_eip;
f0104914:	8b 53 30             	mov    0x30(%ebx),%edx
f0104917:	89 50 28             	mov    %edx,0x28(%eax)
	utf->utf_eflags = tf->tf_eflags;
f010491a:	8b 53 38             	mov    0x38(%ebx),%edx
f010491d:	89 50 2c             	mov    %edx,0x2c(%eax)
	utf->utf_esp = esp;
f0104920:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104923:	89 78 30             	mov    %edi,0x30(%eax)

	// Modify trapframe so that upcall is triggered next.
	tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0104926:	e8 f7 1d 00 00       	call   f0106722 <cpunum>
f010492b:	6b c0 74             	imul   $0x74,%eax,%eax
f010492e:	8b 80 28 60 2a f0    	mov    -0xfd59fd8(%eax),%eax
f0104934:	8b 40 64             	mov    0x64(%eax),%eax
f0104937:	89 43 30             	mov    %eax,0x30(%ebx)

	// and then run the upcall.
	env_run(curenv);
f010493a:	e8 e3 1d 00 00       	call   f0106722 <cpunum>
f010493f:	83 ec 0c             	sub    $0xc,%esp
f0104942:	6b c0 74             	imul   $0x74,%eax,%eax
f0104945:	ff b0 28 60 2a f0    	pushl  -0xfd59fd8(%eax)
f010494b:	e8 be f3 ff ff       	call   f0103d0e <env_run>
		print_trapframe(tf);
f0104950:	83 ec 0c             	sub    $0xc,%esp
f0104953:	53                   	push   %ebx
f0104954:	e8 70 fd ff ff       	call   f01046c9 <print_trapframe>
		panic("Page fault in kernel mode! Fault addr: %p", fault_va);
f0104959:	56                   	push   %esi
f010495a:	68 c8 86 10 f0       	push   $0xf01086c8
f010495f:	68 5f 01 00 00       	push   $0x15f
f0104964:	68 20 85 10 f0       	push   $0xf0108520
f0104969:	e8 26 b7 ff ff       	call   f0100094 <_panic>
		cprintf("[%08x] user fault va %08x ip %08x\n",
f010496e:	8b 7b 30             	mov    0x30(%ebx),%edi
				curenv->env_id, fault_va, tf->tf_eip);
f0104971:	e8 ac 1d 00 00       	call   f0106722 <cpunum>
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104976:	57                   	push   %edi
f0104977:	56                   	push   %esi
				curenv->env_id, fault_va, tf->tf_eip);
f0104978:	6b c0 74             	imul   $0x74,%eax,%eax
		cprintf("[%08x] user fault va %08x ip %08x\n",
f010497b:	8b 80 28 60 2a f0    	mov    -0xfd59fd8(%eax),%eax
f0104981:	ff 70 48             	pushl  0x48(%eax)
f0104984:	68 f4 86 10 f0       	push   $0xf01086f4
f0104989:	e8 0b f6 ff ff       	call   f0103f99 <cprintf>
		print_trapframe(tf);
f010498e:	89 1c 24             	mov    %ebx,(%esp)
f0104991:	e8 33 fd ff ff       	call   f01046c9 <print_trapframe>
		env_destroy(curenv);
f0104996:	e8 87 1d 00 00       	call   f0106722 <cpunum>
f010499b:	83 c4 04             	add    $0x4,%esp
f010499e:	6b c0 74             	imul   $0x74,%eax,%eax
f01049a1:	ff b0 28 60 2a f0    	pushl  -0xfd59fd8(%eax)
f01049a7:	e8 a5 f2 ff ff       	call   f0103c51 <env_destroy>
f01049ac:	83 c4 10             	add    $0x10,%esp
f01049af:	e9 07 ff ff ff       	jmp    f01048bb <page_fault_handler+0x31>
		tf->tf_esp = UXSTACKTOP - sizeof(struct UTrapframe);
f01049b4:	c7 43 3c cc ff bf ee 	movl   $0xeebfffcc,0x3c(%ebx)
		user_mem_assert(curenv, (void*)tf->tf_esp, sizeof(struct UTrapframe), PTE_W | PTE_U);
f01049bb:	e8 62 1d 00 00       	call   f0106722 <cpunum>
f01049c0:	6a 06                	push   $0x6
f01049c2:	6a 34                	push   $0x34
f01049c4:	68 cc ff bf ee       	push   $0xeebfffcc
f01049c9:	6b c0 74             	imul   $0x74,%eax,%eax
f01049cc:	ff b0 28 60 2a f0    	pushl  -0xfd59fd8(%eax)
f01049d2:	e8 3f eb ff ff       	call   f0103516 <user_mem_assert>
f01049d7:	83 c4 10             	add    $0x10,%esp
f01049da:	e9 1e ff ff ff       	jmp    f01048fd <page_fault_handler+0x73>

f01049df <trap>:
{
f01049df:	55                   	push   %ebp
f01049e0:	89 e5                	mov    %esp,%ebp
f01049e2:	57                   	push   %edi
f01049e3:	56                   	push   %esi
f01049e4:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f01049e7:	fc                   	cld    
	if (panicstr)
f01049e8:	83 3d 80 5e 2a f0 00 	cmpl   $0x0,0xf02a5e80
f01049ef:	74 01                	je     f01049f2 <trap+0x13>
		asm volatile("hlt");
f01049f1:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01049f2:	e8 2b 1d 00 00       	call   f0106722 <cpunum>
f01049f7:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01049fa:	01 c2                	add    %eax,%edx
f01049fc:	01 d2                	add    %edx,%edx
f01049fe:	01 c2                	add    %eax,%edx
f0104a00:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104a03:	8d 14 85 04 00 00 00 	lea    0x4(,%eax,4),%edx
	asm volatile("lock; xchgl %0, %1"
f0104a0a:	b8 01 00 00 00       	mov    $0x1,%eax
f0104a0f:	f0 87 82 20 60 2a f0 	lock xchg %eax,-0xfd59fe0(%edx)
f0104a16:	83 f8 02             	cmp    $0x2,%eax
f0104a19:	74 53                	je     f0104a6e <trap+0x8f>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104a1b:	9c                   	pushf  
f0104a1c:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f0104a1d:	f6 c4 02             	test   $0x2,%ah
f0104a20:	75 5e                	jne    f0104a80 <trap+0xa1>
	if ((tf->tf_cs & 3) == 3) {
f0104a22:	66 8b 46 34          	mov    0x34(%esi),%ax
f0104a26:	83 e0 03             	and    $0x3,%eax
f0104a29:	66 83 f8 03          	cmp    $0x3,%ax
f0104a2d:	74 6a                	je     f0104a99 <trap+0xba>
	last_tf = tf;
f0104a2f:	89 35 60 5a 2a f0    	mov    %esi,0xf02a5a60
	switch(tf->tf_trapno){
f0104a35:	8b 46 28             	mov    0x28(%esi),%eax
f0104a38:	83 f8 0e             	cmp    $0xe,%eax
f0104a3b:	0f 84 fd 00 00 00    	je     f0104b3e <trap+0x15f>
f0104a41:	83 f8 30             	cmp    $0x30,%eax
f0104a44:	0f 84 fd 00 00 00    	je     f0104b47 <trap+0x168>
f0104a4a:	83 f8 03             	cmp    $0x3,%eax
f0104a4d:	0f 85 3d 01 00 00    	jne    f0104b90 <trap+0x1b1>
		print_trapframe(tf);
f0104a53:	83 ec 0c             	sub    $0xc,%esp
f0104a56:	56                   	push   %esi
f0104a57:	e8 6d fc ff ff       	call   f01046c9 <print_trapframe>
f0104a5c:	83 c4 10             	add    $0x10,%esp
			monitor(NULL);
f0104a5f:	83 ec 0c             	sub    $0xc,%esp
f0104a62:	6a 00                	push   $0x0
f0104a64:	e8 ea c3 ff ff       	call   f0100e53 <monitor>
f0104a69:	83 c4 10             	add    $0x10,%esp
f0104a6c:	eb f1                	jmp    f0104a5f <trap+0x80>
	spin_lock(&kernel_lock);
f0104a6e:	83 ec 0c             	sub    $0xc,%esp
f0104a71:	68 c0 33 12 f0       	push   $0xf01233c0
f0104a76:	e8 1b 1f 00 00       	call   f0106996 <spin_lock>
f0104a7b:	83 c4 10             	add    $0x10,%esp
f0104a7e:	eb 9b                	jmp    f0104a1b <trap+0x3c>
	assert(!(read_eflags() & FL_IF));
f0104a80:	68 2c 85 10 f0       	push   $0xf010852c
f0104a85:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0104a8a:	68 2b 01 00 00       	push   $0x12b
f0104a8f:	68 20 85 10 f0       	push   $0xf0108520
f0104a94:	e8 fb b5 ff ff       	call   f0100094 <_panic>
f0104a99:	83 ec 0c             	sub    $0xc,%esp
f0104a9c:	68 c0 33 12 f0       	push   $0xf01233c0
f0104aa1:	e8 f0 1e 00 00       	call   f0106996 <spin_lock>
		assert(curenv);
f0104aa6:	e8 77 1c 00 00       	call   f0106722 <cpunum>
f0104aab:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aae:	83 c4 10             	add    $0x10,%esp
f0104ab1:	83 b8 28 60 2a f0 00 	cmpl   $0x0,-0xfd59fd8(%eax)
f0104ab8:	74 3e                	je     f0104af8 <trap+0x119>
		if (curenv->env_status == ENV_DYING) {
f0104aba:	e8 63 1c 00 00       	call   f0106722 <cpunum>
f0104abf:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ac2:	8b 80 28 60 2a f0    	mov    -0xfd59fd8(%eax),%eax
f0104ac8:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104acc:	74 43                	je     f0104b11 <trap+0x132>
		curenv->env_tf = *tf;
f0104ace:	e8 4f 1c 00 00       	call   f0106722 <cpunum>
f0104ad3:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ad6:	8b 80 28 60 2a f0    	mov    -0xfd59fd8(%eax),%eax
f0104adc:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104ae1:	89 c7                	mov    %eax,%edi
f0104ae3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0104ae5:	e8 38 1c 00 00       	call   f0106722 <cpunum>
f0104aea:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aed:	8b b0 28 60 2a f0    	mov    -0xfd59fd8(%eax),%esi
f0104af3:	e9 37 ff ff ff       	jmp    f0104a2f <trap+0x50>
		assert(curenv);
f0104af8:	68 45 85 10 f0       	push   $0xf0108545
f0104afd:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0104b02:	68 32 01 00 00       	push   $0x132
f0104b07:	68 20 85 10 f0       	push   $0xf0108520
f0104b0c:	e8 83 b5 ff ff       	call   f0100094 <_panic>
			env_free(curenv);
f0104b11:	e8 0c 1c 00 00       	call   f0106722 <cpunum>
f0104b16:	83 ec 0c             	sub    $0xc,%esp
f0104b19:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b1c:	ff b0 28 60 2a f0    	pushl  -0xfd59fd8(%eax)
f0104b22:	e8 65 ef ff ff       	call   f0103a8c <env_free>
			curenv = NULL;
f0104b27:	e8 f6 1b 00 00       	call   f0106722 <cpunum>
f0104b2c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b2f:	c7 80 28 60 2a f0 00 	movl   $0x0,-0xfd59fd8(%eax)
f0104b36:	00 00 00 
			sched_yield();
f0104b39:	e8 d6 02 00 00       	call   f0104e14 <sched_yield>
		page_fault_handler(tf);
f0104b3e:	83 ec 0c             	sub    $0xc,%esp
f0104b41:	56                   	push   %esi
f0104b42:	e8 43 fd ff ff       	call   f010488a <page_fault_handler>
		tf->tf_regs.reg_eax = syscall(
f0104b47:	83 ec 08             	sub    $0x8,%esp
f0104b4a:	ff 76 04             	pushl  0x4(%esi)
f0104b4d:	ff 36                	pushl  (%esi)
f0104b4f:	ff 76 10             	pushl  0x10(%esi)
f0104b52:	ff 76 18             	pushl  0x18(%esi)
f0104b55:	ff 76 14             	pushl  0x14(%esi)
f0104b58:	ff 76 1c             	pushl  0x1c(%esi)
f0104b5b:	e8 26 04 00 00       	call   f0104f86 <syscall>
f0104b60:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104b63:	83 c4 20             	add    $0x20,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104b66:	e8 b7 1b 00 00       	call   f0106722 <cpunum>
f0104b6b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b6e:	83 b8 28 60 2a f0 00 	cmpl   $0x0,-0xfd59fd8(%eax)
f0104b75:	74 14                	je     f0104b8b <trap+0x1ac>
f0104b77:	e8 a6 1b 00 00       	call   f0106722 <cpunum>
f0104b7c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b7f:	8b 80 28 60 2a f0    	mov    -0xfd59fd8(%eax),%eax
f0104b85:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104b89:	74 78                	je     f0104c03 <trap+0x224>
		sched_yield();
f0104b8b:	e8 84 02 00 00       	call   f0104e14 <sched_yield>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104b90:	83 f8 27             	cmp    $0x27,%eax
f0104b93:	74 33                	je     f0104bc8 <trap+0x1e9>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) { 
f0104b95:	83 f8 20             	cmp    $0x20,%eax
f0104b98:	74 48                	je     f0104be2 <trap+0x203>
	print_trapframe(tf);
f0104b9a:	83 ec 0c             	sub    $0xc,%esp
f0104b9d:	56                   	push   %esi
f0104b9e:	e8 26 fb ff ff       	call   f01046c9 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104ba3:	83 c4 10             	add    $0x10,%esp
f0104ba6:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104bab:	74 3f                	je     f0104bec <trap+0x20d>
		env_destroy(curenv);
f0104bad:	e8 70 1b 00 00       	call   f0106722 <cpunum>
f0104bb2:	83 ec 0c             	sub    $0xc,%esp
f0104bb5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bb8:	ff b0 28 60 2a f0    	pushl  -0xfd59fd8(%eax)
f0104bbe:	e8 8e f0 ff ff       	call   f0103c51 <env_destroy>
f0104bc3:	83 c4 10             	add    $0x10,%esp
f0104bc6:	eb 9e                	jmp    f0104b66 <trap+0x187>
		cprintf("Spurious interrupt on irq 7\n");
f0104bc8:	83 ec 0c             	sub    $0xc,%esp
f0104bcb:	68 4c 85 10 f0       	push   $0xf010854c
f0104bd0:	e8 c4 f3 ff ff       	call   f0103f99 <cprintf>
		print_trapframe(tf);
f0104bd5:	89 34 24             	mov    %esi,(%esp)
f0104bd8:	e8 ec fa ff ff       	call   f01046c9 <print_trapframe>
f0104bdd:	83 c4 10             	add    $0x10,%esp
f0104be0:	eb 84                	jmp    f0104b66 <trap+0x187>
		lapic_eoi();
f0104be2:	e8 92 1c 00 00       	call   f0106879 <lapic_eoi>
		sched_yield();
f0104be7:	e8 28 02 00 00       	call   f0104e14 <sched_yield>
		panic("unhandled trap in kernel");
f0104bec:	83 ec 04             	sub    $0x4,%esp
f0104bef:	68 69 85 10 f0       	push   $0xf0108569
f0104bf4:	68 11 01 00 00       	push   $0x111
f0104bf9:	68 20 85 10 f0       	push   $0xf0108520
f0104bfe:	e8 91 b4 ff ff       	call   f0100094 <_panic>
		env_run(curenv);
f0104c03:	e8 1a 1b 00 00       	call   f0106722 <cpunum>
f0104c08:	83 ec 0c             	sub    $0xc,%esp
f0104c0b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c0e:	ff b0 28 60 2a f0    	pushl  -0xfd59fd8(%eax)
f0104c14:	e8 f5 f0 ff ff       	call   f0103d0e <env_run>
f0104c19:	90                   	nop

f0104c1a <H_DIVIDE>:
	pushl $(num);							\
	jmp _alltraps

.text

TRAPHANDLER_NOEC(H_DIVIDE , T_DIVIDE)
f0104c1a:	6a 00                	push   $0x0
f0104c1c:	6a 00                	push   $0x0
f0104c1e:	e9 f1 00 00 00       	jmp    f0104d14 <_alltraps>
f0104c23:	90                   	nop

f0104c24 <H_DEBUG>:
TRAPHANDLER_NOEC(H_DEBUG  , T_DEBUG)
f0104c24:	6a 00                	push   $0x0
f0104c26:	6a 01                	push   $0x1
f0104c28:	e9 e7 00 00 00       	jmp    f0104d14 <_alltraps>
f0104c2d:	90                   	nop

f0104c2e <H_NMI>:
TRAPHANDLER_NOEC(H_NMI    , T_NMI)
f0104c2e:	6a 00                	push   $0x0
f0104c30:	6a 02                	push   $0x2
f0104c32:	e9 dd 00 00 00       	jmp    f0104d14 <_alltraps>
f0104c37:	90                   	nop

f0104c38 <H_BRKPT>:
TRAPHANDLER_NOEC(H_BRKPT  , T_BRKPT)
f0104c38:	6a 00                	push   $0x0
f0104c3a:	6a 03                	push   $0x3
f0104c3c:	e9 d3 00 00 00       	jmp    f0104d14 <_alltraps>
f0104c41:	90                   	nop

f0104c42 <H_OFLOW>:
TRAPHANDLER_NOEC(H_OFLOW  , T_OFLOW)
f0104c42:	6a 00                	push   $0x0
f0104c44:	6a 04                	push   $0x4
f0104c46:	e9 c9 00 00 00       	jmp    f0104d14 <_alltraps>
f0104c4b:	90                   	nop

f0104c4c <H_BOUND>:
TRAPHANDLER_NOEC(H_BOUND  , T_BOUND)
f0104c4c:	6a 00                	push   $0x0
f0104c4e:	6a 05                	push   $0x5
f0104c50:	e9 bf 00 00 00       	jmp    f0104d14 <_alltraps>
f0104c55:	90                   	nop

f0104c56 <H_ILLOP>:
TRAPHANDLER_NOEC(H_ILLOP  , T_ILLOP)
f0104c56:	6a 00                	push   $0x0
f0104c58:	6a 06                	push   $0x6
f0104c5a:	e9 b5 00 00 00       	jmp    f0104d14 <_alltraps>
f0104c5f:	90                   	nop

f0104c60 <H_DEVICE>:
TRAPHANDLER_NOEC(H_DEVICE , T_DEVICE)
f0104c60:	6a 00                	push   $0x0
f0104c62:	6a 07                	push   $0x7
f0104c64:	e9 ab 00 00 00       	jmp    f0104d14 <_alltraps>
f0104c69:	90                   	nop

f0104c6a <H_DBLFLT>:
TRAPHANDLER     (H_DBLFLT , T_DBLFLT)	// Error Code const 0
f0104c6a:	6a 08                	push   $0x8
f0104c6c:	e9 a3 00 00 00       	jmp    f0104d14 <_alltraps>
f0104c71:	90                   	nop

f0104c72 <H_TSS>:
TRAPHANDLER     (H_TSS    , T_TSS)
f0104c72:	6a 0a                	push   $0xa
f0104c74:	e9 9b 00 00 00       	jmp    f0104d14 <_alltraps>
f0104c79:	90                   	nop

f0104c7a <H_SEGNP>:
TRAPHANDLER     (H_SEGNP  , T_SEGNP)
f0104c7a:	6a 0b                	push   $0xb
f0104c7c:	e9 93 00 00 00       	jmp    f0104d14 <_alltraps>
f0104c81:	90                   	nop

f0104c82 <H_STACK>:
TRAPHANDLER     (H_STACK  , T_STACK)
f0104c82:	6a 0c                	push   $0xc
f0104c84:	e9 8b 00 00 00       	jmp    f0104d14 <_alltraps>
f0104c89:	90                   	nop

f0104c8a <H_GPFLT>:
TRAPHANDLER     (H_GPFLT  , T_GPFLT)
f0104c8a:	6a 0d                	push   $0xd
f0104c8c:	e9 83 00 00 00       	jmp    f0104d14 <_alltraps>
f0104c91:	90                   	nop

f0104c92 <H_PGFLT>:
TRAPHANDLER     (H_PGFLT  , T_PGFLT)
f0104c92:	6a 0e                	push   $0xe
f0104c94:	eb 7e                	jmp    f0104d14 <_alltraps>

f0104c96 <H_FPERR>:
TRAPHANDLER_NOEC(H_FPERR  , T_FPERR)
f0104c96:	6a 00                	push   $0x0
f0104c98:	6a 10                	push   $0x10
f0104c9a:	eb 78                	jmp    f0104d14 <_alltraps>

f0104c9c <H_ALIGN>:
TRAPHANDLER_NOEC(H_ALIGN  , T_ALIGN)
f0104c9c:	6a 00                	push   $0x0
f0104c9e:	6a 11                	push   $0x11
f0104ca0:	eb 72                	jmp    f0104d14 <_alltraps>

f0104ca2 <H_MCHK>:
TRAPHANDLER_NOEC(H_MCHK   , T_MCHK)
f0104ca2:	6a 00                	push   $0x0
f0104ca4:	6a 12                	push   $0x12
f0104ca6:	eb 6c                	jmp    f0104d14 <_alltraps>

f0104ca8 <H_SIMDERR>:
TRAPHANDLER_NOEC(H_SIMDERR, T_SIMDERR)
f0104ca8:	6a 00                	push   $0x0
f0104caa:	6a 13                	push   $0x13
f0104cac:	eb 66                	jmp    f0104d14 <_alltraps>

f0104cae <H_SYSCALL>:

TRAPHANDLER_NOEC(H_SYSCALL, T_SYSCALL)  // System call.
f0104cae:	6a 00                	push   $0x0
f0104cb0:	6a 30                	push   $0x30
f0104cb2:	eb 60                	jmp    f0104d14 <_alltraps>

f0104cb4 <H_TIMER>:

// IRQ 0 - 15
TRAPHANDLER_NOEC(H_TIMER,  IRQ_OFFSET + IRQ_TIMER)
f0104cb4:	6a 00                	push   $0x0
f0104cb6:	6a 20                	push   $0x20
f0104cb8:	eb 5a                	jmp    f0104d14 <_alltraps>

f0104cba <H_KBD>:
TRAPHANDLER_NOEC(H_KBD,    IRQ_OFFSET + IRQ_KBD)
f0104cba:	6a 00                	push   $0x0
f0104cbc:	6a 21                	push   $0x21
f0104cbe:	eb 54                	jmp    f0104d14 <_alltraps>

f0104cc0 <H_IRQ2>:
TRAPHANDLER_NOEC(H_IRQ2,   IRQ_OFFSET + 2)
f0104cc0:	6a 00                	push   $0x0
f0104cc2:	6a 22                	push   $0x22
f0104cc4:	eb 4e                	jmp    f0104d14 <_alltraps>

f0104cc6 <H_IRQ3>:
TRAPHANDLER_NOEC(H_IRQ3,   IRQ_OFFSET + 3)
f0104cc6:	6a 00                	push   $0x0
f0104cc8:	6a 23                	push   $0x23
f0104cca:	eb 48                	jmp    f0104d14 <_alltraps>

f0104ccc <H_SERIAL>:
TRAPHANDLER_NOEC(H_SERIAL, IRQ_OFFSET + IRQ_SERIAL)
f0104ccc:	6a 00                	push   $0x0
f0104cce:	6a 24                	push   $0x24
f0104cd0:	eb 42                	jmp    f0104d14 <_alltraps>

f0104cd2 <H_IRQ5>:
TRAPHANDLER_NOEC(H_IRQ5,   IRQ_OFFSET + 5)
f0104cd2:	6a 00                	push   $0x0
f0104cd4:	6a 25                	push   $0x25
f0104cd6:	eb 3c                	jmp    f0104d14 <_alltraps>

f0104cd8 <H_IRQ6>:
TRAPHANDLER_NOEC(H_IRQ6,   IRQ_OFFSET + 6)
f0104cd8:	6a 00                	push   $0x0
f0104cda:	6a 26                	push   $0x26
f0104cdc:	eb 36                	jmp    f0104d14 <_alltraps>

f0104cde <H_SPUR>:
TRAPHANDLER_NOEC(H_SPUR,   IRQ_OFFSET + IRQ_SPURIOUS)
f0104cde:	6a 00                	push   $0x0
f0104ce0:	6a 27                	push   $0x27
f0104ce2:	eb 30                	jmp    f0104d14 <_alltraps>

f0104ce4 <H_IRQ8>:
TRAPHANDLER_NOEC(H_IRQ8,   IRQ_OFFSET + 8)
f0104ce4:	6a 00                	push   $0x0
f0104ce6:	6a 28                	push   $0x28
f0104ce8:	eb 2a                	jmp    f0104d14 <_alltraps>

f0104cea <H_IRQ9>:
TRAPHANDLER_NOEC(H_IRQ9,   IRQ_OFFSET + 9)
f0104cea:	6a 00                	push   $0x0
f0104cec:	6a 29                	push   $0x29
f0104cee:	eb 24                	jmp    f0104d14 <_alltraps>

f0104cf0 <H_IRQ10>:
TRAPHANDLER_NOEC(H_IRQ10,  IRQ_OFFSET + 10)
f0104cf0:	6a 00                	push   $0x0
f0104cf2:	6a 2a                	push   $0x2a
f0104cf4:	eb 1e                	jmp    f0104d14 <_alltraps>

f0104cf6 <H_IRQ11>:
TRAPHANDLER_NOEC(H_IRQ11,  IRQ_OFFSET + 11)
f0104cf6:	6a 00                	push   $0x0
f0104cf8:	6a 2b                	push   $0x2b
f0104cfa:	eb 18                	jmp    f0104d14 <_alltraps>

f0104cfc <H_IRQ12>:
TRAPHANDLER_NOEC(H_IRQ12,  IRQ_OFFSET + 12)
f0104cfc:	6a 00                	push   $0x0
f0104cfe:	6a 2c                	push   $0x2c
f0104d00:	eb 12                	jmp    f0104d14 <_alltraps>

f0104d02 <H_IRQ13>:
TRAPHANDLER_NOEC(H_IRQ13,  IRQ_OFFSET + 13)
f0104d02:	6a 00                	push   $0x0
f0104d04:	6a 2d                	push   $0x2d
f0104d06:	eb 0c                	jmp    f0104d14 <_alltraps>

f0104d08 <H_IDE>:
TRAPHANDLER_NOEC(H_IDE,    IRQ_OFFSET + IRQ_IDE)
f0104d08:	6a 00                	push   $0x0
f0104d0a:	6a 2e                	push   $0x2e
f0104d0c:	eb 06                	jmp    f0104d14 <_alltraps>

f0104d0e <H_IRQ15>:
TRAPHANDLER_NOEC(H_IRQ15,  IRQ_OFFSET + 15)
f0104d0e:	6a 00                	push   $0x0
f0104d10:	6a 2f                	push   $0x2f
f0104d12:	eb 00                	jmp    f0104d14 <_alltraps>

f0104d14 <_alltraps>:

_alltraps:
/* Processor has pushed ss, esp, eflags, cs, eip, and [error] */
/* TRAPHANDLER did [error] and trapno */
	pushl  %ds;
f0104d14:	1e                   	push   %ds
	pushl  %es;
f0104d15:	06                   	push   %es
	pushal;
f0104d16:	60                   	pusha  
	movw   $GD_KD, %ax;
f0104d17:	66 b8 10 00          	mov    $0x10,%ax
	movw   %ax   , %ds;
f0104d1b:	8e d8                	mov    %eax,%ds
	movw   %ax   , %es;
f0104d1d:	8e c0                	mov    %eax,%es
	pushl  %esp;
f0104d1f:	54                   	push   %esp
	call   trap
f0104d20:	e8 ba fc ff ff       	call   f01049df <trap>

f0104d25 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104d25:	55                   	push   %ebp
f0104d26:	89 e5                	mov    %esp,%ebp
f0104d28:	83 ec 08             	sub    $0x8,%esp
f0104d2b:	a1 48 52 2a f0       	mov    0xf02a5248,%eax
f0104d30:	83 c0 54             	add    $0x54,%eax
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104d33:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104d38:	8b 10                	mov    (%eax),%edx
f0104d3a:	4a                   	dec    %edx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104d3b:	83 fa 02             	cmp    $0x2,%edx
f0104d3e:	76 2b                	jbe    f0104d6b <sched_halt+0x46>
	for (i = 0; i < NENV; i++) {
f0104d40:	41                   	inc    %ecx
f0104d41:	83 c0 7c             	add    $0x7c,%eax
f0104d44:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104d4a:	75 ec                	jne    f0104d38 <sched_halt+0x13>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f0104d4c:	83 ec 0c             	sub    $0xc,%esp
f0104d4f:	68 70 87 10 f0       	push   $0xf0108770
f0104d54:	e8 40 f2 ff ff       	call   f0103f99 <cprintf>
f0104d59:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104d5c:	83 ec 0c             	sub    $0xc,%esp
f0104d5f:	6a 00                	push   $0x0
f0104d61:	e8 ed c0 ff ff       	call   f0100e53 <monitor>
f0104d66:	83 c4 10             	add    $0x10,%esp
f0104d69:	eb f1                	jmp    f0104d5c <sched_halt+0x37>
	if (i == NENV) {
f0104d6b:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104d71:	74 d9                	je     f0104d4c <sched_halt+0x27>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104d73:	e8 aa 19 00 00       	call   f0106722 <cpunum>
f0104d78:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104d7b:	01 c2                	add    %eax,%edx
f0104d7d:	01 d2                	add    %edx,%edx
f0104d7f:	01 c2                	add    %eax,%edx
f0104d81:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104d84:	c7 04 85 28 60 2a f0 	movl   $0x0,-0xfd59fd8(,%eax,4)
f0104d8b:	00 00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104d8f:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0104d94:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104d99:	76 67                	jbe    f0104e02 <sched_halt+0xdd>
	return (physaddr_t)kva - KERNBASE;
f0104d9b:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104da0:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104da3:	e8 7a 19 00 00       	call   f0106722 <cpunum>
f0104da8:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104dab:	01 c2                	add    %eax,%edx
f0104dad:	01 d2                	add    %edx,%edx
f0104daf:	01 c2                	add    %eax,%edx
f0104db1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104db4:	8d 14 85 04 00 00 00 	lea    0x4(,%eax,4),%edx
	asm volatile("lock; xchgl %0, %1"
f0104dbb:	b8 02 00 00 00       	mov    $0x2,%eax
f0104dc0:	f0 87 82 20 60 2a f0 	lock xchg %eax,-0xfd59fe0(%edx)
	spin_unlock(&kernel_lock);
f0104dc7:	83 ec 0c             	sub    $0xc,%esp
f0104dca:	68 c0 33 12 f0       	push   $0xf01233c0
f0104dcf:	e8 6f 1c 00 00       	call   f0106a43 <spin_unlock>
	asm volatile("pause");
f0104dd4:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104dd6:	e8 47 19 00 00       	call   f0106722 <cpunum>
f0104ddb:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104dde:	01 c2                	add    %eax,%edx
f0104de0:	01 d2                	add    %edx,%edx
f0104de2:	01 c2                	add    %eax,%edx
f0104de4:	8d 04 90             	lea    (%eax,%edx,4),%eax
	asm volatile (
f0104de7:	8b 04 85 30 60 2a f0 	mov    -0xfd59fd0(,%eax,4),%eax
f0104dee:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104df3:	89 c4                	mov    %eax,%esp
f0104df5:	6a 00                	push   $0x0
f0104df7:	6a 00                	push   $0x0
f0104df9:	fb                   	sti    
f0104dfa:	f4                   	hlt    
f0104dfb:	eb fd                	jmp    f0104dfa <sched_halt+0xd5>
}
f0104dfd:	83 c4 10             	add    $0x10,%esp
f0104e00:	c9                   	leave  
f0104e01:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104e02:	50                   	push   %eax
f0104e03:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0104e08:	6a 53                	push   $0x53
f0104e0a:	68 99 87 10 f0       	push   $0xf0108799
f0104e0f:	e8 80 b2 ff ff       	call   f0100094 <_panic>

f0104e14 <sched_yield>:
{
f0104e14:	55                   	push   %ebp
f0104e15:	89 e5                	mov    %esp,%ebp
f0104e17:	53                   	push   %ebx
f0104e18:	83 ec 04             	sub    $0x4,%esp
	if (!curenv) { 
f0104e1b:	e8 02 19 00 00       	call   f0106722 <cpunum>
f0104e20:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104e23:	01 c2                	add    %eax,%edx
f0104e25:	01 d2                	add    %edx,%edx
f0104e27:	01 c2                	add    %eax,%edx
f0104e29:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e2c:	83 3c 85 28 60 2a f0 	cmpl   $0x0,-0xfd59fd8(,%eax,4)
f0104e33:	00 
f0104e34:	74 29                	je     f0104e5f <sched_yield+0x4b>
		for (idle = curenv + 1; idle < envs + NENV; idle++)
f0104e36:	e8 e7 18 00 00       	call   f0106722 <cpunum>
f0104e3b:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104e3e:	01 c2                	add    %eax,%edx
f0104e40:	01 d2                	add    %edx,%edx
f0104e42:	01 c2                	add    %eax,%edx
f0104e44:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e47:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f0104e4e:	83 c0 7c             	add    $0x7c,%eax
f0104e51:	8b 1d 48 52 2a f0    	mov    0xf02a5248,%ebx
f0104e57:	8d 93 00 f0 01 00    	lea    0x1f000(%ebx),%edx
f0104e5d:	eb 26                	jmp    f0104e85 <sched_yield+0x71>
		for (idle = envs; idle < envs + NENV; idle++)
f0104e5f:	a1 48 52 2a f0       	mov    0xf02a5248,%eax
f0104e64:	8d 90 00 f0 01 00    	lea    0x1f000(%eax),%edx
f0104e6a:	39 d0                	cmp    %edx,%eax
f0104e6c:	74 76                	je     f0104ee4 <sched_yield+0xd0>
			if (idle->env_status == ENV_RUNNABLE)
f0104e6e:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104e72:	74 05                	je     f0104e79 <sched_yield+0x65>
		for (idle = envs; idle < envs + NENV; idle++)
f0104e74:	83 c0 7c             	add    $0x7c,%eax
f0104e77:	eb f1                	jmp    f0104e6a <sched_yield+0x56>
				env_run(idle); // Will not return
f0104e79:	83 ec 0c             	sub    $0xc,%esp
f0104e7c:	50                   	push   %eax
f0104e7d:	e8 8c ee ff ff       	call   f0103d0e <env_run>
		for (idle = curenv + 1; idle < envs + NENV; idle++)
f0104e82:	83 c0 7c             	add    $0x7c,%eax
f0104e85:	39 c2                	cmp    %eax,%edx
f0104e87:	76 18                	jbe    f0104ea1 <sched_yield+0x8d>
			if (idle->env_status == ENV_RUNNABLE)
f0104e89:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104e8d:	75 f3                	jne    f0104e82 <sched_yield+0x6e>
				env_run(idle); 
f0104e8f:	83 ec 0c             	sub    $0xc,%esp
f0104e92:	50                   	push   %eax
f0104e93:	e8 76 ee ff ff       	call   f0103d0e <env_run>
				env_run(idle);
f0104e98:	83 ec 0c             	sub    $0xc,%esp
f0104e9b:	53                   	push   %ebx
f0104e9c:	e8 6d ee ff ff       	call   f0103d0e <env_run>
		for (idle = envs; idle < curenv ; idle++)
f0104ea1:	e8 7c 18 00 00       	call   f0106722 <cpunum>
f0104ea6:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104ea9:	01 c2                	add    %eax,%edx
f0104eab:	01 d2                	add    %edx,%edx
f0104ead:	01 c2                	add    %eax,%edx
f0104eaf:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104eb2:	39 1c 85 28 60 2a f0 	cmp    %ebx,-0xfd59fd8(,%eax,4)
f0104eb9:	76 0b                	jbe    f0104ec6 <sched_yield+0xb2>
			if (idle->env_status == ENV_RUNNABLE)
f0104ebb:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f0104ebf:	74 d7                	je     f0104e98 <sched_yield+0x84>
		for (idle = envs; idle < curenv ; idle++)
f0104ec1:	83 c3 7c             	add    $0x7c,%ebx
f0104ec4:	eb db                	jmp    f0104ea1 <sched_yield+0x8d>
		if (curenv->env_status == ENV_RUNNING)
f0104ec6:	e8 57 18 00 00       	call   f0106722 <cpunum>
f0104ecb:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104ece:	01 c2                	add    %eax,%edx
f0104ed0:	01 d2                	add    %edx,%edx
f0104ed2:	01 c2                	add    %eax,%edx
f0104ed4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ed7:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f0104ede:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104ee2:	74 0a                	je     f0104eee <sched_yield+0xda>
	sched_halt();
f0104ee4:	e8 3c fe ff ff       	call   f0104d25 <sched_halt>
}
f0104ee9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104eec:	c9                   	leave  
f0104eed:	c3                   	ret    
			env_run(curenv);
f0104eee:	e8 2f 18 00 00       	call   f0106722 <cpunum>
f0104ef3:	83 ec 0c             	sub    $0xc,%esp
f0104ef6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ef9:	ff b0 28 60 2a f0    	pushl  -0xfd59fd8(%eax)
f0104eff:	e8 0a ee ff ff       	call   f0103d0e <env_run>

f0104f04 <sys_ipc_recv>:
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
int
sys_ipc_recv(void *dstva)
{
f0104f04:	55                   	push   %ebp
f0104f05:	89 e5                	mov    %esp,%ebp
f0104f07:	53                   	push   %ebx
f0104f08:	83 ec 04             	sub    $0x4,%esp
f0104f0b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// Willing to receive information.
	curenv->env_ipc_recving = true; 
f0104f0e:	e8 0f 18 00 00       	call   f0106722 <cpunum>
f0104f13:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104f16:	01 c2                	add    %eax,%edx
f0104f18:	01 d2                	add    %edx,%edx
f0104f1a:	01 c2                	add    %eax,%edx
f0104f1c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104f1f:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f0104f26:	c6 40 68 01          	movb   $0x1,0x68(%eax)

	// If willing to receive page but not aligned
	if ((uintptr_t)dstva < UTOP && (uintptr_t)dstva % PGSIZE) 
f0104f2a:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0104f30:	77 08                	ja     f0104f3a <sys_ipc_recv+0x36>
f0104f32:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f0104f38:	75 45                	jne    f0104f7f <sys_ipc_recv+0x7b>
		return -E_INVAL;
	// No matter we want to get page or not, 
	// this statement is ok.
	curenv->env_ipc_dstva = dstva; 
f0104f3a:	e8 e3 17 00 00       	call   f0106722 <cpunum>
f0104f3f:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104f42:	01 c2                	add    %eax,%edx
f0104f44:	01 d2                	add    %edx,%edx
f0104f46:	01 c2                	add    %eax,%edx
f0104f48:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104f4b:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f0104f52:	89 58 6c             	mov    %ebx,0x6c(%eax)

	// Mark not-runnable. Don't run until we receive something.
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104f55:	e8 c8 17 00 00       	call   f0106722 <cpunum>
f0104f5a:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104f5d:	01 c2                	add    %eax,%edx
f0104f5f:	01 d2                	add    %edx,%edx
f0104f61:	01 c2                	add    %eax,%edx
f0104f63:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104f66:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f0104f6d:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	// There used to be a yield here, which is wrong.
	// When the env is continued, it will (surely) not be running 
	// from here, since this is kernel code. 
	// sched_yield();

	return 0;
f0104f74:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104f79:	83 c4 04             	add    $0x4,%esp
f0104f7c:	5b                   	pop    %ebx
f0104f7d:	5d                   	pop    %ebp
f0104f7e:	c3                   	ret    
		return -E_INVAL;
f0104f7f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f84:	eb f3                	jmp    f0104f79 <sys_ipc_recv+0x75>

f0104f86 <syscall>:

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104f86:	55                   	push   %ebp
f0104f87:	89 e5                	mov    %esp,%ebp
f0104f89:	56                   	push   %esi
f0104f8a:	53                   	push   %ebx
f0104f8b:	83 ec 10             	sub    $0x10,%esp
f0104f8e:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	switch (syscallno) {
f0104f91:	83 f8 0d             	cmp    $0xd,%eax
f0104f94:	0f 87 11 05 00 00    	ja     f01054ab <syscall+0x525>
f0104f9a:	ff 24 85 e0 87 10 f0 	jmp    *-0xfef7820(,%eax,4)
	user_mem_assert(curenv, s, len, PTE_U);  // The memory is readable.
f0104fa1:	e8 7c 17 00 00       	call   f0106722 <cpunum>
f0104fa6:	6a 04                	push   $0x4
f0104fa8:	ff 75 10             	pushl  0x10(%ebp)
f0104fab:	ff 75 0c             	pushl  0xc(%ebp)
f0104fae:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104fb1:	01 c2                	add    %eax,%edx
f0104fb3:	01 d2                	add    %edx,%edx
f0104fb5:	01 c2                	add    %eax,%edx
f0104fb7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104fba:	ff 34 85 28 60 2a f0 	pushl  -0xfd59fd8(,%eax,4)
f0104fc1:	e8 50 e5 ff ff       	call   f0103516 <user_mem_assert>
	cprintf("%.*s", len, s);
f0104fc6:	83 c4 0c             	add    $0xc,%esp
f0104fc9:	ff 75 0c             	pushl  0xc(%ebp)
f0104fcc:	ff 75 10             	pushl  0x10(%ebp)
f0104fcf:	68 a6 87 10 f0       	push   $0xf01087a6
f0104fd4:	e8 c0 ef ff ff       	call   f0103f99 <cprintf>
f0104fd9:	83 c4 10             	add    $0x10,%esp
	case SYS_cputs:
		sys_cputs((const char*)a1, a2);
		return 0;
f0104fdc:	bb 00 00 00 00       	mov    $0x0,%ebx
	case SYS_ipc_recv:
		return sys_ipc_recv((void*)a1);
	default:
		return -E_INVAL;
	}
}
f0104fe1:	89 d8                	mov    %ebx,%eax
f0104fe3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104fe6:	5b                   	pop    %ebx
f0104fe7:	5e                   	pop    %esi
f0104fe8:	5d                   	pop    %ebp
f0104fe9:	c3                   	ret    
	return cons_getc();
f0104fea:	e8 d4 b6 ff ff       	call   f01006c3 <cons_getc>
f0104fef:	89 c3                	mov    %eax,%ebx
		return sys_cgetc();
f0104ff1:	eb ee                	jmp    f0104fe1 <syscall+0x5b>
	return curenv->env_id;
f0104ff3:	e8 2a 17 00 00       	call   f0106722 <cpunum>
f0104ff8:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104ffb:	01 c2                	add    %eax,%edx
f0104ffd:	01 d2                	add    %edx,%edx
f0104fff:	01 c2                	add    %eax,%edx
f0105001:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105004:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f010500b:	8b 58 48             	mov    0x48(%eax),%ebx
		return sys_getenvid();
f010500e:	eb d1                	jmp    f0104fe1 <syscall+0x5b>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0105010:	83 ec 04             	sub    $0x4,%esp
f0105013:	6a 01                	push   $0x1
f0105015:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105018:	50                   	push   %eax
f0105019:	ff 75 0c             	pushl  0xc(%ebp)
f010501c:	e8 41 e5 ff ff       	call   f0103562 <envid2env>
f0105021:	89 c3                	mov    %eax,%ebx
f0105023:	83 c4 10             	add    $0x10,%esp
f0105026:	85 c0                	test   %eax,%eax
f0105028:	78 b7                	js     f0104fe1 <syscall+0x5b>
	if (e == curenv)
f010502a:	e8 f3 16 00 00       	call   f0106722 <cpunum>
f010502f:	8b 4d f4             	mov    -0xc(%ebp),%ecx
f0105032:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0105035:	01 c2                	add    %eax,%edx
f0105037:	01 d2                	add    %edx,%edx
f0105039:	01 c2                	add    %eax,%edx
f010503b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010503e:	39 0c 85 28 60 2a f0 	cmp    %ecx,-0xfd59fd8(,%eax,4)
f0105045:	74 47                	je     f010508e <syscall+0x108>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0105047:	8b 59 48             	mov    0x48(%ecx),%ebx
f010504a:	e8 d3 16 00 00       	call   f0106722 <cpunum>
f010504f:	83 ec 04             	sub    $0x4,%esp
f0105052:	53                   	push   %ebx
f0105053:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0105056:	01 c2                	add    %eax,%edx
f0105058:	01 d2                	add    %edx,%edx
f010505a:	01 c2                	add    %eax,%edx
f010505c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010505f:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f0105066:	ff 70 48             	pushl  0x48(%eax)
f0105069:	68 c6 87 10 f0       	push   $0xf01087c6
f010506e:	e8 26 ef ff ff       	call   f0103f99 <cprintf>
f0105073:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0105076:	83 ec 0c             	sub    $0xc,%esp
f0105079:	ff 75 f4             	pushl  -0xc(%ebp)
f010507c:	e8 d0 eb ff ff       	call   f0103c51 <env_destroy>
f0105081:	83 c4 10             	add    $0x10,%esp
	return 0;
f0105084:	bb 00 00 00 00       	mov    $0x0,%ebx
		return sys_env_destroy(a1);
f0105089:	e9 53 ff ff ff       	jmp    f0104fe1 <syscall+0x5b>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010508e:	e8 8f 16 00 00       	call   f0106722 <cpunum>
f0105093:	83 ec 08             	sub    $0x8,%esp
f0105096:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0105099:	01 c2                	add    %eax,%edx
f010509b:	01 d2                	add    %edx,%edx
f010509d:	01 c2                	add    %eax,%edx
f010509f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01050a2:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f01050a9:	ff 70 48             	pushl  0x48(%eax)
f01050ac:	68 ab 87 10 f0       	push   $0xf01087ab
f01050b1:	e8 e3 ee ff ff       	call   f0103f99 <cprintf>
f01050b6:	83 c4 10             	add    $0x10,%esp
f01050b9:	eb bb                	jmp    f0105076 <syscall+0xf0>
	int r = envid2env(envid, &to_env, 1);  // 1 - Check perm
f01050bb:	83 ec 04             	sub    $0x4,%esp
f01050be:	6a 01                	push   $0x1
f01050c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01050c3:	50                   	push   %eax
f01050c4:	ff 75 0c             	pushl  0xc(%ebp)
f01050c7:	e8 96 e4 ff ff       	call   f0103562 <envid2env>
f01050cc:	89 c3                	mov    %eax,%ebx
	if (r)  // -E_BAD_ENV
f01050ce:	83 c4 10             	add    $0x10,%esp
f01050d1:	85 c0                	test   %eax,%eax
f01050d3:	0f 85 08 ff ff ff    	jne    f0104fe1 <syscall+0x5b>
	if ((uintptr_t)va >= UTOP || (uintptr_t)va % PGSIZE)
f01050d9:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01050e0:	77 59                	ja     f010513b <syscall+0x1b5>
f01050e2:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01050e9:	75 5a                	jne    f0105145 <syscall+0x1bf>
	if (~PTE_SYSCALL & perm) 
f01050eb:	f7 45 14 f8 f1 ff ff 	testl  $0xfffff1f8,0x14(%ebp)
f01050f2:	75 5b                	jne    f010514f <syscall+0x1c9>
	perm |= PTE_U | PTE_P;
f01050f4:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01050f7:	83 cb 05             	or     $0x5,%ebx
	struct PageInfo* pp = page_alloc(1);
f01050fa:	83 ec 0c             	sub    $0xc,%esp
f01050fd:	6a 01                	push   $0x1
f01050ff:	e8 18 c3 ff ff       	call   f010141c <page_alloc>
f0105104:	89 c6                	mov    %eax,%esi
	if (!pp)  // No free memory
f0105106:	83 c4 10             	add    $0x10,%esp
f0105109:	85 c0                	test   %eax,%eax
f010510b:	74 4c                	je     f0105159 <syscall+0x1d3>
	r = page_insert(to_env->env_pgdir, pp, va, perm);
f010510d:	53                   	push   %ebx
f010510e:	ff 75 10             	pushl  0x10(%ebp)
f0105111:	50                   	push   %eax
f0105112:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105115:	ff 70 60             	pushl  0x60(%eax)
f0105118:	e8 58 c6 ff ff       	call   f0101775 <page_insert>
f010511d:	89 c3                	mov    %eax,%ebx
	if (r) 
f010511f:	83 c4 10             	add    $0x10,%esp
f0105122:	85 c0                	test   %eax,%eax
f0105124:	0f 84 b7 fe ff ff    	je     f0104fe1 <syscall+0x5b>
		page_free(pp);
f010512a:	83 ec 0c             	sub    $0xc,%esp
f010512d:	56                   	push   %esi
f010512e:	e8 5b c3 ff ff       	call   f010148e <page_free>
f0105133:	83 c4 10             	add    $0x10,%esp
f0105136:	e9 a6 fe ff ff       	jmp    f0104fe1 <syscall+0x5b>
		return -E_INVAL;
f010513b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105140:	e9 9c fe ff ff       	jmp    f0104fe1 <syscall+0x5b>
f0105145:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010514a:	e9 92 fe ff ff       	jmp    f0104fe1 <syscall+0x5b>
		return -E_INVAL;
f010514f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105154:	e9 88 fe ff ff       	jmp    f0104fe1 <syscall+0x5b>
		return -E_NO_MEM;
f0105159:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
		return sys_page_alloc(a1, (void*)a2, a3);
f010515e:	e9 7e fe ff ff       	jmp    f0104fe1 <syscall+0x5b>
	r = envid2env(srcenvid, &from_env, 1);  // 1 - Check perm
f0105163:	83 ec 04             	sub    $0x4,%esp
f0105166:	6a 01                	push   $0x1
f0105168:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010516b:	50                   	push   %eax
f010516c:	ff 75 0c             	pushl  0xc(%ebp)
f010516f:	e8 ee e3 ff ff       	call   f0103562 <envid2env>
f0105174:	89 c3                	mov    %eax,%ebx
	if (r)  return r;
f0105176:	83 c4 10             	add    $0x10,%esp
f0105179:	85 c0                	test   %eax,%eax
f010517b:	0f 85 60 fe ff ff    	jne    f0104fe1 <syscall+0x5b>
	r = envid2env(dstenvid, &to_env, 1);  // 1 - Check perm
f0105181:	83 ec 04             	sub    $0x4,%esp
f0105184:	6a 01                	push   $0x1
f0105186:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0105189:	50                   	push   %eax
f010518a:	ff 75 14             	pushl  0x14(%ebp)
f010518d:	e8 d0 e3 ff ff       	call   f0103562 <envid2env>
f0105192:	89 c3                	mov    %eax,%ebx
	if (r)  return r;
f0105194:	83 c4 10             	add    $0x10,%esp
f0105197:	85 c0                	test   %eax,%eax
f0105199:	0f 85 42 fe ff ff    	jne    f0104fe1 <syscall+0x5b>
	if (
f010519f:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01051a6:	77 6a                	ja     f0105212 <syscall+0x28c>
		((uintptr_t)srcva >= UTOP || (uintptr_t)srcva % PGSIZE) || 
f01051a8:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01051af:	75 6b                	jne    f010521c <syscall+0x296>
f01051b1:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01051b8:	77 6c                	ja     f0105226 <syscall+0x2a0>
		((uintptr_t)dstva >= UTOP || (uintptr_t)dstva % PGSIZE))
f01051ba:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f01051c1:	75 6d                	jne    f0105230 <syscall+0x2aa>
	if (~PTE_SYSCALL & perm)
f01051c3:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f01051ca:	75 6e                	jne    f010523a <syscall+0x2b4>
	perm |= PTE_U | PTE_P;
f01051cc:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
f01051cf:	83 cb 05             	or     $0x5,%ebx
	struct PageInfo* pp = page_lookup(from_env->env_pgdir, srcva, &src_pgt);
f01051d2:	83 ec 04             	sub    $0x4,%esp
f01051d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01051d8:	50                   	push   %eax
f01051d9:	ff 75 10             	pushl  0x10(%ebp)
f01051dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01051df:	ff 70 60             	pushl  0x60(%eax)
f01051e2:	e8 85 c4 ff ff       	call   f010166c <page_lookup>
	if ((~*src_pgt & PTE_W) && (perm & PTE_W))
f01051e7:	83 c4 10             	add    $0x10,%esp
f01051ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01051ed:	f6 02 02             	testb  $0x2,(%edx)
f01051f0:	75 06                	jne    f01051f8 <syscall+0x272>
f01051f2:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01051f6:	75 4c                	jne    f0105244 <syscall+0x2be>
	r = page_insert(to_env->env_pgdir, pp, dstva, perm);
f01051f8:	53                   	push   %ebx
f01051f9:	ff 75 18             	pushl  0x18(%ebp)
f01051fc:	50                   	push   %eax
f01051fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105200:	ff 70 60             	pushl  0x60(%eax)
f0105203:	e8 6d c5 ff ff       	call   f0101775 <page_insert>
f0105208:	89 c3                	mov    %eax,%ebx
f010520a:	83 c4 10             	add    $0x10,%esp
f010520d:	e9 cf fd ff ff       	jmp    f0104fe1 <syscall+0x5b>
		return -E_INVAL;
f0105212:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105217:	e9 c5 fd ff ff       	jmp    f0104fe1 <syscall+0x5b>
f010521c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105221:	e9 bb fd ff ff       	jmp    f0104fe1 <syscall+0x5b>
f0105226:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010522b:	e9 b1 fd ff ff       	jmp    f0104fe1 <syscall+0x5b>
f0105230:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105235:	e9 a7 fd ff ff       	jmp    f0104fe1 <syscall+0x5b>
		return -E_INVAL;
f010523a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010523f:	e9 9d fd ff ff       	jmp    f0104fe1 <syscall+0x5b>
		return -E_INVAL;
f0105244:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
f0105249:	e9 93 fd ff ff       	jmp    f0104fe1 <syscall+0x5b>
	int r = envid2env(envid, &to_env, 1);  // 1 - Check perm
f010524e:	83 ec 04             	sub    $0x4,%esp
f0105251:	6a 01                	push   $0x1
f0105253:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105256:	50                   	push   %eax
f0105257:	ff 75 0c             	pushl  0xc(%ebp)
f010525a:	e8 03 e3 ff ff       	call   f0103562 <envid2env>
	if (r)  // -E_BAD_ENV
f010525f:	83 c4 10             	add    $0x10,%esp
f0105262:	85 c0                	test   %eax,%eax
f0105264:	75 26                	jne    f010528c <syscall+0x306>
	if ((uintptr_t)va >= UTOP || (uintptr_t)va % PGSIZE)
f0105266:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010526d:	77 1d                	ja     f010528c <syscall+0x306>
f010526f:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0105276:	75 14                	jne    f010528c <syscall+0x306>
	page_remove(to_env->env_pgdir, va);
f0105278:	83 ec 08             	sub    $0x8,%esp
f010527b:	ff 75 10             	pushl  0x10(%ebp)
f010527e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105281:	ff 70 60             	pushl  0x60(%eax)
f0105284:	e8 92 c4 ff ff       	call   f010171b <page_remove>
f0105289:	83 c4 10             	add    $0x10,%esp
		return 0;
f010528c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105291:	e9 4b fd ff ff       	jmp    f0104fe1 <syscall+0x5b>
	int r = env_alloc(&newenv, curenv->env_id);
f0105296:	e8 87 14 00 00       	call   f0106722 <cpunum>
f010529b:	83 ec 08             	sub    $0x8,%esp
f010529e:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01052a1:	01 c2                	add    %eax,%edx
f01052a3:	01 d2                	add    %edx,%edx
f01052a5:	01 c2                	add    %eax,%edx
f01052a7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01052aa:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f01052b1:	ff 70 48             	pushl  0x48(%eax)
f01052b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01052b7:	50                   	push   %eax
f01052b8:	e8 d3 e3 ff ff       	call   f0103690 <env_alloc>
f01052bd:	89 c3                	mov    %eax,%ebx
	if (r)  // Some error
f01052bf:	83 c4 10             	add    $0x10,%esp
f01052c2:	85 c0                	test   %eax,%eax
f01052c4:	0f 85 17 fd ff ff    	jne    f0104fe1 <syscall+0x5b>
	newenv->env_status = ENV_NOT_RUNNABLE;
f01052ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01052cd:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	memcpy(&newenv->env_tf, &curenv->env_tf, sizeof(struct Trapframe));
f01052d4:	e8 49 14 00 00       	call   f0106722 <cpunum>
f01052d9:	83 ec 04             	sub    $0x4,%esp
f01052dc:	6a 44                	push   $0x44
f01052de:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01052e1:	01 c2                	add    %eax,%edx
f01052e3:	01 d2                	add    %edx,%edx
f01052e5:	01 c2                	add    %eax,%edx
f01052e7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01052ea:	ff 34 85 28 60 2a f0 	pushl  -0xfd59fd8(,%eax,4)
f01052f1:	ff 75 f4             	pushl  -0xc(%ebp)
f01052f4:	e8 d4 0d 00 00       	call   f01060cd <memcpy>
	newenv->env_tf.tf_regs.reg_eax = 0;
f01052f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01052fc:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return newenv->env_id;
f0105303:	8b 58 48             	mov    0x48(%eax),%ebx
f0105306:	83 c4 10             	add    $0x10,%esp
		return sys_exofork();
f0105309:	e9 d3 fc ff ff       	jmp    f0104fe1 <syscall+0x5b>
	int r = envid2env(envid, &to_env, 1);  // 1 - Check perm
f010530e:	83 ec 04             	sub    $0x4,%esp
f0105311:	6a 01                	push   $0x1
f0105313:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105316:	50                   	push   %eax
f0105317:	ff 75 0c             	pushl  0xc(%ebp)
f010531a:	e8 43 e2 ff ff       	call   f0103562 <envid2env>
f010531f:	89 c3                	mov    %eax,%ebx
	if (r)  // -E_BAD_ENV
f0105321:	83 c4 10             	add    $0x10,%esp
f0105324:	85 c0                	test   %eax,%eax
f0105326:	0f 85 b5 fc ff ff    	jne    f0104fe1 <syscall+0x5b>
	if (status > ENV_NOT_RUNNABLE || status < 0) 
f010532c:	83 7d 10 04          	cmpl   $0x4,0x10(%ebp)
f0105330:	77 0e                	ja     f0105340 <syscall+0x3ba>
	to_env->env_status = status;
f0105332:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105335:	8b 75 10             	mov    0x10(%ebp),%esi
f0105338:	89 70 54             	mov    %esi,0x54(%eax)
f010533b:	e9 a1 fc ff ff       	jmp    f0104fe1 <syscall+0x5b>
		return -E_INVAL;
f0105340:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		return sys_env_set_status(a1, a2);
f0105345:	e9 97 fc ff ff       	jmp    f0104fe1 <syscall+0x5b>
	int r = envid2env(envid, &to_env, 1);  // 1 - Check perm
f010534a:	83 ec 04             	sub    $0x4,%esp
f010534d:	6a 01                	push   $0x1
f010534f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105352:	50                   	push   %eax
f0105353:	ff 75 0c             	pushl  0xc(%ebp)
f0105356:	e8 07 e2 ff ff       	call   f0103562 <envid2env>
f010535b:	89 c3                	mov    %eax,%ebx
	if (r)  // -E_BAD_ENV
f010535d:	83 c4 10             	add    $0x10,%esp
f0105360:	85 c0                	test   %eax,%eax
f0105362:	0f 85 79 fc ff ff    	jne    f0104fe1 <syscall+0x5b>
	to_env->env_pgfault_upcall = func;
f0105368:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010536b:	8b 75 10             	mov    0x10(%ebp),%esi
f010536e:	89 70 64             	mov    %esi,0x64(%eax)
		return sys_env_set_pgfault_upcall(a1, (void*)a2);
f0105371:	e9 6b fc ff ff       	jmp    f0104fe1 <syscall+0x5b>
	sched_yield();
f0105376:	e8 99 fa ff ff       	call   f0104e14 <sched_yield>
	r = envid2env(envid, &target_env, 0);  // 0 - don't check perm
f010537b:	83 ec 04             	sub    $0x4,%esp
f010537e:	6a 00                	push   $0x0
f0105380:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0105383:	50                   	push   %eax
f0105384:	ff 75 0c             	pushl  0xc(%ebp)
f0105387:	e8 d6 e1 ff ff       	call   f0103562 <envid2env>
f010538c:	89 c3                	mov    %eax,%ebx
	if (r)	return r;
f010538e:	83 c4 10             	add    $0x10,%esp
f0105391:	85 c0                	test   %eax,%eax
f0105393:	0f 85 48 fc ff ff    	jne    f0104fe1 <syscall+0x5b>
	if (!target_env->env_ipc_recving)  // target is not willing to receive
f0105399:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010539c:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f01053a0:	0f 84 e6 00 00 00    	je     f010548c <syscall+0x506>
	target_env->env_ipc_from = curenv->env_id; 
f01053a6:	e8 77 13 00 00       	call   f0106722 <cpunum>
f01053ab:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f01053ae:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01053b1:	01 c2                	add    %eax,%edx
f01053b3:	01 d2                	add    %edx,%edx
f01053b5:	01 c2                	add    %eax,%edx
f01053b7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01053ba:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f01053c1:	8b 40 48             	mov    0x48(%eax),%eax
f01053c4:	89 41 74             	mov    %eax,0x74(%ecx)
	target_env->env_ipc_recving = false;
f01053c7:	c6 41 68 00          	movb   $0x0,0x68(%ecx)
	if ((uintptr_t)srcva >= UTOP || // No page to map
f01053cb:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f01053d2:	77 09                	ja     f01053dd <syscall+0x457>
f01053d4:	81 79 6c ff ff bf ee 	cmpl   $0xeebfffff,0x6c(%ecx)
f01053db:	76 15                	jbe    f01053f2 <syscall+0x46c>
		target_env->env_ipc_value = value;
f01053dd:	8b 45 10             	mov    0x10(%ebp),%eax
f01053e0:	89 41 70             	mov    %eax,0x70(%ecx)
	target_env->env_status = ENV_RUNNABLE;
f01053e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01053e6:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f01053ed:	e9 ef fb ff ff       	jmp    f0104fe1 <syscall+0x5b>
		if ((uintptr_t)srcva % PGSIZE || 	// check addr aligned
f01053f2:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f01053f9:	75 76                	jne    f0105471 <syscall+0x4eb>
f01053fb:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f0105402:	74 0a                	je     f010540e <syscall+0x488>
			return -E_INVAL;
f0105404:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105409:	e9 d3 fb ff ff       	jmp    f0104fe1 <syscall+0x5b>
		struct PageInfo* pp = page_lookup(curenv->env_pgdir, srcva, &src_pgt);
f010540e:	e8 0f 13 00 00       	call   f0106722 <cpunum>
f0105413:	83 ec 04             	sub    $0x4,%esp
f0105416:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0105419:	52                   	push   %edx
f010541a:	ff 75 14             	pushl  0x14(%ebp)
f010541d:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0105420:	01 c2                	add    %eax,%edx
f0105422:	01 d2                	add    %edx,%edx
f0105424:	01 c2                	add    %eax,%edx
f0105426:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105429:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f0105430:	ff 70 60             	pushl  0x60(%eax)
f0105433:	e8 34 c2 ff ff       	call   f010166c <page_lookup>
		if ((~*src_pgt & PTE_W) && (perm & PTE_W))
f0105438:	83 c4 10             	add    $0x10,%esp
f010543b:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010543e:	f6 02 02             	testb  $0x2,(%edx)
f0105441:	75 06                	jne    f0105449 <syscall+0x4c3>
f0105443:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0105447:	75 32                	jne    f010547b <syscall+0x4f5>
		perm |= PTE_U | PTE_P;
f0105449:	8b 75 18             	mov    0x18(%ebp),%esi
f010544c:	83 ce 05             	or     $0x5,%esi
		r = page_insert(target_env->env_pgdir, pp, target_env->env_ipc_dstva, perm);
f010544f:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0105452:	56                   	push   %esi
f0105453:	ff 72 6c             	pushl  0x6c(%edx)
f0105456:	50                   	push   %eax
f0105457:	ff 72 60             	pushl  0x60(%edx)
f010545a:	e8 16 c3 ff ff       	call   f0101775 <page_insert>
		if (r)	return r;
f010545f:	83 c4 10             	add    $0x10,%esp
f0105462:	85 c0                	test   %eax,%eax
f0105464:	75 1f                	jne    f0105485 <syscall+0x4ff>
		target_env->env_ipc_perm = perm;  // tell the permission
f0105466:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105469:	89 70 78             	mov    %esi,0x78(%eax)
f010546c:	e9 72 ff ff ff       	jmp    f01053e3 <syscall+0x45d>
			return -E_INVAL;
f0105471:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105476:	e9 66 fb ff ff       	jmp    f0104fe1 <syscall+0x5b>
			return -E_INVAL;
f010547b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105480:	e9 5c fb ff ff       	jmp    f0104fe1 <syscall+0x5b>
		if (r)	return r;
f0105485:	89 c3                	mov    %eax,%ebx
f0105487:	e9 55 fb ff ff       	jmp    f0104fe1 <syscall+0x5b>
		return -E_IPC_NOT_RECV;
f010548c:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
		return sys_ipc_try_send(a1, a2, (void*)a3, a4);
f0105491:	e9 4b fb ff ff       	jmp    f0104fe1 <syscall+0x5b>
		return sys_ipc_recv((void*)a1);
f0105496:	83 ec 0c             	sub    $0xc,%esp
f0105499:	ff 75 0c             	pushl  0xc(%ebp)
f010549c:	e8 63 fa ff ff       	call   f0104f04 <sys_ipc_recv>
f01054a1:	89 c3                	mov    %eax,%ebx
f01054a3:	83 c4 10             	add    $0x10,%esp
f01054a6:	e9 36 fb ff ff       	jmp    f0104fe1 <syscall+0x5b>
		return -E_INVAL;
f01054ab:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01054b0:	e9 2c fb ff ff       	jmp    f0104fe1 <syscall+0x5b>

f01054b5 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01054b5:	55                   	push   %ebp
f01054b6:	89 e5                	mov    %esp,%ebp
f01054b8:	57                   	push   %edi
f01054b9:	56                   	push   %esi
f01054ba:	53                   	push   %ebx
f01054bb:	83 ec 14             	sub    $0x14,%esp
f01054be:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01054c1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01054c4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01054c7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01054ca:	8b 32                	mov    (%edx),%esi
f01054cc:	8b 01                	mov    (%ecx),%eax
f01054ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01054d1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01054d8:	eb 2f                	jmp    f0105509 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f01054da:	48                   	dec    %eax
		while (m >= l && stabs[m].n_type != type)
f01054db:	39 c6                	cmp    %eax,%esi
f01054dd:	7f 4d                	jg     f010552c <stab_binsearch+0x77>
f01054df:	0f b6 0a             	movzbl (%edx),%ecx
f01054e2:	83 ea 0c             	sub    $0xc,%edx
f01054e5:	39 f9                	cmp    %edi,%ecx
f01054e7:	75 f1                	jne    f01054da <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01054e9:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01054ec:	01 c2                	add    %eax,%edx
f01054ee:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01054f1:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01054f5:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01054f8:	73 37                	jae    f0105531 <stab_binsearch+0x7c>
			*region_left = m;
f01054fa:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01054fd:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f01054ff:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0105502:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0105509:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f010550c:	7f 4d                	jg     f010555b <stab_binsearch+0xa6>
		int true_m = (l + r) / 2, m = true_m;
f010550e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105511:	01 f0                	add    %esi,%eax
f0105513:	89 c3                	mov    %eax,%ebx
f0105515:	c1 eb 1f             	shr    $0x1f,%ebx
f0105518:	01 c3                	add    %eax,%ebx
f010551a:	d1 fb                	sar    %ebx
f010551c:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f010551f:	01 d8                	add    %ebx,%eax
f0105521:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105524:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0105528:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f010552a:	eb af                	jmp    f01054db <stab_binsearch+0x26>
			l = true_m + 1;
f010552c:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f010552f:	eb d8                	jmp    f0105509 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0105531:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105534:	76 12                	jbe    f0105548 <stab_binsearch+0x93>
			*region_right = m - 1;
f0105536:	48                   	dec    %eax
f0105537:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010553a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010553d:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f010553f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105546:	eb c1                	jmp    f0105509 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105548:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010554b:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f010554d:	ff 45 0c             	incl   0xc(%ebp)
f0105550:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0105552:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105559:	eb ae                	jmp    f0105509 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f010555b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010555f:	74 18                	je     f0105579 <stab_binsearch+0xc4>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105561:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105564:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105566:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105569:	8b 0e                	mov    (%esi),%ecx
f010556b:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010556e:	01 c2                	add    %eax,%edx
f0105570:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0105573:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0105577:	eb 0e                	jmp    f0105587 <stab_binsearch+0xd2>
		*region_right = *region_left - 1;
f0105579:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010557c:	8b 00                	mov    (%eax),%eax
f010557e:	48                   	dec    %eax
f010557f:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105582:	89 07                	mov    %eax,(%edi)
f0105584:	eb 14                	jmp    f010559a <stab_binsearch+0xe5>
		     l--)
f0105586:	48                   	dec    %eax
		for (l = *region_right;
f0105587:	39 c1                	cmp    %eax,%ecx
f0105589:	7d 0a                	jge    f0105595 <stab_binsearch+0xe0>
		     l > *region_left && stabs[l].n_type != type;
f010558b:	0f b6 1a             	movzbl (%edx),%ebx
f010558e:	83 ea 0c             	sub    $0xc,%edx
f0105591:	39 fb                	cmp    %edi,%ebx
f0105593:	75 f1                	jne    f0105586 <stab_binsearch+0xd1>
			/* do nothing */;
		*region_left = l;
f0105595:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105598:	89 07                	mov    %eax,(%edi)
	}
}
f010559a:	83 c4 14             	add    $0x14,%esp
f010559d:	5b                   	pop    %ebx
f010559e:	5e                   	pop    %esi
f010559f:	5f                   	pop    %edi
f01055a0:	5d                   	pop    %ebp
f01055a1:	c3                   	ret    

f01055a2 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01055a2:	55                   	push   %ebp
f01055a3:	89 e5                	mov    %esp,%ebp
f01055a5:	57                   	push   %edi
f01055a6:	56                   	push   %esi
f01055a7:	53                   	push   %ebx
f01055a8:	83 ec 4c             	sub    $0x4c,%esp
f01055ab:	8b 75 08             	mov    0x8(%ebp),%esi
f01055ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01055b1:	c7 03 18 88 10 f0    	movl   $0xf0108818,(%ebx)
	info->eip_line = 0;
f01055b7:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01055be:	c7 43 08 18 88 10 f0 	movl   $0xf0108818,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01055c5:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01055cc:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01055cf:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01055d6:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01055dc:	77 1e                	ja     f01055fc <debuginfo_eip+0x5a>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f01055de:	8b 3d 00 00 20 00    	mov    0x200000,%edi
		stab_end = usd->stab_end;
f01055e4:	8b 15 04 00 20 00    	mov    0x200004,%edx
		stabstr = usd->stabstr;
f01055ea:	a1 08 00 20 00       	mov    0x200008,%eax
f01055ef:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f01055f2:	a1 0c 00 20 00       	mov    0x20000c,%eax
f01055f7:	89 45 b8             	mov    %eax,-0x48(%ebp)
f01055fa:	eb 18                	jmp    f0105614 <debuginfo_eip+0x72>
		stabstr_end = __STABSTR_END__;
f01055fc:	c7 45 b8 5f 85 11 f0 	movl   $0xf011855f,-0x48(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0105603:	c7 45 b4 3d 4c 11 f0 	movl   $0xf0114c3d,-0x4c(%ebp)
		stab_end = __STAB_END__;
f010560a:	ba 3c 4c 11 f0       	mov    $0xf0114c3c,%edx
		stabs = __STAB_BEGIN__;
f010560f:	bf b0 8d 10 f0       	mov    $0xf0108db0,%edi
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105614:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0105617:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
f010561a:	0f 83 9b 01 00 00    	jae    f01057bb <debuginfo_eip+0x219>
f0105620:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0105624:	0f 85 98 01 00 00    	jne    f01057c2 <debuginfo_eip+0x220>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010562a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105631:	29 fa                	sub    %edi,%edx
f0105633:	c1 fa 02             	sar    $0x2,%edx
f0105636:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0105639:	8d 04 82             	lea    (%edx,%eax,4),%eax
f010563c:	8d 04 82             	lea    (%edx,%eax,4),%eax
f010563f:	89 c1                	mov    %eax,%ecx
f0105641:	c1 e1 08             	shl    $0x8,%ecx
f0105644:	01 c8                	add    %ecx,%eax
f0105646:	89 c1                	mov    %eax,%ecx
f0105648:	c1 e1 10             	shl    $0x10,%ecx
f010564b:	01 c8                	add    %ecx,%eax
f010564d:	01 c0                	add    %eax,%eax
f010564f:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
f0105653:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105656:	56                   	push   %esi
f0105657:	6a 64                	push   $0x64
f0105659:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010565c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010565f:	89 f8                	mov    %edi,%eax
f0105661:	e8 4f fe ff ff       	call   f01054b5 <stab_binsearch>
	if (lfile == 0)
f0105666:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105669:	83 c4 08             	add    $0x8,%esp
f010566c:	85 c0                	test   %eax,%eax
f010566e:	0f 84 55 01 00 00    	je     f01057c9 <debuginfo_eip+0x227>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105674:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105677:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010567a:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010567d:	56                   	push   %esi
f010567e:	6a 24                	push   $0x24
f0105680:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105683:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105686:	89 f8                	mov    %edi,%eax
f0105688:	e8 28 fe ff ff       	call   f01054b5 <stab_binsearch>

	if (lfun <= rfun) {
f010568d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105690:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0105693:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0105696:	83 c4 08             	add    $0x8,%esp
f0105699:	39 c8                	cmp    %ecx,%eax
f010569b:	0f 8f 80 00 00 00    	jg     f0105721 <debuginfo_eip+0x17f>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01056a1:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01056a4:	01 c2                	add    %eax,%edx
f01056a6:	8d 14 97             	lea    (%edi,%edx,4),%edx
f01056a9:	89 55 c0             	mov    %edx,-0x40(%ebp)
f01056ac:	8b 0a                	mov    (%edx),%ecx
f01056ae:	89 4d bc             	mov    %ecx,-0x44(%ebp)
f01056b1:	8b 55 b8             	mov    -0x48(%ebp),%edx
f01056b4:	2b 55 b4             	sub    -0x4c(%ebp),%edx
f01056b7:	39 d1                	cmp    %edx,%ecx
f01056b9:	73 06                	jae    f01056c1 <debuginfo_eip+0x11f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01056bb:	03 4d b4             	add    -0x4c(%ebp),%ecx
f01056be:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01056c1:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01056c4:	8b 51 08             	mov    0x8(%ecx),%edx
f01056c7:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01056ca:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01056cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01056cf:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01056d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01056d5:	83 ec 08             	sub    $0x8,%esp
f01056d8:	6a 3a                	push   $0x3a
f01056da:	ff 73 08             	pushl  0x8(%ebx)
f01056dd:	e8 1a 09 00 00       	call   f0105ffc <strfind>
f01056e2:	2b 43 08             	sub    0x8(%ebx),%eax
f01056e5:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// N_SLINE represents text segment
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01056e8:	83 c4 08             	add    $0x8,%esp
f01056eb:	56                   	push   %esi
f01056ec:	6a 44                	push   $0x44
f01056ee:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01056f1:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01056f4:	89 f8                	mov    %edi,%eax
f01056f6:	e8 ba fd ff ff       	call   f01054b5 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f01056fb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01056fe:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0105701:	01 c2                	add    %eax,%edx
f0105703:	c1 e2 02             	shl    $0x2,%edx
f0105706:	0f b7 4c 17 06       	movzwl 0x6(%edi,%edx,1),%ecx
f010570b:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010570e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105711:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0105714:	8d 54 17 04          	lea    0x4(%edi,%edx,1),%edx
f0105718:	83 c4 10             	add    $0x10,%esp
f010571b:	c6 45 c0 00          	movb   $0x0,-0x40(%ebp)
f010571f:	eb 19                	jmp    f010573a <debuginfo_eip+0x198>
		info->eip_fn_addr = addr;
f0105721:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0105724:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105727:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f010572a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010572d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105730:	eb a3                	jmp    f01056d5 <debuginfo_eip+0x133>
f0105732:	48                   	dec    %eax
f0105733:	83 ea 0c             	sub    $0xc,%edx
f0105736:	c6 45 c0 01          	movb   $0x1,-0x40(%ebp)
f010573a:	89 45 bc             	mov    %eax,-0x44(%ebp)
	while (lline >= lfile
f010573d:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0105740:	7f 40                	jg     f0105782 <debuginfo_eip+0x1e0>
	       && stabs[lline].n_type != N_SOL
f0105742:	8a 0a                	mov    (%edx),%cl
f0105744:	80 f9 84             	cmp    $0x84,%cl
f0105747:	74 19                	je     f0105762 <debuginfo_eip+0x1c0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105749:	80 f9 64             	cmp    $0x64,%cl
f010574c:	75 e4                	jne    f0105732 <debuginfo_eip+0x190>
f010574e:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0105752:	74 de                	je     f0105732 <debuginfo_eip+0x190>
f0105754:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f0105758:	74 0e                	je     f0105768 <debuginfo_eip+0x1c6>
f010575a:	8b 75 bc             	mov    -0x44(%ebp),%esi
f010575d:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0105760:	eb 06                	jmp    f0105768 <debuginfo_eip+0x1c6>
f0105762:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f0105766:	75 35                	jne    f010579d <debuginfo_eip+0x1fb>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105768:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010576b:	01 d0                	add    %edx,%eax
f010576d:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0105770:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0105773:	8b 75 b4             	mov    -0x4c(%ebp),%esi
f0105776:	29 f0                	sub    %esi,%eax
f0105778:	39 c2                	cmp    %eax,%edx
f010577a:	73 06                	jae    f0105782 <debuginfo_eip+0x1e0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010577c:	89 f0                	mov    %esi,%eax
f010577e:	01 d0                	add    %edx,%eax
f0105780:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105782:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105785:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0105788:	39 f2                	cmp    %esi,%edx
f010578a:	7d 44                	jge    f01057d0 <debuginfo_eip+0x22e>
		for (lline = lfun + 1;
f010578c:	42                   	inc    %edx
f010578d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105790:	89 d0                	mov    %edx,%eax
f0105792:	8d 0c 12             	lea    (%edx,%edx,1),%ecx
f0105795:	01 ca                	add    %ecx,%edx
f0105797:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f010579b:	eb 08                	jmp    f01057a5 <debuginfo_eip+0x203>
f010579d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01057a0:	eb c6                	jmp    f0105768 <debuginfo_eip+0x1c6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01057a2:	ff 43 14             	incl   0x14(%ebx)
		for (lline = lfun + 1;
f01057a5:	39 c6                	cmp    %eax,%esi
f01057a7:	7e 34                	jle    f01057dd <debuginfo_eip+0x23b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01057a9:	8a 0a                	mov    (%edx),%cl
f01057ab:	40                   	inc    %eax
f01057ac:	83 c2 0c             	add    $0xc,%edx
f01057af:	80 f9 a0             	cmp    $0xa0,%cl
f01057b2:	74 ee                	je     f01057a2 <debuginfo_eip+0x200>

	return 0;
f01057b4:	b8 00 00 00 00       	mov    $0x0,%eax
f01057b9:	eb 1a                	jmp    f01057d5 <debuginfo_eip+0x233>
		return -1;
f01057bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057c0:	eb 13                	jmp    f01057d5 <debuginfo_eip+0x233>
f01057c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057c7:	eb 0c                	jmp    f01057d5 <debuginfo_eip+0x233>
		return -1;
f01057c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057ce:	eb 05                	jmp    f01057d5 <debuginfo_eip+0x233>
	return 0;
f01057d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01057d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01057d8:	5b                   	pop    %ebx
f01057d9:	5e                   	pop    %esi
f01057da:	5f                   	pop    %edi
f01057db:	5d                   	pop    %ebp
f01057dc:	c3                   	ret    
	return 0;
f01057dd:	b8 00 00 00 00       	mov    $0x0,%eax
f01057e2:	eb f1                	jmp    f01057d5 <debuginfo_eip+0x233>

f01057e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01057e4:	55                   	push   %ebp
f01057e5:	89 e5                	mov    %esp,%ebp
f01057e7:	57                   	push   %edi
f01057e8:	56                   	push   %esi
f01057e9:	53                   	push   %ebx
f01057ea:	83 ec 1c             	sub    $0x1c,%esp
f01057ed:	89 c7                	mov    %eax,%edi
f01057ef:	89 d6                	mov    %edx,%esi
f01057f1:	8b 45 08             	mov    0x8(%ebp),%eax
f01057f4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01057f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01057fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01057fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105800:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105805:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105808:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f010580b:	39 d3                	cmp    %edx,%ebx
f010580d:	72 05                	jb     f0105814 <printnum+0x30>
f010580f:	39 45 10             	cmp    %eax,0x10(%ebp)
f0105812:	77 78                	ja     f010588c <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105814:	83 ec 0c             	sub    $0xc,%esp
f0105817:	ff 75 18             	pushl  0x18(%ebp)
f010581a:	8b 45 14             	mov    0x14(%ebp),%eax
f010581d:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0105820:	53                   	push   %ebx
f0105821:	ff 75 10             	pushl  0x10(%ebp)
f0105824:	83 ec 08             	sub    $0x8,%esp
f0105827:	ff 75 e4             	pushl  -0x1c(%ebp)
f010582a:	ff 75 e0             	pushl  -0x20(%ebp)
f010582d:	ff 75 dc             	pushl  -0x24(%ebp)
f0105830:	ff 75 d8             	pushl  -0x28(%ebp)
f0105833:	e8 00 13 00 00       	call   f0106b38 <__udivdi3>
f0105838:	83 c4 18             	add    $0x18,%esp
f010583b:	52                   	push   %edx
f010583c:	50                   	push   %eax
f010583d:	89 f2                	mov    %esi,%edx
f010583f:	89 f8                	mov    %edi,%eax
f0105841:	e8 9e ff ff ff       	call   f01057e4 <printnum>
f0105846:	83 c4 20             	add    $0x20,%esp
f0105849:	eb 11                	jmp    f010585c <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010584b:	83 ec 08             	sub    $0x8,%esp
f010584e:	56                   	push   %esi
f010584f:	ff 75 18             	pushl  0x18(%ebp)
f0105852:	ff d7                	call   *%edi
f0105854:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0105857:	4b                   	dec    %ebx
f0105858:	85 db                	test   %ebx,%ebx
f010585a:	7f ef                	jg     f010584b <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010585c:	83 ec 08             	sub    $0x8,%esp
f010585f:	56                   	push   %esi
f0105860:	83 ec 04             	sub    $0x4,%esp
f0105863:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105866:	ff 75 e0             	pushl  -0x20(%ebp)
f0105869:	ff 75 dc             	pushl  -0x24(%ebp)
f010586c:	ff 75 d8             	pushl  -0x28(%ebp)
f010586f:	e8 c4 13 00 00       	call   f0106c38 <__umoddi3>
f0105874:	83 c4 14             	add    $0x14,%esp
f0105877:	0f be 80 22 88 10 f0 	movsbl -0xfef77de(%eax),%eax
f010587e:	50                   	push   %eax
f010587f:	ff d7                	call   *%edi
}
f0105881:	83 c4 10             	add    $0x10,%esp
f0105884:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105887:	5b                   	pop    %ebx
f0105888:	5e                   	pop    %esi
f0105889:	5f                   	pop    %edi
f010588a:	5d                   	pop    %ebp
f010588b:	c3                   	ret    
f010588c:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010588f:	eb c6                	jmp    f0105857 <printnum+0x73>

f0105891 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105891:	55                   	push   %ebp
f0105892:	89 e5                	mov    %esp,%ebp
f0105894:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105897:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f010589a:	8b 10                	mov    (%eax),%edx
f010589c:	3b 50 04             	cmp    0x4(%eax),%edx
f010589f:	73 0a                	jae    f01058ab <sprintputch+0x1a>
		*b->buf++ = ch;
f01058a1:	8d 4a 01             	lea    0x1(%edx),%ecx
f01058a4:	89 08                	mov    %ecx,(%eax)
f01058a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01058a9:	88 02                	mov    %al,(%edx)
}
f01058ab:	5d                   	pop    %ebp
f01058ac:	c3                   	ret    

f01058ad <printfmt>:
{
f01058ad:	55                   	push   %ebp
f01058ae:	89 e5                	mov    %esp,%ebp
f01058b0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01058b3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01058b6:	50                   	push   %eax
f01058b7:	ff 75 10             	pushl  0x10(%ebp)
f01058ba:	ff 75 0c             	pushl  0xc(%ebp)
f01058bd:	ff 75 08             	pushl  0x8(%ebp)
f01058c0:	e8 05 00 00 00       	call   f01058ca <vprintfmt>
}
f01058c5:	83 c4 10             	add    $0x10,%esp
f01058c8:	c9                   	leave  
f01058c9:	c3                   	ret    

f01058ca <vprintfmt>:
{
f01058ca:	55                   	push   %ebp
f01058cb:	89 e5                	mov    %esp,%ebp
f01058cd:	57                   	push   %edi
f01058ce:	56                   	push   %esi
f01058cf:	53                   	push   %ebx
f01058d0:	83 ec 2c             	sub    $0x2c,%esp
f01058d3:	8b 75 08             	mov    0x8(%ebp),%esi
f01058d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01058d9:	8b 7d 10             	mov    0x10(%ebp),%edi
f01058dc:	e9 ac 03 00 00       	jmp    f0105c8d <vprintfmt+0x3c3>
		padc = ' ';
f01058e1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f01058e5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f01058ec:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f01058f3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f01058fa:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01058ff:	8d 47 01             	lea    0x1(%edi),%eax
f0105902:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105905:	8a 17                	mov    (%edi),%dl
f0105907:	8d 42 dd             	lea    -0x23(%edx),%eax
f010590a:	3c 55                	cmp    $0x55,%al
f010590c:	0f 87 fc 03 00 00    	ja     f0105d0e <vprintfmt+0x444>
f0105912:	0f b6 c0             	movzbl %al,%eax
f0105915:	ff 24 85 60 89 10 f0 	jmp    *-0xfef76a0(,%eax,4)
f010591c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f010591f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0105923:	eb da                	jmp    f01058ff <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0105925:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0105928:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f010592c:	eb d1                	jmp    f01058ff <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f010592e:	0f b6 d2             	movzbl %dl,%edx
f0105931:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0105934:	b8 00 00 00 00       	mov    $0x0,%eax
f0105939:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f010593c:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010593f:	01 c0                	add    %eax,%eax
f0105941:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
f0105945:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0105948:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010594b:	83 f9 09             	cmp    $0x9,%ecx
f010594e:	77 52                	ja     f01059a2 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
f0105950:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
f0105951:	eb e9                	jmp    f010593c <vprintfmt+0x72>
			precision = va_arg(ap, int);
f0105953:	8b 45 14             	mov    0x14(%ebp),%eax
f0105956:	8b 00                	mov    (%eax),%eax
f0105958:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010595b:	8b 45 14             	mov    0x14(%ebp),%eax
f010595e:	8d 40 04             	lea    0x4(%eax),%eax
f0105961:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105964:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0105967:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010596b:	79 92                	jns    f01058ff <vprintfmt+0x35>
				width = precision, precision = -1;
f010596d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105970:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105973:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f010597a:	eb 83                	jmp    f01058ff <vprintfmt+0x35>
f010597c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105980:	78 08                	js     f010598a <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
f0105982:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105985:	e9 75 ff ff ff       	jmp    f01058ff <vprintfmt+0x35>
f010598a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0105991:	eb ef                	jmp    f0105982 <vprintfmt+0xb8>
f0105993:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0105996:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010599d:	e9 5d ff ff ff       	jmp    f01058ff <vprintfmt+0x35>
f01059a2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01059a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01059a8:	eb bd                	jmp    f0105967 <vprintfmt+0x9d>
			lflag++;
f01059aa:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
f01059ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01059ae:	e9 4c ff ff ff       	jmp    f01058ff <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f01059b3:	8b 45 14             	mov    0x14(%ebp),%eax
f01059b6:	8d 78 04             	lea    0x4(%eax),%edi
f01059b9:	83 ec 08             	sub    $0x8,%esp
f01059bc:	53                   	push   %ebx
f01059bd:	ff 30                	pushl  (%eax)
f01059bf:	ff d6                	call   *%esi
			break;
f01059c1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01059c4:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01059c7:	e9 be 02 00 00       	jmp    f0105c8a <vprintfmt+0x3c0>
			err = va_arg(ap, int);
f01059cc:	8b 45 14             	mov    0x14(%ebp),%eax
f01059cf:	8d 78 04             	lea    0x4(%eax),%edi
f01059d2:	8b 00                	mov    (%eax),%eax
f01059d4:	85 c0                	test   %eax,%eax
f01059d6:	78 2a                	js     f0105a02 <vprintfmt+0x138>
f01059d8:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01059da:	83 f8 0f             	cmp    $0xf,%eax
f01059dd:	7f 27                	jg     f0105a06 <vprintfmt+0x13c>
f01059df:	8b 04 85 c0 8a 10 f0 	mov    -0xfef7540(,%eax,4),%eax
f01059e6:	85 c0                	test   %eax,%eax
f01059e8:	74 1c                	je     f0105a06 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
f01059ea:	50                   	push   %eax
f01059eb:	68 b5 7f 10 f0       	push   $0xf0107fb5
f01059f0:	53                   	push   %ebx
f01059f1:	56                   	push   %esi
f01059f2:	e8 b6 fe ff ff       	call   f01058ad <printfmt>
f01059f7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01059fa:	89 7d 14             	mov    %edi,0x14(%ebp)
f01059fd:	e9 88 02 00 00       	jmp    f0105c8a <vprintfmt+0x3c0>
f0105a02:	f7 d8                	neg    %eax
f0105a04:	eb d2                	jmp    f01059d8 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
f0105a06:	52                   	push   %edx
f0105a07:	68 3a 88 10 f0       	push   $0xf010883a
f0105a0c:	53                   	push   %ebx
f0105a0d:	56                   	push   %esi
f0105a0e:	e8 9a fe ff ff       	call   f01058ad <printfmt>
f0105a13:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105a16:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0105a19:	e9 6c 02 00 00       	jmp    f0105c8a <vprintfmt+0x3c0>
			if ((p = va_arg(ap, char *)) == NULL)
f0105a1e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a21:	83 c0 04             	add    $0x4,%eax
f0105a24:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0105a27:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a2a:	8b 38                	mov    (%eax),%edi
f0105a2c:	85 ff                	test   %edi,%edi
f0105a2e:	74 18                	je     f0105a48 <vprintfmt+0x17e>
			if (width > 0 && padc != '-')
f0105a30:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105a34:	0f 8e b7 00 00 00    	jle    f0105af1 <vprintfmt+0x227>
f0105a3a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0105a3e:	75 0f                	jne    f0105a4f <vprintfmt+0x185>
f0105a40:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105a43:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0105a46:	eb 6e                	jmp    f0105ab6 <vprintfmt+0x1ec>
				p = "(null)";
f0105a48:	bf 33 88 10 f0       	mov    $0xf0108833,%edi
f0105a4d:	eb e1                	jmp    f0105a30 <vprintfmt+0x166>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105a4f:	83 ec 08             	sub    $0x8,%esp
f0105a52:	ff 75 d0             	pushl  -0x30(%ebp)
f0105a55:	57                   	push   %edi
f0105a56:	e8 57 04 00 00       	call   f0105eb2 <strnlen>
f0105a5b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105a5e:	29 c1                	sub    %eax,%ecx
f0105a60:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0105a63:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105a66:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105a6a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105a6d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105a70:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0105a72:	eb 0d                	jmp    f0105a81 <vprintfmt+0x1b7>
					putch(padc, putdat);
f0105a74:	83 ec 08             	sub    $0x8,%esp
f0105a77:	53                   	push   %ebx
f0105a78:	ff 75 e0             	pushl  -0x20(%ebp)
f0105a7b:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0105a7d:	4f                   	dec    %edi
f0105a7e:	83 c4 10             	add    $0x10,%esp
f0105a81:	85 ff                	test   %edi,%edi
f0105a83:	7f ef                	jg     f0105a74 <vprintfmt+0x1aa>
f0105a85:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105a88:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0105a8b:	89 c8                	mov    %ecx,%eax
f0105a8d:	85 c9                	test   %ecx,%ecx
f0105a8f:	78 59                	js     f0105aea <vprintfmt+0x220>
f0105a91:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0105a94:	29 c1                	sub    %eax,%ecx
f0105a96:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105a99:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105a9c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0105a9f:	eb 15                	jmp    f0105ab6 <vprintfmt+0x1ec>
				if (altflag && (ch < ' ' || ch > '~'))
f0105aa1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105aa5:	75 29                	jne    f0105ad0 <vprintfmt+0x206>
					putch(ch, putdat);
f0105aa7:	83 ec 08             	sub    $0x8,%esp
f0105aaa:	ff 75 0c             	pushl  0xc(%ebp)
f0105aad:	50                   	push   %eax
f0105aae:	ff d6                	call   *%esi
f0105ab0:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105ab3:	ff 4d e0             	decl   -0x20(%ebp)
f0105ab6:	47                   	inc    %edi
f0105ab7:	8a 57 ff             	mov    -0x1(%edi),%dl
f0105aba:	0f be c2             	movsbl %dl,%eax
f0105abd:	85 c0                	test   %eax,%eax
f0105abf:	74 53                	je     f0105b14 <vprintfmt+0x24a>
f0105ac1:	85 db                	test   %ebx,%ebx
f0105ac3:	78 dc                	js     f0105aa1 <vprintfmt+0x1d7>
f0105ac5:	4b                   	dec    %ebx
f0105ac6:	79 d9                	jns    f0105aa1 <vprintfmt+0x1d7>
f0105ac8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105acb:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105ace:	eb 35                	jmp    f0105b05 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
f0105ad0:	0f be d2             	movsbl %dl,%edx
f0105ad3:	83 ea 20             	sub    $0x20,%edx
f0105ad6:	83 fa 5e             	cmp    $0x5e,%edx
f0105ad9:	76 cc                	jbe    f0105aa7 <vprintfmt+0x1dd>
					putch('?', putdat);
f0105adb:	83 ec 08             	sub    $0x8,%esp
f0105ade:	ff 75 0c             	pushl  0xc(%ebp)
f0105ae1:	6a 3f                	push   $0x3f
f0105ae3:	ff d6                	call   *%esi
f0105ae5:	83 c4 10             	add    $0x10,%esp
f0105ae8:	eb c9                	jmp    f0105ab3 <vprintfmt+0x1e9>
f0105aea:	b8 00 00 00 00       	mov    $0x0,%eax
f0105aef:	eb a0                	jmp    f0105a91 <vprintfmt+0x1c7>
f0105af1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105af4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0105af7:	eb bd                	jmp    f0105ab6 <vprintfmt+0x1ec>
				putch(' ', putdat);
f0105af9:	83 ec 08             	sub    $0x8,%esp
f0105afc:	53                   	push   %ebx
f0105afd:	6a 20                	push   $0x20
f0105aff:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0105b01:	4f                   	dec    %edi
f0105b02:	83 c4 10             	add    $0x10,%esp
f0105b05:	85 ff                	test   %edi,%edi
f0105b07:	7f f0                	jg     f0105af9 <vprintfmt+0x22f>
			if ((p = va_arg(ap, char *)) == NULL)
f0105b09:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105b0c:	89 45 14             	mov    %eax,0x14(%ebp)
f0105b0f:	e9 76 01 00 00       	jmp    f0105c8a <vprintfmt+0x3c0>
f0105b14:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105b17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105b1a:	eb e9                	jmp    f0105b05 <vprintfmt+0x23b>
	if (lflag >= 2)
f0105b1c:	83 f9 01             	cmp    $0x1,%ecx
f0105b1f:	7e 3f                	jle    f0105b60 <vprintfmt+0x296>
		return va_arg(*ap, long long);
f0105b21:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b24:	8b 50 04             	mov    0x4(%eax),%edx
f0105b27:	8b 00                	mov    (%eax),%eax
f0105b29:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105b2c:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105b2f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b32:	8d 40 08             	lea    0x8(%eax),%eax
f0105b35:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0105b38:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105b3c:	79 5c                	jns    f0105b9a <vprintfmt+0x2d0>
				putch('-', putdat);
f0105b3e:	83 ec 08             	sub    $0x8,%esp
f0105b41:	53                   	push   %ebx
f0105b42:	6a 2d                	push   $0x2d
f0105b44:	ff d6                	call   *%esi
				num = -(long long) num;
f0105b46:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105b49:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105b4c:	f7 da                	neg    %edx
f0105b4e:	83 d1 00             	adc    $0x0,%ecx
f0105b51:	f7 d9                	neg    %ecx
f0105b53:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0105b56:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105b5b:	e9 10 01 00 00       	jmp    f0105c70 <vprintfmt+0x3a6>
	else if (lflag)
f0105b60:	85 c9                	test   %ecx,%ecx
f0105b62:	75 1b                	jne    f0105b7f <vprintfmt+0x2b5>
		return va_arg(*ap, int);
f0105b64:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b67:	8b 00                	mov    (%eax),%eax
f0105b69:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105b6c:	89 c1                	mov    %eax,%ecx
f0105b6e:	c1 f9 1f             	sar    $0x1f,%ecx
f0105b71:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105b74:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b77:	8d 40 04             	lea    0x4(%eax),%eax
f0105b7a:	89 45 14             	mov    %eax,0x14(%ebp)
f0105b7d:	eb b9                	jmp    f0105b38 <vprintfmt+0x26e>
		return va_arg(*ap, long);
f0105b7f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b82:	8b 00                	mov    (%eax),%eax
f0105b84:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105b87:	89 c1                	mov    %eax,%ecx
f0105b89:	c1 f9 1f             	sar    $0x1f,%ecx
f0105b8c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105b8f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b92:	8d 40 04             	lea    0x4(%eax),%eax
f0105b95:	89 45 14             	mov    %eax,0x14(%ebp)
f0105b98:	eb 9e                	jmp    f0105b38 <vprintfmt+0x26e>
			num = getint(&ap, lflag);
f0105b9a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105b9d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0105ba0:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105ba5:	e9 c6 00 00 00       	jmp    f0105c70 <vprintfmt+0x3a6>
	if (lflag >= 2)
f0105baa:	83 f9 01             	cmp    $0x1,%ecx
f0105bad:	7e 18                	jle    f0105bc7 <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
f0105baf:	8b 45 14             	mov    0x14(%ebp),%eax
f0105bb2:	8b 10                	mov    (%eax),%edx
f0105bb4:	8b 48 04             	mov    0x4(%eax),%ecx
f0105bb7:	8d 40 08             	lea    0x8(%eax),%eax
f0105bba:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105bbd:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105bc2:	e9 a9 00 00 00       	jmp    f0105c70 <vprintfmt+0x3a6>
	else if (lflag)
f0105bc7:	85 c9                	test   %ecx,%ecx
f0105bc9:	75 1a                	jne    f0105be5 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned int);
f0105bcb:	8b 45 14             	mov    0x14(%ebp),%eax
f0105bce:	8b 10                	mov    (%eax),%edx
f0105bd0:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105bd5:	8d 40 04             	lea    0x4(%eax),%eax
f0105bd8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105bdb:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105be0:	e9 8b 00 00 00       	jmp    f0105c70 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0105be5:	8b 45 14             	mov    0x14(%ebp),%eax
f0105be8:	8b 10                	mov    (%eax),%edx
f0105bea:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105bef:	8d 40 04             	lea    0x4(%eax),%eax
f0105bf2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105bf5:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105bfa:	eb 74                	jmp    f0105c70 <vprintfmt+0x3a6>
	if (lflag >= 2)
f0105bfc:	83 f9 01             	cmp    $0x1,%ecx
f0105bff:	7e 15                	jle    f0105c16 <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
f0105c01:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c04:	8b 10                	mov    (%eax),%edx
f0105c06:	8b 48 04             	mov    0x4(%eax),%ecx
f0105c09:	8d 40 08             	lea    0x8(%eax),%eax
f0105c0c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0105c0f:	b8 08 00 00 00       	mov    $0x8,%eax
f0105c14:	eb 5a                	jmp    f0105c70 <vprintfmt+0x3a6>
	else if (lflag)
f0105c16:	85 c9                	test   %ecx,%ecx
f0105c18:	75 17                	jne    f0105c31 <vprintfmt+0x367>
		return va_arg(*ap, unsigned int);
f0105c1a:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c1d:	8b 10                	mov    (%eax),%edx
f0105c1f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105c24:	8d 40 04             	lea    0x4(%eax),%eax
f0105c27:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0105c2a:	b8 08 00 00 00       	mov    $0x8,%eax
f0105c2f:	eb 3f                	jmp    f0105c70 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0105c31:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c34:	8b 10                	mov    (%eax),%edx
f0105c36:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105c3b:	8d 40 04             	lea    0x4(%eax),%eax
f0105c3e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0105c41:	b8 08 00 00 00       	mov    $0x8,%eax
f0105c46:	eb 28                	jmp    f0105c70 <vprintfmt+0x3a6>
			putch('0', putdat);
f0105c48:	83 ec 08             	sub    $0x8,%esp
f0105c4b:	53                   	push   %ebx
f0105c4c:	6a 30                	push   $0x30
f0105c4e:	ff d6                	call   *%esi
			putch('x', putdat);
f0105c50:	83 c4 08             	add    $0x8,%esp
f0105c53:	53                   	push   %ebx
f0105c54:	6a 78                	push   $0x78
f0105c56:	ff d6                	call   *%esi
			num = (unsigned long long)
f0105c58:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c5b:	8b 10                	mov    (%eax),%edx
f0105c5d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0105c62:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0105c65:	8d 40 04             	lea    0x4(%eax),%eax
f0105c68:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105c6b:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0105c70:	83 ec 0c             	sub    $0xc,%esp
f0105c73:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105c77:	57                   	push   %edi
f0105c78:	ff 75 e0             	pushl  -0x20(%ebp)
f0105c7b:	50                   	push   %eax
f0105c7c:	51                   	push   %ecx
f0105c7d:	52                   	push   %edx
f0105c7e:	89 da                	mov    %ebx,%edx
f0105c80:	89 f0                	mov    %esi,%eax
f0105c82:	e8 5d fb ff ff       	call   f01057e4 <printnum>
			break;
f0105c87:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0105c8a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105c8d:	47                   	inc    %edi
f0105c8e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105c92:	83 f8 25             	cmp    $0x25,%eax
f0105c95:	0f 84 46 fc ff ff    	je     f01058e1 <vprintfmt+0x17>
			if (ch == '\0')
f0105c9b:	85 c0                	test   %eax,%eax
f0105c9d:	0f 84 89 00 00 00    	je     f0105d2c <vprintfmt+0x462>
			putch(ch, putdat);
f0105ca3:	83 ec 08             	sub    $0x8,%esp
f0105ca6:	53                   	push   %ebx
f0105ca7:	50                   	push   %eax
f0105ca8:	ff d6                	call   *%esi
f0105caa:	83 c4 10             	add    $0x10,%esp
f0105cad:	eb de                	jmp    f0105c8d <vprintfmt+0x3c3>
	if (lflag >= 2)
f0105caf:	83 f9 01             	cmp    $0x1,%ecx
f0105cb2:	7e 15                	jle    f0105cc9 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
f0105cb4:	8b 45 14             	mov    0x14(%ebp),%eax
f0105cb7:	8b 10                	mov    (%eax),%edx
f0105cb9:	8b 48 04             	mov    0x4(%eax),%ecx
f0105cbc:	8d 40 08             	lea    0x8(%eax),%eax
f0105cbf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105cc2:	b8 10 00 00 00       	mov    $0x10,%eax
f0105cc7:	eb a7                	jmp    f0105c70 <vprintfmt+0x3a6>
	else if (lflag)
f0105cc9:	85 c9                	test   %ecx,%ecx
f0105ccb:	75 17                	jne    f0105ce4 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned int);
f0105ccd:	8b 45 14             	mov    0x14(%ebp),%eax
f0105cd0:	8b 10                	mov    (%eax),%edx
f0105cd2:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105cd7:	8d 40 04             	lea    0x4(%eax),%eax
f0105cda:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105cdd:	b8 10 00 00 00       	mov    $0x10,%eax
f0105ce2:	eb 8c                	jmp    f0105c70 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0105ce4:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ce7:	8b 10                	mov    (%eax),%edx
f0105ce9:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105cee:	8d 40 04             	lea    0x4(%eax),%eax
f0105cf1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105cf4:	b8 10 00 00 00       	mov    $0x10,%eax
f0105cf9:	e9 72 ff ff ff       	jmp    f0105c70 <vprintfmt+0x3a6>
			putch(ch, putdat);
f0105cfe:	83 ec 08             	sub    $0x8,%esp
f0105d01:	53                   	push   %ebx
f0105d02:	6a 25                	push   $0x25
f0105d04:	ff d6                	call   *%esi
			break;
f0105d06:	83 c4 10             	add    $0x10,%esp
f0105d09:	e9 7c ff ff ff       	jmp    f0105c8a <vprintfmt+0x3c0>
			putch('%', putdat);
f0105d0e:	83 ec 08             	sub    $0x8,%esp
f0105d11:	53                   	push   %ebx
f0105d12:	6a 25                	push   $0x25
f0105d14:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105d16:	83 c4 10             	add    $0x10,%esp
f0105d19:	89 f8                	mov    %edi,%eax
f0105d1b:	eb 01                	jmp    f0105d1e <vprintfmt+0x454>
f0105d1d:	48                   	dec    %eax
f0105d1e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0105d22:	75 f9                	jne    f0105d1d <vprintfmt+0x453>
f0105d24:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105d27:	e9 5e ff ff ff       	jmp    f0105c8a <vprintfmt+0x3c0>
}
f0105d2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105d2f:	5b                   	pop    %ebx
f0105d30:	5e                   	pop    %esi
f0105d31:	5f                   	pop    %edi
f0105d32:	5d                   	pop    %ebp
f0105d33:	c3                   	ret    

f0105d34 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105d34:	55                   	push   %ebp
f0105d35:	89 e5                	mov    %esp,%ebp
f0105d37:	83 ec 18             	sub    $0x18,%esp
f0105d3a:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d3d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105d40:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105d43:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105d47:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105d4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105d51:	85 c0                	test   %eax,%eax
f0105d53:	74 26                	je     f0105d7b <vsnprintf+0x47>
f0105d55:	85 d2                	test   %edx,%edx
f0105d57:	7e 29                	jle    f0105d82 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105d59:	ff 75 14             	pushl  0x14(%ebp)
f0105d5c:	ff 75 10             	pushl  0x10(%ebp)
f0105d5f:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105d62:	50                   	push   %eax
f0105d63:	68 91 58 10 f0       	push   $0xf0105891
f0105d68:	e8 5d fb ff ff       	call   f01058ca <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105d6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105d70:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105d76:	83 c4 10             	add    $0x10,%esp
}
f0105d79:	c9                   	leave  
f0105d7a:	c3                   	ret    
		return -E_INVAL;
f0105d7b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105d80:	eb f7                	jmp    f0105d79 <vsnprintf+0x45>
f0105d82:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105d87:	eb f0                	jmp    f0105d79 <vsnprintf+0x45>

f0105d89 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105d89:	55                   	push   %ebp
f0105d8a:	89 e5                	mov    %esp,%ebp
f0105d8c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105d8f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105d92:	50                   	push   %eax
f0105d93:	ff 75 10             	pushl  0x10(%ebp)
f0105d96:	ff 75 0c             	pushl  0xc(%ebp)
f0105d99:	ff 75 08             	pushl  0x8(%ebp)
f0105d9c:	e8 93 ff ff ff       	call   f0105d34 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105da1:	c9                   	leave  
f0105da2:	c3                   	ret    

f0105da3 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105da3:	55                   	push   %ebp
f0105da4:	89 e5                	mov    %esp,%ebp
f0105da6:	57                   	push   %edi
f0105da7:	56                   	push   %esi
f0105da8:	53                   	push   %ebx
f0105da9:	83 ec 0c             	sub    $0xc,%esp
f0105dac:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105daf:	85 c0                	test   %eax,%eax
f0105db1:	74 11                	je     f0105dc4 <readline+0x21>
		cprintf("%s", prompt);
f0105db3:	83 ec 08             	sub    $0x8,%esp
f0105db6:	50                   	push   %eax
f0105db7:	68 b5 7f 10 f0       	push   $0xf0107fb5
f0105dbc:	e8 d8 e1 ff ff       	call   f0103f99 <cprintf>
f0105dc1:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105dc4:	83 ec 0c             	sub    $0xc,%esp
f0105dc7:	6a 00                	push   $0x0
f0105dc9:	e8 94 aa ff ff       	call   f0100862 <iscons>
f0105dce:	89 c7                	mov    %eax,%edi
f0105dd0:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0105dd3:	be 00 00 00 00       	mov    $0x0,%esi
f0105dd8:	eb 7b                	jmp    f0105e55 <readline+0xb2>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f0105dda:	83 f8 f8             	cmp    $0xfffffff8,%eax
f0105ddd:	75 07                	jne    f0105de6 <readline+0x43>
				cprintf("read error: %e\n", c);
			return NULL;
f0105ddf:	b8 00 00 00 00       	mov    $0x0,%eax
f0105de4:	eb 4f                	jmp    f0105e35 <readline+0x92>
				cprintf("read error: %e\n", c);
f0105de6:	83 ec 08             	sub    $0x8,%esp
f0105de9:	50                   	push   %eax
f0105dea:	68 1f 8b 10 f0       	push   $0xf0108b1f
f0105def:	e8 a5 e1 ff ff       	call   f0103f99 <cprintf>
f0105df4:	83 c4 10             	add    $0x10,%esp
			return NULL;
f0105df7:	b8 00 00 00 00       	mov    $0x0,%eax
f0105dfc:	eb 37                	jmp    f0105e35 <readline+0x92>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
			if (echoing)
				cputchar('\b');
f0105dfe:	83 ec 0c             	sub    $0xc,%esp
f0105e01:	6a 08                	push   $0x8
f0105e03:	e8 39 aa ff ff       	call   f0100841 <cputchar>
f0105e08:	83 c4 10             	add    $0x10,%esp
f0105e0b:	eb 47                	jmp    f0105e54 <readline+0xb1>
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
f0105e0d:	83 ec 0c             	sub    $0xc,%esp
f0105e10:	53                   	push   %ebx
f0105e11:	e8 2b aa ff ff       	call   f0100841 <cputchar>
f0105e16:	83 c4 10             	add    $0x10,%esp
f0105e19:	eb 64                	jmp    f0105e7f <readline+0xdc>
			buf[i++] = c;
		} else if (c == '\n' || c == '\r') {
f0105e1b:	83 fb 0a             	cmp    $0xa,%ebx
f0105e1e:	74 05                	je     f0105e25 <readline+0x82>
f0105e20:	83 fb 0d             	cmp    $0xd,%ebx
f0105e23:	75 30                	jne    f0105e55 <readline+0xb2>
			if (echoing)
f0105e25:	85 ff                	test   %edi,%edi
f0105e27:	75 14                	jne    f0105e3d <readline+0x9a>
				cputchar('\n');
			buf[i] = 0;
f0105e29:	c6 86 80 5a 2a f0 00 	movb   $0x0,-0xfd5a580(%esi)
			return buf;
f0105e30:	b8 80 5a 2a f0       	mov    $0xf02a5a80,%eax
		}
	}
}
f0105e35:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105e38:	5b                   	pop    %ebx
f0105e39:	5e                   	pop    %esi
f0105e3a:	5f                   	pop    %edi
f0105e3b:	5d                   	pop    %ebp
f0105e3c:	c3                   	ret    
				cputchar('\n');
f0105e3d:	83 ec 0c             	sub    $0xc,%esp
f0105e40:	6a 0a                	push   $0xa
f0105e42:	e8 fa a9 ff ff       	call   f0100841 <cputchar>
f0105e47:	83 c4 10             	add    $0x10,%esp
f0105e4a:	eb dd                	jmp    f0105e29 <readline+0x86>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105e4c:	85 f6                	test   %esi,%esi
f0105e4e:	7e 40                	jle    f0105e90 <readline+0xed>
			if (echoing)
f0105e50:	85 ff                	test   %edi,%edi
f0105e52:	75 aa                	jne    f0105dfe <readline+0x5b>
			i--;
f0105e54:	4e                   	dec    %esi
		c = getchar();
f0105e55:	e8 f7 a9 ff ff       	call   f0100851 <getchar>
f0105e5a:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105e5c:	85 c0                	test   %eax,%eax
f0105e5e:	0f 88 76 ff ff ff    	js     f0105dda <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105e64:	83 f8 08             	cmp    $0x8,%eax
f0105e67:	74 21                	je     f0105e8a <readline+0xe7>
f0105e69:	83 f8 7f             	cmp    $0x7f,%eax
f0105e6c:	74 de                	je     f0105e4c <readline+0xa9>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105e6e:	83 f8 1f             	cmp    $0x1f,%eax
f0105e71:	7e a8                	jle    f0105e1b <readline+0x78>
f0105e73:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105e79:	7f a0                	jg     f0105e1b <readline+0x78>
			if (echoing)
f0105e7b:	85 ff                	test   %edi,%edi
f0105e7d:	75 8e                	jne    f0105e0d <readline+0x6a>
			buf[i++] = c;
f0105e7f:	88 9e 80 5a 2a f0    	mov    %bl,-0xfd5a580(%esi)
f0105e85:	8d 76 01             	lea    0x1(%esi),%esi
f0105e88:	eb cb                	jmp    f0105e55 <readline+0xb2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105e8a:	85 f6                	test   %esi,%esi
f0105e8c:	7e c7                	jle    f0105e55 <readline+0xb2>
f0105e8e:	eb c0                	jmp    f0105e50 <readline+0xad>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105e90:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105e96:	7e e3                	jle    f0105e7b <readline+0xd8>
f0105e98:	eb bb                	jmp    f0105e55 <readline+0xb2>

f0105e9a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105e9a:	55                   	push   %ebp
f0105e9b:	89 e5                	mov    %esp,%ebp
f0105e9d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105ea0:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ea5:	eb 03                	jmp    f0105eaa <strlen+0x10>
		n++;
f0105ea7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0105eaa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105eae:	75 f7                	jne    f0105ea7 <strlen+0xd>
	return n;
}
f0105eb0:	5d                   	pop    %ebp
f0105eb1:	c3                   	ret    

f0105eb2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105eb2:	55                   	push   %ebp
f0105eb3:	89 e5                	mov    %esp,%ebp
f0105eb5:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105eb8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105ebb:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ec0:	eb 03                	jmp    f0105ec5 <strnlen+0x13>
		n++;
f0105ec2:	83 c2 01             	add    $0x1,%edx
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105ec5:	39 c2                	cmp    %eax,%edx
f0105ec7:	74 08                	je     f0105ed1 <strnlen+0x1f>
f0105ec9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0105ecd:	75 f3                	jne    f0105ec2 <strnlen+0x10>
f0105ecf:	89 d0                	mov    %edx,%eax
	return n;
}
f0105ed1:	5d                   	pop    %ebp
f0105ed2:	c3                   	ret    

f0105ed3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105ed3:	55                   	push   %ebp
f0105ed4:	89 e5                	mov    %esp,%ebp
f0105ed6:	53                   	push   %ebx
f0105ed7:	8b 45 08             	mov    0x8(%ebp),%eax
f0105eda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105edd:	89 c2                	mov    %eax,%edx
f0105edf:	83 c2 01             	add    $0x1,%edx
f0105ee2:	83 c1 01             	add    $0x1,%ecx
f0105ee5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105ee9:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105eec:	84 db                	test   %bl,%bl
f0105eee:	75 ef                	jne    f0105edf <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105ef0:	5b                   	pop    %ebx
f0105ef1:	5d                   	pop    %ebp
f0105ef2:	c3                   	ret    

f0105ef3 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105ef3:	55                   	push   %ebp
f0105ef4:	89 e5                	mov    %esp,%ebp
f0105ef6:	53                   	push   %ebx
f0105ef7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105efa:	53                   	push   %ebx
f0105efb:	e8 9a ff ff ff       	call   f0105e9a <strlen>
f0105f00:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105f03:	ff 75 0c             	pushl  0xc(%ebp)
f0105f06:	01 d8                	add    %ebx,%eax
f0105f08:	50                   	push   %eax
f0105f09:	e8 c5 ff ff ff       	call   f0105ed3 <strcpy>
	return dst;
}
f0105f0e:	89 d8                	mov    %ebx,%eax
f0105f10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105f13:	c9                   	leave  
f0105f14:	c3                   	ret    

f0105f15 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105f15:	55                   	push   %ebp
f0105f16:	89 e5                	mov    %esp,%ebp
f0105f18:	56                   	push   %esi
f0105f19:	53                   	push   %ebx
f0105f1a:	8b 75 08             	mov    0x8(%ebp),%esi
f0105f1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105f20:	89 f3                	mov    %esi,%ebx
f0105f22:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105f25:	89 f2                	mov    %esi,%edx
f0105f27:	eb 0f                	jmp    f0105f38 <strncpy+0x23>
		*dst++ = *src;
f0105f29:	83 c2 01             	add    $0x1,%edx
f0105f2c:	0f b6 01             	movzbl (%ecx),%eax
f0105f2f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105f32:	80 39 01             	cmpb   $0x1,(%ecx)
f0105f35:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0105f38:	39 da                	cmp    %ebx,%edx
f0105f3a:	75 ed                	jne    f0105f29 <strncpy+0x14>
	}
	return ret;
}
f0105f3c:	89 f0                	mov    %esi,%eax
f0105f3e:	5b                   	pop    %ebx
f0105f3f:	5e                   	pop    %esi
f0105f40:	5d                   	pop    %ebp
f0105f41:	c3                   	ret    

f0105f42 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105f42:	55                   	push   %ebp
f0105f43:	89 e5                	mov    %esp,%ebp
f0105f45:	56                   	push   %esi
f0105f46:	53                   	push   %ebx
f0105f47:	8b 75 08             	mov    0x8(%ebp),%esi
f0105f4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105f4d:	8b 55 10             	mov    0x10(%ebp),%edx
f0105f50:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105f52:	85 d2                	test   %edx,%edx
f0105f54:	74 21                	je     f0105f77 <strlcpy+0x35>
f0105f56:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105f5a:	89 f2                	mov    %esi,%edx
f0105f5c:	eb 09                	jmp    f0105f67 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105f5e:	83 c2 01             	add    $0x1,%edx
f0105f61:	83 c1 01             	add    $0x1,%ecx
f0105f64:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f0105f67:	39 c2                	cmp    %eax,%edx
f0105f69:	74 09                	je     f0105f74 <strlcpy+0x32>
f0105f6b:	0f b6 19             	movzbl (%ecx),%ebx
f0105f6e:	84 db                	test   %bl,%bl
f0105f70:	75 ec                	jne    f0105f5e <strlcpy+0x1c>
f0105f72:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0105f74:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105f77:	29 f0                	sub    %esi,%eax
}
f0105f79:	5b                   	pop    %ebx
f0105f7a:	5e                   	pop    %esi
f0105f7b:	5d                   	pop    %ebp
f0105f7c:	c3                   	ret    

f0105f7d <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105f7d:	55                   	push   %ebp
f0105f7e:	89 e5                	mov    %esp,%ebp
f0105f80:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105f83:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105f86:	eb 06                	jmp    f0105f8e <strcmp+0x11>
		p++, q++;
f0105f88:	83 c1 01             	add    $0x1,%ecx
f0105f8b:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0105f8e:	0f b6 01             	movzbl (%ecx),%eax
f0105f91:	84 c0                	test   %al,%al
f0105f93:	74 04                	je     f0105f99 <strcmp+0x1c>
f0105f95:	3a 02                	cmp    (%edx),%al
f0105f97:	74 ef                	je     f0105f88 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105f99:	0f b6 c0             	movzbl %al,%eax
f0105f9c:	0f b6 12             	movzbl (%edx),%edx
f0105f9f:	29 d0                	sub    %edx,%eax
}
f0105fa1:	5d                   	pop    %ebp
f0105fa2:	c3                   	ret    

f0105fa3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105fa3:	55                   	push   %ebp
f0105fa4:	89 e5                	mov    %esp,%ebp
f0105fa6:	53                   	push   %ebx
f0105fa7:	8b 45 08             	mov    0x8(%ebp),%eax
f0105faa:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105fad:	89 c3                	mov    %eax,%ebx
f0105faf:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105fb2:	eb 06                	jmp    f0105fba <strncmp+0x17>
		n--, p++, q++;
f0105fb4:	83 c0 01             	add    $0x1,%eax
f0105fb7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0105fba:	39 d8                	cmp    %ebx,%eax
f0105fbc:	74 15                	je     f0105fd3 <strncmp+0x30>
f0105fbe:	0f b6 08             	movzbl (%eax),%ecx
f0105fc1:	84 c9                	test   %cl,%cl
f0105fc3:	74 04                	je     f0105fc9 <strncmp+0x26>
f0105fc5:	3a 0a                	cmp    (%edx),%cl
f0105fc7:	74 eb                	je     f0105fb4 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105fc9:	0f b6 00             	movzbl (%eax),%eax
f0105fcc:	0f b6 12             	movzbl (%edx),%edx
f0105fcf:	29 d0                	sub    %edx,%eax
f0105fd1:	eb 05                	jmp    f0105fd8 <strncmp+0x35>
		return 0;
f0105fd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105fd8:	5b                   	pop    %ebx
f0105fd9:	5d                   	pop    %ebp
f0105fda:	c3                   	ret    

f0105fdb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105fdb:	55                   	push   %ebp
f0105fdc:	89 e5                	mov    %esp,%ebp
f0105fde:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fe1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105fe5:	eb 07                	jmp    f0105fee <strchr+0x13>
		if (*s == c)
f0105fe7:	38 ca                	cmp    %cl,%dl
f0105fe9:	74 0f                	je     f0105ffa <strchr+0x1f>
	for (; *s; s++)
f0105feb:	83 c0 01             	add    $0x1,%eax
f0105fee:	0f b6 10             	movzbl (%eax),%edx
f0105ff1:	84 d2                	test   %dl,%dl
f0105ff3:	75 f2                	jne    f0105fe7 <strchr+0xc>
			return (char *) s;
	return 0;
f0105ff5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105ffa:	5d                   	pop    %ebp
f0105ffb:	c3                   	ret    

f0105ffc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105ffc:	55                   	push   %ebp
f0105ffd:	89 e5                	mov    %esp,%ebp
f0105fff:	8b 45 08             	mov    0x8(%ebp),%eax
f0106002:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0106006:	eb 03                	jmp    f010600b <strfind+0xf>
f0106008:	83 c0 01             	add    $0x1,%eax
f010600b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010600e:	38 ca                	cmp    %cl,%dl
f0106010:	74 04                	je     f0106016 <strfind+0x1a>
f0106012:	84 d2                	test   %dl,%dl
f0106014:	75 f2                	jne    f0106008 <strfind+0xc>
			break;
	return (char *) s;
}
f0106016:	5d                   	pop    %ebp
f0106017:	c3                   	ret    

f0106018 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0106018:	55                   	push   %ebp
f0106019:	89 e5                	mov    %esp,%ebp
f010601b:	57                   	push   %edi
f010601c:	56                   	push   %esi
f010601d:	53                   	push   %ebx
f010601e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106021:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0106024:	85 c9                	test   %ecx,%ecx
f0106026:	74 36                	je     f010605e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0106028:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010602e:	75 28                	jne    f0106058 <memset+0x40>
f0106030:	f6 c1 03             	test   $0x3,%cl
f0106033:	75 23                	jne    f0106058 <memset+0x40>
		c &= 0xFF;
f0106035:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0106039:	89 d3                	mov    %edx,%ebx
f010603b:	c1 e3 08             	shl    $0x8,%ebx
f010603e:	89 d6                	mov    %edx,%esi
f0106040:	c1 e6 18             	shl    $0x18,%esi
f0106043:	89 d0                	mov    %edx,%eax
f0106045:	c1 e0 10             	shl    $0x10,%eax
f0106048:	09 f0                	or     %esi,%eax
f010604a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010604c:	89 d8                	mov    %ebx,%eax
f010604e:	09 d0                	or     %edx,%eax
f0106050:	c1 e9 02             	shr    $0x2,%ecx
f0106053:	fc                   	cld    
f0106054:	f3 ab                	rep stos %eax,%es:(%edi)
f0106056:	eb 06                	jmp    f010605e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0106058:	8b 45 0c             	mov    0xc(%ebp),%eax
f010605b:	fc                   	cld    
f010605c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010605e:	89 f8                	mov    %edi,%eax
f0106060:	5b                   	pop    %ebx
f0106061:	5e                   	pop    %esi
f0106062:	5f                   	pop    %edi
f0106063:	5d                   	pop    %ebp
f0106064:	c3                   	ret    

f0106065 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0106065:	55                   	push   %ebp
f0106066:	89 e5                	mov    %esp,%ebp
f0106068:	57                   	push   %edi
f0106069:	56                   	push   %esi
f010606a:	8b 45 08             	mov    0x8(%ebp),%eax
f010606d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106070:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0106073:	39 c6                	cmp    %eax,%esi
f0106075:	73 35                	jae    f01060ac <memmove+0x47>
f0106077:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010607a:	39 d0                	cmp    %edx,%eax
f010607c:	73 2e                	jae    f01060ac <memmove+0x47>
		s += n;
		d += n;
f010607e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106081:	89 d6                	mov    %edx,%esi
f0106083:	09 fe                	or     %edi,%esi
f0106085:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010608b:	75 13                	jne    f01060a0 <memmove+0x3b>
f010608d:	f6 c1 03             	test   $0x3,%cl
f0106090:	75 0e                	jne    f01060a0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0106092:	83 ef 04             	sub    $0x4,%edi
f0106095:	8d 72 fc             	lea    -0x4(%edx),%esi
f0106098:	c1 e9 02             	shr    $0x2,%ecx
f010609b:	fd                   	std    
f010609c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010609e:	eb 09                	jmp    f01060a9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01060a0:	83 ef 01             	sub    $0x1,%edi
f01060a3:	8d 72 ff             	lea    -0x1(%edx),%esi
f01060a6:	fd                   	std    
f01060a7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01060a9:	fc                   	cld    
f01060aa:	eb 1d                	jmp    f01060c9 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01060ac:	89 f2                	mov    %esi,%edx
f01060ae:	09 c2                	or     %eax,%edx
f01060b0:	f6 c2 03             	test   $0x3,%dl
f01060b3:	75 0f                	jne    f01060c4 <memmove+0x5f>
f01060b5:	f6 c1 03             	test   $0x3,%cl
f01060b8:	75 0a                	jne    f01060c4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01060ba:	c1 e9 02             	shr    $0x2,%ecx
f01060bd:	89 c7                	mov    %eax,%edi
f01060bf:	fc                   	cld    
f01060c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01060c2:	eb 05                	jmp    f01060c9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01060c4:	89 c7                	mov    %eax,%edi
f01060c6:	fc                   	cld    
f01060c7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01060c9:	5e                   	pop    %esi
f01060ca:	5f                   	pop    %edi
f01060cb:	5d                   	pop    %ebp
f01060cc:	c3                   	ret    

f01060cd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01060cd:	55                   	push   %ebp
f01060ce:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01060d0:	ff 75 10             	pushl  0x10(%ebp)
f01060d3:	ff 75 0c             	pushl  0xc(%ebp)
f01060d6:	ff 75 08             	pushl  0x8(%ebp)
f01060d9:	e8 87 ff ff ff       	call   f0106065 <memmove>
}
f01060de:	c9                   	leave  
f01060df:	c3                   	ret    

f01060e0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01060e0:	55                   	push   %ebp
f01060e1:	89 e5                	mov    %esp,%ebp
f01060e3:	56                   	push   %esi
f01060e4:	53                   	push   %ebx
f01060e5:	8b 45 08             	mov    0x8(%ebp),%eax
f01060e8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01060eb:	89 c6                	mov    %eax,%esi
f01060ed:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01060f0:	eb 1a                	jmp    f010610c <memcmp+0x2c>
		if (*s1 != *s2)
f01060f2:	0f b6 08             	movzbl (%eax),%ecx
f01060f5:	0f b6 1a             	movzbl (%edx),%ebx
f01060f8:	38 d9                	cmp    %bl,%cl
f01060fa:	74 0a                	je     f0106106 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01060fc:	0f b6 c1             	movzbl %cl,%eax
f01060ff:	0f b6 db             	movzbl %bl,%ebx
f0106102:	29 d8                	sub    %ebx,%eax
f0106104:	eb 0f                	jmp    f0106115 <memcmp+0x35>
		s1++, s2++;
f0106106:	83 c0 01             	add    $0x1,%eax
f0106109:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f010610c:	39 f0                	cmp    %esi,%eax
f010610e:	75 e2                	jne    f01060f2 <memcmp+0x12>
	}

	return 0;
f0106110:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106115:	5b                   	pop    %ebx
f0106116:	5e                   	pop    %esi
f0106117:	5d                   	pop    %ebp
f0106118:	c3                   	ret    

f0106119 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0106119:	55                   	push   %ebp
f010611a:	89 e5                	mov    %esp,%ebp
f010611c:	53                   	push   %ebx
f010611d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0106120:	89 c1                	mov    %eax,%ecx
f0106122:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0106125:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
	for (; s < ends; s++)
f0106129:	eb 0a                	jmp    f0106135 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010612b:	0f b6 10             	movzbl (%eax),%edx
f010612e:	39 da                	cmp    %ebx,%edx
f0106130:	74 07                	je     f0106139 <memfind+0x20>
	for (; s < ends; s++)
f0106132:	83 c0 01             	add    $0x1,%eax
f0106135:	39 c8                	cmp    %ecx,%eax
f0106137:	72 f2                	jb     f010612b <memfind+0x12>
			break;
	return (void *) s;
}
f0106139:	5b                   	pop    %ebx
f010613a:	5d                   	pop    %ebp
f010613b:	c3                   	ret    

f010613c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010613c:	55                   	push   %ebp
f010613d:	89 e5                	mov    %esp,%ebp
f010613f:	57                   	push   %edi
f0106140:	56                   	push   %esi
f0106141:	53                   	push   %ebx
f0106142:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106145:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106148:	eb 03                	jmp    f010614d <strtol+0x11>
		s++;
f010614a:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f010614d:	0f b6 01             	movzbl (%ecx),%eax
f0106150:	3c 20                	cmp    $0x20,%al
f0106152:	74 f6                	je     f010614a <strtol+0xe>
f0106154:	3c 09                	cmp    $0x9,%al
f0106156:	74 f2                	je     f010614a <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0106158:	3c 2b                	cmp    $0x2b,%al
f010615a:	75 0a                	jne    f0106166 <strtol+0x2a>
		s++;
f010615c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f010615f:	bf 00 00 00 00       	mov    $0x0,%edi
f0106164:	eb 11                	jmp    f0106177 <strtol+0x3b>
f0106166:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
f010616b:	3c 2d                	cmp    $0x2d,%al
f010616d:	75 08                	jne    f0106177 <strtol+0x3b>
		s++, neg = 1;
f010616f:	83 c1 01             	add    $0x1,%ecx
f0106172:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106177:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010617d:	75 15                	jne    f0106194 <strtol+0x58>
f010617f:	80 39 30             	cmpb   $0x30,(%ecx)
f0106182:	75 10                	jne    f0106194 <strtol+0x58>
f0106184:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0106188:	75 7c                	jne    f0106206 <strtol+0xca>
		s += 2, base = 16;
f010618a:	83 c1 02             	add    $0x2,%ecx
f010618d:	bb 10 00 00 00       	mov    $0x10,%ebx
f0106192:	eb 16                	jmp    f01061aa <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0106194:	85 db                	test   %ebx,%ebx
f0106196:	75 12                	jne    f01061aa <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0106198:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f010619d:	80 39 30             	cmpb   $0x30,(%ecx)
f01061a0:	75 08                	jne    f01061aa <strtol+0x6e>
		s++, base = 8;
f01061a2:	83 c1 01             	add    $0x1,%ecx
f01061a5:	bb 08 00 00 00       	mov    $0x8,%ebx
		base = 10;
f01061aa:	b8 00 00 00 00       	mov    $0x0,%eax
f01061af:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01061b2:	0f b6 11             	movzbl (%ecx),%edx
f01061b5:	8d 72 d0             	lea    -0x30(%edx),%esi
f01061b8:	89 f3                	mov    %esi,%ebx
f01061ba:	80 fb 09             	cmp    $0x9,%bl
f01061bd:	77 08                	ja     f01061c7 <strtol+0x8b>
			dig = *s - '0';
f01061bf:	0f be d2             	movsbl %dl,%edx
f01061c2:	83 ea 30             	sub    $0x30,%edx
f01061c5:	eb 22                	jmp    f01061e9 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01061c7:	8d 72 9f             	lea    -0x61(%edx),%esi
f01061ca:	89 f3                	mov    %esi,%ebx
f01061cc:	80 fb 19             	cmp    $0x19,%bl
f01061cf:	77 08                	ja     f01061d9 <strtol+0x9d>
			dig = *s - 'a' + 10;
f01061d1:	0f be d2             	movsbl %dl,%edx
f01061d4:	83 ea 57             	sub    $0x57,%edx
f01061d7:	eb 10                	jmp    f01061e9 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01061d9:	8d 72 bf             	lea    -0x41(%edx),%esi
f01061dc:	89 f3                	mov    %esi,%ebx
f01061de:	80 fb 19             	cmp    $0x19,%bl
f01061e1:	77 16                	ja     f01061f9 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01061e3:	0f be d2             	movsbl %dl,%edx
f01061e6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01061e9:	3b 55 10             	cmp    0x10(%ebp),%edx
f01061ec:	7d 0b                	jge    f01061f9 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01061ee:	83 c1 01             	add    $0x1,%ecx
f01061f1:	0f af 45 10          	imul   0x10(%ebp),%eax
f01061f5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01061f7:	eb b9                	jmp    f01061b2 <strtol+0x76>

	if (endptr)
f01061f9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01061fd:	74 0d                	je     f010620c <strtol+0xd0>
		*endptr = (char *) s;
f01061ff:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106202:	89 0e                	mov    %ecx,(%esi)
f0106204:	eb 06                	jmp    f010620c <strtol+0xd0>
	else if (base == 0 && s[0] == '0')
f0106206:	85 db                	test   %ebx,%ebx
f0106208:	74 98                	je     f01061a2 <strtol+0x66>
f010620a:	eb 9e                	jmp    f01061aa <strtol+0x6e>
	return (neg ? -val : val);
f010620c:	89 c2                	mov    %eax,%edx
f010620e:	f7 da                	neg    %edx
f0106210:	85 ff                	test   %edi,%edi
f0106212:	0f 45 c2             	cmovne %edx,%eax
}
f0106215:	5b                   	pop    %ebx
f0106216:	5e                   	pop    %esi
f0106217:	5f                   	pop    %edi
f0106218:	5d                   	pop    %ebp
f0106219:	c3                   	ret    

f010621a <strtoul>:

unsigned long
strtoul(const char *s, char **endptr, int base)
{
f010621a:	55                   	push   %ebp
f010621b:	89 e5                	mov    %esp,%ebp
f010621d:	57                   	push   %edi
f010621e:	56                   	push   %esi
f010621f:	53                   	push   %ebx
f0106220:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106223:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	unsigned long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106226:	eb 03                	jmp    f010622b <strtoul+0x11>
		s++;
f0106228:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f010622b:	0f b6 01             	movzbl (%ecx),%eax
f010622e:	3c 20                	cmp    $0x20,%al
f0106230:	74 f6                	je     f0106228 <strtoul+0xe>
f0106232:	3c 09                	cmp    $0x9,%al
f0106234:	74 f2                	je     f0106228 <strtoul+0xe>

	// plus/minus sign
	if (*s == '+')
f0106236:	3c 2b                	cmp    $0x2b,%al
f0106238:	75 0a                	jne    f0106244 <strtoul+0x2a>
		s++;
f010623a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f010623d:	bf 00 00 00 00       	mov    $0x0,%edi
f0106242:	eb 11                	jmp    f0106255 <strtoul+0x3b>
f0106244:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
f0106249:	3c 2d                	cmp    $0x2d,%al
f010624b:	75 08                	jne    f0106255 <strtoul+0x3b>
		s++, neg = 1;
f010624d:	83 c1 01             	add    $0x1,%ecx
f0106250:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106255:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010625b:	75 15                	jne    f0106272 <strtoul+0x58>
f010625d:	80 39 30             	cmpb   $0x30,(%ecx)
f0106260:	75 10                	jne    f0106272 <strtoul+0x58>
f0106262:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0106266:	75 7c                	jne    f01062e4 <strtoul+0xca>
		s += 2, base = 16;
f0106268:	83 c1 02             	add    $0x2,%ecx
f010626b:	bb 10 00 00 00       	mov    $0x10,%ebx
f0106270:	eb 16                	jmp    f0106288 <strtoul+0x6e>
	else if (base == 0 && s[0] == '0')
f0106272:	85 db                	test   %ebx,%ebx
f0106274:	75 12                	jne    f0106288 <strtoul+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0106276:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f010627b:	80 39 30             	cmpb   $0x30,(%ecx)
f010627e:	75 08                	jne    f0106288 <strtoul+0x6e>
		s++, base = 8;
f0106280:	83 c1 01             	add    $0x1,%ecx
f0106283:	bb 08 00 00 00       	mov    $0x8,%ebx
		base = 10;
f0106288:	b8 00 00 00 00       	mov    $0x0,%eax
f010628d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0106290:	0f b6 11             	movzbl (%ecx),%edx
f0106293:	8d 72 d0             	lea    -0x30(%edx),%esi
f0106296:	89 f3                	mov    %esi,%ebx
f0106298:	80 fb 09             	cmp    $0x9,%bl
f010629b:	77 08                	ja     f01062a5 <strtoul+0x8b>
			dig = *s - '0';
f010629d:	0f be d2             	movsbl %dl,%edx
f01062a0:	83 ea 30             	sub    $0x30,%edx
f01062a3:	eb 22                	jmp    f01062c7 <strtoul+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01062a5:	8d 72 9f             	lea    -0x61(%edx),%esi
f01062a8:	89 f3                	mov    %esi,%ebx
f01062aa:	80 fb 19             	cmp    $0x19,%bl
f01062ad:	77 08                	ja     f01062b7 <strtoul+0x9d>
			dig = *s - 'a' + 10;
f01062af:	0f be d2             	movsbl %dl,%edx
f01062b2:	83 ea 57             	sub    $0x57,%edx
f01062b5:	eb 10                	jmp    f01062c7 <strtoul+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01062b7:	8d 72 bf             	lea    -0x41(%edx),%esi
f01062ba:	89 f3                	mov    %esi,%ebx
f01062bc:	80 fb 19             	cmp    $0x19,%bl
f01062bf:	77 16                	ja     f01062d7 <strtoul+0xbd>
			dig = *s - 'A' + 10;
f01062c1:	0f be d2             	movsbl %dl,%edx
f01062c4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01062c7:	3b 55 10             	cmp    0x10(%ebp),%edx
f01062ca:	7d 0b                	jge    f01062d7 <strtoul+0xbd>
			break;
		s++, val = (val * base) + dig;
f01062cc:	83 c1 01             	add    $0x1,%ecx
f01062cf:	0f af 45 10          	imul   0x10(%ebp),%eax
f01062d3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01062d5:	eb b9                	jmp    f0106290 <strtoul+0x76>

	if (endptr)
f01062d7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01062db:	74 0d                	je     f01062ea <strtoul+0xd0>
		*endptr = (char *) s;
f01062dd:	8b 75 0c             	mov    0xc(%ebp),%esi
f01062e0:	89 0e                	mov    %ecx,(%esi)
f01062e2:	eb 06                	jmp    f01062ea <strtoul+0xd0>
	else if (base == 0 && s[0] == '0')
f01062e4:	85 db                	test   %ebx,%ebx
f01062e6:	74 98                	je     f0106280 <strtoul+0x66>
f01062e8:	eb 9e                	jmp    f0106288 <strtoul+0x6e>
	return (neg ? -val : val);
f01062ea:	89 c2                	mov    %eax,%edx
f01062ec:	f7 da                	neg    %edx
f01062ee:	85 ff                	test   %edi,%edi
f01062f0:	0f 45 c2             	cmovne %edx,%eax
}
f01062f3:	5b                   	pop    %ebx
f01062f4:	5e                   	pop    %esi
f01062f5:	5f                   	pop    %edi
f01062f6:	5d                   	pop    %ebp
f01062f7:	c3                   	ret    

f01062f8 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01062f8:	fa                   	cli    

	xorw    %ax, %ax
f01062f9:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01062fb:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01062fd:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01062ff:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0106301:	0f 01 16             	lgdtl  (%esi)
f0106304:	74 70                	je     f0106376 <mpsearch1+0x3>
	movl    %cr0, %eax
f0106306:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0106309:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f010630d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0106310:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0106316:	08 00                	or     %al,(%eax)

f0106318 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106318:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f010631c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010631e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106320:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0106322:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0106326:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106328:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010632a:	b8 00 10 12 00       	mov    $0x121000,%eax
	movl    %eax, %cr3
f010632f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0106332:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0106335:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010633a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f010633d:	8b 25 84 5e 2a f0    	mov    0xf02a5e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0106343:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106348:	b8 92 02 10 f0       	mov    $0xf0100292,%eax
	call    *%eax
f010634d:	ff d0                	call   *%eax

f010634f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010634f:	eb fe                	jmp    f010634f <spin>
f0106351:	8d 76 00             	lea    0x0(%esi),%esi

f0106354 <gdt>:
	...
f010635c:	ff                   	(bad)  
f010635d:	ff 00                	incl   (%eax)
f010635f:	00 00                	add    %al,(%eax)
f0106361:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106368:	00                   	.byte 0x0
f0106369:	92                   	xchg   %eax,%edx
f010636a:	cf                   	iret   
	...

f010636c <gdtdesc>:
f010636c:	17                   	pop    %ss
f010636d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0106372 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0106372:	90                   	nop

f0106373 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106373:	55                   	push   %ebp
f0106374:	89 e5                	mov    %esp,%ebp
f0106376:	57                   	push   %edi
f0106377:	56                   	push   %esi
f0106378:	53                   	push   %ebx
f0106379:	83 ec 0c             	sub    $0xc,%esp
	if (PGNUM(pa) >= npages)
f010637c:	8b 0d 88 5e 2a f0    	mov    0xf02a5e88,%ecx
f0106382:	89 c3                	mov    %eax,%ebx
f0106384:	c1 eb 0c             	shr    $0xc,%ebx
f0106387:	39 cb                	cmp    %ecx,%ebx
f0106389:	73 1a                	jae    f01063a5 <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f010638b:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0106391:	8d 34 02             	lea    (%edx,%eax,1),%esi
	if (PGNUM(pa) >= npages)
f0106394:	89 f0                	mov    %esi,%eax
f0106396:	c1 e8 0c             	shr    $0xc,%eax
f0106399:	39 c8                	cmp    %ecx,%eax
f010639b:	73 1a                	jae    f01063b7 <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f010639d:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f01063a3:	eb 27                	jmp    f01063cc <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01063a5:	50                   	push   %eax
f01063a6:	68 a8 6e 10 f0       	push   $0xf0106ea8
f01063ab:	6a 57                	push   $0x57
f01063ad:	68 bd 8c 10 f0       	push   $0xf0108cbd
f01063b2:	e8 dd 9c ff ff       	call   f0100094 <_panic>
f01063b7:	56                   	push   %esi
f01063b8:	68 a8 6e 10 f0       	push   $0xf0106ea8
f01063bd:	6a 57                	push   $0x57
f01063bf:	68 bd 8c 10 f0       	push   $0xf0108cbd
f01063c4:	e8 cb 9c ff ff       	call   f0100094 <_panic>
f01063c9:	83 c3 10             	add    $0x10,%ebx
f01063cc:	39 f3                	cmp    %esi,%ebx
f01063ce:	73 2c                	jae    f01063fc <mpsearch1+0x89>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01063d0:	83 ec 04             	sub    $0x4,%esp
f01063d3:	6a 04                	push   $0x4
f01063d5:	68 cd 8c 10 f0       	push   $0xf0108ccd
f01063da:	53                   	push   %ebx
f01063db:	e8 00 fd ff ff       	call   f01060e0 <memcmp>
f01063e0:	83 c4 10             	add    $0x10,%esp
f01063e3:	85 c0                	test   %eax,%eax
f01063e5:	75 e2                	jne    f01063c9 <mpsearch1+0x56>
f01063e7:	89 da                	mov    %ebx,%edx
f01063e9:	8d 7b 10             	lea    0x10(%ebx),%edi
		sum += ((uint8_t *)addr)[i];
f01063ec:	0f b6 0a             	movzbl (%edx),%ecx
f01063ef:	01 c8                	add    %ecx,%eax
f01063f1:	42                   	inc    %edx
	for (i = 0; i < len; i++)
f01063f2:	39 fa                	cmp    %edi,%edx
f01063f4:	75 f6                	jne    f01063ec <mpsearch1+0x79>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01063f6:	84 c0                	test   %al,%al
f01063f8:	75 cf                	jne    f01063c9 <mpsearch1+0x56>
f01063fa:	eb 05                	jmp    f0106401 <mpsearch1+0x8e>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01063fc:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0106401:	89 d8                	mov    %ebx,%eax
f0106403:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106406:	5b                   	pop    %ebx
f0106407:	5e                   	pop    %esi
f0106408:	5f                   	pop    %edi
f0106409:	5d                   	pop    %ebp
f010640a:	c3                   	ret    

f010640b <mp_init>:
	return conf;
}

void
mp_init(void)
{
f010640b:	55                   	push   %ebp
f010640c:	89 e5                	mov    %esp,%ebp
f010640e:	57                   	push   %edi
f010640f:	56                   	push   %esi
f0106410:	53                   	push   %ebx
f0106411:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106414:	c7 05 c0 63 2a f0 20 	movl   $0xf02a6020,0xf02a63c0
f010641b:	60 2a f0 
	if (PGNUM(pa) >= npages)
f010641e:	83 3d 88 5e 2a f0 00 	cmpl   $0x0,0xf02a5e88
f0106425:	0f 84 84 00 00 00    	je     f01064af <mp_init+0xa4>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010642b:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106432:	85 c0                	test   %eax,%eax
f0106434:	0f 84 8b 00 00 00    	je     f01064c5 <mp_init+0xba>
		p <<= 4;	// Translate from segment to PA
f010643a:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f010643d:	ba 00 04 00 00       	mov    $0x400,%edx
f0106442:	e8 2c ff ff ff       	call   f0106373 <mpsearch1>
f0106447:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010644a:	85 c0                	test   %eax,%eax
f010644c:	0f 84 97 00 00 00    	je     f01064e9 <mp_init+0xde>
	if (mp->physaddr == 0 || mp->type != 0) {
f0106452:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106455:	8b 70 04             	mov    0x4(%eax),%esi
f0106458:	85 f6                	test   %esi,%esi
f010645a:	0f 84 a8 00 00 00    	je     f0106508 <mp_init+0xfd>
f0106460:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0106464:	0f 85 9e 00 00 00    	jne    f0106508 <mp_init+0xfd>
f010646a:	89 f0                	mov    %esi,%eax
f010646c:	c1 e8 0c             	shr    $0xc,%eax
f010646f:	3b 05 88 5e 2a f0    	cmp    0xf02a5e88,%eax
f0106475:	0f 83 a2 00 00 00    	jae    f010651d <mp_init+0x112>
	return (void *)(pa + KERNBASE);
f010647b:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
f0106481:	89 df                	mov    %ebx,%edi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106483:	83 ec 04             	sub    $0x4,%esp
f0106486:	6a 04                	push   $0x4
f0106488:	68 d2 8c 10 f0       	push   $0xf0108cd2
f010648d:	53                   	push   %ebx
f010648e:	e8 4d fc ff ff       	call   f01060e0 <memcmp>
f0106493:	83 c4 10             	add    $0x10,%esp
f0106496:	85 c0                	test   %eax,%eax
f0106498:	0f 85 94 00 00 00    	jne    f0106532 <mp_init+0x127>
f010649e:	0f b7 53 04          	movzwl 0x4(%ebx),%edx
f01064a2:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
f01064a5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	sum = 0;
f01064a8:	89 c2                	mov    %eax,%edx
f01064aa:	e9 9e 00 00 00       	jmp    f010654d <mp_init+0x142>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01064af:	68 00 04 00 00       	push   $0x400
f01064b4:	68 a8 6e 10 f0       	push   $0xf0106ea8
f01064b9:	6a 6f                	push   $0x6f
f01064bb:	68 bd 8c 10 f0       	push   $0xf0108cbd
f01064c0:	e8 cf 9b ff ff       	call   f0100094 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f01064c5:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01064cc:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f01064cf:	2d 00 04 00 00       	sub    $0x400,%eax
f01064d4:	ba 00 04 00 00       	mov    $0x400,%edx
f01064d9:	e8 95 fe ff ff       	call   f0106373 <mpsearch1>
f01064de:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01064e1:	85 c0                	test   %eax,%eax
f01064e3:	0f 85 69 ff ff ff    	jne    f0106452 <mp_init+0x47>
	return mpsearch1(0xF0000, 0x10000);
f01064e9:	ba 00 00 01 00       	mov    $0x10000,%edx
f01064ee:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01064f3:	e8 7b fe ff ff       	call   f0106373 <mpsearch1>
f01064f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	if ((mp = mpsearch()) == 0)
f01064fb:	85 c0                	test   %eax,%eax
f01064fd:	0f 85 4f ff ff ff    	jne    f0106452 <mp_init+0x47>
f0106503:	e9 b3 01 00 00       	jmp    f01066bb <mp_init+0x2b0>
		cprintf("SMP: Default configurations not implemented\n");
f0106508:	83 ec 0c             	sub    $0xc,%esp
f010650b:	68 30 8b 10 f0       	push   $0xf0108b30
f0106510:	e8 84 da ff ff       	call   f0103f99 <cprintf>
f0106515:	83 c4 10             	add    $0x10,%esp
f0106518:	e9 9e 01 00 00       	jmp    f01066bb <mp_init+0x2b0>
f010651d:	56                   	push   %esi
f010651e:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0106523:	68 90 00 00 00       	push   $0x90
f0106528:	68 bd 8c 10 f0       	push   $0xf0108cbd
f010652d:	e8 62 9b ff ff       	call   f0100094 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106532:	83 ec 0c             	sub    $0xc,%esp
f0106535:	68 60 8b 10 f0       	push   $0xf0108b60
f010653a:	e8 5a da ff ff       	call   f0103f99 <cprintf>
f010653f:	83 c4 10             	add    $0x10,%esp
f0106542:	e9 74 01 00 00       	jmp    f01066bb <mp_init+0x2b0>
		sum += ((uint8_t *)addr)[i];
f0106547:	0f b6 0b             	movzbl (%ebx),%ecx
f010654a:	01 ca                	add    %ecx,%edx
f010654c:	43                   	inc    %ebx
	for (i = 0; i < len; i++)
f010654d:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0106550:	75 f5                	jne    f0106547 <mp_init+0x13c>
	if (sum(conf, conf->length) != 0) {
f0106552:	84 d2                	test   %dl,%dl
f0106554:	75 15                	jne    f010656b <mp_init+0x160>
	if (conf->version != 1 && conf->version != 4) {
f0106556:	8a 57 06             	mov    0x6(%edi),%dl
f0106559:	80 fa 01             	cmp    $0x1,%dl
f010655c:	74 05                	je     f0106563 <mp_init+0x158>
f010655e:	80 fa 04             	cmp    $0x4,%dl
f0106561:	75 1d                	jne    f0106580 <mp_init+0x175>
f0106563:	0f b7 4f 28          	movzwl 0x28(%edi),%ecx
f0106567:	01 d9                	add    %ebx,%ecx
f0106569:	eb 34                	jmp    f010659f <mp_init+0x194>
		cprintf("SMP: Bad MP configuration checksum\n");
f010656b:	83 ec 0c             	sub    $0xc,%esp
f010656e:	68 94 8b 10 f0       	push   $0xf0108b94
f0106573:	e8 21 da ff ff       	call   f0103f99 <cprintf>
f0106578:	83 c4 10             	add    $0x10,%esp
f010657b:	e9 3b 01 00 00       	jmp    f01066bb <mp_init+0x2b0>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106580:	83 ec 08             	sub    $0x8,%esp
f0106583:	0f b6 d2             	movzbl %dl,%edx
f0106586:	52                   	push   %edx
f0106587:	68 b8 8b 10 f0       	push   $0xf0108bb8
f010658c:	e8 08 da ff ff       	call   f0103f99 <cprintf>
f0106591:	83 c4 10             	add    $0x10,%esp
f0106594:	e9 22 01 00 00       	jmp    f01066bb <mp_init+0x2b0>
		sum += ((uint8_t *)addr)[i];
f0106599:	0f b6 13             	movzbl (%ebx),%edx
f010659c:	01 d0                	add    %edx,%eax
f010659e:	43                   	inc    %ebx
	for (i = 0; i < len; i++)
f010659f:	39 d9                	cmp    %ebx,%ecx
f01065a1:	75 f6                	jne    f0106599 <mp_init+0x18e>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01065a3:	02 47 2a             	add    0x2a(%edi),%al
f01065a6:	75 28                	jne    f01065d0 <mp_init+0x1c5>
	if ((conf = mpconfig(&mp)) == 0)
f01065a8:	81 fe 00 00 00 10    	cmp    $0x10000000,%esi
f01065ae:	0f 84 07 01 00 00    	je     f01066bb <mp_init+0x2b0>
		return;
	ismp = 1;
f01065b4:	c7 05 00 60 2a f0 01 	movl   $0x1,0xf02a6000
f01065bb:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01065be:	8b 47 24             	mov    0x24(%edi),%eax
f01065c1:	a3 00 70 2e f0       	mov    %eax,0xf02e7000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01065c6:	8d 77 2c             	lea    0x2c(%edi),%esi
f01065c9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01065ce:	eb 60                	jmp    f0106630 <mp_init+0x225>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01065d0:	83 ec 0c             	sub    $0xc,%esp
f01065d3:	68 d8 8b 10 f0       	push   $0xf0108bd8
f01065d8:	e8 bc d9 ff ff       	call   f0103f99 <cprintf>
f01065dd:	83 c4 10             	add    $0x10,%esp
f01065e0:	e9 d6 00 00 00       	jmp    f01066bb <mp_init+0x2b0>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01065e5:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f01065e9:	74 1e                	je     f0106609 <mp_init+0x1fe>
				bootcpu = &cpus[ncpu];
f01065eb:	8b 15 c4 63 2a f0    	mov    0xf02a63c4,%edx
f01065f1:	8d 04 12             	lea    (%edx,%edx,1),%eax
f01065f4:	01 d0                	add    %edx,%eax
f01065f6:	01 c0                	add    %eax,%eax
f01065f8:	01 d0                	add    %edx,%eax
f01065fa:	8d 04 82             	lea    (%edx,%eax,4),%eax
f01065fd:	8d 04 85 20 60 2a f0 	lea    -0xfd59fe0(,%eax,4),%eax
f0106604:	a3 c0 63 2a f0       	mov    %eax,0xf02a63c0
			if (ncpu < NCPU) {
f0106609:	a1 c4 63 2a f0       	mov    0xf02a63c4,%eax
f010660e:	83 f8 07             	cmp    $0x7,%eax
f0106611:	7f 34                	jg     f0106647 <mp_init+0x23c>
				cpus[ncpu].cpu_id = ncpu;
f0106613:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0106616:	01 c2                	add    %eax,%edx
f0106618:	01 d2                	add    %edx,%edx
f010661a:	01 c2                	add    %eax,%edx
f010661c:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010661f:	88 04 95 20 60 2a f0 	mov    %al,-0xfd59fe0(,%edx,4)
				ncpu++;
f0106626:	40                   	inc    %eax
f0106627:	a3 c4 63 2a f0       	mov    %eax,0xf02a63c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f010662c:	83 c6 14             	add    $0x14,%esi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010662f:	43                   	inc    %ebx
f0106630:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f0106634:	39 d8                	cmp    %ebx,%eax
f0106636:	76 4a                	jbe    f0106682 <mp_init+0x277>
		switch (*p) {
f0106638:	8a 06                	mov    (%esi),%al
f010663a:	84 c0                	test   %al,%al
f010663c:	74 a7                	je     f01065e5 <mp_init+0x1da>
f010663e:	3c 04                	cmp    $0x4,%al
f0106640:	77 1c                	ja     f010665e <mp_init+0x253>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106642:	83 c6 08             	add    $0x8,%esi
			continue;
f0106645:	eb e8                	jmp    f010662f <mp_init+0x224>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106647:	83 ec 08             	sub    $0x8,%esp
f010664a:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f010664e:	50                   	push   %eax
f010664f:	68 08 8c 10 f0       	push   $0xf0108c08
f0106654:	e8 40 d9 ff ff       	call   f0103f99 <cprintf>
f0106659:	83 c4 10             	add    $0x10,%esp
f010665c:	eb ce                	jmp    f010662c <mp_init+0x221>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010665e:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0106661:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f0106664:	50                   	push   %eax
f0106665:	68 30 8c 10 f0       	push   $0xf0108c30
f010666a:	e8 2a d9 ff ff       	call   f0103f99 <cprintf>
			ismp = 0;
f010666f:	c7 05 00 60 2a f0 00 	movl   $0x0,0xf02a6000
f0106676:	00 00 00 
			i = conf->entry;
f0106679:	0f b7 5f 22          	movzwl 0x22(%edi),%ebx
f010667d:	83 c4 10             	add    $0x10,%esp
f0106680:	eb ad                	jmp    f010662f <mp_init+0x224>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106682:	a1 c0 63 2a f0       	mov    0xf02a63c0,%eax
f0106687:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010668e:	83 3d 00 60 2a f0 00 	cmpl   $0x0,0xf02a6000
f0106695:	75 2c                	jne    f01066c3 <mp_init+0x2b8>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106697:	c7 05 c4 63 2a f0 01 	movl   $0x1,0xf02a63c4
f010669e:	00 00 00 
		lapicaddr = 0;
f01066a1:	c7 05 00 70 2e f0 00 	movl   $0x0,0xf02e7000
f01066a8:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01066ab:	83 ec 0c             	sub    $0xc,%esp
f01066ae:	68 50 8c 10 f0       	push   $0xf0108c50
f01066b3:	e8 e1 d8 ff ff       	call   f0103f99 <cprintf>
		return;
f01066b8:	83 c4 10             	add    $0x10,%esp
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f01066bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01066be:	5b                   	pop    %ebx
f01066bf:	5e                   	pop    %esi
f01066c0:	5f                   	pop    %edi
f01066c1:	5d                   	pop    %ebp
f01066c2:	c3                   	ret    
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01066c3:	83 ec 04             	sub    $0x4,%esp
f01066c6:	ff 35 c4 63 2a f0    	pushl  0xf02a63c4
f01066cc:	0f b6 00             	movzbl (%eax),%eax
f01066cf:	50                   	push   %eax
f01066d0:	68 d7 8c 10 f0       	push   $0xf0108cd7
f01066d5:	e8 bf d8 ff ff       	call   f0103f99 <cprintf>
	if (mp->imcrp) {
f01066da:	83 c4 10             	add    $0x10,%esp
f01066dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01066e0:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01066e4:	74 d5                	je     f01066bb <mp_init+0x2b0>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01066e6:	83 ec 0c             	sub    $0xc,%esp
f01066e9:	68 7c 8c 10 f0       	push   $0xf0108c7c
f01066ee:	e8 a6 d8 ff ff       	call   f0103f99 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01066f3:	b0 70                	mov    $0x70,%al
f01066f5:	ba 22 00 00 00       	mov    $0x22,%edx
f01066fa:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01066fb:	ba 23 00 00 00       	mov    $0x23,%edx
f0106700:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0106701:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106704:	ee                   	out    %al,(%dx)
f0106705:	83 c4 10             	add    $0x10,%esp
f0106708:	eb b1                	jmp    f01066bb <mp_init+0x2b0>

f010670a <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f010670a:	55                   	push   %ebp
f010670b:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f010670d:	8b 0d 04 70 2e f0    	mov    0xf02e7004,%ecx
f0106713:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0106716:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106718:	a1 04 70 2e f0       	mov    0xf02e7004,%eax
f010671d:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106720:	5d                   	pop    %ebp
f0106721:	c3                   	ret    

f0106722 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106722:	55                   	push   %ebp
f0106723:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106725:	a1 04 70 2e f0       	mov    0xf02e7004,%eax
f010672a:	85 c0                	test   %eax,%eax
f010672c:	74 08                	je     f0106736 <cpunum+0x14>
		return lapic[ID] >> 24;
f010672e:	8b 40 20             	mov    0x20(%eax),%eax
f0106731:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f0106734:	5d                   	pop    %ebp
f0106735:	c3                   	ret    
	return 0;
f0106736:	b8 00 00 00 00       	mov    $0x0,%eax
f010673b:	eb f7                	jmp    f0106734 <cpunum+0x12>

f010673d <lapic_init>:
	if (!lapicaddr)
f010673d:	a1 00 70 2e f0       	mov    0xf02e7000,%eax
f0106742:	85 c0                	test   %eax,%eax
f0106744:	75 01                	jne    f0106747 <lapic_init+0xa>
f0106746:	c3                   	ret    
{
f0106747:	55                   	push   %ebp
f0106748:	89 e5                	mov    %esp,%ebp
f010674a:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f010674d:	68 00 10 00 00       	push   $0x1000
f0106752:	50                   	push   %eax
f0106753:	e8 84 b0 ff ff       	call   f01017dc <mmio_map_region>
f0106758:	a3 04 70 2e f0       	mov    %eax,0xf02e7004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010675d:	ba 27 01 00 00       	mov    $0x127,%edx
f0106762:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106767:	e8 9e ff ff ff       	call   f010670a <lapicw>
	lapicw(TDCR, X1);
f010676c:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106771:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106776:	e8 8f ff ff ff       	call   f010670a <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010677b:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106780:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106785:	e8 80 ff ff ff       	call   f010670a <lapicw>
	lapicw(TICR, 10000000); 
f010678a:	ba 80 96 98 00       	mov    $0x989680,%edx
f010678f:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106794:	e8 71 ff ff ff       	call   f010670a <lapicw>
	if (thiscpu != bootcpu)
f0106799:	e8 84 ff ff ff       	call   f0106722 <cpunum>
f010679e:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01067a1:	01 c2                	add    %eax,%edx
f01067a3:	01 d2                	add    %edx,%edx
f01067a5:	01 c2                	add    %eax,%edx
f01067a7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01067aa:	8d 04 85 20 60 2a f0 	lea    -0xfd59fe0(,%eax,4),%eax
f01067b1:	83 c4 10             	add    $0x10,%esp
f01067b4:	39 05 c0 63 2a f0    	cmp    %eax,0xf02a63c0
f01067ba:	74 0f                	je     f01067cb <lapic_init+0x8e>
		lapicw(LINT0, MASKED);
f01067bc:	ba 00 00 01 00       	mov    $0x10000,%edx
f01067c1:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01067c6:	e8 3f ff ff ff       	call   f010670a <lapicw>
	lapicw(LINT1, MASKED);
f01067cb:	ba 00 00 01 00       	mov    $0x10000,%edx
f01067d0:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01067d5:	e8 30 ff ff ff       	call   f010670a <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01067da:	a1 04 70 2e f0       	mov    0xf02e7004,%eax
f01067df:	8b 40 30             	mov    0x30(%eax),%eax
f01067e2:	c1 e8 10             	shr    $0x10,%eax
f01067e5:	3c 03                	cmp    $0x3,%al
f01067e7:	77 7c                	ja     f0106865 <lapic_init+0x128>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01067e9:	ba 33 00 00 00       	mov    $0x33,%edx
f01067ee:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01067f3:	e8 12 ff ff ff       	call   f010670a <lapicw>
	lapicw(ESR, 0);
f01067f8:	ba 00 00 00 00       	mov    $0x0,%edx
f01067fd:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106802:	e8 03 ff ff ff       	call   f010670a <lapicw>
	lapicw(ESR, 0);
f0106807:	ba 00 00 00 00       	mov    $0x0,%edx
f010680c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106811:	e8 f4 fe ff ff       	call   f010670a <lapicw>
	lapicw(EOI, 0);
f0106816:	ba 00 00 00 00       	mov    $0x0,%edx
f010681b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106820:	e8 e5 fe ff ff       	call   f010670a <lapicw>
	lapicw(ICRHI, 0);
f0106825:	ba 00 00 00 00       	mov    $0x0,%edx
f010682a:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010682f:	e8 d6 fe ff ff       	call   f010670a <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106834:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106839:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010683e:	e8 c7 fe ff ff       	call   f010670a <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106843:	8b 15 04 70 2e f0    	mov    0xf02e7004,%edx
f0106849:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010684f:	f6 c4 10             	test   $0x10,%ah
f0106852:	75 f5                	jne    f0106849 <lapic_init+0x10c>
	lapicw(TPR, 0);
f0106854:	ba 00 00 00 00       	mov    $0x0,%edx
f0106859:	b8 20 00 00 00       	mov    $0x20,%eax
f010685e:	e8 a7 fe ff ff       	call   f010670a <lapicw>
}
f0106863:	c9                   	leave  
f0106864:	c3                   	ret    
		lapicw(PCINT, MASKED);
f0106865:	ba 00 00 01 00       	mov    $0x10000,%edx
f010686a:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010686f:	e8 96 fe ff ff       	call   f010670a <lapicw>
f0106874:	e9 70 ff ff ff       	jmp    f01067e9 <lapic_init+0xac>

f0106879 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0106879:	83 3d 04 70 2e f0 00 	cmpl   $0x0,0xf02e7004
f0106880:	74 14                	je     f0106896 <lapic_eoi+0x1d>
{
f0106882:	55                   	push   %ebp
f0106883:	89 e5                	mov    %esp,%ebp
		lapicw(EOI, 0);
f0106885:	ba 00 00 00 00       	mov    $0x0,%edx
f010688a:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010688f:	e8 76 fe ff ff       	call   f010670a <lapicw>
}
f0106894:	5d                   	pop    %ebp
f0106895:	c3                   	ret    
f0106896:	c3                   	ret    

f0106897 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106897:	55                   	push   %ebp
f0106898:	89 e5                	mov    %esp,%ebp
f010689a:	56                   	push   %esi
f010689b:	53                   	push   %ebx
f010689c:	8b 75 08             	mov    0x8(%ebp),%esi
f010689f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01068a2:	b0 0f                	mov    $0xf,%al
f01068a4:	ba 70 00 00 00       	mov    $0x70,%edx
f01068a9:	ee                   	out    %al,(%dx)
f01068aa:	b0 0a                	mov    $0xa,%al
f01068ac:	ba 71 00 00 00       	mov    $0x71,%edx
f01068b1:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f01068b2:	83 3d 88 5e 2a f0 00 	cmpl   $0x0,0xf02a5e88
f01068b9:	74 7e                	je     f0106939 <lapic_startap+0xa2>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01068bb:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01068c2:	00 00 
	wrv[1] = addr >> 4;
f01068c4:	89 d8                	mov    %ebx,%eax
f01068c6:	c1 e8 04             	shr    $0x4,%eax
f01068c9:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01068cf:	c1 e6 18             	shl    $0x18,%esi
f01068d2:	89 f2                	mov    %esi,%edx
f01068d4:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01068d9:	e8 2c fe ff ff       	call   f010670a <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01068de:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01068e3:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01068e8:	e8 1d fe ff ff       	call   f010670a <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01068ed:	ba 00 85 00 00       	mov    $0x8500,%edx
f01068f2:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01068f7:	e8 0e fe ff ff       	call   f010670a <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01068fc:	c1 eb 0c             	shr    $0xc,%ebx
f01068ff:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f0106902:	89 f2                	mov    %esi,%edx
f0106904:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106909:	e8 fc fd ff ff       	call   f010670a <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010690e:	89 da                	mov    %ebx,%edx
f0106910:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106915:	e8 f0 fd ff ff       	call   f010670a <lapicw>
		lapicw(ICRHI, apicid << 24);
f010691a:	89 f2                	mov    %esi,%edx
f010691c:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106921:	e8 e4 fd ff ff       	call   f010670a <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106926:	89 da                	mov    %ebx,%edx
f0106928:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010692d:	e8 d8 fd ff ff       	call   f010670a <lapicw>
		microdelay(200);
	}
}
f0106932:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106935:	5b                   	pop    %ebx
f0106936:	5e                   	pop    %esi
f0106937:	5d                   	pop    %ebp
f0106938:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106939:	68 67 04 00 00       	push   $0x467
f010693e:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0106943:	68 98 00 00 00       	push   $0x98
f0106948:	68 f4 8c 10 f0       	push   $0xf0108cf4
f010694d:	e8 42 97 ff ff       	call   f0100094 <_panic>

f0106952 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106952:	55                   	push   %ebp
f0106953:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106955:	8b 55 08             	mov    0x8(%ebp),%edx
f0106958:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f010695e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106963:	e8 a2 fd ff ff       	call   f010670a <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106968:	8b 15 04 70 2e f0    	mov    0xf02e7004,%edx
f010696e:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106974:	f6 c4 10             	test   $0x10,%ah
f0106977:	75 f5                	jne    f010696e <lapic_ipi+0x1c>
		;
}
f0106979:	5d                   	pop    %ebp
f010697a:	c3                   	ret    

f010697b <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010697b:	55                   	push   %ebp
f010697c:	89 e5                	mov    %esp,%ebp
f010697e:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106981:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106987:	8b 55 0c             	mov    0xc(%ebp),%edx
f010698a:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010698d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106994:	5d                   	pop    %ebp
f0106995:	c3                   	ret    

f0106996 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106996:	55                   	push   %ebp
f0106997:	89 e5                	mov    %esp,%ebp
f0106999:	56                   	push   %esi
f010699a:	53                   	push   %ebx
f010699b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f010699e:	83 3b 00             	cmpl   $0x0,(%ebx)
f01069a1:	75 07                	jne    f01069aa <spin_lock+0x14>
	asm volatile("lock; xchgl %0, %1"
f01069a3:	ba 01 00 00 00       	mov    $0x1,%edx
f01069a8:	eb 3f                	jmp    f01069e9 <spin_lock+0x53>
f01069aa:	8b 73 08             	mov    0x8(%ebx),%esi
f01069ad:	e8 70 fd ff ff       	call   f0106722 <cpunum>
f01069b2:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01069b5:	01 c2                	add    %eax,%edx
f01069b7:	01 d2                	add    %edx,%edx
f01069b9:	01 c2                	add    %eax,%edx
f01069bb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01069be:	8d 04 85 20 60 2a f0 	lea    -0xfd59fe0(,%eax,4),%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01069c5:	39 c6                	cmp    %eax,%esi
f01069c7:	75 da                	jne    f01069a3 <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01069c9:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01069cc:	e8 51 fd ff ff       	call   f0106722 <cpunum>
f01069d1:	83 ec 0c             	sub    $0xc,%esp
f01069d4:	53                   	push   %ebx
f01069d5:	50                   	push   %eax
f01069d6:	68 04 8d 10 f0       	push   $0xf0108d04
f01069db:	6a 41                	push   $0x41
f01069dd:	68 68 8d 10 f0       	push   $0xf0108d68
f01069e2:	e8 ad 96 ff ff       	call   f0100094 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01069e7:	f3 90                	pause  
f01069e9:	89 d0                	mov    %edx,%eax
f01069eb:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f01069ee:	85 c0                	test   %eax,%eax
f01069f0:	75 f5                	jne    f01069e7 <spin_lock+0x51>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01069f2:	e8 2b fd ff ff       	call   f0106722 <cpunum>
f01069f7:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01069fa:	01 c2                	add    %eax,%edx
f01069fc:	01 d2                	add    %edx,%edx
f01069fe:	01 c2                	add    %eax,%edx
f0106a00:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106a03:	8d 04 85 20 60 2a f0 	lea    -0xfd59fe0(,%eax,4),%eax
f0106a0a:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106a0d:	83 c3 0c             	add    $0xc,%ebx
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0106a10:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0106a12:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106a17:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106a1d:	76 1d                	jbe    f0106a3c <spin_lock+0xa6>
		pcs[i] = ebp[1];          // saved %eip
f0106a1f:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106a22:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106a25:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f0106a27:	40                   	inc    %eax
f0106a28:	83 f8 0a             	cmp    $0xa,%eax
f0106a2b:	75 ea                	jne    f0106a17 <spin_lock+0x81>
#endif
}
f0106a2d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106a30:	5b                   	pop    %ebx
f0106a31:	5e                   	pop    %esi
f0106a32:	5d                   	pop    %ebp
f0106a33:	c3                   	ret    
		pcs[i] = 0;
f0106a34:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
	for (; i < 10; i++)
f0106a3b:	40                   	inc    %eax
f0106a3c:	83 f8 09             	cmp    $0x9,%eax
f0106a3f:	7e f3                	jle    f0106a34 <spin_lock+0x9e>
f0106a41:	eb ea                	jmp    f0106a2d <spin_lock+0x97>

f0106a43 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106a43:	55                   	push   %ebp
f0106a44:	89 e5                	mov    %esp,%ebp
f0106a46:	57                   	push   %edi
f0106a47:	56                   	push   %esi
f0106a48:	53                   	push   %ebx
f0106a49:	83 ec 4c             	sub    $0x4c,%esp
f0106a4c:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f0106a4f:	83 3e 00             	cmpl   $0x0,(%esi)
f0106a52:	75 35                	jne    f0106a89 <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106a54:	83 ec 04             	sub    $0x4,%esp
f0106a57:	6a 28                	push   $0x28
f0106a59:	8d 46 0c             	lea    0xc(%esi),%eax
f0106a5c:	50                   	push   %eax
f0106a5d:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106a60:	53                   	push   %ebx
f0106a61:	e8 ff f5 ff ff       	call   f0106065 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106a66:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106a69:	0f b6 38             	movzbl (%eax),%edi
f0106a6c:	8b 76 04             	mov    0x4(%esi),%esi
f0106a6f:	e8 ae fc ff ff       	call   f0106722 <cpunum>
f0106a74:	57                   	push   %edi
f0106a75:	56                   	push   %esi
f0106a76:	50                   	push   %eax
f0106a77:	68 30 8d 10 f0       	push   $0xf0108d30
f0106a7c:	e8 18 d5 ff ff       	call   f0103f99 <cprintf>
f0106a81:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106a84:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0106a87:	eb 6c                	jmp    f0106af5 <spin_unlock+0xb2>
	return lock->locked && lock->cpu == thiscpu;
f0106a89:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106a8c:	e8 91 fc ff ff       	call   f0106722 <cpunum>
f0106a91:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0106a94:	01 c2                	add    %eax,%edx
f0106a96:	01 d2                	add    %edx,%edx
f0106a98:	01 c2                	add    %eax,%edx
f0106a9a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106a9d:	8d 04 85 20 60 2a f0 	lea    -0xfd59fe0(,%eax,4),%eax
	if (!holding(lk)) {
f0106aa4:	39 c3                	cmp    %eax,%ebx
f0106aa6:	75 ac                	jne    f0106a54 <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f0106aa8:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106aaf:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f0106ab6:	b8 00 00 00 00       	mov    $0x0,%eax
f0106abb:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0106abe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106ac1:	5b                   	pop    %ebx
f0106ac2:	5e                   	pop    %esi
f0106ac3:	5f                   	pop    %edi
f0106ac4:	5d                   	pop    %ebp
f0106ac5:	c3                   	ret    
					pcs[i] - info.eip_fn_addr);
f0106ac6:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106ac8:	83 ec 04             	sub    $0x4,%esp
f0106acb:	89 c2                	mov    %eax,%edx
f0106acd:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106ad0:	52                   	push   %edx
f0106ad1:	ff 75 b0             	pushl  -0x50(%ebp)
f0106ad4:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106ad7:	ff 75 ac             	pushl  -0x54(%ebp)
f0106ada:	ff 75 a8             	pushl  -0x58(%ebp)
f0106add:	50                   	push   %eax
f0106ade:	68 78 8d 10 f0       	push   $0xf0108d78
f0106ae3:	e8 b1 d4 ff ff       	call   f0103f99 <cprintf>
f0106ae8:	83 c4 20             	add    $0x20,%esp
f0106aeb:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106aee:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106af1:	39 c3                	cmp    %eax,%ebx
f0106af3:	74 2d                	je     f0106b22 <spin_unlock+0xdf>
f0106af5:	89 de                	mov    %ebx,%esi
f0106af7:	8b 03                	mov    (%ebx),%eax
f0106af9:	85 c0                	test   %eax,%eax
f0106afb:	74 25                	je     f0106b22 <spin_unlock+0xdf>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106afd:	83 ec 08             	sub    $0x8,%esp
f0106b00:	57                   	push   %edi
f0106b01:	50                   	push   %eax
f0106b02:	e8 9b ea ff ff       	call   f01055a2 <debuginfo_eip>
f0106b07:	83 c4 10             	add    $0x10,%esp
f0106b0a:	85 c0                	test   %eax,%eax
f0106b0c:	79 b8                	jns    f0106ac6 <spin_unlock+0x83>
				cprintf("  %08x\n", pcs[i]);
f0106b0e:	83 ec 08             	sub    $0x8,%esp
f0106b11:	ff 36                	pushl  (%esi)
f0106b13:	68 8f 8d 10 f0       	push   $0xf0108d8f
f0106b18:	e8 7c d4 ff ff       	call   f0103f99 <cprintf>
f0106b1d:	83 c4 10             	add    $0x10,%esp
f0106b20:	eb c9                	jmp    f0106aeb <spin_unlock+0xa8>
		panic("spin_unlock");
f0106b22:	83 ec 04             	sub    $0x4,%esp
f0106b25:	68 97 8d 10 f0       	push   $0xf0108d97
f0106b2a:	6a 67                	push   $0x67
f0106b2c:	68 68 8d 10 f0       	push   $0xf0108d68
f0106b31:	e8 5e 95 ff ff       	call   f0100094 <_panic>
f0106b36:	66 90                	xchg   %ax,%ax

f0106b38 <__udivdi3>:
f0106b38:	55                   	push   %ebp
f0106b39:	57                   	push   %edi
f0106b3a:	56                   	push   %esi
f0106b3b:	53                   	push   %ebx
f0106b3c:	83 ec 1c             	sub    $0x1c,%esp
f0106b3f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0106b43:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106b47:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106b4b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0106b4f:	85 d2                	test   %edx,%edx
f0106b51:	75 2d                	jne    f0106b80 <__udivdi3+0x48>
f0106b53:	39 f7                	cmp    %esi,%edi
f0106b55:	77 59                	ja     f0106bb0 <__udivdi3+0x78>
f0106b57:	89 f9                	mov    %edi,%ecx
f0106b59:	85 ff                	test   %edi,%edi
f0106b5b:	75 0b                	jne    f0106b68 <__udivdi3+0x30>
f0106b5d:	b8 01 00 00 00       	mov    $0x1,%eax
f0106b62:	31 d2                	xor    %edx,%edx
f0106b64:	f7 f7                	div    %edi
f0106b66:	89 c1                	mov    %eax,%ecx
f0106b68:	31 d2                	xor    %edx,%edx
f0106b6a:	89 f0                	mov    %esi,%eax
f0106b6c:	f7 f1                	div    %ecx
f0106b6e:	89 c3                	mov    %eax,%ebx
f0106b70:	89 e8                	mov    %ebp,%eax
f0106b72:	f7 f1                	div    %ecx
f0106b74:	89 da                	mov    %ebx,%edx
f0106b76:	83 c4 1c             	add    $0x1c,%esp
f0106b79:	5b                   	pop    %ebx
f0106b7a:	5e                   	pop    %esi
f0106b7b:	5f                   	pop    %edi
f0106b7c:	5d                   	pop    %ebp
f0106b7d:	c3                   	ret    
f0106b7e:	66 90                	xchg   %ax,%ax
f0106b80:	39 f2                	cmp    %esi,%edx
f0106b82:	77 1c                	ja     f0106ba0 <__udivdi3+0x68>
f0106b84:	0f bd da             	bsr    %edx,%ebx
f0106b87:	83 f3 1f             	xor    $0x1f,%ebx
f0106b8a:	75 38                	jne    f0106bc4 <__udivdi3+0x8c>
f0106b8c:	39 f2                	cmp    %esi,%edx
f0106b8e:	72 08                	jb     f0106b98 <__udivdi3+0x60>
f0106b90:	39 ef                	cmp    %ebp,%edi
f0106b92:	0f 87 98 00 00 00    	ja     f0106c30 <__udivdi3+0xf8>
f0106b98:	b8 01 00 00 00       	mov    $0x1,%eax
f0106b9d:	eb 05                	jmp    f0106ba4 <__udivdi3+0x6c>
f0106b9f:	90                   	nop
f0106ba0:	31 db                	xor    %ebx,%ebx
f0106ba2:	31 c0                	xor    %eax,%eax
f0106ba4:	89 da                	mov    %ebx,%edx
f0106ba6:	83 c4 1c             	add    $0x1c,%esp
f0106ba9:	5b                   	pop    %ebx
f0106baa:	5e                   	pop    %esi
f0106bab:	5f                   	pop    %edi
f0106bac:	5d                   	pop    %ebp
f0106bad:	c3                   	ret    
f0106bae:	66 90                	xchg   %ax,%ax
f0106bb0:	89 e8                	mov    %ebp,%eax
f0106bb2:	89 f2                	mov    %esi,%edx
f0106bb4:	f7 f7                	div    %edi
f0106bb6:	31 db                	xor    %ebx,%ebx
f0106bb8:	89 da                	mov    %ebx,%edx
f0106bba:	83 c4 1c             	add    $0x1c,%esp
f0106bbd:	5b                   	pop    %ebx
f0106bbe:	5e                   	pop    %esi
f0106bbf:	5f                   	pop    %edi
f0106bc0:	5d                   	pop    %ebp
f0106bc1:	c3                   	ret    
f0106bc2:	66 90                	xchg   %ax,%ax
f0106bc4:	b8 20 00 00 00       	mov    $0x20,%eax
f0106bc9:	29 d8                	sub    %ebx,%eax
f0106bcb:	88 d9                	mov    %bl,%cl
f0106bcd:	d3 e2                	shl    %cl,%edx
f0106bcf:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106bd3:	89 fa                	mov    %edi,%edx
f0106bd5:	88 c1                	mov    %al,%cl
f0106bd7:	d3 ea                	shr    %cl,%edx
f0106bd9:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106bdd:	09 d1                	or     %edx,%ecx
f0106bdf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106be3:	88 d9                	mov    %bl,%cl
f0106be5:	d3 e7                	shl    %cl,%edi
f0106be7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106beb:	89 f7                	mov    %esi,%edi
f0106bed:	88 c1                	mov    %al,%cl
f0106bef:	d3 ef                	shr    %cl,%edi
f0106bf1:	88 d9                	mov    %bl,%cl
f0106bf3:	d3 e6                	shl    %cl,%esi
f0106bf5:	89 ea                	mov    %ebp,%edx
f0106bf7:	88 c1                	mov    %al,%cl
f0106bf9:	d3 ea                	shr    %cl,%edx
f0106bfb:	09 d6                	or     %edx,%esi
f0106bfd:	89 f0                	mov    %esi,%eax
f0106bff:	89 fa                	mov    %edi,%edx
f0106c01:	f7 74 24 08          	divl   0x8(%esp)
f0106c05:	89 d7                	mov    %edx,%edi
f0106c07:	89 c6                	mov    %eax,%esi
f0106c09:	f7 64 24 0c          	mull   0xc(%esp)
f0106c0d:	39 d7                	cmp    %edx,%edi
f0106c0f:	72 13                	jb     f0106c24 <__udivdi3+0xec>
f0106c11:	74 09                	je     f0106c1c <__udivdi3+0xe4>
f0106c13:	89 f0                	mov    %esi,%eax
f0106c15:	31 db                	xor    %ebx,%ebx
f0106c17:	eb 8b                	jmp    f0106ba4 <__udivdi3+0x6c>
f0106c19:	8d 76 00             	lea    0x0(%esi),%esi
f0106c1c:	88 d9                	mov    %bl,%cl
f0106c1e:	d3 e5                	shl    %cl,%ebp
f0106c20:	39 c5                	cmp    %eax,%ebp
f0106c22:	73 ef                	jae    f0106c13 <__udivdi3+0xdb>
f0106c24:	8d 46 ff             	lea    -0x1(%esi),%eax
f0106c27:	31 db                	xor    %ebx,%ebx
f0106c29:	e9 76 ff ff ff       	jmp    f0106ba4 <__udivdi3+0x6c>
f0106c2e:	66 90                	xchg   %ax,%ax
f0106c30:	31 c0                	xor    %eax,%eax
f0106c32:	e9 6d ff ff ff       	jmp    f0106ba4 <__udivdi3+0x6c>
f0106c37:	90                   	nop

f0106c38 <__umoddi3>:
f0106c38:	55                   	push   %ebp
f0106c39:	57                   	push   %edi
f0106c3a:	56                   	push   %esi
f0106c3b:	53                   	push   %ebx
f0106c3c:	83 ec 1c             	sub    $0x1c,%esp
f0106c3f:	8b 74 24 30          	mov    0x30(%esp),%esi
f0106c43:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0106c47:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106c4b:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0106c4f:	89 f0                	mov    %esi,%eax
f0106c51:	89 da                	mov    %ebx,%edx
f0106c53:	85 ed                	test   %ebp,%ebp
f0106c55:	75 15                	jne    f0106c6c <__umoddi3+0x34>
f0106c57:	39 df                	cmp    %ebx,%edi
f0106c59:	76 39                	jbe    f0106c94 <__umoddi3+0x5c>
f0106c5b:	f7 f7                	div    %edi
f0106c5d:	89 d0                	mov    %edx,%eax
f0106c5f:	31 d2                	xor    %edx,%edx
f0106c61:	83 c4 1c             	add    $0x1c,%esp
f0106c64:	5b                   	pop    %ebx
f0106c65:	5e                   	pop    %esi
f0106c66:	5f                   	pop    %edi
f0106c67:	5d                   	pop    %ebp
f0106c68:	c3                   	ret    
f0106c69:	8d 76 00             	lea    0x0(%esi),%esi
f0106c6c:	39 dd                	cmp    %ebx,%ebp
f0106c6e:	77 f1                	ja     f0106c61 <__umoddi3+0x29>
f0106c70:	0f bd cd             	bsr    %ebp,%ecx
f0106c73:	83 f1 1f             	xor    $0x1f,%ecx
f0106c76:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106c7a:	75 38                	jne    f0106cb4 <__umoddi3+0x7c>
f0106c7c:	39 dd                	cmp    %ebx,%ebp
f0106c7e:	72 04                	jb     f0106c84 <__umoddi3+0x4c>
f0106c80:	39 f7                	cmp    %esi,%edi
f0106c82:	77 dd                	ja     f0106c61 <__umoddi3+0x29>
f0106c84:	89 da                	mov    %ebx,%edx
f0106c86:	89 f0                	mov    %esi,%eax
f0106c88:	29 f8                	sub    %edi,%eax
f0106c8a:	19 ea                	sbb    %ebp,%edx
f0106c8c:	83 c4 1c             	add    $0x1c,%esp
f0106c8f:	5b                   	pop    %ebx
f0106c90:	5e                   	pop    %esi
f0106c91:	5f                   	pop    %edi
f0106c92:	5d                   	pop    %ebp
f0106c93:	c3                   	ret    
f0106c94:	89 f9                	mov    %edi,%ecx
f0106c96:	85 ff                	test   %edi,%edi
f0106c98:	75 0b                	jne    f0106ca5 <__umoddi3+0x6d>
f0106c9a:	b8 01 00 00 00       	mov    $0x1,%eax
f0106c9f:	31 d2                	xor    %edx,%edx
f0106ca1:	f7 f7                	div    %edi
f0106ca3:	89 c1                	mov    %eax,%ecx
f0106ca5:	89 d8                	mov    %ebx,%eax
f0106ca7:	31 d2                	xor    %edx,%edx
f0106ca9:	f7 f1                	div    %ecx
f0106cab:	89 f0                	mov    %esi,%eax
f0106cad:	f7 f1                	div    %ecx
f0106caf:	eb ac                	jmp    f0106c5d <__umoddi3+0x25>
f0106cb1:	8d 76 00             	lea    0x0(%esi),%esi
f0106cb4:	b8 20 00 00 00       	mov    $0x20,%eax
f0106cb9:	89 c2                	mov    %eax,%edx
f0106cbb:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106cbf:	29 c2                	sub    %eax,%edx
f0106cc1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106cc5:	88 c1                	mov    %al,%cl
f0106cc7:	d3 e5                	shl    %cl,%ebp
f0106cc9:	89 f8                	mov    %edi,%eax
f0106ccb:	88 d1                	mov    %dl,%cl
f0106ccd:	d3 e8                	shr    %cl,%eax
f0106ccf:	09 c5                	or     %eax,%ebp
f0106cd1:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106cd5:	88 c1                	mov    %al,%cl
f0106cd7:	d3 e7                	shl    %cl,%edi
f0106cd9:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0106cdd:	89 df                	mov    %ebx,%edi
f0106cdf:	88 d1                	mov    %dl,%cl
f0106ce1:	d3 ef                	shr    %cl,%edi
f0106ce3:	88 c1                	mov    %al,%cl
f0106ce5:	d3 e3                	shl    %cl,%ebx
f0106ce7:	89 f0                	mov    %esi,%eax
f0106ce9:	88 d1                	mov    %dl,%cl
f0106ceb:	d3 e8                	shr    %cl,%eax
f0106ced:	09 d8                	or     %ebx,%eax
f0106cef:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0106cf3:	d3 e6                	shl    %cl,%esi
f0106cf5:	89 fa                	mov    %edi,%edx
f0106cf7:	f7 f5                	div    %ebp
f0106cf9:	89 d1                	mov    %edx,%ecx
f0106cfb:	f7 64 24 08          	mull   0x8(%esp)
f0106cff:	89 c3                	mov    %eax,%ebx
f0106d01:	89 d7                	mov    %edx,%edi
f0106d03:	39 d1                	cmp    %edx,%ecx
f0106d05:	72 29                	jb     f0106d30 <__umoddi3+0xf8>
f0106d07:	74 23                	je     f0106d2c <__umoddi3+0xf4>
f0106d09:	89 ca                	mov    %ecx,%edx
f0106d0b:	29 de                	sub    %ebx,%esi
f0106d0d:	19 fa                	sbb    %edi,%edx
f0106d0f:	89 d0                	mov    %edx,%eax
f0106d11:	8a 4c 24 0c          	mov    0xc(%esp),%cl
f0106d15:	d3 e0                	shl    %cl,%eax
f0106d17:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0106d1b:	88 d9                	mov    %bl,%cl
f0106d1d:	d3 ee                	shr    %cl,%esi
f0106d1f:	09 f0                	or     %esi,%eax
f0106d21:	d3 ea                	shr    %cl,%edx
f0106d23:	83 c4 1c             	add    $0x1c,%esp
f0106d26:	5b                   	pop    %ebx
f0106d27:	5e                   	pop    %esi
f0106d28:	5f                   	pop    %edi
f0106d29:	5d                   	pop    %ebp
f0106d2a:	c3                   	ret    
f0106d2b:	90                   	nop
f0106d2c:	39 c6                	cmp    %eax,%esi
f0106d2e:	73 d9                	jae    f0106d09 <__umoddi3+0xd1>
f0106d30:	2b 44 24 08          	sub    0x8(%esp),%eax
f0106d34:	19 ea                	sbb    %ebp,%edx
f0106d36:	89 d7                	mov    %edx,%edi
f0106d38:	89 c3                	mov    %eax,%ebx
f0106d3a:	eb cd                	jmp    f0106d09 <__umoddi3+0xd1>
