
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
f010004b:	68 20 18 10 f0       	push   $0xf0101820
f0100050:	e8 e8 08 00 00       	call   f010093d <cprintf>
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
f0100071:	68 3c 18 10 f0       	push   $0xf010183c
f0100076:	e8 c2 08 00 00       	call   f010093d <cprintf>
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
f01000ac:	e8 78 13 00 00       	call   f0101429 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 d3 04 00 00       	call   f0100589 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 57 18 10 f0       	push   $0xf0101857
f01000c3:	e8 75 08 00 00       	call   f010093d <cprintf>

	cprintf(ANSI_COLOR_RED     "This text is RED!"     ANSI_COLOR_RESET "\n");
f01000c8:	c7 04 24 72 18 10 f0 	movl   $0xf0101872,(%esp)
f01000cf:	e8 69 08 00 00       	call   f010093d <cprintf>
	cprintf(ANSI_COLOR_GREEN   "This text is GREEN!"   ANSI_COLOR_RESET "\n");
f01000d4:	c7 04 24 8e 18 10 f0 	movl   $0xf010188e,(%esp)
f01000db:	e8 5d 08 00 00       	call   f010093d <cprintf>
	cprintf(ANSI_COLOR_YELLOW  "This text is YELLOW!"  ANSI_COLOR_RESET "\n");
f01000e0:	c7 04 24 18 19 10 f0 	movl   $0xf0101918,(%esp)
f01000e7:	e8 51 08 00 00       	call   f010093d <cprintf>
	cprintf(ANSI_COLOR_BLUE    "This text is BLUE!"    ANSI_COLOR_RESET "\n");
f01000ec:	c7 04 24 ac 18 10 f0 	movl   $0xf01018ac,(%esp)
f01000f3:	e8 45 08 00 00       	call   f010093d <cprintf>
	cprintf(ANSI_COLOR_MAGENTA "This text is MAGENTA!" ANSI_COLOR_RESET "\n");
f01000f8:	c7 04 24 38 19 10 f0 	movl   $0xf0101938,(%esp)
f01000ff:	e8 39 08 00 00       	call   f010093d <cprintf>
	cprintf(ANSI_COLOR_CYAN    "This text is CYAN!"    ANSI_COLOR_RESET "\n");
f0100104:	c7 04 24 c9 18 10 f0 	movl   $0xf01018c9,(%esp)
f010010b:	e8 2d 08 00 00       	call   f010093d <cprintf>

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
f0100124:	e8 a0 06 00 00       	call   f01007c9 <monitor>
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
f0100144:	e8 80 06 00 00       	call   f01007c9 <monitor>
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
f0100162:	68 e6 18 10 f0       	push   $0xf01018e6
f0100167:	e8 d1 07 00 00       	call   f010093d <cprintf>
	vcprintf(fmt, ap);
f010016c:	83 c4 08             	add    $0x8,%esp
f010016f:	53                   	push   %ebx
f0100170:	56                   	push   %esi
f0100171:	e8 a1 07 00 00       	call   f0100917 <vcprintf>
	cprintf("\n");
f0100176:	c7 04 24 62 19 10 f0 	movl   $0xf0101962,(%esp)
f010017d:	e8 bb 07 00 00       	call   f010093d <cprintf>
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
f0100197:	68 fe 18 10 f0       	push   $0xf01018fe
f010019c:	e8 9c 07 00 00       	call   f010093d <cprintf>
	vcprintf(fmt, ap);
f01001a1:	83 c4 08             	add    $0x8,%esp
f01001a4:	53                   	push   %ebx
f01001a5:	ff 75 10             	pushl  0x10(%ebp)
f01001a8:	e8 6a 07 00 00       	call   f0100917 <vcprintf>
	cprintf("\n");
f01001ad:	c7 04 24 62 19 10 f0 	movl   $0xf0101962,(%esp)
f01001b4:	e8 84 07 00 00       	call   f010093d <cprintf>
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
f0100274:	0f b6 82 c0 1a 10 f0 	movzbl -0xfefe540(%edx),%eax
f010027b:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
	shift ^= togglecode[data];
f0100281:	0f b6 8a c0 19 10 f0 	movzbl -0xfefe640(%edx),%ecx
f0100288:	31 c8                	xor    %ecx,%eax
f010028a:	a3 00 23 11 f0       	mov    %eax,0xf0112300
	c = charcode[shift & (CTL | SHIFT)][data];
f010028f:	89 c1                	mov    %eax,%ecx
f0100291:	83 e1 03             	and    $0x3,%ecx
f0100294:	8b 0c 8d a0 19 10 f0 	mov    -0xfefe660(,%ecx,4),%ecx
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
f01002c3:	68 58 19 10 f0       	push   $0xf0101958
f01002c8:	e8 70 06 00 00       	call   f010093d <cprintf>
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
f0100300:	8a 82 c0 1a 10 f0    	mov    -0xfefe540(%edx),%al
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
f01004de:	e8 93 0f 00 00       	call   f0101476 <memmove>
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
f0100672:	68 64 19 10 f0       	push   $0xf0101964
f0100677:	e8 c1 02 00 00       	call   f010093d <cprintf>
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
f01006b2:	68 c0 1b 10 f0       	push   $0xf0101bc0
f01006b7:	68 de 1b 10 f0       	push   $0xf0101bde
f01006bc:	68 e3 1b 10 f0       	push   $0xf0101be3
f01006c1:	e8 77 02 00 00       	call   f010093d <cprintf>
f01006c6:	83 c4 0c             	add    $0xc,%esp
f01006c9:	68 5c 1c 10 f0       	push   $0xf0101c5c
f01006ce:	68 ec 1b 10 f0       	push   $0xf0101bec
f01006d3:	68 e3 1b 10 f0       	push   $0xf0101be3
f01006d8:	e8 60 02 00 00       	call   f010093d <cprintf>
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
f01006ea:	68 f5 1b 10 f0       	push   $0xf0101bf5
f01006ef:	e8 49 02 00 00       	call   f010093d <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006f4:	83 c4 08             	add    $0x8,%esp
f01006f7:	68 0c 00 10 00       	push   $0x10000c
f01006fc:	68 84 1c 10 f0       	push   $0xf0101c84
f0100701:	e8 37 02 00 00       	call   f010093d <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100706:	83 c4 0c             	add    $0xc,%esp
f0100709:	68 0c 00 10 00       	push   $0x10000c
f010070e:	68 0c 00 10 f0       	push   $0xf010000c
f0100713:	68 ac 1c 10 f0       	push   $0xf0101cac
f0100718:	e8 20 02 00 00       	call   f010093d <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010071d:	83 c4 0c             	add    $0xc,%esp
f0100720:	68 10 18 10 00       	push   $0x101810
f0100725:	68 10 18 10 f0       	push   $0xf0101810
f010072a:	68 d0 1c 10 f0       	push   $0xf0101cd0
f010072f:	e8 09 02 00 00       	call   f010093d <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100734:	83 c4 0c             	add    $0xc,%esp
f0100737:	68 00 23 11 00       	push   $0x112300
f010073c:	68 00 23 11 f0       	push   $0xf0112300
f0100741:	68 f4 1c 10 f0       	push   $0xf0101cf4
f0100746:	e8 f2 01 00 00       	call   f010093d <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010074b:	83 c4 0c             	add    $0xc,%esp
f010074e:	68 44 29 11 00       	push   $0x112944
f0100753:	68 44 29 11 f0       	push   $0xf0112944
f0100758:	68 18 1d 10 f0       	push   $0xf0101d18
f010075d:	e8 db 01 00 00       	call   f010093d <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100762:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100765:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
f010076a:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f010076f:	c1 f8 0a             	sar    $0xa,%eax
f0100772:	50                   	push   %eax
f0100773:	68 3c 1d 10 f0       	push   $0xf0101d3c
f0100778:	e8 c0 01 00 00       	call   f010093d <cprintf>
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
f0100787:	53                   	push   %ebx
f0100788:	83 ec 10             	sub    $0x10,%esp
	cprintf("Stack backtrace:\n");
f010078b:	68 0e 1c 10 f0       	push   $0xf0101c0e
f0100790:	e8 a8 01 00 00       	call   f010093d <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100795:	89 e8                	mov    %ebp,%eax
	uint32_t ebp = read_ebp(), prev_ebp, eip;
	while (ebp != 0) {
f0100797:	83 c4 10             	add    $0x10,%esp
f010079a:	eb 24                	jmp    f01007c0 <mon_backtrace+0x3c>
		prev_ebp = *(int*)ebp;
f010079c:	8b 18                	mov    (%eax),%ebx
		eip = *((int*)ebp + 1);
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, 
f010079e:	ff 70 18             	pushl  0x18(%eax)
f01007a1:	ff 70 14             	pushl  0x14(%eax)
f01007a4:	ff 70 10             	pushl  0x10(%eax)
f01007a7:	ff 70 0c             	pushl  0xc(%eax)
f01007aa:	ff 70 08             	pushl  0x8(%eax)
f01007ad:	ff 70 04             	pushl  0x4(%eax)
f01007b0:	50                   	push   %eax
f01007b1:	68 68 1d 10 f0       	push   $0xf0101d68
f01007b6:	e8 82 01 00 00       	call   f010093d <cprintf>
				*((int*)ebp + 2), *((int*)ebp + 3), *((int*)ebp + 4), 
				*((int*)ebp + 5), *((int*)ebp + 6));
		ebp = prev_ebp;
f01007bb:	83 c4 20             	add    $0x20,%esp
f01007be:	89 d8                	mov    %ebx,%eax
	while (ebp != 0) {
f01007c0:	85 c0                	test   %eax,%eax
f01007c2:	75 d8                	jne    f010079c <mon_backtrace+0x18>
	}
	return 0;
}
f01007c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01007c7:	c9                   	leave  
f01007c8:	c3                   	ret    

f01007c9 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007c9:	55                   	push   %ebp
f01007ca:	89 e5                	mov    %esp,%ebp
f01007cc:	57                   	push   %edi
f01007cd:	56                   	push   %esi
f01007ce:	53                   	push   %ebx
f01007cf:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007d2:	68 a0 1d 10 f0       	push   $0xf0101da0
f01007d7:	e8 61 01 00 00       	call   f010093d <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007dc:	c7 04 24 c4 1d 10 f0 	movl   $0xf0101dc4,(%esp)
f01007e3:	e8 55 01 00 00       	call   f010093d <cprintf>
f01007e8:	83 c4 10             	add    $0x10,%esp
f01007eb:	eb 47                	jmp    f0100834 <monitor+0x6b>
		while (*buf && strchr(WHITESPACE, *buf))
f01007ed:	83 ec 08             	sub    $0x8,%esp
f01007f0:	0f be c0             	movsbl %al,%eax
f01007f3:	50                   	push   %eax
f01007f4:	68 24 1c 10 f0       	push   $0xf0101c24
f01007f9:	e8 f6 0b 00 00       	call   f01013f4 <strchr>
f01007fe:	83 c4 10             	add    $0x10,%esp
f0100801:	85 c0                	test   %eax,%eax
f0100803:	74 0a                	je     f010080f <monitor+0x46>
			*buf++ = 0;
f0100805:	c6 03 00             	movb   $0x0,(%ebx)
f0100808:	89 f7                	mov    %esi,%edi
f010080a:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010080d:	eb 68                	jmp    f0100877 <monitor+0xae>
		if (*buf == 0)
