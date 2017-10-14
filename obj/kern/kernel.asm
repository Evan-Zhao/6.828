
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
f010004b:	68 e0 17 10 f0       	push   $0xf01017e0
f0100050:	e8 ad 08 00 00       	call   f0100902 <cprintf>
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
f0100071:	68 fc 17 10 f0       	push   $0xf01017fc
f0100076:	e8 87 08 00 00       	call   f0100902 <cprintf>
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
f01000ac:	e8 3d 13 00 00       	call   f01013ee <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 d3 04 00 00       	call   f0100589 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 17 18 10 f0       	push   $0xf0101817
f01000c3:	e8 3a 08 00 00       	call   f0100902 <cprintf>

	cprintf(ANSI_COLOR_RED     "This text is RED!"     ANSI_COLOR_RESET "\n");
f01000c8:	c7 04 24 32 18 10 f0 	movl   $0xf0101832,(%esp)
f01000cf:	e8 2e 08 00 00       	call   f0100902 <cprintf>
	cprintf(ANSI_COLOR_GREEN   "This text is GREEN!"   ANSI_COLOR_RESET "\n");
f01000d4:	c7 04 24 4e 18 10 f0 	movl   $0xf010184e,(%esp)
f01000db:	e8 22 08 00 00       	call   f0100902 <cprintf>
	cprintf(ANSI_COLOR_YELLOW  "This text is YELLOW!"  ANSI_COLOR_RESET "\n");
f01000e0:	c7 04 24 d8 18 10 f0 	movl   $0xf01018d8,(%esp)
f01000e7:	e8 16 08 00 00       	call   f0100902 <cprintf>
	cprintf(ANSI_COLOR_BLUE    "This text is BLUE!"    ANSI_COLOR_RESET "\n");
f01000ec:	c7 04 24 6c 18 10 f0 	movl   $0xf010186c,(%esp)
f01000f3:	e8 0a 08 00 00       	call   f0100902 <cprintf>
	cprintf(ANSI_COLOR_MAGENTA "This text is MAGENTA!" ANSI_COLOR_RESET "\n");
f01000f8:	c7 04 24 f8 18 10 f0 	movl   $0xf01018f8,(%esp)
f01000ff:	e8 fe 07 00 00       	call   f0100902 <cprintf>
	cprintf(ANSI_COLOR_CYAN    "This text is CYAN!"    ANSI_COLOR_RESET "\n");
f0100104:	c7 04 24 89 18 10 f0 	movl   $0xf0101889,(%esp)
f010010b:	e8 f2 07 00 00       	call   f0100902 <cprintf>

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
f0100124:	e8 65 06 00 00       	call   f010078e <monitor>
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
f0100144:	e8 45 06 00 00       	call   f010078e <monitor>
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
f0100162:	68 a6 18 10 f0       	push   $0xf01018a6
f0100167:	e8 96 07 00 00       	call   f0100902 <cprintf>
	vcprintf(fmt, ap);
f010016c:	83 c4 08             	add    $0x8,%esp
f010016f:	53                   	push   %ebx
f0100170:	56                   	push   %esi
f0100171:	e8 66 07 00 00       	call   f01008dc <vcprintf>
	cprintf("\n");
f0100176:	c7 04 24 22 19 10 f0 	movl   $0xf0101922,(%esp)
f010017d:	e8 80 07 00 00       	call   f0100902 <cprintf>
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
f0100197:	68 be 18 10 f0       	push   $0xf01018be
f010019c:	e8 61 07 00 00       	call   f0100902 <cprintf>
	vcprintf(fmt, ap);
f01001a1:	83 c4 08             	add    $0x8,%esp
f01001a4:	53                   	push   %ebx
f01001a5:	ff 75 10             	pushl  0x10(%ebp)
f01001a8:	e8 2f 07 00 00       	call   f01008dc <vcprintf>
	cprintf("\n");
f01001ad:	c7 04 24 22 19 10 f0 	movl   $0xf0101922,(%esp)
f01001b4:	e8 49 07 00 00       	call   f0100902 <cprintf>
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
f0100274:	0f b6 82 80 1a 10 f0 	movzbl -0xfefe580(%edx),%eax
f010027b:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
	shift ^= togglecode[data];
f0100281:	0f b6 8a 80 19 10 f0 	movzbl -0xfefe680(%edx),%ecx
f0100288:	31 c8                	xor    %ecx,%eax
f010028a:	a3 00 23 11 f0       	mov    %eax,0xf0112300
	c = charcode[shift & (CTL | SHIFT)][data];
f010028f:	89 c1                	mov    %eax,%ecx
f0100291:	83 e1 03             	and    $0x3,%ecx
f0100294:	8b 0c 8d 60 19 10 f0 	mov    -0xfefe6a0(,%ecx,4),%ecx
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
f01002c3:	68 18 19 10 f0       	push   $0xf0101918
f01002c8:	e8 35 06 00 00       	call   f0100902 <cprintf>
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
f0100300:	8a 82 80 1a 10 f0    	mov    -0xfefe580(%edx),%al
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
f01004de:	e8 58 0f 00 00       	call   f010143b <memmove>
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
f0100672:	68 24 19 10 f0       	push   $0xf0101924
f0100677:	e8 86 02 00 00       	call   f0100902 <cprintf>
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
f01006b2:	68 80 1b 10 f0       	push   $0xf0101b80
f01006b7:	68 9e 1b 10 f0       	push   $0xf0101b9e
f01006bc:	68 a3 1b 10 f0       	push   $0xf0101ba3
f01006c1:	e8 3c 02 00 00       	call   f0100902 <cprintf>
f01006c6:	83 c4 0c             	add    $0xc,%esp
f01006c9:	68 0c 1c 10 f0       	push   $0xf0101c0c
f01006ce:	68 ac 1b 10 f0       	push   $0xf0101bac
f01006d3:	68 a3 1b 10 f0       	push   $0xf0101ba3
f01006d8:	e8 25 02 00 00       	call   f0100902 <cprintf>
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
f01006ea:	68 b5 1b 10 f0       	push   $0xf0101bb5
f01006ef:	e8 0e 02 00 00       	call   f0100902 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006f4:	83 c4 08             	add    $0x8,%esp
f01006f7:	68 0c 00 10 00       	push   $0x10000c
f01006fc:	68 34 1c 10 f0       	push   $0xf0101c34
f0100701:	e8 fc 01 00 00       	call   f0100902 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100706:	83 c4 0c             	add    $0xc,%esp
f0100709:	68 0c 00 10 00       	push   $0x10000c
f010070e:	68 0c 00 10 f0       	push   $0xf010000c
f0100713:	68 5c 1c 10 f0       	push   $0xf0101c5c
f0100718:	e8 e5 01 00 00       	call   f0100902 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010071d:	83 c4 0c             	add    $0xc,%esp
f0100720:	68 d4 17 10 00       	push   $0x1017d4
f0100725:	68 d4 17 10 f0       	push   $0xf01017d4
f010072a:	68 80 1c 10 f0       	push   $0xf0101c80
f010072f:	e8 ce 01 00 00       	call   f0100902 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100734:	83 c4 0c             	add    $0xc,%esp
f0100737:	68 00 23 11 00       	push   $0x112300
f010073c:	68 00 23 11 f0       	push   $0xf0112300
f0100741:	68 a4 1c 10 f0       	push   $0xf0101ca4
f0100746:	e8 b7 01 00 00       	call   f0100902 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010074b:	83 c4 0c             	add    $0xc,%esp
f010074e:	68 44 29 11 00       	push   $0x112944
f0100753:	68 44 29 11 f0       	push   $0xf0112944
f0100758:	68 c8 1c 10 f0       	push   $0xf0101cc8
f010075d:	e8 a0 01 00 00       	call   f0100902 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100762:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100765:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
f010076a:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f010076f:	c1 f8 0a             	sar    $0xa,%eax
f0100772:	50                   	push   %eax
f0100773:	68 ec 1c 10 f0       	push   $0xf0101cec
f0100778:	e8 85 01 00 00       	call   f0100902 <cprintf>
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
	// Your code here.
	return 0;
}
f0100787:	b8 00 00 00 00       	mov    $0x0,%eax
f010078c:	5d                   	pop    %ebp
f010078d:	c3                   	ret    

f010078e <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010078e:	55                   	push   %ebp
f010078f:	89 e5                	mov    %esp,%ebp
f0100791:	57                   	push   %edi
f0100792:	56                   	push   %esi
f0100793:	53                   	push   %ebx
f0100794:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100797:	68 18 1d 10 f0       	push   $0xf0101d18
f010079c:	e8 61 01 00 00       	call   f0100902 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007a1:	c7 04 24 3c 1d 10 f0 	movl   $0xf0101d3c,(%esp)
f01007a8:	e8 55 01 00 00       	call   f0100902 <cprintf>
f01007ad:	83 c4 10             	add    $0x10,%esp
f01007b0:	eb 47                	jmp    f01007f9 <monitor+0x6b>
		while (*buf && strchr(WHITESPACE, *buf))
f01007b2:	83 ec 08             	sub    $0x8,%esp
f01007b5:	0f be c0             	movsbl %al,%eax
f01007b8:	50                   	push   %eax
f01007b9:	68 d2 1b 10 f0       	push   $0xf0101bd2
f01007be:	e8 f6 0b 00 00       	call   f01013b9 <strchr>
f01007c3:	83 c4 10             	add    $0x10,%esp
f01007c6:	85 c0                	test   %eax,%eax
f01007c8:	74 0a                	je     f01007d4 <monitor+0x46>
			*buf++ = 0;
f01007ca:	c6 03 00             	movb   $0x0,(%ebx)
f01007cd:	89 f7                	mov    %esi,%edi
f01007cf:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01007d2:	eb 68                	jmp    f010083c <monitor+0xae>
		if (*buf == 0)
