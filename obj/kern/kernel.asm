
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
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
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
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

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
f010004b:	68 c0 18 10 f0       	push   $0xf01018c0
f0100050:	e8 47 09 00 00       	call   f010099c <cprintf>
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
f0100065:	e8 1a 07 00 00       	call   f0100784 <mon_backtrace>
f010006a:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010006d:	83 ec 08             	sub    $0x8,%esp
f0100070:	53                   	push   %ebx
f0100071:	68 dc 18 10 f0       	push   $0xf01018dc
f0100076:	e8 21 09 00 00       	call   f010099c <cprintf>
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
f010009a:	b8 44 29 11 f0       	mov    $0xf0112944,%eax
f010009f:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 23 11 f0       	push   $0xf0112300
f01000ac:	e8 1a 14 00 00       	call   f01014cb <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 d3 04 00 00       	call   f0100589 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 f7 18 10 f0       	push   $0xf01018f7
f01000c3:	e8 d4 08 00 00       	call   f010099c <cprintf>

	cprintf(ANSI_COLOR_RED     "This text is RED!"     ANSI_COLOR_RESET "\n");
f01000c8:	c7 04 24 12 19 10 f0 	movl   $0xf0101912,(%esp)
f01000cf:	e8 c8 08 00 00       	call   f010099c <cprintf>
	cprintf(ANSI_COLOR_GREEN   "This text is GREEN!"   ANSI_COLOR_RESET "\n");
f01000d4:	c7 04 24 2e 19 10 f0 	movl   $0xf010192e,(%esp)
f01000db:	e8 bc 08 00 00       	call   f010099c <cprintf>
	cprintf(ANSI_COLOR_YELLOW  "This text is YELLOW!"  ANSI_COLOR_RESET "\n");
f01000e0:	c7 04 24 b8 19 10 f0 	movl   $0xf01019b8,(%esp)
f01000e7:	e8 b0 08 00 00       	call   f010099c <cprintf>
	cprintf(ANSI_COLOR_BLUE    "This text is BLUE!"    ANSI_COLOR_RESET "\n");
f01000ec:	c7 04 24 4c 19 10 f0 	movl   $0xf010194c,(%esp)
f01000f3:	e8 a4 08 00 00       	call   f010099c <cprintf>
	cprintf(ANSI_COLOR_MAGENTA "This text is MAGENTA!" ANSI_COLOR_RESET "\n");
f01000f8:	c7 04 24 d8 19 10 f0 	movl   $0xf01019d8,(%esp)
f01000ff:	e8 98 08 00 00       	call   f010099c <cprintf>
	cprintf(ANSI_COLOR_CYAN    "This text is CYAN!"    ANSI_COLOR_RESET "\n");
f0100104:	c7 04 24 69 19 10 f0 	movl   $0xf0101969,(%esp)
f010010b:	e8 8c 08 00 00       	call   f010099c <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f0100110:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100117:	e8 24 ff ff ff       	call   f0100040 <test_backtrace>
f010011c:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010011f:	83 ec 0c             	sub    $0xc,%esp
f0100122:	6a 00                	push   $0x0
f0100124:	e8 ff 06 00 00       	call   f0100828 <monitor>
f0100129:	83 c4 10             	add    $0x10,%esp
f010012c:	eb f1                	jmp    f010011f <i386_init+0x8b>

f010012e <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010012e:	55                   	push   %ebp
f010012f:	89 e5                	mov    %esp,%ebp
f0100131:	56                   	push   %esi
f0100132:	53                   	push   %ebx
f0100133:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100136:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f010013d:	74 0f                	je     f010014e <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010013f:	83 ec 0c             	sub    $0xc,%esp
f0100142:	6a 00                	push   $0x0
f0100144:	e8 df 06 00 00       	call   f0100828 <monitor>
f0100149:	83 c4 10             	add    $0x10,%esp
f010014c:	eb f1                	jmp    f010013f <_panic+0x11>
	panicstr = fmt;
f010014e:	89 35 40 29 11 f0    	mov    %esi,0xf0112940
	asm volatile("cli; cld");
f0100154:	fa                   	cli    
f0100155:	fc                   	cld    
	va_start(ap, fmt);
f0100156:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100159:	83 ec 04             	sub    $0x4,%esp
f010015c:	ff 75 0c             	pushl  0xc(%ebp)
f010015f:	ff 75 08             	pushl  0x8(%ebp)
f0100162:	68 86 19 10 f0       	push   $0xf0101986
f0100167:	e8 30 08 00 00       	call   f010099c <cprintf>
	vcprintf(fmt, ap);
f010016c:	83 c4 08             	add    $0x8,%esp
f010016f:	53                   	push   %ebx
f0100170:	56                   	push   %esi
f0100171:	e8 00 08 00 00       	call   f0100976 <vcprintf>
	cprintf("\n");
f0100176:	c7 04 24 02 1a 10 f0 	movl   $0xf0101a02,(%esp)
f010017d:	e8 1a 08 00 00       	call   f010099c <cprintf>
f0100182:	83 c4 10             	add    $0x10,%esp
f0100185:	eb b8                	jmp    f010013f <_panic+0x11>

f0100187 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100187:	55                   	push   %ebp
f0100188:	89 e5                	mov    %esp,%ebp
f010018a:	53                   	push   %ebx
f010018b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010018e:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100191:	ff 75 0c             	pushl  0xc(%ebp)
f0100194:	ff 75 08             	pushl  0x8(%ebp)
f0100197:	68 9e 19 10 f0       	push   $0xf010199e
f010019c:	e8 fb 07 00 00       	call   f010099c <cprintf>
	vcprintf(fmt, ap);
f01001a1:	83 c4 08             	add    $0x8,%esp
f01001a4:	53                   	push   %ebx
f01001a5:	ff 75 10             	pushl  0x10(%ebp)
f01001a8:	e8 c9 07 00 00       	call   f0100976 <vcprintf>
	cprintf("\n");
f01001ad:	c7 04 24 02 1a 10 f0 	movl   $0xf0101a02,(%esp)
f01001b4:	e8 e3 07 00 00       	call   f010099c <cprintf>
	va_end(ap);
}
f01001b9:	83 c4 10             	add    $0x10,%esp
f01001bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01001bf:	c9                   	leave  
f01001c0:	c3                   	ret    

f01001c1 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001c1:	55                   	push   %ebp
f01001c2:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c4:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001c9:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001ca:	a8 01                	test   $0x1,%al
f01001cc:	74 0b                	je     f01001d9 <serial_proc_data+0x18>
f01001ce:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001d3:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001d4:	0f b6 c0             	movzbl %al,%eax
}
f01001d7:	5d                   	pop    %ebp
f01001d8:	c3                   	ret    
		return -1;
f01001d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001de:	eb f7                	jmp    f01001d7 <serial_proc_data+0x16>

f01001e0 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001e0:	55                   	push   %ebp
f01001e1:	89 e5                	mov    %esp,%ebp
f01001e3:	53                   	push   %ebx
f01001e4:	83 ec 04             	sub    $0x4,%esp
f01001e7:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001e9:	ff d3                	call   *%ebx
f01001eb:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001ee:	74 2d                	je     f010021d <cons_intr+0x3d>
		if (c == 0)
f01001f0:	85 c0                	test   %eax,%eax
f01001f2:	74 f5                	je     f01001e9 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f01001f4:	8b 0d 24 25 11 f0    	mov    0xf0112524,%ecx
f01001fa:	8d 51 01             	lea    0x1(%ecx),%edx
f01001fd:	89 15 24 25 11 f0    	mov    %edx,0xf0112524
f0100203:	88 81 20 23 11 f0    	mov    %al,-0xfeedce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100209:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010020f:	75 d8                	jne    f01001e9 <cons_intr+0x9>
			cons.wpos = 0;
f0100211:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f0100218:	00 00 00 
f010021b:	eb cc                	jmp    f01001e9 <cons_intr+0x9>
	}
}
f010021d:	83 c4 04             	add    $0x4,%esp
f0100220:	5b                   	pop    %ebx
f0100221:	5d                   	pop    %ebp
f0100222:	c3                   	ret    