f010080f:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100812:	74 6f                	je     f0100883 <monitor+0xba>
		if (argc == MAXARGS-1) {
f0100814:	83 fe 0f             	cmp    $0xf,%esi
f0100817:	74 09                	je     f0100822 <monitor+0x59>
		argv[argc++] = buf;
f0100819:	8d 7e 01             	lea    0x1(%esi),%edi
f010081c:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100820:	eb 37                	jmp    f0100859 <monitor+0x90>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100822:	83 ec 08             	sub    $0x8,%esp
f0100825:	6a 10                	push   $0x10
f0100827:	68 29 1c 10 f0       	push   $0xf0101c29
f010082c:	e8 0c 01 00 00       	call   f010093d <cprintf>
f0100831:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100834:	83 ec 0c             	sub    $0xc,%esp
f0100837:	68 20 1c 10 f0       	push   $0xf0101c20
f010083c:	e8 a8 09 00 00       	call   f01011e9 <readline>
f0100841:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100843:	83 c4 10             	add    $0x10,%esp
f0100846:	85 c0                	test   %eax,%eax
f0100848:	74 ea                	je     f0100834 <monitor+0x6b>
	argv[argc] = 0;
f010084a:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100851:	be 00 00 00 00       	mov    $0x0,%esi
f0100856:	eb 21                	jmp    f0100879 <monitor+0xb0>
			buf++;
f0100858:	43                   	inc    %ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100859:	8a 03                	mov    (%ebx),%al
f010085b:	84 c0                	test   %al,%al
f010085d:	74 18                	je     f0100877 <monitor+0xae>
f010085f:	83 ec 08             	sub    $0x8,%esp
f0100862:	0f be c0             	movsbl %al,%eax
f0100865:	50                   	push   %eax
f0100866:	68 24 1c 10 f0       	push   $0xf0101c24
f010086b:	e8 84 0b 00 00       	call   f01013f4 <strchr>
f0100870:	83 c4 10             	add    $0x10,%esp
f0100873:	85 c0                	test   %eax,%eax
f0100875:	74 e1                	je     f0100858 <monitor+0x8f>
			*buf++ = 0;
f0100877:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100879:	8a 03                	mov    (%ebx),%al
f010087b:	84 c0                	test   %al,%al
f010087d:	0f 85 6a ff ff ff    	jne    f01007ed <monitor+0x24>
	argv[argc] = 0;
f0100883:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f010088a:	00 
	if (argc == 0)
f010088b:	85 f6                	test   %esi,%esi
f010088d:	74 a5                	je     f0100834 <monitor+0x6b>
		if (strcmp(argv[0], commands[i].name) == 0)
f010088f:	83 ec 08             	sub    $0x8,%esp
f0100892:	68 de 1b 10 f0       	push   $0xf0101bde
f0100897:	ff 75 a8             	pushl  -0x58(%ebp)
f010089a:	e8 01 0b 00 00       	call   f01013a0 <strcmp>
f010089f:	83 c4 10             	add    $0x10,%esp
f01008a2:	85 c0                	test   %eax,%eax
f01008a4:	74 34                	je     f01008da <monitor+0x111>
f01008a6:	83 ec 08             	sub    $0x8,%esp
f01008a9:	68 ec 1b 10 f0       	push   $0xf0101bec
f01008ae:	ff 75 a8             	pushl  -0x58(%ebp)
f01008b1:	e8 ea 0a 00 00       	call   f01013a0 <strcmp>
f01008b6:	83 c4 10             	add    $0x10,%esp
f01008b9:	85 c0                	test   %eax,%eax
f01008bb:	74 18                	je     f01008d5 <monitor+0x10c>
	cprintf("Unknown command '%s'\n", argv[0]);
f01008bd:	83 ec 08             	sub    $0x8,%esp
f01008c0:	ff 75 a8             	pushl  -0x58(%ebp)
f01008c3:	68 46 1c 10 f0       	push   $0xf0101c46
f01008c8:	e8 70 00 00 00       	call   f010093d <cprintf>
f01008cd:	83 c4 10             	add    $0x10,%esp
f01008d0:	e9 5f ff ff ff       	jmp    f0100834 <monitor+0x6b>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01008d5:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f01008da:	83 ec 04             	sub    $0x4,%esp
f01008dd:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01008e0:	01 d0                	add    %edx,%eax
f01008e2:	ff 75 08             	pushl  0x8(%ebp)
f01008e5:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f01008e8:	51                   	push   %ecx
f01008e9:	56                   	push   %esi
f01008ea:	ff 14 85 f4 1d 10 f0 	call   *-0xfefe20c(,%eax,4)
			if (runcmd(buf, tf) < 0)
f01008f1:	83 c4 10             	add    $0x10,%esp
f01008f4:	85 c0                	test   %eax,%eax
f01008f6:	0f 89 38 ff ff ff    	jns    f0100834 <monitor+0x6b>
				break;
	}
}
f01008fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008ff:	5b                   	pop    %ebx
f0100900:	5e                   	pop    %esi
f0100901:	5f                   	pop    %edi
f0100902:	5d                   	pop    %ebp
f0100903:	c3                   	ret    

f0100904 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100904:	55                   	push   %ebp
f0100905:	89 e5                	mov    %esp,%ebp
f0100907:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010090a:	ff 75 08             	pushl  0x8(%ebp)
f010090d:	e8 6f fd ff ff       	call   f0100681 <cputchar>
	*cnt++;
}
f0100912:	83 c4 10             	add    $0x10,%esp
f0100915:	c9                   	leave  
f0100916:	c3                   	ret    

f0100917 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100917:	55                   	push   %ebp
f0100918:	89 e5                	mov    %esp,%ebp
f010091a:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010091d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100924:	ff 75 0c             	pushl  0xc(%ebp)
f0100927:	ff 75 08             	pushl  0x8(%ebp)
f010092a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010092d:	50                   	push   %eax
f010092e:	68 04 09 10 f0       	push   $0xf0100904
f0100933:	e8 d8 03 00 00       	call   f0100d10 <vprintfmt>
	return cnt;
}
f0100938:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010093b:	c9                   	leave  
f010093c:	c3                   	ret    

f010093d <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010093d:	55                   	push   %ebp
f010093e:	89 e5                	mov    %esp,%ebp
f0100940:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100943:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100946:	50                   	push   %eax
f0100947:	ff 75 08             	pushl  0x8(%ebp)
f010094a:	e8 c8 ff ff ff       	call   f0100917 <vcprintf>
	va_end(ap);

	return cnt;
}
f010094f:	c9                   	leave  
f0100950:	c3                   	ret    

f0100951 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100951:	55                   	push   %ebp
f0100952:	89 e5                	mov    %esp,%ebp
f0100954:	57                   	push   %edi
f0100955:	56                   	push   %esi
f0100956:	53                   	push   %ebx
f0100957:	83 ec 14             	sub    $0x14,%esp
f010095a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010095d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100960:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100963:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100966:	8b 32                	mov    (%edx),%esi
f0100968:	8b 01                	mov    (%ecx),%eax
f010096a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010096d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100974:	eb 2f                	jmp    f01009a5 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100976:	48                   	dec    %eax
		while (m >= l && stabs[m].n_type != type)
f0100977:	39 c6                	cmp    %eax,%esi
f0100979:	7f 4d                	jg     f01009c8 <stab_binsearch+0x77>
f010097b:	0f b6 0a             	movzbl (%edx),%ecx
f010097e:	83 ea 0c             	sub    $0xc,%edx
f0100981:	39 f9                	cmp    %edi,%ecx
f0100983:	75 f1                	jne    f0100976 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100985:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100988:	01 c2                	add    %eax,%edx
f010098a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010098d:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100991:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100994:	73 37                	jae    f01009cd <stab_binsearch+0x7c>
			*region_left = m;
f0100996:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100999:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f010099b:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f010099e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f01009a5:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f01009a8:	7f 4d                	jg     f01009f7 <stab_binsearch+0xa6>
		int true_m = (l + r) / 2, m = true_m;
f01009aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01009ad:	01 f0                	add    %esi,%eax
f01009af:	89 c3                	mov    %eax,%ebx
f01009b1:	c1 eb 1f             	shr    $0x1f,%ebx
f01009b4:	01 c3                	add    %eax,%ebx
f01009b6:	d1 fb                	sar    %ebx
f01009b8:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f01009bb:	01 d8                	add    %ebx,%eax
f01009bd:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01009c0:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f01009c4:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f01009c6:	eb af                	jmp    f0100977 <stab_binsearch+0x26>
			l = true_m + 1;
f01009c8:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f01009cb:	eb d8                	jmp    f01009a5 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f01009cd:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01009d0:	76 12                	jbe    f01009e4 <stab_binsearch+0x93>
			*region_right = m - 1;
f01009d2:	48                   	dec    %eax
f01009d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01009d6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01009d9:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f01009db:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01009e2:	eb c1                	jmp    f01009a5 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01009e4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01009e7:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01009e9:	ff 45 0c             	incl   0xc(%ebp)
f01009ec:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f01009ee:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01009f5:	eb ae                	jmp    f01009a5 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f01009f7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01009fb:	74 18                	je     f0100a15 <stab_binsearch+0xc4>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01009fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a00:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100a02:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a05:	8b 0e                	mov    (%esi),%ecx
f0100a07:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100a0a:	01 c2                	add    %eax,%edx
f0100a0c:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100a0f:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0100a13:	eb 0e                	jmp    f0100a23 <stab_binsearch+0xd2>
		*region_right = *region_left - 1;
f0100a15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a18:	8b 00                	mov    (%eax),%eax
f0100a1a:	48                   	dec    %eax
f0100a1b:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100a1e:	89 07                	mov    %eax,(%edi)
f0100a20:	eb 14                	jmp    f0100a36 <stab_binsearch+0xe5>
		     l--)
f0100a22:	48                   	dec    %eax
		for (l = *region_right;
f0100a23:	39 c1                	cmp    %eax,%ecx
f0100a25:	7d 0a                	jge    f0100a31 <stab_binsearch+0xe0>
		     l > *region_left && stabs[l].n_type != type;
f0100a27:	0f b6 1a             	movzbl (%edx),%ebx
f0100a2a:	83 ea 0c             	sub    $0xc,%edx
f0100a2d:	39 fb                	cmp    %edi,%ebx
f0100a2f:	75 f1                	jne    f0100a22 <stab_binsearch+0xd1>
			/* do nothing */;
		*region_left = l;
f0100a31:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100a34:	89 07                	mov    %eax,(%edi)
	}
}
f0100a36:	83 c4 14             	add    $0x14,%esp
f0100a39:	5b                   	pop    %ebx
f0100a3a:	5e                   	pop    %esi
f0100a3b:	5f                   	pop    %edi
f0100a3c:	5d                   	pop    %ebp
f0100a3d:	c3                   	ret    

f0100a3e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100a3e:	55                   	push   %ebp
f0100a3f:	89 e5                	mov    %esp,%ebp
f0100a41:	57                   	push   %edi
f0100a42:	56                   	push   %esi
f0100a43:	53                   	push   %ebx
f0100a44:	83 ec 1c             	sub    $0x1c,%esp
f0100a47:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100a4a:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100a4d:	c7 06 04 1e 10 f0    	movl   $0xf0101e04,(%esi)
	info->eip_line = 0;
f0100a53:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100a5a:	c7 46 08 04 1e 10 f0 	movl   $0xf0101e04,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100a61:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100a68:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100a6b:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100a72:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100a78:	0f 86 f8 00 00 00    	jbe    f0100b76 <debuginfo_eip+0x138>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100a7e:	b8 1a 75 10 f0       	mov    $0xf010751a,%eax
f0100a83:	3d dd 5b 10 f0       	cmp    $0xf0105bdd,%eax
f0100a88:	0f 86 73 01 00 00    	jbe    f0100c01 <debuginfo_eip+0x1c3>
f0100a8e:	80 3d 19 75 10 f0 00 	cmpb   $0x0,0xf0107519
f0100a95:	0f 85 6d 01 00 00    	jne    f0100c08 <debuginfo_eip+0x1ca>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100a9b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100aa2:	ba dc 5b 10 f0       	mov    $0xf0105bdc,%edx
f0100aa7:	81 ea 3c 20 10 f0    	sub    $0xf010203c,%edx
f0100aad:	c1 fa 02             	sar    $0x2,%edx
f0100ab0:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0100ab3:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100ab6:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100ab9:	89 c1                	mov    %eax,%ecx
f0100abb:	c1 e1 08             	shl    $0x8,%ecx
f0100abe:	01 c8                	add    %ecx,%eax
f0100ac0:	89 c1                	mov    %eax,%ecx
f0100ac2:	c1 e1 10             	shl    $0x10,%ecx
f0100ac5:	01 c8                	add    %ecx,%eax
f0100ac7:	01 c0                	add    %eax,%eax
f0100ac9:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
f0100acd:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100ad0:	83 ec 08             	sub    $0x8,%esp
f0100ad3:	57                   	push   %edi
f0100ad4:	6a 64                	push   $0x64
f0100ad6:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100ad9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100adc:	b8 3c 20 10 f0       	mov    $0xf010203c,%eax
f0100ae1:	e8 6b fe ff ff       	call   f0100951 <stab_binsearch>
	if (lfile == 0)
