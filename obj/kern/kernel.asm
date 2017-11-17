
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
f010004b:	68 60 6d 10 f0       	push   $0xf0106d60
f0100050:	e8 65 3f 00 00       	call   f0103fba <cprintf>
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
f0100065:	e8 4b 0d 00 00       	call   f0100db5 <mon_backtrace>
f010006a:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010006d:	83 ec 08             	sub    $0x8,%esp
f0100070:	53                   	push   %ebx
f0100071:	68 7c 6d 10 f0       	push   $0xf0106d7c
f0100076:	e8 3f 3f 00 00       	call   f0103fba <cprintf>
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
f01000aa:	e8 b3 0d 00 00       	call   f0100e62 <monitor>
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
f01000bf:	e8 7e 66 00 00       	call   f0106742 <cpunum>
f01000c4:	ff 75 0c             	pushl  0xc(%ebp)
f01000c7:	ff 75 08             	pushl  0x8(%ebp)
f01000ca:	50                   	push   %eax
f01000cb:	68 64 6e 10 f0       	push   $0xf0106e64
f01000d0:	e8 e5 3e 00 00       	call   f0103fba <cprintf>
	vcprintf(fmt, ap);
f01000d5:	83 c4 08             	add    $0x8,%esp
f01000d8:	53                   	push   %ebx
f01000d9:	56                   	push   %esi
f01000da:	e8 b5 3e 00 00       	call   f0103f94 <vcprintf>
	cprintf("\n");
f01000df:	c7 04 24 1b 72 10 f0 	movl   $0xf010721b,(%esp)
f01000e6:	e8 cf 3e 00 00       	call   f0103fba <cprintf>
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
f0100109:	e8 2a 5f 00 00       	call   f0106038 <memset>
	cons_init();
f010010e:	e8 09 06 00 00       	call   f010071c <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f0100113:	83 c4 08             	add    $0x8,%esp
f0100116:	68 ac 1a 00 00       	push   $0x1aac
f010011b:	68 97 6d 10 f0       	push   $0xf0106d97
f0100120:	e8 95 3e 00 00       	call   f0103fba <cprintf>
	mem_init();
f0100125:	e8 22 17 00 00       	call   f010184c <mem_init>
	cprintf(ANSI_COLOR_RED     "This text is RED!"     ANSI_COLOR_RESET "\n");
f010012a:	c7 04 24 b2 6d 10 f0 	movl   $0xf0106db2,(%esp)
f0100131:	e8 84 3e 00 00       	call   f0103fba <cprintf>
	cprintf(ANSI_COLOR_GREEN   "This text is GREEN!"   ANSI_COLOR_RESET "\n");
f0100136:	c7 04 24 ce 6d 10 f0 	movl   $0xf0106dce,(%esp)
f010013d:	e8 78 3e 00 00       	call   f0103fba <cprintf>
	cprintf(ANSI_COLOR_YELLOW  "This text is YELLOW!"  ANSI_COLOR_RESET "\n");
f0100142:	c7 04 24 88 6e 10 f0 	movl   $0xf0106e88,(%esp)
f0100149:	e8 6c 3e 00 00       	call   f0103fba <cprintf>
	cprintf(ANSI_COLOR_BLUE    "This text is BLUE!"    ANSI_COLOR_RESET "\n");
f010014e:	c7 04 24 ec 6d 10 f0 	movl   $0xf0106dec,(%esp)
f0100155:	e8 60 3e 00 00       	call   f0103fba <cprintf>
	cprintf(ANSI_COLOR_MAGENTA "This text is MAGENTA!" ANSI_COLOR_RESET "\n");
f010015a:	c7 04 24 a8 6e 10 f0 	movl   $0xf0106ea8,(%esp)
f0100161:	e8 54 3e 00 00       	call   f0103fba <cprintf>
	cprintf(ANSI_COLOR_CYAN    "This text is CYAN!"    ANSI_COLOR_RESET "\n");
f0100166:	c7 04 24 09 6e 10 f0 	movl   $0xf0106e09,(%esp)
f010016d:	e8 48 3e 00 00       	call   f0103fba <cprintf>
	test_backtrace(5);
f0100172:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100179:	e8 c2 fe ff ff       	call   f0100040 <test_backtrace>
	env_init();
f010017e:	e8 e5 34 00 00       	call   f0103668 <env_init>
	trap_init();
f0100183:	e8 e6 3e 00 00       	call   f010406e <trap_init>
	mp_init();
f0100188:	e8 9e 62 00 00       	call   f010642b <mp_init>
	lapic_init();
f010018d:	e8 cb 65 00 00       	call   f010675d <lapic_init>
	pic_init();
f0100192:	e8 4a 3d 00 00       	call   f0103ee1 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100197:	c7 04 24 c0 33 12 f0 	movl   $0xf01233c0,(%esp)
f010019e:	e8 13 68 00 00       	call   f01069b6 <spin_lock>
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
f01001b2:	b8 92 63 10 f0       	mov    $0xf0106392,%eax
f01001b7:	2d 18 63 10 f0       	sub    $0xf0106318,%eax
f01001bc:	50                   	push   %eax
f01001bd:	68 18 63 10 f0       	push   $0xf0106318
f01001c2:	68 00 70 00 f0       	push   $0xf0007000
f01001c7:	e8 b9 5e 00 00       	call   f0106085 <memmove>
f01001cc:	83 c4 10             	add    $0x10,%esp
	for (c = cpus; c < cpus + ncpu; c++) {
f01001cf:	bb 20 60 2a f0       	mov    $0xf02a6020,%ebx
f01001d4:	eb 19                	jmp    f01001ef <i386_init+0xff>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001d6:	68 00 70 00 00       	push   $0x7000
f01001db:	68 c8 6e 10 f0       	push   $0xf0106ec8
f01001e0:	6a 76                	push   $0x76
f01001e2:	68 26 6e 10 f0       	push   $0xf0106e26
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
f010020c:	e8 31 65 00 00       	call   f0106742 <cpunum>
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
f0100264:	e8 4e 66 00 00       	call   f01068b7 <lapic_startap>
f0100269:	83 c4 10             	add    $0x10,%esp
		while(c->cpu_status != CPU_STARTED)
f010026c:	8b 43 04             	mov    0x4(%ebx),%eax
f010026f:	83 f8 01             	cmp    $0x1,%eax
f0100272:	75 f8                	jne    f010026c <i386_init+0x17c>
f0100274:	e9 73 ff ff ff       	jmp    f01001ec <i386_init+0xfc>
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f0100279:	83 ec 08             	sub    $0x8,%esp
f010027c:	6a 01                	push   $0x1
f010027e:	68 68 85 24 f0       	push   $0xf0248568
f0100283:	e8 32 36 00 00       	call   f01038ba <env_create>
	ENV_CREATE(user_icode, ENV_TYPE_USER);
f0100288:	83 c4 08             	add    $0x8,%esp
f010028b:	6a 00                	push   $0x0
f010028d:	68 2c 03 24 f0       	push   $0xf024032c
f0100292:	e8 23 36 00 00       	call   f01038ba <env_create>
	kbd_intr();
f0100297:	e8 24 04 00 00       	call   f01006c0 <kbd_intr>
	sched_yield();
f010029c:	e8 93 4b 00 00       	call   f0104e34 <sched_yield>

f01002a1 <mp_main>:
{
f01002a1:	55                   	push   %ebp
f01002a2:	89 e5                	mov    %esp,%ebp
f01002a4:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f01002a7:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01002ac:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01002b1:	77 15                	ja     f01002c8 <mp_main+0x27>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01002b3:	50                   	push   %eax
f01002b4:	68 ec 6e 10 f0       	push   $0xf0106eec
f01002b9:	68 8d 00 00 00       	push   $0x8d
f01002be:	68 26 6e 10 f0       	push   $0xf0106e26
f01002c3:	e8 cc fd ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01002c8:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01002cd:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01002d0:	e8 6d 64 00 00       	call   f0106742 <cpunum>
f01002d5:	83 ec 08             	sub    $0x8,%esp
f01002d8:	50                   	push   %eax
f01002d9:	68 32 6e 10 f0       	push   $0xf0106e32
f01002de:	e8 d7 3c 00 00       	call   f0103fba <cprintf>
	lapic_init();
f01002e3:	e8 75 64 00 00       	call   f010675d <lapic_init>
	env_init_percpu();
f01002e8:	e8 4b 33 00 00       	call   f0103638 <env_init_percpu>
	trap_init_percpu();
f01002ed:	e8 dc 3c 00 00       	call   f0103fce <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01002f2:	e8 4b 64 00 00       	call   f0106742 <cpunum>
f01002f7:	6b d0 74             	imul   $0x74,%eax,%edx
f01002fa:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01002fd:	b8 01 00 00 00       	mov    $0x1,%eax
f0100302:	f0 87 82 20 60 2a f0 	lock xchg %eax,-0xfd59fe0(%edx)
f0100309:	c7 04 24 c0 33 12 f0 	movl   $0xf01233c0,(%esp)
f0100310:	e8 a1 66 00 00       	call   f01069b6 <spin_lock>
	sched_yield();
f0100315:	e8 1a 4b 00 00       	call   f0104e34 <sched_yield>

f010031a <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010031a:	55                   	push   %ebp
f010031b:	89 e5                	mov    %esp,%ebp
f010031d:	53                   	push   %ebx
f010031e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100321:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100324:	ff 75 0c             	pushl  0xc(%ebp)
f0100327:	ff 75 08             	pushl  0x8(%ebp)
f010032a:	68 48 6e 10 f0       	push   $0xf0106e48
f010032f:	e8 86 3c 00 00       	call   f0103fba <cprintf>
	vcprintf(fmt, ap);
f0100334:	83 c4 08             	add    $0x8,%esp
f0100337:	53                   	push   %ebx
f0100338:	ff 75 10             	pushl  0x10(%ebp)
f010033b:	e8 54 3c 00 00       	call   f0103f94 <vcprintf>
	cprintf("\n");
f0100340:	c7 04 24 1b 72 10 f0 	movl   $0xf010721b,(%esp)
f0100347:	e8 6e 3c 00 00       	call   f0103fba <cprintf>
	va_end(ap);
}
f010034c:	83 c4 10             	add    $0x10,%esp
f010034f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100352:	c9                   	leave  
f0100353:	c3                   	ret    

f0100354 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100354:	55                   	push   %ebp
f0100355:	89 e5                	mov    %esp,%ebp
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100357:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010035c:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010035d:	a8 01                	test   $0x1,%al
f010035f:	74 0b                	je     f010036c <serial_proc_data+0x18>
f0100361:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100366:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100367:	0f b6 c0             	movzbl %al,%eax
}
f010036a:	5d                   	pop    %ebp
f010036b:	c3                   	ret    
		return -1;
f010036c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100371:	eb f7                	jmp    f010036a <serial_proc_data+0x16>

f0100373 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100373:	55                   	push   %ebp
f0100374:	89 e5                	mov    %esp,%ebp
f0100376:	53                   	push   %ebx
f0100377:	83 ec 04             	sub    $0x4,%esp
f010037a:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010037c:	ff d3                	call   *%ebx
f010037e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100381:	74 2d                	je     f01003b0 <cons_intr+0x3d>
		if (c == 0)
f0100383:	85 c0                	test   %eax,%eax
f0100385:	74 f5                	je     f010037c <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f0100387:	8b 0d 24 52 2a f0    	mov    0xf02a5224,%ecx
f010038d:	8d 51 01             	lea    0x1(%ecx),%edx
f0100390:	89 15 24 52 2a f0    	mov    %edx,0xf02a5224
f0100396:	88 81 20 50 2a f0    	mov    %al,-0xfd5afe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010039c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01003a2:	75 d8                	jne    f010037c <cons_intr+0x9>
			cons.wpos = 0;
f01003a4:	c7 05 24 52 2a f0 00 	movl   $0x0,0xf02a5224
f01003ab:	00 00 00 
f01003ae:	eb cc                	jmp    f010037c <cons_intr+0x9>
	}
}
f01003b0:	83 c4 04             	add    $0x4,%esp
f01003b3:	5b                   	pop    %ebx
f01003b4:	5d                   	pop    %ebp
f01003b5:	c3                   	ret    

f01003b6 <kbd_proc_data>:
{
f01003b6:	55                   	push   %ebp
f01003b7:	89 e5                	mov    %esp,%ebp
f01003b9:	53                   	push   %ebx
f01003ba:	83 ec 04             	sub    $0x4,%esp
f01003bd:	ba 64 00 00 00       	mov    $0x64,%edx
f01003c2:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01003c3:	a8 01                	test   $0x1,%al
f01003c5:	0f 84 f1 00 00 00    	je     f01004bc <kbd_proc_data+0x106>
	if (stat & KBS_TERR)
f01003cb:	a8 20                	test   $0x20,%al
f01003cd:	0f 85 f0 00 00 00    	jne    f01004c3 <kbd_proc_data+0x10d>
f01003d3:	ba 60 00 00 00       	mov    $0x60,%edx
f01003d8:	ec                   	in     (%dx),%al
f01003d9:	88 c2                	mov    %al,%dl
	if (data == 0xE0) {
f01003db:	3c e0                	cmp    $0xe0,%al
f01003dd:	0f 84 8a 00 00 00    	je     f010046d <kbd_proc_data+0xb7>
	} else if (data & 0x80) {
f01003e3:	84 c0                	test   %al,%al
f01003e5:	0f 88 95 00 00 00    	js     f0100480 <kbd_proc_data+0xca>
	} else if (shift & E0ESC) {
f01003eb:	8b 0d 00 50 2a f0    	mov    0xf02a5000,%ecx
f01003f1:	f6 c1 40             	test   $0x40,%cl
f01003f4:	74 0e                	je     f0100404 <kbd_proc_data+0x4e>
		data |= 0x80;
f01003f6:	83 c8 80             	or     $0xffffff80,%eax
f01003f9:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f01003fb:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003fe:	89 0d 00 50 2a f0    	mov    %ecx,0xf02a5000
	shift |= shiftcode[data];
f0100404:	0f b6 d2             	movzbl %dl,%edx
f0100407:	0f b6 82 60 70 10 f0 	movzbl -0xfef8fa0(%edx),%eax
f010040e:	0b 05 00 50 2a f0    	or     0xf02a5000,%eax
	shift ^= togglecode[data];
f0100414:	0f b6 8a 60 6f 10 f0 	movzbl -0xfef90a0(%edx),%ecx
f010041b:	31 c8                	xor    %ecx,%eax
f010041d:	a3 00 50 2a f0       	mov    %eax,0xf02a5000
	c = charcode[shift & (CTL | SHIFT)][data];
f0100422:	89 c1                	mov    %eax,%ecx
f0100424:	83 e1 03             	and    $0x3,%ecx
f0100427:	8b 0c 8d 40 6f 10 f0 	mov    -0xfef90c0(,%ecx,4),%ecx
f010042e:	8a 14 11             	mov    (%ecx,%edx,1),%dl
f0100431:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100434:	a8 08                	test   $0x8,%al
f0100436:	74 0d                	je     f0100445 <kbd_proc_data+0x8f>
		if ('a' <= c && c <= 'z')
f0100438:	89 da                	mov    %ebx,%edx
f010043a:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010043d:	83 f9 19             	cmp    $0x19,%ecx
f0100440:	77 6d                	ja     f01004af <kbd_proc_data+0xf9>
			c += 'A' - 'a';
f0100442:	83 eb 20             	sub    $0x20,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100445:	f7 d0                	not    %eax
f0100447:	a8 06                	test   $0x6,%al
f0100449:	75 2e                	jne    f0100479 <kbd_proc_data+0xc3>
f010044b:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100451:	75 26                	jne    f0100479 <kbd_proc_data+0xc3>
		cprintf("Rebooting!\n");
f0100453:	83 ec 0c             	sub    $0xc,%esp
f0100456:	68 10 6f 10 f0       	push   $0xf0106f10
f010045b:	e8 5a 3b 00 00       	call   f0103fba <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100460:	b0 03                	mov    $0x3,%al
f0100462:	ba 92 00 00 00       	mov    $0x92,%edx
f0100467:	ee                   	out    %al,(%dx)
f0100468:	83 c4 10             	add    $0x10,%esp
f010046b:	eb 0c                	jmp    f0100479 <kbd_proc_data+0xc3>
		shift |= E0ESC;
f010046d:	83 0d 00 50 2a f0 40 	orl    $0x40,0xf02a5000
		return 0;
f0100474:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100479:	89 d8                	mov    %ebx,%eax
f010047b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010047e:	c9                   	leave  
f010047f:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100480:	8b 0d 00 50 2a f0    	mov    0xf02a5000,%ecx
f0100486:	f6 c1 40             	test   $0x40,%cl
f0100489:	75 05                	jne    f0100490 <kbd_proc_data+0xda>
f010048b:	83 e0 7f             	and    $0x7f,%eax
f010048e:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f0100490:	0f b6 d2             	movzbl %dl,%edx
f0100493:	8a 82 60 70 10 f0    	mov    -0xfef8fa0(%edx),%al
f0100499:	83 c8 40             	or     $0x40,%eax
f010049c:	0f b6 c0             	movzbl %al,%eax
f010049f:	f7 d0                	not    %eax
f01004a1:	21 c8                	and    %ecx,%eax
f01004a3:	a3 00 50 2a f0       	mov    %eax,0xf02a5000
		return 0;
f01004a8:	bb 00 00 00 00       	mov    $0x0,%ebx
f01004ad:	eb ca                	jmp    f0100479 <kbd_proc_data+0xc3>
		else if ('A' <= c && c <= 'Z')
f01004af:	83 ea 41             	sub    $0x41,%edx
f01004b2:	83 fa 19             	cmp    $0x19,%edx
f01004b5:	77 8e                	ja     f0100445 <kbd_proc_data+0x8f>
			c += 'a' - 'A';
f01004b7:	83 c3 20             	add    $0x20,%ebx
f01004ba:	eb 89                	jmp    f0100445 <kbd_proc_data+0x8f>
		return -1;
f01004bc:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01004c1:	eb b6                	jmp    f0100479 <kbd_proc_data+0xc3>
		return -1;
f01004c3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01004c8:	eb af                	jmp    f0100479 <kbd_proc_data+0xc3>

f01004ca <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01004ca:	55                   	push   %ebp
f01004cb:	89 e5                	mov    %esp,%ebp
f01004cd:	57                   	push   %edi
f01004ce:	56                   	push   %esi
f01004cf:	53                   	push   %ebx
f01004d0:	83 ec 1c             	sub    $0x1c,%esp
f01004d3:	89 c7                	mov    %eax,%edi
f01004d5:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004da:	be fd 03 00 00       	mov    $0x3fd,%esi
f01004df:	b9 84 00 00 00       	mov    $0x84,%ecx
f01004e4:	eb 06                	jmp    f01004ec <cons_putc+0x22>
f01004e6:	89 ca                	mov    %ecx,%edx
f01004e8:	ec                   	in     (%dx),%al
f01004e9:	ec                   	in     (%dx),%al
f01004ea:	ec                   	in     (%dx),%al
f01004eb:	ec                   	in     (%dx),%al
f01004ec:	89 f2                	mov    %esi,%edx
f01004ee:	ec                   	in     (%dx),%al
	for (i = 0;
f01004ef:	a8 20                	test   $0x20,%al
f01004f1:	75 03                	jne    f01004f6 <cons_putc+0x2c>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01004f3:	4b                   	dec    %ebx
f01004f4:	75 f0                	jne    f01004e6 <cons_putc+0x1c>
	outb(COM1 + COM_TX, c);
f01004f6:	89 f8                	mov    %edi,%eax
f01004f8:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004fb:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100500:	ee                   	out    %al,(%dx)
f0100501:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100506:	be 79 03 00 00       	mov    $0x379,%esi
f010050b:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100510:	eb 06                	jmp    f0100518 <cons_putc+0x4e>
f0100512:	89 ca                	mov    %ecx,%edx
f0100514:	ec                   	in     (%dx),%al
f0100515:	ec                   	in     (%dx),%al
f0100516:	ec                   	in     (%dx),%al
f0100517:	ec                   	in     (%dx),%al
f0100518:	89 f2                	mov    %esi,%edx
f010051a:	ec                   	in     (%dx),%al
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010051b:	84 c0                	test   %al,%al
f010051d:	78 03                	js     f0100522 <cons_putc+0x58>
f010051f:	4b                   	dec    %ebx
f0100520:	75 f0                	jne    f0100512 <cons_putc+0x48>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100522:	ba 78 03 00 00       	mov    $0x378,%edx
f0100527:	8a 45 e7             	mov    -0x19(%ebp),%al
f010052a:	ee                   	out    %al,(%dx)
f010052b:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100530:	b0 0d                	mov    $0xd,%al
f0100532:	ee                   	out    %al,(%dx)
f0100533:	b0 08                	mov    $0x8,%al
f0100535:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f0100536:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f010053c:	75 06                	jne    f0100544 <cons_putc+0x7a>
		c |= 0x0700;
f010053e:	81 cf 00 07 00 00    	or     $0x700,%edi
	switch (c & 0xff) {
f0100544:	89 f8                	mov    %edi,%eax
f0100546:	0f b6 c0             	movzbl %al,%eax
f0100549:	83 f8 09             	cmp    $0x9,%eax
f010054c:	0f 84 b1 00 00 00    	je     f0100603 <cons_putc+0x139>
f0100552:	83 f8 09             	cmp    $0x9,%eax
f0100555:	7e 70                	jle    f01005c7 <cons_putc+0xfd>
f0100557:	83 f8 0a             	cmp    $0xa,%eax
f010055a:	0f 84 96 00 00 00    	je     f01005f6 <cons_putc+0x12c>
f0100560:	83 f8 0d             	cmp    $0xd,%eax
f0100563:	0f 85 d1 00 00 00    	jne    f010063a <cons_putc+0x170>
		crt_pos -= (crt_pos % CRT_COLS);
f0100569:	66 8b 0d 28 52 2a f0 	mov    0xf02a5228,%cx
f0100570:	bb 50 00 00 00       	mov    $0x50,%ebx
f0100575:	89 c8                	mov    %ecx,%eax
f0100577:	ba 00 00 00 00       	mov    $0x0,%edx
f010057c:	66 f7 f3             	div    %bx
f010057f:	29 d1                	sub    %edx,%ecx
f0100581:	66 89 0d 28 52 2a f0 	mov    %cx,0xf02a5228
	if (crt_pos >= CRT_SIZE) {
f0100588:	66 81 3d 28 52 2a f0 	cmpw   $0x7cf,0xf02a5228
f010058f:	cf 07 
f0100591:	0f 87 c5 00 00 00    	ja     f010065c <cons_putc+0x192>
	outb(addr_6845, 14);
f0100597:	8b 0d 30 52 2a f0    	mov    0xf02a5230,%ecx
f010059d:	b0 0e                	mov    $0xe,%al
f010059f:	89 ca                	mov    %ecx,%edx
f01005a1:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005a2:	8d 59 01             	lea    0x1(%ecx),%ebx
f01005a5:	66 a1 28 52 2a f0    	mov    0xf02a5228,%ax
f01005ab:	66 c1 e8 08          	shr    $0x8,%ax
f01005af:	89 da                	mov    %ebx,%edx
f01005b1:	ee                   	out    %al,(%dx)
f01005b2:	b0 0f                	mov    $0xf,%al
f01005b4:	89 ca                	mov    %ecx,%edx
f01005b6:	ee                   	out    %al,(%dx)
f01005b7:	a0 28 52 2a f0       	mov    0xf02a5228,%al
f01005bc:	89 da                	mov    %ebx,%edx
f01005be:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005c2:	5b                   	pop    %ebx
f01005c3:	5e                   	pop    %esi
f01005c4:	5f                   	pop    %edi
f01005c5:	5d                   	pop    %ebp
f01005c6:	c3                   	ret    
	switch (c & 0xff) {
f01005c7:	83 f8 08             	cmp    $0x8,%eax
f01005ca:	75 6e                	jne    f010063a <cons_putc+0x170>
		if (crt_pos > 0) {
f01005cc:	66 a1 28 52 2a f0    	mov    0xf02a5228,%ax
f01005d2:	66 85 c0             	test   %ax,%ax
f01005d5:	74 c0                	je     f0100597 <cons_putc+0xcd>
			crt_pos--;
f01005d7:	48                   	dec    %eax
f01005d8:	66 a3 28 52 2a f0    	mov    %ax,0xf02a5228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01005de:	0f b7 c0             	movzwl %ax,%eax
f01005e1:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f01005e7:	83 cf 20             	or     $0x20,%edi
f01005ea:	8b 15 2c 52 2a f0    	mov    0xf02a522c,%edx
f01005f0:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01005f4:	eb 92                	jmp    f0100588 <cons_putc+0xbe>
		crt_pos += CRT_COLS;
f01005f6:	66 83 05 28 52 2a f0 	addw   $0x50,0xf02a5228
f01005fd:	50 
f01005fe:	e9 66 ff ff ff       	jmp    f0100569 <cons_putc+0x9f>
		cons_putc(' ');
f0100603:	b8 20 00 00 00       	mov    $0x20,%eax
f0100608:	e8 bd fe ff ff       	call   f01004ca <cons_putc>
		cons_putc(' ');
f010060d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100612:	e8 b3 fe ff ff       	call   f01004ca <cons_putc>
		cons_putc(' ');
f0100617:	b8 20 00 00 00       	mov    $0x20,%eax
f010061c:	e8 a9 fe ff ff       	call   f01004ca <cons_putc>
		cons_putc(' ');
f0100621:	b8 20 00 00 00       	mov    $0x20,%eax
f0100626:	e8 9f fe ff ff       	call   f01004ca <cons_putc>
		cons_putc(' ');
f010062b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100630:	e8 95 fe ff ff       	call   f01004ca <cons_putc>
f0100635:	e9 4e ff ff ff       	jmp    f0100588 <cons_putc+0xbe>
		crt_buf[crt_pos++] = c;		/* write the character */
f010063a:	66 a1 28 52 2a f0    	mov    0xf02a5228,%ax
f0100640:	8d 50 01             	lea    0x1(%eax),%edx
f0100643:	66 89 15 28 52 2a f0 	mov    %dx,0xf02a5228
f010064a:	0f b7 c0             	movzwl %ax,%eax
f010064d:	8b 15 2c 52 2a f0    	mov    0xf02a522c,%edx
f0100653:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100657:	e9 2c ff ff ff       	jmp    f0100588 <cons_putc+0xbe>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010065c:	a1 2c 52 2a f0       	mov    0xf02a522c,%eax
f0100661:	83 ec 04             	sub    $0x4,%esp
f0100664:	68 00 0f 00 00       	push   $0xf00
f0100669:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010066f:	52                   	push   %edx
f0100670:	50                   	push   %eax
f0100671:	e8 0f 5a 00 00       	call   f0106085 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100676:	8b 15 2c 52 2a f0    	mov    0xf02a522c,%edx
f010067c:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100682:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100688:	83 c4 10             	add    $0x10,%esp
f010068b:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100690:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100693:	39 d0                	cmp    %edx,%eax
f0100695:	75 f4                	jne    f010068b <cons_putc+0x1c1>
		crt_pos -= CRT_COLS;
f0100697:	66 83 2d 28 52 2a f0 	subw   $0x50,0xf02a5228
f010069e:	50 
f010069f:	e9 f3 fe ff ff       	jmp    f0100597 <cons_putc+0xcd>

f01006a4 <serial_intr>:
	if (serial_exists)
f01006a4:	80 3d 34 52 2a f0 00 	cmpb   $0x0,0xf02a5234
f01006ab:	75 01                	jne    f01006ae <serial_intr+0xa>
f01006ad:	c3                   	ret    
{
f01006ae:	55                   	push   %ebp
f01006af:	89 e5                	mov    %esp,%ebp
f01006b1:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01006b4:	b8 54 03 10 f0       	mov    $0xf0100354,%eax
f01006b9:	e8 b5 fc ff ff       	call   f0100373 <cons_intr>
}
f01006be:	c9                   	leave  
f01006bf:	c3                   	ret    

f01006c0 <kbd_intr>:
{
f01006c0:	55                   	push   %ebp
f01006c1:	89 e5                	mov    %esp,%ebp
f01006c3:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01006c6:	b8 b6 03 10 f0       	mov    $0xf01003b6,%eax
f01006cb:	e8 a3 fc ff ff       	call   f0100373 <cons_intr>
}
f01006d0:	c9                   	leave  
f01006d1:	c3                   	ret    

f01006d2 <cons_getc>:
{
f01006d2:	55                   	push   %ebp
f01006d3:	89 e5                	mov    %esp,%ebp
f01006d5:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f01006d8:	e8 c7 ff ff ff       	call   f01006a4 <serial_intr>
	kbd_intr();
f01006dd:	e8 de ff ff ff       	call   f01006c0 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01006e2:	a1 20 52 2a f0       	mov    0xf02a5220,%eax
f01006e7:	3b 05 24 52 2a f0    	cmp    0xf02a5224,%eax
f01006ed:	74 26                	je     f0100715 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01006ef:	8d 50 01             	lea    0x1(%eax),%edx
f01006f2:	89 15 20 52 2a f0    	mov    %edx,0xf02a5220
f01006f8:	0f b6 80 20 50 2a f0 	movzbl -0xfd5afe0(%eax),%eax
		if (cons.rpos == CONSBUFSIZE)
f01006ff:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100705:	74 02                	je     f0100709 <cons_getc+0x37>
}
f0100707:	c9                   	leave  
f0100708:	c3                   	ret    
			cons.rpos = 0;
f0100709:	c7 05 20 52 2a f0 00 	movl   $0x0,0xf02a5220
f0100710:	00 00 00 
f0100713:	eb f2                	jmp    f0100707 <cons_getc+0x35>
	return 0;
f0100715:	b8 00 00 00 00       	mov    $0x0,%eax
f010071a:	eb eb                	jmp    f0100707 <cons_getc+0x35>

f010071c <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f010071c:	55                   	push   %ebp
f010071d:	89 e5                	mov    %esp,%ebp
f010071f:	57                   	push   %edi
f0100720:	56                   	push   %esi
f0100721:	53                   	push   %ebx
f0100722:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f0100725:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f010072c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100733:	5a a5 
	if (*cp != 0xA55A) {
f0100735:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f010073b:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010073f:	0f 84 c8 00 00 00    	je     f010080d <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f0100745:	c7 05 30 52 2a f0 b4 	movl   $0x3b4,0xf02a5230
f010074c:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010074f:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f0100754:	8b 3d 30 52 2a f0    	mov    0xf02a5230,%edi
f010075a:	b0 0e                	mov    $0xe,%al
f010075c:	89 fa                	mov    %edi,%edx
f010075e:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010075f:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100762:	89 ca                	mov    %ecx,%edx
f0100764:	ec                   	in     (%dx),%al
f0100765:	0f b6 c0             	movzbl %al,%eax
f0100768:	c1 e0 08             	shl    $0x8,%eax
f010076b:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010076d:	b0 0f                	mov    $0xf,%al
f010076f:	89 fa                	mov    %edi,%edx
f0100771:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100772:	89 ca                	mov    %ecx,%edx
f0100774:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100775:	89 35 2c 52 2a f0    	mov    %esi,0xf02a522c
	pos |= inb(addr_6845 + 1);
f010077b:	0f b6 c0             	movzbl %al,%eax
f010077e:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f0100780:	66 a3 28 52 2a f0    	mov    %ax,0xf02a5228
	kbd_intr();
f0100786:	e8 35 ff ff ff       	call   f01006c0 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f010078b:	83 ec 0c             	sub    $0xc,%esp
f010078e:	66 a1 a8 33 12 f0    	mov    0xf01233a8,%ax
f0100794:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100799:	50                   	push   %eax
f010079a:	e8 ca 36 00 00       	call   f0103e69 <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010079f:	b1 00                	mov    $0x0,%cl
f01007a1:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01007a6:	88 c8                	mov    %cl,%al
f01007a8:	89 da                	mov    %ebx,%edx
f01007aa:	ee                   	out    %al,(%dx)
f01007ab:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01007b0:	b0 80                	mov    $0x80,%al
f01007b2:	89 fa                	mov    %edi,%edx
f01007b4:	ee                   	out    %al,(%dx)
f01007b5:	b0 0c                	mov    $0xc,%al
f01007b7:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01007bc:	ee                   	out    %al,(%dx)
f01007bd:	be f9 03 00 00       	mov    $0x3f9,%esi
f01007c2:	88 c8                	mov    %cl,%al
f01007c4:	89 f2                	mov    %esi,%edx
f01007c6:	ee                   	out    %al,(%dx)
f01007c7:	b0 03                	mov    $0x3,%al
f01007c9:	89 fa                	mov    %edi,%edx
f01007cb:	ee                   	out    %al,(%dx)
f01007cc:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01007d1:	88 c8                	mov    %cl,%al
f01007d3:	ee                   	out    %al,(%dx)
f01007d4:	b0 01                	mov    $0x1,%al
f01007d6:	89 f2                	mov    %esi,%edx
f01007d8:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01007d9:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01007de:	ec                   	in     (%dx),%al
f01007df:	88 c1                	mov    %al,%cl
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01007e1:	83 c4 10             	add    $0x10,%esp
f01007e4:	3c ff                	cmp    $0xff,%al
f01007e6:	0f 95 05 34 52 2a f0 	setne  0xf02a5234
f01007ed:	89 da                	mov    %ebx,%edx
f01007ef:	ec                   	in     (%dx),%al
f01007f0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01007f5:	ec                   	in     (%dx),%al
	if (serial_exists)
f01007f6:	80 f9 ff             	cmp    $0xff,%cl
f01007f9:	75 2d                	jne    f0100828 <cons_init+0x10c>
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
		cprintf("Serial port does not exist!\n");
f01007fb:	83 ec 0c             	sub    $0xc,%esp
f01007fe:	68 1c 6f 10 f0       	push   $0xf0106f1c
f0100803:	e8 b2 37 00 00       	call   f0103fba <cprintf>
f0100808:	83 c4 10             	add    $0x10,%esp
}
f010080b:	eb 3b                	jmp    f0100848 <cons_init+0x12c>
		*cp = was;
f010080d:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100814:	c7 05 30 52 2a f0 d4 	movl   $0x3d4,0xf02a5230
f010081b:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010081e:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f0100823:	e9 2c ff ff ff       	jmp    f0100754 <cons_init+0x38>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f0100828:	83 ec 0c             	sub    $0xc,%esp
f010082b:	66 a1 a8 33 12 f0    	mov    0xf01233a8,%ax
f0100831:	25 ef ff 00 00       	and    $0xffef,%eax
f0100836:	50                   	push   %eax
f0100837:	e8 2d 36 00 00       	call   f0103e69 <irq_setmask_8259A>
	if (!serial_exists)
f010083c:	83 c4 10             	add    $0x10,%esp
f010083f:	80 3d 34 52 2a f0 00 	cmpb   $0x0,0xf02a5234
f0100846:	74 b3                	je     f01007fb <cons_init+0xdf>
}
f0100848:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010084b:	5b                   	pop    %ebx
f010084c:	5e                   	pop    %esi
f010084d:	5f                   	pop    %edi
f010084e:	5d                   	pop    %ebp
f010084f:	c3                   	ret    

f0100850 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100850:	55                   	push   %ebp
f0100851:	89 e5                	mov    %esp,%ebp
f0100853:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100856:	8b 45 08             	mov    0x8(%ebp),%eax
f0100859:	e8 6c fc ff ff       	call   f01004ca <cons_putc>
}
f010085e:	c9                   	leave  
f010085f:	c3                   	ret    

f0100860 <getchar>:

int
getchar(void)
{
f0100860:	55                   	push   %ebp
f0100861:	89 e5                	mov    %esp,%ebp
f0100863:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100866:	e8 67 fe ff ff       	call   f01006d2 <cons_getc>
f010086b:	85 c0                	test   %eax,%eax
f010086d:	74 f7                	je     f0100866 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010086f:	c9                   	leave  
f0100870:	c3                   	ret    

f0100871 <iscons>:

int
iscons(int fdnum)
{
f0100871:	55                   	push   %ebp
f0100872:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100874:	b8 01 00 00 00       	mov    $0x1,%eax
f0100879:	5d                   	pop    %ebp
f010087a:	c3                   	ret    

f010087b <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010087b:	55                   	push   %ebp
f010087c:	89 e5                	mov    %esp,%ebp
f010087e:	56                   	push   %esi
f010087f:	53                   	push   %ebx
f0100880:	bb 40 76 10 f0       	mov    $0xf0107640,%ebx
f0100885:	be 7c 76 10 f0       	mov    $0xf010767c,%esi
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010088a:	83 ec 04             	sub    $0x4,%esp
f010088d:	ff 73 04             	pushl  0x4(%ebx)
f0100890:	ff 33                	pushl  (%ebx)
f0100892:	68 60 71 10 f0       	push   $0xf0107160
f0100897:	e8 1e 37 00 00       	call   f0103fba <cprintf>
f010089c:	83 c3 0c             	add    $0xc,%ebx
	for (i = 0; i < ARRAY_SIZE(commands); i++)
f010089f:	83 c4 10             	add    $0x10,%esp
f01008a2:	39 f3                	cmp    %esi,%ebx
f01008a4:	75 e4                	jne    f010088a <mon_help+0xf>
	return 0;
}
f01008a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01008ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01008ae:	5b                   	pop    %ebx
f01008af:	5e                   	pop    %esi
f01008b0:	5d                   	pop    %ebp
f01008b1:	c3                   	ret    

f01008b2 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01008b2:	55                   	push   %ebp
f01008b3:	89 e5                	mov    %esp,%ebp
f01008b5:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01008b8:	68 69 71 10 f0       	push   $0xf0107169
f01008bd:	e8 f8 36 00 00       	call   f0103fba <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01008c2:	83 c4 08             	add    $0x8,%esp
f01008c5:	68 0c 00 10 00       	push   $0x10000c
f01008ca:	68 c0 72 10 f0       	push   $0xf01072c0
f01008cf:	e8 e6 36 00 00       	call   f0103fba <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01008d4:	83 c4 0c             	add    $0xc,%esp
f01008d7:	68 0c 00 10 00       	push   $0x10000c
f01008dc:	68 0c 00 10 f0       	push   $0xf010000c
f01008e1:	68 e8 72 10 f0       	push   $0xf01072e8
f01008e6:	e8 cf 36 00 00       	call   f0103fba <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01008eb:	83 c4 0c             	add    $0xc,%esp
f01008ee:	68 5c 6d 10 00       	push   $0x106d5c
f01008f3:	68 5c 6d 10 f0       	push   $0xf0106d5c
f01008f8:	68 0c 73 10 f0       	push   $0xf010730c
f01008fd:	e8 b8 36 00 00       	call   f0103fba <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100902:	83 c4 0c             	add    $0xc,%esp
f0100905:	68 34 45 2a 00       	push   $0x2a4534
f010090a:	68 34 45 2a f0       	push   $0xf02a4534
f010090f:	68 30 73 10 f0       	push   $0xf0107330
f0100914:	e8 a1 36 00 00       	call   f0103fba <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100919:	83 c4 0c             	add    $0xc,%esp
f010091c:	68 08 70 2e 00       	push   $0x2e7008
f0100921:	68 08 70 2e f0       	push   $0xf02e7008
f0100926:	68 54 73 10 f0       	push   $0xf0107354
f010092b:	e8 8a 36 00 00       	call   f0103fba <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100930:	b8 07 74 2e f0       	mov    $0xf02e7407,%eax
f0100935:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f010093a:	83 c4 08             	add    $0x8,%esp
f010093d:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100942:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100948:	85 c0                	test   %eax,%eax
f010094a:	0f 48 c2             	cmovs  %edx,%eax
f010094d:	c1 f8 0a             	sar    $0xa,%eax
f0100950:	50                   	push   %eax
f0100951:	68 78 73 10 f0       	push   $0xf0107378
f0100956:	e8 5f 36 00 00       	call   f0103fba <cprintf>
	return 0;
}
f010095b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100960:	c9                   	leave  
f0100961:	c3                   	ret    

f0100962 <mon_showmap>:
	}
	return 0;
}

int 
mon_showmap(int argc, char **argv, struct Trapframe *tf) {
f0100962:	55                   	push   %ebp
f0100963:	89 e5                	mov    %esp,%ebp
f0100965:	56                   	push   %esi
f0100966:	53                   	push   %ebx
f0100967:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc <= 2) {
f010096a:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f010096e:	7f 15                	jg     f0100985 <mon_showmap+0x23>
		cprintf("Usage: showmap l r\n");
f0100970:	83 ec 0c             	sub    $0xc,%esp
f0100973:	68 82 71 10 f0       	push   $0xf0107182
f0100978:	e8 3d 36 00 00       	call   f0103fba <cprintf>
		return 0;
f010097d:	83 c4 10             	add    $0x10,%esp
f0100980:	e9 a6 00 00 00       	jmp    f0100a2b <mon_showmap+0xc9>
	}
	uintptr_t l = strtoul(argv[1], NULL, 0), 
f0100985:	83 ec 04             	sub    $0x4,%esp
f0100988:	6a 00                	push   $0x0
f010098a:	6a 00                	push   $0x0
f010098c:	ff 76 04             	pushl  0x4(%esi)
f010098f:	e8 a6 58 00 00       	call   f010623a <strtoul>
f0100994:	89 c3                	mov    %eax,%ebx
		 	  r = strtoul(argv[2], NULL, 0); // In string.h
f0100996:	83 c4 0c             	add    $0xc,%esp
f0100999:	6a 00                	push   $0x0
f010099b:	6a 00                	push   $0x0
f010099d:	ff 76 08             	pushl  0x8(%esi)
f01009a0:	e8 95 58 00 00       	call   f010623a <strtoul>
	if (l > r) {
f01009a5:	83 c4 10             	add    $0x10,%esp
f01009a8:	39 c3                	cmp    %eax,%ebx
f01009aa:	76 12                	jbe    f01009be <mon_showmap+0x5c>
		cprintf("Invalid range; aborting.\n");
f01009ac:	83 ec 0c             	sub    $0xc,%esp
f01009af:	68 96 71 10 f0       	push   $0xf0107196
f01009b4:	e8 01 36 00 00       	call   f0103fba <cprintf>
		return 0;
f01009b9:	83 c4 10             	add    $0x10,%esp
f01009bc:	eb 6d                	jmp    f0100a2b <mon_showmap+0xc9>
	}
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f01009be:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f01009c4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f01009ca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009cf:	89 c6                	mov    %eax,%esi
f01009d1:	eb 54                	jmp    f0100a27 <mon_showmap+0xc5>
		pte_t* pte = pgdir_walk(kern_pgdir, (void*) sz, 0);
f01009d3:	83 ec 04             	sub    $0x4,%esp
f01009d6:	6a 00                	push   $0x0
f01009d8:	53                   	push   %ebx
f01009d9:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f01009df:	e8 31 0b 00 00       	call   f0101515 <pgdir_walk>
		if (pte == NULL || !*pte)
f01009e4:	83 c4 10             	add    $0x10,%esp
f01009e7:	85 c0                	test   %eax,%eax
f01009e9:	74 06                	je     f01009f1 <mon_showmap+0x8f>
f01009eb:	8b 10                	mov    (%eax),%edx
f01009ed:	85 d2                	test   %edx,%edx
f01009ef:	75 13                	jne    f0100a04 <mon_showmap+0xa2>
			cprintf("0x%08x -> ----------; perm = ---\n", sz);
f01009f1:	83 ec 08             	sub    $0x8,%esp
f01009f4:	53                   	push   %ebx
f01009f5:	68 a4 73 10 f0       	push   $0xf01073a4
f01009fa:	e8 bb 35 00 00       	call   f0103fba <cprintf>
f01009ff:	83 c4 10             	add    $0x10,%esp
f0100a02:	eb 1d                	jmp    f0100a21 <mon_showmap+0xbf>
		else 
			cprintf("0x%08x -> 0x%08x; perm = 0x%03x\n", 
f0100a04:	89 d0                	mov    %edx,%eax
f0100a06:	25 ff 0f 00 00       	and    $0xfff,%eax
f0100a0b:	50                   	push   %eax
f0100a0c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a12:	52                   	push   %edx
f0100a13:	53                   	push   %ebx
f0100a14:	68 c8 73 10 f0       	push   $0xf01073c8
f0100a19:	e8 9c 35 00 00       	call   f0103fba <cprintf>
f0100a1e:	83 c4 10             	add    $0x10,%esp
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f0100a21:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100a27:	39 f3                	cmp    %esi,%ebx
f0100a29:	76 a8                	jbe    f01009d3 <mon_showmap+0x71>
					sz, PTE_ADDR(*pte), *pte & 0xFFF);
	}
	return 0;
}
f0100a2b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a30:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100a33:	5b                   	pop    %ebx
f0100a34:	5e                   	pop    %esi
f0100a35:	5d                   	pop    %ebp
f0100a36:	c3                   	ret    

f0100a37 <mon_chmod>:

int
mon_chmod(int argc, char **argv, struct Trapframe *tf) {
f0100a37:	55                   	push   %ebp
f0100a38:	89 e5                	mov    %esp,%ebp
f0100a3a:	57                   	push   %edi
f0100a3b:	56                   	push   %esi
f0100a3c:	53                   	push   %ebx
f0100a3d:	83 ec 1c             	sub    $0x1c,%esp
f0100a40:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100a43:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc <= 2) {
f0100a46:	83 ff 02             	cmp    $0x2,%edi
f0100a49:	7f 15                	jg     f0100a60 <mon_chmod+0x29>
		cprintf("Usage: chmod mod l [r] [-v]\n");
f0100a4b:	83 ec 0c             	sub    $0xc,%esp
f0100a4e:	68 b0 71 10 f0       	push   $0xf01071b0
f0100a53:	e8 62 35 00 00       	call   f0103fba <cprintf>
		return 0;
f0100a58:	83 c4 10             	add    $0x10,%esp
f0100a5b:	e9 4e 01 00 00       	jmp    f0100bae <mon_chmod+0x177>
	}
	uintptr_t mod = strtoul(argv[1], NULL, 0),  
f0100a60:	83 ec 04             	sub    $0x4,%esp
f0100a63:	6a 00                	push   $0x0
f0100a65:	6a 00                	push   $0x0
f0100a67:	ff 76 04             	pushl  0x4(%esi)
f0100a6a:	e8 cb 57 00 00       	call   f010623a <strtoul>
f0100a6f:	89 45 e0             	mov    %eax,-0x20(%ebp)
			  l = strtoul(argv[2], NULL, 0), 
f0100a72:	83 c4 0c             	add    $0xc,%esp
f0100a75:	6a 00                	push   $0x0
f0100a77:	6a 00                	push   $0x0
f0100a79:	ff 76 08             	pushl  0x8(%esi)
f0100a7c:	e8 b9 57 00 00       	call   f010623a <strtoul>
f0100a81:	89 c3                	mov    %eax,%ebx
			  r = argc >= 4 ? strtoul(argv[3], NULL, 0) : l;
f0100a83:	83 c4 10             	add    $0x10,%esp
f0100a86:	83 ff 03             	cmp    $0x3,%edi
f0100a89:	0f 8e 05 01 00 00    	jle    f0100b94 <mon_chmod+0x15d>
f0100a8f:	83 ec 04             	sub    $0x4,%esp
f0100a92:	6a 00                	push   $0x0
f0100a94:	6a 00                	push   $0x0
f0100a96:	ff 76 0c             	pushl  0xc(%esi)
f0100a99:	e8 9c 57 00 00       	call   f010623a <strtoul>
f0100a9e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
f0100aa1:	83 c4 08             	add    $0x8,%esp
f0100aa4:	68 cd 71 10 f0       	push   $0xf01071cd
f0100aa9:	ff 76 0c             	pushl  0xc(%esi)
f0100aac:	e8 ec 54 00 00       	call   f0105f9d <strcmp>
f0100ab1:	83 c4 10             	add    $0x10,%esp
f0100ab4:	85 c0                	test   %eax,%eax
f0100ab6:	0f 94 c0             	sete   %al
f0100ab9:	0f b6 c0             	movzbl %al,%eax
f0100abc:	89 c7                	mov    %eax,%edi
	if (mod > 0xFFF) {
f0100abe:	81 7d e0 ff 0f 00 00 	cmpl   $0xfff,-0x20(%ebp)
f0100ac5:	76 15                	jbe    f0100adc <mon_chmod+0xa5>
		cprintf("Permission exceeds 0xfff; aborting.\n");
f0100ac7:	83 ec 0c             	sub    $0xc,%esp
f0100aca:	68 ec 73 10 f0       	push   $0xf01073ec
f0100acf:	e8 e6 34 00 00       	call   f0103fba <cprintf>
		return 0;
f0100ad4:	83 c4 10             	add    $0x10,%esp
f0100ad7:	e9 d2 00 00 00       	jmp    f0100bae <mon_chmod+0x177>
	}
	if (l > r) {
f0100adc:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0100adf:	76 15                	jbe    f0100af6 <mon_chmod+0xbf>
		cprintf("Invalid range; aborting.\n");
f0100ae1:	83 ec 0c             	sub    $0xc,%esp
f0100ae4:	68 96 71 10 f0       	push   $0xf0107196
f0100ae9:	e8 cc 34 00 00       	call   f0103fba <cprintf>
		return 0;
f0100aee:	83 c4 10             	add    $0x10,%esp
f0100af1:	e9 b8 00 00 00       	jmp    f0100bae <mon_chmod+0x177>
	}
	if (!(mod & PTE_P)) {
f0100af6:	f6 45 e0 01          	testb  $0x1,-0x20(%ebp)
f0100afa:	75 14                	jne    f0100b10 <mon_chmod+0xd9>
		cprintf("Warning: PTE_P flag is not provided; added automatically.");
f0100afc:	83 ec 0c             	sub    $0xc,%esp
f0100aff:	68 14 74 10 f0       	push   $0xf0107414
f0100b04:	e8 b1 34 00 00       	call   f0103fba <cprintf>
		mod |= PTE_P;
f0100b09:	83 4d e0 01          	orl    $0x1,-0x20(%ebp)
f0100b0d:	83 c4 10             	add    $0x10,%esp
	}
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f0100b10:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f0100b16:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0100b1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b1f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b24:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100b27:	eb 64                	jmp    f0100b8d <mon_chmod+0x156>
		pte_t* pte = pgdir_walk(kern_pgdir, (void*) sz, 0);
f0100b29:	83 ec 04             	sub    $0x4,%esp
f0100b2c:	6a 00                	push   $0x0
f0100b2e:	53                   	push   %ebx
f0100b2f:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f0100b35:	e8 db 09 00 00       	call   f0101515 <pgdir_walk>
f0100b3a:	89 c6                	mov    %eax,%esi
		if (pte == NULL || !*pte) {
f0100b3c:	83 c4 10             	add    $0x10,%esp
f0100b3f:	85 c0                	test   %eax,%eax
f0100b41:	74 06                	je     f0100b49 <mon_chmod+0x112>
f0100b43:	8b 00                	mov    (%eax),%eax
f0100b45:	85 c0                	test   %eax,%eax
f0100b47:	75 17                	jne    f0100b60 <mon_chmod+0x129>
			if (verbose)
f0100b49:	85 ff                	test   %edi,%edi
f0100b4b:	74 3a                	je     f0100b87 <mon_chmod+0x150>
				cprintf("Page va = 0x%08x is not mapped; skipping.\n", sz);
f0100b4d:	83 ec 08             	sub    $0x8,%esp
f0100b50:	53                   	push   %ebx
f0100b51:	68 50 74 10 f0       	push   $0xf0107450
f0100b56:	e8 5f 34 00 00       	call   f0103fba <cprintf>
f0100b5b:	83 c4 10             	add    $0x10,%esp
f0100b5e:	eb 27                	jmp    f0100b87 <mon_chmod+0x150>
		}
		else {
			if (verbose) 
f0100b60:	85 ff                	test   %edi,%edi
f0100b62:	74 17                	je     f0100b7b <mon_chmod+0x144>
				cprintf("Page va = 0x%08x perm = 0x%03x changed to 0x%03x\n", 
f0100b64:	ff 75 e0             	pushl  -0x20(%ebp)
f0100b67:	25 ff 0f 00 00       	and    $0xfff,%eax
f0100b6c:	50                   	push   %eax
f0100b6d:	53                   	push   %ebx
f0100b6e:	68 7c 74 10 f0       	push   $0xf010747c
f0100b73:	e8 42 34 00 00       	call   f0103fba <cprintf>
f0100b78:	83 c4 10             	add    $0x10,%esp
						sz, *pte & 0xFFF, mod);
			*pte = PTE_ADDR(*pte) | mod;
f0100b7b:	8b 06                	mov    (%esi),%eax
f0100b7d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b82:	0b 45 e0             	or     -0x20(%ebp),%eax
f0100b85:	89 06                	mov    %eax,(%esi)
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f0100b87:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100b8d:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0100b90:	76 97                	jbe    f0100b29 <mon_chmod+0xf2>
f0100b92:	eb 1a                	jmp    f0100bae <mon_chmod+0x177>
	if (mod > 0xFFF) {
f0100b94:	81 7d e0 ff 0f 00 00 	cmpl   $0xfff,-0x20(%ebp)
f0100b9b:	0f 87 26 ff ff ff    	ja     f0100ac7 <mon_chmod+0x90>
			  r = argc >= 4 ? strtoul(argv[3], NULL, 0) : l;
f0100ba1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
f0100ba4:	bf 00 00 00 00       	mov    $0x0,%edi
f0100ba9:	e9 48 ff ff ff       	jmp    f0100af6 <mon_chmod+0xbf>
		}
	}
	return 0;
}
f0100bae:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100bb6:	5b                   	pop    %ebx
f0100bb7:	5e                   	pop    %esi
f0100bb8:	5f                   	pop    %edi
f0100bb9:	5d                   	pop    %ebp
f0100bba:	c3                   	ret    

f0100bbb <mon_dump>:

int
mon_dump(int argc, char **argv, struct Trapframe *tf) {
f0100bbb:	55                   	push   %ebp
f0100bbc:	89 e5                	mov    %esp,%ebp
f0100bbe:	57                   	push   %edi
f0100bbf:	56                   	push   %esi
f0100bc0:	53                   	push   %ebx
f0100bc1:	83 ec 1c             	sub    $0x1c,%esp
f0100bc4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (argc <= 2 || argc > 4) {
f0100bc7:	8d 43 fd             	lea    -0x3(%ebx),%eax
f0100bca:	83 f8 01             	cmp    $0x1,%eax
f0100bcd:	76 15                	jbe    f0100be4 <mon_dump+0x29>
		cprintf("Usage: dump l r [-v/-p]\n");
f0100bcf:	83 ec 0c             	sub    $0xc,%esp
f0100bd2:	68 d0 71 10 f0       	push   $0xf01071d0
f0100bd7:	e8 de 33 00 00       	call   f0103fba <cprintf>
		return 0;
f0100bdc:	83 c4 10             	add    $0x10,%esp
f0100bdf:	e9 c4 01 00 00       	jmp    f0100da8 <mon_dump+0x1ed>
	}
	unsigned long l = strtoul(argv[1], NULL, 0),
f0100be4:	83 ec 04             	sub    $0x4,%esp
f0100be7:	6a 00                	push   $0x0
f0100be9:	6a 00                	push   $0x0
f0100beb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100bee:	ff 70 04             	pushl  0x4(%eax)
f0100bf1:	e8 44 56 00 00       	call   f010623a <strtoul>
f0100bf6:	89 c6                	mov    %eax,%esi
			  	  r = strtoul(argv[2], NULL, 0);
f0100bf8:	83 c4 0c             	add    $0xc,%esp
f0100bfb:	6a 00                	push   $0x0
f0100bfd:	6a 00                	push   $0x0
f0100bff:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c02:	ff 70 08             	pushl  0x8(%eax)
f0100c05:	e8 30 56 00 00       	call   f010623a <strtoul>
f0100c0a:	89 c7                	mov    %eax,%edi
	int virtual;  // If 0 then physical
	if (argc <= 3)
f0100c0c:	83 c4 10             	add    $0x10,%esp
f0100c0f:	83 fb 03             	cmp    $0x3,%ebx
f0100c12:	7f 15                	jg     f0100c29 <mon_dump+0x6e>
		cprintf("Defaulting to virtual address.\n");
f0100c14:	83 ec 0c             	sub    $0xc,%esp
f0100c17:	68 b0 74 10 f0       	push   $0xf01074b0
f0100c1c:	e8 99 33 00 00       	call   f0103fba <cprintf>
f0100c21:	83 c4 10             	add    $0x10,%esp
f0100c24:	e9 9e 00 00 00       	jmp    f0100cc7 <mon_dump+0x10c>
	else if (!strcmp(argv[3], "-p"))
f0100c29:	83 ec 08             	sub    $0x8,%esp
f0100c2c:	68 e9 71 10 f0       	push   $0xf01071e9
f0100c31:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c34:	ff 70 0c             	pushl  0xc(%eax)
f0100c37:	e8 61 53 00 00       	call   f0105f9d <strcmp>
f0100c3c:	83 c4 10             	add    $0x10,%esp
f0100c3f:	85 c0                	test   %eax,%eax
f0100c41:	75 4f                	jne    f0100c92 <mon_dump+0xd7>
	if (PGNUM(pa) >= npages)
f0100c43:	a1 88 5e 2a f0       	mov    0xf02a5e88,%eax
f0100c48:	89 f2                	mov    %esi,%edx
f0100c4a:	c1 ea 0c             	shr    $0xc,%edx
f0100c4d:	39 c2                	cmp    %eax,%edx
f0100c4f:	72 15                	jb     f0100c66 <mon_dump+0xab>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c51:	56                   	push   %esi
f0100c52:	68 c8 6e 10 f0       	push   $0xf0106ec8
f0100c57:	68 9d 00 00 00       	push   $0x9d
f0100c5c:	68 ec 71 10 f0       	push   $0xf01071ec
f0100c61:	e8 2e f4 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0100c66:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
	if (PGNUM(pa) >= npages)
f0100c6c:	89 fa                	mov    %edi,%edx
f0100c6e:	c1 ea 0c             	shr    $0xc,%edx
f0100c71:	39 c2                	cmp    %eax,%edx
f0100c73:	72 15                	jb     f0100c8a <mon_dump+0xcf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c75:	57                   	push   %edi
f0100c76:	68 c8 6e 10 f0       	push   $0xf0106ec8
f0100c7b:	68 9d 00 00 00       	push   $0x9d
f0100c80:	68 ec 71 10 f0       	push   $0xf01071ec
f0100c85:	e8 0a f4 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0100c8a:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
f0100c90:	eb 35                	jmp    f0100cc7 <mon_dump+0x10c>
		l = (unsigned long)KADDR(l), r = (unsigned long)KADDR(r);
	else if (strcmp(argv[3], "-v")) {
f0100c92:	83 ec 08             	sub    $0x8,%esp
f0100c95:	68 cd 71 10 f0       	push   $0xf01071cd
f0100c9a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c9d:	ff 70 0c             	pushl  0xc(%eax)
f0100ca0:	e8 f8 52 00 00       	call   f0105f9d <strcmp>
f0100ca5:	83 c4 10             	add    $0x10,%esp
f0100ca8:	85 c0                	test   %eax,%eax
f0100caa:	74 1b                	je     f0100cc7 <mon_dump+0x10c>
		cprintf("Unknown flag %s at position 3; aborting.\n", argv[3]);
f0100cac:	83 ec 08             	sub    $0x8,%esp
f0100caf:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100cb2:	ff 70 0c             	pushl  0xc(%eax)
f0100cb5:	68 d0 74 10 f0       	push   $0xf01074d0
f0100cba:	e8 fb 32 00 00       	call   f0103fba <cprintf>
		return 0;
f0100cbf:	83 c4 10             	add    $0x10,%esp
f0100cc2:	e9 e1 00 00 00       	jmp    f0100da8 <mon_dump+0x1ed>
	}
	uintptr_t ptr;
	for (ptr = ROUNDDOWN(l, 16); ptr <= r; ptr += 16) {
f0100cc7:	83 e6 f0             	and    $0xfffffff0,%esi
f0100cca:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0100ccd:	83 c6 10             	add    $0x10,%esi
f0100cd0:	e9 b1 00 00 00       	jmp    f0100d86 <mon_dump+0x1cb>
		cprintf("%08x  ", ptr);
f0100cd5:	83 ec 08             	sub    $0x8,%esp
f0100cd8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100cdb:	53                   	push   %ebx
f0100cdc:	68 fb 71 10 f0       	push   $0xf01071fb
f0100ce1:	e8 d4 32 00 00       	call   f0103fba <cprintf>
f0100ce6:	83 c4 10             	add    $0x10,%esp
		for (int i = 0; i < 16; i++) {
			if (ptr + i <= r)
f0100ce9:	39 df                	cmp    %ebx,%edi
f0100ceb:	72 16                	jb     f0100d03 <mon_dump+0x148>
				cprintf("%02x ", *(unsigned char*)(ptr + i));
f0100ced:	83 ec 08             	sub    $0x8,%esp
f0100cf0:	0f b6 03             	movzbl (%ebx),%eax
f0100cf3:	50                   	push   %eax
f0100cf4:	68 02 72 10 f0       	push   $0xf0107202
f0100cf9:	e8 bc 32 00 00       	call   f0103fba <cprintf>
f0100cfe:	83 c4 10             	add    $0x10,%esp
f0100d01:	eb 10                	jmp    f0100d13 <mon_dump+0x158>
			else 
				cprintf("   ");
f0100d03:	83 ec 0c             	sub    $0xc,%esp
f0100d06:	68 08 72 10 f0       	push   $0xf0107208
f0100d0b:	e8 aa 32 00 00       	call   f0103fba <cprintf>
f0100d10:	83 c4 10             	add    $0x10,%esp
f0100d13:	83 c3 01             	add    $0x1,%ebx
		for (int i = 0; i < 16; i++) {
f0100d16:	39 f3                	cmp    %esi,%ebx
f0100d18:	75 cf                	jne    f0100ce9 <mon_dump+0x12e>
		}
		cprintf(" |");
f0100d1a:	83 ec 0c             	sub    $0xc,%esp
f0100d1d:	68 0c 72 10 f0       	push   $0xf010720c
f0100d22:	e8 93 32 00 00       	call   f0103fba <cprintf>
f0100d27:	83 c4 10             	add    $0x10,%esp
f0100d2a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		for (int i = 0; i < 16; i++) {
			if (ptr + i <= r) {
f0100d2d:	39 df                	cmp    %ebx,%edi
f0100d2f:	72 27                	jb     f0100d58 <mon_dump+0x19d>
				char ch = *(char*)(ptr + i);
f0100d31:	0f b6 03             	movzbl (%ebx),%eax
				cprintf("%c", (ch >= ' ' && ch <= '~') ? ch : '.');
f0100d34:	8d 50 e0             	lea    -0x20(%eax),%edx
f0100d37:	0f be c0             	movsbl %al,%eax
f0100d3a:	80 fa 5e             	cmp    $0x5e,%dl
f0100d3d:	b9 2e 00 00 00       	mov    $0x2e,%ecx
f0100d42:	0f 47 c1             	cmova  %ecx,%eax
f0100d45:	83 ec 08             	sub    $0x8,%esp
f0100d48:	50                   	push   %eax
f0100d49:	68 0f 72 10 f0       	push   $0xf010720f
f0100d4e:	e8 67 32 00 00       	call   f0103fba <cprintf>
f0100d53:	83 c4 10             	add    $0x10,%esp
f0100d56:	eb 10                	jmp    f0100d68 <mon_dump+0x1ad>
			}
			else 
				cprintf(" ");
f0100d58:	83 ec 0c             	sub    $0xc,%esp
f0100d5b:	68 4c 72 10 f0       	push   $0xf010724c
f0100d60:	e8 55 32 00 00       	call   f0103fba <cprintf>
f0100d65:	83 c4 10             	add    $0x10,%esp
f0100d68:	83 c3 01             	add    $0x1,%ebx
		for (int i = 0; i < 16; i++) {
f0100d6b:	39 f3                	cmp    %esi,%ebx
f0100d6d:	75 be                	jne    f0100d2d <mon_dump+0x172>
		}
		cprintf("|\n");
f0100d6f:	83 ec 0c             	sub    $0xc,%esp
f0100d72:	68 12 72 10 f0       	push   $0xf0107212
f0100d77:	e8 3e 32 00 00       	call   f0103fba <cprintf>
	for (ptr = ROUNDDOWN(l, 16); ptr <= r; ptr += 16) {
f0100d7c:	83 45 e4 10          	addl   $0x10,-0x1c(%ebp)
f0100d80:	83 c6 10             	add    $0x10,%esi
f0100d83:	83 c4 10             	add    $0x10,%esp
f0100d86:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0100d89:	0f 83 46 ff ff ff    	jae    f0100cd5 <mon_dump+0x11a>
	}
	if (ROUNDDOWN(r, 16) != r)
f0100d8f:	f7 c7 0f 00 00 00    	test   $0xf,%edi
f0100d95:	74 11                	je     f0100da8 <mon_dump+0x1ed>
		cprintf("%08x  \n", r);
f0100d97:	83 ec 08             	sub    $0x8,%esp
f0100d9a:	57                   	push   %edi
f0100d9b:	68 15 72 10 f0       	push   $0xf0107215
f0100da0:	e8 15 32 00 00       	call   f0103fba <cprintf>
f0100da5:	83 c4 10             	add    $0x10,%esp
	return 0;
}
f0100da8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dad:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100db0:	5b                   	pop    %ebx
f0100db1:	5e                   	pop    %esi
f0100db2:	5f                   	pop    %edi
f0100db3:	5d                   	pop    %ebp
f0100db4:	c3                   	ret    

f0100db5 <mon_backtrace>:
{
f0100db5:	55                   	push   %ebp
f0100db6:	89 e5                	mov    %esp,%ebp
f0100db8:	57                   	push   %edi
f0100db9:	56                   	push   %esi
f0100dba:	53                   	push   %ebx
f0100dbb:	83 ec 38             	sub    $0x38,%esp
	cprintf("Stack backtrace:\n");
f0100dbe:	68 1d 72 10 f0       	push   $0xf010721d
f0100dc3:	e8 f2 31 00 00       	call   f0103fba <cprintf>
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100dc8:	89 e8                	mov    %ebp,%eax
	while (ebp != 0) {
f0100dca:	83 c4 10             	add    $0x10,%esp
f0100dcd:	e9 80 00 00 00       	jmp    f0100e52 <mon_backtrace+0x9d>
		prev_ebp = *(int*)ebp;
f0100dd2:	8b 38                	mov    (%eax),%edi
		eip = *((int*)ebp + 1);
f0100dd4:	8b 70 04             	mov    0x4(%eax),%esi
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, 
f0100dd7:	ff 70 18             	pushl  0x18(%eax)
f0100dda:	ff 70 14             	pushl  0x14(%eax)
f0100ddd:	ff 70 10             	pushl  0x10(%eax)
f0100de0:	ff 70 0c             	pushl  0xc(%eax)
f0100de3:	ff 70 08             	pushl  0x8(%eax)
f0100de6:	56                   	push   %esi
f0100de7:	50                   	push   %eax
f0100de8:	68 fc 74 10 f0       	push   $0xf01074fc
f0100ded:	e8 c8 31 00 00       	call   f0103fba <cprintf>
		int code = debuginfo_eip((uintptr_t)eip, &info);
f0100df2:	83 c4 18             	add    $0x18,%esp
f0100df5:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100df8:	50                   	push   %eax
f0100df9:	56                   	push   %esi
f0100dfa:	e8 c3 47 00 00       	call   f01055c2 <debuginfo_eip>
		cprintf("         %s:%d: ", info.eip_file, info.eip_line);
f0100dff:	83 c4 0c             	add    $0xc,%esp
f0100e02:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100e05:	ff 75 d0             	pushl  -0x30(%ebp)
f0100e08:	68 2f 72 10 f0       	push   $0xf010722f
f0100e0d:	e8 a8 31 00 00       	call   f0103fba <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f0100e12:	83 c4 10             	add    $0x10,%esp
f0100e15:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e1a:	eb 1b                	jmp    f0100e37 <mon_backtrace+0x82>
			cprintf("%c", info.eip_fn_name[i]);
f0100e1c:	83 ec 08             	sub    $0x8,%esp
f0100e1f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e22:	0f be 04 18          	movsbl (%eax,%ebx,1),%eax
f0100e26:	50                   	push   %eax
f0100e27:	68 0f 72 10 f0       	push   $0xf010720f
f0100e2c:	e8 89 31 00 00       	call   f0103fba <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f0100e31:	83 c3 01             	add    $0x1,%ebx
f0100e34:	83 c4 10             	add    $0x10,%esp
f0100e37:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
f0100e3a:	7c e0                	jl     f0100e1c <mon_backtrace+0x67>
		cprintf("+%d\n", eip - info.eip_fn_addr);
f0100e3c:	83 ec 08             	sub    $0x8,%esp
f0100e3f:	2b 75 e0             	sub    -0x20(%ebp),%esi
f0100e42:	56                   	push   %esi
f0100e43:	68 40 72 10 f0       	push   $0xf0107240
f0100e48:	e8 6d 31 00 00       	call   f0103fba <cprintf>
f0100e4d:	83 c4 10             	add    $0x10,%esp
		ebp = prev_ebp;
f0100e50:	89 f8                	mov    %edi,%eax
	while (ebp != 0) {
f0100e52:	85 c0                	test   %eax,%eax
f0100e54:	0f 85 78 ff ff ff    	jne    f0100dd2 <mon_backtrace+0x1d>
}
f0100e5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e5d:	5b                   	pop    %ebx
f0100e5e:	5e                   	pop    %esi
f0100e5f:	5f                   	pop    %edi
f0100e60:	5d                   	pop    %ebp
f0100e61:	c3                   	ret    

f0100e62 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100e62:	55                   	push   %ebp
f0100e63:	89 e5                	mov    %esp,%ebp
f0100e65:	57                   	push   %edi
f0100e66:	56                   	push   %esi
f0100e67:	53                   	push   %ebx
f0100e68:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100e6b:	68 34 75 10 f0       	push   $0xf0107534
f0100e70:	e8 45 31 00 00       	call   f0103fba <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100e75:	c7 04 24 58 75 10 f0 	movl   $0xf0107558,(%esp)
f0100e7c:	e8 39 31 00 00       	call   f0103fba <cprintf>

	if (tf != NULL)
f0100e81:	83 c4 10             	add    $0x10,%esp
f0100e84:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100e88:	74 0e                	je     f0100e98 <monitor+0x36>
		print_trapframe(tf);
f0100e8a:	83 ec 0c             	sub    $0xc,%esp
f0100e8d:	ff 75 08             	pushl  0x8(%ebp)
f0100e90:	e8 55 38 00 00       	call   f01046ea <print_trapframe>
f0100e95:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100e98:	83 ec 0c             	sub    $0xc,%esp
f0100e9b:	68 45 72 10 f0       	push   $0xf0107245
f0100ea0:	e8 1e 4f 00 00       	call   f0105dc3 <readline>
f0100ea5:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100ea7:	83 c4 10             	add    $0x10,%esp
f0100eaa:	85 c0                	test   %eax,%eax
f0100eac:	74 ea                	je     f0100e98 <monitor+0x36>
	argv[argc] = 0;
f0100eae:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100eb5:	be 00 00 00 00       	mov    $0x0,%esi
f0100eba:	eb 0a                	jmp    f0100ec6 <monitor+0x64>
			*buf++ = 0;
f0100ebc:	c6 03 00             	movb   $0x0,(%ebx)
f0100ebf:	89 f7                	mov    %esi,%edi
f0100ec1:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100ec4:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100ec6:	0f b6 03             	movzbl (%ebx),%eax
f0100ec9:	84 c0                	test   %al,%al
f0100ecb:	74 63                	je     f0100f30 <monitor+0xce>
f0100ecd:	83 ec 08             	sub    $0x8,%esp
f0100ed0:	0f be c0             	movsbl %al,%eax
f0100ed3:	50                   	push   %eax
f0100ed4:	68 49 72 10 f0       	push   $0xf0107249
f0100ed9:	e8 1d 51 00 00       	call   f0105ffb <strchr>
f0100ede:	83 c4 10             	add    $0x10,%esp
f0100ee1:	85 c0                	test   %eax,%eax
f0100ee3:	75 d7                	jne    f0100ebc <monitor+0x5a>
		if (*buf == 0)
f0100ee5:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100ee8:	74 46                	je     f0100f30 <monitor+0xce>
		if (argc == MAXARGS-1) {
f0100eea:	83 fe 0f             	cmp    $0xf,%esi
f0100eed:	75 14                	jne    f0100f03 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100eef:	83 ec 08             	sub    $0x8,%esp
f0100ef2:	6a 10                	push   $0x10
f0100ef4:	68 4e 72 10 f0       	push   $0xf010724e
f0100ef9:	e8 bc 30 00 00       	call   f0103fba <cprintf>
f0100efe:	83 c4 10             	add    $0x10,%esp
f0100f01:	eb 95                	jmp    f0100e98 <monitor+0x36>
		argv[argc++] = buf;
f0100f03:	8d 7e 01             	lea    0x1(%esi),%edi
f0100f06:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100f0a:	eb 03                	jmp    f0100f0f <monitor+0xad>
			buf++;
f0100f0c:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100f0f:	0f b6 03             	movzbl (%ebx),%eax
f0100f12:	84 c0                	test   %al,%al
f0100f14:	74 ae                	je     f0100ec4 <monitor+0x62>
f0100f16:	83 ec 08             	sub    $0x8,%esp
f0100f19:	0f be c0             	movsbl %al,%eax
f0100f1c:	50                   	push   %eax
f0100f1d:	68 49 72 10 f0       	push   $0xf0107249
f0100f22:	e8 d4 50 00 00       	call   f0105ffb <strchr>
f0100f27:	83 c4 10             	add    $0x10,%esp
f0100f2a:	85 c0                	test   %eax,%eax
f0100f2c:	74 de                	je     f0100f0c <monitor+0xaa>
f0100f2e:	eb 94                	jmp    f0100ec4 <monitor+0x62>
	argv[argc] = 0;
f0100f30:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100f37:	00 
	if (argc == 0)
f0100f38:	85 f6                	test   %esi,%esi
f0100f3a:	0f 84 58 ff ff ff    	je     f0100e98 <monitor+0x36>
f0100f40:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f0100f45:	83 ec 08             	sub    $0x8,%esp
f0100f48:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100f4b:	ff 34 85 40 76 10 f0 	pushl  -0xfef89c0(,%eax,4)
f0100f52:	ff 75 a8             	pushl  -0x58(%ebp)
f0100f55:	e8 43 50 00 00       	call   f0105f9d <strcmp>
f0100f5a:	83 c4 10             	add    $0x10,%esp
f0100f5d:	85 c0                	test   %eax,%eax
f0100f5f:	75 21                	jne    f0100f82 <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f0100f61:	83 ec 04             	sub    $0x4,%esp
f0100f64:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100f67:	ff 75 08             	pushl  0x8(%ebp)
f0100f6a:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100f6d:	52                   	push   %edx
f0100f6e:	56                   	push   %esi
f0100f6f:	ff 14 85 48 76 10 f0 	call   *-0xfef89b8(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100f76:	83 c4 10             	add    $0x10,%esp
f0100f79:	85 c0                	test   %eax,%eax
f0100f7b:	78 25                	js     f0100fa2 <monitor+0x140>
f0100f7d:	e9 16 ff ff ff       	jmp    f0100e98 <monitor+0x36>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100f82:	83 c3 01             	add    $0x1,%ebx
f0100f85:	83 fb 05             	cmp    $0x5,%ebx
f0100f88:	75 bb                	jne    f0100f45 <monitor+0xe3>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100f8a:	83 ec 08             	sub    $0x8,%esp
f0100f8d:	ff 75 a8             	pushl  -0x58(%ebp)
f0100f90:	68 6b 72 10 f0       	push   $0xf010726b
f0100f95:	e8 20 30 00 00       	call   f0103fba <cprintf>
f0100f9a:	83 c4 10             	add    $0x10,%esp
f0100f9d:	e9 f6 fe ff ff       	jmp    f0100e98 <monitor+0x36>
				break;
	}
}
f0100fa2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fa5:	5b                   	pop    %ebx
f0100fa6:	5e                   	pop    %esi
f0100fa7:	5f                   	pop    %edi
f0100fa8:	5d                   	pop    %ebp
f0100fa9:	c3                   	ret    

f0100faa <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100faa:	55                   	push   %ebp
f0100fab:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100fad:	83 3d 38 52 2a f0 00 	cmpl   $0x0,0xf02a5238
f0100fb4:	74 1f                	je     f0100fd5 <boot_alloc+0x2b>
	}

	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	if (!n)
f0100fb6:	85 c0                	test   %eax,%eax
f0100fb8:	74 2e                	je     f0100fe8 <boot_alloc+0x3e>
		return (void*)nextfree;
	else {
		result = nextfree;
f0100fba:	8b 15 38 52 2a f0    	mov    0xf02a5238,%edx
		nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100fc0:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100fc7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100fcc:	a3 38 52 2a f0       	mov    %eax,0xf02a5238
		return (void*)result;
	}
}
f0100fd1:	89 d0                	mov    %edx,%eax
f0100fd3:	5d                   	pop    %ebp
f0100fd4:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100fd5:	ba 07 80 2e f0       	mov    $0xf02e8007,%edx
f0100fda:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100fe0:	89 15 38 52 2a f0    	mov    %edx,0xf02a5238
f0100fe6:	eb ce                	jmp    f0100fb6 <boot_alloc+0xc>
		return (void*)nextfree;
f0100fe8:	8b 15 38 52 2a f0    	mov    0xf02a5238,%edx
f0100fee:	eb e1                	jmp    f0100fd1 <boot_alloc+0x27>

f0100ff0 <nvram_read>:
{
f0100ff0:	55                   	push   %ebp
f0100ff1:	89 e5                	mov    %esp,%ebp
f0100ff3:	56                   	push   %esi
f0100ff4:	53                   	push   %ebx
f0100ff5:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100ff7:	83 ec 0c             	sub    $0xc,%esp
f0100ffa:	50                   	push   %eax
f0100ffb:	e8 3b 2e 00 00       	call   f0103e3b <mc146818_read>
f0101000:	89 c3                	mov    %eax,%ebx
f0101002:	46                   	inc    %esi
f0101003:	89 34 24             	mov    %esi,(%esp)
f0101006:	e8 30 2e 00 00       	call   f0103e3b <mc146818_read>
f010100b:	c1 e0 08             	shl    $0x8,%eax
f010100e:	09 d8                	or     %ebx,%eax
}
f0101010:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101013:	5b                   	pop    %ebx
f0101014:	5e                   	pop    %esi
f0101015:	5d                   	pop    %ebp
f0101016:	c3                   	ret    

f0101017 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0101017:	89 d1                	mov    %edx,%ecx
f0101019:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f010101c:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f010101f:	a8 01                	test   $0x1,%al
f0101021:	74 47                	je     f010106a <check_va2pa+0x53>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0101023:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101028:	89 c1                	mov    %eax,%ecx
f010102a:	c1 e9 0c             	shr    $0xc,%ecx
f010102d:	3b 0d 88 5e 2a f0    	cmp    0xf02a5e88,%ecx
f0101033:	73 1a                	jae    f010104f <check_va2pa+0x38>
	if (!(p[PTX(va)] & PTE_P))
f0101035:	c1 ea 0c             	shr    $0xc,%edx
f0101038:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010103e:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0101045:	a8 01                	test   $0x1,%al
f0101047:	74 27                	je     f0101070 <check_va2pa+0x59>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0101049:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010104e:	c3                   	ret    
{
f010104f:	55                   	push   %ebp
f0101050:	89 e5                	mov    %esp,%ebp
f0101052:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101055:	50                   	push   %eax
f0101056:	68 c8 6e 10 f0       	push   $0xf0106ec8
f010105b:	68 6f 03 00 00       	push   $0x36f
f0101060:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101065:	e8 2a f0 ff ff       	call   f0100094 <_panic>
		return ~0;
f010106a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010106f:	c3                   	ret    
		return ~0;
f0101070:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0101075:	c3                   	ret    

f0101076 <check_page_free_list>:
{
f0101076:	55                   	push   %ebp
f0101077:	89 e5                	mov    %esp,%ebp
f0101079:	57                   	push   %edi
f010107a:	56                   	push   %esi
f010107b:	53                   	push   %ebx
f010107c:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010107f:	84 c0                	test   %al,%al
f0101081:	0f 85 80 02 00 00    	jne    f0101307 <check_page_free_list+0x291>
	if (!page_free_list)
f0101087:	83 3d 40 52 2a f0 00 	cmpl   $0x0,0xf02a5240
f010108e:	74 0a                	je     f010109a <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101090:	be 00 04 00 00       	mov    $0x400,%esi
f0101095:	e9 c8 02 00 00       	jmp    f0101362 <check_page_free_list+0x2ec>
		panic("'page_free_list' is a null pointer!");
f010109a:	83 ec 04             	sub    $0x4,%esp
f010109d:	68 7c 76 10 f0       	push   $0xf010767c
f01010a2:	68 a2 02 00 00       	push   $0x2a2
f01010a7:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01010ac:	e8 e3 ef ff ff       	call   f0100094 <_panic>
f01010b1:	50                   	push   %eax
f01010b2:	68 c8 6e 10 f0       	push   $0xf0106ec8
f01010b7:	6a 58                	push   $0x58
f01010b9:	68 a9 7f 10 f0       	push   $0xf0107fa9
f01010be:	e8 d1 ef ff ff       	call   f0100094 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01010c3:	8b 1b                	mov    (%ebx),%ebx
f01010c5:	85 db                	test   %ebx,%ebx
f01010c7:	74 41                	je     f010110a <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010c9:	89 d8                	mov    %ebx,%eax
f01010cb:	2b 05 90 5e 2a f0    	sub    0xf02a5e90,%eax
f01010d1:	c1 f8 03             	sar    $0x3,%eax
f01010d4:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f01010d7:	89 c2                	mov    %eax,%edx
f01010d9:	c1 ea 16             	shr    $0x16,%edx
f01010dc:	39 f2                	cmp    %esi,%edx
f01010de:	73 e3                	jae    f01010c3 <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f01010e0:	89 c2                	mov    %eax,%edx
f01010e2:	c1 ea 0c             	shr    $0xc,%edx
f01010e5:	3b 15 88 5e 2a f0    	cmp    0xf02a5e88,%edx
f01010eb:	73 c4                	jae    f01010b1 <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f01010ed:	83 ec 04             	sub    $0x4,%esp
f01010f0:	68 80 00 00 00       	push   $0x80
f01010f5:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f01010fa:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010ff:	50                   	push   %eax
f0101100:	e8 33 4f 00 00       	call   f0106038 <memset>
f0101105:	83 c4 10             	add    $0x10,%esp
f0101108:	eb b9                	jmp    f01010c3 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f010110a:	b8 00 00 00 00       	mov    $0x0,%eax
f010110f:	e8 96 fe ff ff       	call   f0100faa <boot_alloc>
f0101114:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101117:	8b 15 40 52 2a f0    	mov    0xf02a5240,%edx
		assert(pp >= pages);
f010111d:	8b 0d 90 5e 2a f0    	mov    0xf02a5e90,%ecx
		assert(pp < pages + npages);
f0101123:	a1 88 5e 2a f0       	mov    0xf02a5e88,%eax
f0101128:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010112b:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f010112e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101131:	89 4d d0             	mov    %ecx,-0x30(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0101134:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101139:	e9 00 01 00 00       	jmp    f010123e <check_page_free_list+0x1c8>
		assert(pp >= pages);
f010113e:	68 b7 7f 10 f0       	push   $0xf0107fb7
f0101143:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0101148:	68 bc 02 00 00       	push   $0x2bc
f010114d:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101152:	e8 3d ef ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0101157:	68 d8 7f 10 f0       	push   $0xf0107fd8
f010115c:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0101161:	68 bd 02 00 00       	push   $0x2bd
f0101166:	68 9d 7f 10 f0       	push   $0xf0107f9d
f010116b:	e8 24 ef ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101170:	68 a0 76 10 f0       	push   $0xf01076a0
f0101175:	68 c3 7f 10 f0       	push   $0xf0107fc3
f010117a:	68 be 02 00 00       	push   $0x2be
f010117f:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101184:	e8 0b ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != 0);
f0101189:	68 ec 7f 10 f0       	push   $0xf0107fec
f010118e:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0101193:	68 c1 02 00 00       	push   $0x2c1
f0101198:	68 9d 7f 10 f0       	push   $0xf0107f9d
f010119d:	e8 f2 ee ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01011a2:	68 fd 7f 10 f0       	push   $0xf0107ffd
f01011a7:	68 c3 7f 10 f0       	push   $0xf0107fc3
f01011ac:	68 c2 02 00 00       	push   $0x2c2
f01011b1:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01011b6:	e8 d9 ee ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01011bb:	68 d4 76 10 f0       	push   $0xf01076d4
f01011c0:	68 c3 7f 10 f0       	push   $0xf0107fc3
f01011c5:	68 c3 02 00 00       	push   $0x2c3
f01011ca:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01011cf:	e8 c0 ee ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01011d4:	68 16 80 10 f0       	push   $0xf0108016
f01011d9:	68 c3 7f 10 f0       	push   $0xf0107fc3
f01011de:	68 c4 02 00 00       	push   $0x2c4
f01011e3:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01011e8:	e8 a7 ee ff ff       	call   f0100094 <_panic>
	if (PGNUM(pa) >= npages)
f01011ed:	89 c7                	mov    %eax,%edi
f01011ef:	c1 ef 0c             	shr    $0xc,%edi
f01011f2:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f01011f5:	76 19                	jbe    f0101210 <check_page_free_list+0x19a>
	return (void *)(pa + KERNBASE);
f01011f7:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01011fd:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0101200:	77 20                	ja     f0101222 <check_page_free_list+0x1ac>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101202:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101207:	0f 84 92 00 00 00    	je     f010129f <check_page_free_list+0x229>
			++nfree_extmem;
f010120d:	43                   	inc    %ebx
f010120e:	eb 2c                	jmp    f010123c <check_page_free_list+0x1c6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101210:	50                   	push   %eax
f0101211:	68 c8 6e 10 f0       	push   $0xf0106ec8
f0101216:	6a 58                	push   $0x58
f0101218:	68 a9 7f 10 f0       	push   $0xf0107fa9
f010121d:	e8 72 ee ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101222:	68 f8 76 10 f0       	push   $0xf01076f8
f0101227:	68 c3 7f 10 f0       	push   $0xf0107fc3
f010122c:	68 c5 02 00 00       	push   $0x2c5
f0101231:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101236:	e8 59 ee ff ff       	call   f0100094 <_panic>
			++nfree_basemem;
f010123b:	46                   	inc    %esi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010123c:	8b 12                	mov    (%edx),%edx
f010123e:	85 d2                	test   %edx,%edx
f0101240:	74 76                	je     f01012b8 <check_page_free_list+0x242>
		assert(pp >= pages);
f0101242:	39 d1                	cmp    %edx,%ecx
f0101244:	0f 87 f4 fe ff ff    	ja     f010113e <check_page_free_list+0xc8>
		assert(pp < pages + npages);
f010124a:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f010124d:	0f 86 04 ff ff ff    	jbe    f0101157 <check_page_free_list+0xe1>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101253:	89 d0                	mov    %edx,%eax
f0101255:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101258:	a8 07                	test   $0x7,%al
f010125a:	0f 85 10 ff ff ff    	jne    f0101170 <check_page_free_list+0xfa>
	return (pp - pages) << PGSHIFT;
f0101260:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0101263:	c1 e0 0c             	shl    $0xc,%eax
f0101266:	0f 84 1d ff ff ff    	je     f0101189 <check_page_free_list+0x113>
		assert(page2pa(pp) != IOPHYSMEM);
f010126c:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101271:	0f 84 2b ff ff ff    	je     f01011a2 <check_page_free_list+0x12c>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101277:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f010127c:	0f 84 39 ff ff ff    	je     f01011bb <check_page_free_list+0x145>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101282:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101287:	0f 84 47 ff ff ff    	je     f01011d4 <check_page_free_list+0x15e>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010128d:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101292:	0f 87 55 ff ff ff    	ja     f01011ed <check_page_free_list+0x177>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101298:	3d 00 70 00 00       	cmp    $0x7000,%eax
f010129d:	75 9c                	jne    f010123b <check_page_free_list+0x1c5>
f010129f:	68 30 80 10 f0       	push   $0xf0108030
f01012a4:	68 c3 7f 10 f0       	push   $0xf0107fc3
f01012a9:	68 c7 02 00 00       	push   $0x2c7
f01012ae:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01012b3:	e8 dc ed ff ff       	call   f0100094 <_panic>
	assert(nfree_basemem > 0);
f01012b8:	85 f6                	test   %esi,%esi
f01012ba:	7e 19                	jle    f01012d5 <check_page_free_list+0x25f>
	assert(nfree_extmem > 0);
f01012bc:	85 db                	test   %ebx,%ebx
f01012be:	7e 2e                	jle    f01012ee <check_page_free_list+0x278>
	cprintf("check_page_free_list() succeeded!\n");
f01012c0:	83 ec 0c             	sub    $0xc,%esp
f01012c3:	68 40 77 10 f0       	push   $0xf0107740
f01012c8:	e8 ed 2c 00 00       	call   f0103fba <cprintf>
}
f01012cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012d0:	5b                   	pop    %ebx
f01012d1:	5e                   	pop    %esi
f01012d2:	5f                   	pop    %edi
f01012d3:	5d                   	pop    %ebp
f01012d4:	c3                   	ret    
	assert(nfree_basemem > 0);
f01012d5:	68 4d 80 10 f0       	push   $0xf010804d
f01012da:	68 c3 7f 10 f0       	push   $0xf0107fc3
f01012df:	68 cf 02 00 00       	push   $0x2cf
f01012e4:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01012e9:	e8 a6 ed ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f01012ee:	68 5f 80 10 f0       	push   $0xf010805f
f01012f3:	68 c3 7f 10 f0       	push   $0xf0107fc3
f01012f8:	68 d0 02 00 00       	push   $0x2d0
f01012fd:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101302:	e8 8d ed ff ff       	call   f0100094 <_panic>
	if (!page_free_list)
f0101307:	a1 40 52 2a f0       	mov    0xf02a5240,%eax
f010130c:	85 c0                	test   %eax,%eax
f010130e:	0f 84 86 fd ff ff    	je     f010109a <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0101314:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0101317:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010131a:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010131d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101320:	89 c2                	mov    %eax,%edx
f0101322:	2b 15 90 5e 2a f0    	sub    0xf02a5e90,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit; 
f0101328:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f010132e:	0f 95 c2             	setne  %dl
f0101331:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0101334:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0101338:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f010133a:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f010133e:	8b 00                	mov    (%eax),%eax
f0101340:	85 c0                	test   %eax,%eax
f0101342:	75 dc                	jne    f0101320 <check_page_free_list+0x2aa>
		*tp[1] = 0;
f0101344:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101347:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f010134d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101350:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101353:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101355:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101358:	a3 40 52 2a f0       	mov    %eax,0xf02a5240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010135d:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101362:	8b 1d 40 52 2a f0    	mov    0xf02a5240,%ebx
f0101368:	e9 58 fd ff ff       	jmp    f01010c5 <check_page_free_list+0x4f>

f010136d <page_init>:
{
f010136d:	55                   	push   %ebp
f010136e:	89 e5                	mov    %esp,%ebp
f0101370:	57                   	push   %edi
f0101371:	56                   	push   %esi
f0101372:	53                   	push   %ebx
f0101373:	83 ec 1c             	sub    $0x1c,%esp
	physaddr_t free = (physaddr_t) PADDR(boot_alloc(0));
f0101376:	b8 00 00 00 00       	mov    $0x0,%eax
f010137b:	e8 2a fc ff ff       	call   f0100faa <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0101380:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101385:	76 32                	jbe    f01013b9 <page_init+0x4c>
	return (physaddr_t)kva - KERNBASE;
f0101387:	05 00 00 00 10       	add    $0x10000000,%eax
f010138c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	size_t core_code_end = MPENTRY_PADDR + mpentry_end - mpentry_start;
f010138f:	b8 92 d3 10 f0       	mov    $0xf010d392,%eax
f0101394:	2d 18 63 10 f0       	sub    $0xf0106318,%eax
f0101399:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if (i >= npages_basemem && len < free)
f010139c:	8b 1d 44 52 2a f0    	mov    0xf02a5244,%ebx
f01013a2:	8b 0d 40 52 2a f0    	mov    0xf02a5240,%ecx
	for (i = 1, len = PGSIZE; i < npages; i++, len += PGSIZE) {
f01013a8:	bf 00 00 00 00       	mov    $0x0,%edi
f01013ad:	b8 01 00 00 00       	mov    $0x1,%eax
		page_free_list = &pages[i];
f01013b2:	be 01 00 00 00       	mov    $0x1,%esi
	for (i = 1, len = PGSIZE; i < npages; i++, len += PGSIZE) {
f01013b7:	eb 37                	jmp    f01013f0 <page_init+0x83>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013b9:	50                   	push   %eax
f01013ba:	68 ec 6e 10 f0       	push   $0xf0106eec
f01013bf:	68 3e 01 00 00       	push   $0x13e
f01013c4:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01013c9:	e8 c6 ec ff ff       	call   f0100094 <_panic>
		pages[i].pp_ref = 0;
f01013ce:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01013d5:	89 d7                	mov    %edx,%edi
f01013d7:	03 3d 90 5e 2a f0    	add    0xf02a5e90,%edi
f01013dd:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
		pages[i].pp_link = page_free_list;
f01013e3:	89 0f                	mov    %ecx,(%edi)
		page_free_list = &pages[i];
f01013e5:	89 d1                	mov    %edx,%ecx
f01013e7:	03 0d 90 5e 2a f0    	add    0xf02a5e90,%ecx
f01013ed:	89 f7                	mov    %esi,%edi
	for (i = 1, len = PGSIZE; i < npages; i++, len += PGSIZE) {
f01013ef:	40                   	inc    %eax
f01013f0:	39 05 88 5e 2a f0    	cmp    %eax,0xf02a5e88
f01013f6:	76 1d                	jbe    f0101415 <page_init+0xa8>
f01013f8:	89 c2                	mov    %eax,%edx
f01013fa:	c1 e2 0c             	shl    $0xc,%edx
		if (len >= MPENTRY_PADDR && len < core_code_end) // We're in multicore code
f01013fd:	81 fa ff 6f 00 00    	cmp    $0x6fff,%edx
f0101403:	76 05                	jbe    f010140a <page_init+0x9d>
f0101405:	39 55 e4             	cmp    %edx,-0x1c(%ebp)
f0101408:	77 e5                	ja     f01013ef <page_init+0x82>
		if (i >= npages_basemem && len < free)
f010140a:	39 c3                	cmp    %eax,%ebx
f010140c:	77 c0                	ja     f01013ce <page_init+0x61>
f010140e:	39 55 e0             	cmp    %edx,-0x20(%ebp)
f0101411:	76 bb                	jbe    f01013ce <page_init+0x61>
f0101413:	eb da                	jmp    f01013ef <page_init+0x82>
f0101415:	89 f8                	mov    %edi,%eax
f0101417:	84 c0                	test   %al,%al
f0101419:	75 08                	jne    f0101423 <page_init+0xb6>
}
f010141b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010141e:	5b                   	pop    %ebx
f010141f:	5e                   	pop    %esi
f0101420:	5f                   	pop    %edi
f0101421:	5d                   	pop    %ebp
f0101422:	c3                   	ret    
f0101423:	89 0d 40 52 2a f0    	mov    %ecx,0xf02a5240
f0101429:	eb f0                	jmp    f010141b <page_init+0xae>

f010142b <page_alloc>:
{
f010142b:	55                   	push   %ebp
f010142c:	89 e5                	mov    %esp,%ebp
f010142e:	53                   	push   %ebx
f010142f:	83 ec 04             	sub    $0x4,%esp
	struct PageInfo* next = page_free_list;
f0101432:	8b 1d 40 52 2a f0    	mov    0xf02a5240,%ebx
	if (!next)
f0101438:	85 db                	test   %ebx,%ebx
f010143a:	74 13                	je     f010144f <page_alloc+0x24>
	page_free_list = page_free_list->pp_link;
f010143c:	8b 03                	mov    (%ebx),%eax
f010143e:	a3 40 52 2a f0       	mov    %eax,0xf02a5240
	next->pp_link = NULL;
f0101443:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f0101449:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010144d:	75 07                	jne    f0101456 <page_alloc+0x2b>
}
f010144f:	89 d8                	mov    %ebx,%eax
f0101451:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101454:	c9                   	leave  
f0101455:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0101456:	89 d8                	mov    %ebx,%eax
f0101458:	2b 05 90 5e 2a f0    	sub    0xf02a5e90,%eax
f010145e:	c1 f8 03             	sar    $0x3,%eax
f0101461:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101464:	89 c2                	mov    %eax,%edx
f0101466:	c1 ea 0c             	shr    $0xc,%edx
f0101469:	3b 15 88 5e 2a f0    	cmp    0xf02a5e88,%edx
f010146f:	73 1a                	jae    f010148b <page_alloc+0x60>
		memset(content, 0, PGSIZE);
f0101471:	83 ec 04             	sub    $0x4,%esp
f0101474:	68 00 10 00 00       	push   $0x1000
f0101479:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f010147b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101480:	50                   	push   %eax
f0101481:	e8 b2 4b 00 00       	call   f0106038 <memset>
f0101486:	83 c4 10             	add    $0x10,%esp
f0101489:	eb c4                	jmp    f010144f <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010148b:	50                   	push   %eax
f010148c:	68 c8 6e 10 f0       	push   $0xf0106ec8
f0101491:	6a 58                	push   $0x58
f0101493:	68 a9 7f 10 f0       	push   $0xf0107fa9
f0101498:	e8 f7 eb ff ff       	call   f0100094 <_panic>

f010149d <page_free>:
{
f010149d:	55                   	push   %ebp
f010149e:	89 e5                	mov    %esp,%ebp
f01014a0:	83 ec 08             	sub    $0x8,%esp
f01014a3:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref)
f01014a6:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01014ab:	75 14                	jne    f01014c1 <page_free+0x24>
	if (pp->pp_link)
f01014ad:	83 38 00             	cmpl   $0x0,(%eax)
f01014b0:	75 26                	jne    f01014d8 <page_free+0x3b>
	pp->pp_link = page_free_list;
f01014b2:	8b 15 40 52 2a f0    	mov    0xf02a5240,%edx
f01014b8:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f01014ba:	a3 40 52 2a f0       	mov    %eax,0xf02a5240
}
f01014bf:	c9                   	leave  
f01014c0:	c3                   	ret    
		panic("Ref count is non-zero");
f01014c1:	83 ec 04             	sub    $0x4,%esp
f01014c4:	68 70 80 10 f0       	push   $0xf0108070
f01014c9:	68 70 01 00 00       	push   $0x170
f01014ce:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01014d3:	e8 bc eb ff ff       	call   f0100094 <_panic>
		panic("Page is double-freed");
f01014d8:	83 ec 04             	sub    $0x4,%esp
f01014db:	68 86 80 10 f0       	push   $0xf0108086
f01014e0:	68 72 01 00 00       	push   $0x172
f01014e5:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01014ea:	e8 a5 eb ff ff       	call   f0100094 <_panic>

f01014ef <page_decref>:
{
f01014ef:	55                   	push   %ebp
f01014f0:	89 e5                	mov    %esp,%ebp
f01014f2:	83 ec 08             	sub    $0x8,%esp
f01014f5:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01014f8:	8b 42 04             	mov    0x4(%edx),%eax
f01014fb:	48                   	dec    %eax
f01014fc:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101500:	66 85 c0             	test   %ax,%ax
f0101503:	74 02                	je     f0101507 <page_decref+0x18>
}
f0101505:	c9                   	leave  
f0101506:	c3                   	ret    
		page_free(pp);
f0101507:	83 ec 0c             	sub    $0xc,%esp
f010150a:	52                   	push   %edx
f010150b:	e8 8d ff ff ff       	call   f010149d <page_free>
f0101510:	83 c4 10             	add    $0x10,%esp
}
f0101513:	eb f0                	jmp    f0101505 <page_decref+0x16>

f0101515 <pgdir_walk>:
{
f0101515:	55                   	push   %ebp
f0101516:	89 e5                	mov    %esp,%ebp
f0101518:	57                   	push   %edi
f0101519:	56                   	push   %esi
f010151a:	53                   	push   %ebx
f010151b:	83 ec 1c             	sub    $0x1c,%esp
	pde_t pd_entry = (pde_t)pgdir[PDX(va)];
f010151e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101521:	c1 eb 16             	shr    $0x16,%ebx
f0101524:	c1 e3 02             	shl    $0x2,%ebx
f0101527:	03 5d 08             	add    0x8(%ebp),%ebx
f010152a:	8b 03                	mov    (%ebx),%eax
	if (pd_entry) {
f010152c:	85 c0                	test   %eax,%eax
f010152e:	74 42                	je     f0101572 <pgdir_walk+0x5d>
		pte_t* pt_base = KADDR(PTE_ADDR(pd_entry));
f0101530:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101535:	89 c2                	mov    %eax,%edx
f0101537:	c1 ea 0c             	shr    $0xc,%edx
f010153a:	39 15 88 5e 2a f0    	cmp    %edx,0xf02a5e88
f0101540:	76 1b                	jbe    f010155d <pgdir_walk+0x48>
		return pt_base + PTX(va);
f0101542:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101545:	c1 ea 0a             	shr    $0xa,%edx
f0101548:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f010154e:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
}
f0101555:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101558:	5b                   	pop    %ebx
f0101559:	5e                   	pop    %esi
f010155a:	5f                   	pop    %edi
f010155b:	5d                   	pop    %ebp
f010155c:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010155d:	50                   	push   %eax
f010155e:	68 c8 6e 10 f0       	push   $0xf0106ec8
f0101563:	68 9d 01 00 00       	push   $0x19d
f0101568:	68 9d 7f 10 f0       	push   $0xf0107f9d
f010156d:	e8 22 eb ff ff       	call   f0100094 <_panic>
	else if (create) {
f0101572:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101576:	0f 84 9c 00 00 00    	je     f0101618 <pgdir_walk+0x103>
		struct PageInfo *new_pt = page_alloc(0);
f010157c:	83 ec 0c             	sub    $0xc,%esp
f010157f:	6a 00                	push   $0x0
f0101581:	e8 a5 fe ff ff       	call   f010142b <page_alloc>
f0101586:	89 c7                	mov    %eax,%edi
		if (new_pt) {
f0101588:	83 c4 10             	add    $0x10,%esp
f010158b:	85 c0                	test   %eax,%eax
f010158d:	0f 84 8f 00 00 00    	je     f0101622 <pgdir_walk+0x10d>
	return (pp - pages) << PGSHIFT;
f0101593:	2b 05 90 5e 2a f0    	sub    0xf02a5e90,%eax
f0101599:	c1 f8 03             	sar    $0x3,%eax
f010159c:	c1 e0 0c             	shl    $0xc,%eax
f010159f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (PGNUM(pa) >= npages)
f01015a2:	c1 e8 0c             	shr    $0xc,%eax
f01015a5:	3b 05 88 5e 2a f0    	cmp    0xf02a5e88,%eax
f01015ab:	73 42                	jae    f01015ef <pgdir_walk+0xda>
	return (void *)(pa + KERNBASE);
f01015ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01015b0:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
			memset(content, 0, PGSIZE);
f01015b6:	83 ec 04             	sub    $0x4,%esp
f01015b9:	68 00 10 00 00       	push   $0x1000
f01015be:	6a 00                	push   $0x0
f01015c0:	56                   	push   %esi
f01015c1:	e8 72 4a 00 00       	call   f0106038 <memset>
			new_pt->pp_ref++;
f01015c6:	66 ff 47 04          	incw   0x4(%edi)
	if ((uint32_t)kva < KERNBASE)
f01015ca:	83 c4 10             	add    $0x10,%esp
f01015cd:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01015d3:	76 2e                	jbe    f0101603 <pgdir_walk+0xee>
			pgdir[PDX(va)] = PADDR(content) | 0xF; // Set all permissions.
f01015d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01015d8:	83 c8 0f             	or     $0xf,%eax
f01015db:	89 03                	mov    %eax,(%ebx)
			return (pte_t*) content + PTX(va);
f01015dd:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015e0:	c1 e8 0a             	shr    $0xa,%eax
f01015e3:	25 fc 0f 00 00       	and    $0xffc,%eax
f01015e8:	01 f0                	add    %esi,%eax
f01015ea:	e9 66 ff ff ff       	jmp    f0101555 <pgdir_walk+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015ef:	ff 75 e4             	pushl  -0x1c(%ebp)
f01015f2:	68 c8 6e 10 f0       	push   $0xf0106ec8
f01015f7:	6a 58                	push   $0x58
f01015f9:	68 a9 7f 10 f0       	push   $0xf0107fa9
f01015fe:	e8 91 ea ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101603:	56                   	push   %esi
f0101604:	68 ec 6e 10 f0       	push   $0xf0106eec
f0101609:	68 a6 01 00 00       	push   $0x1a6
f010160e:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101613:	e8 7c ea ff ff       	call   f0100094 <_panic>
	return NULL;
f0101618:	b8 00 00 00 00       	mov    $0x0,%eax
f010161d:	e9 33 ff ff ff       	jmp    f0101555 <pgdir_walk+0x40>
f0101622:	b8 00 00 00 00       	mov    $0x0,%eax
f0101627:	e9 29 ff ff ff       	jmp    f0101555 <pgdir_walk+0x40>

f010162c <boot_map_region>:
{
f010162c:	55                   	push   %ebp
f010162d:	89 e5                	mov    %esp,%ebp
f010162f:	57                   	push   %edi
f0101630:	56                   	push   %esi
f0101631:	53                   	push   %ebx
f0101632:	83 ec 1c             	sub    $0x1c,%esp
f0101635:	89 c7                	mov    %eax,%edi
f0101637:	89 d6                	mov    %edx,%esi
f0101639:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f010163c:	bb 00 00 00 00       	mov    $0x0,%ebx
		*page_entry = (pa + size0) | perm | PTE_P;
f0101641:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101644:	83 c8 01             	or     $0x1,%eax
f0101647:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f010164a:	eb 22                	jmp    f010166e <boot_map_region+0x42>
		pte_t *page_entry = pgdir_walk(pgdir, (void*) va + size0, 1);
f010164c:	83 ec 04             	sub    $0x4,%esp
f010164f:	6a 01                	push   $0x1
f0101651:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f0101654:	50                   	push   %eax
f0101655:	57                   	push   %edi
f0101656:	e8 ba fe ff ff       	call   f0101515 <pgdir_walk>
		*page_entry = (pa + size0) | perm | PTE_P;
f010165b:	89 da                	mov    %ebx,%edx
f010165d:	03 55 08             	add    0x8(%ebp),%edx
f0101660:	0b 55 e0             	or     -0x20(%ebp),%edx
f0101663:	89 10                	mov    %edx,(%eax)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f0101665:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010166b:	83 c4 10             	add    $0x10,%esp
f010166e:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101671:	72 d9                	jb     f010164c <boot_map_region+0x20>
}
f0101673:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101676:	5b                   	pop    %ebx
f0101677:	5e                   	pop    %esi
f0101678:	5f                   	pop    %edi
f0101679:	5d                   	pop    %ebp
f010167a:	c3                   	ret    

f010167b <page_lookup>:
{
f010167b:	55                   	push   %ebp
f010167c:	89 e5                	mov    %esp,%ebp
f010167e:	53                   	push   %ebx
f010167f:	83 ec 08             	sub    $0x8,%esp
f0101682:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *page_entry = pgdir_walk(pgdir, (void*) va, 0);
f0101685:	6a 00                	push   $0x0
f0101687:	ff 75 0c             	pushl  0xc(%ebp)
f010168a:	ff 75 08             	pushl  0x8(%ebp)
f010168d:	e8 83 fe ff ff       	call   f0101515 <pgdir_walk>
	if (!page_entry || !*page_entry)
f0101692:	83 c4 10             	add    $0x10,%esp
f0101695:	85 c0                	test   %eax,%eax
f0101697:	74 3a                	je     f01016d3 <page_lookup+0x58>
f0101699:	83 38 00             	cmpl   $0x0,(%eax)
f010169c:	74 3c                	je     f01016da <page_lookup+0x5f>
	if (pte_store)
f010169e:	85 db                	test   %ebx,%ebx
f01016a0:	74 02                	je     f01016a4 <page_lookup+0x29>
		*pte_store = page_entry;
f01016a2:	89 03                	mov    %eax,(%ebx)
f01016a4:	8b 00                	mov    (%eax),%eax
f01016a6:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016a9:	39 05 88 5e 2a f0    	cmp    %eax,0xf02a5e88
f01016af:	76 0e                	jbe    f01016bf <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01016b1:	8b 15 90 5e 2a f0    	mov    0xf02a5e90,%edx
f01016b7:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f01016ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01016bd:	c9                   	leave  
f01016be:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01016bf:	83 ec 04             	sub    $0x4,%esp
f01016c2:	68 64 77 10 f0       	push   $0xf0107764
f01016c7:	6a 51                	push   $0x51
f01016c9:	68 a9 7f 10 f0       	push   $0xf0107fa9
f01016ce:	e8 c1 e9 ff ff       	call   f0100094 <_panic>
		return NULL;
f01016d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01016d8:	eb e0                	jmp    f01016ba <page_lookup+0x3f>
f01016da:	b8 00 00 00 00       	mov    $0x0,%eax
f01016df:	eb d9                	jmp    f01016ba <page_lookup+0x3f>

f01016e1 <tlb_invalidate>:
{
f01016e1:	55                   	push   %ebp
f01016e2:	89 e5                	mov    %esp,%ebp
f01016e4:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f01016e7:	e8 56 50 00 00       	call   f0106742 <cpunum>
f01016ec:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01016ef:	01 c2                	add    %eax,%edx
f01016f1:	01 d2                	add    %edx,%edx
f01016f3:	01 c2                	add    %eax,%edx
f01016f5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01016f8:	83 3c 85 28 60 2a f0 	cmpl   $0x0,-0xfd59fd8(,%eax,4)
f01016ff:	00 
f0101700:	74 20                	je     f0101722 <tlb_invalidate+0x41>
f0101702:	e8 3b 50 00 00       	call   f0106742 <cpunum>
f0101707:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010170a:	01 c2                	add    %eax,%edx
f010170c:	01 d2                	add    %edx,%edx
f010170e:	01 c2                	add    %eax,%edx
f0101710:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0101713:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f010171a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010171d:	39 48 60             	cmp    %ecx,0x60(%eax)
f0101720:	75 06                	jne    f0101728 <tlb_invalidate+0x47>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101722:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101725:	0f 01 38             	invlpg (%eax)
}
f0101728:	c9                   	leave  
f0101729:	c3                   	ret    

f010172a <page_remove>:
{
f010172a:	55                   	push   %ebp
f010172b:	89 e5                	mov    %esp,%ebp
f010172d:	57                   	push   %edi
f010172e:	56                   	push   %esi
f010172f:	53                   	push   %ebx
f0101730:	83 ec 20             	sub    $0x20,%esp
f0101733:	8b 75 08             	mov    0x8(%ebp),%esi
f0101736:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct PageInfo *pp = page_lookup(pgdir, va, &pte_store);
f0101739:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010173c:	50                   	push   %eax
f010173d:	57                   	push   %edi
f010173e:	56                   	push   %esi
f010173f:	e8 37 ff ff ff       	call   f010167b <page_lookup>
	if (!pp)
f0101744:	83 c4 10             	add    $0x10,%esp
f0101747:	85 c0                	test   %eax,%eax
f0101749:	74 23                	je     f010176e <page_remove+0x44>
f010174b:	89 c3                	mov    %eax,%ebx
	pp->pp_ref--;
f010174d:	66 ff 48 04          	decw   0x4(%eax)
	*pte_store = 0;
f0101751:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101754:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f010175a:	83 ec 08             	sub    $0x8,%esp
f010175d:	57                   	push   %edi
f010175e:	56                   	push   %esi
f010175f:	e8 7d ff ff ff       	call   f01016e1 <tlb_invalidate>
	if (!pp->pp_ref)
f0101764:	83 c4 10             	add    $0x10,%esp
f0101767:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010176c:	74 08                	je     f0101776 <page_remove+0x4c>
}
f010176e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101771:	5b                   	pop    %ebx
f0101772:	5e                   	pop    %esi
f0101773:	5f                   	pop    %edi
f0101774:	5d                   	pop    %ebp
f0101775:	c3                   	ret    
		page_free(pp);
f0101776:	83 ec 0c             	sub    $0xc,%esp
f0101779:	53                   	push   %ebx
f010177a:	e8 1e fd ff ff       	call   f010149d <page_free>
f010177f:	83 c4 10             	add    $0x10,%esp
f0101782:	eb ea                	jmp    f010176e <page_remove+0x44>

f0101784 <page_insert>:
{
f0101784:	55                   	push   %ebp
f0101785:	89 e5                	mov    %esp,%ebp
f0101787:	57                   	push   %edi
f0101788:	56                   	push   %esi
f0101789:	53                   	push   %ebx
f010178a:	83 ec 10             	sub    $0x10,%esp
f010178d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101790:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *page_entry = pgdir_walk(pgdir, (void*) va, 1);
f0101793:	6a 01                	push   $0x1
f0101795:	57                   	push   %edi
f0101796:	ff 75 08             	pushl  0x8(%ebp)
f0101799:	e8 77 fd ff ff       	call   f0101515 <pgdir_walk>
	if (!page_entry)
f010179e:	83 c4 10             	add    $0x10,%esp
f01017a1:	85 c0                	test   %eax,%eax
f01017a3:	74 3f                	je     f01017e4 <page_insert+0x60>
f01017a5:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f01017a7:	66 ff 43 04          	incw   0x4(%ebx)
	if (*page_entry) 
f01017ab:	83 38 00             	cmpl   $0x0,(%eax)
f01017ae:	75 23                	jne    f01017d3 <page_insert+0x4f>
	return (pp - pages) << PGSHIFT;
f01017b0:	2b 1d 90 5e 2a f0    	sub    0xf02a5e90,%ebx
f01017b6:	c1 fb 03             	sar    $0x3,%ebx
f01017b9:	c1 e3 0c             	shl    $0xc,%ebx
	*page_entry = page2pa(pp) | perm | PTE_P;
f01017bc:	8b 45 14             	mov    0x14(%ebp),%eax
f01017bf:	83 c8 01             	or     $0x1,%eax
f01017c2:	09 c3                	or     %eax,%ebx
f01017c4:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01017c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01017cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01017ce:	5b                   	pop    %ebx
f01017cf:	5e                   	pop    %esi
f01017d0:	5f                   	pop    %edi
f01017d1:	5d                   	pop    %ebp
f01017d2:	c3                   	ret    
		page_remove(pgdir, va);
f01017d3:	83 ec 08             	sub    $0x8,%esp
f01017d6:	57                   	push   %edi
f01017d7:	ff 75 08             	pushl  0x8(%ebp)
f01017da:	e8 4b ff ff ff       	call   f010172a <page_remove>
f01017df:	83 c4 10             	add    $0x10,%esp
f01017e2:	eb cc                	jmp    f01017b0 <page_insert+0x2c>
		return -E_NO_MEM;  // Has no page table AND cannot be allocated
f01017e4:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01017e9:	eb e0                	jmp    f01017cb <page_insert+0x47>

f01017eb <mmio_map_region>:
{
f01017eb:	55                   	push   %ebp
f01017ec:	89 e5                	mov    %esp,%ebp
f01017ee:	53                   	push   %ebx
f01017ef:	83 ec 04             	sub    $0x4,%esp
	size_t size_up = ROUNDUP(size, PGSIZE);
f01017f2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01017f5:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01017fb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (base >= MMIOLIM)
f0101801:	8b 15 00 33 12 f0    	mov    0xf0123300,%edx
f0101807:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f010180d:	77 26                	ja     f0101835 <mmio_map_region+0x4a>
	boot_map_region(kern_pgdir, base, size_up, pa, PTE_PCD|PTE_PWT|PTE_W);
f010180f:	83 ec 08             	sub    $0x8,%esp
f0101812:	6a 1a                	push   $0x1a
f0101814:	ff 75 08             	pushl  0x8(%ebp)
f0101817:	89 d9                	mov    %ebx,%ecx
f0101819:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f010181e:	e8 09 fe ff ff       	call   f010162c <boot_map_region>
	base += size_up;
f0101823:	a1 00 33 12 f0       	mov    0xf0123300,%eax
f0101828:	01 c3                	add    %eax,%ebx
f010182a:	89 1d 00 33 12 f0    	mov    %ebx,0xf0123300
}
f0101830:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101833:	c9                   	leave  
f0101834:	c3                   	ret    
		panic("MMIO overflowed!");
f0101835:	83 ec 04             	sub    $0x4,%esp
f0101838:	68 9b 80 10 f0       	push   $0xf010809b
f010183d:	68 48 02 00 00       	push   $0x248
f0101842:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101847:	e8 48 e8 ff ff       	call   f0100094 <_panic>

f010184c <mem_init>:
{
f010184c:	55                   	push   %ebp
f010184d:	89 e5                	mov    %esp,%ebp
f010184f:	57                   	push   %edi
f0101850:	56                   	push   %esi
f0101851:	53                   	push   %ebx
f0101852:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0101855:	b8 15 00 00 00       	mov    $0x15,%eax
f010185a:	e8 91 f7 ff ff       	call   f0100ff0 <nvram_read>
f010185f:	89 c6                	mov    %eax,%esi
	extmem = nvram_read(NVRAM_EXTLO);
f0101861:	b8 17 00 00 00       	mov    $0x17,%eax
f0101866:	e8 85 f7 ff ff       	call   f0100ff0 <nvram_read>
f010186b:	89 c3                	mov    %eax,%ebx
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010186d:	b8 34 00 00 00       	mov    $0x34,%eax
f0101872:	e8 79 f7 ff ff       	call   f0100ff0 <nvram_read>
	if (ext16mem)
f0101877:	c1 e0 06             	shl    $0x6,%eax
f010187a:	75 10                	jne    f010188c <mem_init+0x40>
	else if (extmem)
f010187c:	85 db                	test   %ebx,%ebx
f010187e:	0f 84 e6 00 00 00    	je     f010196a <mem_init+0x11e>
		totalmem = 1 * 1024 + extmem;
f0101884:	8d 83 00 04 00 00    	lea    0x400(%ebx),%eax
f010188a:	eb 05                	jmp    f0101891 <mem_init+0x45>
		totalmem = 16 * 1024 + ext16mem;
f010188c:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101891:	89 c2                	mov    %eax,%edx
f0101893:	c1 ea 02             	shr    $0x2,%edx
f0101896:	89 15 88 5e 2a f0    	mov    %edx,0xf02a5e88
	npages_basemem = basemem / (PGSIZE / 1024);
f010189c:	89 f2                	mov    %esi,%edx
f010189e:	c1 ea 02             	shr    $0x2,%edx
f01018a1:	89 15 44 52 2a f0    	mov    %edx,0xf02a5244
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01018a7:	89 c2                	mov    %eax,%edx
f01018a9:	29 f2                	sub    %esi,%edx
f01018ab:	52                   	push   %edx
f01018ac:	56                   	push   %esi
f01018ad:	50                   	push   %eax
f01018ae:	68 84 77 10 f0       	push   $0xf0107784
f01018b3:	e8 02 27 00 00       	call   f0103fba <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01018b8:	b8 00 10 00 00       	mov    $0x1000,%eax
f01018bd:	e8 e8 f6 ff ff       	call   f0100faa <boot_alloc>
f01018c2:	a3 8c 5e 2a f0       	mov    %eax,0xf02a5e8c
	memset(kern_pgdir, 0, PGSIZE);
f01018c7:	83 c4 0c             	add    $0xc,%esp
f01018ca:	68 00 10 00 00       	push   $0x1000
f01018cf:	6a 00                	push   $0x0
f01018d1:	50                   	push   %eax
f01018d2:	e8 61 47 00 00       	call   f0106038 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01018d7:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01018dc:	83 c4 10             	add    $0x10,%esp
f01018df:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01018e4:	0f 86 87 00 00 00    	jbe    f0101971 <mem_init+0x125>
	return (physaddr_t)kva - KERNBASE;
f01018ea:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01018f0:	83 ca 05             	or     $0x5,%edx
f01018f3:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo)*npages);
f01018f9:	a1 88 5e 2a f0       	mov    0xf02a5e88,%eax
f01018fe:	c1 e0 03             	shl    $0x3,%eax
f0101901:	e8 a4 f6 ff ff       	call   f0100faa <boot_alloc>
f0101906:	a3 90 5e 2a f0       	mov    %eax,0xf02a5e90
	memset(pages, 0, sizeof(struct PageInfo)*npages);
f010190b:	83 ec 04             	sub    $0x4,%esp
f010190e:	8b 0d 88 5e 2a f0    	mov    0xf02a5e88,%ecx
f0101914:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f010191b:	52                   	push   %edx
f010191c:	6a 00                	push   $0x0
f010191e:	50                   	push   %eax
f010191f:	e8 14 47 00 00       	call   f0106038 <memset>
	envs = (struct Env *) boot_alloc(sizeof(struct Env)*NENV);
f0101924:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101929:	e8 7c f6 ff ff       	call   f0100faa <boot_alloc>
f010192e:	a3 48 52 2a f0       	mov    %eax,0xf02a5248
	memset(envs, 0, sizeof(struct Env)*NENV);
f0101933:	83 c4 0c             	add    $0xc,%esp
f0101936:	68 00 f0 01 00       	push   $0x1f000
f010193b:	6a 00                	push   $0x0
f010193d:	50                   	push   %eax
f010193e:	e8 f5 46 00 00       	call   f0106038 <memset>
	page_init();
f0101943:	e8 25 fa ff ff       	call   f010136d <page_init>
	check_page_free_list(1);
f0101948:	b8 01 00 00 00       	mov    $0x1,%eax
f010194d:	e8 24 f7 ff ff       	call   f0101076 <check_page_free_list>
	if (!pages)
f0101952:	83 c4 10             	add    $0x10,%esp
f0101955:	83 3d 90 5e 2a f0 00 	cmpl   $0x0,0xf02a5e90
f010195c:	74 28                	je     f0101986 <mem_init+0x13a>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010195e:	a1 40 52 2a f0       	mov    0xf02a5240,%eax
f0101963:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101968:	eb 36                	jmp    f01019a0 <mem_init+0x154>
		totalmem = basemem;
f010196a:	89 f0                	mov    %esi,%eax
f010196c:	e9 20 ff ff ff       	jmp    f0101891 <mem_init+0x45>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101971:	50                   	push   %eax
f0101972:	68 ec 6e 10 f0       	push   $0xf0106eec
f0101977:	68 94 00 00 00       	push   $0x94
f010197c:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101981:	e8 0e e7 ff ff       	call   f0100094 <_panic>
		panic("'pages' is a null pointer!");
f0101986:	83 ec 04             	sub    $0x4,%esp
f0101989:	68 ac 80 10 f0       	push   $0xf01080ac
f010198e:	68 e3 02 00 00       	push   $0x2e3
f0101993:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101998:	e8 f7 e6 ff ff       	call   f0100094 <_panic>
		++nfree;
f010199d:	43                   	inc    %ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010199e:	8b 00                	mov    (%eax),%eax
f01019a0:	85 c0                	test   %eax,%eax
f01019a2:	75 f9                	jne    f010199d <mem_init+0x151>
	assert((pp0 = page_alloc(0)));
f01019a4:	83 ec 0c             	sub    $0xc,%esp
f01019a7:	6a 00                	push   $0x0
f01019a9:	e8 7d fa ff ff       	call   f010142b <page_alloc>
f01019ae:	89 c7                	mov    %eax,%edi
f01019b0:	83 c4 10             	add    $0x10,%esp
f01019b3:	85 c0                	test   %eax,%eax
f01019b5:	0f 84 10 02 00 00    	je     f0101bcb <mem_init+0x37f>
	assert((pp1 = page_alloc(0)));
f01019bb:	83 ec 0c             	sub    $0xc,%esp
f01019be:	6a 00                	push   $0x0
f01019c0:	e8 66 fa ff ff       	call   f010142b <page_alloc>
f01019c5:	89 c6                	mov    %eax,%esi
f01019c7:	83 c4 10             	add    $0x10,%esp
f01019ca:	85 c0                	test   %eax,%eax
f01019cc:	0f 84 12 02 00 00    	je     f0101be4 <mem_init+0x398>
	assert((pp2 = page_alloc(0)));
f01019d2:	83 ec 0c             	sub    $0xc,%esp
f01019d5:	6a 00                	push   $0x0
f01019d7:	e8 4f fa ff ff       	call   f010142b <page_alloc>
f01019dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019df:	83 c4 10             	add    $0x10,%esp
f01019e2:	85 c0                	test   %eax,%eax
f01019e4:	0f 84 13 02 00 00    	je     f0101bfd <mem_init+0x3b1>
	assert(pp1 && pp1 != pp0);
f01019ea:	39 f7                	cmp    %esi,%edi
f01019ec:	0f 84 24 02 00 00    	je     f0101c16 <mem_init+0x3ca>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019f2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019f5:	39 c6                	cmp    %eax,%esi
f01019f7:	0f 84 32 02 00 00    	je     f0101c2f <mem_init+0x3e3>
f01019fd:	39 c7                	cmp    %eax,%edi
f01019ff:	0f 84 2a 02 00 00    	je     f0101c2f <mem_init+0x3e3>
	return (pp - pages) << PGSHIFT;
f0101a05:	8b 0d 90 5e 2a f0    	mov    0xf02a5e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101a0b:	8b 15 88 5e 2a f0    	mov    0xf02a5e88,%edx
f0101a11:	c1 e2 0c             	shl    $0xc,%edx
f0101a14:	89 f8                	mov    %edi,%eax
f0101a16:	29 c8                	sub    %ecx,%eax
f0101a18:	c1 f8 03             	sar    $0x3,%eax
f0101a1b:	c1 e0 0c             	shl    $0xc,%eax
f0101a1e:	39 d0                	cmp    %edx,%eax
f0101a20:	0f 83 22 02 00 00    	jae    f0101c48 <mem_init+0x3fc>
f0101a26:	89 f0                	mov    %esi,%eax
f0101a28:	29 c8                	sub    %ecx,%eax
f0101a2a:	c1 f8 03             	sar    $0x3,%eax
f0101a2d:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101a30:	39 c2                	cmp    %eax,%edx
f0101a32:	0f 86 29 02 00 00    	jbe    f0101c61 <mem_init+0x415>
f0101a38:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a3b:	29 c8                	sub    %ecx,%eax
f0101a3d:	c1 f8 03             	sar    $0x3,%eax
f0101a40:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101a43:	39 c2                	cmp    %eax,%edx
f0101a45:	0f 86 2f 02 00 00    	jbe    f0101c7a <mem_init+0x42e>
	fl = page_free_list;
f0101a4b:	a1 40 52 2a f0       	mov    0xf02a5240,%eax
f0101a50:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101a53:	c7 05 40 52 2a f0 00 	movl   $0x0,0xf02a5240
f0101a5a:	00 00 00 
	assert(!page_alloc(0));
f0101a5d:	83 ec 0c             	sub    $0xc,%esp
f0101a60:	6a 00                	push   $0x0
f0101a62:	e8 c4 f9 ff ff       	call   f010142b <page_alloc>
f0101a67:	83 c4 10             	add    $0x10,%esp
f0101a6a:	85 c0                	test   %eax,%eax
f0101a6c:	0f 85 21 02 00 00    	jne    f0101c93 <mem_init+0x447>
	page_free(pp0);
f0101a72:	83 ec 0c             	sub    $0xc,%esp
f0101a75:	57                   	push   %edi
f0101a76:	e8 22 fa ff ff       	call   f010149d <page_free>
	page_free(pp1);
f0101a7b:	89 34 24             	mov    %esi,(%esp)
f0101a7e:	e8 1a fa ff ff       	call   f010149d <page_free>
	page_free(pp2);
f0101a83:	83 c4 04             	add    $0x4,%esp
f0101a86:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a89:	e8 0f fa ff ff       	call   f010149d <page_free>
	assert((pp0 = page_alloc(0)));
f0101a8e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a95:	e8 91 f9 ff ff       	call   f010142b <page_alloc>
f0101a9a:	89 c6                	mov    %eax,%esi
f0101a9c:	83 c4 10             	add    $0x10,%esp
f0101a9f:	85 c0                	test   %eax,%eax
f0101aa1:	0f 84 05 02 00 00    	je     f0101cac <mem_init+0x460>
	assert((pp1 = page_alloc(0)));
f0101aa7:	83 ec 0c             	sub    $0xc,%esp
f0101aaa:	6a 00                	push   $0x0
f0101aac:	e8 7a f9 ff ff       	call   f010142b <page_alloc>
f0101ab1:	89 c7                	mov    %eax,%edi
f0101ab3:	83 c4 10             	add    $0x10,%esp
f0101ab6:	85 c0                	test   %eax,%eax
f0101ab8:	0f 84 07 02 00 00    	je     f0101cc5 <mem_init+0x479>
	assert((pp2 = page_alloc(0)));
f0101abe:	83 ec 0c             	sub    $0xc,%esp
f0101ac1:	6a 00                	push   $0x0
f0101ac3:	e8 63 f9 ff ff       	call   f010142b <page_alloc>
f0101ac8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101acb:	83 c4 10             	add    $0x10,%esp
f0101ace:	85 c0                	test   %eax,%eax
f0101ad0:	0f 84 08 02 00 00    	je     f0101cde <mem_init+0x492>
	assert(pp1 && pp1 != pp0);
f0101ad6:	39 fe                	cmp    %edi,%esi
f0101ad8:	0f 84 19 02 00 00    	je     f0101cf7 <mem_init+0x4ab>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101ade:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ae1:	39 c7                	cmp    %eax,%edi
f0101ae3:	0f 84 27 02 00 00    	je     f0101d10 <mem_init+0x4c4>
f0101ae9:	39 c6                	cmp    %eax,%esi
f0101aeb:	0f 84 1f 02 00 00    	je     f0101d10 <mem_init+0x4c4>
	assert(!page_alloc(0));
f0101af1:	83 ec 0c             	sub    $0xc,%esp
f0101af4:	6a 00                	push   $0x0
f0101af6:	e8 30 f9 ff ff       	call   f010142b <page_alloc>
f0101afb:	83 c4 10             	add    $0x10,%esp
f0101afe:	85 c0                	test   %eax,%eax
f0101b00:	0f 85 23 02 00 00    	jne    f0101d29 <mem_init+0x4dd>
f0101b06:	89 f0                	mov    %esi,%eax
f0101b08:	2b 05 90 5e 2a f0    	sub    0xf02a5e90,%eax
f0101b0e:	c1 f8 03             	sar    $0x3,%eax
f0101b11:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101b14:	89 c2                	mov    %eax,%edx
f0101b16:	c1 ea 0c             	shr    $0xc,%edx
f0101b19:	3b 15 88 5e 2a f0    	cmp    0xf02a5e88,%edx
f0101b1f:	0f 83 1d 02 00 00    	jae    f0101d42 <mem_init+0x4f6>
	memset(page2kva(pp0), 1, PGSIZE);
f0101b25:	83 ec 04             	sub    $0x4,%esp
f0101b28:	68 00 10 00 00       	push   $0x1000
f0101b2d:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101b2f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101b34:	50                   	push   %eax
f0101b35:	e8 fe 44 00 00       	call   f0106038 <memset>
	page_free(pp0);
f0101b3a:	89 34 24             	mov    %esi,(%esp)
f0101b3d:	e8 5b f9 ff ff       	call   f010149d <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101b42:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101b49:	e8 dd f8 ff ff       	call   f010142b <page_alloc>
f0101b4e:	83 c4 10             	add    $0x10,%esp
f0101b51:	85 c0                	test   %eax,%eax
f0101b53:	0f 84 fb 01 00 00    	je     f0101d54 <mem_init+0x508>
	assert(pp && pp0 == pp);
f0101b59:	39 c6                	cmp    %eax,%esi
f0101b5b:	0f 85 0c 02 00 00    	jne    f0101d6d <mem_init+0x521>
	return (pp - pages) << PGSHIFT;
f0101b61:	89 f2                	mov    %esi,%edx
f0101b63:	2b 15 90 5e 2a f0    	sub    0xf02a5e90,%edx
f0101b69:	c1 fa 03             	sar    $0x3,%edx
f0101b6c:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101b6f:	89 d0                	mov    %edx,%eax
f0101b71:	c1 e8 0c             	shr    $0xc,%eax
f0101b74:	3b 05 88 5e 2a f0    	cmp    0xf02a5e88,%eax
f0101b7a:	0f 83 06 02 00 00    	jae    f0101d86 <mem_init+0x53a>
	return (void *)(pa + KERNBASE);
f0101b80:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101b86:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101b8c:	80 38 00             	cmpb   $0x0,(%eax)
f0101b8f:	0f 85 03 02 00 00    	jne    f0101d98 <mem_init+0x54c>
f0101b95:	40                   	inc    %eax
	for (i = 0; i < PGSIZE; i++)
f0101b96:	39 d0                	cmp    %edx,%eax
f0101b98:	75 f2                	jne    f0101b8c <mem_init+0x340>
	page_free_list = fl;
f0101b9a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b9d:	a3 40 52 2a f0       	mov    %eax,0xf02a5240
	page_free(pp0);
f0101ba2:	83 ec 0c             	sub    $0xc,%esp
f0101ba5:	56                   	push   %esi
f0101ba6:	e8 f2 f8 ff ff       	call   f010149d <page_free>
	page_free(pp1);
f0101bab:	89 3c 24             	mov    %edi,(%esp)
f0101bae:	e8 ea f8 ff ff       	call   f010149d <page_free>
	page_free(pp2);
f0101bb3:	83 c4 04             	add    $0x4,%esp
f0101bb6:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101bb9:	e8 df f8 ff ff       	call   f010149d <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101bbe:	a1 40 52 2a f0       	mov    0xf02a5240,%eax
f0101bc3:	83 c4 10             	add    $0x10,%esp
f0101bc6:	e9 e9 01 00 00       	jmp    f0101db4 <mem_init+0x568>
	assert((pp0 = page_alloc(0)));
f0101bcb:	68 c7 80 10 f0       	push   $0xf01080c7
f0101bd0:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0101bd5:	68 eb 02 00 00       	push   $0x2eb
f0101bda:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101bdf:	e8 b0 e4 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101be4:	68 dd 80 10 f0       	push   $0xf01080dd
f0101be9:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0101bee:	68 ec 02 00 00       	push   $0x2ec
f0101bf3:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101bf8:	e8 97 e4 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101bfd:	68 f3 80 10 f0       	push   $0xf01080f3
f0101c02:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0101c07:	68 ed 02 00 00       	push   $0x2ed
f0101c0c:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101c11:	e8 7e e4 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f0101c16:	68 09 81 10 f0       	push   $0xf0108109
f0101c1b:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0101c20:	68 f0 02 00 00       	push   $0x2f0
f0101c25:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101c2a:	e8 65 e4 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c2f:	68 c0 77 10 f0       	push   $0xf01077c0
f0101c34:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0101c39:	68 f1 02 00 00       	push   $0x2f1
f0101c3e:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101c43:	e8 4c e4 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101c48:	68 1b 81 10 f0       	push   $0xf010811b
f0101c4d:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0101c52:	68 f2 02 00 00       	push   $0x2f2
f0101c57:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101c5c:	e8 33 e4 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101c61:	68 38 81 10 f0       	push   $0xf0108138
f0101c66:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0101c6b:	68 f3 02 00 00       	push   $0x2f3
f0101c70:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101c75:	e8 1a e4 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101c7a:	68 55 81 10 f0       	push   $0xf0108155
f0101c7f:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0101c84:	68 f4 02 00 00       	push   $0x2f4
f0101c89:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101c8e:	e8 01 e4 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101c93:	68 72 81 10 f0       	push   $0xf0108172
f0101c98:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0101c9d:	68 fb 02 00 00       	push   $0x2fb
f0101ca2:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101ca7:	e8 e8 e3 ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0101cac:	68 c7 80 10 f0       	push   $0xf01080c7
f0101cb1:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0101cb6:	68 02 03 00 00       	push   $0x302
f0101cbb:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101cc0:	e8 cf e3 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101cc5:	68 dd 80 10 f0       	push   $0xf01080dd
f0101cca:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0101ccf:	68 03 03 00 00       	push   $0x303
f0101cd4:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101cd9:	e8 b6 e3 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101cde:	68 f3 80 10 f0       	push   $0xf01080f3
f0101ce3:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0101ce8:	68 04 03 00 00       	push   $0x304
f0101ced:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101cf2:	e8 9d e3 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f0101cf7:	68 09 81 10 f0       	push   $0xf0108109
f0101cfc:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0101d01:	68 06 03 00 00       	push   $0x306
f0101d06:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101d0b:	e8 84 e3 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101d10:	68 c0 77 10 f0       	push   $0xf01077c0
f0101d15:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0101d1a:	68 07 03 00 00       	push   $0x307
f0101d1f:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101d24:	e8 6b e3 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101d29:	68 72 81 10 f0       	push   $0xf0108172
f0101d2e:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0101d33:	68 08 03 00 00       	push   $0x308
f0101d38:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101d3d:	e8 52 e3 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d42:	50                   	push   %eax
f0101d43:	68 c8 6e 10 f0       	push   $0xf0106ec8
f0101d48:	6a 58                	push   $0x58
f0101d4a:	68 a9 7f 10 f0       	push   $0xf0107fa9
f0101d4f:	e8 40 e3 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101d54:	68 81 81 10 f0       	push   $0xf0108181
f0101d59:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0101d5e:	68 0d 03 00 00       	push   $0x30d
f0101d63:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101d68:	e8 27 e3 ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f0101d6d:	68 9f 81 10 f0       	push   $0xf010819f
f0101d72:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0101d77:	68 0e 03 00 00       	push   $0x30e
f0101d7c:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101d81:	e8 0e e3 ff ff       	call   f0100094 <_panic>
f0101d86:	52                   	push   %edx
f0101d87:	68 c8 6e 10 f0       	push   $0xf0106ec8
f0101d8c:	6a 58                	push   $0x58
f0101d8e:	68 a9 7f 10 f0       	push   $0xf0107fa9
f0101d93:	e8 fc e2 ff ff       	call   f0100094 <_panic>
		assert(c[i] == 0);
f0101d98:	68 af 81 10 f0       	push   $0xf01081af
f0101d9d:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0101da2:	68 11 03 00 00       	push   $0x311
f0101da7:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0101dac:	e8 e3 e2 ff ff       	call   f0100094 <_panic>
		--nfree;
f0101db1:	4b                   	dec    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101db2:	8b 00                	mov    (%eax),%eax
f0101db4:	85 c0                	test   %eax,%eax
f0101db6:	75 f9                	jne    f0101db1 <mem_init+0x565>
	assert(nfree == 0);
f0101db8:	85 db                	test   %ebx,%ebx
f0101dba:	0f 85 87 09 00 00    	jne    f0102747 <mem_init+0xefb>
	cprintf("check_page_alloc() succeeded!\n");
f0101dc0:	83 ec 0c             	sub    $0xc,%esp
f0101dc3:	68 e0 77 10 f0       	push   $0xf01077e0
f0101dc8:	e8 ed 21 00 00       	call   f0103fba <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101dcd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101dd4:	e8 52 f6 ff ff       	call   f010142b <page_alloc>
f0101dd9:	89 c7                	mov    %eax,%edi
f0101ddb:	83 c4 10             	add    $0x10,%esp
f0101dde:	85 c0                	test   %eax,%eax
f0101de0:	0f 84 7a 09 00 00    	je     f0102760 <mem_init+0xf14>
	assert((pp1 = page_alloc(0)));
f0101de6:	83 ec 0c             	sub    $0xc,%esp
f0101de9:	6a 00                	push   $0x0
f0101deb:	e8 3b f6 ff ff       	call   f010142b <page_alloc>
f0101df0:	89 c3                	mov    %eax,%ebx
f0101df2:	83 c4 10             	add    $0x10,%esp
f0101df5:	85 c0                	test   %eax,%eax
f0101df7:	0f 84 7c 09 00 00    	je     f0102779 <mem_init+0xf2d>
	assert((pp2 = page_alloc(0)));
f0101dfd:	83 ec 0c             	sub    $0xc,%esp
f0101e00:	6a 00                	push   $0x0
f0101e02:	e8 24 f6 ff ff       	call   f010142b <page_alloc>
f0101e07:	89 c6                	mov    %eax,%esi
f0101e09:	83 c4 10             	add    $0x10,%esp
f0101e0c:	85 c0                	test   %eax,%eax
f0101e0e:	0f 84 7e 09 00 00    	je     f0102792 <mem_init+0xf46>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101e14:	39 df                	cmp    %ebx,%edi
f0101e16:	0f 84 8f 09 00 00    	je     f01027ab <mem_init+0xf5f>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101e1c:	39 c3                	cmp    %eax,%ebx
f0101e1e:	0f 84 a0 09 00 00    	je     f01027c4 <mem_init+0xf78>
f0101e24:	39 c7                	cmp    %eax,%edi
f0101e26:	0f 84 98 09 00 00    	je     f01027c4 <mem_init+0xf78>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101e2c:	a1 40 52 2a f0       	mov    0xf02a5240,%eax
f0101e31:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f0101e34:	c7 05 40 52 2a f0 00 	movl   $0x0,0xf02a5240
f0101e3b:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101e3e:	83 ec 0c             	sub    $0xc,%esp
f0101e41:	6a 00                	push   $0x0
f0101e43:	e8 e3 f5 ff ff       	call   f010142b <page_alloc>
f0101e48:	83 c4 10             	add    $0x10,%esp
f0101e4b:	85 c0                	test   %eax,%eax
f0101e4d:	0f 85 8a 09 00 00    	jne    f01027dd <mem_init+0xf91>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101e53:	83 ec 04             	sub    $0x4,%esp
f0101e56:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101e59:	50                   	push   %eax
f0101e5a:	6a 00                	push   $0x0
f0101e5c:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f0101e62:	e8 14 f8 ff ff       	call   f010167b <page_lookup>
f0101e67:	83 c4 10             	add    $0x10,%esp
f0101e6a:	85 c0                	test   %eax,%eax
f0101e6c:	0f 85 84 09 00 00    	jne    f01027f6 <mem_init+0xfaa>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101e72:	6a 02                	push   $0x2
f0101e74:	6a 00                	push   $0x0
f0101e76:	53                   	push   %ebx
f0101e77:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f0101e7d:	e8 02 f9 ff ff       	call   f0101784 <page_insert>
f0101e82:	83 c4 10             	add    $0x10,%esp
f0101e85:	85 c0                	test   %eax,%eax
f0101e87:	0f 89 82 09 00 00    	jns    f010280f <mem_init+0xfc3>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101e8d:	83 ec 0c             	sub    $0xc,%esp
f0101e90:	57                   	push   %edi
f0101e91:	e8 07 f6 ff ff       	call   f010149d <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101e96:	6a 02                	push   $0x2
f0101e98:	6a 00                	push   $0x0
f0101e9a:	53                   	push   %ebx
f0101e9b:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f0101ea1:	e8 de f8 ff ff       	call   f0101784 <page_insert>
f0101ea6:	83 c4 20             	add    $0x20,%esp
f0101ea9:	85 c0                	test   %eax,%eax
f0101eab:	0f 85 77 09 00 00    	jne    f0102828 <mem_init+0xfdc>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101eb1:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f0101eb6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	return (pp - pages) << PGSHIFT;
f0101eb9:	8b 0d 90 5e 2a f0    	mov    0xf02a5e90,%ecx
f0101ebf:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101ec2:	8b 00                	mov    (%eax),%eax
f0101ec4:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101ec7:	89 c2                	mov    %eax,%edx
f0101ec9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101ecf:	89 f8                	mov    %edi,%eax
f0101ed1:	29 c8                	sub    %ecx,%eax
f0101ed3:	c1 f8 03             	sar    $0x3,%eax
f0101ed6:	c1 e0 0c             	shl    $0xc,%eax
f0101ed9:	39 c2                	cmp    %eax,%edx
f0101edb:	0f 85 60 09 00 00    	jne    f0102841 <mem_init+0xff5>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101ee1:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ee6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ee9:	e8 29 f1 ff ff       	call   f0101017 <check_va2pa>
f0101eee:	89 da                	mov    %ebx,%edx
f0101ef0:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101ef3:	c1 fa 03             	sar    $0x3,%edx
f0101ef6:	c1 e2 0c             	shl    $0xc,%edx
f0101ef9:	39 d0                	cmp    %edx,%eax
f0101efb:	0f 85 59 09 00 00    	jne    f010285a <mem_init+0x100e>
	assert(pp1->pp_ref == 1);
f0101f01:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f06:	0f 85 67 09 00 00    	jne    f0102873 <mem_init+0x1027>
	assert(pp0->pp_ref == 1);
f0101f0c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101f11:	0f 85 75 09 00 00    	jne    f010288c <mem_init+0x1040>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f17:	6a 02                	push   $0x2
f0101f19:	68 00 10 00 00       	push   $0x1000
f0101f1e:	56                   	push   %esi
f0101f1f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f22:	e8 5d f8 ff ff       	call   f0101784 <page_insert>
f0101f27:	83 c4 10             	add    $0x10,%esp
f0101f2a:	85 c0                	test   %eax,%eax
f0101f2c:	0f 85 73 09 00 00    	jne    f01028a5 <mem_init+0x1059>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f32:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f37:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f0101f3c:	e8 d6 f0 ff ff       	call   f0101017 <check_va2pa>
f0101f41:	89 f2                	mov    %esi,%edx
f0101f43:	2b 15 90 5e 2a f0    	sub    0xf02a5e90,%edx
f0101f49:	c1 fa 03             	sar    $0x3,%edx
f0101f4c:	c1 e2 0c             	shl    $0xc,%edx
f0101f4f:	39 d0                	cmp    %edx,%eax
f0101f51:	0f 85 67 09 00 00    	jne    f01028be <mem_init+0x1072>
	assert(pp2->pp_ref == 1);
f0101f57:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f5c:	0f 85 75 09 00 00    	jne    f01028d7 <mem_init+0x108b>

	// should be no free memory
	assert(!page_alloc(0));
f0101f62:	83 ec 0c             	sub    $0xc,%esp
f0101f65:	6a 00                	push   $0x0
f0101f67:	e8 bf f4 ff ff       	call   f010142b <page_alloc>
f0101f6c:	83 c4 10             	add    $0x10,%esp
f0101f6f:	85 c0                	test   %eax,%eax
f0101f71:	0f 85 79 09 00 00    	jne    f01028f0 <mem_init+0x10a4>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f77:	6a 02                	push   $0x2
f0101f79:	68 00 10 00 00       	push   $0x1000
f0101f7e:	56                   	push   %esi
f0101f7f:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f0101f85:	e8 fa f7 ff ff       	call   f0101784 <page_insert>
f0101f8a:	83 c4 10             	add    $0x10,%esp
f0101f8d:	85 c0                	test   %eax,%eax
f0101f8f:	0f 85 74 09 00 00    	jne    f0102909 <mem_init+0x10bd>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f95:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f9a:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f0101f9f:	e8 73 f0 ff ff       	call   f0101017 <check_va2pa>
f0101fa4:	89 f2                	mov    %esi,%edx
f0101fa6:	2b 15 90 5e 2a f0    	sub    0xf02a5e90,%edx
f0101fac:	c1 fa 03             	sar    $0x3,%edx
f0101faf:	c1 e2 0c             	shl    $0xc,%edx
f0101fb2:	39 d0                	cmp    %edx,%eax
f0101fb4:	0f 85 68 09 00 00    	jne    f0102922 <mem_init+0x10d6>
	assert(pp2->pp_ref == 1);
f0101fba:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101fbf:	0f 85 76 09 00 00    	jne    f010293b <mem_init+0x10ef>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101fc5:	83 ec 0c             	sub    $0xc,%esp
f0101fc8:	6a 00                	push   $0x0
f0101fca:	e8 5c f4 ff ff       	call   f010142b <page_alloc>
f0101fcf:	83 c4 10             	add    $0x10,%esp
f0101fd2:	85 c0                	test   %eax,%eax
f0101fd4:	0f 85 7a 09 00 00    	jne    f0102954 <mem_init+0x1108>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101fda:	8b 15 8c 5e 2a f0    	mov    0xf02a5e8c,%edx
f0101fe0:	8b 02                	mov    (%edx),%eax
f0101fe2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101fe7:	89 c1                	mov    %eax,%ecx
f0101fe9:	c1 e9 0c             	shr    $0xc,%ecx
f0101fec:	3b 0d 88 5e 2a f0    	cmp    0xf02a5e88,%ecx
f0101ff2:	0f 83 75 09 00 00    	jae    f010296d <mem_init+0x1121>
	return (void *)(pa + KERNBASE);
f0101ff8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ffd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102000:	83 ec 04             	sub    $0x4,%esp
f0102003:	6a 00                	push   $0x0
f0102005:	68 00 10 00 00       	push   $0x1000
f010200a:	52                   	push   %edx
f010200b:	e8 05 f5 ff ff       	call   f0101515 <pgdir_walk>
f0102010:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102013:	8d 51 04             	lea    0x4(%ecx),%edx
f0102016:	83 c4 10             	add    $0x10,%esp
f0102019:	39 d0                	cmp    %edx,%eax
f010201b:	0f 85 61 09 00 00    	jne    f0102982 <mem_init+0x1136>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102021:	6a 06                	push   $0x6
f0102023:	68 00 10 00 00       	push   $0x1000
f0102028:	56                   	push   %esi
f0102029:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f010202f:	e8 50 f7 ff ff       	call   f0101784 <page_insert>
f0102034:	83 c4 10             	add    $0x10,%esp
f0102037:	85 c0                	test   %eax,%eax
f0102039:	0f 85 5c 09 00 00    	jne    f010299b <mem_init+0x114f>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010203f:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f0102044:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102047:	ba 00 10 00 00       	mov    $0x1000,%edx
f010204c:	e8 c6 ef ff ff       	call   f0101017 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0102051:	89 f2                	mov    %esi,%edx
f0102053:	2b 15 90 5e 2a f0    	sub    0xf02a5e90,%edx
f0102059:	c1 fa 03             	sar    $0x3,%edx
f010205c:	c1 e2 0c             	shl    $0xc,%edx
f010205f:	39 d0                	cmp    %edx,%eax
f0102061:	0f 85 4d 09 00 00    	jne    f01029b4 <mem_init+0x1168>
	assert(pp2->pp_ref == 1);
f0102067:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010206c:	0f 85 5b 09 00 00    	jne    f01029cd <mem_init+0x1181>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102072:	83 ec 04             	sub    $0x4,%esp
f0102075:	6a 00                	push   $0x0
f0102077:	68 00 10 00 00       	push   $0x1000
f010207c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010207f:	e8 91 f4 ff ff       	call   f0101515 <pgdir_walk>
f0102084:	83 c4 10             	add    $0x10,%esp
f0102087:	f6 00 04             	testb  $0x4,(%eax)
f010208a:	0f 84 56 09 00 00    	je     f01029e6 <mem_init+0x119a>
	assert(kern_pgdir[0] & PTE_U);
f0102090:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f0102095:	f6 00 04             	testb  $0x4,(%eax)
f0102098:	0f 84 61 09 00 00    	je     f01029ff <mem_init+0x11b3>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010209e:	6a 02                	push   $0x2
f01020a0:	68 00 10 00 00       	push   $0x1000
f01020a5:	56                   	push   %esi
f01020a6:	50                   	push   %eax
f01020a7:	e8 d8 f6 ff ff       	call   f0101784 <page_insert>
f01020ac:	83 c4 10             	add    $0x10,%esp
f01020af:	85 c0                	test   %eax,%eax
f01020b1:	0f 85 61 09 00 00    	jne    f0102a18 <mem_init+0x11cc>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01020b7:	83 ec 04             	sub    $0x4,%esp
f01020ba:	6a 00                	push   $0x0
f01020bc:	68 00 10 00 00       	push   $0x1000
f01020c1:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f01020c7:	e8 49 f4 ff ff       	call   f0101515 <pgdir_walk>
f01020cc:	83 c4 10             	add    $0x10,%esp
f01020cf:	f6 00 02             	testb  $0x2,(%eax)
f01020d2:	0f 84 59 09 00 00    	je     f0102a31 <mem_init+0x11e5>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020d8:	83 ec 04             	sub    $0x4,%esp
f01020db:	6a 00                	push   $0x0
f01020dd:	68 00 10 00 00       	push   $0x1000
f01020e2:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f01020e8:	e8 28 f4 ff ff       	call   f0101515 <pgdir_walk>
f01020ed:	83 c4 10             	add    $0x10,%esp
f01020f0:	f6 00 04             	testb  $0x4,(%eax)
f01020f3:	0f 85 51 09 00 00    	jne    f0102a4a <mem_init+0x11fe>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01020f9:	6a 02                	push   $0x2
f01020fb:	68 00 00 40 00       	push   $0x400000
f0102100:	57                   	push   %edi
f0102101:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f0102107:	e8 78 f6 ff ff       	call   f0101784 <page_insert>
f010210c:	83 c4 10             	add    $0x10,%esp
f010210f:	85 c0                	test   %eax,%eax
f0102111:	0f 89 4c 09 00 00    	jns    f0102a63 <mem_init+0x1217>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102117:	6a 02                	push   $0x2
f0102119:	68 00 10 00 00       	push   $0x1000
f010211e:	53                   	push   %ebx
f010211f:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f0102125:	e8 5a f6 ff ff       	call   f0101784 <page_insert>
f010212a:	83 c4 10             	add    $0x10,%esp
f010212d:	85 c0                	test   %eax,%eax
f010212f:	0f 85 47 09 00 00    	jne    f0102a7c <mem_init+0x1230>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102135:	83 ec 04             	sub    $0x4,%esp
f0102138:	6a 00                	push   $0x0
f010213a:	68 00 10 00 00       	push   $0x1000
f010213f:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f0102145:	e8 cb f3 ff ff       	call   f0101515 <pgdir_walk>
f010214a:	83 c4 10             	add    $0x10,%esp
f010214d:	f6 00 04             	testb  $0x4,(%eax)
f0102150:	0f 85 3f 09 00 00    	jne    f0102a95 <mem_init+0x1249>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102156:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f010215b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010215e:	ba 00 00 00 00       	mov    $0x0,%edx
f0102163:	e8 af ee ff ff       	call   f0101017 <check_va2pa>
f0102168:	89 c1                	mov    %eax,%ecx
f010216a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010216d:	89 d8                	mov    %ebx,%eax
f010216f:	2b 05 90 5e 2a f0    	sub    0xf02a5e90,%eax
f0102175:	c1 f8 03             	sar    $0x3,%eax
f0102178:	c1 e0 0c             	shl    $0xc,%eax
f010217b:	39 c1                	cmp    %eax,%ecx
f010217d:	0f 85 2b 09 00 00    	jne    f0102aae <mem_init+0x1262>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102183:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102188:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010218b:	e8 87 ee ff ff       	call   f0101017 <check_va2pa>
f0102190:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102193:	0f 85 2e 09 00 00    	jne    f0102ac7 <mem_init+0x127b>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102199:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f010219e:	0f 85 3c 09 00 00    	jne    f0102ae0 <mem_init+0x1294>
	assert(pp2->pp_ref == 0);
f01021a4:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01021a9:	0f 85 4a 09 00 00    	jne    f0102af9 <mem_init+0x12ad>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01021af:	83 ec 0c             	sub    $0xc,%esp
f01021b2:	6a 00                	push   $0x0
f01021b4:	e8 72 f2 ff ff       	call   f010142b <page_alloc>
f01021b9:	83 c4 10             	add    $0x10,%esp
f01021bc:	85 c0                	test   %eax,%eax
f01021be:	0f 84 4e 09 00 00    	je     f0102b12 <mem_init+0x12c6>
f01021c4:	39 c6                	cmp    %eax,%esi
f01021c6:	0f 85 46 09 00 00    	jne    f0102b12 <mem_init+0x12c6>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01021cc:	83 ec 08             	sub    $0x8,%esp
f01021cf:	6a 00                	push   $0x0
f01021d1:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f01021d7:	e8 4e f5 ff ff       	call   f010172a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01021dc:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f01021e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01021e4:	ba 00 00 00 00       	mov    $0x0,%edx
f01021e9:	e8 29 ee ff ff       	call   f0101017 <check_va2pa>
f01021ee:	83 c4 10             	add    $0x10,%esp
f01021f1:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021f4:	0f 85 31 09 00 00    	jne    f0102b2b <mem_init+0x12df>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01021fa:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102202:	e8 10 ee ff ff       	call   f0101017 <check_va2pa>
f0102207:	89 da                	mov    %ebx,%edx
f0102209:	2b 15 90 5e 2a f0    	sub    0xf02a5e90,%edx
f010220f:	c1 fa 03             	sar    $0x3,%edx
f0102212:	c1 e2 0c             	shl    $0xc,%edx
f0102215:	39 d0                	cmp    %edx,%eax
f0102217:	0f 85 27 09 00 00    	jne    f0102b44 <mem_init+0x12f8>
	assert(pp1->pp_ref == 1);
f010221d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102222:	0f 85 35 09 00 00    	jne    f0102b5d <mem_init+0x1311>
	assert(pp2->pp_ref == 0);
f0102228:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010222d:	0f 85 43 09 00 00    	jne    f0102b76 <mem_init+0x132a>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102233:	6a 00                	push   $0x0
f0102235:	68 00 10 00 00       	push   $0x1000
f010223a:	53                   	push   %ebx
f010223b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010223e:	e8 41 f5 ff ff       	call   f0101784 <page_insert>
f0102243:	83 c4 10             	add    $0x10,%esp
f0102246:	85 c0                	test   %eax,%eax
f0102248:	0f 85 41 09 00 00    	jne    f0102b8f <mem_init+0x1343>
	assert(pp1->pp_ref);
f010224e:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102253:	0f 84 4f 09 00 00    	je     f0102ba8 <mem_init+0x135c>
	assert(pp1->pp_link == NULL);
f0102259:	83 3b 00             	cmpl   $0x0,(%ebx)
f010225c:	0f 85 5f 09 00 00    	jne    f0102bc1 <mem_init+0x1375>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102262:	83 ec 08             	sub    $0x8,%esp
f0102265:	68 00 10 00 00       	push   $0x1000
f010226a:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f0102270:	e8 b5 f4 ff ff       	call   f010172a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102275:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f010227a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010227d:	ba 00 00 00 00       	mov    $0x0,%edx
f0102282:	e8 90 ed ff ff       	call   f0101017 <check_va2pa>
f0102287:	83 c4 10             	add    $0x10,%esp
f010228a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010228d:	0f 85 47 09 00 00    	jne    f0102bda <mem_init+0x138e>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102293:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102298:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010229b:	e8 77 ed ff ff       	call   f0101017 <check_va2pa>
f01022a0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022a3:	0f 85 4a 09 00 00    	jne    f0102bf3 <mem_init+0x13a7>
	assert(pp1->pp_ref == 0);
f01022a9:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022ae:	0f 85 58 09 00 00    	jne    f0102c0c <mem_init+0x13c0>
	assert(pp2->pp_ref == 0);
f01022b4:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01022b9:	0f 85 66 09 00 00    	jne    f0102c25 <mem_init+0x13d9>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01022bf:	83 ec 0c             	sub    $0xc,%esp
f01022c2:	6a 00                	push   $0x0
f01022c4:	e8 62 f1 ff ff       	call   f010142b <page_alloc>
f01022c9:	83 c4 10             	add    $0x10,%esp
f01022cc:	85 c0                	test   %eax,%eax
f01022ce:	0f 84 6a 09 00 00    	je     f0102c3e <mem_init+0x13f2>
f01022d4:	39 c3                	cmp    %eax,%ebx
f01022d6:	0f 85 62 09 00 00    	jne    f0102c3e <mem_init+0x13f2>

	// should be no free memory
	assert(!page_alloc(0));
f01022dc:	83 ec 0c             	sub    $0xc,%esp
f01022df:	6a 00                	push   $0x0
f01022e1:	e8 45 f1 ff ff       	call   f010142b <page_alloc>
f01022e6:	83 c4 10             	add    $0x10,%esp
f01022e9:	85 c0                	test   %eax,%eax
f01022eb:	0f 85 66 09 00 00    	jne    f0102c57 <mem_init+0x140b>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022f1:	8b 0d 8c 5e 2a f0    	mov    0xf02a5e8c,%ecx
f01022f7:	8b 11                	mov    (%ecx),%edx
f01022f9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01022ff:	89 f8                	mov    %edi,%eax
f0102301:	2b 05 90 5e 2a f0    	sub    0xf02a5e90,%eax
f0102307:	c1 f8 03             	sar    $0x3,%eax
f010230a:	c1 e0 0c             	shl    $0xc,%eax
f010230d:	39 c2                	cmp    %eax,%edx
f010230f:	0f 85 5b 09 00 00    	jne    f0102c70 <mem_init+0x1424>
	kern_pgdir[0] = 0;
f0102315:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010231b:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102320:	0f 85 63 09 00 00    	jne    f0102c89 <mem_init+0x143d>
	pp0->pp_ref = 0;
f0102326:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010232c:	83 ec 0c             	sub    $0xc,%esp
f010232f:	57                   	push   %edi
f0102330:	e8 68 f1 ff ff       	call   f010149d <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102335:	83 c4 0c             	add    $0xc,%esp
f0102338:	6a 01                	push   $0x1
f010233a:	68 00 10 40 00       	push   $0x401000
f010233f:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f0102345:	e8 cb f1 ff ff       	call   f0101515 <pgdir_walk>
f010234a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010234d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102350:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f0102355:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102358:	8b 50 04             	mov    0x4(%eax),%edx
f010235b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0102361:	a1 88 5e 2a f0       	mov    0xf02a5e88,%eax
f0102366:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102369:	89 d1                	mov    %edx,%ecx
f010236b:	c1 e9 0c             	shr    $0xc,%ecx
f010236e:	83 c4 10             	add    $0x10,%esp
f0102371:	39 c1                	cmp    %eax,%ecx
f0102373:	0f 83 29 09 00 00    	jae    f0102ca2 <mem_init+0x1456>
	assert(ptep == ptep1 + PTX(va));
f0102379:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f010237f:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0102382:	0f 85 2f 09 00 00    	jne    f0102cb7 <mem_init+0x146b>
	kern_pgdir[PDX(va)] = 0;
f0102388:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010238b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102392:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
	return (pp - pages) << PGSHIFT;
f0102398:	89 f8                	mov    %edi,%eax
f010239a:	2b 05 90 5e 2a f0    	sub    0xf02a5e90,%eax
f01023a0:	c1 f8 03             	sar    $0x3,%eax
f01023a3:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01023a6:	89 c2                	mov    %eax,%edx
f01023a8:	c1 ea 0c             	shr    $0xc,%edx
f01023ab:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f01023ae:	0f 86 1c 09 00 00    	jbe    f0102cd0 <mem_init+0x1484>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01023b4:	83 ec 04             	sub    $0x4,%esp
f01023b7:	68 00 10 00 00       	push   $0x1000
f01023bc:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01023c1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01023c6:	50                   	push   %eax
f01023c7:	e8 6c 3c 00 00       	call   f0106038 <memset>
	page_free(pp0);
f01023cc:	89 3c 24             	mov    %edi,(%esp)
f01023cf:	e8 c9 f0 ff ff       	call   f010149d <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01023d4:	83 c4 0c             	add    $0xc,%esp
f01023d7:	6a 01                	push   $0x1
f01023d9:	6a 00                	push   $0x0
f01023db:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f01023e1:	e8 2f f1 ff ff       	call   f0101515 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f01023e6:	89 fa                	mov    %edi,%edx
f01023e8:	2b 15 90 5e 2a f0    	sub    0xf02a5e90,%edx
f01023ee:	c1 fa 03             	sar    $0x3,%edx
f01023f1:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01023f4:	89 d0                	mov    %edx,%eax
f01023f6:	c1 e8 0c             	shr    $0xc,%eax
f01023f9:	83 c4 10             	add    $0x10,%esp
f01023fc:	3b 05 88 5e 2a f0    	cmp    0xf02a5e88,%eax
f0102402:	0f 83 da 08 00 00    	jae    f0102ce2 <mem_init+0x1496>
	return (void *)(pa + KERNBASE);
f0102408:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010240e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102411:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102417:	f6 00 01             	testb  $0x1,(%eax)
f010241a:	0f 85 d4 08 00 00    	jne    f0102cf4 <mem_init+0x14a8>
f0102420:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0102423:	39 d0                	cmp    %edx,%eax
f0102425:	75 f0                	jne    f0102417 <mem_init+0xbcb>
	kern_pgdir[0] = 0;
f0102427:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f010242c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102432:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102438:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010243b:	a3 40 52 2a f0       	mov    %eax,0xf02a5240

	// free the pages we took
	page_free(pp0);
f0102440:	83 ec 0c             	sub    $0xc,%esp
f0102443:	57                   	push   %edi
f0102444:	e8 54 f0 ff ff       	call   f010149d <page_free>
	page_free(pp1);
f0102449:	89 1c 24             	mov    %ebx,(%esp)
f010244c:	e8 4c f0 ff ff       	call   f010149d <page_free>
	page_free(pp2);
f0102451:	89 34 24             	mov    %esi,(%esp)
f0102454:	e8 44 f0 ff ff       	call   f010149d <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102459:	83 c4 08             	add    $0x8,%esp
f010245c:	68 01 10 00 00       	push   $0x1001
f0102461:	6a 00                	push   $0x0
f0102463:	e8 83 f3 ff ff       	call   f01017eb <mmio_map_region>
f0102468:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f010246a:	83 c4 08             	add    $0x8,%esp
f010246d:	68 00 10 00 00       	push   $0x1000
f0102472:	6a 00                	push   $0x0
f0102474:	e8 72 f3 ff ff       	call   f01017eb <mmio_map_region>
f0102479:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f010247b:	83 c4 10             	add    $0x10,%esp
f010247e:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102484:	0f 86 83 08 00 00    	jbe    f0102d0d <mem_init+0x14c1>
f010248a:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102490:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102495:	0f 87 72 08 00 00    	ja     f0102d0d <mem_init+0x14c1>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f010249b:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01024a1:	0f 86 7f 08 00 00    	jbe    f0102d26 <mem_init+0x14da>
f01024a7:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f01024ad:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01024b3:	0f 87 6d 08 00 00    	ja     f0102d26 <mem_init+0x14da>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01024b9:	89 da                	mov    %ebx,%edx
f01024bb:	09 f2                	or     %esi,%edx
f01024bd:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01024c3:	0f 85 76 08 00 00    	jne    f0102d3f <mem_init+0x14f3>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01024c9:	39 c6                	cmp    %eax,%esi
f01024cb:	0f 82 87 08 00 00    	jb     f0102d58 <mem_init+0x150c>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01024d1:	8b 3d 8c 5e 2a f0    	mov    0xf02a5e8c,%edi
f01024d7:	89 da                	mov    %ebx,%edx
f01024d9:	89 f8                	mov    %edi,%eax
f01024db:	e8 37 eb ff ff       	call   f0101017 <check_va2pa>
f01024e0:	85 c0                	test   %eax,%eax
f01024e2:	0f 85 89 08 00 00    	jne    f0102d71 <mem_init+0x1525>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01024e8:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01024ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01024f1:	89 c2                	mov    %eax,%edx
f01024f3:	89 f8                	mov    %edi,%eax
f01024f5:	e8 1d eb ff ff       	call   f0101017 <check_va2pa>
f01024fa:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01024ff:	0f 85 85 08 00 00    	jne    f0102d8a <mem_init+0x153e>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102505:	89 f2                	mov    %esi,%edx
f0102507:	89 f8                	mov    %edi,%eax
f0102509:	e8 09 eb ff ff       	call   f0101017 <check_va2pa>
f010250e:	85 c0                	test   %eax,%eax
f0102510:	0f 85 8d 08 00 00    	jne    f0102da3 <mem_init+0x1557>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102516:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f010251c:	89 f8                	mov    %edi,%eax
f010251e:	e8 f4 ea ff ff       	call   f0101017 <check_va2pa>
f0102523:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102526:	0f 85 90 08 00 00    	jne    f0102dbc <mem_init+0x1570>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010252c:	83 ec 04             	sub    $0x4,%esp
f010252f:	6a 00                	push   $0x0
f0102531:	53                   	push   %ebx
f0102532:	57                   	push   %edi
f0102533:	e8 dd ef ff ff       	call   f0101515 <pgdir_walk>
f0102538:	83 c4 10             	add    $0x10,%esp
f010253b:	f6 00 1a             	testb  $0x1a,(%eax)
f010253e:	0f 84 91 08 00 00    	je     f0102dd5 <mem_init+0x1589>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102544:	83 ec 04             	sub    $0x4,%esp
f0102547:	6a 00                	push   $0x0
f0102549:	53                   	push   %ebx
f010254a:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f0102550:	e8 c0 ef ff ff       	call   f0101515 <pgdir_walk>
f0102555:	83 c4 10             	add    $0x10,%esp
f0102558:	f6 00 04             	testb  $0x4,(%eax)
f010255b:	0f 85 8d 08 00 00    	jne    f0102dee <mem_init+0x15a2>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102561:	83 ec 04             	sub    $0x4,%esp
f0102564:	6a 00                	push   $0x0
f0102566:	53                   	push   %ebx
f0102567:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f010256d:	e8 a3 ef ff ff       	call   f0101515 <pgdir_walk>
f0102572:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102578:	83 c4 0c             	add    $0xc,%esp
f010257b:	6a 00                	push   $0x0
f010257d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102580:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f0102586:	e8 8a ef ff ff       	call   f0101515 <pgdir_walk>
f010258b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102591:	83 c4 0c             	add    $0xc,%esp
f0102594:	6a 00                	push   $0x0
f0102596:	56                   	push   %esi
f0102597:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f010259d:	e8 73 ef ff ff       	call   f0101515 <pgdir_walk>
f01025a2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f01025a8:	c7 04 24 a2 82 10 f0 	movl   $0xf01082a2,(%esp)
f01025af:	e8 06 1a 00 00       	call   f0103fba <cprintf>
	pginfo_sz = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01025b4:	a1 88 5e 2a f0       	mov    0xf02a5e88,%eax
f01025b9:	8d 0c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ecx
f01025c0:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_region(kern_pgdir, UPAGES, pginfo_sz, PADDR(pages), PTE_U | PTE_P);
f01025c6:	a1 90 5e 2a f0       	mov    0xf02a5e90,%eax
	if ((uint32_t)kva < KERNBASE)
f01025cb:	83 c4 10             	add    $0x10,%esp
f01025ce:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025d3:	0f 86 2e 08 00 00    	jbe    f0102e07 <mem_init+0x15bb>
f01025d9:	83 ec 08             	sub    $0x8,%esp
f01025dc:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01025de:	05 00 00 00 10       	add    $0x10000000,%eax
f01025e3:	50                   	push   %eax
f01025e4:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01025e9:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f01025ee:	e8 39 f0 ff ff       	call   f010162c <boot_map_region>
	env_sz = ROUNDUP(npages*sizeof(struct Env), PGSIZE);
f01025f3:	8b 15 88 5e 2a f0    	mov    0xf02a5e88,%edx
f01025f9:	89 d0                	mov    %edx,%eax
f01025fb:	c1 e0 05             	shl    $0x5,%eax
f01025fe:	29 d0                	sub    %edx,%eax
f0102600:	8d 0c 85 ff 0f 00 00 	lea    0xfff(,%eax,4),%ecx
f0102607:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_region(kern_pgdir, UENVS, env_sz, PADDR(envs), PTE_U | PTE_P);
f010260d:	a1 48 52 2a f0       	mov    0xf02a5248,%eax
	if ((uint32_t)kva < KERNBASE)
f0102612:	83 c4 10             	add    $0x10,%esp
f0102615:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010261a:	0f 86 fc 07 00 00    	jbe    f0102e1c <mem_init+0x15d0>
f0102620:	83 ec 08             	sub    $0x8,%esp
f0102623:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102625:	05 00 00 00 10       	add    $0x10000000,%eax
f010262a:	50                   	push   %eax
f010262b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102630:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f0102635:	e8 f2 ef ff ff       	call   f010162c <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f010263a:	83 c4 10             	add    $0x10,%esp
f010263d:	b8 00 90 11 f0       	mov    $0xf0119000,%eax
f0102642:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102647:	0f 86 e4 07 00 00    	jbe    f0102e31 <mem_init+0x15e5>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, 
f010264d:	83 ec 08             	sub    $0x8,%esp
f0102650:	6a 03                	push   $0x3
f0102652:	68 00 90 11 00       	push   $0x119000
f0102657:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010265c:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102661:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f0102666:	e8 c1 ef ff ff       	call   f010162c <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 1 << 28, // 2^32 - 0xf0000000
f010266b:	83 c4 08             	add    $0x8,%esp
f010266e:	6a 03                	push   $0x3
f0102670:	6a 00                	push   $0x0
f0102672:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102677:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010267c:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f0102681:	e8 a6 ef ff ff       	call   f010162c <boot_map_region>
f0102686:	c7 45 c8 00 70 2a f0 	movl   $0xf02a7000,-0x38(%ebp)
f010268d:	be 00 70 2e f0       	mov    $0xf02e7000,%esi
f0102692:	83 c4 10             	add    $0x10,%esp
f0102695:	bf 00 70 2a f0       	mov    $0xf02a7000,%edi
f010269a:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
f010269f:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f01026a5:	0f 86 9b 07 00 00    	jbe    f0102e46 <mem_init+0x15fa>
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, 
f01026ab:	83 ec 08             	sub    $0x8,%esp
f01026ae:	6a 02                	push   $0x2
f01026b0:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01026b6:	50                   	push   %eax
f01026b7:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01026bc:	89 da                	mov    %ebx,%edx
f01026be:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
f01026c3:	e8 64 ef ff ff       	call   f010162c <boot_map_region>
f01026c8:	81 c7 00 80 00 00    	add    $0x8000,%edi
f01026ce:	81 eb 00 00 01 00    	sub    $0x10000,%ebx
	for (size_t i = 0; i < NCPU; i++) { // `ncpu` is not set yet, we just use NCPU = 8.
f01026d4:	83 c4 10             	add    $0x10,%esp
f01026d7:	39 f7                	cmp    %esi,%edi
f01026d9:	75 c4                	jne    f010269f <mem_init+0xe53>
f01026db:	89 7d c4             	mov    %edi,-0x3c(%ebp)
	pgdir = kern_pgdir;
f01026de:	8b 3d 8c 5e 2a f0    	mov    0xf02a5e8c,%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01026e4:	a1 88 5e 2a f0       	mov    0xf02a5e88,%eax
f01026e9:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01026ec:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01026f3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01026f8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01026fb:	a1 90 5e 2a f0       	mov    0xf02a5e90,%eax
f0102700:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0102703:	89 45 d0             	mov    %eax,-0x30(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0102706:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
	for (i = 0; i < n; i += PGSIZE) 
f010270c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102711:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102714:	0f 86 71 07 00 00    	jbe    f0102e8b <mem_init+0x163f>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010271a:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102720:	89 f8                	mov    %edi,%eax
f0102722:	e8 f0 e8 ff ff       	call   f0101017 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102727:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010272e:	0f 86 27 07 00 00    	jbe    f0102e5b <mem_init+0x160f>
f0102734:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f0102737:	39 d0                	cmp    %edx,%eax
f0102739:	0f 85 33 07 00 00    	jne    f0102e72 <mem_init+0x1626>
	for (i = 0; i < n; i += PGSIZE) 
f010273f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102745:	eb ca                	jmp    f0102711 <mem_init+0xec5>
	assert(nfree == 0);
f0102747:	68 b9 81 10 f0       	push   $0xf01081b9
f010274c:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102751:	68 1e 03 00 00       	push   $0x31e
f0102756:	68 9d 7f 10 f0       	push   $0xf0107f9d
f010275b:	e8 34 d9 ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0102760:	68 c7 80 10 f0       	push   $0xf01080c7
f0102765:	68 c3 7f 10 f0       	push   $0xf0107fc3
f010276a:	68 84 03 00 00       	push   $0x384
f010276f:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102774:	e8 1b d9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0102779:	68 dd 80 10 f0       	push   $0xf01080dd
f010277e:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102783:	68 85 03 00 00       	push   $0x385
f0102788:	68 9d 7f 10 f0       	push   $0xf0107f9d
f010278d:	e8 02 d9 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0102792:	68 f3 80 10 f0       	push   $0xf01080f3
f0102797:	68 c3 7f 10 f0       	push   $0xf0107fc3
f010279c:	68 86 03 00 00       	push   $0x386
f01027a1:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01027a6:	e8 e9 d8 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f01027ab:	68 09 81 10 f0       	push   $0xf0108109
f01027b0:	68 c3 7f 10 f0       	push   $0xf0107fc3
f01027b5:	68 89 03 00 00       	push   $0x389
f01027ba:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01027bf:	e8 d0 d8 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01027c4:	68 c0 77 10 f0       	push   $0xf01077c0
f01027c9:	68 c3 7f 10 f0       	push   $0xf0107fc3
f01027ce:	68 8a 03 00 00       	push   $0x38a
f01027d3:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01027d8:	e8 b7 d8 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01027dd:	68 72 81 10 f0       	push   $0xf0108172
f01027e2:	68 c3 7f 10 f0       	push   $0xf0107fc3
f01027e7:	68 91 03 00 00       	push   $0x391
f01027ec:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01027f1:	e8 9e d8 ff ff       	call   f0100094 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01027f6:	68 00 78 10 f0       	push   $0xf0107800
f01027fb:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102800:	68 94 03 00 00       	push   $0x394
f0102805:	68 9d 7f 10 f0       	push   $0xf0107f9d
f010280a:	e8 85 d8 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010280f:	68 38 78 10 f0       	push   $0xf0107838
f0102814:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102819:	68 97 03 00 00       	push   $0x397
f010281e:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102823:	e8 6c d8 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102828:	68 68 78 10 f0       	push   $0xf0107868
f010282d:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102832:	68 9b 03 00 00       	push   $0x39b
f0102837:	68 9d 7f 10 f0       	push   $0xf0107f9d
f010283c:	e8 53 d8 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102841:	68 98 78 10 f0       	push   $0xf0107898
f0102846:	68 c3 7f 10 f0       	push   $0xf0107fc3
f010284b:	68 9c 03 00 00       	push   $0x39c
f0102850:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102855:	e8 3a d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010285a:	68 c0 78 10 f0       	push   $0xf01078c0
f010285f:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102864:	68 9d 03 00 00       	push   $0x39d
f0102869:	68 9d 7f 10 f0       	push   $0xf0107f9d
f010286e:	e8 21 d8 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102873:	68 c4 81 10 f0       	push   $0xf01081c4
f0102878:	68 c3 7f 10 f0       	push   $0xf0107fc3
f010287d:	68 9e 03 00 00       	push   $0x39e
f0102882:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102887:	e8 08 d8 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f010288c:	68 d5 81 10 f0       	push   $0xf01081d5
f0102891:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102896:	68 9f 03 00 00       	push   $0x39f
f010289b:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01028a0:	e8 ef d7 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01028a5:	68 f0 78 10 f0       	push   $0xf01078f0
f01028aa:	68 c3 7f 10 f0       	push   $0xf0107fc3
f01028af:	68 a2 03 00 00       	push   $0x3a2
f01028b4:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01028b9:	e8 d6 d7 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01028be:	68 2c 79 10 f0       	push   $0xf010792c
f01028c3:	68 c3 7f 10 f0       	push   $0xf0107fc3
f01028c8:	68 a3 03 00 00       	push   $0x3a3
f01028cd:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01028d2:	e8 bd d7 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f01028d7:	68 e6 81 10 f0       	push   $0xf01081e6
f01028dc:	68 c3 7f 10 f0       	push   $0xf0107fc3
f01028e1:	68 a4 03 00 00       	push   $0x3a4
f01028e6:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01028eb:	e8 a4 d7 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01028f0:	68 72 81 10 f0       	push   $0xf0108172
f01028f5:	68 c3 7f 10 f0       	push   $0xf0107fc3
f01028fa:	68 a7 03 00 00       	push   $0x3a7
f01028ff:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102904:	e8 8b d7 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102909:	68 f0 78 10 f0       	push   $0xf01078f0
f010290e:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102913:	68 aa 03 00 00       	push   $0x3aa
f0102918:	68 9d 7f 10 f0       	push   $0xf0107f9d
f010291d:	e8 72 d7 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102922:	68 2c 79 10 f0       	push   $0xf010792c
f0102927:	68 c3 7f 10 f0       	push   $0xf0107fc3
f010292c:	68 ab 03 00 00       	push   $0x3ab
f0102931:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102936:	e8 59 d7 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f010293b:	68 e6 81 10 f0       	push   $0xf01081e6
f0102940:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102945:	68 ac 03 00 00       	push   $0x3ac
f010294a:	68 9d 7f 10 f0       	push   $0xf0107f9d
f010294f:	e8 40 d7 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0102954:	68 72 81 10 f0       	push   $0xf0108172
f0102959:	68 c3 7f 10 f0       	push   $0xf0107fc3
f010295e:	68 b0 03 00 00       	push   $0x3b0
f0102963:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102968:	e8 27 d7 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010296d:	50                   	push   %eax
f010296e:	68 c8 6e 10 f0       	push   $0xf0106ec8
f0102973:	68 b3 03 00 00       	push   $0x3b3
f0102978:	68 9d 7f 10 f0       	push   $0xf0107f9d
f010297d:	e8 12 d7 ff ff       	call   f0100094 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102982:	68 5c 79 10 f0       	push   $0xf010795c
f0102987:	68 c3 7f 10 f0       	push   $0xf0107fc3
f010298c:	68 b4 03 00 00       	push   $0x3b4
f0102991:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102996:	e8 f9 d6 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010299b:	68 9c 79 10 f0       	push   $0xf010799c
f01029a0:	68 c3 7f 10 f0       	push   $0xf0107fc3
f01029a5:	68 b7 03 00 00       	push   $0x3b7
f01029aa:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01029af:	e8 e0 d6 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01029b4:	68 2c 79 10 f0       	push   $0xf010792c
f01029b9:	68 c3 7f 10 f0       	push   $0xf0107fc3
f01029be:	68 b8 03 00 00       	push   $0x3b8
f01029c3:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01029c8:	e8 c7 d6 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f01029cd:	68 e6 81 10 f0       	push   $0xf01081e6
f01029d2:	68 c3 7f 10 f0       	push   $0xf0107fc3
f01029d7:	68 b9 03 00 00       	push   $0x3b9
f01029dc:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01029e1:	e8 ae d6 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01029e6:	68 dc 79 10 f0       	push   $0xf01079dc
f01029eb:	68 c3 7f 10 f0       	push   $0xf0107fc3
f01029f0:	68 ba 03 00 00       	push   $0x3ba
f01029f5:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01029fa:	e8 95 d6 ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01029ff:	68 f7 81 10 f0       	push   $0xf01081f7
f0102a04:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102a09:	68 bb 03 00 00       	push   $0x3bb
f0102a0e:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102a13:	e8 7c d6 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102a18:	68 f0 78 10 f0       	push   $0xf01078f0
f0102a1d:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102a22:	68 be 03 00 00       	push   $0x3be
f0102a27:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102a2c:	e8 63 d6 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102a31:	68 10 7a 10 f0       	push   $0xf0107a10
f0102a36:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102a3b:	68 bf 03 00 00       	push   $0x3bf
f0102a40:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102a45:	e8 4a d6 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102a4a:	68 44 7a 10 f0       	push   $0xf0107a44
f0102a4f:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102a54:	68 c0 03 00 00       	push   $0x3c0
f0102a59:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102a5e:	e8 31 d6 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102a63:	68 7c 7a 10 f0       	push   $0xf0107a7c
f0102a68:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102a6d:	68 c3 03 00 00       	push   $0x3c3
f0102a72:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102a77:	e8 18 d6 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102a7c:	68 b4 7a 10 f0       	push   $0xf0107ab4
f0102a81:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102a86:	68 c6 03 00 00       	push   $0x3c6
f0102a8b:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102a90:	e8 ff d5 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102a95:	68 44 7a 10 f0       	push   $0xf0107a44
f0102a9a:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102a9f:	68 c7 03 00 00       	push   $0x3c7
f0102aa4:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102aa9:	e8 e6 d5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102aae:	68 f0 7a 10 f0       	push   $0xf0107af0
f0102ab3:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102ab8:	68 ca 03 00 00       	push   $0x3ca
f0102abd:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102ac2:	e8 cd d5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102ac7:	68 1c 7b 10 f0       	push   $0xf0107b1c
f0102acc:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102ad1:	68 cb 03 00 00       	push   $0x3cb
f0102ad6:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102adb:	e8 b4 d5 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 2);
f0102ae0:	68 0d 82 10 f0       	push   $0xf010820d
f0102ae5:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102aea:	68 cd 03 00 00       	push   $0x3cd
f0102aef:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102af4:	e8 9b d5 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102af9:	68 1e 82 10 f0       	push   $0xf010821e
f0102afe:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102b03:	68 ce 03 00 00       	push   $0x3ce
f0102b08:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102b0d:	e8 82 d5 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102b12:	68 4c 7b 10 f0       	push   $0xf0107b4c
f0102b17:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102b1c:	68 d1 03 00 00       	push   $0x3d1
f0102b21:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102b26:	e8 69 d5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102b2b:	68 70 7b 10 f0       	push   $0xf0107b70
f0102b30:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102b35:	68 d5 03 00 00       	push   $0x3d5
f0102b3a:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102b3f:	e8 50 d5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102b44:	68 1c 7b 10 f0       	push   $0xf0107b1c
f0102b49:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102b4e:	68 d6 03 00 00       	push   $0x3d6
f0102b53:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102b58:	e8 37 d5 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102b5d:	68 c4 81 10 f0       	push   $0xf01081c4
f0102b62:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102b67:	68 d7 03 00 00       	push   $0x3d7
f0102b6c:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102b71:	e8 1e d5 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102b76:	68 1e 82 10 f0       	push   $0xf010821e
f0102b7b:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102b80:	68 d8 03 00 00       	push   $0x3d8
f0102b85:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102b8a:	e8 05 d5 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102b8f:	68 94 7b 10 f0       	push   $0xf0107b94
f0102b94:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102b99:	68 db 03 00 00       	push   $0x3db
f0102b9e:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102ba3:	e8 ec d4 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f0102ba8:	68 2f 82 10 f0       	push   $0xf010822f
f0102bad:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102bb2:	68 dc 03 00 00       	push   $0x3dc
f0102bb7:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102bbc:	e8 d3 d4 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f0102bc1:	68 3b 82 10 f0       	push   $0xf010823b
f0102bc6:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102bcb:	68 dd 03 00 00       	push   $0x3dd
f0102bd0:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102bd5:	e8 ba d4 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102bda:	68 70 7b 10 f0       	push   $0xf0107b70
f0102bdf:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102be4:	68 e1 03 00 00       	push   $0x3e1
f0102be9:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102bee:	e8 a1 d4 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102bf3:	68 cc 7b 10 f0       	push   $0xf0107bcc
f0102bf8:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102bfd:	68 e2 03 00 00       	push   $0x3e2
f0102c02:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102c07:	e8 88 d4 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102c0c:	68 50 82 10 f0       	push   $0xf0108250
f0102c11:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102c16:	68 e3 03 00 00       	push   $0x3e3
f0102c1b:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102c20:	e8 6f d4 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102c25:	68 1e 82 10 f0       	push   $0xf010821e
f0102c2a:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102c2f:	68 e4 03 00 00       	push   $0x3e4
f0102c34:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102c39:	e8 56 d4 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102c3e:	68 f4 7b 10 f0       	push   $0xf0107bf4
f0102c43:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102c48:	68 e7 03 00 00       	push   $0x3e7
f0102c4d:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102c52:	e8 3d d4 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0102c57:	68 72 81 10 f0       	push   $0xf0108172
f0102c5c:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102c61:	68 ea 03 00 00       	push   $0x3ea
f0102c66:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102c6b:	e8 24 d4 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c70:	68 98 78 10 f0       	push   $0xf0107898
f0102c75:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102c7a:	68 ed 03 00 00       	push   $0x3ed
f0102c7f:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102c84:	e8 0b d4 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0102c89:	68 d5 81 10 f0       	push   $0xf01081d5
f0102c8e:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102c93:	68 ef 03 00 00       	push   $0x3ef
f0102c98:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102c9d:	e8 f2 d3 ff ff       	call   f0100094 <_panic>
f0102ca2:	52                   	push   %edx
f0102ca3:	68 c8 6e 10 f0       	push   $0xf0106ec8
f0102ca8:	68 f6 03 00 00       	push   $0x3f6
f0102cad:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102cb2:	e8 dd d3 ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102cb7:	68 61 82 10 f0       	push   $0xf0108261
f0102cbc:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102cc1:	68 f7 03 00 00       	push   $0x3f7
f0102cc6:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102ccb:	e8 c4 d3 ff ff       	call   f0100094 <_panic>
f0102cd0:	50                   	push   %eax
f0102cd1:	68 c8 6e 10 f0       	push   $0xf0106ec8
f0102cd6:	6a 58                	push   $0x58
f0102cd8:	68 a9 7f 10 f0       	push   $0xf0107fa9
f0102cdd:	e8 b2 d3 ff ff       	call   f0100094 <_panic>
f0102ce2:	52                   	push   %edx
f0102ce3:	68 c8 6e 10 f0       	push   $0xf0106ec8
f0102ce8:	6a 58                	push   $0x58
f0102cea:	68 a9 7f 10 f0       	push   $0xf0107fa9
f0102cef:	e8 a0 d3 ff ff       	call   f0100094 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102cf4:	68 79 82 10 f0       	push   $0xf0108279
f0102cf9:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102cfe:	68 01 04 00 00       	push   $0x401
f0102d03:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102d08:	e8 87 d3 ff ff       	call   f0100094 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102d0d:	68 18 7c 10 f0       	push   $0xf0107c18
f0102d12:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102d17:	68 11 04 00 00       	push   $0x411
f0102d1c:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102d21:	e8 6e d3 ff ff       	call   f0100094 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102d26:	68 40 7c 10 f0       	push   $0xf0107c40
f0102d2b:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102d30:	68 12 04 00 00       	push   $0x412
f0102d35:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102d3a:	e8 55 d3 ff ff       	call   f0100094 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102d3f:	68 68 7c 10 f0       	push   $0xf0107c68
f0102d44:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102d49:	68 14 04 00 00       	push   $0x414
f0102d4e:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102d53:	e8 3c d3 ff ff       	call   f0100094 <_panic>
	assert(mm1 + 8096 <= mm2);
f0102d58:	68 90 82 10 f0       	push   $0xf0108290
f0102d5d:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102d62:	68 16 04 00 00       	push   $0x416
f0102d67:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102d6c:	e8 23 d3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102d71:	68 90 7c 10 f0       	push   $0xf0107c90
f0102d76:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102d7b:	68 18 04 00 00       	push   $0x418
f0102d80:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102d85:	e8 0a d3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102d8a:	68 b4 7c 10 f0       	push   $0xf0107cb4
f0102d8f:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102d94:	68 19 04 00 00       	push   $0x419
f0102d99:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102d9e:	e8 f1 d2 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102da3:	68 e4 7c 10 f0       	push   $0xf0107ce4
f0102da8:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102dad:	68 1a 04 00 00       	push   $0x41a
f0102db2:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102db7:	e8 d8 d2 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102dbc:	68 08 7d 10 f0       	push   $0xf0107d08
f0102dc1:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102dc6:	68 1b 04 00 00       	push   $0x41b
f0102dcb:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102dd0:	e8 bf d2 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102dd5:	68 34 7d 10 f0       	push   $0xf0107d34
f0102dda:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102ddf:	68 1d 04 00 00       	push   $0x41d
f0102de4:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102de9:	e8 a6 d2 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102dee:	68 78 7d 10 f0       	push   $0xf0107d78
f0102df3:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102df8:	68 1e 04 00 00       	push   $0x41e
f0102dfd:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102e02:	e8 8d d2 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e07:	50                   	push   %eax
f0102e08:	68 ec 6e 10 f0       	push   $0xf0106eec
f0102e0d:	68 bd 00 00 00       	push   $0xbd
f0102e12:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102e17:	e8 78 d2 ff ff       	call   f0100094 <_panic>
f0102e1c:	50                   	push   %eax
f0102e1d:	68 ec 6e 10 f0       	push   $0xf0106eec
f0102e22:	68 c7 00 00 00       	push   $0xc7
f0102e27:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102e2c:	e8 63 d2 ff ff       	call   f0100094 <_panic>
f0102e31:	50                   	push   %eax
f0102e32:	68 ec 6e 10 f0       	push   $0xf0106eec
f0102e37:	68 d4 00 00 00       	push   $0xd4
f0102e3c:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102e41:	e8 4e d2 ff ff       	call   f0100094 <_panic>
f0102e46:	57                   	push   %edi
f0102e47:	68 ec 6e 10 f0       	push   $0xf0106eec
f0102e4c:	68 14 01 00 00       	push   $0x114
f0102e51:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102e56:	e8 39 d2 ff ff       	call   f0100094 <_panic>
f0102e5b:	ff 75 c0             	pushl  -0x40(%ebp)
f0102e5e:	68 ec 6e 10 f0       	push   $0xf0106eec
f0102e63:	68 36 03 00 00       	push   $0x336
f0102e68:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102e6d:	e8 22 d2 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e72:	68 ac 7d 10 f0       	push   $0xf0107dac
f0102e77:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102e7c:	68 36 03 00 00       	push   $0x336
f0102e81:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102e86:	e8 09 d2 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102e8b:	a1 48 52 2a f0       	mov    0xf02a5248,%eax
f0102e90:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((uint32_t)kva < KERNBASE)
f0102e93:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102e96:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102e9b:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f0102ea1:	89 da                	mov    %ebx,%edx
f0102ea3:	89 f8                	mov    %edi,%eax
f0102ea5:	e8 6d e1 ff ff       	call   f0101017 <check_va2pa>
f0102eaa:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102eb1:	76 22                	jbe    f0102ed5 <mem_init+0x1689>
f0102eb3:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102eb6:	39 d0                	cmp    %edx,%eax
f0102eb8:	75 32                	jne    f0102eec <mem_init+0x16a0>
f0102eba:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f0102ec0:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102ec6:	75 d9                	jne    f0102ea1 <mem_init+0x1655>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102ec8:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102ecb:	c1 e6 0c             	shl    $0xc,%esi
f0102ece:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102ed3:	eb 4b                	jmp    f0102f20 <mem_init+0x16d4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ed5:	ff 75 d0             	pushl  -0x30(%ebp)
f0102ed8:	68 ec 6e 10 f0       	push   $0xf0106eec
f0102edd:	68 3b 03 00 00       	push   $0x33b
f0102ee2:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102ee7:	e8 a8 d1 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102eec:	68 e0 7d 10 f0       	push   $0xf0107de0
f0102ef1:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0102ef6:	68 3b 03 00 00       	push   $0x33b
f0102efb:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0102f00:	e8 8f d1 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102f05:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102f0b:	89 f8                	mov    %edi,%eax
f0102f0d:	e8 05 e1 ff ff       	call   f0101017 <check_va2pa>
f0102f12:	39 c3                	cmp    %eax,%ebx
f0102f14:	0f 85 f5 00 00 00    	jne    f010300f <mem_init+0x17c3>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102f1a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f20:	39 f3                	cmp    %esi,%ebx
f0102f22:	72 e1                	jb     f0102f05 <mem_init+0x16b9>
f0102f24:	c7 45 d4 00 70 2a f0 	movl   $0xf02a7000,-0x2c(%ebp)
f0102f2b:	c7 45 cc 00 80 ff ef 	movl   $0xefff8000,-0x34(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102f32:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f35:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0102f38:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0102f3b:	8d 83 00 80 00 00    	lea    0x8000(%ebx),%eax
f0102f41:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102f44:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102f47:	8d b0 00 80 00 20    	lea    0x20008000(%eax),%esi
f0102f4d:	89 da                	mov    %ebx,%edx
f0102f4f:	89 f8                	mov    %edi,%eax
f0102f51:	e8 c1 e0 ff ff       	call   f0101017 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102f56:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102f5d:	0f 86 c5 00 00 00    	jbe    f0103028 <mem_init+0x17dc>
f0102f63:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102f66:	39 d0                	cmp    %edx,%eax
f0102f68:	0f 85 d1 00 00 00    	jne    f010303f <mem_init+0x17f3>
f0102f6e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102f74:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102f77:	75 d4                	jne    f0102f4d <mem_init+0x1701>
f0102f79:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102f7c:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102f82:	89 da                	mov    %ebx,%edx
f0102f84:	89 f8                	mov    %edi,%eax
f0102f86:	e8 8c e0 ff ff       	call   f0101017 <check_va2pa>
f0102f8b:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102f8e:	0f 85 c4 00 00 00    	jne    f0103058 <mem_init+0x180c>
f0102f94:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102f9a:	39 f3                	cmp    %esi,%ebx
f0102f9c:	75 e4                	jne    f0102f82 <mem_init+0x1736>
f0102f9e:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102fa5:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102fac:	81 45 d4 00 80 00 00 	addl   $0x8000,-0x2c(%ebp)
f0102fb3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	for (n = 0; n < NCPU; n++) {
f0102fb6:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
f0102fb9:	0f 85 73 ff ff ff    	jne    f0102f32 <mem_init+0x16e6>
	for (i = 0; i < NPDENTRIES; i++) {
f0102fbf:	b8 00 00 00 00       	mov    $0x0,%eax
			if (i >= PDX(KERNBASE)) {
f0102fc4:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102fc9:	0f 87 a2 00 00 00    	ja     f0103071 <mem_init+0x1825>
				assert(pgdir[i] == 0);
f0102fcf:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102fd3:	0f 85 db 00 00 00    	jne    f01030b4 <mem_init+0x1868>
	for (i = 0; i < NPDENTRIES; i++) {
f0102fd9:	40                   	inc    %eax
f0102fda:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102fdf:	0f 87 e8 00 00 00    	ja     f01030cd <mem_init+0x1881>
		switch (i) {
f0102fe5:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102feb:	83 fa 04             	cmp    $0x4,%edx
f0102fee:	77 d4                	ja     f0102fc4 <mem_init+0x1778>
			assert(pgdir[i] & PTE_P);
f0102ff0:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102ff4:	75 e3                	jne    f0102fd9 <mem_init+0x178d>
f0102ff6:	68 bb 82 10 f0       	push   $0xf01082bb
f0102ffb:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0103000:	68 54 03 00 00       	push   $0x354
f0103005:	68 9d 7f 10 f0       	push   $0xf0107f9d
f010300a:	e8 85 d0 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010300f:	68 14 7e 10 f0       	push   $0xf0107e14
f0103014:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0103019:	68 3f 03 00 00       	push   $0x33f
f010301e:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0103023:	e8 6c d0 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103028:	ff 75 c0             	pushl  -0x40(%ebp)
f010302b:	68 ec 6e 10 f0       	push   $0xf0106eec
f0103030:	68 47 03 00 00       	push   $0x347
f0103035:	68 9d 7f 10 f0       	push   $0xf0107f9d
f010303a:	e8 55 d0 ff ff       	call   f0100094 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010303f:	68 3c 7e 10 f0       	push   $0xf0107e3c
f0103044:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0103049:	68 47 03 00 00       	push   $0x347
f010304e:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0103053:	e8 3c d0 ff ff       	call   f0100094 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0103058:	68 84 7e 10 f0       	push   $0xf0107e84
f010305d:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0103062:	68 49 03 00 00       	push   $0x349
f0103067:	68 9d 7f 10 f0       	push   $0xf0107f9d
f010306c:	e8 23 d0 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_P);
f0103071:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103074:	f6 c2 01             	test   $0x1,%dl
f0103077:	74 22                	je     f010309b <mem_init+0x184f>
				assert(pgdir[i] & PTE_W);
f0103079:	f6 c2 02             	test   $0x2,%dl
f010307c:	0f 85 57 ff ff ff    	jne    f0102fd9 <mem_init+0x178d>
f0103082:	68 cc 82 10 f0       	push   $0xf01082cc
f0103087:	68 c3 7f 10 f0       	push   $0xf0107fc3
f010308c:	68 59 03 00 00       	push   $0x359
f0103091:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0103096:	e8 f9 cf ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_P);
f010309b:	68 bb 82 10 f0       	push   $0xf01082bb
f01030a0:	68 c3 7f 10 f0       	push   $0xf0107fc3
f01030a5:	68 58 03 00 00       	push   $0x358
f01030aa:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01030af:	e8 e0 cf ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] == 0);
f01030b4:	68 dd 82 10 f0       	push   $0xf01082dd
f01030b9:	68 c3 7f 10 f0       	push   $0xf0107fc3
f01030be:	68 5b 03 00 00       	push   $0x35b
f01030c3:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01030c8:	e8 c7 cf ff ff       	call   f0100094 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f01030cd:	83 ec 0c             	sub    $0xc,%esp
f01030d0:	68 a8 7e 10 f0       	push   $0xf0107ea8
f01030d5:	e8 e0 0e 00 00       	call   f0103fba <cprintf>
	lcr3(PADDR(kern_pgdir));
f01030da:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01030df:	83 c4 10             	add    $0x10,%esp
f01030e2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030e7:	0f 86 fe 01 00 00    	jbe    f01032eb <mem_init+0x1a9f>
	return (physaddr_t)kva - KERNBASE;
f01030ed:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01030f2:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f01030f5:	b8 00 00 00 00       	mov    $0x0,%eax
f01030fa:	e8 77 df ff ff       	call   f0101076 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01030ff:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0103102:	83 e0 f3             	and    $0xfffffff3,%eax
f0103105:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f010310a:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010310d:	83 ec 0c             	sub    $0xc,%esp
f0103110:	6a 00                	push   $0x0
f0103112:	e8 14 e3 ff ff       	call   f010142b <page_alloc>
f0103117:	89 c3                	mov    %eax,%ebx
f0103119:	83 c4 10             	add    $0x10,%esp
f010311c:	85 c0                	test   %eax,%eax
f010311e:	0f 84 dc 01 00 00    	je     f0103300 <mem_init+0x1ab4>
	assert((pp1 = page_alloc(0)));
f0103124:	83 ec 0c             	sub    $0xc,%esp
f0103127:	6a 00                	push   $0x0
f0103129:	e8 fd e2 ff ff       	call   f010142b <page_alloc>
f010312e:	89 c7                	mov    %eax,%edi
f0103130:	83 c4 10             	add    $0x10,%esp
f0103133:	85 c0                	test   %eax,%eax
f0103135:	0f 84 de 01 00 00    	je     f0103319 <mem_init+0x1acd>
	assert((pp2 = page_alloc(0)));
f010313b:	83 ec 0c             	sub    $0xc,%esp
f010313e:	6a 00                	push   $0x0
f0103140:	e8 e6 e2 ff ff       	call   f010142b <page_alloc>
f0103145:	89 c6                	mov    %eax,%esi
f0103147:	83 c4 10             	add    $0x10,%esp
f010314a:	85 c0                	test   %eax,%eax
f010314c:	0f 84 e0 01 00 00    	je     f0103332 <mem_init+0x1ae6>
	page_free(pp0);
f0103152:	83 ec 0c             	sub    $0xc,%esp
f0103155:	53                   	push   %ebx
f0103156:	e8 42 e3 ff ff       	call   f010149d <page_free>
	return (pp - pages) << PGSHIFT;
f010315b:	89 f8                	mov    %edi,%eax
f010315d:	2b 05 90 5e 2a f0    	sub    0xf02a5e90,%eax
f0103163:	c1 f8 03             	sar    $0x3,%eax
f0103166:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0103169:	89 c2                	mov    %eax,%edx
f010316b:	c1 ea 0c             	shr    $0xc,%edx
f010316e:	83 c4 10             	add    $0x10,%esp
f0103171:	3b 15 88 5e 2a f0    	cmp    0xf02a5e88,%edx
f0103177:	0f 83 ce 01 00 00    	jae    f010334b <mem_init+0x1aff>
	memset(page2kva(pp1), 1, PGSIZE);
f010317d:	83 ec 04             	sub    $0x4,%esp
f0103180:	68 00 10 00 00       	push   $0x1000
f0103185:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0103187:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010318c:	50                   	push   %eax
f010318d:	e8 a6 2e 00 00       	call   f0106038 <memset>
	return (pp - pages) << PGSHIFT;
f0103192:	89 f0                	mov    %esi,%eax
f0103194:	2b 05 90 5e 2a f0    	sub    0xf02a5e90,%eax
f010319a:	c1 f8 03             	sar    $0x3,%eax
f010319d:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01031a0:	89 c2                	mov    %eax,%edx
f01031a2:	c1 ea 0c             	shr    $0xc,%edx
f01031a5:	83 c4 10             	add    $0x10,%esp
f01031a8:	3b 15 88 5e 2a f0    	cmp    0xf02a5e88,%edx
f01031ae:	0f 83 a9 01 00 00    	jae    f010335d <mem_init+0x1b11>
	memset(page2kva(pp2), 2, PGSIZE);
f01031b4:	83 ec 04             	sub    $0x4,%esp
f01031b7:	68 00 10 00 00       	push   $0x1000
f01031bc:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f01031be:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01031c3:	50                   	push   %eax
f01031c4:	e8 6f 2e 00 00       	call   f0106038 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01031c9:	6a 02                	push   $0x2
f01031cb:	68 00 10 00 00       	push   $0x1000
f01031d0:	57                   	push   %edi
f01031d1:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f01031d7:	e8 a8 e5 ff ff       	call   f0101784 <page_insert>
	assert(pp1->pp_ref == 1);
f01031dc:	83 c4 20             	add    $0x20,%esp
f01031df:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01031e4:	0f 85 85 01 00 00    	jne    f010336f <mem_init+0x1b23>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01031ea:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01031f1:	01 01 01 
f01031f4:	0f 85 8e 01 00 00    	jne    f0103388 <mem_init+0x1b3c>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01031fa:	6a 02                	push   $0x2
f01031fc:	68 00 10 00 00       	push   $0x1000
f0103201:	56                   	push   %esi
f0103202:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f0103208:	e8 77 e5 ff ff       	call   f0101784 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010320d:	83 c4 10             	add    $0x10,%esp
f0103210:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103217:	02 02 02 
f010321a:	0f 85 81 01 00 00    	jne    f01033a1 <mem_init+0x1b55>
	assert(pp2->pp_ref == 1);
f0103220:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103225:	0f 85 8f 01 00 00    	jne    f01033ba <mem_init+0x1b6e>
	assert(pp1->pp_ref == 0);
f010322b:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103230:	0f 85 9d 01 00 00    	jne    f01033d3 <mem_init+0x1b87>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103236:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010323d:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0103240:	89 f0                	mov    %esi,%eax
f0103242:	2b 05 90 5e 2a f0    	sub    0xf02a5e90,%eax
f0103248:	c1 f8 03             	sar    $0x3,%eax
f010324b:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010324e:	89 c2                	mov    %eax,%edx
f0103250:	c1 ea 0c             	shr    $0xc,%edx
f0103253:	3b 15 88 5e 2a f0    	cmp    0xf02a5e88,%edx
f0103259:	0f 83 8d 01 00 00    	jae    f01033ec <mem_init+0x1ba0>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010325f:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103266:	03 03 03 
f0103269:	0f 85 8f 01 00 00    	jne    f01033fe <mem_init+0x1bb2>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010326f:	83 ec 08             	sub    $0x8,%esp
f0103272:	68 00 10 00 00       	push   $0x1000
f0103277:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f010327d:	e8 a8 e4 ff ff       	call   f010172a <page_remove>
	assert(pp2->pp_ref == 0);
f0103282:	83 c4 10             	add    $0x10,%esp
f0103285:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010328a:	0f 85 87 01 00 00    	jne    f0103417 <mem_init+0x1bcb>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103290:	8b 0d 8c 5e 2a f0    	mov    0xf02a5e8c,%ecx
f0103296:	8b 11                	mov    (%ecx),%edx
f0103298:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f010329e:	89 d8                	mov    %ebx,%eax
f01032a0:	2b 05 90 5e 2a f0    	sub    0xf02a5e90,%eax
f01032a6:	c1 f8 03             	sar    $0x3,%eax
f01032a9:	c1 e0 0c             	shl    $0xc,%eax
f01032ac:	39 c2                	cmp    %eax,%edx
f01032ae:	0f 85 7c 01 00 00    	jne    f0103430 <mem_init+0x1be4>
	kern_pgdir[0] = 0;
f01032b4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01032ba:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01032bf:	0f 85 84 01 00 00    	jne    f0103449 <mem_init+0x1bfd>
	pp0->pp_ref = 0;
f01032c5:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f01032cb:	83 ec 0c             	sub    $0xc,%esp
f01032ce:	53                   	push   %ebx
f01032cf:	e8 c9 e1 ff ff       	call   f010149d <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01032d4:	c7 04 24 3c 7f 10 f0 	movl   $0xf0107f3c,(%esp)
f01032db:	e8 da 0c 00 00       	call   f0103fba <cprintf>
}
f01032e0:	83 c4 10             	add    $0x10,%esp
f01032e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01032e6:	5b                   	pop    %ebx
f01032e7:	5e                   	pop    %esi
f01032e8:	5f                   	pop    %edi
f01032e9:	5d                   	pop    %ebp
f01032ea:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032eb:	50                   	push   %eax
f01032ec:	68 ec 6e 10 f0       	push   $0xf0106eec
f01032f1:	68 ed 00 00 00       	push   $0xed
f01032f6:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01032fb:	e8 94 cd ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0103300:	68 c7 80 10 f0       	push   $0xf01080c7
f0103305:	68 c3 7f 10 f0       	push   $0xf0107fc3
f010330a:	68 33 04 00 00       	push   $0x433
f010330f:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0103314:	e8 7b cd ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0103319:	68 dd 80 10 f0       	push   $0xf01080dd
f010331e:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0103323:	68 34 04 00 00       	push   $0x434
f0103328:	68 9d 7f 10 f0       	push   $0xf0107f9d
f010332d:	e8 62 cd ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0103332:	68 f3 80 10 f0       	push   $0xf01080f3
f0103337:	68 c3 7f 10 f0       	push   $0xf0107fc3
f010333c:	68 35 04 00 00       	push   $0x435
f0103341:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0103346:	e8 49 cd ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010334b:	50                   	push   %eax
f010334c:	68 c8 6e 10 f0       	push   $0xf0106ec8
f0103351:	6a 58                	push   $0x58
f0103353:	68 a9 7f 10 f0       	push   $0xf0107fa9
f0103358:	e8 37 cd ff ff       	call   f0100094 <_panic>
f010335d:	50                   	push   %eax
f010335e:	68 c8 6e 10 f0       	push   $0xf0106ec8
f0103363:	6a 58                	push   $0x58
f0103365:	68 a9 7f 10 f0       	push   $0xf0107fa9
f010336a:	e8 25 cd ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f010336f:	68 c4 81 10 f0       	push   $0xf01081c4
f0103374:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0103379:	68 3a 04 00 00       	push   $0x43a
f010337e:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0103383:	e8 0c cd ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103388:	68 c8 7e 10 f0       	push   $0xf0107ec8
f010338d:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0103392:	68 3b 04 00 00       	push   $0x43b
f0103397:	68 9d 7f 10 f0       	push   $0xf0107f9d
f010339c:	e8 f3 cc ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01033a1:	68 ec 7e 10 f0       	push   $0xf0107eec
f01033a6:	68 c3 7f 10 f0       	push   $0xf0107fc3
f01033ab:	68 3d 04 00 00       	push   $0x43d
f01033b0:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01033b5:	e8 da cc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f01033ba:	68 e6 81 10 f0       	push   $0xf01081e6
f01033bf:	68 c3 7f 10 f0       	push   $0xf0107fc3
f01033c4:	68 3e 04 00 00       	push   $0x43e
f01033c9:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01033ce:	e8 c1 cc ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f01033d3:	68 50 82 10 f0       	push   $0xf0108250
f01033d8:	68 c3 7f 10 f0       	push   $0xf0107fc3
f01033dd:	68 3f 04 00 00       	push   $0x43f
f01033e2:	68 9d 7f 10 f0       	push   $0xf0107f9d
f01033e7:	e8 a8 cc ff ff       	call   f0100094 <_panic>
f01033ec:	50                   	push   %eax
f01033ed:	68 c8 6e 10 f0       	push   $0xf0106ec8
f01033f2:	6a 58                	push   $0x58
f01033f4:	68 a9 7f 10 f0       	push   $0xf0107fa9
f01033f9:	e8 96 cc ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01033fe:	68 10 7f 10 f0       	push   $0xf0107f10
f0103403:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0103408:	68 41 04 00 00       	push   $0x441
f010340d:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0103412:	e8 7d cc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0103417:	68 1e 82 10 f0       	push   $0xf010821e
f010341c:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0103421:	68 43 04 00 00       	push   $0x443
f0103426:	68 9d 7f 10 f0       	push   $0xf0107f9d
f010342b:	e8 64 cc ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103430:	68 98 78 10 f0       	push   $0xf0107898
f0103435:	68 c3 7f 10 f0       	push   $0xf0107fc3
f010343a:	68 46 04 00 00       	push   $0x446
f010343f:	68 9d 7f 10 f0       	push   $0xf0107f9d
f0103444:	e8 4b cc ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0103449:	68 d5 81 10 f0       	push   $0xf01081d5
f010344e:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0103453:	68 48 04 00 00       	push   $0x448
f0103458:	68 9d 7f 10 f0       	push   $0xf0107f9d
f010345d:	e8 32 cc ff ff       	call   f0100094 <_panic>

f0103462 <user_mem_check>:
{
f0103462:	55                   	push   %ebp
f0103463:	89 e5                	mov    %esp,%ebp
f0103465:	57                   	push   %edi
f0103466:	56                   	push   %esi
f0103467:	53                   	push   %ebx
f0103468:	83 ec 1c             	sub    $0x1c,%esp
f010346b:	8b 7d 08             	mov    0x8(%ebp),%edi
	void *l = ROUNDDOWN((void*)va, PGSIZE), *r = ROUNDUP((void*)va + len, PGSIZE);
f010346e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103471:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103474:	89 c3                	mov    %eax,%ebx
f0103476:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010347c:	89 c6                	mov    %eax,%esi
f010347e:	03 75 10             	add    0x10(%ebp),%esi
f0103481:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
f0103487:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for (; l < r; l += PGSIZE) {
f010348d:	39 f3                	cmp    %esi,%ebx
f010348f:	0f 83 83 00 00 00    	jae    f0103518 <user_mem_check+0xb6>
		if ((uintptr_t)l >= ULIM) {// Higher than ULIM
f0103495:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103498:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010349e:	77 2d                	ja     f01034cd <user_mem_check+0x6b>
		pte_t* pte = pgdir_walk(env->env_pgdir, l, 0);
f01034a0:	83 ec 04             	sub    $0x4,%esp
f01034a3:	6a 00                	push   $0x0
f01034a5:	53                   	push   %ebx
f01034a6:	ff 77 60             	pushl  0x60(%edi)
f01034a9:	e8 67 e0 ff ff       	call   f0101515 <pgdir_walk>
		if (!pte) {
f01034ae:	83 c4 10             	add    $0x10,%esp
f01034b1:	85 c0                	test   %eax,%eax
f01034b3:	74 2f                	je     f01034e4 <user_mem_check+0x82>
		uint32_t given_perm = *pte & 0xFFF;
f01034b5:	8b 00                	mov    (%eax),%eax
f01034b7:	25 ff 0f 00 00       	and    $0xfff,%eax
		if ((given_perm | perm) > given_perm) {
f01034bc:	89 c2                	mov    %eax,%edx
f01034be:	0b 55 14             	or     0x14(%ebp),%edx
f01034c1:	39 c2                	cmp    %eax,%edx
f01034c3:	77 39                	ja     f01034fe <user_mem_check+0x9c>
	for (; l < r; l += PGSIZE) {
f01034c5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01034cb:	eb c0                	jmp    f010348d <user_mem_check+0x2b>
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f01034cd:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f01034d0:	72 03                	jb     f01034d5 <user_mem_check+0x73>
		if ((uintptr_t)l >= ULIM) {// Higher than ULIM
f01034d2:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f01034d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034d8:	a3 3c 52 2a f0       	mov    %eax,0xf02a523c
			return -E_FAULT;
f01034dd:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034e2:	eb 39                	jmp    f010351d <user_mem_check+0xbb>
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f01034e4:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f01034e7:	72 06                	jb     f01034ef <user_mem_check+0x8d>
		if ((uintptr_t)l >= ULIM) {// Higher than ULIM
f01034e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01034ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f01034ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034f2:	a3 3c 52 2a f0       	mov    %eax,0xf02a523c
			return -E_FAULT;
f01034f7:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034fc:	eb 1f                	jmp    f010351d <user_mem_check+0xbb>
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f01034fe:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0103501:	72 06                	jb     f0103509 <user_mem_check+0xa7>
		if ((uintptr_t)l >= ULIM) {// Higher than ULIM
f0103503:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103506:	89 45 e0             	mov    %eax,-0x20(%ebp)
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f0103509:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010350c:	a3 3c 52 2a f0       	mov    %eax,0xf02a523c
			return -E_FAULT;
f0103511:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103516:	eb 05                	jmp    f010351d <user_mem_check+0xbb>
	return 0;
f0103518:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010351d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103520:	5b                   	pop    %ebx
f0103521:	5e                   	pop    %esi
f0103522:	5f                   	pop    %edi
f0103523:	5d                   	pop    %ebp
f0103524:	c3                   	ret    

f0103525 <user_mem_assert>:
{
f0103525:	55                   	push   %ebp
f0103526:	89 e5                	mov    %esp,%ebp
f0103528:	53                   	push   %ebx
f0103529:	83 ec 04             	sub    $0x4,%esp
f010352c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f010352f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103532:	83 c8 04             	or     $0x4,%eax
f0103535:	50                   	push   %eax
f0103536:	ff 75 10             	pushl  0x10(%ebp)
f0103539:	ff 75 0c             	pushl  0xc(%ebp)
f010353c:	53                   	push   %ebx
f010353d:	e8 20 ff ff ff       	call   f0103462 <user_mem_check>
f0103542:	83 c4 10             	add    $0x10,%esp
f0103545:	85 c0                	test   %eax,%eax
f0103547:	78 05                	js     f010354e <user_mem_assert+0x29>
}
f0103549:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010354c:	c9                   	leave  
f010354d:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f010354e:	83 ec 04             	sub    $0x4,%esp
f0103551:	ff 35 3c 52 2a f0    	pushl  0xf02a523c
f0103557:	ff 73 48             	pushl  0x48(%ebx)
f010355a:	68 68 7f 10 f0       	push   $0xf0107f68
f010355f:	e8 56 0a 00 00       	call   f0103fba <cprintf>
		env_destroy(env);	// may not return
f0103564:	89 1c 24             	mov    %ebx,(%esp)
f0103567:	e8 06 07 00 00       	call   f0103c72 <env_destroy>
f010356c:	83 c4 10             	add    $0x10,%esp
}
f010356f:	eb d8                	jmp    f0103549 <user_mem_assert+0x24>

f0103571 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103571:	55                   	push   %ebp
f0103572:	89 e5                	mov    %esp,%ebp
f0103574:	56                   	push   %esi
f0103575:	53                   	push   %ebx
f0103576:	8b 45 08             	mov    0x8(%ebp),%eax
f0103579:	8b 75 10             	mov    0x10(%ebp),%esi
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010357c:	85 c0                	test   %eax,%eax
f010357e:	74 37                	je     f01035b7 <envid2env+0x46>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103580:	89 c1                	mov    %eax,%ecx
f0103582:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f0103588:	89 ca                	mov    %ecx,%edx
f010358a:	c1 e2 05             	shl    $0x5,%edx
f010358d:	29 ca                	sub    %ecx,%edx
f010358f:	8b 0d 48 52 2a f0    	mov    0xf02a5248,%ecx
f0103595:	8d 1c 91             	lea    (%ecx,%edx,4),%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103598:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f010359c:	74 3d                	je     f01035db <envid2env+0x6a>
f010359e:	39 43 48             	cmp    %eax,0x48(%ebx)
f01035a1:	75 38                	jne    f01035db <envid2env+0x6a>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01035a3:	89 f0                	mov    %esi,%eax
f01035a5:	84 c0                	test   %al,%al
f01035a7:	75 42                	jne    f01035eb <envid2env+0x7a>
		*env_store = 0;
		return -E_BAD_ENV;
	}

	*env_store = e;
f01035a9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035ac:	89 18                	mov    %ebx,(%eax)
	return 0;
f01035ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01035b3:	5b                   	pop    %ebx
f01035b4:	5e                   	pop    %esi
f01035b5:	5d                   	pop    %ebp
f01035b6:	c3                   	ret    
		*env_store = curenv;
f01035b7:	e8 86 31 00 00       	call   f0106742 <cpunum>
f01035bc:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01035bf:	01 c2                	add    %eax,%edx
f01035c1:	01 d2                	add    %edx,%edx
f01035c3:	01 c2                	add    %eax,%edx
f01035c5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01035c8:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f01035cf:	8b 75 0c             	mov    0xc(%ebp),%esi
f01035d2:	89 06                	mov    %eax,(%esi)
		return 0;
f01035d4:	b8 00 00 00 00       	mov    $0x0,%eax
f01035d9:	eb d8                	jmp    f01035b3 <envid2env+0x42>
		*env_store = 0;
f01035db:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035de:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01035e4:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01035e9:	eb c8                	jmp    f01035b3 <envid2env+0x42>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01035eb:	e8 52 31 00 00       	call   f0106742 <cpunum>
f01035f0:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01035f3:	01 c2                	add    %eax,%edx
f01035f5:	01 d2                	add    %edx,%edx
f01035f7:	01 c2                	add    %eax,%edx
f01035f9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01035fc:	39 1c 85 28 60 2a f0 	cmp    %ebx,-0xfd59fd8(,%eax,4)
f0103603:	74 a4                	je     f01035a9 <envid2env+0x38>
f0103605:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103608:	e8 35 31 00 00       	call   f0106742 <cpunum>
f010360d:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103610:	01 c2                	add    %eax,%edx
f0103612:	01 d2                	add    %edx,%edx
f0103614:	01 c2                	add    %eax,%edx
f0103616:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103619:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f0103620:	3b 70 48             	cmp    0x48(%eax),%esi
f0103623:	74 84                	je     f01035a9 <envid2env+0x38>
		*env_store = 0;
f0103625:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103628:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010362e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103633:	e9 7b ff ff ff       	jmp    f01035b3 <envid2env+0x42>

f0103638 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103638:	55                   	push   %ebp
f0103639:	89 e5                	mov    %esp,%ebp
	asm volatile("lgdt (%0)" : : "r" (p));
f010363b:	b8 20 33 12 f0       	mov    $0xf0123320,%eax
f0103640:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103643:	b8 23 00 00 00       	mov    $0x23,%eax
f0103648:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f010364a:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f010364c:	b8 10 00 00 00       	mov    $0x10,%eax
f0103651:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103653:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103655:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103657:	ea 5e 36 10 f0 08 00 	ljmp   $0x8,$0xf010365e
	asm volatile("lldt %0" : : "r" (sel));
f010365e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103663:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103666:	5d                   	pop    %ebp
f0103667:	c3                   	ret    

f0103668 <env_init>:
{
f0103668:	55                   	push   %ebp
f0103669:	89 e5                	mov    %esp,%ebp
f010366b:	56                   	push   %esi
f010366c:	53                   	push   %ebx
		envs[i].env_link = env_free_list;
f010366d:	8b 35 48 52 2a f0    	mov    0xf02a5248,%esi
f0103673:	8b 15 4c 52 2a f0    	mov    0xf02a524c,%edx
f0103679:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f010367f:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0103682:	89 c1                	mov    %eax,%ecx
f0103684:	89 50 44             	mov    %edx,0x44(%eax)
f0103687:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[i];
f010368a:	89 ca                	mov    %ecx,%edx
	for (int i = NENV - 1; i >= 0; i--) { // Be sure not to use size_t
f010368c:	39 d8                	cmp    %ebx,%eax
f010368e:	75 f2                	jne    f0103682 <env_init+0x1a>
f0103690:	89 35 4c 52 2a f0    	mov    %esi,0xf02a524c
	env_init_percpu();
f0103696:	e8 9d ff ff ff       	call   f0103638 <env_init_percpu>
}
f010369b:	5b                   	pop    %ebx
f010369c:	5e                   	pop    %esi
f010369d:	5d                   	pop    %ebp
f010369e:	c3                   	ret    

f010369f <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010369f:	55                   	push   %ebp
f01036a0:	89 e5                	mov    %esp,%ebp
f01036a2:	56                   	push   %esi
f01036a3:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;
	if (!(e = env_free_list))
f01036a4:	8b 1d 4c 52 2a f0    	mov    0xf02a524c,%ebx
f01036aa:	85 db                	test   %ebx,%ebx
f01036ac:	0f 84 fa 01 00 00    	je     f01038ac <env_alloc+0x20d>
	if (!(p = page_alloc(ALLOC_ZERO)))
f01036b2:	83 ec 0c             	sub    $0xc,%esp
f01036b5:	6a 01                	push   $0x1
f01036b7:	e8 6f dd ff ff       	call   f010142b <page_alloc>
f01036bc:	89 c6                	mov    %eax,%esi
f01036be:	83 c4 10             	add    $0x10,%esp
f01036c1:	85 c0                	test   %eax,%eax
f01036c3:	0f 84 ea 01 00 00    	je     f01038b3 <env_alloc+0x214>
	return (pp - pages) << PGSHIFT;
f01036c9:	2b 05 90 5e 2a f0    	sub    0xf02a5e90,%eax
f01036cf:	c1 f8 03             	sar    $0x3,%eax
f01036d2:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01036d5:	89 c2                	mov    %eax,%edx
f01036d7:	c1 ea 0c             	shr    $0xc,%edx
f01036da:	3b 15 88 5e 2a f0    	cmp    0xf02a5e88,%edx
f01036e0:	0f 83 7c 01 00 00    	jae    f0103862 <env_alloc+0x1c3>
	memset(page2kva(p), 0, PGSIZE);
f01036e6:	83 ec 04             	sub    $0x4,%esp
f01036e9:	68 00 10 00 00       	push   $0x1000
f01036ee:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01036f0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01036f5:	50                   	push   %eax
f01036f6:	e8 3d 29 00 00       	call   f0106038 <memset>
	p->pp_ref++;
f01036fb:	66 ff 46 04          	incw   0x4(%esi)
	return (pp - pages) << PGSHIFT;
f01036ff:	2b 35 90 5e 2a f0    	sub    0xf02a5e90,%esi
f0103705:	c1 fe 03             	sar    $0x3,%esi
f0103708:	c1 e6 0c             	shl    $0xc,%esi
	if (PGNUM(pa) >= npages)
f010370b:	89 f0                	mov    %esi,%eax
f010370d:	c1 e8 0c             	shr    $0xc,%eax
f0103710:	83 c4 10             	add    $0x10,%esp
f0103713:	3b 05 88 5e 2a f0    	cmp    0xf02a5e88,%eax
f0103719:	0f 83 55 01 00 00    	jae    f0103874 <env_alloc+0x1d5>
	return (void *)(pa + KERNBASE);
f010371f:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f0103725:	89 73 60             	mov    %esi,0x60(%ebx)
	e->env_pgdir = page2kva(p);
f0103728:	b8 ec 0e 00 00       	mov    $0xeec,%eax
		e->env_pgdir[pgt] = kern_pgdir[pgt];
f010372d:	8b 15 8c 5e 2a f0    	mov    0xf02a5e8c,%edx
f0103733:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0103736:	8b 53 60             	mov    0x60(%ebx),%edx
f0103739:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f010373c:	83 c0 04             	add    $0x4,%eax
	for (size_t pgt = PDX(UTOP); pgt < PGSIZE / sizeof(pde_t); pgt++)
f010373f:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103744:	75 e7                	jne    f010372d <env_alloc+0x8e>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103746:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103749:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010374e:	0f 86 32 01 00 00    	jbe    f0103886 <env_alloc+0x1e7>
	return (physaddr_t)kva - KERNBASE;
f0103754:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010375a:	83 ca 05             	or     $0x5,%edx
f010375d:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103763:	8b 43 48             	mov    0x48(%ebx),%eax
f0103766:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010376b:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103770:	89 c2                	mov    %eax,%edx
f0103772:	0f 8e 23 01 00 00    	jle    f010389b <env_alloc+0x1fc>
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f0103778:	89 d8                	mov    %ebx,%eax
f010377a:	2b 05 48 52 2a f0    	sub    0xf02a5248,%eax
f0103780:	c1 f8 02             	sar    $0x2,%eax
f0103783:	89 c1                	mov    %eax,%ecx
f0103785:	c1 e0 05             	shl    $0x5,%eax
f0103788:	01 c8                	add    %ecx,%eax
f010378a:	c1 e0 05             	shl    $0x5,%eax
f010378d:	01 c8                	add    %ecx,%eax
f010378f:	89 c6                	mov    %eax,%esi
f0103791:	c1 e6 0f             	shl    $0xf,%esi
f0103794:	01 f0                	add    %esi,%eax
f0103796:	c1 e0 05             	shl    $0x5,%eax
f0103799:	01 c8                	add    %ecx,%eax
f010379b:	f7 d8                	neg    %eax
f010379d:	09 d0                	or     %edx,%eax
f010379f:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01037a2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01037a5:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01037a8:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01037af:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01037b6:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01037bd:	83 ec 04             	sub    $0x4,%esp
f01037c0:	6a 44                	push   $0x44
f01037c2:	6a 00                	push   $0x0
f01037c4:	53                   	push   %ebx
f01037c5:	e8 6e 28 00 00       	call   f0106038 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01037ca:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01037d0:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01037d6:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01037dc:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01037e3:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	e->env_tf.tf_eflags = FL_IF;  // This is the only flag till now.
f01037e9:	c7 43 38 00 02 00 00 	movl   $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01037f0:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01037f7:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01037fb:	8b 43 44             	mov    0x44(%ebx),%eax
f01037fe:	a3 4c 52 2a f0       	mov    %eax,0xf02a524c
	*newenv_store = e;
f0103803:	8b 45 08             	mov    0x8(%ebp),%eax
f0103806:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103808:	8b 5b 48             	mov    0x48(%ebx),%ebx
f010380b:	e8 32 2f 00 00       	call   f0106742 <cpunum>
f0103810:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103813:	01 c2                	add    %eax,%edx
f0103815:	01 d2                	add    %edx,%edx
f0103817:	01 c2                	add    %eax,%edx
f0103819:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010381c:	83 c4 10             	add    $0x10,%esp
f010381f:	83 3c 85 28 60 2a f0 	cmpl   $0x0,-0xfd59fd8(,%eax,4)
f0103826:	00 
f0103827:	74 7c                	je     f01038a5 <env_alloc+0x206>
f0103829:	e8 14 2f 00 00       	call   f0106742 <cpunum>
f010382e:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103831:	01 c2                	add    %eax,%edx
f0103833:	01 d2                	add    %edx,%edx
f0103835:	01 c2                	add    %eax,%edx
f0103837:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010383a:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f0103841:	8b 40 48             	mov    0x48(%eax),%eax
f0103844:	83 ec 04             	sub    $0x4,%esp
f0103847:	53                   	push   %ebx
f0103848:	50                   	push   %eax
f0103849:	68 1a 83 10 f0       	push   $0xf010831a
f010384e:	e8 67 07 00 00       	call   f0103fba <cprintf>
	return 0;
f0103853:	83 c4 10             	add    $0x10,%esp
f0103856:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010385b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010385e:	5b                   	pop    %ebx
f010385f:	5e                   	pop    %esi
f0103860:	5d                   	pop    %ebp
f0103861:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103862:	50                   	push   %eax
f0103863:	68 c8 6e 10 f0       	push   $0xf0106ec8
f0103868:	6a 58                	push   $0x58
f010386a:	68 a9 7f 10 f0       	push   $0xf0107fa9
f010386f:	e8 20 c8 ff ff       	call   f0100094 <_panic>
f0103874:	56                   	push   %esi
f0103875:	68 c8 6e 10 f0       	push   $0xf0106ec8
f010387a:	6a 58                	push   $0x58
f010387c:	68 a9 7f 10 f0       	push   $0xf0107fa9
f0103881:	e8 0e c8 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103886:	50                   	push   %eax
f0103887:	68 ec 6e 10 f0       	push   $0xf0106eec
f010388c:	68 c7 00 00 00       	push   $0xc7
f0103891:	68 0f 83 10 f0       	push   $0xf010830f
f0103896:	e8 f9 c7 ff ff       	call   f0100094 <_panic>
		generation = 1 << ENVGENSHIFT;
f010389b:	ba 00 10 00 00       	mov    $0x1000,%edx
f01038a0:	e9 d3 fe ff ff       	jmp    f0103778 <env_alloc+0xd9>
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01038a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01038aa:	eb 98                	jmp    f0103844 <env_alloc+0x1a5>
		return -E_NO_FREE_ENV;
f01038ac:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01038b1:	eb a8                	jmp    f010385b <env_alloc+0x1bc>
		return -E_NO_MEM;
f01038b3:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01038b8:	eb a1                	jmp    f010385b <env_alloc+0x1bc>

f01038ba <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01038ba:	55                   	push   %ebp
f01038bb:	89 e5                	mov    %esp,%ebp
f01038bd:	57                   	push   %edi
f01038be:	56                   	push   %esi
f01038bf:	53                   	push   %ebx
f01038c0:	83 ec 34             	sub    $0x34,%esp
	// LAB 3: Your code here.
	struct Env* newenv;
	int r = env_alloc(&newenv, 0);
f01038c3:	6a 00                	push   $0x0
f01038c5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01038c8:	50                   	push   %eax
f01038c9:	e8 d1 fd ff ff       	call   f010369f <env_alloc>
	if (r)
f01038ce:	83 c4 10             	add    $0x10,%esp
f01038d1:	85 c0                	test   %eax,%eax
f01038d3:	75 47                	jne    f010391c <env_create+0x62>
		panic("Environment allocation faulted: %e", r);
	load_icode(newenv, binary);
f01038d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	if (elf->e_magic != ELF_MAGIC)
f01038d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01038db:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f01038e1:	75 4e                	jne    f0103931 <env_create+0x77>
	struct Proghdr *ph = (struct Proghdr *) (binary + elf->e_phoff), 
f01038e3:	8b 45 08             	mov    0x8(%ebp),%eax
f01038e6:	89 c6                	mov    %eax,%esi
f01038e8:	03 70 1c             	add    0x1c(%eax),%esi
				   *eph = ph + elf->e_phnum;
f01038eb:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
f01038ef:	c1 e0 05             	shl    $0x5,%eax
f01038f2:	01 f0                	add    %esi,%eax
f01038f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	pte_t pgdir_pte = *pgdir_walk(kern_pgdir, e->env_pgdir, 0);
f01038f7:	83 ec 04             	sub    $0x4,%esp
f01038fa:	6a 00                	push   $0x0
f01038fc:	ff 77 60             	pushl  0x60(%edi)
f01038ff:	ff 35 8c 5e 2a f0    	pushl  0xf02a5e8c
f0103905:	e8 0b dc ff ff       	call   f0101515 <pgdir_walk>
	physaddr_t pgdir_phy = PTE_ADDR(pgdir_pte);
f010390a:	8b 00                	mov    (%eax),%eax
f010390c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103911:	0f 22 d8             	mov    %eax,%cr3
f0103914:	83 c4 10             	add    $0x10,%esp
f0103917:	e9 8f 00 00 00       	jmp    f01039ab <env_create+0xf1>
		panic("Environment allocation faulted: %e", r);
f010391c:	50                   	push   %eax
f010391d:	68 ec 82 10 f0       	push   $0xf01082ec
f0103922:	68 a0 01 00 00       	push   $0x1a0
f0103927:	68 0f 83 10 f0       	push   $0xf010830f
f010392c:	e8 63 c7 ff ff       	call   f0100094 <_panic>
		panic("Not a valid elf binary!");
f0103931:	83 ec 04             	sub    $0x4,%esp
f0103934:	68 2f 83 10 f0       	push   $0xf010832f
f0103939:	68 64 01 00 00       	push   $0x164
f010393e:	68 0f 83 10 f0       	push   $0xf010830f
f0103943:	e8 4c c7 ff ff       	call   f0100094 <_panic>
			panic("No free page for allocation.");
f0103948:	83 ec 04             	sub    $0x4,%esp
f010394b:	68 47 83 10 f0       	push   $0xf0108347
f0103950:	68 22 01 00 00       	push   $0x122
f0103955:	68 0f 83 10 f0       	push   $0xf010830f
f010395a:	e8 35 c7 ff ff       	call   f0100094 <_panic>
			panic("Page insertion result: %e", r);
f010395f:	ff 75 cc             	pushl  -0x34(%ebp)
f0103962:	68 64 83 10 f0       	push   $0xf0108364
f0103967:	68 25 01 00 00       	push   $0x125
f010396c:	68 0f 83 10 f0       	push   $0xf010830f
f0103971:	e8 1e c7 ff ff       	call   f0100094 <_panic>
f0103976:	8b 75 d0             	mov    -0x30(%ebp),%esi
			memmove((void*)ph0->p_va, binary + ph0->p_offset, ph0->p_filesz);
f0103979:	83 ec 04             	sub    $0x4,%esp
f010397c:	ff 76 10             	pushl  0x10(%esi)
f010397f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103982:	03 46 04             	add    0x4(%esi),%eax
f0103985:	50                   	push   %eax
f0103986:	ff 76 08             	pushl  0x8(%esi)
f0103989:	e8 f7 26 00 00       	call   f0106085 <memmove>
					ph0->p_memsz - ph0->p_filesz);
f010398e:	8b 46 10             	mov    0x10(%esi),%eax
			memset((void*)ph0->p_va + ph0->p_filesz, 0, 
f0103991:	83 c4 0c             	add    $0xc,%esp
f0103994:	8b 56 14             	mov    0x14(%esi),%edx
f0103997:	29 c2                	sub    %eax,%edx
f0103999:	52                   	push   %edx
f010399a:	6a 00                	push   $0x0
f010399c:	03 46 08             	add    0x8(%esi),%eax
f010399f:	50                   	push   %eax
f01039a0:	e8 93 26 00 00       	call   f0106038 <memset>
f01039a5:	83 c4 10             	add    $0x10,%esp
	for (struct Proghdr* ph0 = ph; ph0 < eph; ph0++) {
f01039a8:	83 c6 20             	add    $0x20,%esi
f01039ab:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f01039ae:	76 5d                	jbe    f0103a0d <env_create+0x153>
		if (ph0->p_type == ELF_PROG_LOAD) {
f01039b0:	83 3e 01             	cmpl   $0x1,(%esi)
f01039b3:	75 f3                	jne    f01039a8 <env_create+0xee>
			region_alloc(e, (void*)ph0->p_va, ph0->p_memsz);
f01039b5:	8b 46 08             	mov    0x8(%esi),%eax
	uintptr_t l = ROUNDDOWN((uintptr_t)va, PGSIZE), 
f01039b8:	89 c3                	mov    %eax,%ebx
f01039ba:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
			  r = ROUNDUP((uintptr_t)(va + len), PGSIZE);
f01039c0:	03 46 14             	add    0x14(%esi),%eax
f01039c3:	05 ff 0f 00 00       	add    $0xfff,%eax
f01039c8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01039cd:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01039d0:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01039d3:	89 c6                	mov    %eax,%esi
	for (uintptr_t ptr = l; ptr < r; ptr += PGSIZE) {
f01039d5:	39 de                	cmp    %ebx,%esi
f01039d7:	76 9d                	jbe    f0103976 <env_create+0xbc>
		struct PageInfo *pg = page_alloc(0);
f01039d9:	83 ec 0c             	sub    $0xc,%esp
f01039dc:	6a 00                	push   $0x0
f01039de:	e8 48 da ff ff       	call   f010142b <page_alloc>
		if (!pg)
f01039e3:	83 c4 10             	add    $0x10,%esp
f01039e6:	85 c0                	test   %eax,%eax
f01039e8:	0f 84 5a ff ff ff    	je     f0103948 <env_create+0x8e>
		int res = page_insert(e->env_pgdir, pg, (void*)ptr, PTE_U | PTE_W);
f01039ee:	6a 06                	push   $0x6
f01039f0:	53                   	push   %ebx
f01039f1:	50                   	push   %eax
f01039f2:	ff 77 60             	pushl  0x60(%edi)
f01039f5:	e8 8a dd ff ff       	call   f0101784 <page_insert>
		if (res)
f01039fa:	83 c4 10             	add    $0x10,%esp
f01039fd:	85 c0                	test   %eax,%eax
f01039ff:	0f 85 5a ff ff ff    	jne    f010395f <env_create+0xa5>
	for (uintptr_t ptr = l; ptr < r; ptr += PGSIZE) {
f0103a05:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103a0b:	eb c8                	jmp    f01039d5 <env_create+0x11b>
	e->env_tf.tf_eip = elf->e_entry;
f0103a0d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a10:	8b 40 18             	mov    0x18(%eax),%eax
f0103a13:	89 47 30             	mov    %eax,0x30(%edi)
	lcr3(PADDR(kern_pgdir));
f0103a16:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103a1b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a20:	76 3e                	jbe    f0103a60 <env_create+0x1a6>
	return (physaddr_t)kva - KERNBASE;
f0103a22:	05 00 00 00 10       	add    $0x10000000,%eax
f0103a27:	0f 22 d8             	mov    %eax,%cr3
	struct PageInfo *stack_page = page_alloc(ALLOC_ZERO);
f0103a2a:	83 ec 0c             	sub    $0xc,%esp
f0103a2d:	6a 01                	push   $0x1
f0103a2f:	e8 f7 d9 ff ff       	call   f010142b <page_alloc>
	if (!stack_page)
f0103a34:	83 c4 10             	add    $0x10,%esp
f0103a37:	85 c0                	test   %eax,%eax
f0103a39:	74 3a                	je     f0103a75 <env_create+0x1bb>
	int r = page_insert(e->env_pgdir, stack_page, (void*)USTACKTOP - PGSIZE, PTE_U | PTE_W);
f0103a3b:	6a 06                	push   $0x6
f0103a3d:	68 00 d0 bf ee       	push   $0xeebfd000
f0103a42:	50                   	push   %eax
f0103a43:	ff 77 60             	pushl  0x60(%edi)
f0103a46:	e8 39 dd ff ff       	call   f0101784 <page_insert>
	if (r)
f0103a4b:	83 c4 10             	add    $0x10,%esp
f0103a4e:	85 c0                	test   %eax,%eax
f0103a50:	75 3a                	jne    f0103a8c <env_create+0x1d2>
	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	if (type == ENV_TYPE_FS) {
f0103a52:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
f0103a56:	74 49                	je     f0103aa1 <env_create+0x1e7>
		newenv->env_tf.tf_eflags |= FL_IOPL_3;
	}
}
f0103a58:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103a5b:	5b                   	pop    %ebx
f0103a5c:	5e                   	pop    %esi
f0103a5d:	5f                   	pop    %edi
f0103a5e:	5d                   	pop    %ebp
f0103a5f:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a60:	50                   	push   %eax
f0103a61:	68 ec 6e 10 f0       	push   $0xf0106eec
f0103a66:	68 84 01 00 00       	push   $0x184
f0103a6b:	68 0f 83 10 f0       	push   $0xf010830f
f0103a70:	e8 1f c6 ff ff       	call   f0100094 <_panic>
		panic("No free page for allocation.");
f0103a75:	83 ec 04             	sub    $0x4,%esp
f0103a78:	68 47 83 10 f0       	push   $0xf0108347
f0103a7d:	68 8c 01 00 00       	push   $0x18c
f0103a82:	68 0f 83 10 f0       	push   $0xf010830f
f0103a87:	e8 08 c6 ff ff       	call   f0100094 <_panic>
		panic("Page insertion result: %e", r);
f0103a8c:	50                   	push   %eax
f0103a8d:	68 64 83 10 f0       	push   $0xf0108364
f0103a92:	68 8f 01 00 00       	push   $0x18f
f0103a97:	68 0f 83 10 f0       	push   $0xf010830f
f0103a9c:	e8 f3 c5 ff ff       	call   f0100094 <_panic>
		newenv->env_tf.tf_eflags |= FL_IOPL_3;
f0103aa1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103aa4:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
}
f0103aab:	eb ab                	jmp    f0103a58 <env_create+0x19e>

f0103aad <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103aad:	55                   	push   %ebp
f0103aae:	89 e5                	mov    %esp,%ebp
f0103ab0:	57                   	push   %edi
f0103ab1:	56                   	push   %esi
f0103ab2:	53                   	push   %ebx
f0103ab3:	83 ec 1c             	sub    $0x1c,%esp
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103ab6:	e8 87 2c 00 00       	call   f0106742 <cpunum>
f0103abb:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103abe:	01 c2                	add    %eax,%edx
f0103ac0:	01 d2                	add    %edx,%edx
f0103ac2:	01 c2                	add    %eax,%edx
f0103ac4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ac7:	8b 55 08             	mov    0x8(%ebp),%edx
f0103aca:	39 14 85 28 60 2a f0 	cmp    %edx,-0xfd59fd8(,%eax,4)
f0103ad1:	75 38                	jne    f0103b0b <env_free+0x5e>
		lcr3(PADDR(kern_pgdir));
f0103ad3:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103ad8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103add:	76 17                	jbe    f0103af6 <env_free+0x49>
	return (physaddr_t)kva - KERNBASE;
f0103adf:	05 00 00 00 10       	add    $0x10000000,%eax
f0103ae4:	0f 22 d8             	mov    %eax,%cr3
f0103ae7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0103aee:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103af1:	e9 9b 00 00 00       	jmp    f0103b91 <env_free+0xe4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103af6:	50                   	push   %eax
f0103af7:	68 ec 6e 10 f0       	push   $0xf0106eec
f0103afc:	68 b6 01 00 00       	push   $0x1b6
f0103b01:	68 0f 83 10 f0       	push   $0xf010830f
f0103b06:	e8 89 c5 ff ff       	call   f0100094 <_panic>
f0103b0b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0103b12:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103b15:	eb 7a                	jmp    f0103b91 <env_free+0xe4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103b17:	50                   	push   %eax
f0103b18:	68 c8 6e 10 f0       	push   $0xf0106ec8
f0103b1d:	68 c5 01 00 00       	push   $0x1c5
f0103b22:	68 0f 83 10 f0       	push   $0xf010830f
f0103b27:	e8 68 c5 ff ff       	call   f0100094 <_panic>
f0103b2c:	83 c3 04             	add    $0x4,%ebx
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103b2f:	39 de                	cmp    %ebx,%esi
f0103b31:	74 21                	je     f0103b54 <env_free+0xa7>
			if (pt[pteno] & PTE_P)
f0103b33:	f6 03 01             	testb  $0x1,(%ebx)
f0103b36:	74 f4                	je     f0103b2c <env_free+0x7f>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b38:	83 ec 08             	sub    $0x8,%esp
f0103b3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b3e:	01 d8                	add    %ebx,%eax
f0103b40:	c1 e0 0a             	shl    $0xa,%eax
f0103b43:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103b46:	50                   	push   %eax
f0103b47:	ff 77 60             	pushl  0x60(%edi)
f0103b4a:	e8 db db ff ff       	call   f010172a <page_remove>
f0103b4f:	83 c4 10             	add    $0x10,%esp
f0103b52:	eb d8                	jmp    f0103b2c <env_free+0x7f>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103b54:	8b 47 60             	mov    0x60(%edi),%eax
f0103b57:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b5a:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103b61:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103b64:	3b 05 88 5e 2a f0    	cmp    0xf02a5e88,%eax
f0103b6a:	73 6a                	jae    f0103bd6 <env_free+0x129>
		page_decref(pa2page(pa));
f0103b6c:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103b6f:	a1 90 5e 2a f0       	mov    0xf02a5e90,%eax
f0103b74:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103b77:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103b7a:	50                   	push   %eax
f0103b7b:	e8 6f d9 ff ff       	call   f01014ef <page_decref>
f0103b80:	83 c4 10             	add    $0x10,%esp
f0103b83:	83 45 dc 04          	addl   $0x4,-0x24(%ebp)
f0103b87:	8b 45 dc             	mov    -0x24(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103b8a:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103b8f:	74 59                	je     f0103bea <env_free+0x13d>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103b91:	8b 47 60             	mov    0x60(%edi),%eax
f0103b94:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b97:	8b 04 10             	mov    (%eax,%edx,1),%eax
f0103b9a:	a8 01                	test   $0x1,%al
f0103b9c:	74 e5                	je     f0103b83 <env_free+0xd6>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103b9e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0103ba3:	89 c2                	mov    %eax,%edx
f0103ba5:	c1 ea 0c             	shr    $0xc,%edx
f0103ba8:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0103bab:	39 15 88 5e 2a f0    	cmp    %edx,0xf02a5e88
f0103bb1:	0f 86 60 ff ff ff    	jbe    f0103b17 <env_free+0x6a>
	return (void *)(pa + KERNBASE);
f0103bb7:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103bbd:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103bc0:	c1 e2 14             	shl    $0x14,%edx
f0103bc3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103bc6:	8d b0 00 10 00 f0    	lea    -0xffff000(%eax),%esi
f0103bcc:	f7 d8                	neg    %eax
f0103bce:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103bd1:	e9 5d ff ff ff       	jmp    f0103b33 <env_free+0x86>
		panic("pa2page called with invalid pa");
f0103bd6:	83 ec 04             	sub    $0x4,%esp
f0103bd9:	68 64 77 10 f0       	push   $0xf0107764
f0103bde:	6a 51                	push   $0x51
f0103be0:	68 a9 7f 10 f0       	push   $0xf0107fa9
f0103be5:	e8 aa c4 ff ff       	call   f0100094 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103bea:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bed:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103bf0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103bf5:	76 52                	jbe    f0103c49 <env_free+0x19c>
	e->env_pgdir = 0;
f0103bf7:	8b 55 08             	mov    0x8(%ebp),%edx
f0103bfa:	c7 42 60 00 00 00 00 	movl   $0x0,0x60(%edx)
	return (physaddr_t)kva - KERNBASE;
f0103c01:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103c06:	c1 e8 0c             	shr    $0xc,%eax
f0103c09:	3b 05 88 5e 2a f0    	cmp    0xf02a5e88,%eax
f0103c0f:	73 4d                	jae    f0103c5e <env_free+0x1b1>
	page_decref(pa2page(pa));
f0103c11:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103c14:	8b 15 90 5e 2a f0    	mov    0xf02a5e90,%edx
f0103c1a:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103c1d:	50                   	push   %eax
f0103c1e:	e8 cc d8 ff ff       	call   f01014ef <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103c23:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c26:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f0103c2d:	a1 4c 52 2a f0       	mov    0xf02a524c,%eax
f0103c32:	8b 55 08             	mov    0x8(%ebp),%edx
f0103c35:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f0103c38:	89 15 4c 52 2a f0    	mov    %edx,0xf02a524c
}
f0103c3e:	83 c4 10             	add    $0x10,%esp
f0103c41:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103c44:	5b                   	pop    %ebx
f0103c45:	5e                   	pop    %esi
f0103c46:	5f                   	pop    %edi
f0103c47:	5d                   	pop    %ebp
f0103c48:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103c49:	50                   	push   %eax
f0103c4a:	68 ec 6e 10 f0       	push   $0xf0106eec
f0103c4f:	68 d3 01 00 00       	push   $0x1d3
f0103c54:	68 0f 83 10 f0       	push   $0xf010830f
f0103c59:	e8 36 c4 ff ff       	call   f0100094 <_panic>
		panic("pa2page called with invalid pa");
f0103c5e:	83 ec 04             	sub    $0x4,%esp
f0103c61:	68 64 77 10 f0       	push   $0xf0107764
f0103c66:	6a 51                	push   $0x51
f0103c68:	68 a9 7f 10 f0       	push   $0xf0107fa9
f0103c6d:	e8 22 c4 ff ff       	call   f0100094 <_panic>

f0103c72 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103c72:	55                   	push   %ebp
f0103c73:	89 e5                	mov    %esp,%ebp
f0103c75:	53                   	push   %ebx
f0103c76:	83 ec 04             	sub    $0x4,%esp
f0103c79:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103c7c:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103c80:	74 2b                	je     f0103cad <env_destroy+0x3b>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f0103c82:	83 ec 0c             	sub    $0xc,%esp
f0103c85:	53                   	push   %ebx
f0103c86:	e8 22 fe ff ff       	call   f0103aad <env_free>

	if (curenv == e) {
f0103c8b:	e8 b2 2a 00 00       	call   f0106742 <cpunum>
f0103c90:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103c93:	01 c2                	add    %eax,%edx
f0103c95:	01 d2                	add    %edx,%edx
f0103c97:	01 c2                	add    %eax,%edx
f0103c99:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c9c:	83 c4 10             	add    $0x10,%esp
f0103c9f:	39 1c 85 28 60 2a f0 	cmp    %ebx,-0xfd59fd8(,%eax,4)
f0103ca6:	74 28                	je     f0103cd0 <env_destroy+0x5e>
		curenv = NULL;
		sched_yield();
	}
}
f0103ca8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103cab:	c9                   	leave  
f0103cac:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103cad:	e8 90 2a 00 00       	call   f0106742 <cpunum>
f0103cb2:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103cb5:	01 c2                	add    %eax,%edx
f0103cb7:	01 d2                	add    %edx,%edx
f0103cb9:	01 c2                	add    %eax,%edx
f0103cbb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103cbe:	39 1c 85 28 60 2a f0 	cmp    %ebx,-0xfd59fd8(,%eax,4)
f0103cc5:	74 bb                	je     f0103c82 <env_destroy+0x10>
		e->env_status = ENV_DYING;
f0103cc7:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103cce:	eb d8                	jmp    f0103ca8 <env_destroy+0x36>
		curenv = NULL;
f0103cd0:	e8 6d 2a 00 00       	call   f0106742 <cpunum>
f0103cd5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cd8:	c7 80 28 60 2a f0 00 	movl   $0x0,-0xfd59fd8(%eax)
f0103cdf:	00 00 00 
		sched_yield();
f0103ce2:	e8 4d 11 00 00       	call   f0104e34 <sched_yield>

f0103ce7 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103ce7:	55                   	push   %ebp
f0103ce8:	89 e5                	mov    %esp,%ebp
f0103cea:	53                   	push   %ebx
f0103ceb:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103cee:	e8 4f 2a 00 00       	call   f0106742 <cpunum>
f0103cf3:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103cf6:	01 c2                	add    %eax,%edx
f0103cf8:	01 d2                	add    %edx,%edx
f0103cfa:	01 c2                	add    %eax,%edx
f0103cfc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103cff:	8b 1c 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%ebx
f0103d06:	e8 37 2a 00 00       	call   f0106742 <cpunum>
f0103d0b:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0103d0e:	8b 65 08             	mov    0x8(%ebp),%esp
f0103d11:	61                   	popa   
f0103d12:	07                   	pop    %es
f0103d13:	1f                   	pop    %ds
f0103d14:	83 c4 08             	add    $0x8,%esp
f0103d17:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103d18:	83 ec 04             	sub    $0x4,%esp
f0103d1b:	68 7e 83 10 f0       	push   $0xf010837e
f0103d20:	68 0a 02 00 00       	push   $0x20a
f0103d25:	68 0f 83 10 f0       	push   $0xf010830f
f0103d2a:	e8 65 c3 ff ff       	call   f0100094 <_panic>

f0103d2f <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103d2f:	55                   	push   %ebp
f0103d30:	89 e5                	mov    %esp,%ebp
f0103d32:	83 ec 08             	sub    $0x8,%esp
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// Unset curenv running before going to new env.
	if (curenv && curenv->env_status == ENV_RUNNING) {
f0103d35:	e8 08 2a 00 00       	call   f0106742 <cpunum>
f0103d3a:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103d3d:	01 c2                	add    %eax,%edx
f0103d3f:	01 d2                	add    %edx,%edx
f0103d41:	01 c2                	add    %eax,%edx
f0103d43:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d46:	83 3c 85 28 60 2a f0 	cmpl   $0x0,-0xfd59fd8(,%eax,4)
f0103d4d:	00 
f0103d4e:	74 18                	je     f0103d68 <env_run+0x39>
f0103d50:	e8 ed 29 00 00       	call   f0106742 <cpunum>
f0103d55:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d58:	8b 80 28 60 2a f0    	mov    -0xfd59fd8(%eax),%eax
f0103d5e:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103d62:	0f 84 8c 00 00 00    	je     f0103df4 <env_run+0xc5>
		curenv->env_status = ENV_RUNNABLE;
	}

	curenv = e;
f0103d68:	e8 d5 29 00 00       	call   f0106742 <cpunum>
f0103d6d:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103d70:	01 c2                	add    %eax,%edx
f0103d72:	01 d2                	add    %edx,%edx
f0103d74:	01 c2                	add    %eax,%edx
f0103d76:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d79:	8b 55 08             	mov    0x8(%ebp),%edx
f0103d7c:	89 14 85 28 60 2a f0 	mov    %edx,-0xfd59fd8(,%eax,4)
	curenv->env_status = ENV_RUNNING;
f0103d83:	e8 ba 29 00 00       	call   f0106742 <cpunum>
f0103d88:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103d8b:	01 c2                	add    %eax,%edx
f0103d8d:	01 d2                	add    %edx,%edx
f0103d8f:	01 c2                	add    %eax,%edx
f0103d91:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d94:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f0103d9b:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++; // Incremetn run count
f0103da2:	e8 9b 29 00 00       	call   f0106742 <cpunum>
f0103da7:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103daa:	01 c2                	add    %eax,%edx
f0103dac:	01 d2                	add    %edx,%edx
f0103dae:	01 c2                	add    %eax,%edx
f0103db0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103db3:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f0103dba:	ff 40 58             	incl   0x58(%eax)

	// Jump to user env pgdir
	lcr3(PADDR(curenv->env_pgdir));
f0103dbd:	e8 80 29 00 00       	call   f0106742 <cpunum>
f0103dc2:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103dc5:	01 c2                	add    %eax,%edx
f0103dc7:	01 d2                	add    %edx,%edx
f0103dc9:	01 c2                	add    %eax,%edx
f0103dcb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103dce:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f0103dd5:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103dd8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ddd:	77 2f                	ja     f0103e0e <env_run+0xdf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ddf:	50                   	push   %eax
f0103de0:	68 ec 6e 10 f0       	push   $0xf0106eec
f0103de5:	68 31 02 00 00       	push   $0x231
f0103dea:	68 0f 83 10 f0       	push   $0xf010830f
f0103def:	e8 a0 c2 ff ff       	call   f0100094 <_panic>
		curenv->env_status = ENV_RUNNABLE;
f0103df4:	e8 49 29 00 00       	call   f0106742 <cpunum>
f0103df9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dfc:	8b 80 28 60 2a f0    	mov    -0xfd59fd8(%eax),%eax
f0103e02:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0103e09:	e9 5a ff ff ff       	jmp    f0103d68 <env_run+0x39>
	return (physaddr_t)kva - KERNBASE;
f0103e0e:	05 00 00 00 10       	add    $0x10000000,%eax
f0103e13:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103e16:	83 ec 0c             	sub    $0xc,%esp
f0103e19:	68 c0 33 12 f0       	push   $0xf01233c0
f0103e1e:	e8 40 2c 00 00       	call   f0106a63 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103e23:	f3 90                	pause  

	// Unlock the kernel if we're heading user mode.
	unlock_kernel();

	// Do the final work.
	env_pop_tf(&curenv->env_tf);  // Does not return.
f0103e25:	e8 18 29 00 00       	call   f0106742 <cpunum>
f0103e2a:	83 c4 04             	add    $0x4,%esp
f0103e2d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e30:	ff b0 28 60 2a f0    	pushl  -0xfd59fd8(%eax)
f0103e36:	e8 ac fe ff ff       	call   f0103ce7 <env_pop_tf>

f0103e3b <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103e3b:	55                   	push   %ebp
f0103e3c:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e3e:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e43:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e46:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103e47:	ba 71 00 00 00       	mov    $0x71,%edx
f0103e4c:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103e4d:	0f b6 c0             	movzbl %al,%eax
}
f0103e50:	5d                   	pop    %ebp
f0103e51:	c3                   	ret    

f0103e52 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103e52:	55                   	push   %ebp
f0103e53:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e55:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e5a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e5d:	ee                   	out    %al,(%dx)
f0103e5e:	ba 71 00 00 00       	mov    $0x71,%edx
f0103e63:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e66:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103e67:	5d                   	pop    %ebp
f0103e68:	c3                   	ret    

f0103e69 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103e69:	55                   	push   %ebp
f0103e6a:	89 e5                	mov    %esp,%ebp
f0103e6c:	56                   	push   %esi
f0103e6d:	53                   	push   %ebx
f0103e6e:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103e71:	66 a3 a8 33 12 f0    	mov    %ax,0xf01233a8
	if (!didinit)
f0103e77:	80 3d 50 52 2a f0 00 	cmpb   $0x0,0xf02a5250
f0103e7e:	74 5a                	je     f0103eda <irq_setmask_8259A+0x71>
f0103e80:	89 c6                	mov    %eax,%esi
f0103e82:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e87:	ee                   	out    %al,(%dx)
f0103e88:	66 c1 e8 08          	shr    $0x8,%ax
f0103e8c:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103e91:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103e92:	83 ec 0c             	sub    $0xc,%esp
f0103e95:	68 8a 83 10 f0       	push   $0xf010838a
f0103e9a:	e8 1b 01 00 00       	call   f0103fba <cprintf>
f0103e9f:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103ea2:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103ea7:	0f b7 f6             	movzwl %si,%esi
f0103eaa:	f7 d6                	not    %esi
f0103eac:	0f a3 de             	bt     %ebx,%esi
f0103eaf:	73 11                	jae    f0103ec2 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103eb1:	83 ec 08             	sub    $0x8,%esp
f0103eb4:	53                   	push   %ebx
f0103eb5:	68 5f 88 10 f0       	push   $0xf010885f
f0103eba:	e8 fb 00 00 00       	call   f0103fba <cprintf>
f0103ebf:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103ec2:	83 c3 01             	add    $0x1,%ebx
f0103ec5:	83 fb 10             	cmp    $0x10,%ebx
f0103ec8:	75 e2                	jne    f0103eac <irq_setmask_8259A+0x43>
	cprintf("\n");
f0103eca:	83 ec 0c             	sub    $0xc,%esp
f0103ecd:	68 1b 72 10 f0       	push   $0xf010721b
f0103ed2:	e8 e3 00 00 00       	call   f0103fba <cprintf>
f0103ed7:	83 c4 10             	add    $0x10,%esp
}
f0103eda:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103edd:	5b                   	pop    %ebx
f0103ede:	5e                   	pop    %esi
f0103edf:	5d                   	pop    %ebp
f0103ee0:	c3                   	ret    

f0103ee1 <pic_init>:
	didinit = 1;
f0103ee1:	c6 05 50 52 2a f0 01 	movb   $0x1,0xf02a5250
f0103ee8:	ba 21 00 00 00       	mov    $0x21,%edx
f0103eed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ef2:	ee                   	out    %al,(%dx)
f0103ef3:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103ef8:	ee                   	out    %al,(%dx)
f0103ef9:	ba 20 00 00 00       	mov    $0x20,%edx
f0103efe:	b8 11 00 00 00       	mov    $0x11,%eax
f0103f03:	ee                   	out    %al,(%dx)
f0103f04:	ba 21 00 00 00       	mov    $0x21,%edx
f0103f09:	b8 20 00 00 00       	mov    $0x20,%eax
f0103f0e:	ee                   	out    %al,(%dx)
f0103f0f:	b8 04 00 00 00       	mov    $0x4,%eax
f0103f14:	ee                   	out    %al,(%dx)
f0103f15:	b8 03 00 00 00       	mov    $0x3,%eax
f0103f1a:	ee                   	out    %al,(%dx)
f0103f1b:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103f20:	b8 11 00 00 00       	mov    $0x11,%eax
f0103f25:	ee                   	out    %al,(%dx)
f0103f26:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103f2b:	b8 28 00 00 00       	mov    $0x28,%eax
f0103f30:	ee                   	out    %al,(%dx)
f0103f31:	b8 02 00 00 00       	mov    $0x2,%eax
f0103f36:	ee                   	out    %al,(%dx)
f0103f37:	b8 01 00 00 00       	mov    $0x1,%eax
f0103f3c:	ee                   	out    %al,(%dx)
f0103f3d:	ba 20 00 00 00       	mov    $0x20,%edx
f0103f42:	b8 68 00 00 00       	mov    $0x68,%eax
f0103f47:	ee                   	out    %al,(%dx)
f0103f48:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f4d:	ee                   	out    %al,(%dx)
f0103f4e:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103f53:	b8 68 00 00 00       	mov    $0x68,%eax
f0103f58:	ee                   	out    %al,(%dx)
f0103f59:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f5e:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103f5f:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f0103f66:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103f6a:	74 13                	je     f0103f7f <pic_init+0x9e>
{
f0103f6c:	55                   	push   %ebp
f0103f6d:	89 e5                	mov    %esp,%ebp
f0103f6f:	83 ec 14             	sub    $0x14,%esp
		irq_setmask_8259A(irq_mask_8259A);
f0103f72:	0f b7 c0             	movzwl %ax,%eax
f0103f75:	50                   	push   %eax
f0103f76:	e8 ee fe ff ff       	call   f0103e69 <irq_setmask_8259A>
f0103f7b:	83 c4 10             	add    $0x10,%esp
}
f0103f7e:	c9                   	leave  
f0103f7f:	f3 c3                	repz ret 

f0103f81 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103f81:	55                   	push   %ebp
f0103f82:	89 e5                	mov    %esp,%ebp
f0103f84:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103f87:	ff 75 08             	pushl  0x8(%ebp)
f0103f8a:	e8 c1 c8 ff ff       	call   f0100850 <cputchar>
	*cnt++;
}
f0103f8f:	83 c4 10             	add    $0x10,%esp
f0103f92:	c9                   	leave  
f0103f93:	c3                   	ret    

f0103f94 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103f94:	55                   	push   %ebp
f0103f95:	89 e5                	mov    %esp,%ebp
f0103f97:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103f9a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103fa1:	ff 75 0c             	pushl  0xc(%ebp)
f0103fa4:	ff 75 08             	pushl  0x8(%ebp)
f0103fa7:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103faa:	50                   	push   %eax
f0103fab:	68 81 3f 10 f0       	push   $0xf0103f81
f0103fb0:	e8 35 19 00 00       	call   f01058ea <vprintfmt>
	return cnt;
}
f0103fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103fb8:	c9                   	leave  
f0103fb9:	c3                   	ret    

f0103fba <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103fba:	55                   	push   %ebp
f0103fbb:	89 e5                	mov    %esp,%ebp
f0103fbd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103fc0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103fc3:	50                   	push   %eax
f0103fc4:	ff 75 08             	pushl  0x8(%ebp)
f0103fc7:	e8 c8 ff ff ff       	call   f0103f94 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103fcc:	c9                   	leave  
f0103fcd:	c3                   	ret    

f0103fce <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103fce:	55                   	push   %ebp
f0103fcf:	89 e5                	mov    %esp,%ebp
f0103fd1:	57                   	push   %edi
f0103fd2:	56                   	push   %esi
f0103fd3:	53                   	push   %ebx
f0103fd4:	83 ec 0c             	sub    $0xc,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	struct Taskstate* ts = &thiscpu->cpu_ts;
f0103fd7:	e8 66 27 00 00       	call   f0106742 <cpunum>
f0103fdc:	89 c6                	mov    %eax,%esi
f0103fde:	8d 1c 00             	lea    (%eax,%eax,1),%ebx
f0103fe1:	01 c3                	add    %eax,%ebx
f0103fe3:	01 db                	add    %ebx,%ebx
f0103fe5:	01 c3                	add    %eax,%ebx
f0103fe7:	c1 e3 02             	shl    $0x2,%ebx
f0103fea:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0103fed:	8d 3c 85 2c 60 2a f0 	lea    -0xfd59fd4(,%eax,4),%edi
	ts->ts_esp0 = KSTACKTOP - cpunum() * (KSTKSIZE + KSTKGAP);
f0103ff4:	e8 49 27 00 00       	call   f0106742 <cpunum>
f0103ff9:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f0103ffc:	8d 14 95 20 60 2a f0 	lea    -0xfd59fe0(,%edx,4),%edx
f0104003:	c1 e0 10             	shl    $0x10,%eax
f0104006:	89 c1                	mov    %eax,%ecx
f0104008:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f010400d:	29 c8                	sub    %ecx,%eax
f010400f:	89 42 10             	mov    %eax,0x10(%edx)
	ts->ts_ss0 = GD_KD;
f0104012:	66 c7 42 14 10 00    	movw   $0x10,0x14(%edx)
	ts->ts_iomb = sizeof(struct Taskstate);
f0104018:	01 f3                	add    %esi,%ebx
f010401a:	66 c7 04 9d 92 60 2a 	movw   $0x68,-0xfd59f6e(,%ebx,4)
f0104021:	f0 68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) ts,
f0104024:	66 c7 05 68 33 12 f0 	movw   $0x67,0xf0123368
f010402b:	67 00 
f010402d:	66 89 3d 6a 33 12 f0 	mov    %di,0xf012336a
f0104034:	89 f8                	mov    %edi,%eax
f0104036:	c1 e8 10             	shr    $0x10,%eax
f0104039:	a2 6c 33 12 f0       	mov    %al,0xf012336c
f010403e:	c6 05 6e 33 12 f0 40 	movb   $0x40,0xf012336e
f0104045:	89 f8                	mov    %edi,%eax
f0104047:	c1 e8 18             	shr    $0x18,%eax
f010404a:	a2 6f 33 12 f0       	mov    %al,0xf012336f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f010404f:	c6 05 6d 33 12 f0 89 	movb   $0x89,0xf012336d
	asm volatile("ltr %0" : : "r" (sel));
f0104056:	b8 28 00 00 00       	mov    $0x28,%eax
f010405b:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f010405e:	b8 ac 33 12 f0       	mov    $0xf01233ac,%eax
f0104063:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0104066:	83 c4 0c             	add    $0xc,%esp
f0104069:	5b                   	pop    %ebx
f010406a:	5e                   	pop    %esi
f010406b:	5f                   	pop    %edi
f010406c:	5d                   	pop    %ebp
f010406d:	c3                   	ret    

f010406e <trap_init>:
{
f010406e:	55                   	push   %ebp
f010406f:	89 e5                	mov    %esp,%ebp
f0104071:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE],  0, GD_KT, (void*)H_DIVIDE, 0);   
f0104074:	b8 3a 4c 10 f0       	mov    $0xf0104c3a,%eax
f0104079:	66 a3 60 52 2a f0    	mov    %ax,0xf02a5260
f010407f:	66 c7 05 62 52 2a f0 	movw   $0x8,0xf02a5262
f0104086:	08 00 
f0104088:	c6 05 64 52 2a f0 00 	movb   $0x0,0xf02a5264
f010408f:	c6 05 65 52 2a f0 8e 	movb   $0x8e,0xf02a5265
f0104096:	c1 e8 10             	shr    $0x10,%eax
f0104099:	66 a3 66 52 2a f0    	mov    %ax,0xf02a5266
	SETGATE(idt[T_DEBUG],   0, GD_KT, (void*)H_DEBUG,  0);  
f010409f:	b8 44 4c 10 f0       	mov    $0xf0104c44,%eax
f01040a4:	66 a3 68 52 2a f0    	mov    %ax,0xf02a5268
f01040aa:	66 c7 05 6a 52 2a f0 	movw   $0x8,0xf02a526a
f01040b1:	08 00 
f01040b3:	c6 05 6c 52 2a f0 00 	movb   $0x0,0xf02a526c
f01040ba:	c6 05 6d 52 2a f0 8e 	movb   $0x8e,0xf02a526d
f01040c1:	c1 e8 10             	shr    $0x10,%eax
f01040c4:	66 a3 6e 52 2a f0    	mov    %ax,0xf02a526e
	SETGATE(idt[T_NMI],     0, GD_KT, (void*)H_NMI,    0);
f01040ca:	b8 4e 4c 10 f0       	mov    $0xf0104c4e,%eax
f01040cf:	66 a3 70 52 2a f0    	mov    %ax,0xf02a5270
f01040d5:	66 c7 05 72 52 2a f0 	movw   $0x8,0xf02a5272
f01040dc:	08 00 
f01040de:	c6 05 74 52 2a f0 00 	movb   $0x0,0xf02a5274
f01040e5:	c6 05 75 52 2a f0 8e 	movb   $0x8e,0xf02a5275
f01040ec:	c1 e8 10             	shr    $0x10,%eax
f01040ef:	66 a3 76 52 2a f0    	mov    %ax,0xf02a5276
	SETGATE(idt[T_BRKPT],   0, GD_KT, (void*)H_BRKPT,  3);  // User level previlege (3)
f01040f5:	b8 58 4c 10 f0       	mov    $0xf0104c58,%eax
f01040fa:	66 a3 78 52 2a f0    	mov    %ax,0xf02a5278
f0104100:	66 c7 05 7a 52 2a f0 	movw   $0x8,0xf02a527a
f0104107:	08 00 
f0104109:	c6 05 7c 52 2a f0 00 	movb   $0x0,0xf02a527c
f0104110:	c6 05 7d 52 2a f0 ee 	movb   $0xee,0xf02a527d
f0104117:	c1 e8 10             	shr    $0x10,%eax
f010411a:	66 a3 7e 52 2a f0    	mov    %ax,0xf02a527e
	SETGATE(idt[T_OFLOW],   0, GD_KT, (void*)H_OFLOW,  0);  
f0104120:	b8 62 4c 10 f0       	mov    $0xf0104c62,%eax
f0104125:	66 a3 80 52 2a f0    	mov    %ax,0xf02a5280
f010412b:	66 c7 05 82 52 2a f0 	movw   $0x8,0xf02a5282
f0104132:	08 00 
f0104134:	c6 05 84 52 2a f0 00 	movb   $0x0,0xf02a5284
f010413b:	c6 05 85 52 2a f0 8e 	movb   $0x8e,0xf02a5285
f0104142:	c1 e8 10             	shr    $0x10,%eax
f0104145:	66 a3 86 52 2a f0    	mov    %ax,0xf02a5286
	SETGATE(idt[T_BOUND],   0, GD_KT, (void*)H_BOUND,  0);  
f010414b:	b8 6c 4c 10 f0       	mov    $0xf0104c6c,%eax
f0104150:	66 a3 88 52 2a f0    	mov    %ax,0xf02a5288
f0104156:	66 c7 05 8a 52 2a f0 	movw   $0x8,0xf02a528a
f010415d:	08 00 
f010415f:	c6 05 8c 52 2a f0 00 	movb   $0x0,0xf02a528c
f0104166:	c6 05 8d 52 2a f0 8e 	movb   $0x8e,0xf02a528d
f010416d:	c1 e8 10             	shr    $0x10,%eax
f0104170:	66 a3 8e 52 2a f0    	mov    %ax,0xf02a528e
	SETGATE(idt[T_ILLOP],   0, GD_KT, (void*)H_ILLOP,  0);  
f0104176:	b8 76 4c 10 f0       	mov    $0xf0104c76,%eax
f010417b:	66 a3 90 52 2a f0    	mov    %ax,0xf02a5290
f0104181:	66 c7 05 92 52 2a f0 	movw   $0x8,0xf02a5292
f0104188:	08 00 
f010418a:	c6 05 94 52 2a f0 00 	movb   $0x0,0xf02a5294
f0104191:	c6 05 95 52 2a f0 8e 	movb   $0x8e,0xf02a5295
f0104198:	c1 e8 10             	shr    $0x10,%eax
f010419b:	66 a3 96 52 2a f0    	mov    %ax,0xf02a5296
	SETGATE(idt[T_DEVICE],  0, GD_KT, (void*)H_DEVICE, 0);   
f01041a1:	b8 80 4c 10 f0       	mov    $0xf0104c80,%eax
f01041a6:	66 a3 98 52 2a f0    	mov    %ax,0xf02a5298
f01041ac:	66 c7 05 9a 52 2a f0 	movw   $0x8,0xf02a529a
f01041b3:	08 00 
f01041b5:	c6 05 9c 52 2a f0 00 	movb   $0x0,0xf02a529c
f01041bc:	c6 05 9d 52 2a f0 8e 	movb   $0x8e,0xf02a529d
f01041c3:	c1 e8 10             	shr    $0x10,%eax
f01041c6:	66 a3 9e 52 2a f0    	mov    %ax,0xf02a529e
	SETGATE(idt[T_DBLFLT],  0, GD_KT, (void*)H_DBLFLT, 0);   
f01041cc:	b8 8a 4c 10 f0       	mov    $0xf0104c8a,%eax
f01041d1:	66 a3 a0 52 2a f0    	mov    %ax,0xf02a52a0
f01041d7:	66 c7 05 a2 52 2a f0 	movw   $0x8,0xf02a52a2
f01041de:	08 00 
f01041e0:	c6 05 a4 52 2a f0 00 	movb   $0x0,0xf02a52a4
f01041e7:	c6 05 a5 52 2a f0 8e 	movb   $0x8e,0xf02a52a5
f01041ee:	c1 e8 10             	shr    $0x10,%eax
f01041f1:	66 a3 a6 52 2a f0    	mov    %ax,0xf02a52a6
	SETGATE(idt[T_TSS],     0, GD_KT, (void*)H_TSS,    0);
f01041f7:	b8 92 4c 10 f0       	mov    $0xf0104c92,%eax
f01041fc:	66 a3 b0 52 2a f0    	mov    %ax,0xf02a52b0
f0104202:	66 c7 05 b2 52 2a f0 	movw   $0x8,0xf02a52b2
f0104209:	08 00 
f010420b:	c6 05 b4 52 2a f0 00 	movb   $0x0,0xf02a52b4
f0104212:	c6 05 b5 52 2a f0 8e 	movb   $0x8e,0xf02a52b5
f0104219:	c1 e8 10             	shr    $0x10,%eax
f010421c:	66 a3 b6 52 2a f0    	mov    %ax,0xf02a52b6
	SETGATE(idt[T_SEGNP],   0, GD_KT, (void*)H_SEGNP,  0);  
f0104222:	b8 9a 4c 10 f0       	mov    $0xf0104c9a,%eax
f0104227:	66 a3 b8 52 2a f0    	mov    %ax,0xf02a52b8
f010422d:	66 c7 05 ba 52 2a f0 	movw   $0x8,0xf02a52ba
f0104234:	08 00 
f0104236:	c6 05 bc 52 2a f0 00 	movb   $0x0,0xf02a52bc
f010423d:	c6 05 bd 52 2a f0 8e 	movb   $0x8e,0xf02a52bd
f0104244:	c1 e8 10             	shr    $0x10,%eax
f0104247:	66 a3 be 52 2a f0    	mov    %ax,0xf02a52be
	SETGATE(idt[T_STACK],   0, GD_KT, (void*)H_STACK,  0);  
f010424d:	b8 a2 4c 10 f0       	mov    $0xf0104ca2,%eax
f0104252:	66 a3 c0 52 2a f0    	mov    %ax,0xf02a52c0
f0104258:	66 c7 05 c2 52 2a f0 	movw   $0x8,0xf02a52c2
f010425f:	08 00 
f0104261:	c6 05 c4 52 2a f0 00 	movb   $0x0,0xf02a52c4
f0104268:	c6 05 c5 52 2a f0 8e 	movb   $0x8e,0xf02a52c5
f010426f:	c1 e8 10             	shr    $0x10,%eax
f0104272:	66 a3 c6 52 2a f0    	mov    %ax,0xf02a52c6
	SETGATE(idt[T_GPFLT],   0, GD_KT, (void*)H_GPFLT,  0);  
f0104278:	b8 aa 4c 10 f0       	mov    $0xf0104caa,%eax
f010427d:	66 a3 c8 52 2a f0    	mov    %ax,0xf02a52c8
f0104283:	66 c7 05 ca 52 2a f0 	movw   $0x8,0xf02a52ca
f010428a:	08 00 
f010428c:	c6 05 cc 52 2a f0 00 	movb   $0x0,0xf02a52cc
f0104293:	c6 05 cd 52 2a f0 8e 	movb   $0x8e,0xf02a52cd
f010429a:	c1 e8 10             	shr    $0x10,%eax
f010429d:	66 a3 ce 52 2a f0    	mov    %ax,0xf02a52ce
	SETGATE(idt[T_PGFLT],   0, GD_KT, (void*)H_PGFLT,  0);  
f01042a3:	b8 b2 4c 10 f0       	mov    $0xf0104cb2,%eax
f01042a8:	66 a3 d0 52 2a f0    	mov    %ax,0xf02a52d0
f01042ae:	66 c7 05 d2 52 2a f0 	movw   $0x8,0xf02a52d2
f01042b5:	08 00 
f01042b7:	c6 05 d4 52 2a f0 00 	movb   $0x0,0xf02a52d4
f01042be:	c6 05 d5 52 2a f0 8e 	movb   $0x8e,0xf02a52d5
f01042c5:	c1 e8 10             	shr    $0x10,%eax
f01042c8:	66 a3 d6 52 2a f0    	mov    %ax,0xf02a52d6
	SETGATE(idt[T_FPERR],   0, GD_KT, (void*)H_FPERR,  0);  
f01042ce:	b8 b6 4c 10 f0       	mov    $0xf0104cb6,%eax
f01042d3:	66 a3 e0 52 2a f0    	mov    %ax,0xf02a52e0
f01042d9:	66 c7 05 e2 52 2a f0 	movw   $0x8,0xf02a52e2
f01042e0:	08 00 
f01042e2:	c6 05 e4 52 2a f0 00 	movb   $0x0,0xf02a52e4
f01042e9:	c6 05 e5 52 2a f0 8e 	movb   $0x8e,0xf02a52e5
f01042f0:	c1 e8 10             	shr    $0x10,%eax
f01042f3:	66 a3 e6 52 2a f0    	mov    %ax,0xf02a52e6
	SETGATE(idt[T_ALIGN],   0, GD_KT, (void*)H_ALIGN,  0);  
f01042f9:	b8 bc 4c 10 f0       	mov    $0xf0104cbc,%eax
f01042fe:	66 a3 e8 52 2a f0    	mov    %ax,0xf02a52e8
f0104304:	66 c7 05 ea 52 2a f0 	movw   $0x8,0xf02a52ea
f010430b:	08 00 
f010430d:	c6 05 ec 52 2a f0 00 	movb   $0x0,0xf02a52ec
f0104314:	c6 05 ed 52 2a f0 8e 	movb   $0x8e,0xf02a52ed
f010431b:	c1 e8 10             	shr    $0x10,%eax
f010431e:	66 a3 ee 52 2a f0    	mov    %ax,0xf02a52ee
	SETGATE(idt[T_MCHK],    0, GD_KT, (void*)H_MCHK,   0); 
f0104324:	b8 c2 4c 10 f0       	mov    $0xf0104cc2,%eax
f0104329:	66 a3 f0 52 2a f0    	mov    %ax,0xf02a52f0
f010432f:	66 c7 05 f2 52 2a f0 	movw   $0x8,0xf02a52f2
f0104336:	08 00 
f0104338:	c6 05 f4 52 2a f0 00 	movb   $0x0,0xf02a52f4
f010433f:	c6 05 f5 52 2a f0 8e 	movb   $0x8e,0xf02a52f5
f0104346:	c1 e8 10             	shr    $0x10,%eax
f0104349:	66 a3 f6 52 2a f0    	mov    %ax,0xf02a52f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, (void*)H_SIMDERR,0);  
f010434f:	b8 c8 4c 10 f0       	mov    $0xf0104cc8,%eax
f0104354:	66 a3 f8 52 2a f0    	mov    %ax,0xf02a52f8
f010435a:	66 c7 05 fa 52 2a f0 	movw   $0x8,0xf02a52fa
f0104361:	08 00 
f0104363:	c6 05 fc 52 2a f0 00 	movb   $0x0,0xf02a52fc
f010436a:	c6 05 fd 52 2a f0 8e 	movb   $0x8e,0xf02a52fd
f0104371:	c1 e8 10             	shr    $0x10,%eax
f0104374:	66 a3 fe 52 2a f0    	mov    %ax,0xf02a52fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, (void*)H_SYSCALL,3);  // System call
f010437a:	b8 ce 4c 10 f0       	mov    $0xf0104cce,%eax
f010437f:	66 a3 e0 53 2a f0    	mov    %ax,0xf02a53e0
f0104385:	66 c7 05 e2 53 2a f0 	movw   $0x8,0xf02a53e2
f010438c:	08 00 
f010438e:	c6 05 e4 53 2a f0 00 	movb   $0x0,0xf02a53e4
f0104395:	c6 05 e5 53 2a f0 ee 	movb   $0xee,0xf02a53e5
f010439c:	c1 e8 10             	shr    $0x10,%eax
f010439f:	66 a3 e6 53 2a f0    	mov    %ax,0xf02a53e6
	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER],    0, GD_KT, (void*)H_TIMER,  0);
f01043a5:	b8 d4 4c 10 f0       	mov    $0xf0104cd4,%eax
f01043aa:	66 a3 60 53 2a f0    	mov    %ax,0xf02a5360
f01043b0:	66 c7 05 62 53 2a f0 	movw   $0x8,0xf02a5362
f01043b7:	08 00 
f01043b9:	c6 05 64 53 2a f0 00 	movb   $0x0,0xf02a5364
f01043c0:	c6 05 65 53 2a f0 8e 	movb   $0x8e,0xf02a5365
f01043c7:	c1 e8 10             	shr    $0x10,%eax
f01043ca:	66 a3 66 53 2a f0    	mov    %ax,0xf02a5366
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD],      0, GD_KT, (void*)H_KBD,    0);
f01043d0:	b8 da 4c 10 f0       	mov    $0xf0104cda,%eax
f01043d5:	66 a3 68 53 2a f0    	mov    %ax,0xf02a5368
f01043db:	66 c7 05 6a 53 2a f0 	movw   $0x8,0xf02a536a
f01043e2:	08 00 
f01043e4:	c6 05 6c 53 2a f0 00 	movb   $0x0,0xf02a536c
f01043eb:	c6 05 6d 53 2a f0 8e 	movb   $0x8e,0xf02a536d
f01043f2:	c1 e8 10             	shr    $0x10,%eax
f01043f5:	66 a3 6e 53 2a f0    	mov    %ax,0xf02a536e
	SETGATE(idt[IRQ_OFFSET + 2],            0, GD_KT, (void*)H_IRQ2,   0);
f01043fb:	b8 e0 4c 10 f0       	mov    $0xf0104ce0,%eax
f0104400:	66 a3 70 53 2a f0    	mov    %ax,0xf02a5370
f0104406:	66 c7 05 72 53 2a f0 	movw   $0x8,0xf02a5372
f010440d:	08 00 
f010440f:	c6 05 74 53 2a f0 00 	movb   $0x0,0xf02a5374
f0104416:	c6 05 75 53 2a f0 8e 	movb   $0x8e,0xf02a5375
f010441d:	c1 e8 10             	shr    $0x10,%eax
f0104420:	66 a3 76 53 2a f0    	mov    %ax,0xf02a5376
	SETGATE(idt[IRQ_OFFSET + 3],            0, GD_KT, (void*)H_IRQ3,   0);
f0104426:	b8 e6 4c 10 f0       	mov    $0xf0104ce6,%eax
f010442b:	66 a3 78 53 2a f0    	mov    %ax,0xf02a5378
f0104431:	66 c7 05 7a 53 2a f0 	movw   $0x8,0xf02a537a
f0104438:	08 00 
f010443a:	c6 05 7c 53 2a f0 00 	movb   $0x0,0xf02a537c
f0104441:	c6 05 7d 53 2a f0 8e 	movb   $0x8e,0xf02a537d
f0104448:	c1 e8 10             	shr    $0x10,%eax
f010444b:	66 a3 7e 53 2a f0    	mov    %ax,0xf02a537e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL],   0, GD_KT, (void*)H_SERIAL, 0);
f0104451:	b8 ec 4c 10 f0       	mov    $0xf0104cec,%eax
f0104456:	66 a3 80 53 2a f0    	mov    %ax,0xf02a5380
f010445c:	66 c7 05 82 53 2a f0 	movw   $0x8,0xf02a5382
f0104463:	08 00 
f0104465:	c6 05 84 53 2a f0 00 	movb   $0x0,0xf02a5384
f010446c:	c6 05 85 53 2a f0 8e 	movb   $0x8e,0xf02a5385
f0104473:	c1 e8 10             	shr    $0x10,%eax
f0104476:	66 a3 86 53 2a f0    	mov    %ax,0xf02a5386
	SETGATE(idt[IRQ_OFFSET + 5],            0, GD_KT, (void*)H_IRQ5,   0);
f010447c:	b8 f2 4c 10 f0       	mov    $0xf0104cf2,%eax
f0104481:	66 a3 88 53 2a f0    	mov    %ax,0xf02a5388
f0104487:	66 c7 05 8a 53 2a f0 	movw   $0x8,0xf02a538a
f010448e:	08 00 
f0104490:	c6 05 8c 53 2a f0 00 	movb   $0x0,0xf02a538c
f0104497:	c6 05 8d 53 2a f0 8e 	movb   $0x8e,0xf02a538d
f010449e:	c1 e8 10             	shr    $0x10,%eax
f01044a1:	66 a3 8e 53 2a f0    	mov    %ax,0xf02a538e
	SETGATE(idt[IRQ_OFFSET + 6],            0, GD_KT, (void*)H_IRQ6,   0);
f01044a7:	b8 f8 4c 10 f0       	mov    $0xf0104cf8,%eax
f01044ac:	66 a3 90 53 2a f0    	mov    %ax,0xf02a5390
f01044b2:	66 c7 05 92 53 2a f0 	movw   $0x8,0xf02a5392
f01044b9:	08 00 
f01044bb:	c6 05 94 53 2a f0 00 	movb   $0x0,0xf02a5394
f01044c2:	c6 05 95 53 2a f0 8e 	movb   $0x8e,0xf02a5395
f01044c9:	c1 e8 10             	shr    $0x10,%eax
f01044cc:	66 a3 96 53 2a f0    	mov    %ax,0xf02a5396
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, (void*)H_SPUR,   0);
f01044d2:	b8 fe 4c 10 f0       	mov    $0xf0104cfe,%eax
f01044d7:	66 a3 98 53 2a f0    	mov    %ax,0xf02a5398
f01044dd:	66 c7 05 9a 53 2a f0 	movw   $0x8,0xf02a539a
f01044e4:	08 00 
f01044e6:	c6 05 9c 53 2a f0 00 	movb   $0x0,0xf02a539c
f01044ed:	c6 05 9d 53 2a f0 8e 	movb   $0x8e,0xf02a539d
f01044f4:	c1 e8 10             	shr    $0x10,%eax
f01044f7:	66 a3 9e 53 2a f0    	mov    %ax,0xf02a539e
	SETGATE(idt[IRQ_OFFSET + 8],            0, GD_KT, (void*)H_IRQ8,   0);
f01044fd:	b8 04 4d 10 f0       	mov    $0xf0104d04,%eax
f0104502:	66 a3 a0 53 2a f0    	mov    %ax,0xf02a53a0
f0104508:	66 c7 05 a2 53 2a f0 	movw   $0x8,0xf02a53a2
f010450f:	08 00 
f0104511:	c6 05 a4 53 2a f0 00 	movb   $0x0,0xf02a53a4
f0104518:	c6 05 a5 53 2a f0 8e 	movb   $0x8e,0xf02a53a5
f010451f:	c1 e8 10             	shr    $0x10,%eax
f0104522:	66 a3 a6 53 2a f0    	mov    %ax,0xf02a53a6
	SETGATE(idt[IRQ_OFFSET + 9],            0, GD_KT, (void*)H_IRQ9,   0);
f0104528:	b8 0a 4d 10 f0       	mov    $0xf0104d0a,%eax
f010452d:	66 a3 a8 53 2a f0    	mov    %ax,0xf02a53a8
f0104533:	66 c7 05 aa 53 2a f0 	movw   $0x8,0xf02a53aa
f010453a:	08 00 
f010453c:	c6 05 ac 53 2a f0 00 	movb   $0x0,0xf02a53ac
f0104543:	c6 05 ad 53 2a f0 8e 	movb   $0x8e,0xf02a53ad
f010454a:	c1 e8 10             	shr    $0x10,%eax
f010454d:	66 a3 ae 53 2a f0    	mov    %ax,0xf02a53ae
	SETGATE(idt[IRQ_OFFSET + 10],           0, GD_KT, (void*)H_IRQ10,  0);
f0104553:	b8 10 4d 10 f0       	mov    $0xf0104d10,%eax
f0104558:	66 a3 b0 53 2a f0    	mov    %ax,0xf02a53b0
f010455e:	66 c7 05 b2 53 2a f0 	movw   $0x8,0xf02a53b2
f0104565:	08 00 
f0104567:	c6 05 b4 53 2a f0 00 	movb   $0x0,0xf02a53b4
f010456e:	c6 05 b5 53 2a f0 8e 	movb   $0x8e,0xf02a53b5
f0104575:	c1 e8 10             	shr    $0x10,%eax
f0104578:	66 a3 b6 53 2a f0    	mov    %ax,0xf02a53b6
	SETGATE(idt[IRQ_OFFSET + 11],           0, GD_KT, (void*)H_IRQ11,  0);
f010457e:	b8 16 4d 10 f0       	mov    $0xf0104d16,%eax
f0104583:	66 a3 b8 53 2a f0    	mov    %ax,0xf02a53b8
f0104589:	66 c7 05 ba 53 2a f0 	movw   $0x8,0xf02a53ba
f0104590:	08 00 
f0104592:	c6 05 bc 53 2a f0 00 	movb   $0x0,0xf02a53bc
f0104599:	c6 05 bd 53 2a f0 8e 	movb   $0x8e,0xf02a53bd
f01045a0:	c1 e8 10             	shr    $0x10,%eax
f01045a3:	66 a3 be 53 2a f0    	mov    %ax,0xf02a53be
	SETGATE(idt[IRQ_OFFSET + 12],           0, GD_KT, (void*)H_IRQ12,  0);
f01045a9:	b8 1c 4d 10 f0       	mov    $0xf0104d1c,%eax
f01045ae:	66 a3 c0 53 2a f0    	mov    %ax,0xf02a53c0
f01045b4:	66 c7 05 c2 53 2a f0 	movw   $0x8,0xf02a53c2
f01045bb:	08 00 
f01045bd:	c6 05 c4 53 2a f0 00 	movb   $0x0,0xf02a53c4
f01045c4:	c6 05 c5 53 2a f0 8e 	movb   $0x8e,0xf02a53c5
f01045cb:	c1 e8 10             	shr    $0x10,%eax
f01045ce:	66 a3 c6 53 2a f0    	mov    %ax,0xf02a53c6
	SETGATE(idt[IRQ_OFFSET + 13],           0, GD_KT, (void*)H_IRQ13,  0);
f01045d4:	b8 22 4d 10 f0       	mov    $0xf0104d22,%eax
f01045d9:	66 a3 c8 53 2a f0    	mov    %ax,0xf02a53c8
f01045df:	66 c7 05 ca 53 2a f0 	movw   $0x8,0xf02a53ca
f01045e6:	08 00 
f01045e8:	c6 05 cc 53 2a f0 00 	movb   $0x0,0xf02a53cc
f01045ef:	c6 05 cd 53 2a f0 8e 	movb   $0x8e,0xf02a53cd
f01045f6:	c1 e8 10             	shr    $0x10,%eax
f01045f9:	66 a3 ce 53 2a f0    	mov    %ax,0xf02a53ce
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE],      0, GD_KT, (void*)H_IDE,    0);
f01045ff:	b8 28 4d 10 f0       	mov    $0xf0104d28,%eax
f0104604:	66 a3 d0 53 2a f0    	mov    %ax,0xf02a53d0
f010460a:	66 c7 05 d2 53 2a f0 	movw   $0x8,0xf02a53d2
f0104611:	08 00 
f0104613:	c6 05 d4 53 2a f0 00 	movb   $0x0,0xf02a53d4
f010461a:	c6 05 d5 53 2a f0 8e 	movb   $0x8e,0xf02a53d5
f0104621:	c1 e8 10             	shr    $0x10,%eax
f0104624:	66 a3 d6 53 2a f0    	mov    %ax,0xf02a53d6
	SETGATE(idt[IRQ_OFFSET + 15],           0, GD_KT, (void*)H_IRQ15,  0);
f010462a:	b8 2e 4d 10 f0       	mov    $0xf0104d2e,%eax
f010462f:	66 a3 d8 53 2a f0    	mov    %ax,0xf02a53d8
f0104635:	66 c7 05 da 53 2a f0 	movw   $0x8,0xf02a53da
f010463c:	08 00 
f010463e:	c6 05 dc 53 2a f0 00 	movb   $0x0,0xf02a53dc
f0104645:	c6 05 dd 53 2a f0 8e 	movb   $0x8e,0xf02a53dd
f010464c:	c1 e8 10             	shr    $0x10,%eax
f010464f:	66 a3 de 53 2a f0    	mov    %ax,0xf02a53de
	trap_init_percpu();
f0104655:	e8 74 f9 ff ff       	call   f0103fce <trap_init_percpu>
}
f010465a:	c9                   	leave  
f010465b:	c3                   	ret    

f010465c <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f010465c:	55                   	push   %ebp
f010465d:	89 e5                	mov    %esp,%ebp
f010465f:	53                   	push   %ebx
f0104660:	83 ec 0c             	sub    $0xc,%esp
f0104663:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0104666:	ff 33                	pushl  (%ebx)
f0104668:	68 9e 83 10 f0       	push   $0xf010839e
f010466d:	e8 48 f9 ff ff       	call   f0103fba <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104672:	83 c4 08             	add    $0x8,%esp
f0104675:	ff 73 04             	pushl  0x4(%ebx)
f0104678:	68 ad 83 10 f0       	push   $0xf01083ad
f010467d:	e8 38 f9 ff ff       	call   f0103fba <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104682:	83 c4 08             	add    $0x8,%esp
f0104685:	ff 73 08             	pushl  0x8(%ebx)
f0104688:	68 bc 83 10 f0       	push   $0xf01083bc
f010468d:	e8 28 f9 ff ff       	call   f0103fba <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104692:	83 c4 08             	add    $0x8,%esp
f0104695:	ff 73 0c             	pushl  0xc(%ebx)
f0104698:	68 cb 83 10 f0       	push   $0xf01083cb
f010469d:	e8 18 f9 ff ff       	call   f0103fba <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01046a2:	83 c4 08             	add    $0x8,%esp
f01046a5:	ff 73 10             	pushl  0x10(%ebx)
f01046a8:	68 da 83 10 f0       	push   $0xf01083da
f01046ad:	e8 08 f9 ff ff       	call   f0103fba <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01046b2:	83 c4 08             	add    $0x8,%esp
f01046b5:	ff 73 14             	pushl  0x14(%ebx)
f01046b8:	68 e9 83 10 f0       	push   $0xf01083e9
f01046bd:	e8 f8 f8 ff ff       	call   f0103fba <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01046c2:	83 c4 08             	add    $0x8,%esp
f01046c5:	ff 73 18             	pushl  0x18(%ebx)
f01046c8:	68 f8 83 10 f0       	push   $0xf01083f8
f01046cd:	e8 e8 f8 ff ff       	call   f0103fba <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01046d2:	83 c4 08             	add    $0x8,%esp
f01046d5:	ff 73 1c             	pushl  0x1c(%ebx)
f01046d8:	68 07 84 10 f0       	push   $0xf0108407
f01046dd:	e8 d8 f8 ff ff       	call   f0103fba <cprintf>
}
f01046e2:	83 c4 10             	add    $0x10,%esp
f01046e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01046e8:	c9                   	leave  
f01046e9:	c3                   	ret    

f01046ea <print_trapframe>:
{
f01046ea:	55                   	push   %ebp
f01046eb:	89 e5                	mov    %esp,%ebp
f01046ed:	53                   	push   %ebx
f01046ee:	83 ec 04             	sub    $0x4,%esp
f01046f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01046f4:	e8 49 20 00 00       	call   f0106742 <cpunum>
f01046f9:	83 ec 04             	sub    $0x4,%esp
f01046fc:	50                   	push   %eax
f01046fd:	53                   	push   %ebx
f01046fe:	68 6b 84 10 f0       	push   $0xf010846b
f0104703:	e8 b2 f8 ff ff       	call   f0103fba <cprintf>
	print_regs(&tf->tf_regs);
f0104708:	89 1c 24             	mov    %ebx,(%esp)
f010470b:	e8 4c ff ff ff       	call   f010465c <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104710:	83 c4 08             	add    $0x8,%esp
f0104713:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104717:	50                   	push   %eax
f0104718:	68 89 84 10 f0       	push   $0xf0108489
f010471d:	e8 98 f8 ff ff       	call   f0103fba <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104722:	83 c4 08             	add    $0x8,%esp
f0104725:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0104729:	50                   	push   %eax
f010472a:	68 9c 84 10 f0       	push   $0xf010849c
f010472f:	e8 86 f8 ff ff       	call   f0103fba <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104734:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0104737:	83 c4 10             	add    $0x10,%esp
f010473a:	83 f8 13             	cmp    $0x13,%eax
f010473d:	76 1c                	jbe    f010475b <print_trapframe+0x71>
	if (trapno == T_SYSCALL)
f010473f:	83 f8 30             	cmp    $0x30,%eax
f0104742:	0f 84 cf 00 00 00    	je     f0104817 <print_trapframe+0x12d>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104748:	8d 50 e0             	lea    -0x20(%eax),%edx
f010474b:	83 fa 0f             	cmp    $0xf,%edx
f010474e:	0f 86 cd 00 00 00    	jbe    f0104821 <print_trapframe+0x137>
	return "(unknown trap)";
f0104754:	ba 35 84 10 f0       	mov    $0xf0108435,%edx
f0104759:	eb 07                	jmp    f0104762 <print_trapframe+0x78>
		return excnames[trapno];
f010475b:	8b 14 85 40 87 10 f0 	mov    -0xfef78c0(,%eax,4),%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104762:	83 ec 04             	sub    $0x4,%esp
f0104765:	52                   	push   %edx
f0104766:	50                   	push   %eax
f0104767:	68 af 84 10 f0       	push   $0xf01084af
f010476c:	e8 49 f8 ff ff       	call   f0103fba <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104771:	83 c4 10             	add    $0x10,%esp
f0104774:	39 1d 60 5a 2a f0    	cmp    %ebx,0xf02a5a60
f010477a:	0f 84 ab 00 00 00    	je     f010482b <print_trapframe+0x141>
	cprintf("  err  0x%08x", tf->tf_err);
f0104780:	83 ec 08             	sub    $0x8,%esp
f0104783:	ff 73 2c             	pushl  0x2c(%ebx)
f0104786:	68 d0 84 10 f0       	push   $0xf01084d0
f010478b:	e8 2a f8 ff ff       	call   f0103fba <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0104790:	83 c4 10             	add    $0x10,%esp
f0104793:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104797:	0f 85 cf 00 00 00    	jne    f010486c <print_trapframe+0x182>
			tf->tf_err & 1 ? "protection" : "not-present");
f010479d:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f01047a0:	a8 01                	test   $0x1,%al
f01047a2:	0f 85 a6 00 00 00    	jne    f010484e <print_trapframe+0x164>
f01047a8:	b9 4f 84 10 f0       	mov    $0xf010844f,%ecx
f01047ad:	a8 02                	test   $0x2,%al
f01047af:	0f 85 a3 00 00 00    	jne    f0104858 <print_trapframe+0x16e>
f01047b5:	ba 61 84 10 f0       	mov    $0xf0108461,%edx
f01047ba:	a8 04                	test   $0x4,%al
f01047bc:	0f 85 a0 00 00 00    	jne    f0104862 <print_trapframe+0x178>
f01047c2:	b8 9b 85 10 f0       	mov    $0xf010859b,%eax
f01047c7:	51                   	push   %ecx
f01047c8:	52                   	push   %edx
f01047c9:	50                   	push   %eax
f01047ca:	68 de 84 10 f0       	push   $0xf01084de
f01047cf:	e8 e6 f7 ff ff       	call   f0103fba <cprintf>
f01047d4:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01047d7:	83 ec 08             	sub    $0x8,%esp
f01047da:	ff 73 30             	pushl  0x30(%ebx)
f01047dd:	68 ed 84 10 f0       	push   $0xf01084ed
f01047e2:	e8 d3 f7 ff ff       	call   f0103fba <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01047e7:	83 c4 08             	add    $0x8,%esp
f01047ea:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01047ee:	50                   	push   %eax
f01047ef:	68 fc 84 10 f0       	push   $0xf01084fc
f01047f4:	e8 c1 f7 ff ff       	call   f0103fba <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01047f9:	83 c4 08             	add    $0x8,%esp
f01047fc:	ff 73 38             	pushl  0x38(%ebx)
f01047ff:	68 0f 85 10 f0       	push   $0xf010850f
f0104804:	e8 b1 f7 ff ff       	call   f0103fba <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104809:	83 c4 10             	add    $0x10,%esp
f010480c:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104810:	75 6f                	jne    f0104881 <print_trapframe+0x197>
}
f0104812:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104815:	c9                   	leave  
f0104816:	c3                   	ret    
		return "System call";
f0104817:	ba 16 84 10 f0       	mov    $0xf0108416,%edx
f010481c:	e9 41 ff ff ff       	jmp    f0104762 <print_trapframe+0x78>
		return "Hardware Interrupt";
f0104821:	ba 22 84 10 f0       	mov    $0xf0108422,%edx
f0104826:	e9 37 ff ff ff       	jmp    f0104762 <print_trapframe+0x78>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010482b:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010482f:	0f 85 4b ff ff ff    	jne    f0104780 <print_trapframe+0x96>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0104835:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104838:	83 ec 08             	sub    $0x8,%esp
f010483b:	50                   	push   %eax
f010483c:	68 c1 84 10 f0       	push   $0xf01084c1
f0104841:	e8 74 f7 ff ff       	call   f0103fba <cprintf>
f0104846:	83 c4 10             	add    $0x10,%esp
f0104849:	e9 32 ff ff ff       	jmp    f0104780 <print_trapframe+0x96>
		cprintf(" [%s, %s, %s]\n",
f010484e:	b9 44 84 10 f0       	mov    $0xf0108444,%ecx
f0104853:	e9 55 ff ff ff       	jmp    f01047ad <print_trapframe+0xc3>
f0104858:	ba 5b 84 10 f0       	mov    $0xf010845b,%edx
f010485d:	e9 58 ff ff ff       	jmp    f01047ba <print_trapframe+0xd0>
f0104862:	b8 66 84 10 f0       	mov    $0xf0108466,%eax
f0104867:	e9 5b ff ff ff       	jmp    f01047c7 <print_trapframe+0xdd>
		cprintf("\n");
f010486c:	83 ec 0c             	sub    $0xc,%esp
f010486f:	68 1b 72 10 f0       	push   $0xf010721b
f0104874:	e8 41 f7 ff ff       	call   f0103fba <cprintf>
f0104879:	83 c4 10             	add    $0x10,%esp
f010487c:	e9 56 ff ff ff       	jmp    f01047d7 <print_trapframe+0xed>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104881:	83 ec 08             	sub    $0x8,%esp
f0104884:	ff 73 3c             	pushl  0x3c(%ebx)
f0104887:	68 1e 85 10 f0       	push   $0xf010851e
f010488c:	e8 29 f7 ff ff       	call   f0103fba <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104891:	83 c4 08             	add    $0x8,%esp
f0104894:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104898:	50                   	push   %eax
f0104899:	68 2d 85 10 f0       	push   $0xf010852d
f010489e:	e8 17 f7 ff ff       	call   f0103fba <cprintf>
f01048a3:	83 c4 10             	add    $0x10,%esp
}
f01048a6:	e9 67 ff ff ff       	jmp    f0104812 <print_trapframe+0x128>

f01048ab <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01048ab:	55                   	push   %ebp
f01048ac:	89 e5                	mov    %esp,%ebp
f01048ae:	57                   	push   %edi
f01048af:	56                   	push   %esi
f01048b0:	53                   	push   %ebx
f01048b1:	83 ec 1c             	sub    $0x1c,%esp
f01048b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01048b7:	0f 20 d6             	mov    %cr2,%esi

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	uint16_t cs = tf->tf_cs;
	if ((cs & 0xFF) == GD_KT) { // code segment descriptor is kernel
f01048ba:	80 7b 34 08          	cmpb   $0x8,0x34(%ebx)
f01048be:	0f 84 ad 00 00 00    	je     f0104971 <page_fault_handler+0xc6>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').


	if (!curenv->env_pgfault_upcall) {
f01048c4:	e8 79 1e 00 00       	call   f0106742 <cpunum>
f01048c9:	6b c0 74             	imul   $0x74,%eax,%eax
f01048cc:	8b 80 28 60 2a f0    	mov    -0xfd59fd8(%eax),%eax
f01048d2:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f01048d6:	0f 84 b3 00 00 00    	je     f010498f <page_fault_handler+0xe4>
		print_trapframe(tf);
		env_destroy(curenv);
	}

	// Backup the current stack pointer.
	uintptr_t esp = tf->tf_esp;
f01048dc:	8b 4b 3c             	mov    0x3c(%ebx),%ecx
f01048df:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	
	// Get stack point to the right place.
	// Then, check whether the user can write memory there.
	// If not, curenv will be destroyed, and things are simpler.
	if (tf->tf_esp < UXSTACKTOP && tf->tf_esp >= UXSTACKTOP - PGSIZE) {
f01048e2:	8d 81 00 10 40 11    	lea    0x11401000(%ecx),%eax
f01048e8:	3d ff 0f 00 00       	cmp    $0xfff,%eax
f01048ed:	0f 87 e2 00 00 00    	ja     f01049d5 <page_fault_handler+0x12a>
		tf->tf_esp -= 4 + sizeof(struct UTrapframe);
f01048f3:	8d 79 c8             	lea    -0x38(%ecx),%edi
f01048f6:	89 7b 3c             	mov    %edi,0x3c(%ebx)
		user_mem_assert(curenv, (void*)tf->tf_esp, 4 + sizeof(struct UTrapframe), PTE_W | PTE_U);
f01048f9:	e8 44 1e 00 00       	call   f0106742 <cpunum>
f01048fe:	6a 06                	push   $0x6
f0104900:	6a 38                	push   $0x38
f0104902:	57                   	push   %edi
f0104903:	6b c0 74             	imul   $0x74,%eax,%eax
f0104906:	ff b0 28 60 2a f0    	pushl  -0xfd59fd8(%eax)
f010490c:	e8 14 ec ff ff       	call   f0103525 <user_mem_assert>
		// FIXME
		*((uint32_t*)esp - 1) = 0;  // We also set the int padding to 0.
f0104911:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104914:	c7 41 fc 00 00 00 00 	movl   $0x0,-0x4(%ecx)
f010491b:	83 c4 10             	add    $0x10,%esp
		tf->tf_esp = UXSTACKTOP - sizeof(struct UTrapframe);
		user_mem_assert(curenv, (void*)tf->tf_esp, sizeof(struct UTrapframe), PTE_W | PTE_U);
	}

	// Fill in UTrapframe data
	struct UTrapframe* utf = (struct UTrapframe*)tf->tf_esp;
f010491e:	8b 43 3c             	mov    0x3c(%ebx),%eax
	utf->utf_fault_va = fault_va;
f0104921:	89 30                	mov    %esi,(%eax)
	utf->utf_err = tf->tf_err;
f0104923:	8b 53 2c             	mov    0x2c(%ebx),%edx
f0104926:	89 50 04             	mov    %edx,0x4(%eax)
	utf->utf_regs = tf->tf_regs;
f0104929:	8d 78 08             	lea    0x8(%eax),%edi
f010492c:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104931:	89 de                	mov    %ebx,%esi
f0104933:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	utf->utf_eip = tf->tf_eip;
f0104935:	8b 53 30             	mov    0x30(%ebx),%edx
f0104938:	89 50 28             	mov    %edx,0x28(%eax)
	utf->utf_eflags = tf->tf_eflags;
f010493b:	8b 53 38             	mov    0x38(%ebx),%edx
f010493e:	89 50 2c             	mov    %edx,0x2c(%eax)
	utf->utf_esp = esp;
f0104941:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104944:	89 78 30             	mov    %edi,0x30(%eax)

	// Modify trapframe so that upcall is triggered next.
	tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0104947:	e8 f6 1d 00 00       	call   f0106742 <cpunum>
f010494c:	6b c0 74             	imul   $0x74,%eax,%eax
f010494f:	8b 80 28 60 2a f0    	mov    -0xfd59fd8(%eax),%eax
f0104955:	8b 40 64             	mov    0x64(%eax),%eax
f0104958:	89 43 30             	mov    %eax,0x30(%ebx)

	// and then run the upcall.
	env_run(curenv);
f010495b:	e8 e2 1d 00 00       	call   f0106742 <cpunum>
f0104960:	83 ec 0c             	sub    $0xc,%esp
f0104963:	6b c0 74             	imul   $0x74,%eax,%eax
f0104966:	ff b0 28 60 2a f0    	pushl  -0xfd59fd8(%eax)
f010496c:	e8 be f3 ff ff       	call   f0103d2f <env_run>
		print_trapframe(tf);
f0104971:	83 ec 0c             	sub    $0xc,%esp
f0104974:	53                   	push   %ebx
f0104975:	e8 70 fd ff ff       	call   f01046ea <print_trapframe>
		panic("Page fault in kernel mode! Fault addr: %p", fault_va);
f010497a:	56                   	push   %esi
f010497b:	68 e8 86 10 f0       	push   $0xf01086e8
f0104980:	68 5f 01 00 00       	push   $0x15f
f0104985:	68 40 85 10 f0       	push   $0xf0108540
f010498a:	e8 05 b7 ff ff       	call   f0100094 <_panic>
		cprintf("[%08x] user fault va %08x ip %08x\n",
f010498f:	8b 7b 30             	mov    0x30(%ebx),%edi
				curenv->env_id, fault_va, tf->tf_eip);
f0104992:	e8 ab 1d 00 00       	call   f0106742 <cpunum>
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104997:	57                   	push   %edi
f0104998:	56                   	push   %esi
				curenv->env_id, fault_va, tf->tf_eip);
f0104999:	6b c0 74             	imul   $0x74,%eax,%eax
		cprintf("[%08x] user fault va %08x ip %08x\n",
f010499c:	8b 80 28 60 2a f0    	mov    -0xfd59fd8(%eax),%eax
f01049a2:	ff 70 48             	pushl  0x48(%eax)
f01049a5:	68 14 87 10 f0       	push   $0xf0108714
f01049aa:	e8 0b f6 ff ff       	call   f0103fba <cprintf>
		print_trapframe(tf);
f01049af:	89 1c 24             	mov    %ebx,(%esp)
f01049b2:	e8 33 fd ff ff       	call   f01046ea <print_trapframe>
		env_destroy(curenv);
f01049b7:	e8 86 1d 00 00       	call   f0106742 <cpunum>
f01049bc:	83 c4 04             	add    $0x4,%esp
f01049bf:	6b c0 74             	imul   $0x74,%eax,%eax
f01049c2:	ff b0 28 60 2a f0    	pushl  -0xfd59fd8(%eax)
f01049c8:	e8 a5 f2 ff ff       	call   f0103c72 <env_destroy>
f01049cd:	83 c4 10             	add    $0x10,%esp
f01049d0:	e9 07 ff ff ff       	jmp    f01048dc <page_fault_handler+0x31>
		tf->tf_esp = UXSTACKTOP - sizeof(struct UTrapframe);
f01049d5:	c7 43 3c cc ff bf ee 	movl   $0xeebfffcc,0x3c(%ebx)
		user_mem_assert(curenv, (void*)tf->tf_esp, sizeof(struct UTrapframe), PTE_W | PTE_U);
f01049dc:	e8 61 1d 00 00       	call   f0106742 <cpunum>
f01049e1:	6a 06                	push   $0x6
f01049e3:	6a 34                	push   $0x34
f01049e5:	68 cc ff bf ee       	push   $0xeebfffcc
f01049ea:	6b c0 74             	imul   $0x74,%eax,%eax
f01049ed:	ff b0 28 60 2a f0    	pushl  -0xfd59fd8(%eax)
f01049f3:	e8 2d eb ff ff       	call   f0103525 <user_mem_assert>
f01049f8:	83 c4 10             	add    $0x10,%esp
f01049fb:	e9 1e ff ff ff       	jmp    f010491e <page_fault_handler+0x73>

f0104a00 <trap>:
{
f0104a00:	55                   	push   %ebp
f0104a01:	89 e5                	mov    %esp,%ebp
f0104a03:	57                   	push   %edi
f0104a04:	56                   	push   %esi
f0104a05:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f0104a08:	fc                   	cld    
	if (panicstr)
f0104a09:	83 3d 80 5e 2a f0 00 	cmpl   $0x0,0xf02a5e80
f0104a10:	74 01                	je     f0104a13 <trap+0x13>
		asm volatile("hlt");
f0104a12:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104a13:	e8 2a 1d 00 00       	call   f0106742 <cpunum>
f0104a18:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104a1b:	01 c2                	add    %eax,%edx
f0104a1d:	01 d2                	add    %edx,%edx
f0104a1f:	01 c2                	add    %eax,%edx
f0104a21:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104a24:	8d 14 85 04 00 00 00 	lea    0x4(,%eax,4),%edx
	asm volatile("lock; xchgl %0, %1"
f0104a2b:	b8 01 00 00 00       	mov    $0x1,%eax
f0104a30:	f0 87 82 20 60 2a f0 	lock xchg %eax,-0xfd59fe0(%edx)
f0104a37:	83 f8 02             	cmp    $0x2,%eax
f0104a3a:	74 53                	je     f0104a8f <trap+0x8f>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104a3c:	9c                   	pushf  
f0104a3d:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f0104a3e:	f6 c4 02             	test   $0x2,%ah
f0104a41:	75 5e                	jne    f0104aa1 <trap+0xa1>
	if ((tf->tf_cs & 3) == 3) {
f0104a43:	66 8b 46 34          	mov    0x34(%esi),%ax
f0104a47:	83 e0 03             	and    $0x3,%eax
f0104a4a:	66 83 f8 03          	cmp    $0x3,%ax
f0104a4e:	74 6a                	je     f0104aba <trap+0xba>
	last_tf = tf;
f0104a50:	89 35 60 5a 2a f0    	mov    %esi,0xf02a5a60
	switch(tf->tf_trapno){
f0104a56:	8b 46 28             	mov    0x28(%esi),%eax
f0104a59:	83 f8 0e             	cmp    $0xe,%eax
f0104a5c:	0f 84 fd 00 00 00    	je     f0104b5f <trap+0x15f>
f0104a62:	83 f8 30             	cmp    $0x30,%eax
f0104a65:	0f 84 fd 00 00 00    	je     f0104b68 <trap+0x168>
f0104a6b:	83 f8 03             	cmp    $0x3,%eax
f0104a6e:	0f 85 3d 01 00 00    	jne    f0104bb1 <trap+0x1b1>
		print_trapframe(tf);
f0104a74:	83 ec 0c             	sub    $0xc,%esp
f0104a77:	56                   	push   %esi
f0104a78:	e8 6d fc ff ff       	call   f01046ea <print_trapframe>
f0104a7d:	83 c4 10             	add    $0x10,%esp
			monitor(NULL);
f0104a80:	83 ec 0c             	sub    $0xc,%esp
f0104a83:	6a 00                	push   $0x0
f0104a85:	e8 d8 c3 ff ff       	call   f0100e62 <monitor>
f0104a8a:	83 c4 10             	add    $0x10,%esp
f0104a8d:	eb f1                	jmp    f0104a80 <trap+0x80>
	spin_lock(&kernel_lock);
f0104a8f:	83 ec 0c             	sub    $0xc,%esp
f0104a92:	68 c0 33 12 f0       	push   $0xf01233c0
f0104a97:	e8 1a 1f 00 00       	call   f01069b6 <spin_lock>
f0104a9c:	83 c4 10             	add    $0x10,%esp
f0104a9f:	eb 9b                	jmp    f0104a3c <trap+0x3c>
	assert(!(read_eflags() & FL_IF));
f0104aa1:	68 4c 85 10 f0       	push   $0xf010854c
f0104aa6:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0104aab:	68 2b 01 00 00       	push   $0x12b
f0104ab0:	68 40 85 10 f0       	push   $0xf0108540
f0104ab5:	e8 da b5 ff ff       	call   f0100094 <_panic>
f0104aba:	83 ec 0c             	sub    $0xc,%esp
f0104abd:	68 c0 33 12 f0       	push   $0xf01233c0
f0104ac2:	e8 ef 1e 00 00       	call   f01069b6 <spin_lock>
		assert(curenv);
f0104ac7:	e8 76 1c 00 00       	call   f0106742 <cpunum>
f0104acc:	6b c0 74             	imul   $0x74,%eax,%eax
f0104acf:	83 c4 10             	add    $0x10,%esp
f0104ad2:	83 b8 28 60 2a f0 00 	cmpl   $0x0,-0xfd59fd8(%eax)
f0104ad9:	74 3e                	je     f0104b19 <trap+0x119>
		if (curenv->env_status == ENV_DYING) {
f0104adb:	e8 62 1c 00 00       	call   f0106742 <cpunum>
f0104ae0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ae3:	8b 80 28 60 2a f0    	mov    -0xfd59fd8(%eax),%eax
f0104ae9:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104aed:	74 43                	je     f0104b32 <trap+0x132>
		curenv->env_tf = *tf;
f0104aef:	e8 4e 1c 00 00       	call   f0106742 <cpunum>
f0104af4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104af7:	8b 80 28 60 2a f0    	mov    -0xfd59fd8(%eax),%eax
f0104afd:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104b02:	89 c7                	mov    %eax,%edi
f0104b04:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0104b06:	e8 37 1c 00 00       	call   f0106742 <cpunum>
f0104b0b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b0e:	8b b0 28 60 2a f0    	mov    -0xfd59fd8(%eax),%esi
f0104b14:	e9 37 ff ff ff       	jmp    f0104a50 <trap+0x50>
		assert(curenv);
f0104b19:	68 65 85 10 f0       	push   $0xf0108565
f0104b1e:	68 c3 7f 10 f0       	push   $0xf0107fc3
f0104b23:	68 32 01 00 00       	push   $0x132
f0104b28:	68 40 85 10 f0       	push   $0xf0108540
f0104b2d:	e8 62 b5 ff ff       	call   f0100094 <_panic>
			env_free(curenv);
f0104b32:	e8 0b 1c 00 00       	call   f0106742 <cpunum>
f0104b37:	83 ec 0c             	sub    $0xc,%esp
f0104b3a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b3d:	ff b0 28 60 2a f0    	pushl  -0xfd59fd8(%eax)
f0104b43:	e8 65 ef ff ff       	call   f0103aad <env_free>
			curenv = NULL;
f0104b48:	e8 f5 1b 00 00       	call   f0106742 <cpunum>
f0104b4d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b50:	c7 80 28 60 2a f0 00 	movl   $0x0,-0xfd59fd8(%eax)
f0104b57:	00 00 00 
			sched_yield();
f0104b5a:	e8 d5 02 00 00       	call   f0104e34 <sched_yield>
		page_fault_handler(tf);
f0104b5f:	83 ec 0c             	sub    $0xc,%esp
f0104b62:	56                   	push   %esi
f0104b63:	e8 43 fd ff ff       	call   f01048ab <page_fault_handler>
		tf->tf_regs.reg_eax = syscall(
f0104b68:	83 ec 08             	sub    $0x8,%esp
f0104b6b:	ff 76 04             	pushl  0x4(%esi)
f0104b6e:	ff 36                	pushl  (%esi)
f0104b70:	ff 76 10             	pushl  0x10(%esi)
f0104b73:	ff 76 18             	pushl  0x18(%esi)
f0104b76:	ff 76 14             	pushl  0x14(%esi)
f0104b79:	ff 76 1c             	pushl  0x1c(%esi)
f0104b7c:	e8 25 04 00 00       	call   f0104fa6 <syscall>
f0104b81:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104b84:	83 c4 20             	add    $0x20,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104b87:	e8 b6 1b 00 00       	call   f0106742 <cpunum>
f0104b8c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b8f:	83 b8 28 60 2a f0 00 	cmpl   $0x0,-0xfd59fd8(%eax)
f0104b96:	74 14                	je     f0104bac <trap+0x1ac>
f0104b98:	e8 a5 1b 00 00       	call   f0106742 <cpunum>
f0104b9d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ba0:	8b 80 28 60 2a f0    	mov    -0xfd59fd8(%eax),%eax
f0104ba6:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104baa:	74 78                	je     f0104c24 <trap+0x224>
		sched_yield();
f0104bac:	e8 83 02 00 00       	call   f0104e34 <sched_yield>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104bb1:	83 f8 27             	cmp    $0x27,%eax
f0104bb4:	74 33                	je     f0104be9 <trap+0x1e9>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) { 
f0104bb6:	83 f8 20             	cmp    $0x20,%eax
f0104bb9:	74 48                	je     f0104c03 <trap+0x203>
	print_trapframe(tf);
f0104bbb:	83 ec 0c             	sub    $0xc,%esp
f0104bbe:	56                   	push   %esi
f0104bbf:	e8 26 fb ff ff       	call   f01046ea <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104bc4:	83 c4 10             	add    $0x10,%esp
f0104bc7:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104bcc:	74 3f                	je     f0104c0d <trap+0x20d>
		env_destroy(curenv);
f0104bce:	e8 6f 1b 00 00       	call   f0106742 <cpunum>
f0104bd3:	83 ec 0c             	sub    $0xc,%esp
f0104bd6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bd9:	ff b0 28 60 2a f0    	pushl  -0xfd59fd8(%eax)
f0104bdf:	e8 8e f0 ff ff       	call   f0103c72 <env_destroy>
f0104be4:	83 c4 10             	add    $0x10,%esp
f0104be7:	eb 9e                	jmp    f0104b87 <trap+0x187>
		cprintf("Spurious interrupt on irq 7\n");
f0104be9:	83 ec 0c             	sub    $0xc,%esp
f0104bec:	68 6c 85 10 f0       	push   $0xf010856c
f0104bf1:	e8 c4 f3 ff ff       	call   f0103fba <cprintf>
		print_trapframe(tf);
f0104bf6:	89 34 24             	mov    %esi,(%esp)
f0104bf9:	e8 ec fa ff ff       	call   f01046ea <print_trapframe>
f0104bfe:	83 c4 10             	add    $0x10,%esp
f0104c01:	eb 84                	jmp    f0104b87 <trap+0x187>
		lapic_eoi();
f0104c03:	e8 91 1c 00 00       	call   f0106899 <lapic_eoi>
		sched_yield();
f0104c08:	e8 27 02 00 00       	call   f0104e34 <sched_yield>
		panic("unhandled trap in kernel");
f0104c0d:	83 ec 04             	sub    $0x4,%esp
f0104c10:	68 89 85 10 f0       	push   $0xf0108589
f0104c15:	68 11 01 00 00       	push   $0x111
f0104c1a:	68 40 85 10 f0       	push   $0xf0108540
f0104c1f:	e8 70 b4 ff ff       	call   f0100094 <_panic>
		env_run(curenv);
f0104c24:	e8 19 1b 00 00       	call   f0106742 <cpunum>
f0104c29:	83 ec 0c             	sub    $0xc,%esp
f0104c2c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c2f:	ff b0 28 60 2a f0    	pushl  -0xfd59fd8(%eax)
f0104c35:	e8 f5 f0 ff ff       	call   f0103d2f <env_run>

f0104c3a <H_DIVIDE>:
	pushl $(num);							\
	jmp _alltraps

.text

TRAPHANDLER_NOEC(H_DIVIDE , T_DIVIDE)
f0104c3a:	6a 00                	push   $0x0
f0104c3c:	6a 00                	push   $0x0
f0104c3e:	e9 f1 00 00 00       	jmp    f0104d34 <_alltraps>
f0104c43:	90                   	nop

f0104c44 <H_DEBUG>:
TRAPHANDLER_NOEC(H_DEBUG  , T_DEBUG)
f0104c44:	6a 00                	push   $0x0
f0104c46:	6a 01                	push   $0x1
f0104c48:	e9 e7 00 00 00       	jmp    f0104d34 <_alltraps>
f0104c4d:	90                   	nop

f0104c4e <H_NMI>:
TRAPHANDLER_NOEC(H_NMI    , T_NMI)
f0104c4e:	6a 00                	push   $0x0
f0104c50:	6a 02                	push   $0x2
f0104c52:	e9 dd 00 00 00       	jmp    f0104d34 <_alltraps>
f0104c57:	90                   	nop

f0104c58 <H_BRKPT>:
TRAPHANDLER_NOEC(H_BRKPT  , T_BRKPT)
f0104c58:	6a 00                	push   $0x0
f0104c5a:	6a 03                	push   $0x3
f0104c5c:	e9 d3 00 00 00       	jmp    f0104d34 <_alltraps>
f0104c61:	90                   	nop

f0104c62 <H_OFLOW>:
TRAPHANDLER_NOEC(H_OFLOW  , T_OFLOW)
f0104c62:	6a 00                	push   $0x0
f0104c64:	6a 04                	push   $0x4
f0104c66:	e9 c9 00 00 00       	jmp    f0104d34 <_alltraps>
f0104c6b:	90                   	nop

f0104c6c <H_BOUND>:
TRAPHANDLER_NOEC(H_BOUND  , T_BOUND)
f0104c6c:	6a 00                	push   $0x0
f0104c6e:	6a 05                	push   $0x5
f0104c70:	e9 bf 00 00 00       	jmp    f0104d34 <_alltraps>
f0104c75:	90                   	nop

f0104c76 <H_ILLOP>:
TRAPHANDLER_NOEC(H_ILLOP  , T_ILLOP)
f0104c76:	6a 00                	push   $0x0
f0104c78:	6a 06                	push   $0x6
f0104c7a:	e9 b5 00 00 00       	jmp    f0104d34 <_alltraps>
f0104c7f:	90                   	nop

f0104c80 <H_DEVICE>:
TRAPHANDLER_NOEC(H_DEVICE , T_DEVICE)
f0104c80:	6a 00                	push   $0x0
f0104c82:	6a 07                	push   $0x7
f0104c84:	e9 ab 00 00 00       	jmp    f0104d34 <_alltraps>
f0104c89:	90                   	nop

f0104c8a <H_DBLFLT>:
TRAPHANDLER     (H_DBLFLT , T_DBLFLT)	// Error Code const 0
f0104c8a:	6a 08                	push   $0x8
f0104c8c:	e9 a3 00 00 00       	jmp    f0104d34 <_alltraps>
f0104c91:	90                   	nop

f0104c92 <H_TSS>:
TRAPHANDLER     (H_TSS    , T_TSS)
f0104c92:	6a 0a                	push   $0xa
f0104c94:	e9 9b 00 00 00       	jmp    f0104d34 <_alltraps>
f0104c99:	90                   	nop

f0104c9a <H_SEGNP>:
TRAPHANDLER     (H_SEGNP  , T_SEGNP)
f0104c9a:	6a 0b                	push   $0xb
f0104c9c:	e9 93 00 00 00       	jmp    f0104d34 <_alltraps>
f0104ca1:	90                   	nop

f0104ca2 <H_STACK>:
TRAPHANDLER     (H_STACK  , T_STACK)
f0104ca2:	6a 0c                	push   $0xc
f0104ca4:	e9 8b 00 00 00       	jmp    f0104d34 <_alltraps>
f0104ca9:	90                   	nop

f0104caa <H_GPFLT>:
TRAPHANDLER     (H_GPFLT  , T_GPFLT)
f0104caa:	6a 0d                	push   $0xd
f0104cac:	e9 83 00 00 00       	jmp    f0104d34 <_alltraps>
f0104cb1:	90                   	nop

f0104cb2 <H_PGFLT>:
TRAPHANDLER     (H_PGFLT  , T_PGFLT)
f0104cb2:	6a 0e                	push   $0xe
f0104cb4:	eb 7e                	jmp    f0104d34 <_alltraps>

f0104cb6 <H_FPERR>:
TRAPHANDLER_NOEC(H_FPERR  , T_FPERR)
f0104cb6:	6a 00                	push   $0x0
f0104cb8:	6a 10                	push   $0x10
f0104cba:	eb 78                	jmp    f0104d34 <_alltraps>

f0104cbc <H_ALIGN>:
TRAPHANDLER_NOEC(H_ALIGN  , T_ALIGN)
f0104cbc:	6a 00                	push   $0x0
f0104cbe:	6a 11                	push   $0x11
f0104cc0:	eb 72                	jmp    f0104d34 <_alltraps>

f0104cc2 <H_MCHK>:
TRAPHANDLER_NOEC(H_MCHK   , T_MCHK)
f0104cc2:	6a 00                	push   $0x0
f0104cc4:	6a 12                	push   $0x12
f0104cc6:	eb 6c                	jmp    f0104d34 <_alltraps>

f0104cc8 <H_SIMDERR>:
TRAPHANDLER_NOEC(H_SIMDERR, T_SIMDERR)
f0104cc8:	6a 00                	push   $0x0
f0104cca:	6a 13                	push   $0x13
f0104ccc:	eb 66                	jmp    f0104d34 <_alltraps>

f0104cce <H_SYSCALL>:

TRAPHANDLER_NOEC(H_SYSCALL, T_SYSCALL)  // System call.
f0104cce:	6a 00                	push   $0x0
f0104cd0:	6a 30                	push   $0x30
f0104cd2:	eb 60                	jmp    f0104d34 <_alltraps>

f0104cd4 <H_TIMER>:

// IRQ 0 - 15
TRAPHANDLER_NOEC(H_TIMER,  IRQ_OFFSET + IRQ_TIMER)
f0104cd4:	6a 00                	push   $0x0
f0104cd6:	6a 20                	push   $0x20
f0104cd8:	eb 5a                	jmp    f0104d34 <_alltraps>

f0104cda <H_KBD>:
TRAPHANDLER_NOEC(H_KBD,    IRQ_OFFSET + IRQ_KBD)
f0104cda:	6a 00                	push   $0x0
f0104cdc:	6a 21                	push   $0x21
f0104cde:	eb 54                	jmp    f0104d34 <_alltraps>

f0104ce0 <H_IRQ2>:
TRAPHANDLER_NOEC(H_IRQ2,   IRQ_OFFSET + 2)
f0104ce0:	6a 00                	push   $0x0
f0104ce2:	6a 22                	push   $0x22
f0104ce4:	eb 4e                	jmp    f0104d34 <_alltraps>

f0104ce6 <H_IRQ3>:
TRAPHANDLER_NOEC(H_IRQ3,   IRQ_OFFSET + 3)
f0104ce6:	6a 00                	push   $0x0
f0104ce8:	6a 23                	push   $0x23
f0104cea:	eb 48                	jmp    f0104d34 <_alltraps>

f0104cec <H_SERIAL>:
TRAPHANDLER_NOEC(H_SERIAL, IRQ_OFFSET + IRQ_SERIAL)
f0104cec:	6a 00                	push   $0x0
f0104cee:	6a 24                	push   $0x24
f0104cf0:	eb 42                	jmp    f0104d34 <_alltraps>

f0104cf2 <H_IRQ5>:
TRAPHANDLER_NOEC(H_IRQ5,   IRQ_OFFSET + 5)
f0104cf2:	6a 00                	push   $0x0
f0104cf4:	6a 25                	push   $0x25
f0104cf6:	eb 3c                	jmp    f0104d34 <_alltraps>

f0104cf8 <H_IRQ6>:
TRAPHANDLER_NOEC(H_IRQ6,   IRQ_OFFSET + 6)
f0104cf8:	6a 00                	push   $0x0
f0104cfa:	6a 26                	push   $0x26
f0104cfc:	eb 36                	jmp    f0104d34 <_alltraps>

f0104cfe <H_SPUR>:
TRAPHANDLER_NOEC(H_SPUR,   IRQ_OFFSET + IRQ_SPURIOUS)
f0104cfe:	6a 00                	push   $0x0
f0104d00:	6a 27                	push   $0x27
f0104d02:	eb 30                	jmp    f0104d34 <_alltraps>

f0104d04 <H_IRQ8>:
TRAPHANDLER_NOEC(H_IRQ8,   IRQ_OFFSET + 8)
f0104d04:	6a 00                	push   $0x0
f0104d06:	6a 28                	push   $0x28
f0104d08:	eb 2a                	jmp    f0104d34 <_alltraps>

f0104d0a <H_IRQ9>:
TRAPHANDLER_NOEC(H_IRQ9,   IRQ_OFFSET + 9)
f0104d0a:	6a 00                	push   $0x0
f0104d0c:	6a 29                	push   $0x29
f0104d0e:	eb 24                	jmp    f0104d34 <_alltraps>

f0104d10 <H_IRQ10>:
TRAPHANDLER_NOEC(H_IRQ10,  IRQ_OFFSET + 10)
f0104d10:	6a 00                	push   $0x0
f0104d12:	6a 2a                	push   $0x2a
f0104d14:	eb 1e                	jmp    f0104d34 <_alltraps>

f0104d16 <H_IRQ11>:
TRAPHANDLER_NOEC(H_IRQ11,  IRQ_OFFSET + 11)
f0104d16:	6a 00                	push   $0x0
f0104d18:	6a 2b                	push   $0x2b
f0104d1a:	eb 18                	jmp    f0104d34 <_alltraps>

f0104d1c <H_IRQ12>:
TRAPHANDLER_NOEC(H_IRQ12,  IRQ_OFFSET + 12)
f0104d1c:	6a 00                	push   $0x0
f0104d1e:	6a 2c                	push   $0x2c
f0104d20:	eb 12                	jmp    f0104d34 <_alltraps>

f0104d22 <H_IRQ13>:
TRAPHANDLER_NOEC(H_IRQ13,  IRQ_OFFSET + 13)
f0104d22:	6a 00                	push   $0x0
f0104d24:	6a 2d                	push   $0x2d
f0104d26:	eb 0c                	jmp    f0104d34 <_alltraps>

f0104d28 <H_IDE>:
TRAPHANDLER_NOEC(H_IDE,    IRQ_OFFSET + IRQ_IDE)
f0104d28:	6a 00                	push   $0x0
f0104d2a:	6a 2e                	push   $0x2e
f0104d2c:	eb 06                	jmp    f0104d34 <_alltraps>

f0104d2e <H_IRQ15>:
TRAPHANDLER_NOEC(H_IRQ15,  IRQ_OFFSET + 15)
f0104d2e:	6a 00                	push   $0x0
f0104d30:	6a 2f                	push   $0x2f
f0104d32:	eb 00                	jmp    f0104d34 <_alltraps>

f0104d34 <_alltraps>:

_alltraps:
/* Processor has pushed ss, esp, eflags, cs, eip, and [error] */
/* TRAPHANDLER did [error] and trapno */
	pushl  %ds;
f0104d34:	1e                   	push   %ds
	pushl  %es;
f0104d35:	06                   	push   %es
	pushal;
f0104d36:	60                   	pusha  
	movw   $GD_KD, %ax;
f0104d37:	66 b8 10 00          	mov    $0x10,%ax
	movw   %ax   , %ds;
f0104d3b:	8e d8                	mov    %eax,%ds
	movw   %ax   , %es;
f0104d3d:	8e c0                	mov    %eax,%es
	pushl  %esp;
f0104d3f:	54                   	push   %esp
	call   trap
f0104d40:	e8 bb fc ff ff       	call   f0104a00 <trap>

f0104d45 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104d45:	55                   	push   %ebp
f0104d46:	89 e5                	mov    %esp,%ebp
f0104d48:	83 ec 08             	sub    $0x8,%esp
f0104d4b:	a1 48 52 2a f0       	mov    0xf02a5248,%eax
f0104d50:	83 c0 54             	add    $0x54,%eax
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104d53:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104d58:	8b 10                	mov    (%eax),%edx
f0104d5a:	4a                   	dec    %edx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104d5b:	83 fa 02             	cmp    $0x2,%edx
f0104d5e:	76 2b                	jbe    f0104d8b <sched_halt+0x46>
	for (i = 0; i < NENV; i++) {
f0104d60:	41                   	inc    %ecx
f0104d61:	83 c0 7c             	add    $0x7c,%eax
f0104d64:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104d6a:	75 ec                	jne    f0104d58 <sched_halt+0x13>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f0104d6c:	83 ec 0c             	sub    $0xc,%esp
f0104d6f:	68 90 87 10 f0       	push   $0xf0108790
f0104d74:	e8 41 f2 ff ff       	call   f0103fba <cprintf>
f0104d79:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104d7c:	83 ec 0c             	sub    $0xc,%esp
f0104d7f:	6a 00                	push   $0x0
f0104d81:	e8 dc c0 ff ff       	call   f0100e62 <monitor>
f0104d86:	83 c4 10             	add    $0x10,%esp
f0104d89:	eb f1                	jmp    f0104d7c <sched_halt+0x37>
	if (i == NENV) {
f0104d8b:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104d91:	74 d9                	je     f0104d6c <sched_halt+0x27>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104d93:	e8 aa 19 00 00       	call   f0106742 <cpunum>
f0104d98:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104d9b:	01 c2                	add    %eax,%edx
f0104d9d:	01 d2                	add    %edx,%edx
f0104d9f:	01 c2                	add    %eax,%edx
f0104da1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104da4:	c7 04 85 28 60 2a f0 	movl   $0x0,-0xfd59fd8(,%eax,4)
f0104dab:	00 00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104daf:	a1 8c 5e 2a f0       	mov    0xf02a5e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0104db4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104db9:	76 67                	jbe    f0104e22 <sched_halt+0xdd>
	return (physaddr_t)kva - KERNBASE;
f0104dbb:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104dc0:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104dc3:	e8 7a 19 00 00       	call   f0106742 <cpunum>
f0104dc8:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104dcb:	01 c2                	add    %eax,%edx
f0104dcd:	01 d2                	add    %edx,%edx
f0104dcf:	01 c2                	add    %eax,%edx
f0104dd1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104dd4:	8d 14 85 04 00 00 00 	lea    0x4(,%eax,4),%edx
	asm volatile("lock; xchgl %0, %1"
f0104ddb:	b8 02 00 00 00       	mov    $0x2,%eax
f0104de0:	f0 87 82 20 60 2a f0 	lock xchg %eax,-0xfd59fe0(%edx)
	spin_unlock(&kernel_lock);
f0104de7:	83 ec 0c             	sub    $0xc,%esp
f0104dea:	68 c0 33 12 f0       	push   $0xf01233c0
f0104def:	e8 6f 1c 00 00       	call   f0106a63 <spin_unlock>
	asm volatile("pause");
f0104df4:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104df6:	e8 47 19 00 00       	call   f0106742 <cpunum>
f0104dfb:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104dfe:	01 c2                	add    %eax,%edx
f0104e00:	01 d2                	add    %edx,%edx
f0104e02:	01 c2                	add    %eax,%edx
f0104e04:	8d 04 90             	lea    (%eax,%edx,4),%eax
	asm volatile (
f0104e07:	8b 04 85 30 60 2a f0 	mov    -0xfd59fd0(,%eax,4),%eax
f0104e0e:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104e13:	89 c4                	mov    %eax,%esp
f0104e15:	6a 00                	push   $0x0
f0104e17:	6a 00                	push   $0x0
f0104e19:	fb                   	sti    
f0104e1a:	f4                   	hlt    
f0104e1b:	eb fd                	jmp    f0104e1a <sched_halt+0xd5>
}
f0104e1d:	83 c4 10             	add    $0x10,%esp
f0104e20:	c9                   	leave  
f0104e21:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104e22:	50                   	push   %eax
f0104e23:	68 ec 6e 10 f0       	push   $0xf0106eec
f0104e28:	6a 53                	push   $0x53
f0104e2a:	68 b9 87 10 f0       	push   $0xf01087b9
f0104e2f:	e8 60 b2 ff ff       	call   f0100094 <_panic>

f0104e34 <sched_yield>:
{
f0104e34:	55                   	push   %ebp
f0104e35:	89 e5                	mov    %esp,%ebp
f0104e37:	53                   	push   %ebx
f0104e38:	83 ec 04             	sub    $0x4,%esp
	if (!curenv) { 
f0104e3b:	e8 02 19 00 00       	call   f0106742 <cpunum>
f0104e40:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104e43:	01 c2                	add    %eax,%edx
f0104e45:	01 d2                	add    %edx,%edx
f0104e47:	01 c2                	add    %eax,%edx
f0104e49:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e4c:	83 3c 85 28 60 2a f0 	cmpl   $0x0,-0xfd59fd8(,%eax,4)
f0104e53:	00 
f0104e54:	74 29                	je     f0104e7f <sched_yield+0x4b>
		for (idle = curenv + 1; idle < envs + NENV; idle++)
f0104e56:	e8 e7 18 00 00       	call   f0106742 <cpunum>
f0104e5b:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104e5e:	01 c2                	add    %eax,%edx
f0104e60:	01 d2                	add    %edx,%edx
f0104e62:	01 c2                	add    %eax,%edx
f0104e64:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e67:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f0104e6e:	83 c0 7c             	add    $0x7c,%eax
f0104e71:	8b 1d 48 52 2a f0    	mov    0xf02a5248,%ebx
f0104e77:	8d 93 00 f0 01 00    	lea    0x1f000(%ebx),%edx
f0104e7d:	eb 26                	jmp    f0104ea5 <sched_yield+0x71>
		for (idle = envs; idle < envs + NENV; idle++)
f0104e7f:	a1 48 52 2a f0       	mov    0xf02a5248,%eax
f0104e84:	8d 90 00 f0 01 00    	lea    0x1f000(%eax),%edx
f0104e8a:	39 d0                	cmp    %edx,%eax
f0104e8c:	74 76                	je     f0104f04 <sched_yield+0xd0>
			if (idle->env_status == ENV_RUNNABLE)
f0104e8e:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104e92:	74 05                	je     f0104e99 <sched_yield+0x65>
		for (idle = envs; idle < envs + NENV; idle++)
f0104e94:	83 c0 7c             	add    $0x7c,%eax
f0104e97:	eb f1                	jmp    f0104e8a <sched_yield+0x56>
				env_run(idle); // Will not return
f0104e99:	83 ec 0c             	sub    $0xc,%esp
f0104e9c:	50                   	push   %eax
f0104e9d:	e8 8d ee ff ff       	call   f0103d2f <env_run>
		for (idle = curenv + 1; idle < envs + NENV; idle++)
f0104ea2:	83 c0 7c             	add    $0x7c,%eax
f0104ea5:	39 c2                	cmp    %eax,%edx
f0104ea7:	76 18                	jbe    f0104ec1 <sched_yield+0x8d>
			if (idle->env_status == ENV_RUNNABLE)
f0104ea9:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104ead:	75 f3                	jne    f0104ea2 <sched_yield+0x6e>
				env_run(idle); 
f0104eaf:	83 ec 0c             	sub    $0xc,%esp
f0104eb2:	50                   	push   %eax
f0104eb3:	e8 77 ee ff ff       	call   f0103d2f <env_run>
				env_run(idle);
f0104eb8:	83 ec 0c             	sub    $0xc,%esp
f0104ebb:	53                   	push   %ebx
f0104ebc:	e8 6e ee ff ff       	call   f0103d2f <env_run>
		for (idle = envs; idle < curenv ; idle++)
f0104ec1:	e8 7c 18 00 00       	call   f0106742 <cpunum>
f0104ec6:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104ec9:	01 c2                	add    %eax,%edx
f0104ecb:	01 d2                	add    %edx,%edx
f0104ecd:	01 c2                	add    %eax,%edx
f0104ecf:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ed2:	39 1c 85 28 60 2a f0 	cmp    %ebx,-0xfd59fd8(,%eax,4)
f0104ed9:	76 0b                	jbe    f0104ee6 <sched_yield+0xb2>
			if (idle->env_status == ENV_RUNNABLE)
f0104edb:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f0104edf:	74 d7                	je     f0104eb8 <sched_yield+0x84>
		for (idle = envs; idle < curenv ; idle++)
f0104ee1:	83 c3 7c             	add    $0x7c,%ebx
f0104ee4:	eb db                	jmp    f0104ec1 <sched_yield+0x8d>
		if (curenv->env_status == ENV_RUNNING)
f0104ee6:	e8 57 18 00 00       	call   f0106742 <cpunum>
f0104eeb:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104eee:	01 c2                	add    %eax,%edx
f0104ef0:	01 d2                	add    %edx,%edx
f0104ef2:	01 c2                	add    %eax,%edx
f0104ef4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ef7:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f0104efe:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104f02:	74 0a                	je     f0104f0e <sched_yield+0xda>
	sched_halt();
f0104f04:	e8 3c fe ff ff       	call   f0104d45 <sched_halt>
}
f0104f09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104f0c:	c9                   	leave  
f0104f0d:	c3                   	ret    
			env_run(curenv);
f0104f0e:	e8 2f 18 00 00       	call   f0106742 <cpunum>
f0104f13:	83 ec 0c             	sub    $0xc,%esp
f0104f16:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f19:	ff b0 28 60 2a f0    	pushl  -0xfd59fd8(%eax)
f0104f1f:	e8 0b ee ff ff       	call   f0103d2f <env_run>

f0104f24 <sys_ipc_recv>:
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
int
sys_ipc_recv(void *dstva)
{
f0104f24:	55                   	push   %ebp
f0104f25:	89 e5                	mov    %esp,%ebp
f0104f27:	53                   	push   %ebx
f0104f28:	83 ec 04             	sub    $0x4,%esp
f0104f2b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// Willing to receive information.
	curenv->env_ipc_recving = true; 
f0104f2e:	e8 0f 18 00 00       	call   f0106742 <cpunum>
f0104f33:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104f36:	01 c2                	add    %eax,%edx
f0104f38:	01 d2                	add    %edx,%edx
f0104f3a:	01 c2                	add    %eax,%edx
f0104f3c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104f3f:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f0104f46:	c6 40 68 01          	movb   $0x1,0x68(%eax)

	// If willing to receive page but not aligned
	if ((uintptr_t)dstva < UTOP && (uintptr_t)dstva % PGSIZE) 
f0104f4a:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0104f50:	77 08                	ja     f0104f5a <sys_ipc_recv+0x36>
f0104f52:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f0104f58:	75 45                	jne    f0104f9f <sys_ipc_recv+0x7b>
		return -E_INVAL;
	// No matter we want to get page or not, 
	// this statement is ok.
	curenv->env_ipc_dstva = dstva; 
f0104f5a:	e8 e3 17 00 00       	call   f0106742 <cpunum>
f0104f5f:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104f62:	01 c2                	add    %eax,%edx
f0104f64:	01 d2                	add    %edx,%edx
f0104f66:	01 c2                	add    %eax,%edx
f0104f68:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104f6b:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f0104f72:	89 58 6c             	mov    %ebx,0x6c(%eax)

	// Mark not-runnable. Don't run until we receive something.
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104f75:	e8 c8 17 00 00       	call   f0106742 <cpunum>
f0104f7a:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104f7d:	01 c2                	add    %eax,%edx
f0104f7f:	01 d2                	add    %edx,%edx
f0104f81:	01 c2                	add    %eax,%edx
f0104f83:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104f86:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f0104f8d:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	// There used to be a yield here, which is wrong.
	// When the env is continued, it will (surely) not be running 
	// from here, since this is kernel code. 
	// sched_yield();

	return 0;
f0104f94:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104f99:	83 c4 04             	add    $0x4,%esp
f0104f9c:	5b                   	pop    %ebx
f0104f9d:	5d                   	pop    %ebp
f0104f9e:	c3                   	ret    
		return -E_INVAL;
f0104f9f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104fa4:	eb f3                	jmp    f0104f99 <sys_ipc_recv+0x75>

f0104fa6 <syscall>:

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104fa6:	55                   	push   %ebp
f0104fa7:	89 e5                	mov    %esp,%ebp
f0104fa9:	56                   	push   %esi
f0104faa:	53                   	push   %ebx
f0104fab:	83 ec 10             	sub    $0x10,%esp
f0104fae:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	switch (syscallno) {
f0104fb1:	83 f8 0d             	cmp    $0xd,%eax
f0104fb4:	0f 87 11 05 00 00    	ja     f01054cb <syscall+0x525>
f0104fba:	ff 24 85 00 88 10 f0 	jmp    *-0xfef7800(,%eax,4)
	user_mem_assert(curenv, s, len, PTE_U);  // The memory is readable.
f0104fc1:	e8 7c 17 00 00       	call   f0106742 <cpunum>
f0104fc6:	6a 04                	push   $0x4
f0104fc8:	ff 75 10             	pushl  0x10(%ebp)
f0104fcb:	ff 75 0c             	pushl  0xc(%ebp)
f0104fce:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104fd1:	01 c2                	add    %eax,%edx
f0104fd3:	01 d2                	add    %edx,%edx
f0104fd5:	01 c2                	add    %eax,%edx
f0104fd7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104fda:	ff 34 85 28 60 2a f0 	pushl  -0xfd59fd8(,%eax,4)
f0104fe1:	e8 3f e5 ff ff       	call   f0103525 <user_mem_assert>
	cprintf("%.*s", len, s);
f0104fe6:	83 c4 0c             	add    $0xc,%esp
f0104fe9:	ff 75 0c             	pushl  0xc(%ebp)
f0104fec:	ff 75 10             	pushl  0x10(%ebp)
f0104fef:	68 c6 87 10 f0       	push   $0xf01087c6
f0104ff4:	e8 c1 ef ff ff       	call   f0103fba <cprintf>
f0104ff9:	83 c4 10             	add    $0x10,%esp
	case SYS_cputs:
		sys_cputs((const char*)a1, a2);
		return 0;
f0104ffc:	bb 00 00 00 00       	mov    $0x0,%ebx
	case SYS_ipc_recv:
		return sys_ipc_recv((void*)a1);
	default:
		return -E_INVAL;
	}
}
f0105001:	89 d8                	mov    %ebx,%eax
f0105003:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105006:	5b                   	pop    %ebx
f0105007:	5e                   	pop    %esi
f0105008:	5d                   	pop    %ebp
f0105009:	c3                   	ret    
	return cons_getc();
f010500a:	e8 c3 b6 ff ff       	call   f01006d2 <cons_getc>
f010500f:	89 c3                	mov    %eax,%ebx
		return sys_cgetc();
f0105011:	eb ee                	jmp    f0105001 <syscall+0x5b>
	return curenv->env_id;
f0105013:	e8 2a 17 00 00       	call   f0106742 <cpunum>
f0105018:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010501b:	01 c2                	add    %eax,%edx
f010501d:	01 d2                	add    %edx,%edx
f010501f:	01 c2                	add    %eax,%edx
f0105021:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105024:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f010502b:	8b 58 48             	mov    0x48(%eax),%ebx
		return sys_getenvid();
f010502e:	eb d1                	jmp    f0105001 <syscall+0x5b>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0105030:	83 ec 04             	sub    $0x4,%esp
f0105033:	6a 01                	push   $0x1
f0105035:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105038:	50                   	push   %eax
f0105039:	ff 75 0c             	pushl  0xc(%ebp)
f010503c:	e8 30 e5 ff ff       	call   f0103571 <envid2env>
f0105041:	89 c3                	mov    %eax,%ebx
f0105043:	83 c4 10             	add    $0x10,%esp
f0105046:	85 c0                	test   %eax,%eax
f0105048:	78 b7                	js     f0105001 <syscall+0x5b>
	if (e == curenv)
f010504a:	e8 f3 16 00 00       	call   f0106742 <cpunum>
f010504f:	8b 4d f4             	mov    -0xc(%ebp),%ecx
f0105052:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0105055:	01 c2                	add    %eax,%edx
f0105057:	01 d2                	add    %edx,%edx
f0105059:	01 c2                	add    %eax,%edx
f010505b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010505e:	39 0c 85 28 60 2a f0 	cmp    %ecx,-0xfd59fd8(,%eax,4)
f0105065:	74 47                	je     f01050ae <syscall+0x108>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0105067:	8b 59 48             	mov    0x48(%ecx),%ebx
f010506a:	e8 d3 16 00 00       	call   f0106742 <cpunum>
f010506f:	83 ec 04             	sub    $0x4,%esp
f0105072:	53                   	push   %ebx
f0105073:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0105076:	01 c2                	add    %eax,%edx
f0105078:	01 d2                	add    %edx,%edx
f010507a:	01 c2                	add    %eax,%edx
f010507c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010507f:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f0105086:	ff 70 48             	pushl  0x48(%eax)
f0105089:	68 e6 87 10 f0       	push   $0xf01087e6
f010508e:	e8 27 ef ff ff       	call   f0103fba <cprintf>
f0105093:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0105096:	83 ec 0c             	sub    $0xc,%esp
f0105099:	ff 75 f4             	pushl  -0xc(%ebp)
f010509c:	e8 d1 eb ff ff       	call   f0103c72 <env_destroy>
f01050a1:	83 c4 10             	add    $0x10,%esp
	return 0;
f01050a4:	bb 00 00 00 00       	mov    $0x0,%ebx
		return sys_env_destroy(a1);
f01050a9:	e9 53 ff ff ff       	jmp    f0105001 <syscall+0x5b>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01050ae:	e8 8f 16 00 00       	call   f0106742 <cpunum>
f01050b3:	83 ec 08             	sub    $0x8,%esp
f01050b6:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01050b9:	01 c2                	add    %eax,%edx
f01050bb:	01 d2                	add    %edx,%edx
f01050bd:	01 c2                	add    %eax,%edx
f01050bf:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01050c2:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f01050c9:	ff 70 48             	pushl  0x48(%eax)
f01050cc:	68 cb 87 10 f0       	push   $0xf01087cb
f01050d1:	e8 e4 ee ff ff       	call   f0103fba <cprintf>
f01050d6:	83 c4 10             	add    $0x10,%esp
f01050d9:	eb bb                	jmp    f0105096 <syscall+0xf0>
	int r = envid2env(envid, &to_env, 1);  // 1 - Check perm
f01050db:	83 ec 04             	sub    $0x4,%esp
f01050de:	6a 01                	push   $0x1
f01050e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01050e3:	50                   	push   %eax
f01050e4:	ff 75 0c             	pushl  0xc(%ebp)
f01050e7:	e8 85 e4 ff ff       	call   f0103571 <envid2env>
f01050ec:	89 c3                	mov    %eax,%ebx
	if (r)  // -E_BAD_ENV
f01050ee:	83 c4 10             	add    $0x10,%esp
f01050f1:	85 c0                	test   %eax,%eax
f01050f3:	0f 85 08 ff ff ff    	jne    f0105001 <syscall+0x5b>
	if ((uintptr_t)va >= UTOP || (uintptr_t)va % PGSIZE)
f01050f9:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105100:	77 59                	ja     f010515b <syscall+0x1b5>
f0105102:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0105109:	75 5a                	jne    f0105165 <syscall+0x1bf>
	if (~PTE_SYSCALL & perm) 
f010510b:	f7 45 14 f8 f1 ff ff 	testl  $0xfffff1f8,0x14(%ebp)
f0105112:	75 5b                	jne    f010516f <syscall+0x1c9>
	perm |= PTE_U | PTE_P;
f0105114:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0105117:	83 cb 05             	or     $0x5,%ebx
	struct PageInfo* pp = page_alloc(1);
f010511a:	83 ec 0c             	sub    $0xc,%esp
f010511d:	6a 01                	push   $0x1
f010511f:	e8 07 c3 ff ff       	call   f010142b <page_alloc>
f0105124:	89 c6                	mov    %eax,%esi
	if (!pp)  // No free memory
f0105126:	83 c4 10             	add    $0x10,%esp
f0105129:	85 c0                	test   %eax,%eax
f010512b:	74 4c                	je     f0105179 <syscall+0x1d3>
	r = page_insert(to_env->env_pgdir, pp, va, perm);
f010512d:	53                   	push   %ebx
f010512e:	ff 75 10             	pushl  0x10(%ebp)
f0105131:	50                   	push   %eax
f0105132:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105135:	ff 70 60             	pushl  0x60(%eax)
f0105138:	e8 47 c6 ff ff       	call   f0101784 <page_insert>
f010513d:	89 c3                	mov    %eax,%ebx
	if (r) 
f010513f:	83 c4 10             	add    $0x10,%esp
f0105142:	85 c0                	test   %eax,%eax
f0105144:	0f 84 b7 fe ff ff    	je     f0105001 <syscall+0x5b>
		page_free(pp);
f010514a:	83 ec 0c             	sub    $0xc,%esp
f010514d:	56                   	push   %esi
f010514e:	e8 4a c3 ff ff       	call   f010149d <page_free>
f0105153:	83 c4 10             	add    $0x10,%esp
f0105156:	e9 a6 fe ff ff       	jmp    f0105001 <syscall+0x5b>
		return -E_INVAL;
f010515b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105160:	e9 9c fe ff ff       	jmp    f0105001 <syscall+0x5b>
f0105165:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010516a:	e9 92 fe ff ff       	jmp    f0105001 <syscall+0x5b>
		return -E_INVAL;
f010516f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105174:	e9 88 fe ff ff       	jmp    f0105001 <syscall+0x5b>
		return -E_NO_MEM;
f0105179:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
		return sys_page_alloc(a1, (void*)a2, a3);
f010517e:	e9 7e fe ff ff       	jmp    f0105001 <syscall+0x5b>
	r = envid2env(srcenvid, &from_env, 1);  // 1 - Check perm
f0105183:	83 ec 04             	sub    $0x4,%esp
f0105186:	6a 01                	push   $0x1
f0105188:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010518b:	50                   	push   %eax
f010518c:	ff 75 0c             	pushl  0xc(%ebp)
f010518f:	e8 dd e3 ff ff       	call   f0103571 <envid2env>
f0105194:	89 c3                	mov    %eax,%ebx
	if (r)  return r;
f0105196:	83 c4 10             	add    $0x10,%esp
f0105199:	85 c0                	test   %eax,%eax
f010519b:	0f 85 60 fe ff ff    	jne    f0105001 <syscall+0x5b>
	r = envid2env(dstenvid, &to_env, 1);  // 1 - Check perm
f01051a1:	83 ec 04             	sub    $0x4,%esp
f01051a4:	6a 01                	push   $0x1
f01051a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
f01051a9:	50                   	push   %eax
f01051aa:	ff 75 14             	pushl  0x14(%ebp)
f01051ad:	e8 bf e3 ff ff       	call   f0103571 <envid2env>
f01051b2:	89 c3                	mov    %eax,%ebx
	if (r)  return r;
f01051b4:	83 c4 10             	add    $0x10,%esp
f01051b7:	85 c0                	test   %eax,%eax
f01051b9:	0f 85 42 fe ff ff    	jne    f0105001 <syscall+0x5b>
	if (
f01051bf:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01051c6:	77 6a                	ja     f0105232 <syscall+0x28c>
		((uintptr_t)srcva >= UTOP || (uintptr_t)srcva % PGSIZE) || 
f01051c8:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01051cf:	75 6b                	jne    f010523c <syscall+0x296>
f01051d1:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01051d8:	77 6c                	ja     f0105246 <syscall+0x2a0>
		((uintptr_t)dstva >= UTOP || (uintptr_t)dstva % PGSIZE))
f01051da:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f01051e1:	75 6d                	jne    f0105250 <syscall+0x2aa>
	if (~PTE_SYSCALL & perm)
f01051e3:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f01051ea:	75 6e                	jne    f010525a <syscall+0x2b4>
	perm |= PTE_U | PTE_P;
f01051ec:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
f01051ef:	83 cb 05             	or     $0x5,%ebx
	struct PageInfo* pp = page_lookup(from_env->env_pgdir, srcva, &src_pgt);
f01051f2:	83 ec 04             	sub    $0x4,%esp
f01051f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01051f8:	50                   	push   %eax
f01051f9:	ff 75 10             	pushl  0x10(%ebp)
f01051fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01051ff:	ff 70 60             	pushl  0x60(%eax)
f0105202:	e8 74 c4 ff ff       	call   f010167b <page_lookup>
	if ((~*src_pgt & PTE_W) && (perm & PTE_W))
f0105207:	83 c4 10             	add    $0x10,%esp
f010520a:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010520d:	f6 02 02             	testb  $0x2,(%edx)
f0105210:	75 06                	jne    f0105218 <syscall+0x272>
f0105212:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0105216:	75 4c                	jne    f0105264 <syscall+0x2be>
	r = page_insert(to_env->env_pgdir, pp, dstva, perm);
f0105218:	53                   	push   %ebx
f0105219:	ff 75 18             	pushl  0x18(%ebp)
f010521c:	50                   	push   %eax
f010521d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105220:	ff 70 60             	pushl  0x60(%eax)
f0105223:	e8 5c c5 ff ff       	call   f0101784 <page_insert>
f0105228:	89 c3                	mov    %eax,%ebx
f010522a:	83 c4 10             	add    $0x10,%esp
f010522d:	e9 cf fd ff ff       	jmp    f0105001 <syscall+0x5b>
		return -E_INVAL;
f0105232:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105237:	e9 c5 fd ff ff       	jmp    f0105001 <syscall+0x5b>
f010523c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105241:	e9 bb fd ff ff       	jmp    f0105001 <syscall+0x5b>
f0105246:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010524b:	e9 b1 fd ff ff       	jmp    f0105001 <syscall+0x5b>
f0105250:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105255:	e9 a7 fd ff ff       	jmp    f0105001 <syscall+0x5b>
		return -E_INVAL;
f010525a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010525f:	e9 9d fd ff ff       	jmp    f0105001 <syscall+0x5b>
		return -E_INVAL;
f0105264:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
f0105269:	e9 93 fd ff ff       	jmp    f0105001 <syscall+0x5b>
	int r = envid2env(envid, &to_env, 1);  // 1 - Check perm
f010526e:	83 ec 04             	sub    $0x4,%esp
f0105271:	6a 01                	push   $0x1
f0105273:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105276:	50                   	push   %eax
f0105277:	ff 75 0c             	pushl  0xc(%ebp)
f010527a:	e8 f2 e2 ff ff       	call   f0103571 <envid2env>
	if (r)  // -E_BAD_ENV
f010527f:	83 c4 10             	add    $0x10,%esp
f0105282:	85 c0                	test   %eax,%eax
f0105284:	75 26                	jne    f01052ac <syscall+0x306>
	if ((uintptr_t)va >= UTOP || (uintptr_t)va % PGSIZE)
f0105286:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010528d:	77 1d                	ja     f01052ac <syscall+0x306>
f010528f:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0105296:	75 14                	jne    f01052ac <syscall+0x306>
	page_remove(to_env->env_pgdir, va);
f0105298:	83 ec 08             	sub    $0x8,%esp
f010529b:	ff 75 10             	pushl  0x10(%ebp)
f010529e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01052a1:	ff 70 60             	pushl  0x60(%eax)
f01052a4:	e8 81 c4 ff ff       	call   f010172a <page_remove>
f01052a9:	83 c4 10             	add    $0x10,%esp
		return 0;
f01052ac:	bb 00 00 00 00       	mov    $0x0,%ebx
f01052b1:	e9 4b fd ff ff       	jmp    f0105001 <syscall+0x5b>
	int r = env_alloc(&newenv, curenv->env_id);
f01052b6:	e8 87 14 00 00       	call   f0106742 <cpunum>
f01052bb:	83 ec 08             	sub    $0x8,%esp
f01052be:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01052c1:	01 c2                	add    %eax,%edx
f01052c3:	01 d2                	add    %edx,%edx
f01052c5:	01 c2                	add    %eax,%edx
f01052c7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01052ca:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f01052d1:	ff 70 48             	pushl  0x48(%eax)
f01052d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01052d7:	50                   	push   %eax
f01052d8:	e8 c2 e3 ff ff       	call   f010369f <env_alloc>
f01052dd:	89 c3                	mov    %eax,%ebx
	if (r)  // Some error
f01052df:	83 c4 10             	add    $0x10,%esp
f01052e2:	85 c0                	test   %eax,%eax
f01052e4:	0f 85 17 fd ff ff    	jne    f0105001 <syscall+0x5b>
	newenv->env_status = ENV_NOT_RUNNABLE;
f01052ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01052ed:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	memcpy(&newenv->env_tf, &curenv->env_tf, sizeof(struct Trapframe));
f01052f4:	e8 49 14 00 00       	call   f0106742 <cpunum>
f01052f9:	83 ec 04             	sub    $0x4,%esp
f01052fc:	6a 44                	push   $0x44
f01052fe:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0105301:	01 c2                	add    %eax,%edx
f0105303:	01 d2                	add    %edx,%edx
f0105305:	01 c2                	add    %eax,%edx
f0105307:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010530a:	ff 34 85 28 60 2a f0 	pushl  -0xfd59fd8(,%eax,4)
f0105311:	ff 75 f4             	pushl  -0xc(%ebp)
f0105314:	e8 d4 0d 00 00       	call   f01060ed <memcpy>
	newenv->env_tf.tf_regs.reg_eax = 0;
f0105319:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010531c:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return newenv->env_id;
f0105323:	8b 58 48             	mov    0x48(%eax),%ebx
f0105326:	83 c4 10             	add    $0x10,%esp
		return sys_exofork();
f0105329:	e9 d3 fc ff ff       	jmp    f0105001 <syscall+0x5b>
	int r = envid2env(envid, &to_env, 1);  // 1 - Check perm
f010532e:	83 ec 04             	sub    $0x4,%esp
f0105331:	6a 01                	push   $0x1
f0105333:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105336:	50                   	push   %eax
f0105337:	ff 75 0c             	pushl  0xc(%ebp)
f010533a:	e8 32 e2 ff ff       	call   f0103571 <envid2env>
f010533f:	89 c3                	mov    %eax,%ebx
	if (r)  // -E_BAD_ENV
f0105341:	83 c4 10             	add    $0x10,%esp
f0105344:	85 c0                	test   %eax,%eax
f0105346:	0f 85 b5 fc ff ff    	jne    f0105001 <syscall+0x5b>
	if (status > ENV_NOT_RUNNABLE || status < 0) 
f010534c:	83 7d 10 04          	cmpl   $0x4,0x10(%ebp)
f0105350:	77 0e                	ja     f0105360 <syscall+0x3ba>
	to_env->env_status = status;
f0105352:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105355:	8b 75 10             	mov    0x10(%ebp),%esi
f0105358:	89 70 54             	mov    %esi,0x54(%eax)
f010535b:	e9 a1 fc ff ff       	jmp    f0105001 <syscall+0x5b>
		return -E_INVAL;
f0105360:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		return sys_env_set_status(a1, a2);
f0105365:	e9 97 fc ff ff       	jmp    f0105001 <syscall+0x5b>
	int r = envid2env(envid, &to_env, 1);  // 1 - Check perm
f010536a:	83 ec 04             	sub    $0x4,%esp
f010536d:	6a 01                	push   $0x1
f010536f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105372:	50                   	push   %eax
f0105373:	ff 75 0c             	pushl  0xc(%ebp)
f0105376:	e8 f6 e1 ff ff       	call   f0103571 <envid2env>
f010537b:	89 c3                	mov    %eax,%ebx
	if (r)  // -E_BAD_ENV
f010537d:	83 c4 10             	add    $0x10,%esp
f0105380:	85 c0                	test   %eax,%eax
f0105382:	0f 85 79 fc ff ff    	jne    f0105001 <syscall+0x5b>
	to_env->env_pgfault_upcall = func;
f0105388:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010538b:	8b 75 10             	mov    0x10(%ebp),%esi
f010538e:	89 70 64             	mov    %esi,0x64(%eax)
		return sys_env_set_pgfault_upcall(a1, (void*)a2);
f0105391:	e9 6b fc ff ff       	jmp    f0105001 <syscall+0x5b>
	sched_yield();
f0105396:	e8 99 fa ff ff       	call   f0104e34 <sched_yield>
	r = envid2env(envid, &target_env, 0);  // 0 - don't check perm
f010539b:	83 ec 04             	sub    $0x4,%esp
f010539e:	6a 00                	push   $0x0
f01053a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
f01053a3:	50                   	push   %eax
f01053a4:	ff 75 0c             	pushl  0xc(%ebp)
f01053a7:	e8 c5 e1 ff ff       	call   f0103571 <envid2env>
f01053ac:	89 c3                	mov    %eax,%ebx
	if (r)	return r;
f01053ae:	83 c4 10             	add    $0x10,%esp
f01053b1:	85 c0                	test   %eax,%eax
f01053b3:	0f 85 48 fc ff ff    	jne    f0105001 <syscall+0x5b>
	if (!target_env->env_ipc_recving)  // target is not willing to receive
f01053b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01053bc:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f01053c0:	0f 84 e6 00 00 00    	je     f01054ac <syscall+0x506>
	target_env->env_ipc_from = curenv->env_id; 
f01053c6:	e8 77 13 00 00       	call   f0106742 <cpunum>
f01053cb:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f01053ce:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01053d1:	01 c2                	add    %eax,%edx
f01053d3:	01 d2                	add    %edx,%edx
f01053d5:	01 c2                	add    %eax,%edx
f01053d7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01053da:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f01053e1:	8b 40 48             	mov    0x48(%eax),%eax
f01053e4:	89 41 74             	mov    %eax,0x74(%ecx)
	target_env->env_ipc_recving = false;
f01053e7:	c6 41 68 00          	movb   $0x0,0x68(%ecx)
	if ((uintptr_t)srcva >= UTOP || // No page to map
f01053eb:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f01053f2:	77 09                	ja     f01053fd <syscall+0x457>
f01053f4:	81 79 6c ff ff bf ee 	cmpl   $0xeebfffff,0x6c(%ecx)
f01053fb:	76 15                	jbe    f0105412 <syscall+0x46c>
		target_env->env_ipc_value = value;
f01053fd:	8b 45 10             	mov    0x10(%ebp),%eax
f0105400:	89 41 70             	mov    %eax,0x70(%ecx)
	target_env->env_status = ENV_RUNNABLE;
f0105403:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105406:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f010540d:	e9 ef fb ff ff       	jmp    f0105001 <syscall+0x5b>
		if ((uintptr_t)srcva % PGSIZE || 	// check addr aligned
f0105412:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0105419:	75 76                	jne    f0105491 <syscall+0x4eb>
f010541b:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f0105422:	74 0a                	je     f010542e <syscall+0x488>
			return -E_INVAL;
f0105424:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105429:	e9 d3 fb ff ff       	jmp    f0105001 <syscall+0x5b>
		struct PageInfo* pp = page_lookup(curenv->env_pgdir, srcva, &src_pgt);
f010542e:	e8 0f 13 00 00       	call   f0106742 <cpunum>
f0105433:	83 ec 04             	sub    $0x4,%esp
f0105436:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0105439:	52                   	push   %edx
f010543a:	ff 75 14             	pushl  0x14(%ebp)
f010543d:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0105440:	01 c2                	add    %eax,%edx
f0105442:	01 d2                	add    %edx,%edx
f0105444:	01 c2                	add    %eax,%edx
f0105446:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105449:	8b 04 85 28 60 2a f0 	mov    -0xfd59fd8(,%eax,4),%eax
f0105450:	ff 70 60             	pushl  0x60(%eax)
f0105453:	e8 23 c2 ff ff       	call   f010167b <page_lookup>
		if ((~*src_pgt & PTE_W) && (perm & PTE_W))
f0105458:	83 c4 10             	add    $0x10,%esp
f010545b:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010545e:	f6 02 02             	testb  $0x2,(%edx)
f0105461:	75 06                	jne    f0105469 <syscall+0x4c3>
f0105463:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0105467:	75 32                	jne    f010549b <syscall+0x4f5>
		perm |= PTE_U | PTE_P;
f0105469:	8b 75 18             	mov    0x18(%ebp),%esi
f010546c:	83 ce 05             	or     $0x5,%esi
		r = page_insert(target_env->env_pgdir, pp, target_env->env_ipc_dstva, perm);
f010546f:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0105472:	56                   	push   %esi
f0105473:	ff 72 6c             	pushl  0x6c(%edx)
f0105476:	50                   	push   %eax
f0105477:	ff 72 60             	pushl  0x60(%edx)
f010547a:	e8 05 c3 ff ff       	call   f0101784 <page_insert>
		if (r)	return r;
f010547f:	83 c4 10             	add    $0x10,%esp
f0105482:	85 c0                	test   %eax,%eax
f0105484:	75 1f                	jne    f01054a5 <syscall+0x4ff>
		target_env->env_ipc_perm = perm;  // tell the permission
f0105486:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105489:	89 70 78             	mov    %esi,0x78(%eax)
f010548c:	e9 72 ff ff ff       	jmp    f0105403 <syscall+0x45d>
			return -E_INVAL;
f0105491:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105496:	e9 66 fb ff ff       	jmp    f0105001 <syscall+0x5b>
			return -E_INVAL;
f010549b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01054a0:	e9 5c fb ff ff       	jmp    f0105001 <syscall+0x5b>
		if (r)	return r;
f01054a5:	89 c3                	mov    %eax,%ebx
f01054a7:	e9 55 fb ff ff       	jmp    f0105001 <syscall+0x5b>
		return -E_IPC_NOT_RECV;
f01054ac:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
		return sys_ipc_try_send(a1, a2, (void*)a3, a4);
f01054b1:	e9 4b fb ff ff       	jmp    f0105001 <syscall+0x5b>
		return sys_ipc_recv((void*)a1);
f01054b6:	83 ec 0c             	sub    $0xc,%esp
f01054b9:	ff 75 0c             	pushl  0xc(%ebp)
f01054bc:	e8 63 fa ff ff       	call   f0104f24 <sys_ipc_recv>
f01054c1:	89 c3                	mov    %eax,%ebx
f01054c3:	83 c4 10             	add    $0x10,%esp
f01054c6:	e9 36 fb ff ff       	jmp    f0105001 <syscall+0x5b>
		return -E_INVAL;
f01054cb:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01054d0:	e9 2c fb ff ff       	jmp    f0105001 <syscall+0x5b>

f01054d5 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01054d5:	55                   	push   %ebp
f01054d6:	89 e5                	mov    %esp,%ebp
f01054d8:	57                   	push   %edi
f01054d9:	56                   	push   %esi
f01054da:	53                   	push   %ebx
f01054db:	83 ec 14             	sub    $0x14,%esp
f01054de:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01054e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01054e4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01054e7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01054ea:	8b 32                	mov    (%edx),%esi
f01054ec:	8b 01                	mov    (%ecx),%eax
f01054ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01054f1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01054f8:	eb 2f                	jmp    f0105529 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f01054fa:	48                   	dec    %eax
		while (m >= l && stabs[m].n_type != type)
f01054fb:	39 c6                	cmp    %eax,%esi
f01054fd:	7f 4d                	jg     f010554c <stab_binsearch+0x77>
f01054ff:	0f b6 0a             	movzbl (%edx),%ecx
f0105502:	83 ea 0c             	sub    $0xc,%edx
f0105505:	39 f9                	cmp    %edi,%ecx
f0105507:	75 f1                	jne    f01054fa <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105509:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010550c:	01 c2                	add    %eax,%edx
f010550e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105511:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0105515:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105518:	73 37                	jae    f0105551 <stab_binsearch+0x7c>
			*region_left = m;
f010551a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010551d:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f010551f:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0105522:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0105529:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f010552c:	7f 4d                	jg     f010557b <stab_binsearch+0xa6>
		int true_m = (l + r) / 2, m = true_m;
f010552e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105531:	01 f0                	add    %esi,%eax
f0105533:	89 c3                	mov    %eax,%ebx
f0105535:	c1 eb 1f             	shr    $0x1f,%ebx
f0105538:	01 c3                	add    %eax,%ebx
f010553a:	d1 fb                	sar    %ebx
f010553c:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f010553f:	01 d8                	add    %ebx,%eax
f0105541:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105544:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0105548:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f010554a:	eb af                	jmp    f01054fb <stab_binsearch+0x26>
			l = true_m + 1;
f010554c:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f010554f:	eb d8                	jmp    f0105529 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0105551:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105554:	76 12                	jbe    f0105568 <stab_binsearch+0x93>
			*region_right = m - 1;
f0105556:	48                   	dec    %eax
f0105557:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010555a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010555d:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f010555f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105566:	eb c1                	jmp    f0105529 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105568:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010556b:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f010556d:	ff 45 0c             	incl   0xc(%ebp)
f0105570:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0105572:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105579:	eb ae                	jmp    f0105529 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f010557b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010557f:	74 18                	je     f0105599 <stab_binsearch+0xc4>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105581:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105584:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105586:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105589:	8b 0e                	mov    (%esi),%ecx
f010558b:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010558e:	01 c2                	add    %eax,%edx
f0105590:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0105593:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0105597:	eb 0e                	jmp    f01055a7 <stab_binsearch+0xd2>
		*region_right = *region_left - 1;
f0105599:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010559c:	8b 00                	mov    (%eax),%eax
f010559e:	48                   	dec    %eax
f010559f:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01055a2:	89 07                	mov    %eax,(%edi)
f01055a4:	eb 14                	jmp    f01055ba <stab_binsearch+0xe5>
		     l--)
f01055a6:	48                   	dec    %eax
		for (l = *region_right;
f01055a7:	39 c1                	cmp    %eax,%ecx
f01055a9:	7d 0a                	jge    f01055b5 <stab_binsearch+0xe0>
		     l > *region_left && stabs[l].n_type != type;
f01055ab:	0f b6 1a             	movzbl (%edx),%ebx
f01055ae:	83 ea 0c             	sub    $0xc,%edx
f01055b1:	39 fb                	cmp    %edi,%ebx
f01055b3:	75 f1                	jne    f01055a6 <stab_binsearch+0xd1>
			/* do nothing */;
		*region_left = l;
f01055b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01055b8:	89 07                	mov    %eax,(%edi)
	}
}
f01055ba:	83 c4 14             	add    $0x14,%esp
f01055bd:	5b                   	pop    %ebx
f01055be:	5e                   	pop    %esi
f01055bf:	5f                   	pop    %edi
f01055c0:	5d                   	pop    %ebp
f01055c1:	c3                   	ret    

f01055c2 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01055c2:	55                   	push   %ebp
f01055c3:	89 e5                	mov    %esp,%ebp
f01055c5:	57                   	push   %edi
f01055c6:	56                   	push   %esi
f01055c7:	53                   	push   %ebx
f01055c8:	83 ec 4c             	sub    $0x4c,%esp
f01055cb:	8b 75 08             	mov    0x8(%ebp),%esi
f01055ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01055d1:	c7 03 38 88 10 f0    	movl   $0xf0108838,(%ebx)
	info->eip_line = 0;
f01055d7:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01055de:	c7 43 08 38 88 10 f0 	movl   $0xf0108838,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01055e5:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01055ec:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01055ef:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01055f6:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01055fc:	77 1e                	ja     f010561c <debuginfo_eip+0x5a>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f01055fe:	8b 3d 00 00 20 00    	mov    0x200000,%edi
		stab_end = usd->stab_end;
f0105604:	8b 15 04 00 20 00    	mov    0x200004,%edx
		stabstr = usd->stabstr;
f010560a:	a1 08 00 20 00       	mov    0x200008,%eax
f010560f:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0105612:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0105617:	89 45 b8             	mov    %eax,-0x48(%ebp)
f010561a:	eb 18                	jmp    f0105634 <debuginfo_eip+0x72>
		stabstr_end = __STABSTR_END__;
f010561c:	c7 45 b8 af 85 11 f0 	movl   $0xf01185af,-0x48(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0105623:	c7 45 b4 8d 4c 11 f0 	movl   $0xf0114c8d,-0x4c(%ebp)
		stab_end = __STAB_END__;
f010562a:	ba 8c 4c 11 f0       	mov    $0xf0114c8c,%edx
		stabs = __STAB_BEGIN__;
f010562f:	bf d0 8d 10 f0       	mov    $0xf0108dd0,%edi
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105634:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0105637:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
f010563a:	0f 83 9b 01 00 00    	jae    f01057db <debuginfo_eip+0x219>
f0105640:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0105644:	0f 85 98 01 00 00    	jne    f01057e2 <debuginfo_eip+0x220>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010564a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105651:	29 fa                	sub    %edi,%edx
f0105653:	c1 fa 02             	sar    $0x2,%edx
f0105656:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0105659:	8d 04 82             	lea    (%edx,%eax,4),%eax
f010565c:	8d 04 82             	lea    (%edx,%eax,4),%eax
f010565f:	89 c1                	mov    %eax,%ecx
f0105661:	c1 e1 08             	shl    $0x8,%ecx
f0105664:	01 c8                	add    %ecx,%eax
f0105666:	89 c1                	mov    %eax,%ecx
f0105668:	c1 e1 10             	shl    $0x10,%ecx
f010566b:	01 c8                	add    %ecx,%eax
f010566d:	01 c0                	add    %eax,%eax
f010566f:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
f0105673:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105676:	56                   	push   %esi
f0105677:	6a 64                	push   $0x64
f0105679:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010567c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010567f:	89 f8                	mov    %edi,%eax
f0105681:	e8 4f fe ff ff       	call   f01054d5 <stab_binsearch>
	if (lfile == 0)
f0105686:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105689:	83 c4 08             	add    $0x8,%esp
f010568c:	85 c0                	test   %eax,%eax
f010568e:	0f 84 55 01 00 00    	je     f01057e9 <debuginfo_eip+0x227>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105694:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105697:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010569a:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010569d:	56                   	push   %esi
f010569e:	6a 24                	push   $0x24
f01056a0:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01056a3:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01056a6:	89 f8                	mov    %edi,%eax
f01056a8:	e8 28 fe ff ff       	call   f01054d5 <stab_binsearch>

	if (lfun <= rfun) {
f01056ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01056b0:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01056b3:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f01056b6:	83 c4 08             	add    $0x8,%esp
f01056b9:	39 c8                	cmp    %ecx,%eax
f01056bb:	0f 8f 80 00 00 00    	jg     f0105741 <debuginfo_eip+0x17f>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01056c1:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01056c4:	01 c2                	add    %eax,%edx
f01056c6:	8d 14 97             	lea    (%edi,%edx,4),%edx
f01056c9:	89 55 c0             	mov    %edx,-0x40(%ebp)
f01056cc:	8b 0a                	mov    (%edx),%ecx
f01056ce:	89 4d bc             	mov    %ecx,-0x44(%ebp)
f01056d1:	8b 55 b8             	mov    -0x48(%ebp),%edx
f01056d4:	2b 55 b4             	sub    -0x4c(%ebp),%edx
f01056d7:	39 d1                	cmp    %edx,%ecx
f01056d9:	73 06                	jae    f01056e1 <debuginfo_eip+0x11f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01056db:	03 4d b4             	add    -0x4c(%ebp),%ecx
f01056de:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01056e1:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01056e4:	8b 51 08             	mov    0x8(%ecx),%edx
f01056e7:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01056ea:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01056ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01056ef:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01056f2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01056f5:	83 ec 08             	sub    $0x8,%esp
f01056f8:	6a 3a                	push   $0x3a
f01056fa:	ff 73 08             	pushl  0x8(%ebx)
f01056fd:	e8 1a 09 00 00       	call   f010601c <strfind>
f0105702:	2b 43 08             	sub    0x8(%ebx),%eax
f0105705:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// N_SLINE represents text segment
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105708:	83 c4 08             	add    $0x8,%esp
f010570b:	56                   	push   %esi
f010570c:	6a 44                	push   $0x44
f010570e:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105711:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105714:	89 f8                	mov    %edi,%eax
f0105716:	e8 ba fd ff ff       	call   f01054d5 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f010571b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010571e:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0105721:	01 c2                	add    %eax,%edx
f0105723:	c1 e2 02             	shl    $0x2,%edx
f0105726:	0f b7 4c 17 06       	movzwl 0x6(%edi,%edx,1),%ecx
f010572b:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010572e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105731:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0105734:	8d 54 17 04          	lea    0x4(%edi,%edx,1),%edx
f0105738:	83 c4 10             	add    $0x10,%esp
f010573b:	c6 45 c0 00          	movb   $0x0,-0x40(%ebp)
f010573f:	eb 19                	jmp    f010575a <debuginfo_eip+0x198>
		info->eip_fn_addr = addr;
f0105741:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0105744:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105747:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f010574a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010574d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105750:	eb a3                	jmp    f01056f5 <debuginfo_eip+0x133>
f0105752:	48                   	dec    %eax
f0105753:	83 ea 0c             	sub    $0xc,%edx
f0105756:	c6 45 c0 01          	movb   $0x1,-0x40(%ebp)
f010575a:	89 45 bc             	mov    %eax,-0x44(%ebp)
	while (lline >= lfile
f010575d:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0105760:	7f 40                	jg     f01057a2 <debuginfo_eip+0x1e0>
	       && stabs[lline].n_type != N_SOL
f0105762:	8a 0a                	mov    (%edx),%cl
f0105764:	80 f9 84             	cmp    $0x84,%cl
f0105767:	74 19                	je     f0105782 <debuginfo_eip+0x1c0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105769:	80 f9 64             	cmp    $0x64,%cl
f010576c:	75 e4                	jne    f0105752 <debuginfo_eip+0x190>
f010576e:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0105772:	74 de                	je     f0105752 <debuginfo_eip+0x190>
f0105774:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f0105778:	74 0e                	je     f0105788 <debuginfo_eip+0x1c6>
f010577a:	8b 75 bc             	mov    -0x44(%ebp),%esi
f010577d:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0105780:	eb 06                	jmp    f0105788 <debuginfo_eip+0x1c6>
f0105782:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f0105786:	75 35                	jne    f01057bd <debuginfo_eip+0x1fb>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105788:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010578b:	01 d0                	add    %edx,%eax
f010578d:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0105790:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0105793:	8b 75 b4             	mov    -0x4c(%ebp),%esi
f0105796:	29 f0                	sub    %esi,%eax
f0105798:	39 c2                	cmp    %eax,%edx
f010579a:	73 06                	jae    f01057a2 <debuginfo_eip+0x1e0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010579c:	89 f0                	mov    %esi,%eax
f010579e:	01 d0                	add    %edx,%eax
f01057a0:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01057a2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01057a5:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01057a8:	39 f2                	cmp    %esi,%edx
f01057aa:	7d 44                	jge    f01057f0 <debuginfo_eip+0x22e>
		for (lline = lfun + 1;
f01057ac:	42                   	inc    %edx
f01057ad:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01057b0:	89 d0                	mov    %edx,%eax
f01057b2:	8d 0c 12             	lea    (%edx,%edx,1),%ecx
f01057b5:	01 ca                	add    %ecx,%edx
f01057b7:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f01057bb:	eb 08                	jmp    f01057c5 <debuginfo_eip+0x203>
f01057bd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01057c0:	eb c6                	jmp    f0105788 <debuginfo_eip+0x1c6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01057c2:	ff 43 14             	incl   0x14(%ebx)
		for (lline = lfun + 1;
f01057c5:	39 c6                	cmp    %eax,%esi
f01057c7:	7e 34                	jle    f01057fd <debuginfo_eip+0x23b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01057c9:	8a 0a                	mov    (%edx),%cl
f01057cb:	40                   	inc    %eax
f01057cc:	83 c2 0c             	add    $0xc,%edx
f01057cf:	80 f9 a0             	cmp    $0xa0,%cl
f01057d2:	74 ee                	je     f01057c2 <debuginfo_eip+0x200>

	return 0;
f01057d4:	b8 00 00 00 00       	mov    $0x0,%eax
f01057d9:	eb 1a                	jmp    f01057f5 <debuginfo_eip+0x233>
		return -1;
f01057db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057e0:	eb 13                	jmp    f01057f5 <debuginfo_eip+0x233>
f01057e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057e7:	eb 0c                	jmp    f01057f5 <debuginfo_eip+0x233>
		return -1;
f01057e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057ee:	eb 05                	jmp    f01057f5 <debuginfo_eip+0x233>
	return 0;
f01057f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01057f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01057f8:	5b                   	pop    %ebx
f01057f9:	5e                   	pop    %esi
f01057fa:	5f                   	pop    %edi
f01057fb:	5d                   	pop    %ebp
f01057fc:	c3                   	ret    
	return 0;
f01057fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0105802:	eb f1                	jmp    f01057f5 <debuginfo_eip+0x233>

f0105804 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105804:	55                   	push   %ebp
f0105805:	89 e5                	mov    %esp,%ebp
f0105807:	57                   	push   %edi
f0105808:	56                   	push   %esi
f0105809:	53                   	push   %ebx
f010580a:	83 ec 1c             	sub    $0x1c,%esp
f010580d:	89 c7                	mov    %eax,%edi
f010580f:	89 d6                	mov    %edx,%esi
f0105811:	8b 45 08             	mov    0x8(%ebp),%eax
f0105814:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105817:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010581a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010581d:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105820:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105825:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105828:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f010582b:	39 d3                	cmp    %edx,%ebx
f010582d:	72 05                	jb     f0105834 <printnum+0x30>
f010582f:	39 45 10             	cmp    %eax,0x10(%ebp)
f0105832:	77 78                	ja     f01058ac <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105834:	83 ec 0c             	sub    $0xc,%esp
f0105837:	ff 75 18             	pushl  0x18(%ebp)
f010583a:	8b 45 14             	mov    0x14(%ebp),%eax
f010583d:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0105840:	53                   	push   %ebx
f0105841:	ff 75 10             	pushl  0x10(%ebp)
f0105844:	83 ec 08             	sub    $0x8,%esp
f0105847:	ff 75 e4             	pushl  -0x1c(%ebp)
f010584a:	ff 75 e0             	pushl  -0x20(%ebp)
f010584d:	ff 75 dc             	pushl  -0x24(%ebp)
f0105850:	ff 75 d8             	pushl  -0x28(%ebp)
f0105853:	e8 00 13 00 00       	call   f0106b58 <__udivdi3>
f0105858:	83 c4 18             	add    $0x18,%esp
f010585b:	52                   	push   %edx
f010585c:	50                   	push   %eax
f010585d:	89 f2                	mov    %esi,%edx
f010585f:	89 f8                	mov    %edi,%eax
f0105861:	e8 9e ff ff ff       	call   f0105804 <printnum>
f0105866:	83 c4 20             	add    $0x20,%esp
f0105869:	eb 11                	jmp    f010587c <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010586b:	83 ec 08             	sub    $0x8,%esp
f010586e:	56                   	push   %esi
f010586f:	ff 75 18             	pushl  0x18(%ebp)
f0105872:	ff d7                	call   *%edi
f0105874:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0105877:	4b                   	dec    %ebx
f0105878:	85 db                	test   %ebx,%ebx
f010587a:	7f ef                	jg     f010586b <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010587c:	83 ec 08             	sub    $0x8,%esp
f010587f:	56                   	push   %esi
f0105880:	83 ec 04             	sub    $0x4,%esp
f0105883:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105886:	ff 75 e0             	pushl  -0x20(%ebp)
f0105889:	ff 75 dc             	pushl  -0x24(%ebp)
f010588c:	ff 75 d8             	pushl  -0x28(%ebp)
f010588f:	e8 c4 13 00 00       	call   f0106c58 <__umoddi3>
f0105894:	83 c4 14             	add    $0x14,%esp
f0105897:	0f be 80 42 88 10 f0 	movsbl -0xfef77be(%eax),%eax
f010589e:	50                   	push   %eax
f010589f:	ff d7                	call   *%edi
}
f01058a1:	83 c4 10             	add    $0x10,%esp
f01058a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01058a7:	5b                   	pop    %ebx
f01058a8:	5e                   	pop    %esi
f01058a9:	5f                   	pop    %edi
f01058aa:	5d                   	pop    %ebp
f01058ab:	c3                   	ret    
f01058ac:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01058af:	eb c6                	jmp    f0105877 <printnum+0x73>

f01058b1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01058b1:	55                   	push   %ebp
f01058b2:	89 e5                	mov    %esp,%ebp
f01058b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01058b7:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f01058ba:	8b 10                	mov    (%eax),%edx
f01058bc:	3b 50 04             	cmp    0x4(%eax),%edx
f01058bf:	73 0a                	jae    f01058cb <sprintputch+0x1a>
		*b->buf++ = ch;
f01058c1:	8d 4a 01             	lea    0x1(%edx),%ecx
f01058c4:	89 08                	mov    %ecx,(%eax)
f01058c6:	8b 45 08             	mov    0x8(%ebp),%eax
f01058c9:	88 02                	mov    %al,(%edx)
}
f01058cb:	5d                   	pop    %ebp
f01058cc:	c3                   	ret    

f01058cd <printfmt>:
{
f01058cd:	55                   	push   %ebp
f01058ce:	89 e5                	mov    %esp,%ebp
f01058d0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01058d3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01058d6:	50                   	push   %eax
f01058d7:	ff 75 10             	pushl  0x10(%ebp)
f01058da:	ff 75 0c             	pushl  0xc(%ebp)
f01058dd:	ff 75 08             	pushl  0x8(%ebp)
f01058e0:	e8 05 00 00 00       	call   f01058ea <vprintfmt>
}
f01058e5:	83 c4 10             	add    $0x10,%esp
f01058e8:	c9                   	leave  
f01058e9:	c3                   	ret    

f01058ea <vprintfmt>:
{
f01058ea:	55                   	push   %ebp
f01058eb:	89 e5                	mov    %esp,%ebp
f01058ed:	57                   	push   %edi
f01058ee:	56                   	push   %esi
f01058ef:	53                   	push   %ebx
f01058f0:	83 ec 2c             	sub    $0x2c,%esp
f01058f3:	8b 75 08             	mov    0x8(%ebp),%esi
f01058f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01058f9:	8b 7d 10             	mov    0x10(%ebp),%edi
f01058fc:	e9 ac 03 00 00       	jmp    f0105cad <vprintfmt+0x3c3>
		padc = ' ';
f0105901:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0105905:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f010590c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f0105913:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f010591a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f010591f:	8d 47 01             	lea    0x1(%edi),%eax
f0105922:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105925:	8a 17                	mov    (%edi),%dl
f0105927:	8d 42 dd             	lea    -0x23(%edx),%eax
f010592a:	3c 55                	cmp    $0x55,%al
f010592c:	0f 87 fc 03 00 00    	ja     f0105d2e <vprintfmt+0x444>
f0105932:	0f b6 c0             	movzbl %al,%eax
f0105935:	ff 24 85 80 89 10 f0 	jmp    *-0xfef7680(,%eax,4)
f010593c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f010593f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0105943:	eb da                	jmp    f010591f <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0105945:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0105948:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f010594c:	eb d1                	jmp    f010591f <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f010594e:	0f b6 d2             	movzbl %dl,%edx
f0105951:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0105954:	b8 00 00 00 00       	mov    $0x0,%eax
f0105959:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f010595c:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010595f:	01 c0                	add    %eax,%eax
f0105961:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
f0105965:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0105968:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010596b:	83 f9 09             	cmp    $0x9,%ecx
f010596e:	77 52                	ja     f01059c2 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
f0105970:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
f0105971:	eb e9                	jmp    f010595c <vprintfmt+0x72>
			precision = va_arg(ap, int);
f0105973:	8b 45 14             	mov    0x14(%ebp),%eax
f0105976:	8b 00                	mov    (%eax),%eax
f0105978:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010597b:	8b 45 14             	mov    0x14(%ebp),%eax
f010597e:	8d 40 04             	lea    0x4(%eax),%eax
f0105981:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105984:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0105987:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010598b:	79 92                	jns    f010591f <vprintfmt+0x35>
				width = precision, precision = -1;
f010598d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105990:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105993:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f010599a:	eb 83                	jmp    f010591f <vprintfmt+0x35>
f010599c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01059a0:	78 08                	js     f01059aa <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
f01059a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01059a5:	e9 75 ff ff ff       	jmp    f010591f <vprintfmt+0x35>
f01059aa:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01059b1:	eb ef                	jmp    f01059a2 <vprintfmt+0xb8>
f01059b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f01059b6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01059bd:	e9 5d ff ff ff       	jmp    f010591f <vprintfmt+0x35>
f01059c2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01059c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01059c8:	eb bd                	jmp    f0105987 <vprintfmt+0x9d>
			lflag++;
f01059ca:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
f01059cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01059ce:	e9 4c ff ff ff       	jmp    f010591f <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f01059d3:	8b 45 14             	mov    0x14(%ebp),%eax
f01059d6:	8d 78 04             	lea    0x4(%eax),%edi
f01059d9:	83 ec 08             	sub    $0x8,%esp
f01059dc:	53                   	push   %ebx
f01059dd:	ff 30                	pushl  (%eax)
f01059df:	ff d6                	call   *%esi
			break;
f01059e1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01059e4:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01059e7:	e9 be 02 00 00       	jmp    f0105caa <vprintfmt+0x3c0>
			err = va_arg(ap, int);
f01059ec:	8b 45 14             	mov    0x14(%ebp),%eax
f01059ef:	8d 78 04             	lea    0x4(%eax),%edi
f01059f2:	8b 00                	mov    (%eax),%eax
f01059f4:	85 c0                	test   %eax,%eax
f01059f6:	78 2a                	js     f0105a22 <vprintfmt+0x138>
f01059f8:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01059fa:	83 f8 0f             	cmp    $0xf,%eax
f01059fd:	7f 27                	jg     f0105a26 <vprintfmt+0x13c>
f01059ff:	8b 04 85 e0 8a 10 f0 	mov    -0xfef7520(,%eax,4),%eax
f0105a06:	85 c0                	test   %eax,%eax
f0105a08:	74 1c                	je     f0105a26 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
f0105a0a:	50                   	push   %eax
f0105a0b:	68 d5 7f 10 f0       	push   $0xf0107fd5
f0105a10:	53                   	push   %ebx
f0105a11:	56                   	push   %esi
f0105a12:	e8 b6 fe ff ff       	call   f01058cd <printfmt>
f0105a17:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105a1a:	89 7d 14             	mov    %edi,0x14(%ebp)
f0105a1d:	e9 88 02 00 00       	jmp    f0105caa <vprintfmt+0x3c0>
f0105a22:	f7 d8                	neg    %eax
f0105a24:	eb d2                	jmp    f01059f8 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
f0105a26:	52                   	push   %edx
f0105a27:	68 5a 88 10 f0       	push   $0xf010885a
f0105a2c:	53                   	push   %ebx
f0105a2d:	56                   	push   %esi
f0105a2e:	e8 9a fe ff ff       	call   f01058cd <printfmt>
f0105a33:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105a36:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0105a39:	e9 6c 02 00 00       	jmp    f0105caa <vprintfmt+0x3c0>
			if ((p = va_arg(ap, char *)) == NULL)
f0105a3e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a41:	83 c0 04             	add    $0x4,%eax
f0105a44:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0105a47:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a4a:	8b 38                	mov    (%eax),%edi
f0105a4c:	85 ff                	test   %edi,%edi
f0105a4e:	74 18                	je     f0105a68 <vprintfmt+0x17e>
			if (width > 0 && padc != '-')
f0105a50:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105a54:	0f 8e b7 00 00 00    	jle    f0105b11 <vprintfmt+0x227>
f0105a5a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0105a5e:	75 0f                	jne    f0105a6f <vprintfmt+0x185>
f0105a60:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105a63:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0105a66:	eb 6e                	jmp    f0105ad6 <vprintfmt+0x1ec>
				p = "(null)";
f0105a68:	bf 53 88 10 f0       	mov    $0xf0108853,%edi
f0105a6d:	eb e1                	jmp    f0105a50 <vprintfmt+0x166>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105a6f:	83 ec 08             	sub    $0x8,%esp
f0105a72:	ff 75 d0             	pushl  -0x30(%ebp)
f0105a75:	57                   	push   %edi
f0105a76:	e8 57 04 00 00       	call   f0105ed2 <strnlen>
f0105a7b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105a7e:	29 c1                	sub    %eax,%ecx
f0105a80:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0105a83:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105a86:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105a8a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105a8d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105a90:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0105a92:	eb 0d                	jmp    f0105aa1 <vprintfmt+0x1b7>
					putch(padc, putdat);
f0105a94:	83 ec 08             	sub    $0x8,%esp
f0105a97:	53                   	push   %ebx
f0105a98:	ff 75 e0             	pushl  -0x20(%ebp)
f0105a9b:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0105a9d:	4f                   	dec    %edi
f0105a9e:	83 c4 10             	add    $0x10,%esp
f0105aa1:	85 ff                	test   %edi,%edi
f0105aa3:	7f ef                	jg     f0105a94 <vprintfmt+0x1aa>
f0105aa5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105aa8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0105aab:	89 c8                	mov    %ecx,%eax
f0105aad:	85 c9                	test   %ecx,%ecx
f0105aaf:	78 59                	js     f0105b0a <vprintfmt+0x220>
f0105ab1:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0105ab4:	29 c1                	sub    %eax,%ecx
f0105ab6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105ab9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105abc:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0105abf:	eb 15                	jmp    f0105ad6 <vprintfmt+0x1ec>
				if (altflag && (ch < ' ' || ch > '~'))
f0105ac1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105ac5:	75 29                	jne    f0105af0 <vprintfmt+0x206>
					putch(ch, putdat);
f0105ac7:	83 ec 08             	sub    $0x8,%esp
f0105aca:	ff 75 0c             	pushl  0xc(%ebp)
f0105acd:	50                   	push   %eax
f0105ace:	ff d6                	call   *%esi
f0105ad0:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105ad3:	ff 4d e0             	decl   -0x20(%ebp)
f0105ad6:	47                   	inc    %edi
f0105ad7:	8a 57 ff             	mov    -0x1(%edi),%dl
f0105ada:	0f be c2             	movsbl %dl,%eax
f0105add:	85 c0                	test   %eax,%eax
f0105adf:	74 53                	je     f0105b34 <vprintfmt+0x24a>
f0105ae1:	85 db                	test   %ebx,%ebx
f0105ae3:	78 dc                	js     f0105ac1 <vprintfmt+0x1d7>
f0105ae5:	4b                   	dec    %ebx
f0105ae6:	79 d9                	jns    f0105ac1 <vprintfmt+0x1d7>
f0105ae8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105aeb:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105aee:	eb 35                	jmp    f0105b25 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
f0105af0:	0f be d2             	movsbl %dl,%edx
f0105af3:	83 ea 20             	sub    $0x20,%edx
f0105af6:	83 fa 5e             	cmp    $0x5e,%edx
f0105af9:	76 cc                	jbe    f0105ac7 <vprintfmt+0x1dd>
					putch('?', putdat);
f0105afb:	83 ec 08             	sub    $0x8,%esp
f0105afe:	ff 75 0c             	pushl  0xc(%ebp)
f0105b01:	6a 3f                	push   $0x3f
f0105b03:	ff d6                	call   *%esi
f0105b05:	83 c4 10             	add    $0x10,%esp
f0105b08:	eb c9                	jmp    f0105ad3 <vprintfmt+0x1e9>
f0105b0a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b0f:	eb a0                	jmp    f0105ab1 <vprintfmt+0x1c7>
f0105b11:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105b14:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0105b17:	eb bd                	jmp    f0105ad6 <vprintfmt+0x1ec>
				putch(' ', putdat);
f0105b19:	83 ec 08             	sub    $0x8,%esp
f0105b1c:	53                   	push   %ebx
f0105b1d:	6a 20                	push   $0x20
f0105b1f:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0105b21:	4f                   	dec    %edi
f0105b22:	83 c4 10             	add    $0x10,%esp
f0105b25:	85 ff                	test   %edi,%edi
f0105b27:	7f f0                	jg     f0105b19 <vprintfmt+0x22f>
			if ((p = va_arg(ap, char *)) == NULL)
f0105b29:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105b2c:	89 45 14             	mov    %eax,0x14(%ebp)
f0105b2f:	e9 76 01 00 00       	jmp    f0105caa <vprintfmt+0x3c0>
f0105b34:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105b37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105b3a:	eb e9                	jmp    f0105b25 <vprintfmt+0x23b>
	if (lflag >= 2)
f0105b3c:	83 f9 01             	cmp    $0x1,%ecx
f0105b3f:	7e 3f                	jle    f0105b80 <vprintfmt+0x296>
		return va_arg(*ap, long long);
f0105b41:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b44:	8b 50 04             	mov    0x4(%eax),%edx
f0105b47:	8b 00                	mov    (%eax),%eax
f0105b49:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105b4c:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105b4f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b52:	8d 40 08             	lea    0x8(%eax),%eax
f0105b55:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0105b58:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105b5c:	79 5c                	jns    f0105bba <vprintfmt+0x2d0>
				putch('-', putdat);
f0105b5e:	83 ec 08             	sub    $0x8,%esp
f0105b61:	53                   	push   %ebx
f0105b62:	6a 2d                	push   $0x2d
f0105b64:	ff d6                	call   *%esi
				num = -(long long) num;
f0105b66:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105b69:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105b6c:	f7 da                	neg    %edx
f0105b6e:	83 d1 00             	adc    $0x0,%ecx
f0105b71:	f7 d9                	neg    %ecx
f0105b73:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0105b76:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105b7b:	e9 10 01 00 00       	jmp    f0105c90 <vprintfmt+0x3a6>
	else if (lflag)
f0105b80:	85 c9                	test   %ecx,%ecx
f0105b82:	75 1b                	jne    f0105b9f <vprintfmt+0x2b5>
		return va_arg(*ap, int);
f0105b84:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b87:	8b 00                	mov    (%eax),%eax
f0105b89:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105b8c:	89 c1                	mov    %eax,%ecx
f0105b8e:	c1 f9 1f             	sar    $0x1f,%ecx
f0105b91:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105b94:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b97:	8d 40 04             	lea    0x4(%eax),%eax
f0105b9a:	89 45 14             	mov    %eax,0x14(%ebp)
f0105b9d:	eb b9                	jmp    f0105b58 <vprintfmt+0x26e>
		return va_arg(*ap, long);
f0105b9f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ba2:	8b 00                	mov    (%eax),%eax
f0105ba4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105ba7:	89 c1                	mov    %eax,%ecx
f0105ba9:	c1 f9 1f             	sar    $0x1f,%ecx
f0105bac:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105baf:	8b 45 14             	mov    0x14(%ebp),%eax
f0105bb2:	8d 40 04             	lea    0x4(%eax),%eax
f0105bb5:	89 45 14             	mov    %eax,0x14(%ebp)
f0105bb8:	eb 9e                	jmp    f0105b58 <vprintfmt+0x26e>
			num = getint(&ap, lflag);
f0105bba:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105bbd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0105bc0:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105bc5:	e9 c6 00 00 00       	jmp    f0105c90 <vprintfmt+0x3a6>
	if (lflag >= 2)
f0105bca:	83 f9 01             	cmp    $0x1,%ecx
f0105bcd:	7e 18                	jle    f0105be7 <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
f0105bcf:	8b 45 14             	mov    0x14(%ebp),%eax
f0105bd2:	8b 10                	mov    (%eax),%edx
f0105bd4:	8b 48 04             	mov    0x4(%eax),%ecx
f0105bd7:	8d 40 08             	lea    0x8(%eax),%eax
f0105bda:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105bdd:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105be2:	e9 a9 00 00 00       	jmp    f0105c90 <vprintfmt+0x3a6>
	else if (lflag)
f0105be7:	85 c9                	test   %ecx,%ecx
f0105be9:	75 1a                	jne    f0105c05 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned int);
f0105beb:	8b 45 14             	mov    0x14(%ebp),%eax
f0105bee:	8b 10                	mov    (%eax),%edx
f0105bf0:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105bf5:	8d 40 04             	lea    0x4(%eax),%eax
f0105bf8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105bfb:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105c00:	e9 8b 00 00 00       	jmp    f0105c90 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0105c05:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c08:	8b 10                	mov    (%eax),%edx
f0105c0a:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105c0f:	8d 40 04             	lea    0x4(%eax),%eax
f0105c12:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105c15:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105c1a:	eb 74                	jmp    f0105c90 <vprintfmt+0x3a6>
	if (lflag >= 2)
f0105c1c:	83 f9 01             	cmp    $0x1,%ecx
f0105c1f:	7e 15                	jle    f0105c36 <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
f0105c21:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c24:	8b 10                	mov    (%eax),%edx
f0105c26:	8b 48 04             	mov    0x4(%eax),%ecx
f0105c29:	8d 40 08             	lea    0x8(%eax),%eax
f0105c2c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0105c2f:	b8 08 00 00 00       	mov    $0x8,%eax
f0105c34:	eb 5a                	jmp    f0105c90 <vprintfmt+0x3a6>
	else if (lflag)
f0105c36:	85 c9                	test   %ecx,%ecx
f0105c38:	75 17                	jne    f0105c51 <vprintfmt+0x367>
		return va_arg(*ap, unsigned int);
f0105c3a:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c3d:	8b 10                	mov    (%eax),%edx
f0105c3f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105c44:	8d 40 04             	lea    0x4(%eax),%eax
f0105c47:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0105c4a:	b8 08 00 00 00       	mov    $0x8,%eax
f0105c4f:	eb 3f                	jmp    f0105c90 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0105c51:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c54:	8b 10                	mov    (%eax),%edx
f0105c56:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105c5b:	8d 40 04             	lea    0x4(%eax),%eax
f0105c5e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0105c61:	b8 08 00 00 00       	mov    $0x8,%eax
f0105c66:	eb 28                	jmp    f0105c90 <vprintfmt+0x3a6>
			putch('0', putdat);
f0105c68:	83 ec 08             	sub    $0x8,%esp
f0105c6b:	53                   	push   %ebx
f0105c6c:	6a 30                	push   $0x30
f0105c6e:	ff d6                	call   *%esi
			putch('x', putdat);
f0105c70:	83 c4 08             	add    $0x8,%esp
f0105c73:	53                   	push   %ebx
f0105c74:	6a 78                	push   $0x78
f0105c76:	ff d6                	call   *%esi
			num = (unsigned long long)
f0105c78:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c7b:	8b 10                	mov    (%eax),%edx
f0105c7d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0105c82:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0105c85:	8d 40 04             	lea    0x4(%eax),%eax
f0105c88:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105c8b:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0105c90:	83 ec 0c             	sub    $0xc,%esp
f0105c93:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105c97:	57                   	push   %edi
f0105c98:	ff 75 e0             	pushl  -0x20(%ebp)
f0105c9b:	50                   	push   %eax
f0105c9c:	51                   	push   %ecx
f0105c9d:	52                   	push   %edx
f0105c9e:	89 da                	mov    %ebx,%edx
f0105ca0:	89 f0                	mov    %esi,%eax
f0105ca2:	e8 5d fb ff ff       	call   f0105804 <printnum>
			break;
f0105ca7:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0105caa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105cad:	47                   	inc    %edi
f0105cae:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105cb2:	83 f8 25             	cmp    $0x25,%eax
f0105cb5:	0f 84 46 fc ff ff    	je     f0105901 <vprintfmt+0x17>
			if (ch == '\0')
f0105cbb:	85 c0                	test   %eax,%eax
f0105cbd:	0f 84 89 00 00 00    	je     f0105d4c <vprintfmt+0x462>
			putch(ch, putdat);
f0105cc3:	83 ec 08             	sub    $0x8,%esp
f0105cc6:	53                   	push   %ebx
f0105cc7:	50                   	push   %eax
f0105cc8:	ff d6                	call   *%esi
f0105cca:	83 c4 10             	add    $0x10,%esp
f0105ccd:	eb de                	jmp    f0105cad <vprintfmt+0x3c3>
	if (lflag >= 2)
f0105ccf:	83 f9 01             	cmp    $0x1,%ecx
f0105cd2:	7e 15                	jle    f0105ce9 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
f0105cd4:	8b 45 14             	mov    0x14(%ebp),%eax
f0105cd7:	8b 10                	mov    (%eax),%edx
f0105cd9:	8b 48 04             	mov    0x4(%eax),%ecx
f0105cdc:	8d 40 08             	lea    0x8(%eax),%eax
f0105cdf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105ce2:	b8 10 00 00 00       	mov    $0x10,%eax
f0105ce7:	eb a7                	jmp    f0105c90 <vprintfmt+0x3a6>
	else if (lflag)
f0105ce9:	85 c9                	test   %ecx,%ecx
f0105ceb:	75 17                	jne    f0105d04 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned int);
f0105ced:	8b 45 14             	mov    0x14(%ebp),%eax
f0105cf0:	8b 10                	mov    (%eax),%edx
f0105cf2:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105cf7:	8d 40 04             	lea    0x4(%eax),%eax
f0105cfa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105cfd:	b8 10 00 00 00       	mov    $0x10,%eax
f0105d02:	eb 8c                	jmp    f0105c90 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0105d04:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d07:	8b 10                	mov    (%eax),%edx
f0105d09:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105d0e:	8d 40 04             	lea    0x4(%eax),%eax
f0105d11:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105d14:	b8 10 00 00 00       	mov    $0x10,%eax
f0105d19:	e9 72 ff ff ff       	jmp    f0105c90 <vprintfmt+0x3a6>
			putch(ch, putdat);
f0105d1e:	83 ec 08             	sub    $0x8,%esp
f0105d21:	53                   	push   %ebx
f0105d22:	6a 25                	push   $0x25
f0105d24:	ff d6                	call   *%esi
			break;
f0105d26:	83 c4 10             	add    $0x10,%esp
f0105d29:	e9 7c ff ff ff       	jmp    f0105caa <vprintfmt+0x3c0>
			putch('%', putdat);
f0105d2e:	83 ec 08             	sub    $0x8,%esp
f0105d31:	53                   	push   %ebx
f0105d32:	6a 25                	push   $0x25
f0105d34:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105d36:	83 c4 10             	add    $0x10,%esp
f0105d39:	89 f8                	mov    %edi,%eax
f0105d3b:	eb 01                	jmp    f0105d3e <vprintfmt+0x454>
f0105d3d:	48                   	dec    %eax
f0105d3e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0105d42:	75 f9                	jne    f0105d3d <vprintfmt+0x453>
f0105d44:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105d47:	e9 5e ff ff ff       	jmp    f0105caa <vprintfmt+0x3c0>
}
f0105d4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105d4f:	5b                   	pop    %ebx
f0105d50:	5e                   	pop    %esi
f0105d51:	5f                   	pop    %edi
f0105d52:	5d                   	pop    %ebp
f0105d53:	c3                   	ret    

f0105d54 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105d54:	55                   	push   %ebp
f0105d55:	89 e5                	mov    %esp,%ebp
f0105d57:	83 ec 18             	sub    $0x18,%esp
f0105d5a:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d5d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105d60:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105d63:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105d67:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105d6a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105d71:	85 c0                	test   %eax,%eax
f0105d73:	74 26                	je     f0105d9b <vsnprintf+0x47>
f0105d75:	85 d2                	test   %edx,%edx
f0105d77:	7e 29                	jle    f0105da2 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105d79:	ff 75 14             	pushl  0x14(%ebp)
f0105d7c:	ff 75 10             	pushl  0x10(%ebp)
f0105d7f:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105d82:	50                   	push   %eax
f0105d83:	68 b1 58 10 f0       	push   $0xf01058b1
f0105d88:	e8 5d fb ff ff       	call   f01058ea <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105d8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105d90:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105d96:	83 c4 10             	add    $0x10,%esp
}
f0105d99:	c9                   	leave  
f0105d9a:	c3                   	ret    
		return -E_INVAL;
f0105d9b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105da0:	eb f7                	jmp    f0105d99 <vsnprintf+0x45>
f0105da2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105da7:	eb f0                	jmp    f0105d99 <vsnprintf+0x45>

f0105da9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105da9:	55                   	push   %ebp
f0105daa:	89 e5                	mov    %esp,%ebp
f0105dac:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105daf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105db2:	50                   	push   %eax
f0105db3:	ff 75 10             	pushl  0x10(%ebp)
f0105db6:	ff 75 0c             	pushl  0xc(%ebp)
f0105db9:	ff 75 08             	pushl  0x8(%ebp)
f0105dbc:	e8 93 ff ff ff       	call   f0105d54 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105dc1:	c9                   	leave  
f0105dc2:	c3                   	ret    

f0105dc3 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105dc3:	55                   	push   %ebp
f0105dc4:	89 e5                	mov    %esp,%ebp
f0105dc6:	57                   	push   %edi
f0105dc7:	56                   	push   %esi
f0105dc8:	53                   	push   %ebx
f0105dc9:	83 ec 0c             	sub    $0xc,%esp
f0105dcc:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105dcf:	85 c0                	test   %eax,%eax
f0105dd1:	74 11                	je     f0105de4 <readline+0x21>
		cprintf("%s", prompt);
f0105dd3:	83 ec 08             	sub    $0x8,%esp
f0105dd6:	50                   	push   %eax
f0105dd7:	68 d5 7f 10 f0       	push   $0xf0107fd5
f0105ddc:	e8 d9 e1 ff ff       	call   f0103fba <cprintf>
f0105de1:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105de4:	83 ec 0c             	sub    $0xc,%esp
f0105de7:	6a 00                	push   $0x0
f0105de9:	e8 83 aa ff ff       	call   f0100871 <iscons>
f0105dee:	89 c7                	mov    %eax,%edi
f0105df0:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0105df3:	be 00 00 00 00       	mov    $0x0,%esi
f0105df8:	eb 7b                	jmp    f0105e75 <readline+0xb2>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f0105dfa:	83 f8 f8             	cmp    $0xfffffff8,%eax
f0105dfd:	75 07                	jne    f0105e06 <readline+0x43>
				cprintf("read error: %e\n", c);
			return NULL;
f0105dff:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e04:	eb 4f                	jmp    f0105e55 <readline+0x92>
				cprintf("read error: %e\n", c);
f0105e06:	83 ec 08             	sub    $0x8,%esp
f0105e09:	50                   	push   %eax
f0105e0a:	68 3f 8b 10 f0       	push   $0xf0108b3f
f0105e0f:	e8 a6 e1 ff ff       	call   f0103fba <cprintf>
f0105e14:	83 c4 10             	add    $0x10,%esp
			return NULL;
f0105e17:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e1c:	eb 37                	jmp    f0105e55 <readline+0x92>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
			if (echoing)
				cputchar('\b');
f0105e1e:	83 ec 0c             	sub    $0xc,%esp
f0105e21:	6a 08                	push   $0x8
f0105e23:	e8 28 aa ff ff       	call   f0100850 <cputchar>
f0105e28:	83 c4 10             	add    $0x10,%esp
f0105e2b:	eb 47                	jmp    f0105e74 <readline+0xb1>
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
f0105e2d:	83 ec 0c             	sub    $0xc,%esp
f0105e30:	53                   	push   %ebx
f0105e31:	e8 1a aa ff ff       	call   f0100850 <cputchar>
f0105e36:	83 c4 10             	add    $0x10,%esp
f0105e39:	eb 64                	jmp    f0105e9f <readline+0xdc>
			buf[i++] = c;
		} else if (c == '\n' || c == '\r') {
f0105e3b:	83 fb 0a             	cmp    $0xa,%ebx
f0105e3e:	74 05                	je     f0105e45 <readline+0x82>
f0105e40:	83 fb 0d             	cmp    $0xd,%ebx
f0105e43:	75 30                	jne    f0105e75 <readline+0xb2>
			if (echoing)
f0105e45:	85 ff                	test   %edi,%edi
f0105e47:	75 14                	jne    f0105e5d <readline+0x9a>
				cputchar('\n');
			buf[i] = 0;
f0105e49:	c6 86 80 5a 2a f0 00 	movb   $0x0,-0xfd5a580(%esi)
			return buf;
f0105e50:	b8 80 5a 2a f0       	mov    $0xf02a5a80,%eax
		}
	}
}
f0105e55:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105e58:	5b                   	pop    %ebx
f0105e59:	5e                   	pop    %esi
f0105e5a:	5f                   	pop    %edi
f0105e5b:	5d                   	pop    %ebp
f0105e5c:	c3                   	ret    
				cputchar('\n');
f0105e5d:	83 ec 0c             	sub    $0xc,%esp
f0105e60:	6a 0a                	push   $0xa
f0105e62:	e8 e9 a9 ff ff       	call   f0100850 <cputchar>
f0105e67:	83 c4 10             	add    $0x10,%esp
f0105e6a:	eb dd                	jmp    f0105e49 <readline+0x86>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105e6c:	85 f6                	test   %esi,%esi
f0105e6e:	7e 40                	jle    f0105eb0 <readline+0xed>
			if (echoing)
f0105e70:	85 ff                	test   %edi,%edi
f0105e72:	75 aa                	jne    f0105e1e <readline+0x5b>
			i--;
f0105e74:	4e                   	dec    %esi
		c = getchar();
f0105e75:	e8 e6 a9 ff ff       	call   f0100860 <getchar>
f0105e7a:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105e7c:	85 c0                	test   %eax,%eax
f0105e7e:	0f 88 76 ff ff ff    	js     f0105dfa <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105e84:	83 f8 08             	cmp    $0x8,%eax
f0105e87:	74 21                	je     f0105eaa <readline+0xe7>
f0105e89:	83 f8 7f             	cmp    $0x7f,%eax
f0105e8c:	74 de                	je     f0105e6c <readline+0xa9>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105e8e:	83 f8 1f             	cmp    $0x1f,%eax
f0105e91:	7e a8                	jle    f0105e3b <readline+0x78>
f0105e93:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105e99:	7f a0                	jg     f0105e3b <readline+0x78>
			if (echoing)
f0105e9b:	85 ff                	test   %edi,%edi
f0105e9d:	75 8e                	jne    f0105e2d <readline+0x6a>
			buf[i++] = c;
f0105e9f:	88 9e 80 5a 2a f0    	mov    %bl,-0xfd5a580(%esi)
f0105ea5:	8d 76 01             	lea    0x1(%esi),%esi
f0105ea8:	eb cb                	jmp    f0105e75 <readline+0xb2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105eaa:	85 f6                	test   %esi,%esi
f0105eac:	7e c7                	jle    f0105e75 <readline+0xb2>
f0105eae:	eb c0                	jmp    f0105e70 <readline+0xad>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105eb0:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105eb6:	7e e3                	jle    f0105e9b <readline+0xd8>
f0105eb8:	eb bb                	jmp    f0105e75 <readline+0xb2>

f0105eba <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105eba:	55                   	push   %ebp
f0105ebb:	89 e5                	mov    %esp,%ebp
f0105ebd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105ec0:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ec5:	eb 03                	jmp    f0105eca <strlen+0x10>
		n++;
f0105ec7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0105eca:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105ece:	75 f7                	jne    f0105ec7 <strlen+0xd>
	return n;
}
f0105ed0:	5d                   	pop    %ebp
f0105ed1:	c3                   	ret    

f0105ed2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105ed2:	55                   	push   %ebp
f0105ed3:	89 e5                	mov    %esp,%ebp
f0105ed5:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105ed8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105edb:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ee0:	eb 03                	jmp    f0105ee5 <strnlen+0x13>
		n++;
f0105ee2:	83 c2 01             	add    $0x1,%edx
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105ee5:	39 c2                	cmp    %eax,%edx
f0105ee7:	74 08                	je     f0105ef1 <strnlen+0x1f>
f0105ee9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0105eed:	75 f3                	jne    f0105ee2 <strnlen+0x10>
f0105eef:	89 d0                	mov    %edx,%eax
	return n;
}
f0105ef1:	5d                   	pop    %ebp
f0105ef2:	c3                   	ret    

f0105ef3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105ef3:	55                   	push   %ebp
f0105ef4:	89 e5                	mov    %esp,%ebp
f0105ef6:	53                   	push   %ebx
f0105ef7:	8b 45 08             	mov    0x8(%ebp),%eax
f0105efa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105efd:	89 c2                	mov    %eax,%edx
f0105eff:	83 c2 01             	add    $0x1,%edx
f0105f02:	83 c1 01             	add    $0x1,%ecx
f0105f05:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105f09:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105f0c:	84 db                	test   %bl,%bl
f0105f0e:	75 ef                	jne    f0105eff <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105f10:	5b                   	pop    %ebx
f0105f11:	5d                   	pop    %ebp
f0105f12:	c3                   	ret    

f0105f13 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105f13:	55                   	push   %ebp
f0105f14:	89 e5                	mov    %esp,%ebp
f0105f16:	53                   	push   %ebx
f0105f17:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105f1a:	53                   	push   %ebx
f0105f1b:	e8 9a ff ff ff       	call   f0105eba <strlen>
f0105f20:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105f23:	ff 75 0c             	pushl  0xc(%ebp)
f0105f26:	01 d8                	add    %ebx,%eax
f0105f28:	50                   	push   %eax
f0105f29:	e8 c5 ff ff ff       	call   f0105ef3 <strcpy>
	return dst;
}
f0105f2e:	89 d8                	mov    %ebx,%eax
f0105f30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105f33:	c9                   	leave  
f0105f34:	c3                   	ret    

f0105f35 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105f35:	55                   	push   %ebp
f0105f36:	89 e5                	mov    %esp,%ebp
f0105f38:	56                   	push   %esi
f0105f39:	53                   	push   %ebx
f0105f3a:	8b 75 08             	mov    0x8(%ebp),%esi
f0105f3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105f40:	89 f3                	mov    %esi,%ebx
f0105f42:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105f45:	89 f2                	mov    %esi,%edx
f0105f47:	eb 0f                	jmp    f0105f58 <strncpy+0x23>
		*dst++ = *src;
f0105f49:	83 c2 01             	add    $0x1,%edx
f0105f4c:	0f b6 01             	movzbl (%ecx),%eax
f0105f4f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105f52:	80 39 01             	cmpb   $0x1,(%ecx)
f0105f55:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0105f58:	39 da                	cmp    %ebx,%edx
f0105f5a:	75 ed                	jne    f0105f49 <strncpy+0x14>
	}
	return ret;
}
f0105f5c:	89 f0                	mov    %esi,%eax
f0105f5e:	5b                   	pop    %ebx
f0105f5f:	5e                   	pop    %esi
f0105f60:	5d                   	pop    %ebp
f0105f61:	c3                   	ret    

f0105f62 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105f62:	55                   	push   %ebp
f0105f63:	89 e5                	mov    %esp,%ebp
f0105f65:	56                   	push   %esi
f0105f66:	53                   	push   %ebx
f0105f67:	8b 75 08             	mov    0x8(%ebp),%esi
f0105f6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105f6d:	8b 55 10             	mov    0x10(%ebp),%edx
f0105f70:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105f72:	85 d2                	test   %edx,%edx
f0105f74:	74 21                	je     f0105f97 <strlcpy+0x35>
f0105f76:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105f7a:	89 f2                	mov    %esi,%edx
f0105f7c:	eb 09                	jmp    f0105f87 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105f7e:	83 c2 01             	add    $0x1,%edx
f0105f81:	83 c1 01             	add    $0x1,%ecx
f0105f84:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f0105f87:	39 c2                	cmp    %eax,%edx
f0105f89:	74 09                	je     f0105f94 <strlcpy+0x32>
f0105f8b:	0f b6 19             	movzbl (%ecx),%ebx
f0105f8e:	84 db                	test   %bl,%bl
f0105f90:	75 ec                	jne    f0105f7e <strlcpy+0x1c>
f0105f92:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0105f94:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105f97:	29 f0                	sub    %esi,%eax
}
f0105f99:	5b                   	pop    %ebx
f0105f9a:	5e                   	pop    %esi
f0105f9b:	5d                   	pop    %ebp
f0105f9c:	c3                   	ret    

f0105f9d <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105f9d:	55                   	push   %ebp
f0105f9e:	89 e5                	mov    %esp,%ebp
f0105fa0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105fa3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105fa6:	eb 06                	jmp    f0105fae <strcmp+0x11>
		p++, q++;
f0105fa8:	83 c1 01             	add    $0x1,%ecx
f0105fab:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0105fae:	0f b6 01             	movzbl (%ecx),%eax
f0105fb1:	84 c0                	test   %al,%al
f0105fb3:	74 04                	je     f0105fb9 <strcmp+0x1c>
f0105fb5:	3a 02                	cmp    (%edx),%al
f0105fb7:	74 ef                	je     f0105fa8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105fb9:	0f b6 c0             	movzbl %al,%eax
f0105fbc:	0f b6 12             	movzbl (%edx),%edx
f0105fbf:	29 d0                	sub    %edx,%eax
}
f0105fc1:	5d                   	pop    %ebp
f0105fc2:	c3                   	ret    

f0105fc3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105fc3:	55                   	push   %ebp
f0105fc4:	89 e5                	mov    %esp,%ebp
f0105fc6:	53                   	push   %ebx
f0105fc7:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fca:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105fcd:	89 c3                	mov    %eax,%ebx
f0105fcf:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105fd2:	eb 06                	jmp    f0105fda <strncmp+0x17>
		n--, p++, q++;
f0105fd4:	83 c0 01             	add    $0x1,%eax
f0105fd7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0105fda:	39 d8                	cmp    %ebx,%eax
f0105fdc:	74 15                	je     f0105ff3 <strncmp+0x30>
f0105fde:	0f b6 08             	movzbl (%eax),%ecx
f0105fe1:	84 c9                	test   %cl,%cl
f0105fe3:	74 04                	je     f0105fe9 <strncmp+0x26>
f0105fe5:	3a 0a                	cmp    (%edx),%cl
f0105fe7:	74 eb                	je     f0105fd4 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105fe9:	0f b6 00             	movzbl (%eax),%eax
f0105fec:	0f b6 12             	movzbl (%edx),%edx
f0105fef:	29 d0                	sub    %edx,%eax
f0105ff1:	eb 05                	jmp    f0105ff8 <strncmp+0x35>
		return 0;
f0105ff3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105ff8:	5b                   	pop    %ebx
f0105ff9:	5d                   	pop    %ebp
f0105ffa:	c3                   	ret    

f0105ffb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105ffb:	55                   	push   %ebp
f0105ffc:	89 e5                	mov    %esp,%ebp
f0105ffe:	8b 45 08             	mov    0x8(%ebp),%eax
f0106001:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0106005:	eb 07                	jmp    f010600e <strchr+0x13>
		if (*s == c)
f0106007:	38 ca                	cmp    %cl,%dl
f0106009:	74 0f                	je     f010601a <strchr+0x1f>
	for (; *s; s++)
f010600b:	83 c0 01             	add    $0x1,%eax
f010600e:	0f b6 10             	movzbl (%eax),%edx
f0106011:	84 d2                	test   %dl,%dl
f0106013:	75 f2                	jne    f0106007 <strchr+0xc>
			return (char *) s;
	return 0;
f0106015:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010601a:	5d                   	pop    %ebp
f010601b:	c3                   	ret    

f010601c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010601c:	55                   	push   %ebp
f010601d:	89 e5                	mov    %esp,%ebp
f010601f:	8b 45 08             	mov    0x8(%ebp),%eax
f0106022:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0106026:	eb 03                	jmp    f010602b <strfind+0xf>
f0106028:	83 c0 01             	add    $0x1,%eax
f010602b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010602e:	38 ca                	cmp    %cl,%dl
f0106030:	74 04                	je     f0106036 <strfind+0x1a>
f0106032:	84 d2                	test   %dl,%dl
f0106034:	75 f2                	jne    f0106028 <strfind+0xc>
			break;
	return (char *) s;
}
f0106036:	5d                   	pop    %ebp
f0106037:	c3                   	ret    

f0106038 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0106038:	55                   	push   %ebp
f0106039:	89 e5                	mov    %esp,%ebp
f010603b:	57                   	push   %edi
f010603c:	56                   	push   %esi
f010603d:	53                   	push   %ebx
f010603e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106041:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0106044:	85 c9                	test   %ecx,%ecx
f0106046:	74 36                	je     f010607e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0106048:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010604e:	75 28                	jne    f0106078 <memset+0x40>
f0106050:	f6 c1 03             	test   $0x3,%cl
f0106053:	75 23                	jne    f0106078 <memset+0x40>
		c &= 0xFF;
f0106055:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0106059:	89 d3                	mov    %edx,%ebx
f010605b:	c1 e3 08             	shl    $0x8,%ebx
f010605e:	89 d6                	mov    %edx,%esi
f0106060:	c1 e6 18             	shl    $0x18,%esi
f0106063:	89 d0                	mov    %edx,%eax
f0106065:	c1 e0 10             	shl    $0x10,%eax
f0106068:	09 f0                	or     %esi,%eax
f010606a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010606c:	89 d8                	mov    %ebx,%eax
f010606e:	09 d0                	or     %edx,%eax
f0106070:	c1 e9 02             	shr    $0x2,%ecx
f0106073:	fc                   	cld    
f0106074:	f3 ab                	rep stos %eax,%es:(%edi)
f0106076:	eb 06                	jmp    f010607e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0106078:	8b 45 0c             	mov    0xc(%ebp),%eax
f010607b:	fc                   	cld    
f010607c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010607e:	89 f8                	mov    %edi,%eax
f0106080:	5b                   	pop    %ebx
f0106081:	5e                   	pop    %esi
f0106082:	5f                   	pop    %edi
f0106083:	5d                   	pop    %ebp
f0106084:	c3                   	ret    

f0106085 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0106085:	55                   	push   %ebp
f0106086:	89 e5                	mov    %esp,%ebp
f0106088:	57                   	push   %edi
f0106089:	56                   	push   %esi
f010608a:	8b 45 08             	mov    0x8(%ebp),%eax
f010608d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106090:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0106093:	39 c6                	cmp    %eax,%esi
f0106095:	73 35                	jae    f01060cc <memmove+0x47>
f0106097:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010609a:	39 d0                	cmp    %edx,%eax
f010609c:	73 2e                	jae    f01060cc <memmove+0x47>
		s += n;
		d += n;
f010609e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01060a1:	89 d6                	mov    %edx,%esi
f01060a3:	09 fe                	or     %edi,%esi
f01060a5:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01060ab:	75 13                	jne    f01060c0 <memmove+0x3b>
f01060ad:	f6 c1 03             	test   $0x3,%cl
f01060b0:	75 0e                	jne    f01060c0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01060b2:	83 ef 04             	sub    $0x4,%edi
f01060b5:	8d 72 fc             	lea    -0x4(%edx),%esi
f01060b8:	c1 e9 02             	shr    $0x2,%ecx
f01060bb:	fd                   	std    
f01060bc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01060be:	eb 09                	jmp    f01060c9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01060c0:	83 ef 01             	sub    $0x1,%edi
f01060c3:	8d 72 ff             	lea    -0x1(%edx),%esi
f01060c6:	fd                   	std    
f01060c7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01060c9:	fc                   	cld    
f01060ca:	eb 1d                	jmp    f01060e9 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01060cc:	89 f2                	mov    %esi,%edx
f01060ce:	09 c2                	or     %eax,%edx
f01060d0:	f6 c2 03             	test   $0x3,%dl
f01060d3:	75 0f                	jne    f01060e4 <memmove+0x5f>
f01060d5:	f6 c1 03             	test   $0x3,%cl
f01060d8:	75 0a                	jne    f01060e4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01060da:	c1 e9 02             	shr    $0x2,%ecx
f01060dd:	89 c7                	mov    %eax,%edi
f01060df:	fc                   	cld    
f01060e0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01060e2:	eb 05                	jmp    f01060e9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01060e4:	89 c7                	mov    %eax,%edi
f01060e6:	fc                   	cld    
f01060e7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01060e9:	5e                   	pop    %esi
f01060ea:	5f                   	pop    %edi
f01060eb:	5d                   	pop    %ebp
f01060ec:	c3                   	ret    

f01060ed <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01060ed:	55                   	push   %ebp
f01060ee:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01060f0:	ff 75 10             	pushl  0x10(%ebp)
f01060f3:	ff 75 0c             	pushl  0xc(%ebp)
f01060f6:	ff 75 08             	pushl  0x8(%ebp)
f01060f9:	e8 87 ff ff ff       	call   f0106085 <memmove>
}
f01060fe:	c9                   	leave  
f01060ff:	c3                   	ret    

f0106100 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0106100:	55                   	push   %ebp
f0106101:	89 e5                	mov    %esp,%ebp
f0106103:	56                   	push   %esi
f0106104:	53                   	push   %ebx
f0106105:	8b 45 08             	mov    0x8(%ebp),%eax
f0106108:	8b 55 0c             	mov    0xc(%ebp),%edx
f010610b:	89 c6                	mov    %eax,%esi
f010610d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0106110:	eb 1a                	jmp    f010612c <memcmp+0x2c>
		if (*s1 != *s2)
f0106112:	0f b6 08             	movzbl (%eax),%ecx
f0106115:	0f b6 1a             	movzbl (%edx),%ebx
f0106118:	38 d9                	cmp    %bl,%cl
f010611a:	74 0a                	je     f0106126 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010611c:	0f b6 c1             	movzbl %cl,%eax
f010611f:	0f b6 db             	movzbl %bl,%ebx
f0106122:	29 d8                	sub    %ebx,%eax
f0106124:	eb 0f                	jmp    f0106135 <memcmp+0x35>
		s1++, s2++;
f0106126:	83 c0 01             	add    $0x1,%eax
f0106129:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f010612c:	39 f0                	cmp    %esi,%eax
f010612e:	75 e2                	jne    f0106112 <memcmp+0x12>
	}

	return 0;
f0106130:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106135:	5b                   	pop    %ebx
f0106136:	5e                   	pop    %esi
f0106137:	5d                   	pop    %ebp
f0106138:	c3                   	ret    

f0106139 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0106139:	55                   	push   %ebp
f010613a:	89 e5                	mov    %esp,%ebp
f010613c:	53                   	push   %ebx
f010613d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0106140:	89 c1                	mov    %eax,%ecx
f0106142:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0106145:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
	for (; s < ends; s++)
f0106149:	eb 0a                	jmp    f0106155 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010614b:	0f b6 10             	movzbl (%eax),%edx
f010614e:	39 da                	cmp    %ebx,%edx
f0106150:	74 07                	je     f0106159 <memfind+0x20>
	for (; s < ends; s++)
f0106152:	83 c0 01             	add    $0x1,%eax
f0106155:	39 c8                	cmp    %ecx,%eax
f0106157:	72 f2                	jb     f010614b <memfind+0x12>
			break;
	return (void *) s;
}
f0106159:	5b                   	pop    %ebx
f010615a:	5d                   	pop    %ebp
f010615b:	c3                   	ret    

f010615c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010615c:	55                   	push   %ebp
f010615d:	89 e5                	mov    %esp,%ebp
f010615f:	57                   	push   %edi
f0106160:	56                   	push   %esi
f0106161:	53                   	push   %ebx
f0106162:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106165:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106168:	eb 03                	jmp    f010616d <strtol+0x11>
		s++;
f010616a:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f010616d:	0f b6 01             	movzbl (%ecx),%eax
f0106170:	3c 20                	cmp    $0x20,%al
f0106172:	74 f6                	je     f010616a <strtol+0xe>
f0106174:	3c 09                	cmp    $0x9,%al
f0106176:	74 f2                	je     f010616a <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0106178:	3c 2b                	cmp    $0x2b,%al
f010617a:	75 0a                	jne    f0106186 <strtol+0x2a>
		s++;
f010617c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f010617f:	bf 00 00 00 00       	mov    $0x0,%edi
f0106184:	eb 11                	jmp    f0106197 <strtol+0x3b>
f0106186:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
f010618b:	3c 2d                	cmp    $0x2d,%al
f010618d:	75 08                	jne    f0106197 <strtol+0x3b>
		s++, neg = 1;
f010618f:	83 c1 01             	add    $0x1,%ecx
f0106192:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106197:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010619d:	75 15                	jne    f01061b4 <strtol+0x58>
f010619f:	80 39 30             	cmpb   $0x30,(%ecx)
f01061a2:	75 10                	jne    f01061b4 <strtol+0x58>
f01061a4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01061a8:	75 7c                	jne    f0106226 <strtol+0xca>
		s += 2, base = 16;
f01061aa:	83 c1 02             	add    $0x2,%ecx
f01061ad:	bb 10 00 00 00       	mov    $0x10,%ebx
f01061b2:	eb 16                	jmp    f01061ca <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01061b4:	85 db                	test   %ebx,%ebx
f01061b6:	75 12                	jne    f01061ca <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01061b8:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f01061bd:	80 39 30             	cmpb   $0x30,(%ecx)
f01061c0:	75 08                	jne    f01061ca <strtol+0x6e>
		s++, base = 8;
f01061c2:	83 c1 01             	add    $0x1,%ecx
f01061c5:	bb 08 00 00 00       	mov    $0x8,%ebx
		base = 10;
f01061ca:	b8 00 00 00 00       	mov    $0x0,%eax
f01061cf:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01061d2:	0f b6 11             	movzbl (%ecx),%edx
f01061d5:	8d 72 d0             	lea    -0x30(%edx),%esi
f01061d8:	89 f3                	mov    %esi,%ebx
f01061da:	80 fb 09             	cmp    $0x9,%bl
f01061dd:	77 08                	ja     f01061e7 <strtol+0x8b>
			dig = *s - '0';
f01061df:	0f be d2             	movsbl %dl,%edx
f01061e2:	83 ea 30             	sub    $0x30,%edx
f01061e5:	eb 22                	jmp    f0106209 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01061e7:	8d 72 9f             	lea    -0x61(%edx),%esi
f01061ea:	89 f3                	mov    %esi,%ebx
f01061ec:	80 fb 19             	cmp    $0x19,%bl
f01061ef:	77 08                	ja     f01061f9 <strtol+0x9d>
			dig = *s - 'a' + 10;
f01061f1:	0f be d2             	movsbl %dl,%edx
f01061f4:	83 ea 57             	sub    $0x57,%edx
f01061f7:	eb 10                	jmp    f0106209 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01061f9:	8d 72 bf             	lea    -0x41(%edx),%esi
f01061fc:	89 f3                	mov    %esi,%ebx
f01061fe:	80 fb 19             	cmp    $0x19,%bl
f0106201:	77 16                	ja     f0106219 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0106203:	0f be d2             	movsbl %dl,%edx
f0106206:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0106209:	3b 55 10             	cmp    0x10(%ebp),%edx
f010620c:	7d 0b                	jge    f0106219 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010620e:	83 c1 01             	add    $0x1,%ecx
f0106211:	0f af 45 10          	imul   0x10(%ebp),%eax
f0106215:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0106217:	eb b9                	jmp    f01061d2 <strtol+0x76>

	if (endptr)
f0106219:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010621d:	74 0d                	je     f010622c <strtol+0xd0>
		*endptr = (char *) s;
f010621f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106222:	89 0e                	mov    %ecx,(%esi)
f0106224:	eb 06                	jmp    f010622c <strtol+0xd0>
	else if (base == 0 && s[0] == '0')
f0106226:	85 db                	test   %ebx,%ebx
f0106228:	74 98                	je     f01061c2 <strtol+0x66>
f010622a:	eb 9e                	jmp    f01061ca <strtol+0x6e>
	return (neg ? -val : val);
f010622c:	89 c2                	mov    %eax,%edx
f010622e:	f7 da                	neg    %edx
f0106230:	85 ff                	test   %edi,%edi
f0106232:	0f 45 c2             	cmovne %edx,%eax
}
f0106235:	5b                   	pop    %ebx
f0106236:	5e                   	pop    %esi
f0106237:	5f                   	pop    %edi
f0106238:	5d                   	pop    %ebp
f0106239:	c3                   	ret    

f010623a <strtoul>:

unsigned long
strtoul(const char *s, char **endptr, int base)
{
f010623a:	55                   	push   %ebp
f010623b:	89 e5                	mov    %esp,%ebp
f010623d:	57                   	push   %edi
f010623e:	56                   	push   %esi
f010623f:	53                   	push   %ebx
f0106240:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106243:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	unsigned long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106246:	eb 03                	jmp    f010624b <strtoul+0x11>
		s++;
f0106248:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f010624b:	0f b6 01             	movzbl (%ecx),%eax
f010624e:	3c 20                	cmp    $0x20,%al
f0106250:	74 f6                	je     f0106248 <strtoul+0xe>
f0106252:	3c 09                	cmp    $0x9,%al
f0106254:	74 f2                	je     f0106248 <strtoul+0xe>

	// plus/minus sign
	if (*s == '+')
f0106256:	3c 2b                	cmp    $0x2b,%al
f0106258:	75 0a                	jne    f0106264 <strtoul+0x2a>
		s++;
f010625a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f010625d:	bf 00 00 00 00       	mov    $0x0,%edi
f0106262:	eb 11                	jmp    f0106275 <strtoul+0x3b>
f0106264:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
f0106269:	3c 2d                	cmp    $0x2d,%al
f010626b:	75 08                	jne    f0106275 <strtoul+0x3b>
		s++, neg = 1;
f010626d:	83 c1 01             	add    $0x1,%ecx
f0106270:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106275:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010627b:	75 15                	jne    f0106292 <strtoul+0x58>
f010627d:	80 39 30             	cmpb   $0x30,(%ecx)
f0106280:	75 10                	jne    f0106292 <strtoul+0x58>
f0106282:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0106286:	75 7c                	jne    f0106304 <strtoul+0xca>
		s += 2, base = 16;
f0106288:	83 c1 02             	add    $0x2,%ecx
f010628b:	bb 10 00 00 00       	mov    $0x10,%ebx
f0106290:	eb 16                	jmp    f01062a8 <strtoul+0x6e>
	else if (base == 0 && s[0] == '0')
f0106292:	85 db                	test   %ebx,%ebx
f0106294:	75 12                	jne    f01062a8 <strtoul+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0106296:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f010629b:	80 39 30             	cmpb   $0x30,(%ecx)
f010629e:	75 08                	jne    f01062a8 <strtoul+0x6e>
		s++, base = 8;
f01062a0:	83 c1 01             	add    $0x1,%ecx
f01062a3:	bb 08 00 00 00       	mov    $0x8,%ebx
		base = 10;
f01062a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01062ad:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01062b0:	0f b6 11             	movzbl (%ecx),%edx
f01062b3:	8d 72 d0             	lea    -0x30(%edx),%esi
f01062b6:	89 f3                	mov    %esi,%ebx
f01062b8:	80 fb 09             	cmp    $0x9,%bl
f01062bb:	77 08                	ja     f01062c5 <strtoul+0x8b>
			dig = *s - '0';
f01062bd:	0f be d2             	movsbl %dl,%edx
f01062c0:	83 ea 30             	sub    $0x30,%edx
f01062c3:	eb 22                	jmp    f01062e7 <strtoul+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01062c5:	8d 72 9f             	lea    -0x61(%edx),%esi
f01062c8:	89 f3                	mov    %esi,%ebx
f01062ca:	80 fb 19             	cmp    $0x19,%bl
f01062cd:	77 08                	ja     f01062d7 <strtoul+0x9d>
			dig = *s - 'a' + 10;
f01062cf:	0f be d2             	movsbl %dl,%edx
f01062d2:	83 ea 57             	sub    $0x57,%edx
f01062d5:	eb 10                	jmp    f01062e7 <strtoul+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01062d7:	8d 72 bf             	lea    -0x41(%edx),%esi
f01062da:	89 f3                	mov    %esi,%ebx
f01062dc:	80 fb 19             	cmp    $0x19,%bl
f01062df:	77 16                	ja     f01062f7 <strtoul+0xbd>
			dig = *s - 'A' + 10;
f01062e1:	0f be d2             	movsbl %dl,%edx
f01062e4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01062e7:	3b 55 10             	cmp    0x10(%ebp),%edx
f01062ea:	7d 0b                	jge    f01062f7 <strtoul+0xbd>
			break;
		s++, val = (val * base) + dig;
f01062ec:	83 c1 01             	add    $0x1,%ecx
f01062ef:	0f af 45 10          	imul   0x10(%ebp),%eax
f01062f3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01062f5:	eb b9                	jmp    f01062b0 <strtoul+0x76>

	if (endptr)
f01062f7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01062fb:	74 0d                	je     f010630a <strtoul+0xd0>
		*endptr = (char *) s;
f01062fd:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106300:	89 0e                	mov    %ecx,(%esi)
f0106302:	eb 06                	jmp    f010630a <strtoul+0xd0>
	else if (base == 0 && s[0] == '0')
f0106304:	85 db                	test   %ebx,%ebx
f0106306:	74 98                	je     f01062a0 <strtoul+0x66>
f0106308:	eb 9e                	jmp    f01062a8 <strtoul+0x6e>
	return (neg ? -val : val);
f010630a:	89 c2                	mov    %eax,%edx
f010630c:	f7 da                	neg    %edx
f010630e:	85 ff                	test   %edi,%edi
f0106310:	0f 45 c2             	cmovne %edx,%eax
}
f0106313:	5b                   	pop    %ebx
f0106314:	5e                   	pop    %esi
f0106315:	5f                   	pop    %edi
f0106316:	5d                   	pop    %ebp
f0106317:	c3                   	ret    

f0106318 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0106318:	fa                   	cli    

	xorw    %ax, %ax
f0106319:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010631b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010631d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010631f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0106321:	0f 01 16             	lgdtl  (%esi)
f0106324:	74 70                	je     f0106396 <mpsearch1+0x3>
	movl    %cr0, %eax
f0106326:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0106329:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f010632d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0106330:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0106336:	08 00                	or     %al,(%eax)

f0106338 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106338:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f010633c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010633e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106340:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0106342:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0106346:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106348:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010634a:	b8 00 10 12 00       	mov    $0x121000,%eax
	movl    %eax, %cr3
f010634f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0106352:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0106355:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010635a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f010635d:	8b 25 84 5e 2a f0    	mov    0xf02a5e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0106363:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106368:	b8 a1 02 10 f0       	mov    $0xf01002a1,%eax
	call    *%eax
f010636d:	ff d0                	call   *%eax

f010636f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010636f:	eb fe                	jmp    f010636f <spin>
f0106371:	8d 76 00             	lea    0x0(%esi),%esi

f0106374 <gdt>:
	...
f010637c:	ff                   	(bad)  
f010637d:	ff 00                	incl   (%eax)
f010637f:	00 00                	add    %al,(%eax)
f0106381:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106388:	00                   	.byte 0x0
f0106389:	92                   	xchg   %eax,%edx
f010638a:	cf                   	iret   
	...

f010638c <gdtdesc>:
f010638c:	17                   	pop    %ss
f010638d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0106392 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0106392:	90                   	nop

f0106393 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106393:	55                   	push   %ebp
f0106394:	89 e5                	mov    %esp,%ebp
f0106396:	57                   	push   %edi
f0106397:	56                   	push   %esi
f0106398:	53                   	push   %ebx
f0106399:	83 ec 0c             	sub    $0xc,%esp
	if (PGNUM(pa) >= npages)
f010639c:	8b 0d 88 5e 2a f0    	mov    0xf02a5e88,%ecx
f01063a2:	89 c3                	mov    %eax,%ebx
f01063a4:	c1 eb 0c             	shr    $0xc,%ebx
f01063a7:	39 cb                	cmp    %ecx,%ebx
f01063a9:	73 1a                	jae    f01063c5 <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f01063ab:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01063b1:	8d 34 02             	lea    (%edx,%eax,1),%esi
	if (PGNUM(pa) >= npages)
f01063b4:	89 f0                	mov    %esi,%eax
f01063b6:	c1 e8 0c             	shr    $0xc,%eax
f01063b9:	39 c8                	cmp    %ecx,%eax
f01063bb:	73 1a                	jae    f01063d7 <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f01063bd:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f01063c3:	eb 27                	jmp    f01063ec <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01063c5:	50                   	push   %eax
f01063c6:	68 c8 6e 10 f0       	push   $0xf0106ec8
f01063cb:	6a 57                	push   $0x57
f01063cd:	68 dd 8c 10 f0       	push   $0xf0108cdd
f01063d2:	e8 bd 9c ff ff       	call   f0100094 <_panic>
f01063d7:	56                   	push   %esi
f01063d8:	68 c8 6e 10 f0       	push   $0xf0106ec8
f01063dd:	6a 57                	push   $0x57
f01063df:	68 dd 8c 10 f0       	push   $0xf0108cdd
f01063e4:	e8 ab 9c ff ff       	call   f0100094 <_panic>
f01063e9:	83 c3 10             	add    $0x10,%ebx
f01063ec:	39 f3                	cmp    %esi,%ebx
f01063ee:	73 2c                	jae    f010641c <mpsearch1+0x89>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01063f0:	83 ec 04             	sub    $0x4,%esp
f01063f3:	6a 04                	push   $0x4
f01063f5:	68 ed 8c 10 f0       	push   $0xf0108ced
f01063fa:	53                   	push   %ebx
f01063fb:	e8 00 fd ff ff       	call   f0106100 <memcmp>
f0106400:	83 c4 10             	add    $0x10,%esp
f0106403:	85 c0                	test   %eax,%eax
f0106405:	75 e2                	jne    f01063e9 <mpsearch1+0x56>
f0106407:	89 da                	mov    %ebx,%edx
f0106409:	8d 7b 10             	lea    0x10(%ebx),%edi
		sum += ((uint8_t *)addr)[i];
f010640c:	0f b6 0a             	movzbl (%edx),%ecx
f010640f:	01 c8                	add    %ecx,%eax
f0106411:	42                   	inc    %edx
	for (i = 0; i < len; i++)
f0106412:	39 fa                	cmp    %edi,%edx
f0106414:	75 f6                	jne    f010640c <mpsearch1+0x79>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106416:	84 c0                	test   %al,%al
f0106418:	75 cf                	jne    f01063e9 <mpsearch1+0x56>
f010641a:	eb 05                	jmp    f0106421 <mpsearch1+0x8e>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010641c:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0106421:	89 d8                	mov    %ebx,%eax
f0106423:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106426:	5b                   	pop    %ebx
f0106427:	5e                   	pop    %esi
f0106428:	5f                   	pop    %edi
f0106429:	5d                   	pop    %ebp
f010642a:	c3                   	ret    

f010642b <mp_init>:
	return conf;
}

void
mp_init(void)
{
f010642b:	55                   	push   %ebp
f010642c:	89 e5                	mov    %esp,%ebp
f010642e:	57                   	push   %edi
f010642f:	56                   	push   %esi
f0106430:	53                   	push   %ebx
f0106431:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106434:	c7 05 c0 63 2a f0 20 	movl   $0xf02a6020,0xf02a63c0
f010643b:	60 2a f0 
	if (PGNUM(pa) >= npages)
f010643e:	83 3d 88 5e 2a f0 00 	cmpl   $0x0,0xf02a5e88
f0106445:	0f 84 84 00 00 00    	je     f01064cf <mp_init+0xa4>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010644b:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106452:	85 c0                	test   %eax,%eax
f0106454:	0f 84 8b 00 00 00    	je     f01064e5 <mp_init+0xba>
		p <<= 4;	// Translate from segment to PA
f010645a:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f010645d:	ba 00 04 00 00       	mov    $0x400,%edx
f0106462:	e8 2c ff ff ff       	call   f0106393 <mpsearch1>
f0106467:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010646a:	85 c0                	test   %eax,%eax
f010646c:	0f 84 97 00 00 00    	je     f0106509 <mp_init+0xde>
	if (mp->physaddr == 0 || mp->type != 0) {
f0106472:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106475:	8b 70 04             	mov    0x4(%eax),%esi
f0106478:	85 f6                	test   %esi,%esi
f010647a:	0f 84 a8 00 00 00    	je     f0106528 <mp_init+0xfd>
f0106480:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0106484:	0f 85 9e 00 00 00    	jne    f0106528 <mp_init+0xfd>
f010648a:	89 f0                	mov    %esi,%eax
f010648c:	c1 e8 0c             	shr    $0xc,%eax
f010648f:	3b 05 88 5e 2a f0    	cmp    0xf02a5e88,%eax
f0106495:	0f 83 a2 00 00 00    	jae    f010653d <mp_init+0x112>
	return (void *)(pa + KERNBASE);
f010649b:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
f01064a1:	89 df                	mov    %ebx,%edi
	if (memcmp(conf, "PCMP", 4) != 0) {
f01064a3:	83 ec 04             	sub    $0x4,%esp
f01064a6:	6a 04                	push   $0x4
f01064a8:	68 f2 8c 10 f0       	push   $0xf0108cf2
f01064ad:	53                   	push   %ebx
f01064ae:	e8 4d fc ff ff       	call   f0106100 <memcmp>
f01064b3:	83 c4 10             	add    $0x10,%esp
f01064b6:	85 c0                	test   %eax,%eax
f01064b8:	0f 85 94 00 00 00    	jne    f0106552 <mp_init+0x127>
f01064be:	0f b7 53 04          	movzwl 0x4(%ebx),%edx
f01064c2:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
f01064c5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	sum = 0;
f01064c8:	89 c2                	mov    %eax,%edx
f01064ca:	e9 9e 00 00 00       	jmp    f010656d <mp_init+0x142>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01064cf:	68 00 04 00 00       	push   $0x400
f01064d4:	68 c8 6e 10 f0       	push   $0xf0106ec8
f01064d9:	6a 6f                	push   $0x6f
f01064db:	68 dd 8c 10 f0       	push   $0xf0108cdd
f01064e0:	e8 af 9b ff ff       	call   f0100094 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f01064e5:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01064ec:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f01064ef:	2d 00 04 00 00       	sub    $0x400,%eax
f01064f4:	ba 00 04 00 00       	mov    $0x400,%edx
f01064f9:	e8 95 fe ff ff       	call   f0106393 <mpsearch1>
f01064fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0106501:	85 c0                	test   %eax,%eax
f0106503:	0f 85 69 ff ff ff    	jne    f0106472 <mp_init+0x47>
	return mpsearch1(0xF0000, 0x10000);
f0106509:	ba 00 00 01 00       	mov    $0x10000,%edx
f010650e:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0106513:	e8 7b fe ff ff       	call   f0106393 <mpsearch1>
f0106518:	89 45 e0             	mov    %eax,-0x20(%ebp)
	if ((mp = mpsearch()) == 0)
f010651b:	85 c0                	test   %eax,%eax
f010651d:	0f 85 4f ff ff ff    	jne    f0106472 <mp_init+0x47>
f0106523:	e9 b3 01 00 00       	jmp    f01066db <mp_init+0x2b0>
		cprintf("SMP: Default configurations not implemented\n");
f0106528:	83 ec 0c             	sub    $0xc,%esp
f010652b:	68 50 8b 10 f0       	push   $0xf0108b50
f0106530:	e8 85 da ff ff       	call   f0103fba <cprintf>
f0106535:	83 c4 10             	add    $0x10,%esp
f0106538:	e9 9e 01 00 00       	jmp    f01066db <mp_init+0x2b0>
f010653d:	56                   	push   %esi
f010653e:	68 c8 6e 10 f0       	push   $0xf0106ec8
f0106543:	68 90 00 00 00       	push   $0x90
f0106548:	68 dd 8c 10 f0       	push   $0xf0108cdd
f010654d:	e8 42 9b ff ff       	call   f0100094 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106552:	83 ec 0c             	sub    $0xc,%esp
f0106555:	68 80 8b 10 f0       	push   $0xf0108b80
f010655a:	e8 5b da ff ff       	call   f0103fba <cprintf>
f010655f:	83 c4 10             	add    $0x10,%esp
f0106562:	e9 74 01 00 00       	jmp    f01066db <mp_init+0x2b0>
		sum += ((uint8_t *)addr)[i];
f0106567:	0f b6 0b             	movzbl (%ebx),%ecx
f010656a:	01 ca                	add    %ecx,%edx
f010656c:	43                   	inc    %ebx
	for (i = 0; i < len; i++)
f010656d:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0106570:	75 f5                	jne    f0106567 <mp_init+0x13c>
	if (sum(conf, conf->length) != 0) {
f0106572:	84 d2                	test   %dl,%dl
f0106574:	75 15                	jne    f010658b <mp_init+0x160>
	if (conf->version != 1 && conf->version != 4) {
f0106576:	8a 57 06             	mov    0x6(%edi),%dl
f0106579:	80 fa 01             	cmp    $0x1,%dl
f010657c:	74 05                	je     f0106583 <mp_init+0x158>
f010657e:	80 fa 04             	cmp    $0x4,%dl
f0106581:	75 1d                	jne    f01065a0 <mp_init+0x175>
f0106583:	0f b7 4f 28          	movzwl 0x28(%edi),%ecx
f0106587:	01 d9                	add    %ebx,%ecx
f0106589:	eb 34                	jmp    f01065bf <mp_init+0x194>
		cprintf("SMP: Bad MP configuration checksum\n");
f010658b:	83 ec 0c             	sub    $0xc,%esp
f010658e:	68 b4 8b 10 f0       	push   $0xf0108bb4
f0106593:	e8 22 da ff ff       	call   f0103fba <cprintf>
f0106598:	83 c4 10             	add    $0x10,%esp
f010659b:	e9 3b 01 00 00       	jmp    f01066db <mp_init+0x2b0>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01065a0:	83 ec 08             	sub    $0x8,%esp
f01065a3:	0f b6 d2             	movzbl %dl,%edx
f01065a6:	52                   	push   %edx
f01065a7:	68 d8 8b 10 f0       	push   $0xf0108bd8
f01065ac:	e8 09 da ff ff       	call   f0103fba <cprintf>
f01065b1:	83 c4 10             	add    $0x10,%esp
f01065b4:	e9 22 01 00 00       	jmp    f01066db <mp_init+0x2b0>
		sum += ((uint8_t *)addr)[i];
f01065b9:	0f b6 13             	movzbl (%ebx),%edx
f01065bc:	01 d0                	add    %edx,%eax
f01065be:	43                   	inc    %ebx
	for (i = 0; i < len; i++)
f01065bf:	39 d9                	cmp    %ebx,%ecx
f01065c1:	75 f6                	jne    f01065b9 <mp_init+0x18e>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01065c3:	02 47 2a             	add    0x2a(%edi),%al
f01065c6:	75 28                	jne    f01065f0 <mp_init+0x1c5>
	if ((conf = mpconfig(&mp)) == 0)
f01065c8:	81 fe 00 00 00 10    	cmp    $0x10000000,%esi
f01065ce:	0f 84 07 01 00 00    	je     f01066db <mp_init+0x2b0>
		return;
	ismp = 1;
f01065d4:	c7 05 00 60 2a f0 01 	movl   $0x1,0xf02a6000
f01065db:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01065de:	8b 47 24             	mov    0x24(%edi),%eax
f01065e1:	a3 00 70 2e f0       	mov    %eax,0xf02e7000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01065e6:	8d 77 2c             	lea    0x2c(%edi),%esi
f01065e9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01065ee:	eb 60                	jmp    f0106650 <mp_init+0x225>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01065f0:	83 ec 0c             	sub    $0xc,%esp
f01065f3:	68 f8 8b 10 f0       	push   $0xf0108bf8
f01065f8:	e8 bd d9 ff ff       	call   f0103fba <cprintf>
f01065fd:	83 c4 10             	add    $0x10,%esp
f0106600:	e9 d6 00 00 00       	jmp    f01066db <mp_init+0x2b0>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106605:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f0106609:	74 1e                	je     f0106629 <mp_init+0x1fe>
				bootcpu = &cpus[ncpu];
f010660b:	8b 15 c4 63 2a f0    	mov    0xf02a63c4,%edx
f0106611:	8d 04 12             	lea    (%edx,%edx,1),%eax
f0106614:	01 d0                	add    %edx,%eax
f0106616:	01 c0                	add    %eax,%eax
f0106618:	01 d0                	add    %edx,%eax
f010661a:	8d 04 82             	lea    (%edx,%eax,4),%eax
f010661d:	8d 04 85 20 60 2a f0 	lea    -0xfd59fe0(,%eax,4),%eax
f0106624:	a3 c0 63 2a f0       	mov    %eax,0xf02a63c0
			if (ncpu < NCPU) {
f0106629:	a1 c4 63 2a f0       	mov    0xf02a63c4,%eax
f010662e:	83 f8 07             	cmp    $0x7,%eax
f0106631:	7f 34                	jg     f0106667 <mp_init+0x23c>
				cpus[ncpu].cpu_id = ncpu;
f0106633:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0106636:	01 c2                	add    %eax,%edx
f0106638:	01 d2                	add    %edx,%edx
f010663a:	01 c2                	add    %eax,%edx
f010663c:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010663f:	88 04 95 20 60 2a f0 	mov    %al,-0xfd59fe0(,%edx,4)
				ncpu++;
f0106646:	40                   	inc    %eax
f0106647:	a3 c4 63 2a f0       	mov    %eax,0xf02a63c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f010664c:	83 c6 14             	add    $0x14,%esi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010664f:	43                   	inc    %ebx
f0106650:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f0106654:	39 d8                	cmp    %ebx,%eax
f0106656:	76 4a                	jbe    f01066a2 <mp_init+0x277>
		switch (*p) {
f0106658:	8a 06                	mov    (%esi),%al
f010665a:	84 c0                	test   %al,%al
f010665c:	74 a7                	je     f0106605 <mp_init+0x1da>
f010665e:	3c 04                	cmp    $0x4,%al
f0106660:	77 1c                	ja     f010667e <mp_init+0x253>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106662:	83 c6 08             	add    $0x8,%esi
			continue;
f0106665:	eb e8                	jmp    f010664f <mp_init+0x224>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106667:	83 ec 08             	sub    $0x8,%esp
f010666a:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f010666e:	50                   	push   %eax
f010666f:	68 28 8c 10 f0       	push   $0xf0108c28
f0106674:	e8 41 d9 ff ff       	call   f0103fba <cprintf>
f0106679:	83 c4 10             	add    $0x10,%esp
f010667c:	eb ce                	jmp    f010664c <mp_init+0x221>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010667e:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0106681:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f0106684:	50                   	push   %eax
f0106685:	68 50 8c 10 f0       	push   $0xf0108c50
f010668a:	e8 2b d9 ff ff       	call   f0103fba <cprintf>
			ismp = 0;
f010668f:	c7 05 00 60 2a f0 00 	movl   $0x0,0xf02a6000
f0106696:	00 00 00 
			i = conf->entry;
f0106699:	0f b7 5f 22          	movzwl 0x22(%edi),%ebx
f010669d:	83 c4 10             	add    $0x10,%esp
f01066a0:	eb ad                	jmp    f010664f <mp_init+0x224>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01066a2:	a1 c0 63 2a f0       	mov    0xf02a63c0,%eax
f01066a7:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01066ae:	83 3d 00 60 2a f0 00 	cmpl   $0x0,0xf02a6000
f01066b5:	75 2c                	jne    f01066e3 <mp_init+0x2b8>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01066b7:	c7 05 c4 63 2a f0 01 	movl   $0x1,0xf02a63c4
f01066be:	00 00 00 
		lapicaddr = 0;
f01066c1:	c7 05 00 70 2e f0 00 	movl   $0x0,0xf02e7000
f01066c8:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01066cb:	83 ec 0c             	sub    $0xc,%esp
f01066ce:	68 70 8c 10 f0       	push   $0xf0108c70
f01066d3:	e8 e2 d8 ff ff       	call   f0103fba <cprintf>
		return;
f01066d8:	83 c4 10             	add    $0x10,%esp
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f01066db:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01066de:	5b                   	pop    %ebx
f01066df:	5e                   	pop    %esi
f01066e0:	5f                   	pop    %edi
f01066e1:	5d                   	pop    %ebp
f01066e2:	c3                   	ret    
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01066e3:	83 ec 04             	sub    $0x4,%esp
f01066e6:	ff 35 c4 63 2a f0    	pushl  0xf02a63c4
f01066ec:	0f b6 00             	movzbl (%eax),%eax
f01066ef:	50                   	push   %eax
f01066f0:	68 f7 8c 10 f0       	push   $0xf0108cf7
f01066f5:	e8 c0 d8 ff ff       	call   f0103fba <cprintf>
	if (mp->imcrp) {
f01066fa:	83 c4 10             	add    $0x10,%esp
f01066fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106700:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106704:	74 d5                	je     f01066db <mp_init+0x2b0>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106706:	83 ec 0c             	sub    $0xc,%esp
f0106709:	68 9c 8c 10 f0       	push   $0xf0108c9c
f010670e:	e8 a7 d8 ff ff       	call   f0103fba <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106713:	b0 70                	mov    $0x70,%al
f0106715:	ba 22 00 00 00       	mov    $0x22,%edx
f010671a:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010671b:	ba 23 00 00 00       	mov    $0x23,%edx
f0106720:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0106721:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106724:	ee                   	out    %al,(%dx)
f0106725:	83 c4 10             	add    $0x10,%esp
f0106728:	eb b1                	jmp    f01066db <mp_init+0x2b0>

f010672a <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f010672a:	55                   	push   %ebp
f010672b:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f010672d:	8b 0d 04 70 2e f0    	mov    0xf02e7004,%ecx
f0106733:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0106736:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106738:	a1 04 70 2e f0       	mov    0xf02e7004,%eax
f010673d:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106740:	5d                   	pop    %ebp
f0106741:	c3                   	ret    

f0106742 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106742:	55                   	push   %ebp
f0106743:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106745:	a1 04 70 2e f0       	mov    0xf02e7004,%eax
f010674a:	85 c0                	test   %eax,%eax
f010674c:	74 08                	je     f0106756 <cpunum+0x14>
		return lapic[ID] >> 24;
f010674e:	8b 40 20             	mov    0x20(%eax),%eax
f0106751:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f0106754:	5d                   	pop    %ebp
f0106755:	c3                   	ret    
	return 0;
f0106756:	b8 00 00 00 00       	mov    $0x0,%eax
f010675b:	eb f7                	jmp    f0106754 <cpunum+0x12>

f010675d <lapic_init>:
	if (!lapicaddr)
f010675d:	a1 00 70 2e f0       	mov    0xf02e7000,%eax
f0106762:	85 c0                	test   %eax,%eax
f0106764:	75 01                	jne    f0106767 <lapic_init+0xa>
f0106766:	c3                   	ret    
{
f0106767:	55                   	push   %ebp
f0106768:	89 e5                	mov    %esp,%ebp
f010676a:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f010676d:	68 00 10 00 00       	push   $0x1000
f0106772:	50                   	push   %eax
f0106773:	e8 73 b0 ff ff       	call   f01017eb <mmio_map_region>
f0106778:	a3 04 70 2e f0       	mov    %eax,0xf02e7004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010677d:	ba 27 01 00 00       	mov    $0x127,%edx
f0106782:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106787:	e8 9e ff ff ff       	call   f010672a <lapicw>
	lapicw(TDCR, X1);
f010678c:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106791:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106796:	e8 8f ff ff ff       	call   f010672a <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010679b:	ba 20 00 02 00       	mov    $0x20020,%edx
f01067a0:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01067a5:	e8 80 ff ff ff       	call   f010672a <lapicw>
	lapicw(TICR, 10000000); 
f01067aa:	ba 80 96 98 00       	mov    $0x989680,%edx
f01067af:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01067b4:	e8 71 ff ff ff       	call   f010672a <lapicw>
	if (thiscpu != bootcpu)
f01067b9:	e8 84 ff ff ff       	call   f0106742 <cpunum>
f01067be:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01067c1:	01 c2                	add    %eax,%edx
f01067c3:	01 d2                	add    %edx,%edx
f01067c5:	01 c2                	add    %eax,%edx
f01067c7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01067ca:	8d 04 85 20 60 2a f0 	lea    -0xfd59fe0(,%eax,4),%eax
f01067d1:	83 c4 10             	add    $0x10,%esp
f01067d4:	39 05 c0 63 2a f0    	cmp    %eax,0xf02a63c0
f01067da:	74 0f                	je     f01067eb <lapic_init+0x8e>
		lapicw(LINT0, MASKED);
f01067dc:	ba 00 00 01 00       	mov    $0x10000,%edx
f01067e1:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01067e6:	e8 3f ff ff ff       	call   f010672a <lapicw>
	lapicw(LINT1, MASKED);
f01067eb:	ba 00 00 01 00       	mov    $0x10000,%edx
f01067f0:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01067f5:	e8 30 ff ff ff       	call   f010672a <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01067fa:	a1 04 70 2e f0       	mov    0xf02e7004,%eax
f01067ff:	8b 40 30             	mov    0x30(%eax),%eax
f0106802:	c1 e8 10             	shr    $0x10,%eax
f0106805:	3c 03                	cmp    $0x3,%al
f0106807:	77 7c                	ja     f0106885 <lapic_init+0x128>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106809:	ba 33 00 00 00       	mov    $0x33,%edx
f010680e:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106813:	e8 12 ff ff ff       	call   f010672a <lapicw>
	lapicw(ESR, 0);
f0106818:	ba 00 00 00 00       	mov    $0x0,%edx
f010681d:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106822:	e8 03 ff ff ff       	call   f010672a <lapicw>
	lapicw(ESR, 0);
f0106827:	ba 00 00 00 00       	mov    $0x0,%edx
f010682c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106831:	e8 f4 fe ff ff       	call   f010672a <lapicw>
	lapicw(EOI, 0);
f0106836:	ba 00 00 00 00       	mov    $0x0,%edx
f010683b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106840:	e8 e5 fe ff ff       	call   f010672a <lapicw>
	lapicw(ICRHI, 0);
f0106845:	ba 00 00 00 00       	mov    $0x0,%edx
f010684a:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010684f:	e8 d6 fe ff ff       	call   f010672a <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106854:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106859:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010685e:	e8 c7 fe ff ff       	call   f010672a <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106863:	8b 15 04 70 2e f0    	mov    0xf02e7004,%edx
f0106869:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010686f:	f6 c4 10             	test   $0x10,%ah
f0106872:	75 f5                	jne    f0106869 <lapic_init+0x10c>
	lapicw(TPR, 0);
f0106874:	ba 00 00 00 00       	mov    $0x0,%edx
f0106879:	b8 20 00 00 00       	mov    $0x20,%eax
f010687e:	e8 a7 fe ff ff       	call   f010672a <lapicw>
}
f0106883:	c9                   	leave  
f0106884:	c3                   	ret    
		lapicw(PCINT, MASKED);
f0106885:	ba 00 00 01 00       	mov    $0x10000,%edx
f010688a:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010688f:	e8 96 fe ff ff       	call   f010672a <lapicw>
f0106894:	e9 70 ff ff ff       	jmp    f0106809 <lapic_init+0xac>

f0106899 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0106899:	83 3d 04 70 2e f0 00 	cmpl   $0x0,0xf02e7004
f01068a0:	74 14                	je     f01068b6 <lapic_eoi+0x1d>
{
f01068a2:	55                   	push   %ebp
f01068a3:	89 e5                	mov    %esp,%ebp
		lapicw(EOI, 0);
f01068a5:	ba 00 00 00 00       	mov    $0x0,%edx
f01068aa:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01068af:	e8 76 fe ff ff       	call   f010672a <lapicw>
}
f01068b4:	5d                   	pop    %ebp
f01068b5:	c3                   	ret    
f01068b6:	c3                   	ret    

f01068b7 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01068b7:	55                   	push   %ebp
f01068b8:	89 e5                	mov    %esp,%ebp
f01068ba:	56                   	push   %esi
f01068bb:	53                   	push   %ebx
f01068bc:	8b 75 08             	mov    0x8(%ebp),%esi
f01068bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01068c2:	b0 0f                	mov    $0xf,%al
f01068c4:	ba 70 00 00 00       	mov    $0x70,%edx
f01068c9:	ee                   	out    %al,(%dx)
f01068ca:	b0 0a                	mov    $0xa,%al
f01068cc:	ba 71 00 00 00       	mov    $0x71,%edx
f01068d1:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f01068d2:	83 3d 88 5e 2a f0 00 	cmpl   $0x0,0xf02a5e88
f01068d9:	74 7e                	je     f0106959 <lapic_startap+0xa2>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01068db:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01068e2:	00 00 
	wrv[1] = addr >> 4;
f01068e4:	89 d8                	mov    %ebx,%eax
f01068e6:	c1 e8 04             	shr    $0x4,%eax
f01068e9:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01068ef:	c1 e6 18             	shl    $0x18,%esi
f01068f2:	89 f2                	mov    %esi,%edx
f01068f4:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01068f9:	e8 2c fe ff ff       	call   f010672a <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01068fe:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106903:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106908:	e8 1d fe ff ff       	call   f010672a <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f010690d:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106912:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106917:	e8 0e fe ff ff       	call   f010672a <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010691c:	c1 eb 0c             	shr    $0xc,%ebx
f010691f:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f0106922:	89 f2                	mov    %esi,%edx
f0106924:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106929:	e8 fc fd ff ff       	call   f010672a <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010692e:	89 da                	mov    %ebx,%edx
f0106930:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106935:	e8 f0 fd ff ff       	call   f010672a <lapicw>
		lapicw(ICRHI, apicid << 24);
f010693a:	89 f2                	mov    %esi,%edx
f010693c:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106941:	e8 e4 fd ff ff       	call   f010672a <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106946:	89 da                	mov    %ebx,%edx
f0106948:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010694d:	e8 d8 fd ff ff       	call   f010672a <lapicw>
		microdelay(200);
	}
}
f0106952:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106955:	5b                   	pop    %ebx
f0106956:	5e                   	pop    %esi
f0106957:	5d                   	pop    %ebp
f0106958:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106959:	68 67 04 00 00       	push   $0x467
f010695e:	68 c8 6e 10 f0       	push   $0xf0106ec8
f0106963:	68 98 00 00 00       	push   $0x98
f0106968:	68 14 8d 10 f0       	push   $0xf0108d14
f010696d:	e8 22 97 ff ff       	call   f0100094 <_panic>

f0106972 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106972:	55                   	push   %ebp
f0106973:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106975:	8b 55 08             	mov    0x8(%ebp),%edx
f0106978:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f010697e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106983:	e8 a2 fd ff ff       	call   f010672a <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106988:	8b 15 04 70 2e f0    	mov    0xf02e7004,%edx
f010698e:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106994:	f6 c4 10             	test   $0x10,%ah
f0106997:	75 f5                	jne    f010698e <lapic_ipi+0x1c>
		;
}
f0106999:	5d                   	pop    %ebp
f010699a:	c3                   	ret    

f010699b <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010699b:	55                   	push   %ebp
f010699c:	89 e5                	mov    %esp,%ebp
f010699e:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01069a1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01069a7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01069aa:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01069ad:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01069b4:	5d                   	pop    %ebp
f01069b5:	c3                   	ret    

f01069b6 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01069b6:	55                   	push   %ebp
f01069b7:	89 e5                	mov    %esp,%ebp
f01069b9:	56                   	push   %esi
f01069ba:	53                   	push   %ebx
f01069bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f01069be:	83 3b 00             	cmpl   $0x0,(%ebx)
f01069c1:	75 07                	jne    f01069ca <spin_lock+0x14>
	asm volatile("lock; xchgl %0, %1"
f01069c3:	ba 01 00 00 00       	mov    $0x1,%edx
f01069c8:	eb 3f                	jmp    f0106a09 <spin_lock+0x53>
f01069ca:	8b 73 08             	mov    0x8(%ebx),%esi
f01069cd:	e8 70 fd ff ff       	call   f0106742 <cpunum>
f01069d2:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01069d5:	01 c2                	add    %eax,%edx
f01069d7:	01 d2                	add    %edx,%edx
f01069d9:	01 c2                	add    %eax,%edx
f01069db:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01069de:	8d 04 85 20 60 2a f0 	lea    -0xfd59fe0(,%eax,4),%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01069e5:	39 c6                	cmp    %eax,%esi
f01069e7:	75 da                	jne    f01069c3 <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01069e9:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01069ec:	e8 51 fd ff ff       	call   f0106742 <cpunum>
f01069f1:	83 ec 0c             	sub    $0xc,%esp
f01069f4:	53                   	push   %ebx
f01069f5:	50                   	push   %eax
f01069f6:	68 24 8d 10 f0       	push   $0xf0108d24
f01069fb:	6a 41                	push   $0x41
f01069fd:	68 88 8d 10 f0       	push   $0xf0108d88
f0106a02:	e8 8d 96 ff ff       	call   f0100094 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106a07:	f3 90                	pause  
f0106a09:	89 d0                	mov    %edx,%eax
f0106a0b:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f0106a0e:	85 c0                	test   %eax,%eax
f0106a10:	75 f5                	jne    f0106a07 <spin_lock+0x51>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106a12:	e8 2b fd ff ff       	call   f0106742 <cpunum>
f0106a17:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0106a1a:	01 c2                	add    %eax,%edx
f0106a1c:	01 d2                	add    %edx,%edx
f0106a1e:	01 c2                	add    %eax,%edx
f0106a20:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106a23:	8d 04 85 20 60 2a f0 	lea    -0xfd59fe0(,%eax,4),%eax
f0106a2a:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106a2d:	83 c3 0c             	add    $0xc,%ebx
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0106a30:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0106a32:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106a37:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106a3d:	76 1d                	jbe    f0106a5c <spin_lock+0xa6>
		pcs[i] = ebp[1];          // saved %eip
f0106a3f:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106a42:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106a45:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f0106a47:	40                   	inc    %eax
f0106a48:	83 f8 0a             	cmp    $0xa,%eax
f0106a4b:	75 ea                	jne    f0106a37 <spin_lock+0x81>
#endif
}
f0106a4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106a50:	5b                   	pop    %ebx
f0106a51:	5e                   	pop    %esi
f0106a52:	5d                   	pop    %ebp
f0106a53:	c3                   	ret    
		pcs[i] = 0;
f0106a54:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
	for (; i < 10; i++)
f0106a5b:	40                   	inc    %eax
f0106a5c:	83 f8 09             	cmp    $0x9,%eax
f0106a5f:	7e f3                	jle    f0106a54 <spin_lock+0x9e>
f0106a61:	eb ea                	jmp    f0106a4d <spin_lock+0x97>

f0106a63 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106a63:	55                   	push   %ebp
f0106a64:	89 e5                	mov    %esp,%ebp
f0106a66:	57                   	push   %edi
f0106a67:	56                   	push   %esi
f0106a68:	53                   	push   %ebx
f0106a69:	83 ec 4c             	sub    $0x4c,%esp
f0106a6c:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f0106a6f:	83 3e 00             	cmpl   $0x0,(%esi)
f0106a72:	75 35                	jne    f0106aa9 <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106a74:	83 ec 04             	sub    $0x4,%esp
f0106a77:	6a 28                	push   $0x28
f0106a79:	8d 46 0c             	lea    0xc(%esi),%eax
f0106a7c:	50                   	push   %eax
f0106a7d:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106a80:	53                   	push   %ebx
f0106a81:	e8 ff f5 ff ff       	call   f0106085 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106a86:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106a89:	0f b6 38             	movzbl (%eax),%edi
f0106a8c:	8b 76 04             	mov    0x4(%esi),%esi
f0106a8f:	e8 ae fc ff ff       	call   f0106742 <cpunum>
f0106a94:	57                   	push   %edi
f0106a95:	56                   	push   %esi
f0106a96:	50                   	push   %eax
f0106a97:	68 50 8d 10 f0       	push   $0xf0108d50
f0106a9c:	e8 19 d5 ff ff       	call   f0103fba <cprintf>
f0106aa1:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106aa4:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0106aa7:	eb 6c                	jmp    f0106b15 <spin_unlock+0xb2>
	return lock->locked && lock->cpu == thiscpu;
f0106aa9:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106aac:	e8 91 fc ff ff       	call   f0106742 <cpunum>
f0106ab1:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0106ab4:	01 c2                	add    %eax,%edx
f0106ab6:	01 d2                	add    %edx,%edx
f0106ab8:	01 c2                	add    %eax,%edx
f0106aba:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106abd:	8d 04 85 20 60 2a f0 	lea    -0xfd59fe0(,%eax,4),%eax
	if (!holding(lk)) {
f0106ac4:	39 c3                	cmp    %eax,%ebx
f0106ac6:	75 ac                	jne    f0106a74 <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f0106ac8:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106acf:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f0106ad6:	b8 00 00 00 00       	mov    $0x0,%eax
f0106adb:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0106ade:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106ae1:	5b                   	pop    %ebx
f0106ae2:	5e                   	pop    %esi
f0106ae3:	5f                   	pop    %edi
f0106ae4:	5d                   	pop    %ebp
f0106ae5:	c3                   	ret    
					pcs[i] - info.eip_fn_addr);
f0106ae6:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106ae8:	83 ec 04             	sub    $0x4,%esp
f0106aeb:	89 c2                	mov    %eax,%edx
f0106aed:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106af0:	52                   	push   %edx
f0106af1:	ff 75 b0             	pushl  -0x50(%ebp)
f0106af4:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106af7:	ff 75 ac             	pushl  -0x54(%ebp)
f0106afa:	ff 75 a8             	pushl  -0x58(%ebp)
f0106afd:	50                   	push   %eax
f0106afe:	68 98 8d 10 f0       	push   $0xf0108d98
f0106b03:	e8 b2 d4 ff ff       	call   f0103fba <cprintf>
f0106b08:	83 c4 20             	add    $0x20,%esp
f0106b0b:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106b0e:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106b11:	39 c3                	cmp    %eax,%ebx
f0106b13:	74 2d                	je     f0106b42 <spin_unlock+0xdf>
f0106b15:	89 de                	mov    %ebx,%esi
f0106b17:	8b 03                	mov    (%ebx),%eax
f0106b19:	85 c0                	test   %eax,%eax
f0106b1b:	74 25                	je     f0106b42 <spin_unlock+0xdf>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106b1d:	83 ec 08             	sub    $0x8,%esp
f0106b20:	57                   	push   %edi
f0106b21:	50                   	push   %eax
f0106b22:	e8 9b ea ff ff       	call   f01055c2 <debuginfo_eip>
f0106b27:	83 c4 10             	add    $0x10,%esp
f0106b2a:	85 c0                	test   %eax,%eax
f0106b2c:	79 b8                	jns    f0106ae6 <spin_unlock+0x83>
				cprintf("  %08x\n", pcs[i]);
f0106b2e:	83 ec 08             	sub    $0x8,%esp
f0106b31:	ff 36                	pushl  (%esi)
f0106b33:	68 af 8d 10 f0       	push   $0xf0108daf
f0106b38:	e8 7d d4 ff ff       	call   f0103fba <cprintf>
f0106b3d:	83 c4 10             	add    $0x10,%esp
f0106b40:	eb c9                	jmp    f0106b0b <spin_unlock+0xa8>
		panic("spin_unlock");
f0106b42:	83 ec 04             	sub    $0x4,%esp
f0106b45:	68 b7 8d 10 f0       	push   $0xf0108db7
f0106b4a:	6a 67                	push   $0x67
f0106b4c:	68 88 8d 10 f0       	push   $0xf0108d88
f0106b51:	e8 3e 95 ff ff       	call   f0100094 <_panic>
f0106b56:	66 90                	xchg   %ax,%ax

f0106b58 <__udivdi3>:
f0106b58:	55                   	push   %ebp
f0106b59:	57                   	push   %edi
f0106b5a:	56                   	push   %esi
f0106b5b:	53                   	push   %ebx
f0106b5c:	83 ec 1c             	sub    $0x1c,%esp
f0106b5f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0106b63:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106b67:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106b6b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0106b6f:	85 d2                	test   %edx,%edx
f0106b71:	75 2d                	jne    f0106ba0 <__udivdi3+0x48>
f0106b73:	39 f7                	cmp    %esi,%edi
f0106b75:	77 59                	ja     f0106bd0 <__udivdi3+0x78>
f0106b77:	89 f9                	mov    %edi,%ecx
f0106b79:	85 ff                	test   %edi,%edi
f0106b7b:	75 0b                	jne    f0106b88 <__udivdi3+0x30>
f0106b7d:	b8 01 00 00 00       	mov    $0x1,%eax
f0106b82:	31 d2                	xor    %edx,%edx
f0106b84:	f7 f7                	div    %edi
f0106b86:	89 c1                	mov    %eax,%ecx
f0106b88:	31 d2                	xor    %edx,%edx
f0106b8a:	89 f0                	mov    %esi,%eax
f0106b8c:	f7 f1                	div    %ecx
f0106b8e:	89 c3                	mov    %eax,%ebx
f0106b90:	89 e8                	mov    %ebp,%eax
f0106b92:	f7 f1                	div    %ecx
f0106b94:	89 da                	mov    %ebx,%edx
f0106b96:	83 c4 1c             	add    $0x1c,%esp
f0106b99:	5b                   	pop    %ebx
f0106b9a:	5e                   	pop    %esi
f0106b9b:	5f                   	pop    %edi
f0106b9c:	5d                   	pop    %ebp
f0106b9d:	c3                   	ret    
f0106b9e:	66 90                	xchg   %ax,%ax
f0106ba0:	39 f2                	cmp    %esi,%edx
f0106ba2:	77 1c                	ja     f0106bc0 <__udivdi3+0x68>
f0106ba4:	0f bd da             	bsr    %edx,%ebx
f0106ba7:	83 f3 1f             	xor    $0x1f,%ebx
f0106baa:	75 38                	jne    f0106be4 <__udivdi3+0x8c>
f0106bac:	39 f2                	cmp    %esi,%edx
f0106bae:	72 08                	jb     f0106bb8 <__udivdi3+0x60>
f0106bb0:	39 ef                	cmp    %ebp,%edi
f0106bb2:	0f 87 98 00 00 00    	ja     f0106c50 <__udivdi3+0xf8>
f0106bb8:	b8 01 00 00 00       	mov    $0x1,%eax
f0106bbd:	eb 05                	jmp    f0106bc4 <__udivdi3+0x6c>
f0106bbf:	90                   	nop
f0106bc0:	31 db                	xor    %ebx,%ebx
f0106bc2:	31 c0                	xor    %eax,%eax
f0106bc4:	89 da                	mov    %ebx,%edx
f0106bc6:	83 c4 1c             	add    $0x1c,%esp
f0106bc9:	5b                   	pop    %ebx
f0106bca:	5e                   	pop    %esi
f0106bcb:	5f                   	pop    %edi
f0106bcc:	5d                   	pop    %ebp
f0106bcd:	c3                   	ret    
f0106bce:	66 90                	xchg   %ax,%ax
f0106bd0:	89 e8                	mov    %ebp,%eax
f0106bd2:	89 f2                	mov    %esi,%edx
f0106bd4:	f7 f7                	div    %edi
f0106bd6:	31 db                	xor    %ebx,%ebx
f0106bd8:	89 da                	mov    %ebx,%edx
f0106bda:	83 c4 1c             	add    $0x1c,%esp
f0106bdd:	5b                   	pop    %ebx
f0106bde:	5e                   	pop    %esi
f0106bdf:	5f                   	pop    %edi
f0106be0:	5d                   	pop    %ebp
f0106be1:	c3                   	ret    
f0106be2:	66 90                	xchg   %ax,%ax
f0106be4:	b8 20 00 00 00       	mov    $0x20,%eax
f0106be9:	29 d8                	sub    %ebx,%eax
f0106beb:	88 d9                	mov    %bl,%cl
f0106bed:	d3 e2                	shl    %cl,%edx
f0106bef:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106bf3:	89 fa                	mov    %edi,%edx
f0106bf5:	88 c1                	mov    %al,%cl
f0106bf7:	d3 ea                	shr    %cl,%edx
f0106bf9:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106bfd:	09 d1                	or     %edx,%ecx
f0106bff:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106c03:	88 d9                	mov    %bl,%cl
f0106c05:	d3 e7                	shl    %cl,%edi
f0106c07:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106c0b:	89 f7                	mov    %esi,%edi
f0106c0d:	88 c1                	mov    %al,%cl
f0106c0f:	d3 ef                	shr    %cl,%edi
f0106c11:	88 d9                	mov    %bl,%cl
f0106c13:	d3 e6                	shl    %cl,%esi
f0106c15:	89 ea                	mov    %ebp,%edx
f0106c17:	88 c1                	mov    %al,%cl
f0106c19:	d3 ea                	shr    %cl,%edx
f0106c1b:	09 d6                	or     %edx,%esi
f0106c1d:	89 f0                	mov    %esi,%eax
f0106c1f:	89 fa                	mov    %edi,%edx
f0106c21:	f7 74 24 08          	divl   0x8(%esp)
f0106c25:	89 d7                	mov    %edx,%edi
f0106c27:	89 c6                	mov    %eax,%esi
f0106c29:	f7 64 24 0c          	mull   0xc(%esp)
f0106c2d:	39 d7                	cmp    %edx,%edi
f0106c2f:	72 13                	jb     f0106c44 <__udivdi3+0xec>
f0106c31:	74 09                	je     f0106c3c <__udivdi3+0xe4>
f0106c33:	89 f0                	mov    %esi,%eax
f0106c35:	31 db                	xor    %ebx,%ebx
f0106c37:	eb 8b                	jmp    f0106bc4 <__udivdi3+0x6c>
f0106c39:	8d 76 00             	lea    0x0(%esi),%esi
f0106c3c:	88 d9                	mov    %bl,%cl
f0106c3e:	d3 e5                	shl    %cl,%ebp
f0106c40:	39 c5                	cmp    %eax,%ebp
f0106c42:	73 ef                	jae    f0106c33 <__udivdi3+0xdb>
f0106c44:	8d 46 ff             	lea    -0x1(%esi),%eax
f0106c47:	31 db                	xor    %ebx,%ebx
f0106c49:	e9 76 ff ff ff       	jmp    f0106bc4 <__udivdi3+0x6c>
f0106c4e:	66 90                	xchg   %ax,%ax
f0106c50:	31 c0                	xor    %eax,%eax
f0106c52:	e9 6d ff ff ff       	jmp    f0106bc4 <__udivdi3+0x6c>
f0106c57:	90                   	nop

f0106c58 <__umoddi3>:
f0106c58:	55                   	push   %ebp
f0106c59:	57                   	push   %edi
f0106c5a:	56                   	push   %esi
f0106c5b:	53                   	push   %ebx
f0106c5c:	83 ec 1c             	sub    $0x1c,%esp
f0106c5f:	8b 74 24 30          	mov    0x30(%esp),%esi
f0106c63:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0106c67:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106c6b:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0106c6f:	89 f0                	mov    %esi,%eax
f0106c71:	89 da                	mov    %ebx,%edx
f0106c73:	85 ed                	test   %ebp,%ebp
f0106c75:	75 15                	jne    f0106c8c <__umoddi3+0x34>
f0106c77:	39 df                	cmp    %ebx,%edi
f0106c79:	76 39                	jbe    f0106cb4 <__umoddi3+0x5c>
f0106c7b:	f7 f7                	div    %edi
f0106c7d:	89 d0                	mov    %edx,%eax
f0106c7f:	31 d2                	xor    %edx,%edx
f0106c81:	83 c4 1c             	add    $0x1c,%esp
f0106c84:	5b                   	pop    %ebx
f0106c85:	5e                   	pop    %esi
f0106c86:	5f                   	pop    %edi
f0106c87:	5d                   	pop    %ebp
f0106c88:	c3                   	ret    
f0106c89:	8d 76 00             	lea    0x0(%esi),%esi
f0106c8c:	39 dd                	cmp    %ebx,%ebp
f0106c8e:	77 f1                	ja     f0106c81 <__umoddi3+0x29>
f0106c90:	0f bd cd             	bsr    %ebp,%ecx
f0106c93:	83 f1 1f             	xor    $0x1f,%ecx
f0106c96:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106c9a:	75 38                	jne    f0106cd4 <__umoddi3+0x7c>
f0106c9c:	39 dd                	cmp    %ebx,%ebp
f0106c9e:	72 04                	jb     f0106ca4 <__umoddi3+0x4c>
f0106ca0:	39 f7                	cmp    %esi,%edi
f0106ca2:	77 dd                	ja     f0106c81 <__umoddi3+0x29>
f0106ca4:	89 da                	mov    %ebx,%edx
f0106ca6:	89 f0                	mov    %esi,%eax
f0106ca8:	29 f8                	sub    %edi,%eax
f0106caa:	19 ea                	sbb    %ebp,%edx
f0106cac:	83 c4 1c             	add    $0x1c,%esp
f0106caf:	5b                   	pop    %ebx
f0106cb0:	5e                   	pop    %esi
f0106cb1:	5f                   	pop    %edi
f0106cb2:	5d                   	pop    %ebp
f0106cb3:	c3                   	ret    
f0106cb4:	89 f9                	mov    %edi,%ecx
f0106cb6:	85 ff                	test   %edi,%edi
f0106cb8:	75 0b                	jne    f0106cc5 <__umoddi3+0x6d>
f0106cba:	b8 01 00 00 00       	mov    $0x1,%eax
f0106cbf:	31 d2                	xor    %edx,%edx
f0106cc1:	f7 f7                	div    %edi
f0106cc3:	89 c1                	mov    %eax,%ecx
f0106cc5:	89 d8                	mov    %ebx,%eax
f0106cc7:	31 d2                	xor    %edx,%edx
f0106cc9:	f7 f1                	div    %ecx
f0106ccb:	89 f0                	mov    %esi,%eax
f0106ccd:	f7 f1                	div    %ecx
f0106ccf:	eb ac                	jmp    f0106c7d <__umoddi3+0x25>
f0106cd1:	8d 76 00             	lea    0x0(%esi),%esi
f0106cd4:	b8 20 00 00 00       	mov    $0x20,%eax
f0106cd9:	89 c2                	mov    %eax,%edx
f0106cdb:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106cdf:	29 c2                	sub    %eax,%edx
f0106ce1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106ce5:	88 c1                	mov    %al,%cl
f0106ce7:	d3 e5                	shl    %cl,%ebp
f0106ce9:	89 f8                	mov    %edi,%eax
f0106ceb:	88 d1                	mov    %dl,%cl
f0106ced:	d3 e8                	shr    %cl,%eax
f0106cef:	09 c5                	or     %eax,%ebp
f0106cf1:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106cf5:	88 c1                	mov    %al,%cl
f0106cf7:	d3 e7                	shl    %cl,%edi
f0106cf9:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0106cfd:	89 df                	mov    %ebx,%edi
f0106cff:	88 d1                	mov    %dl,%cl
f0106d01:	d3 ef                	shr    %cl,%edi
f0106d03:	88 c1                	mov    %al,%cl
f0106d05:	d3 e3                	shl    %cl,%ebx
f0106d07:	89 f0                	mov    %esi,%eax
f0106d09:	88 d1                	mov    %dl,%cl
f0106d0b:	d3 e8                	shr    %cl,%eax
f0106d0d:	09 d8                	or     %ebx,%eax
f0106d0f:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0106d13:	d3 e6                	shl    %cl,%esi
f0106d15:	89 fa                	mov    %edi,%edx
f0106d17:	f7 f5                	div    %ebp
f0106d19:	89 d1                	mov    %edx,%ecx
f0106d1b:	f7 64 24 08          	mull   0x8(%esp)
f0106d1f:	89 c3                	mov    %eax,%ebx
f0106d21:	89 d7                	mov    %edx,%edi
f0106d23:	39 d1                	cmp    %edx,%ecx
f0106d25:	72 29                	jb     f0106d50 <__umoddi3+0xf8>
f0106d27:	74 23                	je     f0106d4c <__umoddi3+0xf4>
f0106d29:	89 ca                	mov    %ecx,%edx
f0106d2b:	29 de                	sub    %ebx,%esi
f0106d2d:	19 fa                	sbb    %edi,%edx
f0106d2f:	89 d0                	mov    %edx,%eax
f0106d31:	8a 4c 24 0c          	mov    0xc(%esp),%cl
f0106d35:	d3 e0                	shl    %cl,%eax
f0106d37:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0106d3b:	88 d9                	mov    %bl,%cl
f0106d3d:	d3 ee                	shr    %cl,%esi
f0106d3f:	09 f0                	or     %esi,%eax
f0106d41:	d3 ea                	shr    %cl,%edx
f0106d43:	83 c4 1c             	add    $0x1c,%esp
f0106d46:	5b                   	pop    %ebx
f0106d47:	5e                   	pop    %esi
f0106d48:	5f                   	pop    %edi
f0106d49:	5d                   	pop    %ebp
f0106d4a:	c3                   	ret    
f0106d4b:	90                   	nop
f0106d4c:	39 c6                	cmp    %eax,%esi
f0106d4e:	73 d9                	jae    f0106d29 <__umoddi3+0xd1>
f0106d50:	2b 44 24 08          	sub    0x8(%esp),%eax
f0106d54:	19 ea                	sbb    %ebp,%edx
f0106d56:	89 d7                	mov    %edx,%edi
f0106d58:	89 c3                	mov    %eax,%ebx
f0106d5a:	eb cd                	jmp    f0106d29 <__umoddi3+0xd1>