f0100223 <kbd_proc_data>:
{
f0100223:	55                   	push   %ebp
f0100224:	89 e5                	mov    %esp,%ebp
f0100226:	53                   	push   %ebx
f0100227:	83 ec 04             	sub    $0x4,%esp
f010022a:	ba 64 00 00 00       	mov    $0x64,%edx
f010022f:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100230:	a8 01                	test   $0x1,%al
f0100232:	0f 84 f1 00 00 00    	je     f0100329 <kbd_proc_data+0x106>
	if (stat & KBS_TERR)
f0100238:	a8 20                	test   $0x20,%al
f010023a:	0f 85 f0 00 00 00    	jne    f0100330 <kbd_proc_data+0x10d>
f0100240:	ba 60 00 00 00       	mov    $0x60,%edx
f0100245:	ec                   	in     (%dx),%al
f0100246:	88 c2                	mov    %al,%dl
	if (data == 0xE0) {
f0100248:	3c e0                	cmp    $0xe0,%al
f010024a:	0f 84 8a 00 00 00    	je     f01002da <kbd_proc_data+0xb7>
	} else if (data & 0x80) {
f0100250:	84 c0                	test   %al,%al
f0100252:	0f 88 95 00 00 00    	js     f01002ed <kbd_proc_data+0xca>
	} else if (shift & E0ESC) {
f0100258:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f010025e:	f6 c1 40             	test   $0x40,%cl
f0100261:	74 0e                	je     f0100271 <kbd_proc_data+0x4e>
		data |= 0x80;
f0100263:	83 c8 80             	or     $0xffffff80,%eax
f0100266:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f0100268:	83 e1 bf             	and    $0xffffffbf,%ecx
f010026b:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	shift |= shiftcode[data];
f0100271:	0f b6 d2             	movzbl %dl,%edx
f0100274:	0f b6 82 60 1b 10 f0 	movzbl -0xfefe4a0(%edx),%eax
f010027b:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
	shift ^= togglecode[data];
f0100281:	0f b6 8a 60 1a 10 f0 	movzbl -0xfefe5a0(%edx),%ecx
f0100288:	31 c8                	xor    %ecx,%eax
f010028a:	a3 00 23 11 f0       	mov    %eax,0xf0112300
	c = charcode[shift & (CTL | SHIFT)][data];
f010028f:	89 c1                	mov    %eax,%ecx
f0100291:	83 e1 03             	and    $0x3,%ecx
f0100294:	8b 0c 8d 40 1a 10 f0 	mov    -0xfefe5c0(,%ecx,4),%ecx
f010029b:	8a 14 11             	mov    (%ecx,%edx,1),%dl
f010029e:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01002a1:	a8 08                	test   $0x8,%al
f01002a3:	74 0d                	je     f01002b2 <kbd_proc_data+0x8f>
		if ('a' <= c && c <= 'z')
f01002a5:	89 da                	mov    %ebx,%edx
f01002a7:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01002aa:	83 f9 19             	cmp    $0x19,%ecx
f01002ad:	77 6d                	ja     f010031c <kbd_proc_data+0xf9>
			c += 'A' - 'a';
f01002af:	83 eb 20             	sub    $0x20,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002b2:	f7 d0                	not    %eax
f01002b4:	a8 06                	test   $0x6,%al
f01002b6:	75 2e                	jne    f01002e6 <kbd_proc_data+0xc3>
f01002b8:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002be:	75 26                	jne    f01002e6 <kbd_proc_data+0xc3>
		cprintf("Rebooting!\n");
f01002c0:	83 ec 0c             	sub    $0xc,%esp
f01002c3:	68 f8 19 10 f0       	push   $0xf01019f8
f01002c8:	e8 cf 06 00 00       	call   f010099c <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002cd:	b0 03                	mov    $0x3,%al
f01002cf:	ba 92 00 00 00       	mov    $0x92,%edx
f01002d4:	ee                   	out    %al,(%dx)
f01002d5:	83 c4 10             	add    $0x10,%esp
f01002d8:	eb 0c                	jmp    f01002e6 <kbd_proc_data+0xc3>
		shift |= E0ESC;
f01002da:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f01002e1:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f01002e6:	89 d8                	mov    %ebx,%eax
f01002e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002eb:	c9                   	leave  
f01002ec:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002ed:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f01002f3:	f6 c1 40             	test   $0x40,%cl
f01002f6:	75 05                	jne    f01002fd <kbd_proc_data+0xda>
f01002f8:	83 e0 7f             	and    $0x7f,%eax
f01002fb:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f01002fd:	0f b6 d2             	movzbl %dl,%edx
f0100300:	8a 82 60 1b 10 f0    	mov    -0xfefe4a0(%edx),%al
f0100306:	83 c8 40             	or     $0x40,%eax
f0100309:	0f b6 c0             	movzbl %al,%eax
f010030c:	f7 d0                	not    %eax
f010030e:	21 c8                	and    %ecx,%eax
f0100310:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f0100315:	bb 00 00 00 00       	mov    $0x0,%ebx
f010031a:	eb ca                	jmp    f01002e6 <kbd_proc_data+0xc3>
		else if ('A' <= c && c <= 'Z')
f010031c:	83 ea 41             	sub    $0x41,%edx
f010031f:	83 fa 19             	cmp    $0x19,%edx
f0100322:	77 8e                	ja     f01002b2 <kbd_proc_data+0x8f>
			c += 'a' - 'A';
f0100324:	83 c3 20             	add    $0x20,%ebx
f0100327:	eb 89                	jmp    f01002b2 <kbd_proc_data+0x8f>
		return -1;
f0100329:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010032e:	eb b6                	jmp    f01002e6 <kbd_proc_data+0xc3>
		return -1;
f0100330:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0100335:	eb af                	jmp    f01002e6 <kbd_proc_data+0xc3>

f0100337 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100337:	55                   	push   %ebp
f0100338:	89 e5                	mov    %esp,%ebp
f010033a:	57                   	push   %edi
f010033b:	56                   	push   %esi
f010033c:	53                   	push   %ebx
f010033d:	83 ec 1c             	sub    $0x1c,%esp
f0100340:	89 c7                	mov    %eax,%edi
f0100342:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100347:	be fd 03 00 00       	mov    $0x3fd,%esi
f010034c:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100351:	eb 06                	jmp    f0100359 <cons_putc+0x22>
f0100353:	89 ca                	mov    %ecx,%edx
f0100355:	ec                   	in     (%dx),%al
f0100356:	ec                   	in     (%dx),%al
f0100357:	ec                   	in     (%dx),%al
f0100358:	ec                   	in     (%dx),%al
f0100359:	89 f2                	mov    %esi,%edx
f010035b:	ec                   	in     (%dx),%al
	for (i = 0;
f010035c:	a8 20                	test   $0x20,%al
f010035e:	75 03                	jne    f0100363 <cons_putc+0x2c>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100360:	4b                   	dec    %ebx
f0100361:	75 f0                	jne    f0100353 <cons_putc+0x1c>
	outb(COM1 + COM_TX, c);
f0100363:	89 f8                	mov    %edi,%eax
f0100365:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100368:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010036d:	ee                   	out    %al,(%dx)
f010036e:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100373:	be 79 03 00 00       	mov    $0x379,%esi
f0100378:	b9 84 00 00 00       	mov    $0x84,%ecx
f010037d:	eb 06                	jmp    f0100385 <cons_putc+0x4e>
f010037f:	89 ca                	mov    %ecx,%edx
f0100381:	ec                   	in     (%dx),%al
f0100382:	ec                   	in     (%dx),%al
f0100383:	ec                   	in     (%dx),%al
f0100384:	ec                   	in     (%dx),%al
f0100385:	89 f2                	mov    %esi,%edx
f0100387:	ec                   	in     (%dx),%al
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100388:	84 c0                	test   %al,%al
f010038a:	78 03                	js     f010038f <cons_putc+0x58>
f010038c:	4b                   	dec    %ebx
f010038d:	75 f0                	jne    f010037f <cons_putc+0x48>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010038f:	ba 78 03 00 00       	mov    $0x378,%edx
f0100394:	8a 45 e7             	mov    -0x19(%ebp),%al
f0100397:	ee                   	out    %al,(%dx)
f0100398:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010039d:	b0 0d                	mov    $0xd,%al
f010039f:	ee                   	out    %al,(%dx)
f01003a0:	b0 08                	mov    $0x8,%al
f01003a2:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01003a3:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f01003a9:	75 06                	jne    f01003b1 <cons_putc+0x7a>
		c |= 0x0700;
f01003ab:	81 cf 00 07 00 00    	or     $0x700,%edi
	switch (c & 0xff) {
f01003b1:	89 f8                	mov    %edi,%eax
f01003b3:	0f b6 c0             	movzbl %al,%eax
f01003b6:	83 f8 09             	cmp    $0x9,%eax
f01003b9:	0f 84 b1 00 00 00    	je     f0100470 <cons_putc+0x139>
f01003bf:	83 f8 09             	cmp    $0x9,%eax
f01003c2:	7e 70                	jle    f0100434 <cons_putc+0xfd>
f01003c4:	83 f8 0a             	cmp    $0xa,%eax
f01003c7:	0f 84 96 00 00 00    	je     f0100463 <cons_putc+0x12c>
f01003cd:	83 f8 0d             	cmp    $0xd,%eax
f01003d0:	0f 85 d1 00 00 00    	jne    f01004a7 <cons_putc+0x170>
		crt_pos -= (crt_pos % CRT_COLS);
f01003d6:	66 8b 0d 28 25 11 f0 	mov    0xf0112528,%cx
f01003dd:	bb 50 00 00 00       	mov    $0x50,%ebx
f01003e2:	89 c8                	mov    %ecx,%eax
f01003e4:	ba 00 00 00 00       	mov    $0x0,%edx
f01003e9:	66 f7 f3             	div    %bx
f01003ec:	29 d1                	sub    %edx,%ecx
f01003ee:	66 89 0d 28 25 11 f0 	mov    %cx,0xf0112528
	if (crt_pos >= CRT_SIZE) {
f01003f5:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f01003fc:	cf 07 
f01003fe:	0f 87 c5 00 00 00    	ja     f01004c9 <cons_putc+0x192>
	outb(addr_6845, 14);
f0100404:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f010040a:	b0 0e                	mov    $0xe,%al
f010040c:	89 ca                	mov    %ecx,%edx
f010040e:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010040f:	8d 59 01             	lea    0x1(%ecx),%ebx
f0100412:	66 a1 28 25 11 f0    	mov    0xf0112528,%ax
f0100418:	66 c1 e8 08          	shr    $0x8,%ax
f010041c:	89 da                	mov    %ebx,%edx
f010041e:	ee                   	out    %al,(%dx)
f010041f:	b0 0f                	mov    $0xf,%al
f0100421:	89 ca                	mov    %ecx,%edx
f0100423:	ee                   	out    %al,(%dx)
f0100424:	a0 28 25 11 f0       	mov    0xf0112528,%al
f0100429:	89 da                	mov    %ebx,%edx
f010042b:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010042c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010042f:	5b                   	pop    %ebx
f0100430:	5e                   	pop    %esi
f0100431:	5f                   	pop    %edi
f0100432:	5d                   	pop    %ebp
f0100433:	c3                   	ret    
	switch (c & 0xff) {
f0100434:	83 f8 08             	cmp    $0x8,%eax
f0100437:	75 6e                	jne    f01004a7 <cons_putc+0x170>
		if (crt_pos > 0) {
f0100439:	66 a1 28 25 11 f0    	mov    0xf0112528,%ax
f010043f:	66 85 c0             	test   %ax,%ax
f0100442:	74 c0                	je     f0100404 <cons_putc+0xcd>
			crt_pos--;
f0100444:	48                   	dec    %eax
f0100445:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010044b:	0f b7 c0             	movzwl %ax,%eax
f010044e:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f0100454:	83 cf 20             	or     $0x20,%edi
f0100457:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f010045d:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100461:	eb 92                	jmp    f01003f5 <cons_putc+0xbe>
		crt_pos += CRT_COLS;
f0100463:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f010046a:	50 
f010046b:	e9 66 ff ff ff       	jmp    f01003d6 <cons_putc+0x9f>
		cons_putc(' ');
f0100470:	b8 20 00 00 00       	mov    $0x20,%eax
f0100475:	e8 bd fe ff ff       	call   f0100337 <cons_putc>
		cons_putc(' ');
f010047a:	b8 20 00 00 00       	mov    $0x20,%eax
f010047f:	e8 b3 fe ff ff       	call   f0100337 <cons_putc>
		cons_putc(' ');
f0100484:	b8 20 00 00 00       	mov    $0x20,%eax
f0100489:	e8 a9 fe ff ff       	call   f0100337 <cons_putc>
		cons_putc(' ');
f010048e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100493:	e8 9f fe ff ff       	call   f0100337 <cons_putc>
		cons_putc(' ');
f0100498:	b8 20 00 00 00       	mov    $0x20,%eax
f010049d:	e8 95 fe ff ff       	call   f0100337 <cons_putc>
f01004a2:	e9 4e ff ff ff       	jmp    f01003f5 <cons_putc+0xbe>
		crt_buf[crt_pos++] = c;		/* write the character */
f01004a7:	66 a1 28 25 11 f0    	mov    0xf0112528,%ax
f01004ad:	8d 50 01             	lea    0x1(%eax),%edx
f01004b0:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f01004b7:	0f b7 c0             	movzwl %ax,%eax
f01004ba:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01004c0:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004c4:	e9 2c ff ff ff       	jmp    f01003f5 <cons_putc+0xbe>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004c9:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f01004ce:	83 ec 04             	sub    $0x4,%esp
f01004d1:	68 00 0f 00 00       	push   $0xf00
f01004d6:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004dc:	52                   	push   %edx
f01004dd:	50                   	push   %eax
f01004de:	e8 35 10 00 00       	call   f0101518 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01004e3:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01004e9:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01004ef:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01004f5:	83 c4 10             	add    $0x10,%esp
f01004f8:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01004fd:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100500:	39 d0                	cmp    %edx,%eax
f0100502:	75 f4                	jne    f01004f8 <cons_putc+0x1c1>
		crt_pos -= CRT_COLS;
f0100504:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f010050b:	50 
f010050c:	e9 f3 fe ff ff       	jmp    f0100404 <cons_putc+0xcd>

f0100511 <serial_intr>:
	if (serial_exists)
f0100511:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f0100518:	75 01                	jne    f010051b <serial_intr+0xa>
f010051a:	c3                   	ret    
{
f010051b:	55                   	push   %ebp
f010051c:	89 e5                	mov    %esp,%ebp
f010051e:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100521:	b8 c1 01 10 f0       	mov    $0xf01001c1,%eax
f0100526:	e8 b5 fc ff ff       	call   f01001e0 <cons_intr>
}
f010052b:	c9                   	leave  
f010052c:	c3                   	ret    

f010052d <kbd_intr>:
{
f010052d:	55                   	push   %ebp
f010052e:	89 e5                	mov    %esp,%ebp
f0100530:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100533:	b8 23 02 10 f0       	mov    $0xf0100223,%eax
f0100538:	e8 a3 fc ff ff       	call   f01001e0 <cons_intr>
}
f010053d:	c9                   	leave  
f010053e:	c3                   	ret    

f010053f <cons_getc>:
{
f010053f:	55                   	push   %ebp
f0100540:	89 e5                	mov    %esp,%ebp
f0100542:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f0100545:	e8 c7 ff ff ff       	call   f0100511 <serial_intr>
	kbd_intr();
f010054a:	e8 de ff ff ff       	call   f010052d <kbd_intr>
	if (cons.rpos != cons.wpos) {
f010054f:	a1 20 25 11 f0       	mov    0xf0112520,%eax
f0100554:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f010055a:	74 26                	je     f0100582 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f010055c:	8d 50 01             	lea    0x1(%eax),%edx
f010055f:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
f0100565:	0f b6 80 20 23 11 f0 	movzbl -0xfeedce0(%eax),%eax
		if (cons.rpos == CONSBUFSIZE)
f010056c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100572:	74 02                	je     f0100576 <cons_getc+0x37>
}
f0100574:	c9                   	leave  
f0100575:	c3                   	ret    
			cons.rpos = 0;
f0100576:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f010057d:	00 00 00 
f0100580:	eb f2                	jmp    f0100574 <cons_getc+0x35>
	return 0;
f0100582:	b8 00 00 00 00       	mov    $0x0,%eax
f0100587:	eb eb                	jmp    f0100574 <cons_getc+0x35>

f0100589 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100589:	55                   	push   %ebp
f010058a:	89 e5                	mov    %esp,%ebp
f010058c:	57                   	push   %edi
f010058d:	56                   	push   %esi
f010058e:	53                   	push   %ebx
f010058f:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f0100592:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f0100599:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01005a0:	5a a5 
	if (*cp != 0xA55A) {
f01005a2:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f01005a8:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005ac:	0f 84 a2 00 00 00    	je     f0100654 <cons_init+0xcb>
		addr_6845 = MONO_BASE;
f01005b2:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f01005b9:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005bc:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f01005c1:	8b 3d 30 25 11 f0    	mov    0xf0112530,%edi
f01005c7:	b0 0e                	mov    $0xe,%al
f01005c9:	89 fa                	mov    %edi,%edx
f01005cb:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005cc:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005cf:	89 ca                	mov    %ecx,%edx
f01005d1:	ec                   	in     (%dx),%al
f01005d2:	0f b6 c0             	movzbl %al,%eax
f01005d5:	c1 e0 08             	shl    $0x8,%eax
f01005d8:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005da:	b0 0f                	mov    $0xf,%al
f01005dc:	89 fa                	mov    %edi,%edx
f01005de:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005df:	89 ca                	mov    %ecx,%edx
f01005e1:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01005e2:	89 35 2c 25 11 f0    	mov    %esi,0xf011252c
	pos |= inb(addr_6845 + 1);
f01005e8:	0f b6 c0             	movzbl %al,%eax
f01005eb:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01005ed:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005f3:	b1 00                	mov    $0x0,%cl
f01005f5:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01005fa:	88 c8                	mov    %cl,%al
f01005fc:	89 da                	mov    %ebx,%edx
f01005fe:	ee                   	out    %al,(%dx)
f01005ff:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100604:	b0 80                	mov    $0x80,%al
f0100606:	89 fa                	mov    %edi,%edx
f0100608:	ee                   	out    %al,(%dx)
f0100609:	b0 0c                	mov    $0xc,%al
f010060b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100610:	ee                   	out    %al,(%dx)
f0100611:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100616:	88 c8                	mov    %cl,%al
f0100618:	89 f2                	mov    %esi,%edx
f010061a:	ee                   	out    %al,(%dx)
f010061b:	b0 03                	mov    $0x3,%al
f010061d:	89 fa                	mov    %edi,%edx
f010061f:	ee                   	out    %al,(%dx)
f0100620:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100625:	88 c8                	mov    %cl,%al
f0100627:	ee                   	out    %al,(%dx)
f0100628:	b0 01                	mov    $0x1,%al
f010062a:	89 f2                	mov    %esi,%edx
f010062c:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010062d:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100632:	ec                   	in     (%dx),%al
f0100633:	88 c1                	mov    %al,%cl
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100635:	3c ff                	cmp    $0xff,%al
f0100637:	0f 95 05 34 25 11 f0 	setne  0xf0112534
f010063e:	89 da                	mov    %ebx,%edx
f0100640:	ec                   	in     (%dx),%al
f0100641:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100646:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100647:	80 f9 ff             	cmp    $0xff,%cl
f010064a:	74 23                	je     f010066f <cons_init+0xe6>
		cprintf("Serial port does not exist!\n");
}
f010064c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010064f:	5b                   	pop    %ebx
f0100650:	5e                   	pop    %esi
f0100651:	5f                   	pop    %edi
f0100652:	5d                   	pop    %ebp
f0100653:	c3                   	ret    
		*cp = was;
f0100654:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010065b:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f0100662:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100665:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f010066a:	e9 52 ff ff ff       	jmp    f01005c1 <cons_init+0x38>
		cprintf("Serial port does not exist!\n");
f010066f:	83 ec 0c             	sub    $0xc,%esp
f0100672:	68 04 1a 10 f0       	push   $0xf0101a04
f0100677:	e8 20 03 00 00       	call   f010099c <cprintf>
f010067c:	83 c4 10             	add    $0x10,%esp
}
f010067f:	eb cb                	jmp    f010064c <cons_init+0xc3>

f0100681 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100681:	55                   	push   %ebp
f0100682:	89 e5                	mov    %esp,%ebp
f0100684:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100687:	8b 45 08             	mov    0x8(%ebp),%eax
f010068a:	e8 a8 fc ff ff       	call   f0100337 <cons_putc>
}
f010068f:	c9                   	leave  
f0100690:	c3                   	ret    

f0100691 <getchar>:

int
getchar(void)
{
f0100691:	55                   	push   %ebp
f0100692:	89 e5                	mov    %esp,%ebp
f0100694:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100697:	e8 a3 fe ff ff       	call   f010053f <cons_getc>
f010069c:	85 c0                	test   %eax,%eax
f010069e:	74 f7                	je     f0100697 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01006a0:	c9                   	leave  
f01006a1:	c3                   	ret    

f01006a2 <iscons>:

int
iscons(int fdnum)
{
f01006a2:	55                   	push   %ebp
f01006a3:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01006a5:	b8 01 00 00 00       	mov    $0x1,%eax
f01006aa:	5d                   	pop    %ebp
f01006ab:	c3                   	ret    

f01006ac <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006ac:	55                   	push   %ebp
f01006ad:	89 e5                	mov    %esp,%ebp
f01006af:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006b2:	68 60 1c 10 f0       	push   $0xf0101c60
f01006b7:	68 7e 1c 10 f0       	push   $0xf0101c7e
f01006bc:	68 83 1c 10 f0       	push   $0xf0101c83
f01006c1:	e8 d6 02 00 00       	call   f010099c <cprintf>
f01006c6:	83 c4 0c             	add    $0xc,%esp
f01006c9:	68 18 1d 10 f0       	push   $0xf0101d18
f01006ce:	68 8c 1c 10 f0       	push   $0xf0101c8c
f01006d3:	68 83 1c 10 f0       	push   $0xf0101c83
f01006d8:	e8 bf 02 00 00       	call   f010099c <cprintf>
	return 0;
}
f01006dd:	b8 00 00 00 00       	mov    $0x0,%eax
f01006e2:	c9                   	leave  
f01006e3:	c3                   	ret    

f01006e4 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006e4:	55                   	push   %ebp
f01006e5:	89 e5                	mov    %esp,%ebp
f01006e7:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006ea:	68 95 1c 10 f0       	push   $0xf0101c95
f01006ef:	e8 a8 02 00 00       	call   f010099c <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006f4:	83 c4 08             	add    $0x8,%esp
f01006f7:	68 0c 00 10 00       	push   $0x10000c
f01006fc:	68 40 1d 10 f0       	push   $0xf0101d40
f0100701:	e8 96 02 00 00       	call   f010099c <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100706:	83 c4 0c             	add    $0xc,%esp
f0100709:	68 0c 00 10 00       	push   $0x10000c
f010070e:	68 0c 00 10 f0       	push   $0xf010000c
f0100713:	68 68 1d 10 f0       	push   $0xf0101d68
f0100718:	e8 7f 02 00 00       	call   f010099c <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010071d:	83 c4 0c             	add    $0xc,%esp
f0100720:	68 b0 18 10 00       	push   $0x1018b0
f0100725:	68 b0 18 10 f0       	push   $0xf01018b0
f010072a:	68 8c 1d 10 f0       	push   $0xf0101d8c
f010072f:	e8 68 02 00 00       	call   f010099c <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100734:	83 c4 0c             	add    $0xc,%esp
f0100737:	68 00 23 11 00       	push   $0x112300
f010073c:	68 00 23 11 f0       	push   $0xf0112300
f0100741:	68 b0 1d 10 f0       	push   $0xf0101db0
f0100746:	e8 51 02 00 00       	call   f010099c <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010074b:	83 c4 0c             	add    $0xc,%esp
f010074e:	68 44 29 11 00       	push   $0x112944
f0100753:	68 44 29 11 f0       	push   $0xf0112944
f0100758:	68 d4 1d 10 f0       	push   $0xf0101dd4
f010075d:	e8 3a 02 00 00       	call   f010099c <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100762:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100765:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
f010076a:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f010076f:	c1 f8 0a             	sar    $0xa,%eax
f0100772:	50                   	push   %eax
f0100773:	68 f8 1d 10 f0       	push   $0xf0101df8
f0100778:	e8 1f 02 00 00       	call   f010099c <cprintf>
	return 0;
}
f010077d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100782:	c9                   	leave  
f0100783:	c3                   	ret    

f0100784 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100784:	55                   	push   %ebp
f0100785:	89 e5                	mov    %esp,%ebp
f0100787:	57                   	push   %edi
f0100788:	56                   	push   %esi
f0100789:	53                   	push   %ebx
f010078a:	83 ec 38             	sub    $0x38,%esp
	cprintf("Stack backtrace:\n");
f010078d:	68 ae 1c 10 f0       	push   $0xf0101cae
f0100792:	e8 05 02 00 00       	call   f010099c <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100797:	89 e8                	mov    %ebp,%eax
	uint32_t ebp = read_ebp(), prev_ebp, eip;
	while (ebp != 0) {
f0100799:	83 c4 10             	add    $0x10,%esp
f010079c:	eb 34                	jmp    f01007d2 <mon_backtrace+0x4e>
				*((int*)ebp + 5), *((int*)ebp + 6));
		struct Eipdebuginfo info;
		int code = debuginfo_eip((uintptr_t)eip, &info);
		cprintf("         %s:%d: ", info.eip_file, info.eip_line);
		for (int i = 0; i < info.eip_fn_namelen; i++)
			cprintf("%c", info.eip_fn_name[i]);
f010079e:	83 ec 08             	sub    $0x8,%esp
f01007a1:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01007a4:	0f be 04 18          	movsbl (%eax,%ebx,1),%eax
f01007a8:	50                   	push   %eax
f01007a9:	68 d1 1c 10 f0       	push   $0xf0101cd1
f01007ae:	e8 e9 01 00 00       	call   f010099c <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f01007b3:	43                   	inc    %ebx
f01007b4:	83 c4 10             	add    $0x10,%esp
f01007b7:	39 5d dc             	cmp    %ebx,-0x24(%ebp)
f01007ba:	7f e2                	jg     f010079e <mon_backtrace+0x1a>
		cprintf("+%d\n", eip - info.eip_fn_addr);
f01007bc:	83 ec 08             	sub    $0x8,%esp
f01007bf:	2b 75 e0             	sub    -0x20(%ebp),%esi
f01007c2:	56                   	push   %esi
f01007c3:	68 d4 1c 10 f0       	push   $0xf0101cd4
f01007c8:	e8 cf 01 00 00       	call   f010099c <cprintf>
		ebp = prev_ebp;
f01007cd:	83 c4 10             	add    $0x10,%esp
f01007d0:	89 f8                	mov    %edi,%eax
	while (ebp != 0) {
f01007d2:	85 c0                	test   %eax,%eax
f01007d4:	74 4a                	je     f0100820 <mon_backtrace+0x9c>
		prev_ebp = *(int*)ebp;
f01007d6:	8b 38                	mov    (%eax),%edi
		eip = *((int*)ebp + 1);
f01007d8:	8b 70 04             	mov    0x4(%eax),%esi
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, 
f01007db:	ff 70 18             	pushl  0x18(%eax)
f01007de:	ff 70 14             	pushl  0x14(%eax)
f01007e1:	ff 70 10             	pushl  0x10(%eax)
f01007e4:	ff 70 0c             	pushl  0xc(%eax)
f01007e7:	ff 70 08             	pushl  0x8(%eax)
f01007ea:	56                   	push   %esi
f01007eb:	50                   	push   %eax
f01007ec:	68 24 1e 10 f0       	push   $0xf0101e24
f01007f1:	e8 a6 01 00 00       	call   f010099c <cprintf>
		int code = debuginfo_eip((uintptr_t)eip, &info);
f01007f6:	83 c4 18             	add    $0x18,%esp
f01007f9:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01007fc:	50                   	push   %eax
f01007fd:	56                   	push   %esi
f01007fe:	e8 9a 02 00 00       	call   f0100a9d <debuginfo_eip>
		cprintf("         %s:%d: ", info.eip_file, info.eip_line);
f0100803:	83 c4 0c             	add    $0xc,%esp
f0100806:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100809:	ff 75 d0             	pushl  -0x30(%ebp)
f010080c:	68 c0 1c 10 f0       	push   $0xf0101cc0
f0100811:	e8 86 01 00 00       	call   f010099c <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f0100816:	83 c4 10             	add    $0x10,%esp
f0100819:	bb 00 00 00 00       	mov    $0x0,%ebx
f010081e:	eb 97                	jmp    f01007b7 <mon_backtrace+0x33>
	}
	return 0;
}
f0100820:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100823:	5b                   	pop    %ebx
f0100824:	5e                   	pop    %esi
f0100825:	5f                   	pop    %edi
f0100826:	5d                   	pop    %ebp
f0100827:	c3                   	ret    

f0100828 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100828:	55                   	push   %ebp
f0100829:	89 e5                	mov    %esp,%ebp
f010082b:	57                   	push   %edi
f010082c:	56                   	push   %esi
f010082d:	53                   	push   %ebx
f010082e:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100831:	68 5c 1e 10 f0       	push   $0xf0101e5c
f0100836:	e8 61 01 00 00       	call   f010099c <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010083b:	c7 04 24 80 1e 10 f0 	movl   $0xf0101e80,(%esp)
f0100842:	e8 55 01 00 00       	call   f010099c <cprintf>
f0100847:	83 c4 10             	add    $0x10,%esp
f010084a:	eb 47                	jmp    f0100893 <monitor+0x6b>
		while (*buf && strchr(WHITESPACE, *buf))
f010084c:	83 ec 08             	sub    $0x8,%esp
f010084f:	0f be c0             	movsbl %al,%eax
f0100852:	50                   	push   %eax
f0100853:	68 dd 1c 10 f0       	push   $0xf0101cdd
f0100858:	e8 39 0c 00 00       	call   f0101496 <strchr>
f010085d:	83 c4 10             	add    $0x10,%esp
f0100860:	85 c0                	test   %eax,%eax
f0100862:	74 0a                	je     f010086e <monitor+0x46>
			*buf++ = 0;
f0100864:	c6 03 00             	movb   $0x0,(%ebx)
f0100867:	89 f7                	mov    %esi,%edi
f0100869:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010086c:	eb 68                	jmp    f01008d6 <monitor+0xae>
		if (*buf == 0)
f010086e:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100871:	74 6f                	je     f01008e2 <monitor+0xba>
		if (argc == MAXARGS-1) {
f0100873:	83 fe 0f             	cmp    $0xf,%esi
f0100876:	74 09                	je     f0100881 <monitor+0x59>
		argv[argc++] = buf;
f0100878:	8d 7e 01             	lea    0x1(%esi),%edi
f010087b:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010087f:	eb 37                	jmp    f01008b8 <monitor+0x90>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100881:	83 ec 08             	sub    $0x8,%esp
f0100884:	6a 10                	push   $0x10
f0100886:	68 e2 1c 10 f0       	push   $0xf0101ce2
f010088b:	e8 0c 01 00 00       	call   f010099c <cprintf>
f0100890:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100893:	83 ec 0c             	sub    $0xc,%esp
f0100896:	68 d9 1c 10 f0       	push   $0xf0101cd9
f010089b:	e8 eb 09 00 00       	call   f010128b <readline>
f01008a0:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01008a2:	83 c4 10             	add    $0x10,%esp
f01008a5:	85 c0                	test   %eax,%eax
f01008a7:	74 ea                	je     f0100893 <monitor+0x6b>
	argv[argc] = 0;
f01008a9:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01008b0:	be 00 00 00 00       	mov    $0x0,%esi
f01008b5:	eb 21                	jmp    f01008d8 <monitor+0xb0>
			buf++;
f01008b7:	43                   	inc    %ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f01008b8:	8a 03                	mov    (%ebx),%al
f01008ba:	84 c0                	test   %al,%al
f01008bc:	74 18                	je     f01008d6 <monitor+0xae>
f01008be:	83 ec 08             	sub    $0x8,%esp
f01008c1:	0f be c0             	movsbl %al,%eax
f01008c4:	50                   	push   %eax
f01008c5:	68 dd 1c 10 f0       	push   $0xf0101cdd
f01008ca:	e8 c7 0b 00 00       	call   f0101496 <strchr>
f01008cf:	83 c4 10             	add    $0x10,%esp
f01008d2:	85 c0                	test   %eax,%eax
f01008d4:	74 e1                	je     f01008b7 <monitor+0x8f>
			*buf++ = 0;
f01008d6:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f01008d8:	8a 03                	mov    (%ebx),%al
f01008da:	84 c0                	test   %al,%al
f01008dc:	0f 85 6a ff ff ff    	jne    f010084c <monitor+0x24>
	argv[argc] = 0;
f01008e2:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008e9:	00 
	if (argc == 0)
f01008ea:	85 f6                	test   %esi,%esi
f01008ec:	74 a5                	je     f0100893 <monitor+0x6b>
		if (strcmp(argv[0], commands[i].name) == 0)
f01008ee:	83 ec 08             	sub    $0x8,%esp
f01008f1:	68 7e 1c 10 f0       	push   $0xf0101c7e
f01008f6:	ff 75 a8             	pushl  -0x58(%ebp)
f01008f9:	e8 44 0b 00 00       	call   f0101442 <strcmp>
f01008fe:	83 c4 10             	add    $0x10,%esp
f0100901:	85 c0                	test   %eax,%eax
f0100903:	74 34                	je     f0100939 <monitor+0x111>
f0100905:	83 ec 08             	sub    $0x8,%esp
f0100908:	68 8c 1c 10 f0       	push   $0xf0101c8c
f010090d:	ff 75 a8             	pushl  -0x58(%ebp)
f0100910:	e8 2d 0b 00 00       	call   f0101442 <strcmp>
f0100915:	83 c4 10             	add    $0x10,%esp
f0100918:	85 c0                	test   %eax,%eax
f010091a:	74 18                	je     f0100934 <monitor+0x10c>
	cprintf("Unknown command '%s'\n", argv[0]);
f010091c:	83 ec 08             	sub    $0x8,%esp
f010091f:	ff 75 a8             	pushl  -0x58(%ebp)
f0100922:	68 ff 1c 10 f0       	push   $0xf0101cff
f0100927:	e8 70 00 00 00       	call   f010099c <cprintf>
f010092c:	83 c4 10             	add    $0x10,%esp
f010092f:	e9 5f ff ff ff       	jmp    f0100893 <monitor+0x6b>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100934:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100939:	83 ec 04             	sub    $0x4,%esp
f010093c:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010093f:	01 d0                	add    %edx,%eax
f0100941:	ff 75 08             	pushl  0x8(%ebp)
f0100944:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100947:	51                   	push   %ecx
f0100948:	56                   	push   %esi
f0100949:	ff 14 85 b0 1e 10 f0 	call   *-0xfefe150(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100950:	83 c4 10             	add    $0x10,%esp
f0100953:	85 c0                	test   %eax,%eax
f0100955:	0f 89 38 ff ff ff    	jns    f0100893 <monitor+0x6b>
				break;
	}
}
f010095b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010095e:	5b                   	pop    %ebx
f010095f:	5e                   	pop    %esi
f0100960:	5f                   	pop    %edi
f0100961:	5d                   	pop    %ebp
f0100962:	c3                   	ret    

f0100963 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100963:	55                   	push   %ebp
f0100964:	89 e5                	mov    %esp,%ebp
f0100966:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0100969:	ff 75 08             	pushl  0x8(%ebp)
f010096c:	e8 10 fd ff ff       	call   f0100681 <cputchar>
	*cnt++;
}
f0100971:	83 c4 10             	add    $0x10,%esp
f0100974:	c9                   	leave  
f0100975:	c3                   	ret    

f0100976 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100976:	55                   	push   %ebp
f0100977:	89 e5                	mov    %esp,%ebp
f0100979:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010097c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100983:	ff 75 0c             	pushl  0xc(%ebp)
f0100986:	ff 75 08             	pushl  0x8(%ebp)
f0100989:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010098c:	50                   	push   %eax
f010098d:	68 63 09 10 f0       	push   $0xf0100963
f0100992:	e8 1b 04 00 00       	call   f0100db2 <vprintfmt>
	return cnt;
}
f0100997:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010099a:	c9                   	leave  
f010099b:	c3                   	ret    

f010099c <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010099c:	55                   	push   %ebp
f010099d:	89 e5                	mov    %esp,%ebp
f010099f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01009a2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01009a5:	50                   	push   %eax
f01009a6:	ff 75 08             	pushl  0x8(%ebp)
f01009a9:	e8 c8 ff ff ff       	call   f0100976 <vcprintf>
	va_end(ap);

	return cnt;
}
f01009ae:	c9                   	leave  
f01009af:	c3                   	ret    

f01009b0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01009b0:	55                   	push   %ebp
f01009b1:	89 e5                	mov    %esp,%ebp
f01009b3:	57                   	push   %edi
f01009b4:	56                   	push   %esi
f01009b5:	53                   	push   %ebx
f01009b6:	83 ec 14             	sub    $0x14,%esp
f01009b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01009bc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01009bf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01009c2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01009c5:	8b 32                	mov    (%edx),%esi
f01009c7:	8b 01                	mov    (%ecx),%eax
f01009c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01009cc:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01009d3:	eb 2f                	jmp    f0100a04 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f01009d5:	48                   	dec    %eax
		while (m >= l && stabs[m].n_type != type)
f01009d6:	39 c6                	cmp    %eax,%esi
f01009d8:	7f 4d                	jg     f0100a27 <stab_binsearch+0x77>
f01009da:	0f b6 0a             	movzbl (%edx),%ecx
f01009dd:	83 ea 0c             	sub    $0xc,%edx
f01009e0:	39 f9                	cmp    %edi,%ecx
f01009e2:	75 f1                	jne    f01009d5 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01009e4:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01009e7:	01 c2                	add    %eax,%edx
f01009e9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01009ec:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01009f0:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01009f3:	73 37                	jae    f0100a2c <stab_binsearch+0x7c>
			*region_left = m;
f01009f5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01009f8:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f01009fa:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f01009fd:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100a04:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0100a07:	7f 4d                	jg     f0100a56 <stab_binsearch+0xa6>
		int true_m = (l + r) / 2, m = true_m;
f0100a09:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100a0c:	01 f0                	add    %esi,%eax
f0100a0e:	89 c3                	mov    %eax,%ebx
f0100a10:	c1 eb 1f             	shr    $0x1f,%ebx
f0100a13:	01 c3                	add    %eax,%ebx
f0100a15:	d1 fb                	sar    %ebx
f0100a17:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100a1a:	01 d8                	add    %ebx,%eax
f0100a1c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100a1f:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100a23:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0100a25:	eb af                	jmp    f01009d6 <stab_binsearch+0x26>
			l = true_m + 1;
f0100a27:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0100a2a:	eb d8                	jmp    f0100a04 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100a2c:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100a2f:	76 12                	jbe    f0100a43 <stab_binsearch+0x93>
			*region_right = m - 1;
f0100a31:	48                   	dec    %eax
f0100a32:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a35:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100a38:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0100a3a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a41:	eb c1                	jmp    f0100a04 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a43:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a46:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100a48:	ff 45 0c             	incl   0xc(%ebp)
f0100a4b:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0100a4d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a54:	eb ae                	jmp    f0100a04 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0100a56:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100a5a:	74 18                	je     f0100a74 <stab_binsearch+0xc4>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a5f:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100a61:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a64:	8b 0e                	mov    (%esi),%ecx
f0100a66:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100a69:	01 c2                	add    %eax,%edx
f0100a6b:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100a6e:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0100a72:	eb 0e                	jmp    f0100a82 <stab_binsearch+0xd2>
		*region_right = *region_left - 1;
f0100a74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a77:	8b 00                	mov    (%eax),%eax
f0100a79:	48                   	dec    %eax
f0100a7a:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100a7d:	89 07                	mov    %eax,(%edi)
f0100a7f:	eb 14                	jmp    f0100a95 <stab_binsearch+0xe5>
		     l--)
f0100a81:	48                   	dec    %eax
		for (l = *region_right;
f0100a82:	39 c1                	cmp    %eax,%ecx
f0100a84:	7d 0a                	jge    f0100a90 <stab_binsearch+0xe0>
		     l > *region_left && stabs[l].n_type != type;
f0100a86:	0f b6 1a             	movzbl (%edx),%ebx
f0100a89:	83 ea 0c             	sub    $0xc,%edx
f0100a8c:	39 fb                	cmp    %edi,%ebx
f0100a8e:	75 f1                	jne    f0100a81 <stab_binsearch+0xd1>
			/* do nothing */;
		*region_left = l;
f0100a90:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100a93:	89 07                	mov    %eax,(%edi)
	}
}
f0100a95:	83 c4 14             	add    $0x14,%esp
f0100a98:	5b                   	pop    %ebx
f0100a99:	5e                   	pop    %esi
f0100a9a:	5f                   	pop    %edi
f0100a9b:	5d                   	pop    %ebp
f0100a9c:	c3                   	ret    