f0100ae6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ae9:	83 c4 10             	add    $0x10,%esp
f0100aec:	85 c0                	test   %eax,%eax
f0100aee:	0f 84 1b 01 00 00    	je     f0100c0f <debuginfo_eip+0x1d1>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100af4:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100af7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100afa:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100afd:	83 ec 08             	sub    $0x8,%esp
f0100b00:	57                   	push   %edi
f0100b01:	6a 24                	push   $0x24
f0100b03:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100b06:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b09:	b8 3c 20 10 f0       	mov    $0xf010203c,%eax
f0100b0e:	e8 3e fe ff ff       	call   f0100951 <stab_binsearch>

	if (lfun <= rfun) {
f0100b13:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100b16:	83 c4 10             	add    $0x10,%esp
f0100b19:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0100b1c:	7f 6c                	jg     f0100b8a <debuginfo_eip+0x14c>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100b1e:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100b21:	01 d8                	add    %ebx,%eax
f0100b23:	c1 e0 02             	shl    $0x2,%eax
f0100b26:	8d 90 3c 20 10 f0    	lea    -0xfefdfc4(%eax),%edx
f0100b2c:	8b 88 3c 20 10 f0    	mov    -0xfefdfc4(%eax),%ecx
f0100b32:	b8 1a 75 10 f0       	mov    $0xf010751a,%eax
f0100b37:	2d dd 5b 10 f0       	sub    $0xf0105bdd,%eax
f0100b3c:	39 c1                	cmp    %eax,%ecx
f0100b3e:	73 09                	jae    f0100b49 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100b40:	81 c1 dd 5b 10 f0    	add    $0xf0105bdd,%ecx
f0100b46:	89 4e 08             	mov    %ecx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100b49:	8b 42 08             	mov    0x8(%edx),%eax
f0100b4c:	89 46 10             	mov    %eax,0x10(%esi)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100b4f:	83 ec 08             	sub    $0x8,%esp
f0100b52:	6a 3a                	push   $0x3a
f0100b54:	ff 76 08             	pushl  0x8(%esi)
f0100b57:	e8 b5 08 00 00       	call   f0101411 <strfind>
f0100b5c:	2b 46 08             	sub    0x8(%esi),%eax
f0100b5f:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100b62:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100b65:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100b68:	01 d8                	add    %ebx,%eax
f0100b6a:	8d 04 85 40 20 10 f0 	lea    -0xfefdfc0(,%eax,4),%eax
f0100b71:	83 c4 10             	add    $0x10,%esp
f0100b74:	eb 20                	jmp    f0100b96 <debuginfo_eip+0x158>
  	        panic("User address");
f0100b76:	83 ec 04             	sub    $0x4,%esp
f0100b79:	68 0e 1e 10 f0       	push   $0xf0101e0e
f0100b7e:	6a 7f                	push   $0x7f
f0100b80:	68 1b 1e 10 f0       	push   $0xf0101e1b
f0100b85:	e8 a4 f5 ff ff       	call   f010012e <_panic>
		info->eip_fn_addr = addr;
f0100b8a:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100b8d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100b90:	eb bd                	jmp    f0100b4f <debuginfo_eip+0x111>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100b92:	4b                   	dec    %ebx
f0100b93:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0100b96:	39 df                	cmp    %ebx,%edi
f0100b98:	7f 34                	jg     f0100bce <debuginfo_eip+0x190>
	       && stabs[lline].n_type != N_SOL
f0100b9a:	8a 10                	mov    (%eax),%dl
f0100b9c:	80 fa 84             	cmp    $0x84,%dl
f0100b9f:	74 0b                	je     f0100bac <debuginfo_eip+0x16e>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100ba1:	80 fa 64             	cmp    $0x64,%dl
f0100ba4:	75 ec                	jne    f0100b92 <debuginfo_eip+0x154>
f0100ba6:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100baa:	74 e6                	je     f0100b92 <debuginfo_eip+0x154>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100bac:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100baf:	01 c3                	add    %eax,%ebx
f0100bb1:	8b 14 9d 3c 20 10 f0 	mov    -0xfefdfc4(,%ebx,4),%edx
f0100bb8:	b8 1a 75 10 f0       	mov    $0xf010751a,%eax
f0100bbd:	2d dd 5b 10 f0       	sub    $0xf0105bdd,%eax
f0100bc2:	39 c2                	cmp    %eax,%edx
f0100bc4:	73 08                	jae    f0100bce <debuginfo_eip+0x190>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100bc6:	81 c2 dd 5b 10 f0    	add    $0xf0105bdd,%edx
f0100bcc:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100bce:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100bd1:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100bd4:	39 c8                	cmp    %ecx,%eax
f0100bd6:	7d 3e                	jge    f0100c16 <debuginfo_eip+0x1d8>
		for (lline = lfun + 1;
f0100bd8:	8d 50 01             	lea    0x1(%eax),%edx
f0100bdb:	8d 1c 00             	lea    (%eax,%eax,1),%ebx
f0100bde:	01 d8                	add    %ebx,%eax
f0100be0:	8d 04 85 4c 20 10 f0 	lea    -0xfefdfb4(,%eax,4),%eax
f0100be7:	eb 04                	jmp    f0100bed <debuginfo_eip+0x1af>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100be9:	ff 46 14             	incl   0x14(%esi)
		     lline++)
f0100bec:	42                   	inc    %edx
		for (lline = lfun + 1;
f0100bed:	39 d1                	cmp    %edx,%ecx
f0100bef:	74 32                	je     f0100c23 <debuginfo_eip+0x1e5>
f0100bf1:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100bf4:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0100bf8:	74 ef                	je     f0100be9 <debuginfo_eip+0x1ab>

	return 0;
f0100bfa:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bff:	eb 1a                	jmp    f0100c1b <debuginfo_eip+0x1dd>
		return -1;
f0100c01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c06:	eb 13                	jmp    f0100c1b <debuginfo_eip+0x1dd>
f0100c08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c0d:	eb 0c                	jmp    f0100c1b <debuginfo_eip+0x1dd>
		return -1;
f0100c0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c14:	eb 05                	jmp    f0100c1b <debuginfo_eip+0x1dd>
	return 0;
f0100c16:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100c1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c1e:	5b                   	pop    %ebx
f0100c1f:	5e                   	pop    %esi
f0100c20:	5f                   	pop    %edi
f0100c21:	5d                   	pop    %ebp
f0100c22:	c3                   	ret    
	return 0;
f0100c23:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c28:	eb f1                	jmp    f0100c1b <debuginfo_eip+0x1dd>

f0100c2a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100c2a:	55                   	push   %ebp
f0100c2b:	89 e5                	mov    %esp,%ebp
f0100c2d:	57                   	push   %edi
f0100c2e:	56                   	push   %esi
f0100c2f:	53                   	push   %ebx
f0100c30:	83 ec 1c             	sub    $0x1c,%esp
f0100c33:	89 c7                	mov    %eax,%edi
f0100c35:	89 d6                	mov    %edx,%esi
f0100c37:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c3a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100c3d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100c40:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100c43:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100c46:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100c4b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100c4e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100c51:	39 d3                	cmp    %edx,%ebx
f0100c53:	72 05                	jb     f0100c5a <printnum+0x30>
f0100c55:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100c58:	77 78                	ja     f0100cd2 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100c5a:	83 ec 0c             	sub    $0xc,%esp
f0100c5d:	ff 75 18             	pushl  0x18(%ebp)
f0100c60:	8b 45 14             	mov    0x14(%ebp),%eax
f0100c63:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100c66:	53                   	push   %ebx
f0100c67:	ff 75 10             	pushl  0x10(%ebp)
f0100c6a:	83 ec 08             	sub    $0x8,%esp
f0100c6d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100c70:	ff 75 e0             	pushl  -0x20(%ebp)
f0100c73:	ff 75 dc             	pushl  -0x24(%ebp)
f0100c76:	ff 75 d8             	pushl  -0x28(%ebp)
f0100c79:	e8 8e 09 00 00       	call   f010160c <__udivdi3>
f0100c7e:	83 c4 18             	add    $0x18,%esp
f0100c81:	52                   	push   %edx
f0100c82:	50                   	push   %eax
f0100c83:	89 f2                	mov    %esi,%edx
f0100c85:	89 f8                	mov    %edi,%eax
f0100c87:	e8 9e ff ff ff       	call   f0100c2a <printnum>
f0100c8c:	83 c4 20             	add    $0x20,%esp
f0100c8f:	eb 11                	jmp    f0100ca2 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100c91:	83 ec 08             	sub    $0x8,%esp
f0100c94:	56                   	push   %esi
f0100c95:	ff 75 18             	pushl  0x18(%ebp)
f0100c98:	ff d7                	call   *%edi
f0100c9a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100c9d:	4b                   	dec    %ebx
f0100c9e:	85 db                	test   %ebx,%ebx
f0100ca0:	7f ef                	jg     f0100c91 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100ca2:	83 ec 08             	sub    $0x8,%esp
f0100ca5:	56                   	push   %esi
f0100ca6:	83 ec 04             	sub    $0x4,%esp
f0100ca9:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100cac:	ff 75 e0             	pushl  -0x20(%ebp)
f0100caf:	ff 75 dc             	pushl  -0x24(%ebp)
f0100cb2:	ff 75 d8             	pushl  -0x28(%ebp)
f0100cb5:	e8 52 0a 00 00       	call   f010170c <__umoddi3>
f0100cba:	83 c4 14             	add    $0x14,%esp
f0100cbd:	0f be 80 29 1e 10 f0 	movsbl -0xfefe1d7(%eax),%eax
f0100cc4:	50                   	push   %eax
f0100cc5:	ff d7                	call   *%edi
}
f0100cc7:	83 c4 10             	add    $0x10,%esp
f0100cca:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ccd:	5b                   	pop    %ebx
f0100cce:	5e                   	pop    %esi
f0100ccf:	5f                   	pop    %edi
f0100cd0:	5d                   	pop    %ebp
f0100cd1:	c3                   	ret    
f0100cd2:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100cd5:	eb c6                	jmp    f0100c9d <printnum+0x73>

f0100cd7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100cd7:	55                   	push   %ebp
f0100cd8:	89 e5                	mov    %esp,%ebp
f0100cda:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100cdd:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0100ce0:	8b 10                	mov    (%eax),%edx
f0100ce2:	3b 50 04             	cmp    0x4(%eax),%edx
f0100ce5:	73 0a                	jae    f0100cf1 <sprintputch+0x1a>
		*b->buf++ = ch;
f0100ce7:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100cea:	89 08                	mov    %ecx,(%eax)
f0100cec:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cef:	88 02                	mov    %al,(%edx)
}
f0100cf1:	5d                   	pop    %ebp
f0100cf2:	c3                   	ret    

f0100cf3 <printfmt>:
{
f0100cf3:	55                   	push   %ebp
f0100cf4:	89 e5                	mov    %esp,%ebp
f0100cf6:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100cf9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100cfc:	50                   	push   %eax
f0100cfd:	ff 75 10             	pushl  0x10(%ebp)
f0100d00:	ff 75 0c             	pushl  0xc(%ebp)
f0100d03:	ff 75 08             	pushl  0x8(%ebp)
f0100d06:	e8 05 00 00 00       	call   f0100d10 <vprintfmt>
}
f0100d0b:	83 c4 10             	add    $0x10,%esp
f0100d0e:	c9                   	leave  
f0100d0f:	c3                   	ret    

