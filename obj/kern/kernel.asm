
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
f010004b:	68 20 68 10 f0       	push   $0xf0106820
f0100050:	e8 3e 3f 00 00       	call   f0103f93 <cprintf>
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
f0100071:	68 3c 68 10 f0       	push   $0xf010683c
f0100076:	e8 18 3f 00 00       	call   f0103f93 <cprintf>
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
f010009c:	83 3d 80 6e 29 f0 00 	cmpl   $0x0,0xf0296e80
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
f01000b4:	89 35 80 6e 29 f0    	mov    %esi,0xf0296e80
	asm volatile("cli; cld");
f01000ba:	fa                   	cli    
f01000bb:	fc                   	cld    
	va_start(ap, fmt);
f01000bc:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f01000bf:	e8 36 61 00 00       	call   f01061fa <cpunum>
f01000c4:	ff 75 0c             	pushl  0xc(%ebp)
f01000c7:	ff 75 08             	pushl  0x8(%ebp)
f01000ca:	50                   	push   %eax
f01000cb:	68 24 69 10 f0       	push   $0xf0106924
f01000d0:	e8 be 3e 00 00       	call   f0103f93 <cprintf>
	vcprintf(fmt, ap);
f01000d5:	83 c4 08             	add    $0x8,%esp
f01000d8:	53                   	push   %ebx
f01000d9:	56                   	push   %esi
f01000da:	e8 8e 3e 00 00       	call   f0103f6d <vcprintf>
	cprintf("\n");
f01000df:	c7 04 24 db 6c 10 f0 	movl   $0xf0106cdb,(%esp)
f01000e6:	e8 a8 3e 00 00       	call   f0103f93 <cprintf>
f01000eb:	83 c4 10             	add    $0x10,%esp
f01000ee:	eb b5                	jmp    f01000a5 <_panic+0x11>

f01000f0 <i386_init>:
{
f01000f0:	55                   	push   %ebp
f01000f1:	89 e5                	mov    %esp,%ebp
f01000f3:	53                   	push   %ebx
f01000f4:	83 ec 08             	sub    $0x8,%esp
	memset(edata, 0, end - edata);
f01000f7:	b8 08 80 2d f0       	mov    $0xf02d8008,%eax
f01000fc:	2d 2c 5c 29 f0       	sub    $0xf0295c2c,%eax
f0100101:	50                   	push   %eax
f0100102:	6a 00                	push   $0x0
f0100104:	68 2c 5c 29 f0       	push   $0xf0295c2c
f0100109:	e8 12 5a 00 00       	call   f0105b20 <memset>
	cons_init();
f010010e:	e8 f5 05 00 00       	call   f0100708 <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f0100113:	83 c4 08             	add    $0x8,%esp
f0100116:	68 ac 1a 00 00       	push   $0x1aac
f010011b:	68 57 68 10 f0       	push   $0xf0106857
f0100120:	e8 6e 3e 00 00       	call   f0103f93 <cprintf>
	mem_init();
f0100125:	e8 bf 16 00 00       	call   f01017e9 <mem_init>
	cprintf(ANSI_COLOR_RED     "This text is RED!"     ANSI_COLOR_RESET "\n");
f010012a:	c7 04 24 72 68 10 f0 	movl   $0xf0106872,(%esp)
f0100131:	e8 5d 3e 00 00       	call   f0103f93 <cprintf>
	cprintf(ANSI_COLOR_GREEN   "This text is GREEN!"   ANSI_COLOR_RESET "\n");
f0100136:	c7 04 24 8e 68 10 f0 	movl   $0xf010688e,(%esp)
f010013d:	e8 51 3e 00 00       	call   f0103f93 <cprintf>
	cprintf(ANSI_COLOR_YELLOW  "This text is YELLOW!"  ANSI_COLOR_RESET "\n");
f0100142:	c7 04 24 48 69 10 f0 	movl   $0xf0106948,(%esp)
f0100149:	e8 45 3e 00 00       	call   f0103f93 <cprintf>
	cprintf(ANSI_COLOR_BLUE    "This text is BLUE!"    ANSI_COLOR_RESET "\n");
f010014e:	c7 04 24 ac 68 10 f0 	movl   $0xf01068ac,(%esp)
f0100155:	e8 39 3e 00 00       	call   f0103f93 <cprintf>
	cprintf(ANSI_COLOR_MAGENTA "This text is MAGENTA!" ANSI_COLOR_RESET "\n");
f010015a:	c7 04 24 68 69 10 f0 	movl   $0xf0106968,(%esp)
f0100161:	e8 2d 3e 00 00       	call   f0103f93 <cprintf>
	cprintf(ANSI_COLOR_CYAN    "This text is CYAN!"    ANSI_COLOR_RESET "\n");
f0100166:	c7 04 24 c9 68 10 f0 	movl   $0xf01068c9,(%esp)
f010016d:	e8 21 3e 00 00       	call   f0103f93 <cprintf>
	test_backtrace(5);
f0100172:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100179:	e8 c2 fe ff ff       	call   f0100040 <test_backtrace>
	env_init();
f010017e:	e8 82 34 00 00       	call   f0103605 <env_init>
	trap_init();
f0100183:	e8 bf 3e 00 00       	call   f0104047 <trap_init>
	mp_init();
f0100188:	e8 56 5d 00 00       	call   f0105ee3 <mp_init>
	lapic_init();
f010018d:	e8 83 60 00 00       	call   f0106215 <lapic_init>
	pic_init();
f0100192:	e8 38 3d 00 00       	call   f0103ecf <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100197:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f010019e:	e8 cb 62 00 00       	call   f010646e <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01001a3:	83 c4 10             	add    $0x10,%esp
f01001a6:	83 3d 88 6e 29 f0 07 	cmpl   $0x7,0xf0296e88
f01001ad:	76 27                	jbe    f01001d6 <i386_init+0xe6>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001af:	83 ec 04             	sub    $0x4,%esp
f01001b2:	b8 4a 5e 10 f0       	mov    $0xf0105e4a,%eax
f01001b7:	2d d0 5d 10 f0       	sub    $0xf0105dd0,%eax
f01001bc:	50                   	push   %eax
f01001bd:	68 d0 5d 10 f0       	push   $0xf0105dd0
f01001c2:	68 00 70 00 f0       	push   $0xf0007000
f01001c7:	e8 a1 59 00 00       	call   f0105b6d <memmove>
f01001cc:	83 c4 10             	add    $0x10,%esp
	for (c = cpus; c < cpus + ncpu; c++) {
f01001cf:	bb 20 70 29 f0       	mov    $0xf0297020,%ebx
f01001d4:	eb 19                	jmp    f01001ef <i386_init+0xff>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001d6:	68 00 70 00 00       	push   $0x7000
f01001db:	68 88 69 10 f0       	push   $0xf0106988
f01001e0:	6a 72                	push   $0x72
f01001e2:	68 e6 68 10 f0       	push   $0xf01068e6
f01001e7:	e8 a8 fe ff ff       	call   f0100094 <_panic>
f01001ec:	83 c3 74             	add    $0x74,%ebx
f01001ef:	8b 15 c4 73 29 f0    	mov    0xf02973c4,%edx
f01001f5:	8d 04 12             	lea    (%edx,%edx,1),%eax
f01001f8:	01 d0                	add    %edx,%eax
f01001fa:	01 c0                	add    %eax,%eax
f01001fc:	01 d0                	add    %edx,%eax
f01001fe:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100201:	8d 04 85 20 70 29 f0 	lea    -0xfd68fe0(,%eax,4),%eax
f0100208:	39 c3                	cmp    %eax,%ebx
f010020a:	73 6d                	jae    f0100279 <i386_init+0x189>
		if (c == cpus + cpunum())  // We've started already.
f010020c:	e8 e9 5f 00 00       	call   f01061fa <cpunum>
f0100211:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100214:	01 c2                	add    %eax,%edx
f0100216:	01 d2                	add    %edx,%edx
f0100218:	01 c2                	add    %eax,%edx
f010021a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010021d:	8d 04 85 20 70 29 f0 	lea    -0xfd68fe0(,%eax,4),%eax
f0100224:	39 c3                	cmp    %eax,%ebx
f0100226:	74 c4                	je     f01001ec <i386_init+0xfc>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100228:	89 d8                	mov    %ebx,%eax
f010022a:	2d 20 70 29 f0       	sub    $0xf0297020,%eax
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
f010024e:	05 00 00 2a f0       	add    $0xf02a0000,%eax
f0100253:	a3 84 6e 29 f0       	mov    %eax,0xf0296e84
		lapic_startap(c->cpu_id, PADDR(code));
f0100258:	83 ec 08             	sub    $0x8,%esp
f010025b:	68 00 70 00 00       	push   $0x7000
f0100260:	0f b6 03             	movzbl (%ebx),%eax
f0100263:	50                   	push   %eax
f0100264:	e8 06 61 00 00       	call   f010636f <lapic_startap>
f0100269:	83 c4 10             	add    $0x10,%esp
		while(c->cpu_status != CPU_STARTED)
f010026c:	8b 43 04             	mov    0x4(%ebx),%eax
f010026f:	83 f8 01             	cmp    $0x1,%eax
f0100272:	75 f8                	jne    f010026c <i386_init+0x17c>
f0100274:	e9 73 ff ff ff       	jmp    f01001ec <i386_init+0xfc>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100279:	83 ec 08             	sub    $0x8,%esp
f010027c:	6a 00                	push   $0x0
f010027e:	68 dc ed 23 f0       	push   $0xf023eddc
f0100283:	e8 c8 35 00 00       	call   f0103850 <env_create>
	sched_yield();
f0100288:	e8 46 48 00 00       	call   f0104ad3 <sched_yield>

f010028d <mp_main>:
{
f010028d:	55                   	push   %ebp
f010028e:	89 e5                	mov    %esp,%ebp
f0100290:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f0100293:	a1 8c 6e 29 f0       	mov    0xf0296e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0100298:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010029d:	77 15                	ja     f01002b4 <mp_main+0x27>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010029f:	50                   	push   %eax
f01002a0:	68 ac 69 10 f0       	push   $0xf01069ac
f01002a5:	68 89 00 00 00       	push   $0x89
f01002aa:	68 e6 68 10 f0       	push   $0xf01068e6
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
f01002bc:	e8 39 5f 00 00       	call   f01061fa <cpunum>
f01002c1:	83 ec 08             	sub    $0x8,%esp
f01002c4:	50                   	push   %eax
f01002c5:	68 f2 68 10 f0       	push   $0xf01068f2
f01002ca:	e8 c4 3c 00 00       	call   f0103f93 <cprintf>
	lapic_init();
f01002cf:	e8 41 5f 00 00       	call   f0106215 <lapic_init>
	env_init_percpu();
f01002d4:	e8 fc 32 00 00       	call   f01035d5 <env_init_percpu>
	trap_init_percpu();
f01002d9:	e8 c9 3c 00 00       	call   f0103fa7 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01002de:	e8 17 5f 00 00       	call   f01061fa <cpunum>
f01002e3:	6b d0 74             	imul   $0x74,%eax,%edx
f01002e6:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01002e9:	b8 01 00 00 00       	mov    $0x1,%eax
f01002ee:	f0 87 82 20 70 29 f0 	lock xchg %eax,-0xfd68fe0(%edx)
f01002f5:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f01002fc:	e8 6d 61 00 00       	call   f010646e <spin_lock>
	sched_yield();
f0100301:	e8 cd 47 00 00       	call   f0104ad3 <sched_yield>

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
f0100316:	68 08 69 10 f0       	push   $0xf0106908
f010031b:	e8 73 3c 00 00       	call   f0103f93 <cprintf>
	vcprintf(fmt, ap);
f0100320:	83 c4 08             	add    $0x8,%esp
f0100323:	53                   	push   %ebx
f0100324:	ff 75 10             	pushl  0x10(%ebp)
f0100327:	e8 41 3c 00 00       	call   f0103f6d <vcprintf>
	cprintf("\n");
f010032c:	c7 04 24 db 6c 10 f0 	movl   $0xf0106cdb,(%esp)
f0100333:	e8 5b 3c 00 00       	call   f0103f93 <cprintf>
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
f0100373:	8b 0d 24 62 29 f0    	mov    0xf0296224,%ecx
f0100379:	8d 51 01             	lea    0x1(%ecx),%edx
f010037c:	89 15 24 62 29 f0    	mov    %edx,0xf0296224
f0100382:	88 81 20 60 29 f0    	mov    %al,-0xfd69fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100388:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010038e:	75 d8                	jne    f0100368 <cons_intr+0x9>
			cons.wpos = 0;
f0100390:	c7 05 24 62 29 f0 00 	movl   $0x0,0xf0296224
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
f01003d7:	8b 0d 00 60 29 f0    	mov    0xf0296000,%ecx
f01003dd:	f6 c1 40             	test   $0x40,%cl
f01003e0:	74 0e                	je     f01003f0 <kbd_proc_data+0x4e>
		data |= 0x80;
f01003e2:	83 c8 80             	or     $0xffffff80,%eax
f01003e5:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f01003e7:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003ea:	89 0d 00 60 29 f0    	mov    %ecx,0xf0296000
	shift |= shiftcode[data];
f01003f0:	0f b6 d2             	movzbl %dl,%edx
f01003f3:	0f b6 82 20 6b 10 f0 	movzbl -0xfef94e0(%edx),%eax
f01003fa:	0b 05 00 60 29 f0    	or     0xf0296000,%eax
	shift ^= togglecode[data];
f0100400:	0f b6 8a 20 6a 10 f0 	movzbl -0xfef95e0(%edx),%ecx
f0100407:	31 c8                	xor    %ecx,%eax
f0100409:	a3 00 60 29 f0       	mov    %eax,0xf0296000
	c = charcode[shift & (CTL | SHIFT)][data];
f010040e:	89 c1                	mov    %eax,%ecx
f0100410:	83 e1 03             	and    $0x3,%ecx
f0100413:	8b 0c 8d 00 6a 10 f0 	mov    -0xfef9600(,%ecx,4),%ecx
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
f0100442:	68 d0 69 10 f0       	push   $0xf01069d0
f0100447:	e8 47 3b 00 00       	call   f0103f93 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010044c:	b0 03                	mov    $0x3,%al
f010044e:	ba 92 00 00 00       	mov    $0x92,%edx
f0100453:	ee                   	out    %al,(%dx)
f0100454:	83 c4 10             	add    $0x10,%esp
f0100457:	eb 0c                	jmp    f0100465 <kbd_proc_data+0xc3>
		shift |= E0ESC;
f0100459:	83 0d 00 60 29 f0 40 	orl    $0x40,0xf0296000
		return 0;
f0100460:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100465:	89 d8                	mov    %ebx,%eax
f0100467:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010046a:	c9                   	leave  
f010046b:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010046c:	8b 0d 00 60 29 f0    	mov    0xf0296000,%ecx
f0100472:	f6 c1 40             	test   $0x40,%cl
f0100475:	75 05                	jne    f010047c <kbd_proc_data+0xda>
f0100477:	83 e0 7f             	and    $0x7f,%eax
f010047a:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f010047c:	0f b6 d2             	movzbl %dl,%edx
f010047f:	8a 82 20 6b 10 f0    	mov    -0xfef94e0(%edx),%al
f0100485:	83 c8 40             	or     $0x40,%eax
f0100488:	0f b6 c0             	movzbl %al,%eax
f010048b:	f7 d0                	not    %eax
f010048d:	21 c8                	and    %ecx,%eax
f010048f:	a3 00 60 29 f0       	mov    %eax,0xf0296000
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
f0100555:	66 8b 0d 28 62 29 f0 	mov    0xf0296228,%cx
f010055c:	bb 50 00 00 00       	mov    $0x50,%ebx
f0100561:	89 c8                	mov    %ecx,%eax
f0100563:	ba 00 00 00 00       	mov    $0x0,%edx
f0100568:	66 f7 f3             	div    %bx
f010056b:	29 d1                	sub    %edx,%ecx
f010056d:	66 89 0d 28 62 29 f0 	mov    %cx,0xf0296228
	if (crt_pos >= CRT_SIZE) {
f0100574:	66 81 3d 28 62 29 f0 	cmpw   $0x7cf,0xf0296228
f010057b:	cf 07 
f010057d:	0f 87 c5 00 00 00    	ja     f0100648 <cons_putc+0x192>
	outb(addr_6845, 14);
f0100583:	8b 0d 30 62 29 f0    	mov    0xf0296230,%ecx
f0100589:	b0 0e                	mov    $0xe,%al
f010058b:	89 ca                	mov    %ecx,%edx
f010058d:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010058e:	8d 59 01             	lea    0x1(%ecx),%ebx
f0100591:	66 a1 28 62 29 f0    	mov    0xf0296228,%ax
f0100597:	66 c1 e8 08          	shr    $0x8,%ax
f010059b:	89 da                	mov    %ebx,%edx
f010059d:	ee                   	out    %al,(%dx)
f010059e:	b0 0f                	mov    $0xf,%al
f01005a0:	89 ca                	mov    %ecx,%edx
f01005a2:	ee                   	out    %al,(%dx)
f01005a3:	a0 28 62 29 f0       	mov    0xf0296228,%al
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
f01005b8:	66 a1 28 62 29 f0    	mov    0xf0296228,%ax
f01005be:	66 85 c0             	test   %ax,%ax
f01005c1:	74 c0                	je     f0100583 <cons_putc+0xcd>
			crt_pos--;
f01005c3:	48                   	dec    %eax
f01005c4:	66 a3 28 62 29 f0    	mov    %ax,0xf0296228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01005ca:	0f b7 c0             	movzwl %ax,%eax
f01005cd:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f01005d3:	83 cf 20             	or     $0x20,%edi
f01005d6:	8b 15 2c 62 29 f0    	mov    0xf029622c,%edx
f01005dc:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01005e0:	eb 92                	jmp    f0100574 <cons_putc+0xbe>
		crt_pos += CRT_COLS;
f01005e2:	66 83 05 28 62 29 f0 	addw   $0x50,0xf0296228
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
f0100626:	66 a1 28 62 29 f0    	mov    0xf0296228,%ax
f010062c:	8d 50 01             	lea    0x1(%eax),%edx
f010062f:	66 89 15 28 62 29 f0 	mov    %dx,0xf0296228
f0100636:	0f b7 c0             	movzwl %ax,%eax
f0100639:	8b 15 2c 62 29 f0    	mov    0xf029622c,%edx
f010063f:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100643:	e9 2c ff ff ff       	jmp    f0100574 <cons_putc+0xbe>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100648:	a1 2c 62 29 f0       	mov    0xf029622c,%eax
f010064d:	83 ec 04             	sub    $0x4,%esp
f0100650:	68 00 0f 00 00       	push   $0xf00
f0100655:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010065b:	52                   	push   %edx
f010065c:	50                   	push   %eax
f010065d:	e8 0b 55 00 00       	call   f0105b6d <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100662:	8b 15 2c 62 29 f0    	mov    0xf029622c,%edx
f0100668:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010066e:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100674:	83 c4 10             	add    $0x10,%esp
f0100677:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010067c:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010067f:	39 d0                	cmp    %edx,%eax
f0100681:	75 f4                	jne    f0100677 <cons_putc+0x1c1>
		crt_pos -= CRT_COLS;
f0100683:	66 83 2d 28 62 29 f0 	subw   $0x50,0xf0296228
f010068a:	50 
f010068b:	e9 f3 fe ff ff       	jmp    f0100583 <cons_putc+0xcd>

f0100690 <serial_intr>:
	if (serial_exists)
f0100690:	80 3d 34 62 29 f0 00 	cmpb   $0x0,0xf0296234
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
f01006ce:	a1 20 62 29 f0       	mov    0xf0296220,%eax
f01006d3:	3b 05 24 62 29 f0    	cmp    0xf0296224,%eax
f01006d9:	74 26                	je     f0100701 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01006db:	8d 50 01             	lea    0x1(%eax),%edx
f01006de:	89 15 20 62 29 f0    	mov    %edx,0xf0296220
f01006e4:	0f b6 80 20 60 29 f0 	movzbl -0xfd69fe0(%eax),%eax
		if (cons.rpos == CONSBUFSIZE)
f01006eb:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01006f1:	74 02                	je     f01006f5 <cons_getc+0x37>
}
f01006f3:	c9                   	leave  
f01006f4:	c3                   	ret    
			cons.rpos = 0;
f01006f5:	c7 05 20 62 29 f0 00 	movl   $0x0,0xf0296220
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
f0100731:	c7 05 30 62 29 f0 b4 	movl   $0x3b4,0xf0296230
f0100738:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010073b:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f0100740:	8b 3d 30 62 29 f0    	mov    0xf0296230,%edi
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
f0100761:	89 35 2c 62 29 f0    	mov    %esi,0xf029622c
	pos |= inb(addr_6845 + 1);
f0100767:	0f b6 c0             	movzbl %al,%eax
f010076a:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f010076c:	66 a3 28 62 29 f0    	mov    %ax,0xf0296228
	kbd_intr();
f0100772:	e8 35 ff ff ff       	call   f01006ac <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f0100777:	83 ec 0c             	sub    $0xc,%esp
f010077a:	66 a1 a8 23 12 f0    	mov    0xf01223a8,%ax
f0100780:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100785:	50                   	push   %eax
f0100786:	e8 c3 36 00 00       	call   f0103e4e <irq_setmask_8259A>
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
f01007d2:	0f 95 05 34 62 29 f0 	setne  0xf0296234
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
f01007f6:	c7 05 30 62 29 f0 d4 	movl   $0x3d4,0xf0296230
f01007fd:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100800:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f0100805:	e9 36 ff ff ff       	jmp    f0100740 <cons_init+0x38>
		cprintf("Serial port does not exist!\n");
f010080a:	83 ec 0c             	sub    $0xc,%esp
f010080d:	68 dc 69 10 f0       	push   $0xf01069dc
f0100812:	e8 7c 37 00 00       	call   f0103f93 <cprintf>
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
f0100856:	ff b3 04 71 10 f0    	pushl  -0xfef8efc(%ebx)
f010085c:	ff b3 00 71 10 f0    	pushl  -0xfef8f00(%ebx)
f0100862:	68 20 6c 10 f0       	push   $0xf0106c20
f0100867:	e8 27 37 00 00       	call   f0103f93 <cprintf>
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
f0100887:	68 29 6c 10 f0       	push   $0xf0106c29
f010088c:	e8 02 37 00 00       	call   f0103f93 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100891:	83 c4 08             	add    $0x8,%esp
f0100894:	68 0c 00 10 00       	push   $0x10000c
f0100899:	68 80 6d 10 f0       	push   $0xf0106d80
f010089e:	e8 f0 36 00 00       	call   f0103f93 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01008a3:	83 c4 0c             	add    $0xc,%esp
f01008a6:	68 0c 00 10 00       	push   $0x10000c
f01008ab:	68 0c 00 10 f0       	push   $0xf010000c
f01008b0:	68 a8 6d 10 f0       	push   $0xf0106da8
f01008b5:	e8 d9 36 00 00       	call   f0103f93 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01008ba:	83 c4 0c             	add    $0xc,%esp
f01008bd:	68 14 68 10 00       	push   $0x106814
f01008c2:	68 14 68 10 f0       	push   $0xf0106814
f01008c7:	68 cc 6d 10 f0       	push   $0xf0106dcc
f01008cc:	e8 c2 36 00 00       	call   f0103f93 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01008d1:	83 c4 0c             	add    $0xc,%esp
f01008d4:	68 2c 5c 29 00       	push   $0x295c2c
f01008d9:	68 2c 5c 29 f0       	push   $0xf0295c2c
f01008de:	68 f0 6d 10 f0       	push   $0xf0106df0
f01008e3:	e8 ab 36 00 00       	call   f0103f93 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01008e8:	83 c4 0c             	add    $0xc,%esp
f01008eb:	68 08 80 2d 00       	push   $0x2d8008
f01008f0:	68 08 80 2d f0       	push   $0xf02d8008
f01008f5:	68 14 6e 10 f0       	push   $0xf0106e14
f01008fa:	e8 94 36 00 00       	call   f0103f93 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008ff:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100902:	b8 07 84 2d f0       	mov    $0xf02d8407,%eax
f0100907:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f010090c:	c1 f8 0a             	sar    $0xa,%eax
f010090f:	50                   	push   %eax
f0100910:	68 38 6e 10 f0       	push   $0xf0106e38
f0100915:	e8 79 36 00 00       	call   f0103f93 <cprintf>
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
f0100939:	e8 c3 53 00 00       	call   f0105d01 <strtoul>
f010093e:	89 c3                	mov    %eax,%ebx
		 	  r = strtoul(argv[2], NULL, 0); // In string.h
f0100940:	83 c4 0c             	add    $0xc,%esp
f0100943:	6a 00                	push   $0x0
f0100945:	6a 00                	push   $0x0
f0100947:	ff 76 08             	pushl  0x8(%esi)
f010094a:	e8 b2 53 00 00       	call   f0105d01 <strtoul>
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
f010096e:	68 42 6c 10 f0       	push   $0xf0106c42
f0100973:	e8 1b 36 00 00       	call   f0103f93 <cprintf>
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
f010098a:	68 56 6c 10 f0       	push   $0xf0106c56
f010098f:	e8 ff 35 00 00       	call   f0103f93 <cprintf>
		return 0;
f0100994:	83 c4 10             	add    $0x10,%esp
f0100997:	eb e2                	jmp    f010097b <mon_showmap+0x5a>
			cprintf("0x%08x -> ----------; perm = ---\n", sz);
f0100999:	83 ec 08             	sub    $0x8,%esp
f010099c:	53                   	push   %ebx
f010099d:	68 64 6e 10 f0       	push   $0xf0106e64
f01009a2:	e8 ec 35 00 00       	call   f0103f93 <cprintf>
f01009a7:	83 c4 10             	add    $0x10,%esp
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f01009aa:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01009b0:	39 f3                	cmp    %esi,%ebx
f01009b2:	77 c7                	ja     f010097b <mon_showmap+0x5a>
		pte_t* pte = pgdir_walk(kern_pgdir, (void*) sz, 0);
f01009b4:	83 ec 04             	sub    $0x4,%esp
f01009b7:	6a 00                	push   $0x0
f01009b9:	53                   	push   %ebx
f01009ba:	ff 35 8c 6e 29 f0    	pushl  0xf0296e8c
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
f01009e2:	68 88 6e 10 f0       	push   $0xf0106e88
f01009e7:	e8 a7 35 00 00       	call   f0103f93 <cprintf>
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
f0100a0d:	e8 ef 52 00 00       	call   f0105d01 <strtoul>
f0100a12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			  l = strtoul(argv[2], NULL, 0), 
f0100a15:	83 c4 0c             	add    $0xc,%esp
f0100a18:	6a 00                	push   $0x0
f0100a1a:	6a 00                	push   $0x0
f0100a1c:	ff 76 08             	pushl  0x8(%esi)
f0100a1f:	e8 dd 52 00 00       	call   f0105d01 <strtoul>
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
f0100a6d:	68 70 6c 10 f0       	push   $0xf0106c70
f0100a72:	e8 1c 35 00 00       	call   f0103f93 <cprintf>
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
f0100a91:	e8 6b 52 00 00       	call   f0105d01 <strtoul>
f0100a96:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
f0100a99:	83 c4 08             	add    $0x8,%esp
f0100a9c:	68 8d 6c 10 f0       	push   $0xf0106c8d
f0100aa1:	ff 76 0c             	pushl  0xc(%esi)
f0100aa4:	e8 ee 4f 00 00       	call   f0105a97 <strcmp>
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
f0100ac7:	68 56 6c 10 f0       	push   $0xf0106c56
f0100acc:	e8 c2 34 00 00       	call   f0103f93 <cprintf>
		return 0;
f0100ad1:	83 c4 10             	add    $0x10,%esp
f0100ad4:	eb a4                	jmp    f0100a7a <mon_chmod+0x89>
		cprintf("Permission exceeds 0xfff; aborting.\n");
f0100ad6:	83 ec 0c             	sub    $0xc,%esp
f0100ad9:	68 ac 6e 10 f0       	push   $0xf0106eac
f0100ade:	e8 b0 34 00 00       	call   f0103f93 <cprintf>
		return 0;
f0100ae3:	83 c4 10             	add    $0x10,%esp
f0100ae6:	eb 92                	jmp    f0100a7a <mon_chmod+0x89>
		cprintf("Warning: PTE_P flag is not provided; added automatically.");
f0100ae8:	83 ec 0c             	sub    $0xc,%esp
f0100aeb:	68 d4 6e 10 f0       	push   $0xf0106ed4
f0100af0:	e8 9e 34 00 00       	call   f0103f93 <cprintf>
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
f0100b1a:	ff 35 8c 6e 29 f0    	pushl  0xf0296e8c
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
f0100b4a:	68 10 6f 10 f0       	push   $0xf0106f10
f0100b4f:	e8 3f 34 00 00       	call   f0103f93 <cprintf>
f0100b54:	83 c4 10             	add    $0x10,%esp
f0100b57:	eb ac                	jmp    f0100b05 <mon_chmod+0x114>
				cprintf("Page va = 0x%08x perm = 0x%03x changed to 0x%03x\n", 
f0100b59:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100b5c:	25 ff 0f 00 00       	and    $0xfff,%eax
f0100b61:	50                   	push   %eax
f0100b62:	53                   	push   %ebx
f0100b63:	68 3c 6f 10 f0       	push   $0xf0106f3c
f0100b68:	e8 26 34 00 00       	call   f0103f93 <cprintf>
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
f0100b89:	68 90 6c 10 f0       	push   $0xf0106c90
f0100b8e:	e8 00 34 00 00       	call   f0103f93 <cprintf>
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
f0100bb0:	e8 4c 51 00 00       	call   f0105d01 <strtoul>
f0100bb5:	89 c6                	mov    %eax,%esi
			  	  r = strtoul(argv[2], NULL, 0);
f0100bb7:	83 c4 0c             	add    $0xc,%esp
f0100bba:	6a 00                	push   $0x0
f0100bbc:	6a 00                	push   $0x0
f0100bbe:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100bc1:	ff 70 08             	pushl  0x8(%eax)
f0100bc4:	e8 38 51 00 00       	call   f0105d01 <strtoul>
f0100bc9:	89 c7                	mov    %eax,%edi
	if (argc <= 3)
f0100bcb:	83 c4 10             	add    $0x10,%esp
f0100bce:	83 fb 03             	cmp    $0x3,%ebx
f0100bd1:	7f 18                	jg     f0100beb <mon_dump+0x79>
		cprintf("Defaulting to virtual address.\n");
f0100bd3:	83 ec 0c             	sub    $0xc,%esp
f0100bd6:	68 70 6f 10 f0       	push   $0xf0106f70
f0100bdb:	e8 b3 33 00 00       	call   f0103f93 <cprintf>
f0100be0:	83 c4 10             	add    $0x10,%esp
	for (ptr = ROUNDDOWN(l, 16); ptr <= r; ptr += 16) {
f0100be3:	83 e6 f0             	and    $0xfffffff0,%esi
f0100be6:	e9 31 01 00 00       	jmp    f0100d1c <mon_dump+0x1aa>
	else if (!strcmp(argv[3], "-p"))
f0100beb:	83 ec 08             	sub    $0x8,%esp
f0100bee:	68 a9 6c 10 f0       	push   $0xf0106ca9
f0100bf3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100bf6:	ff 70 0c             	pushl  0xc(%eax)
f0100bf9:	e8 99 4e 00 00       	call   f0105a97 <strcmp>
f0100bfe:	83 c4 10             	add    $0x10,%esp
f0100c01:	85 c0                	test   %eax,%eax
f0100c03:	75 4f                	jne    f0100c54 <mon_dump+0xe2>
	if (PGNUM(pa) >= npages)
f0100c05:	a1 88 6e 29 f0       	mov    0xf0296e88,%eax
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
f0100c2b:	68 88 69 10 f0       	push   $0xf0106988
f0100c30:	68 9d 00 00 00       	push   $0x9d
f0100c35:	68 ac 6c 10 f0       	push   $0xf0106cac
f0100c3a:	e8 55 f4 ff ff       	call   f0100094 <_panic>
f0100c3f:	57                   	push   %edi
f0100c40:	68 88 69 10 f0       	push   $0xf0106988
f0100c45:	68 9d 00 00 00       	push   $0x9d
f0100c4a:	68 ac 6c 10 f0       	push   $0xf0106cac
f0100c4f:	e8 40 f4 ff ff       	call   f0100094 <_panic>
	else if (strcmp(argv[3], "-v")) {
f0100c54:	83 ec 08             	sub    $0x8,%esp
f0100c57:	68 8d 6c 10 f0       	push   $0xf0106c8d
f0100c5c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c5f:	ff 70 0c             	pushl  0xc(%eax)
f0100c62:	e8 30 4e 00 00       	call   f0105a97 <strcmp>
f0100c67:	83 c4 10             	add    $0x10,%esp
f0100c6a:	85 c0                	test   %eax,%eax
f0100c6c:	0f 84 71 ff ff ff    	je     f0100be3 <mon_dump+0x71>
		cprintf("Unknown flag %s at position 3; aborting.\n", argv[3]);
f0100c72:	83 ec 08             	sub    $0x8,%esp
f0100c75:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c78:	ff 70 0c             	pushl  0xc(%eax)
f0100c7b:	68 90 6f 10 f0       	push   $0xf0106f90
f0100c80:	e8 0e 33 00 00       	call   f0103f93 <cprintf>
		return 0;
f0100c85:	83 c4 10             	add    $0x10,%esp
f0100c88:	e9 09 ff ff ff       	jmp    f0100b96 <mon_dump+0x24>
				cprintf("   ");
f0100c8d:	83 ec 0c             	sub    $0xc,%esp
f0100c90:	68 c8 6c 10 f0       	push   $0xf0106cc8
f0100c95:	e8 f9 32 00 00       	call   f0103f93 <cprintf>
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
f0100cae:	68 c2 6c 10 f0       	push   $0xf0106cc2
f0100cb3:	e8 db 32 00 00       	call   f0103f93 <cprintf>
f0100cb8:	83 c4 10             	add    $0x10,%esp
f0100cbb:	eb e0                	jmp    f0100c9d <mon_dump+0x12b>
		cprintf(" |");
f0100cbd:	83 ec 0c             	sub    $0xc,%esp
f0100cc0:	68 cc 6c 10 f0       	push   $0xf0106ccc
f0100cc5:	e8 c9 32 00 00       	call   f0103f93 <cprintf>
f0100cca:	83 c4 10             	add    $0x10,%esp
f0100ccd:	eb 19                	jmp    f0100ce8 <mon_dump+0x176>
				cprintf("%c", (ch >= ' ' && ch <= '~') ? ch : '.');
f0100ccf:	83 ec 08             	sub    $0x8,%esp
f0100cd2:	0f be c0             	movsbl %al,%eax
f0100cd5:	50                   	push   %eax
f0100cd6:	68 cf 6c 10 f0       	push   $0xf0106ccf
f0100cdb:	e8 b3 32 00 00       	call   f0103f93 <cprintf>
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
f0100cfd:	68 0c 6d 10 f0       	push   $0xf0106d0c
f0100d02:	e8 8c 32 00 00       	call   f0103f93 <cprintf>
f0100d07:	83 c4 10             	add    $0x10,%esp
f0100d0a:	eb d7                	jmp    f0100ce3 <mon_dump+0x171>
		cprintf("|\n");
f0100d0c:	83 ec 0c             	sub    $0xc,%esp
f0100d0f:	68 d2 6c 10 f0       	push   $0xf0106cd2
f0100d14:	e8 7a 32 00 00       	call   f0103f93 <cprintf>
	for (ptr = ROUNDDOWN(l, 16); ptr <= r; ptr += 16) {
f0100d19:	83 c4 10             	add    $0x10,%esp
f0100d1c:	39 f7                	cmp    %esi,%edi
f0100d1e:	72 1e                	jb     f0100d3e <mon_dump+0x1cc>
		cprintf("%08x  ", ptr);
f0100d20:	83 ec 08             	sub    $0x8,%esp
f0100d23:	56                   	push   %esi
f0100d24:	68 bb 6c 10 f0       	push   $0xf0106cbb
f0100d29:	e8 65 32 00 00       	call   f0103f93 <cprintf>
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
f0100d4e:	68 d5 6c 10 f0       	push   $0xf0106cd5
f0100d53:	e8 3b 32 00 00       	call   f0103f93 <cprintf>
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
f0100d69:	68 dd 6c 10 f0       	push   $0xf0106cdd
f0100d6e:	e8 20 32 00 00       	call   f0103f93 <cprintf>
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
f0100d85:	68 cf 6c 10 f0       	push   $0xf0106ccf
f0100d8a:	e8 04 32 00 00       	call   f0103f93 <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f0100d8f:	43                   	inc    %ebx
f0100d90:	83 c4 10             	add    $0x10,%esp
f0100d93:	39 5d dc             	cmp    %ebx,-0x24(%ebp)
f0100d96:	7f e2                	jg     f0100d7a <mon_backtrace+0x1a>
		cprintf("+%d\n", eip - info.eip_fn_addr);
f0100d98:	83 ec 08             	sub    $0x8,%esp
f0100d9b:	2b 75 e0             	sub    -0x20(%ebp),%esi
f0100d9e:	56                   	push   %esi
f0100d9f:	68 00 6d 10 f0       	push   $0xf0106d00
f0100da4:	e8 ea 31 00 00       	call   f0103f93 <cprintf>
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
f0100dc8:	68 bc 6f 10 f0       	push   $0xf0106fbc
f0100dcd:	e8 c1 31 00 00       	call   f0103f93 <cprintf>
		int code = debuginfo_eip((uintptr_t)eip, &info);
f0100dd2:	83 c4 18             	add    $0x18,%esp
f0100dd5:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100dd8:	50                   	push   %eax
f0100dd9:	56                   	push   %esi
f0100dda:	e8 00 43 00 00       	call   f01050df <debuginfo_eip>
		cprintf("         %s:%d: ", info.eip_file, info.eip_line);
f0100ddf:	83 c4 0c             	add    $0xc,%esp
f0100de2:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100de5:	ff 75 d0             	pushl  -0x30(%ebp)
f0100de8:	68 ef 6c 10 f0       	push   $0xf0106cef
f0100ded:	e8 a1 31 00 00       	call   f0103f93 <cprintf>
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
f0100e0d:	68 f4 6f 10 f0       	push   $0xf0106ff4
f0100e12:	e8 7c 31 00 00       	call   f0103f93 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100e17:	c7 04 24 18 70 10 f0 	movl   $0xf0107018,(%esp)
f0100e1e:	e8 70 31 00 00       	call   f0103f93 <cprintf>

	if (tf != NULL)
f0100e23:	83 c4 10             	add    $0x10,%esp
f0100e26:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100e2a:	74 57                	je     f0100e83 <monitor+0x7f>
		print_trapframe(tf);
f0100e2c:	83 ec 0c             	sub    $0xc,%esp
f0100e2f:	ff 75 08             	pushl  0x8(%ebp)
f0100e32:	e8 dc 35 00 00       	call   f0104413 <print_trapframe>
f0100e37:	83 c4 10             	add    $0x10,%esp
f0100e3a:	eb 47                	jmp    f0100e83 <monitor+0x7f>
		while (*buf && strchr(WHITESPACE, *buf))
f0100e3c:	83 ec 08             	sub    $0x8,%esp
f0100e3f:	0f be c0             	movsbl %al,%eax
f0100e42:	50                   	push   %eax
f0100e43:	68 09 6d 10 f0       	push   $0xf0106d09
f0100e48:	e8 9e 4c 00 00       	call   f0105aeb <strchr>
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
f0100e76:	68 0e 6d 10 f0       	push   $0xf0106d0e
f0100e7b:	e8 13 31 00 00       	call   f0103f93 <cprintf>
f0100e80:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100e83:	83 ec 0c             	sub    $0xc,%esp
f0100e86:	68 05 6d 10 f0       	push   $0xf0106d05
f0100e8b:	e8 50 4a 00 00       	call   f01058e0 <readline>
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
f0100eb5:	68 09 6d 10 f0       	push   $0xf0106d09
f0100eba:	e8 2c 4c 00 00       	call   f0105aeb <strchr>
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
f0100ede:	bf 00 71 10 f0       	mov    $0xf0107100,%edi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100ee3:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f0100ee8:	83 ec 08             	sub    $0x8,%esp
f0100eeb:	ff 37                	pushl  (%edi)
f0100eed:	ff 75 a8             	pushl  -0x58(%ebp)
f0100ef0:	e8 a2 4b 00 00       	call   f0105a97 <strcmp>
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
f0100f0b:	68 2b 6d 10 f0       	push   $0xf0106d2b
f0100f10:	e8 7e 30 00 00       	call   f0103f93 <cprintf>
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
f0100f2d:	ff 14 9d 08 71 10 f0 	call   *-0xfef8ef8(,%ebx,4)
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
f0100f4a:	83 3d 38 62 29 f0 00 	cmpl   $0x0,0xf0296238
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
f0100f57:	8b 15 38 62 29 f0    	mov    0xf0296238,%edx
		nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100f5d:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100f64:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f69:	a3 38 62 29 f0       	mov    %eax,0xf0296238
		return (void*)result;
	}
}
f0100f6e:	89 d0                	mov    %edx,%eax
f0100f70:	5d                   	pop    %ebp
f0100f71:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100f72:	ba 07 90 2d f0       	mov    $0xf02d9007,%edx
f0100f77:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100f7d:	89 15 38 62 29 f0    	mov    %edx,0xf0296238
f0100f83:	eb ce                	jmp    f0100f53 <boot_alloc+0xc>
		return (void*)nextfree;
f0100f85:	8b 15 38 62 29 f0    	mov    0xf0296238,%edx
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
f0100f98:	e8 83 2e 00 00       	call   f0103e20 <mc146818_read>
f0100f9d:	89 c3                	mov    %eax,%ebx
f0100f9f:	46                   	inc    %esi
f0100fa0:	89 34 24             	mov    %esi,(%esp)
f0100fa3:	e8 78 2e 00 00       	call   f0103e20 <mc146818_read>
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
f0100fca:	3b 0d 88 6e 29 f0    	cmp    0xf0296e88,%ecx
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
f0100ff3:	68 88 69 10 f0       	push   $0xf0106988
f0100ff8:	68 6f 03 00 00       	push   $0x36f
f0100ffd:	68 5d 7a 10 f0       	push   $0xf0107a5d
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
f0101024:	83 3d 40 62 29 f0 00 	cmpl   $0x0,0xf0296240
f010102b:	74 0a                	je     f0101037 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010102d:	be 00 04 00 00       	mov    $0x400,%esi
f0101032:	e9 c8 02 00 00       	jmp    f01012ff <check_page_free_list+0x2ec>
		panic("'page_free_list' is a null pointer!");
f0101037:	83 ec 04             	sub    $0x4,%esp
f010103a:	68 3c 71 10 f0       	push   $0xf010713c
f010103f:	68 a2 02 00 00       	push   $0x2a2
f0101044:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101049:	e8 46 f0 ff ff       	call   f0100094 <_panic>
f010104e:	50                   	push   %eax
f010104f:	68 88 69 10 f0       	push   $0xf0106988
f0101054:	6a 58                	push   $0x58
f0101056:	68 69 7a 10 f0       	push   $0xf0107a69
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
f0101068:	2b 05 90 6e 29 f0    	sub    0xf0296e90,%eax
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
f0101082:	3b 15 88 6e 29 f0    	cmp    0xf0296e88,%edx
f0101088:	73 c4                	jae    f010104e <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f010108a:	83 ec 04             	sub    $0x4,%esp
f010108d:	68 80 00 00 00       	push   $0x80
f0101092:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0101097:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010109c:	50                   	push   %eax
f010109d:	e8 7e 4a 00 00       	call   f0105b20 <memset>
f01010a2:	83 c4 10             	add    $0x10,%esp
f01010a5:	eb b9                	jmp    f0101060 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f01010a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01010ac:	e8 96 fe ff ff       	call   f0100f47 <boot_alloc>
f01010b1:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010b4:	8b 15 40 62 29 f0    	mov    0xf0296240,%edx
		assert(pp >= pages);
f01010ba:	8b 0d 90 6e 29 f0    	mov    0xf0296e90,%ecx
		assert(pp < pages + npages);
f01010c0:	a1 88 6e 29 f0       	mov    0xf0296e88,%eax
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
f01010db:	68 77 7a 10 f0       	push   $0xf0107a77
f01010e0:	68 83 7a 10 f0       	push   $0xf0107a83
f01010e5:	68 bc 02 00 00       	push   $0x2bc
f01010ea:	68 5d 7a 10 f0       	push   $0xf0107a5d
f01010ef:	e8 a0 ef ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f01010f4:	68 98 7a 10 f0       	push   $0xf0107a98
f01010f9:	68 83 7a 10 f0       	push   $0xf0107a83
f01010fe:	68 bd 02 00 00       	push   $0x2bd
f0101103:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101108:	e8 87 ef ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010110d:	68 60 71 10 f0       	push   $0xf0107160
f0101112:	68 83 7a 10 f0       	push   $0xf0107a83
f0101117:	68 be 02 00 00       	push   $0x2be
f010111c:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101121:	e8 6e ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != 0);
f0101126:	68 ac 7a 10 f0       	push   $0xf0107aac
f010112b:	68 83 7a 10 f0       	push   $0xf0107a83
f0101130:	68 c1 02 00 00       	push   $0x2c1
f0101135:	68 5d 7a 10 f0       	push   $0xf0107a5d
f010113a:	e8 55 ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f010113f:	68 bd 7a 10 f0       	push   $0xf0107abd
f0101144:	68 83 7a 10 f0       	push   $0xf0107a83
f0101149:	68 c2 02 00 00       	push   $0x2c2
f010114e:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101153:	e8 3c ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101158:	68 94 71 10 f0       	push   $0xf0107194
f010115d:	68 83 7a 10 f0       	push   $0xf0107a83
f0101162:	68 c3 02 00 00       	push   $0x2c3
f0101167:	68 5d 7a 10 f0       	push   $0xf0107a5d
f010116c:	e8 23 ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101171:	68 d6 7a 10 f0       	push   $0xf0107ad6
f0101176:	68 83 7a 10 f0       	push   $0xf0107a83
f010117b:	68 c4 02 00 00       	push   $0x2c4
f0101180:	68 5d 7a 10 f0       	push   $0xf0107a5d
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
f01011ae:	68 88 69 10 f0       	push   $0xf0106988
f01011b3:	6a 58                	push   $0x58
f01011b5:	68 69 7a 10 f0       	push   $0xf0107a69
f01011ba:	e8 d5 ee ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01011bf:	68 b8 71 10 f0       	push   $0xf01071b8
f01011c4:	68 83 7a 10 f0       	push   $0xf0107a83
f01011c9:	68 c5 02 00 00       	push   $0x2c5
f01011ce:	68 5d 7a 10 f0       	push   $0xf0107a5d
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
f010123c:	68 f0 7a 10 f0       	push   $0xf0107af0
f0101241:	68 83 7a 10 f0       	push   $0xf0107a83
f0101246:	68 c7 02 00 00       	push   $0x2c7
f010124b:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101250:	e8 3f ee ff ff       	call   f0100094 <_panic>
	assert(nfree_basemem > 0);
f0101255:	85 f6                	test   %esi,%esi
f0101257:	7e 19                	jle    f0101272 <check_page_free_list+0x25f>
	assert(nfree_extmem > 0);
f0101259:	85 db                	test   %ebx,%ebx
f010125b:	7e 2e                	jle    f010128b <check_page_free_list+0x278>
	cprintf("check_page_free_list() succeeded!\n");
f010125d:	83 ec 0c             	sub    $0xc,%esp
f0101260:	68 00 72 10 f0       	push   $0xf0107200
f0101265:	e8 29 2d 00 00       	call   f0103f93 <cprintf>
}
f010126a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010126d:	5b                   	pop    %ebx
f010126e:	5e                   	pop    %esi
f010126f:	5f                   	pop    %edi
f0101270:	5d                   	pop    %ebp
f0101271:	c3                   	ret    
	assert(nfree_basemem > 0);
f0101272:	68 0d 7b 10 f0       	push   $0xf0107b0d
f0101277:	68 83 7a 10 f0       	push   $0xf0107a83
f010127c:	68 cf 02 00 00       	push   $0x2cf
f0101281:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101286:	e8 09 ee ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f010128b:	68 1f 7b 10 f0       	push   $0xf0107b1f
f0101290:	68 83 7a 10 f0       	push   $0xf0107a83
f0101295:	68 d0 02 00 00       	push   $0x2d0
f010129a:	68 5d 7a 10 f0       	push   $0xf0107a5d
f010129f:	e8 f0 ed ff ff       	call   f0100094 <_panic>
	if (!page_free_list)
f01012a4:	a1 40 62 29 f0       	mov    0xf0296240,%eax
f01012a9:	85 c0                	test   %eax,%eax
f01012ab:	0f 84 86 fd ff ff    	je     f0101037 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01012b1:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01012b4:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01012b7:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01012ba:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01012bd:	89 c2                	mov    %eax,%edx
f01012bf:	2b 15 90 6e 29 f0    	sub    0xf0296e90,%edx
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
f01012f5:	a3 40 62 29 f0       	mov    %eax,0xf0296240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01012fa:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01012ff:	8b 1d 40 62 29 f0    	mov    0xf0296240,%ebx
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
f010132c:	b8 4a ce 10 f0       	mov    $0xf010ce4a,%eax
f0101331:	2d d0 5d 10 f0       	sub    $0xf0105dd0,%eax
f0101336:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if (i >= npages_basemem && len < free)
f0101339:	8b 1d 44 62 29 f0    	mov    0xf0296244,%ebx
f010133f:	8b 0d 40 62 29 f0    	mov    0xf0296240,%ecx
	for (i = 1, len = PGSIZE; i < npages; i++, len += PGSIZE) {
f0101345:	bf 00 00 00 00       	mov    $0x0,%edi
f010134a:	b8 01 00 00 00       	mov    $0x1,%eax
		page_free_list = &pages[i];
f010134f:	be 01 00 00 00       	mov    $0x1,%esi
	for (i = 1, len = PGSIZE; i < npages; i++, len += PGSIZE) {
f0101354:	eb 37                	jmp    f010138d <page_init+0x83>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101356:	50                   	push   %eax
f0101357:	68 ac 69 10 f0       	push   $0xf01069ac
f010135c:	68 3e 01 00 00       	push   $0x13e
f0101361:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101366:	e8 29 ed ff ff       	call   f0100094 <_panic>
		pages[i].pp_ref = 0;
f010136b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0101372:	89 d7                	mov    %edx,%edi
f0101374:	03 3d 90 6e 29 f0    	add    0xf0296e90,%edi
f010137a:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
		pages[i].pp_link = page_free_list;
f0101380:	89 0f                	mov    %ecx,(%edi)
		page_free_list = &pages[i];
f0101382:	89 d1                	mov    %edx,%ecx
f0101384:	03 0d 90 6e 29 f0    	add    0xf0296e90,%ecx
f010138a:	89 f7                	mov    %esi,%edi
	for (i = 1, len = PGSIZE; i < npages; i++, len += PGSIZE) {
f010138c:	40                   	inc    %eax
f010138d:	39 05 88 6e 29 f0    	cmp    %eax,0xf0296e88
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
f01013c0:	89 0d 40 62 29 f0    	mov    %ecx,0xf0296240
f01013c6:	eb f0                	jmp    f01013b8 <page_init+0xae>

f01013c8 <page_alloc>:
{
f01013c8:	55                   	push   %ebp
f01013c9:	89 e5                	mov    %esp,%ebp
f01013cb:	53                   	push   %ebx
f01013cc:	83 ec 04             	sub    $0x4,%esp
	struct PageInfo* next = page_free_list;
f01013cf:	8b 1d 40 62 29 f0    	mov    0xf0296240,%ebx
	if (!next)
f01013d5:	85 db                	test   %ebx,%ebx
f01013d7:	74 13                	je     f01013ec <page_alloc+0x24>
	page_free_list = page_free_list->pp_link;
f01013d9:	8b 03                	mov    (%ebx),%eax
f01013db:	a3 40 62 29 f0       	mov    %eax,0xf0296240
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
f01013f5:	2b 05 90 6e 29 f0    	sub    0xf0296e90,%eax
f01013fb:	c1 f8 03             	sar    $0x3,%eax
f01013fe:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101401:	89 c2                	mov    %eax,%edx
f0101403:	c1 ea 0c             	shr    $0xc,%edx
f0101406:	3b 15 88 6e 29 f0    	cmp    0xf0296e88,%edx
f010140c:	73 1a                	jae    f0101428 <page_alloc+0x60>
		memset(content, 0, PGSIZE);
f010140e:	83 ec 04             	sub    $0x4,%esp
f0101411:	68 00 10 00 00       	push   $0x1000
f0101416:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0101418:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010141d:	50                   	push   %eax
f010141e:	e8 fd 46 00 00       	call   f0105b20 <memset>
f0101423:	83 c4 10             	add    $0x10,%esp
f0101426:	eb c4                	jmp    f01013ec <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101428:	50                   	push   %eax
f0101429:	68 88 69 10 f0       	push   $0xf0106988
f010142e:	6a 58                	push   $0x58
f0101430:	68 69 7a 10 f0       	push   $0xf0107a69
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
f010144f:	8b 15 40 62 29 f0    	mov    0xf0296240,%edx
f0101455:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101457:	a3 40 62 29 f0       	mov    %eax,0xf0296240
}
f010145c:	c9                   	leave  
f010145d:	c3                   	ret    
		panic("Ref count is non-zero");
f010145e:	83 ec 04             	sub    $0x4,%esp
f0101461:	68 30 7b 10 f0       	push   $0xf0107b30
f0101466:	68 70 01 00 00       	push   $0x170
f010146b:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101470:	e8 1f ec ff ff       	call   f0100094 <_panic>
		panic("Page is double-freed");
f0101475:	83 ec 04             	sub    $0x4,%esp
f0101478:	68 46 7b 10 f0       	push   $0xf0107b46
f010147d:	68 72 01 00 00       	push   $0x172
f0101482:	68 5d 7a 10 f0       	push   $0xf0107a5d
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
f01014d7:	39 15 88 6e 29 f0    	cmp    %edx,0xf0296e88
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
f01014fb:	68 88 69 10 f0       	push   $0xf0106988
f0101500:	68 9d 01 00 00       	push   $0x19d
f0101505:	68 5d 7a 10 f0       	push   $0xf0107a5d
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
f0101530:	2b 05 90 6e 29 f0    	sub    0xf0296e90,%eax
f0101536:	c1 f8 03             	sar    $0x3,%eax
f0101539:	c1 e0 0c             	shl    $0xc,%eax
f010153c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (PGNUM(pa) >= npages)
f010153f:	c1 e8 0c             	shr    $0xc,%eax
f0101542:	3b 05 88 6e 29 f0    	cmp    0xf0296e88,%eax
f0101548:	73 42                	jae    f010158c <pgdir_walk+0xda>
	return (void *)(pa + KERNBASE);
f010154a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010154d:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
			memset(content, 0, PGSIZE);
f0101553:	83 ec 04             	sub    $0x4,%esp
f0101556:	68 00 10 00 00       	push   $0x1000
f010155b:	6a 00                	push   $0x0
f010155d:	56                   	push   %esi
f010155e:	e8 bd 45 00 00       	call   f0105b20 <memset>
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
f010158f:	68 88 69 10 f0       	push   $0xf0106988
f0101594:	6a 58                	push   $0x58
f0101596:	68 69 7a 10 f0       	push   $0xf0107a69
f010159b:	e8 f4 ea ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01015a0:	56                   	push   %esi
f01015a1:	68 ac 69 10 f0       	push   $0xf01069ac
f01015a6:	68 a6 01 00 00       	push   $0x1a6
f01015ab:	68 5d 7a 10 f0       	push   $0xf0107a5d
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
f0101646:	39 05 88 6e 29 f0    	cmp    %eax,0xf0296e88
f010164c:	76 0e                	jbe    f010165c <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f010164e:	8b 15 90 6e 29 f0    	mov    0xf0296e90,%edx
f0101654:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0101657:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010165a:	c9                   	leave  
f010165b:	c3                   	ret    
		panic("pa2page called with invalid pa");
f010165c:	83 ec 04             	sub    $0x4,%esp
f010165f:	68 24 72 10 f0       	push   $0xf0107224
f0101664:	6a 51                	push   $0x51
f0101666:	68 69 7a 10 f0       	push   $0xf0107a69
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
f0101684:	e8 71 4b 00 00       	call   f01061fa <cpunum>
f0101689:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010168c:	01 c2                	add    %eax,%edx
f010168e:	01 d2                	add    %edx,%edx
f0101690:	01 c2                	add    %eax,%edx
f0101692:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0101695:	83 3c 85 28 70 29 f0 	cmpl   $0x0,-0xfd68fd8(,%eax,4)
f010169c:	00 
f010169d:	74 20                	je     f01016bf <tlb_invalidate+0x41>
f010169f:	e8 56 4b 00 00       	call   f01061fa <cpunum>
f01016a4:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01016a7:	01 c2                	add    %eax,%edx
f01016a9:	01 d2                	add    %edx,%edx
f01016ab:	01 c2                	add    %eax,%edx
f01016ad:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01016b0:	8b 04 85 28 70 29 f0 	mov    -0xfd68fd8(,%eax,4),%eax
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
f010174d:	2b 1d 90 6e 29 f0    	sub    0xf0296e90,%ebx
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
f01017b6:	a1 8c 6e 29 f0       	mov    0xf0296e8c,%eax
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
f01017d5:	68 5b 7b 10 f0       	push   $0xf0107b5b
f01017da:	68 48 02 00 00       	push   $0x248
f01017df:	68 5d 7a 10 f0       	push   $0xf0107a5d
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
f0101833:	89 15 88 6e 29 f0    	mov    %edx,0xf0296e88
	npages_basemem = basemem / (PGSIZE / 1024);
f0101839:	89 f2                	mov    %esi,%edx
f010183b:	c1 ea 02             	shr    $0x2,%edx
f010183e:	89 15 44 62 29 f0    	mov    %edx,0xf0296244
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101844:	89 c2                	mov    %eax,%edx
f0101846:	29 f2                	sub    %esi,%edx
f0101848:	52                   	push   %edx
f0101849:	56                   	push   %esi
f010184a:	50                   	push   %eax
f010184b:	68 44 72 10 f0       	push   $0xf0107244
f0101850:	e8 3e 27 00 00       	call   f0103f93 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101855:	b8 00 10 00 00       	mov    $0x1000,%eax
f010185a:	e8 e8 f6 ff ff       	call   f0100f47 <boot_alloc>
f010185f:	a3 8c 6e 29 f0       	mov    %eax,0xf0296e8c
	memset(kern_pgdir, 0, PGSIZE);
f0101864:	83 c4 0c             	add    $0xc,%esp
f0101867:	68 00 10 00 00       	push   $0x1000
f010186c:	6a 00                	push   $0x0
f010186e:	50                   	push   %eax
f010186f:	e8 ac 42 00 00       	call   f0105b20 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101874:	a1 8c 6e 29 f0       	mov    0xf0296e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0101879:	83 c4 10             	add    $0x10,%esp
f010187c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101881:	0f 86 87 00 00 00    	jbe    f010190e <mem_init+0x125>
	return (physaddr_t)kva - KERNBASE;
f0101887:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010188d:	83 ca 05             	or     $0x5,%edx
f0101890:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo)*npages);
f0101896:	a1 88 6e 29 f0       	mov    0xf0296e88,%eax
f010189b:	c1 e0 03             	shl    $0x3,%eax
f010189e:	e8 a4 f6 ff ff       	call   f0100f47 <boot_alloc>
f01018a3:	a3 90 6e 29 f0       	mov    %eax,0xf0296e90
	memset(pages, 0, sizeof(struct PageInfo)*npages);
f01018a8:	83 ec 04             	sub    $0x4,%esp
f01018ab:	8b 0d 88 6e 29 f0    	mov    0xf0296e88,%ecx
f01018b1:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01018b8:	52                   	push   %edx
f01018b9:	6a 00                	push   $0x0
f01018bb:	50                   	push   %eax
f01018bc:	e8 5f 42 00 00       	call   f0105b20 <memset>
	envs = (struct Env *) boot_alloc(sizeof(struct Env)*NENV);
f01018c1:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01018c6:	e8 7c f6 ff ff       	call   f0100f47 <boot_alloc>
f01018cb:	a3 48 62 29 f0       	mov    %eax,0xf0296248
	memset(envs, 0, sizeof(struct Env)*NENV);
f01018d0:	83 c4 0c             	add    $0xc,%esp
f01018d3:	68 00 f0 01 00       	push   $0x1f000
f01018d8:	6a 00                	push   $0x0
f01018da:	50                   	push   %eax
f01018db:	e8 40 42 00 00       	call   f0105b20 <memset>
	page_init();
f01018e0:	e8 25 fa ff ff       	call   f010130a <page_init>
	check_page_free_list(1);
f01018e5:	b8 01 00 00 00       	mov    $0x1,%eax
f01018ea:	e8 24 f7 ff ff       	call   f0101013 <check_page_free_list>
	if (!pages)
f01018ef:	83 c4 10             	add    $0x10,%esp
f01018f2:	83 3d 90 6e 29 f0 00 	cmpl   $0x0,0xf0296e90
f01018f9:	74 28                	je     f0101923 <mem_init+0x13a>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01018fb:	a1 40 62 29 f0       	mov    0xf0296240,%eax
f0101900:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101905:	eb 36                	jmp    f010193d <mem_init+0x154>
		totalmem = basemem;
f0101907:	89 f0                	mov    %esi,%eax
f0101909:	e9 20 ff ff ff       	jmp    f010182e <mem_init+0x45>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010190e:	50                   	push   %eax
f010190f:	68 ac 69 10 f0       	push   $0xf01069ac
f0101914:	68 94 00 00 00       	push   $0x94
f0101919:	68 5d 7a 10 f0       	push   $0xf0107a5d
f010191e:	e8 71 e7 ff ff       	call   f0100094 <_panic>
		panic("'pages' is a null pointer!");
f0101923:	83 ec 04             	sub    $0x4,%esp
f0101926:	68 6c 7b 10 f0       	push   $0xf0107b6c
f010192b:	68 e3 02 00 00       	push   $0x2e3
f0101930:	68 5d 7a 10 f0       	push   $0xf0107a5d
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
f01019a2:	8b 0d 90 6e 29 f0    	mov    0xf0296e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01019a8:	8b 15 88 6e 29 f0    	mov    0xf0296e88,%edx
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
f01019e8:	a1 40 62 29 f0       	mov    0xf0296240,%eax
f01019ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01019f0:	c7 05 40 62 29 f0 00 	movl   $0x0,0xf0296240
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
f0101aa5:	2b 05 90 6e 29 f0    	sub    0xf0296e90,%eax
f0101aab:	c1 f8 03             	sar    $0x3,%eax
f0101aae:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101ab1:	89 c2                	mov    %eax,%edx
f0101ab3:	c1 ea 0c             	shr    $0xc,%edx
f0101ab6:	3b 15 88 6e 29 f0    	cmp    0xf0296e88,%edx
f0101abc:	0f 83 1d 02 00 00    	jae    f0101cdf <mem_init+0x4f6>
	memset(page2kva(pp0), 1, PGSIZE);
f0101ac2:	83 ec 04             	sub    $0x4,%esp
f0101ac5:	68 00 10 00 00       	push   $0x1000
f0101aca:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101acc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ad1:	50                   	push   %eax
f0101ad2:	e8 49 40 00 00       	call   f0105b20 <memset>
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
f0101b00:	2b 15 90 6e 29 f0    	sub    0xf0296e90,%edx
f0101b06:	c1 fa 03             	sar    $0x3,%edx
f0101b09:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101b0c:	89 d0                	mov    %edx,%eax
f0101b0e:	c1 e8 0c             	shr    $0xc,%eax
f0101b11:	3b 05 88 6e 29 f0    	cmp    0xf0296e88,%eax
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
f0101b3a:	a3 40 62 29 f0       	mov    %eax,0xf0296240
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
f0101b5b:	a1 40 62 29 f0       	mov    0xf0296240,%eax
f0101b60:	83 c4 10             	add    $0x10,%esp
f0101b63:	e9 e9 01 00 00       	jmp    f0101d51 <mem_init+0x568>
	assert((pp0 = page_alloc(0)));
f0101b68:	68 87 7b 10 f0       	push   $0xf0107b87
f0101b6d:	68 83 7a 10 f0       	push   $0xf0107a83
f0101b72:	68 eb 02 00 00       	push   $0x2eb
f0101b77:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101b7c:	e8 13 e5 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101b81:	68 9d 7b 10 f0       	push   $0xf0107b9d
f0101b86:	68 83 7a 10 f0       	push   $0xf0107a83
f0101b8b:	68 ec 02 00 00       	push   $0x2ec
f0101b90:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101b95:	e8 fa e4 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101b9a:	68 b3 7b 10 f0       	push   $0xf0107bb3
f0101b9f:	68 83 7a 10 f0       	push   $0xf0107a83
f0101ba4:	68 ed 02 00 00       	push   $0x2ed
f0101ba9:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101bae:	e8 e1 e4 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f0101bb3:	68 c9 7b 10 f0       	push   $0xf0107bc9
f0101bb8:	68 83 7a 10 f0       	push   $0xf0107a83
f0101bbd:	68 f0 02 00 00       	push   $0x2f0
f0101bc2:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101bc7:	e8 c8 e4 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101bcc:	68 80 72 10 f0       	push   $0xf0107280
f0101bd1:	68 83 7a 10 f0       	push   $0xf0107a83
f0101bd6:	68 f1 02 00 00       	push   $0x2f1
f0101bdb:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101be0:	e8 af e4 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101be5:	68 db 7b 10 f0       	push   $0xf0107bdb
f0101bea:	68 83 7a 10 f0       	push   $0xf0107a83
f0101bef:	68 f2 02 00 00       	push   $0x2f2
f0101bf4:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101bf9:	e8 96 e4 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101bfe:	68 f8 7b 10 f0       	push   $0xf0107bf8
f0101c03:	68 83 7a 10 f0       	push   $0xf0107a83
f0101c08:	68 f3 02 00 00       	push   $0x2f3
f0101c0d:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101c12:	e8 7d e4 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101c17:	68 15 7c 10 f0       	push   $0xf0107c15
f0101c1c:	68 83 7a 10 f0       	push   $0xf0107a83
f0101c21:	68 f4 02 00 00       	push   $0x2f4
f0101c26:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101c2b:	e8 64 e4 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101c30:	68 32 7c 10 f0       	push   $0xf0107c32
f0101c35:	68 83 7a 10 f0       	push   $0xf0107a83
f0101c3a:	68 fb 02 00 00       	push   $0x2fb
f0101c3f:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101c44:	e8 4b e4 ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0101c49:	68 87 7b 10 f0       	push   $0xf0107b87
f0101c4e:	68 83 7a 10 f0       	push   $0xf0107a83
f0101c53:	68 02 03 00 00       	push   $0x302
f0101c58:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101c5d:	e8 32 e4 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c62:	68 9d 7b 10 f0       	push   $0xf0107b9d
f0101c67:	68 83 7a 10 f0       	push   $0xf0107a83
f0101c6c:	68 03 03 00 00       	push   $0x303
f0101c71:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101c76:	e8 19 e4 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c7b:	68 b3 7b 10 f0       	push   $0xf0107bb3
f0101c80:	68 83 7a 10 f0       	push   $0xf0107a83
f0101c85:	68 04 03 00 00       	push   $0x304
f0101c8a:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101c8f:	e8 00 e4 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f0101c94:	68 c9 7b 10 f0       	push   $0xf0107bc9
f0101c99:	68 83 7a 10 f0       	push   $0xf0107a83
f0101c9e:	68 06 03 00 00       	push   $0x306
f0101ca3:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101ca8:	e8 e7 e3 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101cad:	68 80 72 10 f0       	push   $0xf0107280
f0101cb2:	68 83 7a 10 f0       	push   $0xf0107a83
f0101cb7:	68 07 03 00 00       	push   $0x307
f0101cbc:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101cc1:	e8 ce e3 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101cc6:	68 32 7c 10 f0       	push   $0xf0107c32
f0101ccb:	68 83 7a 10 f0       	push   $0xf0107a83
f0101cd0:	68 08 03 00 00       	push   $0x308
f0101cd5:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101cda:	e8 b5 e3 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101cdf:	50                   	push   %eax
f0101ce0:	68 88 69 10 f0       	push   $0xf0106988
f0101ce5:	6a 58                	push   $0x58
f0101ce7:	68 69 7a 10 f0       	push   $0xf0107a69
f0101cec:	e8 a3 e3 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101cf1:	68 41 7c 10 f0       	push   $0xf0107c41
f0101cf6:	68 83 7a 10 f0       	push   $0xf0107a83
f0101cfb:	68 0d 03 00 00       	push   $0x30d
f0101d00:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101d05:	e8 8a e3 ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f0101d0a:	68 5f 7c 10 f0       	push   $0xf0107c5f
f0101d0f:	68 83 7a 10 f0       	push   $0xf0107a83
f0101d14:	68 0e 03 00 00       	push   $0x30e
f0101d19:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0101d1e:	e8 71 e3 ff ff       	call   f0100094 <_panic>
f0101d23:	52                   	push   %edx
f0101d24:	68 88 69 10 f0       	push   $0xf0106988
f0101d29:	6a 58                	push   $0x58
f0101d2b:	68 69 7a 10 f0       	push   $0xf0107a69
f0101d30:	e8 5f e3 ff ff       	call   f0100094 <_panic>
		assert(c[i] == 0);
f0101d35:	68 6f 7c 10 f0       	push   $0xf0107c6f
f0101d3a:	68 83 7a 10 f0       	push   $0xf0107a83
f0101d3f:	68 11 03 00 00       	push   $0x311
f0101d44:	68 5d 7a 10 f0       	push   $0xf0107a5d
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
f0101d60:	68 a0 72 10 f0       	push   $0xf01072a0
f0101d65:	e8 29 22 00 00       	call   f0103f93 <cprintf>
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
f0101dc9:	a1 40 62 29 f0       	mov    0xf0296240,%eax
f0101dce:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f0101dd1:	c7 05 40 62 29 f0 00 	movl   $0x0,0xf0296240
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
f0101df9:	ff 35 8c 6e 29 f0    	pushl  0xf0296e8c
f0101dff:	e8 14 f8 ff ff       	call   f0101618 <page_lookup>
f0101e04:	83 c4 10             	add    $0x10,%esp
f0101e07:	85 c0                	test   %eax,%eax
f0101e09:	0f 85 84 09 00 00    	jne    f0102793 <mem_init+0xfaa>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101e0f:	6a 02                	push   $0x2
f0101e11:	6a 00                	push   $0x0
f0101e13:	53                   	push   %ebx
f0101e14:	ff 35 8c 6e 29 f0    	pushl  0xf0296e8c
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
f0101e38:	ff 35 8c 6e 29 f0    	pushl  0xf0296e8c
f0101e3e:	e8 de f8 ff ff       	call   f0101721 <page_insert>
f0101e43:	83 c4 20             	add    $0x20,%esp
f0101e46:	85 c0                	test   %eax,%eax
f0101e48:	0f 85 77 09 00 00    	jne    f01027c5 <mem_init+0xfdc>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e4e:	a1 8c 6e 29 f0       	mov    0xf0296e8c,%eax
f0101e53:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	return (pp - pages) << PGSHIFT;
f0101e56:	8b 0d 90 6e 29 f0    	mov    0xf0296e90,%ecx
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
f0101ed4:	a1 8c 6e 29 f0       	mov    0xf0296e8c,%eax
f0101ed9:	e8 d6 f0 ff ff       	call   f0100fb4 <check_va2pa>
f0101ede:	89 f2                	mov    %esi,%edx
f0101ee0:	2b 15 90 6e 29 f0    	sub    0xf0296e90,%edx
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
f0101f1c:	ff 35 8c 6e 29 f0    	pushl  0xf0296e8c
f0101f22:	e8 fa f7 ff ff       	call   f0101721 <page_insert>
f0101f27:	83 c4 10             	add    $0x10,%esp
f0101f2a:	85 c0                	test   %eax,%eax
f0101f2c:	0f 85 74 09 00 00    	jne    f01028a6 <mem_init+0x10bd>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f32:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f37:	a1 8c 6e 29 f0       	mov    0xf0296e8c,%eax
f0101f3c:	e8 73 f0 ff ff       	call   f0100fb4 <check_va2pa>
f0101f41:	89 f2                	mov    %esi,%edx
f0101f43:	2b 15 90 6e 29 f0    	sub    0xf0296e90,%edx
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
f0101f77:	8b 15 8c 6e 29 f0    	mov    0xf0296e8c,%edx
f0101f7d:	8b 02                	mov    (%edx),%eax
f0101f7f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101f84:	89 c1                	mov    %eax,%ecx
f0101f86:	c1 e9 0c             	shr    $0xc,%ecx
f0101f89:	3b 0d 88 6e 29 f0    	cmp    0xf0296e88,%ecx
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
f0101fc6:	ff 35 8c 6e 29 f0    	pushl  0xf0296e8c
f0101fcc:	e8 50 f7 ff ff       	call   f0101721 <page_insert>
f0101fd1:	83 c4 10             	add    $0x10,%esp
f0101fd4:	85 c0                	test   %eax,%eax
f0101fd6:	0f 85 5c 09 00 00    	jne    f0102938 <mem_init+0x114f>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101fdc:	a1 8c 6e 29 f0       	mov    0xf0296e8c,%eax
f0101fe1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101fe4:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fe9:	e8 c6 ef ff ff       	call   f0100fb4 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101fee:	89 f2                	mov    %esi,%edx
f0101ff0:	2b 15 90 6e 29 f0    	sub    0xf0296e90,%edx
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
f010202d:	a1 8c 6e 29 f0       	mov    0xf0296e8c,%eax
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
f010205e:	ff 35 8c 6e 29 f0    	pushl  0xf0296e8c
f0102064:	e8 49 f4 ff ff       	call   f01014b2 <pgdir_walk>
f0102069:	83 c4 10             	add    $0x10,%esp
f010206c:	f6 00 02             	testb  $0x2,(%eax)
f010206f:	0f 84 59 09 00 00    	je     f01029ce <mem_init+0x11e5>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102075:	83 ec 04             	sub    $0x4,%esp
f0102078:	6a 00                	push   $0x0
f010207a:	68 00 10 00 00       	push   $0x1000
f010207f:	ff 35 8c 6e 29 f0    	pushl  0xf0296e8c
f0102085:	e8 28 f4 ff ff       	call   f01014b2 <pgdir_walk>
f010208a:	83 c4 10             	add    $0x10,%esp
f010208d:	f6 00 04             	testb  $0x4,(%eax)
f0102090:	0f 85 51 09 00 00    	jne    f01029e7 <mem_init+0x11fe>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102096:	6a 02                	push   $0x2
f0102098:	68 00 00 40 00       	push   $0x400000
f010209d:	57                   	push   %edi
f010209e:	ff 35 8c 6e 29 f0    	pushl  0xf0296e8c
f01020a4:	e8 78 f6 ff ff       	call   f0101721 <page_insert>
f01020a9:	83 c4 10             	add    $0x10,%esp
f01020ac:	85 c0                	test   %eax,%eax
f01020ae:	0f 89 4c 09 00 00    	jns    f0102a00 <mem_init+0x1217>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01020b4:	6a 02                	push   $0x2
f01020b6:	68 00 10 00 00       	push   $0x1000
f01020bb:	53                   	push   %ebx
f01020bc:	ff 35 8c 6e 29 f0    	pushl  0xf0296e8c
f01020c2:	e8 5a f6 ff ff       	call   f0101721 <page_insert>
f01020c7:	83 c4 10             	add    $0x10,%esp
f01020ca:	85 c0                	test   %eax,%eax
f01020cc:	0f 85 47 09 00 00    	jne    f0102a19 <mem_init+0x1230>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020d2:	83 ec 04             	sub    $0x4,%esp
f01020d5:	6a 00                	push   $0x0
f01020d7:	68 00 10 00 00       	push   $0x1000
f01020dc:	ff 35 8c 6e 29 f0    	pushl  0xf0296e8c
f01020e2:	e8 cb f3 ff ff       	call   f01014b2 <pgdir_walk>
f01020e7:	83 c4 10             	add    $0x10,%esp
f01020ea:	f6 00 04             	testb  $0x4,(%eax)
f01020ed:	0f 85 3f 09 00 00    	jne    f0102a32 <mem_init+0x1249>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01020f3:	a1 8c 6e 29 f0       	mov    0xf0296e8c,%eax
f01020f8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01020fb:	ba 00 00 00 00       	mov    $0x0,%edx
f0102100:	e8 af ee ff ff       	call   f0100fb4 <check_va2pa>
f0102105:	89 c1                	mov    %eax,%ecx
f0102107:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010210a:	89 d8                	mov    %ebx,%eax
f010210c:	2b 05 90 6e 29 f0    	sub    0xf0296e90,%eax
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
f010216e:	ff 35 8c 6e 29 f0    	pushl  0xf0296e8c
f0102174:	e8 4e f5 ff ff       	call   f01016c7 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102179:	a1 8c 6e 29 f0       	mov    0xf0296e8c,%eax
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
f01021a6:	2b 15 90 6e 29 f0    	sub    0xf0296e90,%edx
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
f0102207:	ff 35 8c 6e 29 f0    	pushl  0xf0296e8c
f010220d:	e8 b5 f4 ff ff       	call   f01016c7 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102212:	a1 8c 6e 29 f0       	mov    0xf0296e8c,%eax
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
f010228e:	8b 0d 8c 6e 29 f0    	mov    0xf0296e8c,%ecx
f0102294:	8b 11                	mov    (%ecx),%edx
f0102296:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010229c:	89 f8                	mov    %edi,%eax
f010229e:	2b 05 90 6e 29 f0    	sub    0xf0296e90,%eax
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
f01022dc:	ff 35 8c 6e 29 f0    	pushl  0xf0296e8c
f01022e2:	e8 cb f1 ff ff       	call   f01014b2 <pgdir_walk>
f01022e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01022ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01022ed:	a1 8c 6e 29 f0       	mov    0xf0296e8c,%eax
f01022f2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01022f5:	8b 50 04             	mov    0x4(%eax),%edx
f01022f8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f01022fe:	a1 88 6e 29 f0       	mov    0xf0296e88,%eax
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
f0102337:	2b 05 90 6e 29 f0    	sub    0xf0296e90,%eax
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
f0102364:	e8 b7 37 00 00       	call   f0105b20 <memset>
	page_free(pp0);
f0102369:	89 3c 24             	mov    %edi,(%esp)
f010236c:	e8 c9 f0 ff ff       	call   f010143a <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102371:	83 c4 0c             	add    $0xc,%esp
f0102374:	6a 01                	push   $0x1
f0102376:	6a 00                	push   $0x0
f0102378:	ff 35 8c 6e 29 f0    	pushl  0xf0296e8c
f010237e:	e8 2f f1 ff ff       	call   f01014b2 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0102383:	89 fa                	mov    %edi,%edx
f0102385:	2b 15 90 6e 29 f0    	sub    0xf0296e90,%edx
f010238b:	c1 fa 03             	sar    $0x3,%edx
f010238e:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102391:	89 d0                	mov    %edx,%eax
f0102393:	c1 e8 0c             	shr    $0xc,%eax
f0102396:	83 c4 10             	add    $0x10,%esp
f0102399:	3b 05 88 6e 29 f0    	cmp    0xf0296e88,%eax
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
f01023c4:	a1 8c 6e 29 f0       	mov    0xf0296e8c,%eax
f01023c9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01023cf:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f01023d5:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01023d8:	a3 40 62 29 f0       	mov    %eax,0xf0296240

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
f010246e:	8b 3d 8c 6e 29 f0    	mov    0xf0296e8c,%edi
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
f01024e7:	ff 35 8c 6e 29 f0    	pushl  0xf0296e8c
f01024ed:	e8 c0 ef ff ff       	call   f01014b2 <pgdir_walk>
f01024f2:	83 c4 10             	add    $0x10,%esp
f01024f5:	f6 00 04             	testb  $0x4,(%eax)
f01024f8:	0f 85 8d 08 00 00    	jne    f0102d8b <mem_init+0x15a2>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01024fe:	83 ec 04             	sub    $0x4,%esp
f0102501:	6a 00                	push   $0x0
f0102503:	53                   	push   %ebx
f0102504:	ff 35 8c 6e 29 f0    	pushl  0xf0296e8c
f010250a:	e8 a3 ef ff ff       	call   f01014b2 <pgdir_walk>
f010250f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102515:	83 c4 0c             	add    $0xc,%esp
f0102518:	6a 00                	push   $0x0
f010251a:	ff 75 d4             	pushl  -0x2c(%ebp)
f010251d:	ff 35 8c 6e 29 f0    	pushl  0xf0296e8c
f0102523:	e8 8a ef ff ff       	call   f01014b2 <pgdir_walk>
f0102528:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010252e:	83 c4 0c             	add    $0xc,%esp
f0102531:	6a 00                	push   $0x0
f0102533:	56                   	push   %esi
f0102534:	ff 35 8c 6e 29 f0    	pushl  0xf0296e8c
f010253a:	e8 73 ef ff ff       	call   f01014b2 <pgdir_walk>
f010253f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102545:	c7 04 24 62 7d 10 f0 	movl   $0xf0107d62,(%esp)
f010254c:	e8 42 1a 00 00       	call   f0103f93 <cprintf>
	pginfo_sz = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102551:	a1 88 6e 29 f0       	mov    0xf0296e88,%eax
f0102556:	8d 0c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ecx
f010255d:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_region(kern_pgdir, UPAGES, pginfo_sz, PADDR(pages), PTE_U | PTE_P);
f0102563:	a1 90 6e 29 f0       	mov    0xf0296e90,%eax
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
f0102586:	a1 8c 6e 29 f0       	mov    0xf0296e8c,%eax
f010258b:	e8 39 f0 ff ff       	call   f01015c9 <boot_map_region>
	env_sz = ROUNDUP(npages*sizeof(struct Env), PGSIZE);
f0102590:	8b 15 88 6e 29 f0    	mov    0xf0296e88,%edx
f0102596:	89 d0                	mov    %edx,%eax
f0102598:	c1 e0 05             	shl    $0x5,%eax
f010259b:	29 d0                	sub    %edx,%eax
f010259d:	8d 0c 85 ff 0f 00 00 	lea    0xfff(,%eax,4),%ecx
f01025a4:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_region(kern_pgdir, UENVS, env_sz, PADDR(envs), PTE_U | PTE_P);
f01025aa:	a1 48 62 29 f0       	mov    0xf0296248,%eax
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
f01025cd:	a1 8c 6e 29 f0       	mov    0xf0296e8c,%eax
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
f01025fe:	a1 8c 6e 29 f0       	mov    0xf0296e8c,%eax
f0102603:	e8 c1 ef ff ff       	call   f01015c9 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 1 << 28, // 2^32 - 0xf0000000
f0102608:	83 c4 08             	add    $0x8,%esp
f010260b:	6a 03                	push   $0x3
f010260d:	6a 00                	push   $0x0
f010260f:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102614:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102619:	a1 8c 6e 29 f0       	mov    0xf0296e8c,%eax
f010261e:	e8 a6 ef ff ff       	call   f01015c9 <boot_map_region>
f0102623:	c7 45 c8 00 80 29 f0 	movl   $0xf0298000,-0x38(%ebp)
f010262a:	be 00 80 2d f0       	mov    $0xf02d8000,%esi
f010262f:	83 c4 10             	add    $0x10,%esp
f0102632:	bf 00 80 29 f0       	mov    $0xf0298000,%edi
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
f010265b:	a1 8c 6e 29 f0       	mov    0xf0296e8c,%eax
f0102660:	e8 64 ef ff ff       	call   f01015c9 <boot_map_region>
f0102665:	81 c7 00 80 00 00    	add    $0x8000,%edi
f010266b:	81 eb 00 00 01 00    	sub    $0x10000,%ebx
	for (size_t i = 0; i < NCPU; i++) { // `ncpu` is not set yet, we just use NCPU = 8.
f0102671:	83 c4 10             	add    $0x10,%esp
f0102674:	39 f7                	cmp    %esi,%edi
f0102676:	75 c4                	jne    f010263c <mem_init+0xe53>
f0102678:	89 7d c4             	mov    %edi,-0x3c(%ebp)
	pgdir = kern_pgdir;
f010267b:	8b 3d 8c 6e 29 f0    	mov    0xf0296e8c,%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102681:	a1 88 6e 29 f0       	mov    0xf0296e88,%eax
f0102686:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102689:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102690:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102695:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102698:	a1 90 6e 29 f0       	mov    0xf0296e90,%eax
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
f01026e4:	68 79 7c 10 f0       	push   $0xf0107c79
f01026e9:	68 83 7a 10 f0       	push   $0xf0107a83
f01026ee:	68 1e 03 00 00       	push   $0x31e
f01026f3:	68 5d 7a 10 f0       	push   $0xf0107a5d
f01026f8:	e8 97 d9 ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f01026fd:	68 87 7b 10 f0       	push   $0xf0107b87
f0102702:	68 83 7a 10 f0       	push   $0xf0107a83
f0102707:	68 84 03 00 00       	push   $0x384
f010270c:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102711:	e8 7e d9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0102716:	68 9d 7b 10 f0       	push   $0xf0107b9d
f010271b:	68 83 7a 10 f0       	push   $0xf0107a83
f0102720:	68 85 03 00 00       	push   $0x385
f0102725:	68 5d 7a 10 f0       	push   $0xf0107a5d
f010272a:	e8 65 d9 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f010272f:	68 b3 7b 10 f0       	push   $0xf0107bb3
f0102734:	68 83 7a 10 f0       	push   $0xf0107a83
f0102739:	68 86 03 00 00       	push   $0x386
f010273e:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102743:	e8 4c d9 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f0102748:	68 c9 7b 10 f0       	push   $0xf0107bc9
f010274d:	68 83 7a 10 f0       	push   $0xf0107a83
f0102752:	68 89 03 00 00       	push   $0x389
f0102757:	68 5d 7a 10 f0       	push   $0xf0107a5d
f010275c:	e8 33 d9 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102761:	68 80 72 10 f0       	push   $0xf0107280
f0102766:	68 83 7a 10 f0       	push   $0xf0107a83
f010276b:	68 8a 03 00 00       	push   $0x38a
f0102770:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102775:	e8 1a d9 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f010277a:	68 32 7c 10 f0       	push   $0xf0107c32
f010277f:	68 83 7a 10 f0       	push   $0xf0107a83
f0102784:	68 91 03 00 00       	push   $0x391
f0102789:	68 5d 7a 10 f0       	push   $0xf0107a5d
f010278e:	e8 01 d9 ff ff       	call   f0100094 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102793:	68 c0 72 10 f0       	push   $0xf01072c0
f0102798:	68 83 7a 10 f0       	push   $0xf0107a83
f010279d:	68 94 03 00 00       	push   $0x394
f01027a2:	68 5d 7a 10 f0       	push   $0xf0107a5d
f01027a7:	e8 e8 d8 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01027ac:	68 f8 72 10 f0       	push   $0xf01072f8
f01027b1:	68 83 7a 10 f0       	push   $0xf0107a83
f01027b6:	68 97 03 00 00       	push   $0x397
f01027bb:	68 5d 7a 10 f0       	push   $0xf0107a5d
f01027c0:	e8 cf d8 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01027c5:	68 28 73 10 f0       	push   $0xf0107328
f01027ca:	68 83 7a 10 f0       	push   $0xf0107a83
f01027cf:	68 9b 03 00 00       	push   $0x39b
f01027d4:	68 5d 7a 10 f0       	push   $0xf0107a5d
f01027d9:	e8 b6 d8 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01027de:	68 58 73 10 f0       	push   $0xf0107358
f01027e3:	68 83 7a 10 f0       	push   $0xf0107a83
f01027e8:	68 9c 03 00 00       	push   $0x39c
f01027ed:	68 5d 7a 10 f0       	push   $0xf0107a5d
f01027f2:	e8 9d d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01027f7:	68 80 73 10 f0       	push   $0xf0107380
f01027fc:	68 83 7a 10 f0       	push   $0xf0107a83
f0102801:	68 9d 03 00 00       	push   $0x39d
f0102806:	68 5d 7a 10 f0       	push   $0xf0107a5d
f010280b:	e8 84 d8 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102810:	68 84 7c 10 f0       	push   $0xf0107c84
f0102815:	68 83 7a 10 f0       	push   $0xf0107a83
f010281a:	68 9e 03 00 00       	push   $0x39e
f010281f:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102824:	e8 6b d8 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0102829:	68 95 7c 10 f0       	push   $0xf0107c95
f010282e:	68 83 7a 10 f0       	push   $0xf0107a83
f0102833:	68 9f 03 00 00       	push   $0x39f
f0102838:	68 5d 7a 10 f0       	push   $0xf0107a5d
f010283d:	e8 52 d8 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102842:	68 b0 73 10 f0       	push   $0xf01073b0
f0102847:	68 83 7a 10 f0       	push   $0xf0107a83
f010284c:	68 a2 03 00 00       	push   $0x3a2
f0102851:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102856:	e8 39 d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010285b:	68 ec 73 10 f0       	push   $0xf01073ec
f0102860:	68 83 7a 10 f0       	push   $0xf0107a83
f0102865:	68 a3 03 00 00       	push   $0x3a3
f010286a:	68 5d 7a 10 f0       	push   $0xf0107a5d
f010286f:	e8 20 d8 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102874:	68 a6 7c 10 f0       	push   $0xf0107ca6
f0102879:	68 83 7a 10 f0       	push   $0xf0107a83
f010287e:	68 a4 03 00 00       	push   $0x3a4
f0102883:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102888:	e8 07 d8 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f010288d:	68 32 7c 10 f0       	push   $0xf0107c32
f0102892:	68 83 7a 10 f0       	push   $0xf0107a83
f0102897:	68 a7 03 00 00       	push   $0x3a7
f010289c:	68 5d 7a 10 f0       	push   $0xf0107a5d
f01028a1:	e8 ee d7 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01028a6:	68 b0 73 10 f0       	push   $0xf01073b0
f01028ab:	68 83 7a 10 f0       	push   $0xf0107a83
f01028b0:	68 aa 03 00 00       	push   $0x3aa
f01028b5:	68 5d 7a 10 f0       	push   $0xf0107a5d
f01028ba:	e8 d5 d7 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01028bf:	68 ec 73 10 f0       	push   $0xf01073ec
f01028c4:	68 83 7a 10 f0       	push   $0xf0107a83
f01028c9:	68 ab 03 00 00       	push   $0x3ab
f01028ce:	68 5d 7a 10 f0       	push   $0xf0107a5d
f01028d3:	e8 bc d7 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f01028d8:	68 a6 7c 10 f0       	push   $0xf0107ca6
f01028dd:	68 83 7a 10 f0       	push   $0xf0107a83
f01028e2:	68 ac 03 00 00       	push   $0x3ac
f01028e7:	68 5d 7a 10 f0       	push   $0xf0107a5d
f01028ec:	e8 a3 d7 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01028f1:	68 32 7c 10 f0       	push   $0xf0107c32
f01028f6:	68 83 7a 10 f0       	push   $0xf0107a83
f01028fb:	68 b0 03 00 00       	push   $0x3b0
f0102900:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102905:	e8 8a d7 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010290a:	50                   	push   %eax
f010290b:	68 88 69 10 f0       	push   $0xf0106988
f0102910:	68 b3 03 00 00       	push   $0x3b3
f0102915:	68 5d 7a 10 f0       	push   $0xf0107a5d
f010291a:	e8 75 d7 ff ff       	call   f0100094 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010291f:	68 1c 74 10 f0       	push   $0xf010741c
f0102924:	68 83 7a 10 f0       	push   $0xf0107a83
f0102929:	68 b4 03 00 00       	push   $0x3b4
f010292e:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102933:	e8 5c d7 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102938:	68 5c 74 10 f0       	push   $0xf010745c
f010293d:	68 83 7a 10 f0       	push   $0xf0107a83
f0102942:	68 b7 03 00 00       	push   $0x3b7
f0102947:	68 5d 7a 10 f0       	push   $0xf0107a5d
f010294c:	e8 43 d7 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102951:	68 ec 73 10 f0       	push   $0xf01073ec
f0102956:	68 83 7a 10 f0       	push   $0xf0107a83
f010295b:	68 b8 03 00 00       	push   $0x3b8
f0102960:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102965:	e8 2a d7 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f010296a:	68 a6 7c 10 f0       	push   $0xf0107ca6
f010296f:	68 83 7a 10 f0       	push   $0xf0107a83
f0102974:	68 b9 03 00 00       	push   $0x3b9
f0102979:	68 5d 7a 10 f0       	push   $0xf0107a5d
f010297e:	e8 11 d7 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102983:	68 9c 74 10 f0       	push   $0xf010749c
f0102988:	68 83 7a 10 f0       	push   $0xf0107a83
f010298d:	68 ba 03 00 00       	push   $0x3ba
f0102992:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102997:	e8 f8 d6 ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010299c:	68 b7 7c 10 f0       	push   $0xf0107cb7
f01029a1:	68 83 7a 10 f0       	push   $0xf0107a83
f01029a6:	68 bb 03 00 00       	push   $0x3bb
f01029ab:	68 5d 7a 10 f0       	push   $0xf0107a5d
f01029b0:	e8 df d6 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01029b5:	68 b0 73 10 f0       	push   $0xf01073b0
f01029ba:	68 83 7a 10 f0       	push   $0xf0107a83
f01029bf:	68 be 03 00 00       	push   $0x3be
f01029c4:	68 5d 7a 10 f0       	push   $0xf0107a5d
f01029c9:	e8 c6 d6 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01029ce:	68 d0 74 10 f0       	push   $0xf01074d0
f01029d3:	68 83 7a 10 f0       	push   $0xf0107a83
f01029d8:	68 bf 03 00 00       	push   $0x3bf
f01029dd:	68 5d 7a 10 f0       	push   $0xf0107a5d
f01029e2:	e8 ad d6 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01029e7:	68 04 75 10 f0       	push   $0xf0107504
f01029ec:	68 83 7a 10 f0       	push   $0xf0107a83
f01029f1:	68 c0 03 00 00       	push   $0x3c0
f01029f6:	68 5d 7a 10 f0       	push   $0xf0107a5d
f01029fb:	e8 94 d6 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102a00:	68 3c 75 10 f0       	push   $0xf010753c
f0102a05:	68 83 7a 10 f0       	push   $0xf0107a83
f0102a0a:	68 c3 03 00 00       	push   $0x3c3
f0102a0f:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102a14:	e8 7b d6 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102a19:	68 74 75 10 f0       	push   $0xf0107574
f0102a1e:	68 83 7a 10 f0       	push   $0xf0107a83
f0102a23:	68 c6 03 00 00       	push   $0x3c6
f0102a28:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102a2d:	e8 62 d6 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102a32:	68 04 75 10 f0       	push   $0xf0107504
f0102a37:	68 83 7a 10 f0       	push   $0xf0107a83
f0102a3c:	68 c7 03 00 00       	push   $0x3c7
f0102a41:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102a46:	e8 49 d6 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102a4b:	68 b0 75 10 f0       	push   $0xf01075b0
f0102a50:	68 83 7a 10 f0       	push   $0xf0107a83
f0102a55:	68 ca 03 00 00       	push   $0x3ca
f0102a5a:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102a5f:	e8 30 d6 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102a64:	68 dc 75 10 f0       	push   $0xf01075dc
f0102a69:	68 83 7a 10 f0       	push   $0xf0107a83
f0102a6e:	68 cb 03 00 00       	push   $0x3cb
f0102a73:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102a78:	e8 17 d6 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 2);
f0102a7d:	68 cd 7c 10 f0       	push   $0xf0107ccd
f0102a82:	68 83 7a 10 f0       	push   $0xf0107a83
f0102a87:	68 cd 03 00 00       	push   $0x3cd
f0102a8c:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102a91:	e8 fe d5 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102a96:	68 de 7c 10 f0       	push   $0xf0107cde
f0102a9b:	68 83 7a 10 f0       	push   $0xf0107a83
f0102aa0:	68 ce 03 00 00       	push   $0x3ce
f0102aa5:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102aaa:	e8 e5 d5 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102aaf:	68 0c 76 10 f0       	push   $0xf010760c
f0102ab4:	68 83 7a 10 f0       	push   $0xf0107a83
f0102ab9:	68 d1 03 00 00       	push   $0x3d1
f0102abe:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102ac3:	e8 cc d5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102ac8:	68 30 76 10 f0       	push   $0xf0107630
f0102acd:	68 83 7a 10 f0       	push   $0xf0107a83
f0102ad2:	68 d5 03 00 00       	push   $0x3d5
f0102ad7:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102adc:	e8 b3 d5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102ae1:	68 dc 75 10 f0       	push   $0xf01075dc
f0102ae6:	68 83 7a 10 f0       	push   $0xf0107a83
f0102aeb:	68 d6 03 00 00       	push   $0x3d6
f0102af0:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102af5:	e8 9a d5 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102afa:	68 84 7c 10 f0       	push   $0xf0107c84
f0102aff:	68 83 7a 10 f0       	push   $0xf0107a83
f0102b04:	68 d7 03 00 00       	push   $0x3d7
f0102b09:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102b0e:	e8 81 d5 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102b13:	68 de 7c 10 f0       	push   $0xf0107cde
f0102b18:	68 83 7a 10 f0       	push   $0xf0107a83
f0102b1d:	68 d8 03 00 00       	push   $0x3d8
f0102b22:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102b27:	e8 68 d5 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102b2c:	68 54 76 10 f0       	push   $0xf0107654
f0102b31:	68 83 7a 10 f0       	push   $0xf0107a83
f0102b36:	68 db 03 00 00       	push   $0x3db
f0102b3b:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102b40:	e8 4f d5 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f0102b45:	68 ef 7c 10 f0       	push   $0xf0107cef
f0102b4a:	68 83 7a 10 f0       	push   $0xf0107a83
f0102b4f:	68 dc 03 00 00       	push   $0x3dc
f0102b54:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102b59:	e8 36 d5 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f0102b5e:	68 fb 7c 10 f0       	push   $0xf0107cfb
f0102b63:	68 83 7a 10 f0       	push   $0xf0107a83
f0102b68:	68 dd 03 00 00       	push   $0x3dd
f0102b6d:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102b72:	e8 1d d5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102b77:	68 30 76 10 f0       	push   $0xf0107630
f0102b7c:	68 83 7a 10 f0       	push   $0xf0107a83
f0102b81:	68 e1 03 00 00       	push   $0x3e1
f0102b86:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102b8b:	e8 04 d5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102b90:	68 8c 76 10 f0       	push   $0xf010768c
f0102b95:	68 83 7a 10 f0       	push   $0xf0107a83
f0102b9a:	68 e2 03 00 00       	push   $0x3e2
f0102b9f:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102ba4:	e8 eb d4 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102ba9:	68 10 7d 10 f0       	push   $0xf0107d10
f0102bae:	68 83 7a 10 f0       	push   $0xf0107a83
f0102bb3:	68 e3 03 00 00       	push   $0x3e3
f0102bb8:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102bbd:	e8 d2 d4 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102bc2:	68 de 7c 10 f0       	push   $0xf0107cde
f0102bc7:	68 83 7a 10 f0       	push   $0xf0107a83
f0102bcc:	68 e4 03 00 00       	push   $0x3e4
f0102bd1:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102bd6:	e8 b9 d4 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102bdb:	68 b4 76 10 f0       	push   $0xf01076b4
f0102be0:	68 83 7a 10 f0       	push   $0xf0107a83
f0102be5:	68 e7 03 00 00       	push   $0x3e7
f0102bea:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102bef:	e8 a0 d4 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0102bf4:	68 32 7c 10 f0       	push   $0xf0107c32
f0102bf9:	68 83 7a 10 f0       	push   $0xf0107a83
f0102bfe:	68 ea 03 00 00       	push   $0x3ea
f0102c03:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102c08:	e8 87 d4 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c0d:	68 58 73 10 f0       	push   $0xf0107358
f0102c12:	68 83 7a 10 f0       	push   $0xf0107a83
f0102c17:	68 ed 03 00 00       	push   $0x3ed
f0102c1c:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102c21:	e8 6e d4 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0102c26:	68 95 7c 10 f0       	push   $0xf0107c95
f0102c2b:	68 83 7a 10 f0       	push   $0xf0107a83
f0102c30:	68 ef 03 00 00       	push   $0x3ef
f0102c35:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102c3a:	e8 55 d4 ff ff       	call   f0100094 <_panic>
f0102c3f:	52                   	push   %edx
f0102c40:	68 88 69 10 f0       	push   $0xf0106988
f0102c45:	68 f6 03 00 00       	push   $0x3f6
f0102c4a:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102c4f:	e8 40 d4 ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102c54:	68 21 7d 10 f0       	push   $0xf0107d21
f0102c59:	68 83 7a 10 f0       	push   $0xf0107a83
f0102c5e:	68 f7 03 00 00       	push   $0x3f7
f0102c63:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102c68:	e8 27 d4 ff ff       	call   f0100094 <_panic>
f0102c6d:	50                   	push   %eax
f0102c6e:	68 88 69 10 f0       	push   $0xf0106988
f0102c73:	6a 58                	push   $0x58
f0102c75:	68 69 7a 10 f0       	push   $0xf0107a69
f0102c7a:	e8 15 d4 ff ff       	call   f0100094 <_panic>
f0102c7f:	52                   	push   %edx
f0102c80:	68 88 69 10 f0       	push   $0xf0106988
f0102c85:	6a 58                	push   $0x58
f0102c87:	68 69 7a 10 f0       	push   $0xf0107a69
f0102c8c:	e8 03 d4 ff ff       	call   f0100094 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102c91:	68 39 7d 10 f0       	push   $0xf0107d39
f0102c96:	68 83 7a 10 f0       	push   $0xf0107a83
f0102c9b:	68 01 04 00 00       	push   $0x401
f0102ca0:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102ca5:	e8 ea d3 ff ff       	call   f0100094 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102caa:	68 d8 76 10 f0       	push   $0xf01076d8
f0102caf:	68 83 7a 10 f0       	push   $0xf0107a83
f0102cb4:	68 11 04 00 00       	push   $0x411
f0102cb9:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102cbe:	e8 d1 d3 ff ff       	call   f0100094 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102cc3:	68 00 77 10 f0       	push   $0xf0107700
f0102cc8:	68 83 7a 10 f0       	push   $0xf0107a83
f0102ccd:	68 12 04 00 00       	push   $0x412
f0102cd2:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102cd7:	e8 b8 d3 ff ff       	call   f0100094 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102cdc:	68 28 77 10 f0       	push   $0xf0107728
f0102ce1:	68 83 7a 10 f0       	push   $0xf0107a83
f0102ce6:	68 14 04 00 00       	push   $0x414
f0102ceb:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102cf0:	e8 9f d3 ff ff       	call   f0100094 <_panic>
	assert(mm1 + 8096 <= mm2);
f0102cf5:	68 50 7d 10 f0       	push   $0xf0107d50
f0102cfa:	68 83 7a 10 f0       	push   $0xf0107a83
f0102cff:	68 16 04 00 00       	push   $0x416
f0102d04:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102d09:	e8 86 d3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102d0e:	68 50 77 10 f0       	push   $0xf0107750
f0102d13:	68 83 7a 10 f0       	push   $0xf0107a83
f0102d18:	68 18 04 00 00       	push   $0x418
f0102d1d:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102d22:	e8 6d d3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102d27:	68 74 77 10 f0       	push   $0xf0107774
f0102d2c:	68 83 7a 10 f0       	push   $0xf0107a83
f0102d31:	68 19 04 00 00       	push   $0x419
f0102d36:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102d3b:	e8 54 d3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102d40:	68 a4 77 10 f0       	push   $0xf01077a4
f0102d45:	68 83 7a 10 f0       	push   $0xf0107a83
f0102d4a:	68 1a 04 00 00       	push   $0x41a
f0102d4f:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102d54:	e8 3b d3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102d59:	68 c8 77 10 f0       	push   $0xf01077c8
f0102d5e:	68 83 7a 10 f0       	push   $0xf0107a83
f0102d63:	68 1b 04 00 00       	push   $0x41b
f0102d68:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102d6d:	e8 22 d3 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102d72:	68 f4 77 10 f0       	push   $0xf01077f4
f0102d77:	68 83 7a 10 f0       	push   $0xf0107a83
f0102d7c:	68 1d 04 00 00       	push   $0x41d
f0102d81:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102d86:	e8 09 d3 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102d8b:	68 38 78 10 f0       	push   $0xf0107838
f0102d90:	68 83 7a 10 f0       	push   $0xf0107a83
f0102d95:	68 1e 04 00 00       	push   $0x41e
f0102d9a:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102d9f:	e8 f0 d2 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102da4:	50                   	push   %eax
f0102da5:	68 ac 69 10 f0       	push   $0xf01069ac
f0102daa:	68 bd 00 00 00       	push   $0xbd
f0102daf:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102db4:	e8 db d2 ff ff       	call   f0100094 <_panic>
f0102db9:	50                   	push   %eax
f0102dba:	68 ac 69 10 f0       	push   $0xf01069ac
f0102dbf:	68 c7 00 00 00       	push   $0xc7
f0102dc4:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102dc9:	e8 c6 d2 ff ff       	call   f0100094 <_panic>
f0102dce:	50                   	push   %eax
f0102dcf:	68 ac 69 10 f0       	push   $0xf01069ac
f0102dd4:	68 d4 00 00 00       	push   $0xd4
f0102dd9:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102dde:	e8 b1 d2 ff ff       	call   f0100094 <_panic>
f0102de3:	57                   	push   %edi
f0102de4:	68 ac 69 10 f0       	push   $0xf01069ac
f0102de9:	68 14 01 00 00       	push   $0x114
f0102dee:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102df3:	e8 9c d2 ff ff       	call   f0100094 <_panic>
f0102df8:	ff 75 c0             	pushl  -0x40(%ebp)
f0102dfb:	68 ac 69 10 f0       	push   $0xf01069ac
f0102e00:	68 36 03 00 00       	push   $0x336
f0102e05:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102e0a:	e8 85 d2 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e0f:	68 6c 78 10 f0       	push   $0xf010786c
f0102e14:	68 83 7a 10 f0       	push   $0xf0107a83
f0102e19:	68 36 03 00 00       	push   $0x336
f0102e1e:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102e23:	e8 6c d2 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102e28:	a1 48 62 29 f0       	mov    0xf0296248,%eax
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
f0102e75:	68 ac 69 10 f0       	push   $0xf01069ac
f0102e7a:	68 3b 03 00 00       	push   $0x33b
f0102e7f:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102e84:	e8 0b d2 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102e89:	68 a0 78 10 f0       	push   $0xf01078a0
f0102e8e:	68 83 7a 10 f0       	push   $0xf0107a83
f0102e93:	68 3b 03 00 00       	push   $0x33b
f0102e98:	68 5d 7a 10 f0       	push   $0xf0107a5d
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
f0102ec1:	c7 45 d4 00 80 29 f0 	movl   $0xf0298000,-0x2c(%ebp)
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
f0102f93:	68 7b 7d 10 f0       	push   $0xf0107d7b
f0102f98:	68 83 7a 10 f0       	push   $0xf0107a83
f0102f9d:	68 54 03 00 00       	push   $0x354
f0102fa2:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102fa7:	e8 e8 d0 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102fac:	68 d4 78 10 f0       	push   $0xf01078d4
f0102fb1:	68 83 7a 10 f0       	push   $0xf0107a83
f0102fb6:	68 3f 03 00 00       	push   $0x33f
f0102fbb:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102fc0:	e8 cf d0 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fc5:	ff 75 c0             	pushl  -0x40(%ebp)
f0102fc8:	68 ac 69 10 f0       	push   $0xf01069ac
f0102fcd:	68 47 03 00 00       	push   $0x347
f0102fd2:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102fd7:	e8 b8 d0 ff ff       	call   f0100094 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102fdc:	68 fc 78 10 f0       	push   $0xf01078fc
f0102fe1:	68 83 7a 10 f0       	push   $0xf0107a83
f0102fe6:	68 47 03 00 00       	push   $0x347
f0102feb:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102ff0:	e8 9f d0 ff ff       	call   f0100094 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102ff5:	68 44 79 10 f0       	push   $0xf0107944
f0102ffa:	68 83 7a 10 f0       	push   $0xf0107a83
f0102fff:	68 49 03 00 00       	push   $0x349
f0103004:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0103009:	e8 86 d0 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_P);
f010300e:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103011:	f6 c2 01             	test   $0x1,%dl
f0103014:	74 22                	je     f0103038 <mem_init+0x184f>
				assert(pgdir[i] & PTE_W);
f0103016:	f6 c2 02             	test   $0x2,%dl
f0103019:	0f 85 57 ff ff ff    	jne    f0102f76 <mem_init+0x178d>
f010301f:	68 8c 7d 10 f0       	push   $0xf0107d8c
f0103024:	68 83 7a 10 f0       	push   $0xf0107a83
f0103029:	68 59 03 00 00       	push   $0x359
f010302e:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0103033:	e8 5c d0 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_P);
f0103038:	68 7b 7d 10 f0       	push   $0xf0107d7b
f010303d:	68 83 7a 10 f0       	push   $0xf0107a83
f0103042:	68 58 03 00 00       	push   $0x358
f0103047:	68 5d 7a 10 f0       	push   $0xf0107a5d
f010304c:	e8 43 d0 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] == 0);
f0103051:	68 9d 7d 10 f0       	push   $0xf0107d9d
f0103056:	68 83 7a 10 f0       	push   $0xf0107a83
f010305b:	68 5b 03 00 00       	push   $0x35b
f0103060:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0103065:	e8 2a d0 ff ff       	call   f0100094 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f010306a:	83 ec 0c             	sub    $0xc,%esp
f010306d:	68 68 79 10 f0       	push   $0xf0107968
f0103072:	e8 1c 0f 00 00       	call   f0103f93 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0103077:	a1 8c 6e 29 f0       	mov    0xf0296e8c,%eax
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
f01030fa:	2b 05 90 6e 29 f0    	sub    0xf0296e90,%eax
f0103100:	c1 f8 03             	sar    $0x3,%eax
f0103103:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0103106:	89 c2                	mov    %eax,%edx
f0103108:	c1 ea 0c             	shr    $0xc,%edx
f010310b:	83 c4 10             	add    $0x10,%esp
f010310e:	3b 15 88 6e 29 f0    	cmp    0xf0296e88,%edx
f0103114:	0f 83 ce 01 00 00    	jae    f01032e8 <mem_init+0x1aff>
	memset(page2kva(pp1), 1, PGSIZE);
f010311a:	83 ec 04             	sub    $0x4,%esp
f010311d:	68 00 10 00 00       	push   $0x1000
f0103122:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0103124:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103129:	50                   	push   %eax
f010312a:	e8 f1 29 00 00       	call   f0105b20 <memset>
	return (pp - pages) << PGSHIFT;
f010312f:	89 f0                	mov    %esi,%eax
f0103131:	2b 05 90 6e 29 f0    	sub    0xf0296e90,%eax
f0103137:	c1 f8 03             	sar    $0x3,%eax
f010313a:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010313d:	89 c2                	mov    %eax,%edx
f010313f:	c1 ea 0c             	shr    $0xc,%edx
f0103142:	83 c4 10             	add    $0x10,%esp
f0103145:	3b 15 88 6e 29 f0    	cmp    0xf0296e88,%edx
f010314b:	0f 83 a9 01 00 00    	jae    f01032fa <mem_init+0x1b11>
	memset(page2kva(pp2), 2, PGSIZE);
f0103151:	83 ec 04             	sub    $0x4,%esp
f0103154:	68 00 10 00 00       	push   $0x1000
f0103159:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f010315b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103160:	50                   	push   %eax
f0103161:	e8 ba 29 00 00       	call   f0105b20 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103166:	6a 02                	push   $0x2
f0103168:	68 00 10 00 00       	push   $0x1000
f010316d:	57                   	push   %edi
f010316e:	ff 35 8c 6e 29 f0    	pushl  0xf0296e8c
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
f010319f:	ff 35 8c 6e 29 f0    	pushl  0xf0296e8c
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
f01031df:	2b 05 90 6e 29 f0    	sub    0xf0296e90,%eax
f01031e5:	c1 f8 03             	sar    $0x3,%eax
f01031e8:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01031eb:	89 c2                	mov    %eax,%edx
f01031ed:	c1 ea 0c             	shr    $0xc,%edx
f01031f0:	3b 15 88 6e 29 f0    	cmp    0xf0296e88,%edx
f01031f6:	0f 83 8d 01 00 00    	jae    f0103389 <mem_init+0x1ba0>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01031fc:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103203:	03 03 03 
f0103206:	0f 85 8f 01 00 00    	jne    f010339b <mem_init+0x1bb2>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010320c:	83 ec 08             	sub    $0x8,%esp
f010320f:	68 00 10 00 00       	push   $0x1000
f0103214:	ff 35 8c 6e 29 f0    	pushl  0xf0296e8c
f010321a:	e8 a8 e4 ff ff       	call   f01016c7 <page_remove>
	assert(pp2->pp_ref == 0);
f010321f:	83 c4 10             	add    $0x10,%esp
f0103222:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0103227:	0f 85 87 01 00 00    	jne    f01033b4 <mem_init+0x1bcb>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010322d:	8b 0d 8c 6e 29 f0    	mov    0xf0296e8c,%ecx
f0103233:	8b 11                	mov    (%ecx),%edx
f0103235:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f010323b:	89 d8                	mov    %ebx,%eax
f010323d:	2b 05 90 6e 29 f0    	sub    0xf0296e90,%eax
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
f0103271:	c7 04 24 fc 79 10 f0 	movl   $0xf01079fc,(%esp)
f0103278:	e8 16 0d 00 00       	call   f0103f93 <cprintf>
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
f0103289:	68 ac 69 10 f0       	push   $0xf01069ac
f010328e:	68 ed 00 00 00       	push   $0xed
f0103293:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0103298:	e8 f7 cd ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f010329d:	68 87 7b 10 f0       	push   $0xf0107b87
f01032a2:	68 83 7a 10 f0       	push   $0xf0107a83
f01032a7:	68 33 04 00 00       	push   $0x433
f01032ac:	68 5d 7a 10 f0       	push   $0xf0107a5d
f01032b1:	e8 de cd ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01032b6:	68 9d 7b 10 f0       	push   $0xf0107b9d
f01032bb:	68 83 7a 10 f0       	push   $0xf0107a83
f01032c0:	68 34 04 00 00       	push   $0x434
f01032c5:	68 5d 7a 10 f0       	push   $0xf0107a5d
f01032ca:	e8 c5 cd ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01032cf:	68 b3 7b 10 f0       	push   $0xf0107bb3
f01032d4:	68 83 7a 10 f0       	push   $0xf0107a83
f01032d9:	68 35 04 00 00       	push   $0x435
f01032de:	68 5d 7a 10 f0       	push   $0xf0107a5d
f01032e3:	e8 ac cd ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01032e8:	50                   	push   %eax
f01032e9:	68 88 69 10 f0       	push   $0xf0106988
f01032ee:	6a 58                	push   $0x58
f01032f0:	68 69 7a 10 f0       	push   $0xf0107a69
f01032f5:	e8 9a cd ff ff       	call   f0100094 <_panic>
f01032fa:	50                   	push   %eax
f01032fb:	68 88 69 10 f0       	push   $0xf0106988
f0103300:	6a 58                	push   $0x58
f0103302:	68 69 7a 10 f0       	push   $0xf0107a69
f0103307:	e8 88 cd ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f010330c:	68 84 7c 10 f0       	push   $0xf0107c84
f0103311:	68 83 7a 10 f0       	push   $0xf0107a83
f0103316:	68 3a 04 00 00       	push   $0x43a
f010331b:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0103320:	e8 6f cd ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103325:	68 88 79 10 f0       	push   $0xf0107988
f010332a:	68 83 7a 10 f0       	push   $0xf0107a83
f010332f:	68 3b 04 00 00       	push   $0x43b
f0103334:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0103339:	e8 56 cd ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010333e:	68 ac 79 10 f0       	push   $0xf01079ac
f0103343:	68 83 7a 10 f0       	push   $0xf0107a83
f0103348:	68 3d 04 00 00       	push   $0x43d
f010334d:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0103352:	e8 3d cd ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0103357:	68 a6 7c 10 f0       	push   $0xf0107ca6
f010335c:	68 83 7a 10 f0       	push   $0xf0107a83
f0103361:	68 3e 04 00 00       	push   $0x43e
f0103366:	68 5d 7a 10 f0       	push   $0xf0107a5d
f010336b:	e8 24 cd ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0103370:	68 10 7d 10 f0       	push   $0xf0107d10
f0103375:	68 83 7a 10 f0       	push   $0xf0107a83
f010337a:	68 3f 04 00 00       	push   $0x43f
f010337f:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0103384:	e8 0b cd ff ff       	call   f0100094 <_panic>
f0103389:	50                   	push   %eax
f010338a:	68 88 69 10 f0       	push   $0xf0106988
f010338f:	6a 58                	push   $0x58
f0103391:	68 69 7a 10 f0       	push   $0xf0107a69
f0103396:	e8 f9 cc ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010339b:	68 d0 79 10 f0       	push   $0xf01079d0
f01033a0:	68 83 7a 10 f0       	push   $0xf0107a83
f01033a5:	68 41 04 00 00       	push   $0x441
f01033aa:	68 5d 7a 10 f0       	push   $0xf0107a5d
f01033af:	e8 e0 cc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01033b4:	68 de 7c 10 f0       	push   $0xf0107cde
f01033b9:	68 83 7a 10 f0       	push   $0xf0107a83
f01033be:	68 43 04 00 00       	push   $0x443
f01033c3:	68 5d 7a 10 f0       	push   $0xf0107a5d
f01033c8:	e8 c7 cc ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01033cd:	68 58 73 10 f0       	push   $0xf0107358
f01033d2:	68 83 7a 10 f0       	push   $0xf0107a83
f01033d7:	68 46 04 00 00       	push   $0x446
f01033dc:	68 5d 7a 10 f0       	push   $0xf0107a5d
f01033e1:	e8 ae cc ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f01033e6:	68 95 7c 10 f0       	push   $0xf0107c95
f01033eb:	68 83 7a 10 f0       	push   $0xf0107a83
f01033f0:	68 48 04 00 00       	push   $0x448
f01033f5:	68 5d 7a 10 f0       	push   $0xf0107a5d
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
f010342a:	39 f3                	cmp    %esi,%ebx
f010342c:	0f 83 83 00 00 00    	jae    f01034b5 <user_mem_check+0xb6>
		if ((uintptr_t)l >= ULIM) {// Higher than ULIM
f0103432:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103435:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010343b:	77 2d                	ja     f010346a <user_mem_check+0x6b>
		pte_t* pte = pgdir_walk(env->env_pgdir, l, 0);
f010343d:	83 ec 04             	sub    $0x4,%esp
f0103440:	6a 00                	push   $0x0
f0103442:	53                   	push   %ebx
f0103443:	ff 77 60             	pushl  0x60(%edi)
f0103446:	e8 67 e0 ff ff       	call   f01014b2 <pgdir_walk>
		if (!pte) {
f010344b:	83 c4 10             	add    $0x10,%esp
f010344e:	85 c0                	test   %eax,%eax
f0103450:	74 2f                	je     f0103481 <user_mem_check+0x82>
		uint32_t given_perm = *pte & 0xFFF;
f0103452:	8b 00                	mov    (%eax),%eax
f0103454:	25 ff 0f 00 00       	and    $0xfff,%eax
		if ((given_perm | perm) > given_perm) {
f0103459:	89 c2                	mov    %eax,%edx
f010345b:	0b 55 14             	or     0x14(%ebp),%edx
f010345e:	39 c2                	cmp    %eax,%edx
f0103460:	77 39                	ja     f010349b <user_mem_check+0x9c>
	for (; l < r; l += PGSIZE) {
f0103462:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103468:	eb c0                	jmp    f010342a <user_mem_check+0x2b>
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f010346a:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f010346d:	72 03                	jb     f0103472 <user_mem_check+0x73>
		if ((uintptr_t)l >= ULIM) {// Higher than ULIM
f010346f:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f0103472:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103475:	a3 3c 62 29 f0       	mov    %eax,0xf029623c
			return -E_FAULT;
f010347a:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010347f:	eb 39                	jmp    f01034ba <user_mem_check+0xbb>
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f0103481:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0103484:	72 06                	jb     f010348c <user_mem_check+0x8d>
		if ((uintptr_t)l >= ULIM) {// Higher than ULIM
f0103486:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103489:	89 45 e0             	mov    %eax,-0x20(%ebp)
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f010348c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010348f:	a3 3c 62 29 f0       	mov    %eax,0xf029623c
			return -E_FAULT;
f0103494:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103499:	eb 1f                	jmp    f01034ba <user_mem_check+0xbb>
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f010349b:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f010349e:	72 06                	jb     f01034a6 <user_mem_check+0xa7>
		if ((uintptr_t)l >= ULIM) {// Higher than ULIM
f01034a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01034a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f01034a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034a9:	a3 3c 62 29 f0       	mov    %eax,0xf029623c
			return -E_FAULT;
f01034ae:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034b3:	eb 05                	jmp    f01034ba <user_mem_check+0xbb>
	return 0;
f01034b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01034ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034bd:	5b                   	pop    %ebx
f01034be:	5e                   	pop    %esi
f01034bf:	5f                   	pop    %edi
f01034c0:	5d                   	pop    %ebp
f01034c1:	c3                   	ret    

f01034c2 <user_mem_assert>:
{
f01034c2:	55                   	push   %ebp
f01034c3:	89 e5                	mov    %esp,%ebp
f01034c5:	53                   	push   %ebx
f01034c6:	83 ec 04             	sub    $0x4,%esp
f01034c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01034cc:	8b 45 14             	mov    0x14(%ebp),%eax
f01034cf:	83 c8 04             	or     $0x4,%eax
f01034d2:	50                   	push   %eax
f01034d3:	ff 75 10             	pushl  0x10(%ebp)
f01034d6:	ff 75 0c             	pushl  0xc(%ebp)
f01034d9:	53                   	push   %ebx
f01034da:	e8 20 ff ff ff       	call   f01033ff <user_mem_check>
f01034df:	83 c4 10             	add    $0x10,%esp
f01034e2:	85 c0                	test   %eax,%eax
f01034e4:	78 05                	js     f01034eb <user_mem_assert+0x29>
}
f01034e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01034e9:	c9                   	leave  
f01034ea:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f01034eb:	83 ec 04             	sub    $0x4,%esp
f01034ee:	ff 35 3c 62 29 f0    	pushl  0xf029623c
f01034f4:	ff 73 48             	pushl  0x48(%ebx)
f01034f7:	68 28 7a 10 f0       	push   $0xf0107a28
f01034fc:	e8 92 0a 00 00       	call   f0103f93 <cprintf>
		env_destroy(env);	// may not return
f0103501:	89 1c 24             	mov    %ebx,(%esp)
f0103504:	e8 4e 07 00 00       	call   f0103c57 <env_destroy>
f0103509:	83 c4 10             	add    $0x10,%esp
}
f010350c:	eb d8                	jmp    f01034e6 <user_mem_assert+0x24>

f010350e <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010350e:	55                   	push   %ebp
f010350f:	89 e5                	mov    %esp,%ebp
f0103511:	56                   	push   %esi
f0103512:	53                   	push   %ebx
f0103513:	8b 45 08             	mov    0x8(%ebp),%eax
f0103516:	8b 75 10             	mov    0x10(%ebp),%esi
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103519:	85 c0                	test   %eax,%eax
f010351b:	74 37                	je     f0103554 <envid2env+0x46>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010351d:	89 c1                	mov    %eax,%ecx
f010351f:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f0103525:	89 ca                	mov    %ecx,%edx
f0103527:	c1 e2 05             	shl    $0x5,%edx
f010352a:	29 ca                	sub    %ecx,%edx
f010352c:	8b 0d 48 62 29 f0    	mov    0xf0296248,%ecx
f0103532:	8d 1c 91             	lea    (%ecx,%edx,4),%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103535:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103539:	74 3d                	je     f0103578 <envid2env+0x6a>
f010353b:	39 43 48             	cmp    %eax,0x48(%ebx)
f010353e:	75 38                	jne    f0103578 <envid2env+0x6a>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103540:	89 f0                	mov    %esi,%eax
f0103542:	84 c0                	test   %al,%al
f0103544:	75 42                	jne    f0103588 <envid2env+0x7a>
		*env_store = 0;
		return -E_BAD_ENV;
	}

	*env_store = e;
f0103546:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103549:	89 18                	mov    %ebx,(%eax)
	return 0;
f010354b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103550:	5b                   	pop    %ebx
f0103551:	5e                   	pop    %esi
f0103552:	5d                   	pop    %ebp
f0103553:	c3                   	ret    
		*env_store = curenv;
f0103554:	e8 a1 2c 00 00       	call   f01061fa <cpunum>
f0103559:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010355c:	01 c2                	add    %eax,%edx
f010355e:	01 d2                	add    %edx,%edx
f0103560:	01 c2                	add    %eax,%edx
f0103562:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103565:	8b 04 85 28 70 29 f0 	mov    -0xfd68fd8(,%eax,4),%eax
f010356c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010356f:	89 06                	mov    %eax,(%esi)
		return 0;
f0103571:	b8 00 00 00 00       	mov    $0x0,%eax
f0103576:	eb d8                	jmp    f0103550 <envid2env+0x42>
		*env_store = 0;
f0103578:	8b 45 0c             	mov    0xc(%ebp),%eax
f010357b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103581:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103586:	eb c8                	jmp    f0103550 <envid2env+0x42>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103588:	e8 6d 2c 00 00       	call   f01061fa <cpunum>
f010358d:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103590:	01 c2                	add    %eax,%edx
f0103592:	01 d2                	add    %edx,%edx
f0103594:	01 c2                	add    %eax,%edx
f0103596:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103599:	39 1c 85 28 70 29 f0 	cmp    %ebx,-0xfd68fd8(,%eax,4)
f01035a0:	74 a4                	je     f0103546 <envid2env+0x38>
f01035a2:	8b 73 4c             	mov    0x4c(%ebx),%esi
f01035a5:	e8 50 2c 00 00       	call   f01061fa <cpunum>
f01035aa:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01035ad:	01 c2                	add    %eax,%edx
f01035af:	01 d2                	add    %edx,%edx
f01035b1:	01 c2                	add    %eax,%edx
f01035b3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01035b6:	8b 04 85 28 70 29 f0 	mov    -0xfd68fd8(,%eax,4),%eax
f01035bd:	3b 70 48             	cmp    0x48(%eax),%esi
f01035c0:	74 84                	je     f0103546 <envid2env+0x38>
		*env_store = 0;
f01035c2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035c5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01035cb:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01035d0:	e9 7b ff ff ff       	jmp    f0103550 <envid2env+0x42>

f01035d5 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01035d5:	55                   	push   %ebp
f01035d6:	89 e5                	mov    %esp,%ebp
	asm volatile("lgdt (%0)" : : "r" (p));
f01035d8:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
f01035dd:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01035e0:	b8 23 00 00 00       	mov    $0x23,%eax
f01035e5:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01035e7:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01035e9:	b8 10 00 00 00       	mov    $0x10,%eax
f01035ee:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01035f0:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01035f2:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01035f4:	ea fb 35 10 f0 08 00 	ljmp   $0x8,$0xf01035fb
	asm volatile("lldt %0" : : "r" (sel));
f01035fb:	b8 00 00 00 00       	mov    $0x0,%eax
f0103600:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103603:	5d                   	pop    %ebp
f0103604:	c3                   	ret    

f0103605 <env_init>:
{
f0103605:	55                   	push   %ebp
f0103606:	89 e5                	mov    %esp,%ebp
f0103608:	56                   	push   %esi
f0103609:	53                   	push   %ebx
		envs[i].env_link = env_free_list;
f010360a:	8b 35 48 62 29 f0    	mov    0xf0296248,%esi
f0103610:	8b 15 4c 62 29 f0    	mov    0xf029624c,%edx
f0103616:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f010361c:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f010361f:	89 c1                	mov    %eax,%ecx
f0103621:	89 50 44             	mov    %edx,0x44(%eax)
f0103624:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[i];
f0103627:	89 ca                	mov    %ecx,%edx
	for (int i = NENV - 1; i >= 0; i--) { // Be sure not to use size_t
f0103629:	39 d8                	cmp    %ebx,%eax
f010362b:	75 f2                	jne    f010361f <env_init+0x1a>
f010362d:	89 35 4c 62 29 f0    	mov    %esi,0xf029624c
	env_init_percpu();
f0103633:	e8 9d ff ff ff       	call   f01035d5 <env_init_percpu>
}
f0103638:	5b                   	pop    %ebx
f0103639:	5e                   	pop    %esi
f010363a:	5d                   	pop    %ebp
f010363b:	c3                   	ret    

f010363c <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010363c:	55                   	push   %ebp
f010363d:	89 e5                	mov    %esp,%ebp
f010363f:	56                   	push   %esi
f0103640:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;
	// cprintf("newenv_store = %p\n", newenv_store);
	if (!(e = env_free_list))
f0103641:	8b 1d 4c 62 29 f0    	mov    0xf029624c,%ebx
f0103647:	85 db                	test   %ebx,%ebx
f0103649:	0f 84 f3 01 00 00    	je     f0103842 <env_alloc+0x206>
	if (!(p = page_alloc(ALLOC_ZERO)))
f010364f:	83 ec 0c             	sub    $0xc,%esp
f0103652:	6a 01                	push   $0x1
f0103654:	e8 6f dd ff ff       	call   f01013c8 <page_alloc>
f0103659:	89 c6                	mov    %eax,%esi
f010365b:	83 c4 10             	add    $0x10,%esp
f010365e:	85 c0                	test   %eax,%eax
f0103660:	0f 84 e3 01 00 00    	je     f0103849 <env_alloc+0x20d>
	return (pp - pages) << PGSHIFT;
f0103666:	2b 05 90 6e 29 f0    	sub    0xf0296e90,%eax
f010366c:	c1 f8 03             	sar    $0x3,%eax
f010366f:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0103672:	89 c2                	mov    %eax,%edx
f0103674:	c1 ea 0c             	shr    $0xc,%edx
f0103677:	3b 15 88 6e 29 f0    	cmp    0xf0296e88,%edx
f010367d:	0f 83 75 01 00 00    	jae    f01037f8 <env_alloc+0x1bc>
	memset(page2kva(p), 0, PGSIZE);
f0103683:	83 ec 04             	sub    $0x4,%esp
f0103686:	68 00 10 00 00       	push   $0x1000
f010368b:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f010368d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103692:	50                   	push   %eax
f0103693:	e8 88 24 00 00       	call   f0105b20 <memset>
	p->pp_ref++;
f0103698:	66 ff 46 04          	incw   0x4(%esi)
	return (pp - pages) << PGSHIFT;
f010369c:	2b 35 90 6e 29 f0    	sub    0xf0296e90,%esi
f01036a2:	c1 fe 03             	sar    $0x3,%esi
f01036a5:	c1 e6 0c             	shl    $0xc,%esi
	if (PGNUM(pa) >= npages)
f01036a8:	89 f0                	mov    %esi,%eax
f01036aa:	c1 e8 0c             	shr    $0xc,%eax
f01036ad:	83 c4 10             	add    $0x10,%esp
f01036b0:	3b 05 88 6e 29 f0    	cmp    0xf0296e88,%eax
f01036b6:	0f 83 4e 01 00 00    	jae    f010380a <env_alloc+0x1ce>
	return (void *)(pa + KERNBASE);
f01036bc:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f01036c2:	89 73 60             	mov    %esi,0x60(%ebx)
	e->env_pgdir = page2kva(p);
f01036c5:	b8 ec 0e 00 00       	mov    $0xeec,%eax
		e->env_pgdir[pgt] = kern_pgdir[pgt];
f01036ca:	8b 15 8c 6e 29 f0    	mov    0xf0296e8c,%edx
f01036d0:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f01036d3:	8b 53 60             	mov    0x60(%ebx),%edx
f01036d6:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f01036d9:	83 c0 04             	add    $0x4,%eax
	for (size_t pgt = PDX(UTOP); pgt < PGSIZE / sizeof(pde_t); pgt++) {
f01036dc:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01036e1:	75 e7                	jne    f01036ca <env_alloc+0x8e>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01036e3:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01036e6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036eb:	0f 86 2b 01 00 00    	jbe    f010381c <env_alloc+0x1e0>
	return (physaddr_t)kva - KERNBASE;
f01036f1:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01036f7:	83 ca 05             	or     $0x5,%edx
f01036fa:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103700:	8b 43 48             	mov    0x48(%ebx),%eax
f0103703:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103708:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010370d:	89 c2                	mov    %eax,%edx
f010370f:	0f 8e 1c 01 00 00    	jle    f0103831 <env_alloc+0x1f5>
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f0103715:	89 d8                	mov    %ebx,%eax
f0103717:	2b 05 48 62 29 f0    	sub    0xf0296248,%eax
f010371d:	c1 f8 02             	sar    $0x2,%eax
f0103720:	89 c1                	mov    %eax,%ecx
f0103722:	c1 e0 05             	shl    $0x5,%eax
f0103725:	01 c8                	add    %ecx,%eax
f0103727:	c1 e0 05             	shl    $0x5,%eax
f010372a:	01 c8                	add    %ecx,%eax
f010372c:	89 c6                	mov    %eax,%esi
f010372e:	c1 e6 0f             	shl    $0xf,%esi
f0103731:	01 f0                	add    %esi,%eax
f0103733:	c1 e0 05             	shl    $0x5,%eax
f0103736:	01 c8                	add    %ecx,%eax
f0103738:	f7 d8                	neg    %eax
f010373a:	09 d0                	or     %edx,%eax
f010373c:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f010373f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103742:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103745:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010374c:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103753:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010375a:	83 ec 04             	sub    $0x4,%esp
f010375d:	6a 44                	push   $0x44
f010375f:	6a 00                	push   $0x0
f0103761:	53                   	push   %ebx
f0103762:	e8 b9 23 00 00       	call   f0105b20 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103767:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010376d:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103773:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103779:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103780:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103786:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f010378d:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103791:	8b 43 44             	mov    0x44(%ebx),%eax
f0103794:	a3 4c 62 29 f0       	mov    %eax,0xf029624c
	*newenv_store = e;
f0103799:	8b 45 08             	mov    0x8(%ebp),%eax
f010379c:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010379e:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01037a1:	e8 54 2a 00 00       	call   f01061fa <cpunum>
f01037a6:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01037a9:	01 c2                	add    %eax,%edx
f01037ab:	01 d2                	add    %edx,%edx
f01037ad:	01 c2                	add    %eax,%edx
f01037af:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01037b2:	83 c4 10             	add    $0x10,%esp
f01037b5:	83 3c 85 28 70 29 f0 	cmpl   $0x0,-0xfd68fd8(,%eax,4)
f01037bc:	00 
f01037bd:	74 7c                	je     f010383b <env_alloc+0x1ff>
f01037bf:	e8 36 2a 00 00       	call   f01061fa <cpunum>
f01037c4:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01037c7:	01 c2                	add    %eax,%edx
f01037c9:	01 d2                	add    %edx,%edx
f01037cb:	01 c2                	add    %eax,%edx
f01037cd:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01037d0:	8b 04 85 28 70 29 f0 	mov    -0xfd68fd8(,%eax,4),%eax
f01037d7:	8b 40 48             	mov    0x48(%eax),%eax
f01037da:	83 ec 04             	sub    $0x4,%esp
f01037dd:	53                   	push   %ebx
f01037de:	50                   	push   %eax
f01037df:	68 fe 7d 10 f0       	push   $0xf0107dfe
f01037e4:	e8 aa 07 00 00       	call   f0103f93 <cprintf>
	return 0;
f01037e9:	83 c4 10             	add    $0x10,%esp
f01037ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01037f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01037f4:	5b                   	pop    %ebx
f01037f5:	5e                   	pop    %esi
f01037f6:	5d                   	pop    %ebp
f01037f7:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01037f8:	50                   	push   %eax
f01037f9:	68 88 69 10 f0       	push   $0xf0106988
f01037fe:	6a 58                	push   $0x58
f0103800:	68 69 7a 10 f0       	push   $0xf0107a69
f0103805:	e8 8a c8 ff ff       	call   f0100094 <_panic>
f010380a:	56                   	push   %esi
f010380b:	68 88 69 10 f0       	push   $0xf0106988
f0103810:	6a 58                	push   $0x58
f0103812:	68 69 7a 10 f0       	push   $0xf0107a69
f0103817:	e8 78 c8 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010381c:	50                   	push   %eax
f010381d:	68 ac 69 10 f0       	push   $0xf01069ac
f0103822:	68 ca 00 00 00       	push   $0xca
f0103827:	68 f3 7d 10 f0       	push   $0xf0107df3
f010382c:	e8 63 c8 ff ff       	call   f0100094 <_panic>
		generation = 1 << ENVGENSHIFT;
f0103831:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103836:	e9 da fe ff ff       	jmp    f0103715 <env_alloc+0xd9>
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010383b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103840:	eb 98                	jmp    f01037da <env_alloc+0x19e>
		return -E_NO_FREE_ENV;
f0103842:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103847:	eb a8                	jmp    f01037f1 <env_alloc+0x1b5>
		return -E_NO_MEM;
f0103849:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010384e:	eb a1                	jmp    f01037f1 <env_alloc+0x1b5>

f0103850 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103850:	55                   	push   %ebp
f0103851:	89 e5                	mov    %esp,%ebp
f0103853:	57                   	push   %edi
f0103854:	56                   	push   %esi
f0103855:	53                   	push   %ebx
f0103856:	83 ec 34             	sub    $0x34,%esp
	struct Env* newenv;
	// cprintf("&newenv = %p\n", &newenv);
	// cprintf("env_free_list = %p\n", env_free_list);
	int r = env_alloc(&newenv, 0);
f0103859:	6a 00                	push   $0x0
f010385b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010385e:	50                   	push   %eax
f010385f:	e8 d8 fd ff ff       	call   f010363c <env_alloc>
	// cprintf("newenv = %p, envs[0] = %p\n", newenv, envs);
	if (r)
f0103864:	83 c4 10             	add    $0x10,%esp
f0103867:	85 c0                	test   %eax,%eax
f0103869:	75 47                	jne    f01038b2 <env_create+0x62>
		panic("Environment allocation faulted: %e", r);
	load_icode(newenv, binary);
f010386b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	if (elf->e_magic != ELF_MAGIC)
f010386e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103871:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f0103877:	75 4e                	jne    f01038c7 <env_create+0x77>
	struct Proghdr *ph = (struct Proghdr *) (binary + elf->e_phoff), 
f0103879:	8b 45 08             	mov    0x8(%ebp),%eax
f010387c:	89 c6                	mov    %eax,%esi
f010387e:	03 70 1c             	add    0x1c(%eax),%esi
				   *eph = ph + elf->e_phnum;
f0103881:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
f0103885:	c1 e0 05             	shl    $0x5,%eax
f0103888:	01 f0                	add    %esi,%eax
f010388a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	pte_t pgdir_pte = *pgdir_walk(kern_pgdir, e->env_pgdir, 0);
f010388d:	83 ec 04             	sub    $0x4,%esp
f0103890:	6a 00                	push   $0x0
f0103892:	ff 77 60             	pushl  0x60(%edi)
f0103895:	ff 35 8c 6e 29 f0    	pushl  0xf0296e8c
f010389b:	e8 12 dc ff ff       	call   f01014b2 <pgdir_walk>
	physaddr_t pgdir_phy = PTE_ADDR(pgdir_pte);
f01038a0:	8b 00                	mov    (%eax),%eax
f01038a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01038a7:	0f 22 d8             	mov    %eax,%cr3
f01038aa:	83 c4 10             	add    $0x10,%esp
f01038ad:	e9 df 00 00 00       	jmp    f0103991 <env_create+0x141>
		panic("Environment allocation faulted: %e", r);
f01038b2:	50                   	push   %eax
f01038b3:	68 ac 7d 10 f0       	push   $0xf0107dac
f01038b8:	68 a6 01 00 00       	push   $0x1a6
f01038bd:	68 f3 7d 10 f0       	push   $0xf0107df3
f01038c2:	e8 cd c7 ff ff       	call   f0100094 <_panic>
		panic("Not a valid elf binary!");
f01038c7:	83 ec 04             	sub    $0x4,%esp
f01038ca:	68 13 7e 10 f0       	push   $0xf0107e13
f01038cf:	68 68 01 00 00       	push   $0x168
f01038d4:	68 f3 7d 10 f0       	push   $0xf0107df3
f01038d9:	e8 b6 c7 ff ff       	call   f0100094 <_panic>
			region_alloc(e, (void*)ph0->p_va, ph0->p_memsz);
f01038de:	8b 46 08             	mov    0x8(%esi),%eax
	uintptr_t l = ROUNDDOWN((uintptr_t)va, PGSIZE), 
f01038e1:	89 c3                	mov    %eax,%ebx
f01038e3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
			  r = ROUNDUP((uintptr_t)(va + len), PGSIZE);
f01038e9:	03 46 14             	add    0x14(%esi),%eax
f01038ec:	05 ff 0f 00 00       	add    $0xfff,%eax
f01038f1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01038f6:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01038f9:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01038fc:	89 c6                	mov    %eax,%esi
	for (uintptr_t ptr = l; ptr < r; ptr += PGSIZE) {
f01038fe:	39 de                	cmp    %ebx,%esi
f0103900:	76 5a                	jbe    f010395c <env_create+0x10c>
		struct PageInfo *pg = page_alloc(0);
f0103902:	83 ec 0c             	sub    $0xc,%esp
f0103905:	6a 00                	push   $0x0
f0103907:	e8 bc da ff ff       	call   f01013c8 <page_alloc>
		if (!pg)
f010390c:	83 c4 10             	add    $0x10,%esp
f010390f:	85 c0                	test   %eax,%eax
f0103911:	74 1b                	je     f010392e <env_create+0xde>
		int res = page_insert(e->env_pgdir, pg, (void*)ptr, PTE_U | PTE_W);
f0103913:	6a 06                	push   $0x6
f0103915:	53                   	push   %ebx
f0103916:	50                   	push   %eax
f0103917:	ff 77 60             	pushl  0x60(%edi)
f010391a:	e8 02 de ff ff       	call   f0101721 <page_insert>
		if (res)
f010391f:	83 c4 10             	add    $0x10,%esp
f0103922:	85 c0                	test   %eax,%eax
f0103924:	75 1f                	jne    f0103945 <env_create+0xf5>
	for (uintptr_t ptr = l; ptr < r; ptr += PGSIZE) {
f0103926:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010392c:	eb d0                	jmp    f01038fe <env_create+0xae>
			panic("No free page for allocation.");
f010392e:	83 ec 04             	sub    $0x4,%esp
f0103931:	68 2b 7e 10 f0       	push   $0xf0107e2b
f0103936:	68 26 01 00 00       	push   $0x126
f010393b:	68 f3 7d 10 f0       	push   $0xf0107df3
f0103940:	e8 4f c7 ff ff       	call   f0100094 <_panic>
			panic("Page insertion result: %e", r);
f0103945:	ff 75 cc             	pushl  -0x34(%ebp)
f0103948:	68 48 7e 10 f0       	push   $0xf0107e48
f010394d:	68 29 01 00 00       	push   $0x129
f0103952:	68 f3 7d 10 f0       	push   $0xf0107df3
f0103957:	e8 38 c7 ff ff       	call   f0100094 <_panic>
f010395c:	8b 75 d0             	mov    -0x30(%ebp),%esi
			memcpy((void*)ph0->p_va, binary + ph0->p_offset, ph0->p_filesz);
f010395f:	83 ec 04             	sub    $0x4,%esp
f0103962:	ff 76 10             	pushl  0x10(%esi)
f0103965:	8b 45 08             	mov    0x8(%ebp),%eax
f0103968:	03 46 04             	add    0x4(%esi),%eax
f010396b:	50                   	push   %eax
f010396c:	ff 76 08             	pushl  0x8(%esi)
f010396f:	e8 5f 22 00 00       	call   f0105bd3 <memcpy>
					ph0->p_memsz - ph0->p_filesz);
f0103974:	8b 46 10             	mov    0x10(%esi),%eax
			memset((void*)ph0->p_va + ph0->p_filesz, 0, 
f0103977:	83 c4 0c             	add    $0xc,%esp
f010397a:	8b 56 14             	mov    0x14(%esi),%edx
f010397d:	29 c2                	sub    %eax,%edx
f010397f:	52                   	push   %edx
f0103980:	6a 00                	push   $0x0
f0103982:	03 46 08             	add    0x8(%esi),%eax
f0103985:	50                   	push   %eax
f0103986:	e8 95 21 00 00       	call   f0105b20 <memset>
f010398b:	83 c4 10             	add    $0x10,%esp
	for (struct Proghdr* ph0 = ph; ph0 < eph; ph0++) {
f010398e:	83 c6 20             	add    $0x20,%esi
f0103991:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0103994:	76 1e                	jbe    f01039b4 <env_create+0x164>
		if (ph0->p_type == ELF_PROG_LOAD) {
f0103996:	83 3e 01             	cmpl   $0x1,(%esi)
f0103999:	0f 84 3f ff ff ff    	je     f01038de <env_create+0x8e>
			cprintf("Found a ph with type %d; skipping\n", ph0->p_filesz);
f010399f:	83 ec 08             	sub    $0x8,%esp
f01039a2:	ff 76 10             	pushl  0x10(%esi)
f01039a5:	68 d0 7d 10 f0       	push   $0xf0107dd0
f01039aa:	e8 e4 05 00 00       	call   f0103f93 <cprintf>
f01039af:	83 c4 10             	add    $0x10,%esp
f01039b2:	eb da                	jmp    f010398e <env_create+0x13e>
	e->env_tf.tf_eip = elf->e_entry;
f01039b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01039b7:	8b 40 18             	mov    0x18(%eax),%eax
f01039ba:	89 47 30             	mov    %eax,0x30(%edi)
	e->env_tf.tf_eflags = 0;
f01039bd:	c7 47 38 00 00 00 00 	movl   $0x0,0x38(%edi)
	lcr3(PADDR(kern_pgdir));
f01039c4:	a1 8c 6e 29 f0       	mov    0xf0296e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01039c9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039ce:	76 38                	jbe    f0103a08 <env_create+0x1b8>
	return (physaddr_t)kva - KERNBASE;
f01039d0:	05 00 00 00 10       	add    $0x10000000,%eax
f01039d5:	0f 22 d8             	mov    %eax,%cr3
	struct PageInfo *stack_page = page_alloc(ALLOC_ZERO);
f01039d8:	83 ec 0c             	sub    $0xc,%esp
f01039db:	6a 01                	push   $0x1
f01039dd:	e8 e6 d9 ff ff       	call   f01013c8 <page_alloc>
	if (!stack_page)
f01039e2:	83 c4 10             	add    $0x10,%esp
f01039e5:	85 c0                	test   %eax,%eax
f01039e7:	74 34                	je     f0103a1d <env_create+0x1cd>
	int r = page_insert(e->env_pgdir, stack_page, (void*)USTACKTOP - PGSIZE, PTE_U | PTE_W);
f01039e9:	6a 06                	push   $0x6
f01039eb:	68 00 d0 bf ee       	push   $0xeebfd000
f01039f0:	50                   	push   %eax
f01039f1:	ff 77 60             	pushl  0x60(%edi)
f01039f4:	e8 28 dd ff ff       	call   f0101721 <page_insert>
	if (r)
f01039f9:	83 c4 10             	add    $0x10,%esp
f01039fc:	85 c0                	test   %eax,%eax
f01039fe:	75 34                	jne    f0103a34 <env_create+0x1e4>
}
f0103a00:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103a03:	5b                   	pop    %ebx
f0103a04:	5e                   	pop    %esi
f0103a05:	5f                   	pop    %edi
f0103a06:	5d                   	pop    %ebp
f0103a07:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a08:	50                   	push   %eax
f0103a09:	68 ac 69 10 f0       	push   $0xf01069ac
f0103a0e:	68 88 01 00 00       	push   $0x188
f0103a13:	68 f3 7d 10 f0       	push   $0xf0107df3
f0103a18:	e8 77 c6 ff ff       	call   f0100094 <_panic>
		panic("No free page for allocation.");
f0103a1d:	83 ec 04             	sub    $0x4,%esp
f0103a20:	68 2b 7e 10 f0       	push   $0xf0107e2b
f0103a25:	68 90 01 00 00       	push   $0x190
f0103a2a:	68 f3 7d 10 f0       	push   $0xf0107df3
f0103a2f:	e8 60 c6 ff ff       	call   f0100094 <_panic>
		panic("Page insertion result: %e", r);
f0103a34:	50                   	push   %eax
f0103a35:	68 48 7e 10 f0       	push   $0xf0107e48
f0103a3a:	68 93 01 00 00       	push   $0x193
f0103a3f:	68 f3 7d 10 f0       	push   $0xf0107df3
f0103a44:	e8 4b c6 ff ff       	call   f0100094 <_panic>

f0103a49 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103a49:	55                   	push   %ebp
f0103a4a:	89 e5                	mov    %esp,%ebp
f0103a4c:	57                   	push   %edi
f0103a4d:	56                   	push   %esi
f0103a4e:	53                   	push   %ebx
f0103a4f:	83 ec 1c             	sub    $0x1c,%esp
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103a52:	e8 a3 27 00 00       	call   f01061fa <cpunum>
f0103a57:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103a5a:	01 c2                	add    %eax,%edx
f0103a5c:	01 d2                	add    %edx,%edx
f0103a5e:	01 c2                	add    %eax,%edx
f0103a60:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a63:	8b 55 08             	mov    0x8(%ebp),%edx
f0103a66:	39 14 85 28 70 29 f0 	cmp    %edx,-0xfd68fd8(,%eax,4)
f0103a6d:	75 14                	jne    f0103a83 <env_free+0x3a>
		lcr3(PADDR(kern_pgdir));
f0103a6f:	a1 8c 6e 29 f0       	mov    0xf0296e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103a74:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a79:	76 65                	jbe    f0103ae0 <env_free+0x97>
	return (physaddr_t)kva - KERNBASE;
f0103a7b:	05 00 00 00 10       	add    $0x10000000,%eax
f0103a80:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103a83:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a86:	8b 58 48             	mov    0x48(%eax),%ebx
f0103a89:	e8 6c 27 00 00       	call   f01061fa <cpunum>
f0103a8e:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103a91:	01 c2                	add    %eax,%edx
f0103a93:	01 d2                	add    %edx,%edx
f0103a95:	01 c2                	add    %eax,%edx
f0103a97:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a9a:	83 3c 85 28 70 29 f0 	cmpl   $0x0,-0xfd68fd8(,%eax,4)
f0103aa1:	00 
f0103aa2:	74 51                	je     f0103af5 <env_free+0xac>
f0103aa4:	e8 51 27 00 00       	call   f01061fa <cpunum>
f0103aa9:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103aac:	01 c2                	add    %eax,%edx
f0103aae:	01 d2                	add    %edx,%edx
f0103ab0:	01 c2                	add    %eax,%edx
f0103ab2:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ab5:	8b 04 85 28 70 29 f0 	mov    -0xfd68fd8(,%eax,4),%eax
f0103abc:	8b 40 48             	mov    0x48(%eax),%eax
f0103abf:	83 ec 04             	sub    $0x4,%esp
f0103ac2:	53                   	push   %ebx
f0103ac3:	50                   	push   %eax
f0103ac4:	68 62 7e 10 f0       	push   $0xf0107e62
f0103ac9:	e8 c5 04 00 00       	call   f0103f93 <cprintf>
f0103ace:	83 c4 10             	add    $0x10,%esp
f0103ad1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0103ad8:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103adb:	e9 96 00 00 00       	jmp    f0103b76 <env_free+0x12d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ae0:	50                   	push   %eax
f0103ae1:	68 ac 69 10 f0       	push   $0xf01069ac
f0103ae6:	68 b8 01 00 00       	push   $0x1b8
f0103aeb:	68 f3 7d 10 f0       	push   $0xf0107df3
f0103af0:	e8 9f c5 ff ff       	call   f0100094 <_panic>
f0103af5:	b8 00 00 00 00       	mov    $0x0,%eax
f0103afa:	eb c3                	jmp    f0103abf <env_free+0x76>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103afc:	50                   	push   %eax
f0103afd:	68 88 69 10 f0       	push   $0xf0106988
f0103b02:	68 c7 01 00 00       	push   $0x1c7
f0103b07:	68 f3 7d 10 f0       	push   $0xf0107df3
f0103b0c:	e8 83 c5 ff ff       	call   f0100094 <_panic>
f0103b11:	83 c3 04             	add    $0x4,%ebx
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103b14:	39 f3                	cmp    %esi,%ebx
f0103b16:	74 21                	je     f0103b39 <env_free+0xf0>
			if (pt[pteno] & PTE_P)
f0103b18:	f6 03 01             	testb  $0x1,(%ebx)
f0103b1b:	74 f4                	je     f0103b11 <env_free+0xc8>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b1d:	83 ec 08             	sub    $0x8,%esp
f0103b20:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b23:	01 d8                	add    %ebx,%eax
f0103b25:	c1 e0 0a             	shl    $0xa,%eax
f0103b28:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103b2b:	50                   	push   %eax
f0103b2c:	ff 77 60             	pushl  0x60(%edi)
f0103b2f:	e8 93 db ff ff       	call   f01016c7 <page_remove>
f0103b34:	83 c4 10             	add    $0x10,%esp
f0103b37:	eb d8                	jmp    f0103b11 <env_free+0xc8>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103b39:	8b 47 60             	mov    0x60(%edi),%eax
f0103b3c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b3f:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103b46:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103b49:	3b 05 88 6e 29 f0    	cmp    0xf0296e88,%eax
f0103b4f:	73 6a                	jae    f0103bbb <env_free+0x172>
		page_decref(pa2page(pa));
f0103b51:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103b54:	a1 90 6e 29 f0       	mov    0xf0296e90,%eax
f0103b59:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103b5c:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103b5f:	50                   	push   %eax
f0103b60:	e8 27 d9 ff ff       	call   f010148c <page_decref>
f0103b65:	83 c4 10             	add    $0x10,%esp
f0103b68:	83 45 dc 04          	addl   $0x4,-0x24(%ebp)
f0103b6c:	8b 45 dc             	mov    -0x24(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103b6f:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103b74:	74 59                	je     f0103bcf <env_free+0x186>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103b76:	8b 47 60             	mov    0x60(%edi),%eax
f0103b79:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b7c:	8b 04 10             	mov    (%eax,%edx,1),%eax
f0103b7f:	a8 01                	test   $0x1,%al
f0103b81:	74 e5                	je     f0103b68 <env_free+0x11f>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103b83:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0103b88:	89 c2                	mov    %eax,%edx
f0103b8a:	c1 ea 0c             	shr    $0xc,%edx
f0103b8d:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0103b90:	39 15 88 6e 29 f0    	cmp    %edx,0xf0296e88
f0103b96:	0f 86 60 ff ff ff    	jbe    f0103afc <env_free+0xb3>
	return (void *)(pa + KERNBASE);
f0103b9c:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103ba2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103ba5:	c1 e2 14             	shl    $0x14,%edx
f0103ba8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103bab:	8d b0 00 10 00 f0    	lea    -0xffff000(%eax),%esi
f0103bb1:	f7 d8                	neg    %eax
f0103bb3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103bb6:	e9 5d ff ff ff       	jmp    f0103b18 <env_free+0xcf>
		panic("pa2page called with invalid pa");
f0103bbb:	83 ec 04             	sub    $0x4,%esp
f0103bbe:	68 24 72 10 f0       	push   $0xf0107224
f0103bc3:	6a 51                	push   $0x51
f0103bc5:	68 69 7a 10 f0       	push   $0xf0107a69
f0103bca:	e8 c5 c4 ff ff       	call   f0100094 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103bcf:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bd2:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103bd5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103bda:	76 52                	jbe    f0103c2e <env_free+0x1e5>
	e->env_pgdir = 0;
f0103bdc:	8b 55 08             	mov    0x8(%ebp),%edx
f0103bdf:	c7 42 60 00 00 00 00 	movl   $0x0,0x60(%edx)
	return (physaddr_t)kva - KERNBASE;
f0103be6:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103beb:	c1 e8 0c             	shr    $0xc,%eax
f0103bee:	3b 05 88 6e 29 f0    	cmp    0xf0296e88,%eax
f0103bf4:	73 4d                	jae    f0103c43 <env_free+0x1fa>
	page_decref(pa2page(pa));
f0103bf6:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103bf9:	8b 15 90 6e 29 f0    	mov    0xf0296e90,%edx
f0103bff:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103c02:	50                   	push   %eax
f0103c03:	e8 84 d8 ff ff       	call   f010148c <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103c08:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c0b:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f0103c12:	a1 4c 62 29 f0       	mov    0xf029624c,%eax
f0103c17:	8b 55 08             	mov    0x8(%ebp),%edx
f0103c1a:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f0103c1d:	89 15 4c 62 29 f0    	mov    %edx,0xf029624c
}
f0103c23:	83 c4 10             	add    $0x10,%esp
f0103c26:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103c29:	5b                   	pop    %ebx
f0103c2a:	5e                   	pop    %esi
f0103c2b:	5f                   	pop    %edi
f0103c2c:	5d                   	pop    %ebp
f0103c2d:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103c2e:	50                   	push   %eax
f0103c2f:	68 ac 69 10 f0       	push   $0xf01069ac
f0103c34:	68 d5 01 00 00       	push   $0x1d5
f0103c39:	68 f3 7d 10 f0       	push   $0xf0107df3
f0103c3e:	e8 51 c4 ff ff       	call   f0100094 <_panic>
		panic("pa2page called with invalid pa");
f0103c43:	83 ec 04             	sub    $0x4,%esp
f0103c46:	68 24 72 10 f0       	push   $0xf0107224
f0103c4b:	6a 51                	push   $0x51
f0103c4d:	68 69 7a 10 f0       	push   $0xf0107a69
f0103c52:	e8 3d c4 ff ff       	call   f0100094 <_panic>

f0103c57 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103c57:	55                   	push   %ebp
f0103c58:	89 e5                	mov    %esp,%ebp
f0103c5a:	53                   	push   %ebx
f0103c5b:	83 ec 04             	sub    $0x4,%esp
f0103c5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103c61:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103c65:	74 2b                	je     f0103c92 <env_destroy+0x3b>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f0103c67:	83 ec 0c             	sub    $0xc,%esp
f0103c6a:	53                   	push   %ebx
f0103c6b:	e8 d9 fd ff ff       	call   f0103a49 <env_free>

	if (curenv == e) {
f0103c70:	e8 85 25 00 00       	call   f01061fa <cpunum>
f0103c75:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103c78:	01 c2                	add    %eax,%edx
f0103c7a:	01 d2                	add    %edx,%edx
f0103c7c:	01 c2                	add    %eax,%edx
f0103c7e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c81:	83 c4 10             	add    $0x10,%esp
f0103c84:	39 1c 85 28 70 29 f0 	cmp    %ebx,-0xfd68fd8(,%eax,4)
f0103c8b:	74 28                	je     f0103cb5 <env_destroy+0x5e>
		curenv = NULL;
		sched_yield();
	}
}
f0103c8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103c90:	c9                   	leave  
f0103c91:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103c92:	e8 63 25 00 00       	call   f01061fa <cpunum>
f0103c97:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103c9a:	01 c2                	add    %eax,%edx
f0103c9c:	01 d2                	add    %edx,%edx
f0103c9e:	01 c2                	add    %eax,%edx
f0103ca0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ca3:	39 1c 85 28 70 29 f0 	cmp    %ebx,-0xfd68fd8(,%eax,4)
f0103caa:	74 bb                	je     f0103c67 <env_destroy+0x10>
		e->env_status = ENV_DYING;
f0103cac:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103cb3:	eb d8                	jmp    f0103c8d <env_destroy+0x36>
		curenv = NULL;
f0103cb5:	e8 40 25 00 00       	call   f01061fa <cpunum>
f0103cba:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cbd:	c7 80 28 70 29 f0 00 	movl   $0x0,-0xfd68fd8(%eax)
f0103cc4:	00 00 00 
		sched_yield();
f0103cc7:	e8 07 0e 00 00       	call   f0104ad3 <sched_yield>

f0103ccc <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103ccc:	55                   	push   %ebp
f0103ccd:	89 e5                	mov    %esp,%ebp
f0103ccf:	53                   	push   %ebx
f0103cd0:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103cd3:	e8 22 25 00 00       	call   f01061fa <cpunum>
f0103cd8:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103cdb:	01 c2                	add    %eax,%edx
f0103cdd:	01 d2                	add    %edx,%edx
f0103cdf:	01 c2                	add    %eax,%edx
f0103ce1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ce4:	8b 1c 85 28 70 29 f0 	mov    -0xfd68fd8(,%eax,4),%ebx
f0103ceb:	e8 0a 25 00 00       	call   f01061fa <cpunum>
f0103cf0:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0103cf3:	8b 65 08             	mov    0x8(%ebp),%esp
f0103cf6:	61                   	popa   
f0103cf7:	07                   	pop    %es
f0103cf8:	1f                   	pop    %ds
f0103cf9:	83 c4 08             	add    $0x8,%esp
f0103cfc:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103cfd:	83 ec 04             	sub    $0x4,%esp
f0103d00:	68 78 7e 10 f0       	push   $0xf0107e78
f0103d05:	68 0c 02 00 00       	push   $0x20c
f0103d0a:	68 f3 7d 10 f0       	push   $0xf0107df3
f0103d0f:	e8 80 c3 ff ff       	call   f0100094 <_panic>

f0103d14 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103d14:	55                   	push   %ebp
f0103d15:	89 e5                	mov    %esp,%ebp
f0103d17:	83 ec 08             	sub    $0x8,%esp
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// Unset curenv running before going to new env.
	if (curenv && curenv->env_status == ENV_RUNNING) {
f0103d1a:	e8 db 24 00 00       	call   f01061fa <cpunum>
f0103d1f:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103d22:	01 c2                	add    %eax,%edx
f0103d24:	01 d2                	add    %edx,%edx
f0103d26:	01 c2                	add    %eax,%edx
f0103d28:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d2b:	83 3c 85 28 70 29 f0 	cmpl   $0x0,-0xfd68fd8(,%eax,4)
f0103d32:	00 
f0103d33:	74 18                	je     f0103d4d <env_run+0x39>
f0103d35:	e8 c0 24 00 00       	call   f01061fa <cpunum>
f0103d3a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d3d:	8b 80 28 70 29 f0    	mov    -0xfd68fd8(%eax),%eax
f0103d43:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103d47:	0f 84 8c 00 00 00    	je     f0103dd9 <env_run+0xc5>
		curenv->env_status = ENV_RUNNABLE;
	}

	curenv = e;
f0103d4d:	e8 a8 24 00 00       	call   f01061fa <cpunum>
f0103d52:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103d55:	01 c2                	add    %eax,%edx
f0103d57:	01 d2                	add    %edx,%edx
f0103d59:	01 c2                	add    %eax,%edx
f0103d5b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d5e:	8b 55 08             	mov    0x8(%ebp),%edx
f0103d61:	89 14 85 28 70 29 f0 	mov    %edx,-0xfd68fd8(,%eax,4)
	curenv->env_status = ENV_RUNNING;
f0103d68:	e8 8d 24 00 00       	call   f01061fa <cpunum>
f0103d6d:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103d70:	01 c2                	add    %eax,%edx
f0103d72:	01 d2                	add    %edx,%edx
f0103d74:	01 c2                	add    %eax,%edx
f0103d76:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d79:	8b 04 85 28 70 29 f0 	mov    -0xfd68fd8(,%eax,4),%eax
f0103d80:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++; // Incremetn run count
f0103d87:	e8 6e 24 00 00       	call   f01061fa <cpunum>
f0103d8c:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103d8f:	01 c2                	add    %eax,%edx
f0103d91:	01 d2                	add    %edx,%edx
f0103d93:	01 c2                	add    %eax,%edx
f0103d95:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d98:	8b 04 85 28 70 29 f0 	mov    -0xfd68fd8(,%eax,4),%eax
f0103d9f:	ff 40 58             	incl   0x58(%eax)

	// Jump to user env pgdir
	lcr3(PADDR(curenv->env_pgdir));
f0103da2:	e8 53 24 00 00       	call   f01061fa <cpunum>
f0103da7:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103daa:	01 c2                	add    %eax,%edx
f0103dac:	01 d2                	add    %edx,%edx
f0103dae:	01 c2                	add    %eax,%edx
f0103db0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103db3:	8b 04 85 28 70 29 f0 	mov    -0xfd68fd8(,%eax,4),%eax
f0103dba:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103dbd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103dc2:	77 2f                	ja     f0103df3 <env_run+0xdf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103dc4:	50                   	push   %eax
f0103dc5:	68 ac 69 10 f0       	push   $0xf01069ac
f0103dca:	68 33 02 00 00       	push   $0x233
f0103dcf:	68 f3 7d 10 f0       	push   $0xf0107df3
f0103dd4:	e8 bb c2 ff ff       	call   f0100094 <_panic>
		curenv->env_status = ENV_RUNNABLE;
f0103dd9:	e8 1c 24 00 00       	call   f01061fa <cpunum>
f0103dde:	6b c0 74             	imul   $0x74,%eax,%eax
f0103de1:	8b 80 28 70 29 f0    	mov    -0xfd68fd8(%eax),%eax
f0103de7:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0103dee:	e9 5a ff ff ff       	jmp    f0103d4d <env_run+0x39>
	return (physaddr_t)kva - KERNBASE;
f0103df3:	05 00 00 00 10       	add    $0x10000000,%eax
f0103df8:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103dfb:	83 ec 0c             	sub    $0xc,%esp
f0103dfe:	68 c0 23 12 f0       	push   $0xf01223c0
f0103e03:	e8 13 27 00 00       	call   f010651b <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103e08:	f3 90                	pause  

	// Unlock the kernel if we're heading user mode.
	unlock_kernel();

	// Do the final work.
	env_pop_tf(&curenv->env_tf);  // Does not return.
f0103e0a:	e8 eb 23 00 00       	call   f01061fa <cpunum>
f0103e0f:	83 c4 04             	add    $0x4,%esp
f0103e12:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e15:	ff b0 28 70 29 f0    	pushl  -0xfd68fd8(%eax)
f0103e1b:	e8 ac fe ff ff       	call   f0103ccc <env_pop_tf>

f0103e20 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103e20:	55                   	push   %ebp
f0103e21:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e23:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e26:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e2b:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103e2c:	ba 71 00 00 00       	mov    $0x71,%edx
f0103e31:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103e32:	0f b6 c0             	movzbl %al,%eax
}
f0103e35:	5d                   	pop    %ebp
f0103e36:	c3                   	ret    

f0103e37 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103e37:	55                   	push   %ebp
f0103e38:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e3a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e3d:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e42:	ee                   	out    %al,(%dx)
f0103e43:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e46:	ba 71 00 00 00       	mov    $0x71,%edx
f0103e4b:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103e4c:	5d                   	pop    %ebp
f0103e4d:	c3                   	ret    

f0103e4e <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103e4e:	55                   	push   %ebp
f0103e4f:	89 e5                	mov    %esp,%ebp
f0103e51:	56                   	push   %esi
f0103e52:	53                   	push   %ebx
f0103e53:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103e56:	66 a3 a8 23 12 f0    	mov    %ax,0xf01223a8
	if (!didinit)
f0103e5c:	80 3d 50 62 29 f0 00 	cmpb   $0x0,0xf0296250
f0103e63:	75 07                	jne    f0103e6c <irq_setmask_8259A+0x1e>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f0103e65:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103e68:	5b                   	pop    %ebx
f0103e69:	5e                   	pop    %esi
f0103e6a:	5d                   	pop    %ebp
f0103e6b:	c3                   	ret    
f0103e6c:	89 c6                	mov    %eax,%esi
f0103e6e:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e73:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103e74:	66 c1 e8 08          	shr    $0x8,%ax
f0103e78:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103e7d:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103e7e:	83 ec 0c             	sub    $0xc,%esp
f0103e81:	68 84 7e 10 f0       	push   $0xf0107e84
f0103e86:	e8 08 01 00 00       	call   f0103f93 <cprintf>
f0103e8b:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103e8e:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103e93:	0f b7 f6             	movzwl %si,%esi
f0103e96:	f7 d6                	not    %esi
f0103e98:	eb 06                	jmp    f0103ea0 <irq_setmask_8259A+0x52>
	for (i = 0; i < 16; i++)
f0103e9a:	43                   	inc    %ebx
f0103e9b:	83 fb 10             	cmp    $0x10,%ebx
f0103e9e:	74 1d                	je     f0103ebd <irq_setmask_8259A+0x6f>
		if (~mask & (1<<i))
f0103ea0:	89 f0                	mov    %esi,%eax
f0103ea2:	88 d9                	mov    %bl,%cl
f0103ea4:	d3 f8                	sar    %cl,%eax
f0103ea6:	a8 01                	test   $0x1,%al
f0103ea8:	74 f0                	je     f0103e9a <irq_setmask_8259A+0x4c>
			cprintf(" %d", i);
f0103eaa:	83 ec 08             	sub    $0x8,%esp
f0103ead:	53                   	push   %ebx
f0103eae:	68 b7 83 10 f0       	push   $0xf01083b7
f0103eb3:	e8 db 00 00 00       	call   f0103f93 <cprintf>
f0103eb8:	83 c4 10             	add    $0x10,%esp
f0103ebb:	eb dd                	jmp    f0103e9a <irq_setmask_8259A+0x4c>
	cprintf("\n");
f0103ebd:	83 ec 0c             	sub    $0xc,%esp
f0103ec0:	68 db 6c 10 f0       	push   $0xf0106cdb
f0103ec5:	e8 c9 00 00 00       	call   f0103f93 <cprintf>
f0103eca:	83 c4 10             	add    $0x10,%esp
f0103ecd:	eb 96                	jmp    f0103e65 <irq_setmask_8259A+0x17>

f0103ecf <pic_init>:
{
f0103ecf:	55                   	push   %ebp
f0103ed0:	89 e5                	mov    %esp,%ebp
f0103ed2:	57                   	push   %edi
f0103ed3:	56                   	push   %esi
f0103ed4:	53                   	push   %ebx
f0103ed5:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f0103ed8:	c6 05 50 62 29 f0 01 	movb   $0x1,0xf0296250
f0103edf:	b0 ff                	mov    $0xff,%al
f0103ee1:	bb 21 00 00 00       	mov    $0x21,%ebx
f0103ee6:	89 da                	mov    %ebx,%edx
f0103ee8:	ee                   	out    %al,(%dx)
f0103ee9:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f0103eee:	89 ca                	mov    %ecx,%edx
f0103ef0:	ee                   	out    %al,(%dx)
f0103ef1:	bf 11 00 00 00       	mov    $0x11,%edi
f0103ef6:	be 20 00 00 00       	mov    $0x20,%esi
f0103efb:	89 f8                	mov    %edi,%eax
f0103efd:	89 f2                	mov    %esi,%edx
f0103eff:	ee                   	out    %al,(%dx)
f0103f00:	b0 20                	mov    $0x20,%al
f0103f02:	89 da                	mov    %ebx,%edx
f0103f04:	ee                   	out    %al,(%dx)
f0103f05:	b0 04                	mov    $0x4,%al
f0103f07:	ee                   	out    %al,(%dx)
f0103f08:	b0 03                	mov    $0x3,%al
f0103f0a:	ee                   	out    %al,(%dx)
f0103f0b:	bb a0 00 00 00       	mov    $0xa0,%ebx
f0103f10:	89 f8                	mov    %edi,%eax
f0103f12:	89 da                	mov    %ebx,%edx
f0103f14:	ee                   	out    %al,(%dx)
f0103f15:	b0 28                	mov    $0x28,%al
f0103f17:	89 ca                	mov    %ecx,%edx
f0103f19:	ee                   	out    %al,(%dx)
f0103f1a:	b0 02                	mov    $0x2,%al
f0103f1c:	ee                   	out    %al,(%dx)
f0103f1d:	b0 01                	mov    $0x1,%al
f0103f1f:	ee                   	out    %al,(%dx)
f0103f20:	bf 68 00 00 00       	mov    $0x68,%edi
f0103f25:	89 f8                	mov    %edi,%eax
f0103f27:	89 f2                	mov    %esi,%edx
f0103f29:	ee                   	out    %al,(%dx)
f0103f2a:	b1 0a                	mov    $0xa,%cl
f0103f2c:	88 c8                	mov    %cl,%al
f0103f2e:	ee                   	out    %al,(%dx)
f0103f2f:	89 f8                	mov    %edi,%eax
f0103f31:	89 da                	mov    %ebx,%edx
f0103f33:	ee                   	out    %al,(%dx)
f0103f34:	88 c8                	mov    %cl,%al
f0103f36:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103f37:	66 a1 a8 23 12 f0    	mov    0xf01223a8,%ax
f0103f3d:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103f41:	74 0f                	je     f0103f52 <pic_init+0x83>
		irq_setmask_8259A(irq_mask_8259A);
f0103f43:	83 ec 0c             	sub    $0xc,%esp
f0103f46:	0f b7 c0             	movzwl %ax,%eax
f0103f49:	50                   	push   %eax
f0103f4a:	e8 ff fe ff ff       	call   f0103e4e <irq_setmask_8259A>
f0103f4f:	83 c4 10             	add    $0x10,%esp
}
f0103f52:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f55:	5b                   	pop    %ebx
f0103f56:	5e                   	pop    %esi
f0103f57:	5f                   	pop    %edi
f0103f58:	5d                   	pop    %ebp
f0103f59:	c3                   	ret    

f0103f5a <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103f5a:	55                   	push   %ebp
f0103f5b:	89 e5                	mov    %esp,%ebp
f0103f5d:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103f60:	ff 75 08             	pushl  0x8(%ebp)
f0103f63:	e8 b4 c8 ff ff       	call   f010081c <cputchar>
	*cnt++;
}
f0103f68:	83 c4 10             	add    $0x10,%esp
f0103f6b:	c9                   	leave  
f0103f6c:	c3                   	ret    

f0103f6d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103f6d:	55                   	push   %ebp
f0103f6e:	89 e5                	mov    %esp,%ebp
f0103f70:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103f73:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103f7a:	ff 75 0c             	pushl  0xc(%ebp)
f0103f7d:	ff 75 08             	pushl  0x8(%ebp)
f0103f80:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103f83:	50                   	push   %eax
f0103f84:	68 5a 3f 10 f0       	push   $0xf0103f5a
f0103f89:	e8 79 14 00 00       	call   f0105407 <vprintfmt>
	return cnt;
}
f0103f8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f91:	c9                   	leave  
f0103f92:	c3                   	ret    

f0103f93 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103f93:	55                   	push   %ebp
f0103f94:	89 e5                	mov    %esp,%ebp
f0103f96:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103f99:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103f9c:	50                   	push   %eax
f0103f9d:	ff 75 08             	pushl  0x8(%ebp)
f0103fa0:	e8 c8 ff ff ff       	call   f0103f6d <vcprintf>
	va_end(ap);

	return cnt;
}
f0103fa5:	c9                   	leave  
f0103fa6:	c3                   	ret    

f0103fa7 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103fa7:	55                   	push   %ebp
f0103fa8:	89 e5                	mov    %esp,%ebp
f0103faa:	57                   	push   %edi
f0103fab:	56                   	push   %esi
f0103fac:	53                   	push   %ebx
f0103fad:	83 ec 0c             	sub    $0xc,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	struct Taskstate* ts = &thiscpu->cpu_ts;
f0103fb0:	e8 45 22 00 00       	call   f01061fa <cpunum>
f0103fb5:	89 c6                	mov    %eax,%esi
f0103fb7:	8d 1c 00             	lea    (%eax,%eax,1),%ebx
f0103fba:	01 c3                	add    %eax,%ebx
f0103fbc:	01 db                	add    %ebx,%ebx
f0103fbe:	01 c3                	add    %eax,%ebx
f0103fc0:	c1 e3 02             	shl    $0x2,%ebx
f0103fc3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0103fc6:	8d 3c 85 2c 70 29 f0 	lea    -0xfd68fd4(,%eax,4),%edi
	ts->ts_esp0 = KSTACKTOP - cpunum() * (KSTKSIZE + KSTKGAP);
f0103fcd:	e8 28 22 00 00       	call   f01061fa <cpunum>
f0103fd2:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f0103fd5:	8d 14 95 20 70 29 f0 	lea    -0xfd68fe0(,%edx,4),%edx
f0103fdc:	c1 e0 10             	shl    $0x10,%eax
f0103fdf:	89 c1                	mov    %eax,%ecx
f0103fe1:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f0103fe6:	29 c8                	sub    %ecx,%eax
f0103fe8:	89 42 10             	mov    %eax,0x10(%edx)
	ts->ts_ss0 = GD_KD;
f0103feb:	66 c7 42 14 10 00    	movw   $0x10,0x14(%edx)
	ts->ts_iomb = sizeof(struct Taskstate);
f0103ff1:	01 f3                	add    %esi,%ebx
f0103ff3:	66 c7 04 9d 92 70 29 	movw   $0x68,-0xfd68f6e(,%ebx,4)
f0103ffa:	f0 68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) ts,
f0103ffd:	66 c7 05 68 23 12 f0 	movw   $0x67,0xf0122368
f0104004:	67 00 
f0104006:	66 89 3d 6a 23 12 f0 	mov    %di,0xf012236a
f010400d:	89 f8                	mov    %edi,%eax
f010400f:	c1 e8 10             	shr    $0x10,%eax
f0104012:	a2 6c 23 12 f0       	mov    %al,0xf012236c
f0104017:	c6 05 6e 23 12 f0 40 	movb   $0x40,0xf012236e
f010401e:	89 f8                	mov    %edi,%eax
f0104020:	c1 e8 18             	shr    $0x18,%eax
f0104023:	a2 6f 23 12 f0       	mov    %al,0xf012236f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0104028:	c6 05 6d 23 12 f0 89 	movb   $0x89,0xf012236d
	asm volatile("ltr %0" : : "r" (sel));
f010402f:	b8 28 00 00 00       	mov    $0x28,%eax
f0104034:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f0104037:	b8 ac 23 12 f0       	mov    $0xf01223ac,%eax
f010403c:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f010403f:	83 c4 0c             	add    $0xc,%esp
f0104042:	5b                   	pop    %ebx
f0104043:	5e                   	pop    %esi
f0104044:	5f                   	pop    %edi
f0104045:	5d                   	pop    %ebp
f0104046:	c3                   	ret    

f0104047 <trap_init>:
{
f0104047:	55                   	push   %ebp
f0104048:	89 e5                	mov    %esp,%ebp
f010404a:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE] , 1, GD_KT, (void*)H_DIVIDE ,0);   
f010404d:	b8 6e 49 10 f0       	mov    $0xf010496e,%eax
f0104052:	66 a3 60 62 29 f0    	mov    %ax,0xf0296260
f0104058:	66 c7 05 62 62 29 f0 	movw   $0x8,0xf0296262
f010405f:	08 00 
f0104061:	c6 05 64 62 29 f0 00 	movb   $0x0,0xf0296264
f0104068:	c6 05 65 62 29 f0 8f 	movb   $0x8f,0xf0296265
f010406f:	c1 e8 10             	shr    $0x10,%eax
f0104072:	66 a3 66 62 29 f0    	mov    %ax,0xf0296266
	SETGATE(idt[T_DEBUG]  , 1, GD_KT, (void*)H_DEBUG  ,0);  
f0104078:	b8 74 49 10 f0       	mov    $0xf0104974,%eax
f010407d:	66 a3 68 62 29 f0    	mov    %ax,0xf0296268
f0104083:	66 c7 05 6a 62 29 f0 	movw   $0x8,0xf029626a
f010408a:	08 00 
f010408c:	c6 05 6c 62 29 f0 00 	movb   $0x0,0xf029626c
f0104093:	c6 05 6d 62 29 f0 8f 	movb   $0x8f,0xf029626d
f010409a:	c1 e8 10             	shr    $0x10,%eax
f010409d:	66 a3 6e 62 29 f0    	mov    %ax,0xf029626e
	SETGATE(idt[T_NMI]    , 1, GD_KT, (void*)H_NMI    ,0);
f01040a3:	b8 7a 49 10 f0       	mov    $0xf010497a,%eax
f01040a8:	66 a3 70 62 29 f0    	mov    %ax,0xf0296270
f01040ae:	66 c7 05 72 62 29 f0 	movw   $0x8,0xf0296272
f01040b5:	08 00 
f01040b7:	c6 05 74 62 29 f0 00 	movb   $0x0,0xf0296274
f01040be:	c6 05 75 62 29 f0 8f 	movb   $0x8f,0xf0296275
f01040c5:	c1 e8 10             	shr    $0x10,%eax
f01040c8:	66 a3 76 62 29 f0    	mov    %ax,0xf0296276
	SETGATE(idt[T_BRKPT]  , 1, GD_KT, (void*)H_BRKPT  ,3);  // User level previlege (3)
f01040ce:	b8 80 49 10 f0       	mov    $0xf0104980,%eax
f01040d3:	66 a3 78 62 29 f0    	mov    %ax,0xf0296278
f01040d9:	66 c7 05 7a 62 29 f0 	movw   $0x8,0xf029627a
f01040e0:	08 00 
f01040e2:	c6 05 7c 62 29 f0 00 	movb   $0x0,0xf029627c
f01040e9:	c6 05 7d 62 29 f0 ef 	movb   $0xef,0xf029627d
f01040f0:	c1 e8 10             	shr    $0x10,%eax
f01040f3:	66 a3 7e 62 29 f0    	mov    %ax,0xf029627e
	SETGATE(idt[T_OFLOW]  , 1, GD_KT, (void*)H_OFLOW  ,0);  
f01040f9:	b8 86 49 10 f0       	mov    $0xf0104986,%eax
f01040fe:	66 a3 80 62 29 f0    	mov    %ax,0xf0296280
f0104104:	66 c7 05 82 62 29 f0 	movw   $0x8,0xf0296282
f010410b:	08 00 
f010410d:	c6 05 84 62 29 f0 00 	movb   $0x0,0xf0296284
f0104114:	c6 05 85 62 29 f0 8f 	movb   $0x8f,0xf0296285
f010411b:	c1 e8 10             	shr    $0x10,%eax
f010411e:	66 a3 86 62 29 f0    	mov    %ax,0xf0296286
	SETGATE(idt[T_BOUND]  , 1, GD_KT, (void*)H_BOUND  ,0);  
f0104124:	b8 8c 49 10 f0       	mov    $0xf010498c,%eax
f0104129:	66 a3 88 62 29 f0    	mov    %ax,0xf0296288
f010412f:	66 c7 05 8a 62 29 f0 	movw   $0x8,0xf029628a
f0104136:	08 00 
f0104138:	c6 05 8c 62 29 f0 00 	movb   $0x0,0xf029628c
f010413f:	c6 05 8d 62 29 f0 8f 	movb   $0x8f,0xf029628d
f0104146:	c1 e8 10             	shr    $0x10,%eax
f0104149:	66 a3 8e 62 29 f0    	mov    %ax,0xf029628e
	SETGATE(idt[T_ILLOP]  , 1, GD_KT, (void*)H_ILLOP  ,0);  
f010414f:	b8 92 49 10 f0       	mov    $0xf0104992,%eax
f0104154:	66 a3 90 62 29 f0    	mov    %ax,0xf0296290
f010415a:	66 c7 05 92 62 29 f0 	movw   $0x8,0xf0296292
f0104161:	08 00 
f0104163:	c6 05 94 62 29 f0 00 	movb   $0x0,0xf0296294
f010416a:	c6 05 95 62 29 f0 8f 	movb   $0x8f,0xf0296295
f0104171:	c1 e8 10             	shr    $0x10,%eax
f0104174:	66 a3 96 62 29 f0    	mov    %ax,0xf0296296
	SETGATE(idt[T_DEVICE] , 1, GD_KT, (void*)H_DEVICE ,0);   
f010417a:	b8 98 49 10 f0       	mov    $0xf0104998,%eax
f010417f:	66 a3 98 62 29 f0    	mov    %ax,0xf0296298
f0104185:	66 c7 05 9a 62 29 f0 	movw   $0x8,0xf029629a
f010418c:	08 00 
f010418e:	c6 05 9c 62 29 f0 00 	movb   $0x0,0xf029629c
f0104195:	c6 05 9d 62 29 f0 8f 	movb   $0x8f,0xf029629d
f010419c:	c1 e8 10             	shr    $0x10,%eax
f010419f:	66 a3 9e 62 29 f0    	mov    %ax,0xf029629e
	SETGATE(idt[T_DBLFLT] , 1, GD_KT, (void*)H_DBLFLT ,0);   
f01041a5:	b8 9e 49 10 f0       	mov    $0xf010499e,%eax
f01041aa:	66 a3 a0 62 29 f0    	mov    %ax,0xf02962a0
f01041b0:	66 c7 05 a2 62 29 f0 	movw   $0x8,0xf02962a2
f01041b7:	08 00 
f01041b9:	c6 05 a4 62 29 f0 00 	movb   $0x0,0xf02962a4
f01041c0:	c6 05 a5 62 29 f0 8f 	movb   $0x8f,0xf02962a5
f01041c7:	c1 e8 10             	shr    $0x10,%eax
f01041ca:	66 a3 a6 62 29 f0    	mov    %ax,0xf02962a6
	SETGATE(idt[T_TSS]    , 1, GD_KT, (void*)H_TSS    ,0);
f01041d0:	b8 a2 49 10 f0       	mov    $0xf01049a2,%eax
f01041d5:	66 a3 b0 62 29 f0    	mov    %ax,0xf02962b0
f01041db:	66 c7 05 b2 62 29 f0 	movw   $0x8,0xf02962b2
f01041e2:	08 00 
f01041e4:	c6 05 b4 62 29 f0 00 	movb   $0x0,0xf02962b4
f01041eb:	c6 05 b5 62 29 f0 8f 	movb   $0x8f,0xf02962b5
f01041f2:	c1 e8 10             	shr    $0x10,%eax
f01041f5:	66 a3 b6 62 29 f0    	mov    %ax,0xf02962b6
	SETGATE(idt[T_SEGNP]  , 1, GD_KT, (void*)H_SEGNP  ,0);  
f01041fb:	b8 a6 49 10 f0       	mov    $0xf01049a6,%eax
f0104200:	66 a3 b8 62 29 f0    	mov    %ax,0xf02962b8
f0104206:	66 c7 05 ba 62 29 f0 	movw   $0x8,0xf02962ba
f010420d:	08 00 
f010420f:	c6 05 bc 62 29 f0 00 	movb   $0x0,0xf02962bc
f0104216:	c6 05 bd 62 29 f0 8f 	movb   $0x8f,0xf02962bd
f010421d:	c1 e8 10             	shr    $0x10,%eax
f0104220:	66 a3 be 62 29 f0    	mov    %ax,0xf02962be
	SETGATE(idt[T_STACK]  , 1, GD_KT, (void*)H_STACK  ,0);  
f0104226:	b8 aa 49 10 f0       	mov    $0xf01049aa,%eax
f010422b:	66 a3 c0 62 29 f0    	mov    %ax,0xf02962c0
f0104231:	66 c7 05 c2 62 29 f0 	movw   $0x8,0xf02962c2
f0104238:	08 00 
f010423a:	c6 05 c4 62 29 f0 00 	movb   $0x0,0xf02962c4
f0104241:	c6 05 c5 62 29 f0 8f 	movb   $0x8f,0xf02962c5
f0104248:	c1 e8 10             	shr    $0x10,%eax
f010424b:	66 a3 c6 62 29 f0    	mov    %ax,0xf02962c6
	SETGATE(idt[T_GPFLT]  , 1, GD_KT, (void*)H_GPFLT  ,0);  
f0104251:	b8 ae 49 10 f0       	mov    $0xf01049ae,%eax
f0104256:	66 a3 c8 62 29 f0    	mov    %ax,0xf02962c8
f010425c:	66 c7 05 ca 62 29 f0 	movw   $0x8,0xf02962ca
f0104263:	08 00 
f0104265:	c6 05 cc 62 29 f0 00 	movb   $0x0,0xf02962cc
f010426c:	c6 05 cd 62 29 f0 8f 	movb   $0x8f,0xf02962cd
f0104273:	c1 e8 10             	shr    $0x10,%eax
f0104276:	66 a3 ce 62 29 f0    	mov    %ax,0xf02962ce
	SETGATE(idt[T_PGFLT]  , 1, GD_KT, (void*)H_PGFLT  ,0);  
f010427c:	b8 b2 49 10 f0       	mov    $0xf01049b2,%eax
f0104281:	66 a3 d0 62 29 f0    	mov    %ax,0xf02962d0
f0104287:	66 c7 05 d2 62 29 f0 	movw   $0x8,0xf02962d2
f010428e:	08 00 
f0104290:	c6 05 d4 62 29 f0 00 	movb   $0x0,0xf02962d4
f0104297:	c6 05 d5 62 29 f0 8f 	movb   $0x8f,0xf02962d5
f010429e:	c1 e8 10             	shr    $0x10,%eax
f01042a1:	66 a3 d6 62 29 f0    	mov    %ax,0xf02962d6
	SETGATE(idt[T_FPERR]  , 1, GD_KT, (void*)H_FPERR  ,0);  
f01042a7:	b8 b6 49 10 f0       	mov    $0xf01049b6,%eax
f01042ac:	66 a3 e0 62 29 f0    	mov    %ax,0xf02962e0
f01042b2:	66 c7 05 e2 62 29 f0 	movw   $0x8,0xf02962e2
f01042b9:	08 00 
f01042bb:	c6 05 e4 62 29 f0 00 	movb   $0x0,0xf02962e4
f01042c2:	c6 05 e5 62 29 f0 8f 	movb   $0x8f,0xf02962e5
f01042c9:	c1 e8 10             	shr    $0x10,%eax
f01042cc:	66 a3 e6 62 29 f0    	mov    %ax,0xf02962e6
	SETGATE(idt[T_ALIGN]  , 1, GD_KT, (void*)H_ALIGN  ,0);  
f01042d2:	b8 bc 49 10 f0       	mov    $0xf01049bc,%eax
f01042d7:	66 a3 e8 62 29 f0    	mov    %ax,0xf02962e8
f01042dd:	66 c7 05 ea 62 29 f0 	movw   $0x8,0xf02962ea
f01042e4:	08 00 
f01042e6:	c6 05 ec 62 29 f0 00 	movb   $0x0,0xf02962ec
f01042ed:	c6 05 ed 62 29 f0 8f 	movb   $0x8f,0xf02962ed
f01042f4:	c1 e8 10             	shr    $0x10,%eax
f01042f7:	66 a3 ee 62 29 f0    	mov    %ax,0xf02962ee
	SETGATE(idt[T_MCHK]   , 1, GD_KT, (void*)H_MCHK   ,0); 
f01042fd:	b8 c2 49 10 f0       	mov    $0xf01049c2,%eax
f0104302:	66 a3 f0 62 29 f0    	mov    %ax,0xf02962f0
f0104308:	66 c7 05 f2 62 29 f0 	movw   $0x8,0xf02962f2
f010430f:	08 00 
f0104311:	c6 05 f4 62 29 f0 00 	movb   $0x0,0xf02962f4
f0104318:	c6 05 f5 62 29 f0 8f 	movb   $0x8f,0xf02962f5
f010431f:	c1 e8 10             	shr    $0x10,%eax
f0104322:	66 a3 f6 62 29 f0    	mov    %ax,0xf02962f6
	SETGATE(idt[T_SIMDERR], 1, GD_KT, (void*)H_SIMDERR,0);  
f0104328:	b8 c8 49 10 f0       	mov    $0xf01049c8,%eax
f010432d:	66 a3 f8 62 29 f0    	mov    %ax,0xf02962f8
f0104333:	66 c7 05 fa 62 29 f0 	movw   $0x8,0xf02962fa
f010433a:	08 00 
f010433c:	c6 05 fc 62 29 f0 00 	movb   $0x0,0xf02962fc
f0104343:	c6 05 fd 62 29 f0 8f 	movb   $0x8f,0xf02962fd
f010434a:	c1 e8 10             	shr    $0x10,%eax
f010434d:	66 a3 fe 62 29 f0    	mov    %ax,0xf02962fe
	SETGATE(idt[T_SYSCALL], 1, GD_KT, (void*)H_SYSCALL,3);  // System call
f0104353:	b8 ce 49 10 f0       	mov    $0xf01049ce,%eax
f0104358:	66 a3 e0 63 29 f0    	mov    %ax,0xf02963e0
f010435e:	66 c7 05 e2 63 29 f0 	movw   $0x8,0xf02963e2
f0104365:	08 00 
f0104367:	c6 05 e4 63 29 f0 00 	movb   $0x0,0xf02963e4
f010436e:	c6 05 e5 63 29 f0 ef 	movb   $0xef,0xf02963e5
f0104375:	c1 e8 10             	shr    $0x10,%eax
f0104378:	66 a3 e6 63 29 f0    	mov    %ax,0xf02963e6
	trap_init_percpu();
f010437e:	e8 24 fc ff ff       	call   f0103fa7 <trap_init_percpu>
}
f0104383:	c9                   	leave  
f0104384:	c3                   	ret    

f0104385 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104385:	55                   	push   %ebp
f0104386:	89 e5                	mov    %esp,%ebp
f0104388:	53                   	push   %ebx
f0104389:	83 ec 0c             	sub    $0xc,%esp
f010438c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010438f:	ff 33                	pushl  (%ebx)
f0104391:	68 98 7e 10 f0       	push   $0xf0107e98
f0104396:	e8 f8 fb ff ff       	call   f0103f93 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010439b:	83 c4 08             	add    $0x8,%esp
f010439e:	ff 73 04             	pushl  0x4(%ebx)
f01043a1:	68 a7 7e 10 f0       	push   $0xf0107ea7
f01043a6:	e8 e8 fb ff ff       	call   f0103f93 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01043ab:	83 c4 08             	add    $0x8,%esp
f01043ae:	ff 73 08             	pushl  0x8(%ebx)
f01043b1:	68 b6 7e 10 f0       	push   $0xf0107eb6
f01043b6:	e8 d8 fb ff ff       	call   f0103f93 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01043bb:	83 c4 08             	add    $0x8,%esp
f01043be:	ff 73 0c             	pushl  0xc(%ebx)
f01043c1:	68 c5 7e 10 f0       	push   $0xf0107ec5
f01043c6:	e8 c8 fb ff ff       	call   f0103f93 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01043cb:	83 c4 08             	add    $0x8,%esp
f01043ce:	ff 73 10             	pushl  0x10(%ebx)
f01043d1:	68 d4 7e 10 f0       	push   $0xf0107ed4
f01043d6:	e8 b8 fb ff ff       	call   f0103f93 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01043db:	83 c4 08             	add    $0x8,%esp
f01043de:	ff 73 14             	pushl  0x14(%ebx)
f01043e1:	68 e3 7e 10 f0       	push   $0xf0107ee3
f01043e6:	e8 a8 fb ff ff       	call   f0103f93 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01043eb:	83 c4 08             	add    $0x8,%esp
f01043ee:	ff 73 18             	pushl  0x18(%ebx)
f01043f1:	68 f2 7e 10 f0       	push   $0xf0107ef2
f01043f6:	e8 98 fb ff ff       	call   f0103f93 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01043fb:	83 c4 08             	add    $0x8,%esp
f01043fe:	ff 73 1c             	pushl  0x1c(%ebx)
f0104401:	68 01 7f 10 f0       	push   $0xf0107f01
f0104406:	e8 88 fb ff ff       	call   f0103f93 <cprintf>
}
f010440b:	83 c4 10             	add    $0x10,%esp
f010440e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104411:	c9                   	leave  
f0104412:	c3                   	ret    

f0104413 <print_trapframe>:
{
f0104413:	55                   	push   %ebp
f0104414:	89 e5                	mov    %esp,%ebp
f0104416:	53                   	push   %ebx
f0104417:	83 ec 04             	sub    $0x4,%esp
f010441a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f010441d:	e8 d8 1d 00 00       	call   f01061fa <cpunum>
f0104422:	83 ec 04             	sub    $0x4,%esp
f0104425:	50                   	push   %eax
f0104426:	53                   	push   %ebx
f0104427:	68 65 7f 10 f0       	push   $0xf0107f65
f010442c:	e8 62 fb ff ff       	call   f0103f93 <cprintf>
	print_regs(&tf->tf_regs);
f0104431:	89 1c 24             	mov    %ebx,(%esp)
f0104434:	e8 4c ff ff ff       	call   f0104385 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104439:	83 c4 08             	add    $0x8,%esp
f010443c:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104440:	50                   	push   %eax
f0104441:	68 83 7f 10 f0       	push   $0xf0107f83
f0104446:	e8 48 fb ff ff       	call   f0103f93 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010444b:	83 c4 08             	add    $0x8,%esp
f010444e:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0104452:	50                   	push   %eax
f0104453:	68 96 7f 10 f0       	push   $0xf0107f96
f0104458:	e8 36 fb ff ff       	call   f0103f93 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010445d:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0104460:	83 c4 10             	add    $0x10,%esp
f0104463:	83 f8 13             	cmp    $0x13,%eax
f0104466:	76 1c                	jbe    f0104484 <print_trapframe+0x71>
	if (trapno == T_SYSCALL)
f0104468:	83 f8 30             	cmp    $0x30,%eax
f010446b:	0f 84 cf 00 00 00    	je     f0104540 <print_trapframe+0x12d>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104471:	8d 50 e0             	lea    -0x20(%eax),%edx
f0104474:	83 fa 0f             	cmp    $0xf,%edx
f0104477:	0f 86 cd 00 00 00    	jbe    f010454a <print_trapframe+0x137>
	return "(unknown trap)";
f010447d:	ba 2f 7f 10 f0       	mov    $0xf0107f2f,%edx
f0104482:	eb 07                	jmp    f010448b <print_trapframe+0x78>
		return excnames[trapno];
f0104484:	8b 14 85 80 82 10 f0 	mov    -0xfef7d80(,%eax,4),%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010448b:	83 ec 04             	sub    $0x4,%esp
f010448e:	52                   	push   %edx
f010448f:	50                   	push   %eax
f0104490:	68 a9 7f 10 f0       	push   $0xf0107fa9
f0104495:	e8 f9 fa ff ff       	call   f0103f93 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010449a:	83 c4 10             	add    $0x10,%esp
f010449d:	39 1d 60 6a 29 f0    	cmp    %ebx,0xf0296a60
f01044a3:	0f 84 ab 00 00 00    	je     f0104554 <print_trapframe+0x141>
	cprintf("  err  0x%08x", tf->tf_err);
f01044a9:	83 ec 08             	sub    $0x8,%esp
f01044ac:	ff 73 2c             	pushl  0x2c(%ebx)
f01044af:	68 ca 7f 10 f0       	push   $0xf0107fca
f01044b4:	e8 da fa ff ff       	call   f0103f93 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f01044b9:	83 c4 10             	add    $0x10,%esp
f01044bc:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01044c0:	0f 85 cf 00 00 00    	jne    f0104595 <print_trapframe+0x182>
			tf->tf_err & 1 ? "protection" : "not-present");
f01044c6:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f01044c9:	a8 01                	test   $0x1,%al
f01044cb:	0f 85 a6 00 00 00    	jne    f0104577 <print_trapframe+0x164>
f01044d1:	b9 49 7f 10 f0       	mov    $0xf0107f49,%ecx
f01044d6:	a8 02                	test   $0x2,%al
f01044d8:	0f 85 a3 00 00 00    	jne    f0104581 <print_trapframe+0x16e>
f01044de:	ba 5b 7f 10 f0       	mov    $0xf0107f5b,%edx
f01044e3:	a8 04                	test   $0x4,%al
f01044e5:	0f 85 a0 00 00 00    	jne    f010458b <print_trapframe+0x178>
f01044eb:	b8 95 80 10 f0       	mov    $0xf0108095,%eax
f01044f0:	51                   	push   %ecx
f01044f1:	52                   	push   %edx
f01044f2:	50                   	push   %eax
f01044f3:	68 d8 7f 10 f0       	push   $0xf0107fd8
f01044f8:	e8 96 fa ff ff       	call   f0103f93 <cprintf>
f01044fd:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104500:	83 ec 08             	sub    $0x8,%esp
f0104503:	ff 73 30             	pushl  0x30(%ebx)
f0104506:	68 e7 7f 10 f0       	push   $0xf0107fe7
f010450b:	e8 83 fa ff ff       	call   f0103f93 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104510:	83 c4 08             	add    $0x8,%esp
f0104513:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104517:	50                   	push   %eax
f0104518:	68 f6 7f 10 f0       	push   $0xf0107ff6
f010451d:	e8 71 fa ff ff       	call   f0103f93 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104522:	83 c4 08             	add    $0x8,%esp
f0104525:	ff 73 38             	pushl  0x38(%ebx)
f0104528:	68 09 80 10 f0       	push   $0xf0108009
f010452d:	e8 61 fa ff ff       	call   f0103f93 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104532:	83 c4 10             	add    $0x10,%esp
f0104535:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104539:	75 6f                	jne    f01045aa <print_trapframe+0x197>
}
f010453b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010453e:	c9                   	leave  
f010453f:	c3                   	ret    
		return "System call";
f0104540:	ba 10 7f 10 f0       	mov    $0xf0107f10,%edx
f0104545:	e9 41 ff ff ff       	jmp    f010448b <print_trapframe+0x78>
		return "Hardware Interrupt";
f010454a:	ba 1c 7f 10 f0       	mov    $0xf0107f1c,%edx
f010454f:	e9 37 ff ff ff       	jmp    f010448b <print_trapframe+0x78>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104554:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104558:	0f 85 4b ff ff ff    	jne    f01044a9 <print_trapframe+0x96>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010455e:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104561:	83 ec 08             	sub    $0x8,%esp
f0104564:	50                   	push   %eax
f0104565:	68 bb 7f 10 f0       	push   $0xf0107fbb
f010456a:	e8 24 fa ff ff       	call   f0103f93 <cprintf>
f010456f:	83 c4 10             	add    $0x10,%esp
f0104572:	e9 32 ff ff ff       	jmp    f01044a9 <print_trapframe+0x96>
		cprintf(" [%s, %s, %s]\n",
f0104577:	b9 3e 7f 10 f0       	mov    $0xf0107f3e,%ecx
f010457c:	e9 55 ff ff ff       	jmp    f01044d6 <print_trapframe+0xc3>
f0104581:	ba 55 7f 10 f0       	mov    $0xf0107f55,%edx
f0104586:	e9 58 ff ff ff       	jmp    f01044e3 <print_trapframe+0xd0>
f010458b:	b8 60 7f 10 f0       	mov    $0xf0107f60,%eax
f0104590:	e9 5b ff ff ff       	jmp    f01044f0 <print_trapframe+0xdd>
		cprintf("\n");
f0104595:	83 ec 0c             	sub    $0xc,%esp
f0104598:	68 db 6c 10 f0       	push   $0xf0106cdb
f010459d:	e8 f1 f9 ff ff       	call   f0103f93 <cprintf>
f01045a2:	83 c4 10             	add    $0x10,%esp
f01045a5:	e9 56 ff ff ff       	jmp    f0104500 <print_trapframe+0xed>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01045aa:	83 ec 08             	sub    $0x8,%esp
f01045ad:	ff 73 3c             	pushl  0x3c(%ebx)
f01045b0:	68 18 80 10 f0       	push   $0xf0108018
f01045b5:	e8 d9 f9 ff ff       	call   f0103f93 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01045ba:	83 c4 08             	add    $0x8,%esp
f01045bd:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01045c1:	50                   	push   %eax
f01045c2:	68 27 80 10 f0       	push   $0xf0108027
f01045c7:	e8 c7 f9 ff ff       	call   f0103f93 <cprintf>
f01045cc:	83 c4 10             	add    $0x10,%esp
}
f01045cf:	e9 67 ff ff ff       	jmp    f010453b <print_trapframe+0x128>

f01045d4 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01045d4:	55                   	push   %ebp
f01045d5:	89 e5                	mov    %esp,%ebp
f01045d7:	57                   	push   %edi
f01045d8:	56                   	push   %esi
f01045d9:	53                   	push   %ebx
f01045da:	83 ec 1c             	sub    $0x1c,%esp
f01045dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01045e0:	0f 20 d0             	mov    %cr2,%eax
f01045e3:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	uint16_t cs = tf->tf_cs;
	if ((cs & 0xFF) == GD_KT) { // code segment descriptor is kernel
f01045e6:	80 7b 34 08          	cmpb   $0x8,0x34(%ebx)
f01045ea:	0f 84 c0 00 00 00    	je     f01046b0 <page_fault_handler+0xdc>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').


	if (!curenv->env_pgfault_upcall) {
f01045f0:	e8 05 1c 00 00       	call   f01061fa <cpunum>
f01045f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01045f8:	8b 80 28 70 29 f0    	mov    -0xfd68fd8(%eax),%eax
f01045fe:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104602:	0f 84 c8 00 00 00    	je     f01046d0 <page_fault_handler+0xfc>
		print_trapframe(tf);
		env_destroy(curenv);
	}

	// Backup the current stack pointer.
	uintptr_t esp = tf->tf_esp;
f0104608:	8b 7b 3c             	mov    0x3c(%ebx),%edi
f010460b:	89 7d e0             	mov    %edi,-0x20(%ebp)
	
	// Get stack point to the right place.
	// Then, check whether the user can write memory there.
	// If not, curenv will be destroyed, and things are simpler.
	if (tf->tf_esp < UXSTACKTOP && tf->tf_esp >= UXSTACKTOP - PGSIZE) {
f010460e:	8d 87 00 10 40 11    	lea    0x11401000(%edi),%eax
f0104614:	3d ff 0f 00 00       	cmp    $0xfff,%eax
f0104619:	0f 87 f9 00 00 00    	ja     f0104718 <page_fault_handler+0x144>
		tf->tf_esp -= 4 + sizeof(struct UTrapframe);
f010461f:	8d 77 c8             	lea    -0x38(%edi),%esi
f0104622:	89 73 3c             	mov    %esi,0x3c(%ebx)
		user_mem_assert(curenv, (void*)tf->tf_esp, 4 + sizeof(struct UTrapframe), PTE_W | PTE_U);
f0104625:	e8 d0 1b 00 00       	call   f01061fa <cpunum>
f010462a:	6a 06                	push   $0x6
f010462c:	6a 38                	push   $0x38
f010462e:	56                   	push   %esi
f010462f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104632:	ff b0 28 70 29 f0    	pushl  -0xfd68fd8(%eax)
f0104638:	e8 85 ee ff ff       	call   f01034c2 <user_mem_assert>
		// FIXME
		*((uint32_t*)esp - 1) = 0;  // We also set the int padding to 0.
f010463d:	c7 47 fc 00 00 00 00 	movl   $0x0,-0x4(%edi)
f0104644:	83 c4 10             	add    $0x10,%esp
		tf->tf_esp = UXSTACKTOP - sizeof(struct UTrapframe);
		user_mem_assert(curenv, (void*)tf->tf_esp, sizeof(struct UTrapframe), PTE_W | PTE_U);
	}

	// Fill in UTrapframe data
	struct UTrapframe* utf = (struct UTrapframe*)tf->tf_esp;
f0104647:	8b 43 3c             	mov    0x3c(%ebx),%eax
	utf->utf_fault_va = fault_va;
f010464a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010464d:	89 08                	mov    %ecx,(%eax)
	utf->utf_err = tf->tf_err;
f010464f:	8b 53 2c             	mov    0x2c(%ebx),%edx
f0104652:	89 50 04             	mov    %edx,0x4(%eax)
	utf->utf_regs = tf->tf_regs;
f0104655:	8d 78 08             	lea    0x8(%eax),%edi
f0104658:	b9 08 00 00 00       	mov    $0x8,%ecx
f010465d:	89 de                	mov    %ebx,%esi
f010465f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	utf->utf_eip = tf->tf_eip;
f0104661:	8b 53 30             	mov    0x30(%ebx),%edx
f0104664:	89 50 28             	mov    %edx,0x28(%eax)
	utf->utf_eflags = tf->tf_eflags;
f0104667:	8b 53 38             	mov    0x38(%ebx),%edx
f010466a:	89 50 2c             	mov    %edx,0x2c(%eax)
	utf->utf_esp = esp;
f010466d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104670:	89 70 30             	mov    %esi,0x30(%eax)

	cprintf("We came from text addr %x, the fault addr was %x.\n", tf->tf_eip, fault_va);
f0104673:	83 ec 04             	sub    $0x4,%esp
f0104676:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104679:	ff 73 30             	pushl  0x30(%ebx)
f010467c:	68 30 82 10 f0       	push   $0xf0108230
f0104681:	e8 0d f9 ff ff       	call   f0103f93 <cprintf>
	// Modify trapframe so that upcall is triggered next.
	tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0104686:	e8 6f 1b 00 00       	call   f01061fa <cpunum>
f010468b:	6b c0 74             	imul   $0x74,%eax,%eax
f010468e:	8b 80 28 70 29 f0    	mov    -0xfd68fd8(%eax),%eax
f0104694:	8b 40 64             	mov    0x64(%eax),%eax
f0104697:	89 43 30             	mov    %eax,0x30(%ebx)

	// and then run the upcall.
	env_run(curenv);
f010469a:	e8 5b 1b 00 00       	call   f01061fa <cpunum>
f010469f:	83 c4 04             	add    $0x4,%esp
f01046a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01046a5:	ff b0 28 70 29 f0    	pushl  -0xfd68fd8(%eax)
f01046ab:	e8 64 f6 ff ff       	call   f0103d14 <env_run>
		print_trapframe(tf);
f01046b0:	83 ec 0c             	sub    $0xc,%esp
f01046b3:	53                   	push   %ebx
f01046b4:	e8 5a fd ff ff       	call   f0104413 <print_trapframe>
		panic("Page fault in kernel mode! Fault addr: %p", fault_va);
f01046b9:	ff 75 e4             	pushl  -0x1c(%ebp)
f01046bc:	68 e0 81 10 f0       	push   $0xf01081e0
f01046c1:	68 3f 01 00 00       	push   $0x13f
f01046c6:	68 3a 80 10 f0       	push   $0xf010803a
f01046cb:	e8 c4 b9 ff ff       	call   f0100094 <_panic>
		cprintf("[%08x] user fault va %08x ip %08x\n",
f01046d0:	8b 73 30             	mov    0x30(%ebx),%esi
				curenv->env_id, fault_va, tf->tf_eip);
f01046d3:	e8 22 1b 00 00       	call   f01061fa <cpunum>
		cprintf("[%08x] user fault va %08x ip %08x\n",
f01046d8:	56                   	push   %esi
f01046d9:	ff 75 e4             	pushl  -0x1c(%ebp)
				curenv->env_id, fault_va, tf->tf_eip);
f01046dc:	6b c0 74             	imul   $0x74,%eax,%eax
		cprintf("[%08x] user fault va %08x ip %08x\n",
f01046df:	8b 80 28 70 29 f0    	mov    -0xfd68fd8(%eax),%eax
f01046e5:	ff 70 48             	pushl  0x48(%eax)
f01046e8:	68 0c 82 10 f0       	push   $0xf010820c
f01046ed:	e8 a1 f8 ff ff       	call   f0103f93 <cprintf>
		print_trapframe(tf);
f01046f2:	89 1c 24             	mov    %ebx,(%esp)
f01046f5:	e8 19 fd ff ff       	call   f0104413 <print_trapframe>
		env_destroy(curenv);
f01046fa:	e8 fb 1a 00 00       	call   f01061fa <cpunum>
f01046ff:	83 c4 04             	add    $0x4,%esp
f0104702:	6b c0 74             	imul   $0x74,%eax,%eax
f0104705:	ff b0 28 70 29 f0    	pushl  -0xfd68fd8(%eax)
f010470b:	e8 47 f5 ff ff       	call   f0103c57 <env_destroy>
f0104710:	83 c4 10             	add    $0x10,%esp
f0104713:	e9 f0 fe ff ff       	jmp    f0104608 <page_fault_handler+0x34>
		tf->tf_esp = UXSTACKTOP - sizeof(struct UTrapframe);
f0104718:	c7 43 3c cc ff bf ee 	movl   $0xeebfffcc,0x3c(%ebx)
		user_mem_assert(curenv, (void*)tf->tf_esp, sizeof(struct UTrapframe), PTE_W | PTE_U);
f010471f:	e8 d6 1a 00 00       	call   f01061fa <cpunum>
f0104724:	6a 06                	push   $0x6
f0104726:	6a 34                	push   $0x34
f0104728:	68 cc ff bf ee       	push   $0xeebfffcc
f010472d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104730:	ff b0 28 70 29 f0    	pushl  -0xfd68fd8(%eax)
f0104736:	e8 87 ed ff ff       	call   f01034c2 <user_mem_assert>
f010473b:	83 c4 10             	add    $0x10,%esp
f010473e:	e9 04 ff ff ff       	jmp    f0104647 <page_fault_handler+0x73>

f0104743 <trap>:
{
f0104743:	55                   	push   %ebp
f0104744:	89 e5                	mov    %esp,%ebp
f0104746:	57                   	push   %edi
f0104747:	56                   	push   %esi
f0104748:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f010474b:	fc                   	cld    
	if (panicstr)
f010474c:	83 3d 80 6e 29 f0 00 	cmpl   $0x0,0xf0296e80
f0104753:	74 01                	je     f0104756 <trap+0x13>
		asm volatile("hlt");
f0104755:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104756:	e8 9f 1a 00 00       	call   f01061fa <cpunum>
f010475b:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010475e:	01 c2                	add    %eax,%edx
f0104760:	01 d2                	add    %edx,%edx
f0104762:	01 c2                	add    %eax,%edx
f0104764:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104767:	8d 14 85 04 00 00 00 	lea    0x4(,%eax,4),%edx
	asm volatile("lock; xchgl %0, %1"
f010476e:	b8 01 00 00 00       	mov    $0x1,%eax
f0104773:	f0 87 82 20 70 29 f0 	lock xchg %eax,-0xfd68fe0(%edx)
f010477a:	83 f8 02             	cmp    $0x2,%eax
f010477d:	74 53                	je     f01047d2 <trap+0x8f>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f010477f:	9c                   	pushf  
f0104780:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f0104781:	f6 c4 02             	test   $0x2,%ah
f0104784:	75 5e                	jne    f01047e4 <trap+0xa1>
	if ((tf->tf_cs & 3) == 3) {
f0104786:	66 8b 46 34          	mov    0x34(%esi),%ax
f010478a:	83 e0 03             	and    $0x3,%eax
f010478d:	66 83 f8 03          	cmp    $0x3,%ax
f0104791:	74 6a                	je     f01047fd <trap+0xba>
	last_tf = tf;
f0104793:	89 35 60 6a 29 f0    	mov    %esi,0xf0296a60
	switch(tf->tf_trapno){
f0104799:	8b 46 28             	mov    0x28(%esi),%eax
f010479c:	83 f8 0e             	cmp    $0xe,%eax
f010479f:	0f 84 fd 00 00 00    	je     f01048a2 <trap+0x15f>
f01047a5:	83 f8 30             	cmp    $0x30,%eax
f01047a8:	0f 84 fd 00 00 00    	je     f01048ab <trap+0x168>
f01047ae:	83 f8 03             	cmp    $0x3,%eax
f01047b1:	0f 85 3d 01 00 00    	jne    f01048f4 <trap+0x1b1>
		print_trapframe(tf);
f01047b7:	83 ec 0c             	sub    $0xc,%esp
f01047ba:	56                   	push   %esi
f01047bb:	e8 53 fc ff ff       	call   f0104413 <print_trapframe>
f01047c0:	83 c4 10             	add    $0x10,%esp
			monitor(NULL);
f01047c3:	83 ec 0c             	sub    $0xc,%esp
f01047c6:	6a 00                	push   $0x0
f01047c8:	e8 37 c6 ff ff       	call   f0100e04 <monitor>
f01047cd:	83 c4 10             	add    $0x10,%esp
f01047d0:	eb f1                	jmp    f01047c3 <trap+0x80>
	spin_lock(&kernel_lock);
f01047d2:	83 ec 0c             	sub    $0xc,%esp
f01047d5:	68 c0 23 12 f0       	push   $0xf01223c0
f01047da:	e8 8f 1c 00 00       	call   f010646e <spin_lock>
f01047df:	83 c4 10             	add    $0x10,%esp
f01047e2:	eb 9b                	jmp    f010477f <trap+0x3c>
	assert(!(read_eflags() & FL_IF));
f01047e4:	68 46 80 10 f0       	push   $0xf0108046
f01047e9:	68 83 7a 10 f0       	push   $0xf0107a83
f01047ee:	68 0b 01 00 00       	push   $0x10b
f01047f3:	68 3a 80 10 f0       	push   $0xf010803a
f01047f8:	e8 97 b8 ff ff       	call   f0100094 <_panic>
f01047fd:	83 ec 0c             	sub    $0xc,%esp
f0104800:	68 c0 23 12 f0       	push   $0xf01223c0
f0104805:	e8 64 1c 00 00       	call   f010646e <spin_lock>
		assert(curenv);
f010480a:	e8 eb 19 00 00       	call   f01061fa <cpunum>
f010480f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104812:	83 c4 10             	add    $0x10,%esp
f0104815:	83 b8 28 70 29 f0 00 	cmpl   $0x0,-0xfd68fd8(%eax)
f010481c:	74 3e                	je     f010485c <trap+0x119>
		if (curenv->env_status == ENV_DYING) {
f010481e:	e8 d7 19 00 00       	call   f01061fa <cpunum>
f0104823:	6b c0 74             	imul   $0x74,%eax,%eax
f0104826:	8b 80 28 70 29 f0    	mov    -0xfd68fd8(%eax),%eax
f010482c:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104830:	74 43                	je     f0104875 <trap+0x132>
		curenv->env_tf = *tf;
f0104832:	e8 c3 19 00 00       	call   f01061fa <cpunum>
f0104837:	6b c0 74             	imul   $0x74,%eax,%eax
f010483a:	8b 80 28 70 29 f0    	mov    -0xfd68fd8(%eax),%eax
f0104840:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104845:	89 c7                	mov    %eax,%edi
f0104847:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0104849:	e8 ac 19 00 00       	call   f01061fa <cpunum>
f010484e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104851:	8b b0 28 70 29 f0    	mov    -0xfd68fd8(%eax),%esi
f0104857:	e9 37 ff ff ff       	jmp    f0104793 <trap+0x50>
		assert(curenv);
f010485c:	68 5f 80 10 f0       	push   $0xf010805f
f0104861:	68 83 7a 10 f0       	push   $0xf0107a83
f0104866:	68 12 01 00 00       	push   $0x112
f010486b:	68 3a 80 10 f0       	push   $0xf010803a
f0104870:	e8 1f b8 ff ff       	call   f0100094 <_panic>
			env_free(curenv);
f0104875:	e8 80 19 00 00       	call   f01061fa <cpunum>
f010487a:	83 ec 0c             	sub    $0xc,%esp
f010487d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104880:	ff b0 28 70 29 f0    	pushl  -0xfd68fd8(%eax)
f0104886:	e8 be f1 ff ff       	call   f0103a49 <env_free>
			curenv = NULL;
f010488b:	e8 6a 19 00 00       	call   f01061fa <cpunum>
f0104890:	6b c0 74             	imul   $0x74,%eax,%eax
f0104893:	c7 80 28 70 29 f0 00 	movl   $0x0,-0xfd68fd8(%eax)
f010489a:	00 00 00 
			sched_yield();
f010489d:	e8 31 02 00 00       	call   f0104ad3 <sched_yield>
		page_fault_handler(tf);
f01048a2:	83 ec 0c             	sub    $0xc,%esp
f01048a5:	56                   	push   %esi
f01048a6:	e8 29 fd ff ff       	call   f01045d4 <page_fault_handler>
		tf->tf_regs.reg_eax = syscall(
f01048ab:	83 ec 08             	sub    $0x8,%esp
f01048ae:	ff 76 04             	pushl  0x4(%esi)
f01048b1:	ff 36                	pushl  (%esi)
f01048b3:	ff 76 10             	pushl  0x10(%esi)
f01048b6:	ff 76 18             	pushl  0x18(%esi)
f01048b9:	ff 76 14             	pushl  0x14(%esi)
f01048bc:	ff 76 1c             	pushl  0x1c(%esi)
f01048bf:	e8 ff 02 00 00       	call   f0104bc3 <syscall>
f01048c4:	89 46 1c             	mov    %eax,0x1c(%esi)
f01048c7:	83 c4 20             	add    $0x20,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f01048ca:	e8 2b 19 00 00       	call   f01061fa <cpunum>
f01048cf:	6b c0 74             	imul   $0x74,%eax,%eax
f01048d2:	83 b8 28 70 29 f0 00 	cmpl   $0x0,-0xfd68fd8(%eax)
f01048d9:	74 14                	je     f01048ef <trap+0x1ac>
f01048db:	e8 1a 19 00 00       	call   f01061fa <cpunum>
f01048e0:	6b c0 74             	imul   $0x74,%eax,%eax
f01048e3:	8b 80 28 70 29 f0    	mov    -0xfd68fd8(%eax),%eax
f01048e9:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01048ed:	74 69                	je     f0104958 <trap+0x215>
		sched_yield();
f01048ef:	e8 df 01 00 00       	call   f0104ad3 <sched_yield>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01048f4:	83 f8 27             	cmp    $0x27,%eax
f01048f7:	74 2e                	je     f0104927 <trap+0x1e4>
	print_trapframe(tf);
f01048f9:	83 ec 0c             	sub    $0xc,%esp
f01048fc:	56                   	push   %esi
f01048fd:	e8 11 fb ff ff       	call   f0104413 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104902:	83 c4 10             	add    $0x10,%esp
f0104905:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010490a:	74 35                	je     f0104941 <trap+0x1fe>
		env_destroy(curenv);
f010490c:	e8 e9 18 00 00       	call   f01061fa <cpunum>
f0104911:	83 ec 0c             	sub    $0xc,%esp
f0104914:	6b c0 74             	imul   $0x74,%eax,%eax
f0104917:	ff b0 28 70 29 f0    	pushl  -0xfd68fd8(%eax)
f010491d:	e8 35 f3 ff ff       	call   f0103c57 <env_destroy>
f0104922:	83 c4 10             	add    $0x10,%esp
f0104925:	eb a3                	jmp    f01048ca <trap+0x187>
		cprintf("Spurious interrupt on irq 7\n");
f0104927:	83 ec 0c             	sub    $0xc,%esp
f010492a:	68 66 80 10 f0       	push   $0xf0108066
f010492f:	e8 5f f6 ff ff       	call   f0103f93 <cprintf>
		print_trapframe(tf);
f0104934:	89 34 24             	mov    %esi,(%esp)
f0104937:	e8 d7 fa ff ff       	call   f0104413 <print_trapframe>
f010493c:	83 c4 10             	add    $0x10,%esp
f010493f:	eb 89                	jmp    f01048ca <trap+0x187>
		panic("unhandled trap in kernel");
f0104941:	83 ec 04             	sub    $0x4,%esp
f0104944:	68 83 80 10 f0       	push   $0xf0108083
f0104949:	68 f1 00 00 00       	push   $0xf1
f010494e:	68 3a 80 10 f0       	push   $0xf010803a
f0104953:	e8 3c b7 ff ff       	call   f0100094 <_panic>
		env_run(curenv);
f0104958:	e8 9d 18 00 00       	call   f01061fa <cpunum>
f010495d:	83 ec 0c             	sub    $0xc,%esp
f0104960:	6b c0 74             	imul   $0x74,%eax,%eax
f0104963:	ff b0 28 70 29 f0    	pushl  -0xfd68fd8(%eax)
f0104969:	e8 a6 f3 ff ff       	call   f0103d14 <env_run>

f010496e <H_DIVIDE>:
	pushl $(num);							\
	jmp _alltraps

.text

TRAPHANDLER_NOEC(H_DIVIDE , T_DIVIDE)
f010496e:	6a 00                	push   $0x0
f0104970:	6a 00                	push   $0x0
f0104972:	eb 60                	jmp    f01049d4 <_alltraps>

f0104974 <H_DEBUG>:
TRAPHANDLER_NOEC(H_DEBUG  , T_DEBUG)
f0104974:	6a 00                	push   $0x0
f0104976:	6a 01                	push   $0x1
f0104978:	eb 5a                	jmp    f01049d4 <_alltraps>

f010497a <H_NMI>:
TRAPHANDLER_NOEC(H_NMI    , T_NMI)
f010497a:	6a 00                	push   $0x0
f010497c:	6a 02                	push   $0x2
f010497e:	eb 54                	jmp    f01049d4 <_alltraps>

f0104980 <H_BRKPT>:
TRAPHANDLER_NOEC(H_BRKPT  , T_BRKPT)
f0104980:	6a 00                	push   $0x0
f0104982:	6a 03                	push   $0x3
f0104984:	eb 4e                	jmp    f01049d4 <_alltraps>

f0104986 <H_OFLOW>:
TRAPHANDLER_NOEC(H_OFLOW  , T_OFLOW)
f0104986:	6a 00                	push   $0x0
f0104988:	6a 04                	push   $0x4
f010498a:	eb 48                	jmp    f01049d4 <_alltraps>

f010498c <H_BOUND>:
TRAPHANDLER_NOEC(H_BOUND  , T_BOUND)
f010498c:	6a 00                	push   $0x0
f010498e:	6a 05                	push   $0x5
f0104990:	eb 42                	jmp    f01049d4 <_alltraps>

f0104992 <H_ILLOP>:
TRAPHANDLER_NOEC(H_ILLOP  , T_ILLOP)
f0104992:	6a 00                	push   $0x0
f0104994:	6a 06                	push   $0x6
f0104996:	eb 3c                	jmp    f01049d4 <_alltraps>

f0104998 <H_DEVICE>:
TRAPHANDLER_NOEC(H_DEVICE , T_DEVICE)
f0104998:	6a 00                	push   $0x0
f010499a:	6a 07                	push   $0x7
f010499c:	eb 36                	jmp    f01049d4 <_alltraps>

f010499e <H_DBLFLT>:
TRAPHANDLER     (H_DBLFLT , T_DBLFLT)	// Error Code const 0
f010499e:	6a 08                	push   $0x8
f01049a0:	eb 32                	jmp    f01049d4 <_alltraps>

f01049a2 <H_TSS>:
TRAPHANDLER     (H_TSS    , T_TSS)
f01049a2:	6a 0a                	push   $0xa
f01049a4:	eb 2e                	jmp    f01049d4 <_alltraps>

f01049a6 <H_SEGNP>:
TRAPHANDLER     (H_SEGNP  , T_SEGNP)
f01049a6:	6a 0b                	push   $0xb
f01049a8:	eb 2a                	jmp    f01049d4 <_alltraps>

f01049aa <H_STACK>:
TRAPHANDLER     (H_STACK  , T_STACK)
f01049aa:	6a 0c                	push   $0xc
f01049ac:	eb 26                	jmp    f01049d4 <_alltraps>

f01049ae <H_GPFLT>:
TRAPHANDLER     (H_GPFLT  , T_GPFLT)
f01049ae:	6a 0d                	push   $0xd
f01049b0:	eb 22                	jmp    f01049d4 <_alltraps>

f01049b2 <H_PGFLT>:
TRAPHANDLER     (H_PGFLT  , T_PGFLT)
f01049b2:	6a 0e                	push   $0xe
f01049b4:	eb 1e                	jmp    f01049d4 <_alltraps>

f01049b6 <H_FPERR>:
TRAPHANDLER_NOEC(H_FPERR  , T_FPERR)
f01049b6:	6a 00                	push   $0x0
f01049b8:	6a 10                	push   $0x10
f01049ba:	eb 18                	jmp    f01049d4 <_alltraps>

f01049bc <H_ALIGN>:
TRAPHANDLER_NOEC(H_ALIGN  , T_ALIGN)
f01049bc:	6a 00                	push   $0x0
f01049be:	6a 11                	push   $0x11
f01049c0:	eb 12                	jmp    f01049d4 <_alltraps>

f01049c2 <H_MCHK>:
TRAPHANDLER_NOEC(H_MCHK   , T_MCHK)
f01049c2:	6a 00                	push   $0x0
f01049c4:	6a 12                	push   $0x12
f01049c6:	eb 0c                	jmp    f01049d4 <_alltraps>

f01049c8 <H_SIMDERR>:
TRAPHANDLER_NOEC(H_SIMDERR, T_SIMDERR)
f01049c8:	6a 00                	push   $0x0
f01049ca:	6a 13                	push   $0x13
f01049cc:	eb 06                	jmp    f01049d4 <_alltraps>

f01049ce <H_SYSCALL>:

TRAPHANDLER_NOEC(H_SYSCALL, T_SYSCALL)  // System call.
f01049ce:	6a 00                	push   $0x0
f01049d0:	6a 30                	push   $0x30
f01049d2:	eb 00                	jmp    f01049d4 <_alltraps>

f01049d4 <_alltraps>:

_alltraps:
/* Processor has pushed ss, esp, eflags, cs, eip, and [error] */
/* TRAPHANDLER did [error] and trapno */
	pushl  %ds;
f01049d4:	1e                   	push   %ds
	pushl  %es;
f01049d5:	06                   	push   %es
	pushal;
f01049d6:	60                   	pusha  
	movw   $GD_KD, %ax;
f01049d7:	66 b8 10 00          	mov    $0x10,%ax
	movw   %ax   , %ds;
f01049db:	8e d8                	mov    %eax,%ds
	movw   %ax   , %es;
f01049dd:	8e c0                	mov    %eax,%es
	pushl  %esp;
f01049df:	54                   	push   %esp
	call   trap
f01049e0:	e8 5e fd ff ff       	call   f0104743 <trap>

f01049e5 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01049e5:	55                   	push   %ebp
f01049e6:	89 e5                	mov    %esp,%ebp
f01049e8:	83 ec 08             	sub    $0x8,%esp
f01049eb:	a1 48 62 29 f0       	mov    0xf0296248,%eax
f01049f0:	83 c0 54             	add    $0x54,%eax
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01049f3:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f01049f8:	8b 10                	mov    (%eax),%edx
f01049fa:	4a                   	dec    %edx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01049fb:	83 fa 02             	cmp    $0x2,%edx
f01049fe:	76 2b                	jbe    f0104a2b <sched_halt+0x46>
	for (i = 0; i < NENV; i++) {
f0104a00:	41                   	inc    %ecx
f0104a01:	83 c0 7c             	add    $0x7c,%eax
f0104a04:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104a0a:	75 ec                	jne    f01049f8 <sched_halt+0x13>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f0104a0c:	83 ec 0c             	sub    $0xc,%esp
f0104a0f:	68 d0 82 10 f0       	push   $0xf01082d0
f0104a14:	e8 7a f5 ff ff       	call   f0103f93 <cprintf>
f0104a19:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104a1c:	83 ec 0c             	sub    $0xc,%esp
f0104a1f:	6a 00                	push   $0x0
f0104a21:	e8 de c3 ff ff       	call   f0100e04 <monitor>
f0104a26:	83 c4 10             	add    $0x10,%esp
f0104a29:	eb f1                	jmp    f0104a1c <sched_halt+0x37>
	if (i == NENV) {
f0104a2b:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104a31:	74 d9                	je     f0104a0c <sched_halt+0x27>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104a33:	e8 c2 17 00 00       	call   f01061fa <cpunum>
f0104a38:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104a3b:	01 c2                	add    %eax,%edx
f0104a3d:	01 d2                	add    %edx,%edx
f0104a3f:	01 c2                	add    %eax,%edx
f0104a41:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104a44:	c7 04 85 28 70 29 f0 	movl   $0x0,-0xfd68fd8(,%eax,4)
f0104a4b:	00 00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104a4f:	a1 8c 6e 29 f0       	mov    0xf0296e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0104a54:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104a59:	76 66                	jbe    f0104ac1 <sched_halt+0xdc>
	return (physaddr_t)kva - KERNBASE;
f0104a5b:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104a60:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104a63:	e8 92 17 00 00       	call   f01061fa <cpunum>
f0104a68:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104a6b:	01 c2                	add    %eax,%edx
f0104a6d:	01 d2                	add    %edx,%edx
f0104a6f:	01 c2                	add    %eax,%edx
f0104a71:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104a74:	8d 14 85 04 00 00 00 	lea    0x4(,%eax,4),%edx
	asm volatile("lock; xchgl %0, %1"
f0104a7b:	b8 02 00 00 00       	mov    $0x2,%eax
f0104a80:	f0 87 82 20 70 29 f0 	lock xchg %eax,-0xfd68fe0(%edx)
	spin_unlock(&kernel_lock);
f0104a87:	83 ec 0c             	sub    $0xc,%esp
f0104a8a:	68 c0 23 12 f0       	push   $0xf01223c0
f0104a8f:	e8 87 1a 00 00       	call   f010651b <spin_unlock>
	asm volatile("pause");
f0104a94:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104a96:	e8 5f 17 00 00       	call   f01061fa <cpunum>
f0104a9b:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104a9e:	01 c2                	add    %eax,%edx
f0104aa0:	01 d2                	add    %edx,%edx
f0104aa2:	01 c2                	add    %eax,%edx
f0104aa4:	8d 04 90             	lea    (%eax,%edx,4),%eax
	asm volatile (
f0104aa7:	8b 04 85 30 70 29 f0 	mov    -0xfd68fd0(,%eax,4),%eax
f0104aae:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104ab3:	89 c4                	mov    %eax,%esp
f0104ab5:	6a 00                	push   $0x0
f0104ab7:	6a 00                	push   $0x0
f0104ab9:	f4                   	hlt    
f0104aba:	eb fd                	jmp    f0104ab9 <sched_halt+0xd4>
}
f0104abc:	83 c4 10             	add    $0x10,%esp
f0104abf:	c9                   	leave  
f0104ac0:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104ac1:	50                   	push   %eax
f0104ac2:	68 ac 69 10 f0       	push   $0xf01069ac
f0104ac7:	6a 53                	push   $0x53
f0104ac9:	68 f9 82 10 f0       	push   $0xf01082f9
f0104ace:	e8 c1 b5 ff ff       	call   f0100094 <_panic>

f0104ad3 <sched_yield>:
{
f0104ad3:	55                   	push   %ebp
f0104ad4:	89 e5                	mov    %esp,%ebp
f0104ad6:	53                   	push   %ebx
f0104ad7:	83 ec 04             	sub    $0x4,%esp
	if (!curenv) { 
f0104ada:	e8 1b 17 00 00       	call   f01061fa <cpunum>
f0104adf:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104ae2:	01 c2                	add    %eax,%edx
f0104ae4:	01 d2                	add    %edx,%edx
f0104ae6:	01 c2                	add    %eax,%edx
f0104ae8:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104aeb:	83 3c 85 28 70 29 f0 	cmpl   $0x0,-0xfd68fd8(,%eax,4)
f0104af2:	00 
f0104af3:	74 29                	je     f0104b1e <sched_yield+0x4b>
		for (idle = curenv + 1; idle < envs + NENV; idle++)
f0104af5:	e8 00 17 00 00       	call   f01061fa <cpunum>
f0104afa:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104afd:	01 c2                	add    %eax,%edx
f0104aff:	01 d2                	add    %edx,%edx
f0104b01:	01 c2                	add    %eax,%edx
f0104b03:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104b06:	8b 04 85 28 70 29 f0 	mov    -0xfd68fd8(,%eax,4),%eax
f0104b0d:	83 c0 7c             	add    $0x7c,%eax
f0104b10:	8b 1d 48 62 29 f0    	mov    0xf0296248,%ebx
f0104b16:	8d 93 00 f0 01 00    	lea    0x1f000(%ebx),%edx
f0104b1c:	eb 26                	jmp    f0104b44 <sched_yield+0x71>
		for (idle = envs; idle < envs + NENV; idle++)
f0104b1e:	a1 48 62 29 f0       	mov    0xf0296248,%eax
f0104b23:	8d 90 00 f0 01 00    	lea    0x1f000(%eax),%edx
f0104b29:	39 d0                	cmp    %edx,%eax
f0104b2b:	74 76                	je     f0104ba3 <sched_yield+0xd0>
			if (idle->env_status == ENV_RUNNABLE)
f0104b2d:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104b31:	74 05                	je     f0104b38 <sched_yield+0x65>
		for (idle = envs; idle < envs + NENV; idle++)
f0104b33:	83 c0 7c             	add    $0x7c,%eax
f0104b36:	eb f1                	jmp    f0104b29 <sched_yield+0x56>
				env_run(idle); // Will not return
f0104b38:	83 ec 0c             	sub    $0xc,%esp
f0104b3b:	50                   	push   %eax
f0104b3c:	e8 d3 f1 ff ff       	call   f0103d14 <env_run>
		for (idle = curenv + 1; idle < envs + NENV; idle++)
f0104b41:	83 c0 7c             	add    $0x7c,%eax
f0104b44:	39 c2                	cmp    %eax,%edx
f0104b46:	76 18                	jbe    f0104b60 <sched_yield+0x8d>
			if (idle->env_status == ENV_RUNNABLE)
f0104b48:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104b4c:	75 f3                	jne    f0104b41 <sched_yield+0x6e>
				env_run(idle); 
f0104b4e:	83 ec 0c             	sub    $0xc,%esp
f0104b51:	50                   	push   %eax
f0104b52:	e8 bd f1 ff ff       	call   f0103d14 <env_run>
				env_run(idle);
f0104b57:	83 ec 0c             	sub    $0xc,%esp
f0104b5a:	53                   	push   %ebx
f0104b5b:	e8 b4 f1 ff ff       	call   f0103d14 <env_run>
		for (idle = envs; idle < curenv ; idle++)
f0104b60:	e8 95 16 00 00       	call   f01061fa <cpunum>
f0104b65:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104b68:	01 c2                	add    %eax,%edx
f0104b6a:	01 d2                	add    %edx,%edx
f0104b6c:	01 c2                	add    %eax,%edx
f0104b6e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104b71:	39 1c 85 28 70 29 f0 	cmp    %ebx,-0xfd68fd8(,%eax,4)
f0104b78:	76 0b                	jbe    f0104b85 <sched_yield+0xb2>
			if (idle->env_status == ENV_RUNNABLE)
f0104b7a:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f0104b7e:	74 d7                	je     f0104b57 <sched_yield+0x84>
		for (idle = envs; idle < curenv ; idle++)
f0104b80:	83 c3 7c             	add    $0x7c,%ebx
f0104b83:	eb db                	jmp    f0104b60 <sched_yield+0x8d>
		if (curenv->env_status == ENV_RUNNING)
f0104b85:	e8 70 16 00 00       	call   f01061fa <cpunum>
f0104b8a:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104b8d:	01 c2                	add    %eax,%edx
f0104b8f:	01 d2                	add    %edx,%edx
f0104b91:	01 c2                	add    %eax,%edx
f0104b93:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104b96:	8b 04 85 28 70 29 f0 	mov    -0xfd68fd8(,%eax,4),%eax
f0104b9d:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104ba1:	74 0a                	je     f0104bad <sched_yield+0xda>
	sched_halt();
f0104ba3:	e8 3d fe ff ff       	call   f01049e5 <sched_halt>
}
f0104ba8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104bab:	c9                   	leave  
f0104bac:	c3                   	ret    
			env_run(curenv);
f0104bad:	e8 48 16 00 00       	call   f01061fa <cpunum>
f0104bb2:	83 ec 0c             	sub    $0xc,%esp
f0104bb5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bb8:	ff b0 28 70 29 f0    	pushl  -0xfd68fd8(%eax)
f0104bbe:	e8 51 f1 ff ff       	call   f0103d14 <env_run>

f0104bc3 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104bc3:	55                   	push   %ebp
f0104bc4:	89 e5                	mov    %esp,%ebp
f0104bc6:	56                   	push   %esi
f0104bc7:	53                   	push   %ebx
f0104bc8:	83 ec 10             	sub    $0x10,%esp
f0104bcb:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	switch (syscallno) {
f0104bce:	83 f8 0a             	cmp    $0xa,%eax
f0104bd1:	0f 87 11 04 00 00    	ja     f0104fe8 <syscall+0x425>
f0104bd7:	ff 24 85 64 83 10 f0 	jmp    *-0xfef7c9c(,%eax,4)
	user_mem_assert(curenv, s, len, PTE_U);  // The memory is readable.
f0104bde:	e8 17 16 00 00       	call   f01061fa <cpunum>
f0104be3:	6a 04                	push   $0x4
f0104be5:	ff 75 10             	pushl  0x10(%ebp)
f0104be8:	ff 75 0c             	pushl  0xc(%ebp)
f0104beb:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104bee:	01 c2                	add    %eax,%edx
f0104bf0:	01 d2                	add    %edx,%edx
f0104bf2:	01 c2                	add    %eax,%edx
f0104bf4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104bf7:	ff 34 85 28 70 29 f0 	pushl  -0xfd68fd8(,%eax,4)
f0104bfe:	e8 bf e8 ff ff       	call   f01034c2 <user_mem_assert>
	cprintf("%.*s", len, s);
f0104c03:	83 c4 0c             	add    $0xc,%esp
f0104c06:	ff 75 0c             	pushl  0xc(%ebp)
f0104c09:	ff 75 10             	pushl  0x10(%ebp)
f0104c0c:	68 06 83 10 f0       	push   $0xf0108306
f0104c11:	e8 7d f3 ff ff       	call   f0103f93 <cprintf>
f0104c16:	83 c4 10             	add    $0x10,%esp
	case SYS_cputs:
		sys_cputs((const char*)a1, a2);
		return 0;
f0104c19:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();  // Should not return...
		return 0;
	default:
		return -E_INVAL;
	}
}
f0104c1e:	89 d8                	mov    %ebx,%eax
f0104c20:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104c23:	5b                   	pop    %ebx
f0104c24:	5e                   	pop    %esi
f0104c25:	5d                   	pop    %ebp
f0104c26:	c3                   	ret    
	return cons_getc();
f0104c27:	e8 92 ba ff ff       	call   f01006be <cons_getc>
f0104c2c:	89 c3                	mov    %eax,%ebx
		return sys_cgetc();
f0104c2e:	eb ee                	jmp    f0104c1e <syscall+0x5b>
	return curenv->env_id;
f0104c30:	e8 c5 15 00 00       	call   f01061fa <cpunum>
f0104c35:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104c38:	01 c2                	add    %eax,%edx
f0104c3a:	01 d2                	add    %edx,%edx
f0104c3c:	01 c2                	add    %eax,%edx
f0104c3e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104c41:	8b 04 85 28 70 29 f0 	mov    -0xfd68fd8(,%eax,4),%eax
f0104c48:	8b 58 48             	mov    0x48(%eax),%ebx
		return sys_getenvid();
f0104c4b:	eb d1                	jmp    f0104c1e <syscall+0x5b>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104c4d:	83 ec 04             	sub    $0x4,%esp
f0104c50:	6a 01                	push   $0x1
f0104c52:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104c55:	50                   	push   %eax
f0104c56:	ff 75 0c             	pushl  0xc(%ebp)
f0104c59:	e8 b0 e8 ff ff       	call   f010350e <envid2env>
f0104c5e:	89 c3                	mov    %eax,%ebx
f0104c60:	83 c4 10             	add    $0x10,%esp
f0104c63:	85 c0                	test   %eax,%eax
f0104c65:	78 b7                	js     f0104c1e <syscall+0x5b>
	if (e == curenv)
f0104c67:	e8 8e 15 00 00       	call   f01061fa <cpunum>
f0104c6c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
f0104c6f:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104c72:	01 c2                	add    %eax,%edx
f0104c74:	01 d2                	add    %edx,%edx
f0104c76:	01 c2                	add    %eax,%edx
f0104c78:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104c7b:	39 0c 85 28 70 29 f0 	cmp    %ecx,-0xfd68fd8(,%eax,4)
f0104c82:	74 47                	je     f0104ccb <syscall+0x108>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104c84:	8b 59 48             	mov    0x48(%ecx),%ebx
f0104c87:	e8 6e 15 00 00       	call   f01061fa <cpunum>
f0104c8c:	83 ec 04             	sub    $0x4,%esp
f0104c8f:	53                   	push   %ebx
f0104c90:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104c93:	01 c2                	add    %eax,%edx
f0104c95:	01 d2                	add    %edx,%edx
f0104c97:	01 c2                	add    %eax,%edx
f0104c99:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104c9c:	8b 04 85 28 70 29 f0 	mov    -0xfd68fd8(,%eax,4),%eax
f0104ca3:	ff 70 48             	pushl  0x48(%eax)
f0104ca6:	68 26 83 10 f0       	push   $0xf0108326
f0104cab:	e8 e3 f2 ff ff       	call   f0103f93 <cprintf>
f0104cb0:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104cb3:	83 ec 0c             	sub    $0xc,%esp
f0104cb6:	ff 75 f4             	pushl  -0xc(%ebp)
f0104cb9:	e8 99 ef ff ff       	call   f0103c57 <env_destroy>
f0104cbe:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104cc1:	bb 00 00 00 00       	mov    $0x0,%ebx
		return sys_env_destroy(a1);
f0104cc6:	e9 53 ff ff ff       	jmp    f0104c1e <syscall+0x5b>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104ccb:	e8 2a 15 00 00       	call   f01061fa <cpunum>
f0104cd0:	83 ec 08             	sub    $0x8,%esp
f0104cd3:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104cd6:	01 c2                	add    %eax,%edx
f0104cd8:	01 d2                	add    %edx,%edx
f0104cda:	01 c2                	add    %eax,%edx
f0104cdc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104cdf:	8b 04 85 28 70 29 f0 	mov    -0xfd68fd8(,%eax,4),%eax
f0104ce6:	ff 70 48             	pushl  0x48(%eax)
f0104ce9:	68 0b 83 10 f0       	push   $0xf010830b
f0104cee:	e8 a0 f2 ff ff       	call   f0103f93 <cprintf>
f0104cf3:	83 c4 10             	add    $0x10,%esp
f0104cf6:	eb bb                	jmp    f0104cb3 <syscall+0xf0>
	int r = envid2env(envid, &to_env, 1);  // 1 - Check perm
f0104cf8:	83 ec 04             	sub    $0x4,%esp
f0104cfb:	6a 01                	push   $0x1
f0104cfd:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104d00:	50                   	push   %eax
f0104d01:	ff 75 0c             	pushl  0xc(%ebp)
f0104d04:	e8 05 e8 ff ff       	call   f010350e <envid2env>
f0104d09:	89 c3                	mov    %eax,%ebx
	if (r)  // -E_BAD_ENV
f0104d0b:	83 c4 10             	add    $0x10,%esp
f0104d0e:	85 c0                	test   %eax,%eax
f0104d10:	0f 85 08 ff ff ff    	jne    f0104c1e <syscall+0x5b>
	if ((uintptr_t)va >= UTOP || (uintptr_t)va % PGSIZE) {
f0104d16:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104d1d:	77 59                	ja     f0104d78 <syscall+0x1b5>
f0104d1f:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104d26:	75 50                	jne    f0104d78 <syscall+0x1b5>
	if (~PTE_SYSCALL & perm) 
f0104d28:	f7 45 14 f8 f1 ff ff 	testl  $0xfffff1f8,0x14(%ebp)
f0104d2f:	75 63                	jne    f0104d94 <syscall+0x1d1>
	perm |= PTE_U | PTE_P;
f0104d31:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104d34:	83 cb 05             	or     $0x5,%ebx
	struct PageInfo* pp = page_alloc(1);
f0104d37:	83 ec 0c             	sub    $0xc,%esp
f0104d3a:	6a 01                	push   $0x1
f0104d3c:	e8 87 c6 ff ff       	call   f01013c8 <page_alloc>
f0104d41:	89 c6                	mov    %eax,%esi
	if (!pp)  // No free memory
f0104d43:	83 c4 10             	add    $0x10,%esp
f0104d46:	85 c0                	test   %eax,%eax
f0104d48:	74 54                	je     f0104d9e <syscall+0x1db>
	r = page_insert(to_env->env_pgdir, pp, va, perm);
f0104d4a:	53                   	push   %ebx
f0104d4b:	ff 75 10             	pushl  0x10(%ebp)
f0104d4e:	50                   	push   %eax
f0104d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104d52:	ff 70 60             	pushl  0x60(%eax)
f0104d55:	e8 c7 c9 ff ff       	call   f0101721 <page_insert>
f0104d5a:	89 c3                	mov    %eax,%ebx
	if (r)
f0104d5c:	83 c4 10             	add    $0x10,%esp
f0104d5f:	85 c0                	test   %eax,%eax
f0104d61:	0f 84 b7 fe ff ff    	je     f0104c1e <syscall+0x5b>
		page_free(pp);
f0104d67:	83 ec 0c             	sub    $0xc,%esp
f0104d6a:	56                   	push   %esi
f0104d6b:	e8 ca c6 ff ff       	call   f010143a <page_free>
f0104d70:	83 c4 10             	add    $0x10,%esp
f0104d73:	e9 a6 fe ff ff       	jmp    f0104c1e <syscall+0x5b>
		cprintf("2, -3\n", r);
f0104d78:	83 ec 08             	sub    $0x8,%esp
f0104d7b:	6a 00                	push   $0x0
f0104d7d:	68 3e 83 10 f0       	push   $0xf010833e
f0104d82:	e8 0c f2 ff ff       	call   f0103f93 <cprintf>
f0104d87:	83 c4 10             	add    $0x10,%esp
		return -E_INVAL;
f0104d8a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d8f:	e9 8a fe ff ff       	jmp    f0104c1e <syscall+0x5b>
		return -E_INVAL;
f0104d94:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d99:	e9 80 fe ff ff       	jmp    f0104c1e <syscall+0x5b>
		return -E_NO_MEM;
f0104d9e:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
		return sys_page_alloc(a1, (void*)a2, a3);
f0104da3:	e9 76 fe ff ff       	jmp    f0104c1e <syscall+0x5b>
	r = envid2env(srcenvid, &from_env, 1);  // 1 - Check perm
f0104da8:	83 ec 04             	sub    $0x4,%esp
f0104dab:	6a 01                	push   $0x1
f0104dad:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104db0:	50                   	push   %eax
f0104db1:	ff 75 0c             	pushl  0xc(%ebp)
f0104db4:	e8 55 e7 ff ff       	call   f010350e <envid2env>
f0104db9:	89 c3                	mov    %eax,%ebx
	if (r)  return r;
f0104dbb:	83 c4 10             	add    $0x10,%esp
f0104dbe:	85 c0                	test   %eax,%eax
f0104dc0:	0f 85 58 fe ff ff    	jne    f0104c1e <syscall+0x5b>
	r = envid2env(dstenvid, &to_env, 1);  // 1 - Check perm
f0104dc6:	83 ec 04             	sub    $0x4,%esp
f0104dc9:	6a 01                	push   $0x1
f0104dcb:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104dce:	50                   	push   %eax
f0104dcf:	ff 75 14             	pushl  0x14(%ebp)
f0104dd2:	e8 37 e7 ff ff       	call   f010350e <envid2env>
f0104dd7:	89 c3                	mov    %eax,%ebx
	if (r)  return r;
f0104dd9:	83 c4 10             	add    $0x10,%esp
f0104ddc:	85 c0                	test   %eax,%eax
f0104dde:	0f 85 3a fe ff ff    	jne    f0104c1e <syscall+0x5b>
	if (
f0104de4:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104deb:	0f 87 8e 00 00 00    	ja     f0104e7f <syscall+0x2bc>
		((uintptr_t)srcva >= UTOP || (uintptr_t)srcva % PGSIZE) || 
f0104df1:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104df8:	0f 85 8b 00 00 00    	jne    f0104e89 <syscall+0x2c6>
f0104dfe:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104e05:	0f 87 88 00 00 00    	ja     f0104e93 <syscall+0x2d0>
		((uintptr_t)dstva >= UTOP || (uintptr_t)dstva % PGSIZE))
f0104e0b:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104e12:	0f 85 85 00 00 00    	jne    f0104e9d <syscall+0x2da>
	cprintf("PTE_SYSCALL = %x, perm = %x!\n", PTE_SYSCALL, perm);
f0104e18:	83 ec 04             	sub    $0x4,%esp
f0104e1b:	ff 75 1c             	pushl  0x1c(%ebp)
f0104e1e:	68 07 0e 00 00       	push   $0xe07
f0104e23:	68 45 83 10 f0       	push   $0xf0108345
f0104e28:	e8 66 f1 ff ff       	call   f0103f93 <cprintf>
	if (~PTE_SYSCALL & perm)
f0104e2d:	83 c4 10             	add    $0x10,%esp
f0104e30:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f0104e37:	75 6e                	jne    f0104ea7 <syscall+0x2e4>
	perm |= PTE_U | PTE_P;
f0104e39:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
f0104e3c:	83 cb 05             	or     $0x5,%ebx
	struct PageInfo* pp = page_lookup(from_env->env_pgdir, srcva, &src_pgt);
f0104e3f:	83 ec 04             	sub    $0x4,%esp
f0104e42:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104e45:	50                   	push   %eax
f0104e46:	ff 75 10             	pushl  0x10(%ebp)
f0104e49:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104e4c:	ff 70 60             	pushl  0x60(%eax)
f0104e4f:	e8 c4 c7 ff ff       	call   f0101618 <page_lookup>
	if ((~*src_pgt & PTE_W) && (perm & PTE_W))
f0104e54:	83 c4 10             	add    $0x10,%esp
f0104e57:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104e5a:	f6 02 02             	testb  $0x2,(%edx)
f0104e5d:	75 06                	jne    f0104e65 <syscall+0x2a2>
f0104e5f:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104e63:	75 4c                	jne    f0104eb1 <syscall+0x2ee>
	r = page_insert(to_env->env_pgdir, pp, dstva, perm);
f0104e65:	53                   	push   %ebx
f0104e66:	ff 75 18             	pushl  0x18(%ebp)
f0104e69:	50                   	push   %eax
f0104e6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104e6d:	ff 70 60             	pushl  0x60(%eax)
f0104e70:	e8 ac c8 ff ff       	call   f0101721 <page_insert>
f0104e75:	89 c3                	mov    %eax,%ebx
f0104e77:	83 c4 10             	add    $0x10,%esp
f0104e7a:	e9 9f fd ff ff       	jmp    f0104c1e <syscall+0x5b>
		return -E_INVAL;
f0104e7f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104e84:	e9 95 fd ff ff       	jmp    f0104c1e <syscall+0x5b>
f0104e89:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104e8e:	e9 8b fd ff ff       	jmp    f0104c1e <syscall+0x5b>
f0104e93:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104e98:	e9 81 fd ff ff       	jmp    f0104c1e <syscall+0x5b>
f0104e9d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104ea2:	e9 77 fd ff ff       	jmp    f0104c1e <syscall+0x5b>
		return -E_INVAL;
f0104ea7:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104eac:	e9 6d fd ff ff       	jmp    f0104c1e <syscall+0x5b>
		return -E_INVAL;
f0104eb1:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
f0104eb6:	e9 63 fd ff ff       	jmp    f0104c1e <syscall+0x5b>
	int r = envid2env(envid, &to_env, 1);  // 1 - Check perm
f0104ebb:	83 ec 04             	sub    $0x4,%esp
f0104ebe:	6a 01                	push   $0x1
f0104ec0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104ec3:	50                   	push   %eax
f0104ec4:	ff 75 0c             	pushl  0xc(%ebp)
f0104ec7:	e8 42 e6 ff ff       	call   f010350e <envid2env>
	if (r)  // -E_BAD_ENV
f0104ecc:	83 c4 10             	add    $0x10,%esp
f0104ecf:	85 c0                	test   %eax,%eax
f0104ed1:	75 26                	jne    f0104ef9 <syscall+0x336>
	if ((uintptr_t)va >= UTOP || (uintptr_t)va % PGSIZE)
f0104ed3:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104eda:	77 1d                	ja     f0104ef9 <syscall+0x336>
f0104edc:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104ee3:	75 14                	jne    f0104ef9 <syscall+0x336>
	page_remove(to_env->env_pgdir, va);
f0104ee5:	83 ec 08             	sub    $0x8,%esp
f0104ee8:	ff 75 10             	pushl  0x10(%ebp)
f0104eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104eee:	ff 70 60             	pushl  0x60(%eax)
f0104ef1:	e8 d1 c7 ff ff       	call   f01016c7 <page_remove>
f0104ef6:	83 c4 10             	add    $0x10,%esp
		return 0;
f0104ef9:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104efe:	e9 1b fd ff ff       	jmp    f0104c1e <syscall+0x5b>
	int r = env_alloc(&newenv, curenv->env_id);
f0104f03:	e8 f2 12 00 00       	call   f01061fa <cpunum>
f0104f08:	83 ec 08             	sub    $0x8,%esp
f0104f0b:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104f0e:	01 c2                	add    %eax,%edx
f0104f10:	01 d2                	add    %edx,%edx
f0104f12:	01 c2                	add    %eax,%edx
f0104f14:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104f17:	8b 04 85 28 70 29 f0 	mov    -0xfd68fd8(,%eax,4),%eax
f0104f1e:	ff 70 48             	pushl  0x48(%eax)
f0104f21:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104f24:	50                   	push   %eax
f0104f25:	e8 12 e7 ff ff       	call   f010363c <env_alloc>
f0104f2a:	89 c3                	mov    %eax,%ebx
	if (r)  // Some error
f0104f2c:	83 c4 10             	add    $0x10,%esp
f0104f2f:	85 c0                	test   %eax,%eax
f0104f31:	0f 85 e7 fc ff ff    	jne    f0104c1e <syscall+0x5b>
	newenv->env_status = ENV_NOT_RUNNABLE;
f0104f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104f3a:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	memcpy(&newenv->env_tf, &curenv->env_tf, sizeof(struct Trapframe));
f0104f41:	e8 b4 12 00 00       	call   f01061fa <cpunum>
f0104f46:	83 ec 04             	sub    $0x4,%esp
f0104f49:	6a 44                	push   $0x44
f0104f4b:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104f4e:	01 c2                	add    %eax,%edx
f0104f50:	01 d2                	add    %edx,%edx
f0104f52:	01 c2                	add    %eax,%edx
f0104f54:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104f57:	ff 34 85 28 70 29 f0 	pushl  -0xfd68fd8(,%eax,4)
f0104f5e:	ff 75 f4             	pushl  -0xc(%ebp)
f0104f61:	e8 6d 0c 00 00       	call   f0105bd3 <memcpy>
	newenv->env_tf.tf_regs.reg_eax = 0;
f0104f66:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104f69:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return newenv->env_id;
f0104f70:	8b 58 48             	mov    0x48(%eax),%ebx
f0104f73:	83 c4 10             	add    $0x10,%esp
		return sys_exofork();
f0104f76:	e9 a3 fc ff ff       	jmp    f0104c1e <syscall+0x5b>
	int r = envid2env(envid, &to_env, 1);  // 1 - Check perm
f0104f7b:	83 ec 04             	sub    $0x4,%esp
f0104f7e:	6a 01                	push   $0x1
f0104f80:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104f83:	50                   	push   %eax
f0104f84:	ff 75 0c             	pushl  0xc(%ebp)
f0104f87:	e8 82 e5 ff ff       	call   f010350e <envid2env>
f0104f8c:	89 c3                	mov    %eax,%ebx
	if (r)  // -E_BAD_ENV
f0104f8e:	83 c4 10             	add    $0x10,%esp
f0104f91:	85 c0                	test   %eax,%eax
f0104f93:	0f 85 85 fc ff ff    	jne    f0104c1e <syscall+0x5b>
	if (status > ENV_NOT_RUNNABLE || status < 0) 
f0104f99:	83 7d 10 04          	cmpl   $0x4,0x10(%ebp)
f0104f9d:	77 0e                	ja     f0104fad <syscall+0x3ea>
	to_env->env_status = status;
f0104f9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104fa2:	8b 75 10             	mov    0x10(%ebp),%esi
f0104fa5:	89 70 54             	mov    %esi,0x54(%eax)
f0104fa8:	e9 71 fc ff ff       	jmp    f0104c1e <syscall+0x5b>
		return -E_INVAL;
f0104fad:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		return sys_env_set_status(a1, a2);
f0104fb2:	e9 67 fc ff ff       	jmp    f0104c1e <syscall+0x5b>
	int r = envid2env(envid, &to_env, 1);  // 1 - Check perm
f0104fb7:	83 ec 04             	sub    $0x4,%esp
f0104fba:	6a 01                	push   $0x1
f0104fbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104fbf:	50                   	push   %eax
f0104fc0:	ff 75 0c             	pushl  0xc(%ebp)
f0104fc3:	e8 46 e5 ff ff       	call   f010350e <envid2env>
f0104fc8:	89 c3                	mov    %eax,%ebx
	if (r)  // -E_BAD_ENV
f0104fca:	83 c4 10             	add    $0x10,%esp
f0104fcd:	85 c0                	test   %eax,%eax
f0104fcf:	0f 85 49 fc ff ff    	jne    f0104c1e <syscall+0x5b>
	to_env->env_pgfault_upcall = func;
f0104fd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104fd8:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104fdb:	89 48 64             	mov    %ecx,0x64(%eax)
		return sys_env_set_pgfault_upcall(a1, (void*)a2);
f0104fde:	e9 3b fc ff ff       	jmp    f0104c1e <syscall+0x5b>
	sched_yield();
f0104fe3:	e8 eb fa ff ff       	call   f0104ad3 <sched_yield>
		return -E_INVAL;
f0104fe8:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104fed:	e9 2c fc ff ff       	jmp    f0104c1e <syscall+0x5b>

f0104ff2 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104ff2:	55                   	push   %ebp
f0104ff3:	89 e5                	mov    %esp,%ebp
f0104ff5:	57                   	push   %edi
f0104ff6:	56                   	push   %esi
f0104ff7:	53                   	push   %ebx
f0104ff8:	83 ec 14             	sub    $0x14,%esp
f0104ffb:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104ffe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105001:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105004:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105007:	8b 32                	mov    (%edx),%esi
f0105009:	8b 01                	mov    (%ecx),%eax
f010500b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010500e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0105015:	eb 2f                	jmp    f0105046 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0105017:	48                   	dec    %eax
		while (m >= l && stabs[m].n_type != type)
f0105018:	39 c6                	cmp    %eax,%esi
f010501a:	7f 4d                	jg     f0105069 <stab_binsearch+0x77>
f010501c:	0f b6 0a             	movzbl (%edx),%ecx
f010501f:	83 ea 0c             	sub    $0xc,%edx
f0105022:	39 f9                	cmp    %edi,%ecx
f0105024:	75 f1                	jne    f0105017 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105026:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0105029:	01 c2                	add    %eax,%edx
f010502b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010502e:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0105032:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105035:	73 37                	jae    f010506e <stab_binsearch+0x7c>
			*region_left = m;
f0105037:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010503a:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f010503c:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f010503f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0105046:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0105049:	7f 4d                	jg     f0105098 <stab_binsearch+0xa6>
		int true_m = (l + r) / 2, m = true_m;
f010504b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010504e:	01 f0                	add    %esi,%eax
f0105050:	89 c3                	mov    %eax,%ebx
f0105052:	c1 eb 1f             	shr    $0x1f,%ebx
f0105055:	01 c3                	add    %eax,%ebx
f0105057:	d1 fb                	sar    %ebx
f0105059:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f010505c:	01 d8                	add    %ebx,%eax
f010505e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105061:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0105065:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0105067:	eb af                	jmp    f0105018 <stab_binsearch+0x26>
			l = true_m + 1;
f0105069:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f010506c:	eb d8                	jmp    f0105046 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f010506e:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105071:	76 12                	jbe    f0105085 <stab_binsearch+0x93>
			*region_right = m - 1;
f0105073:	48                   	dec    %eax
f0105074:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105077:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010507a:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f010507c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105083:	eb c1                	jmp    f0105046 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105085:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105088:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f010508a:	ff 45 0c             	incl   0xc(%ebp)
f010508d:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f010508f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105096:	eb ae                	jmp    f0105046 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0105098:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010509c:	74 18                	je     f01050b6 <stab_binsearch+0xc4>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010509e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01050a1:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01050a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01050a6:	8b 0e                	mov    (%esi),%ecx
f01050a8:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01050ab:	01 c2                	add    %eax,%edx
f01050ad:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01050b0:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f01050b4:	eb 0e                	jmp    f01050c4 <stab_binsearch+0xd2>
		*region_right = *region_left - 1;
f01050b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01050b9:	8b 00                	mov    (%eax),%eax
f01050bb:	48                   	dec    %eax
f01050bc:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01050bf:	89 07                	mov    %eax,(%edi)
f01050c1:	eb 14                	jmp    f01050d7 <stab_binsearch+0xe5>
		     l--)
f01050c3:	48                   	dec    %eax
		for (l = *region_right;
f01050c4:	39 c1                	cmp    %eax,%ecx
f01050c6:	7d 0a                	jge    f01050d2 <stab_binsearch+0xe0>
		     l > *region_left && stabs[l].n_type != type;
f01050c8:	0f b6 1a             	movzbl (%edx),%ebx
f01050cb:	83 ea 0c             	sub    $0xc,%edx
f01050ce:	39 fb                	cmp    %edi,%ebx
f01050d0:	75 f1                	jne    f01050c3 <stab_binsearch+0xd1>
			/* do nothing */;
		*region_left = l;
f01050d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01050d5:	89 07                	mov    %eax,(%edi)
	}
}
f01050d7:	83 c4 14             	add    $0x14,%esp
f01050da:	5b                   	pop    %ebx
f01050db:	5e                   	pop    %esi
f01050dc:	5f                   	pop    %edi
f01050dd:	5d                   	pop    %ebp
f01050de:	c3                   	ret    

f01050df <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01050df:	55                   	push   %ebp
f01050e0:	89 e5                	mov    %esp,%ebp
f01050e2:	57                   	push   %edi
f01050e3:	56                   	push   %esi
f01050e4:	53                   	push   %ebx
f01050e5:	83 ec 4c             	sub    $0x4c,%esp
f01050e8:	8b 75 08             	mov    0x8(%ebp),%esi
f01050eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01050ee:	c7 03 90 83 10 f0    	movl   $0xf0108390,(%ebx)
	info->eip_line = 0;
f01050f4:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01050fb:	c7 43 08 90 83 10 f0 	movl   $0xf0108390,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0105102:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0105109:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010510c:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105113:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0105119:	77 1e                	ja     f0105139 <debuginfo_eip+0x5a>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f010511b:	8b 3d 00 00 20 00    	mov    0x200000,%edi
		stab_end = usd->stab_end;
f0105121:	8b 15 04 00 20 00    	mov    0x200004,%edx
		stabstr = usd->stabstr;
f0105127:	a1 08 00 20 00       	mov    0x200008,%eax
f010512c:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f010512f:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0105134:	89 45 b8             	mov    %eax,-0x48(%ebp)
f0105137:	eb 18                	jmp    f0105151 <debuginfo_eip+0x72>
		stabstr_end = __STABSTR_END__;
f0105139:	c7 45 b8 1d 7e 11 f0 	movl   $0xf0117e1d,-0x48(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0105140:	c7 45 b4 e1 45 11 f0 	movl   $0xf01145e1,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0105147:	ba e0 45 11 f0       	mov    $0xf01145e0,%edx
		stabs = __STAB_BEGIN__;
f010514c:	bf 74 88 10 f0       	mov    $0xf0108874,%edi
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105151:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0105154:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
f0105157:	0f 83 9b 01 00 00    	jae    f01052f8 <debuginfo_eip+0x219>
f010515d:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0105161:	0f 85 98 01 00 00    	jne    f01052ff <debuginfo_eip+0x220>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105167:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010516e:	29 fa                	sub    %edi,%edx
f0105170:	c1 fa 02             	sar    $0x2,%edx
f0105173:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0105176:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0105179:	8d 04 82             	lea    (%edx,%eax,4),%eax
f010517c:	89 c1                	mov    %eax,%ecx
f010517e:	c1 e1 08             	shl    $0x8,%ecx
f0105181:	01 c8                	add    %ecx,%eax
f0105183:	89 c1                	mov    %eax,%ecx
f0105185:	c1 e1 10             	shl    $0x10,%ecx
f0105188:	01 c8                	add    %ecx,%eax
f010518a:	01 c0                	add    %eax,%eax
f010518c:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
f0105190:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105193:	56                   	push   %esi
f0105194:	6a 64                	push   $0x64
f0105196:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105199:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010519c:	89 f8                	mov    %edi,%eax
f010519e:	e8 4f fe ff ff       	call   f0104ff2 <stab_binsearch>
	if (lfile == 0)
f01051a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01051a6:	83 c4 08             	add    $0x8,%esp
f01051a9:	85 c0                	test   %eax,%eax
f01051ab:	0f 84 55 01 00 00    	je     f0105306 <debuginfo_eip+0x227>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01051b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01051b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01051b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01051ba:	56                   	push   %esi
f01051bb:	6a 24                	push   $0x24
f01051bd:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01051c0:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01051c3:	89 f8                	mov    %edi,%eax
f01051c5:	e8 28 fe ff ff       	call   f0104ff2 <stab_binsearch>

	if (lfun <= rfun) {
f01051ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01051cd:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01051d0:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f01051d3:	83 c4 08             	add    $0x8,%esp
f01051d6:	39 c8                	cmp    %ecx,%eax
f01051d8:	0f 8f 80 00 00 00    	jg     f010525e <debuginfo_eip+0x17f>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01051de:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01051e1:	01 c2                	add    %eax,%edx
f01051e3:	8d 14 97             	lea    (%edi,%edx,4),%edx
f01051e6:	89 55 c0             	mov    %edx,-0x40(%ebp)
f01051e9:	8b 0a                	mov    (%edx),%ecx
f01051eb:	89 4d bc             	mov    %ecx,-0x44(%ebp)
f01051ee:	8b 55 b8             	mov    -0x48(%ebp),%edx
f01051f1:	2b 55 b4             	sub    -0x4c(%ebp),%edx
f01051f4:	39 d1                	cmp    %edx,%ecx
f01051f6:	73 06                	jae    f01051fe <debuginfo_eip+0x11f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01051f8:	03 4d b4             	add    -0x4c(%ebp),%ecx
f01051fb:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01051fe:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105201:	8b 51 08             	mov    0x8(%ecx),%edx
f0105204:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105207:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0105209:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010520c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010520f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105212:	83 ec 08             	sub    $0x8,%esp
f0105215:	6a 3a                	push   $0x3a
f0105217:	ff 73 08             	pushl  0x8(%ebx)
f010521a:	e8 e9 08 00 00       	call   f0105b08 <strfind>
f010521f:	2b 43 08             	sub    0x8(%ebx),%eax
f0105222:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// N_SLINE represents text segment
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105225:	83 c4 08             	add    $0x8,%esp
f0105228:	56                   	push   %esi
f0105229:	6a 44                	push   $0x44
f010522b:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010522e:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105231:	89 f8                	mov    %edi,%eax
f0105233:	e8 ba fd ff ff       	call   f0104ff2 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0105238:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010523b:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010523e:	01 c2                	add    %eax,%edx
f0105240:	c1 e2 02             	shl    $0x2,%edx
f0105243:	0f b7 4c 17 06       	movzwl 0x6(%edi,%edx,1),%ecx
f0105248:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010524b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010524e:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0105251:	8d 54 17 04          	lea    0x4(%edi,%edx,1),%edx
f0105255:	83 c4 10             	add    $0x10,%esp
f0105258:	c6 45 c0 00          	movb   $0x0,-0x40(%ebp)
f010525c:	eb 19                	jmp    f0105277 <debuginfo_eip+0x198>
		info->eip_fn_addr = addr;
f010525e:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0105261:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105264:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105267:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010526a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010526d:	eb a3                	jmp    f0105212 <debuginfo_eip+0x133>
f010526f:	48                   	dec    %eax
f0105270:	83 ea 0c             	sub    $0xc,%edx
f0105273:	c6 45 c0 01          	movb   $0x1,-0x40(%ebp)
f0105277:	89 45 bc             	mov    %eax,-0x44(%ebp)
	while (lline >= lfile
f010527a:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f010527d:	7f 40                	jg     f01052bf <debuginfo_eip+0x1e0>
	       && stabs[lline].n_type != N_SOL
f010527f:	8a 0a                	mov    (%edx),%cl
f0105281:	80 f9 84             	cmp    $0x84,%cl
f0105284:	74 19                	je     f010529f <debuginfo_eip+0x1c0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105286:	80 f9 64             	cmp    $0x64,%cl
f0105289:	75 e4                	jne    f010526f <debuginfo_eip+0x190>
f010528b:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f010528f:	74 de                	je     f010526f <debuginfo_eip+0x190>
f0105291:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f0105295:	74 0e                	je     f01052a5 <debuginfo_eip+0x1c6>
f0105297:	8b 75 bc             	mov    -0x44(%ebp),%esi
f010529a:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010529d:	eb 06                	jmp    f01052a5 <debuginfo_eip+0x1c6>
f010529f:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f01052a3:	75 35                	jne    f01052da <debuginfo_eip+0x1fb>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01052a5:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01052a8:	01 d0                	add    %edx,%eax
f01052aa:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01052ad:	8b 45 b8             	mov    -0x48(%ebp),%eax
f01052b0:	8b 75 b4             	mov    -0x4c(%ebp),%esi
f01052b3:	29 f0                	sub    %esi,%eax
f01052b5:	39 c2                	cmp    %eax,%edx
f01052b7:	73 06                	jae    f01052bf <debuginfo_eip+0x1e0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01052b9:	89 f0                	mov    %esi,%eax
f01052bb:	01 d0                	add    %edx,%eax
f01052bd:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01052bf:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01052c2:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01052c5:	39 f2                	cmp    %esi,%edx
f01052c7:	7d 44                	jge    f010530d <debuginfo_eip+0x22e>
		for (lline = lfun + 1;
f01052c9:	42                   	inc    %edx
f01052ca:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01052cd:	89 d0                	mov    %edx,%eax
f01052cf:	8d 0c 12             	lea    (%edx,%edx,1),%ecx
f01052d2:	01 ca                	add    %ecx,%edx
f01052d4:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f01052d8:	eb 08                	jmp    f01052e2 <debuginfo_eip+0x203>
f01052da:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01052dd:	eb c6                	jmp    f01052a5 <debuginfo_eip+0x1c6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01052df:	ff 43 14             	incl   0x14(%ebx)
		for (lline = lfun + 1;
f01052e2:	39 c6                	cmp    %eax,%esi
f01052e4:	7e 34                	jle    f010531a <debuginfo_eip+0x23b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01052e6:	8a 0a                	mov    (%edx),%cl
f01052e8:	40                   	inc    %eax
f01052e9:	83 c2 0c             	add    $0xc,%edx
f01052ec:	80 f9 a0             	cmp    $0xa0,%cl
f01052ef:	74 ee                	je     f01052df <debuginfo_eip+0x200>

	return 0;
f01052f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01052f6:	eb 1a                	jmp    f0105312 <debuginfo_eip+0x233>
		return -1;
f01052f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01052fd:	eb 13                	jmp    f0105312 <debuginfo_eip+0x233>
f01052ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105304:	eb 0c                	jmp    f0105312 <debuginfo_eip+0x233>
		return -1;
f0105306:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010530b:	eb 05                	jmp    f0105312 <debuginfo_eip+0x233>
	return 0;
f010530d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105312:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105315:	5b                   	pop    %ebx
f0105316:	5e                   	pop    %esi
f0105317:	5f                   	pop    %edi
f0105318:	5d                   	pop    %ebp
f0105319:	c3                   	ret    
	return 0;
f010531a:	b8 00 00 00 00       	mov    $0x0,%eax
f010531f:	eb f1                	jmp    f0105312 <debuginfo_eip+0x233>

f0105321 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105321:	55                   	push   %ebp
f0105322:	89 e5                	mov    %esp,%ebp
f0105324:	57                   	push   %edi
f0105325:	56                   	push   %esi
f0105326:	53                   	push   %ebx
f0105327:	83 ec 1c             	sub    $0x1c,%esp
f010532a:	89 c7                	mov    %eax,%edi
f010532c:	89 d6                	mov    %edx,%esi
f010532e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105331:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105334:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105337:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010533a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010533d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105342:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105345:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0105348:	39 d3                	cmp    %edx,%ebx
f010534a:	72 05                	jb     f0105351 <printnum+0x30>
f010534c:	39 45 10             	cmp    %eax,0x10(%ebp)
f010534f:	77 78                	ja     f01053c9 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105351:	83 ec 0c             	sub    $0xc,%esp
f0105354:	ff 75 18             	pushl  0x18(%ebp)
f0105357:	8b 45 14             	mov    0x14(%ebp),%eax
f010535a:	8d 58 ff             	lea    -0x1(%eax),%ebx
f010535d:	53                   	push   %ebx
f010535e:	ff 75 10             	pushl  0x10(%ebp)
f0105361:	83 ec 08             	sub    $0x8,%esp
f0105364:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105367:	ff 75 e0             	pushl  -0x20(%ebp)
f010536a:	ff 75 dc             	pushl  -0x24(%ebp)
f010536d:	ff 75 d8             	pushl  -0x28(%ebp)
f0105370:	e8 9b 12 00 00       	call   f0106610 <__udivdi3>
f0105375:	83 c4 18             	add    $0x18,%esp
f0105378:	52                   	push   %edx
f0105379:	50                   	push   %eax
f010537a:	89 f2                	mov    %esi,%edx
f010537c:	89 f8                	mov    %edi,%eax
f010537e:	e8 9e ff ff ff       	call   f0105321 <printnum>
f0105383:	83 c4 20             	add    $0x20,%esp
f0105386:	eb 11                	jmp    f0105399 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105388:	83 ec 08             	sub    $0x8,%esp
f010538b:	56                   	push   %esi
f010538c:	ff 75 18             	pushl  0x18(%ebp)
f010538f:	ff d7                	call   *%edi
f0105391:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0105394:	4b                   	dec    %ebx
f0105395:	85 db                	test   %ebx,%ebx
f0105397:	7f ef                	jg     f0105388 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105399:	83 ec 08             	sub    $0x8,%esp
f010539c:	56                   	push   %esi
f010539d:	83 ec 04             	sub    $0x4,%esp
f01053a0:	ff 75 e4             	pushl  -0x1c(%ebp)
f01053a3:	ff 75 e0             	pushl  -0x20(%ebp)
f01053a6:	ff 75 dc             	pushl  -0x24(%ebp)
f01053a9:	ff 75 d8             	pushl  -0x28(%ebp)
f01053ac:	e8 5f 13 00 00       	call   f0106710 <__umoddi3>
f01053b1:	83 c4 14             	add    $0x14,%esp
f01053b4:	0f be 80 9a 83 10 f0 	movsbl -0xfef7c66(%eax),%eax
f01053bb:	50                   	push   %eax
f01053bc:	ff d7                	call   *%edi
}
f01053be:	83 c4 10             	add    $0x10,%esp
f01053c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01053c4:	5b                   	pop    %ebx
f01053c5:	5e                   	pop    %esi
f01053c6:	5f                   	pop    %edi
f01053c7:	5d                   	pop    %ebp
f01053c8:	c3                   	ret    
f01053c9:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01053cc:	eb c6                	jmp    f0105394 <printnum+0x73>

f01053ce <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01053ce:	55                   	push   %ebp
f01053cf:	89 e5                	mov    %esp,%ebp
f01053d1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01053d4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f01053d7:	8b 10                	mov    (%eax),%edx
f01053d9:	3b 50 04             	cmp    0x4(%eax),%edx
f01053dc:	73 0a                	jae    f01053e8 <sprintputch+0x1a>
		*b->buf++ = ch;
f01053de:	8d 4a 01             	lea    0x1(%edx),%ecx
f01053e1:	89 08                	mov    %ecx,(%eax)
f01053e3:	8b 45 08             	mov    0x8(%ebp),%eax
f01053e6:	88 02                	mov    %al,(%edx)
}
f01053e8:	5d                   	pop    %ebp
f01053e9:	c3                   	ret    

f01053ea <printfmt>:
{
f01053ea:	55                   	push   %ebp
f01053eb:	89 e5                	mov    %esp,%ebp
f01053ed:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01053f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01053f3:	50                   	push   %eax
f01053f4:	ff 75 10             	pushl  0x10(%ebp)
f01053f7:	ff 75 0c             	pushl  0xc(%ebp)
f01053fa:	ff 75 08             	pushl  0x8(%ebp)
f01053fd:	e8 05 00 00 00       	call   f0105407 <vprintfmt>
}
f0105402:	83 c4 10             	add    $0x10,%esp
f0105405:	c9                   	leave  
f0105406:	c3                   	ret    

f0105407 <vprintfmt>:
{
f0105407:	55                   	push   %ebp
f0105408:	89 e5                	mov    %esp,%ebp
f010540a:	57                   	push   %edi
f010540b:	56                   	push   %esi
f010540c:	53                   	push   %ebx
f010540d:	83 ec 2c             	sub    $0x2c,%esp
f0105410:	8b 75 08             	mov    0x8(%ebp),%esi
f0105413:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105416:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105419:	e9 ac 03 00 00       	jmp    f01057ca <vprintfmt+0x3c3>
		padc = ' ';
f010541e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0105422:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0105429:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f0105430:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0105437:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f010543c:	8d 47 01             	lea    0x1(%edi),%eax
f010543f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105442:	8a 17                	mov    (%edi),%dl
f0105444:	8d 42 dd             	lea    -0x23(%edx),%eax
f0105447:	3c 55                	cmp    $0x55,%al
f0105449:	0f 87 fc 03 00 00    	ja     f010584b <vprintfmt+0x444>
f010544f:	0f b6 c0             	movzbl %al,%eax
f0105452:	ff 24 85 60 84 10 f0 	jmp    *-0xfef7ba0(,%eax,4)
f0105459:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f010545c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0105460:	eb da                	jmp    f010543c <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0105462:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0105465:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0105469:	eb d1                	jmp    f010543c <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f010546b:	0f b6 d2             	movzbl %dl,%edx
f010546e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0105471:	b8 00 00 00 00       	mov    $0x0,%eax
f0105476:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0105479:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010547c:	01 c0                	add    %eax,%eax
f010547e:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
f0105482:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0105485:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0105488:	83 f9 09             	cmp    $0x9,%ecx
f010548b:	77 52                	ja     f01054df <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
f010548d:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
f010548e:	eb e9                	jmp    f0105479 <vprintfmt+0x72>
			precision = va_arg(ap, int);
f0105490:	8b 45 14             	mov    0x14(%ebp),%eax
f0105493:	8b 00                	mov    (%eax),%eax
f0105495:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105498:	8b 45 14             	mov    0x14(%ebp),%eax
f010549b:	8d 40 04             	lea    0x4(%eax),%eax
f010549e:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01054a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f01054a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01054a8:	79 92                	jns    f010543c <vprintfmt+0x35>
				width = precision, precision = -1;
f01054aa:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01054ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01054b0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01054b7:	eb 83                	jmp    f010543c <vprintfmt+0x35>
f01054b9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01054bd:	78 08                	js     f01054c7 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
f01054bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01054c2:	e9 75 ff ff ff       	jmp    f010543c <vprintfmt+0x35>
f01054c7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01054ce:	eb ef                	jmp    f01054bf <vprintfmt+0xb8>
f01054d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f01054d3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01054da:	e9 5d ff ff ff       	jmp    f010543c <vprintfmt+0x35>
f01054df:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01054e2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01054e5:	eb bd                	jmp    f01054a4 <vprintfmt+0x9d>
			lflag++;
f01054e7:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
f01054e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01054eb:	e9 4c ff ff ff       	jmp    f010543c <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f01054f0:	8b 45 14             	mov    0x14(%ebp),%eax
f01054f3:	8d 78 04             	lea    0x4(%eax),%edi
f01054f6:	83 ec 08             	sub    $0x8,%esp
f01054f9:	53                   	push   %ebx
f01054fa:	ff 30                	pushl  (%eax)
f01054fc:	ff d6                	call   *%esi
			break;
f01054fe:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0105501:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0105504:	e9 be 02 00 00       	jmp    f01057c7 <vprintfmt+0x3c0>
			err = va_arg(ap, int);
f0105509:	8b 45 14             	mov    0x14(%ebp),%eax
f010550c:	8d 78 04             	lea    0x4(%eax),%edi
f010550f:	8b 00                	mov    (%eax),%eax
f0105511:	85 c0                	test   %eax,%eax
f0105513:	78 2a                	js     f010553f <vprintfmt+0x138>
f0105515:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105517:	83 f8 08             	cmp    $0x8,%eax
f010551a:	7f 27                	jg     f0105543 <vprintfmt+0x13c>
f010551c:	8b 04 85 c0 85 10 f0 	mov    -0xfef7a40(,%eax,4),%eax
f0105523:	85 c0                	test   %eax,%eax
f0105525:	74 1c                	je     f0105543 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
f0105527:	50                   	push   %eax
f0105528:	68 95 7a 10 f0       	push   $0xf0107a95
f010552d:	53                   	push   %ebx
f010552e:	56                   	push   %esi
f010552f:	e8 b6 fe ff ff       	call   f01053ea <printfmt>
f0105534:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105537:	89 7d 14             	mov    %edi,0x14(%ebp)
f010553a:	e9 88 02 00 00       	jmp    f01057c7 <vprintfmt+0x3c0>
f010553f:	f7 d8                	neg    %eax
f0105541:	eb d2                	jmp    f0105515 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
f0105543:	52                   	push   %edx
f0105544:	68 b2 83 10 f0       	push   $0xf01083b2
f0105549:	53                   	push   %ebx
f010554a:	56                   	push   %esi
f010554b:	e8 9a fe ff ff       	call   f01053ea <printfmt>
f0105550:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105553:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0105556:	e9 6c 02 00 00       	jmp    f01057c7 <vprintfmt+0x3c0>
			if ((p = va_arg(ap, char *)) == NULL)
f010555b:	8b 45 14             	mov    0x14(%ebp),%eax
f010555e:	83 c0 04             	add    $0x4,%eax
f0105561:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0105564:	8b 45 14             	mov    0x14(%ebp),%eax
f0105567:	8b 38                	mov    (%eax),%edi
f0105569:	85 ff                	test   %edi,%edi
f010556b:	74 18                	je     f0105585 <vprintfmt+0x17e>
			if (width > 0 && padc != '-')
f010556d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105571:	0f 8e b7 00 00 00    	jle    f010562e <vprintfmt+0x227>
f0105577:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010557b:	75 0f                	jne    f010558c <vprintfmt+0x185>
f010557d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105580:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0105583:	eb 6e                	jmp    f01055f3 <vprintfmt+0x1ec>
				p = "(null)";
f0105585:	bf ab 83 10 f0       	mov    $0xf01083ab,%edi
f010558a:	eb e1                	jmp    f010556d <vprintfmt+0x166>
				for (width -= strnlen(p, precision); width > 0; width--)
f010558c:	83 ec 08             	sub    $0x8,%esp
f010558f:	ff 75 d0             	pushl  -0x30(%ebp)
f0105592:	57                   	push   %edi
f0105593:	e8 45 04 00 00       	call   f01059dd <strnlen>
f0105598:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010559b:	29 c1                	sub    %eax,%ecx
f010559d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f01055a0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f01055a3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01055a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01055aa:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01055ad:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f01055af:	eb 0d                	jmp    f01055be <vprintfmt+0x1b7>
					putch(padc, putdat);
f01055b1:	83 ec 08             	sub    $0x8,%esp
f01055b4:	53                   	push   %ebx
f01055b5:	ff 75 e0             	pushl  -0x20(%ebp)
f01055b8:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f01055ba:	4f                   	dec    %edi
f01055bb:	83 c4 10             	add    $0x10,%esp
f01055be:	85 ff                	test   %edi,%edi
f01055c0:	7f ef                	jg     f01055b1 <vprintfmt+0x1aa>
f01055c2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01055c5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01055c8:	89 c8                	mov    %ecx,%eax
f01055ca:	85 c9                	test   %ecx,%ecx
f01055cc:	78 59                	js     f0105627 <vprintfmt+0x220>
f01055ce:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01055d1:	29 c1                	sub    %eax,%ecx
f01055d3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01055d6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01055d9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01055dc:	eb 15                	jmp    f01055f3 <vprintfmt+0x1ec>
				if (altflag && (ch < ' ' || ch > '~'))
f01055de:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01055e2:	75 29                	jne    f010560d <vprintfmt+0x206>
					putch(ch, putdat);
f01055e4:	83 ec 08             	sub    $0x8,%esp
f01055e7:	ff 75 0c             	pushl  0xc(%ebp)
f01055ea:	50                   	push   %eax
f01055eb:	ff d6                	call   *%esi
f01055ed:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01055f0:	ff 4d e0             	decl   -0x20(%ebp)
f01055f3:	47                   	inc    %edi
f01055f4:	8a 57 ff             	mov    -0x1(%edi),%dl
f01055f7:	0f be c2             	movsbl %dl,%eax
f01055fa:	85 c0                	test   %eax,%eax
f01055fc:	74 53                	je     f0105651 <vprintfmt+0x24a>
f01055fe:	85 db                	test   %ebx,%ebx
f0105600:	78 dc                	js     f01055de <vprintfmt+0x1d7>
f0105602:	4b                   	dec    %ebx
f0105603:	79 d9                	jns    f01055de <vprintfmt+0x1d7>
f0105605:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105608:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010560b:	eb 35                	jmp    f0105642 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
f010560d:	0f be d2             	movsbl %dl,%edx
f0105610:	83 ea 20             	sub    $0x20,%edx
f0105613:	83 fa 5e             	cmp    $0x5e,%edx
f0105616:	76 cc                	jbe    f01055e4 <vprintfmt+0x1dd>
					putch('?', putdat);
f0105618:	83 ec 08             	sub    $0x8,%esp
f010561b:	ff 75 0c             	pushl  0xc(%ebp)
f010561e:	6a 3f                	push   $0x3f
f0105620:	ff d6                	call   *%esi
f0105622:	83 c4 10             	add    $0x10,%esp
f0105625:	eb c9                	jmp    f01055f0 <vprintfmt+0x1e9>
f0105627:	b8 00 00 00 00       	mov    $0x0,%eax
f010562c:	eb a0                	jmp    f01055ce <vprintfmt+0x1c7>
f010562e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105631:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0105634:	eb bd                	jmp    f01055f3 <vprintfmt+0x1ec>
				putch(' ', putdat);
f0105636:	83 ec 08             	sub    $0x8,%esp
f0105639:	53                   	push   %ebx
f010563a:	6a 20                	push   $0x20
f010563c:	ff d6                	call   *%esi
			for (; width > 0; width--)
f010563e:	4f                   	dec    %edi
f010563f:	83 c4 10             	add    $0x10,%esp
f0105642:	85 ff                	test   %edi,%edi
f0105644:	7f f0                	jg     f0105636 <vprintfmt+0x22f>
			if ((p = va_arg(ap, char *)) == NULL)
f0105646:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105649:	89 45 14             	mov    %eax,0x14(%ebp)
f010564c:	e9 76 01 00 00       	jmp    f01057c7 <vprintfmt+0x3c0>
f0105651:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105654:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105657:	eb e9                	jmp    f0105642 <vprintfmt+0x23b>
	if (lflag >= 2)
f0105659:	83 f9 01             	cmp    $0x1,%ecx
f010565c:	7e 3f                	jle    f010569d <vprintfmt+0x296>
		return va_arg(*ap, long long);
f010565e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105661:	8b 50 04             	mov    0x4(%eax),%edx
f0105664:	8b 00                	mov    (%eax),%eax
f0105666:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105669:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010566c:	8b 45 14             	mov    0x14(%ebp),%eax
f010566f:	8d 40 08             	lea    0x8(%eax),%eax
f0105672:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0105675:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105679:	79 5c                	jns    f01056d7 <vprintfmt+0x2d0>
				putch('-', putdat);
f010567b:	83 ec 08             	sub    $0x8,%esp
f010567e:	53                   	push   %ebx
f010567f:	6a 2d                	push   $0x2d
f0105681:	ff d6                	call   *%esi
				num = -(long long) num;
f0105683:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105686:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105689:	f7 da                	neg    %edx
f010568b:	83 d1 00             	adc    $0x0,%ecx
f010568e:	f7 d9                	neg    %ecx
f0105690:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0105693:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105698:	e9 10 01 00 00       	jmp    f01057ad <vprintfmt+0x3a6>
	else if (lflag)
f010569d:	85 c9                	test   %ecx,%ecx
f010569f:	75 1b                	jne    f01056bc <vprintfmt+0x2b5>
		return va_arg(*ap, int);
f01056a1:	8b 45 14             	mov    0x14(%ebp),%eax
f01056a4:	8b 00                	mov    (%eax),%eax
f01056a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01056a9:	89 c1                	mov    %eax,%ecx
f01056ab:	c1 f9 1f             	sar    $0x1f,%ecx
f01056ae:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01056b1:	8b 45 14             	mov    0x14(%ebp),%eax
f01056b4:	8d 40 04             	lea    0x4(%eax),%eax
f01056b7:	89 45 14             	mov    %eax,0x14(%ebp)
f01056ba:	eb b9                	jmp    f0105675 <vprintfmt+0x26e>
		return va_arg(*ap, long);
f01056bc:	8b 45 14             	mov    0x14(%ebp),%eax
f01056bf:	8b 00                	mov    (%eax),%eax
f01056c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01056c4:	89 c1                	mov    %eax,%ecx
f01056c6:	c1 f9 1f             	sar    $0x1f,%ecx
f01056c9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01056cc:	8b 45 14             	mov    0x14(%ebp),%eax
f01056cf:	8d 40 04             	lea    0x4(%eax),%eax
f01056d2:	89 45 14             	mov    %eax,0x14(%ebp)
f01056d5:	eb 9e                	jmp    f0105675 <vprintfmt+0x26e>
			num = getint(&ap, lflag);
f01056d7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01056da:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01056dd:	b8 0a 00 00 00       	mov    $0xa,%eax
f01056e2:	e9 c6 00 00 00       	jmp    f01057ad <vprintfmt+0x3a6>
	if (lflag >= 2)
f01056e7:	83 f9 01             	cmp    $0x1,%ecx
f01056ea:	7e 18                	jle    f0105704 <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
f01056ec:	8b 45 14             	mov    0x14(%ebp),%eax
f01056ef:	8b 10                	mov    (%eax),%edx
f01056f1:	8b 48 04             	mov    0x4(%eax),%ecx
f01056f4:	8d 40 08             	lea    0x8(%eax),%eax
f01056f7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01056fa:	b8 0a 00 00 00       	mov    $0xa,%eax
f01056ff:	e9 a9 00 00 00       	jmp    f01057ad <vprintfmt+0x3a6>
	else if (lflag)
f0105704:	85 c9                	test   %ecx,%ecx
f0105706:	75 1a                	jne    f0105722 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned int);
f0105708:	8b 45 14             	mov    0x14(%ebp),%eax
f010570b:	8b 10                	mov    (%eax),%edx
f010570d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105712:	8d 40 04             	lea    0x4(%eax),%eax
f0105715:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105718:	b8 0a 00 00 00       	mov    $0xa,%eax
f010571d:	e9 8b 00 00 00       	jmp    f01057ad <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0105722:	8b 45 14             	mov    0x14(%ebp),%eax
f0105725:	8b 10                	mov    (%eax),%edx
f0105727:	b9 00 00 00 00       	mov    $0x0,%ecx
f010572c:	8d 40 04             	lea    0x4(%eax),%eax
f010572f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105732:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105737:	eb 74                	jmp    f01057ad <vprintfmt+0x3a6>
	if (lflag >= 2)
f0105739:	83 f9 01             	cmp    $0x1,%ecx
f010573c:	7e 15                	jle    f0105753 <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
f010573e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105741:	8b 10                	mov    (%eax),%edx
f0105743:	8b 48 04             	mov    0x4(%eax),%ecx
f0105746:	8d 40 08             	lea    0x8(%eax),%eax
f0105749:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010574c:	b8 08 00 00 00       	mov    $0x8,%eax
f0105751:	eb 5a                	jmp    f01057ad <vprintfmt+0x3a6>
	else if (lflag)
f0105753:	85 c9                	test   %ecx,%ecx
f0105755:	75 17                	jne    f010576e <vprintfmt+0x367>
		return va_arg(*ap, unsigned int);
f0105757:	8b 45 14             	mov    0x14(%ebp),%eax
f010575a:	8b 10                	mov    (%eax),%edx
f010575c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105761:	8d 40 04             	lea    0x4(%eax),%eax
f0105764:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0105767:	b8 08 00 00 00       	mov    $0x8,%eax
f010576c:	eb 3f                	jmp    f01057ad <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f010576e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105771:	8b 10                	mov    (%eax),%edx
f0105773:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105778:	8d 40 04             	lea    0x4(%eax),%eax
f010577b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010577e:	b8 08 00 00 00       	mov    $0x8,%eax
f0105783:	eb 28                	jmp    f01057ad <vprintfmt+0x3a6>
			putch('0', putdat);
f0105785:	83 ec 08             	sub    $0x8,%esp
f0105788:	53                   	push   %ebx
f0105789:	6a 30                	push   $0x30
f010578b:	ff d6                	call   *%esi
			putch('x', putdat);
f010578d:	83 c4 08             	add    $0x8,%esp
f0105790:	53                   	push   %ebx
f0105791:	6a 78                	push   $0x78
f0105793:	ff d6                	call   *%esi
			num = (unsigned long long)
f0105795:	8b 45 14             	mov    0x14(%ebp),%eax
f0105798:	8b 10                	mov    (%eax),%edx
f010579a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010579f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01057a2:	8d 40 04             	lea    0x4(%eax),%eax
f01057a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01057a8:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01057ad:	83 ec 0c             	sub    $0xc,%esp
f01057b0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01057b4:	57                   	push   %edi
f01057b5:	ff 75 e0             	pushl  -0x20(%ebp)
f01057b8:	50                   	push   %eax
f01057b9:	51                   	push   %ecx
f01057ba:	52                   	push   %edx
f01057bb:	89 da                	mov    %ebx,%edx
f01057bd:	89 f0                	mov    %esi,%eax
f01057bf:	e8 5d fb ff ff       	call   f0105321 <printnum>
			break;
f01057c4:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f01057c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01057ca:	47                   	inc    %edi
f01057cb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01057cf:	83 f8 25             	cmp    $0x25,%eax
f01057d2:	0f 84 46 fc ff ff    	je     f010541e <vprintfmt+0x17>
			if (ch == '\0')
f01057d8:	85 c0                	test   %eax,%eax
f01057da:	0f 84 89 00 00 00    	je     f0105869 <vprintfmt+0x462>
			putch(ch, putdat);
f01057e0:	83 ec 08             	sub    $0x8,%esp
f01057e3:	53                   	push   %ebx
f01057e4:	50                   	push   %eax
f01057e5:	ff d6                	call   *%esi
f01057e7:	83 c4 10             	add    $0x10,%esp
f01057ea:	eb de                	jmp    f01057ca <vprintfmt+0x3c3>
	if (lflag >= 2)
f01057ec:	83 f9 01             	cmp    $0x1,%ecx
f01057ef:	7e 15                	jle    f0105806 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
f01057f1:	8b 45 14             	mov    0x14(%ebp),%eax
f01057f4:	8b 10                	mov    (%eax),%edx
f01057f6:	8b 48 04             	mov    0x4(%eax),%ecx
f01057f9:	8d 40 08             	lea    0x8(%eax),%eax
f01057fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01057ff:	b8 10 00 00 00       	mov    $0x10,%eax
f0105804:	eb a7                	jmp    f01057ad <vprintfmt+0x3a6>
	else if (lflag)
f0105806:	85 c9                	test   %ecx,%ecx
f0105808:	75 17                	jne    f0105821 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned int);
f010580a:	8b 45 14             	mov    0x14(%ebp),%eax
f010580d:	8b 10                	mov    (%eax),%edx
f010580f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105814:	8d 40 04             	lea    0x4(%eax),%eax
f0105817:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010581a:	b8 10 00 00 00       	mov    $0x10,%eax
f010581f:	eb 8c                	jmp    f01057ad <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0105821:	8b 45 14             	mov    0x14(%ebp),%eax
f0105824:	8b 10                	mov    (%eax),%edx
f0105826:	b9 00 00 00 00       	mov    $0x0,%ecx
f010582b:	8d 40 04             	lea    0x4(%eax),%eax
f010582e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105831:	b8 10 00 00 00       	mov    $0x10,%eax
f0105836:	e9 72 ff ff ff       	jmp    f01057ad <vprintfmt+0x3a6>
			putch(ch, putdat);
f010583b:	83 ec 08             	sub    $0x8,%esp
f010583e:	53                   	push   %ebx
f010583f:	6a 25                	push   $0x25
f0105841:	ff d6                	call   *%esi
			break;
f0105843:	83 c4 10             	add    $0x10,%esp
f0105846:	e9 7c ff ff ff       	jmp    f01057c7 <vprintfmt+0x3c0>
			putch('%', putdat);
f010584b:	83 ec 08             	sub    $0x8,%esp
f010584e:	53                   	push   %ebx
f010584f:	6a 25                	push   $0x25
f0105851:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105853:	83 c4 10             	add    $0x10,%esp
f0105856:	89 f8                	mov    %edi,%eax
f0105858:	eb 01                	jmp    f010585b <vprintfmt+0x454>
f010585a:	48                   	dec    %eax
f010585b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010585f:	75 f9                	jne    f010585a <vprintfmt+0x453>
f0105861:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105864:	e9 5e ff ff ff       	jmp    f01057c7 <vprintfmt+0x3c0>
}
f0105869:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010586c:	5b                   	pop    %ebx
f010586d:	5e                   	pop    %esi
f010586e:	5f                   	pop    %edi
f010586f:	5d                   	pop    %ebp
f0105870:	c3                   	ret    

f0105871 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105871:	55                   	push   %ebp
f0105872:	89 e5                	mov    %esp,%ebp
f0105874:	83 ec 18             	sub    $0x18,%esp
f0105877:	8b 45 08             	mov    0x8(%ebp),%eax
f010587a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010587d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105880:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105884:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105887:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010588e:	85 c0                	test   %eax,%eax
f0105890:	74 26                	je     f01058b8 <vsnprintf+0x47>
f0105892:	85 d2                	test   %edx,%edx
f0105894:	7e 29                	jle    f01058bf <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105896:	ff 75 14             	pushl  0x14(%ebp)
f0105899:	ff 75 10             	pushl  0x10(%ebp)
f010589c:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010589f:	50                   	push   %eax
f01058a0:	68 ce 53 10 f0       	push   $0xf01053ce
f01058a5:	e8 5d fb ff ff       	call   f0105407 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01058aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01058ad:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01058b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01058b3:	83 c4 10             	add    $0x10,%esp
}
f01058b6:	c9                   	leave  
f01058b7:	c3                   	ret    
		return -E_INVAL;
f01058b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01058bd:	eb f7                	jmp    f01058b6 <vsnprintf+0x45>
f01058bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01058c4:	eb f0                	jmp    f01058b6 <vsnprintf+0x45>

f01058c6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01058c6:	55                   	push   %ebp
f01058c7:	89 e5                	mov    %esp,%ebp
f01058c9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01058cc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01058cf:	50                   	push   %eax
f01058d0:	ff 75 10             	pushl  0x10(%ebp)
f01058d3:	ff 75 0c             	pushl  0xc(%ebp)
f01058d6:	ff 75 08             	pushl  0x8(%ebp)
f01058d9:	e8 93 ff ff ff       	call   f0105871 <vsnprintf>
	va_end(ap);

	return rc;
}
f01058de:	c9                   	leave  
f01058df:	c3                   	ret    

f01058e0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01058e0:	55                   	push   %ebp
f01058e1:	89 e5                	mov    %esp,%ebp
f01058e3:	57                   	push   %edi
f01058e4:	56                   	push   %esi
f01058e5:	53                   	push   %ebx
f01058e6:	83 ec 0c             	sub    $0xc,%esp
f01058e9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01058ec:	85 c0                	test   %eax,%eax
f01058ee:	74 11                	je     f0105901 <readline+0x21>
		cprintf("%s", prompt);
f01058f0:	83 ec 08             	sub    $0x8,%esp
f01058f3:	50                   	push   %eax
f01058f4:	68 95 7a 10 f0       	push   $0xf0107a95
f01058f9:	e8 95 e6 ff ff       	call   f0103f93 <cprintf>
f01058fe:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0105901:	83 ec 0c             	sub    $0xc,%esp
f0105904:	6a 00                	push   $0x0
f0105906:	e8 32 af ff ff       	call   f010083d <iscons>
f010590b:	89 c7                	mov    %eax,%edi
f010590d:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0105910:	be 00 00 00 00       	mov    $0x0,%esi
f0105915:	eb 6f                	jmp    f0105986 <readline+0xa6>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0105917:	83 ec 08             	sub    $0x8,%esp
f010591a:	50                   	push   %eax
f010591b:	68 e4 85 10 f0       	push   $0xf01085e4
f0105920:	e8 6e e6 ff ff       	call   f0103f93 <cprintf>
			return NULL;
f0105925:	83 c4 10             	add    $0x10,%esp
f0105928:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f010592d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105930:	5b                   	pop    %ebx
f0105931:	5e                   	pop    %esi
f0105932:	5f                   	pop    %edi
f0105933:	5d                   	pop    %ebp
f0105934:	c3                   	ret    
				cputchar('\b');
f0105935:	83 ec 0c             	sub    $0xc,%esp
f0105938:	6a 08                	push   $0x8
f010593a:	e8 dd ae ff ff       	call   f010081c <cputchar>
f010593f:	83 c4 10             	add    $0x10,%esp
f0105942:	eb 41                	jmp    f0105985 <readline+0xa5>
				cputchar(c);
f0105944:	83 ec 0c             	sub    $0xc,%esp
f0105947:	53                   	push   %ebx
f0105948:	e8 cf ae ff ff       	call   f010081c <cputchar>
f010594d:	83 c4 10             	add    $0x10,%esp
f0105950:	eb 5a                	jmp    f01059ac <readline+0xcc>
		} else if (c == '\n' || c == '\r') {
f0105952:	83 fb 0a             	cmp    $0xa,%ebx
f0105955:	74 05                	je     f010595c <readline+0x7c>
f0105957:	83 fb 0d             	cmp    $0xd,%ebx
f010595a:	75 2a                	jne    f0105986 <readline+0xa6>
			if (echoing)
f010595c:	85 ff                	test   %edi,%edi
f010595e:	75 0e                	jne    f010596e <readline+0x8e>
			buf[i] = 0;
f0105960:	c6 86 80 6a 29 f0 00 	movb   $0x0,-0xfd69580(%esi)
			return buf;
f0105967:	b8 80 6a 29 f0       	mov    $0xf0296a80,%eax
f010596c:	eb bf                	jmp    f010592d <readline+0x4d>
				cputchar('\n');
f010596e:	83 ec 0c             	sub    $0xc,%esp
f0105971:	6a 0a                	push   $0xa
f0105973:	e8 a4 ae ff ff       	call   f010081c <cputchar>
f0105978:	83 c4 10             	add    $0x10,%esp
f010597b:	eb e3                	jmp    f0105960 <readline+0x80>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010597d:	85 f6                	test   %esi,%esi
f010597f:	7e 3c                	jle    f01059bd <readline+0xdd>
			if (echoing)
f0105981:	85 ff                	test   %edi,%edi
f0105983:	75 b0                	jne    f0105935 <readline+0x55>
			i--;
f0105985:	4e                   	dec    %esi
		c = getchar();
f0105986:	e8 a1 ae ff ff       	call   f010082c <getchar>
f010598b:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010598d:	85 c0                	test   %eax,%eax
f010598f:	78 86                	js     f0105917 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105991:	83 f8 08             	cmp    $0x8,%eax
f0105994:	74 21                	je     f01059b7 <readline+0xd7>
f0105996:	83 f8 7f             	cmp    $0x7f,%eax
f0105999:	74 e2                	je     f010597d <readline+0x9d>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010599b:	83 f8 1f             	cmp    $0x1f,%eax
f010599e:	7e b2                	jle    f0105952 <readline+0x72>
f01059a0:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01059a6:	7f aa                	jg     f0105952 <readline+0x72>
			if (echoing)
f01059a8:	85 ff                	test   %edi,%edi
f01059aa:	75 98                	jne    f0105944 <readline+0x64>
			buf[i++] = c;
f01059ac:	88 9e 80 6a 29 f0    	mov    %bl,-0xfd69580(%esi)
f01059b2:	8d 76 01             	lea    0x1(%esi),%esi
f01059b5:	eb cf                	jmp    f0105986 <readline+0xa6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01059b7:	85 f6                	test   %esi,%esi
f01059b9:	7e cb                	jle    f0105986 <readline+0xa6>
f01059bb:	eb c4                	jmp    f0105981 <readline+0xa1>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01059bd:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01059c3:	7e e3                	jle    f01059a8 <readline+0xc8>
f01059c5:	eb bf                	jmp    f0105986 <readline+0xa6>

f01059c7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01059c7:	55                   	push   %ebp
f01059c8:	89 e5                	mov    %esp,%ebp
f01059ca:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01059cd:	b8 00 00 00 00       	mov    $0x0,%eax
f01059d2:	eb 01                	jmp    f01059d5 <strlen+0xe>
		n++;
f01059d4:	40                   	inc    %eax
	for (n = 0; *s != '\0'; s++)
f01059d5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01059d9:	75 f9                	jne    f01059d4 <strlen+0xd>
	return n;
}
f01059db:	5d                   	pop    %ebp
f01059dc:	c3                   	ret    

f01059dd <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01059dd:	55                   	push   %ebp
f01059de:	89 e5                	mov    %esp,%ebp
f01059e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01059e3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01059e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01059eb:	eb 01                	jmp    f01059ee <strnlen+0x11>
		n++;
f01059ed:	40                   	inc    %eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01059ee:	39 d0                	cmp    %edx,%eax
f01059f0:	74 06                	je     f01059f8 <strnlen+0x1b>
f01059f2:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01059f6:	75 f5                	jne    f01059ed <strnlen+0x10>
	return n;
}
f01059f8:	5d                   	pop    %ebp
f01059f9:	c3                   	ret    

f01059fa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01059fa:	55                   	push   %ebp
f01059fb:	89 e5                	mov    %esp,%ebp
f01059fd:	53                   	push   %ebx
f01059fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105a04:	89 c2                	mov    %eax,%edx
f0105a06:	41                   	inc    %ecx
f0105a07:	42                   	inc    %edx
f0105a08:	8a 59 ff             	mov    -0x1(%ecx),%bl
f0105a0b:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105a0e:	84 db                	test   %bl,%bl
f0105a10:	75 f4                	jne    f0105a06 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105a12:	5b                   	pop    %ebx
f0105a13:	5d                   	pop    %ebp
f0105a14:	c3                   	ret    

f0105a15 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105a15:	55                   	push   %ebp
f0105a16:	89 e5                	mov    %esp,%ebp
f0105a18:	53                   	push   %ebx
f0105a19:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105a1c:	53                   	push   %ebx
f0105a1d:	e8 a5 ff ff ff       	call   f01059c7 <strlen>
f0105a22:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105a25:	ff 75 0c             	pushl  0xc(%ebp)
f0105a28:	01 d8                	add    %ebx,%eax
f0105a2a:	50                   	push   %eax
f0105a2b:	e8 ca ff ff ff       	call   f01059fa <strcpy>
	return dst;
}
f0105a30:	89 d8                	mov    %ebx,%eax
f0105a32:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105a35:	c9                   	leave  
f0105a36:	c3                   	ret    

f0105a37 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105a37:	55                   	push   %ebp
f0105a38:	89 e5                	mov    %esp,%ebp
f0105a3a:	56                   	push   %esi
f0105a3b:	53                   	push   %ebx
f0105a3c:	8b 75 08             	mov    0x8(%ebp),%esi
f0105a3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105a42:	89 f3                	mov    %esi,%ebx
f0105a44:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105a47:	89 f2                	mov    %esi,%edx
f0105a49:	39 da                	cmp    %ebx,%edx
f0105a4b:	74 0e                	je     f0105a5b <strncpy+0x24>
		*dst++ = *src;
f0105a4d:	42                   	inc    %edx
f0105a4e:	8a 01                	mov    (%ecx),%al
f0105a50:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f0105a53:	80 39 00             	cmpb   $0x0,(%ecx)
f0105a56:	74 f1                	je     f0105a49 <strncpy+0x12>
			src++;
f0105a58:	41                   	inc    %ecx
f0105a59:	eb ee                	jmp    f0105a49 <strncpy+0x12>
	}
	return ret;
}
f0105a5b:	89 f0                	mov    %esi,%eax
f0105a5d:	5b                   	pop    %ebx
f0105a5e:	5e                   	pop    %esi
f0105a5f:	5d                   	pop    %ebp
f0105a60:	c3                   	ret    

f0105a61 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105a61:	55                   	push   %ebp
f0105a62:	89 e5                	mov    %esp,%ebp
f0105a64:	56                   	push   %esi
f0105a65:	53                   	push   %ebx
f0105a66:	8b 75 08             	mov    0x8(%ebp),%esi
f0105a69:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105a6c:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105a6f:	85 c0                	test   %eax,%eax
f0105a71:	74 20                	je     f0105a93 <strlcpy+0x32>
f0105a73:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
f0105a77:	89 f0                	mov    %esi,%eax
f0105a79:	eb 05                	jmp    f0105a80 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105a7b:	42                   	inc    %edx
f0105a7c:	40                   	inc    %eax
f0105a7d:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0105a80:	39 d8                	cmp    %ebx,%eax
f0105a82:	74 06                	je     f0105a8a <strlcpy+0x29>
f0105a84:	8a 0a                	mov    (%edx),%cl
f0105a86:	84 c9                	test   %cl,%cl
f0105a88:	75 f1                	jne    f0105a7b <strlcpy+0x1a>
		*dst = '\0';
f0105a8a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105a8d:	29 f0                	sub    %esi,%eax
}
f0105a8f:	5b                   	pop    %ebx
f0105a90:	5e                   	pop    %esi
f0105a91:	5d                   	pop    %ebp
f0105a92:	c3                   	ret    
f0105a93:	89 f0                	mov    %esi,%eax
f0105a95:	eb f6                	jmp    f0105a8d <strlcpy+0x2c>

f0105a97 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105a97:	55                   	push   %ebp
f0105a98:	89 e5                	mov    %esp,%ebp
f0105a9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105a9d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105aa0:	eb 02                	jmp    f0105aa4 <strcmp+0xd>
		p++, q++;
f0105aa2:	41                   	inc    %ecx
f0105aa3:	42                   	inc    %edx
	while (*p && *p == *q)
f0105aa4:	8a 01                	mov    (%ecx),%al
f0105aa6:	84 c0                	test   %al,%al
f0105aa8:	74 04                	je     f0105aae <strcmp+0x17>
f0105aaa:	3a 02                	cmp    (%edx),%al
f0105aac:	74 f4                	je     f0105aa2 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105aae:	0f b6 c0             	movzbl %al,%eax
f0105ab1:	0f b6 12             	movzbl (%edx),%edx
f0105ab4:	29 d0                	sub    %edx,%eax
}
f0105ab6:	5d                   	pop    %ebp
f0105ab7:	c3                   	ret    

f0105ab8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105ab8:	55                   	push   %ebp
f0105ab9:	89 e5                	mov    %esp,%ebp
f0105abb:	53                   	push   %ebx
f0105abc:	8b 45 08             	mov    0x8(%ebp),%eax
f0105abf:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105ac2:	89 c3                	mov    %eax,%ebx
f0105ac4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105ac7:	eb 02                	jmp    f0105acb <strncmp+0x13>
		n--, p++, q++;
f0105ac9:	40                   	inc    %eax
f0105aca:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
f0105acb:	39 d8                	cmp    %ebx,%eax
f0105acd:	74 15                	je     f0105ae4 <strncmp+0x2c>
f0105acf:	8a 08                	mov    (%eax),%cl
f0105ad1:	84 c9                	test   %cl,%cl
f0105ad3:	74 04                	je     f0105ad9 <strncmp+0x21>
f0105ad5:	3a 0a                	cmp    (%edx),%cl
f0105ad7:	74 f0                	je     f0105ac9 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105ad9:	0f b6 00             	movzbl (%eax),%eax
f0105adc:	0f b6 12             	movzbl (%edx),%edx
f0105adf:	29 d0                	sub    %edx,%eax
}
f0105ae1:	5b                   	pop    %ebx
f0105ae2:	5d                   	pop    %ebp
f0105ae3:	c3                   	ret    
		return 0;
f0105ae4:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ae9:	eb f6                	jmp    f0105ae1 <strncmp+0x29>

f0105aeb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105aeb:	55                   	push   %ebp
f0105aec:	89 e5                	mov    %esp,%ebp
f0105aee:	8b 45 08             	mov    0x8(%ebp),%eax
f0105af1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0105af4:	8a 10                	mov    (%eax),%dl
f0105af6:	84 d2                	test   %dl,%dl
f0105af8:	74 07                	je     f0105b01 <strchr+0x16>
		if (*s == c)
f0105afa:	38 ca                	cmp    %cl,%dl
f0105afc:	74 08                	je     f0105b06 <strchr+0x1b>
	for (; *s; s++)
f0105afe:	40                   	inc    %eax
f0105aff:	eb f3                	jmp    f0105af4 <strchr+0x9>
			return (char *) s;
	return 0;
f0105b01:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105b06:	5d                   	pop    %ebp
f0105b07:	c3                   	ret    

f0105b08 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105b08:	55                   	push   %ebp
f0105b09:	89 e5                	mov    %esp,%ebp
f0105b0b:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b0e:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0105b11:	8a 10                	mov    (%eax),%dl
f0105b13:	84 d2                	test   %dl,%dl
f0105b15:	74 07                	je     f0105b1e <strfind+0x16>
		if (*s == c)
f0105b17:	38 ca                	cmp    %cl,%dl
f0105b19:	74 03                	je     f0105b1e <strfind+0x16>
	for (; *s; s++)
f0105b1b:	40                   	inc    %eax
f0105b1c:	eb f3                	jmp    f0105b11 <strfind+0x9>
			break;
	return (char *) s;
}
f0105b1e:	5d                   	pop    %ebp
f0105b1f:	c3                   	ret    

f0105b20 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105b20:	55                   	push   %ebp
f0105b21:	89 e5                	mov    %esp,%ebp
f0105b23:	57                   	push   %edi
f0105b24:	56                   	push   %esi
f0105b25:	53                   	push   %ebx
f0105b26:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105b29:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105b2c:	85 c9                	test   %ecx,%ecx
f0105b2e:	74 13                	je     f0105b43 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105b30:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105b36:	75 05                	jne    f0105b3d <memset+0x1d>
f0105b38:	f6 c1 03             	test   $0x3,%cl
f0105b3b:	74 0d                	je     f0105b4a <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105b3d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105b40:	fc                   	cld    
f0105b41:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105b43:	89 f8                	mov    %edi,%eax
f0105b45:	5b                   	pop    %ebx
f0105b46:	5e                   	pop    %esi
f0105b47:	5f                   	pop    %edi
f0105b48:	5d                   	pop    %ebp
f0105b49:	c3                   	ret    
		c &= 0xFF;
f0105b4a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105b4e:	89 d3                	mov    %edx,%ebx
f0105b50:	c1 e3 08             	shl    $0x8,%ebx
f0105b53:	89 d0                	mov    %edx,%eax
f0105b55:	c1 e0 18             	shl    $0x18,%eax
f0105b58:	89 d6                	mov    %edx,%esi
f0105b5a:	c1 e6 10             	shl    $0x10,%esi
f0105b5d:	09 f0                	or     %esi,%eax
f0105b5f:	09 c2                	or     %eax,%edx
f0105b61:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0105b63:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0105b66:	89 d0                	mov    %edx,%eax
f0105b68:	fc                   	cld    
f0105b69:	f3 ab                	rep stos %eax,%es:(%edi)
f0105b6b:	eb d6                	jmp    f0105b43 <memset+0x23>

f0105b6d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105b6d:	55                   	push   %ebp
f0105b6e:	89 e5                	mov    %esp,%ebp
f0105b70:	57                   	push   %edi
f0105b71:	56                   	push   %esi
f0105b72:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b75:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105b78:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105b7b:	39 c6                	cmp    %eax,%esi
f0105b7d:	73 33                	jae    f0105bb2 <memmove+0x45>
f0105b7f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105b82:	39 c2                	cmp    %eax,%edx
f0105b84:	76 2c                	jbe    f0105bb2 <memmove+0x45>
		s += n;
		d += n;
f0105b86:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105b89:	89 d6                	mov    %edx,%esi
f0105b8b:	09 fe                	or     %edi,%esi
f0105b8d:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105b93:	74 0a                	je     f0105b9f <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105b95:	4f                   	dec    %edi
f0105b96:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0105b99:	fd                   	std    
f0105b9a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105b9c:	fc                   	cld    
f0105b9d:	eb 21                	jmp    f0105bc0 <memmove+0x53>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105b9f:	f6 c1 03             	test   $0x3,%cl
f0105ba2:	75 f1                	jne    f0105b95 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105ba4:	83 ef 04             	sub    $0x4,%edi
f0105ba7:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105baa:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0105bad:	fd                   	std    
f0105bae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105bb0:	eb ea                	jmp    f0105b9c <memmove+0x2f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105bb2:	89 f2                	mov    %esi,%edx
f0105bb4:	09 c2                	or     %eax,%edx
f0105bb6:	f6 c2 03             	test   $0x3,%dl
f0105bb9:	74 09                	je     f0105bc4 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105bbb:	89 c7                	mov    %eax,%edi
f0105bbd:	fc                   	cld    
f0105bbe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105bc0:	5e                   	pop    %esi
f0105bc1:	5f                   	pop    %edi
f0105bc2:	5d                   	pop    %ebp
f0105bc3:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105bc4:	f6 c1 03             	test   $0x3,%cl
f0105bc7:	75 f2                	jne    f0105bbb <memmove+0x4e>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105bc9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105bcc:	89 c7                	mov    %eax,%edi
f0105bce:	fc                   	cld    
f0105bcf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105bd1:	eb ed                	jmp    f0105bc0 <memmove+0x53>

f0105bd3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105bd3:	55                   	push   %ebp
f0105bd4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105bd6:	ff 75 10             	pushl  0x10(%ebp)
f0105bd9:	ff 75 0c             	pushl  0xc(%ebp)
f0105bdc:	ff 75 08             	pushl  0x8(%ebp)
f0105bdf:	e8 89 ff ff ff       	call   f0105b6d <memmove>
}
f0105be4:	c9                   	leave  
f0105be5:	c3                   	ret    

f0105be6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105be6:	55                   	push   %ebp
f0105be7:	89 e5                	mov    %esp,%ebp
f0105be9:	56                   	push   %esi
f0105bea:	53                   	push   %ebx
f0105beb:	8b 45 08             	mov    0x8(%ebp),%eax
f0105bee:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105bf1:	89 c6                	mov    %eax,%esi
f0105bf3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105bf6:	39 f0                	cmp    %esi,%eax
f0105bf8:	74 16                	je     f0105c10 <memcmp+0x2a>
		if (*s1 != *s2)
f0105bfa:	8a 08                	mov    (%eax),%cl
f0105bfc:	8a 1a                	mov    (%edx),%bl
f0105bfe:	38 d9                	cmp    %bl,%cl
f0105c00:	75 04                	jne    f0105c06 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0105c02:	40                   	inc    %eax
f0105c03:	42                   	inc    %edx
f0105c04:	eb f0                	jmp    f0105bf6 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0105c06:	0f b6 c1             	movzbl %cl,%eax
f0105c09:	0f b6 db             	movzbl %bl,%ebx
f0105c0c:	29 d8                	sub    %ebx,%eax
f0105c0e:	eb 05                	jmp    f0105c15 <memcmp+0x2f>
	}

	return 0;
f0105c10:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105c15:	5b                   	pop    %ebx
f0105c16:	5e                   	pop    %esi
f0105c17:	5d                   	pop    %ebp
f0105c18:	c3                   	ret    

f0105c19 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105c19:	55                   	push   %ebp
f0105c1a:	89 e5                	mov    %esp,%ebp
f0105c1c:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105c22:	89 c2                	mov    %eax,%edx
f0105c24:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105c27:	39 d0                	cmp    %edx,%eax
f0105c29:	73 07                	jae    f0105c32 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105c2b:	38 08                	cmp    %cl,(%eax)
f0105c2d:	74 03                	je     f0105c32 <memfind+0x19>
	for (; s < ends; s++)
f0105c2f:	40                   	inc    %eax
f0105c30:	eb f5                	jmp    f0105c27 <memfind+0xe>
			break;
	return (void *) s;
}
f0105c32:	5d                   	pop    %ebp
f0105c33:	c3                   	ret    

f0105c34 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105c34:	55                   	push   %ebp
f0105c35:	89 e5                	mov    %esp,%ebp
f0105c37:	57                   	push   %edi
f0105c38:	56                   	push   %esi
f0105c39:	53                   	push   %ebx
f0105c3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105c3d:	eb 01                	jmp    f0105c40 <strtol+0xc>
		s++;
f0105c3f:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f0105c40:	8a 01                	mov    (%ecx),%al
f0105c42:	3c 20                	cmp    $0x20,%al
f0105c44:	74 f9                	je     f0105c3f <strtol+0xb>
f0105c46:	3c 09                	cmp    $0x9,%al
f0105c48:	74 f5                	je     f0105c3f <strtol+0xb>

	// plus/minus sign
	if (*s == '+')
f0105c4a:	3c 2b                	cmp    $0x2b,%al
f0105c4c:	74 2b                	je     f0105c79 <strtol+0x45>
		s++;
	else if (*s == '-')
f0105c4e:	3c 2d                	cmp    $0x2d,%al
f0105c50:	74 2f                	je     f0105c81 <strtol+0x4d>
	int neg = 0;
f0105c52:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105c57:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f0105c5e:	75 12                	jne    f0105c72 <strtol+0x3e>
f0105c60:	80 39 30             	cmpb   $0x30,(%ecx)
f0105c63:	74 24                	je     f0105c89 <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105c65:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0105c69:	75 07                	jne    f0105c72 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105c6b:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f0105c72:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c77:	eb 4e                	jmp    f0105cc7 <strtol+0x93>
		s++;
f0105c79:	41                   	inc    %ecx
	int neg = 0;
f0105c7a:	bf 00 00 00 00       	mov    $0x0,%edi
f0105c7f:	eb d6                	jmp    f0105c57 <strtol+0x23>
		s++, neg = 1;
f0105c81:	41                   	inc    %ecx
f0105c82:	bf 01 00 00 00       	mov    $0x1,%edi
f0105c87:	eb ce                	jmp    f0105c57 <strtol+0x23>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105c89:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105c8d:	74 10                	je     f0105c9f <strtol+0x6b>
	else if (base == 0 && s[0] == '0')
f0105c8f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0105c93:	75 dd                	jne    f0105c72 <strtol+0x3e>
		s++, base = 8;
f0105c95:	41                   	inc    %ecx
f0105c96:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f0105c9d:	eb d3                	jmp    f0105c72 <strtol+0x3e>
		s += 2, base = 16;
f0105c9f:	83 c1 02             	add    $0x2,%ecx
f0105ca2:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f0105ca9:	eb c7                	jmp    f0105c72 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0105cab:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105cae:	89 f3                	mov    %esi,%ebx
f0105cb0:	80 fb 19             	cmp    $0x19,%bl
f0105cb3:	77 24                	ja     f0105cd9 <strtol+0xa5>
			dig = *s - 'a' + 10;
f0105cb5:	0f be d2             	movsbl %dl,%edx
f0105cb8:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105cbb:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105cbe:	7d 2b                	jge    f0105ceb <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
f0105cc0:	41                   	inc    %ecx
f0105cc1:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105cc5:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0105cc7:	8a 11                	mov    (%ecx),%dl
f0105cc9:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0105ccc:	80 fb 09             	cmp    $0x9,%bl
f0105ccf:	77 da                	ja     f0105cab <strtol+0x77>
			dig = *s - '0';
f0105cd1:	0f be d2             	movsbl %dl,%edx
f0105cd4:	83 ea 30             	sub    $0x30,%edx
f0105cd7:	eb e2                	jmp    f0105cbb <strtol+0x87>
		else if (*s >= 'A' && *s <= 'Z')
f0105cd9:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105cdc:	89 f3                	mov    %esi,%ebx
f0105cde:	80 fb 19             	cmp    $0x19,%bl
f0105ce1:	77 08                	ja     f0105ceb <strtol+0xb7>
			dig = *s - 'A' + 10;
f0105ce3:	0f be d2             	movsbl %dl,%edx
f0105ce6:	83 ea 37             	sub    $0x37,%edx
f0105ce9:	eb d0                	jmp    f0105cbb <strtol+0x87>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105ceb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105cef:	74 05                	je     f0105cf6 <strtol+0xc2>
		*endptr = (char *) s;
f0105cf1:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105cf4:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0105cf6:	85 ff                	test   %edi,%edi
f0105cf8:	74 02                	je     f0105cfc <strtol+0xc8>
f0105cfa:	f7 d8                	neg    %eax
}
f0105cfc:	5b                   	pop    %ebx
f0105cfd:	5e                   	pop    %esi
f0105cfe:	5f                   	pop    %edi
f0105cff:	5d                   	pop    %ebp
f0105d00:	c3                   	ret    

f0105d01 <strtoul>:

unsigned long
strtoul(const char *s, char **endptr, int base)
{
f0105d01:	55                   	push   %ebp
f0105d02:	89 e5                	mov    %esp,%ebp
f0105d04:	57                   	push   %edi
f0105d05:	56                   	push   %esi
f0105d06:	53                   	push   %ebx
f0105d07:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	unsigned long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105d0a:	eb 01                	jmp    f0105d0d <strtoul+0xc>
		s++;
f0105d0c:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f0105d0d:	8a 01                	mov    (%ecx),%al
f0105d0f:	3c 20                	cmp    $0x20,%al
f0105d11:	74 f9                	je     f0105d0c <strtoul+0xb>
f0105d13:	3c 09                	cmp    $0x9,%al
f0105d15:	74 f5                	je     f0105d0c <strtoul+0xb>

	// plus/minus sign
	if (*s == '+')
f0105d17:	3c 2b                	cmp    $0x2b,%al
f0105d19:	74 2b                	je     f0105d46 <strtoul+0x45>
		s++;
	else if (*s == '-')
f0105d1b:	3c 2d                	cmp    $0x2d,%al
f0105d1d:	74 2f                	je     f0105d4e <strtoul+0x4d>
	int neg = 0;
f0105d1f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105d24:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f0105d2b:	75 12                	jne    f0105d3f <strtoul+0x3e>
f0105d2d:	80 39 30             	cmpb   $0x30,(%ecx)
f0105d30:	74 24                	je     f0105d56 <strtoul+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105d32:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0105d36:	75 07                	jne    f0105d3f <strtoul+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105d38:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f0105d3f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d44:	eb 4e                	jmp    f0105d94 <strtoul+0x93>
		s++;
f0105d46:	41                   	inc    %ecx
	int neg = 0;
f0105d47:	bf 00 00 00 00       	mov    $0x0,%edi
f0105d4c:	eb d6                	jmp    f0105d24 <strtoul+0x23>
		s++, neg = 1;
f0105d4e:	41                   	inc    %ecx
f0105d4f:	bf 01 00 00 00       	mov    $0x1,%edi
f0105d54:	eb ce                	jmp    f0105d24 <strtoul+0x23>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105d56:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105d5a:	74 10                	je     f0105d6c <strtoul+0x6b>
	else if (base == 0 && s[0] == '0')
f0105d5c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0105d60:	75 dd                	jne    f0105d3f <strtoul+0x3e>
		s++, base = 8;
f0105d62:	41                   	inc    %ecx
f0105d63:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f0105d6a:	eb d3                	jmp    f0105d3f <strtoul+0x3e>
		s += 2, base = 16;
f0105d6c:	83 c1 02             	add    $0x2,%ecx
f0105d6f:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f0105d76:	eb c7                	jmp    f0105d3f <strtoul+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0105d78:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105d7b:	89 f3                	mov    %esi,%ebx
f0105d7d:	80 fb 19             	cmp    $0x19,%bl
f0105d80:	77 24                	ja     f0105da6 <strtoul+0xa5>
			dig = *s - 'a' + 10;
f0105d82:	0f be d2             	movsbl %dl,%edx
f0105d85:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105d88:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105d8b:	7d 2b                	jge    f0105db8 <strtoul+0xb7>
			break;
		s++, val = (val * base) + dig;
f0105d8d:	41                   	inc    %ecx
f0105d8e:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105d92:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0105d94:	8a 11                	mov    (%ecx),%dl
f0105d96:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0105d99:	80 fb 09             	cmp    $0x9,%bl
f0105d9c:	77 da                	ja     f0105d78 <strtoul+0x77>
			dig = *s - '0';
f0105d9e:	0f be d2             	movsbl %dl,%edx
f0105da1:	83 ea 30             	sub    $0x30,%edx
f0105da4:	eb e2                	jmp    f0105d88 <strtoul+0x87>
		else if (*s >= 'A' && *s <= 'Z')
f0105da6:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105da9:	89 f3                	mov    %esi,%ebx
f0105dab:	80 fb 19             	cmp    $0x19,%bl
f0105dae:	77 08                	ja     f0105db8 <strtoul+0xb7>
			dig = *s - 'A' + 10;
f0105db0:	0f be d2             	movsbl %dl,%edx
f0105db3:	83 ea 37             	sub    $0x37,%edx
f0105db6:	eb d0                	jmp    f0105d88 <strtoul+0x87>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105db8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105dbc:	74 05                	je     f0105dc3 <strtoul+0xc2>
		*endptr = (char *) s;
f0105dbe:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105dc1:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0105dc3:	85 ff                	test   %edi,%edi
f0105dc5:	74 02                	je     f0105dc9 <strtoul+0xc8>
f0105dc7:	f7 d8                	neg    %eax
}
f0105dc9:	5b                   	pop    %ebx
f0105dca:	5e                   	pop    %esi
f0105dcb:	5f                   	pop    %edi
f0105dcc:	5d                   	pop    %ebp
f0105dcd:	c3                   	ret    
f0105dce:	66 90                	xchg   %ax,%ax

f0105dd0 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105dd0:	fa                   	cli    

	xorw    %ax, %ax
f0105dd1:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105dd3:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105dd5:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105dd7:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105dd9:	0f 01 16             	lgdtl  (%esi)
f0105ddc:	74 70                	je     f0105e4e <mpsearch1+0x3>
	movl    %cr0, %eax
f0105dde:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105de1:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105de5:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105de8:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105dee:	08 00                	or     %al,(%eax)

f0105df0 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105df0:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105df4:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105df6:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105df8:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105dfa:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105dfe:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105e00:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105e02:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f0105e07:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105e0a:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105e0d:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105e12:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105e15:	8b 25 84 6e 29 f0    	mov    0xf0296e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105e1b:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105e20:	b8 8d 02 10 f0       	mov    $0xf010028d,%eax
	call    *%eax
f0105e25:	ff d0                	call   *%eax

f0105e27 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105e27:	eb fe                	jmp    f0105e27 <spin>
f0105e29:	8d 76 00             	lea    0x0(%esi),%esi

f0105e2c <gdt>:
	...
f0105e34:	ff                   	(bad)  
f0105e35:	ff 00                	incl   (%eax)
f0105e37:	00 00                	add    %al,(%eax)
f0105e39:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105e40:	00                   	.byte 0x0
f0105e41:	92                   	xchg   %eax,%edx
f0105e42:	cf                   	iret   
	...

f0105e44 <gdtdesc>:
f0105e44:	17                   	pop    %ss
f0105e45:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105e4a <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105e4a:	90                   	nop

f0105e4b <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105e4b:	55                   	push   %ebp
f0105e4c:	89 e5                	mov    %esp,%ebp
f0105e4e:	57                   	push   %edi
f0105e4f:	56                   	push   %esi
f0105e50:	53                   	push   %ebx
f0105e51:	83 ec 0c             	sub    $0xc,%esp
	if (PGNUM(pa) >= npages)
f0105e54:	8b 0d 88 6e 29 f0    	mov    0xf0296e88,%ecx
f0105e5a:	89 c3                	mov    %eax,%ebx
f0105e5c:	c1 eb 0c             	shr    $0xc,%ebx
f0105e5f:	39 cb                	cmp    %ecx,%ebx
f0105e61:	73 1a                	jae    f0105e7d <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f0105e63:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105e69:	8d 34 02             	lea    (%edx,%eax,1),%esi
	if (PGNUM(pa) >= npages)
f0105e6c:	89 f0                	mov    %esi,%eax
f0105e6e:	c1 e8 0c             	shr    $0xc,%eax
f0105e71:	39 c8                	cmp    %ecx,%eax
f0105e73:	73 1a                	jae    f0105e8f <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f0105e75:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0105e7b:	eb 27                	jmp    f0105ea4 <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105e7d:	50                   	push   %eax
f0105e7e:	68 88 69 10 f0       	push   $0xf0106988
f0105e83:	6a 57                	push   $0x57
f0105e85:	68 81 87 10 f0       	push   $0xf0108781
f0105e8a:	e8 05 a2 ff ff       	call   f0100094 <_panic>
f0105e8f:	56                   	push   %esi
f0105e90:	68 88 69 10 f0       	push   $0xf0106988
f0105e95:	6a 57                	push   $0x57
f0105e97:	68 81 87 10 f0       	push   $0xf0108781
f0105e9c:	e8 f3 a1 ff ff       	call   f0100094 <_panic>
f0105ea1:	83 c3 10             	add    $0x10,%ebx
f0105ea4:	39 f3                	cmp    %esi,%ebx
f0105ea6:	73 2c                	jae    f0105ed4 <mpsearch1+0x89>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105ea8:	83 ec 04             	sub    $0x4,%esp
f0105eab:	6a 04                	push   $0x4
f0105ead:	68 91 87 10 f0       	push   $0xf0108791
f0105eb2:	53                   	push   %ebx
f0105eb3:	e8 2e fd ff ff       	call   f0105be6 <memcmp>
f0105eb8:	83 c4 10             	add    $0x10,%esp
f0105ebb:	85 c0                	test   %eax,%eax
f0105ebd:	75 e2                	jne    f0105ea1 <mpsearch1+0x56>
f0105ebf:	89 da                	mov    %ebx,%edx
f0105ec1:	8d 7b 10             	lea    0x10(%ebx),%edi
		sum += ((uint8_t *)addr)[i];
f0105ec4:	0f b6 0a             	movzbl (%edx),%ecx
f0105ec7:	01 c8                	add    %ecx,%eax
f0105ec9:	42                   	inc    %edx
	for (i = 0; i < len; i++)
f0105eca:	39 fa                	cmp    %edi,%edx
f0105ecc:	75 f6                	jne    f0105ec4 <mpsearch1+0x79>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105ece:	84 c0                	test   %al,%al
f0105ed0:	75 cf                	jne    f0105ea1 <mpsearch1+0x56>
f0105ed2:	eb 05                	jmp    f0105ed9 <mpsearch1+0x8e>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105ed4:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0105ed9:	89 d8                	mov    %ebx,%eax
f0105edb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105ede:	5b                   	pop    %ebx
f0105edf:	5e                   	pop    %esi
f0105ee0:	5f                   	pop    %edi
f0105ee1:	5d                   	pop    %ebp
f0105ee2:	c3                   	ret    

f0105ee3 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105ee3:	55                   	push   %ebp
f0105ee4:	89 e5                	mov    %esp,%ebp
f0105ee6:	57                   	push   %edi
f0105ee7:	56                   	push   %esi
f0105ee8:	53                   	push   %ebx
f0105ee9:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105eec:	c7 05 c0 73 29 f0 20 	movl   $0xf0297020,0xf02973c0
f0105ef3:	70 29 f0 
	if (PGNUM(pa) >= npages)
f0105ef6:	83 3d 88 6e 29 f0 00 	cmpl   $0x0,0xf0296e88
f0105efd:	0f 84 84 00 00 00    	je     f0105f87 <mp_init+0xa4>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105f03:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105f0a:	85 c0                	test   %eax,%eax
f0105f0c:	0f 84 8b 00 00 00    	je     f0105f9d <mp_init+0xba>
		p <<= 4;	// Translate from segment to PA
f0105f12:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105f15:	ba 00 04 00 00       	mov    $0x400,%edx
f0105f1a:	e8 2c ff ff ff       	call   f0105e4b <mpsearch1>
f0105f1f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105f22:	85 c0                	test   %eax,%eax
f0105f24:	0f 84 97 00 00 00    	je     f0105fc1 <mp_init+0xde>
	if (mp->physaddr == 0 || mp->type != 0) {
f0105f2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105f2d:	8b 70 04             	mov    0x4(%eax),%esi
f0105f30:	85 f6                	test   %esi,%esi
f0105f32:	0f 84 a8 00 00 00    	je     f0105fe0 <mp_init+0xfd>
f0105f38:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105f3c:	0f 85 9e 00 00 00    	jne    f0105fe0 <mp_init+0xfd>
f0105f42:	89 f0                	mov    %esi,%eax
f0105f44:	c1 e8 0c             	shr    $0xc,%eax
f0105f47:	3b 05 88 6e 29 f0    	cmp    0xf0296e88,%eax
f0105f4d:	0f 83 a2 00 00 00    	jae    f0105ff5 <mp_init+0x112>
	return (void *)(pa + KERNBASE);
f0105f53:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
f0105f59:	89 df                	mov    %ebx,%edi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105f5b:	83 ec 04             	sub    $0x4,%esp
f0105f5e:	6a 04                	push   $0x4
f0105f60:	68 96 87 10 f0       	push   $0xf0108796
f0105f65:	53                   	push   %ebx
f0105f66:	e8 7b fc ff ff       	call   f0105be6 <memcmp>
f0105f6b:	83 c4 10             	add    $0x10,%esp
f0105f6e:	85 c0                	test   %eax,%eax
f0105f70:	0f 85 94 00 00 00    	jne    f010600a <mp_init+0x127>
f0105f76:	0f b7 53 04          	movzwl 0x4(%ebx),%edx
f0105f7a:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
f0105f7d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	sum = 0;
f0105f80:	89 c2                	mov    %eax,%edx
f0105f82:	e9 9e 00 00 00       	jmp    f0106025 <mp_init+0x142>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105f87:	68 00 04 00 00       	push   $0x400
f0105f8c:	68 88 69 10 f0       	push   $0xf0106988
f0105f91:	6a 6f                	push   $0x6f
f0105f93:	68 81 87 10 f0       	push   $0xf0108781
f0105f98:	e8 f7 a0 ff ff       	call   f0100094 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105f9d:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105fa4:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105fa7:	2d 00 04 00 00       	sub    $0x400,%eax
f0105fac:	ba 00 04 00 00       	mov    $0x400,%edx
f0105fb1:	e8 95 fe ff ff       	call   f0105e4b <mpsearch1>
f0105fb6:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105fb9:	85 c0                	test   %eax,%eax
f0105fbb:	0f 85 69 ff ff ff    	jne    f0105f2a <mp_init+0x47>
	return mpsearch1(0xF0000, 0x10000);
f0105fc1:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105fc6:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105fcb:	e8 7b fe ff ff       	call   f0105e4b <mpsearch1>
f0105fd0:	89 45 e0             	mov    %eax,-0x20(%ebp)
	if ((mp = mpsearch()) == 0)
f0105fd3:	85 c0                	test   %eax,%eax
f0105fd5:	0f 85 4f ff ff ff    	jne    f0105f2a <mp_init+0x47>
f0105fdb:	e9 b3 01 00 00       	jmp    f0106193 <mp_init+0x2b0>
		cprintf("SMP: Default configurations not implemented\n");
f0105fe0:	83 ec 0c             	sub    $0xc,%esp
f0105fe3:	68 f4 85 10 f0       	push   $0xf01085f4
f0105fe8:	e8 a6 df ff ff       	call   f0103f93 <cprintf>
f0105fed:	83 c4 10             	add    $0x10,%esp
f0105ff0:	e9 9e 01 00 00       	jmp    f0106193 <mp_init+0x2b0>
f0105ff5:	56                   	push   %esi
f0105ff6:	68 88 69 10 f0       	push   $0xf0106988
f0105ffb:	68 90 00 00 00       	push   $0x90
f0106000:	68 81 87 10 f0       	push   $0xf0108781
f0106005:	e8 8a a0 ff ff       	call   f0100094 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f010600a:	83 ec 0c             	sub    $0xc,%esp
f010600d:	68 24 86 10 f0       	push   $0xf0108624
f0106012:	e8 7c df ff ff       	call   f0103f93 <cprintf>
f0106017:	83 c4 10             	add    $0x10,%esp
f010601a:	e9 74 01 00 00       	jmp    f0106193 <mp_init+0x2b0>
		sum += ((uint8_t *)addr)[i];
f010601f:	0f b6 0b             	movzbl (%ebx),%ecx
f0106022:	01 ca                	add    %ecx,%edx
f0106024:	43                   	inc    %ebx
	for (i = 0; i < len; i++)
f0106025:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0106028:	75 f5                	jne    f010601f <mp_init+0x13c>
	if (sum(conf, conf->length) != 0) {
f010602a:	84 d2                	test   %dl,%dl
f010602c:	75 15                	jne    f0106043 <mp_init+0x160>
	if (conf->version != 1 && conf->version != 4) {
f010602e:	8a 57 06             	mov    0x6(%edi),%dl
f0106031:	80 fa 01             	cmp    $0x1,%dl
f0106034:	74 05                	je     f010603b <mp_init+0x158>
f0106036:	80 fa 04             	cmp    $0x4,%dl
f0106039:	75 1d                	jne    f0106058 <mp_init+0x175>
f010603b:	0f b7 4f 28          	movzwl 0x28(%edi),%ecx
f010603f:	01 d9                	add    %ebx,%ecx
f0106041:	eb 34                	jmp    f0106077 <mp_init+0x194>
		cprintf("SMP: Bad MP configuration checksum\n");
f0106043:	83 ec 0c             	sub    $0xc,%esp
f0106046:	68 58 86 10 f0       	push   $0xf0108658
f010604b:	e8 43 df ff ff       	call   f0103f93 <cprintf>
f0106050:	83 c4 10             	add    $0x10,%esp
f0106053:	e9 3b 01 00 00       	jmp    f0106193 <mp_init+0x2b0>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106058:	83 ec 08             	sub    $0x8,%esp
f010605b:	0f b6 d2             	movzbl %dl,%edx
f010605e:	52                   	push   %edx
f010605f:	68 7c 86 10 f0       	push   $0xf010867c
f0106064:	e8 2a df ff ff       	call   f0103f93 <cprintf>
f0106069:	83 c4 10             	add    $0x10,%esp
f010606c:	e9 22 01 00 00       	jmp    f0106193 <mp_init+0x2b0>
		sum += ((uint8_t *)addr)[i];
f0106071:	0f b6 13             	movzbl (%ebx),%edx
f0106074:	01 d0                	add    %edx,%eax
f0106076:	43                   	inc    %ebx
	for (i = 0; i < len; i++)
f0106077:	39 d9                	cmp    %ebx,%ecx
f0106079:	75 f6                	jne    f0106071 <mp_init+0x18e>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010607b:	02 47 2a             	add    0x2a(%edi),%al
f010607e:	75 28                	jne    f01060a8 <mp_init+0x1c5>
	if ((conf = mpconfig(&mp)) == 0)
f0106080:	81 fe 00 00 00 10    	cmp    $0x10000000,%esi
f0106086:	0f 84 07 01 00 00    	je     f0106193 <mp_init+0x2b0>
		return;
	ismp = 1;
f010608c:	c7 05 00 70 29 f0 01 	movl   $0x1,0xf0297000
f0106093:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0106096:	8b 47 24             	mov    0x24(%edi),%eax
f0106099:	a3 00 80 2d f0       	mov    %eax,0xf02d8000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010609e:	8d 77 2c             	lea    0x2c(%edi),%esi
f01060a1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01060a6:	eb 60                	jmp    f0106108 <mp_init+0x225>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01060a8:	83 ec 0c             	sub    $0xc,%esp
f01060ab:	68 9c 86 10 f0       	push   $0xf010869c
f01060b0:	e8 de de ff ff       	call   f0103f93 <cprintf>
f01060b5:	83 c4 10             	add    $0x10,%esp
f01060b8:	e9 d6 00 00 00       	jmp    f0106193 <mp_init+0x2b0>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01060bd:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f01060c1:	74 1e                	je     f01060e1 <mp_init+0x1fe>
				bootcpu = &cpus[ncpu];
f01060c3:	8b 15 c4 73 29 f0    	mov    0xf02973c4,%edx
f01060c9:	8d 04 12             	lea    (%edx,%edx,1),%eax
f01060cc:	01 d0                	add    %edx,%eax
f01060ce:	01 c0                	add    %eax,%eax
f01060d0:	01 d0                	add    %edx,%eax
f01060d2:	8d 04 82             	lea    (%edx,%eax,4),%eax
f01060d5:	8d 04 85 20 70 29 f0 	lea    -0xfd68fe0(,%eax,4),%eax
f01060dc:	a3 c0 73 29 f0       	mov    %eax,0xf02973c0
			if (ncpu < NCPU) {
f01060e1:	a1 c4 73 29 f0       	mov    0xf02973c4,%eax
f01060e6:	83 f8 07             	cmp    $0x7,%eax
f01060e9:	7f 34                	jg     f010611f <mp_init+0x23c>
				cpus[ncpu].cpu_id = ncpu;
f01060eb:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01060ee:	01 c2                	add    %eax,%edx
f01060f0:	01 d2                	add    %edx,%edx
f01060f2:	01 c2                	add    %eax,%edx
f01060f4:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01060f7:	88 04 95 20 70 29 f0 	mov    %al,-0xfd68fe0(,%edx,4)
				ncpu++;
f01060fe:	40                   	inc    %eax
f01060ff:	a3 c4 73 29 f0       	mov    %eax,0xf02973c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106104:	83 c6 14             	add    $0x14,%esi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106107:	43                   	inc    %ebx
f0106108:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f010610c:	39 d8                	cmp    %ebx,%eax
f010610e:	76 4a                	jbe    f010615a <mp_init+0x277>
		switch (*p) {
f0106110:	8a 06                	mov    (%esi),%al
f0106112:	84 c0                	test   %al,%al
f0106114:	74 a7                	je     f01060bd <mp_init+0x1da>
f0106116:	3c 04                	cmp    $0x4,%al
f0106118:	77 1c                	ja     f0106136 <mp_init+0x253>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f010611a:	83 c6 08             	add    $0x8,%esi
			continue;
f010611d:	eb e8                	jmp    f0106107 <mp_init+0x224>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010611f:	83 ec 08             	sub    $0x8,%esp
f0106122:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0106126:	50                   	push   %eax
f0106127:	68 cc 86 10 f0       	push   $0xf01086cc
f010612c:	e8 62 de ff ff       	call   f0103f93 <cprintf>
f0106131:	83 c4 10             	add    $0x10,%esp
f0106134:	eb ce                	jmp    f0106104 <mp_init+0x221>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106136:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0106139:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f010613c:	50                   	push   %eax
f010613d:	68 f4 86 10 f0       	push   $0xf01086f4
f0106142:	e8 4c de ff ff       	call   f0103f93 <cprintf>
			ismp = 0;
f0106147:	c7 05 00 70 29 f0 00 	movl   $0x0,0xf0297000
f010614e:	00 00 00 
			i = conf->entry;
f0106151:	0f b7 5f 22          	movzwl 0x22(%edi),%ebx
f0106155:	83 c4 10             	add    $0x10,%esp
f0106158:	eb ad                	jmp    f0106107 <mp_init+0x224>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010615a:	a1 c0 73 29 f0       	mov    0xf02973c0,%eax
f010615f:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106166:	83 3d 00 70 29 f0 00 	cmpl   $0x0,0xf0297000
f010616d:	75 2c                	jne    f010619b <mp_init+0x2b8>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f010616f:	c7 05 c4 73 29 f0 01 	movl   $0x1,0xf02973c4
f0106176:	00 00 00 
		lapicaddr = 0;
f0106179:	c7 05 00 80 2d f0 00 	movl   $0x0,0xf02d8000
f0106180:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106183:	83 ec 0c             	sub    $0xc,%esp
f0106186:	68 14 87 10 f0       	push   $0xf0108714
f010618b:	e8 03 de ff ff       	call   f0103f93 <cprintf>
		return;
f0106190:	83 c4 10             	add    $0x10,%esp
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0106193:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106196:	5b                   	pop    %ebx
f0106197:	5e                   	pop    %esi
f0106198:	5f                   	pop    %edi
f0106199:	5d                   	pop    %ebp
f010619a:	c3                   	ret    
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010619b:	83 ec 04             	sub    $0x4,%esp
f010619e:	ff 35 c4 73 29 f0    	pushl  0xf02973c4
f01061a4:	0f b6 00             	movzbl (%eax),%eax
f01061a7:	50                   	push   %eax
f01061a8:	68 9b 87 10 f0       	push   $0xf010879b
f01061ad:	e8 e1 dd ff ff       	call   f0103f93 <cprintf>
	if (mp->imcrp) {
f01061b2:	83 c4 10             	add    $0x10,%esp
f01061b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01061b8:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01061bc:	74 d5                	je     f0106193 <mp_init+0x2b0>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01061be:	83 ec 0c             	sub    $0xc,%esp
f01061c1:	68 40 87 10 f0       	push   $0xf0108740
f01061c6:	e8 c8 dd ff ff       	call   f0103f93 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01061cb:	b0 70                	mov    $0x70,%al
f01061cd:	ba 22 00 00 00       	mov    $0x22,%edx
f01061d2:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01061d3:	ba 23 00 00 00       	mov    $0x23,%edx
f01061d8:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f01061d9:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01061dc:	ee                   	out    %al,(%dx)
f01061dd:	83 c4 10             	add    $0x10,%esp
f01061e0:	eb b1                	jmp    f0106193 <mp_init+0x2b0>

f01061e2 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f01061e2:	55                   	push   %ebp
f01061e3:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01061e5:	8b 0d 04 80 2d f0    	mov    0xf02d8004,%ecx
f01061eb:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01061ee:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01061f0:	a1 04 80 2d f0       	mov    0xf02d8004,%eax
f01061f5:	8b 40 20             	mov    0x20(%eax),%eax
}
f01061f8:	5d                   	pop    %ebp
f01061f9:	c3                   	ret    

f01061fa <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f01061fa:	55                   	push   %ebp
f01061fb:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01061fd:	a1 04 80 2d f0       	mov    0xf02d8004,%eax
f0106202:	85 c0                	test   %eax,%eax
f0106204:	74 08                	je     f010620e <cpunum+0x14>
		return lapic[ID] >> 24;
f0106206:	8b 40 20             	mov    0x20(%eax),%eax
f0106209:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f010620c:	5d                   	pop    %ebp
f010620d:	c3                   	ret    
	return 0;
f010620e:	b8 00 00 00 00       	mov    $0x0,%eax
f0106213:	eb f7                	jmp    f010620c <cpunum+0x12>

f0106215 <lapic_init>:
	if (!lapicaddr)
f0106215:	a1 00 80 2d f0       	mov    0xf02d8000,%eax
f010621a:	85 c0                	test   %eax,%eax
f010621c:	75 01                	jne    f010621f <lapic_init+0xa>
f010621e:	c3                   	ret    
{
f010621f:	55                   	push   %ebp
f0106220:	89 e5                	mov    %esp,%ebp
f0106222:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0106225:	68 00 10 00 00       	push   $0x1000
f010622a:	50                   	push   %eax
f010622b:	e8 58 b5 ff ff       	call   f0101788 <mmio_map_region>
f0106230:	a3 04 80 2d f0       	mov    %eax,0xf02d8004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106235:	ba 27 01 00 00       	mov    $0x127,%edx
f010623a:	b8 3c 00 00 00       	mov    $0x3c,%eax
f010623f:	e8 9e ff ff ff       	call   f01061e2 <lapicw>
	lapicw(TDCR, X1);
f0106244:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106249:	b8 f8 00 00 00       	mov    $0xf8,%eax
f010624e:	e8 8f ff ff ff       	call   f01061e2 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106253:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106258:	b8 c8 00 00 00       	mov    $0xc8,%eax
f010625d:	e8 80 ff ff ff       	call   f01061e2 <lapicw>
	lapicw(TICR, 10000000); 
f0106262:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106267:	b8 e0 00 00 00       	mov    $0xe0,%eax
f010626c:	e8 71 ff ff ff       	call   f01061e2 <lapicw>
	if (thiscpu != bootcpu)
f0106271:	e8 84 ff ff ff       	call   f01061fa <cpunum>
f0106276:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0106279:	01 c2                	add    %eax,%edx
f010627b:	01 d2                	add    %edx,%edx
f010627d:	01 c2                	add    %eax,%edx
f010627f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106282:	8d 04 85 20 70 29 f0 	lea    -0xfd68fe0(,%eax,4),%eax
f0106289:	83 c4 10             	add    $0x10,%esp
f010628c:	39 05 c0 73 29 f0    	cmp    %eax,0xf02973c0
f0106292:	74 0f                	je     f01062a3 <lapic_init+0x8e>
		lapicw(LINT0, MASKED);
f0106294:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106299:	b8 d4 00 00 00       	mov    $0xd4,%eax
f010629e:	e8 3f ff ff ff       	call   f01061e2 <lapicw>
	lapicw(LINT1, MASKED);
f01062a3:	ba 00 00 01 00       	mov    $0x10000,%edx
f01062a8:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01062ad:	e8 30 ff ff ff       	call   f01061e2 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01062b2:	a1 04 80 2d f0       	mov    0xf02d8004,%eax
f01062b7:	8b 40 30             	mov    0x30(%eax),%eax
f01062ba:	c1 e8 10             	shr    $0x10,%eax
f01062bd:	3c 03                	cmp    $0x3,%al
f01062bf:	77 7c                	ja     f010633d <lapic_init+0x128>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01062c1:	ba 33 00 00 00       	mov    $0x33,%edx
f01062c6:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01062cb:	e8 12 ff ff ff       	call   f01061e2 <lapicw>
	lapicw(ESR, 0);
f01062d0:	ba 00 00 00 00       	mov    $0x0,%edx
f01062d5:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01062da:	e8 03 ff ff ff       	call   f01061e2 <lapicw>
	lapicw(ESR, 0);
f01062df:	ba 00 00 00 00       	mov    $0x0,%edx
f01062e4:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01062e9:	e8 f4 fe ff ff       	call   f01061e2 <lapicw>
	lapicw(EOI, 0);
f01062ee:	ba 00 00 00 00       	mov    $0x0,%edx
f01062f3:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01062f8:	e8 e5 fe ff ff       	call   f01061e2 <lapicw>
	lapicw(ICRHI, 0);
f01062fd:	ba 00 00 00 00       	mov    $0x0,%edx
f0106302:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106307:	e8 d6 fe ff ff       	call   f01061e2 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010630c:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106311:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106316:	e8 c7 fe ff ff       	call   f01061e2 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f010631b:	8b 15 04 80 2d f0    	mov    0xf02d8004,%edx
f0106321:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106327:	f6 c4 10             	test   $0x10,%ah
f010632a:	75 f5                	jne    f0106321 <lapic_init+0x10c>
	lapicw(TPR, 0);
f010632c:	ba 00 00 00 00       	mov    $0x0,%edx
f0106331:	b8 20 00 00 00       	mov    $0x20,%eax
f0106336:	e8 a7 fe ff ff       	call   f01061e2 <lapicw>
}
f010633b:	c9                   	leave  
f010633c:	c3                   	ret    
		lapicw(PCINT, MASKED);
f010633d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106342:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106347:	e8 96 fe ff ff       	call   f01061e2 <lapicw>
f010634c:	e9 70 ff ff ff       	jmp    f01062c1 <lapic_init+0xac>

f0106351 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0106351:	83 3d 04 80 2d f0 00 	cmpl   $0x0,0xf02d8004
f0106358:	74 14                	je     f010636e <lapic_eoi+0x1d>
{
f010635a:	55                   	push   %ebp
f010635b:	89 e5                	mov    %esp,%ebp
		lapicw(EOI, 0);
f010635d:	ba 00 00 00 00       	mov    $0x0,%edx
f0106362:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106367:	e8 76 fe ff ff       	call   f01061e2 <lapicw>
}
f010636c:	5d                   	pop    %ebp
f010636d:	c3                   	ret    
f010636e:	c3                   	ret    

f010636f <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f010636f:	55                   	push   %ebp
f0106370:	89 e5                	mov    %esp,%ebp
f0106372:	56                   	push   %esi
f0106373:	53                   	push   %ebx
f0106374:	8b 75 08             	mov    0x8(%ebp),%esi
f0106377:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010637a:	b0 0f                	mov    $0xf,%al
f010637c:	ba 70 00 00 00       	mov    $0x70,%edx
f0106381:	ee                   	out    %al,(%dx)
f0106382:	b0 0a                	mov    $0xa,%al
f0106384:	ba 71 00 00 00       	mov    $0x71,%edx
f0106389:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f010638a:	83 3d 88 6e 29 f0 00 	cmpl   $0x0,0xf0296e88
f0106391:	74 7e                	je     f0106411 <lapic_startap+0xa2>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106393:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f010639a:	00 00 
	wrv[1] = addr >> 4;
f010639c:	89 d8                	mov    %ebx,%eax
f010639e:	c1 e8 04             	shr    $0x4,%eax
f01063a1:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01063a7:	c1 e6 18             	shl    $0x18,%esi
f01063aa:	89 f2                	mov    %esi,%edx
f01063ac:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01063b1:	e8 2c fe ff ff       	call   f01061e2 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01063b6:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01063bb:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01063c0:	e8 1d fe ff ff       	call   f01061e2 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01063c5:	ba 00 85 00 00       	mov    $0x8500,%edx
f01063ca:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01063cf:	e8 0e fe ff ff       	call   f01061e2 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01063d4:	c1 eb 0c             	shr    $0xc,%ebx
f01063d7:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f01063da:	89 f2                	mov    %esi,%edx
f01063dc:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01063e1:	e8 fc fd ff ff       	call   f01061e2 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01063e6:	89 da                	mov    %ebx,%edx
f01063e8:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01063ed:	e8 f0 fd ff ff       	call   f01061e2 <lapicw>
		lapicw(ICRHI, apicid << 24);
f01063f2:	89 f2                	mov    %esi,%edx
f01063f4:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01063f9:	e8 e4 fd ff ff       	call   f01061e2 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01063fe:	89 da                	mov    %ebx,%edx
f0106400:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106405:	e8 d8 fd ff ff       	call   f01061e2 <lapicw>
		microdelay(200);
	}
}
f010640a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010640d:	5b                   	pop    %ebx
f010640e:	5e                   	pop    %esi
f010640f:	5d                   	pop    %ebp
f0106410:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106411:	68 67 04 00 00       	push   $0x467
f0106416:	68 88 69 10 f0       	push   $0xf0106988
f010641b:	68 98 00 00 00       	push   $0x98
f0106420:	68 b8 87 10 f0       	push   $0xf01087b8
f0106425:	e8 6a 9c ff ff       	call   f0100094 <_panic>

f010642a <lapic_ipi>:

void
lapic_ipi(int vector)
{
f010642a:	55                   	push   %ebp
f010642b:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f010642d:	8b 55 08             	mov    0x8(%ebp),%edx
f0106430:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106436:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010643b:	e8 a2 fd ff ff       	call   f01061e2 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106440:	8b 15 04 80 2d f0    	mov    0xf02d8004,%edx
f0106446:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010644c:	f6 c4 10             	test   $0x10,%ah
f010644f:	75 f5                	jne    f0106446 <lapic_ipi+0x1c>
		;
}
f0106451:	5d                   	pop    %ebp
f0106452:	c3                   	ret    

f0106453 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106453:	55                   	push   %ebp
f0106454:	89 e5                	mov    %esp,%ebp
f0106456:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106459:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f010645f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106462:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106465:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f010646c:	5d                   	pop    %ebp
f010646d:	c3                   	ret    

f010646e <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f010646e:	55                   	push   %ebp
f010646f:	89 e5                	mov    %esp,%ebp
f0106471:	56                   	push   %esi
f0106472:	53                   	push   %ebx
f0106473:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f0106476:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106479:	75 07                	jne    f0106482 <spin_lock+0x14>
	asm volatile("lock; xchgl %0, %1"
f010647b:	ba 01 00 00 00       	mov    $0x1,%edx
f0106480:	eb 3f                	jmp    f01064c1 <spin_lock+0x53>
f0106482:	8b 73 08             	mov    0x8(%ebx),%esi
f0106485:	e8 70 fd ff ff       	call   f01061fa <cpunum>
f010648a:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010648d:	01 c2                	add    %eax,%edx
f010648f:	01 d2                	add    %edx,%edx
f0106491:	01 c2                	add    %eax,%edx
f0106493:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106496:	8d 04 85 20 70 29 f0 	lea    -0xfd68fe0(,%eax,4),%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f010649d:	39 c6                	cmp    %eax,%esi
f010649f:	75 da                	jne    f010647b <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01064a1:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01064a4:	e8 51 fd ff ff       	call   f01061fa <cpunum>
f01064a9:	83 ec 0c             	sub    $0xc,%esp
f01064ac:	53                   	push   %ebx
f01064ad:	50                   	push   %eax
f01064ae:	68 c8 87 10 f0       	push   $0xf01087c8
f01064b3:	6a 41                	push   $0x41
f01064b5:	68 2c 88 10 f0       	push   $0xf010882c
f01064ba:	e8 d5 9b ff ff       	call   f0100094 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01064bf:	f3 90                	pause  
f01064c1:	89 d0                	mov    %edx,%eax
f01064c3:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f01064c6:	85 c0                	test   %eax,%eax
f01064c8:	75 f5                	jne    f01064bf <spin_lock+0x51>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01064ca:	e8 2b fd ff ff       	call   f01061fa <cpunum>
f01064cf:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01064d2:	01 c2                	add    %eax,%edx
f01064d4:	01 d2                	add    %edx,%edx
f01064d6:	01 c2                	add    %eax,%edx
f01064d8:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01064db:	8d 04 85 20 70 29 f0 	lea    -0xfd68fe0(,%eax,4),%eax
f01064e2:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01064e5:	83 c3 0c             	add    $0xc,%ebx
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01064e8:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f01064ea:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01064ef:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01064f5:	76 1d                	jbe    f0106514 <spin_lock+0xa6>
		pcs[i] = ebp[1];          // saved %eip
f01064f7:	8b 4a 04             	mov    0x4(%edx),%ecx
f01064fa:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01064fd:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f01064ff:	40                   	inc    %eax
f0106500:	83 f8 0a             	cmp    $0xa,%eax
f0106503:	75 ea                	jne    f01064ef <spin_lock+0x81>
#endif
}
f0106505:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106508:	5b                   	pop    %ebx
f0106509:	5e                   	pop    %esi
f010650a:	5d                   	pop    %ebp
f010650b:	c3                   	ret    
		pcs[i] = 0;
f010650c:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
	for (; i < 10; i++)
f0106513:	40                   	inc    %eax
f0106514:	83 f8 09             	cmp    $0x9,%eax
f0106517:	7e f3                	jle    f010650c <spin_lock+0x9e>
f0106519:	eb ea                	jmp    f0106505 <spin_lock+0x97>

f010651b <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f010651b:	55                   	push   %ebp
f010651c:	89 e5                	mov    %esp,%ebp
f010651e:	57                   	push   %edi
f010651f:	56                   	push   %esi
f0106520:	53                   	push   %ebx
f0106521:	83 ec 4c             	sub    $0x4c,%esp
f0106524:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f0106527:	83 3e 00             	cmpl   $0x0,(%esi)
f010652a:	75 35                	jne    f0106561 <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010652c:	83 ec 04             	sub    $0x4,%esp
f010652f:	6a 28                	push   $0x28
f0106531:	8d 46 0c             	lea    0xc(%esi),%eax
f0106534:	50                   	push   %eax
f0106535:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106538:	53                   	push   %ebx
f0106539:	e8 2f f6 ff ff       	call   f0105b6d <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f010653e:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106541:	0f b6 38             	movzbl (%eax),%edi
f0106544:	8b 76 04             	mov    0x4(%esi),%esi
f0106547:	e8 ae fc ff ff       	call   f01061fa <cpunum>
f010654c:	57                   	push   %edi
f010654d:	56                   	push   %esi
f010654e:	50                   	push   %eax
f010654f:	68 f4 87 10 f0       	push   $0xf01087f4
f0106554:	e8 3a da ff ff       	call   f0103f93 <cprintf>
f0106559:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010655c:	8d 7d a8             	lea    -0x58(%ebp),%edi
f010655f:	eb 6c                	jmp    f01065cd <spin_unlock+0xb2>
	return lock->locked && lock->cpu == thiscpu;
f0106561:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106564:	e8 91 fc ff ff       	call   f01061fa <cpunum>
f0106569:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010656c:	01 c2                	add    %eax,%edx
f010656e:	01 d2                	add    %edx,%edx
f0106570:	01 c2                	add    %eax,%edx
f0106572:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106575:	8d 04 85 20 70 29 f0 	lea    -0xfd68fe0(,%eax,4),%eax
	if (!holding(lk)) {
f010657c:	39 c3                	cmp    %eax,%ebx
f010657e:	75 ac                	jne    f010652c <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f0106580:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106587:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f010658e:	b8 00 00 00 00       	mov    $0x0,%eax
f0106593:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0106596:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106599:	5b                   	pop    %ebx
f010659a:	5e                   	pop    %esi
f010659b:	5f                   	pop    %edi
f010659c:	5d                   	pop    %ebp
f010659d:	c3                   	ret    
					pcs[i] - info.eip_fn_addr);
f010659e:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01065a0:	83 ec 04             	sub    $0x4,%esp
f01065a3:	89 c2                	mov    %eax,%edx
f01065a5:	2b 55 b8             	sub    -0x48(%ebp),%edx
f01065a8:	52                   	push   %edx
f01065a9:	ff 75 b0             	pushl  -0x50(%ebp)
f01065ac:	ff 75 b4             	pushl  -0x4c(%ebp)
f01065af:	ff 75 ac             	pushl  -0x54(%ebp)
f01065b2:	ff 75 a8             	pushl  -0x58(%ebp)
f01065b5:	50                   	push   %eax
f01065b6:	68 3c 88 10 f0       	push   $0xf010883c
f01065bb:	e8 d3 d9 ff ff       	call   f0103f93 <cprintf>
f01065c0:	83 c4 20             	add    $0x20,%esp
f01065c3:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f01065c6:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01065c9:	39 c3                	cmp    %eax,%ebx
f01065cb:	74 2d                	je     f01065fa <spin_unlock+0xdf>
f01065cd:	89 de                	mov    %ebx,%esi
f01065cf:	8b 03                	mov    (%ebx),%eax
f01065d1:	85 c0                	test   %eax,%eax
f01065d3:	74 25                	je     f01065fa <spin_unlock+0xdf>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01065d5:	83 ec 08             	sub    $0x8,%esp
f01065d8:	57                   	push   %edi
f01065d9:	50                   	push   %eax
f01065da:	e8 00 eb ff ff       	call   f01050df <debuginfo_eip>
f01065df:	83 c4 10             	add    $0x10,%esp
f01065e2:	85 c0                	test   %eax,%eax
f01065e4:	79 b8                	jns    f010659e <spin_unlock+0x83>
				cprintf("  %08x\n", pcs[i]);
f01065e6:	83 ec 08             	sub    $0x8,%esp
f01065e9:	ff 36                	pushl  (%esi)
f01065eb:	68 53 88 10 f0       	push   $0xf0108853
f01065f0:	e8 9e d9 ff ff       	call   f0103f93 <cprintf>
f01065f5:	83 c4 10             	add    $0x10,%esp
f01065f8:	eb c9                	jmp    f01065c3 <spin_unlock+0xa8>
		panic("spin_unlock");
f01065fa:	83 ec 04             	sub    $0x4,%esp
f01065fd:	68 5b 88 10 f0       	push   $0xf010885b
f0106602:	6a 67                	push   $0x67
f0106604:	68 2c 88 10 f0       	push   $0xf010882c
f0106609:	e8 86 9a ff ff       	call   f0100094 <_panic>
f010660e:	66 90                	xchg   %ax,%ax

f0106610 <__udivdi3>:
f0106610:	55                   	push   %ebp
f0106611:	57                   	push   %edi
f0106612:	56                   	push   %esi
f0106613:	53                   	push   %ebx
f0106614:	83 ec 1c             	sub    $0x1c,%esp
f0106617:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010661b:	8b 74 24 34          	mov    0x34(%esp),%esi
f010661f:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106623:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0106627:	85 d2                	test   %edx,%edx
f0106629:	75 2d                	jne    f0106658 <__udivdi3+0x48>
f010662b:	39 f7                	cmp    %esi,%edi
f010662d:	77 59                	ja     f0106688 <__udivdi3+0x78>
f010662f:	89 f9                	mov    %edi,%ecx
f0106631:	85 ff                	test   %edi,%edi
f0106633:	75 0b                	jne    f0106640 <__udivdi3+0x30>
f0106635:	b8 01 00 00 00       	mov    $0x1,%eax
f010663a:	31 d2                	xor    %edx,%edx
f010663c:	f7 f7                	div    %edi
f010663e:	89 c1                	mov    %eax,%ecx
f0106640:	31 d2                	xor    %edx,%edx
f0106642:	89 f0                	mov    %esi,%eax
f0106644:	f7 f1                	div    %ecx
f0106646:	89 c3                	mov    %eax,%ebx
f0106648:	89 e8                	mov    %ebp,%eax
f010664a:	f7 f1                	div    %ecx
f010664c:	89 da                	mov    %ebx,%edx
f010664e:	83 c4 1c             	add    $0x1c,%esp
f0106651:	5b                   	pop    %ebx
f0106652:	5e                   	pop    %esi
f0106653:	5f                   	pop    %edi
f0106654:	5d                   	pop    %ebp
f0106655:	c3                   	ret    
f0106656:	66 90                	xchg   %ax,%ax
f0106658:	39 f2                	cmp    %esi,%edx
f010665a:	77 1c                	ja     f0106678 <__udivdi3+0x68>
f010665c:	0f bd da             	bsr    %edx,%ebx
f010665f:	83 f3 1f             	xor    $0x1f,%ebx
f0106662:	75 38                	jne    f010669c <__udivdi3+0x8c>
f0106664:	39 f2                	cmp    %esi,%edx
f0106666:	72 08                	jb     f0106670 <__udivdi3+0x60>
f0106668:	39 ef                	cmp    %ebp,%edi
f010666a:	0f 87 98 00 00 00    	ja     f0106708 <__udivdi3+0xf8>
f0106670:	b8 01 00 00 00       	mov    $0x1,%eax
f0106675:	eb 05                	jmp    f010667c <__udivdi3+0x6c>
f0106677:	90                   	nop
f0106678:	31 db                	xor    %ebx,%ebx
f010667a:	31 c0                	xor    %eax,%eax
f010667c:	89 da                	mov    %ebx,%edx
f010667e:	83 c4 1c             	add    $0x1c,%esp
f0106681:	5b                   	pop    %ebx
f0106682:	5e                   	pop    %esi
f0106683:	5f                   	pop    %edi
f0106684:	5d                   	pop    %ebp
f0106685:	c3                   	ret    
f0106686:	66 90                	xchg   %ax,%ax
f0106688:	89 e8                	mov    %ebp,%eax
f010668a:	89 f2                	mov    %esi,%edx
f010668c:	f7 f7                	div    %edi
f010668e:	31 db                	xor    %ebx,%ebx
f0106690:	89 da                	mov    %ebx,%edx
f0106692:	83 c4 1c             	add    $0x1c,%esp
f0106695:	5b                   	pop    %ebx
f0106696:	5e                   	pop    %esi
f0106697:	5f                   	pop    %edi
f0106698:	5d                   	pop    %ebp
f0106699:	c3                   	ret    
f010669a:	66 90                	xchg   %ax,%ax
f010669c:	b8 20 00 00 00       	mov    $0x20,%eax
f01066a1:	29 d8                	sub    %ebx,%eax
f01066a3:	88 d9                	mov    %bl,%cl
f01066a5:	d3 e2                	shl    %cl,%edx
f01066a7:	89 54 24 08          	mov    %edx,0x8(%esp)
f01066ab:	89 fa                	mov    %edi,%edx
f01066ad:	88 c1                	mov    %al,%cl
f01066af:	d3 ea                	shr    %cl,%edx
f01066b1:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01066b5:	09 d1                	or     %edx,%ecx
f01066b7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01066bb:	88 d9                	mov    %bl,%cl
f01066bd:	d3 e7                	shl    %cl,%edi
f01066bf:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01066c3:	89 f7                	mov    %esi,%edi
f01066c5:	88 c1                	mov    %al,%cl
f01066c7:	d3 ef                	shr    %cl,%edi
f01066c9:	88 d9                	mov    %bl,%cl
f01066cb:	d3 e6                	shl    %cl,%esi
f01066cd:	89 ea                	mov    %ebp,%edx
f01066cf:	88 c1                	mov    %al,%cl
f01066d1:	d3 ea                	shr    %cl,%edx
f01066d3:	09 d6                	or     %edx,%esi
f01066d5:	89 f0                	mov    %esi,%eax
f01066d7:	89 fa                	mov    %edi,%edx
f01066d9:	f7 74 24 08          	divl   0x8(%esp)
f01066dd:	89 d7                	mov    %edx,%edi
f01066df:	89 c6                	mov    %eax,%esi
f01066e1:	f7 64 24 0c          	mull   0xc(%esp)
f01066e5:	39 d7                	cmp    %edx,%edi
f01066e7:	72 13                	jb     f01066fc <__udivdi3+0xec>
f01066e9:	74 09                	je     f01066f4 <__udivdi3+0xe4>
f01066eb:	89 f0                	mov    %esi,%eax
f01066ed:	31 db                	xor    %ebx,%ebx
f01066ef:	eb 8b                	jmp    f010667c <__udivdi3+0x6c>
f01066f1:	8d 76 00             	lea    0x0(%esi),%esi
f01066f4:	88 d9                	mov    %bl,%cl
f01066f6:	d3 e5                	shl    %cl,%ebp
f01066f8:	39 c5                	cmp    %eax,%ebp
f01066fa:	73 ef                	jae    f01066eb <__udivdi3+0xdb>
f01066fc:	8d 46 ff             	lea    -0x1(%esi),%eax
f01066ff:	31 db                	xor    %ebx,%ebx
f0106701:	e9 76 ff ff ff       	jmp    f010667c <__udivdi3+0x6c>
f0106706:	66 90                	xchg   %ax,%ax
f0106708:	31 c0                	xor    %eax,%eax
f010670a:	e9 6d ff ff ff       	jmp    f010667c <__udivdi3+0x6c>
f010670f:	90                   	nop

f0106710 <__umoddi3>:
f0106710:	55                   	push   %ebp
f0106711:	57                   	push   %edi
f0106712:	56                   	push   %esi
f0106713:	53                   	push   %ebx
f0106714:	83 ec 1c             	sub    $0x1c,%esp
f0106717:	8b 74 24 30          	mov    0x30(%esp),%esi
f010671b:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f010671f:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106723:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0106727:	89 f0                	mov    %esi,%eax
f0106729:	89 da                	mov    %ebx,%edx
f010672b:	85 ed                	test   %ebp,%ebp
f010672d:	75 15                	jne    f0106744 <__umoddi3+0x34>
f010672f:	39 df                	cmp    %ebx,%edi
f0106731:	76 39                	jbe    f010676c <__umoddi3+0x5c>
f0106733:	f7 f7                	div    %edi
f0106735:	89 d0                	mov    %edx,%eax
f0106737:	31 d2                	xor    %edx,%edx
f0106739:	83 c4 1c             	add    $0x1c,%esp
f010673c:	5b                   	pop    %ebx
f010673d:	5e                   	pop    %esi
f010673e:	5f                   	pop    %edi
f010673f:	5d                   	pop    %ebp
f0106740:	c3                   	ret    
f0106741:	8d 76 00             	lea    0x0(%esi),%esi
f0106744:	39 dd                	cmp    %ebx,%ebp
f0106746:	77 f1                	ja     f0106739 <__umoddi3+0x29>
f0106748:	0f bd cd             	bsr    %ebp,%ecx
f010674b:	83 f1 1f             	xor    $0x1f,%ecx
f010674e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106752:	75 38                	jne    f010678c <__umoddi3+0x7c>
f0106754:	39 dd                	cmp    %ebx,%ebp
f0106756:	72 04                	jb     f010675c <__umoddi3+0x4c>
f0106758:	39 f7                	cmp    %esi,%edi
f010675a:	77 dd                	ja     f0106739 <__umoddi3+0x29>
f010675c:	89 da                	mov    %ebx,%edx
f010675e:	89 f0                	mov    %esi,%eax
f0106760:	29 f8                	sub    %edi,%eax
f0106762:	19 ea                	sbb    %ebp,%edx
f0106764:	83 c4 1c             	add    $0x1c,%esp
f0106767:	5b                   	pop    %ebx
f0106768:	5e                   	pop    %esi
f0106769:	5f                   	pop    %edi
f010676a:	5d                   	pop    %ebp
f010676b:	c3                   	ret    
f010676c:	89 f9                	mov    %edi,%ecx
f010676e:	85 ff                	test   %edi,%edi
f0106770:	75 0b                	jne    f010677d <__umoddi3+0x6d>
f0106772:	b8 01 00 00 00       	mov    $0x1,%eax
f0106777:	31 d2                	xor    %edx,%edx
f0106779:	f7 f7                	div    %edi
f010677b:	89 c1                	mov    %eax,%ecx
f010677d:	89 d8                	mov    %ebx,%eax
f010677f:	31 d2                	xor    %edx,%edx
f0106781:	f7 f1                	div    %ecx
f0106783:	89 f0                	mov    %esi,%eax
f0106785:	f7 f1                	div    %ecx
f0106787:	eb ac                	jmp    f0106735 <__umoddi3+0x25>
f0106789:	8d 76 00             	lea    0x0(%esi),%esi
f010678c:	b8 20 00 00 00       	mov    $0x20,%eax
f0106791:	89 c2                	mov    %eax,%edx
f0106793:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106797:	29 c2                	sub    %eax,%edx
f0106799:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010679d:	88 c1                	mov    %al,%cl
f010679f:	d3 e5                	shl    %cl,%ebp
f01067a1:	89 f8                	mov    %edi,%eax
f01067a3:	88 d1                	mov    %dl,%cl
f01067a5:	d3 e8                	shr    %cl,%eax
f01067a7:	09 c5                	or     %eax,%ebp
f01067a9:	8b 44 24 04          	mov    0x4(%esp),%eax
f01067ad:	88 c1                	mov    %al,%cl
f01067af:	d3 e7                	shl    %cl,%edi
f01067b1:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01067b5:	89 df                	mov    %ebx,%edi
f01067b7:	88 d1                	mov    %dl,%cl
f01067b9:	d3 ef                	shr    %cl,%edi
f01067bb:	88 c1                	mov    %al,%cl
f01067bd:	d3 e3                	shl    %cl,%ebx
f01067bf:	89 f0                	mov    %esi,%eax
f01067c1:	88 d1                	mov    %dl,%cl
f01067c3:	d3 e8                	shr    %cl,%eax
f01067c5:	09 d8                	or     %ebx,%eax
f01067c7:	8a 4c 24 04          	mov    0x4(%esp),%cl
f01067cb:	d3 e6                	shl    %cl,%esi
f01067cd:	89 fa                	mov    %edi,%edx
f01067cf:	f7 f5                	div    %ebp
f01067d1:	89 d1                	mov    %edx,%ecx
f01067d3:	f7 64 24 08          	mull   0x8(%esp)
f01067d7:	89 c3                	mov    %eax,%ebx
f01067d9:	89 d7                	mov    %edx,%edi
f01067db:	39 d1                	cmp    %edx,%ecx
f01067dd:	72 29                	jb     f0106808 <__umoddi3+0xf8>
f01067df:	74 23                	je     f0106804 <__umoddi3+0xf4>
f01067e1:	89 ca                	mov    %ecx,%edx
f01067e3:	29 de                	sub    %ebx,%esi
f01067e5:	19 fa                	sbb    %edi,%edx
f01067e7:	89 d0                	mov    %edx,%eax
f01067e9:	8a 4c 24 0c          	mov    0xc(%esp),%cl
f01067ed:	d3 e0                	shl    %cl,%eax
f01067ef:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f01067f3:	88 d9                	mov    %bl,%cl
f01067f5:	d3 ee                	shr    %cl,%esi
f01067f7:	09 f0                	or     %esi,%eax
f01067f9:	d3 ea                	shr    %cl,%edx
f01067fb:	83 c4 1c             	add    $0x1c,%esp
f01067fe:	5b                   	pop    %ebx
f01067ff:	5e                   	pop    %esi
f0106800:	5f                   	pop    %edi
f0106801:	5d                   	pop    %ebp
f0106802:	c3                   	ret    
f0106803:	90                   	nop
f0106804:	39 c6                	cmp    %eax,%esi
f0106806:	73 d9                	jae    f01067e1 <__umoddi3+0xd1>
f0106808:	2b 44 24 08          	sub    0x8(%esp),%eax
f010680c:	19 ea                	sbb    %ebp,%edx
f010680e:	89 d7                	mov    %edx,%edi
f0106810:	89 c3                	mov    %eax,%ebx
f0106812:	eb cd                	jmp    f01067e1 <__umoddi3+0xd1>