f0100a9d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100a9d:	55                   	push   %ebp
f0100a9e:	89 e5                	mov    %esp,%ebp
f0100aa0:	57                   	push   %edi
f0100aa1:	56                   	push   %esi
f0100aa2:	53                   	push   %ebx
f0100aa3:	83 ec 3c             	sub    $0x3c,%esp
f0100aa6:	8b 75 08             	mov    0x8(%ebp),%esi
f0100aa9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100aac:	c7 03 c0 1e 10 f0    	movl   $0xf0101ec0,(%ebx)
	info->eip_line = 0;
f0100ab2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100ab9:	c7 43 08 c0 1e 10 f0 	movl   $0xf0101ec0,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100ac0:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100ac7:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100aca:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100ad1:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100ad7:	0f 86 31 01 00 00    	jbe    f0100c0e <debuginfo_eip+0x171>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100add:	b8 48 77 10 f0       	mov    $0xf0107748,%eax
f0100ae2:	3d dd 5d 10 f0       	cmp    $0xf0105ddd,%eax
f0100ae7:	0f 86 b6 01 00 00    	jbe    f0100ca3 <debuginfo_eip+0x206>
f0100aed:	80 3d 47 77 10 f0 00 	cmpb   $0x0,0xf0107747
f0100af4:	0f 85 b0 01 00 00    	jne    f0100caa <debuginfo_eip+0x20d>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100afa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100b01:	ba dc 5d 10 f0       	mov    $0xf0105ddc,%edx
f0100b06:	81 ea f8 20 10 f0    	sub    $0xf01020f8,%edx
f0100b0c:	c1 fa 02             	sar    $0x2,%edx
f0100b0f:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0100b12:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100b15:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100b18:	89 c1                	mov    %eax,%ecx
f0100b1a:	c1 e1 08             	shl    $0x8,%ecx
f0100b1d:	01 c8                	add    %ecx,%eax
f0100b1f:	89 c1                	mov    %eax,%ecx
f0100b21:	c1 e1 10             	shl    $0x10,%ecx
f0100b24:	01 c8                	add    %ecx,%eax
f0100b26:	01 c0                	add    %eax,%eax
f0100b28:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
f0100b2c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100b2f:	83 ec 08             	sub    $0x8,%esp
f0100b32:	56                   	push   %esi
f0100b33:	6a 64                	push   $0x64
f0100b35:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100b38:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100b3b:	b8 f8 20 10 f0       	mov    $0xf01020f8,%eax
f0100b40:	e8 6b fe ff ff       	call   f01009b0 <stab_binsearch>
	if (lfile == 0)