f0100d10 <vprintfmt>:
{
f0100d10:	55                   	push   %ebp
f0100d11:	89 e5                	mov    %esp,%ebp
f0100d13:	57                   	push   %edi
f0100d14:	56                   	push   %esi
f0100d15:	53                   	push   %ebx
f0100d16:	83 ec 2c             	sub    $0x2c,%esp
f0100d19:	8b 75 08             	mov    0x8(%ebp),%esi
f0100d1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100d1f:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100d22:	e9 ac 03 00 00       	jmp    f01010d3 <vprintfmt+0x3c3>
		padc = ' ';
f0100d27:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0100d2b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0100d32:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f0100d39:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0100d40:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0100d45:	8d 47 01             	lea    0x1(%edi),%eax
f0100d48:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100d4b:	8a 17                	mov    (%edi),%dl
f0100d4d:	8d 42 dd             	lea    -0x23(%edx),%eax
f0100d50:	3c 55                	cmp    $0x55,%al
f0100d52:	0f 87 fc 03 00 00    	ja     f0101154 <vprintfmt+0x444>
f0100d58:	0f b6 c0             	movzbl %al,%eax
f0100d5b:	ff 24 85 b8 1e 10 f0 	jmp    *-0xfefe148(,%eax,4)
f0100d62:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0100d65:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0100d69:	eb da                	jmp    f0100d45 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0100d6b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0100d6e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100d72:	eb d1                	jmp    f0100d45 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0100d74:	0f b6 d2             	movzbl %dl,%edx
f0100d77:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0100d7a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d7f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0100d82:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100d85:	01 c0                	add    %eax,%eax
f0100d87:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
f0100d8b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0100d8e:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0100d91:	83 f9 09             	cmp    $0x9,%ecx
f0100d94:	77 52                	ja     f0100de8 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
f0100d96:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
f0100d97:	eb e9                	jmp    f0100d82 <vprintfmt+0x72>
			precision = va_arg(ap, int);
f0100d99:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d9c:	8b 00                	mov    (%eax),%eax
f0100d9e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100da1:	8b 45 14             	mov    0x14(%ebp),%eax
f0100da4:	8d 40 04             	lea    0x4(%eax),%eax
f0100da7:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100daa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0100dad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100db1:	79 92                	jns    f0100d45 <vprintfmt+0x35>
				width = precision, precision = -1;
f0100db3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100db6:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100db9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100dc0:	eb 83                	jmp    f0100d45 <vprintfmt+0x35>
f0100dc2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100dc6:	78 08                	js     f0100dd0 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
f0100dc8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100dcb:	e9 75 ff ff ff       	jmp    f0100d45 <vprintfmt+0x35>
f0100dd0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0100dd7:	eb ef                	jmp    f0100dc8 <vprintfmt+0xb8>
f0100dd9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0100ddc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100de3:	e9 5d ff ff ff       	jmp    f0100d45 <vprintfmt+0x35>
f0100de8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100deb:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100dee:	eb bd                	jmp    f0100dad <vprintfmt+0x9d>
			lflag++;
f0100df0:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
f0100df1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0100df4:	e9 4c ff ff ff       	jmp    f0100d45 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f0100df9:	8b 45 14             	mov    0x14(%ebp),%eax
f0100dfc:	8d 78 04             	lea    0x4(%eax),%edi
f0100dff:	83 ec 08             	sub    $0x8,%esp
f0100e02:	53                   	push   %ebx
f0100e03:	ff 30                	pushl  (%eax)
f0100e05:	ff d6                	call   *%esi
			break;
f0100e07:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0100e0a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0100e0d:	e9 be 02 00 00       	jmp    f01010d0 <vprintfmt+0x3c0>
			err = va_arg(ap, int);
f0100e12:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e15:	8d 78 04             	lea    0x4(%eax),%edi
f0100e18:	8b 00                	mov    (%eax),%eax
f0100e1a:	85 c0                	test   %eax,%eax
f0100e1c:	78 2a                	js     f0100e48 <vprintfmt+0x138>
f0100e1e:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100e20:	83 f8 06             	cmp    $0x6,%eax
f0100e23:	7f 27                	jg     f0100e4c <vprintfmt+0x13c>
f0100e25:	8b 04 85 10 20 10 f0 	mov    -0xfefdff0(,%eax,4),%eax
f0100e2c:	85 c0                	test   %eax,%eax
f0100e2e:	74 1c                	je     f0100e4c <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
f0100e30:	50                   	push   %eax
f0100e31:	68 4a 1e 10 f0       	push   $0xf0101e4a
f0100e36:	53                   	push   %ebx
f0100e37:	56                   	push   %esi
f0100e38:	e8 b6 fe ff ff       	call   f0100cf3 <printfmt>
f0100e3d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100e40:	89 7d 14             	mov    %edi,0x14(%ebp)
f0100e43:	e9 88 02 00 00       	jmp    f01010d0 <vprintfmt+0x3c0>
f0100e48:	f7 d8                	neg    %eax
f0100e4a:	eb d2                	jmp    f0100e1e <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
f0100e4c:	52                   	push   %edx
f0100e4d:	68 41 1e 10 f0       	push   $0xf0101e41
f0100e52:	53                   	push   %ebx
f0100e53:	56                   	push   %esi
f0100e54:	e8 9a fe ff ff       	call   f0100cf3 <printfmt>
f0100e59:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100e5c:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0100e5f:	e9 6c 02 00 00       	jmp    f01010d0 <vprintfmt+0x3c0>
			if ((p = va_arg(ap, char *)) == NULL)
f0100e64:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e67:	83 c0 04             	add    $0x4,%eax
f0100e6a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100e6d:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e70:	8b 38                	mov    (%eax),%edi
f0100e72:	85 ff                	test   %edi,%edi
f0100e74:	74 18                	je     f0100e8e <vprintfmt+0x17e>
			if (width > 0 && padc != '-')
f0100e76:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100e7a:	0f 8e b7 00 00 00    	jle    f0100f37 <vprintfmt+0x227>
f0100e80:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100e84:	75 0f                	jne    f0100e95 <vprintfmt+0x185>
f0100e86:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100e89:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100e8c:	eb 6e                	jmp    f0100efc <vprintfmt+0x1ec>
				p = "(null)";
f0100e8e:	bf 3a 1e 10 f0       	mov    $0xf0101e3a,%edi
f0100e93:	eb e1                	jmp    f0100e76 <vprintfmt+0x166>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100e95:	83 ec 08             	sub    $0x8,%esp
f0100e98:	ff 75 d0             	pushl  -0x30(%ebp)
f0100e9b:	57                   	push   %edi
f0100e9c:	e8 45 04 00 00       	call   f01012e6 <strnlen>
f0100ea1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100ea4:	29 c1                	sub    %eax,%ecx
f0100ea6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0100ea9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0100eac:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0100eb0:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100eb3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100eb6:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0100eb8:	eb 0d                	jmp    f0100ec7 <vprintfmt+0x1b7>
					putch(padc, putdat);
f0100eba:	83 ec 08             	sub    $0x8,%esp
f0100ebd:	53                   	push   %ebx
f0100ebe:	ff 75 e0             	pushl  -0x20(%ebp)
f0100ec1:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0100ec3:	4f                   	dec    %edi
f0100ec4:	83 c4 10             	add    $0x10,%esp
f0100ec7:	85 ff                	test   %edi,%edi
f0100ec9:	7f ef                	jg     f0100eba <vprintfmt+0x1aa>
f0100ecb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100ece:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0100ed1:	89 c8                	mov    %ecx,%eax
f0100ed3:	85 c9                	test   %ecx,%ecx
f0100ed5:	78 59                	js     f0100f30 <vprintfmt+0x220>
f0100ed7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0100eda:	29 c1                	sub    %eax,%ecx
f0100edc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100edf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100ee2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100ee5:	eb 15                	jmp    f0100efc <vprintfmt+0x1ec>
				if (altflag && (ch < ' ' || ch > '~'))
f0100ee7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100eeb:	75 29                	jne    f0100f16 <vprintfmt+0x206>
					putch(ch, putdat);
f0100eed:	83 ec 08             	sub    $0x8,%esp
f0100ef0:	ff 75 0c             	pushl  0xc(%ebp)
f0100ef3:	50                   	push   %eax
f0100ef4:	ff d6                	call   *%esi
f0100ef6:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100ef9:	ff 4d e0             	decl   -0x20(%ebp)
f0100efc:	47                   	inc    %edi
f0100efd:	8a 57 ff             	mov    -0x1(%edi),%dl
f0100f00:	0f be c2             	movsbl %dl,%eax
f0100f03:	85 c0                	test   %eax,%eax
f0100f05:	74 53                	je     f0100f5a <vprintfmt+0x24a>
f0100f07:	85 db                	test   %ebx,%ebx
f0100f09:	78 dc                	js     f0100ee7 <vprintfmt+0x1d7>
f0100f0b:	4b                   	dec    %ebx
f0100f0c:	79 d9                	jns    f0100ee7 <vprintfmt+0x1d7>
f0100f0e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100f11:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100f14:	eb 35                	jmp    f0100f4b <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
f0100f16:	0f be d2             	movsbl %dl,%edx
f0100f19:	83 ea 20             	sub    $0x20,%edx
f0100f1c:	83 fa 5e             	cmp    $0x5e,%edx
f0100f1f:	76 cc                	jbe    f0100eed <vprintfmt+0x1dd>
					putch('?', putdat);
f0100f21:	83 ec 08             	sub    $0x8,%esp
f0100f24:	ff 75 0c             	pushl  0xc(%ebp)
f0100f27:	6a 3f                	push   $0x3f
f0100f29:	ff d6                	call   *%esi
f0100f2b:	83 c4 10             	add    $0x10,%esp
f0100f2e:	eb c9                	jmp    f0100ef9 <vprintfmt+0x1e9>
f0100f30:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f35:	eb a0                	jmp    f0100ed7 <vprintfmt+0x1c7>
f0100f37:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100f3a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100f3d:	eb bd                	jmp    f0100efc <vprintfmt+0x1ec>
				putch(' ', putdat);
f0100f3f:	83 ec 08             	sub    $0x8,%esp
f0100f42:	53                   	push   %ebx
f0100f43:	6a 20                	push   $0x20
f0100f45:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0100f47:	4f                   	dec    %edi
f0100f48:	83 c4 10             	add    $0x10,%esp
f0100f4b:	85 ff                	test   %edi,%edi
f0100f4d:	7f f0                	jg     f0100f3f <vprintfmt+0x22f>
			if ((p = va_arg(ap, char *)) == NULL)
f0100f4f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0100f52:	89 45 14             	mov    %eax,0x14(%ebp)
f0100f55:	e9 76 01 00 00       	jmp    f01010d0 <vprintfmt+0x3c0>
f0100f5a:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100f5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100f60:	eb e9                	jmp    f0100f4b <vprintfmt+0x23b>
	if (lflag >= 2)
f0100f62:	83 f9 01             	cmp    $0x1,%ecx
f0100f65:	7e 3f                	jle    f0100fa6 <vprintfmt+0x296>
		return va_arg(*ap, long long);
f0100f67:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f6a:	8b 50 04             	mov    0x4(%eax),%edx
f0100f6d:	8b 00                	mov    (%eax),%eax
f0100f6f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f72:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100f75:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f78:	8d 40 08             	lea    0x8(%eax),%eax
f0100f7b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0100f7e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100f82:	79 5c                	jns    f0100fe0 <vprintfmt+0x2d0>
				putch('-', putdat);
f0100f84:	83 ec 08             	sub    $0x8,%esp
f0100f87:	53                   	push   %ebx
f0100f88:	6a 2d                	push   $0x2d
f0100f8a:	ff d6                	call   *%esi
				num = -(long long) num;
f0100f8c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100f8f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100f92:	f7 da                	neg    %edx
f0100f94:	83 d1 00             	adc    $0x0,%ecx
f0100f97:	f7 d9                	neg    %ecx
f0100f99:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0100f9c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100fa1:	e9 10 01 00 00       	jmp    f01010b6 <vprintfmt+0x3a6>
	else if (lflag)
f0100fa6:	85 c9                	test   %ecx,%ecx
f0100fa8:	75 1b                	jne    f0100fc5 <vprintfmt+0x2b5>
		return va_arg(*ap, int);
f0100faa:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fad:	8b 00                	mov    (%eax),%eax
f0100faf:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100fb2:	89 c1                	mov    %eax,%ecx
f0100fb4:	c1 f9 1f             	sar    $0x1f,%ecx
f0100fb7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100fba:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fbd:	8d 40 04             	lea    0x4(%eax),%eax
f0100fc0:	89 45 14             	mov    %eax,0x14(%ebp)
f0100fc3:	eb b9                	jmp    f0100f7e <vprintfmt+0x26e>
		return va_arg(*ap, long);
f0100fc5:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fc8:	8b 00                	mov    (%eax),%eax
f0100fca:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100fcd:	89 c1                	mov    %eax,%ecx
f0100fcf:	c1 f9 1f             	sar    $0x1f,%ecx
f0100fd2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100fd5:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fd8:	8d 40 04             	lea    0x4(%eax),%eax
f0100fdb:	89 45 14             	mov    %eax,0x14(%ebp)
f0100fde:	eb 9e                	jmp    f0100f7e <vprintfmt+0x26e>
			num = getint(&ap, lflag);
f0100fe0:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100fe3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0100fe6:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100feb:	e9 c6 00 00 00       	jmp    f01010b6 <vprintfmt+0x3a6>
	if (lflag >= 2)
f0100ff0:	83 f9 01             	cmp    $0x1,%ecx
f0100ff3:	7e 18                	jle    f010100d <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
f0100ff5:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ff8:	8b 10                	mov    (%eax),%edx
f0100ffa:	8b 48 04             	mov    0x4(%eax),%ecx
f0100ffd:	8d 40 08             	lea    0x8(%eax),%eax
f0101000:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101003:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101008:	e9 a9 00 00 00       	jmp    f01010b6 <vprintfmt+0x3a6>
	else if (lflag)
f010100d:	85 c9                	test   %ecx,%ecx
f010100f:	75 1a                	jne    f010102b <vprintfmt+0x31b>
		return va_arg(*ap, unsigned int);
f0101011:	8b 45 14             	mov    0x14(%ebp),%eax
f0101014:	8b 10                	mov    (%eax),%edx
f0101016:	b9 00 00 00 00       	mov    $0x0,%ecx
f010101b:	8d 40 04             	lea    0x4(%eax),%eax
f010101e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101021:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101026:	e9 8b 00 00 00       	jmp    f01010b6 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f010102b:	8b 45 14             	mov    0x14(%ebp),%eax
f010102e:	8b 10                	mov    (%eax),%edx
f0101030:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101035:	8d 40 04             	lea    0x4(%eax),%eax
f0101038:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010103b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101040:	eb 74                	jmp    f01010b6 <vprintfmt+0x3a6>
	if (lflag >= 2)
f0101042:	83 f9 01             	cmp    $0x1,%ecx
f0101045:	7e 15                	jle    f010105c <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
f0101047:	8b 45 14             	mov    0x14(%ebp),%eax
f010104a:	8b 10                	mov    (%eax),%edx
f010104c:	8b 48 04             	mov    0x4(%eax),%ecx
f010104f:	8d 40 08             	lea    0x8(%eax),%eax
f0101052:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101055:	b8 08 00 00 00       	mov    $0x8,%eax
f010105a:	eb 5a                	jmp    f01010b6 <vprintfmt+0x3a6>
	else if (lflag)
f010105c:	85 c9                	test   %ecx,%ecx
f010105e:	75 17                	jne    f0101077 <vprintfmt+0x367>
		return va_arg(*ap, unsigned int);
f0101060:	8b 45 14             	mov    0x14(%ebp),%eax
f0101063:	8b 10                	mov    (%eax),%edx
f0101065:	b9 00 00 00 00       	mov    $0x0,%ecx
f010106a:	8d 40 04             	lea    0x4(%eax),%eax
f010106d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101070:	b8 08 00 00 00       	mov    $0x8,%eax
f0101075:	eb 3f                	jmp    f01010b6 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0101077:	8b 45 14             	mov    0x14(%ebp),%eax
f010107a:	8b 10                	mov    (%eax),%edx
f010107c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101081:	8d 40 04             	lea    0x4(%eax),%eax
f0101084:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101087:	b8 08 00 00 00       	mov    $0x8,%eax
f010108c:	eb 28                	jmp    f01010b6 <vprintfmt+0x3a6>
			putch('0', putdat);
f010108e:	83 ec 08             	sub    $0x8,%esp
f0101091:	53                   	push   %ebx
f0101092:	6a 30                	push   $0x30
f0101094:	ff d6                	call   *%esi
			putch('x', putdat);
f0101096:	83 c4 08             	add    $0x8,%esp
f0101099:	53                   	push   %ebx
f010109a:	6a 78                	push   $0x78
f010109c:	ff d6                	call   *%esi
			num = (unsigned long long)
f010109e:	8b 45 14             	mov    0x14(%ebp),%eax
f01010a1:	8b 10                	mov    (%eax),%edx
f01010a3:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01010a8:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01010ab:	8d 40 04             	lea    0x4(%eax),%eax
f01010ae:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01010b1:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01010b6:	83 ec 0c             	sub    $0xc,%esp
f01010b9:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01010bd:	57                   	push   %edi
f01010be:	ff 75 e0             	pushl  -0x20(%ebp)
f01010c1:	50                   	push   %eax
f01010c2:	51                   	push   %ecx
f01010c3:	52                   	push   %edx
f01010c4:	89 da                	mov    %ebx,%edx
f01010c6:	89 f0                	mov    %esi,%eax
f01010c8:	e8 5d fb ff ff       	call   f0100c2a <printnum>
			break;
f01010cd:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f01010d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01010d3:	47                   	inc    %edi
f01010d4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01010d8:	83 f8 25             	cmp    $0x25,%eax
f01010db:	0f 84 46 fc ff ff    	je     f0100d27 <vprintfmt+0x17>
			if (ch == '\0')
f01010e1:	85 c0                	test   %eax,%eax
f01010e3:	0f 84 89 00 00 00    	je     f0101172 <vprintfmt+0x462>
			putch(ch, putdat);
f01010e9:	83 ec 08             	sub    $0x8,%esp
f01010ec:	53                   	push   %ebx
f01010ed:	50                   	push   %eax
f01010ee:	ff d6                	call   *%esi
f01010f0:	83 c4 10             	add    $0x10,%esp
f01010f3:	eb de                	jmp    f01010d3 <vprintfmt+0x3c3>
	if (lflag >= 2)
f01010f5:	83 f9 01             	cmp    $0x1,%ecx
f01010f8:	7e 15                	jle    f010110f <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
f01010fa:	8b 45 14             	mov    0x14(%ebp),%eax
f01010fd:	8b 10                	mov    (%eax),%edx
f01010ff:	8b 48 04             	mov    0x4(%eax),%ecx
f0101102:	8d 40 08             	lea    0x8(%eax),%eax
f0101105:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101108:	b8 10 00 00 00       	mov    $0x10,%eax
f010110d:	eb a7                	jmp    f01010b6 <vprintfmt+0x3a6>
	else if (lflag)
f010110f:	85 c9                	test   %ecx,%ecx
f0101111:	75 17                	jne    f010112a <vprintfmt+0x41a>
		return va_arg(*ap, unsigned int);
f0101113:	8b 45 14             	mov    0x14(%ebp),%eax
f0101116:	8b 10                	mov    (%eax),%edx
f0101118:	b9 00 00 00 00       	mov    $0x0,%ecx
f010111d:	8d 40 04             	lea    0x4(%eax),%eax
f0101120:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101123:	b8 10 00 00 00       	mov    $0x10,%eax
f0101128:	eb 8c                	jmp    f01010b6 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f010112a:	8b 45 14             	mov    0x14(%ebp),%eax
f010112d:	8b 10                	mov    (%eax),%edx
f010112f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101134:	8d 40 04             	lea    0x4(%eax),%eax
f0101137:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010113a:	b8 10 00 00 00       	mov    $0x10,%eax
f010113f:	e9 72 ff ff ff       	jmp    f01010b6 <vprintfmt+0x3a6>
			putch(ch, putdat);
f0101144:	83 ec 08             	sub    $0x8,%esp
f0101147:	53                   	push   %ebx
f0101148:	6a 25                	push   $0x25
f010114a:	ff d6                	call   *%esi
			break;
f010114c:	83 c4 10             	add    $0x10,%esp
f010114f:	e9 7c ff ff ff       	jmp    f01010d0 <vprintfmt+0x3c0>
			putch('%', putdat);
f0101154:	83 ec 08             	sub    $0x8,%esp
f0101157:	53                   	push   %ebx
f0101158:	6a 25                	push   $0x25
f010115a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010115c:	83 c4 10             	add    $0x10,%esp
f010115f:	89 f8                	mov    %edi,%eax
f0101161:	eb 01                	jmp    f0101164 <vprintfmt+0x454>
f0101163:	48                   	dec    %eax
f0101164:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0101168:	75 f9                	jne    f0101163 <vprintfmt+0x453>
f010116a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010116d:	e9 5e ff ff ff       	jmp    f01010d0 <vprintfmt+0x3c0>
}
f0101172:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101175:	5b                   	pop    %ebx
f0101176:	5e                   	pop    %esi
f0101177:	5f                   	pop    %edi
f0101178:	5d                   	pop    %ebp
f0101179:	c3                   	ret    