f01007d4:	80 3b 00             	cmpb   $0x0,(%ebx)
f01007d7:	74 6f                	je     f0100848 <monitor+0xba>
		if (argc == MAXARGS-1) {
f01007d9:	83 fe 0f             	cmp    $0xf,%esi
f01007dc:	74 09                	je     f01007e7 <monitor+0x59>
		argv[argc++] = buf;
f01007de:	8d 7e 01             	lea    0x1(%esi),%edi
f01007e1:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01007e5:	eb 37                	jmp    f010081e <monitor+0x90>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01007e7:	83 ec 08             	sub    $0x8,%esp
f01007ea:	6a 10                	push   $0x10
f01007ec:	68 d7 1b 10 f0       	push   $0xf0101bd7
f01007f1:	e8 0c 01 00 00       	call   f0100902 <cprintf>
f01007f6:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01007f9:	83 ec 0c             	sub    $0xc,%esp
f01007fc:	68 ce 1b 10 f0       	push   $0xf0101bce
f0100801:	e8 a8 09 00 00       	call   f01011ae <readline>
f0100806:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100808:	83 c4 10             	add    $0x10,%esp
f010080b:	85 c0                	test   %eax,%eax
f010080d:	74 ea                	je     f01007f9 <monitor+0x6b>
	argv[argc] = 0;
f010080f:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100816:	be 00 00 00 00       	mov    $0x0,%esi
f010081b:	eb 21                	jmp    f010083e <monitor+0xb0>
			buf++;
f010081d:	43                   	inc    %ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f010081e:	8a 03                	mov    (%ebx),%al
f0100820:	84 c0                	test   %al,%al
f0100822:	74 18                	je     f010083c <monitor+0xae>
f0100824:	83 ec 08             	sub    $0x8,%esp
f0100827:	0f be c0             	movsbl %al,%eax
f010082a:	50                   	push   %eax
f010082b:	68 d2 1b 10 f0       	push   $0xf0101bd2
f0100830:	e8 84 0b 00 00       	call   f01013b9 <strchr>
f0100835:	83 c4 10             	add    $0x10,%esp
f0100838:	85 c0                	test   %eax,%eax
f010083a:	74 e1                	je     f010081d <monitor+0x8f>
			*buf++ = 0;
f010083c:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f010083e:	8a 03                	mov    (%ebx),%al
f0100840:	84 c0                	test   %al,%al
f0100842:	0f 85 6a ff ff ff    	jne    f01007b2 <monitor+0x24>
	argv[argc] = 0;
f0100848:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f010084f:	00 
	if (argc == 0)
f0100850:	85 f6                	test   %esi,%esi
f0100852:	74 a5                	je     f01007f9 <monitor+0x6b>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100854:	83 ec 08             	sub    $0x8,%esp
f0100857:	68 9e 1b 10 f0       	push   $0xf0101b9e
f010085c:	ff 75 a8             	pushl  -0x58(%ebp)
f010085f:	e8 01 0b 00 00       	call   f0101365 <strcmp>
f0100864:	83 c4 10             	add    $0x10,%esp
f0100867:	85 c0                	test   %eax,%eax
f0100869:	74 34                	je     f010089f <monitor+0x111>
f010086b:	83 ec 08             	sub    $0x8,%esp
f010086e:	68 ac 1b 10 f0       	push   $0xf0101bac
f0100873:	ff 75 a8             	pushl  -0x58(%ebp)
f0100876:	e8 ea 0a 00 00       	call   f0101365 <strcmp>
f010087b:	83 c4 10             	add    $0x10,%esp
f010087e:	85 c0                	test   %eax,%eax
f0100880:	74 18                	je     f010089a <monitor+0x10c>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100882:	83 ec 08             	sub    $0x8,%esp
f0100885:	ff 75 a8             	pushl  -0x58(%ebp)
f0100888:	68 f4 1b 10 f0       	push   $0xf0101bf4
f010088d:	e8 70 00 00 00       	call   f0100902 <cprintf>
f0100892:	83 c4 10             	add    $0x10,%esp
f0100895:	e9 5f ff ff ff       	jmp    f01007f9 <monitor+0x6b>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f010089a:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f010089f:	83 ec 04             	sub    $0x4,%esp
f01008a2:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01008a5:	01 d0                	add    %edx,%eax
f01008a7:	ff 75 08             	pushl  0x8(%ebp)
f01008aa:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f01008ad:	51                   	push   %ecx
f01008ae:	56                   	push   %esi
f01008af:	ff 14 85 6c 1d 10 f0 	call   *-0xfefe294(,%eax,4)
			if (runcmd(buf, tf) < 0)
f01008b6:	83 c4 10             	add    $0x10,%esp
f01008b9:	85 c0                	test   %eax,%eax
f01008bb:	0f 89 38 ff ff ff    	jns    f01007f9 <monitor+0x6b>
				break;
	}
}
f01008c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008c4:	5b                   	pop    %ebx
f01008c5:	5e                   	pop    %esi
f01008c6:	5f                   	pop    %edi
f01008c7:	5d                   	pop    %ebp
f01008c8:	c3                   	ret    

f01008c9 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01008c9:	55                   	push   %ebp
f01008ca:	89 e5                	mov    %esp,%ebp
f01008cc:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01008cf:	ff 75 08             	pushl  0x8(%ebp)
f01008d2:	e8 aa fd ff ff       	call   f0100681 <cputchar>
	*cnt++;
}
f01008d7:	83 c4 10             	add    $0x10,%esp
f01008da:	c9                   	leave  
f01008db:	c3                   	ret    

f01008dc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01008dc:	55                   	push   %ebp
f01008dd:	89 e5                	mov    %esp,%ebp
f01008df:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01008e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01008e9:	ff 75 0c             	pushl  0xc(%ebp)
f01008ec:	ff 75 08             	pushl  0x8(%ebp)
f01008ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01008f2:	50                   	push   %eax
f01008f3:	68 c9 08 10 f0       	push   $0xf01008c9
f01008f8:	e8 d8 03 00 00       	call   f0100cd5 <vprintfmt>
	return cnt;
}
f01008fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100900:	c9                   	leave  
f0100901:	c3                   	ret    

f0100902 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100902:	55                   	push   %ebp
f0100903:	89 e5                	mov    %esp,%ebp
f0100905:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100908:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010090b:	50                   	push   %eax
f010090c:	ff 75 08             	pushl  0x8(%ebp)
f010090f:	e8 c8 ff ff ff       	call   f01008dc <vcprintf>
	va_end(ap);

	return cnt;
}
f0100914:	c9                   	leave  
f0100915:	c3                   	ret    

f0100916 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100916:	55                   	push   %ebp
f0100917:	89 e5                	mov    %esp,%ebp
f0100919:	57                   	push   %edi
f010091a:	56                   	push   %esi
f010091b:	53                   	push   %ebx
f010091c:	83 ec 14             	sub    $0x14,%esp
f010091f:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100922:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100925:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100928:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f010092b:	8b 32                	mov    (%edx),%esi
f010092d:	8b 01                	mov    (%ecx),%eax
f010092f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100932:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100939:	eb 2f                	jmp    f010096a <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f010093b:	48                   	dec    %eax
		while (m >= l && stabs[m].n_type != type)
f010093c:	39 c6                	cmp    %eax,%esi
f010093e:	7f 4d                	jg     f010098d <stab_binsearch+0x77>
f0100940:	0f b6 0a             	movzbl (%edx),%ecx
f0100943:	83 ea 0c             	sub    $0xc,%edx
f0100946:	39 f9                	cmp    %edi,%ecx
f0100948:	75 f1                	jne    f010093b <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010094a:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010094d:	01 c2                	add    %eax,%edx
f010094f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100952:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100956:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100959:	73 37                	jae    f0100992 <stab_binsearch+0x7c>
			*region_left = m;
f010095b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010095e:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0100960:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0100963:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f010096a:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f010096d:	7f 4d                	jg     f01009bc <stab_binsearch+0xa6>
		int true_m = (l + r) / 2, m = true_m;
f010096f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100972:	01 f0                	add    %esi,%eax
f0100974:	89 c3                	mov    %eax,%ebx
f0100976:	c1 eb 1f             	shr    $0x1f,%ebx
f0100979:	01 c3                	add    %eax,%ebx
f010097b:	d1 fb                	sar    %ebx
f010097d:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100980:	01 d8                	add    %ebx,%eax
f0100982:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100985:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100989:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f010098b:	eb af                	jmp    f010093c <stab_binsearch+0x26>
			l = true_m + 1;
f010098d:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0100990:	eb d8                	jmp    f010096a <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100992:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100995:	76 12                	jbe    f01009a9 <stab_binsearch+0x93>
			*region_right = m - 1;
f0100997:	48                   	dec    %eax
f0100998:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010099b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010099e:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f01009a0:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01009a7:	eb c1                	jmp    f010096a <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01009a9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01009ac:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01009ae:	ff 45 0c             	incl   0xc(%ebp)
f01009b1:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f01009b3:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01009ba:	eb ae                	jmp    f010096a <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f01009bc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01009c0:	74 18                	je     f01009da <stab_binsearch+0xc4>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01009c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01009c5:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01009c7:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01009ca:	8b 0e                	mov    (%esi),%ecx
f01009cc:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01009cf:	01 c2                	add    %eax,%edx
f01009d1:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01009d4:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f01009d8:	eb 0e                	jmp    f01009e8 <stab_binsearch+0xd2>
		*region_right = *region_left - 1;
f01009da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009dd:	8b 00                	mov    (%eax),%eax
f01009df:	48                   	dec    %eax
f01009e0:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01009e3:	89 07                	mov    %eax,(%edi)
f01009e5:	eb 14                	jmp    f01009fb <stab_binsearch+0xe5>
		     l--)
f01009e7:	48                   	dec    %eax
		for (l = *region_right;
f01009e8:	39 c1                	cmp    %eax,%ecx
f01009ea:	7d 0a                	jge    f01009f6 <stab_binsearch+0xe0>
		     l > *region_left && stabs[l].n_type != type;
f01009ec:	0f b6 1a             	movzbl (%edx),%ebx
f01009ef:	83 ea 0c             	sub    $0xc,%edx
f01009f2:	39 fb                	cmp    %edi,%ebx
f01009f4:	75 f1                	jne    f01009e7 <stab_binsearch+0xd1>
			/* do nothing */;
		*region_left = l;
f01009f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01009f9:	89 07                	mov    %eax,(%edi)
	}
}
f01009fb:	83 c4 14             	add    $0x14,%esp
f01009fe:	5b                   	pop    %ebx
f01009ff:	5e                   	pop    %esi
f0100a00:	5f                   	pop    %edi
f0100a01:	5d                   	pop    %ebp
f0100a02:	c3                   	ret    

f0100a03 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100a03:	55                   	push   %ebp
f0100a04:	89 e5                	mov    %esp,%ebp
f0100a06:	57                   	push   %edi
f0100a07:	56                   	push   %esi
f0100a08:	53                   	push   %ebx
f0100a09:	83 ec 1c             	sub    $0x1c,%esp
f0100a0c:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100a0f:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100a12:	c7 06 7c 1d 10 f0    	movl   $0xf0101d7c,(%esi)
	info->eip_line = 0;
f0100a18:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100a1f:	c7 46 08 7c 1d 10 f0 	movl   $0xf0101d7c,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100a26:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100a2d:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100a30:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100a37:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100a3d:	0f 86 f8 00 00 00    	jbe    f0100b3b <debuginfo_eip+0x138>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100a43:	b8 c3 73 10 f0       	mov    $0xf01073c3,%eax
f0100a48:	3d a1 5a 10 f0       	cmp    $0xf0105aa1,%eax
f0100a4d:	0f 86 73 01 00 00    	jbe    f0100bc6 <debuginfo_eip+0x1c3>
f0100a53:	80 3d c2 73 10 f0 00 	cmpb   $0x0,0xf01073c2
f0100a5a:	0f 85 6d 01 00 00    	jne    f0100bcd <debuginfo_eip+0x1ca>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100a60:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100a67:	ba a0 5a 10 f0       	mov    $0xf0105aa0,%edx
f0100a6c:	81 ea b4 1f 10 f0    	sub    $0xf0101fb4,%edx
f0100a72:	c1 fa 02             	sar    $0x2,%edx
f0100a75:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0100a78:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100a7b:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100a7e:	89 c1                	mov    %eax,%ecx
f0100a80:	c1 e1 08             	shl    $0x8,%ecx
f0100a83:	01 c8                	add    %ecx,%eax
f0100a85:	89 c1                	mov    %eax,%ecx
f0100a87:	c1 e1 10             	shl    $0x10,%ecx
f0100a8a:	01 c8                	add    %ecx,%eax
f0100a8c:	01 c0                	add    %eax,%eax
f0100a8e:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
f0100a92:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100a95:	83 ec 08             	sub    $0x8,%esp
f0100a98:	57                   	push   %edi
f0100a99:	6a 64                	push   $0x64
f0100a9b:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100a9e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100aa1:	b8 b4 1f 10 f0       	mov    $0xf0101fb4,%eax
f0100aa6:	e8 6b fe ff ff       	call   f0100916 <stab_binsearch>
	if (lfile == 0)
