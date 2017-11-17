
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
f0100050:	e8 2f 3f 00 00       	call   f0103f84 <cprintf>
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
f0100065:	e8 2a 0d 00 00       	call   f0100d94 <mon_backtrace>
f010006a:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010006d:	83 ec 08             	sub    $0x8,%esp
f0100070:	53                   	push   %ebx
f0100071:	68 5c 6d 10 f0       	push   $0xf0106d5c
f0100076:	e8 09 3f 00 00       	call   f0103f84 <cprintf>
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
f010009c:	83 3d 80 7e 2a f0 00 	cmpl   $0x0,0xf02a7e80
f01000a3:	74 0f                	je     f01000b4 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000a5:	83 ec 0c             	sub    $0xc,%esp
f01000a8:	6a 00                	push   $0x0
f01000aa:	e8 89 0d 00 00       	call   f0100e38 <monitor>
f01000af:	83 c4 10             	add    $0x10,%esp
f01000b2:	eb f1                	jmp    f01000a5 <_panic+0x11>
	panicstr = fmt;
f01000b4:	89 35 80 7e 2a f0    	mov    %esi,0xf02a7e80
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
f01000d0:	e8 af 3e 00 00       	call   f0103f84 <cprintf>
	vcprintf(fmt, ap);
f01000d5:	83 c4 08             	add    $0x8,%esp
f01000d8:	53                   	push   %ebx
f01000d9:	56                   	push   %esi
f01000da:	e8 7f 3e 00 00       	call   f0103f5e <vcprintf>
	cprintf("\n");
f01000df:	c7 04 24 fb 71 10 f0 	movl   $0xf01071fb,(%esp)
f01000e6:	e8 99 3e 00 00       	call   f0103f84 <cprintf>
f01000eb:	83 c4 10             	add    $0x10,%esp
f01000ee:	eb b5                	jmp    f01000a5 <_panic+0x11>

f01000f0 <i386_init>:
{
f01000f0:	55                   	push   %ebp
f01000f1:	89 e5                	mov    %esp,%ebp
f01000f3:	53                   	push   %ebx
f01000f4:	83 ec 08             	sub    $0x8,%esp
	memset(edata, 0, end - edata);
f01000f7:	b8 08 90 2e f0       	mov    $0xf02e9008,%eax
f01000fc:	2d 3c 65 2a f0       	sub    $0xf02a653c,%eax
f0100101:	50                   	push   %eax
f0100102:	6a 00                	push   $0x0
f0100104:	68 3c 65 2a f0       	push   $0xf02a653c
f0100109:	e8 3b 5f 00 00       	call   f0106049 <memset>
	cons_init();
f010010e:	e8 09 06 00 00       	call   f010071c <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f0100113:	83 c4 08             	add    $0x8,%esp
f0100116:	68 ac 1a 00 00       	push   $0x1aac
f010011b:	68 77 6d 10 f0       	push   $0xf0106d77
f0100120:	e8 5f 3e 00 00       	call   f0103f84 <cprintf>
	mem_init();
f0100125:	e8 f3 16 00 00       	call   f010181d <mem_init>
	cprintf(ANSI_COLOR_RED     "This text is RED!"     ANSI_COLOR_RESET "\n");
f010012a:	c7 04 24 92 6d 10 f0 	movl   $0xf0106d92,(%esp)
f0100131:	e8 4e 3e 00 00       	call   f0103f84 <cprintf>
	cprintf(ANSI_COLOR_GREEN   "This text is GREEN!"   ANSI_COLOR_RESET "\n");
f0100136:	c7 04 24 ae 6d 10 f0 	movl   $0xf0106dae,(%esp)
f010013d:	e8 42 3e 00 00       	call   f0103f84 <cprintf>
	cprintf(ANSI_COLOR_YELLOW  "This text is YELLOW!"  ANSI_COLOR_RESET "\n");
f0100142:	c7 04 24 68 6e 10 f0 	movl   $0xf0106e68,(%esp)
f0100149:	e8 36 3e 00 00       	call   f0103f84 <cprintf>
	cprintf(ANSI_COLOR_BLUE    "This text is BLUE!"    ANSI_COLOR_RESET "\n");
f010014e:	c7 04 24 cc 6d 10 f0 	movl   $0xf0106dcc,(%esp)
f0100155:	e8 2a 3e 00 00       	call   f0103f84 <cprintf>
	cprintf(ANSI_COLOR_MAGENTA "This text is MAGENTA!" ANSI_COLOR_RESET "\n");
f010015a:	c7 04 24 88 6e 10 f0 	movl   $0xf0106e88,(%esp)
f0100161:	e8 1e 3e 00 00       	call   f0103f84 <cprintf>
	cprintf(ANSI_COLOR_CYAN    "This text is CYAN!"    ANSI_COLOR_RESET "\n");
f0100166:	c7 04 24 e9 6d 10 f0 	movl   $0xf0106de9,(%esp)
f010016d:	e8 12 3e 00 00       	call   f0103f84 <cprintf>
	test_backtrace(5);
f0100172:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100179:	e8 c2 fe ff ff       	call   f0100040 <test_backtrace>
	env_init();
f010017e:	e8 b6 34 00 00       	call   f0103639 <env_init>
	trap_init();
f0100183:	e8 b0 3e 00 00       	call   f0104038 <trap_init>
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
f01001a6:	83 3d 88 7e 2a f0 07 	cmpl   $0x7,0xf02a7e88
f01001ad:	76 27                	jbe    f01001d6 <i386_init+0xe6>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001af:	83 ec 04             	sub    $0x4,%esp
f01001b2:	b8 72 63 10 f0       	mov    $0xf0106372,%eax
f01001b7:	2d f8 62 10 f0       	sub    $0xf01062f8,%eax
f01001bc:	50                   	push   %eax
f01001bd:	68 f8 62 10 f0       	push   $0xf01062f8
f01001c2:	68 00 70 00 f0       	push   $0xf0007000
f01001c7:	e8 ca 5e 00 00       	call   f0106096 <memmove>
f01001cc:	83 c4 10             	add    $0x10,%esp
	for (c = cpus; c < cpus + ncpu; c++) {
f01001cf:	bb 20 80 2a f0       	mov    $0xf02a8020,%ebx
f01001d4:	eb 19                	jmp    f01001ef <i386_init+0xff>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001d6:	68 00 70 00 00       	push   $0x7000
f01001db:	68 a8 6e 10 f0       	push   $0xf0106ea8
f01001e0:	6a 76                	push   $0x76
f01001e2:	68 06 6e 10 f0       	push   $0xf0106e06
f01001e7:	e8 a8 fe ff ff       	call   f0100094 <_panic>
f01001ec:	83 c3 74             	add    $0x74,%ebx
f01001ef:	8b 15 c4 83 2a f0    	mov    0xf02a83c4,%edx
f01001f5:	8d 04 12             	lea    (%edx,%edx,1),%eax
f01001f8:	01 d0                	add    %edx,%eax
f01001fa:	01 c0                	add    %eax,%eax
f01001fc:	01 d0                	add    %edx,%eax
f01001fe:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100201:	8d 04 85 20 80 2a f0 	lea    -0xfd57fe0(,%eax,4),%eax
f0100208:	39 c3                	cmp    %eax,%ebx
f010020a:	73 6d                	jae    f0100279 <i386_init+0x189>
		if (c == cpus + cpunum())  // We've started already.
f010020c:	e8 11 65 00 00       	call   f0106722 <cpunum>
f0100211:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100214:	01 c2                	add    %eax,%edx
f0100216:	01 d2                	add    %edx,%edx
f0100218:	01 c2                	add    %eax,%edx
f010021a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010021d:	8d 04 85 20 80 2a f0 	lea    -0xfd57fe0(,%eax,4),%eax
f0100224:	39 c3                	cmp    %eax,%ebx
f0100226:	74 c4                	je     f01001ec <i386_init+0xfc>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100228:	89 d8                	mov    %ebx,%eax
f010022a:	2d 20 80 2a f0       	sub    $0xf02a8020,%eax
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
f010024e:	05 00 10 2b f0       	add    $0xf02b1000,%eax
f0100253:	a3 84 7e 2a f0       	mov    %eax,0xf02a7e84
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
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f0100279:	83 ec 08             	sub    $0x8,%esp
f010027c:	6a 01                	push   $0x1
f010027e:	68 68 85 24 f0       	push   $0xf0248568
f0100283:	e8 03 36 00 00       	call   f010388b <env_create>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100288:	83 c4 08             	add    $0x8,%esp
f010028b:	6a 00                	push   $0x0
f010028d:	68 e8 80 23 f0       	push   $0xf02380e8
f0100292:	e8 f4 35 00 00       	call   f010388b <env_create>
	kbd_intr();
f0100297:	e8 24 04 00 00       	call   f01006c0 <kbd_intr>
	sched_yield();
f010029c:	e8 5d 4b 00 00       	call   f0104dfe <sched_yield>

f01002a1 <mp_main>:
{
f01002a1:	55                   	push   %ebp
f01002a2:	89 e5                	mov    %esp,%ebp
f01002a4:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f01002a7:	a1 8c 7e 2a f0       	mov    0xf02a7e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01002ac:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01002b1:	77 15                	ja     f01002c8 <mp_main+0x27>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01002b3:	50                   	push   %eax
f01002b4:	68 cc 6e 10 f0       	push   $0xf0106ecc
f01002b9:	68 8d 00 00 00       	push   $0x8d
f01002be:	68 06 6e 10 f0       	push   $0xf0106e06
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
f01002d0:	e8 4d 64 00 00       	call   f0106722 <cpunum>
f01002d5:	83 ec 08             	sub    $0x8,%esp
f01002d8:	50                   	push   %eax
f01002d9:	68 12 6e 10 f0       	push   $0xf0106e12
f01002de:	e8 a1 3c 00 00       	call   f0103f84 <cprintf>
	lapic_init();
f01002e3:	e8 55 64 00 00       	call   f010673d <lapic_init>
	env_init_percpu();
f01002e8:	e8 1c 33 00 00       	call   f0103609 <env_init_percpu>
	trap_init_percpu();
f01002ed:	e8 a6 3c 00 00       	call   f0103f98 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01002f2:	e8 2b 64 00 00       	call   f0106722 <cpunum>
f01002f7:	6b d0 74             	imul   $0x74,%eax,%edx
f01002fa:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01002fd:	b8 01 00 00 00       	mov    $0x1,%eax
f0100302:	f0 87 82 20 80 2a f0 	lock xchg %eax,-0xfd57fe0(%edx)
f0100309:	c7 04 24 c0 33 12 f0 	movl   $0xf01233c0,(%esp)
f0100310:	e8 81 66 00 00       	call   f0106996 <spin_lock>
	sched_yield();
f0100315:	e8 e4 4a 00 00       	call   f0104dfe <sched_yield>

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
f010032a:	68 28 6e 10 f0       	push   $0xf0106e28
f010032f:	e8 50 3c 00 00       	call   f0103f84 <cprintf>
	vcprintf(fmt, ap);
f0100334:	83 c4 08             	add    $0x8,%esp
f0100337:	53                   	push   %ebx
f0100338:	ff 75 10             	pushl  0x10(%ebp)
f010033b:	e8 1e 3c 00 00       	call   f0103f5e <vcprintf>
	cprintf("\n");
f0100340:	c7 04 24 fb 71 10 f0 	movl   $0xf01071fb,(%esp)
f0100347:	e8 38 3c 00 00       	call   f0103f84 <cprintf>
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
f0100387:	8b 0d 24 72 2a f0    	mov    0xf02a7224,%ecx
f010038d:	8d 51 01             	lea    0x1(%ecx),%edx
f0100390:	89 15 24 72 2a f0    	mov    %edx,0xf02a7224
f0100396:	88 81 20 70 2a f0    	mov    %al,-0xfd58fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010039c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01003a2:	75 d8                	jne    f010037c <cons_intr+0x9>
			cons.wpos = 0;
f01003a4:	c7 05 24 72 2a f0 00 	movl   $0x0,0xf02a7224
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
f01003eb:	8b 0d 00 70 2a f0    	mov    0xf02a7000,%ecx
f01003f1:	f6 c1 40             	test   $0x40,%cl
f01003f4:	74 0e                	je     f0100404 <kbd_proc_data+0x4e>
		data |= 0x80;
f01003f6:	83 c8 80             	or     $0xffffff80,%eax
f01003f9:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f01003fb:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003fe:	89 0d 00 70 2a f0    	mov    %ecx,0xf02a7000
	shift |= shiftcode[data];
f0100404:	0f b6 d2             	movzbl %dl,%edx
f0100407:	0f b6 82 40 70 10 f0 	movzbl -0xfef8fc0(%edx),%eax
f010040e:	0b 05 00 70 2a f0    	or     0xf02a7000,%eax
	shift ^= togglecode[data];
f0100414:	0f b6 8a 40 6f 10 f0 	movzbl -0xfef90c0(%edx),%ecx
f010041b:	31 c8                	xor    %ecx,%eax
f010041d:	a3 00 70 2a f0       	mov    %eax,0xf02a7000
	c = charcode[shift & (CTL | SHIFT)][data];
f0100422:	89 c1                	mov    %eax,%ecx
f0100424:	83 e1 03             	and    $0x3,%ecx
f0100427:	8b 0c 8d 20 6f 10 f0 	mov    -0xfef90e0(,%ecx,4),%ecx
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
f0100456:	68 f0 6e 10 f0       	push   $0xf0106ef0
f010045b:	e8 24 3b 00 00       	call   f0103f84 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100460:	b0 03                	mov    $0x3,%al
f0100462:	ba 92 00 00 00       	mov    $0x92,%edx
f0100467:	ee                   	out    %al,(%dx)
f0100468:	83 c4 10             	add    $0x10,%esp
f010046b:	eb 0c                	jmp    f0100479 <kbd_proc_data+0xc3>
		shift |= E0ESC;
f010046d:	83 0d 00 70 2a f0 40 	orl    $0x40,0xf02a7000
		return 0;
f0100474:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100479:	89 d8                	mov    %ebx,%eax
f010047b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010047e:	c9                   	leave  
f010047f:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100480:	8b 0d 00 70 2a f0    	mov    0xf02a7000,%ecx
f0100486:	f6 c1 40             	test   $0x40,%cl
f0100489:	75 05                	jne    f0100490 <kbd_proc_data+0xda>
f010048b:	83 e0 7f             	and    $0x7f,%eax
f010048e:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f0100490:	0f b6 d2             	movzbl %dl,%edx
f0100493:	8a 82 40 70 10 f0    	mov    -0xfef8fc0(%edx),%al
f0100499:	83 c8 40             	or     $0x40,%eax
f010049c:	0f b6 c0             	movzbl %al,%eax
f010049f:	f7 d0                	not    %eax
f01004a1:	21 c8                	and    %ecx,%eax
f01004a3:	a3 00 70 2a f0       	mov    %eax,0xf02a7000
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
f0100569:	66 8b 0d 28 72 2a f0 	mov    0xf02a7228,%cx
f0100570:	bb 50 00 00 00       	mov    $0x50,%ebx
f0100575:	89 c8                	mov    %ecx,%eax
f0100577:	ba 00 00 00 00       	mov    $0x0,%edx
f010057c:	66 f7 f3             	div    %bx
f010057f:	29 d1                	sub    %edx,%ecx
f0100581:	66 89 0d 28 72 2a f0 	mov    %cx,0xf02a7228
	if (crt_pos >= CRT_SIZE) {
f0100588:	66 81 3d 28 72 2a f0 	cmpw   $0x7cf,0xf02a7228
f010058f:	cf 07 
f0100591:	0f 87 c5 00 00 00    	ja     f010065c <cons_putc+0x192>
	outb(addr_6845, 14);
f0100597:	8b 0d 30 72 2a f0    	mov    0xf02a7230,%ecx
f010059d:	b0 0e                	mov    $0xe,%al
f010059f:	89 ca                	mov    %ecx,%edx
f01005a1:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005a2:	8d 59 01             	lea    0x1(%ecx),%ebx
f01005a5:	66 a1 28 72 2a f0    	mov    0xf02a7228,%ax
f01005ab:	66 c1 e8 08          	shr    $0x8,%ax
f01005af:	89 da                	mov    %ebx,%edx
f01005b1:	ee                   	out    %al,(%dx)
f01005b2:	b0 0f                	mov    $0xf,%al
f01005b4:	89 ca                	mov    %ecx,%edx
f01005b6:	ee                   	out    %al,(%dx)
f01005b7:	a0 28 72 2a f0       	mov    0xf02a7228,%al
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
f01005cc:	66 a1 28 72 2a f0    	mov    0xf02a7228,%ax
f01005d2:	66 85 c0             	test   %ax,%ax
f01005d5:	74 c0                	je     f0100597 <cons_putc+0xcd>
			crt_pos--;
f01005d7:	48                   	dec    %eax
f01005d8:	66 a3 28 72 2a f0    	mov    %ax,0xf02a7228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01005de:	0f b7 c0             	movzwl %ax,%eax
f01005e1:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f01005e7:	83 cf 20             	or     $0x20,%edi
f01005ea:	8b 15 2c 72 2a f0    	mov    0xf02a722c,%edx
f01005f0:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01005f4:	eb 92                	jmp    f0100588 <cons_putc+0xbe>
		crt_pos += CRT_COLS;
f01005f6:	66 83 05 28 72 2a f0 	addw   $0x50,0xf02a7228
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
f010063a:	66 a1 28 72 2a f0    	mov    0xf02a7228,%ax
f0100640:	8d 50 01             	lea    0x1(%eax),%edx
f0100643:	66 89 15 28 72 2a f0 	mov    %dx,0xf02a7228
f010064a:	0f b7 c0             	movzwl %ax,%eax
f010064d:	8b 15 2c 72 2a f0    	mov    0xf02a722c,%edx
f0100653:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100657:	e9 2c ff ff ff       	jmp    f0100588 <cons_putc+0xbe>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010065c:	a1 2c 72 2a f0       	mov    0xf02a722c,%eax
f0100661:	83 ec 04             	sub    $0x4,%esp
f0100664:	68 00 0f 00 00       	push   $0xf00
f0100669:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010066f:	52                   	push   %edx
f0100670:	50                   	push   %eax
f0100671:	e8 20 5a 00 00       	call   f0106096 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100676:	8b 15 2c 72 2a f0    	mov    0xf02a722c,%edx
f010067c:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100682:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100688:	83 c4 10             	add    $0x10,%esp
f010068b:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100690:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100693:	39 d0                	cmp    %edx,%eax
f0100695:	75 f4                	jne    f010068b <cons_putc+0x1c1>
		crt_pos -= CRT_COLS;
f0100697:	66 83 2d 28 72 2a f0 	subw   $0x50,0xf02a7228
f010069e:	50 
f010069f:	e9 f3 fe ff ff       	jmp    f0100597 <cons_putc+0xcd>

f01006a4 <serial_intr>:
	if (serial_exists)
f01006a4:	80 3d 34 72 2a f0 00 	cmpb   $0x0,0xf02a7234
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
f01006e2:	a1 20 72 2a f0       	mov    0xf02a7220,%eax
f01006e7:	3b 05 24 72 2a f0    	cmp    0xf02a7224,%eax
f01006ed:	74 26                	je     f0100715 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01006ef:	8d 50 01             	lea    0x1(%eax),%edx
f01006f2:	89 15 20 72 2a f0    	mov    %edx,0xf02a7220
f01006f8:	0f b6 80 20 70 2a f0 	movzbl -0xfd58fe0(%eax),%eax
		if (cons.rpos == CONSBUFSIZE)
f01006ff:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100705:	74 02                	je     f0100709 <cons_getc+0x37>
}
f0100707:	c9                   	leave  
f0100708:	c3                   	ret    
			cons.rpos = 0;
f0100709:	c7 05 20 72 2a f0 00 	movl   $0x0,0xf02a7220
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
f0100745:	c7 05 30 72 2a f0 b4 	movl   $0x3b4,0xf02a7230
f010074c:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010074f:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f0100754:	8b 3d 30 72 2a f0    	mov    0xf02a7230,%edi
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
f0100775:	89 35 2c 72 2a f0    	mov    %esi,0xf02a722c
	pos |= inb(addr_6845 + 1);
f010077b:	0f b6 c0             	movzbl %al,%eax
f010077e:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f0100780:	66 a3 28 72 2a f0    	mov    %ax,0xf02a7228
	kbd_intr();
f0100786:	e8 35 ff ff ff       	call   f01006c0 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f010078b:	83 ec 0c             	sub    $0xc,%esp
f010078e:	66 a1 a8 33 12 f0    	mov    0xf01233a8,%ax
f0100794:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100799:	50                   	push   %eax
f010079a:	e8 a0 36 00 00       	call   f0103e3f <irq_setmask_8259A>
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
f01007e6:	0f 95 05 34 72 2a f0 	setne  0xf02a7234
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
f01007fe:	68 fc 6e 10 f0       	push   $0xf0106efc
f0100803:	e8 7c 37 00 00       	call   f0103f84 <cprintf>
f0100808:	83 c4 10             	add    $0x10,%esp
}
f010080b:	eb 3b                	jmp    f0100848 <cons_init+0x12c>
		*cp = was;
f010080d:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100814:	c7 05 30 72 2a f0 d4 	movl   $0x3d4,0xf02a7230
f010081b:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010081e:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f0100823:	e9 2c ff ff ff       	jmp    f0100754 <cons_init+0x38>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f0100828:	83 ec 0c             	sub    $0xc,%esp
f010082b:	66 a1 a8 33 12 f0    	mov    0xf01233a8,%ax
f0100831:	25 ef ff 00 00       	and    $0xffef,%eax
f0100836:	50                   	push   %eax
f0100837:	e8 03 36 00 00       	call   f0103e3f <irq_setmask_8259A>
	if (!serial_exists)
f010083c:	83 c4 10             	add    $0x10,%esp
f010083f:	80 3d 34 72 2a f0 00 	cmpb   $0x0,0xf02a7234
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
f010087e:	53                   	push   %ebx
f010087f:	83 ec 04             	sub    $0x4,%esp
f0100882:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100887:	83 ec 04             	sub    $0x4,%esp
f010088a:	ff b3 24 76 10 f0    	pushl  -0xfef89dc(%ebx)
f0100890:	ff b3 20 76 10 f0    	pushl  -0xfef89e0(%ebx)
f0100896:	68 40 71 10 f0       	push   $0xf0107140
f010089b:	e8 e4 36 00 00       	call   f0103f84 <cprintf>
f01008a0:	83 c3 0c             	add    $0xc,%ebx
	for (i = 0; i < ARRAY_SIZE(commands); i++)
f01008a3:	83 c4 10             	add    $0x10,%esp
f01008a6:	83 fb 3c             	cmp    $0x3c,%ebx
f01008a9:	75 dc                	jne    f0100887 <mon_help+0xc>
	return 0;
}
f01008ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01008b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01008b3:	c9                   	leave  
f01008b4:	c3                   	ret    

f01008b5 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01008b5:	55                   	push   %ebp
f01008b6:	89 e5                	mov    %esp,%ebp
f01008b8:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01008bb:	68 49 71 10 f0       	push   $0xf0107149
f01008c0:	e8 bf 36 00 00       	call   f0103f84 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01008c5:	83 c4 08             	add    $0x8,%esp
f01008c8:	68 0c 00 10 00       	push   $0x10000c
f01008cd:	68 a0 72 10 f0       	push   $0xf01072a0
f01008d2:	e8 ad 36 00 00       	call   f0103f84 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01008d7:	83 c4 0c             	add    $0xc,%esp
f01008da:	68 0c 00 10 00       	push   $0x10000c
f01008df:	68 0c 00 10 f0       	push   $0xf010000c
f01008e4:	68 c8 72 10 f0       	push   $0xf01072c8
f01008e9:	e8 96 36 00 00       	call   f0103f84 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01008ee:	83 c4 0c             	add    $0xc,%esp
f01008f1:	68 3c 6d 10 00       	push   $0x106d3c
f01008f6:	68 3c 6d 10 f0       	push   $0xf0106d3c
f01008fb:	68 ec 72 10 f0       	push   $0xf01072ec
f0100900:	e8 7f 36 00 00       	call   f0103f84 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100905:	83 c4 0c             	add    $0xc,%esp
f0100908:	68 3c 65 2a 00       	push   $0x2a653c
f010090d:	68 3c 65 2a f0       	push   $0xf02a653c
f0100912:	68 10 73 10 f0       	push   $0xf0107310
f0100917:	e8 68 36 00 00       	call   f0103f84 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010091c:	83 c4 0c             	add    $0xc,%esp
f010091f:	68 08 90 2e 00       	push   $0x2e9008
f0100924:	68 08 90 2e f0       	push   $0xf02e9008
f0100929:	68 34 73 10 f0       	push   $0xf0107334
f010092e:	e8 51 36 00 00       	call   f0103f84 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100933:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100936:	b8 07 94 2e f0       	mov    $0xf02e9407,%eax
f010093b:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100940:	c1 f8 0a             	sar    $0xa,%eax
f0100943:	50                   	push   %eax
f0100944:	68 58 73 10 f0       	push   $0xf0107358
f0100949:	e8 36 36 00 00       	call   f0103f84 <cprintf>
	return 0;
}
f010094e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100953:	c9                   	leave  
f0100954:	c3                   	ret    

f0100955 <mon_showmap>:
	}
	return 0;
}

int 
mon_showmap(int argc, char **argv, struct Trapframe *tf) {
f0100955:	55                   	push   %ebp
f0100956:	89 e5                	mov    %esp,%ebp
f0100958:	56                   	push   %esi
f0100959:	53                   	push   %ebx
f010095a:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc <= 2) {
f010095d:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100961:	7e 3c                	jle    f010099f <mon_showmap+0x4a>
		cprintf("Usage: showmap l r\n");
		return 0;
	}
	uintptr_t l = strtoul(argv[1], NULL, 0), 
f0100963:	83 ec 04             	sub    $0x4,%esp
f0100966:	6a 00                	push   $0x0
f0100968:	6a 00                	push   $0x0
f010096a:	ff 76 04             	pushl  0x4(%esi)
f010096d:	e8 b8 58 00 00       	call   f010622a <strtoul>
f0100972:	89 c3                	mov    %eax,%ebx
		 	  r = strtoul(argv[2], NULL, 0); // In string.h
f0100974:	83 c4 0c             	add    $0xc,%esp
f0100977:	6a 00                	push   $0x0
f0100979:	6a 00                	push   $0x0
f010097b:	ff 76 08             	pushl  0x8(%esi)
f010097e:	e8 a7 58 00 00       	call   f010622a <strtoul>
	if (l > r) {
f0100983:	83 c4 10             	add    $0x10,%esp
f0100986:	39 c3                	cmp    %eax,%ebx
f0100988:	77 31                	ja     f01009bb <mon_showmap+0x66>
		cprintf("Invalid range; aborting.\n");
		return 0;
	}
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f010098a:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f0100990:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0100996:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010099b:	89 c6                	mov    %eax,%esi
f010099d:	eb 45                	jmp    f01009e4 <mon_showmap+0x8f>
		cprintf("Usage: showmap l r\n");
f010099f:	83 ec 0c             	sub    $0xc,%esp
f01009a2:	68 62 71 10 f0       	push   $0xf0107162
f01009a7:	e8 d8 35 00 00       	call   f0103f84 <cprintf>
		return 0;
f01009ac:	83 c4 10             	add    $0x10,%esp
		else 
			cprintf("0x%08x -> 0x%08x; perm = 0x%03x\n", 
					sz, PTE_ADDR(*pte), *pte & 0xFFF);
	}
	return 0;
}
f01009af:	b8 00 00 00 00       	mov    $0x0,%eax
f01009b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01009b7:	5b                   	pop    %ebx
f01009b8:	5e                   	pop    %esi
f01009b9:	5d                   	pop    %ebp
f01009ba:	c3                   	ret    
		cprintf("Invalid range; aborting.\n");
f01009bb:	83 ec 0c             	sub    $0xc,%esp
f01009be:	68 76 71 10 f0       	push   $0xf0107176
f01009c3:	e8 bc 35 00 00       	call   f0103f84 <cprintf>
		return 0;
f01009c8:	83 c4 10             	add    $0x10,%esp
f01009cb:	eb e2                	jmp    f01009af <mon_showmap+0x5a>
			cprintf("0x%08x -> ----------; perm = ---\n", sz);
f01009cd:	83 ec 08             	sub    $0x8,%esp
f01009d0:	53                   	push   %ebx
f01009d1:	68 84 73 10 f0       	push   $0xf0107384
f01009d6:	e8 a9 35 00 00       	call   f0103f84 <cprintf>
f01009db:	83 c4 10             	add    $0x10,%esp
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f01009de:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01009e4:	39 f3                	cmp    %esi,%ebx
f01009e6:	77 c7                	ja     f01009af <mon_showmap+0x5a>
		pte_t* pte = pgdir_walk(kern_pgdir, (void*) sz, 0);
f01009e8:	83 ec 04             	sub    $0x4,%esp
f01009eb:	6a 00                	push   $0x0
f01009ed:	53                   	push   %ebx
f01009ee:	ff 35 8c 7e 2a f0    	pushl  0xf02a7e8c
f01009f4:	e8 ed 0a 00 00       	call   f01014e6 <pgdir_walk>
		if (pte == NULL || !*pte)
f01009f9:	83 c4 10             	add    $0x10,%esp
f01009fc:	85 c0                	test   %eax,%eax
f01009fe:	74 cd                	je     f01009cd <mon_showmap+0x78>
f0100a00:	8b 00                	mov    (%eax),%eax
f0100a02:	85 c0                	test   %eax,%eax
f0100a04:	74 c7                	je     f01009cd <mon_showmap+0x78>
			cprintf("0x%08x -> 0x%08x; perm = 0x%03x\n", 
f0100a06:	89 c2                	mov    %eax,%edx
f0100a08:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f0100a0e:	52                   	push   %edx
f0100a0f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a14:	50                   	push   %eax
f0100a15:	53                   	push   %ebx
f0100a16:	68 a8 73 10 f0       	push   $0xf01073a8
f0100a1b:	e8 64 35 00 00       	call   f0103f84 <cprintf>
f0100a20:	83 c4 10             	add    $0x10,%esp
f0100a23:	eb b9                	jmp    f01009de <mon_showmap+0x89>

f0100a25 <mon_chmod>:

int
mon_chmod(int argc, char **argv, struct Trapframe *tf) {
f0100a25:	55                   	push   %ebp
f0100a26:	89 e5                	mov    %esp,%ebp
f0100a28:	57                   	push   %edi
f0100a29:	56                   	push   %esi
f0100a2a:	53                   	push   %ebx
f0100a2b:	83 ec 1c             	sub    $0x1c,%esp
f0100a2e:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc <= 2) {
f0100a31:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100a35:	7e 67                	jle    f0100a9e <mon_chmod+0x79>
		cprintf("Usage: chmod mod l [r] [-v]\n");
		return 0;
	}
	uintptr_t mod = strtoul(argv[1], NULL, 0),  
f0100a37:	83 ec 04             	sub    $0x4,%esp
f0100a3a:	6a 00                	push   $0x0
f0100a3c:	6a 00                	push   $0x0
f0100a3e:	ff 76 04             	pushl  0x4(%esi)
f0100a41:	e8 e4 57 00 00       	call   f010622a <strtoul>
f0100a46:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			  l = strtoul(argv[2], NULL, 0), 
f0100a49:	83 c4 0c             	add    $0xc,%esp
f0100a4c:	6a 00                	push   $0x0
f0100a4e:	6a 00                	push   $0x0
f0100a50:	ff 76 08             	pushl  0x8(%esi)
f0100a53:	e8 d2 57 00 00       	call   f010622a <strtoul>
f0100a58:	89 c3                	mov    %eax,%ebx
			  r = argc >= 4 ? strtoul(argv[3], NULL, 0) : l;
f0100a5a:	83 c4 10             	add    $0x10,%esp
f0100a5d:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100a61:	7f 58                	jg     f0100abb <mon_chmod+0x96>
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
	if (mod > 0xFFF) {
f0100a63:	81 7d e4 ff 0f 00 00 	cmpl   $0xfff,-0x1c(%ebp)
f0100a6a:	0f 87 9a 00 00 00    	ja     f0100b0a <mon_chmod+0xe5>
			  r = argc >= 4 ? strtoul(argv[3], NULL, 0) : l;
f0100a70:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
f0100a73:	bf 00 00 00 00       	mov    $0x0,%edi
	}
	if (l > r) {
		cprintf("Invalid range; aborting.\n");
		return 0;
	}
	if (!(mod & PTE_P)) {
f0100a78:	f6 45 e4 01          	testb  $0x1,-0x1c(%ebp)
f0100a7c:	0f 84 9a 00 00 00    	je     f0100b1c <mon_chmod+0xf7>
		cprintf("Warning: PTE_P flag is not provided; added automatically.");
		mod |= PTE_P;
	}
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f0100a82:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f0100a88:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0100a8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a91:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a96:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100a99:	e9 a1 00 00 00       	jmp    f0100b3f <mon_chmod+0x11a>
		cprintf("Usage: chmod mod l [r] [-v]\n");
f0100a9e:	83 ec 0c             	sub    $0xc,%esp
f0100aa1:	68 90 71 10 f0       	push   $0xf0107190
f0100aa6:	e8 d9 34 00 00       	call   f0103f84 <cprintf>
		return 0;
f0100aab:	83 c4 10             	add    $0x10,%esp
						sz, *pte & 0xFFF, mod);
			*pte = PTE_ADDR(*pte) | mod;
		}
	}
	return 0;
}
f0100aae:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ab3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ab6:	5b                   	pop    %ebx
f0100ab7:	5e                   	pop    %esi
f0100ab8:	5f                   	pop    %edi
f0100ab9:	5d                   	pop    %ebp
f0100aba:	c3                   	ret    
			  r = argc >= 4 ? strtoul(argv[3], NULL, 0) : l;
f0100abb:	83 ec 04             	sub    $0x4,%esp
f0100abe:	6a 00                	push   $0x0
f0100ac0:	6a 00                	push   $0x0
f0100ac2:	ff 76 0c             	pushl  0xc(%esi)
f0100ac5:	e8 60 57 00 00       	call   f010622a <strtoul>
f0100aca:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
f0100acd:	83 c4 08             	add    $0x8,%esp
f0100ad0:	68 ad 71 10 f0       	push   $0xf01071ad
f0100ad5:	ff 76 0c             	pushl  0xc(%esi)
f0100ad8:	e8 e3 54 00 00       	call   f0105fc0 <strcmp>
f0100add:	83 c4 10             	add    $0x10,%esp
f0100ae0:	85 c0                	test   %eax,%eax
f0100ae2:	0f 94 c0             	sete   %al
f0100ae5:	0f b6 c0             	movzbl %al,%eax
f0100ae8:	89 c7                	mov    %eax,%edi
	if (mod > 0xFFF) {
f0100aea:	81 7d e4 ff 0f 00 00 	cmpl   $0xfff,-0x1c(%ebp)
f0100af1:	77 17                	ja     f0100b0a <mon_chmod+0xe5>
	if (l > r) {
f0100af3:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0100af6:	76 80                	jbe    f0100a78 <mon_chmod+0x53>
		cprintf("Invalid range; aborting.\n");
f0100af8:	83 ec 0c             	sub    $0xc,%esp
f0100afb:	68 76 71 10 f0       	push   $0xf0107176
f0100b00:	e8 7f 34 00 00       	call   f0103f84 <cprintf>
		return 0;
f0100b05:	83 c4 10             	add    $0x10,%esp
f0100b08:	eb a4                	jmp    f0100aae <mon_chmod+0x89>
		cprintf("Permission exceeds 0xfff; aborting.\n");
f0100b0a:	83 ec 0c             	sub    $0xc,%esp
f0100b0d:	68 cc 73 10 f0       	push   $0xf01073cc
f0100b12:	e8 6d 34 00 00       	call   f0103f84 <cprintf>
		return 0;
f0100b17:	83 c4 10             	add    $0x10,%esp
f0100b1a:	eb 92                	jmp    f0100aae <mon_chmod+0x89>
		cprintf("Warning: PTE_P flag is not provided; added automatically.");
f0100b1c:	83 ec 0c             	sub    $0xc,%esp
f0100b1f:	68 f4 73 10 f0       	push   $0xf01073f4
f0100b24:	e8 5b 34 00 00       	call   f0103f84 <cprintf>
		mod |= PTE_P;
f0100b29:	83 4d e4 01          	orl    $0x1,-0x1c(%ebp)
f0100b2d:	83 c4 10             	add    $0x10,%esp
f0100b30:	e9 4d ff ff ff       	jmp    f0100a82 <mon_chmod+0x5d>
			if (verbose)
f0100b35:	85 ff                	test   %edi,%edi
f0100b37:	75 41                	jne    f0100b7a <mon_chmod+0x155>
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f0100b39:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100b3f:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0100b42:	0f 87 66 ff ff ff    	ja     f0100aae <mon_chmod+0x89>
		pte_t* pte = pgdir_walk(kern_pgdir, (void*) sz, 0);
f0100b48:	83 ec 04             	sub    $0x4,%esp
f0100b4b:	6a 00                	push   $0x0
f0100b4d:	53                   	push   %ebx
f0100b4e:	ff 35 8c 7e 2a f0    	pushl  0xf02a7e8c
f0100b54:	e8 8d 09 00 00       	call   f01014e6 <pgdir_walk>
f0100b59:	89 c6                	mov    %eax,%esi
		if (pte == NULL || !*pte) {
f0100b5b:	83 c4 10             	add    $0x10,%esp
f0100b5e:	85 c0                	test   %eax,%eax
f0100b60:	74 d3                	je     f0100b35 <mon_chmod+0x110>
f0100b62:	8b 00                	mov    (%eax),%eax
f0100b64:	85 c0                	test   %eax,%eax
f0100b66:	74 cd                	je     f0100b35 <mon_chmod+0x110>
			if (verbose) 
f0100b68:	85 ff                	test   %edi,%edi
f0100b6a:	75 21                	jne    f0100b8d <mon_chmod+0x168>
			*pte = PTE_ADDR(*pte) | mod;
f0100b6c:	8b 06                	mov    (%esi),%eax
f0100b6e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b73:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0100b76:	89 06                	mov    %eax,(%esi)
f0100b78:	eb bf                	jmp    f0100b39 <mon_chmod+0x114>
				cprintf("Page va = 0x%08x is not mapped; skipping.\n", sz);
f0100b7a:	83 ec 08             	sub    $0x8,%esp
f0100b7d:	53                   	push   %ebx
f0100b7e:	68 30 74 10 f0       	push   $0xf0107430
f0100b83:	e8 fc 33 00 00       	call   f0103f84 <cprintf>
f0100b88:	83 c4 10             	add    $0x10,%esp
f0100b8b:	eb ac                	jmp    f0100b39 <mon_chmod+0x114>
				cprintf("Page va = 0x%08x perm = 0x%03x changed to 0x%03x\n", 
f0100b8d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100b90:	25 ff 0f 00 00       	and    $0xfff,%eax
f0100b95:	50                   	push   %eax
f0100b96:	53                   	push   %ebx
f0100b97:	68 5c 74 10 f0       	push   $0xf010745c
f0100b9c:	e8 e3 33 00 00       	call   f0103f84 <cprintf>
f0100ba1:	83 c4 10             	add    $0x10,%esp
f0100ba4:	eb c6                	jmp    f0100b6c <mon_chmod+0x147>

f0100ba6 <mon_dump>:

int
mon_dump(int argc, char **argv, struct Trapframe *tf) {
f0100ba6:	55                   	push   %ebp
f0100ba7:	89 e5                	mov    %esp,%ebp
f0100ba9:	57                   	push   %edi
f0100baa:	56                   	push   %esi
f0100bab:	53                   	push   %ebx
f0100bac:	83 ec 1c             	sub    $0x1c,%esp
f0100baf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (argc <= 2 || argc > 4) {
f0100bb2:	8d 43 fd             	lea    -0x3(%ebx),%eax
f0100bb5:	83 f8 01             	cmp    $0x1,%eax
f0100bb8:	76 1d                	jbe    f0100bd7 <mon_dump+0x31>
		cprintf("Usage: dump l r [-v/-p]\n");
f0100bba:	83 ec 0c             	sub    $0xc,%esp
f0100bbd:	68 b0 71 10 f0       	push   $0xf01071b0
f0100bc2:	e8 bd 33 00 00       	call   f0103f84 <cprintf>
		return 0;
f0100bc7:	83 c4 10             	add    $0x10,%esp
		cprintf("|\n");
	}
	if (ROUNDDOWN(r, 16) != r)
		cprintf("%08x  \n", r);
	return 0;
}
f0100bca:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100bd2:	5b                   	pop    %ebx
f0100bd3:	5e                   	pop    %esi
f0100bd4:	5f                   	pop    %edi
f0100bd5:	5d                   	pop    %ebp
f0100bd6:	c3                   	ret    
	unsigned long l = strtoul(argv[1], NULL, 0),
f0100bd7:	83 ec 04             	sub    $0x4,%esp
f0100bda:	6a 00                	push   $0x0
f0100bdc:	6a 00                	push   $0x0
f0100bde:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100be1:	ff 70 04             	pushl  0x4(%eax)
f0100be4:	e8 41 56 00 00       	call   f010622a <strtoul>
f0100be9:	89 c6                	mov    %eax,%esi
			  	  r = strtoul(argv[2], NULL, 0);
f0100beb:	83 c4 0c             	add    $0xc,%esp
f0100bee:	6a 00                	push   $0x0
f0100bf0:	6a 00                	push   $0x0
f0100bf2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100bf5:	ff 70 08             	pushl  0x8(%eax)
f0100bf8:	e8 2d 56 00 00       	call   f010622a <strtoul>
f0100bfd:	89 c7                	mov    %eax,%edi
	if (argc <= 3)
f0100bff:	83 c4 10             	add    $0x10,%esp
f0100c02:	83 fb 03             	cmp    $0x3,%ebx
f0100c05:	7f 18                	jg     f0100c1f <mon_dump+0x79>
		cprintf("Defaulting to virtual address.\n");
f0100c07:	83 ec 0c             	sub    $0xc,%esp
f0100c0a:	68 90 74 10 f0       	push   $0xf0107490
f0100c0f:	e8 70 33 00 00       	call   f0103f84 <cprintf>
f0100c14:	83 c4 10             	add    $0x10,%esp
	for (ptr = ROUNDDOWN(l, 16); ptr <= r; ptr += 16) {
f0100c17:	83 e6 f0             	and    $0xfffffff0,%esi
f0100c1a:	e9 31 01 00 00       	jmp    f0100d50 <mon_dump+0x1aa>
	else if (!strcmp(argv[3], "-p"))
f0100c1f:	83 ec 08             	sub    $0x8,%esp
f0100c22:	68 c9 71 10 f0       	push   $0xf01071c9
f0100c27:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c2a:	ff 70 0c             	pushl  0xc(%eax)
f0100c2d:	e8 8e 53 00 00       	call   f0105fc0 <strcmp>
f0100c32:	83 c4 10             	add    $0x10,%esp
f0100c35:	85 c0                	test   %eax,%eax
f0100c37:	75 4f                	jne    f0100c88 <mon_dump+0xe2>
	if (PGNUM(pa) >= npages)
f0100c39:	a1 88 7e 2a f0       	mov    0xf02a7e88,%eax
f0100c3e:	89 f2                	mov    %esi,%edx
f0100c40:	c1 ea 0c             	shr    $0xc,%edx
f0100c43:	39 c2                	cmp    %eax,%edx
f0100c45:	73 17                	jae    f0100c5e <mon_dump+0xb8>
	return (void *)(pa + KERNBASE);
f0100c47:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
	if (PGNUM(pa) >= npages)
f0100c4d:	89 fa                	mov    %edi,%edx
f0100c4f:	c1 ea 0c             	shr    $0xc,%edx
f0100c52:	39 c2                	cmp    %eax,%edx
f0100c54:	73 1d                	jae    f0100c73 <mon_dump+0xcd>
	return (void *)(pa + KERNBASE);
f0100c56:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
f0100c5c:	eb b9                	jmp    f0100c17 <mon_dump+0x71>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c5e:	56                   	push   %esi
f0100c5f:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0100c64:	68 9d 00 00 00       	push   $0x9d
f0100c69:	68 cc 71 10 f0       	push   $0xf01071cc
f0100c6e:	e8 21 f4 ff ff       	call   f0100094 <_panic>
f0100c73:	57                   	push   %edi
f0100c74:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0100c79:	68 9d 00 00 00       	push   $0x9d
f0100c7e:	68 cc 71 10 f0       	push   $0xf01071cc
f0100c83:	e8 0c f4 ff ff       	call   f0100094 <_panic>
	else if (strcmp(argv[3], "-v")) {
f0100c88:	83 ec 08             	sub    $0x8,%esp
f0100c8b:	68 ad 71 10 f0       	push   $0xf01071ad
f0100c90:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c93:	ff 70 0c             	pushl  0xc(%eax)
f0100c96:	e8 25 53 00 00       	call   f0105fc0 <strcmp>
f0100c9b:	83 c4 10             	add    $0x10,%esp
f0100c9e:	85 c0                	test   %eax,%eax
f0100ca0:	0f 84 71 ff ff ff    	je     f0100c17 <mon_dump+0x71>
		cprintf("Unknown flag %s at position 3; aborting.\n", argv[3]);
f0100ca6:	83 ec 08             	sub    $0x8,%esp
f0100ca9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100cac:	ff 70 0c             	pushl  0xc(%eax)
f0100caf:	68 b0 74 10 f0       	push   $0xf01074b0
f0100cb4:	e8 cb 32 00 00       	call   f0103f84 <cprintf>
		return 0;
f0100cb9:	83 c4 10             	add    $0x10,%esp
f0100cbc:	e9 09 ff ff ff       	jmp    f0100bca <mon_dump+0x24>
				cprintf("   ");
f0100cc1:	83 ec 0c             	sub    $0xc,%esp
f0100cc4:	68 e8 71 10 f0       	push   $0xf01071e8
f0100cc9:	e8 b6 32 00 00       	call   f0103f84 <cprintf>
f0100cce:	83 c4 10             	add    $0x10,%esp
f0100cd1:	43                   	inc    %ebx
		for (int i = 0; i < 16; i++) {
f0100cd2:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0100cd5:	74 1a                	je     f0100cf1 <mon_dump+0x14b>
			if (ptr + i <= r)
f0100cd7:	39 df                	cmp    %ebx,%edi
f0100cd9:	72 e6                	jb     f0100cc1 <mon_dump+0x11b>
				cprintf("%02x ", *(unsigned char*)(ptr + i));
f0100cdb:	83 ec 08             	sub    $0x8,%esp
f0100cde:	0f b6 03             	movzbl (%ebx),%eax
f0100ce1:	50                   	push   %eax
f0100ce2:	68 e2 71 10 f0       	push   $0xf01071e2
f0100ce7:	e8 98 32 00 00       	call   f0103f84 <cprintf>
f0100cec:	83 c4 10             	add    $0x10,%esp
f0100cef:	eb e0                	jmp    f0100cd1 <mon_dump+0x12b>
		cprintf(" |");
f0100cf1:	83 ec 0c             	sub    $0xc,%esp
f0100cf4:	68 ec 71 10 f0       	push   $0xf01071ec
f0100cf9:	e8 86 32 00 00       	call   f0103f84 <cprintf>
f0100cfe:	83 c4 10             	add    $0x10,%esp
f0100d01:	eb 19                	jmp    f0100d1c <mon_dump+0x176>
				cprintf("%c", (ch >= ' ' && ch <= '~') ? ch : '.');
f0100d03:	83 ec 08             	sub    $0x8,%esp
f0100d06:	0f be c0             	movsbl %al,%eax
f0100d09:	50                   	push   %eax
f0100d0a:	68 ef 71 10 f0       	push   $0xf01071ef
f0100d0f:	e8 70 32 00 00       	call   f0103f84 <cprintf>
f0100d14:	83 c4 10             	add    $0x10,%esp
f0100d17:	46                   	inc    %esi
		for (int i = 0; i < 16; i++) {
f0100d18:	39 de                	cmp    %ebx,%esi
f0100d1a:	74 24                	je     f0100d40 <mon_dump+0x19a>
			if (ptr + i <= r) {
f0100d1c:	39 f7                	cmp    %esi,%edi
f0100d1e:	72 0e                	jb     f0100d2e <mon_dump+0x188>
				char ch = *(char*)(ptr + i);
f0100d20:	8a 06                	mov    (%esi),%al
				cprintf("%c", (ch >= ' ' && ch <= '~') ? ch : '.');
f0100d22:	8d 50 e0             	lea    -0x20(%eax),%edx
f0100d25:	80 fa 5e             	cmp    $0x5e,%dl
f0100d28:	76 d9                	jbe    f0100d03 <mon_dump+0x15d>
f0100d2a:	b0 2e                	mov    $0x2e,%al
f0100d2c:	eb d5                	jmp    f0100d03 <mon_dump+0x15d>
				cprintf(" ");
f0100d2e:	83 ec 0c             	sub    $0xc,%esp
f0100d31:	68 2c 72 10 f0       	push   $0xf010722c
f0100d36:	e8 49 32 00 00       	call   f0103f84 <cprintf>
f0100d3b:	83 c4 10             	add    $0x10,%esp
f0100d3e:	eb d7                	jmp    f0100d17 <mon_dump+0x171>
		cprintf("|\n");
f0100d40:	83 ec 0c             	sub    $0xc,%esp
f0100d43:	68 f2 71 10 f0       	push   $0xf01071f2
f0100d48:	e8 37 32 00 00       	call   f0103f84 <cprintf>
	for (ptr = ROUNDDOWN(l, 16); ptr <= r; ptr += 16) {
f0100d4d:	83 c4 10             	add    $0x10,%esp
f0100d50:	39 f7                	cmp    %esi,%edi
f0100d52:	72 1e                	jb     f0100d72 <mon_dump+0x1cc>
		cprintf("%08x  ", ptr);
f0100d54:	83 ec 08             	sub    $0x8,%esp
f0100d57:	56                   	push   %esi
f0100d58:	68 db 71 10 f0       	push   $0xf01071db
f0100d5d:	e8 22 32 00 00       	call   f0103f84 <cprintf>
f0100d62:	8d 46 10             	lea    0x10(%esi),%eax
f0100d65:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100d68:	83 c4 10             	add    $0x10,%esp
f0100d6b:	89 f3                	mov    %esi,%ebx
f0100d6d:	e9 65 ff ff ff       	jmp    f0100cd7 <mon_dump+0x131>
	if (ROUNDDOWN(r, 16) != r)
f0100d72:	f7 c7 0f 00 00 00    	test   $0xf,%edi
f0100d78:	0f 84 4c fe ff ff    	je     f0100bca <mon_dump+0x24>
		cprintf("%08x  \n", r);
f0100d7e:	83 ec 08             	sub    $0x8,%esp
f0100d81:	57                   	push   %edi
f0100d82:	68 f5 71 10 f0       	push   $0xf01071f5
f0100d87:	e8 f8 31 00 00       	call   f0103f84 <cprintf>
f0100d8c:	83 c4 10             	add    $0x10,%esp
f0100d8f:	e9 36 fe ff ff       	jmp    f0100bca <mon_dump+0x24>

f0100d94 <mon_backtrace>:
{
f0100d94:	55                   	push   %ebp
f0100d95:	89 e5                	mov    %esp,%ebp
f0100d97:	57                   	push   %edi
f0100d98:	56                   	push   %esi
f0100d99:	53                   	push   %ebx
f0100d9a:	83 ec 38             	sub    $0x38,%esp
	cprintf("Stack backtrace:\n");
f0100d9d:	68 fd 71 10 f0       	push   $0xf01071fd
f0100da2:	e8 dd 31 00 00       	call   f0103f84 <cprintf>
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100da7:	89 e8                	mov    %ebp,%eax
	while (ebp != 0) {
f0100da9:	83 c4 10             	add    $0x10,%esp
f0100dac:	eb 34                	jmp    f0100de2 <mon_backtrace+0x4e>
			cprintf("%c", info.eip_fn_name[i]);
f0100dae:	83 ec 08             	sub    $0x8,%esp
f0100db1:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100db4:	0f be 04 18          	movsbl (%eax,%ebx,1),%eax
f0100db8:	50                   	push   %eax
f0100db9:	68 ef 71 10 f0       	push   $0xf01071ef
f0100dbe:	e8 c1 31 00 00       	call   f0103f84 <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f0100dc3:	43                   	inc    %ebx
f0100dc4:	83 c4 10             	add    $0x10,%esp
f0100dc7:	39 5d dc             	cmp    %ebx,-0x24(%ebp)
f0100dca:	7f e2                	jg     f0100dae <mon_backtrace+0x1a>
		cprintf("+%d\n", eip - info.eip_fn_addr);
f0100dcc:	83 ec 08             	sub    $0x8,%esp
f0100dcf:	2b 75 e0             	sub    -0x20(%ebp),%esi
f0100dd2:	56                   	push   %esi
f0100dd3:	68 20 72 10 f0       	push   $0xf0107220
f0100dd8:	e8 a7 31 00 00       	call   f0103f84 <cprintf>
		ebp = prev_ebp;
f0100ddd:	83 c4 10             	add    $0x10,%esp
f0100de0:	89 f8                	mov    %edi,%eax
	while (ebp != 0) {
f0100de2:	85 c0                	test   %eax,%eax
f0100de4:	74 4a                	je     f0100e30 <mon_backtrace+0x9c>
		prev_ebp = *(int*)ebp;
f0100de6:	8b 38                	mov    (%eax),%edi
		eip = *((int*)ebp + 1);
f0100de8:	8b 70 04             	mov    0x4(%eax),%esi
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, 
f0100deb:	ff 70 18             	pushl  0x18(%eax)
f0100dee:	ff 70 14             	pushl  0x14(%eax)
f0100df1:	ff 70 10             	pushl  0x10(%eax)
f0100df4:	ff 70 0c             	pushl  0xc(%eax)
f0100df7:	ff 70 08             	pushl  0x8(%eax)
f0100dfa:	56                   	push   %esi
f0100dfb:	50                   	push   %eax
f0100dfc:	68 dc 74 10 f0       	push   $0xf01074dc
f0100e01:	e8 7e 31 00 00       	call   f0103f84 <cprintf>
		int code = debuginfo_eip((uintptr_t)eip, &info);
f0100e06:	83 c4 18             	add    $0x18,%esp
f0100e09:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100e0c:	50                   	push   %eax
f0100e0d:	56                   	push   %esi
f0100e0e:	e8 e5 47 00 00       	call   f01055f8 <debuginfo_eip>
		cprintf("         %s:%d: ", info.eip_file, info.eip_line);
f0100e13:	83 c4 0c             	add    $0xc,%esp
f0100e16:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100e19:	ff 75 d0             	pushl  -0x30(%ebp)
f0100e1c:	68 0f 72 10 f0       	push   $0xf010720f
f0100e21:	e8 5e 31 00 00       	call   f0103f84 <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f0100e26:	83 c4 10             	add    $0x10,%esp
f0100e29:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e2e:	eb 97                	jmp    f0100dc7 <mon_backtrace+0x33>
}
f0100e30:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e33:	5b                   	pop    %ebx
f0100e34:	5e                   	pop    %esi
f0100e35:	5f                   	pop    %edi
f0100e36:	5d                   	pop    %ebp
f0100e37:	c3                   	ret    

f0100e38 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100e38:	55                   	push   %ebp
f0100e39:	89 e5                	mov    %esp,%ebp
f0100e3b:	57                   	push   %edi
f0100e3c:	56                   	push   %esi
f0100e3d:	53                   	push   %ebx
f0100e3e:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100e41:	68 14 75 10 f0       	push   $0xf0107514
f0100e46:	e8 39 31 00 00       	call   f0103f84 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100e4b:	c7 04 24 38 75 10 f0 	movl   $0xf0107538,(%esp)
f0100e52:	e8 2d 31 00 00       	call   f0103f84 <cprintf>

	if (tf != NULL)
f0100e57:	83 c4 10             	add    $0x10,%esp
f0100e5a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100e5e:	74 57                	je     f0100eb7 <monitor+0x7f>
		print_trapframe(tf);
f0100e60:	83 ec 0c             	sub    $0xc,%esp
f0100e63:	ff 75 08             	pushl  0x8(%ebp)
f0100e66:	e8 49 38 00 00       	call   f01046b4 <print_trapframe>
f0100e6b:	83 c4 10             	add    $0x10,%esp
f0100e6e:	eb 47                	jmp    f0100eb7 <monitor+0x7f>
		while (*buf && strchr(WHITESPACE, *buf))
f0100e70:	83 ec 08             	sub    $0x8,%esp
f0100e73:	0f be c0             	movsbl %al,%eax
f0100e76:	50                   	push   %eax
f0100e77:	68 29 72 10 f0       	push   $0xf0107229
f0100e7c:	e8 93 51 00 00       	call   f0106014 <strchr>
f0100e81:	83 c4 10             	add    $0x10,%esp
f0100e84:	85 c0                	test   %eax,%eax
f0100e86:	74 0a                	je     f0100e92 <monitor+0x5a>
			*buf++ = 0;
f0100e88:	c6 03 00             	movb   $0x0,(%ebx)
f0100e8b:	89 f7                	mov    %esi,%edi
f0100e8d:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100e90:	eb 68                	jmp    f0100efa <monitor+0xc2>
		if (*buf == 0)
f0100e92:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100e95:	74 6f                	je     f0100f06 <monitor+0xce>
		if (argc == MAXARGS-1) {
f0100e97:	83 fe 0f             	cmp    $0xf,%esi
f0100e9a:	74 09                	je     f0100ea5 <monitor+0x6d>
		argv[argc++] = buf;
f0100e9c:	8d 7e 01             	lea    0x1(%esi),%edi
f0100e9f:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100ea3:	eb 37                	jmp    f0100edc <monitor+0xa4>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100ea5:	83 ec 08             	sub    $0x8,%esp
f0100ea8:	6a 10                	push   $0x10
f0100eaa:	68 2e 72 10 f0       	push   $0xf010722e
f0100eaf:	e8 d0 30 00 00       	call   f0103f84 <cprintf>
f0100eb4:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100eb7:	83 ec 0c             	sub    $0xc,%esp
f0100eba:	68 25 72 10 f0       	push   $0xf0107225
f0100ebf:	e8 35 4f 00 00       	call   f0105df9 <readline>
f0100ec4:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100ec6:	83 c4 10             	add    $0x10,%esp
f0100ec9:	85 c0                	test   %eax,%eax
f0100ecb:	74 ea                	je     f0100eb7 <monitor+0x7f>
	argv[argc] = 0;
f0100ecd:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100ed4:	be 00 00 00 00       	mov    $0x0,%esi
f0100ed9:	eb 21                	jmp    f0100efc <monitor+0xc4>
			buf++;
f0100edb:	43                   	inc    %ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100edc:	8a 03                	mov    (%ebx),%al
f0100ede:	84 c0                	test   %al,%al
f0100ee0:	74 18                	je     f0100efa <monitor+0xc2>
f0100ee2:	83 ec 08             	sub    $0x8,%esp
f0100ee5:	0f be c0             	movsbl %al,%eax
f0100ee8:	50                   	push   %eax
f0100ee9:	68 29 72 10 f0       	push   $0xf0107229
f0100eee:	e8 21 51 00 00       	call   f0106014 <strchr>
f0100ef3:	83 c4 10             	add    $0x10,%esp
f0100ef6:	85 c0                	test   %eax,%eax
f0100ef8:	74 e1                	je     f0100edb <monitor+0xa3>
			*buf++ = 0;
f0100efa:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100efc:	8a 03                	mov    (%ebx),%al
f0100efe:	84 c0                	test   %al,%al
f0100f00:	0f 85 6a ff ff ff    	jne    f0100e70 <monitor+0x38>
	argv[argc] = 0;
f0100f06:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100f0d:	00 
	if (argc == 0)
f0100f0e:	85 f6                	test   %esi,%esi
f0100f10:	74 a5                	je     f0100eb7 <monitor+0x7f>
f0100f12:	bf 20 76 10 f0       	mov    $0xf0107620,%edi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100f17:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f0100f1c:	83 ec 08             	sub    $0x8,%esp
f0100f1f:	ff 37                	pushl  (%edi)
f0100f21:	ff 75 a8             	pushl  -0x58(%ebp)
f0100f24:	e8 97 50 00 00       	call   f0105fc0 <strcmp>
f0100f29:	83 c4 10             	add    $0x10,%esp
f0100f2c:	85 c0                	test   %eax,%eax
f0100f2e:	74 21                	je     f0100f51 <monitor+0x119>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100f30:	43                   	inc    %ebx
f0100f31:	83 c7 0c             	add    $0xc,%edi
f0100f34:	83 fb 05             	cmp    $0x5,%ebx
f0100f37:	75 e3                	jne    f0100f1c <monitor+0xe4>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100f39:	83 ec 08             	sub    $0x8,%esp
f0100f3c:	ff 75 a8             	pushl  -0x58(%ebp)
f0100f3f:	68 4b 72 10 f0       	push   $0xf010724b
f0100f44:	e8 3b 30 00 00       	call   f0103f84 <cprintf>
f0100f49:	83 c4 10             	add    $0x10,%esp
f0100f4c:	e9 66 ff ff ff       	jmp    f0100eb7 <monitor+0x7f>
			return commands[i].func(argc, argv, tf);
f0100f51:	83 ec 04             	sub    $0x4,%esp
f0100f54:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100f57:	01 c3                	add    %eax,%ebx
f0100f59:	ff 75 08             	pushl  0x8(%ebp)
f0100f5c:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100f5f:	50                   	push   %eax
f0100f60:	56                   	push   %esi
f0100f61:	ff 14 9d 28 76 10 f0 	call   *-0xfef89d8(,%ebx,4)
			if (runcmd(buf, tf) < 0)
f0100f68:	83 c4 10             	add    $0x10,%esp
f0100f6b:	85 c0                	test   %eax,%eax
f0100f6d:	0f 89 44 ff ff ff    	jns    f0100eb7 <monitor+0x7f>
				break;
	}
}
f0100f73:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f76:	5b                   	pop    %ebx
f0100f77:	5e                   	pop    %esi
f0100f78:	5f                   	pop    %edi
f0100f79:	5d                   	pop    %ebp
f0100f7a:	c3                   	ret    

f0100f7b <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100f7b:	55                   	push   %ebp
f0100f7c:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100f7e:	83 3d 38 72 2a f0 00 	cmpl   $0x0,0xf02a7238
f0100f85:	74 1f                	je     f0100fa6 <boot_alloc+0x2b>
	}

	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	if (!n)
f0100f87:	85 c0                	test   %eax,%eax
f0100f89:	74 2e                	je     f0100fb9 <boot_alloc+0x3e>
		return (void*)nextfree;
	else {
		result = nextfree;
f0100f8b:	8b 15 38 72 2a f0    	mov    0xf02a7238,%edx
		nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100f91:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100f98:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f9d:	a3 38 72 2a f0       	mov    %eax,0xf02a7238
		return (void*)result;
	}
}
f0100fa2:	89 d0                	mov    %edx,%eax
f0100fa4:	5d                   	pop    %ebp
f0100fa5:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100fa6:	ba 07 a0 2e f0       	mov    $0xf02ea007,%edx
f0100fab:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100fb1:	89 15 38 72 2a f0    	mov    %edx,0xf02a7238
f0100fb7:	eb ce                	jmp    f0100f87 <boot_alloc+0xc>
		return (void*)nextfree;
f0100fb9:	8b 15 38 72 2a f0    	mov    0xf02a7238,%edx
f0100fbf:	eb e1                	jmp    f0100fa2 <boot_alloc+0x27>

f0100fc1 <nvram_read>:
{
f0100fc1:	55                   	push   %ebp
f0100fc2:	89 e5                	mov    %esp,%ebp
f0100fc4:	56                   	push   %esi
f0100fc5:	53                   	push   %ebx
f0100fc6:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100fc8:	83 ec 0c             	sub    $0xc,%esp
f0100fcb:	50                   	push   %eax
f0100fcc:	e8 40 2e 00 00       	call   f0103e11 <mc146818_read>
f0100fd1:	89 c3                	mov    %eax,%ebx
f0100fd3:	46                   	inc    %esi
f0100fd4:	89 34 24             	mov    %esi,(%esp)
f0100fd7:	e8 35 2e 00 00       	call   f0103e11 <mc146818_read>
f0100fdc:	c1 e0 08             	shl    $0x8,%eax
f0100fdf:	09 d8                	or     %ebx,%eax
}
f0100fe1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100fe4:	5b                   	pop    %ebx
f0100fe5:	5e                   	pop    %esi
f0100fe6:	5d                   	pop    %ebp
f0100fe7:	c3                   	ret    

f0100fe8 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100fe8:	89 d1                	mov    %edx,%ecx
f0100fea:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100fed:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ff0:	a8 01                	test   $0x1,%al
f0100ff2:	74 47                	je     f010103b <check_va2pa+0x53>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100ff4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100ff9:	89 c1                	mov    %eax,%ecx
f0100ffb:	c1 e9 0c             	shr    $0xc,%ecx
f0100ffe:	3b 0d 88 7e 2a f0    	cmp    0xf02a7e88,%ecx
f0101004:	73 1a                	jae    f0101020 <check_va2pa+0x38>
	if (!(p[PTX(va)] & PTE_P))
f0101006:	c1 ea 0c             	shr    $0xc,%edx
f0101009:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010100f:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0101016:	a8 01                	test   $0x1,%al
f0101018:	74 27                	je     f0101041 <check_va2pa+0x59>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f010101a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010101f:	c3                   	ret    
{
f0101020:	55                   	push   %ebp
f0101021:	89 e5                	mov    %esp,%ebp
f0101023:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101026:	50                   	push   %eax
f0101027:	68 a8 6e 10 f0       	push   $0xf0106ea8
f010102c:	68 6f 03 00 00       	push   $0x36f
f0101031:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101036:	e8 59 f0 ff ff       	call   f0100094 <_panic>
		return ~0;
f010103b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101040:	c3                   	ret    
		return ~0;
f0101041:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0101046:	c3                   	ret    

f0101047 <check_page_free_list>:
{
f0101047:	55                   	push   %ebp
f0101048:	89 e5                	mov    %esp,%ebp
f010104a:	57                   	push   %edi
f010104b:	56                   	push   %esi
f010104c:	53                   	push   %ebx
f010104d:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101050:	84 c0                	test   %al,%al
f0101052:	0f 85 80 02 00 00    	jne    f01012d8 <check_page_free_list+0x291>
	if (!page_free_list)
f0101058:	83 3d 40 72 2a f0 00 	cmpl   $0x0,0xf02a7240
f010105f:	74 0a                	je     f010106b <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101061:	be 00 04 00 00       	mov    $0x400,%esi
f0101066:	e9 c8 02 00 00       	jmp    f0101333 <check_page_free_list+0x2ec>
		panic("'page_free_list' is a null pointer!");
f010106b:	83 ec 04             	sub    $0x4,%esp
f010106e:	68 5c 76 10 f0       	push   $0xf010765c
f0101073:	68 a2 02 00 00       	push   $0x2a2
f0101078:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010107d:	e8 12 f0 ff ff       	call   f0100094 <_panic>
f0101082:	50                   	push   %eax
f0101083:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0101088:	6a 58                	push   $0x58
f010108a:	68 89 7f 10 f0       	push   $0xf0107f89
f010108f:	e8 00 f0 ff ff       	call   f0100094 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101094:	8b 1b                	mov    (%ebx),%ebx
f0101096:	85 db                	test   %ebx,%ebx
f0101098:	74 41                	je     f01010db <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010109a:	89 d8                	mov    %ebx,%eax
f010109c:	2b 05 90 7e 2a f0    	sub    0xf02a7e90,%eax
f01010a2:	c1 f8 03             	sar    $0x3,%eax
f01010a5:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f01010a8:	89 c2                	mov    %eax,%edx
f01010aa:	c1 ea 16             	shr    $0x16,%edx
f01010ad:	39 f2                	cmp    %esi,%edx
f01010af:	73 e3                	jae    f0101094 <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f01010b1:	89 c2                	mov    %eax,%edx
f01010b3:	c1 ea 0c             	shr    $0xc,%edx
f01010b6:	3b 15 88 7e 2a f0    	cmp    0xf02a7e88,%edx
f01010bc:	73 c4                	jae    f0101082 <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f01010be:	83 ec 04             	sub    $0x4,%esp
f01010c1:	68 80 00 00 00       	push   $0x80
f01010c6:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f01010cb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010d0:	50                   	push   %eax
f01010d1:	e8 73 4f 00 00       	call   f0106049 <memset>
f01010d6:	83 c4 10             	add    $0x10,%esp
f01010d9:	eb b9                	jmp    f0101094 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f01010db:	b8 00 00 00 00       	mov    $0x0,%eax
f01010e0:	e8 96 fe ff ff       	call   f0100f7b <boot_alloc>
f01010e5:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010e8:	8b 15 40 72 2a f0    	mov    0xf02a7240,%edx
		assert(pp >= pages);
f01010ee:	8b 0d 90 7e 2a f0    	mov    0xf02a7e90,%ecx
		assert(pp < pages + npages);
f01010f4:	a1 88 7e 2a f0       	mov    0xf02a7e88,%eax
f01010f9:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01010fc:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f01010ff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101102:	89 4d d0             	mov    %ecx,-0x30(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0101105:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010110a:	e9 00 01 00 00       	jmp    f010120f <check_page_free_list+0x1c8>
		assert(pp >= pages);
f010110f:	68 97 7f 10 f0       	push   $0xf0107f97
f0101114:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101119:	68 bc 02 00 00       	push   $0x2bc
f010111e:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101123:	e8 6c ef ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0101128:	68 b8 7f 10 f0       	push   $0xf0107fb8
f010112d:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101132:	68 bd 02 00 00       	push   $0x2bd
f0101137:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010113c:	e8 53 ef ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101141:	68 80 76 10 f0       	push   $0xf0107680
f0101146:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010114b:	68 be 02 00 00       	push   $0x2be
f0101150:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101155:	e8 3a ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != 0);
f010115a:	68 cc 7f 10 f0       	push   $0xf0107fcc
f010115f:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101164:	68 c1 02 00 00       	push   $0x2c1
f0101169:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010116e:	e8 21 ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101173:	68 dd 7f 10 f0       	push   $0xf0107fdd
f0101178:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010117d:	68 c2 02 00 00       	push   $0x2c2
f0101182:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101187:	e8 08 ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010118c:	68 b4 76 10 f0       	push   $0xf01076b4
f0101191:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101196:	68 c3 02 00 00       	push   $0x2c3
f010119b:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01011a0:	e8 ef ee ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01011a5:	68 f6 7f 10 f0       	push   $0xf0107ff6
f01011aa:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01011af:	68 c4 02 00 00       	push   $0x2c4
f01011b4:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01011b9:	e8 d6 ee ff ff       	call   f0100094 <_panic>
	if (PGNUM(pa) >= npages)
f01011be:	89 c7                	mov    %eax,%edi
f01011c0:	c1 ef 0c             	shr    $0xc,%edi
f01011c3:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f01011c6:	76 19                	jbe    f01011e1 <check_page_free_list+0x19a>
	return (void *)(pa + KERNBASE);
f01011c8:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01011ce:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f01011d1:	77 20                	ja     f01011f3 <check_page_free_list+0x1ac>
		assert(page2pa(pp) != MPENTRY_PADDR);
f01011d3:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01011d8:	0f 84 92 00 00 00    	je     f0101270 <check_page_free_list+0x229>
			++nfree_extmem;
f01011de:	43                   	inc    %ebx
f01011df:	eb 2c                	jmp    f010120d <check_page_free_list+0x1c6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011e1:	50                   	push   %eax
f01011e2:	68 a8 6e 10 f0       	push   $0xf0106ea8
f01011e7:	6a 58                	push   $0x58
f01011e9:	68 89 7f 10 f0       	push   $0xf0107f89
f01011ee:	e8 a1 ee ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01011f3:	68 d8 76 10 f0       	push   $0xf01076d8
f01011f8:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01011fd:	68 c5 02 00 00       	push   $0x2c5
f0101202:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101207:	e8 88 ee ff ff       	call   f0100094 <_panic>
			++nfree_basemem;
f010120c:	46                   	inc    %esi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010120d:	8b 12                	mov    (%edx),%edx
f010120f:	85 d2                	test   %edx,%edx
f0101211:	74 76                	je     f0101289 <check_page_free_list+0x242>
		assert(pp >= pages);
f0101213:	39 d1                	cmp    %edx,%ecx
f0101215:	0f 87 f4 fe ff ff    	ja     f010110f <check_page_free_list+0xc8>
		assert(pp < pages + npages);
f010121b:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f010121e:	0f 86 04 ff ff ff    	jbe    f0101128 <check_page_free_list+0xe1>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101224:	89 d0                	mov    %edx,%eax
f0101226:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101229:	a8 07                	test   $0x7,%al
f010122b:	0f 85 10 ff ff ff    	jne    f0101141 <check_page_free_list+0xfa>
	return (pp - pages) << PGSHIFT;
f0101231:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0101234:	c1 e0 0c             	shl    $0xc,%eax
f0101237:	0f 84 1d ff ff ff    	je     f010115a <check_page_free_list+0x113>
		assert(page2pa(pp) != IOPHYSMEM);
f010123d:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101242:	0f 84 2b ff ff ff    	je     f0101173 <check_page_free_list+0x12c>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101248:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f010124d:	0f 84 39 ff ff ff    	je     f010118c <check_page_free_list+0x145>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101253:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101258:	0f 84 47 ff ff ff    	je     f01011a5 <check_page_free_list+0x15e>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010125e:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101263:	0f 87 55 ff ff ff    	ja     f01011be <check_page_free_list+0x177>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101269:	3d 00 70 00 00       	cmp    $0x7000,%eax
f010126e:	75 9c                	jne    f010120c <check_page_free_list+0x1c5>
f0101270:	68 10 80 10 f0       	push   $0xf0108010
f0101275:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010127a:	68 c7 02 00 00       	push   $0x2c7
f010127f:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101284:	e8 0b ee ff ff       	call   f0100094 <_panic>
	assert(nfree_basemem > 0);
f0101289:	85 f6                	test   %esi,%esi
f010128b:	7e 19                	jle    f01012a6 <check_page_free_list+0x25f>
	assert(nfree_extmem > 0);
f010128d:	85 db                	test   %ebx,%ebx
f010128f:	7e 2e                	jle    f01012bf <check_page_free_list+0x278>
	cprintf("check_page_free_list() succeeded!\n");
f0101291:	83 ec 0c             	sub    $0xc,%esp
f0101294:	68 20 77 10 f0       	push   $0xf0107720
f0101299:	e8 e6 2c 00 00       	call   f0103f84 <cprintf>
}
f010129e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012a1:	5b                   	pop    %ebx
f01012a2:	5e                   	pop    %esi
f01012a3:	5f                   	pop    %edi
f01012a4:	5d                   	pop    %ebp
f01012a5:	c3                   	ret    
	assert(nfree_basemem > 0);
f01012a6:	68 2d 80 10 f0       	push   $0xf010802d
f01012ab:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01012b0:	68 cf 02 00 00       	push   $0x2cf
f01012b5:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01012ba:	e8 d5 ed ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f01012bf:	68 3f 80 10 f0       	push   $0xf010803f
f01012c4:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01012c9:	68 d0 02 00 00       	push   $0x2d0
f01012ce:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01012d3:	e8 bc ed ff ff       	call   f0100094 <_panic>
	if (!page_free_list)
f01012d8:	a1 40 72 2a f0       	mov    0xf02a7240,%eax
f01012dd:	85 c0                	test   %eax,%eax
f01012df:	0f 84 86 fd ff ff    	je     f010106b <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01012e5:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01012e8:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01012eb:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01012ee:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01012f1:	89 c2                	mov    %eax,%edx
f01012f3:	2b 15 90 7e 2a f0    	sub    0xf02a7e90,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit; 
f01012f9:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f01012ff:	0f 95 c2             	setne  %dl
f0101302:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0101305:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0101309:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f010130b:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f010130f:	8b 00                	mov    (%eax),%eax
f0101311:	85 c0                	test   %eax,%eax
f0101313:	75 dc                	jne    f01012f1 <check_page_free_list+0x2aa>
		*tp[1] = 0;
f0101315:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101318:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f010131e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101321:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101324:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101326:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101329:	a3 40 72 2a f0       	mov    %eax,0xf02a7240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010132e:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101333:	8b 1d 40 72 2a f0    	mov    0xf02a7240,%ebx
f0101339:	e9 58 fd ff ff       	jmp    f0101096 <check_page_free_list+0x4f>

f010133e <page_init>:
{
f010133e:	55                   	push   %ebp
f010133f:	89 e5                	mov    %esp,%ebp
f0101341:	57                   	push   %edi
f0101342:	56                   	push   %esi
f0101343:	53                   	push   %ebx
f0101344:	83 ec 1c             	sub    $0x1c,%esp
	physaddr_t free = (physaddr_t) PADDR(boot_alloc(0));
f0101347:	b8 00 00 00 00       	mov    $0x0,%eax
f010134c:	e8 2a fc ff ff       	call   f0100f7b <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0101351:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101356:	76 32                	jbe    f010138a <page_init+0x4c>
	return (physaddr_t)kva - KERNBASE;
f0101358:	05 00 00 00 10       	add    $0x10000000,%eax
f010135d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	size_t core_code_end = MPENTRY_PADDR + mpentry_end - mpentry_start;
f0101360:	b8 72 d3 10 f0       	mov    $0xf010d372,%eax
f0101365:	2d f8 62 10 f0       	sub    $0xf01062f8,%eax
f010136a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if (i >= npages_basemem && len < free)
f010136d:	8b 1d 44 72 2a f0    	mov    0xf02a7244,%ebx
f0101373:	8b 0d 40 72 2a f0    	mov    0xf02a7240,%ecx
	for (i = 1, len = PGSIZE; i < npages; i++, len += PGSIZE) {
f0101379:	bf 00 00 00 00       	mov    $0x0,%edi
f010137e:	b8 01 00 00 00       	mov    $0x1,%eax
		page_free_list = &pages[i];
f0101383:	be 01 00 00 00       	mov    $0x1,%esi
	for (i = 1, len = PGSIZE; i < npages; i++, len += PGSIZE) {
f0101388:	eb 37                	jmp    f01013c1 <page_init+0x83>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010138a:	50                   	push   %eax
f010138b:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0101390:	68 3e 01 00 00       	push   $0x13e
f0101395:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010139a:	e8 f5 ec ff ff       	call   f0100094 <_panic>
		pages[i].pp_ref = 0;
f010139f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01013a6:	89 d7                	mov    %edx,%edi
f01013a8:	03 3d 90 7e 2a f0    	add    0xf02a7e90,%edi
f01013ae:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
		pages[i].pp_link = page_free_list;
f01013b4:	89 0f                	mov    %ecx,(%edi)
		page_free_list = &pages[i];
f01013b6:	89 d1                	mov    %edx,%ecx
f01013b8:	03 0d 90 7e 2a f0    	add    0xf02a7e90,%ecx
f01013be:	89 f7                	mov    %esi,%edi
	for (i = 1, len = PGSIZE; i < npages; i++, len += PGSIZE) {
f01013c0:	40                   	inc    %eax
f01013c1:	39 05 88 7e 2a f0    	cmp    %eax,0xf02a7e88
f01013c7:	76 1d                	jbe    f01013e6 <page_init+0xa8>
f01013c9:	89 c2                	mov    %eax,%edx
f01013cb:	c1 e2 0c             	shl    $0xc,%edx
		if (len >= MPENTRY_PADDR && len < core_code_end) // We're in multicore code
f01013ce:	81 fa ff 6f 00 00    	cmp    $0x6fff,%edx
f01013d4:	76 05                	jbe    f01013db <page_init+0x9d>
f01013d6:	39 55 e4             	cmp    %edx,-0x1c(%ebp)
f01013d9:	77 e5                	ja     f01013c0 <page_init+0x82>
		if (i >= npages_basemem && len < free)
f01013db:	39 c3                	cmp    %eax,%ebx
f01013dd:	77 c0                	ja     f010139f <page_init+0x61>
f01013df:	39 55 e0             	cmp    %edx,-0x20(%ebp)
f01013e2:	76 bb                	jbe    f010139f <page_init+0x61>
f01013e4:	eb da                	jmp    f01013c0 <page_init+0x82>
f01013e6:	89 f8                	mov    %edi,%eax
f01013e8:	84 c0                	test   %al,%al
f01013ea:	75 08                	jne    f01013f4 <page_init+0xb6>
}
f01013ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01013ef:	5b                   	pop    %ebx
f01013f0:	5e                   	pop    %esi
f01013f1:	5f                   	pop    %edi
f01013f2:	5d                   	pop    %ebp
f01013f3:	c3                   	ret    
f01013f4:	89 0d 40 72 2a f0    	mov    %ecx,0xf02a7240
f01013fa:	eb f0                	jmp    f01013ec <page_init+0xae>

f01013fc <page_alloc>:
{
f01013fc:	55                   	push   %ebp
f01013fd:	89 e5                	mov    %esp,%ebp
f01013ff:	53                   	push   %ebx
f0101400:	83 ec 04             	sub    $0x4,%esp
	struct PageInfo* next = page_free_list;
f0101403:	8b 1d 40 72 2a f0    	mov    0xf02a7240,%ebx
	if (!next)
f0101409:	85 db                	test   %ebx,%ebx
f010140b:	74 13                	je     f0101420 <page_alloc+0x24>
	page_free_list = page_free_list->pp_link;
f010140d:	8b 03                	mov    (%ebx),%eax
f010140f:	a3 40 72 2a f0       	mov    %eax,0xf02a7240
	next->pp_link = NULL;
f0101414:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f010141a:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010141e:	75 07                	jne    f0101427 <page_alloc+0x2b>
}
f0101420:	89 d8                	mov    %ebx,%eax
f0101422:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101425:	c9                   	leave  
f0101426:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0101427:	89 d8                	mov    %ebx,%eax
f0101429:	2b 05 90 7e 2a f0    	sub    0xf02a7e90,%eax
f010142f:	c1 f8 03             	sar    $0x3,%eax
f0101432:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101435:	89 c2                	mov    %eax,%edx
f0101437:	c1 ea 0c             	shr    $0xc,%edx
f010143a:	3b 15 88 7e 2a f0    	cmp    0xf02a7e88,%edx
f0101440:	73 1a                	jae    f010145c <page_alloc+0x60>
		memset(content, 0, PGSIZE);
f0101442:	83 ec 04             	sub    $0x4,%esp
f0101445:	68 00 10 00 00       	push   $0x1000
f010144a:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f010144c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101451:	50                   	push   %eax
f0101452:	e8 f2 4b 00 00       	call   f0106049 <memset>
f0101457:	83 c4 10             	add    $0x10,%esp
f010145a:	eb c4                	jmp    f0101420 <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010145c:	50                   	push   %eax
f010145d:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0101462:	6a 58                	push   $0x58
f0101464:	68 89 7f 10 f0       	push   $0xf0107f89
f0101469:	e8 26 ec ff ff       	call   f0100094 <_panic>

f010146e <page_free>:
{
f010146e:	55                   	push   %ebp
f010146f:	89 e5                	mov    %esp,%ebp
f0101471:	83 ec 08             	sub    $0x8,%esp
f0101474:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref)
f0101477:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010147c:	75 14                	jne    f0101492 <page_free+0x24>
	if (pp->pp_link)
f010147e:	83 38 00             	cmpl   $0x0,(%eax)
f0101481:	75 26                	jne    f01014a9 <page_free+0x3b>
	pp->pp_link = page_free_list;
f0101483:	8b 15 40 72 2a f0    	mov    0xf02a7240,%edx
f0101489:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f010148b:	a3 40 72 2a f0       	mov    %eax,0xf02a7240
}
f0101490:	c9                   	leave  
f0101491:	c3                   	ret    
		panic("Ref count is non-zero");
f0101492:	83 ec 04             	sub    $0x4,%esp
f0101495:	68 50 80 10 f0       	push   $0xf0108050
f010149a:	68 70 01 00 00       	push   $0x170
f010149f:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01014a4:	e8 eb eb ff ff       	call   f0100094 <_panic>
		panic("Page is double-freed");
f01014a9:	83 ec 04             	sub    $0x4,%esp
f01014ac:	68 66 80 10 f0       	push   $0xf0108066
f01014b1:	68 72 01 00 00       	push   $0x172
f01014b6:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01014bb:	e8 d4 eb ff ff       	call   f0100094 <_panic>

f01014c0 <page_decref>:
{
f01014c0:	55                   	push   %ebp
f01014c1:	89 e5                	mov    %esp,%ebp
f01014c3:	83 ec 08             	sub    $0x8,%esp
f01014c6:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01014c9:	8b 42 04             	mov    0x4(%edx),%eax
f01014cc:	48                   	dec    %eax
f01014cd:	66 89 42 04          	mov    %ax,0x4(%edx)
f01014d1:	66 85 c0             	test   %ax,%ax
f01014d4:	74 02                	je     f01014d8 <page_decref+0x18>
}
f01014d6:	c9                   	leave  
f01014d7:	c3                   	ret    
		page_free(pp);
f01014d8:	83 ec 0c             	sub    $0xc,%esp
f01014db:	52                   	push   %edx
f01014dc:	e8 8d ff ff ff       	call   f010146e <page_free>
f01014e1:	83 c4 10             	add    $0x10,%esp
}
f01014e4:	eb f0                	jmp    f01014d6 <page_decref+0x16>

f01014e6 <pgdir_walk>:
{
f01014e6:	55                   	push   %ebp
f01014e7:	89 e5                	mov    %esp,%ebp
f01014e9:	57                   	push   %edi
f01014ea:	56                   	push   %esi
f01014eb:	53                   	push   %ebx
f01014ec:	83 ec 1c             	sub    $0x1c,%esp
	pde_t pd_entry = (pde_t)pgdir[PDX(va)];
f01014ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01014f2:	c1 eb 16             	shr    $0x16,%ebx
f01014f5:	c1 e3 02             	shl    $0x2,%ebx
f01014f8:	03 5d 08             	add    0x8(%ebp),%ebx
f01014fb:	8b 03                	mov    (%ebx),%eax
	if (pd_entry) {
f01014fd:	85 c0                	test   %eax,%eax
f01014ff:	74 42                	je     f0101543 <pgdir_walk+0x5d>
		pte_t* pt_base = KADDR(PTE_ADDR(pd_entry));
f0101501:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101506:	89 c2                	mov    %eax,%edx
f0101508:	c1 ea 0c             	shr    $0xc,%edx
f010150b:	39 15 88 7e 2a f0    	cmp    %edx,0xf02a7e88
f0101511:	76 1b                	jbe    f010152e <pgdir_walk+0x48>
		return pt_base + PTX(va);
f0101513:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101516:	c1 ea 0a             	shr    $0xa,%edx
f0101519:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f010151f:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
}
f0101526:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101529:	5b                   	pop    %ebx
f010152a:	5e                   	pop    %esi
f010152b:	5f                   	pop    %edi
f010152c:	5d                   	pop    %ebp
f010152d:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010152e:	50                   	push   %eax
f010152f:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0101534:	68 9d 01 00 00       	push   $0x19d
f0101539:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010153e:	e8 51 eb ff ff       	call   f0100094 <_panic>
	else if (create) {
f0101543:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101547:	0f 84 9c 00 00 00    	je     f01015e9 <pgdir_walk+0x103>
		struct PageInfo *new_pt = page_alloc(0);
f010154d:	83 ec 0c             	sub    $0xc,%esp
f0101550:	6a 00                	push   $0x0
f0101552:	e8 a5 fe ff ff       	call   f01013fc <page_alloc>
f0101557:	89 c7                	mov    %eax,%edi
		if (new_pt) {
f0101559:	83 c4 10             	add    $0x10,%esp
f010155c:	85 c0                	test   %eax,%eax
f010155e:	0f 84 8f 00 00 00    	je     f01015f3 <pgdir_walk+0x10d>
	return (pp - pages) << PGSHIFT;
f0101564:	2b 05 90 7e 2a f0    	sub    0xf02a7e90,%eax
f010156a:	c1 f8 03             	sar    $0x3,%eax
f010156d:	c1 e0 0c             	shl    $0xc,%eax
f0101570:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (PGNUM(pa) >= npages)
f0101573:	c1 e8 0c             	shr    $0xc,%eax
f0101576:	3b 05 88 7e 2a f0    	cmp    0xf02a7e88,%eax
f010157c:	73 42                	jae    f01015c0 <pgdir_walk+0xda>
	return (void *)(pa + KERNBASE);
f010157e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101581:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
			memset(content, 0, PGSIZE);
f0101587:	83 ec 04             	sub    $0x4,%esp
f010158a:	68 00 10 00 00       	push   $0x1000
f010158f:	6a 00                	push   $0x0
f0101591:	56                   	push   %esi
f0101592:	e8 b2 4a 00 00       	call   f0106049 <memset>
			new_pt->pp_ref++;
f0101597:	66 ff 47 04          	incw   0x4(%edi)
	if ((uint32_t)kva < KERNBASE)
f010159b:	83 c4 10             	add    $0x10,%esp
f010159e:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01015a4:	76 2e                	jbe    f01015d4 <pgdir_walk+0xee>
			pgdir[PDX(va)] = PADDR(content) | 0xF; // Set all permissions.
f01015a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01015a9:	83 c8 0f             	or     $0xf,%eax
f01015ac:	89 03                	mov    %eax,(%ebx)
			return (pte_t*) content + PTX(va);
f01015ae:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015b1:	c1 e8 0a             	shr    $0xa,%eax
f01015b4:	25 fc 0f 00 00       	and    $0xffc,%eax
f01015b9:	01 f0                	add    %esi,%eax
f01015bb:	e9 66 ff ff ff       	jmp    f0101526 <pgdir_walk+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015c0:	ff 75 e4             	pushl  -0x1c(%ebp)
f01015c3:	68 a8 6e 10 f0       	push   $0xf0106ea8
f01015c8:	6a 58                	push   $0x58
f01015ca:	68 89 7f 10 f0       	push   $0xf0107f89
f01015cf:	e8 c0 ea ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01015d4:	56                   	push   %esi
f01015d5:	68 cc 6e 10 f0       	push   $0xf0106ecc
f01015da:	68 a6 01 00 00       	push   $0x1a6
f01015df:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01015e4:	e8 ab ea ff ff       	call   f0100094 <_panic>
	return NULL;
f01015e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01015ee:	e9 33 ff ff ff       	jmp    f0101526 <pgdir_walk+0x40>
f01015f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01015f8:	e9 29 ff ff ff       	jmp    f0101526 <pgdir_walk+0x40>

f01015fd <boot_map_region>:
{
f01015fd:	55                   	push   %ebp
f01015fe:	89 e5                	mov    %esp,%ebp
f0101600:	57                   	push   %edi
f0101601:	56                   	push   %esi
f0101602:	53                   	push   %ebx
f0101603:	83 ec 1c             	sub    $0x1c,%esp
f0101606:	89 c7                	mov    %eax,%edi
f0101608:	89 d6                	mov    %edx,%esi
f010160a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f010160d:	bb 00 00 00 00       	mov    $0x0,%ebx
		*page_entry = (pa + size0) | perm | PTE_P;
f0101612:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101615:	83 c8 01             	or     $0x1,%eax
f0101618:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f010161b:	eb 22                	jmp    f010163f <boot_map_region+0x42>
		pte_t *page_entry = pgdir_walk(pgdir, (void*) va + size0, 1);
f010161d:	83 ec 04             	sub    $0x4,%esp
f0101620:	6a 01                	push   $0x1
f0101622:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f0101625:	50                   	push   %eax
f0101626:	57                   	push   %edi
f0101627:	e8 ba fe ff ff       	call   f01014e6 <pgdir_walk>
		*page_entry = (pa + size0) | perm | PTE_P;
f010162c:	89 da                	mov    %ebx,%edx
f010162e:	03 55 08             	add    0x8(%ebp),%edx
f0101631:	0b 55 e0             	or     -0x20(%ebp),%edx
f0101634:	89 10                	mov    %edx,(%eax)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f0101636:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010163c:	83 c4 10             	add    $0x10,%esp
f010163f:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101642:	72 d9                	jb     f010161d <boot_map_region+0x20>
}
f0101644:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101647:	5b                   	pop    %ebx
f0101648:	5e                   	pop    %esi
f0101649:	5f                   	pop    %edi
f010164a:	5d                   	pop    %ebp
f010164b:	c3                   	ret    

f010164c <page_lookup>:
{
f010164c:	55                   	push   %ebp
f010164d:	89 e5                	mov    %esp,%ebp
f010164f:	53                   	push   %ebx
f0101650:	83 ec 08             	sub    $0x8,%esp
f0101653:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *page_entry = pgdir_walk(pgdir, (void*) va, 0);
f0101656:	6a 00                	push   $0x0
f0101658:	ff 75 0c             	pushl  0xc(%ebp)
f010165b:	ff 75 08             	pushl  0x8(%ebp)
f010165e:	e8 83 fe ff ff       	call   f01014e6 <pgdir_walk>
	if (!page_entry || !*page_entry)
f0101663:	83 c4 10             	add    $0x10,%esp
f0101666:	85 c0                	test   %eax,%eax
f0101668:	74 3a                	je     f01016a4 <page_lookup+0x58>
f010166a:	83 38 00             	cmpl   $0x0,(%eax)
f010166d:	74 3c                	je     f01016ab <page_lookup+0x5f>
	if (pte_store)
f010166f:	85 db                	test   %ebx,%ebx
f0101671:	74 02                	je     f0101675 <page_lookup+0x29>
		*pte_store = page_entry;
f0101673:	89 03                	mov    %eax,(%ebx)
f0101675:	8b 00                	mov    (%eax),%eax
f0101677:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010167a:	39 05 88 7e 2a f0    	cmp    %eax,0xf02a7e88
f0101680:	76 0e                	jbe    f0101690 <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0101682:	8b 15 90 7e 2a f0    	mov    0xf02a7e90,%edx
f0101688:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f010168b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010168e:	c9                   	leave  
f010168f:	c3                   	ret    
		panic("pa2page called with invalid pa");
f0101690:	83 ec 04             	sub    $0x4,%esp
f0101693:	68 44 77 10 f0       	push   $0xf0107744
f0101698:	6a 51                	push   $0x51
f010169a:	68 89 7f 10 f0       	push   $0xf0107f89
f010169f:	e8 f0 e9 ff ff       	call   f0100094 <_panic>
		return NULL;
f01016a4:	b8 00 00 00 00       	mov    $0x0,%eax
f01016a9:	eb e0                	jmp    f010168b <page_lookup+0x3f>
f01016ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01016b0:	eb d9                	jmp    f010168b <page_lookup+0x3f>

f01016b2 <tlb_invalidate>:
{
f01016b2:	55                   	push   %ebp
f01016b3:	89 e5                	mov    %esp,%ebp
f01016b5:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f01016b8:	e8 65 50 00 00       	call   f0106722 <cpunum>
f01016bd:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01016c0:	01 c2                	add    %eax,%edx
f01016c2:	01 d2                	add    %edx,%edx
f01016c4:	01 c2                	add    %eax,%edx
f01016c6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01016c9:	83 3c 85 28 80 2a f0 	cmpl   $0x0,-0xfd57fd8(,%eax,4)
f01016d0:	00 
f01016d1:	74 20                	je     f01016f3 <tlb_invalidate+0x41>
f01016d3:	e8 4a 50 00 00       	call   f0106722 <cpunum>
f01016d8:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01016db:	01 c2                	add    %eax,%edx
f01016dd:	01 d2                	add    %edx,%edx
f01016df:	01 c2                	add    %eax,%edx
f01016e1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01016e4:	8b 04 85 28 80 2a f0 	mov    -0xfd57fd8(,%eax,4),%eax
f01016eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01016ee:	39 48 60             	cmp    %ecx,0x60(%eax)
f01016f1:	75 06                	jne    f01016f9 <tlb_invalidate+0x47>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01016f3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01016f6:	0f 01 38             	invlpg (%eax)
}
f01016f9:	c9                   	leave  
f01016fa:	c3                   	ret    

f01016fb <page_remove>:
{
f01016fb:	55                   	push   %ebp
f01016fc:	89 e5                	mov    %esp,%ebp
f01016fe:	57                   	push   %edi
f01016ff:	56                   	push   %esi
f0101700:	53                   	push   %ebx
f0101701:	83 ec 20             	sub    $0x20,%esp
f0101704:	8b 75 08             	mov    0x8(%ebp),%esi
f0101707:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct PageInfo *pp = page_lookup(pgdir, va, &pte_store);
f010170a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010170d:	50                   	push   %eax
f010170e:	57                   	push   %edi
f010170f:	56                   	push   %esi
f0101710:	e8 37 ff ff ff       	call   f010164c <page_lookup>
	if (!pp)
f0101715:	83 c4 10             	add    $0x10,%esp
f0101718:	85 c0                	test   %eax,%eax
f010171a:	74 23                	je     f010173f <page_remove+0x44>
f010171c:	89 c3                	mov    %eax,%ebx
	pp->pp_ref--;
f010171e:	66 ff 48 04          	decw   0x4(%eax)
	*pte_store = 0;
f0101722:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101725:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f010172b:	83 ec 08             	sub    $0x8,%esp
f010172e:	57                   	push   %edi
f010172f:	56                   	push   %esi
f0101730:	e8 7d ff ff ff       	call   f01016b2 <tlb_invalidate>
	if (!pp->pp_ref)
f0101735:	83 c4 10             	add    $0x10,%esp
f0101738:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010173d:	74 08                	je     f0101747 <page_remove+0x4c>
}
f010173f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101742:	5b                   	pop    %ebx
f0101743:	5e                   	pop    %esi
f0101744:	5f                   	pop    %edi
f0101745:	5d                   	pop    %ebp
f0101746:	c3                   	ret    
		page_free(pp);
f0101747:	83 ec 0c             	sub    $0xc,%esp
f010174a:	53                   	push   %ebx
f010174b:	e8 1e fd ff ff       	call   f010146e <page_free>
f0101750:	83 c4 10             	add    $0x10,%esp
f0101753:	eb ea                	jmp    f010173f <page_remove+0x44>

f0101755 <page_insert>:
{
f0101755:	55                   	push   %ebp
f0101756:	89 e5                	mov    %esp,%ebp
f0101758:	57                   	push   %edi
f0101759:	56                   	push   %esi
f010175a:	53                   	push   %ebx
f010175b:	83 ec 10             	sub    $0x10,%esp
f010175e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101761:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *page_entry = pgdir_walk(pgdir, (void*) va, 1);
f0101764:	6a 01                	push   $0x1
f0101766:	57                   	push   %edi
f0101767:	ff 75 08             	pushl  0x8(%ebp)
f010176a:	e8 77 fd ff ff       	call   f01014e6 <pgdir_walk>
	if (!page_entry)
f010176f:	83 c4 10             	add    $0x10,%esp
f0101772:	85 c0                	test   %eax,%eax
f0101774:	74 3f                	je     f01017b5 <page_insert+0x60>
f0101776:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f0101778:	66 ff 43 04          	incw   0x4(%ebx)
	if (*page_entry) 
f010177c:	83 38 00             	cmpl   $0x0,(%eax)
f010177f:	75 23                	jne    f01017a4 <page_insert+0x4f>
	return (pp - pages) << PGSHIFT;
f0101781:	2b 1d 90 7e 2a f0    	sub    0xf02a7e90,%ebx
f0101787:	c1 fb 03             	sar    $0x3,%ebx
f010178a:	c1 e3 0c             	shl    $0xc,%ebx
	*page_entry = page2pa(pp) | perm | PTE_P;
f010178d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101790:	83 c8 01             	or     $0x1,%eax
f0101793:	09 c3                	or     %eax,%ebx
f0101795:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0101797:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010179c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010179f:	5b                   	pop    %ebx
f01017a0:	5e                   	pop    %esi
f01017a1:	5f                   	pop    %edi
f01017a2:	5d                   	pop    %ebp
f01017a3:	c3                   	ret    
		page_remove(pgdir, va);
f01017a4:	83 ec 08             	sub    $0x8,%esp
f01017a7:	57                   	push   %edi
f01017a8:	ff 75 08             	pushl  0x8(%ebp)
f01017ab:	e8 4b ff ff ff       	call   f01016fb <page_remove>
f01017b0:	83 c4 10             	add    $0x10,%esp
f01017b3:	eb cc                	jmp    f0101781 <page_insert+0x2c>
		return -E_NO_MEM;  // Has no page table AND cannot be allocated
f01017b5:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01017ba:	eb e0                	jmp    f010179c <page_insert+0x47>

f01017bc <mmio_map_region>:
{
f01017bc:	55                   	push   %ebp
f01017bd:	89 e5                	mov    %esp,%ebp
f01017bf:	53                   	push   %ebx
f01017c0:	83 ec 04             	sub    $0x4,%esp
	size_t size_up = ROUNDUP(size, PGSIZE);
f01017c3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01017c6:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01017cc:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (base >= MMIOLIM)
f01017d2:	8b 15 00 33 12 f0    	mov    0xf0123300,%edx
f01017d8:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01017de:	77 26                	ja     f0101806 <mmio_map_region+0x4a>
	boot_map_region(kern_pgdir, base, size_up, pa, PTE_PCD|PTE_PWT|PTE_W);
f01017e0:	83 ec 08             	sub    $0x8,%esp
f01017e3:	6a 1a                	push   $0x1a
f01017e5:	ff 75 08             	pushl  0x8(%ebp)
f01017e8:	89 d9                	mov    %ebx,%ecx
f01017ea:	a1 8c 7e 2a f0       	mov    0xf02a7e8c,%eax
f01017ef:	e8 09 fe ff ff       	call   f01015fd <boot_map_region>
	base += size_up;
f01017f4:	a1 00 33 12 f0       	mov    0xf0123300,%eax
f01017f9:	01 c3                	add    %eax,%ebx
f01017fb:	89 1d 00 33 12 f0    	mov    %ebx,0xf0123300
}
f0101801:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101804:	c9                   	leave  
f0101805:	c3                   	ret    
		panic("MMIO overflowed!");
f0101806:	83 ec 04             	sub    $0x4,%esp
f0101809:	68 7b 80 10 f0       	push   $0xf010807b
f010180e:	68 48 02 00 00       	push   $0x248
f0101813:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101818:	e8 77 e8 ff ff       	call   f0100094 <_panic>

f010181d <mem_init>:
{
f010181d:	55                   	push   %ebp
f010181e:	89 e5                	mov    %esp,%ebp
f0101820:	57                   	push   %edi
f0101821:	56                   	push   %esi
f0101822:	53                   	push   %ebx
f0101823:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0101826:	b8 15 00 00 00       	mov    $0x15,%eax
f010182b:	e8 91 f7 ff ff       	call   f0100fc1 <nvram_read>
f0101830:	89 c6                	mov    %eax,%esi
	extmem = nvram_read(NVRAM_EXTLO);
f0101832:	b8 17 00 00 00       	mov    $0x17,%eax
f0101837:	e8 85 f7 ff ff       	call   f0100fc1 <nvram_read>
f010183c:	89 c3                	mov    %eax,%ebx
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010183e:	b8 34 00 00 00       	mov    $0x34,%eax
f0101843:	e8 79 f7 ff ff       	call   f0100fc1 <nvram_read>
	if (ext16mem)
f0101848:	c1 e0 06             	shl    $0x6,%eax
f010184b:	75 10                	jne    f010185d <mem_init+0x40>
	else if (extmem)
f010184d:	85 db                	test   %ebx,%ebx
f010184f:	0f 84 e6 00 00 00    	je     f010193b <mem_init+0x11e>
		totalmem = 1 * 1024 + extmem;
f0101855:	8d 83 00 04 00 00    	lea    0x400(%ebx),%eax
f010185b:	eb 05                	jmp    f0101862 <mem_init+0x45>
		totalmem = 16 * 1024 + ext16mem;
f010185d:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101862:	89 c2                	mov    %eax,%edx
f0101864:	c1 ea 02             	shr    $0x2,%edx
f0101867:	89 15 88 7e 2a f0    	mov    %edx,0xf02a7e88
	npages_basemem = basemem / (PGSIZE / 1024);
f010186d:	89 f2                	mov    %esi,%edx
f010186f:	c1 ea 02             	shr    $0x2,%edx
f0101872:	89 15 44 72 2a f0    	mov    %edx,0xf02a7244
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101878:	89 c2                	mov    %eax,%edx
f010187a:	29 f2                	sub    %esi,%edx
f010187c:	52                   	push   %edx
f010187d:	56                   	push   %esi
f010187e:	50                   	push   %eax
f010187f:	68 64 77 10 f0       	push   $0xf0107764
f0101884:	e8 fb 26 00 00       	call   f0103f84 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101889:	b8 00 10 00 00       	mov    $0x1000,%eax
f010188e:	e8 e8 f6 ff ff       	call   f0100f7b <boot_alloc>
f0101893:	a3 8c 7e 2a f0       	mov    %eax,0xf02a7e8c
	memset(kern_pgdir, 0, PGSIZE);
f0101898:	83 c4 0c             	add    $0xc,%esp
f010189b:	68 00 10 00 00       	push   $0x1000
f01018a0:	6a 00                	push   $0x0
f01018a2:	50                   	push   %eax
f01018a3:	e8 a1 47 00 00       	call   f0106049 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01018a8:	a1 8c 7e 2a f0       	mov    0xf02a7e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01018ad:	83 c4 10             	add    $0x10,%esp
f01018b0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01018b5:	0f 86 87 00 00 00    	jbe    f0101942 <mem_init+0x125>
	return (physaddr_t)kva - KERNBASE;
f01018bb:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01018c1:	83 ca 05             	or     $0x5,%edx
f01018c4:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo)*npages);
f01018ca:	a1 88 7e 2a f0       	mov    0xf02a7e88,%eax
f01018cf:	c1 e0 03             	shl    $0x3,%eax
f01018d2:	e8 a4 f6 ff ff       	call   f0100f7b <boot_alloc>
f01018d7:	a3 90 7e 2a f0       	mov    %eax,0xf02a7e90
	memset(pages, 0, sizeof(struct PageInfo)*npages);
f01018dc:	83 ec 04             	sub    $0x4,%esp
f01018df:	8b 0d 88 7e 2a f0    	mov    0xf02a7e88,%ecx
f01018e5:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01018ec:	52                   	push   %edx
f01018ed:	6a 00                	push   $0x0
f01018ef:	50                   	push   %eax
f01018f0:	e8 54 47 00 00       	call   f0106049 <memset>
	envs = (struct Env *) boot_alloc(sizeof(struct Env)*NENV);
f01018f5:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01018fa:	e8 7c f6 ff ff       	call   f0100f7b <boot_alloc>
f01018ff:	a3 48 72 2a f0       	mov    %eax,0xf02a7248
	memset(envs, 0, sizeof(struct Env)*NENV);
f0101904:	83 c4 0c             	add    $0xc,%esp
f0101907:	68 00 f0 01 00       	push   $0x1f000
f010190c:	6a 00                	push   $0x0
f010190e:	50                   	push   %eax
f010190f:	e8 35 47 00 00       	call   f0106049 <memset>
	page_init();
f0101914:	e8 25 fa ff ff       	call   f010133e <page_init>
	check_page_free_list(1);
f0101919:	b8 01 00 00 00       	mov    $0x1,%eax
f010191e:	e8 24 f7 ff ff       	call   f0101047 <check_page_free_list>
	if (!pages)
f0101923:	83 c4 10             	add    $0x10,%esp
f0101926:	83 3d 90 7e 2a f0 00 	cmpl   $0x0,0xf02a7e90
f010192d:	74 28                	je     f0101957 <mem_init+0x13a>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010192f:	a1 40 72 2a f0       	mov    0xf02a7240,%eax
f0101934:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101939:	eb 36                	jmp    f0101971 <mem_init+0x154>
		totalmem = basemem;
f010193b:	89 f0                	mov    %esi,%eax
f010193d:	e9 20 ff ff ff       	jmp    f0101862 <mem_init+0x45>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101942:	50                   	push   %eax
f0101943:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0101948:	68 94 00 00 00       	push   $0x94
f010194d:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101952:	e8 3d e7 ff ff       	call   f0100094 <_panic>
		panic("'pages' is a null pointer!");
f0101957:	83 ec 04             	sub    $0x4,%esp
f010195a:	68 8c 80 10 f0       	push   $0xf010808c
f010195f:	68 e3 02 00 00       	push   $0x2e3
f0101964:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101969:	e8 26 e7 ff ff       	call   f0100094 <_panic>
		++nfree;
f010196e:	43                   	inc    %ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010196f:	8b 00                	mov    (%eax),%eax
f0101971:	85 c0                	test   %eax,%eax
f0101973:	75 f9                	jne    f010196e <mem_init+0x151>
	assert((pp0 = page_alloc(0)));
f0101975:	83 ec 0c             	sub    $0xc,%esp
f0101978:	6a 00                	push   $0x0
f010197a:	e8 7d fa ff ff       	call   f01013fc <page_alloc>
f010197f:	89 c7                	mov    %eax,%edi
f0101981:	83 c4 10             	add    $0x10,%esp
f0101984:	85 c0                	test   %eax,%eax
f0101986:	0f 84 10 02 00 00    	je     f0101b9c <mem_init+0x37f>
	assert((pp1 = page_alloc(0)));
f010198c:	83 ec 0c             	sub    $0xc,%esp
f010198f:	6a 00                	push   $0x0
f0101991:	e8 66 fa ff ff       	call   f01013fc <page_alloc>
f0101996:	89 c6                	mov    %eax,%esi
f0101998:	83 c4 10             	add    $0x10,%esp
f010199b:	85 c0                	test   %eax,%eax
f010199d:	0f 84 12 02 00 00    	je     f0101bb5 <mem_init+0x398>
	assert((pp2 = page_alloc(0)));
f01019a3:	83 ec 0c             	sub    $0xc,%esp
f01019a6:	6a 00                	push   $0x0
f01019a8:	e8 4f fa ff ff       	call   f01013fc <page_alloc>
f01019ad:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019b0:	83 c4 10             	add    $0x10,%esp
f01019b3:	85 c0                	test   %eax,%eax
f01019b5:	0f 84 13 02 00 00    	je     f0101bce <mem_init+0x3b1>
	assert(pp1 && pp1 != pp0);
f01019bb:	39 f7                	cmp    %esi,%edi
f01019bd:	0f 84 24 02 00 00    	je     f0101be7 <mem_init+0x3ca>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019c3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019c6:	39 c6                	cmp    %eax,%esi
f01019c8:	0f 84 32 02 00 00    	je     f0101c00 <mem_init+0x3e3>
f01019ce:	39 c7                	cmp    %eax,%edi
f01019d0:	0f 84 2a 02 00 00    	je     f0101c00 <mem_init+0x3e3>
	return (pp - pages) << PGSHIFT;
f01019d6:	8b 0d 90 7e 2a f0    	mov    0xf02a7e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01019dc:	8b 15 88 7e 2a f0    	mov    0xf02a7e88,%edx
f01019e2:	c1 e2 0c             	shl    $0xc,%edx
f01019e5:	89 f8                	mov    %edi,%eax
f01019e7:	29 c8                	sub    %ecx,%eax
f01019e9:	c1 f8 03             	sar    $0x3,%eax
f01019ec:	c1 e0 0c             	shl    $0xc,%eax
f01019ef:	39 d0                	cmp    %edx,%eax
f01019f1:	0f 83 22 02 00 00    	jae    f0101c19 <mem_init+0x3fc>
f01019f7:	89 f0                	mov    %esi,%eax
f01019f9:	29 c8                	sub    %ecx,%eax
f01019fb:	c1 f8 03             	sar    $0x3,%eax
f01019fe:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101a01:	39 c2                	cmp    %eax,%edx
f0101a03:	0f 86 29 02 00 00    	jbe    f0101c32 <mem_init+0x415>
f0101a09:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a0c:	29 c8                	sub    %ecx,%eax
f0101a0e:	c1 f8 03             	sar    $0x3,%eax
f0101a11:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101a14:	39 c2                	cmp    %eax,%edx
f0101a16:	0f 86 2f 02 00 00    	jbe    f0101c4b <mem_init+0x42e>
	fl = page_free_list;
f0101a1c:	a1 40 72 2a f0       	mov    0xf02a7240,%eax
f0101a21:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101a24:	c7 05 40 72 2a f0 00 	movl   $0x0,0xf02a7240
f0101a2b:	00 00 00 
	assert(!page_alloc(0));
f0101a2e:	83 ec 0c             	sub    $0xc,%esp
f0101a31:	6a 00                	push   $0x0
f0101a33:	e8 c4 f9 ff ff       	call   f01013fc <page_alloc>
f0101a38:	83 c4 10             	add    $0x10,%esp
f0101a3b:	85 c0                	test   %eax,%eax
f0101a3d:	0f 85 21 02 00 00    	jne    f0101c64 <mem_init+0x447>
	page_free(pp0);
f0101a43:	83 ec 0c             	sub    $0xc,%esp
f0101a46:	57                   	push   %edi
f0101a47:	e8 22 fa ff ff       	call   f010146e <page_free>
	page_free(pp1);
f0101a4c:	89 34 24             	mov    %esi,(%esp)
f0101a4f:	e8 1a fa ff ff       	call   f010146e <page_free>
	page_free(pp2);
f0101a54:	83 c4 04             	add    $0x4,%esp
f0101a57:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a5a:	e8 0f fa ff ff       	call   f010146e <page_free>
	assert((pp0 = page_alloc(0)));
f0101a5f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a66:	e8 91 f9 ff ff       	call   f01013fc <page_alloc>
f0101a6b:	89 c6                	mov    %eax,%esi
f0101a6d:	83 c4 10             	add    $0x10,%esp
f0101a70:	85 c0                	test   %eax,%eax
f0101a72:	0f 84 05 02 00 00    	je     f0101c7d <mem_init+0x460>
	assert((pp1 = page_alloc(0)));
f0101a78:	83 ec 0c             	sub    $0xc,%esp
f0101a7b:	6a 00                	push   $0x0
f0101a7d:	e8 7a f9 ff ff       	call   f01013fc <page_alloc>
f0101a82:	89 c7                	mov    %eax,%edi
f0101a84:	83 c4 10             	add    $0x10,%esp
f0101a87:	85 c0                	test   %eax,%eax
f0101a89:	0f 84 07 02 00 00    	je     f0101c96 <mem_init+0x479>
	assert((pp2 = page_alloc(0)));
f0101a8f:	83 ec 0c             	sub    $0xc,%esp
f0101a92:	6a 00                	push   $0x0
f0101a94:	e8 63 f9 ff ff       	call   f01013fc <page_alloc>
f0101a99:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a9c:	83 c4 10             	add    $0x10,%esp
f0101a9f:	85 c0                	test   %eax,%eax
f0101aa1:	0f 84 08 02 00 00    	je     f0101caf <mem_init+0x492>
	assert(pp1 && pp1 != pp0);
f0101aa7:	39 fe                	cmp    %edi,%esi
f0101aa9:	0f 84 19 02 00 00    	je     f0101cc8 <mem_init+0x4ab>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101aaf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ab2:	39 c7                	cmp    %eax,%edi
f0101ab4:	0f 84 27 02 00 00    	je     f0101ce1 <mem_init+0x4c4>
f0101aba:	39 c6                	cmp    %eax,%esi
f0101abc:	0f 84 1f 02 00 00    	je     f0101ce1 <mem_init+0x4c4>
	assert(!page_alloc(0));
f0101ac2:	83 ec 0c             	sub    $0xc,%esp
f0101ac5:	6a 00                	push   $0x0
f0101ac7:	e8 30 f9 ff ff       	call   f01013fc <page_alloc>
f0101acc:	83 c4 10             	add    $0x10,%esp
f0101acf:	85 c0                	test   %eax,%eax
f0101ad1:	0f 85 23 02 00 00    	jne    f0101cfa <mem_init+0x4dd>
f0101ad7:	89 f0                	mov    %esi,%eax
f0101ad9:	2b 05 90 7e 2a f0    	sub    0xf02a7e90,%eax
f0101adf:	c1 f8 03             	sar    $0x3,%eax
f0101ae2:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101ae5:	89 c2                	mov    %eax,%edx
f0101ae7:	c1 ea 0c             	shr    $0xc,%edx
f0101aea:	3b 15 88 7e 2a f0    	cmp    0xf02a7e88,%edx
f0101af0:	0f 83 1d 02 00 00    	jae    f0101d13 <mem_init+0x4f6>
	memset(page2kva(pp0), 1, PGSIZE);
f0101af6:	83 ec 04             	sub    $0x4,%esp
f0101af9:	68 00 10 00 00       	push   $0x1000
f0101afe:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101b00:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101b05:	50                   	push   %eax
f0101b06:	e8 3e 45 00 00       	call   f0106049 <memset>
	page_free(pp0);
f0101b0b:	89 34 24             	mov    %esi,(%esp)
f0101b0e:	e8 5b f9 ff ff       	call   f010146e <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101b13:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101b1a:	e8 dd f8 ff ff       	call   f01013fc <page_alloc>
f0101b1f:	83 c4 10             	add    $0x10,%esp
f0101b22:	85 c0                	test   %eax,%eax
f0101b24:	0f 84 fb 01 00 00    	je     f0101d25 <mem_init+0x508>
	assert(pp && pp0 == pp);
f0101b2a:	39 c6                	cmp    %eax,%esi
f0101b2c:	0f 85 0c 02 00 00    	jne    f0101d3e <mem_init+0x521>
	return (pp - pages) << PGSHIFT;
f0101b32:	89 f2                	mov    %esi,%edx
f0101b34:	2b 15 90 7e 2a f0    	sub    0xf02a7e90,%edx
f0101b3a:	c1 fa 03             	sar    $0x3,%edx
f0101b3d:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101b40:	89 d0                	mov    %edx,%eax
f0101b42:	c1 e8 0c             	shr    $0xc,%eax
f0101b45:	3b 05 88 7e 2a f0    	cmp    0xf02a7e88,%eax
f0101b4b:	0f 83 06 02 00 00    	jae    f0101d57 <mem_init+0x53a>
	return (void *)(pa + KERNBASE);
f0101b51:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101b57:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101b5d:	80 38 00             	cmpb   $0x0,(%eax)
f0101b60:	0f 85 03 02 00 00    	jne    f0101d69 <mem_init+0x54c>
f0101b66:	40                   	inc    %eax
	for (i = 0; i < PGSIZE; i++)
f0101b67:	39 d0                	cmp    %edx,%eax
f0101b69:	75 f2                	jne    f0101b5d <mem_init+0x340>
	page_free_list = fl;
f0101b6b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b6e:	a3 40 72 2a f0       	mov    %eax,0xf02a7240
	page_free(pp0);
f0101b73:	83 ec 0c             	sub    $0xc,%esp
f0101b76:	56                   	push   %esi
f0101b77:	e8 f2 f8 ff ff       	call   f010146e <page_free>
	page_free(pp1);
f0101b7c:	89 3c 24             	mov    %edi,(%esp)
f0101b7f:	e8 ea f8 ff ff       	call   f010146e <page_free>
	page_free(pp2);
f0101b84:	83 c4 04             	add    $0x4,%esp
f0101b87:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b8a:	e8 df f8 ff ff       	call   f010146e <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b8f:	a1 40 72 2a f0       	mov    0xf02a7240,%eax
f0101b94:	83 c4 10             	add    $0x10,%esp
f0101b97:	e9 e9 01 00 00       	jmp    f0101d85 <mem_init+0x568>
	assert((pp0 = page_alloc(0)));
f0101b9c:	68 a7 80 10 f0       	push   $0xf01080a7
f0101ba1:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101ba6:	68 eb 02 00 00       	push   $0x2eb
f0101bab:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101bb0:	e8 df e4 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101bb5:	68 bd 80 10 f0       	push   $0xf01080bd
f0101bba:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101bbf:	68 ec 02 00 00       	push   $0x2ec
f0101bc4:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101bc9:	e8 c6 e4 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101bce:	68 d3 80 10 f0       	push   $0xf01080d3
f0101bd3:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101bd8:	68 ed 02 00 00       	push   $0x2ed
f0101bdd:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101be2:	e8 ad e4 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f0101be7:	68 e9 80 10 f0       	push   $0xf01080e9
f0101bec:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101bf1:	68 f0 02 00 00       	push   $0x2f0
f0101bf6:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101bfb:	e8 94 e4 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c00:	68 a0 77 10 f0       	push   $0xf01077a0
f0101c05:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101c0a:	68 f1 02 00 00       	push   $0x2f1
f0101c0f:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101c14:	e8 7b e4 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101c19:	68 fb 80 10 f0       	push   $0xf01080fb
f0101c1e:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101c23:	68 f2 02 00 00       	push   $0x2f2
f0101c28:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101c2d:	e8 62 e4 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101c32:	68 18 81 10 f0       	push   $0xf0108118
f0101c37:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101c3c:	68 f3 02 00 00       	push   $0x2f3
f0101c41:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101c46:	e8 49 e4 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101c4b:	68 35 81 10 f0       	push   $0xf0108135
f0101c50:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101c55:	68 f4 02 00 00       	push   $0x2f4
f0101c5a:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101c5f:	e8 30 e4 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101c64:	68 52 81 10 f0       	push   $0xf0108152
f0101c69:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101c6e:	68 fb 02 00 00       	push   $0x2fb
f0101c73:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101c78:	e8 17 e4 ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0101c7d:	68 a7 80 10 f0       	push   $0xf01080a7
f0101c82:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101c87:	68 02 03 00 00       	push   $0x302
f0101c8c:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101c91:	e8 fe e3 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c96:	68 bd 80 10 f0       	push   $0xf01080bd
f0101c9b:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101ca0:	68 03 03 00 00       	push   $0x303
f0101ca5:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101caa:	e8 e5 e3 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101caf:	68 d3 80 10 f0       	push   $0xf01080d3
f0101cb4:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101cb9:	68 04 03 00 00       	push   $0x304
f0101cbe:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101cc3:	e8 cc e3 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f0101cc8:	68 e9 80 10 f0       	push   $0xf01080e9
f0101ccd:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101cd2:	68 06 03 00 00       	push   $0x306
f0101cd7:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101cdc:	e8 b3 e3 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101ce1:	68 a0 77 10 f0       	push   $0xf01077a0
f0101ce6:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101ceb:	68 07 03 00 00       	push   $0x307
f0101cf0:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101cf5:	e8 9a e3 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101cfa:	68 52 81 10 f0       	push   $0xf0108152
f0101cff:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101d04:	68 08 03 00 00       	push   $0x308
f0101d09:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101d0e:	e8 81 e3 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d13:	50                   	push   %eax
f0101d14:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0101d19:	6a 58                	push   $0x58
f0101d1b:	68 89 7f 10 f0       	push   $0xf0107f89
f0101d20:	e8 6f e3 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101d25:	68 61 81 10 f0       	push   $0xf0108161
f0101d2a:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101d2f:	68 0d 03 00 00       	push   $0x30d
f0101d34:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101d39:	e8 56 e3 ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f0101d3e:	68 7f 81 10 f0       	push   $0xf010817f
f0101d43:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101d48:	68 0e 03 00 00       	push   $0x30e
f0101d4d:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101d52:	e8 3d e3 ff ff       	call   f0100094 <_panic>
f0101d57:	52                   	push   %edx
f0101d58:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0101d5d:	6a 58                	push   $0x58
f0101d5f:	68 89 7f 10 f0       	push   $0xf0107f89
f0101d64:	e8 2b e3 ff ff       	call   f0100094 <_panic>
		assert(c[i] == 0);
f0101d69:	68 8f 81 10 f0       	push   $0xf010818f
f0101d6e:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0101d73:	68 11 03 00 00       	push   $0x311
f0101d78:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0101d7d:	e8 12 e3 ff ff       	call   f0100094 <_panic>
		--nfree;
f0101d82:	4b                   	dec    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101d83:	8b 00                	mov    (%eax),%eax
f0101d85:	85 c0                	test   %eax,%eax
f0101d87:	75 f9                	jne    f0101d82 <mem_init+0x565>
	assert(nfree == 0);
f0101d89:	85 db                	test   %ebx,%ebx
f0101d8b:	0f 85 87 09 00 00    	jne    f0102718 <mem_init+0xefb>
	cprintf("check_page_alloc() succeeded!\n");
f0101d91:	83 ec 0c             	sub    $0xc,%esp
f0101d94:	68 c0 77 10 f0       	push   $0xf01077c0
f0101d99:	e8 e6 21 00 00       	call   f0103f84 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101d9e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101da5:	e8 52 f6 ff ff       	call   f01013fc <page_alloc>
f0101daa:	89 c7                	mov    %eax,%edi
f0101dac:	83 c4 10             	add    $0x10,%esp
f0101daf:	85 c0                	test   %eax,%eax
f0101db1:	0f 84 7a 09 00 00    	je     f0102731 <mem_init+0xf14>
	assert((pp1 = page_alloc(0)));
f0101db7:	83 ec 0c             	sub    $0xc,%esp
f0101dba:	6a 00                	push   $0x0
f0101dbc:	e8 3b f6 ff ff       	call   f01013fc <page_alloc>
f0101dc1:	89 c3                	mov    %eax,%ebx
f0101dc3:	83 c4 10             	add    $0x10,%esp
f0101dc6:	85 c0                	test   %eax,%eax
f0101dc8:	0f 84 7c 09 00 00    	je     f010274a <mem_init+0xf2d>
	assert((pp2 = page_alloc(0)));
f0101dce:	83 ec 0c             	sub    $0xc,%esp
f0101dd1:	6a 00                	push   $0x0
f0101dd3:	e8 24 f6 ff ff       	call   f01013fc <page_alloc>
f0101dd8:	89 c6                	mov    %eax,%esi
f0101dda:	83 c4 10             	add    $0x10,%esp
f0101ddd:	85 c0                	test   %eax,%eax
f0101ddf:	0f 84 7e 09 00 00    	je     f0102763 <mem_init+0xf46>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101de5:	39 df                	cmp    %ebx,%edi
f0101de7:	0f 84 8f 09 00 00    	je     f010277c <mem_init+0xf5f>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101ded:	39 c3                	cmp    %eax,%ebx
f0101def:	0f 84 a0 09 00 00    	je     f0102795 <mem_init+0xf78>
f0101df5:	39 c7                	cmp    %eax,%edi
f0101df7:	0f 84 98 09 00 00    	je     f0102795 <mem_init+0xf78>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101dfd:	a1 40 72 2a f0       	mov    0xf02a7240,%eax
f0101e02:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f0101e05:	c7 05 40 72 2a f0 00 	movl   $0x0,0xf02a7240
f0101e0c:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101e0f:	83 ec 0c             	sub    $0xc,%esp
f0101e12:	6a 00                	push   $0x0
f0101e14:	e8 e3 f5 ff ff       	call   f01013fc <page_alloc>
f0101e19:	83 c4 10             	add    $0x10,%esp
f0101e1c:	85 c0                	test   %eax,%eax
f0101e1e:	0f 85 8a 09 00 00    	jne    f01027ae <mem_init+0xf91>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101e24:	83 ec 04             	sub    $0x4,%esp
f0101e27:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101e2a:	50                   	push   %eax
f0101e2b:	6a 00                	push   $0x0
f0101e2d:	ff 35 8c 7e 2a f0    	pushl  0xf02a7e8c
f0101e33:	e8 14 f8 ff ff       	call   f010164c <page_lookup>
f0101e38:	83 c4 10             	add    $0x10,%esp
f0101e3b:	85 c0                	test   %eax,%eax
f0101e3d:	0f 85 84 09 00 00    	jne    f01027c7 <mem_init+0xfaa>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101e43:	6a 02                	push   $0x2
f0101e45:	6a 00                	push   $0x0
f0101e47:	53                   	push   %ebx
f0101e48:	ff 35 8c 7e 2a f0    	pushl  0xf02a7e8c
f0101e4e:	e8 02 f9 ff ff       	call   f0101755 <page_insert>
f0101e53:	83 c4 10             	add    $0x10,%esp
f0101e56:	85 c0                	test   %eax,%eax
f0101e58:	0f 89 82 09 00 00    	jns    f01027e0 <mem_init+0xfc3>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101e5e:	83 ec 0c             	sub    $0xc,%esp
f0101e61:	57                   	push   %edi
f0101e62:	e8 07 f6 ff ff       	call   f010146e <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101e67:	6a 02                	push   $0x2
f0101e69:	6a 00                	push   $0x0
f0101e6b:	53                   	push   %ebx
f0101e6c:	ff 35 8c 7e 2a f0    	pushl  0xf02a7e8c
f0101e72:	e8 de f8 ff ff       	call   f0101755 <page_insert>
f0101e77:	83 c4 20             	add    $0x20,%esp
f0101e7a:	85 c0                	test   %eax,%eax
f0101e7c:	0f 85 77 09 00 00    	jne    f01027f9 <mem_init+0xfdc>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e82:	a1 8c 7e 2a f0       	mov    0xf02a7e8c,%eax
f0101e87:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	return (pp - pages) << PGSHIFT;
f0101e8a:	8b 0d 90 7e 2a f0    	mov    0xf02a7e90,%ecx
f0101e90:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101e93:	8b 00                	mov    (%eax),%eax
f0101e95:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101e98:	89 c2                	mov    %eax,%edx
f0101e9a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101ea0:	89 f8                	mov    %edi,%eax
f0101ea2:	29 c8                	sub    %ecx,%eax
f0101ea4:	c1 f8 03             	sar    $0x3,%eax
f0101ea7:	c1 e0 0c             	shl    $0xc,%eax
f0101eaa:	39 c2                	cmp    %eax,%edx
f0101eac:	0f 85 60 09 00 00    	jne    f0102812 <mem_init+0xff5>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101eb2:	ba 00 00 00 00       	mov    $0x0,%edx
f0101eb7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101eba:	e8 29 f1 ff ff       	call   f0100fe8 <check_va2pa>
f0101ebf:	89 da                	mov    %ebx,%edx
f0101ec1:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101ec4:	c1 fa 03             	sar    $0x3,%edx
f0101ec7:	c1 e2 0c             	shl    $0xc,%edx
f0101eca:	39 d0                	cmp    %edx,%eax
f0101ecc:	0f 85 59 09 00 00    	jne    f010282b <mem_init+0x100e>
	assert(pp1->pp_ref == 1);
f0101ed2:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ed7:	0f 85 67 09 00 00    	jne    f0102844 <mem_init+0x1027>
	assert(pp0->pp_ref == 1);
f0101edd:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101ee2:	0f 85 75 09 00 00    	jne    f010285d <mem_init+0x1040>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ee8:	6a 02                	push   $0x2
f0101eea:	68 00 10 00 00       	push   $0x1000
f0101eef:	56                   	push   %esi
f0101ef0:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101ef3:	e8 5d f8 ff ff       	call   f0101755 <page_insert>
f0101ef8:	83 c4 10             	add    $0x10,%esp
f0101efb:	85 c0                	test   %eax,%eax
f0101efd:	0f 85 73 09 00 00    	jne    f0102876 <mem_init+0x1059>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f03:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f08:	a1 8c 7e 2a f0       	mov    0xf02a7e8c,%eax
f0101f0d:	e8 d6 f0 ff ff       	call   f0100fe8 <check_va2pa>
f0101f12:	89 f2                	mov    %esi,%edx
f0101f14:	2b 15 90 7e 2a f0    	sub    0xf02a7e90,%edx
f0101f1a:	c1 fa 03             	sar    $0x3,%edx
f0101f1d:	c1 e2 0c             	shl    $0xc,%edx
f0101f20:	39 d0                	cmp    %edx,%eax
f0101f22:	0f 85 67 09 00 00    	jne    f010288f <mem_init+0x1072>
	assert(pp2->pp_ref == 1);
f0101f28:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f2d:	0f 85 75 09 00 00    	jne    f01028a8 <mem_init+0x108b>

	// should be no free memory
	assert(!page_alloc(0));
f0101f33:	83 ec 0c             	sub    $0xc,%esp
f0101f36:	6a 00                	push   $0x0
f0101f38:	e8 bf f4 ff ff       	call   f01013fc <page_alloc>
f0101f3d:	83 c4 10             	add    $0x10,%esp
f0101f40:	85 c0                	test   %eax,%eax
f0101f42:	0f 85 79 09 00 00    	jne    f01028c1 <mem_init+0x10a4>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f48:	6a 02                	push   $0x2
f0101f4a:	68 00 10 00 00       	push   $0x1000
f0101f4f:	56                   	push   %esi
f0101f50:	ff 35 8c 7e 2a f0    	pushl  0xf02a7e8c
f0101f56:	e8 fa f7 ff ff       	call   f0101755 <page_insert>
f0101f5b:	83 c4 10             	add    $0x10,%esp
f0101f5e:	85 c0                	test   %eax,%eax
f0101f60:	0f 85 74 09 00 00    	jne    f01028da <mem_init+0x10bd>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f66:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f6b:	a1 8c 7e 2a f0       	mov    0xf02a7e8c,%eax
f0101f70:	e8 73 f0 ff ff       	call   f0100fe8 <check_va2pa>
f0101f75:	89 f2                	mov    %esi,%edx
f0101f77:	2b 15 90 7e 2a f0    	sub    0xf02a7e90,%edx
f0101f7d:	c1 fa 03             	sar    $0x3,%edx
f0101f80:	c1 e2 0c             	shl    $0xc,%edx
f0101f83:	39 d0                	cmp    %edx,%eax
f0101f85:	0f 85 68 09 00 00    	jne    f01028f3 <mem_init+0x10d6>
	assert(pp2->pp_ref == 1);
f0101f8b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f90:	0f 85 76 09 00 00    	jne    f010290c <mem_init+0x10ef>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101f96:	83 ec 0c             	sub    $0xc,%esp
f0101f99:	6a 00                	push   $0x0
f0101f9b:	e8 5c f4 ff ff       	call   f01013fc <page_alloc>
f0101fa0:	83 c4 10             	add    $0x10,%esp
f0101fa3:	85 c0                	test   %eax,%eax
f0101fa5:	0f 85 7a 09 00 00    	jne    f0102925 <mem_init+0x1108>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101fab:	8b 15 8c 7e 2a f0    	mov    0xf02a7e8c,%edx
f0101fb1:	8b 02                	mov    (%edx),%eax
f0101fb3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101fb8:	89 c1                	mov    %eax,%ecx
f0101fba:	c1 e9 0c             	shr    $0xc,%ecx
f0101fbd:	3b 0d 88 7e 2a f0    	cmp    0xf02a7e88,%ecx
f0101fc3:	0f 83 75 09 00 00    	jae    f010293e <mem_init+0x1121>
	return (void *)(pa + KERNBASE);
f0101fc9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101fce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101fd1:	83 ec 04             	sub    $0x4,%esp
f0101fd4:	6a 00                	push   $0x0
f0101fd6:	68 00 10 00 00       	push   $0x1000
f0101fdb:	52                   	push   %edx
f0101fdc:	e8 05 f5 ff ff       	call   f01014e6 <pgdir_walk>
f0101fe1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101fe4:	8d 51 04             	lea    0x4(%ecx),%edx
f0101fe7:	83 c4 10             	add    $0x10,%esp
f0101fea:	39 d0                	cmp    %edx,%eax
f0101fec:	0f 85 61 09 00 00    	jne    f0102953 <mem_init+0x1136>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101ff2:	6a 06                	push   $0x6
f0101ff4:	68 00 10 00 00       	push   $0x1000
f0101ff9:	56                   	push   %esi
f0101ffa:	ff 35 8c 7e 2a f0    	pushl  0xf02a7e8c
f0102000:	e8 50 f7 ff ff       	call   f0101755 <page_insert>
f0102005:	83 c4 10             	add    $0x10,%esp
f0102008:	85 c0                	test   %eax,%eax
f010200a:	0f 85 5c 09 00 00    	jne    f010296c <mem_init+0x114f>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102010:	a1 8c 7e 2a f0       	mov    0xf02a7e8c,%eax
f0102015:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102018:	ba 00 10 00 00       	mov    $0x1000,%edx
f010201d:	e8 c6 ef ff ff       	call   f0100fe8 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0102022:	89 f2                	mov    %esi,%edx
f0102024:	2b 15 90 7e 2a f0    	sub    0xf02a7e90,%edx
f010202a:	c1 fa 03             	sar    $0x3,%edx
f010202d:	c1 e2 0c             	shl    $0xc,%edx
f0102030:	39 d0                	cmp    %edx,%eax
f0102032:	0f 85 4d 09 00 00    	jne    f0102985 <mem_init+0x1168>
	assert(pp2->pp_ref == 1);
f0102038:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010203d:	0f 85 5b 09 00 00    	jne    f010299e <mem_init+0x1181>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102043:	83 ec 04             	sub    $0x4,%esp
f0102046:	6a 00                	push   $0x0
f0102048:	68 00 10 00 00       	push   $0x1000
f010204d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102050:	e8 91 f4 ff ff       	call   f01014e6 <pgdir_walk>
f0102055:	83 c4 10             	add    $0x10,%esp
f0102058:	f6 00 04             	testb  $0x4,(%eax)
f010205b:	0f 84 56 09 00 00    	je     f01029b7 <mem_init+0x119a>
	assert(kern_pgdir[0] & PTE_U);
f0102061:	a1 8c 7e 2a f0       	mov    0xf02a7e8c,%eax
f0102066:	f6 00 04             	testb  $0x4,(%eax)
f0102069:	0f 84 61 09 00 00    	je     f01029d0 <mem_init+0x11b3>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010206f:	6a 02                	push   $0x2
f0102071:	68 00 10 00 00       	push   $0x1000
f0102076:	56                   	push   %esi
f0102077:	50                   	push   %eax
f0102078:	e8 d8 f6 ff ff       	call   f0101755 <page_insert>
f010207d:	83 c4 10             	add    $0x10,%esp
f0102080:	85 c0                	test   %eax,%eax
f0102082:	0f 85 61 09 00 00    	jne    f01029e9 <mem_init+0x11cc>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102088:	83 ec 04             	sub    $0x4,%esp
f010208b:	6a 00                	push   $0x0
f010208d:	68 00 10 00 00       	push   $0x1000
f0102092:	ff 35 8c 7e 2a f0    	pushl  0xf02a7e8c
f0102098:	e8 49 f4 ff ff       	call   f01014e6 <pgdir_walk>
f010209d:	83 c4 10             	add    $0x10,%esp
f01020a0:	f6 00 02             	testb  $0x2,(%eax)
f01020a3:	0f 84 59 09 00 00    	je     f0102a02 <mem_init+0x11e5>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020a9:	83 ec 04             	sub    $0x4,%esp
f01020ac:	6a 00                	push   $0x0
f01020ae:	68 00 10 00 00       	push   $0x1000
f01020b3:	ff 35 8c 7e 2a f0    	pushl  0xf02a7e8c
f01020b9:	e8 28 f4 ff ff       	call   f01014e6 <pgdir_walk>
f01020be:	83 c4 10             	add    $0x10,%esp
f01020c1:	f6 00 04             	testb  $0x4,(%eax)
f01020c4:	0f 85 51 09 00 00    	jne    f0102a1b <mem_init+0x11fe>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01020ca:	6a 02                	push   $0x2
f01020cc:	68 00 00 40 00       	push   $0x400000
f01020d1:	57                   	push   %edi
f01020d2:	ff 35 8c 7e 2a f0    	pushl  0xf02a7e8c
f01020d8:	e8 78 f6 ff ff       	call   f0101755 <page_insert>
f01020dd:	83 c4 10             	add    $0x10,%esp
f01020e0:	85 c0                	test   %eax,%eax
f01020e2:	0f 89 4c 09 00 00    	jns    f0102a34 <mem_init+0x1217>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01020e8:	6a 02                	push   $0x2
f01020ea:	68 00 10 00 00       	push   $0x1000
f01020ef:	53                   	push   %ebx
f01020f0:	ff 35 8c 7e 2a f0    	pushl  0xf02a7e8c
f01020f6:	e8 5a f6 ff ff       	call   f0101755 <page_insert>
f01020fb:	83 c4 10             	add    $0x10,%esp
f01020fe:	85 c0                	test   %eax,%eax
f0102100:	0f 85 47 09 00 00    	jne    f0102a4d <mem_init+0x1230>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102106:	83 ec 04             	sub    $0x4,%esp
f0102109:	6a 00                	push   $0x0
f010210b:	68 00 10 00 00       	push   $0x1000
f0102110:	ff 35 8c 7e 2a f0    	pushl  0xf02a7e8c
f0102116:	e8 cb f3 ff ff       	call   f01014e6 <pgdir_walk>
f010211b:	83 c4 10             	add    $0x10,%esp
f010211e:	f6 00 04             	testb  $0x4,(%eax)
f0102121:	0f 85 3f 09 00 00    	jne    f0102a66 <mem_init+0x1249>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102127:	a1 8c 7e 2a f0       	mov    0xf02a7e8c,%eax
f010212c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010212f:	ba 00 00 00 00       	mov    $0x0,%edx
f0102134:	e8 af ee ff ff       	call   f0100fe8 <check_va2pa>
f0102139:	89 c1                	mov    %eax,%ecx
f010213b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010213e:	89 d8                	mov    %ebx,%eax
f0102140:	2b 05 90 7e 2a f0    	sub    0xf02a7e90,%eax
f0102146:	c1 f8 03             	sar    $0x3,%eax
f0102149:	c1 e0 0c             	shl    $0xc,%eax
f010214c:	39 c1                	cmp    %eax,%ecx
f010214e:	0f 85 2b 09 00 00    	jne    f0102a7f <mem_init+0x1262>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102154:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102159:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010215c:	e8 87 ee ff ff       	call   f0100fe8 <check_va2pa>
f0102161:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102164:	0f 85 2e 09 00 00    	jne    f0102a98 <mem_init+0x127b>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010216a:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f010216f:	0f 85 3c 09 00 00    	jne    f0102ab1 <mem_init+0x1294>
	assert(pp2->pp_ref == 0);
f0102175:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010217a:	0f 85 4a 09 00 00    	jne    f0102aca <mem_init+0x12ad>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102180:	83 ec 0c             	sub    $0xc,%esp
f0102183:	6a 00                	push   $0x0
f0102185:	e8 72 f2 ff ff       	call   f01013fc <page_alloc>
f010218a:	83 c4 10             	add    $0x10,%esp
f010218d:	85 c0                	test   %eax,%eax
f010218f:	0f 84 4e 09 00 00    	je     f0102ae3 <mem_init+0x12c6>
f0102195:	39 c6                	cmp    %eax,%esi
f0102197:	0f 85 46 09 00 00    	jne    f0102ae3 <mem_init+0x12c6>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010219d:	83 ec 08             	sub    $0x8,%esp
f01021a0:	6a 00                	push   $0x0
f01021a2:	ff 35 8c 7e 2a f0    	pushl  0xf02a7e8c
f01021a8:	e8 4e f5 ff ff       	call   f01016fb <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01021ad:	a1 8c 7e 2a f0       	mov    0xf02a7e8c,%eax
f01021b2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01021b5:	ba 00 00 00 00       	mov    $0x0,%edx
f01021ba:	e8 29 ee ff ff       	call   f0100fe8 <check_va2pa>
f01021bf:	83 c4 10             	add    $0x10,%esp
f01021c2:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021c5:	0f 85 31 09 00 00    	jne    f0102afc <mem_init+0x12df>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01021cb:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021d0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021d3:	e8 10 ee ff ff       	call   f0100fe8 <check_va2pa>
f01021d8:	89 da                	mov    %ebx,%edx
f01021da:	2b 15 90 7e 2a f0    	sub    0xf02a7e90,%edx
f01021e0:	c1 fa 03             	sar    $0x3,%edx
f01021e3:	c1 e2 0c             	shl    $0xc,%edx
f01021e6:	39 d0                	cmp    %edx,%eax
f01021e8:	0f 85 27 09 00 00    	jne    f0102b15 <mem_init+0x12f8>
	assert(pp1->pp_ref == 1);
f01021ee:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01021f3:	0f 85 35 09 00 00    	jne    f0102b2e <mem_init+0x1311>
	assert(pp2->pp_ref == 0);
f01021f9:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01021fe:	0f 85 43 09 00 00    	jne    f0102b47 <mem_init+0x132a>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102204:	6a 00                	push   $0x0
f0102206:	68 00 10 00 00       	push   $0x1000
f010220b:	53                   	push   %ebx
f010220c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010220f:	e8 41 f5 ff ff       	call   f0101755 <page_insert>
f0102214:	83 c4 10             	add    $0x10,%esp
f0102217:	85 c0                	test   %eax,%eax
f0102219:	0f 85 41 09 00 00    	jne    f0102b60 <mem_init+0x1343>
	assert(pp1->pp_ref);
f010221f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102224:	0f 84 4f 09 00 00    	je     f0102b79 <mem_init+0x135c>
	assert(pp1->pp_link == NULL);
f010222a:	83 3b 00             	cmpl   $0x0,(%ebx)
f010222d:	0f 85 5f 09 00 00    	jne    f0102b92 <mem_init+0x1375>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102233:	83 ec 08             	sub    $0x8,%esp
f0102236:	68 00 10 00 00       	push   $0x1000
f010223b:	ff 35 8c 7e 2a f0    	pushl  0xf02a7e8c
f0102241:	e8 b5 f4 ff ff       	call   f01016fb <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102246:	a1 8c 7e 2a f0       	mov    0xf02a7e8c,%eax
f010224b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010224e:	ba 00 00 00 00       	mov    $0x0,%edx
f0102253:	e8 90 ed ff ff       	call   f0100fe8 <check_va2pa>
f0102258:	83 c4 10             	add    $0x10,%esp
f010225b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010225e:	0f 85 47 09 00 00    	jne    f0102bab <mem_init+0x138e>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102264:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102269:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010226c:	e8 77 ed ff ff       	call   f0100fe8 <check_va2pa>
f0102271:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102274:	0f 85 4a 09 00 00    	jne    f0102bc4 <mem_init+0x13a7>
	assert(pp1->pp_ref == 0);
f010227a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010227f:	0f 85 58 09 00 00    	jne    f0102bdd <mem_init+0x13c0>
	assert(pp2->pp_ref == 0);
f0102285:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010228a:	0f 85 66 09 00 00    	jne    f0102bf6 <mem_init+0x13d9>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102290:	83 ec 0c             	sub    $0xc,%esp
f0102293:	6a 00                	push   $0x0
f0102295:	e8 62 f1 ff ff       	call   f01013fc <page_alloc>
f010229a:	83 c4 10             	add    $0x10,%esp
f010229d:	85 c0                	test   %eax,%eax
f010229f:	0f 84 6a 09 00 00    	je     f0102c0f <mem_init+0x13f2>
f01022a5:	39 c3                	cmp    %eax,%ebx
f01022a7:	0f 85 62 09 00 00    	jne    f0102c0f <mem_init+0x13f2>

	// should be no free memory
	assert(!page_alloc(0));
f01022ad:	83 ec 0c             	sub    $0xc,%esp
f01022b0:	6a 00                	push   $0x0
f01022b2:	e8 45 f1 ff ff       	call   f01013fc <page_alloc>
f01022b7:	83 c4 10             	add    $0x10,%esp
f01022ba:	85 c0                	test   %eax,%eax
f01022bc:	0f 85 66 09 00 00    	jne    f0102c28 <mem_init+0x140b>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022c2:	8b 0d 8c 7e 2a f0    	mov    0xf02a7e8c,%ecx
f01022c8:	8b 11                	mov    (%ecx),%edx
f01022ca:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01022d0:	89 f8                	mov    %edi,%eax
f01022d2:	2b 05 90 7e 2a f0    	sub    0xf02a7e90,%eax
f01022d8:	c1 f8 03             	sar    $0x3,%eax
f01022db:	c1 e0 0c             	shl    $0xc,%eax
f01022de:	39 c2                	cmp    %eax,%edx
f01022e0:	0f 85 5b 09 00 00    	jne    f0102c41 <mem_init+0x1424>
	kern_pgdir[0] = 0;
f01022e6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01022ec:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01022f1:	0f 85 63 09 00 00    	jne    f0102c5a <mem_init+0x143d>
	pp0->pp_ref = 0;
f01022f7:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01022fd:	83 ec 0c             	sub    $0xc,%esp
f0102300:	57                   	push   %edi
f0102301:	e8 68 f1 ff ff       	call   f010146e <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102306:	83 c4 0c             	add    $0xc,%esp
f0102309:	6a 01                	push   $0x1
f010230b:	68 00 10 40 00       	push   $0x401000
f0102310:	ff 35 8c 7e 2a f0    	pushl  0xf02a7e8c
f0102316:	e8 cb f1 ff ff       	call   f01014e6 <pgdir_walk>
f010231b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010231e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102321:	a1 8c 7e 2a f0       	mov    0xf02a7e8c,%eax
f0102326:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102329:	8b 50 04             	mov    0x4(%eax),%edx
f010232c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0102332:	a1 88 7e 2a f0       	mov    0xf02a7e88,%eax
f0102337:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010233a:	89 d1                	mov    %edx,%ecx
f010233c:	c1 e9 0c             	shr    $0xc,%ecx
f010233f:	83 c4 10             	add    $0x10,%esp
f0102342:	39 c1                	cmp    %eax,%ecx
f0102344:	0f 83 29 09 00 00    	jae    f0102c73 <mem_init+0x1456>
	assert(ptep == ptep1 + PTX(va));
f010234a:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102350:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0102353:	0f 85 2f 09 00 00    	jne    f0102c88 <mem_init+0x146b>
	kern_pgdir[PDX(va)] = 0;
f0102359:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010235c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102363:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
	return (pp - pages) << PGSHIFT;
f0102369:	89 f8                	mov    %edi,%eax
f010236b:	2b 05 90 7e 2a f0    	sub    0xf02a7e90,%eax
f0102371:	c1 f8 03             	sar    $0x3,%eax
f0102374:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102377:	89 c2                	mov    %eax,%edx
f0102379:	c1 ea 0c             	shr    $0xc,%edx
f010237c:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f010237f:	0f 86 1c 09 00 00    	jbe    f0102ca1 <mem_init+0x1484>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102385:	83 ec 04             	sub    $0x4,%esp
f0102388:	68 00 10 00 00       	push   $0x1000
f010238d:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0102392:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102397:	50                   	push   %eax
f0102398:	e8 ac 3c 00 00       	call   f0106049 <memset>
	page_free(pp0);
f010239d:	89 3c 24             	mov    %edi,(%esp)
f01023a0:	e8 c9 f0 ff ff       	call   f010146e <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01023a5:	83 c4 0c             	add    $0xc,%esp
f01023a8:	6a 01                	push   $0x1
f01023aa:	6a 00                	push   $0x0
f01023ac:	ff 35 8c 7e 2a f0    	pushl  0xf02a7e8c
f01023b2:	e8 2f f1 ff ff       	call   f01014e6 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f01023b7:	89 fa                	mov    %edi,%edx
f01023b9:	2b 15 90 7e 2a f0    	sub    0xf02a7e90,%edx
f01023bf:	c1 fa 03             	sar    $0x3,%edx
f01023c2:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01023c5:	89 d0                	mov    %edx,%eax
f01023c7:	c1 e8 0c             	shr    $0xc,%eax
f01023ca:	83 c4 10             	add    $0x10,%esp
f01023cd:	3b 05 88 7e 2a f0    	cmp    0xf02a7e88,%eax
f01023d3:	0f 83 da 08 00 00    	jae    f0102cb3 <mem_init+0x1496>
	return (void *)(pa + KERNBASE);
f01023d9:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01023df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01023e2:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01023e8:	f6 00 01             	testb  $0x1,(%eax)
f01023eb:	0f 85 d4 08 00 00    	jne    f0102cc5 <mem_init+0x14a8>
f01023f1:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f01023f4:	39 d0                	cmp    %edx,%eax
f01023f6:	75 f0                	jne    f01023e8 <mem_init+0xbcb>
	kern_pgdir[0] = 0;
f01023f8:	a1 8c 7e 2a f0       	mov    0xf02a7e8c,%eax
f01023fd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102403:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102409:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010240c:	a3 40 72 2a f0       	mov    %eax,0xf02a7240

	// free the pages we took
	page_free(pp0);
f0102411:	83 ec 0c             	sub    $0xc,%esp
f0102414:	57                   	push   %edi
f0102415:	e8 54 f0 ff ff       	call   f010146e <page_free>
	page_free(pp1);
f010241a:	89 1c 24             	mov    %ebx,(%esp)
f010241d:	e8 4c f0 ff ff       	call   f010146e <page_free>
	page_free(pp2);
f0102422:	89 34 24             	mov    %esi,(%esp)
f0102425:	e8 44 f0 ff ff       	call   f010146e <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010242a:	83 c4 08             	add    $0x8,%esp
f010242d:	68 01 10 00 00       	push   $0x1001
f0102432:	6a 00                	push   $0x0
f0102434:	e8 83 f3 ff ff       	call   f01017bc <mmio_map_region>
f0102439:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f010243b:	83 c4 08             	add    $0x8,%esp
f010243e:	68 00 10 00 00       	push   $0x1000
f0102443:	6a 00                	push   $0x0
f0102445:	e8 72 f3 ff ff       	call   f01017bc <mmio_map_region>
f010244a:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f010244c:	83 c4 10             	add    $0x10,%esp
f010244f:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102455:	0f 86 83 08 00 00    	jbe    f0102cde <mem_init+0x14c1>
f010245b:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102461:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102466:	0f 87 72 08 00 00    	ja     f0102cde <mem_init+0x14c1>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f010246c:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102472:	0f 86 7f 08 00 00    	jbe    f0102cf7 <mem_init+0x14da>
f0102478:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f010247e:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102484:	0f 87 6d 08 00 00    	ja     f0102cf7 <mem_init+0x14da>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f010248a:	89 da                	mov    %ebx,%edx
f010248c:	09 f2                	or     %esi,%edx
f010248e:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102494:	0f 85 76 08 00 00    	jne    f0102d10 <mem_init+0x14f3>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f010249a:	39 c6                	cmp    %eax,%esi
f010249c:	0f 82 87 08 00 00    	jb     f0102d29 <mem_init+0x150c>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01024a2:	8b 3d 8c 7e 2a f0    	mov    0xf02a7e8c,%edi
f01024a8:	89 da                	mov    %ebx,%edx
f01024aa:	89 f8                	mov    %edi,%eax
f01024ac:	e8 37 eb ff ff       	call   f0100fe8 <check_va2pa>
f01024b1:	85 c0                	test   %eax,%eax
f01024b3:	0f 85 89 08 00 00    	jne    f0102d42 <mem_init+0x1525>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01024b9:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01024bf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01024c2:	89 c2                	mov    %eax,%edx
f01024c4:	89 f8                	mov    %edi,%eax
f01024c6:	e8 1d eb ff ff       	call   f0100fe8 <check_va2pa>
f01024cb:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01024d0:	0f 85 85 08 00 00    	jne    f0102d5b <mem_init+0x153e>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01024d6:	89 f2                	mov    %esi,%edx
f01024d8:	89 f8                	mov    %edi,%eax
f01024da:	e8 09 eb ff ff       	call   f0100fe8 <check_va2pa>
f01024df:	85 c0                	test   %eax,%eax
f01024e1:	0f 85 8d 08 00 00    	jne    f0102d74 <mem_init+0x1557>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01024e7:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01024ed:	89 f8                	mov    %edi,%eax
f01024ef:	e8 f4 ea ff ff       	call   f0100fe8 <check_va2pa>
f01024f4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024f7:	0f 85 90 08 00 00    	jne    f0102d8d <mem_init+0x1570>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01024fd:	83 ec 04             	sub    $0x4,%esp
f0102500:	6a 00                	push   $0x0
f0102502:	53                   	push   %ebx
f0102503:	57                   	push   %edi
f0102504:	e8 dd ef ff ff       	call   f01014e6 <pgdir_walk>
f0102509:	83 c4 10             	add    $0x10,%esp
f010250c:	f6 00 1a             	testb  $0x1a,(%eax)
f010250f:	0f 84 91 08 00 00    	je     f0102da6 <mem_init+0x1589>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102515:	83 ec 04             	sub    $0x4,%esp
f0102518:	6a 00                	push   $0x0
f010251a:	53                   	push   %ebx
f010251b:	ff 35 8c 7e 2a f0    	pushl  0xf02a7e8c
f0102521:	e8 c0 ef ff ff       	call   f01014e6 <pgdir_walk>
f0102526:	83 c4 10             	add    $0x10,%esp
f0102529:	f6 00 04             	testb  $0x4,(%eax)
f010252c:	0f 85 8d 08 00 00    	jne    f0102dbf <mem_init+0x15a2>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102532:	83 ec 04             	sub    $0x4,%esp
f0102535:	6a 00                	push   $0x0
f0102537:	53                   	push   %ebx
f0102538:	ff 35 8c 7e 2a f0    	pushl  0xf02a7e8c
f010253e:	e8 a3 ef ff ff       	call   f01014e6 <pgdir_walk>
f0102543:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102549:	83 c4 0c             	add    $0xc,%esp
f010254c:	6a 00                	push   $0x0
f010254e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102551:	ff 35 8c 7e 2a f0    	pushl  0xf02a7e8c
f0102557:	e8 8a ef ff ff       	call   f01014e6 <pgdir_walk>
f010255c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102562:	83 c4 0c             	add    $0xc,%esp
f0102565:	6a 00                	push   $0x0
f0102567:	56                   	push   %esi
f0102568:	ff 35 8c 7e 2a f0    	pushl  0xf02a7e8c
f010256e:	e8 73 ef ff ff       	call   f01014e6 <pgdir_walk>
f0102573:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102579:	c7 04 24 82 82 10 f0 	movl   $0xf0108282,(%esp)
f0102580:	e8 ff 19 00 00       	call   f0103f84 <cprintf>
	pginfo_sz = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102585:	a1 88 7e 2a f0       	mov    0xf02a7e88,%eax
f010258a:	8d 0c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ecx
f0102591:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_region(kern_pgdir, UPAGES, pginfo_sz, PADDR(pages), PTE_U | PTE_P);
f0102597:	a1 90 7e 2a f0       	mov    0xf02a7e90,%eax
	if ((uint32_t)kva < KERNBASE)
f010259c:	83 c4 10             	add    $0x10,%esp
f010259f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025a4:	0f 86 2e 08 00 00    	jbe    f0102dd8 <mem_init+0x15bb>
f01025aa:	83 ec 08             	sub    $0x8,%esp
f01025ad:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01025af:	05 00 00 00 10       	add    $0x10000000,%eax
f01025b4:	50                   	push   %eax
f01025b5:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01025ba:	a1 8c 7e 2a f0       	mov    0xf02a7e8c,%eax
f01025bf:	e8 39 f0 ff ff       	call   f01015fd <boot_map_region>
	env_sz = ROUNDUP(npages*sizeof(struct Env), PGSIZE);
f01025c4:	8b 15 88 7e 2a f0    	mov    0xf02a7e88,%edx
f01025ca:	89 d0                	mov    %edx,%eax
f01025cc:	c1 e0 05             	shl    $0x5,%eax
f01025cf:	29 d0                	sub    %edx,%eax
f01025d1:	8d 0c 85 ff 0f 00 00 	lea    0xfff(,%eax,4),%ecx
f01025d8:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_region(kern_pgdir, UENVS, env_sz, PADDR(envs), PTE_U | PTE_P);
f01025de:	a1 48 72 2a f0       	mov    0xf02a7248,%eax
	if ((uint32_t)kva < KERNBASE)
f01025e3:	83 c4 10             	add    $0x10,%esp
f01025e6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025eb:	0f 86 fc 07 00 00    	jbe    f0102ded <mem_init+0x15d0>
f01025f1:	83 ec 08             	sub    $0x8,%esp
f01025f4:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01025f6:	05 00 00 00 10       	add    $0x10000000,%eax
f01025fb:	50                   	push   %eax
f01025fc:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102601:	a1 8c 7e 2a f0       	mov    0xf02a7e8c,%eax
f0102606:	e8 f2 ef ff ff       	call   f01015fd <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f010260b:	83 c4 10             	add    $0x10,%esp
f010260e:	b8 00 90 11 f0       	mov    $0xf0119000,%eax
f0102613:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102618:	0f 86 e4 07 00 00    	jbe    f0102e02 <mem_init+0x15e5>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, 
f010261e:	83 ec 08             	sub    $0x8,%esp
f0102621:	6a 03                	push   $0x3
f0102623:	68 00 90 11 00       	push   $0x119000
f0102628:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010262d:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102632:	a1 8c 7e 2a f0       	mov    0xf02a7e8c,%eax
f0102637:	e8 c1 ef ff ff       	call   f01015fd <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 1 << 28, // 2^32 - 0xf0000000
f010263c:	83 c4 08             	add    $0x8,%esp
f010263f:	6a 03                	push   $0x3
f0102641:	6a 00                	push   $0x0
f0102643:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102648:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010264d:	a1 8c 7e 2a f0       	mov    0xf02a7e8c,%eax
f0102652:	e8 a6 ef ff ff       	call   f01015fd <boot_map_region>
f0102657:	c7 45 c8 00 90 2a f0 	movl   $0xf02a9000,-0x38(%ebp)
f010265e:	be 00 90 2e f0       	mov    $0xf02e9000,%esi
f0102663:	83 c4 10             	add    $0x10,%esp
f0102666:	bf 00 90 2a f0       	mov    $0xf02a9000,%edi
f010266b:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
f0102670:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0102676:	0f 86 9b 07 00 00    	jbe    f0102e17 <mem_init+0x15fa>
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, 
f010267c:	83 ec 08             	sub    $0x8,%esp
f010267f:	6a 02                	push   $0x2
f0102681:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0102687:	50                   	push   %eax
f0102688:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010268d:	89 da                	mov    %ebx,%edx
f010268f:	a1 8c 7e 2a f0       	mov    0xf02a7e8c,%eax
f0102694:	e8 64 ef ff ff       	call   f01015fd <boot_map_region>
f0102699:	81 c7 00 80 00 00    	add    $0x8000,%edi
f010269f:	81 eb 00 00 01 00    	sub    $0x10000,%ebx
	for (size_t i = 0; i < NCPU; i++) { // `ncpu` is not set yet, we just use NCPU = 8.
f01026a5:	83 c4 10             	add    $0x10,%esp
f01026a8:	39 f7                	cmp    %esi,%edi
f01026aa:	75 c4                	jne    f0102670 <mem_init+0xe53>
f01026ac:	89 7d c4             	mov    %edi,-0x3c(%ebp)
	pgdir = kern_pgdir;
f01026af:	8b 3d 8c 7e 2a f0    	mov    0xf02a7e8c,%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01026b5:	a1 88 7e 2a f0       	mov    0xf02a7e88,%eax
f01026ba:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01026bd:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01026c4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01026c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01026cc:	a1 90 7e 2a f0       	mov    0xf02a7e90,%eax
f01026d1:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01026d4:	89 45 d0             	mov    %eax,-0x30(%ebp)
	return (physaddr_t)kva - KERNBASE;
f01026d7:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
	for (i = 0; i < n; i += PGSIZE) 
f01026dd:	bb 00 00 00 00       	mov    $0x0,%ebx
f01026e2:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01026e5:	0f 86 71 07 00 00    	jbe    f0102e5c <mem_init+0x163f>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01026eb:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01026f1:	89 f8                	mov    %edi,%eax
f01026f3:	e8 f0 e8 ff ff       	call   f0100fe8 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01026f8:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01026ff:	0f 86 27 07 00 00    	jbe    f0102e2c <mem_init+0x160f>
f0102705:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f0102708:	39 d0                	cmp    %edx,%eax
f010270a:	0f 85 33 07 00 00    	jne    f0102e43 <mem_init+0x1626>
	for (i = 0; i < n; i += PGSIZE) 
f0102710:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102716:	eb ca                	jmp    f01026e2 <mem_init+0xec5>
	assert(nfree == 0);
f0102718:	68 99 81 10 f0       	push   $0xf0108199
f010271d:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102722:	68 1e 03 00 00       	push   $0x31e
f0102727:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010272c:	e8 63 d9 ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0102731:	68 a7 80 10 f0       	push   $0xf01080a7
f0102736:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010273b:	68 84 03 00 00       	push   $0x384
f0102740:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102745:	e8 4a d9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f010274a:	68 bd 80 10 f0       	push   $0xf01080bd
f010274f:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102754:	68 85 03 00 00       	push   $0x385
f0102759:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010275e:	e8 31 d9 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0102763:	68 d3 80 10 f0       	push   $0xf01080d3
f0102768:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010276d:	68 86 03 00 00       	push   $0x386
f0102772:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102777:	e8 18 d9 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f010277c:	68 e9 80 10 f0       	push   $0xf01080e9
f0102781:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102786:	68 89 03 00 00       	push   $0x389
f010278b:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102790:	e8 ff d8 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102795:	68 a0 77 10 f0       	push   $0xf01077a0
f010279a:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010279f:	68 8a 03 00 00       	push   $0x38a
f01027a4:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01027a9:	e8 e6 d8 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01027ae:	68 52 81 10 f0       	push   $0xf0108152
f01027b3:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01027b8:	68 91 03 00 00       	push   $0x391
f01027bd:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01027c2:	e8 cd d8 ff ff       	call   f0100094 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01027c7:	68 e0 77 10 f0       	push   $0xf01077e0
f01027cc:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01027d1:	68 94 03 00 00       	push   $0x394
f01027d6:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01027db:	e8 b4 d8 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01027e0:	68 18 78 10 f0       	push   $0xf0107818
f01027e5:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01027ea:	68 97 03 00 00       	push   $0x397
f01027ef:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01027f4:	e8 9b d8 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01027f9:	68 48 78 10 f0       	push   $0xf0107848
f01027fe:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102803:	68 9b 03 00 00       	push   $0x39b
f0102808:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010280d:	e8 82 d8 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102812:	68 78 78 10 f0       	push   $0xf0107878
f0102817:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010281c:	68 9c 03 00 00       	push   $0x39c
f0102821:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102826:	e8 69 d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010282b:	68 a0 78 10 f0       	push   $0xf01078a0
f0102830:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102835:	68 9d 03 00 00       	push   $0x39d
f010283a:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010283f:	e8 50 d8 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102844:	68 a4 81 10 f0       	push   $0xf01081a4
f0102849:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010284e:	68 9e 03 00 00       	push   $0x39e
f0102853:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102858:	e8 37 d8 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f010285d:	68 b5 81 10 f0       	push   $0xf01081b5
f0102862:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102867:	68 9f 03 00 00       	push   $0x39f
f010286c:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102871:	e8 1e d8 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102876:	68 d0 78 10 f0       	push   $0xf01078d0
f010287b:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102880:	68 a2 03 00 00       	push   $0x3a2
f0102885:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010288a:	e8 05 d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010288f:	68 0c 79 10 f0       	push   $0xf010790c
f0102894:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102899:	68 a3 03 00 00       	push   $0x3a3
f010289e:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01028a3:	e8 ec d7 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f01028a8:	68 c6 81 10 f0       	push   $0xf01081c6
f01028ad:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01028b2:	68 a4 03 00 00       	push   $0x3a4
f01028b7:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01028bc:	e8 d3 d7 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01028c1:	68 52 81 10 f0       	push   $0xf0108152
f01028c6:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01028cb:	68 a7 03 00 00       	push   $0x3a7
f01028d0:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01028d5:	e8 ba d7 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01028da:	68 d0 78 10 f0       	push   $0xf01078d0
f01028df:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01028e4:	68 aa 03 00 00       	push   $0x3aa
f01028e9:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01028ee:	e8 a1 d7 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01028f3:	68 0c 79 10 f0       	push   $0xf010790c
f01028f8:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01028fd:	68 ab 03 00 00       	push   $0x3ab
f0102902:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102907:	e8 88 d7 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f010290c:	68 c6 81 10 f0       	push   $0xf01081c6
f0102911:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102916:	68 ac 03 00 00       	push   $0x3ac
f010291b:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102920:	e8 6f d7 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0102925:	68 52 81 10 f0       	push   $0xf0108152
f010292a:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010292f:	68 b0 03 00 00       	push   $0x3b0
f0102934:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102939:	e8 56 d7 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010293e:	50                   	push   %eax
f010293f:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0102944:	68 b3 03 00 00       	push   $0x3b3
f0102949:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010294e:	e8 41 d7 ff ff       	call   f0100094 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102953:	68 3c 79 10 f0       	push   $0xf010793c
f0102958:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010295d:	68 b4 03 00 00       	push   $0x3b4
f0102962:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102967:	e8 28 d7 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010296c:	68 7c 79 10 f0       	push   $0xf010797c
f0102971:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102976:	68 b7 03 00 00       	push   $0x3b7
f010297b:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102980:	e8 0f d7 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102985:	68 0c 79 10 f0       	push   $0xf010790c
f010298a:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010298f:	68 b8 03 00 00       	push   $0x3b8
f0102994:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102999:	e8 f6 d6 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f010299e:	68 c6 81 10 f0       	push   $0xf01081c6
f01029a3:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01029a8:	68 b9 03 00 00       	push   $0x3b9
f01029ad:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01029b2:	e8 dd d6 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01029b7:	68 bc 79 10 f0       	push   $0xf01079bc
f01029bc:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01029c1:	68 ba 03 00 00       	push   $0x3ba
f01029c6:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01029cb:	e8 c4 d6 ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01029d0:	68 d7 81 10 f0       	push   $0xf01081d7
f01029d5:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01029da:	68 bb 03 00 00       	push   $0x3bb
f01029df:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01029e4:	e8 ab d6 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01029e9:	68 d0 78 10 f0       	push   $0xf01078d0
f01029ee:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01029f3:	68 be 03 00 00       	push   $0x3be
f01029f8:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01029fd:	e8 92 d6 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102a02:	68 f0 79 10 f0       	push   $0xf01079f0
f0102a07:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102a0c:	68 bf 03 00 00       	push   $0x3bf
f0102a11:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102a16:	e8 79 d6 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102a1b:	68 24 7a 10 f0       	push   $0xf0107a24
f0102a20:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102a25:	68 c0 03 00 00       	push   $0x3c0
f0102a2a:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102a2f:	e8 60 d6 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102a34:	68 5c 7a 10 f0       	push   $0xf0107a5c
f0102a39:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102a3e:	68 c3 03 00 00       	push   $0x3c3
f0102a43:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102a48:	e8 47 d6 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102a4d:	68 94 7a 10 f0       	push   $0xf0107a94
f0102a52:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102a57:	68 c6 03 00 00       	push   $0x3c6
f0102a5c:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102a61:	e8 2e d6 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102a66:	68 24 7a 10 f0       	push   $0xf0107a24
f0102a6b:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102a70:	68 c7 03 00 00       	push   $0x3c7
f0102a75:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102a7a:	e8 15 d6 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102a7f:	68 d0 7a 10 f0       	push   $0xf0107ad0
f0102a84:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102a89:	68 ca 03 00 00       	push   $0x3ca
f0102a8e:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102a93:	e8 fc d5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102a98:	68 fc 7a 10 f0       	push   $0xf0107afc
f0102a9d:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102aa2:	68 cb 03 00 00       	push   $0x3cb
f0102aa7:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102aac:	e8 e3 d5 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 2);
f0102ab1:	68 ed 81 10 f0       	push   $0xf01081ed
f0102ab6:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102abb:	68 cd 03 00 00       	push   $0x3cd
f0102ac0:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102ac5:	e8 ca d5 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102aca:	68 fe 81 10 f0       	push   $0xf01081fe
f0102acf:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102ad4:	68 ce 03 00 00       	push   $0x3ce
f0102ad9:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102ade:	e8 b1 d5 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102ae3:	68 2c 7b 10 f0       	push   $0xf0107b2c
f0102ae8:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102aed:	68 d1 03 00 00       	push   $0x3d1
f0102af2:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102af7:	e8 98 d5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102afc:	68 50 7b 10 f0       	push   $0xf0107b50
f0102b01:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102b06:	68 d5 03 00 00       	push   $0x3d5
f0102b0b:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102b10:	e8 7f d5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102b15:	68 fc 7a 10 f0       	push   $0xf0107afc
f0102b1a:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102b1f:	68 d6 03 00 00       	push   $0x3d6
f0102b24:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102b29:	e8 66 d5 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102b2e:	68 a4 81 10 f0       	push   $0xf01081a4
f0102b33:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102b38:	68 d7 03 00 00       	push   $0x3d7
f0102b3d:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102b42:	e8 4d d5 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102b47:	68 fe 81 10 f0       	push   $0xf01081fe
f0102b4c:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102b51:	68 d8 03 00 00       	push   $0x3d8
f0102b56:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102b5b:	e8 34 d5 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102b60:	68 74 7b 10 f0       	push   $0xf0107b74
f0102b65:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102b6a:	68 db 03 00 00       	push   $0x3db
f0102b6f:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102b74:	e8 1b d5 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f0102b79:	68 0f 82 10 f0       	push   $0xf010820f
f0102b7e:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102b83:	68 dc 03 00 00       	push   $0x3dc
f0102b88:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102b8d:	e8 02 d5 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f0102b92:	68 1b 82 10 f0       	push   $0xf010821b
f0102b97:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102b9c:	68 dd 03 00 00       	push   $0x3dd
f0102ba1:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102ba6:	e8 e9 d4 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102bab:	68 50 7b 10 f0       	push   $0xf0107b50
f0102bb0:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102bb5:	68 e1 03 00 00       	push   $0x3e1
f0102bba:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102bbf:	e8 d0 d4 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102bc4:	68 ac 7b 10 f0       	push   $0xf0107bac
f0102bc9:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102bce:	68 e2 03 00 00       	push   $0x3e2
f0102bd3:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102bd8:	e8 b7 d4 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102bdd:	68 30 82 10 f0       	push   $0xf0108230
f0102be2:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102be7:	68 e3 03 00 00       	push   $0x3e3
f0102bec:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102bf1:	e8 9e d4 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102bf6:	68 fe 81 10 f0       	push   $0xf01081fe
f0102bfb:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102c00:	68 e4 03 00 00       	push   $0x3e4
f0102c05:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102c0a:	e8 85 d4 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102c0f:	68 d4 7b 10 f0       	push   $0xf0107bd4
f0102c14:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102c19:	68 e7 03 00 00       	push   $0x3e7
f0102c1e:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102c23:	e8 6c d4 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0102c28:	68 52 81 10 f0       	push   $0xf0108152
f0102c2d:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102c32:	68 ea 03 00 00       	push   $0x3ea
f0102c37:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102c3c:	e8 53 d4 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c41:	68 78 78 10 f0       	push   $0xf0107878
f0102c46:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102c4b:	68 ed 03 00 00       	push   $0x3ed
f0102c50:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102c55:	e8 3a d4 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0102c5a:	68 b5 81 10 f0       	push   $0xf01081b5
f0102c5f:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102c64:	68 ef 03 00 00       	push   $0x3ef
f0102c69:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102c6e:	e8 21 d4 ff ff       	call   f0100094 <_panic>
f0102c73:	52                   	push   %edx
f0102c74:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0102c79:	68 f6 03 00 00       	push   $0x3f6
f0102c7e:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102c83:	e8 0c d4 ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102c88:	68 41 82 10 f0       	push   $0xf0108241
f0102c8d:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102c92:	68 f7 03 00 00       	push   $0x3f7
f0102c97:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102c9c:	e8 f3 d3 ff ff       	call   f0100094 <_panic>
f0102ca1:	50                   	push   %eax
f0102ca2:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0102ca7:	6a 58                	push   $0x58
f0102ca9:	68 89 7f 10 f0       	push   $0xf0107f89
f0102cae:	e8 e1 d3 ff ff       	call   f0100094 <_panic>
f0102cb3:	52                   	push   %edx
f0102cb4:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0102cb9:	6a 58                	push   $0x58
f0102cbb:	68 89 7f 10 f0       	push   $0xf0107f89
f0102cc0:	e8 cf d3 ff ff       	call   f0100094 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102cc5:	68 59 82 10 f0       	push   $0xf0108259
f0102cca:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102ccf:	68 01 04 00 00       	push   $0x401
f0102cd4:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102cd9:	e8 b6 d3 ff ff       	call   f0100094 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102cde:	68 f8 7b 10 f0       	push   $0xf0107bf8
f0102ce3:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102ce8:	68 11 04 00 00       	push   $0x411
f0102ced:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102cf2:	e8 9d d3 ff ff       	call   f0100094 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102cf7:	68 20 7c 10 f0       	push   $0xf0107c20
f0102cfc:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102d01:	68 12 04 00 00       	push   $0x412
f0102d06:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102d0b:	e8 84 d3 ff ff       	call   f0100094 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102d10:	68 48 7c 10 f0       	push   $0xf0107c48
f0102d15:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102d1a:	68 14 04 00 00       	push   $0x414
f0102d1f:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102d24:	e8 6b d3 ff ff       	call   f0100094 <_panic>
	assert(mm1 + 8096 <= mm2);
f0102d29:	68 70 82 10 f0       	push   $0xf0108270
f0102d2e:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102d33:	68 16 04 00 00       	push   $0x416
f0102d38:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102d3d:	e8 52 d3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102d42:	68 70 7c 10 f0       	push   $0xf0107c70
f0102d47:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102d4c:	68 18 04 00 00       	push   $0x418
f0102d51:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102d56:	e8 39 d3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102d5b:	68 94 7c 10 f0       	push   $0xf0107c94
f0102d60:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102d65:	68 19 04 00 00       	push   $0x419
f0102d6a:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102d6f:	e8 20 d3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102d74:	68 c4 7c 10 f0       	push   $0xf0107cc4
f0102d79:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102d7e:	68 1a 04 00 00       	push   $0x41a
f0102d83:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102d88:	e8 07 d3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102d8d:	68 e8 7c 10 f0       	push   $0xf0107ce8
f0102d92:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102d97:	68 1b 04 00 00       	push   $0x41b
f0102d9c:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102da1:	e8 ee d2 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102da6:	68 14 7d 10 f0       	push   $0xf0107d14
f0102dab:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102db0:	68 1d 04 00 00       	push   $0x41d
f0102db5:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102dba:	e8 d5 d2 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102dbf:	68 58 7d 10 f0       	push   $0xf0107d58
f0102dc4:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102dc9:	68 1e 04 00 00       	push   $0x41e
f0102dce:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102dd3:	e8 bc d2 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dd8:	50                   	push   %eax
f0102dd9:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0102dde:	68 bd 00 00 00       	push   $0xbd
f0102de3:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102de8:	e8 a7 d2 ff ff       	call   f0100094 <_panic>
f0102ded:	50                   	push   %eax
f0102dee:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0102df3:	68 c7 00 00 00       	push   $0xc7
f0102df8:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102dfd:	e8 92 d2 ff ff       	call   f0100094 <_panic>
f0102e02:	50                   	push   %eax
f0102e03:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0102e08:	68 d4 00 00 00       	push   $0xd4
f0102e0d:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102e12:	e8 7d d2 ff ff       	call   f0100094 <_panic>
f0102e17:	57                   	push   %edi
f0102e18:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0102e1d:	68 14 01 00 00       	push   $0x114
f0102e22:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102e27:	e8 68 d2 ff ff       	call   f0100094 <_panic>
f0102e2c:	ff 75 c0             	pushl  -0x40(%ebp)
f0102e2f:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0102e34:	68 36 03 00 00       	push   $0x336
f0102e39:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102e3e:	e8 51 d2 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e43:	68 8c 7d 10 f0       	push   $0xf0107d8c
f0102e48:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102e4d:	68 36 03 00 00       	push   $0x336
f0102e52:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102e57:	e8 38 d2 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102e5c:	a1 48 72 2a f0       	mov    0xf02a7248,%eax
f0102e61:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((uint32_t)kva < KERNBASE)
f0102e64:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102e67:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102e6c:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f0102e72:	89 da                	mov    %ebx,%edx
f0102e74:	89 f8                	mov    %edi,%eax
f0102e76:	e8 6d e1 ff ff       	call   f0100fe8 <check_va2pa>
f0102e7b:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102e82:	76 22                	jbe    f0102ea6 <mem_init+0x1689>
f0102e84:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102e87:	39 d0                	cmp    %edx,%eax
f0102e89:	75 32                	jne    f0102ebd <mem_init+0x16a0>
f0102e8b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f0102e91:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102e97:	75 d9                	jne    f0102e72 <mem_init+0x1655>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e99:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102e9c:	c1 e6 0c             	shl    $0xc,%esi
f0102e9f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102ea4:	eb 4b                	jmp    f0102ef1 <mem_init+0x16d4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ea6:	ff 75 d0             	pushl  -0x30(%ebp)
f0102ea9:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0102eae:	68 3b 03 00 00       	push   $0x33b
f0102eb3:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102eb8:	e8 d7 d1 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102ebd:	68 c0 7d 10 f0       	push   $0xf0107dc0
f0102ec2:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102ec7:	68 3b 03 00 00       	push   $0x33b
f0102ecc:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102ed1:	e8 be d1 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102ed6:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102edc:	89 f8                	mov    %edi,%eax
f0102ede:	e8 05 e1 ff ff       	call   f0100fe8 <check_va2pa>
f0102ee3:	39 c3                	cmp    %eax,%ebx
f0102ee5:	0f 85 f5 00 00 00    	jne    f0102fe0 <mem_init+0x17c3>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102eeb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ef1:	39 f3                	cmp    %esi,%ebx
f0102ef3:	72 e1                	jb     f0102ed6 <mem_init+0x16b9>
f0102ef5:	c7 45 d4 00 90 2a f0 	movl   $0xf02a9000,-0x2c(%ebp)
f0102efc:	c7 45 cc 00 80 ff ef 	movl   $0xefff8000,-0x34(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102f03:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f06:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0102f09:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0102f0c:	8d 83 00 80 00 00    	lea    0x8000(%ebx),%eax
f0102f12:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102f15:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102f18:	8d b0 00 80 00 20    	lea    0x20008000(%eax),%esi
f0102f1e:	89 da                	mov    %ebx,%edx
f0102f20:	89 f8                	mov    %edi,%eax
f0102f22:	e8 c1 e0 ff ff       	call   f0100fe8 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102f27:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102f2e:	0f 86 c5 00 00 00    	jbe    f0102ff9 <mem_init+0x17dc>
f0102f34:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102f37:	39 d0                	cmp    %edx,%eax
f0102f39:	0f 85 d1 00 00 00    	jne    f0103010 <mem_init+0x17f3>
f0102f3f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102f45:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102f48:	75 d4                	jne    f0102f1e <mem_init+0x1701>
f0102f4a:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102f4d:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102f53:	89 da                	mov    %ebx,%edx
f0102f55:	89 f8                	mov    %edi,%eax
f0102f57:	e8 8c e0 ff ff       	call   f0100fe8 <check_va2pa>
f0102f5c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102f5f:	0f 85 c4 00 00 00    	jne    f0103029 <mem_init+0x180c>
f0102f65:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102f6b:	39 f3                	cmp    %esi,%ebx
f0102f6d:	75 e4                	jne    f0102f53 <mem_init+0x1736>
f0102f6f:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102f76:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102f7d:	81 45 d4 00 80 00 00 	addl   $0x8000,-0x2c(%ebp)
f0102f84:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	for (n = 0; n < NCPU; n++) {
f0102f87:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
f0102f8a:	0f 85 73 ff ff ff    	jne    f0102f03 <mem_init+0x16e6>
	for (i = 0; i < NPDENTRIES; i++) {
f0102f90:	b8 00 00 00 00       	mov    $0x0,%eax
			if (i >= PDX(KERNBASE)) {
f0102f95:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102f9a:	0f 87 a2 00 00 00    	ja     f0103042 <mem_init+0x1825>
				assert(pgdir[i] == 0);
f0102fa0:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102fa4:	0f 85 db 00 00 00    	jne    f0103085 <mem_init+0x1868>
	for (i = 0; i < NPDENTRIES; i++) {
f0102faa:	40                   	inc    %eax
f0102fab:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102fb0:	0f 87 e8 00 00 00    	ja     f010309e <mem_init+0x1881>
		switch (i) {
f0102fb6:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102fbc:	83 fa 04             	cmp    $0x4,%edx
f0102fbf:	77 d4                	ja     f0102f95 <mem_init+0x1778>
			assert(pgdir[i] & PTE_P);
f0102fc1:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102fc5:	75 e3                	jne    f0102faa <mem_init+0x178d>
f0102fc7:	68 9b 82 10 f0       	push   $0xf010829b
f0102fcc:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102fd1:	68 54 03 00 00       	push   $0x354
f0102fd6:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102fdb:	e8 b4 d0 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102fe0:	68 f4 7d 10 f0       	push   $0xf0107df4
f0102fe5:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0102fea:	68 3f 03 00 00       	push   $0x33f
f0102fef:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0102ff4:	e8 9b d0 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ff9:	ff 75 c0             	pushl  -0x40(%ebp)
f0102ffc:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0103001:	68 47 03 00 00       	push   $0x347
f0103006:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010300b:	e8 84 d0 ff ff       	call   f0100094 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103010:	68 1c 7e 10 f0       	push   $0xf0107e1c
f0103015:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010301a:	68 47 03 00 00       	push   $0x347
f010301f:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0103024:	e8 6b d0 ff ff       	call   f0100094 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0103029:	68 64 7e 10 f0       	push   $0xf0107e64
f010302e:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0103033:	68 49 03 00 00       	push   $0x349
f0103038:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010303d:	e8 52 d0 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_P);
f0103042:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103045:	f6 c2 01             	test   $0x1,%dl
f0103048:	74 22                	je     f010306c <mem_init+0x184f>
				assert(pgdir[i] & PTE_W);
f010304a:	f6 c2 02             	test   $0x2,%dl
f010304d:	0f 85 57 ff ff ff    	jne    f0102faa <mem_init+0x178d>
f0103053:	68 ac 82 10 f0       	push   $0xf01082ac
f0103058:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010305d:	68 59 03 00 00       	push   $0x359
f0103062:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0103067:	e8 28 d0 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_P);
f010306c:	68 9b 82 10 f0       	push   $0xf010829b
f0103071:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0103076:	68 58 03 00 00       	push   $0x358
f010307b:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0103080:	e8 0f d0 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] == 0);
f0103085:	68 bd 82 10 f0       	push   $0xf01082bd
f010308a:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010308f:	68 5b 03 00 00       	push   $0x35b
f0103094:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0103099:	e8 f6 cf ff ff       	call   f0100094 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f010309e:	83 ec 0c             	sub    $0xc,%esp
f01030a1:	68 88 7e 10 f0       	push   $0xf0107e88
f01030a6:	e8 d9 0e 00 00       	call   f0103f84 <cprintf>
	lcr3(PADDR(kern_pgdir));
f01030ab:	a1 8c 7e 2a f0       	mov    0xf02a7e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01030b0:	83 c4 10             	add    $0x10,%esp
f01030b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030b8:	0f 86 fe 01 00 00    	jbe    f01032bc <mem_init+0x1a9f>
	return (physaddr_t)kva - KERNBASE;
f01030be:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01030c3:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f01030c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01030cb:	e8 77 df ff ff       	call   f0101047 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01030d0:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01030d3:	83 e0 f3             	and    $0xfffffff3,%eax
f01030d6:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01030db:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01030de:	83 ec 0c             	sub    $0xc,%esp
f01030e1:	6a 00                	push   $0x0
f01030e3:	e8 14 e3 ff ff       	call   f01013fc <page_alloc>
f01030e8:	89 c3                	mov    %eax,%ebx
f01030ea:	83 c4 10             	add    $0x10,%esp
f01030ed:	85 c0                	test   %eax,%eax
f01030ef:	0f 84 dc 01 00 00    	je     f01032d1 <mem_init+0x1ab4>
	assert((pp1 = page_alloc(0)));
f01030f5:	83 ec 0c             	sub    $0xc,%esp
f01030f8:	6a 00                	push   $0x0
f01030fa:	e8 fd e2 ff ff       	call   f01013fc <page_alloc>
f01030ff:	89 c7                	mov    %eax,%edi
f0103101:	83 c4 10             	add    $0x10,%esp
f0103104:	85 c0                	test   %eax,%eax
f0103106:	0f 84 de 01 00 00    	je     f01032ea <mem_init+0x1acd>
	assert((pp2 = page_alloc(0)));
f010310c:	83 ec 0c             	sub    $0xc,%esp
f010310f:	6a 00                	push   $0x0
f0103111:	e8 e6 e2 ff ff       	call   f01013fc <page_alloc>
f0103116:	89 c6                	mov    %eax,%esi
f0103118:	83 c4 10             	add    $0x10,%esp
f010311b:	85 c0                	test   %eax,%eax
f010311d:	0f 84 e0 01 00 00    	je     f0103303 <mem_init+0x1ae6>
	page_free(pp0);
f0103123:	83 ec 0c             	sub    $0xc,%esp
f0103126:	53                   	push   %ebx
f0103127:	e8 42 e3 ff ff       	call   f010146e <page_free>
	return (pp - pages) << PGSHIFT;
f010312c:	89 f8                	mov    %edi,%eax
f010312e:	2b 05 90 7e 2a f0    	sub    0xf02a7e90,%eax
f0103134:	c1 f8 03             	sar    $0x3,%eax
f0103137:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010313a:	89 c2                	mov    %eax,%edx
f010313c:	c1 ea 0c             	shr    $0xc,%edx
f010313f:	83 c4 10             	add    $0x10,%esp
f0103142:	3b 15 88 7e 2a f0    	cmp    0xf02a7e88,%edx
f0103148:	0f 83 ce 01 00 00    	jae    f010331c <mem_init+0x1aff>
	memset(page2kva(pp1), 1, PGSIZE);
f010314e:	83 ec 04             	sub    $0x4,%esp
f0103151:	68 00 10 00 00       	push   $0x1000
f0103156:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0103158:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010315d:	50                   	push   %eax
f010315e:	e8 e6 2e 00 00       	call   f0106049 <memset>
	return (pp - pages) << PGSHIFT;
f0103163:	89 f0                	mov    %esi,%eax
f0103165:	2b 05 90 7e 2a f0    	sub    0xf02a7e90,%eax
f010316b:	c1 f8 03             	sar    $0x3,%eax
f010316e:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0103171:	89 c2                	mov    %eax,%edx
f0103173:	c1 ea 0c             	shr    $0xc,%edx
f0103176:	83 c4 10             	add    $0x10,%esp
f0103179:	3b 15 88 7e 2a f0    	cmp    0xf02a7e88,%edx
f010317f:	0f 83 a9 01 00 00    	jae    f010332e <mem_init+0x1b11>
	memset(page2kva(pp2), 2, PGSIZE);
f0103185:	83 ec 04             	sub    $0x4,%esp
f0103188:	68 00 10 00 00       	push   $0x1000
f010318d:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f010318f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103194:	50                   	push   %eax
f0103195:	e8 af 2e 00 00       	call   f0106049 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010319a:	6a 02                	push   $0x2
f010319c:	68 00 10 00 00       	push   $0x1000
f01031a1:	57                   	push   %edi
f01031a2:	ff 35 8c 7e 2a f0    	pushl  0xf02a7e8c
f01031a8:	e8 a8 e5 ff ff       	call   f0101755 <page_insert>
	assert(pp1->pp_ref == 1);
f01031ad:	83 c4 20             	add    $0x20,%esp
f01031b0:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01031b5:	0f 85 85 01 00 00    	jne    f0103340 <mem_init+0x1b23>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01031bb:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01031c2:	01 01 01 
f01031c5:	0f 85 8e 01 00 00    	jne    f0103359 <mem_init+0x1b3c>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01031cb:	6a 02                	push   $0x2
f01031cd:	68 00 10 00 00       	push   $0x1000
f01031d2:	56                   	push   %esi
f01031d3:	ff 35 8c 7e 2a f0    	pushl  0xf02a7e8c
f01031d9:	e8 77 e5 ff ff       	call   f0101755 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01031de:	83 c4 10             	add    $0x10,%esp
f01031e1:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01031e8:	02 02 02 
f01031eb:	0f 85 81 01 00 00    	jne    f0103372 <mem_init+0x1b55>
	assert(pp2->pp_ref == 1);
f01031f1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01031f6:	0f 85 8f 01 00 00    	jne    f010338b <mem_init+0x1b6e>
	assert(pp1->pp_ref == 0);
f01031fc:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103201:	0f 85 9d 01 00 00    	jne    f01033a4 <mem_init+0x1b87>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103207:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010320e:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0103211:	89 f0                	mov    %esi,%eax
f0103213:	2b 05 90 7e 2a f0    	sub    0xf02a7e90,%eax
f0103219:	c1 f8 03             	sar    $0x3,%eax
f010321c:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010321f:	89 c2                	mov    %eax,%edx
f0103221:	c1 ea 0c             	shr    $0xc,%edx
f0103224:	3b 15 88 7e 2a f0    	cmp    0xf02a7e88,%edx
f010322a:	0f 83 8d 01 00 00    	jae    f01033bd <mem_init+0x1ba0>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103230:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103237:	03 03 03 
f010323a:	0f 85 8f 01 00 00    	jne    f01033cf <mem_init+0x1bb2>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103240:	83 ec 08             	sub    $0x8,%esp
f0103243:	68 00 10 00 00       	push   $0x1000
f0103248:	ff 35 8c 7e 2a f0    	pushl  0xf02a7e8c
f010324e:	e8 a8 e4 ff ff       	call   f01016fb <page_remove>
	assert(pp2->pp_ref == 0);
f0103253:	83 c4 10             	add    $0x10,%esp
f0103256:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010325b:	0f 85 87 01 00 00    	jne    f01033e8 <mem_init+0x1bcb>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103261:	8b 0d 8c 7e 2a f0    	mov    0xf02a7e8c,%ecx
f0103267:	8b 11                	mov    (%ecx),%edx
f0103269:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f010326f:	89 d8                	mov    %ebx,%eax
f0103271:	2b 05 90 7e 2a f0    	sub    0xf02a7e90,%eax
f0103277:	c1 f8 03             	sar    $0x3,%eax
f010327a:	c1 e0 0c             	shl    $0xc,%eax
f010327d:	39 c2                	cmp    %eax,%edx
f010327f:	0f 85 7c 01 00 00    	jne    f0103401 <mem_init+0x1be4>
	kern_pgdir[0] = 0;
f0103285:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010328b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103290:	0f 85 84 01 00 00    	jne    f010341a <mem_init+0x1bfd>
	pp0->pp_ref = 0;
f0103296:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f010329c:	83 ec 0c             	sub    $0xc,%esp
f010329f:	53                   	push   %ebx
f01032a0:	e8 c9 e1 ff ff       	call   f010146e <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01032a5:	c7 04 24 1c 7f 10 f0 	movl   $0xf0107f1c,(%esp)
f01032ac:	e8 d3 0c 00 00       	call   f0103f84 <cprintf>
}
f01032b1:	83 c4 10             	add    $0x10,%esp
f01032b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01032b7:	5b                   	pop    %ebx
f01032b8:	5e                   	pop    %esi
f01032b9:	5f                   	pop    %edi
f01032ba:	5d                   	pop    %ebp
f01032bb:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032bc:	50                   	push   %eax
f01032bd:	68 cc 6e 10 f0       	push   $0xf0106ecc
f01032c2:	68 ed 00 00 00       	push   $0xed
f01032c7:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01032cc:	e8 c3 cd ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f01032d1:	68 a7 80 10 f0       	push   $0xf01080a7
f01032d6:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01032db:	68 33 04 00 00       	push   $0x433
f01032e0:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01032e5:	e8 aa cd ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01032ea:	68 bd 80 10 f0       	push   $0xf01080bd
f01032ef:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01032f4:	68 34 04 00 00       	push   $0x434
f01032f9:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01032fe:	e8 91 cd ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0103303:	68 d3 80 10 f0       	push   $0xf01080d3
f0103308:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010330d:	68 35 04 00 00       	push   $0x435
f0103312:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0103317:	e8 78 cd ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010331c:	50                   	push   %eax
f010331d:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0103322:	6a 58                	push   $0x58
f0103324:	68 89 7f 10 f0       	push   $0xf0107f89
f0103329:	e8 66 cd ff ff       	call   f0100094 <_panic>
f010332e:	50                   	push   %eax
f010332f:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0103334:	6a 58                	push   $0x58
f0103336:	68 89 7f 10 f0       	push   $0xf0107f89
f010333b:	e8 54 cd ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0103340:	68 a4 81 10 f0       	push   $0xf01081a4
f0103345:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010334a:	68 3a 04 00 00       	push   $0x43a
f010334f:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0103354:	e8 3b cd ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103359:	68 a8 7e 10 f0       	push   $0xf0107ea8
f010335e:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0103363:	68 3b 04 00 00       	push   $0x43b
f0103368:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010336d:	e8 22 cd ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103372:	68 cc 7e 10 f0       	push   $0xf0107ecc
f0103377:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010337c:	68 3d 04 00 00       	push   $0x43d
f0103381:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0103386:	e8 09 cd ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f010338b:	68 c6 81 10 f0       	push   $0xf01081c6
f0103390:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0103395:	68 3e 04 00 00       	push   $0x43e
f010339a:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010339f:	e8 f0 cc ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f01033a4:	68 30 82 10 f0       	push   $0xf0108230
f01033a9:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01033ae:	68 3f 04 00 00       	push   $0x43f
f01033b3:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01033b8:	e8 d7 cc ff ff       	call   f0100094 <_panic>
f01033bd:	50                   	push   %eax
f01033be:	68 a8 6e 10 f0       	push   $0xf0106ea8
f01033c3:	6a 58                	push   $0x58
f01033c5:	68 89 7f 10 f0       	push   $0xf0107f89
f01033ca:	e8 c5 cc ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01033cf:	68 f0 7e 10 f0       	push   $0xf0107ef0
f01033d4:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01033d9:	68 41 04 00 00       	push   $0x441
f01033de:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01033e3:	e8 ac cc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01033e8:	68 fe 81 10 f0       	push   $0xf01081fe
f01033ed:	68 a3 7f 10 f0       	push   $0xf0107fa3
f01033f2:	68 43 04 00 00       	push   $0x443
f01033f7:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01033fc:	e8 93 cc ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103401:	68 78 78 10 f0       	push   $0xf0107878
f0103406:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010340b:	68 46 04 00 00       	push   $0x446
f0103410:	68 7d 7f 10 f0       	push   $0xf0107f7d
f0103415:	e8 7a cc ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f010341a:	68 b5 81 10 f0       	push   $0xf01081b5
f010341f:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0103424:	68 48 04 00 00       	push   $0x448
f0103429:	68 7d 7f 10 f0       	push   $0xf0107f7d
f010342e:	e8 61 cc ff ff       	call   f0100094 <_panic>

f0103433 <user_mem_check>:
{
f0103433:	55                   	push   %ebp
f0103434:	89 e5                	mov    %esp,%ebp
f0103436:	57                   	push   %edi
f0103437:	56                   	push   %esi
f0103438:	53                   	push   %ebx
f0103439:	83 ec 1c             	sub    $0x1c,%esp
f010343c:	8b 7d 08             	mov    0x8(%ebp),%edi
	void *l = ROUNDDOWN((void*)va, PGSIZE), *r = ROUNDUP((void*)va + len, PGSIZE);
f010343f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103442:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103445:	89 c3                	mov    %eax,%ebx
f0103447:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010344d:	89 c6                	mov    %eax,%esi
f010344f:	03 75 10             	add    0x10(%ebp),%esi
f0103452:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
f0103458:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for (; l < r; l += PGSIZE) {
f010345e:	39 f3                	cmp    %esi,%ebx
f0103460:	0f 83 83 00 00 00    	jae    f01034e9 <user_mem_check+0xb6>
		if ((uintptr_t)l >= ULIM) {// Higher than ULIM
f0103466:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103469:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010346f:	77 2d                	ja     f010349e <user_mem_check+0x6b>
		pte_t* pte = pgdir_walk(env->env_pgdir, l, 0);
f0103471:	83 ec 04             	sub    $0x4,%esp
f0103474:	6a 00                	push   $0x0
f0103476:	53                   	push   %ebx
f0103477:	ff 77 60             	pushl  0x60(%edi)
f010347a:	e8 67 e0 ff ff       	call   f01014e6 <pgdir_walk>
		if (!pte) {
f010347f:	83 c4 10             	add    $0x10,%esp
f0103482:	85 c0                	test   %eax,%eax
f0103484:	74 2f                	je     f01034b5 <user_mem_check+0x82>
		uint32_t given_perm = *pte & 0xFFF;
f0103486:	8b 00                	mov    (%eax),%eax
f0103488:	25 ff 0f 00 00       	and    $0xfff,%eax
		if ((given_perm | perm) > given_perm) {
f010348d:	89 c2                	mov    %eax,%edx
f010348f:	0b 55 14             	or     0x14(%ebp),%edx
f0103492:	39 c2                	cmp    %eax,%edx
f0103494:	77 39                	ja     f01034cf <user_mem_check+0x9c>
	for (; l < r; l += PGSIZE) {
f0103496:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010349c:	eb c0                	jmp    f010345e <user_mem_check+0x2b>
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f010349e:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f01034a1:	72 03                	jb     f01034a6 <user_mem_check+0x73>
		if ((uintptr_t)l >= ULIM) {// Higher than ULIM
f01034a3:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f01034a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034a9:	a3 3c 72 2a f0       	mov    %eax,0xf02a723c
			return -E_FAULT;
f01034ae:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034b3:	eb 39                	jmp    f01034ee <user_mem_check+0xbb>
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f01034b5:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f01034b8:	72 06                	jb     f01034c0 <user_mem_check+0x8d>
		if ((uintptr_t)l >= ULIM) {// Higher than ULIM
f01034ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01034bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f01034c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034c3:	a3 3c 72 2a f0       	mov    %eax,0xf02a723c
			return -E_FAULT;
f01034c8:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034cd:	eb 1f                	jmp    f01034ee <user_mem_check+0xbb>
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f01034cf:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f01034d2:	72 06                	jb     f01034da <user_mem_check+0xa7>
		if ((uintptr_t)l >= ULIM) {// Higher than ULIM
f01034d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01034d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f01034da:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034dd:	a3 3c 72 2a f0       	mov    %eax,0xf02a723c
			return -E_FAULT;
f01034e2:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034e7:	eb 05                	jmp    f01034ee <user_mem_check+0xbb>
	return 0;
f01034e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01034ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034f1:	5b                   	pop    %ebx
f01034f2:	5e                   	pop    %esi
f01034f3:	5f                   	pop    %edi
f01034f4:	5d                   	pop    %ebp
f01034f5:	c3                   	ret    

f01034f6 <user_mem_assert>:
{
f01034f6:	55                   	push   %ebp
f01034f7:	89 e5                	mov    %esp,%ebp
f01034f9:	53                   	push   %ebx
f01034fa:	83 ec 04             	sub    $0x4,%esp
f01034fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103500:	8b 45 14             	mov    0x14(%ebp),%eax
f0103503:	83 c8 04             	or     $0x4,%eax
f0103506:	50                   	push   %eax
f0103507:	ff 75 10             	pushl  0x10(%ebp)
f010350a:	ff 75 0c             	pushl  0xc(%ebp)
f010350d:	53                   	push   %ebx
f010350e:	e8 20 ff ff ff       	call   f0103433 <user_mem_check>
f0103513:	83 c4 10             	add    $0x10,%esp
f0103516:	85 c0                	test   %eax,%eax
f0103518:	78 05                	js     f010351f <user_mem_assert+0x29>
}
f010351a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010351d:	c9                   	leave  
f010351e:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f010351f:	83 ec 04             	sub    $0x4,%esp
f0103522:	ff 35 3c 72 2a f0    	pushl  0xf02a723c
f0103528:	ff 73 48             	pushl  0x48(%ebx)
f010352b:	68 48 7f 10 f0       	push   $0xf0107f48
f0103530:	e8 4f 0a 00 00       	call   f0103f84 <cprintf>
		env_destroy(env);	// may not return
f0103535:	89 1c 24             	mov    %ebx,(%esp)
f0103538:	e8 0b 07 00 00       	call   f0103c48 <env_destroy>
f010353d:	83 c4 10             	add    $0x10,%esp
}
f0103540:	eb d8                	jmp    f010351a <user_mem_assert+0x24>

f0103542 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103542:	55                   	push   %ebp
f0103543:	89 e5                	mov    %esp,%ebp
f0103545:	56                   	push   %esi
f0103546:	53                   	push   %ebx
f0103547:	8b 45 08             	mov    0x8(%ebp),%eax
f010354a:	8b 75 10             	mov    0x10(%ebp),%esi
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010354d:	85 c0                	test   %eax,%eax
f010354f:	74 37                	je     f0103588 <envid2env+0x46>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103551:	89 c1                	mov    %eax,%ecx
f0103553:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f0103559:	89 ca                	mov    %ecx,%edx
f010355b:	c1 e2 05             	shl    $0x5,%edx
f010355e:	29 ca                	sub    %ecx,%edx
f0103560:	8b 0d 48 72 2a f0    	mov    0xf02a7248,%ecx
f0103566:	8d 1c 91             	lea    (%ecx,%edx,4),%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103569:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f010356d:	74 3d                	je     f01035ac <envid2env+0x6a>
f010356f:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103572:	75 38                	jne    f01035ac <envid2env+0x6a>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103574:	89 f0                	mov    %esi,%eax
f0103576:	84 c0                	test   %al,%al
f0103578:	75 42                	jne    f01035bc <envid2env+0x7a>
		*env_store = 0;
		return -E_BAD_ENV;
	}

	*env_store = e;
f010357a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010357d:	89 18                	mov    %ebx,(%eax)
	return 0;
f010357f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103584:	5b                   	pop    %ebx
f0103585:	5e                   	pop    %esi
f0103586:	5d                   	pop    %ebp
f0103587:	c3                   	ret    
		*env_store = curenv;
f0103588:	e8 95 31 00 00       	call   f0106722 <cpunum>
f010358d:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103590:	01 c2                	add    %eax,%edx
f0103592:	01 d2                	add    %edx,%edx
f0103594:	01 c2                	add    %eax,%edx
f0103596:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103599:	8b 04 85 28 80 2a f0 	mov    -0xfd57fd8(,%eax,4),%eax
f01035a0:	8b 75 0c             	mov    0xc(%ebp),%esi
f01035a3:	89 06                	mov    %eax,(%esi)
		return 0;
f01035a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01035aa:	eb d8                	jmp    f0103584 <envid2env+0x42>
		*env_store = 0;
f01035ac:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035af:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01035b5:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01035ba:	eb c8                	jmp    f0103584 <envid2env+0x42>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01035bc:	e8 61 31 00 00       	call   f0106722 <cpunum>
f01035c1:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01035c4:	01 c2                	add    %eax,%edx
f01035c6:	01 d2                	add    %edx,%edx
f01035c8:	01 c2                	add    %eax,%edx
f01035ca:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01035cd:	39 1c 85 28 80 2a f0 	cmp    %ebx,-0xfd57fd8(,%eax,4)
f01035d4:	74 a4                	je     f010357a <envid2env+0x38>
f01035d6:	8b 73 4c             	mov    0x4c(%ebx),%esi
f01035d9:	e8 44 31 00 00       	call   f0106722 <cpunum>
f01035de:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01035e1:	01 c2                	add    %eax,%edx
f01035e3:	01 d2                	add    %edx,%edx
f01035e5:	01 c2                	add    %eax,%edx
f01035e7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01035ea:	8b 04 85 28 80 2a f0 	mov    -0xfd57fd8(,%eax,4),%eax
f01035f1:	3b 70 48             	cmp    0x48(%eax),%esi
f01035f4:	74 84                	je     f010357a <envid2env+0x38>
		*env_store = 0;
f01035f6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035f9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01035ff:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103604:	e9 7b ff ff ff       	jmp    f0103584 <envid2env+0x42>

f0103609 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103609:	55                   	push   %ebp
f010360a:	89 e5                	mov    %esp,%ebp
	asm volatile("lgdt (%0)" : : "r" (p));
f010360c:	b8 20 33 12 f0       	mov    $0xf0123320,%eax
f0103611:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103614:	b8 23 00 00 00       	mov    $0x23,%eax
f0103619:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f010361b:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f010361d:	b8 10 00 00 00       	mov    $0x10,%eax
f0103622:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103624:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103626:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103628:	ea 2f 36 10 f0 08 00 	ljmp   $0x8,$0xf010362f
	asm volatile("lldt %0" : : "r" (sel));
f010362f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103634:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103637:	5d                   	pop    %ebp
f0103638:	c3                   	ret    

f0103639 <env_init>:
{
f0103639:	55                   	push   %ebp
f010363a:	89 e5                	mov    %esp,%ebp
f010363c:	56                   	push   %esi
f010363d:	53                   	push   %ebx
		envs[i].env_link = env_free_list;
f010363e:	8b 35 48 72 2a f0    	mov    0xf02a7248,%esi
f0103644:	8b 15 4c 72 2a f0    	mov    0xf02a724c,%edx
f010364a:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103650:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0103653:	89 c1                	mov    %eax,%ecx
f0103655:	89 50 44             	mov    %edx,0x44(%eax)
f0103658:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[i];
f010365b:	89 ca                	mov    %ecx,%edx
	for (int i = NENV - 1; i >= 0; i--) { // Be sure not to use size_t
f010365d:	39 d8                	cmp    %ebx,%eax
f010365f:	75 f2                	jne    f0103653 <env_init+0x1a>
f0103661:	89 35 4c 72 2a f0    	mov    %esi,0xf02a724c
	env_init_percpu();
f0103667:	e8 9d ff ff ff       	call   f0103609 <env_init_percpu>
}
f010366c:	5b                   	pop    %ebx
f010366d:	5e                   	pop    %esi
f010366e:	5d                   	pop    %ebp
f010366f:	c3                   	ret    

f0103670 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103670:	55                   	push   %ebp
f0103671:	89 e5                	mov    %esp,%ebp
f0103673:	56                   	push   %esi
f0103674:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;
	if (!(e = env_free_list))
f0103675:	8b 1d 4c 72 2a f0    	mov    0xf02a724c,%ebx
f010367b:	85 db                	test   %ebx,%ebx
f010367d:	0f 84 fa 01 00 00    	je     f010387d <env_alloc+0x20d>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103683:	83 ec 0c             	sub    $0xc,%esp
f0103686:	6a 01                	push   $0x1
f0103688:	e8 6f dd ff ff       	call   f01013fc <page_alloc>
f010368d:	89 c6                	mov    %eax,%esi
f010368f:	83 c4 10             	add    $0x10,%esp
f0103692:	85 c0                	test   %eax,%eax
f0103694:	0f 84 ea 01 00 00    	je     f0103884 <env_alloc+0x214>
	return (pp - pages) << PGSHIFT;
f010369a:	2b 05 90 7e 2a f0    	sub    0xf02a7e90,%eax
f01036a0:	c1 f8 03             	sar    $0x3,%eax
f01036a3:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01036a6:	89 c2                	mov    %eax,%edx
f01036a8:	c1 ea 0c             	shr    $0xc,%edx
f01036ab:	3b 15 88 7e 2a f0    	cmp    0xf02a7e88,%edx
f01036b1:	0f 83 7c 01 00 00    	jae    f0103833 <env_alloc+0x1c3>
	memset(page2kva(p), 0, PGSIZE);
f01036b7:	83 ec 04             	sub    $0x4,%esp
f01036ba:	68 00 10 00 00       	push   $0x1000
f01036bf:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01036c1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01036c6:	50                   	push   %eax
f01036c7:	e8 7d 29 00 00       	call   f0106049 <memset>
	p->pp_ref++;
f01036cc:	66 ff 46 04          	incw   0x4(%esi)
	return (pp - pages) << PGSHIFT;
f01036d0:	2b 35 90 7e 2a f0    	sub    0xf02a7e90,%esi
f01036d6:	c1 fe 03             	sar    $0x3,%esi
f01036d9:	c1 e6 0c             	shl    $0xc,%esi
	if (PGNUM(pa) >= npages)
f01036dc:	89 f0                	mov    %esi,%eax
f01036de:	c1 e8 0c             	shr    $0xc,%eax
f01036e1:	83 c4 10             	add    $0x10,%esp
f01036e4:	3b 05 88 7e 2a f0    	cmp    0xf02a7e88,%eax
f01036ea:	0f 83 55 01 00 00    	jae    f0103845 <env_alloc+0x1d5>
	return (void *)(pa + KERNBASE);
f01036f0:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f01036f6:	89 73 60             	mov    %esi,0x60(%ebx)
	e->env_pgdir = page2kva(p);
f01036f9:	b8 ec 0e 00 00       	mov    $0xeec,%eax
		e->env_pgdir[pgt] = kern_pgdir[pgt];
f01036fe:	8b 15 8c 7e 2a f0    	mov    0xf02a7e8c,%edx
f0103704:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0103707:	8b 53 60             	mov    0x60(%ebx),%edx
f010370a:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f010370d:	83 c0 04             	add    $0x4,%eax
	for (size_t pgt = PDX(UTOP); pgt < PGSIZE / sizeof(pde_t); pgt++)
f0103710:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103715:	75 e7                	jne    f01036fe <env_alloc+0x8e>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103717:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f010371a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010371f:	0f 86 32 01 00 00    	jbe    f0103857 <env_alloc+0x1e7>
	return (physaddr_t)kva - KERNBASE;
f0103725:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010372b:	83 ca 05             	or     $0x5,%edx
f010372e:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103734:	8b 43 48             	mov    0x48(%ebx),%eax
f0103737:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010373c:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103741:	89 c2                	mov    %eax,%edx
f0103743:	0f 8e 23 01 00 00    	jle    f010386c <env_alloc+0x1fc>
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f0103749:	89 d8                	mov    %ebx,%eax
f010374b:	2b 05 48 72 2a f0    	sub    0xf02a7248,%eax
f0103751:	c1 f8 02             	sar    $0x2,%eax
f0103754:	89 c1                	mov    %eax,%ecx
f0103756:	c1 e0 05             	shl    $0x5,%eax
f0103759:	01 c8                	add    %ecx,%eax
f010375b:	c1 e0 05             	shl    $0x5,%eax
f010375e:	01 c8                	add    %ecx,%eax
f0103760:	89 c6                	mov    %eax,%esi
f0103762:	c1 e6 0f             	shl    $0xf,%esi
f0103765:	01 f0                	add    %esi,%eax
f0103767:	c1 e0 05             	shl    $0x5,%eax
f010376a:	01 c8                	add    %ecx,%eax
f010376c:	f7 d8                	neg    %eax
f010376e:	09 d0                	or     %edx,%eax
f0103770:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103773:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103776:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103779:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103780:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103787:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010378e:	83 ec 04             	sub    $0x4,%esp
f0103791:	6a 44                	push   $0x44
f0103793:	6a 00                	push   $0x0
f0103795:	53                   	push   %ebx
f0103796:	e8 ae 28 00 00       	call   f0106049 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f010379b:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01037a1:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01037a7:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01037ad:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01037b4:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	e->env_tf.tf_eflags = FL_IF;  // This is the only flag till now.
f01037ba:	c7 43 38 00 02 00 00 	movl   $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01037c1:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01037c8:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01037cc:	8b 43 44             	mov    0x44(%ebx),%eax
f01037cf:	a3 4c 72 2a f0       	mov    %eax,0xf02a724c
	*newenv_store = e;
f01037d4:	8b 45 08             	mov    0x8(%ebp),%eax
f01037d7:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01037d9:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01037dc:	e8 41 2f 00 00       	call   f0106722 <cpunum>
f01037e1:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01037e4:	01 c2                	add    %eax,%edx
f01037e6:	01 d2                	add    %edx,%edx
f01037e8:	01 c2                	add    %eax,%edx
f01037ea:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01037ed:	83 c4 10             	add    $0x10,%esp
f01037f0:	83 3c 85 28 80 2a f0 	cmpl   $0x0,-0xfd57fd8(,%eax,4)
f01037f7:	00 
f01037f8:	74 7c                	je     f0103876 <env_alloc+0x206>
f01037fa:	e8 23 2f 00 00       	call   f0106722 <cpunum>
f01037ff:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103802:	01 c2                	add    %eax,%edx
f0103804:	01 d2                	add    %edx,%edx
f0103806:	01 c2                	add    %eax,%edx
f0103808:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010380b:	8b 04 85 28 80 2a f0 	mov    -0xfd57fd8(,%eax,4),%eax
f0103812:	8b 40 48             	mov    0x48(%eax),%eax
f0103815:	83 ec 04             	sub    $0x4,%esp
f0103818:	53                   	push   %ebx
f0103819:	50                   	push   %eax
f010381a:	68 fa 82 10 f0       	push   $0xf01082fa
f010381f:	e8 60 07 00 00       	call   f0103f84 <cprintf>
	return 0;
f0103824:	83 c4 10             	add    $0x10,%esp
f0103827:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010382c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010382f:	5b                   	pop    %ebx
f0103830:	5e                   	pop    %esi
f0103831:	5d                   	pop    %ebp
f0103832:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103833:	50                   	push   %eax
f0103834:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0103839:	6a 58                	push   $0x58
f010383b:	68 89 7f 10 f0       	push   $0xf0107f89
f0103840:	e8 4f c8 ff ff       	call   f0100094 <_panic>
f0103845:	56                   	push   %esi
f0103846:	68 a8 6e 10 f0       	push   $0xf0106ea8
f010384b:	6a 58                	push   $0x58
f010384d:	68 89 7f 10 f0       	push   $0xf0107f89
f0103852:	e8 3d c8 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103857:	50                   	push   %eax
f0103858:	68 cc 6e 10 f0       	push   $0xf0106ecc
f010385d:	68 c7 00 00 00       	push   $0xc7
f0103862:	68 ef 82 10 f0       	push   $0xf01082ef
f0103867:	e8 28 c8 ff ff       	call   f0100094 <_panic>
		generation = 1 << ENVGENSHIFT;
f010386c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103871:	e9 d3 fe ff ff       	jmp    f0103749 <env_alloc+0xd9>
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103876:	b8 00 00 00 00       	mov    $0x0,%eax
f010387b:	eb 98                	jmp    f0103815 <env_alloc+0x1a5>
		return -E_NO_FREE_ENV;
f010387d:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103882:	eb a8                	jmp    f010382c <env_alloc+0x1bc>
		return -E_NO_MEM;
f0103884:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103889:	eb a1                	jmp    f010382c <env_alloc+0x1bc>

f010388b <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010388b:	55                   	push   %ebp
f010388c:	89 e5                	mov    %esp,%ebp
f010388e:	57                   	push   %edi
f010388f:	56                   	push   %esi
f0103890:	53                   	push   %ebx
f0103891:	83 ec 34             	sub    $0x34,%esp
	// LAB 3: Your code here.
	struct Env* newenv;
	int r = env_alloc(&newenv, 0);
f0103894:	6a 00                	push   $0x0
f0103896:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103899:	50                   	push   %eax
f010389a:	e8 d1 fd ff ff       	call   f0103670 <env_alloc>
	if (r)
f010389f:	83 c4 10             	add    $0x10,%esp
f01038a2:	85 c0                	test   %eax,%eax
f01038a4:	75 47                	jne    f01038ed <env_create+0x62>
		panic("Environment allocation faulted: %e", r);
	load_icode(newenv, binary);
f01038a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	if (elf->e_magic != ELF_MAGIC)
f01038a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01038ac:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f01038b2:	75 4e                	jne    f0103902 <env_create+0x77>
	struct Proghdr *ph = (struct Proghdr *) (binary + elf->e_phoff), 
f01038b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01038b7:	89 c6                	mov    %eax,%esi
f01038b9:	03 70 1c             	add    0x1c(%eax),%esi
				   *eph = ph + elf->e_phnum;
f01038bc:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
f01038c0:	c1 e0 05             	shl    $0x5,%eax
f01038c3:	01 f0                	add    %esi,%eax
f01038c5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	pte_t pgdir_pte = *pgdir_walk(kern_pgdir, e->env_pgdir, 0);
f01038c8:	83 ec 04             	sub    $0x4,%esp
f01038cb:	6a 00                	push   $0x0
f01038cd:	ff 77 60             	pushl  0x60(%edi)
f01038d0:	ff 35 8c 7e 2a f0    	pushl  0xf02a7e8c
f01038d6:	e8 0b dc ff ff       	call   f01014e6 <pgdir_walk>
	physaddr_t pgdir_phy = PTE_ADDR(pgdir_pte);
f01038db:	8b 00                	mov    (%eax),%eax
f01038dd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01038e2:	0f 22 d8             	mov    %eax,%cr3
f01038e5:	83 c4 10             	add    $0x10,%esp
f01038e8:	e9 8f 00 00 00       	jmp    f010397c <env_create+0xf1>
		panic("Environment allocation faulted: %e", r);
f01038ed:	50                   	push   %eax
f01038ee:	68 cc 82 10 f0       	push   $0xf01082cc
f01038f3:	68 a0 01 00 00       	push   $0x1a0
f01038f8:	68 ef 82 10 f0       	push   $0xf01082ef
f01038fd:	e8 92 c7 ff ff       	call   f0100094 <_panic>
		panic("Not a valid elf binary!");
f0103902:	83 ec 04             	sub    $0x4,%esp
f0103905:	68 0f 83 10 f0       	push   $0xf010830f
f010390a:	68 64 01 00 00       	push   $0x164
f010390f:	68 ef 82 10 f0       	push   $0xf01082ef
f0103914:	e8 7b c7 ff ff       	call   f0100094 <_panic>
			panic("No free page for allocation.");
f0103919:	83 ec 04             	sub    $0x4,%esp
f010391c:	68 27 83 10 f0       	push   $0xf0108327
f0103921:	68 22 01 00 00       	push   $0x122
f0103926:	68 ef 82 10 f0       	push   $0xf01082ef
f010392b:	e8 64 c7 ff ff       	call   f0100094 <_panic>
			panic("Page insertion result: %e", r);
f0103930:	ff 75 cc             	pushl  -0x34(%ebp)
f0103933:	68 44 83 10 f0       	push   $0xf0108344
f0103938:	68 25 01 00 00       	push   $0x125
f010393d:	68 ef 82 10 f0       	push   $0xf01082ef
f0103942:	e8 4d c7 ff ff       	call   f0100094 <_panic>
f0103947:	8b 75 d0             	mov    -0x30(%ebp),%esi
			memmove((void*)ph0->p_va, binary + ph0->p_offset, ph0->p_filesz);
f010394a:	83 ec 04             	sub    $0x4,%esp
f010394d:	ff 76 10             	pushl  0x10(%esi)
f0103950:	8b 45 08             	mov    0x8(%ebp),%eax
f0103953:	03 46 04             	add    0x4(%esi),%eax
f0103956:	50                   	push   %eax
f0103957:	ff 76 08             	pushl  0x8(%esi)
f010395a:	e8 37 27 00 00       	call   f0106096 <memmove>
					ph0->p_memsz - ph0->p_filesz);
f010395f:	8b 46 10             	mov    0x10(%esi),%eax
			memset((void*)ph0->p_va + ph0->p_filesz, 0, 
f0103962:	83 c4 0c             	add    $0xc,%esp
f0103965:	8b 56 14             	mov    0x14(%esi),%edx
f0103968:	29 c2                	sub    %eax,%edx
f010396a:	52                   	push   %edx
f010396b:	6a 00                	push   $0x0
f010396d:	03 46 08             	add    0x8(%esi),%eax
f0103970:	50                   	push   %eax
f0103971:	e8 d3 26 00 00       	call   f0106049 <memset>
f0103976:	83 c4 10             	add    $0x10,%esp
	for (struct Proghdr* ph0 = ph; ph0 < eph; ph0++) {
f0103979:	83 c6 20             	add    $0x20,%esi
f010397c:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f010397f:	76 5d                	jbe    f01039de <env_create+0x153>
		if (ph0->p_type == ELF_PROG_LOAD) {
f0103981:	83 3e 01             	cmpl   $0x1,(%esi)
f0103984:	75 f3                	jne    f0103979 <env_create+0xee>
			region_alloc(e, (void*)ph0->p_va, ph0->p_memsz);
f0103986:	8b 46 08             	mov    0x8(%esi),%eax
	uintptr_t l = ROUNDDOWN((uintptr_t)va, PGSIZE), 
f0103989:	89 c3                	mov    %eax,%ebx
f010398b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
			  r = ROUNDUP((uintptr_t)(va + len), PGSIZE);
f0103991:	03 46 14             	add    0x14(%esi),%eax
f0103994:	05 ff 0f 00 00       	add    $0xfff,%eax
f0103999:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010399e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01039a1:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01039a4:	89 c6                	mov    %eax,%esi
	for (uintptr_t ptr = l; ptr < r; ptr += PGSIZE) {
f01039a6:	39 de                	cmp    %ebx,%esi
f01039a8:	76 9d                	jbe    f0103947 <env_create+0xbc>
		struct PageInfo *pg = page_alloc(0);
f01039aa:	83 ec 0c             	sub    $0xc,%esp
f01039ad:	6a 00                	push   $0x0
f01039af:	e8 48 da ff ff       	call   f01013fc <page_alloc>
		if (!pg)
f01039b4:	83 c4 10             	add    $0x10,%esp
f01039b7:	85 c0                	test   %eax,%eax
f01039b9:	0f 84 5a ff ff ff    	je     f0103919 <env_create+0x8e>
		int res = page_insert(e->env_pgdir, pg, (void*)ptr, PTE_U | PTE_W);
f01039bf:	6a 06                	push   $0x6
f01039c1:	53                   	push   %ebx
f01039c2:	50                   	push   %eax
f01039c3:	ff 77 60             	pushl  0x60(%edi)
f01039c6:	e8 8a dd ff ff       	call   f0101755 <page_insert>
		if (res)
f01039cb:	83 c4 10             	add    $0x10,%esp
f01039ce:	85 c0                	test   %eax,%eax
f01039d0:	0f 85 5a ff ff ff    	jne    f0103930 <env_create+0xa5>
	for (uintptr_t ptr = l; ptr < r; ptr += PGSIZE) {
f01039d6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01039dc:	eb c8                	jmp    f01039a6 <env_create+0x11b>
	e->env_tf.tf_eip = elf->e_entry;
f01039de:	8b 45 08             	mov    0x8(%ebp),%eax
f01039e1:	8b 40 18             	mov    0x18(%eax),%eax
f01039e4:	89 47 30             	mov    %eax,0x30(%edi)
	lcr3(PADDR(kern_pgdir));
f01039e7:	a1 8c 7e 2a f0       	mov    0xf02a7e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01039ec:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039f1:	76 46                	jbe    f0103a39 <env_create+0x1ae>
	return (physaddr_t)kva - KERNBASE;
f01039f3:	05 00 00 00 10       	add    $0x10000000,%eax
f01039f8:	0f 22 d8             	mov    %eax,%cr3
	struct PageInfo *stack_page = page_alloc(ALLOC_ZERO);
f01039fb:	83 ec 0c             	sub    $0xc,%esp
f01039fe:	6a 01                	push   $0x1
f0103a00:	e8 f7 d9 ff ff       	call   f01013fc <page_alloc>
	if (!stack_page)
f0103a05:	83 c4 10             	add    $0x10,%esp
f0103a08:	85 c0                	test   %eax,%eax
f0103a0a:	74 42                	je     f0103a4e <env_create+0x1c3>
	int r = page_insert(e->env_pgdir, stack_page, (void*)USTACKTOP - PGSIZE, PTE_U | PTE_W);
f0103a0c:	6a 06                	push   $0x6
f0103a0e:	68 00 d0 bf ee       	push   $0xeebfd000
f0103a13:	50                   	push   %eax
f0103a14:	ff 77 60             	pushl  0x60(%edi)
f0103a17:	e8 39 dd ff ff       	call   f0101755 <page_insert>
	if (r)
f0103a1c:	83 c4 10             	add    $0x10,%esp
f0103a1f:	85 c0                	test   %eax,%eax
f0103a21:	75 42                	jne    f0103a65 <env_create+0x1da>

	// Write environment type.
	newenv->env_type = type;
f0103a23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103a26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103a29:	89 48 50             	mov    %ecx,0x50(%eax)
	
	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	if (type == ENV_TYPE_FS) {
f0103a2c:	83 f9 01             	cmp    $0x1,%ecx
f0103a2f:	74 49                	je     f0103a7a <env_create+0x1ef>
		newenv->env_tf.tf_eflags |= FL_IOPL_3;
	}
}
f0103a31:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103a34:	5b                   	pop    %ebx
f0103a35:	5e                   	pop    %esi
f0103a36:	5f                   	pop    %edi
f0103a37:	5d                   	pop    %ebp
f0103a38:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a39:	50                   	push   %eax
f0103a3a:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0103a3f:	68 84 01 00 00       	push   $0x184
f0103a44:	68 ef 82 10 f0       	push   $0xf01082ef
f0103a49:	e8 46 c6 ff ff       	call   f0100094 <_panic>
		panic("No free page for allocation.");
f0103a4e:	83 ec 04             	sub    $0x4,%esp
f0103a51:	68 27 83 10 f0       	push   $0xf0108327
f0103a56:	68 8c 01 00 00       	push   $0x18c
f0103a5b:	68 ef 82 10 f0       	push   $0xf01082ef
f0103a60:	e8 2f c6 ff ff       	call   f0100094 <_panic>
		panic("Page insertion result: %e", r);
f0103a65:	50                   	push   %eax
f0103a66:	68 44 83 10 f0       	push   $0xf0108344
f0103a6b:	68 8f 01 00 00       	push   $0x18f
f0103a70:	68 ef 82 10 f0       	push   $0xf01082ef
f0103a75:	e8 1a c6 ff ff       	call   f0100094 <_panic>
		newenv->env_tf.tf_eflags |= FL_IOPL_3;
f0103a7a:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
}
f0103a81:	eb ae                	jmp    f0103a31 <env_create+0x1a6>

f0103a83 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103a83:	55                   	push   %ebp
f0103a84:	89 e5                	mov    %esp,%ebp
f0103a86:	57                   	push   %edi
f0103a87:	56                   	push   %esi
f0103a88:	53                   	push   %ebx
f0103a89:	83 ec 1c             	sub    $0x1c,%esp
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103a8c:	e8 91 2c 00 00       	call   f0106722 <cpunum>
f0103a91:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103a94:	01 c2                	add    %eax,%edx
f0103a96:	01 d2                	add    %edx,%edx
f0103a98:	01 c2                	add    %eax,%edx
f0103a9a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a9d:	8b 55 08             	mov    0x8(%ebp),%edx
f0103aa0:	39 14 85 28 80 2a f0 	cmp    %edx,-0xfd57fd8(,%eax,4)
f0103aa7:	75 38                	jne    f0103ae1 <env_free+0x5e>
		lcr3(PADDR(kern_pgdir));
f0103aa9:	a1 8c 7e 2a f0       	mov    0xf02a7e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103aae:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ab3:	76 17                	jbe    f0103acc <env_free+0x49>
	return (physaddr_t)kva - KERNBASE;
f0103ab5:	05 00 00 00 10       	add    $0x10000000,%eax
f0103aba:	0f 22 d8             	mov    %eax,%cr3
f0103abd:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0103ac4:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103ac7:	e9 9b 00 00 00       	jmp    f0103b67 <env_free+0xe4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103acc:	50                   	push   %eax
f0103acd:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0103ad2:	68 ba 01 00 00       	push   $0x1ba
f0103ad7:	68 ef 82 10 f0       	push   $0xf01082ef
f0103adc:	e8 b3 c5 ff ff       	call   f0100094 <_panic>
f0103ae1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0103ae8:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103aeb:	eb 7a                	jmp    f0103b67 <env_free+0xe4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103aed:	50                   	push   %eax
f0103aee:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0103af3:	68 c9 01 00 00       	push   $0x1c9
f0103af8:	68 ef 82 10 f0       	push   $0xf01082ef
f0103afd:	e8 92 c5 ff ff       	call   f0100094 <_panic>
f0103b02:	83 c3 04             	add    $0x4,%ebx
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103b05:	39 de                	cmp    %ebx,%esi
f0103b07:	74 21                	je     f0103b2a <env_free+0xa7>
			if (pt[pteno] & PTE_P)
f0103b09:	f6 03 01             	testb  $0x1,(%ebx)
f0103b0c:	74 f4                	je     f0103b02 <env_free+0x7f>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b0e:	83 ec 08             	sub    $0x8,%esp
f0103b11:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b14:	01 d8                	add    %ebx,%eax
f0103b16:	c1 e0 0a             	shl    $0xa,%eax
f0103b19:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103b1c:	50                   	push   %eax
f0103b1d:	ff 77 60             	pushl  0x60(%edi)
f0103b20:	e8 d6 db ff ff       	call   f01016fb <page_remove>
f0103b25:	83 c4 10             	add    $0x10,%esp
f0103b28:	eb d8                	jmp    f0103b02 <env_free+0x7f>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103b2a:	8b 47 60             	mov    0x60(%edi),%eax
f0103b2d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b30:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103b37:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103b3a:	3b 05 88 7e 2a f0    	cmp    0xf02a7e88,%eax
f0103b40:	73 6a                	jae    f0103bac <env_free+0x129>
		page_decref(pa2page(pa));
f0103b42:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103b45:	a1 90 7e 2a f0       	mov    0xf02a7e90,%eax
f0103b4a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103b4d:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103b50:	50                   	push   %eax
f0103b51:	e8 6a d9 ff ff       	call   f01014c0 <page_decref>
f0103b56:	83 c4 10             	add    $0x10,%esp
f0103b59:	83 45 dc 04          	addl   $0x4,-0x24(%ebp)
f0103b5d:	8b 45 dc             	mov    -0x24(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103b60:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103b65:	74 59                	je     f0103bc0 <env_free+0x13d>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103b67:	8b 47 60             	mov    0x60(%edi),%eax
f0103b6a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b6d:	8b 04 10             	mov    (%eax,%edx,1),%eax
f0103b70:	a8 01                	test   $0x1,%al
f0103b72:	74 e5                	je     f0103b59 <env_free+0xd6>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103b74:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0103b79:	89 c2                	mov    %eax,%edx
f0103b7b:	c1 ea 0c             	shr    $0xc,%edx
f0103b7e:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0103b81:	39 15 88 7e 2a f0    	cmp    %edx,0xf02a7e88
f0103b87:	0f 86 60 ff ff ff    	jbe    f0103aed <env_free+0x6a>
	return (void *)(pa + KERNBASE);
f0103b8d:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b93:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b96:	c1 e2 14             	shl    $0x14,%edx
f0103b99:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103b9c:	8d b0 00 10 00 f0    	lea    -0xffff000(%eax),%esi
f0103ba2:	f7 d8                	neg    %eax
f0103ba4:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103ba7:	e9 5d ff ff ff       	jmp    f0103b09 <env_free+0x86>
		panic("pa2page called with invalid pa");
f0103bac:	83 ec 04             	sub    $0x4,%esp
f0103baf:	68 44 77 10 f0       	push   $0xf0107744
f0103bb4:	6a 51                	push   $0x51
f0103bb6:	68 89 7f 10 f0       	push   $0xf0107f89
f0103bbb:	e8 d4 c4 ff ff       	call   f0100094 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103bc0:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bc3:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103bc6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103bcb:	76 52                	jbe    f0103c1f <env_free+0x19c>
	e->env_pgdir = 0;
f0103bcd:	8b 55 08             	mov    0x8(%ebp),%edx
f0103bd0:	c7 42 60 00 00 00 00 	movl   $0x0,0x60(%edx)
	return (physaddr_t)kva - KERNBASE;
f0103bd7:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103bdc:	c1 e8 0c             	shr    $0xc,%eax
f0103bdf:	3b 05 88 7e 2a f0    	cmp    0xf02a7e88,%eax
f0103be5:	73 4d                	jae    f0103c34 <env_free+0x1b1>
	page_decref(pa2page(pa));
f0103be7:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103bea:	8b 15 90 7e 2a f0    	mov    0xf02a7e90,%edx
f0103bf0:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103bf3:	50                   	push   %eax
f0103bf4:	e8 c7 d8 ff ff       	call   f01014c0 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103bf9:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bfc:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f0103c03:	a1 4c 72 2a f0       	mov    0xf02a724c,%eax
f0103c08:	8b 55 08             	mov    0x8(%ebp),%edx
f0103c0b:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f0103c0e:	89 15 4c 72 2a f0    	mov    %edx,0xf02a724c
}
f0103c14:	83 c4 10             	add    $0x10,%esp
f0103c17:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103c1a:	5b                   	pop    %ebx
f0103c1b:	5e                   	pop    %esi
f0103c1c:	5f                   	pop    %edi
f0103c1d:	5d                   	pop    %ebp
f0103c1e:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103c1f:	50                   	push   %eax
f0103c20:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0103c25:	68 d7 01 00 00       	push   $0x1d7
f0103c2a:	68 ef 82 10 f0       	push   $0xf01082ef
f0103c2f:	e8 60 c4 ff ff       	call   f0100094 <_panic>
		panic("pa2page called with invalid pa");
f0103c34:	83 ec 04             	sub    $0x4,%esp
f0103c37:	68 44 77 10 f0       	push   $0xf0107744
f0103c3c:	6a 51                	push   $0x51
f0103c3e:	68 89 7f 10 f0       	push   $0xf0107f89
f0103c43:	e8 4c c4 ff ff       	call   f0100094 <_panic>

f0103c48 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103c48:	55                   	push   %ebp
f0103c49:	89 e5                	mov    %esp,%ebp
f0103c4b:	53                   	push   %ebx
f0103c4c:	83 ec 04             	sub    $0x4,%esp
f0103c4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103c52:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103c56:	74 2b                	je     f0103c83 <env_destroy+0x3b>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f0103c58:	83 ec 0c             	sub    $0xc,%esp
f0103c5b:	53                   	push   %ebx
f0103c5c:	e8 22 fe ff ff       	call   f0103a83 <env_free>

	if (curenv == e) {
f0103c61:	e8 bc 2a 00 00       	call   f0106722 <cpunum>
f0103c66:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103c69:	01 c2                	add    %eax,%edx
f0103c6b:	01 d2                	add    %edx,%edx
f0103c6d:	01 c2                	add    %eax,%edx
f0103c6f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c72:	83 c4 10             	add    $0x10,%esp
f0103c75:	39 1c 85 28 80 2a f0 	cmp    %ebx,-0xfd57fd8(,%eax,4)
f0103c7c:	74 28                	je     f0103ca6 <env_destroy+0x5e>
		curenv = NULL;
		sched_yield();
	}
}
f0103c7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103c81:	c9                   	leave  
f0103c82:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103c83:	e8 9a 2a 00 00       	call   f0106722 <cpunum>
f0103c88:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103c8b:	01 c2                	add    %eax,%edx
f0103c8d:	01 d2                	add    %edx,%edx
f0103c8f:	01 c2                	add    %eax,%edx
f0103c91:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c94:	39 1c 85 28 80 2a f0 	cmp    %ebx,-0xfd57fd8(,%eax,4)
f0103c9b:	74 bb                	je     f0103c58 <env_destroy+0x10>
		e->env_status = ENV_DYING;
f0103c9d:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103ca4:	eb d8                	jmp    f0103c7e <env_destroy+0x36>
		curenv = NULL;
f0103ca6:	e8 77 2a 00 00       	call   f0106722 <cpunum>
f0103cab:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cae:	c7 80 28 80 2a f0 00 	movl   $0x0,-0xfd57fd8(%eax)
f0103cb5:	00 00 00 
		sched_yield();
f0103cb8:	e8 41 11 00 00       	call   f0104dfe <sched_yield>

f0103cbd <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103cbd:	55                   	push   %ebp
f0103cbe:	89 e5                	mov    %esp,%ebp
f0103cc0:	53                   	push   %ebx
f0103cc1:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103cc4:	e8 59 2a 00 00       	call   f0106722 <cpunum>
f0103cc9:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103ccc:	01 c2                	add    %eax,%edx
f0103cce:	01 d2                	add    %edx,%edx
f0103cd0:	01 c2                	add    %eax,%edx
f0103cd2:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103cd5:	8b 1c 85 28 80 2a f0 	mov    -0xfd57fd8(,%eax,4),%ebx
f0103cdc:	e8 41 2a 00 00       	call   f0106722 <cpunum>
f0103ce1:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0103ce4:	8b 65 08             	mov    0x8(%ebp),%esp
f0103ce7:	61                   	popa   
f0103ce8:	07                   	pop    %es
f0103ce9:	1f                   	pop    %ds
f0103cea:	83 c4 08             	add    $0x8,%esp
f0103ced:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103cee:	83 ec 04             	sub    $0x4,%esp
f0103cf1:	68 5e 83 10 f0       	push   $0xf010835e
f0103cf6:	68 0e 02 00 00       	push   $0x20e
f0103cfb:	68 ef 82 10 f0       	push   $0xf01082ef
f0103d00:	e8 8f c3 ff ff       	call   f0100094 <_panic>

f0103d05 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103d05:	55                   	push   %ebp
f0103d06:	89 e5                	mov    %esp,%ebp
f0103d08:	83 ec 08             	sub    $0x8,%esp
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// Unset curenv running before going to new env.
	if (curenv && curenv->env_status == ENV_RUNNING) {
f0103d0b:	e8 12 2a 00 00       	call   f0106722 <cpunum>
f0103d10:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103d13:	01 c2                	add    %eax,%edx
f0103d15:	01 d2                	add    %edx,%edx
f0103d17:	01 c2                	add    %eax,%edx
f0103d19:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d1c:	83 3c 85 28 80 2a f0 	cmpl   $0x0,-0xfd57fd8(,%eax,4)
f0103d23:	00 
f0103d24:	74 18                	je     f0103d3e <env_run+0x39>
f0103d26:	e8 f7 29 00 00       	call   f0106722 <cpunum>
f0103d2b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d2e:	8b 80 28 80 2a f0    	mov    -0xfd57fd8(%eax),%eax
f0103d34:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103d38:	0f 84 8c 00 00 00    	je     f0103dca <env_run+0xc5>
		curenv->env_status = ENV_RUNNABLE;
	}

	curenv = e;
f0103d3e:	e8 df 29 00 00       	call   f0106722 <cpunum>
f0103d43:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103d46:	01 c2                	add    %eax,%edx
f0103d48:	01 d2                	add    %edx,%edx
f0103d4a:	01 c2                	add    %eax,%edx
f0103d4c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d4f:	8b 55 08             	mov    0x8(%ebp),%edx
f0103d52:	89 14 85 28 80 2a f0 	mov    %edx,-0xfd57fd8(,%eax,4)
	curenv->env_status = ENV_RUNNING;
f0103d59:	e8 c4 29 00 00       	call   f0106722 <cpunum>
f0103d5e:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103d61:	01 c2                	add    %eax,%edx
f0103d63:	01 d2                	add    %edx,%edx
f0103d65:	01 c2                	add    %eax,%edx
f0103d67:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d6a:	8b 04 85 28 80 2a f0 	mov    -0xfd57fd8(,%eax,4),%eax
f0103d71:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++; // Incremetn run count
f0103d78:	e8 a5 29 00 00       	call   f0106722 <cpunum>
f0103d7d:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103d80:	01 c2                	add    %eax,%edx
f0103d82:	01 d2                	add    %edx,%edx
f0103d84:	01 c2                	add    %eax,%edx
f0103d86:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d89:	8b 04 85 28 80 2a f0 	mov    -0xfd57fd8(,%eax,4),%eax
f0103d90:	ff 40 58             	incl   0x58(%eax)

	// Jump to user env pgdir
	lcr3(PADDR(curenv->env_pgdir));
f0103d93:	e8 8a 29 00 00       	call   f0106722 <cpunum>
f0103d98:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103d9b:	01 c2                	add    %eax,%edx
f0103d9d:	01 d2                	add    %edx,%edx
f0103d9f:	01 c2                	add    %eax,%edx
f0103da1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103da4:	8b 04 85 28 80 2a f0 	mov    -0xfd57fd8(,%eax,4),%eax
f0103dab:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103dae:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103db3:	77 2f                	ja     f0103de4 <env_run+0xdf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103db5:	50                   	push   %eax
f0103db6:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0103dbb:	68 35 02 00 00       	push   $0x235
f0103dc0:	68 ef 82 10 f0       	push   $0xf01082ef
f0103dc5:	e8 ca c2 ff ff       	call   f0100094 <_panic>
		curenv->env_status = ENV_RUNNABLE;
f0103dca:	e8 53 29 00 00       	call   f0106722 <cpunum>
f0103dcf:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dd2:	8b 80 28 80 2a f0    	mov    -0xfd57fd8(%eax),%eax
f0103dd8:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0103ddf:	e9 5a ff ff ff       	jmp    f0103d3e <env_run+0x39>
	return (physaddr_t)kva - KERNBASE;
f0103de4:	05 00 00 00 10       	add    $0x10000000,%eax
f0103de9:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103dec:	83 ec 0c             	sub    $0xc,%esp
f0103def:	68 c0 33 12 f0       	push   $0xf01233c0
f0103df4:	e8 4a 2c 00 00       	call   f0106a43 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103df9:	f3 90                	pause  

	// Unlock the kernel if we're heading user mode.
	unlock_kernel();

	// Do the final work.
	env_pop_tf(&curenv->env_tf);  // Does not return.
f0103dfb:	e8 22 29 00 00       	call   f0106722 <cpunum>
f0103e00:	83 c4 04             	add    $0x4,%esp
f0103e03:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e06:	ff b0 28 80 2a f0    	pushl  -0xfd57fd8(%eax)
f0103e0c:	e8 ac fe ff ff       	call   f0103cbd <env_pop_tf>

f0103e11 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103e11:	55                   	push   %ebp
f0103e12:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e14:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e17:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e1c:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103e1d:	ba 71 00 00 00       	mov    $0x71,%edx
f0103e22:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103e23:	0f b6 c0             	movzbl %al,%eax
}
f0103e26:	5d                   	pop    %ebp
f0103e27:	c3                   	ret    

f0103e28 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103e28:	55                   	push   %ebp
f0103e29:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e2b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e2e:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e33:	ee                   	out    %al,(%dx)
f0103e34:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e37:	ba 71 00 00 00       	mov    $0x71,%edx
f0103e3c:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103e3d:	5d                   	pop    %ebp
f0103e3e:	c3                   	ret    

f0103e3f <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103e3f:	55                   	push   %ebp
f0103e40:	89 e5                	mov    %esp,%ebp
f0103e42:	56                   	push   %esi
f0103e43:	53                   	push   %ebx
f0103e44:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103e47:	66 a3 a8 33 12 f0    	mov    %ax,0xf01233a8
	if (!didinit)
f0103e4d:	80 3d 50 72 2a f0 00 	cmpb   $0x0,0xf02a7250
f0103e54:	75 07                	jne    f0103e5d <irq_setmask_8259A+0x1e>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f0103e56:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103e59:	5b                   	pop    %ebx
f0103e5a:	5e                   	pop    %esi
f0103e5b:	5d                   	pop    %ebp
f0103e5c:	c3                   	ret    
f0103e5d:	89 c6                	mov    %eax,%esi
f0103e5f:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e64:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103e65:	66 c1 e8 08          	shr    $0x8,%ax
f0103e69:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103e6e:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103e6f:	83 ec 0c             	sub    $0xc,%esp
f0103e72:	68 6a 83 10 f0       	push   $0xf010836a
f0103e77:	e8 08 01 00 00       	call   f0103f84 <cprintf>
f0103e7c:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103e7f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103e84:	0f b7 f6             	movzwl %si,%esi
f0103e87:	f7 d6                	not    %esi
f0103e89:	eb 06                	jmp    f0103e91 <irq_setmask_8259A+0x52>
	for (i = 0; i < 16; i++)
f0103e8b:	43                   	inc    %ebx
f0103e8c:	83 fb 10             	cmp    $0x10,%ebx
f0103e8f:	74 1d                	je     f0103eae <irq_setmask_8259A+0x6f>
		if (~mask & (1<<i))
f0103e91:	89 f0                	mov    %esi,%eax
f0103e93:	88 d9                	mov    %bl,%cl
f0103e95:	d3 f8                	sar    %cl,%eax
f0103e97:	a8 01                	test   $0x1,%al
f0103e99:	74 f0                	je     f0103e8b <irq_setmask_8259A+0x4c>
			cprintf(" %d", i);
f0103e9b:	83 ec 08             	sub    $0x8,%esp
f0103e9e:	53                   	push   %ebx
f0103e9f:	68 67 88 10 f0       	push   $0xf0108867
f0103ea4:	e8 db 00 00 00       	call   f0103f84 <cprintf>
f0103ea9:	83 c4 10             	add    $0x10,%esp
f0103eac:	eb dd                	jmp    f0103e8b <irq_setmask_8259A+0x4c>
	cprintf("\n");
f0103eae:	83 ec 0c             	sub    $0xc,%esp
f0103eb1:	68 fb 71 10 f0       	push   $0xf01071fb
f0103eb6:	e8 c9 00 00 00       	call   f0103f84 <cprintf>
f0103ebb:	83 c4 10             	add    $0x10,%esp
f0103ebe:	eb 96                	jmp    f0103e56 <irq_setmask_8259A+0x17>

f0103ec0 <pic_init>:
{
f0103ec0:	55                   	push   %ebp
f0103ec1:	89 e5                	mov    %esp,%ebp
f0103ec3:	57                   	push   %edi
f0103ec4:	56                   	push   %esi
f0103ec5:	53                   	push   %ebx
f0103ec6:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f0103ec9:	c6 05 50 72 2a f0 01 	movb   $0x1,0xf02a7250
f0103ed0:	b0 ff                	mov    $0xff,%al
f0103ed2:	bb 21 00 00 00       	mov    $0x21,%ebx
f0103ed7:	89 da                	mov    %ebx,%edx
f0103ed9:	ee                   	out    %al,(%dx)
f0103eda:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f0103edf:	89 ca                	mov    %ecx,%edx
f0103ee1:	ee                   	out    %al,(%dx)
f0103ee2:	bf 11 00 00 00       	mov    $0x11,%edi
f0103ee7:	be 20 00 00 00       	mov    $0x20,%esi
f0103eec:	89 f8                	mov    %edi,%eax
f0103eee:	89 f2                	mov    %esi,%edx
f0103ef0:	ee                   	out    %al,(%dx)
f0103ef1:	b0 20                	mov    $0x20,%al
f0103ef3:	89 da                	mov    %ebx,%edx
f0103ef5:	ee                   	out    %al,(%dx)
f0103ef6:	b0 04                	mov    $0x4,%al
f0103ef8:	ee                   	out    %al,(%dx)
f0103ef9:	b0 03                	mov    $0x3,%al
f0103efb:	ee                   	out    %al,(%dx)
f0103efc:	bb a0 00 00 00       	mov    $0xa0,%ebx
f0103f01:	89 f8                	mov    %edi,%eax
f0103f03:	89 da                	mov    %ebx,%edx
f0103f05:	ee                   	out    %al,(%dx)
f0103f06:	b0 28                	mov    $0x28,%al
f0103f08:	89 ca                	mov    %ecx,%edx
f0103f0a:	ee                   	out    %al,(%dx)
f0103f0b:	b0 02                	mov    $0x2,%al
f0103f0d:	ee                   	out    %al,(%dx)
f0103f0e:	b0 01                	mov    $0x1,%al
f0103f10:	ee                   	out    %al,(%dx)
f0103f11:	bf 68 00 00 00       	mov    $0x68,%edi
f0103f16:	89 f8                	mov    %edi,%eax
f0103f18:	89 f2                	mov    %esi,%edx
f0103f1a:	ee                   	out    %al,(%dx)
f0103f1b:	b1 0a                	mov    $0xa,%cl
f0103f1d:	88 c8                	mov    %cl,%al
f0103f1f:	ee                   	out    %al,(%dx)
f0103f20:	89 f8                	mov    %edi,%eax
f0103f22:	89 da                	mov    %ebx,%edx
f0103f24:	ee                   	out    %al,(%dx)
f0103f25:	88 c8                	mov    %cl,%al
f0103f27:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103f28:	66 a1 a8 33 12 f0    	mov    0xf01233a8,%ax
f0103f2e:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103f32:	74 0f                	je     f0103f43 <pic_init+0x83>
		irq_setmask_8259A(irq_mask_8259A);
f0103f34:	83 ec 0c             	sub    $0xc,%esp
f0103f37:	0f b7 c0             	movzwl %ax,%eax
f0103f3a:	50                   	push   %eax
f0103f3b:	e8 ff fe ff ff       	call   f0103e3f <irq_setmask_8259A>
f0103f40:	83 c4 10             	add    $0x10,%esp
}
f0103f43:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f46:	5b                   	pop    %ebx
f0103f47:	5e                   	pop    %esi
f0103f48:	5f                   	pop    %edi
f0103f49:	5d                   	pop    %ebp
f0103f4a:	c3                   	ret    

f0103f4b <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103f4b:	55                   	push   %ebp
f0103f4c:	89 e5                	mov    %esp,%ebp
f0103f4e:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103f51:	ff 75 08             	pushl  0x8(%ebp)
f0103f54:	e8 f7 c8 ff ff       	call   f0100850 <cputchar>
	*cnt++;
}
f0103f59:	83 c4 10             	add    $0x10,%esp
f0103f5c:	c9                   	leave  
f0103f5d:	c3                   	ret    

f0103f5e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103f5e:	55                   	push   %ebp
f0103f5f:	89 e5                	mov    %esp,%ebp
f0103f61:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103f64:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103f6b:	ff 75 0c             	pushl  0xc(%ebp)
f0103f6e:	ff 75 08             	pushl  0x8(%ebp)
f0103f71:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103f74:	50                   	push   %eax
f0103f75:	68 4b 3f 10 f0       	push   $0xf0103f4b
f0103f7a:	e8 a1 19 00 00       	call   f0105920 <vprintfmt>
	return cnt;
}
f0103f7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f82:	c9                   	leave  
f0103f83:	c3                   	ret    

f0103f84 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103f84:	55                   	push   %ebp
f0103f85:	89 e5                	mov    %esp,%ebp
f0103f87:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103f8a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103f8d:	50                   	push   %eax
f0103f8e:	ff 75 08             	pushl  0x8(%ebp)
f0103f91:	e8 c8 ff ff ff       	call   f0103f5e <vcprintf>
	va_end(ap);

	return cnt;
}
f0103f96:	c9                   	leave  
f0103f97:	c3                   	ret    

f0103f98 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103f98:	55                   	push   %ebp
f0103f99:	89 e5                	mov    %esp,%ebp
f0103f9b:	57                   	push   %edi
f0103f9c:	56                   	push   %esi
f0103f9d:	53                   	push   %ebx
f0103f9e:	83 ec 0c             	sub    $0xc,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	struct Taskstate* ts = &thiscpu->cpu_ts;
f0103fa1:	e8 7c 27 00 00       	call   f0106722 <cpunum>
f0103fa6:	89 c6                	mov    %eax,%esi
f0103fa8:	8d 1c 00             	lea    (%eax,%eax,1),%ebx
f0103fab:	01 c3                	add    %eax,%ebx
f0103fad:	01 db                	add    %ebx,%ebx
f0103faf:	01 c3                	add    %eax,%ebx
f0103fb1:	c1 e3 02             	shl    $0x2,%ebx
f0103fb4:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0103fb7:	8d 3c 85 2c 80 2a f0 	lea    -0xfd57fd4(,%eax,4),%edi
	ts->ts_esp0 = KSTACKTOP - cpunum() * (KSTKSIZE + KSTKGAP);
f0103fbe:	e8 5f 27 00 00       	call   f0106722 <cpunum>
f0103fc3:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f0103fc6:	8d 14 95 20 80 2a f0 	lea    -0xfd57fe0(,%edx,4),%edx
f0103fcd:	c1 e0 10             	shl    $0x10,%eax
f0103fd0:	89 c1                	mov    %eax,%ecx
f0103fd2:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f0103fd7:	29 c8                	sub    %ecx,%eax
f0103fd9:	89 42 10             	mov    %eax,0x10(%edx)
	ts->ts_ss0 = GD_KD;
f0103fdc:	66 c7 42 14 10 00    	movw   $0x10,0x14(%edx)
	ts->ts_iomb = sizeof(struct Taskstate);
f0103fe2:	01 f3                	add    %esi,%ebx
f0103fe4:	66 c7 04 9d 92 80 2a 	movw   $0x68,-0xfd57f6e(,%ebx,4)
f0103feb:	f0 68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) ts,
f0103fee:	66 c7 05 68 33 12 f0 	movw   $0x67,0xf0123368
f0103ff5:	67 00 
f0103ff7:	66 89 3d 6a 33 12 f0 	mov    %di,0xf012336a
f0103ffe:	89 f8                	mov    %edi,%eax
f0104000:	c1 e8 10             	shr    $0x10,%eax
f0104003:	a2 6c 33 12 f0       	mov    %al,0xf012336c
f0104008:	c6 05 6e 33 12 f0 40 	movb   $0x40,0xf012336e
f010400f:	89 f8                	mov    %edi,%eax
f0104011:	c1 e8 18             	shr    $0x18,%eax
f0104014:	a2 6f 33 12 f0       	mov    %al,0xf012336f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0104019:	c6 05 6d 33 12 f0 89 	movb   $0x89,0xf012336d
	asm volatile("ltr %0" : : "r" (sel));
f0104020:	b8 28 00 00 00       	mov    $0x28,%eax
f0104025:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f0104028:	b8 ac 33 12 f0       	mov    $0xf01233ac,%eax
f010402d:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0104030:	83 c4 0c             	add    $0xc,%esp
f0104033:	5b                   	pop    %ebx
f0104034:	5e                   	pop    %esi
f0104035:	5f                   	pop    %edi
f0104036:	5d                   	pop    %ebp
f0104037:	c3                   	ret    

f0104038 <trap_init>:
{
f0104038:	55                   	push   %ebp
f0104039:	89 e5                	mov    %esp,%ebp
f010403b:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE],  0, GD_KT, (void*)H_DIVIDE, 0);   
f010403e:	b8 04 4c 10 f0       	mov    $0xf0104c04,%eax
f0104043:	66 a3 60 72 2a f0    	mov    %ax,0xf02a7260
f0104049:	66 c7 05 62 72 2a f0 	movw   $0x8,0xf02a7262
f0104050:	08 00 
f0104052:	c6 05 64 72 2a f0 00 	movb   $0x0,0xf02a7264
f0104059:	c6 05 65 72 2a f0 8e 	movb   $0x8e,0xf02a7265
f0104060:	c1 e8 10             	shr    $0x10,%eax
f0104063:	66 a3 66 72 2a f0    	mov    %ax,0xf02a7266
	SETGATE(idt[T_DEBUG],   0, GD_KT, (void*)H_DEBUG,  0);  
f0104069:	b8 0e 4c 10 f0       	mov    $0xf0104c0e,%eax
f010406e:	66 a3 68 72 2a f0    	mov    %ax,0xf02a7268
f0104074:	66 c7 05 6a 72 2a f0 	movw   $0x8,0xf02a726a
f010407b:	08 00 
f010407d:	c6 05 6c 72 2a f0 00 	movb   $0x0,0xf02a726c
f0104084:	c6 05 6d 72 2a f0 8e 	movb   $0x8e,0xf02a726d
f010408b:	c1 e8 10             	shr    $0x10,%eax
f010408e:	66 a3 6e 72 2a f0    	mov    %ax,0xf02a726e
	SETGATE(idt[T_NMI],     0, GD_KT, (void*)H_NMI,    0);
f0104094:	b8 18 4c 10 f0       	mov    $0xf0104c18,%eax
f0104099:	66 a3 70 72 2a f0    	mov    %ax,0xf02a7270
f010409f:	66 c7 05 72 72 2a f0 	movw   $0x8,0xf02a7272
f01040a6:	08 00 
f01040a8:	c6 05 74 72 2a f0 00 	movb   $0x0,0xf02a7274
f01040af:	c6 05 75 72 2a f0 8e 	movb   $0x8e,0xf02a7275
f01040b6:	c1 e8 10             	shr    $0x10,%eax
f01040b9:	66 a3 76 72 2a f0    	mov    %ax,0xf02a7276
	SETGATE(idt[T_BRKPT],   0, GD_KT, (void*)H_BRKPT,  3);  // User level previlege (3)
f01040bf:	b8 22 4c 10 f0       	mov    $0xf0104c22,%eax
f01040c4:	66 a3 78 72 2a f0    	mov    %ax,0xf02a7278
f01040ca:	66 c7 05 7a 72 2a f0 	movw   $0x8,0xf02a727a
f01040d1:	08 00 
f01040d3:	c6 05 7c 72 2a f0 00 	movb   $0x0,0xf02a727c
f01040da:	c6 05 7d 72 2a f0 ee 	movb   $0xee,0xf02a727d
f01040e1:	c1 e8 10             	shr    $0x10,%eax
f01040e4:	66 a3 7e 72 2a f0    	mov    %ax,0xf02a727e
	SETGATE(idt[T_OFLOW],   0, GD_KT, (void*)H_OFLOW,  0);  
f01040ea:	b8 2c 4c 10 f0       	mov    $0xf0104c2c,%eax
f01040ef:	66 a3 80 72 2a f0    	mov    %ax,0xf02a7280
f01040f5:	66 c7 05 82 72 2a f0 	movw   $0x8,0xf02a7282
f01040fc:	08 00 
f01040fe:	c6 05 84 72 2a f0 00 	movb   $0x0,0xf02a7284
f0104105:	c6 05 85 72 2a f0 8e 	movb   $0x8e,0xf02a7285
f010410c:	c1 e8 10             	shr    $0x10,%eax
f010410f:	66 a3 86 72 2a f0    	mov    %ax,0xf02a7286
	SETGATE(idt[T_BOUND],   0, GD_KT, (void*)H_BOUND,  0);  
f0104115:	b8 36 4c 10 f0       	mov    $0xf0104c36,%eax
f010411a:	66 a3 88 72 2a f0    	mov    %ax,0xf02a7288
f0104120:	66 c7 05 8a 72 2a f0 	movw   $0x8,0xf02a728a
f0104127:	08 00 
f0104129:	c6 05 8c 72 2a f0 00 	movb   $0x0,0xf02a728c
f0104130:	c6 05 8d 72 2a f0 8e 	movb   $0x8e,0xf02a728d
f0104137:	c1 e8 10             	shr    $0x10,%eax
f010413a:	66 a3 8e 72 2a f0    	mov    %ax,0xf02a728e
	SETGATE(idt[T_ILLOP],   0, GD_KT, (void*)H_ILLOP,  0);  
f0104140:	b8 40 4c 10 f0       	mov    $0xf0104c40,%eax
f0104145:	66 a3 90 72 2a f0    	mov    %ax,0xf02a7290
f010414b:	66 c7 05 92 72 2a f0 	movw   $0x8,0xf02a7292
f0104152:	08 00 
f0104154:	c6 05 94 72 2a f0 00 	movb   $0x0,0xf02a7294
f010415b:	c6 05 95 72 2a f0 8e 	movb   $0x8e,0xf02a7295
f0104162:	c1 e8 10             	shr    $0x10,%eax
f0104165:	66 a3 96 72 2a f0    	mov    %ax,0xf02a7296
	SETGATE(idt[T_DEVICE],  0, GD_KT, (void*)H_DEVICE, 0);   
f010416b:	b8 4a 4c 10 f0       	mov    $0xf0104c4a,%eax
f0104170:	66 a3 98 72 2a f0    	mov    %ax,0xf02a7298
f0104176:	66 c7 05 9a 72 2a f0 	movw   $0x8,0xf02a729a
f010417d:	08 00 
f010417f:	c6 05 9c 72 2a f0 00 	movb   $0x0,0xf02a729c
f0104186:	c6 05 9d 72 2a f0 8e 	movb   $0x8e,0xf02a729d
f010418d:	c1 e8 10             	shr    $0x10,%eax
f0104190:	66 a3 9e 72 2a f0    	mov    %ax,0xf02a729e
	SETGATE(idt[T_DBLFLT],  0, GD_KT, (void*)H_DBLFLT, 0);   
f0104196:	b8 54 4c 10 f0       	mov    $0xf0104c54,%eax
f010419b:	66 a3 a0 72 2a f0    	mov    %ax,0xf02a72a0
f01041a1:	66 c7 05 a2 72 2a f0 	movw   $0x8,0xf02a72a2
f01041a8:	08 00 
f01041aa:	c6 05 a4 72 2a f0 00 	movb   $0x0,0xf02a72a4
f01041b1:	c6 05 a5 72 2a f0 8e 	movb   $0x8e,0xf02a72a5
f01041b8:	c1 e8 10             	shr    $0x10,%eax
f01041bb:	66 a3 a6 72 2a f0    	mov    %ax,0xf02a72a6
	SETGATE(idt[T_TSS],     0, GD_KT, (void*)H_TSS,    0);
f01041c1:	b8 5c 4c 10 f0       	mov    $0xf0104c5c,%eax
f01041c6:	66 a3 b0 72 2a f0    	mov    %ax,0xf02a72b0
f01041cc:	66 c7 05 b2 72 2a f0 	movw   $0x8,0xf02a72b2
f01041d3:	08 00 
f01041d5:	c6 05 b4 72 2a f0 00 	movb   $0x0,0xf02a72b4
f01041dc:	c6 05 b5 72 2a f0 8e 	movb   $0x8e,0xf02a72b5
f01041e3:	c1 e8 10             	shr    $0x10,%eax
f01041e6:	66 a3 b6 72 2a f0    	mov    %ax,0xf02a72b6
	SETGATE(idt[T_SEGNP],   0, GD_KT, (void*)H_SEGNP,  0);  
f01041ec:	b8 64 4c 10 f0       	mov    $0xf0104c64,%eax
f01041f1:	66 a3 b8 72 2a f0    	mov    %ax,0xf02a72b8
f01041f7:	66 c7 05 ba 72 2a f0 	movw   $0x8,0xf02a72ba
f01041fe:	08 00 
f0104200:	c6 05 bc 72 2a f0 00 	movb   $0x0,0xf02a72bc
f0104207:	c6 05 bd 72 2a f0 8e 	movb   $0x8e,0xf02a72bd
f010420e:	c1 e8 10             	shr    $0x10,%eax
f0104211:	66 a3 be 72 2a f0    	mov    %ax,0xf02a72be
	SETGATE(idt[T_STACK],   0, GD_KT, (void*)H_STACK,  0);  
f0104217:	b8 6c 4c 10 f0       	mov    $0xf0104c6c,%eax
f010421c:	66 a3 c0 72 2a f0    	mov    %ax,0xf02a72c0
f0104222:	66 c7 05 c2 72 2a f0 	movw   $0x8,0xf02a72c2
f0104229:	08 00 
f010422b:	c6 05 c4 72 2a f0 00 	movb   $0x0,0xf02a72c4
f0104232:	c6 05 c5 72 2a f0 8e 	movb   $0x8e,0xf02a72c5
f0104239:	c1 e8 10             	shr    $0x10,%eax
f010423c:	66 a3 c6 72 2a f0    	mov    %ax,0xf02a72c6
	SETGATE(idt[T_GPFLT],   0, GD_KT, (void*)H_GPFLT,  0);  
f0104242:	b8 74 4c 10 f0       	mov    $0xf0104c74,%eax
f0104247:	66 a3 c8 72 2a f0    	mov    %ax,0xf02a72c8
f010424d:	66 c7 05 ca 72 2a f0 	movw   $0x8,0xf02a72ca
f0104254:	08 00 
f0104256:	c6 05 cc 72 2a f0 00 	movb   $0x0,0xf02a72cc
f010425d:	c6 05 cd 72 2a f0 8e 	movb   $0x8e,0xf02a72cd
f0104264:	c1 e8 10             	shr    $0x10,%eax
f0104267:	66 a3 ce 72 2a f0    	mov    %ax,0xf02a72ce
	SETGATE(idt[T_PGFLT],   0, GD_KT, (void*)H_PGFLT,  0);  
f010426d:	b8 7c 4c 10 f0       	mov    $0xf0104c7c,%eax
f0104272:	66 a3 d0 72 2a f0    	mov    %ax,0xf02a72d0
f0104278:	66 c7 05 d2 72 2a f0 	movw   $0x8,0xf02a72d2
f010427f:	08 00 
f0104281:	c6 05 d4 72 2a f0 00 	movb   $0x0,0xf02a72d4
f0104288:	c6 05 d5 72 2a f0 8e 	movb   $0x8e,0xf02a72d5
f010428f:	c1 e8 10             	shr    $0x10,%eax
f0104292:	66 a3 d6 72 2a f0    	mov    %ax,0xf02a72d6
	SETGATE(idt[T_FPERR],   0, GD_KT, (void*)H_FPERR,  0);  
f0104298:	b8 80 4c 10 f0       	mov    $0xf0104c80,%eax
f010429d:	66 a3 e0 72 2a f0    	mov    %ax,0xf02a72e0
f01042a3:	66 c7 05 e2 72 2a f0 	movw   $0x8,0xf02a72e2
f01042aa:	08 00 
f01042ac:	c6 05 e4 72 2a f0 00 	movb   $0x0,0xf02a72e4
f01042b3:	c6 05 e5 72 2a f0 8e 	movb   $0x8e,0xf02a72e5
f01042ba:	c1 e8 10             	shr    $0x10,%eax
f01042bd:	66 a3 e6 72 2a f0    	mov    %ax,0xf02a72e6
	SETGATE(idt[T_ALIGN],   0, GD_KT, (void*)H_ALIGN,  0);  
f01042c3:	b8 86 4c 10 f0       	mov    $0xf0104c86,%eax
f01042c8:	66 a3 e8 72 2a f0    	mov    %ax,0xf02a72e8
f01042ce:	66 c7 05 ea 72 2a f0 	movw   $0x8,0xf02a72ea
f01042d5:	08 00 
f01042d7:	c6 05 ec 72 2a f0 00 	movb   $0x0,0xf02a72ec
f01042de:	c6 05 ed 72 2a f0 8e 	movb   $0x8e,0xf02a72ed
f01042e5:	c1 e8 10             	shr    $0x10,%eax
f01042e8:	66 a3 ee 72 2a f0    	mov    %ax,0xf02a72ee
	SETGATE(idt[T_MCHK],    0, GD_KT, (void*)H_MCHK,   0); 
f01042ee:	b8 8c 4c 10 f0       	mov    $0xf0104c8c,%eax
f01042f3:	66 a3 f0 72 2a f0    	mov    %ax,0xf02a72f0
f01042f9:	66 c7 05 f2 72 2a f0 	movw   $0x8,0xf02a72f2
f0104300:	08 00 
f0104302:	c6 05 f4 72 2a f0 00 	movb   $0x0,0xf02a72f4
f0104309:	c6 05 f5 72 2a f0 8e 	movb   $0x8e,0xf02a72f5
f0104310:	c1 e8 10             	shr    $0x10,%eax
f0104313:	66 a3 f6 72 2a f0    	mov    %ax,0xf02a72f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, (void*)H_SIMDERR,0);  
f0104319:	b8 92 4c 10 f0       	mov    $0xf0104c92,%eax
f010431e:	66 a3 f8 72 2a f0    	mov    %ax,0xf02a72f8
f0104324:	66 c7 05 fa 72 2a f0 	movw   $0x8,0xf02a72fa
f010432b:	08 00 
f010432d:	c6 05 fc 72 2a f0 00 	movb   $0x0,0xf02a72fc
f0104334:	c6 05 fd 72 2a f0 8e 	movb   $0x8e,0xf02a72fd
f010433b:	c1 e8 10             	shr    $0x10,%eax
f010433e:	66 a3 fe 72 2a f0    	mov    %ax,0xf02a72fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, (void*)H_SYSCALL,3);  // System call
f0104344:	b8 98 4c 10 f0       	mov    $0xf0104c98,%eax
f0104349:	66 a3 e0 73 2a f0    	mov    %ax,0xf02a73e0
f010434f:	66 c7 05 e2 73 2a f0 	movw   $0x8,0xf02a73e2
f0104356:	08 00 
f0104358:	c6 05 e4 73 2a f0 00 	movb   $0x0,0xf02a73e4
f010435f:	c6 05 e5 73 2a f0 ee 	movb   $0xee,0xf02a73e5
f0104366:	c1 e8 10             	shr    $0x10,%eax
f0104369:	66 a3 e6 73 2a f0    	mov    %ax,0xf02a73e6
	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER],    0, GD_KT, (void*)H_TIMER,  0);
f010436f:	b8 9e 4c 10 f0       	mov    $0xf0104c9e,%eax
f0104374:	66 a3 60 73 2a f0    	mov    %ax,0xf02a7360
f010437a:	66 c7 05 62 73 2a f0 	movw   $0x8,0xf02a7362
f0104381:	08 00 
f0104383:	c6 05 64 73 2a f0 00 	movb   $0x0,0xf02a7364
f010438a:	c6 05 65 73 2a f0 8e 	movb   $0x8e,0xf02a7365
f0104391:	c1 e8 10             	shr    $0x10,%eax
f0104394:	66 a3 66 73 2a f0    	mov    %ax,0xf02a7366
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD],      0, GD_KT, (void*)H_KBD,    0);
f010439a:	b8 a4 4c 10 f0       	mov    $0xf0104ca4,%eax
f010439f:	66 a3 68 73 2a f0    	mov    %ax,0xf02a7368
f01043a5:	66 c7 05 6a 73 2a f0 	movw   $0x8,0xf02a736a
f01043ac:	08 00 
f01043ae:	c6 05 6c 73 2a f0 00 	movb   $0x0,0xf02a736c
f01043b5:	c6 05 6d 73 2a f0 8e 	movb   $0x8e,0xf02a736d
f01043bc:	c1 e8 10             	shr    $0x10,%eax
f01043bf:	66 a3 6e 73 2a f0    	mov    %ax,0xf02a736e
	SETGATE(idt[IRQ_OFFSET + 2],            0, GD_KT, (void*)H_IRQ2,   0);
f01043c5:	b8 aa 4c 10 f0       	mov    $0xf0104caa,%eax
f01043ca:	66 a3 70 73 2a f0    	mov    %ax,0xf02a7370
f01043d0:	66 c7 05 72 73 2a f0 	movw   $0x8,0xf02a7372
f01043d7:	08 00 
f01043d9:	c6 05 74 73 2a f0 00 	movb   $0x0,0xf02a7374
f01043e0:	c6 05 75 73 2a f0 8e 	movb   $0x8e,0xf02a7375
f01043e7:	c1 e8 10             	shr    $0x10,%eax
f01043ea:	66 a3 76 73 2a f0    	mov    %ax,0xf02a7376
	SETGATE(idt[IRQ_OFFSET + 3],            0, GD_KT, (void*)H_IRQ3,   0);
f01043f0:	b8 b0 4c 10 f0       	mov    $0xf0104cb0,%eax
f01043f5:	66 a3 78 73 2a f0    	mov    %ax,0xf02a7378
f01043fb:	66 c7 05 7a 73 2a f0 	movw   $0x8,0xf02a737a
f0104402:	08 00 
f0104404:	c6 05 7c 73 2a f0 00 	movb   $0x0,0xf02a737c
f010440b:	c6 05 7d 73 2a f0 8e 	movb   $0x8e,0xf02a737d
f0104412:	c1 e8 10             	shr    $0x10,%eax
f0104415:	66 a3 7e 73 2a f0    	mov    %ax,0xf02a737e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL],   0, GD_KT, (void*)H_SERIAL, 0);
f010441b:	b8 b6 4c 10 f0       	mov    $0xf0104cb6,%eax
f0104420:	66 a3 80 73 2a f0    	mov    %ax,0xf02a7380
f0104426:	66 c7 05 82 73 2a f0 	movw   $0x8,0xf02a7382
f010442d:	08 00 
f010442f:	c6 05 84 73 2a f0 00 	movb   $0x0,0xf02a7384
f0104436:	c6 05 85 73 2a f0 8e 	movb   $0x8e,0xf02a7385
f010443d:	c1 e8 10             	shr    $0x10,%eax
f0104440:	66 a3 86 73 2a f0    	mov    %ax,0xf02a7386
	SETGATE(idt[IRQ_OFFSET + 5],            0, GD_KT, (void*)H_IRQ5,   0);
f0104446:	b8 bc 4c 10 f0       	mov    $0xf0104cbc,%eax
f010444b:	66 a3 88 73 2a f0    	mov    %ax,0xf02a7388
f0104451:	66 c7 05 8a 73 2a f0 	movw   $0x8,0xf02a738a
f0104458:	08 00 
f010445a:	c6 05 8c 73 2a f0 00 	movb   $0x0,0xf02a738c
f0104461:	c6 05 8d 73 2a f0 8e 	movb   $0x8e,0xf02a738d
f0104468:	c1 e8 10             	shr    $0x10,%eax
f010446b:	66 a3 8e 73 2a f0    	mov    %ax,0xf02a738e
	SETGATE(idt[IRQ_OFFSET + 6],            0, GD_KT, (void*)H_IRQ6,   0);
f0104471:	b8 c2 4c 10 f0       	mov    $0xf0104cc2,%eax
f0104476:	66 a3 90 73 2a f0    	mov    %ax,0xf02a7390
f010447c:	66 c7 05 92 73 2a f0 	movw   $0x8,0xf02a7392
f0104483:	08 00 
f0104485:	c6 05 94 73 2a f0 00 	movb   $0x0,0xf02a7394
f010448c:	c6 05 95 73 2a f0 8e 	movb   $0x8e,0xf02a7395
f0104493:	c1 e8 10             	shr    $0x10,%eax
f0104496:	66 a3 96 73 2a f0    	mov    %ax,0xf02a7396
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, (void*)H_SPUR,   0);
f010449c:	b8 c8 4c 10 f0       	mov    $0xf0104cc8,%eax
f01044a1:	66 a3 98 73 2a f0    	mov    %ax,0xf02a7398
f01044a7:	66 c7 05 9a 73 2a f0 	movw   $0x8,0xf02a739a
f01044ae:	08 00 
f01044b0:	c6 05 9c 73 2a f0 00 	movb   $0x0,0xf02a739c
f01044b7:	c6 05 9d 73 2a f0 8e 	movb   $0x8e,0xf02a739d
f01044be:	c1 e8 10             	shr    $0x10,%eax
f01044c1:	66 a3 9e 73 2a f0    	mov    %ax,0xf02a739e
	SETGATE(idt[IRQ_OFFSET + 8],            0, GD_KT, (void*)H_IRQ8,   0);
f01044c7:	b8 ce 4c 10 f0       	mov    $0xf0104cce,%eax
f01044cc:	66 a3 a0 73 2a f0    	mov    %ax,0xf02a73a0
f01044d2:	66 c7 05 a2 73 2a f0 	movw   $0x8,0xf02a73a2
f01044d9:	08 00 
f01044db:	c6 05 a4 73 2a f0 00 	movb   $0x0,0xf02a73a4
f01044e2:	c6 05 a5 73 2a f0 8e 	movb   $0x8e,0xf02a73a5
f01044e9:	c1 e8 10             	shr    $0x10,%eax
f01044ec:	66 a3 a6 73 2a f0    	mov    %ax,0xf02a73a6
	SETGATE(idt[IRQ_OFFSET + 9],            0, GD_KT, (void*)H_IRQ9,   0);
f01044f2:	b8 d4 4c 10 f0       	mov    $0xf0104cd4,%eax
f01044f7:	66 a3 a8 73 2a f0    	mov    %ax,0xf02a73a8
f01044fd:	66 c7 05 aa 73 2a f0 	movw   $0x8,0xf02a73aa
f0104504:	08 00 
f0104506:	c6 05 ac 73 2a f0 00 	movb   $0x0,0xf02a73ac
f010450d:	c6 05 ad 73 2a f0 8e 	movb   $0x8e,0xf02a73ad
f0104514:	c1 e8 10             	shr    $0x10,%eax
f0104517:	66 a3 ae 73 2a f0    	mov    %ax,0xf02a73ae
	SETGATE(idt[IRQ_OFFSET + 10],           0, GD_KT, (void*)H_IRQ10,  0);
f010451d:	b8 da 4c 10 f0       	mov    $0xf0104cda,%eax
f0104522:	66 a3 b0 73 2a f0    	mov    %ax,0xf02a73b0
f0104528:	66 c7 05 b2 73 2a f0 	movw   $0x8,0xf02a73b2
f010452f:	08 00 
f0104531:	c6 05 b4 73 2a f0 00 	movb   $0x0,0xf02a73b4
f0104538:	c6 05 b5 73 2a f0 8e 	movb   $0x8e,0xf02a73b5
f010453f:	c1 e8 10             	shr    $0x10,%eax
f0104542:	66 a3 b6 73 2a f0    	mov    %ax,0xf02a73b6
	SETGATE(idt[IRQ_OFFSET + 11],           0, GD_KT, (void*)H_IRQ11,  0);
f0104548:	b8 e0 4c 10 f0       	mov    $0xf0104ce0,%eax
f010454d:	66 a3 b8 73 2a f0    	mov    %ax,0xf02a73b8
f0104553:	66 c7 05 ba 73 2a f0 	movw   $0x8,0xf02a73ba
f010455a:	08 00 
f010455c:	c6 05 bc 73 2a f0 00 	movb   $0x0,0xf02a73bc
f0104563:	c6 05 bd 73 2a f0 8e 	movb   $0x8e,0xf02a73bd
f010456a:	c1 e8 10             	shr    $0x10,%eax
f010456d:	66 a3 be 73 2a f0    	mov    %ax,0xf02a73be
	SETGATE(idt[IRQ_OFFSET + 12],           0, GD_KT, (void*)H_IRQ12,  0);
f0104573:	b8 e6 4c 10 f0       	mov    $0xf0104ce6,%eax
f0104578:	66 a3 c0 73 2a f0    	mov    %ax,0xf02a73c0
f010457e:	66 c7 05 c2 73 2a f0 	movw   $0x8,0xf02a73c2
f0104585:	08 00 
f0104587:	c6 05 c4 73 2a f0 00 	movb   $0x0,0xf02a73c4
f010458e:	c6 05 c5 73 2a f0 8e 	movb   $0x8e,0xf02a73c5
f0104595:	c1 e8 10             	shr    $0x10,%eax
f0104598:	66 a3 c6 73 2a f0    	mov    %ax,0xf02a73c6
	SETGATE(idt[IRQ_OFFSET + 13],           0, GD_KT, (void*)H_IRQ13,  0);
f010459e:	b8 ec 4c 10 f0       	mov    $0xf0104cec,%eax
f01045a3:	66 a3 c8 73 2a f0    	mov    %ax,0xf02a73c8
f01045a9:	66 c7 05 ca 73 2a f0 	movw   $0x8,0xf02a73ca
f01045b0:	08 00 
f01045b2:	c6 05 cc 73 2a f0 00 	movb   $0x0,0xf02a73cc
f01045b9:	c6 05 cd 73 2a f0 8e 	movb   $0x8e,0xf02a73cd
f01045c0:	c1 e8 10             	shr    $0x10,%eax
f01045c3:	66 a3 ce 73 2a f0    	mov    %ax,0xf02a73ce
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE],      0, GD_KT, (void*)H_IDE,    0);
f01045c9:	b8 f2 4c 10 f0       	mov    $0xf0104cf2,%eax
f01045ce:	66 a3 d0 73 2a f0    	mov    %ax,0xf02a73d0
f01045d4:	66 c7 05 d2 73 2a f0 	movw   $0x8,0xf02a73d2
f01045db:	08 00 
f01045dd:	c6 05 d4 73 2a f0 00 	movb   $0x0,0xf02a73d4
f01045e4:	c6 05 d5 73 2a f0 8e 	movb   $0x8e,0xf02a73d5
f01045eb:	c1 e8 10             	shr    $0x10,%eax
f01045ee:	66 a3 d6 73 2a f0    	mov    %ax,0xf02a73d6
	SETGATE(idt[IRQ_OFFSET + 15],           0, GD_KT, (void*)H_IRQ15,  0);
f01045f4:	b8 f8 4c 10 f0       	mov    $0xf0104cf8,%eax
f01045f9:	66 a3 d8 73 2a f0    	mov    %ax,0xf02a73d8
f01045ff:	66 c7 05 da 73 2a f0 	movw   $0x8,0xf02a73da
f0104606:	08 00 
f0104608:	c6 05 dc 73 2a f0 00 	movb   $0x0,0xf02a73dc
f010460f:	c6 05 dd 73 2a f0 8e 	movb   $0x8e,0xf02a73dd
f0104616:	c1 e8 10             	shr    $0x10,%eax
f0104619:	66 a3 de 73 2a f0    	mov    %ax,0xf02a73de
	trap_init_percpu();
f010461f:	e8 74 f9 ff ff       	call   f0103f98 <trap_init_percpu>
}
f0104624:	c9                   	leave  
f0104625:	c3                   	ret    

f0104626 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104626:	55                   	push   %ebp
f0104627:	89 e5                	mov    %esp,%ebp
f0104629:	53                   	push   %ebx
f010462a:	83 ec 0c             	sub    $0xc,%esp
f010462d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0104630:	ff 33                	pushl  (%ebx)
f0104632:	68 7e 83 10 f0       	push   $0xf010837e
f0104637:	e8 48 f9 ff ff       	call   f0103f84 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010463c:	83 c4 08             	add    $0x8,%esp
f010463f:	ff 73 04             	pushl  0x4(%ebx)
f0104642:	68 8d 83 10 f0       	push   $0xf010838d
f0104647:	e8 38 f9 ff ff       	call   f0103f84 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010464c:	83 c4 08             	add    $0x8,%esp
f010464f:	ff 73 08             	pushl  0x8(%ebx)
f0104652:	68 9c 83 10 f0       	push   $0xf010839c
f0104657:	e8 28 f9 ff ff       	call   f0103f84 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010465c:	83 c4 08             	add    $0x8,%esp
f010465f:	ff 73 0c             	pushl  0xc(%ebx)
f0104662:	68 ab 83 10 f0       	push   $0xf01083ab
f0104667:	e8 18 f9 ff ff       	call   f0103f84 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010466c:	83 c4 08             	add    $0x8,%esp
f010466f:	ff 73 10             	pushl  0x10(%ebx)
f0104672:	68 ba 83 10 f0       	push   $0xf01083ba
f0104677:	e8 08 f9 ff ff       	call   f0103f84 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010467c:	83 c4 08             	add    $0x8,%esp
f010467f:	ff 73 14             	pushl  0x14(%ebx)
f0104682:	68 c9 83 10 f0       	push   $0xf01083c9
f0104687:	e8 f8 f8 ff ff       	call   f0103f84 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010468c:	83 c4 08             	add    $0x8,%esp
f010468f:	ff 73 18             	pushl  0x18(%ebx)
f0104692:	68 d8 83 10 f0       	push   $0xf01083d8
f0104697:	e8 e8 f8 ff ff       	call   f0103f84 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010469c:	83 c4 08             	add    $0x8,%esp
f010469f:	ff 73 1c             	pushl  0x1c(%ebx)
f01046a2:	68 e7 83 10 f0       	push   $0xf01083e7
f01046a7:	e8 d8 f8 ff ff       	call   f0103f84 <cprintf>
}
f01046ac:	83 c4 10             	add    $0x10,%esp
f01046af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01046b2:	c9                   	leave  
f01046b3:	c3                   	ret    

f01046b4 <print_trapframe>:
{
f01046b4:	55                   	push   %ebp
f01046b5:	89 e5                	mov    %esp,%ebp
f01046b7:	53                   	push   %ebx
f01046b8:	83 ec 04             	sub    $0x4,%esp
f01046bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01046be:	e8 5f 20 00 00       	call   f0106722 <cpunum>
f01046c3:	83 ec 04             	sub    $0x4,%esp
f01046c6:	50                   	push   %eax
f01046c7:	53                   	push   %ebx
f01046c8:	68 4b 84 10 f0       	push   $0xf010844b
f01046cd:	e8 b2 f8 ff ff       	call   f0103f84 <cprintf>
	print_regs(&tf->tf_regs);
f01046d2:	89 1c 24             	mov    %ebx,(%esp)
f01046d5:	e8 4c ff ff ff       	call   f0104626 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01046da:	83 c4 08             	add    $0x8,%esp
f01046dd:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01046e1:	50                   	push   %eax
f01046e2:	68 69 84 10 f0       	push   $0xf0108469
f01046e7:	e8 98 f8 ff ff       	call   f0103f84 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01046ec:	83 c4 08             	add    $0x8,%esp
f01046ef:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01046f3:	50                   	push   %eax
f01046f4:	68 7c 84 10 f0       	push   $0xf010847c
f01046f9:	e8 86 f8 ff ff       	call   f0103f84 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01046fe:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0104701:	83 c4 10             	add    $0x10,%esp
f0104704:	83 f8 13             	cmp    $0x13,%eax
f0104707:	76 1c                	jbe    f0104725 <print_trapframe+0x71>
	if (trapno == T_SYSCALL)
f0104709:	83 f8 30             	cmp    $0x30,%eax
f010470c:	0f 84 cf 00 00 00    	je     f01047e1 <print_trapframe+0x12d>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104712:	8d 50 e0             	lea    -0x20(%eax),%edx
f0104715:	83 fa 0f             	cmp    $0xf,%edx
f0104718:	0f 86 cd 00 00 00    	jbe    f01047eb <print_trapframe+0x137>
	return "(unknown trap)";
f010471e:	ba 15 84 10 f0       	mov    $0xf0108415,%edx
f0104723:	eb 07                	jmp    f010472c <print_trapframe+0x78>
		return excnames[trapno];
f0104725:	8b 14 85 20 87 10 f0 	mov    -0xfef78e0(,%eax,4),%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010472c:	83 ec 04             	sub    $0x4,%esp
f010472f:	52                   	push   %edx
f0104730:	50                   	push   %eax
f0104731:	68 8f 84 10 f0       	push   $0xf010848f
f0104736:	e8 49 f8 ff ff       	call   f0103f84 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010473b:	83 c4 10             	add    $0x10,%esp
f010473e:	39 1d 60 7a 2a f0    	cmp    %ebx,0xf02a7a60
f0104744:	0f 84 ab 00 00 00    	je     f01047f5 <print_trapframe+0x141>
	cprintf("  err  0x%08x", tf->tf_err);
f010474a:	83 ec 08             	sub    $0x8,%esp
f010474d:	ff 73 2c             	pushl  0x2c(%ebx)
f0104750:	68 b0 84 10 f0       	push   $0xf01084b0
f0104755:	e8 2a f8 ff ff       	call   f0103f84 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f010475a:	83 c4 10             	add    $0x10,%esp
f010475d:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104761:	0f 85 cf 00 00 00    	jne    f0104836 <print_trapframe+0x182>
			tf->tf_err & 1 ? "protection" : "not-present");
f0104767:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f010476a:	a8 01                	test   $0x1,%al
f010476c:	0f 85 a6 00 00 00    	jne    f0104818 <print_trapframe+0x164>
f0104772:	b9 2f 84 10 f0       	mov    $0xf010842f,%ecx
f0104777:	a8 02                	test   $0x2,%al
f0104779:	0f 85 a3 00 00 00    	jne    f0104822 <print_trapframe+0x16e>
f010477f:	ba 41 84 10 f0       	mov    $0xf0108441,%edx
f0104784:	a8 04                	test   $0x4,%al
f0104786:	0f 85 a0 00 00 00    	jne    f010482c <print_trapframe+0x178>
f010478c:	b8 7b 85 10 f0       	mov    $0xf010857b,%eax
f0104791:	51                   	push   %ecx
f0104792:	52                   	push   %edx
f0104793:	50                   	push   %eax
f0104794:	68 be 84 10 f0       	push   $0xf01084be
f0104799:	e8 e6 f7 ff ff       	call   f0103f84 <cprintf>
f010479e:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01047a1:	83 ec 08             	sub    $0x8,%esp
f01047a4:	ff 73 30             	pushl  0x30(%ebx)
f01047a7:	68 cd 84 10 f0       	push   $0xf01084cd
f01047ac:	e8 d3 f7 ff ff       	call   f0103f84 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01047b1:	83 c4 08             	add    $0x8,%esp
f01047b4:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01047b8:	50                   	push   %eax
f01047b9:	68 dc 84 10 f0       	push   $0xf01084dc
f01047be:	e8 c1 f7 ff ff       	call   f0103f84 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01047c3:	83 c4 08             	add    $0x8,%esp
f01047c6:	ff 73 38             	pushl  0x38(%ebx)
f01047c9:	68 ef 84 10 f0       	push   $0xf01084ef
f01047ce:	e8 b1 f7 ff ff       	call   f0103f84 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01047d3:	83 c4 10             	add    $0x10,%esp
f01047d6:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01047da:	75 6f                	jne    f010484b <print_trapframe+0x197>
}
f01047dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01047df:	c9                   	leave  
f01047e0:	c3                   	ret    
		return "System call";
f01047e1:	ba f6 83 10 f0       	mov    $0xf01083f6,%edx
f01047e6:	e9 41 ff ff ff       	jmp    f010472c <print_trapframe+0x78>
		return "Hardware Interrupt";
f01047eb:	ba 02 84 10 f0       	mov    $0xf0108402,%edx
f01047f0:	e9 37 ff ff ff       	jmp    f010472c <print_trapframe+0x78>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01047f5:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01047f9:	0f 85 4b ff ff ff    	jne    f010474a <print_trapframe+0x96>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f01047ff:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104802:	83 ec 08             	sub    $0x8,%esp
f0104805:	50                   	push   %eax
f0104806:	68 a1 84 10 f0       	push   $0xf01084a1
f010480b:	e8 74 f7 ff ff       	call   f0103f84 <cprintf>
f0104810:	83 c4 10             	add    $0x10,%esp
f0104813:	e9 32 ff ff ff       	jmp    f010474a <print_trapframe+0x96>
		cprintf(" [%s, %s, %s]\n",
f0104818:	b9 24 84 10 f0       	mov    $0xf0108424,%ecx
f010481d:	e9 55 ff ff ff       	jmp    f0104777 <print_trapframe+0xc3>
f0104822:	ba 3b 84 10 f0       	mov    $0xf010843b,%edx
f0104827:	e9 58 ff ff ff       	jmp    f0104784 <print_trapframe+0xd0>
f010482c:	b8 46 84 10 f0       	mov    $0xf0108446,%eax
f0104831:	e9 5b ff ff ff       	jmp    f0104791 <print_trapframe+0xdd>
		cprintf("\n");
f0104836:	83 ec 0c             	sub    $0xc,%esp
f0104839:	68 fb 71 10 f0       	push   $0xf01071fb
f010483e:	e8 41 f7 ff ff       	call   f0103f84 <cprintf>
f0104843:	83 c4 10             	add    $0x10,%esp
f0104846:	e9 56 ff ff ff       	jmp    f01047a1 <print_trapframe+0xed>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010484b:	83 ec 08             	sub    $0x8,%esp
f010484e:	ff 73 3c             	pushl  0x3c(%ebx)
f0104851:	68 fe 84 10 f0       	push   $0xf01084fe
f0104856:	e8 29 f7 ff ff       	call   f0103f84 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010485b:	83 c4 08             	add    $0x8,%esp
f010485e:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104862:	50                   	push   %eax
f0104863:	68 0d 85 10 f0       	push   $0xf010850d
f0104868:	e8 17 f7 ff ff       	call   f0103f84 <cprintf>
f010486d:	83 c4 10             	add    $0x10,%esp
}
f0104870:	e9 67 ff ff ff       	jmp    f01047dc <print_trapframe+0x128>

f0104875 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104875:	55                   	push   %ebp
f0104876:	89 e5                	mov    %esp,%ebp
f0104878:	57                   	push   %edi
f0104879:	56                   	push   %esi
f010487a:	53                   	push   %ebx
f010487b:	83 ec 1c             	sub    $0x1c,%esp
f010487e:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104881:	0f 20 d6             	mov    %cr2,%esi

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	uint16_t cs = tf->tf_cs;
	if ((cs & 0xFF) == GD_KT) { // code segment descriptor is kernel
f0104884:	80 7b 34 08          	cmpb   $0x8,0x34(%ebx)
f0104888:	0f 84 ad 00 00 00    	je     f010493b <page_fault_handler+0xc6>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').


	if (!curenv->env_pgfault_upcall) {
f010488e:	e8 8f 1e 00 00       	call   f0106722 <cpunum>
f0104893:	6b c0 74             	imul   $0x74,%eax,%eax
f0104896:	8b 80 28 80 2a f0    	mov    -0xfd57fd8(%eax),%eax
f010489c:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f01048a0:	0f 84 b3 00 00 00    	je     f0104959 <page_fault_handler+0xe4>
		print_trapframe(tf);
		env_destroy(curenv);
	}

	// Backup the current stack pointer.
	uintptr_t esp = tf->tf_esp;
f01048a6:	8b 4b 3c             	mov    0x3c(%ebx),%ecx
f01048a9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	
	// Get stack point to the right place.
	// Then, check whether the user can write memory there.
	// If not, curenv will be destroyed, and things are simpler.
	if (tf->tf_esp < UXSTACKTOP && tf->tf_esp >= UXSTACKTOP - PGSIZE) {
f01048ac:	8d 81 00 10 40 11    	lea    0x11401000(%ecx),%eax
f01048b2:	3d ff 0f 00 00       	cmp    $0xfff,%eax
f01048b7:	0f 87 e2 00 00 00    	ja     f010499f <page_fault_handler+0x12a>
		tf->tf_esp -= 4 + sizeof(struct UTrapframe);
f01048bd:	8d 79 c8             	lea    -0x38(%ecx),%edi
f01048c0:	89 7b 3c             	mov    %edi,0x3c(%ebx)
		user_mem_assert(curenv, (void*)tf->tf_esp, 4 + sizeof(struct UTrapframe), PTE_W | PTE_U);
f01048c3:	e8 5a 1e 00 00       	call   f0106722 <cpunum>
f01048c8:	6a 06                	push   $0x6
f01048ca:	6a 38                	push   $0x38
f01048cc:	57                   	push   %edi
f01048cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01048d0:	ff b0 28 80 2a f0    	pushl  -0xfd57fd8(%eax)
f01048d6:	e8 1b ec ff ff       	call   f01034f6 <user_mem_assert>
		// FIXME
		*((uint32_t*)esp - 1) = 0;  // We also set the int padding to 0.
f01048db:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01048de:	c7 41 fc 00 00 00 00 	movl   $0x0,-0x4(%ecx)
f01048e5:	83 c4 10             	add    $0x10,%esp
		tf->tf_esp = UXSTACKTOP - sizeof(struct UTrapframe);
		user_mem_assert(curenv, (void*)tf->tf_esp, sizeof(struct UTrapframe), PTE_W | PTE_U);
	}

	// Fill in UTrapframe data
	struct UTrapframe* utf = (struct UTrapframe*)tf->tf_esp;
f01048e8:	8b 43 3c             	mov    0x3c(%ebx),%eax
	utf->utf_fault_va = fault_va;
f01048eb:	89 30                	mov    %esi,(%eax)
	utf->utf_err = tf->tf_err;
f01048ed:	8b 53 2c             	mov    0x2c(%ebx),%edx
f01048f0:	89 50 04             	mov    %edx,0x4(%eax)
	utf->utf_regs = tf->tf_regs;
f01048f3:	8d 78 08             	lea    0x8(%eax),%edi
f01048f6:	b9 08 00 00 00       	mov    $0x8,%ecx
f01048fb:	89 de                	mov    %ebx,%esi
f01048fd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	utf->utf_eip = tf->tf_eip;
f01048ff:	8b 53 30             	mov    0x30(%ebx),%edx
f0104902:	89 50 28             	mov    %edx,0x28(%eax)
	utf->utf_eflags = tf->tf_eflags;
f0104905:	8b 53 38             	mov    0x38(%ebx),%edx
f0104908:	89 50 2c             	mov    %edx,0x2c(%eax)
	utf->utf_esp = esp;
f010490b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010490e:	89 78 30             	mov    %edi,0x30(%eax)

	// Modify trapframe so that upcall is triggered next.
	tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0104911:	e8 0c 1e 00 00       	call   f0106722 <cpunum>
f0104916:	6b c0 74             	imul   $0x74,%eax,%eax
f0104919:	8b 80 28 80 2a f0    	mov    -0xfd57fd8(%eax),%eax
f010491f:	8b 40 64             	mov    0x64(%eax),%eax
f0104922:	89 43 30             	mov    %eax,0x30(%ebx)

	// and then run the upcall.
	env_run(curenv);
f0104925:	e8 f8 1d 00 00       	call   f0106722 <cpunum>
f010492a:	83 ec 0c             	sub    $0xc,%esp
f010492d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104930:	ff b0 28 80 2a f0    	pushl  -0xfd57fd8(%eax)
f0104936:	e8 ca f3 ff ff       	call   f0103d05 <env_run>
		print_trapframe(tf);
f010493b:	83 ec 0c             	sub    $0xc,%esp
f010493e:	53                   	push   %ebx
f010493f:	e8 70 fd ff ff       	call   f01046b4 <print_trapframe>
		panic("Page fault in kernel mode! Fault addr: %p", fault_va);
f0104944:	56                   	push   %esi
f0104945:	68 c8 86 10 f0       	push   $0xf01086c8
f010494a:	68 5f 01 00 00       	push   $0x15f
f010494f:	68 20 85 10 f0       	push   $0xf0108520
f0104954:	e8 3b b7 ff ff       	call   f0100094 <_panic>
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104959:	8b 7b 30             	mov    0x30(%ebx),%edi
				curenv->env_id, fault_va, tf->tf_eip);
f010495c:	e8 c1 1d 00 00       	call   f0106722 <cpunum>
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104961:	57                   	push   %edi
f0104962:	56                   	push   %esi
				curenv->env_id, fault_va, tf->tf_eip);
f0104963:	6b c0 74             	imul   $0x74,%eax,%eax
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104966:	8b 80 28 80 2a f0    	mov    -0xfd57fd8(%eax),%eax
f010496c:	ff 70 48             	pushl  0x48(%eax)
f010496f:	68 f4 86 10 f0       	push   $0xf01086f4
f0104974:	e8 0b f6 ff ff       	call   f0103f84 <cprintf>
		print_trapframe(tf);
f0104979:	89 1c 24             	mov    %ebx,(%esp)
f010497c:	e8 33 fd ff ff       	call   f01046b4 <print_trapframe>
		env_destroy(curenv);
f0104981:	e8 9c 1d 00 00       	call   f0106722 <cpunum>
f0104986:	83 c4 04             	add    $0x4,%esp
f0104989:	6b c0 74             	imul   $0x74,%eax,%eax
f010498c:	ff b0 28 80 2a f0    	pushl  -0xfd57fd8(%eax)
f0104992:	e8 b1 f2 ff ff       	call   f0103c48 <env_destroy>
f0104997:	83 c4 10             	add    $0x10,%esp
f010499a:	e9 07 ff ff ff       	jmp    f01048a6 <page_fault_handler+0x31>
		tf->tf_esp = UXSTACKTOP - sizeof(struct UTrapframe);
f010499f:	c7 43 3c cc ff bf ee 	movl   $0xeebfffcc,0x3c(%ebx)
		user_mem_assert(curenv, (void*)tf->tf_esp, sizeof(struct UTrapframe), PTE_W | PTE_U);
f01049a6:	e8 77 1d 00 00       	call   f0106722 <cpunum>
f01049ab:	6a 06                	push   $0x6
f01049ad:	6a 34                	push   $0x34
f01049af:	68 cc ff bf ee       	push   $0xeebfffcc
f01049b4:	6b c0 74             	imul   $0x74,%eax,%eax
f01049b7:	ff b0 28 80 2a f0    	pushl  -0xfd57fd8(%eax)
f01049bd:	e8 34 eb ff ff       	call   f01034f6 <user_mem_assert>
f01049c2:	83 c4 10             	add    $0x10,%esp
f01049c5:	e9 1e ff ff ff       	jmp    f01048e8 <page_fault_handler+0x73>

f01049ca <trap>:
{
f01049ca:	55                   	push   %ebp
f01049cb:	89 e5                	mov    %esp,%ebp
f01049cd:	57                   	push   %edi
f01049ce:	56                   	push   %esi
f01049cf:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f01049d2:	fc                   	cld    
	if (panicstr)
f01049d3:	83 3d 80 7e 2a f0 00 	cmpl   $0x0,0xf02a7e80
f01049da:	74 01                	je     f01049dd <trap+0x13>
		asm volatile("hlt");
f01049dc:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01049dd:	e8 40 1d 00 00       	call   f0106722 <cpunum>
f01049e2:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01049e5:	01 c2                	add    %eax,%edx
f01049e7:	01 d2                	add    %edx,%edx
f01049e9:	01 c2                	add    %eax,%edx
f01049eb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01049ee:	8d 14 85 04 00 00 00 	lea    0x4(,%eax,4),%edx
	asm volatile("lock; xchgl %0, %1"
f01049f5:	b8 01 00 00 00       	mov    $0x1,%eax
f01049fa:	f0 87 82 20 80 2a f0 	lock xchg %eax,-0xfd57fe0(%edx)
f0104a01:	83 f8 02             	cmp    $0x2,%eax
f0104a04:	74 53                	je     f0104a59 <trap+0x8f>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104a06:	9c                   	pushf  
f0104a07:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f0104a08:	f6 c4 02             	test   $0x2,%ah
f0104a0b:	75 5e                	jne    f0104a6b <trap+0xa1>
	if ((tf->tf_cs & 3) == 3) {
f0104a0d:	66 8b 46 34          	mov    0x34(%esi),%ax
f0104a11:	83 e0 03             	and    $0x3,%eax
f0104a14:	66 83 f8 03          	cmp    $0x3,%ax
f0104a18:	74 6a                	je     f0104a84 <trap+0xba>
	last_tf = tf;
f0104a1a:	89 35 60 7a 2a f0    	mov    %esi,0xf02a7a60
	switch(tf->tf_trapno){
f0104a20:	8b 46 28             	mov    0x28(%esi),%eax
f0104a23:	83 f8 0e             	cmp    $0xe,%eax
f0104a26:	0f 84 fd 00 00 00    	je     f0104b29 <trap+0x15f>
f0104a2c:	83 f8 30             	cmp    $0x30,%eax
f0104a2f:	0f 84 fd 00 00 00    	je     f0104b32 <trap+0x168>
f0104a35:	83 f8 03             	cmp    $0x3,%eax
f0104a38:	0f 85 3d 01 00 00    	jne    f0104b7b <trap+0x1b1>
		print_trapframe(tf);
f0104a3e:	83 ec 0c             	sub    $0xc,%esp
f0104a41:	56                   	push   %esi
f0104a42:	e8 6d fc ff ff       	call   f01046b4 <print_trapframe>
f0104a47:	83 c4 10             	add    $0x10,%esp
			monitor(NULL);
f0104a4a:	83 ec 0c             	sub    $0xc,%esp
f0104a4d:	6a 00                	push   $0x0
f0104a4f:	e8 e4 c3 ff ff       	call   f0100e38 <monitor>
f0104a54:	83 c4 10             	add    $0x10,%esp
f0104a57:	eb f1                	jmp    f0104a4a <trap+0x80>
	spin_lock(&kernel_lock);
f0104a59:	83 ec 0c             	sub    $0xc,%esp
f0104a5c:	68 c0 33 12 f0       	push   $0xf01233c0
f0104a61:	e8 30 1f 00 00       	call   f0106996 <spin_lock>
f0104a66:	83 c4 10             	add    $0x10,%esp
f0104a69:	eb 9b                	jmp    f0104a06 <trap+0x3c>
	assert(!(read_eflags() & FL_IF));
f0104a6b:	68 2c 85 10 f0       	push   $0xf010852c
f0104a70:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0104a75:	68 2b 01 00 00       	push   $0x12b
f0104a7a:	68 20 85 10 f0       	push   $0xf0108520
f0104a7f:	e8 10 b6 ff ff       	call   f0100094 <_panic>
f0104a84:	83 ec 0c             	sub    $0xc,%esp
f0104a87:	68 c0 33 12 f0       	push   $0xf01233c0
f0104a8c:	e8 05 1f 00 00       	call   f0106996 <spin_lock>
		assert(curenv);
f0104a91:	e8 8c 1c 00 00       	call   f0106722 <cpunum>
f0104a96:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a99:	83 c4 10             	add    $0x10,%esp
f0104a9c:	83 b8 28 80 2a f0 00 	cmpl   $0x0,-0xfd57fd8(%eax)
f0104aa3:	74 3e                	je     f0104ae3 <trap+0x119>
		if (curenv->env_status == ENV_DYING) {
f0104aa5:	e8 78 1c 00 00       	call   f0106722 <cpunum>
f0104aaa:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aad:	8b 80 28 80 2a f0    	mov    -0xfd57fd8(%eax),%eax
f0104ab3:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104ab7:	74 43                	je     f0104afc <trap+0x132>
		curenv->env_tf = *tf;
f0104ab9:	e8 64 1c 00 00       	call   f0106722 <cpunum>
f0104abe:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ac1:	8b 80 28 80 2a f0    	mov    -0xfd57fd8(%eax),%eax
f0104ac7:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104acc:	89 c7                	mov    %eax,%edi
f0104ace:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0104ad0:	e8 4d 1c 00 00       	call   f0106722 <cpunum>
f0104ad5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ad8:	8b b0 28 80 2a f0    	mov    -0xfd57fd8(%eax),%esi
f0104ade:	e9 37 ff ff ff       	jmp    f0104a1a <trap+0x50>
		assert(curenv);
f0104ae3:	68 45 85 10 f0       	push   $0xf0108545
f0104ae8:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0104aed:	68 32 01 00 00       	push   $0x132
f0104af2:	68 20 85 10 f0       	push   $0xf0108520
f0104af7:	e8 98 b5 ff ff       	call   f0100094 <_panic>
			env_free(curenv);
f0104afc:	e8 21 1c 00 00       	call   f0106722 <cpunum>
f0104b01:	83 ec 0c             	sub    $0xc,%esp
f0104b04:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b07:	ff b0 28 80 2a f0    	pushl  -0xfd57fd8(%eax)
f0104b0d:	e8 71 ef ff ff       	call   f0103a83 <env_free>
			curenv = NULL;
f0104b12:	e8 0b 1c 00 00       	call   f0106722 <cpunum>
f0104b17:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b1a:	c7 80 28 80 2a f0 00 	movl   $0x0,-0xfd57fd8(%eax)
f0104b21:	00 00 00 
			sched_yield();
f0104b24:	e8 d5 02 00 00       	call   f0104dfe <sched_yield>
		page_fault_handler(tf);
f0104b29:	83 ec 0c             	sub    $0xc,%esp
f0104b2c:	56                   	push   %esi
f0104b2d:	e8 43 fd ff ff       	call   f0104875 <page_fault_handler>
		tf->tf_regs.reg_eax = syscall(
f0104b32:	83 ec 08             	sub    $0x8,%esp
f0104b35:	ff 76 04             	pushl  0x4(%esi)
f0104b38:	ff 36                	pushl  (%esi)
f0104b3a:	ff 76 10             	pushl  0x10(%esi)
f0104b3d:	ff 76 18             	pushl  0x18(%esi)
f0104b40:	ff 76 14             	pushl  0x14(%esi)
f0104b43:	ff 76 1c             	pushl  0x1c(%esi)
f0104b46:	e8 25 04 00 00       	call   f0104f70 <syscall>
f0104b4b:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104b4e:	83 c4 20             	add    $0x20,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104b51:	e8 cc 1b 00 00       	call   f0106722 <cpunum>
f0104b56:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b59:	83 b8 28 80 2a f0 00 	cmpl   $0x0,-0xfd57fd8(%eax)
f0104b60:	74 14                	je     f0104b76 <trap+0x1ac>
f0104b62:	e8 bb 1b 00 00       	call   f0106722 <cpunum>
f0104b67:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b6a:	8b 80 28 80 2a f0    	mov    -0xfd57fd8(%eax),%eax
f0104b70:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104b74:	74 78                	je     f0104bee <trap+0x224>
		sched_yield();
f0104b76:	e8 83 02 00 00       	call   f0104dfe <sched_yield>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104b7b:	83 f8 27             	cmp    $0x27,%eax
f0104b7e:	74 33                	je     f0104bb3 <trap+0x1e9>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) { 
f0104b80:	83 f8 20             	cmp    $0x20,%eax
f0104b83:	74 48                	je     f0104bcd <trap+0x203>
	print_trapframe(tf);
f0104b85:	83 ec 0c             	sub    $0xc,%esp
f0104b88:	56                   	push   %esi
f0104b89:	e8 26 fb ff ff       	call   f01046b4 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104b8e:	83 c4 10             	add    $0x10,%esp
f0104b91:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104b96:	74 3f                	je     f0104bd7 <trap+0x20d>
		env_destroy(curenv);
f0104b98:	e8 85 1b 00 00       	call   f0106722 <cpunum>
f0104b9d:	83 ec 0c             	sub    $0xc,%esp
f0104ba0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ba3:	ff b0 28 80 2a f0    	pushl  -0xfd57fd8(%eax)
f0104ba9:	e8 9a f0 ff ff       	call   f0103c48 <env_destroy>
f0104bae:	83 c4 10             	add    $0x10,%esp
f0104bb1:	eb 9e                	jmp    f0104b51 <trap+0x187>
		cprintf("Spurious interrupt on irq 7\n");
f0104bb3:	83 ec 0c             	sub    $0xc,%esp
f0104bb6:	68 4c 85 10 f0       	push   $0xf010854c
f0104bbb:	e8 c4 f3 ff ff       	call   f0103f84 <cprintf>
		print_trapframe(tf);
f0104bc0:	89 34 24             	mov    %esi,(%esp)
f0104bc3:	e8 ec fa ff ff       	call   f01046b4 <print_trapframe>
f0104bc8:	83 c4 10             	add    $0x10,%esp
f0104bcb:	eb 84                	jmp    f0104b51 <trap+0x187>
		lapic_eoi();
f0104bcd:	e8 a7 1c 00 00       	call   f0106879 <lapic_eoi>
		sched_yield();
f0104bd2:	e8 27 02 00 00       	call   f0104dfe <sched_yield>
		panic("unhandled trap in kernel");
f0104bd7:	83 ec 04             	sub    $0x4,%esp
f0104bda:	68 69 85 10 f0       	push   $0xf0108569
f0104bdf:	68 11 01 00 00       	push   $0x111
f0104be4:	68 20 85 10 f0       	push   $0xf0108520
f0104be9:	e8 a6 b4 ff ff       	call   f0100094 <_panic>
		env_run(curenv);
f0104bee:	e8 2f 1b 00 00       	call   f0106722 <cpunum>
f0104bf3:	83 ec 0c             	sub    $0xc,%esp
f0104bf6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bf9:	ff b0 28 80 2a f0    	pushl  -0xfd57fd8(%eax)
f0104bff:	e8 01 f1 ff ff       	call   f0103d05 <env_run>

f0104c04 <H_DIVIDE>:
	pushl $(num);							\
	jmp _alltraps

.text

TRAPHANDLER_NOEC(H_DIVIDE , T_DIVIDE)
f0104c04:	6a 00                	push   $0x0
f0104c06:	6a 00                	push   $0x0
f0104c08:	e9 f1 00 00 00       	jmp    f0104cfe <_alltraps>
f0104c0d:	90                   	nop

f0104c0e <H_DEBUG>:
TRAPHANDLER_NOEC(H_DEBUG  , T_DEBUG)
f0104c0e:	6a 00                	push   $0x0
f0104c10:	6a 01                	push   $0x1
f0104c12:	e9 e7 00 00 00       	jmp    f0104cfe <_alltraps>
f0104c17:	90                   	nop

f0104c18 <H_NMI>:
TRAPHANDLER_NOEC(H_NMI    , T_NMI)
f0104c18:	6a 00                	push   $0x0
f0104c1a:	6a 02                	push   $0x2
f0104c1c:	e9 dd 00 00 00       	jmp    f0104cfe <_alltraps>
f0104c21:	90                   	nop

f0104c22 <H_BRKPT>:
TRAPHANDLER_NOEC(H_BRKPT  , T_BRKPT)
f0104c22:	6a 00                	push   $0x0
f0104c24:	6a 03                	push   $0x3
f0104c26:	e9 d3 00 00 00       	jmp    f0104cfe <_alltraps>
f0104c2b:	90                   	nop

f0104c2c <H_OFLOW>:
TRAPHANDLER_NOEC(H_OFLOW  , T_OFLOW)
f0104c2c:	6a 00                	push   $0x0
f0104c2e:	6a 04                	push   $0x4
f0104c30:	e9 c9 00 00 00       	jmp    f0104cfe <_alltraps>
f0104c35:	90                   	nop

f0104c36 <H_BOUND>:
TRAPHANDLER_NOEC(H_BOUND  , T_BOUND)
f0104c36:	6a 00                	push   $0x0
f0104c38:	6a 05                	push   $0x5
f0104c3a:	e9 bf 00 00 00       	jmp    f0104cfe <_alltraps>
f0104c3f:	90                   	nop

f0104c40 <H_ILLOP>:
TRAPHANDLER_NOEC(H_ILLOP  , T_ILLOP)
f0104c40:	6a 00                	push   $0x0
f0104c42:	6a 06                	push   $0x6
f0104c44:	e9 b5 00 00 00       	jmp    f0104cfe <_alltraps>
f0104c49:	90                   	nop

f0104c4a <H_DEVICE>:
TRAPHANDLER_NOEC(H_DEVICE , T_DEVICE)
f0104c4a:	6a 00                	push   $0x0
f0104c4c:	6a 07                	push   $0x7
f0104c4e:	e9 ab 00 00 00       	jmp    f0104cfe <_alltraps>
f0104c53:	90                   	nop

f0104c54 <H_DBLFLT>:
TRAPHANDLER     (H_DBLFLT , T_DBLFLT)	// Error Code const 0
f0104c54:	6a 08                	push   $0x8
f0104c56:	e9 a3 00 00 00       	jmp    f0104cfe <_alltraps>
f0104c5b:	90                   	nop

f0104c5c <H_TSS>:
TRAPHANDLER     (H_TSS    , T_TSS)
f0104c5c:	6a 0a                	push   $0xa
f0104c5e:	e9 9b 00 00 00       	jmp    f0104cfe <_alltraps>
f0104c63:	90                   	nop

f0104c64 <H_SEGNP>:
TRAPHANDLER     (H_SEGNP  , T_SEGNP)
f0104c64:	6a 0b                	push   $0xb
f0104c66:	e9 93 00 00 00       	jmp    f0104cfe <_alltraps>
f0104c6b:	90                   	nop

f0104c6c <H_STACK>:
TRAPHANDLER     (H_STACK  , T_STACK)
f0104c6c:	6a 0c                	push   $0xc
f0104c6e:	e9 8b 00 00 00       	jmp    f0104cfe <_alltraps>
f0104c73:	90                   	nop

f0104c74 <H_GPFLT>:
TRAPHANDLER     (H_GPFLT  , T_GPFLT)
f0104c74:	6a 0d                	push   $0xd
f0104c76:	e9 83 00 00 00       	jmp    f0104cfe <_alltraps>
f0104c7b:	90                   	nop

f0104c7c <H_PGFLT>:
TRAPHANDLER     (H_PGFLT  , T_PGFLT)
f0104c7c:	6a 0e                	push   $0xe
f0104c7e:	eb 7e                	jmp    f0104cfe <_alltraps>

f0104c80 <H_FPERR>:
TRAPHANDLER_NOEC(H_FPERR  , T_FPERR)
f0104c80:	6a 00                	push   $0x0
f0104c82:	6a 10                	push   $0x10
f0104c84:	eb 78                	jmp    f0104cfe <_alltraps>

f0104c86 <H_ALIGN>:
TRAPHANDLER_NOEC(H_ALIGN  , T_ALIGN)
f0104c86:	6a 00                	push   $0x0
f0104c88:	6a 11                	push   $0x11
f0104c8a:	eb 72                	jmp    f0104cfe <_alltraps>

f0104c8c <H_MCHK>:
TRAPHANDLER_NOEC(H_MCHK   , T_MCHK)
f0104c8c:	6a 00                	push   $0x0
f0104c8e:	6a 12                	push   $0x12
f0104c90:	eb 6c                	jmp    f0104cfe <_alltraps>

f0104c92 <H_SIMDERR>:
TRAPHANDLER_NOEC(H_SIMDERR, T_SIMDERR)
f0104c92:	6a 00                	push   $0x0
f0104c94:	6a 13                	push   $0x13
f0104c96:	eb 66                	jmp    f0104cfe <_alltraps>

f0104c98 <H_SYSCALL>:

TRAPHANDLER_NOEC(H_SYSCALL, T_SYSCALL)  // System call.
f0104c98:	6a 00                	push   $0x0
f0104c9a:	6a 30                	push   $0x30
f0104c9c:	eb 60                	jmp    f0104cfe <_alltraps>

f0104c9e <H_TIMER>:

// IRQ 0 - 15
TRAPHANDLER_NOEC(H_TIMER,  IRQ_OFFSET + IRQ_TIMER)
f0104c9e:	6a 00                	push   $0x0
f0104ca0:	6a 20                	push   $0x20
f0104ca2:	eb 5a                	jmp    f0104cfe <_alltraps>

f0104ca4 <H_KBD>:
TRAPHANDLER_NOEC(H_KBD,    IRQ_OFFSET + IRQ_KBD)
f0104ca4:	6a 00                	push   $0x0
f0104ca6:	6a 21                	push   $0x21
f0104ca8:	eb 54                	jmp    f0104cfe <_alltraps>

f0104caa <H_IRQ2>:
TRAPHANDLER_NOEC(H_IRQ2,   IRQ_OFFSET + 2)
f0104caa:	6a 00                	push   $0x0
f0104cac:	6a 22                	push   $0x22
f0104cae:	eb 4e                	jmp    f0104cfe <_alltraps>

f0104cb0 <H_IRQ3>:
TRAPHANDLER_NOEC(H_IRQ3,   IRQ_OFFSET + 3)
f0104cb0:	6a 00                	push   $0x0
f0104cb2:	6a 23                	push   $0x23
f0104cb4:	eb 48                	jmp    f0104cfe <_alltraps>

f0104cb6 <H_SERIAL>:
TRAPHANDLER_NOEC(H_SERIAL, IRQ_OFFSET + IRQ_SERIAL)
f0104cb6:	6a 00                	push   $0x0
f0104cb8:	6a 24                	push   $0x24
f0104cba:	eb 42                	jmp    f0104cfe <_alltraps>

f0104cbc <H_IRQ5>:
TRAPHANDLER_NOEC(H_IRQ5,   IRQ_OFFSET + 5)
f0104cbc:	6a 00                	push   $0x0
f0104cbe:	6a 25                	push   $0x25
f0104cc0:	eb 3c                	jmp    f0104cfe <_alltraps>

f0104cc2 <H_IRQ6>:
TRAPHANDLER_NOEC(H_IRQ6,   IRQ_OFFSET + 6)
f0104cc2:	6a 00                	push   $0x0
f0104cc4:	6a 26                	push   $0x26
f0104cc6:	eb 36                	jmp    f0104cfe <_alltraps>

f0104cc8 <H_SPUR>:
TRAPHANDLER_NOEC(H_SPUR,   IRQ_OFFSET + IRQ_SPURIOUS)
f0104cc8:	6a 00                	push   $0x0
f0104cca:	6a 27                	push   $0x27
f0104ccc:	eb 30                	jmp    f0104cfe <_alltraps>

f0104cce <H_IRQ8>:
TRAPHANDLER_NOEC(H_IRQ8,   IRQ_OFFSET + 8)
f0104cce:	6a 00                	push   $0x0
f0104cd0:	6a 28                	push   $0x28
f0104cd2:	eb 2a                	jmp    f0104cfe <_alltraps>

f0104cd4 <H_IRQ9>:
TRAPHANDLER_NOEC(H_IRQ9,   IRQ_OFFSET + 9)
f0104cd4:	6a 00                	push   $0x0
f0104cd6:	6a 29                	push   $0x29
f0104cd8:	eb 24                	jmp    f0104cfe <_alltraps>

f0104cda <H_IRQ10>:
TRAPHANDLER_NOEC(H_IRQ10,  IRQ_OFFSET + 10)
f0104cda:	6a 00                	push   $0x0
f0104cdc:	6a 2a                	push   $0x2a
f0104cde:	eb 1e                	jmp    f0104cfe <_alltraps>

f0104ce0 <H_IRQ11>:
TRAPHANDLER_NOEC(H_IRQ11,  IRQ_OFFSET + 11)
f0104ce0:	6a 00                	push   $0x0
f0104ce2:	6a 2b                	push   $0x2b
f0104ce4:	eb 18                	jmp    f0104cfe <_alltraps>

f0104ce6 <H_IRQ12>:
TRAPHANDLER_NOEC(H_IRQ12,  IRQ_OFFSET + 12)
f0104ce6:	6a 00                	push   $0x0
f0104ce8:	6a 2c                	push   $0x2c
f0104cea:	eb 12                	jmp    f0104cfe <_alltraps>

f0104cec <H_IRQ13>:
TRAPHANDLER_NOEC(H_IRQ13,  IRQ_OFFSET + 13)
f0104cec:	6a 00                	push   $0x0
f0104cee:	6a 2d                	push   $0x2d
f0104cf0:	eb 0c                	jmp    f0104cfe <_alltraps>

f0104cf2 <H_IDE>:
TRAPHANDLER_NOEC(H_IDE,    IRQ_OFFSET + IRQ_IDE)
f0104cf2:	6a 00                	push   $0x0
f0104cf4:	6a 2e                	push   $0x2e
f0104cf6:	eb 06                	jmp    f0104cfe <_alltraps>

f0104cf8 <H_IRQ15>:
TRAPHANDLER_NOEC(H_IRQ15,  IRQ_OFFSET + 15)
f0104cf8:	6a 00                	push   $0x0
f0104cfa:	6a 2f                	push   $0x2f
f0104cfc:	eb 00                	jmp    f0104cfe <_alltraps>

f0104cfe <_alltraps>:

_alltraps:
/* Processor has pushed ss, esp, eflags, cs, eip, and [error] */
/* TRAPHANDLER did [error] and trapno */
	pushl  %ds;
f0104cfe:	1e                   	push   %ds
	pushl  %es;
f0104cff:	06                   	push   %es
	pushal;
f0104d00:	60                   	pusha  
	movw   $GD_KD, %ax;
f0104d01:	66 b8 10 00          	mov    $0x10,%ax
	movw   %ax   , %ds;
f0104d05:	8e d8                	mov    %eax,%ds
	movw   %ax   , %es;
f0104d07:	8e c0                	mov    %eax,%es
	pushl  %esp;
f0104d09:	54                   	push   %esp
	call   trap
f0104d0a:	e8 bb fc ff ff       	call   f01049ca <trap>

f0104d0f <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104d0f:	55                   	push   %ebp
f0104d10:	89 e5                	mov    %esp,%ebp
f0104d12:	83 ec 08             	sub    $0x8,%esp
f0104d15:	a1 48 72 2a f0       	mov    0xf02a7248,%eax
f0104d1a:	83 c0 54             	add    $0x54,%eax
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104d1d:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104d22:	8b 10                	mov    (%eax),%edx
f0104d24:	4a                   	dec    %edx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104d25:	83 fa 02             	cmp    $0x2,%edx
f0104d28:	76 2b                	jbe    f0104d55 <sched_halt+0x46>
	for (i = 0; i < NENV; i++) {
f0104d2a:	41                   	inc    %ecx
f0104d2b:	83 c0 7c             	add    $0x7c,%eax
f0104d2e:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104d34:	75 ec                	jne    f0104d22 <sched_halt+0x13>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f0104d36:	83 ec 0c             	sub    $0xc,%esp
f0104d39:	68 70 87 10 f0       	push   $0xf0108770
f0104d3e:	e8 41 f2 ff ff       	call   f0103f84 <cprintf>
f0104d43:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104d46:	83 ec 0c             	sub    $0xc,%esp
f0104d49:	6a 00                	push   $0x0
f0104d4b:	e8 e8 c0 ff ff       	call   f0100e38 <monitor>
f0104d50:	83 c4 10             	add    $0x10,%esp
f0104d53:	eb f1                	jmp    f0104d46 <sched_halt+0x37>
	if (i == NENV) {
f0104d55:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104d5b:	74 d9                	je     f0104d36 <sched_halt+0x27>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104d5d:	e8 c0 19 00 00       	call   f0106722 <cpunum>
f0104d62:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104d65:	01 c2                	add    %eax,%edx
f0104d67:	01 d2                	add    %edx,%edx
f0104d69:	01 c2                	add    %eax,%edx
f0104d6b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104d6e:	c7 04 85 28 80 2a f0 	movl   $0x0,-0xfd57fd8(,%eax,4)
f0104d75:	00 00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104d79:	a1 8c 7e 2a f0       	mov    0xf02a7e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0104d7e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104d83:	76 67                	jbe    f0104dec <sched_halt+0xdd>
	return (physaddr_t)kva - KERNBASE;
f0104d85:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104d8a:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104d8d:	e8 90 19 00 00       	call   f0106722 <cpunum>
f0104d92:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104d95:	01 c2                	add    %eax,%edx
f0104d97:	01 d2                	add    %edx,%edx
f0104d99:	01 c2                	add    %eax,%edx
f0104d9b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104d9e:	8d 14 85 04 00 00 00 	lea    0x4(,%eax,4),%edx
	asm volatile("lock; xchgl %0, %1"
f0104da5:	b8 02 00 00 00       	mov    $0x2,%eax
f0104daa:	f0 87 82 20 80 2a f0 	lock xchg %eax,-0xfd57fe0(%edx)
	spin_unlock(&kernel_lock);
f0104db1:	83 ec 0c             	sub    $0xc,%esp
f0104db4:	68 c0 33 12 f0       	push   $0xf01233c0
f0104db9:	e8 85 1c 00 00       	call   f0106a43 <spin_unlock>
	asm volatile("pause");
f0104dbe:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104dc0:	e8 5d 19 00 00       	call   f0106722 <cpunum>
f0104dc5:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104dc8:	01 c2                	add    %eax,%edx
f0104dca:	01 d2                	add    %edx,%edx
f0104dcc:	01 c2                	add    %eax,%edx
f0104dce:	8d 04 90             	lea    (%eax,%edx,4),%eax
	asm volatile (
f0104dd1:	8b 04 85 30 80 2a f0 	mov    -0xfd57fd0(,%eax,4),%eax
f0104dd8:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104ddd:	89 c4                	mov    %eax,%esp
f0104ddf:	6a 00                	push   $0x0
f0104de1:	6a 00                	push   $0x0
f0104de3:	fb                   	sti    
f0104de4:	f4                   	hlt    
f0104de5:	eb fd                	jmp    f0104de4 <sched_halt+0xd5>
}
f0104de7:	83 c4 10             	add    $0x10,%esp
f0104dea:	c9                   	leave  
f0104deb:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104dec:	50                   	push   %eax
f0104ded:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0104df2:	6a 53                	push   $0x53
f0104df4:	68 99 87 10 f0       	push   $0xf0108799
f0104df9:	e8 96 b2 ff ff       	call   f0100094 <_panic>

f0104dfe <sched_yield>:
{
f0104dfe:	55                   	push   %ebp
f0104dff:	89 e5                	mov    %esp,%ebp
f0104e01:	53                   	push   %ebx
f0104e02:	83 ec 04             	sub    $0x4,%esp
	if (!curenv) { 
f0104e05:	e8 18 19 00 00       	call   f0106722 <cpunum>
f0104e0a:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104e0d:	01 c2                	add    %eax,%edx
f0104e0f:	01 d2                	add    %edx,%edx
f0104e11:	01 c2                	add    %eax,%edx
f0104e13:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e16:	83 3c 85 28 80 2a f0 	cmpl   $0x0,-0xfd57fd8(,%eax,4)
f0104e1d:	00 
f0104e1e:	74 29                	je     f0104e49 <sched_yield+0x4b>
		for (idle = curenv + 1; idle < envs + NENV; idle++)
f0104e20:	e8 fd 18 00 00       	call   f0106722 <cpunum>
f0104e25:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104e28:	01 c2                	add    %eax,%edx
f0104e2a:	01 d2                	add    %edx,%edx
f0104e2c:	01 c2                	add    %eax,%edx
f0104e2e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e31:	8b 04 85 28 80 2a f0 	mov    -0xfd57fd8(,%eax,4),%eax
f0104e38:	83 c0 7c             	add    $0x7c,%eax
f0104e3b:	8b 1d 48 72 2a f0    	mov    0xf02a7248,%ebx
f0104e41:	8d 93 00 f0 01 00    	lea    0x1f000(%ebx),%edx
f0104e47:	eb 26                	jmp    f0104e6f <sched_yield+0x71>
		for (idle = envs; idle < envs + NENV; idle++)
f0104e49:	a1 48 72 2a f0       	mov    0xf02a7248,%eax
f0104e4e:	8d 90 00 f0 01 00    	lea    0x1f000(%eax),%edx
f0104e54:	39 d0                	cmp    %edx,%eax
f0104e56:	74 76                	je     f0104ece <sched_yield+0xd0>
			if (idle->env_status == ENV_RUNNABLE)
f0104e58:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104e5c:	74 05                	je     f0104e63 <sched_yield+0x65>
		for (idle = envs; idle < envs + NENV; idle++)
f0104e5e:	83 c0 7c             	add    $0x7c,%eax
f0104e61:	eb f1                	jmp    f0104e54 <sched_yield+0x56>
				env_run(idle); // Will not return
f0104e63:	83 ec 0c             	sub    $0xc,%esp
f0104e66:	50                   	push   %eax
f0104e67:	e8 99 ee ff ff       	call   f0103d05 <env_run>
		for (idle = curenv + 1; idle < envs + NENV; idle++)
f0104e6c:	83 c0 7c             	add    $0x7c,%eax
f0104e6f:	39 c2                	cmp    %eax,%edx
f0104e71:	76 18                	jbe    f0104e8b <sched_yield+0x8d>
			if (idle->env_status == ENV_RUNNABLE)
f0104e73:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104e77:	75 f3                	jne    f0104e6c <sched_yield+0x6e>
				env_run(idle); 
f0104e79:	83 ec 0c             	sub    $0xc,%esp
f0104e7c:	50                   	push   %eax
f0104e7d:	e8 83 ee ff ff       	call   f0103d05 <env_run>
				env_run(idle);
f0104e82:	83 ec 0c             	sub    $0xc,%esp
f0104e85:	53                   	push   %ebx
f0104e86:	e8 7a ee ff ff       	call   f0103d05 <env_run>
		for (idle = envs; idle < curenv ; idle++)
f0104e8b:	e8 92 18 00 00       	call   f0106722 <cpunum>
f0104e90:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104e93:	01 c2                	add    %eax,%edx
f0104e95:	01 d2                	add    %edx,%edx
f0104e97:	01 c2                	add    %eax,%edx
f0104e99:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e9c:	39 1c 85 28 80 2a f0 	cmp    %ebx,-0xfd57fd8(,%eax,4)
f0104ea3:	76 0b                	jbe    f0104eb0 <sched_yield+0xb2>
			if (idle->env_status == ENV_RUNNABLE)
f0104ea5:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f0104ea9:	74 d7                	je     f0104e82 <sched_yield+0x84>
		for (idle = envs; idle < curenv ; idle++)
f0104eab:	83 c3 7c             	add    $0x7c,%ebx
f0104eae:	eb db                	jmp    f0104e8b <sched_yield+0x8d>
		if (curenv->env_status == ENV_RUNNING)
f0104eb0:	e8 6d 18 00 00       	call   f0106722 <cpunum>
f0104eb5:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104eb8:	01 c2                	add    %eax,%edx
f0104eba:	01 d2                	add    %edx,%edx
f0104ebc:	01 c2                	add    %eax,%edx
f0104ebe:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ec1:	8b 04 85 28 80 2a f0 	mov    -0xfd57fd8(,%eax,4),%eax
f0104ec8:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104ecc:	74 0a                	je     f0104ed8 <sched_yield+0xda>
	sched_halt();
f0104ece:	e8 3c fe ff ff       	call   f0104d0f <sched_halt>
}
f0104ed3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104ed6:	c9                   	leave  
f0104ed7:	c3                   	ret    
			env_run(curenv);
f0104ed8:	e8 45 18 00 00       	call   f0106722 <cpunum>
f0104edd:	83 ec 0c             	sub    $0xc,%esp
f0104ee0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ee3:	ff b0 28 80 2a f0    	pushl  -0xfd57fd8(%eax)
f0104ee9:	e8 17 ee ff ff       	call   f0103d05 <env_run>

f0104eee <sys_ipc_recv>:
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
int
sys_ipc_recv(void *dstva)
{
f0104eee:	55                   	push   %ebp
f0104eef:	89 e5                	mov    %esp,%ebp
f0104ef1:	53                   	push   %ebx
f0104ef2:	83 ec 04             	sub    $0x4,%esp
f0104ef5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// Willing to receive information.
	curenv->env_ipc_recving = true; 
f0104ef8:	e8 25 18 00 00       	call   f0106722 <cpunum>
f0104efd:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104f00:	01 c2                	add    %eax,%edx
f0104f02:	01 d2                	add    %edx,%edx
f0104f04:	01 c2                	add    %eax,%edx
f0104f06:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104f09:	8b 04 85 28 80 2a f0 	mov    -0xfd57fd8(,%eax,4),%eax
f0104f10:	c6 40 68 01          	movb   $0x1,0x68(%eax)

	// If willing to receive page but not aligned
	if ((uintptr_t)dstva < UTOP && (uintptr_t)dstva % PGSIZE) 
f0104f14:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0104f1a:	77 08                	ja     f0104f24 <sys_ipc_recv+0x36>
f0104f1c:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f0104f22:	75 45                	jne    f0104f69 <sys_ipc_recv+0x7b>
		return -E_INVAL;
	// No matter we want to get page or not, 
	// this statement is ok.
	curenv->env_ipc_dstva = dstva; 
f0104f24:	e8 f9 17 00 00       	call   f0106722 <cpunum>
f0104f29:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104f2c:	01 c2                	add    %eax,%edx
f0104f2e:	01 d2                	add    %edx,%edx
f0104f30:	01 c2                	add    %eax,%edx
f0104f32:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104f35:	8b 04 85 28 80 2a f0 	mov    -0xfd57fd8(,%eax,4),%eax
f0104f3c:	89 58 6c             	mov    %ebx,0x6c(%eax)

	// Mark not-runnable. Don't run until we receive something.
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104f3f:	e8 de 17 00 00       	call   f0106722 <cpunum>
f0104f44:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104f47:	01 c2                	add    %eax,%edx
f0104f49:	01 d2                	add    %edx,%edx
f0104f4b:	01 c2                	add    %eax,%edx
f0104f4d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104f50:	8b 04 85 28 80 2a f0 	mov    -0xfd57fd8(,%eax,4),%eax
f0104f57:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	// There used to be a yield here, which is wrong.
	// When the env is continued, it will (surely) not be running 
	// from here, since this is kernel code. 
	// sched_yield();

	return 0;
f0104f5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104f63:	83 c4 04             	add    $0x4,%esp
f0104f66:	5b                   	pop    %ebx
f0104f67:	5d                   	pop    %ebp
f0104f68:	c3                   	ret    
		return -E_INVAL;
f0104f69:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f6e:	eb f3                	jmp    f0104f63 <sys_ipc_recv+0x75>

f0104f70 <syscall>:

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104f70:	55                   	push   %ebp
f0104f71:	89 e5                	mov    %esp,%ebp
f0104f73:	56                   	push   %esi
f0104f74:	53                   	push   %ebx
f0104f75:	83 ec 20             	sub    $0x20,%esp
f0104f78:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	switch (syscallno) {
f0104f7b:	83 f8 0d             	cmp    $0xd,%eax
f0104f7e:	0f 87 7d 05 00 00    	ja     f0105501 <syscall+0x591>
f0104f84:	ff 24 85 08 88 10 f0 	jmp    *-0xfef77f8(,%eax,4)
	user_mem_assert(curenv, s, len, PTE_U);  // The memory is readable.
f0104f8b:	e8 92 17 00 00       	call   f0106722 <cpunum>
f0104f90:	6a 04                	push   $0x4
f0104f92:	ff 75 10             	pushl  0x10(%ebp)
f0104f95:	ff 75 0c             	pushl  0xc(%ebp)
f0104f98:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104f9b:	01 c2                	add    %eax,%edx
f0104f9d:	01 d2                	add    %edx,%edx
f0104f9f:	01 c2                	add    %eax,%edx
f0104fa1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104fa4:	ff 34 85 28 80 2a f0 	pushl  -0xfd57fd8(,%eax,4)
f0104fab:	e8 46 e5 ff ff       	call   f01034f6 <user_mem_assert>
	cprintf("%.*s", len, s);
f0104fb0:	83 c4 0c             	add    $0xc,%esp
f0104fb3:	ff 75 0c             	pushl  0xc(%ebp)
f0104fb6:	ff 75 10             	pushl  0x10(%ebp)
f0104fb9:	68 a6 87 10 f0       	push   $0xf01087a6
f0104fbe:	e8 c1 ef ff ff       	call   f0103f84 <cprintf>
f0104fc3:	83 c4 10             	add    $0x10,%esp
	case SYS_cputs:
		sys_cputs((const char*)a1, a2);
		return 0;
f0104fc6:	bb 00 00 00 00       	mov    $0x0,%ebx
	case SYS_ipc_recv:
		return sys_ipc_recv((void*)a1);
	default:
		return -E_INVAL;
	}
}
f0104fcb:	89 d8                	mov    %ebx,%eax
f0104fcd:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104fd0:	5b                   	pop    %ebx
f0104fd1:	5e                   	pop    %esi
f0104fd2:	5d                   	pop    %ebp
f0104fd3:	c3                   	ret    
	return cons_getc();
f0104fd4:	e8 f9 b6 ff ff       	call   f01006d2 <cons_getc>
f0104fd9:	89 c3                	mov    %eax,%ebx
		return sys_cgetc();
f0104fdb:	eb ee                	jmp    f0104fcb <syscall+0x5b>
	return curenv->env_id;
f0104fdd:	e8 40 17 00 00       	call   f0106722 <cpunum>
f0104fe2:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104fe5:	01 c2                	add    %eax,%edx
f0104fe7:	01 d2                	add    %edx,%edx
f0104fe9:	01 c2                	add    %eax,%edx
f0104feb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104fee:	8b 04 85 28 80 2a f0 	mov    -0xfd57fd8(,%eax,4),%eax
f0104ff5:	8b 58 48             	mov    0x48(%eax),%ebx
		return sys_getenvid();
f0104ff8:	eb d1                	jmp    f0104fcb <syscall+0x5b>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104ffa:	83 ec 04             	sub    $0x4,%esp
f0104ffd:	6a 01                	push   $0x1
f0104fff:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105002:	50                   	push   %eax
f0105003:	ff 75 0c             	pushl  0xc(%ebp)
f0105006:	e8 37 e5 ff ff       	call   f0103542 <envid2env>
f010500b:	89 c3                	mov    %eax,%ebx
f010500d:	83 c4 10             	add    $0x10,%esp
f0105010:	85 c0                	test   %eax,%eax
f0105012:	78 b7                	js     f0104fcb <syscall+0x5b>
	if (e == curenv)
f0105014:	e8 09 17 00 00       	call   f0106722 <cpunum>
f0105019:	8b 4d f4             	mov    -0xc(%ebp),%ecx
f010501c:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010501f:	01 c2                	add    %eax,%edx
f0105021:	01 d2                	add    %edx,%edx
f0105023:	01 c2                	add    %eax,%edx
f0105025:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105028:	39 0c 85 28 80 2a f0 	cmp    %ecx,-0xfd57fd8(,%eax,4)
f010502f:	74 47                	je     f0105078 <syscall+0x108>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0105031:	8b 59 48             	mov    0x48(%ecx),%ebx
f0105034:	e8 e9 16 00 00       	call   f0106722 <cpunum>
f0105039:	83 ec 04             	sub    $0x4,%esp
f010503c:	53                   	push   %ebx
f010503d:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0105040:	01 c2                	add    %eax,%edx
f0105042:	01 d2                	add    %edx,%edx
f0105044:	01 c2                	add    %eax,%edx
f0105046:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105049:	8b 04 85 28 80 2a f0 	mov    -0xfd57fd8(,%eax,4),%eax
f0105050:	ff 70 48             	pushl  0x48(%eax)
f0105053:	68 c6 87 10 f0       	push   $0xf01087c6
f0105058:	e8 27 ef ff ff       	call   f0103f84 <cprintf>
f010505d:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0105060:	83 ec 0c             	sub    $0xc,%esp
f0105063:	ff 75 f4             	pushl  -0xc(%ebp)
f0105066:	e8 dd eb ff ff       	call   f0103c48 <env_destroy>
f010506b:	83 c4 10             	add    $0x10,%esp
	return 0;
f010506e:	bb 00 00 00 00       	mov    $0x0,%ebx
		return sys_env_destroy(a1);
f0105073:	e9 53 ff ff ff       	jmp    f0104fcb <syscall+0x5b>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0105078:	e8 a5 16 00 00       	call   f0106722 <cpunum>
f010507d:	83 ec 08             	sub    $0x8,%esp
f0105080:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0105083:	01 c2                	add    %eax,%edx
f0105085:	01 d2                	add    %edx,%edx
f0105087:	01 c2                	add    %eax,%edx
f0105089:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010508c:	8b 04 85 28 80 2a f0 	mov    -0xfd57fd8(,%eax,4),%eax
f0105093:	ff 70 48             	pushl  0x48(%eax)
f0105096:	68 ab 87 10 f0       	push   $0xf01087ab
f010509b:	e8 e4 ee ff ff       	call   f0103f84 <cprintf>
f01050a0:	83 c4 10             	add    $0x10,%esp
f01050a3:	eb bb                	jmp    f0105060 <syscall+0xf0>
	int r = envid2env(envid, &to_env, 1);  // 1 - Check perm
f01050a5:	83 ec 04             	sub    $0x4,%esp
f01050a8:	6a 01                	push   $0x1
f01050aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01050ad:	50                   	push   %eax
f01050ae:	ff 75 0c             	pushl  0xc(%ebp)
f01050b1:	e8 8c e4 ff ff       	call   f0103542 <envid2env>
f01050b6:	89 c3                	mov    %eax,%ebx
	if (r)  // -E_BAD_ENV
f01050b8:	83 c4 10             	add    $0x10,%esp
f01050bb:	85 c0                	test   %eax,%eax
f01050bd:	0f 85 08 ff ff ff    	jne    f0104fcb <syscall+0x5b>
	if ((uintptr_t)va >= UTOP || (uintptr_t)va % PGSIZE)
f01050c3:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01050ca:	77 59                	ja     f0105125 <syscall+0x1b5>
f01050cc:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01050d3:	75 5a                	jne    f010512f <syscall+0x1bf>
	if (~PTE_SYSCALL & perm) 
f01050d5:	f7 45 14 f8 f1 ff ff 	testl  $0xfffff1f8,0x14(%ebp)
f01050dc:	75 5b                	jne    f0105139 <syscall+0x1c9>
	perm |= PTE_U | PTE_P;
f01050de:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01050e1:	83 cb 05             	or     $0x5,%ebx
	struct PageInfo* pp = page_alloc(1);
f01050e4:	83 ec 0c             	sub    $0xc,%esp
f01050e7:	6a 01                	push   $0x1
f01050e9:	e8 0e c3 ff ff       	call   f01013fc <page_alloc>
f01050ee:	89 c6                	mov    %eax,%esi
	if (!pp)  // No free memory
f01050f0:	83 c4 10             	add    $0x10,%esp
f01050f3:	85 c0                	test   %eax,%eax
f01050f5:	74 4c                	je     f0105143 <syscall+0x1d3>
	r = page_insert(to_env->env_pgdir, pp, va, perm);
f01050f7:	53                   	push   %ebx
f01050f8:	ff 75 10             	pushl  0x10(%ebp)
f01050fb:	50                   	push   %eax
f01050fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01050ff:	ff 70 60             	pushl  0x60(%eax)
f0105102:	e8 4e c6 ff ff       	call   f0101755 <page_insert>
f0105107:	89 c3                	mov    %eax,%ebx
	if (r) 
f0105109:	83 c4 10             	add    $0x10,%esp
f010510c:	85 c0                	test   %eax,%eax
f010510e:	0f 84 b7 fe ff ff    	je     f0104fcb <syscall+0x5b>
		page_free(pp);
f0105114:	83 ec 0c             	sub    $0xc,%esp
f0105117:	56                   	push   %esi
f0105118:	e8 51 c3 ff ff       	call   f010146e <page_free>
f010511d:	83 c4 10             	add    $0x10,%esp
f0105120:	e9 a6 fe ff ff       	jmp    f0104fcb <syscall+0x5b>
		return -E_INVAL;
f0105125:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010512a:	e9 9c fe ff ff       	jmp    f0104fcb <syscall+0x5b>
f010512f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105134:	e9 92 fe ff ff       	jmp    f0104fcb <syscall+0x5b>
		return -E_INVAL;
f0105139:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010513e:	e9 88 fe ff ff       	jmp    f0104fcb <syscall+0x5b>
		return -E_NO_MEM;
f0105143:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
		return sys_page_alloc(a1, (void*)a2, a3);
f0105148:	e9 7e fe ff ff       	jmp    f0104fcb <syscall+0x5b>
	r = envid2env(srcenvid, &from_env, 1);  // 1 - Check perm
f010514d:	83 ec 04             	sub    $0x4,%esp
f0105150:	6a 01                	push   $0x1
f0105152:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105155:	50                   	push   %eax
f0105156:	ff 75 0c             	pushl  0xc(%ebp)
f0105159:	e8 e4 e3 ff ff       	call   f0103542 <envid2env>
f010515e:	89 c3                	mov    %eax,%ebx
	if (r)  return r;
f0105160:	83 c4 10             	add    $0x10,%esp
f0105163:	85 c0                	test   %eax,%eax
f0105165:	0f 85 60 fe ff ff    	jne    f0104fcb <syscall+0x5b>
	r = envid2env(dstenvid, &to_env, 1);  // 1 - Check perm
f010516b:	83 ec 04             	sub    $0x4,%esp
f010516e:	6a 01                	push   $0x1
f0105170:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0105173:	50                   	push   %eax
f0105174:	ff 75 14             	pushl  0x14(%ebp)
f0105177:	e8 c6 e3 ff ff       	call   f0103542 <envid2env>
f010517c:	89 c3                	mov    %eax,%ebx
	if (r)  return r;
f010517e:	83 c4 10             	add    $0x10,%esp
f0105181:	85 c0                	test   %eax,%eax
f0105183:	0f 85 42 fe ff ff    	jne    f0104fcb <syscall+0x5b>
	if (
f0105189:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105190:	77 6a                	ja     f01051fc <syscall+0x28c>
		((uintptr_t)srcva >= UTOP || (uintptr_t)srcva % PGSIZE) || 
f0105192:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0105199:	75 6b                	jne    f0105206 <syscall+0x296>
f010519b:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01051a2:	77 6c                	ja     f0105210 <syscall+0x2a0>
		((uintptr_t)dstva >= UTOP || (uintptr_t)dstva % PGSIZE))
f01051a4:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f01051ab:	75 6d                	jne    f010521a <syscall+0x2aa>
	if (~PTE_SYSCALL & perm)
f01051ad:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f01051b4:	75 6e                	jne    f0105224 <syscall+0x2b4>
	perm |= PTE_U | PTE_P;
f01051b6:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
f01051b9:	83 cb 05             	or     $0x5,%ebx
	struct PageInfo* pp = page_lookup(from_env->env_pgdir, srcva, &src_pgt);
f01051bc:	83 ec 04             	sub    $0x4,%esp
f01051bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01051c2:	50                   	push   %eax
f01051c3:	ff 75 10             	pushl  0x10(%ebp)
f01051c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01051c9:	ff 70 60             	pushl  0x60(%eax)
f01051cc:	e8 7b c4 ff ff       	call   f010164c <page_lookup>
	if ((~*src_pgt & PTE_W) && (perm & PTE_W))
f01051d1:	83 c4 10             	add    $0x10,%esp
f01051d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01051d7:	f6 02 02             	testb  $0x2,(%edx)
f01051da:	75 06                	jne    f01051e2 <syscall+0x272>
f01051dc:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01051e0:	75 4c                	jne    f010522e <syscall+0x2be>
	r = page_insert(to_env->env_pgdir, pp, dstva, perm);
f01051e2:	53                   	push   %ebx
f01051e3:	ff 75 18             	pushl  0x18(%ebp)
f01051e6:	50                   	push   %eax
f01051e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01051ea:	ff 70 60             	pushl  0x60(%eax)
f01051ed:	e8 63 c5 ff ff       	call   f0101755 <page_insert>
f01051f2:	89 c3                	mov    %eax,%ebx
f01051f4:	83 c4 10             	add    $0x10,%esp
f01051f7:	e9 cf fd ff ff       	jmp    f0104fcb <syscall+0x5b>
		return -E_INVAL;
f01051fc:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105201:	e9 c5 fd ff ff       	jmp    f0104fcb <syscall+0x5b>
f0105206:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010520b:	e9 bb fd ff ff       	jmp    f0104fcb <syscall+0x5b>
f0105210:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105215:	e9 b1 fd ff ff       	jmp    f0104fcb <syscall+0x5b>
f010521a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010521f:	e9 a7 fd ff ff       	jmp    f0104fcb <syscall+0x5b>
		return -E_INVAL;
f0105224:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105229:	e9 9d fd ff ff       	jmp    f0104fcb <syscall+0x5b>
		return -E_INVAL;
f010522e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
f0105233:	e9 93 fd ff ff       	jmp    f0104fcb <syscall+0x5b>
	int r = envid2env(envid, &to_env, 1);  // 1 - Check perm
f0105238:	83 ec 04             	sub    $0x4,%esp
f010523b:	6a 01                	push   $0x1
f010523d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105240:	50                   	push   %eax
f0105241:	ff 75 0c             	pushl  0xc(%ebp)
f0105244:	e8 f9 e2 ff ff       	call   f0103542 <envid2env>
	if (r)  // -E_BAD_ENV
f0105249:	83 c4 10             	add    $0x10,%esp
f010524c:	85 c0                	test   %eax,%eax
f010524e:	75 26                	jne    f0105276 <syscall+0x306>
	if ((uintptr_t)va >= UTOP || (uintptr_t)va % PGSIZE)
f0105250:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105257:	77 1d                	ja     f0105276 <syscall+0x306>
f0105259:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0105260:	75 14                	jne    f0105276 <syscall+0x306>
	page_remove(to_env->env_pgdir, va);
f0105262:	83 ec 08             	sub    $0x8,%esp
f0105265:	ff 75 10             	pushl  0x10(%ebp)
f0105268:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010526b:	ff 70 60             	pushl  0x60(%eax)
f010526e:	e8 88 c4 ff ff       	call   f01016fb <page_remove>
f0105273:	83 c4 10             	add    $0x10,%esp
		return 0;
f0105276:	bb 00 00 00 00       	mov    $0x0,%ebx
f010527b:	e9 4b fd ff ff       	jmp    f0104fcb <syscall+0x5b>
	int r = env_alloc(&newenv, curenv->env_id);
f0105280:	e8 9d 14 00 00       	call   f0106722 <cpunum>
f0105285:	83 ec 08             	sub    $0x8,%esp
f0105288:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010528b:	01 c2                	add    %eax,%edx
f010528d:	01 d2                	add    %edx,%edx
f010528f:	01 c2                	add    %eax,%edx
f0105291:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105294:	8b 04 85 28 80 2a f0 	mov    -0xfd57fd8(,%eax,4),%eax
f010529b:	ff 70 48             	pushl  0x48(%eax)
f010529e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01052a1:	50                   	push   %eax
f01052a2:	e8 c9 e3 ff ff       	call   f0103670 <env_alloc>
f01052a7:	89 c3                	mov    %eax,%ebx
	if (r)  // Some error
f01052a9:	83 c4 10             	add    $0x10,%esp
f01052ac:	85 c0                	test   %eax,%eax
f01052ae:	0f 85 17 fd ff ff    	jne    f0104fcb <syscall+0x5b>
	newenv->env_status = ENV_NOT_RUNNABLE;
f01052b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01052b7:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	memcpy(&newenv->env_tf, &curenv->env_tf, sizeof(struct Trapframe));
f01052be:	e8 5f 14 00 00       	call   f0106722 <cpunum>
f01052c3:	83 ec 04             	sub    $0x4,%esp
f01052c6:	6a 44                	push   $0x44
f01052c8:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01052cb:	01 c2                	add    %eax,%edx
f01052cd:	01 d2                	add    %edx,%edx
f01052cf:	01 c2                	add    %eax,%edx
f01052d1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01052d4:	ff 34 85 28 80 2a f0 	pushl  -0xfd57fd8(,%eax,4)
f01052db:	ff 75 f4             	pushl  -0xc(%ebp)
f01052de:	e8 19 0e 00 00       	call   f01060fc <memcpy>
	newenv->env_tf.tf_regs.reg_eax = 0;
f01052e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01052e6:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return newenv->env_id;
f01052ed:	8b 58 48             	mov    0x48(%eax),%ebx
f01052f0:	83 c4 10             	add    $0x10,%esp
		return sys_exofork();
f01052f3:	e9 d3 fc ff ff       	jmp    f0104fcb <syscall+0x5b>
	int r = envid2env(envid, &to_env, 1);  // 1 - Check perm
f01052f8:	83 ec 04             	sub    $0x4,%esp
f01052fb:	6a 01                	push   $0x1
f01052fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105300:	50                   	push   %eax
f0105301:	ff 75 0c             	pushl  0xc(%ebp)
f0105304:	e8 39 e2 ff ff       	call   f0103542 <envid2env>
f0105309:	89 c3                	mov    %eax,%ebx
	if (r)  // -E_BAD_ENV
f010530b:	83 c4 10             	add    $0x10,%esp
f010530e:	85 c0                	test   %eax,%eax
f0105310:	0f 85 b5 fc ff ff    	jne    f0104fcb <syscall+0x5b>
	if (status > ENV_NOT_RUNNABLE || status < 0) 
f0105316:	83 7d 10 04          	cmpl   $0x4,0x10(%ebp)
f010531a:	77 0e                	ja     f010532a <syscall+0x3ba>
	to_env->env_status = status;
f010531c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010531f:	8b 75 10             	mov    0x10(%ebp),%esi
f0105322:	89 70 54             	mov    %esi,0x54(%eax)
f0105325:	e9 a1 fc ff ff       	jmp    f0104fcb <syscall+0x5b>
		return -E_INVAL;
f010532a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		return sys_env_set_status(a1, a2);
f010532f:	e9 97 fc ff ff       	jmp    f0104fcb <syscall+0x5b>
	r = envid2env(envid, &env, 1);
f0105334:	83 ec 04             	sub    $0x4,%esp
f0105337:	6a 01                	push   $0x1
f0105339:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010533c:	50                   	push   %eax
f010533d:	ff 75 0c             	pushl  0xc(%ebp)
f0105340:	e8 fd e1 ff ff       	call   f0103542 <envid2env>
f0105345:	89 c3                	mov    %eax,%ebx
	if (r)	return r;
f0105347:	83 c4 10             	add    $0x10,%esp
f010534a:	85 c0                	test   %eax,%eax
f010534c:	0f 85 79 fc ff ff    	jne    f0104fcb <syscall+0x5b>
	if (!tf)	return -E_INVAL;
f0105352:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0105356:	74 3b                	je     f0105393 <syscall+0x423>
	cprintf("tf_eflags (before) = %x\n", tf->tf_eflags);
f0105358:	83 ec 08             	sub    $0x8,%esp
f010535b:	8b 45 10             	mov    0x10(%ebp),%eax
f010535e:	ff 70 38             	pushl  0x38(%eax)
f0105361:	68 de 87 10 f0       	push   $0xf01087de
f0105366:	e8 19 ec ff ff       	call   f0103f84 <cprintf>
	tf->tf_eflags |= FL_IF;  // Interrupt flag.
f010536b:	8b 45 10             	mov    0x10(%ebp),%eax
f010536e:	8b 40 38             	mov    0x38(%eax),%eax
f0105371:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105374:	80 cc 02             	or     $0x2,%ah
f0105377:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010537a:	89 41 38             	mov    %eax,0x38(%ecx)
	cprintf("tf_eflags = %x\n", tf->tf_eflags);
f010537d:	83 c4 08             	add    $0x8,%esp
f0105380:	50                   	push   %eax
f0105381:	68 f7 87 10 f0       	push   $0xf01087f7
f0105386:	e8 f9 eb ff ff       	call   f0103f84 <cprintf>
f010538b:	83 c4 10             	add    $0x10,%esp
f010538e:	e9 38 fc ff ff       	jmp    f0104fcb <syscall+0x5b>
	if (!tf)	return -E_INVAL;
f0105393:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		return sys_env_set_trapframe(a1, (void*)a2);
f0105398:	e9 2e fc ff ff       	jmp    f0104fcb <syscall+0x5b>
	int r = envid2env(envid, &to_env, 1);  // 1 - Check perm
f010539d:	83 ec 04             	sub    $0x4,%esp
f01053a0:	6a 01                	push   $0x1
f01053a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01053a5:	50                   	push   %eax
f01053a6:	ff 75 0c             	pushl  0xc(%ebp)
f01053a9:	e8 94 e1 ff ff       	call   f0103542 <envid2env>
f01053ae:	89 c3                	mov    %eax,%ebx
	if (r)  // -E_BAD_ENV
f01053b0:	83 c4 10             	add    $0x10,%esp
f01053b3:	85 c0                	test   %eax,%eax
f01053b5:	0f 85 10 fc ff ff    	jne    f0104fcb <syscall+0x5b>
	to_env->env_pgfault_upcall = func;
f01053bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01053be:	8b 75 10             	mov    0x10(%ebp),%esi
f01053c1:	89 70 64             	mov    %esi,0x64(%eax)
		return sys_env_set_pgfault_upcall(a1, (void*)a2);
f01053c4:	e9 02 fc ff ff       	jmp    f0104fcb <syscall+0x5b>
	sched_yield();
f01053c9:	e8 30 fa ff ff       	call   f0104dfe <sched_yield>
	r = envid2env(envid, &target_env, 0);  // 0 - don't check perm
f01053ce:	83 ec 04             	sub    $0x4,%esp
f01053d1:	6a 00                	push   $0x0
f01053d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
f01053d6:	50                   	push   %eax
f01053d7:	ff 75 0c             	pushl  0xc(%ebp)
f01053da:	e8 63 e1 ff ff       	call   f0103542 <envid2env>
f01053df:	89 c3                	mov    %eax,%ebx
	if (r)	return r;
f01053e1:	83 c4 10             	add    $0x10,%esp
f01053e4:	85 c0                	test   %eax,%eax
f01053e6:	0f 85 df fb ff ff    	jne    f0104fcb <syscall+0x5b>
	if (!target_env->env_ipc_recving)  // target is not willing to receive
f01053ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01053ef:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f01053f3:	0f 84 e9 00 00 00    	je     f01054e2 <syscall+0x572>
	target_env->env_ipc_from = curenv->env_id; 
f01053f9:	e8 24 13 00 00       	call   f0106722 <cpunum>
f01053fe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0105401:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0105404:	01 c2                	add    %eax,%edx
f0105406:	01 d2                	add    %edx,%edx
f0105408:	01 c2                	add    %eax,%edx
f010540a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010540d:	8b 04 85 28 80 2a f0 	mov    -0xfd57fd8(,%eax,4),%eax
f0105414:	8b 40 48             	mov    0x48(%eax),%eax
f0105417:	89 41 74             	mov    %eax,0x74(%ecx)
	target_env->env_ipc_recving = false;
f010541a:	c6 41 68 00          	movb   $0x0,0x68(%ecx)
	target_env->env_ipc_value = value;
f010541e:	8b 45 10             	mov    0x10(%ebp),%eax
f0105421:	89 41 70             	mov    %eax,0x70(%ecx)
	if ((uintptr_t)srcva < UTOP && // Have a page to map
f0105424:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f010542b:	0f 87 87 00 00 00    	ja     f01054b8 <syscall+0x548>
f0105431:	81 79 6c ff ff bf ee 	cmpl   $0xeebfffff,0x6c(%ecx)
f0105438:	77 7e                	ja     f01054b8 <syscall+0x548>
		if ((uintptr_t)srcva % PGSIZE || 	// check addr aligned
f010543a:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0105441:	0f 85 80 00 00 00    	jne    f01054c7 <syscall+0x557>
f0105447:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f010544e:	74 0a                	je     f010545a <syscall+0x4ea>
			return -E_INVAL;
f0105450:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105455:	e9 71 fb ff ff       	jmp    f0104fcb <syscall+0x5b>
		struct PageInfo* pp = page_lookup(curenv->env_pgdir, srcva, &src_pgt);
f010545a:	e8 c3 12 00 00       	call   f0106722 <cpunum>
f010545f:	83 ec 04             	sub    $0x4,%esp
f0105462:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0105465:	52                   	push   %edx
f0105466:	ff 75 14             	pushl  0x14(%ebp)
f0105469:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010546c:	01 c2                	add    %eax,%edx
f010546e:	01 d2                	add    %edx,%edx
f0105470:	01 c2                	add    %eax,%edx
f0105472:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105475:	8b 04 85 28 80 2a f0 	mov    -0xfd57fd8(,%eax,4),%eax
f010547c:	ff 70 60             	pushl  0x60(%eax)
f010547f:	e8 c8 c1 ff ff       	call   f010164c <page_lookup>
		if ((~*src_pgt & PTE_W) && (perm & PTE_W))
f0105484:	83 c4 10             	add    $0x10,%esp
f0105487:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010548a:	f6 02 02             	testb  $0x2,(%edx)
f010548d:	75 06                	jne    f0105495 <syscall+0x525>
f010548f:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0105493:	75 3c                	jne    f01054d1 <syscall+0x561>
		perm |= PTE_U | PTE_P;
f0105495:	8b 75 18             	mov    0x18(%ebp),%esi
f0105498:	83 ce 05             	or     $0x5,%esi
		r = page_insert(target_env->env_pgdir, pp, target_env->env_ipc_dstva, perm);
f010549b:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010549e:	56                   	push   %esi
f010549f:	ff 72 6c             	pushl  0x6c(%edx)
f01054a2:	50                   	push   %eax
f01054a3:	ff 72 60             	pushl  0x60(%edx)
f01054a6:	e8 aa c2 ff ff       	call   f0101755 <page_insert>
		if (r)	return r;
f01054ab:	83 c4 10             	add    $0x10,%esp
f01054ae:	85 c0                	test   %eax,%eax
f01054b0:	75 29                	jne    f01054db <syscall+0x56b>
		target_env->env_ipc_perm = perm;  // tell the permission
f01054b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01054b5:	89 70 78             	mov    %esi,0x78(%eax)
	target_env->env_status = ENV_RUNNABLE;
f01054b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01054bb:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f01054c2:	e9 04 fb ff ff       	jmp    f0104fcb <syscall+0x5b>
			return -E_INVAL;
f01054c7:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01054cc:	e9 fa fa ff ff       	jmp    f0104fcb <syscall+0x5b>
			return -E_INVAL;
f01054d1:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01054d6:	e9 f0 fa ff ff       	jmp    f0104fcb <syscall+0x5b>
		if (r)	return r;
f01054db:	89 c3                	mov    %eax,%ebx
f01054dd:	e9 e9 fa ff ff       	jmp    f0104fcb <syscall+0x5b>
		return -E_IPC_NOT_RECV;
f01054e2:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
		return sys_ipc_try_send(a1, a2, (void*)a3, a4);
f01054e7:	e9 df fa ff ff       	jmp    f0104fcb <syscall+0x5b>
		return sys_ipc_recv((void*)a1);
f01054ec:	83 ec 0c             	sub    $0xc,%esp
f01054ef:	ff 75 0c             	pushl  0xc(%ebp)
f01054f2:	e8 f7 f9 ff ff       	call   f0104eee <sys_ipc_recv>
f01054f7:	89 c3                	mov    %eax,%ebx
f01054f9:	83 c4 10             	add    $0x10,%esp
f01054fc:	e9 ca fa ff ff       	jmp    f0104fcb <syscall+0x5b>
		return -E_INVAL;
f0105501:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105506:	e9 c0 fa ff ff       	jmp    f0104fcb <syscall+0x5b>

f010550b <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010550b:	55                   	push   %ebp
f010550c:	89 e5                	mov    %esp,%ebp
f010550e:	57                   	push   %edi
f010550f:	56                   	push   %esi
f0105510:	53                   	push   %ebx
f0105511:	83 ec 14             	sub    $0x14,%esp
f0105514:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105517:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010551a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010551d:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105520:	8b 32                	mov    (%edx),%esi
f0105522:	8b 01                	mov    (%ecx),%eax
f0105524:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105527:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010552e:	eb 2f                	jmp    f010555f <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0105530:	48                   	dec    %eax
		while (m >= l && stabs[m].n_type != type)
f0105531:	39 c6                	cmp    %eax,%esi
f0105533:	7f 4d                	jg     f0105582 <stab_binsearch+0x77>
f0105535:	0f b6 0a             	movzbl (%edx),%ecx
f0105538:	83 ea 0c             	sub    $0xc,%edx
f010553b:	39 f9                	cmp    %edi,%ecx
f010553d:	75 f1                	jne    f0105530 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010553f:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0105542:	01 c2                	add    %eax,%edx
f0105544:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105547:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010554b:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010554e:	73 37                	jae    f0105587 <stab_binsearch+0x7c>
			*region_left = m;
f0105550:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105553:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0105555:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0105558:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f010555f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0105562:	7f 4d                	jg     f01055b1 <stab_binsearch+0xa6>
		int true_m = (l + r) / 2, m = true_m;
f0105564:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105567:	01 f0                	add    %esi,%eax
f0105569:	89 c3                	mov    %eax,%ebx
f010556b:	c1 eb 1f             	shr    $0x1f,%ebx
f010556e:	01 c3                	add    %eax,%ebx
f0105570:	d1 fb                	sar    %ebx
f0105572:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0105575:	01 d8                	add    %ebx,%eax
f0105577:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010557a:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f010557e:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0105580:	eb af                	jmp    f0105531 <stab_binsearch+0x26>
			l = true_m + 1;
f0105582:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0105585:	eb d8                	jmp    f010555f <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0105587:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010558a:	76 12                	jbe    f010559e <stab_binsearch+0x93>
			*region_right = m - 1;
f010558c:	48                   	dec    %eax
f010558d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105590:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105593:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0105595:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010559c:	eb c1                	jmp    f010555f <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010559e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01055a1:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01055a3:	ff 45 0c             	incl   0xc(%ebp)
f01055a6:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f01055a8:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01055af:	eb ae                	jmp    f010555f <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f01055b1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01055b5:	74 18                	je     f01055cf <stab_binsearch+0xc4>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01055b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01055ba:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01055bc:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01055bf:	8b 0e                	mov    (%esi),%ecx
f01055c1:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01055c4:	01 c2                	add    %eax,%edx
f01055c6:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01055c9:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f01055cd:	eb 0e                	jmp    f01055dd <stab_binsearch+0xd2>
		*region_right = *region_left - 1;
f01055cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01055d2:	8b 00                	mov    (%eax),%eax
f01055d4:	48                   	dec    %eax
f01055d5:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01055d8:	89 07                	mov    %eax,(%edi)
f01055da:	eb 14                	jmp    f01055f0 <stab_binsearch+0xe5>
		     l--)
f01055dc:	48                   	dec    %eax
		for (l = *region_right;
f01055dd:	39 c1                	cmp    %eax,%ecx
f01055df:	7d 0a                	jge    f01055eb <stab_binsearch+0xe0>
		     l > *region_left && stabs[l].n_type != type;
f01055e1:	0f b6 1a             	movzbl (%edx),%ebx
f01055e4:	83 ea 0c             	sub    $0xc,%edx
f01055e7:	39 fb                	cmp    %edi,%ebx
f01055e9:	75 f1                	jne    f01055dc <stab_binsearch+0xd1>
			/* do nothing */;
		*region_left = l;
f01055eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01055ee:	89 07                	mov    %eax,(%edi)
	}
}
f01055f0:	83 c4 14             	add    $0x14,%esp
f01055f3:	5b                   	pop    %ebx
f01055f4:	5e                   	pop    %esi
f01055f5:	5f                   	pop    %edi
f01055f6:	5d                   	pop    %ebp
f01055f7:	c3                   	ret    

f01055f8 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01055f8:	55                   	push   %ebp
f01055f9:	89 e5                	mov    %esp,%ebp
f01055fb:	57                   	push   %edi
f01055fc:	56                   	push   %esi
f01055fd:	53                   	push   %ebx
f01055fe:	83 ec 4c             	sub    $0x4c,%esp
f0105601:	8b 75 08             	mov    0x8(%ebp),%esi
f0105604:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105607:	c7 03 40 88 10 f0    	movl   $0xf0108840,(%ebx)
	info->eip_line = 0;
f010560d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0105614:	c7 43 08 40 88 10 f0 	movl   $0xf0108840,0x8(%ebx)
	info->eip_fn_namelen = 9;
f010561b:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0105622:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0105625:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010562c:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0105632:	77 1e                	ja     f0105652 <debuginfo_eip+0x5a>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0105634:	8b 3d 00 00 20 00    	mov    0x200000,%edi
		stab_end = usd->stab_end;
f010563a:	8b 15 04 00 20 00    	mov    0x200004,%edx
		stabstr = usd->stabstr;
f0105640:	a1 08 00 20 00       	mov    0x200008,%eax
f0105645:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0105648:	a1 0c 00 20 00       	mov    0x20000c,%eax
f010564d:	89 45 b8             	mov    %eax,-0x48(%ebp)
f0105650:	eb 18                	jmp    f010566a <debuginfo_eip+0x72>
		stabstr_end = __STABSTR_END__;
f0105652:	c7 45 b8 c6 88 11 f0 	movl   $0xf01188c6,-0x48(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0105659:	c7 45 b4 a5 4f 11 f0 	movl   $0xf0114fa5,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0105660:	ba a4 4f 11 f0       	mov    $0xf0114fa4,%edx
		stabs = __STAB_BEGIN__;
f0105665:	bf d0 8d 10 f0       	mov    $0xf0108dd0,%edi
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010566a:	8b 45 b8             	mov    -0x48(%ebp),%eax
f010566d:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
f0105670:	0f 83 9b 01 00 00    	jae    f0105811 <debuginfo_eip+0x219>
f0105676:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f010567a:	0f 85 98 01 00 00    	jne    f0105818 <debuginfo_eip+0x220>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105680:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105687:	29 fa                	sub    %edi,%edx
f0105689:	c1 fa 02             	sar    $0x2,%edx
f010568c:	8d 04 92             	lea    (%edx,%edx,4),%eax
f010568f:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0105692:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0105695:	89 c1                	mov    %eax,%ecx
f0105697:	c1 e1 08             	shl    $0x8,%ecx
f010569a:	01 c8                	add    %ecx,%eax
f010569c:	89 c1                	mov    %eax,%ecx
f010569e:	c1 e1 10             	shl    $0x10,%ecx
f01056a1:	01 c8                	add    %ecx,%eax
f01056a3:	01 c0                	add    %eax,%eax
f01056a5:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
f01056a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01056ac:	56                   	push   %esi
f01056ad:	6a 64                	push   $0x64
f01056af:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01056b2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01056b5:	89 f8                	mov    %edi,%eax
f01056b7:	e8 4f fe ff ff       	call   f010550b <stab_binsearch>
	if (lfile == 0)
f01056bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01056bf:	83 c4 08             	add    $0x8,%esp
f01056c2:	85 c0                	test   %eax,%eax
f01056c4:	0f 84 55 01 00 00    	je     f010581f <debuginfo_eip+0x227>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01056ca:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01056cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01056d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01056d3:	56                   	push   %esi
f01056d4:	6a 24                	push   $0x24
f01056d6:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01056d9:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01056dc:	89 f8                	mov    %edi,%eax
f01056de:	e8 28 fe ff ff       	call   f010550b <stab_binsearch>

	if (lfun <= rfun) {
f01056e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01056e6:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01056e9:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f01056ec:	83 c4 08             	add    $0x8,%esp
f01056ef:	39 c8                	cmp    %ecx,%eax
f01056f1:	0f 8f 80 00 00 00    	jg     f0105777 <debuginfo_eip+0x17f>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01056f7:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01056fa:	01 c2                	add    %eax,%edx
f01056fc:	8d 14 97             	lea    (%edi,%edx,4),%edx
f01056ff:	89 55 c0             	mov    %edx,-0x40(%ebp)
f0105702:	8b 0a                	mov    (%edx),%ecx
f0105704:	89 4d bc             	mov    %ecx,-0x44(%ebp)
f0105707:	8b 55 b8             	mov    -0x48(%ebp),%edx
f010570a:	2b 55 b4             	sub    -0x4c(%ebp),%edx
f010570d:	39 d1                	cmp    %edx,%ecx
f010570f:	73 06                	jae    f0105717 <debuginfo_eip+0x11f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105711:	03 4d b4             	add    -0x4c(%ebp),%ecx
f0105714:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105717:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f010571a:	8b 51 08             	mov    0x8(%ecx),%edx
f010571d:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105720:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0105722:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105725:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105728:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010572b:	83 ec 08             	sub    $0x8,%esp
f010572e:	6a 3a                	push   $0x3a
f0105730:	ff 73 08             	pushl  0x8(%ebx)
f0105733:	e8 f9 08 00 00       	call   f0106031 <strfind>
f0105738:	2b 43 08             	sub    0x8(%ebx),%eax
f010573b:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// N_SLINE represents text segment
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f010573e:	83 c4 08             	add    $0x8,%esp
f0105741:	56                   	push   %esi
f0105742:	6a 44                	push   $0x44
f0105744:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105747:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010574a:	89 f8                	mov    %edi,%eax
f010574c:	e8 ba fd ff ff       	call   f010550b <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0105751:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105754:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0105757:	01 c2                	add    %eax,%edx
f0105759:	c1 e2 02             	shl    $0x2,%edx
f010575c:	0f b7 4c 17 06       	movzwl 0x6(%edi,%edx,1),%ecx
f0105761:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105764:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105767:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f010576a:	8d 54 17 04          	lea    0x4(%edi,%edx,1),%edx
f010576e:	83 c4 10             	add    $0x10,%esp
f0105771:	c6 45 c0 00          	movb   $0x0,-0x40(%ebp)
f0105775:	eb 19                	jmp    f0105790 <debuginfo_eip+0x198>
		info->eip_fn_addr = addr;
f0105777:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010577a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010577d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105780:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105783:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105786:	eb a3                	jmp    f010572b <debuginfo_eip+0x133>
f0105788:	48                   	dec    %eax
f0105789:	83 ea 0c             	sub    $0xc,%edx
f010578c:	c6 45 c0 01          	movb   $0x1,-0x40(%ebp)
f0105790:	89 45 bc             	mov    %eax,-0x44(%ebp)
	while (lline >= lfile
f0105793:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0105796:	7f 40                	jg     f01057d8 <debuginfo_eip+0x1e0>
	       && stabs[lline].n_type != N_SOL
f0105798:	8a 0a                	mov    (%edx),%cl
f010579a:	80 f9 84             	cmp    $0x84,%cl
f010579d:	74 19                	je     f01057b8 <debuginfo_eip+0x1c0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010579f:	80 f9 64             	cmp    $0x64,%cl
f01057a2:	75 e4                	jne    f0105788 <debuginfo_eip+0x190>
f01057a4:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f01057a8:	74 de                	je     f0105788 <debuginfo_eip+0x190>
f01057aa:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f01057ae:	74 0e                	je     f01057be <debuginfo_eip+0x1c6>
f01057b0:	8b 75 bc             	mov    -0x44(%ebp),%esi
f01057b3:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01057b6:	eb 06                	jmp    f01057be <debuginfo_eip+0x1c6>
f01057b8:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f01057bc:	75 35                	jne    f01057f3 <debuginfo_eip+0x1fb>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01057be:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01057c1:	01 d0                	add    %edx,%eax
f01057c3:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01057c6:	8b 45 b8             	mov    -0x48(%ebp),%eax
f01057c9:	8b 75 b4             	mov    -0x4c(%ebp),%esi
f01057cc:	29 f0                	sub    %esi,%eax
f01057ce:	39 c2                	cmp    %eax,%edx
f01057d0:	73 06                	jae    f01057d8 <debuginfo_eip+0x1e0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01057d2:	89 f0                	mov    %esi,%eax
f01057d4:	01 d0                	add    %edx,%eax
f01057d6:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01057d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01057db:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01057de:	39 f2                	cmp    %esi,%edx
f01057e0:	7d 44                	jge    f0105826 <debuginfo_eip+0x22e>
		for (lline = lfun + 1;
f01057e2:	42                   	inc    %edx
f01057e3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01057e6:	89 d0                	mov    %edx,%eax
f01057e8:	8d 0c 12             	lea    (%edx,%edx,1),%ecx
f01057eb:	01 ca                	add    %ecx,%edx
f01057ed:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f01057f1:	eb 08                	jmp    f01057fb <debuginfo_eip+0x203>
f01057f3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01057f6:	eb c6                	jmp    f01057be <debuginfo_eip+0x1c6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01057f8:	ff 43 14             	incl   0x14(%ebx)
		for (lline = lfun + 1;
f01057fb:	39 c6                	cmp    %eax,%esi
f01057fd:	7e 34                	jle    f0105833 <debuginfo_eip+0x23b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01057ff:	8a 0a                	mov    (%edx),%cl
f0105801:	40                   	inc    %eax
f0105802:	83 c2 0c             	add    $0xc,%edx
f0105805:	80 f9 a0             	cmp    $0xa0,%cl
f0105808:	74 ee                	je     f01057f8 <debuginfo_eip+0x200>

	return 0;
f010580a:	b8 00 00 00 00       	mov    $0x0,%eax
f010580f:	eb 1a                	jmp    f010582b <debuginfo_eip+0x233>
		return -1;
f0105811:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105816:	eb 13                	jmp    f010582b <debuginfo_eip+0x233>
f0105818:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010581d:	eb 0c                	jmp    f010582b <debuginfo_eip+0x233>
		return -1;
f010581f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105824:	eb 05                	jmp    f010582b <debuginfo_eip+0x233>
	return 0;
f0105826:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010582b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010582e:	5b                   	pop    %ebx
f010582f:	5e                   	pop    %esi
f0105830:	5f                   	pop    %edi
f0105831:	5d                   	pop    %ebp
f0105832:	c3                   	ret    
	return 0;
f0105833:	b8 00 00 00 00       	mov    $0x0,%eax
f0105838:	eb f1                	jmp    f010582b <debuginfo_eip+0x233>

f010583a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010583a:	55                   	push   %ebp
f010583b:	89 e5                	mov    %esp,%ebp
f010583d:	57                   	push   %edi
f010583e:	56                   	push   %esi
f010583f:	53                   	push   %ebx
f0105840:	83 ec 1c             	sub    $0x1c,%esp
f0105843:	89 c7                	mov    %eax,%edi
f0105845:	89 d6                	mov    %edx,%esi
f0105847:	8b 45 08             	mov    0x8(%ebp),%eax
f010584a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010584d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105850:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105853:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105856:	bb 00 00 00 00       	mov    $0x0,%ebx
f010585b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010585e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0105861:	39 d3                	cmp    %edx,%ebx
f0105863:	72 05                	jb     f010586a <printnum+0x30>
f0105865:	39 45 10             	cmp    %eax,0x10(%ebp)
f0105868:	77 78                	ja     f01058e2 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010586a:	83 ec 0c             	sub    $0xc,%esp
f010586d:	ff 75 18             	pushl  0x18(%ebp)
f0105870:	8b 45 14             	mov    0x14(%ebp),%eax
f0105873:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0105876:	53                   	push   %ebx
f0105877:	ff 75 10             	pushl  0x10(%ebp)
f010587a:	83 ec 08             	sub    $0x8,%esp
f010587d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105880:	ff 75 e0             	pushl  -0x20(%ebp)
f0105883:	ff 75 dc             	pushl  -0x24(%ebp)
f0105886:	ff 75 d8             	pushl  -0x28(%ebp)
f0105889:	e8 aa 12 00 00       	call   f0106b38 <__udivdi3>
f010588e:	83 c4 18             	add    $0x18,%esp
f0105891:	52                   	push   %edx
f0105892:	50                   	push   %eax
f0105893:	89 f2                	mov    %esi,%edx
f0105895:	89 f8                	mov    %edi,%eax
f0105897:	e8 9e ff ff ff       	call   f010583a <printnum>
f010589c:	83 c4 20             	add    $0x20,%esp
f010589f:	eb 11                	jmp    f01058b2 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01058a1:	83 ec 08             	sub    $0x8,%esp
f01058a4:	56                   	push   %esi
f01058a5:	ff 75 18             	pushl  0x18(%ebp)
f01058a8:	ff d7                	call   *%edi
f01058aa:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f01058ad:	4b                   	dec    %ebx
f01058ae:	85 db                	test   %ebx,%ebx
f01058b0:	7f ef                	jg     f01058a1 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01058b2:	83 ec 08             	sub    $0x8,%esp
f01058b5:	56                   	push   %esi
f01058b6:	83 ec 04             	sub    $0x4,%esp
f01058b9:	ff 75 e4             	pushl  -0x1c(%ebp)
f01058bc:	ff 75 e0             	pushl  -0x20(%ebp)
f01058bf:	ff 75 dc             	pushl  -0x24(%ebp)
f01058c2:	ff 75 d8             	pushl  -0x28(%ebp)
f01058c5:	e8 6e 13 00 00       	call   f0106c38 <__umoddi3>
f01058ca:	83 c4 14             	add    $0x14,%esp
f01058cd:	0f be 80 4a 88 10 f0 	movsbl -0xfef77b6(%eax),%eax
f01058d4:	50                   	push   %eax
f01058d5:	ff d7                	call   *%edi
}
f01058d7:	83 c4 10             	add    $0x10,%esp
f01058da:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01058dd:	5b                   	pop    %ebx
f01058de:	5e                   	pop    %esi
f01058df:	5f                   	pop    %edi
f01058e0:	5d                   	pop    %ebp
f01058e1:	c3                   	ret    
f01058e2:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01058e5:	eb c6                	jmp    f01058ad <printnum+0x73>

f01058e7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01058e7:	55                   	push   %ebp
f01058e8:	89 e5                	mov    %esp,%ebp
f01058ea:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01058ed:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f01058f0:	8b 10                	mov    (%eax),%edx
f01058f2:	3b 50 04             	cmp    0x4(%eax),%edx
f01058f5:	73 0a                	jae    f0105901 <sprintputch+0x1a>
		*b->buf++ = ch;
f01058f7:	8d 4a 01             	lea    0x1(%edx),%ecx
f01058fa:	89 08                	mov    %ecx,(%eax)
f01058fc:	8b 45 08             	mov    0x8(%ebp),%eax
f01058ff:	88 02                	mov    %al,(%edx)
}
f0105901:	5d                   	pop    %ebp
f0105902:	c3                   	ret    

f0105903 <printfmt>:
{
f0105903:	55                   	push   %ebp
f0105904:	89 e5                	mov    %esp,%ebp
f0105906:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0105909:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010590c:	50                   	push   %eax
f010590d:	ff 75 10             	pushl  0x10(%ebp)
f0105910:	ff 75 0c             	pushl  0xc(%ebp)
f0105913:	ff 75 08             	pushl  0x8(%ebp)
f0105916:	e8 05 00 00 00       	call   f0105920 <vprintfmt>
}
f010591b:	83 c4 10             	add    $0x10,%esp
f010591e:	c9                   	leave  
f010591f:	c3                   	ret    

f0105920 <vprintfmt>:
{
f0105920:	55                   	push   %ebp
f0105921:	89 e5                	mov    %esp,%ebp
f0105923:	57                   	push   %edi
f0105924:	56                   	push   %esi
f0105925:	53                   	push   %ebx
f0105926:	83 ec 2c             	sub    $0x2c,%esp
f0105929:	8b 75 08             	mov    0x8(%ebp),%esi
f010592c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010592f:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105932:	e9 ac 03 00 00       	jmp    f0105ce3 <vprintfmt+0x3c3>
		padc = ' ';
f0105937:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f010593b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0105942:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f0105949:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0105950:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0105955:	8d 47 01             	lea    0x1(%edi),%eax
f0105958:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010595b:	8a 17                	mov    (%edi),%dl
f010595d:	8d 42 dd             	lea    -0x23(%edx),%eax
f0105960:	3c 55                	cmp    $0x55,%al
f0105962:	0f 87 fc 03 00 00    	ja     f0105d64 <vprintfmt+0x444>
f0105968:	0f b6 c0             	movzbl %al,%eax
f010596b:	ff 24 85 80 89 10 f0 	jmp    *-0xfef7680(,%eax,4)
f0105972:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0105975:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0105979:	eb da                	jmp    f0105955 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f010597b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f010597e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0105982:	eb d1                	jmp    f0105955 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0105984:	0f b6 d2             	movzbl %dl,%edx
f0105987:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f010598a:	b8 00 00 00 00       	mov    $0x0,%eax
f010598f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0105992:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0105995:	01 c0                	add    %eax,%eax
f0105997:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
f010599b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f010599e:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01059a1:	83 f9 09             	cmp    $0x9,%ecx
f01059a4:	77 52                	ja     f01059f8 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
f01059a6:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
f01059a7:	eb e9                	jmp    f0105992 <vprintfmt+0x72>
			precision = va_arg(ap, int);
f01059a9:	8b 45 14             	mov    0x14(%ebp),%eax
f01059ac:	8b 00                	mov    (%eax),%eax
f01059ae:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01059b1:	8b 45 14             	mov    0x14(%ebp),%eax
f01059b4:	8d 40 04             	lea    0x4(%eax),%eax
f01059b7:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01059ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f01059bd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01059c1:	79 92                	jns    f0105955 <vprintfmt+0x35>
				width = precision, precision = -1;
f01059c3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01059c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01059c9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01059d0:	eb 83                	jmp    f0105955 <vprintfmt+0x35>
f01059d2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01059d6:	78 08                	js     f01059e0 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
f01059d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01059db:	e9 75 ff ff ff       	jmp    f0105955 <vprintfmt+0x35>
f01059e0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01059e7:	eb ef                	jmp    f01059d8 <vprintfmt+0xb8>
f01059e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f01059ec:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01059f3:	e9 5d ff ff ff       	jmp    f0105955 <vprintfmt+0x35>
f01059f8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01059fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01059fe:	eb bd                	jmp    f01059bd <vprintfmt+0x9d>
			lflag++;
f0105a00:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
f0105a01:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0105a04:	e9 4c ff ff ff       	jmp    f0105955 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f0105a09:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a0c:	8d 78 04             	lea    0x4(%eax),%edi
f0105a0f:	83 ec 08             	sub    $0x8,%esp
f0105a12:	53                   	push   %ebx
f0105a13:	ff 30                	pushl  (%eax)
f0105a15:	ff d6                	call   *%esi
			break;
f0105a17:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0105a1a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0105a1d:	e9 be 02 00 00       	jmp    f0105ce0 <vprintfmt+0x3c0>
			err = va_arg(ap, int);
f0105a22:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a25:	8d 78 04             	lea    0x4(%eax),%edi
f0105a28:	8b 00                	mov    (%eax),%eax
f0105a2a:	85 c0                	test   %eax,%eax
f0105a2c:	78 2a                	js     f0105a58 <vprintfmt+0x138>
f0105a2e:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105a30:	83 f8 0f             	cmp    $0xf,%eax
f0105a33:	7f 27                	jg     f0105a5c <vprintfmt+0x13c>
f0105a35:	8b 04 85 e0 8a 10 f0 	mov    -0xfef7520(,%eax,4),%eax
f0105a3c:	85 c0                	test   %eax,%eax
f0105a3e:	74 1c                	je     f0105a5c <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
f0105a40:	50                   	push   %eax
f0105a41:	68 b5 7f 10 f0       	push   $0xf0107fb5
f0105a46:	53                   	push   %ebx
f0105a47:	56                   	push   %esi
f0105a48:	e8 b6 fe ff ff       	call   f0105903 <printfmt>
f0105a4d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105a50:	89 7d 14             	mov    %edi,0x14(%ebp)
f0105a53:	e9 88 02 00 00       	jmp    f0105ce0 <vprintfmt+0x3c0>
f0105a58:	f7 d8                	neg    %eax
f0105a5a:	eb d2                	jmp    f0105a2e <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
f0105a5c:	52                   	push   %edx
f0105a5d:	68 62 88 10 f0       	push   $0xf0108862
f0105a62:	53                   	push   %ebx
f0105a63:	56                   	push   %esi
f0105a64:	e8 9a fe ff ff       	call   f0105903 <printfmt>
f0105a69:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105a6c:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0105a6f:	e9 6c 02 00 00       	jmp    f0105ce0 <vprintfmt+0x3c0>
			if ((p = va_arg(ap, char *)) == NULL)
f0105a74:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a77:	83 c0 04             	add    $0x4,%eax
f0105a7a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0105a7d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a80:	8b 38                	mov    (%eax),%edi
f0105a82:	85 ff                	test   %edi,%edi
f0105a84:	74 18                	je     f0105a9e <vprintfmt+0x17e>
			if (width > 0 && padc != '-')
f0105a86:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105a8a:	0f 8e b7 00 00 00    	jle    f0105b47 <vprintfmt+0x227>
f0105a90:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0105a94:	75 0f                	jne    f0105aa5 <vprintfmt+0x185>
f0105a96:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105a99:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0105a9c:	eb 6e                	jmp    f0105b0c <vprintfmt+0x1ec>
				p = "(null)";
f0105a9e:	bf 5b 88 10 f0       	mov    $0xf010885b,%edi
f0105aa3:	eb e1                	jmp    f0105a86 <vprintfmt+0x166>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105aa5:	83 ec 08             	sub    $0x8,%esp
f0105aa8:	ff 75 d0             	pushl  -0x30(%ebp)
f0105aab:	57                   	push   %edi
f0105aac:	e8 55 04 00 00       	call   f0105f06 <strnlen>
f0105ab1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105ab4:	29 c1                	sub    %eax,%ecx
f0105ab6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0105ab9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105abc:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105ac0:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105ac3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105ac6:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0105ac8:	eb 0d                	jmp    f0105ad7 <vprintfmt+0x1b7>
					putch(padc, putdat);
f0105aca:	83 ec 08             	sub    $0x8,%esp
f0105acd:	53                   	push   %ebx
f0105ace:	ff 75 e0             	pushl  -0x20(%ebp)
f0105ad1:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0105ad3:	4f                   	dec    %edi
f0105ad4:	83 c4 10             	add    $0x10,%esp
f0105ad7:	85 ff                	test   %edi,%edi
f0105ad9:	7f ef                	jg     f0105aca <vprintfmt+0x1aa>
f0105adb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105ade:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0105ae1:	89 c8                	mov    %ecx,%eax
f0105ae3:	85 c9                	test   %ecx,%ecx
f0105ae5:	78 59                	js     f0105b40 <vprintfmt+0x220>
f0105ae7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0105aea:	29 c1                	sub    %eax,%ecx
f0105aec:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105aef:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105af2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0105af5:	eb 15                	jmp    f0105b0c <vprintfmt+0x1ec>
				if (altflag && (ch < ' ' || ch > '~'))
f0105af7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105afb:	75 29                	jne    f0105b26 <vprintfmt+0x206>
					putch(ch, putdat);
f0105afd:	83 ec 08             	sub    $0x8,%esp
f0105b00:	ff 75 0c             	pushl  0xc(%ebp)
f0105b03:	50                   	push   %eax
f0105b04:	ff d6                	call   *%esi
f0105b06:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105b09:	ff 4d e0             	decl   -0x20(%ebp)
f0105b0c:	47                   	inc    %edi
f0105b0d:	8a 57 ff             	mov    -0x1(%edi),%dl
f0105b10:	0f be c2             	movsbl %dl,%eax
f0105b13:	85 c0                	test   %eax,%eax
f0105b15:	74 53                	je     f0105b6a <vprintfmt+0x24a>
f0105b17:	85 db                	test   %ebx,%ebx
f0105b19:	78 dc                	js     f0105af7 <vprintfmt+0x1d7>
f0105b1b:	4b                   	dec    %ebx
f0105b1c:	79 d9                	jns    f0105af7 <vprintfmt+0x1d7>
f0105b1e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105b21:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105b24:	eb 35                	jmp    f0105b5b <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
f0105b26:	0f be d2             	movsbl %dl,%edx
f0105b29:	83 ea 20             	sub    $0x20,%edx
f0105b2c:	83 fa 5e             	cmp    $0x5e,%edx
f0105b2f:	76 cc                	jbe    f0105afd <vprintfmt+0x1dd>
					putch('?', putdat);
f0105b31:	83 ec 08             	sub    $0x8,%esp
f0105b34:	ff 75 0c             	pushl  0xc(%ebp)
f0105b37:	6a 3f                	push   $0x3f
f0105b39:	ff d6                	call   *%esi
f0105b3b:	83 c4 10             	add    $0x10,%esp
f0105b3e:	eb c9                	jmp    f0105b09 <vprintfmt+0x1e9>
f0105b40:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b45:	eb a0                	jmp    f0105ae7 <vprintfmt+0x1c7>
f0105b47:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105b4a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0105b4d:	eb bd                	jmp    f0105b0c <vprintfmt+0x1ec>
				putch(' ', putdat);
f0105b4f:	83 ec 08             	sub    $0x8,%esp
f0105b52:	53                   	push   %ebx
f0105b53:	6a 20                	push   $0x20
f0105b55:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0105b57:	4f                   	dec    %edi
f0105b58:	83 c4 10             	add    $0x10,%esp
f0105b5b:	85 ff                	test   %edi,%edi
f0105b5d:	7f f0                	jg     f0105b4f <vprintfmt+0x22f>
			if ((p = va_arg(ap, char *)) == NULL)
f0105b5f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105b62:	89 45 14             	mov    %eax,0x14(%ebp)
f0105b65:	e9 76 01 00 00       	jmp    f0105ce0 <vprintfmt+0x3c0>
f0105b6a:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105b6d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105b70:	eb e9                	jmp    f0105b5b <vprintfmt+0x23b>
	if (lflag >= 2)
f0105b72:	83 f9 01             	cmp    $0x1,%ecx
f0105b75:	7e 3f                	jle    f0105bb6 <vprintfmt+0x296>
		return va_arg(*ap, long long);
f0105b77:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b7a:	8b 50 04             	mov    0x4(%eax),%edx
f0105b7d:	8b 00                	mov    (%eax),%eax
f0105b7f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105b82:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105b85:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b88:	8d 40 08             	lea    0x8(%eax),%eax
f0105b8b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0105b8e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105b92:	79 5c                	jns    f0105bf0 <vprintfmt+0x2d0>
				putch('-', putdat);
f0105b94:	83 ec 08             	sub    $0x8,%esp
f0105b97:	53                   	push   %ebx
f0105b98:	6a 2d                	push   $0x2d
f0105b9a:	ff d6                	call   *%esi
				num = -(long long) num;
f0105b9c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105b9f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105ba2:	f7 da                	neg    %edx
f0105ba4:	83 d1 00             	adc    $0x0,%ecx
f0105ba7:	f7 d9                	neg    %ecx
f0105ba9:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0105bac:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105bb1:	e9 10 01 00 00       	jmp    f0105cc6 <vprintfmt+0x3a6>
	else if (lflag)
f0105bb6:	85 c9                	test   %ecx,%ecx
f0105bb8:	75 1b                	jne    f0105bd5 <vprintfmt+0x2b5>
		return va_arg(*ap, int);
f0105bba:	8b 45 14             	mov    0x14(%ebp),%eax
f0105bbd:	8b 00                	mov    (%eax),%eax
f0105bbf:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105bc2:	89 c1                	mov    %eax,%ecx
f0105bc4:	c1 f9 1f             	sar    $0x1f,%ecx
f0105bc7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105bca:	8b 45 14             	mov    0x14(%ebp),%eax
f0105bcd:	8d 40 04             	lea    0x4(%eax),%eax
f0105bd0:	89 45 14             	mov    %eax,0x14(%ebp)
f0105bd3:	eb b9                	jmp    f0105b8e <vprintfmt+0x26e>
		return va_arg(*ap, long);
f0105bd5:	8b 45 14             	mov    0x14(%ebp),%eax
f0105bd8:	8b 00                	mov    (%eax),%eax
f0105bda:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105bdd:	89 c1                	mov    %eax,%ecx
f0105bdf:	c1 f9 1f             	sar    $0x1f,%ecx
f0105be2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105be5:	8b 45 14             	mov    0x14(%ebp),%eax
f0105be8:	8d 40 04             	lea    0x4(%eax),%eax
f0105beb:	89 45 14             	mov    %eax,0x14(%ebp)
f0105bee:	eb 9e                	jmp    f0105b8e <vprintfmt+0x26e>
			num = getint(&ap, lflag);
f0105bf0:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105bf3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0105bf6:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105bfb:	e9 c6 00 00 00       	jmp    f0105cc6 <vprintfmt+0x3a6>
	if (lflag >= 2)
f0105c00:	83 f9 01             	cmp    $0x1,%ecx
f0105c03:	7e 18                	jle    f0105c1d <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
f0105c05:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c08:	8b 10                	mov    (%eax),%edx
f0105c0a:	8b 48 04             	mov    0x4(%eax),%ecx
f0105c0d:	8d 40 08             	lea    0x8(%eax),%eax
f0105c10:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105c13:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105c18:	e9 a9 00 00 00       	jmp    f0105cc6 <vprintfmt+0x3a6>
	else if (lflag)
f0105c1d:	85 c9                	test   %ecx,%ecx
f0105c1f:	75 1a                	jne    f0105c3b <vprintfmt+0x31b>
		return va_arg(*ap, unsigned int);
f0105c21:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c24:	8b 10                	mov    (%eax),%edx
f0105c26:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105c2b:	8d 40 04             	lea    0x4(%eax),%eax
f0105c2e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105c31:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105c36:	e9 8b 00 00 00       	jmp    f0105cc6 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0105c3b:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c3e:	8b 10                	mov    (%eax),%edx
f0105c40:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105c45:	8d 40 04             	lea    0x4(%eax),%eax
f0105c48:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105c4b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105c50:	eb 74                	jmp    f0105cc6 <vprintfmt+0x3a6>
	if (lflag >= 2)
f0105c52:	83 f9 01             	cmp    $0x1,%ecx
f0105c55:	7e 15                	jle    f0105c6c <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
f0105c57:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c5a:	8b 10                	mov    (%eax),%edx
f0105c5c:	8b 48 04             	mov    0x4(%eax),%ecx
f0105c5f:	8d 40 08             	lea    0x8(%eax),%eax
f0105c62:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0105c65:	b8 08 00 00 00       	mov    $0x8,%eax
f0105c6a:	eb 5a                	jmp    f0105cc6 <vprintfmt+0x3a6>
	else if (lflag)
f0105c6c:	85 c9                	test   %ecx,%ecx
f0105c6e:	75 17                	jne    f0105c87 <vprintfmt+0x367>
		return va_arg(*ap, unsigned int);
f0105c70:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c73:	8b 10                	mov    (%eax),%edx
f0105c75:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105c7a:	8d 40 04             	lea    0x4(%eax),%eax
f0105c7d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0105c80:	b8 08 00 00 00       	mov    $0x8,%eax
f0105c85:	eb 3f                	jmp    f0105cc6 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0105c87:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c8a:	8b 10                	mov    (%eax),%edx
f0105c8c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105c91:	8d 40 04             	lea    0x4(%eax),%eax
f0105c94:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0105c97:	b8 08 00 00 00       	mov    $0x8,%eax
f0105c9c:	eb 28                	jmp    f0105cc6 <vprintfmt+0x3a6>
			putch('0', putdat);
f0105c9e:	83 ec 08             	sub    $0x8,%esp
f0105ca1:	53                   	push   %ebx
f0105ca2:	6a 30                	push   $0x30
f0105ca4:	ff d6                	call   *%esi
			putch('x', putdat);
f0105ca6:	83 c4 08             	add    $0x8,%esp
f0105ca9:	53                   	push   %ebx
f0105caa:	6a 78                	push   $0x78
f0105cac:	ff d6                	call   *%esi
			num = (unsigned long long)
f0105cae:	8b 45 14             	mov    0x14(%ebp),%eax
f0105cb1:	8b 10                	mov    (%eax),%edx
f0105cb3:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0105cb8:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0105cbb:	8d 40 04             	lea    0x4(%eax),%eax
f0105cbe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105cc1:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0105cc6:	83 ec 0c             	sub    $0xc,%esp
f0105cc9:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105ccd:	57                   	push   %edi
f0105cce:	ff 75 e0             	pushl  -0x20(%ebp)
f0105cd1:	50                   	push   %eax
f0105cd2:	51                   	push   %ecx
f0105cd3:	52                   	push   %edx
f0105cd4:	89 da                	mov    %ebx,%edx
f0105cd6:	89 f0                	mov    %esi,%eax
f0105cd8:	e8 5d fb ff ff       	call   f010583a <printnum>
			break;
f0105cdd:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0105ce0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105ce3:	47                   	inc    %edi
f0105ce4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105ce8:	83 f8 25             	cmp    $0x25,%eax
f0105ceb:	0f 84 46 fc ff ff    	je     f0105937 <vprintfmt+0x17>
			if (ch == '\0')
f0105cf1:	85 c0                	test   %eax,%eax
f0105cf3:	0f 84 89 00 00 00    	je     f0105d82 <vprintfmt+0x462>
			putch(ch, putdat);
f0105cf9:	83 ec 08             	sub    $0x8,%esp
f0105cfc:	53                   	push   %ebx
f0105cfd:	50                   	push   %eax
f0105cfe:	ff d6                	call   *%esi
f0105d00:	83 c4 10             	add    $0x10,%esp
f0105d03:	eb de                	jmp    f0105ce3 <vprintfmt+0x3c3>
	if (lflag >= 2)
f0105d05:	83 f9 01             	cmp    $0x1,%ecx
f0105d08:	7e 15                	jle    f0105d1f <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
f0105d0a:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d0d:	8b 10                	mov    (%eax),%edx
f0105d0f:	8b 48 04             	mov    0x4(%eax),%ecx
f0105d12:	8d 40 08             	lea    0x8(%eax),%eax
f0105d15:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105d18:	b8 10 00 00 00       	mov    $0x10,%eax
f0105d1d:	eb a7                	jmp    f0105cc6 <vprintfmt+0x3a6>
	else if (lflag)
f0105d1f:	85 c9                	test   %ecx,%ecx
f0105d21:	75 17                	jne    f0105d3a <vprintfmt+0x41a>
		return va_arg(*ap, unsigned int);
f0105d23:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d26:	8b 10                	mov    (%eax),%edx
f0105d28:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105d2d:	8d 40 04             	lea    0x4(%eax),%eax
f0105d30:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105d33:	b8 10 00 00 00       	mov    $0x10,%eax
f0105d38:	eb 8c                	jmp    f0105cc6 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0105d3a:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d3d:	8b 10                	mov    (%eax),%edx
f0105d3f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105d44:	8d 40 04             	lea    0x4(%eax),%eax
f0105d47:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105d4a:	b8 10 00 00 00       	mov    $0x10,%eax
f0105d4f:	e9 72 ff ff ff       	jmp    f0105cc6 <vprintfmt+0x3a6>
			putch(ch, putdat);
f0105d54:	83 ec 08             	sub    $0x8,%esp
f0105d57:	53                   	push   %ebx
f0105d58:	6a 25                	push   $0x25
f0105d5a:	ff d6                	call   *%esi
			break;
f0105d5c:	83 c4 10             	add    $0x10,%esp
f0105d5f:	e9 7c ff ff ff       	jmp    f0105ce0 <vprintfmt+0x3c0>
			putch('%', putdat);
f0105d64:	83 ec 08             	sub    $0x8,%esp
f0105d67:	53                   	push   %ebx
f0105d68:	6a 25                	push   $0x25
f0105d6a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105d6c:	83 c4 10             	add    $0x10,%esp
f0105d6f:	89 f8                	mov    %edi,%eax
f0105d71:	eb 01                	jmp    f0105d74 <vprintfmt+0x454>
f0105d73:	48                   	dec    %eax
f0105d74:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0105d78:	75 f9                	jne    f0105d73 <vprintfmt+0x453>
f0105d7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105d7d:	e9 5e ff ff ff       	jmp    f0105ce0 <vprintfmt+0x3c0>
}
f0105d82:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105d85:	5b                   	pop    %ebx
f0105d86:	5e                   	pop    %esi
f0105d87:	5f                   	pop    %edi
f0105d88:	5d                   	pop    %ebp
f0105d89:	c3                   	ret    

f0105d8a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105d8a:	55                   	push   %ebp
f0105d8b:	89 e5                	mov    %esp,%ebp
f0105d8d:	83 ec 18             	sub    $0x18,%esp
f0105d90:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d93:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105d96:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105d99:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105d9d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105da0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105da7:	85 c0                	test   %eax,%eax
f0105da9:	74 26                	je     f0105dd1 <vsnprintf+0x47>
f0105dab:	85 d2                	test   %edx,%edx
f0105dad:	7e 29                	jle    f0105dd8 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105daf:	ff 75 14             	pushl  0x14(%ebp)
f0105db2:	ff 75 10             	pushl  0x10(%ebp)
f0105db5:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105db8:	50                   	push   %eax
f0105db9:	68 e7 58 10 f0       	push   $0xf01058e7
f0105dbe:	e8 5d fb ff ff       	call   f0105920 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105dc3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105dc6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105dc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105dcc:	83 c4 10             	add    $0x10,%esp
}
f0105dcf:	c9                   	leave  
f0105dd0:	c3                   	ret    
		return -E_INVAL;
f0105dd1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105dd6:	eb f7                	jmp    f0105dcf <vsnprintf+0x45>
f0105dd8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105ddd:	eb f0                	jmp    f0105dcf <vsnprintf+0x45>

f0105ddf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105ddf:	55                   	push   %ebp
f0105de0:	89 e5                	mov    %esp,%ebp
f0105de2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105de5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105de8:	50                   	push   %eax
f0105de9:	ff 75 10             	pushl  0x10(%ebp)
f0105dec:	ff 75 0c             	pushl  0xc(%ebp)
f0105def:	ff 75 08             	pushl  0x8(%ebp)
f0105df2:	e8 93 ff ff ff       	call   f0105d8a <vsnprintf>
	va_end(ap);

	return rc;
}
f0105df7:	c9                   	leave  
f0105df8:	c3                   	ret    

f0105df9 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105df9:	55                   	push   %ebp
f0105dfa:	89 e5                	mov    %esp,%ebp
f0105dfc:	57                   	push   %edi
f0105dfd:	56                   	push   %esi
f0105dfe:	53                   	push   %ebx
f0105dff:	83 ec 0c             	sub    $0xc,%esp
f0105e02:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105e05:	85 c0                	test   %eax,%eax
f0105e07:	74 11                	je     f0105e1a <readline+0x21>
		cprintf("%s", prompt);
f0105e09:	83 ec 08             	sub    $0x8,%esp
f0105e0c:	50                   	push   %eax
f0105e0d:	68 b5 7f 10 f0       	push   $0xf0107fb5
f0105e12:	e8 6d e1 ff ff       	call   f0103f84 <cprintf>
f0105e17:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105e1a:	83 ec 0c             	sub    $0xc,%esp
f0105e1d:	6a 00                	push   $0x0
f0105e1f:	e8 4d aa ff ff       	call   f0100871 <iscons>
f0105e24:	89 c7                	mov    %eax,%edi
f0105e26:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0105e29:	be 00 00 00 00       	mov    $0x0,%esi
f0105e2e:	eb 7b                	jmp    f0105eab <readline+0xb2>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f0105e30:	83 f8 f8             	cmp    $0xfffffff8,%eax
f0105e33:	75 07                	jne    f0105e3c <readline+0x43>
				cprintf("read error: %e\n", c);
			return NULL;
f0105e35:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e3a:	eb 4f                	jmp    f0105e8b <readline+0x92>
				cprintf("read error: %e\n", c);
f0105e3c:	83 ec 08             	sub    $0x8,%esp
f0105e3f:	50                   	push   %eax
f0105e40:	68 3f 8b 10 f0       	push   $0xf0108b3f
f0105e45:	e8 3a e1 ff ff       	call   f0103f84 <cprintf>
f0105e4a:	83 c4 10             	add    $0x10,%esp
			return NULL;
f0105e4d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e52:	eb 37                	jmp    f0105e8b <readline+0x92>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
			if (echoing)
				cputchar('\b');
f0105e54:	83 ec 0c             	sub    $0xc,%esp
f0105e57:	6a 08                	push   $0x8
f0105e59:	e8 f2 a9 ff ff       	call   f0100850 <cputchar>
f0105e5e:	83 c4 10             	add    $0x10,%esp
f0105e61:	eb 47                	jmp    f0105eaa <readline+0xb1>
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
f0105e63:	83 ec 0c             	sub    $0xc,%esp
f0105e66:	53                   	push   %ebx
f0105e67:	e8 e4 a9 ff ff       	call   f0100850 <cputchar>
f0105e6c:	83 c4 10             	add    $0x10,%esp
f0105e6f:	eb 64                	jmp    f0105ed5 <readline+0xdc>
			buf[i++] = c;
		} else if (c == '\n' || c == '\r') {
f0105e71:	83 fb 0a             	cmp    $0xa,%ebx
f0105e74:	74 05                	je     f0105e7b <readline+0x82>
f0105e76:	83 fb 0d             	cmp    $0xd,%ebx
f0105e79:	75 30                	jne    f0105eab <readline+0xb2>
			if (echoing)
f0105e7b:	85 ff                	test   %edi,%edi
f0105e7d:	75 14                	jne    f0105e93 <readline+0x9a>
				cputchar('\n');
			buf[i] = 0;
f0105e7f:	c6 86 80 7a 2a f0 00 	movb   $0x0,-0xfd58580(%esi)
			return buf;
f0105e86:	b8 80 7a 2a f0       	mov    $0xf02a7a80,%eax
		}
	}
}
f0105e8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105e8e:	5b                   	pop    %ebx
f0105e8f:	5e                   	pop    %esi
f0105e90:	5f                   	pop    %edi
f0105e91:	5d                   	pop    %ebp
f0105e92:	c3                   	ret    
				cputchar('\n');
f0105e93:	83 ec 0c             	sub    $0xc,%esp
f0105e96:	6a 0a                	push   $0xa
f0105e98:	e8 b3 a9 ff ff       	call   f0100850 <cputchar>
f0105e9d:	83 c4 10             	add    $0x10,%esp
f0105ea0:	eb dd                	jmp    f0105e7f <readline+0x86>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105ea2:	85 f6                	test   %esi,%esi
f0105ea4:	7e 40                	jle    f0105ee6 <readline+0xed>
			if (echoing)
f0105ea6:	85 ff                	test   %edi,%edi
f0105ea8:	75 aa                	jne    f0105e54 <readline+0x5b>
			i--;
f0105eaa:	4e                   	dec    %esi
		c = getchar();
f0105eab:	e8 b0 a9 ff ff       	call   f0100860 <getchar>
f0105eb0:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105eb2:	85 c0                	test   %eax,%eax
f0105eb4:	0f 88 76 ff ff ff    	js     f0105e30 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105eba:	83 f8 08             	cmp    $0x8,%eax
f0105ebd:	74 21                	je     f0105ee0 <readline+0xe7>
f0105ebf:	83 f8 7f             	cmp    $0x7f,%eax
f0105ec2:	74 de                	je     f0105ea2 <readline+0xa9>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105ec4:	83 f8 1f             	cmp    $0x1f,%eax
f0105ec7:	7e a8                	jle    f0105e71 <readline+0x78>
f0105ec9:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105ecf:	7f a0                	jg     f0105e71 <readline+0x78>
			if (echoing)
f0105ed1:	85 ff                	test   %edi,%edi
f0105ed3:	75 8e                	jne    f0105e63 <readline+0x6a>
			buf[i++] = c;
f0105ed5:	88 9e 80 7a 2a f0    	mov    %bl,-0xfd58580(%esi)
f0105edb:	8d 76 01             	lea    0x1(%esi),%esi
f0105ede:	eb cb                	jmp    f0105eab <readline+0xb2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105ee0:	85 f6                	test   %esi,%esi
f0105ee2:	7e c7                	jle    f0105eab <readline+0xb2>
f0105ee4:	eb c0                	jmp    f0105ea6 <readline+0xad>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105ee6:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105eec:	7e e3                	jle    f0105ed1 <readline+0xd8>
f0105eee:	eb bb                	jmp    f0105eab <readline+0xb2>

f0105ef0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105ef0:	55                   	push   %ebp
f0105ef1:	89 e5                	mov    %esp,%ebp
f0105ef3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105ef6:	b8 00 00 00 00       	mov    $0x0,%eax
f0105efb:	eb 01                	jmp    f0105efe <strlen+0xe>
		n++;
f0105efd:	40                   	inc    %eax
	for (n = 0; *s != '\0'; s++)
f0105efe:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105f02:	75 f9                	jne    f0105efd <strlen+0xd>
	return n;
}
f0105f04:	5d                   	pop    %ebp
f0105f05:	c3                   	ret    

f0105f06 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105f06:	55                   	push   %ebp
f0105f07:	89 e5                	mov    %esp,%ebp
f0105f09:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105f0c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105f0f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f14:	eb 01                	jmp    f0105f17 <strnlen+0x11>
		n++;
f0105f16:	40                   	inc    %eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105f17:	39 d0                	cmp    %edx,%eax
f0105f19:	74 06                	je     f0105f21 <strnlen+0x1b>
f0105f1b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105f1f:	75 f5                	jne    f0105f16 <strnlen+0x10>
	return n;
}
f0105f21:	5d                   	pop    %ebp
f0105f22:	c3                   	ret    

f0105f23 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105f23:	55                   	push   %ebp
f0105f24:	89 e5                	mov    %esp,%ebp
f0105f26:	53                   	push   %ebx
f0105f27:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105f2d:	89 c2                	mov    %eax,%edx
f0105f2f:	41                   	inc    %ecx
f0105f30:	42                   	inc    %edx
f0105f31:	8a 59 ff             	mov    -0x1(%ecx),%bl
f0105f34:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105f37:	84 db                	test   %bl,%bl
f0105f39:	75 f4                	jne    f0105f2f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105f3b:	5b                   	pop    %ebx
f0105f3c:	5d                   	pop    %ebp
f0105f3d:	c3                   	ret    

f0105f3e <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105f3e:	55                   	push   %ebp
f0105f3f:	89 e5                	mov    %esp,%ebp
f0105f41:	53                   	push   %ebx
f0105f42:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105f45:	53                   	push   %ebx
f0105f46:	e8 a5 ff ff ff       	call   f0105ef0 <strlen>
f0105f4b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105f4e:	ff 75 0c             	pushl  0xc(%ebp)
f0105f51:	01 d8                	add    %ebx,%eax
f0105f53:	50                   	push   %eax
f0105f54:	e8 ca ff ff ff       	call   f0105f23 <strcpy>
	return dst;
}
f0105f59:	89 d8                	mov    %ebx,%eax
f0105f5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105f5e:	c9                   	leave  
f0105f5f:	c3                   	ret    

f0105f60 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105f60:	55                   	push   %ebp
f0105f61:	89 e5                	mov    %esp,%ebp
f0105f63:	56                   	push   %esi
f0105f64:	53                   	push   %ebx
f0105f65:	8b 75 08             	mov    0x8(%ebp),%esi
f0105f68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105f6b:	89 f3                	mov    %esi,%ebx
f0105f6d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105f70:	89 f2                	mov    %esi,%edx
f0105f72:	39 da                	cmp    %ebx,%edx
f0105f74:	74 0e                	je     f0105f84 <strncpy+0x24>
		*dst++ = *src;
f0105f76:	42                   	inc    %edx
f0105f77:	8a 01                	mov    (%ecx),%al
f0105f79:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f0105f7c:	80 39 00             	cmpb   $0x0,(%ecx)
f0105f7f:	74 f1                	je     f0105f72 <strncpy+0x12>
			src++;
f0105f81:	41                   	inc    %ecx
f0105f82:	eb ee                	jmp    f0105f72 <strncpy+0x12>
	}
	return ret;
}
f0105f84:	89 f0                	mov    %esi,%eax
f0105f86:	5b                   	pop    %ebx
f0105f87:	5e                   	pop    %esi
f0105f88:	5d                   	pop    %ebp
f0105f89:	c3                   	ret    

f0105f8a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105f8a:	55                   	push   %ebp
f0105f8b:	89 e5                	mov    %esp,%ebp
f0105f8d:	56                   	push   %esi
f0105f8e:	53                   	push   %ebx
f0105f8f:	8b 75 08             	mov    0x8(%ebp),%esi
f0105f92:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105f95:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105f98:	85 c0                	test   %eax,%eax
f0105f9a:	74 20                	je     f0105fbc <strlcpy+0x32>
f0105f9c:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
f0105fa0:	89 f0                	mov    %esi,%eax
f0105fa2:	eb 05                	jmp    f0105fa9 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105fa4:	42                   	inc    %edx
f0105fa5:	40                   	inc    %eax
f0105fa6:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0105fa9:	39 d8                	cmp    %ebx,%eax
f0105fab:	74 06                	je     f0105fb3 <strlcpy+0x29>
f0105fad:	8a 0a                	mov    (%edx),%cl
f0105faf:	84 c9                	test   %cl,%cl
f0105fb1:	75 f1                	jne    f0105fa4 <strlcpy+0x1a>
		*dst = '\0';
f0105fb3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105fb6:	29 f0                	sub    %esi,%eax
}
f0105fb8:	5b                   	pop    %ebx
f0105fb9:	5e                   	pop    %esi
f0105fba:	5d                   	pop    %ebp
f0105fbb:	c3                   	ret    
f0105fbc:	89 f0                	mov    %esi,%eax
f0105fbe:	eb f6                	jmp    f0105fb6 <strlcpy+0x2c>

f0105fc0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105fc0:	55                   	push   %ebp
f0105fc1:	89 e5                	mov    %esp,%ebp
f0105fc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105fc6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105fc9:	eb 02                	jmp    f0105fcd <strcmp+0xd>
		p++, q++;
f0105fcb:	41                   	inc    %ecx
f0105fcc:	42                   	inc    %edx
	while (*p && *p == *q)
f0105fcd:	8a 01                	mov    (%ecx),%al
f0105fcf:	84 c0                	test   %al,%al
f0105fd1:	74 04                	je     f0105fd7 <strcmp+0x17>
f0105fd3:	3a 02                	cmp    (%edx),%al
f0105fd5:	74 f4                	je     f0105fcb <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105fd7:	0f b6 c0             	movzbl %al,%eax
f0105fda:	0f b6 12             	movzbl (%edx),%edx
f0105fdd:	29 d0                	sub    %edx,%eax
}
f0105fdf:	5d                   	pop    %ebp
f0105fe0:	c3                   	ret    

f0105fe1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105fe1:	55                   	push   %ebp
f0105fe2:	89 e5                	mov    %esp,%ebp
f0105fe4:	53                   	push   %ebx
f0105fe5:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fe8:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105feb:	89 c3                	mov    %eax,%ebx
f0105fed:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105ff0:	eb 02                	jmp    f0105ff4 <strncmp+0x13>
		n--, p++, q++;
f0105ff2:	40                   	inc    %eax
f0105ff3:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
f0105ff4:	39 d8                	cmp    %ebx,%eax
f0105ff6:	74 15                	je     f010600d <strncmp+0x2c>
f0105ff8:	8a 08                	mov    (%eax),%cl
f0105ffa:	84 c9                	test   %cl,%cl
f0105ffc:	74 04                	je     f0106002 <strncmp+0x21>
f0105ffe:	3a 0a                	cmp    (%edx),%cl
f0106000:	74 f0                	je     f0105ff2 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0106002:	0f b6 00             	movzbl (%eax),%eax
f0106005:	0f b6 12             	movzbl (%edx),%edx
f0106008:	29 d0                	sub    %edx,%eax
}
f010600a:	5b                   	pop    %ebx
f010600b:	5d                   	pop    %ebp
f010600c:	c3                   	ret    
		return 0;
f010600d:	b8 00 00 00 00       	mov    $0x0,%eax
f0106012:	eb f6                	jmp    f010600a <strncmp+0x29>

f0106014 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0106014:	55                   	push   %ebp
f0106015:	89 e5                	mov    %esp,%ebp
f0106017:	8b 45 08             	mov    0x8(%ebp),%eax
f010601a:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010601d:	8a 10                	mov    (%eax),%dl
f010601f:	84 d2                	test   %dl,%dl
f0106021:	74 07                	je     f010602a <strchr+0x16>
		if (*s == c)
f0106023:	38 ca                	cmp    %cl,%dl
f0106025:	74 08                	je     f010602f <strchr+0x1b>
	for (; *s; s++)
f0106027:	40                   	inc    %eax
f0106028:	eb f3                	jmp    f010601d <strchr+0x9>
			return (char *) s;
	return 0;
f010602a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010602f:	5d                   	pop    %ebp
f0106030:	c3                   	ret    

f0106031 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0106031:	55                   	push   %ebp
f0106032:	89 e5                	mov    %esp,%ebp
f0106034:	8b 45 08             	mov    0x8(%ebp),%eax
f0106037:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010603a:	8a 10                	mov    (%eax),%dl
f010603c:	84 d2                	test   %dl,%dl
f010603e:	74 07                	je     f0106047 <strfind+0x16>
		if (*s == c)
f0106040:	38 ca                	cmp    %cl,%dl
f0106042:	74 03                	je     f0106047 <strfind+0x16>
	for (; *s; s++)
f0106044:	40                   	inc    %eax
f0106045:	eb f3                	jmp    f010603a <strfind+0x9>
			break;
	return (char *) s;
}
f0106047:	5d                   	pop    %ebp
f0106048:	c3                   	ret    

f0106049 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0106049:	55                   	push   %ebp
f010604a:	89 e5                	mov    %esp,%ebp
f010604c:	57                   	push   %edi
f010604d:	56                   	push   %esi
f010604e:	53                   	push   %ebx
f010604f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106052:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0106055:	85 c9                	test   %ecx,%ecx
f0106057:	74 13                	je     f010606c <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0106059:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010605f:	75 05                	jne    f0106066 <memset+0x1d>
f0106061:	f6 c1 03             	test   $0x3,%cl
f0106064:	74 0d                	je     f0106073 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0106066:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106069:	fc                   	cld    
f010606a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010606c:	89 f8                	mov    %edi,%eax
f010606e:	5b                   	pop    %ebx
f010606f:	5e                   	pop    %esi
f0106070:	5f                   	pop    %edi
f0106071:	5d                   	pop    %ebp
f0106072:	c3                   	ret    
		c &= 0xFF;
f0106073:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0106077:	89 d3                	mov    %edx,%ebx
f0106079:	c1 e3 08             	shl    $0x8,%ebx
f010607c:	89 d0                	mov    %edx,%eax
f010607e:	c1 e0 18             	shl    $0x18,%eax
f0106081:	89 d6                	mov    %edx,%esi
f0106083:	c1 e6 10             	shl    $0x10,%esi
f0106086:	09 f0                	or     %esi,%eax
f0106088:	09 c2                	or     %eax,%edx
f010608a:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f010608c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010608f:	89 d0                	mov    %edx,%eax
f0106091:	fc                   	cld    
f0106092:	f3 ab                	rep stos %eax,%es:(%edi)
f0106094:	eb d6                	jmp    f010606c <memset+0x23>

f0106096 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0106096:	55                   	push   %ebp
f0106097:	89 e5                	mov    %esp,%ebp
f0106099:	57                   	push   %edi
f010609a:	56                   	push   %esi
f010609b:	8b 45 08             	mov    0x8(%ebp),%eax
f010609e:	8b 75 0c             	mov    0xc(%ebp),%esi
f01060a1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01060a4:	39 c6                	cmp    %eax,%esi
f01060a6:	73 33                	jae    f01060db <memmove+0x45>
f01060a8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01060ab:	39 c2                	cmp    %eax,%edx
f01060ad:	76 2c                	jbe    f01060db <memmove+0x45>
		s += n;
		d += n;
f01060af:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01060b2:	89 d6                	mov    %edx,%esi
f01060b4:	09 fe                	or     %edi,%esi
f01060b6:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01060bc:	74 0a                	je     f01060c8 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01060be:	4f                   	dec    %edi
f01060bf:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01060c2:	fd                   	std    
f01060c3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01060c5:	fc                   	cld    
f01060c6:	eb 21                	jmp    f01060e9 <memmove+0x53>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01060c8:	f6 c1 03             	test   $0x3,%cl
f01060cb:	75 f1                	jne    f01060be <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01060cd:	83 ef 04             	sub    $0x4,%edi
f01060d0:	8d 72 fc             	lea    -0x4(%edx),%esi
f01060d3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01060d6:	fd                   	std    
f01060d7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01060d9:	eb ea                	jmp    f01060c5 <memmove+0x2f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01060db:	89 f2                	mov    %esi,%edx
f01060dd:	09 c2                	or     %eax,%edx
f01060df:	f6 c2 03             	test   $0x3,%dl
f01060e2:	74 09                	je     f01060ed <memmove+0x57>
			asm volatile("cld; rep movsl\n"
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
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01060ed:	f6 c1 03             	test   $0x3,%cl
f01060f0:	75 f2                	jne    f01060e4 <memmove+0x4e>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01060f2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01060f5:	89 c7                	mov    %eax,%edi
f01060f7:	fc                   	cld    
f01060f8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01060fa:	eb ed                	jmp    f01060e9 <memmove+0x53>

f01060fc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01060fc:	55                   	push   %ebp
f01060fd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01060ff:	ff 75 10             	pushl  0x10(%ebp)
f0106102:	ff 75 0c             	pushl  0xc(%ebp)
f0106105:	ff 75 08             	pushl  0x8(%ebp)
f0106108:	e8 89 ff ff ff       	call   f0106096 <memmove>
}
f010610d:	c9                   	leave  
f010610e:	c3                   	ret    

f010610f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010610f:	55                   	push   %ebp
f0106110:	89 e5                	mov    %esp,%ebp
f0106112:	56                   	push   %esi
f0106113:	53                   	push   %ebx
f0106114:	8b 45 08             	mov    0x8(%ebp),%eax
f0106117:	8b 55 0c             	mov    0xc(%ebp),%edx
f010611a:	89 c6                	mov    %eax,%esi
f010611c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010611f:	39 f0                	cmp    %esi,%eax
f0106121:	74 16                	je     f0106139 <memcmp+0x2a>
		if (*s1 != *s2)
f0106123:	8a 08                	mov    (%eax),%cl
f0106125:	8a 1a                	mov    (%edx),%bl
f0106127:	38 d9                	cmp    %bl,%cl
f0106129:	75 04                	jne    f010612f <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010612b:	40                   	inc    %eax
f010612c:	42                   	inc    %edx
f010612d:	eb f0                	jmp    f010611f <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f010612f:	0f b6 c1             	movzbl %cl,%eax
f0106132:	0f b6 db             	movzbl %bl,%ebx
f0106135:	29 d8                	sub    %ebx,%eax
f0106137:	eb 05                	jmp    f010613e <memcmp+0x2f>
	}

	return 0;
f0106139:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010613e:	5b                   	pop    %ebx
f010613f:	5e                   	pop    %esi
f0106140:	5d                   	pop    %ebp
f0106141:	c3                   	ret    

f0106142 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0106142:	55                   	push   %ebp
f0106143:	89 e5                	mov    %esp,%ebp
f0106145:	8b 45 08             	mov    0x8(%ebp),%eax
f0106148:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010614b:	89 c2                	mov    %eax,%edx
f010614d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0106150:	39 d0                	cmp    %edx,%eax
f0106152:	73 07                	jae    f010615b <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
f0106154:	38 08                	cmp    %cl,(%eax)
f0106156:	74 03                	je     f010615b <memfind+0x19>
	for (; s < ends; s++)
f0106158:	40                   	inc    %eax
f0106159:	eb f5                	jmp    f0106150 <memfind+0xe>
			break;
	return (void *) s;
}
f010615b:	5d                   	pop    %ebp
f010615c:	c3                   	ret    

f010615d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010615d:	55                   	push   %ebp
f010615e:	89 e5                	mov    %esp,%ebp
f0106160:	57                   	push   %edi
f0106161:	56                   	push   %esi
f0106162:	53                   	push   %ebx
f0106163:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106166:	eb 01                	jmp    f0106169 <strtol+0xc>
		s++;
f0106168:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f0106169:	8a 01                	mov    (%ecx),%al
f010616b:	3c 20                	cmp    $0x20,%al
f010616d:	74 f9                	je     f0106168 <strtol+0xb>
f010616f:	3c 09                	cmp    $0x9,%al
f0106171:	74 f5                	je     f0106168 <strtol+0xb>

	// plus/minus sign
	if (*s == '+')
f0106173:	3c 2b                	cmp    $0x2b,%al
f0106175:	74 2b                	je     f01061a2 <strtol+0x45>
		s++;
	else if (*s == '-')
f0106177:	3c 2d                	cmp    $0x2d,%al
f0106179:	74 2f                	je     f01061aa <strtol+0x4d>
	int neg = 0;
f010617b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106180:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f0106187:	75 12                	jne    f010619b <strtol+0x3e>
f0106189:	80 39 30             	cmpb   $0x30,(%ecx)
f010618c:	74 24                	je     f01061b2 <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010618e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0106192:	75 07                	jne    f010619b <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0106194:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f010619b:	b8 00 00 00 00       	mov    $0x0,%eax
f01061a0:	eb 4e                	jmp    f01061f0 <strtol+0x93>
		s++;
f01061a2:	41                   	inc    %ecx
	int neg = 0;
f01061a3:	bf 00 00 00 00       	mov    $0x0,%edi
f01061a8:	eb d6                	jmp    f0106180 <strtol+0x23>
		s++, neg = 1;
f01061aa:	41                   	inc    %ecx
f01061ab:	bf 01 00 00 00       	mov    $0x1,%edi
f01061b0:	eb ce                	jmp    f0106180 <strtol+0x23>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01061b2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01061b6:	74 10                	je     f01061c8 <strtol+0x6b>
	else if (base == 0 && s[0] == '0')
f01061b8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01061bc:	75 dd                	jne    f010619b <strtol+0x3e>
		s++, base = 8;
f01061be:	41                   	inc    %ecx
f01061bf:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f01061c6:	eb d3                	jmp    f010619b <strtol+0x3e>
		s += 2, base = 16;
f01061c8:	83 c1 02             	add    $0x2,%ecx
f01061cb:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f01061d2:	eb c7                	jmp    f010619b <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01061d4:	8d 72 9f             	lea    -0x61(%edx),%esi
f01061d7:	89 f3                	mov    %esi,%ebx
f01061d9:	80 fb 19             	cmp    $0x19,%bl
f01061dc:	77 24                	ja     f0106202 <strtol+0xa5>
			dig = *s - 'a' + 10;
f01061de:	0f be d2             	movsbl %dl,%edx
f01061e1:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01061e4:	3b 55 10             	cmp    0x10(%ebp),%edx
f01061e7:	7d 2b                	jge    f0106214 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
f01061e9:	41                   	inc    %ecx
f01061ea:	0f af 45 10          	imul   0x10(%ebp),%eax
f01061ee:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01061f0:	8a 11                	mov    (%ecx),%dl
f01061f2:	8d 5a d0             	lea    -0x30(%edx),%ebx
f01061f5:	80 fb 09             	cmp    $0x9,%bl
f01061f8:	77 da                	ja     f01061d4 <strtol+0x77>
			dig = *s - '0';
f01061fa:	0f be d2             	movsbl %dl,%edx
f01061fd:	83 ea 30             	sub    $0x30,%edx
f0106200:	eb e2                	jmp    f01061e4 <strtol+0x87>
		else if (*s >= 'A' && *s <= 'Z')
f0106202:	8d 72 bf             	lea    -0x41(%edx),%esi
f0106205:	89 f3                	mov    %esi,%ebx
f0106207:	80 fb 19             	cmp    $0x19,%bl
f010620a:	77 08                	ja     f0106214 <strtol+0xb7>
			dig = *s - 'A' + 10;
f010620c:	0f be d2             	movsbl %dl,%edx
f010620f:	83 ea 37             	sub    $0x37,%edx
f0106212:	eb d0                	jmp    f01061e4 <strtol+0x87>
		// we don't properly detect overflow!
	}

	if (endptr)
f0106214:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0106218:	74 05                	je     f010621f <strtol+0xc2>
		*endptr = (char *) s;
f010621a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010621d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f010621f:	85 ff                	test   %edi,%edi
f0106221:	74 02                	je     f0106225 <strtol+0xc8>
f0106223:	f7 d8                	neg    %eax
}
f0106225:	5b                   	pop    %ebx
f0106226:	5e                   	pop    %esi
f0106227:	5f                   	pop    %edi
f0106228:	5d                   	pop    %ebp
f0106229:	c3                   	ret    

f010622a <strtoul>:

unsigned long
strtoul(const char *s, char **endptr, int base)
{
f010622a:	55                   	push   %ebp
f010622b:	89 e5                	mov    %esp,%ebp
f010622d:	57                   	push   %edi
f010622e:	56                   	push   %esi
f010622f:	53                   	push   %ebx
f0106230:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	unsigned long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106233:	eb 01                	jmp    f0106236 <strtoul+0xc>
		s++;
f0106235:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f0106236:	8a 01                	mov    (%ecx),%al
f0106238:	3c 20                	cmp    $0x20,%al
f010623a:	74 f9                	je     f0106235 <strtoul+0xb>
f010623c:	3c 09                	cmp    $0x9,%al
f010623e:	74 f5                	je     f0106235 <strtoul+0xb>

	// plus/minus sign
	if (*s == '+')
f0106240:	3c 2b                	cmp    $0x2b,%al
f0106242:	74 2b                	je     f010626f <strtoul+0x45>
		s++;
	else if (*s == '-')
f0106244:	3c 2d                	cmp    $0x2d,%al
f0106246:	74 2f                	je     f0106277 <strtoul+0x4d>
	int neg = 0;
f0106248:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010624d:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f0106254:	75 12                	jne    f0106268 <strtoul+0x3e>
f0106256:	80 39 30             	cmpb   $0x30,(%ecx)
f0106259:	74 24                	je     f010627f <strtoul+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010625b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010625f:	75 07                	jne    f0106268 <strtoul+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0106261:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f0106268:	b8 00 00 00 00       	mov    $0x0,%eax
f010626d:	eb 4e                	jmp    f01062bd <strtoul+0x93>
		s++;
f010626f:	41                   	inc    %ecx
	int neg = 0;
f0106270:	bf 00 00 00 00       	mov    $0x0,%edi
f0106275:	eb d6                	jmp    f010624d <strtoul+0x23>
		s++, neg = 1;
f0106277:	41                   	inc    %ecx
f0106278:	bf 01 00 00 00       	mov    $0x1,%edi
f010627d:	eb ce                	jmp    f010624d <strtoul+0x23>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010627f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0106283:	74 10                	je     f0106295 <strtoul+0x6b>
	else if (base == 0 && s[0] == '0')
f0106285:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0106289:	75 dd                	jne    f0106268 <strtoul+0x3e>
		s++, base = 8;
f010628b:	41                   	inc    %ecx
f010628c:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f0106293:	eb d3                	jmp    f0106268 <strtoul+0x3e>
		s += 2, base = 16;
f0106295:	83 c1 02             	add    $0x2,%ecx
f0106298:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f010629f:	eb c7                	jmp    f0106268 <strtoul+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01062a1:	8d 72 9f             	lea    -0x61(%edx),%esi
f01062a4:	89 f3                	mov    %esi,%ebx
f01062a6:	80 fb 19             	cmp    $0x19,%bl
f01062a9:	77 24                	ja     f01062cf <strtoul+0xa5>
			dig = *s - 'a' + 10;
f01062ab:	0f be d2             	movsbl %dl,%edx
f01062ae:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01062b1:	3b 55 10             	cmp    0x10(%ebp),%edx
f01062b4:	7d 2b                	jge    f01062e1 <strtoul+0xb7>
			break;
		s++, val = (val * base) + dig;
f01062b6:	41                   	inc    %ecx
f01062b7:	0f af 45 10          	imul   0x10(%ebp),%eax
f01062bb:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01062bd:	8a 11                	mov    (%ecx),%dl
f01062bf:	8d 5a d0             	lea    -0x30(%edx),%ebx
f01062c2:	80 fb 09             	cmp    $0x9,%bl
f01062c5:	77 da                	ja     f01062a1 <strtoul+0x77>
			dig = *s - '0';
f01062c7:	0f be d2             	movsbl %dl,%edx
f01062ca:	83 ea 30             	sub    $0x30,%edx
f01062cd:	eb e2                	jmp    f01062b1 <strtoul+0x87>
		else if (*s >= 'A' && *s <= 'Z')
f01062cf:	8d 72 bf             	lea    -0x41(%edx),%esi
f01062d2:	89 f3                	mov    %esi,%ebx
f01062d4:	80 fb 19             	cmp    $0x19,%bl
f01062d7:	77 08                	ja     f01062e1 <strtoul+0xb7>
			dig = *s - 'A' + 10;
f01062d9:	0f be d2             	movsbl %dl,%edx
f01062dc:	83 ea 37             	sub    $0x37,%edx
f01062df:	eb d0                	jmp    f01062b1 <strtoul+0x87>
		// we don't properly detect overflow!
	}

	if (endptr)
f01062e1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01062e5:	74 05                	je     f01062ec <strtoul+0xc2>
		*endptr = (char *) s;
f01062e7:	8b 75 0c             	mov    0xc(%ebp),%esi
f01062ea:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f01062ec:	85 ff                	test   %edi,%edi
f01062ee:	74 02                	je     f01062f2 <strtoul+0xc8>
f01062f0:	f7 d8                	neg    %eax
}
f01062f2:	5b                   	pop    %ebx
f01062f3:	5e                   	pop    %esi
f01062f4:	5f                   	pop    %edi
f01062f5:	5d                   	pop    %ebp
f01062f6:	c3                   	ret    
f01062f7:	90                   	nop

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
f010633d:	8b 25 84 7e 2a f0    	mov    0xf02a7e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0106343:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106348:	b8 a1 02 10 f0       	mov    $0xf01002a1,%eax
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
f010637c:	8b 0d 88 7e 2a f0    	mov    0xf02a7e88,%ecx
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
f01063ad:	68 dd 8c 10 f0       	push   $0xf0108cdd
f01063b2:	e8 dd 9c ff ff       	call   f0100094 <_panic>
f01063b7:	56                   	push   %esi
f01063b8:	68 a8 6e 10 f0       	push   $0xf0106ea8
f01063bd:	6a 57                	push   $0x57
f01063bf:	68 dd 8c 10 f0       	push   $0xf0108cdd
f01063c4:	e8 cb 9c ff ff       	call   f0100094 <_panic>
f01063c9:	83 c3 10             	add    $0x10,%ebx
f01063cc:	39 f3                	cmp    %esi,%ebx
f01063ce:	73 2c                	jae    f01063fc <mpsearch1+0x89>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01063d0:	83 ec 04             	sub    $0x4,%esp
f01063d3:	6a 04                	push   $0x4
f01063d5:	68 ed 8c 10 f0       	push   $0xf0108ced
f01063da:	53                   	push   %ebx
f01063db:	e8 2f fd ff ff       	call   f010610f <memcmp>
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
f0106414:	c7 05 c0 83 2a f0 20 	movl   $0xf02a8020,0xf02a83c0
f010641b:	80 2a f0 
	if (PGNUM(pa) >= npages)
f010641e:	83 3d 88 7e 2a f0 00 	cmpl   $0x0,0xf02a7e88
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
f010646f:	3b 05 88 7e 2a f0    	cmp    0xf02a7e88,%eax
f0106475:	0f 83 a2 00 00 00    	jae    f010651d <mp_init+0x112>
	return (void *)(pa + KERNBASE);
f010647b:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
f0106481:	89 df                	mov    %ebx,%edi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106483:	83 ec 04             	sub    $0x4,%esp
f0106486:	6a 04                	push   $0x4
f0106488:	68 f2 8c 10 f0       	push   $0xf0108cf2
f010648d:	53                   	push   %ebx
f010648e:	e8 7c fc ff ff       	call   f010610f <memcmp>
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
f01064bb:	68 dd 8c 10 f0       	push   $0xf0108cdd
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
f010650b:	68 50 8b 10 f0       	push   $0xf0108b50
f0106510:	e8 6f da ff ff       	call   f0103f84 <cprintf>
f0106515:	83 c4 10             	add    $0x10,%esp
f0106518:	e9 9e 01 00 00       	jmp    f01066bb <mp_init+0x2b0>
f010651d:	56                   	push   %esi
f010651e:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0106523:	68 90 00 00 00       	push   $0x90
f0106528:	68 dd 8c 10 f0       	push   $0xf0108cdd
f010652d:	e8 62 9b ff ff       	call   f0100094 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106532:	83 ec 0c             	sub    $0xc,%esp
f0106535:	68 80 8b 10 f0       	push   $0xf0108b80
f010653a:	e8 45 da ff ff       	call   f0103f84 <cprintf>
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
f010656e:	68 b4 8b 10 f0       	push   $0xf0108bb4
f0106573:	e8 0c da ff ff       	call   f0103f84 <cprintf>
f0106578:	83 c4 10             	add    $0x10,%esp
f010657b:	e9 3b 01 00 00       	jmp    f01066bb <mp_init+0x2b0>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106580:	83 ec 08             	sub    $0x8,%esp
f0106583:	0f b6 d2             	movzbl %dl,%edx
f0106586:	52                   	push   %edx
f0106587:	68 d8 8b 10 f0       	push   $0xf0108bd8
f010658c:	e8 f3 d9 ff ff       	call   f0103f84 <cprintf>
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
f01065b4:	c7 05 00 80 2a f0 01 	movl   $0x1,0xf02a8000
f01065bb:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01065be:	8b 47 24             	mov    0x24(%edi),%eax
f01065c1:	a3 00 90 2e f0       	mov    %eax,0xf02e9000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01065c6:	8d 77 2c             	lea    0x2c(%edi),%esi
f01065c9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01065ce:	eb 60                	jmp    f0106630 <mp_init+0x225>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01065d0:	83 ec 0c             	sub    $0xc,%esp
f01065d3:	68 f8 8b 10 f0       	push   $0xf0108bf8
f01065d8:	e8 a7 d9 ff ff       	call   f0103f84 <cprintf>
f01065dd:	83 c4 10             	add    $0x10,%esp
f01065e0:	e9 d6 00 00 00       	jmp    f01066bb <mp_init+0x2b0>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01065e5:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f01065e9:	74 1e                	je     f0106609 <mp_init+0x1fe>
				bootcpu = &cpus[ncpu];
f01065eb:	8b 15 c4 83 2a f0    	mov    0xf02a83c4,%edx
f01065f1:	8d 04 12             	lea    (%edx,%edx,1),%eax
f01065f4:	01 d0                	add    %edx,%eax
f01065f6:	01 c0                	add    %eax,%eax
f01065f8:	01 d0                	add    %edx,%eax
f01065fa:	8d 04 82             	lea    (%edx,%eax,4),%eax
f01065fd:	8d 04 85 20 80 2a f0 	lea    -0xfd57fe0(,%eax,4),%eax
f0106604:	a3 c0 83 2a f0       	mov    %eax,0xf02a83c0
			if (ncpu < NCPU) {
f0106609:	a1 c4 83 2a f0       	mov    0xf02a83c4,%eax
f010660e:	83 f8 07             	cmp    $0x7,%eax
f0106611:	7f 34                	jg     f0106647 <mp_init+0x23c>
				cpus[ncpu].cpu_id = ncpu;
f0106613:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0106616:	01 c2                	add    %eax,%edx
f0106618:	01 d2                	add    %edx,%edx
f010661a:	01 c2                	add    %eax,%edx
f010661c:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010661f:	88 04 95 20 80 2a f0 	mov    %al,-0xfd57fe0(,%edx,4)
				ncpu++;
f0106626:	40                   	inc    %eax
f0106627:	a3 c4 83 2a f0       	mov    %eax,0xf02a83c4
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
f010664f:	68 28 8c 10 f0       	push   $0xf0108c28
f0106654:	e8 2b d9 ff ff       	call   f0103f84 <cprintf>
f0106659:	83 c4 10             	add    $0x10,%esp
f010665c:	eb ce                	jmp    f010662c <mp_init+0x221>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010665e:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0106661:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f0106664:	50                   	push   %eax
f0106665:	68 50 8c 10 f0       	push   $0xf0108c50
f010666a:	e8 15 d9 ff ff       	call   f0103f84 <cprintf>
			ismp = 0;
f010666f:	c7 05 00 80 2a f0 00 	movl   $0x0,0xf02a8000
f0106676:	00 00 00 
			i = conf->entry;
f0106679:	0f b7 5f 22          	movzwl 0x22(%edi),%ebx
f010667d:	83 c4 10             	add    $0x10,%esp
f0106680:	eb ad                	jmp    f010662f <mp_init+0x224>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106682:	a1 c0 83 2a f0       	mov    0xf02a83c0,%eax
f0106687:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010668e:	83 3d 00 80 2a f0 00 	cmpl   $0x0,0xf02a8000
f0106695:	75 2c                	jne    f01066c3 <mp_init+0x2b8>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106697:	c7 05 c4 83 2a f0 01 	movl   $0x1,0xf02a83c4
f010669e:	00 00 00 
		lapicaddr = 0;
f01066a1:	c7 05 00 90 2e f0 00 	movl   $0x0,0xf02e9000
f01066a8:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01066ab:	83 ec 0c             	sub    $0xc,%esp
f01066ae:	68 70 8c 10 f0       	push   $0xf0108c70
f01066b3:	e8 cc d8 ff ff       	call   f0103f84 <cprintf>
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
f01066c6:	ff 35 c4 83 2a f0    	pushl  0xf02a83c4
f01066cc:	0f b6 00             	movzbl (%eax),%eax
f01066cf:	50                   	push   %eax
f01066d0:	68 f7 8c 10 f0       	push   $0xf0108cf7
f01066d5:	e8 aa d8 ff ff       	call   f0103f84 <cprintf>
	if (mp->imcrp) {
f01066da:	83 c4 10             	add    $0x10,%esp
f01066dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01066e0:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01066e4:	74 d5                	je     f01066bb <mp_init+0x2b0>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01066e6:	83 ec 0c             	sub    $0xc,%esp
f01066e9:	68 9c 8c 10 f0       	push   $0xf0108c9c
f01066ee:	e8 91 d8 ff ff       	call   f0103f84 <cprintf>
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
f010670d:	8b 0d 04 90 2e f0    	mov    0xf02e9004,%ecx
f0106713:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0106716:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106718:	a1 04 90 2e f0       	mov    0xf02e9004,%eax
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
f0106725:	a1 04 90 2e f0       	mov    0xf02e9004,%eax
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
f010673d:	a1 00 90 2e f0       	mov    0xf02e9000,%eax
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
f0106753:	e8 64 b0 ff ff       	call   f01017bc <mmio_map_region>
f0106758:	a3 04 90 2e f0       	mov    %eax,0xf02e9004
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
f01067aa:	8d 04 85 20 80 2a f0 	lea    -0xfd57fe0(,%eax,4),%eax
f01067b1:	83 c4 10             	add    $0x10,%esp
f01067b4:	39 05 c0 83 2a f0    	cmp    %eax,0xf02a83c0
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
f01067da:	a1 04 90 2e f0       	mov    0xf02e9004,%eax
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
f0106843:	8b 15 04 90 2e f0    	mov    0xf02e9004,%edx
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
f0106879:	83 3d 04 90 2e f0 00 	cmpl   $0x0,0xf02e9004
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
f01068b2:	83 3d 88 7e 2a f0 00 	cmpl   $0x0,0xf02a7e88
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
f0106948:	68 14 8d 10 f0       	push   $0xf0108d14
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
f0106968:	8b 15 04 90 2e f0    	mov    0xf02e9004,%edx
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
f01069be:	8d 04 85 20 80 2a f0 	lea    -0xfd57fe0(,%eax,4),%eax
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
f01069d6:	68 24 8d 10 f0       	push   $0xf0108d24
f01069db:	6a 41                	push   $0x41
f01069dd:	68 88 8d 10 f0       	push   $0xf0108d88
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
f0106a03:	8d 04 85 20 80 2a f0 	lea    -0xfd57fe0(,%eax,4),%eax
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
f0106a61:	e8 30 f6 ff ff       	call   f0106096 <memmove>
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
f0106a77:	68 50 8d 10 f0       	push   $0xf0108d50
f0106a7c:	e8 03 d5 ff ff       	call   f0103f84 <cprintf>
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
f0106a9d:	8d 04 85 20 80 2a f0 	lea    -0xfd57fe0(,%eax,4),%eax
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
f0106ade:	68 98 8d 10 f0       	push   $0xf0108d98
f0106ae3:	e8 9c d4 ff ff       	call   f0103f84 <cprintf>
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
f0106b02:	e8 f1 ea ff ff       	call   f01055f8 <debuginfo_eip>
f0106b07:	83 c4 10             	add    $0x10,%esp
f0106b0a:	85 c0                	test   %eax,%eax
f0106b0c:	79 b8                	jns    f0106ac6 <spin_unlock+0x83>
				cprintf("  %08x\n", pcs[i]);
f0106b0e:	83 ec 08             	sub    $0x8,%esp
f0106b11:	ff 36                	pushl  (%esi)
f0106b13:	68 af 8d 10 f0       	push   $0xf0108daf
f0106b18:	e8 67 d4 ff ff       	call   f0103f84 <cprintf>
f0106b1d:	83 c4 10             	add    $0x10,%esp
f0106b20:	eb c9                	jmp    f0106aeb <spin_unlock+0xa8>
		panic("spin_unlock");
f0106b22:	83 ec 04             	sub    $0x4,%esp
f0106b25:	68 b7 8d 10 f0       	push   $0xf0108db7
f0106b2a:	6a 67                	push   $0x67
f0106b2c:	68 88 8d 10 f0       	push   $0xf0108d88
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