f010117a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010117a:	55                   	push   %ebp
f010117b:	89 e5                	mov    %esp,%ebp
f010117d:	83 ec 18             	sub    $0x18,%esp
f0101180:	8b 45 08             	mov    0x8(%ebp),%eax
f0101183:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101186:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101189:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010118d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101190:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101197:	85 c0                	test   %eax,%eax
f0101199:	74 26                	je     f01011c1 <vsnprintf+0x47>
f010119b:	85 d2                	test   %edx,%edx
f010119d:	7e 29                	jle    f01011c8 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010119f:	ff 75 14             	pushl  0x14(%ebp)
f01011a2:	ff 75 10             	pushl  0x10(%ebp)
f01011a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01011a8:	50                   	push   %eax
f01011a9:	68 d7 0c 10 f0       	push   $0xf0100cd7
f01011ae:	e8 5d fb ff ff       	call   f0100d10 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01011b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01011b6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01011b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011bc:	83 c4 10             	add    $0x10,%esp
}
f01011bf:	c9                   	leave  
f01011c0:	c3                   	ret    
		return -E_INVAL;
f01011c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01011c6:	eb f7                	jmp    f01011bf <vsnprintf+0x45>
f01011c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01011cd:	eb f0                	jmp    f01011bf <vsnprintf+0x45>

f01011cf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01011cf:	55                   	push   %ebp
f01011d0:	89 e5                	mov    %esp,%ebp
f01011d2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01011d5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01011d8:	50                   	push   %eax
f01011d9:	ff 75 10             	pushl  0x10(%ebp)
f01011dc:	ff 75 0c             	pushl  0xc(%ebp)
f01011df:	ff 75 08             	pushl  0x8(%ebp)
f01011e2:	e8 93 ff ff ff       	call   f010117a <vsnprintf>
	va_end(ap);

	return rc;
}
f01011e7:	c9                   	leave  
f01011e8:	c3                   	ret    

f01011e9 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01011e9:	55                   	push   %ebp
f01011ea:	89 e5                	mov    %esp,%ebp
f01011ec:	57                   	push   %edi
f01011ed:	56                   	push   %esi
f01011ee:	53                   	push   %ebx
f01011ef:	83 ec 0c             	sub    $0xc,%esp
f01011f2:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01011f5:	85 c0                	test   %eax,%eax
f01011f7:	74 11                	je     f010120a <readline+0x21>
		cprintf("%s", prompt);
f01011f9:	83 ec 08             	sub    $0x8,%esp
f01011fc:	50                   	push   %eax
f01011fd:	68 4a 1e 10 f0       	push   $0xf0101e4a
f0101202:	e8 36 f7 ff ff       	call   f010093d <cprintf>
f0101207:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010120a:	83 ec 0c             	sub    $0xc,%esp
f010120d:	6a 00                	push   $0x0
f010120f:	e8 8e f4 ff ff       	call   f01006a2 <iscons>
f0101214:	89 c7                	mov    %eax,%edi
f0101216:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0101219:	be 00 00 00 00       	mov    $0x0,%esi
f010121e:	eb 6f                	jmp    f010128f <readline+0xa6>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0101220:	83 ec 08             	sub    $0x8,%esp
f0101223:	50                   	push   %eax
f0101224:	68 2c 20 10 f0       	push   $0xf010202c
f0101229:	e8 0f f7 ff ff       	call   f010093d <cprintf>
			return NULL;
f010122e:	83 c4 10             	add    $0x10,%esp
f0101231:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0101236:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101239:	5b                   	pop    %ebx
f010123a:	5e                   	pop    %esi
f010123b:	5f                   	pop    %edi
f010123c:	5d                   	pop    %ebp
f010123d:	c3                   	ret    
				cputchar('\b');
f010123e:	83 ec 0c             	sub    $0xc,%esp
f0101241:	6a 08                	push   $0x8
f0101243:	e8 39 f4 ff ff       	call   f0100681 <cputchar>
f0101248:	83 c4 10             	add    $0x10,%esp
f010124b:	eb 41                	jmp    f010128e <readline+0xa5>
				cputchar(c);
