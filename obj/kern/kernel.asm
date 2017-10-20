
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
f010004b:	68 60 64 10 f0       	push   $0xf0106460
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
f0100065:	e8 14 0d 00 00       	call   f0100d7e <mon_backtrace>
f010006a:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010006d:	83 ec 08             	sub    $0x8,%esp
f0100070:	53                   	push   %ebx
f0100071:	68 7c 64 10 f0       	push   $0xf010647c
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
f010009c:	83 3d 80 1e 29 f0 00 	cmpl   $0x0,0xf0291e80
f01000a3:	74 0f                	je     f01000b4 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000a5:	83 ec 0c             	sub    $0xc,%esp
f01000a8:	6a 00                	push   $0x0
f01000aa:	e8 73 0d 00 00       	call   f0100e22 <monitor>
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
f01000bf:	e8 72 5d 00 00       	call   f0105e36 <cpunum>
f01000c4:	ff 75 0c             	pushl  0xc(%ebp)
f01000c7:	ff 75 08             	pushl  0x8(%ebp)
f01000ca:	50                   	push   %eax
f01000cb:	68 64 65 10 f0       	push   $0xf0106564
f01000d0:	e8 be 3e 00 00       	call   f0103f93 <cprintf>
	vcprintf(fmt, ap);
f01000d5:	83 c4 08             	add    $0x8,%esp
f01000d8:	53                   	push   %ebx
f01000d9:	56                   	push   %esi
f01000da:	e8 8e 3e 00 00       	call   f0103f6d <vcprintf>
	cprintf("\n");
f01000df:	c7 04 24 1b 69 10 f0 	movl   $0xf010691b,(%esp)
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
f01000f7:	b8 08 30 2d f0       	mov    $0xf02d3008,%eax
f01000fc:	2d ec 0b 29 f0       	sub    $0xf0290bec,%eax
f0100101:	50                   	push   %eax
f0100102:	6a 00                	push   $0x0
f0100104:	68 ec 0b 29 f0       	push   $0xf0290bec
f0100109:	e8 4e 56 00 00       	call   f010575c <memset>
	cons_init();
f010010e:	e8 13 06 00 00       	call   f0100726 <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f0100113:	83 c4 08             	add    $0x8,%esp
f0100116:	68 ac 1a 00 00       	push   $0x1aac
f010011b:	68 97 64 10 f0       	push   $0xf0106497
f0100120:	e8 6e 3e 00 00       	call   f0103f93 <cprintf>
	mem_init();
f0100125:	e8 dd 16 00 00       	call   f0101807 <mem_init>
	cprintf(ANSI_COLOR_RED     "This text is RED!"     ANSI_COLOR_RESET "\n");
f010012a:	c7 04 24 b2 64 10 f0 	movl   $0xf01064b2,(%esp)
f0100131:	e8 5d 3e 00 00       	call   f0103f93 <cprintf>
	cprintf(ANSI_COLOR_GREEN   "This text is GREEN!"   ANSI_COLOR_RESET "\n");
f0100136:	c7 04 24 ce 64 10 f0 	movl   $0xf01064ce,(%esp)
f010013d:	e8 51 3e 00 00       	call   f0103f93 <cprintf>
	cprintf(ANSI_COLOR_YELLOW  "This text is YELLOW!"  ANSI_COLOR_RESET "\n");
f0100142:	c7 04 24 88 65 10 f0 	movl   $0xf0106588,(%esp)
f0100149:	e8 45 3e 00 00       	call   f0103f93 <cprintf>
	cprintf(ANSI_COLOR_BLUE    "This text is BLUE!"    ANSI_COLOR_RESET "\n");
f010014e:	c7 04 24 ec 64 10 f0 	movl   $0xf01064ec,(%esp)
f0100155:	e8 39 3e 00 00       	call   f0103f93 <cprintf>
	cprintf(ANSI_COLOR_MAGENTA "This text is MAGENTA!" ANSI_COLOR_RESET "\n");
f010015a:	c7 04 24 a8 65 10 f0 	movl   $0xf01065a8,(%esp)
f0100161:	e8 2d 3e 00 00       	call   f0103f93 <cprintf>
	cprintf(ANSI_COLOR_CYAN    "This text is CYAN!"    ANSI_COLOR_RESET "\n");
f0100166:	c7 04 24 09 65 10 f0 	movl   $0xf0106509,(%esp)
f010016d:	e8 21 3e 00 00       	call   f0103f93 <cprintf>
	test_backtrace(5);
f0100172:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100179:	e8 c2 fe ff ff       	call   f0100040 <test_backtrace>
	env_init();
f010017e:	e8 82 34 00 00       	call   f0103605 <env_init>
	trap_init();
f0100183:	e8 bf 3e 00 00       	call   f0104047 <trap_init>
	mp_init();
f0100188:	e8 92 59 00 00       	call   f0105b1f <mp_init>
	lapic_init();
f010018d:	e8 bf 5c 00 00       	call   f0105e51 <lapic_init>
	pic_init();
f0100192:	e8 38 3d 00 00       	call   f0103ecf <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100197:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f010019e:	e8 07 5f 00 00       	call   f01060aa <spin_lock>
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
f01001b2:	b8 86 5a 10 f0       	mov    $0xf0105a86,%eax
f01001b7:	2d 0c 5a 10 f0       	sub    $0xf0105a0c,%eax
f01001bc:	50                   	push   %eax
f01001bd:	68 0c 5a 10 f0       	push   $0xf0105a0c
f01001c2:	68 00 70 00 f0       	push   $0xf0007000
f01001c7:	e8 dd 55 00 00       	call   f01057a9 <memmove>
f01001cc:	83 c4 10             	add    $0x10,%esp
	for (c = cpus; c < cpus + ncpu; c++) {
f01001cf:	bb 20 20 29 f0       	mov    $0xf0292020,%ebx
f01001d4:	eb 19                	jmp    f01001ef <i386_init+0xff>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001d6:	68 00 70 00 00       	push   $0x7000
f01001db:	68 c8 65 10 f0       	push   $0xf01065c8
f01001e0:	6a 72                	push   $0x72
f01001e2:	68 26 65 10 f0       	push   $0xf0106526
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
f010020c:	e8 25 5c 00 00       	call   f0105e36 <cpunum>
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
f0100264:	e8 42 5d 00 00       	call   f0105fab <lapic_startap>
f0100269:	83 c4 10             	add    $0x10,%esp
		while(c->cpu_status != CPU_STARTED)
f010026c:	8b 43 04             	mov    0x4(%ebx),%eax
f010026f:	83 f8 01             	cmp    $0x1,%eax
f0100272:	75 f8                	jne    f010026c <i386_init+0x17c>
f0100274:	e9 73 ff ff ff       	jmp    f01001ec <i386_init+0xfc>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f0100279:	83 ec 08             	sub    $0x8,%esp
f010027c:	6a 00                	push   $0x0
f010027e:	68 5c 79 1c f0       	push   $0xf01c795c
f0100283:	e8 c8 35 00 00       	call   f0103850 <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f0100288:	83 c4 08             	add    $0x8,%esp
f010028b:	6a 00                	push   $0x0
f010028d:	68 5c 79 1c f0       	push   $0xf01c795c
f0100292:	e8 b9 35 00 00       	call   f0103850 <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f0100297:	83 c4 08             	add    $0x8,%esp
f010029a:	6a 00                	push   $0x0
f010029c:	68 5c 79 1c f0       	push   $0xf01c795c
f01002a1:	e8 aa 35 00 00       	call   f0103850 <env_create>
	sched_yield();
f01002a6:	e8 58 47 00 00       	call   f0104a03 <sched_yield>

f01002ab <mp_main>:
{
f01002ab:	55                   	push   %ebp
f01002ac:	89 e5                	mov    %esp,%ebp
f01002ae:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f01002b1:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01002b6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01002bb:	77 15                	ja     f01002d2 <mp_main+0x27>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01002bd:	50                   	push   %eax
f01002be:	68 ec 65 10 f0       	push   $0xf01065ec
f01002c3:	68 89 00 00 00       	push   $0x89
f01002c8:	68 26 65 10 f0       	push   $0xf0106526
f01002cd:	e8 c2 fd ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01002d2:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01002d7:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01002da:	e8 57 5b 00 00       	call   f0105e36 <cpunum>
f01002df:	83 ec 08             	sub    $0x8,%esp
f01002e2:	50                   	push   %eax
f01002e3:	68 32 65 10 f0       	push   $0xf0106532
f01002e8:	e8 a6 3c 00 00       	call   f0103f93 <cprintf>
	lapic_init();
f01002ed:	e8 5f 5b 00 00       	call   f0105e51 <lapic_init>
	env_init_percpu();
f01002f2:	e8 de 32 00 00       	call   f01035d5 <env_init_percpu>
	trap_init_percpu();
f01002f7:	e8 ab 3c 00 00       	call   f0103fa7 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01002fc:	e8 35 5b 00 00       	call   f0105e36 <cpunum>
f0100301:	6b d0 74             	imul   $0x74,%eax,%edx
f0100304:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100307:	b8 01 00 00 00       	mov    $0x1,%eax
f010030c:	f0 87 82 20 20 29 f0 	lock xchg %eax,-0xfd6dfe0(%edx)
f0100313:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f010031a:	e8 8b 5d 00 00       	call   f01060aa <spin_lock>
	sched_yield();
f010031f:	e8 df 46 00 00       	call   f0104a03 <sched_yield>

f0100324 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100324:	55                   	push   %ebp
f0100325:	89 e5                	mov    %esp,%ebp
f0100327:	53                   	push   %ebx
f0100328:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010032b:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010032e:	ff 75 0c             	pushl  0xc(%ebp)
f0100331:	ff 75 08             	pushl  0x8(%ebp)
f0100334:	68 48 65 10 f0       	push   $0xf0106548
f0100339:	e8 55 3c 00 00       	call   f0103f93 <cprintf>
	vcprintf(fmt, ap);
f010033e:	83 c4 08             	add    $0x8,%esp
f0100341:	53                   	push   %ebx
f0100342:	ff 75 10             	pushl  0x10(%ebp)
f0100345:	e8 23 3c 00 00       	call   f0103f6d <vcprintf>
	cprintf("\n");
f010034a:	c7 04 24 1b 69 10 f0 	movl   $0xf010691b,(%esp)
f0100351:	e8 3d 3c 00 00       	call   f0103f93 <cprintf>
	va_end(ap);
}
f0100356:	83 c4 10             	add    $0x10,%esp
f0100359:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010035c:	c9                   	leave  
f010035d:	c3                   	ret    

f010035e <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010035e:	55                   	push   %ebp
f010035f:	89 e5                	mov    %esp,%ebp
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100361:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100366:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100367:	a8 01                	test   $0x1,%al
f0100369:	74 0b                	je     f0100376 <serial_proc_data+0x18>
f010036b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100370:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100371:	0f b6 c0             	movzbl %al,%eax
}
f0100374:	5d                   	pop    %ebp
f0100375:	c3                   	ret    
		return -1;
f0100376:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010037b:	eb f7                	jmp    f0100374 <serial_proc_data+0x16>

f010037d <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010037d:	55                   	push   %ebp
f010037e:	89 e5                	mov    %esp,%ebp
f0100380:	53                   	push   %ebx
f0100381:	83 ec 04             	sub    $0x4,%esp
f0100384:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100386:	ff d3                	call   *%ebx
f0100388:	83 f8 ff             	cmp    $0xffffffff,%eax
f010038b:	74 2d                	je     f01003ba <cons_intr+0x3d>
		if (c == 0)
f010038d:	85 c0                	test   %eax,%eax
f010038f:	74 f5                	je     f0100386 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f0100391:	8b 0d 24 12 29 f0    	mov    0xf0291224,%ecx
f0100397:	8d 51 01             	lea    0x1(%ecx),%edx
f010039a:	89 15 24 12 29 f0    	mov    %edx,0xf0291224
f01003a0:	88 81 20 10 29 f0    	mov    %al,-0xfd6efe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01003a6:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01003ac:	75 d8                	jne    f0100386 <cons_intr+0x9>
			cons.wpos = 0;
f01003ae:	c7 05 24 12 29 f0 00 	movl   $0x0,0xf0291224
f01003b5:	00 00 00 
f01003b8:	eb cc                	jmp    f0100386 <cons_intr+0x9>
	}
}
f01003ba:	83 c4 04             	add    $0x4,%esp
f01003bd:	5b                   	pop    %ebx
f01003be:	5d                   	pop    %ebp
f01003bf:	c3                   	ret    

f01003c0 <kbd_proc_data>:
{
f01003c0:	55                   	push   %ebp
f01003c1:	89 e5                	mov    %esp,%ebp
f01003c3:	53                   	push   %ebx
f01003c4:	83 ec 04             	sub    $0x4,%esp
f01003c7:	ba 64 00 00 00       	mov    $0x64,%edx
f01003cc:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01003cd:	a8 01                	test   $0x1,%al
f01003cf:	0f 84 f1 00 00 00    	je     f01004c6 <kbd_proc_data+0x106>
	if (stat & KBS_TERR)
f01003d5:	a8 20                	test   $0x20,%al
f01003d7:	0f 85 f0 00 00 00    	jne    f01004cd <kbd_proc_data+0x10d>
f01003dd:	ba 60 00 00 00       	mov    $0x60,%edx
f01003e2:	ec                   	in     (%dx),%al
f01003e3:	88 c2                	mov    %al,%dl
	if (data == 0xE0) {
f01003e5:	3c e0                	cmp    $0xe0,%al
f01003e7:	0f 84 8a 00 00 00    	je     f0100477 <kbd_proc_data+0xb7>
	} else if (data & 0x80) {
f01003ed:	84 c0                	test   %al,%al
f01003ef:	0f 88 95 00 00 00    	js     f010048a <kbd_proc_data+0xca>
	} else if (shift & E0ESC) {
f01003f5:	8b 0d 00 10 29 f0    	mov    0xf0291000,%ecx
f01003fb:	f6 c1 40             	test   $0x40,%cl
f01003fe:	74 0e                	je     f010040e <kbd_proc_data+0x4e>
		data |= 0x80;
f0100400:	83 c8 80             	or     $0xffffff80,%eax
f0100403:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f0100405:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100408:	89 0d 00 10 29 f0    	mov    %ecx,0xf0291000
	shift |= shiftcode[data];
f010040e:	0f b6 d2             	movzbl %dl,%edx
f0100411:	0f b6 82 60 67 10 f0 	movzbl -0xfef98a0(%edx),%eax
f0100418:	0b 05 00 10 29 f0    	or     0xf0291000,%eax
	shift ^= togglecode[data];
f010041e:	0f b6 8a 60 66 10 f0 	movzbl -0xfef99a0(%edx),%ecx
f0100425:	31 c8                	xor    %ecx,%eax
f0100427:	a3 00 10 29 f0       	mov    %eax,0xf0291000
	c = charcode[shift & (CTL | SHIFT)][data];
f010042c:	89 c1                	mov    %eax,%ecx
f010042e:	83 e1 03             	and    $0x3,%ecx
f0100431:	8b 0c 8d 40 66 10 f0 	mov    -0xfef99c0(,%ecx,4),%ecx
f0100438:	8a 14 11             	mov    (%ecx,%edx,1),%dl
f010043b:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010043e:	a8 08                	test   $0x8,%al
f0100440:	74 0d                	je     f010044f <kbd_proc_data+0x8f>
		if ('a' <= c && c <= 'z')
f0100442:	89 da                	mov    %ebx,%edx
f0100444:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100447:	83 f9 19             	cmp    $0x19,%ecx
f010044a:	77 6d                	ja     f01004b9 <kbd_proc_data+0xf9>
			c += 'A' - 'a';
f010044c:	83 eb 20             	sub    $0x20,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010044f:	f7 d0                	not    %eax
f0100451:	a8 06                	test   $0x6,%al
f0100453:	75 2e                	jne    f0100483 <kbd_proc_data+0xc3>
f0100455:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010045b:	75 26                	jne    f0100483 <kbd_proc_data+0xc3>
		cprintf("Rebooting!\n");
f010045d:	83 ec 0c             	sub    $0xc,%esp
f0100460:	68 10 66 10 f0       	push   $0xf0106610
f0100465:	e8 29 3b 00 00       	call   f0103f93 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010046a:	b0 03                	mov    $0x3,%al
f010046c:	ba 92 00 00 00       	mov    $0x92,%edx
f0100471:	ee                   	out    %al,(%dx)
f0100472:	83 c4 10             	add    $0x10,%esp
f0100475:	eb 0c                	jmp    f0100483 <kbd_proc_data+0xc3>
		shift |= E0ESC;
f0100477:	83 0d 00 10 29 f0 40 	orl    $0x40,0xf0291000
		return 0;
f010047e:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100483:	89 d8                	mov    %ebx,%eax
f0100485:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100488:	c9                   	leave  
f0100489:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010048a:	8b 0d 00 10 29 f0    	mov    0xf0291000,%ecx
f0100490:	f6 c1 40             	test   $0x40,%cl
f0100493:	75 05                	jne    f010049a <kbd_proc_data+0xda>
f0100495:	83 e0 7f             	and    $0x7f,%eax
f0100498:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f010049a:	0f b6 d2             	movzbl %dl,%edx
f010049d:	8a 82 60 67 10 f0    	mov    -0xfef98a0(%edx),%al
f01004a3:	83 c8 40             	or     $0x40,%eax
f01004a6:	0f b6 c0             	movzbl %al,%eax
f01004a9:	f7 d0                	not    %eax
f01004ab:	21 c8                	and    %ecx,%eax
f01004ad:	a3 00 10 29 f0       	mov    %eax,0xf0291000
		return 0;
f01004b2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01004b7:	eb ca                	jmp    f0100483 <kbd_proc_data+0xc3>
		else if ('A' <= c && c <= 'Z')
f01004b9:	83 ea 41             	sub    $0x41,%edx
f01004bc:	83 fa 19             	cmp    $0x19,%edx
f01004bf:	77 8e                	ja     f010044f <kbd_proc_data+0x8f>
			c += 'a' - 'A';
f01004c1:	83 c3 20             	add    $0x20,%ebx
f01004c4:	eb 89                	jmp    f010044f <kbd_proc_data+0x8f>
		return -1;
f01004c6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01004cb:	eb b6                	jmp    f0100483 <kbd_proc_data+0xc3>
		return -1;
f01004cd:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01004d2:	eb af                	jmp    f0100483 <kbd_proc_data+0xc3>

f01004d4 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01004d4:	55                   	push   %ebp
f01004d5:	89 e5                	mov    %esp,%ebp
f01004d7:	57                   	push   %edi
f01004d8:	56                   	push   %esi
f01004d9:	53                   	push   %ebx
f01004da:	83 ec 1c             	sub    $0x1c,%esp
f01004dd:	89 c7                	mov    %eax,%edi
f01004df:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004e4:	be fd 03 00 00       	mov    $0x3fd,%esi
f01004e9:	b9 84 00 00 00       	mov    $0x84,%ecx
f01004ee:	eb 06                	jmp    f01004f6 <cons_putc+0x22>
f01004f0:	89 ca                	mov    %ecx,%edx
f01004f2:	ec                   	in     (%dx),%al
f01004f3:	ec                   	in     (%dx),%al
f01004f4:	ec                   	in     (%dx),%al
f01004f5:	ec                   	in     (%dx),%al
f01004f6:	89 f2                	mov    %esi,%edx
f01004f8:	ec                   	in     (%dx),%al
	for (i = 0;
f01004f9:	a8 20                	test   $0x20,%al
f01004fb:	75 03                	jne    f0100500 <cons_putc+0x2c>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01004fd:	4b                   	dec    %ebx
f01004fe:	75 f0                	jne    f01004f0 <cons_putc+0x1c>
	outb(COM1 + COM_TX, c);
f0100500:	89 f8                	mov    %edi,%eax
f0100502:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100505:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010050a:	ee                   	out    %al,(%dx)
f010050b:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100510:	be 79 03 00 00       	mov    $0x379,%esi
f0100515:	b9 84 00 00 00       	mov    $0x84,%ecx
f010051a:	eb 06                	jmp    f0100522 <cons_putc+0x4e>
f010051c:	89 ca                	mov    %ecx,%edx
f010051e:	ec                   	in     (%dx),%al
f010051f:	ec                   	in     (%dx),%al
f0100520:	ec                   	in     (%dx),%al
f0100521:	ec                   	in     (%dx),%al
f0100522:	89 f2                	mov    %esi,%edx
f0100524:	ec                   	in     (%dx),%al
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100525:	84 c0                	test   %al,%al
f0100527:	78 03                	js     f010052c <cons_putc+0x58>
f0100529:	4b                   	dec    %ebx
f010052a:	75 f0                	jne    f010051c <cons_putc+0x48>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010052c:	ba 78 03 00 00       	mov    $0x378,%edx
f0100531:	8a 45 e7             	mov    -0x19(%ebp),%al
f0100534:	ee                   	out    %al,(%dx)
f0100535:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010053a:	b0 0d                	mov    $0xd,%al
f010053c:	ee                   	out    %al,(%dx)
f010053d:	b0 08                	mov    $0x8,%al
f010053f:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f0100540:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100546:	75 06                	jne    f010054e <cons_putc+0x7a>
		c |= 0x0700;
f0100548:	81 cf 00 07 00 00    	or     $0x700,%edi
	switch (c & 0xff) {
f010054e:	89 f8                	mov    %edi,%eax
f0100550:	0f b6 c0             	movzbl %al,%eax
f0100553:	83 f8 09             	cmp    $0x9,%eax
f0100556:	0f 84 b1 00 00 00    	je     f010060d <cons_putc+0x139>
f010055c:	83 f8 09             	cmp    $0x9,%eax
f010055f:	7e 70                	jle    f01005d1 <cons_putc+0xfd>
f0100561:	83 f8 0a             	cmp    $0xa,%eax
f0100564:	0f 84 96 00 00 00    	je     f0100600 <cons_putc+0x12c>
f010056a:	83 f8 0d             	cmp    $0xd,%eax
f010056d:	0f 85 d1 00 00 00    	jne    f0100644 <cons_putc+0x170>
		crt_pos -= (crt_pos % CRT_COLS);
f0100573:	66 8b 0d 28 12 29 f0 	mov    0xf0291228,%cx
f010057a:	bb 50 00 00 00       	mov    $0x50,%ebx
f010057f:	89 c8                	mov    %ecx,%eax
f0100581:	ba 00 00 00 00       	mov    $0x0,%edx
f0100586:	66 f7 f3             	div    %bx
f0100589:	29 d1                	sub    %edx,%ecx
f010058b:	66 89 0d 28 12 29 f0 	mov    %cx,0xf0291228
	if (crt_pos >= CRT_SIZE) {
f0100592:	66 81 3d 28 12 29 f0 	cmpw   $0x7cf,0xf0291228
f0100599:	cf 07 
f010059b:	0f 87 c5 00 00 00    	ja     f0100666 <cons_putc+0x192>
	outb(addr_6845, 14);
f01005a1:	8b 0d 30 12 29 f0    	mov    0xf0291230,%ecx
f01005a7:	b0 0e                	mov    $0xe,%al
f01005a9:	89 ca                	mov    %ecx,%edx
f01005ab:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005ac:	8d 59 01             	lea    0x1(%ecx),%ebx
f01005af:	66 a1 28 12 29 f0    	mov    0xf0291228,%ax
f01005b5:	66 c1 e8 08          	shr    $0x8,%ax
f01005b9:	89 da                	mov    %ebx,%edx
f01005bb:	ee                   	out    %al,(%dx)
f01005bc:	b0 0f                	mov    $0xf,%al
f01005be:	89 ca                	mov    %ecx,%edx
f01005c0:	ee                   	out    %al,(%dx)
f01005c1:	a0 28 12 29 f0       	mov    0xf0291228,%al
f01005c6:	89 da                	mov    %ebx,%edx
f01005c8:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005cc:	5b                   	pop    %ebx
f01005cd:	5e                   	pop    %esi
f01005ce:	5f                   	pop    %edi
f01005cf:	5d                   	pop    %ebp
f01005d0:	c3                   	ret    
	switch (c & 0xff) {
f01005d1:	83 f8 08             	cmp    $0x8,%eax
f01005d4:	75 6e                	jne    f0100644 <cons_putc+0x170>
		if (crt_pos > 0) {
f01005d6:	66 a1 28 12 29 f0    	mov    0xf0291228,%ax
f01005dc:	66 85 c0             	test   %ax,%ax
f01005df:	74 c0                	je     f01005a1 <cons_putc+0xcd>
			crt_pos--;
f01005e1:	48                   	dec    %eax
f01005e2:	66 a3 28 12 29 f0    	mov    %ax,0xf0291228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01005e8:	0f b7 c0             	movzwl %ax,%eax
f01005eb:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f01005f1:	83 cf 20             	or     $0x20,%edi
f01005f4:	8b 15 2c 12 29 f0    	mov    0xf029122c,%edx
f01005fa:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01005fe:	eb 92                	jmp    f0100592 <cons_putc+0xbe>
		crt_pos += CRT_COLS;
f0100600:	66 83 05 28 12 29 f0 	addw   $0x50,0xf0291228
f0100607:	50 
f0100608:	e9 66 ff ff ff       	jmp    f0100573 <cons_putc+0x9f>
		cons_putc(' ');
f010060d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100612:	e8 bd fe ff ff       	call   f01004d4 <cons_putc>
		cons_putc(' ');
f0100617:	b8 20 00 00 00       	mov    $0x20,%eax
f010061c:	e8 b3 fe ff ff       	call   f01004d4 <cons_putc>
		cons_putc(' ');
f0100621:	b8 20 00 00 00       	mov    $0x20,%eax
f0100626:	e8 a9 fe ff ff       	call   f01004d4 <cons_putc>
		cons_putc(' ');
f010062b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100630:	e8 9f fe ff ff       	call   f01004d4 <cons_putc>
		cons_putc(' ');
f0100635:	b8 20 00 00 00       	mov    $0x20,%eax
f010063a:	e8 95 fe ff ff       	call   f01004d4 <cons_putc>
f010063f:	e9 4e ff ff ff       	jmp    f0100592 <cons_putc+0xbe>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100644:	66 a1 28 12 29 f0    	mov    0xf0291228,%ax
f010064a:	8d 50 01             	lea    0x1(%eax),%edx
f010064d:	66 89 15 28 12 29 f0 	mov    %dx,0xf0291228
f0100654:	0f b7 c0             	movzwl %ax,%eax
f0100657:	8b 15 2c 12 29 f0    	mov    0xf029122c,%edx
f010065d:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100661:	e9 2c ff ff ff       	jmp    f0100592 <cons_putc+0xbe>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100666:	a1 2c 12 29 f0       	mov    0xf029122c,%eax
f010066b:	83 ec 04             	sub    $0x4,%esp
f010066e:	68 00 0f 00 00       	push   $0xf00
f0100673:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100679:	52                   	push   %edx
f010067a:	50                   	push   %eax
f010067b:	e8 29 51 00 00       	call   f01057a9 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100680:	8b 15 2c 12 29 f0    	mov    0xf029122c,%edx
f0100686:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010068c:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100692:	83 c4 10             	add    $0x10,%esp
f0100695:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010069a:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010069d:	39 d0                	cmp    %edx,%eax
f010069f:	75 f4                	jne    f0100695 <cons_putc+0x1c1>
		crt_pos -= CRT_COLS;
f01006a1:	66 83 2d 28 12 29 f0 	subw   $0x50,0xf0291228
f01006a8:	50 
f01006a9:	e9 f3 fe ff ff       	jmp    f01005a1 <cons_putc+0xcd>

f01006ae <serial_intr>:
	if (serial_exists)
f01006ae:	80 3d 34 12 29 f0 00 	cmpb   $0x0,0xf0291234
f01006b5:	75 01                	jne    f01006b8 <serial_intr+0xa>
f01006b7:	c3                   	ret    
{
f01006b8:	55                   	push   %ebp
f01006b9:	89 e5                	mov    %esp,%ebp
f01006bb:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01006be:	b8 5e 03 10 f0       	mov    $0xf010035e,%eax
f01006c3:	e8 b5 fc ff ff       	call   f010037d <cons_intr>
}
f01006c8:	c9                   	leave  
f01006c9:	c3                   	ret    

f01006ca <kbd_intr>:
{
f01006ca:	55                   	push   %ebp
f01006cb:	89 e5                	mov    %esp,%ebp
f01006cd:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01006d0:	b8 c0 03 10 f0       	mov    $0xf01003c0,%eax
f01006d5:	e8 a3 fc ff ff       	call   f010037d <cons_intr>
}
f01006da:	c9                   	leave  
f01006db:	c3                   	ret    

f01006dc <cons_getc>:
{
f01006dc:	55                   	push   %ebp
f01006dd:	89 e5                	mov    %esp,%ebp
f01006df:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f01006e2:	e8 c7 ff ff ff       	call   f01006ae <serial_intr>
	kbd_intr();
f01006e7:	e8 de ff ff ff       	call   f01006ca <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01006ec:	a1 20 12 29 f0       	mov    0xf0291220,%eax
f01006f1:	3b 05 24 12 29 f0    	cmp    0xf0291224,%eax
f01006f7:	74 26                	je     f010071f <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01006f9:	8d 50 01             	lea    0x1(%eax),%edx
f01006fc:	89 15 20 12 29 f0    	mov    %edx,0xf0291220
f0100702:	0f b6 80 20 10 29 f0 	movzbl -0xfd6efe0(%eax),%eax
		if (cons.rpos == CONSBUFSIZE)
f0100709:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010070f:	74 02                	je     f0100713 <cons_getc+0x37>
}
f0100711:	c9                   	leave  
f0100712:	c3                   	ret    
			cons.rpos = 0;
f0100713:	c7 05 20 12 29 f0 00 	movl   $0x0,0xf0291220
f010071a:	00 00 00 
f010071d:	eb f2                	jmp    f0100711 <cons_getc+0x35>
	return 0;
f010071f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100724:	eb eb                	jmp    f0100711 <cons_getc+0x35>

f0100726 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100726:	55                   	push   %ebp
f0100727:	89 e5                	mov    %esp,%ebp
f0100729:	57                   	push   %edi
f010072a:	56                   	push   %esi
f010072b:	53                   	push   %ebx
f010072c:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f010072f:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f0100736:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010073d:	5a a5 
	if (*cp != 0xA55A) {
f010073f:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f0100745:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100749:	0f 84 be 00 00 00    	je     f010080d <cons_init+0xe7>
		addr_6845 = MONO_BASE;
f010074f:	c7 05 30 12 29 f0 b4 	movl   $0x3b4,0xf0291230
f0100756:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100759:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f010075e:	8b 3d 30 12 29 f0    	mov    0xf0291230,%edi
f0100764:	b0 0e                	mov    $0xe,%al
f0100766:	89 fa                	mov    %edi,%edx
f0100768:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100769:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010076c:	89 ca                	mov    %ecx,%edx
f010076e:	ec                   	in     (%dx),%al
f010076f:	0f b6 c0             	movzbl %al,%eax
f0100772:	c1 e0 08             	shl    $0x8,%eax
f0100775:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100777:	b0 0f                	mov    $0xf,%al
f0100779:	89 fa                	mov    %edi,%edx
f010077b:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010077c:	89 ca                	mov    %ecx,%edx
f010077e:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010077f:	89 35 2c 12 29 f0    	mov    %esi,0xf029122c
	pos |= inb(addr_6845 + 1);
f0100785:	0f b6 c0             	movzbl %al,%eax
f0100788:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f010078a:	66 a3 28 12 29 f0    	mov    %ax,0xf0291228
	kbd_intr();
f0100790:	e8 35 ff ff ff       	call   f01006ca <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f0100795:	83 ec 0c             	sub    $0xc,%esp
f0100798:	66 a1 a8 23 12 f0    	mov    0xf01223a8,%ax
f010079e:	25 fd ff 00 00       	and    $0xfffd,%eax
f01007a3:	50                   	push   %eax
f01007a4:	e8 a5 36 00 00       	call   f0103e4e <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01007a9:	b1 00                	mov    $0x0,%cl
f01007ab:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01007b0:	88 c8                	mov    %cl,%al
f01007b2:	89 da                	mov    %ebx,%edx
f01007b4:	ee                   	out    %al,(%dx)
f01007b5:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01007ba:	b0 80                	mov    $0x80,%al
f01007bc:	89 fa                	mov    %edi,%edx
f01007be:	ee                   	out    %al,(%dx)
f01007bf:	b0 0c                	mov    $0xc,%al
f01007c1:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01007c6:	ee                   	out    %al,(%dx)
f01007c7:	be f9 03 00 00       	mov    $0x3f9,%esi
f01007cc:	88 c8                	mov    %cl,%al
f01007ce:	89 f2                	mov    %esi,%edx
f01007d0:	ee                   	out    %al,(%dx)
f01007d1:	b0 03                	mov    $0x3,%al
f01007d3:	89 fa                	mov    %edi,%edx
f01007d5:	ee                   	out    %al,(%dx)
f01007d6:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01007db:	88 c8                	mov    %cl,%al
f01007dd:	ee                   	out    %al,(%dx)
f01007de:	b0 01                	mov    $0x1,%al
f01007e0:	89 f2                	mov    %esi,%edx
f01007e2:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01007e3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01007e8:	ec                   	in     (%dx),%al
f01007e9:	88 c1                	mov    %al,%cl
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01007eb:	83 c4 10             	add    $0x10,%esp
f01007ee:	3c ff                	cmp    $0xff,%al
f01007f0:	0f 95 05 34 12 29 f0 	setne  0xf0291234
f01007f7:	89 da                	mov    %ebx,%edx
f01007f9:	ec                   	in     (%dx),%al
f01007fa:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01007ff:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100800:	80 f9 ff             	cmp    $0xff,%cl
f0100803:	74 23                	je     f0100828 <cons_init+0x102>
		cprintf("Serial port does not exist!\n");
}
f0100805:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100808:	5b                   	pop    %ebx
f0100809:	5e                   	pop    %esi
f010080a:	5f                   	pop    %edi
f010080b:	5d                   	pop    %ebp
f010080c:	c3                   	ret    
		*cp = was;
f010080d:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100814:	c7 05 30 12 29 f0 d4 	movl   $0x3d4,0xf0291230
f010081b:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010081e:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f0100823:	e9 36 ff ff ff       	jmp    f010075e <cons_init+0x38>
		cprintf("Serial port does not exist!\n");
f0100828:	83 ec 0c             	sub    $0xc,%esp
f010082b:	68 1c 66 10 f0       	push   $0xf010661c
f0100830:	e8 5e 37 00 00       	call   f0103f93 <cprintf>
f0100835:	83 c4 10             	add    $0x10,%esp
}
f0100838:	eb cb                	jmp    f0100805 <cons_init+0xdf>

f010083a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010083a:	55                   	push   %ebp
f010083b:	89 e5                	mov    %esp,%ebp
f010083d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100840:	8b 45 08             	mov    0x8(%ebp),%eax
f0100843:	e8 8c fc ff ff       	call   f01004d4 <cons_putc>
}
f0100848:	c9                   	leave  
f0100849:	c3                   	ret    

f010084a <getchar>:

int
getchar(void)
{
f010084a:	55                   	push   %ebp
f010084b:	89 e5                	mov    %esp,%ebp
f010084d:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100850:	e8 87 fe ff ff       	call   f01006dc <cons_getc>
f0100855:	85 c0                	test   %eax,%eax
f0100857:	74 f7                	je     f0100850 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100859:	c9                   	leave  
f010085a:	c3                   	ret    

f010085b <iscons>:

int
iscons(int fdnum)
{
f010085b:	55                   	push   %ebp
f010085c:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010085e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100863:	5d                   	pop    %ebp
f0100864:	c3                   	ret    

f0100865 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100865:	55                   	push   %ebp
f0100866:	89 e5                	mov    %esp,%ebp
f0100868:	53                   	push   %ebx
f0100869:	83 ec 04             	sub    $0x4,%esp
f010086c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100871:	83 ec 04             	sub    $0x4,%esp
f0100874:	ff b3 44 6d 10 f0    	pushl  -0xfef92bc(%ebx)
f010087a:	ff b3 40 6d 10 f0    	pushl  -0xfef92c0(%ebx)
f0100880:	68 60 68 10 f0       	push   $0xf0106860
f0100885:	e8 09 37 00 00       	call   f0103f93 <cprintf>
f010088a:	83 c3 0c             	add    $0xc,%ebx
	for (i = 0; i < ARRAY_SIZE(commands); i++)
f010088d:	83 c4 10             	add    $0x10,%esp
f0100890:	83 fb 3c             	cmp    $0x3c,%ebx
f0100893:	75 dc                	jne    f0100871 <mon_help+0xc>
	return 0;
}
f0100895:	b8 00 00 00 00       	mov    $0x0,%eax
f010089a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010089d:	c9                   	leave  
f010089e:	c3                   	ret    

f010089f <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010089f:	55                   	push   %ebp
f01008a0:	89 e5                	mov    %esp,%ebp
f01008a2:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01008a5:	68 69 68 10 f0       	push   $0xf0106869
f01008aa:	e8 e4 36 00 00       	call   f0103f93 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01008af:	83 c4 08             	add    $0x8,%esp
f01008b2:	68 0c 00 10 00       	push   $0x10000c
f01008b7:	68 c0 69 10 f0       	push   $0xf01069c0
f01008bc:	e8 d2 36 00 00       	call   f0103f93 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01008c1:	83 c4 0c             	add    $0xc,%esp
f01008c4:	68 0c 00 10 00       	push   $0x10000c
f01008c9:	68 0c 00 10 f0       	push   $0xf010000c
f01008ce:	68 e8 69 10 f0       	push   $0xf01069e8
f01008d3:	e8 bb 36 00 00       	call   f0103f93 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01008d8:	83 c4 0c             	add    $0xc,%esp
f01008db:	68 50 64 10 00       	push   $0x106450
f01008e0:	68 50 64 10 f0       	push   $0xf0106450
f01008e5:	68 0c 6a 10 f0       	push   $0xf0106a0c
f01008ea:	e8 a4 36 00 00       	call   f0103f93 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01008ef:	83 c4 0c             	add    $0xc,%esp
f01008f2:	68 ec 0b 29 00       	push   $0x290bec
f01008f7:	68 ec 0b 29 f0       	push   $0xf0290bec
f01008fc:	68 30 6a 10 f0       	push   $0xf0106a30
f0100901:	e8 8d 36 00 00       	call   f0103f93 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100906:	83 c4 0c             	add    $0xc,%esp
f0100909:	68 08 30 2d 00       	push   $0x2d3008
f010090e:	68 08 30 2d f0       	push   $0xf02d3008
f0100913:	68 54 6a 10 f0       	push   $0xf0106a54
f0100918:	e8 76 36 00 00       	call   f0103f93 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010091d:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100920:	b8 07 34 2d f0       	mov    $0xf02d3407,%eax
f0100925:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f010092a:	c1 f8 0a             	sar    $0xa,%eax
f010092d:	50                   	push   %eax
f010092e:	68 78 6a 10 f0       	push   $0xf0106a78
f0100933:	e8 5b 36 00 00       	call   f0103f93 <cprintf>
	return 0;
}
f0100938:	b8 00 00 00 00       	mov    $0x0,%eax
f010093d:	c9                   	leave  
f010093e:	c3                   	ret    

f010093f <mon_showmap>:
	}
	return 0;
}

int 
mon_showmap(int argc, char **argv, struct Trapframe *tf) {
f010093f:	55                   	push   %ebp
f0100940:	89 e5                	mov    %esp,%ebp
f0100942:	56                   	push   %esi
f0100943:	53                   	push   %ebx
f0100944:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc <= 2) {
f0100947:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f010094b:	7e 3c                	jle    f0100989 <mon_showmap+0x4a>
		cprintf("Usage: showmap l r\n");
		return 0;
	}
	uintptr_t l = strtoul(argv[1], NULL, 0), 
f010094d:	83 ec 04             	sub    $0x4,%esp
f0100950:	6a 00                	push   $0x0
f0100952:	6a 00                	push   $0x0
f0100954:	ff 76 04             	pushl  0x4(%esi)
f0100957:	e8 e1 4f 00 00       	call   f010593d <strtoul>
f010095c:	89 c3                	mov    %eax,%ebx
		 	  r = strtoul(argv[2], NULL, 0); // In string.h
f010095e:	83 c4 0c             	add    $0xc,%esp
f0100961:	6a 00                	push   $0x0
f0100963:	6a 00                	push   $0x0
f0100965:	ff 76 08             	pushl  0x8(%esi)
f0100968:	e8 d0 4f 00 00       	call   f010593d <strtoul>
	if (l > r) {
f010096d:	83 c4 10             	add    $0x10,%esp
f0100970:	39 c3                	cmp    %eax,%ebx
f0100972:	77 31                	ja     f01009a5 <mon_showmap+0x66>
		cprintf("Invalid range; aborting.\n");
		return 0;
	}
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f0100974:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f010097a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0100980:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100985:	89 c6                	mov    %eax,%esi
f0100987:	eb 45                	jmp    f01009ce <mon_showmap+0x8f>
		cprintf("Usage: showmap l r\n");
f0100989:	83 ec 0c             	sub    $0xc,%esp
f010098c:	68 82 68 10 f0       	push   $0xf0106882
f0100991:	e8 fd 35 00 00       	call   f0103f93 <cprintf>
		return 0;
f0100996:	83 c4 10             	add    $0x10,%esp
		else 
			cprintf("0x%08x -> 0x%08x; perm = 0x%03x\n", 
					sz, PTE_ADDR(*pte), *pte & 0xFFF);
	}
	return 0;
}
f0100999:	b8 00 00 00 00       	mov    $0x0,%eax
f010099e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01009a1:	5b                   	pop    %ebx
f01009a2:	5e                   	pop    %esi
f01009a3:	5d                   	pop    %ebp
f01009a4:	c3                   	ret    
		cprintf("Invalid range; aborting.\n");
f01009a5:	83 ec 0c             	sub    $0xc,%esp
f01009a8:	68 96 68 10 f0       	push   $0xf0106896
f01009ad:	e8 e1 35 00 00       	call   f0103f93 <cprintf>
		return 0;
f01009b2:	83 c4 10             	add    $0x10,%esp
f01009b5:	eb e2                	jmp    f0100999 <mon_showmap+0x5a>
			cprintf("0x%08x -> ----------; perm = ---\n", sz);
f01009b7:	83 ec 08             	sub    $0x8,%esp
f01009ba:	53                   	push   %ebx
f01009bb:	68 a4 6a 10 f0       	push   $0xf0106aa4
f01009c0:	e8 ce 35 00 00       	call   f0103f93 <cprintf>
f01009c5:	83 c4 10             	add    $0x10,%esp
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f01009c8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01009ce:	39 f3                	cmp    %esi,%ebx
f01009d0:	77 c7                	ja     f0100999 <mon_showmap+0x5a>
		pte_t* pte = pgdir_walk(kern_pgdir, (void*) sz, 0);
f01009d2:	83 ec 04             	sub    $0x4,%esp
f01009d5:	6a 00                	push   $0x0
f01009d7:	53                   	push   %ebx
f01009d8:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f01009de:	e8 ed 0a 00 00       	call   f01014d0 <pgdir_walk>
		if (pte == NULL || !*pte)
f01009e3:	83 c4 10             	add    $0x10,%esp
f01009e6:	85 c0                	test   %eax,%eax
f01009e8:	74 cd                	je     f01009b7 <mon_showmap+0x78>
f01009ea:	8b 00                	mov    (%eax),%eax
f01009ec:	85 c0                	test   %eax,%eax
f01009ee:	74 c7                	je     f01009b7 <mon_showmap+0x78>
			cprintf("0x%08x -> 0x%08x; perm = 0x%03x\n", 
f01009f0:	89 c2                	mov    %eax,%edx
f01009f2:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f01009f8:	52                   	push   %edx
f01009f9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009fe:	50                   	push   %eax
f01009ff:	53                   	push   %ebx
f0100a00:	68 c8 6a 10 f0       	push   $0xf0106ac8
f0100a05:	e8 89 35 00 00       	call   f0103f93 <cprintf>
f0100a0a:	83 c4 10             	add    $0x10,%esp
f0100a0d:	eb b9                	jmp    f01009c8 <mon_showmap+0x89>

f0100a0f <mon_chmod>:

int
mon_chmod(int argc, char **argv, struct Trapframe *tf) {
f0100a0f:	55                   	push   %ebp
f0100a10:	89 e5                	mov    %esp,%ebp
f0100a12:	57                   	push   %edi
f0100a13:	56                   	push   %esi
f0100a14:	53                   	push   %ebx
f0100a15:	83 ec 1c             	sub    $0x1c,%esp
f0100a18:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc <= 2) {
f0100a1b:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100a1f:	7e 67                	jle    f0100a88 <mon_chmod+0x79>
		cprintf("Usage: chmod mod l [r] [-v]\n");
		return 0;
	}
	uintptr_t mod = strtoul(argv[1], NULL, 0),  
f0100a21:	83 ec 04             	sub    $0x4,%esp
f0100a24:	6a 00                	push   $0x0
f0100a26:	6a 00                	push   $0x0
f0100a28:	ff 76 04             	pushl  0x4(%esi)
f0100a2b:	e8 0d 4f 00 00       	call   f010593d <strtoul>
f0100a30:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			  l = strtoul(argv[2], NULL, 0), 
f0100a33:	83 c4 0c             	add    $0xc,%esp
f0100a36:	6a 00                	push   $0x0
f0100a38:	6a 00                	push   $0x0
f0100a3a:	ff 76 08             	pushl  0x8(%esi)
f0100a3d:	e8 fb 4e 00 00       	call   f010593d <strtoul>
f0100a42:	89 c3                	mov    %eax,%ebx
			  r = argc >= 4 ? strtoul(argv[3], NULL, 0) : l;
f0100a44:	83 c4 10             	add    $0x10,%esp
f0100a47:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100a4b:	7f 58                	jg     f0100aa5 <mon_chmod+0x96>
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
	if (mod > 0xFFF) {
f0100a4d:	81 7d e4 ff 0f 00 00 	cmpl   $0xfff,-0x1c(%ebp)
f0100a54:	0f 87 9a 00 00 00    	ja     f0100af4 <mon_chmod+0xe5>
			  r = argc >= 4 ? strtoul(argv[3], NULL, 0) : l;
f0100a5a:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
f0100a5d:	bf 00 00 00 00       	mov    $0x0,%edi
	}
	if (l > r) {
		cprintf("Invalid range; aborting.\n");
		return 0;
	}
	if (!(mod & PTE_P)) {
f0100a62:	f6 45 e4 01          	testb  $0x1,-0x1c(%ebp)
f0100a66:	0f 84 9a 00 00 00    	je     f0100b06 <mon_chmod+0xf7>
		cprintf("Warning: PTE_P flag is not provided; added automatically.");
		mod |= PTE_P;
	}
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f0100a6c:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f0100a72:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0100a78:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a7b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a80:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100a83:	e9 a1 00 00 00       	jmp    f0100b29 <mon_chmod+0x11a>
		cprintf("Usage: chmod mod l [r] [-v]\n");
f0100a88:	83 ec 0c             	sub    $0xc,%esp
f0100a8b:	68 b0 68 10 f0       	push   $0xf01068b0
f0100a90:	e8 fe 34 00 00       	call   f0103f93 <cprintf>
		return 0;
f0100a95:	83 c4 10             	add    $0x10,%esp
						sz, *pte & 0xFFF, mod);
			*pte = PTE_ADDR(*pte) | mod;
		}
	}
	return 0;
}
f0100a98:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100aa0:	5b                   	pop    %ebx
f0100aa1:	5e                   	pop    %esi
f0100aa2:	5f                   	pop    %edi
f0100aa3:	5d                   	pop    %ebp
f0100aa4:	c3                   	ret    
			  r = argc >= 4 ? strtoul(argv[3], NULL, 0) : l;
f0100aa5:	83 ec 04             	sub    $0x4,%esp
f0100aa8:	6a 00                	push   $0x0
f0100aaa:	6a 00                	push   $0x0
f0100aac:	ff 76 0c             	pushl  0xc(%esi)
f0100aaf:	e8 89 4e 00 00       	call   f010593d <strtoul>
f0100ab4:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
f0100ab7:	83 c4 08             	add    $0x8,%esp
f0100aba:	68 cd 68 10 f0       	push   $0xf01068cd
f0100abf:	ff 76 0c             	pushl  0xc(%esi)
f0100ac2:	e8 0c 4c 00 00       	call   f01056d3 <strcmp>
f0100ac7:	83 c4 10             	add    $0x10,%esp
f0100aca:	85 c0                	test   %eax,%eax
f0100acc:	0f 94 c0             	sete   %al
f0100acf:	0f b6 c0             	movzbl %al,%eax
f0100ad2:	89 c7                	mov    %eax,%edi
	if (mod > 0xFFF) {
f0100ad4:	81 7d e4 ff 0f 00 00 	cmpl   $0xfff,-0x1c(%ebp)
f0100adb:	77 17                	ja     f0100af4 <mon_chmod+0xe5>
	if (l > r) {
f0100add:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0100ae0:	76 80                	jbe    f0100a62 <mon_chmod+0x53>
		cprintf("Invalid range; aborting.\n");
f0100ae2:	83 ec 0c             	sub    $0xc,%esp
f0100ae5:	68 96 68 10 f0       	push   $0xf0106896
f0100aea:	e8 a4 34 00 00       	call   f0103f93 <cprintf>
		return 0;
f0100aef:	83 c4 10             	add    $0x10,%esp
f0100af2:	eb a4                	jmp    f0100a98 <mon_chmod+0x89>
		cprintf("Permission exceeds 0xfff; aborting.\n");
f0100af4:	83 ec 0c             	sub    $0xc,%esp
f0100af7:	68 ec 6a 10 f0       	push   $0xf0106aec
f0100afc:	e8 92 34 00 00       	call   f0103f93 <cprintf>
		return 0;
f0100b01:	83 c4 10             	add    $0x10,%esp
f0100b04:	eb 92                	jmp    f0100a98 <mon_chmod+0x89>
		cprintf("Warning: PTE_P flag is not provided; added automatically.");
f0100b06:	83 ec 0c             	sub    $0xc,%esp
f0100b09:	68 14 6b 10 f0       	push   $0xf0106b14
f0100b0e:	e8 80 34 00 00       	call   f0103f93 <cprintf>
		mod |= PTE_P;
f0100b13:	83 4d e4 01          	orl    $0x1,-0x1c(%ebp)
f0100b17:	83 c4 10             	add    $0x10,%esp
f0100b1a:	e9 4d ff ff ff       	jmp    f0100a6c <mon_chmod+0x5d>
			if (verbose)
f0100b1f:	85 ff                	test   %edi,%edi
f0100b21:	75 41                	jne    f0100b64 <mon_chmod+0x155>
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f0100b23:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100b29:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0100b2c:	0f 87 66 ff ff ff    	ja     f0100a98 <mon_chmod+0x89>
		pte_t* pte = pgdir_walk(kern_pgdir, (void*) sz, 0);
f0100b32:	83 ec 04             	sub    $0x4,%esp
f0100b35:	6a 00                	push   $0x0
f0100b37:	53                   	push   %ebx
f0100b38:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f0100b3e:	e8 8d 09 00 00       	call   f01014d0 <pgdir_walk>
f0100b43:	89 c6                	mov    %eax,%esi
		if (pte == NULL || !*pte) {
f0100b45:	83 c4 10             	add    $0x10,%esp
f0100b48:	85 c0                	test   %eax,%eax
f0100b4a:	74 d3                	je     f0100b1f <mon_chmod+0x110>
f0100b4c:	8b 00                	mov    (%eax),%eax
f0100b4e:	85 c0                	test   %eax,%eax
f0100b50:	74 cd                	je     f0100b1f <mon_chmod+0x110>
			if (verbose) 
f0100b52:	85 ff                	test   %edi,%edi
f0100b54:	75 21                	jne    f0100b77 <mon_chmod+0x168>
			*pte = PTE_ADDR(*pte) | mod;
f0100b56:	8b 06                	mov    (%esi),%eax
f0100b58:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b5d:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0100b60:	89 06                	mov    %eax,(%esi)
f0100b62:	eb bf                	jmp    f0100b23 <mon_chmod+0x114>
				cprintf("Page va = 0x%08x is not mapped; skipping.\n", sz);
f0100b64:	83 ec 08             	sub    $0x8,%esp
f0100b67:	53                   	push   %ebx
f0100b68:	68 50 6b 10 f0       	push   $0xf0106b50
f0100b6d:	e8 21 34 00 00       	call   f0103f93 <cprintf>
f0100b72:	83 c4 10             	add    $0x10,%esp
f0100b75:	eb ac                	jmp    f0100b23 <mon_chmod+0x114>
				cprintf("Page va = 0x%08x perm = 0x%03x changed to 0x%03x\n", 
f0100b77:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100b7a:	25 ff 0f 00 00       	and    $0xfff,%eax
f0100b7f:	50                   	push   %eax
f0100b80:	53                   	push   %ebx
f0100b81:	68 7c 6b 10 f0       	push   $0xf0106b7c
f0100b86:	e8 08 34 00 00       	call   f0103f93 <cprintf>
f0100b8b:	83 c4 10             	add    $0x10,%esp
f0100b8e:	eb c6                	jmp    f0100b56 <mon_chmod+0x147>

f0100b90 <mon_dump>:

int
mon_dump(int argc, char **argv, struct Trapframe *tf) {
f0100b90:	55                   	push   %ebp
f0100b91:	89 e5                	mov    %esp,%ebp
f0100b93:	57                   	push   %edi
f0100b94:	56                   	push   %esi
f0100b95:	53                   	push   %ebx
f0100b96:	83 ec 1c             	sub    $0x1c,%esp
f0100b99:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (argc <= 2 || argc > 4) {
f0100b9c:	8d 43 fd             	lea    -0x3(%ebx),%eax
f0100b9f:	83 f8 01             	cmp    $0x1,%eax
f0100ba2:	76 1d                	jbe    f0100bc1 <mon_dump+0x31>
		cprintf("Usage: dump l r [-v/-p]\n");
f0100ba4:	83 ec 0c             	sub    $0xc,%esp
f0100ba7:	68 d0 68 10 f0       	push   $0xf01068d0
f0100bac:	e8 e2 33 00 00       	call   f0103f93 <cprintf>
		return 0;
f0100bb1:	83 c4 10             	add    $0x10,%esp
		cprintf("|\n");
	}
	if (ROUNDDOWN(r, 16) != r)
		cprintf("%08x  \n", r);
	return 0;
}
f0100bb4:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100bbc:	5b                   	pop    %ebx
f0100bbd:	5e                   	pop    %esi
f0100bbe:	5f                   	pop    %edi
f0100bbf:	5d                   	pop    %ebp
f0100bc0:	c3                   	ret    
	unsigned long l = strtoul(argv[1], NULL, 0),
f0100bc1:	83 ec 04             	sub    $0x4,%esp
f0100bc4:	6a 00                	push   $0x0
f0100bc6:	6a 00                	push   $0x0
f0100bc8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100bcb:	ff 70 04             	pushl  0x4(%eax)
f0100bce:	e8 6a 4d 00 00       	call   f010593d <strtoul>
f0100bd3:	89 c6                	mov    %eax,%esi
			  	  r = strtoul(argv[2], NULL, 0);
f0100bd5:	83 c4 0c             	add    $0xc,%esp
f0100bd8:	6a 00                	push   $0x0
f0100bda:	6a 00                	push   $0x0
f0100bdc:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100bdf:	ff 70 08             	pushl  0x8(%eax)
f0100be2:	e8 56 4d 00 00       	call   f010593d <strtoul>
f0100be7:	89 c7                	mov    %eax,%edi
	if (argc <= 3)
f0100be9:	83 c4 10             	add    $0x10,%esp
f0100bec:	83 fb 03             	cmp    $0x3,%ebx
f0100bef:	7f 18                	jg     f0100c09 <mon_dump+0x79>
		cprintf("Defaulting to virtual address.\n");
f0100bf1:	83 ec 0c             	sub    $0xc,%esp
f0100bf4:	68 b0 6b 10 f0       	push   $0xf0106bb0
f0100bf9:	e8 95 33 00 00       	call   f0103f93 <cprintf>
f0100bfe:	83 c4 10             	add    $0x10,%esp
	for (ptr = ROUNDDOWN(l, 16); ptr <= r; ptr += 16) {
f0100c01:	83 e6 f0             	and    $0xfffffff0,%esi
f0100c04:	e9 31 01 00 00       	jmp    f0100d3a <mon_dump+0x1aa>
	else if (!strcmp(argv[3], "-p"))
f0100c09:	83 ec 08             	sub    $0x8,%esp
f0100c0c:	68 e9 68 10 f0       	push   $0xf01068e9
f0100c11:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c14:	ff 70 0c             	pushl  0xc(%eax)
f0100c17:	e8 b7 4a 00 00       	call   f01056d3 <strcmp>
f0100c1c:	83 c4 10             	add    $0x10,%esp
f0100c1f:	85 c0                	test   %eax,%eax
f0100c21:	75 4f                	jne    f0100c72 <mon_dump+0xe2>
	if (PGNUM(pa) >= npages)
f0100c23:	a1 88 1e 29 f0       	mov    0xf0291e88,%eax
f0100c28:	89 f2                	mov    %esi,%edx
f0100c2a:	c1 ea 0c             	shr    $0xc,%edx
f0100c2d:	39 c2                	cmp    %eax,%edx
f0100c2f:	73 17                	jae    f0100c48 <mon_dump+0xb8>
	return (void *)(pa + KERNBASE);
f0100c31:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
	if (PGNUM(pa) >= npages)
f0100c37:	89 fa                	mov    %edi,%edx
f0100c39:	c1 ea 0c             	shr    $0xc,%edx
f0100c3c:	39 c2                	cmp    %eax,%edx
f0100c3e:	73 1d                	jae    f0100c5d <mon_dump+0xcd>
	return (void *)(pa + KERNBASE);
f0100c40:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
f0100c46:	eb b9                	jmp    f0100c01 <mon_dump+0x71>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c48:	56                   	push   %esi
f0100c49:	68 c8 65 10 f0       	push   $0xf01065c8
f0100c4e:	68 9d 00 00 00       	push   $0x9d
f0100c53:	68 ec 68 10 f0       	push   $0xf01068ec
f0100c58:	e8 37 f4 ff ff       	call   f0100094 <_panic>
f0100c5d:	57                   	push   %edi
f0100c5e:	68 c8 65 10 f0       	push   $0xf01065c8
f0100c63:	68 9d 00 00 00       	push   $0x9d
f0100c68:	68 ec 68 10 f0       	push   $0xf01068ec
f0100c6d:	e8 22 f4 ff ff       	call   f0100094 <_panic>
	else if (strcmp(argv[3], "-v")) {
f0100c72:	83 ec 08             	sub    $0x8,%esp
f0100c75:	68 cd 68 10 f0       	push   $0xf01068cd
f0100c7a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c7d:	ff 70 0c             	pushl  0xc(%eax)
f0100c80:	e8 4e 4a 00 00       	call   f01056d3 <strcmp>
f0100c85:	83 c4 10             	add    $0x10,%esp
f0100c88:	85 c0                	test   %eax,%eax
f0100c8a:	0f 84 71 ff ff ff    	je     f0100c01 <mon_dump+0x71>
		cprintf("Unknown flag %s at position 3; aborting.\n", argv[3]);
f0100c90:	83 ec 08             	sub    $0x8,%esp
f0100c93:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c96:	ff 70 0c             	pushl  0xc(%eax)
f0100c99:	68 d0 6b 10 f0       	push   $0xf0106bd0
f0100c9e:	e8 f0 32 00 00       	call   f0103f93 <cprintf>
		return 0;
f0100ca3:	83 c4 10             	add    $0x10,%esp
f0100ca6:	e9 09 ff ff ff       	jmp    f0100bb4 <mon_dump+0x24>
				cprintf("   ");
f0100cab:	83 ec 0c             	sub    $0xc,%esp
f0100cae:	68 08 69 10 f0       	push   $0xf0106908
f0100cb3:	e8 db 32 00 00       	call   f0103f93 <cprintf>
f0100cb8:	83 c4 10             	add    $0x10,%esp
f0100cbb:	43                   	inc    %ebx
		for (int i = 0; i < 16; i++) {
f0100cbc:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0100cbf:	74 1a                	je     f0100cdb <mon_dump+0x14b>
			if (ptr + i <= r)
f0100cc1:	39 df                	cmp    %ebx,%edi
f0100cc3:	72 e6                	jb     f0100cab <mon_dump+0x11b>
				cprintf("%02x ", *(unsigned char*)(ptr + i));
f0100cc5:	83 ec 08             	sub    $0x8,%esp
f0100cc8:	0f b6 03             	movzbl (%ebx),%eax
f0100ccb:	50                   	push   %eax
f0100ccc:	68 02 69 10 f0       	push   $0xf0106902
f0100cd1:	e8 bd 32 00 00       	call   f0103f93 <cprintf>
f0100cd6:	83 c4 10             	add    $0x10,%esp
f0100cd9:	eb e0                	jmp    f0100cbb <mon_dump+0x12b>
		cprintf(" |");
f0100cdb:	83 ec 0c             	sub    $0xc,%esp
f0100cde:	68 0c 69 10 f0       	push   $0xf010690c
f0100ce3:	e8 ab 32 00 00       	call   f0103f93 <cprintf>
f0100ce8:	83 c4 10             	add    $0x10,%esp
f0100ceb:	eb 19                	jmp    f0100d06 <mon_dump+0x176>
				cprintf("%c", (ch >= ' ' && ch <= '~') ? ch : '.');
f0100ced:	83 ec 08             	sub    $0x8,%esp
f0100cf0:	0f be c0             	movsbl %al,%eax
f0100cf3:	50                   	push   %eax
f0100cf4:	68 0f 69 10 f0       	push   $0xf010690f
f0100cf9:	e8 95 32 00 00       	call   f0103f93 <cprintf>
f0100cfe:	83 c4 10             	add    $0x10,%esp
f0100d01:	46                   	inc    %esi
		for (int i = 0; i < 16; i++) {
f0100d02:	39 de                	cmp    %ebx,%esi
f0100d04:	74 24                	je     f0100d2a <mon_dump+0x19a>
			if (ptr + i <= r) {
f0100d06:	39 f7                	cmp    %esi,%edi
f0100d08:	72 0e                	jb     f0100d18 <mon_dump+0x188>
				char ch = *(char*)(ptr + i);
f0100d0a:	8a 06                	mov    (%esi),%al
				cprintf("%c", (ch >= ' ' && ch <= '~') ? ch : '.');
f0100d0c:	8d 50 e0             	lea    -0x20(%eax),%edx
f0100d0f:	80 fa 5e             	cmp    $0x5e,%dl
f0100d12:	76 d9                	jbe    f0100ced <mon_dump+0x15d>
f0100d14:	b0 2e                	mov    $0x2e,%al
f0100d16:	eb d5                	jmp    f0100ced <mon_dump+0x15d>
				cprintf(" ");
f0100d18:	83 ec 0c             	sub    $0xc,%esp
f0100d1b:	68 4c 69 10 f0       	push   $0xf010694c
f0100d20:	e8 6e 32 00 00       	call   f0103f93 <cprintf>
f0100d25:	83 c4 10             	add    $0x10,%esp
f0100d28:	eb d7                	jmp    f0100d01 <mon_dump+0x171>
		cprintf("|\n");
f0100d2a:	83 ec 0c             	sub    $0xc,%esp
f0100d2d:	68 12 69 10 f0       	push   $0xf0106912
f0100d32:	e8 5c 32 00 00       	call   f0103f93 <cprintf>
	for (ptr = ROUNDDOWN(l, 16); ptr <= r; ptr += 16) {
f0100d37:	83 c4 10             	add    $0x10,%esp
f0100d3a:	39 f7                	cmp    %esi,%edi
f0100d3c:	72 1e                	jb     f0100d5c <mon_dump+0x1cc>
		cprintf("%08x  ", ptr);
f0100d3e:	83 ec 08             	sub    $0x8,%esp
f0100d41:	56                   	push   %esi
f0100d42:	68 fb 68 10 f0       	push   $0xf01068fb
f0100d47:	e8 47 32 00 00       	call   f0103f93 <cprintf>
f0100d4c:	8d 46 10             	lea    0x10(%esi),%eax
f0100d4f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100d52:	83 c4 10             	add    $0x10,%esp
f0100d55:	89 f3                	mov    %esi,%ebx
f0100d57:	e9 65 ff ff ff       	jmp    f0100cc1 <mon_dump+0x131>
	if (ROUNDDOWN(r, 16) != r)
f0100d5c:	f7 c7 0f 00 00 00    	test   $0xf,%edi
f0100d62:	0f 84 4c fe ff ff    	je     f0100bb4 <mon_dump+0x24>
		cprintf("%08x  \n", r);
f0100d68:	83 ec 08             	sub    $0x8,%esp
f0100d6b:	57                   	push   %edi
f0100d6c:	68 15 69 10 f0       	push   $0xf0106915
f0100d71:	e8 1d 32 00 00       	call   f0103f93 <cprintf>
f0100d76:	83 c4 10             	add    $0x10,%esp
f0100d79:	e9 36 fe ff ff       	jmp    f0100bb4 <mon_dump+0x24>

f0100d7e <mon_backtrace>:
{
f0100d7e:	55                   	push   %ebp
f0100d7f:	89 e5                	mov    %esp,%ebp
f0100d81:	57                   	push   %edi
f0100d82:	56                   	push   %esi
f0100d83:	53                   	push   %ebx
f0100d84:	83 ec 38             	sub    $0x38,%esp
	cprintf("Stack backtrace:\n");
f0100d87:	68 1d 69 10 f0       	push   $0xf010691d
f0100d8c:	e8 02 32 00 00       	call   f0103f93 <cprintf>
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100d91:	89 e8                	mov    %ebp,%eax
	while (ebp != 0) {
f0100d93:	83 c4 10             	add    $0x10,%esp
f0100d96:	eb 34                	jmp    f0100dcc <mon_backtrace+0x4e>
			cprintf("%c", info.eip_fn_name[i]);
f0100d98:	83 ec 08             	sub    $0x8,%esp
f0100d9b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100d9e:	0f be 04 18          	movsbl (%eax,%ebx,1),%eax
f0100da2:	50                   	push   %eax
f0100da3:	68 0f 69 10 f0       	push   $0xf010690f
f0100da8:	e8 e6 31 00 00       	call   f0103f93 <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f0100dad:	43                   	inc    %ebx
f0100dae:	83 c4 10             	add    $0x10,%esp
f0100db1:	39 5d dc             	cmp    %ebx,-0x24(%ebp)
f0100db4:	7f e2                	jg     f0100d98 <mon_backtrace+0x1a>
		cprintf("+%d\n", eip - info.eip_fn_addr);
f0100db6:	83 ec 08             	sub    $0x8,%esp
f0100db9:	2b 75 e0             	sub    -0x20(%ebp),%esi
f0100dbc:	56                   	push   %esi
f0100dbd:	68 40 69 10 f0       	push   $0xf0106940
f0100dc2:	e8 cc 31 00 00       	call   f0103f93 <cprintf>
		ebp = prev_ebp;
f0100dc7:	83 c4 10             	add    $0x10,%esp
f0100dca:	89 f8                	mov    %edi,%eax
	while (ebp != 0) {
f0100dcc:	85 c0                	test   %eax,%eax
f0100dce:	74 4a                	je     f0100e1a <mon_backtrace+0x9c>
		prev_ebp = *(int*)ebp;
f0100dd0:	8b 38                	mov    (%eax),%edi
		eip = *((int*)ebp + 1);
f0100dd2:	8b 70 04             	mov    0x4(%eax),%esi
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, 
f0100dd5:	ff 70 18             	pushl  0x18(%eax)
f0100dd8:	ff 70 14             	pushl  0x14(%eax)
f0100ddb:	ff 70 10             	pushl  0x10(%eax)
f0100dde:	ff 70 0c             	pushl  0xc(%eax)
f0100de1:	ff 70 08             	pushl  0x8(%eax)
f0100de4:	56                   	push   %esi
f0100de5:	50                   	push   %eax
f0100de6:	68 fc 6b 10 f0       	push   $0xf0106bfc
f0100deb:	e8 a3 31 00 00       	call   f0103f93 <cprintf>
		int code = debuginfo_eip((uintptr_t)eip, &info);
f0100df0:	83 c4 18             	add    $0x18,%esp
f0100df3:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100df6:	50                   	push   %eax
f0100df7:	56                   	push   %esi
f0100df8:	e8 1e 3f 00 00       	call   f0104d1b <debuginfo_eip>
		cprintf("         %s:%d: ", info.eip_file, info.eip_line);
f0100dfd:	83 c4 0c             	add    $0xc,%esp
f0100e00:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100e03:	ff 75 d0             	pushl  -0x30(%ebp)
f0100e06:	68 2f 69 10 f0       	push   $0xf010692f
f0100e0b:	e8 83 31 00 00       	call   f0103f93 <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f0100e10:	83 c4 10             	add    $0x10,%esp
f0100e13:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e18:	eb 97                	jmp    f0100db1 <mon_backtrace+0x33>
}
f0100e1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e1d:	5b                   	pop    %ebx
f0100e1e:	5e                   	pop    %esi
f0100e1f:	5f                   	pop    %edi
f0100e20:	5d                   	pop    %ebp
f0100e21:	c3                   	ret    

f0100e22 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100e22:	55                   	push   %ebp
f0100e23:	89 e5                	mov    %esp,%ebp
f0100e25:	57                   	push   %edi
f0100e26:	56                   	push   %esi
f0100e27:	53                   	push   %ebx
f0100e28:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100e2b:	68 34 6c 10 f0       	push   $0xf0106c34
f0100e30:	e8 5e 31 00 00       	call   f0103f93 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100e35:	c7 04 24 58 6c 10 f0 	movl   $0xf0106c58,(%esp)
f0100e3c:	e8 52 31 00 00       	call   f0103f93 <cprintf>

	if (tf != NULL)
f0100e41:	83 c4 10             	add    $0x10,%esp
f0100e44:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100e48:	74 57                	je     f0100ea1 <monitor+0x7f>
		print_trapframe(tf);
f0100e4a:	83 ec 0c             	sub    $0xc,%esp
f0100e4d:	ff 75 08             	pushl  0x8(%ebp)
f0100e50:	e8 be 35 00 00       	call   f0104413 <print_trapframe>
f0100e55:	83 c4 10             	add    $0x10,%esp
f0100e58:	eb 47                	jmp    f0100ea1 <monitor+0x7f>
		while (*buf && strchr(WHITESPACE, *buf))
f0100e5a:	83 ec 08             	sub    $0x8,%esp
f0100e5d:	0f be c0             	movsbl %al,%eax
f0100e60:	50                   	push   %eax
f0100e61:	68 49 69 10 f0       	push   $0xf0106949
f0100e66:	e8 bc 48 00 00       	call   f0105727 <strchr>
f0100e6b:	83 c4 10             	add    $0x10,%esp
f0100e6e:	85 c0                	test   %eax,%eax
f0100e70:	74 0a                	je     f0100e7c <monitor+0x5a>
			*buf++ = 0;
f0100e72:	c6 03 00             	movb   $0x0,(%ebx)
f0100e75:	89 f7                	mov    %esi,%edi
f0100e77:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100e7a:	eb 68                	jmp    f0100ee4 <monitor+0xc2>
		if (*buf == 0)
f0100e7c:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100e7f:	74 6f                	je     f0100ef0 <monitor+0xce>
		if (argc == MAXARGS-1) {
f0100e81:	83 fe 0f             	cmp    $0xf,%esi
f0100e84:	74 09                	je     f0100e8f <monitor+0x6d>
		argv[argc++] = buf;
f0100e86:	8d 7e 01             	lea    0x1(%esi),%edi
f0100e89:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100e8d:	eb 37                	jmp    f0100ec6 <monitor+0xa4>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100e8f:	83 ec 08             	sub    $0x8,%esp
f0100e92:	6a 10                	push   $0x10
f0100e94:	68 4e 69 10 f0       	push   $0xf010694e
f0100e99:	e8 f5 30 00 00       	call   f0103f93 <cprintf>
f0100e9e:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100ea1:	83 ec 0c             	sub    $0xc,%esp
f0100ea4:	68 45 69 10 f0       	push   $0xf0106945
f0100ea9:	e8 6e 46 00 00       	call   f010551c <readline>
f0100eae:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100eb0:	83 c4 10             	add    $0x10,%esp
f0100eb3:	85 c0                	test   %eax,%eax
f0100eb5:	74 ea                	je     f0100ea1 <monitor+0x7f>
	argv[argc] = 0;
f0100eb7:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100ebe:	be 00 00 00 00       	mov    $0x0,%esi
f0100ec3:	eb 21                	jmp    f0100ee6 <monitor+0xc4>
			buf++;
f0100ec5:	43                   	inc    %ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100ec6:	8a 03                	mov    (%ebx),%al
f0100ec8:	84 c0                	test   %al,%al
f0100eca:	74 18                	je     f0100ee4 <monitor+0xc2>
f0100ecc:	83 ec 08             	sub    $0x8,%esp
f0100ecf:	0f be c0             	movsbl %al,%eax
f0100ed2:	50                   	push   %eax
f0100ed3:	68 49 69 10 f0       	push   $0xf0106949
f0100ed8:	e8 4a 48 00 00       	call   f0105727 <strchr>
f0100edd:	83 c4 10             	add    $0x10,%esp
f0100ee0:	85 c0                	test   %eax,%eax
f0100ee2:	74 e1                	je     f0100ec5 <monitor+0xa3>
			*buf++ = 0;
f0100ee4:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100ee6:	8a 03                	mov    (%ebx),%al
f0100ee8:	84 c0                	test   %al,%al
f0100eea:	0f 85 6a ff ff ff    	jne    f0100e5a <monitor+0x38>
	argv[argc] = 0;
f0100ef0:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100ef7:	00 
	if (argc == 0)
f0100ef8:	85 f6                	test   %esi,%esi
f0100efa:	74 a5                	je     f0100ea1 <monitor+0x7f>
f0100efc:	bf 40 6d 10 f0       	mov    $0xf0106d40,%edi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100f01:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f0100f06:	83 ec 08             	sub    $0x8,%esp
f0100f09:	ff 37                	pushl  (%edi)
f0100f0b:	ff 75 a8             	pushl  -0x58(%ebp)
f0100f0e:	e8 c0 47 00 00       	call   f01056d3 <strcmp>
f0100f13:	83 c4 10             	add    $0x10,%esp
f0100f16:	85 c0                	test   %eax,%eax
f0100f18:	74 21                	je     f0100f3b <monitor+0x119>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100f1a:	43                   	inc    %ebx
f0100f1b:	83 c7 0c             	add    $0xc,%edi
f0100f1e:	83 fb 05             	cmp    $0x5,%ebx
f0100f21:	75 e3                	jne    f0100f06 <monitor+0xe4>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100f23:	83 ec 08             	sub    $0x8,%esp
f0100f26:	ff 75 a8             	pushl  -0x58(%ebp)
f0100f29:	68 6b 69 10 f0       	push   $0xf010696b
f0100f2e:	e8 60 30 00 00       	call   f0103f93 <cprintf>
f0100f33:	83 c4 10             	add    $0x10,%esp
f0100f36:	e9 66 ff ff ff       	jmp    f0100ea1 <monitor+0x7f>
			return commands[i].func(argc, argv, tf);
f0100f3b:	83 ec 04             	sub    $0x4,%esp
f0100f3e:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100f41:	01 c3                	add    %eax,%ebx
f0100f43:	ff 75 08             	pushl  0x8(%ebp)
f0100f46:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100f49:	50                   	push   %eax
f0100f4a:	56                   	push   %esi
f0100f4b:	ff 14 9d 48 6d 10 f0 	call   *-0xfef92b8(,%ebx,4)
			if (runcmd(buf, tf) < 0)
f0100f52:	83 c4 10             	add    $0x10,%esp
f0100f55:	85 c0                	test   %eax,%eax
f0100f57:	0f 89 44 ff ff ff    	jns    f0100ea1 <monitor+0x7f>
				break;
	}
}
f0100f5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f60:	5b                   	pop    %ebx
f0100f61:	5e                   	pop    %esi
f0100f62:	5f                   	pop    %edi
f0100f63:	5d                   	pop    %ebp
f0100f64:	c3                   	ret    

f0100f65 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100f65:	55                   	push   %ebp
f0100f66:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100f68:	83 3d 38 12 29 f0 00 	cmpl   $0x0,0xf0291238
f0100f6f:	74 1f                	je     f0100f90 <boot_alloc+0x2b>
	}

	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	if (!n)
f0100f71:	85 c0                	test   %eax,%eax
f0100f73:	74 2e                	je     f0100fa3 <boot_alloc+0x3e>
		return (void*)nextfree;
	else {
		result = nextfree;
f0100f75:	8b 15 38 12 29 f0    	mov    0xf0291238,%edx
		nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100f7b:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100f82:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f87:	a3 38 12 29 f0       	mov    %eax,0xf0291238
		return (void*)result;
	}
}
f0100f8c:	89 d0                	mov    %edx,%eax
f0100f8e:	5d                   	pop    %ebp
f0100f8f:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100f90:	ba 07 40 2d f0       	mov    $0xf02d4007,%edx
f0100f95:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100f9b:	89 15 38 12 29 f0    	mov    %edx,0xf0291238
f0100fa1:	eb ce                	jmp    f0100f71 <boot_alloc+0xc>
		return (void*)nextfree;
f0100fa3:	8b 15 38 12 29 f0    	mov    0xf0291238,%edx
f0100fa9:	eb e1                	jmp    f0100f8c <boot_alloc+0x27>

f0100fab <nvram_read>:
{
f0100fab:	55                   	push   %ebp
f0100fac:	89 e5                	mov    %esp,%ebp
f0100fae:	56                   	push   %esi
f0100faf:	53                   	push   %ebx
f0100fb0:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100fb2:	83 ec 0c             	sub    $0xc,%esp
f0100fb5:	50                   	push   %eax
f0100fb6:	e8 65 2e 00 00       	call   f0103e20 <mc146818_read>
f0100fbb:	89 c3                	mov    %eax,%ebx
f0100fbd:	46                   	inc    %esi
f0100fbe:	89 34 24             	mov    %esi,(%esp)
f0100fc1:	e8 5a 2e 00 00       	call   f0103e20 <mc146818_read>
f0100fc6:	c1 e0 08             	shl    $0x8,%eax
f0100fc9:	09 d8                	or     %ebx,%eax
}
f0100fcb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100fce:	5b                   	pop    %ebx
f0100fcf:	5e                   	pop    %esi
f0100fd0:	5d                   	pop    %ebp
f0100fd1:	c3                   	ret    

f0100fd2 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100fd2:	89 d1                	mov    %edx,%ecx
f0100fd4:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100fd7:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100fda:	a8 01                	test   $0x1,%al
f0100fdc:	74 47                	je     f0101025 <check_va2pa+0x53>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100fde:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100fe3:	89 c1                	mov    %eax,%ecx
f0100fe5:	c1 e9 0c             	shr    $0xc,%ecx
f0100fe8:	3b 0d 88 1e 29 f0    	cmp    0xf0291e88,%ecx
f0100fee:	73 1a                	jae    f010100a <check_va2pa+0x38>
	if (!(p[PTX(va)] & PTE_P))
f0100ff0:	c1 ea 0c             	shr    $0xc,%edx
f0100ff3:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100ff9:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0101000:	a8 01                	test   $0x1,%al
f0101002:	74 27                	je     f010102b <check_va2pa+0x59>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0101004:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101009:	c3                   	ret    
{
f010100a:	55                   	push   %ebp
f010100b:	89 e5                	mov    %esp,%ebp
f010100d:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101010:	50                   	push   %eax
f0101011:	68 c8 65 10 f0       	push   $0xf01065c8
f0101016:	68 69 03 00 00       	push   $0x369
f010101b:	68 9d 76 10 f0       	push   $0xf010769d
f0101020:	e8 6f f0 ff ff       	call   f0100094 <_panic>
		return ~0;
f0101025:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010102a:	c3                   	ret    
		return ~0;
f010102b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0101030:	c3                   	ret    

f0101031 <check_page_free_list>:
{
f0101031:	55                   	push   %ebp
f0101032:	89 e5                	mov    %esp,%ebp
f0101034:	57                   	push   %edi
f0101035:	56                   	push   %esi
f0101036:	53                   	push   %ebx
f0101037:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010103a:	84 c0                	test   %al,%al
f010103c:	0f 85 80 02 00 00    	jne    f01012c2 <check_page_free_list+0x291>
	if (!page_free_list)
f0101042:	83 3d 40 12 29 f0 00 	cmpl   $0x0,0xf0291240
f0101049:	74 0a                	je     f0101055 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010104b:	be 00 04 00 00       	mov    $0x400,%esi
f0101050:	e9 c8 02 00 00       	jmp    f010131d <check_page_free_list+0x2ec>
		panic("'page_free_list' is a null pointer!");
f0101055:	83 ec 04             	sub    $0x4,%esp
f0101058:	68 7c 6d 10 f0       	push   $0xf0106d7c
f010105d:	68 9c 02 00 00       	push   $0x29c
f0101062:	68 9d 76 10 f0       	push   $0xf010769d
f0101067:	e8 28 f0 ff ff       	call   f0100094 <_panic>
f010106c:	50                   	push   %eax
f010106d:	68 c8 65 10 f0       	push   $0xf01065c8
f0101072:	6a 58                	push   $0x58
f0101074:	68 a9 76 10 f0       	push   $0xf01076a9
f0101079:	e8 16 f0 ff ff       	call   f0100094 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010107e:	8b 1b                	mov    (%ebx),%ebx
f0101080:	85 db                	test   %ebx,%ebx
f0101082:	74 41                	je     f01010c5 <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101084:	89 d8                	mov    %ebx,%eax
f0101086:	2b 05 90 1e 29 f0    	sub    0xf0291e90,%eax
f010108c:	c1 f8 03             	sar    $0x3,%eax
f010108f:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0101092:	89 c2                	mov    %eax,%edx
f0101094:	c1 ea 16             	shr    $0x16,%edx
f0101097:	39 f2                	cmp    %esi,%edx
f0101099:	73 e3                	jae    f010107e <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f010109b:	89 c2                	mov    %eax,%edx
f010109d:	c1 ea 0c             	shr    $0xc,%edx
f01010a0:	3b 15 88 1e 29 f0    	cmp    0xf0291e88,%edx
f01010a6:	73 c4                	jae    f010106c <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f01010a8:	83 ec 04             	sub    $0x4,%esp
f01010ab:	68 80 00 00 00       	push   $0x80
f01010b0:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f01010b5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010ba:	50                   	push   %eax
f01010bb:	e8 9c 46 00 00       	call   f010575c <memset>
f01010c0:	83 c4 10             	add    $0x10,%esp
f01010c3:	eb b9                	jmp    f010107e <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f01010c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01010ca:	e8 96 fe ff ff       	call   f0100f65 <boot_alloc>
f01010cf:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010d2:	8b 15 40 12 29 f0    	mov    0xf0291240,%edx
		assert(pp >= pages);
f01010d8:	8b 0d 90 1e 29 f0    	mov    0xf0291e90,%ecx
		assert(pp < pages + npages);
f01010de:	a1 88 1e 29 f0       	mov    0xf0291e88,%eax
f01010e3:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01010e6:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f01010e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01010ec:	89 4d d0             	mov    %ecx,-0x30(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f01010ef:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010f4:	e9 00 01 00 00       	jmp    f01011f9 <check_page_free_list+0x1c8>
		assert(pp >= pages);
f01010f9:	68 b7 76 10 f0       	push   $0xf01076b7
f01010fe:	68 c3 76 10 f0       	push   $0xf01076c3
f0101103:	68 b6 02 00 00       	push   $0x2b6
f0101108:	68 9d 76 10 f0       	push   $0xf010769d
f010110d:	e8 82 ef ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0101112:	68 d8 76 10 f0       	push   $0xf01076d8
f0101117:	68 c3 76 10 f0       	push   $0xf01076c3
f010111c:	68 b7 02 00 00       	push   $0x2b7
f0101121:	68 9d 76 10 f0       	push   $0xf010769d
f0101126:	e8 69 ef ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010112b:	68 a0 6d 10 f0       	push   $0xf0106da0
f0101130:	68 c3 76 10 f0       	push   $0xf01076c3
f0101135:	68 b8 02 00 00       	push   $0x2b8
f010113a:	68 9d 76 10 f0       	push   $0xf010769d
f010113f:	e8 50 ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != 0);
f0101144:	68 ec 76 10 f0       	push   $0xf01076ec
f0101149:	68 c3 76 10 f0       	push   $0xf01076c3
f010114e:	68 bb 02 00 00       	push   $0x2bb
f0101153:	68 9d 76 10 f0       	push   $0xf010769d
f0101158:	e8 37 ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f010115d:	68 fd 76 10 f0       	push   $0xf01076fd
f0101162:	68 c3 76 10 f0       	push   $0xf01076c3
f0101167:	68 bc 02 00 00       	push   $0x2bc
f010116c:	68 9d 76 10 f0       	push   $0xf010769d
f0101171:	e8 1e ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101176:	68 d4 6d 10 f0       	push   $0xf0106dd4
f010117b:	68 c3 76 10 f0       	push   $0xf01076c3
f0101180:	68 bd 02 00 00       	push   $0x2bd
f0101185:	68 9d 76 10 f0       	push   $0xf010769d
f010118a:	e8 05 ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f010118f:	68 16 77 10 f0       	push   $0xf0107716
f0101194:	68 c3 76 10 f0       	push   $0xf01076c3
f0101199:	68 be 02 00 00       	push   $0x2be
f010119e:	68 9d 76 10 f0       	push   $0xf010769d
f01011a3:	e8 ec ee ff ff       	call   f0100094 <_panic>
	if (PGNUM(pa) >= npages)
f01011a8:	89 c7                	mov    %eax,%edi
f01011aa:	c1 ef 0c             	shr    $0xc,%edi
f01011ad:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f01011b0:	76 19                	jbe    f01011cb <check_page_free_list+0x19a>
	return (void *)(pa + KERNBASE);
f01011b2:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01011b8:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f01011bb:	77 20                	ja     f01011dd <check_page_free_list+0x1ac>
		assert(page2pa(pp) != MPENTRY_PADDR);
f01011bd:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01011c2:	0f 84 92 00 00 00    	je     f010125a <check_page_free_list+0x229>
			++nfree_extmem;
f01011c8:	43                   	inc    %ebx
f01011c9:	eb 2c                	jmp    f01011f7 <check_page_free_list+0x1c6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011cb:	50                   	push   %eax
f01011cc:	68 c8 65 10 f0       	push   $0xf01065c8
f01011d1:	6a 58                	push   $0x58
f01011d3:	68 a9 76 10 f0       	push   $0xf01076a9
f01011d8:	e8 b7 ee ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01011dd:	68 f8 6d 10 f0       	push   $0xf0106df8
f01011e2:	68 c3 76 10 f0       	push   $0xf01076c3
f01011e7:	68 bf 02 00 00       	push   $0x2bf
f01011ec:	68 9d 76 10 f0       	push   $0xf010769d
f01011f1:	e8 9e ee ff ff       	call   f0100094 <_panic>
			++nfree_basemem;
f01011f6:	46                   	inc    %esi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01011f7:	8b 12                	mov    (%edx),%edx
f01011f9:	85 d2                	test   %edx,%edx
f01011fb:	74 76                	je     f0101273 <check_page_free_list+0x242>
		assert(pp >= pages);
f01011fd:	39 d1                	cmp    %edx,%ecx
f01011ff:	0f 87 f4 fe ff ff    	ja     f01010f9 <check_page_free_list+0xc8>
		assert(pp < pages + npages);
f0101205:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0101208:	0f 86 04 ff ff ff    	jbe    f0101112 <check_page_free_list+0xe1>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010120e:	89 d0                	mov    %edx,%eax
f0101210:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101213:	a8 07                	test   $0x7,%al
f0101215:	0f 85 10 ff ff ff    	jne    f010112b <check_page_free_list+0xfa>
	return (pp - pages) << PGSHIFT;
f010121b:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f010121e:	c1 e0 0c             	shl    $0xc,%eax
f0101221:	0f 84 1d ff ff ff    	je     f0101144 <check_page_free_list+0x113>
		assert(page2pa(pp) != IOPHYSMEM);
f0101227:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010122c:	0f 84 2b ff ff ff    	je     f010115d <check_page_free_list+0x12c>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101232:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101237:	0f 84 39 ff ff ff    	je     f0101176 <check_page_free_list+0x145>
		assert(page2pa(pp) != EXTPHYSMEM);
f010123d:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101242:	0f 84 47 ff ff ff    	je     f010118f <check_page_free_list+0x15e>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101248:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f010124d:	0f 87 55 ff ff ff    	ja     f01011a8 <check_page_free_list+0x177>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101253:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101258:	75 9c                	jne    f01011f6 <check_page_free_list+0x1c5>
f010125a:	68 30 77 10 f0       	push   $0xf0107730
f010125f:	68 c3 76 10 f0       	push   $0xf01076c3
f0101264:	68 c1 02 00 00       	push   $0x2c1
f0101269:	68 9d 76 10 f0       	push   $0xf010769d
f010126e:	e8 21 ee ff ff       	call   f0100094 <_panic>
	assert(nfree_basemem > 0);
f0101273:	85 f6                	test   %esi,%esi
f0101275:	7e 19                	jle    f0101290 <check_page_free_list+0x25f>
	assert(nfree_extmem > 0);
f0101277:	85 db                	test   %ebx,%ebx
f0101279:	7e 2e                	jle    f01012a9 <check_page_free_list+0x278>
	cprintf("check_page_free_list() succeeded!\n");
f010127b:	83 ec 0c             	sub    $0xc,%esp
f010127e:	68 40 6e 10 f0       	push   $0xf0106e40
f0101283:	e8 0b 2d 00 00       	call   f0103f93 <cprintf>
}
f0101288:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010128b:	5b                   	pop    %ebx
f010128c:	5e                   	pop    %esi
f010128d:	5f                   	pop    %edi
f010128e:	5d                   	pop    %ebp
f010128f:	c3                   	ret    
	assert(nfree_basemem > 0);
f0101290:	68 4d 77 10 f0       	push   $0xf010774d
f0101295:	68 c3 76 10 f0       	push   $0xf01076c3
f010129a:	68 c9 02 00 00       	push   $0x2c9
f010129f:	68 9d 76 10 f0       	push   $0xf010769d
f01012a4:	e8 eb ed ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f01012a9:	68 5f 77 10 f0       	push   $0xf010775f
f01012ae:	68 c3 76 10 f0       	push   $0xf01076c3
f01012b3:	68 ca 02 00 00       	push   $0x2ca
f01012b8:	68 9d 76 10 f0       	push   $0xf010769d
f01012bd:	e8 d2 ed ff ff       	call   f0100094 <_panic>
	if (!page_free_list)
f01012c2:	a1 40 12 29 f0       	mov    0xf0291240,%eax
f01012c7:	85 c0                	test   %eax,%eax
f01012c9:	0f 84 86 fd ff ff    	je     f0101055 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01012cf:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01012d2:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01012d5:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01012d8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01012db:	89 c2                	mov    %eax,%edx
f01012dd:	2b 15 90 1e 29 f0    	sub    0xf0291e90,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit; 
f01012e3:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f01012e9:	0f 95 c2             	setne  %dl
f01012ec:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f01012ef:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f01012f3:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f01012f5:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f01012f9:	8b 00                	mov    (%eax),%eax
f01012fb:	85 c0                	test   %eax,%eax
f01012fd:	75 dc                	jne    f01012db <check_page_free_list+0x2aa>
		*tp[1] = 0;
f01012ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101302:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101308:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010130b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010130e:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101310:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101313:	a3 40 12 29 f0       	mov    %eax,0xf0291240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101318:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010131d:	8b 1d 40 12 29 f0    	mov    0xf0291240,%ebx
f0101323:	e9 58 fd ff ff       	jmp    f0101080 <check_page_free_list+0x4f>

f0101328 <page_init>:
{
f0101328:	55                   	push   %ebp
f0101329:	89 e5                	mov    %esp,%ebp
f010132b:	57                   	push   %edi
f010132c:	56                   	push   %esi
f010132d:	53                   	push   %ebx
f010132e:	83 ec 1c             	sub    $0x1c,%esp
	physaddr_t free = (physaddr_t) PADDR(boot_alloc(0));
f0101331:	b8 00 00 00 00       	mov    $0x0,%eax
f0101336:	e8 2a fc ff ff       	call   f0100f65 <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f010133b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101340:	76 32                	jbe    f0101374 <page_init+0x4c>
	return (physaddr_t)kva - KERNBASE;
f0101342:	05 00 00 00 10       	add    $0x10000000,%eax
f0101347:	89 45 e0             	mov    %eax,-0x20(%ebp)
	size_t core_code_end = MPENTRY_PADDR + mpentry_end - mpentry_start;
f010134a:	b8 86 ca 10 f0       	mov    $0xf010ca86,%eax
f010134f:	2d 0c 5a 10 f0       	sub    $0xf0105a0c,%eax
f0101354:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if (i >= npages_basemem && len < free)
f0101357:	8b 1d 44 12 29 f0    	mov    0xf0291244,%ebx
f010135d:	8b 0d 40 12 29 f0    	mov    0xf0291240,%ecx
	for (i = 1, len = PGSIZE; i < npages; i++, len += PGSIZE) {
f0101363:	bf 00 00 00 00       	mov    $0x0,%edi
f0101368:	b8 01 00 00 00       	mov    $0x1,%eax
		page_free_list = &pages[i];
f010136d:	be 01 00 00 00       	mov    $0x1,%esi
	for (i = 1, len = PGSIZE; i < npages; i++, len += PGSIZE) {
f0101372:	eb 37                	jmp    f01013ab <page_init+0x83>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101374:	50                   	push   %eax
f0101375:	68 ec 65 10 f0       	push   $0xf01065ec
f010137a:	68 3e 01 00 00       	push   $0x13e
f010137f:	68 9d 76 10 f0       	push   $0xf010769d
f0101384:	e8 0b ed ff ff       	call   f0100094 <_panic>
		pages[i].pp_ref = 0;
f0101389:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0101390:	89 d7                	mov    %edx,%edi
f0101392:	03 3d 90 1e 29 f0    	add    0xf0291e90,%edi
f0101398:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
		pages[i].pp_link = page_free_list;
f010139e:	89 0f                	mov    %ecx,(%edi)
		page_free_list = &pages[i];
f01013a0:	89 d1                	mov    %edx,%ecx
f01013a2:	03 0d 90 1e 29 f0    	add    0xf0291e90,%ecx
f01013a8:	89 f7                	mov    %esi,%edi
	for (i = 1, len = PGSIZE; i < npages; i++, len += PGSIZE) {
f01013aa:	40                   	inc    %eax
f01013ab:	39 05 88 1e 29 f0    	cmp    %eax,0xf0291e88
f01013b1:	76 1d                	jbe    f01013d0 <page_init+0xa8>
f01013b3:	89 c2                	mov    %eax,%edx
f01013b5:	c1 e2 0c             	shl    $0xc,%edx
		if (len >= MPENTRY_PADDR && len < core_code_end) // We're in multicore code
f01013b8:	81 fa ff 6f 00 00    	cmp    $0x6fff,%edx
f01013be:	76 05                	jbe    f01013c5 <page_init+0x9d>
f01013c0:	39 55 e4             	cmp    %edx,-0x1c(%ebp)
f01013c3:	77 e5                	ja     f01013aa <page_init+0x82>
		if (i >= npages_basemem && len < free)
f01013c5:	39 c3                	cmp    %eax,%ebx
f01013c7:	77 c0                	ja     f0101389 <page_init+0x61>
f01013c9:	39 55 e0             	cmp    %edx,-0x20(%ebp)
f01013cc:	76 bb                	jbe    f0101389 <page_init+0x61>
f01013ce:	eb da                	jmp    f01013aa <page_init+0x82>
f01013d0:	89 f8                	mov    %edi,%eax
f01013d2:	84 c0                	test   %al,%al
f01013d4:	75 08                	jne    f01013de <page_init+0xb6>
}
f01013d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01013d9:	5b                   	pop    %ebx
f01013da:	5e                   	pop    %esi
f01013db:	5f                   	pop    %edi
f01013dc:	5d                   	pop    %ebp
f01013dd:	c3                   	ret    
f01013de:	89 0d 40 12 29 f0    	mov    %ecx,0xf0291240
f01013e4:	eb f0                	jmp    f01013d6 <page_init+0xae>

f01013e6 <page_alloc>:
{
f01013e6:	55                   	push   %ebp
f01013e7:	89 e5                	mov    %esp,%ebp
f01013e9:	53                   	push   %ebx
f01013ea:	83 ec 04             	sub    $0x4,%esp
	struct PageInfo* next = page_free_list;
f01013ed:	8b 1d 40 12 29 f0    	mov    0xf0291240,%ebx
	if (!next)
f01013f3:	85 db                	test   %ebx,%ebx
f01013f5:	74 13                	je     f010140a <page_alloc+0x24>
	page_free_list = page_free_list->pp_link;
f01013f7:	8b 03                	mov    (%ebx),%eax
f01013f9:	a3 40 12 29 f0       	mov    %eax,0xf0291240
	next->pp_link = NULL;
f01013fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f0101404:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101408:	75 07                	jne    f0101411 <page_alloc+0x2b>
}
f010140a:	89 d8                	mov    %ebx,%eax
f010140c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010140f:	c9                   	leave  
f0101410:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0101411:	89 d8                	mov    %ebx,%eax
f0101413:	2b 05 90 1e 29 f0    	sub    0xf0291e90,%eax
f0101419:	c1 f8 03             	sar    $0x3,%eax
f010141c:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010141f:	89 c2                	mov    %eax,%edx
f0101421:	c1 ea 0c             	shr    $0xc,%edx
f0101424:	3b 15 88 1e 29 f0    	cmp    0xf0291e88,%edx
f010142a:	73 1a                	jae    f0101446 <page_alloc+0x60>
		memset(content, 0, PGSIZE);
f010142c:	83 ec 04             	sub    $0x4,%esp
f010142f:	68 00 10 00 00       	push   $0x1000
f0101434:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0101436:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010143b:	50                   	push   %eax
f010143c:	e8 1b 43 00 00       	call   f010575c <memset>
f0101441:	83 c4 10             	add    $0x10,%esp
f0101444:	eb c4                	jmp    f010140a <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101446:	50                   	push   %eax
f0101447:	68 c8 65 10 f0       	push   $0xf01065c8
f010144c:	6a 58                	push   $0x58
f010144e:	68 a9 76 10 f0       	push   $0xf01076a9
f0101453:	e8 3c ec ff ff       	call   f0100094 <_panic>

f0101458 <page_free>:
{
f0101458:	55                   	push   %ebp
f0101459:	89 e5                	mov    %esp,%ebp
f010145b:	83 ec 08             	sub    $0x8,%esp
f010145e:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref)
f0101461:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101466:	75 14                	jne    f010147c <page_free+0x24>
	if (pp->pp_link)
f0101468:	83 38 00             	cmpl   $0x0,(%eax)
f010146b:	75 26                	jne    f0101493 <page_free+0x3b>
	pp->pp_link = page_free_list;
f010146d:	8b 15 40 12 29 f0    	mov    0xf0291240,%edx
f0101473:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101475:	a3 40 12 29 f0       	mov    %eax,0xf0291240
}
f010147a:	c9                   	leave  
f010147b:	c3                   	ret    
		panic("Ref count is non-zero");
f010147c:	83 ec 04             	sub    $0x4,%esp
f010147f:	68 70 77 10 f0       	push   $0xf0107770
f0101484:	68 70 01 00 00       	push   $0x170
f0101489:	68 9d 76 10 f0       	push   $0xf010769d
f010148e:	e8 01 ec ff ff       	call   f0100094 <_panic>
		panic("Page is double-freed");
f0101493:	83 ec 04             	sub    $0x4,%esp
f0101496:	68 86 77 10 f0       	push   $0xf0107786
f010149b:	68 72 01 00 00       	push   $0x172
f01014a0:	68 9d 76 10 f0       	push   $0xf010769d
f01014a5:	e8 ea eb ff ff       	call   f0100094 <_panic>

f01014aa <page_decref>:
{
f01014aa:	55                   	push   %ebp
f01014ab:	89 e5                	mov    %esp,%ebp
f01014ad:	83 ec 08             	sub    $0x8,%esp
f01014b0:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01014b3:	8b 42 04             	mov    0x4(%edx),%eax
f01014b6:	48                   	dec    %eax
f01014b7:	66 89 42 04          	mov    %ax,0x4(%edx)
f01014bb:	66 85 c0             	test   %ax,%ax
f01014be:	74 02                	je     f01014c2 <page_decref+0x18>
}
f01014c0:	c9                   	leave  
f01014c1:	c3                   	ret    
		page_free(pp);
f01014c2:	83 ec 0c             	sub    $0xc,%esp
f01014c5:	52                   	push   %edx
f01014c6:	e8 8d ff ff ff       	call   f0101458 <page_free>
f01014cb:	83 c4 10             	add    $0x10,%esp
}
f01014ce:	eb f0                	jmp    f01014c0 <page_decref+0x16>

f01014d0 <pgdir_walk>:
{
f01014d0:	55                   	push   %ebp
f01014d1:	89 e5                	mov    %esp,%ebp
f01014d3:	57                   	push   %edi
f01014d4:	56                   	push   %esi
f01014d5:	53                   	push   %ebx
f01014d6:	83 ec 1c             	sub    $0x1c,%esp
	pde_t pd_entry = (pde_t)pgdir[PDX(va)];
f01014d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01014dc:	c1 eb 16             	shr    $0x16,%ebx
f01014df:	c1 e3 02             	shl    $0x2,%ebx
f01014e2:	03 5d 08             	add    0x8(%ebp),%ebx
f01014e5:	8b 03                	mov    (%ebx),%eax
	if (pd_entry) {
f01014e7:	85 c0                	test   %eax,%eax
f01014e9:	74 42                	je     f010152d <pgdir_walk+0x5d>
		pte_t* pt_base = KADDR(PTE_ADDR(pd_entry));
f01014eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01014f0:	89 c2                	mov    %eax,%edx
f01014f2:	c1 ea 0c             	shr    $0xc,%edx
f01014f5:	39 15 88 1e 29 f0    	cmp    %edx,0xf0291e88
f01014fb:	76 1b                	jbe    f0101518 <pgdir_walk+0x48>
		return pt_base + PTX(va);
f01014fd:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101500:	c1 ea 0a             	shr    $0xa,%edx
f0101503:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f0101509:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
}
f0101510:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101513:	5b                   	pop    %ebx
f0101514:	5e                   	pop    %esi
f0101515:	5f                   	pop    %edi
f0101516:	5d                   	pop    %ebp
f0101517:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101518:	50                   	push   %eax
f0101519:	68 c8 65 10 f0       	push   $0xf01065c8
f010151e:	68 9d 01 00 00       	push   $0x19d
f0101523:	68 9d 76 10 f0       	push   $0xf010769d
f0101528:	e8 67 eb ff ff       	call   f0100094 <_panic>
	else if (create) {
f010152d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101531:	0f 84 9c 00 00 00    	je     f01015d3 <pgdir_walk+0x103>
		struct PageInfo *new_pt = page_alloc(0);
f0101537:	83 ec 0c             	sub    $0xc,%esp
f010153a:	6a 00                	push   $0x0
f010153c:	e8 a5 fe ff ff       	call   f01013e6 <page_alloc>
f0101541:	89 c7                	mov    %eax,%edi
		if (new_pt) {
f0101543:	83 c4 10             	add    $0x10,%esp
f0101546:	85 c0                	test   %eax,%eax
f0101548:	0f 84 8f 00 00 00    	je     f01015dd <pgdir_walk+0x10d>
	return (pp - pages) << PGSHIFT;
f010154e:	2b 05 90 1e 29 f0    	sub    0xf0291e90,%eax
f0101554:	c1 f8 03             	sar    $0x3,%eax
f0101557:	c1 e0 0c             	shl    $0xc,%eax
f010155a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (PGNUM(pa) >= npages)
f010155d:	c1 e8 0c             	shr    $0xc,%eax
f0101560:	3b 05 88 1e 29 f0    	cmp    0xf0291e88,%eax
f0101566:	73 42                	jae    f01015aa <pgdir_walk+0xda>
	return (void *)(pa + KERNBASE);
f0101568:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010156b:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
			memset(content, 0, PGSIZE);
f0101571:	83 ec 04             	sub    $0x4,%esp
f0101574:	68 00 10 00 00       	push   $0x1000
f0101579:	6a 00                	push   $0x0
f010157b:	56                   	push   %esi
f010157c:	e8 db 41 00 00       	call   f010575c <memset>
			new_pt->pp_ref++;
f0101581:	66 ff 47 04          	incw   0x4(%edi)
	if ((uint32_t)kva < KERNBASE)
f0101585:	83 c4 10             	add    $0x10,%esp
f0101588:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f010158e:	76 2e                	jbe    f01015be <pgdir_walk+0xee>
			pgdir[PDX(va)] = PADDR(content) | 0xF; // Set all permissions.
f0101590:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101593:	83 c8 0f             	or     $0xf,%eax
f0101596:	89 03                	mov    %eax,(%ebx)
			return (pte_t*) content + PTX(va);
f0101598:	8b 45 0c             	mov    0xc(%ebp),%eax
f010159b:	c1 e8 0a             	shr    $0xa,%eax
f010159e:	25 fc 0f 00 00       	and    $0xffc,%eax
f01015a3:	01 f0                	add    %esi,%eax
f01015a5:	e9 66 ff ff ff       	jmp    f0101510 <pgdir_walk+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015aa:	ff 75 e4             	pushl  -0x1c(%ebp)
f01015ad:	68 c8 65 10 f0       	push   $0xf01065c8
f01015b2:	6a 58                	push   $0x58
f01015b4:	68 a9 76 10 f0       	push   $0xf01076a9
f01015b9:	e8 d6 ea ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01015be:	56                   	push   %esi
f01015bf:	68 ec 65 10 f0       	push   $0xf01065ec
f01015c4:	68 a6 01 00 00       	push   $0x1a6
f01015c9:	68 9d 76 10 f0       	push   $0xf010769d
f01015ce:	e8 c1 ea ff ff       	call   f0100094 <_panic>
	return NULL;
f01015d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01015d8:	e9 33 ff ff ff       	jmp    f0101510 <pgdir_walk+0x40>
f01015dd:	b8 00 00 00 00       	mov    $0x0,%eax
f01015e2:	e9 29 ff ff ff       	jmp    f0101510 <pgdir_walk+0x40>

f01015e7 <boot_map_region>:
{
f01015e7:	55                   	push   %ebp
f01015e8:	89 e5                	mov    %esp,%ebp
f01015ea:	57                   	push   %edi
f01015eb:	56                   	push   %esi
f01015ec:	53                   	push   %ebx
f01015ed:	83 ec 1c             	sub    $0x1c,%esp
f01015f0:	89 c7                	mov    %eax,%edi
f01015f2:	89 d6                	mov    %edx,%esi
f01015f4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f01015f7:	bb 00 00 00 00       	mov    $0x0,%ebx
		*page_entry = (pa + size0) | perm | PTE_P;
f01015fc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015ff:	83 c8 01             	or     $0x1,%eax
f0101602:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f0101605:	eb 22                	jmp    f0101629 <boot_map_region+0x42>
		pte_t *page_entry = pgdir_walk(pgdir, (void*) va + size0, 1);
f0101607:	83 ec 04             	sub    $0x4,%esp
f010160a:	6a 01                	push   $0x1
f010160c:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f010160f:	50                   	push   %eax
f0101610:	57                   	push   %edi
f0101611:	e8 ba fe ff ff       	call   f01014d0 <pgdir_walk>
		*page_entry = (pa + size0) | perm | PTE_P;
f0101616:	89 da                	mov    %ebx,%edx
f0101618:	03 55 08             	add    0x8(%ebp),%edx
f010161b:	0b 55 e0             	or     -0x20(%ebp),%edx
f010161e:	89 10                	mov    %edx,(%eax)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f0101620:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101626:	83 c4 10             	add    $0x10,%esp
f0101629:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010162c:	72 d9                	jb     f0101607 <boot_map_region+0x20>
}
f010162e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101631:	5b                   	pop    %ebx
f0101632:	5e                   	pop    %esi
f0101633:	5f                   	pop    %edi
f0101634:	5d                   	pop    %ebp
f0101635:	c3                   	ret    

f0101636 <page_lookup>:
{
f0101636:	55                   	push   %ebp
f0101637:	89 e5                	mov    %esp,%ebp
f0101639:	53                   	push   %ebx
f010163a:	83 ec 08             	sub    $0x8,%esp
f010163d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *page_entry = pgdir_walk(pgdir, (void*) va, 0);
f0101640:	6a 00                	push   $0x0
f0101642:	ff 75 0c             	pushl  0xc(%ebp)
f0101645:	ff 75 08             	pushl  0x8(%ebp)
f0101648:	e8 83 fe ff ff       	call   f01014d0 <pgdir_walk>
	if (!page_entry || !*page_entry)
f010164d:	83 c4 10             	add    $0x10,%esp
f0101650:	85 c0                	test   %eax,%eax
f0101652:	74 3a                	je     f010168e <page_lookup+0x58>
f0101654:	83 38 00             	cmpl   $0x0,(%eax)
f0101657:	74 3c                	je     f0101695 <page_lookup+0x5f>
	if (pte_store)
f0101659:	85 db                	test   %ebx,%ebx
f010165b:	74 02                	je     f010165f <page_lookup+0x29>
		*pte_store = page_entry;
f010165d:	89 03                	mov    %eax,(%ebx)
f010165f:	8b 00                	mov    (%eax),%eax
f0101661:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101664:	39 05 88 1e 29 f0    	cmp    %eax,0xf0291e88
f010166a:	76 0e                	jbe    f010167a <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f010166c:	8b 15 90 1e 29 f0    	mov    0xf0291e90,%edx
f0101672:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0101675:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101678:	c9                   	leave  
f0101679:	c3                   	ret    
		panic("pa2page called with invalid pa");
f010167a:	83 ec 04             	sub    $0x4,%esp
f010167d:	68 64 6e 10 f0       	push   $0xf0106e64
f0101682:	6a 51                	push   $0x51
f0101684:	68 a9 76 10 f0       	push   $0xf01076a9
f0101689:	e8 06 ea ff ff       	call   f0100094 <_panic>
		return NULL;
f010168e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101693:	eb e0                	jmp    f0101675 <page_lookup+0x3f>
f0101695:	b8 00 00 00 00       	mov    $0x0,%eax
f010169a:	eb d9                	jmp    f0101675 <page_lookup+0x3f>

f010169c <tlb_invalidate>:
{
f010169c:	55                   	push   %ebp
f010169d:	89 e5                	mov    %esp,%ebp
f010169f:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f01016a2:	e8 8f 47 00 00       	call   f0105e36 <cpunum>
f01016a7:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01016aa:	01 c2                	add    %eax,%edx
f01016ac:	01 d2                	add    %edx,%edx
f01016ae:	01 c2                	add    %eax,%edx
f01016b0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01016b3:	83 3c 85 28 20 29 f0 	cmpl   $0x0,-0xfd6dfd8(,%eax,4)
f01016ba:	00 
f01016bb:	74 20                	je     f01016dd <tlb_invalidate+0x41>
f01016bd:	e8 74 47 00 00       	call   f0105e36 <cpunum>
f01016c2:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01016c5:	01 c2                	add    %eax,%edx
f01016c7:	01 d2                	add    %edx,%edx
f01016c9:	01 c2                	add    %eax,%edx
f01016cb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01016ce:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f01016d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01016d8:	39 48 60             	cmp    %ecx,0x60(%eax)
f01016db:	75 06                	jne    f01016e3 <tlb_invalidate+0x47>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01016dd:	8b 45 0c             	mov    0xc(%ebp),%eax
f01016e0:	0f 01 38             	invlpg (%eax)
}
f01016e3:	c9                   	leave  
f01016e4:	c3                   	ret    

f01016e5 <page_remove>:
{
f01016e5:	55                   	push   %ebp
f01016e6:	89 e5                	mov    %esp,%ebp
f01016e8:	57                   	push   %edi
f01016e9:	56                   	push   %esi
f01016ea:	53                   	push   %ebx
f01016eb:	83 ec 20             	sub    $0x20,%esp
f01016ee:	8b 75 08             	mov    0x8(%ebp),%esi
f01016f1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct PageInfo *pp = page_lookup(pgdir, va, &pte_store);
f01016f4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01016f7:	50                   	push   %eax
f01016f8:	57                   	push   %edi
f01016f9:	56                   	push   %esi
f01016fa:	e8 37 ff ff ff       	call   f0101636 <page_lookup>
	if (!pp)
f01016ff:	83 c4 10             	add    $0x10,%esp
f0101702:	85 c0                	test   %eax,%eax
f0101704:	74 23                	je     f0101729 <page_remove+0x44>
f0101706:	89 c3                	mov    %eax,%ebx
	pp->pp_ref--;
f0101708:	66 ff 48 04          	decw   0x4(%eax)
	*pte_store = 0;
f010170c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010170f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f0101715:	83 ec 08             	sub    $0x8,%esp
f0101718:	57                   	push   %edi
f0101719:	56                   	push   %esi
f010171a:	e8 7d ff ff ff       	call   f010169c <tlb_invalidate>
	if (!pp->pp_ref)
f010171f:	83 c4 10             	add    $0x10,%esp
f0101722:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101727:	74 08                	je     f0101731 <page_remove+0x4c>
}
f0101729:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010172c:	5b                   	pop    %ebx
f010172d:	5e                   	pop    %esi
f010172e:	5f                   	pop    %edi
f010172f:	5d                   	pop    %ebp
f0101730:	c3                   	ret    
		page_free(pp);
f0101731:	83 ec 0c             	sub    $0xc,%esp
f0101734:	53                   	push   %ebx
f0101735:	e8 1e fd ff ff       	call   f0101458 <page_free>
f010173a:	83 c4 10             	add    $0x10,%esp
f010173d:	eb ea                	jmp    f0101729 <page_remove+0x44>

f010173f <page_insert>:
{
f010173f:	55                   	push   %ebp
f0101740:	89 e5                	mov    %esp,%ebp
f0101742:	57                   	push   %edi
f0101743:	56                   	push   %esi
f0101744:	53                   	push   %ebx
f0101745:	83 ec 10             	sub    $0x10,%esp
f0101748:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010174b:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *page_entry = pgdir_walk(pgdir, (void*) va, 1);
f010174e:	6a 01                	push   $0x1
f0101750:	57                   	push   %edi
f0101751:	ff 75 08             	pushl  0x8(%ebp)
f0101754:	e8 77 fd ff ff       	call   f01014d0 <pgdir_walk>
	if (!page_entry)
f0101759:	83 c4 10             	add    $0x10,%esp
f010175c:	85 c0                	test   %eax,%eax
f010175e:	74 3f                	je     f010179f <page_insert+0x60>
f0101760:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f0101762:	66 ff 43 04          	incw   0x4(%ebx)
	if (*page_entry) 
f0101766:	83 38 00             	cmpl   $0x0,(%eax)
f0101769:	75 23                	jne    f010178e <page_insert+0x4f>
	return (pp - pages) << PGSHIFT;
f010176b:	2b 1d 90 1e 29 f0    	sub    0xf0291e90,%ebx
f0101771:	c1 fb 03             	sar    $0x3,%ebx
f0101774:	c1 e3 0c             	shl    $0xc,%ebx
	*page_entry = page2pa(pp) | perm | PTE_P;
f0101777:	8b 45 14             	mov    0x14(%ebp),%eax
f010177a:	83 c8 01             	or     $0x1,%eax
f010177d:	09 c3                	or     %eax,%ebx
f010177f:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0101781:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101786:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101789:	5b                   	pop    %ebx
f010178a:	5e                   	pop    %esi
f010178b:	5f                   	pop    %edi
f010178c:	5d                   	pop    %ebp
f010178d:	c3                   	ret    
		page_remove(pgdir, va);
f010178e:	83 ec 08             	sub    $0x8,%esp
f0101791:	57                   	push   %edi
f0101792:	ff 75 08             	pushl  0x8(%ebp)
f0101795:	e8 4b ff ff ff       	call   f01016e5 <page_remove>
f010179a:	83 c4 10             	add    $0x10,%esp
f010179d:	eb cc                	jmp    f010176b <page_insert+0x2c>
		return -E_NO_MEM;  // Has no page table AND cannot be allocated
f010179f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01017a4:	eb e0                	jmp    f0101786 <page_insert+0x47>

f01017a6 <mmio_map_region>:
{
f01017a6:	55                   	push   %ebp
f01017a7:	89 e5                	mov    %esp,%ebp
f01017a9:	53                   	push   %ebx
f01017aa:	83 ec 04             	sub    $0x4,%esp
	size_t size_up = ROUNDUP(size, PGSIZE);
f01017ad:	8b 45 0c             	mov    0xc(%ebp),%eax
f01017b0:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01017b6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (base >= MMIOLIM)
f01017bc:	8b 15 00 23 12 f0    	mov    0xf0122300,%edx
f01017c2:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01017c8:	77 26                	ja     f01017f0 <mmio_map_region+0x4a>
	boot_map_region(kern_pgdir, base, size_up, pa, PTE_PCD|PTE_PWT|PTE_W);
f01017ca:	83 ec 08             	sub    $0x8,%esp
f01017cd:	6a 1a                	push   $0x1a
f01017cf:	ff 75 08             	pushl  0x8(%ebp)
f01017d2:	89 d9                	mov    %ebx,%ecx
f01017d4:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f01017d9:	e8 09 fe ff ff       	call   f01015e7 <boot_map_region>
	base += size_up;
f01017de:	a1 00 23 12 f0       	mov    0xf0122300,%eax
f01017e3:	01 c3                	add    %eax,%ebx
f01017e5:	89 1d 00 23 12 f0    	mov    %ebx,0xf0122300
}
f01017eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01017ee:	c9                   	leave  
f01017ef:	c3                   	ret    
		panic("MMIO overflowed!");
f01017f0:	83 ec 04             	sub    $0x4,%esp
f01017f3:	68 9b 77 10 f0       	push   $0xf010779b
f01017f8:	68 48 02 00 00       	push   $0x248
f01017fd:	68 9d 76 10 f0       	push   $0xf010769d
f0101802:	e8 8d e8 ff ff       	call   f0100094 <_panic>

f0101807 <mem_init>:
{
f0101807:	55                   	push   %ebp
f0101808:	89 e5                	mov    %esp,%ebp
f010180a:	57                   	push   %edi
f010180b:	56                   	push   %esi
f010180c:	53                   	push   %ebx
f010180d:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0101810:	b8 15 00 00 00       	mov    $0x15,%eax
f0101815:	e8 91 f7 ff ff       	call   f0100fab <nvram_read>
f010181a:	89 c6                	mov    %eax,%esi
	extmem = nvram_read(NVRAM_EXTLO);
f010181c:	b8 17 00 00 00       	mov    $0x17,%eax
f0101821:	e8 85 f7 ff ff       	call   f0100fab <nvram_read>
f0101826:	89 c3                	mov    %eax,%ebx
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101828:	b8 34 00 00 00       	mov    $0x34,%eax
f010182d:	e8 79 f7 ff ff       	call   f0100fab <nvram_read>
	if (ext16mem)
f0101832:	c1 e0 06             	shl    $0x6,%eax
f0101835:	75 10                	jne    f0101847 <mem_init+0x40>
	else if (extmem)
f0101837:	85 db                	test   %ebx,%ebx
f0101839:	0f 84 e6 00 00 00    	je     f0101925 <mem_init+0x11e>
		totalmem = 1 * 1024 + extmem;
f010183f:	8d 83 00 04 00 00    	lea    0x400(%ebx),%eax
f0101845:	eb 05                	jmp    f010184c <mem_init+0x45>
		totalmem = 16 * 1024 + ext16mem;
f0101847:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f010184c:	89 c2                	mov    %eax,%edx
f010184e:	c1 ea 02             	shr    $0x2,%edx
f0101851:	89 15 88 1e 29 f0    	mov    %edx,0xf0291e88
	npages_basemem = basemem / (PGSIZE / 1024);
f0101857:	89 f2                	mov    %esi,%edx
f0101859:	c1 ea 02             	shr    $0x2,%edx
f010185c:	89 15 44 12 29 f0    	mov    %edx,0xf0291244
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101862:	89 c2                	mov    %eax,%edx
f0101864:	29 f2                	sub    %esi,%edx
f0101866:	52                   	push   %edx
f0101867:	56                   	push   %esi
f0101868:	50                   	push   %eax
f0101869:	68 84 6e 10 f0       	push   $0xf0106e84
f010186e:	e8 20 27 00 00       	call   f0103f93 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101873:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101878:	e8 e8 f6 ff ff       	call   f0100f65 <boot_alloc>
f010187d:	a3 8c 1e 29 f0       	mov    %eax,0xf0291e8c
	memset(kern_pgdir, 0, PGSIZE);
f0101882:	83 c4 0c             	add    $0xc,%esp
f0101885:	68 00 10 00 00       	push   $0x1000
f010188a:	6a 00                	push   $0x0
f010188c:	50                   	push   %eax
f010188d:	e8 ca 3e 00 00       	call   f010575c <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101892:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0101897:	83 c4 10             	add    $0x10,%esp
f010189a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010189f:	0f 86 87 00 00 00    	jbe    f010192c <mem_init+0x125>
	return (physaddr_t)kva - KERNBASE;
f01018a5:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01018ab:	83 ca 05             	or     $0x5,%edx
f01018ae:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo)*npages);
f01018b4:	a1 88 1e 29 f0       	mov    0xf0291e88,%eax
f01018b9:	c1 e0 03             	shl    $0x3,%eax
f01018bc:	e8 a4 f6 ff ff       	call   f0100f65 <boot_alloc>
f01018c1:	a3 90 1e 29 f0       	mov    %eax,0xf0291e90
	memset(pages, 0, sizeof(struct PageInfo)*npages);
f01018c6:	83 ec 04             	sub    $0x4,%esp
f01018c9:	8b 0d 88 1e 29 f0    	mov    0xf0291e88,%ecx
f01018cf:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01018d6:	52                   	push   %edx
f01018d7:	6a 00                	push   $0x0
f01018d9:	50                   	push   %eax
f01018da:	e8 7d 3e 00 00       	call   f010575c <memset>
	envs = (struct Env *) boot_alloc(sizeof(struct Env)*NENV);
f01018df:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01018e4:	e8 7c f6 ff ff       	call   f0100f65 <boot_alloc>
f01018e9:	a3 48 12 29 f0       	mov    %eax,0xf0291248
	memset(envs, 0, sizeof(struct Env)*NENV);
f01018ee:	83 c4 0c             	add    $0xc,%esp
f01018f1:	68 00 f0 01 00       	push   $0x1f000
f01018f6:	6a 00                	push   $0x0
f01018f8:	50                   	push   %eax
f01018f9:	e8 5e 3e 00 00       	call   f010575c <memset>
	page_init();
f01018fe:	e8 25 fa ff ff       	call   f0101328 <page_init>
	check_page_free_list(1);
f0101903:	b8 01 00 00 00       	mov    $0x1,%eax
f0101908:	e8 24 f7 ff ff       	call   f0101031 <check_page_free_list>
	if (!pages)
f010190d:	83 c4 10             	add    $0x10,%esp
f0101910:	83 3d 90 1e 29 f0 00 	cmpl   $0x0,0xf0291e90
f0101917:	74 28                	je     f0101941 <mem_init+0x13a>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101919:	a1 40 12 29 f0       	mov    0xf0291240,%eax
f010191e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101923:	eb 36                	jmp    f010195b <mem_init+0x154>
		totalmem = basemem;
f0101925:	89 f0                	mov    %esi,%eax
f0101927:	e9 20 ff ff ff       	jmp    f010184c <mem_init+0x45>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010192c:	50                   	push   %eax
f010192d:	68 ec 65 10 f0       	push   $0xf01065ec
f0101932:	68 94 00 00 00       	push   $0x94
f0101937:	68 9d 76 10 f0       	push   $0xf010769d
f010193c:	e8 53 e7 ff ff       	call   f0100094 <_panic>
		panic("'pages' is a null pointer!");
f0101941:	83 ec 04             	sub    $0x4,%esp
f0101944:	68 ac 77 10 f0       	push   $0xf01077ac
f0101949:	68 dd 02 00 00       	push   $0x2dd
f010194e:	68 9d 76 10 f0       	push   $0xf010769d
f0101953:	e8 3c e7 ff ff       	call   f0100094 <_panic>
		++nfree;
f0101958:	43                   	inc    %ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101959:	8b 00                	mov    (%eax),%eax
f010195b:	85 c0                	test   %eax,%eax
f010195d:	75 f9                	jne    f0101958 <mem_init+0x151>
	assert((pp0 = page_alloc(0)));
f010195f:	83 ec 0c             	sub    $0xc,%esp
f0101962:	6a 00                	push   $0x0
f0101964:	e8 7d fa ff ff       	call   f01013e6 <page_alloc>
f0101969:	89 c7                	mov    %eax,%edi
f010196b:	83 c4 10             	add    $0x10,%esp
f010196e:	85 c0                	test   %eax,%eax
f0101970:	0f 84 10 02 00 00    	je     f0101b86 <mem_init+0x37f>
	assert((pp1 = page_alloc(0)));
f0101976:	83 ec 0c             	sub    $0xc,%esp
f0101979:	6a 00                	push   $0x0
f010197b:	e8 66 fa ff ff       	call   f01013e6 <page_alloc>
f0101980:	89 c6                	mov    %eax,%esi
f0101982:	83 c4 10             	add    $0x10,%esp
f0101985:	85 c0                	test   %eax,%eax
f0101987:	0f 84 12 02 00 00    	je     f0101b9f <mem_init+0x398>
	assert((pp2 = page_alloc(0)));
f010198d:	83 ec 0c             	sub    $0xc,%esp
f0101990:	6a 00                	push   $0x0
f0101992:	e8 4f fa ff ff       	call   f01013e6 <page_alloc>
f0101997:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010199a:	83 c4 10             	add    $0x10,%esp
f010199d:	85 c0                	test   %eax,%eax
f010199f:	0f 84 13 02 00 00    	je     f0101bb8 <mem_init+0x3b1>
	assert(pp1 && pp1 != pp0);
f01019a5:	39 f7                	cmp    %esi,%edi
f01019a7:	0f 84 24 02 00 00    	je     f0101bd1 <mem_init+0x3ca>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019ad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019b0:	39 c6                	cmp    %eax,%esi
f01019b2:	0f 84 32 02 00 00    	je     f0101bea <mem_init+0x3e3>
f01019b8:	39 c7                	cmp    %eax,%edi
f01019ba:	0f 84 2a 02 00 00    	je     f0101bea <mem_init+0x3e3>
	return (pp - pages) << PGSHIFT;
f01019c0:	8b 0d 90 1e 29 f0    	mov    0xf0291e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01019c6:	8b 15 88 1e 29 f0    	mov    0xf0291e88,%edx
f01019cc:	c1 e2 0c             	shl    $0xc,%edx
f01019cf:	89 f8                	mov    %edi,%eax
f01019d1:	29 c8                	sub    %ecx,%eax
f01019d3:	c1 f8 03             	sar    $0x3,%eax
f01019d6:	c1 e0 0c             	shl    $0xc,%eax
f01019d9:	39 d0                	cmp    %edx,%eax
f01019db:	0f 83 22 02 00 00    	jae    f0101c03 <mem_init+0x3fc>
f01019e1:	89 f0                	mov    %esi,%eax
f01019e3:	29 c8                	sub    %ecx,%eax
f01019e5:	c1 f8 03             	sar    $0x3,%eax
f01019e8:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01019eb:	39 c2                	cmp    %eax,%edx
f01019ed:	0f 86 29 02 00 00    	jbe    f0101c1c <mem_init+0x415>
f01019f3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019f6:	29 c8                	sub    %ecx,%eax
f01019f8:	c1 f8 03             	sar    $0x3,%eax
f01019fb:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01019fe:	39 c2                	cmp    %eax,%edx
f0101a00:	0f 86 2f 02 00 00    	jbe    f0101c35 <mem_init+0x42e>
	fl = page_free_list;
f0101a06:	a1 40 12 29 f0       	mov    0xf0291240,%eax
f0101a0b:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101a0e:	c7 05 40 12 29 f0 00 	movl   $0x0,0xf0291240
f0101a15:	00 00 00 
	assert(!page_alloc(0));
f0101a18:	83 ec 0c             	sub    $0xc,%esp
f0101a1b:	6a 00                	push   $0x0
f0101a1d:	e8 c4 f9 ff ff       	call   f01013e6 <page_alloc>
f0101a22:	83 c4 10             	add    $0x10,%esp
f0101a25:	85 c0                	test   %eax,%eax
f0101a27:	0f 85 21 02 00 00    	jne    f0101c4e <mem_init+0x447>
	page_free(pp0);
f0101a2d:	83 ec 0c             	sub    $0xc,%esp
f0101a30:	57                   	push   %edi
f0101a31:	e8 22 fa ff ff       	call   f0101458 <page_free>
	page_free(pp1);
f0101a36:	89 34 24             	mov    %esi,(%esp)
f0101a39:	e8 1a fa ff ff       	call   f0101458 <page_free>
	page_free(pp2);
f0101a3e:	83 c4 04             	add    $0x4,%esp
f0101a41:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a44:	e8 0f fa ff ff       	call   f0101458 <page_free>
	assert((pp0 = page_alloc(0)));
f0101a49:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a50:	e8 91 f9 ff ff       	call   f01013e6 <page_alloc>
f0101a55:	89 c6                	mov    %eax,%esi
f0101a57:	83 c4 10             	add    $0x10,%esp
f0101a5a:	85 c0                	test   %eax,%eax
f0101a5c:	0f 84 05 02 00 00    	je     f0101c67 <mem_init+0x460>
	assert((pp1 = page_alloc(0)));
f0101a62:	83 ec 0c             	sub    $0xc,%esp
f0101a65:	6a 00                	push   $0x0
f0101a67:	e8 7a f9 ff ff       	call   f01013e6 <page_alloc>
f0101a6c:	89 c7                	mov    %eax,%edi
f0101a6e:	83 c4 10             	add    $0x10,%esp
f0101a71:	85 c0                	test   %eax,%eax
f0101a73:	0f 84 07 02 00 00    	je     f0101c80 <mem_init+0x479>
	assert((pp2 = page_alloc(0)));
f0101a79:	83 ec 0c             	sub    $0xc,%esp
f0101a7c:	6a 00                	push   $0x0
f0101a7e:	e8 63 f9 ff ff       	call   f01013e6 <page_alloc>
f0101a83:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a86:	83 c4 10             	add    $0x10,%esp
f0101a89:	85 c0                	test   %eax,%eax
f0101a8b:	0f 84 08 02 00 00    	je     f0101c99 <mem_init+0x492>
	assert(pp1 && pp1 != pp0);
f0101a91:	39 fe                	cmp    %edi,%esi
f0101a93:	0f 84 19 02 00 00    	je     f0101cb2 <mem_init+0x4ab>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a99:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a9c:	39 c7                	cmp    %eax,%edi
f0101a9e:	0f 84 27 02 00 00    	je     f0101ccb <mem_init+0x4c4>
f0101aa4:	39 c6                	cmp    %eax,%esi
f0101aa6:	0f 84 1f 02 00 00    	je     f0101ccb <mem_init+0x4c4>
	assert(!page_alloc(0));
f0101aac:	83 ec 0c             	sub    $0xc,%esp
f0101aaf:	6a 00                	push   $0x0
f0101ab1:	e8 30 f9 ff ff       	call   f01013e6 <page_alloc>
f0101ab6:	83 c4 10             	add    $0x10,%esp
f0101ab9:	85 c0                	test   %eax,%eax
f0101abb:	0f 85 23 02 00 00    	jne    f0101ce4 <mem_init+0x4dd>
f0101ac1:	89 f0                	mov    %esi,%eax
f0101ac3:	2b 05 90 1e 29 f0    	sub    0xf0291e90,%eax
f0101ac9:	c1 f8 03             	sar    $0x3,%eax
f0101acc:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101acf:	89 c2                	mov    %eax,%edx
f0101ad1:	c1 ea 0c             	shr    $0xc,%edx
f0101ad4:	3b 15 88 1e 29 f0    	cmp    0xf0291e88,%edx
f0101ada:	0f 83 1d 02 00 00    	jae    f0101cfd <mem_init+0x4f6>
	memset(page2kva(pp0), 1, PGSIZE);
f0101ae0:	83 ec 04             	sub    $0x4,%esp
f0101ae3:	68 00 10 00 00       	push   $0x1000
f0101ae8:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101aea:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101aef:	50                   	push   %eax
f0101af0:	e8 67 3c 00 00       	call   f010575c <memset>
	page_free(pp0);
f0101af5:	89 34 24             	mov    %esi,(%esp)
f0101af8:	e8 5b f9 ff ff       	call   f0101458 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101afd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101b04:	e8 dd f8 ff ff       	call   f01013e6 <page_alloc>
f0101b09:	83 c4 10             	add    $0x10,%esp
f0101b0c:	85 c0                	test   %eax,%eax
f0101b0e:	0f 84 fb 01 00 00    	je     f0101d0f <mem_init+0x508>
	assert(pp && pp0 == pp);
f0101b14:	39 c6                	cmp    %eax,%esi
f0101b16:	0f 85 0c 02 00 00    	jne    f0101d28 <mem_init+0x521>
	return (pp - pages) << PGSHIFT;
f0101b1c:	89 f2                	mov    %esi,%edx
f0101b1e:	2b 15 90 1e 29 f0    	sub    0xf0291e90,%edx
f0101b24:	c1 fa 03             	sar    $0x3,%edx
f0101b27:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101b2a:	89 d0                	mov    %edx,%eax
f0101b2c:	c1 e8 0c             	shr    $0xc,%eax
f0101b2f:	3b 05 88 1e 29 f0    	cmp    0xf0291e88,%eax
f0101b35:	0f 83 06 02 00 00    	jae    f0101d41 <mem_init+0x53a>
	return (void *)(pa + KERNBASE);
f0101b3b:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101b41:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101b47:	80 38 00             	cmpb   $0x0,(%eax)
f0101b4a:	0f 85 03 02 00 00    	jne    f0101d53 <mem_init+0x54c>
f0101b50:	40                   	inc    %eax
	for (i = 0; i < PGSIZE; i++)
f0101b51:	39 d0                	cmp    %edx,%eax
f0101b53:	75 f2                	jne    f0101b47 <mem_init+0x340>
	page_free_list = fl;
f0101b55:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b58:	a3 40 12 29 f0       	mov    %eax,0xf0291240
	page_free(pp0);
f0101b5d:	83 ec 0c             	sub    $0xc,%esp
f0101b60:	56                   	push   %esi
f0101b61:	e8 f2 f8 ff ff       	call   f0101458 <page_free>
	page_free(pp1);
f0101b66:	89 3c 24             	mov    %edi,(%esp)
f0101b69:	e8 ea f8 ff ff       	call   f0101458 <page_free>
	page_free(pp2);
f0101b6e:	83 c4 04             	add    $0x4,%esp
f0101b71:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b74:	e8 df f8 ff ff       	call   f0101458 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b79:	a1 40 12 29 f0       	mov    0xf0291240,%eax
f0101b7e:	83 c4 10             	add    $0x10,%esp
f0101b81:	e9 e9 01 00 00       	jmp    f0101d6f <mem_init+0x568>
	assert((pp0 = page_alloc(0)));
f0101b86:	68 c7 77 10 f0       	push   $0xf01077c7
f0101b8b:	68 c3 76 10 f0       	push   $0xf01076c3
f0101b90:	68 e5 02 00 00       	push   $0x2e5
f0101b95:	68 9d 76 10 f0       	push   $0xf010769d
f0101b9a:	e8 f5 e4 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101b9f:	68 dd 77 10 f0       	push   $0xf01077dd
f0101ba4:	68 c3 76 10 f0       	push   $0xf01076c3
f0101ba9:	68 e6 02 00 00       	push   $0x2e6
f0101bae:	68 9d 76 10 f0       	push   $0xf010769d
f0101bb3:	e8 dc e4 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101bb8:	68 f3 77 10 f0       	push   $0xf01077f3
f0101bbd:	68 c3 76 10 f0       	push   $0xf01076c3
f0101bc2:	68 e7 02 00 00       	push   $0x2e7
f0101bc7:	68 9d 76 10 f0       	push   $0xf010769d
f0101bcc:	e8 c3 e4 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f0101bd1:	68 09 78 10 f0       	push   $0xf0107809
f0101bd6:	68 c3 76 10 f0       	push   $0xf01076c3
f0101bdb:	68 ea 02 00 00       	push   $0x2ea
f0101be0:	68 9d 76 10 f0       	push   $0xf010769d
f0101be5:	e8 aa e4 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101bea:	68 c0 6e 10 f0       	push   $0xf0106ec0
f0101bef:	68 c3 76 10 f0       	push   $0xf01076c3
f0101bf4:	68 eb 02 00 00       	push   $0x2eb
f0101bf9:	68 9d 76 10 f0       	push   $0xf010769d
f0101bfe:	e8 91 e4 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101c03:	68 1b 78 10 f0       	push   $0xf010781b
f0101c08:	68 c3 76 10 f0       	push   $0xf01076c3
f0101c0d:	68 ec 02 00 00       	push   $0x2ec
f0101c12:	68 9d 76 10 f0       	push   $0xf010769d
f0101c17:	e8 78 e4 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101c1c:	68 38 78 10 f0       	push   $0xf0107838
f0101c21:	68 c3 76 10 f0       	push   $0xf01076c3
f0101c26:	68 ed 02 00 00       	push   $0x2ed
f0101c2b:	68 9d 76 10 f0       	push   $0xf010769d
f0101c30:	e8 5f e4 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101c35:	68 55 78 10 f0       	push   $0xf0107855
f0101c3a:	68 c3 76 10 f0       	push   $0xf01076c3
f0101c3f:	68 ee 02 00 00       	push   $0x2ee
f0101c44:	68 9d 76 10 f0       	push   $0xf010769d
f0101c49:	e8 46 e4 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101c4e:	68 72 78 10 f0       	push   $0xf0107872
f0101c53:	68 c3 76 10 f0       	push   $0xf01076c3
f0101c58:	68 f5 02 00 00       	push   $0x2f5
f0101c5d:	68 9d 76 10 f0       	push   $0xf010769d
f0101c62:	e8 2d e4 ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f0101c67:	68 c7 77 10 f0       	push   $0xf01077c7
f0101c6c:	68 c3 76 10 f0       	push   $0xf01076c3
f0101c71:	68 fc 02 00 00       	push   $0x2fc
f0101c76:	68 9d 76 10 f0       	push   $0xf010769d
f0101c7b:	e8 14 e4 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c80:	68 dd 77 10 f0       	push   $0xf01077dd
f0101c85:	68 c3 76 10 f0       	push   $0xf01076c3
f0101c8a:	68 fd 02 00 00       	push   $0x2fd
f0101c8f:	68 9d 76 10 f0       	push   $0xf010769d
f0101c94:	e8 fb e3 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c99:	68 f3 77 10 f0       	push   $0xf01077f3
f0101c9e:	68 c3 76 10 f0       	push   $0xf01076c3
f0101ca3:	68 fe 02 00 00       	push   $0x2fe
f0101ca8:	68 9d 76 10 f0       	push   $0xf010769d
f0101cad:	e8 e2 e3 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f0101cb2:	68 09 78 10 f0       	push   $0xf0107809
f0101cb7:	68 c3 76 10 f0       	push   $0xf01076c3
f0101cbc:	68 00 03 00 00       	push   $0x300
f0101cc1:	68 9d 76 10 f0       	push   $0xf010769d
f0101cc6:	e8 c9 e3 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101ccb:	68 c0 6e 10 f0       	push   $0xf0106ec0
f0101cd0:	68 c3 76 10 f0       	push   $0xf01076c3
f0101cd5:	68 01 03 00 00       	push   $0x301
f0101cda:	68 9d 76 10 f0       	push   $0xf010769d
f0101cdf:	e8 b0 e3 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101ce4:	68 72 78 10 f0       	push   $0xf0107872
f0101ce9:	68 c3 76 10 f0       	push   $0xf01076c3
f0101cee:	68 02 03 00 00       	push   $0x302
f0101cf3:	68 9d 76 10 f0       	push   $0xf010769d
f0101cf8:	e8 97 e3 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101cfd:	50                   	push   %eax
f0101cfe:	68 c8 65 10 f0       	push   $0xf01065c8
f0101d03:	6a 58                	push   $0x58
f0101d05:	68 a9 76 10 f0       	push   $0xf01076a9
f0101d0a:	e8 85 e3 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101d0f:	68 81 78 10 f0       	push   $0xf0107881
f0101d14:	68 c3 76 10 f0       	push   $0xf01076c3
f0101d19:	68 07 03 00 00       	push   $0x307
f0101d1e:	68 9d 76 10 f0       	push   $0xf010769d
f0101d23:	e8 6c e3 ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f0101d28:	68 9f 78 10 f0       	push   $0xf010789f
f0101d2d:	68 c3 76 10 f0       	push   $0xf01076c3
f0101d32:	68 08 03 00 00       	push   $0x308
f0101d37:	68 9d 76 10 f0       	push   $0xf010769d
f0101d3c:	e8 53 e3 ff ff       	call   f0100094 <_panic>
f0101d41:	52                   	push   %edx
f0101d42:	68 c8 65 10 f0       	push   $0xf01065c8
f0101d47:	6a 58                	push   $0x58
f0101d49:	68 a9 76 10 f0       	push   $0xf01076a9
f0101d4e:	e8 41 e3 ff ff       	call   f0100094 <_panic>
		assert(c[i] == 0);
f0101d53:	68 af 78 10 f0       	push   $0xf01078af
f0101d58:	68 c3 76 10 f0       	push   $0xf01076c3
f0101d5d:	68 0b 03 00 00       	push   $0x30b
f0101d62:	68 9d 76 10 f0       	push   $0xf010769d
f0101d67:	e8 28 e3 ff ff       	call   f0100094 <_panic>
		--nfree;
f0101d6c:	4b                   	dec    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101d6d:	8b 00                	mov    (%eax),%eax
f0101d6f:	85 c0                	test   %eax,%eax
f0101d71:	75 f9                	jne    f0101d6c <mem_init+0x565>
	assert(nfree == 0);
f0101d73:	85 db                	test   %ebx,%ebx
f0101d75:	0f 85 87 09 00 00    	jne    f0102702 <mem_init+0xefb>
	cprintf("check_page_alloc() succeeded!\n");
f0101d7b:	83 ec 0c             	sub    $0xc,%esp
f0101d7e:	68 e0 6e 10 f0       	push   $0xf0106ee0
f0101d83:	e8 0b 22 00 00       	call   f0103f93 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101d88:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d8f:	e8 52 f6 ff ff       	call   f01013e6 <page_alloc>
f0101d94:	89 c7                	mov    %eax,%edi
f0101d96:	83 c4 10             	add    $0x10,%esp
f0101d99:	85 c0                	test   %eax,%eax
f0101d9b:	0f 84 7a 09 00 00    	je     f010271b <mem_init+0xf14>
	assert((pp1 = page_alloc(0)));
f0101da1:	83 ec 0c             	sub    $0xc,%esp
f0101da4:	6a 00                	push   $0x0
f0101da6:	e8 3b f6 ff ff       	call   f01013e6 <page_alloc>
f0101dab:	89 c3                	mov    %eax,%ebx
f0101dad:	83 c4 10             	add    $0x10,%esp
f0101db0:	85 c0                	test   %eax,%eax
f0101db2:	0f 84 7c 09 00 00    	je     f0102734 <mem_init+0xf2d>
	assert((pp2 = page_alloc(0)));
f0101db8:	83 ec 0c             	sub    $0xc,%esp
f0101dbb:	6a 00                	push   $0x0
f0101dbd:	e8 24 f6 ff ff       	call   f01013e6 <page_alloc>
f0101dc2:	89 c6                	mov    %eax,%esi
f0101dc4:	83 c4 10             	add    $0x10,%esp
f0101dc7:	85 c0                	test   %eax,%eax
f0101dc9:	0f 84 7e 09 00 00    	je     f010274d <mem_init+0xf46>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101dcf:	39 df                	cmp    %ebx,%edi
f0101dd1:	0f 84 8f 09 00 00    	je     f0102766 <mem_init+0xf5f>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101dd7:	39 c3                	cmp    %eax,%ebx
f0101dd9:	0f 84 a0 09 00 00    	je     f010277f <mem_init+0xf78>
f0101ddf:	39 c7                	cmp    %eax,%edi
f0101de1:	0f 84 98 09 00 00    	je     f010277f <mem_init+0xf78>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101de7:	a1 40 12 29 f0       	mov    0xf0291240,%eax
f0101dec:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f0101def:	c7 05 40 12 29 f0 00 	movl   $0x0,0xf0291240
f0101df6:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101df9:	83 ec 0c             	sub    $0xc,%esp
f0101dfc:	6a 00                	push   $0x0
f0101dfe:	e8 e3 f5 ff ff       	call   f01013e6 <page_alloc>
f0101e03:	83 c4 10             	add    $0x10,%esp
f0101e06:	85 c0                	test   %eax,%eax
f0101e08:	0f 85 8a 09 00 00    	jne    f0102798 <mem_init+0xf91>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101e0e:	83 ec 04             	sub    $0x4,%esp
f0101e11:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101e14:	50                   	push   %eax
f0101e15:	6a 00                	push   $0x0
f0101e17:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f0101e1d:	e8 14 f8 ff ff       	call   f0101636 <page_lookup>
f0101e22:	83 c4 10             	add    $0x10,%esp
f0101e25:	85 c0                	test   %eax,%eax
f0101e27:	0f 85 84 09 00 00    	jne    f01027b1 <mem_init+0xfaa>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101e2d:	6a 02                	push   $0x2
f0101e2f:	6a 00                	push   $0x0
f0101e31:	53                   	push   %ebx
f0101e32:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f0101e38:	e8 02 f9 ff ff       	call   f010173f <page_insert>
f0101e3d:	83 c4 10             	add    $0x10,%esp
f0101e40:	85 c0                	test   %eax,%eax
f0101e42:	0f 89 82 09 00 00    	jns    f01027ca <mem_init+0xfc3>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101e48:	83 ec 0c             	sub    $0xc,%esp
f0101e4b:	57                   	push   %edi
f0101e4c:	e8 07 f6 ff ff       	call   f0101458 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101e51:	6a 02                	push   $0x2
f0101e53:	6a 00                	push   $0x0
f0101e55:	53                   	push   %ebx
f0101e56:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f0101e5c:	e8 de f8 ff ff       	call   f010173f <page_insert>
f0101e61:	83 c4 20             	add    $0x20,%esp
f0101e64:	85 c0                	test   %eax,%eax
f0101e66:	0f 85 77 09 00 00    	jne    f01027e3 <mem_init+0xfdc>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e6c:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f0101e71:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	return (pp - pages) << PGSHIFT;
f0101e74:	8b 0d 90 1e 29 f0    	mov    0xf0291e90,%ecx
f0101e7a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101e7d:	8b 00                	mov    (%eax),%eax
f0101e7f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101e82:	89 c2                	mov    %eax,%edx
f0101e84:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101e8a:	89 f8                	mov    %edi,%eax
f0101e8c:	29 c8                	sub    %ecx,%eax
f0101e8e:	c1 f8 03             	sar    $0x3,%eax
f0101e91:	c1 e0 0c             	shl    $0xc,%eax
f0101e94:	39 c2                	cmp    %eax,%edx
f0101e96:	0f 85 60 09 00 00    	jne    f01027fc <mem_init+0xff5>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101e9c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ea1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ea4:	e8 29 f1 ff ff       	call   f0100fd2 <check_va2pa>
f0101ea9:	89 da                	mov    %ebx,%edx
f0101eab:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101eae:	c1 fa 03             	sar    $0x3,%edx
f0101eb1:	c1 e2 0c             	shl    $0xc,%edx
f0101eb4:	39 d0                	cmp    %edx,%eax
f0101eb6:	0f 85 59 09 00 00    	jne    f0102815 <mem_init+0x100e>
	assert(pp1->pp_ref == 1);
f0101ebc:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ec1:	0f 85 67 09 00 00    	jne    f010282e <mem_init+0x1027>
	assert(pp0->pp_ref == 1);
f0101ec7:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101ecc:	0f 85 75 09 00 00    	jne    f0102847 <mem_init+0x1040>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ed2:	6a 02                	push   $0x2
f0101ed4:	68 00 10 00 00       	push   $0x1000
f0101ed9:	56                   	push   %esi
f0101eda:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101edd:	e8 5d f8 ff ff       	call   f010173f <page_insert>
f0101ee2:	83 c4 10             	add    $0x10,%esp
f0101ee5:	85 c0                	test   %eax,%eax
f0101ee7:	0f 85 73 09 00 00    	jne    f0102860 <mem_init+0x1059>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101eed:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ef2:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f0101ef7:	e8 d6 f0 ff ff       	call   f0100fd2 <check_va2pa>
f0101efc:	89 f2                	mov    %esi,%edx
f0101efe:	2b 15 90 1e 29 f0    	sub    0xf0291e90,%edx
f0101f04:	c1 fa 03             	sar    $0x3,%edx
f0101f07:	c1 e2 0c             	shl    $0xc,%edx
f0101f0a:	39 d0                	cmp    %edx,%eax
f0101f0c:	0f 85 67 09 00 00    	jne    f0102879 <mem_init+0x1072>
	assert(pp2->pp_ref == 1);
f0101f12:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f17:	0f 85 75 09 00 00    	jne    f0102892 <mem_init+0x108b>

	// should be no free memory
	assert(!page_alloc(0));
f0101f1d:	83 ec 0c             	sub    $0xc,%esp
f0101f20:	6a 00                	push   $0x0
f0101f22:	e8 bf f4 ff ff       	call   f01013e6 <page_alloc>
f0101f27:	83 c4 10             	add    $0x10,%esp
f0101f2a:	85 c0                	test   %eax,%eax
f0101f2c:	0f 85 79 09 00 00    	jne    f01028ab <mem_init+0x10a4>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f32:	6a 02                	push   $0x2
f0101f34:	68 00 10 00 00       	push   $0x1000
f0101f39:	56                   	push   %esi
f0101f3a:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f0101f40:	e8 fa f7 ff ff       	call   f010173f <page_insert>
f0101f45:	83 c4 10             	add    $0x10,%esp
f0101f48:	85 c0                	test   %eax,%eax
f0101f4a:	0f 85 74 09 00 00    	jne    f01028c4 <mem_init+0x10bd>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f50:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f55:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f0101f5a:	e8 73 f0 ff ff       	call   f0100fd2 <check_va2pa>
f0101f5f:	89 f2                	mov    %esi,%edx
f0101f61:	2b 15 90 1e 29 f0    	sub    0xf0291e90,%edx
f0101f67:	c1 fa 03             	sar    $0x3,%edx
f0101f6a:	c1 e2 0c             	shl    $0xc,%edx
f0101f6d:	39 d0                	cmp    %edx,%eax
f0101f6f:	0f 85 68 09 00 00    	jne    f01028dd <mem_init+0x10d6>
	assert(pp2->pp_ref == 1);
f0101f75:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f7a:	0f 85 76 09 00 00    	jne    f01028f6 <mem_init+0x10ef>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101f80:	83 ec 0c             	sub    $0xc,%esp
f0101f83:	6a 00                	push   $0x0
f0101f85:	e8 5c f4 ff ff       	call   f01013e6 <page_alloc>
f0101f8a:	83 c4 10             	add    $0x10,%esp
f0101f8d:	85 c0                	test   %eax,%eax
f0101f8f:	0f 85 7a 09 00 00    	jne    f010290f <mem_init+0x1108>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101f95:	8b 15 8c 1e 29 f0    	mov    0xf0291e8c,%edx
f0101f9b:	8b 02                	mov    (%edx),%eax
f0101f9d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101fa2:	89 c1                	mov    %eax,%ecx
f0101fa4:	c1 e9 0c             	shr    $0xc,%ecx
f0101fa7:	3b 0d 88 1e 29 f0    	cmp    0xf0291e88,%ecx
f0101fad:	0f 83 75 09 00 00    	jae    f0102928 <mem_init+0x1121>
	return (void *)(pa + KERNBASE);
f0101fb3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101fb8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101fbb:	83 ec 04             	sub    $0x4,%esp
f0101fbe:	6a 00                	push   $0x0
f0101fc0:	68 00 10 00 00       	push   $0x1000
f0101fc5:	52                   	push   %edx
f0101fc6:	e8 05 f5 ff ff       	call   f01014d0 <pgdir_walk>
f0101fcb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101fce:	8d 51 04             	lea    0x4(%ecx),%edx
f0101fd1:	83 c4 10             	add    $0x10,%esp
f0101fd4:	39 d0                	cmp    %edx,%eax
f0101fd6:	0f 85 61 09 00 00    	jne    f010293d <mem_init+0x1136>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101fdc:	6a 06                	push   $0x6
f0101fde:	68 00 10 00 00       	push   $0x1000
f0101fe3:	56                   	push   %esi
f0101fe4:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f0101fea:	e8 50 f7 ff ff       	call   f010173f <page_insert>
f0101fef:	83 c4 10             	add    $0x10,%esp
f0101ff2:	85 c0                	test   %eax,%eax
f0101ff4:	0f 85 5c 09 00 00    	jne    f0102956 <mem_init+0x114f>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ffa:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f0101fff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102002:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102007:	e8 c6 ef ff ff       	call   f0100fd2 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f010200c:	89 f2                	mov    %esi,%edx
f010200e:	2b 15 90 1e 29 f0    	sub    0xf0291e90,%edx
f0102014:	c1 fa 03             	sar    $0x3,%edx
f0102017:	c1 e2 0c             	shl    $0xc,%edx
f010201a:	39 d0                	cmp    %edx,%eax
f010201c:	0f 85 4d 09 00 00    	jne    f010296f <mem_init+0x1168>
	assert(pp2->pp_ref == 1);
f0102022:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102027:	0f 85 5b 09 00 00    	jne    f0102988 <mem_init+0x1181>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010202d:	83 ec 04             	sub    $0x4,%esp
f0102030:	6a 00                	push   $0x0
f0102032:	68 00 10 00 00       	push   $0x1000
f0102037:	ff 75 d4             	pushl  -0x2c(%ebp)
f010203a:	e8 91 f4 ff ff       	call   f01014d0 <pgdir_walk>
f010203f:	83 c4 10             	add    $0x10,%esp
f0102042:	f6 00 04             	testb  $0x4,(%eax)
f0102045:	0f 84 56 09 00 00    	je     f01029a1 <mem_init+0x119a>
	assert(kern_pgdir[0] & PTE_U);
f010204b:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f0102050:	f6 00 04             	testb  $0x4,(%eax)
f0102053:	0f 84 61 09 00 00    	je     f01029ba <mem_init+0x11b3>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102059:	6a 02                	push   $0x2
f010205b:	68 00 10 00 00       	push   $0x1000
f0102060:	56                   	push   %esi
f0102061:	50                   	push   %eax
f0102062:	e8 d8 f6 ff ff       	call   f010173f <page_insert>
f0102067:	83 c4 10             	add    $0x10,%esp
f010206a:	85 c0                	test   %eax,%eax
f010206c:	0f 85 61 09 00 00    	jne    f01029d3 <mem_init+0x11cc>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102072:	83 ec 04             	sub    $0x4,%esp
f0102075:	6a 00                	push   $0x0
f0102077:	68 00 10 00 00       	push   $0x1000
f010207c:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f0102082:	e8 49 f4 ff ff       	call   f01014d0 <pgdir_walk>
f0102087:	83 c4 10             	add    $0x10,%esp
f010208a:	f6 00 02             	testb  $0x2,(%eax)
f010208d:	0f 84 59 09 00 00    	je     f01029ec <mem_init+0x11e5>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102093:	83 ec 04             	sub    $0x4,%esp
f0102096:	6a 00                	push   $0x0
f0102098:	68 00 10 00 00       	push   $0x1000
f010209d:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f01020a3:	e8 28 f4 ff ff       	call   f01014d0 <pgdir_walk>
f01020a8:	83 c4 10             	add    $0x10,%esp
f01020ab:	f6 00 04             	testb  $0x4,(%eax)
f01020ae:	0f 85 51 09 00 00    	jne    f0102a05 <mem_init+0x11fe>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01020b4:	6a 02                	push   $0x2
f01020b6:	68 00 00 40 00       	push   $0x400000
f01020bb:	57                   	push   %edi
f01020bc:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f01020c2:	e8 78 f6 ff ff       	call   f010173f <page_insert>
f01020c7:	83 c4 10             	add    $0x10,%esp
f01020ca:	85 c0                	test   %eax,%eax
f01020cc:	0f 89 4c 09 00 00    	jns    f0102a1e <mem_init+0x1217>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01020d2:	6a 02                	push   $0x2
f01020d4:	68 00 10 00 00       	push   $0x1000
f01020d9:	53                   	push   %ebx
f01020da:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f01020e0:	e8 5a f6 ff ff       	call   f010173f <page_insert>
f01020e5:	83 c4 10             	add    $0x10,%esp
f01020e8:	85 c0                	test   %eax,%eax
f01020ea:	0f 85 47 09 00 00    	jne    f0102a37 <mem_init+0x1230>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020f0:	83 ec 04             	sub    $0x4,%esp
f01020f3:	6a 00                	push   $0x0
f01020f5:	68 00 10 00 00       	push   $0x1000
f01020fa:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f0102100:	e8 cb f3 ff ff       	call   f01014d0 <pgdir_walk>
f0102105:	83 c4 10             	add    $0x10,%esp
f0102108:	f6 00 04             	testb  $0x4,(%eax)
f010210b:	0f 85 3f 09 00 00    	jne    f0102a50 <mem_init+0x1249>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102111:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f0102116:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102119:	ba 00 00 00 00       	mov    $0x0,%edx
f010211e:	e8 af ee ff ff       	call   f0100fd2 <check_va2pa>
f0102123:	89 c1                	mov    %eax,%ecx
f0102125:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102128:	89 d8                	mov    %ebx,%eax
f010212a:	2b 05 90 1e 29 f0    	sub    0xf0291e90,%eax
f0102130:	c1 f8 03             	sar    $0x3,%eax
f0102133:	c1 e0 0c             	shl    $0xc,%eax
f0102136:	39 c1                	cmp    %eax,%ecx
f0102138:	0f 85 2b 09 00 00    	jne    f0102a69 <mem_init+0x1262>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010213e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102143:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102146:	e8 87 ee ff ff       	call   f0100fd2 <check_va2pa>
f010214b:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010214e:	0f 85 2e 09 00 00    	jne    f0102a82 <mem_init+0x127b>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102154:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0102159:	0f 85 3c 09 00 00    	jne    f0102a9b <mem_init+0x1294>
	assert(pp2->pp_ref == 0);
f010215f:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102164:	0f 85 4a 09 00 00    	jne    f0102ab4 <mem_init+0x12ad>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010216a:	83 ec 0c             	sub    $0xc,%esp
f010216d:	6a 00                	push   $0x0
f010216f:	e8 72 f2 ff ff       	call   f01013e6 <page_alloc>
f0102174:	83 c4 10             	add    $0x10,%esp
f0102177:	85 c0                	test   %eax,%eax
f0102179:	0f 84 4e 09 00 00    	je     f0102acd <mem_init+0x12c6>
f010217f:	39 c6                	cmp    %eax,%esi
f0102181:	0f 85 46 09 00 00    	jne    f0102acd <mem_init+0x12c6>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102187:	83 ec 08             	sub    $0x8,%esp
f010218a:	6a 00                	push   $0x0
f010218c:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f0102192:	e8 4e f5 ff ff       	call   f01016e5 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102197:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f010219c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010219f:	ba 00 00 00 00       	mov    $0x0,%edx
f01021a4:	e8 29 ee ff ff       	call   f0100fd2 <check_va2pa>
f01021a9:	83 c4 10             	add    $0x10,%esp
f01021ac:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021af:	0f 85 31 09 00 00    	jne    f0102ae6 <mem_init+0x12df>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01021b5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021ba:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021bd:	e8 10 ee ff ff       	call   f0100fd2 <check_va2pa>
f01021c2:	89 da                	mov    %ebx,%edx
f01021c4:	2b 15 90 1e 29 f0    	sub    0xf0291e90,%edx
f01021ca:	c1 fa 03             	sar    $0x3,%edx
f01021cd:	c1 e2 0c             	shl    $0xc,%edx
f01021d0:	39 d0                	cmp    %edx,%eax
f01021d2:	0f 85 27 09 00 00    	jne    f0102aff <mem_init+0x12f8>
	assert(pp1->pp_ref == 1);
f01021d8:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01021dd:	0f 85 35 09 00 00    	jne    f0102b18 <mem_init+0x1311>
	assert(pp2->pp_ref == 0);
f01021e3:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01021e8:	0f 85 43 09 00 00    	jne    f0102b31 <mem_init+0x132a>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01021ee:	6a 00                	push   $0x0
f01021f0:	68 00 10 00 00       	push   $0x1000
f01021f5:	53                   	push   %ebx
f01021f6:	ff 75 d4             	pushl  -0x2c(%ebp)
f01021f9:	e8 41 f5 ff ff       	call   f010173f <page_insert>
f01021fe:	83 c4 10             	add    $0x10,%esp
f0102201:	85 c0                	test   %eax,%eax
f0102203:	0f 85 41 09 00 00    	jne    f0102b4a <mem_init+0x1343>
	assert(pp1->pp_ref);
f0102209:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010220e:	0f 84 4f 09 00 00    	je     f0102b63 <mem_init+0x135c>
	assert(pp1->pp_link == NULL);
f0102214:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102217:	0f 85 5f 09 00 00    	jne    f0102b7c <mem_init+0x1375>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010221d:	83 ec 08             	sub    $0x8,%esp
f0102220:	68 00 10 00 00       	push   $0x1000
f0102225:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f010222b:	e8 b5 f4 ff ff       	call   f01016e5 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102230:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f0102235:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102238:	ba 00 00 00 00       	mov    $0x0,%edx
f010223d:	e8 90 ed ff ff       	call   f0100fd2 <check_va2pa>
f0102242:	83 c4 10             	add    $0x10,%esp
f0102245:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102248:	0f 85 47 09 00 00    	jne    f0102b95 <mem_init+0x138e>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010224e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102253:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102256:	e8 77 ed ff ff       	call   f0100fd2 <check_va2pa>
f010225b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010225e:	0f 85 4a 09 00 00    	jne    f0102bae <mem_init+0x13a7>
	assert(pp1->pp_ref == 0);
f0102264:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102269:	0f 85 58 09 00 00    	jne    f0102bc7 <mem_init+0x13c0>
	assert(pp2->pp_ref == 0);
f010226f:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102274:	0f 85 66 09 00 00    	jne    f0102be0 <mem_init+0x13d9>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010227a:	83 ec 0c             	sub    $0xc,%esp
f010227d:	6a 00                	push   $0x0
f010227f:	e8 62 f1 ff ff       	call   f01013e6 <page_alloc>
f0102284:	83 c4 10             	add    $0x10,%esp
f0102287:	85 c0                	test   %eax,%eax
f0102289:	0f 84 6a 09 00 00    	je     f0102bf9 <mem_init+0x13f2>
f010228f:	39 c3                	cmp    %eax,%ebx
f0102291:	0f 85 62 09 00 00    	jne    f0102bf9 <mem_init+0x13f2>

	// should be no free memory
	assert(!page_alloc(0));
f0102297:	83 ec 0c             	sub    $0xc,%esp
f010229a:	6a 00                	push   $0x0
f010229c:	e8 45 f1 ff ff       	call   f01013e6 <page_alloc>
f01022a1:	83 c4 10             	add    $0x10,%esp
f01022a4:	85 c0                	test   %eax,%eax
f01022a6:	0f 85 66 09 00 00    	jne    f0102c12 <mem_init+0x140b>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022ac:	8b 0d 8c 1e 29 f0    	mov    0xf0291e8c,%ecx
f01022b2:	8b 11                	mov    (%ecx),%edx
f01022b4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01022ba:	89 f8                	mov    %edi,%eax
f01022bc:	2b 05 90 1e 29 f0    	sub    0xf0291e90,%eax
f01022c2:	c1 f8 03             	sar    $0x3,%eax
f01022c5:	c1 e0 0c             	shl    $0xc,%eax
f01022c8:	39 c2                	cmp    %eax,%edx
f01022ca:	0f 85 5b 09 00 00    	jne    f0102c2b <mem_init+0x1424>
	kern_pgdir[0] = 0;
f01022d0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01022d6:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01022db:	0f 85 63 09 00 00    	jne    f0102c44 <mem_init+0x143d>
	pp0->pp_ref = 0;
f01022e1:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01022e7:	83 ec 0c             	sub    $0xc,%esp
f01022ea:	57                   	push   %edi
f01022eb:	e8 68 f1 ff ff       	call   f0101458 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01022f0:	83 c4 0c             	add    $0xc,%esp
f01022f3:	6a 01                	push   $0x1
f01022f5:	68 00 10 40 00       	push   $0x401000
f01022fa:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f0102300:	e8 cb f1 ff ff       	call   f01014d0 <pgdir_walk>
f0102305:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102308:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010230b:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f0102310:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102313:	8b 50 04             	mov    0x4(%eax),%edx
f0102316:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f010231c:	a1 88 1e 29 f0       	mov    0xf0291e88,%eax
f0102321:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102324:	89 d1                	mov    %edx,%ecx
f0102326:	c1 e9 0c             	shr    $0xc,%ecx
f0102329:	83 c4 10             	add    $0x10,%esp
f010232c:	39 c1                	cmp    %eax,%ecx
f010232e:	0f 83 29 09 00 00    	jae    f0102c5d <mem_init+0x1456>
	assert(ptep == ptep1 + PTX(va));
f0102334:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f010233a:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f010233d:	0f 85 2f 09 00 00    	jne    f0102c72 <mem_init+0x146b>
	kern_pgdir[PDX(va)] = 0;
f0102343:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102346:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f010234d:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
	return (pp - pages) << PGSHIFT;
f0102353:	89 f8                	mov    %edi,%eax
f0102355:	2b 05 90 1e 29 f0    	sub    0xf0291e90,%eax
f010235b:	c1 f8 03             	sar    $0x3,%eax
f010235e:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102361:	89 c2                	mov    %eax,%edx
f0102363:	c1 ea 0c             	shr    $0xc,%edx
f0102366:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f0102369:	0f 86 1c 09 00 00    	jbe    f0102c8b <mem_init+0x1484>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010236f:	83 ec 04             	sub    $0x4,%esp
f0102372:	68 00 10 00 00       	push   $0x1000
f0102377:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f010237c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102381:	50                   	push   %eax
f0102382:	e8 d5 33 00 00       	call   f010575c <memset>
	page_free(pp0);
f0102387:	89 3c 24             	mov    %edi,(%esp)
f010238a:	e8 c9 f0 ff ff       	call   f0101458 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010238f:	83 c4 0c             	add    $0xc,%esp
f0102392:	6a 01                	push   $0x1
f0102394:	6a 00                	push   $0x0
f0102396:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f010239c:	e8 2f f1 ff ff       	call   f01014d0 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f01023a1:	89 fa                	mov    %edi,%edx
f01023a3:	2b 15 90 1e 29 f0    	sub    0xf0291e90,%edx
f01023a9:	c1 fa 03             	sar    $0x3,%edx
f01023ac:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01023af:	89 d0                	mov    %edx,%eax
f01023b1:	c1 e8 0c             	shr    $0xc,%eax
f01023b4:	83 c4 10             	add    $0x10,%esp
f01023b7:	3b 05 88 1e 29 f0    	cmp    0xf0291e88,%eax
f01023bd:	0f 83 da 08 00 00    	jae    f0102c9d <mem_init+0x1496>
	return (void *)(pa + KERNBASE);
f01023c3:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01023c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01023cc:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01023d2:	f6 00 01             	testb  $0x1,(%eax)
f01023d5:	0f 85 d4 08 00 00    	jne    f0102caf <mem_init+0x14a8>
f01023db:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f01023de:	39 d0                	cmp    %edx,%eax
f01023e0:	75 f0                	jne    f01023d2 <mem_init+0xbcb>
	kern_pgdir[0] = 0;
f01023e2:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f01023e7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01023ed:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f01023f3:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01023f6:	a3 40 12 29 f0       	mov    %eax,0xf0291240

	// free the pages we took
	page_free(pp0);
f01023fb:	83 ec 0c             	sub    $0xc,%esp
f01023fe:	57                   	push   %edi
f01023ff:	e8 54 f0 ff ff       	call   f0101458 <page_free>
	page_free(pp1);
f0102404:	89 1c 24             	mov    %ebx,(%esp)
f0102407:	e8 4c f0 ff ff       	call   f0101458 <page_free>
	page_free(pp2);
f010240c:	89 34 24             	mov    %esi,(%esp)
f010240f:	e8 44 f0 ff ff       	call   f0101458 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102414:	83 c4 08             	add    $0x8,%esp
f0102417:	68 01 10 00 00       	push   $0x1001
f010241c:	6a 00                	push   $0x0
f010241e:	e8 83 f3 ff ff       	call   f01017a6 <mmio_map_region>
f0102423:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102425:	83 c4 08             	add    $0x8,%esp
f0102428:	68 00 10 00 00       	push   $0x1000
f010242d:	6a 00                	push   $0x0
f010242f:	e8 72 f3 ff ff       	call   f01017a6 <mmio_map_region>
f0102434:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102436:	83 c4 10             	add    $0x10,%esp
f0102439:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010243f:	0f 86 83 08 00 00    	jbe    f0102cc8 <mem_init+0x14c1>
f0102445:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f010244b:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102450:	0f 87 72 08 00 00    	ja     f0102cc8 <mem_init+0x14c1>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102456:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010245c:	0f 86 7f 08 00 00    	jbe    f0102ce1 <mem_init+0x14da>
f0102462:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102468:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f010246e:	0f 87 6d 08 00 00    	ja     f0102ce1 <mem_init+0x14da>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102474:	89 da                	mov    %ebx,%edx
f0102476:	09 f2                	or     %esi,%edx
f0102478:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f010247e:	0f 85 76 08 00 00    	jne    f0102cfa <mem_init+0x14f3>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102484:	39 c6                	cmp    %eax,%esi
f0102486:	0f 82 87 08 00 00    	jb     f0102d13 <mem_init+0x150c>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f010248c:	8b 3d 8c 1e 29 f0    	mov    0xf0291e8c,%edi
f0102492:	89 da                	mov    %ebx,%edx
f0102494:	89 f8                	mov    %edi,%eax
f0102496:	e8 37 eb ff ff       	call   f0100fd2 <check_va2pa>
f010249b:	85 c0                	test   %eax,%eax
f010249d:	0f 85 89 08 00 00    	jne    f0102d2c <mem_init+0x1525>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01024a3:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01024a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01024ac:	89 c2                	mov    %eax,%edx
f01024ae:	89 f8                	mov    %edi,%eax
f01024b0:	e8 1d eb ff ff       	call   f0100fd2 <check_va2pa>
f01024b5:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01024ba:	0f 85 85 08 00 00    	jne    f0102d45 <mem_init+0x153e>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01024c0:	89 f2                	mov    %esi,%edx
f01024c2:	89 f8                	mov    %edi,%eax
f01024c4:	e8 09 eb ff ff       	call   f0100fd2 <check_va2pa>
f01024c9:	85 c0                	test   %eax,%eax
f01024cb:	0f 85 8d 08 00 00    	jne    f0102d5e <mem_init+0x1557>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01024d1:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01024d7:	89 f8                	mov    %edi,%eax
f01024d9:	e8 f4 ea ff ff       	call   f0100fd2 <check_va2pa>
f01024de:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024e1:	0f 85 90 08 00 00    	jne    f0102d77 <mem_init+0x1570>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01024e7:	83 ec 04             	sub    $0x4,%esp
f01024ea:	6a 00                	push   $0x0
f01024ec:	53                   	push   %ebx
f01024ed:	57                   	push   %edi
f01024ee:	e8 dd ef ff ff       	call   f01014d0 <pgdir_walk>
f01024f3:	83 c4 10             	add    $0x10,%esp
f01024f6:	f6 00 1a             	testb  $0x1a,(%eax)
f01024f9:	0f 84 91 08 00 00    	je     f0102d90 <mem_init+0x1589>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01024ff:	83 ec 04             	sub    $0x4,%esp
f0102502:	6a 00                	push   $0x0
f0102504:	53                   	push   %ebx
f0102505:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f010250b:	e8 c0 ef ff ff       	call   f01014d0 <pgdir_walk>
f0102510:	83 c4 10             	add    $0x10,%esp
f0102513:	f6 00 04             	testb  $0x4,(%eax)
f0102516:	0f 85 8d 08 00 00    	jne    f0102da9 <mem_init+0x15a2>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f010251c:	83 ec 04             	sub    $0x4,%esp
f010251f:	6a 00                	push   $0x0
f0102521:	53                   	push   %ebx
f0102522:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f0102528:	e8 a3 ef ff ff       	call   f01014d0 <pgdir_walk>
f010252d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102533:	83 c4 0c             	add    $0xc,%esp
f0102536:	6a 00                	push   $0x0
f0102538:	ff 75 d4             	pushl  -0x2c(%ebp)
f010253b:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f0102541:	e8 8a ef ff ff       	call   f01014d0 <pgdir_walk>
f0102546:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010254c:	83 c4 0c             	add    $0xc,%esp
f010254f:	6a 00                	push   $0x0
f0102551:	56                   	push   %esi
f0102552:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f0102558:	e8 73 ef ff ff       	call   f01014d0 <pgdir_walk>
f010255d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102563:	c7 04 24 a2 79 10 f0 	movl   $0xf01079a2,(%esp)
f010256a:	e8 24 1a 00 00       	call   f0103f93 <cprintf>
	pginfo_sz = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010256f:	a1 88 1e 29 f0       	mov    0xf0291e88,%eax
f0102574:	8d 0c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ecx
f010257b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_region(kern_pgdir, UPAGES, pginfo_sz, PADDR(pages), PTE_U | PTE_P);
f0102581:	a1 90 1e 29 f0       	mov    0xf0291e90,%eax
	if ((uint32_t)kva < KERNBASE)
f0102586:	83 c4 10             	add    $0x10,%esp
f0102589:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010258e:	0f 86 2e 08 00 00    	jbe    f0102dc2 <mem_init+0x15bb>
f0102594:	83 ec 08             	sub    $0x8,%esp
f0102597:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102599:	05 00 00 00 10       	add    $0x10000000,%eax
f010259e:	50                   	push   %eax
f010259f:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01025a4:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f01025a9:	e8 39 f0 ff ff       	call   f01015e7 <boot_map_region>
	env_sz = ROUNDUP(npages*sizeof(struct Env), PGSIZE);
f01025ae:	8b 15 88 1e 29 f0    	mov    0xf0291e88,%edx
f01025b4:	89 d0                	mov    %edx,%eax
f01025b6:	c1 e0 05             	shl    $0x5,%eax
f01025b9:	29 d0                	sub    %edx,%eax
f01025bb:	8d 0c 85 ff 0f 00 00 	lea    0xfff(,%eax,4),%ecx
f01025c2:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_region(kern_pgdir, UENVS, env_sz, PADDR(envs), PTE_U | PTE_P);
f01025c8:	a1 48 12 29 f0       	mov    0xf0291248,%eax
	if ((uint32_t)kva < KERNBASE)
f01025cd:	83 c4 10             	add    $0x10,%esp
f01025d0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025d5:	0f 86 fc 07 00 00    	jbe    f0102dd7 <mem_init+0x15d0>
f01025db:	83 ec 08             	sub    $0x8,%esp
f01025de:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01025e0:	05 00 00 00 10       	add    $0x10000000,%eax
f01025e5:	50                   	push   %eax
f01025e6:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01025eb:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f01025f0:	e8 f2 ef ff ff       	call   f01015e7 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01025f5:	83 c4 10             	add    $0x10,%esp
f01025f8:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f01025fd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102602:	0f 86 e4 07 00 00    	jbe    f0102dec <mem_init+0x15e5>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, 
f0102608:	83 ec 08             	sub    $0x8,%esp
f010260b:	6a 03                	push   $0x3
f010260d:	68 00 80 11 00       	push   $0x118000
f0102612:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102617:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010261c:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f0102621:	e8 c1 ef ff ff       	call   f01015e7 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 1 << 28, // 2^32 - 0xf0000000
f0102626:	83 c4 08             	add    $0x8,%esp
f0102629:	6a 03                	push   $0x3
f010262b:	6a 00                	push   $0x0
f010262d:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102632:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102637:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f010263c:	e8 a6 ef ff ff       	call   f01015e7 <boot_map_region>
f0102641:	c7 45 c8 00 30 29 f0 	movl   $0xf0293000,-0x38(%ebp)
f0102648:	be 00 30 2d f0       	mov    $0xf02d3000,%esi
f010264d:	83 c4 10             	add    $0x10,%esp
f0102650:	bf 00 30 29 f0       	mov    $0xf0293000,%edi
f0102655:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
f010265a:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0102660:	0f 86 9b 07 00 00    	jbe    f0102e01 <mem_init+0x15fa>
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, 
f0102666:	83 ec 08             	sub    $0x8,%esp
f0102669:	6a 02                	push   $0x2
f010266b:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0102671:	50                   	push   %eax
f0102672:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102677:	89 da                	mov    %ebx,%edx
f0102679:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
f010267e:	e8 64 ef ff ff       	call   f01015e7 <boot_map_region>
f0102683:	81 c7 00 80 00 00    	add    $0x8000,%edi
f0102689:	81 eb 00 00 01 00    	sub    $0x10000,%ebx
	for (size_t i = 0; i < NCPU; i++) { // `ncpu` is not set yet, we just use NCPU = 8.
f010268f:	83 c4 10             	add    $0x10,%esp
f0102692:	39 f7                	cmp    %esi,%edi
f0102694:	75 c4                	jne    f010265a <mem_init+0xe53>
f0102696:	89 7d c4             	mov    %edi,-0x3c(%ebp)
	pgdir = kern_pgdir;
f0102699:	8b 3d 8c 1e 29 f0    	mov    0xf0291e8c,%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010269f:	a1 88 1e 29 f0       	mov    0xf0291e88,%eax
f01026a4:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01026a7:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01026ae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01026b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01026b6:	a1 90 1e 29 f0       	mov    0xf0291e90,%eax
f01026bb:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01026be:	89 45 d0             	mov    %eax,-0x30(%ebp)
	return (physaddr_t)kva - KERNBASE;
f01026c1:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
	for (i = 0; i < n; i += PGSIZE) 
f01026c7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01026cc:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01026cf:	0f 86 71 07 00 00    	jbe    f0102e46 <mem_init+0x163f>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01026d5:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01026db:	89 f8                	mov    %edi,%eax
f01026dd:	e8 f0 e8 ff ff       	call   f0100fd2 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01026e2:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01026e9:	0f 86 27 07 00 00    	jbe    f0102e16 <mem_init+0x160f>
f01026ef:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f01026f2:	39 d0                	cmp    %edx,%eax
f01026f4:	0f 85 33 07 00 00    	jne    f0102e2d <mem_init+0x1626>
	for (i = 0; i < n; i += PGSIZE) 
f01026fa:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102700:	eb ca                	jmp    f01026cc <mem_init+0xec5>
	assert(nfree == 0);
f0102702:	68 b9 78 10 f0       	push   $0xf01078b9
f0102707:	68 c3 76 10 f0       	push   $0xf01076c3
f010270c:	68 18 03 00 00       	push   $0x318
f0102711:	68 9d 76 10 f0       	push   $0xf010769d
f0102716:	e8 79 d9 ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f010271b:	68 c7 77 10 f0       	push   $0xf01077c7
f0102720:	68 c3 76 10 f0       	push   $0xf01076c3
f0102725:	68 7e 03 00 00       	push   $0x37e
f010272a:	68 9d 76 10 f0       	push   $0xf010769d
f010272f:	e8 60 d9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0102734:	68 dd 77 10 f0       	push   $0xf01077dd
f0102739:	68 c3 76 10 f0       	push   $0xf01076c3
f010273e:	68 7f 03 00 00       	push   $0x37f
f0102743:	68 9d 76 10 f0       	push   $0xf010769d
f0102748:	e8 47 d9 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f010274d:	68 f3 77 10 f0       	push   $0xf01077f3
f0102752:	68 c3 76 10 f0       	push   $0xf01076c3
f0102757:	68 80 03 00 00       	push   $0x380
f010275c:	68 9d 76 10 f0       	push   $0xf010769d
f0102761:	e8 2e d9 ff ff       	call   f0100094 <_panic>
	assert(pp1 && pp1 != pp0);
f0102766:	68 09 78 10 f0       	push   $0xf0107809
f010276b:	68 c3 76 10 f0       	push   $0xf01076c3
f0102770:	68 83 03 00 00       	push   $0x383
f0102775:	68 9d 76 10 f0       	push   $0xf010769d
f010277a:	e8 15 d9 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010277f:	68 c0 6e 10 f0       	push   $0xf0106ec0
f0102784:	68 c3 76 10 f0       	push   $0xf01076c3
f0102789:	68 84 03 00 00       	push   $0x384
f010278e:	68 9d 76 10 f0       	push   $0xf010769d
f0102793:	e8 fc d8 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0102798:	68 72 78 10 f0       	push   $0xf0107872
f010279d:	68 c3 76 10 f0       	push   $0xf01076c3
f01027a2:	68 8b 03 00 00       	push   $0x38b
f01027a7:	68 9d 76 10 f0       	push   $0xf010769d
f01027ac:	e8 e3 d8 ff ff       	call   f0100094 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01027b1:	68 00 6f 10 f0       	push   $0xf0106f00
f01027b6:	68 c3 76 10 f0       	push   $0xf01076c3
f01027bb:	68 8e 03 00 00       	push   $0x38e
f01027c0:	68 9d 76 10 f0       	push   $0xf010769d
f01027c5:	e8 ca d8 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01027ca:	68 38 6f 10 f0       	push   $0xf0106f38
f01027cf:	68 c3 76 10 f0       	push   $0xf01076c3
f01027d4:	68 91 03 00 00       	push   $0x391
f01027d9:	68 9d 76 10 f0       	push   $0xf010769d
f01027de:	e8 b1 d8 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01027e3:	68 68 6f 10 f0       	push   $0xf0106f68
f01027e8:	68 c3 76 10 f0       	push   $0xf01076c3
f01027ed:	68 95 03 00 00       	push   $0x395
f01027f2:	68 9d 76 10 f0       	push   $0xf010769d
f01027f7:	e8 98 d8 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01027fc:	68 98 6f 10 f0       	push   $0xf0106f98
f0102801:	68 c3 76 10 f0       	push   $0xf01076c3
f0102806:	68 96 03 00 00       	push   $0x396
f010280b:	68 9d 76 10 f0       	push   $0xf010769d
f0102810:	e8 7f d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102815:	68 c0 6f 10 f0       	push   $0xf0106fc0
f010281a:	68 c3 76 10 f0       	push   $0xf01076c3
f010281f:	68 97 03 00 00       	push   $0x397
f0102824:	68 9d 76 10 f0       	push   $0xf010769d
f0102829:	e8 66 d8 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f010282e:	68 c4 78 10 f0       	push   $0xf01078c4
f0102833:	68 c3 76 10 f0       	push   $0xf01076c3
f0102838:	68 98 03 00 00       	push   $0x398
f010283d:	68 9d 76 10 f0       	push   $0xf010769d
f0102842:	e8 4d d8 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0102847:	68 d5 78 10 f0       	push   $0xf01078d5
f010284c:	68 c3 76 10 f0       	push   $0xf01076c3
f0102851:	68 99 03 00 00       	push   $0x399
f0102856:	68 9d 76 10 f0       	push   $0xf010769d
f010285b:	e8 34 d8 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102860:	68 f0 6f 10 f0       	push   $0xf0106ff0
f0102865:	68 c3 76 10 f0       	push   $0xf01076c3
f010286a:	68 9c 03 00 00       	push   $0x39c
f010286f:	68 9d 76 10 f0       	push   $0xf010769d
f0102874:	e8 1b d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102879:	68 2c 70 10 f0       	push   $0xf010702c
f010287e:	68 c3 76 10 f0       	push   $0xf01076c3
f0102883:	68 9d 03 00 00       	push   $0x39d
f0102888:	68 9d 76 10 f0       	push   $0xf010769d
f010288d:	e8 02 d8 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102892:	68 e6 78 10 f0       	push   $0xf01078e6
f0102897:	68 c3 76 10 f0       	push   $0xf01076c3
f010289c:	68 9e 03 00 00       	push   $0x39e
f01028a1:	68 9d 76 10 f0       	push   $0xf010769d
f01028a6:	e8 e9 d7 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01028ab:	68 72 78 10 f0       	push   $0xf0107872
f01028b0:	68 c3 76 10 f0       	push   $0xf01076c3
f01028b5:	68 a1 03 00 00       	push   $0x3a1
f01028ba:	68 9d 76 10 f0       	push   $0xf010769d
f01028bf:	e8 d0 d7 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01028c4:	68 f0 6f 10 f0       	push   $0xf0106ff0
f01028c9:	68 c3 76 10 f0       	push   $0xf01076c3
f01028ce:	68 a4 03 00 00       	push   $0x3a4
f01028d3:	68 9d 76 10 f0       	push   $0xf010769d
f01028d8:	e8 b7 d7 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01028dd:	68 2c 70 10 f0       	push   $0xf010702c
f01028e2:	68 c3 76 10 f0       	push   $0xf01076c3
f01028e7:	68 a5 03 00 00       	push   $0x3a5
f01028ec:	68 9d 76 10 f0       	push   $0xf010769d
f01028f1:	e8 9e d7 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f01028f6:	68 e6 78 10 f0       	push   $0xf01078e6
f01028fb:	68 c3 76 10 f0       	push   $0xf01076c3
f0102900:	68 a6 03 00 00       	push   $0x3a6
f0102905:	68 9d 76 10 f0       	push   $0xf010769d
f010290a:	e8 85 d7 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f010290f:	68 72 78 10 f0       	push   $0xf0107872
f0102914:	68 c3 76 10 f0       	push   $0xf01076c3
f0102919:	68 aa 03 00 00       	push   $0x3aa
f010291e:	68 9d 76 10 f0       	push   $0xf010769d
f0102923:	e8 6c d7 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102928:	50                   	push   %eax
f0102929:	68 c8 65 10 f0       	push   $0xf01065c8
f010292e:	68 ad 03 00 00       	push   $0x3ad
f0102933:	68 9d 76 10 f0       	push   $0xf010769d
f0102938:	e8 57 d7 ff ff       	call   f0100094 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010293d:	68 5c 70 10 f0       	push   $0xf010705c
f0102942:	68 c3 76 10 f0       	push   $0xf01076c3
f0102947:	68 ae 03 00 00       	push   $0x3ae
f010294c:	68 9d 76 10 f0       	push   $0xf010769d
f0102951:	e8 3e d7 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102956:	68 9c 70 10 f0       	push   $0xf010709c
f010295b:	68 c3 76 10 f0       	push   $0xf01076c3
f0102960:	68 b1 03 00 00       	push   $0x3b1
f0102965:	68 9d 76 10 f0       	push   $0xf010769d
f010296a:	e8 25 d7 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010296f:	68 2c 70 10 f0       	push   $0xf010702c
f0102974:	68 c3 76 10 f0       	push   $0xf01076c3
f0102979:	68 b2 03 00 00       	push   $0x3b2
f010297e:	68 9d 76 10 f0       	push   $0xf010769d
f0102983:	e8 0c d7 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102988:	68 e6 78 10 f0       	push   $0xf01078e6
f010298d:	68 c3 76 10 f0       	push   $0xf01076c3
f0102992:	68 b3 03 00 00       	push   $0x3b3
f0102997:	68 9d 76 10 f0       	push   $0xf010769d
f010299c:	e8 f3 d6 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01029a1:	68 dc 70 10 f0       	push   $0xf01070dc
f01029a6:	68 c3 76 10 f0       	push   $0xf01076c3
f01029ab:	68 b4 03 00 00       	push   $0x3b4
f01029b0:	68 9d 76 10 f0       	push   $0xf010769d
f01029b5:	e8 da d6 ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01029ba:	68 f7 78 10 f0       	push   $0xf01078f7
f01029bf:	68 c3 76 10 f0       	push   $0xf01076c3
f01029c4:	68 b5 03 00 00       	push   $0x3b5
f01029c9:	68 9d 76 10 f0       	push   $0xf010769d
f01029ce:	e8 c1 d6 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01029d3:	68 f0 6f 10 f0       	push   $0xf0106ff0
f01029d8:	68 c3 76 10 f0       	push   $0xf01076c3
f01029dd:	68 b8 03 00 00       	push   $0x3b8
f01029e2:	68 9d 76 10 f0       	push   $0xf010769d
f01029e7:	e8 a8 d6 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01029ec:	68 10 71 10 f0       	push   $0xf0107110
f01029f1:	68 c3 76 10 f0       	push   $0xf01076c3
f01029f6:	68 b9 03 00 00       	push   $0x3b9
f01029fb:	68 9d 76 10 f0       	push   $0xf010769d
f0102a00:	e8 8f d6 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102a05:	68 44 71 10 f0       	push   $0xf0107144
f0102a0a:	68 c3 76 10 f0       	push   $0xf01076c3
f0102a0f:	68 ba 03 00 00       	push   $0x3ba
f0102a14:	68 9d 76 10 f0       	push   $0xf010769d
f0102a19:	e8 76 d6 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102a1e:	68 7c 71 10 f0       	push   $0xf010717c
f0102a23:	68 c3 76 10 f0       	push   $0xf01076c3
f0102a28:	68 bd 03 00 00       	push   $0x3bd
f0102a2d:	68 9d 76 10 f0       	push   $0xf010769d
f0102a32:	e8 5d d6 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102a37:	68 b4 71 10 f0       	push   $0xf01071b4
f0102a3c:	68 c3 76 10 f0       	push   $0xf01076c3
f0102a41:	68 c0 03 00 00       	push   $0x3c0
f0102a46:	68 9d 76 10 f0       	push   $0xf010769d
f0102a4b:	e8 44 d6 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102a50:	68 44 71 10 f0       	push   $0xf0107144
f0102a55:	68 c3 76 10 f0       	push   $0xf01076c3
f0102a5a:	68 c1 03 00 00       	push   $0x3c1
f0102a5f:	68 9d 76 10 f0       	push   $0xf010769d
f0102a64:	e8 2b d6 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102a69:	68 f0 71 10 f0       	push   $0xf01071f0
f0102a6e:	68 c3 76 10 f0       	push   $0xf01076c3
f0102a73:	68 c4 03 00 00       	push   $0x3c4
f0102a78:	68 9d 76 10 f0       	push   $0xf010769d
f0102a7d:	e8 12 d6 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102a82:	68 1c 72 10 f0       	push   $0xf010721c
f0102a87:	68 c3 76 10 f0       	push   $0xf01076c3
f0102a8c:	68 c5 03 00 00       	push   $0x3c5
f0102a91:	68 9d 76 10 f0       	push   $0xf010769d
f0102a96:	e8 f9 d5 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 2);
f0102a9b:	68 0d 79 10 f0       	push   $0xf010790d
f0102aa0:	68 c3 76 10 f0       	push   $0xf01076c3
f0102aa5:	68 c7 03 00 00       	push   $0x3c7
f0102aaa:	68 9d 76 10 f0       	push   $0xf010769d
f0102aaf:	e8 e0 d5 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102ab4:	68 1e 79 10 f0       	push   $0xf010791e
f0102ab9:	68 c3 76 10 f0       	push   $0xf01076c3
f0102abe:	68 c8 03 00 00       	push   $0x3c8
f0102ac3:	68 9d 76 10 f0       	push   $0xf010769d
f0102ac8:	e8 c7 d5 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102acd:	68 4c 72 10 f0       	push   $0xf010724c
f0102ad2:	68 c3 76 10 f0       	push   $0xf01076c3
f0102ad7:	68 cb 03 00 00       	push   $0x3cb
f0102adc:	68 9d 76 10 f0       	push   $0xf010769d
f0102ae1:	e8 ae d5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102ae6:	68 70 72 10 f0       	push   $0xf0107270
f0102aeb:	68 c3 76 10 f0       	push   $0xf01076c3
f0102af0:	68 cf 03 00 00       	push   $0x3cf
f0102af5:	68 9d 76 10 f0       	push   $0xf010769d
f0102afa:	e8 95 d5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102aff:	68 1c 72 10 f0       	push   $0xf010721c
f0102b04:	68 c3 76 10 f0       	push   $0xf01076c3
f0102b09:	68 d0 03 00 00       	push   $0x3d0
f0102b0e:	68 9d 76 10 f0       	push   $0xf010769d
f0102b13:	e8 7c d5 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102b18:	68 c4 78 10 f0       	push   $0xf01078c4
f0102b1d:	68 c3 76 10 f0       	push   $0xf01076c3
f0102b22:	68 d1 03 00 00       	push   $0x3d1
f0102b27:	68 9d 76 10 f0       	push   $0xf010769d
f0102b2c:	e8 63 d5 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102b31:	68 1e 79 10 f0       	push   $0xf010791e
f0102b36:	68 c3 76 10 f0       	push   $0xf01076c3
f0102b3b:	68 d2 03 00 00       	push   $0x3d2
f0102b40:	68 9d 76 10 f0       	push   $0xf010769d
f0102b45:	e8 4a d5 ff ff       	call   f0100094 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102b4a:	68 94 72 10 f0       	push   $0xf0107294
f0102b4f:	68 c3 76 10 f0       	push   $0xf01076c3
f0102b54:	68 d5 03 00 00       	push   $0x3d5
f0102b59:	68 9d 76 10 f0       	push   $0xf010769d
f0102b5e:	e8 31 d5 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f0102b63:	68 2f 79 10 f0       	push   $0xf010792f
f0102b68:	68 c3 76 10 f0       	push   $0xf01076c3
f0102b6d:	68 d6 03 00 00       	push   $0x3d6
f0102b72:	68 9d 76 10 f0       	push   $0xf010769d
f0102b77:	e8 18 d5 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f0102b7c:	68 3b 79 10 f0       	push   $0xf010793b
f0102b81:	68 c3 76 10 f0       	push   $0xf01076c3
f0102b86:	68 d7 03 00 00       	push   $0x3d7
f0102b8b:	68 9d 76 10 f0       	push   $0xf010769d
f0102b90:	e8 ff d4 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102b95:	68 70 72 10 f0       	push   $0xf0107270
f0102b9a:	68 c3 76 10 f0       	push   $0xf01076c3
f0102b9f:	68 db 03 00 00       	push   $0x3db
f0102ba4:	68 9d 76 10 f0       	push   $0xf010769d
f0102ba9:	e8 e6 d4 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102bae:	68 cc 72 10 f0       	push   $0xf01072cc
f0102bb3:	68 c3 76 10 f0       	push   $0xf01076c3
f0102bb8:	68 dc 03 00 00       	push   $0x3dc
f0102bbd:	68 9d 76 10 f0       	push   $0xf010769d
f0102bc2:	e8 cd d4 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102bc7:	68 50 79 10 f0       	push   $0xf0107950
f0102bcc:	68 c3 76 10 f0       	push   $0xf01076c3
f0102bd1:	68 dd 03 00 00       	push   $0x3dd
f0102bd6:	68 9d 76 10 f0       	push   $0xf010769d
f0102bdb:	e8 b4 d4 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102be0:	68 1e 79 10 f0       	push   $0xf010791e
f0102be5:	68 c3 76 10 f0       	push   $0xf01076c3
f0102bea:	68 de 03 00 00       	push   $0x3de
f0102bef:	68 9d 76 10 f0       	push   $0xf010769d
f0102bf4:	e8 9b d4 ff ff       	call   f0100094 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102bf9:	68 f4 72 10 f0       	push   $0xf01072f4
f0102bfe:	68 c3 76 10 f0       	push   $0xf01076c3
f0102c03:	68 e1 03 00 00       	push   $0x3e1
f0102c08:	68 9d 76 10 f0       	push   $0xf010769d
f0102c0d:	e8 82 d4 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0102c12:	68 72 78 10 f0       	push   $0xf0107872
f0102c17:	68 c3 76 10 f0       	push   $0xf01076c3
f0102c1c:	68 e4 03 00 00       	push   $0x3e4
f0102c21:	68 9d 76 10 f0       	push   $0xf010769d
f0102c26:	e8 69 d4 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c2b:	68 98 6f 10 f0       	push   $0xf0106f98
f0102c30:	68 c3 76 10 f0       	push   $0xf01076c3
f0102c35:	68 e7 03 00 00       	push   $0x3e7
f0102c3a:	68 9d 76 10 f0       	push   $0xf010769d
f0102c3f:	e8 50 d4 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0102c44:	68 d5 78 10 f0       	push   $0xf01078d5
f0102c49:	68 c3 76 10 f0       	push   $0xf01076c3
f0102c4e:	68 e9 03 00 00       	push   $0x3e9
f0102c53:	68 9d 76 10 f0       	push   $0xf010769d
f0102c58:	e8 37 d4 ff ff       	call   f0100094 <_panic>
f0102c5d:	52                   	push   %edx
f0102c5e:	68 c8 65 10 f0       	push   $0xf01065c8
f0102c63:	68 f0 03 00 00       	push   $0x3f0
f0102c68:	68 9d 76 10 f0       	push   $0xf010769d
f0102c6d:	e8 22 d4 ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102c72:	68 61 79 10 f0       	push   $0xf0107961
f0102c77:	68 c3 76 10 f0       	push   $0xf01076c3
f0102c7c:	68 f1 03 00 00       	push   $0x3f1
f0102c81:	68 9d 76 10 f0       	push   $0xf010769d
f0102c86:	e8 09 d4 ff ff       	call   f0100094 <_panic>
f0102c8b:	50                   	push   %eax
f0102c8c:	68 c8 65 10 f0       	push   $0xf01065c8
f0102c91:	6a 58                	push   $0x58
f0102c93:	68 a9 76 10 f0       	push   $0xf01076a9
f0102c98:	e8 f7 d3 ff ff       	call   f0100094 <_panic>
f0102c9d:	52                   	push   %edx
f0102c9e:	68 c8 65 10 f0       	push   $0xf01065c8
f0102ca3:	6a 58                	push   $0x58
f0102ca5:	68 a9 76 10 f0       	push   $0xf01076a9
f0102caa:	e8 e5 d3 ff ff       	call   f0100094 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102caf:	68 79 79 10 f0       	push   $0xf0107979
f0102cb4:	68 c3 76 10 f0       	push   $0xf01076c3
f0102cb9:	68 fb 03 00 00       	push   $0x3fb
f0102cbe:	68 9d 76 10 f0       	push   $0xf010769d
f0102cc3:	e8 cc d3 ff ff       	call   f0100094 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102cc8:	68 18 73 10 f0       	push   $0xf0107318
f0102ccd:	68 c3 76 10 f0       	push   $0xf01076c3
f0102cd2:	68 0b 04 00 00       	push   $0x40b
f0102cd7:	68 9d 76 10 f0       	push   $0xf010769d
f0102cdc:	e8 b3 d3 ff ff       	call   f0100094 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102ce1:	68 40 73 10 f0       	push   $0xf0107340
f0102ce6:	68 c3 76 10 f0       	push   $0xf01076c3
f0102ceb:	68 0c 04 00 00       	push   $0x40c
f0102cf0:	68 9d 76 10 f0       	push   $0xf010769d
f0102cf5:	e8 9a d3 ff ff       	call   f0100094 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102cfa:	68 68 73 10 f0       	push   $0xf0107368
f0102cff:	68 c3 76 10 f0       	push   $0xf01076c3
f0102d04:	68 0e 04 00 00       	push   $0x40e
f0102d09:	68 9d 76 10 f0       	push   $0xf010769d
f0102d0e:	e8 81 d3 ff ff       	call   f0100094 <_panic>
	assert(mm1 + 8096 <= mm2);
f0102d13:	68 90 79 10 f0       	push   $0xf0107990
f0102d18:	68 c3 76 10 f0       	push   $0xf01076c3
f0102d1d:	68 10 04 00 00       	push   $0x410
f0102d22:	68 9d 76 10 f0       	push   $0xf010769d
f0102d27:	e8 68 d3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102d2c:	68 90 73 10 f0       	push   $0xf0107390
f0102d31:	68 c3 76 10 f0       	push   $0xf01076c3
f0102d36:	68 12 04 00 00       	push   $0x412
f0102d3b:	68 9d 76 10 f0       	push   $0xf010769d
f0102d40:	e8 4f d3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102d45:	68 b4 73 10 f0       	push   $0xf01073b4
f0102d4a:	68 c3 76 10 f0       	push   $0xf01076c3
f0102d4f:	68 13 04 00 00       	push   $0x413
f0102d54:	68 9d 76 10 f0       	push   $0xf010769d
f0102d59:	e8 36 d3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102d5e:	68 e4 73 10 f0       	push   $0xf01073e4
f0102d63:	68 c3 76 10 f0       	push   $0xf01076c3
f0102d68:	68 14 04 00 00       	push   $0x414
f0102d6d:	68 9d 76 10 f0       	push   $0xf010769d
f0102d72:	e8 1d d3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102d77:	68 08 74 10 f0       	push   $0xf0107408
f0102d7c:	68 c3 76 10 f0       	push   $0xf01076c3
f0102d81:	68 15 04 00 00       	push   $0x415
f0102d86:	68 9d 76 10 f0       	push   $0xf010769d
f0102d8b:	e8 04 d3 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102d90:	68 34 74 10 f0       	push   $0xf0107434
f0102d95:	68 c3 76 10 f0       	push   $0xf01076c3
f0102d9a:	68 17 04 00 00       	push   $0x417
f0102d9f:	68 9d 76 10 f0       	push   $0xf010769d
f0102da4:	e8 eb d2 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102da9:	68 78 74 10 f0       	push   $0xf0107478
f0102dae:	68 c3 76 10 f0       	push   $0xf01076c3
f0102db3:	68 18 04 00 00       	push   $0x418
f0102db8:	68 9d 76 10 f0       	push   $0xf010769d
f0102dbd:	e8 d2 d2 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dc2:	50                   	push   %eax
f0102dc3:	68 ec 65 10 f0       	push   $0xf01065ec
f0102dc8:	68 bd 00 00 00       	push   $0xbd
f0102dcd:	68 9d 76 10 f0       	push   $0xf010769d
f0102dd2:	e8 bd d2 ff ff       	call   f0100094 <_panic>
f0102dd7:	50                   	push   %eax
f0102dd8:	68 ec 65 10 f0       	push   $0xf01065ec
f0102ddd:	68 c7 00 00 00       	push   $0xc7
f0102de2:	68 9d 76 10 f0       	push   $0xf010769d
f0102de7:	e8 a8 d2 ff ff       	call   f0100094 <_panic>
f0102dec:	50                   	push   %eax
f0102ded:	68 ec 65 10 f0       	push   $0xf01065ec
f0102df2:	68 d4 00 00 00       	push   $0xd4
f0102df7:	68 9d 76 10 f0       	push   $0xf010769d
f0102dfc:	e8 93 d2 ff ff       	call   f0100094 <_panic>
f0102e01:	57                   	push   %edi
f0102e02:	68 ec 65 10 f0       	push   $0xf01065ec
f0102e07:	68 14 01 00 00       	push   $0x114
f0102e0c:	68 9d 76 10 f0       	push   $0xf010769d
f0102e11:	e8 7e d2 ff ff       	call   f0100094 <_panic>
f0102e16:	ff 75 c0             	pushl  -0x40(%ebp)
f0102e19:	68 ec 65 10 f0       	push   $0xf01065ec
f0102e1e:	68 30 03 00 00       	push   $0x330
f0102e23:	68 9d 76 10 f0       	push   $0xf010769d
f0102e28:	e8 67 d2 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e2d:	68 ac 74 10 f0       	push   $0xf01074ac
f0102e32:	68 c3 76 10 f0       	push   $0xf01076c3
f0102e37:	68 30 03 00 00       	push   $0x330
f0102e3c:	68 9d 76 10 f0       	push   $0xf010769d
f0102e41:	e8 4e d2 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102e46:	a1 48 12 29 f0       	mov    0xf0291248,%eax
f0102e4b:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((uint32_t)kva < KERNBASE)
f0102e4e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102e51:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102e56:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f0102e5c:	89 da                	mov    %ebx,%edx
f0102e5e:	89 f8                	mov    %edi,%eax
f0102e60:	e8 6d e1 ff ff       	call   f0100fd2 <check_va2pa>
f0102e65:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102e6c:	76 22                	jbe    f0102e90 <mem_init+0x1689>
f0102e6e:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102e71:	39 d0                	cmp    %edx,%eax
f0102e73:	75 32                	jne    f0102ea7 <mem_init+0x16a0>
f0102e75:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f0102e7b:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102e81:	75 d9                	jne    f0102e5c <mem_init+0x1655>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e83:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102e86:	c1 e6 0c             	shl    $0xc,%esi
f0102e89:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102e8e:	eb 4b                	jmp    f0102edb <mem_init+0x16d4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e90:	ff 75 d0             	pushl  -0x30(%ebp)
f0102e93:	68 ec 65 10 f0       	push   $0xf01065ec
f0102e98:	68 35 03 00 00       	push   $0x335
f0102e9d:	68 9d 76 10 f0       	push   $0xf010769d
f0102ea2:	e8 ed d1 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102ea7:	68 e0 74 10 f0       	push   $0xf01074e0
f0102eac:	68 c3 76 10 f0       	push   $0xf01076c3
f0102eb1:	68 35 03 00 00       	push   $0x335
f0102eb6:	68 9d 76 10 f0       	push   $0xf010769d
f0102ebb:	e8 d4 d1 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102ec0:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102ec6:	89 f8                	mov    %edi,%eax
f0102ec8:	e8 05 e1 ff ff       	call   f0100fd2 <check_va2pa>
f0102ecd:	39 c3                	cmp    %eax,%ebx
f0102ecf:	0f 85 f5 00 00 00    	jne    f0102fca <mem_init+0x17c3>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102ed5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102edb:	39 f3                	cmp    %esi,%ebx
f0102edd:	72 e1                	jb     f0102ec0 <mem_init+0x16b9>
f0102edf:	c7 45 d4 00 30 29 f0 	movl   $0xf0293000,-0x2c(%ebp)
f0102ee6:	c7 45 cc 00 80 ff ef 	movl   $0xefff8000,-0x34(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102eed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ef0:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0102ef3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0102ef6:	8d 83 00 80 00 00    	lea    0x8000(%ebx),%eax
f0102efc:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102eff:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102f02:	8d b0 00 80 00 20    	lea    0x20008000(%eax),%esi
f0102f08:	89 da                	mov    %ebx,%edx
f0102f0a:	89 f8                	mov    %edi,%eax
f0102f0c:	e8 c1 e0 ff ff       	call   f0100fd2 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102f11:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102f18:	0f 86 c5 00 00 00    	jbe    f0102fe3 <mem_init+0x17dc>
f0102f1e:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102f21:	39 d0                	cmp    %edx,%eax
f0102f23:	0f 85 d1 00 00 00    	jne    f0102ffa <mem_init+0x17f3>
f0102f29:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102f2f:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102f32:	75 d4                	jne    f0102f08 <mem_init+0x1701>
f0102f34:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102f37:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102f3d:	89 da                	mov    %ebx,%edx
f0102f3f:	89 f8                	mov    %edi,%eax
f0102f41:	e8 8c e0 ff ff       	call   f0100fd2 <check_va2pa>
f0102f46:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102f49:	0f 85 c4 00 00 00    	jne    f0103013 <mem_init+0x180c>
f0102f4f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102f55:	39 f3                	cmp    %esi,%ebx
f0102f57:	75 e4                	jne    f0102f3d <mem_init+0x1736>
f0102f59:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102f60:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102f67:	81 45 d4 00 80 00 00 	addl   $0x8000,-0x2c(%ebp)
f0102f6e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	for (n = 0; n < NCPU; n++) {
f0102f71:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
f0102f74:	0f 85 73 ff ff ff    	jne    f0102eed <mem_init+0x16e6>
	for (i = 0; i < NPDENTRIES; i++) {
f0102f7a:	b8 00 00 00 00       	mov    $0x0,%eax
			if (i >= PDX(KERNBASE)) {
f0102f7f:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102f84:	0f 87 a2 00 00 00    	ja     f010302c <mem_init+0x1825>
				assert(pgdir[i] == 0);
f0102f8a:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102f8e:	0f 85 db 00 00 00    	jne    f010306f <mem_init+0x1868>
	for (i = 0; i < NPDENTRIES; i++) {
f0102f94:	40                   	inc    %eax
f0102f95:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102f9a:	0f 87 e8 00 00 00    	ja     f0103088 <mem_init+0x1881>
		switch (i) {
f0102fa0:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102fa6:	83 fa 04             	cmp    $0x4,%edx
f0102fa9:	77 d4                	ja     f0102f7f <mem_init+0x1778>
			assert(pgdir[i] & PTE_P);
f0102fab:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102faf:	75 e3                	jne    f0102f94 <mem_init+0x178d>
f0102fb1:	68 bb 79 10 f0       	push   $0xf01079bb
f0102fb6:	68 c3 76 10 f0       	push   $0xf01076c3
f0102fbb:	68 4e 03 00 00       	push   $0x34e
f0102fc0:	68 9d 76 10 f0       	push   $0xf010769d
f0102fc5:	e8 ca d0 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102fca:	68 14 75 10 f0       	push   $0xf0107514
f0102fcf:	68 c3 76 10 f0       	push   $0xf01076c3
f0102fd4:	68 39 03 00 00       	push   $0x339
f0102fd9:	68 9d 76 10 f0       	push   $0xf010769d
f0102fde:	e8 b1 d0 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fe3:	ff 75 c0             	pushl  -0x40(%ebp)
f0102fe6:	68 ec 65 10 f0       	push   $0xf01065ec
f0102feb:	68 41 03 00 00       	push   $0x341
f0102ff0:	68 9d 76 10 f0       	push   $0xf010769d
f0102ff5:	e8 9a d0 ff ff       	call   f0100094 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102ffa:	68 3c 75 10 f0       	push   $0xf010753c
f0102fff:	68 c3 76 10 f0       	push   $0xf01076c3
f0103004:	68 41 03 00 00       	push   $0x341
f0103009:	68 9d 76 10 f0       	push   $0xf010769d
f010300e:	e8 81 d0 ff ff       	call   f0100094 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0103013:	68 84 75 10 f0       	push   $0xf0107584
f0103018:	68 c3 76 10 f0       	push   $0xf01076c3
f010301d:	68 43 03 00 00       	push   $0x343
f0103022:	68 9d 76 10 f0       	push   $0xf010769d
f0103027:	e8 68 d0 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_P);
f010302c:	8b 14 87             	mov    (%edi,%eax,4),%edx
f010302f:	f6 c2 01             	test   $0x1,%dl
f0103032:	74 22                	je     f0103056 <mem_init+0x184f>
				assert(pgdir[i] & PTE_W);
f0103034:	f6 c2 02             	test   $0x2,%dl
f0103037:	0f 85 57 ff ff ff    	jne    f0102f94 <mem_init+0x178d>
f010303d:	68 cc 79 10 f0       	push   $0xf01079cc
f0103042:	68 c3 76 10 f0       	push   $0xf01076c3
f0103047:	68 53 03 00 00       	push   $0x353
f010304c:	68 9d 76 10 f0       	push   $0xf010769d
f0103051:	e8 3e d0 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_P);
f0103056:	68 bb 79 10 f0       	push   $0xf01079bb
f010305b:	68 c3 76 10 f0       	push   $0xf01076c3
f0103060:	68 52 03 00 00       	push   $0x352
f0103065:	68 9d 76 10 f0       	push   $0xf010769d
f010306a:	e8 25 d0 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] == 0);
f010306f:	68 dd 79 10 f0       	push   $0xf01079dd
f0103074:	68 c3 76 10 f0       	push   $0xf01076c3
f0103079:	68 55 03 00 00       	push   $0x355
f010307e:	68 9d 76 10 f0       	push   $0xf010769d
f0103083:	e8 0c d0 ff ff       	call   f0100094 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0103088:	83 ec 0c             	sub    $0xc,%esp
f010308b:	68 a8 75 10 f0       	push   $0xf01075a8
f0103090:	e8 fe 0e 00 00       	call   f0103f93 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0103095:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f010309a:	83 c4 10             	add    $0x10,%esp
f010309d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030a2:	0f 86 fe 01 00 00    	jbe    f01032a6 <mem_init+0x1a9f>
	return (physaddr_t)kva - KERNBASE;
f01030a8:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01030ad:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f01030b0:	b8 00 00 00 00       	mov    $0x0,%eax
f01030b5:	e8 77 df ff ff       	call   f0101031 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01030ba:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01030bd:	83 e0 f3             	and    $0xfffffff3,%eax
f01030c0:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01030c5:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01030c8:	83 ec 0c             	sub    $0xc,%esp
f01030cb:	6a 00                	push   $0x0
f01030cd:	e8 14 e3 ff ff       	call   f01013e6 <page_alloc>
f01030d2:	89 c3                	mov    %eax,%ebx
f01030d4:	83 c4 10             	add    $0x10,%esp
f01030d7:	85 c0                	test   %eax,%eax
f01030d9:	0f 84 dc 01 00 00    	je     f01032bb <mem_init+0x1ab4>
	assert((pp1 = page_alloc(0)));
f01030df:	83 ec 0c             	sub    $0xc,%esp
f01030e2:	6a 00                	push   $0x0
f01030e4:	e8 fd e2 ff ff       	call   f01013e6 <page_alloc>
f01030e9:	89 c7                	mov    %eax,%edi
f01030eb:	83 c4 10             	add    $0x10,%esp
f01030ee:	85 c0                	test   %eax,%eax
f01030f0:	0f 84 de 01 00 00    	je     f01032d4 <mem_init+0x1acd>
	assert((pp2 = page_alloc(0)));
f01030f6:	83 ec 0c             	sub    $0xc,%esp
f01030f9:	6a 00                	push   $0x0
f01030fb:	e8 e6 e2 ff ff       	call   f01013e6 <page_alloc>
f0103100:	89 c6                	mov    %eax,%esi
f0103102:	83 c4 10             	add    $0x10,%esp
f0103105:	85 c0                	test   %eax,%eax
f0103107:	0f 84 e0 01 00 00    	je     f01032ed <mem_init+0x1ae6>
	page_free(pp0);
f010310d:	83 ec 0c             	sub    $0xc,%esp
f0103110:	53                   	push   %ebx
f0103111:	e8 42 e3 ff ff       	call   f0101458 <page_free>
	return (pp - pages) << PGSHIFT;
f0103116:	89 f8                	mov    %edi,%eax
f0103118:	2b 05 90 1e 29 f0    	sub    0xf0291e90,%eax
f010311e:	c1 f8 03             	sar    $0x3,%eax
f0103121:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0103124:	89 c2                	mov    %eax,%edx
f0103126:	c1 ea 0c             	shr    $0xc,%edx
f0103129:	83 c4 10             	add    $0x10,%esp
f010312c:	3b 15 88 1e 29 f0    	cmp    0xf0291e88,%edx
f0103132:	0f 83 ce 01 00 00    	jae    f0103306 <mem_init+0x1aff>
	memset(page2kva(pp1), 1, PGSIZE);
f0103138:	83 ec 04             	sub    $0x4,%esp
f010313b:	68 00 10 00 00       	push   $0x1000
f0103140:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0103142:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103147:	50                   	push   %eax
f0103148:	e8 0f 26 00 00       	call   f010575c <memset>
	return (pp - pages) << PGSHIFT;
f010314d:	89 f0                	mov    %esi,%eax
f010314f:	2b 05 90 1e 29 f0    	sub    0xf0291e90,%eax
f0103155:	c1 f8 03             	sar    $0x3,%eax
f0103158:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010315b:	89 c2                	mov    %eax,%edx
f010315d:	c1 ea 0c             	shr    $0xc,%edx
f0103160:	83 c4 10             	add    $0x10,%esp
f0103163:	3b 15 88 1e 29 f0    	cmp    0xf0291e88,%edx
f0103169:	0f 83 a9 01 00 00    	jae    f0103318 <mem_init+0x1b11>
	memset(page2kva(pp2), 2, PGSIZE);
f010316f:	83 ec 04             	sub    $0x4,%esp
f0103172:	68 00 10 00 00       	push   $0x1000
f0103177:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0103179:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010317e:	50                   	push   %eax
f010317f:	e8 d8 25 00 00       	call   f010575c <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103184:	6a 02                	push   $0x2
f0103186:	68 00 10 00 00       	push   $0x1000
f010318b:	57                   	push   %edi
f010318c:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f0103192:	e8 a8 e5 ff ff       	call   f010173f <page_insert>
	assert(pp1->pp_ref == 1);
f0103197:	83 c4 20             	add    $0x20,%esp
f010319a:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010319f:	0f 85 85 01 00 00    	jne    f010332a <mem_init+0x1b23>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01031a5:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01031ac:	01 01 01 
f01031af:	0f 85 8e 01 00 00    	jne    f0103343 <mem_init+0x1b3c>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01031b5:	6a 02                	push   $0x2
f01031b7:	68 00 10 00 00       	push   $0x1000
f01031bc:	56                   	push   %esi
f01031bd:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f01031c3:	e8 77 e5 ff ff       	call   f010173f <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01031c8:	83 c4 10             	add    $0x10,%esp
f01031cb:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01031d2:	02 02 02 
f01031d5:	0f 85 81 01 00 00    	jne    f010335c <mem_init+0x1b55>
	assert(pp2->pp_ref == 1);
f01031db:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01031e0:	0f 85 8f 01 00 00    	jne    f0103375 <mem_init+0x1b6e>
	assert(pp1->pp_ref == 0);
f01031e6:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01031eb:	0f 85 9d 01 00 00    	jne    f010338e <mem_init+0x1b87>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01031f1:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01031f8:	03 03 03 
	return (pp - pages) << PGSHIFT;
f01031fb:	89 f0                	mov    %esi,%eax
f01031fd:	2b 05 90 1e 29 f0    	sub    0xf0291e90,%eax
f0103203:	c1 f8 03             	sar    $0x3,%eax
f0103206:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0103209:	89 c2                	mov    %eax,%edx
f010320b:	c1 ea 0c             	shr    $0xc,%edx
f010320e:	3b 15 88 1e 29 f0    	cmp    0xf0291e88,%edx
f0103214:	0f 83 8d 01 00 00    	jae    f01033a7 <mem_init+0x1ba0>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010321a:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103221:	03 03 03 
f0103224:	0f 85 8f 01 00 00    	jne    f01033b9 <mem_init+0x1bb2>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010322a:	83 ec 08             	sub    $0x8,%esp
f010322d:	68 00 10 00 00       	push   $0x1000
f0103232:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f0103238:	e8 a8 e4 ff ff       	call   f01016e5 <page_remove>
	assert(pp2->pp_ref == 0);
f010323d:	83 c4 10             	add    $0x10,%esp
f0103240:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0103245:	0f 85 87 01 00 00    	jne    f01033d2 <mem_init+0x1bcb>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010324b:	8b 0d 8c 1e 29 f0    	mov    0xf0291e8c,%ecx
f0103251:	8b 11                	mov    (%ecx),%edx
f0103253:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0103259:	89 d8                	mov    %ebx,%eax
f010325b:	2b 05 90 1e 29 f0    	sub    0xf0291e90,%eax
f0103261:	c1 f8 03             	sar    $0x3,%eax
f0103264:	c1 e0 0c             	shl    $0xc,%eax
f0103267:	39 c2                	cmp    %eax,%edx
f0103269:	0f 85 7c 01 00 00    	jne    f01033eb <mem_init+0x1be4>
	kern_pgdir[0] = 0;
f010326f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0103275:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010327a:	0f 85 84 01 00 00    	jne    f0103404 <mem_init+0x1bfd>
	pp0->pp_ref = 0;
f0103280:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0103286:	83 ec 0c             	sub    $0xc,%esp
f0103289:	53                   	push   %ebx
f010328a:	e8 c9 e1 ff ff       	call   f0101458 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010328f:	c7 04 24 3c 76 10 f0 	movl   $0xf010763c,(%esp)
f0103296:	e8 f8 0c 00 00       	call   f0103f93 <cprintf>
}
f010329b:	83 c4 10             	add    $0x10,%esp
f010329e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01032a1:	5b                   	pop    %ebx
f01032a2:	5e                   	pop    %esi
f01032a3:	5f                   	pop    %edi
f01032a4:	5d                   	pop    %ebp
f01032a5:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032a6:	50                   	push   %eax
f01032a7:	68 ec 65 10 f0       	push   $0xf01065ec
f01032ac:	68 ed 00 00 00       	push   $0xed
f01032b1:	68 9d 76 10 f0       	push   $0xf010769d
f01032b6:	e8 d9 cd ff ff       	call   f0100094 <_panic>
	assert((pp0 = page_alloc(0)));
f01032bb:	68 c7 77 10 f0       	push   $0xf01077c7
f01032c0:	68 c3 76 10 f0       	push   $0xf01076c3
f01032c5:	68 2d 04 00 00       	push   $0x42d
f01032ca:	68 9d 76 10 f0       	push   $0xf010769d
f01032cf:	e8 c0 cd ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01032d4:	68 dd 77 10 f0       	push   $0xf01077dd
f01032d9:	68 c3 76 10 f0       	push   $0xf01076c3
f01032de:	68 2e 04 00 00       	push   $0x42e
f01032e3:	68 9d 76 10 f0       	push   $0xf010769d
f01032e8:	e8 a7 cd ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01032ed:	68 f3 77 10 f0       	push   $0xf01077f3
f01032f2:	68 c3 76 10 f0       	push   $0xf01076c3
f01032f7:	68 2f 04 00 00       	push   $0x42f
f01032fc:	68 9d 76 10 f0       	push   $0xf010769d
f0103301:	e8 8e cd ff ff       	call   f0100094 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103306:	50                   	push   %eax
f0103307:	68 c8 65 10 f0       	push   $0xf01065c8
f010330c:	6a 58                	push   $0x58
f010330e:	68 a9 76 10 f0       	push   $0xf01076a9
f0103313:	e8 7c cd ff ff       	call   f0100094 <_panic>
f0103318:	50                   	push   %eax
f0103319:	68 c8 65 10 f0       	push   $0xf01065c8
f010331e:	6a 58                	push   $0x58
f0103320:	68 a9 76 10 f0       	push   $0xf01076a9
f0103325:	e8 6a cd ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f010332a:	68 c4 78 10 f0       	push   $0xf01078c4
f010332f:	68 c3 76 10 f0       	push   $0xf01076c3
f0103334:	68 34 04 00 00       	push   $0x434
f0103339:	68 9d 76 10 f0       	push   $0xf010769d
f010333e:	e8 51 cd ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103343:	68 c8 75 10 f0       	push   $0xf01075c8
f0103348:	68 c3 76 10 f0       	push   $0xf01076c3
f010334d:	68 35 04 00 00       	push   $0x435
f0103352:	68 9d 76 10 f0       	push   $0xf010769d
f0103357:	e8 38 cd ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010335c:	68 ec 75 10 f0       	push   $0xf01075ec
f0103361:	68 c3 76 10 f0       	push   $0xf01076c3
f0103366:	68 37 04 00 00       	push   $0x437
f010336b:	68 9d 76 10 f0       	push   $0xf010769d
f0103370:	e8 1f cd ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0103375:	68 e6 78 10 f0       	push   $0xf01078e6
f010337a:	68 c3 76 10 f0       	push   $0xf01076c3
f010337f:	68 38 04 00 00       	push   $0x438
f0103384:	68 9d 76 10 f0       	push   $0xf010769d
f0103389:	e8 06 cd ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f010338e:	68 50 79 10 f0       	push   $0xf0107950
f0103393:	68 c3 76 10 f0       	push   $0xf01076c3
f0103398:	68 39 04 00 00       	push   $0x439
f010339d:	68 9d 76 10 f0       	push   $0xf010769d
f01033a2:	e8 ed cc ff ff       	call   f0100094 <_panic>
f01033a7:	50                   	push   %eax
f01033a8:	68 c8 65 10 f0       	push   $0xf01065c8
f01033ad:	6a 58                	push   $0x58
f01033af:	68 a9 76 10 f0       	push   $0xf01076a9
f01033b4:	e8 db cc ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01033b9:	68 10 76 10 f0       	push   $0xf0107610
f01033be:	68 c3 76 10 f0       	push   $0xf01076c3
f01033c3:	68 3b 04 00 00       	push   $0x43b
f01033c8:	68 9d 76 10 f0       	push   $0xf010769d
f01033cd:	e8 c2 cc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01033d2:	68 1e 79 10 f0       	push   $0xf010791e
f01033d7:	68 c3 76 10 f0       	push   $0xf01076c3
f01033dc:	68 3d 04 00 00       	push   $0x43d
f01033e1:	68 9d 76 10 f0       	push   $0xf010769d
f01033e6:	e8 a9 cc ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01033eb:	68 98 6f 10 f0       	push   $0xf0106f98
f01033f0:	68 c3 76 10 f0       	push   $0xf01076c3
f01033f5:	68 40 04 00 00       	push   $0x440
f01033fa:	68 9d 76 10 f0       	push   $0xf010769d
f01033ff:	e8 90 cc ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0103404:	68 d5 78 10 f0       	push   $0xf01078d5
f0103409:	68 c3 76 10 f0       	push   $0xf01076c3
f010340e:	68 42 04 00 00       	push   $0x442
f0103413:	68 9d 76 10 f0       	push   $0xf010769d
f0103418:	e8 77 cc ff ff       	call   f0100094 <_panic>

f010341d <user_mem_check>:
{
f010341d:	55                   	push   %ebp
f010341e:	89 e5                	mov    %esp,%ebp
f0103420:	57                   	push   %edi
f0103421:	56                   	push   %esi
f0103422:	53                   	push   %ebx
f0103423:	83 ec 1c             	sub    $0x1c,%esp
f0103426:	8b 7d 08             	mov    0x8(%ebp),%edi
	void *l = ROUNDDOWN((void*)va, PGSIZE), *r = ROUNDUP((void*)va + len, PGSIZE);
f0103429:	8b 45 0c             	mov    0xc(%ebp),%eax
f010342c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010342f:	89 c3                	mov    %eax,%ebx
f0103431:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0103437:	89 c6                	mov    %eax,%esi
f0103439:	03 75 10             	add    0x10(%ebp),%esi
f010343c:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
f0103442:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for (; l < r; l += PGSIZE) {
f0103448:	eb 1d                	jmp    f0103467 <user_mem_check+0x4a>
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f010344a:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f010344d:	72 03                	jb     f0103452 <user_mem_check+0x35>
		if ((uintptr_t)l >= ULIM) {// Higher than ULIM
f010344f:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f0103452:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103455:	a3 3c 12 29 f0       	mov    %eax,0xf029123c
			return -E_FAULT;
f010345a:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010345f:	eb 59                	jmp    f01034ba <user_mem_check+0x9d>
	for (; l < r; l += PGSIZE) {
f0103461:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103467:	39 f3                	cmp    %esi,%ebx
f0103469:	73 4a                	jae    f01034b5 <user_mem_check+0x98>
		if ((uintptr_t)l >= ULIM) {// Higher than ULIM
f010346b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f010346e:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0103474:	77 d4                	ja     f010344a <user_mem_check+0x2d>
		pte_t* pte = pgdir_walk(env->env_pgdir, l, 0);
f0103476:	83 ec 04             	sub    $0x4,%esp
f0103479:	6a 00                	push   $0x0
f010347b:	53                   	push   %ebx
f010347c:	ff 77 60             	pushl  0x60(%edi)
f010347f:	e8 4c e0 ff ff       	call   f01014d0 <pgdir_walk>
		if (pte) {
f0103484:	83 c4 10             	add    $0x10,%esp
f0103487:	85 c0                	test   %eax,%eax
f0103489:	74 d6                	je     f0103461 <user_mem_check+0x44>
			uint32_t given_perm = *pte & 0xFFF;
f010348b:	8b 00                	mov    (%eax),%eax
f010348d:	25 ff 0f 00 00       	and    $0xfff,%eax
			if ((given_perm | perm) > given_perm) {
f0103492:	89 c2                	mov    %eax,%edx
f0103494:	0b 55 14             	or     0x14(%ebp),%edx
f0103497:	39 c2                	cmp    %eax,%edx
f0103499:	76 c6                	jbe    f0103461 <user_mem_check+0x44>
				user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f010349b:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f010349e:	72 06                	jb     f01034a6 <user_mem_check+0x89>
		if ((uintptr_t)l >= ULIM) {// Higher than ULIM
f01034a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01034a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
				user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f01034a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034a9:	a3 3c 12 29 f0       	mov    %eax,0xf029123c
				return -E_FAULT;
f01034ae:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034b3:	eb 05                	jmp    f01034ba <user_mem_check+0x9d>
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
f01034da:	e8 3e ff ff ff       	call   f010341d <user_mem_check>
f01034df:	83 c4 10             	add    $0x10,%esp
f01034e2:	85 c0                	test   %eax,%eax
f01034e4:	78 05                	js     f01034eb <user_mem_assert+0x29>
}
f01034e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01034e9:	c9                   	leave  
f01034ea:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f01034eb:	83 ec 04             	sub    $0x4,%esp
f01034ee:	ff 35 3c 12 29 f0    	pushl  0xf029123c
f01034f4:	ff 73 48             	pushl  0x48(%ebx)
f01034f7:	68 68 76 10 f0       	push   $0xf0107668
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
f010352c:	8b 0d 48 12 29 f0    	mov    0xf0291248,%ecx
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
f0103554:	e8 dd 28 00 00       	call   f0105e36 <cpunum>
f0103559:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010355c:	01 c2                	add    %eax,%edx
f010355e:	01 d2                	add    %edx,%edx
f0103560:	01 c2                	add    %eax,%edx
f0103562:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103565:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
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
f0103588:	e8 a9 28 00 00       	call   f0105e36 <cpunum>
f010358d:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103590:	01 c2                	add    %eax,%edx
f0103592:	01 d2                	add    %edx,%edx
f0103594:	01 c2                	add    %eax,%edx
f0103596:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103599:	39 1c 85 28 20 29 f0 	cmp    %ebx,-0xfd6dfd8(,%eax,4)
f01035a0:	74 a4                	je     f0103546 <envid2env+0x38>
f01035a2:	8b 73 4c             	mov    0x4c(%ebx),%esi
f01035a5:	e8 8c 28 00 00       	call   f0105e36 <cpunum>
f01035aa:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01035ad:	01 c2                	add    %eax,%edx
f01035af:	01 d2                	add    %edx,%edx
f01035b1:	01 c2                	add    %eax,%edx
f01035b3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01035b6:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
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
f010360a:	8b 35 48 12 29 f0    	mov    0xf0291248,%esi
f0103610:	8b 15 4c 12 29 f0    	mov    0xf029124c,%edx
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
f010362d:	89 35 4c 12 29 f0    	mov    %esi,0xf029124c
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
f0103641:	8b 1d 4c 12 29 f0    	mov    0xf029124c,%ebx
f0103647:	85 db                	test   %ebx,%ebx
f0103649:	0f 84 f3 01 00 00    	je     f0103842 <env_alloc+0x206>
	if (!(p = page_alloc(ALLOC_ZERO)))
f010364f:	83 ec 0c             	sub    $0xc,%esp
f0103652:	6a 01                	push   $0x1
f0103654:	e8 8d dd ff ff       	call   f01013e6 <page_alloc>
f0103659:	89 c6                	mov    %eax,%esi
f010365b:	83 c4 10             	add    $0x10,%esp
f010365e:	85 c0                	test   %eax,%eax
f0103660:	0f 84 e3 01 00 00    	je     f0103849 <env_alloc+0x20d>
	return (pp - pages) << PGSHIFT;
f0103666:	2b 05 90 1e 29 f0    	sub    0xf0291e90,%eax
f010366c:	c1 f8 03             	sar    $0x3,%eax
f010366f:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0103672:	89 c2                	mov    %eax,%edx
f0103674:	c1 ea 0c             	shr    $0xc,%edx
f0103677:	3b 15 88 1e 29 f0    	cmp    0xf0291e88,%edx
f010367d:	0f 83 75 01 00 00    	jae    f01037f8 <env_alloc+0x1bc>
	memset(page2kva(p), 0, PGSIZE);
f0103683:	83 ec 04             	sub    $0x4,%esp
f0103686:	68 00 10 00 00       	push   $0x1000
f010368b:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f010368d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103692:	50                   	push   %eax
f0103693:	e8 c4 20 00 00       	call   f010575c <memset>
	p->pp_ref++;
f0103698:	66 ff 46 04          	incw   0x4(%esi)
	return (pp - pages) << PGSHIFT;
f010369c:	2b 35 90 1e 29 f0    	sub    0xf0291e90,%esi
f01036a2:	c1 fe 03             	sar    $0x3,%esi
f01036a5:	c1 e6 0c             	shl    $0xc,%esi
	if (PGNUM(pa) >= npages)
f01036a8:	89 f0                	mov    %esi,%eax
f01036aa:	c1 e8 0c             	shr    $0xc,%eax
f01036ad:	83 c4 10             	add    $0x10,%esp
f01036b0:	3b 05 88 1e 29 f0    	cmp    0xf0291e88,%eax
f01036b6:	0f 83 4e 01 00 00    	jae    f010380a <env_alloc+0x1ce>
	return (void *)(pa + KERNBASE);
f01036bc:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f01036c2:	89 73 60             	mov    %esi,0x60(%ebx)
	e->env_pgdir = page2kva(p);
f01036c5:	b8 ec 0e 00 00       	mov    $0xeec,%eax
		e->env_pgdir[pgt] = kern_pgdir[pgt];
f01036ca:	8b 15 8c 1e 29 f0    	mov    0xf0291e8c,%edx
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
f0103717:	2b 05 48 12 29 f0    	sub    0xf0291248,%eax
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
f0103762:	e8 f5 1f 00 00       	call   f010575c <memset>
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
f0103794:	a3 4c 12 29 f0       	mov    %eax,0xf029124c
	*newenv_store = e;
f0103799:	8b 45 08             	mov    0x8(%ebp),%eax
f010379c:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010379e:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01037a1:	e8 90 26 00 00       	call   f0105e36 <cpunum>
f01037a6:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01037a9:	01 c2                	add    %eax,%edx
f01037ab:	01 d2                	add    %edx,%edx
f01037ad:	01 c2                	add    %eax,%edx
f01037af:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01037b2:	83 c4 10             	add    $0x10,%esp
f01037b5:	83 3c 85 28 20 29 f0 	cmpl   $0x0,-0xfd6dfd8(,%eax,4)
f01037bc:	00 
f01037bd:	74 7c                	je     f010383b <env_alloc+0x1ff>
f01037bf:	e8 72 26 00 00       	call   f0105e36 <cpunum>
f01037c4:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01037c7:	01 c2                	add    %eax,%edx
f01037c9:	01 d2                	add    %edx,%edx
f01037cb:	01 c2                	add    %eax,%edx
f01037cd:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01037d0:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f01037d7:	8b 40 48             	mov    0x48(%eax),%eax
f01037da:	83 ec 04             	sub    $0x4,%esp
f01037dd:	53                   	push   %ebx
f01037de:	50                   	push   %eax
f01037df:	68 3e 7a 10 f0       	push   $0xf0107a3e
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
f01037f9:	68 c8 65 10 f0       	push   $0xf01065c8
f01037fe:	6a 58                	push   $0x58
f0103800:	68 a9 76 10 f0       	push   $0xf01076a9
f0103805:	e8 8a c8 ff ff       	call   f0100094 <_panic>
f010380a:	56                   	push   %esi
f010380b:	68 c8 65 10 f0       	push   $0xf01065c8
f0103810:	6a 58                	push   $0x58
f0103812:	68 a9 76 10 f0       	push   $0xf01076a9
f0103817:	e8 78 c8 ff ff       	call   f0100094 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010381c:	50                   	push   %eax
f010381d:	68 ec 65 10 f0       	push   $0xf01065ec
f0103822:	68 ca 00 00 00       	push   $0xca
f0103827:	68 33 7a 10 f0       	push   $0xf0107a33
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
f0103895:	ff 35 8c 1e 29 f0    	pushl  0xf0291e8c
f010389b:	e8 30 dc ff ff       	call   f01014d0 <pgdir_walk>
	physaddr_t pgdir_phy = PTE_ADDR(pgdir_pte);
f01038a0:	8b 00                	mov    (%eax),%eax
f01038a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01038a7:	0f 22 d8             	mov    %eax,%cr3
f01038aa:	83 c4 10             	add    $0x10,%esp
f01038ad:	e9 df 00 00 00       	jmp    f0103991 <env_create+0x141>
		panic("Environment allocation faulted: %e", r);
f01038b2:	50                   	push   %eax
f01038b3:	68 ec 79 10 f0       	push   $0xf01079ec
f01038b8:	68 a6 01 00 00       	push   $0x1a6
f01038bd:	68 33 7a 10 f0       	push   $0xf0107a33
f01038c2:	e8 cd c7 ff ff       	call   f0100094 <_panic>
		panic("Not a valid elf binary!");
f01038c7:	83 ec 04             	sub    $0x4,%esp
f01038ca:	68 53 7a 10 f0       	push   $0xf0107a53
f01038cf:	68 68 01 00 00       	push   $0x168
f01038d4:	68 33 7a 10 f0       	push   $0xf0107a33
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
f0103907:	e8 da da ff ff       	call   f01013e6 <page_alloc>
		if (!pg)
f010390c:	83 c4 10             	add    $0x10,%esp
f010390f:	85 c0                	test   %eax,%eax
f0103911:	74 1b                	je     f010392e <env_create+0xde>
		int res = page_insert(e->env_pgdir, pg, (void*)ptr, PTE_U | PTE_W);
f0103913:	6a 06                	push   $0x6
f0103915:	53                   	push   %ebx
f0103916:	50                   	push   %eax
f0103917:	ff 77 60             	pushl  0x60(%edi)
f010391a:	e8 20 de ff ff       	call   f010173f <page_insert>
		if (res)
f010391f:	83 c4 10             	add    $0x10,%esp
f0103922:	85 c0                	test   %eax,%eax
f0103924:	75 1f                	jne    f0103945 <env_create+0xf5>
	for (uintptr_t ptr = l; ptr < r; ptr += PGSIZE) {
f0103926:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010392c:	eb d0                	jmp    f01038fe <env_create+0xae>
			panic("No free page for allocation.");
f010392e:	83 ec 04             	sub    $0x4,%esp
f0103931:	68 6b 7a 10 f0       	push   $0xf0107a6b
f0103936:	68 26 01 00 00       	push   $0x126
f010393b:	68 33 7a 10 f0       	push   $0xf0107a33
f0103940:	e8 4f c7 ff ff       	call   f0100094 <_panic>
			panic("Page insertion result: %e", r);
f0103945:	ff 75 cc             	pushl  -0x34(%ebp)
f0103948:	68 88 7a 10 f0       	push   $0xf0107a88
f010394d:	68 29 01 00 00       	push   $0x129
f0103952:	68 33 7a 10 f0       	push   $0xf0107a33
f0103957:	e8 38 c7 ff ff       	call   f0100094 <_panic>
f010395c:	8b 75 d0             	mov    -0x30(%ebp),%esi
			memcpy((void*)ph0->p_va, binary + ph0->p_offset, ph0->p_filesz);
f010395f:	83 ec 04             	sub    $0x4,%esp
f0103962:	ff 76 10             	pushl  0x10(%esi)
f0103965:	8b 45 08             	mov    0x8(%ebp),%eax
f0103968:	03 46 04             	add    0x4(%esi),%eax
f010396b:	50                   	push   %eax
f010396c:	ff 76 08             	pushl  0x8(%esi)
f010396f:	e8 9b 1e 00 00       	call   f010580f <memcpy>
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
f0103986:	e8 d1 1d 00 00       	call   f010575c <memset>
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
f01039a5:	68 10 7a 10 f0       	push   $0xf0107a10
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
f01039c4:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01039c9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039ce:	76 38                	jbe    f0103a08 <env_create+0x1b8>
	return (physaddr_t)kva - KERNBASE;
f01039d0:	05 00 00 00 10       	add    $0x10000000,%eax
f01039d5:	0f 22 d8             	mov    %eax,%cr3
	struct PageInfo *stack_page = page_alloc(ALLOC_ZERO);
f01039d8:	83 ec 0c             	sub    $0xc,%esp
f01039db:	6a 01                	push   $0x1
f01039dd:	e8 04 da ff ff       	call   f01013e6 <page_alloc>
	if (!stack_page)
f01039e2:	83 c4 10             	add    $0x10,%esp
f01039e5:	85 c0                	test   %eax,%eax
f01039e7:	74 34                	je     f0103a1d <env_create+0x1cd>
	int r = page_insert(e->env_pgdir, stack_page, (void*)USTACKTOP - PGSIZE, PTE_U | PTE_W);
f01039e9:	6a 06                	push   $0x6
f01039eb:	68 00 d0 bf ee       	push   $0xeebfd000
f01039f0:	50                   	push   %eax
f01039f1:	ff 77 60             	pushl  0x60(%edi)
f01039f4:	e8 46 dd ff ff       	call   f010173f <page_insert>
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
f0103a09:	68 ec 65 10 f0       	push   $0xf01065ec
f0103a0e:	68 88 01 00 00       	push   $0x188
f0103a13:	68 33 7a 10 f0       	push   $0xf0107a33
f0103a18:	e8 77 c6 ff ff       	call   f0100094 <_panic>
		panic("No free page for allocation.");
f0103a1d:	83 ec 04             	sub    $0x4,%esp
f0103a20:	68 6b 7a 10 f0       	push   $0xf0107a6b
f0103a25:	68 90 01 00 00       	push   $0x190
f0103a2a:	68 33 7a 10 f0       	push   $0xf0107a33
f0103a2f:	e8 60 c6 ff ff       	call   f0100094 <_panic>
		panic("Page insertion result: %e", r);
f0103a34:	50                   	push   %eax
f0103a35:	68 88 7a 10 f0       	push   $0xf0107a88
f0103a3a:	68 93 01 00 00       	push   $0x193
f0103a3f:	68 33 7a 10 f0       	push   $0xf0107a33
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
f0103a52:	e8 df 23 00 00       	call   f0105e36 <cpunum>
f0103a57:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103a5a:	01 c2                	add    %eax,%edx
f0103a5c:	01 d2                	add    %edx,%edx
f0103a5e:	01 c2                	add    %eax,%edx
f0103a60:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a63:	8b 55 08             	mov    0x8(%ebp),%edx
f0103a66:	39 14 85 28 20 29 f0 	cmp    %edx,-0xfd6dfd8(,%eax,4)
f0103a6d:	75 14                	jne    f0103a83 <env_free+0x3a>
		lcr3(PADDR(kern_pgdir));
f0103a6f:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
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
f0103a89:	e8 a8 23 00 00       	call   f0105e36 <cpunum>
f0103a8e:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103a91:	01 c2                	add    %eax,%edx
f0103a93:	01 d2                	add    %edx,%edx
f0103a95:	01 c2                	add    %eax,%edx
f0103a97:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a9a:	83 3c 85 28 20 29 f0 	cmpl   $0x0,-0xfd6dfd8(,%eax,4)
f0103aa1:	00 
f0103aa2:	74 51                	je     f0103af5 <env_free+0xac>
f0103aa4:	e8 8d 23 00 00       	call   f0105e36 <cpunum>
f0103aa9:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103aac:	01 c2                	add    %eax,%edx
f0103aae:	01 d2                	add    %edx,%edx
f0103ab0:	01 c2                	add    %eax,%edx
f0103ab2:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ab5:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f0103abc:	8b 40 48             	mov    0x48(%eax),%eax
f0103abf:	83 ec 04             	sub    $0x4,%esp
f0103ac2:	53                   	push   %ebx
f0103ac3:	50                   	push   %eax
f0103ac4:	68 a2 7a 10 f0       	push   $0xf0107aa2
f0103ac9:	e8 c5 04 00 00       	call   f0103f93 <cprintf>
f0103ace:	83 c4 10             	add    $0x10,%esp
f0103ad1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0103ad8:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103adb:	e9 96 00 00 00       	jmp    f0103b76 <env_free+0x12d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ae0:	50                   	push   %eax
f0103ae1:	68 ec 65 10 f0       	push   $0xf01065ec
f0103ae6:	68 b8 01 00 00       	push   $0x1b8
f0103aeb:	68 33 7a 10 f0       	push   $0xf0107a33
f0103af0:	e8 9f c5 ff ff       	call   f0100094 <_panic>
f0103af5:	b8 00 00 00 00       	mov    $0x0,%eax
f0103afa:	eb c3                	jmp    f0103abf <env_free+0x76>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103afc:	50                   	push   %eax
f0103afd:	68 c8 65 10 f0       	push   $0xf01065c8
f0103b02:	68 c7 01 00 00       	push   $0x1c7
f0103b07:	68 33 7a 10 f0       	push   $0xf0107a33
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
f0103b2f:	e8 b1 db ff ff       	call   f01016e5 <page_remove>
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
f0103b49:	3b 05 88 1e 29 f0    	cmp    0xf0291e88,%eax
f0103b4f:	73 6a                	jae    f0103bbb <env_free+0x172>
		page_decref(pa2page(pa));
f0103b51:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103b54:	a1 90 1e 29 f0       	mov    0xf0291e90,%eax
f0103b59:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103b5c:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103b5f:	50                   	push   %eax
f0103b60:	e8 45 d9 ff ff       	call   f01014aa <page_decref>
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
f0103b90:	39 15 88 1e 29 f0    	cmp    %edx,0xf0291e88
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
f0103bbe:	68 64 6e 10 f0       	push   $0xf0106e64
f0103bc3:	6a 51                	push   $0x51
f0103bc5:	68 a9 76 10 f0       	push   $0xf01076a9
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
f0103bee:	3b 05 88 1e 29 f0    	cmp    0xf0291e88,%eax
f0103bf4:	73 4d                	jae    f0103c43 <env_free+0x1fa>
	page_decref(pa2page(pa));
f0103bf6:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103bf9:	8b 15 90 1e 29 f0    	mov    0xf0291e90,%edx
f0103bff:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103c02:	50                   	push   %eax
f0103c03:	e8 a2 d8 ff ff       	call   f01014aa <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103c08:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c0b:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f0103c12:	a1 4c 12 29 f0       	mov    0xf029124c,%eax
f0103c17:	8b 55 08             	mov    0x8(%ebp),%edx
f0103c1a:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f0103c1d:	89 15 4c 12 29 f0    	mov    %edx,0xf029124c
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
f0103c2f:	68 ec 65 10 f0       	push   $0xf01065ec
f0103c34:	68 d5 01 00 00       	push   $0x1d5
f0103c39:	68 33 7a 10 f0       	push   $0xf0107a33
f0103c3e:	e8 51 c4 ff ff       	call   f0100094 <_panic>
		panic("pa2page called with invalid pa");
f0103c43:	83 ec 04             	sub    $0x4,%esp
f0103c46:	68 64 6e 10 f0       	push   $0xf0106e64
f0103c4b:	6a 51                	push   $0x51
f0103c4d:	68 a9 76 10 f0       	push   $0xf01076a9
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
f0103c70:	e8 c1 21 00 00       	call   f0105e36 <cpunum>
f0103c75:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103c78:	01 c2                	add    %eax,%edx
f0103c7a:	01 d2                	add    %edx,%edx
f0103c7c:	01 c2                	add    %eax,%edx
f0103c7e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c81:	83 c4 10             	add    $0x10,%esp
f0103c84:	39 1c 85 28 20 29 f0 	cmp    %ebx,-0xfd6dfd8(,%eax,4)
f0103c8b:	74 28                	je     f0103cb5 <env_destroy+0x5e>
		curenv = NULL;
		sched_yield();
	}
}
f0103c8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103c90:	c9                   	leave  
f0103c91:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103c92:	e8 9f 21 00 00       	call   f0105e36 <cpunum>
f0103c97:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103c9a:	01 c2                	add    %eax,%edx
f0103c9c:	01 d2                	add    %edx,%edx
f0103c9e:	01 c2                	add    %eax,%edx
f0103ca0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ca3:	39 1c 85 28 20 29 f0 	cmp    %ebx,-0xfd6dfd8(,%eax,4)
f0103caa:	74 bb                	je     f0103c67 <env_destroy+0x10>
		e->env_status = ENV_DYING;
f0103cac:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103cb3:	eb d8                	jmp    f0103c8d <env_destroy+0x36>
		curenv = NULL;
f0103cb5:	e8 7c 21 00 00       	call   f0105e36 <cpunum>
f0103cba:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cbd:	c7 80 28 20 29 f0 00 	movl   $0x0,-0xfd6dfd8(%eax)
f0103cc4:	00 00 00 
		sched_yield();
f0103cc7:	e8 37 0d 00 00       	call   f0104a03 <sched_yield>

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
f0103cd3:	e8 5e 21 00 00       	call   f0105e36 <cpunum>
f0103cd8:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103cdb:	01 c2                	add    %eax,%edx
f0103cdd:	01 d2                	add    %edx,%edx
f0103cdf:	01 c2                	add    %eax,%edx
f0103ce1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ce4:	8b 1c 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%ebx
f0103ceb:	e8 46 21 00 00       	call   f0105e36 <cpunum>
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
f0103d00:	68 b8 7a 10 f0       	push   $0xf0107ab8
f0103d05:	68 0c 02 00 00       	push   $0x20c
f0103d0a:	68 33 7a 10 f0       	push   $0xf0107a33
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
f0103d1a:	e8 17 21 00 00       	call   f0105e36 <cpunum>
f0103d1f:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103d22:	01 c2                	add    %eax,%edx
f0103d24:	01 d2                	add    %edx,%edx
f0103d26:	01 c2                	add    %eax,%edx
f0103d28:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d2b:	83 3c 85 28 20 29 f0 	cmpl   $0x0,-0xfd6dfd8(,%eax,4)
f0103d32:	00 
f0103d33:	74 18                	je     f0103d4d <env_run+0x39>
f0103d35:	e8 fc 20 00 00       	call   f0105e36 <cpunum>
f0103d3a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d3d:	8b 80 28 20 29 f0    	mov    -0xfd6dfd8(%eax),%eax
f0103d43:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103d47:	0f 84 8c 00 00 00    	je     f0103dd9 <env_run+0xc5>
		curenv->env_status = ENV_RUNNABLE;
	}

	curenv = e;
f0103d4d:	e8 e4 20 00 00       	call   f0105e36 <cpunum>
f0103d52:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103d55:	01 c2                	add    %eax,%edx
f0103d57:	01 d2                	add    %edx,%edx
f0103d59:	01 c2                	add    %eax,%edx
f0103d5b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d5e:	8b 55 08             	mov    0x8(%ebp),%edx
f0103d61:	89 14 85 28 20 29 f0 	mov    %edx,-0xfd6dfd8(,%eax,4)
	curenv->env_status = ENV_RUNNING;
f0103d68:	e8 c9 20 00 00       	call   f0105e36 <cpunum>
f0103d6d:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103d70:	01 c2                	add    %eax,%edx
f0103d72:	01 d2                	add    %edx,%edx
f0103d74:	01 c2                	add    %eax,%edx
f0103d76:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d79:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f0103d80:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++; // Incremetn run count
f0103d87:	e8 aa 20 00 00       	call   f0105e36 <cpunum>
f0103d8c:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103d8f:	01 c2                	add    %eax,%edx
f0103d91:	01 d2                	add    %edx,%edx
f0103d93:	01 c2                	add    %eax,%edx
f0103d95:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d98:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f0103d9f:	ff 40 58             	incl   0x58(%eax)

	// Jump to user env pgdir
	lcr3(PADDR(curenv->env_pgdir));
f0103da2:	e8 8f 20 00 00       	call   f0105e36 <cpunum>
f0103da7:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103daa:	01 c2                	add    %eax,%edx
f0103dac:	01 d2                	add    %edx,%edx
f0103dae:	01 c2                	add    %eax,%edx
f0103db0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103db3:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f0103dba:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103dbd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103dc2:	77 2f                	ja     f0103df3 <env_run+0xdf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103dc4:	50                   	push   %eax
f0103dc5:	68 ec 65 10 f0       	push   $0xf01065ec
f0103dca:	68 33 02 00 00       	push   $0x233
f0103dcf:	68 33 7a 10 f0       	push   $0xf0107a33
f0103dd4:	e8 bb c2 ff ff       	call   f0100094 <_panic>
		curenv->env_status = ENV_RUNNABLE;
f0103dd9:	e8 58 20 00 00       	call   f0105e36 <cpunum>
f0103dde:	6b c0 74             	imul   $0x74,%eax,%eax
f0103de1:	8b 80 28 20 29 f0    	mov    -0xfd6dfd8(%eax),%eax
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
f0103e03:	e8 4f 23 00 00       	call   f0106157 <spin_unlock>

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
f0103e0a:	e8 27 20 00 00       	call   f0105e36 <cpunum>
f0103e0f:	83 c4 04             	add    $0x4,%esp
f0103e12:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e15:	ff b0 28 20 29 f0    	pushl  -0xfd6dfd8(%eax)
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
f0103e5c:	80 3d 50 12 29 f0 00 	cmpb   $0x0,0xf0291250
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
f0103e81:	68 c4 7a 10 f0       	push   $0xf0107ac4
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
f0103eae:	68 93 7f 10 f0       	push   $0xf0107f93
f0103eb3:	e8 db 00 00 00       	call   f0103f93 <cprintf>
f0103eb8:	83 c4 10             	add    $0x10,%esp
f0103ebb:	eb dd                	jmp    f0103e9a <irq_setmask_8259A+0x4c>
	cprintf("\n");
f0103ebd:	83 ec 0c             	sub    $0xc,%esp
f0103ec0:	68 1b 69 10 f0       	push   $0xf010691b
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
f0103ed8:	c6 05 50 12 29 f0 01 	movb   $0x1,0xf0291250
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
f0103f63:	e8 d2 c8 ff ff       	call   f010083a <cputchar>
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
f0103f89:	e8 b5 10 00 00       	call   f0105043 <vprintfmt>
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
f0103fb0:	e8 81 1e 00 00       	call   f0105e36 <cpunum>
f0103fb5:	89 c6                	mov    %eax,%esi
f0103fb7:	8d 1c 00             	lea    (%eax,%eax,1),%ebx
f0103fba:	01 c3                	add    %eax,%ebx
f0103fbc:	01 db                	add    %ebx,%ebx
f0103fbe:	01 c3                	add    %eax,%ebx
f0103fc0:	c1 e3 02             	shl    $0x2,%ebx
f0103fc3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0103fc6:	8d 3c 85 2c 20 29 f0 	lea    -0xfd6dfd4(,%eax,4),%edi
	ts->ts_esp0 = KSTACKTOP - cpunum() * (KSTKSIZE + KSTKGAP);
f0103fcd:	e8 64 1e 00 00       	call   f0105e36 <cpunum>
f0103fd2:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f0103fd5:	8d 14 95 20 20 29 f0 	lea    -0xfd6dfe0(,%edx,4),%edx
f0103fdc:	c1 e0 10             	shl    $0x10,%eax
f0103fdf:	89 c1                	mov    %eax,%ecx
f0103fe1:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f0103fe6:	29 c8                	sub    %ecx,%eax
f0103fe8:	89 42 10             	mov    %eax,0x10(%edx)
	ts->ts_ss0 = GD_KD;
f0103feb:	66 c7 42 14 10 00    	movw   $0x10,0x14(%edx)
	ts->ts_iomb = sizeof(struct Taskstate);
f0103ff1:	01 f3                	add    %esi,%ebx
f0103ff3:	66 c7 04 9d 92 20 29 	movw   $0x68,-0xfd6df6e(,%ebx,4)
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
f010404d:	b8 9e 48 10 f0       	mov    $0xf010489e,%eax
f0104052:	66 a3 60 12 29 f0    	mov    %ax,0xf0291260
f0104058:	66 c7 05 62 12 29 f0 	movw   $0x8,0xf0291262
f010405f:	08 00 
f0104061:	c6 05 64 12 29 f0 00 	movb   $0x0,0xf0291264
f0104068:	c6 05 65 12 29 f0 8f 	movb   $0x8f,0xf0291265
f010406f:	c1 e8 10             	shr    $0x10,%eax
f0104072:	66 a3 66 12 29 f0    	mov    %ax,0xf0291266
	SETGATE(idt[T_DEBUG]  , 1, GD_KT, (void*)H_DEBUG  ,0);  
f0104078:	b8 a4 48 10 f0       	mov    $0xf01048a4,%eax
f010407d:	66 a3 68 12 29 f0    	mov    %ax,0xf0291268
f0104083:	66 c7 05 6a 12 29 f0 	movw   $0x8,0xf029126a
f010408a:	08 00 
f010408c:	c6 05 6c 12 29 f0 00 	movb   $0x0,0xf029126c
f0104093:	c6 05 6d 12 29 f0 8f 	movb   $0x8f,0xf029126d
f010409a:	c1 e8 10             	shr    $0x10,%eax
f010409d:	66 a3 6e 12 29 f0    	mov    %ax,0xf029126e
	SETGATE(idt[T_NMI]    , 1, GD_KT, (void*)H_NMI    ,0);
f01040a3:	b8 aa 48 10 f0       	mov    $0xf01048aa,%eax
f01040a8:	66 a3 70 12 29 f0    	mov    %ax,0xf0291270
f01040ae:	66 c7 05 72 12 29 f0 	movw   $0x8,0xf0291272
f01040b5:	08 00 
f01040b7:	c6 05 74 12 29 f0 00 	movb   $0x0,0xf0291274
f01040be:	c6 05 75 12 29 f0 8f 	movb   $0x8f,0xf0291275
f01040c5:	c1 e8 10             	shr    $0x10,%eax
f01040c8:	66 a3 76 12 29 f0    	mov    %ax,0xf0291276
	SETGATE(idt[T_BRKPT]  , 1, GD_KT, (void*)H_BRKPT  ,3);  // User level previlege (3)
f01040ce:	b8 b0 48 10 f0       	mov    $0xf01048b0,%eax
f01040d3:	66 a3 78 12 29 f0    	mov    %ax,0xf0291278
f01040d9:	66 c7 05 7a 12 29 f0 	movw   $0x8,0xf029127a
f01040e0:	08 00 
f01040e2:	c6 05 7c 12 29 f0 00 	movb   $0x0,0xf029127c
f01040e9:	c6 05 7d 12 29 f0 ef 	movb   $0xef,0xf029127d
f01040f0:	c1 e8 10             	shr    $0x10,%eax
f01040f3:	66 a3 7e 12 29 f0    	mov    %ax,0xf029127e
	SETGATE(idt[T_OFLOW]  , 1, GD_KT, (void*)H_OFLOW  ,0);  
f01040f9:	b8 b6 48 10 f0       	mov    $0xf01048b6,%eax
f01040fe:	66 a3 80 12 29 f0    	mov    %ax,0xf0291280
f0104104:	66 c7 05 82 12 29 f0 	movw   $0x8,0xf0291282
f010410b:	08 00 
f010410d:	c6 05 84 12 29 f0 00 	movb   $0x0,0xf0291284
f0104114:	c6 05 85 12 29 f0 8f 	movb   $0x8f,0xf0291285
f010411b:	c1 e8 10             	shr    $0x10,%eax
f010411e:	66 a3 86 12 29 f0    	mov    %ax,0xf0291286
	SETGATE(idt[T_BOUND]  , 1, GD_KT, (void*)H_BOUND  ,0);  
f0104124:	b8 bc 48 10 f0       	mov    $0xf01048bc,%eax
f0104129:	66 a3 88 12 29 f0    	mov    %ax,0xf0291288
f010412f:	66 c7 05 8a 12 29 f0 	movw   $0x8,0xf029128a
f0104136:	08 00 
f0104138:	c6 05 8c 12 29 f0 00 	movb   $0x0,0xf029128c
f010413f:	c6 05 8d 12 29 f0 8f 	movb   $0x8f,0xf029128d
f0104146:	c1 e8 10             	shr    $0x10,%eax
f0104149:	66 a3 8e 12 29 f0    	mov    %ax,0xf029128e
	SETGATE(idt[T_ILLOP]  , 1, GD_KT, (void*)H_ILLOP  ,0);  
f010414f:	b8 c2 48 10 f0       	mov    $0xf01048c2,%eax
f0104154:	66 a3 90 12 29 f0    	mov    %ax,0xf0291290
f010415a:	66 c7 05 92 12 29 f0 	movw   $0x8,0xf0291292
f0104161:	08 00 
f0104163:	c6 05 94 12 29 f0 00 	movb   $0x0,0xf0291294
f010416a:	c6 05 95 12 29 f0 8f 	movb   $0x8f,0xf0291295
f0104171:	c1 e8 10             	shr    $0x10,%eax
f0104174:	66 a3 96 12 29 f0    	mov    %ax,0xf0291296
	SETGATE(idt[T_DEVICE] , 1, GD_KT, (void*)H_DEVICE ,0);   
f010417a:	b8 c8 48 10 f0       	mov    $0xf01048c8,%eax
f010417f:	66 a3 98 12 29 f0    	mov    %ax,0xf0291298
f0104185:	66 c7 05 9a 12 29 f0 	movw   $0x8,0xf029129a
f010418c:	08 00 
f010418e:	c6 05 9c 12 29 f0 00 	movb   $0x0,0xf029129c
f0104195:	c6 05 9d 12 29 f0 8f 	movb   $0x8f,0xf029129d
f010419c:	c1 e8 10             	shr    $0x10,%eax
f010419f:	66 a3 9e 12 29 f0    	mov    %ax,0xf029129e
	SETGATE(idt[T_DBLFLT] , 1, GD_KT, (void*)H_DBLFLT ,0);   
f01041a5:	b8 ce 48 10 f0       	mov    $0xf01048ce,%eax
f01041aa:	66 a3 a0 12 29 f0    	mov    %ax,0xf02912a0
f01041b0:	66 c7 05 a2 12 29 f0 	movw   $0x8,0xf02912a2
f01041b7:	08 00 
f01041b9:	c6 05 a4 12 29 f0 00 	movb   $0x0,0xf02912a4
f01041c0:	c6 05 a5 12 29 f0 8f 	movb   $0x8f,0xf02912a5
f01041c7:	c1 e8 10             	shr    $0x10,%eax
f01041ca:	66 a3 a6 12 29 f0    	mov    %ax,0xf02912a6
	SETGATE(idt[T_TSS]    , 1, GD_KT, (void*)H_TSS    ,0);
f01041d0:	b8 d2 48 10 f0       	mov    $0xf01048d2,%eax
f01041d5:	66 a3 b0 12 29 f0    	mov    %ax,0xf02912b0
f01041db:	66 c7 05 b2 12 29 f0 	movw   $0x8,0xf02912b2
f01041e2:	08 00 
f01041e4:	c6 05 b4 12 29 f0 00 	movb   $0x0,0xf02912b4
f01041eb:	c6 05 b5 12 29 f0 8f 	movb   $0x8f,0xf02912b5
f01041f2:	c1 e8 10             	shr    $0x10,%eax
f01041f5:	66 a3 b6 12 29 f0    	mov    %ax,0xf02912b6
	SETGATE(idt[T_SEGNP]  , 1, GD_KT, (void*)H_SEGNP  ,0);  
f01041fb:	b8 d6 48 10 f0       	mov    $0xf01048d6,%eax
f0104200:	66 a3 b8 12 29 f0    	mov    %ax,0xf02912b8
f0104206:	66 c7 05 ba 12 29 f0 	movw   $0x8,0xf02912ba
f010420d:	08 00 
f010420f:	c6 05 bc 12 29 f0 00 	movb   $0x0,0xf02912bc
f0104216:	c6 05 bd 12 29 f0 8f 	movb   $0x8f,0xf02912bd
f010421d:	c1 e8 10             	shr    $0x10,%eax
f0104220:	66 a3 be 12 29 f0    	mov    %ax,0xf02912be
	SETGATE(idt[T_STACK]  , 1, GD_KT, (void*)H_STACK  ,0);  
f0104226:	b8 da 48 10 f0       	mov    $0xf01048da,%eax
f010422b:	66 a3 c0 12 29 f0    	mov    %ax,0xf02912c0
f0104231:	66 c7 05 c2 12 29 f0 	movw   $0x8,0xf02912c2
f0104238:	08 00 
f010423a:	c6 05 c4 12 29 f0 00 	movb   $0x0,0xf02912c4
f0104241:	c6 05 c5 12 29 f0 8f 	movb   $0x8f,0xf02912c5
f0104248:	c1 e8 10             	shr    $0x10,%eax
f010424b:	66 a3 c6 12 29 f0    	mov    %ax,0xf02912c6
	SETGATE(idt[T_GPFLT]  , 1, GD_KT, (void*)H_GPFLT  ,0);  
f0104251:	b8 de 48 10 f0       	mov    $0xf01048de,%eax
f0104256:	66 a3 c8 12 29 f0    	mov    %ax,0xf02912c8
f010425c:	66 c7 05 ca 12 29 f0 	movw   $0x8,0xf02912ca
f0104263:	08 00 
f0104265:	c6 05 cc 12 29 f0 00 	movb   $0x0,0xf02912cc
f010426c:	c6 05 cd 12 29 f0 8f 	movb   $0x8f,0xf02912cd
f0104273:	c1 e8 10             	shr    $0x10,%eax
f0104276:	66 a3 ce 12 29 f0    	mov    %ax,0xf02912ce
	SETGATE(idt[T_PGFLT]  , 1, GD_KT, (void*)H_PGFLT  ,0);  
f010427c:	b8 e2 48 10 f0       	mov    $0xf01048e2,%eax
f0104281:	66 a3 d0 12 29 f0    	mov    %ax,0xf02912d0
f0104287:	66 c7 05 d2 12 29 f0 	movw   $0x8,0xf02912d2
f010428e:	08 00 
f0104290:	c6 05 d4 12 29 f0 00 	movb   $0x0,0xf02912d4
f0104297:	c6 05 d5 12 29 f0 8f 	movb   $0x8f,0xf02912d5
f010429e:	c1 e8 10             	shr    $0x10,%eax
f01042a1:	66 a3 d6 12 29 f0    	mov    %ax,0xf02912d6
	SETGATE(idt[T_FPERR]  , 1, GD_KT, (void*)H_FPERR  ,0);  
f01042a7:	b8 e6 48 10 f0       	mov    $0xf01048e6,%eax
f01042ac:	66 a3 e0 12 29 f0    	mov    %ax,0xf02912e0
f01042b2:	66 c7 05 e2 12 29 f0 	movw   $0x8,0xf02912e2
f01042b9:	08 00 
f01042bb:	c6 05 e4 12 29 f0 00 	movb   $0x0,0xf02912e4
f01042c2:	c6 05 e5 12 29 f0 8f 	movb   $0x8f,0xf02912e5
f01042c9:	c1 e8 10             	shr    $0x10,%eax
f01042cc:	66 a3 e6 12 29 f0    	mov    %ax,0xf02912e6
	SETGATE(idt[T_ALIGN]  , 1, GD_KT, (void*)H_ALIGN  ,0);  
f01042d2:	b8 ec 48 10 f0       	mov    $0xf01048ec,%eax
f01042d7:	66 a3 e8 12 29 f0    	mov    %ax,0xf02912e8
f01042dd:	66 c7 05 ea 12 29 f0 	movw   $0x8,0xf02912ea
f01042e4:	08 00 
f01042e6:	c6 05 ec 12 29 f0 00 	movb   $0x0,0xf02912ec
f01042ed:	c6 05 ed 12 29 f0 8f 	movb   $0x8f,0xf02912ed
f01042f4:	c1 e8 10             	shr    $0x10,%eax
f01042f7:	66 a3 ee 12 29 f0    	mov    %ax,0xf02912ee
	SETGATE(idt[T_MCHK]   , 1, GD_KT, (void*)H_MCHK   ,0); 
f01042fd:	b8 f2 48 10 f0       	mov    $0xf01048f2,%eax
f0104302:	66 a3 f0 12 29 f0    	mov    %ax,0xf02912f0
f0104308:	66 c7 05 f2 12 29 f0 	movw   $0x8,0xf02912f2
f010430f:	08 00 
f0104311:	c6 05 f4 12 29 f0 00 	movb   $0x0,0xf02912f4
f0104318:	c6 05 f5 12 29 f0 8f 	movb   $0x8f,0xf02912f5
f010431f:	c1 e8 10             	shr    $0x10,%eax
f0104322:	66 a3 f6 12 29 f0    	mov    %ax,0xf02912f6
	SETGATE(idt[T_SIMDERR], 1, GD_KT, (void*)H_SIMDERR,0);  
f0104328:	b8 f8 48 10 f0       	mov    $0xf01048f8,%eax
f010432d:	66 a3 f8 12 29 f0    	mov    %ax,0xf02912f8
f0104333:	66 c7 05 fa 12 29 f0 	movw   $0x8,0xf02912fa
f010433a:	08 00 
f010433c:	c6 05 fc 12 29 f0 00 	movb   $0x0,0xf02912fc
f0104343:	c6 05 fd 12 29 f0 8f 	movb   $0x8f,0xf02912fd
f010434a:	c1 e8 10             	shr    $0x10,%eax
f010434d:	66 a3 fe 12 29 f0    	mov    %ax,0xf02912fe
	SETGATE(idt[T_SYSCALL], 1, GD_KT, (void*)H_SYSCALL,3);  // System call
f0104353:	b8 fe 48 10 f0       	mov    $0xf01048fe,%eax
f0104358:	66 a3 e0 13 29 f0    	mov    %ax,0xf02913e0
f010435e:	66 c7 05 e2 13 29 f0 	movw   $0x8,0xf02913e2
f0104365:	08 00 
f0104367:	c6 05 e4 13 29 f0 00 	movb   $0x0,0xf02913e4
f010436e:	c6 05 e5 13 29 f0 ef 	movb   $0xef,0xf02913e5
f0104375:	c1 e8 10             	shr    $0x10,%eax
f0104378:	66 a3 e6 13 29 f0    	mov    %ax,0xf02913e6
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
f0104391:	68 d8 7a 10 f0       	push   $0xf0107ad8
f0104396:	e8 f8 fb ff ff       	call   f0103f93 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010439b:	83 c4 08             	add    $0x8,%esp
f010439e:	ff 73 04             	pushl  0x4(%ebx)
f01043a1:	68 e7 7a 10 f0       	push   $0xf0107ae7
f01043a6:	e8 e8 fb ff ff       	call   f0103f93 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01043ab:	83 c4 08             	add    $0x8,%esp
f01043ae:	ff 73 08             	pushl  0x8(%ebx)
f01043b1:	68 f6 7a 10 f0       	push   $0xf0107af6
f01043b6:	e8 d8 fb ff ff       	call   f0103f93 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01043bb:	83 c4 08             	add    $0x8,%esp
f01043be:	ff 73 0c             	pushl  0xc(%ebx)
f01043c1:	68 05 7b 10 f0       	push   $0xf0107b05
f01043c6:	e8 c8 fb ff ff       	call   f0103f93 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01043cb:	83 c4 08             	add    $0x8,%esp
f01043ce:	ff 73 10             	pushl  0x10(%ebx)
f01043d1:	68 14 7b 10 f0       	push   $0xf0107b14
f01043d6:	e8 b8 fb ff ff       	call   f0103f93 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01043db:	83 c4 08             	add    $0x8,%esp
f01043de:	ff 73 14             	pushl  0x14(%ebx)
f01043e1:	68 23 7b 10 f0       	push   $0xf0107b23
f01043e6:	e8 a8 fb ff ff       	call   f0103f93 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01043eb:	83 c4 08             	add    $0x8,%esp
f01043ee:	ff 73 18             	pushl  0x18(%ebx)
f01043f1:	68 32 7b 10 f0       	push   $0xf0107b32
f01043f6:	e8 98 fb ff ff       	call   f0103f93 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01043fb:	83 c4 08             	add    $0x8,%esp
f01043fe:	ff 73 1c             	pushl  0x1c(%ebx)
f0104401:	68 41 7b 10 f0       	push   $0xf0107b41
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
f010441d:	e8 14 1a 00 00       	call   f0105e36 <cpunum>
f0104422:	83 ec 04             	sub    $0x4,%esp
f0104425:	50                   	push   %eax
f0104426:	53                   	push   %ebx
f0104427:	68 a5 7b 10 f0       	push   $0xf0107ba5
f010442c:	e8 62 fb ff ff       	call   f0103f93 <cprintf>
	print_regs(&tf->tf_regs);
f0104431:	89 1c 24             	mov    %ebx,(%esp)
f0104434:	e8 4c ff ff ff       	call   f0104385 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104439:	83 c4 08             	add    $0x8,%esp
f010443c:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104440:	50                   	push   %eax
f0104441:	68 c3 7b 10 f0       	push   $0xf0107bc3
f0104446:	e8 48 fb ff ff       	call   f0103f93 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010444b:	83 c4 08             	add    $0x8,%esp
f010444e:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0104452:	50                   	push   %eax
f0104453:	68 d6 7b 10 f0       	push   $0xf0107bd6
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
f010447d:	ba 6f 7b 10 f0       	mov    $0xf0107b6f,%edx
f0104482:	eb 07                	jmp    f010448b <print_trapframe+0x78>
		return excnames[trapno];
f0104484:	8b 14 85 80 7e 10 f0 	mov    -0xfef8180(,%eax,4),%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010448b:	83 ec 04             	sub    $0x4,%esp
f010448e:	52                   	push   %edx
f010448f:	50                   	push   %eax
f0104490:	68 e9 7b 10 f0       	push   $0xf0107be9
f0104495:	e8 f9 fa ff ff       	call   f0103f93 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010449a:	83 c4 10             	add    $0x10,%esp
f010449d:	39 1d 60 1a 29 f0    	cmp    %ebx,0xf0291a60
f01044a3:	0f 84 ab 00 00 00    	je     f0104554 <print_trapframe+0x141>
	cprintf("  err  0x%08x", tf->tf_err);
f01044a9:	83 ec 08             	sub    $0x8,%esp
f01044ac:	ff 73 2c             	pushl  0x2c(%ebx)
f01044af:	68 0a 7c 10 f0       	push   $0xf0107c0a
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
f01044d1:	b9 89 7b 10 f0       	mov    $0xf0107b89,%ecx
f01044d6:	a8 02                	test   $0x2,%al
f01044d8:	0f 85 a3 00 00 00    	jne    f0104581 <print_trapframe+0x16e>
f01044de:	ba 9b 7b 10 f0       	mov    $0xf0107b9b,%edx
f01044e3:	a8 04                	test   $0x4,%al
f01044e5:	0f 85 a0 00 00 00    	jne    f010458b <print_trapframe+0x178>
f01044eb:	b8 d5 7c 10 f0       	mov    $0xf0107cd5,%eax
f01044f0:	51                   	push   %ecx
f01044f1:	52                   	push   %edx
f01044f2:	50                   	push   %eax
f01044f3:	68 18 7c 10 f0       	push   $0xf0107c18
f01044f8:	e8 96 fa ff ff       	call   f0103f93 <cprintf>
f01044fd:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104500:	83 ec 08             	sub    $0x8,%esp
f0104503:	ff 73 30             	pushl  0x30(%ebx)
f0104506:	68 27 7c 10 f0       	push   $0xf0107c27
f010450b:	e8 83 fa ff ff       	call   f0103f93 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104510:	83 c4 08             	add    $0x8,%esp
f0104513:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104517:	50                   	push   %eax
f0104518:	68 36 7c 10 f0       	push   $0xf0107c36
f010451d:	e8 71 fa ff ff       	call   f0103f93 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104522:	83 c4 08             	add    $0x8,%esp
f0104525:	ff 73 38             	pushl  0x38(%ebx)
f0104528:	68 49 7c 10 f0       	push   $0xf0107c49
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
f0104540:	ba 50 7b 10 f0       	mov    $0xf0107b50,%edx
f0104545:	e9 41 ff ff ff       	jmp    f010448b <print_trapframe+0x78>
		return "Hardware Interrupt";
f010454a:	ba 5c 7b 10 f0       	mov    $0xf0107b5c,%edx
f010454f:	e9 37 ff ff ff       	jmp    f010448b <print_trapframe+0x78>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104554:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104558:	0f 85 4b ff ff ff    	jne    f01044a9 <print_trapframe+0x96>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010455e:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104561:	83 ec 08             	sub    $0x8,%esp
f0104564:	50                   	push   %eax
f0104565:	68 fb 7b 10 f0       	push   $0xf0107bfb
f010456a:	e8 24 fa ff ff       	call   f0103f93 <cprintf>
f010456f:	83 c4 10             	add    $0x10,%esp
f0104572:	e9 32 ff ff ff       	jmp    f01044a9 <print_trapframe+0x96>
		cprintf(" [%s, %s, %s]\n",
f0104577:	b9 7e 7b 10 f0       	mov    $0xf0107b7e,%ecx
f010457c:	e9 55 ff ff ff       	jmp    f01044d6 <print_trapframe+0xc3>
f0104581:	ba 95 7b 10 f0       	mov    $0xf0107b95,%edx
f0104586:	e9 58 ff ff ff       	jmp    f01044e3 <print_trapframe+0xd0>
f010458b:	b8 a0 7b 10 f0       	mov    $0xf0107ba0,%eax
f0104590:	e9 5b ff ff ff       	jmp    f01044f0 <print_trapframe+0xdd>
		cprintf("\n");
f0104595:	83 ec 0c             	sub    $0xc,%esp
f0104598:	68 1b 69 10 f0       	push   $0xf010691b
f010459d:	e8 f1 f9 ff ff       	call   f0103f93 <cprintf>
f01045a2:	83 c4 10             	add    $0x10,%esp
f01045a5:	e9 56 ff ff ff       	jmp    f0104500 <print_trapframe+0xed>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01045aa:	83 ec 08             	sub    $0x8,%esp
f01045ad:	ff 73 3c             	pushl  0x3c(%ebx)
f01045b0:	68 58 7c 10 f0       	push   $0xf0107c58
f01045b5:	e8 d9 f9 ff ff       	call   f0103f93 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01045ba:	83 c4 08             	add    $0x8,%esp
f01045bd:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01045c1:	50                   	push   %eax
f01045c2:	68 67 7c 10 f0       	push   $0xf0107c67
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
f01045da:	83 ec 0c             	sub    $0xc,%esp
f01045dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01045e0:	0f 20 d6             	mov    %cr2,%esi

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	uint16_t cs = tf->tf_cs;
	if ((cs & 0xFF) == GD_KT) { // code segment descriptor is kernel
f01045e3:	80 7b 34 08          	cmpb   $0x8,0x34(%ebx)
f01045e7:	74 5d                	je     f0104646 <page_fault_handler+0x72>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01045e9:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01045ec:	e8 45 18 00 00       	call   f0105e36 <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01045f1:	57                   	push   %edi
f01045f2:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f01045f3:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01045f6:	01 c2                	add    %eax,%edx
f01045f8:	01 d2                	add    %edx,%edx
f01045fa:	01 c2                	add    %eax,%edx
f01045fc:	8d 04 90             	lea    (%eax,%edx,4),%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01045ff:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f0104606:	ff 70 48             	pushl  0x48(%eax)
f0104609:	68 4c 7e 10 f0       	push   $0xf0107e4c
f010460e:	e8 80 f9 ff ff       	call   f0103f93 <cprintf>
	print_trapframe(tf);
f0104613:	89 1c 24             	mov    %ebx,(%esp)
f0104616:	e8 f8 fd ff ff       	call   f0104413 <print_trapframe>
	env_destroy(curenv);
f010461b:	e8 16 18 00 00       	call   f0105e36 <cpunum>
f0104620:	83 c4 04             	add    $0x4,%esp
f0104623:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104626:	01 c2                	add    %eax,%edx
f0104628:	01 d2                	add    %edx,%edx
f010462a:	01 c2                	add    %eax,%edx
f010462c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010462f:	ff 34 85 28 20 29 f0 	pushl  -0xfd6dfd8(,%eax,4)
f0104636:	e8 1c f6 ff ff       	call   f0103c57 <env_destroy>
}
f010463b:	83 c4 10             	add    $0x10,%esp
f010463e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104641:	5b                   	pop    %ebx
f0104642:	5e                   	pop    %esi
f0104643:	5f                   	pop    %edi
f0104644:	5d                   	pop    %ebp
f0104645:	c3                   	ret    
		print_trapframe(tf);
f0104646:	83 ec 0c             	sub    $0xc,%esp
f0104649:	53                   	push   %ebx
f010464a:	e8 c4 fd ff ff       	call   f0104413 <print_trapframe>
		panic("Page fault in kernel mode! Fault addr: %p", fault_va);
f010464f:	56                   	push   %esi
f0104650:	68 20 7e 10 f0       	push   $0xf0107e20
f0104655:	68 3f 01 00 00       	push   $0x13f
f010465a:	68 7a 7c 10 f0       	push   $0xf0107c7a
f010465f:	e8 30 ba ff ff       	call   f0100094 <_panic>

f0104664 <trap>:
{
f0104664:	55                   	push   %ebp
f0104665:	89 e5                	mov    %esp,%ebp
f0104667:	57                   	push   %edi
f0104668:	56                   	push   %esi
f0104669:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f010466c:	fc                   	cld    
	if (panicstr)
f010466d:	83 3d 80 1e 29 f0 00 	cmpl   $0x0,0xf0291e80
f0104674:	74 01                	je     f0104677 <trap+0x13>
		asm volatile("hlt");
f0104676:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104677:	e8 ba 17 00 00       	call   f0105e36 <cpunum>
f010467c:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010467f:	01 c2                	add    %eax,%edx
f0104681:	01 d2                	add    %edx,%edx
f0104683:	01 c2                	add    %eax,%edx
f0104685:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104688:	8d 14 85 04 00 00 00 	lea    0x4(,%eax,4),%edx
	asm volatile("lock; xchgl %0, %1"
f010468f:	b8 01 00 00 00       	mov    $0x1,%eax
f0104694:	f0 87 82 20 20 29 f0 	lock xchg %eax,-0xfd6dfe0(%edx)
f010469b:	83 f8 02             	cmp    $0x2,%eax
f010469e:	74 53                	je     f01046f3 <trap+0x8f>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01046a0:	9c                   	pushf  
f01046a1:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f01046a2:	f6 c4 02             	test   $0x2,%ah
f01046a5:	75 5e                	jne    f0104705 <trap+0xa1>
	if ((tf->tf_cs & 3) == 3) {
f01046a7:	66 8b 46 34          	mov    0x34(%esi),%ax
f01046ab:	83 e0 03             	and    $0x3,%eax
f01046ae:	66 83 f8 03          	cmp    $0x3,%ax
f01046b2:	74 6a                	je     f010471e <trap+0xba>
	last_tf = tf;
f01046b4:	89 35 60 1a 29 f0    	mov    %esi,0xf0291a60
	switch(tf->tf_trapno){
f01046ba:	8b 46 28             	mov    0x28(%esi),%eax
f01046bd:	83 f8 0e             	cmp    $0xe,%eax
f01046c0:	0f 84 fd 00 00 00    	je     f01047c3 <trap+0x15f>
f01046c6:	83 f8 30             	cmp    $0x30,%eax
f01046c9:	0f 84 2e 01 00 00    	je     f01047fd <trap+0x199>
f01046cf:	83 f8 03             	cmp    $0x3,%eax
f01046d2:	0f 85 46 01 00 00    	jne    f010481e <trap+0x1ba>
		print_trapframe(tf);
f01046d8:	83 ec 0c             	sub    $0xc,%esp
f01046db:	56                   	push   %esi
f01046dc:	e8 32 fd ff ff       	call   f0104413 <print_trapframe>
f01046e1:	83 c4 10             	add    $0x10,%esp
			monitor(NULL);
f01046e4:	83 ec 0c             	sub    $0xc,%esp
f01046e7:	6a 00                	push   $0x0
f01046e9:	e8 34 c7 ff ff       	call   f0100e22 <monitor>
f01046ee:	83 c4 10             	add    $0x10,%esp
f01046f1:	eb f1                	jmp    f01046e4 <trap+0x80>
	spin_lock(&kernel_lock);
f01046f3:	83 ec 0c             	sub    $0xc,%esp
f01046f6:	68 c0 23 12 f0       	push   $0xf01223c0
f01046fb:	e8 aa 19 00 00       	call   f01060aa <spin_lock>
f0104700:	83 c4 10             	add    $0x10,%esp
f0104703:	eb 9b                	jmp    f01046a0 <trap+0x3c>
	assert(!(read_eflags() & FL_IF));
f0104705:	68 86 7c 10 f0       	push   $0xf0107c86
f010470a:	68 c3 76 10 f0       	push   $0xf01076c3
f010470f:	68 0b 01 00 00       	push   $0x10b
f0104714:	68 7a 7c 10 f0       	push   $0xf0107c7a
f0104719:	e8 76 b9 ff ff       	call   f0100094 <_panic>
f010471e:	83 ec 0c             	sub    $0xc,%esp
f0104721:	68 c0 23 12 f0       	push   $0xf01223c0
f0104726:	e8 7f 19 00 00       	call   f01060aa <spin_lock>
		assert(curenv);
f010472b:	e8 06 17 00 00       	call   f0105e36 <cpunum>
f0104730:	6b c0 74             	imul   $0x74,%eax,%eax
f0104733:	83 c4 10             	add    $0x10,%esp
f0104736:	83 b8 28 20 29 f0 00 	cmpl   $0x0,-0xfd6dfd8(%eax)
f010473d:	75 19                	jne    f0104758 <trap+0xf4>
f010473f:	68 9f 7c 10 f0       	push   $0xf0107c9f
f0104744:	68 c3 76 10 f0       	push   $0xf01076c3
f0104749:	68 12 01 00 00       	push   $0x112
f010474e:	68 7a 7c 10 f0       	push   $0xf0107c7a
f0104753:	e8 3c b9 ff ff       	call   f0100094 <_panic>
		if (curenv->env_status == ENV_DYING) {
f0104758:	e8 d9 16 00 00       	call   f0105e36 <cpunum>
f010475d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104760:	8b 80 28 20 29 f0    	mov    -0xfd6dfd8(%eax),%eax
f0104766:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010476a:	74 2a                	je     f0104796 <trap+0x132>
		curenv->env_tf = *tf;
f010476c:	e8 c5 16 00 00       	call   f0105e36 <cpunum>
f0104771:	6b c0 74             	imul   $0x74,%eax,%eax
f0104774:	8b 80 28 20 29 f0    	mov    -0xfd6dfd8(%eax),%eax
f010477a:	b9 11 00 00 00       	mov    $0x11,%ecx
f010477f:	89 c7                	mov    %eax,%edi
f0104781:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0104783:	e8 ae 16 00 00       	call   f0105e36 <cpunum>
f0104788:	6b c0 74             	imul   $0x74,%eax,%eax
f010478b:	8b b0 28 20 29 f0    	mov    -0xfd6dfd8(%eax),%esi
f0104791:	e9 1e ff ff ff       	jmp    f01046b4 <trap+0x50>
			env_free(curenv);
f0104796:	e8 9b 16 00 00       	call   f0105e36 <cpunum>
f010479b:	83 ec 0c             	sub    $0xc,%esp
f010479e:	6b c0 74             	imul   $0x74,%eax,%eax
f01047a1:	ff b0 28 20 29 f0    	pushl  -0xfd6dfd8(%eax)
f01047a7:	e8 9d f2 ff ff       	call   f0103a49 <env_free>
			curenv = NULL;
f01047ac:	e8 85 16 00 00       	call   f0105e36 <cpunum>
f01047b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01047b4:	c7 80 28 20 29 f0 00 	movl   $0x0,-0xfd6dfd8(%eax)
f01047bb:	00 00 00 
			sched_yield();
f01047be:	e8 40 02 00 00       	call   f0104a03 <sched_yield>
		page_fault_handler(tf);
f01047c3:	83 ec 0c             	sub    $0xc,%esp
f01047c6:	56                   	push   %esi
f01047c7:	e8 08 fe ff ff       	call   f01045d4 <page_fault_handler>
f01047cc:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f01047cf:	e8 62 16 00 00       	call   f0105e36 <cpunum>
f01047d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01047d7:	83 b8 28 20 29 f0 00 	cmpl   $0x0,-0xfd6dfd8(%eax)
f01047de:	74 18                	je     f01047f8 <trap+0x194>
f01047e0:	e8 51 16 00 00       	call   f0105e36 <cpunum>
f01047e5:	6b c0 74             	imul   $0x74,%eax,%eax
f01047e8:	8b 80 28 20 29 f0    	mov    -0xfd6dfd8(%eax),%eax
f01047ee:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01047f2:	0f 84 90 00 00 00    	je     f0104888 <trap+0x224>
		sched_yield();
f01047f8:	e8 06 02 00 00       	call   f0104a03 <sched_yield>
		tf->tf_regs.reg_eax = syscall(
f01047fd:	83 ec 08             	sub    $0x8,%esp
f0104800:	ff 76 04             	pushl  0x4(%esi)
f0104803:	ff 36                	pushl  (%esi)
f0104805:	ff 76 10             	pushl  0x10(%esi)
f0104808:	ff 76 18             	pushl  0x18(%esi)
f010480b:	ff 76 14             	pushl  0x14(%esi)
f010480e:	ff 76 1c             	pushl  0x1c(%esi)
f0104811:	e8 dd 02 00 00       	call   f0104af3 <syscall>
f0104816:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104819:	83 c4 20             	add    $0x20,%esp
f010481c:	eb b1                	jmp    f01047cf <trap+0x16b>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f010481e:	83 f8 27             	cmp    $0x27,%eax
f0104821:	74 31                	je     f0104854 <trap+0x1f0>
	print_trapframe(tf);
f0104823:	83 ec 0c             	sub    $0xc,%esp
f0104826:	56                   	push   %esi
f0104827:	e8 e7 fb ff ff       	call   f0104413 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010482c:	83 c4 10             	add    $0x10,%esp
f010482f:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104834:	74 3b                	je     f0104871 <trap+0x20d>
		env_destroy(curenv);
f0104836:	e8 fb 15 00 00       	call   f0105e36 <cpunum>
f010483b:	83 ec 0c             	sub    $0xc,%esp
f010483e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104841:	ff b0 28 20 29 f0    	pushl  -0xfd6dfd8(%eax)
f0104847:	e8 0b f4 ff ff       	call   f0103c57 <env_destroy>
f010484c:	83 c4 10             	add    $0x10,%esp
f010484f:	e9 7b ff ff ff       	jmp    f01047cf <trap+0x16b>
		cprintf("Spurious interrupt on irq 7\n");
f0104854:	83 ec 0c             	sub    $0xc,%esp
f0104857:	68 a6 7c 10 f0       	push   $0xf0107ca6
f010485c:	e8 32 f7 ff ff       	call   f0103f93 <cprintf>
		print_trapframe(tf);
f0104861:	89 34 24             	mov    %esi,(%esp)
f0104864:	e8 aa fb ff ff       	call   f0104413 <print_trapframe>
f0104869:	83 c4 10             	add    $0x10,%esp
f010486c:	e9 5e ff ff ff       	jmp    f01047cf <trap+0x16b>
		panic("unhandled trap in kernel");
f0104871:	83 ec 04             	sub    $0x4,%esp
f0104874:	68 c3 7c 10 f0       	push   $0xf0107cc3
f0104879:	68 f1 00 00 00       	push   $0xf1
f010487e:	68 7a 7c 10 f0       	push   $0xf0107c7a
f0104883:	e8 0c b8 ff ff       	call   f0100094 <_panic>
		env_run(curenv);
f0104888:	e8 a9 15 00 00       	call   f0105e36 <cpunum>
f010488d:	83 ec 0c             	sub    $0xc,%esp
f0104890:	6b c0 74             	imul   $0x74,%eax,%eax
f0104893:	ff b0 28 20 29 f0    	pushl  -0xfd6dfd8(%eax)
f0104899:	e8 76 f4 ff ff       	call   f0103d14 <env_run>

f010489e <H_DIVIDE>:
	pushl $(num);							\
	jmp _alltraps

.text

TRAPHANDLER_NOEC(H_DIVIDE , T_DIVIDE)
f010489e:	6a 00                	push   $0x0
f01048a0:	6a 00                	push   $0x0
f01048a2:	eb 60                	jmp    f0104904 <_alltraps>

f01048a4 <H_DEBUG>:
TRAPHANDLER_NOEC(H_DEBUG  , T_DEBUG)
f01048a4:	6a 00                	push   $0x0
f01048a6:	6a 01                	push   $0x1
f01048a8:	eb 5a                	jmp    f0104904 <_alltraps>

f01048aa <H_NMI>:
TRAPHANDLER_NOEC(H_NMI    , T_NMI)
f01048aa:	6a 00                	push   $0x0
f01048ac:	6a 02                	push   $0x2
f01048ae:	eb 54                	jmp    f0104904 <_alltraps>

f01048b0 <H_BRKPT>:
TRAPHANDLER_NOEC(H_BRKPT  , T_BRKPT)
f01048b0:	6a 00                	push   $0x0
f01048b2:	6a 03                	push   $0x3
f01048b4:	eb 4e                	jmp    f0104904 <_alltraps>

f01048b6 <H_OFLOW>:
TRAPHANDLER_NOEC(H_OFLOW  , T_OFLOW)
f01048b6:	6a 00                	push   $0x0
f01048b8:	6a 04                	push   $0x4
f01048ba:	eb 48                	jmp    f0104904 <_alltraps>

f01048bc <H_BOUND>:
TRAPHANDLER_NOEC(H_BOUND  , T_BOUND)
f01048bc:	6a 00                	push   $0x0
f01048be:	6a 05                	push   $0x5
f01048c0:	eb 42                	jmp    f0104904 <_alltraps>

f01048c2 <H_ILLOP>:
TRAPHANDLER_NOEC(H_ILLOP  , T_ILLOP)
f01048c2:	6a 00                	push   $0x0
f01048c4:	6a 06                	push   $0x6
f01048c6:	eb 3c                	jmp    f0104904 <_alltraps>

f01048c8 <H_DEVICE>:
TRAPHANDLER_NOEC(H_DEVICE , T_DEVICE)
f01048c8:	6a 00                	push   $0x0
f01048ca:	6a 07                	push   $0x7
f01048cc:	eb 36                	jmp    f0104904 <_alltraps>

f01048ce <H_DBLFLT>:
TRAPHANDLER     (H_DBLFLT , T_DBLFLT)	// Error Code const 0
f01048ce:	6a 08                	push   $0x8
f01048d0:	eb 32                	jmp    f0104904 <_alltraps>

f01048d2 <H_TSS>:
TRAPHANDLER     (H_TSS    , T_TSS)
f01048d2:	6a 0a                	push   $0xa
f01048d4:	eb 2e                	jmp    f0104904 <_alltraps>

f01048d6 <H_SEGNP>:
TRAPHANDLER     (H_SEGNP  , T_SEGNP)
f01048d6:	6a 0b                	push   $0xb
f01048d8:	eb 2a                	jmp    f0104904 <_alltraps>

f01048da <H_STACK>:
TRAPHANDLER     (H_STACK  , T_STACK)
f01048da:	6a 0c                	push   $0xc
f01048dc:	eb 26                	jmp    f0104904 <_alltraps>

f01048de <H_GPFLT>:
TRAPHANDLER     (H_GPFLT  , T_GPFLT)
f01048de:	6a 0d                	push   $0xd
f01048e0:	eb 22                	jmp    f0104904 <_alltraps>

f01048e2 <H_PGFLT>:
TRAPHANDLER     (H_PGFLT  , T_PGFLT)
f01048e2:	6a 0e                	push   $0xe
f01048e4:	eb 1e                	jmp    f0104904 <_alltraps>

f01048e6 <H_FPERR>:
TRAPHANDLER_NOEC(H_FPERR  , T_FPERR)
f01048e6:	6a 00                	push   $0x0
f01048e8:	6a 10                	push   $0x10
f01048ea:	eb 18                	jmp    f0104904 <_alltraps>

f01048ec <H_ALIGN>:
TRAPHANDLER_NOEC(H_ALIGN  , T_ALIGN)
f01048ec:	6a 00                	push   $0x0
f01048ee:	6a 11                	push   $0x11
f01048f0:	eb 12                	jmp    f0104904 <_alltraps>

f01048f2 <H_MCHK>:
TRAPHANDLER_NOEC(H_MCHK   , T_MCHK)
f01048f2:	6a 00                	push   $0x0
f01048f4:	6a 12                	push   $0x12
f01048f6:	eb 0c                	jmp    f0104904 <_alltraps>

f01048f8 <H_SIMDERR>:
TRAPHANDLER_NOEC(H_SIMDERR, T_SIMDERR)
f01048f8:	6a 00                	push   $0x0
f01048fa:	6a 13                	push   $0x13
f01048fc:	eb 06                	jmp    f0104904 <_alltraps>

f01048fe <H_SYSCALL>:

TRAPHANDLER_NOEC(H_SYSCALL, T_SYSCALL)  // System call.
f01048fe:	6a 00                	push   $0x0
f0104900:	6a 30                	push   $0x30
f0104902:	eb 00                	jmp    f0104904 <_alltraps>

f0104904 <_alltraps>:

_alltraps:
/* Processor has pushed ss, esp, eflags, cs, eip, and [error] */
/* TRAPHANDLER did [error] and trapno */
	pushl  %ds;
f0104904:	1e                   	push   %ds
	pushl  %es;
f0104905:	06                   	push   %es
	pushal;
f0104906:	60                   	pusha  
	movw   $GD_KD, %ax;
f0104907:	66 b8 10 00          	mov    $0x10,%ax
	movw   %ax   , %ds;
f010490b:	8e d8                	mov    %eax,%ds
	movw   %ax   , %es;
f010490d:	8e c0                	mov    %eax,%es
	pushl  %esp;
f010490f:	54                   	push   %esp
	call   trap
f0104910:	e8 4f fd ff ff       	call   f0104664 <trap>

f0104915 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104915:	55                   	push   %ebp
f0104916:	89 e5                	mov    %esp,%ebp
f0104918:	83 ec 08             	sub    $0x8,%esp
f010491b:	a1 48 12 29 f0       	mov    0xf0291248,%eax
f0104920:	83 c0 54             	add    $0x54,%eax
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104923:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104928:	8b 10                	mov    (%eax),%edx
f010492a:	4a                   	dec    %edx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010492b:	83 fa 02             	cmp    $0x2,%edx
f010492e:	76 2b                	jbe    f010495b <sched_halt+0x46>
	for (i = 0; i < NENV; i++) {
f0104930:	41                   	inc    %ecx
f0104931:	83 c0 7c             	add    $0x7c,%eax
f0104934:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010493a:	75 ec                	jne    f0104928 <sched_halt+0x13>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f010493c:	83 ec 0c             	sub    $0xc,%esp
f010493f:	68 d0 7e 10 f0       	push   $0xf0107ed0
f0104944:	e8 4a f6 ff ff       	call   f0103f93 <cprintf>
f0104949:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f010494c:	83 ec 0c             	sub    $0xc,%esp
f010494f:	6a 00                	push   $0x0
f0104951:	e8 cc c4 ff ff       	call   f0100e22 <monitor>
f0104956:	83 c4 10             	add    $0x10,%esp
f0104959:	eb f1                	jmp    f010494c <sched_halt+0x37>
	if (i == NENV) {
f010495b:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104961:	74 d9                	je     f010493c <sched_halt+0x27>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104963:	e8 ce 14 00 00       	call   f0105e36 <cpunum>
f0104968:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010496b:	01 c2                	add    %eax,%edx
f010496d:	01 d2                	add    %edx,%edx
f010496f:	01 c2                	add    %eax,%edx
f0104971:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104974:	c7 04 85 28 20 29 f0 	movl   $0x0,-0xfd6dfd8(,%eax,4)
f010497b:	00 00 00 00 
	lcr3(PADDR(kern_pgdir));
f010497f:	a1 8c 1e 29 f0       	mov    0xf0291e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0104984:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104989:	76 66                	jbe    f01049f1 <sched_halt+0xdc>
	return (physaddr_t)kva - KERNBASE;
f010498b:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104990:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104993:	e8 9e 14 00 00       	call   f0105e36 <cpunum>
f0104998:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010499b:	01 c2                	add    %eax,%edx
f010499d:	01 d2                	add    %edx,%edx
f010499f:	01 c2                	add    %eax,%edx
f01049a1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01049a4:	8d 14 85 04 00 00 00 	lea    0x4(,%eax,4),%edx
	asm volatile("lock; xchgl %0, %1"
f01049ab:	b8 02 00 00 00       	mov    $0x2,%eax
f01049b0:	f0 87 82 20 20 29 f0 	lock xchg %eax,-0xfd6dfe0(%edx)
	spin_unlock(&kernel_lock);
f01049b7:	83 ec 0c             	sub    $0xc,%esp
f01049ba:	68 c0 23 12 f0       	push   $0xf01223c0
f01049bf:	e8 93 17 00 00       	call   f0106157 <spin_unlock>
	asm volatile("pause");
f01049c4:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01049c6:	e8 6b 14 00 00       	call   f0105e36 <cpunum>
f01049cb:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01049ce:	01 c2                	add    %eax,%edx
f01049d0:	01 d2                	add    %edx,%edx
f01049d2:	01 c2                	add    %eax,%edx
f01049d4:	8d 04 90             	lea    (%eax,%edx,4),%eax
	asm volatile (
f01049d7:	8b 04 85 30 20 29 f0 	mov    -0xfd6dfd0(,%eax,4),%eax
f01049de:	bd 00 00 00 00       	mov    $0x0,%ebp
f01049e3:	89 c4                	mov    %eax,%esp
f01049e5:	6a 00                	push   $0x0
f01049e7:	6a 00                	push   $0x0
f01049e9:	f4                   	hlt    
f01049ea:	eb fd                	jmp    f01049e9 <sched_halt+0xd4>
}
f01049ec:	83 c4 10             	add    $0x10,%esp
f01049ef:	c9                   	leave  
f01049f0:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01049f1:	50                   	push   %eax
f01049f2:	68 ec 65 10 f0       	push   $0xf01065ec
f01049f7:	6a 53                	push   $0x53
f01049f9:	68 f9 7e 10 f0       	push   $0xf0107ef9
f01049fe:	e8 91 b6 ff ff       	call   f0100094 <_panic>

f0104a03 <sched_yield>:
{
f0104a03:	55                   	push   %ebp
f0104a04:	89 e5                	mov    %esp,%ebp
f0104a06:	53                   	push   %ebx
f0104a07:	83 ec 04             	sub    $0x4,%esp
	if (!curenv) { 
f0104a0a:	e8 27 14 00 00       	call   f0105e36 <cpunum>
f0104a0f:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104a12:	01 c2                	add    %eax,%edx
f0104a14:	01 d2                	add    %edx,%edx
f0104a16:	01 c2                	add    %eax,%edx
f0104a18:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104a1b:	83 3c 85 28 20 29 f0 	cmpl   $0x0,-0xfd6dfd8(,%eax,4)
f0104a22:	00 
f0104a23:	74 29                	je     f0104a4e <sched_yield+0x4b>
		for (idle = curenv + 1; idle < envs + NENV; idle++)
f0104a25:	e8 0c 14 00 00       	call   f0105e36 <cpunum>
f0104a2a:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104a2d:	01 c2                	add    %eax,%edx
f0104a2f:	01 d2                	add    %edx,%edx
f0104a31:	01 c2                	add    %eax,%edx
f0104a33:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104a36:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f0104a3d:	83 c0 7c             	add    $0x7c,%eax
f0104a40:	8b 1d 48 12 29 f0    	mov    0xf0291248,%ebx
f0104a46:	8d 93 00 f0 01 00    	lea    0x1f000(%ebx),%edx
f0104a4c:	eb 26                	jmp    f0104a74 <sched_yield+0x71>
		for (idle = envs; idle < envs + NENV; idle++)
f0104a4e:	a1 48 12 29 f0       	mov    0xf0291248,%eax
f0104a53:	8d 90 00 f0 01 00    	lea    0x1f000(%eax),%edx
f0104a59:	39 d0                	cmp    %edx,%eax
f0104a5b:	74 76                	je     f0104ad3 <sched_yield+0xd0>
			if (idle->env_status == ENV_RUNNABLE)
f0104a5d:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104a61:	74 05                	je     f0104a68 <sched_yield+0x65>
		for (idle = envs; idle < envs + NENV; idle++)
f0104a63:	83 c0 7c             	add    $0x7c,%eax
f0104a66:	eb f1                	jmp    f0104a59 <sched_yield+0x56>
				env_run(idle); // Will not return
f0104a68:	83 ec 0c             	sub    $0xc,%esp
f0104a6b:	50                   	push   %eax
f0104a6c:	e8 a3 f2 ff ff       	call   f0103d14 <env_run>
		for (idle = curenv + 1; idle < envs + NENV; idle++)
f0104a71:	83 c0 7c             	add    $0x7c,%eax
f0104a74:	39 c2                	cmp    %eax,%edx
f0104a76:	76 18                	jbe    f0104a90 <sched_yield+0x8d>
			if (idle->env_status == ENV_RUNNABLE)
f0104a78:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104a7c:	75 f3                	jne    f0104a71 <sched_yield+0x6e>
				env_run(idle); 
f0104a7e:	83 ec 0c             	sub    $0xc,%esp
f0104a81:	50                   	push   %eax
f0104a82:	e8 8d f2 ff ff       	call   f0103d14 <env_run>
				env_run(idle);
f0104a87:	83 ec 0c             	sub    $0xc,%esp
f0104a8a:	53                   	push   %ebx
f0104a8b:	e8 84 f2 ff ff       	call   f0103d14 <env_run>
		for (idle = envs; idle < curenv ; idle++)
f0104a90:	e8 a1 13 00 00       	call   f0105e36 <cpunum>
f0104a95:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104a98:	01 c2                	add    %eax,%edx
f0104a9a:	01 d2                	add    %edx,%edx
f0104a9c:	01 c2                	add    %eax,%edx
f0104a9e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104aa1:	39 1c 85 28 20 29 f0 	cmp    %ebx,-0xfd6dfd8(,%eax,4)
f0104aa8:	76 0b                	jbe    f0104ab5 <sched_yield+0xb2>
			if (idle->env_status == ENV_RUNNABLE)
f0104aaa:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f0104aae:	74 d7                	je     f0104a87 <sched_yield+0x84>
		for (idle = envs; idle < curenv ; idle++)
f0104ab0:	83 c3 7c             	add    $0x7c,%ebx
f0104ab3:	eb db                	jmp    f0104a90 <sched_yield+0x8d>
		if (curenv->env_status == ENV_RUNNING)
f0104ab5:	e8 7c 13 00 00       	call   f0105e36 <cpunum>
f0104aba:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104abd:	01 c2                	add    %eax,%edx
f0104abf:	01 d2                	add    %edx,%edx
f0104ac1:	01 c2                	add    %eax,%edx
f0104ac3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ac6:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f0104acd:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104ad1:	74 0a                	je     f0104add <sched_yield+0xda>
	sched_halt();
f0104ad3:	e8 3d fe ff ff       	call   f0104915 <sched_halt>
}
f0104ad8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104adb:	c9                   	leave  
f0104adc:	c3                   	ret    
			env_run(curenv);
f0104add:	e8 54 13 00 00       	call   f0105e36 <cpunum>
f0104ae2:	83 ec 0c             	sub    $0xc,%esp
f0104ae5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ae8:	ff b0 28 20 29 f0    	pushl  -0xfd6dfd8(%eax)
f0104aee:	e8 21 f2 ff ff       	call   f0103d14 <env_run>

f0104af3 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104af3:	55                   	push   %ebp
f0104af4:	89 e5                	mov    %esp,%ebp
f0104af6:	53                   	push   %ebx
f0104af7:	83 ec 14             	sub    $0x14,%esp
f0104afa:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	switch (syscallno) {
f0104afd:	83 f8 0a             	cmp    $0xa,%eax
f0104b00:	0f 87 1e 01 00 00    	ja     f0104c24 <syscall+0x131>
f0104b06:	ff 24 85 40 7f 10 f0 	jmp    *-0xfef80c0(,%eax,4)
	case SYS_cputs:
		user_mem_assert(curenv, (const void*)a1, a2, PTE_U);  // The memory is readable.
f0104b0d:	e8 24 13 00 00       	call   f0105e36 <cpunum>
f0104b12:	6a 04                	push   $0x4
f0104b14:	ff 75 10             	pushl  0x10(%ebp)
f0104b17:	ff 75 0c             	pushl  0xc(%ebp)
f0104b1a:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104b1d:	01 c2                	add    %eax,%edx
f0104b1f:	01 d2                	add    %edx,%edx
f0104b21:	01 c2                	add    %eax,%edx
f0104b23:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104b26:	ff 34 85 28 20 29 f0 	pushl  -0xfd6dfd8(,%eax,4)
f0104b2d:	e8 90 e9 ff ff       	call   f01034c2 <user_mem_assert>
	cprintf("%.*s", len, s);
f0104b32:	83 c4 0c             	add    $0xc,%esp
f0104b35:	ff 75 0c             	pushl  0xc(%ebp)
f0104b38:	ff 75 10             	pushl  0x10(%ebp)
f0104b3b:	68 06 7f 10 f0       	push   $0xf0107f06
f0104b40:	e8 4e f4 ff ff       	call   f0103f93 <cprintf>
f0104b45:	83 c4 10             	add    $0x10,%esp
		sys_cputs((const char*)a1, a2);
		return 0;
f0104b48:	b8 00 00 00 00       	mov    $0x0,%eax
	case SYS_yield:
		sys_yield();
	default:
		return -E_INVAL;
	}
}
f0104b4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104b50:	c9                   	leave  
f0104b51:	c3                   	ret    
	return cons_getc();
f0104b52:	e8 85 bb ff ff       	call   f01006dc <cons_getc>
		return sys_cgetc();
f0104b57:	eb f4                	jmp    f0104b4d <syscall+0x5a>
	return curenv->env_id;
f0104b59:	e8 d8 12 00 00       	call   f0105e36 <cpunum>
f0104b5e:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104b61:	01 c2                	add    %eax,%edx
f0104b63:	01 d2                	add    %edx,%edx
f0104b65:	01 c2                	add    %eax,%edx
f0104b67:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104b6a:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f0104b71:	8b 40 48             	mov    0x48(%eax),%eax
		return sys_getenvid();
f0104b74:	eb d7                	jmp    f0104b4d <syscall+0x5a>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104b76:	83 ec 04             	sub    $0x4,%esp
f0104b79:	6a 01                	push   $0x1
f0104b7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104b7e:	50                   	push   %eax
f0104b7f:	ff 75 0c             	pushl  0xc(%ebp)
f0104b82:	e8 87 e9 ff ff       	call   f010350e <envid2env>
f0104b87:	83 c4 10             	add    $0x10,%esp
f0104b8a:	85 c0                	test   %eax,%eax
f0104b8c:	78 bf                	js     f0104b4d <syscall+0x5a>
	if (e == curenv)
f0104b8e:	e8 a3 12 00 00       	call   f0105e36 <cpunum>
f0104b93:	8b 4d f4             	mov    -0xc(%ebp),%ecx
f0104b96:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104b99:	01 c2                	add    %eax,%edx
f0104b9b:	01 d2                	add    %edx,%edx
f0104b9d:	01 c2                	add    %eax,%edx
f0104b9f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ba2:	39 0c 85 28 20 29 f0 	cmp    %ecx,-0xfd6dfd8(,%eax,4)
f0104ba9:	74 47                	je     f0104bf2 <syscall+0xff>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104bab:	8b 59 48             	mov    0x48(%ecx),%ebx
f0104bae:	e8 83 12 00 00       	call   f0105e36 <cpunum>
f0104bb3:	83 ec 04             	sub    $0x4,%esp
f0104bb6:	53                   	push   %ebx
f0104bb7:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104bba:	01 c2                	add    %eax,%edx
f0104bbc:	01 d2                	add    %edx,%edx
f0104bbe:	01 c2                	add    %eax,%edx
f0104bc0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104bc3:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f0104bca:	ff 70 48             	pushl  0x48(%eax)
f0104bcd:	68 26 7f 10 f0       	push   $0xf0107f26
f0104bd2:	e8 bc f3 ff ff       	call   f0103f93 <cprintf>
f0104bd7:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104bda:	83 ec 0c             	sub    $0xc,%esp
f0104bdd:	ff 75 f4             	pushl  -0xc(%ebp)
f0104be0:	e8 72 f0 ff ff       	call   f0103c57 <env_destroy>
f0104be5:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104be8:	b8 00 00 00 00       	mov    $0x0,%eax
		return sys_env_destroy(a1);
f0104bed:	e9 5b ff ff ff       	jmp    f0104b4d <syscall+0x5a>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104bf2:	e8 3f 12 00 00       	call   f0105e36 <cpunum>
f0104bf7:	83 ec 08             	sub    $0x8,%esp
f0104bfa:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104bfd:	01 c2                	add    %eax,%edx
f0104bff:	01 d2                	add    %edx,%edx
f0104c01:	01 c2                	add    %eax,%edx
f0104c03:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104c06:	8b 04 85 28 20 29 f0 	mov    -0xfd6dfd8(,%eax,4),%eax
f0104c0d:	ff 70 48             	pushl  0x48(%eax)
f0104c10:	68 0b 7f 10 f0       	push   $0xf0107f0b
f0104c15:	e8 79 f3 ff ff       	call   f0103f93 <cprintf>
f0104c1a:	83 c4 10             	add    $0x10,%esp
f0104c1d:	eb bb                	jmp    f0104bda <syscall+0xe7>
	sched_yield();
f0104c1f:	e8 df fd ff ff       	call   f0104a03 <sched_yield>
		return -E_INVAL;
f0104c24:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c29:	e9 1f ff ff ff       	jmp    f0104b4d <syscall+0x5a>

f0104c2e <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104c2e:	55                   	push   %ebp
f0104c2f:	89 e5                	mov    %esp,%ebp
f0104c31:	57                   	push   %edi
f0104c32:	56                   	push   %esi
f0104c33:	53                   	push   %ebx
f0104c34:	83 ec 14             	sub    $0x14,%esp
f0104c37:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104c3a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104c3d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104c40:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104c43:	8b 32                	mov    (%edx),%esi
f0104c45:	8b 01                	mov    (%ecx),%eax
f0104c47:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c4a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104c51:	eb 2f                	jmp    f0104c82 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0104c53:	48                   	dec    %eax
		while (m >= l && stabs[m].n_type != type)
f0104c54:	39 c6                	cmp    %eax,%esi
f0104c56:	7f 4d                	jg     f0104ca5 <stab_binsearch+0x77>
f0104c58:	0f b6 0a             	movzbl (%edx),%ecx
f0104c5b:	83 ea 0c             	sub    $0xc,%edx
f0104c5e:	39 f9                	cmp    %edi,%ecx
f0104c60:	75 f1                	jne    f0104c53 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104c62:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104c65:	01 c2                	add    %eax,%edx
f0104c67:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104c6a:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104c6e:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104c71:	73 37                	jae    f0104caa <stab_binsearch+0x7c>
			*region_left = m;
f0104c73:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104c76:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0104c78:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0104c7b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104c82:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0104c85:	7f 4d                	jg     f0104cd4 <stab_binsearch+0xa6>
		int true_m = (l + r) / 2, m = true_m;
f0104c87:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104c8a:	01 f0                	add    %esi,%eax
f0104c8c:	89 c3                	mov    %eax,%ebx
f0104c8e:	c1 eb 1f             	shr    $0x1f,%ebx
f0104c91:	01 c3                	add    %eax,%ebx
f0104c93:	d1 fb                	sar    %ebx
f0104c95:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0104c98:	01 d8                	add    %ebx,%eax
f0104c9a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104c9d:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104ca1:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0104ca3:	eb af                	jmp    f0104c54 <stab_binsearch+0x26>
			l = true_m + 1;
f0104ca5:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0104ca8:	eb d8                	jmp    f0104c82 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0104caa:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104cad:	76 12                	jbe    f0104cc1 <stab_binsearch+0x93>
			*region_right = m - 1;
f0104caf:	48                   	dec    %eax
f0104cb0:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104cb3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104cb6:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0104cb8:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104cbf:	eb c1                	jmp    f0104c82 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104cc1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104cc4:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104cc6:	ff 45 0c             	incl   0xc(%ebp)
f0104cc9:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0104ccb:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104cd2:	eb ae                	jmp    f0104c82 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0104cd4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104cd8:	74 18                	je     f0104cf2 <stab_binsearch+0xc4>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104cda:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104cdd:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104cdf:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104ce2:	8b 0e                	mov    (%esi),%ecx
f0104ce4:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104ce7:	01 c2                	add    %eax,%edx
f0104ce9:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104cec:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0104cf0:	eb 0e                	jmp    f0104d00 <stab_binsearch+0xd2>
		*region_right = *region_left - 1;
f0104cf2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104cf5:	8b 00                	mov    (%eax),%eax
f0104cf7:	48                   	dec    %eax
f0104cf8:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104cfb:	89 07                	mov    %eax,(%edi)
f0104cfd:	eb 14                	jmp    f0104d13 <stab_binsearch+0xe5>
		     l--)
f0104cff:	48                   	dec    %eax
		for (l = *region_right;
f0104d00:	39 c1                	cmp    %eax,%ecx
f0104d02:	7d 0a                	jge    f0104d0e <stab_binsearch+0xe0>
		     l > *region_left && stabs[l].n_type != type;
f0104d04:	0f b6 1a             	movzbl (%edx),%ebx
f0104d07:	83 ea 0c             	sub    $0xc,%edx
f0104d0a:	39 fb                	cmp    %edi,%ebx
f0104d0c:	75 f1                	jne    f0104cff <stab_binsearch+0xd1>
			/* do nothing */;
		*region_left = l;
f0104d0e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d11:	89 07                	mov    %eax,(%edi)
	}
}
f0104d13:	83 c4 14             	add    $0x14,%esp
f0104d16:	5b                   	pop    %ebx
f0104d17:	5e                   	pop    %esi
f0104d18:	5f                   	pop    %edi
f0104d19:	5d                   	pop    %ebp
f0104d1a:	c3                   	ret    

f0104d1b <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104d1b:	55                   	push   %ebp
f0104d1c:	89 e5                	mov    %esp,%ebp
f0104d1e:	57                   	push   %edi
f0104d1f:	56                   	push   %esi
f0104d20:	53                   	push   %ebx
f0104d21:	83 ec 4c             	sub    $0x4c,%esp
f0104d24:	8b 75 08             	mov    0x8(%ebp),%esi
f0104d27:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104d2a:	c7 03 6c 7f 10 f0    	movl   $0xf0107f6c,(%ebx)
	info->eip_line = 0;
f0104d30:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104d37:	c7 43 08 6c 7f 10 f0 	movl   $0xf0107f6c,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104d3e:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104d45:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104d48:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104d4f:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104d55:	77 1e                	ja     f0104d75 <debuginfo_eip+0x5a>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104d57:	8b 3d 00 00 20 00    	mov    0x200000,%edi
		stab_end = usd->stab_end;
f0104d5d:	8b 15 04 00 20 00    	mov    0x200004,%edx
		stabstr = usd->stabstr;
f0104d63:	a1 08 00 20 00       	mov    0x200008,%eax
f0104d68:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0104d6b:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0104d70:	89 45 b8             	mov    %eax,-0x48(%ebp)
f0104d73:	eb 18                	jmp    f0104d8d <debuginfo_eip+0x72>
		stabstr_end = __STABSTR_END__;
f0104d75:	c7 45 b8 a6 74 11 f0 	movl   $0xf01174a6,-0x48(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104d7c:	c7 45 b4 d5 3c 11 f0 	movl   $0xf0113cd5,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0104d83:	ba d4 3c 11 f0       	mov    $0xf0113cd4,%edx
		stabs = __STAB_BEGIN__;
f0104d88:	bf 54 84 10 f0       	mov    $0xf0108454,%edi
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104d8d:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0104d90:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
f0104d93:	0f 83 9b 01 00 00    	jae    f0104f34 <debuginfo_eip+0x219>
f0104d99:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104d9d:	0f 85 98 01 00 00    	jne    f0104f3b <debuginfo_eip+0x220>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104da3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104daa:	29 fa                	sub    %edi,%edx
f0104dac:	c1 fa 02             	sar    $0x2,%edx
f0104daf:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0104db2:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0104db5:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0104db8:	89 c1                	mov    %eax,%ecx
f0104dba:	c1 e1 08             	shl    $0x8,%ecx
f0104dbd:	01 c8                	add    %ecx,%eax
f0104dbf:	89 c1                	mov    %eax,%ecx
f0104dc1:	c1 e1 10             	shl    $0x10,%ecx
f0104dc4:	01 c8                	add    %ecx,%eax
f0104dc6:	01 c0                	add    %eax,%eax
f0104dc8:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
f0104dcc:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104dcf:	56                   	push   %esi
f0104dd0:	6a 64                	push   $0x64
f0104dd2:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104dd5:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104dd8:	89 f8                	mov    %edi,%eax
f0104dda:	e8 4f fe ff ff       	call   f0104c2e <stab_binsearch>
	if (lfile == 0)
f0104ddf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104de2:	83 c4 08             	add    $0x8,%esp
f0104de5:	85 c0                	test   %eax,%eax
f0104de7:	0f 84 55 01 00 00    	je     f0104f42 <debuginfo_eip+0x227>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104ded:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104df0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104df3:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104df6:	56                   	push   %esi
f0104df7:	6a 24                	push   $0x24
f0104df9:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104dfc:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104dff:	89 f8                	mov    %edi,%eax
f0104e01:	e8 28 fe ff ff       	call   f0104c2e <stab_binsearch>

	if (lfun <= rfun) {
f0104e06:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e09:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0104e0c:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0104e0f:	83 c4 08             	add    $0x8,%esp
f0104e12:	39 c8                	cmp    %ecx,%eax
f0104e14:	0f 8f 80 00 00 00    	jg     f0104e9a <debuginfo_eip+0x17f>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104e1a:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104e1d:	01 c2                	add    %eax,%edx
f0104e1f:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104e22:	89 55 c0             	mov    %edx,-0x40(%ebp)
f0104e25:	8b 0a                	mov    (%edx),%ecx
f0104e27:	89 4d bc             	mov    %ecx,-0x44(%ebp)
f0104e2a:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0104e2d:	2b 55 b4             	sub    -0x4c(%ebp),%edx
f0104e30:	39 d1                	cmp    %edx,%ecx
f0104e32:	73 06                	jae    f0104e3a <debuginfo_eip+0x11f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104e34:	03 4d b4             	add    -0x4c(%ebp),%ecx
f0104e37:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104e3a:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104e3d:	8b 51 08             	mov    0x8(%ecx),%edx
f0104e40:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104e43:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0104e45:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104e48:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104e4b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104e4e:	83 ec 08             	sub    $0x8,%esp
f0104e51:	6a 3a                	push   $0x3a
f0104e53:	ff 73 08             	pushl  0x8(%ebx)
f0104e56:	e8 e9 08 00 00       	call   f0105744 <strfind>
f0104e5b:	2b 43 08             	sub    0x8(%ebx),%eax
f0104e5e:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// N_SLINE represents text segment
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104e61:	83 c4 08             	add    $0x8,%esp
f0104e64:	56                   	push   %esi
f0104e65:	6a 44                	push   $0x44
f0104e67:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104e6a:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104e6d:	89 f8                	mov    %edi,%eax
f0104e6f:	e8 ba fd ff ff       	call   f0104c2e <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0104e74:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104e77:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104e7a:	01 c2                	add    %eax,%edx
f0104e7c:	c1 e2 02             	shl    $0x2,%edx
f0104e7f:	0f b7 4c 17 06       	movzwl 0x6(%edi,%edx,1),%ecx
f0104e84:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104e87:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104e8a:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104e8d:	8d 54 17 04          	lea    0x4(%edi,%edx,1),%edx
f0104e91:	83 c4 10             	add    $0x10,%esp
f0104e94:	c6 45 c0 00          	movb   $0x0,-0x40(%ebp)
f0104e98:	eb 19                	jmp    f0104eb3 <debuginfo_eip+0x198>
		info->eip_fn_addr = addr;
f0104e9a:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0104e9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ea0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104ea3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ea6:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104ea9:	eb a3                	jmp    f0104e4e <debuginfo_eip+0x133>
f0104eab:	48                   	dec    %eax
f0104eac:	83 ea 0c             	sub    $0xc,%edx
f0104eaf:	c6 45 c0 01          	movb   $0x1,-0x40(%ebp)
f0104eb3:	89 45 bc             	mov    %eax,-0x44(%ebp)
	while (lline >= lfile
f0104eb6:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0104eb9:	7f 40                	jg     f0104efb <debuginfo_eip+0x1e0>
	       && stabs[lline].n_type != N_SOL
f0104ebb:	8a 0a                	mov    (%edx),%cl
f0104ebd:	80 f9 84             	cmp    $0x84,%cl
f0104ec0:	74 19                	je     f0104edb <debuginfo_eip+0x1c0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104ec2:	80 f9 64             	cmp    $0x64,%cl
f0104ec5:	75 e4                	jne    f0104eab <debuginfo_eip+0x190>
f0104ec7:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0104ecb:	74 de                	je     f0104eab <debuginfo_eip+0x190>
f0104ecd:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f0104ed1:	74 0e                	je     f0104ee1 <debuginfo_eip+0x1c6>
f0104ed3:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0104ed6:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0104ed9:	eb 06                	jmp    f0104ee1 <debuginfo_eip+0x1c6>
f0104edb:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f0104edf:	75 35                	jne    f0104f16 <debuginfo_eip+0x1fb>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104ee1:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104ee4:	01 d0                	add    %edx,%eax
f0104ee6:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104ee9:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0104eec:	8b 75 b4             	mov    -0x4c(%ebp),%esi
f0104eef:	29 f0                	sub    %esi,%eax
f0104ef1:	39 c2                	cmp    %eax,%edx
f0104ef3:	73 06                	jae    f0104efb <debuginfo_eip+0x1e0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104ef5:	89 f0                	mov    %esi,%eax
f0104ef7:	01 d0                	add    %edx,%eax
f0104ef9:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104efb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104efe:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0104f01:	39 f2                	cmp    %esi,%edx
f0104f03:	7d 44                	jge    f0104f49 <debuginfo_eip+0x22e>
		for (lline = lfun + 1;
f0104f05:	42                   	inc    %edx
f0104f06:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104f09:	89 d0                	mov    %edx,%eax
f0104f0b:	8d 0c 12             	lea    (%edx,%edx,1),%ecx
f0104f0e:	01 ca                	add    %ecx,%edx
f0104f10:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0104f14:	eb 08                	jmp    f0104f1e <debuginfo_eip+0x203>
f0104f16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104f19:	eb c6                	jmp    f0104ee1 <debuginfo_eip+0x1c6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104f1b:	ff 43 14             	incl   0x14(%ebx)
		for (lline = lfun + 1;
f0104f1e:	39 c6                	cmp    %eax,%esi
f0104f20:	7e 34                	jle    f0104f56 <debuginfo_eip+0x23b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104f22:	8a 0a                	mov    (%edx),%cl
f0104f24:	40                   	inc    %eax
f0104f25:	83 c2 0c             	add    $0xc,%edx
f0104f28:	80 f9 a0             	cmp    $0xa0,%cl
f0104f2b:	74 ee                	je     f0104f1b <debuginfo_eip+0x200>

	return 0;
f0104f2d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f32:	eb 1a                	jmp    f0104f4e <debuginfo_eip+0x233>
		return -1;
f0104f34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f39:	eb 13                	jmp    f0104f4e <debuginfo_eip+0x233>
f0104f3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f40:	eb 0c                	jmp    f0104f4e <debuginfo_eip+0x233>
		return -1;
f0104f42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f47:	eb 05                	jmp    f0104f4e <debuginfo_eip+0x233>
	return 0;
f0104f49:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104f4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f51:	5b                   	pop    %ebx
f0104f52:	5e                   	pop    %esi
f0104f53:	5f                   	pop    %edi
f0104f54:	5d                   	pop    %ebp
f0104f55:	c3                   	ret    
	return 0;
f0104f56:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f5b:	eb f1                	jmp    f0104f4e <debuginfo_eip+0x233>

f0104f5d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104f5d:	55                   	push   %ebp
f0104f5e:	89 e5                	mov    %esp,%ebp
f0104f60:	57                   	push   %edi
f0104f61:	56                   	push   %esi
f0104f62:	53                   	push   %ebx
f0104f63:	83 ec 1c             	sub    $0x1c,%esp
f0104f66:	89 c7                	mov    %eax,%edi
f0104f68:	89 d6                	mov    %edx,%esi
f0104f6a:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f6d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104f70:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f73:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104f76:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104f79:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104f7e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104f81:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104f84:	39 d3                	cmp    %edx,%ebx
f0104f86:	72 05                	jb     f0104f8d <printnum+0x30>
f0104f88:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104f8b:	77 78                	ja     f0105005 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104f8d:	83 ec 0c             	sub    $0xc,%esp
f0104f90:	ff 75 18             	pushl  0x18(%ebp)
f0104f93:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f96:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104f99:	53                   	push   %ebx
f0104f9a:	ff 75 10             	pushl  0x10(%ebp)
f0104f9d:	83 ec 08             	sub    $0x8,%esp
f0104fa0:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104fa3:	ff 75 e0             	pushl  -0x20(%ebp)
f0104fa6:	ff 75 dc             	pushl  -0x24(%ebp)
f0104fa9:	ff 75 d8             	pushl  -0x28(%ebp)
f0104fac:	e8 9b 12 00 00       	call   f010624c <__udivdi3>
f0104fb1:	83 c4 18             	add    $0x18,%esp
f0104fb4:	52                   	push   %edx
f0104fb5:	50                   	push   %eax
f0104fb6:	89 f2                	mov    %esi,%edx
f0104fb8:	89 f8                	mov    %edi,%eax
f0104fba:	e8 9e ff ff ff       	call   f0104f5d <printnum>
f0104fbf:	83 c4 20             	add    $0x20,%esp
f0104fc2:	eb 11                	jmp    f0104fd5 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104fc4:	83 ec 08             	sub    $0x8,%esp
f0104fc7:	56                   	push   %esi
f0104fc8:	ff 75 18             	pushl  0x18(%ebp)
f0104fcb:	ff d7                	call   *%edi
f0104fcd:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0104fd0:	4b                   	dec    %ebx
f0104fd1:	85 db                	test   %ebx,%ebx
f0104fd3:	7f ef                	jg     f0104fc4 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104fd5:	83 ec 08             	sub    $0x8,%esp
f0104fd8:	56                   	push   %esi
f0104fd9:	83 ec 04             	sub    $0x4,%esp
f0104fdc:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104fdf:	ff 75 e0             	pushl  -0x20(%ebp)
f0104fe2:	ff 75 dc             	pushl  -0x24(%ebp)
f0104fe5:	ff 75 d8             	pushl  -0x28(%ebp)
f0104fe8:	e8 5f 13 00 00       	call   f010634c <__umoddi3>
f0104fed:	83 c4 14             	add    $0x14,%esp
f0104ff0:	0f be 80 76 7f 10 f0 	movsbl -0xfef808a(%eax),%eax
f0104ff7:	50                   	push   %eax
f0104ff8:	ff d7                	call   *%edi
}
f0104ffa:	83 c4 10             	add    $0x10,%esp
f0104ffd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105000:	5b                   	pop    %ebx
f0105001:	5e                   	pop    %esi
f0105002:	5f                   	pop    %edi
f0105003:	5d                   	pop    %ebp
f0105004:	c3                   	ret    
f0105005:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0105008:	eb c6                	jmp    f0104fd0 <printnum+0x73>

f010500a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010500a:	55                   	push   %ebp
f010500b:	89 e5                	mov    %esp,%ebp
f010500d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105010:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0105013:	8b 10                	mov    (%eax),%edx
f0105015:	3b 50 04             	cmp    0x4(%eax),%edx
f0105018:	73 0a                	jae    f0105024 <sprintputch+0x1a>
		*b->buf++ = ch;
f010501a:	8d 4a 01             	lea    0x1(%edx),%ecx
f010501d:	89 08                	mov    %ecx,(%eax)
f010501f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105022:	88 02                	mov    %al,(%edx)
}
f0105024:	5d                   	pop    %ebp
f0105025:	c3                   	ret    

f0105026 <printfmt>:
{
f0105026:	55                   	push   %ebp
f0105027:	89 e5                	mov    %esp,%ebp
f0105029:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f010502c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010502f:	50                   	push   %eax
f0105030:	ff 75 10             	pushl  0x10(%ebp)
f0105033:	ff 75 0c             	pushl  0xc(%ebp)
f0105036:	ff 75 08             	pushl  0x8(%ebp)
f0105039:	e8 05 00 00 00       	call   f0105043 <vprintfmt>
}
f010503e:	83 c4 10             	add    $0x10,%esp
f0105041:	c9                   	leave  
f0105042:	c3                   	ret    

f0105043 <vprintfmt>:
{
f0105043:	55                   	push   %ebp
f0105044:	89 e5                	mov    %esp,%ebp
f0105046:	57                   	push   %edi
f0105047:	56                   	push   %esi
f0105048:	53                   	push   %ebx
f0105049:	83 ec 2c             	sub    $0x2c,%esp
f010504c:	8b 75 08             	mov    0x8(%ebp),%esi
f010504f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105052:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105055:	e9 ac 03 00 00       	jmp    f0105406 <vprintfmt+0x3c3>
		padc = ' ';
f010505a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f010505e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0105065:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f010506c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0105073:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0105078:	8d 47 01             	lea    0x1(%edi),%eax
f010507b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010507e:	8a 17                	mov    (%edi),%dl
f0105080:	8d 42 dd             	lea    -0x23(%edx),%eax
f0105083:	3c 55                	cmp    $0x55,%al
f0105085:	0f 87 fc 03 00 00    	ja     f0105487 <vprintfmt+0x444>
f010508b:	0f b6 c0             	movzbl %al,%eax
f010508e:	ff 24 85 40 80 10 f0 	jmp    *-0xfef7fc0(,%eax,4)
f0105095:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0105098:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f010509c:	eb da                	jmp    f0105078 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f010509e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f01050a1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f01050a5:	eb d1                	jmp    f0105078 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f01050a7:	0f b6 d2             	movzbl %dl,%edx
f01050aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f01050ad:	b8 00 00 00 00       	mov    $0x0,%eax
f01050b2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f01050b5:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01050b8:	01 c0                	add    %eax,%eax
f01050ba:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
f01050be:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f01050c1:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01050c4:	83 f9 09             	cmp    $0x9,%ecx
f01050c7:	77 52                	ja     f010511b <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
f01050c9:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
f01050ca:	eb e9                	jmp    f01050b5 <vprintfmt+0x72>
			precision = va_arg(ap, int);
f01050cc:	8b 45 14             	mov    0x14(%ebp),%eax
f01050cf:	8b 00                	mov    (%eax),%eax
f01050d1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01050d4:	8b 45 14             	mov    0x14(%ebp),%eax
f01050d7:	8d 40 04             	lea    0x4(%eax),%eax
f01050da:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01050dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f01050e0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01050e4:	79 92                	jns    f0105078 <vprintfmt+0x35>
				width = precision, precision = -1;
f01050e6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01050e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01050ec:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01050f3:	eb 83                	jmp    f0105078 <vprintfmt+0x35>
f01050f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01050f9:	78 08                	js     f0105103 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
f01050fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01050fe:	e9 75 ff ff ff       	jmp    f0105078 <vprintfmt+0x35>
f0105103:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010510a:	eb ef                	jmp    f01050fb <vprintfmt+0xb8>
f010510c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f010510f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0105116:	e9 5d ff ff ff       	jmp    f0105078 <vprintfmt+0x35>
f010511b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010511e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105121:	eb bd                	jmp    f01050e0 <vprintfmt+0x9d>
			lflag++;
f0105123:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
f0105124:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0105127:	e9 4c ff ff ff       	jmp    f0105078 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f010512c:	8b 45 14             	mov    0x14(%ebp),%eax
f010512f:	8d 78 04             	lea    0x4(%eax),%edi
f0105132:	83 ec 08             	sub    $0x8,%esp
f0105135:	53                   	push   %ebx
f0105136:	ff 30                	pushl  (%eax)
f0105138:	ff d6                	call   *%esi
			break;
f010513a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f010513d:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0105140:	e9 be 02 00 00       	jmp    f0105403 <vprintfmt+0x3c0>
			err = va_arg(ap, int);
f0105145:	8b 45 14             	mov    0x14(%ebp),%eax
f0105148:	8d 78 04             	lea    0x4(%eax),%edi
f010514b:	8b 00                	mov    (%eax),%eax
f010514d:	85 c0                	test   %eax,%eax
f010514f:	78 2a                	js     f010517b <vprintfmt+0x138>
f0105151:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105153:	83 f8 08             	cmp    $0x8,%eax
f0105156:	7f 27                	jg     f010517f <vprintfmt+0x13c>
f0105158:	8b 04 85 a0 81 10 f0 	mov    -0xfef7e60(,%eax,4),%eax
f010515f:	85 c0                	test   %eax,%eax
f0105161:	74 1c                	je     f010517f <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
f0105163:	50                   	push   %eax
f0105164:	68 d5 76 10 f0       	push   $0xf01076d5
f0105169:	53                   	push   %ebx
f010516a:	56                   	push   %esi
f010516b:	e8 b6 fe ff ff       	call   f0105026 <printfmt>
f0105170:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105173:	89 7d 14             	mov    %edi,0x14(%ebp)
f0105176:	e9 88 02 00 00       	jmp    f0105403 <vprintfmt+0x3c0>
f010517b:	f7 d8                	neg    %eax
f010517d:	eb d2                	jmp    f0105151 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
f010517f:	52                   	push   %edx
f0105180:	68 8e 7f 10 f0       	push   $0xf0107f8e
f0105185:	53                   	push   %ebx
f0105186:	56                   	push   %esi
f0105187:	e8 9a fe ff ff       	call   f0105026 <printfmt>
f010518c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010518f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0105192:	e9 6c 02 00 00       	jmp    f0105403 <vprintfmt+0x3c0>
			if ((p = va_arg(ap, char *)) == NULL)
f0105197:	8b 45 14             	mov    0x14(%ebp),%eax
f010519a:	83 c0 04             	add    $0x4,%eax
f010519d:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01051a0:	8b 45 14             	mov    0x14(%ebp),%eax
f01051a3:	8b 38                	mov    (%eax),%edi
f01051a5:	85 ff                	test   %edi,%edi
f01051a7:	74 18                	je     f01051c1 <vprintfmt+0x17e>
			if (width > 0 && padc != '-')
f01051a9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01051ad:	0f 8e b7 00 00 00    	jle    f010526a <vprintfmt+0x227>
f01051b3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01051b7:	75 0f                	jne    f01051c8 <vprintfmt+0x185>
f01051b9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01051bc:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01051bf:	eb 6e                	jmp    f010522f <vprintfmt+0x1ec>
				p = "(null)";
f01051c1:	bf 87 7f 10 f0       	mov    $0xf0107f87,%edi
f01051c6:	eb e1                	jmp    f01051a9 <vprintfmt+0x166>
				for (width -= strnlen(p, precision); width > 0; width--)
f01051c8:	83 ec 08             	sub    $0x8,%esp
f01051cb:	ff 75 d0             	pushl  -0x30(%ebp)
f01051ce:	57                   	push   %edi
f01051cf:	e8 45 04 00 00       	call   f0105619 <strnlen>
f01051d4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01051d7:	29 c1                	sub    %eax,%ecx
f01051d9:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f01051dc:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f01051df:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01051e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01051e6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01051e9:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f01051eb:	eb 0d                	jmp    f01051fa <vprintfmt+0x1b7>
					putch(padc, putdat);
f01051ed:	83 ec 08             	sub    $0x8,%esp
f01051f0:	53                   	push   %ebx
f01051f1:	ff 75 e0             	pushl  -0x20(%ebp)
f01051f4:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f01051f6:	4f                   	dec    %edi
f01051f7:	83 c4 10             	add    $0x10,%esp
f01051fa:	85 ff                	test   %edi,%edi
f01051fc:	7f ef                	jg     f01051ed <vprintfmt+0x1aa>
f01051fe:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105201:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0105204:	89 c8                	mov    %ecx,%eax
f0105206:	85 c9                	test   %ecx,%ecx
f0105208:	78 59                	js     f0105263 <vprintfmt+0x220>
f010520a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010520d:	29 c1                	sub    %eax,%ecx
f010520f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105212:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105215:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0105218:	eb 15                	jmp    f010522f <vprintfmt+0x1ec>
				if (altflag && (ch < ' ' || ch > '~'))
f010521a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010521e:	75 29                	jne    f0105249 <vprintfmt+0x206>
					putch(ch, putdat);
f0105220:	83 ec 08             	sub    $0x8,%esp
f0105223:	ff 75 0c             	pushl  0xc(%ebp)
f0105226:	50                   	push   %eax
f0105227:	ff d6                	call   *%esi
f0105229:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010522c:	ff 4d e0             	decl   -0x20(%ebp)
f010522f:	47                   	inc    %edi
f0105230:	8a 57 ff             	mov    -0x1(%edi),%dl
f0105233:	0f be c2             	movsbl %dl,%eax
f0105236:	85 c0                	test   %eax,%eax
f0105238:	74 53                	je     f010528d <vprintfmt+0x24a>
f010523a:	85 db                	test   %ebx,%ebx
f010523c:	78 dc                	js     f010521a <vprintfmt+0x1d7>
f010523e:	4b                   	dec    %ebx
f010523f:	79 d9                	jns    f010521a <vprintfmt+0x1d7>
f0105241:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105244:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105247:	eb 35                	jmp    f010527e <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
f0105249:	0f be d2             	movsbl %dl,%edx
f010524c:	83 ea 20             	sub    $0x20,%edx
f010524f:	83 fa 5e             	cmp    $0x5e,%edx
f0105252:	76 cc                	jbe    f0105220 <vprintfmt+0x1dd>
					putch('?', putdat);
f0105254:	83 ec 08             	sub    $0x8,%esp
f0105257:	ff 75 0c             	pushl  0xc(%ebp)
f010525a:	6a 3f                	push   $0x3f
f010525c:	ff d6                	call   *%esi
f010525e:	83 c4 10             	add    $0x10,%esp
f0105261:	eb c9                	jmp    f010522c <vprintfmt+0x1e9>
f0105263:	b8 00 00 00 00       	mov    $0x0,%eax
f0105268:	eb a0                	jmp    f010520a <vprintfmt+0x1c7>
f010526a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010526d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0105270:	eb bd                	jmp    f010522f <vprintfmt+0x1ec>
				putch(' ', putdat);
f0105272:	83 ec 08             	sub    $0x8,%esp
f0105275:	53                   	push   %ebx
f0105276:	6a 20                	push   $0x20
f0105278:	ff d6                	call   *%esi
			for (; width > 0; width--)
f010527a:	4f                   	dec    %edi
f010527b:	83 c4 10             	add    $0x10,%esp
f010527e:	85 ff                	test   %edi,%edi
f0105280:	7f f0                	jg     f0105272 <vprintfmt+0x22f>
			if ((p = va_arg(ap, char *)) == NULL)
f0105282:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105285:	89 45 14             	mov    %eax,0x14(%ebp)
f0105288:	e9 76 01 00 00       	jmp    f0105403 <vprintfmt+0x3c0>
f010528d:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105290:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105293:	eb e9                	jmp    f010527e <vprintfmt+0x23b>
	if (lflag >= 2)
f0105295:	83 f9 01             	cmp    $0x1,%ecx
f0105298:	7e 3f                	jle    f01052d9 <vprintfmt+0x296>
		return va_arg(*ap, long long);
f010529a:	8b 45 14             	mov    0x14(%ebp),%eax
f010529d:	8b 50 04             	mov    0x4(%eax),%edx
f01052a0:	8b 00                	mov    (%eax),%eax
f01052a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01052a5:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01052a8:	8b 45 14             	mov    0x14(%ebp),%eax
f01052ab:	8d 40 08             	lea    0x8(%eax),%eax
f01052ae:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01052b1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01052b5:	79 5c                	jns    f0105313 <vprintfmt+0x2d0>
				putch('-', putdat);
f01052b7:	83 ec 08             	sub    $0x8,%esp
f01052ba:	53                   	push   %ebx
f01052bb:	6a 2d                	push   $0x2d
f01052bd:	ff d6                	call   *%esi
				num = -(long long) num;
f01052bf:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01052c2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01052c5:	f7 da                	neg    %edx
f01052c7:	83 d1 00             	adc    $0x0,%ecx
f01052ca:	f7 d9                	neg    %ecx
f01052cc:	83 c4 10             	add    $0x10,%esp
			base = 10;
f01052cf:	b8 0a 00 00 00       	mov    $0xa,%eax
f01052d4:	e9 10 01 00 00       	jmp    f01053e9 <vprintfmt+0x3a6>
	else if (lflag)
f01052d9:	85 c9                	test   %ecx,%ecx
f01052db:	75 1b                	jne    f01052f8 <vprintfmt+0x2b5>
		return va_arg(*ap, int);
f01052dd:	8b 45 14             	mov    0x14(%ebp),%eax
f01052e0:	8b 00                	mov    (%eax),%eax
f01052e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01052e5:	89 c1                	mov    %eax,%ecx
f01052e7:	c1 f9 1f             	sar    $0x1f,%ecx
f01052ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01052ed:	8b 45 14             	mov    0x14(%ebp),%eax
f01052f0:	8d 40 04             	lea    0x4(%eax),%eax
f01052f3:	89 45 14             	mov    %eax,0x14(%ebp)
f01052f6:	eb b9                	jmp    f01052b1 <vprintfmt+0x26e>
		return va_arg(*ap, long);
f01052f8:	8b 45 14             	mov    0x14(%ebp),%eax
f01052fb:	8b 00                	mov    (%eax),%eax
f01052fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105300:	89 c1                	mov    %eax,%ecx
f0105302:	c1 f9 1f             	sar    $0x1f,%ecx
f0105305:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105308:	8b 45 14             	mov    0x14(%ebp),%eax
f010530b:	8d 40 04             	lea    0x4(%eax),%eax
f010530e:	89 45 14             	mov    %eax,0x14(%ebp)
f0105311:	eb 9e                	jmp    f01052b1 <vprintfmt+0x26e>
			num = getint(&ap, lflag);
f0105313:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105316:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0105319:	b8 0a 00 00 00       	mov    $0xa,%eax
f010531e:	e9 c6 00 00 00       	jmp    f01053e9 <vprintfmt+0x3a6>
	if (lflag >= 2)
f0105323:	83 f9 01             	cmp    $0x1,%ecx
f0105326:	7e 18                	jle    f0105340 <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
f0105328:	8b 45 14             	mov    0x14(%ebp),%eax
f010532b:	8b 10                	mov    (%eax),%edx
f010532d:	8b 48 04             	mov    0x4(%eax),%ecx
f0105330:	8d 40 08             	lea    0x8(%eax),%eax
f0105333:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105336:	b8 0a 00 00 00       	mov    $0xa,%eax
f010533b:	e9 a9 00 00 00       	jmp    f01053e9 <vprintfmt+0x3a6>
	else if (lflag)
f0105340:	85 c9                	test   %ecx,%ecx
f0105342:	75 1a                	jne    f010535e <vprintfmt+0x31b>
		return va_arg(*ap, unsigned int);
f0105344:	8b 45 14             	mov    0x14(%ebp),%eax
f0105347:	8b 10                	mov    (%eax),%edx
f0105349:	b9 00 00 00 00       	mov    $0x0,%ecx
f010534e:	8d 40 04             	lea    0x4(%eax),%eax
f0105351:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105354:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105359:	e9 8b 00 00 00       	jmp    f01053e9 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f010535e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105361:	8b 10                	mov    (%eax),%edx
f0105363:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105368:	8d 40 04             	lea    0x4(%eax),%eax
f010536b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010536e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105373:	eb 74                	jmp    f01053e9 <vprintfmt+0x3a6>
	if (lflag >= 2)
f0105375:	83 f9 01             	cmp    $0x1,%ecx
f0105378:	7e 15                	jle    f010538f <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
f010537a:	8b 45 14             	mov    0x14(%ebp),%eax
f010537d:	8b 10                	mov    (%eax),%edx
f010537f:	8b 48 04             	mov    0x4(%eax),%ecx
f0105382:	8d 40 08             	lea    0x8(%eax),%eax
f0105385:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0105388:	b8 08 00 00 00       	mov    $0x8,%eax
f010538d:	eb 5a                	jmp    f01053e9 <vprintfmt+0x3a6>
	else if (lflag)
f010538f:	85 c9                	test   %ecx,%ecx
f0105391:	75 17                	jne    f01053aa <vprintfmt+0x367>
		return va_arg(*ap, unsigned int);
f0105393:	8b 45 14             	mov    0x14(%ebp),%eax
f0105396:	8b 10                	mov    (%eax),%edx
f0105398:	b9 00 00 00 00       	mov    $0x0,%ecx
f010539d:	8d 40 04             	lea    0x4(%eax),%eax
f01053a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01053a3:	b8 08 00 00 00       	mov    $0x8,%eax
f01053a8:	eb 3f                	jmp    f01053e9 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f01053aa:	8b 45 14             	mov    0x14(%ebp),%eax
f01053ad:	8b 10                	mov    (%eax),%edx
f01053af:	b9 00 00 00 00       	mov    $0x0,%ecx
f01053b4:	8d 40 04             	lea    0x4(%eax),%eax
f01053b7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01053ba:	b8 08 00 00 00       	mov    $0x8,%eax
f01053bf:	eb 28                	jmp    f01053e9 <vprintfmt+0x3a6>
			putch('0', putdat);
f01053c1:	83 ec 08             	sub    $0x8,%esp
f01053c4:	53                   	push   %ebx
f01053c5:	6a 30                	push   $0x30
f01053c7:	ff d6                	call   *%esi
			putch('x', putdat);
f01053c9:	83 c4 08             	add    $0x8,%esp
f01053cc:	53                   	push   %ebx
f01053cd:	6a 78                	push   $0x78
f01053cf:	ff d6                	call   *%esi
			num = (unsigned long long)
f01053d1:	8b 45 14             	mov    0x14(%ebp),%eax
f01053d4:	8b 10                	mov    (%eax),%edx
f01053d6:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01053db:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01053de:	8d 40 04             	lea    0x4(%eax),%eax
f01053e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01053e4:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01053e9:	83 ec 0c             	sub    $0xc,%esp
f01053ec:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01053f0:	57                   	push   %edi
f01053f1:	ff 75 e0             	pushl  -0x20(%ebp)
f01053f4:	50                   	push   %eax
f01053f5:	51                   	push   %ecx
f01053f6:	52                   	push   %edx
f01053f7:	89 da                	mov    %ebx,%edx
f01053f9:	89 f0                	mov    %esi,%eax
f01053fb:	e8 5d fb ff ff       	call   f0104f5d <printnum>
			break;
f0105400:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0105403:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105406:	47                   	inc    %edi
f0105407:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010540b:	83 f8 25             	cmp    $0x25,%eax
f010540e:	0f 84 46 fc ff ff    	je     f010505a <vprintfmt+0x17>
			if (ch == '\0')
f0105414:	85 c0                	test   %eax,%eax
f0105416:	0f 84 89 00 00 00    	je     f01054a5 <vprintfmt+0x462>
			putch(ch, putdat);
f010541c:	83 ec 08             	sub    $0x8,%esp
f010541f:	53                   	push   %ebx
f0105420:	50                   	push   %eax
f0105421:	ff d6                	call   *%esi
f0105423:	83 c4 10             	add    $0x10,%esp
f0105426:	eb de                	jmp    f0105406 <vprintfmt+0x3c3>
	if (lflag >= 2)
f0105428:	83 f9 01             	cmp    $0x1,%ecx
f010542b:	7e 15                	jle    f0105442 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
f010542d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105430:	8b 10                	mov    (%eax),%edx
f0105432:	8b 48 04             	mov    0x4(%eax),%ecx
f0105435:	8d 40 08             	lea    0x8(%eax),%eax
f0105438:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010543b:	b8 10 00 00 00       	mov    $0x10,%eax
f0105440:	eb a7                	jmp    f01053e9 <vprintfmt+0x3a6>
	else if (lflag)
f0105442:	85 c9                	test   %ecx,%ecx
f0105444:	75 17                	jne    f010545d <vprintfmt+0x41a>
		return va_arg(*ap, unsigned int);
f0105446:	8b 45 14             	mov    0x14(%ebp),%eax
f0105449:	8b 10                	mov    (%eax),%edx
f010544b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105450:	8d 40 04             	lea    0x4(%eax),%eax
f0105453:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105456:	b8 10 00 00 00       	mov    $0x10,%eax
f010545b:	eb 8c                	jmp    f01053e9 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f010545d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105460:	8b 10                	mov    (%eax),%edx
f0105462:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105467:	8d 40 04             	lea    0x4(%eax),%eax
f010546a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010546d:	b8 10 00 00 00       	mov    $0x10,%eax
f0105472:	e9 72 ff ff ff       	jmp    f01053e9 <vprintfmt+0x3a6>
			putch(ch, putdat);
f0105477:	83 ec 08             	sub    $0x8,%esp
f010547a:	53                   	push   %ebx
f010547b:	6a 25                	push   $0x25
f010547d:	ff d6                	call   *%esi
			break;
f010547f:	83 c4 10             	add    $0x10,%esp
f0105482:	e9 7c ff ff ff       	jmp    f0105403 <vprintfmt+0x3c0>
			putch('%', putdat);
f0105487:	83 ec 08             	sub    $0x8,%esp
f010548a:	53                   	push   %ebx
f010548b:	6a 25                	push   $0x25
f010548d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010548f:	83 c4 10             	add    $0x10,%esp
f0105492:	89 f8                	mov    %edi,%eax
f0105494:	eb 01                	jmp    f0105497 <vprintfmt+0x454>
f0105496:	48                   	dec    %eax
f0105497:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010549b:	75 f9                	jne    f0105496 <vprintfmt+0x453>
f010549d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01054a0:	e9 5e ff ff ff       	jmp    f0105403 <vprintfmt+0x3c0>
}
f01054a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01054a8:	5b                   	pop    %ebx
f01054a9:	5e                   	pop    %esi
f01054aa:	5f                   	pop    %edi
f01054ab:	5d                   	pop    %ebp
f01054ac:	c3                   	ret    

f01054ad <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01054ad:	55                   	push   %ebp
f01054ae:	89 e5                	mov    %esp,%ebp
f01054b0:	83 ec 18             	sub    $0x18,%esp
f01054b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01054b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01054b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01054bc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01054c0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01054c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01054ca:	85 c0                	test   %eax,%eax
f01054cc:	74 26                	je     f01054f4 <vsnprintf+0x47>
f01054ce:	85 d2                	test   %edx,%edx
f01054d0:	7e 29                	jle    f01054fb <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01054d2:	ff 75 14             	pushl  0x14(%ebp)
f01054d5:	ff 75 10             	pushl  0x10(%ebp)
f01054d8:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01054db:	50                   	push   %eax
f01054dc:	68 0a 50 10 f0       	push   $0xf010500a
f01054e1:	e8 5d fb ff ff       	call   f0105043 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01054e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01054e9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01054ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01054ef:	83 c4 10             	add    $0x10,%esp
}
f01054f2:	c9                   	leave  
f01054f3:	c3                   	ret    
		return -E_INVAL;
f01054f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01054f9:	eb f7                	jmp    f01054f2 <vsnprintf+0x45>
f01054fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105500:	eb f0                	jmp    f01054f2 <vsnprintf+0x45>

f0105502 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105502:	55                   	push   %ebp
f0105503:	89 e5                	mov    %esp,%ebp
f0105505:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105508:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010550b:	50                   	push   %eax
f010550c:	ff 75 10             	pushl  0x10(%ebp)
f010550f:	ff 75 0c             	pushl  0xc(%ebp)
f0105512:	ff 75 08             	pushl  0x8(%ebp)
f0105515:	e8 93 ff ff ff       	call   f01054ad <vsnprintf>
	va_end(ap);

	return rc;
}
f010551a:	c9                   	leave  
f010551b:	c3                   	ret    

f010551c <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010551c:	55                   	push   %ebp
f010551d:	89 e5                	mov    %esp,%ebp
f010551f:	57                   	push   %edi
f0105520:	56                   	push   %esi
f0105521:	53                   	push   %ebx
f0105522:	83 ec 0c             	sub    $0xc,%esp
f0105525:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105528:	85 c0                	test   %eax,%eax
f010552a:	74 11                	je     f010553d <readline+0x21>
		cprintf("%s", prompt);
f010552c:	83 ec 08             	sub    $0x8,%esp
f010552f:	50                   	push   %eax
f0105530:	68 d5 76 10 f0       	push   $0xf01076d5
f0105535:	e8 59 ea ff ff       	call   f0103f93 <cprintf>
f010553a:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010553d:	83 ec 0c             	sub    $0xc,%esp
f0105540:	6a 00                	push   $0x0
f0105542:	e8 14 b3 ff ff       	call   f010085b <iscons>
f0105547:	89 c7                	mov    %eax,%edi
f0105549:	83 c4 10             	add    $0x10,%esp
	i = 0;
f010554c:	be 00 00 00 00       	mov    $0x0,%esi
f0105551:	eb 6f                	jmp    f01055c2 <readline+0xa6>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0105553:	83 ec 08             	sub    $0x8,%esp
f0105556:	50                   	push   %eax
f0105557:	68 c4 81 10 f0       	push   $0xf01081c4
f010555c:	e8 32 ea ff ff       	call   f0103f93 <cprintf>
			return NULL;
f0105561:	83 c4 10             	add    $0x10,%esp
f0105564:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0105569:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010556c:	5b                   	pop    %ebx
f010556d:	5e                   	pop    %esi
f010556e:	5f                   	pop    %edi
f010556f:	5d                   	pop    %ebp
f0105570:	c3                   	ret    
				cputchar('\b');
f0105571:	83 ec 0c             	sub    $0xc,%esp
f0105574:	6a 08                	push   $0x8
f0105576:	e8 bf b2 ff ff       	call   f010083a <cputchar>
f010557b:	83 c4 10             	add    $0x10,%esp
f010557e:	eb 41                	jmp    f01055c1 <readline+0xa5>
				cputchar(c);
f0105580:	83 ec 0c             	sub    $0xc,%esp
f0105583:	53                   	push   %ebx
f0105584:	e8 b1 b2 ff ff       	call   f010083a <cputchar>
f0105589:	83 c4 10             	add    $0x10,%esp
f010558c:	eb 5a                	jmp    f01055e8 <readline+0xcc>
		} else if (c == '\n' || c == '\r') {
f010558e:	83 fb 0a             	cmp    $0xa,%ebx
f0105591:	74 05                	je     f0105598 <readline+0x7c>
f0105593:	83 fb 0d             	cmp    $0xd,%ebx
f0105596:	75 2a                	jne    f01055c2 <readline+0xa6>
			if (echoing)
f0105598:	85 ff                	test   %edi,%edi
f010559a:	75 0e                	jne    f01055aa <readline+0x8e>
			buf[i] = 0;
f010559c:	c6 86 80 1a 29 f0 00 	movb   $0x0,-0xfd6e580(%esi)
			return buf;
f01055a3:	b8 80 1a 29 f0       	mov    $0xf0291a80,%eax
f01055a8:	eb bf                	jmp    f0105569 <readline+0x4d>
				cputchar('\n');
f01055aa:	83 ec 0c             	sub    $0xc,%esp
f01055ad:	6a 0a                	push   $0xa
f01055af:	e8 86 b2 ff ff       	call   f010083a <cputchar>
f01055b4:	83 c4 10             	add    $0x10,%esp
f01055b7:	eb e3                	jmp    f010559c <readline+0x80>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01055b9:	85 f6                	test   %esi,%esi
f01055bb:	7e 3c                	jle    f01055f9 <readline+0xdd>
			if (echoing)
f01055bd:	85 ff                	test   %edi,%edi
f01055bf:	75 b0                	jne    f0105571 <readline+0x55>
			i--;
f01055c1:	4e                   	dec    %esi
		c = getchar();
f01055c2:	e8 83 b2 ff ff       	call   f010084a <getchar>
f01055c7:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01055c9:	85 c0                	test   %eax,%eax
f01055cb:	78 86                	js     f0105553 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01055cd:	83 f8 08             	cmp    $0x8,%eax
f01055d0:	74 21                	je     f01055f3 <readline+0xd7>
f01055d2:	83 f8 7f             	cmp    $0x7f,%eax
f01055d5:	74 e2                	je     f01055b9 <readline+0x9d>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01055d7:	83 f8 1f             	cmp    $0x1f,%eax
f01055da:	7e b2                	jle    f010558e <readline+0x72>
f01055dc:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01055e2:	7f aa                	jg     f010558e <readline+0x72>
			if (echoing)
f01055e4:	85 ff                	test   %edi,%edi
f01055e6:	75 98                	jne    f0105580 <readline+0x64>
			buf[i++] = c;
f01055e8:	88 9e 80 1a 29 f0    	mov    %bl,-0xfd6e580(%esi)
f01055ee:	8d 76 01             	lea    0x1(%esi),%esi
f01055f1:	eb cf                	jmp    f01055c2 <readline+0xa6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01055f3:	85 f6                	test   %esi,%esi
f01055f5:	7e cb                	jle    f01055c2 <readline+0xa6>
f01055f7:	eb c4                	jmp    f01055bd <readline+0xa1>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01055f9:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01055ff:	7e e3                	jle    f01055e4 <readline+0xc8>
f0105601:	eb bf                	jmp    f01055c2 <readline+0xa6>

f0105603 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105603:	55                   	push   %ebp
f0105604:	89 e5                	mov    %esp,%ebp
f0105606:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105609:	b8 00 00 00 00       	mov    $0x0,%eax
f010560e:	eb 01                	jmp    f0105611 <strlen+0xe>
		n++;
f0105610:	40                   	inc    %eax
	for (n = 0; *s != '\0'; s++)
f0105611:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105615:	75 f9                	jne    f0105610 <strlen+0xd>
	return n;
}
f0105617:	5d                   	pop    %ebp
f0105618:	c3                   	ret    

f0105619 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105619:	55                   	push   %ebp
f010561a:	89 e5                	mov    %esp,%ebp
f010561c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010561f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105622:	b8 00 00 00 00       	mov    $0x0,%eax
f0105627:	eb 01                	jmp    f010562a <strnlen+0x11>
		n++;
f0105629:	40                   	inc    %eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010562a:	39 d0                	cmp    %edx,%eax
f010562c:	74 06                	je     f0105634 <strnlen+0x1b>
f010562e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105632:	75 f5                	jne    f0105629 <strnlen+0x10>
	return n;
}
f0105634:	5d                   	pop    %ebp
f0105635:	c3                   	ret    

f0105636 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105636:	55                   	push   %ebp
f0105637:	89 e5                	mov    %esp,%ebp
f0105639:	53                   	push   %ebx
f010563a:	8b 45 08             	mov    0x8(%ebp),%eax
f010563d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105640:	89 c2                	mov    %eax,%edx
f0105642:	41                   	inc    %ecx
f0105643:	42                   	inc    %edx
f0105644:	8a 59 ff             	mov    -0x1(%ecx),%bl
f0105647:	88 5a ff             	mov    %bl,-0x1(%edx)
f010564a:	84 db                	test   %bl,%bl
f010564c:	75 f4                	jne    f0105642 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010564e:	5b                   	pop    %ebx
f010564f:	5d                   	pop    %ebp
f0105650:	c3                   	ret    

f0105651 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105651:	55                   	push   %ebp
f0105652:	89 e5                	mov    %esp,%ebp
f0105654:	53                   	push   %ebx
f0105655:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105658:	53                   	push   %ebx
f0105659:	e8 a5 ff ff ff       	call   f0105603 <strlen>
f010565e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105661:	ff 75 0c             	pushl  0xc(%ebp)
f0105664:	01 d8                	add    %ebx,%eax
f0105666:	50                   	push   %eax
f0105667:	e8 ca ff ff ff       	call   f0105636 <strcpy>
	return dst;
}
f010566c:	89 d8                	mov    %ebx,%eax
f010566e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105671:	c9                   	leave  
f0105672:	c3                   	ret    

f0105673 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105673:	55                   	push   %ebp
f0105674:	89 e5                	mov    %esp,%ebp
f0105676:	56                   	push   %esi
f0105677:	53                   	push   %ebx
f0105678:	8b 75 08             	mov    0x8(%ebp),%esi
f010567b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010567e:	89 f3                	mov    %esi,%ebx
f0105680:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105683:	89 f2                	mov    %esi,%edx
f0105685:	39 da                	cmp    %ebx,%edx
f0105687:	74 0e                	je     f0105697 <strncpy+0x24>
		*dst++ = *src;
f0105689:	42                   	inc    %edx
f010568a:	8a 01                	mov    (%ecx),%al
f010568c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f010568f:	80 39 00             	cmpb   $0x0,(%ecx)
f0105692:	74 f1                	je     f0105685 <strncpy+0x12>
			src++;
f0105694:	41                   	inc    %ecx
f0105695:	eb ee                	jmp    f0105685 <strncpy+0x12>
	}
	return ret;
}
f0105697:	89 f0                	mov    %esi,%eax
f0105699:	5b                   	pop    %ebx
f010569a:	5e                   	pop    %esi
f010569b:	5d                   	pop    %ebp
f010569c:	c3                   	ret    

f010569d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010569d:	55                   	push   %ebp
f010569e:	89 e5                	mov    %esp,%ebp
f01056a0:	56                   	push   %esi
f01056a1:	53                   	push   %ebx
f01056a2:	8b 75 08             	mov    0x8(%ebp),%esi
f01056a5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01056a8:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01056ab:	85 c0                	test   %eax,%eax
f01056ad:	74 20                	je     f01056cf <strlcpy+0x32>
f01056af:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
f01056b3:	89 f0                	mov    %esi,%eax
f01056b5:	eb 05                	jmp    f01056bc <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01056b7:	42                   	inc    %edx
f01056b8:	40                   	inc    %eax
f01056b9:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f01056bc:	39 d8                	cmp    %ebx,%eax
f01056be:	74 06                	je     f01056c6 <strlcpy+0x29>
f01056c0:	8a 0a                	mov    (%edx),%cl
f01056c2:	84 c9                	test   %cl,%cl
f01056c4:	75 f1                	jne    f01056b7 <strlcpy+0x1a>
		*dst = '\0';
f01056c6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01056c9:	29 f0                	sub    %esi,%eax
}
f01056cb:	5b                   	pop    %ebx
f01056cc:	5e                   	pop    %esi
f01056cd:	5d                   	pop    %ebp
f01056ce:	c3                   	ret    
f01056cf:	89 f0                	mov    %esi,%eax
f01056d1:	eb f6                	jmp    f01056c9 <strlcpy+0x2c>

f01056d3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01056d3:	55                   	push   %ebp
f01056d4:	89 e5                	mov    %esp,%ebp
f01056d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01056d9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01056dc:	eb 02                	jmp    f01056e0 <strcmp+0xd>
		p++, q++;
f01056de:	41                   	inc    %ecx
f01056df:	42                   	inc    %edx
	while (*p && *p == *q)
f01056e0:	8a 01                	mov    (%ecx),%al
f01056e2:	84 c0                	test   %al,%al
f01056e4:	74 04                	je     f01056ea <strcmp+0x17>
f01056e6:	3a 02                	cmp    (%edx),%al
f01056e8:	74 f4                	je     f01056de <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01056ea:	0f b6 c0             	movzbl %al,%eax
f01056ed:	0f b6 12             	movzbl (%edx),%edx
f01056f0:	29 d0                	sub    %edx,%eax
}
f01056f2:	5d                   	pop    %ebp
f01056f3:	c3                   	ret    

f01056f4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01056f4:	55                   	push   %ebp
f01056f5:	89 e5                	mov    %esp,%ebp
f01056f7:	53                   	push   %ebx
f01056f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01056fb:	8b 55 0c             	mov    0xc(%ebp),%edx
f01056fe:	89 c3                	mov    %eax,%ebx
f0105700:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105703:	eb 02                	jmp    f0105707 <strncmp+0x13>
		n--, p++, q++;
f0105705:	40                   	inc    %eax
f0105706:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
f0105707:	39 d8                	cmp    %ebx,%eax
f0105709:	74 15                	je     f0105720 <strncmp+0x2c>
f010570b:	8a 08                	mov    (%eax),%cl
f010570d:	84 c9                	test   %cl,%cl
f010570f:	74 04                	je     f0105715 <strncmp+0x21>
f0105711:	3a 0a                	cmp    (%edx),%cl
f0105713:	74 f0                	je     f0105705 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105715:	0f b6 00             	movzbl (%eax),%eax
f0105718:	0f b6 12             	movzbl (%edx),%edx
f010571b:	29 d0                	sub    %edx,%eax
}
f010571d:	5b                   	pop    %ebx
f010571e:	5d                   	pop    %ebp
f010571f:	c3                   	ret    
		return 0;
f0105720:	b8 00 00 00 00       	mov    $0x0,%eax
f0105725:	eb f6                	jmp    f010571d <strncmp+0x29>

f0105727 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105727:	55                   	push   %ebp
f0105728:	89 e5                	mov    %esp,%ebp
f010572a:	8b 45 08             	mov    0x8(%ebp),%eax
f010572d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0105730:	8a 10                	mov    (%eax),%dl
f0105732:	84 d2                	test   %dl,%dl
f0105734:	74 07                	je     f010573d <strchr+0x16>
		if (*s == c)
f0105736:	38 ca                	cmp    %cl,%dl
f0105738:	74 08                	je     f0105742 <strchr+0x1b>
	for (; *s; s++)
f010573a:	40                   	inc    %eax
f010573b:	eb f3                	jmp    f0105730 <strchr+0x9>
			return (char *) s;
	return 0;
f010573d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105742:	5d                   	pop    %ebp
f0105743:	c3                   	ret    

f0105744 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105744:	55                   	push   %ebp
f0105745:	89 e5                	mov    %esp,%ebp
f0105747:	8b 45 08             	mov    0x8(%ebp),%eax
f010574a:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010574d:	8a 10                	mov    (%eax),%dl
f010574f:	84 d2                	test   %dl,%dl
f0105751:	74 07                	je     f010575a <strfind+0x16>
		if (*s == c)
f0105753:	38 ca                	cmp    %cl,%dl
f0105755:	74 03                	je     f010575a <strfind+0x16>
	for (; *s; s++)
f0105757:	40                   	inc    %eax
f0105758:	eb f3                	jmp    f010574d <strfind+0x9>
			break;
	return (char *) s;
}
f010575a:	5d                   	pop    %ebp
f010575b:	c3                   	ret    

f010575c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010575c:	55                   	push   %ebp
f010575d:	89 e5                	mov    %esp,%ebp
f010575f:	57                   	push   %edi
f0105760:	56                   	push   %esi
f0105761:	53                   	push   %ebx
f0105762:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105765:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105768:	85 c9                	test   %ecx,%ecx
f010576a:	74 13                	je     f010577f <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010576c:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105772:	75 05                	jne    f0105779 <memset+0x1d>
f0105774:	f6 c1 03             	test   $0x3,%cl
f0105777:	74 0d                	je     f0105786 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105779:	8b 45 0c             	mov    0xc(%ebp),%eax
f010577c:	fc                   	cld    
f010577d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010577f:	89 f8                	mov    %edi,%eax
f0105781:	5b                   	pop    %ebx
f0105782:	5e                   	pop    %esi
f0105783:	5f                   	pop    %edi
f0105784:	5d                   	pop    %ebp
f0105785:	c3                   	ret    
		c &= 0xFF;
f0105786:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010578a:	89 d3                	mov    %edx,%ebx
f010578c:	c1 e3 08             	shl    $0x8,%ebx
f010578f:	89 d0                	mov    %edx,%eax
f0105791:	c1 e0 18             	shl    $0x18,%eax
f0105794:	89 d6                	mov    %edx,%esi
f0105796:	c1 e6 10             	shl    $0x10,%esi
f0105799:	09 f0                	or     %esi,%eax
f010579b:	09 c2                	or     %eax,%edx
f010579d:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f010579f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01057a2:	89 d0                	mov    %edx,%eax
f01057a4:	fc                   	cld    
f01057a5:	f3 ab                	rep stos %eax,%es:(%edi)
f01057a7:	eb d6                	jmp    f010577f <memset+0x23>

f01057a9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01057a9:	55                   	push   %ebp
f01057aa:	89 e5                	mov    %esp,%ebp
f01057ac:	57                   	push   %edi
f01057ad:	56                   	push   %esi
f01057ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01057b1:	8b 75 0c             	mov    0xc(%ebp),%esi
f01057b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01057b7:	39 c6                	cmp    %eax,%esi
f01057b9:	73 33                	jae    f01057ee <memmove+0x45>
f01057bb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01057be:	39 c2                	cmp    %eax,%edx
f01057c0:	76 2c                	jbe    f01057ee <memmove+0x45>
		s += n;
		d += n;
f01057c2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01057c5:	89 d6                	mov    %edx,%esi
f01057c7:	09 fe                	or     %edi,%esi
f01057c9:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01057cf:	74 0a                	je     f01057db <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01057d1:	4f                   	dec    %edi
f01057d2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01057d5:	fd                   	std    
f01057d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01057d8:	fc                   	cld    
f01057d9:	eb 21                	jmp    f01057fc <memmove+0x53>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01057db:	f6 c1 03             	test   $0x3,%cl
f01057de:	75 f1                	jne    f01057d1 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01057e0:	83 ef 04             	sub    $0x4,%edi
f01057e3:	8d 72 fc             	lea    -0x4(%edx),%esi
f01057e6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01057e9:	fd                   	std    
f01057ea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01057ec:	eb ea                	jmp    f01057d8 <memmove+0x2f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01057ee:	89 f2                	mov    %esi,%edx
f01057f0:	09 c2                	or     %eax,%edx
f01057f2:	f6 c2 03             	test   $0x3,%dl
f01057f5:	74 09                	je     f0105800 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01057f7:	89 c7                	mov    %eax,%edi
f01057f9:	fc                   	cld    
f01057fa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01057fc:	5e                   	pop    %esi
f01057fd:	5f                   	pop    %edi
f01057fe:	5d                   	pop    %ebp
f01057ff:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105800:	f6 c1 03             	test   $0x3,%cl
f0105803:	75 f2                	jne    f01057f7 <memmove+0x4e>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105805:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105808:	89 c7                	mov    %eax,%edi
f010580a:	fc                   	cld    
f010580b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010580d:	eb ed                	jmp    f01057fc <memmove+0x53>

f010580f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010580f:	55                   	push   %ebp
f0105810:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105812:	ff 75 10             	pushl  0x10(%ebp)
f0105815:	ff 75 0c             	pushl  0xc(%ebp)
f0105818:	ff 75 08             	pushl  0x8(%ebp)
f010581b:	e8 89 ff ff ff       	call   f01057a9 <memmove>
}
f0105820:	c9                   	leave  
f0105821:	c3                   	ret    

f0105822 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105822:	55                   	push   %ebp
f0105823:	89 e5                	mov    %esp,%ebp
f0105825:	56                   	push   %esi
f0105826:	53                   	push   %ebx
f0105827:	8b 45 08             	mov    0x8(%ebp),%eax
f010582a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010582d:	89 c6                	mov    %eax,%esi
f010582f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105832:	39 f0                	cmp    %esi,%eax
f0105834:	74 16                	je     f010584c <memcmp+0x2a>
		if (*s1 != *s2)
f0105836:	8a 08                	mov    (%eax),%cl
f0105838:	8a 1a                	mov    (%edx),%bl
f010583a:	38 d9                	cmp    %bl,%cl
f010583c:	75 04                	jne    f0105842 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010583e:	40                   	inc    %eax
f010583f:	42                   	inc    %edx
f0105840:	eb f0                	jmp    f0105832 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0105842:	0f b6 c1             	movzbl %cl,%eax
f0105845:	0f b6 db             	movzbl %bl,%ebx
f0105848:	29 d8                	sub    %ebx,%eax
f010584a:	eb 05                	jmp    f0105851 <memcmp+0x2f>
	}

	return 0;
f010584c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105851:	5b                   	pop    %ebx
f0105852:	5e                   	pop    %esi
f0105853:	5d                   	pop    %ebp
f0105854:	c3                   	ret    

f0105855 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105855:	55                   	push   %ebp
f0105856:	89 e5                	mov    %esp,%ebp
f0105858:	8b 45 08             	mov    0x8(%ebp),%eax
f010585b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010585e:	89 c2                	mov    %eax,%edx
f0105860:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105863:	39 d0                	cmp    %edx,%eax
f0105865:	73 07                	jae    f010586e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105867:	38 08                	cmp    %cl,(%eax)
f0105869:	74 03                	je     f010586e <memfind+0x19>
	for (; s < ends; s++)
f010586b:	40                   	inc    %eax
f010586c:	eb f5                	jmp    f0105863 <memfind+0xe>
			break;
	return (void *) s;
}
f010586e:	5d                   	pop    %ebp
f010586f:	c3                   	ret    

f0105870 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105870:	55                   	push   %ebp
f0105871:	89 e5                	mov    %esp,%ebp
f0105873:	57                   	push   %edi
f0105874:	56                   	push   %esi
f0105875:	53                   	push   %ebx
f0105876:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105879:	eb 01                	jmp    f010587c <strtol+0xc>
		s++;
f010587b:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f010587c:	8a 01                	mov    (%ecx),%al
f010587e:	3c 20                	cmp    $0x20,%al
f0105880:	74 f9                	je     f010587b <strtol+0xb>
f0105882:	3c 09                	cmp    $0x9,%al
f0105884:	74 f5                	je     f010587b <strtol+0xb>

	// plus/minus sign
	if (*s == '+')
f0105886:	3c 2b                	cmp    $0x2b,%al
f0105888:	74 2b                	je     f01058b5 <strtol+0x45>
		s++;
	else if (*s == '-')
f010588a:	3c 2d                	cmp    $0x2d,%al
f010588c:	74 2f                	je     f01058bd <strtol+0x4d>
	int neg = 0;
f010588e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105893:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f010589a:	75 12                	jne    f01058ae <strtol+0x3e>
f010589c:	80 39 30             	cmpb   $0x30,(%ecx)
f010589f:	74 24                	je     f01058c5 <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01058a1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01058a5:	75 07                	jne    f01058ae <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01058a7:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f01058ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01058b3:	eb 4e                	jmp    f0105903 <strtol+0x93>
		s++;
f01058b5:	41                   	inc    %ecx
	int neg = 0;
f01058b6:	bf 00 00 00 00       	mov    $0x0,%edi
f01058bb:	eb d6                	jmp    f0105893 <strtol+0x23>
		s++, neg = 1;
f01058bd:	41                   	inc    %ecx
f01058be:	bf 01 00 00 00       	mov    $0x1,%edi
f01058c3:	eb ce                	jmp    f0105893 <strtol+0x23>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01058c5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01058c9:	74 10                	je     f01058db <strtol+0x6b>
	else if (base == 0 && s[0] == '0')
f01058cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01058cf:	75 dd                	jne    f01058ae <strtol+0x3e>
		s++, base = 8;
f01058d1:	41                   	inc    %ecx
f01058d2:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f01058d9:	eb d3                	jmp    f01058ae <strtol+0x3e>
		s += 2, base = 16;
f01058db:	83 c1 02             	add    $0x2,%ecx
f01058de:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f01058e5:	eb c7                	jmp    f01058ae <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01058e7:	8d 72 9f             	lea    -0x61(%edx),%esi
f01058ea:	89 f3                	mov    %esi,%ebx
f01058ec:	80 fb 19             	cmp    $0x19,%bl
f01058ef:	77 24                	ja     f0105915 <strtol+0xa5>
			dig = *s - 'a' + 10;
f01058f1:	0f be d2             	movsbl %dl,%edx
f01058f4:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01058f7:	3b 55 10             	cmp    0x10(%ebp),%edx
f01058fa:	7d 2b                	jge    f0105927 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
f01058fc:	41                   	inc    %ecx
f01058fd:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105901:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0105903:	8a 11                	mov    (%ecx),%dl
f0105905:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0105908:	80 fb 09             	cmp    $0x9,%bl
f010590b:	77 da                	ja     f01058e7 <strtol+0x77>
			dig = *s - '0';
f010590d:	0f be d2             	movsbl %dl,%edx
f0105910:	83 ea 30             	sub    $0x30,%edx
f0105913:	eb e2                	jmp    f01058f7 <strtol+0x87>
		else if (*s >= 'A' && *s <= 'Z')
f0105915:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105918:	89 f3                	mov    %esi,%ebx
f010591a:	80 fb 19             	cmp    $0x19,%bl
f010591d:	77 08                	ja     f0105927 <strtol+0xb7>
			dig = *s - 'A' + 10;
f010591f:	0f be d2             	movsbl %dl,%edx
f0105922:	83 ea 37             	sub    $0x37,%edx
f0105925:	eb d0                	jmp    f01058f7 <strtol+0x87>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105927:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010592b:	74 05                	je     f0105932 <strtol+0xc2>
		*endptr = (char *) s;
f010592d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105930:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0105932:	85 ff                	test   %edi,%edi
f0105934:	74 02                	je     f0105938 <strtol+0xc8>
f0105936:	f7 d8                	neg    %eax
}
f0105938:	5b                   	pop    %ebx
f0105939:	5e                   	pop    %esi
f010593a:	5f                   	pop    %edi
f010593b:	5d                   	pop    %ebp
f010593c:	c3                   	ret    

f010593d <strtoul>:

unsigned long
strtoul(const char *s, char **endptr, int base)
{
f010593d:	55                   	push   %ebp
f010593e:	89 e5                	mov    %esp,%ebp
f0105940:	57                   	push   %edi
f0105941:	56                   	push   %esi
f0105942:	53                   	push   %ebx
f0105943:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	unsigned long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105946:	eb 01                	jmp    f0105949 <strtoul+0xc>
		s++;
f0105948:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f0105949:	8a 01                	mov    (%ecx),%al
f010594b:	3c 20                	cmp    $0x20,%al
f010594d:	74 f9                	je     f0105948 <strtoul+0xb>
f010594f:	3c 09                	cmp    $0x9,%al
f0105951:	74 f5                	je     f0105948 <strtoul+0xb>

	// plus/minus sign
	if (*s == '+')
f0105953:	3c 2b                	cmp    $0x2b,%al
f0105955:	74 2b                	je     f0105982 <strtoul+0x45>
		s++;
	else if (*s == '-')
f0105957:	3c 2d                	cmp    $0x2d,%al
f0105959:	74 2f                	je     f010598a <strtoul+0x4d>
	int neg = 0;
f010595b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105960:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f0105967:	75 12                	jne    f010597b <strtoul+0x3e>
f0105969:	80 39 30             	cmpb   $0x30,(%ecx)
f010596c:	74 24                	je     f0105992 <strtoul+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010596e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0105972:	75 07                	jne    f010597b <strtoul+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105974:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f010597b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105980:	eb 4e                	jmp    f01059d0 <strtoul+0x93>
		s++;
f0105982:	41                   	inc    %ecx
	int neg = 0;
f0105983:	bf 00 00 00 00       	mov    $0x0,%edi
f0105988:	eb d6                	jmp    f0105960 <strtoul+0x23>
		s++, neg = 1;
f010598a:	41                   	inc    %ecx
f010598b:	bf 01 00 00 00       	mov    $0x1,%edi
f0105990:	eb ce                	jmp    f0105960 <strtoul+0x23>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105992:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105996:	74 10                	je     f01059a8 <strtoul+0x6b>
	else if (base == 0 && s[0] == '0')
f0105998:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010599c:	75 dd                	jne    f010597b <strtoul+0x3e>
		s++, base = 8;
f010599e:	41                   	inc    %ecx
f010599f:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f01059a6:	eb d3                	jmp    f010597b <strtoul+0x3e>
		s += 2, base = 16;
f01059a8:	83 c1 02             	add    $0x2,%ecx
f01059ab:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f01059b2:	eb c7                	jmp    f010597b <strtoul+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01059b4:	8d 72 9f             	lea    -0x61(%edx),%esi
f01059b7:	89 f3                	mov    %esi,%ebx
f01059b9:	80 fb 19             	cmp    $0x19,%bl
f01059bc:	77 24                	ja     f01059e2 <strtoul+0xa5>
			dig = *s - 'a' + 10;
f01059be:	0f be d2             	movsbl %dl,%edx
f01059c1:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01059c4:	3b 55 10             	cmp    0x10(%ebp),%edx
f01059c7:	7d 2b                	jge    f01059f4 <strtoul+0xb7>
			break;
		s++, val = (val * base) + dig;
f01059c9:	41                   	inc    %ecx
f01059ca:	0f af 45 10          	imul   0x10(%ebp),%eax
f01059ce:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01059d0:	8a 11                	mov    (%ecx),%dl
f01059d2:	8d 5a d0             	lea    -0x30(%edx),%ebx
f01059d5:	80 fb 09             	cmp    $0x9,%bl
f01059d8:	77 da                	ja     f01059b4 <strtoul+0x77>
			dig = *s - '0';
f01059da:	0f be d2             	movsbl %dl,%edx
f01059dd:	83 ea 30             	sub    $0x30,%edx
f01059e0:	eb e2                	jmp    f01059c4 <strtoul+0x87>
		else if (*s >= 'A' && *s <= 'Z')
f01059e2:	8d 72 bf             	lea    -0x41(%edx),%esi
f01059e5:	89 f3                	mov    %esi,%ebx
f01059e7:	80 fb 19             	cmp    $0x19,%bl
f01059ea:	77 08                	ja     f01059f4 <strtoul+0xb7>
			dig = *s - 'A' + 10;
f01059ec:	0f be d2             	movsbl %dl,%edx
f01059ef:	83 ea 37             	sub    $0x37,%edx
f01059f2:	eb d0                	jmp    f01059c4 <strtoul+0x87>
		// we don't properly detect overflow!
	}

	if (endptr)
f01059f4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01059f8:	74 05                	je     f01059ff <strtoul+0xc2>
		*endptr = (char *) s;
f01059fa:	8b 75 0c             	mov    0xc(%ebp),%esi
f01059fd:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f01059ff:	85 ff                	test   %edi,%edi
f0105a01:	74 02                	je     f0105a05 <strtoul+0xc8>
f0105a03:	f7 d8                	neg    %eax
}
f0105a05:	5b                   	pop    %ebx
f0105a06:	5e                   	pop    %esi
f0105a07:	5f                   	pop    %edi
f0105a08:	5d                   	pop    %ebp
f0105a09:	c3                   	ret    
f0105a0a:	66 90                	xchg   %ax,%ax

f0105a0c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105a0c:	fa                   	cli    

	xorw    %ax, %ax
f0105a0d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105a0f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105a11:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105a13:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105a15:	0f 01 16             	lgdtl  (%esi)
f0105a18:	74 70                	je     f0105a8a <mpsearch1+0x3>
	movl    %cr0, %eax
f0105a1a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105a1d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105a21:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105a24:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105a2a:	08 00                	or     %al,(%eax)

f0105a2c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105a2c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105a30:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105a32:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105a34:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105a36:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105a3a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105a3c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105a3e:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f0105a43:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105a46:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105a49:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105a4e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105a51:	8b 25 84 1e 29 f0    	mov    0xf0291e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105a57:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105a5c:	b8 ab 02 10 f0       	mov    $0xf01002ab,%eax
	call    *%eax
f0105a61:	ff d0                	call   *%eax

f0105a63 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105a63:	eb fe                	jmp    f0105a63 <spin>
f0105a65:	8d 76 00             	lea    0x0(%esi),%esi

f0105a68 <gdt>:
	...
f0105a70:	ff                   	(bad)  
f0105a71:	ff 00                	incl   (%eax)
f0105a73:	00 00                	add    %al,(%eax)
f0105a75:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105a7c:	00                   	.byte 0x0
f0105a7d:	92                   	xchg   %eax,%edx
f0105a7e:	cf                   	iret   
	...

f0105a80 <gdtdesc>:
f0105a80:	17                   	pop    %ss
f0105a81:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105a86 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105a86:	90                   	nop

f0105a87 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105a87:	55                   	push   %ebp
f0105a88:	89 e5                	mov    %esp,%ebp
f0105a8a:	57                   	push   %edi
f0105a8b:	56                   	push   %esi
f0105a8c:	53                   	push   %ebx
f0105a8d:	83 ec 0c             	sub    $0xc,%esp
	if (PGNUM(pa) >= npages)
f0105a90:	8b 0d 88 1e 29 f0    	mov    0xf0291e88,%ecx
f0105a96:	89 c3                	mov    %eax,%ebx
f0105a98:	c1 eb 0c             	shr    $0xc,%ebx
f0105a9b:	39 cb                	cmp    %ecx,%ebx
f0105a9d:	73 1a                	jae    f0105ab9 <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f0105a9f:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105aa5:	8d 34 02             	lea    (%edx,%eax,1),%esi
	if (PGNUM(pa) >= npages)
f0105aa8:	89 f0                	mov    %esi,%eax
f0105aaa:	c1 e8 0c             	shr    $0xc,%eax
f0105aad:	39 c8                	cmp    %ecx,%eax
f0105aaf:	73 1a                	jae    f0105acb <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f0105ab1:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0105ab7:	eb 27                	jmp    f0105ae0 <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105ab9:	50                   	push   %eax
f0105aba:	68 c8 65 10 f0       	push   $0xf01065c8
f0105abf:	6a 57                	push   $0x57
f0105ac1:	68 61 83 10 f0       	push   $0xf0108361
f0105ac6:	e8 c9 a5 ff ff       	call   f0100094 <_panic>
f0105acb:	56                   	push   %esi
f0105acc:	68 c8 65 10 f0       	push   $0xf01065c8
f0105ad1:	6a 57                	push   $0x57
f0105ad3:	68 61 83 10 f0       	push   $0xf0108361
f0105ad8:	e8 b7 a5 ff ff       	call   f0100094 <_panic>
f0105add:	83 c3 10             	add    $0x10,%ebx
f0105ae0:	39 f3                	cmp    %esi,%ebx
f0105ae2:	73 2c                	jae    f0105b10 <mpsearch1+0x89>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105ae4:	83 ec 04             	sub    $0x4,%esp
f0105ae7:	6a 04                	push   $0x4
f0105ae9:	68 71 83 10 f0       	push   $0xf0108371
f0105aee:	53                   	push   %ebx
f0105aef:	e8 2e fd ff ff       	call   f0105822 <memcmp>
f0105af4:	83 c4 10             	add    $0x10,%esp
f0105af7:	85 c0                	test   %eax,%eax
f0105af9:	75 e2                	jne    f0105add <mpsearch1+0x56>
f0105afb:	89 da                	mov    %ebx,%edx
f0105afd:	8d 7b 10             	lea    0x10(%ebx),%edi
		sum += ((uint8_t *)addr)[i];
f0105b00:	0f b6 0a             	movzbl (%edx),%ecx
f0105b03:	01 c8                	add    %ecx,%eax
f0105b05:	42                   	inc    %edx
	for (i = 0; i < len; i++)
f0105b06:	39 fa                	cmp    %edi,%edx
f0105b08:	75 f6                	jne    f0105b00 <mpsearch1+0x79>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105b0a:	84 c0                	test   %al,%al
f0105b0c:	75 cf                	jne    f0105add <mpsearch1+0x56>
f0105b0e:	eb 05                	jmp    f0105b15 <mpsearch1+0x8e>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105b10:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0105b15:	89 d8                	mov    %ebx,%eax
f0105b17:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105b1a:	5b                   	pop    %ebx
f0105b1b:	5e                   	pop    %esi
f0105b1c:	5f                   	pop    %edi
f0105b1d:	5d                   	pop    %ebp
f0105b1e:	c3                   	ret    

f0105b1f <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105b1f:	55                   	push   %ebp
f0105b20:	89 e5                	mov    %esp,%ebp
f0105b22:	57                   	push   %edi
f0105b23:	56                   	push   %esi
f0105b24:	53                   	push   %ebx
f0105b25:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105b28:	c7 05 c0 23 29 f0 20 	movl   $0xf0292020,0xf02923c0
f0105b2f:	20 29 f0 
	if (PGNUM(pa) >= npages)
f0105b32:	83 3d 88 1e 29 f0 00 	cmpl   $0x0,0xf0291e88
f0105b39:	0f 84 84 00 00 00    	je     f0105bc3 <mp_init+0xa4>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105b3f:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105b46:	85 c0                	test   %eax,%eax
f0105b48:	0f 84 8b 00 00 00    	je     f0105bd9 <mp_init+0xba>
		p <<= 4;	// Translate from segment to PA
f0105b4e:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105b51:	ba 00 04 00 00       	mov    $0x400,%edx
f0105b56:	e8 2c ff ff ff       	call   f0105a87 <mpsearch1>
f0105b5b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105b5e:	85 c0                	test   %eax,%eax
f0105b60:	0f 84 97 00 00 00    	je     f0105bfd <mp_init+0xde>
	if (mp->physaddr == 0 || mp->type != 0) {
f0105b66:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105b69:	8b 70 04             	mov    0x4(%eax),%esi
f0105b6c:	85 f6                	test   %esi,%esi
f0105b6e:	0f 84 a8 00 00 00    	je     f0105c1c <mp_init+0xfd>
f0105b74:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105b78:	0f 85 9e 00 00 00    	jne    f0105c1c <mp_init+0xfd>
f0105b7e:	89 f0                	mov    %esi,%eax
f0105b80:	c1 e8 0c             	shr    $0xc,%eax
f0105b83:	3b 05 88 1e 29 f0    	cmp    0xf0291e88,%eax
f0105b89:	0f 83 a2 00 00 00    	jae    f0105c31 <mp_init+0x112>
	return (void *)(pa + KERNBASE);
f0105b8f:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
f0105b95:	89 df                	mov    %ebx,%edi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105b97:	83 ec 04             	sub    $0x4,%esp
f0105b9a:	6a 04                	push   $0x4
f0105b9c:	68 76 83 10 f0       	push   $0xf0108376
f0105ba1:	53                   	push   %ebx
f0105ba2:	e8 7b fc ff ff       	call   f0105822 <memcmp>
f0105ba7:	83 c4 10             	add    $0x10,%esp
f0105baa:	85 c0                	test   %eax,%eax
f0105bac:	0f 85 94 00 00 00    	jne    f0105c46 <mp_init+0x127>
f0105bb2:	0f b7 53 04          	movzwl 0x4(%ebx),%edx
f0105bb6:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
f0105bb9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	sum = 0;
f0105bbc:	89 c2                	mov    %eax,%edx
f0105bbe:	e9 9e 00 00 00       	jmp    f0105c61 <mp_init+0x142>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105bc3:	68 00 04 00 00       	push   $0x400
f0105bc8:	68 c8 65 10 f0       	push   $0xf01065c8
f0105bcd:	6a 6f                	push   $0x6f
f0105bcf:	68 61 83 10 f0       	push   $0xf0108361
f0105bd4:	e8 bb a4 ff ff       	call   f0100094 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105bd9:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105be0:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105be3:	2d 00 04 00 00       	sub    $0x400,%eax
f0105be8:	ba 00 04 00 00       	mov    $0x400,%edx
f0105bed:	e8 95 fe ff ff       	call   f0105a87 <mpsearch1>
f0105bf2:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105bf5:	85 c0                	test   %eax,%eax
f0105bf7:	0f 85 69 ff ff ff    	jne    f0105b66 <mp_init+0x47>
	return mpsearch1(0xF0000, 0x10000);
f0105bfd:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105c02:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105c07:	e8 7b fe ff ff       	call   f0105a87 <mpsearch1>
f0105c0c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	if ((mp = mpsearch()) == 0)
f0105c0f:	85 c0                	test   %eax,%eax
f0105c11:	0f 85 4f ff ff ff    	jne    f0105b66 <mp_init+0x47>
f0105c17:	e9 b3 01 00 00       	jmp    f0105dcf <mp_init+0x2b0>
		cprintf("SMP: Default configurations not implemented\n");
f0105c1c:	83 ec 0c             	sub    $0xc,%esp
f0105c1f:	68 d4 81 10 f0       	push   $0xf01081d4
f0105c24:	e8 6a e3 ff ff       	call   f0103f93 <cprintf>
f0105c29:	83 c4 10             	add    $0x10,%esp
f0105c2c:	e9 9e 01 00 00       	jmp    f0105dcf <mp_init+0x2b0>
f0105c31:	56                   	push   %esi
f0105c32:	68 c8 65 10 f0       	push   $0xf01065c8
f0105c37:	68 90 00 00 00       	push   $0x90
f0105c3c:	68 61 83 10 f0       	push   $0xf0108361
f0105c41:	e8 4e a4 ff ff       	call   f0100094 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105c46:	83 ec 0c             	sub    $0xc,%esp
f0105c49:	68 04 82 10 f0       	push   $0xf0108204
f0105c4e:	e8 40 e3 ff ff       	call   f0103f93 <cprintf>
f0105c53:	83 c4 10             	add    $0x10,%esp
f0105c56:	e9 74 01 00 00       	jmp    f0105dcf <mp_init+0x2b0>
		sum += ((uint8_t *)addr)[i];
f0105c5b:	0f b6 0b             	movzbl (%ebx),%ecx
f0105c5e:	01 ca                	add    %ecx,%edx
f0105c60:	43                   	inc    %ebx
	for (i = 0; i < len; i++)
f0105c61:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0105c64:	75 f5                	jne    f0105c5b <mp_init+0x13c>
	if (sum(conf, conf->length) != 0) {
f0105c66:	84 d2                	test   %dl,%dl
f0105c68:	75 15                	jne    f0105c7f <mp_init+0x160>
	if (conf->version != 1 && conf->version != 4) {
f0105c6a:	8a 57 06             	mov    0x6(%edi),%dl
f0105c6d:	80 fa 01             	cmp    $0x1,%dl
f0105c70:	74 05                	je     f0105c77 <mp_init+0x158>
f0105c72:	80 fa 04             	cmp    $0x4,%dl
f0105c75:	75 1d                	jne    f0105c94 <mp_init+0x175>
f0105c77:	0f b7 4f 28          	movzwl 0x28(%edi),%ecx
f0105c7b:	01 d9                	add    %ebx,%ecx
f0105c7d:	eb 34                	jmp    f0105cb3 <mp_init+0x194>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105c7f:	83 ec 0c             	sub    $0xc,%esp
f0105c82:	68 38 82 10 f0       	push   $0xf0108238
f0105c87:	e8 07 e3 ff ff       	call   f0103f93 <cprintf>
f0105c8c:	83 c4 10             	add    $0x10,%esp
f0105c8f:	e9 3b 01 00 00       	jmp    f0105dcf <mp_init+0x2b0>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105c94:	83 ec 08             	sub    $0x8,%esp
f0105c97:	0f b6 d2             	movzbl %dl,%edx
f0105c9a:	52                   	push   %edx
f0105c9b:	68 5c 82 10 f0       	push   $0xf010825c
f0105ca0:	e8 ee e2 ff ff       	call   f0103f93 <cprintf>
f0105ca5:	83 c4 10             	add    $0x10,%esp
f0105ca8:	e9 22 01 00 00       	jmp    f0105dcf <mp_init+0x2b0>
		sum += ((uint8_t *)addr)[i];
f0105cad:	0f b6 13             	movzbl (%ebx),%edx
f0105cb0:	01 d0                	add    %edx,%eax
f0105cb2:	43                   	inc    %ebx
	for (i = 0; i < len; i++)
f0105cb3:	39 d9                	cmp    %ebx,%ecx
f0105cb5:	75 f6                	jne    f0105cad <mp_init+0x18e>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105cb7:	02 47 2a             	add    0x2a(%edi),%al
f0105cba:	75 28                	jne    f0105ce4 <mp_init+0x1c5>
	if ((conf = mpconfig(&mp)) == 0)
f0105cbc:	81 fe 00 00 00 10    	cmp    $0x10000000,%esi
f0105cc2:	0f 84 07 01 00 00    	je     f0105dcf <mp_init+0x2b0>
		return;
	ismp = 1;
f0105cc8:	c7 05 00 20 29 f0 01 	movl   $0x1,0xf0292000
f0105ccf:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105cd2:	8b 47 24             	mov    0x24(%edi),%eax
f0105cd5:	a3 00 30 2d f0       	mov    %eax,0xf02d3000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105cda:	8d 77 2c             	lea    0x2c(%edi),%esi
f0105cdd:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105ce2:	eb 60                	jmp    f0105d44 <mp_init+0x225>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105ce4:	83 ec 0c             	sub    $0xc,%esp
f0105ce7:	68 7c 82 10 f0       	push   $0xf010827c
f0105cec:	e8 a2 e2 ff ff       	call   f0103f93 <cprintf>
f0105cf1:	83 c4 10             	add    $0x10,%esp
f0105cf4:	e9 d6 00 00 00       	jmp    f0105dcf <mp_init+0x2b0>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105cf9:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f0105cfd:	74 1e                	je     f0105d1d <mp_init+0x1fe>
				bootcpu = &cpus[ncpu];
f0105cff:	8b 15 c4 23 29 f0    	mov    0xf02923c4,%edx
f0105d05:	8d 04 12             	lea    (%edx,%edx,1),%eax
f0105d08:	01 d0                	add    %edx,%eax
f0105d0a:	01 c0                	add    %eax,%eax
f0105d0c:	01 d0                	add    %edx,%eax
f0105d0e:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0105d11:	8d 04 85 20 20 29 f0 	lea    -0xfd6dfe0(,%eax,4),%eax
f0105d18:	a3 c0 23 29 f0       	mov    %eax,0xf02923c0
			if (ncpu < NCPU) {
f0105d1d:	a1 c4 23 29 f0       	mov    0xf02923c4,%eax
f0105d22:	83 f8 07             	cmp    $0x7,%eax
f0105d25:	7f 34                	jg     f0105d5b <mp_init+0x23c>
				cpus[ncpu].cpu_id = ncpu;
f0105d27:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0105d2a:	01 c2                	add    %eax,%edx
f0105d2c:	01 d2                	add    %edx,%edx
f0105d2e:	01 c2                	add    %eax,%edx
f0105d30:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0105d33:	88 04 95 20 20 29 f0 	mov    %al,-0xfd6dfe0(,%edx,4)
				ncpu++;
f0105d3a:	40                   	inc    %eax
f0105d3b:	a3 c4 23 29 f0       	mov    %eax,0xf02923c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105d40:	83 c6 14             	add    $0x14,%esi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105d43:	43                   	inc    %ebx
f0105d44:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f0105d48:	39 d8                	cmp    %ebx,%eax
f0105d4a:	76 4a                	jbe    f0105d96 <mp_init+0x277>
		switch (*p) {
f0105d4c:	8a 06                	mov    (%esi),%al
f0105d4e:	84 c0                	test   %al,%al
f0105d50:	74 a7                	je     f0105cf9 <mp_init+0x1da>
f0105d52:	3c 04                	cmp    $0x4,%al
f0105d54:	77 1c                	ja     f0105d72 <mp_init+0x253>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105d56:	83 c6 08             	add    $0x8,%esi
			continue;
f0105d59:	eb e8                	jmp    f0105d43 <mp_init+0x224>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105d5b:	83 ec 08             	sub    $0x8,%esp
f0105d5e:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0105d62:	50                   	push   %eax
f0105d63:	68 ac 82 10 f0       	push   $0xf01082ac
f0105d68:	e8 26 e2 ff ff       	call   f0103f93 <cprintf>
f0105d6d:	83 c4 10             	add    $0x10,%esp
f0105d70:	eb ce                	jmp    f0105d40 <mp_init+0x221>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105d72:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0105d75:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f0105d78:	50                   	push   %eax
f0105d79:	68 d4 82 10 f0       	push   $0xf01082d4
f0105d7e:	e8 10 e2 ff ff       	call   f0103f93 <cprintf>
			ismp = 0;
f0105d83:	c7 05 00 20 29 f0 00 	movl   $0x0,0xf0292000
f0105d8a:	00 00 00 
			i = conf->entry;
f0105d8d:	0f b7 5f 22          	movzwl 0x22(%edi),%ebx
f0105d91:	83 c4 10             	add    $0x10,%esp
f0105d94:	eb ad                	jmp    f0105d43 <mp_init+0x224>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105d96:	a1 c0 23 29 f0       	mov    0xf02923c0,%eax
f0105d9b:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105da2:	83 3d 00 20 29 f0 00 	cmpl   $0x0,0xf0292000
f0105da9:	75 2c                	jne    f0105dd7 <mp_init+0x2b8>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105dab:	c7 05 c4 23 29 f0 01 	movl   $0x1,0xf02923c4
f0105db2:	00 00 00 
		lapicaddr = 0;
f0105db5:	c7 05 00 30 2d f0 00 	movl   $0x0,0xf02d3000
f0105dbc:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105dbf:	83 ec 0c             	sub    $0xc,%esp
f0105dc2:	68 f4 82 10 f0       	push   $0xf01082f4
f0105dc7:	e8 c7 e1 ff ff       	call   f0103f93 <cprintf>
		return;
f0105dcc:	83 c4 10             	add    $0x10,%esp
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105dcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105dd2:	5b                   	pop    %ebx
f0105dd3:	5e                   	pop    %esi
f0105dd4:	5f                   	pop    %edi
f0105dd5:	5d                   	pop    %ebp
f0105dd6:	c3                   	ret    
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105dd7:	83 ec 04             	sub    $0x4,%esp
f0105dda:	ff 35 c4 23 29 f0    	pushl  0xf02923c4
f0105de0:	0f b6 00             	movzbl (%eax),%eax
f0105de3:	50                   	push   %eax
f0105de4:	68 7b 83 10 f0       	push   $0xf010837b
f0105de9:	e8 a5 e1 ff ff       	call   f0103f93 <cprintf>
	if (mp->imcrp) {
f0105dee:	83 c4 10             	add    $0x10,%esp
f0105df1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105df4:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105df8:	74 d5                	je     f0105dcf <mp_init+0x2b0>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105dfa:	83 ec 0c             	sub    $0xc,%esp
f0105dfd:	68 20 83 10 f0       	push   $0xf0108320
f0105e02:	e8 8c e1 ff ff       	call   f0103f93 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105e07:	b0 70                	mov    $0x70,%al
f0105e09:	ba 22 00 00 00       	mov    $0x22,%edx
f0105e0e:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105e0f:	ba 23 00 00 00       	mov    $0x23,%edx
f0105e14:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0105e15:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105e18:	ee                   	out    %al,(%dx)
f0105e19:	83 c4 10             	add    $0x10,%esp
f0105e1c:	eb b1                	jmp    f0105dcf <mp_init+0x2b0>

f0105e1e <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105e1e:	55                   	push   %ebp
f0105e1f:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105e21:	8b 0d 04 30 2d f0    	mov    0xf02d3004,%ecx
f0105e27:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105e2a:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105e2c:	a1 04 30 2d f0       	mov    0xf02d3004,%eax
f0105e31:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105e34:	5d                   	pop    %ebp
f0105e35:	c3                   	ret    

f0105e36 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105e36:	55                   	push   %ebp
f0105e37:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105e39:	a1 04 30 2d f0       	mov    0xf02d3004,%eax
f0105e3e:	85 c0                	test   %eax,%eax
f0105e40:	74 08                	je     f0105e4a <cpunum+0x14>
		return lapic[ID] >> 24;
f0105e42:	8b 40 20             	mov    0x20(%eax),%eax
f0105e45:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f0105e48:	5d                   	pop    %ebp
f0105e49:	c3                   	ret    
	return 0;
f0105e4a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e4f:	eb f7                	jmp    f0105e48 <cpunum+0x12>

f0105e51 <lapic_init>:
	if (!lapicaddr)
f0105e51:	a1 00 30 2d f0       	mov    0xf02d3000,%eax
f0105e56:	85 c0                	test   %eax,%eax
f0105e58:	75 01                	jne    f0105e5b <lapic_init+0xa>
f0105e5a:	c3                   	ret    
{
f0105e5b:	55                   	push   %ebp
f0105e5c:	89 e5                	mov    %esp,%ebp
f0105e5e:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0105e61:	68 00 10 00 00       	push   $0x1000
f0105e66:	50                   	push   %eax
f0105e67:	e8 3a b9 ff ff       	call   f01017a6 <mmio_map_region>
f0105e6c:	a3 04 30 2d f0       	mov    %eax,0xf02d3004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105e71:	ba 27 01 00 00       	mov    $0x127,%edx
f0105e76:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105e7b:	e8 9e ff ff ff       	call   f0105e1e <lapicw>
	lapicw(TDCR, X1);
f0105e80:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105e85:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105e8a:	e8 8f ff ff ff       	call   f0105e1e <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105e8f:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105e94:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105e99:	e8 80 ff ff ff       	call   f0105e1e <lapicw>
	lapicw(TICR, 10000000); 
f0105e9e:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105ea3:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105ea8:	e8 71 ff ff ff       	call   f0105e1e <lapicw>
	if (thiscpu != bootcpu)
f0105ead:	e8 84 ff ff ff       	call   f0105e36 <cpunum>
f0105eb2:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0105eb5:	01 c2                	add    %eax,%edx
f0105eb7:	01 d2                	add    %edx,%edx
f0105eb9:	01 c2                	add    %eax,%edx
f0105ebb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105ebe:	8d 04 85 20 20 29 f0 	lea    -0xfd6dfe0(,%eax,4),%eax
f0105ec5:	83 c4 10             	add    $0x10,%esp
f0105ec8:	39 05 c0 23 29 f0    	cmp    %eax,0xf02923c0
f0105ece:	74 0f                	je     f0105edf <lapic_init+0x8e>
		lapicw(LINT0, MASKED);
f0105ed0:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105ed5:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105eda:	e8 3f ff ff ff       	call   f0105e1e <lapicw>
	lapicw(LINT1, MASKED);
f0105edf:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105ee4:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105ee9:	e8 30 ff ff ff       	call   f0105e1e <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105eee:	a1 04 30 2d f0       	mov    0xf02d3004,%eax
f0105ef3:	8b 40 30             	mov    0x30(%eax),%eax
f0105ef6:	c1 e8 10             	shr    $0x10,%eax
f0105ef9:	3c 03                	cmp    $0x3,%al
f0105efb:	77 7c                	ja     f0105f79 <lapic_init+0x128>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105efd:	ba 33 00 00 00       	mov    $0x33,%edx
f0105f02:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105f07:	e8 12 ff ff ff       	call   f0105e1e <lapicw>
	lapicw(ESR, 0);
f0105f0c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f11:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105f16:	e8 03 ff ff ff       	call   f0105e1e <lapicw>
	lapicw(ESR, 0);
f0105f1b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f20:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105f25:	e8 f4 fe ff ff       	call   f0105e1e <lapicw>
	lapicw(EOI, 0);
f0105f2a:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f2f:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105f34:	e8 e5 fe ff ff       	call   f0105e1e <lapicw>
	lapicw(ICRHI, 0);
f0105f39:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f3e:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f43:	e8 d6 fe ff ff       	call   f0105e1e <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105f48:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105f4d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f52:	e8 c7 fe ff ff       	call   f0105e1e <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105f57:	8b 15 04 30 2d f0    	mov    0xf02d3004,%edx
f0105f5d:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105f63:	f6 c4 10             	test   $0x10,%ah
f0105f66:	75 f5                	jne    f0105f5d <lapic_init+0x10c>
	lapicw(TPR, 0);
f0105f68:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f6d:	b8 20 00 00 00       	mov    $0x20,%eax
f0105f72:	e8 a7 fe ff ff       	call   f0105e1e <lapicw>
}
f0105f77:	c9                   	leave  
f0105f78:	c3                   	ret    
		lapicw(PCINT, MASKED);
f0105f79:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105f7e:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105f83:	e8 96 fe ff ff       	call   f0105e1e <lapicw>
f0105f88:	e9 70 ff ff ff       	jmp    f0105efd <lapic_init+0xac>

f0105f8d <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105f8d:	83 3d 04 30 2d f0 00 	cmpl   $0x0,0xf02d3004
f0105f94:	74 14                	je     f0105faa <lapic_eoi+0x1d>
{
f0105f96:	55                   	push   %ebp
f0105f97:	89 e5                	mov    %esp,%ebp
		lapicw(EOI, 0);
f0105f99:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f9e:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105fa3:	e8 76 fe ff ff       	call   f0105e1e <lapicw>
}
f0105fa8:	5d                   	pop    %ebp
f0105fa9:	c3                   	ret    
f0105faa:	c3                   	ret    

f0105fab <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105fab:	55                   	push   %ebp
f0105fac:	89 e5                	mov    %esp,%ebp
f0105fae:	56                   	push   %esi
f0105faf:	53                   	push   %ebx
f0105fb0:	8b 75 08             	mov    0x8(%ebp),%esi
f0105fb3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105fb6:	b0 0f                	mov    $0xf,%al
f0105fb8:	ba 70 00 00 00       	mov    $0x70,%edx
f0105fbd:	ee                   	out    %al,(%dx)
f0105fbe:	b0 0a                	mov    $0xa,%al
f0105fc0:	ba 71 00 00 00       	mov    $0x71,%edx
f0105fc5:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f0105fc6:	83 3d 88 1e 29 f0 00 	cmpl   $0x0,0xf0291e88
f0105fcd:	74 7e                	je     f010604d <lapic_startap+0xa2>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105fcf:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105fd6:	00 00 
	wrv[1] = addr >> 4;
f0105fd8:	89 d8                	mov    %ebx,%eax
f0105fda:	c1 e8 04             	shr    $0x4,%eax
f0105fdd:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105fe3:	c1 e6 18             	shl    $0x18,%esi
f0105fe6:	89 f2                	mov    %esi,%edx
f0105fe8:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105fed:	e8 2c fe ff ff       	call   f0105e1e <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105ff2:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105ff7:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ffc:	e8 1d fe ff ff       	call   f0105e1e <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106001:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106006:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010600b:	e8 0e fe ff ff       	call   f0105e1e <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106010:	c1 eb 0c             	shr    $0xc,%ebx
f0106013:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f0106016:	89 f2                	mov    %esi,%edx
f0106018:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010601d:	e8 fc fd ff ff       	call   f0105e1e <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106022:	89 da                	mov    %ebx,%edx
f0106024:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106029:	e8 f0 fd ff ff       	call   f0105e1e <lapicw>
		lapicw(ICRHI, apicid << 24);
f010602e:	89 f2                	mov    %esi,%edx
f0106030:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106035:	e8 e4 fd ff ff       	call   f0105e1e <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010603a:	89 da                	mov    %ebx,%edx
f010603c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106041:	e8 d8 fd ff ff       	call   f0105e1e <lapicw>
		microdelay(200);
	}
}
f0106046:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106049:	5b                   	pop    %ebx
f010604a:	5e                   	pop    %esi
f010604b:	5d                   	pop    %ebp
f010604c:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010604d:	68 67 04 00 00       	push   $0x467
f0106052:	68 c8 65 10 f0       	push   $0xf01065c8
f0106057:	68 98 00 00 00       	push   $0x98
f010605c:	68 98 83 10 f0       	push   $0xf0108398
f0106061:	e8 2e a0 ff ff       	call   f0100094 <_panic>

f0106066 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106066:	55                   	push   %ebp
f0106067:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106069:	8b 55 08             	mov    0x8(%ebp),%edx
f010606c:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106072:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106077:	e8 a2 fd ff ff       	call   f0105e1e <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010607c:	8b 15 04 30 2d f0    	mov    0xf02d3004,%edx
f0106082:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106088:	f6 c4 10             	test   $0x10,%ah
f010608b:	75 f5                	jne    f0106082 <lapic_ipi+0x1c>
		;
}
f010608d:	5d                   	pop    %ebp
f010608e:	c3                   	ret    

f010608f <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010608f:	55                   	push   %ebp
f0106090:	89 e5                	mov    %esp,%ebp
f0106092:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106095:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f010609b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010609e:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01060a1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01060a8:	5d                   	pop    %ebp
f01060a9:	c3                   	ret    

f01060aa <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01060aa:	55                   	push   %ebp
f01060ab:	89 e5                	mov    %esp,%ebp
f01060ad:	56                   	push   %esi
f01060ae:	53                   	push   %ebx
f01060af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f01060b2:	83 3b 00             	cmpl   $0x0,(%ebx)
f01060b5:	75 07                	jne    f01060be <spin_lock+0x14>
	asm volatile("lock; xchgl %0, %1"
f01060b7:	ba 01 00 00 00       	mov    $0x1,%edx
f01060bc:	eb 3f                	jmp    f01060fd <spin_lock+0x53>
f01060be:	8b 73 08             	mov    0x8(%ebx),%esi
f01060c1:	e8 70 fd ff ff       	call   f0105e36 <cpunum>
f01060c6:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01060c9:	01 c2                	add    %eax,%edx
f01060cb:	01 d2                	add    %edx,%edx
f01060cd:	01 c2                	add    %eax,%edx
f01060cf:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01060d2:	8d 04 85 20 20 29 f0 	lea    -0xfd6dfe0(,%eax,4),%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01060d9:	39 c6                	cmp    %eax,%esi
f01060db:	75 da                	jne    f01060b7 <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01060dd:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01060e0:	e8 51 fd ff ff       	call   f0105e36 <cpunum>
f01060e5:	83 ec 0c             	sub    $0xc,%esp
f01060e8:	53                   	push   %ebx
f01060e9:	50                   	push   %eax
f01060ea:	68 a8 83 10 f0       	push   $0xf01083a8
f01060ef:	6a 41                	push   $0x41
f01060f1:	68 0c 84 10 f0       	push   $0xf010840c
f01060f6:	e8 99 9f ff ff       	call   f0100094 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01060fb:	f3 90                	pause  
f01060fd:	89 d0                	mov    %edx,%eax
f01060ff:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f0106102:	85 c0                	test   %eax,%eax
f0106104:	75 f5                	jne    f01060fb <spin_lock+0x51>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106106:	e8 2b fd ff ff       	call   f0105e36 <cpunum>
f010610b:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010610e:	01 c2                	add    %eax,%edx
f0106110:	01 d2                	add    %edx,%edx
f0106112:	01 c2                	add    %eax,%edx
f0106114:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106117:	8d 04 85 20 20 29 f0 	lea    -0xfd6dfe0(,%eax,4),%eax
f010611e:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106121:	83 c3 0c             	add    $0xc,%ebx
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0106124:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0106126:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f010612b:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106131:	76 1d                	jbe    f0106150 <spin_lock+0xa6>
		pcs[i] = ebp[1];          // saved %eip
f0106133:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106136:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106139:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f010613b:	40                   	inc    %eax
f010613c:	83 f8 0a             	cmp    $0xa,%eax
f010613f:	75 ea                	jne    f010612b <spin_lock+0x81>
#endif
}
f0106141:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106144:	5b                   	pop    %ebx
f0106145:	5e                   	pop    %esi
f0106146:	5d                   	pop    %ebp
f0106147:	c3                   	ret    
		pcs[i] = 0;
f0106148:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
	for (; i < 10; i++)
f010614f:	40                   	inc    %eax
f0106150:	83 f8 09             	cmp    $0x9,%eax
f0106153:	7e f3                	jle    f0106148 <spin_lock+0x9e>
f0106155:	eb ea                	jmp    f0106141 <spin_lock+0x97>

f0106157 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106157:	55                   	push   %ebp
f0106158:	89 e5                	mov    %esp,%ebp
f010615a:	57                   	push   %edi
f010615b:	56                   	push   %esi
f010615c:	53                   	push   %ebx
f010615d:	83 ec 4c             	sub    $0x4c,%esp
f0106160:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f0106163:	83 3e 00             	cmpl   $0x0,(%esi)
f0106166:	75 35                	jne    f010619d <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106168:	83 ec 04             	sub    $0x4,%esp
f010616b:	6a 28                	push   $0x28
f010616d:	8d 46 0c             	lea    0xc(%esi),%eax
f0106170:	50                   	push   %eax
f0106171:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106174:	53                   	push   %ebx
f0106175:	e8 2f f6 ff ff       	call   f01057a9 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f010617a:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f010617d:	0f b6 38             	movzbl (%eax),%edi
f0106180:	8b 76 04             	mov    0x4(%esi),%esi
f0106183:	e8 ae fc ff ff       	call   f0105e36 <cpunum>
f0106188:	57                   	push   %edi
f0106189:	56                   	push   %esi
f010618a:	50                   	push   %eax
f010618b:	68 d4 83 10 f0       	push   $0xf01083d4
f0106190:	e8 fe dd ff ff       	call   f0103f93 <cprintf>
f0106195:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106198:	8d 7d a8             	lea    -0x58(%ebp),%edi
f010619b:	eb 6c                	jmp    f0106209 <spin_unlock+0xb2>
	return lock->locked && lock->cpu == thiscpu;
f010619d:	8b 5e 08             	mov    0x8(%esi),%ebx
f01061a0:	e8 91 fc ff ff       	call   f0105e36 <cpunum>
f01061a5:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01061a8:	01 c2                	add    %eax,%edx
f01061aa:	01 d2                	add    %edx,%edx
f01061ac:	01 c2                	add    %eax,%edx
f01061ae:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01061b1:	8d 04 85 20 20 29 f0 	lea    -0xfd6dfe0(,%eax,4),%eax
	if (!holding(lk)) {
f01061b8:	39 c3                	cmp    %eax,%ebx
f01061ba:	75 ac                	jne    f0106168 <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f01061bc:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01061c3:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f01061ca:	b8 00 00 00 00       	mov    $0x0,%eax
f01061cf:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f01061d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01061d5:	5b                   	pop    %ebx
f01061d6:	5e                   	pop    %esi
f01061d7:	5f                   	pop    %edi
f01061d8:	5d                   	pop    %ebp
f01061d9:	c3                   	ret    
					pcs[i] - info.eip_fn_addr);
f01061da:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01061dc:	83 ec 04             	sub    $0x4,%esp
f01061df:	89 c2                	mov    %eax,%edx
f01061e1:	2b 55 b8             	sub    -0x48(%ebp),%edx
f01061e4:	52                   	push   %edx
f01061e5:	ff 75 b0             	pushl  -0x50(%ebp)
f01061e8:	ff 75 b4             	pushl  -0x4c(%ebp)
f01061eb:	ff 75 ac             	pushl  -0x54(%ebp)
f01061ee:	ff 75 a8             	pushl  -0x58(%ebp)
f01061f1:	50                   	push   %eax
f01061f2:	68 1c 84 10 f0       	push   $0xf010841c
f01061f7:	e8 97 dd ff ff       	call   f0103f93 <cprintf>
f01061fc:	83 c4 20             	add    $0x20,%esp
f01061ff:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106202:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106205:	39 c3                	cmp    %eax,%ebx
f0106207:	74 2d                	je     f0106236 <spin_unlock+0xdf>
f0106209:	89 de                	mov    %ebx,%esi
f010620b:	8b 03                	mov    (%ebx),%eax
f010620d:	85 c0                	test   %eax,%eax
f010620f:	74 25                	je     f0106236 <spin_unlock+0xdf>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106211:	83 ec 08             	sub    $0x8,%esp
f0106214:	57                   	push   %edi
f0106215:	50                   	push   %eax
f0106216:	e8 00 eb ff ff       	call   f0104d1b <debuginfo_eip>
f010621b:	83 c4 10             	add    $0x10,%esp
f010621e:	85 c0                	test   %eax,%eax
f0106220:	79 b8                	jns    f01061da <spin_unlock+0x83>
				cprintf("  %08x\n", pcs[i]);
f0106222:	83 ec 08             	sub    $0x8,%esp
f0106225:	ff 36                	pushl  (%esi)
f0106227:	68 33 84 10 f0       	push   $0xf0108433
f010622c:	e8 62 dd ff ff       	call   f0103f93 <cprintf>
f0106231:	83 c4 10             	add    $0x10,%esp
f0106234:	eb c9                	jmp    f01061ff <spin_unlock+0xa8>
		panic("spin_unlock");
f0106236:	83 ec 04             	sub    $0x4,%esp
f0106239:	68 3b 84 10 f0       	push   $0xf010843b
f010623e:	6a 67                	push   $0x67
f0106240:	68 0c 84 10 f0       	push   $0xf010840c
f0106245:	e8 4a 9e ff ff       	call   f0100094 <_panic>
f010624a:	66 90                	xchg   %ax,%ax

f010624c <__udivdi3>:
f010624c:	55                   	push   %ebp
f010624d:	57                   	push   %edi
f010624e:	56                   	push   %esi
f010624f:	53                   	push   %ebx
f0106250:	83 ec 1c             	sub    $0x1c,%esp
f0106253:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0106257:	8b 74 24 34          	mov    0x34(%esp),%esi
f010625b:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010625f:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0106263:	85 d2                	test   %edx,%edx
f0106265:	75 2d                	jne    f0106294 <__udivdi3+0x48>
f0106267:	39 f7                	cmp    %esi,%edi
f0106269:	77 59                	ja     f01062c4 <__udivdi3+0x78>
f010626b:	89 f9                	mov    %edi,%ecx
f010626d:	85 ff                	test   %edi,%edi
f010626f:	75 0b                	jne    f010627c <__udivdi3+0x30>
f0106271:	b8 01 00 00 00       	mov    $0x1,%eax
f0106276:	31 d2                	xor    %edx,%edx
f0106278:	f7 f7                	div    %edi
f010627a:	89 c1                	mov    %eax,%ecx
f010627c:	31 d2                	xor    %edx,%edx
f010627e:	89 f0                	mov    %esi,%eax
f0106280:	f7 f1                	div    %ecx
f0106282:	89 c3                	mov    %eax,%ebx
f0106284:	89 e8                	mov    %ebp,%eax
f0106286:	f7 f1                	div    %ecx
f0106288:	89 da                	mov    %ebx,%edx
f010628a:	83 c4 1c             	add    $0x1c,%esp
f010628d:	5b                   	pop    %ebx
f010628e:	5e                   	pop    %esi
f010628f:	5f                   	pop    %edi
f0106290:	5d                   	pop    %ebp
f0106291:	c3                   	ret    
f0106292:	66 90                	xchg   %ax,%ax
f0106294:	39 f2                	cmp    %esi,%edx
f0106296:	77 1c                	ja     f01062b4 <__udivdi3+0x68>
f0106298:	0f bd da             	bsr    %edx,%ebx
f010629b:	83 f3 1f             	xor    $0x1f,%ebx
f010629e:	75 38                	jne    f01062d8 <__udivdi3+0x8c>
f01062a0:	39 f2                	cmp    %esi,%edx
f01062a2:	72 08                	jb     f01062ac <__udivdi3+0x60>
f01062a4:	39 ef                	cmp    %ebp,%edi
f01062a6:	0f 87 98 00 00 00    	ja     f0106344 <__udivdi3+0xf8>
f01062ac:	b8 01 00 00 00       	mov    $0x1,%eax
f01062b1:	eb 05                	jmp    f01062b8 <__udivdi3+0x6c>
f01062b3:	90                   	nop
f01062b4:	31 db                	xor    %ebx,%ebx
f01062b6:	31 c0                	xor    %eax,%eax
f01062b8:	89 da                	mov    %ebx,%edx
f01062ba:	83 c4 1c             	add    $0x1c,%esp
f01062bd:	5b                   	pop    %ebx
f01062be:	5e                   	pop    %esi
f01062bf:	5f                   	pop    %edi
f01062c0:	5d                   	pop    %ebp
f01062c1:	c3                   	ret    
f01062c2:	66 90                	xchg   %ax,%ax
f01062c4:	89 e8                	mov    %ebp,%eax
f01062c6:	89 f2                	mov    %esi,%edx
f01062c8:	f7 f7                	div    %edi
f01062ca:	31 db                	xor    %ebx,%ebx
f01062cc:	89 da                	mov    %ebx,%edx
f01062ce:	83 c4 1c             	add    $0x1c,%esp
f01062d1:	5b                   	pop    %ebx
f01062d2:	5e                   	pop    %esi
f01062d3:	5f                   	pop    %edi
f01062d4:	5d                   	pop    %ebp
f01062d5:	c3                   	ret    
f01062d6:	66 90                	xchg   %ax,%ax
f01062d8:	b8 20 00 00 00       	mov    $0x20,%eax
f01062dd:	29 d8                	sub    %ebx,%eax
f01062df:	88 d9                	mov    %bl,%cl
f01062e1:	d3 e2                	shl    %cl,%edx
f01062e3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01062e7:	89 fa                	mov    %edi,%edx
f01062e9:	88 c1                	mov    %al,%cl
f01062eb:	d3 ea                	shr    %cl,%edx
f01062ed:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01062f1:	09 d1                	or     %edx,%ecx
f01062f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01062f7:	88 d9                	mov    %bl,%cl
f01062f9:	d3 e7                	shl    %cl,%edi
f01062fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01062ff:	89 f7                	mov    %esi,%edi
f0106301:	88 c1                	mov    %al,%cl
f0106303:	d3 ef                	shr    %cl,%edi
f0106305:	88 d9                	mov    %bl,%cl
f0106307:	d3 e6                	shl    %cl,%esi
f0106309:	89 ea                	mov    %ebp,%edx
f010630b:	88 c1                	mov    %al,%cl
f010630d:	d3 ea                	shr    %cl,%edx
f010630f:	09 d6                	or     %edx,%esi
f0106311:	89 f0                	mov    %esi,%eax
f0106313:	89 fa                	mov    %edi,%edx
f0106315:	f7 74 24 08          	divl   0x8(%esp)
f0106319:	89 d7                	mov    %edx,%edi
f010631b:	89 c6                	mov    %eax,%esi
f010631d:	f7 64 24 0c          	mull   0xc(%esp)
f0106321:	39 d7                	cmp    %edx,%edi
f0106323:	72 13                	jb     f0106338 <__udivdi3+0xec>
f0106325:	74 09                	je     f0106330 <__udivdi3+0xe4>
f0106327:	89 f0                	mov    %esi,%eax
f0106329:	31 db                	xor    %ebx,%ebx
f010632b:	eb 8b                	jmp    f01062b8 <__udivdi3+0x6c>
f010632d:	8d 76 00             	lea    0x0(%esi),%esi
f0106330:	88 d9                	mov    %bl,%cl
f0106332:	d3 e5                	shl    %cl,%ebp
f0106334:	39 c5                	cmp    %eax,%ebp
f0106336:	73 ef                	jae    f0106327 <__udivdi3+0xdb>
f0106338:	8d 46 ff             	lea    -0x1(%esi),%eax
f010633b:	31 db                	xor    %ebx,%ebx
f010633d:	e9 76 ff ff ff       	jmp    f01062b8 <__udivdi3+0x6c>
f0106342:	66 90                	xchg   %ax,%ax
f0106344:	31 c0                	xor    %eax,%eax
f0106346:	e9 6d ff ff ff       	jmp    f01062b8 <__udivdi3+0x6c>
f010634b:	90                   	nop

f010634c <__umoddi3>:
f010634c:	55                   	push   %ebp
f010634d:	57                   	push   %edi
f010634e:	56                   	push   %esi
f010634f:	53                   	push   %ebx
f0106350:	83 ec 1c             	sub    $0x1c,%esp
f0106353:	8b 74 24 30          	mov    0x30(%esp),%esi
f0106357:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f010635b:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010635f:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0106363:	89 f0                	mov    %esi,%eax
f0106365:	89 da                	mov    %ebx,%edx
f0106367:	85 ed                	test   %ebp,%ebp
f0106369:	75 15                	jne    f0106380 <__umoddi3+0x34>
f010636b:	39 df                	cmp    %ebx,%edi
f010636d:	76 39                	jbe    f01063a8 <__umoddi3+0x5c>
f010636f:	f7 f7                	div    %edi
f0106371:	89 d0                	mov    %edx,%eax
f0106373:	31 d2                	xor    %edx,%edx
f0106375:	83 c4 1c             	add    $0x1c,%esp
f0106378:	5b                   	pop    %ebx
f0106379:	5e                   	pop    %esi
f010637a:	5f                   	pop    %edi
f010637b:	5d                   	pop    %ebp
f010637c:	c3                   	ret    
f010637d:	8d 76 00             	lea    0x0(%esi),%esi
f0106380:	39 dd                	cmp    %ebx,%ebp
f0106382:	77 f1                	ja     f0106375 <__umoddi3+0x29>
f0106384:	0f bd cd             	bsr    %ebp,%ecx
f0106387:	83 f1 1f             	xor    $0x1f,%ecx
f010638a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010638e:	75 38                	jne    f01063c8 <__umoddi3+0x7c>
f0106390:	39 dd                	cmp    %ebx,%ebp
f0106392:	72 04                	jb     f0106398 <__umoddi3+0x4c>
f0106394:	39 f7                	cmp    %esi,%edi
f0106396:	77 dd                	ja     f0106375 <__umoddi3+0x29>
f0106398:	89 da                	mov    %ebx,%edx
f010639a:	89 f0                	mov    %esi,%eax
f010639c:	29 f8                	sub    %edi,%eax
f010639e:	19 ea                	sbb    %ebp,%edx
f01063a0:	83 c4 1c             	add    $0x1c,%esp
f01063a3:	5b                   	pop    %ebx
f01063a4:	5e                   	pop    %esi
f01063a5:	5f                   	pop    %edi
f01063a6:	5d                   	pop    %ebp
f01063a7:	c3                   	ret    
f01063a8:	89 f9                	mov    %edi,%ecx
f01063aa:	85 ff                	test   %edi,%edi
f01063ac:	75 0b                	jne    f01063b9 <__umoddi3+0x6d>
f01063ae:	b8 01 00 00 00       	mov    $0x1,%eax
f01063b3:	31 d2                	xor    %edx,%edx
f01063b5:	f7 f7                	div    %edi
f01063b7:	89 c1                	mov    %eax,%ecx
f01063b9:	89 d8                	mov    %ebx,%eax
f01063bb:	31 d2                	xor    %edx,%edx
f01063bd:	f7 f1                	div    %ecx
f01063bf:	89 f0                	mov    %esi,%eax
f01063c1:	f7 f1                	div    %ecx
f01063c3:	eb ac                	jmp    f0106371 <__umoddi3+0x25>
f01063c5:	8d 76 00             	lea    0x0(%esi),%esi
f01063c8:	b8 20 00 00 00       	mov    $0x20,%eax
f01063cd:	89 c2                	mov    %eax,%edx
f01063cf:	8b 44 24 04          	mov    0x4(%esp),%eax
f01063d3:	29 c2                	sub    %eax,%edx
f01063d5:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01063d9:	88 c1                	mov    %al,%cl
f01063db:	d3 e5                	shl    %cl,%ebp
f01063dd:	89 f8                	mov    %edi,%eax
f01063df:	88 d1                	mov    %dl,%cl
f01063e1:	d3 e8                	shr    %cl,%eax
f01063e3:	09 c5                	or     %eax,%ebp
f01063e5:	8b 44 24 04          	mov    0x4(%esp),%eax
f01063e9:	88 c1                	mov    %al,%cl
f01063eb:	d3 e7                	shl    %cl,%edi
f01063ed:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01063f1:	89 df                	mov    %ebx,%edi
f01063f3:	88 d1                	mov    %dl,%cl
f01063f5:	d3 ef                	shr    %cl,%edi
f01063f7:	88 c1                	mov    %al,%cl
f01063f9:	d3 e3                	shl    %cl,%ebx
f01063fb:	89 f0                	mov    %esi,%eax
f01063fd:	88 d1                	mov    %dl,%cl
f01063ff:	d3 e8                	shr    %cl,%eax
f0106401:	09 d8                	or     %ebx,%eax
f0106403:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0106407:	d3 e6                	shl    %cl,%esi
f0106409:	89 fa                	mov    %edi,%edx
f010640b:	f7 f5                	div    %ebp
f010640d:	89 d1                	mov    %edx,%ecx
f010640f:	f7 64 24 08          	mull   0x8(%esp)
f0106413:	89 c3                	mov    %eax,%ebx
f0106415:	89 d7                	mov    %edx,%edi
f0106417:	39 d1                	cmp    %edx,%ecx
f0106419:	72 29                	jb     f0106444 <__umoddi3+0xf8>
f010641b:	74 23                	je     f0106440 <__umoddi3+0xf4>
f010641d:	89 ca                	mov    %ecx,%edx
f010641f:	29 de                	sub    %ebx,%esi
f0106421:	19 fa                	sbb    %edi,%edx
f0106423:	89 d0                	mov    %edx,%eax
f0106425:	8a 4c 24 0c          	mov    0xc(%esp),%cl
f0106429:	d3 e0                	shl    %cl,%eax
f010642b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f010642f:	88 d9                	mov    %bl,%cl
f0106431:	d3 ee                	shr    %cl,%esi
f0106433:	09 f0                	or     %esi,%eax
f0106435:	d3 ea                	shr    %cl,%edx
f0106437:	83 c4 1c             	add    $0x1c,%esp
f010643a:	5b                   	pop    %ebx
f010643b:	5e                   	pop    %esi
f010643c:	5f                   	pop    %edi
f010643d:	5d                   	pop    %ebp
f010643e:	c3                   	ret    
f010643f:	90                   	nop
f0106440:	39 c6                	cmp    %eax,%esi
f0106442:	73 d9                	jae    f010641d <__umoddi3+0xd1>
f0106444:	2b 44 24 08          	sub    0x8(%esp),%eax
f0106448:	19 ea                	sbb    %ebp,%edx
f010644a:	89 d7                	mov    %edx,%edi
f010644c:	89 c3                	mov    %eax,%ebx
f010644e:	eb cd                	jmp    f010641d <__umoddi3+0xd1>