f0100aab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100aae:	83 c4 10             	add    $0x10,%esp
f0100ab1:	85 c0                	test   %eax,%eax
f0100ab3:	0f 84 1b 01 00 00    	je     f0100bd4 <debuginfo_eip+0x1d1>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100ab9:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100abc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100abf:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100ac2:	83 ec 08             	sub    $0x8,%esp
f0100ac5:	57                   	push   %edi
f0100ac6:	6a 24                	push   $0x24
f0100ac8:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100acb:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ace:	b8 b4 1f 10 f0       	mov    $0xf0101fb4,%eax
f0100ad3:	e8 3e fe ff ff       	call   f0100916 <stab_binsearch>

	if (lfun <= rfun) {
f0100ad8:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100adb:	83 c4 10             	add    $0x10,%esp
f0100ade:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0100ae1:	7f 6c                	jg     f0100b4f <debuginfo_eip+0x14c>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100ae3:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100ae6:	01 d8                	add    %ebx,%eax
f0100ae8:	c1 e0 02             	shl    $0x2,%eax
f0100aeb:	8d 90 b4 1f 10 f0    	lea    -0xfefe04c(%eax),%edx
f0100af1:	8b 88 b4 1f 10 f0    	mov    -0xfefe04c(%eax),%ecx
f0100af7:	b8 c3 73 10 f0       	mov    $0xf01073c3,%eax
f0100afc:	2d a1 5a 10 f0       	sub    $0xf0105aa1,%eax
f0100b01:	39 c1                	cmp    %eax,%ecx
f0100b03:	73 09                	jae    f0100b0e <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100b05:	81 c1 a1 5a 10 f0    	add    $0xf0105aa1,%ecx
f0100b0b:	89 4e 08             	mov    %ecx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100b0e:	8b 42 08             	mov    0x8(%edx),%eax
f0100b11:	89 46 10             	mov    %eax,0x10(%esi)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100b14:	83 ec 08             	sub    $0x8,%esp
f0100b17:	6a 3a                	push   $0x3a
f0100b19:	ff 76 08             	pushl  0x8(%esi)
f0100b1c:	e8 b5 08 00 00       	call   f01013d6 <strfind>
f0100b21:	2b 46 08             	sub    0x8(%esi),%eax
f0100b24:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100b27:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100b2a:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100b2d:	01 d8                	add    %ebx,%eax
f0100b2f:	8d 04 85 b8 1f 10 f0 	lea    -0xfefe048(,%eax,4),%eax
f0100b36:	83 c4 10             	add    $0x10,%esp
f0100b39:	eb 20                	jmp    f0100b5b <debuginfo_eip+0x158>
  	        panic("User address");
f0100b3b:	83 ec 04             	sub    $0x4,%esp
f0100b3e:	68 86 1d 10 f0       	push   $0xf0101d86
f0100b43:	6a 7f                	push   $0x7f
f0100b45:	68 93 1d 10 f0       	push   $0xf0101d93
f0100b4a:	e8 df f5 ff ff       	call   f010012e <_panic>
		info->eip_fn_addr = addr;
f0100b4f:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100b52:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100b55:	eb bd                	jmp    f0100b14 <debuginfo_eip+0x111>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100b57:	4b                   	dec    %ebx
f0100b58:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0100b5b:	39 df                	cmp    %ebx,%edi
f0100b5d:	7f 34                	jg     f0100b93 <debuginfo_eip+0x190>
	       && stabs[lline].n_type != N_SOL
f0100b5f:	8a 10                	mov    (%eax),%dl
f0100b61:	80 fa 84             	cmp    $0x84,%dl
f0100b64:	74 0b                	je     f0100b71 <debuginfo_eip+0x16e>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100b66:	80 fa 64             	cmp    $0x64,%dl
f0100b69:	75 ec                	jne    f0100b57 <debuginfo_eip+0x154>
f0100b6b:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100b6f:	74 e6                	je     f0100b57 <debuginfo_eip+0x154>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100b71:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100b74:	01 c3                	add    %eax,%ebx
f0100b76:	8b 14 9d b4 1f 10 f0 	mov    -0xfefe04c(,%ebx,4),%edx
f0100b7d:	b8 c3 73 10 f0       	mov    $0xf01073c3,%eax
f0100b82:	2d a1 5a 10 f0       	sub    $0xf0105aa1,%eax
f0100b87:	39 c2                	cmp    %eax,%edx
f0100b89:	73 08                	jae    f0100b93 <debuginfo_eip+0x190>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100b8b:	81 c2 a1 5a 10 f0    	add    $0xf0105aa1,%edx
f0100b91:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100b93:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100b96:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100b99:	39 c8                	cmp    %ecx,%eax
f0100b9b:	7d 3e                	jge    f0100bdb <debuginfo_eip+0x1d8>
		for (lline = lfun + 1;
f0100b9d:	8d 50 01             	lea    0x1(%eax),%edx
f0100ba0:	8d 1c 00             	lea    (%eax,%eax,1),%ebx
f0100ba3:	01 d8                	add    %ebx,%eax
f0100ba5:	8d 04 85 c4 1f 10 f0 	lea    -0xfefe03c(,%eax,4),%eax
f0100bac:	eb 04                	jmp    f0100bb2 <debuginfo_eip+0x1af>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100bae:	ff 46 14             	incl   0x14(%esi)
		     lline++)
f0100bb1:	42                   	inc    %edx
		for (lline = lfun + 1;
f0100bb2:	39 d1                	cmp    %edx,%ecx
f0100bb4:	74 32                	je     f0100be8 <debuginfo_eip+0x1e5>
f0100bb6:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100bb9:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0100bbd:	74 ef                	je     f0100bae <debuginfo_eip+0x1ab>

	return 0;
f0100bbf:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bc4:	eb 1a                	jmp    f0100be0 <debuginfo_eip+0x1dd>
		return -1;
f0100bc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100bcb:	eb 13                	jmp    f0100be0 <debuginfo_eip+0x1dd>
f0100bcd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100bd2:	eb 0c                	jmp    f0100be0 <debuginfo_eip+0x1dd>
		return -1;
f0100bd4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100bd9:	eb 05                	jmp    f0100be0 <debuginfo_eip+0x1dd>
	return 0;
f0100bdb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100be0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100be3:	5b                   	pop    %ebx
f0100be4:	5e                   	pop    %esi
f0100be5:	5f                   	pop    %edi
f0100be6:	5d                   	pop    %ebp
f0100be7:	c3                   	ret    
	return 0;
f0100be8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bed:	eb f1                	jmp    f0100be0 <debuginfo_eip+0x1dd>

f0100bef <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100bef:	55                   	push   %ebp
f0100bf0:	89 e5                	mov    %esp,%ebp
f0100bf2:	57                   	push   %edi
f0100bf3:	56                   	push   %esi
f0100bf4:	53                   	push   %ebx
f0100bf5:	83 ec 1c             	sub    $0x1c,%esp
f0100bf8:	89 c7                	mov    %eax,%edi
f0100bfa:	89 d6                	mov    %edx,%esi
f0100bfc:	8b 45 08             	mov    0x8(%ebp),%eax
f0100bff:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100c02:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100c05:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100c08:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100c0b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100c10:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100c13:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100c16:	39 d3                	cmp    %edx,%ebx
f0100c18:	72 05                	jb     f0100c1f <printnum+0x30>
f0100c1a:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100c1d:	77 78                	ja     f0100c97 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100c1f:	83 ec 0c             	sub    $0xc,%esp
f0100c22:	ff 75 18             	pushl  0x18(%ebp)
f0100c25:	8b 45 14             	mov    0x14(%ebp),%eax
f0100c28:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100c2b:	53                   	push   %ebx
f0100c2c:	ff 75 10             	pushl  0x10(%ebp)
f0100c2f:	83 ec 08             	sub    $0x8,%esp
f0100c32:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100c35:	ff 75 e0             	pushl  -0x20(%ebp)
f0100c38:	ff 75 dc             	pushl  -0x24(%ebp)
f0100c3b:	ff 75 d8             	pushl  -0x28(%ebp)
f0100c3e:	e8 8d 09 00 00       	call   f01015d0 <__udivdi3>
f0100c43:	83 c4 18             	add    $0x18,%esp
f0100c46:	52                   	push   %edx
f0100c47:	50                   	push   %eax
f0100c48:	89 f2                	mov    %esi,%edx
f0100c4a:	89 f8                	mov    %edi,%eax
f0100c4c:	e8 9e ff ff ff       	call   f0100bef <printnum>
f0100c51:	83 c4 20             	add    $0x20,%esp
f0100c54:	eb 11                	jmp    f0100c67 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100c56:	83 ec 08             	sub    $0x8,%esp
f0100c59:	56                   	push   %esi
f0100c5a:	ff 75 18             	pushl  0x18(%ebp)
f0100c5d:	ff d7                	call   *%edi
f0100c5f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100c62:	4b                   	dec    %ebx
f0100c63:	85 db                	test   %ebx,%ebx
f0100c65:	7f ef                	jg     f0100c56 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100c67:	83 ec 08             	sub    $0x8,%esp
f0100c6a:	56                   	push   %esi
f0100c6b:	83 ec 04             	sub    $0x4,%esp
f0100c6e:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100c71:	ff 75 e0             	pushl  -0x20(%ebp)
f0100c74:	ff 75 dc             	pushl  -0x24(%ebp)
f0100c77:	ff 75 d8             	pushl  -0x28(%ebp)
f0100c7a:	e8 51 0a 00 00       	call   f01016d0 <__umoddi3>
f0100c7f:	83 c4 14             	add    $0x14,%esp
f0100c82:	0f be 80 a1 1d 10 f0 	movsbl -0xfefe25f(%eax),%eax
f0100c89:	50                   	push   %eax
f0100c8a:	ff d7                	call   *%edi
}
f0100c8c:	83 c4 10             	add    $0x10,%esp
f0100c8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c92:	5b                   	pop    %ebx
f0100c93:	5e                   	pop    %esi
f0100c94:	5f                   	pop    %edi
f0100c95:	5d                   	pop    %ebp
f0100c96:	c3                   	ret    
f0100c97:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100c9a:	eb c6                	jmp    f0100c62 <printnum+0x73>

f0100c9c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100c9c:	55                   	push   %ebp
f0100c9d:	89 e5                	mov    %esp,%ebp
f0100c9f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100ca2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0100ca5:	8b 10                	mov    (%eax),%edx
f0100ca7:	3b 50 04             	cmp    0x4(%eax),%edx
f0100caa:	73 0a                	jae    f0100cb6 <sprintputch+0x1a>
		*b->buf++ = ch;
f0100cac:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100caf:	89 08                	mov    %ecx,(%eax)
f0100cb1:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cb4:	88 02                	mov    %al,(%edx)
}
f0100cb6:	5d                   	pop    %ebp
f0100cb7:	c3                   	ret    

f0100cb8 <printfmt>:
{
f0100cb8:	55                   	push   %ebp
f0100cb9:	89 e5                	mov    %esp,%ebp
f0100cbb:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100cbe:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100cc1:	50                   	push   %eax
f0100cc2:	ff 75 10             	pushl  0x10(%ebp)
f0100cc5:	ff 75 0c             	pushl  0xc(%ebp)
f0100cc8:	ff 75 08             	pushl  0x8(%ebp)
f0100ccb:	e8 05 00 00 00       	call   f0100cd5 <vprintfmt>
}
f0100cd0:	83 c4 10             	add    $0x10,%esp
f0100cd3:	c9                   	leave  
f0100cd4:	c3                   	ret    