f010124d:	83 ec 0c             	sub    $0xc,%esp
f0101250:	53                   	push   %ebx
f0101251:	e8 2b f4 ff ff       	call   f0100681 <cputchar>
f0101256:	83 c4 10             	add    $0x10,%esp
f0101259:	eb 5a                	jmp    f01012b5 <readline+0xcc>
		} else if (c == '\n' || c == '\r') {
f010125b:	83 fb 0a             	cmp    $0xa,%ebx
f010125e:	74 05                	je     f0101265 <readline+0x7c>
f0101260:	83 fb 0d             	cmp    $0xd,%ebx
f0101263:	75 2a                	jne    f010128f <readline+0xa6>
			if (echoing)
f0101265:	85 ff                	test   %edi,%edi
f0101267:	75 0e                	jne    f0101277 <readline+0x8e>
			buf[i] = 0;
f0101269:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f0101270:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
f0101275:	eb bf                	jmp    f0101236 <readline+0x4d>
				cputchar('\n');
f0101277:	83 ec 0c             	sub    $0xc,%esp
f010127a:	6a 0a                	push   $0xa
f010127c:	e8 00 f4 ff ff       	call   f0100681 <cputchar>
f0101281:	83 c4 10             	add    $0x10,%esp
f0101284:	eb e3                	jmp    f0101269 <readline+0x80>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101286:	85 f6                	test   %esi,%esi
f0101288:	7e 3c                	jle    f01012c6 <readline+0xdd>
			if (echoing)
f010128a:	85 ff                	test   %edi,%edi
f010128c:	75 b0                	jne    f010123e <readline+0x55>
			i--;
f010128e:	4e                   	dec    %esi
		c = getchar();
f010128f:	e8 fd f3 ff ff       	call   f0100691 <getchar>
f0101294:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0101296:	85 c0                	test   %eax,%eax
f0101298:	78 86                	js     f0101220 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010129a:	83 f8 08             	cmp    $0x8,%eax
f010129d:	74 21                	je     f01012c0 <readline+0xd7>
f010129f:	83 f8 7f             	cmp    $0x7f,%eax
f01012a2:	74 e2                	je     f0101286 <readline+0x9d>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01012a4:	83 f8 1f             	cmp    $0x1f,%eax
f01012a7:	7e b2                	jle    f010125b <readline+0x72>
f01012a9:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01012af:	7f aa                	jg     f010125b <readline+0x72>
			if (echoing)
f01012b1:	85 ff                	test   %edi,%edi
f01012b3:	75 98                	jne    f010124d <readline+0x64>
			buf[i++] = c;
f01012b5:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f01012bb:	8d 76 01             	lea    0x1(%esi),%esi
f01012be:	eb cf                	jmp    f010128f <readline+0xa6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01012c0:	85 f6                	test   %esi,%esi
f01012c2:	7e cb                	jle    f010128f <readline+0xa6>
f01012c4:	eb c4                	jmp    f010128a <readline+0xa1>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01012c6:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01012cc:	7e e3                	jle    f01012b1 <readline+0xc8>
f01012ce:	eb bf                	jmp    f010128f <readline+0xa6>

f01012d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01012d0:	55                   	push   %ebp
f01012d1:	89 e5                	mov    %esp,%ebp
f01012d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01012d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01012db:	eb 01                	jmp    f01012de <strlen+0xe>
		n++;
f01012dd:	40                   	inc    %eax
	for (n = 0; *s != '\0'; s++)
f01012de:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01012e2:	75 f9                	jne    f01012dd <strlen+0xd>
	return n;
}
f01012e4:	5d                   	pop    %ebp
f01012e5:	c3                   	ret    

f01012e6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01012e6:	55                   	push   %ebp
f01012e7:	89 e5                	mov    %esp,%ebp
f01012e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01012ec:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012ef:	b8 00 00 00 00       	mov    $0x0,%eax
f01012f4:	eb 01                	jmp    f01012f7 <strnlen+0x11>
		n++;
f01012f6:	40                   	inc    %eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012f7:	39 d0                	cmp    %edx,%eax
f01012f9:	74 06                	je     f0101301 <strnlen+0x1b>
f01012fb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01012ff:	75 f5                	jne    f01012f6 <strnlen+0x10>
	return n;
}
f0101301:	5d                   	pop    %ebp
f0101302:	c3                   	ret    

f0101303 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101303:	55                   	push   %ebp
f0101304:	89 e5                	mov    %esp,%ebp
f0101306:	53                   	push   %ebx
f0101307:	8b 45 08             	mov    0x8(%ebp),%eax
f010130a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010130d:	89 c2                	mov    %eax,%edx
f010130f:	41                   	inc    %ecx
f0101310:	42                   	inc    %edx
f0101311:	8a 59 ff             	mov    -0x1(%ecx),%bl
f0101314:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101317:	84 db                	test   %bl,%bl
f0101319:	75 f4                	jne    f010130f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010131b:	5b                   	pop    %ebx
f010131c:	5d                   	pop    %ebp
f010131d:	c3                   	ret    

f010131e <strcat>:

char *
strcat(char *dst, const char *src)
{
f010131e:	55                   	push   %ebp
f010131f:	89 e5                	mov    %esp,%ebp
f0101321:	53                   	push   %ebx
f0101322:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101325:	53                   	push   %ebx
f0101326:	e8 a5 ff ff ff       	call   f01012d0 <strlen>
f010132b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010132e:	ff 75 0c             	pushl  0xc(%ebp)
f0101331:	01 d8                	add    %ebx,%eax
f0101333:	50                   	push   %eax
f0101334:	e8 ca ff ff ff       	call   f0101303 <strcpy>
	return dst;
}
f0101339:	89 d8                	mov    %ebx,%eax
f010133b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010133e:	c9                   	leave  
f010133f:	c3                   	ret    

f0101340 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101340:	55                   	push   %ebp
f0101341:	89 e5                	mov    %esp,%ebp
f0101343:	56                   	push   %esi
f0101344:	53                   	push   %ebx
f0101345:	8b 75 08             	mov    0x8(%ebp),%esi
f0101348:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010134b:	89 f3                	mov    %esi,%ebx
f010134d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101350:	89 f2                	mov    %esi,%edx
f0101352:	39 da                	cmp    %ebx,%edx
f0101354:	74 0e                	je     f0101364 <strncpy+0x24>
		*dst++ = *src;
f0101356:	42                   	inc    %edx
f0101357:	8a 01                	mov    (%ecx),%al
f0101359:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f010135c:	80 39 00             	cmpb   $0x0,(%ecx)
f010135f:	74 f1                	je     f0101352 <strncpy+0x12>
			src++;
f0101361:	41                   	inc    %ecx
f0101362:	eb ee                	jmp    f0101352 <strncpy+0x12>
	}
	return ret;
}
f0101364:	89 f0                	mov    %esi,%eax
f0101366:	5b                   	pop    %ebx
f0101367:	5e                   	pop    %esi
f0101368:	5d                   	pop    %ebp
f0101369:	c3                   	ret    

f010136a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010136a:	55                   	push   %ebp
f010136b:	89 e5                	mov    %esp,%ebp
f010136d:	56                   	push   %esi
f010136e:	53                   	push   %ebx
f010136f:	8b 75 08             	mov    0x8(%ebp),%esi
f0101372:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101375:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101378:	85 c0                	test   %eax,%eax
f010137a:	74 20                	je     f010139c <strlcpy+0x32>
f010137c:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
f0101380:	89 f0                	mov    %esi,%eax
f0101382:	eb 05                	jmp    f0101389 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101384:	42                   	inc    %edx
f0101385:	40                   	inc    %eax
f0101386:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0101389:	39 d8                	cmp    %ebx,%eax
f010138b:	74 06                	je     f0101393 <strlcpy+0x29>
f010138d:	8a 0a                	mov    (%edx),%cl
f010138f:	84 c9                	test   %cl,%cl
f0101391:	75 f1                	jne    f0101384 <strlcpy+0x1a>
		*dst = '\0';
f0101393:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101396:	29 f0                	sub    %esi,%eax
}
f0101398:	5b                   	pop    %ebx
f0101399:	5e                   	pop    %esi
f010139a:	5d                   	pop    %ebp
f010139b:	c3                   	ret    
f010139c:	89 f0                	mov    %esi,%eax
f010139e:	eb f6                	jmp    f0101396 <strlcpy+0x2c>

f01013a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01013a0:	55                   	push   %ebp
f01013a1:	89 e5                	mov    %esp,%ebp
f01013a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01013a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01013a9:	eb 02                	jmp    f01013ad <strcmp+0xd>
		p++, q++;
f01013ab:	41                   	inc    %ecx
f01013ac:	42                   	inc    %edx
	while (*p && *p == *q)
f01013ad:	8a 01                	mov    (%ecx),%al
f01013af:	84 c0                	test   %al,%al
f01013b1:	74 04                	je     f01013b7 <strcmp+0x17>
f01013b3:	3a 02                	cmp    (%edx),%al
f01013b5:	74 f4                	je     f01013ab <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01013b7:	0f b6 c0             	movzbl %al,%eax
f01013ba:	0f b6 12             	movzbl (%edx),%edx
f01013bd:	29 d0                	sub    %edx,%eax
}
f01013bf:	5d                   	pop    %ebp
f01013c0:	c3                   	ret    

f01013c1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01013c1:	55                   	push   %ebp
f01013c2:	89 e5                	mov    %esp,%ebp
f01013c4:	53                   	push   %ebx
f01013c5:	8b 45 08             	mov    0x8(%ebp),%eax
f01013c8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01013cb:	89 c3                	mov    %eax,%ebx
f01013cd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01013d0:	eb 02                	jmp    f01013d4 <strncmp+0x13>
		n--, p++, q++;
f01013d2:	40                   	inc    %eax
f01013d3:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
f01013d4:	39 d8                	cmp    %ebx,%eax
f01013d6:	74 15                	je     f01013ed <strncmp+0x2c>
f01013d8:	8a 08                	mov    (%eax),%cl
f01013da:	84 c9                	test   %cl,%cl
f01013dc:	74 04                	je     f01013e2 <strncmp+0x21>
f01013de:	3a 0a                	cmp    (%edx),%cl
f01013e0:	74 f0                	je     f01013d2 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01013e2:	0f b6 00             	movzbl (%eax),%eax
f01013e5:	0f b6 12             	movzbl (%edx),%edx
f01013e8:	29 d0                	sub    %edx,%eax
}
f01013ea:	5b                   	pop    %ebx
f01013eb:	5d                   	pop    %ebp
f01013ec:	c3                   	ret    
		return 0;
f01013ed:	b8 00 00 00 00       	mov    $0x0,%eax
f01013f2:	eb f6                	jmp    f01013ea <strncmp+0x29>

f01013f4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01013f4:	55                   	push   %ebp
f01013f5:	89 e5                	mov    %esp,%ebp
f01013f7:	8b 45 08             	mov    0x8(%ebp),%eax
f01013fa:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01013fd:	8a 10                	mov    (%eax),%dl
f01013ff:	84 d2                	test   %dl,%dl
f0101401:	74 07                	je     f010140a <strchr+0x16>
		if (*s == c)
f0101403:	38 ca                	cmp    %cl,%dl
f0101405:	74 08                	je     f010140f <strchr+0x1b>
	for (; *s; s++)
f0101407:	40                   	inc    %eax
f0101408:	eb f3                	jmp    f01013fd <strchr+0x9>
			return (char *) s;
	return 0;
f010140a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010140f:	5d                   	pop    %ebp
f0101410:	c3                   	ret    

f0101411 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101411:	55                   	push   %ebp
f0101412:	89 e5                	mov    %esp,%ebp
f0101414:	8b 45 08             	mov    0x8(%ebp),%eax
f0101417:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010141a:	8a 10                	mov    (%eax),%dl
f010141c:	84 d2                	test   %dl,%dl
f010141e:	74 07                	je     f0101427 <strfind+0x16>
		if (*s == c)
f0101420:	38 ca                	cmp    %cl,%dl
f0101422:	74 03                	je     f0101427 <strfind+0x16>
	for (; *s; s++)
f0101424:	40                   	inc    %eax
f0101425:	eb f3                	jmp    f010141a <strfind+0x9>
			break;
	return (char *) s;
}
f0101427:	5d                   	pop    %ebp
f0101428:	c3                   	ret    