f0100b45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b48:	83 c4 10             	add    $0x10,%esp
f0100b4b:	85 c0                	test   %eax,%eax
f0100b4d:	0f 84 5e 01 00 00    	je     f0100cb1 <debuginfo_eip+0x214>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100b53:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100b56:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b59:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100b5c:	83 ec 08             	sub    $0x8,%esp
f0100b5f:	56                   	push   %esi
f0100b60:	6a 24                	push   $0x24
f0100b62:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100b65:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b68:	b8 f8 20 10 f0       	mov    $0xf01020f8,%eax
f0100b6d:	e8 3e fe ff ff       	call   f01009b0 <stab_binsearch>

	if (lfun <= rfun) {
f0100b72:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100b75:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100b78:	83 c4 10             	add    $0x10,%esp
f0100b7b:	39 d0                	cmp    %edx,%eax
f0100b7d:	0f 8f 9f 00 00 00    	jg     f0100c22 <debuginfo_eip+0x185>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100b83:	8d 0c 00             	lea    (%eax,%eax,1),%ecx
f0100b86:	01 c1                	add    %eax,%ecx
f0100b88:	c1 e1 02             	shl    $0x2,%ecx
f0100b8b:	8d b9 f8 20 10 f0    	lea    -0xfefdf08(%ecx),%edi
f0100b91:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100b94:	8b 89 f8 20 10 f0    	mov    -0xfefdf08(%ecx),%ecx
f0100b9a:	bf 48 77 10 f0       	mov    $0xf0107748,%edi
f0100b9f:	81 ef dd 5d 10 f0    	sub    $0xf0105ddd,%edi
f0100ba5:	39 f9                	cmp    %edi,%ecx
f0100ba7:	73 09                	jae    f0100bb2 <debuginfo_eip+0x115>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100ba9:	81 c1 dd 5d 10 f0    	add    $0xf0105ddd,%ecx
f0100baf:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100bb2:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100bb5:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100bb8:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100bbb:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100bbd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100bc0:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100bc3:	83 ec 08             	sub    $0x8,%esp
f0100bc6:	6a 3a                	push   $0x3a
f0100bc8:	ff 73 08             	pushl  0x8(%ebx)
f0100bcb:	e8 e3 08 00 00       	call   f01014b3 <strfind>
f0100bd0:	2b 43 08             	sub    0x8(%ebx),%eax
f0100bd3:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// N_SLINE represents text segment
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100bd6:	83 c4 08             	add    $0x8,%esp
f0100bd9:	56                   	push   %esi
f0100bda:	6a 44                	push   $0x44
f0100bdc:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100bdf:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100be2:	b8 f8 20 10 f0       	mov    $0xf01020f8,%eax
f0100be7:	e8 c4 fd ff ff       	call   f01009b0 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0100bec:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100bef:	8d 04 12             	lea    (%edx,%edx,1),%eax
f0100bf2:	01 d0                	add    %edx,%eax
f0100bf4:	c1 e0 02             	shl    $0x2,%eax
f0100bf7:	0f b7 88 fe 20 10 f0 	movzwl -0xfefdf02(%eax),%ecx
f0100bfe:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c01:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100c04:	05 fc 20 10 f0       	add    $0xf01020fc,%eax
f0100c09:	83 c4 10             	add    $0x10,%esp
f0100c0c:	eb 29                	jmp    f0100c37 <debuginfo_eip+0x19a>
  	        panic("User address");
f0100c0e:	83 ec 04             	sub    $0x4,%esp
f0100c11:	68 ca 1e 10 f0       	push   $0xf0101eca
f0100c16:	6a 7f                	push   $0x7f
f0100c18:	68 d7 1e 10 f0       	push   $0xf0101ed7
f0100c1d:	e8 0c f5 ff ff       	call   f010012e <_panic>
		info->eip_fn_addr = addr;
f0100c22:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100c25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c28:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100c2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c2e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100c31:	eb 90                	jmp    f0100bc3 <debuginfo_eip+0x126>
f0100c33:	4a                   	dec    %edx
f0100c34:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0100c37:	39 d6                	cmp    %edx,%esi
f0100c39:	7f 34                	jg     f0100c6f <debuginfo_eip+0x1d2>
	       && stabs[lline].n_type != N_SOL
f0100c3b:	8a 08                	mov    (%eax),%cl
f0100c3d:	80 f9 84             	cmp    $0x84,%cl
f0100c40:	74 0b                	je     f0100c4d <debuginfo_eip+0x1b0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100c42:	80 f9 64             	cmp    $0x64,%cl
f0100c45:	75 ec                	jne    f0100c33 <debuginfo_eip+0x196>
f0100c47:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100c4b:	74 e6                	je     f0100c33 <debuginfo_eip+0x196>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100c4d:	8d 04 12             	lea    (%edx,%edx,1),%eax
f0100c50:	01 c2                	add    %eax,%edx
f0100c52:	8b 14 95 f8 20 10 f0 	mov    -0xfefdf08(,%edx,4),%edx
f0100c59:	b8 48 77 10 f0       	mov    $0xf0107748,%eax
f0100c5e:	2d dd 5d 10 f0       	sub    $0xf0105ddd,%eax
f0100c63:	39 c2                	cmp    %eax,%edx
f0100c65:	73 08                	jae    f0100c6f <debuginfo_eip+0x1d2>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100c67:	81 c2 dd 5d 10 f0    	add    $0xf0105ddd,%edx
f0100c6d:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c6f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c72:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0100c75:	39 f2                	cmp    %esi,%edx
f0100c77:	7d 3f                	jge    f0100cb8 <debuginfo_eip+0x21b>
		for (lline = lfun + 1;
f0100c79:	42                   	inc    %edx
f0100c7a:	89 d0                	mov    %edx,%eax
f0100c7c:	8d 0c 12             	lea    (%edx,%edx,1),%ecx
f0100c7f:	01 ca                	add    %ecx,%edx
f0100c81:	8d 14 95 fc 20 10 f0 	lea    -0xfefdf04(,%edx,4),%edx
f0100c88:	eb 03                	jmp    f0100c8d <debuginfo_eip+0x1f0>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100c8a:	ff 43 14             	incl   0x14(%ebx)
		for (lline = lfun + 1;
f0100c8d:	39 c6                	cmp    %eax,%esi
f0100c8f:	7e 34                	jle    f0100cc5 <debuginfo_eip+0x228>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100c91:	8a 0a                	mov    (%edx),%cl
f0100c93:	40                   	inc    %eax
f0100c94:	83 c2 0c             	add    $0xc,%edx
f0100c97:	80 f9 a0             	cmp    $0xa0,%cl
f0100c9a:	74 ee                	je     f0100c8a <debuginfo_eip+0x1ed>

	return 0;
f0100c9c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ca1:	eb 1a                	jmp    f0100cbd <debuginfo_eip+0x220>
		return -1;
f0100ca3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ca8:	eb 13                	jmp    f0100cbd <debuginfo_eip+0x220>
f0100caa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100caf:	eb 0c                	jmp    f0100cbd <debuginfo_eip+0x220>
		return -1;
f0100cb1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cb6:	eb 05                	jmp    f0100cbd <debuginfo_eip+0x220>
	return 0;
f0100cb8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100cbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cc0:	5b                   	pop    %ebx
f0100cc1:	5e                   	pop    %esi
f0100cc2:	5f                   	pop    %edi
f0100cc3:	5d                   	pop    %ebp
f0100cc4:	c3                   	ret    
	return 0;
f0100cc5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cca:	eb f1                	jmp    f0100cbd <debuginfo_eip+0x220>

f0100ccc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100ccc:	55                   	push   %ebp
f0100ccd:	89 e5                	mov    %esp,%ebp
f0100ccf:	57                   	push   %edi
f0100cd0:	56                   	push   %esi
f0100cd1:	53                   	push   %ebx
f0100cd2:	83 ec 1c             	sub    $0x1c,%esp
f0100cd5:	89 c7                	mov    %eax,%edi
f0100cd7:	89 d6                	mov    %edx,%esi
f0100cd9:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cdc:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100cdf:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100ce2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100ce5:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100ce8:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ced:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100cf0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100cf3:	39 d3                	cmp    %edx,%ebx
f0100cf5:	72 05                	jb     f0100cfc <printnum+0x30>
f0100cf7:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100cfa:	77 78                	ja     f0100d74 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100cfc:	83 ec 0c             	sub    $0xc,%esp
f0100cff:	ff 75 18             	pushl  0x18(%ebp)
f0100d02:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d05:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100d08:	53                   	push   %ebx
f0100d09:	ff 75 10             	pushl  0x10(%ebp)
f0100d0c:	83 ec 08             	sub    $0x8,%esp
f0100d0f:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d12:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d15:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d18:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d1b:	e8 8c 09 00 00       	call   f01016ac <__udivdi3>
f0100d20:	83 c4 18             	add    $0x18,%esp
f0100d23:	52                   	push   %edx
f0100d24:	50                   	push   %eax
f0100d25:	89 f2                	mov    %esi,%edx
f0100d27:	89 f8                	mov    %edi,%eax
f0100d29:	e8 9e ff ff ff       	call   f0100ccc <printnum>
f0100d2e:	83 c4 20             	add    $0x20,%esp
f0100d31:	eb 11                	jmp    f0100d44 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100d33:	83 ec 08             	sub    $0x8,%esp
f0100d36:	56                   	push   %esi
f0100d37:	ff 75 18             	pushl  0x18(%ebp)
f0100d3a:	ff d7                	call   *%edi
f0100d3c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100d3f:	4b                   	dec    %ebx
f0100d40:	85 db                	test   %ebx,%ebx
f0100d42:	7f ef                	jg     f0100d33 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100d44:	83 ec 08             	sub    $0x8,%esp
f0100d47:	56                   	push   %esi
f0100d48:	83 ec 04             	sub    $0x4,%esp
f0100d4b:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d4e:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d51:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d54:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d57:	e8 50 0a 00 00       	call   f01017ac <__umoddi3>
f0100d5c:	83 c4 14             	add    $0x14,%esp
f0100d5f:	0f be 80 e5 1e 10 f0 	movsbl -0xfefe11b(%eax),%eax
f0100d66:	50                   	push   %eax
f0100d67:	ff d7                	call   *%edi
}
f0100d69:	83 c4 10             	add    $0x10,%esp
f0100d6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d6f:	5b                   	pop    %ebx
f0100d70:	5e                   	pop    %esi
f0100d71:	5f                   	pop    %edi
f0100d72:	5d                   	pop    %ebp
f0100d73:	c3                   	ret    
f0100d74:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100d77:	eb c6                	jmp    f0100d3f <printnum+0x73>

f0100d79 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100d79:	55                   	push   %ebp
f0100d7a:	89 e5                	mov    %esp,%ebp
f0100d7c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100d7f:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0100d82:	8b 10                	mov    (%eax),%edx
f0100d84:	3b 50 04             	cmp    0x4(%eax),%edx
f0100d87:	73 0a                	jae    f0100d93 <sprintputch+0x1a>
		*b->buf++ = ch;
f0100d89:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100d8c:	89 08                	mov    %ecx,(%eax)
f0100d8e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d91:	88 02                	mov    %al,(%edx)
}
f0100d93:	5d                   	pop    %ebp
f0100d94:	c3                   	ret    

f0100d95 <printfmt>:
{
f0100d95:	55                   	push   %ebp
f0100d96:	89 e5                	mov    %esp,%ebp
f0100d98:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100d9b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100d9e:	50                   	push   %eax
f0100d9f:	ff 75 10             	pushl  0x10(%ebp)
f0100da2:	ff 75 0c             	pushl  0xc(%ebp)
f0100da5:	ff 75 08             	pushl  0x8(%ebp)
f0100da8:	e8 05 00 00 00       	call   f0100db2 <vprintfmt>
}
f0100dad:	83 c4 10             	add    $0x10,%esp
f0100db0:	c9                   	leave  
f0100db1:	c3                   	ret    

f0100db2 <vprintfmt>:
{
f0100db2:	55                   	push   %ebp
f0100db3:	89 e5                	mov    %esp,%ebp
f0100db5:	57                   	push   %edi
f0100db6:	56                   	push   %esi
f0100db7:	53                   	push   %ebx
f0100db8:	83 ec 2c             	sub    $0x2c,%esp
f0100dbb:	8b 75 08             	mov    0x8(%ebp),%esi
f0100dbe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100dc1:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100dc4:	e9 ac 03 00 00       	jmp    f0101175 <vprintfmt+0x3c3>
		padc = ' ';
f0100dc9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0100dcd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0100dd4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f0100ddb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0100de2:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0100de7:	8d 47 01             	lea    0x1(%edi),%eax
f0100dea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100ded:	8a 17                	mov    (%edi),%dl
f0100def:	8d 42 dd             	lea    -0x23(%edx),%eax
f0100df2:	3c 55                	cmp    $0x55,%al
f0100df4:	0f 87 fc 03 00 00    	ja     f01011f6 <vprintfmt+0x444>
f0100dfa:	0f b6 c0             	movzbl %al,%eax
f0100dfd:	ff 24 85 74 1f 10 f0 	jmp    *-0xfefe08c(,%eax,4)
f0100e04:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0100e07:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0100e0b:	eb da                	jmp    f0100de7 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0100e0d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0100e10:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100e14:	eb d1                	jmp    f0100de7 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0100e16:	0f b6 d2             	movzbl %dl,%edx
f0100e19:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0100e1c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e21:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0100e24:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100e27:	01 c0                	add    %eax,%eax
f0100e29:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
f0100e2d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0100e30:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0100e33:	83 f9 09             	cmp    $0x9,%ecx
f0100e36:	77 52                	ja     f0100e8a <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
f0100e38:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
f0100e39:	eb e9                	jmp    f0100e24 <vprintfmt+0x72>
			precision = va_arg(ap, int);
f0100e3b:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e3e:	8b 00                	mov    (%eax),%eax
f0100e40:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100e43:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e46:	8d 40 04             	lea    0x4(%eax),%eax
f0100e49:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100e4c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0100e4f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100e53:	79 92                	jns    f0100de7 <vprintfmt+0x35>
				width = precision, precision = -1;
f0100e55:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100e58:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100e5b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100e62:	eb 83                	jmp    f0100de7 <vprintfmt+0x35>
f0100e64:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100e68:	78 08                	js     f0100e72 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
f0100e6a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e6d:	e9 75 ff ff ff       	jmp    f0100de7 <vprintfmt+0x35>
f0100e72:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0100e79:	eb ef                	jmp    f0100e6a <vprintfmt+0xb8>
f0100e7b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0100e7e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100e85:	e9 5d ff ff ff       	jmp    f0100de7 <vprintfmt+0x35>
f0100e8a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100e8d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100e90:	eb bd                	jmp    f0100e4f <vprintfmt+0x9d>
			lflag++;
f0100e92:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
f0100e93:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0100e96:	e9 4c ff ff ff       	jmp    f0100de7 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f0100e9b:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e9e:	8d 78 04             	lea    0x4(%eax),%edi
f0100ea1:	83 ec 08             	sub    $0x8,%esp
f0100ea4:	53                   	push   %ebx
f0100ea5:	ff 30                	pushl  (%eax)
f0100ea7:	ff d6                	call   *%esi
			break;
f0100ea9:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0100eac:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0100eaf:	e9 be 02 00 00       	jmp    f0101172 <vprintfmt+0x3c0>
			err = va_arg(ap, int);
f0100eb4:	8b 45 14             	mov    0x14(%ebp),%eax
f0100eb7:	8d 78 04             	lea    0x4(%eax),%edi
f0100eba:	8b 00                	mov    (%eax),%eax
f0100ebc:	85 c0                	test   %eax,%eax
f0100ebe:	78 2a                	js     f0100eea <vprintfmt+0x138>
f0100ec0:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100ec2:	83 f8 06             	cmp    $0x6,%eax
f0100ec5:	7f 27                	jg     f0100eee <vprintfmt+0x13c>
f0100ec7:	8b 04 85 cc 20 10 f0 	mov    -0xfefdf34(,%eax,4),%eax
f0100ece:	85 c0                	test   %eax,%eax
f0100ed0:	74 1c                	je     f0100eee <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
f0100ed2:	50                   	push   %eax
f0100ed3:	68 06 1f 10 f0       	push   $0xf0101f06
f0100ed8:	53                   	push   %ebx
f0100ed9:	56                   	push   %esi
f0100eda:	e8 b6 fe ff ff       	call   f0100d95 <printfmt>
f0100edf:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100ee2:	89 7d 14             	mov    %edi,0x14(%ebp)
f0100ee5:	e9 88 02 00 00       	jmp    f0101172 <vprintfmt+0x3c0>
f0100eea:	f7 d8                	neg    %eax
f0100eec:	eb d2                	jmp    f0100ec0 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
f0100eee:	52                   	push   %edx
f0100eef:	68 fd 1e 10 f0       	push   $0xf0101efd
f0100ef4:	53                   	push   %ebx
f0100ef5:	56                   	push   %esi
f0100ef6:	e8 9a fe ff ff       	call   f0100d95 <printfmt>
f0100efb:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100efe:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0100f01:	e9 6c 02 00 00       	jmp    f0101172 <vprintfmt+0x3c0>
			if ((p = va_arg(ap, char *)) == NULL)
f0100f06:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f09:	83 c0 04             	add    $0x4,%eax
f0100f0c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100f0f:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f12:	8b 38                	mov    (%eax),%edi
f0100f14:	85 ff                	test   %edi,%edi
f0100f16:	74 18                	je     f0100f30 <vprintfmt+0x17e>
			if (width > 0 && padc != '-')
f0100f18:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100f1c:	0f 8e b7 00 00 00    	jle    f0100fd9 <vprintfmt+0x227>
f0100f22:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100f26:	75 0f                	jne    f0100f37 <vprintfmt+0x185>
f0100f28:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100f2b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100f2e:	eb 6e                	jmp    f0100f9e <vprintfmt+0x1ec>
				p = "(null)";
f0100f30:	bf f6 1e 10 f0       	mov    $0xf0101ef6,%edi
f0100f35:	eb e1                	jmp    f0100f18 <vprintfmt+0x166>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f37:	83 ec 08             	sub    $0x8,%esp
f0100f3a:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f3d:	57                   	push   %edi
f0100f3e:	e8 45 04 00 00       	call   f0101388 <strnlen>
f0100f43:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100f46:	29 c1                	sub    %eax,%ecx
f0100f48:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0100f4b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0100f4e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0100f52:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f55:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100f58:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f5a:	eb 0d                	jmp    f0100f69 <vprintfmt+0x1b7>
					putch(padc, putdat);
f0100f5c:	83 ec 08             	sub    $0x8,%esp
f0100f5f:	53                   	push   %ebx
f0100f60:	ff 75 e0             	pushl  -0x20(%ebp)
f0100f63:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f65:	4f                   	dec    %edi
f0100f66:	83 c4 10             	add    $0x10,%esp
f0100f69:	85 ff                	test   %edi,%edi
f0100f6b:	7f ef                	jg     f0100f5c <vprintfmt+0x1aa>
f0100f6d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100f70:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0100f73:	89 c8                	mov    %ecx,%eax
f0100f75:	85 c9                	test   %ecx,%ecx
f0100f77:	78 59                	js     f0100fd2 <vprintfmt+0x220>
f0100f79:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0100f7c:	29 c1                	sub    %eax,%ecx
f0100f7e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100f81:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100f84:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100f87:	eb 15                	jmp    f0100f9e <vprintfmt+0x1ec>
				if (altflag && (ch < ' ' || ch > '~'))
f0100f89:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100f8d:	75 29                	jne    f0100fb8 <vprintfmt+0x206>
					putch(ch, putdat);
f0100f8f:	83 ec 08             	sub    $0x8,%esp
f0100f92:	ff 75 0c             	pushl  0xc(%ebp)
f0100f95:	50                   	push   %eax
f0100f96:	ff d6                	call   *%esi
f0100f98:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100f9b:	ff 4d e0             	decl   -0x20(%ebp)
f0100f9e:	47                   	inc    %edi
f0100f9f:	8a 57 ff             	mov    -0x1(%edi),%dl
f0100fa2:	0f be c2             	movsbl %dl,%eax
f0100fa5:	85 c0                	test   %eax,%eax
f0100fa7:	74 53                	je     f0100ffc <vprintfmt+0x24a>
f0100fa9:	85 db                	test   %ebx,%ebx
f0100fab:	78 dc                	js     f0100f89 <vprintfmt+0x1d7>
f0100fad:	4b                   	dec    %ebx
f0100fae:	79 d9                	jns    f0100f89 <vprintfmt+0x1d7>
f0100fb0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100fb3:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100fb6:	eb 35                	jmp    f0100fed <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
f0100fb8:	0f be d2             	movsbl %dl,%edx
f0100fbb:	83 ea 20             	sub    $0x20,%edx
f0100fbe:	83 fa 5e             	cmp    $0x5e,%edx
f0100fc1:	76 cc                	jbe    f0100f8f <vprintfmt+0x1dd>
					putch('?', putdat);
f0100fc3:	83 ec 08             	sub    $0x8,%esp
f0100fc6:	ff 75 0c             	pushl  0xc(%ebp)
f0100fc9:	6a 3f                	push   $0x3f
f0100fcb:	ff d6                	call   *%esi
f0100fcd:	83 c4 10             	add    $0x10,%esp
f0100fd0:	eb c9                	jmp    f0100f9b <vprintfmt+0x1e9>
f0100fd2:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fd7:	eb a0                	jmp    f0100f79 <vprintfmt+0x1c7>
f0100fd9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100fdc:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100fdf:	eb bd                	jmp    f0100f9e <vprintfmt+0x1ec>
				putch(' ', putdat);
f0100fe1:	83 ec 08             	sub    $0x8,%esp
f0100fe4:	53                   	push   %ebx
f0100fe5:	6a 20                	push   $0x20
f0100fe7:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0100fe9:	4f                   	dec    %edi
f0100fea:	83 c4 10             	add    $0x10,%esp
f0100fed:	85 ff                	test   %edi,%edi
f0100fef:	7f f0                	jg     f0100fe1 <vprintfmt+0x22f>
			if ((p = va_arg(ap, char *)) == NULL)
f0100ff1:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0100ff4:	89 45 14             	mov    %eax,0x14(%ebp)
f0100ff7:	e9 76 01 00 00       	jmp    f0101172 <vprintfmt+0x3c0>
f0100ffc:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100fff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101002:	eb e9                	jmp    f0100fed <vprintfmt+0x23b>
	if (lflag >= 2)
f0101004:	83 f9 01             	cmp    $0x1,%ecx
f0101007:	7e 3f                	jle    f0101048 <vprintfmt+0x296>
		return va_arg(*ap, long long);
f0101009:	8b 45 14             	mov    0x14(%ebp),%eax
f010100c:	8b 50 04             	mov    0x4(%eax),%edx
f010100f:	8b 00                	mov    (%eax),%eax
f0101011:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101014:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101017:	8b 45 14             	mov    0x14(%ebp),%eax
f010101a:	8d 40 08             	lea    0x8(%eax),%eax
f010101d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0101020:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101024:	79 5c                	jns    f0101082 <vprintfmt+0x2d0>
				putch('-', putdat);
f0101026:	83 ec 08             	sub    $0x8,%esp
f0101029:	53                   	push   %ebx
f010102a:	6a 2d                	push   $0x2d
f010102c:	ff d6                	call   *%esi
				num = -(long long) num;
f010102e:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101031:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101034:	f7 da                	neg    %edx
f0101036:	83 d1 00             	adc    $0x0,%ecx
f0101039:	f7 d9                	neg    %ecx
f010103b:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010103e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101043:	e9 10 01 00 00       	jmp    f0101158 <vprintfmt+0x3a6>
	else if (lflag)
f0101048:	85 c9                	test   %ecx,%ecx
f010104a:	75 1b                	jne    f0101067 <vprintfmt+0x2b5>
		return va_arg(*ap, int);
f010104c:	8b 45 14             	mov    0x14(%ebp),%eax
f010104f:	8b 00                	mov    (%eax),%eax
f0101051:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101054:	89 c1                	mov    %eax,%ecx
f0101056:	c1 f9 1f             	sar    $0x1f,%ecx
f0101059:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010105c:	8b 45 14             	mov    0x14(%ebp),%eax
f010105f:	8d 40 04             	lea    0x4(%eax),%eax
f0101062:	89 45 14             	mov    %eax,0x14(%ebp)
f0101065:	eb b9                	jmp    f0101020 <vprintfmt+0x26e>
		return va_arg(*ap, long);
f0101067:	8b 45 14             	mov    0x14(%ebp),%eax
f010106a:	8b 00                	mov    (%eax),%eax
f010106c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010106f:	89 c1                	mov    %eax,%ecx
f0101071:	c1 f9 1f             	sar    $0x1f,%ecx
f0101074:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101077:	8b 45 14             	mov    0x14(%ebp),%eax
f010107a:	8d 40 04             	lea    0x4(%eax),%eax
f010107d:	89 45 14             	mov    %eax,0x14(%ebp)
f0101080:	eb 9e                	jmp    f0101020 <vprintfmt+0x26e>
			num = getint(&ap, lflag);
f0101082:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101085:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0101088:	b8 0a 00 00 00       	mov    $0xa,%eax
f010108d:	e9 c6 00 00 00       	jmp    f0101158 <vprintfmt+0x3a6>
	if (lflag >= 2)
f0101092:	83 f9 01             	cmp    $0x1,%ecx
f0101095:	7e 18                	jle    f01010af <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
f0101097:	8b 45 14             	mov    0x14(%ebp),%eax
f010109a:	8b 10                	mov    (%eax),%edx
f010109c:	8b 48 04             	mov    0x4(%eax),%ecx
f010109f:	8d 40 08             	lea    0x8(%eax),%eax
f01010a2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01010a5:	b8 0a 00 00 00       	mov    $0xa,%eax
f01010aa:	e9 a9 00 00 00       	jmp    f0101158 <vprintfmt+0x3a6>
	else if (lflag)
f01010af:	85 c9                	test   %ecx,%ecx
f01010b1:	75 1a                	jne    f01010cd <vprintfmt+0x31b>
		return va_arg(*ap, unsigned int);
f01010b3:	8b 45 14             	mov    0x14(%ebp),%eax
f01010b6:	8b 10                	mov    (%eax),%edx
f01010b8:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010bd:	8d 40 04             	lea    0x4(%eax),%eax
f01010c0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01010c3:	b8 0a 00 00 00       	mov    $0xa,%eax
f01010c8:	e9 8b 00 00 00       	jmp    f0101158 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f01010cd:	8b 45 14             	mov    0x14(%ebp),%eax
f01010d0:	8b 10                	mov    (%eax),%edx
f01010d2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010d7:	8d 40 04             	lea    0x4(%eax),%eax
f01010da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01010dd:	b8 0a 00 00 00       	mov    $0xa,%eax
f01010e2:	eb 74                	jmp    f0101158 <vprintfmt+0x3a6>
	if (lflag >= 2)
f01010e4:	83 f9 01             	cmp    $0x1,%ecx
f01010e7:	7e 15                	jle    f01010fe <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
f01010e9:	8b 45 14             	mov    0x14(%ebp),%eax
f01010ec:	8b 10                	mov    (%eax),%edx
f01010ee:	8b 48 04             	mov    0x4(%eax),%ecx
f01010f1:	8d 40 08             	lea    0x8(%eax),%eax
f01010f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01010f7:	b8 08 00 00 00       	mov    $0x8,%eax
f01010fc:	eb 5a                	jmp    f0101158 <vprintfmt+0x3a6>
	else if (lflag)
f01010fe:	85 c9                	test   %ecx,%ecx
f0101100:	75 17                	jne    f0101119 <vprintfmt+0x367>
		return va_arg(*ap, unsigned int);
f0101102:	8b 45 14             	mov    0x14(%ebp),%eax
f0101105:	8b 10                	mov    (%eax),%edx
f0101107:	b9 00 00 00 00       	mov    $0x0,%ecx
f010110c:	8d 40 04             	lea    0x4(%eax),%eax
f010110f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101112:	b8 08 00 00 00       	mov    $0x8,%eax
f0101117:	eb 3f                	jmp    f0101158 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0101119:	8b 45 14             	mov    0x14(%ebp),%eax
f010111c:	8b 10                	mov    (%eax),%edx
f010111e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101123:	8d 40 04             	lea    0x4(%eax),%eax
f0101126:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101129:	b8 08 00 00 00       	mov    $0x8,%eax
f010112e:	eb 28                	jmp    f0101158 <vprintfmt+0x3a6>
			putch('0', putdat);
f0101130:	83 ec 08             	sub    $0x8,%esp
f0101133:	53                   	push   %ebx
f0101134:	6a 30                	push   $0x30
f0101136:	ff d6                	call   *%esi
			putch('x', putdat);
f0101138:	83 c4 08             	add    $0x8,%esp
f010113b:	53                   	push   %ebx
f010113c:	6a 78                	push   $0x78
f010113e:	ff d6                	call   *%esi
			num = (unsigned long long)
f0101140:	8b 45 14             	mov    0x14(%ebp),%eax
f0101143:	8b 10                	mov    (%eax),%edx
f0101145:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010114a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010114d:	8d 40 04             	lea    0x4(%eax),%eax
f0101150:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101153:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0101158:	83 ec 0c             	sub    $0xc,%esp
f010115b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f010115f:	57                   	push   %edi
f0101160:	ff 75 e0             	pushl  -0x20(%ebp)
f0101163:	50                   	push   %eax
f0101164:	51                   	push   %ecx
f0101165:	52                   	push   %edx
f0101166:	89 da                	mov    %ebx,%edx
f0101168:	89 f0                	mov    %esi,%eax
f010116a:	e8 5d fb ff ff       	call   f0100ccc <printnum>
			break;
f010116f:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0101172:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101175:	47                   	inc    %edi
f0101176:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010117a:	83 f8 25             	cmp    $0x25,%eax
f010117d:	0f 84 46 fc ff ff    	je     f0100dc9 <vprintfmt+0x17>
			if (ch == '\0')
f0101183:	85 c0                	test   %eax,%eax
f0101185:	0f 84 89 00 00 00    	je     f0101214 <vprintfmt+0x462>
			putch(ch, putdat);
f010118b:	83 ec 08             	sub    $0x8,%esp
f010118e:	53                   	push   %ebx
f010118f:	50                   	push   %eax
f0101190:	ff d6                	call   *%esi
f0101192:	83 c4 10             	add    $0x10,%esp
f0101195:	eb de                	jmp    f0101175 <vprintfmt+0x3c3>
	if (lflag >= 2)
f0101197:	83 f9 01             	cmp    $0x1,%ecx
f010119a:	7e 15                	jle    f01011b1 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
f010119c:	8b 45 14             	mov    0x14(%ebp),%eax
f010119f:	8b 10                	mov    (%eax),%edx
f01011a1:	8b 48 04             	mov    0x4(%eax),%ecx
f01011a4:	8d 40 08             	lea    0x8(%eax),%eax
f01011a7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01011aa:	b8 10 00 00 00       	mov    $0x10,%eax
f01011af:	eb a7                	jmp    f0101158 <vprintfmt+0x3a6>
	else if (lflag)
f01011b1:	85 c9                	test   %ecx,%ecx
f01011b3:	75 17                	jne    f01011cc <vprintfmt+0x41a>
		return va_arg(*ap, unsigned int);
f01011b5:	8b 45 14             	mov    0x14(%ebp),%eax
f01011b8:	8b 10                	mov    (%eax),%edx
f01011ba:	b9 00 00 00 00       	mov    $0x0,%ecx
f01011bf:	8d 40 04             	lea    0x4(%eax),%eax
f01011c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01011c5:	b8 10 00 00 00       	mov    $0x10,%eax
f01011ca:	eb 8c                	jmp    f0101158 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f01011cc:	8b 45 14             	mov    0x14(%ebp),%eax
f01011cf:	8b 10                	mov    (%eax),%edx
f01011d1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01011d6:	8d 40 04             	lea    0x4(%eax),%eax
f01011d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01011dc:	b8 10 00 00 00       	mov    $0x10,%eax
f01011e1:	e9 72 ff ff ff       	jmp    f0101158 <vprintfmt+0x3a6>
			putch(ch, putdat);
f01011e6:	83 ec 08             	sub    $0x8,%esp
f01011e9:	53                   	push   %ebx
f01011ea:	6a 25                	push   $0x25
f01011ec:	ff d6                	call   *%esi
			break;
f01011ee:	83 c4 10             	add    $0x10,%esp
f01011f1:	e9 7c ff ff ff       	jmp    f0101172 <vprintfmt+0x3c0>
			putch('%', putdat);
f01011f6:	83 ec 08             	sub    $0x8,%esp
f01011f9:	53                   	push   %ebx
f01011fa:	6a 25                	push   $0x25
f01011fc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01011fe:	83 c4 10             	add    $0x10,%esp
f0101201:	89 f8                	mov    %edi,%eax
f0101203:	eb 01                	jmp    f0101206 <vprintfmt+0x454>
f0101205:	48                   	dec    %eax
f0101206:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010120a:	75 f9                	jne    f0101205 <vprintfmt+0x453>
f010120c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010120f:	e9 5e ff ff ff       	jmp    f0101172 <vprintfmt+0x3c0>
}
f0101214:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101217:	5b                   	pop    %ebx
f0101218:	5e                   	pop    %esi
f0101219:	5f                   	pop    %edi
f010121a:	5d                   	pop    %ebp
f010121b:	c3                   	ret    

f010121c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010121c:	55                   	push   %ebp
f010121d:	89 e5                	mov    %esp,%ebp
f010121f:	83 ec 18             	sub    $0x18,%esp
f0101222:	8b 45 08             	mov    0x8(%ebp),%eax
f0101225:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101228:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010122b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010122f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101232:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101239:	85 c0                	test   %eax,%eax
f010123b:	74 26                	je     f0101263 <vsnprintf+0x47>
f010123d:	85 d2                	test   %edx,%edx
f010123f:	7e 29                	jle    f010126a <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101241:	ff 75 14             	pushl  0x14(%ebp)
f0101244:	ff 75 10             	pushl  0x10(%ebp)
f0101247:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010124a:	50                   	push   %eax
f010124b:	68 79 0d 10 f0       	push   $0xf0100d79
f0101250:	e8 5d fb ff ff       	call   f0100db2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101255:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101258:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010125b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010125e:	83 c4 10             	add    $0x10,%esp
}
f0101261:	c9                   	leave  
f0101262:	c3                   	ret    
		return -E_INVAL;