f0100cd5 <vprintfmt>:
{
f0100cd5:	55                   	push   %ebp
f0100cd6:	89 e5                	mov    %esp,%ebp
f0100cd8:	57                   	push   %edi
f0100cd9:	56                   	push   %esi
f0100cda:	53                   	push   %ebx
f0100cdb:	83 ec 2c             	sub    $0x2c,%esp
f0100cde:	8b 75 08             	mov    0x8(%ebp),%esi
f0100ce1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100ce4:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100ce7:	e9 ac 03 00 00       	jmp    f0101098 <vprintfmt+0x3c3>
		padc = ' ';
f0100cec:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0100cf0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0100cf7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f0100cfe:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0100d05:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0100d0a:	8d 47 01             	lea    0x1(%edi),%eax
f0100d0d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100d10:	8a 17                	mov    (%edi),%dl
f0100d12:	8d 42 dd             	lea    -0x23(%edx),%eax
f0100d15:	3c 55                	cmp    $0x55,%al
f0100d17:	0f 87 fc 03 00 00    	ja     f0101119 <vprintfmt+0x444>
f0100d1d:	0f b6 c0             	movzbl %al,%eax
f0100d20:	ff 24 85 30 1e 10 f0 	jmp    *-0xfefe1d0(,%eax,4)
f0100d27:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0100d2a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0100d2e:	eb da                	jmp    f0100d0a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0100d30:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0100d33:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100d37:	eb d1                	jmp    f0100d0a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0100d39:	0f b6 d2             	movzbl %dl,%edx
f0100d3c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0100d3f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d44:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0100d47:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100d4a:	01 c0                	add    %eax,%eax
f0100d4c:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
f0100d50:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0100d53:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0100d56:	83 f9 09             	cmp    $0x9,%ecx
f0100d59:	77 52                	ja     f0100dad <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
f0100d5b:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
f0100d5c:	eb e9                	jmp    f0100d47 <vprintfmt+0x72>
			precision = va_arg(ap, int);
f0100d5e:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d61:	8b 00                	mov    (%eax),%eax
f0100d63:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100d66:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d69:	8d 40 04             	lea    0x4(%eax),%eax
f0100d6c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100d6f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0100d72:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100d76:	79 92                	jns    f0100d0a <vprintfmt+0x35>
				width = precision, precision = -1;
f0100d78:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100d7b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100d7e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100d85:	eb 83                	jmp    f0100d0a <vprintfmt+0x35>
f0100d87:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100d8b:	78 08                	js     f0100d95 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
f0100d8d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100d90:	e9 75 ff ff ff       	jmp    f0100d0a <vprintfmt+0x35>
f0100d95:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0100d9c:	eb ef                	jmp    f0100d8d <vprintfmt+0xb8>
f0100d9e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0100da1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100da8:	e9 5d ff ff ff       	jmp    f0100d0a <vprintfmt+0x35>
f0100dad:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100db0:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100db3:	eb bd                	jmp    f0100d72 <vprintfmt+0x9d>
			lflag++;
f0100db5:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
f0100db6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0100db9:	e9 4c ff ff ff       	jmp    f0100d0a <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f0100dbe:	8b 45 14             	mov    0x14(%ebp),%eax
f0100dc1:	8d 78 04             	lea    0x4(%eax),%edi
f0100dc4:	83 ec 08             	sub    $0x8,%esp
f0100dc7:	53                   	push   %ebx
f0100dc8:	ff 30                	pushl  (%eax)
f0100dca:	ff d6                	call   *%esi
			break;
f0100dcc:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0100dcf:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0100dd2:	e9 be 02 00 00       	jmp    f0101095 <vprintfmt+0x3c0>
			err = va_arg(ap, int);
f0100dd7:	8b 45 14             	mov    0x14(%ebp),%eax
f0100dda:	8d 78 04             	lea    0x4(%eax),%edi
f0100ddd:	8b 00                	mov    (%eax),%eax
f0100ddf:	85 c0                	test   %eax,%eax
f0100de1:	78 2a                	js     f0100e0d <vprintfmt+0x138>
f0100de3:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100de5:	83 f8 06             	cmp    $0x6,%eax
f0100de8:	7f 27                	jg     f0100e11 <vprintfmt+0x13c>
f0100dea:	8b 04 85 88 1f 10 f0 	mov    -0xfefe078(,%eax,4),%eax
f0100df1:	85 c0                	test   %eax,%eax
f0100df3:	74 1c                	je     f0100e11 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
f0100df5:	50                   	push   %eax
f0100df6:	68 c2 1d 10 f0       	push   $0xf0101dc2
f0100dfb:	53                   	push   %ebx
f0100dfc:	56                   	push   %esi
f0100dfd:	e8 b6 fe ff ff       	call   f0100cb8 <printfmt>
f0100e02:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100e05:	89 7d 14             	mov    %edi,0x14(%ebp)
f0100e08:	e9 88 02 00 00       	jmp    f0101095 <vprintfmt+0x3c0>
f0100e0d:	f7 d8                	neg    %eax
f0100e0f:	eb d2                	jmp    f0100de3 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
f0100e11:	52                   	push   %edx
f0100e12:	68 b9 1d 10 f0       	push   $0xf0101db9
f0100e17:	53                   	push   %ebx
f0100e18:	56                   	push   %esi
f0100e19:	e8 9a fe ff ff       	call   f0100cb8 <printfmt>
f0100e1e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100e21:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0100e24:	e9 6c 02 00 00       	jmp    f0101095 <vprintfmt+0x3c0>
			if ((p = va_arg(ap, char *)) == NULL)
f0100e29:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e2c:	83 c0 04             	add    $0x4,%eax
f0100e2f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100e32:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e35:	8b 38                	mov    (%eax),%edi
f0100e37:	85 ff                	test   %edi,%edi
f0100e39:	74 18                	je     f0100e53 <vprintfmt+0x17e>
			if (width > 0 && padc != '-')
f0100e3b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100e3f:	0f 8e b7 00 00 00    	jle    f0100efc <vprintfmt+0x227>
f0100e45:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100e49:	75 0f                	jne    f0100e5a <vprintfmt+0x185>
f0100e4b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100e4e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100e51:	eb 6e                	jmp    f0100ec1 <vprintfmt+0x1ec>
				p = "(null)";
f0100e53:	bf b2 1d 10 f0       	mov    $0xf0101db2,%edi
f0100e58:	eb e1                	jmp    f0100e3b <vprintfmt+0x166>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100e5a:	83 ec 08             	sub    $0x8,%esp
f0100e5d:	ff 75 d0             	pushl  -0x30(%ebp)
f0100e60:	57                   	push   %edi
f0100e61:	e8 45 04 00 00       	call   f01012ab <strnlen>
f0100e66:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100e69:	29 c1                	sub    %eax,%ecx
f0100e6b:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0100e6e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0100e71:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0100e75:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100e78:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100e7b:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0100e7d:	eb 0d                	jmp    f0100e8c <vprintfmt+0x1b7>
					putch(padc, putdat);
f0100e7f:	83 ec 08             	sub    $0x8,%esp
f0100e82:	53                   	push   %ebx
f0100e83:	ff 75 e0             	pushl  -0x20(%ebp)
f0100e86:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0100e88:	4f                   	dec    %edi
f0100e89:	83 c4 10             	add    $0x10,%esp
f0100e8c:	85 ff                	test   %edi,%edi
f0100e8e:	7f ef                	jg     f0100e7f <vprintfmt+0x1aa>
f0100e90:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100e93:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0100e96:	89 c8                	mov    %ecx,%eax
f0100e98:	85 c9                	test   %ecx,%ecx
f0100e9a:	78 59                	js     f0100ef5 <vprintfmt+0x220>
f0100e9c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0100e9f:	29 c1                	sub    %eax,%ecx
f0100ea1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100ea4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100ea7:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100eaa:	eb 15                	jmp    f0100ec1 <vprintfmt+0x1ec>
				if (altflag && (ch < ' ' || ch > '~'))
f0100eac:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100eb0:	75 29                	jne    f0100edb <vprintfmt+0x206>
					putch(ch, putdat);
f0100eb2:	83 ec 08             	sub    $0x8,%esp
f0100eb5:	ff 75 0c             	pushl  0xc(%ebp)
f0100eb8:	50                   	push   %eax
f0100eb9:	ff d6                	call   *%esi
f0100ebb:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100ebe:	ff 4d e0             	decl   -0x20(%ebp)
f0100ec1:	47                   	inc    %edi
f0100ec2:	8a 57 ff             	mov    -0x1(%edi),%dl
f0100ec5:	0f be c2             	movsbl %dl,%eax
f0100ec8:	85 c0                	test   %eax,%eax
f0100eca:	74 53                	je     f0100f1f <vprintfmt+0x24a>
f0100ecc:	85 db                	test   %ebx,%ebx
f0100ece:	78 dc                	js     f0100eac <vprintfmt+0x1d7>
f0100ed0:	4b                   	dec    %ebx
f0100ed1:	79 d9                	jns    f0100eac <vprintfmt+0x1d7>
f0100ed3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100ed6:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100ed9:	eb 35                	jmp    f0100f10 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
f0100edb:	0f be d2             	movsbl %dl,%edx
f0100ede:	83 ea 20             	sub    $0x20,%edx
f0100ee1:	83 fa 5e             	cmp    $0x5e,%edx
f0100ee4:	76 cc                	jbe    f0100eb2 <vprintfmt+0x1dd>
					putch('?', putdat);
f0100ee6:	83 ec 08             	sub    $0x8,%esp
f0100ee9:	ff 75 0c             	pushl  0xc(%ebp)
f0100eec:	6a 3f                	push   $0x3f
f0100eee:	ff d6                	call   *%esi
f0100ef0:	83 c4 10             	add    $0x10,%esp
f0100ef3:	eb c9                	jmp    f0100ebe <vprintfmt+0x1e9>
f0100ef5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100efa:	eb a0                	jmp    f0100e9c <vprintfmt+0x1c7>
f0100efc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100eff:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100f02:	eb bd                	jmp    f0100ec1 <vprintfmt+0x1ec>
				putch(' ', putdat);
f0100f04:	83 ec 08             	sub    $0x8,%esp
f0100f07:	53                   	push   %ebx
f0100f08:	6a 20                	push   $0x20
f0100f0a:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0100f0c:	4f                   	dec    %edi
f0100f0d:	83 c4 10             	add    $0x10,%esp
f0100f10:	85 ff                	test   %edi,%edi
f0100f12:	7f f0                	jg     f0100f04 <vprintfmt+0x22f>
			if ((p = va_arg(ap, char *)) == NULL)
f0100f14:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0100f17:	89 45 14             	mov    %eax,0x14(%ebp)
f0100f1a:	e9 76 01 00 00       	jmp    f0101095 <vprintfmt+0x3c0>
f0100f1f:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100f22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100f25:	eb e9                	jmp    f0100f10 <vprintfmt+0x23b>
	if (lflag >= 2)
f0100f27:	83 f9 01             	cmp    $0x1,%ecx
f0100f2a:	7e 3f                	jle    f0100f6b <vprintfmt+0x296>
		return va_arg(*ap, long long);
f0100f2c:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f2f:	8b 50 04             	mov    0x4(%eax),%edx
f0100f32:	8b 00                	mov    (%eax),%eax
f0100f34:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f37:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100f3a:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f3d:	8d 40 08             	lea    0x8(%eax),%eax
f0100f40:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0100f43:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100f47:	79 5c                	jns    f0100fa5 <vprintfmt+0x2d0>
				putch('-', putdat);
f0100f49:	83 ec 08             	sub    $0x8,%esp
f0100f4c:	53                   	push   %ebx
f0100f4d:	6a 2d                	push   $0x2d
f0100f4f:	ff d6                	call   *%esi
				num = -(long long) num;
f0100f51:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100f54:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100f57:	f7 da                	neg    %edx
f0100f59:	83 d1 00             	adc    $0x0,%ecx
f0100f5c:	f7 d9                	neg    %ecx
f0100f5e:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0100f61:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100f66:	e9 10 01 00 00       	jmp    f010107b <vprintfmt+0x3a6>
	else if (lflag)
f0100f6b:	85 c9                	test   %ecx,%ecx
f0100f6d:	75 1b                	jne    f0100f8a <vprintfmt+0x2b5>
		return va_arg(*ap, int);
f0100f6f:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f72:	8b 00                	mov    (%eax),%eax
f0100f74:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f77:	89 c1                	mov    %eax,%ecx
f0100f79:	c1 f9 1f             	sar    $0x1f,%ecx
f0100f7c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100f7f:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f82:	8d 40 04             	lea    0x4(%eax),%eax
f0100f85:	89 45 14             	mov    %eax,0x14(%ebp)
f0100f88:	eb b9                	jmp    f0100f43 <vprintfmt+0x26e>
		return va_arg(*ap, long);
f0100f8a:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f8d:	8b 00                	mov    (%eax),%eax
f0100f8f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f92:	89 c1                	mov    %eax,%ecx
f0100f94:	c1 f9 1f             	sar    $0x1f,%ecx
f0100f97:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100f9a:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f9d:	8d 40 04             	lea    0x4(%eax),%eax
f0100fa0:	89 45 14             	mov    %eax,0x14(%ebp)
f0100fa3:	eb 9e                	jmp    f0100f43 <vprintfmt+0x26e>
			num = getint(&ap, lflag);
f0100fa5:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100fa8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0100fab:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100fb0:	e9 c6 00 00 00       	jmp    f010107b <vprintfmt+0x3a6>
	if (lflag >= 2)
f0100fb5:	83 f9 01             	cmp    $0x1,%ecx
f0100fb8:	7e 18                	jle    f0100fd2 <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
f0100fba:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fbd:	8b 10                	mov    (%eax),%edx
f0100fbf:	8b 48 04             	mov    0x4(%eax),%ecx
f0100fc2:	8d 40 08             	lea    0x8(%eax),%eax
f0100fc5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0100fc8:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100fcd:	e9 a9 00 00 00       	jmp    f010107b <vprintfmt+0x3a6>
	else if (lflag)
f0100fd2:	85 c9                	test   %ecx,%ecx
f0100fd4:	75 1a                	jne    f0100ff0 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned int);
f0100fd6:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fd9:	8b 10                	mov    (%eax),%edx
f0100fdb:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100fe0:	8d 40 04             	lea    0x4(%eax),%eax
f0100fe3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0100fe6:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100feb:	e9 8b 00 00 00       	jmp    f010107b <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0100ff0:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ff3:	8b 10                	mov    (%eax),%edx
f0100ff5:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100ffa:	8d 40 04             	lea    0x4(%eax),%eax
f0100ffd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101000:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101005:	eb 74                	jmp    f010107b <vprintfmt+0x3a6>
	if (lflag >= 2)