f0101429 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101429:	55                   	push   %ebp
f010142a:	89 e5                	mov    %esp,%ebp
f010142c:	57                   	push   %edi
f010142d:	56                   	push   %esi
f010142e:	53                   	push   %ebx
f010142f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101432:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101435:	85 c9                	test   %ecx,%ecx
f0101437:	74 13                	je     f010144c <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101439:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010143f:	75 05                	jne    f0101446 <memset+0x1d>
f0101441:	f6 c1 03             	test   $0x3,%cl
f0101444:	74 0d                	je     f0101453 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101446:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101449:	fc                   	cld    
f010144a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010144c:	89 f8                	mov    %edi,%eax
f010144e:	5b                   	pop    %ebx
f010144f:	5e                   	pop    %esi
f0101450:	5f                   	pop    %edi
f0101451:	5d                   	pop    %ebp
f0101452:	c3                   	ret    
		c &= 0xFF;
f0101453:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101457:	89 d3                	mov    %edx,%ebx
f0101459:	c1 e3 08             	shl    $0x8,%ebx
f010145c:	89 d0                	mov    %edx,%eax
f010145e:	c1 e0 18             	shl    $0x18,%eax
f0101461:	89 d6                	mov    %edx,%esi
f0101463:	c1 e6 10             	shl    $0x10,%esi
f0101466:	09 f0                	or     %esi,%eax
f0101468:	09 c2                	or     %eax,%edx
f010146a:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f010146c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010146f:	89 d0                	mov    %edx,%eax
f0101471:	fc                   	cld    
f0101472:	f3 ab                	rep stos %eax,%es:(%edi)
f0101474:	eb d6                	jmp    f010144c <memset+0x23>

f0101476 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101476:	55                   	push   %ebp
f0101477:	89 e5                	mov    %esp,%ebp
f0101479:	57                   	push   %edi
f010147a:	56                   	push   %esi
f010147b:	8b 45 08             	mov    0x8(%ebp),%eax
f010147e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101481:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101484:	39 c6                	cmp    %eax,%esi
f0101486:	73 33                	jae    f01014bb <memmove+0x45>
f0101488:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010148b:	39 c2                	cmp    %eax,%edx
f010148d:	76 2c                	jbe    f01014bb <memmove+0x45>
		s += n;
		d += n;
f010148f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101492:	89 d6                	mov    %edx,%esi
f0101494:	09 fe                	or     %edi,%esi
f0101496:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010149c:	74 0a                	je     f01014a8 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010149e:	4f                   	dec    %edi
f010149f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01014a2:	fd                   	std    
f01014a3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01014a5:	fc                   	cld    
f01014a6:	eb 21                	jmp    f01014c9 <memmove+0x53>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01014a8:	f6 c1 03             	test   $0x3,%cl
f01014ab:	75 f1                	jne    f010149e <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01014ad:	83 ef 04             	sub    $0x4,%edi
f01014b0:	8d 72 fc             	lea    -0x4(%edx),%esi
f01014b3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01014b6:	fd                   	std    
f01014b7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01014b9:	eb ea                	jmp    f01014a5 <memmove+0x2f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01014bb:	89 f2                	mov    %esi,%edx
f01014bd:	09 c2                	or     %eax,%edx
f01014bf:	f6 c2 03             	test   $0x3,%dl
f01014c2:	74 09                	je     f01014cd <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01014c4:	89 c7                	mov    %eax,%edi
f01014c6:	fc                   	cld    
f01014c7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01014c9:	5e                   	pop    %esi
f01014ca:	5f                   	pop    %edi
f01014cb:	5d                   	pop    %ebp
f01014cc:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01014cd:	f6 c1 03             	test   $0x3,%cl
f01014d0:	75 f2                	jne    f01014c4 <memmove+0x4e>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01014d2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01014d5:	89 c7                	mov    %eax,%edi
f01014d7:	fc                   	cld    
f01014d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01014da:	eb ed                	jmp    f01014c9 <memmove+0x53>

f01014dc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01014dc:	55                   	push   %ebp
f01014dd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01014df:	ff 75 10             	pushl  0x10(%ebp)
f01014e2:	ff 75 0c             	pushl  0xc(%ebp)
f01014e5:	ff 75 08             	pushl  0x8(%ebp)
f01014e8:	e8 89 ff ff ff       	call   f0101476 <memmove>
}
f01014ed:	c9                   	leave  
f01014ee:	c3                   	ret    

f01014ef <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01014ef:	55                   	push   %ebp
f01014f0:	89 e5                	mov    %esp,%ebp
f01014f2:	56                   	push   %esi
f01014f3:	53                   	push   %ebx
f01014f4:	8b 45 08             	mov    0x8(%ebp),%eax
f01014f7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01014fa:	89 c6                	mov    %eax,%esi
f01014fc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01014ff:	39 f0                	cmp    %esi,%eax
f0101501:	74 16                	je     f0101519 <memcmp+0x2a>
		if (*s1 != *s2)
f0101503:	8a 08                	mov    (%eax),%cl
f0101505:	8a 1a                	mov    (%edx),%bl
f0101507:	38 d9                	cmp    %bl,%cl
f0101509:	75 04                	jne    f010150f <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010150b:	40                   	inc    %eax
f010150c:	42                   	inc    %edx
f010150d:	eb f0                	jmp    f01014ff <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f010150f:	0f b6 c1             	movzbl %cl,%eax
f0101512:	0f b6 db             	movzbl %bl,%ebx
f0101515:	29 d8                	sub    %ebx,%eax
f0101517:	eb 05                	jmp    f010151e <memcmp+0x2f>
	}

	return 0;
f0101519:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010151e:	5b                   	pop    %ebx
f010151f:	5e                   	pop    %esi
f0101520:	5d                   	pop    %ebp
f0101521:	c3                   	ret    

f0101522 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101522:	55                   	push   %ebp
f0101523:	89 e5                	mov    %esp,%ebp
f0101525:	8b 45 08             	mov    0x8(%ebp),%eax
f0101528:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010152b:	89 c2                	mov    %eax,%edx
f010152d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101530:	39 d0                	cmp    %edx,%eax
f0101532:	73 07                	jae    f010153b <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101534:	38 08                	cmp    %cl,(%eax)
f0101536:	74 03                	je     f010153b <memfind+0x19>
	for (; s < ends; s++)
f0101538:	40                   	inc    %eax
f0101539:	eb f5                	jmp    f0101530 <memfind+0xe>
			break;
	return (void *) s;
}
f010153b:	5d                   	pop    %ebp
f010153c:	c3                   	ret    

f010153d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010153d:	55                   	push   %ebp
f010153e:	89 e5                	mov    %esp,%ebp
f0101540:	57                   	push   %edi
f0101541:	56                   	push   %esi
f0101542:	53                   	push   %ebx
f0101543:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101546:	eb 01                	jmp    f0101549 <strtol+0xc>
		s++;
f0101548:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f0101549:	8a 01                	mov    (%ecx),%al
f010154b:	3c 20                	cmp    $0x20,%al
f010154d:	74 f9                	je     f0101548 <strtol+0xb>
f010154f:	3c 09                	cmp    $0x9,%al
f0101551:	74 f5                	je     f0101548 <strtol+0xb>

	// plus/minus sign
	if (*s == '+')
f0101553:	3c 2b                	cmp    $0x2b,%al
f0101555:	74 2b                	je     f0101582 <strtol+0x45>
		s++;
	else if (*s == '-')
f0101557:	3c 2d                	cmp    $0x2d,%al
f0101559:	74 2f                	je     f010158a <strtol+0x4d>
	int neg = 0;
f010155b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101560:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f0101567:	75 12                	jne    f010157b <strtol+0x3e>
f0101569:	80 39 30             	cmpb   $0x30,(%ecx)
f010156c:	74 24                	je     f0101592 <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010156e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101572:	75 07                	jne    f010157b <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101574:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f010157b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101580:	eb 4e                	jmp    f01015d0 <strtol+0x93>
		s++;
f0101582:	41                   	inc    %ecx
	int neg = 0;
f0101583:	bf 00 00 00 00       	mov    $0x0,%edi
f0101588:	eb d6                	jmp    f0101560 <strtol+0x23>
		s++, neg = 1;
f010158a:	41                   	inc    %ecx
f010158b:	bf 01 00 00 00       	mov    $0x1,%edi
f0101590:	eb ce                	jmp    f0101560 <strtol+0x23>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101592:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101596:	74 10                	je     f01015a8 <strtol+0x6b>
	else if (base == 0 && s[0] == '0')
f0101598:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010159c:	75 dd                	jne    f010157b <strtol+0x3e>
		s++, base = 8;
f010159e:	41                   	inc    %ecx
f010159f:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f01015a6:	eb d3                	jmp    f010157b <strtol+0x3e>
		s += 2, base = 16;
f01015a8:	83 c1 02             	add    $0x2,%ecx
f01015ab:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f01015b2:	eb c7                	jmp    f010157b <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01015b4:	8d 72 9f             	lea    -0x61(%edx),%esi
f01015b7:	89 f3                	mov    %esi,%ebx
f01015b9:	80 fb 19             	cmp    $0x19,%bl
f01015bc:	77 24                	ja     f01015e2 <strtol+0xa5>
			dig = *s - 'a' + 10;
f01015be:	0f be d2             	movsbl %dl,%edx
f01015c1:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01015c4:	3b 55 10             	cmp    0x10(%ebp),%edx
f01015c7:	7d 2b                	jge    f01015f4 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
f01015c9:	41                   	inc    %ecx
f01015ca:	0f af 45 10          	imul   0x10(%ebp),%eax
f01015ce:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01015d0:	8a 11                	mov    (%ecx),%dl
f01015d2:	8d 5a d0             	lea    -0x30(%edx),%ebx
f01015d5:	80 fb 09             	cmp    $0x9,%bl
f01015d8:	77 da                	ja     f01015b4 <strtol+0x77>
			dig = *s - '0';
f01015da:	0f be d2             	movsbl %dl,%edx
f01015dd:	83 ea 30             	sub    $0x30,%edx
f01015e0:	eb e2                	jmp    f01015c4 <strtol+0x87>
		else if (*s >= 'A' && *s <= 'Z')
f01015e2:	8d 72 bf             	lea    -0x41(%edx),%esi
f01015e5:	89 f3                	mov    %esi,%ebx
f01015e7:	80 fb 19             	cmp    $0x19,%bl
f01015ea:	77 08                	ja     f01015f4 <strtol+0xb7>
			dig = *s - 'A' + 10;
f01015ec:	0f be d2             	movsbl %dl,%edx
f01015ef:	83 ea 37             	sub    $0x37,%edx
f01015f2:	eb d0                	jmp    f01015c4 <strtol+0x87>
		// we don't properly detect overflow!
	}

	if (endptr)
f01015f4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01015f8:	74 05                	je     f01015ff <strtol+0xc2>
		*endptr = (char *) s;
f01015fa:	8b 75 0c             	mov    0xc(%ebp),%esi
f01015fd:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f01015ff:	85 ff                	test   %edi,%edi
f0101601:	74 02                	je     f0101605 <strtol+0xc8>
f0101603:	f7 d8                	neg    %eax
}
f0101605:	5b                   	pop    %ebx
f0101606:	5e                   	pop    %esi
f0101607:	5f                   	pop    %edi
f0101608:	5d                   	pop    %ebp
f0101609:	c3                   	ret    
f010160a:	66 90                	xchg   %ax,%ax