f0101263:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101268:	eb f7                	jmp    f0101261 <vsnprintf+0x45>
f010126a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010126f:	eb f0                	jmp    f0101261 <vsnprintf+0x45>

f0101271 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101271:	55                   	push   %ebp
f0101272:	89 e5                	mov    %esp,%ebp
f0101274:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101277:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010127a:	50                   	push   %eax
f010127b:	ff 75 10             	pushl  0x10(%ebp)
f010127e:	ff 75 0c             	pushl  0xc(%ebp)
f0101281:	ff 75 08             	pushl  0x8(%ebp)
f0101284:	e8 93 ff ff ff       	call   f010121c <vsnprintf>
	va_end(ap);

	return rc;
}
f0101289:	c9                   	leave  
f010128a:	c3                   	ret    

f010128b <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010128b:	55                   	push   %ebp
f010128c:	89 e5                	mov    %esp,%ebp
f010128e:	57                   	push   %edi
f010128f:	56                   	push   %esi
f0101290:	53                   	push   %ebx
f0101291:	83 ec 0c             	sub    $0xc,%esp
f0101294:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101297:	85 c0                	test   %eax,%eax
f0101299:	74 11                	je     f01012ac <readline+0x21>
		cprintf("%s", prompt);
f010129b:	83 ec 08             	sub    $0x8,%esp
f010129e:	50                   	push   %eax
f010129f:	68 06 1f 10 f0       	push   $0xf0101f06
f01012a4:	e8 f3 f6 ff ff       	call   f010099c <cprintf>
f01012a9:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01012ac:	83 ec 0c             	sub    $0xc,%esp
f01012af:	6a 00                	push   $0x0
f01012b1:	e8 ec f3 ff ff       	call   f01006a2 <iscons>
f01012b6:	89 c7                	mov    %eax,%edi
f01012b8:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01012bb:	be 00 00 00 00       	mov    $0x0,%esi
f01012c0:	eb 6f                	jmp    f0101331 <readline+0xa6>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01012c2:	83 ec 08             	sub    $0x8,%esp
f01012c5:	50                   	push   %eax
f01012c6:	68 e8 20 10 f0       	push   $0xf01020e8
f01012cb:	e8 cc f6 ff ff       	call   f010099c <cprintf>
			return NULL;