f0101007:	83 f9 01             	cmp    $0x1,%ecx
f010100a:	7e 15                	jle    f0101021 <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
f010100c:	8b 45 14             	mov    0x14(%ebp),%eax
f010100f:	8b 10                	mov    (%eax),%edx
f0101011:	8b 48 04             	mov    0x4(%eax),%ecx
f0101014:	8d 40 08             	lea    0x8(%eax),%eax
f0101017:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010101a:	b8 08 00 00 00       	mov    $0x8,%eax
f010101f:	eb 5a                	jmp    f010107b <vprintfmt+0x3a6>
	else if (lflag)
f0101021:	85 c9                	test   %ecx,%ecx
f0101023:	75 17                	jne    f010103c <vprintfmt+0x367>
		return va_arg(*ap, unsigned int);
f0101025:	8b 45 14             	mov    0x14(%ebp),%eax
f0101028:	8b 10                	mov    (%eax),%edx
f010102a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010102f:	8d 40 04             	lea    0x4(%eax),%eax
f0101032:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101035:	b8 08 00 00 00       	mov    $0x8,%eax
f010103a:	eb 3f                	jmp    f010107b <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f010103c:	8b 45 14             	mov    0x14(%ebp),%eax
f010103f:	8b 10                	mov    (%eax),%edx
f0101041:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101046:	8d 40 04             	lea    0x4(%eax),%eax
f0101049:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010104c:	b8 08 00 00 00       	mov    $0x8,%eax
f0101051:	eb 28                	jmp    f010107b <vprintfmt+0x3a6>
			putch('0', putdat);
f0101053:	83 ec 08             	sub    $0x8,%esp
f0101056:	53                   	push   %ebx
f0101057:	6a 30                	push   $0x30
f0101059:	ff d6                	call   *%esi
			putch('x', putdat);
f010105b:	83 c4 08             	add    $0x8,%esp
f010105e:	53                   	push   %ebx
f010105f:	6a 78                	push   $0x78
f0101061:	ff d6                	call   *%esi
			num = (unsigned long long)
f0101063:	8b 45 14             	mov    0x14(%ebp),%eax
f0101066:	8b 10                	mov    (%eax),%edx
f0101068:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010106d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0101070:	8d 40 04             	lea    0x4(%eax),%eax
f0101073:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101076:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f010107b:	83 ec 0c             	sub    $0xc,%esp
f010107e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0101082:	57                   	push   %edi
f0101083:	ff 75 e0             	pushl  -0x20(%ebp)
f0101086:	50                   	push   %eax
f0101087:	51                   	push   %ecx
f0101088:	52                   	push   %edx
f0101089:	89 da                	mov    %ebx,%edx
f010108b:	89 f0                	mov    %esi,%eax
f010108d:	e8 5d fb ff ff       	call   f0100bef <printnum>
			break;
f0101092:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0101095:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101098:	47                   	inc    %edi
f0101099:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010109d:	83 f8 25             	cmp    $0x25,%eax
f01010a0:	0f 84 46 fc ff ff    	je     f0100cec <vprintfmt+0x17>
			if (ch == '\0')
f01010a6:	85 c0                	test   %eax,%eax
f01010a8:	0f 84 89 00 00 00    	je     f0101137 <vprintfmt+0x462>
			putch(ch, putdat);
f01010ae:	83 ec 08             	sub    $0x8,%esp
f01010b1:	53                   	push   %ebx
f01010b2:	50                   	push   %eax
f01010b3:	ff d6                	call   *%esi
f01010b5:	83 c4 10             	add    $0x10,%esp
f01010b8:	eb de                	jmp    f0101098 <vprintfmt+0x3c3>
	if (lflag >= 2)
f01010ba:	83 f9 01             	cmp    $0x1,%ecx
f01010bd:	7e 15                	jle    f01010d4 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
f01010bf:	8b 45 14             	mov    0x14(%ebp),%eax
f01010c2:	8b 10                	mov    (%eax),%edx
f01010c4:	8b 48 04             	mov    0x4(%eax),%ecx
f01010c7:	8d 40 08             	lea    0x8(%eax),%eax
f01010ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01010cd:	b8 10 00 00 00       	mov    $0x10,%eax
f01010d2:	eb a7                	jmp    f010107b <vprintfmt+0x3a6>
	else if (lflag)
f01010d4:	85 c9                	test   %ecx,%ecx
f01010d6:	75 17                	jne    f01010ef <vprintfmt+0x41a>
		return va_arg(*ap, unsigned int);
f01010d8:	8b 45 14             	mov    0x14(%ebp),%eax
f01010db:	8b 10                	mov    (%eax),%edx
f01010dd:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010e2:	8d 40 04             	lea    0x4(%eax),%eax
f01010e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01010e8:	b8 10 00 00 00       	mov    $0x10,%eax
f01010ed:	eb 8c                	jmp    f010107b <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f01010ef:	8b 45 14             	mov    0x14(%ebp),%eax
f01010f2:	8b 10                	mov    (%eax),%edx
f01010f4:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010f9:	8d 40 04             	lea    0x4(%eax),%eax
f01010fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01010ff:	b8 10 00 00 00       	mov    $0x10,%eax
f0101104:	e9 72 ff ff ff       	jmp    f010107b <vprintfmt+0x3a6>
			putch(ch, putdat);
f0101109:	83 ec 08             	sub    $0x8,%esp
f010110c:	53                   	push   %ebx
f010110d:	6a 25                	push   $0x25
f010110f:	ff d6                	call   *%esi
			break;
f0101111:	83 c4 10             	add    $0x10,%esp
f0101114:	e9 7c ff ff ff       	jmp    f0101095 <vprintfmt+0x3c0>
			putch('%', putdat);
f0101119:	83 ec 08             	sub    $0x8,%esp
f010111c:	53                   	push   %ebx
f010111d:	6a 25                	push   $0x25
f010111f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101121:	83 c4 10             	add    $0x10,%esp
f0101124:	89 f8                	mov    %edi,%eax
f0101126:	eb 01                	jmp    f0101129 <vprintfmt+0x454>
f0101128:	48                   	dec    %eax
f0101129:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010112d:	75 f9                	jne    f0101128 <vprintfmt+0x453>
f010112f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101132:	e9 5e ff ff ff       	jmp    f0101095 <vprintfmt+0x3c0>
}
f0101137:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010113a:	5b                   	pop    %ebx
f010113b:	5e                   	pop    %esi
f010113c:	5f                   	pop    %edi
f010113d:	5d                   	pop    %ebp
f010113e:	c3                   	ret    

f010113f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010113f:	55                   	push   %ebp
f0101140:	89 e5                	mov    %esp,%ebp
f0101142:	83 ec 18             	sub    $0x18,%esp
f0101145:	8b 45 08             	mov    0x8(%ebp),%eax
f0101148:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010114b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010114e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101152:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101155:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010115c:	85 c0                	test   %eax,%eax
f010115e:	74 26                	je     f0101186 <vsnprintf+0x47>
f0101160:	85 d2                	test   %edx,%edx
f0101162:	7e 29                	jle    f010118d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101164:	ff 75 14             	pushl  0x14(%ebp)
f0101167:	ff 75 10             	pushl  0x10(%ebp)
f010116a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010116d:	50                   	push   %eax
f010116e:	68 9c 0c 10 f0       	push   $0xf0100c9c
f0101173:	e8 5d fb ff ff       	call   f0100cd5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101178:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010117b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010117e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101181:	83 c4 10             	add    $0x10,%esp
}
f0101184:	c9                   	leave  
f0101185:	c3                   	ret    
		return -E_INVAL;
f0101186:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010118b:	eb f7                	jmp    f0101184 <vsnprintf+0x45>
f010118d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101192:	eb f0                	jmp    f0101184 <vsnprintf+0x45>

f0101194 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101194:	55                   	push   %ebp
f0101195:	89 e5                	mov    %esp,%ebp
f0101197:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010119a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010119d:	50                   	push   %eax
f010119e:	ff 75 10             	pushl  0x10(%ebp)
f01011a1:	ff 75 0c             	pushl  0xc(%ebp)
f01011a4:	ff 75 08             	pushl  0x8(%ebp)
f01011a7:	e8 93 ff ff ff       	call   f010113f <vsnprintf>
	va_end(ap);

	return rc;
}
f01011ac:	c9                   	leave  
f01011ad:	c3                   	ret    

f01011ae <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01011ae:	55                   	push   %ebp
f01011af:	89 e5                	mov    %esp,%ebp
f01011b1:	57                   	push   %edi
f01011b2:	56                   	push   %esi
f01011b3:	53                   	push   %ebx
f01011b4:	83 ec 0c             	sub    $0xc,%esp
f01011b7:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01011ba:	85 c0                	test   %eax,%eax
f01011bc:	74 11                	je     f01011cf <readline+0x21>
		cprintf("%s", prompt);
f01011be:	83 ec 08             	sub    $0x8,%esp
f01011c1:	50                   	push   %eax
f01011c2:	68 c2 1d 10 f0       	push   $0xf0101dc2
f01011c7:	e8 36 f7 ff ff       	call   f0100902 <cprintf>
f01011cc:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01011cf:	83 ec 0c             	sub    $0xc,%esp
f01011d2:	6a 00                	push   $0x0
f01011d4:	e8 c9 f4 ff ff       	call   f01006a2 <iscons>
f01011d9:	89 c7                	mov    %eax,%edi
f01011db:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01011de:	be 00 00 00 00       	mov    $0x0,%esi
f01011e3:	eb 6f                	jmp    f0101254 <readline+0xa6>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01011e5:	83 ec 08             	sub    $0x8,%esp
f01011e8:	50                   	push   %eax
f01011e9:	68 a4 1f 10 f0       	push   $0xf0101fa4
f01011ee:	e8 0f f7 ff ff       	call   f0100902 <cprintf>
			return NULL;
f01011f3:	83 c4 10             	add    $0x10,%esp
f01011f6:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01011fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011fe:	5b                   	pop    %ebx
f01011ff:	5e                   	pop    %esi
f0101200:	5f                   	pop    %edi
f0101201:	5d                   	pop    %ebp
f0101202:	c3                   	ret    
				cputchar('\b');
f0101203:	83 ec 0c             	sub    $0xc,%esp
f0101206:	6a 08                	push   $0x8
f0101208:	e8 74 f4 ff ff       	call   f0100681 <cputchar>
f010120d:	83 c4 10             	add    $0x10,%esp
f0101210:	eb 41                	jmp    f0101253 <readline+0xa5>
				cputchar(c);
