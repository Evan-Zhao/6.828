
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
f0100015:	b8 00 00 12 00       	mov    $0x120000,%eax
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
f0100034:	bc 00 00 12 f0       	mov    $0xf0120000,%esp

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
f010004b:	68 e0 66 10 f0       	push   $0xf01066e0
f0100050:	e8 20 3f 00 00       	call   f0103f75 <cprintf>
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
f0100065:	e8 f6 0c 00 00       	call   f0100d60 <mon_backtrace>
f010006a:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010006d:	83 ec 08             	sub    $0x8,%esp
f0100070:	53                   	push   %ebx
f0100071:	68 fc 66 10 f0       	push   $0xf01066fc
f0100076:	e8 fa 3e 00 00       	call   f0103f75 <cprintf>
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
f010009c:	83 3d 80 1e 29 f0 00 	cmpl   $0x0,0xf0291e80
f01000a3:	74 0f                	je     f01000b4 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000a5:	83 ec 0c             	sub    $0xc,%esp
f01000a8:	6a 00                	push   $0x0
f01000aa:	e8 55 0d 00 00       	call   f0100e04 <monitor>
f01000af:	83 c4 10             	add    $0x10,%esp
f01000b2:	eb f1                	jmp    f01000a5 <_panic+0x11>
	panicstr = fmt;
f01000b4:	89 35 80 1e 29 f0    	mov    %esi,0xf0291e80
	asm volatile("cli; cld");
f01000ba:	fa                   	cli    
f01000bb:	fc                   	cld    
	va_start(ap, fmt);
f01000bc:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f01000bf:	e8 02 60 00 00       	call   f01060c6 <cpunum>
f01000c4:	ff 75 0c             	pushl  0xc(%ebp)
f01000c7:	ff 75 08             	pushl  0x8(%ebp)
f01000ca:	50                   	push   %eax
f01000cb:	68 e4 67 10 f0       	push   $0xf01067e4
f01000d0:	e8 a0 3e 00 00       	call   f0103f75 <cprintf>
	vcprintf(fmt, ap);
f01000d5:	83 c4 08             	add    $0x8,%esp
f01000d8:	53                   	push   %ebx
f01000d9:	56                   	push   %esi
f01000da:	e8 70 3e 00 00       	call   f0103f4f <vcprintf>
	cprintf("\n");
f01000df:	c7 04 24 9b 6b 10 f0 	movl   $0xf0106b9b,(%esp)
f01000e6:	e8 8a 3e 00 00       	call   f0103f75 <cprintf>
f01000eb:	83 c4 10             	add    $0x10,%esp
f01000ee:	eb b5                	jmp    f01000a5 <_panic+0x11>

f01000f0 <i386_init>:
{
f01000f0:	55                   	push   %ebp
f01000f1:	89 e5                	mov    %esp,%ebp
f01000f3:	53                   	push   %ebx
f01000f4:	83 ec 08             	sub    $0x8,%esp
	memset(edata, 0, end - edata);
f01000f7:	b8 08 30 2d f0       	mov    $0xf02d3008,%eax
f01000fc:	2d ec 0b 29 f0       	sub    $0xf0290bec,%eax
f0100101:	50                   	push   %eax
f0100102:	6a 00                	push   $0x0
f0100104:	68 ec 0b 29 f0       	push   $0xf0290bec
f0100109:	e8 e0 58 00 00       	call   f01059ee <memset>
	cons_init();
f010010e:	e8 f5 05 00 00       	call   f0100708 <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f0100113:	83 c4 08             	add    $0x8,%esp
f0100116:	68 ac 1a 00 00       	push   $0x1aac
f010011b:	68 17 67 10 f0       	push   $0xf0106717
f0100120:	e8 50 3e 00 00       	call   f0103f75 <cprintf>
	mem_init();
f0100125:	e8 bf 16 00 00       	call   f01017e9 <mem_init>
	cprintf(ANSI_COLOR_RED     "This text is RED!"     ANSI_COLOR_RESET "\n");
f010012a:	c7 04 24 32 67 10 f0 	movl   $0xf0106732,(%esp)
f0100131:	e8 3f 3e 00 00       	call   f0103f75 <cprintf>
	cprintf(ANSI_COLOR_GREEN   "This text is GREEN!"   ANSI_COLOR_RESET "\n");
f0100136:	c7 04 24 4e 67 10 f0 	movl   $0xf010674e,(%esp)
f010013d:	e8 33 3e 00 00       	call   f0103f75 <cprintf>
	cprintf(ANSI_COLOR_YELLOW  "This text is YELLOW!"  ANSI_COLOR_RESET "\n");
f0100142:	c7 04 24 08 68 10 f0 	movl   $0xf0106808,(%esp)
f0100149:	e8 27 3e 00 00       	call   f0103f75 <cprintf>
	cprintf(ANSI_COLOR_BLUE    "This text is BLUE!"    ANSI_COLOR_RESET "\n");
f010014e:	c7 04 24 6c 67 10 f0 	movl   $0xf010676c,(%esp)
f0100155:	e8 1b 3e 00 00       	call   f0103f75 <cprintf>
	cprintf(ANSI_COLOR_MAGENTA "This text is MAGENTA!" ANSI_COLOR_RESET "\n");
f010015a:	c7 04 24 28 68 10 f0 	movl   $0xf0106828,(%esp)
f0100161:	e8 0f 3e 00 00       	call   f0103f75 <cprintf>
	cprintf(ANSI_COLOR_CYAN    "This text is CYAN!"    ANSI_COLOR_RESET "\n");
f0100166:	c7 04 24 89 67 10 f0 	movl   $0xf0106789,(%esp)
f010016d:	e8 03 3e 00 00       	call   f0103f75 <cprintf>
	test_backtrace(5);
f0100172:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100179:	e8 c2 fe ff ff       	call   f0100040 <test_backtrace>
	env_init();
f010017e:	e8 64 34 00 00       	call   f01035e7 <env_init>
	trap_init();
f0100183:	e8 a1 3e 00 00       	call   f0104029 <trap_init>
	mp_init();
f0100188:	e8 22 5c 00 00       	call   f0105daf <mp_init>
	lapic_init();
f010018d:	e8 4f 5f 00 00       	call   f01060e1 <lapic_init>
	pic_init();
f0100192:	e8 1a 3d 00 00       	call   f0103eb1 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100197:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f010019e:	e8 97 61 00 00       	call   f010633a <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01001a3:	83 c4 10             	add    $0x10,%esp
f01001a6:	83 3d 88 1e 29 f0 07 	cmpl   $0x7,0xf0291e88
f01001ad:	76 27                	jbe    f01001d6 <i386_init+0xe6>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001af:	83 ec 04             	sub    $0x4,%esp
f01001b2:	b8 16 5d 10 f0       	mov    $0xf0105d16,%eax
f01001b7:	2d 9c 5c 10 f0       	sub    $0xf0105c9c,%eax
f01001bc:	50                   	push   %eax
f01001bd:	68 9c 5c 10 f0       	push   $0xf0105c9c
f01001c2:	68 00 70 00 f0       	push   $0xf0007000
f01001c7:	e8 6f 58 00 00       	call   f0105a3b <memmove>
f01001cc:	83 c4 10             	add    $0x10,%esp
	for (c = cpus; c < cpus + ncpu; c++) {
f01001cf:	bb 20 20 29 f0       	mov    $0xf0292020,%ebx
f01001d4:	eb 19                	jmp    f01001ef <i386_init+0xff>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001d6:	68 00 70 00 00       	push   $0x7000
f01001db:	68 48 68 10 f0       	push   $0xf0106848
f01001e0:	6a 72                	push   $0x72
f01001e2:	68 a6 67 10 f0       	push   $0xf01067a6
f01001e7:	e8 a8 fe ff ff       	call   f0100094 <_panic>
f01001ec:	83 c3 74             	add    $0x74,%ebx
f01001ef:	8b 15 c4 23 29 f0    	mov    0xf02923c4,%edx
f01001f5:	8d 04 12             	lea    (%edx,%edx,1),%eax
f01001f8:	01 d0                	add    %edx,%eax
f01001fa:	01 c0                	add    %eax,%eax
f01001fc:	01 d0                	add    %edx,%eax
f01001fe:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100201:	8d 04 85 20 20 29 f0 	lea    -0xfd6dfe0(,%eax,4),%eax
f0100208:	39 c3                	cmp    %eax,%ebx
f010020a:	73 6d                	jae    f0100279 <i386_init+0x189>
		if (c == cpus + cpunum())  // We've started already.
f010020c:	e8 b5 5e 00 00       	call   f01060c6 <cpunum>
f0100211:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100214:	01 c2                	add    %eax,%edx
f0100216:	01 d2                	add    %edx,%edx
f0100218:	01 c2                	add    %eax,%edx
f010021a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010021d:	8d 04 85 20 20 29 f0 	lea    -0xfd6dfe0(,%eax,4),%eax
f0100224:	39 c3                	cmp    %eax,%ebx
f0100226:	74 c4                	je     f01001ec <i386_init+0xfc>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100228:	89 d8                	mov    %ebx,%eax
f010022a:	2d 20 20 29 f0       	sub    $0xf0292020,%eax
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
f010024e:	05 00 b0 29 f0       	add    $0xf029b000,%eax
f0100253:	a3 84 1e 29 f0       	mov    %eax,0xf0291e84
		lapic_startap(c->cpu_id, PADDR(code));
f0100258:	83 ec 08             	sub    $0x8,%esp
f010025b:	68 00 70 00 00       	push   $0x7000
f0100260:	0f b6 03             	movzbl (%ebx),%eax
f0100263:	50                   	push   %eax
f0100264:	e8 d2 5f 00 00       	call   f010623b <lapic_startap>
f0100269:	83 c4 10             	add    $0x10,%esp
		while(c->cpu_status != CPU_STARTED)
f010026c:	8b 43 04             	mov    0x4(%ebx),%eax
f010026f:	83 f8 01             	cmp    $0x1,%eax
f0100272:	75 f8                	jne    f010026c <i386_init+0x17c>
f0100274:	e9 73 ff ff ff       	jmp    f01001ec <i386_init+0xfc>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100279:	83 ec 08             	sub    $0x8,%esp
f010027c:	6a 00                	push   $0x0
f010027e:	68 c0 2b 20 f0       	push   $0xf0202bc0
f0100283:	e8 aa 35 00 00       	call   f0103832 <env_create>
	sched_yield();
f0100288:	e8 58 47 00 00       	call   f01049e5 <sched_yield>

f010028d <mp_main>:
{
f010028d:	55                   	push   %ebp
f010028e:	89 e5                	mov    %esp,%ebp
f0100290:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f0100293:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0100298:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010029d:	77 15                	ja     f01002b4 <mp_main+0x27>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010029f:	50                   	push   %eax
f01002a0:	68 6c 68 10 f0       	push   $0xf010686c
f01002a5:	68 89 00 00 00       	push   $0x89
f01002aa:	68 a6 67 10 f0       	push   $0xf01067a6
f01002af:	e8 e0 fd ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01002b4:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01002b9:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01002bc:	e8 05 5e 00 00       	call   f01060c6 <cpunum>
f01002c1:	83 ec 08             	sub    $0x8,%esp
f01002c4:	50                   	push   %eax
f01002c5:	68 b2 67 10 f0       	push   $0xf01067b2
f01002ca:	e8 a6 3c 00 00       	call   f0103f75 <cprintf>
	lapic_init();
f01002cf:	e8 0d 5e 00 00       	call   f01060e1 <lapic_init>
	env_init_percpu();
f01002d4:	e8 de 32 00 00       	call   f01035b7 <env_init_percpu>
	trap_init_percpu();
f01002d9:	e8 ab 3c 00 00       	call   f0103f89 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01002de:	e8 e3 5d 00 00       	call   f01060c6 <cpunum>
f01002e3:	6b d0 74             	imul   $0x74,%eax,%edx
f01002e6:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01002e9:	b8 01 00 00 00       	mov    $0x1,%eax
f01002ee:	f0 87 82 20 20 29 f0 	lock xchg %eax,-0xfd6dfe0(%edx)
f01002f5:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f01002fc:	e8 39 60 00 00       	call   f010633a <spin_lock>
	sched_yield();
f0100301:	e8 df 46 00 00       	call   f01049e5 <sched_yield>

f0100306 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100306:	55                   	push   %ebp
f0100307:	89 e5                	mov    %esp,%ebp
f0100309:	53                   	push   %ebx
f010030a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010030d:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100310:	ff 75 0c             	pushl  0xc(%ebp)
f0100313:	ff 75 08             	pushl  0x8(%ebp)
f0100316:	68 c8 67 10 f0       	push   $0xf01067c8
f010031b:	e8 55 3c 00 00       	call   f0103f75 <cprintf>
	vcprintf(fmt, ap);
f0100320:	83 c4 08             	add    $0x8,%esp
f0100323:	53                   	push   %ebx
f0100324:	ff 75 10             	pushl  0x10(%ebp)
f0100327:	e8 23 3c 00 00       	call   f0103f4f <vcprintf>
	cprintf("\n");
f010032c:	c7 04 24 9b 6b 10 f0 	movl   $0xf0106b9b,(%esp)
f0100333:	e8 3d 3c 00 00       	call   f0103f75 <cprintf>
	va_end(ap);
}
f0100338:	83 c4 10             	add    $0x10,%esp
f010033b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010033e:	c9                   	leave  
f010033f:	c3                   	ret    

f0100340 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100340:	55                   	push   %ebp
f0100341:	89 e5                	mov    %esp,%ebp
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100343:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100348:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100349:	a8 01                	test   $0x1,%al
f010034b:	74 0b                	je     f0100358 <serial_proc_data+0x18>
f010034d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100352:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100353:	0f b6 c0             	movzbl %al,%eax
}
f0100356:	5d                   	pop    %ebp
f0100357:	c3                   	ret    
		return -1;
f0100358:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010035d:	eb f7                	jmp    f0100356 <serial_proc_data+0x16>

f010035f <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010035f:	55                   	push   %ebp
f0100360:	89 e5                	mov    %esp,%ebp
f0100362:	53                   	push   %ebx
f0100363:	83 ec 04             	sub    $0x4,%esp
f0100366:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100368:	ff d3                	call   *%ebx
f010036a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010036d:	74 2d                	je     f010039c <cons_intr+0x3d>
		if (c == 0)
f010036f:	85 c0                	test   %eax,%eax
f0100371:	74 f5                	je     f0100368 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f0100373:	8b 0d 24 12 29 f0    	mov    0xf0291224,%ecx
f0100379:	8d 51 01             	lea    0x1(%ecx),%edx
f010037c:	89 15 24 12 29 f0    	mov    %edx,0xf0291224
f0100382:	88 81 20 10 29 f0    	mov    %al,-0xfd6efe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100388:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010038e:	75 d8                	jne    f0100368 <cons_intr+0x9>
			cons.wpos = 0;
f0100390:	c7 05 24 12 29 f0 00 	movl   $0x0,0xf0291224
f0100397:	00 00 00 
f010039a:	eb cc                	jmp    f0100368 <cons_intr+0x9>
	}
}
f010039c:	83 c4 04             	add    $0x4,%esp
f010039f:	5b                   	pop    %ebx
f01003a0:	5d                   	pop    %ebp
f01003a1:	c3                   	ret    

f01003a2 <kbd_proc_data>:
{
f01003a2:	55                   	push   %ebp
f01003a3:	89 e5                	mov    %esp,%ebp
f01003a5:	53                   	push   %ebx
f01003a6:	83 ec 04             	sub    $0x4,%esp
f01003a9:	ba 64 00 00 00       	mov    $0x64,%edx
f01003ae:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01003af:	a8 01                	test   $0x1,%al
f01003b1:	0f 84 f1 00 00 00    	je     f01004a8 <kbd_proc_data+0x106>
	if (stat & KBS_TERR)
f01003b7:	a8 20                	test   $0x20,%al
f01003b9:	0f 85 f0 00 00 00    	jne    f01004af <kbd_proc_data+0x10d>
f01003bf:	ba 60 00 00 00       	mov    $0x60,%edx
f01003c4:	ec                   	in     (%dx),%al
f01003c5:	88 c2                	mov    %al,%dl
	if (data == 0xE0) {
f01003c7:	3c e0                	cmp    $0xe0,%al
f01003c9:	0f 84 8a 00 00 00    	je     f0100459 <kbd_proc_data+0xb7>
	} else if (data & 0x80) {
f01003cf:	84 c0                	test   %al,%al
f01003d1:	0f 88 95 00 00 00    	js     f010046c <kbd_proc_data+0xca>
	} else if (shift & E0ESC) {
f01003d7:	8b 0d 00 10 29 f0    	mov    0xf0291000,%ecx
f01003dd:	f6 c1 40             	test   $0x40,%cl
f01003e0:	74 0e                	je     f01003f0 <kbd_proc_data+0x4e>
		data |= 0x80;
f01003e2:	83 c8 80             	or     $0xffffff80,%eax
f01003e5:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f01003e7:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003ea:	89 0d 00 10 29 f0    	mov    %ecx,0xf0291000
	shift |= shiftcode[data];
f01003f0:	0f b6 d2             	movzbl %dl,%edx
f01003f3:	0f b6 82 e0 69 10 f0 	movzbl -0xfef9620(%edx),%eax
f01003fa:	0b 05 00 10 29 f0    	or     0xf0291000,%eax
	shift ^= togglecode[data];
f0100400:	0f b6 8a e0 68 10 f0 	movzbl -0xfef9720(%edx),%ecx
f0100407:	31 c8                	xor    %ecx,%eax
f0100409:	a3 00 10 29 f0       	mov    %eax,0xf0291000
	c = charcode[shift & (CTL | SHIFT)][data];
f010040e:	89 c1                	mov    %eax,%ecx
f0100410:	83 e1 03             	and    $0x3,%ecx
f0100413:	8b 0c 8d c0 68 10 f0 	mov    -0xfef9740(,%ecx,4),%ecx
f010041a:	8a 14 11             	mov    (%ecx,%edx,1),%dl
f010041d:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100420:	a8 08                	test   $0x8,%al
f0100422:	74 0d                	je     f0100431 <kbd_proc_data+0x8f>
		if ('a' <= c && c <= 'z')
f0100424:	89 da                	mov    %ebx,%edx
f0100426:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100429:	83 f9 19             	cmp    $0x19,%ecx
f010042c:	77 6d                	ja     f010049b <kbd_proc_data+0xf9>
			c += 'A' - 'a';
f010042e:	83 eb 20             	sub    $0x20,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100431:	f7 d0                	not    %eax
f0100433:	a8 06                	test   $0x6,%al
f0100435:	75 2e                	jne    f0100465 <kbd_proc_data+0xc3>
f0100437:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010043d:	75 26                	jne    f0100465 <kbd_proc_data+0xc3>
		cprintf("Rebooting!\n");
f010043f:	83 ec 0c             	sub    $0xc,%esp
f0100442:	68 90 68 10 f0       	push   $0xf0106890
f0100447:	e8 29 3b 00 00       	call   f0103f75 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010044c:	b0 03                	mov    $0x3,%al
f010044e:	ba 92 00 00 00       	mov    $0x92,%edx
f0100453:	ee                   	out    %al,(%dx)
f0100454:	83 c4 10             	add    $0x10,%esp
f0100457:	eb 0c                	jmp    f0100465 <kbd_proc_data+0xc3>
		shift |= E0ESC;
f0100459:	83 0d 00 10 29 f0 40 	orl    $0x40,0xf0291000
		return 0;
f0100460:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100465:	89 d8                	mov    %ebx,%eax
f0100467:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010046a:	c9                   	leave  
f010046b:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010046c:	8b 0d 00 10 29 f0    	mov    0xf0291000,%ecx
f0100472:	f6 c1 40             	test   $0x40,%cl
f0100475:	75 05                	jne    f010047c <kbd_proc_data+0xda>
f0100477:	83 e0 7f             	and    $0x7f,%eax
f010047a:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f010047c:	0f b6 d2             	movzbl %dl,%edx
f010047f:	8a 82 e0 69 10 f0    	mov    -0xfef9620(%edx),%al
f0100485:	83 c8 40             	or     $0x40,%eax
f0100488:	0f b6 c0             	movzbl %al,%eax
f010048b:	f7 d0                	not    %eax
f010048d:	21 c8                	and    %ecx,%eax
f010048f:	a3 00 10 29 f0       	mov    %eax,0xf0291000
		return 0;
f0100494:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100499:	eb ca                	jmp    f0100465 <kbd_proc_data+0xc3>
		else if ('A' <= c && c <= 'Z')
f010049b:	83 ea 41             	sub    $0x41,%edx
f010049e:	83 fa 19             	cmp    $0x19,%edx
f01004a1:	77 8e                	ja     f0100431 <kbd_proc_data+0x8f>
			c += 'a' - 'A';
f01004a3:	83 c3 20             	add    $0x20,%ebx
f01004a6:	eb 89                	jmp    f0100431 <kbd_proc_data+0x8f>
		return -1;
f01004a8:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01004ad:	eb b6                	jmp    f0100465 <kbd_proc_data+0xc3>
		return -1;
f01004af:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01004b4:	eb af                	jmp    f0100465 <kbd_proc_data+0xc3>

f01004b6 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01004b6:	55                   	push   %ebp
f01004b7:	89 e5                	mov    %esp,%ebp
f01004b9:	57                   	push   %edi
f01004ba:	56                   	push   %esi
f01004bb:	53                   	push   %ebx
f01004bc:	83 ec 1c             	sub    $0x1c,%esp
f01004bf:	89 c7                	mov    %eax,%edi
f01004c1:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004c6:	be fd 03 00 00       	mov    $0x3fd,%esi
f01004cb:	b9 84 00 00 00       	mov    $0x84,%ecx
f01004d0:	eb 06                	jmp    f01004d8 <cons_putc+0x22>
f01004d2:	89 ca                	mov    %ecx,%edx
f01004d4:	ec                   	in     (%dx),%al
f01004d5:	ec                   	in     (%dx),%al
f01004d6:	ec                   	in     (%dx),%al
f01004d7:	ec                   	in     (%dx),%al
f01004d8:	89 f2                	mov    %esi,%edx
f01004da:	ec                   	in     (%dx),%al
	for (i = 0;
f01004db:	a8 20                	test   $0x20,%al
f01004dd:	75 03                	jne    f01004e2 <cons_putc+0x2c>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01004df:	4b                   	dec    %ebx
f01004e0:	75 f0                	jne    f01004d2 <cons_putc+0x1c>
	outb(COM1 + COM_TX, c);
f01004e2:	89 f8                	mov    %edi,%eax
f01004e4:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004e7:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01004ec:	ee                   	out    %al,(%dx)
f01004ed:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004f2:	be 79 03 00 00       	mov    $0x379,%esi
f01004f7:	b9 84 00 00 00       	mov    $0x84,%ecx
f01004fc:	eb 06                	jmp    f0100504 <cons_putc+0x4e>
f01004fe:	89 ca                	mov    %ecx,%edx
f0100500:	ec                   	in     (%dx),%al
f0100501:	ec                   	in     (%dx),%al
f0100502:	ec                   	in     (%dx),%al
f0100503:	ec                   	in     (%dx),%al
f0100504:	89 f2                	mov    %esi,%edx
f0100506:	ec                   	in     (%dx),%al
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100507:	84 c0                	test   %al,%al
f0100509:	78 03                	js     f010050e <cons_putc+0x58>
f010050b:	4b                   	dec    %ebx
f010050c:	75 f0                	jne    f01004fe <cons_putc+0x48>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010050e:	ba 78 03 00 00       	mov    $0x378,%edx
f0100513:	8a 45 e7             	mov    -0x19(%ebp),%al
f0100516:	ee                   	out    %al,(%dx)
f0100517:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010051c:	b0 0d                	mov    $0xd,%al
f010051e:	ee                   	out    %al,(%dx)
f010051f:	b0 08                	mov    $0x8,%al
f0100521:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f0100522:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100528:	75 06                	jne    f0100530 <cons_putc+0x7a>
		c |= 0x0700;
f010052a:	81 cf 00 07 00 00    	or     $0x700,%edi
	switch (c & 0xff) {
f0100530:	89 f8                	mov    %edi,%eax
f0100532:	0f b6 c0             	movzbl %al,%eax
f0100535:	83 f8 09             	cmp    $0x9,%eax
f0100538:	0f 84 b1 00 00 00    	je     f01005ef <cons_putc+0x139>
f010053e:	83 f8 09             	cmp    $0x9,%eax
f0100541:	7e 70                	jle    f01005b3 <cons_putc+0xfd>
f0100543:	83 f8 0a             	cmp    $0xa,%eax
f0100546:	0f 84 96 00 00 00    	je     f01005e2 <cons_putc+0x12c>
f010054c:	83 f8 0d             	cmp    $0xd,%eax
f010054f:	0f 85 d1 00 00 00    	jne    f0100626 <cons_putc+0x170>
		crt_pos -= (crt_pos % CRT_COLS);
f0100555:	66 8b 0d 28 12 29 f0 	mov    0xf0291228,%cx
f010055c:	bb 50 00 00 00       	mov    $0x50,%ebx
f0100561:	89 c8                	mov    %ecx,%eax
f0100563:	ba 00 00 00 00       	mov    $0x0,%edx
f0100568:	66 f7 f3             	div    %bx
f010056b:	29 d1                	sub    %edx,%ecx
f010056d:	66 89 0d 28 12 29 f0 	mov    %cx,0xf0291228
	if (crt_pos >= CRT_SIZE) {
f0100574:	66 81 3d 28 12 29 f0 	cmpw   $0x7cf,0xf0291228
f010057b:	cf 07 
f010057d:	0f 87 c5 00 00 00    	ja     f0100648 <cons_putc+0x192>
	outb(addr_6845, 14);
f0100583:	8b 0d 30 12 29 f0    	mov    0xf0291230,%ecx
f0100589:	b0 0e                	mov    $0xe,%al
f010058b:	89 ca                	mov    %ecx,%edx
f010058d:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010058e:	8d 59 01             	lea    0x1(%ecx),%ebx
f0100591:	66 a1 28 12 29 f0    	mov    0xf0291228,%ax
f0100597:	66 c1 e8 08          	shr    $0x8,%ax
f010059b:	89 da                	mov    %ebx,%edx
f010059d:	ee                   	out    %al,(%dx)
f010059e:	b0 0f                	mov    $0xf,%al
f01005a0:	89 ca                	mov    %ecx,%edx
f01005a2:	ee                   	out    %al,(%dx)
f01005a3:	a0 28 12 29 f0       	mov    0xf0291228,%al
f01005a8:	89 da                	mov    %ebx,%edx
f01005aa:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005ae:	5b                   	pop    %ebx
f01005af:	5e                   	pop    %esi
f01005b0:	5f                   	pop    %edi
f01005b1:	5d                   	pop    %ebp
f01005b2:	c3                   	ret    
	switch (c & 0xff) {
f01005b3:	83 f8 08             	cmp    $0x8,%eax
f01005b6:	75 6e                	jne    f0100626 <cons_putc+0x170>
		if (crt_pos > 0) {
f01005b8:	66 a1 28 12 29 f0    	mov    0xf0291228,%ax
f01005be:	66 85 c0             	test   %ax,%ax
f01005c1:	74 c0                	je     f0100583 <cons_putc+0xcd>
			crt_pos--;
f01005c3:	48                   	dec    %eax
f01005c4:	66 a3 28 12 29 f0    	mov    %ax,0xf0291228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01005ca:	0f b7 c0             	movzwl %ax,%eax
f01005cd:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f01005d3:	83 cf 20             	or     $0x20,%edi
f01005d6:	8b 15 2c 12 29 f0    	mov    0xf029122c,%edx
f01005dc:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01005e0:	eb 92                	jmp    f0100574 <cons_putc+0xbe>
		crt_pos += CRT_COLS;
f01005e2:	66 83 05 28 12 29 f0 	addw   $0x50,0xf0291228
f01005e9:	50 
f01005ea:	e9 66 ff ff ff       	jmp    f0100555 <cons_putc+0x9f>
		cons_putc(' ');
f01005ef:	b8 20 00 00 00       	mov    $0x20,%eax
f01005f4:	e8 bd fe ff ff       	call   f01004b6 <cons_putc>
		cons_putc(' ');
f01005f9:	b8 20 00 00 00       	mov    $0x20,%eax
f01005fe:	e8 b3 fe ff ff       	call   f01004b6 <cons_putc>
		cons_putc(' ');
f0100603:	b8 20 00 00 00       	mov    $0x20,%eax
f0100608:	e8 a9 fe ff ff       	call   f01004b6 <cons_putc>
		cons_putc(' ');
f010060d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100612:	e8 9f fe ff ff       	call   f01004b6 <cons_putc>
		cons_putc(' ');
f0100617:	b8 20 00 00 00       	mov    $0x20,%eax
f010061c:	e8 95 fe ff ff       	call   f01004b6 <cons_putc>
f0100621:	e9 4e ff ff ff       	jmp    f0100574 <cons_putc+0xbe>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100626:	66 a1 28 12 29 f0    	mov    0xf0291228,%ax
f010062c:	8d 50 01             	lea    0x1(%eax),%edx
f010062f:	66 89 15 28 12 29 f0 	mov    %dx,0xf0291228
f0100636:	0f b7 c0             	movzwl %ax,%eax
f0100639:	8b 15 2c 12 29 f0    	mov    0xf029122c,%edx
f010063f:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100643:	e9 2c ff ff ff       	jmp    f0100574 <cons_putc+0xbe>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100648:	a1 2c 12 29 f0       	mov    0xf029122c,%eax
f010064d:	83 ec 04             	sub    $0x4,%esp
f0100650:	68 00 0f 00 00       	push   $0xf00
f0100655:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010065b:	52                   	push   %edx
f010065c:	50                   	push   %eax
f010065d:	e8 d9 53 00 00       	call   f0105a3b <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100662:	8b 15 2c 12 29 f0    	mov    0xf029122c,%edx
f0100668:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010066e:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100674:	83 c4 10             	add    $0x10,%esp
f0100677:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010067c:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010067f:	39 d0                	cmp    %edx,%eax
f0100681:	75 f4                	jne    f0100677 <cons_putc+0x1c1>
		crt_pos -= CRT_COLS;
f0100683:	66 83 2d 28 12 29 f0 	subw   $0x50,0xf0291228
f010068a:	50 
f010068b:	e9 f3 fe ff ff       	jmp    f0100583 <cons_putc+0xcd>

f0100690 <serial_intr>:
	if (serial_exists)
f0100690:	80 3d 34 12 29 f0 00 	cmpb   $0x0,0xf0291234
f0100697:	75 01                	jne    f010069a <serial_intr+0xa>
f0100699:	c3                   	ret    
{
f010069a:	55                   	push   %ebp
f010069b:	89 e5                	mov    %esp,%ebp
f010069d:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01006a0:	b8 40 03 10 f0       	mov    $0xf0100340,%eax
f01006a5:	e8 b5 fc ff ff       	call   f010035f <cons_intr>
}
f01006aa:	c9                   	leave  
f01006ab:	c3                   	ret    

f01006ac <kbd_intr>:
{
f01006ac:	55                   	push   %ebp
f01006ad:	89 e5                	mov    %esp,%ebp
f01006af:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01006b2:	b8 a2 03 10 f0       	mov    $0xf01003a2,%eax
f01006b7:	e8 a3 fc ff ff       	call   f010035f <cons_intr>
}
f01006bc:	c9                   	leave  
f01006bd:	c3                   	ret    

f01006be <cons_getc>:
{
f01006be:	55                   	push   %ebp
f01006bf:	89 e5                	mov    %esp,%ebp
f01006c1:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f01006c4:	e8 c7 ff ff ff       	call   f0100690 <serial_intr>
	kbd_intr();
f01006c9:	e8 de ff ff ff       	call   f01006ac <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01006ce:	a1 20 12 29 f0       	mov    0xf0291220,%eax
f01006d3:	3b 05 24 12 29 f0    	cmp    0xf0291224,%eax
f01006d9:	74 26                	je     f0100701 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01006db:	8d 50 01             	lea    0x1(%eax),%edx
f01006de:	89 15 20 12 29 f0    	mov    %edx,0xf0291220
f01006e4:	0f b6 80 20 10 29 f0 	movzbl -0xfd6efe0(%eax),%eax
		if (cons.rpos == CONSBUFSIZE)
f01006eb:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01006f1:	74 02                	je     f01006f5 <cons_getc+0x37>
}
f01006f3:	c9                   	leave  
f01006f4:	c3                   	ret    
			cons.rpos = 0;
f01006f5:	c7 05 20 12 29 f0 00 	movl   $0x0,0xf0291220
f01006fc:	00 00 00 
f01006ff:	eb f2                	jmp    f01006f3 <cons_getc+0x35>
	return 0;
f0100701:	b8 00 00 00 00       	mov    $0x0,%eax
f0100706:	eb eb                	jmp    f01006f3 <cons_getc+0x35>

f0100708 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100708:	55                   	push   %ebp
f0100709:	89 e5                	mov    %esp,%ebp
f010070b:	57                   	push   %edi
f010070c:	56                   	push   %esi
f010070d:	53                   	push   %ebx
f010070e:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f0100711:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f0100718:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010071f:	5a a5 
	if (*cp != 0xA55A) {
f0100721:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f0100727:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010072b:	0f 84 be 00 00 00    	je     f01007ef <cons_init+0xe7>
		addr_6845 = MONO_BASE;
f0100731:	c7 05 30 12 29 f0 b4 	movl   $0x3b4,0xf0291230
f0100738:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010073b:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f0100740:	8b 3d 30 12 29 f0    	mov    0xf0291230,%edi
f0100746:	b0 0e                	mov    $0xe,%al
f0100748:	89 fa                	mov    %edi,%edx
f010074a:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010074b:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010074e:	89 ca                	mov    %ecx,%edx
f0100750:	ec                   	in     (%dx),%al
f0100751:	0f b6 c0             	movzbl %al,%eax
f0100754:	c1 e0 08             	shl    $0x8,%eax
f0100757:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100759:	b0 0f                	mov    $0xf,%al
f010075b:	89 fa                	mov    %edi,%edx
f010075d:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010075e:	89 ca                	mov    %ecx,%edx
f0100760:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100761:	89 35 2c 12 29 f0    	mov    %esi,0xf029122c
	pos |= inb(addr_6845 + 1);
f0100767:	0f b6 c0             	movzbl %al,%eax
f010076a:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f010076c:	66 a3 28 12 29 f0    	mov    %ax,0xf0291228
	kbd_intr();
f0100772:	e8 35 ff ff ff       	call   f01006ac <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f0100777:	83 ec 0c             	sub    $0xc,%esp
f010077a:	66 a1 a8 23 12 f0    	mov    0xf01223a8,%ax
f0100780:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100785:	50                   	push   %eax
f0100786:	e8 a5 36 00 00       	call   f0103e30 <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010078b:	b1 00                	mov    $0x0,%cl
f010078d:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100792:	88 c8                	mov    %cl,%al
f0100794:	89 da                	mov    %ebx,%edx
f0100796:	ee                   	out    %al,(%dx)
f0100797:	bf fb 03 00 00       	mov    $0x3fb,%edi
f010079c:	b0 80                	mov    $0x80,%al
f010079e:	89 fa                	mov    %edi,%edx
f01007a0:	ee                   	out    %al,(%dx)
f01007a1:	b0 0c                	mov    $0xc,%al
f01007a3:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01007a8:	ee                   	out    %al,(%dx)
f01007a9:	be f9 03 00 00       	mov    $0x3f9,%esi
f01007ae:	88 c8                	mov    %cl,%al
f01007b0:	89 f2                	mov    %esi,%edx
f01007b2:	ee                   	out    %al,(%dx)
f01007b3:	b0 03                	mov    $0x3,%al
f01007b5:	89 fa                	mov    %edi,%edx
f01007b7:	ee                   	out    %al,(%dx)
f01007b8:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01007bd:	88 c8                	mov    %cl,%al
f01007bf:	ee                   	out    %al,(%dx)
f01007c0:	b0 01                	mov    $0x1,%al
f01007c2:	89 f2                	mov    %esi,%edx
f01007c4:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01007c5:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01007ca:	ec                   	in     (%dx),%al
f01007cb:	88 c1                	mov    %al,%cl
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01007cd:	83 c4 10             	add    $0x10,%esp
f01007d0:	3c ff                	cmp    $0xff,%al
f01007d2:	0f 95 05 34 12 29 f0 	setne  0xf0291234
f01007d9:	89 da                	mov    %ebx,%edx
f01007db:	ec                   	in     (%dx),%al
f01007dc:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01007e1:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01007e2:	80 f9 ff             	cmp    $0xff,%cl
f01007e5:	74 23                	je     f010080a <cons_init+0x102>
		cprintf("Serial port does not exist!\n");
}
f01007e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007ea:	5b                   	pop    %ebx
f01007eb:	5e                   	pop    %esi
f01007ec:	5f                   	pop    %edi
f01007ed:	5d                   	pop    %ebp
f01007ee:	c3                   	ret    
		*cp = was;
f01007ef:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01007f6:	c7 05 30 12 29 f0 d4 	movl   $0x3d4,0xf0291230
f01007fd:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100800:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f0100805:	e9 36 ff ff ff       	jmp    f0100740 <cons_init+0x38>
		cprintf("Serial port does not exist!\n");
f010080a:	83 ec 0c             	sub    $0xc,%esp
f010080d:	68 9c 68 10 f0       	push   $0xf010689c
f0100812:	e8 5e 37 00 00       	call   f0103f75 <cprintf>
f0100817:	83 c4 10             	add    $0x10,%esp
}
f010081a:	eb cb                	jmp    f01007e7 <cons_init+0xdf>

f010081c <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010081c:	55                   	push   %ebp
f010081d:	89 e5                	mov    %esp,%ebp
f010081f:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100822:	8b 45 08             	mov    0x8(%ebp),%eax
f0100825:	e8 8c fc ff ff       	call   f01004b6 <cons_putc>
}
f010082a:	c9                   	leave  
f010082b:	c3                   	ret    

f010082c <getchar>:

int
getchar(void)
{
f010082c:	55                   	push   %ebp
f010082d:	89 e5                	mov    %esp,%ebp
f010082f:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100832:	e8 87 fe ff ff       	call   f01006be <cons_getc>
f0100837:	85 c0                	test   %eax,%eax
f0100839:	74 f7                	je     f0100832 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010083b:	c9                   	leave  
f010083c:	c3                   	ret    

f010083d <iscons>:

int
iscons(int fdnum)
{
f010083d:	55                   	push   %ebp
f010083e:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100840:	b8 01 00 00 00       	mov    $0x1,%eax
f0100845:	5d                   	pop    %ebp
f0100846:	c3                   	ret    

f0100847 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100847:	55                   	push   %ebp
f0100848:	89 e5                	mov    %esp,%ebp
f010084a:	53                   	push   %ebx
f010084b:	83 ec 04             	sub    $0x4,%esp
f010084e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100853:	83 ec 04             	sub    $0x4,%esp
f0100856:	ff b3 c4 6f 10 f0    	pushl  -0xfef903c(%ebx)
f010085c:	ff b3 c0 6f 10 f0    	pushl  -0xfef9040(%ebx)
f0100862:	68 e0 6a 10 f0       	push   $0xf0106ae0
f0100867:	e8 09 37 00 00       	call   f0103f75 <cprintf>
f010086c:	83 c3 0c             	add    $0xc,%ebx
	for (i = 0; i < ARRAY_SIZE(commands); i++)
f010086f:	83 c4 10             	add    $0x10,%esp
f0100872:	83 fb 3c             	cmp    $0x3c,%ebx
f0100875:	75 dc                	jne    f0100853 <mon_help+0xc>
	return 0;
}
f0100877:	b8 00 00 00 00       	mov    $0x0,%eax
f010087c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010087f:	c9                   	leave  
f0100880:	c3                   	ret    

f0100881 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100881:	55                   	push   %ebp
f0100882:	89 e5                	mov    %esp,%ebp
f0100884:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100887:	68 e9 6a 10 f0       	push   $0xf0106ae9
f010088c:	e8 e4 36 00 00       	call   f0103f75 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100891:	83 c4 08             	add    $0x8,%esp
f0100894:	68 0c 00 10 00       	push   $0x10000c
f0100899:	68 40 6c 10 f0       	push   $0xf0106c40
f010089e:	e8 d2 36 00 00       	call   f0103f75 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01008a3:	83 c4 0c             	add    $0xc,%esp
f01008a6:	68 0c 00 10 00       	push   $0x10000c
f01008ab:	68 0c 00 10 f0       	push   $0xf010000c
f01008b0:	68 68 6c 10 f0       	push   $0xf0106c68
f01008b5:	e8 bb 36 00 00       	call   f0103f75 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01008ba:	83 c4 0c             	add    $0xc,%esp
f01008bd:	68 e0 66 10 00       	push   $0x1066e0
f01008c2:	68 e0 66 10 f0       	push   $0xf01066e0
f01008c7:	68 8c 6c 10 f0       	push   $0xf0106c8c
f01008cc:	e8 a4 36 00 00       	call   f0103f75 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01008d1:	83 c4 0c             	add    $0xc,%esp
f01008d4:	68 ec 0b 29 00       	push   $0x290bec
f01008d9:	68 ec 0b 29 f0       	push   $0xf0290bec
f01008de:	68 b0 6c 10 f0       	push   $0xf0106cb0
f01008e3:	e8 8d 36 00 00       	call   f0103f75 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01008e8:	83 c4 0c             	add    $0xc,%esp
f01008eb:	68 08 30 2d 00       	push   $0x2d3008
f01008f0:	68 08 30 2d f0       	push   $0xf02d3008
f01008f5:	68 d4 6c 10 f0       	push   $0xf0106cd4
f01008fa:	e8 76 36 00 00       	call   f0103f75 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008ff:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100902:	b8 07 34 2d f0       	mov    $0xf02d3407,%eax
f0100907:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f010090c:	c1 f8 0a             	sar    $0xa,%eax
f010090f:	50                   	push   %eax
f0100910:	68 f8 6c 10 f0       	push   $0xf0106cf8
f0100915:	e8 5b 36 00 00       	call   f0103f75 <cprintf>
	return 0;
}
f010091a:	b8 00 00 00 00       	mov    $0x0,%eax
f010091f:	c9                   	leave  
f0100920:	c3                   	ret    

f0100921 <mon_showmap>:
	}
	return 0;
}

int 
mon_showmap(int argc, char **argv, struct Trapframe *tf) {
f0100921:	55                   	push   %ebp
f0100922:	89 e5                	mov    %esp,%ebp
f0100924:	56                   	push   %esi
f0100925:	53                   	push   %ebx
f0100926:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc <= 2) {
f0100929:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f010092d:	7e 3c                	jle    f010096b <mon_showmap+0x4a>
		cprintf("Usage: showmap l r\n");
		return 0;
	}
	uintptr_t l = strtoul(argv[1], NULL, 0), 
f010092f:	83 ec 04             	sub    $0x4,%esp
f0100932:	6a 00                	push   $0x0
f0100934:	6a 00                	push   $0x0
f0100936:	ff 76 04             	pushl  0x4(%esi)
f0100939:	e8 91 52 00 00       	call   f0105bcf <strtoul>
f010093e:	89 c3                	mov    %eax,%ebx
		 	  r = strtoul(argv[2], NULL, 0); // In string.h
f0100940:	83 c4 0c             	add    $0xc,%esp
f0100943:	6a 00                	push   $0x0
f0100945:	6a 00                	push   $0x0
f0100947:	ff 76 08             	pushl  0x8(%esi)
f010094a:	e8 80 52 00 00       	call   f0105bcf <strtoul>
	if (l > r) {
f010094f:	83 c4 10             	add    $0x10,%esp
f0100952:	39 c3                	cmp    %eax,%ebx
f0100954:	77 31                	ja     f0100987 <mon_showmap+0x66>
		cprintf("Invalid range; aborting.\n");
		return 0;
	}
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f0100956:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f010095c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0100962:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100967:	89 c6                	mov    %eax,%esi
f0100969:	eb 45                	jmp    f01009b0 <mon_showmap+0x8f>
		cprintf("Usage: showmap l r\n");
f010096b:	83 ec 0c             	sub    $0xc,%esp
f010096e:	68 02 6b 10 f0       	push   $0xf0106b02
f0100973:	e8 fd 35 00 00       	call   f0103f75 <cprintf>
		return 0;
f0100978:	83 c4 10             	add    $0x10,%esp
		else 
			cprintf("0x%08x -> 0x%08x; perm = 0x%03x\n", 
					sz, PTE_ADDR(*pte), *pte & 0xFFF);
	}
	return 0;
}
f010097b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100980:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100983:	5b                   	pop    %ebx
f0100984:	5e                   	pop    %esi
f0100985:	5d                   	pop    %ebp
f0100986:	c3                   	ret    
		cprintf("Invalid range; aborting.\n");
f0100987:	83 ec 0c             	sub    $0xc,%esp
f010098a:	68 16 6b 10 f0       	push   $0xf0106b16
f010098f:	e8 e1 35 00 00       	call   f0103f75 <cprintf>
		return 0;
f0100994:	83 c4 10             	add    $0x10,%esp
f0100997:	eb e2                	jmp    f010097b <mon_showmap+0x5a>
			cprintf("0x%08x -> ----------; perm = ---\n", sz);
f0100999:	83 ec 08             	sub    $0x8,%esp
f010099c:	53                   	push   %ebx
f010099d:	68 24 6d 10 f0       	push   $0xf0106d24
f01009a2:	e8 ce 35 00 00       	call   f0103f75 <cprintf>
f01009a7:	83 c4 10             	add    $0x10,%esp
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f01009aa:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01009b0:	39 f3                	cmp    %esi,%ebx
f01009b2:	77 c7                	ja     f010097b <mon_showmap+0x5a>
		pte_t* pte = pgdir_walk(kern_pgdir, (void*) sz, 0);
f01009b4:	83 ec 04             	sub    $0x4,%esp
f01009b7:	6a 00                	push   $0x0
f01009b9:	53                   	push   %ebx
f01009ba:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f01009c0:	e8 ed 0a 00 00       	call   f01014b2 <pgdir_walk>
		if (pte == NULL || !*pte)
f01009c5:	83 c4 10             	add    $0x10,%esp
f01009c8:	85 c0                	test   %eax,%eax
f01009ca:	74 cd                	je     f0100999 <mon_showmap+0x78>
f01009cc:	8b 00                	mov    (%eax),%eax
f01009ce:	85 c0                	test   %eax,%eax
f01009d0:	74 c7                	je     f0100999 <mon_showmap+0x78>
			cprintf("0x%08x -> 0x%08x; perm = 0x%03x\n", 
f01009d2:	89 c2                	mov    %eax,%edx
f01009d4:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f01009da:	52                   	push   %edx
f01009db:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009e0:	50                   	push   %eax
f01009e1:	53                   	push   %ebx
f01009e2:	68 48 6d 10 f0       	push   $0xf0106d48
f01009e7:	e8 89 35 00 00       	call   f0103f75 <cprintf>
f01009ec:	83 c4 10             	add    $0x10,%esp
f01009ef:	eb b9                	jmp    f01009aa <mon_showmap+0x89>

f01009f1 <mon_chmod>:

int
mon_chmod(int argc, char **argv, struct Trapframe *tf) {
f01009f1:	55                   	push   %ebp
f01009f2:	89 e5                	mov    %esp,%ebp
f01009f4:	57                   	push   %edi
f01009f5:	56                   	push   %esi
f01009f6:	53                   	push   %ebx
f01009f7:	83 ec 1c             	sub    $0x1c,%esp
f01009fa:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc <= 2) {
f01009fd:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100a01:	7e 67                	jle    f0100a6a <mon_chmod+0x79>
		cprintf("Usage: chmod mod l [r] [-v]\n");
		return 0;
	}
	uintptr_t mod = strtoul(argv[1], NULL, 0),  
f0100a03:	83 ec 04             	sub    $0x4,%esp
f0100a06:	6a 00                	push   $0x0
f0100a08:	6a 00                	push   $0x0
f0100a0a:	ff 76 04             	pushl  0x4(%esi)
f0100a0d:	e8 bd 51 00 00       	call   f0105bcf <strtoul>
f0100a12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			  l = strtoul(argv[2], NULL, 0), 
f0100a15:	83 c4 0c             	add    $0xc,%esp
f0100a18:	6a 00                	push   $0x0
f0100a1a:	6a 00                	push   $0x0
f0100a1c:	ff 76 08             	pushl  0x8(%esi)
f0100a1f:	e8 ab 51 00 00       	call   f0105bcf <strtoul>
f0100a24:	89 c3                	mov    %eax,%ebx
			  r = argc >= 4 ? strtoul(argv[3], NULL, 0) : l;
f0100a26:	83 c4 10             	add    $0x10,%esp
f0100a29:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100a2d:	7f 58                	jg     f0100a87 <mon_chmod+0x96>
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
	if (mod > 0xFFF) {
f0100a2f:	81 7d e4 ff 0f 00 00 	cmpl   $0xfff,-0x1c(%ebp)
f0100a36:	0f 87 9a 00 00 00    	ja     f0100ad6 <mon_chmod+0xe5>
			  r = argc >= 4 ? strtoul(argv[3], NULL, 0) : l;
f0100a3c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
f0100a3f:	bf 00 00 00 00       	mov    $0x0,%edi
	}
	if (l > r) {
		cprintf("Invalid range; aborting.\n");
		return 0;
	}
	if (!(mod & PTE_P)) {
f0100a44:	f6 45 e4 01          	testb  $0x1,-0x1c(%ebp)
f0100a48:	0f 84 9a 00 00 00    	je     f0100ae8 <mon_chmod+0xf7>
		cprintf("Warning: PTE_P flag is not provided; added automatically.");
		mod |= PTE_P;
	}
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f0100a4e:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f0100a54:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0100a5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a5d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a62:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100a65:	e9 a1 00 00 00       	jmp    f0100b0b <mon_chmod+0x11a>
		cprintf("Usage: chmod mod l [r] [-v]\n");
f0100a6a:	83 ec 0c             	sub    $0xc,%esp
f0100a6d:	68 30 6b 10 f0       	push   $0xf0106b30
f0100a72:	e8 fe 34 00 00       	call   f0103f75 <cprintf>
		return 0;
f0100a77:	83 c4 10             	add    $0x10,%esp
						sz, *pte & 0xFFF, mod);
			*pte = PTE_ADDR(*pte) | mod;
		}
	}
	return 0;
}
f0100a7a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a82:	5b                   	pop    %ebx
f0100a83:	5e                   	pop    %esi
f0100a84:	5f                   	pop    %edi
f0100a85:	5d                   	pop    %ebp
f0100a86:	c3                   	ret    
			  r = argc >= 4 ? strtoul(argv[3], NULL, 0) : l;
f0100a87:	83 ec 04             	sub    $0x4,%esp
f0100a8a:	6a 00                	push   $0x0
f0100a8c:	6a 00                	push   $0x0
f0100a8e:	ff 76 0c             	pushl  0xc(%esi)
f0100a91:	e8 39 51 00 00       	call   f0105bcf <strtoul>
f0100a96:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
f0100a99:	83 c4 08             	add    $0x8,%esp
f0100a9c:	68 4d 6b 10 f0       	push   $0xf0106b4d
f0100aa1:	ff 76 0c             	pushl  0xc(%esi)
f0100aa4:	e8 bc 4e 00 00       	call   f0105965 <strcmp>
f0100aa9:	83 c4 10             	add    $0x10,%esp
f0100aac:	85 c0                	test   %eax,%eax
f0100aae:	0f 94 c0             	sete   %al
f0100ab1:	0f b6 c0             	movzbl %al,%eax
f0100ab4:	89 c7                	mov    %eax,%edi
	if (mod > 0xFFF) {
f0100ab6:	81 7d e4 ff 0f 00 00 	cmpl   $0xfff,-0x1c(%ebp)
f0100abd:	77 17                	ja     f0100ad6 <mon_chmod+0xe5>
	if (l > r) {
f0100abf:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0100ac2:	76 80                	jbe    f0100a44 <mon_chmod+0x53>
		cprintf("Invalid range; aborting.\n");
f0100ac4:	83 ec 0c             	sub    $0xc,%esp
f0100ac7:	68 16 6b 10 f0       	push   $0xf0106b16
f0100acc:	e8 a4 34 00 00       	call   f0103f75 <cprintf>
		return 0;
f0100ad1:	83 c4 10             	add    $0x10,%esp
f0100ad4:	eb a4                	jmp    f0100a7a <mon_chmod+0x89>
		cprintf("Permission exceeds 0xfff; aborting.\n");
f0100ad6:	83 ec 0c             	sub    $0xc,%esp
f0100ad9:	68 6c 6d 10 f0       	push   $0xf0106d6c
f0100ade:	e8 92 34 00 00       	call   f0103f75 <cprintf>
		return 0;
f0100ae3:	83 c4 10             	add    $0x10,%esp
f0100ae6:	eb 92                	jmp    f0100a7a <mon_chmod+0x89>
		cprintf("Warning: PTE_P flag is not provided; added automatically.");
f0100ae8:	83 ec 0c             	sub    $0xc,%esp
f0100aeb:	68 94 6d 10 f0       	push   $0xf0106d94
f0100af0:	e8 80 34 00 00       	call   f0103f75 <cprintf>
		mod |= PTE_P;
f0100af5:	83 4d e4 01          	orl    $0x1,-0x1c(%ebp)
f0100af9:	83 c4 10             	add    $0x10,%esp
f0100afc:	e9 4d ff ff ff       	jmp    f0100a4e <mon_chmod+0x5d>
			if (verbose)
f0100b01:	85 ff                	test   %edi,%edi
f0100b03:	75 41                	jne    f0100b46 <mon_chmod+0x155>
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f0100b05:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100b0b:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0100b0e:	0f 87 66 ff ff ff    	ja     f0100a7a <mon_chmod+0x89>
		pte_t* pte = pgdir_walk(kern_pgdir, (void*) sz, 0);
f0100b14:	83 ec 04             	sub    $0x4,%esp
f0100b17:	6a 00                	push   $0x0
f0100b19:	53                   	push   %ebx
f0100b1a:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f0100b20:	e8 8d 09 00 00       	call   f01014b2 <pgdir_walk>
f0100b25:	89 c6                	mov    %eax,%esi
		if (pte == NULL || !*pte) {
f0100b27:	83 c4 10             	add    $0x10,%esp
f0100b2a:	85 c0                	test   %eax,%eax
f0100b2c:	74 d3                	je     f0100b01 <mon_chmod+0x110>
f0100b2e:	8b 00                	mov    (%eax),%eax
f0100b30:	85 c0                	test   %eax,%eax
f0100b32:	74 cd                	je     f0100b01 <mon_chmod+0x110>
			if (verbose) 
f0100b34:	85 ff                	test   %edi,%edi
f0100b36:	75 21                	jne    f0100b59 <mon_chmod+0x168>
			*pte = PTE_ADDR(*pte) | mod;
f0100b38:	8b 06                	mov    (%esi),%eax
f0100b3a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b3f:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0100b42:	89 06                	mov    %eax,(%esi)
f0100b44:	eb bf                	jmp    f0100b05 <mon_chmod+0x114>
				cprintf("Page va = 0x%08x is not mapped; skipping.\n", sz);
f0100b46:	83 ec 08             	sub    $0x8,%esp
f0100b49:	53                   	push   %ebx
f0100b4a:	68 d0 6d 10 f0       	push   $0xf0106dd0
f0100b4f:	e8 21 34 00 00       	call   f0103f75 <cprintf>
f0100b54:	83 c4 10             	add    $0x10,%esp
f0100b57:	eb ac                	jmp    f0100b05 <mon_chmod+0x114>
				cprintf("Page va = 0x%08x perm = 0x%03x changed to 0x%03x\n", 
f0100b59:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100b5c:	25 ff 0f 00 00       	and    $0xfff,%eax
f0100b61:	50                   	push   %eax
f0100b62:	53                   	push   %ebx
f0100b63:	68 fc 6d 10 f0       	push   $0xf0106dfc
f0100b68:	e8 08 34 00 00       	call   f0103f75 <cprintf>
f0100b6d:	83 c4 10             	add    $0x10,%esp
f0100b70:	eb c6                	jmp    f0100b38 <mon_chmod+0x147>

f0100b72 <mon_dump>:

int
mon_dump(int argc, char **argv, struct Trapframe *tf) {
f0100b72:	55                   	push   %ebp
f0100b73:	89 e5                	mov    %esp,%ebp
f0100b75:	57                   	push   %edi
f0100b76:	56                   	push   %esi
f0100b77:	53                   	push   %ebx
f0100b78:	83 ec 1c             	sub    $0x1c,%esp
f0100b7b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (argc <= 2 || argc > 4) {
f0100b7e:	8d 43 fd             	lea    -0x3(%ebx),%eax
f0100b81:	83 f8 01             	cmp    $0x1,%eax
f0100b84:	76 1d                	jbe    f0100ba3 <mon_dump+0x31>
		cprintf("Usage: dump l r [-v/-p]\n");
f0100b86:	83 ec 0c             	sub    $0xc,%esp
f0100b89:	68 50 6b 10 f0       	push   $0xf0106b50
f0100b8e:	e8 e2 33 00 00       	call   f0103f75 <cprintf>
		return 0;
f0100b93:	83 c4 10             	add    $0x10,%esp
		cprintf("|\n");
	}
	if (ROUNDDOWN(r, 16) != r)
		cprintf("%08x  \n", r);
	return 0;
}
f0100b96:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b9e:	5b                   	pop    %ebx
f0100b9f:	5e                   	pop    %esi
f0100ba0:	5f                   	pop    %edi
f0100ba1:	5d                   	pop    %ebp
f0100ba2:	c3                   	ret    
	unsigned long l = strtoul(argv[1], NULL, 0),
f0100ba3:	83 ec 04             	sub    $0x4,%esp
f0100ba6:	6a 00                	push   $0x0
f0100ba8:	6a 00                	push   $0x0
f0100baa:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100bad:	ff 70 04             	pushl  0x4(%eax)
f0100bb0:	e8 1a 50 00 00       	call   f0105bcf <strtoul>
f0100bb5:	89 c6                	mov    %eax,%esi
			  	  r = strtoul(argv[2], NULL, 0);
f0100bb7:	83 c4 0c             	add    $0xc,%esp
f0100bba:	6a 00                	push   $0x0
f0100bbc:	6a 00                	push   $0x0
f0100bbe:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100bc1:	ff 70 08             	pushl  0x8(%eax)
f0100bc4:	e8 06 50 00 00       	call   f0105bcf <strtoul>
f0100bc9:	89 c7                	mov    %eax,%edi
	if (argc <= 3)
f0100bcb:	83 c4 10             	add    $0x10,%esp
f0100bce:	83 fb 03             	cmp    $0x3,%ebx
f0100bd1:	7f 18                	jg     f0100beb <mon_dump+0x79>
		cprintf("Defaulting to virtual address.\n");
f0100bd3:	83 ec 0c             	sub    $0xc,%esp
f0100bd6:	68 30 6e 10 f0       	push   $0xf0106e30
f0100bdb:	e8 95 33 00 00       	call   f0103f75 <cprintf>
f0100be0:	83 c4 10             	add    $0x10,%esp
	for (ptr = ROUNDDOWN(l, 16); ptr <= r; ptr += 16) {
f0100be3:	83 e6 f0             	and    $0xfffffff0,%esi
f0100be6:	e9 31 01 00 00       	jmp    f0100d1c <mon_dump+0x1aa>
	else if (!strcmp(argv[3], "-p"))
f0100beb:	83 ec 08             	sub    $0x8,%esp
f0100bee:	68 69 6b 10 f0       	push   $0xf0106b69
f0100bf3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100bf6:	ff 70 0c             	pushl  0xc(%eax)
f0100bf9:	e8 67 4d 00 00       	call   f0105965 <strcmp>
f0100bfe:	83 c4 10             	add    $0x10,%esp
f0100c01:	85 c0                	test   %eax,%eax
f0100c03:	75 4f                	jne    f0100c54 <mon_dump+0xe2>
	if (PGNUM(pa) >= npages)
f0100c05:	a1 88 1e 29 f0       	mov    0xf0291e88,%eax
f0100c0a:	89 f2                	mov    %esi,%edx
f0100c0c:	c1 ea 0c             	shr    $0xc,%edx
f0100c0f:	39 c2                	cmp    %eax,%edx
f0100c11:	73 17                	jae    f0100c2a <mon_dump+0xb8>
	return (void *)(pa + KERNBASE);
f0100c13:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
	if (PGNUM(pa) >= npages)
f0100c19:	89 fa                	mov    %edi,%edx
f0100c1b:	c1 ea 0c             	shr    $0xc,%edx
f0100c1e:	39 c2                	cmp    %eax,%edx
f0100c20:	73 1d                	jae    f0100c3f <mon_dump+0xcd>
	return (void *)(pa + KERNBASE);
f0100c22:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
f0100c28:	eb b9                	jmp    f0100be3 <mon_dump+0x71>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c2a:	56                   	push   %esi
f0100c2b:	68 48 68 10 f0       	push   $0xf0106848
f0100c30:	68 9d 00 00 00       	push   $0x9d
f0100c35:	68 6c 6b 10 f0       	push   $0xf0106b6c
f0100c3a:	e8 55 f4 ff ff       	call   f0100094 <_panic>
f0100c3f:	57                   	push   %edi
f0100c40:	68 48 68 10 f0       	push   $0xf0106848
f0100c45:	68 9d 00 00 00       	push   $0x9d
f0100c4a:	68 6c 6b 10 f0       	push   $0xf0106b6c
f0100c4f:	e8 40 f4 ff ff       	call   f0100094 <_panic>
	else if (strcmp(argv[3], "-v")) {
f0100c54:	83 ec 08             	sub    $0x8,%esp
f0100c57:	68 4d 6b 10 f0       	push   $0xf0106b4d
f0100c5c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c5f:	ff 70 0c             	pushl  0xc(%eax)
f0100c62:	e8 fe 4c 00 00       	call   f0105965 <strcmp>
f0100c67:	83 c4 10             	add    $0x10,%esp
f0100c6a:	85 c0                	test   %eax,%eax
f0100c6c:	0f 84 71 ff ff ff    	je     f0100be3 <mon_dump+0x71>
		cprintf("Unknown flag %s at position 3; aborting.\n", argv[3]);
f0100c72:	83 ec 08             	sub    $0x8,%esp
f0100c75:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c78:	ff 70 0c             	pushl  0xc(%eax)
f0100c7b:	68 50 6e 10 f0       	push   $0xf0106e50
f0100c80:	e8 f0 32 00 00       	call   f0103f75 <cprintf>
		return 0;
f0100c85:	83 c4 10             	add    $0x10,%esp
f0100c88:	e9 09 ff ff ff       	jmp    f0100b96 <mon_dump+0x24>
				cprintf("   ");
f0100c8d:	83 ec 0c             	sub    $0xc,%esp
f0100c90:	68 88 6b 10 f0       	push   $0xf0106b88
f0100c95:	e8 db 32 00 00       	call   f0103f75 <cprintf>
f0100c9a:	83 c4 10             	add    $0x10,%esp
f0100c9d:	43                   	inc    %ebx
		for (int i = 0; i < 16; i++) {
f0100c9e:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0100ca1:	74 1a                	je     f0100cbd <mon_dump+0x14b>
			if (ptr + i <= r)
f0100ca3:	39 df                	cmp    %ebx,%edi
f0100ca5:	72 e6                	jb     f0100c8d <mon_dump+0x11b>
				cprintf("%02x ", *(unsigned char*)(ptr + i));
f0100ca7:	83 ec 08             	sub    $0x8,%esp
f0100caa:	0f b6 03             	movzbl (%ebx),%eax
f0100cad:	50                   	push   %eax
f0100cae:	68 82 6b 10 f0       	push   $0xf0106b82
f0100cb3:	e8 bd 32 00 00       	call   f0103f75 <cprintf>
f0100cb8:	83 c4 10             	add    $0x10,%esp
f0100cbb:	eb e0                	jmp    f0100c9d <mon_dump+0x12b>
		cprintf(" |");
f0100cbd:	83 ec 0c             	sub    $0xc,%esp
f0100cc0:	68 8c 6b 10 f0       	push   $0xf0106b8c
f0100cc5:	e8 ab 32 00 00       	call   f0103f75 <cprintf>
f0100cca:	83 c4 10             	add    $0x10,%esp
f0100ccd:	eb 19                	jmp    f0100ce8 <mon_dump+0x176>
				cprintf("%c", (ch >= ' ' && ch <= '~') ? ch : '.');
f0100ccf:	83 ec 08             	sub    $0x8,%esp
f0100cd2:	0f be c0             	movsbl %al,%eax
f0100cd5:	50                   	push   %eax
f0100cd6:	68 8f 6b 10 f0       	push   $0xf0106b8f
f0100cdb:	e8 95 32 00 00       	call   f0103f75 <cprintf>
f0100ce0:	83 c4 10             	add    $0x10,%esp
f0100ce3:	46                   	inc    %esi
		for (int i = 0; i < 16; i++) {
f0100ce4:	39 de                	cmp    %ebx,%esi
f0100ce6:	74 24                	je     f0100d0c <mon_dump+0x19a>
			if (ptr + i <= r) {
f0100ce8:	39 f7                	cmp    %esi,%edi
f0100cea:	72 0e                	jb     f0100cfa <mon_dump+0x188>
				char ch = *(char*)(ptr + i);
f0100cec:	8a 06                	mov    (%esi),%al
				cprintf("%c", (ch >= ' ' && ch <= '~') ? ch : '.');
f0100cee:	8d 50 e0             	lea    -0x20(%eax),%edx
f0100cf1:	80 fa 5e             	cmp    $0x5e,%dl
f0100cf4:	76 d9                	jbe    f0100ccf <mon_dump+0x15d>
f0100cf6:	b0 2e                	mov    $0x2e,%al
f0100cf8:	eb d5                	jmp    f0100ccf <mon_dump+0x15d>
				cprintf(" ");
f0100cfa:	83 ec 0c             	sub    $0xc,%esp
f0100cfd:	68 cc 6b 10 f0       	push   $0xf0106bcc
f0100d02:	e8 6e 32 00 00       	call   f0103f75 <cprintf>
f0100d07:	83 c4 10             	add    $0x10,%esp
f0100d0a:	eb d7                	jmp    f0100ce3 <mon_dump+0x171>
		cprintf("|\n");
f0100d0c:	83 ec 0c             	sub    $0xc,%esp
f0100d0f:	68 92 6b 10 f0       	push   $0xf0106b92
f0100d14:	e8 5c 32 00 00       	call   f0103f75 <cprintf>
	for (ptr = ROUNDDOWN(l, 16); ptr <= r; ptr += 16) {
f0100d19:	83 c4 10             	add    $0x10,%esp
f0100d1c:	39 f7                	cmp    %esi,%edi
f0100d1e:	72 1e                	jb     f0100d3e <mon_dump+0x1cc>
		cprintf("%08x  ", ptr);
f0100d20:	83 ec 08             	sub    $0x8,%esp
f0100d23:	56                   	push   %esi
f0100d24:	68 7b 6b 10 f0       	push   $0xf0106b7b
f0100d29:	e8 47 32 00 00       	call   f0103f75 <cprintf>
f0100d2e:	8d 46 10             	lea    0x10(%esi),%eax
f0100d31:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100d34:	83 c4 10             	add    $0x10,%esp
f0100d37:	89 f3                	mov    %esi,%ebx
f0100d39:	e9 65 ff ff ff       	jmp    f0100ca3 <mon_dump+0x131>
	if (ROUNDDOWN(r, 16) != r)
f0100d3e:	f7 c7 0f 00 00 00    	test   $0xf,%edi
f0100d44:	0f 84 4c fe ff ff    	je     f0100b96 <mon_dump+0x24>
		cprintf("%08x  \n", r);
f0100d4a:	83 ec 08             	sub    $0x8,%esp
f0100d4d:	57                   	push   %edi
f0100d4e:	68 95 6b 10 f0       	push   $0xf0106b95
f0100d53:	e8 1d 32 00 00       	call   f0103f75 <cprintf>
f0100d58:	83 c4 10             	add    $0x10,%esp
f0100d5b:	e9 36 fe ff ff       	jmp    f0100b96 <mon_dump+0x24>

f0100d60 <mon_backtrace>:
{
f0100d60:	55                   	push   %ebp
f0100d61:	89 e5                	mov    %esp,%ebp
f0100d63:	57                   	push   %edi
f0100d64:	56                   	push   %esi
f0100d65:	53                   	push   %ebx
f0100d66:	83 ec 38             	sub    $0x38,%esp
	cprintf("Stack backtrace:\n");
f0100d69:	68 9d 6b 10 f0       	push   $0xf0106b9d
f0100d6e:	e8 02 32 00 00       	call   f0103f75 <cprintf>
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100d73:	89 e8                	mov    %ebp,%eax
	while (ebp != 0) {
f0100d75:	83 c4 10             	add    $0x10,%esp
f0100d78:	eb 34                	jmp    f0100dae <mon_backtrace+0x4e>
			cprintf("%c", info.eip_fn_name[i]);
f0100d7a:	83 ec 08             	sub    $0x8,%esp
f0100d7d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100d80:	0f be 04 18          	movsbl (%eax,%ebx,1),%eax
f0100d84:	50                   	push   %eax
f0100d85:	68 8f 6b 10 f0       	push   $0xf0106b8f
f0100d8a:	e8 e6 31 00 00       	call   f0103f75 <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f0100d8f:	43                   	inc    %ebx
f0100d90:	83 c4 10             	add    $0x10,%esp
f0100d93:	39 5d dc             	cmp    %ebx,-0x24(%ebp)
f0100d96:	7f e2                	jg     f0100d7a <mon_backtrace+0x1a>
		cprintf("+%d\n", eip - info.eip_fn_addr);
f0100d98:	83 ec 08             	sub    $0x8,%esp
f0100d9b:	2b 75 e0             	sub    -0x20(%ebp),%esi
f0100d9e:	56                   	push   %esi
f0100d9f:	68 c0 6b 10 f0       	push   $0xf0106bc0
f0100da4:	e8 cc 31 00 00       	call   f0103f75 <cprintf>
		ebp = prev_ebp;
f0100da9:	83 c4 10             	add    $0x10,%esp
f0100dac:	89 f8                	mov    %edi,%eax
	while (ebp != 0) {
f0100dae:	85 c0                	test   %eax,%eax
f0100db0:	74 4a                	je     f0100dfc <mon_backtrace+0x9c>
		prev_ebp = *(int*)ebp;
f0100db2:	8b 38                	mov    (%eax),%edi
		eip = *((int*)ebp + 1);
f0100db4:	8b 70 04             	mov    0x4(%eax),%esi
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, 
f0100db7:	ff 70 18             	pushl  0x18(%eax)
f0100dba:	ff 70 14             	pushl  0x14(%eax)
f0100dbd:	ff 70 10             	pushl  0x10(%eax)
f0100dc0:	ff 70 0c             	pushl  0xc(%eax)
f0100dc3:	ff 70 08             	pushl  0x8(%eax)
f0100dc6:	56                   	push   %esi
f0100dc7:	50                   	push   %eax
f0100dc8:	68 7c 6e 10 f0       	push   $0xf0106e7c
f0100dcd:	e8 a3 31 00 00       	call   f0103f75 <cprintf>
		int code = debuginfo_eip((uintptr_t)eip, &info);
f0100dd2:	83 c4 18             	add    $0x18,%esp
f0100dd5:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100dd8:	50                   	push   %eax
f0100dd9:	56                   	push   %esi
f0100dda:	e8 ce 41 00 00       	call   f0104fad <debuginfo_eip>
		cprintf("         %s:%d: ", info.eip_file, info.eip_line);
f0100ddf:	83 c4 0c             	add    $0xc,%esp
f0100de2:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100de5:	ff 75 d0             	pushl  -0x30(%ebp)
f0100de8:	68 af 6b 10 f0       	push   $0xf0106baf
f0100ded:	e8 83 31 00 00       	call   f0103f75 <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f0100df2:	83 c4 10             	add    $0x10,%esp
f0100df5:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100dfa:	eb 97                	jmp    f0100d93 <mon_backtrace+0x33>
}
f0100dfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100dff:	5b                   	pop    %ebx
f0100e00:	5e                   	pop    %esi
f0100e01:	5f                   	pop    %edi
f0100e02:	5d                   	pop    %ebp
f0100e03:	c3                   	ret    

f0100e04 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100e04:	55                   	push   %ebp
f0100e05:	89 e5                	mov    %esp,%ebp
f0100e07:	57                   	push   %edi
f0100e08:	56                   	push   %esi
f0100e09:	53                   	push   %ebx
f0100e0a:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100e0d:	68 b4 6e 10 f0       	push   $0xf0106eb4
f0100e12:	e8 5e 31 00 00       	call   f0103f75 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100e17:	c7 04 24 d8 6e 10 f0 	movl   $0xf0106ed8,(%esp)
f0100e1e:	e8 52 31 00 00       	call   f0103f75 <cprintf>

	if (tf != NULL)
f0100e23:	83 c4 10             	add    $0x10,%esp
f0100e26:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100e2a:	74 57                	je     f0100e83 <monitor+0x7f>
		print_trapframe(tf);
f0100e2c:	83 ec 0c             	sub    $0xc,%esp
f0100e2f:	ff 75 08             	pushl  0x8(%ebp)
f0100e32:	e8 be 35 00 00       	call   f01043f5 <print_trapframe>
f0100e37:	83 c4 10             	add    $0x10,%esp
f0100e3a:	eb 47                	jmp    f0100e83 <monitor+0x7f>
		while (*buf && strchr(WHITESPACE, *buf))
f0100e3c:	83 ec 08             	sub    $0x8,%esp
f0100e3f:	0f be c0             	movsbl %al,%eax
f0100e42:	50                   	push   %eax
f0100e43:	68 c9 6b 10 f0       	push   $0xf0106bc9
f0100e48:	e8 6c 4b 00 00       	call   f01059b9 <strchr>
f0100e4d:	83 c4 10             	add    $0x10,%esp
f0100e50:	85 c0                	test   %eax,%eax
f0100e52:	74 0a                	je     f0100e5e <monitor+0x5a>
			*buf++ = 0;
f0100e54:	c6 03 00             	movb   $0x0,(%ebx)
f0100e57:	89 f7                	mov    %esi,%edi
f0100e59:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100e5c:	eb 68                	jmp    f0100ec6 <monitor+0xc2>
		if (*buf == 0)
f0100e5e:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100e61:	74 6f                	je     f0100ed2 <monitor+0xce>
		if (argc == MAXARGS-1) {
f0100e63:	83 fe 0f             	cmp    $0xf,%esi
f0100e66:	74 09                	je     f0100e71 <monitor+0x6d>
		argv[argc++] = buf;
f0100e68:	8d 7e 01             	lea    0x1(%esi),%edi
f0100e6b:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100e6f:	eb 37                	jmp    f0100ea8 <monitor+0xa4>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100e71:	83 ec 08             	sub    $0x8,%esp
f0100e74:	6a 10                	push   $0x10
f0100e76:	68 ce 6b 10 f0       	push   $0xf0106bce
f0100e7b:	e8 f5 30 00 00       	call   f0103f75 <cprintf>
f0100e80:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100e83:	83 ec 0c             	sub    $0xc,%esp
f0100e86:	68 c5 6b 10 f0       	push   $0xf0106bc5
f0100e8b:	e8 1e 49 00 00       	call   f01057ae <readline>
f0100e90:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100e92:	83 c4 10             	add    $0x10,%esp
f0100e95:	85 c0                	test   %eax,%eax
f0100e97:	74 ea                	je     f0100e83 <monitor+0x7f>
	argv[argc] = 0;
f0100e99:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100ea0:	be 00 00 00 00       	mov    $0x0,%esi
f0100ea5:	eb 21                	jmp    f0100ec8 <monitor+0xc4>
			buf++;
f0100ea7:	43                   	inc    %ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100ea8:	8a 03                	mov    (%ebx),%al
f0100eaa:	84 c0                	test   %al,%al
f0100eac:	74 18                	je     f0100ec6 <monitor+0xc2>
f0100eae:	83 ec 08             	sub    $0x8,%esp
f0100eb1:	0f be c0             	movsbl %al,%eax
f0100eb4:	50                   	push   %eax
f0100eb5:	68 c9 6b 10 f0       	push   $0xf0106bc9
f0100eba:	e8 fa 4a 00 00       	call   f01059b9 <strchr>
f0100ebf:	83 c4 10             	add    $0x10,%esp
f0100ec2:	85 c0                	test   %eax,%eax
f0100ec4:	74 e1                	je     f0100ea7 <monitor+0xa3>
			*buf++ = 0;
f0100ec6:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100ec8:	8a 03                	mov    (%ebx),%al
f0100eca:	84 c0                	test   %al,%al
f0100ecc:	0f 85 6a ff ff ff    	jne    f0100e3c <monitor+0x38>
	argv[argc] = 0;
f0100ed2:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100ed9:	00 
	if (argc == 0)
f0100eda:	85 f6                	test   %esi,%esi
f0100edc:	74 a5                	je     f0100e83 <monitor+0x7f>
f0100ede:	bf c0 6f 10 f0       	mov    $0xf0106fc0,%edi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100ee3:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f0100ee8:	83 ec 08             	sub    $0x8,%esp
f0100eeb:	ff 37                	pushl  (%edi)
f0100eed:	ff 75 a8             	pushl  -0x58(%ebp)
f0100ef0:	e8 70 4a 00 00       	call   f0105965 <strcmp>
f0100ef5:	83 c4 10             	add    $0x10,%esp
f0100ef8:	85 c0                	test   %eax,%eax
f0100efa:	74 21                	je     f0100f1d <monitor+0x119>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100efc:	43                   	inc    %ebx
f0100efd:	83 c7 0c             	add    $0xc,%edi
f0100f00:	83 fb 05             	cmp    $0x5,%ebx
f0100f03:	75 e3                	jne    f0100ee8 <monitor+0xe4>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100f05:	83 ec 08             	sub    $0x8,%esp
f0100f08:	ff 75 a8             	pushl  -0x58(%ebp)
f0100f0b:	68 eb 6b 10 f0       	push   $0xf0106beb
f0100f10:	e8 60 30 00 00       	call   f0103f75 <cprintf>
f0100f15:	83 c4 10             	add    $0x10,%esp
f0100f18:	e9 66 ff ff ff       	jmp    f0100e83 <monitor+0x7f>
			return commands[i].func(argc, argv, tf);
f0100f1d:	83 ec 04             	sub    $0x4,%esp
f0100f20:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100f23:	01 c3                	add    %eax,%ebx
f0100f25:	ff 75 08             	pushl  0x8(%ebp)
f0100f28:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100f2b:	50                   	push   %eax
f0100f2c:	56                   	push   %esi
f0100f2d:	ff 14 9d c8 6f 10 f0 	call   *-0xfef9038(,%ebx,4)
			if (runcmd(buf, tf) < 0)
f0100f34:	83 c4 10             	add    $0x10,%esp
f0100f37:	85 c0                	test   %eax,%eax
f0100f39:	0f 89 44 ff ff ff    	jns    f0100e83 <monitor+0x7f>
				break;
	}
}
f0100f3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f42:	5b                   	pop    %ebx
f0100f43:	5e                   	pop    %esi
f0100f44:	5f                   	pop    %edi
f0100f45:	5d                   	pop    %ebp
f0100f46:	c3                   	ret    

f0100f47 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100f47:	55                   	push   %ebp
f0100f48:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100f4a:	83 3d 38 12 29 f0 00 	cmpl   $0x0,0xf0291238
f0100f51:	74 1f                	je     f0100f72 <boot_alloc+0x2b>
	}

	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	if (!n)
f0100f53:	85 c0                	test   %eax,%eax
f0100f55:	74 2e                	je     f0100f85 <boot_alloc+0x3e>
		return (void*)nextfree;
	else {
		result = nextfree;
f0100f57:	8b 15 38 12 29 f0    	mov    0xf0291238,%edx
		nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100f5d:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100f64:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f69:	a3 38 12 29 f0       	mov    %eax,0xf0291238
		return (void*)result;
	}
}
f0100f6e:	89 d0                	mov    %edx,%eax
f0100f70:	5d                   	pop    %ebp
f0100f71:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100f72:	ba 07 40 2d f0       	mov    $0xf02d4007,%edx
f0100f77:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100f7d:	89 15 38 12 29 f0    	mov    %edx,0xf0291238
f0100f83:	eb ce                	jmp    f0100f53 <boot_alloc+0xc>
		return (void*)nextfree;
f0100f85:	8b 15 38 12 29 f0    	mov    0xf0291238,%edx
f0100f8b:	eb e1                	jmp    f0100f6e <boot_alloc+0x27>

f0100f8d <nvram_read>:
{
f0100f8d:	55                   	push   %ebp
f0100f8e:	89 e5                	mov    %esp,%ebp
f0100f90:	56                   	push   %esi
f0100f91:	53                   	push   %ebx
f0100f92:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100f94:	83 ec 0c             	sub    $0xc,%esp
f0100f97:	50                   	push   %eax
f0100f98:	e8 65 2e 00 00       	call   f0103e02 <mc146818_read>
f0100f9d:	89 c3                	mov    %eax,%ebx
f0100f9f:	46                   	inc    %esi
f0100fa0:	89 34 24             	mov    %esi,(%esp)
f0100fa3:	e8 5a 2e 00 00       	call   f0103e02 <mc146818_read>
f0100fa8:	c1 e0 08             	shl    $0x8,%eax
f0100fab:	09 d8                	or     %ebx,%eax
}
f0100fad:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100fb0:	5b                   	pop    %ebx
f0100fb1:	5e                   	pop    %esi
f0100fb2:	5d                   	pop    %ebp
f0100fb3:	c3                   	ret    

f0100fb4 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100fb4:	89 d1                	mov    %edx,%ecx
f0100fb6:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100fb9:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100fbc:	a8 01                	test   $0x1,%al
f0100fbe:	74 47                	je     f0101007 <check_va2pa+0x53>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100fc0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100fc5:	89 c1                	mov    %eax,%ecx
f0100fc7:	c1 e9 0c             	shr    $0xc,%ecx
f0100fca:	3b 0d 88 1e 29 f0    	cmp    0xf0291e88,%ecx
f0100fd0:	73 1a                	jae    f0100fec <check_va2pa+0x38>
	if (!(p[PTX(va)] & PTE_P))
f0100fd2:	c1 ea 0c             	shr    $0xc,%edx
f0100fd5:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100fdb:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100fe2:	a8 01                	test   $0x1,%al
f0100fe4:	74 27                	je     f010100d <check_va2pa+0x59>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100fe6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100feb:	c3                   	ret    
{
f0100fec:	55                   	push   %ebp
f0100fed:	89 e5                	mov    %esp,%ebp
f0100fef:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ff2:	50                   	push   %eax
f0100ff3:	68 48 68 10 f0       	push   $0xf0106848
f0100ff8:	68 69 03 00 00       	push   $0x369
f0100ffd:	68 1d 79 10 f0       	push   $0xf010791d
f0101002:	e8 8d f0 ff ff       	call   f0100094 <_panic>
		return ~0;
f0101007:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010100c:	c3                   	ret    
		return ~0;
f010100d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0101012:	c3                   	ret    

f0101013 <check_page_free_list>:
{
f0101013:	55                   	push   %ebp
f0101014:	89 e5                	mov    %esp,%ebp
f0101016:	57                   	push   %edi
f0101017:	56                   	push   %esi
f0101018:	53                   	push   %ebx
f0101019:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010101c:	84 c0                	test   %al,%al
f010101e:	0f 85 80 02 00 00    	jne    f01012a4 <check_page_free_list+0x291>
	if (!page_free_list)
f0101024:	83 3d 40 12 29 f0 00 	cmpl   $0x0,0xf0291240
f010102b:	74 0a                	je     f0101037 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010102d:	be 00 04 00 00       	mov    $0x400,%esi
f0101032:	e9 c8 02 00 00       	jmp    f01012ff <check_page_free_list+0x2ec>
		panic("'page_free_list' is a null pointer!");
f0101037:	83 ec 04             	sub    $0x4,%esp
f010103a:	68 fc 6f 10 f0       	push   $0xf0106ffc
f010103f:	68 9c 02 00 00       	push   $0x29c
f0101044:	68 1d 79 10 f0       	push   $0xf010791d
f0101049:	e8 46 f0 ff ff       	call   f0100094 <_panic>
f010104e:	50                   	push   %eax
f010104f:	68 48 68 10 f0       	push   $0xf0106848
f0101054:	6a 58                	push   $0x58
f0101056:	68 29 79 10 f0       	push   $0xf0107929
f010105b:	e8 34 f0 ff ff       	call   f0100094 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101060:	8b 1b                	mov    (%ebx),%ebx
f0101062:	85 db                	test   %ebx,%ebx
f0101064:	74 41                	je     f01010a7 <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101066:	89 d8                	mov    %ebx,%eax
f0101068:	2b 05 90 1e 29 f0    	sub    0xf0291e90,%eax
f010106e:	c1 f8 03             	sar    $0x3,%eax
f0101071:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0101074:	89 c2                	mov    %eax,%edx
f0101076:	c1 ea 16             	shr    $0x16,%edx
f0101079:	39 f2                	cmp    %esi,%edx
f010107b:	73 e3                	jae    f0101060 <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f010107d:	89 c2                	mov    %eax,%edx
f010107f:	c1 ea 0c             	shr    $0xc,%edx
f0101082:	3b 15 88 1e 29 f0    	cmp    0xf0291e88,%edx
f0101088:	73 c4                	jae    f010104e <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f010108a:	83 ec 04             	sub    $0x4,%esp
f010108d:	68 80 00 00 00       	push   $0x80
f0101092:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0101097:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010109c:	50                   	push   %eax
f010109d:	e8 4c 49 00 00       	call   f01059ee <memset>
f01010a2:	83 c4 10             	add    $0x10,%esp
f01010a5:	eb b9                	jmp    f0101060 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f01010a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01010ac:	e8 96 fe ff ff       	call   f0100f47 <boot_alloc>
f01010b1:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010b4:	8b 15 40 12 29 f0    	mov    0xf0291240,%edx
		assert(pp >= pages);
f01010ba:	8b 0d 90 1e 29 f0    	mov    0xf0291e90,%ecx
		assert(pp < pages + npages);
f01010c0:	a1 88 1e 29 f0       	mov    0xf0291e88,%eax
f01010c5:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01010c8:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f01010cb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01010ce:	89 4d d0             	mov    %ecx,-0x30(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f01010d1:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010d6:	e9 00 01 00 00       	jmp    f01011db <check_page_free_list+0x1c8>
		assert(pp >= pages);
f01010db:	68 37 79 10 f0       	push   $0xf0107937
f01010e0:	68 43 79 10 f0       	push   $0xf0107943
f01010e5:	68 b6 02 00 00       	push   $0x2b6
f01010ea:	68 1d 79 10 f0       	push   $0xf010791d
f01010ef:	e8 a0 ef ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f01010f4:	68 58 79 10 f0       	push   $0xf0107958
f01010f9:	68 43 79 10 f0       	push   $0xf0107943
f01010fe:	68 b7 02 00 00       	push   $0x2b7
f0101103:	68 1d 79 10 f0       	push   $0xf010791d
f0101108:	e8 87 ef ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010110d:	68 20 70 10 f0       	push   $0xf0107020
f0101112:	68 43 79 10 f0       	push   $0xf0107943
f0101117:	68 b8 02 00 00       	push   $0x2b8
f010111c:	68 1d 79 10 f0       	push   $0xf010791d
f0101121:	e8 6e ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != 0);
f0101126:	68 6c 79 10 f0       	push   $0xf010796c
f010112b:	68 43 79 10 f0       	push   $0xf0107943
f0101130:	68 bb 02 00 00       	push   $0x2bb
f0101135:	68 1d 79 10 f0       	push   $0xf010791d
f010113a:	e8 55 ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f010113f:	68 7d 79 10 f0       	push   $0xf010797d
f0101144:	68 43 79 10 f0       	push   $0xf0107943
f0101149:	68 bc 02 00 00       	push   $0x2bc
f010114e:	68 1d 79 10 f0       	push   $0xf010791d
f0101153:	e8 3c ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101158:	68 54 70 10 f0       	push   $0xf0107054
f010115d:	68 43 79 10 f0       	push   $0xf0107943
f0101162:	68 bd 02 00 00       	push   $0x2bd
f0101167:	68 1d 79 10 f0       	push   $0xf010791d
f010116c:	e8 23 ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101171:	68 96 79 10 f0       	push   $0xf0107996
f0101176:	68 43 79 10 f0       	push   $0xf0107943
f010117b:	68 be 02 00 00       	push   $0x2be
f0101180:	68 1d 79 10 f0       	push   $0xf010791d
f0101185:	e8 0a ef ff ff       	call   f0100094 <_panic>
	if (PGNUM(pa) >= npages)
f010118a:	89 c7                	mov    %eax,%edi
f010118c:	c1 ef 0c             	shr    $0xc,%edi
f010118f:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0101192:	76 19                	jbe    f01011ad <check_page_free_list+0x19a>
	return (void *)(pa + KERNBASE);
f0101194:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010119a:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f010119d:	77 20                	ja     f01011bf <check_page_free_list+0x1ac>
		assert(page2pa(pp) != MPENTRY_PADDR);
f010119f:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01011a4:	0f 84 92 00 00 00    	je     f010123c <check_page_free_list+0x229>
			++nfree_extmem;
f01011aa:	43                   	inc    %ebx
f01011ab:	eb 2c                	jmp    f01011d9 <check_page_free_list+0x1c6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011ad:	50                   	push   %eax
f01011ae:	68 48 68 10 f0       	push   $0xf0106848
f01011b3:	6a 58                	push   $0x58
f01011b5:	68 29 79 10 f0       	push   $0xf0107929
f01011ba:	e8 d5 ee ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01011bf:	68 78 70 10 f0       	push   $0xf0107078
f01011c4:	68 43 79 10 f0       	push   $0xf0107943
f01011c9:	68 bf 02 00 00       	push   $0x2bf
f01011ce:	68 1d 79 10 f0       	push   $0xf010791d
f01011d3:	e8 bc ee ff ff       	call   f0100094 <_panic>
			++nfree_basemem;
f01011d8:	46                   	inc    %esi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01011d9:	8b 12                	mov    (%edx),%edx
f01011db:	85 d2                	test   %edx,%edx
f01011dd:	74 76                	je     f0101255 <check_page_free_list+0x242>
		assert(pp >= pages);
f01011df:	39 d1                	cmp    %edx,%ecx
f01011e1:	0f 87 f4 fe ff ff    	ja     f01010db <check_page_free_list+0xc8>
		assert(pp < pages + npages);
f01011e7:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f01011ea:	0f 86 04 ff ff ff    	jbe    f01010f4 <check_page_free_list+0xe1>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01011f0:	89 d0                	mov    %edx,%eax
f01011f2:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01011f5:	a8 07                	test   $0x7,%al
f01011f7:	0f 85 10 ff ff ff    	jne    f010110d <check_page_free_list+0xfa>
	return (pp - pages) << PGSHIFT;
f01011fd:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0101200:	c1 e0 0c             	shl    $0xc,%eax
f0101203:	0f 84 1d ff ff ff    	je     f0101126 <check_page_free_list+0x113>
		assert(page2pa(pp) != IOPHYSMEM);
f0101209:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010120e:	0f 84 2b ff ff ff    	je     f010113f <check_page_free_list+0x12c>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101214:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101219:	0f 84 39 ff ff ff    	je     f0101158 <check_page_free_list+0x145>
		assert(page2pa(pp) != EXTPHYSMEM);
f010121f:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101224:	0f 84 47 ff ff ff    	je     f0101171 <check_page_free_list+0x15e>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010122a:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f010122f:	0f 87 55 ff ff ff    	ja     f010118a <check_page_free_list+0x177>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101235:	3d 00 70 00 00       	cmp    $0x7000,%eax
f010123a:	75 9c                	jne    f01011d8 <check_page_free_list+0x1c5>
f010123c:	68 b0 79 10 f0       	push   $0xf01079b0
f0101241:	68 43 79 10 f0       	push   $0xf0107943
f0101246:	68 c1 02 00 00       	push   $0x2c1
f010124b:	68 1d 79 10 f0       	push   $0xf010791d
f0101250:	e8 3f ee ff ff       	call   f0100094 <_panic>
	assert(nfree_basemem > 0);
f0101255:	85 f6                	test   %esi,%esi
f0101257:	7e 19                	jle    f0101272 <check_page_free_list+0x25f>
	assert(nfree_extmem > 0);
f0101259:	85 db                	test   %ebx,%ebx
f010125b:	7e 2e                	jle    f010128b <check_page_free_list+0x278>
	cprintf("check_page_free_list() succeeded!\n");
f010125d:	83 ec 0c             	sub    $0xc,%esp
f0101260:	68 c0 70 10 f0       	push   $0xf01070c0
f0101265:	e8 0b 2d 00 00       	call   f0103f75 <cprintf>
}
f010126a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010126d:	5b                   	pop    %ebx
f010126e:	5e                   	pop    %esi
f010126f:	5f                   	pop    %edi
f0101270:	5d                   	pop    %ebp
f0101271:	c3                   	ret    
	assert(nfree_basemem > 0);
f0101272:	68 cd 79 10 f0       	push   $0xf01079cd
f0101277:	68 43 79 10 f0       	push   $0xf0107943
f010127c:	68 c9 02 00 00       	push   $0x2c9
f0101281:	68 1d 79 10 f0       	push   $0xf010791d
f0101286:	e8 09 ee ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f010128b:	68 df 79 10 f0       	push   $0xf01079df
f0101290:	68 43 79 10 f0       	push   $0xf0107943
f0101295:	68 ca 02 00 00       	push   $0x2ca
f010129a:	68 1d 79 10 f0       	push   $0xf010791d
f010129f:	e8 f0 ed ff ff       	call   f0100094 <_panic>
	if (!page_free_list)
f01012a4:	a1 40 12 29 f0       	mov    0xf0291240,%eax
f01012a9:	85 c0                	test   %eax,%eax
f01012ab:	0f 84 86 fd ff ff    	je     f0101037 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01012b1:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01012b4:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01012b7:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01012ba:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01012bd:	89 c2                	mov    %eax,%edx
f01012bf:	2b 15 90 1e 29 f0    	sub    0xf0291e90,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit; 
f01012c5:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f01012cb:	0f 95 c2             	setne  %dl
f01012ce:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f01012d1:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f01012d5:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f01012d7:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f01012db:	8b 00                	mov    (%eax),%eax
f01012dd:	85 c0                	test   %eax,%eax
f01012df:	75 dc                	jne    f01012bd <check_page_free_list+0x2aa>
		*tp[1] = 0;
f01012e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01012e4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f01012ea:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01012ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01012f0:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f01012f2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01012f5:	a3 40 12 29 f0       	mov    %eax,0xf0291240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01012fa:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01012ff:	8b 1d 40 12 29 f0    	mov    0xf0291240,%ebx
f0101305:	e9 58 fd ff ff       	jmp    f0101062 <check_page_free_list+0x4f>

f010130a <page_init>:
{
f010130a:	55                   	push   %ebp
f010130b:	89 e5                	mov    %esp,%ebp
f010130d:	57                   	push   %edi
f010130e:	56                   	push   %esi
f010130f:	53                   	push   %ebx
f0101310:	83 ec 1c             	sub    $0x1c,%esp
	physaddr_t free = (physaddr_t) PADDR(boot_alloc(0));
f0101313:	b8 00 00 00 00       	mov    $0x0,%eax
f0101318:	e8 2a fc ff ff       	call   f0100f47 <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f010131d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101322:	76 32                	jbe    f0101356 <page_init+0x4c>
	return (physaddr_t)kva - KERNBASE;
f0101324:	05 00 00 00 10       	add    $0x10000000,%eax
f0101329:	89 45 e0             	mov    %eax,-0x20(%ebp)
	size_t core_code_end = MPENTRY_PADDR + mpentry_end - mpentry_start;
f010132c:	b8 16 cd 10 f0       	mov    $0xf010cd16,%eax
f0101331:	2d 9c 5c 10 f0       	sub    $0xf0105c9c,%eax
f0101336:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if (i >= npages_basemem && len < free)
f0101339:	8b 1d 44 12 29 f0    	mov    0xf0291244,%ebx
f010133f:	8b 0d 40 12 29 f0    	mov    0xf0291240,%ecx
	for (i = 1, len = PGSIZE; i < npages; i++, len += PGSIZE) {
f0101345:	bf 00 00 00 00       	mov    $0x0,%edi
f010134a:	b8 01 00 00 00       	mov    $0x1,%eax
		page_free_list = &pages[i];
f010134f:	be 01 00 00 00       	mov    $0x1,%esi
	for (i = 1, len = PGSIZE; i < npages; i++, len += PGSIZE) {
f0101354:	eb 37                	jmp    f010138d <page_init+0x83>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101356:	50                   	push   %eax
f0101357:	68 6c 68 10 f0       	push   $0xf010686c
f010135c:	68 3e 01 00 00       	push   $0x13e
f0101361:	68 1d 79 10 f0       	push   $0xf010791d
f0101366:	e8 29 ed ff ff       	call   f0100094 <_panic>
		pages[i].pp_ref = 0;
f010136b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0101372:	89 d7                	mov    %edx,%edi
f0101374:	03 3d 90 1e 29 f0    	add    0xf0291e90,%edi
f010137a:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
		pages[i].pp_link = page_free_list;
f0101380:	89 0f                	mov    %ecx,(%edi)
		page_free_list = &pages[i];
f0101382:	89 d1                	mov    %edx,%ecx
f0101384:	03 0d 90 1e 29 f0    	add    0xf0291e90,%ecx
f010138a:	89 f7                	mov    %esi,%edi
	for (i = 1, len = PGSIZE; i < npages; i++, len += PGSIZE) {
f010138c:	40                   	inc    %eax
f010138d:	39 05 88 1e 29 f0    	cmp    %eax,0xf0291e88
f0101393:	76 1d                	jbe    f01013b2 <page_init+0xa8>
f0101395:	89 c2                	mov    %eax,%edx
f0101397:	c1 e2 0c             	shl    $0xc,%edx
		if (len >= MPENTRY_PADDR && len < core_code_end) // We're in multicore code
f010139a:	81 fa ff 6f 00 00    	cmp    $0x6fff,%edx
f01013a0:	76 05                	jbe    f01013a7 <page_init+0x9d>
f01013a2:	39 55 e4             	cmp    %edx,-0x1c(%ebp)
f01013a5:	77 e5                	ja     f010138c <page_init+0x82>
		if (i >= npages_basemem && len < free)
f01013a7:	39 c3                	cmp    %eax,%ebx
f01013a9:	77 c0                	ja     f010136b <page_init+0x61>
f01013ab:	39 55 e0             	cmp    %edx,-0x20(%ebp)
f01013ae:	76 bb                	jbe    f010136b <page_init+0x61>
f01013b0:	eb da                	jmp    f010138c <page_init+0x82>
f01013b2:	89 f8                	mov    %edi,%eax
f01013b4:	84 c0                	test   %al,%al
f01013b6:	75 08                	jne    f01013c0 <page_init+0xb6>
}
f01013b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01013bb:	5b                   	pop    %ebx
f01013bc:	5e                   	pop    %esi
f01013bd:	5f                   	pop    %edi
f01013be:	5d                   	pop    %ebp
f01013bf:	c3                   	ret    
f01013c0:	89 0d 40 12 29 f0    	mov    %ecx,0xf0291240
f01013c6:	eb f0                	jmp    f01013b8 <page_init+0xae>

f01013c8 <page_alloc>:
{
f01013c8:	55                   	push   %ebp
f01013c9:	89 e5                	mov    %esp,%ebp
f01013cb:	53                   	push   %ebx
f01013cc:	83 ec 04             	sub    $0x4,%esp
	struct PageInfo* next = page_free_list;
f01013cf:	8b 1d 40 12 29 f0    	mov    0xf0291240,%ebx
	if (!next)
f01013d5:	85 db                	test   %ebx,%ebx
f01013d7:	74 13                	je     f01013ec <page_alloc+0x24>
	page_free_list = page_free_list->pp_link;
f01013d9:	8b 03                	mov    (%ebx),%eax
f01013db:	a3 40 12 29 f0       	mov    %eax,0xf0291240
	next->pp_link = NULL;
f01013e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f01013e6:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01013ea:	75 07                	jne    f01013f3 <page_alloc+0x2b>
}
f01013ec:	89 d8                	mov    %ebx,%eax
f01013ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01013f1:	c9                   	leave  
f01013f2:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f01013f3:	89 d8                	mov    %ebx,%eax
f01013f5:	2b 05 90 1e 29 f0    	sub    0xf0291e90,%eax
f01013fb:	c1 f8 03             	sar    $0x3,%eax
f01013fe:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101401:	89 c2                	mov    %eax,%edx
f0101403:	c1 ea 0c             	shr    $0xc,%edx
f0101406:	3b 15 88 1e 29 f0    	cmp    0xf0291e88,%edx
f010140c:	73 1a                	jae    f0101428 <page_alloc+0x60>
		memset(content, 0, PGSIZE);
f010140e:	83 ec 04             	sub    $0x4,%esp
f0101411:	68 00 10 00 00       	push   $0x1000
f0101416:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0101418:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010141d:	50                   	push   %eax
f010141e:	e8 cb 45 00 00       	call   f01059ee <memset>
f0101423:	83 c4 10             	add    $0x10,%esp
f0101426:	eb c4                	jmp    f01013ec <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101428:	50                   	push   %eax
f0101429:	68 48 68 10 f0       	push   $0xf0106848
f010142e:	6a 58                	push   $0x58
f0101430:	68 29 79 10 f0       	push   $0xf0107929
f0101435:	e8 5a ec ff ff       	call   f0100094 <_panic>

f010143a <page_free>:
{
f010143a:	55                   	push   %ebp
f010143b:	89 e5                	mov    %esp,%ebp
f010143d:	83 ec 08             	sub    $0x8,%esp
f0101440:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref)
f0101443:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101448:	75 14                	jne    f010145e <page_free+0x24>
	if (pp->pp_link)
f010144a:	83 38 00             	cmpl   $0x0,(%eax)
f010144d:	75 26                	jne    f0101475 <page_free+0x3b>
	pp->pp_link = page_free_list;
f010144f:	8b 15 40 12 29 f0    	mov    0xf0291240,%edx
f0101455:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101457:	a3 40 12 29 f0       	mov    %eax,0xf0291240
}
f010145c:	c9                   	leave  
f010145d:	c3                   	ret    
		panic("Ref count is non-zero");
f010145e:	83 ec 04             	sub    $0x4,%esp
f0101461:	68 f0 79 10 f0       	push   $0xf01079f0
f0101466:	68 70 01 00 00       	push   $0x170
f010146b:	68 1d 79 10 f0       	push   $0xf010791d
f0101470:	e8 1f ec ff ff       	call   f0100094 <_panic>
		panic("Page is double-freed");
f0101475:	83 ec 04             	sub    $0x4,%esp
f0101478:	68 06 7a 10 f0       	push   $0xf0107a06
f010147d:	68 72 01 00 00       	push   $0x172
f0101482:	68 1d 79 10 f0       	push   $0xf010791d
f0101487:	e8 08 ec ff ff       	call   f0100094 <_panic>

f010148c <page_decref>:
{
f010148c:	55                   	push   %ebp
f010148d:	89 e5                	mov    %esp,%ebp
f010148f:	83 ec 08             	sub    $0x8,%esp
f0101492:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101495:	8b 42 04             	mov    0x4(%edx),%eax
f0101498:	48                   	dec    %eax
f0101499:	66 89 42 04          	mov    %ax,0x4(%edx)
f010149d:	66 85 c0             	test   %ax,%ax
f01014a0:	74 02                	je     f01014a4 <page_decref+0x18>
}
f01014a2:	c9                   	leave  
f01014a3:	c3                   	ret    
		page_free(pp);
f01014a4:	83 ec 0c             	sub    $0xc,%esp
f01014a7:	52                   	push   %edx
f01014a8:	e8 8d ff ff ff       	call   f010143a <page_free>
f01014ad:	83 c4 10             	add    $0x10,%esp
}
f01014b0:	eb f0                	jmp    f01014a2 <page_decref+0x16>

f01014b2 <pgdir_walk>:
{
f01014b2:	55                   	push   %ebp
f01014b3:	89 e5                	mov    %esp,%ebp
f01014b5:	57                   	push   %edi
f01014b6:	56                   	push   %esi
f01014b7:	53                   	push   %ebx
f01014b8:	83 ec 1c             	sub    $0x1c,%esp
	pde_t pd_entry = (pde_t)pgdir[PDX(va)];
f01014bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01014be:	c1 eb 16             	shr    $0x16,%ebx
f01014c1:	c1 e3 02             	shl    $0x2,%ebx
f01014c4:	03 5d 08             	add    0x8(%ebp),%ebx
f01014c7:	8b 03                	mov    (%ebx),%eax
	if (pd_entry) {
f01014c9:	85 c0                	test   %eax,%eax
f01014cb:	74 42                	je     f010150f <pgdir_walk+0x5d>
		pte_t* pt_base = KADDR(PTE_ADDR(pd_entry));
f01014cd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01014d2:	89 c2                	mov    %eax,%edx
f01014d4:	c1 ea 0c             	shr    $0xc,%edx
f01014d7:	39 15 88 1e 29 f0    	cmp    %edx,0xf0291e88
f01014dd:	76 1b                	jbe    f01014fa <pgdir_walk+0x48>
		return pt_base + PTX(va);
f01014df:	8b 55 0c             	mov    0xc(%ebp),%edx
f01014e2:	c1 ea 0a             	shr    $0xa,%edx
f01014e5:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f01014eb:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
}
f01014f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014f5:	5b                   	pop    %ebx
f01014f6:	5e                   	pop    %esi
f01014f7:	5f                   	pop    %edi
f01014f8:	5d                   	pop    %ebp
f01014f9:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014fa:	50                   	push   %eax
f01014fb:	68 48 68 10 f0       	push   $0xf0106848
f0101500:	68 9d 01 00 00       	push   $0x19d
f0101505:	68 1d 79 10 f0       	push   $0xf010791d
f010150a:	e8 85 eb ff ff       	call   f0100094 <_panic>
	else if (create) {
f010150f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101513:	0f 84 9c 00 00 00    	je     f01015b5 <pgdir_walk+0x103>
		struct PageInfo *new_pt = page_alloc(0);
f0101519:	83 ec 0c             	sub    $0xc,%esp
f010151c:	6a 00                	push   $0x0
f010151e:	e8 a5 fe ff ff       	call   f01013c8 <page_alloc>
f0101523:	89 c7                	mov    %eax,%edi
		if (new_pt) {
f0101525:	83 c4 10             	add    $0x10,%esp
f0101528:	85 c0                	test   %eax,%eax
f010152a:	0f 84 8f 00 00 00    	je     f01015bf <pgdir_walk+0x10d>
	return (pp - pages) << PGSHIFT;
f0101530:	2b 05 90 1e 29 f0    	sub    0xf0291e90,%eax
f0101536:	c1 f8 03             	sar    $0x3,%eax
f0101539:	c1 e0 0c             	shl    $0xc,%eax
f010153c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (PGNUM(pa) >= npages)
f010153f:	c1 e8 0c             	shr    $0xc,%eax
f0101542:	3b 05 88 1e 29 f0    	cmp    0xf0291e88,%eax
f0101548:	73 42                	jae    f010158c <pgdir_walk+0xda>
	return (void *)(pa + KERNBASE);
f010154a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010154d:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
			memset(content, 0, PGSIZE);
f0101553:	83 ec 04             	sub    $0x4,%esp
f0101556:	68 00 10 00 00       	push   $0x1000
f010155b:	6a 00                	push   $0x0
f010155d:	56                   	push   %esi
f010155e:	e8 8b 44 00 00       	call   f01059ee <memset>
			new_pt->pp_ref++;
f0101563:	66 ff 47 04          	incw   0x4(%edi)
	if ((uint32_t)kva < KERNBASE)
f0101567:	83 c4 10             	add    $0x10,%esp
f010156a:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0101570:	76 2e                	jbe    f01015a0 <pgdir_walk+0xee>
			pgdir[PDX(va)] = PADDR(content) | 0xF; // Set all permissions.
f0101572:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101575:	83 c8 0f             	or     $0xf,%eax
f0101578:	89 03                	mov    %eax,(%ebx)
			return (pte_t*) content + PTX(va);
f010157a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010157d:	c1 e8 0a             	shr    $0xa,%eax
f0101580:	25 fc 0f 00 00       	and    $0xffc,%eax
f0101585:	01 f0                	add    %esi,%eax
f0101587:	e9 66 ff ff ff       	jmp    f01014f2 <pgdir_walk+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010158c:	ff 75 e4             	pushl  -0x1c(%ebp)
f010158f:	68 48 68 10 f0       	push   $0xf0106848
f0101594:	6a 58                	push   $0x58
f0101596:	68 29 79 10 f0       	push   $0xf0107929
f010159b:	e8 f4 ea ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01015a0:	56                   	push   %esi
f01015a1:	68 6c 68 10 f0       	push   $0xf010686c
f01015a6:	68 a6 01 00 00       	push   $0x1a6
f01015ab:	68 1d 79 10 f0       	push   $0xf010791d
f01015b0:	e8 df ea ff ff       	call   f0100094 <_panic>
	return NULL;
f01015b5:	b8 00 00 00 00       	mov    $0x0,%eax
f01015ba:	e9 33 ff ff ff       	jmp    f01014f2 <pgdir_walk+0x40>
f01015bf:	b8 00 00 00 00       	mov    $0x0,%eax
f01015c4:	e9 29 ff ff ff       	jmp    f01014f2 <pgdir_walk+0x40>

f01015c9 <boot_map_region>:
{
f01015c9:	55                   	push   %ebp
f01015ca:	89 e5                	mov    %esp,%ebp
f01015cc:	57                   	push   %edi
f01015cd:	56                   	push   %esi
f01015ce:	53                   	push   %ebx
f01015cf:	83 ec 1c             	sub    $0x1c,%esp
f01015d2:	89 c7                	mov    %eax,%edi
f01015d4:	89 d6                	mov    %edx,%esi
f01015d6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f01015d9:	bb 00 00 00 00       	mov    $0x0,%ebx
		*page_entry = (pa + size0) | perm | PTE_P;
f01015de:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015e1:	83 c8 01             	or     $0x1,%eax
f01015e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f01015e7:	eb 22                	jmp    f010160b <boot_map_region+0x42>
		pte_t *page_entry = pgdir_walk(pgdir, (void*) va + size0, 1);
f01015e9:	83 ec 04             	sub    $0x4,%esp
f01015ec:	6a 01                	push   $0x1
f01015ee:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f01015f1:	50                   	push   %eax
f01015f2:	57                   	push   %edi
f01015f3:	e8 ba fe ff ff       	call   f01014b2 <pgdir_walk>
		*page_entry = (pa + size0) | perm | PTE_P;
f01015f8:	89 da                	mov    %ebx,%edx
f01015fa:	03 55 08             	add    0x8(%ebp),%edx
f01015fd:	0b 55 e0             	or     -0x20(%ebp),%edx
f0101600:	89 10                	mov    %edx,(%eax)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f0101602:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101608:	83 c4 10             	add    $0x10,%esp
f010160b:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010160e:	72 d9                	jb     f01015e9 <boot_map_region+0x20>
}
f0101610:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101613:	5b                   	pop    %ebx
f0101614:	5e                   	pop    %esi
f0101615:	5f                   	pop    %edi
f0101616:	5d                   	pop    %ebp
f0101617:	c3                   	ret    

f0101618 <page_lookup>:
{
f0101618:	55                   	push   %ebp
f0101619:	89 e5                	mov    %esp,%ebp
f010161b:	53                   	push   %ebx
f010161c:	83 ec 08             	sub    $0x8,%esp
f010161f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *page_entry = pgdir_walk(pgdir, (void*) va, 0);
f0101622:	6a 00                	push   $0x0
f0101624:	ff 75 0c             	pushl  0xc(%ebp)
f0101627:	ff 75 08             	pushl  0x8(%ebp)
f010162a:	e8 83 fe ff ff       	call   f01014b2 <pgdir_walk>
	if (!page_entry || !*page_entry)
f010162f:	83 c4 10             	add    $0x10,%esp
f0101632:	85 c0                	test   %eax,%eax
f0101634:	74 3a                	je     f0101670 <page_lookup+0x58>
f0101636:	83 38 00             	cmpl   $0x0,(%eax)
f0101639:	74 3c                	je     f0101677 <page_lookup+0x5f>
	if (pte_store)
f010163b:	85 db                	test   %ebx,%ebx
f010163d:	74 02                	je     f0101641 <page_lookup+0x29>
		*pte_store = page_entry;
f010163f:	89 03                	mov    %eax,(%ebx)
f0101641:	8b 00                	mov    (%eax),%eax
f0101643:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101646:	39 05 88 1e 29 f0    	cmp    %eax,0xf0291e88
f010164c:	76 0e                	jbe    f010165c <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f010164e:	8b 15 90 1e 29 f0    	mov    0xf0291e90,%edx
f0101654:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0101657:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010165a:	c9                   	leave  
f010165b:	c3                   	ret    
		panic("pa2page called with invalid pa");
f010165c:	83 ec 04             	sub    $0x4,%esp
f010165f:	68 e4 70 10 f0       	push   $0xf01070e4
f0101664:	6a 51                	push   $0x51
f0101666:	68 29 79 10 f0       	push   $0xf0107929
f010166b:	e8 24 ea ff ff       	call   f0100094 <_panic>
		return NULL;
f0101670:	b8 00 00 00 00       	mov    $0x0,%eax
f0101675:	eb e0                	jmp    f0101657 <page_lookup+0x3f>
f0101677:	b8 00 00 00 00       	mov    $0x0,%eax
f010167c:	eb d9                	jmp    f0101657 <page_lookup+0x3f>

f010167e <tlb_invalidate>:
{
f010167e:	55                   	push   %ebp
f010167f:	89 e5                	mov    %esp,%ebp
f0101681:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f0101684:	e8 3d 4a 00 00       	call   f01060c6 <cpunum>
f0101689:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010168c:	01 c2                	add    %eax,%edx
f010168e:	01 d2                	add    %edx,%edx
f0101690:	01 c2                	add    %eax,%edx
f0101692:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0101695:	83 3c 85 28 20 29 f0 	cmpl   $0x0,-0xfd6dfd8(,%eax,4)
f010169c:	00 
f010169d:	74 20                	je     f01016bf <tlb_invalidate+0x41>
f010169f:	e8 22 4a 00 00       	call   f01060c6 <cpunum>
f01016a4:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01016a7:	01 c2                	add    %eax,%edx
f01016a9:	01 d2                	add    %edx,%edx
f01016ab:	01 c2                	add    %eax,%edx
f01016ad:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01016b0:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f01016b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01016ba:	39 48 60             	cmp    %ecx,0x60(%eax)
f01016bd:	75 06                	jne    f01016c5 <tlb_invalidate+0x47>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01016bf:	8b 45 0c             	mov    0xc(%ebp),%eax
f01016c2:	0f 01 38             	invlpg (%eax)
}
f01016c5:	c9                   	leave  
f01016c6:	c3                   	ret    

f01016c7 <page_remove>:
{
f01016c7:	55                   	push   %ebp
f01016c8:	89 e5                	mov    %esp,%ebp
f01016ca:	57                   	push   %edi
f01016cb:	56                   	push   %esi
f01016cc:	53                   	push   %ebx
f01016cd:	83 ec 20             	sub    $0x20,%esp
f01016d0:	8b 75 08             	mov    0x8(%ebp),%esi
f01016d3:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct PageInfo *pp = page_lookup(pgdir, va, &pte_store);
f01016d6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01016d9:	50                   	push   %eax
f01016da:	57                   	push   %edi
f01016db:	56                   	push   %esi
f01016dc:	e8 37 ff ff ff       	call   f0101618 <page_lookup>
	if (!pp)
f01016e1:	83 c4 10             	add    $0x10,%esp
f01016e4:	85 c0                	test   %eax,%eax
f01016e6:	74 23                	je     f010170b <page_remove+0x44>
f01016e8:	89 c3                	mov    %eax,%ebx
	pp->pp_ref--;
f01016ea:	66 ff 48 04          	decw   0x4(%eax)
	*pte_store = 0;
f01016ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01016f1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f01016f7:	83 ec 08             	sub    $0x8,%esp
f01016fa:	57                   	push   %edi
f01016fb:	56                   	push   %esi
f01016fc:	e8 7d ff ff ff       	call   f010167e <tlb_invalidate>
	if (!pp->pp_ref)
f0101701:	83 c4 10             	add    $0x10,%esp
f0101704:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101709:	74 08                	je     f0101713 <page_remove+0x4c>
}
f010170b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010170e:	5b                   	pop    %ebx
f010170f:	5e                   	pop    %esi
f0101710:	5f                   	pop    %edi
f0101711:	5d                   	pop    %ebp
f0101712:	c3                   	ret    
		page_free(pp);
f0101713:	83 ec 0c             	sub    $0xc,%esp
f0101716:	53                   	push   %ebx
f0101717:	e8 1e fd ff ff       	call   f010143a <page_free>
f010171c:	83 c4 10             	add    $0x10,%esp
f010171f:	eb ea                	jmp    f010170b <page_remove+0x44>

f0101721 <page_insert>:
{
f0101721:	55                   	push   %ebp
f0101722:	89 e5                	mov    %esp,%ebp
f0101724:	57                   	push   %edi
f0101725:	56                   	push   %esi
f0101726:	53                   	push   %ebx
f0101727:	83 ec 10             	sub    $0x10,%esp
f010172a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010172d:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *page_entry = pgdir_walk(pgdir, (void*) va, 1);
f0101730:	6a 01                	push   $0x1
f0101732:	57                   	push   %edi
f0101733:	ff 75 08             	pushl  0x8(%ebp)
f0101736:	e8 77 fd ff ff       	call   f01014b2 <pgdir_walk>
	if (!page_entry)
f010173b:	83 c4 10             	add    $0x10,%esp
f010173e:	85 c0                	test   %eax,%eax
f0101740:	74 3f                	je     f0101781 <page_insert+0x60>
f0101742:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f0101744:	66 ff 43 04          	incw   0x4(%ebx)
	if (*page_entry) 
f0101748:	83 38 00             	cmpl   $0x0,(%eax)
f010174b:	75 23                	jne    f0101770 <page_insert+0x4f>
	return (pp - pages) << PGSHIFT;
f010174d:	2b 1d 90 1e 29 f0    	sub    0xf0291e90,%ebx
f0101753:	c1 fb 03             	sar    $0x3,%ebx
f0101756:	c1 e3 0c             	shl    $0xc,%ebx
	*page_entry = page2pa(pp) | perm | PTE_P;
f0101759:	8b 45 14             	mov    0x14(%ebp),%eax
f010175c:	83 c8 01             	or     $0x1,%eax
f010175f:	09 c3                	or     %eax,%ebx
f0101761:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0101763:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101768:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010176b:	5b                   	pop    %ebx
f010176c:	5e                   	pop    %esi
f010176d:	5f                   	pop    %edi
f010176e:	5d                   	pop    %ebp
f010176f:	c3                   	ret    
		page_remove(pgdir, va);
f0101770:	83 ec 08             	sub    $0x8,%esp
f0101773:	57                   	push   %edi
f0101774:	ff 75 08             	pushl  0x8(%ebp)
f0101777:	e8 4b ff ff ff       	call   f01016c7 <page_remove>
f010177c:	83 c4 10             	add    $0x10,%esp
f010177f:	eb cc                	jmp    f010174d <page_insert+0x2c>
		return -E_NO_MEM;  // Has no page table AND cannot be allocated
f0101781:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101786:	eb e0                	jmp    f0101768 <page_insert+0x47>

f0101788 <mmio_map_region>:
{
f0101788:	55                   	push   %ebp
f0101789:	89 e5                	mov    %esp,%ebp
f010178b:	53                   	push   %ebx
f010178c:	83 ec 04             	sub    $0x4,%esp
	size_t size_up = ROUNDUP(size, PGSIZE);
f010178f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101792:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101798:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (base >= MMIOLIM)
f010179e:	8b 15 00 23 12 f0    	mov    0xf0122300,%edx
f01017a4:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01017aa:	77 26                	ja     f01017d2 <mmio_map_region+0x4a>
	boot_map_region(kern_pgdir, base, size_up, pa, PTE_PCD|PTE_PWT|PTE_W);
f01017ac:	83 ec 08             	sub    $0x8,%esp
f01017af:	6a 1a                	push   $0x1a
f01017b1:	ff 75 08             	pushl  0x8(%ebp)
f01017b4:	89 d9                	mov    %ebx,%ecx
f01017b6:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f01017bb:	e8 09 fe ff ff       	call   f01015c9 <boot_map_region>
	base += size_up;
f01017c0:	a1 00 23 12 f0       	mov    0xf0122300,%eax
f01017c5:	01 c3                	add    %eax,%ebx
f01017c7:	89 1d 00 23 12 f0    	mov    %ebx,0xf0122300
}
f01017cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01017d0:	c9                   	leave  
f01017d1:	c3                   	ret    
		panic("MMIO overflowed!");
f01017d2:	83 ec 04             	sub    $0x4,%esp
f01017d5:	68 1b 7a 10 f0       	push   $0xf0107a1b
f01017da:	68 48 02 00 00       	push   $0x248
f01017df:	68 1d 79 10 f0       	push   $0xf010791d
f01017e4:	e8 ab e8 ff ff       	call   f0100094 <_panic>

f01017e9 <mem_init>:
{
f01017e9:	55                   	push   %ebp
f01017ea:	89 e5                	mov    %esp,%ebp
f01017ec:	57                   	push   %edi
f01017ed:	56                   	push   %esi
f01017ee:	53                   	push   %ebx
f01017ef:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f01017f2:	b8 15 00 00 00       	mov    $0x15,%eax
f01017f7:	e8 91 f7 ff ff       	call   f0100f8d <nvram_read>
f01017fc:	89 c6                	mov    %eax,%esi
	extmem = nvram_read(NVRAM_EXTLO);
f01017fe:	b8 17 00 00 00       	mov    $0x17,%eax
f0101803:	e8 85 f7 ff ff       	call   f0100f8d <nvram_read>
f0101808:	89 c3                	mov    %eax,%ebx
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010180a:	b8 34 00 00 00       	mov    $0x34,%eax
f010180f:	e8 79 f7 ff ff       	call   f0100f8d <nvram_read>
	if (ext16mem)
f0101814:	c1 e0 06             	shl    $0x6,%eax
f0101817:	75 10                	jne    f0101829 <mem_init+0x40>
	else if (extmem)
f0101819:	85 db                	test   %ebx,%ebx
f010181b:	0f 84 e6 00 00 00    	je     f0101907 <mem_init+0x11e>
		totalmem = 1 * 1024 + extmem;
f0101821:	8d 83 00 04 00 00    	lea    0x400(%ebx),%eax
f0101827:	eb 05                	jmp    f010182e <mem_init+0x45>
		totalmem = 16 * 1024 + ext16mem;
f0101829:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f010182e:	89 c2                	mov    %eax,%edx
f0101830:	c1 ea 02             	shr    $0x2,%edx
f0101833:	89 15 88 1e 29 f0    	mov    %edx,0xf0291e88
	npages_basemem = basemem / (PGSIZE / 1024);
f0101839:	89 f2                	mov    %esi,%edx
f010183b:	c1 ea 02             	shr    $0x2,%edx
f010183e:	89 15 44 12 29 f0    	mov    %edx,0xf0291244
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101844:	89 c2                	mov    %eax,%edx
f0101846:	29 f2                	sub    %esi,%edx
f0101848:	52                   	push   %edx
f0101849:	56                   	push   %esi
f010184a:	50                   	push   %eax
f010184b:	68 04 71 10 f0       	push   $0xf0107104
f0101850:	e8 20 27 00 00       	call   f0103f75 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101855:	b8 00 10 00 00       	mov    $0x1000,%eax
f010185a:	e8 e8 f6 ff ff       	call   f0100f47 <boot_alloc>
f010185f:	a3 8c 1e 29 f0       	mov    %eax,0xf0291e8c
	memset(kern_pgdir, 0, PGSIZE);
f0101864:	83 c4 0c             	add    $0xc,%esp
f0101867:	68 00 10 00 00       	push   $0x1000
f010186c:	6a 00                	push   $0x0
f010186e:	50                   	push   %eax
f010186f:	e8 7a 41 00 00       	call   f01059ee <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101874:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0101879:	83 c4 10             	add    $0x10,%esp
f010187c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101881:	0f 86 87 00 00 00    	jbe    f010190e <mem_init+0x125>
	return (physaddr_t)kva - KERNBASE;
f0101887:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010188d:	83 ca 05             	or     $0x5,%edx
f0101890:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo)*npages);
f0101896:	a1 88 1e 29 f0       	mov    0xf0291e88,%eax
f010189b:	c1 e0 03             	shl    $0x3,%eax
f010189e:	e8 a4 f6 ff ff       	call   f0100f47 <boot_alloc>
f01018a3:	a3 90 1e 29 f0       	mov    %eax,0xf0291e90
	memset(pages, 0, sizeof(struct PageInfo)*npages);
f01018a8:	83 ec 04             	sub    $0x4,%esp
f01018ab:	8b 0d 88 1e 29 f0    	mov    0xf0291e88,%ecx
f01018b1:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01018b8:	52                   	push   %edx
f01018b9:	6a 00                	push   $0x0
f01018bb:	50                   	push   %eax
f01018bc:	e8 2d 41 00 00       	call   f01059ee <memset>
	envs = (struct Env *) boot_alloc(sizeof(struct Env)*NENV);
f01018c1:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01018c6:	e8 7c f6 ff ff       	call   f0100f47 <boot_alloc>
f01018cb:	a3 48 12 29 f0       	mov    %eax,0xf0291248
	memset(envs, 0, sizeof(struct Env)*NENV);
f01018d0:	83 c4 0c             	add    $0xc,%esp
f01018d3:	68 00 f0 01 00       	push   $0x1f000
f01018d8:	6a 00                	push   $0x0
f01018da:	50                   	push   %eax
f01018db:	e8 0e 41 00 00       	call   f01059ee <memset>
	page_init();
f01018e0:	e8 25 fa ff ff       	call   f010130a <page_init>
	check_page_free_list(1);
f01018e5:	b8 01 00 00 00       	mov    $0x1,%eax
f01018ea:	e8 24 f7 ff ff       	call   f0101013 <check_page_free_list>
	if (!pages)
f01018ef:	83 c4 10             	add    $0x10,%esp
f01018f2:	83 3d 90 1e 29 f0 00 	cmpl   $0x0,0xf0291e90
f01018f9:	74 28                	je     f0101923 <mem_init+0x13a>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01018fb:	a1 40 12 29 f0       	mov    0xf0291240,%eax
f0101900:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101905:	eb 36                	jmp    f010193d <mem_init+0x154>
		totalmem = basemem;
f0101907:	89 f0                	mov    %esi,%eax
f0101909:	e9 20 ff ff ff       	jmp    f010182e <mem_init+0x45>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010190e:	50                   	push   %eax
f010190f:	68 6c 68 10 f0       	push   $0xf010686c
f0101914:	68 94 00 00 00       	push   $0x94
f0101919:	68 1d 79 10 f0       	push   $0xf010791d
f010191e:	e8 71 e7 ff ff       	call   f0100094 <_panic>
		panic("'pages' is a null pointer!");
f0101923:	83 ec 04             	sub    $0x4,%esp
f0101926:	68 2c 7a 10 f0       	push   $0xf0107a2c
f010192b:	68 dd 02 00 00       	push   $0x2dd
f0101930:	68 1d 79 10 f0       	push   $0xf010791d
f0101935:	e8 5a e7 ff ff       	call   f0100094 <_panic>
		++nfree;
f010193a:	43                   	inc    %ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010193b:	8b 00                	mov    (%eax),%eax
f010193d:	85 c0                	test   %eax,%eax
f010193f:	75 f9                	jne    f010193a <mem_init+0x151>
	assert((pp0 = page_alloc(0)));
f0101941:	83 ec 0c             	sub    $0xc,%esp
f0101944:	6a 00                	push   $0x0
f0101946:	e8 7d fa ff ff       	call   f01013c8 <page_alloc>
f010194b:	89 c7                	mov    %eax,%edi
f010194d:	83 c4 10             	add    $0x10,%esp
f0101950:	85 c0                	test   %eax,%eax
f0101952:	0f 84 10 02 00 00    	je     f0101b68 <mem_init+0x37f>
	assert((pp1 = page_alloc(0)));
f0101958:	83 ec 0c             	sub    $0xc,%esp
f010195b:	6a 00                	push   $0x0
f010195d:	e8 66 fa ff ff       	call   f01013c8 <page_alloc>
f0101962:	89 c6                	mov    %eax,%esi
f0101964:	83 c4 10             	add    $0x10,%esp
f0101967:	85 c0                	test   %eax,%eax
f0101969:	0f 84 12 02 00 00    	je     f0101b81 <mem_init+0x398>
	assert((pp2 = page_alloc(0)));
f010196f:	83 ec 0c             	sub    $0xc,%esp
f0101972:	6a 00                	push   $0x0
f0101974:	e8 4f fa ff ff       	call   f01013c8 <page_alloc>
f0101979:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010197c:	83 c4 10             	add    $0x10,%esp
f010197f:	85 c0                	test   %eax,%eax
f0101981:	0f 84 13 02 00 00    	je     f0101b9a <mem_init+0x3b1>
	assert(pp1 && pp1 != pp0);
f0101987:	39 f7                	cmp    %esi,%edi
f0101989:	0f 84 24 02 00 00    	je     f0101bb3 <mem_init+0x3ca>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010198f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101992:	39 c6                	cmp    %eax,%esi
f0101994:	0f 84 32 02 00 00    	je     f0101bcc <mem_init+0x3e3>
f010199a:	39 c7                	cmp    %eax,%edi
f010199c:	0f 84 2a 02 00 00    	je     f0101bcc <mem_init+0x3e3>
	return (pp - pages) << PGSHIFT;
f01019a2:	8b 0d 90 1e 29 f0    	mov    0xf0291e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01019a8:	8b 15 88 1e 29 f0    	mov    0xf0291e88,%edx
f01019ae:	c1 e2 0c             	shl    $0xc,%edx
f01019b1:	89 f8                	mov    %edi,%eax
f01019b3:	29 c8                	sub    %ecx,%eax
f01019b5:	c1 f8 03             	sar    $0x3,%eax
f01019b8:	c1 e0 0c             	shl    $0xc,%eax
f01019bb:	39 d0                	cmp    %edx,%eax
f01019bd:	0f 83 22 02 00 00    	jae    f0101be5 <mem_init+0x3fc>
f01019c3:	89 f0                	mov    %esi,%eax
f01019c5:	29 c8                	sub    %ecx,%eax
f01019c7:	c1 f8 03             	sar    $0x3,%eax
f01019ca:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01019cd:	39 c2                	cmp    %eax,%edx
f01019cf:	0f 86 29 02 00 00    	jbe    f0101bfe <mem_init+0x415>
f01019d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019d8:	29 c8                	sub    %ecx,%eax
f01019da:	c1 f8 03             	sar    $0x3,%eax
f01019dd:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01019e0:	39 c2                	cmp    %eax,%edx
f01019e2:	0f 86 2f 02 00 00    	jbe    f0101c17 <mem_init+0x42e>
	fl = page_free_list;
f01019e8:	a1 40 12 29 f0       	mov    0xf0291240,%eax
f01019ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01019f0:	c7 05 40 12 29 f0 00 	movl   $0x0,0xf0291240
f01019f7:	00 00 00 
	assert(!page_alloc(0));
f01019fa:	83 ec 0c             	sub    $0xc,%esp
f01019fd:	6a 00                	push   $0x0
f01019ff:	e8 c4 f9 ff ff       	call   f01013c8 <page_alloc>
f0101a04:	83 c4 10             	add    $0x10,%esp
f0101a07:	85 c0                	test   %eax,%eax
f0101a09:	0f 85 21 02 00 00    	jne    f0101c30 <mem_init+0x447>
	page_free(pp0);
f0101a0f:	83 ec 0c             	sub    $0xc,%esp
f0101a12:	57                   	push   %edi
f0101a13:	e8 22 fa ff ff       	call   f010143a <page_free>
	page_free(pp1);
f0101a18:	89 34 24             	mov    %esi,(%esp)
f0101a1b:	e8 1a fa ff ff       	call   f010143a <page_free>
	page_free(pp2);
f0101a20:	83 c4 04             	add    $0x4,%esp
f0101a23:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a26:	e8 0f fa ff ff       	call   f010143a <page_free>
	assert((pp0 = page_alloc(0)));
f0101a2b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a32:	e8 91 f9 ff ff       	call   f01013c8 <page_alloc>
f0101a37:	89 c6                	mov    %eax,%esi
f0101a39:	83 c4 10             	add    $0x10,%esp
f0101a3c:	85 c0                	test   %eax,%eax
f0101a3e:	0f 84 05 02 00 00    	je     f0101c49 <mem_init+0x460>
	assert((pp1 = page_alloc(0)));
f0101a44:	83 ec 0c             	sub    $0xc,%esp
f0101a47:	6a 00                	push   $0x0
f0101a49:	e8 7a f9 ff ff       	call   f01013c8 <page_alloc>
f0101a4e:	89 c7                	mov    %eax,%edi
f0101a50:	83 c4 10             	add    $0x10,%esp
f0101a53:	85 c0                	test   %eax,%eax
f0101a55:	0f 84 07 02 00 00    	je     f0101c62 <mem_init+0x479>
	assert((pp2 = page_alloc(0)));
f0101a5b:	83 ec 0c             	sub    $0xc,%esp
f0101a5e:	6a 00                	push   $0x0
f0101a60:	e8 63 f9 ff ff       	call   f01013c8 <page_alloc>
f0101a65:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a68:	83 c4 10             	add    $0x10,%esp
f0101a6b:	85 c0                	test   %eax,%eax
f0101a6d:	0f 84 08 02 00 00    	je     f0101c7b <mem_init+0x492>
	assert(pp1 && pp1 != pp0);
f0101a73:	39 fe                	cmp    %edi,%esi
f0101a75:	0f 84 19 02 00 00    	je     f0101c94 <mem_init+0x4ab>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a7b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a7e:	39 c7                	cmp    %eax,%edi
f0101a80:	0f 84 27 02 00 00    	je     f0101cad <mem_init+0x4c4>
f0101a86:	39 c6                	cmp    %eax,%esi
f0101a88:	0f 84 1f 02 00 00    	je     f0101cad <mem_init+0x4c4>
	assert(!page_alloc(0));
f0101a8e:	83 ec 0c             	sub    $0xc,%esp
f0101a91:	6a 00                	push   $0x0
f0101a93:	e8 30 f9 ff ff       	call   f01013c8 <page_alloc>
f0101a98:	83 c4 10             	add    $0x10,%esp
f0101a9b:	85 c0                	test   %eax,%eax
f0101a9d:	0f 85 23 02 00 00    	jne    f0101cc6 <mem_init+0x4dd>
f0101aa3:	89 f0                	mov    %esi,%eax
f0101aa5:	2b 05 90 1e 29 f0    	sub    0xf0291e90,%eax
f0101aab:	c1 f8 03             	sar    $0x3,%eax
f0101aae:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101ab1:	89 c2                	mov    %eax,%edx
f0101ab3:	c1 ea 0c             	shr    $0xc,%edx
f0101ab6:	3b 15 88 1e 29 f0    	cmp    0xf0291e88,%edx
f0101abc:	0f 83 1d 02 00 00    	jae    f0101cdf <mem_init+0x4f6>
	memset(page2kva(pp0), 1, PGSIZE);
f0101ac2:	83 ec 04             	sub    $0x4,%esp
f0101ac5:	68 00 10 00 00       	push   $0x1000
f0101aca:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101acc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ad1:	50                   	push   %eax
f0101ad2:	e8 17 3f 00 00       	call   f01059ee <memset>
	page_free(pp0);
f0101ad7:	89 34 24             	mov    %esi,(%esp)
f0101ada:	e8 5b f9 ff ff       	call   f010143a <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101adf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101ae6:	e8 dd f8 ff ff       	call   f01013c8 <page_alloc>
f0101aeb:	83 c4 10             	add    $0x10,%esp
f0101aee:	85 c0                	test   %eax,%eax
f0101af0:	0f 84 fb 01 00 00    	je     f0101cf1 <mem_init+0x508>
	assert(pp && pp0 == pp);
f0101af6:	39 c6                	cmp    %eax,%esi
f0101af8:	0f 85 0c 02 00 00    	jne    f0101d0a <mem_init+0x521>
	return (pp - pages) << PGSHIFT;
f0101afe:	89 f2                	mov    %esi,%edx
f0101b00:	2b 15 90 1e 29 f0    	sub    0xf0291e90,%edx
f0101b06:	c1 fa 03             	sar    $0x3,%edx
f0101b09:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101b0c:	89 d0                	mov    %edx,%eax
f0101b0e:	c1 e8 0c             	shr    $0xc,%eax
f0101b11:	3b 05 88 1e 29 f0    	cmp    0xf0291e88,%eax
f0101b17:	0f 83 06 02 00 00    	jae    f0101d23 <mem_init+0x53a>
	return (void *)(pa + KERNBASE);
f0101b1d:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101b23:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101b29:	80 38 00             	cmpb   $0x0,(%eax)
f0101b2c:	0f 85 03 02 00 00    	jne    f0101d35 <mem_init+0x54c>
f0101b32:	40                   	inc    %eax
	for (i = 0; i < PGSIZE; i++)
f0101b33:	39 d0                	cmp    %edx,%eax
f0101b35:	75 f2                	jne    f0101b29 <mem_init+0x340>
	page_free_list = fl;
f0101b37:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b3a:	a3 40 12 29 f0       	mov    %eax,0xf0291240
	page_free(pp0);
f0101b3f:	83 ec 0c             	sub    $0xc,%esp
f0101b42:	56                   	push   %esi
f0101b43:	e8 f2 f8 ff ff       	call   f010143a <page_free>
	page_free(pp1);
f0101b48:	89 3c 24             	mov    %edi,(%esp)
f0101b4b:	e8 ea f8 ff ff       	call   f010143a <page_free>
	page_free(pp2);
f0101b50:	83 c4 04             	add    $0x4,%esp
f0101b53:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b56:	e8 df f8 ff ff       	call   f010143a <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b5b:	a1 40 12 29 f0       	mov    0xf0291240,%eax
f0101b60:	83 c4 10             	add    $0x10,%esp
f0101b63:	e9 e9 01 00 00       	jmp    f0101d51 <mem_init+0x568>
	assert((pp0 = page_alloc(0)));
f0101b68:	68 47 7a 10 f0       	push   $0xf0107a47
f0101b6d:	68 43 79 10 f0       	push   $0xf0107943
f0101b72:	68 e5 02 00 00       	push   $0x2e5
f0101b77:	68 1d 79 10 f0       	push   $0xf010791d
f0101b7c:	e8 13 e5 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101b81:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101b86:	68 43 79 10 f0       	push   $0xf0107943
f0101b8b:	68 e6 02 00 00       	push   $0x2e6
f0101b90:	68 1d 79 10 f0       	push   $0xf010791d
f0101b95:	e8 fa e4 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101b9a:	68 73 7a 10 f0       	push   $0xf0107a73
f0101b9f:	68 43 79 10 f0       	push   $0xf0107943
f0101ba4:	68 e7 02 00 00       	push   $0x2e7
f0101ba9:	68 1d 79 10 f0       	push   $0xf010791d
f0101bae:	e8 e1 e4 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f0101bb3:	68 89 7a 10 f0       	push   $0xf0107a89
f0101bb8:	68 43 79 10 f0       	push   $0xf0107943
f0101bbd:	68 ea 02 00 00       	push   $0x2ea
f0101bc2:	68 1d 79 10 f0       	push   $0xf010791d
f0101bc7:	e8 c8 e4 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101bcc:	68 40 71 10 f0       	push   $0xf0107140
f0101bd1:	68 43 79 10 f0       	push   $0xf0107943
f0101bd6:	68 eb 02 00 00       	push   $0x2eb
f0101bdb:	68 1d 79 10 f0       	push   $0xf010791d
f0101be0:	e8 af e4 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101be5:	68 9b 7a 10 f0       	push   $0xf0107a9b
f0101bea:	68 43 79 10 f0       	push   $0xf0107943
f0101bef:	68 ec 02 00 00       	push   $0x2ec
f0101bf4:	68 1d 79 10 f0       	push   $0xf010791d
f0101bf9:	e8 96 e4 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101bfe:	68 b8 7a 10 f0       	push   $0xf0107ab8
f0101c03:	68 43 79 10 f0       	push   $0xf0107943
f0101c08:	68 ed 02 00 00       	push   $0x2ed
f0101c0d:	68 1d 79 10 f0       	push   $0xf010791d
f0101c12:	e8 7d e4 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101c17:	68 d5 7a 10 f0       	push   $0xf0107ad5
f0101c1c:	68 43 79 10 f0       	push   $0xf0107943
f0101c21:	68 ee 02 00 00       	push   $0x2ee
f0101c26:	68 1d 79 10 f0       	push   $0xf010791d
f0101c2b:	e8 64 e4 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101c30:	68 f2 7a 10 f0       	push   $0xf0107af2
f0101c35:	68 43 79 10 f0       	push   $0xf0107943
f0101c3a:	68 f5 02 00 00       	push   $0x2f5
f0101c3f:	68 1d 79 10 f0       	push   $0xf010791d
f0101c44:	e8 4b e4 ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0101c49:	68 47 7a 10 f0       	push   $0xf0107a47
f0101c4e:	68 43 79 10 f0       	push   $0xf0107943
f0101c53:	68 fc 02 00 00       	push   $0x2fc
f0101c58:	68 1d 79 10 f0       	push   $0xf010791d
f0101c5d:	e8 32 e4 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c62:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101c67:	68 43 79 10 f0       	push   $0xf0107943
f0101c6c:	68 fd 02 00 00       	push   $0x2fd
f0101c71:	68 1d 79 10 f0       	push   $0xf010791d
f0101c76:	e8 19 e4 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c7b:	68 73 7a 10 f0       	push   $0xf0107a73
f0101c80:	68 43 79 10 f0       	push   $0xf0107943
f0101c85:	68 fe 02 00 00       	push   $0x2fe
f0101c8a:	68 1d 79 10 f0       	push   $0xf010791d
f0101c8f:	e8 00 e4 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f0101c94:	68 89 7a 10 f0       	push   $0xf0107a89
f0101c99:	68 43 79 10 f0       	push   $0xf0107943
f0101c9e:	68 00 03 00 00       	push   $0x300
f0101ca3:	68 1d 79 10 f0       	push   $0xf010791d
f0101ca8:	e8 e7 e3 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101cad:	68 40 71 10 f0       	push   $0xf0107140
f0101cb2:	68 43 79 10 f0       	push   $0xf0107943
f0101cb7:	68 01 03 00 00       	push   $0x301
f0101cbc:	68 1d 79 10 f0       	push   $0xf010791d
f0101cc1:	e8 ce e3 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101cc6:	68 f2 7a 10 f0       	push   $0xf0107af2
f0101ccb:	68 43 79 10 f0       	push   $0xf0107943
f0101cd0:	68 02 03 00 00       	push   $0x302
f0101cd5:	68 1d 79 10 f0       	push   $0xf010791d
f0101cda:	e8 b5 e3 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101cdf:	50                   	push   %eax
f0101ce0:	68 48 68 10 f0       	push   $0xf0106848
f0101ce5:	6a 58                	push   $0x58
f0101ce7:	68 29 79 10 f0       	push   $0xf0107929
f0101cec:	e8 a3 e3 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101cf1:	68 01 7b 10 f0       	push   $0xf0107b01
f0101cf6:	68 43 79 10 f0       	push   $0xf0107943
f0101cfb:	68 07 03 00 00       	push   $0x307
f0101d00:	68 1d 79 10 f0       	push   $0xf010791d
f0101d05:	e8 8a e3 ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f0101d0a:	68 1f 7b 10 f0       	push   $0xf0107b1f
f0101d0f:	68 43 79 10 f0       	push   $0xf0107943
f0101d14:	68 08 03 00 00       	push   $0x308
f0101d19:	68 1d 79 10 f0       	push   $0xf010791d
f0101d1e:	e8 71 e3 ff ff       	call   f0100094 <_panic>
f0101d23:	52                   	push   %edx
f0101d24:	68 48 68 10 f0       	push   $0xf0106848
f0101d29:	6a 58                	push   $0x58
f0101d2b:	68 29 79 10 f0       	push   $0xf0107929
f0101d30:	e8 5f e3 ff ff       	call   f0100094 <_panic>
		assert(c[i] == 0);
f0101d35:	68 2f 7b 10 f0       	push   $0xf0107b2f
f0101d3a:	68 43 79 10 f0       	push   $0xf0107943
f0101d3f:	68 0b 03 00 00       	push   $0x30b
f0101d44:	68 1d 79 10 f0       	push   $0xf010791d
f0101d49:	e8 46 e3 ff ff       	call   f0100094 <_panic>
		--nfree;
f0101d4e:	4b                   	dec    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101d4f:	8b 00                	mov    (%eax),%eax
f0101d51:	85 c0                	test   %eax,%eax
f0101d53:	75 f9                	jne    f0101d4e <mem_init+0x565>
	assert(nfree == 0);
f0101d55:	85 db                	test   %ebx,%ebx
f0101d57:	0f 85 87 09 00 00    	jne    f01026e4 <mem_init+0xefb>
	cprintf("check_page_alloc() succeeded!\n");
f0101d5d:	83 ec 0c             	sub    $0xc,%esp
f0101d60:	68 60 71 10 f0       	push   $0xf0107160
f0101d65:	e8 0b 22 00 00       	call   f0103f75 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101d6a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d71:	e8 52 f6 ff ff       	call   f01013c8 <page_alloc>
f0101d76:	89 c7                	mov    %eax,%edi
f0101d78:	83 c4 10             	add    $0x10,%esp
f0101d7b:	85 c0                	test   %eax,%eax
f0101d7d:	0f 84 7a 09 00 00    	je     f01026fd <mem_init+0xf14>
	assert((pp1 = page_alloc(0)));
f0101d83:	83 ec 0c             	sub    $0xc,%esp
f0101d86:	6a 00                	push   $0x0
f0101d88:	e8 3b f6 ff ff       	call   f01013c8 <page_alloc>
f0101d8d:	89 c3                	mov    %eax,%ebx
f0101d8f:	83 c4 10             	add    $0x10,%esp
f0101d92:	85 c0                	test   %eax,%eax
f0101d94:	0f 84 7c 09 00 00    	je     f0102716 <mem_init+0xf2d>
	assert((pp2 = page_alloc(0)));
f0101d9a:	83 ec 0c             	sub    $0xc,%esp
f0101d9d:	6a 00                	push   $0x0
f0101d9f:	e8 24 f6 ff ff       	call   f01013c8 <page_alloc>
f0101da4:	89 c6                	mov    %eax,%esi
f0101da6:	83 c4 10             	add    $0x10,%esp
f0101da9:	85 c0                	test   %eax,%eax
f0101dab:	0f 84 7e 09 00 00    	je     f010272f <mem_init+0xf46>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101db1:	39 df                	cmp    %ebx,%edi
f0101db3:	0f 84 8f 09 00 00    	je     f0102748 <mem_init+0xf5f>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101db9:	39 c3                	cmp    %eax,%ebx
f0101dbb:	0f 84 a0 09 00 00    	je     f0102761 <mem_init+0xf78>
f0101dc1:	39 c7                	cmp    %eax,%edi
f0101dc3:	0f 84 98 09 00 00    	je     f0102761 <mem_init+0xf78>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101dc9:	a1 40 12 29 f0       	mov    0xf0291240,%eax
f0101dce:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f0101dd1:	c7 05 40 12 29 f0 00 	movl   $0x0,0xf0291240
f0101dd8:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101ddb:	83 ec 0c             	sub    $0xc,%esp
f0101dde:	6a 00                	push   $0x0
f0101de0:	e8 e3 f5 ff ff       	call   f01013c8 <page_alloc>
f0101de5:	83 c4 10             	add    $0x10,%esp
f0101de8:	85 c0                	test   %eax,%eax
f0101dea:	0f 85 8a 09 00 00    	jne    f010277a <mem_init+0xf91>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101df0:	83 ec 04             	sub    $0x4,%esp
f0101df3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101df6:	50                   	push   %eax
f0101df7:	6a 00                	push   $0x0
f0101df9:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f0101dff:	e8 14 f8 ff ff       	call   f0101618 <page_lookup>
f0101e04:	83 c4 10             	add    $0x10,%esp
f0101e07:	85 c0                	test   %eax,%eax
f0101e09:	0f 85 84 09 00 00    	jne    f0102793 <mem_init+0xfaa>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101e0f:	6a 02                	push   $0x2
f0101e11:	6a 00                	push   $0x0
f0101e13:	53                   	push   %ebx
f0101e14:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f0101e1a:	e8 02 f9 ff ff       	call   f0101721 <page_insert>
f0101e1f:	83 c4 10             	add    $0x10,%esp
f0101e22:	85 c0                	test   %eax,%eax
f0101e24:	0f 89 82 09 00 00    	jns    f01027ac <mem_init+0xfc3>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101e2a:	83 ec 0c             	sub    $0xc,%esp
f0101e2d:	57                   	push   %edi
f0101e2e:	e8 07 f6 ff ff       	call   f010143a <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101e33:	6a 02                	push   $0x2
f0101e35:	6a 00                	push   $0x0
f0101e37:	53                   	push   %ebx
f0101e38:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f0101e3e:	e8 de f8 ff ff       	call   f0101721 <page_insert>
f0101e43:	83 c4 20             	add    $0x20,%esp
f0101e46:	85 c0                	test   %eax,%eax
f0101e48:	0f 85 77 09 00 00    	jne    f01027c5 <mem_init+0xfdc>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e4e:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f0101e53:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	return (pp - pages) << PGSHIFT;
f0101e56:	8b 0d 90 1e 29 f0    	mov    0xf0291e90,%ecx
f0101e5c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101e5f:	8b 00                	mov    (%eax),%eax
f0101e61:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101e64:	89 c2                	mov    %eax,%edx
f0101e66:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101e6c:	89 f8                	mov    %edi,%eax
f0101e6e:	29 c8                	sub    %ecx,%eax
f0101e70:	c1 f8 03             	sar    $0x3,%eax
f0101e73:	c1 e0 0c             	shl    $0xc,%eax
f0101e76:	39 c2                	cmp    %eax,%edx
f0101e78:	0f 85 60 09 00 00    	jne    f01027de <mem_init+0xff5>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101e7e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e83:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e86:	e8 29 f1 ff ff       	call   f0100fb4 <check_va2pa>
f0101e8b:	89 da                	mov    %ebx,%edx
f0101e8d:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101e90:	c1 fa 03             	sar    $0x3,%edx
f0101e93:	c1 e2 0c             	shl    $0xc,%edx
f0101e96:	39 d0                	cmp    %edx,%eax
f0101e98:	0f 85 59 09 00 00    	jne    f01027f7 <mem_init+0x100e>
	assert(pp1->pp_ref == 1);
f0101e9e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ea3:	0f 85 67 09 00 00    	jne    f0102810 <mem_init+0x1027>
	assert(pp0->pp_ref == 1);
f0101ea9:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101eae:	0f 85 75 09 00 00    	jne    f0102829 <mem_init+0x1040>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101eb4:	6a 02                	push   $0x2
f0101eb6:	68 00 10 00 00       	push   $0x1000
f0101ebb:	56                   	push   %esi
f0101ebc:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101ebf:	e8 5d f8 ff ff       	call   f0101721 <page_insert>
f0101ec4:	83 c4 10             	add    $0x10,%esp
f0101ec7:	85 c0                	test   %eax,%eax
f0101ec9:	0f 85 73 09 00 00    	jne    f0102842 <mem_init+0x1059>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ecf:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ed4:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f0101ed9:	e8 d6 f0 ff ff       	call   f0100fb4 <check_va2pa>
f0101ede:	89 f2                	mov    %esi,%edx
f0101ee0:	2b 15 90 1e 29 f0    	sub    0xf0291e90,%edx
f0101ee6:	c1 fa 03             	sar    $0x3,%edx
f0101ee9:	c1 e2 0c             	shl    $0xc,%edx
f0101eec:	39 d0                	cmp    %edx,%eax
f0101eee:	0f 85 67 09 00 00    	jne    f010285b <mem_init+0x1072>
	assert(pp2->pp_ref == 1);
f0101ef4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ef9:	0f 85 75 09 00 00    	jne    f0102874 <mem_init+0x108b>

	// should be no free memory
	assert(!page_alloc(0));
f0101eff:	83 ec 0c             	sub    $0xc,%esp
f0101f02:	6a 00                	push   $0x0
f0101f04:	e8 bf f4 ff ff       	call   f01013c8 <page_alloc>
f0101f09:	83 c4 10             	add    $0x10,%esp
f0101f0c:	85 c0                	test   %eax,%eax
f0101f0e:	0f 85 79 09 00 00    	jne    f010288d <mem_init+0x10a4>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f14:	6a 02                	push   $0x2
f0101f16:	68 00 10 00 00       	push   $0x1000
f0101f1b:	56                   	push   %esi
f0101f1c:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f0101f22:	e8 fa f7 ff ff       	call   f0101721 <page_insert>
f0101f27:	83 c4 10             	add    $0x10,%esp
f0101f2a:	85 c0                	test   %eax,%eax
f0101f2c:	0f 85 74 09 00 00    	jne    f01028a6 <mem_init+0x10bd>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f32:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f37:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f0101f3c:	e8 73 f0 ff ff       	call   f0100fb4 <check_va2pa>
f0101f41:	89 f2                	mov    %esi,%edx
f0101f43:	2b 15 90 1e 29 f0    	sub    0xf0291e90,%edx
f0101f49:	c1 fa 03             	sar    $0x3,%edx
f0101f4c:	c1 e2 0c             	shl    $0xc,%edx
f0101f4f:	39 d0                	cmp    %edx,%eax
f0101f51:	0f 85 68 09 00 00    	jne    f01028bf <mem_init+0x10d6>
	assert(pp2->pp_ref == 1);
f0101f57:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f5c:	0f 85 76 09 00 00    	jne    f01028d8 <mem_init+0x10ef>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101f62:	83 ec 0c             	sub    $0xc,%esp
f0101f65:	6a 00                	push   $0x0
f0101f67:	e8 5c f4 ff ff       	call   f01013c8 <page_alloc>
f0101f6c:	83 c4 10             	add    $0x10,%esp
f0101f6f:	85 c0                	test   %eax,%eax
f0101f71:	0f 85 7a 09 00 00    	jne    f01028f1 <mem_init+0x1108>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101f77:	8b 15 8c 1e 29 f0    	mov    0xf0291e8c,%edx
f0101f7d:	8b 02                	mov    (%edx),%eax
f0101f7f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101f84:	89 c1                	mov    %eax,%ecx
f0101f86:	c1 e9 0c             	shr    $0xc,%ecx
f0101f89:	3b 0d 88 1e 29 f0    	cmp    0xf0291e88,%ecx
f0101f8f:	0f 83 75 09 00 00    	jae    f010290a <mem_init+0x1121>
	return (void *)(pa + KERNBASE);
f0101f95:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101f9a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101f9d:	83 ec 04             	sub    $0x4,%esp
f0101fa0:	6a 00                	push   $0x0
f0101fa2:	68 00 10 00 00       	push   $0x1000
f0101fa7:	52                   	push   %edx
f0101fa8:	e8 05 f5 ff ff       	call   f01014b2 <pgdir_walk>
f0101fad:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101fb0:	8d 51 04             	lea    0x4(%ecx),%edx
f0101fb3:	83 c4 10             	add    $0x10,%esp
f0101fb6:	39 d0                	cmp    %edx,%eax
f0101fb8:	0f 85 61 09 00 00    	jne    f010291f <mem_init+0x1136>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101fbe:	6a 06                	push   $0x6
f0101fc0:	68 00 10 00 00       	push   $0x1000
f0101fc5:	56                   	push   %esi
f0101fc6:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f0101fcc:	e8 50 f7 ff ff       	call   f0101721 <page_insert>
f0101fd1:	83 c4 10             	add    $0x10,%esp
f0101fd4:	85 c0                	test   %eax,%eax
f0101fd6:	0f 85 5c 09 00 00    	jne    f0102938 <mem_init+0x114f>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101fdc:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f0101fe1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101fe4:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fe9:	e8 c6 ef ff ff       	call   f0100fb4 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101fee:	89 f2                	mov    %esi,%edx
f0101ff0:	2b 15 90 1e 29 f0    	sub    0xf0291e90,%edx
f0101ff6:	c1 fa 03             	sar    $0x3,%edx
f0101ff9:	c1 e2 0c             	shl    $0xc,%edx
f0101ffc:	39 d0                	cmp    %edx,%eax
f0101ffe:	0f 85 4d 09 00 00    	jne    f0102951 <mem_init+0x1168>
	assert(pp2->pp_ref == 1);
f0102004:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102009:	0f 85 5b 09 00 00    	jne    f010296a <mem_init+0x1181>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010200f:	83 ec 04             	sub    $0x4,%esp
f0102012:	6a 00                	push   $0x0
f0102014:	68 00 10 00 00       	push   $0x1000
f0102019:	ff 75 d4             	pushl  -0x2c(%ebp)
f010201c:	e8 91 f4 ff ff       	call   f01014b2 <pgdir_walk>
f0102021:	83 c4 10             	add    $0x10,%esp
f0102024:	f6 00 04             	testb  $0x4,(%eax)
f0102027:	0f 84 56 09 00 00    	je     f0102983 <mem_init+0x119a>
	assert(kern_pgdir[0] & PTE_U);
f010202d:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f0102032:	f6 00 04             	testb  $0x4,(%eax)
f0102035:	0f 84 61 09 00 00    	je     f010299c <mem_init+0x11b3>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010203b:	6a 02                	push   $0x2
f010203d:	68 00 10 00 00       	push   $0x1000
f0102042:	56                   	push   %esi
f0102043:	50                   	push   %eax
f0102044:	e8 d8 f6 ff ff       	call   f0101721 <page_insert>
f0102049:	83 c4 10             	add    $0x10,%esp
f010204c:	85 c0                	test   %eax,%eax
f010204e:	0f 85 61 09 00 00    	jne    f01029b5 <mem_init+0x11cc>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102054:	83 ec 04             	sub    $0x4,%esp
f0102057:	6a 00                	push   $0x0
f0102059:	68 00 10 00 00       	push   $0x1000
f010205e:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f0102064:	e8 49 f4 ff ff       	call   f01014b2 <pgdir_walk>
f0102069:	83 c4 10             	add    $0x10,%esp
f010206c:	f6 00 02             	testb  $0x2,(%eax)
f010206f:	0f 84 59 09 00 00    	je     f01029ce <mem_init+0x11e5>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102075:	83 ec 04             	sub    $0x4,%esp
f0102078:	6a 00                	push   $0x0
f010207a:	68 00 10 00 00       	push   $0x1000
f010207f:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f0102085:	e8 28 f4 ff ff       	call   f01014b2 <pgdir_walk>
f010208a:	83 c4 10             	add    $0x10,%esp
f010208d:	f6 00 04             	testb  $0x4,(%eax)
f0102090:	0f 85 51 09 00 00    	jne    f01029e7 <mem_init+0x11fe>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102096:	6a 02                	push   $0x2
f0102098:	68 00 00 40 00       	push   $0x400000
f010209d:	57                   	push   %edi
f010209e:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f01020a4:	e8 78 f6 ff ff       	call   f0101721 <page_insert>
f01020a9:	83 c4 10             	add    $0x10,%esp
f01020ac:	85 c0                	test   %eax,%eax
f01020ae:	0f 89 4c 09 00 00    	jns    f0102a00 <mem_init+0x1217>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01020b4:	6a 02                	push   $0x2
f01020b6:	68 00 10 00 00       	push   $0x1000
f01020bb:	53                   	push   %ebx
f01020bc:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f01020c2:	e8 5a f6 ff ff       	call   f0101721 <page_insert>
f01020c7:	83 c4 10             	add    $0x10,%esp
f01020ca:	85 c0                	test   %eax,%eax
f01020cc:	0f 85 47 09 00 00    	jne    f0102a19 <mem_init+0x1230>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020d2:	83 ec 04             	sub    $0x4,%esp
f01020d5:	6a 00                	push   $0x0
f01020d7:	68 00 10 00 00       	push   $0x1000
f01020dc:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f01020e2:	e8 cb f3 ff ff       	call   f01014b2 <pgdir_walk>
f01020e7:	83 c4 10             	add    $0x10,%esp
f01020ea:	f6 00 04             	testb  $0x4,(%eax)
f01020ed:	0f 85 3f 09 00 00    	jne    f0102a32 <mem_init+0x1249>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01020f3:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f01020f8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01020fb:	ba 00 00 00 00       	mov    $0x0,%edx
f0102100:	e8 af ee ff ff       	call   f0100fb4 <check_va2pa>
f0102105:	89 c1                	mov    %eax,%ecx
f0102107:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010210a:	89 d8                	mov    %ebx,%eax
f010210c:	2b 05 90 1e 29 f0    	sub    0xf0291e90,%eax
f0102112:	c1 f8 03             	sar    $0x3,%eax
f0102115:	c1 e0 0c             	shl    $0xc,%eax
f0102118:	39 c1                	cmp    %eax,%ecx
f010211a:	0f 85 2b 09 00 00    	jne    f0102a4b <mem_init+0x1262>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102120:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102125:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102128:	e8 87 ee ff ff       	call   f0100fb4 <check_va2pa>
f010212d:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102130:	0f 85 2e 09 00 00    	jne    f0102a64 <mem_init+0x127b>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102136:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f010213b:	0f 85 3c 09 00 00    	jne    f0102a7d <mem_init+0x1294>
	assert(pp2->pp_ref == 0);
f0102141:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102146:	0f 85 4a 09 00 00    	jne    f0102a96 <mem_init+0x12ad>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010214c:	83 ec 0c             	sub    $0xc,%esp
f010214f:	6a 00                	push   $0x0
f0102151:	e8 72 f2 ff ff       	call   f01013c8 <page_alloc>
f0102156:	83 c4 10             	add    $0x10,%esp
f0102159:	85 c0                	test   %eax,%eax
f010215b:	0f 84 4e 09 00 00    	je     f0102aaf <mem_init+0x12c6>
f0102161:	39 c6                	cmp    %eax,%esi
f0102163:	0f 85 46 09 00 00    	jne    f0102aaf <mem_init+0x12c6>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102169:	83 ec 08             	sub    $0x8,%esp
f010216c:	6a 00                	push   $0x0
f010216e:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f0102174:	e8 4e f5 ff ff       	call   f01016c7 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102179:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f010217e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102181:	ba 00 00 00 00       	mov    $0x0,%edx
f0102186:	e8 29 ee ff ff       	call   f0100fb4 <check_va2pa>
f010218b:	83 c4 10             	add    $0x10,%esp
f010218e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102191:	0f 85 31 09 00 00    	jne    f0102ac8 <mem_init+0x12df>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102197:	ba 00 10 00 00       	mov    $0x1000,%edx
f010219c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010219f:	e8 10 ee ff ff       	call   f0100fb4 <check_va2pa>
f01021a4:	89 da                	mov    %ebx,%edx
f01021a6:	2b 15 90 1e 29 f0    	sub    0xf0291e90,%edx
f01021ac:	c1 fa 03             	sar    $0x3,%edx
f01021af:	c1 e2 0c             	shl    $0xc,%edx
f01021b2:	39 d0                	cmp    %edx,%eax
f01021b4:	0f 85 27 09 00 00    	jne    f0102ae1 <mem_init+0x12f8>
	assert(pp1->pp_ref == 1);
f01021ba:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01021bf:	0f 85 35 09 00 00    	jne    f0102afa <mem_init+0x1311>
	assert(pp2->pp_ref == 0);
f01021c5:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01021ca:	0f 85 43 09 00 00    	jne    f0102b13 <mem_init+0x132a>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01021d0:	6a 00                	push   $0x0
f01021d2:	68 00 10 00 00       	push   $0x1000
f01021d7:	53                   	push   %ebx
f01021d8:	ff 75 d4             	pushl  -0x2c(%ebp)
f01021db:	e8 41 f5 ff ff       	call   f0101721 <page_insert>
f01021e0:	83 c4 10             	add    $0x10,%esp
f01021e3:	85 c0                	test   %eax,%eax
f01021e5:	0f 85 41 09 00 00    	jne    f0102b2c <mem_init+0x1343>
	assert(pp1->pp_ref);
f01021eb:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021f0:	0f 84 4f 09 00 00    	je     f0102b45 <mem_init+0x135c>
	assert(pp1->pp_link == NULL);
f01021f6:	83 3b 00             	cmpl   $0x0,(%ebx)
f01021f9:	0f 85 5f 09 00 00    	jne    f0102b5e <mem_init+0x1375>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01021ff:	83 ec 08             	sub    $0x8,%esp
f0102202:	68 00 10 00 00       	push   $0x1000
f0102207:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f010220d:	e8 b5 f4 ff ff       	call   f01016c7 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102212:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f0102217:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010221a:	ba 00 00 00 00       	mov    $0x0,%edx
f010221f:	e8 90 ed ff ff       	call   f0100fb4 <check_va2pa>
f0102224:	83 c4 10             	add    $0x10,%esp
f0102227:	83 f8 ff             	cmp    $0xffffffff,%eax
f010222a:	0f 85 47 09 00 00    	jne    f0102b77 <mem_init+0x138e>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102230:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102235:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102238:	e8 77 ed ff ff       	call   f0100fb4 <check_va2pa>
f010223d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102240:	0f 85 4a 09 00 00    	jne    f0102b90 <mem_init+0x13a7>
	assert(pp1->pp_ref == 0);
f0102246:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010224b:	0f 85 58 09 00 00    	jne    f0102ba9 <mem_init+0x13c0>
	assert(pp2->pp_ref == 0);
f0102251:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102256:	0f 85 66 09 00 00    	jne    f0102bc2 <mem_init+0x13d9>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010225c:	83 ec 0c             	sub    $0xc,%esp
f010225f:	6a 00                	push   $0x0
f0102261:	e8 62 f1 ff ff       	call   f01013c8 <page_alloc>
f0102266:	83 c4 10             	add    $0x10,%esp
f0102269:	85 c0                	test   %eax,%eax
f010226b:	0f 84 6a 09 00 00    	je     f0102bdb <mem_init+0x13f2>
f0102271:	39 c3                	cmp    %eax,%ebx
f0102273:	0f 85 62 09 00 00    	jne    f0102bdb <mem_init+0x13f2>

	// should be no free memory
	assert(!page_alloc(0));
f0102279:	83 ec 0c             	sub    $0xc,%esp
f010227c:	6a 00                	push   $0x0
f010227e:	e8 45 f1 ff ff       	call   f01013c8 <page_alloc>
f0102283:	83 c4 10             	add    $0x10,%esp
f0102286:	85 c0                	test   %eax,%eax
f0102288:	0f 85 66 09 00 00    	jne    f0102bf4 <mem_init+0x140b>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010228e:	8b 0d 8c 1e 29 f0    	mov    0xf0291e8c,%ecx
f0102294:	8b 11                	mov    (%ecx),%edx
f0102296:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010229c:	89 f8                	mov    %edi,%eax
f010229e:	2b 05 90 1e 29 f0    	sub    0xf0291e90,%eax
f01022a4:	c1 f8 03             	sar    $0x3,%eax
f01022a7:	c1 e0 0c             	shl    $0xc,%eax
f01022aa:	39 c2                	cmp    %eax,%edx
f01022ac:	0f 85 5b 09 00 00    	jne    f0102c0d <mem_init+0x1424>
	kern_pgdir[0] = 0;
f01022b2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01022b8:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01022bd:	0f 85 63 09 00 00    	jne    f0102c26 <mem_init+0x143d>
	pp0->pp_ref = 0;
f01022c3:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01022c9:	83 ec 0c             	sub    $0xc,%esp
f01022cc:	57                   	push   %edi
f01022cd:	e8 68 f1 ff ff       	call   f010143a <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01022d2:	83 c4 0c             	add    $0xc,%esp
f01022d5:	6a 01                	push   $0x1
f01022d7:	68 00 10 40 00       	push   $0x401000
f01022dc:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f01022e2:	e8 cb f1 ff ff       	call   f01014b2 <pgdir_walk>
f01022e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01022ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01022ed:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f01022f2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01022f5:	8b 50 04             	mov    0x4(%eax),%edx
f01022f8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f01022fe:	a1 88 1e 29 f0       	mov    0xf0291e88,%eax
f0102303:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102306:	89 d1                	mov    %edx,%ecx
f0102308:	c1 e9 0c             	shr    $0xc,%ecx
f010230b:	83 c4 10             	add    $0x10,%esp
f010230e:	39 c1                	cmp    %eax,%ecx
f0102310:	0f 83 29 09 00 00    	jae    f0102c3f <mem_init+0x1456>
	assert(ptep == ptep1 + PTX(va));
f0102316:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f010231c:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f010231f:	0f 85 2f 09 00 00    	jne    f0102c54 <mem_init+0x146b>
	kern_pgdir[PDX(va)] = 0;
f0102325:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102328:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f010232f:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
	return (pp - pages) << PGSHIFT;
f0102335:	89 f8                	mov    %edi,%eax
f0102337:	2b 05 90 1e 29 f0    	sub    0xf0291e90,%eax
f010233d:	c1 f8 03             	sar    $0x3,%eax
f0102340:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102343:	89 c2                	mov    %eax,%edx
f0102345:	c1 ea 0c             	shr    $0xc,%edx
f0102348:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f010234b:	0f 86 1c 09 00 00    	jbe    f0102c6d <mem_init+0x1484>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102351:	83 ec 04             	sub    $0x4,%esp
f0102354:	68 00 10 00 00       	push   $0x1000
f0102359:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f010235e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102363:	50                   	push   %eax
f0102364:	e8 85 36 00 00       	call   f01059ee <memset>
	page_free(pp0);
f0102369:	89 3c 24             	mov    %edi,(%esp)
f010236c:	e8 c9 f0 ff ff       	call   f010143a <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102371:	83 c4 0c             	add    $0xc,%esp
f0102374:	6a 01                	push   $0x1
f0102376:	6a 00                	push   $0x0
f0102378:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f010237e:	e8 2f f1 ff ff       	call   f01014b2 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0102383:	89 fa                	mov    %edi,%edx
f0102385:	2b 15 90 1e 29 f0    	sub    0xf0291e90,%edx
f010238b:	c1 fa 03             	sar    $0x3,%edx
f010238e:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102391:	89 d0                	mov    %edx,%eax
f0102393:	c1 e8 0c             	shr    $0xc,%eax
f0102396:	83 c4 10             	add    $0x10,%esp
f0102399:	3b 05 88 1e 29 f0    	cmp    0xf0291e88,%eax
f010239f:	0f 83 da 08 00 00    	jae    f0102c7f <mem_init+0x1496>
	return (void *)(pa + KERNBASE);
f01023a5:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01023ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01023ae:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01023b4:	f6 00 01             	testb  $0x1,(%eax)
f01023b7:	0f 85 d4 08 00 00    	jne    f0102c91 <mem_init+0x14a8>
f01023bd:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f01023c0:	39 d0                	cmp    %edx,%eax
f01023c2:	75 f0                	jne    f01023b4 <mem_init+0xbcb>
	kern_pgdir[0] = 0;
f01023c4:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f01023c9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01023cf:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f01023d5:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01023d8:	a3 40 12 29 f0       	mov    %eax,0xf0291240

	// free the pages we took
	page_free(pp0);
f01023dd:	83 ec 0c             	sub    $0xc,%esp
f01023e0:	57                   	push   %edi
f01023e1:	e8 54 f0 ff ff       	call   f010143a <page_free>
	page_free(pp1);
f01023e6:	89 1c 24             	mov    %ebx,(%esp)
f01023e9:	e8 4c f0 ff ff       	call   f010143a <page_free>
	page_free(pp2);
f01023ee:	89 34 24             	mov    %esi,(%esp)
f01023f1:	e8 44 f0 ff ff       	call   f010143a <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01023f6:	83 c4 08             	add    $0x8,%esp
f01023f9:	68 01 10 00 00       	push   $0x1001
f01023fe:	6a 00                	push   $0x0
f0102400:	e8 83 f3 ff ff       	call   f0101788 <mmio_map_region>
f0102405:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102407:	83 c4 08             	add    $0x8,%esp
f010240a:	68 00 10 00 00       	push   $0x1000
f010240f:	6a 00                	push   $0x0
f0102411:	e8 72 f3 ff ff       	call   f0101788 <mmio_map_region>
f0102416:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102418:	83 c4 10             	add    $0x10,%esp
f010241b:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102421:	0f 86 83 08 00 00    	jbe    f0102caa <mem_init+0x14c1>
f0102427:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f010242d:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102432:	0f 87 72 08 00 00    	ja     f0102caa <mem_init+0x14c1>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102438:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010243e:	0f 86 7f 08 00 00    	jbe    f0102cc3 <mem_init+0x14da>
f0102444:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f010244a:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102450:	0f 87 6d 08 00 00    	ja     f0102cc3 <mem_init+0x14da>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102456:	89 da                	mov    %ebx,%edx
f0102458:	09 f2                	or     %esi,%edx
f010245a:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102460:	0f 85 76 08 00 00    	jne    f0102cdc <mem_init+0x14f3>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102466:	39 c6                	cmp    %eax,%esi
f0102468:	0f 82 87 08 00 00    	jb     f0102cf5 <mem_init+0x150c>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f010246e:	8b 3d 8c 1e 29 f0    	mov    0xf0291e8c,%edi
f0102474:	89 da                	mov    %ebx,%edx
f0102476:	89 f8                	mov    %edi,%eax
f0102478:	e8 37 eb ff ff       	call   f0100fb4 <check_va2pa>
f010247d:	85 c0                	test   %eax,%eax
f010247f:	0f 85 89 08 00 00    	jne    f0102d0e <mem_init+0x1525>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102485:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f010248b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010248e:	89 c2                	mov    %eax,%edx
f0102490:	89 f8                	mov    %edi,%eax
f0102492:	e8 1d eb ff ff       	call   f0100fb4 <check_va2pa>
f0102497:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010249c:	0f 85 85 08 00 00    	jne    f0102d27 <mem_init+0x153e>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01024a2:	89 f2                	mov    %esi,%edx
f01024a4:	89 f8                	mov    %edi,%eax
f01024a6:	e8 09 eb ff ff       	call   f0100fb4 <check_va2pa>
f01024ab:	85 c0                	test   %eax,%eax
f01024ad:	0f 85 8d 08 00 00    	jne    f0102d40 <mem_init+0x1557>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01024b3:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01024b9:	89 f8                	mov    %edi,%eax
f01024bb:	e8 f4 ea ff ff       	call   f0100fb4 <check_va2pa>
f01024c0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024c3:	0f 85 90 08 00 00    	jne    f0102d59 <mem_init+0x1570>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01024c9:	83 ec 04             	sub    $0x4,%esp
f01024cc:	6a 00                	push   $0x0
f01024ce:	53                   	push   %ebx
f01024cf:	57                   	push   %edi
f01024d0:	e8 dd ef ff ff       	call   f01014b2 <pgdir_walk>
f01024d5:	83 c4 10             	add    $0x10,%esp
f01024d8:	f6 00 1a             	testb  $0x1a,(%eax)
f01024db:	0f 84 91 08 00 00    	je     f0102d72 <mem_init+0x1589>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01024e1:	83 ec 04             	sub    $0x4,%esp
f01024e4:	6a 00                	push   $0x0
f01024e6:	53                   	push   %ebx
f01024e7:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f01024ed:	e8 c0 ef ff ff       	call   f01014b2 <pgdir_walk>
f01024f2:	83 c4 10             	add    $0x10,%esp
f01024f5:	f6 00 04             	testb  $0x4,(%eax)
f01024f8:	0f 85 8d 08 00 00    	jne    f0102d8b <mem_init+0x15a2>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01024fe:	83 ec 04             	sub    $0x4,%esp
f0102501:	6a 00                	push   $0x0
f0102503:	53                   	push   %ebx
f0102504:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f010250a:	e8 a3 ef ff ff       	call   f01014b2 <pgdir_walk>
f010250f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102515:	83 c4 0c             	add    $0xc,%esp
f0102518:	6a 00                	push   $0x0
f010251a:	ff 75 d4             	pushl  -0x2c(%ebp)
f010251d:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f0102523:	e8 8a ef ff ff       	call   f01014b2 <pgdir_walk>
f0102528:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010252e:	83 c4 0c             	add    $0xc,%esp
f0102531:	6a 00                	push   $0x0
f0102533:	56                   	push   %esi
f0102534:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f010253a:	e8 73 ef ff ff       	call   f01014b2 <pgdir_walk>
f010253f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102545:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f010254c:	e8 24 1a 00 00       	call   f0103f75 <cprintf>
	pginfo_sz = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102551:	a1 88 1e 29 f0       	mov    0xf0291e88,%eax
f0102556:	8d 0c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ecx
f010255d:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_region(kern_pgdir, UPAGES, pginfo_sz, PADDR(pages), PTE_U | PTE_P);
f0102563:	a1 90 1e 29 f0       	mov    0xf0291e90,%eax
	if ((uint32_t)kva < KERNBASE)
f0102568:	83 c4 10             	add    $0x10,%esp
f010256b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102570:	0f 86 2e 08 00 00    	jbe    f0102da4 <mem_init+0x15bb>
f0102576:	83 ec 08             	sub    $0x8,%esp
f0102579:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f010257b:	05 00 00 00 10       	add    $0x10000000,%eax
f0102580:	50                   	push   %eax
f0102581:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102586:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f010258b:	e8 39 f0 ff ff       	call   f01015c9 <boot_map_region>
	env_sz = ROUNDUP(npages*sizeof(struct Env), PGSIZE);
f0102590:	8b 15 88 1e 29 f0    	mov    0xf0291e88,%edx
f0102596:	89 d0                	mov    %edx,%eax
f0102598:	c1 e0 05             	shl    $0x5,%eax
f010259b:	29 d0                	sub    %edx,%eax
f010259d:	8d 0c 85 ff 0f 00 00 	lea    0xfff(,%eax,4),%ecx
f01025a4:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_region(kern_pgdir, UENVS, env_sz, PADDR(envs), PTE_U | PTE_P);
f01025aa:	a1 48 12 29 f0       	mov    0xf0291248,%eax
	if ((uint32_t)kva < KERNBASE)
f01025af:	83 c4 10             	add    $0x10,%esp
f01025b2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025b7:	0f 86 fc 07 00 00    	jbe    f0102db9 <mem_init+0x15d0>
f01025bd:	83 ec 08             	sub    $0x8,%esp
f01025c0:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01025c2:	05 00 00 00 10       	add    $0x10000000,%eax
f01025c7:	50                   	push   %eax
f01025c8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01025cd:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f01025d2:	e8 f2 ef ff ff       	call   f01015c9 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01025d7:	83 c4 10             	add    $0x10,%esp
f01025da:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f01025df:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025e4:	0f 86 e4 07 00 00    	jbe    f0102dce <mem_init+0x15e5>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, 
f01025ea:	83 ec 08             	sub    $0x8,%esp
f01025ed:	6a 03                	push   $0x3
f01025ef:	68 00 80 11 00       	push   $0x118000
f01025f4:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01025f9:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01025fe:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f0102603:	e8 c1 ef ff ff       	call   f01015c9 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 1 << 28, // 2^32 - 0xf0000000
f0102608:	83 c4 08             	add    $0x8,%esp
f010260b:	6a 03                	push   $0x3
f010260d:	6a 00                	push   $0x0
f010260f:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102614:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102619:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f010261e:	e8 a6 ef ff ff       	call   f01015c9 <boot_map_region>
f0102623:	c7 45 c8 00 30 29 f0 	movl   $0xf0293000,-0x38(%ebp)
f010262a:	be 00 30 2d f0       	mov    $0xf02d3000,%esi
f010262f:	83 c4 10             	add    $0x10,%esp
f0102632:	bf 00 30 29 f0       	mov    $0xf0293000,%edi
f0102637:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
f010263c:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0102642:	0f 86 9b 07 00 00    	jbe    f0102de3 <mem_init+0x15fa>
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, 
f0102648:	83 ec 08             	sub    $0x8,%esp
f010264b:	6a 02                	push   $0x2
f010264d:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0102653:	50                   	push   %eax
f0102654:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102659:	89 da                	mov    %ebx,%edx
f010265b:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f0102660:	e8 64 ef ff ff       	call   f01015c9 <boot_map_region>
f0102665:	81 c7 00 80 00 00    	add    $0x8000,%edi
f010266b:	81 eb 00 00 01 00    	sub    $0x10000,%ebx
	for (size_t i = 0; i < NCPU; i++) { // `ncpu` is not set yet, we just use NCPU = 8.
f0102671:	83 c4 10             	add    $0x10,%esp
f0102674:	39 f7                	cmp    %esi,%edi
f0102676:	75 c4                	jne    f010263c <mem_init+0xe53>
f0102678:	89 7d c4             	mov    %edi,-0x3c(%ebp)
	pgdir = kern_pgdir;
f010267b:	8b 3d 8c 1e 29 f0    	mov    0xf0291e8c,%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102681:	a1 88 1e 29 f0       	mov    0xf0291e88,%eax
f0102686:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102689:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102690:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102695:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102698:	a1 90 1e 29 f0       	mov    0xf0291e90,%eax
f010269d:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01026a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
	return (physaddr_t)kva - KERNBASE;
f01026a3:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
	for (i = 0; i < n; i += PGSIZE) 
f01026a9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01026ae:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01026b1:	0f 86 71 07 00 00    	jbe    f0102e28 <mem_init+0x163f>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01026b7:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01026bd:	89 f8                	mov    %edi,%eax
f01026bf:	e8 f0 e8 ff ff       	call   f0100fb4 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01026c4:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01026cb:	0f 86 27 07 00 00    	jbe    f0102df8 <mem_init+0x160f>
f01026d1:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f01026d4:	39 d0                	cmp    %edx,%eax
f01026d6:	0f 85 33 07 00 00    	jne    f0102e0f <mem_init+0x1626>
	for (i = 0; i < n; i += PGSIZE) 
f01026dc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01026e2:	eb ca                	jmp    f01026ae <mem_init+0xec5>
	assert(nfree == 0);
f01026e4:	68 39 7b 10 f0       	push   $0xf0107b39
f01026e9:	68 43 79 10 f0       	push   $0xf0107943
f01026ee:	68 18 03 00 00       	push   $0x318
f01026f3:	68 1d 79 10 f0       	push   $0xf010791d
f01026f8:	e8 97 d9 ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f01026fd:	68 47 7a 10 f0       	push   $0xf0107a47
f0102702:	68 43 79 10 f0       	push   $0xf0107943
f0102707:	68 7e 03 00 00       	push   $0x37e
f010270c:	68 1d 79 10 f0       	push   $0xf010791d
f0102711:	e8 7e d9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0102716:	68 5d 7a 10 f0       	push   $0xf0107a5d
f010271b:	68 43 79 10 f0       	push   $0xf0107943
f0102720:	68 7f 03 00 00       	push   $0x37f
f0102725:	68 1d 79 10 f0       	push   $0xf010791d
f010272a:	e8 65 d9 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f010272f:	68 73 7a 10 f0       	push   $0xf0107a73
f0102734:	68 43 79 10 f0       	push   $0xf0107943
f0102739:	68 80 03 00 00       	push   $0x380
f010273e:	68 1d 79 10 f0       	push   $0xf010791d
f0102743:	e8 4c d9 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f0102748:	68 89 7a 10 f0       	push   $0xf0107a89
f010274d:	68 43 79 10 f0       	push   $0xf0107943
f0102752:	68 83 03 00 00       	push   $0x383
f0102757:	68 1d 79 10 f0       	push   $0xf010791d
f010275c:	e8 33 d9 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102761:	68 40 71 10 f0       	push   $0xf0107140
f0102766:	68 43 79 10 f0       	push   $0xf0107943
f010276b:	68 84 03 00 00       	push   $0x384
f0102770:	68 1d 79 10 f0       	push   $0xf010791d
f0102775:	e8 1a d9 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f010277a:	68 f2 7a 10 f0       	push   $0xf0107af2
f010277f:	68 43 79 10 f0       	push   $0xf0107943
f0102784:	68 8b 03 00 00       	push   $0x38b
f0102789:	68 1d 79 10 f0       	push   $0xf010791d
f010278e:	e8 01 d9 ff ff       	call   f0100094 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102793:	68 80 71 10 f0       	push   $0xf0107180
f0102798:	68 43 79 10 f0       	push   $0xf0107943
f010279d:	68 8e 03 00 00       	push   $0x38e
f01027a2:	68 1d 79 10 f0       	push   $0xf010791d
f01027a7:	e8 e8 d8 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01027ac:	68 b8 71 10 f0       	push   $0xf01071b8
f01027b1:	68 43 79 10 f0       	push   $0xf0107943
f01027b6:	68 91 03 00 00       	push   $0x391
f01027bb:	68 1d 79 10 f0       	push   $0xf010791d
f01027c0:	e8 cf d8 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01027c5:	68 e8 71 10 f0       	push   $0xf01071e8
f01027ca:	68 43 79 10 f0       	push   $0xf0107943
f01027cf:	68 95 03 00 00       	push   $0x395
f01027d4:	68 1d 79 10 f0       	push   $0xf010791d
f01027d9:	e8 b6 d8 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01027de:	68 18 72 10 f0       	push   $0xf0107218
f01027e3:	68 43 79 10 f0       	push   $0xf0107943
f01027e8:	68 96 03 00 00       	push   $0x396
f01027ed:	68 1d 79 10 f0       	push   $0xf010791d
f01027f2:	e8 9d d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01027f7:	68 40 72 10 f0       	push   $0xf0107240
f01027fc:	68 43 79 10 f0       	push   $0xf0107943
f0102801:	68 97 03 00 00       	push   $0x397
f0102806:	68 1d 79 10 f0       	push   $0xf010791d
f010280b:	e8 84 d8 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102810:	68 44 7b 10 f0       	push   $0xf0107b44
f0102815:	68 43 79 10 f0       	push   $0xf0107943
f010281a:	68 98 03 00 00       	push   $0x398
f010281f:	68 1d 79 10 f0       	push   $0xf010791d
f0102824:	e8 6b d8 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0102829:	68 55 7b 10 f0       	push   $0xf0107b55
f010282e:	68 43 79 10 f0       	push   $0xf0107943
f0102833:	68 99 03 00 00       	push   $0x399
f0102838:	68 1d 79 10 f0       	push   $0xf010791d
f010283d:	e8 52 d8 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102842:	68 70 72 10 f0       	push   $0xf0107270
f0102847:	68 43 79 10 f0       	push   $0xf0107943
f010284c:	68 9c 03 00 00       	push   $0x39c
f0102851:	68 1d 79 10 f0       	push   $0xf010791d
f0102856:	e8 39 d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010285b:	68 ac 72 10 f0       	push   $0xf01072ac
f0102860:	68 43 79 10 f0       	push   $0xf0107943
f0102865:	68 9d 03 00 00       	push   $0x39d
f010286a:	68 1d 79 10 f0       	push   $0xf010791d
f010286f:	e8 20 d8 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102874:	68 66 7b 10 f0       	push   $0xf0107b66
f0102879:	68 43 79 10 f0       	push   $0xf0107943
f010287e:	68 9e 03 00 00       	push   $0x39e
f0102883:	68 1d 79 10 f0       	push   $0xf010791d
f0102888:	e8 07 d8 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f010288d:	68 f2 7a 10 f0       	push   $0xf0107af2
f0102892:	68 43 79 10 f0       	push   $0xf0107943
f0102897:	68 a1 03 00 00       	push   $0x3a1
f010289c:	68 1d 79 10 f0       	push   $0xf010791d
f01028a1:	e8 ee d7 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01028a6:	68 70 72 10 f0       	push   $0xf0107270
f01028ab:	68 43 79 10 f0       	push   $0xf0107943
f01028b0:	68 a4 03 00 00       	push   $0x3a4
f01028b5:	68 1d 79 10 f0       	push   $0xf010791d
f01028ba:	e8 d5 d7 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01028bf:	68 ac 72 10 f0       	push   $0xf01072ac
f01028c4:	68 43 79 10 f0       	push   $0xf0107943
f01028c9:	68 a5 03 00 00       	push   $0x3a5
f01028ce:	68 1d 79 10 f0       	push   $0xf010791d
f01028d3:	e8 bc d7 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f01028d8:	68 66 7b 10 f0       	push   $0xf0107b66
f01028dd:	68 43 79 10 f0       	push   $0xf0107943
f01028e2:	68 a6 03 00 00       	push   $0x3a6
f01028e7:	68 1d 79 10 f0       	push   $0xf010791d
f01028ec:	e8 a3 d7 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01028f1:	68 f2 7a 10 f0       	push   $0xf0107af2
f01028f6:	68 43 79 10 f0       	push   $0xf0107943
f01028fb:	68 aa 03 00 00       	push   $0x3aa
f0102900:	68 1d 79 10 f0       	push   $0xf010791d
f0102905:	e8 8a d7 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010290a:	50                   	push   %eax
f010290b:	68 48 68 10 f0       	push   $0xf0106848
f0102910:	68 ad 03 00 00       	push   $0x3ad
f0102915:	68 1d 79 10 f0       	push   $0xf010791d
f010291a:	e8 75 d7 ff ff       	call   f0100094 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010291f:	68 dc 72 10 f0       	push   $0xf01072dc
f0102924:	68 43 79 10 f0       	push   $0xf0107943
f0102929:	68 ae 03 00 00       	push   $0x3ae
f010292e:	68 1d 79 10 f0       	push   $0xf010791d
f0102933:	e8 5c d7 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102938:	68 1c 73 10 f0       	push   $0xf010731c
f010293d:	68 43 79 10 f0       	push   $0xf0107943
f0102942:	68 b1 03 00 00       	push   $0x3b1
f0102947:	68 1d 79 10 f0       	push   $0xf010791d
f010294c:	e8 43 d7 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102951:	68 ac 72 10 f0       	push   $0xf01072ac
f0102956:	68 43 79 10 f0       	push   $0xf0107943
f010295b:	68 b2 03 00 00       	push   $0x3b2
f0102960:	68 1d 79 10 f0       	push   $0xf010791d
f0102965:	e8 2a d7 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f010296a:	68 66 7b 10 f0       	push   $0xf0107b66
f010296f:	68 43 79 10 f0       	push   $0xf0107943
f0102974:	68 b3 03 00 00       	push   $0x3b3
f0102979:	68 1d 79 10 f0       	push   $0xf010791d
f010297e:	e8 11 d7 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102983:	68 5c 73 10 f0       	push   $0xf010735c
f0102988:	68 43 79 10 f0       	push   $0xf0107943
f010298d:	68 b4 03 00 00       	push   $0x3b4
f0102992:	68 1d 79 10 f0       	push   $0xf010791d
f0102997:	e8 f8 d6 ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010299c:	68 77 7b 10 f0       	push   $0xf0107b77
f01029a1:	68 43 79 10 f0       	push   $0xf0107943
f01029a6:	68 b5 03 00 00       	push   $0x3b5
f01029ab:	68 1d 79 10 f0       	push   $0xf010791d
f01029b0:	e8 df d6 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01029b5:	68 70 72 10 f0       	push   $0xf0107270
f01029ba:	68 43 79 10 f0       	push   $0xf0107943
f01029bf:	68 b8 03 00 00       	push   $0x3b8
f01029c4:	68 1d 79 10 f0       	push   $0xf010791d
f01029c9:	e8 c6 d6 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01029ce:	68 90 73 10 f0       	push   $0xf0107390
f01029d3:	68 43 79 10 f0       	push   $0xf0107943
f01029d8:	68 b9 03 00 00       	push   $0x3b9
f01029dd:	68 1d 79 10 f0       	push   $0xf010791d
f01029e2:	e8 ad d6 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01029e7:	68 c4 73 10 f0       	push   $0xf01073c4
f01029ec:	68 43 79 10 f0       	push   $0xf0107943
f01029f1:	68 ba 03 00 00       	push   $0x3ba
f01029f6:	68 1d 79 10 f0       	push   $0xf010791d
f01029fb:	e8 94 d6 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102a00:	68 fc 73 10 f0       	push   $0xf01073fc
f0102a05:	68 43 79 10 f0       	push   $0xf0107943
f0102a0a:	68 bd 03 00 00       	push   $0x3bd
f0102a0f:	68 1d 79 10 f0       	push   $0xf010791d
f0102a14:	e8 7b d6 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102a19:	68 34 74 10 f0       	push   $0xf0107434
f0102a1e:	68 43 79 10 f0       	push   $0xf0107943
f0102a23:	68 c0 03 00 00       	push   $0x3c0
f0102a28:	68 1d 79 10 f0       	push   $0xf010791d
f0102a2d:	e8 62 d6 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102a32:	68 c4 73 10 f0       	push   $0xf01073c4
f0102a37:	68 43 79 10 f0       	push   $0xf0107943
f0102a3c:	68 c1 03 00 00       	push   $0x3c1
f0102a41:	68 1d 79 10 f0       	push   $0xf010791d
f0102a46:	e8 49 d6 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102a4b:	68 70 74 10 f0       	push   $0xf0107470
f0102a50:	68 43 79 10 f0       	push   $0xf0107943
f0102a55:	68 c4 03 00 00       	push   $0x3c4
f0102a5a:	68 1d 79 10 f0       	push   $0xf010791d
f0102a5f:	e8 30 d6 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102a64:	68 9c 74 10 f0       	push   $0xf010749c
f0102a69:	68 43 79 10 f0       	push   $0xf0107943
f0102a6e:	68 c5 03 00 00       	push   $0x3c5
f0102a73:	68 1d 79 10 f0       	push   $0xf010791d
f0102a78:	e8 17 d6 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 2);
f0102a7d:	68 8d 7b 10 f0       	push   $0xf0107b8d
f0102a82:	68 43 79 10 f0       	push   $0xf0107943
f0102a87:	68 c7 03 00 00       	push   $0x3c7
f0102a8c:	68 1d 79 10 f0       	push   $0xf010791d
f0102a91:	e8 fe d5 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102a96:	68 9e 7b 10 f0       	push   $0xf0107b9e
f0102a9b:	68 43 79 10 f0       	push   $0xf0107943
f0102aa0:	68 c8 03 00 00       	push   $0x3c8
f0102aa5:	68 1d 79 10 f0       	push   $0xf010791d
f0102aaa:	e8 e5 d5 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102aaf:	68 cc 74 10 f0       	push   $0xf01074cc
f0102ab4:	68 43 79 10 f0       	push   $0xf0107943
f0102ab9:	68 cb 03 00 00       	push   $0x3cb
f0102abe:	68 1d 79 10 f0       	push   $0xf010791d
f0102ac3:	e8 cc d5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102ac8:	68 f0 74 10 f0       	push   $0xf01074f0
f0102acd:	68 43 79 10 f0       	push   $0xf0107943
f0102ad2:	68 cf 03 00 00       	push   $0x3cf
f0102ad7:	68 1d 79 10 f0       	push   $0xf010791d
f0102adc:	e8 b3 d5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102ae1:	68 9c 74 10 f0       	push   $0xf010749c
f0102ae6:	68 43 79 10 f0       	push   $0xf0107943
f0102aeb:	68 d0 03 00 00       	push   $0x3d0
f0102af0:	68 1d 79 10 f0       	push   $0xf010791d
f0102af5:	e8 9a d5 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102afa:	68 44 7b 10 f0       	push   $0xf0107b44
f0102aff:	68 43 79 10 f0       	push   $0xf0107943
f0102b04:	68 d1 03 00 00       	push   $0x3d1
f0102b09:	68 1d 79 10 f0       	push   $0xf010791d
f0102b0e:	e8 81 d5 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102b13:	68 9e 7b 10 f0       	push   $0xf0107b9e
f0102b18:	68 43 79 10 f0       	push   $0xf0107943
f0102b1d:	68 d2 03 00 00       	push   $0x3d2
f0102b22:	68 1d 79 10 f0       	push   $0xf010791d
f0102b27:	e8 68 d5 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102b2c:	68 14 75 10 f0       	push   $0xf0107514
f0102b31:	68 43 79 10 f0       	push   $0xf0107943
f0102b36:	68 d5 03 00 00       	push   $0x3d5
f0102b3b:	68 1d 79 10 f0       	push   $0xf010791d
f0102b40:	e8 4f d5 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f0102b45:	68 af 7b 10 f0       	push   $0xf0107baf
f0102b4a:	68 43 79 10 f0       	push   $0xf0107943
f0102b4f:	68 d6 03 00 00       	push   $0x3d6
f0102b54:	68 1d 79 10 f0       	push   $0xf010791d
f0102b59:	e8 36 d5 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f0102b5e:	68 bb 7b 10 f0       	push   $0xf0107bbb
f0102b63:	68 43 79 10 f0       	push   $0xf0107943
f0102b68:	68 d7 03 00 00       	push   $0x3d7
f0102b6d:	68 1d 79 10 f0       	push   $0xf010791d
f0102b72:	e8 1d d5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102b77:	68 f0 74 10 f0       	push   $0xf01074f0
f0102b7c:	68 43 79 10 f0       	push   $0xf0107943
f0102b81:	68 db 03 00 00       	push   $0x3db
f0102b86:	68 1d 79 10 f0       	push   $0xf010791d
f0102b8b:	e8 04 d5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102b90:	68 4c 75 10 f0       	push   $0xf010754c
f0102b95:	68 43 79 10 f0       	push   $0xf0107943
f0102b9a:	68 dc 03 00 00       	push   $0x3dc
f0102b9f:	68 1d 79 10 f0       	push   $0xf010791d
f0102ba4:	e8 eb d4 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102ba9:	68 d0 7b 10 f0       	push   $0xf0107bd0
f0102bae:	68 43 79 10 f0       	push   $0xf0107943
f0102bb3:	68 dd 03 00 00       	push   $0x3dd
f0102bb8:	68 1d 79 10 f0       	push   $0xf010791d
f0102bbd:	e8 d2 d4 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102bc2:	68 9e 7b 10 f0       	push   $0xf0107b9e
f0102bc7:	68 43 79 10 f0       	push   $0xf0107943
f0102bcc:	68 de 03 00 00       	push   $0x3de
f0102bd1:	68 1d 79 10 f0       	push   $0xf010791d
f0102bd6:	e8 b9 d4 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102bdb:	68 74 75 10 f0       	push   $0xf0107574
f0102be0:	68 43 79 10 f0       	push   $0xf0107943
f0102be5:	68 e1 03 00 00       	push   $0x3e1
f0102bea:	68 1d 79 10 f0       	push   $0xf010791d
f0102bef:	e8 a0 d4 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0102bf4:	68 f2 7a 10 f0       	push   $0xf0107af2
f0102bf9:	68 43 79 10 f0       	push   $0xf0107943
f0102bfe:	68 e4 03 00 00       	push   $0x3e4
f0102c03:	68 1d 79 10 f0       	push   $0xf010791d
f0102c08:	e8 87 d4 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c0d:	68 18 72 10 f0       	push   $0xf0107218
f0102c12:	68 43 79 10 f0       	push   $0xf0107943
f0102c17:	68 e7 03 00 00       	push   $0x3e7
f0102c1c:	68 1d 79 10 f0       	push   $0xf010791d
f0102c21:	e8 6e d4 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0102c26:	68 55 7b 10 f0       	push   $0xf0107b55
f0102c2b:	68 43 79 10 f0       	push   $0xf0107943
f0102c30:	68 e9 03 00 00       	push   $0x3e9
f0102c35:	68 1d 79 10 f0       	push   $0xf010791d
f0102c3a:	e8 55 d4 ff ff       	call   f0100094 <_panic>
f0102c3f:	52                   	push   %edx
f0102c40:	68 48 68 10 f0       	push   $0xf0106848
f0102c45:	68 f0 03 00 00       	push   $0x3f0
f0102c4a:	68 1d 79 10 f0       	push   $0xf010791d
f0102c4f:	e8 40 d4 ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102c54:	68 e1 7b 10 f0       	push   $0xf0107be1
f0102c59:	68 43 79 10 f0       	push   $0xf0107943
f0102c5e:	68 f1 03 00 00       	push   $0x3f1
f0102c63:	68 1d 79 10 f0       	push   $0xf010791d
f0102c68:	e8 27 d4 ff ff       	call   f0100094 <_panic>
f0102c6d:	50                   	push   %eax
f0102c6e:	68 48 68 10 f0       	push   $0xf0106848
f0102c73:	6a 58                	push   $0x58
f0102c75:	68 29 79 10 f0       	push   $0xf0107929
f0102c7a:	e8 15 d4 ff ff       	call   f0100094 <_panic>
f0102c7f:	52                   	push   %edx
f0102c80:	68 48 68 10 f0       	push   $0xf0106848
f0102c85:	6a 58                	push   $0x58
f0102c87:	68 29 79 10 f0       	push   $0xf0107929
f0102c8c:	e8 03 d4 ff ff       	call   f0100094 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102c91:	68 f9 7b 10 f0       	push   $0xf0107bf9
f0102c96:	68 43 79 10 f0       	push   $0xf0107943
f0102c9b:	68 fb 03 00 00       	push   $0x3fb
f0102ca0:	68 1d 79 10 f0       	push   $0xf010791d
f0102ca5:	e8 ea d3 ff ff       	call   f0100094 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102caa:	68 98 75 10 f0       	push   $0xf0107598
f0102caf:	68 43 79 10 f0       	push   $0xf0107943
f0102cb4:	68 0b 04 00 00       	push   $0x40b
f0102cb9:	68 1d 79 10 f0       	push   $0xf010791d
f0102cbe:	e8 d1 d3 ff ff       	call   f0100094 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102cc3:	68 c0 75 10 f0       	push   $0xf01075c0
f0102cc8:	68 43 79 10 f0       	push   $0xf0107943
f0102ccd:	68 0c 04 00 00       	push   $0x40c
f0102cd2:	68 1d 79 10 f0       	push   $0xf010791d
f0102cd7:	e8 b8 d3 ff ff       	call   f0100094 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102cdc:	68 e8 75 10 f0       	push   $0xf01075e8
f0102ce1:	68 43 79 10 f0       	push   $0xf0107943
f0102ce6:	68 0e 04 00 00       	push   $0x40e
f0102ceb:	68 1d 79 10 f0       	push   $0xf010791d
f0102cf0:	e8 9f d3 ff ff       	call   f0100094 <_panic>
	assert(mm1 + 8096 <= mm2);
f0102cf5:	68 10 7c 10 f0       	push   $0xf0107c10
f0102cfa:	68 43 79 10 f0       	push   $0xf0107943
f0102cff:	68 10 04 00 00       	push   $0x410
f0102d04:	68 1d 79 10 f0       	push   $0xf010791d
f0102d09:	e8 86 d3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102d0e:	68 10 76 10 f0       	push   $0xf0107610
f0102d13:	68 43 79 10 f0       	push   $0xf0107943
f0102d18:	68 12 04 00 00       	push   $0x412
f0102d1d:	68 1d 79 10 f0       	push   $0xf010791d
f0102d22:	e8 6d d3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102d27:	68 34 76 10 f0       	push   $0xf0107634
f0102d2c:	68 43 79 10 f0       	push   $0xf0107943
f0102d31:	68 13 04 00 00       	push   $0x413
f0102d36:	68 1d 79 10 f0       	push   $0xf010791d
f0102d3b:	e8 54 d3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102d40:	68 64 76 10 f0       	push   $0xf0107664
f0102d45:	68 43 79 10 f0       	push   $0xf0107943
f0102d4a:	68 14 04 00 00       	push   $0x414
f0102d4f:	68 1d 79 10 f0       	push   $0xf010791d
f0102d54:	e8 3b d3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102d59:	68 88 76 10 f0       	push   $0xf0107688
f0102d5e:	68 43 79 10 f0       	push   $0xf0107943
f0102d63:	68 15 04 00 00       	push   $0x415
f0102d68:	68 1d 79 10 f0       	push   $0xf010791d
f0102d6d:	e8 22 d3 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102d72:	68 b4 76 10 f0       	push   $0xf01076b4
f0102d77:	68 43 79 10 f0       	push   $0xf0107943
f0102d7c:	68 17 04 00 00       	push   $0x417
f0102d81:	68 1d 79 10 f0       	push   $0xf010791d
f0102d86:	e8 09 d3 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102d8b:	68 f8 76 10 f0       	push   $0xf01076f8
f0102d90:	68 43 79 10 f0       	push   $0xf0107943
f0102d95:	68 18 04 00 00       	push   $0x418
f0102d9a:	68 1d 79 10 f0       	push   $0xf010791d
f0102d9f:	e8 f0 d2 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102da4:	50                   	push   %eax
f0102da5:	68 6c 68 10 f0       	push   $0xf010686c
f0102daa:	68 bd 00 00 00       	push   $0xbd
f0102daf:	68 1d 79 10 f0       	push   $0xf010791d
f0102db4:	e8 db d2 ff ff       	call   f0100094 <_panic>
f0102db9:	50                   	push   %eax
f0102dba:	68 6c 68 10 f0       	push   $0xf010686c
f0102dbf:	68 c7 00 00 00       	push   $0xc7
f0102dc4:	68 1d 79 10 f0       	push   $0xf010791d
f0102dc9:	e8 c6 d2 ff ff       	call   f0100094 <_panic>
f0102dce:	50                   	push   %eax
f0102dcf:	68 6c 68 10 f0       	push   $0xf010686c
f0102dd4:	68 d4 00 00 00       	push   $0xd4
f0102dd9:	68 1d 79 10 f0       	push   $0xf010791d
f0102dde:	e8 b1 d2 ff ff       	call   f0100094 <_panic>
f0102de3:	57                   	push   %edi
f0102de4:	68 6c 68 10 f0       	push   $0xf010686c
f0102de9:	68 14 01 00 00       	push   $0x114
f0102dee:	68 1d 79 10 f0       	push   $0xf010791d
f0102df3:	e8 9c d2 ff ff       	call   f0100094 <_panic>
f0102df8:	ff 75 c0             	pushl  -0x40(%ebp)
f0102dfb:	68 6c 68 10 f0       	push   $0xf010686c
f0102e00:	68 30 03 00 00       	push   $0x330
f0102e05:	68 1d 79 10 f0       	push   $0xf010791d
f0102e0a:	e8 85 d2 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e0f:	68 2c 77 10 f0       	push   $0xf010772c
f0102e14:	68 43 79 10 f0       	push   $0xf0107943
f0102e19:	68 30 03 00 00       	push   $0x330
f0102e1e:	68 1d 79 10 f0       	push   $0xf010791d
f0102e23:	e8 6c d2 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102e28:	a1 48 12 29 f0       	mov    0xf0291248,%eax
f0102e2d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((uint32_t)kva < KERNBASE)
f0102e30:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102e33:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102e38:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f0102e3e:	89 da                	mov    %ebx,%edx
f0102e40:	89 f8                	mov    %edi,%eax
f0102e42:	e8 6d e1 ff ff       	call   f0100fb4 <check_va2pa>
f0102e47:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102e4e:	76 22                	jbe    f0102e72 <mem_init+0x1689>
f0102e50:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102e53:	39 d0                	cmp    %edx,%eax
f0102e55:	75 32                	jne    f0102e89 <mem_init+0x16a0>
f0102e57:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f0102e5d:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102e63:	75 d9                	jne    f0102e3e <mem_init+0x1655>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e65:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102e68:	c1 e6 0c             	shl    $0xc,%esi
f0102e6b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102e70:	eb 4b                	jmp    f0102ebd <mem_init+0x16d4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e72:	ff 75 d0             	pushl  -0x30(%ebp)
f0102e75:	68 6c 68 10 f0       	push   $0xf010686c
f0102e7a:	68 35 03 00 00       	push   $0x335
f0102e7f:	68 1d 79 10 f0       	push   $0xf010791d
f0102e84:	e8 0b d2 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102e89:	68 60 77 10 f0       	push   $0xf0107760
f0102e8e:	68 43 79 10 f0       	push   $0xf0107943
f0102e93:	68 35 03 00 00       	push   $0x335
f0102e98:	68 1d 79 10 f0       	push   $0xf010791d
f0102e9d:	e8 f2 d1 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102ea2:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102ea8:	89 f8                	mov    %edi,%eax
f0102eaa:	e8 05 e1 ff ff       	call   f0100fb4 <check_va2pa>
f0102eaf:	39 c3                	cmp    %eax,%ebx
f0102eb1:	0f 85 f5 00 00 00    	jne    f0102fac <mem_init+0x17c3>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102eb7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ebd:	39 f3                	cmp    %esi,%ebx
f0102ebf:	72 e1                	jb     f0102ea2 <mem_init+0x16b9>
f0102ec1:	c7 45 d4 00 30 29 f0 	movl   $0xf0293000,-0x2c(%ebp)
f0102ec8:	c7 45 cc 00 80 ff ef 	movl   $0xefff8000,-0x34(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102ecf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ed2:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0102ed5:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0102ed8:	8d 83 00 80 00 00    	lea    0x8000(%ebx),%eax
f0102ede:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102ee1:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102ee4:	8d b0 00 80 00 20    	lea    0x20008000(%eax),%esi
f0102eea:	89 da                	mov    %ebx,%edx
f0102eec:	89 f8                	mov    %edi,%eax
f0102eee:	e8 c1 e0 ff ff       	call   f0100fb4 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102ef3:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102efa:	0f 86 c5 00 00 00    	jbe    f0102fc5 <mem_init+0x17dc>
f0102f00:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102f03:	39 d0                	cmp    %edx,%eax
f0102f05:	0f 85 d1 00 00 00    	jne    f0102fdc <mem_init+0x17f3>
f0102f0b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102f11:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102f14:	75 d4                	jne    f0102eea <mem_init+0x1701>
f0102f16:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102f19:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102f1f:	89 da                	mov    %ebx,%edx
f0102f21:	89 f8                	mov    %edi,%eax
f0102f23:	e8 8c e0 ff ff       	call   f0100fb4 <check_va2pa>
f0102f28:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102f2b:	0f 85 c4 00 00 00    	jne    f0102ff5 <mem_init+0x180c>
f0102f31:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102f37:	39 f3                	cmp    %esi,%ebx
f0102f39:	75 e4                	jne    f0102f1f <mem_init+0x1736>
f0102f3b:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102f42:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102f49:	81 45 d4 00 80 00 00 	addl   $0x8000,-0x2c(%ebp)
f0102f50:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	for (n = 0; n < NCPU; n++) {
f0102f53:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
f0102f56:	0f 85 73 ff ff ff    	jne    f0102ecf <mem_init+0x16e6>
	for (i = 0; i < NPDENTRIES; i++) {
f0102f5c:	b8 00 00 00 00       	mov    $0x0,%eax
			if (i >= PDX(KERNBASE)) {
f0102f61:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102f66:	0f 87 a2 00 00 00    	ja     f010300e <mem_init+0x1825>
				assert(pgdir[i] == 0);
f0102f6c:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102f70:	0f 85 db 00 00 00    	jne    f0103051 <mem_init+0x1868>
	for (i = 0; i < NPDENTRIES; i++) {
f0102f76:	40                   	inc    %eax
f0102f77:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102f7c:	0f 87 e8 00 00 00    	ja     f010306a <mem_init+0x1881>
		switch (i) {
f0102f82:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102f88:	83 fa 04             	cmp    $0x4,%edx
f0102f8b:	77 d4                	ja     f0102f61 <mem_init+0x1778>
			assert(pgdir[i] & PTE_P);
f0102f8d:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102f91:	75 e3                	jne    f0102f76 <mem_init+0x178d>
f0102f93:	68 3b 7c 10 f0       	push   $0xf0107c3b
f0102f98:	68 43 79 10 f0       	push   $0xf0107943
f0102f9d:	68 4e 03 00 00       	push   $0x34e
f0102fa2:	68 1d 79 10 f0       	push   $0xf010791d
f0102fa7:	e8 e8 d0 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102fac:	68 94 77 10 f0       	push   $0xf0107794
f0102fb1:	68 43 79 10 f0       	push   $0xf0107943
f0102fb6:	68 39 03 00 00       	push   $0x339
f0102fbb:	68 1d 79 10 f0       	push   $0xf010791d
f0102fc0:	e8 cf d0 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fc5:	ff 75 c0             	pushl  -0x40(%ebp)
f0102fc8:	68 6c 68 10 f0       	push   $0xf010686c
f0102fcd:	68 41 03 00 00       	push   $0x341
f0102fd2:	68 1d 79 10 f0       	push   $0xf010791d
f0102fd7:	e8 b8 d0 ff ff       	call   f0100094 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102fdc:	68 bc 77 10 f0       	push   $0xf01077bc
f0102fe1:	68 43 79 10 f0       	push   $0xf0107943
f0102fe6:	68 41 03 00 00       	push   $0x341
f0102feb:	68 1d 79 10 f0       	push   $0xf010791d
f0102ff0:	e8 9f d0 ff ff       	call   f0100094 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102ff5:	68 04 78 10 f0       	push   $0xf0107804
f0102ffa:	68 43 79 10 f0       	push   $0xf0107943
f0102fff:	68 43 03 00 00       	push   $0x343
f0103004:	68 1d 79 10 f0       	push   $0xf010791d
f0103009:	e8 86 d0 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_P);
f010300e:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103011:	f6 c2 01             	test   $0x1,%dl
f0103014:	74 22                	je     f0103038 <mem_init+0x184f>
				assert(pgdir[i] & PTE_W);
f0103016:	f6 c2 02             	test   $0x2,%dl
f0103019:	0f 85 57 ff ff ff    	jne    f0102f76 <mem_init+0x178d>
f010301f:	68 4c 7c 10 f0       	push   $0xf0107c4c
f0103024:	68 43 79 10 f0       	push   $0xf0107943
f0103029:	68 53 03 00 00       	push   $0x353
f010302e:	68 1d 79 10 f0       	push   $0xf010791d
f0103033:	e8 5c d0 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_P);
f0103038:	68 3b 7c 10 f0       	push   $0xf0107c3b
f010303d:	68 43 79 10 f0       	push   $0xf0107943
f0103042:	68 52 03 00 00       	push   $0x352
f0103047:	68 1d 79 10 f0       	push   $0xf010791d
f010304c:	e8 43 d0 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] == 0);
f0103051:	68 5d 7c 10 f0       	push   $0xf0107c5d
f0103056:	68 43 79 10 f0       	push   $0xf0107943
f010305b:	68 55 03 00 00       	push   $0x355
f0103060:	68 1d 79 10 f0       	push   $0xf010791d
f0103065:	e8 2a d0 ff ff       	call   f0100094 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f010306a:	83 ec 0c             	sub    $0xc,%esp
f010306d:	68 28 78 10 f0       	push   $0xf0107828
f0103072:	e8 fe 0e 00 00       	call   f0103f75 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0103077:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f010307c:	83 c4 10             	add    $0x10,%esp
f010307f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103084:	0f 86 fe 01 00 00    	jbe    f0103288 <mem_init+0x1a9f>
	return (physaddr_t)kva - KERNBASE;
f010308a:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010308f:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0103092:	b8 00 00 00 00       	mov    $0x0,%eax
f0103097:	e8 77 df ff ff       	call   f0101013 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f010309c:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010309f:	83 e0 f3             	and    $0xfffffff3,%eax
f01030a2:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01030a7:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01030aa:	83 ec 0c             	sub    $0xc,%esp
f01030ad:	6a 00                	push   $0x0
f01030af:	e8 14 e3 ff ff       	call   f01013c8 <page_alloc>
f01030b4:	89 c3                	mov    %eax,%ebx
f01030b6:	83 c4 10             	add    $0x10,%esp
f01030b9:	85 c0                	test   %eax,%eax
f01030bb:	0f 84 dc 01 00 00    	je     f010329d <mem_init+0x1ab4>
	assert((pp1 = page_alloc(0)));
f01030c1:	83 ec 0c             	sub    $0xc,%esp
f01030c4:	6a 00                	push   $0x0
f01030c6:	e8 fd e2 ff ff       	call   f01013c8 <page_alloc>
f01030cb:	89 c7                	mov    %eax,%edi
f01030cd:	83 c4 10             	add    $0x10,%esp
f01030d0:	85 c0                	test   %eax,%eax
f01030d2:	0f 84 de 01 00 00    	je     f01032b6 <mem_init+0x1acd>
	assert((pp2 = page_alloc(0)));
f01030d8:	83 ec 0c             	sub    $0xc,%esp
f01030db:	6a 00                	push   $0x0
f01030dd:	e8 e6 e2 ff ff       	call   f01013c8 <page_alloc>
f01030e2:	89 c6                	mov    %eax,%esi
f01030e4:	83 c4 10             	add    $0x10,%esp
f01030e7:	85 c0                	test   %eax,%eax
f01030e9:	0f 84 e0 01 00 00    	je     f01032cf <mem_init+0x1ae6>
	page_free(pp0);
f01030ef:	83 ec 0c             	sub    $0xc,%esp
f01030f2:	53                   	push   %ebx
f01030f3:	e8 42 e3 ff ff       	call   f010143a <page_free>
	return (pp - pages) << PGSHIFT;
f01030f8:	89 f8                	mov    %edi,%eax
f01030fa:	2b 05 90 1e 29 f0    	sub    0xf0291e90,%eax
f0103100:	c1 f8 03             	sar    $0x3,%eax
f0103103:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0103106:	89 c2                	mov    %eax,%edx
f0103108:	c1 ea 0c             	shr    $0xc,%edx
f010310b:	83 c4 10             	add    $0x10,%esp
f010310e:	3b 15 88 1e 29 f0    	cmp    0xf0291e88,%edx
f0103114:	0f 83 ce 01 00 00    	jae    f01032e8 <mem_init+0x1aff>
	memset(page2kva(pp1), 1, PGSIZE);
f010311a:	83 ec 04             	sub    $0x4,%esp
f010311d:	68 00 10 00 00       	push   $0x1000
f0103122:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0103124:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103129:	50                   	push   %eax
f010312a:	e8 bf 28 00 00       	call   f01059ee <memset>
	return (pp - pages) << PGSHIFT;
f010312f:	89 f0                	mov    %esi,%eax
f0103131:	2b 05 90 1e 29 f0    	sub    0xf0291e90,%eax
f0103137:	c1 f8 03             	sar    $0x3,%eax
f010313a:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010313d:	89 c2                	mov    %eax,%edx
f010313f:	c1 ea 0c             	shr    $0xc,%edx
f0103142:	83 c4 10             	add    $0x10,%esp
f0103145:	3b 15 88 1e 29 f0    	cmp    0xf0291e88,%edx
f010314b:	0f 83 a9 01 00 00    	jae    f01032fa <mem_init+0x1b11>
	memset(page2kva(pp2), 2, PGSIZE);
f0103151:	83 ec 04             	sub    $0x4,%esp
f0103154:	68 00 10 00 00       	push   $0x1000
f0103159:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f010315b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103160:	50                   	push   %eax
f0103161:	e8 88 28 00 00       	call   f01059ee <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103166:	6a 02                	push   $0x2
f0103168:	68 00 10 00 00       	push   $0x1000
f010316d:	57                   	push   %edi
f010316e:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f0103174:	e8 a8 e5 ff ff       	call   f0101721 <page_insert>
	assert(pp1->pp_ref == 1);
f0103179:	83 c4 20             	add    $0x20,%esp
f010317c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103181:	0f 85 85 01 00 00    	jne    f010330c <mem_init+0x1b23>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103187:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f010318e:	01 01 01 
f0103191:	0f 85 8e 01 00 00    	jne    f0103325 <mem_init+0x1b3c>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0103197:	6a 02                	push   $0x2
f0103199:	68 00 10 00 00       	push   $0x1000
f010319e:	56                   	push   %esi
f010319f:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f01031a5:	e8 77 e5 ff ff       	call   f0101721 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01031aa:	83 c4 10             	add    $0x10,%esp
f01031ad:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01031b4:	02 02 02 
f01031b7:	0f 85 81 01 00 00    	jne    f010333e <mem_init+0x1b55>
	assert(pp2->pp_ref == 1);
f01031bd:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01031c2:	0f 85 8f 01 00 00    	jne    f0103357 <mem_init+0x1b6e>
	assert(pp1->pp_ref == 0);
f01031c8:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01031cd:	0f 85 9d 01 00 00    	jne    f0103370 <mem_init+0x1b87>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01031d3:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01031da:	03 03 03 
	return (pp - pages) << PGSHIFT;
f01031dd:	89 f0                	mov    %esi,%eax
f01031df:	2b 05 90 1e 29 f0    	sub    0xf0291e90,%eax
f01031e5:	c1 f8 03             	sar    $0x3,%eax
f01031e8:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01031eb:	89 c2                	mov    %eax,%edx
f01031ed:	c1 ea 0c             	shr    $0xc,%edx
f01031f0:	3b 15 88 1e 29 f0    	cmp    0xf0291e88,%edx
f01031f6:	0f 83 8d 01 00 00    	jae    f0103389 <mem_init+0x1ba0>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01031fc:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103203:	03 03 03 
f0103206:	0f 85 8f 01 00 00    	jne    f010339b <mem_init+0x1bb2>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010320c:	83 ec 08             	sub    $0x8,%esp
f010320f:	68 00 10 00 00       	push   $0x1000
f0103214:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f010321a:	e8 a8 e4 ff ff       	call   f01016c7 <page_remove>
	assert(pp2->pp_ref == 0);
f010321f:	83 c4 10             	add    $0x10,%esp
f0103222:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0103227:	0f 85 87 01 00 00    	jne    f01033b4 <mem_init+0x1bcb>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010322d:	8b 0d 8c 1e 29 f0    	mov    0xf0291e8c,%ecx
f0103233:	8b 11                	mov    (%ecx),%edx
f0103235:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f010323b:	89 d8                	mov    %ebx,%eax
f010323d:	2b 05 90 1e 29 f0    	sub    0xf0291e90,%eax
f0103243:	c1 f8 03             	sar    $0x3,%eax
f0103246:	c1 e0 0c             	shl    $0xc,%eax
f0103249:	39 c2                	cmp    %eax,%edx
f010324b:	0f 85 7c 01 00 00    	jne    f01033cd <mem_init+0x1be4>
	kern_pgdir[0] = 0;
f0103251:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0103257:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010325c:	0f 85 84 01 00 00    	jne    f01033e6 <mem_init+0x1bfd>
	pp0->pp_ref = 0;
f0103262:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0103268:	83 ec 0c             	sub    $0xc,%esp
f010326b:	53                   	push   %ebx
f010326c:	e8 c9 e1 ff ff       	call   f010143a <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103271:	c7 04 24 bc 78 10 f0 	movl   $0xf01078bc,(%esp)
f0103278:	e8 f8 0c 00 00       	call   f0103f75 <cprintf>
}
f010327d:	83 c4 10             	add    $0x10,%esp
f0103280:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103283:	5b                   	pop    %ebx
f0103284:	5e                   	pop    %esi
f0103285:	5f                   	pop    %edi
f0103286:	5d                   	pop    %ebp
f0103287:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103288:	50                   	push   %eax
f0103289:	68 6c 68 10 f0       	push   $0xf010686c
f010328e:	68 ed 00 00 00       	push   $0xed
f0103293:	68 1d 79 10 f0       	push   $0xf010791d
f0103298:	e8 f7 cd ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f010329d:	68 47 7a 10 f0       	push   $0xf0107a47
f01032a2:	68 43 79 10 f0       	push   $0xf0107943
f01032a7:	68 2d 04 00 00       	push   $0x42d
f01032ac:	68 1d 79 10 f0       	push   $0xf010791d
f01032b1:	e8 de cd ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01032b6:	68 5d 7a 10 f0       	push   $0xf0107a5d
f01032bb:	68 43 79 10 f0       	push   $0xf0107943
f01032c0:	68 2e 04 00 00       	push   $0x42e
f01032c5:	68 1d 79 10 f0       	push   $0xf010791d
f01032ca:	e8 c5 cd ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01032cf:	68 73 7a 10 f0       	push   $0xf0107a73
f01032d4:	68 43 79 10 f0       	push   $0xf0107943
f01032d9:	68 2f 04 00 00       	push   $0x42f
f01032de:	68 1d 79 10 f0       	push   $0xf010791d
f01032e3:	e8 ac cd ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01032e8:	50                   	push   %eax
f01032e9:	68 48 68 10 f0       	push   $0xf0106848
f01032ee:	6a 58                	push   $0x58
f01032f0:	68 29 79 10 f0       	push   $0xf0107929
f01032f5:	e8 9a cd ff ff       	call   f0100094 <_panic>
f01032fa:	50                   	push   %eax
f01032fb:	68 48 68 10 f0       	push   $0xf0106848
f0103300:	6a 58                	push   $0x58
f0103302:	68 29 79 10 f0       	push   $0xf0107929
f0103307:	e8 88 cd ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f010330c:	68 44 7b 10 f0       	push   $0xf0107b44
f0103311:	68 43 79 10 f0       	push   $0xf0107943
f0103316:	68 34 04 00 00       	push   $0x434
f010331b:	68 1d 79 10 f0       	push   $0xf010791d
f0103320:	e8 6f cd ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103325:	68 48 78 10 f0       	push   $0xf0107848
f010332a:	68 43 79 10 f0       	push   $0xf0107943
f010332f:	68 35 04 00 00       	push   $0x435
f0103334:	68 1d 79 10 f0       	push   $0xf010791d
f0103339:	e8 56 cd ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010333e:	68 6c 78 10 f0       	push   $0xf010786c
f0103343:	68 43 79 10 f0       	push   $0xf0107943
f0103348:	68 37 04 00 00       	push   $0x437
f010334d:	68 1d 79 10 f0       	push   $0xf010791d
f0103352:	e8 3d cd ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0103357:	68 66 7b 10 f0       	push   $0xf0107b66
f010335c:	68 43 79 10 f0       	push   $0xf0107943
f0103361:	68 38 04 00 00       	push   $0x438
f0103366:	68 1d 79 10 f0       	push   $0xf010791d
f010336b:	e8 24 cd ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0103370:	68 d0 7b 10 f0       	push   $0xf0107bd0
f0103375:	68 43 79 10 f0       	push   $0xf0107943
f010337a:	68 39 04 00 00       	push   $0x439
f010337f:	68 1d 79 10 f0       	push   $0xf010791d
f0103384:	e8 0b cd ff ff       	call   f0100094 <_panic>
f0103389:	50                   	push   %eax
f010338a:	68 48 68 10 f0       	push   $0xf0106848
f010338f:	6a 58                	push   $0x58
f0103391:	68 29 79 10 f0       	push   $0xf0107929
f0103396:	e8 f9 cc ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010339b:	68 90 78 10 f0       	push   $0xf0107890
f01033a0:	68 43 79 10 f0       	push   $0xf0107943
f01033a5:	68 3b 04 00 00       	push   $0x43b
f01033aa:	68 1d 79 10 f0       	push   $0xf010791d
f01033af:	e8 e0 cc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01033b4:	68 9e 7b 10 f0       	push   $0xf0107b9e
f01033b9:	68 43 79 10 f0       	push   $0xf0107943
f01033be:	68 3d 04 00 00       	push   $0x43d
f01033c3:	68 1d 79 10 f0       	push   $0xf010791d
f01033c8:	e8 c7 cc ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01033cd:	68 18 72 10 f0       	push   $0xf0107218
f01033d2:	68 43 79 10 f0       	push   $0xf0107943
f01033d7:	68 40 04 00 00       	push   $0x440
f01033dc:	68 1d 79 10 f0       	push   $0xf010791d
f01033e1:	e8 ae cc ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f01033e6:	68 55 7b 10 f0       	push   $0xf0107b55
f01033eb:	68 43 79 10 f0       	push   $0xf0107943
f01033f0:	68 42 04 00 00       	push   $0x442
f01033f5:	68 1d 79 10 f0       	push   $0xf010791d
f01033fa:	e8 95 cc ff ff       	call   f0100094 <_panic>

f01033ff <user_mem_check>:
{
f01033ff:	55                   	push   %ebp
f0103400:	89 e5                	mov    %esp,%ebp
f0103402:	57                   	push   %edi
f0103403:	56                   	push   %esi
f0103404:	53                   	push   %ebx
f0103405:	83 ec 1c             	sub    $0x1c,%esp
f0103408:	8b 7d 08             	mov    0x8(%ebp),%edi
	void *l = ROUNDDOWN((void*)va, PGSIZE), *r = ROUNDUP((void*)va + len, PGSIZE);
f010340b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010340e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103411:	89 c3                	mov    %eax,%ebx
f0103413:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0103419:	89 c6                	mov    %eax,%esi
f010341b:	03 75 10             	add    0x10(%ebp),%esi
f010341e:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
f0103424:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for (; l < r; l += PGSIZE) {
f010342a:	eb 1d                	jmp    f0103449 <user_mem_check+0x4a>
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f010342c:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f010342f:	72 03                	jb     f0103434 <user_mem_check+0x35>
		if ((uintptr_t)l >= ULIM) {// Higher than ULIM
f0103431:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f0103434:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103437:	a3 3c 12 29 f0       	mov    %eax,0xf029123c
			return -E_FAULT;
f010343c:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103441:	eb 59                	jmp    f010349c <user_mem_check+0x9d>
	for (; l < r; l += PGSIZE) {
f0103443:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103449:	39 f3                	cmp    %esi,%ebx
f010344b:	73 4a                	jae    f0103497 <user_mem_check+0x98>
		if ((uintptr_t)l >= ULIM) {// Higher than ULIM
f010344d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103450:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0103456:	77 d4                	ja     f010342c <user_mem_check+0x2d>
		pte_t* pte = pgdir_walk(env->env_pgdir, l, 0);
f0103458:	83 ec 04             	sub    $0x4,%esp
f010345b:	6a 00                	push   $0x0
f010345d:	53                   	push   %ebx
f010345e:	ff 77 60             	pushl  0x60(%edi)
f0103461:	e8 4c e0 ff ff       	call   f01014b2 <pgdir_walk>
		if (pte) {
f0103466:	83 c4 10             	add    $0x10,%esp
f0103469:	85 c0                	test   %eax,%eax
f010346b:	74 d6                	je     f0103443 <user_mem_check+0x44>
			uint32_t given_perm = *pte & 0xFFF;
f010346d:	8b 00                	mov    (%eax),%eax
f010346f:	25 ff 0f 00 00       	and    $0xfff,%eax
			if ((given_perm | perm) > given_perm) {
f0103474:	89 c2                	mov    %eax,%edx
f0103476:	0b 55 14             	or     0x14(%ebp),%edx
f0103479:	39 c2                	cmp    %eax,%edx
f010347b:	76 c6                	jbe    f0103443 <user_mem_check+0x44>
				user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f010347d:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0103480:	72 06                	jb     f0103488 <user_mem_check+0x89>
		if ((uintptr_t)l >= ULIM) {// Higher than ULIM
f0103482:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103485:	89 45 e0             	mov    %eax,-0x20(%ebp)
				user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f0103488:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010348b:	a3 3c 12 29 f0       	mov    %eax,0xf029123c
				return -E_FAULT;
f0103490:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103495:	eb 05                	jmp    f010349c <user_mem_check+0x9d>
	return 0;
f0103497:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010349c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010349f:	5b                   	pop    %ebx
f01034a0:	5e                   	pop    %esi
f01034a1:	5f                   	pop    %edi
f01034a2:	5d                   	pop    %ebp
f01034a3:	c3                   	ret    

f01034a4 <user_mem_assert>:
{
f01034a4:	55                   	push   %ebp
f01034a5:	89 e5                	mov    %esp,%ebp
f01034a7:	53                   	push   %ebx
f01034a8:	83 ec 04             	sub    $0x4,%esp
f01034ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01034ae:	8b 45 14             	mov    0x14(%ebp),%eax
f01034b1:	83 c8 04             	or     $0x4,%eax
f01034b4:	50                   	push   %eax
f01034b5:	ff 75 10             	pushl  0x10(%ebp)
f01034b8:	ff 75 0c             	pushl  0xc(%ebp)
f01034bb:	53                   	push   %ebx
f01034bc:	e8 3e ff ff ff       	call   f01033ff <user_mem_check>
f01034c1:	83 c4 10             	add    $0x10,%esp
f01034c4:	85 c0                	test   %eax,%eax
f01034c6:	78 05                	js     f01034cd <user_mem_assert+0x29>
}
f01034c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01034cb:	c9                   	leave  
f01034cc:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f01034cd:	83 ec 04             	sub    $0x4,%esp
f01034d0:	ff 35 3c 12 29 f0    	pushl  0xf029123c
f01034d6:	ff 73 48             	pushl  0x48(%ebx)
f01034d9:	68 e8 78 10 f0       	push   $0xf01078e8
f01034de:	e8 92 0a 00 00       	call   f0103f75 <cprintf>
		env_destroy(env);	// may not return
f01034e3:	89 1c 24             	mov    %ebx,(%esp)
f01034e6:	e8 4e 07 00 00       	call   f0103c39 <env_destroy>
f01034eb:	83 c4 10             	add    $0x10,%esp
}
f01034ee:	eb d8                	jmp    f01034c8 <user_mem_assert+0x24>

f01034f0 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01034f0:	55                   	push   %ebp
f01034f1:	89 e5                	mov    %esp,%ebp
f01034f3:	56                   	push   %esi
f01034f4:	53                   	push   %ebx
f01034f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01034f8:	8b 75 10             	mov    0x10(%ebp),%esi
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01034fb:	85 c0                	test   %eax,%eax
f01034fd:	74 37                	je     f0103536 <envid2env+0x46>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01034ff:	89 c1                	mov    %eax,%ecx
f0103501:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f0103507:	89 ca                	mov    %ecx,%edx
f0103509:	c1 e2 05             	shl    $0x5,%edx
f010350c:	29 ca                	sub    %ecx,%edx
f010350e:	8b 0d 48 12 29 f0    	mov    0xf0291248,%ecx
f0103514:	8d 1c 91             	lea    (%ecx,%edx,4),%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103517:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f010351b:	74 3d                	je     f010355a <envid2env+0x6a>
f010351d:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103520:	75 38                	jne    f010355a <envid2env+0x6a>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103522:	89 f0                	mov    %esi,%eax
f0103524:	84 c0                	test   %al,%al
f0103526:	75 42                	jne    f010356a <envid2env+0x7a>
		*env_store = 0;
		return -E_BAD_ENV;
	}

	*env_store = e;
f0103528:	8b 45 0c             	mov    0xc(%ebp),%eax
f010352b:	89 18                	mov    %ebx,(%eax)
	return 0;
f010352d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103532:	5b                   	pop    %ebx
f0103533:	5e                   	pop    %esi
f0103534:	5d                   	pop    %ebp
f0103535:	c3                   	ret    
		*env_store = curenv;
f0103536:	e8 8b 2b 00 00       	call   f01060c6 <cpunum>
f010353b:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010353e:	01 c2                	add    %eax,%edx
f0103540:	01 d2                	add    %edx,%edx
f0103542:	01 c2                	add    %eax,%edx
f0103544:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103547:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f010354e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103551:	89 06                	mov    %eax,(%esi)
		return 0;
f0103553:	b8 00 00 00 00       	mov    $0x0,%eax
f0103558:	eb d8                	jmp    f0103532 <envid2env+0x42>
		*env_store = 0;
f010355a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010355d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103563:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103568:	eb c8                	jmp    f0103532 <envid2env+0x42>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010356a:	e8 57 2b 00 00       	call   f01060c6 <cpunum>
f010356f:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103572:	01 c2                	add    %eax,%edx
f0103574:	01 d2                	add    %edx,%edx
f0103576:	01 c2                	add    %eax,%edx
f0103578:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010357b:	39 1c 85 28 20 29 f0 	cmp    %ebx,-0xfd6dfd8(,%eax,4)
f0103582:	74 a4                	je     f0103528 <envid2env+0x38>
f0103584:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103587:	e8 3a 2b 00 00       	call   f01060c6 <cpunum>
f010358c:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010358f:	01 c2                	add    %eax,%edx
f0103591:	01 d2                	add    %edx,%edx
f0103593:	01 c2                	add    %eax,%edx
f0103595:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103598:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f010359f:	3b 70 48             	cmp    0x48(%eax),%esi
f01035a2:	74 84                	je     f0103528 <envid2env+0x38>
		*env_store = 0;
f01035a4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035a7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01035ad:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01035b2:	e9 7b ff ff ff       	jmp    f0103532 <envid2env+0x42>

f01035b7 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01035b7:	55                   	push   %ebp
f01035b8:	89 e5                	mov    %esp,%ebp
	asm volatile("lgdt (%0)" : : "r" (p));
f01035ba:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
f01035bf:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01035c2:	b8 23 00 00 00       	mov    $0x23,%eax
f01035c7:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01035c9:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01035cb:	b8 10 00 00 00       	mov    $0x10,%eax
f01035d0:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01035d2:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01035d4:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01035d6:	ea dd 35 10 f0 08 00 	ljmp   $0x8,$0xf01035dd
	asm volatile("lldt %0" : : "r" (sel));
f01035dd:	b8 00 00 00 00       	mov    $0x0,%eax
f01035e2:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01035e5:	5d                   	pop    %ebp
f01035e6:	c3                   	ret    

f01035e7 <env_init>:
{
f01035e7:	55                   	push   %ebp
f01035e8:	89 e5                	mov    %esp,%ebp
f01035ea:	56                   	push   %esi
f01035eb:	53                   	push   %ebx
		envs[i].env_link = env_free_list;
f01035ec:	8b 35 48 12 29 f0    	mov    0xf0291248,%esi
f01035f2:	8b 15 4c 12 29 f0    	mov    0xf029124c,%edx
f01035f8:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f01035fe:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0103601:	89 c1                	mov    %eax,%ecx
f0103603:	89 50 44             	mov    %edx,0x44(%eax)
f0103606:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[i];
f0103609:	89 ca                	mov    %ecx,%edx
	for (int i = NENV - 1; i >= 0; i--) { // Be sure not to use size_t
f010360b:	39 d8                	cmp    %ebx,%eax
f010360d:	75 f2                	jne    f0103601 <env_init+0x1a>
f010360f:	89 35 4c 12 29 f0    	mov    %esi,0xf029124c
	env_init_percpu();
f0103615:	e8 9d ff ff ff       	call   f01035b7 <env_init_percpu>
}
f010361a:	5b                   	pop    %ebx
f010361b:	5e                   	pop    %esi
f010361c:	5d                   	pop    %ebp
f010361d:	c3                   	ret    

f010361e <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010361e:	55                   	push   %ebp
f010361f:	89 e5                	mov    %esp,%ebp
f0103621:	56                   	push   %esi
f0103622:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;
	// cprintf("newenv_store = %p\n", newenv_store);
	if (!(e = env_free_list))
f0103623:	8b 1d 4c 12 29 f0    	mov    0xf029124c,%ebx
f0103629:	85 db                	test   %ebx,%ebx
f010362b:	0f 84 f3 01 00 00    	je     f0103824 <env_alloc+0x206>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103631:	83 ec 0c             	sub    $0xc,%esp
f0103634:	6a 01                	push   $0x1
f0103636:	e8 8d dd ff ff       	call   f01013c8 <page_alloc>
f010363b:	89 c6                	mov    %eax,%esi
f010363d:	83 c4 10             	add    $0x10,%esp
f0103640:	85 c0                	test   %eax,%eax
f0103642:	0f 84 e3 01 00 00    	je     f010382b <env_alloc+0x20d>
	return (pp - pages) << PGSHIFT;
f0103648:	2b 05 90 1e 29 f0    	sub    0xf0291e90,%eax
f010364e:	c1 f8 03             	sar    $0x3,%eax
f0103651:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0103654:	89 c2                	mov    %eax,%edx
f0103656:	c1 ea 0c             	shr    $0xc,%edx
f0103659:	3b 15 88 1e 29 f0    	cmp    0xf0291e88,%edx
f010365f:	0f 83 75 01 00 00    	jae    f01037da <env_alloc+0x1bc>
	memset(page2kva(p), 0, PGSIZE);
f0103665:	83 ec 04             	sub    $0x4,%esp
f0103668:	68 00 10 00 00       	push   $0x1000
f010366d:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f010366f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103674:	50                   	push   %eax
f0103675:	e8 74 23 00 00       	call   f01059ee <memset>
	p->pp_ref++;
f010367a:	66 ff 46 04          	incw   0x4(%esi)
	return (pp - pages) << PGSHIFT;
f010367e:	2b 35 90 1e 29 f0    	sub    0xf0291e90,%esi
f0103684:	c1 fe 03             	sar    $0x3,%esi
f0103687:	c1 e6 0c             	shl    $0xc,%esi
	if (PGNUM(pa) >= npages)
f010368a:	89 f0                	mov    %esi,%eax
f010368c:	c1 e8 0c             	shr    $0xc,%eax
f010368f:	83 c4 10             	add    $0x10,%esp
f0103692:	3b 05 88 1e 29 f0    	cmp    0xf0291e88,%eax
f0103698:	0f 83 4e 01 00 00    	jae    f01037ec <env_alloc+0x1ce>
	return (void *)(pa + KERNBASE);
f010369e:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f01036a4:	89 73 60             	mov    %esi,0x60(%ebx)
	e->env_pgdir = page2kva(p);
f01036a7:	b8 ec 0e 00 00       	mov    $0xeec,%eax
		e->env_pgdir[pgt] = kern_pgdir[pgt];
f01036ac:	8b 15 8c 1e 29 f0    	mov    0xf0291e8c,%edx
f01036b2:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f01036b5:	8b 53 60             	mov    0x60(%ebx),%edx
f01036b8:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f01036bb:	83 c0 04             	add    $0x4,%eax
	for (size_t pgt = PDX(UTOP); pgt < PGSIZE / sizeof(pde_t); pgt++) {
f01036be:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01036c3:	75 e7                	jne    f01036ac <env_alloc+0x8e>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01036c5:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01036c8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036cd:	0f 86 2b 01 00 00    	jbe    f01037fe <env_alloc+0x1e0>
	return (physaddr_t)kva - KERNBASE;
f01036d3:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01036d9:	83 ca 05             	or     $0x5,%edx
f01036dc:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01036e2:	8b 43 48             	mov    0x48(%ebx),%eax
f01036e5:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01036ea:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01036ef:	89 c2                	mov    %eax,%edx
f01036f1:	0f 8e 1c 01 00 00    	jle    f0103813 <env_alloc+0x1f5>
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f01036f7:	89 d8                	mov    %ebx,%eax
f01036f9:	2b 05 48 12 29 f0    	sub    0xf0291248,%eax
f01036ff:	c1 f8 02             	sar    $0x2,%eax
f0103702:	89 c1                	mov    %eax,%ecx
f0103704:	c1 e0 05             	shl    $0x5,%eax
f0103707:	01 c8                	add    %ecx,%eax
f0103709:	c1 e0 05             	shl    $0x5,%eax
f010370c:	01 c8                	add    %ecx,%eax
f010370e:	89 c6                	mov    %eax,%esi
f0103710:	c1 e6 0f             	shl    $0xf,%esi
f0103713:	01 f0                	add    %esi,%eax
f0103715:	c1 e0 05             	shl    $0x5,%eax
f0103718:	01 c8                	add    %ecx,%eax
f010371a:	f7 d8                	neg    %eax
f010371c:	09 d0                	or     %edx,%eax
f010371e:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103721:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103724:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103727:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010372e:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103735:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010373c:	83 ec 04             	sub    $0x4,%esp
f010373f:	6a 44                	push   $0x44
f0103741:	6a 00                	push   $0x0
f0103743:	53                   	push   %ebx
f0103744:	e8 a5 22 00 00       	call   f01059ee <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103749:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010374f:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103755:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010375b:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103762:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103768:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f010376f:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103773:	8b 43 44             	mov    0x44(%ebx),%eax
f0103776:	a3 4c 12 29 f0       	mov    %eax,0xf029124c
	*newenv_store = e;
f010377b:	8b 45 08             	mov    0x8(%ebp),%eax
f010377e:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103780:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103783:	e8 3e 29 00 00       	call   f01060c6 <cpunum>
f0103788:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010378b:	01 c2                	add    %eax,%edx
f010378d:	01 d2                	add    %edx,%edx
f010378f:	01 c2                	add    %eax,%edx
f0103791:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103794:	83 c4 10             	add    $0x10,%esp
f0103797:	83 3c 85 28 20 29 f0 	cmpl   $0x0,-0xfd6dfd8(,%eax,4)
f010379e:	00 
f010379f:	74 7c                	je     f010381d <env_alloc+0x1ff>
f01037a1:	e8 20 29 00 00       	call   f01060c6 <cpunum>
f01037a6:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01037a9:	01 c2                	add    %eax,%edx
f01037ab:	01 d2                	add    %edx,%edx
f01037ad:	01 c2                	add    %eax,%edx
f01037af:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01037b2:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f01037b9:	8b 40 48             	mov    0x48(%eax),%eax
f01037bc:	83 ec 04             	sub    $0x4,%esp
f01037bf:	53                   	push   %ebx
f01037c0:	50                   	push   %eax
f01037c1:	68 be 7c 10 f0       	push   $0xf0107cbe
f01037c6:	e8 aa 07 00 00       	call   f0103f75 <cprintf>
	return 0;
f01037cb:	83 c4 10             	add    $0x10,%esp
f01037ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01037d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01037d6:	5b                   	pop    %ebx
f01037d7:	5e                   	pop    %esi
f01037d8:	5d                   	pop    %ebp
f01037d9:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01037da:	50                   	push   %eax
f01037db:	68 48 68 10 f0       	push   $0xf0106848
f01037e0:	6a 58                	push   $0x58
f01037e2:	68 29 79 10 f0       	push   $0xf0107929
f01037e7:	e8 a8 c8 ff ff       	call   f0100094 <_panic>
f01037ec:	56                   	push   %esi
f01037ed:	68 48 68 10 f0       	push   $0xf0106848
f01037f2:	6a 58                	push   $0x58
f01037f4:	68 29 79 10 f0       	push   $0xf0107929
f01037f9:	e8 96 c8 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037fe:	50                   	push   %eax
f01037ff:	68 6c 68 10 f0       	push   $0xf010686c
f0103804:	68 ca 00 00 00       	push   $0xca
f0103809:	68 b3 7c 10 f0       	push   $0xf0107cb3
f010380e:	e8 81 c8 ff ff       	call   f0100094 <_panic>
		generation = 1 << ENVGENSHIFT;
f0103813:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103818:	e9 da fe ff ff       	jmp    f01036f7 <env_alloc+0xd9>
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010381d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103822:	eb 98                	jmp    f01037bc <env_alloc+0x19e>
		return -E_NO_FREE_ENV;
f0103824:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103829:	eb a8                	jmp    f01037d3 <env_alloc+0x1b5>
		return -E_NO_MEM;
f010382b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103830:	eb a1                	jmp    f01037d3 <env_alloc+0x1b5>

f0103832 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103832:	55                   	push   %ebp
f0103833:	89 e5                	mov    %esp,%ebp
f0103835:	57                   	push   %edi
f0103836:	56                   	push   %esi
f0103837:	53                   	push   %ebx
f0103838:	83 ec 34             	sub    $0x34,%esp
	struct Env* newenv;
	// cprintf("&newenv = %p\n", &newenv);
	// cprintf("env_free_list = %p\n", env_free_list);
	int r = env_alloc(&newenv, 0);
f010383b:	6a 00                	push   $0x0
f010383d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103840:	50                   	push   %eax
f0103841:	e8 d8 fd ff ff       	call   f010361e <env_alloc>
	// cprintf("newenv = %p, envs[0] = %p\n", newenv, envs);
	if (r)
f0103846:	83 c4 10             	add    $0x10,%esp
f0103849:	85 c0                	test   %eax,%eax
f010384b:	75 47                	jne    f0103894 <env_create+0x62>
		panic("Environment allocation faulted: %e", r);
	load_icode(newenv, binary);
f010384d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	if (elf->e_magic != ELF_MAGIC)
f0103850:	8b 45 08             	mov    0x8(%ebp),%eax
f0103853:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f0103859:	75 4e                	jne    f01038a9 <env_create+0x77>
	struct Proghdr *ph = (struct Proghdr *) (binary + elf->e_phoff), 
f010385b:	8b 45 08             	mov    0x8(%ebp),%eax
f010385e:	89 c6                	mov    %eax,%esi
f0103860:	03 70 1c             	add    0x1c(%eax),%esi
				   *eph = ph + elf->e_phnum;
f0103863:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
f0103867:	c1 e0 05             	shl    $0x5,%eax
f010386a:	01 f0                	add    %esi,%eax
f010386c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	pte_t pgdir_pte = *pgdir_walk(kern_pgdir, e->env_pgdir, 0);
f010386f:	83 ec 04             	sub    $0x4,%esp
f0103872:	6a 00                	push   $0x0
f0103874:	ff 77 60             	pushl  0x60(%edi)
f0103877:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f010387d:	e8 30 dc ff ff       	call   f01014b2 <pgdir_walk>
	physaddr_t pgdir_phy = PTE_ADDR(pgdir_pte);
f0103882:	8b 00                	mov    (%eax),%eax
f0103884:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103889:	0f 22 d8             	mov    %eax,%cr3
f010388c:	83 c4 10             	add    $0x10,%esp
f010388f:	e9 df 00 00 00       	jmp    f0103973 <env_create+0x141>
		panic("Environment allocation faulted: %e", r);
f0103894:	50                   	push   %eax
f0103895:	68 6c 7c 10 f0       	push   $0xf0107c6c
f010389a:	68 a6 01 00 00       	push   $0x1a6
f010389f:	68 b3 7c 10 f0       	push   $0xf0107cb3
f01038a4:	e8 eb c7 ff ff       	call   f0100094 <_panic>
		panic("Not a valid elf binary!");
f01038a9:	83 ec 04             	sub    $0x4,%esp
f01038ac:	68 d3 7c 10 f0       	push   $0xf0107cd3
f01038b1:	68 68 01 00 00       	push   $0x168
f01038b6:	68 b3 7c 10 f0       	push   $0xf0107cb3
f01038bb:	e8 d4 c7 ff ff       	call   f0100094 <_panic>
			region_alloc(e, (void*)ph0->p_va, ph0->p_memsz);
f01038c0:	8b 46 08             	mov    0x8(%esi),%eax
	uintptr_t l = ROUNDDOWN((uintptr_t)va, PGSIZE), 
f01038c3:	89 c3                	mov    %eax,%ebx
f01038c5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
			  r = ROUNDUP((uintptr_t)(va + len), PGSIZE);
f01038cb:	03 46 14             	add    0x14(%esi),%eax
f01038ce:	05 ff 0f 00 00       	add    $0xfff,%eax
f01038d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01038d8:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01038db:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01038de:	89 c6                	mov    %eax,%esi
	for (uintptr_t ptr = l; ptr < r; ptr += PGSIZE) {
f01038e0:	39 de                	cmp    %ebx,%esi
f01038e2:	76 5a                	jbe    f010393e <env_create+0x10c>
		struct PageInfo *pg = page_alloc(0);
f01038e4:	83 ec 0c             	sub    $0xc,%esp
f01038e7:	6a 00                	push   $0x0
f01038e9:	e8 da da ff ff       	call   f01013c8 <page_alloc>
		if (!pg)
f01038ee:	83 c4 10             	add    $0x10,%esp
f01038f1:	85 c0                	test   %eax,%eax
f01038f3:	74 1b                	je     f0103910 <env_create+0xde>
		int res = page_insert(e->env_pgdir, pg, (void*)ptr, PTE_U | PTE_W);
f01038f5:	6a 06                	push   $0x6
f01038f7:	53                   	push   %ebx
f01038f8:	50                   	push   %eax
f01038f9:	ff 77 60             	pushl  0x60(%edi)
f01038fc:	e8 20 de ff ff       	call   f0101721 <page_insert>
		if (res)
f0103901:	83 c4 10             	add    $0x10,%esp
f0103904:	85 c0                	test   %eax,%eax
f0103906:	75 1f                	jne    f0103927 <env_create+0xf5>
	for (uintptr_t ptr = l; ptr < r; ptr += PGSIZE) {
f0103908:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010390e:	eb d0                	jmp    f01038e0 <env_create+0xae>
			panic("No free page for allocation.");
f0103910:	83 ec 04             	sub    $0x4,%esp
f0103913:	68 eb 7c 10 f0       	push   $0xf0107ceb
f0103918:	68 26 01 00 00       	push   $0x126
f010391d:	68 b3 7c 10 f0       	push   $0xf0107cb3
f0103922:	e8 6d c7 ff ff       	call   f0100094 <_panic>
			panic("Page insertion result: %e", r);
f0103927:	ff 75 cc             	pushl  -0x34(%ebp)
f010392a:	68 08 7d 10 f0       	push   $0xf0107d08
f010392f:	68 29 01 00 00       	push   $0x129
f0103934:	68 b3 7c 10 f0       	push   $0xf0107cb3
f0103939:	e8 56 c7 ff ff       	call   f0100094 <_panic>
f010393e:	8b 75 d0             	mov    -0x30(%ebp),%esi
			memcpy((void*)ph0->p_va, binary + ph0->p_offset, ph0->p_filesz);
f0103941:	83 ec 04             	sub    $0x4,%esp
f0103944:	ff 76 10             	pushl  0x10(%esi)
f0103947:	8b 45 08             	mov    0x8(%ebp),%eax
f010394a:	03 46 04             	add    0x4(%esi),%eax
f010394d:	50                   	push   %eax
f010394e:	ff 76 08             	pushl  0x8(%esi)
f0103951:	e8 4b 21 00 00       	call   f0105aa1 <memcpy>
					ph0->p_memsz - ph0->p_filesz);
f0103956:	8b 46 10             	mov    0x10(%esi),%eax
			memset((void*)ph0->p_va + ph0->p_filesz, 0, 
f0103959:	83 c4 0c             	add    $0xc,%esp
f010395c:	8b 56 14             	mov    0x14(%esi),%edx
f010395f:	29 c2                	sub    %eax,%edx
f0103961:	52                   	push   %edx
f0103962:	6a 00                	push   $0x0
f0103964:	03 46 08             	add    0x8(%esi),%eax
f0103967:	50                   	push   %eax
f0103968:	e8 81 20 00 00       	call   f01059ee <memset>
f010396d:	83 c4 10             	add    $0x10,%esp
	for (struct Proghdr* ph0 = ph; ph0 < eph; ph0++) {
f0103970:	83 c6 20             	add    $0x20,%esi
f0103973:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0103976:	76 1e                	jbe    f0103996 <env_create+0x164>
		if (ph0->p_type == ELF_PROG_LOAD) {
f0103978:	83 3e 01             	cmpl   $0x1,(%esi)
f010397b:	0f 84 3f ff ff ff    	je     f01038c0 <env_create+0x8e>
			cprintf("Found a ph with type %d; skipping\n", ph0->p_filesz);
f0103981:	83 ec 08             	sub    $0x8,%esp
f0103984:	ff 76 10             	pushl  0x10(%esi)
f0103987:	68 90 7c 10 f0       	push   $0xf0107c90
f010398c:	e8 e4 05 00 00       	call   f0103f75 <cprintf>
f0103991:	83 c4 10             	add    $0x10,%esp
f0103994:	eb da                	jmp    f0103970 <env_create+0x13e>
	e->env_tf.tf_eip = elf->e_entry;
f0103996:	8b 45 08             	mov    0x8(%ebp),%eax
f0103999:	8b 40 18             	mov    0x18(%eax),%eax
f010399c:	89 47 30             	mov    %eax,0x30(%edi)
	e->env_tf.tf_eflags = 0;
f010399f:	c7 47 38 00 00 00 00 	movl   $0x0,0x38(%edi)
	lcr3(PADDR(kern_pgdir));
f01039a6:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01039ab:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039b0:	76 38                	jbe    f01039ea <env_create+0x1b8>
	return (physaddr_t)kva - KERNBASE;
f01039b2:	05 00 00 00 10       	add    $0x10000000,%eax
f01039b7:	0f 22 d8             	mov    %eax,%cr3
	struct PageInfo *stack_page = page_alloc(ALLOC_ZERO);
f01039ba:	83 ec 0c             	sub    $0xc,%esp
f01039bd:	6a 01                	push   $0x1
f01039bf:	e8 04 da ff ff       	call   f01013c8 <page_alloc>
	if (!stack_page)
f01039c4:	83 c4 10             	add    $0x10,%esp
f01039c7:	85 c0                	test   %eax,%eax
f01039c9:	74 34                	je     f01039ff <env_create+0x1cd>
	int r = page_insert(e->env_pgdir, stack_page, (void*)USTACKTOP - PGSIZE, PTE_U | PTE_W);
f01039cb:	6a 06                	push   $0x6
f01039cd:	68 00 d0 bf ee       	push   $0xeebfd000
f01039d2:	50                   	push   %eax
f01039d3:	ff 77 60             	pushl  0x60(%edi)
f01039d6:	e8 46 dd ff ff       	call   f0101721 <page_insert>
	if (r)
f01039db:	83 c4 10             	add    $0x10,%esp
f01039de:	85 c0                	test   %eax,%eax
f01039e0:	75 34                	jne    f0103a16 <env_create+0x1e4>
}
f01039e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01039e5:	5b                   	pop    %ebx
f01039e6:	5e                   	pop    %esi
f01039e7:	5f                   	pop    %edi
f01039e8:	5d                   	pop    %ebp
f01039e9:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039ea:	50                   	push   %eax
f01039eb:	68 6c 68 10 f0       	push   $0xf010686c
f01039f0:	68 88 01 00 00       	push   $0x188
f01039f5:	68 b3 7c 10 f0       	push   $0xf0107cb3
f01039fa:	e8 95 c6 ff ff       	call   f0100094 <_panic>
		panic("No free page for allocation.");
f01039ff:	83 ec 04             	sub    $0x4,%esp
f0103a02:	68 eb 7c 10 f0       	push   $0xf0107ceb
f0103a07:	68 90 01 00 00       	push   $0x190
f0103a0c:	68 b3 7c 10 f0       	push   $0xf0107cb3
f0103a11:	e8 7e c6 ff ff       	call   f0100094 <_panic>
		panic("Page insertion result: %e", r);
f0103a16:	50                   	push   %eax
f0103a17:	68 08 7d 10 f0       	push   $0xf0107d08
f0103a1c:	68 93 01 00 00       	push   $0x193
f0103a21:	68 b3 7c 10 f0       	push   $0xf0107cb3
f0103a26:	e8 69 c6 ff ff       	call   f0100094 <_panic>

f0103a2b <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103a2b:	55                   	push   %ebp
f0103a2c:	89 e5                	mov    %esp,%ebp
f0103a2e:	57                   	push   %edi
f0103a2f:	56                   	push   %esi
f0103a30:	53                   	push   %ebx
f0103a31:	83 ec 1c             	sub    $0x1c,%esp
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103a34:	e8 8d 26 00 00       	call   f01060c6 <cpunum>
f0103a39:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103a3c:	01 c2                	add    %eax,%edx
f0103a3e:	01 d2                	add    %edx,%edx
f0103a40:	01 c2                	add    %eax,%edx
f0103a42:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a45:	8b 55 08             	mov    0x8(%ebp),%edx
f0103a48:	39 14 85 28 20 29 f0 	cmp    %edx,-0xfd6dfd8(,%eax,4)
f0103a4f:	75 14                	jne    f0103a65 <env_free+0x3a>
		lcr3(PADDR(kern_pgdir));
f0103a51:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103a56:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a5b:	76 65                	jbe    f0103ac2 <env_free+0x97>
	return (physaddr_t)kva - KERNBASE;
f0103a5d:	05 00 00 00 10       	add    $0x10000000,%eax
f0103a62:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103a65:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a68:	8b 58 48             	mov    0x48(%eax),%ebx
f0103a6b:	e8 56 26 00 00       	call   f01060c6 <cpunum>
f0103a70:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103a73:	01 c2                	add    %eax,%edx
f0103a75:	01 d2                	add    %edx,%edx
f0103a77:	01 c2                	add    %eax,%edx
f0103a79:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a7c:	83 3c 85 28 20 29 f0 	cmpl   $0x0,-0xfd6dfd8(,%eax,4)
f0103a83:	00 
f0103a84:	74 51                	je     f0103ad7 <env_free+0xac>
f0103a86:	e8 3b 26 00 00       	call   f01060c6 <cpunum>
f0103a8b:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103a8e:	01 c2                	add    %eax,%edx
f0103a90:	01 d2                	add    %edx,%edx
f0103a92:	01 c2                	add    %eax,%edx
f0103a94:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a97:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f0103a9e:	8b 40 48             	mov    0x48(%eax),%eax
f0103aa1:	83 ec 04             	sub    $0x4,%esp
f0103aa4:	53                   	push   %ebx
f0103aa5:	50                   	push   %eax
f0103aa6:	68 22 7d 10 f0       	push   $0xf0107d22
f0103aab:	e8 c5 04 00 00       	call   f0103f75 <cprintf>
f0103ab0:	83 c4 10             	add    $0x10,%esp
f0103ab3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0103aba:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103abd:	e9 96 00 00 00       	jmp    f0103b58 <env_free+0x12d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ac2:	50                   	push   %eax
f0103ac3:	68 6c 68 10 f0       	push   $0xf010686c
f0103ac8:	68 b8 01 00 00       	push   $0x1b8
f0103acd:	68 b3 7c 10 f0       	push   $0xf0107cb3
f0103ad2:	e8 bd c5 ff ff       	call   f0100094 <_panic>
f0103ad7:	b8 00 00 00 00       	mov    $0x0,%eax
f0103adc:	eb c3                	jmp    f0103aa1 <env_free+0x76>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103ade:	50                   	push   %eax
f0103adf:	68 48 68 10 f0       	push   $0xf0106848
f0103ae4:	68 c7 01 00 00       	push   $0x1c7
f0103ae9:	68 b3 7c 10 f0       	push   $0xf0107cb3
f0103aee:	e8 a1 c5 ff ff       	call   f0100094 <_panic>
f0103af3:	83 c3 04             	add    $0x4,%ebx
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103af6:	39 f3                	cmp    %esi,%ebx
f0103af8:	74 21                	je     f0103b1b <env_free+0xf0>
			if (pt[pteno] & PTE_P)
f0103afa:	f6 03 01             	testb  $0x1,(%ebx)
f0103afd:	74 f4                	je     f0103af3 <env_free+0xc8>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103aff:	83 ec 08             	sub    $0x8,%esp
f0103b02:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b05:	01 d8                	add    %ebx,%eax
f0103b07:	c1 e0 0a             	shl    $0xa,%eax
f0103b0a:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103b0d:	50                   	push   %eax
f0103b0e:	ff 77 60             	pushl  0x60(%edi)
f0103b11:	e8 b1 db ff ff       	call   f01016c7 <page_remove>
f0103b16:	83 c4 10             	add    $0x10,%esp
f0103b19:	eb d8                	jmp    f0103af3 <env_free+0xc8>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103b1b:	8b 47 60             	mov    0x60(%edi),%eax
f0103b1e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b21:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103b28:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103b2b:	3b 05 88 1e 29 f0    	cmp    0xf0291e88,%eax
f0103b31:	73 6a                	jae    f0103b9d <env_free+0x172>
		page_decref(pa2page(pa));
f0103b33:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103b36:	a1 90 1e 29 f0       	mov    0xf0291e90,%eax
f0103b3b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103b3e:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103b41:	50                   	push   %eax
f0103b42:	e8 45 d9 ff ff       	call   f010148c <page_decref>
f0103b47:	83 c4 10             	add    $0x10,%esp
f0103b4a:	83 45 dc 04          	addl   $0x4,-0x24(%ebp)
f0103b4e:	8b 45 dc             	mov    -0x24(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103b51:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103b56:	74 59                	je     f0103bb1 <env_free+0x186>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103b58:	8b 47 60             	mov    0x60(%edi),%eax
f0103b5b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b5e:	8b 04 10             	mov    (%eax,%edx,1),%eax
f0103b61:	a8 01                	test   $0x1,%al
f0103b63:	74 e5                	je     f0103b4a <env_free+0x11f>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103b65:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0103b6a:	89 c2                	mov    %eax,%edx
f0103b6c:	c1 ea 0c             	shr    $0xc,%edx
f0103b6f:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0103b72:	39 15 88 1e 29 f0    	cmp    %edx,0xf0291e88
f0103b78:	0f 86 60 ff ff ff    	jbe    f0103ade <env_free+0xb3>
	return (void *)(pa + KERNBASE);
f0103b7e:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b84:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b87:	c1 e2 14             	shl    $0x14,%edx
f0103b8a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103b8d:	8d b0 00 10 00 f0    	lea    -0xffff000(%eax),%esi
f0103b93:	f7 d8                	neg    %eax
f0103b95:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103b98:	e9 5d ff ff ff       	jmp    f0103afa <env_free+0xcf>
		panic("pa2page called with invalid pa");
f0103b9d:	83 ec 04             	sub    $0x4,%esp
f0103ba0:	68 e4 70 10 f0       	push   $0xf01070e4
f0103ba5:	6a 51                	push   $0x51
f0103ba7:	68 29 79 10 f0       	push   $0xf0107929
f0103bac:	e8 e3 c4 ff ff       	call   f0100094 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103bb1:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bb4:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103bb7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103bbc:	76 52                	jbe    f0103c10 <env_free+0x1e5>
	e->env_pgdir = 0;
f0103bbe:	8b 55 08             	mov    0x8(%ebp),%edx
f0103bc1:	c7 42 60 00 00 00 00 	movl   $0x0,0x60(%edx)
	return (physaddr_t)kva - KERNBASE;
f0103bc8:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103bcd:	c1 e8 0c             	shr    $0xc,%eax
f0103bd0:	3b 05 88 1e 29 f0    	cmp    0xf0291e88,%eax
f0103bd6:	73 4d                	jae    f0103c25 <env_free+0x1fa>
	page_decref(pa2page(pa));
f0103bd8:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103bdb:	8b 15 90 1e 29 f0    	mov    0xf0291e90,%edx
f0103be1:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103be4:	50                   	push   %eax
f0103be5:	e8 a2 d8 ff ff       	call   f010148c <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103bea:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bed:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f0103bf4:	a1 4c 12 29 f0       	mov    0xf029124c,%eax
f0103bf9:	8b 55 08             	mov    0x8(%ebp),%edx
f0103bfc:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f0103bff:	89 15 4c 12 29 f0    	mov    %edx,0xf029124c
}
f0103c05:	83 c4 10             	add    $0x10,%esp
f0103c08:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103c0b:	5b                   	pop    %ebx
f0103c0c:	5e                   	pop    %esi
f0103c0d:	5f                   	pop    %edi
f0103c0e:	5d                   	pop    %ebp
f0103c0f:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103c10:	50                   	push   %eax
f0103c11:	68 6c 68 10 f0       	push   $0xf010686c
f0103c16:	68 d5 01 00 00       	push   $0x1d5
f0103c1b:	68 b3 7c 10 f0       	push   $0xf0107cb3
f0103c20:	e8 6f c4 ff ff       	call   f0100094 <_panic>
		panic("pa2page called with invalid pa");
f0103c25:	83 ec 04             	sub    $0x4,%esp
f0103c28:	68 e4 70 10 f0       	push   $0xf01070e4
f0103c2d:	6a 51                	push   $0x51
f0103c2f:	68 29 79 10 f0       	push   $0xf0107929
f0103c34:	e8 5b c4 ff ff       	call   f0100094 <_panic>

f0103c39 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103c39:	55                   	push   %ebp
f0103c3a:	89 e5                	mov    %esp,%ebp
f0103c3c:	53                   	push   %ebx
f0103c3d:	83 ec 04             	sub    $0x4,%esp
f0103c40:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103c43:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103c47:	74 2b                	je     f0103c74 <env_destroy+0x3b>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f0103c49:	83 ec 0c             	sub    $0xc,%esp
f0103c4c:	53                   	push   %ebx
f0103c4d:	e8 d9 fd ff ff       	call   f0103a2b <env_free>

	if (curenv == e) {
f0103c52:	e8 6f 24 00 00       	call   f01060c6 <cpunum>
f0103c57:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103c5a:	01 c2                	add    %eax,%edx
f0103c5c:	01 d2                	add    %edx,%edx
f0103c5e:	01 c2                	add    %eax,%edx
f0103c60:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c63:	83 c4 10             	add    $0x10,%esp
f0103c66:	39 1c 85 28 20 29 f0 	cmp    %ebx,-0xfd6dfd8(,%eax,4)
f0103c6d:	74 28                	je     f0103c97 <env_destroy+0x5e>
		curenv = NULL;
		sched_yield();
	}
}
f0103c6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103c72:	c9                   	leave  
f0103c73:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103c74:	e8 4d 24 00 00       	call   f01060c6 <cpunum>
f0103c79:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103c7c:	01 c2                	add    %eax,%edx
f0103c7e:	01 d2                	add    %edx,%edx
f0103c80:	01 c2                	add    %eax,%edx
f0103c82:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c85:	39 1c 85 28 20 29 f0 	cmp    %ebx,-0xfd6dfd8(,%eax,4)
f0103c8c:	74 bb                	je     f0103c49 <env_destroy+0x10>
		e->env_status = ENV_DYING;
f0103c8e:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103c95:	eb d8                	jmp    f0103c6f <env_destroy+0x36>
		curenv = NULL;
f0103c97:	e8 2a 24 00 00       	call   f01060c6 <cpunum>
f0103c9c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c9f:	c7 80 28 20 29 f0 00 	movl   $0x0,-0xfd6dfd8(%eax)
f0103ca6:	00 00 00 
		sched_yield();
f0103ca9:	e8 37 0d 00 00       	call   f01049e5 <sched_yield>

f0103cae <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103cae:	55                   	push   %ebp
f0103caf:	89 e5                	mov    %esp,%ebp
f0103cb1:	53                   	push   %ebx
f0103cb2:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103cb5:	e8 0c 24 00 00       	call   f01060c6 <cpunum>
f0103cba:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103cbd:	01 c2                	add    %eax,%edx
f0103cbf:	01 d2                	add    %edx,%edx
f0103cc1:	01 c2                	add    %eax,%edx
f0103cc3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103cc6:	8b 1c 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%ebx
f0103ccd:	e8 f4 23 00 00       	call   f01060c6 <cpunum>
f0103cd2:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0103cd5:	8b 65 08             	mov    0x8(%ebp),%esp
f0103cd8:	61                   	popa   
f0103cd9:	07                   	pop    %es
f0103cda:	1f                   	pop    %ds
f0103cdb:	83 c4 08             	add    $0x8,%esp
f0103cde:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103cdf:	83 ec 04             	sub    $0x4,%esp
f0103ce2:	68 38 7d 10 f0       	push   $0xf0107d38
f0103ce7:	68 0c 02 00 00       	push   $0x20c
f0103cec:	68 b3 7c 10 f0       	push   $0xf0107cb3
f0103cf1:	e8 9e c3 ff ff       	call   f0100094 <_panic>

f0103cf6 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103cf6:	55                   	push   %ebp
f0103cf7:	89 e5                	mov    %esp,%ebp
f0103cf9:	83 ec 08             	sub    $0x8,%esp
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// Unset curenv running before going to new env.
	if (curenv && curenv->env_status == ENV_RUNNING) {
f0103cfc:	e8 c5 23 00 00       	call   f01060c6 <cpunum>
f0103d01:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103d04:	01 c2                	add    %eax,%edx
f0103d06:	01 d2                	add    %edx,%edx
f0103d08:	01 c2                	add    %eax,%edx
f0103d0a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d0d:	83 3c 85 28 20 29 f0 	cmpl   $0x0,-0xfd6dfd8(,%eax,4)
f0103d14:	00 
f0103d15:	74 18                	je     f0103d2f <env_run+0x39>
f0103d17:	e8 aa 23 00 00       	call   f01060c6 <cpunum>
f0103d1c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d1f:	8b 80 28 20 29 f0    	mov    -0xfd6dfd8(%eax),%eax
f0103d25:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103d29:	0f 84 8c 00 00 00    	je     f0103dbb <env_run+0xc5>
		curenv->env_status = ENV_RUNNABLE;
	}

	curenv = e;
f0103d2f:	e8 92 23 00 00       	call   f01060c6 <cpunum>
f0103d34:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103d37:	01 c2                	add    %eax,%edx
f0103d39:	01 d2                	add    %edx,%edx
f0103d3b:	01 c2                	add    %eax,%edx
f0103d3d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d40:	8b 55 08             	mov    0x8(%ebp),%edx
f0103d43:	89 14 85 28 20 29 f0 	mov    %edx,-0xfd6dfd8(,%eax,4)
	curenv->env_status = ENV_RUNNING;
f0103d4a:	e8 77 23 00 00       	call   f01060c6 <cpunum>
f0103d4f:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103d52:	01 c2                	add    %eax,%edx
f0103d54:	01 d2                	add    %edx,%edx
f0103d56:	01 c2                	add    %eax,%edx
f0103d58:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d5b:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f0103d62:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++; // Incremetn run count
f0103d69:	e8 58 23 00 00       	call   f01060c6 <cpunum>
f0103d6e:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103d71:	01 c2                	add    %eax,%edx
f0103d73:	01 d2                	add    %edx,%edx
f0103d75:	01 c2                	add    %eax,%edx
f0103d77:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d7a:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f0103d81:	ff 40 58             	incl   0x58(%eax)

	// Jump to user env pgdir
	lcr3(PADDR(curenv->env_pgdir));
f0103d84:	e8 3d 23 00 00       	call   f01060c6 <cpunum>
f0103d89:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103d8c:	01 c2                	add    %eax,%edx
f0103d8e:	01 d2                	add    %edx,%edx
f0103d90:	01 c2                	add    %eax,%edx
f0103d92:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d95:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f0103d9c:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103d9f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103da4:	77 2f                	ja     f0103dd5 <env_run+0xdf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103da6:	50                   	push   %eax
f0103da7:	68 6c 68 10 f0       	push   $0xf010686c
f0103dac:	68 33 02 00 00       	push   $0x233
f0103db1:	68 b3 7c 10 f0       	push   $0xf0107cb3
f0103db6:	e8 d9 c2 ff ff       	call   f0100094 <_panic>
		curenv->env_status = ENV_RUNNABLE;
f0103dbb:	e8 06 23 00 00       	call   f01060c6 <cpunum>
f0103dc0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dc3:	8b 80 28 20 29 f0    	mov    -0xfd6dfd8(%eax),%eax
f0103dc9:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0103dd0:	e9 5a ff ff ff       	jmp    f0103d2f <env_run+0x39>
	return (physaddr_t)kva - KERNBASE;
f0103dd5:	05 00 00 00 10       	add    $0x10000000,%eax
f0103dda:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103ddd:	83 ec 0c             	sub    $0xc,%esp
f0103de0:	68 c0 23 12 f0       	push   $0xf01223c0
f0103de5:	e8 fd 25 00 00       	call   f01063e7 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103dea:	f3 90                	pause  
	
	// Unlock the kernel if we're heading user mode.
	unlock_kernel();

	// Do the final work.
	env_pop_tf(&curenv->env_tf);  // Does not return.
f0103dec:	e8 d5 22 00 00       	call   f01060c6 <cpunum>
f0103df1:	83 c4 04             	add    $0x4,%esp
f0103df4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103df7:	ff b0 28 20 29 f0    	pushl  -0xfd6dfd8(%eax)
f0103dfd:	e8 ac fe ff ff       	call   f0103cae <env_pop_tf>

f0103e02 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103e02:	55                   	push   %ebp
f0103e03:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e05:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e08:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e0d:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103e0e:	ba 71 00 00 00       	mov    $0x71,%edx
f0103e13:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103e14:	0f b6 c0             	movzbl %al,%eax
}
f0103e17:	5d                   	pop    %ebp
f0103e18:	c3                   	ret    

f0103e19 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103e19:	55                   	push   %ebp
f0103e1a:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e1c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e1f:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e24:	ee                   	out    %al,(%dx)
f0103e25:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e28:	ba 71 00 00 00       	mov    $0x71,%edx
f0103e2d:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103e2e:	5d                   	pop    %ebp
f0103e2f:	c3                   	ret    

f0103e30 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103e30:	55                   	push   %ebp
f0103e31:	89 e5                	mov    %esp,%ebp
f0103e33:	56                   	push   %esi
f0103e34:	53                   	push   %ebx
f0103e35:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103e38:	66 a3 a8 23 12 f0    	mov    %ax,0xf01223a8
	if (!didinit)
f0103e3e:	80 3d 50 12 29 f0 00 	cmpb   $0x0,0xf0291250
f0103e45:	75 07                	jne    f0103e4e <irq_setmask_8259A+0x1e>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f0103e47:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103e4a:	5b                   	pop    %ebx
f0103e4b:	5e                   	pop    %esi
f0103e4c:	5d                   	pop    %ebp
f0103e4d:	c3                   	ret    
f0103e4e:	89 c6                	mov    %eax,%esi
f0103e50:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e55:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103e56:	66 c1 e8 08          	shr    $0x8,%ax
f0103e5a:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103e5f:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103e60:	83 ec 0c             	sub    $0xc,%esp
f0103e63:	68 44 7d 10 f0       	push   $0xf0107d44
f0103e68:	e8 08 01 00 00       	call   f0103f75 <cprintf>
f0103e6d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103e70:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103e75:	0f b7 f6             	movzwl %si,%esi
f0103e78:	f7 d6                	not    %esi
f0103e7a:	eb 06                	jmp    f0103e82 <irq_setmask_8259A+0x52>
	for (i = 0; i < 16; i++)
f0103e7c:	43                   	inc    %ebx
f0103e7d:	83 fb 10             	cmp    $0x10,%ebx
f0103e80:	74 1d                	je     f0103e9f <irq_setmask_8259A+0x6f>
		if (~mask & (1<<i))
f0103e82:	89 f0                	mov    %esi,%eax
f0103e84:	88 d9                	mov    %bl,%cl
f0103e86:	d3 f8                	sar    %cl,%eax
f0103e88:	a8 01                	test   $0x1,%al
f0103e8a:	74 f0                	je     f0103e7c <irq_setmask_8259A+0x4c>
			cprintf(" %d", i);
f0103e8c:	83 ec 08             	sub    $0x8,%esp
f0103e8f:	53                   	push   %ebx
f0103e90:	68 13 82 10 f0       	push   $0xf0108213
f0103e95:	e8 db 00 00 00       	call   f0103f75 <cprintf>
f0103e9a:	83 c4 10             	add    $0x10,%esp
f0103e9d:	eb dd                	jmp    f0103e7c <irq_setmask_8259A+0x4c>
	cprintf("\n");
f0103e9f:	83 ec 0c             	sub    $0xc,%esp
f0103ea2:	68 9b 6b 10 f0       	push   $0xf0106b9b
f0103ea7:	e8 c9 00 00 00       	call   f0103f75 <cprintf>
f0103eac:	83 c4 10             	add    $0x10,%esp
f0103eaf:	eb 96                	jmp    f0103e47 <irq_setmask_8259A+0x17>

f0103eb1 <pic_init>:
{
f0103eb1:	55                   	push   %ebp
f0103eb2:	89 e5                	mov    %esp,%ebp
f0103eb4:	57                   	push   %edi
f0103eb5:	56                   	push   %esi
f0103eb6:	53                   	push   %ebx
f0103eb7:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f0103eba:	c6 05 50 12 29 f0 01 	movb   $0x1,0xf0291250
f0103ec1:	b0 ff                	mov    $0xff,%al
f0103ec3:	bb 21 00 00 00       	mov    $0x21,%ebx
f0103ec8:	89 da                	mov    %ebx,%edx
f0103eca:	ee                   	out    %al,(%dx)
f0103ecb:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f0103ed0:	89 ca                	mov    %ecx,%edx
f0103ed2:	ee                   	out    %al,(%dx)
f0103ed3:	bf 11 00 00 00       	mov    $0x11,%edi
f0103ed8:	be 20 00 00 00       	mov    $0x20,%esi
f0103edd:	89 f8                	mov    %edi,%eax
f0103edf:	89 f2                	mov    %esi,%edx
f0103ee1:	ee                   	out    %al,(%dx)
f0103ee2:	b0 20                	mov    $0x20,%al
f0103ee4:	89 da                	mov    %ebx,%edx
f0103ee6:	ee                   	out    %al,(%dx)
f0103ee7:	b0 04                	mov    $0x4,%al
f0103ee9:	ee                   	out    %al,(%dx)
f0103eea:	b0 03                	mov    $0x3,%al
f0103eec:	ee                   	out    %al,(%dx)
f0103eed:	bb a0 00 00 00       	mov    $0xa0,%ebx
f0103ef2:	89 f8                	mov    %edi,%eax
f0103ef4:	89 da                	mov    %ebx,%edx
f0103ef6:	ee                   	out    %al,(%dx)
f0103ef7:	b0 28                	mov    $0x28,%al
f0103ef9:	89 ca                	mov    %ecx,%edx
f0103efb:	ee                   	out    %al,(%dx)
f0103efc:	b0 02                	mov    $0x2,%al
f0103efe:	ee                   	out    %al,(%dx)
f0103eff:	b0 01                	mov    $0x1,%al
f0103f01:	ee                   	out    %al,(%dx)
f0103f02:	bf 68 00 00 00       	mov    $0x68,%edi
f0103f07:	89 f8                	mov    %edi,%eax
f0103f09:	89 f2                	mov    %esi,%edx
f0103f0b:	ee                   	out    %al,(%dx)
f0103f0c:	b1 0a                	mov    $0xa,%cl
f0103f0e:	88 c8                	mov    %cl,%al
f0103f10:	ee                   	out    %al,(%dx)
f0103f11:	89 f8                	mov    %edi,%eax
f0103f13:	89 da                	mov    %ebx,%edx
f0103f15:	ee                   	out    %al,(%dx)
f0103f16:	88 c8                	mov    %cl,%al
f0103f18:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103f19:	66 a1 a8 23 12 f0    	mov    0xf01223a8,%ax
f0103f1f:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103f23:	74 0f                	je     f0103f34 <pic_init+0x83>
		irq_setmask_8259A(irq_mask_8259A);
f0103f25:	83 ec 0c             	sub    $0xc,%esp
f0103f28:	0f b7 c0             	movzwl %ax,%eax
f0103f2b:	50                   	push   %eax
f0103f2c:	e8 ff fe ff ff       	call   f0103e30 <irq_setmask_8259A>
f0103f31:	83 c4 10             	add    $0x10,%esp
}
f0103f34:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f37:	5b                   	pop    %ebx
f0103f38:	5e                   	pop    %esi
f0103f39:	5f                   	pop    %edi
f0103f3a:	5d                   	pop    %ebp
f0103f3b:	c3                   	ret    

f0103f3c <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103f3c:	55                   	push   %ebp
f0103f3d:	89 e5                	mov    %esp,%ebp
f0103f3f:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103f42:	ff 75 08             	pushl  0x8(%ebp)
f0103f45:	e8 d2 c8 ff ff       	call   f010081c <cputchar>
	*cnt++;
}
f0103f4a:	83 c4 10             	add    $0x10,%esp
f0103f4d:	c9                   	leave  
f0103f4e:	c3                   	ret    

f0103f4f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103f4f:	55                   	push   %ebp
f0103f50:	89 e5                	mov    %esp,%ebp
f0103f52:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103f55:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103f5c:	ff 75 0c             	pushl  0xc(%ebp)
f0103f5f:	ff 75 08             	pushl  0x8(%ebp)
f0103f62:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103f65:	50                   	push   %eax
f0103f66:	68 3c 3f 10 f0       	push   $0xf0103f3c
f0103f6b:	e8 65 13 00 00       	call   f01052d5 <vprintfmt>
	return cnt;
}
f0103f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f73:	c9                   	leave  
f0103f74:	c3                   	ret    

f0103f75 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103f75:	55                   	push   %ebp
f0103f76:	89 e5                	mov    %esp,%ebp
f0103f78:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103f7b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103f7e:	50                   	push   %eax
f0103f7f:	ff 75 08             	pushl  0x8(%ebp)
f0103f82:	e8 c8 ff ff ff       	call   f0103f4f <vcprintf>
	va_end(ap);

	return cnt;
}
f0103f87:	c9                   	leave  
f0103f88:	c3                   	ret    

f0103f89 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103f89:	55                   	push   %ebp
f0103f8a:	89 e5                	mov    %esp,%ebp
f0103f8c:	57                   	push   %edi
f0103f8d:	56                   	push   %esi
f0103f8e:	53                   	push   %ebx
f0103f8f:	83 ec 0c             	sub    $0xc,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	struct Taskstate* ts = &thiscpu->cpu_ts;
f0103f92:	e8 2f 21 00 00       	call   f01060c6 <cpunum>
f0103f97:	89 c6                	mov    %eax,%esi
f0103f99:	8d 1c 00             	lea    (%eax,%eax,1),%ebx
f0103f9c:	01 c3                	add    %eax,%ebx
f0103f9e:	01 db                	add    %ebx,%ebx
f0103fa0:	01 c3                	add    %eax,%ebx
f0103fa2:	c1 e3 02             	shl    $0x2,%ebx
f0103fa5:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0103fa8:	8d 3c 85 2c 20 29 f0 	lea    -0xfd6dfd4(,%eax,4),%edi
	ts->ts_esp0 = KSTACKTOP - cpunum() * (KSTKSIZE + KSTKGAP);
f0103faf:	e8 12 21 00 00       	call   f01060c6 <cpunum>
f0103fb4:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f0103fb7:	8d 14 95 20 20 29 f0 	lea    -0xfd6dfe0(,%edx,4),%edx
f0103fbe:	c1 e0 10             	shl    $0x10,%eax
f0103fc1:	89 c1                	mov    %eax,%ecx
f0103fc3:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f0103fc8:	29 c8                	sub    %ecx,%eax
f0103fca:	89 42 10             	mov    %eax,0x10(%edx)
	ts->ts_ss0 = GD_KD;
f0103fcd:	66 c7 42 14 10 00    	movw   $0x10,0x14(%edx)
	ts->ts_iomb = sizeof(struct Taskstate);
f0103fd3:	01 f3                	add    %esi,%ebx
f0103fd5:	66 c7 04 9d 92 20 29 	movw   $0x68,-0xfd6df6e(,%ebx,4)
f0103fdc:	f0 68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) ts,
f0103fdf:	66 c7 05 68 23 12 f0 	movw   $0x67,0xf0122368
f0103fe6:	67 00 
f0103fe8:	66 89 3d 6a 23 12 f0 	mov    %di,0xf012236a
f0103fef:	89 f8                	mov    %edi,%eax
f0103ff1:	c1 e8 10             	shr    $0x10,%eax
f0103ff4:	a2 6c 23 12 f0       	mov    %al,0xf012236c
f0103ff9:	c6 05 6e 23 12 f0 40 	movb   $0x40,0xf012236e
f0104000:	89 f8                	mov    %edi,%eax
f0104002:	c1 e8 18             	shr    $0x18,%eax
f0104005:	a2 6f 23 12 f0       	mov    %al,0xf012236f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f010400a:	c6 05 6d 23 12 f0 89 	movb   $0x89,0xf012236d
	asm volatile("ltr %0" : : "r" (sel));
f0104011:	b8 28 00 00 00       	mov    $0x28,%eax
f0104016:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f0104019:	b8 ac 23 12 f0       	mov    $0xf01223ac,%eax
f010401e:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0104021:	83 c4 0c             	add    $0xc,%esp
f0104024:	5b                   	pop    %ebx
f0104025:	5e                   	pop    %esi
f0104026:	5f                   	pop    %edi
f0104027:	5d                   	pop    %ebp
f0104028:	c3                   	ret    

f0104029 <trap_init>:
{
f0104029:	55                   	push   %ebp
f010402a:	89 e5                	mov    %esp,%ebp
f010402c:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE] , 1, GD_KT, (void*)H_DIVIDE ,0);   
f010402f:	b8 80 48 10 f0       	mov    $0xf0104880,%eax
f0104034:	66 a3 60 12 29 f0    	mov    %ax,0xf0291260
f010403a:	66 c7 05 62 12 29 f0 	movw   $0x8,0xf0291262
f0104041:	08 00 
f0104043:	c6 05 64 12 29 f0 00 	movb   $0x0,0xf0291264
f010404a:	c6 05 65 12 29 f0 8f 	movb   $0x8f,0xf0291265
f0104051:	c1 e8 10             	shr    $0x10,%eax
f0104054:	66 a3 66 12 29 f0    	mov    %ax,0xf0291266
	SETGATE(idt[T_DEBUG]  , 1, GD_KT, (void*)H_DEBUG  ,0);  
f010405a:	b8 86 48 10 f0       	mov    $0xf0104886,%eax
f010405f:	66 a3 68 12 29 f0    	mov    %ax,0xf0291268
f0104065:	66 c7 05 6a 12 29 f0 	movw   $0x8,0xf029126a
f010406c:	08 00 
f010406e:	c6 05 6c 12 29 f0 00 	movb   $0x0,0xf029126c
f0104075:	c6 05 6d 12 29 f0 8f 	movb   $0x8f,0xf029126d
f010407c:	c1 e8 10             	shr    $0x10,%eax
f010407f:	66 a3 6e 12 29 f0    	mov    %ax,0xf029126e
	SETGATE(idt[T_NMI]    , 1, GD_KT, (void*)H_NMI    ,0);
f0104085:	b8 8c 48 10 f0       	mov    $0xf010488c,%eax
f010408a:	66 a3 70 12 29 f0    	mov    %ax,0xf0291270
f0104090:	66 c7 05 72 12 29 f0 	movw   $0x8,0xf0291272
f0104097:	08 00 
f0104099:	c6 05 74 12 29 f0 00 	movb   $0x0,0xf0291274
f01040a0:	c6 05 75 12 29 f0 8f 	movb   $0x8f,0xf0291275
f01040a7:	c1 e8 10             	shr    $0x10,%eax
f01040aa:	66 a3 76 12 29 f0    	mov    %ax,0xf0291276
	SETGATE(idt[T_BRKPT]  , 1, GD_KT, (void*)H_BRKPT  ,3);  // User level previlege (3)
f01040b0:	b8 92 48 10 f0       	mov    $0xf0104892,%eax
f01040b5:	66 a3 78 12 29 f0    	mov    %ax,0xf0291278
f01040bb:	66 c7 05 7a 12 29 f0 	movw   $0x8,0xf029127a
f01040c2:	08 00 
f01040c4:	c6 05 7c 12 29 f0 00 	movb   $0x0,0xf029127c
f01040cb:	c6 05 7d 12 29 f0 ef 	movb   $0xef,0xf029127d
f01040d2:	c1 e8 10             	shr    $0x10,%eax
f01040d5:	66 a3 7e 12 29 f0    	mov    %ax,0xf029127e
	SETGATE(idt[T_OFLOW]  , 1, GD_KT, (void*)H_OFLOW  ,0);  
f01040db:	b8 98 48 10 f0       	mov    $0xf0104898,%eax
f01040e0:	66 a3 80 12 29 f0    	mov    %ax,0xf0291280
f01040e6:	66 c7 05 82 12 29 f0 	movw   $0x8,0xf0291282
f01040ed:	08 00 
f01040ef:	c6 05 84 12 29 f0 00 	movb   $0x0,0xf0291284
f01040f6:	c6 05 85 12 29 f0 8f 	movb   $0x8f,0xf0291285
f01040fd:	c1 e8 10             	shr    $0x10,%eax
f0104100:	66 a3 86 12 29 f0    	mov    %ax,0xf0291286
	SETGATE(idt[T_BOUND]  , 1, GD_KT, (void*)H_BOUND  ,0);  
f0104106:	b8 9e 48 10 f0       	mov    $0xf010489e,%eax
f010410b:	66 a3 88 12 29 f0    	mov    %ax,0xf0291288
f0104111:	66 c7 05 8a 12 29 f0 	movw   $0x8,0xf029128a
f0104118:	08 00 
f010411a:	c6 05 8c 12 29 f0 00 	movb   $0x0,0xf029128c
f0104121:	c6 05 8d 12 29 f0 8f 	movb   $0x8f,0xf029128d
f0104128:	c1 e8 10             	shr    $0x10,%eax
f010412b:	66 a3 8e 12 29 f0    	mov    %ax,0xf029128e
	SETGATE(idt[T_ILLOP]  , 1, GD_KT, (void*)H_ILLOP  ,0);  
f0104131:	b8 a4 48 10 f0       	mov    $0xf01048a4,%eax
f0104136:	66 a3 90 12 29 f0    	mov    %ax,0xf0291290
f010413c:	66 c7 05 92 12 29 f0 	movw   $0x8,0xf0291292
f0104143:	08 00 
f0104145:	c6 05 94 12 29 f0 00 	movb   $0x0,0xf0291294
f010414c:	c6 05 95 12 29 f0 8f 	movb   $0x8f,0xf0291295
f0104153:	c1 e8 10             	shr    $0x10,%eax
f0104156:	66 a3 96 12 29 f0    	mov    %ax,0xf0291296
	SETGATE(idt[T_DEVICE] , 1, GD_KT, (void*)H_DEVICE ,0);   
f010415c:	b8 aa 48 10 f0       	mov    $0xf01048aa,%eax
f0104161:	66 a3 98 12 29 f0    	mov    %ax,0xf0291298
f0104167:	66 c7 05 9a 12 29 f0 	movw   $0x8,0xf029129a
f010416e:	08 00 
f0104170:	c6 05 9c 12 29 f0 00 	movb   $0x0,0xf029129c
f0104177:	c6 05 9d 12 29 f0 8f 	movb   $0x8f,0xf029129d
f010417e:	c1 e8 10             	shr    $0x10,%eax
f0104181:	66 a3 9e 12 29 f0    	mov    %ax,0xf029129e
	SETGATE(idt[T_DBLFLT] , 1, GD_KT, (void*)H_DBLFLT ,0);   
f0104187:	b8 b0 48 10 f0       	mov    $0xf01048b0,%eax
f010418c:	66 a3 a0 12 29 f0    	mov    %ax,0xf02912a0
f0104192:	66 c7 05 a2 12 29 f0 	movw   $0x8,0xf02912a2
f0104199:	08 00 
f010419b:	c6 05 a4 12 29 f0 00 	movb   $0x0,0xf02912a4
f01041a2:	c6 05 a5 12 29 f0 8f 	movb   $0x8f,0xf02912a5
f01041a9:	c1 e8 10             	shr    $0x10,%eax
f01041ac:	66 a3 a6 12 29 f0    	mov    %ax,0xf02912a6
	SETGATE(idt[T_TSS]    , 1, GD_KT, (void*)H_TSS    ,0);
f01041b2:	b8 b4 48 10 f0       	mov    $0xf01048b4,%eax
f01041b7:	66 a3 b0 12 29 f0    	mov    %ax,0xf02912b0
f01041bd:	66 c7 05 b2 12 29 f0 	movw   $0x8,0xf02912b2
f01041c4:	08 00 
f01041c6:	c6 05 b4 12 29 f0 00 	movb   $0x0,0xf02912b4
f01041cd:	c6 05 b5 12 29 f0 8f 	movb   $0x8f,0xf02912b5
f01041d4:	c1 e8 10             	shr    $0x10,%eax
f01041d7:	66 a3 b6 12 29 f0    	mov    %ax,0xf02912b6
	SETGATE(idt[T_SEGNP]  , 1, GD_KT, (void*)H_SEGNP  ,0);  
f01041dd:	b8 b8 48 10 f0       	mov    $0xf01048b8,%eax
f01041e2:	66 a3 b8 12 29 f0    	mov    %ax,0xf02912b8
f01041e8:	66 c7 05 ba 12 29 f0 	movw   $0x8,0xf02912ba
f01041ef:	08 00 
f01041f1:	c6 05 bc 12 29 f0 00 	movb   $0x0,0xf02912bc
f01041f8:	c6 05 bd 12 29 f0 8f 	movb   $0x8f,0xf02912bd
f01041ff:	c1 e8 10             	shr    $0x10,%eax
f0104202:	66 a3 be 12 29 f0    	mov    %ax,0xf02912be
	SETGATE(idt[T_STACK]  , 1, GD_KT, (void*)H_STACK  ,0);  
f0104208:	b8 bc 48 10 f0       	mov    $0xf01048bc,%eax
f010420d:	66 a3 c0 12 29 f0    	mov    %ax,0xf02912c0
f0104213:	66 c7 05 c2 12 29 f0 	movw   $0x8,0xf02912c2
f010421a:	08 00 
f010421c:	c6 05 c4 12 29 f0 00 	movb   $0x0,0xf02912c4
f0104223:	c6 05 c5 12 29 f0 8f 	movb   $0x8f,0xf02912c5
f010422a:	c1 e8 10             	shr    $0x10,%eax
f010422d:	66 a3 c6 12 29 f0    	mov    %ax,0xf02912c6
	SETGATE(idt[T_GPFLT]  , 1, GD_KT, (void*)H_GPFLT  ,0);  
f0104233:	b8 c0 48 10 f0       	mov    $0xf01048c0,%eax
f0104238:	66 a3 c8 12 29 f0    	mov    %ax,0xf02912c8
f010423e:	66 c7 05 ca 12 29 f0 	movw   $0x8,0xf02912ca
f0104245:	08 00 
f0104247:	c6 05 cc 12 29 f0 00 	movb   $0x0,0xf02912cc
f010424e:	c6 05 cd 12 29 f0 8f 	movb   $0x8f,0xf02912cd
f0104255:	c1 e8 10             	shr    $0x10,%eax
f0104258:	66 a3 ce 12 29 f0    	mov    %ax,0xf02912ce
	SETGATE(idt[T_PGFLT]  , 1, GD_KT, (void*)H_PGFLT  ,0);  
f010425e:	b8 c4 48 10 f0       	mov    $0xf01048c4,%eax
f0104263:	66 a3 d0 12 29 f0    	mov    %ax,0xf02912d0
f0104269:	66 c7 05 d2 12 29 f0 	movw   $0x8,0xf02912d2
f0104270:	08 00 
f0104272:	c6 05 d4 12 29 f0 00 	movb   $0x0,0xf02912d4
f0104279:	c6 05 d5 12 29 f0 8f 	movb   $0x8f,0xf02912d5
f0104280:	c1 e8 10             	shr    $0x10,%eax
f0104283:	66 a3 d6 12 29 f0    	mov    %ax,0xf02912d6
	SETGATE(idt[T_FPERR]  , 1, GD_KT, (void*)H_FPERR  ,0);  
f0104289:	b8 c8 48 10 f0       	mov    $0xf01048c8,%eax
f010428e:	66 a3 e0 12 29 f0    	mov    %ax,0xf02912e0
f0104294:	66 c7 05 e2 12 29 f0 	movw   $0x8,0xf02912e2
f010429b:	08 00 
f010429d:	c6 05 e4 12 29 f0 00 	movb   $0x0,0xf02912e4
f01042a4:	c6 05 e5 12 29 f0 8f 	movb   $0x8f,0xf02912e5
f01042ab:	c1 e8 10             	shr    $0x10,%eax
f01042ae:	66 a3 e6 12 29 f0    	mov    %ax,0xf02912e6
	SETGATE(idt[T_ALIGN]  , 1, GD_KT, (void*)H_ALIGN  ,0);  
f01042b4:	b8 ce 48 10 f0       	mov    $0xf01048ce,%eax
f01042b9:	66 a3 e8 12 29 f0    	mov    %ax,0xf02912e8
f01042bf:	66 c7 05 ea 12 29 f0 	movw   $0x8,0xf02912ea
f01042c6:	08 00 
f01042c8:	c6 05 ec 12 29 f0 00 	movb   $0x0,0xf02912ec
f01042cf:	c6 05 ed 12 29 f0 8f 	movb   $0x8f,0xf02912ed
f01042d6:	c1 e8 10             	shr    $0x10,%eax
f01042d9:	66 a3 ee 12 29 f0    	mov    %ax,0xf02912ee
	SETGATE(idt[T_MCHK]   , 1, GD_KT, (void*)H_MCHK   ,0); 
f01042df:	b8 d4 48 10 f0       	mov    $0xf01048d4,%eax
f01042e4:	66 a3 f0 12 29 f0    	mov    %ax,0xf02912f0
f01042ea:	66 c7 05 f2 12 29 f0 	movw   $0x8,0xf02912f2
f01042f1:	08 00 
f01042f3:	c6 05 f4 12 29 f0 00 	movb   $0x0,0xf02912f4
f01042fa:	c6 05 f5 12 29 f0 8f 	movb   $0x8f,0xf02912f5
f0104301:	c1 e8 10             	shr    $0x10,%eax
f0104304:	66 a3 f6 12 29 f0    	mov    %ax,0xf02912f6
	SETGATE(idt[T_SIMDERR], 1, GD_KT, (void*)H_SIMDERR,0);  
f010430a:	b8 da 48 10 f0       	mov    $0xf01048da,%eax
f010430f:	66 a3 f8 12 29 f0    	mov    %ax,0xf02912f8
f0104315:	66 c7 05 fa 12 29 f0 	movw   $0x8,0xf02912fa
f010431c:	08 00 
f010431e:	c6 05 fc 12 29 f0 00 	movb   $0x0,0xf02912fc
f0104325:	c6 05 fd 12 29 f0 8f 	movb   $0x8f,0xf02912fd
f010432c:	c1 e8 10             	shr    $0x10,%eax
f010432f:	66 a3 fe 12 29 f0    	mov    %ax,0xf02912fe
	SETGATE(idt[T_SYSCALL], 1, GD_KT, (void*)H_SYSCALL,3);  // System call
f0104335:	b8 e0 48 10 f0       	mov    $0xf01048e0,%eax
f010433a:	66 a3 e0 13 29 f0    	mov    %ax,0xf02913e0
f0104340:	66 c7 05 e2 13 29 f0 	movw   $0x8,0xf02913e2
f0104347:	08 00 
f0104349:	c6 05 e4 13 29 f0 00 	movb   $0x0,0xf02913e4
f0104350:	c6 05 e5 13 29 f0 ef 	movb   $0xef,0xf02913e5
f0104357:	c1 e8 10             	shr    $0x10,%eax
f010435a:	66 a3 e6 13 29 f0    	mov    %ax,0xf02913e6
	trap_init_percpu();
f0104360:	e8 24 fc ff ff       	call   f0103f89 <trap_init_percpu>
}
f0104365:	c9                   	leave  
f0104366:	c3                   	ret    

f0104367 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104367:	55                   	push   %ebp
f0104368:	89 e5                	mov    %esp,%ebp
f010436a:	53                   	push   %ebx
f010436b:	83 ec 0c             	sub    $0xc,%esp
f010436e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0104371:	ff 33                	pushl  (%ebx)
f0104373:	68 58 7d 10 f0       	push   $0xf0107d58
f0104378:	e8 f8 fb ff ff       	call   f0103f75 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010437d:	83 c4 08             	add    $0x8,%esp
f0104380:	ff 73 04             	pushl  0x4(%ebx)
f0104383:	68 67 7d 10 f0       	push   $0xf0107d67
f0104388:	e8 e8 fb ff ff       	call   f0103f75 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010438d:	83 c4 08             	add    $0x8,%esp
f0104390:	ff 73 08             	pushl  0x8(%ebx)
f0104393:	68 76 7d 10 f0       	push   $0xf0107d76
f0104398:	e8 d8 fb ff ff       	call   f0103f75 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010439d:	83 c4 08             	add    $0x8,%esp
f01043a0:	ff 73 0c             	pushl  0xc(%ebx)
f01043a3:	68 85 7d 10 f0       	push   $0xf0107d85
f01043a8:	e8 c8 fb ff ff       	call   f0103f75 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01043ad:	83 c4 08             	add    $0x8,%esp
f01043b0:	ff 73 10             	pushl  0x10(%ebx)
f01043b3:	68 94 7d 10 f0       	push   $0xf0107d94
f01043b8:	e8 b8 fb ff ff       	call   f0103f75 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01043bd:	83 c4 08             	add    $0x8,%esp
f01043c0:	ff 73 14             	pushl  0x14(%ebx)
f01043c3:	68 a3 7d 10 f0       	push   $0xf0107da3
f01043c8:	e8 a8 fb ff ff       	call   f0103f75 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01043cd:	83 c4 08             	add    $0x8,%esp
f01043d0:	ff 73 18             	pushl  0x18(%ebx)
f01043d3:	68 b2 7d 10 f0       	push   $0xf0107db2
f01043d8:	e8 98 fb ff ff       	call   f0103f75 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01043dd:	83 c4 08             	add    $0x8,%esp
f01043e0:	ff 73 1c             	pushl  0x1c(%ebx)
f01043e3:	68 c1 7d 10 f0       	push   $0xf0107dc1
f01043e8:	e8 88 fb ff ff       	call   f0103f75 <cprintf>
}
f01043ed:	83 c4 10             	add    $0x10,%esp
f01043f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01043f3:	c9                   	leave  
f01043f4:	c3                   	ret    

f01043f5 <print_trapframe>:
{
f01043f5:	55                   	push   %ebp
f01043f6:	89 e5                	mov    %esp,%ebp
f01043f8:	53                   	push   %ebx
f01043f9:	83 ec 04             	sub    $0x4,%esp
f01043fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01043ff:	e8 c2 1c 00 00       	call   f01060c6 <cpunum>
f0104404:	83 ec 04             	sub    $0x4,%esp
f0104407:	50                   	push   %eax
f0104408:	53                   	push   %ebx
f0104409:	68 25 7e 10 f0       	push   $0xf0107e25
f010440e:	e8 62 fb ff ff       	call   f0103f75 <cprintf>
	print_regs(&tf->tf_regs);
f0104413:	89 1c 24             	mov    %ebx,(%esp)
f0104416:	e8 4c ff ff ff       	call   f0104367 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010441b:	83 c4 08             	add    $0x8,%esp
f010441e:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104422:	50                   	push   %eax
f0104423:	68 43 7e 10 f0       	push   $0xf0107e43
f0104428:	e8 48 fb ff ff       	call   f0103f75 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010442d:	83 c4 08             	add    $0x8,%esp
f0104430:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0104434:	50                   	push   %eax
f0104435:	68 56 7e 10 f0       	push   $0xf0107e56
f010443a:	e8 36 fb ff ff       	call   f0103f75 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010443f:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0104442:	83 c4 10             	add    $0x10,%esp
f0104445:	83 f8 13             	cmp    $0x13,%eax
f0104448:	76 1c                	jbe    f0104466 <print_trapframe+0x71>
	if (trapno == T_SYSCALL)
f010444a:	83 f8 30             	cmp    $0x30,%eax
f010444d:	0f 84 cf 00 00 00    	je     f0104522 <print_trapframe+0x12d>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104453:	8d 50 e0             	lea    -0x20(%eax),%edx
f0104456:	83 fa 0f             	cmp    $0xf,%edx
f0104459:	0f 86 cd 00 00 00    	jbe    f010452c <print_trapframe+0x137>
	return "(unknown trap)";
f010445f:	ba ef 7d 10 f0       	mov    $0xf0107def,%edx
f0104464:	eb 07                	jmp    f010446d <print_trapframe+0x78>
		return excnames[trapno];
f0104466:	8b 14 85 00 81 10 f0 	mov    -0xfef7f00(,%eax,4),%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010446d:	83 ec 04             	sub    $0x4,%esp
f0104470:	52                   	push   %edx
f0104471:	50                   	push   %eax
f0104472:	68 69 7e 10 f0       	push   $0xf0107e69
f0104477:	e8 f9 fa ff ff       	call   f0103f75 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010447c:	83 c4 10             	add    $0x10,%esp
f010447f:	39 1d 60 1a 29 f0    	cmp    %ebx,0xf0291a60
f0104485:	0f 84 ab 00 00 00    	je     f0104536 <print_trapframe+0x141>
	cprintf("  err  0x%08x", tf->tf_err);
f010448b:	83 ec 08             	sub    $0x8,%esp
f010448e:	ff 73 2c             	pushl  0x2c(%ebx)
f0104491:	68 8a 7e 10 f0       	push   $0xf0107e8a
f0104496:	e8 da fa ff ff       	call   f0103f75 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f010449b:	83 c4 10             	add    $0x10,%esp
f010449e:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01044a2:	0f 85 cf 00 00 00    	jne    f0104577 <print_trapframe+0x182>
			tf->tf_err & 1 ? "protection" : "not-present");
f01044a8:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f01044ab:	a8 01                	test   $0x1,%al
f01044ad:	0f 85 a6 00 00 00    	jne    f0104559 <print_trapframe+0x164>
f01044b3:	b9 09 7e 10 f0       	mov    $0xf0107e09,%ecx
f01044b8:	a8 02                	test   $0x2,%al
f01044ba:	0f 85 a3 00 00 00    	jne    f0104563 <print_trapframe+0x16e>
f01044c0:	ba 1b 7e 10 f0       	mov    $0xf0107e1b,%edx
f01044c5:	a8 04                	test   $0x4,%al
f01044c7:	0f 85 a0 00 00 00    	jne    f010456d <print_trapframe+0x178>
f01044cd:	b8 55 7f 10 f0       	mov    $0xf0107f55,%eax
f01044d2:	51                   	push   %ecx
f01044d3:	52                   	push   %edx
f01044d4:	50                   	push   %eax
f01044d5:	68 98 7e 10 f0       	push   $0xf0107e98
f01044da:	e8 96 fa ff ff       	call   f0103f75 <cprintf>
f01044df:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01044e2:	83 ec 08             	sub    $0x8,%esp
f01044e5:	ff 73 30             	pushl  0x30(%ebx)
f01044e8:	68 a7 7e 10 f0       	push   $0xf0107ea7
f01044ed:	e8 83 fa ff ff       	call   f0103f75 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01044f2:	83 c4 08             	add    $0x8,%esp
f01044f5:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01044f9:	50                   	push   %eax
f01044fa:	68 b6 7e 10 f0       	push   $0xf0107eb6
f01044ff:	e8 71 fa ff ff       	call   f0103f75 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104504:	83 c4 08             	add    $0x8,%esp
f0104507:	ff 73 38             	pushl  0x38(%ebx)
f010450a:	68 c9 7e 10 f0       	push   $0xf0107ec9
f010450f:	e8 61 fa ff ff       	call   f0103f75 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104514:	83 c4 10             	add    $0x10,%esp
f0104517:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010451b:	75 6f                	jne    f010458c <print_trapframe+0x197>
}
f010451d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104520:	c9                   	leave  
f0104521:	c3                   	ret    
		return "System call";
f0104522:	ba d0 7d 10 f0       	mov    $0xf0107dd0,%edx
f0104527:	e9 41 ff ff ff       	jmp    f010446d <print_trapframe+0x78>
		return "Hardware Interrupt";
f010452c:	ba dc 7d 10 f0       	mov    $0xf0107ddc,%edx
f0104531:	e9 37 ff ff ff       	jmp    f010446d <print_trapframe+0x78>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104536:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010453a:	0f 85 4b ff ff ff    	jne    f010448b <print_trapframe+0x96>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0104540:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104543:	83 ec 08             	sub    $0x8,%esp
f0104546:	50                   	push   %eax
f0104547:	68 7b 7e 10 f0       	push   $0xf0107e7b
f010454c:	e8 24 fa ff ff       	call   f0103f75 <cprintf>
f0104551:	83 c4 10             	add    $0x10,%esp
f0104554:	e9 32 ff ff ff       	jmp    f010448b <print_trapframe+0x96>
		cprintf(" [%s, %s, %s]\n",
f0104559:	b9 fe 7d 10 f0       	mov    $0xf0107dfe,%ecx
f010455e:	e9 55 ff ff ff       	jmp    f01044b8 <print_trapframe+0xc3>
f0104563:	ba 15 7e 10 f0       	mov    $0xf0107e15,%edx
f0104568:	e9 58 ff ff ff       	jmp    f01044c5 <print_trapframe+0xd0>
f010456d:	b8 20 7e 10 f0       	mov    $0xf0107e20,%eax
f0104572:	e9 5b ff ff ff       	jmp    f01044d2 <print_trapframe+0xdd>
		cprintf("\n");
f0104577:	83 ec 0c             	sub    $0xc,%esp
f010457a:	68 9b 6b 10 f0       	push   $0xf0106b9b
f010457f:	e8 f1 f9 ff ff       	call   f0103f75 <cprintf>
f0104584:	83 c4 10             	add    $0x10,%esp
f0104587:	e9 56 ff ff ff       	jmp    f01044e2 <print_trapframe+0xed>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010458c:	83 ec 08             	sub    $0x8,%esp
f010458f:	ff 73 3c             	pushl  0x3c(%ebx)
f0104592:	68 d8 7e 10 f0       	push   $0xf0107ed8
f0104597:	e8 d9 f9 ff ff       	call   f0103f75 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010459c:	83 c4 08             	add    $0x8,%esp
f010459f:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01045a3:	50                   	push   %eax
f01045a4:	68 e7 7e 10 f0       	push   $0xf0107ee7
f01045a9:	e8 c7 f9 ff ff       	call   f0103f75 <cprintf>
f01045ae:	83 c4 10             	add    $0x10,%esp
}
f01045b1:	e9 67 ff ff ff       	jmp    f010451d <print_trapframe+0x128>

f01045b6 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01045b6:	55                   	push   %ebp
f01045b7:	89 e5                	mov    %esp,%ebp
f01045b9:	57                   	push   %edi
f01045ba:	56                   	push   %esi
f01045bb:	53                   	push   %ebx
f01045bc:	83 ec 0c             	sub    $0xc,%esp
f01045bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01045c2:	0f 20 d6             	mov    %cr2,%esi

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	uint16_t cs = tf->tf_cs;
	if ((cs & 0xFF) == GD_KT) { // code segment descriptor is kernel
f01045c5:	80 7b 34 08          	cmpb   $0x8,0x34(%ebx)
f01045c9:	74 5d                	je     f0104628 <page_fault_handler+0x72>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01045cb:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01045ce:	e8 f3 1a 00 00       	call   f01060c6 <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01045d3:	57                   	push   %edi
f01045d4:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f01045d5:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01045d8:	01 c2                	add    %eax,%edx
f01045da:	01 d2                	add    %edx,%edx
f01045dc:	01 c2                	add    %eax,%edx
f01045de:	8d 04 90             	lea    (%eax,%edx,4),%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01045e1:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f01045e8:	ff 70 48             	pushl  0x48(%eax)
f01045eb:	68 cc 80 10 f0       	push   $0xf01080cc
f01045f0:	e8 80 f9 ff ff       	call   f0103f75 <cprintf>
	print_trapframe(tf);
f01045f5:	89 1c 24             	mov    %ebx,(%esp)
f01045f8:	e8 f8 fd ff ff       	call   f01043f5 <print_trapframe>
	env_destroy(curenv);
f01045fd:	e8 c4 1a 00 00       	call   f01060c6 <cpunum>
f0104602:	83 c4 04             	add    $0x4,%esp
f0104605:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104608:	01 c2                	add    %eax,%edx
f010460a:	01 d2                	add    %edx,%edx
f010460c:	01 c2                	add    %eax,%edx
f010460e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104611:	ff 34 85 28 20 29 f0 	pushl  -0xfd6dfd8(,%eax,4)
f0104618:	e8 1c f6 ff ff       	call   f0103c39 <env_destroy>
}
f010461d:	83 c4 10             	add    $0x10,%esp
f0104620:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104623:	5b                   	pop    %ebx
f0104624:	5e                   	pop    %esi
f0104625:	5f                   	pop    %edi
f0104626:	5d                   	pop    %ebp
f0104627:	c3                   	ret    
		print_trapframe(tf);
f0104628:	83 ec 0c             	sub    $0xc,%esp
f010462b:	53                   	push   %ebx
f010462c:	e8 c4 fd ff ff       	call   f01043f5 <print_trapframe>
		panic("Page fault in kernel mode! Fault addr: %p", fault_va);
f0104631:	56                   	push   %esi
f0104632:	68 a0 80 10 f0       	push   $0xf01080a0
f0104637:	68 3f 01 00 00       	push   $0x13f
f010463c:	68 fa 7e 10 f0       	push   $0xf0107efa
f0104641:	e8 4e ba ff ff       	call   f0100094 <_panic>

f0104646 <trap>:
{
f0104646:	55                   	push   %ebp
f0104647:	89 e5                	mov    %esp,%ebp
f0104649:	57                   	push   %edi
f010464a:	56                   	push   %esi
f010464b:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f010464e:	fc                   	cld    
	if (panicstr)
f010464f:	83 3d 80 1e 29 f0 00 	cmpl   $0x0,0xf0291e80
f0104656:	74 01                	je     f0104659 <trap+0x13>
		asm volatile("hlt");
f0104658:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104659:	e8 68 1a 00 00       	call   f01060c6 <cpunum>
f010465e:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104661:	01 c2                	add    %eax,%edx
f0104663:	01 d2                	add    %edx,%edx
f0104665:	01 c2                	add    %eax,%edx
f0104667:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010466a:	8d 14 85 04 00 00 00 	lea    0x4(,%eax,4),%edx
	asm volatile("lock; xchgl %0, %1"
f0104671:	b8 01 00 00 00       	mov    $0x1,%eax
f0104676:	f0 87 82 20 20 29 f0 	lock xchg %eax,-0xfd6dfe0(%edx)
f010467d:	83 f8 02             	cmp    $0x2,%eax
f0104680:	74 53                	je     f01046d5 <trap+0x8f>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104682:	9c                   	pushf  
f0104683:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f0104684:	f6 c4 02             	test   $0x2,%ah
f0104687:	75 5e                	jne    f01046e7 <trap+0xa1>
	if ((tf->tf_cs & 3) == 3) {
f0104689:	66 8b 46 34          	mov    0x34(%esi),%ax
f010468d:	83 e0 03             	and    $0x3,%eax
f0104690:	66 83 f8 03          	cmp    $0x3,%ax
f0104694:	74 6a                	je     f0104700 <trap+0xba>
	last_tf = tf;
f0104696:	89 35 60 1a 29 f0    	mov    %esi,0xf0291a60
	switch(tf->tf_trapno){
f010469c:	8b 46 28             	mov    0x28(%esi),%eax
f010469f:	83 f8 0e             	cmp    $0xe,%eax
f01046a2:	0f 84 fd 00 00 00    	je     f01047a5 <trap+0x15f>
f01046a8:	83 f8 30             	cmp    $0x30,%eax
f01046ab:	0f 84 2e 01 00 00    	je     f01047df <trap+0x199>
f01046b1:	83 f8 03             	cmp    $0x3,%eax
f01046b4:	0f 85 46 01 00 00    	jne    f0104800 <trap+0x1ba>
		print_trapframe(tf);
f01046ba:	83 ec 0c             	sub    $0xc,%esp
f01046bd:	56                   	push   %esi
f01046be:	e8 32 fd ff ff       	call   f01043f5 <print_trapframe>
f01046c3:	83 c4 10             	add    $0x10,%esp
			monitor(NULL);
f01046c6:	83 ec 0c             	sub    $0xc,%esp
f01046c9:	6a 00                	push   $0x0
f01046cb:	e8 34 c7 ff ff       	call   f0100e04 <monitor>
f01046d0:	83 c4 10             	add    $0x10,%esp
f01046d3:	eb f1                	jmp    f01046c6 <trap+0x80>
	spin_lock(&kernel_lock);
f01046d5:	83 ec 0c             	sub    $0xc,%esp
f01046d8:	68 c0 23 12 f0       	push   $0xf01223c0
f01046dd:	e8 58 1c 00 00       	call   f010633a <spin_lock>
f01046e2:	83 c4 10             	add    $0x10,%esp
f01046e5:	eb 9b                	jmp    f0104682 <trap+0x3c>
	assert(!(read_eflags() & FL_IF));
f01046e7:	68 06 7f 10 f0       	push   $0xf0107f06
f01046ec:	68 43 79 10 f0       	push   $0xf0107943
f01046f1:	68 0b 01 00 00       	push   $0x10b
f01046f6:	68 fa 7e 10 f0       	push   $0xf0107efa
f01046fb:	e8 94 b9 ff ff       	call   f0100094 <_panic>
f0104700:	83 ec 0c             	sub    $0xc,%esp
f0104703:	68 c0 23 12 f0       	push   $0xf01223c0
f0104708:	e8 2d 1c 00 00       	call   f010633a <spin_lock>
		assert(curenv);
f010470d:	e8 b4 19 00 00       	call   f01060c6 <cpunum>
f0104712:	6b c0 74             	imul   $0x74,%eax,%eax
f0104715:	83 c4 10             	add    $0x10,%esp
f0104718:	83 b8 28 20 29 f0 00 	cmpl   $0x0,-0xfd6dfd8(%eax)
f010471f:	75 19                	jne    f010473a <trap+0xf4>
f0104721:	68 1f 7f 10 f0       	push   $0xf0107f1f
f0104726:	68 43 79 10 f0       	push   $0xf0107943
f010472b:	68 12 01 00 00       	push   $0x112
f0104730:	68 fa 7e 10 f0       	push   $0xf0107efa
f0104735:	e8 5a b9 ff ff       	call   f0100094 <_panic>
		if (curenv->env_status == ENV_DYING) {
f010473a:	e8 87 19 00 00       	call   f01060c6 <cpunum>
f010473f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104742:	8b 80 28 20 29 f0    	mov    -0xfd6dfd8(%eax),%eax
f0104748:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010474c:	74 2a                	je     f0104778 <trap+0x132>
		curenv->env_tf = *tf;
f010474e:	e8 73 19 00 00       	call   f01060c6 <cpunum>
f0104753:	6b c0 74             	imul   $0x74,%eax,%eax
f0104756:	8b 80 28 20 29 f0    	mov    -0xfd6dfd8(%eax),%eax
f010475c:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104761:	89 c7                	mov    %eax,%edi
f0104763:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0104765:	e8 5c 19 00 00       	call   f01060c6 <cpunum>
f010476a:	6b c0 74             	imul   $0x74,%eax,%eax
f010476d:	8b b0 28 20 29 f0    	mov    -0xfd6dfd8(%eax),%esi
f0104773:	e9 1e ff ff ff       	jmp    f0104696 <trap+0x50>
			env_free(curenv);
f0104778:	e8 49 19 00 00       	call   f01060c6 <cpunum>
f010477d:	83 ec 0c             	sub    $0xc,%esp
f0104780:	6b c0 74             	imul   $0x74,%eax,%eax
f0104783:	ff b0 28 20 29 f0    	pushl  -0xfd6dfd8(%eax)
f0104789:	e8 9d f2 ff ff       	call   f0103a2b <env_free>
			curenv = NULL;
f010478e:	e8 33 19 00 00       	call   f01060c6 <cpunum>
f0104793:	6b c0 74             	imul   $0x74,%eax,%eax
f0104796:	c7 80 28 20 29 f0 00 	movl   $0x0,-0xfd6dfd8(%eax)
f010479d:	00 00 00 
			sched_yield();
f01047a0:	e8 40 02 00 00       	call   f01049e5 <sched_yield>
		page_fault_handler(tf);
f01047a5:	83 ec 0c             	sub    $0xc,%esp
f01047a8:	56                   	push   %esi
f01047a9:	e8 08 fe ff ff       	call   f01045b6 <page_fault_handler>
f01047ae:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f01047b1:	e8 10 19 00 00       	call   f01060c6 <cpunum>
f01047b6:	6b c0 74             	imul   $0x74,%eax,%eax
f01047b9:	83 b8 28 20 29 f0 00 	cmpl   $0x0,-0xfd6dfd8(%eax)
f01047c0:	74 18                	je     f01047da <trap+0x194>
f01047c2:	e8 ff 18 00 00       	call   f01060c6 <cpunum>
f01047c7:	6b c0 74             	imul   $0x74,%eax,%eax
f01047ca:	8b 80 28 20 29 f0    	mov    -0xfd6dfd8(%eax),%eax
f01047d0:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01047d4:	0f 84 90 00 00 00    	je     f010486a <trap+0x224>
		sched_yield();
f01047da:	e8 06 02 00 00       	call   f01049e5 <sched_yield>
		tf->tf_regs.reg_eax = syscall(
f01047df:	83 ec 08             	sub    $0x8,%esp
f01047e2:	ff 76 04             	pushl  0x4(%esi)
f01047e5:	ff 36                	pushl  (%esi)
f01047e7:	ff 76 10             	pushl  0x10(%esi)
f01047ea:	ff 76 18             	pushl  0x18(%esi)
f01047ed:	ff 76 14             	pushl  0x14(%esi)
f01047f0:	ff 76 1c             	pushl  0x1c(%esi)
f01047f3:	e8 dd 02 00 00       	call   f0104ad5 <syscall>
f01047f8:	89 46 1c             	mov    %eax,0x1c(%esi)
f01047fb:	83 c4 20             	add    $0x20,%esp
f01047fe:	eb b1                	jmp    f01047b1 <trap+0x16b>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104800:	83 f8 27             	cmp    $0x27,%eax
f0104803:	74 31                	je     f0104836 <trap+0x1f0>
	print_trapframe(tf);
f0104805:	83 ec 0c             	sub    $0xc,%esp
f0104808:	56                   	push   %esi
f0104809:	e8 e7 fb ff ff       	call   f01043f5 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010480e:	83 c4 10             	add    $0x10,%esp
f0104811:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104816:	74 3b                	je     f0104853 <trap+0x20d>
		env_destroy(curenv);
f0104818:	e8 a9 18 00 00       	call   f01060c6 <cpunum>
f010481d:	83 ec 0c             	sub    $0xc,%esp
f0104820:	6b c0 74             	imul   $0x74,%eax,%eax
f0104823:	ff b0 28 20 29 f0    	pushl  -0xfd6dfd8(%eax)
f0104829:	e8 0b f4 ff ff       	call   f0103c39 <env_destroy>
f010482e:	83 c4 10             	add    $0x10,%esp
f0104831:	e9 7b ff ff ff       	jmp    f01047b1 <trap+0x16b>
		cprintf("Spurious interrupt on irq 7\n");
f0104836:	83 ec 0c             	sub    $0xc,%esp
f0104839:	68 26 7f 10 f0       	push   $0xf0107f26
f010483e:	e8 32 f7 ff ff       	call   f0103f75 <cprintf>
		print_trapframe(tf);
f0104843:	89 34 24             	mov    %esi,(%esp)
f0104846:	e8 aa fb ff ff       	call   f01043f5 <print_trapframe>
f010484b:	83 c4 10             	add    $0x10,%esp
f010484e:	e9 5e ff ff ff       	jmp    f01047b1 <trap+0x16b>
		panic("unhandled trap in kernel");
f0104853:	83 ec 04             	sub    $0x4,%esp
f0104856:	68 43 7f 10 f0       	push   $0xf0107f43
f010485b:	68 f1 00 00 00       	push   $0xf1
f0104860:	68 fa 7e 10 f0       	push   $0xf0107efa
f0104865:	e8 2a b8 ff ff       	call   f0100094 <_panic>
		env_run(curenv);
f010486a:	e8 57 18 00 00       	call   f01060c6 <cpunum>
f010486f:	83 ec 0c             	sub    $0xc,%esp
f0104872:	6b c0 74             	imul   $0x74,%eax,%eax
f0104875:	ff b0 28 20 29 f0    	pushl  -0xfd6dfd8(%eax)
f010487b:	e8 76 f4 ff ff       	call   f0103cf6 <env_run>

f0104880 <H_DIVIDE>:
	pushl $(num);							\
	jmp _alltraps

.text

TRAPHANDLER_NOEC(H_DIVIDE , T_DIVIDE)
f0104880:	6a 00                	push   $0x0
f0104882:	6a 00                	push   $0x0
f0104884:	eb 60                	jmp    f01048e6 <_alltraps>

f0104886 <H_DEBUG>:
TRAPHANDLER_NOEC(H_DEBUG  , T_DEBUG)
f0104886:	6a 00                	push   $0x0
f0104888:	6a 01                	push   $0x1
f010488a:	eb 5a                	jmp    f01048e6 <_alltraps>

f010488c <H_NMI>:
TRAPHANDLER_NOEC(H_NMI    , T_NMI)
f010488c:	6a 00                	push   $0x0
f010488e:	6a 02                	push   $0x2
f0104890:	eb 54                	jmp    f01048e6 <_alltraps>

f0104892 <H_BRKPT>:
TRAPHANDLER_NOEC(H_BRKPT  , T_BRKPT)
f0104892:	6a 00                	push   $0x0
f0104894:	6a 03                	push   $0x3
f0104896:	eb 4e                	jmp    f01048e6 <_alltraps>

f0104898 <H_OFLOW>:
TRAPHANDLER_NOEC(H_OFLOW  , T_OFLOW)
f0104898:	6a 00                	push   $0x0
f010489a:	6a 04                	push   $0x4
f010489c:	eb 48                	jmp    f01048e6 <_alltraps>

f010489e <H_BOUND>:
TRAPHANDLER_NOEC(H_BOUND  , T_BOUND)
f010489e:	6a 00                	push   $0x0
f01048a0:	6a 05                	push   $0x5
f01048a2:	eb 42                	jmp    f01048e6 <_alltraps>

f01048a4 <H_ILLOP>:
TRAPHANDLER_NOEC(H_ILLOP  , T_ILLOP)
f01048a4:	6a 00                	push   $0x0
f01048a6:	6a 06                	push   $0x6
f01048a8:	eb 3c                	jmp    f01048e6 <_alltraps>

f01048aa <H_DEVICE>:
TRAPHANDLER_NOEC(H_DEVICE , T_DEVICE)
f01048aa:	6a 00                	push   $0x0
f01048ac:	6a 07                	push   $0x7
f01048ae:	eb 36                	jmp    f01048e6 <_alltraps>

f01048b0 <H_DBLFLT>:
TRAPHANDLER     (H_DBLFLT , T_DBLFLT)	// Error Code const 0
f01048b0:	6a 08                	push   $0x8
f01048b2:	eb 32                	jmp    f01048e6 <_alltraps>

f01048b4 <H_TSS>:
TRAPHANDLER     (H_TSS    , T_TSS)
f01048b4:	6a 0a                	push   $0xa
f01048b6:	eb 2e                	jmp    f01048e6 <_alltraps>

f01048b8 <H_SEGNP>:
TRAPHANDLER     (H_SEGNP  , T_SEGNP)
f01048b8:	6a 0b                	push   $0xb
f01048ba:	eb 2a                	jmp    f01048e6 <_alltraps>

f01048bc <H_STACK>:
TRAPHANDLER     (H_STACK  , T_STACK)
f01048bc:	6a 0c                	push   $0xc
f01048be:	eb 26                	jmp    f01048e6 <_alltraps>

f01048c0 <H_GPFLT>:
TRAPHANDLER     (H_GPFLT  , T_GPFLT)
f01048c0:	6a 0d                	push   $0xd
f01048c2:	eb 22                	jmp    f01048e6 <_alltraps>

f01048c4 <H_PGFLT>:
TRAPHANDLER     (H_PGFLT  , T_PGFLT)
f01048c4:	6a 0e                	push   $0xe
f01048c6:	eb 1e                	jmp    f01048e6 <_alltraps>

f01048c8 <H_FPERR>:
TRAPHANDLER_NOEC(H_FPERR  , T_FPERR)
f01048c8:	6a 00                	push   $0x0
f01048ca:	6a 10                	push   $0x10
f01048cc:	eb 18                	jmp    f01048e6 <_alltraps>

f01048ce <H_ALIGN>:
TRAPHANDLER_NOEC(H_ALIGN  , T_ALIGN)
f01048ce:	6a 00                	push   $0x0
f01048d0:	6a 11                	push   $0x11
f01048d2:	eb 12                	jmp    f01048e6 <_alltraps>

f01048d4 <H_MCHK>:
TRAPHANDLER_NOEC(H_MCHK   , T_MCHK)
f01048d4:	6a 00                	push   $0x0
f01048d6:	6a 12                	push   $0x12
f01048d8:	eb 0c                	jmp    f01048e6 <_alltraps>

f01048da <H_SIMDERR>:
TRAPHANDLER_NOEC(H_SIMDERR, T_SIMDERR)
f01048da:	6a 00                	push   $0x0
f01048dc:	6a 13                	push   $0x13
f01048de:	eb 06                	jmp    f01048e6 <_alltraps>

f01048e0 <H_SYSCALL>:

TRAPHANDLER_NOEC(H_SYSCALL, T_SYSCALL)  // System call.
f01048e0:	6a 00                	push   $0x0
f01048e2:	6a 30                	push   $0x30
f01048e4:	eb 00                	jmp    f01048e6 <_alltraps>

f01048e6 <_alltraps>:

_alltraps:
/* Processor has pushed ss, esp, eflags, cs, eip, and [error] */
/* TRAPHANDLER did [error] and trapno */
	pushl  %ds;
f01048e6:	1e                   	push   %ds
	pushl  %es;
f01048e7:	06                   	push   %es
	pushal;
f01048e8:	60                   	pusha  
	movw   $GD_KD, %ax;
f01048e9:	66 b8 10 00          	mov    $0x10,%ax
	movw   %ax   , %ds;
f01048ed:	8e d8                	mov    %eax,%ds
	movw   %ax   , %es;
f01048ef:	8e c0                	mov    %eax,%es
	pushl  %esp;
f01048f1:	54                   	push   %esp
	call   trap
f01048f2:	e8 4f fd ff ff       	call   f0104646 <trap>

f01048f7 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01048f7:	55                   	push   %ebp
f01048f8:	89 e5                	mov    %esp,%ebp
f01048fa:	83 ec 08             	sub    $0x8,%esp
f01048fd:	a1 48 12 29 f0       	mov    0xf0291248,%eax
f0104902:	83 c0 54             	add    $0x54,%eax
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104905:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f010490a:	8b 10                	mov    (%eax),%edx
f010490c:	4a                   	dec    %edx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010490d:	83 fa 02             	cmp    $0x2,%edx
f0104910:	76 2b                	jbe    f010493d <sched_halt+0x46>
	for (i = 0; i < NENV; i++) {
f0104912:	41                   	inc    %ecx
f0104913:	83 c0 7c             	add    $0x7c,%eax
f0104916:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010491c:	75 ec                	jne    f010490a <sched_halt+0x13>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f010491e:	83 ec 0c             	sub    $0xc,%esp
f0104921:	68 50 81 10 f0       	push   $0xf0108150
f0104926:	e8 4a f6 ff ff       	call   f0103f75 <cprintf>
f010492b:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f010492e:	83 ec 0c             	sub    $0xc,%esp
f0104931:	6a 00                	push   $0x0
f0104933:	e8 cc c4 ff ff       	call   f0100e04 <monitor>
f0104938:	83 c4 10             	add    $0x10,%esp
f010493b:	eb f1                	jmp    f010492e <sched_halt+0x37>
	if (i == NENV) {
f010493d:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104943:	74 d9                	je     f010491e <sched_halt+0x27>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104945:	e8 7c 17 00 00       	call   f01060c6 <cpunum>
f010494a:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010494d:	01 c2                	add    %eax,%edx
f010494f:	01 d2                	add    %edx,%edx
f0104951:	01 c2                	add    %eax,%edx
f0104953:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104956:	c7 04 85 28 20 29 f0 	movl   $0x0,-0xfd6dfd8(,%eax,4)
f010495d:	00 00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104961:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0104966:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010496b:	76 66                	jbe    f01049d3 <sched_halt+0xdc>
	return (physaddr_t)kva - KERNBASE;
f010496d:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104972:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104975:	e8 4c 17 00 00       	call   f01060c6 <cpunum>
f010497a:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010497d:	01 c2                	add    %eax,%edx
f010497f:	01 d2                	add    %edx,%edx
f0104981:	01 c2                	add    %eax,%edx
f0104983:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104986:	8d 14 85 04 00 00 00 	lea    0x4(,%eax,4),%edx
	asm volatile("lock; xchgl %0, %1"
f010498d:	b8 02 00 00 00       	mov    $0x2,%eax
f0104992:	f0 87 82 20 20 29 f0 	lock xchg %eax,-0xfd6dfe0(%edx)
	spin_unlock(&kernel_lock);
f0104999:	83 ec 0c             	sub    $0xc,%esp
f010499c:	68 c0 23 12 f0       	push   $0xf01223c0
f01049a1:	e8 41 1a 00 00       	call   f01063e7 <spin_unlock>
	asm volatile("pause");
f01049a6:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01049a8:	e8 19 17 00 00       	call   f01060c6 <cpunum>
f01049ad:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01049b0:	01 c2                	add    %eax,%edx
f01049b2:	01 d2                	add    %edx,%edx
f01049b4:	01 c2                	add    %eax,%edx
f01049b6:	8d 04 90             	lea    (%eax,%edx,4),%eax
	asm volatile (
f01049b9:	8b 04 85 30 20 29 f0 	mov    -0xfd6dfd0(,%eax,4),%eax
f01049c0:	bd 00 00 00 00       	mov    $0x0,%ebp
f01049c5:	89 c4                	mov    %eax,%esp
f01049c7:	6a 00                	push   $0x0
f01049c9:	6a 00                	push   $0x0
f01049cb:	f4                   	hlt    
f01049cc:	eb fd                	jmp    f01049cb <sched_halt+0xd4>
}
f01049ce:	83 c4 10             	add    $0x10,%esp
f01049d1:	c9                   	leave  
f01049d2:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01049d3:	50                   	push   %eax
f01049d4:	68 6c 68 10 f0       	push   $0xf010686c
f01049d9:	6a 53                	push   $0x53
f01049db:	68 79 81 10 f0       	push   $0xf0108179
f01049e0:	e8 af b6 ff ff       	call   f0100094 <_panic>

f01049e5 <sched_yield>:
{
f01049e5:	55                   	push   %ebp
f01049e6:	89 e5                	mov    %esp,%ebp
f01049e8:	53                   	push   %ebx
f01049e9:	83 ec 04             	sub    $0x4,%esp
	if (!curenv) { 
f01049ec:	e8 d5 16 00 00       	call   f01060c6 <cpunum>
f01049f1:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01049f4:	01 c2                	add    %eax,%edx
f01049f6:	01 d2                	add    %edx,%edx
f01049f8:	01 c2                	add    %eax,%edx
f01049fa:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01049fd:	83 3c 85 28 20 29 f0 	cmpl   $0x0,-0xfd6dfd8(,%eax,4)
f0104a04:	00 
f0104a05:	74 29                	je     f0104a30 <sched_yield+0x4b>
		for (idle = curenv + 1; idle < envs + NENV; idle++)
f0104a07:	e8 ba 16 00 00       	call   f01060c6 <cpunum>
f0104a0c:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104a0f:	01 c2                	add    %eax,%edx
f0104a11:	01 d2                	add    %edx,%edx
f0104a13:	01 c2                	add    %eax,%edx
f0104a15:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104a18:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f0104a1f:	83 c0 7c             	add    $0x7c,%eax
f0104a22:	8b 1d 48 12 29 f0    	mov    0xf0291248,%ebx
f0104a28:	8d 93 00 f0 01 00    	lea    0x1f000(%ebx),%edx
f0104a2e:	eb 26                	jmp    f0104a56 <sched_yield+0x71>
		for (idle = envs; idle < envs + NENV; idle++)
f0104a30:	a1 48 12 29 f0       	mov    0xf0291248,%eax
f0104a35:	8d 90 00 f0 01 00    	lea    0x1f000(%eax),%edx
f0104a3b:	39 d0                	cmp    %edx,%eax
f0104a3d:	74 76                	je     f0104ab5 <sched_yield+0xd0>
			if (idle->env_status == ENV_RUNNABLE)
f0104a3f:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104a43:	74 05                	je     f0104a4a <sched_yield+0x65>
		for (idle = envs; idle < envs + NENV; idle++)
f0104a45:	83 c0 7c             	add    $0x7c,%eax
f0104a48:	eb f1                	jmp    f0104a3b <sched_yield+0x56>
				env_run(idle); // Will not return
f0104a4a:	83 ec 0c             	sub    $0xc,%esp
f0104a4d:	50                   	push   %eax
f0104a4e:	e8 a3 f2 ff ff       	call   f0103cf6 <env_run>
		for (idle = curenv + 1; idle < envs + NENV; idle++)
f0104a53:	83 c0 7c             	add    $0x7c,%eax
f0104a56:	39 c2                	cmp    %eax,%edx
f0104a58:	76 18                	jbe    f0104a72 <sched_yield+0x8d>
			if (idle->env_status == ENV_RUNNABLE)
f0104a5a:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104a5e:	75 f3                	jne    f0104a53 <sched_yield+0x6e>
				env_run(idle); 
f0104a60:	83 ec 0c             	sub    $0xc,%esp
f0104a63:	50                   	push   %eax
f0104a64:	e8 8d f2 ff ff       	call   f0103cf6 <env_run>
				env_run(idle);
f0104a69:	83 ec 0c             	sub    $0xc,%esp
f0104a6c:	53                   	push   %ebx
f0104a6d:	e8 84 f2 ff ff       	call   f0103cf6 <env_run>
		for (idle = envs; idle < curenv ; idle++)
f0104a72:	e8 4f 16 00 00       	call   f01060c6 <cpunum>
f0104a77:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104a7a:	01 c2                	add    %eax,%edx
f0104a7c:	01 d2                	add    %edx,%edx
f0104a7e:	01 c2                	add    %eax,%edx
f0104a80:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104a83:	39 1c 85 28 20 29 f0 	cmp    %ebx,-0xfd6dfd8(,%eax,4)
f0104a8a:	76 0b                	jbe    f0104a97 <sched_yield+0xb2>
			if (idle->env_status == ENV_RUNNABLE)
f0104a8c:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f0104a90:	74 d7                	je     f0104a69 <sched_yield+0x84>
		for (idle = envs; idle < curenv ; idle++)
f0104a92:	83 c3 7c             	add    $0x7c,%ebx
f0104a95:	eb db                	jmp    f0104a72 <sched_yield+0x8d>
		if (curenv->env_status == ENV_RUNNING)
f0104a97:	e8 2a 16 00 00       	call   f01060c6 <cpunum>
f0104a9c:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104a9f:	01 c2                	add    %eax,%edx
f0104aa1:	01 d2                	add    %edx,%edx
f0104aa3:	01 c2                	add    %eax,%edx
f0104aa5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104aa8:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f0104aaf:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104ab3:	74 0a                	je     f0104abf <sched_yield+0xda>
	sched_halt();
f0104ab5:	e8 3d fe ff ff       	call   f01048f7 <sched_halt>
}
f0104aba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104abd:	c9                   	leave  
f0104abe:	c3                   	ret    
			env_run(curenv);
f0104abf:	e8 02 16 00 00       	call   f01060c6 <cpunum>
f0104ac4:	83 ec 0c             	sub    $0xc,%esp
f0104ac7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aca:	ff b0 28 20 29 f0    	pushl  -0xfd6dfd8(%eax)
f0104ad0:	e8 21 f2 ff ff       	call   f0103cf6 <env_run>

f0104ad5 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104ad5:	55                   	push   %ebp
f0104ad6:	89 e5                	mov    %esp,%ebp
f0104ad8:	56                   	push   %esi
f0104ad9:	53                   	push   %ebx
f0104ada:	83 ec 10             	sub    $0x10,%esp
f0104add:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	switch (syscallno) {
f0104ae0:	83 f8 0a             	cmp    $0xa,%eax
f0104ae3:	0f 87 cd 03 00 00    	ja     f0104eb6 <syscall+0x3e1>
f0104ae9:	ff 24 85 c0 81 10 f0 	jmp    *-0xfef7e40(,%eax,4)
	case SYS_cputs:
		user_mem_assert(curenv, (const void*)a1, a2, PTE_U);  // The memory is readable.
f0104af0:	e8 d1 15 00 00       	call   f01060c6 <cpunum>
f0104af5:	6a 04                	push   $0x4
f0104af7:	ff 75 10             	pushl  0x10(%ebp)
f0104afa:	ff 75 0c             	pushl  0xc(%ebp)
f0104afd:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104b00:	01 c2                	add    %eax,%edx
f0104b02:	01 d2                	add    %edx,%edx
f0104b04:	01 c2                	add    %eax,%edx
f0104b06:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104b09:	ff 34 85 28 20 29 f0 	pushl  -0xfd6dfd8(,%eax,4)
f0104b10:	e8 8f e9 ff ff       	call   f01034a4 <user_mem_assert>
	cprintf("%.*s", len, s);
f0104b15:	83 c4 0c             	add    $0xc,%esp
f0104b18:	ff 75 0c             	pushl  0xc(%ebp)
f0104b1b:	ff 75 10             	pushl  0x10(%ebp)
f0104b1e:	68 86 81 10 f0       	push   $0xf0108186
f0104b23:	e8 4d f4 ff ff       	call   f0103f75 <cprintf>
f0104b28:	83 c4 10             	add    $0x10,%esp
		sys_cputs((const char*)a1, a2);
		return 0;
f0104b2b:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();  // Should not return...
		return 0;
	default:
		return -E_INVAL;
	}
}
f0104b30:	89 d8                	mov    %ebx,%eax
f0104b32:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104b35:	5b                   	pop    %ebx
f0104b36:	5e                   	pop    %esi
f0104b37:	5d                   	pop    %ebp
f0104b38:	c3                   	ret    
	return cons_getc();
f0104b39:	e8 80 bb ff ff       	call   f01006be <cons_getc>
f0104b3e:	89 c3                	mov    %eax,%ebx
		return sys_cgetc();
f0104b40:	eb ee                	jmp    f0104b30 <syscall+0x5b>
	return curenv->env_id;
f0104b42:	e8 7f 15 00 00       	call   f01060c6 <cpunum>
f0104b47:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104b4a:	01 c2                	add    %eax,%edx
f0104b4c:	01 d2                	add    %edx,%edx
f0104b4e:	01 c2                	add    %eax,%edx
f0104b50:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104b53:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f0104b5a:	8b 58 48             	mov    0x48(%eax),%ebx
		return sys_getenvid();
f0104b5d:	eb d1                	jmp    f0104b30 <syscall+0x5b>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104b5f:	83 ec 04             	sub    $0x4,%esp
f0104b62:	6a 01                	push   $0x1
f0104b64:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104b67:	50                   	push   %eax
f0104b68:	ff 75 0c             	pushl  0xc(%ebp)
f0104b6b:	e8 80 e9 ff ff       	call   f01034f0 <envid2env>
f0104b70:	89 c3                	mov    %eax,%ebx
f0104b72:	83 c4 10             	add    $0x10,%esp
f0104b75:	85 c0                	test   %eax,%eax
f0104b77:	78 b7                	js     f0104b30 <syscall+0x5b>
	if (e == curenv)
f0104b79:	e8 48 15 00 00       	call   f01060c6 <cpunum>
f0104b7e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
f0104b81:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104b84:	01 c2                	add    %eax,%edx
f0104b86:	01 d2                	add    %edx,%edx
f0104b88:	01 c2                	add    %eax,%edx
f0104b8a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104b8d:	39 0c 85 28 20 29 f0 	cmp    %ecx,-0xfd6dfd8(,%eax,4)
f0104b94:	74 47                	je     f0104bdd <syscall+0x108>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104b96:	8b 59 48             	mov    0x48(%ecx),%ebx
f0104b99:	e8 28 15 00 00       	call   f01060c6 <cpunum>
f0104b9e:	83 ec 04             	sub    $0x4,%esp
f0104ba1:	53                   	push   %ebx
f0104ba2:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104ba5:	01 c2                	add    %eax,%edx
f0104ba7:	01 d2                	add    %edx,%edx
f0104ba9:	01 c2                	add    %eax,%edx
f0104bab:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104bae:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f0104bb5:	ff 70 48             	pushl  0x48(%eax)
f0104bb8:	68 a6 81 10 f0       	push   $0xf01081a6
f0104bbd:	e8 b3 f3 ff ff       	call   f0103f75 <cprintf>
f0104bc2:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104bc5:	83 ec 0c             	sub    $0xc,%esp
f0104bc8:	ff 75 f4             	pushl  -0xc(%ebp)
f0104bcb:	e8 69 f0 ff ff       	call   f0103c39 <env_destroy>
f0104bd0:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104bd3:	bb 00 00 00 00       	mov    $0x0,%ebx
		return sys_env_destroy(a1);
f0104bd8:	e9 53 ff ff ff       	jmp    f0104b30 <syscall+0x5b>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104bdd:	e8 e4 14 00 00       	call   f01060c6 <cpunum>
f0104be2:	83 ec 08             	sub    $0x8,%esp
f0104be5:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104be8:	01 c2                	add    %eax,%edx
f0104bea:	01 d2                	add    %edx,%edx
f0104bec:	01 c2                	add    %eax,%edx
f0104bee:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104bf1:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f0104bf8:	ff 70 48             	pushl  0x48(%eax)
f0104bfb:	68 8b 81 10 f0       	push   $0xf010818b
f0104c00:	e8 70 f3 ff ff       	call   f0103f75 <cprintf>
f0104c05:	83 c4 10             	add    $0x10,%esp
f0104c08:	eb bb                	jmp    f0104bc5 <syscall+0xf0>
	int r = envid2env(envid, &to_env, 1);  // 1 - Check perm
f0104c0a:	83 ec 04             	sub    $0x4,%esp
f0104c0d:	6a 01                	push   $0x1
f0104c0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104c12:	50                   	push   %eax
f0104c13:	ff 75 0c             	pushl  0xc(%ebp)
f0104c16:	e8 d5 e8 ff ff       	call   f01034f0 <envid2env>
f0104c1b:	89 c3                	mov    %eax,%ebx
	if (r)  // -E_BAD_ENV
f0104c1d:	83 c4 10             	add    $0x10,%esp
f0104c20:	85 c0                	test   %eax,%eax
f0104c22:	0f 85 08 ff ff ff    	jne    f0104b30 <syscall+0x5b>
	if ((uintptr_t)va >= UTOP || (uintptr_t)va % PGSIZE)
f0104c28:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104c2f:	77 5b                	ja     f0104c8c <syscall+0x1b7>
f0104c31:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104c38:	75 5c                	jne    f0104c96 <syscall+0x1c1>
	if (
f0104c3a:	f6 45 14 05          	testb  $0x5,0x14(%ebp)
f0104c3e:	74 60                	je     f0104ca0 <syscall+0x1cb>
		!((PTE_U | PTE_P) & perm) || // If we don't have perm U or P
f0104c40:	f7 45 14 f8 f1 ff ff 	testl  $0xfffff1f8,0x14(%ebp)
f0104c47:	75 61                	jne    f0104caa <syscall+0x1d5>
	struct PageInfo* pp = page_alloc(1);
f0104c49:	83 ec 0c             	sub    $0xc,%esp
f0104c4c:	6a 01                	push   $0x1
f0104c4e:	e8 75 c7 ff ff       	call   f01013c8 <page_alloc>
f0104c53:	89 c6                	mov    %eax,%esi
	if (!pp)  // No free memory
f0104c55:	83 c4 10             	add    $0x10,%esp
f0104c58:	85 c0                	test   %eax,%eax
f0104c5a:	74 58                	je     f0104cb4 <syscall+0x1df>
	r = page_insert(to_env->env_pgdir, pp, va, perm);
f0104c5c:	ff 75 14             	pushl  0x14(%ebp)
f0104c5f:	ff 75 10             	pushl  0x10(%ebp)
f0104c62:	50                   	push   %eax
f0104c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104c66:	ff 70 60             	pushl  0x60(%eax)
f0104c69:	e8 b3 ca ff ff       	call   f0101721 <page_insert>
f0104c6e:	89 c3                	mov    %eax,%ebx
	if (r)
f0104c70:	83 c4 10             	add    $0x10,%esp
f0104c73:	85 c0                	test   %eax,%eax
f0104c75:	0f 84 b5 fe ff ff    	je     f0104b30 <syscall+0x5b>
		page_free(pp);
f0104c7b:	83 ec 0c             	sub    $0xc,%esp
f0104c7e:	56                   	push   %esi
f0104c7f:	e8 b6 c7 ff ff       	call   f010143a <page_free>
f0104c84:	83 c4 10             	add    $0x10,%esp
f0104c87:	e9 a4 fe ff ff       	jmp    f0104b30 <syscall+0x5b>
		return -E_INVAL;
f0104c8c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c91:	e9 9a fe ff ff       	jmp    f0104b30 <syscall+0x5b>
f0104c96:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c9b:	e9 90 fe ff ff       	jmp    f0104b30 <syscall+0x5b>
		return -E_INVAL;
f0104ca0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104ca5:	e9 86 fe ff ff       	jmp    f0104b30 <syscall+0x5b>
f0104caa:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104caf:	e9 7c fe ff ff       	jmp    f0104b30 <syscall+0x5b>
		return -E_NO_MEM;
f0104cb4:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
		return sys_page_alloc(a1, (void*)a2, a3);
f0104cb9:	e9 72 fe ff ff       	jmp    f0104b30 <syscall+0x5b>
	r = envid2env(srcenvid, &from_env, 1);  // 1 - Check perm
f0104cbe:	83 ec 04             	sub    $0x4,%esp
f0104cc1:	6a 01                	push   $0x1
f0104cc3:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104cc6:	50                   	push   %eax
f0104cc7:	ff 75 0c             	pushl  0xc(%ebp)
f0104cca:	e8 21 e8 ff ff       	call   f01034f0 <envid2env>
f0104ccf:	89 c3                	mov    %eax,%ebx
	if (r)  return r;
f0104cd1:	83 c4 10             	add    $0x10,%esp
f0104cd4:	85 c0                	test   %eax,%eax
f0104cd6:	0f 85 54 fe ff ff    	jne    f0104b30 <syscall+0x5b>
	r = envid2env(dstenvid, &to_env, 1);  // 1 - Check perm
f0104cdc:	83 ec 04             	sub    $0x4,%esp
f0104cdf:	6a 01                	push   $0x1
f0104ce1:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104ce4:	50                   	push   %eax
f0104ce5:	ff 75 14             	pushl  0x14(%ebp)
f0104ce8:	e8 03 e8 ff ff       	call   f01034f0 <envid2env>
f0104ced:	89 c3                	mov    %eax,%ebx
	if (r)  return r;
f0104cef:	83 c4 10             	add    $0x10,%esp
f0104cf2:	85 c0                	test   %eax,%eax
f0104cf4:	0f 85 36 fe ff ff    	jne    f0104b30 <syscall+0x5b>
	if (
f0104cfa:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104d01:	77 6c                	ja     f0104d6f <syscall+0x29a>
		((uintptr_t)srcva >= UTOP || (uintptr_t)srcva % PGSIZE) || 
f0104d03:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104d0a:	75 6d                	jne    f0104d79 <syscall+0x2a4>
f0104d0c:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104d13:	77 6e                	ja     f0104d83 <syscall+0x2ae>
		((uintptr_t)dstva >= UTOP || (uintptr_t)dstva % PGSIZE))
f0104d15:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104d1c:	75 6f                	jne    f0104d8d <syscall+0x2b8>
	if (
f0104d1e:	f6 45 1c 05          	testb  $0x5,0x1c(%ebp)
f0104d22:	74 73                	je     f0104d97 <syscall+0x2c2>
		!((PTE_U | PTE_P) & perm) || // If we don't have perm U or P
f0104d24:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f0104d2b:	75 74                	jne    f0104da1 <syscall+0x2cc>
	struct PageInfo* pp = page_lookup(from_env->env_pgdir, srcva, &src_pgt);
f0104d2d:	83 ec 04             	sub    $0x4,%esp
f0104d30:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104d33:	50                   	push   %eax
f0104d34:	ff 75 10             	pushl  0x10(%ebp)
f0104d37:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104d3a:	ff 70 60             	pushl  0x60(%eax)
f0104d3d:	e8 d6 c8 ff ff       	call   f0101618 <page_lookup>
	if ((~*src_pgt & PTE_W) && (perm & PTE_W))
f0104d42:	83 c4 10             	add    $0x10,%esp
f0104d45:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104d48:	f6 02 02             	testb  $0x2,(%edx)
f0104d4b:	75 06                	jne    f0104d53 <syscall+0x27e>
f0104d4d:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104d51:	75 58                	jne    f0104dab <syscall+0x2d6>
	r = page_insert(to_env->env_pgdir, pp, dstva, perm);
f0104d53:	ff 75 1c             	pushl  0x1c(%ebp)
f0104d56:	ff 75 18             	pushl  0x18(%ebp)
f0104d59:	50                   	push   %eax
f0104d5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104d5d:	ff 70 60             	pushl  0x60(%eax)
f0104d60:	e8 bc c9 ff ff       	call   f0101721 <page_insert>
f0104d65:	89 c3                	mov    %eax,%ebx
f0104d67:	83 c4 10             	add    $0x10,%esp
f0104d6a:	e9 c1 fd ff ff       	jmp    f0104b30 <syscall+0x5b>
		return -E_INVAL;
f0104d6f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d74:	e9 b7 fd ff ff       	jmp    f0104b30 <syscall+0x5b>
f0104d79:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d7e:	e9 ad fd ff ff       	jmp    f0104b30 <syscall+0x5b>
f0104d83:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d88:	e9 a3 fd ff ff       	jmp    f0104b30 <syscall+0x5b>
f0104d8d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d92:	e9 99 fd ff ff       	jmp    f0104b30 <syscall+0x5b>
		return -E_INVAL;
f0104d97:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d9c:	e9 8f fd ff ff       	jmp    f0104b30 <syscall+0x5b>
f0104da1:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104da6:	e9 85 fd ff ff       	jmp    f0104b30 <syscall+0x5b>
		return -E_INVAL;
f0104dab:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
f0104db0:	e9 7b fd ff ff       	jmp    f0104b30 <syscall+0x5b>
	int r = envid2env(envid, &to_env, 1);  // 1 - Check perm
f0104db5:	83 ec 04             	sub    $0x4,%esp
f0104db8:	6a 01                	push   $0x1
f0104dba:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104dbd:	50                   	push   %eax
f0104dbe:	ff 75 0c             	pushl  0xc(%ebp)
f0104dc1:	e8 2a e7 ff ff       	call   f01034f0 <envid2env>
	if (r)  // -E_BAD_ENV
f0104dc6:	83 c4 10             	add    $0x10,%esp
f0104dc9:	85 c0                	test   %eax,%eax
f0104dcb:	75 26                	jne    f0104df3 <syscall+0x31e>
	if ((uintptr_t)va >= UTOP || (uintptr_t)va % PGSIZE)
f0104dcd:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104dd4:	77 1d                	ja     f0104df3 <syscall+0x31e>
f0104dd6:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104ddd:	75 14                	jne    f0104df3 <syscall+0x31e>
	page_remove(to_env->env_pgdir, va);
f0104ddf:	83 ec 08             	sub    $0x8,%esp
f0104de2:	ff 75 10             	pushl  0x10(%ebp)
f0104de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104de8:	ff 70 60             	pushl  0x60(%eax)
f0104deb:	e8 d7 c8 ff ff       	call   f01016c7 <page_remove>
f0104df0:	83 c4 10             	add    $0x10,%esp
		return 0;
f0104df3:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104df8:	e9 33 fd ff ff       	jmp    f0104b30 <syscall+0x5b>
	int r = env_alloc(&newenv, curenv->env_id);
f0104dfd:	e8 c4 12 00 00       	call   f01060c6 <cpunum>
f0104e02:	83 ec 08             	sub    $0x8,%esp
f0104e05:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104e08:	01 c2                	add    %eax,%edx
f0104e0a:	01 d2                	add    %edx,%edx
f0104e0c:	01 c2                	add    %eax,%edx
f0104e0e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e11:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f0104e18:	ff 70 48             	pushl  0x48(%eax)
f0104e1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104e1e:	50                   	push   %eax
f0104e1f:	e8 fa e7 ff ff       	call   f010361e <env_alloc>
f0104e24:	89 c3                	mov    %eax,%ebx
	if (r)  // Some error
f0104e26:	83 c4 10             	add    $0x10,%esp
f0104e29:	85 c0                	test   %eax,%eax
f0104e2b:	0f 85 ff fc ff ff    	jne    f0104b30 <syscall+0x5b>
	newenv->env_status = ENV_NOT_RUNNABLE;
f0104e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104e34:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	memcpy(&newenv->env_tf, &curenv->env_tf, sizeof(struct Trapframe));
f0104e3b:	e8 86 12 00 00       	call   f01060c6 <cpunum>
f0104e40:	83 ec 04             	sub    $0x4,%esp
f0104e43:	6a 44                	push   $0x44
f0104e45:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104e48:	01 c2                	add    %eax,%edx
f0104e4a:	01 d2                	add    %edx,%edx
f0104e4c:	01 c2                	add    %eax,%edx
f0104e4e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e51:	ff 34 85 28 20 29 f0 	pushl  -0xfd6dfd8(,%eax,4)
f0104e58:	ff 75 f4             	pushl  -0xc(%ebp)
f0104e5b:	e8 41 0c 00 00       	call   f0105aa1 <memcpy>
	newenv->env_tf.tf_regs.reg_eax = 0;
f0104e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104e63:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return newenv->env_id;
f0104e6a:	8b 58 48             	mov    0x48(%eax),%ebx
f0104e6d:	83 c4 10             	add    $0x10,%esp
		return sys_exofork();
f0104e70:	e9 bb fc ff ff       	jmp    f0104b30 <syscall+0x5b>
	int r = envid2env(envid, &to_env, 1);  // 1 - Check perm
f0104e75:	83 ec 04             	sub    $0x4,%esp
f0104e78:	6a 01                	push   $0x1
f0104e7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104e7d:	50                   	push   %eax
f0104e7e:	ff 75 0c             	pushl  0xc(%ebp)
f0104e81:	e8 6a e6 ff ff       	call   f01034f0 <envid2env>
f0104e86:	89 c3                	mov    %eax,%ebx
	if (r)  // -E_BAD_ENV
f0104e88:	83 c4 10             	add    $0x10,%esp
f0104e8b:	85 c0                	test   %eax,%eax
f0104e8d:	0f 85 9d fc ff ff    	jne    f0104b30 <syscall+0x5b>
	if (status > ENV_NOT_RUNNABLE || status < 0) 
f0104e93:	83 7d 10 04          	cmpl   $0x4,0x10(%ebp)
f0104e97:	77 0e                	ja     f0104ea7 <syscall+0x3d2>
	to_env->env_status = status;
f0104e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104e9c:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104e9f:	89 48 54             	mov    %ecx,0x54(%eax)
f0104ea2:	e9 89 fc ff ff       	jmp    f0104b30 <syscall+0x5b>
		return -E_INVAL;
f0104ea7:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		return sys_env_set_status(a1, a2);
f0104eac:	e9 7f fc ff ff       	jmp    f0104b30 <syscall+0x5b>
	sched_yield();
f0104eb1:	e8 2f fb ff ff       	call   f01049e5 <sched_yield>
		return -E_INVAL;
f0104eb6:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104ebb:	e9 70 fc ff ff       	jmp    f0104b30 <syscall+0x5b>

f0104ec0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104ec0:	55                   	push   %ebp
f0104ec1:	89 e5                	mov    %esp,%ebp
f0104ec3:	57                   	push   %edi
f0104ec4:	56                   	push   %esi
f0104ec5:	53                   	push   %ebx
f0104ec6:	83 ec 14             	sub    $0x14,%esp
f0104ec9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104ecc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104ecf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104ed2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104ed5:	8b 32                	mov    (%edx),%esi
f0104ed7:	8b 01                	mov    (%ecx),%eax
f0104ed9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104edc:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104ee3:	eb 2f                	jmp    f0104f14 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0104ee5:	48                   	dec    %eax
		while (m >= l && stabs[m].n_type != type)
f0104ee6:	39 c6                	cmp    %eax,%esi
f0104ee8:	7f 4d                	jg     f0104f37 <stab_binsearch+0x77>
f0104eea:	0f b6 0a             	movzbl (%edx),%ecx
f0104eed:	83 ea 0c             	sub    $0xc,%edx
f0104ef0:	39 f9                	cmp    %edi,%ecx
f0104ef2:	75 f1                	jne    f0104ee5 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104ef4:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104ef7:	01 c2                	add    %eax,%edx
f0104ef9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104efc:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104f00:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104f03:	73 37                	jae    f0104f3c <stab_binsearch+0x7c>
			*region_left = m;
f0104f05:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104f08:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0104f0a:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0104f0d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104f14:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0104f17:	7f 4d                	jg     f0104f66 <stab_binsearch+0xa6>
		int true_m = (l + r) / 2, m = true_m;
f0104f19:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104f1c:	01 f0                	add    %esi,%eax
f0104f1e:	89 c3                	mov    %eax,%ebx
f0104f20:	c1 eb 1f             	shr    $0x1f,%ebx
f0104f23:	01 c3                	add    %eax,%ebx
f0104f25:	d1 fb                	sar    %ebx
f0104f27:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0104f2a:	01 d8                	add    %ebx,%eax
f0104f2c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104f2f:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104f33:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0104f35:	eb af                	jmp    f0104ee6 <stab_binsearch+0x26>
			l = true_m + 1;
f0104f37:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0104f3a:	eb d8                	jmp    f0104f14 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0104f3c:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104f3f:	76 12                	jbe    f0104f53 <stab_binsearch+0x93>
			*region_right = m - 1;
f0104f41:	48                   	dec    %eax
f0104f42:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104f45:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104f48:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0104f4a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104f51:	eb c1                	jmp    f0104f14 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104f53:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104f56:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104f58:	ff 45 0c             	incl   0xc(%ebp)
f0104f5b:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0104f5d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104f64:	eb ae                	jmp    f0104f14 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0104f66:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104f6a:	74 18                	je     f0104f84 <stab_binsearch+0xc4>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104f6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104f6f:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104f71:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104f74:	8b 0e                	mov    (%esi),%ecx
f0104f76:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104f79:	01 c2                	add    %eax,%edx
f0104f7b:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104f7e:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0104f82:	eb 0e                	jmp    f0104f92 <stab_binsearch+0xd2>
		*region_right = *region_left - 1;
f0104f84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f87:	8b 00                	mov    (%eax),%eax
f0104f89:	48                   	dec    %eax
f0104f8a:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104f8d:	89 07                	mov    %eax,(%edi)
f0104f8f:	eb 14                	jmp    f0104fa5 <stab_binsearch+0xe5>
		     l--)
f0104f91:	48                   	dec    %eax
		for (l = *region_right;
f0104f92:	39 c1                	cmp    %eax,%ecx
f0104f94:	7d 0a                	jge    f0104fa0 <stab_binsearch+0xe0>
		     l > *region_left && stabs[l].n_type != type;
f0104f96:	0f b6 1a             	movzbl (%edx),%ebx
f0104f99:	83 ea 0c             	sub    $0xc,%edx
f0104f9c:	39 fb                	cmp    %edi,%ebx
f0104f9e:	75 f1                	jne    f0104f91 <stab_binsearch+0xd1>
			/* do nothing */;
		*region_left = l;
f0104fa0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104fa3:	89 07                	mov    %eax,(%edi)
	}
}
f0104fa5:	83 c4 14             	add    $0x14,%esp
f0104fa8:	5b                   	pop    %ebx
f0104fa9:	5e                   	pop    %esi
f0104faa:	5f                   	pop    %edi
f0104fab:	5d                   	pop    %ebp
f0104fac:	c3                   	ret    

f0104fad <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104fad:	55                   	push   %ebp
f0104fae:	89 e5                	mov    %esp,%ebp
f0104fb0:	57                   	push   %edi
f0104fb1:	56                   	push   %esi
f0104fb2:	53                   	push   %ebx
f0104fb3:	83 ec 4c             	sub    $0x4c,%esp
f0104fb6:	8b 75 08             	mov    0x8(%ebp),%esi
f0104fb9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104fbc:	c7 03 ec 81 10 f0    	movl   $0xf01081ec,(%ebx)
	info->eip_line = 0;
f0104fc2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104fc9:	c7 43 08 ec 81 10 f0 	movl   $0xf01081ec,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104fd0:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104fd7:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104fda:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104fe1:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104fe7:	77 1e                	ja     f0105007 <debuginfo_eip+0x5a>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104fe9:	8b 3d 00 00 20 00    	mov    0x200000,%edi
		stab_end = usd->stab_end;
f0104fef:	8b 15 04 00 20 00    	mov    0x200004,%edx
		stabstr = usd->stabstr;
f0104ff5:	a1 08 00 20 00       	mov    0x200008,%eax
f0104ffa:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0104ffd:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0105002:	89 45 b8             	mov    %eax,-0x48(%ebp)
f0105005:	eb 18                	jmp    f010501f <debuginfo_eip+0x72>
		stabstr_end = __STABSTR_END__;
f0105007:	c7 45 b8 b9 7a 11 f0 	movl   $0xf0117ab9,-0x48(%ebp)
		stabstr = __STABSTR_BEGIN__;
f010500e:	c7 45 b4 9d 42 11 f0 	movl   $0xf011429d,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0105015:	ba 9c 42 11 f0       	mov    $0xf011429c,%edx
		stabs = __STAB_BEGIN__;
f010501a:	bf d4 86 10 f0       	mov    $0xf01086d4,%edi
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010501f:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0105022:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
f0105025:	0f 83 9b 01 00 00    	jae    f01051c6 <debuginfo_eip+0x219>
f010502b:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f010502f:	0f 85 98 01 00 00    	jne    f01051cd <debuginfo_eip+0x220>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105035:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010503c:	29 fa                	sub    %edi,%edx
f010503e:	c1 fa 02             	sar    $0x2,%edx
f0105041:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0105044:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0105047:	8d 04 82             	lea    (%edx,%eax,4),%eax
f010504a:	89 c1                	mov    %eax,%ecx
f010504c:	c1 e1 08             	shl    $0x8,%ecx
f010504f:	01 c8                	add    %ecx,%eax
f0105051:	89 c1                	mov    %eax,%ecx
f0105053:	c1 e1 10             	shl    $0x10,%ecx
f0105056:	01 c8                	add    %ecx,%eax
f0105058:	01 c0                	add    %eax,%eax
f010505a:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
f010505e:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105061:	56                   	push   %esi
f0105062:	6a 64                	push   $0x64
f0105064:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105067:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010506a:	89 f8                	mov    %edi,%eax
f010506c:	e8 4f fe ff ff       	call   f0104ec0 <stab_binsearch>
	if (lfile == 0)
f0105071:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105074:	83 c4 08             	add    $0x8,%esp
f0105077:	85 c0                	test   %eax,%eax
f0105079:	0f 84 55 01 00 00    	je     f01051d4 <debuginfo_eip+0x227>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010507f:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105082:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105085:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105088:	56                   	push   %esi
f0105089:	6a 24                	push   $0x24
f010508b:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010508e:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105091:	89 f8                	mov    %edi,%eax
f0105093:	e8 28 fe ff ff       	call   f0104ec0 <stab_binsearch>

	if (lfun <= rfun) {
f0105098:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010509b:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f010509e:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f01050a1:	83 c4 08             	add    $0x8,%esp
f01050a4:	39 c8                	cmp    %ecx,%eax
f01050a6:	0f 8f 80 00 00 00    	jg     f010512c <debuginfo_eip+0x17f>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01050ac:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01050af:	01 c2                	add    %eax,%edx
f01050b1:	8d 14 97             	lea    (%edi,%edx,4),%edx
f01050b4:	89 55 c0             	mov    %edx,-0x40(%ebp)
f01050b7:	8b 0a                	mov    (%edx),%ecx
f01050b9:	89 4d bc             	mov    %ecx,-0x44(%ebp)
f01050bc:	8b 55 b8             	mov    -0x48(%ebp),%edx
f01050bf:	2b 55 b4             	sub    -0x4c(%ebp),%edx
f01050c2:	39 d1                	cmp    %edx,%ecx
f01050c4:	73 06                	jae    f01050cc <debuginfo_eip+0x11f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01050c6:	03 4d b4             	add    -0x4c(%ebp),%ecx
f01050c9:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01050cc:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01050cf:	8b 51 08             	mov    0x8(%ecx),%edx
f01050d2:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01050d5:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01050d7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01050da:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01050dd:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01050e0:	83 ec 08             	sub    $0x8,%esp
f01050e3:	6a 3a                	push   $0x3a
f01050e5:	ff 73 08             	pushl  0x8(%ebx)
f01050e8:	e8 e9 08 00 00       	call   f01059d6 <strfind>
f01050ed:	2b 43 08             	sub    0x8(%ebx),%eax
f01050f0:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// N_SLINE represents text segment
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01050f3:	83 c4 08             	add    $0x8,%esp
f01050f6:	56                   	push   %esi
f01050f7:	6a 44                	push   $0x44
f01050f9:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01050fc:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01050ff:	89 f8                	mov    %edi,%eax
f0105101:	e8 ba fd ff ff       	call   f0104ec0 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0105106:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105109:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010510c:	01 c2                	add    %eax,%edx
f010510e:	c1 e2 02             	shl    $0x2,%edx
f0105111:	0f b7 4c 17 06       	movzwl 0x6(%edi,%edx,1),%ecx
f0105116:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105119:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010511c:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f010511f:	8d 54 17 04          	lea    0x4(%edi,%edx,1),%edx
f0105123:	83 c4 10             	add    $0x10,%esp
f0105126:	c6 45 c0 00          	movb   $0x0,-0x40(%ebp)
f010512a:	eb 19                	jmp    f0105145 <debuginfo_eip+0x198>
		info->eip_fn_addr = addr;
f010512c:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010512f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105132:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105135:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105138:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010513b:	eb a3                	jmp    f01050e0 <debuginfo_eip+0x133>
f010513d:	48                   	dec    %eax
f010513e:	83 ea 0c             	sub    $0xc,%edx
f0105141:	c6 45 c0 01          	movb   $0x1,-0x40(%ebp)
f0105145:	89 45 bc             	mov    %eax,-0x44(%ebp)
	while (lline >= lfile
f0105148:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f010514b:	7f 40                	jg     f010518d <debuginfo_eip+0x1e0>
	       && stabs[lline].n_type != N_SOL
f010514d:	8a 0a                	mov    (%edx),%cl
f010514f:	80 f9 84             	cmp    $0x84,%cl
f0105152:	74 19                	je     f010516d <debuginfo_eip+0x1c0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105154:	80 f9 64             	cmp    $0x64,%cl
f0105157:	75 e4                	jne    f010513d <debuginfo_eip+0x190>
f0105159:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f010515d:	74 de                	je     f010513d <debuginfo_eip+0x190>
f010515f:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f0105163:	74 0e                	je     f0105173 <debuginfo_eip+0x1c6>
f0105165:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0105168:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010516b:	eb 06                	jmp    f0105173 <debuginfo_eip+0x1c6>
f010516d:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f0105171:	75 35                	jne    f01051a8 <debuginfo_eip+0x1fb>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105173:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0105176:	01 d0                	add    %edx,%eax
f0105178:	8b 14 87             	mov    (%edi,%eax,4),%edx
f010517b:	8b 45 b8             	mov    -0x48(%ebp),%eax
f010517e:	8b 75 b4             	mov    -0x4c(%ebp),%esi
f0105181:	29 f0                	sub    %esi,%eax
f0105183:	39 c2                	cmp    %eax,%edx
f0105185:	73 06                	jae    f010518d <debuginfo_eip+0x1e0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105187:	89 f0                	mov    %esi,%eax
f0105189:	01 d0                	add    %edx,%eax
f010518b:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010518d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105190:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0105193:	39 f2                	cmp    %esi,%edx
f0105195:	7d 44                	jge    f01051db <debuginfo_eip+0x22e>
		for (lline = lfun + 1;
f0105197:	42                   	inc    %edx
f0105198:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010519b:	89 d0                	mov    %edx,%eax
f010519d:	8d 0c 12             	lea    (%edx,%edx,1),%ecx
f01051a0:	01 ca                	add    %ecx,%edx
f01051a2:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f01051a6:	eb 08                	jmp    f01051b0 <debuginfo_eip+0x203>
f01051a8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01051ab:	eb c6                	jmp    f0105173 <debuginfo_eip+0x1c6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01051ad:	ff 43 14             	incl   0x14(%ebx)
		for (lline = lfun + 1;
f01051b0:	39 c6                	cmp    %eax,%esi
f01051b2:	7e 34                	jle    f01051e8 <debuginfo_eip+0x23b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01051b4:	8a 0a                	mov    (%edx),%cl
f01051b6:	40                   	inc    %eax
f01051b7:	83 c2 0c             	add    $0xc,%edx
f01051ba:	80 f9 a0             	cmp    $0xa0,%cl
f01051bd:	74 ee                	je     f01051ad <debuginfo_eip+0x200>

	return 0;
f01051bf:	b8 00 00 00 00       	mov    $0x0,%eax
f01051c4:	eb 1a                	jmp    f01051e0 <debuginfo_eip+0x233>
		return -1;
f01051c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01051cb:	eb 13                	jmp    f01051e0 <debuginfo_eip+0x233>
f01051cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01051d2:	eb 0c                	jmp    f01051e0 <debuginfo_eip+0x233>
		return -1;
f01051d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01051d9:	eb 05                	jmp    f01051e0 <debuginfo_eip+0x233>
	return 0;
f01051db:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01051e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01051e3:	5b                   	pop    %ebx
f01051e4:	5e                   	pop    %esi
f01051e5:	5f                   	pop    %edi
f01051e6:	5d                   	pop    %ebp
f01051e7:	c3                   	ret    
	return 0;
f01051e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01051ed:	eb f1                	jmp    f01051e0 <debuginfo_eip+0x233>

f01051ef <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01051ef:	55                   	push   %ebp
f01051f0:	89 e5                	mov    %esp,%ebp
f01051f2:	57                   	push   %edi
f01051f3:	56                   	push   %esi
f01051f4:	53                   	push   %ebx
f01051f5:	83 ec 1c             	sub    $0x1c,%esp
f01051f8:	89 c7                	mov    %eax,%edi
f01051fa:	89 d6                	mov    %edx,%esi
f01051fc:	8b 45 08             	mov    0x8(%ebp),%eax
f01051ff:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105202:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105205:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105208:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010520b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105210:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105213:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0105216:	39 d3                	cmp    %edx,%ebx
f0105218:	72 05                	jb     f010521f <printnum+0x30>
f010521a:	39 45 10             	cmp    %eax,0x10(%ebp)
f010521d:	77 78                	ja     f0105297 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010521f:	83 ec 0c             	sub    $0xc,%esp
f0105222:	ff 75 18             	pushl  0x18(%ebp)
f0105225:	8b 45 14             	mov    0x14(%ebp),%eax
f0105228:	8d 58 ff             	lea    -0x1(%eax),%ebx
f010522b:	53                   	push   %ebx
f010522c:	ff 75 10             	pushl  0x10(%ebp)
f010522f:	83 ec 08             	sub    $0x8,%esp
f0105232:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105235:	ff 75 e0             	pushl  -0x20(%ebp)
f0105238:	ff 75 dc             	pushl  -0x24(%ebp)
f010523b:	ff 75 d8             	pushl  -0x28(%ebp)
f010523e:	e8 99 12 00 00       	call   f01064dc <__udivdi3>
f0105243:	83 c4 18             	add    $0x18,%esp
f0105246:	52                   	push   %edx
f0105247:	50                   	push   %eax
f0105248:	89 f2                	mov    %esi,%edx
f010524a:	89 f8                	mov    %edi,%eax
f010524c:	e8 9e ff ff ff       	call   f01051ef <printnum>
f0105251:	83 c4 20             	add    $0x20,%esp
f0105254:	eb 11                	jmp    f0105267 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105256:	83 ec 08             	sub    $0x8,%esp
f0105259:	56                   	push   %esi
f010525a:	ff 75 18             	pushl  0x18(%ebp)
f010525d:	ff d7                	call   *%edi
f010525f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0105262:	4b                   	dec    %ebx
f0105263:	85 db                	test   %ebx,%ebx
f0105265:	7f ef                	jg     f0105256 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105267:	83 ec 08             	sub    $0x8,%esp
f010526a:	56                   	push   %esi
f010526b:	83 ec 04             	sub    $0x4,%esp
f010526e:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105271:	ff 75 e0             	pushl  -0x20(%ebp)
f0105274:	ff 75 dc             	pushl  -0x24(%ebp)
f0105277:	ff 75 d8             	pushl  -0x28(%ebp)
f010527a:	e8 5d 13 00 00       	call   f01065dc <__umoddi3>
f010527f:	83 c4 14             	add    $0x14,%esp
f0105282:	0f be 80 f6 81 10 f0 	movsbl -0xfef7e0a(%eax),%eax
f0105289:	50                   	push   %eax
f010528a:	ff d7                	call   *%edi
}
f010528c:	83 c4 10             	add    $0x10,%esp
f010528f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105292:	5b                   	pop    %ebx
f0105293:	5e                   	pop    %esi
f0105294:	5f                   	pop    %edi
f0105295:	5d                   	pop    %ebp
f0105296:	c3                   	ret    
f0105297:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010529a:	eb c6                	jmp    f0105262 <printnum+0x73>

f010529c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010529c:	55                   	push   %ebp
f010529d:	89 e5                	mov    %esp,%ebp
f010529f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01052a2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f01052a5:	8b 10                	mov    (%eax),%edx
f01052a7:	3b 50 04             	cmp    0x4(%eax),%edx
f01052aa:	73 0a                	jae    f01052b6 <sprintputch+0x1a>
		*b->buf++ = ch;
f01052ac:	8d 4a 01             	lea    0x1(%edx),%ecx
f01052af:	89 08                	mov    %ecx,(%eax)
f01052b1:	8b 45 08             	mov    0x8(%ebp),%eax
f01052b4:	88 02                	mov    %al,(%edx)
}
f01052b6:	5d                   	pop    %ebp
f01052b7:	c3                   	ret    

f01052b8 <printfmt>:
{
f01052b8:	55                   	push   %ebp
f01052b9:	89 e5                	mov    %esp,%ebp
f01052bb:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01052be:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01052c1:	50                   	push   %eax
f01052c2:	ff 75 10             	pushl  0x10(%ebp)
f01052c5:	ff 75 0c             	pushl  0xc(%ebp)
f01052c8:	ff 75 08             	pushl  0x8(%ebp)
f01052cb:	e8 05 00 00 00       	call   f01052d5 <vprintfmt>
}
f01052d0:	83 c4 10             	add    $0x10,%esp
f01052d3:	c9                   	leave  
f01052d4:	c3                   	ret    

f01052d5 <vprintfmt>:
{
f01052d5:	55                   	push   %ebp
f01052d6:	89 e5                	mov    %esp,%ebp
f01052d8:	57                   	push   %edi
f01052d9:	56                   	push   %esi
f01052da:	53                   	push   %ebx
f01052db:	83 ec 2c             	sub    $0x2c,%esp
f01052de:	8b 75 08             	mov    0x8(%ebp),%esi
f01052e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01052e4:	8b 7d 10             	mov    0x10(%ebp),%edi
f01052e7:	e9 ac 03 00 00       	jmp    f0105698 <vprintfmt+0x3c3>
		padc = ' ';
f01052ec:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f01052f0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f01052f7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f01052fe:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0105305:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f010530a:	8d 47 01             	lea    0x1(%edi),%eax
f010530d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105310:	8a 17                	mov    (%edi),%dl
f0105312:	8d 42 dd             	lea    -0x23(%edx),%eax
f0105315:	3c 55                	cmp    $0x55,%al
f0105317:	0f 87 fc 03 00 00    	ja     f0105719 <vprintfmt+0x444>
f010531d:	0f b6 c0             	movzbl %al,%eax
f0105320:	ff 24 85 c0 82 10 f0 	jmp    *-0xfef7d40(,%eax,4)
f0105327:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f010532a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f010532e:	eb da                	jmp    f010530a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0105330:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0105333:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0105337:	eb d1                	jmp    f010530a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0105339:	0f b6 d2             	movzbl %dl,%edx
f010533c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f010533f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105344:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0105347:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010534a:	01 c0                	add    %eax,%eax
f010534c:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
f0105350:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0105353:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0105356:	83 f9 09             	cmp    $0x9,%ecx
f0105359:	77 52                	ja     f01053ad <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
f010535b:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
f010535c:	eb e9                	jmp    f0105347 <vprintfmt+0x72>
			precision = va_arg(ap, int);
f010535e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105361:	8b 00                	mov    (%eax),%eax
f0105363:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105366:	8b 45 14             	mov    0x14(%ebp),%eax
f0105369:	8d 40 04             	lea    0x4(%eax),%eax
f010536c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010536f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0105372:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105376:	79 92                	jns    f010530a <vprintfmt+0x35>
				width = precision, precision = -1;
f0105378:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010537b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010537e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105385:	eb 83                	jmp    f010530a <vprintfmt+0x35>
f0105387:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010538b:	78 08                	js     f0105395 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
f010538d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105390:	e9 75 ff ff ff       	jmp    f010530a <vprintfmt+0x35>
f0105395:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010539c:	eb ef                	jmp    f010538d <vprintfmt+0xb8>
f010539e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f01053a1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01053a8:	e9 5d ff ff ff       	jmp    f010530a <vprintfmt+0x35>
f01053ad:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01053b0:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01053b3:	eb bd                	jmp    f0105372 <vprintfmt+0x9d>
			lflag++;
f01053b5:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
f01053b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01053b9:	e9 4c ff ff ff       	jmp    f010530a <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f01053be:	8b 45 14             	mov    0x14(%ebp),%eax
f01053c1:	8d 78 04             	lea    0x4(%eax),%edi
f01053c4:	83 ec 08             	sub    $0x8,%esp
f01053c7:	53                   	push   %ebx
f01053c8:	ff 30                	pushl  (%eax)
f01053ca:	ff d6                	call   *%esi
			break;
f01053cc:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01053cf:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01053d2:	e9 be 02 00 00       	jmp    f0105695 <vprintfmt+0x3c0>
			err = va_arg(ap, int);
f01053d7:	8b 45 14             	mov    0x14(%ebp),%eax
f01053da:	8d 78 04             	lea    0x4(%eax),%edi
f01053dd:	8b 00                	mov    (%eax),%eax
f01053df:	85 c0                	test   %eax,%eax
f01053e1:	78 2a                	js     f010540d <vprintfmt+0x138>
f01053e3:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01053e5:	83 f8 08             	cmp    $0x8,%eax
f01053e8:	7f 27                	jg     f0105411 <vprintfmt+0x13c>
f01053ea:	8b 04 85 20 84 10 f0 	mov    -0xfef7be0(,%eax,4),%eax
f01053f1:	85 c0                	test   %eax,%eax
f01053f3:	74 1c                	je     f0105411 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
f01053f5:	50                   	push   %eax
f01053f6:	68 55 79 10 f0       	push   $0xf0107955
f01053fb:	53                   	push   %ebx
f01053fc:	56                   	push   %esi
f01053fd:	e8 b6 fe ff ff       	call   f01052b8 <printfmt>
f0105402:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105405:	89 7d 14             	mov    %edi,0x14(%ebp)
f0105408:	e9 88 02 00 00       	jmp    f0105695 <vprintfmt+0x3c0>
f010540d:	f7 d8                	neg    %eax
f010540f:	eb d2                	jmp    f01053e3 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
f0105411:	52                   	push   %edx
f0105412:	68 0e 82 10 f0       	push   $0xf010820e
f0105417:	53                   	push   %ebx
f0105418:	56                   	push   %esi
f0105419:	e8 9a fe ff ff       	call   f01052b8 <printfmt>
f010541e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105421:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0105424:	e9 6c 02 00 00       	jmp    f0105695 <vprintfmt+0x3c0>
			if ((p = va_arg(ap, char *)) == NULL)
f0105429:	8b 45 14             	mov    0x14(%ebp),%eax
f010542c:	83 c0 04             	add    $0x4,%eax
f010542f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0105432:	8b 45 14             	mov    0x14(%ebp),%eax
f0105435:	8b 38                	mov    (%eax),%edi
f0105437:	85 ff                	test   %edi,%edi
f0105439:	74 18                	je     f0105453 <vprintfmt+0x17e>
			if (width > 0 && padc != '-')
f010543b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010543f:	0f 8e b7 00 00 00    	jle    f01054fc <vprintfmt+0x227>
f0105445:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0105449:	75 0f                	jne    f010545a <vprintfmt+0x185>
f010544b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010544e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0105451:	eb 6e                	jmp    f01054c1 <vprintfmt+0x1ec>
				p = "(null)";
f0105453:	bf 07 82 10 f0       	mov    $0xf0108207,%edi
f0105458:	eb e1                	jmp    f010543b <vprintfmt+0x166>
				for (width -= strnlen(p, precision); width > 0; width--)
f010545a:	83 ec 08             	sub    $0x8,%esp
f010545d:	ff 75 d0             	pushl  -0x30(%ebp)
f0105460:	57                   	push   %edi
f0105461:	e8 45 04 00 00       	call   f01058ab <strnlen>
f0105466:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105469:	29 c1                	sub    %eax,%ecx
f010546b:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f010546e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105471:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105475:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105478:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010547b:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f010547d:	eb 0d                	jmp    f010548c <vprintfmt+0x1b7>
					putch(padc, putdat);
f010547f:	83 ec 08             	sub    $0x8,%esp
f0105482:	53                   	push   %ebx
f0105483:	ff 75 e0             	pushl  -0x20(%ebp)
f0105486:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0105488:	4f                   	dec    %edi
f0105489:	83 c4 10             	add    $0x10,%esp
f010548c:	85 ff                	test   %edi,%edi
f010548e:	7f ef                	jg     f010547f <vprintfmt+0x1aa>
f0105490:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105493:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0105496:	89 c8                	mov    %ecx,%eax
f0105498:	85 c9                	test   %ecx,%ecx
f010549a:	78 59                	js     f01054f5 <vprintfmt+0x220>
f010549c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010549f:	29 c1                	sub    %eax,%ecx
f01054a1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01054a4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01054a7:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01054aa:	eb 15                	jmp    f01054c1 <vprintfmt+0x1ec>
				if (altflag && (ch < ' ' || ch > '~'))
f01054ac:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01054b0:	75 29                	jne    f01054db <vprintfmt+0x206>
					putch(ch, putdat);
f01054b2:	83 ec 08             	sub    $0x8,%esp
f01054b5:	ff 75 0c             	pushl  0xc(%ebp)
f01054b8:	50                   	push   %eax
f01054b9:	ff d6                	call   *%esi
f01054bb:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01054be:	ff 4d e0             	decl   -0x20(%ebp)
f01054c1:	47                   	inc    %edi
f01054c2:	8a 57 ff             	mov    -0x1(%edi),%dl
f01054c5:	0f be c2             	movsbl %dl,%eax
f01054c8:	85 c0                	test   %eax,%eax
f01054ca:	74 53                	je     f010551f <vprintfmt+0x24a>
f01054cc:	85 db                	test   %ebx,%ebx
f01054ce:	78 dc                	js     f01054ac <vprintfmt+0x1d7>
f01054d0:	4b                   	dec    %ebx
f01054d1:	79 d9                	jns    f01054ac <vprintfmt+0x1d7>
f01054d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01054d6:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01054d9:	eb 35                	jmp    f0105510 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
f01054db:	0f be d2             	movsbl %dl,%edx
f01054de:	83 ea 20             	sub    $0x20,%edx
f01054e1:	83 fa 5e             	cmp    $0x5e,%edx
f01054e4:	76 cc                	jbe    f01054b2 <vprintfmt+0x1dd>
					putch('?', putdat);
f01054e6:	83 ec 08             	sub    $0x8,%esp
f01054e9:	ff 75 0c             	pushl  0xc(%ebp)
f01054ec:	6a 3f                	push   $0x3f
f01054ee:	ff d6                	call   *%esi
f01054f0:	83 c4 10             	add    $0x10,%esp
f01054f3:	eb c9                	jmp    f01054be <vprintfmt+0x1e9>
f01054f5:	b8 00 00 00 00       	mov    $0x0,%eax
f01054fa:	eb a0                	jmp    f010549c <vprintfmt+0x1c7>
f01054fc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01054ff:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0105502:	eb bd                	jmp    f01054c1 <vprintfmt+0x1ec>
				putch(' ', putdat);
f0105504:	83 ec 08             	sub    $0x8,%esp
f0105507:	53                   	push   %ebx
f0105508:	6a 20                	push   $0x20
f010550a:	ff d6                	call   *%esi
			for (; width > 0; width--)
f010550c:	4f                   	dec    %edi
f010550d:	83 c4 10             	add    $0x10,%esp
f0105510:	85 ff                	test   %edi,%edi
f0105512:	7f f0                	jg     f0105504 <vprintfmt+0x22f>
			if ((p = va_arg(ap, char *)) == NULL)
f0105514:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105517:	89 45 14             	mov    %eax,0x14(%ebp)
f010551a:	e9 76 01 00 00       	jmp    f0105695 <vprintfmt+0x3c0>
f010551f:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105522:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105525:	eb e9                	jmp    f0105510 <vprintfmt+0x23b>
	if (lflag >= 2)
f0105527:	83 f9 01             	cmp    $0x1,%ecx
f010552a:	7e 3f                	jle    f010556b <vprintfmt+0x296>
		return va_arg(*ap, long long);
f010552c:	8b 45 14             	mov    0x14(%ebp),%eax
f010552f:	8b 50 04             	mov    0x4(%eax),%edx
f0105532:	8b 00                	mov    (%eax),%eax
f0105534:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105537:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010553a:	8b 45 14             	mov    0x14(%ebp),%eax
f010553d:	8d 40 08             	lea    0x8(%eax),%eax
f0105540:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0105543:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105547:	79 5c                	jns    f01055a5 <vprintfmt+0x2d0>
				putch('-', putdat);
f0105549:	83 ec 08             	sub    $0x8,%esp
f010554c:	53                   	push   %ebx
f010554d:	6a 2d                	push   $0x2d
f010554f:	ff d6                	call   *%esi
				num = -(long long) num;
f0105551:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105554:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105557:	f7 da                	neg    %edx
f0105559:	83 d1 00             	adc    $0x0,%ecx
f010555c:	f7 d9                	neg    %ecx
f010555e:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0105561:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105566:	e9 10 01 00 00       	jmp    f010567b <vprintfmt+0x3a6>
	else if (lflag)
f010556b:	85 c9                	test   %ecx,%ecx
f010556d:	75 1b                	jne    f010558a <vprintfmt+0x2b5>
		return va_arg(*ap, int);
f010556f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105572:	8b 00                	mov    (%eax),%eax
f0105574:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105577:	89 c1                	mov    %eax,%ecx
f0105579:	c1 f9 1f             	sar    $0x1f,%ecx
f010557c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010557f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105582:	8d 40 04             	lea    0x4(%eax),%eax
f0105585:	89 45 14             	mov    %eax,0x14(%ebp)
f0105588:	eb b9                	jmp    f0105543 <vprintfmt+0x26e>
		return va_arg(*ap, long);
f010558a:	8b 45 14             	mov    0x14(%ebp),%eax
f010558d:	8b 00                	mov    (%eax),%eax
f010558f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105592:	89 c1                	mov    %eax,%ecx
f0105594:	c1 f9 1f             	sar    $0x1f,%ecx
f0105597:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010559a:	8b 45 14             	mov    0x14(%ebp),%eax
f010559d:	8d 40 04             	lea    0x4(%eax),%eax
f01055a0:	89 45 14             	mov    %eax,0x14(%ebp)
f01055a3:	eb 9e                	jmp    f0105543 <vprintfmt+0x26e>
			num = getint(&ap, lflag);
f01055a5:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01055a8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01055ab:	b8 0a 00 00 00       	mov    $0xa,%eax
f01055b0:	e9 c6 00 00 00       	jmp    f010567b <vprintfmt+0x3a6>
	if (lflag >= 2)
f01055b5:	83 f9 01             	cmp    $0x1,%ecx
f01055b8:	7e 18                	jle    f01055d2 <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
f01055ba:	8b 45 14             	mov    0x14(%ebp),%eax
f01055bd:	8b 10                	mov    (%eax),%edx
f01055bf:	8b 48 04             	mov    0x4(%eax),%ecx
f01055c2:	8d 40 08             	lea    0x8(%eax),%eax
f01055c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01055c8:	b8 0a 00 00 00       	mov    $0xa,%eax
f01055cd:	e9 a9 00 00 00       	jmp    f010567b <vprintfmt+0x3a6>
	else if (lflag)
f01055d2:	85 c9                	test   %ecx,%ecx
f01055d4:	75 1a                	jne    f01055f0 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned int);
f01055d6:	8b 45 14             	mov    0x14(%ebp),%eax
f01055d9:	8b 10                	mov    (%eax),%edx
f01055db:	b9 00 00 00 00       	mov    $0x0,%ecx
f01055e0:	8d 40 04             	lea    0x4(%eax),%eax
f01055e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01055e6:	b8 0a 00 00 00       	mov    $0xa,%eax
f01055eb:	e9 8b 00 00 00       	jmp    f010567b <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f01055f0:	8b 45 14             	mov    0x14(%ebp),%eax
f01055f3:	8b 10                	mov    (%eax),%edx
f01055f5:	b9 00 00 00 00       	mov    $0x0,%ecx
f01055fa:	8d 40 04             	lea    0x4(%eax),%eax
f01055fd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105600:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105605:	eb 74                	jmp    f010567b <vprintfmt+0x3a6>
	if (lflag >= 2)
f0105607:	83 f9 01             	cmp    $0x1,%ecx
f010560a:	7e 15                	jle    f0105621 <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
f010560c:	8b 45 14             	mov    0x14(%ebp),%eax
f010560f:	8b 10                	mov    (%eax),%edx
f0105611:	8b 48 04             	mov    0x4(%eax),%ecx
f0105614:	8d 40 08             	lea    0x8(%eax),%eax
f0105617:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010561a:	b8 08 00 00 00       	mov    $0x8,%eax
f010561f:	eb 5a                	jmp    f010567b <vprintfmt+0x3a6>
	else if (lflag)
f0105621:	85 c9                	test   %ecx,%ecx
f0105623:	75 17                	jne    f010563c <vprintfmt+0x367>
		return va_arg(*ap, unsigned int);
f0105625:	8b 45 14             	mov    0x14(%ebp),%eax
f0105628:	8b 10                	mov    (%eax),%edx
f010562a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010562f:	8d 40 04             	lea    0x4(%eax),%eax
f0105632:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0105635:	b8 08 00 00 00       	mov    $0x8,%eax
f010563a:	eb 3f                	jmp    f010567b <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f010563c:	8b 45 14             	mov    0x14(%ebp),%eax
f010563f:	8b 10                	mov    (%eax),%edx
f0105641:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105646:	8d 40 04             	lea    0x4(%eax),%eax
f0105649:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010564c:	b8 08 00 00 00       	mov    $0x8,%eax
f0105651:	eb 28                	jmp    f010567b <vprintfmt+0x3a6>
			putch('0', putdat);
f0105653:	83 ec 08             	sub    $0x8,%esp
f0105656:	53                   	push   %ebx
f0105657:	6a 30                	push   $0x30
f0105659:	ff d6                	call   *%esi
			putch('x', putdat);
f010565b:	83 c4 08             	add    $0x8,%esp
f010565e:	53                   	push   %ebx
f010565f:	6a 78                	push   $0x78
f0105661:	ff d6                	call   *%esi
			num = (unsigned long long)
f0105663:	8b 45 14             	mov    0x14(%ebp),%eax
f0105666:	8b 10                	mov    (%eax),%edx
f0105668:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010566d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0105670:	8d 40 04             	lea    0x4(%eax),%eax
f0105673:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105676:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f010567b:	83 ec 0c             	sub    $0xc,%esp
f010567e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105682:	57                   	push   %edi
f0105683:	ff 75 e0             	pushl  -0x20(%ebp)
f0105686:	50                   	push   %eax
f0105687:	51                   	push   %ecx
f0105688:	52                   	push   %edx
f0105689:	89 da                	mov    %ebx,%edx
f010568b:	89 f0                	mov    %esi,%eax
f010568d:	e8 5d fb ff ff       	call   f01051ef <printnum>
			break;
f0105692:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0105695:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105698:	47                   	inc    %edi
f0105699:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010569d:	83 f8 25             	cmp    $0x25,%eax
f01056a0:	0f 84 46 fc ff ff    	je     f01052ec <vprintfmt+0x17>
			if (ch == '\0')
f01056a6:	85 c0                	test   %eax,%eax
f01056a8:	0f 84 89 00 00 00    	je     f0105737 <vprintfmt+0x462>
			putch(ch, putdat);
f01056ae:	83 ec 08             	sub    $0x8,%esp
f01056b1:	53                   	push   %ebx
f01056b2:	50                   	push   %eax
f01056b3:	ff d6                	call   *%esi
f01056b5:	83 c4 10             	add    $0x10,%esp
f01056b8:	eb de                	jmp    f0105698 <vprintfmt+0x3c3>
	if (lflag >= 2)
f01056ba:	83 f9 01             	cmp    $0x1,%ecx
f01056bd:	7e 15                	jle    f01056d4 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
f01056bf:	8b 45 14             	mov    0x14(%ebp),%eax
f01056c2:	8b 10                	mov    (%eax),%edx
f01056c4:	8b 48 04             	mov    0x4(%eax),%ecx
f01056c7:	8d 40 08             	lea    0x8(%eax),%eax
f01056ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01056cd:	b8 10 00 00 00       	mov    $0x10,%eax
f01056d2:	eb a7                	jmp    f010567b <vprintfmt+0x3a6>
	else if (lflag)
f01056d4:	85 c9                	test   %ecx,%ecx
f01056d6:	75 17                	jne    f01056ef <vprintfmt+0x41a>
		return va_arg(*ap, unsigned int);
f01056d8:	8b 45 14             	mov    0x14(%ebp),%eax
f01056db:	8b 10                	mov    (%eax),%edx
f01056dd:	b9 00 00 00 00       	mov    $0x0,%ecx
f01056e2:	8d 40 04             	lea    0x4(%eax),%eax
f01056e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01056e8:	b8 10 00 00 00       	mov    $0x10,%eax
f01056ed:	eb 8c                	jmp    f010567b <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f01056ef:	8b 45 14             	mov    0x14(%ebp),%eax
f01056f2:	8b 10                	mov    (%eax),%edx
f01056f4:	b9 00 00 00 00       	mov    $0x0,%ecx
f01056f9:	8d 40 04             	lea    0x4(%eax),%eax
f01056fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01056ff:	b8 10 00 00 00       	mov    $0x10,%eax
f0105704:	e9 72 ff ff ff       	jmp    f010567b <vprintfmt+0x3a6>
			putch(ch, putdat);
f0105709:	83 ec 08             	sub    $0x8,%esp
f010570c:	53                   	push   %ebx
f010570d:	6a 25                	push   $0x25
f010570f:	ff d6                	call   *%esi
			break;
f0105711:	83 c4 10             	add    $0x10,%esp
f0105714:	e9 7c ff ff ff       	jmp    f0105695 <vprintfmt+0x3c0>
			putch('%', putdat);
f0105719:	83 ec 08             	sub    $0x8,%esp
f010571c:	53                   	push   %ebx
f010571d:	6a 25                	push   $0x25
f010571f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105721:	83 c4 10             	add    $0x10,%esp
f0105724:	89 f8                	mov    %edi,%eax
f0105726:	eb 01                	jmp    f0105729 <vprintfmt+0x454>
f0105728:	48                   	dec    %eax
f0105729:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010572d:	75 f9                	jne    f0105728 <vprintfmt+0x453>
f010572f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105732:	e9 5e ff ff ff       	jmp    f0105695 <vprintfmt+0x3c0>
}
f0105737:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010573a:	5b                   	pop    %ebx
f010573b:	5e                   	pop    %esi
f010573c:	5f                   	pop    %edi
f010573d:	5d                   	pop    %ebp
f010573e:	c3                   	ret    

f010573f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010573f:	55                   	push   %ebp
f0105740:	89 e5                	mov    %esp,%ebp
f0105742:	83 ec 18             	sub    $0x18,%esp
f0105745:	8b 45 08             	mov    0x8(%ebp),%eax
f0105748:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010574b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010574e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105752:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105755:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010575c:	85 c0                	test   %eax,%eax
f010575e:	74 26                	je     f0105786 <vsnprintf+0x47>
f0105760:	85 d2                	test   %edx,%edx
f0105762:	7e 29                	jle    f010578d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105764:	ff 75 14             	pushl  0x14(%ebp)
f0105767:	ff 75 10             	pushl  0x10(%ebp)
f010576a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010576d:	50                   	push   %eax
f010576e:	68 9c 52 10 f0       	push   $0xf010529c
f0105773:	e8 5d fb ff ff       	call   f01052d5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105778:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010577b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010577e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105781:	83 c4 10             	add    $0x10,%esp
}
f0105784:	c9                   	leave  
f0105785:	c3                   	ret    
		return -E_INVAL;
f0105786:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010578b:	eb f7                	jmp    f0105784 <vsnprintf+0x45>
f010578d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105792:	eb f0                	jmp    f0105784 <vsnprintf+0x45>

f0105794 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105794:	55                   	push   %ebp
f0105795:	89 e5                	mov    %esp,%ebp
f0105797:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010579a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010579d:	50                   	push   %eax
f010579e:	ff 75 10             	pushl  0x10(%ebp)
f01057a1:	ff 75 0c             	pushl  0xc(%ebp)
f01057a4:	ff 75 08             	pushl  0x8(%ebp)
f01057a7:	e8 93 ff ff ff       	call   f010573f <vsnprintf>
	va_end(ap);

	return rc;
}
f01057ac:	c9                   	leave  
f01057ad:	c3                   	ret    

f01057ae <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01057ae:	55                   	push   %ebp
f01057af:	89 e5                	mov    %esp,%ebp
f01057b1:	57                   	push   %edi
f01057b2:	56                   	push   %esi
f01057b3:	53                   	push   %ebx
f01057b4:	83 ec 0c             	sub    $0xc,%esp
f01057b7:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01057ba:	85 c0                	test   %eax,%eax
f01057bc:	74 11                	je     f01057cf <readline+0x21>
		cprintf("%s", prompt);
f01057be:	83 ec 08             	sub    $0x8,%esp
f01057c1:	50                   	push   %eax
f01057c2:	68 55 79 10 f0       	push   $0xf0107955
f01057c7:	e8 a9 e7 ff ff       	call   f0103f75 <cprintf>
f01057cc:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01057cf:	83 ec 0c             	sub    $0xc,%esp
f01057d2:	6a 00                	push   $0x0
f01057d4:	e8 64 b0 ff ff       	call   f010083d <iscons>
f01057d9:	89 c7                	mov    %eax,%edi
f01057db:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01057de:	be 00 00 00 00       	mov    $0x0,%esi
f01057e3:	eb 6f                	jmp    f0105854 <readline+0xa6>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01057e5:	83 ec 08             	sub    $0x8,%esp
f01057e8:	50                   	push   %eax
f01057e9:	68 44 84 10 f0       	push   $0xf0108444
f01057ee:	e8 82 e7 ff ff       	call   f0103f75 <cprintf>
			return NULL;
f01057f3:	83 c4 10             	add    $0x10,%esp
f01057f6:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01057fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01057fe:	5b                   	pop    %ebx
f01057ff:	5e                   	pop    %esi
f0105800:	5f                   	pop    %edi
f0105801:	5d                   	pop    %ebp
f0105802:	c3                   	ret    
				cputchar('\b');
f0105803:	83 ec 0c             	sub    $0xc,%esp
f0105806:	6a 08                	push   $0x8
f0105808:	e8 0f b0 ff ff       	call   f010081c <cputchar>
f010580d:	83 c4 10             	add    $0x10,%esp
f0105810:	eb 41                	jmp    f0105853 <readline+0xa5>
				cputchar(c);
f0105812:	83 ec 0c             	sub    $0xc,%esp
f0105815:	53                   	push   %ebx
f0105816:	e8 01 b0 ff ff       	call   f010081c <cputchar>
f010581b:	83 c4 10             	add    $0x10,%esp
f010581e:	eb 5a                	jmp    f010587a <readline+0xcc>
		} else if (c == '\n' || c == '\r') {
f0105820:	83 fb 0a             	cmp    $0xa,%ebx
f0105823:	74 05                	je     f010582a <readline+0x7c>
f0105825:	83 fb 0d             	cmp    $0xd,%ebx
f0105828:	75 2a                	jne    f0105854 <readline+0xa6>
			if (echoing)
f010582a:	85 ff                	test   %edi,%edi
f010582c:	75 0e                	jne    f010583c <readline+0x8e>
			buf[i] = 0;
f010582e:	c6 86 80 1a 29 f0 00 	movb   $0x0,-0xfd6e580(%esi)
			return buf;
f0105835:	b8 80 1a 29 f0       	mov    $0xf0291a80,%eax
f010583a:	eb bf                	jmp    f01057fb <readline+0x4d>
				cputchar('\n');
f010583c:	83 ec 0c             	sub    $0xc,%esp
f010583f:	6a 0a                	push   $0xa
f0105841:	e8 d6 af ff ff       	call   f010081c <cputchar>
f0105846:	83 c4 10             	add    $0x10,%esp
f0105849:	eb e3                	jmp    f010582e <readline+0x80>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010584b:	85 f6                	test   %esi,%esi
f010584d:	7e 3c                	jle    f010588b <readline+0xdd>
			if (echoing)
f010584f:	85 ff                	test   %edi,%edi
f0105851:	75 b0                	jne    f0105803 <readline+0x55>
			i--;
f0105853:	4e                   	dec    %esi
		c = getchar();
f0105854:	e8 d3 af ff ff       	call   f010082c <getchar>
f0105859:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010585b:	85 c0                	test   %eax,%eax
f010585d:	78 86                	js     f01057e5 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010585f:	83 f8 08             	cmp    $0x8,%eax
f0105862:	74 21                	je     f0105885 <readline+0xd7>
f0105864:	83 f8 7f             	cmp    $0x7f,%eax
f0105867:	74 e2                	je     f010584b <readline+0x9d>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105869:	83 f8 1f             	cmp    $0x1f,%eax
f010586c:	7e b2                	jle    f0105820 <readline+0x72>
f010586e:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105874:	7f aa                	jg     f0105820 <readline+0x72>
			if (echoing)
f0105876:	85 ff                	test   %edi,%edi
f0105878:	75 98                	jne    f0105812 <readline+0x64>
			buf[i++] = c;
f010587a:	88 9e 80 1a 29 f0    	mov    %bl,-0xfd6e580(%esi)
f0105880:	8d 76 01             	lea    0x1(%esi),%esi
f0105883:	eb cf                	jmp    f0105854 <readline+0xa6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105885:	85 f6                	test   %esi,%esi
f0105887:	7e cb                	jle    f0105854 <readline+0xa6>
f0105889:	eb c4                	jmp    f010584f <readline+0xa1>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010588b:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105891:	7e e3                	jle    f0105876 <readline+0xc8>
f0105893:	eb bf                	jmp    f0105854 <readline+0xa6>

f0105895 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105895:	55                   	push   %ebp
f0105896:	89 e5                	mov    %esp,%ebp
f0105898:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010589b:	b8 00 00 00 00       	mov    $0x0,%eax
f01058a0:	eb 01                	jmp    f01058a3 <strlen+0xe>
		n++;
f01058a2:	40                   	inc    %eax
	for (n = 0; *s != '\0'; s++)
f01058a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01058a7:	75 f9                	jne    f01058a2 <strlen+0xd>
	return n;
}
f01058a9:	5d                   	pop    %ebp
f01058aa:	c3                   	ret    

f01058ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01058ab:	55                   	push   %ebp
f01058ac:	89 e5                	mov    %esp,%ebp
f01058ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01058b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01058b4:	b8 00 00 00 00       	mov    $0x0,%eax
f01058b9:	eb 01                	jmp    f01058bc <strnlen+0x11>
		n++;
f01058bb:	40                   	inc    %eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01058bc:	39 d0                	cmp    %edx,%eax
f01058be:	74 06                	je     f01058c6 <strnlen+0x1b>
f01058c0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01058c4:	75 f5                	jne    f01058bb <strnlen+0x10>
	return n;
}
f01058c6:	5d                   	pop    %ebp
f01058c7:	c3                   	ret    

f01058c8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01058c8:	55                   	push   %ebp
f01058c9:	89 e5                	mov    %esp,%ebp
f01058cb:	53                   	push   %ebx
f01058cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01058cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01058d2:	89 c2                	mov    %eax,%edx
f01058d4:	41                   	inc    %ecx
f01058d5:	42                   	inc    %edx
f01058d6:	8a 59 ff             	mov    -0x1(%ecx),%bl
f01058d9:	88 5a ff             	mov    %bl,-0x1(%edx)
f01058dc:	84 db                	test   %bl,%bl
f01058de:	75 f4                	jne    f01058d4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01058e0:	5b                   	pop    %ebx
f01058e1:	5d                   	pop    %ebp
f01058e2:	c3                   	ret    

f01058e3 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01058e3:	55                   	push   %ebp
f01058e4:	89 e5                	mov    %esp,%ebp
f01058e6:	53                   	push   %ebx
f01058e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01058ea:	53                   	push   %ebx
f01058eb:	e8 a5 ff ff ff       	call   f0105895 <strlen>
f01058f0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01058f3:	ff 75 0c             	pushl  0xc(%ebp)
f01058f6:	01 d8                	add    %ebx,%eax
f01058f8:	50                   	push   %eax
f01058f9:	e8 ca ff ff ff       	call   f01058c8 <strcpy>
	return dst;
}
f01058fe:	89 d8                	mov    %ebx,%eax
f0105900:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105903:	c9                   	leave  
f0105904:	c3                   	ret    

f0105905 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105905:	55                   	push   %ebp
f0105906:	89 e5                	mov    %esp,%ebp
f0105908:	56                   	push   %esi
f0105909:	53                   	push   %ebx
f010590a:	8b 75 08             	mov    0x8(%ebp),%esi
f010590d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105910:	89 f3                	mov    %esi,%ebx
f0105912:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105915:	89 f2                	mov    %esi,%edx
f0105917:	39 da                	cmp    %ebx,%edx
f0105919:	74 0e                	je     f0105929 <strncpy+0x24>
		*dst++ = *src;
f010591b:	42                   	inc    %edx
f010591c:	8a 01                	mov    (%ecx),%al
f010591e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f0105921:	80 39 00             	cmpb   $0x0,(%ecx)
f0105924:	74 f1                	je     f0105917 <strncpy+0x12>
			src++;
f0105926:	41                   	inc    %ecx
f0105927:	eb ee                	jmp    f0105917 <strncpy+0x12>
	}
	return ret;
}
f0105929:	89 f0                	mov    %esi,%eax
f010592b:	5b                   	pop    %ebx
f010592c:	5e                   	pop    %esi
f010592d:	5d                   	pop    %ebp
f010592e:	c3                   	ret    

f010592f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010592f:	55                   	push   %ebp
f0105930:	89 e5                	mov    %esp,%ebp
f0105932:	56                   	push   %esi
f0105933:	53                   	push   %ebx
f0105934:	8b 75 08             	mov    0x8(%ebp),%esi
f0105937:	8b 55 0c             	mov    0xc(%ebp),%edx
f010593a:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010593d:	85 c0                	test   %eax,%eax
f010593f:	74 20                	je     f0105961 <strlcpy+0x32>
f0105941:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
f0105945:	89 f0                	mov    %esi,%eax
f0105947:	eb 05                	jmp    f010594e <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105949:	42                   	inc    %edx
f010594a:	40                   	inc    %eax
f010594b:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f010594e:	39 d8                	cmp    %ebx,%eax
f0105950:	74 06                	je     f0105958 <strlcpy+0x29>
f0105952:	8a 0a                	mov    (%edx),%cl
f0105954:	84 c9                	test   %cl,%cl
f0105956:	75 f1                	jne    f0105949 <strlcpy+0x1a>
		*dst = '\0';
f0105958:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010595b:	29 f0                	sub    %esi,%eax
}
f010595d:	5b                   	pop    %ebx
f010595e:	5e                   	pop    %esi
f010595f:	5d                   	pop    %ebp
f0105960:	c3                   	ret    
f0105961:	89 f0                	mov    %esi,%eax
f0105963:	eb f6                	jmp    f010595b <strlcpy+0x2c>

f0105965 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105965:	55                   	push   %ebp
f0105966:	89 e5                	mov    %esp,%ebp
f0105968:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010596b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010596e:	eb 02                	jmp    f0105972 <strcmp+0xd>
		p++, q++;
f0105970:	41                   	inc    %ecx
f0105971:	42                   	inc    %edx
	while (*p && *p == *q)
f0105972:	8a 01                	mov    (%ecx),%al
f0105974:	84 c0                	test   %al,%al
f0105976:	74 04                	je     f010597c <strcmp+0x17>
f0105978:	3a 02                	cmp    (%edx),%al
f010597a:	74 f4                	je     f0105970 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010597c:	0f b6 c0             	movzbl %al,%eax
f010597f:	0f b6 12             	movzbl (%edx),%edx
f0105982:	29 d0                	sub    %edx,%eax
}
f0105984:	5d                   	pop    %ebp
f0105985:	c3                   	ret    

f0105986 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105986:	55                   	push   %ebp
f0105987:	89 e5                	mov    %esp,%ebp
f0105989:	53                   	push   %ebx
f010598a:	8b 45 08             	mov    0x8(%ebp),%eax
f010598d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105990:	89 c3                	mov    %eax,%ebx
f0105992:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105995:	eb 02                	jmp    f0105999 <strncmp+0x13>
		n--, p++, q++;
f0105997:	40                   	inc    %eax
f0105998:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
f0105999:	39 d8                	cmp    %ebx,%eax
f010599b:	74 15                	je     f01059b2 <strncmp+0x2c>
f010599d:	8a 08                	mov    (%eax),%cl
f010599f:	84 c9                	test   %cl,%cl
f01059a1:	74 04                	je     f01059a7 <strncmp+0x21>
f01059a3:	3a 0a                	cmp    (%edx),%cl
f01059a5:	74 f0                	je     f0105997 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01059a7:	0f b6 00             	movzbl (%eax),%eax
f01059aa:	0f b6 12             	movzbl (%edx),%edx
f01059ad:	29 d0                	sub    %edx,%eax
}
f01059af:	5b                   	pop    %ebx
f01059b0:	5d                   	pop    %ebp
f01059b1:	c3                   	ret    
		return 0;
f01059b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01059b7:	eb f6                	jmp    f01059af <strncmp+0x29>

f01059b9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01059b9:	55                   	push   %ebp
f01059ba:	89 e5                	mov    %esp,%ebp
f01059bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01059bf:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01059c2:	8a 10                	mov    (%eax),%dl
f01059c4:	84 d2                	test   %dl,%dl
f01059c6:	74 07                	je     f01059cf <strchr+0x16>
		if (*s == c)
f01059c8:	38 ca                	cmp    %cl,%dl
f01059ca:	74 08                	je     f01059d4 <strchr+0x1b>
	for (; *s; s++)
f01059cc:	40                   	inc    %eax
f01059cd:	eb f3                	jmp    f01059c2 <strchr+0x9>
			return (char *) s;
	return 0;
f01059cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01059d4:	5d                   	pop    %ebp
f01059d5:	c3                   	ret    

f01059d6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01059d6:	55                   	push   %ebp
f01059d7:	89 e5                	mov    %esp,%ebp
f01059d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01059dc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01059df:	8a 10                	mov    (%eax),%dl
f01059e1:	84 d2                	test   %dl,%dl
f01059e3:	74 07                	je     f01059ec <strfind+0x16>
		if (*s == c)
f01059e5:	38 ca                	cmp    %cl,%dl
f01059e7:	74 03                	je     f01059ec <strfind+0x16>
	for (; *s; s++)
f01059e9:	40                   	inc    %eax
f01059ea:	eb f3                	jmp    f01059df <strfind+0x9>
			break;
	return (char *) s;
}
f01059ec:	5d                   	pop    %ebp
f01059ed:	c3                   	ret    

f01059ee <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01059ee:	55                   	push   %ebp
f01059ef:	89 e5                	mov    %esp,%ebp
f01059f1:	57                   	push   %edi
f01059f2:	56                   	push   %esi
f01059f3:	53                   	push   %ebx
f01059f4:	8b 7d 08             	mov    0x8(%ebp),%edi
f01059f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01059fa:	85 c9                	test   %ecx,%ecx
f01059fc:	74 13                	je     f0105a11 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01059fe:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105a04:	75 05                	jne    f0105a0b <memset+0x1d>
f0105a06:	f6 c1 03             	test   $0x3,%cl
f0105a09:	74 0d                	je     f0105a18 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105a0b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105a0e:	fc                   	cld    
f0105a0f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105a11:	89 f8                	mov    %edi,%eax
f0105a13:	5b                   	pop    %ebx
f0105a14:	5e                   	pop    %esi
f0105a15:	5f                   	pop    %edi
f0105a16:	5d                   	pop    %ebp
f0105a17:	c3                   	ret    
		c &= 0xFF;
f0105a18:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105a1c:	89 d3                	mov    %edx,%ebx
f0105a1e:	c1 e3 08             	shl    $0x8,%ebx
f0105a21:	89 d0                	mov    %edx,%eax
f0105a23:	c1 e0 18             	shl    $0x18,%eax
f0105a26:	89 d6                	mov    %edx,%esi
f0105a28:	c1 e6 10             	shl    $0x10,%esi
f0105a2b:	09 f0                	or     %esi,%eax
f0105a2d:	09 c2                	or     %eax,%edx
f0105a2f:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0105a31:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0105a34:	89 d0                	mov    %edx,%eax
f0105a36:	fc                   	cld    
f0105a37:	f3 ab                	rep stos %eax,%es:(%edi)
f0105a39:	eb d6                	jmp    f0105a11 <memset+0x23>

f0105a3b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105a3b:	55                   	push   %ebp
f0105a3c:	89 e5                	mov    %esp,%ebp
f0105a3e:	57                   	push   %edi
f0105a3f:	56                   	push   %esi
f0105a40:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a43:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105a46:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105a49:	39 c6                	cmp    %eax,%esi
f0105a4b:	73 33                	jae    f0105a80 <memmove+0x45>
f0105a4d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105a50:	39 c2                	cmp    %eax,%edx
f0105a52:	76 2c                	jbe    f0105a80 <memmove+0x45>
		s += n;
		d += n;
f0105a54:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105a57:	89 d6                	mov    %edx,%esi
f0105a59:	09 fe                	or     %edi,%esi
f0105a5b:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105a61:	74 0a                	je     f0105a6d <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105a63:	4f                   	dec    %edi
f0105a64:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0105a67:	fd                   	std    
f0105a68:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105a6a:	fc                   	cld    
f0105a6b:	eb 21                	jmp    f0105a8e <memmove+0x53>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105a6d:	f6 c1 03             	test   $0x3,%cl
f0105a70:	75 f1                	jne    f0105a63 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105a72:	83 ef 04             	sub    $0x4,%edi
f0105a75:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105a78:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0105a7b:	fd                   	std    
f0105a7c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105a7e:	eb ea                	jmp    f0105a6a <memmove+0x2f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105a80:	89 f2                	mov    %esi,%edx
f0105a82:	09 c2                	or     %eax,%edx
f0105a84:	f6 c2 03             	test   $0x3,%dl
f0105a87:	74 09                	je     f0105a92 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105a89:	89 c7                	mov    %eax,%edi
f0105a8b:	fc                   	cld    
f0105a8c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105a8e:	5e                   	pop    %esi
f0105a8f:	5f                   	pop    %edi
f0105a90:	5d                   	pop    %ebp
f0105a91:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105a92:	f6 c1 03             	test   $0x3,%cl
f0105a95:	75 f2                	jne    f0105a89 <memmove+0x4e>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105a97:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105a9a:	89 c7                	mov    %eax,%edi
f0105a9c:	fc                   	cld    
f0105a9d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105a9f:	eb ed                	jmp    f0105a8e <memmove+0x53>

f0105aa1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105aa1:	55                   	push   %ebp
f0105aa2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105aa4:	ff 75 10             	pushl  0x10(%ebp)
f0105aa7:	ff 75 0c             	pushl  0xc(%ebp)
f0105aaa:	ff 75 08             	pushl  0x8(%ebp)
f0105aad:	e8 89 ff ff ff       	call   f0105a3b <memmove>
}
f0105ab2:	c9                   	leave  
f0105ab3:	c3                   	ret    

f0105ab4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105ab4:	55                   	push   %ebp
f0105ab5:	89 e5                	mov    %esp,%ebp
f0105ab7:	56                   	push   %esi
f0105ab8:	53                   	push   %ebx
f0105ab9:	8b 45 08             	mov    0x8(%ebp),%eax
f0105abc:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105abf:	89 c6                	mov    %eax,%esi
f0105ac1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105ac4:	39 f0                	cmp    %esi,%eax
f0105ac6:	74 16                	je     f0105ade <memcmp+0x2a>
		if (*s1 != *s2)
f0105ac8:	8a 08                	mov    (%eax),%cl
f0105aca:	8a 1a                	mov    (%edx),%bl
f0105acc:	38 d9                	cmp    %bl,%cl
f0105ace:	75 04                	jne    f0105ad4 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0105ad0:	40                   	inc    %eax
f0105ad1:	42                   	inc    %edx
f0105ad2:	eb f0                	jmp    f0105ac4 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0105ad4:	0f b6 c1             	movzbl %cl,%eax
f0105ad7:	0f b6 db             	movzbl %bl,%ebx
f0105ada:	29 d8                	sub    %ebx,%eax
f0105adc:	eb 05                	jmp    f0105ae3 <memcmp+0x2f>
	}

	return 0;
f0105ade:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105ae3:	5b                   	pop    %ebx
f0105ae4:	5e                   	pop    %esi
f0105ae5:	5d                   	pop    %ebp
f0105ae6:	c3                   	ret    

f0105ae7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105ae7:	55                   	push   %ebp
f0105ae8:	89 e5                	mov    %esp,%ebp
f0105aea:	8b 45 08             	mov    0x8(%ebp),%eax
f0105aed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105af0:	89 c2                	mov    %eax,%edx
f0105af2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105af5:	39 d0                	cmp    %edx,%eax
f0105af7:	73 07                	jae    f0105b00 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105af9:	38 08                	cmp    %cl,(%eax)
f0105afb:	74 03                	je     f0105b00 <memfind+0x19>
	for (; s < ends; s++)
f0105afd:	40                   	inc    %eax
f0105afe:	eb f5                	jmp    f0105af5 <memfind+0xe>
			break;
	return (void *) s;
}
f0105b00:	5d                   	pop    %ebp
f0105b01:	c3                   	ret    

f0105b02 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105b02:	55                   	push   %ebp
f0105b03:	89 e5                	mov    %esp,%ebp
f0105b05:	57                   	push   %edi
f0105b06:	56                   	push   %esi
f0105b07:	53                   	push   %ebx
f0105b08:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105b0b:	eb 01                	jmp    f0105b0e <strtol+0xc>
		s++;
f0105b0d:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f0105b0e:	8a 01                	mov    (%ecx),%al
f0105b10:	3c 20                	cmp    $0x20,%al
f0105b12:	74 f9                	je     f0105b0d <strtol+0xb>
f0105b14:	3c 09                	cmp    $0x9,%al
f0105b16:	74 f5                	je     f0105b0d <strtol+0xb>

	// plus/minus sign
	if (*s == '+')
f0105b18:	3c 2b                	cmp    $0x2b,%al
f0105b1a:	74 2b                	je     f0105b47 <strtol+0x45>
		s++;
	else if (*s == '-')
f0105b1c:	3c 2d                	cmp    $0x2d,%al
f0105b1e:	74 2f                	je     f0105b4f <strtol+0x4d>
	int neg = 0;
f0105b20:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105b25:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f0105b2c:	75 12                	jne    f0105b40 <strtol+0x3e>
f0105b2e:	80 39 30             	cmpb   $0x30,(%ecx)
f0105b31:	74 24                	je     f0105b57 <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105b33:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0105b37:	75 07                	jne    f0105b40 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105b39:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f0105b40:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b45:	eb 4e                	jmp    f0105b95 <strtol+0x93>
		s++;
f0105b47:	41                   	inc    %ecx
	int neg = 0;
f0105b48:	bf 00 00 00 00       	mov    $0x0,%edi
f0105b4d:	eb d6                	jmp    f0105b25 <strtol+0x23>
		s++, neg = 1;
f0105b4f:	41                   	inc    %ecx
f0105b50:	bf 01 00 00 00       	mov    $0x1,%edi
f0105b55:	eb ce                	jmp    f0105b25 <strtol+0x23>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105b57:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105b5b:	74 10                	je     f0105b6d <strtol+0x6b>
	else if (base == 0 && s[0] == '0')
f0105b5d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0105b61:	75 dd                	jne    f0105b40 <strtol+0x3e>
		s++, base = 8;
f0105b63:	41                   	inc    %ecx
f0105b64:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f0105b6b:	eb d3                	jmp    f0105b40 <strtol+0x3e>
		s += 2, base = 16;
f0105b6d:	83 c1 02             	add    $0x2,%ecx
f0105b70:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f0105b77:	eb c7                	jmp    f0105b40 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0105b79:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105b7c:	89 f3                	mov    %esi,%ebx
f0105b7e:	80 fb 19             	cmp    $0x19,%bl
f0105b81:	77 24                	ja     f0105ba7 <strtol+0xa5>
			dig = *s - 'a' + 10;
f0105b83:	0f be d2             	movsbl %dl,%edx
f0105b86:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105b89:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105b8c:	7d 2b                	jge    f0105bb9 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
f0105b8e:	41                   	inc    %ecx
f0105b8f:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105b93:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0105b95:	8a 11                	mov    (%ecx),%dl
f0105b97:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0105b9a:	80 fb 09             	cmp    $0x9,%bl
f0105b9d:	77 da                	ja     f0105b79 <strtol+0x77>
			dig = *s - '0';
f0105b9f:	0f be d2             	movsbl %dl,%edx
f0105ba2:	83 ea 30             	sub    $0x30,%edx
f0105ba5:	eb e2                	jmp    f0105b89 <strtol+0x87>
		else if (*s >= 'A' && *s <= 'Z')
f0105ba7:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105baa:	89 f3                	mov    %esi,%ebx
f0105bac:	80 fb 19             	cmp    $0x19,%bl
f0105baf:	77 08                	ja     f0105bb9 <strtol+0xb7>
			dig = *s - 'A' + 10;
f0105bb1:	0f be d2             	movsbl %dl,%edx
f0105bb4:	83 ea 37             	sub    $0x37,%edx
f0105bb7:	eb d0                	jmp    f0105b89 <strtol+0x87>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105bb9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105bbd:	74 05                	je     f0105bc4 <strtol+0xc2>
		*endptr = (char *) s;
f0105bbf:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105bc2:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0105bc4:	85 ff                	test   %edi,%edi
f0105bc6:	74 02                	je     f0105bca <strtol+0xc8>
f0105bc8:	f7 d8                	neg    %eax
}
f0105bca:	5b                   	pop    %ebx
f0105bcb:	5e                   	pop    %esi
f0105bcc:	5f                   	pop    %edi
f0105bcd:	5d                   	pop    %ebp
f0105bce:	c3                   	ret    

f0105bcf <strtoul>:

unsigned long
strtoul(const char *s, char **endptr, int base)
{
f0105bcf:	55                   	push   %ebp
f0105bd0:	89 e5                	mov    %esp,%ebp
f0105bd2:	57                   	push   %edi
f0105bd3:	56                   	push   %esi
f0105bd4:	53                   	push   %ebx
f0105bd5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	unsigned long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105bd8:	eb 01                	jmp    f0105bdb <strtoul+0xc>
		s++;
f0105bda:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f0105bdb:	8a 01                	mov    (%ecx),%al
f0105bdd:	3c 20                	cmp    $0x20,%al
f0105bdf:	74 f9                	je     f0105bda <strtoul+0xb>
f0105be1:	3c 09                	cmp    $0x9,%al
f0105be3:	74 f5                	je     f0105bda <strtoul+0xb>

	// plus/minus sign
	if (*s == '+')
f0105be5:	3c 2b                	cmp    $0x2b,%al
f0105be7:	74 2b                	je     f0105c14 <strtoul+0x45>
		s++;
	else if (*s == '-')
f0105be9:	3c 2d                	cmp    $0x2d,%al
f0105beb:	74 2f                	je     f0105c1c <strtoul+0x4d>
	int neg = 0;
f0105bed:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105bf2:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f0105bf9:	75 12                	jne    f0105c0d <strtoul+0x3e>
f0105bfb:	80 39 30             	cmpb   $0x30,(%ecx)
f0105bfe:	74 24                	je     f0105c24 <strtoul+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105c00:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0105c04:	75 07                	jne    f0105c0d <strtoul+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105c06:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f0105c0d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c12:	eb 4e                	jmp    f0105c62 <strtoul+0x93>
		s++;
f0105c14:	41                   	inc    %ecx
	int neg = 0;
f0105c15:	bf 00 00 00 00       	mov    $0x0,%edi
f0105c1a:	eb d6                	jmp    f0105bf2 <strtoul+0x23>
		s++, neg = 1;
f0105c1c:	41                   	inc    %ecx
f0105c1d:	bf 01 00 00 00       	mov    $0x1,%edi
f0105c22:	eb ce                	jmp    f0105bf2 <strtoul+0x23>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105c24:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105c28:	74 10                	je     f0105c3a <strtoul+0x6b>
	else if (base == 0 && s[0] == '0')
f0105c2a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0105c2e:	75 dd                	jne    f0105c0d <strtoul+0x3e>
		s++, base = 8;
f0105c30:	41                   	inc    %ecx
f0105c31:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f0105c38:	eb d3                	jmp    f0105c0d <strtoul+0x3e>
		s += 2, base = 16;
f0105c3a:	83 c1 02             	add    $0x2,%ecx
f0105c3d:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f0105c44:	eb c7                	jmp    f0105c0d <strtoul+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0105c46:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105c49:	89 f3                	mov    %esi,%ebx
f0105c4b:	80 fb 19             	cmp    $0x19,%bl
f0105c4e:	77 24                	ja     f0105c74 <strtoul+0xa5>
			dig = *s - 'a' + 10;
f0105c50:	0f be d2             	movsbl %dl,%edx
f0105c53:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105c56:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105c59:	7d 2b                	jge    f0105c86 <strtoul+0xb7>
			break;
		s++, val = (val * base) + dig;
f0105c5b:	41                   	inc    %ecx
f0105c5c:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105c60:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0105c62:	8a 11                	mov    (%ecx),%dl
f0105c64:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0105c67:	80 fb 09             	cmp    $0x9,%bl
f0105c6a:	77 da                	ja     f0105c46 <strtoul+0x77>
			dig = *s - '0';
f0105c6c:	0f be d2             	movsbl %dl,%edx
f0105c6f:	83 ea 30             	sub    $0x30,%edx
f0105c72:	eb e2                	jmp    f0105c56 <strtoul+0x87>
		else if (*s >= 'A' && *s <= 'Z')
f0105c74:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105c77:	89 f3                	mov    %esi,%ebx
f0105c79:	80 fb 19             	cmp    $0x19,%bl
f0105c7c:	77 08                	ja     f0105c86 <strtoul+0xb7>
			dig = *s - 'A' + 10;
f0105c7e:	0f be d2             	movsbl %dl,%edx
f0105c81:	83 ea 37             	sub    $0x37,%edx
f0105c84:	eb d0                	jmp    f0105c56 <strtoul+0x87>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105c86:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105c8a:	74 05                	je     f0105c91 <strtoul+0xc2>
		*endptr = (char *) s;
f0105c8c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105c8f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0105c91:	85 ff                	test   %edi,%edi
f0105c93:	74 02                	je     f0105c97 <strtoul+0xc8>
f0105c95:	f7 d8                	neg    %eax
}
f0105c97:	5b                   	pop    %ebx
f0105c98:	5e                   	pop    %esi
f0105c99:	5f                   	pop    %edi
f0105c9a:	5d                   	pop    %ebp
f0105c9b:	c3                   	ret    

f0105c9c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105c9c:	fa                   	cli    

	xorw    %ax, %ax
f0105c9d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105c9f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105ca1:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105ca3:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105ca5:	0f 01 16             	lgdtl  (%esi)
f0105ca8:	74 70                	je     f0105d1a <mpsearch1+0x3>
	movl    %cr0, %eax
f0105caa:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105cad:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105cb1:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105cb4:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105cba:	08 00                	or     %al,(%eax)

f0105cbc <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105cbc:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105cc0:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105cc2:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105cc4:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105cc6:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105cca:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105ccc:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105cce:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f0105cd3:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105cd6:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105cd9:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105cde:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105ce1:	8b 25 84 1e 29 f0    	mov    0xf0291e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105ce7:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105cec:	b8 8d 02 10 f0       	mov    $0xf010028d,%eax
	call    *%eax
f0105cf1:	ff d0                	call   *%eax

f0105cf3 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105cf3:	eb fe                	jmp    f0105cf3 <spin>
f0105cf5:	8d 76 00             	lea    0x0(%esi),%esi

f0105cf8 <gdt>:
	...
f0105d00:	ff                   	(bad)  
f0105d01:	ff 00                	incl   (%eax)
f0105d03:	00 00                	add    %al,(%eax)
f0105d05:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105d0c:	00                   	.byte 0x0
f0105d0d:	92                   	xchg   %eax,%edx
f0105d0e:	cf                   	iret   
	...

f0105d10 <gdtdesc>:
f0105d10:	17                   	pop    %ss
f0105d11:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105d16 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105d16:	90                   	nop

f0105d17 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105d17:	55                   	push   %ebp
f0105d18:	89 e5                	mov    %esp,%ebp
f0105d1a:	57                   	push   %edi
f0105d1b:	56                   	push   %esi
f0105d1c:	53                   	push   %ebx
f0105d1d:	83 ec 0c             	sub    $0xc,%esp
	if (PGNUM(pa) >= npages)
f0105d20:	8b 0d 88 1e 29 f0    	mov    0xf0291e88,%ecx
f0105d26:	89 c3                	mov    %eax,%ebx
f0105d28:	c1 eb 0c             	shr    $0xc,%ebx
f0105d2b:	39 cb                	cmp    %ecx,%ebx
f0105d2d:	73 1a                	jae    f0105d49 <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f0105d2f:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105d35:	8d 34 02             	lea    (%edx,%eax,1),%esi
	if (PGNUM(pa) >= npages)
f0105d38:	89 f0                	mov    %esi,%eax
f0105d3a:	c1 e8 0c             	shr    $0xc,%eax
f0105d3d:	39 c8                	cmp    %ecx,%eax
f0105d3f:	73 1a                	jae    f0105d5b <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f0105d41:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0105d47:	eb 27                	jmp    f0105d70 <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105d49:	50                   	push   %eax
f0105d4a:	68 48 68 10 f0       	push   $0xf0106848
f0105d4f:	6a 57                	push   $0x57
f0105d51:	68 e1 85 10 f0       	push   $0xf01085e1
f0105d56:	e8 39 a3 ff ff       	call   f0100094 <_panic>
f0105d5b:	56                   	push   %esi
f0105d5c:	68 48 68 10 f0       	push   $0xf0106848
f0105d61:	6a 57                	push   $0x57
f0105d63:	68 e1 85 10 f0       	push   $0xf01085e1
f0105d68:	e8 27 a3 ff ff       	call   f0100094 <_panic>
f0105d6d:	83 c3 10             	add    $0x10,%ebx
f0105d70:	39 f3                	cmp    %esi,%ebx
f0105d72:	73 2c                	jae    f0105da0 <mpsearch1+0x89>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105d74:	83 ec 04             	sub    $0x4,%esp
f0105d77:	6a 04                	push   $0x4
f0105d79:	68 f1 85 10 f0       	push   $0xf01085f1
f0105d7e:	53                   	push   %ebx
f0105d7f:	e8 30 fd ff ff       	call   f0105ab4 <memcmp>
f0105d84:	83 c4 10             	add    $0x10,%esp
f0105d87:	85 c0                	test   %eax,%eax
f0105d89:	75 e2                	jne    f0105d6d <mpsearch1+0x56>
f0105d8b:	89 da                	mov    %ebx,%edx
f0105d8d:	8d 7b 10             	lea    0x10(%ebx),%edi
		sum += ((uint8_t *)addr)[i];
f0105d90:	0f b6 0a             	movzbl (%edx),%ecx
f0105d93:	01 c8                	add    %ecx,%eax
f0105d95:	42                   	inc    %edx
	for (i = 0; i < len; i++)
f0105d96:	39 fa                	cmp    %edi,%edx
f0105d98:	75 f6                	jne    f0105d90 <mpsearch1+0x79>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105d9a:	84 c0                	test   %al,%al
f0105d9c:	75 cf                	jne    f0105d6d <mpsearch1+0x56>
f0105d9e:	eb 05                	jmp    f0105da5 <mpsearch1+0x8e>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105da0:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0105da5:	89 d8                	mov    %ebx,%eax
f0105da7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105daa:	5b                   	pop    %ebx
f0105dab:	5e                   	pop    %esi
f0105dac:	5f                   	pop    %edi
f0105dad:	5d                   	pop    %ebp
f0105dae:	c3                   	ret    

f0105daf <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105daf:	55                   	push   %ebp
f0105db0:	89 e5                	mov    %esp,%ebp
f0105db2:	57                   	push   %edi
f0105db3:	56                   	push   %esi
f0105db4:	53                   	push   %ebx
f0105db5:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105db8:	c7 05 c0 23 29 f0 20 	movl   $0xf0292020,0xf02923c0
f0105dbf:	20 29 f0 
	if (PGNUM(pa) >= npages)
f0105dc2:	83 3d 88 1e 29 f0 00 	cmpl   $0x0,0xf0291e88
f0105dc9:	0f 84 84 00 00 00    	je     f0105e53 <mp_init+0xa4>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105dcf:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105dd6:	85 c0                	test   %eax,%eax
f0105dd8:	0f 84 8b 00 00 00    	je     f0105e69 <mp_init+0xba>
		p <<= 4;	// Translate from segment to PA
f0105dde:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105de1:	ba 00 04 00 00       	mov    $0x400,%edx
f0105de6:	e8 2c ff ff ff       	call   f0105d17 <mpsearch1>
f0105deb:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105dee:	85 c0                	test   %eax,%eax
f0105df0:	0f 84 97 00 00 00    	je     f0105e8d <mp_init+0xde>
	if (mp->physaddr == 0 || mp->type != 0) {
f0105df6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105df9:	8b 70 04             	mov    0x4(%eax),%esi
f0105dfc:	85 f6                	test   %esi,%esi
f0105dfe:	0f 84 a8 00 00 00    	je     f0105eac <mp_init+0xfd>
f0105e04:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105e08:	0f 85 9e 00 00 00    	jne    f0105eac <mp_init+0xfd>
f0105e0e:	89 f0                	mov    %esi,%eax
f0105e10:	c1 e8 0c             	shr    $0xc,%eax
f0105e13:	3b 05 88 1e 29 f0    	cmp    0xf0291e88,%eax
f0105e19:	0f 83 a2 00 00 00    	jae    f0105ec1 <mp_init+0x112>
	return (void *)(pa + KERNBASE);
f0105e1f:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
f0105e25:	89 df                	mov    %ebx,%edi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105e27:	83 ec 04             	sub    $0x4,%esp
f0105e2a:	6a 04                	push   $0x4
f0105e2c:	68 f6 85 10 f0       	push   $0xf01085f6
f0105e31:	53                   	push   %ebx
f0105e32:	e8 7d fc ff ff       	call   f0105ab4 <memcmp>
f0105e37:	83 c4 10             	add    $0x10,%esp
f0105e3a:	85 c0                	test   %eax,%eax
f0105e3c:	0f 85 94 00 00 00    	jne    f0105ed6 <mp_init+0x127>
f0105e42:	0f b7 53 04          	movzwl 0x4(%ebx),%edx
f0105e46:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
f0105e49:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	sum = 0;
f0105e4c:	89 c2                	mov    %eax,%edx
f0105e4e:	e9 9e 00 00 00       	jmp    f0105ef1 <mp_init+0x142>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105e53:	68 00 04 00 00       	push   $0x400
f0105e58:	68 48 68 10 f0       	push   $0xf0106848
f0105e5d:	6a 6f                	push   $0x6f
f0105e5f:	68 e1 85 10 f0       	push   $0xf01085e1
f0105e64:	e8 2b a2 ff ff       	call   f0100094 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105e69:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105e70:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105e73:	2d 00 04 00 00       	sub    $0x400,%eax
f0105e78:	ba 00 04 00 00       	mov    $0x400,%edx
f0105e7d:	e8 95 fe ff ff       	call   f0105d17 <mpsearch1>
f0105e82:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105e85:	85 c0                	test   %eax,%eax
f0105e87:	0f 85 69 ff ff ff    	jne    f0105df6 <mp_init+0x47>
	return mpsearch1(0xF0000, 0x10000);
f0105e8d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e92:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105e97:	e8 7b fe ff ff       	call   f0105d17 <mpsearch1>
f0105e9c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	if ((mp = mpsearch()) == 0)
f0105e9f:	85 c0                	test   %eax,%eax
f0105ea1:	0f 85 4f ff ff ff    	jne    f0105df6 <mp_init+0x47>
f0105ea7:	e9 b3 01 00 00       	jmp    f010605f <mp_init+0x2b0>
		cprintf("SMP: Default configurations not implemented\n");
f0105eac:	83 ec 0c             	sub    $0xc,%esp
f0105eaf:	68 54 84 10 f0       	push   $0xf0108454
f0105eb4:	e8 bc e0 ff ff       	call   f0103f75 <cprintf>
f0105eb9:	83 c4 10             	add    $0x10,%esp
f0105ebc:	e9 9e 01 00 00       	jmp    f010605f <mp_init+0x2b0>
f0105ec1:	56                   	push   %esi
f0105ec2:	68 48 68 10 f0       	push   $0xf0106848
f0105ec7:	68 90 00 00 00       	push   $0x90
f0105ecc:	68 e1 85 10 f0       	push   $0xf01085e1
f0105ed1:	e8 be a1 ff ff       	call   f0100094 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105ed6:	83 ec 0c             	sub    $0xc,%esp
f0105ed9:	68 84 84 10 f0       	push   $0xf0108484
f0105ede:	e8 92 e0 ff ff       	call   f0103f75 <cprintf>
f0105ee3:	83 c4 10             	add    $0x10,%esp
f0105ee6:	e9 74 01 00 00       	jmp    f010605f <mp_init+0x2b0>
		sum += ((uint8_t *)addr)[i];
f0105eeb:	0f b6 0b             	movzbl (%ebx),%ecx
f0105eee:	01 ca                	add    %ecx,%edx
f0105ef0:	43                   	inc    %ebx
	for (i = 0; i < len; i++)
f0105ef1:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0105ef4:	75 f5                	jne    f0105eeb <mp_init+0x13c>
	if (sum(conf, conf->length) != 0) {
f0105ef6:	84 d2                	test   %dl,%dl
f0105ef8:	75 15                	jne    f0105f0f <mp_init+0x160>
	if (conf->version != 1 && conf->version != 4) {
f0105efa:	8a 57 06             	mov    0x6(%edi),%dl
f0105efd:	80 fa 01             	cmp    $0x1,%dl
f0105f00:	74 05                	je     f0105f07 <mp_init+0x158>
f0105f02:	80 fa 04             	cmp    $0x4,%dl
f0105f05:	75 1d                	jne    f0105f24 <mp_init+0x175>
f0105f07:	0f b7 4f 28          	movzwl 0x28(%edi),%ecx
f0105f0b:	01 d9                	add    %ebx,%ecx
f0105f0d:	eb 34                	jmp    f0105f43 <mp_init+0x194>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105f0f:	83 ec 0c             	sub    $0xc,%esp
f0105f12:	68 b8 84 10 f0       	push   $0xf01084b8
f0105f17:	e8 59 e0 ff ff       	call   f0103f75 <cprintf>
f0105f1c:	83 c4 10             	add    $0x10,%esp
f0105f1f:	e9 3b 01 00 00       	jmp    f010605f <mp_init+0x2b0>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105f24:	83 ec 08             	sub    $0x8,%esp
f0105f27:	0f b6 d2             	movzbl %dl,%edx
f0105f2a:	52                   	push   %edx
f0105f2b:	68 dc 84 10 f0       	push   $0xf01084dc
f0105f30:	e8 40 e0 ff ff       	call   f0103f75 <cprintf>
f0105f35:	83 c4 10             	add    $0x10,%esp
f0105f38:	e9 22 01 00 00       	jmp    f010605f <mp_init+0x2b0>
		sum += ((uint8_t *)addr)[i];
f0105f3d:	0f b6 13             	movzbl (%ebx),%edx
f0105f40:	01 d0                	add    %edx,%eax
f0105f42:	43                   	inc    %ebx
	for (i = 0; i < len; i++)
f0105f43:	39 d9                	cmp    %ebx,%ecx
f0105f45:	75 f6                	jne    f0105f3d <mp_init+0x18e>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105f47:	02 47 2a             	add    0x2a(%edi),%al
f0105f4a:	75 28                	jne    f0105f74 <mp_init+0x1c5>
	if ((conf = mpconfig(&mp)) == 0)
f0105f4c:	81 fe 00 00 00 10    	cmp    $0x10000000,%esi
f0105f52:	0f 84 07 01 00 00    	je     f010605f <mp_init+0x2b0>
		return;
	ismp = 1;
f0105f58:	c7 05 00 20 29 f0 01 	movl   $0x1,0xf0292000
f0105f5f:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105f62:	8b 47 24             	mov    0x24(%edi),%eax
f0105f65:	a3 00 30 2d f0       	mov    %eax,0xf02d3000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105f6a:	8d 77 2c             	lea    0x2c(%edi),%esi
f0105f6d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105f72:	eb 60                	jmp    f0105fd4 <mp_init+0x225>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105f74:	83 ec 0c             	sub    $0xc,%esp
f0105f77:	68 fc 84 10 f0       	push   $0xf01084fc
f0105f7c:	e8 f4 df ff ff       	call   f0103f75 <cprintf>
f0105f81:	83 c4 10             	add    $0x10,%esp
f0105f84:	e9 d6 00 00 00       	jmp    f010605f <mp_init+0x2b0>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105f89:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f0105f8d:	74 1e                	je     f0105fad <mp_init+0x1fe>
				bootcpu = &cpus[ncpu];
f0105f8f:	8b 15 c4 23 29 f0    	mov    0xf02923c4,%edx
f0105f95:	8d 04 12             	lea    (%edx,%edx,1),%eax
f0105f98:	01 d0                	add    %edx,%eax
f0105f9a:	01 c0                	add    %eax,%eax
f0105f9c:	01 d0                	add    %edx,%eax
f0105f9e:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0105fa1:	8d 04 85 20 20 29 f0 	lea    -0xfd6dfe0(,%eax,4),%eax
f0105fa8:	a3 c0 23 29 f0       	mov    %eax,0xf02923c0
			if (ncpu < NCPU) {
f0105fad:	a1 c4 23 29 f0       	mov    0xf02923c4,%eax
f0105fb2:	83 f8 07             	cmp    $0x7,%eax
f0105fb5:	7f 34                	jg     f0105feb <mp_init+0x23c>
				cpus[ncpu].cpu_id = ncpu;
f0105fb7:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0105fba:	01 c2                	add    %eax,%edx
f0105fbc:	01 d2                	add    %edx,%edx
f0105fbe:	01 c2                	add    %eax,%edx
f0105fc0:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0105fc3:	88 04 95 20 20 29 f0 	mov    %al,-0xfd6dfe0(,%edx,4)
				ncpu++;
f0105fca:	40                   	inc    %eax
f0105fcb:	a3 c4 23 29 f0       	mov    %eax,0xf02923c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105fd0:	83 c6 14             	add    $0x14,%esi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105fd3:	43                   	inc    %ebx
f0105fd4:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f0105fd8:	39 d8                	cmp    %ebx,%eax
f0105fda:	76 4a                	jbe    f0106026 <mp_init+0x277>
		switch (*p) {
f0105fdc:	8a 06                	mov    (%esi),%al
f0105fde:	84 c0                	test   %al,%al
f0105fe0:	74 a7                	je     f0105f89 <mp_init+0x1da>
f0105fe2:	3c 04                	cmp    $0x4,%al
f0105fe4:	77 1c                	ja     f0106002 <mp_init+0x253>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105fe6:	83 c6 08             	add    $0x8,%esi
			continue;
f0105fe9:	eb e8                	jmp    f0105fd3 <mp_init+0x224>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105feb:	83 ec 08             	sub    $0x8,%esp
f0105fee:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0105ff2:	50                   	push   %eax
f0105ff3:	68 2c 85 10 f0       	push   $0xf010852c
f0105ff8:	e8 78 df ff ff       	call   f0103f75 <cprintf>
f0105ffd:	83 c4 10             	add    $0x10,%esp
f0106000:	eb ce                	jmp    f0105fd0 <mp_init+0x221>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106002:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0106005:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f0106008:	50                   	push   %eax
f0106009:	68 54 85 10 f0       	push   $0xf0108554
f010600e:	e8 62 df ff ff       	call   f0103f75 <cprintf>
			ismp = 0;
f0106013:	c7 05 00 20 29 f0 00 	movl   $0x0,0xf0292000
f010601a:	00 00 00 
			i = conf->entry;
f010601d:	0f b7 5f 22          	movzwl 0x22(%edi),%ebx
f0106021:	83 c4 10             	add    $0x10,%esp
f0106024:	eb ad                	jmp    f0105fd3 <mp_init+0x224>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106026:	a1 c0 23 29 f0       	mov    0xf02923c0,%eax
f010602b:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106032:	83 3d 00 20 29 f0 00 	cmpl   $0x0,0xf0292000
f0106039:	75 2c                	jne    f0106067 <mp_init+0x2b8>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f010603b:	c7 05 c4 23 29 f0 01 	movl   $0x1,0xf02923c4
f0106042:	00 00 00 
		lapicaddr = 0;
f0106045:	c7 05 00 30 2d f0 00 	movl   $0x0,0xf02d3000
f010604c:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f010604f:	83 ec 0c             	sub    $0xc,%esp
f0106052:	68 74 85 10 f0       	push   $0xf0108574
f0106057:	e8 19 df ff ff       	call   f0103f75 <cprintf>
		return;
f010605c:	83 c4 10             	add    $0x10,%esp
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f010605f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106062:	5b                   	pop    %ebx
f0106063:	5e                   	pop    %esi
f0106064:	5f                   	pop    %edi
f0106065:	5d                   	pop    %ebp
f0106066:	c3                   	ret    
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106067:	83 ec 04             	sub    $0x4,%esp
f010606a:	ff 35 c4 23 29 f0    	pushl  0xf02923c4
f0106070:	0f b6 00             	movzbl (%eax),%eax
f0106073:	50                   	push   %eax
f0106074:	68 fb 85 10 f0       	push   $0xf01085fb
f0106079:	e8 f7 de ff ff       	call   f0103f75 <cprintf>
	if (mp->imcrp) {
f010607e:	83 c4 10             	add    $0x10,%esp
f0106081:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106084:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106088:	74 d5                	je     f010605f <mp_init+0x2b0>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f010608a:	83 ec 0c             	sub    $0xc,%esp
f010608d:	68 a0 85 10 f0       	push   $0xf01085a0
f0106092:	e8 de de ff ff       	call   f0103f75 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106097:	b0 70                	mov    $0x70,%al
f0106099:	ba 22 00 00 00       	mov    $0x22,%edx
f010609e:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010609f:	ba 23 00 00 00       	mov    $0x23,%edx
f01060a4:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f01060a5:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01060a8:	ee                   	out    %al,(%dx)
f01060a9:	83 c4 10             	add    $0x10,%esp
f01060ac:	eb b1                	jmp    f010605f <mp_init+0x2b0>

f01060ae <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f01060ae:	55                   	push   %ebp
f01060af:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01060b1:	8b 0d 04 30 2d f0    	mov    0xf02d3004,%ecx
f01060b7:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01060ba:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01060bc:	a1 04 30 2d f0       	mov    0xf02d3004,%eax
f01060c1:	8b 40 20             	mov    0x20(%eax),%eax
}
f01060c4:	5d                   	pop    %ebp
f01060c5:	c3                   	ret    

f01060c6 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f01060c6:	55                   	push   %ebp
f01060c7:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01060c9:	a1 04 30 2d f0       	mov    0xf02d3004,%eax
f01060ce:	85 c0                	test   %eax,%eax
f01060d0:	74 08                	je     f01060da <cpunum+0x14>
		return lapic[ID] >> 24;
f01060d2:	8b 40 20             	mov    0x20(%eax),%eax
f01060d5:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f01060d8:	5d                   	pop    %ebp
f01060d9:	c3                   	ret    
	return 0;
f01060da:	b8 00 00 00 00       	mov    $0x0,%eax
f01060df:	eb f7                	jmp    f01060d8 <cpunum+0x12>

f01060e1 <lapic_init>:
	if (!lapicaddr)
f01060e1:	a1 00 30 2d f0       	mov    0xf02d3000,%eax
f01060e6:	85 c0                	test   %eax,%eax
f01060e8:	75 01                	jne    f01060eb <lapic_init+0xa>
f01060ea:	c3                   	ret    
{
f01060eb:	55                   	push   %ebp
f01060ec:	89 e5                	mov    %esp,%ebp
f01060ee:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f01060f1:	68 00 10 00 00       	push   $0x1000
f01060f6:	50                   	push   %eax
f01060f7:	e8 8c b6 ff ff       	call   f0101788 <mmio_map_region>
f01060fc:	a3 04 30 2d f0       	mov    %eax,0xf02d3004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106101:	ba 27 01 00 00       	mov    $0x127,%edx
f0106106:	b8 3c 00 00 00       	mov    $0x3c,%eax
f010610b:	e8 9e ff ff ff       	call   f01060ae <lapicw>
	lapicw(TDCR, X1);
f0106110:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106115:	b8 f8 00 00 00       	mov    $0xf8,%eax
f010611a:	e8 8f ff ff ff       	call   f01060ae <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010611f:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106124:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106129:	e8 80 ff ff ff       	call   f01060ae <lapicw>
	lapicw(TICR, 10000000); 
f010612e:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106133:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106138:	e8 71 ff ff ff       	call   f01060ae <lapicw>
	if (thiscpu != bootcpu)
f010613d:	e8 84 ff ff ff       	call   f01060c6 <cpunum>
f0106142:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0106145:	01 c2                	add    %eax,%edx
f0106147:	01 d2                	add    %edx,%edx
f0106149:	01 c2                	add    %eax,%edx
f010614b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010614e:	8d 04 85 20 20 29 f0 	lea    -0xfd6dfe0(,%eax,4),%eax
f0106155:	83 c4 10             	add    $0x10,%esp
f0106158:	39 05 c0 23 29 f0    	cmp    %eax,0xf02923c0
f010615e:	74 0f                	je     f010616f <lapic_init+0x8e>
		lapicw(LINT0, MASKED);
f0106160:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106165:	b8 d4 00 00 00       	mov    $0xd4,%eax
f010616a:	e8 3f ff ff ff       	call   f01060ae <lapicw>
	lapicw(LINT1, MASKED);
f010616f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106174:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106179:	e8 30 ff ff ff       	call   f01060ae <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f010617e:	a1 04 30 2d f0       	mov    0xf02d3004,%eax
f0106183:	8b 40 30             	mov    0x30(%eax),%eax
f0106186:	c1 e8 10             	shr    $0x10,%eax
f0106189:	3c 03                	cmp    $0x3,%al
f010618b:	77 7c                	ja     f0106209 <lapic_init+0x128>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f010618d:	ba 33 00 00 00       	mov    $0x33,%edx
f0106192:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106197:	e8 12 ff ff ff       	call   f01060ae <lapicw>
	lapicw(ESR, 0);
f010619c:	ba 00 00 00 00       	mov    $0x0,%edx
f01061a1:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01061a6:	e8 03 ff ff ff       	call   f01060ae <lapicw>
	lapicw(ESR, 0);
f01061ab:	ba 00 00 00 00       	mov    $0x0,%edx
f01061b0:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01061b5:	e8 f4 fe ff ff       	call   f01060ae <lapicw>
	lapicw(EOI, 0);
f01061ba:	ba 00 00 00 00       	mov    $0x0,%edx
f01061bf:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01061c4:	e8 e5 fe ff ff       	call   f01060ae <lapicw>
	lapicw(ICRHI, 0);
f01061c9:	ba 00 00 00 00       	mov    $0x0,%edx
f01061ce:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01061d3:	e8 d6 fe ff ff       	call   f01060ae <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01061d8:	ba 00 85 08 00       	mov    $0x88500,%edx
f01061dd:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01061e2:	e8 c7 fe ff ff       	call   f01060ae <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01061e7:	8b 15 04 30 2d f0    	mov    0xf02d3004,%edx
f01061ed:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01061f3:	f6 c4 10             	test   $0x10,%ah
f01061f6:	75 f5                	jne    f01061ed <lapic_init+0x10c>
	lapicw(TPR, 0);
f01061f8:	ba 00 00 00 00       	mov    $0x0,%edx
f01061fd:	b8 20 00 00 00       	mov    $0x20,%eax
f0106202:	e8 a7 fe ff ff       	call   f01060ae <lapicw>
}
f0106207:	c9                   	leave  
f0106208:	c3                   	ret    
		lapicw(PCINT, MASKED);
f0106209:	ba 00 00 01 00       	mov    $0x10000,%edx
f010620e:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106213:	e8 96 fe ff ff       	call   f01060ae <lapicw>
f0106218:	e9 70 ff ff ff       	jmp    f010618d <lapic_init+0xac>

f010621d <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f010621d:	83 3d 04 30 2d f0 00 	cmpl   $0x0,0xf02d3004
f0106224:	74 14                	je     f010623a <lapic_eoi+0x1d>
{
f0106226:	55                   	push   %ebp
f0106227:	89 e5                	mov    %esp,%ebp
		lapicw(EOI, 0);
f0106229:	ba 00 00 00 00       	mov    $0x0,%edx
f010622e:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106233:	e8 76 fe ff ff       	call   f01060ae <lapicw>
}
f0106238:	5d                   	pop    %ebp
f0106239:	c3                   	ret    
f010623a:	c3                   	ret    

f010623b <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f010623b:	55                   	push   %ebp
f010623c:	89 e5                	mov    %esp,%ebp
f010623e:	56                   	push   %esi
f010623f:	53                   	push   %ebx
f0106240:	8b 75 08             	mov    0x8(%ebp),%esi
f0106243:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106246:	b0 0f                	mov    $0xf,%al
f0106248:	ba 70 00 00 00       	mov    $0x70,%edx
f010624d:	ee                   	out    %al,(%dx)
f010624e:	b0 0a                	mov    $0xa,%al
f0106250:	ba 71 00 00 00       	mov    $0x71,%edx
f0106255:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f0106256:	83 3d 88 1e 29 f0 00 	cmpl   $0x0,0xf0291e88
f010625d:	74 7e                	je     f01062dd <lapic_startap+0xa2>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f010625f:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106266:	00 00 
	wrv[1] = addr >> 4;
f0106268:	89 d8                	mov    %ebx,%eax
f010626a:	c1 e8 04             	shr    $0x4,%eax
f010626d:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106273:	c1 e6 18             	shl    $0x18,%esi
f0106276:	89 f2                	mov    %esi,%edx
f0106278:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010627d:	e8 2c fe ff ff       	call   f01060ae <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106282:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106287:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010628c:	e8 1d fe ff ff       	call   f01060ae <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106291:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106296:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010629b:	e8 0e fe ff ff       	call   f01060ae <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01062a0:	c1 eb 0c             	shr    $0xc,%ebx
f01062a3:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f01062a6:	89 f2                	mov    %esi,%edx
f01062a8:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01062ad:	e8 fc fd ff ff       	call   f01060ae <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01062b2:	89 da                	mov    %ebx,%edx
f01062b4:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01062b9:	e8 f0 fd ff ff       	call   f01060ae <lapicw>
		lapicw(ICRHI, apicid << 24);
f01062be:	89 f2                	mov    %esi,%edx
f01062c0:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01062c5:	e8 e4 fd ff ff       	call   f01060ae <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01062ca:	89 da                	mov    %ebx,%edx
f01062cc:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01062d1:	e8 d8 fd ff ff       	call   f01060ae <lapicw>
		microdelay(200);
	}
}
f01062d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01062d9:	5b                   	pop    %ebx
f01062da:	5e                   	pop    %esi
f01062db:	5d                   	pop    %ebp
f01062dc:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01062dd:	68 67 04 00 00       	push   $0x467
f01062e2:	68 48 68 10 f0       	push   $0xf0106848
f01062e7:	68 98 00 00 00       	push   $0x98
f01062ec:	68 18 86 10 f0       	push   $0xf0108618
f01062f1:	e8 9e 9d ff ff       	call   f0100094 <_panic>

f01062f6 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01062f6:	55                   	push   %ebp
f01062f7:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01062f9:	8b 55 08             	mov    0x8(%ebp),%edx
f01062fc:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106302:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106307:	e8 a2 fd ff ff       	call   f01060ae <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010630c:	8b 15 04 30 2d f0    	mov    0xf02d3004,%edx
f0106312:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106318:	f6 c4 10             	test   $0x10,%ah
f010631b:	75 f5                	jne    f0106312 <lapic_ipi+0x1c>
		;
}
f010631d:	5d                   	pop    %ebp
f010631e:	c3                   	ret    

f010631f <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010631f:	55                   	push   %ebp
f0106320:	89 e5                	mov    %esp,%ebp
f0106322:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106325:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f010632b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010632e:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106331:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106338:	5d                   	pop    %ebp
f0106339:	c3                   	ret    

f010633a <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f010633a:	55                   	push   %ebp
f010633b:	89 e5                	mov    %esp,%ebp
f010633d:	56                   	push   %esi
f010633e:	53                   	push   %ebx
f010633f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f0106342:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106345:	75 07                	jne    f010634e <spin_lock+0x14>
	asm volatile("lock; xchgl %0, %1"
f0106347:	ba 01 00 00 00       	mov    $0x1,%edx
f010634c:	eb 3f                	jmp    f010638d <spin_lock+0x53>
f010634e:	8b 73 08             	mov    0x8(%ebx),%esi
f0106351:	e8 70 fd ff ff       	call   f01060c6 <cpunum>
f0106356:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0106359:	01 c2                	add    %eax,%edx
f010635b:	01 d2                	add    %edx,%edx
f010635d:	01 c2                	add    %eax,%edx
f010635f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106362:	8d 04 85 20 20 29 f0 	lea    -0xfd6dfe0(,%eax,4),%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106369:	39 c6                	cmp    %eax,%esi
f010636b:	75 da                	jne    f0106347 <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f010636d:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106370:	e8 51 fd ff ff       	call   f01060c6 <cpunum>
f0106375:	83 ec 0c             	sub    $0xc,%esp
f0106378:	53                   	push   %ebx
f0106379:	50                   	push   %eax
f010637a:	68 28 86 10 f0       	push   $0xf0108628
f010637f:	6a 41                	push   $0x41
f0106381:	68 8c 86 10 f0       	push   $0xf010868c
f0106386:	e8 09 9d ff ff       	call   f0100094 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010638b:	f3 90                	pause  
f010638d:	89 d0                	mov    %edx,%eax
f010638f:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f0106392:	85 c0                	test   %eax,%eax
f0106394:	75 f5                	jne    f010638b <spin_lock+0x51>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106396:	e8 2b fd ff ff       	call   f01060c6 <cpunum>
f010639b:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010639e:	01 c2                	add    %eax,%edx
f01063a0:	01 d2                	add    %edx,%edx
f01063a2:	01 c2                	add    %eax,%edx
f01063a4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01063a7:	8d 04 85 20 20 29 f0 	lea    -0xfd6dfe0(,%eax,4),%eax
f01063ae:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01063b1:	83 c3 0c             	add    $0xc,%ebx
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01063b4:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f01063b6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01063bb:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01063c1:	76 1d                	jbe    f01063e0 <spin_lock+0xa6>
		pcs[i] = ebp[1];          // saved %eip
f01063c3:	8b 4a 04             	mov    0x4(%edx),%ecx
f01063c6:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01063c9:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f01063cb:	40                   	inc    %eax
f01063cc:	83 f8 0a             	cmp    $0xa,%eax
f01063cf:	75 ea                	jne    f01063bb <spin_lock+0x81>
#endif
}
f01063d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01063d4:	5b                   	pop    %ebx
f01063d5:	5e                   	pop    %esi
f01063d6:	5d                   	pop    %ebp
f01063d7:	c3                   	ret    
		pcs[i] = 0;
f01063d8:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
	for (; i < 10; i++)
f01063df:	40                   	inc    %eax
f01063e0:	83 f8 09             	cmp    $0x9,%eax
f01063e3:	7e f3                	jle    f01063d8 <spin_lock+0x9e>
f01063e5:	eb ea                	jmp    f01063d1 <spin_lock+0x97>

f01063e7 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01063e7:	55                   	push   %ebp
f01063e8:	89 e5                	mov    %esp,%ebp
f01063ea:	57                   	push   %edi
f01063eb:	56                   	push   %esi
f01063ec:	53                   	push   %ebx
f01063ed:	83 ec 4c             	sub    $0x4c,%esp
f01063f0:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f01063f3:	83 3e 00             	cmpl   $0x0,(%esi)
f01063f6:	75 35                	jne    f010642d <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01063f8:	83 ec 04             	sub    $0x4,%esp
f01063fb:	6a 28                	push   $0x28
f01063fd:	8d 46 0c             	lea    0xc(%esi),%eax
f0106400:	50                   	push   %eax
f0106401:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106404:	53                   	push   %ebx
f0106405:	e8 31 f6 ff ff       	call   f0105a3b <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f010640a:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f010640d:	0f b6 38             	movzbl (%eax),%edi
f0106410:	8b 76 04             	mov    0x4(%esi),%esi
f0106413:	e8 ae fc ff ff       	call   f01060c6 <cpunum>
f0106418:	57                   	push   %edi
f0106419:	56                   	push   %esi
f010641a:	50                   	push   %eax
f010641b:	68 54 86 10 f0       	push   $0xf0108654
f0106420:	e8 50 db ff ff       	call   f0103f75 <cprintf>
f0106425:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106428:	8d 7d a8             	lea    -0x58(%ebp),%edi
f010642b:	eb 6c                	jmp    f0106499 <spin_unlock+0xb2>
	return lock->locked && lock->cpu == thiscpu;
f010642d:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106430:	e8 91 fc ff ff       	call   f01060c6 <cpunum>
f0106435:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0106438:	01 c2                	add    %eax,%edx
f010643a:	01 d2                	add    %edx,%edx
f010643c:	01 c2                	add    %eax,%edx
f010643e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106441:	8d 04 85 20 20 29 f0 	lea    -0xfd6dfe0(,%eax,4),%eax
	if (!holding(lk)) {
f0106448:	39 c3                	cmp    %eax,%ebx
f010644a:	75 ac                	jne    f01063f8 <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f010644c:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106453:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f010645a:	b8 00 00 00 00       	mov    $0x0,%eax
f010645f:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0106462:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106465:	5b                   	pop    %ebx
f0106466:	5e                   	pop    %esi
f0106467:	5f                   	pop    %edi
f0106468:	5d                   	pop    %ebp
f0106469:	c3                   	ret    
					pcs[i] - info.eip_fn_addr);
f010646a:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f010646c:	83 ec 04             	sub    $0x4,%esp
f010646f:	89 c2                	mov    %eax,%edx
f0106471:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106474:	52                   	push   %edx
f0106475:	ff 75 b0             	pushl  -0x50(%ebp)
f0106478:	ff 75 b4             	pushl  -0x4c(%ebp)
f010647b:	ff 75 ac             	pushl  -0x54(%ebp)
f010647e:	ff 75 a8             	pushl  -0x58(%ebp)
f0106481:	50                   	push   %eax
f0106482:	68 9c 86 10 f0       	push   $0xf010869c
f0106487:	e8 e9 da ff ff       	call   f0103f75 <cprintf>
f010648c:	83 c4 20             	add    $0x20,%esp
f010648f:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106492:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106495:	39 c3                	cmp    %eax,%ebx
f0106497:	74 2d                	je     f01064c6 <spin_unlock+0xdf>
f0106499:	89 de                	mov    %ebx,%esi
f010649b:	8b 03                	mov    (%ebx),%eax
f010649d:	85 c0                	test   %eax,%eax
f010649f:	74 25                	je     f01064c6 <spin_unlock+0xdf>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01064a1:	83 ec 08             	sub    $0x8,%esp
f01064a4:	57                   	push   %edi
f01064a5:	50                   	push   %eax
f01064a6:	e8 02 eb ff ff       	call   f0104fad <debuginfo_eip>
f01064ab:	83 c4 10             	add    $0x10,%esp
f01064ae:	85 c0                	test   %eax,%eax
f01064b0:	79 b8                	jns    f010646a <spin_unlock+0x83>
				cprintf("  %08x\n", pcs[i]);
f01064b2:	83 ec 08             	sub    $0x8,%esp
f01064b5:	ff 36                	pushl  (%esi)
f01064b7:	68 b3 86 10 f0       	push   $0xf01086b3
f01064bc:	e8 b4 da ff ff       	call   f0103f75 <cprintf>
f01064c1:	83 c4 10             	add    $0x10,%esp
f01064c4:	eb c9                	jmp    f010648f <spin_unlock+0xa8>
		panic("spin_unlock");
f01064c6:	83 ec 04             	sub    $0x4,%esp
f01064c9:	68 bb 86 10 f0       	push   $0xf01086bb
f01064ce:	6a 67                	push   $0x67
f01064d0:	68 8c 86 10 f0       	push   $0xf010868c
f01064d5:	e8 ba 9b ff ff       	call   f0100094 <_panic>
f01064da:	66 90                	xchg   %ax,%ax

f01064dc <__udivdi3>:
f01064dc:	55                   	push   %ebp
f01064dd:	57                   	push   %edi
f01064de:	56                   	push   %esi
f01064df:	53                   	push   %ebx
f01064e0:	83 ec 1c             	sub    $0x1c,%esp
f01064e3:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01064e7:	8b 74 24 34          	mov    0x34(%esp),%esi
f01064eb:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01064ef:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01064f3:	85 d2                	test   %edx,%edx
f01064f5:	75 2d                	jne    f0106524 <__udivdi3+0x48>
f01064f7:	39 f7                	cmp    %esi,%edi
f01064f9:	77 59                	ja     f0106554 <__udivdi3+0x78>
f01064fb:	89 f9                	mov    %edi,%ecx
f01064fd:	85 ff                	test   %edi,%edi
f01064ff:	75 0b                	jne    f010650c <__udivdi3+0x30>
f0106501:	b8 01 00 00 00       	mov    $0x1,%eax
f0106506:	31 d2                	xor    %edx,%edx
f0106508:	f7 f7                	div    %edi
f010650a:	89 c1                	mov    %eax,%ecx
f010650c:	31 d2                	xor    %edx,%edx
f010650e:	89 f0                	mov    %esi,%eax
f0106510:	f7 f1                	div    %ecx
f0106512:	89 c3                	mov    %eax,%ebx
f0106514:	89 e8                	mov    %ebp,%eax
f0106516:	f7 f1                	div    %ecx
f0106518:	89 da                	mov    %ebx,%edx
f010651a:	83 c4 1c             	add    $0x1c,%esp
f010651d:	5b                   	pop    %ebx
f010651e:	5e                   	pop    %esi
f010651f:	5f                   	pop    %edi
f0106520:	5d                   	pop    %ebp
f0106521:	c3                   	ret    
f0106522:	66 90                	xchg   %ax,%ax
f0106524:	39 f2                	cmp    %esi,%edx
f0106526:	77 1c                	ja     f0106544 <__udivdi3+0x68>
f0106528:	0f bd da             	bsr    %edx,%ebx
f010652b:	83 f3 1f             	xor    $0x1f,%ebx
f010652e:	75 38                	jne    f0106568 <__udivdi3+0x8c>
f0106530:	39 f2                	cmp    %esi,%edx
f0106532:	72 08                	jb     f010653c <__udivdi3+0x60>
f0106534:	39 ef                	cmp    %ebp,%edi
f0106536:	0f 87 98 00 00 00    	ja     f01065d4 <__udivdi3+0xf8>
f010653c:	b8 01 00 00 00       	mov    $0x1,%eax
f0106541:	eb 05                	jmp    f0106548 <__udivdi3+0x6c>
f0106543:	90                   	nop
f0106544:	31 db                	xor    %ebx,%ebx
f0106546:	31 c0                	xor    %eax,%eax
f0106548:	89 da                	mov    %ebx,%edx
f010654a:	83 c4 1c             	add    $0x1c,%esp
f010654d:	5b                   	pop    %ebx
f010654e:	5e                   	pop    %esi
f010654f:	5f                   	pop    %edi
f0106550:	5d                   	pop    %ebp
f0106551:	c3                   	ret    
f0106552:	66 90                	xchg   %ax,%ax
f0106554:	89 e8                	mov    %ebp,%eax
f0106556:	89 f2                	mov    %esi,%edx
f0106558:	f7 f7                	div    %edi
f010655a:	31 db                	xor    %ebx,%ebx
f010655c:	89 da                	mov    %ebx,%edx
f010655e:	83 c4 1c             	add    $0x1c,%esp
f0106561:	5b                   	pop    %ebx
f0106562:	5e                   	pop    %esi
f0106563:	5f                   	pop    %edi
f0106564:	5d                   	pop    %ebp
f0106565:	c3                   	ret    
f0106566:	66 90                	xchg   %ax,%ax
f0106568:	b8 20 00 00 00       	mov    $0x20,%eax
f010656d:	29 d8                	sub    %ebx,%eax
f010656f:	88 d9                	mov    %bl,%cl
f0106571:	d3 e2                	shl    %cl,%edx
f0106573:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106577:	89 fa                	mov    %edi,%edx
f0106579:	88 c1                	mov    %al,%cl
f010657b:	d3 ea                	shr    %cl,%edx
f010657d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106581:	09 d1                	or     %edx,%ecx
f0106583:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106587:	88 d9                	mov    %bl,%cl
f0106589:	d3 e7                	shl    %cl,%edi
f010658b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010658f:	89 f7                	mov    %esi,%edi
f0106591:	88 c1                	mov    %al,%cl
f0106593:	d3 ef                	shr    %cl,%edi
f0106595:	88 d9                	mov    %bl,%cl
f0106597:	d3 e6                	shl    %cl,%esi
f0106599:	89 ea                	mov    %ebp,%edx
f010659b:	88 c1                	mov    %al,%cl
f010659d:	d3 ea                	shr    %cl,%edx
f010659f:	09 d6                	or     %edx,%esi
f01065a1:	89 f0                	mov    %esi,%eax
f01065a3:	89 fa                	mov    %edi,%edx
f01065a5:	f7 74 24 08          	divl   0x8(%esp)
f01065a9:	89 d7                	mov    %edx,%edi
f01065ab:	89 c6                	mov    %eax,%esi
f01065ad:	f7 64 24 0c          	mull   0xc(%esp)
f01065b1:	39 d7                	cmp    %edx,%edi
f01065b3:	72 13                	jb     f01065c8 <__udivdi3+0xec>
f01065b5:	74 09                	je     f01065c0 <__udivdi3+0xe4>
f01065b7:	89 f0                	mov    %esi,%eax
f01065b9:	31 db                	xor    %ebx,%ebx
f01065bb:	eb 8b                	jmp    f0106548 <__udivdi3+0x6c>
f01065bd:	8d 76 00             	lea    0x0(%esi),%esi
f01065c0:	88 d9                	mov    %bl,%cl
f01065c2:	d3 e5                	shl    %cl,%ebp
f01065c4:	39 c5                	cmp    %eax,%ebp
f01065c6:	73 ef                	jae    f01065b7 <__udivdi3+0xdb>
f01065c8:	8d 46 ff             	lea    -0x1(%esi),%eax
f01065cb:	31 db                	xor    %ebx,%ebx
f01065cd:	e9 76 ff ff ff       	jmp    f0106548 <__udivdi3+0x6c>
f01065d2:	66 90                	xchg   %ax,%ax
f01065d4:	31 c0                	xor    %eax,%eax
f01065d6:	e9 6d ff ff ff       	jmp    f0106548 <__udivdi3+0x6c>
f01065db:	90                   	nop

f01065dc <__umoddi3>:
f01065dc:	55                   	push   %ebp
f01065dd:	57                   	push   %edi
f01065de:	56                   	push   %esi
f01065df:	53                   	push   %ebx
f01065e0:	83 ec 1c             	sub    $0x1c,%esp
f01065e3:	8b 74 24 30          	mov    0x30(%esp),%esi
f01065e7:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01065eb:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01065ef:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f01065f3:	89 f0                	mov    %esi,%eax
f01065f5:	89 da                	mov    %ebx,%edx
f01065f7:	85 ed                	test   %ebp,%ebp
f01065f9:	75 15                	jne    f0106610 <__umoddi3+0x34>
f01065fb:	39 df                	cmp    %ebx,%edi
f01065fd:	76 39                	jbe    f0106638 <__umoddi3+0x5c>
f01065ff:	f7 f7                	div    %edi
f0106601:	89 d0                	mov    %edx,%eax
f0106603:	31 d2                	xor    %edx,%edx
f0106605:	83 c4 1c             	add    $0x1c,%esp
f0106608:	5b                   	pop    %ebx
f0106609:	5e                   	pop    %esi
f010660a:	5f                   	pop    %edi
f010660b:	5d                   	pop    %ebp
f010660c:	c3                   	ret    
f010660d:	8d 76 00             	lea    0x0(%esi),%esi
f0106610:	39 dd                	cmp    %ebx,%ebp
f0106612:	77 f1                	ja     f0106605 <__umoddi3+0x29>
f0106614:	0f bd cd             	bsr    %ebp,%ecx
f0106617:	83 f1 1f             	xor    $0x1f,%ecx
f010661a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010661e:	75 38                	jne    f0106658 <__umoddi3+0x7c>
f0106620:	39 dd                	cmp    %ebx,%ebp
f0106622:	72 04                	jb     f0106628 <__umoddi3+0x4c>
f0106624:	39 f7                	cmp    %esi,%edi
f0106626:	77 dd                	ja     f0106605 <__umoddi3+0x29>
f0106628:	89 da                	mov    %ebx,%edx
f010662a:	89 f0                	mov    %esi,%eax
f010662c:	29 f8                	sub    %edi,%eax
f010662e:	19 ea                	sbb    %ebp,%edx
f0106630:	83 c4 1c             	add    $0x1c,%esp
f0106633:	5b                   	pop    %ebx
f0106634:	5e                   	pop    %esi
f0106635:	5f                   	pop    %edi
f0106636:	5d                   	pop    %ebp
f0106637:	c3                   	ret    
f0106638:	89 f9                	mov    %edi,%ecx
f010663a:	85 ff                	test   %edi,%edi
f010663c:	75 0b                	jne    f0106649 <__umoddi3+0x6d>
f010663e:	b8 01 00 00 00       	mov    $0x1,%eax
f0106643:	31 d2                	xor    %edx,%edx
f0106645:	f7 f7                	div    %edi
f0106647:	89 c1                	mov    %eax,%ecx
f0106649:	89 d8                	mov    %ebx,%eax
f010664b:	31 d2                	xor    %edx,%edx
f010664d:	f7 f1                	div    %ecx
f010664f:	89 f0                	mov    %esi,%eax
f0106651:	f7 f1                	div    %ecx
f0106653:	eb ac                	jmp    f0106601 <__umoddi3+0x25>
f0106655:	8d 76 00             	lea    0x0(%esi),%esi
f0106658:	b8 20 00 00 00       	mov    $0x20,%eax
f010665d:	89 c2                	mov    %eax,%edx
f010665f:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106663:	29 c2                	sub    %eax,%edx
f0106665:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106669:	88 c1                	mov    %al,%cl
f010666b:	d3 e5                	shl    %cl,%ebp
f010666d:	89 f8                	mov    %edi,%eax
f010666f:	88 d1                	mov    %dl,%cl
f0106671:	d3 e8                	shr    %cl,%eax
f0106673:	09 c5                	or     %eax,%ebp
f0106675:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106679:	88 c1                	mov    %al,%cl
f010667b:	d3 e7                	shl    %cl,%edi
f010667d:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0106681:	89 df                	mov    %ebx,%edi
f0106683:	88 d1                	mov    %dl,%cl
f0106685:	d3 ef                	shr    %cl,%edi
f0106687:	88 c1                	mov    %al,%cl
f0106689:	d3 e3                	shl    %cl,%ebx
f010668b:	89 f0                	mov    %esi,%eax
f010668d:	88 d1                	mov    %dl,%cl
f010668f:	d3 e8                	shr    %cl,%eax
f0106691:	09 d8                	or     %ebx,%eax
f0106693:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0106697:	d3 e6                	shl    %cl,%esi
f0106699:	89 fa                	mov    %edi,%edx
f010669b:	f7 f5                	div    %ebp
f010669d:	89 d1                	mov    %edx,%ecx
f010669f:	f7 64 24 08          	mull   0x8(%esp)
f01066a3:	89 c3                	mov    %eax,%ebx
f01066a5:	89 d7                	mov    %edx,%edi
f01066a7:	39 d1                	cmp    %edx,%ecx
f01066a9:	72 29                	jb     f01066d4 <__umoddi3+0xf8>
f01066ab:	74 23                	je     f01066d0 <__umoddi3+0xf4>
f01066ad:	89 ca                	mov    %ecx,%edx
f01066af:	29 de                	sub    %ebx,%esi
f01066b1:	19 fa                	sbb    %edi,%edx
f01066b3:	89 d0                	mov    %edx,%eax
f01066b5:	8a 4c 24 0c          	mov    0xc(%esp),%cl
f01066b9:	d3 e0                	shl    %cl,%eax
f01066bb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f01066bf:	88 d9                	mov    %bl,%cl
f01066c1:	d3 ee                	shr    %cl,%esi
f01066c3:	09 f0                	or     %esi,%eax
f01066c5:	d3 ea                	shr    %cl,%edx
f01066c7:	83 c4 1c             	add    $0x1c,%esp
f01066ca:	5b                   	pop    %ebx
f01066cb:	5e                   	pop    %esi
f01066cc:	5f                   	pop    %edi
f01066cd:	5d                   	pop    %ebp
f01066ce:	c3                   	ret    
f01066cf:	90                   	nop
f01066d0:	39 c6                	cmp    %eax,%esi
f01066d2:	73 d9                	jae    f01066ad <__umoddi3+0xd1>
f01066d4:	2b 44 24 08          	sub    0x8(%esp),%eax
f01066d8:	19 ea                	sbb    %ebp,%edx
f01066da:	89 d7                	mov    %edx,%edi
f01066dc:	89 c3                	mov    %eax,%ebx
f01066de:	eb cd                	jmp    f01066ad <__umoddi3+0xd1>