f01012d0:	83 c4 10             	add    $0x10,%esp
f01012d3:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01012d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012db:	5b                   	pop    %ebx
f01012dc:	5e                   	pop    %esi
f01012dd:	5f                   	pop    %edi
f01012de:	5d                   	pop    %ebp
f01012df:	c3                   	ret    
				cputchar('\b');
f01012e0:	83 ec 0c             	sub    $0xc,%esp
f01012e3:	6a 08                	push   $0x8
f01012e5:	e8 97 f3 ff ff       	call   f0100681 <cputchar>
f01012ea:	83 c4 10             	add    $0x10,%esp
f01012ed:	eb 41                	jmp    f0101330 <readline+0xa5>
				cputchar(c);
f01012ef:	83 ec 0c             	sub    $0xc,%esp
f01012f2:	53                   	push   %ebx
f01012f3:	e8 89 f3 ff ff       	call   f0100681 <cputchar>
f01012f8:	83 c4 10             	add    $0x10,%esp
f01012fb:	eb 5a                	jmp    f0101357 <readline+0xcc>
		} else if (c == '\n' || c == '\r') {
f01012fd:	83 fb 0a             	cmp    $0xa,%ebx
f0101300:	74 05                	je     f0101307 <readline+0x7c>
f0101302:	83 fb 0d             	cmp    $0xd,%ebx
f0101305:	75 2a                	jne    f0101331 <readline+0xa6>
			if (echoing)
f0101307:	85 ff                	test   %edi,%edi
f0101309:	75 0e                	jne    f0101319 <readline+0x8e>
			buf[i] = 0;
f010130b:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f0101312:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
f0101317:	eb bf                	jmp    f01012d8 <readline+0x4d>
				cputchar('\n');
f0101319:	83 ec 0c             	sub    $0xc,%esp
f010131c:	6a 0a                	push   $0xa
f010131e:	e8 5e f3 ff ff       	call   f0100681 <cputchar>
f0101323:	83 c4 10             	add    $0x10,%esp
f0101326:	eb e3                	jmp    f010130b <readline+0x80>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101328:	85 f6                	test   %esi,%esi
f010132a:	7e 3c                	jle    f0101368 <readline+0xdd>
			if (echoing)
f010132c:	85 ff                	test   %edi,%edi
f010132e:	75 b0                	jne    f01012e0 <readline+0x55>
			i--;
f0101330:	4e                   	dec    %esi
		c = getchar();
f0101331:	e8 5b f3 ff ff       	call   f0100691 <getchar>
f0101336:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0101338:	85 c0                	test   %eax,%eax
f010133a:	78 86                	js     f01012c2 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010133c:	83 f8 08             	cmp    $0x8,%eax
f010133f:	74 21                	je     f0101362 <readline+0xd7>
f0101341:	83 f8 7f             	cmp    $0x7f,%eax
f0101344:	74 e2                	je     f0101328 <readline+0x9d>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101346:	83 f8 1f             	cmp    $0x1f,%eax
f0101349:	7e b2                	jle    f01012fd <readline+0x72>
f010134b:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101351:	7f aa                	jg     f01012fd <readline+0x72>
			if (echoing)
f0101353:	85 ff                	test   %edi,%edi
f0101355:	75 98                	jne    f01012ef <readline+0x64>
			buf[i++] = c;
f0101357:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f010135d:	8d 76 01             	lea    0x1(%esi),%esi
f0101360:	eb cf                	jmp    f0101331 <readline+0xa6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101362:	85 f6                	test   %esi,%esi
f0101364:	7e cb                	jle    f0101331 <readline+0xa6>
f0101366:	eb c4                	jmp    f010132c <readline+0xa1>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101368:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010136e:	7e e3                	jle    f0101353 <readline+0xc8>
f0101370:	eb bf                	jmp    f0101331 <readline+0xa6>

f0101372 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101372:	55                   	push   %ebp
f0101373:	89 e5                	mov    %esp,%ebp
f0101375:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101378:	b8 00 00 00 00       	mov    $0x0,%eax
f010137d:	eb 01                	jmp    f0101380 <strlen+0xe>
		n++;
f010137f:	40                   	inc    %eax
	for (n = 0; *s != '\0'; s++)
f0101380:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101384:	75 f9                	jne    f010137f <strlen+0xd>
	return n;
}
f0101386:	5d                   	pop    %ebp
f0101387:	c3                   	ret    

f0101388 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101388:	55                   	push   %ebp
f0101389:	89 e5                	mov    %esp,%ebp
f010138b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010138e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101391:	b8 00 00 00 00       	mov    $0x0,%eax
f0101396:	eb 01                	jmp    f0101399 <strnlen+0x11>
		n++;
f0101398:	40                   	inc    %eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101399:	39 d0                	cmp    %edx,%eax
f010139b:	74 06                	je     f01013a3 <strnlen+0x1b>
f010139d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01013a1:	75 f5                	jne    f0101398 <strnlen+0x10>
	return n;
}
f01013a3:	5d                   	pop    %ebp
f01013a4:	c3                   	ret    

f01013a5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01013a5:	55                   	push   %ebp
f01013a6:	89 e5                	mov    %esp,%ebp
f01013a8:	53                   	push   %ebx
f01013a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01013ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01013af:	89 c2                	mov    %eax,%edx
f01013b1:	41                   	inc    %ecx
f01013b2:	42                   	inc    %edx
f01013b3:	8a 59 ff             	mov    -0x1(%ecx),%bl
f01013b6:	88 5a ff             	mov    %bl,-0x1(%edx)
f01013b9:	84 db                	test   %bl,%bl
f01013bb:	75 f4                	jne    f01013b1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01013bd:	5b                   	pop    %ebx
f01013be:	5d                   	pop    %ebp
f01013bf:	c3                   	ret    