f0101212:	83 ec 0c             	sub    $0xc,%esp
f0101215:	53                   	push   %ebx
f0101216:	e8 66 f4 ff ff       	call   f0100681 <cputchar>
f010121b:	83 c4 10             	add    $0x10,%esp
f010121e:	eb 5a                	jmp    f010127a <readline+0xcc>
		} else if (c == '\n' || c == '\r') {
f0101220:	83 fb 0a             	cmp    $0xa,%ebx
f0101223:	74 05                	je     f010122a <readline+0x7c>
f0101225:	83 fb 0d             	cmp    $0xd,%ebx
f0101228:	75 2a                	jne    f0101254 <readline+0xa6>
			if (echoing)
f010122a:	85 ff                	test   %edi,%edi
f010122c:	75 0e                	jne    f010123c <readline+0x8e>
			buf[i] = 0;
f010122e:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f0101235:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
f010123a:	eb bf                	jmp    f01011fb <readline+0x4d>
				cputchar('\n');
f010123c:	83 ec 0c             	sub    $0xc,%esp
f010123f:	6a 0a                	push   $0xa
f0101241:	e8 3b f4 ff ff       	call   f0100681 <cputchar>
f0101246:	83 c4 10             	add    $0x10,%esp
f0101249:	eb e3                	jmp    f010122e <readline+0x80>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010124b:	85 f6                	test   %esi,%esi
f010124d:	7e 3c                	jle    f010128b <readline+0xdd>
			if (echoing)
f010124f:	85 ff                	test   %edi,%edi
f0101251:	75 b0                	jne    f0101203 <readline+0x55>
			i--;
f0101253:	4e                   	dec    %esi
		c = getchar();
f0101254:	e8 38 f4 ff ff       	call   f0100691 <getchar>
f0101259:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010125b:	85 c0                	test   %eax,%eax
f010125d:	78 86                	js     f01011e5 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010125f:	83 f8 08             	cmp    $0x8,%eax
f0101262:	74 21                	je     f0101285 <readline+0xd7>
f0101264:	83 f8 7f             	cmp    $0x7f,%eax
f0101267:	74 e2                	je     f010124b <readline+0x9d>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101269:	83 f8 1f             	cmp    $0x1f,%eax
f010126c:	7e b2                	jle    f0101220 <readline+0x72>
f010126e:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101274:	7f aa                	jg     f0101220 <readline+0x72>
			if (echoing)
f0101276:	85 ff                	test   %edi,%edi
f0101278:	75 98                	jne    f0101212 <readline+0x64>
			buf[i++] = c;
f010127a:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f0101280:	8d 76 01             	lea    0x1(%esi),%esi
f0101283:	eb cf                	jmp    f0101254 <readline+0xa6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101285:	85 f6                	test   %esi,%esi
f0101287:	7e cb                	jle    f0101254 <readline+0xa6>
f0101289:	eb c4                	jmp    f010124f <readline+0xa1>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010128b:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101291:	7e e3                	jle    f0101276 <readline+0xc8>
f0101293:	eb bf                	jmp    f0101254 <readline+0xa6>

f0101295 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101295:	55                   	push   %ebp
f0101296:	89 e5                	mov    %esp,%ebp
f0101298:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010129b:	b8 00 00 00 00       	mov    $0x0,%eax
f01012a0:	eb 01                	jmp    f01012a3 <strlen+0xe>
		n++;
f01012a2:	40                   	inc    %eax
	for (n = 0; *s != '\0'; s++)
f01012a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01012a7:	75 f9                	jne    f01012a2 <strlen+0xd>
	return n;
}
f01012a9:	5d                   	pop    %ebp
f01012aa:	c3                   	ret    

f01012ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01012ab:	55                   	push   %ebp
f01012ac:	89 e5                	mov    %esp,%ebp
f01012ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01012b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012b4:	b8 00 00 00 00       	mov    $0x0,%eax
f01012b9:	eb 01                	jmp    f01012bc <strnlen+0x11>
		n++;
f01012bb:	40                   	inc    %eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012bc:	39 d0                	cmp    %edx,%eax
f01012be:	74 06                	je     f01012c6 <strnlen+0x1b>
f01012c0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01012c4:	75 f5                	jne    f01012bb <strnlen+0x10>
	return n;
}
f01012c6:	5d                   	pop    %ebp
f01012c7:	c3                   	ret    

f01012c8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01012c8:	55                   	push   %ebp
f01012c9:	89 e5                	mov    %esp,%ebp
f01012cb:	53                   	push   %ebx
f01012cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01012cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01012d2:	89 c2                	mov    %eax,%edx
f01012d4:	41                   	inc    %ecx
f01012d5:	42                   	inc    %edx
f01012d6:	8a 59 ff             	mov    -0x1(%ecx),%bl
f01012d9:	88 5a ff             	mov    %bl,-0x1(%edx)
f01012dc:	84 db                	test   %bl,%bl
f01012de:	75 f4                	jne    f01012d4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01012e0:	5b                   	pop    %ebx
f01012e1:	5d                   	pop    %ebp
f01012e2:	c3                   	ret    

f01012e3 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01012e3:	55                   	push   %ebp
f01012e4:	89 e5                	mov    %esp,%ebp
f01012e6:	53                   	push   %ebx
f01012e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01012ea:	53                   	push   %ebx
f01012eb:	e8 a5 ff ff ff       	call   f0101295 <strlen>
f01012f0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01012f3:	ff 75 0c             	pushl  0xc(%ebp)
f01012f6:	01 d8                	add    %ebx,%eax
f01012f8:	50                   	push   %eax
f01012f9:	e8 ca ff ff ff       	call   f01012c8 <strcpy>
	return dst;
}
f01012fe:	89 d8                	mov    %ebx,%eax
f0101300:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101303:	c9                   	leave  
f0101304:	c3                   	ret    

f0101305 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101305:	55                   	push   %ebp
f0101306:	89 e5                	mov    %esp,%ebp
f0101308:	56                   	push   %esi
f0101309:	53                   	push   %ebx
f010130a:	8b 75 08             	mov    0x8(%ebp),%esi
f010130d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101310:	89 f3                	mov    %esi,%ebx
f0101312:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101315:	89 f2                	mov    %esi,%edx
f0101317:	39 da                	cmp    %ebx,%edx
f0101319:	74 0e                	je     f0101329 <strncpy+0x24>
		*dst++ = *src;
f010131b:	42                   	inc    %edx
f010131c:	8a 01                	mov    (%ecx),%al
f010131e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f0101321:	80 39 00             	cmpb   $0x0,(%ecx)
f0101324:	74 f1                	je     f0101317 <strncpy+0x12>
			src++;
f0101326:	41                   	inc    %ecx
f0101327:	eb ee                	jmp    f0101317 <strncpy+0x12>
	}
	return ret;
}
f0101329:	89 f0                	mov    %esi,%eax
f010132b:	5b                   	pop    %ebx
f010132c:	5e                   	pop    %esi
f010132d:	5d                   	pop    %ebp
f010132e:	c3                   	ret    

f010132f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010132f:	55                   	push   %ebp
f0101330:	89 e5                	mov    %esp,%ebp
f0101332:	56                   	push   %esi
f0101333:	53                   	push   %ebx
f0101334:	8b 75 08             	mov    0x8(%ebp),%esi
f0101337:	8b 55 0c             	mov    0xc(%ebp),%edx
f010133a:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010133d:	85 c0                	test   %eax,%eax
f010133f:	74 20                	je     f0101361 <strlcpy+0x32>
f0101341:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
f0101345:	89 f0                	mov    %esi,%eax
f0101347:	eb 05                	jmp    f010134e <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101349:	42                   	inc    %edx
f010134a:	40                   	inc    %eax
f010134b:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f010134e:	39 d8                	cmp    %ebx,%eax
f0101350:	74 06                	je     f0101358 <strlcpy+0x29>
f0101352:	8a 0a                	mov    (%edx),%cl
f0101354:	84 c9                	test   %cl,%cl
f0101356:	75 f1                	jne    f0101349 <strlcpy+0x1a>
		*dst = '\0';
f0101358:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010135b:	29 f0                	sub    %esi,%eax
}
f010135d:	5b                   	pop    %ebx
f010135e:	5e                   	pop    %esi
f010135f:	5d                   	pop    %ebp
f0101360:	c3                   	ret    
f0101361:	89 f0                	mov    %esi,%eax
f0101363:	eb f6                	jmp    f010135b <strlcpy+0x2c>

f0101365 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101365:	55                   	push   %ebp
f0101366:	89 e5                	mov    %esp,%ebp
f0101368:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010136b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010136e:	eb 02                	jmp    f0101372 <strcmp+0xd>
		p++, q++;
f0101370:	41                   	inc    %ecx
f0101371:	42                   	inc    %edx
	while (*p && *p == *q)
f0101372:	8a 01                	mov    (%ecx),%al
f0101374:	84 c0                	test   %al,%al
f0101376:	74 04                	je     f010137c <strcmp+0x17>
f0101378:	3a 02                	cmp    (%edx),%al
f010137a:	74 f4                	je     f0101370 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010137c:	0f b6 c0             	movzbl %al,%eax
f010137f:	0f b6 12             	movzbl (%edx),%edx
f0101382:	29 d0                	sub    %edx,%eax
}
f0101384:	5d                   	pop    %ebp
f0101385:	c3                   	ret    

f0101386 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101386:	55                   	push   %ebp
f0101387:	89 e5                	mov    %esp,%ebp
f0101389:	53                   	push   %ebx
f010138a:	8b 45 08             	mov    0x8(%ebp),%eax
f010138d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101390:	89 c3                	mov    %eax,%ebx
f0101392:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101395:	eb 02                	jmp    f0101399 <strncmp+0x13>
		n--, p++, q++;
f0101397:	40                   	inc    %eax
f0101398:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
f0101399:	39 d8                	cmp    %ebx,%eax
f010139b:	74 15                	je     f01013b2 <strncmp+0x2c>
f010139d:	8a 08                	mov    (%eax),%cl
f010139f:	84 c9                	test   %cl,%cl
f01013a1:	74 04                	je     f01013a7 <strncmp+0x21>
f01013a3:	3a 0a                	cmp    (%edx),%cl
f01013a5:	74 f0                	je     f0101397 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01013a7:	0f b6 00             	movzbl (%eax),%eax
f01013aa:	0f b6 12             	movzbl (%edx),%edx
f01013ad:	29 d0                	sub    %edx,%eax
}
f01013af:	5b                   	pop    %ebx
f01013b0:	5d                   	pop    %ebp
f01013b1:	c3                   	ret    
		return 0;
f01013b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01013b7:	eb f6                	jmp    f01013af <strncmp+0x29>

f01013b9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01013b9:	55                   	push   %ebp
f01013ba:	89 e5                	mov    %esp,%ebp
f01013bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01013bf:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01013c2:	8a 10                	mov    (%eax),%dl
f01013c4:	84 d2                	test   %dl,%dl
f01013c6:	74 07                	je     f01013cf <strchr+0x16>
		if (*s == c)
f01013c8:	38 ca                	cmp    %cl,%dl
f01013ca:	74 08                	je     f01013d4 <strchr+0x1b>
	for (; *s; s++)
f01013cc:	40                   	inc    %eax
f01013cd:	eb f3                	jmp    f01013c2 <strchr+0x9>
			return (char *) s;
	return 0;
f01013cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01013d4:	5d                   	pop    %ebp
f01013d5:	c3                   	ret    

f01013d6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01013d6:	55                   	push   %ebp
f01013d7:	89 e5                	mov    %esp,%ebp
f01013d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01013dc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01013df:	8a 10                	mov    (%eax),%dl
f01013e1:	84 d2                	test   %dl,%dl
f01013e3:	74 07                	je     f01013ec <strfind+0x16>
		if (*s == c)
f01013e5:	38 ca                	cmp    %cl,%dl
f01013e7:	74 03                	je     f01013ec <strfind+0x16>
	for (; *s; s++)
f01013e9:	40                   	inc    %eax
f01013ea:	eb f3                	jmp    f01013df <strfind+0x9>
			break;
	return (char *) s;
}
f01013ec:	5d                   	pop    %ebp
f01013ed:	c3                   	ret    

f01013ee <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01013ee:	55                   	push   %ebp
f01013ef:	89 e5                	mov    %esp,%ebp
f01013f1:	57                   	push   %edi
f01013f2:	56                   	push   %esi
f01013f3:	53                   	push   %ebx
f01013f4:	8b 7d 08             	mov    0x8(%ebp),%edi
f01013f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01013fa:	85 c9                	test   %ecx,%ecx
f01013fc:	74 13                	je     f0101411 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01013fe:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101404:	75 05                	jne    f010140b <memset+0x1d>
f0101406:	f6 c1 03             	test   $0x3,%cl
f0101409:	74 0d                	je     f0101418 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010140b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010140e:	fc                   	cld    
f010140f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101411:	89 f8                	mov    %edi,%eax
f0101413:	5b                   	pop    %ebx
f0101414:	5e                   	pop    %esi
f0101415:	5f                   	pop    %edi
f0101416:	5d                   	pop    %ebp
f0101417:	c3                   	ret    
		c &= 0xFF;