f010160c <__udivdi3>:
f010160c:	55                   	push   %ebp
f010160d:	57                   	push   %edi
f010160e:	56                   	push   %esi
f010160f:	53                   	push   %ebx
f0101610:	83 ec 1c             	sub    $0x1c,%esp
f0101613:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0101617:	8b 74 24 34          	mov    0x34(%esp),%esi
f010161b:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010161f:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0101623:	85 d2                	test   %edx,%edx
f0101625:	75 2d                	jne    f0101654 <__udivdi3+0x48>
f0101627:	39 f7                	cmp    %esi,%edi
f0101629:	77 59                	ja     f0101684 <__udivdi3+0x78>
f010162b:	89 f9                	mov    %edi,%ecx
f010162d:	85 ff                	test   %edi,%edi
f010162f:	75 0b                	jne    f010163c <__udivdi3+0x30>
f0101631:	b8 01 00 00 00       	mov    $0x1,%eax
f0101636:	31 d2                	xor    %edx,%edx
f0101638:	f7 f7                	div    %edi
f010163a:	89 c1                	mov    %eax,%ecx
f010163c:	31 d2                	xor    %edx,%edx
f010163e:	89 f0                	mov    %esi,%eax
f0101640:	f7 f1                	div    %ecx
f0101642:	89 c3                	mov    %eax,%ebx
f0101644:	89 e8                	mov    %ebp,%eax
f0101646:	f7 f1                	div    %ecx
f0101648:	89 da                	mov    %ebx,%edx
f010164a:	83 c4 1c             	add    $0x1c,%esp
f010164d:	5b                   	pop    %ebx
f010164e:	5e                   	pop    %esi
f010164f:	5f                   	pop    %edi
f0101650:	5d                   	pop    %ebp
f0101651:	c3                   	ret    
f0101652:	66 90                	xchg   %ax,%ax
f0101654:	39 f2                	cmp    %esi,%edx
f0101656:	77 1c                	ja     f0101674 <__udivdi3+0x68>
f0101658:	0f bd da             	bsr    %edx,%ebx
f010165b:	83 f3 1f             	xor    $0x1f,%ebx
f010165e:	75 38                	jne    f0101698 <__udivdi3+0x8c>
f0101660:	39 f2                	cmp    %esi,%edx
f0101662:	72 08                	jb     f010166c <__udivdi3+0x60>
f0101664:	39 ef                	cmp    %ebp,%edi
f0101666:	0f 87 98 00 00 00    	ja     f0101704 <__udivdi3+0xf8>
f010166c:	b8 01 00 00 00       	mov    $0x1,%eax
f0101671:	eb 05                	jmp    f0101678 <__udivdi3+0x6c>
f0101673:	90                   	nop
f0101674:	31 db                	xor    %ebx,%ebx
f0101676:	31 c0                	xor    %eax,%eax
f0101678:	89 da                	mov    %ebx,%edx
f010167a:	83 c4 1c             	add    $0x1c,%esp
f010167d:	5b                   	pop    %ebx
f010167e:	5e                   	pop    %esi
f010167f:	5f                   	pop    %edi
f0101680:	5d                   	pop    %ebp
f0101681:	c3                   	ret    
f0101682:	66 90                	xchg   %ax,%ax
f0101684:	89 e8                	mov    %ebp,%eax
f0101686:	89 f2                	mov    %esi,%edx
f0101688:	f7 f7                	div    %edi
f010168a:	31 db                	xor    %ebx,%ebx
f010168c:	89 da                	mov    %ebx,%edx
f010168e:	83 c4 1c             	add    $0x1c,%esp
f0101691:	5b                   	pop    %ebx
f0101692:	5e                   	pop    %esi
f0101693:	5f                   	pop    %edi
f0101694:	5d                   	pop    %ebp
f0101695:	c3                   	ret    
f0101696:	66 90                	xchg   %ax,%ax
f0101698:	b8 20 00 00 00       	mov    $0x20,%eax
f010169d:	29 d8                	sub    %ebx,%eax
f010169f:	88 d9                	mov    %bl,%cl
f01016a1:	d3 e2                	shl    %cl,%edx
f01016a3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01016a7:	89 fa                	mov    %edi,%edx
f01016a9:	88 c1                	mov    %al,%cl
f01016ab:	d3 ea                	shr    %cl,%edx
f01016ad:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01016b1:	09 d1                	or     %edx,%ecx
f01016b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01016b7:	88 d9                	mov    %bl,%cl
f01016b9:	d3 e7                	shl    %cl,%edi
f01016bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01016bf:	89 f7                	mov    %esi,%edi
f01016c1:	88 c1                	mov    %al,%cl
f01016c3:	d3 ef                	shr    %cl,%edi
f01016c5:	88 d9                	mov    %bl,%cl
f01016c7:	d3 e6                	shl    %cl,%esi
f01016c9:	89 ea                	mov    %ebp,%edx
f01016cb:	88 c1                	mov    %al,%cl
f01016cd:	d3 ea                	shr    %cl,%edx
f01016cf:	09 d6                	or     %edx,%esi
f01016d1:	89 f0                	mov    %esi,%eax
f01016d3:	89 fa                	mov    %edi,%edx
f01016d5:	f7 74 24 08          	divl   0x8(%esp)
f01016d9:	89 d7                	mov    %edx,%edi
f01016db:	89 c6                	mov    %eax,%esi
f01016dd:	f7 64 24 0c          	mull   0xc(%esp)
f01016e1:	39 d7                	cmp    %edx,%edi
f01016e3:	72 13                	jb     f01016f8 <__udivdi3+0xec>
f01016e5:	74 09                	je     f01016f0 <__udivdi3+0xe4>
f01016e7:	89 f0                	mov    %esi,%eax
f01016e9:	31 db                	xor    %ebx,%ebx
f01016eb:	eb 8b                	jmp    f0101678 <__udivdi3+0x6c>
f01016ed:	8d 76 00             	lea    0x0(%esi),%esi
f01016f0:	88 d9                	mov    %bl,%cl
f01016f2:	d3 e5                	shl    %cl,%ebp
f01016f4:	39 c5                	cmp    %eax,%ebp
f01016f6:	73 ef                	jae    f01016e7 <__udivdi3+0xdb>
f01016f8:	8d 46 ff             	lea    -0x1(%esi),%eax
f01016fb:	31 db                	xor    %ebx,%ebx
f01016fd:	e9 76 ff ff ff       	jmp    f0101678 <__udivdi3+0x6c>
f0101702:	66 90                	xchg   %ax,%ax
f0101704:	31 c0                	xor    %eax,%eax
f0101706:	e9 6d ff ff ff       	jmp    f0101678 <__udivdi3+0x6c>
f010170b:	90                   	nop

f010170c <__umoddi3>:
f010170c:	55                   	push   %ebp
f010170d:	57                   	push   %edi
f010170e:	56                   	push   %esi
f010170f:	53                   	push   %ebx
f0101710:	83 ec 1c             	sub    $0x1c,%esp
f0101713:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101717:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f010171b:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010171f:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0101723:	89 f0                	mov    %esi,%eax
f0101725:	89 da                	mov    %ebx,%edx
f0101727:	85 ed                	test   %ebp,%ebp
f0101729:	75 15                	jne    f0101740 <__umoddi3+0x34>
f010172b:	39 df                	cmp    %ebx,%edi
f010172d:	76 39                	jbe    f0101768 <__umoddi3+0x5c>
f010172f:	f7 f7                	div    %edi
f0101731:	89 d0                	mov    %edx,%eax
f0101733:	31 d2                	xor    %edx,%edx
f0101735:	83 c4 1c             	add    $0x1c,%esp
f0101738:	5b                   	pop    %ebx
f0101739:	5e                   	pop    %esi
f010173a:	5f                   	pop    %edi
f010173b:	5d                   	pop    %ebp
f010173c:	c3                   	ret    
f010173d:	8d 76 00             	lea    0x0(%esi),%esi
f0101740:	39 dd                	cmp    %ebx,%ebp
f0101742:	77 f1                	ja     f0101735 <__umoddi3+0x29>
f0101744:	0f bd cd             	bsr    %ebp,%ecx
f0101747:	83 f1 1f             	xor    $0x1f,%ecx
f010174a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010174e:	75 38                	jne    f0101788 <__umoddi3+0x7c>
f0101750:	39 dd                	cmp    %ebx,%ebp
f0101752:	72 04                	jb     f0101758 <__umoddi3+0x4c>
f0101754:	39 f7                	cmp    %esi,%edi
f0101756:	77 dd                	ja     f0101735 <__umoddi3+0x29>
f0101758:	89 da                	mov    %ebx,%edx
f010175a:	89 f0                	mov    %esi,%eax
f010175c:	29 f8                	sub    %edi,%eax
f010175e:	19 ea                	sbb    %ebp,%edx
f0101760:	83 c4 1c             	add    $0x1c,%esp
f0101763:	5b                   	pop    %ebx
f0101764:	5e                   	pop    %esi
f0101765:	5f                   	pop    %edi
f0101766:	5d                   	pop    %ebp
f0101767:	c3                   	ret    
f0101768:	89 f9                	mov    %edi,%ecx
f010176a:	85 ff                	test   %edi,%edi
f010176c:	75 0b                	jne    f0101779 <__umoddi3+0x6d>
f010176e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101773:	31 d2                	xor    %edx,%edx
f0101775:	f7 f7                	div    %edi
f0101777:	89 c1                	mov    %eax,%ecx
f0101779:	89 d8                	mov    %ebx,%eax
f010177b:	31 d2                	xor    %edx,%edx
f010177d:	f7 f1                	div    %ecx
f010177f:	89 f0                	mov    %esi,%eax
f0101781:	f7 f1                	div    %ecx
f0101783:	eb ac                	jmp    f0101731 <__umoddi3+0x25>
f0101785:	8d 76 00             	lea    0x0(%esi),%esi
f0101788:	b8 20 00 00 00       	mov    $0x20,%eax
f010178d:	89 c2                	mov    %eax,%edx
f010178f:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101793:	29 c2                	sub    %eax,%edx
f0101795:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101799:	88 c1                	mov    %al,%cl
f010179b:	d3 e5                	shl    %cl,%ebp
f010179d:	89 f8                	mov    %edi,%eax
f010179f:	88 d1                	mov    %dl,%cl
f01017a1:	d3 e8                	shr    %cl,%eax
f01017a3:	09 c5                	or     %eax,%ebp
f01017a5:	8b 44 24 04          	mov    0x4(%esp),%eax
f01017a9:	88 c1                	mov    %al,%cl
f01017ab:	d3 e7                	shl    %cl,%edi
f01017ad:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01017b1:	89 df                	mov    %ebx,%edi
f01017b3:	88 d1                	mov    %dl,%cl
f01017b5:	d3 ef                	shr    %cl,%edi
f01017b7:	88 c1                	mov    %al,%cl
f01017b9:	d3 e3                	shl    %cl,%ebx
f01017bb:	89 f0                	mov    %esi,%eax
f01017bd:	88 d1                	mov    %dl,%cl
f01017bf:	d3 e8                	shr    %cl,%eax
f01017c1:	09 d8                	or     %ebx,%eax
f01017c3:	8a 4c 24 04          	mov    0x4(%esp),%cl
f01017c7:	d3 e6                	shl    %cl,%esi
f01017c9:	89 fa                	mov    %edi,%edx
f01017cb:	f7 f5                	div    %ebp
f01017cd:	89 d1                	mov    %edx,%ecx
f01017cf:	f7 64 24 08          	mull   0x8(%esp)
f01017d3:	89 c3                	mov    %eax,%ebx
f01017d5:	89 d7                	mov    %edx,%edi
f01017d7:	39 d1                	cmp    %edx,%ecx
f01017d9:	72 29                	jb     f0101804 <__umoddi3+0xf8>
f01017db:	74 23                	je     f0101800 <__umoddi3+0xf4>
f01017dd:	89 ca                	mov    %ecx,%edx
f01017df:	29 de                	sub    %ebx,%esi
f01017e1:	19 fa                	sbb    %edi,%edx
f01017e3:	89 d0                	mov    %edx,%eax
f01017e5:	8a 4c 24 0c          	mov    0xc(%esp),%cl
f01017e9:	d3 e0                	shl    %cl,%eax
f01017eb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f01017ef:	88 d9                	mov    %bl,%cl
f01017f1:	d3 ee                	shr    %cl,%esi
f01017f3:	09 f0                	or     %esi,%eax
f01017f5:	d3 ea                	shr    %cl,%edx
f01017f7:	83 c4 1c             	add    $0x1c,%esp
f01017fa:	5b                   	pop    %ebx
f01017fb:	5e                   	pop    %esi
f01017fc:	5f                   	pop    %edi
f01017fd:	5d                   	pop    %ebp
f01017fe:	c3                   	ret    
f01017ff:	90                   	nop
f0101800:	39 c6                	cmp    %eax,%esi
f0101802:	73 d9                	jae    f01017dd <__umoddi3+0xd1>
f0101804:	2b 44 24 08          	sub    0x8(%esp),%eax
f0101808:	19 ea                	sbb    %ebp,%edx
f010180a:	89 d7                	mov    %edx,%edi
f010180c:	89 c3                	mov    %eax,%ebx
f010180e:	eb cd                	jmp    f01017dd <__umoddi3+0xd1>