f01013c0 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01013c0:	55                   	push   %ebp
f01013c1:	89 e5                	mov    %esp,%ebp
f01013c3:	53                   	push   %ebx
f01013c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01013c7:	53                   	push   %ebx
f01013c8:	e8 a5 ff ff ff       	call   f0101372 <strlen>
f01013cd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01013d0:	ff 75 0c             	pushl  0xc(%ebp)
f01013d3:	01 d8                	add    %ebx,%eax
f01013d5:	50                   	push   %eax
f01013d6:	e8 ca ff ff ff       	call   f01013a5 <strcpy>
	return dst;
}
f01013db:	89 d8                	mov    %ebx,%eax
f01013dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01013e0:	c9                   	leave  
f01013e1:	c3                   	ret    

f01013e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01013e2:	55                   	push   %ebp
f01013e3:	89 e5                	mov    %esp,%ebp
f01013e5:	56                   	push   %esi
f01013e6:	53                   	push   %ebx
f01013e7:	8b 75 08             	mov    0x8(%ebp),%esi
f01013ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01013ed:	89 f3                	mov    %esi,%ebx
f01013ef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01013f2:	89 f2                	mov    %esi,%edx
f01013f4:	39 da                	cmp    %ebx,%edx
f01013f6:	74 0e                	je     f0101406 <strncpy+0x24>
		*dst++ = *src;
f01013f8:	42                   	inc    %edx
f01013f9:	8a 01                	mov    (%ecx),%al
f01013fb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f01013fe:	80 39 00             	cmpb   $0x0,(%ecx)
f0101401:	74 f1                	je     f01013f4 <strncpy+0x12>
			src++;
f0101403:	41                   	inc    %ecx
f0101404:	eb ee                	jmp    f01013f4 <strncpy+0x12>
	}
	return ret;
}
f0101406:	89 f0                	mov    %esi,%eax
f0101408:	5b                   	pop    %ebx
f0101409:	5e                   	pop    %esi
f010140a:	5d                   	pop    %ebp
f010140b:	c3                   	ret    

f010140c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010140c:	55                   	push   %ebp
f010140d:	89 e5                	mov    %esp,%ebp
f010140f:	56                   	push   %esi
f0101410:	53                   	push   %ebx
f0101411:	8b 75 08             	mov    0x8(%ebp),%esi
f0101414:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101417:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010141a:	85 c0                	test   %eax,%eax
f010141c:	74 20                	je     f010143e <strlcpy+0x32>
f010141e:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
f0101422:	89 f0                	mov    %esi,%eax
f0101424:	eb 05                	jmp    f010142b <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101426:	42                   	inc    %edx
f0101427:	40                   	inc    %eax
f0101428:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f010142b:	39 d8                	cmp    %ebx,%eax
f010142d:	74 06                	je     f0101435 <strlcpy+0x29>
f010142f:	8a 0a                	mov    (%edx),%cl
f0101431:	84 c9                	test   %cl,%cl
f0101433:	75 f1                	jne    f0101426 <strlcpy+0x1a>
		*dst = '\0';
f0101435:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101438:	29 f0                	sub    %esi,%eax
}
f010143a:	5b                   	pop    %ebx
f010143b:	5e                   	pop    %esi
f010143c:	5d                   	pop    %ebp
f010143d:	c3                   	ret    
f010143e:	89 f0                	mov    %esi,%eax
f0101440:	eb f6                	jmp    f0101438 <strlcpy+0x2c>

f0101442 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101442:	55                   	push   %ebp
f0101443:	89 e5                	mov    %esp,%ebp
f0101445:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101448:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010144b:	eb 02                	jmp    f010144f <strcmp+0xd>
		p++, q++;
f010144d:	41                   	inc    %ecx
f010144e:	42                   	inc    %edx
	while (*p && *p == *q)
f010144f:	8a 01                	mov    (%ecx),%al
f0101451:	84 c0                	test   %al,%al
f0101453:	74 04                	je     f0101459 <strcmp+0x17>
f0101455:	3a 02                	cmp    (%edx),%al
f0101457:	74 f4                	je     f010144d <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101459:	0f b6 c0             	movzbl %al,%eax
f010145c:	0f b6 12             	movzbl (%edx),%edx
f010145f:	29 d0                	sub    %edx,%eax
}
f0101461:	5d                   	pop    %ebp
f0101462:	c3                   	ret    

f0101463 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101463:	55                   	push   %ebp
f0101464:	89 e5                	mov    %esp,%ebp
f0101466:	53                   	push   %ebx
f0101467:	8b 45 08             	mov    0x8(%ebp),%eax
f010146a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010146d:	89 c3                	mov    %eax,%ebx
f010146f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101472:	eb 02                	jmp    f0101476 <strncmp+0x13>
		n--, p++, q++;
f0101474:	40                   	inc    %eax
f0101475:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
f0101476:	39 d8                	cmp    %ebx,%eax
f0101478:	74 15                	je     f010148f <strncmp+0x2c>
f010147a:	8a 08                	mov    (%eax),%cl
f010147c:	84 c9                	test   %cl,%cl
f010147e:	74 04                	je     f0101484 <strncmp+0x21>
f0101480:	3a 0a                	cmp    (%edx),%cl
f0101482:	74 f0                	je     f0101474 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101484:	0f b6 00             	movzbl (%eax),%eax
f0101487:	0f b6 12             	movzbl (%edx),%edx
f010148a:	29 d0                	sub    %edx,%eax
}
f010148c:	5b                   	pop    %ebx
f010148d:	5d                   	pop    %ebp
f010148e:	c3                   	ret    
		return 0;
f010148f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101494:	eb f6                	jmp    f010148c <strncmp+0x29>

f0101496 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101496:	55                   	push   %ebp
f0101497:	89 e5                	mov    %esp,%ebp
f0101499:	8b 45 08             	mov    0x8(%ebp),%eax
f010149c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010149f:	8a 10                	mov    (%eax),%dl
f01014a1:	84 d2                	test   %dl,%dl
f01014a3:	74 07                	je     f01014ac <strchr+0x16>
		if (*s == c)
f01014a5:	38 ca                	cmp    %cl,%dl
f01014a7:	74 08                	je     f01014b1 <strchr+0x1b>
	for (; *s; s++)
f01014a9:	40                   	inc    %eax
f01014aa:	eb f3                	jmp    f010149f <strchr+0x9>
			return (char *) s;
	return 0;
f01014ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01014b1:	5d                   	pop    %ebp
f01014b2:	c3                   	ret    

f01014b3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01014b3:	55                   	push   %ebp
f01014b4:	89 e5                	mov    %esp,%ebp
f01014b6:	8b 45 08             	mov    0x8(%ebp),%eax
f01014b9:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01014bc:	8a 10                	mov    (%eax),%dl
f01014be:	84 d2                	test   %dl,%dl
f01014c0:	74 07                	je     f01014c9 <strfind+0x16>
		if (*s == c)
f01014c2:	38 ca                	cmp    %cl,%dl
f01014c4:	74 03                	je     f01014c9 <strfind+0x16>
	for (; *s; s++)
f01014c6:	40                   	inc    %eax
f01014c7:	eb f3                	jmp    f01014bc <strfind+0x9>
			break;
	return (char *) s;
}
f01014c9:	5d                   	pop    %ebp
f01014ca:	c3                   	ret    

f01014cb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01014cb:	55                   	push   %ebp
f01014cc:	89 e5                	mov    %esp,%ebp
f01014ce:	57                   	push   %edi
f01014cf:	56                   	push   %esi
f01014d0:	53                   	push   %ebx
f01014d1:	8b 7d 08             	mov    0x8(%ebp),%edi
f01014d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01014d7:	85 c9                	test   %ecx,%ecx
f01014d9:	74 13                	je     f01014ee <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01014db:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01014e1:	75 05                	jne    f01014e8 <memset+0x1d>
f01014e3:	f6 c1 03             	test   $0x3,%cl
f01014e6:	74 0d                	je     f01014f5 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01014e8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014eb:	fc                   	cld    
f01014ec:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01014ee:	89 f8                	mov    %edi,%eax
f01014f0:	5b                   	pop    %ebx
f01014f1:	5e                   	pop    %esi
f01014f2:	5f                   	pop    %edi
f01014f3:	5d                   	pop    %ebp
f01014f4:	c3                   	ret    
		c &= 0xFF;
f01014f5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01014f9:	89 d3                	mov    %edx,%ebx
f01014fb:	c1 e3 08             	shl    $0x8,%ebx
f01014fe:	89 d0                	mov    %edx,%eax
f0101500:	c1 e0 18             	shl    $0x18,%eax
f0101503:	89 d6                	mov    %edx,%esi
f0101505:	c1 e6 10             	shl    $0x10,%esi
f0101508:	09 f0                	or     %esi,%eax
f010150a:	09 c2                	or     %eax,%edx
f010150c:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f010150e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0101511:	89 d0                	mov    %edx,%eax
f0101513:	fc                   	cld    
f0101514:	f3 ab                	rep stos %eax,%es:(%edi)
f0101516:	eb d6                	jmp    f01014ee <memset+0x23>

f0101518 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101518:	55                   	push   %ebp
f0101519:	89 e5                	mov    %esp,%ebp
f010151b:	57                   	push   %edi
f010151c:	56                   	push   %esi
f010151d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101520:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101523:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101526:	39 c6                	cmp    %eax,%esi
f0101528:	73 33                	jae    f010155d <memmove+0x45>
f010152a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010152d:	39 c2                	cmp    %eax,%edx
f010152f:	76 2c                	jbe    f010155d <memmove+0x45>
		s += n;
		d += n;
f0101531:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101534:	89 d6                	mov    %edx,%esi
f0101536:	09 fe                	or     %edi,%esi
f0101538:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010153e:	74 0a                	je     f010154a <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101540:	4f                   	dec    %edi
f0101541:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0101544:	fd                   	std    
f0101545:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101547:	fc                   	cld    
f0101548:	eb 21                	jmp    f010156b <memmove+0x53>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010154a:	f6 c1 03             	test   $0x3,%cl
f010154d:	75 f1                	jne    f0101540 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010154f:	83 ef 04             	sub    $0x4,%edi
f0101552:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101555:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0101558:	fd                   	std    
f0101559:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010155b:	eb ea                	jmp    f0101547 <memmove+0x2f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010155d:	89 f2                	mov    %esi,%edx
f010155f:	09 c2                	or     %eax,%edx
f0101561:	f6 c2 03             	test   $0x3,%dl
f0101564:	74 09                	je     f010156f <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101566:	89 c7                	mov    %eax,%edi
f0101568:	fc                   	cld    
f0101569:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010156b:	5e                   	pop    %esi
f010156c:	5f                   	pop    %edi
f010156d:	5d                   	pop    %ebp
f010156e:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010156f:	f6 c1 03             	test   $0x3,%cl
f0101572:	75 f2                	jne    f0101566 <memmove+0x4e>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101574:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0101577:	89 c7                	mov    %eax,%edi
f0101579:	fc                   	cld    
f010157a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010157c:	eb ed                	jmp    f010156b <memmove+0x53>

f010157e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010157e:	55                   	push   %ebp
f010157f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0101581:	ff 75 10             	pushl  0x10(%ebp)
f0101584:	ff 75 0c             	pushl  0xc(%ebp)
f0101587:	ff 75 08             	pushl  0x8(%ebp)
f010158a:	e8 89 ff ff ff       	call   f0101518 <memmove>
}
f010158f:	c9                   	leave  
f0101590:	c3                   	ret    

f0101591 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101591:	55                   	push   %ebp
f0101592:	89 e5                	mov    %esp,%ebp
f0101594:	56                   	push   %esi
f0101595:	53                   	push   %ebx
f0101596:	8b 45 08             	mov    0x8(%ebp),%eax
f0101599:	8b 55 0c             	mov    0xc(%ebp),%edx
f010159c:	89 c6                	mov    %eax,%esi
f010159e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01015a1:	39 f0                	cmp    %esi,%eax
f01015a3:	74 16                	je     f01015bb <memcmp+0x2a>
		if (*s1 != *s2)
f01015a5:	8a 08                	mov    (%eax),%cl
f01015a7:	8a 1a                	mov    (%edx),%bl
f01015a9:	38 d9                	cmp    %bl,%cl
f01015ab:	75 04                	jne    f01015b1 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01015ad:	40                   	inc    %eax
f01015ae:	42                   	inc    %edx
f01015af:	eb f0                	jmp    f01015a1 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f01015b1:	0f b6 c1             	movzbl %cl,%eax
f01015b4:	0f b6 db             	movzbl %bl,%ebx
f01015b7:	29 d8                	sub    %ebx,%eax
f01015b9:	eb 05                	jmp    f01015c0 <memcmp+0x2f>
	}

	return 0;
f01015bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01015c0:	5b                   	pop    %ebx
f01015c1:	5e                   	pop    %esi
f01015c2:	5d                   	pop    %ebp
f01015c3:	c3                   	ret    

f01015c4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01015c4:	55                   	push   %ebp
f01015c5:	89 e5                	mov    %esp,%ebp
f01015c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01015ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01015cd:	89 c2                	mov    %eax,%edx
f01015cf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01015d2:	39 d0                	cmp    %edx,%eax
f01015d4:	73 07                	jae    f01015dd <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
f01015d6:	38 08                	cmp    %cl,(%eax)
f01015d8:	74 03                	je     f01015dd <memfind+0x19>
	for (; s < ends; s++)
f01015da:	40                   	inc    %eax
f01015db:	eb f5                	jmp    f01015d2 <memfind+0xe>
			break;
	return (void *) s;
}
f01015dd:	5d                   	pop    %ebp
f01015de:	c3                   	ret    

f01015df <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01015df:	55                   	push   %ebp
f01015e0:	89 e5                	mov    %esp,%ebp
f01015e2:	57                   	push   %edi
f01015e3:	56                   	push   %esi
f01015e4:	53                   	push   %ebx
f01015e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01015e8:	eb 01                	jmp    f01015eb <strtol+0xc>
		s++;
f01015ea:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f01015eb:	8a 01                	mov    (%ecx),%al
f01015ed:	3c 20                	cmp    $0x20,%al
f01015ef:	74 f9                	je     f01015ea <strtol+0xb>
f01015f1:	3c 09                	cmp    $0x9,%al
f01015f3:	74 f5                	je     f01015ea <strtol+0xb>

	// plus/minus sign
	if (*s == '+')
f01015f5:	3c 2b                	cmp    $0x2b,%al
f01015f7:	74 2b                	je     f0101624 <strtol+0x45>
		s++;
	else if (*s == '-')
f01015f9:	3c 2d                	cmp    $0x2d,%al
f01015fb:	74 2f                	je     f010162c <strtol+0x4d>
	int neg = 0;
f01015fd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101602:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f0101609:	75 12                	jne    f010161d <strtol+0x3e>
f010160b:	80 39 30             	cmpb   $0x30,(%ecx)
f010160e:	74 24                	je     f0101634 <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101610:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101614:	75 07                	jne    f010161d <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101616:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f010161d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101622:	eb 4e                	jmp    f0101672 <strtol+0x93>
		s++;
f0101624:	41                   	inc    %ecx
	int neg = 0;
f0101625:	bf 00 00 00 00       	mov    $0x0,%edi
f010162a:	eb d6                	jmp    f0101602 <strtol+0x23>
		s++, neg = 1;
f010162c:	41                   	inc    %ecx
f010162d:	bf 01 00 00 00       	mov    $0x1,%edi
f0101632:	eb ce                	jmp    f0101602 <strtol+0x23>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101634:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101638:	74 10                	je     f010164a <strtol+0x6b>
	else if (base == 0 && s[0] == '0')