f0101418:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010141c:	89 d3                	mov    %edx,%ebx
f010141e:	c1 e3 08             	shl    $0x8,%ebx
f0101421:	89 d0                	mov    %edx,%eax
f0101423:	c1 e0 18             	shl    $0x18,%eax
f0101426:	89 d6                	mov    %edx,%esi
f0101428:	c1 e6 10             	shl    $0x10,%esi
f010142b:	09 f0                	or     %esi,%eax
f010142d:	09 c2                	or     %eax,%edx
f010142f:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0101431:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0101434:	89 d0                	mov    %edx,%eax
f0101436:	fc                   	cld    
f0101437:	f3 ab                	rep stos %eax,%es:(%edi)
f0101439:	eb d6                	jmp    f0101411 <memset+0x23>

f010143b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010143b:	55                   	push   %ebp
f010143c:	89 e5                	mov    %esp,%ebp
f010143e:	57                   	push   %edi
f010143f:	56                   	push   %esi
f0101440:	8b 45 08             	mov    0x8(%ebp),%eax
f0101443:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101446:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101449:	39 c6                	cmp    %eax,%esi
f010144b:	73 33                	jae    f0101480 <memmove+0x45>
f010144d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101450:	39 c2                	cmp    %eax,%edx
f0101452:	76 2c                	jbe    f0101480 <memmove+0x45>
		s += n;
		d += n;
f0101454:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101457:	89 d6                	mov    %edx,%esi
f0101459:	09 fe                	or     %edi,%esi
f010145b:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101461:	74 0a                	je     f010146d <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101463:	4f                   	dec    %edi
f0101464:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0101467:	fd                   	std    
f0101468:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010146a:	fc                   	cld    
f010146b:	eb 21                	jmp    f010148e <memmove+0x53>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010146d:	f6 c1 03             	test   $0x3,%cl
f0101470:	75 f1                	jne    f0101463 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101472:	83 ef 04             	sub    $0x4,%edi
f0101475:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101478:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f010147b:	fd                   	std    
f010147c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010147e:	eb ea                	jmp    f010146a <memmove+0x2f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101480:	89 f2                	mov    %esi,%edx
f0101482:	09 c2                	or     %eax,%edx
f0101484:	f6 c2 03             	test   $0x3,%dl
f0101487:	74 09                	je     f0101492 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101489:	89 c7                	mov    %eax,%edi
f010148b:	fc                   	cld    
f010148c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010148e:	5e                   	pop    %esi
f010148f:	5f                   	pop    %edi
f0101490:	5d                   	pop    %ebp
f0101491:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101492:	f6 c1 03             	test   $0x3,%cl
f0101495:	75 f2                	jne    f0101489 <memmove+0x4e>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101497:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f010149a:	89 c7                	mov    %eax,%edi
f010149c:	fc                   	cld    
f010149d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010149f:	eb ed                	jmp    f010148e <memmove+0x53>

f01014a1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01014a1:	55                   	push   %ebp
f01014a2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01014a4:	ff 75 10             	pushl  0x10(%ebp)
f01014a7:	ff 75 0c             	pushl  0xc(%ebp)
f01014aa:	ff 75 08             	pushl  0x8(%ebp)
f01014ad:	e8 89 ff ff ff       	call   f010143b <memmove>
}
f01014b2:	c9                   	leave  
f01014b3:	c3                   	ret    

f01014b4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01014b4:	55                   	push   %ebp
f01014b5:	89 e5                	mov    %esp,%ebp
f01014b7:	56                   	push   %esi
f01014b8:	53                   	push   %ebx
f01014b9:	8b 45 08             	mov    0x8(%ebp),%eax
f01014bc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01014bf:	89 c6                	mov    %eax,%esi
f01014c1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01014c4:	39 f0                	cmp    %esi,%eax
f01014c6:	74 16                	je     f01014de <memcmp+0x2a>
		if (*s1 != *s2)
f01014c8:	8a 08                	mov    (%eax),%cl
f01014ca:	8a 1a                	mov    (%edx),%bl
f01014cc:	38 d9                	cmp    %bl,%cl
f01014ce:	75 04                	jne    f01014d4 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01014d0:	40                   	inc    %eax
f01014d1:	42                   	inc    %edx
f01014d2:	eb f0                	jmp    f01014c4 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f01014d4:	0f b6 c1             	movzbl %cl,%eax
f01014d7:	0f b6 db             	movzbl %bl,%ebx
f01014da:	29 d8                	sub    %ebx,%eax
f01014dc:	eb 05                	jmp    f01014e3 <memcmp+0x2f>
	}

	return 0;
f01014de:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01014e3:	5b                   	pop    %ebx
f01014e4:	5e                   	pop    %esi
f01014e5:	5d                   	pop    %ebp
f01014e6:	c3                   	ret    

f01014e7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01014e7:	55                   	push   %ebp
f01014e8:	89 e5                	mov    %esp,%ebp
f01014ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01014ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01014f0:	89 c2                	mov    %eax,%edx
f01014f2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01014f5:	39 d0                	cmp    %edx,%eax
f01014f7:	73 07                	jae    f0101500 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
f01014f9:	38 08                	cmp    %cl,(%eax)
f01014fb:	74 03                	je     f0101500 <memfind+0x19>
	for (; s < ends; s++)
f01014fd:	40                   	inc    %eax
f01014fe:	eb f5                	jmp    f01014f5 <memfind+0xe>
			break;
	return (void *) s;
}
f0101500:	5d                   	pop    %ebp
f0101501:	c3                   	ret    

f0101502 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101502:	55                   	push   %ebp
f0101503:	89 e5                	mov    %esp,%ebp
f0101505:	57                   	push   %edi
f0101506:	56                   	push   %esi
f0101507:	53                   	push   %ebx
f0101508:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010150b:	eb 01                	jmp    f010150e <strtol+0xc>
		s++;
f010150d:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f010150e:	8a 01                	mov    (%ecx),%al
f0101510:	3c 20                	cmp    $0x20,%al
f0101512:	74 f9                	je     f010150d <strtol+0xb>
f0101514:	3c 09                	cmp    $0x9,%al
f0101516:	74 f5                	je     f010150d <strtol+0xb>

	// plus/minus sign
	if (*s == '+')
f0101518:	3c 2b                	cmp    $0x2b,%al
f010151a:	74 2b                	je     f0101547 <strtol+0x45>
		s++;
	else if (*s == '-')
f010151c:	3c 2d                	cmp    $0x2d,%al
f010151e:	74 2f                	je     f010154f <strtol+0x4d>
	int neg = 0;
f0101520:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101525:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f010152c:	75 12                	jne    f0101540 <strtol+0x3e>
f010152e:	80 39 30             	cmpb   $0x30,(%ecx)
f0101531:	74 24                	je     f0101557 <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101533:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101537:	75 07                	jne    f0101540 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101539:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f0101540:	b8 00 00 00 00       	mov    $0x0,%eax
f0101545:	eb 4e                	jmp    f0101595 <strtol+0x93>
		s++;
f0101547:	41                   	inc    %ecx
	int neg = 0;
f0101548:	bf 00 00 00 00       	mov    $0x0,%edi
f010154d:	eb d6                	jmp    f0101525 <strtol+0x23>
		s++, neg = 1;
f010154f:	41                   	inc    %ecx
f0101550:	bf 01 00 00 00       	mov    $0x1,%edi
f0101555:	eb ce                	jmp    f0101525 <strtol+0x23>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101557:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010155b:	74 10                	je     f010156d <strtol+0x6b>
	else if (base == 0 && s[0] == '0')
f010155d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101561:	75 dd                	jne    f0101540 <strtol+0x3e>
		s++, base = 8;
f0101563:	41                   	inc    %ecx
f0101564:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f010156b:	eb d3                	jmp    f0101540 <strtol+0x3e>
		s += 2, base = 16;
f010156d:	83 c1 02             	add    $0x2,%ecx
f0101570:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f0101577:	eb c7                	jmp    f0101540 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0101579:	8d 72 9f             	lea    -0x61(%edx),%esi
f010157c:	89 f3                	mov    %esi,%ebx
f010157e:	80 fb 19             	cmp    $0x19,%bl
f0101581:	77 24                	ja     f01015a7 <strtol+0xa5>
			dig = *s - 'a' + 10;
f0101583:	0f be d2             	movsbl %dl,%edx
f0101586:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101589:	3b 55 10             	cmp    0x10(%ebp),%edx
f010158c:	7d 2b                	jge    f01015b9 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
f010158e:	41                   	inc    %ecx
f010158f:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101593:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0101595:	8a 11                	mov    (%ecx),%dl
f0101597:	8d 5a d0             	lea    -0x30(%edx),%ebx
f010159a:	80 fb 09             	cmp    $0x9,%bl
f010159d:	77 da                	ja     f0101579 <strtol+0x77>
			dig = *s - '0';
f010159f:	0f be d2             	movsbl %dl,%edx
f01015a2:	83 ea 30             	sub    $0x30,%edx
f01015a5:	eb e2                	jmp    f0101589 <strtol+0x87>
		else if (*s >= 'A' && *s <= 'Z')
f01015a7:	8d 72 bf             	lea    -0x41(%edx),%esi
f01015aa:	89 f3                	mov    %esi,%ebx
f01015ac:	80 fb 19             	cmp    $0x19,%bl
f01015af:	77 08                	ja     f01015b9 <strtol+0xb7>
			dig = *s - 'A' + 10;
f01015b1:	0f be d2             	movsbl %dl,%edx
f01015b4:	83 ea 37             	sub    $0x37,%edx
f01015b7:	eb d0                	jmp    f0101589 <strtol+0x87>
		// we don't properly detect overflow!
	}

	if (endptr)
f01015b9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01015bd:	74 05                	je     f01015c4 <strtol+0xc2>
		*endptr = (char *) s;
f01015bf:	8b 75 0c             	mov    0xc(%ebp),%esi
f01015c2:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f01015c4:	85 ff                	test   %edi,%edi
f01015c6:	74 02                	je     f01015ca <strtol+0xc8>
f01015c8:	f7 d8                	neg    %eax
}
f01015ca:	5b                   	pop    %ebx
f01015cb:	5e                   	pop    %esi
f01015cc:	5f                   	pop    %edi
f01015cd:	5d                   	pop    %ebp
f01015ce:	c3                   	ret    
f01015cf:	90                   	nop

