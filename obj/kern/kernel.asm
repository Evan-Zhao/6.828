
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
f0100015:	b8 00 b0 11 00       	mov    $0x11b000,%eax
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
f0100034:	bc 00 b0 11 f0       	mov    $0xf011b000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 56 00 00 00       	call   f0100094 <i386_init>

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
f010004b:	68 a0 4f 10 f0       	push   $0xf0104fa0
f0100050:	e8 92 36 00 00       	call   f01036e7 <cprintf>
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
f0100065:	e8 75 0b 00 00       	call   f0100bdf <mon_backtrace>
f010006a:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010006d:	83 ec 08             	sub    $0x8,%esp
f0100070:	53                   	push   %ebx
f0100071:	68 bc 4f 10 f0       	push   $0xf0104fbc
f0100076:	e8 6c 36 00 00       	call   f01036e7 <cprintf>
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

f0100094 <i386_init>:

void
i386_init(void)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010009a:	b8 f0 6d 1b f0       	mov    $0xf01b6df0,%eax
f010009f:	2d c6 5e 1b f0       	sub    $0xf01b5ec6,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 c6 5e 1b f0       	push   $0xf01b5ec6
f01000ac:	e8 31 4a 00 00       	call   f0104ae2 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 ed 04 00 00       	call   f01005a3 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 d7 4f 10 f0       	push   $0xf0104fd7
f01000c3:	e8 1f 36 00 00       	call   f01036e7 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000c8:	e8 90 14 00 00       	call   f010155d <mem_init>
	cprintf(ANSI_COLOR_RED     "This text is RED!"     ANSI_COLOR_RESET "\n");
f01000cd:	c7 04 24 f2 4f 10 f0 	movl   $0xf0104ff2,(%esp)
f01000d4:	e8 0e 36 00 00       	call   f01036e7 <cprintf>
	cprintf(ANSI_COLOR_GREEN   "This text is GREEN!"   ANSI_COLOR_RESET "\n");
f01000d9:	c7 04 24 0e 50 10 f0 	movl   $0xf010500e,(%esp)
f01000e0:	e8 02 36 00 00       	call   f01036e7 <cprintf>
	cprintf(ANSI_COLOR_YELLOW  "This text is YELLOW!"  ANSI_COLOR_RESET "\n");
f01000e5:	c7 04 24 98 50 10 f0 	movl   $0xf0105098,(%esp)
f01000ec:	e8 f6 35 00 00       	call   f01036e7 <cprintf>
	cprintf(ANSI_COLOR_BLUE    "This text is BLUE!"    ANSI_COLOR_RESET "\n");
f01000f1:	c7 04 24 2c 50 10 f0 	movl   $0xf010502c,(%esp)
f01000f8:	e8 ea 35 00 00       	call   f01036e7 <cprintf>
	cprintf(ANSI_COLOR_MAGENTA "This text is MAGENTA!" ANSI_COLOR_RESET "\n");
f01000fd:	c7 04 24 b8 50 10 f0 	movl   $0xf01050b8,(%esp)
f0100104:	e8 de 35 00 00       	call   f01036e7 <cprintf>
	cprintf(ANSI_COLOR_CYAN    "This text is CYAN!"    ANSI_COLOR_RESET "\n");
f0100109:	c7 04 24 49 50 10 f0 	movl   $0xf0105049,(%esp)
f0100110:	e8 d2 35 00 00       	call   f01036e7 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f0100115:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f010011c:	e8 1f ff ff ff       	call   f0100040 <test_backtrace>

	// Lab 3 user environment initialization functions
	env_init();
f0100121:	e8 c8 2e 00 00       	call   f0102fee <env_init>
	trap_init();
f0100126:	e8 36 36 00 00       	call   f0103761 <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010012b:	83 c4 08             	add    $0x8,%esp
f010012e:	6a 00                	push   $0x0
f0100130:	68 3e 07 14 f0       	push   $0xf014073e
f0100135:	e8 cd 30 00 00       	call   f0103207 <env_create>
	// Touch all you want.
	ENV_CREATE(user_divzero, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f010013a:	83 c4 04             	add    $0x4,%esp
f010013d:	ff 35 2c 61 1b f0    	pushl  0xf01b612c
f0100143:	e8 d5 34 00 00       	call   f010361d <env_run>

f0100148 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100148:	55                   	push   %ebp
f0100149:	89 e5                	mov    %esp,%ebp
f010014b:	56                   	push   %esi
f010014c:	53                   	push   %ebx
f010014d:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100150:	83 3d e0 6d 1b f0 00 	cmpl   $0x0,0xf01b6de0
f0100157:	74 0f                	je     f0100168 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100159:	83 ec 0c             	sub    $0xc,%esp
f010015c:	6a 00                	push   $0x0
f010015e:	e8 20 0b 00 00       	call   f0100c83 <monitor>
f0100163:	83 c4 10             	add    $0x10,%esp
f0100166:	eb f1                	jmp    f0100159 <_panic+0x11>
	panicstr = fmt;
f0100168:	89 35 e0 6d 1b f0    	mov    %esi,0xf01b6de0
	asm volatile("cli; cld");
f010016e:	fa                   	cli    
f010016f:	fc                   	cld    
	va_start(ap, fmt);
f0100170:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100173:	83 ec 04             	sub    $0x4,%esp
f0100176:	ff 75 0c             	pushl  0xc(%ebp)
f0100179:	ff 75 08             	pushl  0x8(%ebp)
f010017c:	68 66 50 10 f0       	push   $0xf0105066
f0100181:	e8 61 35 00 00       	call   f01036e7 <cprintf>
	vcprintf(fmt, ap);
f0100186:	83 c4 08             	add    $0x8,%esp
f0100189:	53                   	push   %ebx
f010018a:	56                   	push   %esi
f010018b:	e8 31 35 00 00       	call   f01036c1 <vcprintf>
	cprintf("\n");
f0100190:	c7 04 24 fb 53 10 f0 	movl   $0xf01053fb,(%esp)
f0100197:	e8 4b 35 00 00       	call   f01036e7 <cprintf>
f010019c:	83 c4 10             	add    $0x10,%esp
f010019f:	eb b8                	jmp    f0100159 <_panic+0x11>

f01001a1 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01001a1:	55                   	push   %ebp
f01001a2:	89 e5                	mov    %esp,%ebp
f01001a4:	53                   	push   %ebx
f01001a5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01001a8:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01001ab:	ff 75 0c             	pushl  0xc(%ebp)
f01001ae:	ff 75 08             	pushl  0x8(%ebp)
f01001b1:	68 7e 50 10 f0       	push   $0xf010507e
f01001b6:	e8 2c 35 00 00       	call   f01036e7 <cprintf>
	vcprintf(fmt, ap);
f01001bb:	83 c4 08             	add    $0x8,%esp
f01001be:	53                   	push   %ebx
f01001bf:	ff 75 10             	pushl  0x10(%ebp)
f01001c2:	e8 fa 34 00 00       	call   f01036c1 <vcprintf>
	cprintf("\n");
f01001c7:	c7 04 24 fb 53 10 f0 	movl   $0xf01053fb,(%esp)
f01001ce:	e8 14 35 00 00       	call   f01036e7 <cprintf>
	va_end(ap);
}
f01001d3:	83 c4 10             	add    $0x10,%esp
f01001d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01001d9:	c9                   	leave  
f01001da:	c3                   	ret    

f01001db <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001db:	55                   	push   %ebp
f01001dc:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001de:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001e3:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001e4:	a8 01                	test   $0x1,%al
f01001e6:	74 0b                	je     f01001f3 <serial_proc_data+0x18>
f01001e8:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001ed:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001ee:	0f b6 c0             	movzbl %al,%eax
}
f01001f1:	5d                   	pop    %ebp
f01001f2:	c3                   	ret    
		return -1;
f01001f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001f8:	eb f7                	jmp    f01001f1 <serial_proc_data+0x16>

f01001fa <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001fa:	55                   	push   %ebp
f01001fb:	89 e5                	mov    %esp,%ebp
f01001fd:	53                   	push   %ebx
f01001fe:	83 ec 04             	sub    $0x4,%esp
f0100201:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100203:	ff d3                	call   *%ebx
f0100205:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100208:	74 2d                	je     f0100237 <cons_intr+0x3d>
		if (c == 0)
f010020a:	85 c0                	test   %eax,%eax
f010020c:	74 f5                	je     f0100203 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f010020e:	8b 0d 04 61 1b f0    	mov    0xf01b6104,%ecx
f0100214:	8d 51 01             	lea    0x1(%ecx),%edx
f0100217:	89 15 04 61 1b f0    	mov    %edx,0xf01b6104
f010021d:	88 81 00 5f 1b f0    	mov    %al,-0xfe4a100(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100223:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100229:	75 d8                	jne    f0100203 <cons_intr+0x9>
			cons.wpos = 0;
f010022b:	c7 05 04 61 1b f0 00 	movl   $0x0,0xf01b6104
f0100232:	00 00 00 
f0100235:	eb cc                	jmp    f0100203 <cons_intr+0x9>
	}
}
f0100237:	83 c4 04             	add    $0x4,%esp
f010023a:	5b                   	pop    %ebx
f010023b:	5d                   	pop    %ebp
f010023c:	c3                   	ret    

f010023d <kbd_proc_data>:
{
f010023d:	55                   	push   %ebp
f010023e:	89 e5                	mov    %esp,%ebp
f0100240:	53                   	push   %ebx
f0100241:	83 ec 04             	sub    $0x4,%esp
f0100244:	ba 64 00 00 00       	mov    $0x64,%edx
f0100249:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f010024a:	a8 01                	test   $0x1,%al
f010024c:	0f 84 f1 00 00 00    	je     f0100343 <kbd_proc_data+0x106>
	if (stat & KBS_TERR)
f0100252:	a8 20                	test   $0x20,%al
f0100254:	0f 85 f0 00 00 00    	jne    f010034a <kbd_proc_data+0x10d>
f010025a:	ba 60 00 00 00       	mov    $0x60,%edx
f010025f:	ec                   	in     (%dx),%al
f0100260:	88 c2                	mov    %al,%dl
	if (data == 0xE0) {
f0100262:	3c e0                	cmp    $0xe0,%al
f0100264:	0f 84 8a 00 00 00    	je     f01002f4 <kbd_proc_data+0xb7>
	} else if (data & 0x80) {
f010026a:	84 c0                	test   %al,%al
f010026c:	0f 88 95 00 00 00    	js     f0100307 <kbd_proc_data+0xca>
	} else if (shift & E0ESC) {
f0100272:	8b 0d e0 5e 1b f0    	mov    0xf01b5ee0,%ecx
f0100278:	f6 c1 40             	test   $0x40,%cl
f010027b:	74 0e                	je     f010028b <kbd_proc_data+0x4e>
		data |= 0x80;
f010027d:	83 c8 80             	or     $0xffffff80,%eax
f0100280:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f0100282:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100285:	89 0d e0 5e 1b f0    	mov    %ecx,0xf01b5ee0
	shift |= shiftcode[data];
f010028b:	0f b6 d2             	movzbl %dl,%edx
f010028e:	0f b6 82 40 52 10 f0 	movzbl -0xfefadc0(%edx),%eax
f0100295:	0b 05 e0 5e 1b f0    	or     0xf01b5ee0,%eax
	shift ^= togglecode[data];
f010029b:	0f b6 8a 40 51 10 f0 	movzbl -0xfefaec0(%edx),%ecx
f01002a2:	31 c8                	xor    %ecx,%eax
f01002a4:	a3 e0 5e 1b f0       	mov    %eax,0xf01b5ee0
	c = charcode[shift & (CTL | SHIFT)][data];
f01002a9:	89 c1                	mov    %eax,%ecx
f01002ab:	83 e1 03             	and    $0x3,%ecx
f01002ae:	8b 0c 8d 20 51 10 f0 	mov    -0xfefaee0(,%ecx,4),%ecx
f01002b5:	8a 14 11             	mov    (%ecx,%edx,1),%dl
f01002b8:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01002bb:	a8 08                	test   $0x8,%al
f01002bd:	74 0d                	je     f01002cc <kbd_proc_data+0x8f>
		if ('a' <= c && c <= 'z')
f01002bf:	89 da                	mov    %ebx,%edx
f01002c1:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01002c4:	83 f9 19             	cmp    $0x19,%ecx
f01002c7:	77 6d                	ja     f0100336 <kbd_proc_data+0xf9>
			c += 'A' - 'a';
f01002c9:	83 eb 20             	sub    $0x20,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002cc:	f7 d0                	not    %eax
f01002ce:	a8 06                	test   $0x6,%al
f01002d0:	75 2e                	jne    f0100300 <kbd_proc_data+0xc3>
f01002d2:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002d8:	75 26                	jne    f0100300 <kbd_proc_data+0xc3>
		cprintf("Rebooting!\n");
f01002da:	83 ec 0c             	sub    $0xc,%esp
f01002dd:	68 d8 50 10 f0       	push   $0xf01050d8
f01002e2:	e8 00 34 00 00       	call   f01036e7 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002e7:	b0 03                	mov    $0x3,%al
f01002e9:	ba 92 00 00 00       	mov    $0x92,%edx
f01002ee:	ee                   	out    %al,(%dx)
f01002ef:	83 c4 10             	add    $0x10,%esp
f01002f2:	eb 0c                	jmp    f0100300 <kbd_proc_data+0xc3>
		shift |= E0ESC;
f01002f4:	83 0d e0 5e 1b f0 40 	orl    $0x40,0xf01b5ee0
		return 0;
f01002fb:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100300:	89 d8                	mov    %ebx,%eax
f0100302:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100305:	c9                   	leave  
f0100306:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100307:	8b 0d e0 5e 1b f0    	mov    0xf01b5ee0,%ecx
f010030d:	f6 c1 40             	test   $0x40,%cl
f0100310:	75 05                	jne    f0100317 <kbd_proc_data+0xda>
f0100312:	83 e0 7f             	and    $0x7f,%eax
f0100315:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f0100317:	0f b6 d2             	movzbl %dl,%edx
f010031a:	8a 82 40 52 10 f0    	mov    -0xfefadc0(%edx),%al
f0100320:	83 c8 40             	or     $0x40,%eax
f0100323:	0f b6 c0             	movzbl %al,%eax
f0100326:	f7 d0                	not    %eax
f0100328:	21 c8                	and    %ecx,%eax
f010032a:	a3 e0 5e 1b f0       	mov    %eax,0xf01b5ee0
		return 0;
f010032f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100334:	eb ca                	jmp    f0100300 <kbd_proc_data+0xc3>
		else if ('A' <= c && c <= 'Z')
f0100336:	83 ea 41             	sub    $0x41,%edx
f0100339:	83 fa 19             	cmp    $0x19,%edx
f010033c:	77 8e                	ja     f01002cc <kbd_proc_data+0x8f>
			c += 'a' - 'A';
f010033e:	83 c3 20             	add    $0x20,%ebx
f0100341:	eb 89                	jmp    f01002cc <kbd_proc_data+0x8f>
		return -1;
f0100343:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0100348:	eb b6                	jmp    f0100300 <kbd_proc_data+0xc3>
		return -1;
f010034a:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010034f:	eb af                	jmp    f0100300 <kbd_proc_data+0xc3>

f0100351 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100351:	55                   	push   %ebp
f0100352:	89 e5                	mov    %esp,%ebp
f0100354:	57                   	push   %edi
f0100355:	56                   	push   %esi
f0100356:	53                   	push   %ebx
f0100357:	83 ec 1c             	sub    $0x1c,%esp
f010035a:	89 c7                	mov    %eax,%edi
f010035c:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100361:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100366:	b9 84 00 00 00       	mov    $0x84,%ecx
f010036b:	eb 06                	jmp    f0100373 <cons_putc+0x22>
f010036d:	89 ca                	mov    %ecx,%edx
f010036f:	ec                   	in     (%dx),%al
f0100370:	ec                   	in     (%dx),%al
f0100371:	ec                   	in     (%dx),%al
f0100372:	ec                   	in     (%dx),%al
f0100373:	89 f2                	mov    %esi,%edx
f0100375:	ec                   	in     (%dx),%al
	for (i = 0;
f0100376:	a8 20                	test   $0x20,%al
f0100378:	75 03                	jne    f010037d <cons_putc+0x2c>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010037a:	4b                   	dec    %ebx
f010037b:	75 f0                	jne    f010036d <cons_putc+0x1c>
	outb(COM1 + COM_TX, c);
f010037d:	89 f8                	mov    %edi,%eax
f010037f:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100382:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100387:	ee                   	out    %al,(%dx)
f0100388:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010038d:	be 79 03 00 00       	mov    $0x379,%esi
f0100392:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100397:	eb 06                	jmp    f010039f <cons_putc+0x4e>
f0100399:	89 ca                	mov    %ecx,%edx
f010039b:	ec                   	in     (%dx),%al
f010039c:	ec                   	in     (%dx),%al
f010039d:	ec                   	in     (%dx),%al
f010039e:	ec                   	in     (%dx),%al
f010039f:	89 f2                	mov    %esi,%edx
f01003a1:	ec                   	in     (%dx),%al
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003a2:	84 c0                	test   %al,%al
f01003a4:	78 03                	js     f01003a9 <cons_putc+0x58>
f01003a6:	4b                   	dec    %ebx
f01003a7:	75 f0                	jne    f0100399 <cons_putc+0x48>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003a9:	ba 78 03 00 00       	mov    $0x378,%edx
f01003ae:	8a 45 e7             	mov    -0x19(%ebp),%al
f01003b1:	ee                   	out    %al,(%dx)
f01003b2:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003b7:	b0 0d                	mov    $0xd,%al
f01003b9:	ee                   	out    %al,(%dx)
f01003ba:	b0 08                	mov    $0x8,%al
f01003bc:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01003bd:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f01003c3:	75 06                	jne    f01003cb <cons_putc+0x7a>
		c |= 0x0700;
f01003c5:	81 cf 00 07 00 00    	or     $0x700,%edi
	switch (c & 0xff) {
f01003cb:	89 f8                	mov    %edi,%eax
f01003cd:	0f b6 c0             	movzbl %al,%eax
f01003d0:	83 f8 09             	cmp    $0x9,%eax
f01003d3:	0f 84 b1 00 00 00    	je     f010048a <cons_putc+0x139>
f01003d9:	83 f8 09             	cmp    $0x9,%eax
f01003dc:	7e 70                	jle    f010044e <cons_putc+0xfd>
f01003de:	83 f8 0a             	cmp    $0xa,%eax
f01003e1:	0f 84 96 00 00 00    	je     f010047d <cons_putc+0x12c>
f01003e7:	83 f8 0d             	cmp    $0xd,%eax
f01003ea:	0f 85 d1 00 00 00    	jne    f01004c1 <cons_putc+0x170>
		crt_pos -= (crt_pos % CRT_COLS);
f01003f0:	66 8b 0d 08 61 1b f0 	mov    0xf01b6108,%cx
f01003f7:	bb 50 00 00 00       	mov    $0x50,%ebx
f01003fc:	89 c8                	mov    %ecx,%eax
f01003fe:	ba 00 00 00 00       	mov    $0x0,%edx
f0100403:	66 f7 f3             	div    %bx
f0100406:	29 d1                	sub    %edx,%ecx
f0100408:	66 89 0d 08 61 1b f0 	mov    %cx,0xf01b6108
	if (crt_pos >= CRT_SIZE) {
f010040f:	66 81 3d 08 61 1b f0 	cmpw   $0x7cf,0xf01b6108
f0100416:	cf 07 
f0100418:	0f 87 c5 00 00 00    	ja     f01004e3 <cons_putc+0x192>
	outb(addr_6845, 14);
f010041e:	8b 0d 10 61 1b f0    	mov    0xf01b6110,%ecx
f0100424:	b0 0e                	mov    $0xe,%al
f0100426:	89 ca                	mov    %ecx,%edx
f0100428:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100429:	8d 59 01             	lea    0x1(%ecx),%ebx
f010042c:	66 a1 08 61 1b f0    	mov    0xf01b6108,%ax
f0100432:	66 c1 e8 08          	shr    $0x8,%ax
f0100436:	89 da                	mov    %ebx,%edx
f0100438:	ee                   	out    %al,(%dx)
f0100439:	b0 0f                	mov    $0xf,%al
f010043b:	89 ca                	mov    %ecx,%edx
f010043d:	ee                   	out    %al,(%dx)
f010043e:	a0 08 61 1b f0       	mov    0xf01b6108,%al
f0100443:	89 da                	mov    %ebx,%edx
f0100445:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100446:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100449:	5b                   	pop    %ebx
f010044a:	5e                   	pop    %esi
f010044b:	5f                   	pop    %edi
f010044c:	5d                   	pop    %ebp
f010044d:	c3                   	ret    
	switch (c & 0xff) {
f010044e:	83 f8 08             	cmp    $0x8,%eax
f0100451:	75 6e                	jne    f01004c1 <cons_putc+0x170>
		if (crt_pos > 0) {
f0100453:	66 a1 08 61 1b f0    	mov    0xf01b6108,%ax
f0100459:	66 85 c0             	test   %ax,%ax
f010045c:	74 c0                	je     f010041e <cons_putc+0xcd>
			crt_pos--;
f010045e:	48                   	dec    %eax
f010045f:	66 a3 08 61 1b f0    	mov    %ax,0xf01b6108
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100465:	0f b7 c0             	movzwl %ax,%eax
f0100468:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f010046e:	83 cf 20             	or     $0x20,%edi
f0100471:	8b 15 0c 61 1b f0    	mov    0xf01b610c,%edx
f0100477:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010047b:	eb 92                	jmp    f010040f <cons_putc+0xbe>
		crt_pos += CRT_COLS;
f010047d:	66 83 05 08 61 1b f0 	addw   $0x50,0xf01b6108
f0100484:	50 
f0100485:	e9 66 ff ff ff       	jmp    f01003f0 <cons_putc+0x9f>
		cons_putc(' ');
f010048a:	b8 20 00 00 00       	mov    $0x20,%eax
f010048f:	e8 bd fe ff ff       	call   f0100351 <cons_putc>
		cons_putc(' ');
f0100494:	b8 20 00 00 00       	mov    $0x20,%eax
f0100499:	e8 b3 fe ff ff       	call   f0100351 <cons_putc>
		cons_putc(' ');
f010049e:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a3:	e8 a9 fe ff ff       	call   f0100351 <cons_putc>
		cons_putc(' ');
f01004a8:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ad:	e8 9f fe ff ff       	call   f0100351 <cons_putc>
		cons_putc(' ');
f01004b2:	b8 20 00 00 00       	mov    $0x20,%eax
f01004b7:	e8 95 fe ff ff       	call   f0100351 <cons_putc>
f01004bc:	e9 4e ff ff ff       	jmp    f010040f <cons_putc+0xbe>
		crt_buf[crt_pos++] = c;		/* write the character */
f01004c1:	66 a1 08 61 1b f0    	mov    0xf01b6108,%ax
f01004c7:	8d 50 01             	lea    0x1(%eax),%edx
f01004ca:	66 89 15 08 61 1b f0 	mov    %dx,0xf01b6108
f01004d1:	0f b7 c0             	movzwl %ax,%eax
f01004d4:	8b 15 0c 61 1b f0    	mov    0xf01b610c,%edx
f01004da:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004de:	e9 2c ff ff ff       	jmp    f010040f <cons_putc+0xbe>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004e3:	a1 0c 61 1b f0       	mov    0xf01b610c,%eax
f01004e8:	83 ec 04             	sub    $0x4,%esp
f01004eb:	68 00 0f 00 00       	push   $0xf00
f01004f0:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004f6:	52                   	push   %edx
f01004f7:	50                   	push   %eax
f01004f8:	e8 32 46 00 00       	call   f0104b2f <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01004fd:	8b 15 0c 61 1b f0    	mov    0xf01b610c,%edx
f0100503:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100509:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010050f:	83 c4 10             	add    $0x10,%esp
f0100512:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100517:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010051a:	39 d0                	cmp    %edx,%eax
f010051c:	75 f4                	jne    f0100512 <cons_putc+0x1c1>
		crt_pos -= CRT_COLS;
f010051e:	66 83 2d 08 61 1b f0 	subw   $0x50,0xf01b6108
f0100525:	50 
f0100526:	e9 f3 fe ff ff       	jmp    f010041e <cons_putc+0xcd>

f010052b <serial_intr>:
	if (serial_exists)
f010052b:	80 3d 14 61 1b f0 00 	cmpb   $0x0,0xf01b6114
f0100532:	75 01                	jne    f0100535 <serial_intr+0xa>
f0100534:	c3                   	ret    
{
f0100535:	55                   	push   %ebp
f0100536:	89 e5                	mov    %esp,%ebp
f0100538:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010053b:	b8 db 01 10 f0       	mov    $0xf01001db,%eax
f0100540:	e8 b5 fc ff ff       	call   f01001fa <cons_intr>
}
f0100545:	c9                   	leave  
f0100546:	c3                   	ret    

f0100547 <kbd_intr>:
{
f0100547:	55                   	push   %ebp
f0100548:	89 e5                	mov    %esp,%ebp
f010054a:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010054d:	b8 3d 02 10 f0       	mov    $0xf010023d,%eax
f0100552:	e8 a3 fc ff ff       	call   f01001fa <cons_intr>
}
f0100557:	c9                   	leave  
f0100558:	c3                   	ret    

f0100559 <cons_getc>:
{
f0100559:	55                   	push   %ebp
f010055a:	89 e5                	mov    %esp,%ebp
f010055c:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f010055f:	e8 c7 ff ff ff       	call   f010052b <serial_intr>
	kbd_intr();
f0100564:	e8 de ff ff ff       	call   f0100547 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100569:	a1 00 61 1b f0       	mov    0xf01b6100,%eax
f010056e:	3b 05 04 61 1b f0    	cmp    0xf01b6104,%eax
f0100574:	74 26                	je     f010059c <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100576:	8d 50 01             	lea    0x1(%eax),%edx
f0100579:	89 15 00 61 1b f0    	mov    %edx,0xf01b6100
f010057f:	0f b6 80 00 5f 1b f0 	movzbl -0xfe4a100(%eax),%eax
		if (cons.rpos == CONSBUFSIZE)
f0100586:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010058c:	74 02                	je     f0100590 <cons_getc+0x37>
}
f010058e:	c9                   	leave  
f010058f:	c3                   	ret    
			cons.rpos = 0;
f0100590:	c7 05 00 61 1b f0 00 	movl   $0x0,0xf01b6100
f0100597:	00 00 00 
f010059a:	eb f2                	jmp    f010058e <cons_getc+0x35>
	return 0;
f010059c:	b8 00 00 00 00       	mov    $0x0,%eax
f01005a1:	eb eb                	jmp    f010058e <cons_getc+0x35>

f01005a3 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01005a3:	55                   	push   %ebp
f01005a4:	89 e5                	mov    %esp,%ebp
f01005a6:	57                   	push   %edi
f01005a7:	56                   	push   %esi
f01005a8:	53                   	push   %ebx
f01005a9:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f01005ac:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f01005b3:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01005ba:	5a a5 
	if (*cp != 0xA55A) {
f01005bc:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f01005c2:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005c6:	0f 84 a2 00 00 00    	je     f010066e <cons_init+0xcb>
		addr_6845 = MONO_BASE;
f01005cc:	c7 05 10 61 1b f0 b4 	movl   $0x3b4,0xf01b6110
f01005d3:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005d6:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f01005db:	8b 3d 10 61 1b f0    	mov    0xf01b6110,%edi
f01005e1:	b0 0e                	mov    $0xe,%al
f01005e3:	89 fa                	mov    %edi,%edx
f01005e5:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005e6:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005e9:	89 ca                	mov    %ecx,%edx
f01005eb:	ec                   	in     (%dx),%al
f01005ec:	0f b6 c0             	movzbl %al,%eax
f01005ef:	c1 e0 08             	shl    $0x8,%eax
f01005f2:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005f4:	b0 0f                	mov    $0xf,%al
f01005f6:	89 fa                	mov    %edi,%edx
f01005f8:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005f9:	89 ca                	mov    %ecx,%edx
f01005fb:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01005fc:	89 35 0c 61 1b f0    	mov    %esi,0xf01b610c
	pos |= inb(addr_6845 + 1);
f0100602:	0f b6 c0             	movzbl %al,%eax
f0100605:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f0100607:	66 a3 08 61 1b f0    	mov    %ax,0xf01b6108
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010060d:	b1 00                	mov    $0x0,%cl
f010060f:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100614:	88 c8                	mov    %cl,%al
f0100616:	89 da                	mov    %ebx,%edx
f0100618:	ee                   	out    %al,(%dx)
f0100619:	bf fb 03 00 00       	mov    $0x3fb,%edi
f010061e:	b0 80                	mov    $0x80,%al
f0100620:	89 fa                	mov    %edi,%edx
f0100622:	ee                   	out    %al,(%dx)
f0100623:	b0 0c                	mov    $0xc,%al
f0100625:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010062a:	ee                   	out    %al,(%dx)
f010062b:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100630:	88 c8                	mov    %cl,%al
f0100632:	89 f2                	mov    %esi,%edx
f0100634:	ee                   	out    %al,(%dx)
f0100635:	b0 03                	mov    $0x3,%al
f0100637:	89 fa                	mov    %edi,%edx
f0100639:	ee                   	out    %al,(%dx)
f010063a:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010063f:	88 c8                	mov    %cl,%al
f0100641:	ee                   	out    %al,(%dx)
f0100642:	b0 01                	mov    $0x1,%al
f0100644:	89 f2                	mov    %esi,%edx
f0100646:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100647:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010064c:	ec                   	in     (%dx),%al
f010064d:	88 c1                	mov    %al,%cl
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010064f:	3c ff                	cmp    $0xff,%al
f0100651:	0f 95 05 14 61 1b f0 	setne  0xf01b6114
f0100658:	89 da                	mov    %ebx,%edx
f010065a:	ec                   	in     (%dx),%al
f010065b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100660:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100661:	80 f9 ff             	cmp    $0xff,%cl
f0100664:	74 23                	je     f0100689 <cons_init+0xe6>
		cprintf("Serial port does not exist!\n");
}
f0100666:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100669:	5b                   	pop    %ebx
f010066a:	5e                   	pop    %esi
f010066b:	5f                   	pop    %edi
f010066c:	5d                   	pop    %ebp
f010066d:	c3                   	ret    
		*cp = was;
f010066e:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100675:	c7 05 10 61 1b f0 d4 	movl   $0x3d4,0xf01b6110
f010067c:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010067f:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f0100684:	e9 52 ff ff ff       	jmp    f01005db <cons_init+0x38>
		cprintf("Serial port does not exist!\n");
f0100689:	83 ec 0c             	sub    $0xc,%esp
f010068c:	68 e4 50 10 f0       	push   $0xf01050e4
f0100691:	e8 51 30 00 00       	call   f01036e7 <cprintf>
f0100696:	83 c4 10             	add    $0x10,%esp
}
f0100699:	eb cb                	jmp    f0100666 <cons_init+0xc3>

f010069b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010069b:	55                   	push   %ebp
f010069c:	89 e5                	mov    %esp,%ebp
f010069e:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01006a1:	8b 45 08             	mov    0x8(%ebp),%eax
f01006a4:	e8 a8 fc ff ff       	call   f0100351 <cons_putc>
}
f01006a9:	c9                   	leave  
f01006aa:	c3                   	ret    

f01006ab <getchar>:

int
getchar(void)
{
f01006ab:	55                   	push   %ebp
f01006ac:	89 e5                	mov    %esp,%ebp
f01006ae:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01006b1:	e8 a3 fe ff ff       	call   f0100559 <cons_getc>
f01006b6:	85 c0                	test   %eax,%eax
f01006b8:	74 f7                	je     f01006b1 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01006ba:	c9                   	leave  
f01006bb:	c3                   	ret    

f01006bc <iscons>:

int
iscons(int fdnum)
{
f01006bc:	55                   	push   %ebp
f01006bd:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01006bf:	b8 01 00 00 00       	mov    $0x1,%eax
f01006c4:	5d                   	pop    %ebp
f01006c5:	c3                   	ret    

f01006c6 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006c6:	55                   	push   %ebp
f01006c7:	89 e5                	mov    %esp,%ebp
f01006c9:	53                   	push   %ebx
f01006ca:	83 ec 04             	sub    $0x4,%esp
f01006cd:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006d2:	83 ec 04             	sub    $0x4,%esp
f01006d5:	ff b3 44 58 10 f0    	pushl  -0xfefa7bc(%ebx)
f01006db:	ff b3 40 58 10 f0    	pushl  -0xfefa7c0(%ebx)
f01006e1:	68 40 53 10 f0       	push   $0xf0105340
f01006e6:	e8 fc 2f 00 00       	call   f01036e7 <cprintf>
f01006eb:	83 c3 0c             	add    $0xc,%ebx
	for (i = 0; i < ARRAY_SIZE(commands); i++)
f01006ee:	83 c4 10             	add    $0x10,%esp
f01006f1:	83 fb 3c             	cmp    $0x3c,%ebx
f01006f4:	75 dc                	jne    f01006d2 <mon_help+0xc>
	return 0;
}
f01006f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01006fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01006fe:	c9                   	leave  
f01006ff:	c3                   	ret    

f0100700 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100700:	55                   	push   %ebp
f0100701:	89 e5                	mov    %esp,%ebp
f0100703:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100706:	68 49 53 10 f0       	push   $0xf0105349
f010070b:	e8 d7 2f 00 00       	call   f01036e7 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100710:	83 c4 08             	add    $0x8,%esp
f0100713:	68 0c 00 10 00       	push   $0x10000c
f0100718:	68 a0 54 10 f0       	push   $0xf01054a0
f010071d:	e8 c5 2f 00 00       	call   f01036e7 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100722:	83 c4 0c             	add    $0xc,%esp
f0100725:	68 0c 00 10 00       	push   $0x10000c
f010072a:	68 0c 00 10 f0       	push   $0xf010000c
f010072f:	68 c8 54 10 f0       	push   $0xf01054c8
f0100734:	e8 ae 2f 00 00       	call   f01036e7 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100739:	83 c4 0c             	add    $0xc,%esp
f010073c:	68 94 4f 10 00       	push   $0x104f94
f0100741:	68 94 4f 10 f0       	push   $0xf0104f94
f0100746:	68 ec 54 10 f0       	push   $0xf01054ec
f010074b:	e8 97 2f 00 00       	call   f01036e7 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100750:	83 c4 0c             	add    $0xc,%esp
f0100753:	68 c6 5e 1b 00       	push   $0x1b5ec6
f0100758:	68 c6 5e 1b f0       	push   $0xf01b5ec6
f010075d:	68 10 55 10 f0       	push   $0xf0105510
f0100762:	e8 80 2f 00 00       	call   f01036e7 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100767:	83 c4 0c             	add    $0xc,%esp
f010076a:	68 f0 6d 1b 00       	push   $0x1b6df0
f010076f:	68 f0 6d 1b f0       	push   $0xf01b6df0
f0100774:	68 34 55 10 f0       	push   $0xf0105534
f0100779:	e8 69 2f 00 00       	call   f01036e7 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010077e:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100781:	b8 ef 71 1b f0       	mov    $0xf01b71ef,%eax
f0100786:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f010078b:	c1 f8 0a             	sar    $0xa,%eax
f010078e:	50                   	push   %eax
f010078f:	68 58 55 10 f0       	push   $0xf0105558
f0100794:	e8 4e 2f 00 00       	call   f01036e7 <cprintf>
	return 0;
}
f0100799:	b8 00 00 00 00       	mov    $0x0,%eax
f010079e:	c9                   	leave  
f010079f:	c3                   	ret    

f01007a0 <mon_showmap>:
	}
	return 0;
}

int 
mon_showmap(int argc, char **argv, struct Trapframe *tf) {
f01007a0:	55                   	push   %ebp
f01007a1:	89 e5                	mov    %esp,%ebp
f01007a3:	56                   	push   %esi
f01007a4:	53                   	push   %ebx
f01007a5:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc <= 2) {
f01007a8:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f01007ac:	7e 3c                	jle    f01007ea <mon_showmap+0x4a>
		cprintf("Usage: showmap l r\n");
		return 0;
	}
	uintptr_t l = strtoul(argv[1], NULL, 0), 
f01007ae:	83 ec 04             	sub    $0x4,%esp
f01007b1:	6a 00                	push   $0x0
f01007b3:	6a 00                	push   $0x0
f01007b5:	ff 76 04             	pushl  0x4(%esi)
f01007b8:	e8 06 45 00 00       	call   f0104cc3 <strtoul>
f01007bd:	89 c3                	mov    %eax,%ebx
		 	  r = strtoul(argv[2], NULL, 0); // In string.h
f01007bf:	83 c4 0c             	add    $0xc,%esp
f01007c2:	6a 00                	push   $0x0
f01007c4:	6a 00                	push   $0x0
f01007c6:	ff 76 08             	pushl  0x8(%esi)
f01007c9:	e8 f5 44 00 00       	call   f0104cc3 <strtoul>
	if (l > r) {
f01007ce:	83 c4 10             	add    $0x10,%esp
f01007d1:	39 c3                	cmp    %eax,%ebx
f01007d3:	77 31                	ja     f0100806 <mon_showmap+0x66>
		cprintf("Invalid range; aborting.\n");
		return 0;
	}
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f01007d5:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f01007db:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f01007e1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01007e6:	89 c6                	mov    %eax,%esi
f01007e8:	eb 45                	jmp    f010082f <mon_showmap+0x8f>
		cprintf("Usage: showmap l r\n");
f01007ea:	83 ec 0c             	sub    $0xc,%esp
f01007ed:	68 62 53 10 f0       	push   $0xf0105362
f01007f2:	e8 f0 2e 00 00       	call   f01036e7 <cprintf>
		return 0;
f01007f7:	83 c4 10             	add    $0x10,%esp
		else 
			cprintf("0x%08x -> 0x%08x; perm = 0x%03x\n", 
					sz, PTE_ADDR(*pte), *pte & 0xFFF);
	}
	return 0;
}
f01007fa:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100802:	5b                   	pop    %ebx
f0100803:	5e                   	pop    %esi
f0100804:	5d                   	pop    %ebp
f0100805:	c3                   	ret    
		cprintf("Invalid range; aborting.\n");
f0100806:	83 ec 0c             	sub    $0xc,%esp
f0100809:	68 76 53 10 f0       	push   $0xf0105376
f010080e:	e8 d4 2e 00 00       	call   f01036e7 <cprintf>
		return 0;
f0100813:	83 c4 10             	add    $0x10,%esp
f0100816:	eb e2                	jmp    f01007fa <mon_showmap+0x5a>
			cprintf("0x%08x -> ----------; perm = ---\n", sz);
f0100818:	83 ec 08             	sub    $0x8,%esp
f010081b:	53                   	push   %ebx
f010081c:	68 84 55 10 f0       	push   $0xf0105584
f0100821:	e8 c1 2e 00 00       	call   f01036e7 <cprintf>
f0100826:	83 c4 10             	add    $0x10,%esp
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f0100829:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010082f:	39 f3                	cmp    %esi,%ebx
f0100831:	77 c7                	ja     f01007fa <mon_showmap+0x5a>
		pte_t* pte = pgdir_walk(kern_pgdir, (void*) sz, 0);
f0100833:	83 ec 04             	sub    $0x4,%esp
f0100836:	6a 00                	push   $0x0
f0100838:	53                   	push   %ebx
f0100839:	ff 35 e8 6d 1b f0    	pushl  0xf01b6de8
f010083f:	e8 9e 0a 00 00       	call   f01012e2 <pgdir_walk>
		if (pte == NULL || !*pte)
f0100844:	83 c4 10             	add    $0x10,%esp
f0100847:	85 c0                	test   %eax,%eax
f0100849:	74 cd                	je     f0100818 <mon_showmap+0x78>
f010084b:	8b 00                	mov    (%eax),%eax
f010084d:	85 c0                	test   %eax,%eax
f010084f:	74 c7                	je     f0100818 <mon_showmap+0x78>
			cprintf("0x%08x -> 0x%08x; perm = 0x%03x\n", 
f0100851:	89 c2                	mov    %eax,%edx
f0100853:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f0100859:	52                   	push   %edx
f010085a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010085f:	50                   	push   %eax
f0100860:	53                   	push   %ebx
f0100861:	68 a8 55 10 f0       	push   $0xf01055a8
f0100866:	e8 7c 2e 00 00       	call   f01036e7 <cprintf>
f010086b:	83 c4 10             	add    $0x10,%esp
f010086e:	eb b9                	jmp    f0100829 <mon_showmap+0x89>

f0100870 <mon_chmod>:

int
mon_chmod(int argc, char **argv, struct Trapframe *tf) {
f0100870:	55                   	push   %ebp
f0100871:	89 e5                	mov    %esp,%ebp
f0100873:	57                   	push   %edi
f0100874:	56                   	push   %esi
f0100875:	53                   	push   %ebx
f0100876:	83 ec 1c             	sub    $0x1c,%esp
f0100879:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc <= 2) {
f010087c:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100880:	7e 67                	jle    f01008e9 <mon_chmod+0x79>
		cprintf("Usage: chmod mod l [r] [-v]\n");
		return 0;
	}
	uintptr_t mod = strtoul(argv[1], NULL, 0),  
f0100882:	83 ec 04             	sub    $0x4,%esp
f0100885:	6a 00                	push   $0x0
f0100887:	6a 00                	push   $0x0
f0100889:	ff 76 04             	pushl  0x4(%esi)
f010088c:	e8 32 44 00 00       	call   f0104cc3 <strtoul>
f0100891:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			  l = strtoul(argv[2], NULL, 0), 
f0100894:	83 c4 0c             	add    $0xc,%esp
f0100897:	6a 00                	push   $0x0
f0100899:	6a 00                	push   $0x0
f010089b:	ff 76 08             	pushl  0x8(%esi)
f010089e:	e8 20 44 00 00       	call   f0104cc3 <strtoul>
f01008a3:	89 c3                	mov    %eax,%ebx
			  r = argc >= 4 ? strtoul(argv[3], NULL, 0) : l;
f01008a5:	83 c4 10             	add    $0x10,%esp
f01008a8:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f01008ac:	7f 58                	jg     f0100906 <mon_chmod+0x96>
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
	if (mod > 0xFFF) {
f01008ae:	81 7d e4 ff 0f 00 00 	cmpl   $0xfff,-0x1c(%ebp)
f01008b5:	0f 87 9a 00 00 00    	ja     f0100955 <mon_chmod+0xe5>
			  r = argc >= 4 ? strtoul(argv[3], NULL, 0) : l;
f01008bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
f01008be:	bf 00 00 00 00       	mov    $0x0,%edi
	}
	if (l > r) {
		cprintf("Invalid range; aborting.\n");
		return 0;
	}
	if (!(mod & PTE_P)) {
f01008c3:	f6 45 e4 01          	testb  $0x1,-0x1c(%ebp)
f01008c7:	0f 84 9a 00 00 00    	je     f0100967 <mon_chmod+0xf7>
		cprintf("Warning: PTE_P flag is not provided; added automatically.");
		mod |= PTE_P;
	}
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f01008cd:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f01008d3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f01008d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01008dc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01008e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01008e4:	e9 a1 00 00 00       	jmp    f010098a <mon_chmod+0x11a>
		cprintf("Usage: chmod mod l [r] [-v]\n");
f01008e9:	83 ec 0c             	sub    $0xc,%esp
f01008ec:	68 90 53 10 f0       	push   $0xf0105390
f01008f1:	e8 f1 2d 00 00       	call   f01036e7 <cprintf>
		return 0;
f01008f6:	83 c4 10             	add    $0x10,%esp
						sz, *pte & 0xFFF, mod);
			*pte = PTE_ADDR(*pte) | mod;
		}
	}
	return 0;
}
f01008f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01008fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100901:	5b                   	pop    %ebx
f0100902:	5e                   	pop    %esi
f0100903:	5f                   	pop    %edi
f0100904:	5d                   	pop    %ebp
f0100905:	c3                   	ret    
			  r = argc >= 4 ? strtoul(argv[3], NULL, 0) : l;
f0100906:	83 ec 04             	sub    $0x4,%esp
f0100909:	6a 00                	push   $0x0
f010090b:	6a 00                	push   $0x0
f010090d:	ff 76 0c             	pushl  0xc(%esi)
f0100910:	e8 ae 43 00 00       	call   f0104cc3 <strtoul>
f0100915:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
f0100918:	83 c4 08             	add    $0x8,%esp
f010091b:	68 ad 53 10 f0       	push   $0xf01053ad
f0100920:	ff 76 0c             	pushl  0xc(%esi)
f0100923:	e8 31 41 00 00       	call   f0104a59 <strcmp>
f0100928:	83 c4 10             	add    $0x10,%esp
f010092b:	85 c0                	test   %eax,%eax
f010092d:	0f 94 c0             	sete   %al
f0100930:	0f b6 c0             	movzbl %al,%eax
f0100933:	89 c7                	mov    %eax,%edi
	if (mod > 0xFFF) {
f0100935:	81 7d e4 ff 0f 00 00 	cmpl   $0xfff,-0x1c(%ebp)
f010093c:	77 17                	ja     f0100955 <mon_chmod+0xe5>
	if (l > r) {
f010093e:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0100941:	76 80                	jbe    f01008c3 <mon_chmod+0x53>
		cprintf("Invalid range; aborting.\n");
f0100943:	83 ec 0c             	sub    $0xc,%esp
f0100946:	68 76 53 10 f0       	push   $0xf0105376
f010094b:	e8 97 2d 00 00       	call   f01036e7 <cprintf>
		return 0;
f0100950:	83 c4 10             	add    $0x10,%esp
f0100953:	eb a4                	jmp    f01008f9 <mon_chmod+0x89>
		cprintf("Permission exceeds 0xfff; aborting.\n");
f0100955:	83 ec 0c             	sub    $0xc,%esp
f0100958:	68 cc 55 10 f0       	push   $0xf01055cc
f010095d:	e8 85 2d 00 00       	call   f01036e7 <cprintf>
		return 0;
f0100962:	83 c4 10             	add    $0x10,%esp
f0100965:	eb 92                	jmp    f01008f9 <mon_chmod+0x89>
		cprintf("Warning: PTE_P flag is not provided; added automatically.");
f0100967:	83 ec 0c             	sub    $0xc,%esp
f010096a:	68 f4 55 10 f0       	push   $0xf01055f4
f010096f:	e8 73 2d 00 00       	call   f01036e7 <cprintf>
		mod |= PTE_P;
f0100974:	83 4d e4 01          	orl    $0x1,-0x1c(%ebp)
f0100978:	83 c4 10             	add    $0x10,%esp
f010097b:	e9 4d ff ff ff       	jmp    f01008cd <mon_chmod+0x5d>
			if (verbose)
f0100980:	85 ff                	test   %edi,%edi
f0100982:	75 41                	jne    f01009c5 <mon_chmod+0x155>
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f0100984:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010098a:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f010098d:	0f 87 66 ff ff ff    	ja     f01008f9 <mon_chmod+0x89>
		pte_t* pte = pgdir_walk(kern_pgdir, (void*) sz, 0);
f0100993:	83 ec 04             	sub    $0x4,%esp
f0100996:	6a 00                	push   $0x0
f0100998:	53                   	push   %ebx
f0100999:	ff 35 e8 6d 1b f0    	pushl  0xf01b6de8
f010099f:	e8 3e 09 00 00       	call   f01012e2 <pgdir_walk>
f01009a4:	89 c6                	mov    %eax,%esi
		if (pte == NULL || !*pte) {
f01009a6:	83 c4 10             	add    $0x10,%esp
f01009a9:	85 c0                	test   %eax,%eax
f01009ab:	74 d3                	je     f0100980 <mon_chmod+0x110>
f01009ad:	8b 00                	mov    (%eax),%eax
f01009af:	85 c0                	test   %eax,%eax
f01009b1:	74 cd                	je     f0100980 <mon_chmod+0x110>
			if (verbose) 
f01009b3:	85 ff                	test   %edi,%edi
f01009b5:	75 21                	jne    f01009d8 <mon_chmod+0x168>
			*pte = PTE_ADDR(*pte) | mod;
f01009b7:	8b 06                	mov    (%esi),%eax
f01009b9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009be:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01009c1:	89 06                	mov    %eax,(%esi)
f01009c3:	eb bf                	jmp    f0100984 <mon_chmod+0x114>
				cprintf("Page va = 0x%08x is not mapped; skipping.\n", sz);
f01009c5:	83 ec 08             	sub    $0x8,%esp
f01009c8:	53                   	push   %ebx
f01009c9:	68 30 56 10 f0       	push   $0xf0105630
f01009ce:	e8 14 2d 00 00       	call   f01036e7 <cprintf>
f01009d3:	83 c4 10             	add    $0x10,%esp
f01009d6:	eb ac                	jmp    f0100984 <mon_chmod+0x114>
				cprintf("Page va = 0x%08x perm = 0x%03x changed to 0x%03x\n", 
f01009d8:	ff 75 e4             	pushl  -0x1c(%ebp)
f01009db:	25 ff 0f 00 00       	and    $0xfff,%eax
f01009e0:	50                   	push   %eax
f01009e1:	53                   	push   %ebx
f01009e2:	68 5c 56 10 f0       	push   $0xf010565c
f01009e7:	e8 fb 2c 00 00       	call   f01036e7 <cprintf>
f01009ec:	83 c4 10             	add    $0x10,%esp
f01009ef:	eb c6                	jmp    f01009b7 <mon_chmod+0x147>

f01009f1 <mon_dump>:

int
mon_dump(int argc, char **argv, struct Trapframe *tf) {
f01009f1:	55                   	push   %ebp
f01009f2:	89 e5                	mov    %esp,%ebp
f01009f4:	57                   	push   %edi
f01009f5:	56                   	push   %esi
f01009f6:	53                   	push   %ebx
f01009f7:	83 ec 1c             	sub    $0x1c,%esp
f01009fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (argc <= 2 || argc > 4) {
f01009fd:	8d 43 fd             	lea    -0x3(%ebx),%eax
f0100a00:	83 f8 01             	cmp    $0x1,%eax
f0100a03:	76 1d                	jbe    f0100a22 <mon_dump+0x31>
		cprintf("Usage: dump l r [-v/-p]\n");
f0100a05:	83 ec 0c             	sub    $0xc,%esp
f0100a08:	68 b0 53 10 f0       	push   $0xf01053b0
f0100a0d:	e8 d5 2c 00 00       	call   f01036e7 <cprintf>
		return 0;
f0100a12:	83 c4 10             	add    $0x10,%esp
		cprintf("|\n");
	}
	if (ROUNDDOWN(r, 16) != r)
		cprintf("%08x  \n", r);
	return 0;
}
f0100a15:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a1d:	5b                   	pop    %ebx
f0100a1e:	5e                   	pop    %esi
f0100a1f:	5f                   	pop    %edi
f0100a20:	5d                   	pop    %ebp
f0100a21:	c3                   	ret    
	unsigned long l = strtoul(argv[1], NULL, 0),
f0100a22:	83 ec 04             	sub    $0x4,%esp
f0100a25:	6a 00                	push   $0x0
f0100a27:	6a 00                	push   $0x0
f0100a29:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a2c:	ff 70 04             	pushl  0x4(%eax)
f0100a2f:	e8 8f 42 00 00       	call   f0104cc3 <strtoul>
f0100a34:	89 c6                	mov    %eax,%esi
			  	  r = strtoul(argv[2], NULL, 0);
f0100a36:	83 c4 0c             	add    $0xc,%esp
f0100a39:	6a 00                	push   $0x0
f0100a3b:	6a 00                	push   $0x0
f0100a3d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a40:	ff 70 08             	pushl  0x8(%eax)
f0100a43:	e8 7b 42 00 00       	call   f0104cc3 <strtoul>
f0100a48:	89 c7                	mov    %eax,%edi
	if (argc <= 3)
f0100a4a:	83 c4 10             	add    $0x10,%esp
f0100a4d:	83 fb 03             	cmp    $0x3,%ebx
f0100a50:	7f 18                	jg     f0100a6a <mon_dump+0x79>
		cprintf("Defaulting to virtual address.\n");
f0100a52:	83 ec 0c             	sub    $0xc,%esp
f0100a55:	68 90 56 10 f0       	push   $0xf0105690
f0100a5a:	e8 88 2c 00 00       	call   f01036e7 <cprintf>
f0100a5f:	83 c4 10             	add    $0x10,%esp
	for (ptr = ROUNDDOWN(l, 16); ptr <= r; ptr += 16) {
f0100a62:	83 e6 f0             	and    $0xfffffff0,%esi
f0100a65:	e9 31 01 00 00       	jmp    f0100b9b <mon_dump+0x1aa>
	else if (!strcmp(argv[3], "-p"))
f0100a6a:	83 ec 08             	sub    $0x8,%esp
f0100a6d:	68 c9 53 10 f0       	push   $0xf01053c9
f0100a72:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a75:	ff 70 0c             	pushl  0xc(%eax)
f0100a78:	e8 dc 3f 00 00       	call   f0104a59 <strcmp>
f0100a7d:	83 c4 10             	add    $0x10,%esp
f0100a80:	85 c0                	test   %eax,%eax
f0100a82:	75 4f                	jne    f0100ad3 <mon_dump+0xe2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a84:	a1 e4 6d 1b f0       	mov    0xf01b6de4,%eax
f0100a89:	89 f2                	mov    %esi,%edx
f0100a8b:	c1 ea 0c             	shr    $0xc,%edx
f0100a8e:	39 c2                	cmp    %eax,%edx
f0100a90:	73 17                	jae    f0100aa9 <mon_dump+0xb8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f0100a92:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
	if (PGNUM(pa) >= npages)
f0100a98:	89 fa                	mov    %edi,%edx
f0100a9a:	c1 ea 0c             	shr    $0xc,%edx
f0100a9d:	39 c2                	cmp    %eax,%edx
f0100a9f:	73 1d                	jae    f0100abe <mon_dump+0xcd>
	return (void *)(pa + KERNBASE);
f0100aa1:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
f0100aa7:	eb b9                	jmp    f0100a62 <mon_dump+0x71>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100aa9:	56                   	push   %esi
f0100aaa:	68 b0 56 10 f0       	push   $0xf01056b0
f0100aaf:	68 9d 00 00 00       	push   $0x9d
f0100ab4:	68 cc 53 10 f0       	push   $0xf01053cc
f0100ab9:	e8 8a f6 ff ff       	call   f0100148 <_panic>
f0100abe:	57                   	push   %edi
f0100abf:	68 b0 56 10 f0       	push   $0xf01056b0
f0100ac4:	68 9d 00 00 00       	push   $0x9d
f0100ac9:	68 cc 53 10 f0       	push   $0xf01053cc
f0100ace:	e8 75 f6 ff ff       	call   f0100148 <_panic>
	else if (strcmp(argv[3], "-v")) {
f0100ad3:	83 ec 08             	sub    $0x8,%esp
f0100ad6:	68 ad 53 10 f0       	push   $0xf01053ad
f0100adb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100ade:	ff 70 0c             	pushl  0xc(%eax)
f0100ae1:	e8 73 3f 00 00       	call   f0104a59 <strcmp>
f0100ae6:	83 c4 10             	add    $0x10,%esp
f0100ae9:	85 c0                	test   %eax,%eax
f0100aeb:	0f 84 71 ff ff ff    	je     f0100a62 <mon_dump+0x71>
		cprintf("Unknown flag %s at position 3; aborting.\n", argv[3]);
f0100af1:	83 ec 08             	sub    $0x8,%esp
f0100af4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100af7:	ff 70 0c             	pushl  0xc(%eax)
f0100afa:	68 d4 56 10 f0       	push   $0xf01056d4
f0100aff:	e8 e3 2b 00 00       	call   f01036e7 <cprintf>
		return 0;
f0100b04:	83 c4 10             	add    $0x10,%esp
f0100b07:	e9 09 ff ff ff       	jmp    f0100a15 <mon_dump+0x24>
				cprintf("   ");
f0100b0c:	83 ec 0c             	sub    $0xc,%esp
f0100b0f:	68 e8 53 10 f0       	push   $0xf01053e8
f0100b14:	e8 ce 2b 00 00       	call   f01036e7 <cprintf>
f0100b19:	83 c4 10             	add    $0x10,%esp
f0100b1c:	43                   	inc    %ebx
		for (int i = 0; i < 16; i++) {
f0100b1d:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0100b20:	74 1a                	je     f0100b3c <mon_dump+0x14b>
			if (ptr + i <= r)
f0100b22:	39 df                	cmp    %ebx,%edi
f0100b24:	72 e6                	jb     f0100b0c <mon_dump+0x11b>
				cprintf("%02x ", *(unsigned char*)(ptr + i));
f0100b26:	83 ec 08             	sub    $0x8,%esp
f0100b29:	0f b6 03             	movzbl (%ebx),%eax
f0100b2c:	50                   	push   %eax
f0100b2d:	68 e2 53 10 f0       	push   $0xf01053e2
f0100b32:	e8 b0 2b 00 00       	call   f01036e7 <cprintf>
f0100b37:	83 c4 10             	add    $0x10,%esp
f0100b3a:	eb e0                	jmp    f0100b1c <mon_dump+0x12b>
		cprintf(" |");
f0100b3c:	83 ec 0c             	sub    $0xc,%esp
f0100b3f:	68 ec 53 10 f0       	push   $0xf01053ec
f0100b44:	e8 9e 2b 00 00       	call   f01036e7 <cprintf>
f0100b49:	83 c4 10             	add    $0x10,%esp
f0100b4c:	eb 19                	jmp    f0100b67 <mon_dump+0x176>
				cprintf("%c", (ch >= ' ' && ch <= '~') ? ch : '.');
f0100b4e:	83 ec 08             	sub    $0x8,%esp
f0100b51:	0f be c0             	movsbl %al,%eax
f0100b54:	50                   	push   %eax
f0100b55:	68 ef 53 10 f0       	push   $0xf01053ef
f0100b5a:	e8 88 2b 00 00       	call   f01036e7 <cprintf>
f0100b5f:	83 c4 10             	add    $0x10,%esp
f0100b62:	46                   	inc    %esi
		for (int i = 0; i < 16; i++) {
f0100b63:	39 de                	cmp    %ebx,%esi
f0100b65:	74 24                	je     f0100b8b <mon_dump+0x19a>
			if (ptr + i <= r) {
f0100b67:	39 f7                	cmp    %esi,%edi
f0100b69:	72 0e                	jb     f0100b79 <mon_dump+0x188>
				char ch = *(char*)(ptr + i);
f0100b6b:	8a 06                	mov    (%esi),%al
				cprintf("%c", (ch >= ' ' && ch <= '~') ? ch : '.');
f0100b6d:	8d 50 e0             	lea    -0x20(%eax),%edx
f0100b70:	80 fa 5e             	cmp    $0x5e,%dl
f0100b73:	76 d9                	jbe    f0100b4e <mon_dump+0x15d>
f0100b75:	b0 2e                	mov    $0x2e,%al
f0100b77:	eb d5                	jmp    f0100b4e <mon_dump+0x15d>
				cprintf(" ");
f0100b79:	83 ec 0c             	sub    $0xc,%esp
f0100b7c:	68 2c 54 10 f0       	push   $0xf010542c
f0100b81:	e8 61 2b 00 00       	call   f01036e7 <cprintf>
f0100b86:	83 c4 10             	add    $0x10,%esp
f0100b89:	eb d7                	jmp    f0100b62 <mon_dump+0x171>
		cprintf("|\n");
f0100b8b:	83 ec 0c             	sub    $0xc,%esp
f0100b8e:	68 f2 53 10 f0       	push   $0xf01053f2
f0100b93:	e8 4f 2b 00 00       	call   f01036e7 <cprintf>
	for (ptr = ROUNDDOWN(l, 16); ptr <= r; ptr += 16) {
f0100b98:	83 c4 10             	add    $0x10,%esp
f0100b9b:	39 f7                	cmp    %esi,%edi
f0100b9d:	72 1e                	jb     f0100bbd <mon_dump+0x1cc>
		cprintf("%08x  ", ptr);
f0100b9f:	83 ec 08             	sub    $0x8,%esp
f0100ba2:	56                   	push   %esi
f0100ba3:	68 db 53 10 f0       	push   $0xf01053db
f0100ba8:	e8 3a 2b 00 00       	call   f01036e7 <cprintf>
f0100bad:	8d 46 10             	lea    0x10(%esi),%eax
f0100bb0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100bb3:	83 c4 10             	add    $0x10,%esp
f0100bb6:	89 f3                	mov    %esi,%ebx
f0100bb8:	e9 65 ff ff ff       	jmp    f0100b22 <mon_dump+0x131>
	if (ROUNDDOWN(r, 16) != r)
f0100bbd:	f7 c7 0f 00 00 00    	test   $0xf,%edi
f0100bc3:	0f 84 4c fe ff ff    	je     f0100a15 <mon_dump+0x24>
		cprintf("%08x  \n", r);
f0100bc9:	83 ec 08             	sub    $0x8,%esp
f0100bcc:	57                   	push   %edi
f0100bcd:	68 f5 53 10 f0       	push   $0xf01053f5
f0100bd2:	e8 10 2b 00 00       	call   f01036e7 <cprintf>
f0100bd7:	83 c4 10             	add    $0x10,%esp
f0100bda:	e9 36 fe ff ff       	jmp    f0100a15 <mon_dump+0x24>

f0100bdf <mon_backtrace>:
{
f0100bdf:	55                   	push   %ebp
f0100be0:	89 e5                	mov    %esp,%ebp
f0100be2:	57                   	push   %edi
f0100be3:	56                   	push   %esi
f0100be4:	53                   	push   %ebx
f0100be5:	83 ec 38             	sub    $0x38,%esp
	cprintf("Stack backtrace:\n");
f0100be8:	68 fd 53 10 f0       	push   $0xf01053fd
f0100bed:	e8 f5 2a 00 00       	call   f01036e7 <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100bf2:	89 e8                	mov    %ebp,%eax
	while (ebp != 0) {
f0100bf4:	83 c4 10             	add    $0x10,%esp
f0100bf7:	eb 34                	jmp    f0100c2d <mon_backtrace+0x4e>
			cprintf("%c", info.eip_fn_name[i]);
f0100bf9:	83 ec 08             	sub    $0x8,%esp
f0100bfc:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100bff:	0f be 04 18          	movsbl (%eax,%ebx,1),%eax
f0100c03:	50                   	push   %eax
f0100c04:	68 ef 53 10 f0       	push   $0xf01053ef
f0100c09:	e8 d9 2a 00 00       	call   f01036e7 <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f0100c0e:	43                   	inc    %ebx
f0100c0f:	83 c4 10             	add    $0x10,%esp
f0100c12:	39 5d dc             	cmp    %ebx,-0x24(%ebp)
f0100c15:	7f e2                	jg     f0100bf9 <mon_backtrace+0x1a>
		cprintf("+%d\n", eip - info.eip_fn_addr);
f0100c17:	83 ec 08             	sub    $0x8,%esp
f0100c1a:	2b 75 e0             	sub    -0x20(%ebp),%esi
f0100c1d:	56                   	push   %esi
f0100c1e:	68 20 54 10 f0       	push   $0xf0105420
f0100c23:	e8 bf 2a 00 00       	call   f01036e7 <cprintf>
		ebp = prev_ebp;
f0100c28:	83 c4 10             	add    $0x10,%esp
f0100c2b:	89 f8                	mov    %edi,%eax
	while (ebp != 0) {
f0100c2d:	85 c0                	test   %eax,%eax
f0100c2f:	74 4a                	je     f0100c7b <mon_backtrace+0x9c>
		prev_ebp = *(int*)ebp;
f0100c31:	8b 38                	mov    (%eax),%edi
		eip = *((int*)ebp + 1);
f0100c33:	8b 70 04             	mov    0x4(%eax),%esi
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, 
f0100c36:	ff 70 18             	pushl  0x18(%eax)
f0100c39:	ff 70 14             	pushl  0x14(%eax)
f0100c3c:	ff 70 10             	pushl  0x10(%eax)
f0100c3f:	ff 70 0c             	pushl  0xc(%eax)
f0100c42:	ff 70 08             	pushl  0x8(%eax)
f0100c45:	56                   	push   %esi
f0100c46:	50                   	push   %eax
f0100c47:	68 00 57 10 f0       	push   $0xf0105700
f0100c4c:	e8 96 2a 00 00       	call   f01036e7 <cprintf>
		int code = debuginfo_eip((uintptr_t)eip, &info);
f0100c51:	83 c4 18             	add    $0x18,%esp
f0100c54:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100c57:	50                   	push   %eax
f0100c58:	56                   	push   %esi
f0100c59:	e8 43 34 00 00       	call   f01040a1 <debuginfo_eip>
		cprintf("         %s:%d: ", info.eip_file, info.eip_line);
f0100c5e:	83 c4 0c             	add    $0xc,%esp
f0100c61:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100c64:	ff 75 d0             	pushl  -0x30(%ebp)
f0100c67:	68 0f 54 10 f0       	push   $0xf010540f
f0100c6c:	e8 76 2a 00 00       	call   f01036e7 <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f0100c71:	83 c4 10             	add    $0x10,%esp
f0100c74:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100c79:	eb 97                	jmp    f0100c12 <mon_backtrace+0x33>
}
f0100c7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c7e:	5b                   	pop    %ebx
f0100c7f:	5e                   	pop    %esi
f0100c80:	5f                   	pop    %edi
f0100c81:	5d                   	pop    %ebp
f0100c82:	c3                   	ret    

f0100c83 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100c83:	55                   	push   %ebp
f0100c84:	89 e5                	mov    %esp,%ebp
f0100c86:	57                   	push   %edi
f0100c87:	56                   	push   %esi
f0100c88:	53                   	push   %ebx
f0100c89:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100c8c:	68 38 57 10 f0       	push   $0xf0105738
f0100c91:	e8 51 2a 00 00       	call   f01036e7 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100c96:	c7 04 24 5c 57 10 f0 	movl   $0xf010575c,(%esp)
f0100c9d:	e8 45 2a 00 00       	call   f01036e7 <cprintf>

	if (tf != NULL)
f0100ca2:	83 c4 10             	add    $0x10,%esp
f0100ca5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100ca9:	74 57                	je     f0100d02 <monitor+0x7f>
		print_trapframe(tf);
f0100cab:	83 ec 0c             	sub    $0xc,%esp
f0100cae:	ff 75 08             	pushl  0x8(%ebp)
f0100cb1:	e8 74 2e 00 00       	call   f0103b2a <print_trapframe>
f0100cb6:	83 c4 10             	add    $0x10,%esp
f0100cb9:	eb 47                	jmp    f0100d02 <monitor+0x7f>
		while (*buf && strchr(WHITESPACE, *buf))
f0100cbb:	83 ec 08             	sub    $0x8,%esp
f0100cbe:	0f be c0             	movsbl %al,%eax
f0100cc1:	50                   	push   %eax
f0100cc2:	68 29 54 10 f0       	push   $0xf0105429
f0100cc7:	e8 e1 3d 00 00       	call   f0104aad <strchr>
f0100ccc:	83 c4 10             	add    $0x10,%esp
f0100ccf:	85 c0                	test   %eax,%eax
f0100cd1:	74 0a                	je     f0100cdd <monitor+0x5a>
			*buf++ = 0;
f0100cd3:	c6 03 00             	movb   $0x0,(%ebx)
f0100cd6:	89 f7                	mov    %esi,%edi
f0100cd8:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100cdb:	eb 68                	jmp    f0100d45 <monitor+0xc2>
		if (*buf == 0)
f0100cdd:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100ce0:	74 6f                	je     f0100d51 <monitor+0xce>
		if (argc == MAXARGS-1) {
f0100ce2:	83 fe 0f             	cmp    $0xf,%esi
f0100ce5:	74 09                	je     f0100cf0 <monitor+0x6d>
		argv[argc++] = buf;
f0100ce7:	8d 7e 01             	lea    0x1(%esi),%edi
f0100cea:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100cee:	eb 37                	jmp    f0100d27 <monitor+0xa4>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100cf0:	83 ec 08             	sub    $0x8,%esp
f0100cf3:	6a 10                	push   $0x10
f0100cf5:	68 2e 54 10 f0       	push   $0xf010542e
f0100cfa:	e8 e8 29 00 00       	call   f01036e7 <cprintf>
f0100cff:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100d02:	83 ec 0c             	sub    $0xc,%esp
f0100d05:	68 25 54 10 f0       	push   $0xf0105425
f0100d0a:	e8 93 3b 00 00       	call   f01048a2 <readline>
f0100d0f:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100d11:	83 c4 10             	add    $0x10,%esp
f0100d14:	85 c0                	test   %eax,%eax
f0100d16:	74 ea                	je     f0100d02 <monitor+0x7f>
	argv[argc] = 0;
f0100d18:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100d1f:	be 00 00 00 00       	mov    $0x0,%esi
f0100d24:	eb 21                	jmp    f0100d47 <monitor+0xc4>
			buf++;
f0100d26:	43                   	inc    %ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100d27:	8a 03                	mov    (%ebx),%al
f0100d29:	84 c0                	test   %al,%al
f0100d2b:	74 18                	je     f0100d45 <monitor+0xc2>
f0100d2d:	83 ec 08             	sub    $0x8,%esp
f0100d30:	0f be c0             	movsbl %al,%eax
f0100d33:	50                   	push   %eax
f0100d34:	68 29 54 10 f0       	push   $0xf0105429
f0100d39:	e8 6f 3d 00 00       	call   f0104aad <strchr>
f0100d3e:	83 c4 10             	add    $0x10,%esp
f0100d41:	85 c0                	test   %eax,%eax
f0100d43:	74 e1                	je     f0100d26 <monitor+0xa3>
			*buf++ = 0;
f0100d45:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100d47:	8a 03                	mov    (%ebx),%al
f0100d49:	84 c0                	test   %al,%al
f0100d4b:	0f 85 6a ff ff ff    	jne    f0100cbb <monitor+0x38>
	argv[argc] = 0;
f0100d51:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100d58:	00 
	if (argc == 0)
f0100d59:	85 f6                	test   %esi,%esi
f0100d5b:	74 a5                	je     f0100d02 <monitor+0x7f>
f0100d5d:	bf 40 58 10 f0       	mov    $0xf0105840,%edi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100d62:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f0100d67:	83 ec 08             	sub    $0x8,%esp
f0100d6a:	ff 37                	pushl  (%edi)
f0100d6c:	ff 75 a8             	pushl  -0x58(%ebp)
f0100d6f:	e8 e5 3c 00 00       	call   f0104a59 <strcmp>
f0100d74:	83 c4 10             	add    $0x10,%esp
f0100d77:	85 c0                	test   %eax,%eax
f0100d79:	74 21                	je     f0100d9c <monitor+0x119>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100d7b:	43                   	inc    %ebx
f0100d7c:	83 c7 0c             	add    $0xc,%edi
f0100d7f:	83 fb 05             	cmp    $0x5,%ebx
f0100d82:	75 e3                	jne    f0100d67 <monitor+0xe4>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100d84:	83 ec 08             	sub    $0x8,%esp
f0100d87:	ff 75 a8             	pushl  -0x58(%ebp)
f0100d8a:	68 4b 54 10 f0       	push   $0xf010544b
f0100d8f:	e8 53 29 00 00       	call   f01036e7 <cprintf>
f0100d94:	83 c4 10             	add    $0x10,%esp
f0100d97:	e9 66 ff ff ff       	jmp    f0100d02 <monitor+0x7f>
			return commands[i].func(argc, argv, tf);
f0100d9c:	83 ec 04             	sub    $0x4,%esp
f0100d9f:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100da2:	01 c3                	add    %eax,%ebx
f0100da4:	ff 75 08             	pushl  0x8(%ebp)
f0100da7:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100daa:	50                   	push   %eax
f0100dab:	56                   	push   %esi
f0100dac:	ff 14 9d 48 58 10 f0 	call   *-0xfefa7b8(,%ebx,4)
			if (runcmd(buf, tf) < 0)
f0100db3:	83 c4 10             	add    $0x10,%esp
f0100db6:	85 c0                	test   %eax,%eax
f0100db8:	0f 89 44 ff ff ff    	jns    f0100d02 <monitor+0x7f>
				break;
	}
}
f0100dbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100dc1:	5b                   	pop    %ebx
f0100dc2:	5e                   	pop    %esi
f0100dc3:	5f                   	pop    %edi
f0100dc4:	5d                   	pop    %ebp
f0100dc5:	c3                   	ret    

f0100dc6 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100dc6:	55                   	push   %ebp
f0100dc7:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100dc9:	83 3d 18 61 1b f0 00 	cmpl   $0x0,0xf01b6118
f0100dd0:	74 1f                	je     f0100df1 <boot_alloc+0x2b>
	}

	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	if (!n)
f0100dd2:	85 c0                	test   %eax,%eax
f0100dd4:	74 2e                	je     f0100e04 <boot_alloc+0x3e>
		return (void*)nextfree;
	else {
		result = nextfree;
f0100dd6:	8b 15 18 61 1b f0    	mov    0xf01b6118,%edx
		nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100ddc:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100de3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100de8:	a3 18 61 1b f0       	mov    %eax,0xf01b6118
		return (void*)result;
	}
}
f0100ded:	89 d0                	mov    %edx,%eax
f0100def:	5d                   	pop    %ebp
f0100df0:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100df1:	ba ef 7d 1b f0       	mov    $0xf01b7def,%edx
f0100df6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100dfc:	89 15 18 61 1b f0    	mov    %edx,0xf01b6118
f0100e02:	eb ce                	jmp    f0100dd2 <boot_alloc+0xc>
		return (void*)nextfree;
f0100e04:	8b 15 18 61 1b f0    	mov    0xf01b6118,%edx
f0100e0a:	eb e1                	jmp    f0100ded <boot_alloc+0x27>

f0100e0c <nvram_read>:
{
f0100e0c:	55                   	push   %ebp
f0100e0d:	89 e5                	mov    %esp,%ebp
f0100e0f:	56                   	push   %esi
f0100e10:	53                   	push   %ebx
f0100e11:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100e13:	83 ec 0c             	sub    $0xc,%esp
f0100e16:	50                   	push   %eax
f0100e17:	e8 64 28 00 00       	call   f0103680 <mc146818_read>
f0100e1c:	89 c3                	mov    %eax,%ebx
f0100e1e:	46                   	inc    %esi
f0100e1f:	89 34 24             	mov    %esi,(%esp)
f0100e22:	e8 59 28 00 00       	call   f0103680 <mc146818_read>
f0100e27:	c1 e0 08             	shl    $0x8,%eax
f0100e2a:	09 d8                	or     %ebx,%eax
}
f0100e2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100e2f:	5b                   	pop    %ebx
f0100e30:	5e                   	pop    %esi
f0100e31:	5d                   	pop    %ebp
f0100e32:	c3                   	ret    

f0100e33 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100e33:	89 d1                	mov    %edx,%ecx
f0100e35:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100e38:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100e3b:	a8 01                	test   $0x1,%al
f0100e3d:	74 47                	je     f0100e86 <check_va2pa+0x53>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100e3f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100e44:	89 c1                	mov    %eax,%ecx
f0100e46:	c1 e9 0c             	shr    $0xc,%ecx
f0100e49:	3b 0d e4 6d 1b f0    	cmp    0xf01b6de4,%ecx
f0100e4f:	73 1a                	jae    f0100e6b <check_va2pa+0x38>
	if (!(p[PTX(va)] & PTE_P))
f0100e51:	c1 ea 0c             	shr    $0xc,%edx
f0100e54:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100e5a:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100e61:	a8 01                	test   $0x1,%al
f0100e63:	74 27                	je     f0100e8c <check_va2pa+0x59>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100e65:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100e6a:	c3                   	ret    
{
f0100e6b:	55                   	push   %ebp
f0100e6c:	89 e5                	mov    %esp,%ebp
f0100e6e:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e71:	50                   	push   %eax
f0100e72:	68 b0 56 10 f0       	push   $0xf01056b0
f0100e77:	68 0f 03 00 00       	push   $0x30f
f0100e7c:	68 39 60 10 f0       	push   $0xf0106039
f0100e81:	e8 c2 f2 ff ff       	call   f0100148 <_panic>
		return ~0;
f0100e86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e8b:	c3                   	ret    
		return ~0;
f0100e8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100e91:	c3                   	ret    

f0100e92 <check_page_free_list>:
{
f0100e92:	55                   	push   %ebp
f0100e93:	89 e5                	mov    %esp,%ebp
f0100e95:	57                   	push   %edi
f0100e96:	56                   	push   %esi
f0100e97:	53                   	push   %ebx
f0100e98:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e9b:	84 c0                	test   %al,%al
f0100e9d:	0f 85 50 02 00 00    	jne    f01010f3 <check_page_free_list+0x261>
	if (!page_free_list)
f0100ea3:	83 3d 20 61 1b f0 00 	cmpl   $0x0,0xf01b6120
f0100eaa:	74 0a                	je     f0100eb6 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100eac:	be 00 04 00 00       	mov    $0x400,%esi
f0100eb1:	e9 98 02 00 00       	jmp    f010114e <check_page_free_list+0x2bc>
		panic("'page_free_list' is a null pointer!");
f0100eb6:	83 ec 04             	sub    $0x4,%esp
f0100eb9:	68 7c 58 10 f0       	push   $0xf010587c
f0100ebe:	68 4a 02 00 00       	push   $0x24a
f0100ec3:	68 39 60 10 f0       	push   $0xf0106039
f0100ec8:	e8 7b f2 ff ff       	call   f0100148 <_panic>
f0100ecd:	50                   	push   %eax
f0100ece:	68 b0 56 10 f0       	push   $0xf01056b0
f0100ed3:	6a 56                	push   $0x56
f0100ed5:	68 45 60 10 f0       	push   $0xf0106045
f0100eda:	e8 69 f2 ff ff       	call   f0100148 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100edf:	8b 1b                	mov    (%ebx),%ebx
f0100ee1:	85 db                	test   %ebx,%ebx
f0100ee3:	74 41                	je     f0100f26 <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ee5:	89 d8                	mov    %ebx,%eax
f0100ee7:	2b 05 ec 6d 1b f0    	sub    0xf01b6dec,%eax
f0100eed:	c1 f8 03             	sar    $0x3,%eax
f0100ef0:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100ef3:	89 c2                	mov    %eax,%edx
f0100ef5:	c1 ea 16             	shr    $0x16,%edx
f0100ef8:	39 f2                	cmp    %esi,%edx
f0100efa:	73 e3                	jae    f0100edf <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100efc:	89 c2                	mov    %eax,%edx
f0100efe:	c1 ea 0c             	shr    $0xc,%edx
f0100f01:	3b 15 e4 6d 1b f0    	cmp    0xf01b6de4,%edx
f0100f07:	73 c4                	jae    f0100ecd <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100f09:	83 ec 04             	sub    $0x4,%esp
f0100f0c:	68 80 00 00 00       	push   $0x80
f0100f11:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100f16:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f1b:	50                   	push   %eax
f0100f1c:	e8 c1 3b 00 00       	call   f0104ae2 <memset>
f0100f21:	83 c4 10             	add    $0x10,%esp
f0100f24:	eb b9                	jmp    f0100edf <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100f26:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f2b:	e8 96 fe ff ff       	call   f0100dc6 <boot_alloc>
f0100f30:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f33:	8b 15 20 61 1b f0    	mov    0xf01b6120,%edx
		assert(pp >= pages);
f0100f39:	8b 0d ec 6d 1b f0    	mov    0xf01b6dec,%ecx
		assert(pp < pages + npages);
f0100f3f:	a1 e4 6d 1b f0       	mov    0xf01b6de4,%eax
f0100f44:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100f47:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100f4a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0100f4d:	be 00 00 00 00       	mov    $0x0,%esi
f0100f52:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f55:	e9 c8 00 00 00       	jmp    f0101022 <check_page_free_list+0x190>
		assert(pp >= pages);
f0100f5a:	68 53 60 10 f0       	push   $0xf0106053
f0100f5f:	68 5f 60 10 f0       	push   $0xf010605f
f0100f64:	68 64 02 00 00       	push   $0x264
f0100f69:	68 39 60 10 f0       	push   $0xf0106039
f0100f6e:	e8 d5 f1 ff ff       	call   f0100148 <_panic>
		assert(pp < pages + npages);
f0100f73:	68 74 60 10 f0       	push   $0xf0106074
f0100f78:	68 5f 60 10 f0       	push   $0xf010605f
f0100f7d:	68 65 02 00 00       	push   $0x265
f0100f82:	68 39 60 10 f0       	push   $0xf0106039
f0100f87:	e8 bc f1 ff ff       	call   f0100148 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100f8c:	68 a0 58 10 f0       	push   $0xf01058a0
f0100f91:	68 5f 60 10 f0       	push   $0xf010605f
f0100f96:	68 66 02 00 00       	push   $0x266
f0100f9b:	68 39 60 10 f0       	push   $0xf0106039
f0100fa0:	e8 a3 f1 ff ff       	call   f0100148 <_panic>
		assert(page2pa(pp) != 0);
f0100fa5:	68 88 60 10 f0       	push   $0xf0106088
f0100faa:	68 5f 60 10 f0       	push   $0xf010605f
f0100faf:	68 69 02 00 00       	push   $0x269
f0100fb4:	68 39 60 10 f0       	push   $0xf0106039
f0100fb9:	e8 8a f1 ff ff       	call   f0100148 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100fbe:	68 99 60 10 f0       	push   $0xf0106099
f0100fc3:	68 5f 60 10 f0       	push   $0xf010605f
f0100fc8:	68 6a 02 00 00       	push   $0x26a
f0100fcd:	68 39 60 10 f0       	push   $0xf0106039
f0100fd2:	e8 71 f1 ff ff       	call   f0100148 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100fd7:	68 d4 58 10 f0       	push   $0xf01058d4
f0100fdc:	68 5f 60 10 f0       	push   $0xf010605f
f0100fe1:	68 6b 02 00 00       	push   $0x26b
f0100fe6:	68 39 60 10 f0       	push   $0xf0106039
f0100feb:	e8 58 f1 ff ff       	call   f0100148 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100ff0:	68 b2 60 10 f0       	push   $0xf01060b2
f0100ff5:	68 5f 60 10 f0       	push   $0xf010605f
f0100ffa:	68 6c 02 00 00       	push   $0x26c
f0100fff:	68 39 60 10 f0       	push   $0xf0106039
f0101004:	e8 3f f1 ff ff       	call   f0100148 <_panic>
	if (PGNUM(pa) >= npages)
f0101009:	89 c3                	mov    %eax,%ebx
f010100b:	c1 eb 0c             	shr    $0xc,%ebx
f010100e:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f0101011:	76 63                	jbe    f0101076 <check_page_free_list+0x1e4>
	return (void *)(pa + KERNBASE);
f0101013:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101018:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f010101b:	77 6b                	ja     f0101088 <check_page_free_list+0x1f6>
			++nfree_extmem;
f010101d:	ff 45 d0             	incl   -0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101020:	8b 12                	mov    (%edx),%edx
f0101022:	85 d2                	test   %edx,%edx
f0101024:	74 7b                	je     f01010a1 <check_page_free_list+0x20f>
		assert(pp >= pages);
f0101026:	39 d1                	cmp    %edx,%ecx
f0101028:	0f 87 2c ff ff ff    	ja     f0100f5a <check_page_free_list+0xc8>
		assert(pp < pages + npages);
f010102e:	39 d7                	cmp    %edx,%edi
f0101030:	0f 86 3d ff ff ff    	jbe    f0100f73 <check_page_free_list+0xe1>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101036:	89 d0                	mov    %edx,%eax
f0101038:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f010103b:	a8 07                	test   $0x7,%al
f010103d:	0f 85 49 ff ff ff    	jne    f0100f8c <check_page_free_list+0xfa>
	return (pp - pages) << PGSHIFT;
f0101043:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0101046:	c1 e0 0c             	shl    $0xc,%eax
f0101049:	0f 84 56 ff ff ff    	je     f0100fa5 <check_page_free_list+0x113>
		assert(page2pa(pp) != IOPHYSMEM);
f010104f:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101054:	0f 84 64 ff ff ff    	je     f0100fbe <check_page_free_list+0x12c>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010105a:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f010105f:	0f 84 72 ff ff ff    	je     f0100fd7 <check_page_free_list+0x145>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101065:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010106a:	74 84                	je     f0100ff0 <check_page_free_list+0x15e>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010106c:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101071:	77 96                	ja     f0101009 <check_page_free_list+0x177>
			++nfree_basemem;
f0101073:	46                   	inc    %esi
f0101074:	eb aa                	jmp    f0101020 <check_page_free_list+0x18e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101076:	50                   	push   %eax
f0101077:	68 b0 56 10 f0       	push   $0xf01056b0
f010107c:	6a 56                	push   $0x56
f010107e:	68 45 60 10 f0       	push   $0xf0106045
f0101083:	e8 c0 f0 ff ff       	call   f0100148 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101088:	68 f8 58 10 f0       	push   $0xf01058f8
f010108d:	68 5f 60 10 f0       	push   $0xf010605f
f0101092:	68 6d 02 00 00       	push   $0x26d
f0101097:	68 39 60 10 f0       	push   $0xf0106039
f010109c:	e8 a7 f0 ff ff       	call   f0100148 <_panic>
f01010a1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
	assert(nfree_basemem > 0);
f01010a4:	85 f6                	test   %esi,%esi
f01010a6:	7e 19                	jle    f01010c1 <check_page_free_list+0x22f>
	assert(nfree_extmem > 0);
f01010a8:	85 db                	test   %ebx,%ebx
f01010aa:	7e 2e                	jle    f01010da <check_page_free_list+0x248>
	cprintf("check_page_free_list() succeeded!\n");
f01010ac:	83 ec 0c             	sub    $0xc,%esp
f01010af:	68 40 59 10 f0       	push   $0xf0105940
f01010b4:	e8 2e 26 00 00       	call   f01036e7 <cprintf>
}
f01010b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010bc:	5b                   	pop    %ebx
f01010bd:	5e                   	pop    %esi
f01010be:	5f                   	pop    %edi
f01010bf:	5d                   	pop    %ebp
f01010c0:	c3                   	ret    
	assert(nfree_basemem > 0);
f01010c1:	68 cc 60 10 f0       	push   $0xf01060cc
f01010c6:	68 5f 60 10 f0       	push   $0xf010605f
f01010cb:	68 75 02 00 00       	push   $0x275
f01010d0:	68 39 60 10 f0       	push   $0xf0106039
f01010d5:	e8 6e f0 ff ff       	call   f0100148 <_panic>
	assert(nfree_extmem > 0);
f01010da:	68 de 60 10 f0       	push   $0xf01060de
f01010df:	68 5f 60 10 f0       	push   $0xf010605f
f01010e4:	68 76 02 00 00       	push   $0x276
f01010e9:	68 39 60 10 f0       	push   $0xf0106039
f01010ee:	e8 55 f0 ff ff       	call   f0100148 <_panic>
	if (!page_free_list)
f01010f3:	a1 20 61 1b f0       	mov    0xf01b6120,%eax
f01010f8:	85 c0                	test   %eax,%eax
f01010fa:	0f 84 b6 fd ff ff    	je     f0100eb6 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0101100:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0101103:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101106:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0101109:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f010110c:	89 c2                	mov    %eax,%edx
f010110e:	2b 15 ec 6d 1b f0    	sub    0xf01b6dec,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit; 
f0101114:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f010111a:	0f 95 c2             	setne  %dl
f010111d:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0101120:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0101124:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0101126:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f010112a:	8b 00                	mov    (%eax),%eax
f010112c:	85 c0                	test   %eax,%eax
f010112e:	75 dc                	jne    f010110c <check_page_free_list+0x27a>
		*tp[1] = 0;
f0101130:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101133:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101139:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010113c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010113f:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101141:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101144:	a3 20 61 1b f0       	mov    %eax,0xf01b6120
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101149:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010114e:	8b 1d 20 61 1b f0    	mov    0xf01b6120,%ebx
f0101154:	e9 88 fd ff ff       	jmp    f0100ee1 <check_page_free_list+0x4f>

f0101159 <page_init>:
{
f0101159:	55                   	push   %ebp
f010115a:	89 e5                	mov    %esp,%ebp
f010115c:	57                   	push   %edi
f010115d:	56                   	push   %esi
f010115e:	53                   	push   %ebx
f010115f:	83 ec 1c             	sub    $0x1c,%esp
	physaddr_t free = (physaddr_t) PADDR(boot_alloc(0));
f0101162:	b8 00 00 00 00       	mov    $0x0,%eax
f0101167:	e8 5a fc ff ff       	call   f0100dc6 <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f010116c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101171:	76 22                	jbe    f0101195 <page_init+0x3c>
	return (physaddr_t)kva - KERNBASE;
f0101173:	05 00 00 00 10       	add    $0x10000000,%eax
f0101178:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if (i >= npages_basemem && i * PGSIZE < free)
f010117b:	8b 35 24 61 1b f0    	mov    0xf01b6124,%esi
f0101181:	8b 1d 20 61 1b f0    	mov    0xf01b6120,%ebx
	for (i = 1; i < npages; i++) {
f0101187:	b2 00                	mov    $0x0,%dl
f0101189:	b8 01 00 00 00       	mov    $0x1,%eax
		page_free_list = &pages[i];
f010118e:	bf 01 00 00 00       	mov    $0x1,%edi
	for (i = 1; i < npages; i++) {
f0101193:	eb 37                	jmp    f01011cc <page_init+0x73>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101195:	50                   	push   %eax
f0101196:	68 64 59 10 f0       	push   $0xf0105964
f010119b:	68 18 01 00 00       	push   $0x118
f01011a0:	68 39 60 10 f0       	push   $0xf0106039
f01011a5:	e8 9e ef ff ff       	call   f0100148 <_panic>
		pages[i].pp_ref = 0;
f01011aa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01011b1:	89 d1                	mov    %edx,%ecx
f01011b3:	03 0d ec 6d 1b f0    	add    0xf01b6dec,%ecx
f01011b9:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f01011bf:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f01011c1:	89 d3                	mov    %edx,%ebx
f01011c3:	03 1d ec 6d 1b f0    	add    0xf01b6dec,%ebx
f01011c9:	89 fa                	mov    %edi,%edx
	for (i = 1; i < npages; i++) {
f01011cb:	40                   	inc    %eax
f01011cc:	39 05 e4 6d 1b f0    	cmp    %eax,0xf01b6de4
f01011d2:	76 10                	jbe    f01011e4 <page_init+0x8b>
		if (i >= npages_basemem && i * PGSIZE < free)
f01011d4:	39 c6                	cmp    %eax,%esi
f01011d6:	77 d2                	ja     f01011aa <page_init+0x51>
f01011d8:	89 c1                	mov    %eax,%ecx
f01011da:	c1 e1 0c             	shl    $0xc,%ecx
f01011dd:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
f01011e0:	76 c8                	jbe    f01011aa <page_init+0x51>
f01011e2:	eb e7                	jmp    f01011cb <page_init+0x72>
f01011e4:	84 d2                	test   %dl,%dl
f01011e6:	75 08                	jne    f01011f0 <page_init+0x97>
}
f01011e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011eb:	5b                   	pop    %ebx
f01011ec:	5e                   	pop    %esi
f01011ed:	5f                   	pop    %edi
f01011ee:	5d                   	pop    %ebp
f01011ef:	c3                   	ret    
f01011f0:	89 1d 20 61 1b f0    	mov    %ebx,0xf01b6120
f01011f6:	eb f0                	jmp    f01011e8 <page_init+0x8f>

f01011f8 <page_alloc>:
{
f01011f8:	55                   	push   %ebp
f01011f9:	89 e5                	mov    %esp,%ebp
f01011fb:	53                   	push   %ebx
f01011fc:	83 ec 04             	sub    $0x4,%esp
	struct PageInfo* next = page_free_list;
f01011ff:	8b 1d 20 61 1b f0    	mov    0xf01b6120,%ebx
	if (!next)
f0101205:	85 db                	test   %ebx,%ebx
f0101207:	74 13                	je     f010121c <page_alloc+0x24>
	page_free_list = page_free_list->pp_link;
f0101209:	8b 03                	mov    (%ebx),%eax
f010120b:	a3 20 61 1b f0       	mov    %eax,0xf01b6120
	next->pp_link = NULL;
f0101210:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f0101216:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010121a:	75 07                	jne    f0101223 <page_alloc+0x2b>
}
f010121c:	89 d8                	mov    %ebx,%eax
f010121e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101221:	c9                   	leave  
f0101222:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0101223:	89 d8                	mov    %ebx,%eax
f0101225:	2b 05 ec 6d 1b f0    	sub    0xf01b6dec,%eax
f010122b:	c1 f8 03             	sar    $0x3,%eax
f010122e:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101231:	89 c2                	mov    %eax,%edx
f0101233:	c1 ea 0c             	shr    $0xc,%edx
f0101236:	3b 15 e4 6d 1b f0    	cmp    0xf01b6de4,%edx
f010123c:	73 1a                	jae    f0101258 <page_alloc+0x60>
		memset(content, 0, PGSIZE);
f010123e:	83 ec 04             	sub    $0x4,%esp
f0101241:	68 00 10 00 00       	push   $0x1000
f0101246:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0101248:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010124d:	50                   	push   %eax
f010124e:	e8 8f 38 00 00       	call   f0104ae2 <memset>
f0101253:	83 c4 10             	add    $0x10,%esp
f0101256:	eb c4                	jmp    f010121c <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101258:	50                   	push   %eax
f0101259:	68 b0 56 10 f0       	push   $0xf01056b0
f010125e:	6a 56                	push   $0x56
f0101260:	68 45 60 10 f0       	push   $0xf0106045
f0101265:	e8 de ee ff ff       	call   f0100148 <_panic>

f010126a <page_free>:
{
f010126a:	55                   	push   %ebp
f010126b:	89 e5                	mov    %esp,%ebp
f010126d:	83 ec 08             	sub    $0x8,%esp
f0101270:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref)
f0101273:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101278:	75 14                	jne    f010128e <page_free+0x24>
	if (pp->pp_link)
f010127a:	83 38 00             	cmpl   $0x0,(%eax)
f010127d:	75 26                	jne    f01012a5 <page_free+0x3b>
	pp->pp_link = page_free_list;
f010127f:	8b 15 20 61 1b f0    	mov    0xf01b6120,%edx
f0101285:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101287:	a3 20 61 1b f0       	mov    %eax,0xf01b6120
}
f010128c:	c9                   	leave  
f010128d:	c3                   	ret    
		panic("Ref count is non-zero");
f010128e:	83 ec 04             	sub    $0x4,%esp
f0101291:	68 ef 60 10 f0       	push   $0xf01060ef
f0101296:	68 45 01 00 00       	push   $0x145
f010129b:	68 39 60 10 f0       	push   $0xf0106039
f01012a0:	e8 a3 ee ff ff       	call   f0100148 <_panic>
		panic("Page is double-freed");
f01012a5:	83 ec 04             	sub    $0x4,%esp
f01012a8:	68 05 61 10 f0       	push   $0xf0106105
f01012ad:	68 47 01 00 00       	push   $0x147
f01012b2:	68 39 60 10 f0       	push   $0xf0106039
f01012b7:	e8 8c ee ff ff       	call   f0100148 <_panic>

f01012bc <page_decref>:
{
f01012bc:	55                   	push   %ebp
f01012bd:	89 e5                	mov    %esp,%ebp
f01012bf:	83 ec 08             	sub    $0x8,%esp
f01012c2:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01012c5:	8b 42 04             	mov    0x4(%edx),%eax
f01012c8:	48                   	dec    %eax
f01012c9:	66 89 42 04          	mov    %ax,0x4(%edx)
f01012cd:	66 85 c0             	test   %ax,%ax
f01012d0:	74 02                	je     f01012d4 <page_decref+0x18>
}
f01012d2:	c9                   	leave  
f01012d3:	c3                   	ret    
		page_free(pp);
f01012d4:	83 ec 0c             	sub    $0xc,%esp
f01012d7:	52                   	push   %edx
f01012d8:	e8 8d ff ff ff       	call   f010126a <page_free>
f01012dd:	83 c4 10             	add    $0x10,%esp
}
f01012e0:	eb f0                	jmp    f01012d2 <page_decref+0x16>

f01012e2 <pgdir_walk>:
{
f01012e2:	55                   	push   %ebp
f01012e3:	89 e5                	mov    %esp,%ebp
f01012e5:	57                   	push   %edi
f01012e6:	56                   	push   %esi
f01012e7:	53                   	push   %ebx
f01012e8:	83 ec 1c             	sub    $0x1c,%esp
	pde_t pd_entry = (pde_t)pgdir[PDX(va)];
f01012eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01012ee:	c1 eb 16             	shr    $0x16,%ebx
f01012f1:	c1 e3 02             	shl    $0x2,%ebx
f01012f4:	03 5d 08             	add    0x8(%ebp),%ebx
f01012f7:	8b 03                	mov    (%ebx),%eax
	if (pd_entry) {
f01012f9:	85 c0                	test   %eax,%eax
f01012fb:	74 42                	je     f010133f <pgdir_walk+0x5d>
		pte_t* pt_base = KADDR(PTE_ADDR(pd_entry));
f01012fd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101302:	89 c2                	mov    %eax,%edx
f0101304:	c1 ea 0c             	shr    $0xc,%edx
f0101307:	39 15 e4 6d 1b f0    	cmp    %edx,0xf01b6de4
f010130d:	76 1b                	jbe    f010132a <pgdir_walk+0x48>
		return pt_base + PTX(va);
f010130f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101312:	c1 ea 0a             	shr    $0xa,%edx
f0101315:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f010131b:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
}
f0101322:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101325:	5b                   	pop    %ebx
f0101326:	5e                   	pop    %esi
f0101327:	5f                   	pop    %edi
f0101328:	5d                   	pop    %ebp
f0101329:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010132a:	50                   	push   %eax
f010132b:	68 b0 56 10 f0       	push   $0xf01056b0
f0101330:	68 72 01 00 00       	push   $0x172
f0101335:	68 39 60 10 f0       	push   $0xf0106039
f010133a:	e8 09 ee ff ff       	call   f0100148 <_panic>
	else if (create) {
f010133f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101343:	0f 84 9c 00 00 00    	je     f01013e5 <pgdir_walk+0x103>
		struct PageInfo *new_pt = page_alloc(0);
f0101349:	83 ec 0c             	sub    $0xc,%esp
f010134c:	6a 00                	push   $0x0
f010134e:	e8 a5 fe ff ff       	call   f01011f8 <page_alloc>
f0101353:	89 c7                	mov    %eax,%edi
		if (new_pt) {
f0101355:	83 c4 10             	add    $0x10,%esp
f0101358:	85 c0                	test   %eax,%eax
f010135a:	0f 84 8f 00 00 00    	je     f01013ef <pgdir_walk+0x10d>
	return (pp - pages) << PGSHIFT;
f0101360:	2b 05 ec 6d 1b f0    	sub    0xf01b6dec,%eax
f0101366:	c1 f8 03             	sar    $0x3,%eax
f0101369:	c1 e0 0c             	shl    $0xc,%eax
f010136c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (PGNUM(pa) >= npages)
f010136f:	c1 e8 0c             	shr    $0xc,%eax
f0101372:	3b 05 e4 6d 1b f0    	cmp    0xf01b6de4,%eax
f0101378:	73 42                	jae    f01013bc <pgdir_walk+0xda>
	return (void *)(pa + KERNBASE);
f010137a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010137d:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
			memset(content, 0, PGSIZE);
f0101383:	83 ec 04             	sub    $0x4,%esp
f0101386:	68 00 10 00 00       	push   $0x1000
f010138b:	6a 00                	push   $0x0
f010138d:	56                   	push   %esi
f010138e:	e8 4f 37 00 00       	call   f0104ae2 <memset>
			new_pt->pp_ref++;
f0101393:	66 ff 47 04          	incw   0x4(%edi)
	if ((uint32_t)kva < KERNBASE)
f0101397:	83 c4 10             	add    $0x10,%esp
f010139a:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01013a0:	76 2e                	jbe    f01013d0 <pgdir_walk+0xee>
			pgdir[PDX(va)] = PADDR(content) | 0xF; // Set all permissions.
f01013a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01013a5:	83 c8 0f             	or     $0xf,%eax
f01013a8:	89 03                	mov    %eax,(%ebx)
			return (pte_t*) content + PTX(va);
f01013aa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01013ad:	c1 e8 0a             	shr    $0xa,%eax
f01013b0:	25 fc 0f 00 00       	and    $0xffc,%eax
f01013b5:	01 f0                	add    %esi,%eax
f01013b7:	e9 66 ff ff ff       	jmp    f0101322 <pgdir_walk+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013bc:	ff 75 e4             	pushl  -0x1c(%ebp)
f01013bf:	68 b0 56 10 f0       	push   $0xf01056b0
f01013c4:	6a 56                	push   $0x56
f01013c6:	68 45 60 10 f0       	push   $0xf0106045
f01013cb:	e8 78 ed ff ff       	call   f0100148 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013d0:	56                   	push   %esi
f01013d1:	68 64 59 10 f0       	push   $0xf0105964
f01013d6:	68 7b 01 00 00       	push   $0x17b
f01013db:	68 39 60 10 f0       	push   $0xf0106039
f01013e0:	e8 63 ed ff ff       	call   f0100148 <_panic>
	return NULL;
f01013e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01013ea:	e9 33 ff ff ff       	jmp    f0101322 <pgdir_walk+0x40>
f01013ef:	b8 00 00 00 00       	mov    $0x0,%eax
f01013f4:	e9 29 ff ff ff       	jmp    f0101322 <pgdir_walk+0x40>

f01013f9 <boot_map_region>:
{
f01013f9:	55                   	push   %ebp
f01013fa:	89 e5                	mov    %esp,%ebp
f01013fc:	57                   	push   %edi
f01013fd:	56                   	push   %esi
f01013fe:	53                   	push   %ebx
f01013ff:	83 ec 1c             	sub    $0x1c,%esp
f0101402:	89 c7                	mov    %eax,%edi
f0101404:	89 d6                	mov    %edx,%esi
f0101406:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f0101409:	bb 00 00 00 00       	mov    $0x0,%ebx
		*page_entry = (pa + size0) | perm | PTE_P;
f010140e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101411:	83 c8 01             	or     $0x1,%eax
f0101414:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f0101417:	eb 22                	jmp    f010143b <boot_map_region+0x42>
		pte_t *page_entry = pgdir_walk(pgdir, (void*) va + size0, 1);
f0101419:	83 ec 04             	sub    $0x4,%esp
f010141c:	6a 01                	push   $0x1
f010141e:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f0101421:	50                   	push   %eax
f0101422:	57                   	push   %edi
f0101423:	e8 ba fe ff ff       	call   f01012e2 <pgdir_walk>
		*page_entry = (pa + size0) | perm | PTE_P;
f0101428:	89 da                	mov    %ebx,%edx
f010142a:	03 55 08             	add    0x8(%ebp),%edx
f010142d:	0b 55 e0             	or     -0x20(%ebp),%edx
f0101430:	89 10                	mov    %edx,(%eax)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f0101432:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101438:	83 c4 10             	add    $0x10,%esp
f010143b:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010143e:	72 d9                	jb     f0101419 <boot_map_region+0x20>
}
f0101440:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101443:	5b                   	pop    %ebx
f0101444:	5e                   	pop    %esi
f0101445:	5f                   	pop    %edi
f0101446:	5d                   	pop    %ebp
f0101447:	c3                   	ret    

f0101448 <page_lookup>:
{
f0101448:	55                   	push   %ebp
f0101449:	89 e5                	mov    %esp,%ebp
f010144b:	53                   	push   %ebx
f010144c:	83 ec 08             	sub    $0x8,%esp
f010144f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *page_entry = pgdir_walk(pgdir, (void*) va, 0);
f0101452:	6a 00                	push   $0x0
f0101454:	ff 75 0c             	pushl  0xc(%ebp)
f0101457:	ff 75 08             	pushl  0x8(%ebp)
f010145a:	e8 83 fe ff ff       	call   f01012e2 <pgdir_walk>
	if (!page_entry || !*page_entry)
f010145f:	83 c4 10             	add    $0x10,%esp
f0101462:	85 c0                	test   %eax,%eax
f0101464:	74 3a                	je     f01014a0 <page_lookup+0x58>
f0101466:	83 38 00             	cmpl   $0x0,(%eax)
f0101469:	74 3c                	je     f01014a7 <page_lookup+0x5f>
	if (pte_store)
f010146b:	85 db                	test   %ebx,%ebx
f010146d:	74 02                	je     f0101471 <page_lookup+0x29>
		*pte_store = page_entry;
f010146f:	89 03                	mov    %eax,(%ebx)
f0101471:	8b 00                	mov    (%eax),%eax
f0101473:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101476:	39 05 e4 6d 1b f0    	cmp    %eax,0xf01b6de4
f010147c:	76 0e                	jbe    f010148c <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f010147e:	8b 15 ec 6d 1b f0    	mov    0xf01b6dec,%edx
f0101484:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0101487:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010148a:	c9                   	leave  
f010148b:	c3                   	ret    
		panic("pa2page called with invalid pa");
f010148c:	83 ec 04             	sub    $0x4,%esp
f010148f:	68 88 59 10 f0       	push   $0xf0105988
f0101494:	6a 4f                	push   $0x4f
f0101496:	68 45 60 10 f0       	push   $0xf0106045
f010149b:	e8 a8 ec ff ff       	call   f0100148 <_panic>
		return NULL;
f01014a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01014a5:	eb e0                	jmp    f0101487 <page_lookup+0x3f>
f01014a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01014ac:	eb d9                	jmp    f0101487 <page_lookup+0x3f>

f01014ae <page_remove>:
{
f01014ae:	55                   	push   %ebp
f01014af:	89 e5                	mov    %esp,%ebp
f01014b1:	53                   	push   %ebx
f01014b2:	83 ec 18             	sub    $0x18,%esp
f01014b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo *pp = page_lookup(pgdir, va, &pte_store);
f01014b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01014bb:	50                   	push   %eax
f01014bc:	53                   	push   %ebx
f01014bd:	ff 75 08             	pushl  0x8(%ebp)
f01014c0:	e8 83 ff ff ff       	call   f0101448 <page_lookup>
	if (!pp)
f01014c5:	83 c4 10             	add    $0x10,%esp
f01014c8:	85 c0                	test   %eax,%eax
f01014ca:	74 17                	je     f01014e3 <page_remove+0x35>
	pp->pp_ref--;
f01014cc:	66 ff 48 04          	decw   0x4(%eax)
	*pte_store = 0;
f01014d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01014d3:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01014d9:	0f 01 3b             	invlpg (%ebx)
	if (!pp->pp_ref)
f01014dc:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01014e1:	74 05                	je     f01014e8 <page_remove+0x3a>
}
f01014e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01014e6:	c9                   	leave  
f01014e7:	c3                   	ret    
		page_free(pp);
f01014e8:	83 ec 0c             	sub    $0xc,%esp
f01014eb:	50                   	push   %eax
f01014ec:	e8 79 fd ff ff       	call   f010126a <page_free>
f01014f1:	83 c4 10             	add    $0x10,%esp
f01014f4:	eb ed                	jmp    f01014e3 <page_remove+0x35>

f01014f6 <page_insert>:
{
f01014f6:	55                   	push   %ebp
f01014f7:	89 e5                	mov    %esp,%ebp
f01014f9:	57                   	push   %edi
f01014fa:	56                   	push   %esi
f01014fb:	53                   	push   %ebx
f01014fc:	83 ec 10             	sub    $0x10,%esp
f01014ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101502:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *page_entry = pgdir_walk(pgdir, (void*) va, 1);
f0101505:	6a 01                	push   $0x1
f0101507:	57                   	push   %edi
f0101508:	ff 75 08             	pushl  0x8(%ebp)
f010150b:	e8 d2 fd ff ff       	call   f01012e2 <pgdir_walk>
	if (!page_entry)
f0101510:	83 c4 10             	add    $0x10,%esp
f0101513:	85 c0                	test   %eax,%eax
f0101515:	74 3f                	je     f0101556 <page_insert+0x60>
f0101517:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f0101519:	66 ff 43 04          	incw   0x4(%ebx)
	if (*page_entry) 
f010151d:	83 38 00             	cmpl   $0x0,(%eax)
f0101520:	75 23                	jne    f0101545 <page_insert+0x4f>
	return (pp - pages) << PGSHIFT;
f0101522:	2b 1d ec 6d 1b f0    	sub    0xf01b6dec,%ebx
f0101528:	c1 fb 03             	sar    $0x3,%ebx
f010152b:	c1 e3 0c             	shl    $0xc,%ebx
	*page_entry = page2pa(pp) | perm | PTE_P;
f010152e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101531:	83 c8 01             	or     $0x1,%eax
f0101534:	09 c3                	or     %eax,%ebx
f0101536:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0101538:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010153d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101540:	5b                   	pop    %ebx
f0101541:	5e                   	pop    %esi
f0101542:	5f                   	pop    %edi
f0101543:	5d                   	pop    %ebp
f0101544:	c3                   	ret    
		page_remove(pgdir, va);
f0101545:	83 ec 08             	sub    $0x8,%esp
f0101548:	57                   	push   %edi
f0101549:	ff 75 08             	pushl  0x8(%ebp)
f010154c:	e8 5d ff ff ff       	call   f01014ae <page_remove>
f0101551:	83 c4 10             	add    $0x10,%esp
f0101554:	eb cc                	jmp    f0101522 <page_insert+0x2c>
		return -E_NO_MEM;  // Has no page table AND cannot be allocated
f0101556:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010155b:	eb e0                	jmp    f010153d <page_insert+0x47>

f010155d <mem_init>:
{
f010155d:	55                   	push   %ebp
f010155e:	89 e5                	mov    %esp,%ebp
f0101560:	57                   	push   %edi
f0101561:	56                   	push   %esi
f0101562:	53                   	push   %ebx
f0101563:	83 ec 2c             	sub    $0x2c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0101566:	b8 15 00 00 00       	mov    $0x15,%eax
f010156b:	e8 9c f8 ff ff       	call   f0100e0c <nvram_read>
f0101570:	89 c6                	mov    %eax,%esi
	extmem = nvram_read(NVRAM_EXTLO);
f0101572:	b8 17 00 00 00       	mov    $0x17,%eax
f0101577:	e8 90 f8 ff ff       	call   f0100e0c <nvram_read>
f010157c:	89 c3                	mov    %eax,%ebx
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010157e:	b8 34 00 00 00       	mov    $0x34,%eax
f0101583:	e8 84 f8 ff ff       	call   f0100e0c <nvram_read>
	if (ext16mem)
f0101588:	c1 e0 06             	shl    $0x6,%eax
f010158b:	75 10                	jne    f010159d <mem_init+0x40>
	else if (extmem)
f010158d:	85 db                	test   %ebx,%ebx
f010158f:	0f 84 e6 00 00 00    	je     f010167b <mem_init+0x11e>
		totalmem = 1 * 1024 + extmem;
f0101595:	8d 83 00 04 00 00    	lea    0x400(%ebx),%eax
f010159b:	eb 05                	jmp    f01015a2 <mem_init+0x45>
		totalmem = 16 * 1024 + ext16mem;
f010159d:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f01015a2:	89 c2                	mov    %eax,%edx
f01015a4:	c1 ea 02             	shr    $0x2,%edx
f01015a7:	89 15 e4 6d 1b f0    	mov    %edx,0xf01b6de4
	npages_basemem = basemem / (PGSIZE / 1024);
f01015ad:	89 f2                	mov    %esi,%edx
f01015af:	c1 ea 02             	shr    $0x2,%edx
f01015b2:	89 15 24 61 1b f0    	mov    %edx,0xf01b6124
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01015b8:	89 c2                	mov    %eax,%edx
f01015ba:	29 f2                	sub    %esi,%edx
f01015bc:	52                   	push   %edx
f01015bd:	56                   	push   %esi
f01015be:	50                   	push   %eax
f01015bf:	68 a8 59 10 f0       	push   $0xf01059a8
f01015c4:	e8 1e 21 00 00       	call   f01036e7 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01015c9:	b8 00 10 00 00       	mov    $0x1000,%eax
f01015ce:	e8 f3 f7 ff ff       	call   f0100dc6 <boot_alloc>
f01015d3:	a3 e8 6d 1b f0       	mov    %eax,0xf01b6de8
	memset(kern_pgdir, 0, PGSIZE);
f01015d8:	83 c4 0c             	add    $0xc,%esp
f01015db:	68 00 10 00 00       	push   $0x1000
f01015e0:	6a 00                	push   $0x0
f01015e2:	50                   	push   %eax
f01015e3:	e8 fa 34 00 00       	call   f0104ae2 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01015e8:	a1 e8 6d 1b f0       	mov    0xf01b6de8,%eax
	if ((uint32_t)kva < KERNBASE)
f01015ed:	83 c4 10             	add    $0x10,%esp
f01015f0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01015f5:	0f 86 87 00 00 00    	jbe    f0101682 <mem_init+0x125>
	return (physaddr_t)kva - KERNBASE;
f01015fb:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101601:	83 ca 05             	or     $0x5,%edx
f0101604:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo)*npages);
f010160a:	a1 e4 6d 1b f0       	mov    0xf01b6de4,%eax
f010160f:	c1 e0 03             	shl    $0x3,%eax
f0101612:	e8 af f7 ff ff       	call   f0100dc6 <boot_alloc>
f0101617:	a3 ec 6d 1b f0       	mov    %eax,0xf01b6dec
	memset(pages, 0, sizeof(struct PageInfo)*npages);
f010161c:	83 ec 04             	sub    $0x4,%esp
f010161f:	8b 3d e4 6d 1b f0    	mov    0xf01b6de4,%edi
f0101625:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f010162c:	52                   	push   %edx
f010162d:	6a 00                	push   $0x0
f010162f:	50                   	push   %eax
f0101630:	e8 ad 34 00 00       	call   f0104ae2 <memset>
	envs = (struct Env *) boot_alloc(sizeof(struct Env)*NENV);
f0101635:	b8 00 80 01 00       	mov    $0x18000,%eax
f010163a:	e8 87 f7 ff ff       	call   f0100dc6 <boot_alloc>
f010163f:	a3 2c 61 1b f0       	mov    %eax,0xf01b612c
	memset(envs, 0, sizeof(struct Env)*NENV);
f0101644:	83 c4 0c             	add    $0xc,%esp
f0101647:	68 00 80 01 00       	push   $0x18000
f010164c:	6a 00                	push   $0x0
f010164e:	50                   	push   %eax
f010164f:	e8 8e 34 00 00       	call   f0104ae2 <memset>
	page_init();
f0101654:	e8 00 fb ff ff       	call   f0101159 <page_init>
	check_page_free_list(1);
f0101659:	b8 01 00 00 00       	mov    $0x1,%eax
f010165e:	e8 2f f8 ff ff       	call   f0100e92 <check_page_free_list>
	if (!pages)
f0101663:	83 c4 10             	add    $0x10,%esp
f0101666:	83 3d ec 6d 1b f0 00 	cmpl   $0x0,0xf01b6dec
f010166d:	74 28                	je     f0101697 <mem_init+0x13a>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010166f:	a1 20 61 1b f0       	mov    0xf01b6120,%eax
f0101674:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101679:	eb 36                	jmp    f01016b1 <mem_init+0x154>
		totalmem = basemem;
f010167b:	89 f0                	mov    %esi,%eax
f010167d:	e9 20 ff ff ff       	jmp    f01015a2 <mem_init+0x45>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101682:	50                   	push   %eax
f0101683:	68 64 59 10 f0       	push   $0xf0105964
f0101688:	68 92 00 00 00       	push   $0x92
f010168d:	68 39 60 10 f0       	push   $0xf0106039
f0101692:	e8 b1 ea ff ff       	call   f0100148 <_panic>
		panic("'pages' is a null pointer!");
f0101697:	83 ec 04             	sub    $0x4,%esp
f010169a:	68 1a 61 10 f0       	push   $0xf010611a
f010169f:	68 89 02 00 00       	push   $0x289
f01016a4:	68 39 60 10 f0       	push   $0xf0106039
f01016a9:	e8 9a ea ff ff       	call   f0100148 <_panic>
		++nfree;
f01016ae:	43                   	inc    %ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01016af:	8b 00                	mov    (%eax),%eax
f01016b1:	85 c0                	test   %eax,%eax
f01016b3:	75 f9                	jne    f01016ae <mem_init+0x151>
	assert((pp0 = page_alloc(0)));
f01016b5:	83 ec 0c             	sub    $0xc,%esp
f01016b8:	6a 00                	push   $0x0
f01016ba:	e8 39 fb ff ff       	call   f01011f8 <page_alloc>
f01016bf:	89 c7                	mov    %eax,%edi
f01016c1:	83 c4 10             	add    $0x10,%esp
f01016c4:	85 c0                	test   %eax,%eax
f01016c6:	0f 84 10 02 00 00    	je     f01018dc <mem_init+0x37f>
	assert((pp1 = page_alloc(0)));
f01016cc:	83 ec 0c             	sub    $0xc,%esp
f01016cf:	6a 00                	push   $0x0
f01016d1:	e8 22 fb ff ff       	call   f01011f8 <page_alloc>
f01016d6:	89 c6                	mov    %eax,%esi
f01016d8:	83 c4 10             	add    $0x10,%esp
f01016db:	85 c0                	test   %eax,%eax
f01016dd:	0f 84 12 02 00 00    	je     f01018f5 <mem_init+0x398>
	assert((pp2 = page_alloc(0)));
f01016e3:	83 ec 0c             	sub    $0xc,%esp
f01016e6:	6a 00                	push   $0x0
f01016e8:	e8 0b fb ff ff       	call   f01011f8 <page_alloc>
f01016ed:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01016f0:	83 c4 10             	add    $0x10,%esp
f01016f3:	85 c0                	test   %eax,%eax
f01016f5:	0f 84 13 02 00 00    	je     f010190e <mem_init+0x3b1>
	assert(pp1 && pp1 != pp0);
f01016fb:	39 f7                	cmp    %esi,%edi
f01016fd:	0f 84 24 02 00 00    	je     f0101927 <mem_init+0x3ca>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101703:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101706:	39 c6                	cmp    %eax,%esi
f0101708:	0f 84 32 02 00 00    	je     f0101940 <mem_init+0x3e3>
f010170e:	39 c7                	cmp    %eax,%edi
f0101710:	0f 84 2a 02 00 00    	je     f0101940 <mem_init+0x3e3>
	return (pp - pages) << PGSHIFT;
f0101716:	8b 0d ec 6d 1b f0    	mov    0xf01b6dec,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010171c:	8b 15 e4 6d 1b f0    	mov    0xf01b6de4,%edx
f0101722:	c1 e2 0c             	shl    $0xc,%edx
f0101725:	89 f8                	mov    %edi,%eax
f0101727:	29 c8                	sub    %ecx,%eax
f0101729:	c1 f8 03             	sar    $0x3,%eax
f010172c:	c1 e0 0c             	shl    $0xc,%eax
f010172f:	39 d0                	cmp    %edx,%eax
f0101731:	0f 83 22 02 00 00    	jae    f0101959 <mem_init+0x3fc>
f0101737:	89 f0                	mov    %esi,%eax
f0101739:	29 c8                	sub    %ecx,%eax
f010173b:	c1 f8 03             	sar    $0x3,%eax
f010173e:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101741:	39 c2                	cmp    %eax,%edx
f0101743:	0f 86 29 02 00 00    	jbe    f0101972 <mem_init+0x415>
f0101749:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010174c:	29 c8                	sub    %ecx,%eax
f010174e:	c1 f8 03             	sar    $0x3,%eax
f0101751:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101754:	39 c2                	cmp    %eax,%edx
f0101756:	0f 86 2f 02 00 00    	jbe    f010198b <mem_init+0x42e>
	fl = page_free_list;
f010175c:	a1 20 61 1b f0       	mov    0xf01b6120,%eax
f0101761:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101764:	c7 05 20 61 1b f0 00 	movl   $0x0,0xf01b6120
f010176b:	00 00 00 
	assert(!page_alloc(0));
f010176e:	83 ec 0c             	sub    $0xc,%esp
f0101771:	6a 00                	push   $0x0
f0101773:	e8 80 fa ff ff       	call   f01011f8 <page_alloc>
f0101778:	83 c4 10             	add    $0x10,%esp
f010177b:	85 c0                	test   %eax,%eax
f010177d:	0f 85 21 02 00 00    	jne    f01019a4 <mem_init+0x447>
	page_free(pp0);
f0101783:	83 ec 0c             	sub    $0xc,%esp
f0101786:	57                   	push   %edi
f0101787:	e8 de fa ff ff       	call   f010126a <page_free>
	page_free(pp1);
f010178c:	89 34 24             	mov    %esi,(%esp)
f010178f:	e8 d6 fa ff ff       	call   f010126a <page_free>
	page_free(pp2);
f0101794:	83 c4 04             	add    $0x4,%esp
f0101797:	ff 75 d4             	pushl  -0x2c(%ebp)
f010179a:	e8 cb fa ff ff       	call   f010126a <page_free>
	assert((pp0 = page_alloc(0)));
f010179f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017a6:	e8 4d fa ff ff       	call   f01011f8 <page_alloc>
f01017ab:	89 c6                	mov    %eax,%esi
f01017ad:	83 c4 10             	add    $0x10,%esp
f01017b0:	85 c0                	test   %eax,%eax
f01017b2:	0f 84 05 02 00 00    	je     f01019bd <mem_init+0x460>
	assert((pp1 = page_alloc(0)));
f01017b8:	83 ec 0c             	sub    $0xc,%esp
f01017bb:	6a 00                	push   $0x0
f01017bd:	e8 36 fa ff ff       	call   f01011f8 <page_alloc>
f01017c2:	89 c7                	mov    %eax,%edi
f01017c4:	83 c4 10             	add    $0x10,%esp
f01017c7:	85 c0                	test   %eax,%eax
f01017c9:	0f 84 07 02 00 00    	je     f01019d6 <mem_init+0x479>
	assert((pp2 = page_alloc(0)));
f01017cf:	83 ec 0c             	sub    $0xc,%esp
f01017d2:	6a 00                	push   $0x0
f01017d4:	e8 1f fa ff ff       	call   f01011f8 <page_alloc>
f01017d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017dc:	83 c4 10             	add    $0x10,%esp
f01017df:	85 c0                	test   %eax,%eax
f01017e1:	0f 84 08 02 00 00    	je     f01019ef <mem_init+0x492>
	assert(pp1 && pp1 != pp0);
f01017e7:	39 fe                	cmp    %edi,%esi
f01017e9:	0f 84 19 02 00 00    	je     f0101a08 <mem_init+0x4ab>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017f2:	39 c7                	cmp    %eax,%edi
f01017f4:	0f 84 27 02 00 00    	je     f0101a21 <mem_init+0x4c4>
f01017fa:	39 c6                	cmp    %eax,%esi
f01017fc:	0f 84 1f 02 00 00    	je     f0101a21 <mem_init+0x4c4>
	assert(!page_alloc(0));
f0101802:	83 ec 0c             	sub    $0xc,%esp
f0101805:	6a 00                	push   $0x0
f0101807:	e8 ec f9 ff ff       	call   f01011f8 <page_alloc>
f010180c:	83 c4 10             	add    $0x10,%esp
f010180f:	85 c0                	test   %eax,%eax
f0101811:	0f 85 23 02 00 00    	jne    f0101a3a <mem_init+0x4dd>
f0101817:	89 f0                	mov    %esi,%eax
f0101819:	2b 05 ec 6d 1b f0    	sub    0xf01b6dec,%eax
f010181f:	c1 f8 03             	sar    $0x3,%eax
f0101822:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101825:	89 c2                	mov    %eax,%edx
f0101827:	c1 ea 0c             	shr    $0xc,%edx
f010182a:	3b 15 e4 6d 1b f0    	cmp    0xf01b6de4,%edx
f0101830:	0f 83 1d 02 00 00    	jae    f0101a53 <mem_init+0x4f6>
	memset(page2kva(pp0), 1, PGSIZE);
f0101836:	83 ec 04             	sub    $0x4,%esp
f0101839:	68 00 10 00 00       	push   $0x1000
f010183e:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101840:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101845:	50                   	push   %eax
f0101846:	e8 97 32 00 00       	call   f0104ae2 <memset>
	page_free(pp0);
f010184b:	89 34 24             	mov    %esi,(%esp)
f010184e:	e8 17 fa ff ff       	call   f010126a <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101853:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010185a:	e8 99 f9 ff ff       	call   f01011f8 <page_alloc>
f010185f:	83 c4 10             	add    $0x10,%esp
f0101862:	85 c0                	test   %eax,%eax
f0101864:	0f 84 fb 01 00 00    	je     f0101a65 <mem_init+0x508>
	assert(pp && pp0 == pp);
f010186a:	39 c6                	cmp    %eax,%esi
f010186c:	0f 85 0c 02 00 00    	jne    f0101a7e <mem_init+0x521>
	return (pp - pages) << PGSHIFT;
f0101872:	89 f2                	mov    %esi,%edx
f0101874:	2b 15 ec 6d 1b f0    	sub    0xf01b6dec,%edx
f010187a:	c1 fa 03             	sar    $0x3,%edx
f010187d:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101880:	89 d0                	mov    %edx,%eax
f0101882:	c1 e8 0c             	shr    $0xc,%eax
f0101885:	3b 05 e4 6d 1b f0    	cmp    0xf01b6de4,%eax
f010188b:	0f 83 06 02 00 00    	jae    f0101a97 <mem_init+0x53a>
	return (void *)(pa + KERNBASE);
f0101891:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101897:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f010189d:	80 38 00             	cmpb   $0x0,(%eax)
f01018a0:	0f 85 03 02 00 00    	jne    f0101aa9 <mem_init+0x54c>
f01018a6:	40                   	inc    %eax
	for (i = 0; i < PGSIZE; i++)
f01018a7:	39 d0                	cmp    %edx,%eax
f01018a9:	75 f2                	jne    f010189d <mem_init+0x340>
	page_free_list = fl;
f01018ab:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01018ae:	a3 20 61 1b f0       	mov    %eax,0xf01b6120
	page_free(pp0);
f01018b3:	83 ec 0c             	sub    $0xc,%esp
f01018b6:	56                   	push   %esi
f01018b7:	e8 ae f9 ff ff       	call   f010126a <page_free>
	page_free(pp1);
f01018bc:	89 3c 24             	mov    %edi,(%esp)
f01018bf:	e8 a6 f9 ff ff       	call   f010126a <page_free>
	page_free(pp2);
f01018c4:	83 c4 04             	add    $0x4,%esp
f01018c7:	ff 75 d4             	pushl  -0x2c(%ebp)
f01018ca:	e8 9b f9 ff ff       	call   f010126a <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01018cf:	a1 20 61 1b f0       	mov    0xf01b6120,%eax
f01018d4:	83 c4 10             	add    $0x10,%esp
f01018d7:	e9 e9 01 00 00       	jmp    f0101ac5 <mem_init+0x568>
	assert((pp0 = page_alloc(0)));
f01018dc:	68 35 61 10 f0       	push   $0xf0106135
f01018e1:	68 5f 60 10 f0       	push   $0xf010605f
f01018e6:	68 91 02 00 00       	push   $0x291
f01018eb:	68 39 60 10 f0       	push   $0xf0106039
f01018f0:	e8 53 e8 ff ff       	call   f0100148 <_panic>
	assert((pp1 = page_alloc(0)));
f01018f5:	68 4b 61 10 f0       	push   $0xf010614b
f01018fa:	68 5f 60 10 f0       	push   $0xf010605f
f01018ff:	68 92 02 00 00       	push   $0x292
f0101904:	68 39 60 10 f0       	push   $0xf0106039
f0101909:	e8 3a e8 ff ff       	call   f0100148 <_panic>
	assert((pp2 = page_alloc(0)));
f010190e:	68 61 61 10 f0       	push   $0xf0106161
f0101913:	68 5f 60 10 f0       	push   $0xf010605f
f0101918:	68 93 02 00 00       	push   $0x293
f010191d:	68 39 60 10 f0       	push   $0xf0106039
f0101922:	e8 21 e8 ff ff       	call   f0100148 <_panic>
	assert(pp1 && pp1 != pp0);
f0101927:	68 77 61 10 f0       	push   $0xf0106177
f010192c:	68 5f 60 10 f0       	push   $0xf010605f
f0101931:	68 96 02 00 00       	push   $0x296
f0101936:	68 39 60 10 f0       	push   $0xf0106039
f010193b:	e8 08 e8 ff ff       	call   f0100148 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101940:	68 e4 59 10 f0       	push   $0xf01059e4
f0101945:	68 5f 60 10 f0       	push   $0xf010605f
f010194a:	68 97 02 00 00       	push   $0x297
f010194f:	68 39 60 10 f0       	push   $0xf0106039
f0101954:	e8 ef e7 ff ff       	call   f0100148 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101959:	68 89 61 10 f0       	push   $0xf0106189
f010195e:	68 5f 60 10 f0       	push   $0xf010605f
f0101963:	68 98 02 00 00       	push   $0x298
f0101968:	68 39 60 10 f0       	push   $0xf0106039
f010196d:	e8 d6 e7 ff ff       	call   f0100148 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101972:	68 a6 61 10 f0       	push   $0xf01061a6
f0101977:	68 5f 60 10 f0       	push   $0xf010605f
f010197c:	68 99 02 00 00       	push   $0x299
f0101981:	68 39 60 10 f0       	push   $0xf0106039
f0101986:	e8 bd e7 ff ff       	call   f0100148 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010198b:	68 c3 61 10 f0       	push   $0xf01061c3
f0101990:	68 5f 60 10 f0       	push   $0xf010605f
f0101995:	68 9a 02 00 00       	push   $0x29a
f010199a:	68 39 60 10 f0       	push   $0xf0106039
f010199f:	e8 a4 e7 ff ff       	call   f0100148 <_panic>
	assert(!page_alloc(0));
f01019a4:	68 e0 61 10 f0       	push   $0xf01061e0
f01019a9:	68 5f 60 10 f0       	push   $0xf010605f
f01019ae:	68 a1 02 00 00       	push   $0x2a1
f01019b3:	68 39 60 10 f0       	push   $0xf0106039
f01019b8:	e8 8b e7 ff ff       	call   f0100148 <_panic>
	assert((pp0 = page_alloc(0)));
f01019bd:	68 35 61 10 f0       	push   $0xf0106135
f01019c2:	68 5f 60 10 f0       	push   $0xf010605f
f01019c7:	68 a8 02 00 00       	push   $0x2a8
f01019cc:	68 39 60 10 f0       	push   $0xf0106039
f01019d1:	e8 72 e7 ff ff       	call   f0100148 <_panic>
	assert((pp1 = page_alloc(0)));
f01019d6:	68 4b 61 10 f0       	push   $0xf010614b
f01019db:	68 5f 60 10 f0       	push   $0xf010605f
f01019e0:	68 a9 02 00 00       	push   $0x2a9
f01019e5:	68 39 60 10 f0       	push   $0xf0106039
f01019ea:	e8 59 e7 ff ff       	call   f0100148 <_panic>
	assert((pp2 = page_alloc(0)));
f01019ef:	68 61 61 10 f0       	push   $0xf0106161
f01019f4:	68 5f 60 10 f0       	push   $0xf010605f
f01019f9:	68 aa 02 00 00       	push   $0x2aa
f01019fe:	68 39 60 10 f0       	push   $0xf0106039
f0101a03:	e8 40 e7 ff ff       	call   f0100148 <_panic>
	assert(pp1 && pp1 != pp0);
f0101a08:	68 77 61 10 f0       	push   $0xf0106177
f0101a0d:	68 5f 60 10 f0       	push   $0xf010605f
f0101a12:	68 ac 02 00 00       	push   $0x2ac
f0101a17:	68 39 60 10 f0       	push   $0xf0106039
f0101a1c:	e8 27 e7 ff ff       	call   f0100148 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a21:	68 e4 59 10 f0       	push   $0xf01059e4
f0101a26:	68 5f 60 10 f0       	push   $0xf010605f
f0101a2b:	68 ad 02 00 00       	push   $0x2ad
f0101a30:	68 39 60 10 f0       	push   $0xf0106039
f0101a35:	e8 0e e7 ff ff       	call   f0100148 <_panic>
	assert(!page_alloc(0));
f0101a3a:	68 e0 61 10 f0       	push   $0xf01061e0
f0101a3f:	68 5f 60 10 f0       	push   $0xf010605f
f0101a44:	68 ae 02 00 00       	push   $0x2ae
f0101a49:	68 39 60 10 f0       	push   $0xf0106039
f0101a4e:	e8 f5 e6 ff ff       	call   f0100148 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a53:	50                   	push   %eax
f0101a54:	68 b0 56 10 f0       	push   $0xf01056b0
f0101a59:	6a 56                	push   $0x56
f0101a5b:	68 45 60 10 f0       	push   $0xf0106045
f0101a60:	e8 e3 e6 ff ff       	call   f0100148 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101a65:	68 ef 61 10 f0       	push   $0xf01061ef
f0101a6a:	68 5f 60 10 f0       	push   $0xf010605f
f0101a6f:	68 b3 02 00 00       	push   $0x2b3
f0101a74:	68 39 60 10 f0       	push   $0xf0106039
f0101a79:	e8 ca e6 ff ff       	call   f0100148 <_panic>
	assert(pp && pp0 == pp);
f0101a7e:	68 0d 62 10 f0       	push   $0xf010620d
f0101a83:	68 5f 60 10 f0       	push   $0xf010605f
f0101a88:	68 b4 02 00 00       	push   $0x2b4
f0101a8d:	68 39 60 10 f0       	push   $0xf0106039
f0101a92:	e8 b1 e6 ff ff       	call   f0100148 <_panic>
f0101a97:	52                   	push   %edx
f0101a98:	68 b0 56 10 f0       	push   $0xf01056b0
f0101a9d:	6a 56                	push   $0x56
f0101a9f:	68 45 60 10 f0       	push   $0xf0106045
f0101aa4:	e8 9f e6 ff ff       	call   f0100148 <_panic>
		assert(c[i] == 0);
f0101aa9:	68 1d 62 10 f0       	push   $0xf010621d
f0101aae:	68 5f 60 10 f0       	push   $0xf010605f
f0101ab3:	68 b7 02 00 00       	push   $0x2b7
f0101ab8:	68 39 60 10 f0       	push   $0xf0106039
f0101abd:	e8 86 e6 ff ff       	call   f0100148 <_panic>
		--nfree;
f0101ac2:	4b                   	dec    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101ac3:	8b 00                	mov    (%eax),%eax
f0101ac5:	85 c0                	test   %eax,%eax
f0101ac7:	75 f9                	jne    f0101ac2 <mem_init+0x565>
	assert(nfree == 0);
f0101ac9:	85 db                	test   %ebx,%ebx
f0101acb:	0f 85 b1 07 00 00    	jne    f0102282 <mem_init+0xd25>
	cprintf("check_page_alloc() succeeded!\n");
f0101ad1:	83 ec 0c             	sub    $0xc,%esp
f0101ad4:	68 04 5a 10 f0       	push   $0xf0105a04
f0101ad9:	e8 09 1c 00 00       	call   f01036e7 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101ade:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ae5:	e8 0e f7 ff ff       	call   f01011f8 <page_alloc>
f0101aea:	89 c7                	mov    %eax,%edi
f0101aec:	83 c4 10             	add    $0x10,%esp
f0101aef:	85 c0                	test   %eax,%eax
f0101af1:	0f 84 a4 07 00 00    	je     f010229b <mem_init+0xd3e>
	assert((pp1 = page_alloc(0)));
f0101af7:	83 ec 0c             	sub    $0xc,%esp
f0101afa:	6a 00                	push   $0x0
f0101afc:	e8 f7 f6 ff ff       	call   f01011f8 <page_alloc>
f0101b01:	89 c3                	mov    %eax,%ebx
f0101b03:	83 c4 10             	add    $0x10,%esp
f0101b06:	85 c0                	test   %eax,%eax
f0101b08:	0f 84 a6 07 00 00    	je     f01022b4 <mem_init+0xd57>
	assert((pp2 = page_alloc(0)));
f0101b0e:	83 ec 0c             	sub    $0xc,%esp
f0101b11:	6a 00                	push   $0x0
f0101b13:	e8 e0 f6 ff ff       	call   f01011f8 <page_alloc>
f0101b18:	89 c6                	mov    %eax,%esi
f0101b1a:	83 c4 10             	add    $0x10,%esp
f0101b1d:	85 c0                	test   %eax,%eax
f0101b1f:	0f 84 a8 07 00 00    	je     f01022cd <mem_init+0xd70>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b25:	39 df                	cmp    %ebx,%edi
f0101b27:	0f 84 b9 07 00 00    	je     f01022e6 <mem_init+0xd89>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b2d:	39 c3                	cmp    %eax,%ebx
f0101b2f:	0f 84 ca 07 00 00    	je     f01022ff <mem_init+0xda2>
f0101b35:	39 c7                	cmp    %eax,%edi
f0101b37:	0f 84 c2 07 00 00    	je     f01022ff <mem_init+0xda2>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101b3d:	a1 20 61 1b f0       	mov    0xf01b6120,%eax
f0101b42:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f0101b45:	c7 05 20 61 1b f0 00 	movl   $0x0,0xf01b6120
f0101b4c:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101b4f:	83 ec 0c             	sub    $0xc,%esp
f0101b52:	6a 00                	push   $0x0
f0101b54:	e8 9f f6 ff ff       	call   f01011f8 <page_alloc>
f0101b59:	83 c4 10             	add    $0x10,%esp
f0101b5c:	85 c0                	test   %eax,%eax
f0101b5e:	0f 85 b4 07 00 00    	jne    f0102318 <mem_init+0xdbb>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101b64:	83 ec 04             	sub    $0x4,%esp
f0101b67:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101b6a:	50                   	push   %eax
f0101b6b:	6a 00                	push   $0x0
f0101b6d:	ff 35 e8 6d 1b f0    	pushl  0xf01b6de8
f0101b73:	e8 d0 f8 ff ff       	call   f0101448 <page_lookup>
f0101b78:	83 c4 10             	add    $0x10,%esp
f0101b7b:	85 c0                	test   %eax,%eax
f0101b7d:	0f 85 ae 07 00 00    	jne    f0102331 <mem_init+0xdd4>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101b83:	6a 02                	push   $0x2
f0101b85:	6a 00                	push   $0x0
f0101b87:	53                   	push   %ebx
f0101b88:	ff 35 e8 6d 1b f0    	pushl  0xf01b6de8
f0101b8e:	e8 63 f9 ff ff       	call   f01014f6 <page_insert>
f0101b93:	83 c4 10             	add    $0x10,%esp
f0101b96:	85 c0                	test   %eax,%eax
f0101b98:	0f 89 ac 07 00 00    	jns    f010234a <mem_init+0xded>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101b9e:	83 ec 0c             	sub    $0xc,%esp
f0101ba1:	57                   	push   %edi
f0101ba2:	e8 c3 f6 ff ff       	call   f010126a <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101ba7:	6a 02                	push   $0x2
f0101ba9:	6a 00                	push   $0x0
f0101bab:	53                   	push   %ebx
f0101bac:	ff 35 e8 6d 1b f0    	pushl  0xf01b6de8
f0101bb2:	e8 3f f9 ff ff       	call   f01014f6 <page_insert>
f0101bb7:	83 c4 20             	add    $0x20,%esp
f0101bba:	85 c0                	test   %eax,%eax
f0101bbc:	0f 85 a1 07 00 00    	jne    f0102363 <mem_init+0xe06>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101bc2:	a1 e8 6d 1b f0       	mov    0xf01b6de8,%eax
f0101bc7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	return (pp - pages) << PGSHIFT;
f0101bca:	8b 0d ec 6d 1b f0    	mov    0xf01b6dec,%ecx
f0101bd0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101bd3:	8b 00                	mov    (%eax),%eax
f0101bd5:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101bd8:	89 c2                	mov    %eax,%edx
f0101bda:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101be0:	89 f8                	mov    %edi,%eax
f0101be2:	29 c8                	sub    %ecx,%eax
f0101be4:	c1 f8 03             	sar    $0x3,%eax
f0101be7:	c1 e0 0c             	shl    $0xc,%eax
f0101bea:	39 c2                	cmp    %eax,%edx
f0101bec:	0f 85 8a 07 00 00    	jne    f010237c <mem_init+0xe1f>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101bf2:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bf7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bfa:	e8 34 f2 ff ff       	call   f0100e33 <check_va2pa>
f0101bff:	89 da                	mov    %ebx,%edx
f0101c01:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101c04:	c1 fa 03             	sar    $0x3,%edx
f0101c07:	c1 e2 0c             	shl    $0xc,%edx
f0101c0a:	39 d0                	cmp    %edx,%eax
f0101c0c:	0f 85 83 07 00 00    	jne    f0102395 <mem_init+0xe38>
	assert(pp1->pp_ref == 1);
f0101c12:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101c17:	0f 85 91 07 00 00    	jne    f01023ae <mem_init+0xe51>
	assert(pp0->pp_ref == 1);
f0101c1d:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101c22:	0f 85 9f 07 00 00    	jne    f01023c7 <mem_init+0xe6a>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c28:	6a 02                	push   $0x2
f0101c2a:	68 00 10 00 00       	push   $0x1000
f0101c2f:	56                   	push   %esi
f0101c30:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c33:	e8 be f8 ff ff       	call   f01014f6 <page_insert>
f0101c38:	83 c4 10             	add    $0x10,%esp
f0101c3b:	85 c0                	test   %eax,%eax
f0101c3d:	0f 85 9d 07 00 00    	jne    f01023e0 <mem_init+0xe83>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c43:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c48:	a1 e8 6d 1b f0       	mov    0xf01b6de8,%eax
f0101c4d:	e8 e1 f1 ff ff       	call   f0100e33 <check_va2pa>
f0101c52:	89 f2                	mov    %esi,%edx
f0101c54:	2b 15 ec 6d 1b f0    	sub    0xf01b6dec,%edx
f0101c5a:	c1 fa 03             	sar    $0x3,%edx
f0101c5d:	c1 e2 0c             	shl    $0xc,%edx
f0101c60:	39 d0                	cmp    %edx,%eax
f0101c62:	0f 85 91 07 00 00    	jne    f01023f9 <mem_init+0xe9c>
	assert(pp2->pp_ref == 1);
f0101c68:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c6d:	0f 85 9f 07 00 00    	jne    f0102412 <mem_init+0xeb5>

	// should be no free memory
	assert(!page_alloc(0));
f0101c73:	83 ec 0c             	sub    $0xc,%esp
f0101c76:	6a 00                	push   $0x0
f0101c78:	e8 7b f5 ff ff       	call   f01011f8 <page_alloc>
f0101c7d:	83 c4 10             	add    $0x10,%esp
f0101c80:	85 c0                	test   %eax,%eax
f0101c82:	0f 85 a3 07 00 00    	jne    f010242b <mem_init+0xece>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c88:	6a 02                	push   $0x2
f0101c8a:	68 00 10 00 00       	push   $0x1000
f0101c8f:	56                   	push   %esi
f0101c90:	ff 35 e8 6d 1b f0    	pushl  0xf01b6de8
f0101c96:	e8 5b f8 ff ff       	call   f01014f6 <page_insert>
f0101c9b:	83 c4 10             	add    $0x10,%esp
f0101c9e:	85 c0                	test   %eax,%eax
f0101ca0:	0f 85 9e 07 00 00    	jne    f0102444 <mem_init+0xee7>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ca6:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cab:	a1 e8 6d 1b f0       	mov    0xf01b6de8,%eax
f0101cb0:	e8 7e f1 ff ff       	call   f0100e33 <check_va2pa>
f0101cb5:	89 f2                	mov    %esi,%edx
f0101cb7:	2b 15 ec 6d 1b f0    	sub    0xf01b6dec,%edx
f0101cbd:	c1 fa 03             	sar    $0x3,%edx
f0101cc0:	c1 e2 0c             	shl    $0xc,%edx
f0101cc3:	39 d0                	cmp    %edx,%eax
f0101cc5:	0f 85 92 07 00 00    	jne    f010245d <mem_init+0xf00>
	assert(pp2->pp_ref == 1);
f0101ccb:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101cd0:	0f 85 a0 07 00 00    	jne    f0102476 <mem_init+0xf19>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101cd6:	83 ec 0c             	sub    $0xc,%esp
f0101cd9:	6a 00                	push   $0x0
f0101cdb:	e8 18 f5 ff ff       	call   f01011f8 <page_alloc>
f0101ce0:	83 c4 10             	add    $0x10,%esp
f0101ce3:	85 c0                	test   %eax,%eax
f0101ce5:	0f 85 a4 07 00 00    	jne    f010248f <mem_init+0xf32>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101ceb:	8b 15 e8 6d 1b f0    	mov    0xf01b6de8,%edx
f0101cf1:	8b 02                	mov    (%edx),%eax
f0101cf3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101cf8:	89 c1                	mov    %eax,%ecx
f0101cfa:	c1 e9 0c             	shr    $0xc,%ecx
f0101cfd:	3b 0d e4 6d 1b f0    	cmp    0xf01b6de4,%ecx
f0101d03:	0f 83 9f 07 00 00    	jae    f01024a8 <mem_init+0xf4b>
	return (void *)(pa + KERNBASE);
f0101d09:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101d0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101d11:	83 ec 04             	sub    $0x4,%esp
f0101d14:	6a 00                	push   $0x0
f0101d16:	68 00 10 00 00       	push   $0x1000
f0101d1b:	52                   	push   %edx
f0101d1c:	e8 c1 f5 ff ff       	call   f01012e2 <pgdir_walk>
f0101d21:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101d24:	8d 51 04             	lea    0x4(%ecx),%edx
f0101d27:	83 c4 10             	add    $0x10,%esp
f0101d2a:	39 d0                	cmp    %edx,%eax
f0101d2c:	0f 85 8b 07 00 00    	jne    f01024bd <mem_init+0xf60>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101d32:	6a 06                	push   $0x6
f0101d34:	68 00 10 00 00       	push   $0x1000
f0101d39:	56                   	push   %esi
f0101d3a:	ff 35 e8 6d 1b f0    	pushl  0xf01b6de8
f0101d40:	e8 b1 f7 ff ff       	call   f01014f6 <page_insert>
f0101d45:	83 c4 10             	add    $0x10,%esp
f0101d48:	85 c0                	test   %eax,%eax
f0101d4a:	0f 85 86 07 00 00    	jne    f01024d6 <mem_init+0xf79>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d50:	a1 e8 6d 1b f0       	mov    0xf01b6de8,%eax
f0101d55:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101d58:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d5d:	e8 d1 f0 ff ff       	call   f0100e33 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101d62:	89 f2                	mov    %esi,%edx
f0101d64:	2b 15 ec 6d 1b f0    	sub    0xf01b6dec,%edx
f0101d6a:	c1 fa 03             	sar    $0x3,%edx
f0101d6d:	c1 e2 0c             	shl    $0xc,%edx
f0101d70:	39 d0                	cmp    %edx,%eax
f0101d72:	0f 85 77 07 00 00    	jne    f01024ef <mem_init+0xf92>
	assert(pp2->pp_ref == 1);
f0101d78:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d7d:	0f 85 85 07 00 00    	jne    f0102508 <mem_init+0xfab>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101d83:	83 ec 04             	sub    $0x4,%esp
f0101d86:	6a 00                	push   $0x0
f0101d88:	68 00 10 00 00       	push   $0x1000
f0101d8d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101d90:	e8 4d f5 ff ff       	call   f01012e2 <pgdir_walk>
f0101d95:	83 c4 10             	add    $0x10,%esp
f0101d98:	f6 00 04             	testb  $0x4,(%eax)
f0101d9b:	0f 84 80 07 00 00    	je     f0102521 <mem_init+0xfc4>
	assert(kern_pgdir[0] & PTE_U);
f0101da1:	a1 e8 6d 1b f0       	mov    0xf01b6de8,%eax
f0101da6:	f6 00 04             	testb  $0x4,(%eax)
f0101da9:	0f 84 8b 07 00 00    	je     f010253a <mem_init+0xfdd>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101daf:	6a 02                	push   $0x2
f0101db1:	68 00 10 00 00       	push   $0x1000
f0101db6:	56                   	push   %esi
f0101db7:	50                   	push   %eax
f0101db8:	e8 39 f7 ff ff       	call   f01014f6 <page_insert>
f0101dbd:	83 c4 10             	add    $0x10,%esp
f0101dc0:	85 c0                	test   %eax,%eax
f0101dc2:	0f 85 8b 07 00 00    	jne    f0102553 <mem_init+0xff6>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101dc8:	83 ec 04             	sub    $0x4,%esp
f0101dcb:	6a 00                	push   $0x0
f0101dcd:	68 00 10 00 00       	push   $0x1000
f0101dd2:	ff 35 e8 6d 1b f0    	pushl  0xf01b6de8
f0101dd8:	e8 05 f5 ff ff       	call   f01012e2 <pgdir_walk>
f0101ddd:	83 c4 10             	add    $0x10,%esp
f0101de0:	f6 00 02             	testb  $0x2,(%eax)
f0101de3:	0f 84 83 07 00 00    	je     f010256c <mem_init+0x100f>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101de9:	83 ec 04             	sub    $0x4,%esp
f0101dec:	6a 00                	push   $0x0
f0101dee:	68 00 10 00 00       	push   $0x1000
f0101df3:	ff 35 e8 6d 1b f0    	pushl  0xf01b6de8
f0101df9:	e8 e4 f4 ff ff       	call   f01012e2 <pgdir_walk>
f0101dfe:	83 c4 10             	add    $0x10,%esp
f0101e01:	f6 00 04             	testb  $0x4,(%eax)
f0101e04:	0f 85 7b 07 00 00    	jne    f0102585 <mem_init+0x1028>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101e0a:	6a 02                	push   $0x2
f0101e0c:	68 00 00 40 00       	push   $0x400000
f0101e11:	57                   	push   %edi
f0101e12:	ff 35 e8 6d 1b f0    	pushl  0xf01b6de8
f0101e18:	e8 d9 f6 ff ff       	call   f01014f6 <page_insert>
f0101e1d:	83 c4 10             	add    $0x10,%esp
f0101e20:	85 c0                	test   %eax,%eax
f0101e22:	0f 89 76 07 00 00    	jns    f010259e <mem_init+0x1041>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101e28:	6a 02                	push   $0x2
f0101e2a:	68 00 10 00 00       	push   $0x1000
f0101e2f:	53                   	push   %ebx
f0101e30:	ff 35 e8 6d 1b f0    	pushl  0xf01b6de8
f0101e36:	e8 bb f6 ff ff       	call   f01014f6 <page_insert>
f0101e3b:	83 c4 10             	add    $0x10,%esp
f0101e3e:	85 c0                	test   %eax,%eax
f0101e40:	0f 85 71 07 00 00    	jne    f01025b7 <mem_init+0x105a>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e46:	83 ec 04             	sub    $0x4,%esp
f0101e49:	6a 00                	push   $0x0
f0101e4b:	68 00 10 00 00       	push   $0x1000
f0101e50:	ff 35 e8 6d 1b f0    	pushl  0xf01b6de8
f0101e56:	e8 87 f4 ff ff       	call   f01012e2 <pgdir_walk>
f0101e5b:	83 c4 10             	add    $0x10,%esp
f0101e5e:	f6 00 04             	testb  $0x4,(%eax)
f0101e61:	0f 85 69 07 00 00    	jne    f01025d0 <mem_init+0x1073>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101e67:	a1 e8 6d 1b f0       	mov    0xf01b6de8,%eax
f0101e6c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101e6f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e74:	e8 ba ef ff ff       	call   f0100e33 <check_va2pa>
f0101e79:	89 c1                	mov    %eax,%ecx
f0101e7b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101e7e:	89 d8                	mov    %ebx,%eax
f0101e80:	2b 05 ec 6d 1b f0    	sub    0xf01b6dec,%eax
f0101e86:	c1 f8 03             	sar    $0x3,%eax
f0101e89:	c1 e0 0c             	shl    $0xc,%eax
f0101e8c:	39 c1                	cmp    %eax,%ecx
f0101e8e:	0f 85 55 07 00 00    	jne    f01025e9 <mem_init+0x108c>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e94:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e99:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e9c:	e8 92 ef ff ff       	call   f0100e33 <check_va2pa>
f0101ea1:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101ea4:	0f 85 58 07 00 00    	jne    f0102602 <mem_init+0x10a5>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101eaa:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101eaf:	0f 85 66 07 00 00    	jne    f010261b <mem_init+0x10be>
	assert(pp2->pp_ref == 0);
f0101eb5:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101eba:	0f 85 74 07 00 00    	jne    f0102634 <mem_init+0x10d7>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101ec0:	83 ec 0c             	sub    $0xc,%esp
f0101ec3:	6a 00                	push   $0x0
f0101ec5:	e8 2e f3 ff ff       	call   f01011f8 <page_alloc>
f0101eca:	83 c4 10             	add    $0x10,%esp
f0101ecd:	85 c0                	test   %eax,%eax
f0101ecf:	0f 84 78 07 00 00    	je     f010264d <mem_init+0x10f0>
f0101ed5:	39 c6                	cmp    %eax,%esi
f0101ed7:	0f 85 70 07 00 00    	jne    f010264d <mem_init+0x10f0>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101edd:	83 ec 08             	sub    $0x8,%esp
f0101ee0:	6a 00                	push   $0x0
f0101ee2:	ff 35 e8 6d 1b f0    	pushl  0xf01b6de8
f0101ee8:	e8 c1 f5 ff ff       	call   f01014ae <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101eed:	a1 e8 6d 1b f0       	mov    0xf01b6de8,%eax
f0101ef2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101ef5:	ba 00 00 00 00       	mov    $0x0,%edx
f0101efa:	e8 34 ef ff ff       	call   f0100e33 <check_va2pa>
f0101eff:	83 c4 10             	add    $0x10,%esp
f0101f02:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f05:	0f 85 5b 07 00 00    	jne    f0102666 <mem_init+0x1109>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f0b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f10:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f13:	e8 1b ef ff ff       	call   f0100e33 <check_va2pa>
f0101f18:	89 da                	mov    %ebx,%edx
f0101f1a:	2b 15 ec 6d 1b f0    	sub    0xf01b6dec,%edx
f0101f20:	c1 fa 03             	sar    $0x3,%edx
f0101f23:	c1 e2 0c             	shl    $0xc,%edx
f0101f26:	39 d0                	cmp    %edx,%eax
f0101f28:	0f 85 51 07 00 00    	jne    f010267f <mem_init+0x1122>
	assert(pp1->pp_ref == 1);
f0101f2e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f33:	0f 85 5f 07 00 00    	jne    f0102698 <mem_init+0x113b>
	assert(pp2->pp_ref == 0);
f0101f39:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f3e:	0f 85 6d 07 00 00    	jne    f01026b1 <mem_init+0x1154>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101f44:	6a 00                	push   $0x0
f0101f46:	68 00 10 00 00       	push   $0x1000
f0101f4b:	53                   	push   %ebx
f0101f4c:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f4f:	e8 a2 f5 ff ff       	call   f01014f6 <page_insert>
f0101f54:	83 c4 10             	add    $0x10,%esp
f0101f57:	85 c0                	test   %eax,%eax
f0101f59:	0f 85 6b 07 00 00    	jne    f01026ca <mem_init+0x116d>
	assert(pp1->pp_ref);
f0101f5f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101f64:	0f 84 79 07 00 00    	je     f01026e3 <mem_init+0x1186>
	assert(pp1->pp_link == NULL);
f0101f6a:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101f6d:	0f 85 89 07 00 00    	jne    f01026fc <mem_init+0x119f>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101f73:	83 ec 08             	sub    $0x8,%esp
f0101f76:	68 00 10 00 00       	push   $0x1000
f0101f7b:	ff 35 e8 6d 1b f0    	pushl  0xf01b6de8
f0101f81:	e8 28 f5 ff ff       	call   f01014ae <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f86:	a1 e8 6d 1b f0       	mov    0xf01b6de8,%eax
f0101f8b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f8e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f93:	e8 9b ee ff ff       	call   f0100e33 <check_va2pa>
f0101f98:	83 c4 10             	add    $0x10,%esp
f0101f9b:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f9e:	0f 85 71 07 00 00    	jne    f0102715 <mem_init+0x11b8>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101fa4:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fa9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fac:	e8 82 ee ff ff       	call   f0100e33 <check_va2pa>
f0101fb1:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fb4:	0f 85 74 07 00 00    	jne    f010272e <mem_init+0x11d1>
	assert(pp1->pp_ref == 0);
f0101fba:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101fbf:	0f 85 82 07 00 00    	jne    f0102747 <mem_init+0x11ea>
	assert(pp2->pp_ref == 0);
f0101fc5:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101fca:	0f 85 90 07 00 00    	jne    f0102760 <mem_init+0x1203>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101fd0:	83 ec 0c             	sub    $0xc,%esp
f0101fd3:	6a 00                	push   $0x0
f0101fd5:	e8 1e f2 ff ff       	call   f01011f8 <page_alloc>
f0101fda:	83 c4 10             	add    $0x10,%esp
f0101fdd:	85 c0                	test   %eax,%eax
f0101fdf:	0f 84 94 07 00 00    	je     f0102779 <mem_init+0x121c>
f0101fe5:	39 c3                	cmp    %eax,%ebx
f0101fe7:	0f 85 8c 07 00 00    	jne    f0102779 <mem_init+0x121c>

	// should be no free memory
	assert(!page_alloc(0));
f0101fed:	83 ec 0c             	sub    $0xc,%esp
f0101ff0:	6a 00                	push   $0x0
f0101ff2:	e8 01 f2 ff ff       	call   f01011f8 <page_alloc>
f0101ff7:	83 c4 10             	add    $0x10,%esp
f0101ffa:	85 c0                	test   %eax,%eax
f0101ffc:	0f 85 90 07 00 00    	jne    f0102792 <mem_init+0x1235>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102002:	8b 0d e8 6d 1b f0    	mov    0xf01b6de8,%ecx
f0102008:	8b 11                	mov    (%ecx),%edx
f010200a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102010:	89 f8                	mov    %edi,%eax
f0102012:	2b 05 ec 6d 1b f0    	sub    0xf01b6dec,%eax
f0102018:	c1 f8 03             	sar    $0x3,%eax
f010201b:	c1 e0 0c             	shl    $0xc,%eax
f010201e:	39 c2                	cmp    %eax,%edx
f0102020:	0f 85 85 07 00 00    	jne    f01027ab <mem_init+0x124e>
	kern_pgdir[0] = 0;
f0102026:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010202c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102031:	0f 85 8d 07 00 00    	jne    f01027c4 <mem_init+0x1267>
	pp0->pp_ref = 0;
f0102037:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010203d:	83 ec 0c             	sub    $0xc,%esp
f0102040:	57                   	push   %edi
f0102041:	e8 24 f2 ff ff       	call   f010126a <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102046:	83 c4 0c             	add    $0xc,%esp
f0102049:	6a 01                	push   $0x1
f010204b:	68 00 10 40 00       	push   $0x401000
f0102050:	ff 35 e8 6d 1b f0    	pushl  0xf01b6de8
f0102056:	e8 87 f2 ff ff       	call   f01012e2 <pgdir_walk>
f010205b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010205e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102061:	a1 e8 6d 1b f0       	mov    0xf01b6de8,%eax
f0102066:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102069:	8b 50 04             	mov    0x4(%eax),%edx
f010206c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0102072:	a1 e4 6d 1b f0       	mov    0xf01b6de4,%eax
f0102077:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010207a:	89 d1                	mov    %edx,%ecx
f010207c:	c1 e9 0c             	shr    $0xc,%ecx
f010207f:	83 c4 10             	add    $0x10,%esp
f0102082:	39 c1                	cmp    %eax,%ecx
f0102084:	0f 83 53 07 00 00    	jae    f01027dd <mem_init+0x1280>
	assert(ptep == ptep1 + PTX(va));
f010208a:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102090:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0102093:	0f 85 59 07 00 00    	jne    f01027f2 <mem_init+0x1295>
	kern_pgdir[PDX(va)] = 0;
f0102099:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010209c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f01020a3:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
	return (pp - pages) << PGSHIFT;
f01020a9:	89 f8                	mov    %edi,%eax
f01020ab:	2b 05 ec 6d 1b f0    	sub    0xf01b6dec,%eax
f01020b1:	c1 f8 03             	sar    $0x3,%eax
f01020b4:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01020b7:	89 c2                	mov    %eax,%edx
f01020b9:	c1 ea 0c             	shr    $0xc,%edx
f01020bc:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f01020bf:	0f 86 46 07 00 00    	jbe    f010280b <mem_init+0x12ae>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01020c5:	83 ec 04             	sub    $0x4,%esp
f01020c8:	68 00 10 00 00       	push   $0x1000
f01020cd:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01020d2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01020d7:	50                   	push   %eax
f01020d8:	e8 05 2a 00 00       	call   f0104ae2 <memset>
	page_free(pp0);
f01020dd:	89 3c 24             	mov    %edi,(%esp)
f01020e0:	e8 85 f1 ff ff       	call   f010126a <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01020e5:	83 c4 0c             	add    $0xc,%esp
f01020e8:	6a 01                	push   $0x1
f01020ea:	6a 00                	push   $0x0
f01020ec:	ff 35 e8 6d 1b f0    	pushl  0xf01b6de8
f01020f2:	e8 eb f1 ff ff       	call   f01012e2 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f01020f7:	89 fa                	mov    %edi,%edx
f01020f9:	2b 15 ec 6d 1b f0    	sub    0xf01b6dec,%edx
f01020ff:	c1 fa 03             	sar    $0x3,%edx
f0102102:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102105:	89 d0                	mov    %edx,%eax
f0102107:	c1 e8 0c             	shr    $0xc,%eax
f010210a:	83 c4 10             	add    $0x10,%esp
f010210d:	3b 05 e4 6d 1b f0    	cmp    0xf01b6de4,%eax
f0102113:	0f 83 04 07 00 00    	jae    f010281d <mem_init+0x12c0>
	return (void *)(pa + KERNBASE);
f0102119:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010211f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102122:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102128:	f6 00 01             	testb  $0x1,(%eax)
f010212b:	0f 85 fe 06 00 00    	jne    f010282f <mem_init+0x12d2>
f0102131:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0102134:	39 d0                	cmp    %edx,%eax
f0102136:	75 f0                	jne    f0102128 <mem_init+0xbcb>
	kern_pgdir[0] = 0;
f0102138:	a1 e8 6d 1b f0       	mov    0xf01b6de8,%eax
f010213d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102143:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102149:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010214c:	a3 20 61 1b f0       	mov    %eax,0xf01b6120

	// free the pages we took
	page_free(pp0);
f0102151:	83 ec 0c             	sub    $0xc,%esp
f0102154:	57                   	push   %edi
f0102155:	e8 10 f1 ff ff       	call   f010126a <page_free>
	page_free(pp1);
f010215a:	89 1c 24             	mov    %ebx,(%esp)
f010215d:	e8 08 f1 ff ff       	call   f010126a <page_free>
	page_free(pp2);
f0102162:	89 34 24             	mov    %esi,(%esp)
f0102165:	e8 00 f1 ff ff       	call   f010126a <page_free>

	cprintf("check_page() succeeded!\n");
f010216a:	c7 04 24 fe 62 10 f0 	movl   $0xf01062fe,(%esp)
f0102171:	e8 71 15 00 00       	call   f01036e7 <cprintf>
	pginfo_sz = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102176:	a1 e4 6d 1b f0       	mov    0xf01b6de4,%eax
f010217b:	8d 0c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ecx
f0102182:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_region(kern_pgdir, UPAGES, pginfo_sz, PADDR(pages), PTE_U | PTE_P);
f0102188:	a1 ec 6d 1b f0       	mov    0xf01b6dec,%eax
	if ((uint32_t)kva < KERNBASE)
f010218d:	83 c4 10             	add    $0x10,%esp
f0102190:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102195:	0f 86 ad 06 00 00    	jbe    f0102848 <mem_init+0x12eb>
f010219b:	83 ec 08             	sub    $0x8,%esp
f010219e:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01021a0:	05 00 00 00 10       	add    $0x10000000,%eax
f01021a5:	50                   	push   %eax
f01021a6:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01021ab:	a1 e8 6d 1b f0       	mov    0xf01b6de8,%eax
f01021b0:	e8 44 f2 ff ff       	call   f01013f9 <boot_map_region>
	env_sz = ROUNDUP(npages*sizeof(struct Env), PGSIZE);
f01021b5:	a1 e4 6d 1b f0       	mov    0xf01b6de4,%eax
f01021ba:	8d 0c 00             	lea    (%eax,%eax,1),%ecx
f01021bd:	01 c1                	add    %eax,%ecx
f01021bf:	c1 e1 05             	shl    $0x5,%ecx
f01021c2:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f01021c8:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_region(kern_pgdir, UENVS, env_sz, PADDR(envs), PTE_U | PTE_P);
f01021ce:	a1 2c 61 1b f0       	mov    0xf01b612c,%eax
	if ((uint32_t)kva < KERNBASE)
f01021d3:	83 c4 10             	add    $0x10,%esp
f01021d6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021db:	0f 86 7c 06 00 00    	jbe    f010285d <mem_init+0x1300>
f01021e1:	83 ec 08             	sub    $0x8,%esp
f01021e4:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01021e6:	05 00 00 00 10       	add    $0x10000000,%eax
f01021eb:	50                   	push   %eax
f01021ec:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01021f1:	a1 e8 6d 1b f0       	mov    0xf01b6de8,%eax
f01021f6:	e8 fe f1 ff ff       	call   f01013f9 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01021fb:	83 c4 10             	add    $0x10,%esp
f01021fe:	b8 00 30 11 f0       	mov    $0xf0113000,%eax
f0102203:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102208:	0f 86 64 06 00 00    	jbe    f0102872 <mem_init+0x1315>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, 
f010220e:	83 ec 08             	sub    $0x8,%esp
f0102211:	6a 03                	push   $0x3
f0102213:	68 00 30 11 00       	push   $0x113000
f0102218:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010221d:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102222:	a1 e8 6d 1b f0       	mov    0xf01b6de8,%eax
f0102227:	e8 cd f1 ff ff       	call   f01013f9 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 1 << 28, // 2^32 - 0xf0000000
f010222c:	83 c4 08             	add    $0x8,%esp
f010222f:	6a 03                	push   $0x3
f0102231:	6a 00                	push   $0x0
f0102233:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102238:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010223d:	a1 e8 6d 1b f0       	mov    0xf01b6de8,%eax
f0102242:	e8 b2 f1 ff ff       	call   f01013f9 <boot_map_region>
	pgdir = kern_pgdir;
f0102247:	8b 1d e8 6d 1b f0    	mov    0xf01b6de8,%ebx
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010224d:	a1 e4 6d 1b f0       	mov    0xf01b6de4,%eax
f0102252:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102255:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010225c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102261:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102264:	a1 ec 6d 1b f0       	mov    0xf01b6dec,%eax
f0102269:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010226c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	return (physaddr_t)kva - KERNBASE;
f010226f:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f0102275:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i += PGSIZE) 
f0102278:	be 00 00 00 00       	mov    $0x0,%esi
f010227d:	e9 22 06 00 00       	jmp    f01028a4 <mem_init+0x1347>
	assert(nfree == 0);
f0102282:	68 27 62 10 f0       	push   $0xf0106227
f0102287:	68 5f 60 10 f0       	push   $0xf010605f
f010228c:	68 c4 02 00 00       	push   $0x2c4
f0102291:	68 39 60 10 f0       	push   $0xf0106039
f0102296:	e8 ad de ff ff       	call   f0100148 <_panic>
	assert((pp0 = page_alloc(0)));
f010229b:	68 35 61 10 f0       	push   $0xf0106135
f01022a0:	68 5f 60 10 f0       	push   $0xf010605f
f01022a5:	68 23 03 00 00       	push   $0x323
f01022aa:	68 39 60 10 f0       	push   $0xf0106039
f01022af:	e8 94 de ff ff       	call   f0100148 <_panic>
	assert((pp1 = page_alloc(0)));
f01022b4:	68 4b 61 10 f0       	push   $0xf010614b
f01022b9:	68 5f 60 10 f0       	push   $0xf010605f
f01022be:	68 24 03 00 00       	push   $0x324
f01022c3:	68 39 60 10 f0       	push   $0xf0106039
f01022c8:	e8 7b de ff ff       	call   f0100148 <_panic>
	assert((pp2 = page_alloc(0)));
f01022cd:	68 61 61 10 f0       	push   $0xf0106161
f01022d2:	68 5f 60 10 f0       	push   $0xf010605f
f01022d7:	68 25 03 00 00       	push   $0x325
f01022dc:	68 39 60 10 f0       	push   $0xf0106039
f01022e1:	e8 62 de ff ff       	call   f0100148 <_panic>
	assert(pp1 && pp1 != pp0);
f01022e6:	68 77 61 10 f0       	push   $0xf0106177
f01022eb:	68 5f 60 10 f0       	push   $0xf010605f
f01022f0:	68 28 03 00 00       	push   $0x328
f01022f5:	68 39 60 10 f0       	push   $0xf0106039
f01022fa:	e8 49 de ff ff       	call   f0100148 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01022ff:	68 e4 59 10 f0       	push   $0xf01059e4
f0102304:	68 5f 60 10 f0       	push   $0xf010605f
f0102309:	68 29 03 00 00       	push   $0x329
f010230e:	68 39 60 10 f0       	push   $0xf0106039
f0102313:	e8 30 de ff ff       	call   f0100148 <_panic>
	assert(!page_alloc(0));
f0102318:	68 e0 61 10 f0       	push   $0xf01061e0
f010231d:	68 5f 60 10 f0       	push   $0xf010605f
f0102322:	68 30 03 00 00       	push   $0x330
f0102327:	68 39 60 10 f0       	push   $0xf0106039
f010232c:	e8 17 de ff ff       	call   f0100148 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102331:	68 24 5a 10 f0       	push   $0xf0105a24
f0102336:	68 5f 60 10 f0       	push   $0xf010605f
f010233b:	68 33 03 00 00       	push   $0x333
f0102340:	68 39 60 10 f0       	push   $0xf0106039
f0102345:	e8 fe dd ff ff       	call   f0100148 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010234a:	68 5c 5a 10 f0       	push   $0xf0105a5c
f010234f:	68 5f 60 10 f0       	push   $0xf010605f
f0102354:	68 36 03 00 00       	push   $0x336
f0102359:	68 39 60 10 f0       	push   $0xf0106039
f010235e:	e8 e5 dd ff ff       	call   f0100148 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102363:	68 8c 5a 10 f0       	push   $0xf0105a8c
f0102368:	68 5f 60 10 f0       	push   $0xf010605f
f010236d:	68 3a 03 00 00       	push   $0x33a
f0102372:	68 39 60 10 f0       	push   $0xf0106039
f0102377:	e8 cc dd ff ff       	call   f0100148 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010237c:	68 bc 5a 10 f0       	push   $0xf0105abc
f0102381:	68 5f 60 10 f0       	push   $0xf010605f
f0102386:	68 3b 03 00 00       	push   $0x33b
f010238b:	68 39 60 10 f0       	push   $0xf0106039
f0102390:	e8 b3 dd ff ff       	call   f0100148 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102395:	68 e4 5a 10 f0       	push   $0xf0105ae4
f010239a:	68 5f 60 10 f0       	push   $0xf010605f
f010239f:	68 3c 03 00 00       	push   $0x33c
f01023a4:	68 39 60 10 f0       	push   $0xf0106039
f01023a9:	e8 9a dd ff ff       	call   f0100148 <_panic>
	assert(pp1->pp_ref == 1);
f01023ae:	68 32 62 10 f0       	push   $0xf0106232
f01023b3:	68 5f 60 10 f0       	push   $0xf010605f
f01023b8:	68 3d 03 00 00       	push   $0x33d
f01023bd:	68 39 60 10 f0       	push   $0xf0106039
f01023c2:	e8 81 dd ff ff       	call   f0100148 <_panic>
	assert(pp0->pp_ref == 1);
f01023c7:	68 43 62 10 f0       	push   $0xf0106243
f01023cc:	68 5f 60 10 f0       	push   $0xf010605f
f01023d1:	68 3e 03 00 00       	push   $0x33e
f01023d6:	68 39 60 10 f0       	push   $0xf0106039
f01023db:	e8 68 dd ff ff       	call   f0100148 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01023e0:	68 14 5b 10 f0       	push   $0xf0105b14
f01023e5:	68 5f 60 10 f0       	push   $0xf010605f
f01023ea:	68 41 03 00 00       	push   $0x341
f01023ef:	68 39 60 10 f0       	push   $0xf0106039
f01023f4:	e8 4f dd ff ff       	call   f0100148 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023f9:	68 50 5b 10 f0       	push   $0xf0105b50
f01023fe:	68 5f 60 10 f0       	push   $0xf010605f
f0102403:	68 42 03 00 00       	push   $0x342
f0102408:	68 39 60 10 f0       	push   $0xf0106039
f010240d:	e8 36 dd ff ff       	call   f0100148 <_panic>
	assert(pp2->pp_ref == 1);
f0102412:	68 54 62 10 f0       	push   $0xf0106254
f0102417:	68 5f 60 10 f0       	push   $0xf010605f
f010241c:	68 43 03 00 00       	push   $0x343
f0102421:	68 39 60 10 f0       	push   $0xf0106039
f0102426:	e8 1d dd ff ff       	call   f0100148 <_panic>
	assert(!page_alloc(0));
f010242b:	68 e0 61 10 f0       	push   $0xf01061e0
f0102430:	68 5f 60 10 f0       	push   $0xf010605f
f0102435:	68 46 03 00 00       	push   $0x346
f010243a:	68 39 60 10 f0       	push   $0xf0106039
f010243f:	e8 04 dd ff ff       	call   f0100148 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102444:	68 14 5b 10 f0       	push   $0xf0105b14
f0102449:	68 5f 60 10 f0       	push   $0xf010605f
f010244e:	68 49 03 00 00       	push   $0x349
f0102453:	68 39 60 10 f0       	push   $0xf0106039
f0102458:	e8 eb dc ff ff       	call   f0100148 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010245d:	68 50 5b 10 f0       	push   $0xf0105b50
f0102462:	68 5f 60 10 f0       	push   $0xf010605f
f0102467:	68 4a 03 00 00       	push   $0x34a
f010246c:	68 39 60 10 f0       	push   $0xf0106039
f0102471:	e8 d2 dc ff ff       	call   f0100148 <_panic>
	assert(pp2->pp_ref == 1);
f0102476:	68 54 62 10 f0       	push   $0xf0106254
f010247b:	68 5f 60 10 f0       	push   $0xf010605f
f0102480:	68 4b 03 00 00       	push   $0x34b
f0102485:	68 39 60 10 f0       	push   $0xf0106039
f010248a:	e8 b9 dc ff ff       	call   f0100148 <_panic>
	assert(!page_alloc(0));
f010248f:	68 e0 61 10 f0       	push   $0xf01061e0
f0102494:	68 5f 60 10 f0       	push   $0xf010605f
f0102499:	68 4f 03 00 00       	push   $0x34f
f010249e:	68 39 60 10 f0       	push   $0xf0106039
f01024a3:	e8 a0 dc ff ff       	call   f0100148 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024a8:	50                   	push   %eax
f01024a9:	68 b0 56 10 f0       	push   $0xf01056b0
f01024ae:	68 52 03 00 00       	push   $0x352
f01024b3:	68 39 60 10 f0       	push   $0xf0106039
f01024b8:	e8 8b dc ff ff       	call   f0100148 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01024bd:	68 80 5b 10 f0       	push   $0xf0105b80
f01024c2:	68 5f 60 10 f0       	push   $0xf010605f
f01024c7:	68 53 03 00 00       	push   $0x353
f01024cc:	68 39 60 10 f0       	push   $0xf0106039
f01024d1:	e8 72 dc ff ff       	call   f0100148 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01024d6:	68 c0 5b 10 f0       	push   $0xf0105bc0
f01024db:	68 5f 60 10 f0       	push   $0xf010605f
f01024e0:	68 56 03 00 00       	push   $0x356
f01024e5:	68 39 60 10 f0       	push   $0xf0106039
f01024ea:	e8 59 dc ff ff       	call   f0100148 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024ef:	68 50 5b 10 f0       	push   $0xf0105b50
f01024f4:	68 5f 60 10 f0       	push   $0xf010605f
f01024f9:	68 57 03 00 00       	push   $0x357
f01024fe:	68 39 60 10 f0       	push   $0xf0106039
f0102503:	e8 40 dc ff ff       	call   f0100148 <_panic>
	assert(pp2->pp_ref == 1);
f0102508:	68 54 62 10 f0       	push   $0xf0106254
f010250d:	68 5f 60 10 f0       	push   $0xf010605f
f0102512:	68 58 03 00 00       	push   $0x358
f0102517:	68 39 60 10 f0       	push   $0xf0106039
f010251c:	e8 27 dc ff ff       	call   f0100148 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102521:	68 00 5c 10 f0       	push   $0xf0105c00
f0102526:	68 5f 60 10 f0       	push   $0xf010605f
f010252b:	68 59 03 00 00       	push   $0x359
f0102530:	68 39 60 10 f0       	push   $0xf0106039
f0102535:	e8 0e dc ff ff       	call   f0100148 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010253a:	68 65 62 10 f0       	push   $0xf0106265
f010253f:	68 5f 60 10 f0       	push   $0xf010605f
f0102544:	68 5a 03 00 00       	push   $0x35a
f0102549:	68 39 60 10 f0       	push   $0xf0106039
f010254e:	e8 f5 db ff ff       	call   f0100148 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102553:	68 14 5b 10 f0       	push   $0xf0105b14
f0102558:	68 5f 60 10 f0       	push   $0xf010605f
f010255d:	68 5d 03 00 00       	push   $0x35d
f0102562:	68 39 60 10 f0       	push   $0xf0106039
f0102567:	e8 dc db ff ff       	call   f0100148 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010256c:	68 34 5c 10 f0       	push   $0xf0105c34
f0102571:	68 5f 60 10 f0       	push   $0xf010605f
f0102576:	68 5e 03 00 00       	push   $0x35e
f010257b:	68 39 60 10 f0       	push   $0xf0106039
f0102580:	e8 c3 db ff ff       	call   f0100148 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102585:	68 68 5c 10 f0       	push   $0xf0105c68
f010258a:	68 5f 60 10 f0       	push   $0xf010605f
f010258f:	68 5f 03 00 00       	push   $0x35f
f0102594:	68 39 60 10 f0       	push   $0xf0106039
f0102599:	e8 aa db ff ff       	call   f0100148 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010259e:	68 a0 5c 10 f0       	push   $0xf0105ca0
f01025a3:	68 5f 60 10 f0       	push   $0xf010605f
f01025a8:	68 62 03 00 00       	push   $0x362
f01025ad:	68 39 60 10 f0       	push   $0xf0106039
f01025b2:	e8 91 db ff ff       	call   f0100148 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01025b7:	68 d8 5c 10 f0       	push   $0xf0105cd8
f01025bc:	68 5f 60 10 f0       	push   $0xf010605f
f01025c1:	68 65 03 00 00       	push   $0x365
f01025c6:	68 39 60 10 f0       	push   $0xf0106039
f01025cb:	e8 78 db ff ff       	call   f0100148 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01025d0:	68 68 5c 10 f0       	push   $0xf0105c68
f01025d5:	68 5f 60 10 f0       	push   $0xf010605f
f01025da:	68 66 03 00 00       	push   $0x366
f01025df:	68 39 60 10 f0       	push   $0xf0106039
f01025e4:	e8 5f db ff ff       	call   f0100148 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01025e9:	68 14 5d 10 f0       	push   $0xf0105d14
f01025ee:	68 5f 60 10 f0       	push   $0xf010605f
f01025f3:	68 69 03 00 00       	push   $0x369
f01025f8:	68 39 60 10 f0       	push   $0xf0106039
f01025fd:	e8 46 db ff ff       	call   f0100148 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102602:	68 40 5d 10 f0       	push   $0xf0105d40
f0102607:	68 5f 60 10 f0       	push   $0xf010605f
f010260c:	68 6a 03 00 00       	push   $0x36a
f0102611:	68 39 60 10 f0       	push   $0xf0106039
f0102616:	e8 2d db ff ff       	call   f0100148 <_panic>
	assert(pp1->pp_ref == 2);
f010261b:	68 7b 62 10 f0       	push   $0xf010627b
f0102620:	68 5f 60 10 f0       	push   $0xf010605f
f0102625:	68 6c 03 00 00       	push   $0x36c
f010262a:	68 39 60 10 f0       	push   $0xf0106039
f010262f:	e8 14 db ff ff       	call   f0100148 <_panic>
	assert(pp2->pp_ref == 0);
f0102634:	68 8c 62 10 f0       	push   $0xf010628c
f0102639:	68 5f 60 10 f0       	push   $0xf010605f
f010263e:	68 6d 03 00 00       	push   $0x36d
f0102643:	68 39 60 10 f0       	push   $0xf0106039
f0102648:	e8 fb da ff ff       	call   f0100148 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f010264d:	68 70 5d 10 f0       	push   $0xf0105d70
f0102652:	68 5f 60 10 f0       	push   $0xf010605f
f0102657:	68 70 03 00 00       	push   $0x370
f010265c:	68 39 60 10 f0       	push   $0xf0106039
f0102661:	e8 e2 da ff ff       	call   f0100148 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102666:	68 94 5d 10 f0       	push   $0xf0105d94
f010266b:	68 5f 60 10 f0       	push   $0xf010605f
f0102670:	68 74 03 00 00       	push   $0x374
f0102675:	68 39 60 10 f0       	push   $0xf0106039
f010267a:	e8 c9 da ff ff       	call   f0100148 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010267f:	68 40 5d 10 f0       	push   $0xf0105d40
f0102684:	68 5f 60 10 f0       	push   $0xf010605f
f0102689:	68 75 03 00 00       	push   $0x375
f010268e:	68 39 60 10 f0       	push   $0xf0106039
f0102693:	e8 b0 da ff ff       	call   f0100148 <_panic>
	assert(pp1->pp_ref == 1);
f0102698:	68 32 62 10 f0       	push   $0xf0106232
f010269d:	68 5f 60 10 f0       	push   $0xf010605f
f01026a2:	68 76 03 00 00       	push   $0x376
f01026a7:	68 39 60 10 f0       	push   $0xf0106039
f01026ac:	e8 97 da ff ff       	call   f0100148 <_panic>
	assert(pp2->pp_ref == 0);
f01026b1:	68 8c 62 10 f0       	push   $0xf010628c
f01026b6:	68 5f 60 10 f0       	push   $0xf010605f
f01026bb:	68 77 03 00 00       	push   $0x377
f01026c0:	68 39 60 10 f0       	push   $0xf0106039
f01026c5:	e8 7e da ff ff       	call   f0100148 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01026ca:	68 b8 5d 10 f0       	push   $0xf0105db8
f01026cf:	68 5f 60 10 f0       	push   $0xf010605f
f01026d4:	68 7a 03 00 00       	push   $0x37a
f01026d9:	68 39 60 10 f0       	push   $0xf0106039
f01026de:	e8 65 da ff ff       	call   f0100148 <_panic>
	assert(pp1->pp_ref);
f01026e3:	68 9d 62 10 f0       	push   $0xf010629d
f01026e8:	68 5f 60 10 f0       	push   $0xf010605f
f01026ed:	68 7b 03 00 00       	push   $0x37b
f01026f2:	68 39 60 10 f0       	push   $0xf0106039
f01026f7:	e8 4c da ff ff       	call   f0100148 <_panic>
	assert(pp1->pp_link == NULL);
f01026fc:	68 a9 62 10 f0       	push   $0xf01062a9
f0102701:	68 5f 60 10 f0       	push   $0xf010605f
f0102706:	68 7c 03 00 00       	push   $0x37c
f010270b:	68 39 60 10 f0       	push   $0xf0106039
f0102710:	e8 33 da ff ff       	call   f0100148 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102715:	68 94 5d 10 f0       	push   $0xf0105d94
f010271a:	68 5f 60 10 f0       	push   $0xf010605f
f010271f:	68 80 03 00 00       	push   $0x380
f0102724:	68 39 60 10 f0       	push   $0xf0106039
f0102729:	e8 1a da ff ff       	call   f0100148 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010272e:	68 f0 5d 10 f0       	push   $0xf0105df0
f0102733:	68 5f 60 10 f0       	push   $0xf010605f
f0102738:	68 81 03 00 00       	push   $0x381
f010273d:	68 39 60 10 f0       	push   $0xf0106039
f0102742:	e8 01 da ff ff       	call   f0100148 <_panic>
	assert(pp1->pp_ref == 0);
f0102747:	68 be 62 10 f0       	push   $0xf01062be
f010274c:	68 5f 60 10 f0       	push   $0xf010605f
f0102751:	68 82 03 00 00       	push   $0x382
f0102756:	68 39 60 10 f0       	push   $0xf0106039
f010275b:	e8 e8 d9 ff ff       	call   f0100148 <_panic>
	assert(pp2->pp_ref == 0);
f0102760:	68 8c 62 10 f0       	push   $0xf010628c
f0102765:	68 5f 60 10 f0       	push   $0xf010605f
f010276a:	68 83 03 00 00       	push   $0x383
f010276f:	68 39 60 10 f0       	push   $0xf0106039
f0102774:	e8 cf d9 ff ff       	call   f0100148 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102779:	68 18 5e 10 f0       	push   $0xf0105e18
f010277e:	68 5f 60 10 f0       	push   $0xf010605f
f0102783:	68 86 03 00 00       	push   $0x386
f0102788:	68 39 60 10 f0       	push   $0xf0106039
f010278d:	e8 b6 d9 ff ff       	call   f0100148 <_panic>
	assert(!page_alloc(0));
f0102792:	68 e0 61 10 f0       	push   $0xf01061e0
f0102797:	68 5f 60 10 f0       	push   $0xf010605f
f010279c:	68 89 03 00 00       	push   $0x389
f01027a1:	68 39 60 10 f0       	push   $0xf0106039
f01027a6:	e8 9d d9 ff ff       	call   f0100148 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01027ab:	68 bc 5a 10 f0       	push   $0xf0105abc
f01027b0:	68 5f 60 10 f0       	push   $0xf010605f
f01027b5:	68 8c 03 00 00       	push   $0x38c
f01027ba:	68 39 60 10 f0       	push   $0xf0106039
f01027bf:	e8 84 d9 ff ff       	call   f0100148 <_panic>
	assert(pp0->pp_ref == 1);
f01027c4:	68 43 62 10 f0       	push   $0xf0106243
f01027c9:	68 5f 60 10 f0       	push   $0xf010605f
f01027ce:	68 8e 03 00 00       	push   $0x38e
f01027d3:	68 39 60 10 f0       	push   $0xf0106039
f01027d8:	e8 6b d9 ff ff       	call   f0100148 <_panic>
f01027dd:	52                   	push   %edx
f01027de:	68 b0 56 10 f0       	push   $0xf01056b0
f01027e3:	68 95 03 00 00       	push   $0x395
f01027e8:	68 39 60 10 f0       	push   $0xf0106039
f01027ed:	e8 56 d9 ff ff       	call   f0100148 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01027f2:	68 cf 62 10 f0       	push   $0xf01062cf
f01027f7:	68 5f 60 10 f0       	push   $0xf010605f
f01027fc:	68 96 03 00 00       	push   $0x396
f0102801:	68 39 60 10 f0       	push   $0xf0106039
f0102806:	e8 3d d9 ff ff       	call   f0100148 <_panic>
f010280b:	50                   	push   %eax
f010280c:	68 b0 56 10 f0       	push   $0xf01056b0
f0102811:	6a 56                	push   $0x56
f0102813:	68 45 60 10 f0       	push   $0xf0106045
f0102818:	e8 2b d9 ff ff       	call   f0100148 <_panic>
f010281d:	52                   	push   %edx
f010281e:	68 b0 56 10 f0       	push   $0xf01056b0
f0102823:	6a 56                	push   $0x56
f0102825:	68 45 60 10 f0       	push   $0xf0106045
f010282a:	e8 19 d9 ff ff       	call   f0100148 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f010282f:	68 e7 62 10 f0       	push   $0xf01062e7
f0102834:	68 5f 60 10 f0       	push   $0xf010605f
f0102839:	68 a0 03 00 00       	push   $0x3a0
f010283e:	68 39 60 10 f0       	push   $0xf0106039
f0102843:	e8 00 d9 ff ff       	call   f0100148 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102848:	50                   	push   %eax
f0102849:	68 64 59 10 f0       	push   $0xf0105964
f010284e:	68 bb 00 00 00       	push   $0xbb
f0102853:	68 39 60 10 f0       	push   $0xf0106039
f0102858:	e8 eb d8 ff ff       	call   f0100148 <_panic>
f010285d:	50                   	push   %eax
f010285e:	68 64 59 10 f0       	push   $0xf0105964
f0102863:	68 c5 00 00 00       	push   $0xc5
f0102868:	68 39 60 10 f0       	push   $0xf0106039
f010286d:	e8 d6 d8 ff ff       	call   f0100148 <_panic>
f0102872:	50                   	push   %eax
f0102873:	68 64 59 10 f0       	push   $0xf0105964
f0102878:	68 d2 00 00 00       	push   $0xd2
f010287d:	68 39 60 10 f0       	push   $0xf0106039
f0102882:	e8 c1 d8 ff ff       	call   f0100148 <_panic>
f0102887:	ff 75 c8             	pushl  -0x38(%ebp)
f010288a:	68 64 59 10 f0       	push   $0xf0105964
f010288f:	68 dc 02 00 00       	push   $0x2dc
f0102894:	68 39 60 10 f0       	push   $0xf0106039
f0102899:	e8 aa d8 ff ff       	call   f0100148 <_panic>
	for (i = 0; i < n; i += PGSIZE) 
f010289e:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01028a4:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f01028a7:	76 36                	jbe    f01028df <mem_init+0x1382>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01028a9:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f01028af:	89 d8                	mov    %ebx,%eax
f01028b1:	e8 7d e5 ff ff       	call   f0100e33 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01028b6:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01028bd:	76 c8                	jbe    f0102887 <mem_init+0x132a>
f01028bf:	8d 14 3e             	lea    (%esi,%edi,1),%edx
f01028c2:	39 c2                	cmp    %eax,%edx
f01028c4:	74 d8                	je     f010289e <mem_init+0x1341>
f01028c6:	68 3c 5e 10 f0       	push   $0xf0105e3c
f01028cb:	68 5f 60 10 f0       	push   $0xf010605f
f01028d0:	68 dc 02 00 00       	push   $0x2dc
f01028d5:	68 39 60 10 f0       	push   $0xf0106039
f01028da:	e8 69 d8 ff ff       	call   f0100148 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01028df:	a1 2c 61 1b f0       	mov    0xf01b612c,%eax
f01028e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01028e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01028ea:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f01028ef:	8d b8 00 00 40 21    	lea    0x21400000(%eax),%edi
f01028f5:	89 f2                	mov    %esi,%edx
f01028f7:	89 d8                	mov    %ebx,%eax
f01028f9:	e8 35 e5 ff ff       	call   f0100e33 <check_va2pa>
f01028fe:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102905:	76 3d                	jbe    f0102944 <mem_init+0x13e7>
f0102907:	8d 14 37             	lea    (%edi,%esi,1),%edx
f010290a:	39 c2                	cmp    %eax,%edx
f010290c:	75 4d                	jne    f010295b <mem_init+0x13fe>
f010290e:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < n; i += PGSIZE)
f0102914:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f010291a:	75 d9                	jne    f01028f5 <mem_init+0x1398>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010291c:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010291f:	c1 e7 0c             	shl    $0xc,%edi
f0102922:	be 00 00 00 00       	mov    $0x0,%esi
f0102927:	39 fe                	cmp    %edi,%esi
f0102929:	73 62                	jae    f010298d <mem_init+0x1430>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010292b:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102931:	89 d8                	mov    %ebx,%eax
f0102933:	e8 fb e4 ff ff       	call   f0100e33 <check_va2pa>
f0102938:	39 c6                	cmp    %eax,%esi
f010293a:	75 38                	jne    f0102974 <mem_init+0x1417>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010293c:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102942:	eb e3                	jmp    f0102927 <mem_init+0x13ca>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102944:	ff 75 d0             	pushl  -0x30(%ebp)
f0102947:	68 64 59 10 f0       	push   $0xf0105964
f010294c:	68 e1 02 00 00       	push   $0x2e1
f0102951:	68 39 60 10 f0       	push   $0xf0106039
f0102956:	e8 ed d7 ff ff       	call   f0100148 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010295b:	68 70 5e 10 f0       	push   $0xf0105e70
f0102960:	68 5f 60 10 f0       	push   $0xf010605f
f0102965:	68 e1 02 00 00       	push   $0x2e1
f010296a:	68 39 60 10 f0       	push   $0xf0106039
f010296f:	e8 d4 d7 ff ff       	call   f0100148 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102974:	68 a4 5e 10 f0       	push   $0xf0105ea4
f0102979:	68 5f 60 10 f0       	push   $0xf010605f
f010297e:	68 e5 02 00 00       	push   $0x2e5
f0102983:	68 39 60 10 f0       	push   $0xf0106039
f0102988:	e8 bb d7 ff ff       	call   f0100148 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010298d:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102992:	b8 00 30 11 f0       	mov    $0xf0113000,%eax
f0102997:	8d b8 00 80 00 20    	lea    0x20008000(%eax),%edi
f010299d:	89 f2                	mov    %esi,%edx
f010299f:	89 d8                	mov    %ebx,%eax
f01029a1:	e8 8d e4 ff ff       	call   f0100e33 <check_va2pa>
f01029a6:	8d 14 37             	lea    (%edi,%esi,1),%edx
f01029a9:	39 d0                	cmp    %edx,%eax
f01029ab:	75 26                	jne    f01029d3 <mem_init+0x1476>
f01029ad:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < KSTKSIZE; i += PGSIZE) {
f01029b3:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01029b9:	75 e2                	jne    f010299d <mem_init+0x1440>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01029bb:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01029c0:	89 d8                	mov    %ebx,%eax
f01029c2:	e8 6c e4 ff ff       	call   f0100e33 <check_va2pa>
f01029c7:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029ca:	75 20                	jne    f01029ec <mem_init+0x148f>
	for (i = 0; i < NPDENTRIES; i++) {
f01029cc:	b8 00 00 00 00       	mov    $0x0,%eax
f01029d1:	eb 59                	jmp    f0102a2c <mem_init+0x14cf>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01029d3:	68 cc 5e 10 f0       	push   $0xf0105ecc
f01029d8:	68 5f 60 10 f0       	push   $0xf010605f
f01029dd:	68 e9 02 00 00       	push   $0x2e9
f01029e2:	68 39 60 10 f0       	push   $0xf0106039
f01029e7:	e8 5c d7 ff ff       	call   f0100148 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01029ec:	68 14 5f 10 f0       	push   $0xf0105f14
f01029f1:	68 5f 60 10 f0       	push   $0xf010605f
f01029f6:	68 eb 02 00 00       	push   $0x2eb
f01029fb:	68 39 60 10 f0       	push   $0xf0106039
f0102a00:	e8 43 d7 ff ff       	call   f0100148 <_panic>
			assert(pgdir[i] & PTE_P);
f0102a05:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102a09:	74 47                	je     f0102a52 <mem_init+0x14f5>
	for (i = 0; i < NPDENTRIES; i++) {
f0102a0b:	40                   	inc    %eax
f0102a0c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102a11:	0f 87 93 00 00 00    	ja     f0102aaa <mem_init+0x154d>
		switch (i) {
f0102a17:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102a1c:	72 0e                	jb     f0102a2c <mem_init+0x14cf>
f0102a1e:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102a23:	76 e0                	jbe    f0102a05 <mem_init+0x14a8>
f0102a25:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102a2a:	74 d9                	je     f0102a05 <mem_init+0x14a8>
			if (i >= PDX(KERNBASE)) {
f0102a2c:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102a31:	77 38                	ja     f0102a6b <mem_init+0x150e>
				assert(pgdir[i] == 0);
f0102a33:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102a37:	74 d2                	je     f0102a0b <mem_init+0x14ae>
f0102a39:	68 39 63 10 f0       	push   $0xf0106339
f0102a3e:	68 5f 60 10 f0       	push   $0xf010605f
f0102a43:	68 fb 02 00 00       	push   $0x2fb
f0102a48:	68 39 60 10 f0       	push   $0xf0106039
f0102a4d:	e8 f6 d6 ff ff       	call   f0100148 <_panic>
			assert(pgdir[i] & PTE_P);
f0102a52:	68 17 63 10 f0       	push   $0xf0106317
f0102a57:	68 5f 60 10 f0       	push   $0xf010605f
f0102a5c:	68 f4 02 00 00       	push   $0x2f4
f0102a61:	68 39 60 10 f0       	push   $0xf0106039
f0102a66:	e8 dd d6 ff ff       	call   f0100148 <_panic>
				assert(pgdir[i] & PTE_P);
f0102a6b:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102a6e:	f6 c2 01             	test   $0x1,%dl
f0102a71:	74 1e                	je     f0102a91 <mem_init+0x1534>
				assert(pgdir[i] & PTE_W);
f0102a73:	f6 c2 02             	test   $0x2,%dl
f0102a76:	75 93                	jne    f0102a0b <mem_init+0x14ae>
f0102a78:	68 28 63 10 f0       	push   $0xf0106328
f0102a7d:	68 5f 60 10 f0       	push   $0xf010605f
f0102a82:	68 f9 02 00 00       	push   $0x2f9
f0102a87:	68 39 60 10 f0       	push   $0xf0106039
f0102a8c:	e8 b7 d6 ff ff       	call   f0100148 <_panic>
				assert(pgdir[i] & PTE_P);
f0102a91:	68 17 63 10 f0       	push   $0xf0106317
f0102a96:	68 5f 60 10 f0       	push   $0xf010605f
f0102a9b:	68 f8 02 00 00       	push   $0x2f8
f0102aa0:	68 39 60 10 f0       	push   $0xf0106039
f0102aa5:	e8 9e d6 ff ff       	call   f0100148 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102aaa:	83 ec 0c             	sub    $0xc,%esp
f0102aad:	68 44 5f 10 f0       	push   $0xf0105f44
f0102ab2:	e8 30 0c 00 00       	call   f01036e7 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102ab7:	a1 e8 6d 1b f0       	mov    0xf01b6de8,%eax
	if ((uint32_t)kva < KERNBASE)
f0102abc:	83 c4 10             	add    $0x10,%esp
f0102abf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ac4:	0f 86 fe 01 00 00    	jbe    f0102cc8 <mem_init+0x176b>
	return (physaddr_t)kva - KERNBASE;
f0102aca:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102acf:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102ad2:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ad7:	e8 b6 e3 ff ff       	call   f0100e92 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102adc:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102adf:	83 e0 f3             	and    $0xfffffff3,%eax
f0102ae2:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102ae7:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102aea:	83 ec 0c             	sub    $0xc,%esp
f0102aed:	6a 00                	push   $0x0
f0102aef:	e8 04 e7 ff ff       	call   f01011f8 <page_alloc>
f0102af4:	89 c3                	mov    %eax,%ebx
f0102af6:	83 c4 10             	add    $0x10,%esp
f0102af9:	85 c0                	test   %eax,%eax
f0102afb:	0f 84 dc 01 00 00    	je     f0102cdd <mem_init+0x1780>
	assert((pp1 = page_alloc(0)));
f0102b01:	83 ec 0c             	sub    $0xc,%esp
f0102b04:	6a 00                	push   $0x0
f0102b06:	e8 ed e6 ff ff       	call   f01011f8 <page_alloc>
f0102b0b:	89 c7                	mov    %eax,%edi
f0102b0d:	83 c4 10             	add    $0x10,%esp
f0102b10:	85 c0                	test   %eax,%eax
f0102b12:	0f 84 de 01 00 00    	je     f0102cf6 <mem_init+0x1799>
	assert((pp2 = page_alloc(0)));
f0102b18:	83 ec 0c             	sub    $0xc,%esp
f0102b1b:	6a 00                	push   $0x0
f0102b1d:	e8 d6 e6 ff ff       	call   f01011f8 <page_alloc>
f0102b22:	89 c6                	mov    %eax,%esi
f0102b24:	83 c4 10             	add    $0x10,%esp
f0102b27:	85 c0                	test   %eax,%eax
f0102b29:	0f 84 e0 01 00 00    	je     f0102d0f <mem_init+0x17b2>
	page_free(pp0);
f0102b2f:	83 ec 0c             	sub    $0xc,%esp
f0102b32:	53                   	push   %ebx
f0102b33:	e8 32 e7 ff ff       	call   f010126a <page_free>
	return (pp - pages) << PGSHIFT;
f0102b38:	89 f8                	mov    %edi,%eax
f0102b3a:	2b 05 ec 6d 1b f0    	sub    0xf01b6dec,%eax
f0102b40:	c1 f8 03             	sar    $0x3,%eax
f0102b43:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102b46:	89 c2                	mov    %eax,%edx
f0102b48:	c1 ea 0c             	shr    $0xc,%edx
f0102b4b:	83 c4 10             	add    $0x10,%esp
f0102b4e:	3b 15 e4 6d 1b f0    	cmp    0xf01b6de4,%edx
f0102b54:	0f 83 ce 01 00 00    	jae    f0102d28 <mem_init+0x17cb>
	memset(page2kva(pp1), 1, PGSIZE);
f0102b5a:	83 ec 04             	sub    $0x4,%esp
f0102b5d:	68 00 10 00 00       	push   $0x1000
f0102b62:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102b64:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b69:	50                   	push   %eax
f0102b6a:	e8 73 1f 00 00       	call   f0104ae2 <memset>
	return (pp - pages) << PGSHIFT;
f0102b6f:	89 f0                	mov    %esi,%eax
f0102b71:	2b 05 ec 6d 1b f0    	sub    0xf01b6dec,%eax
f0102b77:	c1 f8 03             	sar    $0x3,%eax
f0102b7a:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102b7d:	89 c2                	mov    %eax,%edx
f0102b7f:	c1 ea 0c             	shr    $0xc,%edx
f0102b82:	83 c4 10             	add    $0x10,%esp
f0102b85:	3b 15 e4 6d 1b f0    	cmp    0xf01b6de4,%edx
f0102b8b:	0f 83 a9 01 00 00    	jae    f0102d3a <mem_init+0x17dd>
	memset(page2kva(pp2), 2, PGSIZE);
f0102b91:	83 ec 04             	sub    $0x4,%esp
f0102b94:	68 00 10 00 00       	push   $0x1000
f0102b99:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102b9b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102ba0:	50                   	push   %eax
f0102ba1:	e8 3c 1f 00 00       	call   f0104ae2 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102ba6:	6a 02                	push   $0x2
f0102ba8:	68 00 10 00 00       	push   $0x1000
f0102bad:	57                   	push   %edi
f0102bae:	ff 35 e8 6d 1b f0    	pushl  0xf01b6de8
f0102bb4:	e8 3d e9 ff ff       	call   f01014f6 <page_insert>
	assert(pp1->pp_ref == 1);
f0102bb9:	83 c4 20             	add    $0x20,%esp
f0102bbc:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102bc1:	0f 85 85 01 00 00    	jne    f0102d4c <mem_init+0x17ef>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102bc7:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102bce:	01 01 01 
f0102bd1:	0f 85 8e 01 00 00    	jne    f0102d65 <mem_init+0x1808>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102bd7:	6a 02                	push   $0x2
f0102bd9:	68 00 10 00 00       	push   $0x1000
f0102bde:	56                   	push   %esi
f0102bdf:	ff 35 e8 6d 1b f0    	pushl  0xf01b6de8
f0102be5:	e8 0c e9 ff ff       	call   f01014f6 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102bea:	83 c4 10             	add    $0x10,%esp
f0102bed:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102bf4:	02 02 02 
f0102bf7:	0f 85 81 01 00 00    	jne    f0102d7e <mem_init+0x1821>
	assert(pp2->pp_ref == 1);
f0102bfd:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102c02:	0f 85 8f 01 00 00    	jne    f0102d97 <mem_init+0x183a>
	assert(pp1->pp_ref == 0);
f0102c08:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102c0d:	0f 85 9d 01 00 00    	jne    f0102db0 <mem_init+0x1853>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102c13:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102c1a:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102c1d:	89 f0                	mov    %esi,%eax
f0102c1f:	2b 05 ec 6d 1b f0    	sub    0xf01b6dec,%eax
f0102c25:	c1 f8 03             	sar    $0x3,%eax
f0102c28:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102c2b:	89 c2                	mov    %eax,%edx
f0102c2d:	c1 ea 0c             	shr    $0xc,%edx
f0102c30:	3b 15 e4 6d 1b f0    	cmp    0xf01b6de4,%edx
f0102c36:	0f 83 8d 01 00 00    	jae    f0102dc9 <mem_init+0x186c>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c3c:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102c43:	03 03 03 
f0102c46:	0f 85 8f 01 00 00    	jne    f0102ddb <mem_init+0x187e>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c4c:	83 ec 08             	sub    $0x8,%esp
f0102c4f:	68 00 10 00 00       	push   $0x1000
f0102c54:	ff 35 e8 6d 1b f0    	pushl  0xf01b6de8
f0102c5a:	e8 4f e8 ff ff       	call   f01014ae <page_remove>
	assert(pp2->pp_ref == 0);
f0102c5f:	83 c4 10             	add    $0x10,%esp
f0102c62:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102c67:	0f 85 87 01 00 00    	jne    f0102df4 <mem_init+0x1897>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c6d:	8b 0d e8 6d 1b f0    	mov    0xf01b6de8,%ecx
f0102c73:	8b 11                	mov    (%ecx),%edx
f0102c75:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102c7b:	89 d8                	mov    %ebx,%eax
f0102c7d:	2b 05 ec 6d 1b f0    	sub    0xf01b6dec,%eax
f0102c83:	c1 f8 03             	sar    $0x3,%eax
f0102c86:	c1 e0 0c             	shl    $0xc,%eax
f0102c89:	39 c2                	cmp    %eax,%edx
f0102c8b:	0f 85 7c 01 00 00    	jne    f0102e0d <mem_init+0x18b0>
	kern_pgdir[0] = 0;
f0102c91:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102c97:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102c9c:	0f 85 84 01 00 00    	jne    f0102e26 <mem_init+0x18c9>
	pp0->pp_ref = 0;
f0102ca2:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102ca8:	83 ec 0c             	sub    $0xc,%esp
f0102cab:	53                   	push   %ebx
f0102cac:	e8 b9 e5 ff ff       	call   f010126a <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102cb1:	c7 04 24 d8 5f 10 f0 	movl   $0xf0105fd8,(%esp)
f0102cb8:	e8 2a 0a 00 00       	call   f01036e7 <cprintf>
}
f0102cbd:	83 c4 10             	add    $0x10,%esp
f0102cc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102cc3:	5b                   	pop    %ebx
f0102cc4:	5e                   	pop    %esi
f0102cc5:	5f                   	pop    %edi
f0102cc6:	5d                   	pop    %ebp
f0102cc7:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cc8:	50                   	push   %eax
f0102cc9:	68 64 59 10 f0       	push   $0xf0105964
f0102cce:	68 e8 00 00 00       	push   $0xe8
f0102cd3:	68 39 60 10 f0       	push   $0xf0106039
f0102cd8:	e8 6b d4 ff ff       	call   f0100148 <_panic>
	assert((pp0 = page_alloc(0)));
f0102cdd:	68 35 61 10 f0       	push   $0xf0106135
f0102ce2:	68 5f 60 10 f0       	push   $0xf010605f
f0102ce7:	68 bb 03 00 00       	push   $0x3bb
f0102cec:	68 39 60 10 f0       	push   $0xf0106039
f0102cf1:	e8 52 d4 ff ff       	call   f0100148 <_panic>
	assert((pp1 = page_alloc(0)));
f0102cf6:	68 4b 61 10 f0       	push   $0xf010614b
f0102cfb:	68 5f 60 10 f0       	push   $0xf010605f
f0102d00:	68 bc 03 00 00       	push   $0x3bc
f0102d05:	68 39 60 10 f0       	push   $0xf0106039
f0102d0a:	e8 39 d4 ff ff       	call   f0100148 <_panic>
	assert((pp2 = page_alloc(0)));
f0102d0f:	68 61 61 10 f0       	push   $0xf0106161
f0102d14:	68 5f 60 10 f0       	push   $0xf010605f
f0102d19:	68 bd 03 00 00       	push   $0x3bd
f0102d1e:	68 39 60 10 f0       	push   $0xf0106039
f0102d23:	e8 20 d4 ff ff       	call   f0100148 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d28:	50                   	push   %eax
f0102d29:	68 b0 56 10 f0       	push   $0xf01056b0
f0102d2e:	6a 56                	push   $0x56
f0102d30:	68 45 60 10 f0       	push   $0xf0106045
f0102d35:	e8 0e d4 ff ff       	call   f0100148 <_panic>
f0102d3a:	50                   	push   %eax
f0102d3b:	68 b0 56 10 f0       	push   $0xf01056b0
f0102d40:	6a 56                	push   $0x56
f0102d42:	68 45 60 10 f0       	push   $0xf0106045
f0102d47:	e8 fc d3 ff ff       	call   f0100148 <_panic>
	assert(pp1->pp_ref == 1);
f0102d4c:	68 32 62 10 f0       	push   $0xf0106232
f0102d51:	68 5f 60 10 f0       	push   $0xf010605f
f0102d56:	68 c2 03 00 00       	push   $0x3c2
f0102d5b:	68 39 60 10 f0       	push   $0xf0106039
f0102d60:	e8 e3 d3 ff ff       	call   f0100148 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102d65:	68 64 5f 10 f0       	push   $0xf0105f64
f0102d6a:	68 5f 60 10 f0       	push   $0xf010605f
f0102d6f:	68 c3 03 00 00       	push   $0x3c3
f0102d74:	68 39 60 10 f0       	push   $0xf0106039
f0102d79:	e8 ca d3 ff ff       	call   f0100148 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102d7e:	68 88 5f 10 f0       	push   $0xf0105f88
f0102d83:	68 5f 60 10 f0       	push   $0xf010605f
f0102d88:	68 c5 03 00 00       	push   $0x3c5
f0102d8d:	68 39 60 10 f0       	push   $0xf0106039
f0102d92:	e8 b1 d3 ff ff       	call   f0100148 <_panic>
	assert(pp2->pp_ref == 1);
f0102d97:	68 54 62 10 f0       	push   $0xf0106254
f0102d9c:	68 5f 60 10 f0       	push   $0xf010605f
f0102da1:	68 c6 03 00 00       	push   $0x3c6
f0102da6:	68 39 60 10 f0       	push   $0xf0106039
f0102dab:	e8 98 d3 ff ff       	call   f0100148 <_panic>
	assert(pp1->pp_ref == 0);
f0102db0:	68 be 62 10 f0       	push   $0xf01062be
f0102db5:	68 5f 60 10 f0       	push   $0xf010605f
f0102dba:	68 c7 03 00 00       	push   $0x3c7
f0102dbf:	68 39 60 10 f0       	push   $0xf0106039
f0102dc4:	e8 7f d3 ff ff       	call   f0100148 <_panic>
f0102dc9:	50                   	push   %eax
f0102dca:	68 b0 56 10 f0       	push   $0xf01056b0
f0102dcf:	6a 56                	push   $0x56
f0102dd1:	68 45 60 10 f0       	push   $0xf0106045
f0102dd6:	e8 6d d3 ff ff       	call   f0100148 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102ddb:	68 ac 5f 10 f0       	push   $0xf0105fac
f0102de0:	68 5f 60 10 f0       	push   $0xf010605f
f0102de5:	68 c9 03 00 00       	push   $0x3c9
f0102dea:	68 39 60 10 f0       	push   $0xf0106039
f0102def:	e8 54 d3 ff ff       	call   f0100148 <_panic>
	assert(pp2->pp_ref == 0);
f0102df4:	68 8c 62 10 f0       	push   $0xf010628c
f0102df9:	68 5f 60 10 f0       	push   $0xf010605f
f0102dfe:	68 cb 03 00 00       	push   $0x3cb
f0102e03:	68 39 60 10 f0       	push   $0xf0106039
f0102e08:	e8 3b d3 ff ff       	call   f0100148 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e0d:	68 bc 5a 10 f0       	push   $0xf0105abc
f0102e12:	68 5f 60 10 f0       	push   $0xf010605f
f0102e17:	68 ce 03 00 00       	push   $0x3ce
f0102e1c:	68 39 60 10 f0       	push   $0xf0106039
f0102e21:	e8 22 d3 ff ff       	call   f0100148 <_panic>
	assert(pp0->pp_ref == 1);
f0102e26:	68 43 62 10 f0       	push   $0xf0106243
f0102e2b:	68 5f 60 10 f0       	push   $0xf010605f
f0102e30:	68 d0 03 00 00       	push   $0x3d0
f0102e35:	68 39 60 10 f0       	push   $0xf0106039
f0102e3a:	e8 09 d3 ff ff       	call   f0100148 <_panic>

f0102e3f <tlb_invalidate>:
{
f0102e3f:	55                   	push   %ebp
f0102e40:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102e42:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e45:	0f 01 38             	invlpg (%eax)
}
f0102e48:	5d                   	pop    %ebp
f0102e49:	c3                   	ret    

f0102e4a <user_mem_check>:
{
f0102e4a:	55                   	push   %ebp
f0102e4b:	89 e5                	mov    %esp,%ebp
f0102e4d:	57                   	push   %edi
f0102e4e:	56                   	push   %esi
f0102e4f:	53                   	push   %ebx
f0102e50:	83 ec 1c             	sub    $0x1c,%esp
f0102e53:	8b 7d 08             	mov    0x8(%ebp),%edi
	void *l = ROUNDDOWN((void*)va, PGSIZE), *r = ROUNDUP((void*)va + len, PGSIZE);
f0102e56:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e59:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102e5c:	89 c3                	mov    %eax,%ebx
f0102e5e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102e64:	89 c6                	mov    %eax,%esi
f0102e66:	03 75 10             	add    0x10(%ebp),%esi
f0102e69:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
f0102e6f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for (; l < r; l += PGSIZE) {
f0102e75:	eb 1d                	jmp    f0102e94 <user_mem_check+0x4a>
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f0102e77:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102e7a:	72 03                	jb     f0102e7f <user_mem_check+0x35>
		if ((uintptr_t)l >= ULIM) {// Higher than ULIM
f0102e7c:	89 5d e0             	mov    %ebx,-0x20(%ebp)
			user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f0102e7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102e82:	a3 1c 61 1b f0       	mov    %eax,0xf01b611c
			return -E_FAULT;
f0102e87:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102e8c:	eb 59                	jmp    f0102ee7 <user_mem_check+0x9d>
	for (; l < r; l += PGSIZE) {
f0102e8e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e94:	39 f3                	cmp    %esi,%ebx
f0102e96:	73 4a                	jae    f0102ee2 <user_mem_check+0x98>
		if ((uintptr_t)l >= ULIM) {// Higher than ULIM
f0102e98:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0102e9b:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102ea1:	77 d4                	ja     f0102e77 <user_mem_check+0x2d>
		pte_t* pte = pgdir_walk(env->env_pgdir, l, 0);
f0102ea3:	83 ec 04             	sub    $0x4,%esp
f0102ea6:	6a 00                	push   $0x0
f0102ea8:	53                   	push   %ebx
f0102ea9:	ff 77 5c             	pushl  0x5c(%edi)
f0102eac:	e8 31 e4 ff ff       	call   f01012e2 <pgdir_walk>
		if (pte) {
f0102eb1:	83 c4 10             	add    $0x10,%esp
f0102eb4:	85 c0                	test   %eax,%eax
f0102eb6:	74 d6                	je     f0102e8e <user_mem_check+0x44>
			uint32_t given_perm = *pte & 0xFFF;
f0102eb8:	8b 00                	mov    (%eax),%eax
f0102eba:	25 ff 0f 00 00       	and    $0xfff,%eax
			if ((given_perm | perm) > given_perm) {
f0102ebf:	89 c2                	mov    %eax,%edx
f0102ec1:	0b 55 14             	or     0x14(%ebp),%edx
f0102ec4:	39 c2                	cmp    %eax,%edx
f0102ec6:	76 c6                	jbe    f0102e8e <user_mem_check+0x44>
				user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f0102ec8:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102ecb:	72 06                	jb     f0102ed3 <user_mem_check+0x89>
		if ((uintptr_t)l >= ULIM) {// Higher than ULIM
f0102ecd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102ed0:	89 45 e0             	mov    %eax,-0x20(%ebp)
				user_mem_check_addr = (uintptr_t)(l < va ? va : l); 
f0102ed3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102ed6:	a3 1c 61 1b f0       	mov    %eax,0xf01b611c
				return -E_FAULT;
f0102edb:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102ee0:	eb 05                	jmp    f0102ee7 <user_mem_check+0x9d>
	return 0;
f0102ee2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102ee7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102eea:	5b                   	pop    %ebx
f0102eeb:	5e                   	pop    %esi
f0102eec:	5f                   	pop    %edi
f0102eed:	5d                   	pop    %ebp
f0102eee:	c3                   	ret    

f0102eef <user_mem_assert>:
{
f0102eef:	55                   	push   %ebp
f0102ef0:	89 e5                	mov    %esp,%ebp
f0102ef2:	53                   	push   %ebx
f0102ef3:	83 ec 04             	sub    $0x4,%esp
f0102ef6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102ef9:	8b 45 14             	mov    0x14(%ebp),%eax
f0102efc:	83 c8 04             	or     $0x4,%eax
f0102eff:	50                   	push   %eax
f0102f00:	ff 75 10             	pushl  0x10(%ebp)
f0102f03:	ff 75 0c             	pushl  0xc(%ebp)
f0102f06:	53                   	push   %ebx
f0102f07:	e8 3e ff ff ff       	call   f0102e4a <user_mem_check>
f0102f0c:	83 c4 10             	add    $0x10,%esp
f0102f0f:	85 c0                	test   %eax,%eax
f0102f11:	78 05                	js     f0102f18 <user_mem_assert+0x29>
}
f0102f13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102f16:	c9                   	leave  
f0102f17:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f0102f18:	83 ec 04             	sub    $0x4,%esp
f0102f1b:	ff 35 1c 61 1b f0    	pushl  0xf01b611c
f0102f21:	ff 73 48             	pushl  0x48(%ebx)
f0102f24:	68 04 60 10 f0       	push   $0xf0106004
f0102f29:	e8 b9 07 00 00       	call   f01036e7 <cprintf>
		env_destroy(env);	// may not return
f0102f2e:	89 1c 24             	mov    %ebx,(%esp)
f0102f31:	e8 97 06 00 00       	call   f01035cd <env_destroy>
f0102f36:	83 c4 10             	add    $0x10,%esp
}
f0102f39:	eb d8                	jmp    f0102f13 <user_mem_assert+0x24>

f0102f3b <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102f3b:	55                   	push   %ebp
f0102f3c:	89 e5                	mov    %esp,%ebp
f0102f3e:	53                   	push   %ebx
f0102f3f:	8b 55 08             	mov    0x8(%ebp),%edx
f0102f42:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102f45:	85 d2                	test   %edx,%edx
f0102f47:	74 44                	je     f0102f8d <envid2env+0x52>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102f49:	89 d3                	mov    %edx,%ebx
f0102f4b:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102f51:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0102f54:	01 d8                	add    %ebx,%eax
f0102f56:	c1 e0 05             	shl    $0x5,%eax
f0102f59:	03 05 2c 61 1b f0    	add    0xf01b612c,%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102f5f:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f0102f63:	74 39                	je     f0102f9e <envid2env+0x63>
f0102f65:	39 50 48             	cmp    %edx,0x48(%eax)
f0102f68:	75 34                	jne    f0102f9e <envid2env+0x63>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102f6a:	84 c9                	test   %cl,%cl
f0102f6c:	74 12                	je     f0102f80 <envid2env+0x45>
f0102f6e:	8b 15 28 61 1b f0    	mov    0xf01b6128,%edx
f0102f74:	39 c2                	cmp    %eax,%edx
f0102f76:	74 08                	je     f0102f80 <envid2env+0x45>
f0102f78:	8b 5a 48             	mov    0x48(%edx),%ebx
f0102f7b:	39 58 4c             	cmp    %ebx,0x4c(%eax)
f0102f7e:	75 2e                	jne    f0102fae <envid2env+0x73>
		*env_store = 0;
		return -E_BAD_ENV;
	}

	*env_store = e;
f0102f80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102f83:	89 01                	mov    %eax,(%ecx)
	return 0;
f0102f85:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102f8a:	5b                   	pop    %ebx
f0102f8b:	5d                   	pop    %ebp
f0102f8c:	c3                   	ret    
		*env_store = curenv;
f0102f8d:	a1 28 61 1b f0       	mov    0xf01b6128,%eax
f0102f92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102f95:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102f97:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f9c:	eb ec                	jmp    f0102f8a <envid2env+0x4f>
		*env_store = 0;
f0102f9e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fa1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102fa7:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102fac:	eb dc                	jmp    f0102f8a <envid2env+0x4f>
		*env_store = 0;
f0102fae:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fb1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102fb7:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102fbc:	eb cc                	jmp    f0102f8a <envid2env+0x4f>

f0102fbe <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102fbe:	55                   	push   %ebp
f0102fbf:	89 e5                	mov    %esp,%ebp
	asm volatile("lgdt (%0)" : : "r" (p));
f0102fc1:	b8 00 d3 11 f0       	mov    $0xf011d300,%eax
f0102fc6:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0102fc9:	b8 23 00 00 00       	mov    $0x23,%eax
f0102fce:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0102fd0:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0102fd2:	b8 10 00 00 00       	mov    $0x10,%eax
f0102fd7:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0102fd9:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0102fdb:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0102fdd:	ea e4 2f 10 f0 08 00 	ljmp   $0x8,$0xf0102fe4
	asm volatile("lldt %0" : : "r" (sel));
f0102fe4:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fe9:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102fec:	5d                   	pop    %ebp
f0102fed:	c3                   	ret    

f0102fee <env_init>:
{
f0102fee:	55                   	push   %ebp
f0102fef:	89 e5                	mov    %esp,%ebp
f0102ff1:	56                   	push   %esi
f0102ff2:	53                   	push   %ebx
		envs[i].env_link = env_free_list;
f0102ff3:	8b 35 2c 61 1b f0    	mov    0xf01b612c,%esi
f0102ff9:	8b 15 30 61 1b f0    	mov    0xf01b6130,%edx
f0102fff:	8d 86 a0 7f 01 00    	lea    0x17fa0(%esi),%eax
f0103005:	8d 5e a0             	lea    -0x60(%esi),%ebx
f0103008:	89 c1                	mov    %eax,%ecx
f010300a:	89 50 44             	mov    %edx,0x44(%eax)
f010300d:	83 e8 60             	sub    $0x60,%eax
		env_free_list = &envs[i];
f0103010:	89 ca                	mov    %ecx,%edx
	for (int i = NENV - 1; i >= 0; i--) { // Be sure not to use size_t
f0103012:	39 d8                	cmp    %ebx,%eax
f0103014:	75 f2                	jne    f0103008 <env_init+0x1a>
f0103016:	89 35 30 61 1b f0    	mov    %esi,0xf01b6130
	env_init_percpu();
f010301c:	e8 9d ff ff ff       	call   f0102fbe <env_init_percpu>
}
f0103021:	5b                   	pop    %ebx
f0103022:	5e                   	pop    %esi
f0103023:	5d                   	pop    %ebp
f0103024:	c3                   	ret    

f0103025 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103025:	55                   	push   %ebp
f0103026:	89 e5                	mov    %esp,%ebp
f0103028:	56                   	push   %esi
f0103029:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;
	// cprintf("newenv_store = %p\n", newenv_store);
	if (!(e = env_free_list))
f010302a:	8b 1d 30 61 1b f0    	mov    0xf01b6130,%ebx
f0103030:	85 db                	test   %ebx,%ebx
f0103032:	0f 84 c1 01 00 00    	je     f01031f9 <env_alloc+0x1d4>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103038:	83 ec 0c             	sub    $0xc,%esp
f010303b:	6a 01                	push   $0x1
f010303d:	e8 b6 e1 ff ff       	call   f01011f8 <page_alloc>
f0103042:	89 c6                	mov    %eax,%esi
f0103044:	83 c4 10             	add    $0x10,%esp
f0103047:	85 c0                	test   %eax,%eax
f0103049:	0f 84 b1 01 00 00    	je     f0103200 <env_alloc+0x1db>
	return (pp - pages) << PGSHIFT;
f010304f:	2b 05 ec 6d 1b f0    	sub    0xf01b6dec,%eax
f0103055:	c1 f8 03             	sar    $0x3,%eax
f0103058:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010305b:	89 c2                	mov    %eax,%edx
f010305d:	c1 ea 0c             	shr    $0xc,%edx
f0103060:	3b 15 e4 6d 1b f0    	cmp    0xf01b6de4,%edx
f0103066:	0f 83 43 01 00 00    	jae    f01031af <env_alloc+0x18a>
	memset(page2kva(p), 0, PGSIZE);
f010306c:	83 ec 04             	sub    $0x4,%esp
f010306f:	68 00 10 00 00       	push   $0x1000
f0103074:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0103076:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010307b:	50                   	push   %eax
f010307c:	e8 61 1a 00 00       	call   f0104ae2 <memset>
	p->pp_ref++;
f0103081:	66 ff 46 04          	incw   0x4(%esi)
	return (pp - pages) << PGSHIFT;
f0103085:	2b 35 ec 6d 1b f0    	sub    0xf01b6dec,%esi
f010308b:	c1 fe 03             	sar    $0x3,%esi
f010308e:	c1 e6 0c             	shl    $0xc,%esi
	if (PGNUM(pa) >= npages)
f0103091:	89 f0                	mov    %esi,%eax
f0103093:	c1 e8 0c             	shr    $0xc,%eax
f0103096:	83 c4 10             	add    $0x10,%esp
f0103099:	3b 05 e4 6d 1b f0    	cmp    0xf01b6de4,%eax
f010309f:	0f 83 1c 01 00 00    	jae    f01031c1 <env_alloc+0x19c>
	return (void *)(pa + KERNBASE);
f01030a5:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f01030ab:	89 73 5c             	mov    %esi,0x5c(%ebx)
	e->env_pgdir = page2kva(p);
f01030ae:	b8 ec 0e 00 00       	mov    $0xeec,%eax
		e->env_pgdir[pgt] = kern_pgdir[pgt];
f01030b3:	8b 15 e8 6d 1b f0    	mov    0xf01b6de8,%edx
f01030b9:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f01030bc:	8b 53 5c             	mov    0x5c(%ebx),%edx
f01030bf:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f01030c2:	83 c0 04             	add    $0x4,%eax
	for (size_t pgt = PDX(UTOP); pgt < PGSIZE / sizeof(pde_t); pgt++) {
f01030c5:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01030ca:	75 e7                	jne    f01030b3 <env_alloc+0x8e>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01030cc:	8b 43 5c             	mov    0x5c(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01030cf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030d4:	0f 86 f9 00 00 00    	jbe    f01031d3 <env_alloc+0x1ae>
	return (physaddr_t)kva - KERNBASE;
f01030da:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01030e0:	83 ca 05             	or     $0x5,%edx
f01030e3:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01030e9:	8b 43 48             	mov    0x48(%ebx),%eax
f01030ec:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01030f1:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01030f6:	89 c2                	mov    %eax,%edx
f01030f8:	0f 8e ea 00 00 00    	jle    f01031e8 <env_alloc+0x1c3>
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f01030fe:	89 d8                	mov    %ebx,%eax
f0103100:	2b 05 2c 61 1b f0    	sub    0xf01b612c,%eax
f0103106:	c1 f8 05             	sar    $0x5,%eax
f0103109:	89 c1                	mov    %eax,%ecx
f010310b:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010310e:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0103111:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0103114:	89 c6                	mov    %eax,%esi
f0103116:	c1 e6 08             	shl    $0x8,%esi
f0103119:	01 f0                	add    %esi,%eax
f010311b:	89 c6                	mov    %eax,%esi
f010311d:	c1 e6 10             	shl    $0x10,%esi
f0103120:	01 f0                	add    %esi,%eax
f0103122:	01 c0                	add    %eax,%eax
f0103124:	01 c8                	add    %ecx,%eax
f0103126:	09 d0                	or     %edx,%eax
f0103128:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f010312b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010312e:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103131:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103138:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010313f:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103146:	83 ec 04             	sub    $0x4,%esp
f0103149:	6a 44                	push   $0x44
f010314b:	6a 00                	push   $0x0
f010314d:	53                   	push   %ebx
f010314e:	e8 8f 19 00 00       	call   f0104ae2 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103153:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103159:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010315f:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103165:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010316c:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0103172:	8b 43 44             	mov    0x44(%ebx),%eax
f0103175:	a3 30 61 1b f0       	mov    %eax,0xf01b6130
	*newenv_store = e;
f010317a:	8b 45 08             	mov    0x8(%ebp),%eax
f010317d:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010317f:	8b 53 48             	mov    0x48(%ebx),%edx
f0103182:	a1 28 61 1b f0       	mov    0xf01b6128,%eax
f0103187:	83 c4 10             	add    $0x10,%esp
f010318a:	85 c0                	test   %eax,%eax
f010318c:	74 64                	je     f01031f2 <env_alloc+0x1cd>
f010318e:	8b 40 48             	mov    0x48(%eax),%eax
f0103191:	83 ec 04             	sub    $0x4,%esp
f0103194:	52                   	push   %edx
f0103195:	50                   	push   %eax
f0103196:	68 d1 63 10 f0       	push   $0xf01063d1
f010319b:	e8 47 05 00 00       	call   f01036e7 <cprintf>
	return 0;
f01031a0:	83 c4 10             	add    $0x10,%esp
f01031a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01031a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01031ab:	5b                   	pop    %ebx
f01031ac:	5e                   	pop    %esi
f01031ad:	5d                   	pop    %ebp
f01031ae:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01031af:	50                   	push   %eax
f01031b0:	68 b0 56 10 f0       	push   $0xf01056b0
f01031b5:	6a 56                	push   $0x56
f01031b7:	68 45 60 10 f0       	push   $0xf0106045
f01031bc:	e8 87 cf ff ff       	call   f0100148 <_panic>
f01031c1:	56                   	push   %esi
f01031c2:	68 b0 56 10 f0       	push   $0xf01056b0
f01031c7:	6a 56                	push   $0x56
f01031c9:	68 45 60 10 f0       	push   $0xf0106045
f01031ce:	e8 75 cf ff ff       	call   f0100148 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031d3:	50                   	push   %eax
f01031d4:	68 64 59 10 f0       	push   $0xf0105964
f01031d9:	68 c7 00 00 00       	push   $0xc7
f01031de:	68 c6 63 10 f0       	push   $0xf01063c6
f01031e3:	e8 60 cf ff ff       	call   f0100148 <_panic>
		generation = 1 << ENVGENSHIFT;
f01031e8:	ba 00 10 00 00       	mov    $0x1000,%edx
f01031ed:	e9 0c ff ff ff       	jmp    f01030fe <env_alloc+0xd9>
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01031f2:	b8 00 00 00 00       	mov    $0x0,%eax
f01031f7:	eb 98                	jmp    f0103191 <env_alloc+0x16c>
		return -E_NO_FREE_ENV;
f01031f9:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01031fe:	eb a8                	jmp    f01031a8 <env_alloc+0x183>
		return -E_NO_MEM;
f0103200:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103205:	eb a1                	jmp    f01031a8 <env_alloc+0x183>

f0103207 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103207:	55                   	push   %ebp
f0103208:	89 e5                	mov    %esp,%ebp
f010320a:	57                   	push   %edi
f010320b:	56                   	push   %esi
f010320c:	53                   	push   %ebx
f010320d:	83 ec 34             	sub    $0x34,%esp
	struct Env* newenv;
	// cprintf("&newenv = %p\n", &newenv);
	// cprintf("env_free_list = %p\n", env_free_list);
	int r = env_alloc(&newenv, 0);
f0103210:	6a 00                	push   $0x0
f0103212:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103215:	50                   	push   %eax
f0103216:	e8 0a fe ff ff       	call   f0103025 <env_alloc>
	// cprintf("newenv = %p, envs[0] = %p\n", newenv, envs);
	if (r)
f010321b:	83 c4 10             	add    $0x10,%esp
f010321e:	85 c0                	test   %eax,%eax
f0103220:	75 47                	jne    f0103269 <env_create+0x62>
		panic("Environment allocation faulted: %e", r);
	load_icode(newenv, binary);
f0103222:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	if (elf->e_magic != ELF_MAGIC)
f0103225:	8b 45 08             	mov    0x8(%ebp),%eax
f0103228:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f010322e:	75 4e                	jne    f010327e <env_create+0x77>
	struct Proghdr *ph = (struct Proghdr *) (binary + elf->e_phoff), 
f0103230:	8b 45 08             	mov    0x8(%ebp),%eax
f0103233:	89 c6                	mov    %eax,%esi
f0103235:	03 70 1c             	add    0x1c(%eax),%esi
				   *eph = ph + elf->e_phnum;
f0103238:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
f010323c:	c1 e0 05             	shl    $0x5,%eax
f010323f:	01 f0                	add    %esi,%eax
f0103241:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	pte_t pgdir_pte = *pgdir_walk(kern_pgdir, e->env_pgdir, 0);
f0103244:	83 ec 04             	sub    $0x4,%esp
f0103247:	6a 00                	push   $0x0
f0103249:	ff 77 5c             	pushl  0x5c(%edi)
f010324c:	ff 35 e8 6d 1b f0    	pushl  0xf01b6de8
f0103252:	e8 8b e0 ff ff       	call   f01012e2 <pgdir_walk>
	physaddr_t pgdir_phy = PTE_ADDR(pgdir_pte);
f0103257:	8b 00                	mov    (%eax),%eax
f0103259:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010325e:	0f 22 d8             	mov    %eax,%cr3
f0103261:	83 c4 10             	add    $0x10,%esp
f0103264:	e9 df 00 00 00       	jmp    f0103348 <env_create+0x141>
		panic("Environment allocation faulted: %e", r);
f0103269:	50                   	push   %eax
f010326a:	68 48 63 10 f0       	push   $0xf0106348
f010326f:	68 9a 01 00 00       	push   $0x19a
f0103274:	68 c6 63 10 f0       	push   $0xf01063c6
f0103279:	e8 ca ce ff ff       	call   f0100148 <_panic>
		panic("Not a valid elf binary!");
f010327e:	83 ec 04             	sub    $0x4,%esp
f0103281:	68 e6 63 10 f0       	push   $0xf01063e6
f0103286:	68 5c 01 00 00       	push   $0x15c
f010328b:	68 c6 63 10 f0       	push   $0xf01063c6
f0103290:	e8 b3 ce ff ff       	call   f0100148 <_panic>
			region_alloc(e, (void*)ph0->p_va, ph0->p_memsz);
f0103295:	8b 46 08             	mov    0x8(%esi),%eax
	uintptr_t l = ROUNDDOWN((uintptr_t)va, PGSIZE), 
f0103298:	89 c3                	mov    %eax,%ebx
f010329a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
			  r = ROUNDUP((uintptr_t)(va + len), PGSIZE);
f01032a0:	03 46 14             	add    0x14(%esi),%eax
f01032a3:	05 ff 0f 00 00       	add    $0xfff,%eax
f01032a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01032ad:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01032b0:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01032b3:	89 c6                	mov    %eax,%esi
	for (uintptr_t ptr = l; ptr < r; ptr += PGSIZE) {
f01032b5:	39 de                	cmp    %ebx,%esi
f01032b7:	76 5a                	jbe    f0103313 <env_create+0x10c>
		struct PageInfo *pg = page_alloc(0);
f01032b9:	83 ec 0c             	sub    $0xc,%esp
f01032bc:	6a 00                	push   $0x0
f01032be:	e8 35 df ff ff       	call   f01011f8 <page_alloc>
		if (!pg)
f01032c3:	83 c4 10             	add    $0x10,%esp
f01032c6:	85 c0                	test   %eax,%eax
f01032c8:	74 1b                	je     f01032e5 <env_create+0xde>
		int res = page_insert(e->env_pgdir, pg, (void*)ptr, PTE_U | PTE_W);
f01032ca:	6a 06                	push   $0x6
f01032cc:	53                   	push   %ebx
f01032cd:	50                   	push   %eax
f01032ce:	ff 77 5c             	pushl  0x5c(%edi)
f01032d1:	e8 20 e2 ff ff       	call   f01014f6 <page_insert>
		if (res)
f01032d6:	83 c4 10             	add    $0x10,%esp
f01032d9:	85 c0                	test   %eax,%eax
f01032db:	75 1f                	jne    f01032fc <env_create+0xf5>
	for (uintptr_t ptr = l; ptr < r; ptr += PGSIZE) {
f01032dd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01032e3:	eb d0                	jmp    f01032b5 <env_create+0xae>
			panic("No free page for allocation.");
f01032e5:	83 ec 04             	sub    $0x4,%esp
f01032e8:	68 fe 63 10 f0       	push   $0xf01063fe
f01032ed:	68 1a 01 00 00       	push   $0x11a
f01032f2:	68 c6 63 10 f0       	push   $0xf01063c6
f01032f7:	e8 4c ce ff ff       	call   f0100148 <_panic>
			panic("Page insertion result: %e", r);
f01032fc:	ff 75 cc             	pushl  -0x34(%ebp)
f01032ff:	68 1b 64 10 f0       	push   $0xf010641b
f0103304:	68 1d 01 00 00       	push   $0x11d
f0103309:	68 c6 63 10 f0       	push   $0xf01063c6
f010330e:	e8 35 ce ff ff       	call   f0100148 <_panic>
f0103313:	8b 75 d0             	mov    -0x30(%ebp),%esi
			memcpy((void*)ph0->p_va, binary + ph0->p_offset, ph0->p_filesz);
f0103316:	83 ec 04             	sub    $0x4,%esp
f0103319:	ff 76 10             	pushl  0x10(%esi)
f010331c:	8b 45 08             	mov    0x8(%ebp),%eax
f010331f:	03 46 04             	add    0x4(%esi),%eax
f0103322:	50                   	push   %eax
f0103323:	ff 76 08             	pushl  0x8(%esi)
f0103326:	e8 6a 18 00 00       	call   f0104b95 <memcpy>
					ph0->p_memsz - ph0->p_filesz);
f010332b:	8b 46 10             	mov    0x10(%esi),%eax
			memset((void*)ph0->p_va + ph0->p_filesz, 0, 
f010332e:	83 c4 0c             	add    $0xc,%esp
f0103331:	8b 56 14             	mov    0x14(%esi),%edx
f0103334:	29 c2                	sub    %eax,%edx
f0103336:	52                   	push   %edx
f0103337:	6a 00                	push   $0x0
f0103339:	03 46 08             	add    0x8(%esi),%eax
f010333c:	50                   	push   %eax
f010333d:	e8 a0 17 00 00       	call   f0104ae2 <memset>
f0103342:	83 c4 10             	add    $0x10,%esp
	for (struct Proghdr* ph0 = ph; ph0 < eph; ph0++) {
f0103345:	83 c6 20             	add    $0x20,%esi
f0103348:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f010334b:	76 1e                	jbe    f010336b <env_create+0x164>
		if (ph0->p_type == ELF_PROG_LOAD) {
f010334d:	83 3e 01             	cmpl   $0x1,(%esi)
f0103350:	0f 84 3f ff ff ff    	je     f0103295 <env_create+0x8e>
			cprintf("Found a ph with type %d; skipping\n", ph0->p_filesz);
f0103356:	83 ec 08             	sub    $0x8,%esp
f0103359:	ff 76 10             	pushl  0x10(%esi)
f010335c:	68 6c 63 10 f0       	push   $0xf010636c
f0103361:	e8 81 03 00 00       	call   f01036e7 <cprintf>
f0103366:	83 c4 10             	add    $0x10,%esp
f0103369:	eb da                	jmp    f0103345 <env_create+0x13e>
	e->env_tf.tf_eip = elf->e_entry;
f010336b:	8b 45 08             	mov    0x8(%ebp),%eax
f010336e:	8b 40 18             	mov    0x18(%eax),%eax
f0103371:	89 47 30             	mov    %eax,0x30(%edi)
	e->env_tf.tf_eflags = 0;
f0103374:	c7 47 38 00 00 00 00 	movl   $0x0,0x38(%edi)
	lcr3(PADDR(kern_pgdir));
f010337b:	a1 e8 6d 1b f0       	mov    0xf01b6de8,%eax
	if ((uint32_t)kva < KERNBASE)
f0103380:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103385:	76 38                	jbe    f01033bf <env_create+0x1b8>
	return (physaddr_t)kva - KERNBASE;
f0103387:	05 00 00 00 10       	add    $0x10000000,%eax
f010338c:	0f 22 d8             	mov    %eax,%cr3
	struct PageInfo *stack_page = page_alloc(ALLOC_ZERO);
f010338f:	83 ec 0c             	sub    $0xc,%esp
f0103392:	6a 01                	push   $0x1
f0103394:	e8 5f de ff ff       	call   f01011f8 <page_alloc>
	if (!stack_page)
f0103399:	83 c4 10             	add    $0x10,%esp
f010339c:	85 c0                	test   %eax,%eax
f010339e:	74 34                	je     f01033d4 <env_create+0x1cd>
	int r = page_insert(e->env_pgdir, stack_page, (void*)USTACKTOP - PGSIZE, PTE_U | PTE_W);
f01033a0:	6a 06                	push   $0x6
f01033a2:	68 00 d0 bf ee       	push   $0xeebfd000
f01033a7:	50                   	push   %eax
f01033a8:	ff 77 5c             	pushl  0x5c(%edi)
f01033ab:	e8 46 e1 ff ff       	call   f01014f6 <page_insert>
	if (r)
f01033b0:	83 c4 10             	add    $0x10,%esp
f01033b3:	85 c0                	test   %eax,%eax
f01033b5:	75 34                	jne    f01033eb <env_create+0x1e4>
}
f01033b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033ba:	5b                   	pop    %ebx
f01033bb:	5e                   	pop    %esi
f01033bc:	5f                   	pop    %edi
f01033bd:	5d                   	pop    %ebp
f01033be:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033bf:	50                   	push   %eax
f01033c0:	68 64 59 10 f0       	push   $0xf0105964
f01033c5:	68 7c 01 00 00       	push   $0x17c
f01033ca:	68 c6 63 10 f0       	push   $0xf01063c6
f01033cf:	e8 74 cd ff ff       	call   f0100148 <_panic>
		panic("No free page for allocation.");
f01033d4:	83 ec 04             	sub    $0x4,%esp
f01033d7:	68 fe 63 10 f0       	push   $0xf01063fe
f01033dc:	68 84 01 00 00       	push   $0x184
f01033e1:	68 c6 63 10 f0       	push   $0xf01063c6
f01033e6:	e8 5d cd ff ff       	call   f0100148 <_panic>
		panic("Page insertion result: %e", r);
f01033eb:	50                   	push   %eax
f01033ec:	68 1b 64 10 f0       	push   $0xf010641b
f01033f1:	68 87 01 00 00       	push   $0x187
f01033f6:	68 c6 63 10 f0       	push   $0xf01063c6
f01033fb:	e8 48 cd ff ff       	call   f0100148 <_panic>

f0103400 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103400:	55                   	push   %ebp
f0103401:	89 e5                	mov    %esp,%ebp
f0103403:	57                   	push   %edi
f0103404:	56                   	push   %esi
f0103405:	53                   	push   %ebx
f0103406:	83 ec 1c             	sub    $0x1c,%esp
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103409:	8b 15 28 61 1b f0    	mov    0xf01b6128,%edx
f010340f:	3b 55 08             	cmp    0x8(%ebp),%edx
f0103412:	75 14                	jne    f0103428 <env_free+0x28>
		lcr3(PADDR(kern_pgdir));
f0103414:	a1 e8 6d 1b f0       	mov    0xf01b6de8,%eax
	if ((uint32_t)kva < KERNBASE)
f0103419:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010341e:	76 36                	jbe    f0103456 <env_free+0x56>
	return (physaddr_t)kva - KERNBASE;
f0103420:	05 00 00 00 10       	add    $0x10000000,%eax
f0103425:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103428:	8b 45 08             	mov    0x8(%ebp),%eax
f010342b:	8b 48 48             	mov    0x48(%eax),%ecx
f010342e:	85 d2                	test   %edx,%edx
f0103430:	74 39                	je     f010346b <env_free+0x6b>
f0103432:	8b 42 48             	mov    0x48(%edx),%eax
f0103435:	83 ec 04             	sub    $0x4,%esp
f0103438:	51                   	push   %ecx
f0103439:	50                   	push   %eax
f010343a:	68 35 64 10 f0       	push   $0xf0106435
f010343f:	e8 a3 02 00 00       	call   f01036e7 <cprintf>
f0103444:	83 c4 10             	add    $0x10,%esp
f0103447:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f010344e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103451:	e9 96 00 00 00       	jmp    f01034ec <env_free+0xec>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103456:	50                   	push   %eax
f0103457:	68 64 59 10 f0       	push   $0xf0105964
f010345c:	68 ac 01 00 00       	push   $0x1ac
f0103461:	68 c6 63 10 f0       	push   $0xf01063c6
f0103466:	e8 dd cc ff ff       	call   f0100148 <_panic>
f010346b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103470:	eb c3                	jmp    f0103435 <env_free+0x35>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103472:	50                   	push   %eax
f0103473:	68 b0 56 10 f0       	push   $0xf01056b0
f0103478:	68 bb 01 00 00       	push   $0x1bb
f010347d:	68 c6 63 10 f0       	push   $0xf01063c6
f0103482:	e8 c1 cc ff ff       	call   f0100148 <_panic>
f0103487:	83 c3 04             	add    $0x4,%ebx
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010348a:	39 f3                	cmp    %esi,%ebx
f010348c:	74 21                	je     f01034af <env_free+0xaf>
			if (pt[pteno] & PTE_P)
f010348e:	f6 03 01             	testb  $0x1,(%ebx)
f0103491:	74 f4                	je     f0103487 <env_free+0x87>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103493:	83 ec 08             	sub    $0x8,%esp
f0103496:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103499:	01 d8                	add    %ebx,%eax
f010349b:	c1 e0 0a             	shl    $0xa,%eax
f010349e:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01034a1:	50                   	push   %eax
f01034a2:	ff 77 5c             	pushl  0x5c(%edi)
f01034a5:	e8 04 e0 ff ff       	call   f01014ae <page_remove>
f01034aa:	83 c4 10             	add    $0x10,%esp
f01034ad:	eb d8                	jmp    f0103487 <env_free+0x87>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01034af:	8b 47 5c             	mov    0x5c(%edi),%eax
f01034b2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034b5:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f01034bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01034bf:	3b 05 e4 6d 1b f0    	cmp    0xf01b6de4,%eax
f01034c5:	73 6a                	jae    f0103531 <env_free+0x131>
		page_decref(pa2page(pa));
f01034c7:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01034ca:	a1 ec 6d 1b f0       	mov    0xf01b6dec,%eax
f01034cf:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01034d2:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01034d5:	50                   	push   %eax
f01034d6:	e8 e1 dd ff ff       	call   f01012bc <page_decref>
f01034db:	83 c4 10             	add    $0x10,%esp
f01034de:	83 45 dc 04          	addl   $0x4,-0x24(%ebp)
f01034e2:	8b 45 dc             	mov    -0x24(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01034e5:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01034ea:	74 59                	je     f0103545 <env_free+0x145>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01034ec:	8b 47 5c             	mov    0x5c(%edi),%eax
f01034ef:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034f2:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01034f5:	a8 01                	test   $0x1,%al
f01034f7:	74 e5                	je     f01034de <env_free+0xde>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01034f9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01034fe:	89 c2                	mov    %eax,%edx
f0103500:	c1 ea 0c             	shr    $0xc,%edx
f0103503:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0103506:	39 15 e4 6d 1b f0    	cmp    %edx,0xf01b6de4
f010350c:	0f 86 60 ff ff ff    	jbe    f0103472 <env_free+0x72>
	return (void *)(pa + KERNBASE);
f0103512:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103518:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010351b:	c1 e2 14             	shl    $0x14,%edx
f010351e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103521:	8d b0 00 10 00 f0    	lea    -0xffff000(%eax),%esi
f0103527:	f7 d8                	neg    %eax
f0103529:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010352c:	e9 5d ff ff ff       	jmp    f010348e <env_free+0x8e>
		panic("pa2page called with invalid pa");
f0103531:	83 ec 04             	sub    $0x4,%esp
f0103534:	68 88 59 10 f0       	push   $0xf0105988
f0103539:	6a 4f                	push   $0x4f
f010353b:	68 45 60 10 f0       	push   $0xf0106045
f0103540:	e8 03 cc ff ff       	call   f0100148 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103545:	8b 45 08             	mov    0x8(%ebp),%eax
f0103548:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010354b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103550:	76 52                	jbe    f01035a4 <env_free+0x1a4>
	e->env_pgdir = 0;
f0103552:	8b 55 08             	mov    0x8(%ebp),%edx
f0103555:	c7 42 5c 00 00 00 00 	movl   $0x0,0x5c(%edx)
	return (physaddr_t)kva - KERNBASE;
f010355c:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103561:	c1 e8 0c             	shr    $0xc,%eax
f0103564:	3b 05 e4 6d 1b f0    	cmp    0xf01b6de4,%eax
f010356a:	73 4d                	jae    f01035b9 <env_free+0x1b9>
	page_decref(pa2page(pa));
f010356c:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010356f:	8b 15 ec 6d 1b f0    	mov    0xf01b6dec,%edx
f0103575:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103578:	50                   	push   %eax
f0103579:	e8 3e dd ff ff       	call   f01012bc <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010357e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103581:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f0103588:	a1 30 61 1b f0       	mov    0xf01b6130,%eax
f010358d:	8b 55 08             	mov    0x8(%ebp),%edx
f0103590:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f0103593:	89 15 30 61 1b f0    	mov    %edx,0xf01b6130
}
f0103599:	83 c4 10             	add    $0x10,%esp
f010359c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010359f:	5b                   	pop    %ebx
f01035a0:	5e                   	pop    %esi
f01035a1:	5f                   	pop    %edi
f01035a2:	5d                   	pop    %ebp
f01035a3:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035a4:	50                   	push   %eax
f01035a5:	68 64 59 10 f0       	push   $0xf0105964
f01035aa:	68 c9 01 00 00       	push   $0x1c9
f01035af:	68 c6 63 10 f0       	push   $0xf01063c6
f01035b4:	e8 8f cb ff ff       	call   f0100148 <_panic>
		panic("pa2page called with invalid pa");
f01035b9:	83 ec 04             	sub    $0x4,%esp
f01035bc:	68 88 59 10 f0       	push   $0xf0105988
f01035c1:	6a 4f                	push   $0x4f
f01035c3:	68 45 60 10 f0       	push   $0xf0106045
f01035c8:	e8 7b cb ff ff       	call   f0100148 <_panic>

f01035cd <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f01035cd:	55                   	push   %ebp
f01035ce:	89 e5                	mov    %esp,%ebp
f01035d0:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f01035d3:	ff 75 08             	pushl  0x8(%ebp)
f01035d6:	e8 25 fe ff ff       	call   f0103400 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01035db:	c7 04 24 90 63 10 f0 	movl   $0xf0106390,(%esp)
f01035e2:	e8 00 01 00 00       	call   f01036e7 <cprintf>
f01035e7:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f01035ea:	83 ec 0c             	sub    $0xc,%esp
f01035ed:	6a 00                	push   $0x0
f01035ef:	e8 8f d6 ff ff       	call   f0100c83 <monitor>
f01035f4:	83 c4 10             	add    $0x10,%esp
f01035f7:	eb f1                	jmp    f01035ea <env_destroy+0x1d>

f01035f9 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01035f9:	55                   	push   %ebp
f01035fa:	89 e5                	mov    %esp,%ebp
f01035fc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile(
f01035ff:	8b 65 08             	mov    0x8(%ebp),%esp
f0103602:	61                   	popa   
f0103603:	07                   	pop    %es
f0103604:	1f                   	pop    %ds
f0103605:	83 c4 08             	add    $0x8,%esp
f0103608:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103609:	68 4b 64 10 f0       	push   $0xf010644b
f010360e:	68 f2 01 00 00       	push   $0x1f2
f0103613:	68 c6 63 10 f0       	push   $0xf01063c6
f0103618:	e8 2b cb ff ff       	call   f0100148 <_panic>

f010361d <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010361d:	55                   	push   %ebp
f010361e:	89 e5                	mov    %esp,%ebp
f0103620:	83 ec 08             	sub    $0x8,%esp
f0103623:	8b 45 08             	mov    0x8(%ebp),%eax
	// Hint: This function loads the new environment's state from
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	if (curenv && curenv->env_status == ENV_RUNNING) {
f0103626:	8b 15 28 61 1b f0    	mov    0xf01b6128,%edx
f010362c:	85 d2                	test   %edx,%edx
f010362e:	74 06                	je     f0103636 <env_run+0x19>
f0103630:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0103634:	74 2f                	je     f0103665 <env_run+0x48>
		curenv->env_status = ENV_RUNNABLE;
	}
	// mon_backtrace(0, 0, 0);
	curenv = e;
f0103636:	a3 28 61 1b f0       	mov    %eax,0xf01b6128
	curenv->env_status = ENV_RUNNING;
f010363b:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103642:	ff 40 58             	incl   0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f0103645:	8b 50 5c             	mov    0x5c(%eax),%edx
	if ((uint32_t)kva < KERNBASE)
f0103648:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010364e:	77 1e                	ja     f010366e <env_run+0x51>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103650:	52                   	push   %edx
f0103651:	68 64 59 10 f0       	push   $0xf0105964
f0103656:	68 16 02 00 00       	push   $0x216
f010365b:	68 c6 63 10 f0       	push   $0xf01063c6
f0103660:	e8 e3 ca ff ff       	call   f0100148 <_panic>
		curenv->env_status = ENV_RUNNABLE;
f0103665:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
f010366c:	eb c8                	jmp    f0103636 <env_run+0x19>
	return (physaddr_t)kva - KERNBASE;
f010366e:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103674:	0f 22 da             	mov    %edx,%cr3
	env_pop_tf(&curenv->env_tf);  // Does not return.
f0103677:	83 ec 0c             	sub    $0xc,%esp
f010367a:	50                   	push   %eax
f010367b:	e8 79 ff ff ff       	call   f01035f9 <env_pop_tf>

f0103680 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103680:	55                   	push   %ebp
f0103681:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103683:	8b 45 08             	mov    0x8(%ebp),%eax
f0103686:	ba 70 00 00 00       	mov    $0x70,%edx
f010368b:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010368c:	ba 71 00 00 00       	mov    $0x71,%edx
f0103691:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103692:	0f b6 c0             	movzbl %al,%eax
}
f0103695:	5d                   	pop    %ebp
f0103696:	c3                   	ret    

f0103697 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103697:	55                   	push   %ebp
f0103698:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010369a:	8b 45 08             	mov    0x8(%ebp),%eax
f010369d:	ba 70 00 00 00       	mov    $0x70,%edx
f01036a2:	ee                   	out    %al,(%dx)
f01036a3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036a6:	ba 71 00 00 00       	mov    $0x71,%edx
f01036ab:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01036ac:	5d                   	pop    %ebp
f01036ad:	c3                   	ret    

f01036ae <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01036ae:	55                   	push   %ebp
f01036af:	89 e5                	mov    %esp,%ebp
f01036b1:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01036b4:	ff 75 08             	pushl  0x8(%ebp)
f01036b7:	e8 df cf ff ff       	call   f010069b <cputchar>
	*cnt++;
}
f01036bc:	83 c4 10             	add    $0x10,%esp
f01036bf:	c9                   	leave  
f01036c0:	c3                   	ret    

f01036c1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01036c1:	55                   	push   %ebp
f01036c2:	89 e5                	mov    %esp,%ebp
f01036c4:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01036c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01036ce:	ff 75 0c             	pushl  0xc(%ebp)
f01036d1:	ff 75 08             	pushl  0x8(%ebp)
f01036d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01036d7:	50                   	push   %eax
f01036d8:	68 ae 36 10 f0       	push   $0xf01036ae
f01036dd:	e8 e7 0c 00 00       	call   f01043c9 <vprintfmt>
	return cnt;
}
f01036e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01036e5:	c9                   	leave  
f01036e6:	c3                   	ret    

f01036e7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01036e7:	55                   	push   %ebp
f01036e8:	89 e5                	mov    %esp,%ebp
f01036ea:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01036ed:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01036f0:	50                   	push   %eax
f01036f1:	ff 75 08             	pushl  0x8(%ebp)
f01036f4:	e8 c8 ff ff ff       	call   f01036c1 <vcprintf>
	va_end(ap);

	return cnt;
}
f01036f9:	c9                   	leave  
f01036fa:	c3                   	ret    

f01036fb <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01036fb:	55                   	push   %ebp
f01036fc:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f01036fe:	b8 60 69 1b f0       	mov    $0xf01b6960,%eax
f0103703:	c7 05 64 69 1b f0 00 	movl   $0xf0000000,0xf01b6964
f010370a:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f010370d:	66 c7 05 68 69 1b f0 	movw   $0x10,0xf01b6968
f0103714:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f0103716:	66 c7 05 c6 69 1b f0 	movw   $0x68,0xf01b69c6
f010371d:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f010371f:	66 c7 05 48 d3 11 f0 	movw   $0x67,0xf011d348
f0103726:	67 00 
f0103728:	66 a3 4a d3 11 f0    	mov    %ax,0xf011d34a
f010372e:	89 c2                	mov    %eax,%edx
f0103730:	c1 ea 10             	shr    $0x10,%edx
f0103733:	88 15 4c d3 11 f0    	mov    %dl,0xf011d34c
f0103739:	c6 05 4e d3 11 f0 40 	movb   $0x40,0xf011d34e
f0103740:	c1 e8 18             	shr    $0x18,%eax
f0103743:	a2 4f d3 11 f0       	mov    %al,0xf011d34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103748:	c6 05 4d d3 11 f0 89 	movb   $0x89,0xf011d34d
	asm volatile("ltr %0" : : "r" (sel));
f010374f:	b8 28 00 00 00       	mov    $0x28,%eax
f0103754:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f0103757:	b8 50 d3 11 f0       	mov    $0xf011d350,%eax
f010375c:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f010375f:	5d                   	pop    %ebp
f0103760:	c3                   	ret    

f0103761 <trap_init>:
{
f0103761:	55                   	push   %ebp
f0103762:	89 e5                	mov    %esp,%ebp
	SETGATE(idt[T_DIVIDE] , 1, GD_KT, (void*)H_DIVIDE ,0);   
f0103764:	b8 74 3e 10 f0       	mov    $0xf0103e74,%eax
f0103769:	66 a3 40 61 1b f0    	mov    %ax,0xf01b6140
f010376f:	66 c7 05 42 61 1b f0 	movw   $0x8,0xf01b6142
f0103776:	08 00 
f0103778:	c6 05 44 61 1b f0 00 	movb   $0x0,0xf01b6144
f010377f:	c6 05 45 61 1b f0 8f 	movb   $0x8f,0xf01b6145
f0103786:	c1 e8 10             	shr    $0x10,%eax
f0103789:	66 a3 46 61 1b f0    	mov    %ax,0xf01b6146
	SETGATE(idt[T_DEBUG]  , 1, GD_KT, (void*)H_DEBUG  ,0);  
f010378f:	b8 7a 3e 10 f0       	mov    $0xf0103e7a,%eax
f0103794:	66 a3 48 61 1b f0    	mov    %ax,0xf01b6148
f010379a:	66 c7 05 4a 61 1b f0 	movw   $0x8,0xf01b614a
f01037a1:	08 00 
f01037a3:	c6 05 4c 61 1b f0 00 	movb   $0x0,0xf01b614c
f01037aa:	c6 05 4d 61 1b f0 8f 	movb   $0x8f,0xf01b614d
f01037b1:	c1 e8 10             	shr    $0x10,%eax
f01037b4:	66 a3 4e 61 1b f0    	mov    %ax,0xf01b614e
	SETGATE(idt[T_NMI]    , 1, GD_KT, (void*)H_NMI    ,0);
f01037ba:	b8 80 3e 10 f0       	mov    $0xf0103e80,%eax
f01037bf:	66 a3 50 61 1b f0    	mov    %ax,0xf01b6150
f01037c5:	66 c7 05 52 61 1b f0 	movw   $0x8,0xf01b6152
f01037cc:	08 00 
f01037ce:	c6 05 54 61 1b f0 00 	movb   $0x0,0xf01b6154
f01037d5:	c6 05 55 61 1b f0 8f 	movb   $0x8f,0xf01b6155
f01037dc:	c1 e8 10             	shr    $0x10,%eax
f01037df:	66 a3 56 61 1b f0    	mov    %ax,0xf01b6156
	SETGATE(idt[T_BRKPT]  , 1, GD_KT, (void*)H_BRKPT  ,3);  // User level previlege (3)
f01037e5:	b8 86 3e 10 f0       	mov    $0xf0103e86,%eax
f01037ea:	66 a3 58 61 1b f0    	mov    %ax,0xf01b6158
f01037f0:	66 c7 05 5a 61 1b f0 	movw   $0x8,0xf01b615a
f01037f7:	08 00 
f01037f9:	c6 05 5c 61 1b f0 00 	movb   $0x0,0xf01b615c
f0103800:	c6 05 5d 61 1b f0 ef 	movb   $0xef,0xf01b615d
f0103807:	c1 e8 10             	shr    $0x10,%eax
f010380a:	66 a3 5e 61 1b f0    	mov    %ax,0xf01b615e
	SETGATE(idt[T_OFLOW]  , 1, GD_KT, (void*)H_OFLOW  ,0);  
f0103810:	b8 8c 3e 10 f0       	mov    $0xf0103e8c,%eax
f0103815:	66 a3 60 61 1b f0    	mov    %ax,0xf01b6160
f010381b:	66 c7 05 62 61 1b f0 	movw   $0x8,0xf01b6162
f0103822:	08 00 
f0103824:	c6 05 64 61 1b f0 00 	movb   $0x0,0xf01b6164
f010382b:	c6 05 65 61 1b f0 8f 	movb   $0x8f,0xf01b6165
f0103832:	c1 e8 10             	shr    $0x10,%eax
f0103835:	66 a3 66 61 1b f0    	mov    %ax,0xf01b6166
	SETGATE(idt[T_BOUND]  , 1, GD_KT, (void*)H_BOUND  ,0);  
f010383b:	b8 92 3e 10 f0       	mov    $0xf0103e92,%eax
f0103840:	66 a3 68 61 1b f0    	mov    %ax,0xf01b6168
f0103846:	66 c7 05 6a 61 1b f0 	movw   $0x8,0xf01b616a
f010384d:	08 00 
f010384f:	c6 05 6c 61 1b f0 00 	movb   $0x0,0xf01b616c
f0103856:	c6 05 6d 61 1b f0 8f 	movb   $0x8f,0xf01b616d
f010385d:	c1 e8 10             	shr    $0x10,%eax
f0103860:	66 a3 6e 61 1b f0    	mov    %ax,0xf01b616e
	SETGATE(idt[T_ILLOP]  , 1, GD_KT, (void*)H_ILLOP  ,0);  
f0103866:	b8 98 3e 10 f0       	mov    $0xf0103e98,%eax
f010386b:	66 a3 70 61 1b f0    	mov    %ax,0xf01b6170
f0103871:	66 c7 05 72 61 1b f0 	movw   $0x8,0xf01b6172
f0103878:	08 00 
f010387a:	c6 05 74 61 1b f0 00 	movb   $0x0,0xf01b6174
f0103881:	c6 05 75 61 1b f0 8f 	movb   $0x8f,0xf01b6175
f0103888:	c1 e8 10             	shr    $0x10,%eax
f010388b:	66 a3 76 61 1b f0    	mov    %ax,0xf01b6176
	SETGATE(idt[T_DEVICE] , 1, GD_KT, (void*)H_DEVICE ,0);   
f0103891:	b8 9e 3e 10 f0       	mov    $0xf0103e9e,%eax
f0103896:	66 a3 78 61 1b f0    	mov    %ax,0xf01b6178
f010389c:	66 c7 05 7a 61 1b f0 	movw   $0x8,0xf01b617a
f01038a3:	08 00 
f01038a5:	c6 05 7c 61 1b f0 00 	movb   $0x0,0xf01b617c
f01038ac:	c6 05 7d 61 1b f0 8f 	movb   $0x8f,0xf01b617d
f01038b3:	c1 e8 10             	shr    $0x10,%eax
f01038b6:	66 a3 7e 61 1b f0    	mov    %ax,0xf01b617e
	SETGATE(idt[T_DBLFLT] , 1, GD_KT, (void*)H_DBLFLT ,0);   
f01038bc:	b8 a4 3e 10 f0       	mov    $0xf0103ea4,%eax
f01038c1:	66 a3 80 61 1b f0    	mov    %ax,0xf01b6180
f01038c7:	66 c7 05 82 61 1b f0 	movw   $0x8,0xf01b6182
f01038ce:	08 00 
f01038d0:	c6 05 84 61 1b f0 00 	movb   $0x0,0xf01b6184
f01038d7:	c6 05 85 61 1b f0 8f 	movb   $0x8f,0xf01b6185
f01038de:	c1 e8 10             	shr    $0x10,%eax
f01038e1:	66 a3 86 61 1b f0    	mov    %ax,0xf01b6186
	SETGATE(idt[T_TSS]    , 1, GD_KT, (void*)H_TSS    ,0);
f01038e7:	b8 a8 3e 10 f0       	mov    $0xf0103ea8,%eax
f01038ec:	66 a3 90 61 1b f0    	mov    %ax,0xf01b6190
f01038f2:	66 c7 05 92 61 1b f0 	movw   $0x8,0xf01b6192
f01038f9:	08 00 
f01038fb:	c6 05 94 61 1b f0 00 	movb   $0x0,0xf01b6194
f0103902:	c6 05 95 61 1b f0 8f 	movb   $0x8f,0xf01b6195
f0103909:	c1 e8 10             	shr    $0x10,%eax
f010390c:	66 a3 96 61 1b f0    	mov    %ax,0xf01b6196
	SETGATE(idt[T_SEGNP]  , 1, GD_KT, (void*)H_SEGNP  ,0);  
f0103912:	b8 ac 3e 10 f0       	mov    $0xf0103eac,%eax
f0103917:	66 a3 98 61 1b f0    	mov    %ax,0xf01b6198
f010391d:	66 c7 05 9a 61 1b f0 	movw   $0x8,0xf01b619a
f0103924:	08 00 
f0103926:	c6 05 9c 61 1b f0 00 	movb   $0x0,0xf01b619c
f010392d:	c6 05 9d 61 1b f0 8f 	movb   $0x8f,0xf01b619d
f0103934:	c1 e8 10             	shr    $0x10,%eax
f0103937:	66 a3 9e 61 1b f0    	mov    %ax,0xf01b619e
	SETGATE(idt[T_STACK]  , 1, GD_KT, (void*)H_STACK  ,0);  
f010393d:	b8 b0 3e 10 f0       	mov    $0xf0103eb0,%eax
f0103942:	66 a3 a0 61 1b f0    	mov    %ax,0xf01b61a0
f0103948:	66 c7 05 a2 61 1b f0 	movw   $0x8,0xf01b61a2
f010394f:	08 00 
f0103951:	c6 05 a4 61 1b f0 00 	movb   $0x0,0xf01b61a4
f0103958:	c6 05 a5 61 1b f0 8f 	movb   $0x8f,0xf01b61a5
f010395f:	c1 e8 10             	shr    $0x10,%eax
f0103962:	66 a3 a6 61 1b f0    	mov    %ax,0xf01b61a6
	SETGATE(idt[T_GPFLT]  , 1, GD_KT, (void*)H_GPFLT  ,0);  
f0103968:	b8 b4 3e 10 f0       	mov    $0xf0103eb4,%eax
f010396d:	66 a3 a8 61 1b f0    	mov    %ax,0xf01b61a8
f0103973:	66 c7 05 aa 61 1b f0 	movw   $0x8,0xf01b61aa
f010397a:	08 00 
f010397c:	c6 05 ac 61 1b f0 00 	movb   $0x0,0xf01b61ac
f0103983:	c6 05 ad 61 1b f0 8f 	movb   $0x8f,0xf01b61ad
f010398a:	c1 e8 10             	shr    $0x10,%eax
f010398d:	66 a3 ae 61 1b f0    	mov    %ax,0xf01b61ae
	SETGATE(idt[T_PGFLT]  , 1, GD_KT, (void*)H_PGFLT  ,0);  
f0103993:	b8 b8 3e 10 f0       	mov    $0xf0103eb8,%eax
f0103998:	66 a3 b0 61 1b f0    	mov    %ax,0xf01b61b0
f010399e:	66 c7 05 b2 61 1b f0 	movw   $0x8,0xf01b61b2
f01039a5:	08 00 
f01039a7:	c6 05 b4 61 1b f0 00 	movb   $0x0,0xf01b61b4
f01039ae:	c6 05 b5 61 1b f0 8f 	movb   $0x8f,0xf01b61b5
f01039b5:	c1 e8 10             	shr    $0x10,%eax
f01039b8:	66 a3 b6 61 1b f0    	mov    %ax,0xf01b61b6
	SETGATE(idt[T_FPERR]  , 1, GD_KT, (void*)H_FPERR  ,0);  
f01039be:	b8 bc 3e 10 f0       	mov    $0xf0103ebc,%eax
f01039c3:	66 a3 c0 61 1b f0    	mov    %ax,0xf01b61c0
f01039c9:	66 c7 05 c2 61 1b f0 	movw   $0x8,0xf01b61c2
f01039d0:	08 00 
f01039d2:	c6 05 c4 61 1b f0 00 	movb   $0x0,0xf01b61c4
f01039d9:	c6 05 c5 61 1b f0 8f 	movb   $0x8f,0xf01b61c5
f01039e0:	c1 e8 10             	shr    $0x10,%eax
f01039e3:	66 a3 c6 61 1b f0    	mov    %ax,0xf01b61c6
	SETGATE(idt[T_ALIGN]  , 1, GD_KT, (void*)H_ALIGN  ,0);  
f01039e9:	b8 c2 3e 10 f0       	mov    $0xf0103ec2,%eax
f01039ee:	66 a3 c8 61 1b f0    	mov    %ax,0xf01b61c8
f01039f4:	66 c7 05 ca 61 1b f0 	movw   $0x8,0xf01b61ca
f01039fb:	08 00 
f01039fd:	c6 05 cc 61 1b f0 00 	movb   $0x0,0xf01b61cc
f0103a04:	c6 05 cd 61 1b f0 8f 	movb   $0x8f,0xf01b61cd
f0103a0b:	c1 e8 10             	shr    $0x10,%eax
f0103a0e:	66 a3 ce 61 1b f0    	mov    %ax,0xf01b61ce
	SETGATE(idt[T_MCHK]   , 1, GD_KT, (void*)H_MCHK   ,0); 
f0103a14:	b8 c8 3e 10 f0       	mov    $0xf0103ec8,%eax
f0103a19:	66 a3 d0 61 1b f0    	mov    %ax,0xf01b61d0
f0103a1f:	66 c7 05 d2 61 1b f0 	movw   $0x8,0xf01b61d2
f0103a26:	08 00 
f0103a28:	c6 05 d4 61 1b f0 00 	movb   $0x0,0xf01b61d4
f0103a2f:	c6 05 d5 61 1b f0 8f 	movb   $0x8f,0xf01b61d5
f0103a36:	c1 e8 10             	shr    $0x10,%eax
f0103a39:	66 a3 d6 61 1b f0    	mov    %ax,0xf01b61d6
	SETGATE(idt[T_SIMDERR], 1, GD_KT, (void*)H_SIMDERR,0);  
f0103a3f:	b8 ce 3e 10 f0       	mov    $0xf0103ece,%eax
f0103a44:	66 a3 d8 61 1b f0    	mov    %ax,0xf01b61d8
f0103a4a:	66 c7 05 da 61 1b f0 	movw   $0x8,0xf01b61da
f0103a51:	08 00 
f0103a53:	c6 05 dc 61 1b f0 00 	movb   $0x0,0xf01b61dc
f0103a5a:	c6 05 dd 61 1b f0 8f 	movb   $0x8f,0xf01b61dd
f0103a61:	c1 e8 10             	shr    $0x10,%eax
f0103a64:	66 a3 de 61 1b f0    	mov    %ax,0xf01b61de
	SETGATE(idt[T_SYSCALL], 1, GD_KT, (void*)H_SYSCALL,3);  // System call
f0103a6a:	b8 d4 3e 10 f0       	mov    $0xf0103ed4,%eax
f0103a6f:	66 a3 c0 62 1b f0    	mov    %ax,0xf01b62c0
f0103a75:	66 c7 05 c2 62 1b f0 	movw   $0x8,0xf01b62c2
f0103a7c:	08 00 
f0103a7e:	c6 05 c4 62 1b f0 00 	movb   $0x0,0xf01b62c4
f0103a85:	c6 05 c5 62 1b f0 ef 	movb   $0xef,0xf01b62c5
f0103a8c:	c1 e8 10             	shr    $0x10,%eax
f0103a8f:	66 a3 c6 62 1b f0    	mov    %ax,0xf01b62c6
	trap_init_percpu();
f0103a95:	e8 61 fc ff ff       	call   f01036fb <trap_init_percpu>
}
f0103a9a:	5d                   	pop    %ebp
f0103a9b:	c3                   	ret    

f0103a9c <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103a9c:	55                   	push   %ebp
f0103a9d:	89 e5                	mov    %esp,%ebp
f0103a9f:	53                   	push   %ebx
f0103aa0:	83 ec 0c             	sub    $0xc,%esp
f0103aa3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103aa6:	ff 33                	pushl  (%ebx)
f0103aa8:	68 57 64 10 f0       	push   $0xf0106457
f0103aad:	e8 35 fc ff ff       	call   f01036e7 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103ab2:	83 c4 08             	add    $0x8,%esp
f0103ab5:	ff 73 04             	pushl  0x4(%ebx)
f0103ab8:	68 66 64 10 f0       	push   $0xf0106466
f0103abd:	e8 25 fc ff ff       	call   f01036e7 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103ac2:	83 c4 08             	add    $0x8,%esp
f0103ac5:	ff 73 08             	pushl  0x8(%ebx)
f0103ac8:	68 75 64 10 f0       	push   $0xf0106475
f0103acd:	e8 15 fc ff ff       	call   f01036e7 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103ad2:	83 c4 08             	add    $0x8,%esp
f0103ad5:	ff 73 0c             	pushl  0xc(%ebx)
f0103ad8:	68 84 64 10 f0       	push   $0xf0106484
f0103add:	e8 05 fc ff ff       	call   f01036e7 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103ae2:	83 c4 08             	add    $0x8,%esp
f0103ae5:	ff 73 10             	pushl  0x10(%ebx)
f0103ae8:	68 93 64 10 f0       	push   $0xf0106493
f0103aed:	e8 f5 fb ff ff       	call   f01036e7 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103af2:	83 c4 08             	add    $0x8,%esp
f0103af5:	ff 73 14             	pushl  0x14(%ebx)
f0103af8:	68 a2 64 10 f0       	push   $0xf01064a2
f0103afd:	e8 e5 fb ff ff       	call   f01036e7 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103b02:	83 c4 08             	add    $0x8,%esp
f0103b05:	ff 73 18             	pushl  0x18(%ebx)
f0103b08:	68 b1 64 10 f0       	push   $0xf01064b1
f0103b0d:	e8 d5 fb ff ff       	call   f01036e7 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103b12:	83 c4 08             	add    $0x8,%esp
f0103b15:	ff 73 1c             	pushl  0x1c(%ebx)
f0103b18:	68 c0 64 10 f0       	push   $0xf01064c0
f0103b1d:	e8 c5 fb ff ff       	call   f01036e7 <cprintf>
}
f0103b22:	83 c4 10             	add    $0x10,%esp
f0103b25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103b28:	c9                   	leave  
f0103b29:	c3                   	ret    

f0103b2a <print_trapframe>:
{
f0103b2a:	55                   	push   %ebp
f0103b2b:	89 e5                	mov    %esp,%ebp
f0103b2d:	53                   	push   %ebx
f0103b2e:	83 ec 0c             	sub    $0xc,%esp
f0103b31:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103b34:	53                   	push   %ebx
f0103b35:	68 11 66 10 f0       	push   $0xf0106611
f0103b3a:	e8 a8 fb ff ff       	call   f01036e7 <cprintf>
	print_regs(&tf->tf_regs);
f0103b3f:	89 1c 24             	mov    %ebx,(%esp)
f0103b42:	e8 55 ff ff ff       	call   f0103a9c <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103b47:	83 c4 08             	add    $0x8,%esp
f0103b4a:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103b4e:	50                   	push   %eax
f0103b4f:	68 11 65 10 f0       	push   $0xf0106511
f0103b54:	e8 8e fb ff ff       	call   f01036e7 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103b59:	83 c4 08             	add    $0x8,%esp
f0103b5c:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103b60:	50                   	push   %eax
f0103b61:	68 24 65 10 f0       	push   $0xf0106524
f0103b66:	e8 7c fb ff ff       	call   f01036e7 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103b6b:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0103b6e:	83 c4 10             	add    $0x10,%esp
f0103b71:	83 f8 13             	cmp    $0x13,%eax
f0103b74:	76 10                	jbe    f0103b86 <print_trapframe+0x5c>
	if (trapno == T_SYSCALL)
f0103b76:	83 f8 30             	cmp    $0x30,%eax
f0103b79:	0f 84 c3 00 00 00    	je     f0103c42 <print_trapframe+0x118>
	return "(unknown trap)";
f0103b7f:	ba db 64 10 f0       	mov    $0xf01064db,%edx
f0103b84:	eb 07                	jmp    f0103b8d <print_trapframe+0x63>
		return excnames[trapno];
f0103b86:	8b 14 85 e0 67 10 f0 	mov    -0xfef9820(,%eax,4),%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103b8d:	83 ec 04             	sub    $0x4,%esp
f0103b90:	52                   	push   %edx
f0103b91:	50                   	push   %eax
f0103b92:	68 37 65 10 f0       	push   $0xf0106537
f0103b97:	e8 4b fb ff ff       	call   f01036e7 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103b9c:	83 c4 10             	add    $0x10,%esp
f0103b9f:	39 1d 40 69 1b f0    	cmp    %ebx,0xf01b6940
f0103ba5:	0f 84 a1 00 00 00    	je     f0103c4c <print_trapframe+0x122>
	cprintf("  err  0x%08x", tf->tf_err);
f0103bab:	83 ec 08             	sub    $0x8,%esp
f0103bae:	ff 73 2c             	pushl  0x2c(%ebx)
f0103bb1:	68 58 65 10 f0       	push   $0xf0106558
f0103bb6:	e8 2c fb ff ff       	call   f01036e7 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103bbb:	83 c4 10             	add    $0x10,%esp
f0103bbe:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103bc2:	0f 85 c5 00 00 00    	jne    f0103c8d <print_trapframe+0x163>
			tf->tf_err & 1 ? "protection" : "not-present");
f0103bc8:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0103bcb:	a8 01                	test   $0x1,%al
f0103bcd:	0f 85 9c 00 00 00    	jne    f0103c6f <print_trapframe+0x145>
f0103bd3:	b9 f5 64 10 f0       	mov    $0xf01064f5,%ecx
f0103bd8:	a8 02                	test   $0x2,%al
f0103bda:	0f 85 99 00 00 00    	jne    f0103c79 <print_trapframe+0x14f>
f0103be0:	ba 07 65 10 f0       	mov    $0xf0106507,%edx
f0103be5:	a8 04                	test   $0x4,%al
f0103be7:	0f 85 96 00 00 00    	jne    f0103c83 <print_trapframe+0x159>
f0103bed:	b8 3c 66 10 f0       	mov    $0xf010663c,%eax
f0103bf2:	51                   	push   %ecx
f0103bf3:	52                   	push   %edx
f0103bf4:	50                   	push   %eax
f0103bf5:	68 66 65 10 f0       	push   $0xf0106566
f0103bfa:	e8 e8 fa ff ff       	call   f01036e7 <cprintf>
f0103bff:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103c02:	83 ec 08             	sub    $0x8,%esp
f0103c05:	ff 73 30             	pushl  0x30(%ebx)
f0103c08:	68 75 65 10 f0       	push   $0xf0106575
f0103c0d:	e8 d5 fa ff ff       	call   f01036e7 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103c12:	83 c4 08             	add    $0x8,%esp
f0103c15:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103c19:	50                   	push   %eax
f0103c1a:	68 84 65 10 f0       	push   $0xf0106584
f0103c1f:	e8 c3 fa ff ff       	call   f01036e7 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103c24:	83 c4 08             	add    $0x8,%esp
f0103c27:	ff 73 38             	pushl  0x38(%ebx)
f0103c2a:	68 97 65 10 f0       	push   $0xf0106597
f0103c2f:	e8 b3 fa ff ff       	call   f01036e7 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103c34:	83 c4 10             	add    $0x10,%esp
f0103c37:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103c3b:	75 65                	jne    f0103ca2 <print_trapframe+0x178>
}
f0103c3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103c40:	c9                   	leave  
f0103c41:	c3                   	ret    
		return "System call";
f0103c42:	ba cf 64 10 f0       	mov    $0xf01064cf,%edx
f0103c47:	e9 41 ff ff ff       	jmp    f0103b8d <print_trapframe+0x63>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103c4c:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103c50:	0f 85 55 ff ff ff    	jne    f0103bab <print_trapframe+0x81>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103c56:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103c59:	83 ec 08             	sub    $0x8,%esp
f0103c5c:	50                   	push   %eax
f0103c5d:	68 49 65 10 f0       	push   $0xf0106549
f0103c62:	e8 80 fa ff ff       	call   f01036e7 <cprintf>
f0103c67:	83 c4 10             	add    $0x10,%esp
f0103c6a:	e9 3c ff ff ff       	jmp    f0103bab <print_trapframe+0x81>
		cprintf(" [%s, %s, %s]\n",
f0103c6f:	b9 ea 64 10 f0       	mov    $0xf01064ea,%ecx
f0103c74:	e9 5f ff ff ff       	jmp    f0103bd8 <print_trapframe+0xae>
f0103c79:	ba 01 65 10 f0       	mov    $0xf0106501,%edx
f0103c7e:	e9 62 ff ff ff       	jmp    f0103be5 <print_trapframe+0xbb>
f0103c83:	b8 0c 65 10 f0       	mov    $0xf010650c,%eax
f0103c88:	e9 65 ff ff ff       	jmp    f0103bf2 <print_trapframe+0xc8>
		cprintf("\n");
f0103c8d:	83 ec 0c             	sub    $0xc,%esp
f0103c90:	68 fb 53 10 f0       	push   $0xf01053fb
f0103c95:	e8 4d fa ff ff       	call   f01036e7 <cprintf>
f0103c9a:	83 c4 10             	add    $0x10,%esp
f0103c9d:	e9 60 ff ff ff       	jmp    f0103c02 <print_trapframe+0xd8>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103ca2:	83 ec 08             	sub    $0x8,%esp
f0103ca5:	ff 73 3c             	pushl  0x3c(%ebx)
f0103ca8:	68 a6 65 10 f0       	push   $0xf01065a6
f0103cad:	e8 35 fa ff ff       	call   f01036e7 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103cb2:	83 c4 08             	add    $0x8,%esp
f0103cb5:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103cb9:	50                   	push   %eax
f0103cba:	68 b5 65 10 f0       	push   $0xf01065b5
f0103cbf:	e8 23 fa ff ff       	call   f01036e7 <cprintf>
f0103cc4:	83 c4 10             	add    $0x10,%esp
}
f0103cc7:	e9 71 ff ff ff       	jmp    f0103c3d <print_trapframe+0x113>

f0103ccc <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103ccc:	55                   	push   %ebp
f0103ccd:	89 e5                	mov    %esp,%ebp
f0103ccf:	53                   	push   %ebx
f0103cd0:	83 ec 04             	sub    $0x4,%esp
f0103cd3:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103cd6:	0f 20 d0             	mov    %cr2,%eax

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	uint16_t cs = tf->tf_cs;
	if ((cs & 0xFF) == GD_KT) // code segment descriptor is kernel
f0103cd9:	80 7b 34 08          	cmpb   $0x8,0x34(%ebx)
f0103cdd:	74 34                	je     f0103d13 <page_fault_handler+0x47>

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103cdf:	ff 73 30             	pushl  0x30(%ebx)
f0103ce2:	50                   	push   %eax
f0103ce3:	a1 28 61 1b f0       	mov    0xf01b6128,%eax
f0103ce8:	ff 70 48             	pushl  0x48(%eax)
f0103ceb:	68 88 67 10 f0       	push   $0xf0106788
f0103cf0:	e8 f2 f9 ff ff       	call   f01036e7 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103cf5:	89 1c 24             	mov    %ebx,(%esp)
f0103cf8:	e8 2d fe ff ff       	call   f0103b2a <print_trapframe>
	env_destroy(curenv);
f0103cfd:	83 c4 04             	add    $0x4,%esp
f0103d00:	ff 35 28 61 1b f0    	pushl  0xf01b6128
f0103d06:	e8 c2 f8 ff ff       	call   f01035cd <env_destroy>
}
f0103d0b:	83 c4 10             	add    $0x10,%esp
f0103d0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103d11:	c9                   	leave  
f0103d12:	c3                   	ret    
		panic("Page fault in kernel mode!");
f0103d13:	83 ec 04             	sub    $0x4,%esp
f0103d16:	68 c8 65 10 f0       	push   $0xf01065c8
f0103d1b:	68 fd 00 00 00       	push   $0xfd
f0103d20:	68 e3 65 10 f0       	push   $0xf01065e3
f0103d25:	e8 1e c4 ff ff       	call   f0100148 <_panic>

f0103d2a <trap>:
{
f0103d2a:	55                   	push   %ebp
f0103d2b:	89 e5                	mov    %esp,%ebp
f0103d2d:	57                   	push   %edi
f0103d2e:	56                   	push   %esi
f0103d2f:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f0103d32:	fc                   	cld    
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103d33:	9c                   	pushf  
f0103d34:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f0103d35:	f6 c4 02             	test   $0x2,%ah
f0103d38:	74 19                	je     f0103d53 <trap+0x29>
f0103d3a:	68 ef 65 10 f0       	push   $0xf01065ef
f0103d3f:	68 5f 60 10 f0       	push   $0xf010605f
f0103d44:	68 d6 00 00 00       	push   $0xd6
f0103d49:	68 e3 65 10 f0       	push   $0xf01065e3
f0103d4e:	e8 f5 c3 ff ff       	call   f0100148 <_panic>
	cprintf("Incoming TRAP frame at %p\n", tf);
f0103d53:	83 ec 08             	sub    $0x8,%esp
f0103d56:	56                   	push   %esi
f0103d57:	68 08 66 10 f0       	push   $0xf0106608
f0103d5c:	e8 86 f9 ff ff       	call   f01036e7 <cprintf>
	if ((tf->tf_cs & 3) == 3) {
f0103d61:	66 8b 46 34          	mov    0x34(%esi),%ax
f0103d65:	83 e0 03             	and    $0x3,%eax
f0103d68:	83 c4 10             	add    $0x10,%esp
f0103d6b:	66 83 f8 03          	cmp    $0x3,%ax
f0103d6f:	75 18                	jne    f0103d89 <trap+0x5f>
		assert(curenv);
f0103d71:	a1 28 61 1b f0       	mov    0xf01b6128,%eax
f0103d76:	85 c0                	test   %eax,%eax
f0103d78:	74 46                	je     f0103dc0 <trap+0x96>
		curenv->env_tf = *tf;
f0103d7a:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103d7f:	89 c7                	mov    %eax,%edi
f0103d81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0103d83:	8b 35 28 61 1b f0    	mov    0xf01b6128,%esi
	last_tf = tf;
f0103d89:	89 35 40 69 1b f0    	mov    %esi,0xf01b6940
	switch(tf->tf_trapno){
f0103d8f:	8b 46 28             	mov    0x28(%esi),%eax
f0103d92:	83 f8 0e             	cmp    $0xe,%eax
f0103d95:	74 42                	je     f0103dd9 <trap+0xaf>
f0103d97:	83 f8 30             	cmp    $0x30,%eax
f0103d9a:	74 71                	je     f0103e0d <trap+0xe3>
f0103d9c:	83 f8 03             	cmp    $0x3,%eax
f0103d9f:	0f 85 89 00 00 00    	jne    f0103e2e <trap+0x104>
		print_trapframe(tf);
f0103da5:	83 ec 0c             	sub    $0xc,%esp
f0103da8:	56                   	push   %esi
f0103da9:	e8 7c fd ff ff       	call   f0103b2a <print_trapframe>
f0103dae:	83 c4 10             	add    $0x10,%esp
			monitor(NULL);
f0103db1:	83 ec 0c             	sub    $0xc,%esp
f0103db4:	6a 00                	push   $0x0
f0103db6:	e8 c8 ce ff ff       	call   f0100c83 <monitor>
f0103dbb:	83 c4 10             	add    $0x10,%esp
f0103dbe:	eb f1                	jmp    f0103db1 <trap+0x87>
		assert(curenv);
f0103dc0:	68 23 66 10 f0       	push   $0xf0106623
f0103dc5:	68 5f 60 10 f0       	push   $0xf010605f
f0103dca:	68 dc 00 00 00       	push   $0xdc
f0103dcf:	68 e3 65 10 f0       	push   $0xf01065e3
f0103dd4:	e8 6f c3 ff ff       	call   f0100148 <_panic>
		page_fault_handler(tf);
f0103dd9:	83 ec 0c             	sub    $0xc,%esp
f0103ddc:	56                   	push   %esi
f0103ddd:	e8 ea fe ff ff       	call   f0103ccc <page_fault_handler>
f0103de2:	83 c4 10             	add    $0x10,%esp
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103de5:	a1 28 61 1b f0       	mov    0xf01b6128,%eax
f0103dea:	85 c0                	test   %eax,%eax
f0103dec:	74 06                	je     f0103df4 <trap+0xca>
f0103dee:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103df2:	74 77                	je     f0103e6b <trap+0x141>
f0103df4:	68 ac 67 10 f0       	push   $0xf01067ac
f0103df9:	68 5f 60 10 f0       	push   $0xf010605f
f0103dfe:	68 ee 00 00 00       	push   $0xee
f0103e03:	68 e3 65 10 f0       	push   $0xf01065e3
f0103e08:	e8 3b c3 ff ff       	call   f0100148 <_panic>
		tf->tf_regs.reg_eax = syscall(
f0103e0d:	83 ec 08             	sub    $0x8,%esp
f0103e10:	ff 76 04             	pushl  0x4(%esi)
f0103e13:	ff 36                	pushl  (%esi)
f0103e15:	ff 76 10             	pushl  0x10(%esi)
f0103e18:	ff 76 18             	pushl  0x18(%esi)
f0103e1b:	ff 76 14             	pushl  0x14(%esi)
f0103e1e:	ff 76 1c             	pushl  0x1c(%esi)
f0103e21:	e8 c5 00 00 00       	call   f0103eeb <syscall>
f0103e26:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103e29:	83 c4 20             	add    $0x20,%esp
f0103e2c:	eb b7                	jmp    f0103de5 <trap+0xbb>
	print_trapframe(tf);
f0103e2e:	83 ec 0c             	sub    $0xc,%esp
f0103e31:	56                   	push   %esi
f0103e32:	e8 f3 fc ff ff       	call   f0103b2a <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103e37:	83 c4 10             	add    $0x10,%esp
f0103e3a:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103e3f:	74 13                	je     f0103e54 <trap+0x12a>
		env_destroy(curenv);
f0103e41:	83 ec 0c             	sub    $0xc,%esp
f0103e44:	ff 35 28 61 1b f0    	pushl  0xf01b6128
f0103e4a:	e8 7e f7 ff ff       	call   f01035cd <env_destroy>
f0103e4f:	83 c4 10             	add    $0x10,%esp
f0103e52:	eb 91                	jmp    f0103de5 <trap+0xbb>
		panic("unhandled trap in kernel");
f0103e54:	83 ec 04             	sub    $0x4,%esp
f0103e57:	68 2a 66 10 f0       	push   $0xf010662a
f0103e5c:	68 c5 00 00 00       	push   $0xc5
f0103e61:	68 e3 65 10 f0       	push   $0xf01065e3
f0103e66:	e8 dd c2 ff ff       	call   f0100148 <_panic>
	env_run(curenv);
f0103e6b:	83 ec 0c             	sub    $0xc,%esp
f0103e6e:	50                   	push   %eax
f0103e6f:	e8 a9 f7 ff ff       	call   f010361d <env_run>

f0103e74 <H_DIVIDE>:
	pushl $(num);							\
	jmp _alltraps

.text

TRAPHANDLER_NOEC(H_DIVIDE , T_DIVIDE)
f0103e74:	6a 00                	push   $0x0
f0103e76:	6a 00                	push   $0x0
f0103e78:	eb 60                	jmp    f0103eda <_alltraps>

f0103e7a <H_DEBUG>:
TRAPHANDLER_NOEC(H_DEBUG  , T_DEBUG)
f0103e7a:	6a 00                	push   $0x0
f0103e7c:	6a 01                	push   $0x1
f0103e7e:	eb 5a                	jmp    f0103eda <_alltraps>

f0103e80 <H_NMI>:
TRAPHANDLER_NOEC(H_NMI    , T_NMI)
f0103e80:	6a 00                	push   $0x0
f0103e82:	6a 02                	push   $0x2
f0103e84:	eb 54                	jmp    f0103eda <_alltraps>

f0103e86 <H_BRKPT>:
TRAPHANDLER_NOEC(H_BRKPT  , T_BRKPT)
f0103e86:	6a 00                	push   $0x0
f0103e88:	6a 03                	push   $0x3
f0103e8a:	eb 4e                	jmp    f0103eda <_alltraps>

f0103e8c <H_OFLOW>:
TRAPHANDLER_NOEC(H_OFLOW  , T_OFLOW)
f0103e8c:	6a 00                	push   $0x0
f0103e8e:	6a 04                	push   $0x4
f0103e90:	eb 48                	jmp    f0103eda <_alltraps>

f0103e92 <H_BOUND>:
TRAPHANDLER_NOEC(H_BOUND  , T_BOUND)
f0103e92:	6a 00                	push   $0x0
f0103e94:	6a 05                	push   $0x5
f0103e96:	eb 42                	jmp    f0103eda <_alltraps>

f0103e98 <H_ILLOP>:
TRAPHANDLER_NOEC(H_ILLOP  , T_ILLOP)
f0103e98:	6a 00                	push   $0x0
f0103e9a:	6a 06                	push   $0x6
f0103e9c:	eb 3c                	jmp    f0103eda <_alltraps>

f0103e9e <H_DEVICE>:
TRAPHANDLER_NOEC(H_DEVICE , T_DEVICE)
f0103e9e:	6a 00                	push   $0x0
f0103ea0:	6a 07                	push   $0x7
f0103ea2:	eb 36                	jmp    f0103eda <_alltraps>

f0103ea4 <H_DBLFLT>:
TRAPHANDLER     (H_DBLFLT , T_DBLFLT)	// Error Code const 0
f0103ea4:	6a 08                	push   $0x8
f0103ea6:	eb 32                	jmp    f0103eda <_alltraps>

f0103ea8 <H_TSS>:
TRAPHANDLER     (H_TSS    , T_TSS)
f0103ea8:	6a 0a                	push   $0xa
f0103eaa:	eb 2e                	jmp    f0103eda <_alltraps>

f0103eac <H_SEGNP>:
TRAPHANDLER     (H_SEGNP  , T_SEGNP)
f0103eac:	6a 0b                	push   $0xb
f0103eae:	eb 2a                	jmp    f0103eda <_alltraps>

f0103eb0 <H_STACK>:
TRAPHANDLER     (H_STACK  , T_STACK)
f0103eb0:	6a 0c                	push   $0xc
f0103eb2:	eb 26                	jmp    f0103eda <_alltraps>

f0103eb4 <H_GPFLT>:
TRAPHANDLER     (H_GPFLT  , T_GPFLT)
f0103eb4:	6a 0d                	push   $0xd
f0103eb6:	eb 22                	jmp    f0103eda <_alltraps>

f0103eb8 <H_PGFLT>:
TRAPHANDLER     (H_PGFLT  , T_PGFLT)
f0103eb8:	6a 0e                	push   $0xe
f0103eba:	eb 1e                	jmp    f0103eda <_alltraps>

f0103ebc <H_FPERR>:
TRAPHANDLER_NOEC(H_FPERR  , T_FPERR)
f0103ebc:	6a 00                	push   $0x0
f0103ebe:	6a 10                	push   $0x10
f0103ec0:	eb 18                	jmp    f0103eda <_alltraps>

f0103ec2 <H_ALIGN>:
TRAPHANDLER_NOEC(H_ALIGN  , T_ALIGN)
f0103ec2:	6a 00                	push   $0x0
f0103ec4:	6a 11                	push   $0x11
f0103ec6:	eb 12                	jmp    f0103eda <_alltraps>

f0103ec8 <H_MCHK>:
TRAPHANDLER_NOEC(H_MCHK   , T_MCHK)
f0103ec8:	6a 00                	push   $0x0
f0103eca:	6a 12                	push   $0x12
f0103ecc:	eb 0c                	jmp    f0103eda <_alltraps>

f0103ece <H_SIMDERR>:
TRAPHANDLER_NOEC(H_SIMDERR, T_SIMDERR)
f0103ece:	6a 00                	push   $0x0
f0103ed0:	6a 13                	push   $0x13
f0103ed2:	eb 06                	jmp    f0103eda <_alltraps>

f0103ed4 <H_SYSCALL>:

TRAPHANDLER_NOEC(H_SYSCALL, T_SYSCALL)  // System call.
f0103ed4:	6a 00                	push   $0x0
f0103ed6:	6a 30                	push   $0x30
f0103ed8:	eb 00                	jmp    f0103eda <_alltraps>

f0103eda <_alltraps>:

_alltraps:
/* Processor has pushed ss, esp, eflags, cs, eip, and [error] */
/* TRAPHANDLER did [error] and trapno */
	pushl  %ds;
f0103eda:	1e                   	push   %ds
	pushl  %es;
f0103edb:	06                   	push   %es
	pushal;
f0103edc:	60                   	pusha  
	movw   $GD_KD, %ax;
f0103edd:	66 b8 10 00          	mov    $0x10,%ax
	movw   %ax   , %ds;
f0103ee1:	8e d8                	mov    %eax,%ds
	movw   %ax   , %es;
f0103ee3:	8e c0                	mov    %eax,%es
	pushl  %esp;
f0103ee5:	54                   	push   %esp
	call   trap
f0103ee6:	e8 3f fe ff ff       	call   f0103d2a <trap>

f0103eeb <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103eeb:	55                   	push   %ebp
f0103eec:	89 e5                	mov    %esp,%ebp
f0103eee:	83 ec 18             	sub    $0x18,%esp
f0103ef1:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	switch (syscallno) {
f0103ef4:	83 f8 01             	cmp    $0x1,%eax
f0103ef7:	74 46                	je     f0103f3f <syscall+0x54>
f0103ef9:	83 f8 01             	cmp    $0x1,%eax
f0103efc:	72 11                	jb     f0103f0f <syscall+0x24>
f0103efe:	83 f8 02             	cmp    $0x2,%eax
f0103f01:	74 43                	je     f0103f46 <syscall+0x5b>
f0103f03:	83 f8 03             	cmp    $0x3,%eax
f0103f06:	74 48                	je     f0103f50 <syscall+0x65>
	case SYS_getenvid:
		return sys_getenvid();
	case SYS_env_destroy:
		return sys_env_destroy(a1);
	default:
		return -E_INVAL;
f0103f08:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103f0d:	eb 2e                	jmp    f0103f3d <syscall+0x52>
		user_mem_assert(curenv, (const void*)a1, a2, PTE_U);  // The memory is readable.
f0103f0f:	6a 04                	push   $0x4
f0103f11:	ff 75 10             	pushl  0x10(%ebp)
f0103f14:	ff 75 0c             	pushl  0xc(%ebp)
f0103f17:	ff 35 28 61 1b f0    	pushl  0xf01b6128
f0103f1d:	e8 cd ef ff ff       	call   f0102eef <user_mem_assert>
	cprintf("%.*s", len, s);
f0103f22:	83 c4 0c             	add    $0xc,%esp
f0103f25:	ff 75 0c             	pushl  0xc(%ebp)
f0103f28:	ff 75 10             	pushl  0x10(%ebp)
f0103f2b:	68 30 68 10 f0       	push   $0xf0106830
f0103f30:	e8 b2 f7 ff ff       	call   f01036e7 <cprintf>
f0103f35:	83 c4 10             	add    $0x10,%esp
		return 0;
f0103f38:	b8 00 00 00 00       	mov    $0x0,%eax
	}
}
f0103f3d:	c9                   	leave  
f0103f3e:	c3                   	ret    
	return cons_getc();
f0103f3f:	e8 15 c6 ff ff       	call   f0100559 <cons_getc>
		return sys_cgetc();
f0103f44:	eb f7                	jmp    f0103f3d <syscall+0x52>
	return curenv->env_id;
f0103f46:	a1 28 61 1b f0       	mov    0xf01b6128,%eax
f0103f4b:	8b 40 48             	mov    0x48(%eax),%eax
		return sys_getenvid();
f0103f4e:	eb ed                	jmp    f0103f3d <syscall+0x52>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0103f50:	83 ec 04             	sub    $0x4,%esp
f0103f53:	6a 01                	push   $0x1
f0103f55:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103f58:	50                   	push   %eax
f0103f59:	ff 75 0c             	pushl  0xc(%ebp)
f0103f5c:	e8 da ef ff ff       	call   f0102f3b <envid2env>
f0103f61:	83 c4 10             	add    $0x10,%esp
f0103f64:	85 c0                	test   %eax,%eax
f0103f66:	78 d5                	js     f0103f3d <syscall+0x52>
	if (e == curenv)
f0103f68:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103f6b:	a1 28 61 1b f0       	mov    0xf01b6128,%eax
f0103f70:	39 c2                	cmp    %eax,%edx
f0103f72:	74 2b                	je     f0103f9f <syscall+0xb4>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0103f74:	83 ec 04             	sub    $0x4,%esp
f0103f77:	ff 72 48             	pushl  0x48(%edx)
f0103f7a:	ff 70 48             	pushl  0x48(%eax)
f0103f7d:	68 50 68 10 f0       	push   $0xf0106850
f0103f82:	e8 60 f7 ff ff       	call   f01036e7 <cprintf>
f0103f87:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0103f8a:	83 ec 0c             	sub    $0xc,%esp
f0103f8d:	ff 75 f4             	pushl  -0xc(%ebp)
f0103f90:	e8 38 f6 ff ff       	call   f01035cd <env_destroy>
f0103f95:	83 c4 10             	add    $0x10,%esp
	return 0;
f0103f98:	b8 00 00 00 00       	mov    $0x0,%eax
		return sys_env_destroy(a1);
f0103f9d:	eb 9e                	jmp    f0103f3d <syscall+0x52>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103f9f:	83 ec 08             	sub    $0x8,%esp
f0103fa2:	ff 70 48             	pushl  0x48(%eax)
f0103fa5:	68 35 68 10 f0       	push   $0xf0106835
f0103faa:	e8 38 f7 ff ff       	call   f01036e7 <cprintf>
f0103faf:	83 c4 10             	add    $0x10,%esp
f0103fb2:	eb d6                	jmp    f0103f8a <syscall+0x9f>

f0103fb4 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103fb4:	55                   	push   %ebp
f0103fb5:	89 e5                	mov    %esp,%ebp
f0103fb7:	57                   	push   %edi
f0103fb8:	56                   	push   %esi
f0103fb9:	53                   	push   %ebx
f0103fba:	83 ec 14             	sub    $0x14,%esp
f0103fbd:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103fc0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103fc3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103fc6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103fc9:	8b 32                	mov    (%edx),%esi
f0103fcb:	8b 01                	mov    (%ecx),%eax
f0103fcd:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103fd0:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103fd7:	eb 2f                	jmp    f0104008 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0103fd9:	48                   	dec    %eax
		while (m >= l && stabs[m].n_type != type)
f0103fda:	39 c6                	cmp    %eax,%esi
f0103fdc:	7f 4d                	jg     f010402b <stab_binsearch+0x77>
f0103fde:	0f b6 0a             	movzbl (%edx),%ecx
f0103fe1:	83 ea 0c             	sub    $0xc,%edx
f0103fe4:	39 f9                	cmp    %edi,%ecx
f0103fe6:	75 f1                	jne    f0103fd9 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103fe8:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103feb:	01 c2                	add    %eax,%edx
f0103fed:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103ff0:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103ff4:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103ff7:	73 37                	jae    f0104030 <stab_binsearch+0x7c>
			*region_left = m;
f0103ff9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103ffc:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0103ffe:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0104001:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104008:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f010400b:	7f 4d                	jg     f010405a <stab_binsearch+0xa6>
		int true_m = (l + r) / 2, m = true_m;
f010400d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104010:	01 f0                	add    %esi,%eax
f0104012:	89 c3                	mov    %eax,%ebx
f0104014:	c1 eb 1f             	shr    $0x1f,%ebx
f0104017:	01 c3                	add    %eax,%ebx
f0104019:	d1 fb                	sar    %ebx
f010401b:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f010401e:	01 d8                	add    %ebx,%eax
f0104020:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104023:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104027:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0104029:	eb af                	jmp    f0103fda <stab_binsearch+0x26>
			l = true_m + 1;
f010402b:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f010402e:	eb d8                	jmp    f0104008 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0104030:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104033:	76 12                	jbe    f0104047 <stab_binsearch+0x93>
			*region_right = m - 1;
f0104035:	48                   	dec    %eax
f0104036:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104039:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010403c:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f010403e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104045:	eb c1                	jmp    f0104008 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104047:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010404a:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f010404c:	ff 45 0c             	incl   0xc(%ebp)
f010404f:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0104051:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104058:	eb ae                	jmp    f0104008 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f010405a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010405e:	74 18                	je     f0104078 <stab_binsearch+0xc4>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104060:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104063:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104065:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104068:	8b 0e                	mov    (%esi),%ecx
f010406a:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010406d:	01 c2                	add    %eax,%edx
f010406f:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104072:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0104076:	eb 0e                	jmp    f0104086 <stab_binsearch+0xd2>
		*region_right = *region_left - 1;
f0104078:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010407b:	8b 00                	mov    (%eax),%eax
f010407d:	48                   	dec    %eax
f010407e:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104081:	89 07                	mov    %eax,(%edi)
f0104083:	eb 14                	jmp    f0104099 <stab_binsearch+0xe5>
		     l--)
f0104085:	48                   	dec    %eax
		for (l = *region_right;
f0104086:	39 c1                	cmp    %eax,%ecx
f0104088:	7d 0a                	jge    f0104094 <stab_binsearch+0xe0>
		     l > *region_left && stabs[l].n_type != type;
f010408a:	0f b6 1a             	movzbl (%edx),%ebx
f010408d:	83 ea 0c             	sub    $0xc,%edx
f0104090:	39 fb                	cmp    %edi,%ebx
f0104092:	75 f1                	jne    f0104085 <stab_binsearch+0xd1>
			/* do nothing */;
		*region_left = l;
f0104094:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104097:	89 07                	mov    %eax,(%edi)
	}
}
f0104099:	83 c4 14             	add    $0x14,%esp
f010409c:	5b                   	pop    %ebx
f010409d:	5e                   	pop    %esi
f010409e:	5f                   	pop    %edi
f010409f:	5d                   	pop    %ebp
f01040a0:	c3                   	ret    

f01040a1 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01040a1:	55                   	push   %ebp
f01040a2:	89 e5                	mov    %esp,%ebp
f01040a4:	57                   	push   %edi
f01040a5:	56                   	push   %esi
f01040a6:	53                   	push   %ebx
f01040a7:	83 ec 4c             	sub    $0x4c,%esp
f01040aa:	8b 75 08             	mov    0x8(%ebp),%esi
f01040ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01040b0:	c7 03 68 68 10 f0    	movl   $0xf0106868,(%ebx)
	info->eip_line = 0;
f01040b6:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01040bd:	c7 43 08 68 68 10 f0 	movl   $0xf0106868,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01040c4:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01040cb:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01040ce:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01040d5:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01040db:	77 1e                	ja     f01040fb <debuginfo_eip+0x5a>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f01040dd:	8b 3d 00 00 20 00    	mov    0x200000,%edi
		stab_end = usd->stab_end;
f01040e3:	8b 15 04 00 20 00    	mov    0x200004,%edx
		stabstr = usd->stabstr;
f01040e9:	a1 08 00 20 00       	mov    0x200008,%eax
f01040ee:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f01040f1:	a1 0c 00 20 00       	mov    0x20000c,%eax
f01040f6:	89 45 b8             	mov    %eax,-0x48(%ebp)
f01040f9:	eb 18                	jmp    f0104113 <debuginfo_eip+0x72>
		stabstr_end = __STABSTR_END__;
f01040fb:	c7 45 b8 78 2b 11 f0 	movl   $0xf0112b78,-0x48(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104102:	c7 45 b4 85 ff 10 f0 	movl   $0xf010ff85,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0104109:	ba 84 ff 10 f0       	mov    $0xf010ff84,%edx
		stabs = __STAB_BEGIN__;
f010410e:	bf 80 6a 10 f0       	mov    $0xf0106a80,%edi
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104113:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0104116:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
f0104119:	0f 83 9b 01 00 00    	jae    f01042ba <debuginfo_eip+0x219>
f010411f:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104123:	0f 85 98 01 00 00    	jne    f01042c1 <debuginfo_eip+0x220>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104129:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104130:	29 fa                	sub    %edi,%edx
f0104132:	c1 fa 02             	sar    $0x2,%edx
f0104135:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0104138:	8d 04 82             	lea    (%edx,%eax,4),%eax
f010413b:	8d 04 82             	lea    (%edx,%eax,4),%eax
f010413e:	89 c1                	mov    %eax,%ecx
f0104140:	c1 e1 08             	shl    $0x8,%ecx
f0104143:	01 c8                	add    %ecx,%eax
f0104145:	89 c1                	mov    %eax,%ecx
f0104147:	c1 e1 10             	shl    $0x10,%ecx
f010414a:	01 c8                	add    %ecx,%eax
f010414c:	01 c0                	add    %eax,%eax
f010414e:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
f0104152:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104155:	56                   	push   %esi
f0104156:	6a 64                	push   $0x64
f0104158:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010415b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010415e:	89 f8                	mov    %edi,%eax
f0104160:	e8 4f fe ff ff       	call   f0103fb4 <stab_binsearch>
	if (lfile == 0)
f0104165:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104168:	83 c4 08             	add    $0x8,%esp
f010416b:	85 c0                	test   %eax,%eax
f010416d:	0f 84 55 01 00 00    	je     f01042c8 <debuginfo_eip+0x227>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104173:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104176:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104179:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010417c:	56                   	push   %esi
f010417d:	6a 24                	push   $0x24
f010417f:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104182:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104185:	89 f8                	mov    %edi,%eax
f0104187:	e8 28 fe ff ff       	call   f0103fb4 <stab_binsearch>

	if (lfun <= rfun) {
f010418c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010418f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0104192:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0104195:	83 c4 08             	add    $0x8,%esp
f0104198:	39 c8                	cmp    %ecx,%eax
f010419a:	0f 8f 80 00 00 00    	jg     f0104220 <debuginfo_eip+0x17f>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01041a0:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01041a3:	01 c2                	add    %eax,%edx
f01041a5:	8d 14 97             	lea    (%edi,%edx,4),%edx
f01041a8:	89 55 c0             	mov    %edx,-0x40(%ebp)
f01041ab:	8b 0a                	mov    (%edx),%ecx
f01041ad:	89 4d bc             	mov    %ecx,-0x44(%ebp)
f01041b0:	8b 55 b8             	mov    -0x48(%ebp),%edx
f01041b3:	2b 55 b4             	sub    -0x4c(%ebp),%edx
f01041b6:	39 d1                	cmp    %edx,%ecx
f01041b8:	73 06                	jae    f01041c0 <debuginfo_eip+0x11f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01041ba:	03 4d b4             	add    -0x4c(%ebp),%ecx
f01041bd:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01041c0:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01041c3:	8b 51 08             	mov    0x8(%ecx),%edx
f01041c6:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01041c9:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01041cb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01041ce:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01041d1:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01041d4:	83 ec 08             	sub    $0x8,%esp
f01041d7:	6a 3a                	push   $0x3a
f01041d9:	ff 73 08             	pushl  0x8(%ebx)
f01041dc:	e8 e9 08 00 00       	call   f0104aca <strfind>
f01041e1:	2b 43 08             	sub    0x8(%ebx),%eax
f01041e4:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// N_SLINE represents text segment
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01041e7:	83 c4 08             	add    $0x8,%esp
f01041ea:	56                   	push   %esi
f01041eb:	6a 44                	push   $0x44
f01041ed:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01041f0:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01041f3:	89 f8                	mov    %edi,%eax
f01041f5:	e8 ba fd ff ff       	call   f0103fb4 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f01041fa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01041fd:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0104200:	01 c2                	add    %eax,%edx
f0104202:	c1 e2 02             	shl    $0x2,%edx
f0104205:	0f b7 4c 17 06       	movzwl 0x6(%edi,%edx,1),%ecx
f010420a:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010420d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104210:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104213:	8d 54 17 04          	lea    0x4(%edi,%edx,1),%edx
f0104217:	83 c4 10             	add    $0x10,%esp
f010421a:	c6 45 c0 00          	movb   $0x0,-0x40(%ebp)
f010421e:	eb 19                	jmp    f0104239 <debuginfo_eip+0x198>
		info->eip_fn_addr = addr;
f0104220:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0104223:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104226:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104229:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010422c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010422f:	eb a3                	jmp    f01041d4 <debuginfo_eip+0x133>
f0104231:	48                   	dec    %eax
f0104232:	83 ea 0c             	sub    $0xc,%edx
f0104235:	c6 45 c0 01          	movb   $0x1,-0x40(%ebp)
f0104239:	89 45 bc             	mov    %eax,-0x44(%ebp)
	while (lline >= lfile
f010423c:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f010423f:	7f 40                	jg     f0104281 <debuginfo_eip+0x1e0>
	       && stabs[lline].n_type != N_SOL
f0104241:	8a 0a                	mov    (%edx),%cl
f0104243:	80 f9 84             	cmp    $0x84,%cl
f0104246:	74 19                	je     f0104261 <debuginfo_eip+0x1c0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104248:	80 f9 64             	cmp    $0x64,%cl
f010424b:	75 e4                	jne    f0104231 <debuginfo_eip+0x190>
f010424d:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0104251:	74 de                	je     f0104231 <debuginfo_eip+0x190>
f0104253:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f0104257:	74 0e                	je     f0104267 <debuginfo_eip+0x1c6>
f0104259:	8b 75 bc             	mov    -0x44(%ebp),%esi
f010425c:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010425f:	eb 06                	jmp    f0104267 <debuginfo_eip+0x1c6>
f0104261:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f0104265:	75 35                	jne    f010429c <debuginfo_eip+0x1fb>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104267:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010426a:	01 d0                	add    %edx,%eax
f010426c:	8b 14 87             	mov    (%edi,%eax,4),%edx
f010426f:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0104272:	8b 75 b4             	mov    -0x4c(%ebp),%esi
f0104275:	29 f0                	sub    %esi,%eax
f0104277:	39 c2                	cmp    %eax,%edx
f0104279:	73 06                	jae    f0104281 <debuginfo_eip+0x1e0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010427b:	89 f0                	mov    %esi,%eax
f010427d:	01 d0                	add    %edx,%eax
f010427f:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104281:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104284:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0104287:	39 f2                	cmp    %esi,%edx
f0104289:	7d 44                	jge    f01042cf <debuginfo_eip+0x22e>
		for (lline = lfun + 1;
f010428b:	42                   	inc    %edx
f010428c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010428f:	89 d0                	mov    %edx,%eax
f0104291:	8d 0c 12             	lea    (%edx,%edx,1),%ecx
f0104294:	01 ca                	add    %ecx,%edx
f0104296:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f010429a:	eb 08                	jmp    f01042a4 <debuginfo_eip+0x203>
f010429c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010429f:	eb c6                	jmp    f0104267 <debuginfo_eip+0x1c6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01042a1:	ff 43 14             	incl   0x14(%ebx)
		for (lline = lfun + 1;
f01042a4:	39 c6                	cmp    %eax,%esi
f01042a6:	7e 34                	jle    f01042dc <debuginfo_eip+0x23b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01042a8:	8a 0a                	mov    (%edx),%cl
f01042aa:	40                   	inc    %eax
f01042ab:	83 c2 0c             	add    $0xc,%edx
f01042ae:	80 f9 a0             	cmp    $0xa0,%cl
f01042b1:	74 ee                	je     f01042a1 <debuginfo_eip+0x200>

	return 0;
f01042b3:	b8 00 00 00 00       	mov    $0x0,%eax
f01042b8:	eb 1a                	jmp    f01042d4 <debuginfo_eip+0x233>
		return -1;
f01042ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01042bf:	eb 13                	jmp    f01042d4 <debuginfo_eip+0x233>
f01042c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01042c6:	eb 0c                	jmp    f01042d4 <debuginfo_eip+0x233>
		return -1;
f01042c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01042cd:	eb 05                	jmp    f01042d4 <debuginfo_eip+0x233>
	return 0;
f01042cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01042d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01042d7:	5b                   	pop    %ebx
f01042d8:	5e                   	pop    %esi
f01042d9:	5f                   	pop    %edi
f01042da:	5d                   	pop    %ebp
f01042db:	c3                   	ret    
	return 0;
f01042dc:	b8 00 00 00 00       	mov    $0x0,%eax
f01042e1:	eb f1                	jmp    f01042d4 <debuginfo_eip+0x233>

f01042e3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01042e3:	55                   	push   %ebp
f01042e4:	89 e5                	mov    %esp,%ebp
f01042e6:	57                   	push   %edi
f01042e7:	56                   	push   %esi
f01042e8:	53                   	push   %ebx
f01042e9:	83 ec 1c             	sub    $0x1c,%esp
f01042ec:	89 c7                	mov    %eax,%edi
f01042ee:	89 d6                	mov    %edx,%esi
f01042f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01042f3:	8b 55 0c             	mov    0xc(%ebp),%edx
f01042f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01042f9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01042fc:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01042ff:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104304:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104307:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f010430a:	39 d3                	cmp    %edx,%ebx
f010430c:	72 05                	jb     f0104313 <printnum+0x30>
f010430e:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104311:	77 78                	ja     f010438b <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104313:	83 ec 0c             	sub    $0xc,%esp
f0104316:	ff 75 18             	pushl  0x18(%ebp)
f0104319:	8b 45 14             	mov    0x14(%ebp),%eax
f010431c:	8d 58 ff             	lea    -0x1(%eax),%ebx
f010431f:	53                   	push   %ebx
f0104320:	ff 75 10             	pushl  0x10(%ebp)
f0104323:	83 ec 08             	sub    $0x8,%esp
f0104326:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104329:	ff 75 e0             	pushl  -0x20(%ebp)
f010432c:	ff 75 dc             	pushl  -0x24(%ebp)
f010432f:	ff 75 d8             	pushl  -0x28(%ebp)
f0104332:	e8 59 0a 00 00       	call   f0104d90 <__udivdi3>
f0104337:	83 c4 18             	add    $0x18,%esp
f010433a:	52                   	push   %edx
f010433b:	50                   	push   %eax
f010433c:	89 f2                	mov    %esi,%edx
f010433e:	89 f8                	mov    %edi,%eax
f0104340:	e8 9e ff ff ff       	call   f01042e3 <printnum>
f0104345:	83 c4 20             	add    $0x20,%esp
f0104348:	eb 11                	jmp    f010435b <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010434a:	83 ec 08             	sub    $0x8,%esp
f010434d:	56                   	push   %esi
f010434e:	ff 75 18             	pushl  0x18(%ebp)
f0104351:	ff d7                	call   *%edi
f0104353:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0104356:	4b                   	dec    %ebx
f0104357:	85 db                	test   %ebx,%ebx
f0104359:	7f ef                	jg     f010434a <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010435b:	83 ec 08             	sub    $0x8,%esp
f010435e:	56                   	push   %esi
f010435f:	83 ec 04             	sub    $0x4,%esp
f0104362:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104365:	ff 75 e0             	pushl  -0x20(%ebp)
f0104368:	ff 75 dc             	pushl  -0x24(%ebp)
f010436b:	ff 75 d8             	pushl  -0x28(%ebp)
f010436e:	e8 1d 0b 00 00       	call   f0104e90 <__umoddi3>
f0104373:	83 c4 14             	add    $0x14,%esp
f0104376:	0f be 80 72 68 10 f0 	movsbl -0xfef978e(%eax),%eax
f010437d:	50                   	push   %eax
f010437e:	ff d7                	call   *%edi
}
f0104380:	83 c4 10             	add    $0x10,%esp
f0104383:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104386:	5b                   	pop    %ebx
f0104387:	5e                   	pop    %esi
f0104388:	5f                   	pop    %edi
f0104389:	5d                   	pop    %ebp
f010438a:	c3                   	ret    
f010438b:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010438e:	eb c6                	jmp    f0104356 <printnum+0x73>

f0104390 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104390:	55                   	push   %ebp
f0104391:	89 e5                	mov    %esp,%ebp
f0104393:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104396:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0104399:	8b 10                	mov    (%eax),%edx
f010439b:	3b 50 04             	cmp    0x4(%eax),%edx
f010439e:	73 0a                	jae    f01043aa <sprintputch+0x1a>
		*b->buf++ = ch;
f01043a0:	8d 4a 01             	lea    0x1(%edx),%ecx
f01043a3:	89 08                	mov    %ecx,(%eax)
f01043a5:	8b 45 08             	mov    0x8(%ebp),%eax
f01043a8:	88 02                	mov    %al,(%edx)
}
f01043aa:	5d                   	pop    %ebp
f01043ab:	c3                   	ret    

f01043ac <printfmt>:
{
f01043ac:	55                   	push   %ebp
f01043ad:	89 e5                	mov    %esp,%ebp
f01043af:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01043b2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01043b5:	50                   	push   %eax
f01043b6:	ff 75 10             	pushl  0x10(%ebp)
f01043b9:	ff 75 0c             	pushl  0xc(%ebp)
f01043bc:	ff 75 08             	pushl  0x8(%ebp)
f01043bf:	e8 05 00 00 00       	call   f01043c9 <vprintfmt>
}
f01043c4:	83 c4 10             	add    $0x10,%esp
f01043c7:	c9                   	leave  
f01043c8:	c3                   	ret    

f01043c9 <vprintfmt>:
{
f01043c9:	55                   	push   %ebp
f01043ca:	89 e5                	mov    %esp,%ebp
f01043cc:	57                   	push   %edi
f01043cd:	56                   	push   %esi
f01043ce:	53                   	push   %ebx
f01043cf:	83 ec 2c             	sub    $0x2c,%esp
f01043d2:	8b 75 08             	mov    0x8(%ebp),%esi
f01043d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01043d8:	8b 7d 10             	mov    0x10(%ebp),%edi
f01043db:	e9 ac 03 00 00       	jmp    f010478c <vprintfmt+0x3c3>
		padc = ' ';
f01043e0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f01043e4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f01043eb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f01043f2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f01043f9:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01043fe:	8d 47 01             	lea    0x1(%edi),%eax
f0104401:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104404:	8a 17                	mov    (%edi),%dl
f0104406:	8d 42 dd             	lea    -0x23(%edx),%eax
f0104409:	3c 55                	cmp    $0x55,%al
f010440b:	0f 87 fc 03 00 00    	ja     f010480d <vprintfmt+0x444>
f0104411:	0f b6 c0             	movzbl %al,%eax
f0104414:	ff 24 85 fc 68 10 f0 	jmp    *-0xfef9704(,%eax,4)
f010441b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f010441e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0104422:	eb da                	jmp    f01043fe <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0104424:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0104427:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f010442b:	eb d1                	jmp    f01043fe <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f010442d:	0f b6 d2             	movzbl %dl,%edx
f0104430:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0104433:	b8 00 00 00 00       	mov    $0x0,%eax
f0104438:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f010443b:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010443e:	01 c0                	add    %eax,%eax
f0104440:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
f0104444:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0104447:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010444a:	83 f9 09             	cmp    $0x9,%ecx
f010444d:	77 52                	ja     f01044a1 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
f010444f:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
f0104450:	eb e9                	jmp    f010443b <vprintfmt+0x72>
			precision = va_arg(ap, int);
f0104452:	8b 45 14             	mov    0x14(%ebp),%eax
f0104455:	8b 00                	mov    (%eax),%eax
f0104457:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010445a:	8b 45 14             	mov    0x14(%ebp),%eax
f010445d:	8d 40 04             	lea    0x4(%eax),%eax
f0104460:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104463:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0104466:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010446a:	79 92                	jns    f01043fe <vprintfmt+0x35>
				width = precision, precision = -1;
f010446c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010446f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104472:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104479:	eb 83                	jmp    f01043fe <vprintfmt+0x35>
f010447b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010447f:	78 08                	js     f0104489 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
f0104481:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104484:	e9 75 ff ff ff       	jmp    f01043fe <vprintfmt+0x35>
f0104489:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0104490:	eb ef                	jmp    f0104481 <vprintfmt+0xb8>
f0104492:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0104495:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010449c:	e9 5d ff ff ff       	jmp    f01043fe <vprintfmt+0x35>
f01044a1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01044a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01044a7:	eb bd                	jmp    f0104466 <vprintfmt+0x9d>
			lflag++;
f01044a9:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
f01044aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01044ad:	e9 4c ff ff ff       	jmp    f01043fe <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f01044b2:	8b 45 14             	mov    0x14(%ebp),%eax
f01044b5:	8d 78 04             	lea    0x4(%eax),%edi
f01044b8:	83 ec 08             	sub    $0x8,%esp
f01044bb:	53                   	push   %ebx
f01044bc:	ff 30                	pushl  (%eax)
f01044be:	ff d6                	call   *%esi
			break;
f01044c0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01044c3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01044c6:	e9 be 02 00 00       	jmp    f0104789 <vprintfmt+0x3c0>
			err = va_arg(ap, int);
f01044cb:	8b 45 14             	mov    0x14(%ebp),%eax
f01044ce:	8d 78 04             	lea    0x4(%eax),%edi
f01044d1:	8b 00                	mov    (%eax),%eax
f01044d3:	85 c0                	test   %eax,%eax
f01044d5:	78 2a                	js     f0104501 <vprintfmt+0x138>
f01044d7:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01044d9:	83 f8 06             	cmp    $0x6,%eax
f01044dc:	7f 27                	jg     f0104505 <vprintfmt+0x13c>
f01044de:	8b 04 85 54 6a 10 f0 	mov    -0xfef95ac(,%eax,4),%eax
f01044e5:	85 c0                	test   %eax,%eax
f01044e7:	74 1c                	je     f0104505 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
f01044e9:	50                   	push   %eax
f01044ea:	68 71 60 10 f0       	push   $0xf0106071
f01044ef:	53                   	push   %ebx
f01044f0:	56                   	push   %esi
f01044f1:	e8 b6 fe ff ff       	call   f01043ac <printfmt>
f01044f6:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01044f9:	89 7d 14             	mov    %edi,0x14(%ebp)
f01044fc:	e9 88 02 00 00       	jmp    f0104789 <vprintfmt+0x3c0>
f0104501:	f7 d8                	neg    %eax
f0104503:	eb d2                	jmp    f01044d7 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
f0104505:	52                   	push   %edx
f0104506:	68 8a 68 10 f0       	push   $0xf010688a
f010450b:	53                   	push   %ebx
f010450c:	56                   	push   %esi
f010450d:	e8 9a fe ff ff       	call   f01043ac <printfmt>
f0104512:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104515:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0104518:	e9 6c 02 00 00       	jmp    f0104789 <vprintfmt+0x3c0>
			if ((p = va_arg(ap, char *)) == NULL)
f010451d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104520:	83 c0 04             	add    $0x4,%eax
f0104523:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0104526:	8b 45 14             	mov    0x14(%ebp),%eax
f0104529:	8b 38                	mov    (%eax),%edi
f010452b:	85 ff                	test   %edi,%edi
f010452d:	74 18                	je     f0104547 <vprintfmt+0x17e>
			if (width > 0 && padc != '-')
f010452f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104533:	0f 8e b7 00 00 00    	jle    f01045f0 <vprintfmt+0x227>
f0104539:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010453d:	75 0f                	jne    f010454e <vprintfmt+0x185>
f010453f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104542:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0104545:	eb 6e                	jmp    f01045b5 <vprintfmt+0x1ec>
				p = "(null)";
f0104547:	bf 83 68 10 f0       	mov    $0xf0106883,%edi
f010454c:	eb e1                	jmp    f010452f <vprintfmt+0x166>
				for (width -= strnlen(p, precision); width > 0; width--)
f010454e:	83 ec 08             	sub    $0x8,%esp
f0104551:	ff 75 d0             	pushl  -0x30(%ebp)
f0104554:	57                   	push   %edi
f0104555:	e8 45 04 00 00       	call   f010499f <strnlen>
f010455a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010455d:	29 c1                	sub    %eax,%ecx
f010455f:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0104562:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104565:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104569:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010456c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010456f:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0104571:	eb 0d                	jmp    f0104580 <vprintfmt+0x1b7>
					putch(padc, putdat);
f0104573:	83 ec 08             	sub    $0x8,%esp
f0104576:	53                   	push   %ebx
f0104577:	ff 75 e0             	pushl  -0x20(%ebp)
f010457a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f010457c:	4f                   	dec    %edi
f010457d:	83 c4 10             	add    $0x10,%esp
f0104580:	85 ff                	test   %edi,%edi
f0104582:	7f ef                	jg     f0104573 <vprintfmt+0x1aa>
f0104584:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104587:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010458a:	89 c8                	mov    %ecx,%eax
f010458c:	85 c9                	test   %ecx,%ecx
f010458e:	78 59                	js     f01045e9 <vprintfmt+0x220>
f0104590:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104593:	29 c1                	sub    %eax,%ecx
f0104595:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104598:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010459b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010459e:	eb 15                	jmp    f01045b5 <vprintfmt+0x1ec>
				if (altflag && (ch < ' ' || ch > '~'))
f01045a0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01045a4:	75 29                	jne    f01045cf <vprintfmt+0x206>
					putch(ch, putdat);
f01045a6:	83 ec 08             	sub    $0x8,%esp
f01045a9:	ff 75 0c             	pushl  0xc(%ebp)
f01045ac:	50                   	push   %eax
f01045ad:	ff d6                	call   *%esi
f01045af:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01045b2:	ff 4d e0             	decl   -0x20(%ebp)
f01045b5:	47                   	inc    %edi
f01045b6:	8a 57 ff             	mov    -0x1(%edi),%dl
f01045b9:	0f be c2             	movsbl %dl,%eax
f01045bc:	85 c0                	test   %eax,%eax
f01045be:	74 53                	je     f0104613 <vprintfmt+0x24a>
f01045c0:	85 db                	test   %ebx,%ebx
f01045c2:	78 dc                	js     f01045a0 <vprintfmt+0x1d7>
f01045c4:	4b                   	dec    %ebx
f01045c5:	79 d9                	jns    f01045a0 <vprintfmt+0x1d7>
f01045c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01045ca:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01045cd:	eb 35                	jmp    f0104604 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
f01045cf:	0f be d2             	movsbl %dl,%edx
f01045d2:	83 ea 20             	sub    $0x20,%edx
f01045d5:	83 fa 5e             	cmp    $0x5e,%edx
f01045d8:	76 cc                	jbe    f01045a6 <vprintfmt+0x1dd>
					putch('?', putdat);
f01045da:	83 ec 08             	sub    $0x8,%esp
f01045dd:	ff 75 0c             	pushl  0xc(%ebp)
f01045e0:	6a 3f                	push   $0x3f
f01045e2:	ff d6                	call   *%esi
f01045e4:	83 c4 10             	add    $0x10,%esp
f01045e7:	eb c9                	jmp    f01045b2 <vprintfmt+0x1e9>
f01045e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01045ee:	eb a0                	jmp    f0104590 <vprintfmt+0x1c7>
f01045f0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01045f3:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01045f6:	eb bd                	jmp    f01045b5 <vprintfmt+0x1ec>
				putch(' ', putdat);
f01045f8:	83 ec 08             	sub    $0x8,%esp
f01045fb:	53                   	push   %ebx
f01045fc:	6a 20                	push   $0x20
f01045fe:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0104600:	4f                   	dec    %edi
f0104601:	83 c4 10             	add    $0x10,%esp
f0104604:	85 ff                	test   %edi,%edi
f0104606:	7f f0                	jg     f01045f8 <vprintfmt+0x22f>
			if ((p = va_arg(ap, char *)) == NULL)
f0104608:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010460b:	89 45 14             	mov    %eax,0x14(%ebp)
f010460e:	e9 76 01 00 00       	jmp    f0104789 <vprintfmt+0x3c0>
f0104613:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104616:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104619:	eb e9                	jmp    f0104604 <vprintfmt+0x23b>
	if (lflag >= 2)
f010461b:	83 f9 01             	cmp    $0x1,%ecx
f010461e:	7e 3f                	jle    f010465f <vprintfmt+0x296>
		return va_arg(*ap, long long);
f0104620:	8b 45 14             	mov    0x14(%ebp),%eax
f0104623:	8b 50 04             	mov    0x4(%eax),%edx
f0104626:	8b 00                	mov    (%eax),%eax
f0104628:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010462b:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010462e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104631:	8d 40 08             	lea    0x8(%eax),%eax
f0104634:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0104637:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010463b:	79 5c                	jns    f0104699 <vprintfmt+0x2d0>
				putch('-', putdat);
f010463d:	83 ec 08             	sub    $0x8,%esp
f0104640:	53                   	push   %ebx
f0104641:	6a 2d                	push   $0x2d
f0104643:	ff d6                	call   *%esi
				num = -(long long) num;
f0104645:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104648:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010464b:	f7 da                	neg    %edx
f010464d:	83 d1 00             	adc    $0x0,%ecx
f0104650:	f7 d9                	neg    %ecx
f0104652:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0104655:	b8 0a 00 00 00       	mov    $0xa,%eax
f010465a:	e9 10 01 00 00       	jmp    f010476f <vprintfmt+0x3a6>
	else if (lflag)
f010465f:	85 c9                	test   %ecx,%ecx
f0104661:	75 1b                	jne    f010467e <vprintfmt+0x2b5>
		return va_arg(*ap, int);
f0104663:	8b 45 14             	mov    0x14(%ebp),%eax
f0104666:	8b 00                	mov    (%eax),%eax
f0104668:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010466b:	89 c1                	mov    %eax,%ecx
f010466d:	c1 f9 1f             	sar    $0x1f,%ecx
f0104670:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104673:	8b 45 14             	mov    0x14(%ebp),%eax
f0104676:	8d 40 04             	lea    0x4(%eax),%eax
f0104679:	89 45 14             	mov    %eax,0x14(%ebp)
f010467c:	eb b9                	jmp    f0104637 <vprintfmt+0x26e>
		return va_arg(*ap, long);
f010467e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104681:	8b 00                	mov    (%eax),%eax
f0104683:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104686:	89 c1                	mov    %eax,%ecx
f0104688:	c1 f9 1f             	sar    $0x1f,%ecx
f010468b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010468e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104691:	8d 40 04             	lea    0x4(%eax),%eax
f0104694:	89 45 14             	mov    %eax,0x14(%ebp)
f0104697:	eb 9e                	jmp    f0104637 <vprintfmt+0x26e>
			num = getint(&ap, lflag);
f0104699:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010469c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f010469f:	b8 0a 00 00 00       	mov    $0xa,%eax
f01046a4:	e9 c6 00 00 00       	jmp    f010476f <vprintfmt+0x3a6>
	if (lflag >= 2)
f01046a9:	83 f9 01             	cmp    $0x1,%ecx
f01046ac:	7e 18                	jle    f01046c6 <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
f01046ae:	8b 45 14             	mov    0x14(%ebp),%eax
f01046b1:	8b 10                	mov    (%eax),%edx
f01046b3:	8b 48 04             	mov    0x4(%eax),%ecx
f01046b6:	8d 40 08             	lea    0x8(%eax),%eax
f01046b9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01046bc:	b8 0a 00 00 00       	mov    $0xa,%eax
f01046c1:	e9 a9 00 00 00       	jmp    f010476f <vprintfmt+0x3a6>
	else if (lflag)
f01046c6:	85 c9                	test   %ecx,%ecx
f01046c8:	75 1a                	jne    f01046e4 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned int);
f01046ca:	8b 45 14             	mov    0x14(%ebp),%eax
f01046cd:	8b 10                	mov    (%eax),%edx
f01046cf:	b9 00 00 00 00       	mov    $0x0,%ecx
f01046d4:	8d 40 04             	lea    0x4(%eax),%eax
f01046d7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01046da:	b8 0a 00 00 00       	mov    $0xa,%eax
f01046df:	e9 8b 00 00 00       	jmp    f010476f <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f01046e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01046e7:	8b 10                	mov    (%eax),%edx
f01046e9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01046ee:	8d 40 04             	lea    0x4(%eax),%eax
f01046f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01046f4:	b8 0a 00 00 00       	mov    $0xa,%eax
f01046f9:	eb 74                	jmp    f010476f <vprintfmt+0x3a6>
	if (lflag >= 2)
f01046fb:	83 f9 01             	cmp    $0x1,%ecx
f01046fe:	7e 15                	jle    f0104715 <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
f0104700:	8b 45 14             	mov    0x14(%ebp),%eax
f0104703:	8b 10                	mov    (%eax),%edx
f0104705:	8b 48 04             	mov    0x4(%eax),%ecx
f0104708:	8d 40 08             	lea    0x8(%eax),%eax
f010470b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010470e:	b8 08 00 00 00       	mov    $0x8,%eax
f0104713:	eb 5a                	jmp    f010476f <vprintfmt+0x3a6>
	else if (lflag)
f0104715:	85 c9                	test   %ecx,%ecx
f0104717:	75 17                	jne    f0104730 <vprintfmt+0x367>
		return va_arg(*ap, unsigned int);
f0104719:	8b 45 14             	mov    0x14(%ebp),%eax
f010471c:	8b 10                	mov    (%eax),%edx
f010471e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104723:	8d 40 04             	lea    0x4(%eax),%eax
f0104726:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104729:	b8 08 00 00 00       	mov    $0x8,%eax
f010472e:	eb 3f                	jmp    f010476f <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0104730:	8b 45 14             	mov    0x14(%ebp),%eax
f0104733:	8b 10                	mov    (%eax),%edx
f0104735:	b9 00 00 00 00       	mov    $0x0,%ecx
f010473a:	8d 40 04             	lea    0x4(%eax),%eax
f010473d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104740:	b8 08 00 00 00       	mov    $0x8,%eax
f0104745:	eb 28                	jmp    f010476f <vprintfmt+0x3a6>
			putch('0', putdat);
f0104747:	83 ec 08             	sub    $0x8,%esp
f010474a:	53                   	push   %ebx
f010474b:	6a 30                	push   $0x30
f010474d:	ff d6                	call   *%esi
			putch('x', putdat);
f010474f:	83 c4 08             	add    $0x8,%esp
f0104752:	53                   	push   %ebx
f0104753:	6a 78                	push   $0x78
f0104755:	ff d6                	call   *%esi
			num = (unsigned long long)
f0104757:	8b 45 14             	mov    0x14(%ebp),%eax
f010475a:	8b 10                	mov    (%eax),%edx
f010475c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0104761:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0104764:	8d 40 04             	lea    0x4(%eax),%eax
f0104767:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010476a:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f010476f:	83 ec 0c             	sub    $0xc,%esp
f0104772:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0104776:	57                   	push   %edi
f0104777:	ff 75 e0             	pushl  -0x20(%ebp)
f010477a:	50                   	push   %eax
f010477b:	51                   	push   %ecx
f010477c:	52                   	push   %edx
f010477d:	89 da                	mov    %ebx,%edx
f010477f:	89 f0                	mov    %esi,%eax
f0104781:	e8 5d fb ff ff       	call   f01042e3 <printnum>
			break;
f0104786:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0104789:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010478c:	47                   	inc    %edi
f010478d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104791:	83 f8 25             	cmp    $0x25,%eax
f0104794:	0f 84 46 fc ff ff    	je     f01043e0 <vprintfmt+0x17>
			if (ch == '\0')
f010479a:	85 c0                	test   %eax,%eax
f010479c:	0f 84 89 00 00 00    	je     f010482b <vprintfmt+0x462>
			putch(ch, putdat);
f01047a2:	83 ec 08             	sub    $0x8,%esp
f01047a5:	53                   	push   %ebx
f01047a6:	50                   	push   %eax
f01047a7:	ff d6                	call   *%esi
f01047a9:	83 c4 10             	add    $0x10,%esp
f01047ac:	eb de                	jmp    f010478c <vprintfmt+0x3c3>
	if (lflag >= 2)
f01047ae:	83 f9 01             	cmp    $0x1,%ecx
f01047b1:	7e 15                	jle    f01047c8 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
f01047b3:	8b 45 14             	mov    0x14(%ebp),%eax
f01047b6:	8b 10                	mov    (%eax),%edx
f01047b8:	8b 48 04             	mov    0x4(%eax),%ecx
f01047bb:	8d 40 08             	lea    0x8(%eax),%eax
f01047be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01047c1:	b8 10 00 00 00       	mov    $0x10,%eax
f01047c6:	eb a7                	jmp    f010476f <vprintfmt+0x3a6>
	else if (lflag)
f01047c8:	85 c9                	test   %ecx,%ecx
f01047ca:	75 17                	jne    f01047e3 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned int);
f01047cc:	8b 45 14             	mov    0x14(%ebp),%eax
f01047cf:	8b 10                	mov    (%eax),%edx
f01047d1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01047d6:	8d 40 04             	lea    0x4(%eax),%eax
f01047d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01047dc:	b8 10 00 00 00       	mov    $0x10,%eax
f01047e1:	eb 8c                	jmp    f010476f <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f01047e3:	8b 45 14             	mov    0x14(%ebp),%eax
f01047e6:	8b 10                	mov    (%eax),%edx
f01047e8:	b9 00 00 00 00       	mov    $0x0,%ecx
f01047ed:	8d 40 04             	lea    0x4(%eax),%eax
f01047f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01047f3:	b8 10 00 00 00       	mov    $0x10,%eax
f01047f8:	e9 72 ff ff ff       	jmp    f010476f <vprintfmt+0x3a6>
			putch(ch, putdat);
f01047fd:	83 ec 08             	sub    $0x8,%esp
f0104800:	53                   	push   %ebx
f0104801:	6a 25                	push   $0x25
f0104803:	ff d6                	call   *%esi
			break;
f0104805:	83 c4 10             	add    $0x10,%esp
f0104808:	e9 7c ff ff ff       	jmp    f0104789 <vprintfmt+0x3c0>
			putch('%', putdat);
f010480d:	83 ec 08             	sub    $0x8,%esp
f0104810:	53                   	push   %ebx
f0104811:	6a 25                	push   $0x25
f0104813:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104815:	83 c4 10             	add    $0x10,%esp
f0104818:	89 f8                	mov    %edi,%eax
f010481a:	eb 01                	jmp    f010481d <vprintfmt+0x454>
f010481c:	48                   	dec    %eax
f010481d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0104821:	75 f9                	jne    f010481c <vprintfmt+0x453>
f0104823:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104826:	e9 5e ff ff ff       	jmp    f0104789 <vprintfmt+0x3c0>
}
f010482b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010482e:	5b                   	pop    %ebx
f010482f:	5e                   	pop    %esi
f0104830:	5f                   	pop    %edi
f0104831:	5d                   	pop    %ebp
f0104832:	c3                   	ret    

f0104833 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104833:	55                   	push   %ebp
f0104834:	89 e5                	mov    %esp,%ebp
f0104836:	83 ec 18             	sub    $0x18,%esp
f0104839:	8b 45 08             	mov    0x8(%ebp),%eax
f010483c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010483f:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104842:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104846:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104849:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104850:	85 c0                	test   %eax,%eax
f0104852:	74 26                	je     f010487a <vsnprintf+0x47>
f0104854:	85 d2                	test   %edx,%edx
f0104856:	7e 29                	jle    f0104881 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104858:	ff 75 14             	pushl  0x14(%ebp)
f010485b:	ff 75 10             	pushl  0x10(%ebp)
f010485e:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104861:	50                   	push   %eax
f0104862:	68 90 43 10 f0       	push   $0xf0104390
f0104867:	e8 5d fb ff ff       	call   f01043c9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010486c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010486f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104872:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104875:	83 c4 10             	add    $0x10,%esp
}
f0104878:	c9                   	leave  
f0104879:	c3                   	ret    
		return -E_INVAL;
f010487a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010487f:	eb f7                	jmp    f0104878 <vsnprintf+0x45>
f0104881:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104886:	eb f0                	jmp    f0104878 <vsnprintf+0x45>

f0104888 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104888:	55                   	push   %ebp
f0104889:	89 e5                	mov    %esp,%ebp
f010488b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010488e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104891:	50                   	push   %eax
f0104892:	ff 75 10             	pushl  0x10(%ebp)
f0104895:	ff 75 0c             	pushl  0xc(%ebp)
f0104898:	ff 75 08             	pushl  0x8(%ebp)
f010489b:	e8 93 ff ff ff       	call   f0104833 <vsnprintf>
	va_end(ap);

	return rc;
}
f01048a0:	c9                   	leave  
f01048a1:	c3                   	ret    

f01048a2 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01048a2:	55                   	push   %ebp
f01048a3:	89 e5                	mov    %esp,%ebp
f01048a5:	57                   	push   %edi
f01048a6:	56                   	push   %esi
f01048a7:	53                   	push   %ebx
f01048a8:	83 ec 0c             	sub    $0xc,%esp
f01048ab:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01048ae:	85 c0                	test   %eax,%eax
f01048b0:	74 11                	je     f01048c3 <readline+0x21>
		cprintf("%s", prompt);
f01048b2:	83 ec 08             	sub    $0x8,%esp
f01048b5:	50                   	push   %eax
f01048b6:	68 71 60 10 f0       	push   $0xf0106071
f01048bb:	e8 27 ee ff ff       	call   f01036e7 <cprintf>
f01048c0:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01048c3:	83 ec 0c             	sub    $0xc,%esp
f01048c6:	6a 00                	push   $0x0
f01048c8:	e8 ef bd ff ff       	call   f01006bc <iscons>
f01048cd:	89 c7                	mov    %eax,%edi
f01048cf:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01048d2:	be 00 00 00 00       	mov    $0x0,%esi
f01048d7:	eb 6f                	jmp    f0104948 <readline+0xa6>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01048d9:	83 ec 08             	sub    $0x8,%esp
f01048dc:	50                   	push   %eax
f01048dd:	68 70 6a 10 f0       	push   $0xf0106a70
f01048e2:	e8 00 ee ff ff       	call   f01036e7 <cprintf>
			return NULL;
f01048e7:	83 c4 10             	add    $0x10,%esp
f01048ea:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01048ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01048f2:	5b                   	pop    %ebx
f01048f3:	5e                   	pop    %esi
f01048f4:	5f                   	pop    %edi
f01048f5:	5d                   	pop    %ebp
f01048f6:	c3                   	ret    
				cputchar('\b');
f01048f7:	83 ec 0c             	sub    $0xc,%esp
f01048fa:	6a 08                	push   $0x8
f01048fc:	e8 9a bd ff ff       	call   f010069b <cputchar>
f0104901:	83 c4 10             	add    $0x10,%esp
f0104904:	eb 41                	jmp    f0104947 <readline+0xa5>
				cputchar(c);
f0104906:	83 ec 0c             	sub    $0xc,%esp
f0104909:	53                   	push   %ebx
f010490a:	e8 8c bd ff ff       	call   f010069b <cputchar>
f010490f:	83 c4 10             	add    $0x10,%esp
f0104912:	eb 5a                	jmp    f010496e <readline+0xcc>
		} else if (c == '\n' || c == '\r') {
f0104914:	83 fb 0a             	cmp    $0xa,%ebx
f0104917:	74 05                	je     f010491e <readline+0x7c>
f0104919:	83 fb 0d             	cmp    $0xd,%ebx
f010491c:	75 2a                	jne    f0104948 <readline+0xa6>
			if (echoing)
f010491e:	85 ff                	test   %edi,%edi
f0104920:	75 0e                	jne    f0104930 <readline+0x8e>
			buf[i] = 0;
f0104922:	c6 86 e0 69 1b f0 00 	movb   $0x0,-0xfe49620(%esi)
			return buf;
f0104929:	b8 e0 69 1b f0       	mov    $0xf01b69e0,%eax
f010492e:	eb bf                	jmp    f01048ef <readline+0x4d>
				cputchar('\n');
f0104930:	83 ec 0c             	sub    $0xc,%esp
f0104933:	6a 0a                	push   $0xa
f0104935:	e8 61 bd ff ff       	call   f010069b <cputchar>
f010493a:	83 c4 10             	add    $0x10,%esp
f010493d:	eb e3                	jmp    f0104922 <readline+0x80>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010493f:	85 f6                	test   %esi,%esi
f0104941:	7e 3c                	jle    f010497f <readline+0xdd>
			if (echoing)
f0104943:	85 ff                	test   %edi,%edi
f0104945:	75 b0                	jne    f01048f7 <readline+0x55>
			i--;
f0104947:	4e                   	dec    %esi
		c = getchar();
f0104948:	e8 5e bd ff ff       	call   f01006ab <getchar>
f010494d:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010494f:	85 c0                	test   %eax,%eax
f0104951:	78 86                	js     f01048d9 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104953:	83 f8 08             	cmp    $0x8,%eax
f0104956:	74 21                	je     f0104979 <readline+0xd7>
f0104958:	83 f8 7f             	cmp    $0x7f,%eax
f010495b:	74 e2                	je     f010493f <readline+0x9d>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010495d:	83 f8 1f             	cmp    $0x1f,%eax
f0104960:	7e b2                	jle    f0104914 <readline+0x72>
f0104962:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104968:	7f aa                	jg     f0104914 <readline+0x72>
			if (echoing)
f010496a:	85 ff                	test   %edi,%edi
f010496c:	75 98                	jne    f0104906 <readline+0x64>
			buf[i++] = c;
f010496e:	88 9e e0 69 1b f0    	mov    %bl,-0xfe49620(%esi)
f0104974:	8d 76 01             	lea    0x1(%esi),%esi
f0104977:	eb cf                	jmp    f0104948 <readline+0xa6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104979:	85 f6                	test   %esi,%esi
f010497b:	7e cb                	jle    f0104948 <readline+0xa6>
f010497d:	eb c4                	jmp    f0104943 <readline+0xa1>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010497f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104985:	7e e3                	jle    f010496a <readline+0xc8>
f0104987:	eb bf                	jmp    f0104948 <readline+0xa6>

f0104989 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104989:	55                   	push   %ebp
f010498a:	89 e5                	mov    %esp,%ebp
f010498c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010498f:	b8 00 00 00 00       	mov    $0x0,%eax
f0104994:	eb 01                	jmp    f0104997 <strlen+0xe>
		n++;
f0104996:	40                   	inc    %eax
	for (n = 0; *s != '\0'; s++)
f0104997:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010499b:	75 f9                	jne    f0104996 <strlen+0xd>
	return n;
}
f010499d:	5d                   	pop    %ebp
f010499e:	c3                   	ret    

f010499f <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010499f:	55                   	push   %ebp
f01049a0:	89 e5                	mov    %esp,%ebp
f01049a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01049a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01049a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01049ad:	eb 01                	jmp    f01049b0 <strnlen+0x11>
		n++;
f01049af:	40                   	inc    %eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01049b0:	39 d0                	cmp    %edx,%eax
f01049b2:	74 06                	je     f01049ba <strnlen+0x1b>
f01049b4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01049b8:	75 f5                	jne    f01049af <strnlen+0x10>
	return n;
}
f01049ba:	5d                   	pop    %ebp
f01049bb:	c3                   	ret    

f01049bc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01049bc:	55                   	push   %ebp
f01049bd:	89 e5                	mov    %esp,%ebp
f01049bf:	53                   	push   %ebx
f01049c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01049c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01049c6:	89 c2                	mov    %eax,%edx
f01049c8:	41                   	inc    %ecx
f01049c9:	42                   	inc    %edx
f01049ca:	8a 59 ff             	mov    -0x1(%ecx),%bl
f01049cd:	88 5a ff             	mov    %bl,-0x1(%edx)
f01049d0:	84 db                	test   %bl,%bl
f01049d2:	75 f4                	jne    f01049c8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01049d4:	5b                   	pop    %ebx
f01049d5:	5d                   	pop    %ebp
f01049d6:	c3                   	ret    

f01049d7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01049d7:	55                   	push   %ebp
f01049d8:	89 e5                	mov    %esp,%ebp
f01049da:	53                   	push   %ebx
f01049db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01049de:	53                   	push   %ebx
f01049df:	e8 a5 ff ff ff       	call   f0104989 <strlen>
f01049e4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01049e7:	ff 75 0c             	pushl  0xc(%ebp)
f01049ea:	01 d8                	add    %ebx,%eax
f01049ec:	50                   	push   %eax
f01049ed:	e8 ca ff ff ff       	call   f01049bc <strcpy>
	return dst;
}
f01049f2:	89 d8                	mov    %ebx,%eax
f01049f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01049f7:	c9                   	leave  
f01049f8:	c3                   	ret    

f01049f9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01049f9:	55                   	push   %ebp
f01049fa:	89 e5                	mov    %esp,%ebp
f01049fc:	56                   	push   %esi
f01049fd:	53                   	push   %ebx
f01049fe:	8b 75 08             	mov    0x8(%ebp),%esi
f0104a01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104a04:	89 f3                	mov    %esi,%ebx
f0104a06:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104a09:	89 f2                	mov    %esi,%edx
f0104a0b:	39 da                	cmp    %ebx,%edx
f0104a0d:	74 0e                	je     f0104a1d <strncpy+0x24>
		*dst++ = *src;
f0104a0f:	42                   	inc    %edx
f0104a10:	8a 01                	mov    (%ecx),%al
f0104a12:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f0104a15:	80 39 00             	cmpb   $0x0,(%ecx)
f0104a18:	74 f1                	je     f0104a0b <strncpy+0x12>
			src++;
f0104a1a:	41                   	inc    %ecx
f0104a1b:	eb ee                	jmp    f0104a0b <strncpy+0x12>
	}
	return ret;
}
f0104a1d:	89 f0                	mov    %esi,%eax
f0104a1f:	5b                   	pop    %ebx
f0104a20:	5e                   	pop    %esi
f0104a21:	5d                   	pop    %ebp
f0104a22:	c3                   	ret    

f0104a23 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104a23:	55                   	push   %ebp
f0104a24:	89 e5                	mov    %esp,%ebp
f0104a26:	56                   	push   %esi
f0104a27:	53                   	push   %ebx
f0104a28:	8b 75 08             	mov    0x8(%ebp),%esi
f0104a2b:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104a2e:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104a31:	85 c0                	test   %eax,%eax
f0104a33:	74 20                	je     f0104a55 <strlcpy+0x32>
f0104a35:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
f0104a39:	89 f0                	mov    %esi,%eax
f0104a3b:	eb 05                	jmp    f0104a42 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104a3d:	42                   	inc    %edx
f0104a3e:	40                   	inc    %eax
f0104a3f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0104a42:	39 d8                	cmp    %ebx,%eax
f0104a44:	74 06                	je     f0104a4c <strlcpy+0x29>
f0104a46:	8a 0a                	mov    (%edx),%cl
f0104a48:	84 c9                	test   %cl,%cl
f0104a4a:	75 f1                	jne    f0104a3d <strlcpy+0x1a>
		*dst = '\0';
f0104a4c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104a4f:	29 f0                	sub    %esi,%eax
}
f0104a51:	5b                   	pop    %ebx
f0104a52:	5e                   	pop    %esi
f0104a53:	5d                   	pop    %ebp
f0104a54:	c3                   	ret    
f0104a55:	89 f0                	mov    %esi,%eax
f0104a57:	eb f6                	jmp    f0104a4f <strlcpy+0x2c>

f0104a59 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104a59:	55                   	push   %ebp
f0104a5a:	89 e5                	mov    %esp,%ebp
f0104a5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104a5f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104a62:	eb 02                	jmp    f0104a66 <strcmp+0xd>
		p++, q++;
f0104a64:	41                   	inc    %ecx
f0104a65:	42                   	inc    %edx
	while (*p && *p == *q)
f0104a66:	8a 01                	mov    (%ecx),%al
f0104a68:	84 c0                	test   %al,%al
f0104a6a:	74 04                	je     f0104a70 <strcmp+0x17>
f0104a6c:	3a 02                	cmp    (%edx),%al
f0104a6e:	74 f4                	je     f0104a64 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104a70:	0f b6 c0             	movzbl %al,%eax
f0104a73:	0f b6 12             	movzbl (%edx),%edx
f0104a76:	29 d0                	sub    %edx,%eax
}
f0104a78:	5d                   	pop    %ebp
f0104a79:	c3                   	ret    

f0104a7a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104a7a:	55                   	push   %ebp
f0104a7b:	89 e5                	mov    %esp,%ebp
f0104a7d:	53                   	push   %ebx
f0104a7e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a81:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104a84:	89 c3                	mov    %eax,%ebx
f0104a86:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104a89:	eb 02                	jmp    f0104a8d <strncmp+0x13>
		n--, p++, q++;
f0104a8b:	40                   	inc    %eax
f0104a8c:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
f0104a8d:	39 d8                	cmp    %ebx,%eax
f0104a8f:	74 15                	je     f0104aa6 <strncmp+0x2c>
f0104a91:	8a 08                	mov    (%eax),%cl
f0104a93:	84 c9                	test   %cl,%cl
f0104a95:	74 04                	je     f0104a9b <strncmp+0x21>
f0104a97:	3a 0a                	cmp    (%edx),%cl
f0104a99:	74 f0                	je     f0104a8b <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104a9b:	0f b6 00             	movzbl (%eax),%eax
f0104a9e:	0f b6 12             	movzbl (%edx),%edx
f0104aa1:	29 d0                	sub    %edx,%eax
}
f0104aa3:	5b                   	pop    %ebx
f0104aa4:	5d                   	pop    %ebp
f0104aa5:	c3                   	ret    
		return 0;
f0104aa6:	b8 00 00 00 00       	mov    $0x0,%eax
f0104aab:	eb f6                	jmp    f0104aa3 <strncmp+0x29>

f0104aad <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104aad:	55                   	push   %ebp
f0104aae:	89 e5                	mov    %esp,%ebp
f0104ab0:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ab3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0104ab6:	8a 10                	mov    (%eax),%dl
f0104ab8:	84 d2                	test   %dl,%dl
f0104aba:	74 07                	je     f0104ac3 <strchr+0x16>
		if (*s == c)
f0104abc:	38 ca                	cmp    %cl,%dl
f0104abe:	74 08                	je     f0104ac8 <strchr+0x1b>
	for (; *s; s++)
f0104ac0:	40                   	inc    %eax
f0104ac1:	eb f3                	jmp    f0104ab6 <strchr+0x9>
			return (char *) s;
	return 0;
f0104ac3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104ac8:	5d                   	pop    %ebp
f0104ac9:	c3                   	ret    

f0104aca <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104aca:	55                   	push   %ebp
f0104acb:	89 e5                	mov    %esp,%ebp
f0104acd:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ad0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0104ad3:	8a 10                	mov    (%eax),%dl
f0104ad5:	84 d2                	test   %dl,%dl
f0104ad7:	74 07                	je     f0104ae0 <strfind+0x16>
		if (*s == c)
f0104ad9:	38 ca                	cmp    %cl,%dl
f0104adb:	74 03                	je     f0104ae0 <strfind+0x16>
	for (; *s; s++)
f0104add:	40                   	inc    %eax
f0104ade:	eb f3                	jmp    f0104ad3 <strfind+0x9>
			break;
	return (char *) s;
}
f0104ae0:	5d                   	pop    %ebp
f0104ae1:	c3                   	ret    

f0104ae2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104ae2:	55                   	push   %ebp
f0104ae3:	89 e5                	mov    %esp,%ebp
f0104ae5:	57                   	push   %edi
f0104ae6:	56                   	push   %esi
f0104ae7:	53                   	push   %ebx
f0104ae8:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104aeb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104aee:	85 c9                	test   %ecx,%ecx
f0104af0:	74 13                	je     f0104b05 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104af2:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104af8:	75 05                	jne    f0104aff <memset+0x1d>
f0104afa:	f6 c1 03             	test   $0x3,%cl
f0104afd:	74 0d                	je     f0104b0c <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104aff:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104b02:	fc                   	cld    
f0104b03:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104b05:	89 f8                	mov    %edi,%eax
f0104b07:	5b                   	pop    %ebx
f0104b08:	5e                   	pop    %esi
f0104b09:	5f                   	pop    %edi
f0104b0a:	5d                   	pop    %ebp
f0104b0b:	c3                   	ret    
		c &= 0xFF;
f0104b0c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104b10:	89 d3                	mov    %edx,%ebx
f0104b12:	c1 e3 08             	shl    $0x8,%ebx
f0104b15:	89 d0                	mov    %edx,%eax
f0104b17:	c1 e0 18             	shl    $0x18,%eax
f0104b1a:	89 d6                	mov    %edx,%esi
f0104b1c:	c1 e6 10             	shl    $0x10,%esi
f0104b1f:	09 f0                	or     %esi,%eax
f0104b21:	09 c2                	or     %eax,%edx
f0104b23:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0104b25:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0104b28:	89 d0                	mov    %edx,%eax
f0104b2a:	fc                   	cld    
f0104b2b:	f3 ab                	rep stos %eax,%es:(%edi)
f0104b2d:	eb d6                	jmp    f0104b05 <memset+0x23>

f0104b2f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104b2f:	55                   	push   %ebp
f0104b30:	89 e5                	mov    %esp,%ebp
f0104b32:	57                   	push   %edi
f0104b33:	56                   	push   %esi
f0104b34:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b37:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104b3a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104b3d:	39 c6                	cmp    %eax,%esi
f0104b3f:	73 33                	jae    f0104b74 <memmove+0x45>
f0104b41:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104b44:	39 c2                	cmp    %eax,%edx
f0104b46:	76 2c                	jbe    f0104b74 <memmove+0x45>
		s += n;
		d += n;
f0104b48:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104b4b:	89 d6                	mov    %edx,%esi
f0104b4d:	09 fe                	or     %edi,%esi
f0104b4f:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104b55:	74 0a                	je     f0104b61 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104b57:	4f                   	dec    %edi
f0104b58:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0104b5b:	fd                   	std    
f0104b5c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104b5e:	fc                   	cld    
f0104b5f:	eb 21                	jmp    f0104b82 <memmove+0x53>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104b61:	f6 c1 03             	test   $0x3,%cl
f0104b64:	75 f1                	jne    f0104b57 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104b66:	83 ef 04             	sub    $0x4,%edi
f0104b69:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104b6c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0104b6f:	fd                   	std    
f0104b70:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104b72:	eb ea                	jmp    f0104b5e <memmove+0x2f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104b74:	89 f2                	mov    %esi,%edx
f0104b76:	09 c2                	or     %eax,%edx
f0104b78:	f6 c2 03             	test   $0x3,%dl
f0104b7b:	74 09                	je     f0104b86 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104b7d:	89 c7                	mov    %eax,%edi
f0104b7f:	fc                   	cld    
f0104b80:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104b82:	5e                   	pop    %esi
f0104b83:	5f                   	pop    %edi
f0104b84:	5d                   	pop    %ebp
f0104b85:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104b86:	f6 c1 03             	test   $0x3,%cl
f0104b89:	75 f2                	jne    f0104b7d <memmove+0x4e>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104b8b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0104b8e:	89 c7                	mov    %eax,%edi
f0104b90:	fc                   	cld    
f0104b91:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104b93:	eb ed                	jmp    f0104b82 <memmove+0x53>

f0104b95 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104b95:	55                   	push   %ebp
f0104b96:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0104b98:	ff 75 10             	pushl  0x10(%ebp)
f0104b9b:	ff 75 0c             	pushl  0xc(%ebp)
f0104b9e:	ff 75 08             	pushl  0x8(%ebp)
f0104ba1:	e8 89 ff ff ff       	call   f0104b2f <memmove>
}
f0104ba6:	c9                   	leave  
f0104ba7:	c3                   	ret    

f0104ba8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104ba8:	55                   	push   %ebp
f0104ba9:	89 e5                	mov    %esp,%ebp
f0104bab:	56                   	push   %esi
f0104bac:	53                   	push   %ebx
f0104bad:	8b 45 08             	mov    0x8(%ebp),%eax
f0104bb0:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104bb3:	89 c6                	mov    %eax,%esi
f0104bb5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104bb8:	39 f0                	cmp    %esi,%eax
f0104bba:	74 16                	je     f0104bd2 <memcmp+0x2a>
		if (*s1 != *s2)
f0104bbc:	8a 08                	mov    (%eax),%cl
f0104bbe:	8a 1a                	mov    (%edx),%bl
f0104bc0:	38 d9                	cmp    %bl,%cl
f0104bc2:	75 04                	jne    f0104bc8 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0104bc4:	40                   	inc    %eax
f0104bc5:	42                   	inc    %edx
f0104bc6:	eb f0                	jmp    f0104bb8 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0104bc8:	0f b6 c1             	movzbl %cl,%eax
f0104bcb:	0f b6 db             	movzbl %bl,%ebx
f0104bce:	29 d8                	sub    %ebx,%eax
f0104bd0:	eb 05                	jmp    f0104bd7 <memcmp+0x2f>
	}

	return 0;
f0104bd2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104bd7:	5b                   	pop    %ebx
f0104bd8:	5e                   	pop    %esi
f0104bd9:	5d                   	pop    %ebp
f0104bda:	c3                   	ret    

f0104bdb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104bdb:	55                   	push   %ebp
f0104bdc:	89 e5                	mov    %esp,%ebp
f0104bde:	8b 45 08             	mov    0x8(%ebp),%eax
f0104be1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0104be4:	89 c2                	mov    %eax,%edx
f0104be6:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104be9:	39 d0                	cmp    %edx,%eax
f0104beb:	73 07                	jae    f0104bf4 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104bed:	38 08                	cmp    %cl,(%eax)
f0104bef:	74 03                	je     f0104bf4 <memfind+0x19>
	for (; s < ends; s++)
f0104bf1:	40                   	inc    %eax
f0104bf2:	eb f5                	jmp    f0104be9 <memfind+0xe>
			break;
	return (void *) s;
}
f0104bf4:	5d                   	pop    %ebp
f0104bf5:	c3                   	ret    

f0104bf6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104bf6:	55                   	push   %ebp
f0104bf7:	89 e5                	mov    %esp,%ebp
f0104bf9:	57                   	push   %edi
f0104bfa:	56                   	push   %esi
f0104bfb:	53                   	push   %ebx
f0104bfc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104bff:	eb 01                	jmp    f0104c02 <strtol+0xc>
		s++;
f0104c01:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f0104c02:	8a 01                	mov    (%ecx),%al
f0104c04:	3c 20                	cmp    $0x20,%al
f0104c06:	74 f9                	je     f0104c01 <strtol+0xb>
f0104c08:	3c 09                	cmp    $0x9,%al
f0104c0a:	74 f5                	je     f0104c01 <strtol+0xb>

	// plus/minus sign
	if (*s == '+')
f0104c0c:	3c 2b                	cmp    $0x2b,%al
f0104c0e:	74 2b                	je     f0104c3b <strtol+0x45>
		s++;
	else if (*s == '-')
f0104c10:	3c 2d                	cmp    $0x2d,%al
f0104c12:	74 2f                	je     f0104c43 <strtol+0x4d>
	int neg = 0;
f0104c14:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104c19:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f0104c20:	75 12                	jne    f0104c34 <strtol+0x3e>
f0104c22:	80 39 30             	cmpb   $0x30,(%ecx)
f0104c25:	74 24                	je     f0104c4b <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104c27:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0104c2b:	75 07                	jne    f0104c34 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104c2d:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f0104c34:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c39:	eb 4e                	jmp    f0104c89 <strtol+0x93>
		s++;
f0104c3b:	41                   	inc    %ecx
	int neg = 0;
f0104c3c:	bf 00 00 00 00       	mov    $0x0,%edi
f0104c41:	eb d6                	jmp    f0104c19 <strtol+0x23>
		s++, neg = 1;
f0104c43:	41                   	inc    %ecx
f0104c44:	bf 01 00 00 00       	mov    $0x1,%edi
f0104c49:	eb ce                	jmp    f0104c19 <strtol+0x23>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104c4b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0104c4f:	74 10                	je     f0104c61 <strtol+0x6b>
	else if (base == 0 && s[0] == '0')
f0104c51:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0104c55:	75 dd                	jne    f0104c34 <strtol+0x3e>
		s++, base = 8;
f0104c57:	41                   	inc    %ecx
f0104c58:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f0104c5f:	eb d3                	jmp    f0104c34 <strtol+0x3e>
		s += 2, base = 16;
f0104c61:	83 c1 02             	add    $0x2,%ecx
f0104c64:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f0104c6b:	eb c7                	jmp    f0104c34 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0104c6d:	8d 72 9f             	lea    -0x61(%edx),%esi
f0104c70:	89 f3                	mov    %esi,%ebx
f0104c72:	80 fb 19             	cmp    $0x19,%bl
f0104c75:	77 24                	ja     f0104c9b <strtol+0xa5>
			dig = *s - 'a' + 10;
f0104c77:	0f be d2             	movsbl %dl,%edx
f0104c7a:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0104c7d:	3b 55 10             	cmp    0x10(%ebp),%edx
f0104c80:	7d 2b                	jge    f0104cad <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
f0104c82:	41                   	inc    %ecx
f0104c83:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104c87:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0104c89:	8a 11                	mov    (%ecx),%dl
f0104c8b:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0104c8e:	80 fb 09             	cmp    $0x9,%bl
f0104c91:	77 da                	ja     f0104c6d <strtol+0x77>
			dig = *s - '0';
f0104c93:	0f be d2             	movsbl %dl,%edx
f0104c96:	83 ea 30             	sub    $0x30,%edx
f0104c99:	eb e2                	jmp    f0104c7d <strtol+0x87>
		else if (*s >= 'A' && *s <= 'Z')
f0104c9b:	8d 72 bf             	lea    -0x41(%edx),%esi
f0104c9e:	89 f3                	mov    %esi,%ebx
f0104ca0:	80 fb 19             	cmp    $0x19,%bl
f0104ca3:	77 08                	ja     f0104cad <strtol+0xb7>
			dig = *s - 'A' + 10;
f0104ca5:	0f be d2             	movsbl %dl,%edx
f0104ca8:	83 ea 37             	sub    $0x37,%edx
f0104cab:	eb d0                	jmp    f0104c7d <strtol+0x87>
		// we don't properly detect overflow!
	}

	if (endptr)
f0104cad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104cb1:	74 05                	je     f0104cb8 <strtol+0xc2>
		*endptr = (char *) s;
f0104cb3:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104cb6:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0104cb8:	85 ff                	test   %edi,%edi
f0104cba:	74 02                	je     f0104cbe <strtol+0xc8>
f0104cbc:	f7 d8                	neg    %eax
}
f0104cbe:	5b                   	pop    %ebx
f0104cbf:	5e                   	pop    %esi
f0104cc0:	5f                   	pop    %edi
f0104cc1:	5d                   	pop    %ebp
f0104cc2:	c3                   	ret    

f0104cc3 <strtoul>:

unsigned long
strtoul(const char *s, char **endptr, int base)
{
f0104cc3:	55                   	push   %ebp
f0104cc4:	89 e5                	mov    %esp,%ebp
f0104cc6:	57                   	push   %edi
f0104cc7:	56                   	push   %esi
f0104cc8:	53                   	push   %ebx
f0104cc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	unsigned long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104ccc:	eb 01                	jmp    f0104ccf <strtoul+0xc>
		s++;
f0104cce:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f0104ccf:	8a 01                	mov    (%ecx),%al
f0104cd1:	3c 20                	cmp    $0x20,%al
f0104cd3:	74 f9                	je     f0104cce <strtoul+0xb>
f0104cd5:	3c 09                	cmp    $0x9,%al
f0104cd7:	74 f5                	je     f0104cce <strtoul+0xb>

	// plus/minus sign
	if (*s == '+')
f0104cd9:	3c 2b                	cmp    $0x2b,%al
f0104cdb:	74 2b                	je     f0104d08 <strtoul+0x45>
		s++;
	else if (*s == '-')
f0104cdd:	3c 2d                	cmp    $0x2d,%al
f0104cdf:	74 2f                	je     f0104d10 <strtoul+0x4d>
	int neg = 0;
f0104ce1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104ce6:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f0104ced:	75 12                	jne    f0104d01 <strtoul+0x3e>
f0104cef:	80 39 30             	cmpb   $0x30,(%ecx)
f0104cf2:	74 24                	je     f0104d18 <strtoul+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104cf4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0104cf8:	75 07                	jne    f0104d01 <strtoul+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104cfa:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f0104d01:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d06:	eb 4e                	jmp    f0104d56 <strtoul+0x93>
		s++;
f0104d08:	41                   	inc    %ecx
	int neg = 0;
f0104d09:	bf 00 00 00 00       	mov    $0x0,%edi
f0104d0e:	eb d6                	jmp    f0104ce6 <strtoul+0x23>
		s++, neg = 1;
f0104d10:	41                   	inc    %ecx
f0104d11:	bf 01 00 00 00       	mov    $0x1,%edi
f0104d16:	eb ce                	jmp    f0104ce6 <strtoul+0x23>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104d18:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0104d1c:	74 10                	je     f0104d2e <strtoul+0x6b>
	else if (base == 0 && s[0] == '0')
f0104d1e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0104d22:	75 dd                	jne    f0104d01 <strtoul+0x3e>
		s++, base = 8;
f0104d24:	41                   	inc    %ecx
f0104d25:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f0104d2c:	eb d3                	jmp    f0104d01 <strtoul+0x3e>
		s += 2, base = 16;
f0104d2e:	83 c1 02             	add    $0x2,%ecx
f0104d31:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f0104d38:	eb c7                	jmp    f0104d01 <strtoul+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0104d3a:	8d 72 9f             	lea    -0x61(%edx),%esi
f0104d3d:	89 f3                	mov    %esi,%ebx
f0104d3f:	80 fb 19             	cmp    $0x19,%bl
f0104d42:	77 24                	ja     f0104d68 <strtoul+0xa5>
			dig = *s - 'a' + 10;
f0104d44:	0f be d2             	movsbl %dl,%edx
f0104d47:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0104d4a:	3b 55 10             	cmp    0x10(%ebp),%edx
f0104d4d:	7d 2b                	jge    f0104d7a <strtoul+0xb7>
			break;
		s++, val = (val * base) + dig;
f0104d4f:	41                   	inc    %ecx
f0104d50:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104d54:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0104d56:	8a 11                	mov    (%ecx),%dl
f0104d58:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0104d5b:	80 fb 09             	cmp    $0x9,%bl
f0104d5e:	77 da                	ja     f0104d3a <strtoul+0x77>
			dig = *s - '0';
f0104d60:	0f be d2             	movsbl %dl,%edx
f0104d63:	83 ea 30             	sub    $0x30,%edx
f0104d66:	eb e2                	jmp    f0104d4a <strtoul+0x87>
		else if (*s >= 'A' && *s <= 'Z')
f0104d68:	8d 72 bf             	lea    -0x41(%edx),%esi
f0104d6b:	89 f3                	mov    %esi,%ebx
f0104d6d:	80 fb 19             	cmp    $0x19,%bl
f0104d70:	77 08                	ja     f0104d7a <strtoul+0xb7>
			dig = *s - 'A' + 10;
f0104d72:	0f be d2             	movsbl %dl,%edx
f0104d75:	83 ea 37             	sub    $0x37,%edx
f0104d78:	eb d0                	jmp    f0104d4a <strtoul+0x87>
		// we don't properly detect overflow!
	}

	if (endptr)
f0104d7a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104d7e:	74 05                	je     f0104d85 <strtoul+0xc2>
		*endptr = (char *) s;
f0104d80:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104d83:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0104d85:	85 ff                	test   %edi,%edi
f0104d87:	74 02                	je     f0104d8b <strtoul+0xc8>
f0104d89:	f7 d8                	neg    %eax
}
f0104d8b:	5b                   	pop    %ebx
f0104d8c:	5e                   	pop    %esi
f0104d8d:	5f                   	pop    %edi
f0104d8e:	5d                   	pop    %ebp
f0104d8f:	c3                   	ret    

f0104d90 <__udivdi3>:
f0104d90:	55                   	push   %ebp
f0104d91:	57                   	push   %edi
f0104d92:	56                   	push   %esi
f0104d93:	53                   	push   %ebx
f0104d94:	83 ec 1c             	sub    $0x1c,%esp
f0104d97:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0104d9b:	8b 74 24 34          	mov    0x34(%esp),%esi
f0104d9f:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104da3:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0104da7:	85 d2                	test   %edx,%edx
f0104da9:	75 2d                	jne    f0104dd8 <__udivdi3+0x48>
f0104dab:	39 f7                	cmp    %esi,%edi
f0104dad:	77 59                	ja     f0104e08 <__udivdi3+0x78>
f0104daf:	89 f9                	mov    %edi,%ecx
f0104db1:	85 ff                	test   %edi,%edi
f0104db3:	75 0b                	jne    f0104dc0 <__udivdi3+0x30>
f0104db5:	b8 01 00 00 00       	mov    $0x1,%eax
f0104dba:	31 d2                	xor    %edx,%edx
f0104dbc:	f7 f7                	div    %edi
f0104dbe:	89 c1                	mov    %eax,%ecx
f0104dc0:	31 d2                	xor    %edx,%edx
f0104dc2:	89 f0                	mov    %esi,%eax
f0104dc4:	f7 f1                	div    %ecx
f0104dc6:	89 c3                	mov    %eax,%ebx
f0104dc8:	89 e8                	mov    %ebp,%eax
f0104dca:	f7 f1                	div    %ecx
f0104dcc:	89 da                	mov    %ebx,%edx
f0104dce:	83 c4 1c             	add    $0x1c,%esp
f0104dd1:	5b                   	pop    %ebx
f0104dd2:	5e                   	pop    %esi
f0104dd3:	5f                   	pop    %edi
f0104dd4:	5d                   	pop    %ebp
f0104dd5:	c3                   	ret    
f0104dd6:	66 90                	xchg   %ax,%ax
f0104dd8:	39 f2                	cmp    %esi,%edx
f0104dda:	77 1c                	ja     f0104df8 <__udivdi3+0x68>
f0104ddc:	0f bd da             	bsr    %edx,%ebx
f0104ddf:	83 f3 1f             	xor    $0x1f,%ebx
f0104de2:	75 38                	jne    f0104e1c <__udivdi3+0x8c>
f0104de4:	39 f2                	cmp    %esi,%edx
f0104de6:	72 08                	jb     f0104df0 <__udivdi3+0x60>
f0104de8:	39 ef                	cmp    %ebp,%edi
f0104dea:	0f 87 98 00 00 00    	ja     f0104e88 <__udivdi3+0xf8>
f0104df0:	b8 01 00 00 00       	mov    $0x1,%eax
f0104df5:	eb 05                	jmp    f0104dfc <__udivdi3+0x6c>
f0104df7:	90                   	nop
f0104df8:	31 db                	xor    %ebx,%ebx
f0104dfa:	31 c0                	xor    %eax,%eax
f0104dfc:	89 da                	mov    %ebx,%edx
f0104dfe:	83 c4 1c             	add    $0x1c,%esp
f0104e01:	5b                   	pop    %ebx
f0104e02:	5e                   	pop    %esi
f0104e03:	5f                   	pop    %edi
f0104e04:	5d                   	pop    %ebp
f0104e05:	c3                   	ret    
f0104e06:	66 90                	xchg   %ax,%ax
f0104e08:	89 e8                	mov    %ebp,%eax
f0104e0a:	89 f2                	mov    %esi,%edx
f0104e0c:	f7 f7                	div    %edi
f0104e0e:	31 db                	xor    %ebx,%ebx
f0104e10:	89 da                	mov    %ebx,%edx
f0104e12:	83 c4 1c             	add    $0x1c,%esp
f0104e15:	5b                   	pop    %ebx
f0104e16:	5e                   	pop    %esi
f0104e17:	5f                   	pop    %edi
f0104e18:	5d                   	pop    %ebp
f0104e19:	c3                   	ret    
f0104e1a:	66 90                	xchg   %ax,%ax
f0104e1c:	b8 20 00 00 00       	mov    $0x20,%eax
f0104e21:	29 d8                	sub    %ebx,%eax
f0104e23:	88 d9                	mov    %bl,%cl
f0104e25:	d3 e2                	shl    %cl,%edx
f0104e27:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104e2b:	89 fa                	mov    %edi,%edx
f0104e2d:	88 c1                	mov    %al,%cl
f0104e2f:	d3 ea                	shr    %cl,%edx
f0104e31:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0104e35:	09 d1                	or     %edx,%ecx
f0104e37:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104e3b:	88 d9                	mov    %bl,%cl
f0104e3d:	d3 e7                	shl    %cl,%edi
f0104e3f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104e43:	89 f7                	mov    %esi,%edi
f0104e45:	88 c1                	mov    %al,%cl
f0104e47:	d3 ef                	shr    %cl,%edi
f0104e49:	88 d9                	mov    %bl,%cl
f0104e4b:	d3 e6                	shl    %cl,%esi
f0104e4d:	89 ea                	mov    %ebp,%edx
f0104e4f:	88 c1                	mov    %al,%cl
f0104e51:	d3 ea                	shr    %cl,%edx
f0104e53:	09 d6                	or     %edx,%esi
f0104e55:	89 f0                	mov    %esi,%eax
f0104e57:	89 fa                	mov    %edi,%edx
f0104e59:	f7 74 24 08          	divl   0x8(%esp)
f0104e5d:	89 d7                	mov    %edx,%edi
f0104e5f:	89 c6                	mov    %eax,%esi
f0104e61:	f7 64 24 0c          	mull   0xc(%esp)
f0104e65:	39 d7                	cmp    %edx,%edi
f0104e67:	72 13                	jb     f0104e7c <__udivdi3+0xec>
f0104e69:	74 09                	je     f0104e74 <__udivdi3+0xe4>
f0104e6b:	89 f0                	mov    %esi,%eax
f0104e6d:	31 db                	xor    %ebx,%ebx
f0104e6f:	eb 8b                	jmp    f0104dfc <__udivdi3+0x6c>
f0104e71:	8d 76 00             	lea    0x0(%esi),%esi
f0104e74:	88 d9                	mov    %bl,%cl
f0104e76:	d3 e5                	shl    %cl,%ebp
f0104e78:	39 c5                	cmp    %eax,%ebp
f0104e7a:	73 ef                	jae    f0104e6b <__udivdi3+0xdb>
f0104e7c:	8d 46 ff             	lea    -0x1(%esi),%eax
f0104e7f:	31 db                	xor    %ebx,%ebx
f0104e81:	e9 76 ff ff ff       	jmp    f0104dfc <__udivdi3+0x6c>
f0104e86:	66 90                	xchg   %ax,%ax
f0104e88:	31 c0                	xor    %eax,%eax
f0104e8a:	e9 6d ff ff ff       	jmp    f0104dfc <__udivdi3+0x6c>
f0104e8f:	90                   	nop

f0104e90 <__umoddi3>:
f0104e90:	55                   	push   %ebp
f0104e91:	57                   	push   %edi
f0104e92:	56                   	push   %esi
f0104e93:	53                   	push   %ebx
f0104e94:	83 ec 1c             	sub    $0x1c,%esp
f0104e97:	8b 74 24 30          	mov    0x30(%esp),%esi
f0104e9b:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0104e9f:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104ea3:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0104ea7:	89 f0                	mov    %esi,%eax
f0104ea9:	89 da                	mov    %ebx,%edx
f0104eab:	85 ed                	test   %ebp,%ebp
f0104ead:	75 15                	jne    f0104ec4 <__umoddi3+0x34>
f0104eaf:	39 df                	cmp    %ebx,%edi
f0104eb1:	76 39                	jbe    f0104eec <__umoddi3+0x5c>
f0104eb3:	f7 f7                	div    %edi
f0104eb5:	89 d0                	mov    %edx,%eax
f0104eb7:	31 d2                	xor    %edx,%edx
f0104eb9:	83 c4 1c             	add    $0x1c,%esp
f0104ebc:	5b                   	pop    %ebx
f0104ebd:	5e                   	pop    %esi
f0104ebe:	5f                   	pop    %edi
f0104ebf:	5d                   	pop    %ebp
f0104ec0:	c3                   	ret    
f0104ec1:	8d 76 00             	lea    0x0(%esi),%esi
f0104ec4:	39 dd                	cmp    %ebx,%ebp
f0104ec6:	77 f1                	ja     f0104eb9 <__umoddi3+0x29>
f0104ec8:	0f bd cd             	bsr    %ebp,%ecx
f0104ecb:	83 f1 1f             	xor    $0x1f,%ecx
f0104ece:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104ed2:	75 38                	jne    f0104f0c <__umoddi3+0x7c>
f0104ed4:	39 dd                	cmp    %ebx,%ebp
f0104ed6:	72 04                	jb     f0104edc <__umoddi3+0x4c>
f0104ed8:	39 f7                	cmp    %esi,%edi
f0104eda:	77 dd                	ja     f0104eb9 <__umoddi3+0x29>
f0104edc:	89 da                	mov    %ebx,%edx
f0104ede:	89 f0                	mov    %esi,%eax
f0104ee0:	29 f8                	sub    %edi,%eax
f0104ee2:	19 ea                	sbb    %ebp,%edx
f0104ee4:	83 c4 1c             	add    $0x1c,%esp
f0104ee7:	5b                   	pop    %ebx
f0104ee8:	5e                   	pop    %esi
f0104ee9:	5f                   	pop    %edi
f0104eea:	5d                   	pop    %ebp
f0104eeb:	c3                   	ret    
f0104eec:	89 f9                	mov    %edi,%ecx
f0104eee:	85 ff                	test   %edi,%edi
f0104ef0:	75 0b                	jne    f0104efd <__umoddi3+0x6d>
f0104ef2:	b8 01 00 00 00       	mov    $0x1,%eax
f0104ef7:	31 d2                	xor    %edx,%edx
f0104ef9:	f7 f7                	div    %edi
f0104efb:	89 c1                	mov    %eax,%ecx
f0104efd:	89 d8                	mov    %ebx,%eax
f0104eff:	31 d2                	xor    %edx,%edx
f0104f01:	f7 f1                	div    %ecx
f0104f03:	89 f0                	mov    %esi,%eax
f0104f05:	f7 f1                	div    %ecx
f0104f07:	eb ac                	jmp    f0104eb5 <__umoddi3+0x25>
f0104f09:	8d 76 00             	lea    0x0(%esi),%esi
f0104f0c:	b8 20 00 00 00       	mov    $0x20,%eax
f0104f11:	89 c2                	mov    %eax,%edx
f0104f13:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104f17:	29 c2                	sub    %eax,%edx
f0104f19:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104f1d:	88 c1                	mov    %al,%cl
f0104f1f:	d3 e5                	shl    %cl,%ebp
f0104f21:	89 f8                	mov    %edi,%eax
f0104f23:	88 d1                	mov    %dl,%cl
f0104f25:	d3 e8                	shr    %cl,%eax
f0104f27:	09 c5                	or     %eax,%ebp
f0104f29:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104f2d:	88 c1                	mov    %al,%cl
f0104f2f:	d3 e7                	shl    %cl,%edi
f0104f31:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104f35:	89 df                	mov    %ebx,%edi
f0104f37:	88 d1                	mov    %dl,%cl
f0104f39:	d3 ef                	shr    %cl,%edi
f0104f3b:	88 c1                	mov    %al,%cl
f0104f3d:	d3 e3                	shl    %cl,%ebx
f0104f3f:	89 f0                	mov    %esi,%eax
f0104f41:	88 d1                	mov    %dl,%cl
f0104f43:	d3 e8                	shr    %cl,%eax
f0104f45:	09 d8                	or     %ebx,%eax
f0104f47:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0104f4b:	d3 e6                	shl    %cl,%esi
f0104f4d:	89 fa                	mov    %edi,%edx
f0104f4f:	f7 f5                	div    %ebp
f0104f51:	89 d1                	mov    %edx,%ecx
f0104f53:	f7 64 24 08          	mull   0x8(%esp)
f0104f57:	89 c3                	mov    %eax,%ebx
f0104f59:	89 d7                	mov    %edx,%edi
f0104f5b:	39 d1                	cmp    %edx,%ecx
f0104f5d:	72 29                	jb     f0104f88 <__umoddi3+0xf8>
f0104f5f:	74 23                	je     f0104f84 <__umoddi3+0xf4>
f0104f61:	89 ca                	mov    %ecx,%edx
f0104f63:	29 de                	sub    %ebx,%esi
f0104f65:	19 fa                	sbb    %edi,%edx
f0104f67:	89 d0                	mov    %edx,%eax
f0104f69:	8a 4c 24 0c          	mov    0xc(%esp),%cl
f0104f6d:	d3 e0                	shl    %cl,%eax
f0104f6f:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0104f73:	88 d9                	mov    %bl,%cl
f0104f75:	d3 ee                	shr    %cl,%esi
f0104f77:	09 f0                	or     %esi,%eax
f0104f79:	d3 ea                	shr    %cl,%edx
f0104f7b:	83 c4 1c             	add    $0x1c,%esp
f0104f7e:	5b                   	pop    %ebx
f0104f7f:	5e                   	pop    %esi
f0104f80:	5f                   	pop    %edi
f0104f81:	5d                   	pop    %ebp
f0104f82:	c3                   	ret    
f0104f83:	90                   	nop
f0104f84:	39 c6                	cmp    %eax,%esi
f0104f86:	73 d9                	jae    f0104f61 <__umoddi3+0xd1>
f0104f88:	2b 44 24 08          	sub    0x8(%esp),%eax
f0104f8c:	19 ea                	sbb    %ebp,%edx
f0104f8e:	89 d7                	mov    %edx,%edi
f0104f90:	89 c3                	mov    %eax,%ebx
f0104f92:	eb cd                	jmp    f0104f61 <__umoddi3+0xd1>