f010163a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010163e:	75 dd                	jne    f010161d <strtol+0x3e>
		s++, base = 8;
f0101640:	41                   	inc    %ecx
f0101641:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f0101648:	eb d3                	jmp    f010161d <strtol+0x3e>
		s += 2, base = 16;
f010164a:	83 c1 02             	add    $0x2,%ecx
f010164d:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f0101654:	eb c7                	jmp    f010161d <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0101656:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101659:	89 f3                	mov    %esi,%ebx
f010165b:	80 fb 19             	cmp    $0x19,%bl
f010165e:	77 24                	ja     f0101684 <strtol+0xa5>
			dig = *s - 'a' + 10;
f0101660:	0f be d2             	movsbl %dl,%edx
f0101663:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101666:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101669:	7d 2b                	jge    f0101696 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
f010166b:	41                   	inc    %ecx
f010166c:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101670:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0101672:	8a 11                	mov    (%ecx),%dl
f0101674:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0101677:	80 fb 09             	cmp    $0x9,%bl
f010167a:	77 da                	ja     f0101656 <strtol+0x77>
			dig = *s - '0';
f010167c:	0f be d2             	movsbl %dl,%edx
f010167f:	83 ea 30             	sub    $0x30,%edx
f0101682:	eb e2                	jmp    f0101666 <strtol+0x87>
		else if (*s >= 'A' && *s <= 'Z')
f0101684:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101687:	89 f3                	mov    %esi,%ebx
f0101689:	80 fb 19             	cmp    $0x19,%bl
f010168c:	77 08                	ja     f0101696 <strtol+0xb7>
			dig = *s - 'A' + 10;
f010168e:	0f be d2             	movsbl %dl,%edx
f0101691:	83 ea 37             	sub    $0x37,%edx
f0101694:	eb d0                	jmp    f0101666 <strtol+0x87>
		// we don't properly detect overflow!
	}

	if (endptr)
f0101696:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010169a:	74 05                	je     f01016a1 <strtol+0xc2>
		*endptr = (char *) s;
f010169c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010169f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f01016a1:	85 ff                	test   %edi,%edi
f01016a3:	74 02                	je     f01016a7 <strtol+0xc8>
f01016a5:	f7 d8                	neg    %eax
}
f01016a7:	5b                   	pop    %ebx
f01016a8:	5e                   	pop    %esi
f01016a9:	5f                   	pop    %edi
f01016aa:	5d                   	pop    %ebp
f01016ab:	c3                   	ret    

f01016ac <__udivdi3>:
f01016ac:	55                   	push   %ebp
f01016ad:	57                   	push   %edi
f01016ae:	56                   	push   %esi
f01016af:	53                   	push   %ebx
f01016b0:	83 ec 1c             	sub    $0x1c,%esp
f01016b3:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01016b7:	8b 74 24 34          	mov    0x34(%esp),%esi
f01016bb:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01016bf:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01016c3:	85 d2                	test   %edx,%edx
f01016c5:	75 2d                	jne    f01016f4 <__udivdi3+0x48>
f01016c7:	39 f7                	cmp    %esi,%edi
f01016c9:	77 59                	ja     f0101724 <__udivdi3+0x78>
f01016cb:	89 f9                	mov    %edi,%ecx
f01016cd:	85 ff                	test   %edi,%edi
f01016cf:	75 0b                	jne    f01016dc <__udivdi3+0x30>
f01016d1:	b8 01 00 00 00       	mov    $0x1,%eax
f01016d6:	31 d2                	xor    %edx,%edx
f01016d8:	f7 f7                	div    %edi
f01016da:	89 c1                	mov    %eax,%ecx
f01016dc:	31 d2                	xor    %edx,%edx
f01016de:	89 f0                	mov    %esi,%eax
f01016e0:	f7 f1                	div    %ecx
f01016e2:	89 c3                	mov    %eax,%ebx
f01016e4:	89 e8                	mov    %ebp,%eax
f01016e6:	f7 f1                	div    %ecx
f01016e8:	89 da                	mov    %ebx,%edx
f01016ea:	83 c4 1c             	add    $0x1c,%esp
f01016ed:	5b                   	pop    %ebx
f01016ee:	5e                   	pop    %esi
f01016ef:	5f                   	pop    %edi
f01016f0:	5d                   	pop    %ebp
f01016f1:	c3                   	ret    
f01016f2:	66 90                	xchg   %ax,%ax
f01016f4:	39 f2                	cmp    %esi,%edx
f01016f6:	77 1c                	ja     f0101714 <__udivdi3+0x68>
f01016f8:	0f bd da             	bsr    %edx,%ebx
f01016fb:	83 f3 1f             	xor    $0x1f,%ebx
f01016fe:	75 38                	jne    f0101738 <__udivdi3+0x8c>
f0101700:	39 f2                	cmp    %esi,%edx
f0101702:	72 08                	jb     f010170c <__udivdi3+0x60>
f0101704:	39 ef                	cmp    %ebp,%edi
f0101706:	0f 87 98 00 00 00    	ja     f01017a4 <__udivdi3+0xf8>
f010170c:	b8 01 00 00 00       	mov    $0x1,%eax
f0101711:	eb 05                	jmp    f0101718 <__udivdi3+0x6c>
f0101713:	90                   	nop
f0101714:	31 db                	xor    %ebx,%ebx
f0101716:	31 c0                	xor    %eax,%eax
f0101718:	89 da                	mov    %ebx,%edx
f010171a:	83 c4 1c             	add    $0x1c,%esp
f010171d:	5b                   	pop    %ebx
f010171e:	5e                   	pop    %esi
f010171f:	5f                   	pop    %edi
f0101720:	5d                   	pop    %ebp
f0101721:	c3                   	ret    
f0101722:	66 90                	xchg   %ax,%ax
f0101724:	89 e8                	mov    %ebp,%eax
f0101726:	89 f2                	mov    %esi,%edx
f0101728:	f7 f7                	div    %edi
f010172a:	31 db                	xor    %ebx,%ebx
f010172c:	89 da                	mov    %ebx,%edx
f010172e:	83 c4 1c             	add    $0x1c,%esp
f0101731:	5b                   	pop    %ebx
f0101732:	5e                   	pop    %esi
f0101733:	5f                   	pop    %edi
f0101734:	5d                   	pop    %ebp
f0101735:	c3                   	ret    
f0101736:	66 90                	xchg   %ax,%ax
f0101738:	b8 20 00 00 00       	mov    $0x20,%eax
f010173d:	29 d8                	sub    %ebx,%eax
f010173f:	88 d9                	mov    %bl,%cl
f0101741:	d3 e2                	shl    %cl,%edx
f0101743:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101747:	89 fa                	mov    %edi,%edx
f0101749:	88 c1                	mov    %al,%cl
f010174b:	d3 ea                	shr    %cl,%edx
f010174d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101751:	09 d1                	or     %edx,%ecx
f0101753:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101757:	88 d9                	mov    %bl,%cl
f0101759:	d3 e7                	shl    %cl,%edi
f010175b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010175f:	89 f7                	mov    %esi,%edi
f0101761:	88 c1                	mov    %al,%cl
f0101763:	d3 ef                	shr    %cl,%edi
f0101765:	88 d9                	mov    %bl,%cl
f0101767:	d3 e6                	shl    %cl,%esi
f0101769:	89 ea                	mov    %ebp,%edx
f010176b:	88 c1                	mov    %al,%cl
f010176d:	d3 ea                	shr    %cl,%edx
f010176f:	09 d6                	or     %edx,%esi
f0101771:	89 f0                	mov    %esi,%eax
f0101773:	89 fa                	mov    %edi,%edx
f0101775:	f7 74 24 08          	divl   0x8(%esp)
f0101779:	89 d7                	mov    %edx,%edi
f010177b:	89 c6                	mov    %eax,%esi
f010177d:	f7 64 24 0c          	mull   0xc(%esp)
f0101781:	39 d7                	cmp    %edx,%edi
f0101783:	72 13                	jb     f0101798 <__udivdi3+0xec>
f0101785:	74 09                	je     f0101790 <__udivdi3+0xe4>
f0101787:	89 f0                	mov    %esi,%eax
f0101789:	31 db                	xor    %ebx,%ebx
f010178b:	eb 8b                	jmp    f0101718 <__udivdi3+0x6c>
f010178d:	8d 76 00             	lea    0x0(%esi),%esi
f0101790:	88 d9                	mov    %bl,%cl
f0101792:	d3 e5                	shl    %cl,%ebp
f0101794:	39 c5                	cmp    %eax,%ebp
f0101796:	73 ef                	jae    f0101787 <__udivdi3+0xdb>
f0101798:	8d 46 ff             	lea    -0x1(%esi),%eax
f010179b:	31 db                	xor    %ebx,%ebx
f010179d:	e9 76 ff ff ff       	jmp    f0101718 <__udivdi3+0x6c>
f01017a2:	66 90                	xchg   %ax,%ax
f01017a4:	31 c0                	xor    %eax,%eax
f01017a6:	e9 6d ff ff ff       	jmp    f0101718 <__udivdi3+0x6c>
f01017ab:	90                   	nop

f01017ac <__umoddi3>:
f01017ac:	55                   	push   %ebp
f01017ad:	57                   	push   %edi
f01017ae:	56                   	push   %esi
f01017af:	53                   	push   %ebx
f01017b0:	83 ec 1c             	sub    $0x1c,%esp
f01017b3:	8b 74 24 30          	mov    0x30(%esp),%esi
f01017b7:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01017bb:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01017bf:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f01017c3:	89 f0                	mov    %esi,%eax
f01017c5:	89 da                	mov    %ebx,%edx
f01017c7:	85 ed                	test   %ebp,%ebp
f01017c9:	75 15                	jne    f01017e0 <__umoddi3+0x34>
f01017cb:	39 df                	cmp    %ebx,%edi
f01017cd:	76 39                	jbe    f0101808 <__umoddi3+0x5c>
f01017cf:	f7 f7                	div    %edi
f01017d1:	89 d0                	mov    %edx,%eax
f01017d3:	31 d2                	xor    %edx,%edx
f01017d5:	83 c4 1c             	add    $0x1c,%esp
f01017d8:	5b                   	pop    %ebx
f01017d9:	5e                   	pop    %esi
f01017da:	5f                   	pop    %edi
f01017db:	5d                   	pop    %ebp
f01017dc:	c3                   	ret    
f01017dd:	8d 76 00             	lea    0x0(%esi),%esi
f01017e0:	39 dd                	cmp    %ebx,%ebp
f01017e2:	77 f1                	ja     f01017d5 <__umoddi3+0x29>
f01017e4:	0f bd cd             	bsr    %ebp,%ecx
f01017e7:	83 f1 1f             	xor    $0x1f,%ecx
f01017ea:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01017ee:	75 38                	jne    f0101828 <__umoddi3+0x7c>
f01017f0:	39 dd                	cmp    %ebx,%ebp
f01017f2:	72 04                	jb     f01017f8 <__umoddi3+0x4c>
f01017f4:	39 f7                	cmp    %esi,%edi
f01017f6:	77 dd                	ja     f01017d5 <__umoddi3+0x29>
f01017f8:	89 da                	mov    %ebx,%edx
f01017fa:	89 f0                	mov    %esi,%eax
f01017fc:	29 f8                	sub    %edi,%eax
f01017fe:	19 ea                	sbb    %ebp,%edx
f0101800:	83 c4 1c             	add    $0x1c,%esp
f0101803:	5b                   	pop    %ebx
f0101804:	5e                   	pop    %esi
f0101805:	5f                   	pop    %edi
f0101806:	5d                   	pop    %ebp
f0101807:	c3                   	ret    
f0101808:	89 f9                	mov    %edi,%ecx
f010180a:	85 ff                	test   %edi,%edi
f010180c:	75 0b                	jne    f0101819 <__umoddi3+0x6d>
f010180e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101813:	31 d2                	xor    %edx,%edx
f0101815:	f7 f7                	div    %edi
f0101817:	89 c1                	mov    %eax,%ecx
f0101819:	89 d8                	mov    %ebx,%eax
f010181b:	31 d2                	xor    %edx,%edx
f010181d:	f7 f1                	div    %ecx
f010181f:	89 f0                	mov    %esi,%eax
f0101821:	f7 f1                	div    %ecx
f0101823:	eb ac                	jmp    f01017d1 <__umoddi3+0x25>
f0101825:	8d 76 00             	lea    0x0(%esi),%esi
f0101828:	b8 20 00 00 00       	mov    $0x20,%eax
f010182d:	89 c2                	mov    %eax,%edx
f010182f:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101833:	29 c2                	sub    %eax,%edx
f0101835:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101839:	88 c1                	mov    %al,%cl
f010183b:	d3 e5                	shl    %cl,%ebp
f010183d:	89 f8                	mov    %edi,%eax
f010183f:	88 d1                	mov    %dl,%cl
f0101841:	d3 e8                	shr    %cl,%eax
f0101843:	09 c5                	or     %eax,%ebp
f0101845:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101849:	88 c1                	mov    %al,%cl
f010184b:	d3 e7                	shl    %cl,%edi
f010184d:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101851:	89 df                	mov    %ebx,%edi
f0101853:	88 d1                	mov    %dl,%cl
f0101855:	d3 ef                	shr    %cl,%edi
f0101857:	88 c1                	mov    %al,%cl
f0101859:	d3 e3                	shl    %cl,%ebx
f010185b:	89 f0                	mov    %esi,%eax
f010185d:	88 d1                	mov    %dl,%cl
f010185f:	d3 e8                	shr    %cl,%eax
f0101861:	09 d8                	or     %ebx,%eax
f0101863:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0101867:	d3 e6                	shl    %cl,%esi
f0101869:	89 fa                	mov    %edi,%edx
f010186b:	f7 f5                	div    %ebp
f010186d:	89 d1                	mov    %edx,%ecx
f010186f:	f7 64 24 08          	mull   0x8(%esp)
f0101873:	89 c3                	mov    %eax,%ebx
f0101875:	89 d7                	mov    %edx,%edi
f0101877:	39 d1                	cmp    %edx,%ecx
f0101879:	72 29                	jb     f01018a4 <__umoddi3+0xf8>
f010187b:	74 23                	je     f01018a0 <__umoddi3+0xf4>
f010187d:	89 ca                	mov    %ecx,%edx
f010187f:	29 de                	sub    %ebx,%esi
f0101881:	19 fa                	sbb    %edi,%edx
f0101883:	89 d0                	mov    %edx,%eax
f0101885:	8a 4c 24 0c          	mov    0xc(%esp),%cl
f0101889:	d3 e0                	shl    %cl,%eax
f010188b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f010188f:	88 d9                	mov    %bl,%cl
f0101891:	d3 ee                	shr    %cl,%esi
f0101893:	09 f0                	or     %esi,%eax
f0101895:	d3 ea                	shr    %cl,%edx
f0101897:	83 c4 1c             	add    $0x1c,%esp
f010189a:	5b                   	pop    %ebx
f010189b:	5e                   	pop    %esi
f010189c:	5f                   	pop    %edi
f010189d:	5d                   	pop    %ebp
f010189e:	c3                   	ret    
f010189f:	90                   	nop
f01018a0:	39 c6                	cmp    %eax,%esi
f01018a2:	73 d9                	jae    f010187d <__umoddi3+0xd1>
f01018a4:	2b 44 24 08          	sub    0x8(%esp),%eax
f01018a8:	19 ea                	sbb    %ebp,%edx
f01018aa:	89 d7                	mov    %edx,%edi
f01018ac:	89 c3                	mov    %eax,%ebx
f01018ae:	eb cd                	jmp    f010187d <__umoddi3+0xd1>