f01015d0 <__udivdi3>:
f01015d0:	55                   	push   %ebp
f01015d1:	57                   	push   %edi
f01015d2:	56                   	push   %esi
f01015d3:	53                   	push   %ebx
f01015d4:	83 ec 1c             	sub    $0x1c,%esp
f01015d7:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01015db:	8b 74 24 34          	mov    0x34(%esp),%esi
f01015df:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01015e3:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01015e7:	85 d2                	test   %edx,%edx
f01015e9:	75 2d                	jne    f0101618 <__udivdi3+0x48>
f01015eb:	39 f7                	cmp    %esi,%edi
f01015ed:	77 59                	ja     f0101648 <__udivdi3+0x78>
f01015ef:	89 f9                	mov    %edi,%ecx
f01015f1:	85 ff                	test   %edi,%edi
f01015f3:	75 0b                	jne    f0101600 <__udivdi3+0x30>
f01015f5:	b8 01 00 00 00       	mov    $0x1,%eax
f01015fa:	31 d2                	xor    %edx,%edx
f01015fc:	f7 f7                	div    %edi
f01015fe:	89 c1                	mov    %eax,%ecx
f0101600:	31 d2                	xor    %edx,%edx
f0101602:	89 f0                	mov    %esi,%eax
f0101604:	f7 f1                	div    %ecx
f0101606:	89 c3                	mov    %eax,%ebx
f0101608:	89 e8                	mov    %ebp,%eax
f010160a:	f7 f1                	div    %ecx
f010160c:	89 da                	mov    %ebx,%edx
f010160e:	83 c4 1c             	add    $0x1c,%esp
f0101611:	5b                   	pop    %ebx
f0101612:	5e                   	pop    %esi
f0101613:	5f                   	pop    %edi
f0101614:	5d                   	pop    %ebp
f0101615:	c3                   	ret    
f0101616:	66 90                	xchg   %ax,%ax
f0101618:	39 f2                	cmp    %esi,%edx
f010161a:	77 1c                	ja     f0101638 <__udivdi3+0x68>
f010161c:	0f bd da             	bsr    %edx,%ebx
f010161f:	83 f3 1f             	xor    $0x1f,%ebx
f0101622:	75 38                	jne    f010165c <__udivdi3+0x8c>
f0101624:	39 f2                	cmp    %esi,%edx
f0101626:	72 08                	jb     f0101630 <__udivdi3+0x60>
f0101628:	39 ef                	cmp    %ebp,%edi
f010162a:	0f 87 98 00 00 00    	ja     f01016c8 <__udivdi3+0xf8>
f0101630:	b8 01 00 00 00       	mov    $0x1,%eax
f0101635:	eb 05                	jmp    f010163c <__udivdi3+0x6c>
f0101637:	90                   	nop
f0101638:	31 db                	xor    %ebx,%ebx
f010163a:	31 c0                	xor    %eax,%eax
f010163c:	89 da                	mov    %ebx,%edx
f010163e:	83 c4 1c             	add    $0x1c,%esp
f0101641:	5b                   	pop    %ebx
f0101642:	5e                   	pop    %esi
f0101643:	5f                   	pop    %edi
f0101644:	5d                   	pop    %ebp
f0101645:	c3                   	ret    
f0101646:	66 90                	xchg   %ax,%ax
f0101648:	89 e8                	mov    %ebp,%eax
f010164a:	89 f2                	mov    %esi,%edx
f010164c:	f7 f7                	div    %edi
f010164e:	31 db                	xor    %ebx,%ebx
f0101650:	89 da                	mov    %ebx,%edx
f0101652:	83 c4 1c             	add    $0x1c,%esp
f0101655:	5b                   	pop    %ebx
f0101656:	5e                   	pop    %esi
f0101657:	5f                   	pop    %edi
f0101658:	5d                   	pop    %ebp
f0101659:	c3                   	ret    
f010165a:	66 90                	xchg   %ax,%ax
f010165c:	b8 20 00 00 00       	mov    $0x20,%eax
f0101661:	29 d8                	sub    %ebx,%eax
f0101663:	88 d9                	mov    %bl,%cl
f0101665:	d3 e2                	shl    %cl,%edx
f0101667:	89 54 24 08          	mov    %edx,0x8(%esp)
f010166b:	89 fa                	mov    %edi,%edx
f010166d:	88 c1                	mov    %al,%cl
f010166f:	d3 ea                	shr    %cl,%edx
f0101671:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101675:	09 d1                	or     %edx,%ecx
f0101677:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010167b:	88 d9                	mov    %bl,%cl
f010167d:	d3 e7                	shl    %cl,%edi
f010167f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101683:	89 f7                	mov    %esi,%edi
f0101685:	88 c1                	mov    %al,%cl
f0101687:	d3 ef                	shr    %cl,%edi
f0101689:	88 d9                	mov    %bl,%cl
f010168b:	d3 e6                	shl    %cl,%esi
f010168d:	89 ea                	mov    %ebp,%edx
f010168f:	88 c1                	mov    %al,%cl
f0101691:	d3 ea                	shr    %cl,%edx
f0101693:	09 d6                	or     %edx,%esi
f0101695:	89 f0                	mov    %esi,%eax
f0101697:	89 fa                	mov    %edi,%edx
f0101699:	f7 74 24 08          	divl   0x8(%esp)
f010169d:	89 d7                	mov    %edx,%edi
f010169f:	89 c6                	mov    %eax,%esi
f01016a1:	f7 64 24 0c          	mull   0xc(%esp)
f01016a5:	39 d7                	cmp    %edx,%edi
f01016a7:	72 13                	jb     f01016bc <__udivdi3+0xec>
f01016a9:	74 09                	je     f01016b4 <__udivdi3+0xe4>
f01016ab:	89 f0                	mov    %esi,%eax
f01016ad:	31 db                	xor    %ebx,%ebx
f01016af:	eb 8b                	jmp    f010163c <__udivdi3+0x6c>
f01016b1:	8d 76 00             	lea    0x0(%esi),%esi
f01016b4:	88 d9                	mov    %bl,%cl
f01016b6:	d3 e5                	shl    %cl,%ebp
f01016b8:	39 c5                	cmp    %eax,%ebp
f01016ba:	73 ef                	jae    f01016ab <__udivdi3+0xdb>
f01016bc:	8d 46 ff             	lea    -0x1(%esi),%eax
f01016bf:	31 db                	xor    %ebx,%ebx
f01016c1:	e9 76 ff ff ff       	jmp    f010163c <__udivdi3+0x6c>
f01016c6:	66 90                	xchg   %ax,%ax
f01016c8:	31 c0                	xor    %eax,%eax
f01016ca:	e9 6d ff ff ff       	jmp    f010163c <__udivdi3+0x6c>
f01016cf:	90                   	nop

f01016d0 <__umoddi3>:
f01016d0:	55                   	push   %ebp
f01016d1:	57                   	push   %edi
f01016d2:	56                   	push   %esi
f01016d3:	53                   	push   %ebx
f01016d4:	83 ec 1c             	sub    $0x1c,%esp
f01016d7:	8b 74 24 30          	mov    0x30(%esp),%esi
f01016db:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01016df:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01016e3:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f01016e7:	89 f0                	mov    %esi,%eax
f01016e9:	89 da                	mov    %ebx,%edx
f01016eb:	85 ed                	test   %ebp,%ebp
f01016ed:	75 15                	jne    f0101704 <__umoddi3+0x34>
f01016ef:	39 df                	cmp    %ebx,%edi
f01016f1:	76 39                	jbe    f010172c <__umoddi3+0x5c>
f01016f3:	f7 f7                	div    %edi
f01016f5:	89 d0                	mov    %edx,%eax
f01016f7:	31 d2                	xor    %edx,%edx
f01016f9:	83 c4 1c             	add    $0x1c,%esp
f01016fc:	5b                   	pop    %ebx
f01016fd:	5e                   	pop    %esi
f01016fe:	5f                   	pop    %edi
f01016ff:	5d                   	pop    %ebp
f0101700:	c3                   	ret    
f0101701:	8d 76 00             	lea    0x0(%esi),%esi
f0101704:	39 dd                	cmp    %ebx,%ebp
f0101706:	77 f1                	ja     f01016f9 <__umoddi3+0x29>
f0101708:	0f bd cd             	bsr    %ebp,%ecx
f010170b:	83 f1 1f             	xor    $0x1f,%ecx
f010170e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101712:	75 38                	jne    f010174c <__umoddi3+0x7c>
f0101714:	39 dd                	cmp    %ebx,%ebp
f0101716:	72 04                	jb     f010171c <__umoddi3+0x4c>
f0101718:	39 f7                	cmp    %esi,%edi
f010171a:	77 dd                	ja     f01016f9 <__umoddi3+0x29>
f010171c:	89 da                	mov    %ebx,%edx
f010171e:	89 f0                	mov    %esi,%eax
f0101720:	29 f8                	sub    %edi,%eax
f0101722:	19 ea                	sbb    %ebp,%edx
f0101724:	83 c4 1c             	add    $0x1c,%esp
f0101727:	5b                   	pop    %ebx
f0101728:	5e                   	pop    %esi
f0101729:	5f                   	pop    %edi
f010172a:	5d                   	pop    %ebp
f010172b:	c3                   	ret    
f010172c:	89 f9                	mov    %edi,%ecx
f010172e:	85 ff                	test   %edi,%edi
f0101730:	75 0b                	jne    f010173d <__umoddi3+0x6d>
f0101732:	b8 01 00 00 00       	mov    $0x1,%eax
f0101737:	31 d2                	xor    %edx,%edx
f0101739:	f7 f7                	div    %edi
f010173b:	89 c1                	mov    %eax,%ecx
f010173d:	89 d8                	mov    %ebx,%eax
f010173f:	31 d2                	xor    %edx,%edx
f0101741:	f7 f1                	div    %ecx
f0101743:	89 f0                	mov    %esi,%eax
f0101745:	f7 f1                	div    %ecx
f0101747:	eb ac                	jmp    f01016f5 <__umoddi3+0x25>
f0101749:	8d 76 00             	lea    0x0(%esi),%esi
f010174c:	b8 20 00 00 00       	mov    $0x20,%eax
f0101751:	89 c2                	mov    %eax,%edx
f0101753:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101757:	29 c2                	sub    %eax,%edx
f0101759:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010175d:	88 c1                	mov    %al,%cl
f010175f:	d3 e5                	shl    %cl,%ebp
f0101761:	89 f8                	mov    %edi,%eax
f0101763:	88 d1                	mov    %dl,%cl
f0101765:	d3 e8                	shr    %cl,%eax
f0101767:	09 c5                	or     %eax,%ebp
f0101769:	8b 44 24 04          	mov    0x4(%esp),%eax
f010176d:	88 c1                	mov    %al,%cl
f010176f:	d3 e7                	shl    %cl,%edi
f0101771:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101775:	89 df                	mov    %ebx,%edi
f0101777:	88 d1                	mov    %dl,%cl
f0101779:	d3 ef                	shr    %cl,%edi
f010177b:	88 c1                	mov    %al,%cl
f010177d:	d3 e3                	shl    %cl,%ebx
f010177f:	89 f0                	mov    %esi,%eax
f0101781:	88 d1                	mov    %dl,%cl
f0101783:	d3 e8                	shr    %cl,%eax
f0101785:	09 d8                	or     %ebx,%eax
f0101787:	8a 4c 24 04          	mov    0x4(%esp),%cl
f010178b:	d3 e6                	shl    %cl,%esi
f010178d:	89 fa                	mov    %edi,%edx
f010178f:	f7 f5                	div    %ebp
f0101791:	89 d1                	mov    %edx,%ecx
f0101793:	f7 64 24 08          	mull   0x8(%esp)
f0101797:	89 c3                	mov    %eax,%ebx
f0101799:	89 d7                	mov    %edx,%edi
f010179b:	39 d1                	cmp    %edx,%ecx
f010179d:	72 29                	jb     f01017c8 <__umoddi3+0xf8>
f010179f:	74 23                	je     f01017c4 <__umoddi3+0xf4>
f01017a1:	89 ca                	mov    %ecx,%edx
f01017a3:	29 de                	sub    %ebx,%esi
f01017a5:	19 fa                	sbb    %edi,%edx
f01017a7:	89 d0                	mov    %edx,%eax
f01017a9:	8a 4c 24 0c          	mov    0xc(%esp),%cl
f01017ad:	d3 e0                	shl    %cl,%eax
f01017af:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f01017b3:	88 d9                	mov    %bl,%cl
f01017b5:	d3 ee                	shr    %cl,%esi
f01017b7:	09 f0                	or     %esi,%eax
f01017b9:	d3 ea                	shr    %cl,%edx
f01017bb:	83 c4 1c             	add    $0x1c,%esp
f01017be:	5b                   	pop    %ebx
f01017bf:	5e                   	pop    %esi
f01017c0:	5f                   	pop    %edi
f01017c1:	5d                   	pop    %ebp
f01017c2:	c3                   	ret    
f01017c3:	90                   	nop
f01017c4:	39 c6                	cmp    %eax,%esi
f01017c6:	73 d9                	jae    f01017a1 <__umoddi3+0xd1>
f01017c8:	2b 44 24 08          	sub    0x8(%esp),%eax
f01017cc:	19 ea                	sbb    %ebp,%edx
f01017ce:	89 d7                	mov    %edx,%edi
f01017d0:	89 c3                	mov    %eax,%ebx
f01017d2:	eb cd                	jmp    f01017a1 <__umoddi3+0xd1>
