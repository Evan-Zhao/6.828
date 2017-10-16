
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
f0100015:	b8 00 30 11 00       	mov    $0x113000,%eax
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
f0100034:	bc 00 30 11 f0       	mov    $0xf0113000,%esp

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
f010004b:	68 80 24 10 f0       	push   $0xf0102480
f0100050:	e8 08 15 00 00       	call   f010155d <cprintf>
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
f0100065:	e8 1f 07 00 00       	call   f0100789 <mon_backtrace>
f010006a:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010006d:	83 ec 08             	sub    $0x8,%esp
f0100070:	53                   	push   %ebx
f0100071:	68 9c 24 10 f0       	push   $0xf010249c
f0100076:	e8 e2 14 00 00       	call   f010155d <cprintf>
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
f010009a:	b8 70 59 11 f0       	mov    $0xf0115970,%eax
f010009f:	2d 00 53 11 f0       	sub    $0xf0115300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 53 11 f0       	push   $0xf0115300
f01000ac:	e8 db 1f 00 00       	call   f010208c <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 d8 04 00 00       	call   f010058e <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 b7 24 10 f0       	push   $0xf01024b7
f01000c3:	e8 95 14 00 00       	call   f010155d <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000c8:	e8 1e 0b 00 00       	call   f0100beb <mem_init>
	cprintf(ANSI_COLOR_RED     "This text is RED!"     ANSI_COLOR_RESET "\n");
f01000cd:	c7 04 24 d2 24 10 f0 	movl   $0xf01024d2,(%esp)
f01000d4:	e8 84 14 00 00       	call   f010155d <cprintf>
	cprintf(ANSI_COLOR_GREEN   "This text is GREEN!"   ANSI_COLOR_RESET "\n");
f01000d9:	c7 04 24 ee 24 10 f0 	movl   $0xf01024ee,(%esp)
f01000e0:	e8 78 14 00 00       	call   f010155d <cprintf>
	cprintf(ANSI_COLOR_YELLOW  "This text is YELLOW!"  ANSI_COLOR_RESET "\n");
f01000e5:	c7 04 24 78 25 10 f0 	movl   $0xf0102578,(%esp)
f01000ec:	e8 6c 14 00 00       	call   f010155d <cprintf>
	cprintf(ANSI_COLOR_BLUE    "This text is BLUE!"    ANSI_COLOR_RESET "\n");
f01000f1:	c7 04 24 0c 25 10 f0 	movl   $0xf010250c,(%esp)
f01000f8:	e8 60 14 00 00       	call   f010155d <cprintf>
	cprintf(ANSI_COLOR_MAGENTA "This text is MAGENTA!" ANSI_COLOR_RESET "\n");
f01000fd:	c7 04 24 98 25 10 f0 	movl   $0xf0102598,(%esp)
f0100104:	e8 54 14 00 00       	call   f010155d <cprintf>
	cprintf(ANSI_COLOR_CYAN    "This text is CYAN!"    ANSI_COLOR_RESET "\n");
f0100109:	c7 04 24 29 25 10 f0 	movl   $0xf0102529,(%esp)
f0100110:	e8 48 14 00 00       	call   f010155d <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f0100115:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f010011c:	e8 1f ff ff ff       	call   f0100040 <test_backtrace>
f0100121:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100124:	83 ec 0c             	sub    $0xc,%esp
f0100127:	6a 00                	push   $0x0
f0100129:	e8 ff 06 00 00       	call   f010082d <monitor>
f010012e:	83 c4 10             	add    $0x10,%esp
f0100131:	eb f1                	jmp    f0100124 <i386_init+0x90>

f0100133 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100133:	55                   	push   %ebp
f0100134:	89 e5                	mov    %esp,%ebp
f0100136:	56                   	push   %esi
f0100137:	53                   	push   %ebx
f0100138:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010013b:	83 3d 60 59 11 f0 00 	cmpl   $0x0,0xf0115960
f0100142:	74 0f                	je     f0100153 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100144:	83 ec 0c             	sub    $0xc,%esp
f0100147:	6a 00                	push   $0x0
f0100149:	e8 df 06 00 00       	call   f010082d <monitor>
f010014e:	83 c4 10             	add    $0x10,%esp
f0100151:	eb f1                	jmp    f0100144 <_panic+0x11>
	panicstr = fmt;
f0100153:	89 35 60 59 11 f0    	mov    %esi,0xf0115960
	asm volatile("cli; cld");
f0100159:	fa                   	cli    
f010015a:	fc                   	cld    
	va_start(ap, fmt);
f010015b:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f010015e:	83 ec 04             	sub    $0x4,%esp
f0100161:	ff 75 0c             	pushl  0xc(%ebp)
f0100164:	ff 75 08             	pushl  0x8(%ebp)
f0100167:	68 46 25 10 f0       	push   $0xf0102546
f010016c:	e8 ec 13 00 00       	call   f010155d <cprintf>
	vcprintf(fmt, ap);
f0100171:	83 c4 08             	add    $0x8,%esp
f0100174:	53                   	push   %ebx
f0100175:	56                   	push   %esi
f0100176:	e8 bc 13 00 00       	call   f0101537 <vcprintf>
	cprintf("\n");
f010017b:	c7 04 24 c2 25 10 f0 	movl   $0xf01025c2,(%esp)
f0100182:	e8 d6 13 00 00       	call   f010155d <cprintf>
f0100187:	83 c4 10             	add    $0x10,%esp
f010018a:	eb b8                	jmp    f0100144 <_panic+0x11>

f010018c <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010018c:	55                   	push   %ebp
f010018d:	89 e5                	mov    %esp,%ebp
f010018f:	53                   	push   %ebx
f0100190:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100193:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100196:	ff 75 0c             	pushl  0xc(%ebp)
f0100199:	ff 75 08             	pushl  0x8(%ebp)
f010019c:	68 5e 25 10 f0       	push   $0xf010255e
f01001a1:	e8 b7 13 00 00       	call   f010155d <cprintf>
	vcprintf(fmt, ap);
f01001a6:	83 c4 08             	add    $0x8,%esp
f01001a9:	53                   	push   %ebx
f01001aa:	ff 75 10             	pushl  0x10(%ebp)
f01001ad:	e8 85 13 00 00       	call   f0101537 <vcprintf>
	cprintf("\n");
f01001b2:	c7 04 24 c2 25 10 f0 	movl   $0xf01025c2,(%esp)
f01001b9:	e8 9f 13 00 00       	call   f010155d <cprintf>
	va_end(ap);
}
f01001be:	83 c4 10             	add    $0x10,%esp
f01001c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01001c4:	c9                   	leave  
f01001c5:	c3                   	ret    

f01001c6 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001c6:	55                   	push   %ebp
f01001c7:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c9:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001ce:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001cf:	a8 01                	test   $0x1,%al
f01001d1:	74 0b                	je     f01001de <serial_proc_data+0x18>
f01001d3:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001d8:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001d9:	0f b6 c0             	movzbl %al,%eax
}
f01001dc:	5d                   	pop    %ebp
f01001dd:	c3                   	ret    
		return -1;
f01001de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001e3:	eb f7                	jmp    f01001dc <serial_proc_data+0x16>

f01001e5 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001e5:	55                   	push   %ebp
f01001e6:	89 e5                	mov    %esp,%ebp
f01001e8:	53                   	push   %ebx
f01001e9:	83 ec 04             	sub    $0x4,%esp
f01001ec:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001ee:	ff d3                	call   *%ebx
f01001f0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001f3:	74 2d                	je     f0100222 <cons_intr+0x3d>
		if (c == 0)
f01001f5:	85 c0                	test   %eax,%eax
f01001f7:	74 f5                	je     f01001ee <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f01001f9:	8b 0d 24 55 11 f0    	mov    0xf0115524,%ecx
f01001ff:	8d 51 01             	lea    0x1(%ecx),%edx
f0100202:	89 15 24 55 11 f0    	mov    %edx,0xf0115524
f0100208:	88 81 20 53 11 f0    	mov    %al,-0xfeeace0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010020e:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100214:	75 d8                	jne    f01001ee <cons_intr+0x9>
			cons.wpos = 0;
f0100216:	c7 05 24 55 11 f0 00 	movl   $0x0,0xf0115524
f010021d:	00 00 00 
f0100220:	eb cc                	jmp    f01001ee <cons_intr+0x9>
	}
}
f0100222:	83 c4 04             	add    $0x4,%esp
f0100225:	5b                   	pop    %ebx
f0100226:	5d                   	pop    %ebp
f0100227:	c3                   	ret    

f0100228 <kbd_proc_data>:
{
f0100228:	55                   	push   %ebp
f0100229:	89 e5                	mov    %esp,%ebp
f010022b:	53                   	push   %ebx
f010022c:	83 ec 04             	sub    $0x4,%esp
f010022f:	ba 64 00 00 00       	mov    $0x64,%edx
f0100234:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100235:	a8 01                	test   $0x1,%al
f0100237:	0f 84 f1 00 00 00    	je     f010032e <kbd_proc_data+0x106>
	if (stat & KBS_TERR)
f010023d:	a8 20                	test   $0x20,%al
f010023f:	0f 85 f0 00 00 00    	jne    f0100335 <kbd_proc_data+0x10d>
f0100245:	ba 60 00 00 00       	mov    $0x60,%edx
f010024a:	ec                   	in     (%dx),%al
f010024b:	88 c2                	mov    %al,%dl
	if (data == 0xE0) {
f010024d:	3c e0                	cmp    $0xe0,%al
f010024f:	0f 84 8a 00 00 00    	je     f01002df <kbd_proc_data+0xb7>
	} else if (data & 0x80) {
f0100255:	84 c0                	test   %al,%al
f0100257:	0f 88 95 00 00 00    	js     f01002f2 <kbd_proc_data+0xca>
	} else if (shift & E0ESC) {
f010025d:	8b 0d 00 53 11 f0    	mov    0xf0115300,%ecx
f0100263:	f6 c1 40             	test   $0x40,%cl
f0100266:	74 0e                	je     f0100276 <kbd_proc_data+0x4e>
		data |= 0x80;
f0100268:	83 c8 80             	or     $0xffffff80,%eax
f010026b:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f010026d:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100270:	89 0d 00 53 11 f0    	mov    %ecx,0xf0115300
	shift |= shiftcode[data];
f0100276:	0f b6 d2             	movzbl %dl,%edx
f0100279:	0f b6 82 20 27 10 f0 	movzbl -0xfefd8e0(%edx),%eax
f0100280:	0b 05 00 53 11 f0    	or     0xf0115300,%eax
	shift ^= togglecode[data];
f0100286:	0f b6 8a 20 26 10 f0 	movzbl -0xfefd9e0(%edx),%ecx
f010028d:	31 c8                	xor    %ecx,%eax
f010028f:	a3 00 53 11 f0       	mov    %eax,0xf0115300
	c = charcode[shift & (CTL | SHIFT)][data];
f0100294:	89 c1                	mov    %eax,%ecx
f0100296:	83 e1 03             	and    $0x3,%ecx
f0100299:	8b 0c 8d 00 26 10 f0 	mov    -0xfefda00(,%ecx,4),%ecx
f01002a0:	8a 14 11             	mov    (%ecx,%edx,1),%dl
f01002a3:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01002a6:	a8 08                	test   $0x8,%al
f01002a8:	74 0d                	je     f01002b7 <kbd_proc_data+0x8f>
		if ('a' <= c && c <= 'z')
f01002aa:	89 da                	mov    %ebx,%edx
f01002ac:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01002af:	83 f9 19             	cmp    $0x19,%ecx
f01002b2:	77 6d                	ja     f0100321 <kbd_proc_data+0xf9>
			c += 'A' - 'a';
f01002b4:	83 eb 20             	sub    $0x20,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002b7:	f7 d0                	not    %eax
f01002b9:	a8 06                	test   $0x6,%al
f01002bb:	75 2e                	jne    f01002eb <kbd_proc_data+0xc3>
f01002bd:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002c3:	75 26                	jne    f01002eb <kbd_proc_data+0xc3>
		cprintf("Rebooting!\n");
f01002c5:	83 ec 0c             	sub    $0xc,%esp
f01002c8:	68 b8 25 10 f0       	push   $0xf01025b8
f01002cd:	e8 8b 12 00 00       	call   f010155d <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002d2:	b0 03                	mov    $0x3,%al
f01002d4:	ba 92 00 00 00       	mov    $0x92,%edx
f01002d9:	ee                   	out    %al,(%dx)
f01002da:	83 c4 10             	add    $0x10,%esp
f01002dd:	eb 0c                	jmp    f01002eb <kbd_proc_data+0xc3>
		shift |= E0ESC;
f01002df:	83 0d 00 53 11 f0 40 	orl    $0x40,0xf0115300
		return 0;
f01002e6:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f01002eb:	89 d8                	mov    %ebx,%eax
f01002ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002f0:	c9                   	leave  
f01002f1:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002f2:	8b 0d 00 53 11 f0    	mov    0xf0115300,%ecx
f01002f8:	f6 c1 40             	test   $0x40,%cl
f01002fb:	75 05                	jne    f0100302 <kbd_proc_data+0xda>
f01002fd:	83 e0 7f             	and    $0x7f,%eax
f0100300:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f0100302:	0f b6 d2             	movzbl %dl,%edx
f0100305:	8a 82 20 27 10 f0    	mov    -0xfefd8e0(%edx),%al
f010030b:	83 c8 40             	or     $0x40,%eax
f010030e:	0f b6 c0             	movzbl %al,%eax
f0100311:	f7 d0                	not    %eax
f0100313:	21 c8                	and    %ecx,%eax
f0100315:	a3 00 53 11 f0       	mov    %eax,0xf0115300
		return 0;
f010031a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010031f:	eb ca                	jmp    f01002eb <kbd_proc_data+0xc3>
		else if ('A' <= c && c <= 'Z')
f0100321:	83 ea 41             	sub    $0x41,%edx
f0100324:	83 fa 19             	cmp    $0x19,%edx
f0100327:	77 8e                	ja     f01002b7 <kbd_proc_data+0x8f>
			c += 'a' - 'A';
f0100329:	83 c3 20             	add    $0x20,%ebx
f010032c:	eb 89                	jmp    f01002b7 <kbd_proc_data+0x8f>
		return -1;
f010032e:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0100333:	eb b6                	jmp    f01002eb <kbd_proc_data+0xc3>
		return -1;
f0100335:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010033a:	eb af                	jmp    f01002eb <kbd_proc_data+0xc3>

f010033c <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010033c:	55                   	push   %ebp
f010033d:	89 e5                	mov    %esp,%ebp
f010033f:	57                   	push   %edi
f0100340:	56                   	push   %esi
f0100341:	53                   	push   %ebx
f0100342:	83 ec 1c             	sub    $0x1c,%esp
f0100345:	89 c7                	mov    %eax,%edi
f0100347:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010034c:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100351:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100356:	eb 06                	jmp    f010035e <cons_putc+0x22>
f0100358:	89 ca                	mov    %ecx,%edx
f010035a:	ec                   	in     (%dx),%al
f010035b:	ec                   	in     (%dx),%al
f010035c:	ec                   	in     (%dx),%al
f010035d:	ec                   	in     (%dx),%al
f010035e:	89 f2                	mov    %esi,%edx
f0100360:	ec                   	in     (%dx),%al
	for (i = 0;
f0100361:	a8 20                	test   $0x20,%al
f0100363:	75 03                	jne    f0100368 <cons_putc+0x2c>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100365:	4b                   	dec    %ebx
f0100366:	75 f0                	jne    f0100358 <cons_putc+0x1c>
	outb(COM1 + COM_TX, c);
f0100368:	89 f8                	mov    %edi,%eax
f010036a:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010036d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100372:	ee                   	out    %al,(%dx)
f0100373:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100378:	be 79 03 00 00       	mov    $0x379,%esi
f010037d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100382:	eb 06                	jmp    f010038a <cons_putc+0x4e>
f0100384:	89 ca                	mov    %ecx,%edx
f0100386:	ec                   	in     (%dx),%al
f0100387:	ec                   	in     (%dx),%al
f0100388:	ec                   	in     (%dx),%al
f0100389:	ec                   	in     (%dx),%al
f010038a:	89 f2                	mov    %esi,%edx
f010038c:	ec                   	in     (%dx),%al
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010038d:	84 c0                	test   %al,%al
f010038f:	78 03                	js     f0100394 <cons_putc+0x58>
f0100391:	4b                   	dec    %ebx
f0100392:	75 f0                	jne    f0100384 <cons_putc+0x48>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100394:	ba 78 03 00 00       	mov    $0x378,%edx
f0100399:	8a 45 e7             	mov    -0x19(%ebp),%al
f010039c:	ee                   	out    %al,(%dx)
f010039d:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003a2:	b0 0d                	mov    $0xd,%al
f01003a4:	ee                   	out    %al,(%dx)
f01003a5:	b0 08                	mov    $0x8,%al
f01003a7:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01003a8:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f01003ae:	75 06                	jne    f01003b6 <cons_putc+0x7a>
		c |= 0x0700;
f01003b0:	81 cf 00 07 00 00    	or     $0x700,%edi
	switch (c & 0xff) {
f01003b6:	89 f8                	mov    %edi,%eax
f01003b8:	0f b6 c0             	movzbl %al,%eax
f01003bb:	83 f8 09             	cmp    $0x9,%eax
f01003be:	0f 84 b1 00 00 00    	je     f0100475 <cons_putc+0x139>
f01003c4:	83 f8 09             	cmp    $0x9,%eax
f01003c7:	7e 70                	jle    f0100439 <cons_putc+0xfd>
f01003c9:	83 f8 0a             	cmp    $0xa,%eax
f01003cc:	0f 84 96 00 00 00    	je     f0100468 <cons_putc+0x12c>
f01003d2:	83 f8 0d             	cmp    $0xd,%eax
f01003d5:	0f 85 d1 00 00 00    	jne    f01004ac <cons_putc+0x170>
		crt_pos -= (crt_pos % CRT_COLS);
f01003db:	66 8b 0d 28 55 11 f0 	mov    0xf0115528,%cx
f01003e2:	bb 50 00 00 00       	mov    $0x50,%ebx
f01003e7:	89 c8                	mov    %ecx,%eax
f01003e9:	ba 00 00 00 00       	mov    $0x0,%edx
f01003ee:	66 f7 f3             	div    %bx
f01003f1:	29 d1                	sub    %edx,%ecx
f01003f3:	66 89 0d 28 55 11 f0 	mov    %cx,0xf0115528
	if (crt_pos >= CRT_SIZE) {
f01003fa:	66 81 3d 28 55 11 f0 	cmpw   $0x7cf,0xf0115528
f0100401:	cf 07 
f0100403:	0f 87 c5 00 00 00    	ja     f01004ce <cons_putc+0x192>
	outb(addr_6845, 14);
f0100409:	8b 0d 30 55 11 f0    	mov    0xf0115530,%ecx
f010040f:	b0 0e                	mov    $0xe,%al
f0100411:	89 ca                	mov    %ecx,%edx
f0100413:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100414:	8d 59 01             	lea    0x1(%ecx),%ebx
f0100417:	66 a1 28 55 11 f0    	mov    0xf0115528,%ax
f010041d:	66 c1 e8 08          	shr    $0x8,%ax
f0100421:	89 da                	mov    %ebx,%edx
f0100423:	ee                   	out    %al,(%dx)
f0100424:	b0 0f                	mov    $0xf,%al
f0100426:	89 ca                	mov    %ecx,%edx
f0100428:	ee                   	out    %al,(%dx)
f0100429:	a0 28 55 11 f0       	mov    0xf0115528,%al
f010042e:	89 da                	mov    %ebx,%edx
f0100430:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100431:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100434:	5b                   	pop    %ebx
f0100435:	5e                   	pop    %esi
f0100436:	5f                   	pop    %edi
f0100437:	5d                   	pop    %ebp
f0100438:	c3                   	ret    
	switch (c & 0xff) {
f0100439:	83 f8 08             	cmp    $0x8,%eax
f010043c:	75 6e                	jne    f01004ac <cons_putc+0x170>
		if (crt_pos > 0) {
f010043e:	66 a1 28 55 11 f0    	mov    0xf0115528,%ax
f0100444:	66 85 c0             	test   %ax,%ax
f0100447:	74 c0                	je     f0100409 <cons_putc+0xcd>
			crt_pos--;
f0100449:	48                   	dec    %eax
f010044a:	66 a3 28 55 11 f0    	mov    %ax,0xf0115528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100450:	0f b7 c0             	movzwl %ax,%eax
f0100453:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f0100459:	83 cf 20             	or     $0x20,%edi
f010045c:	8b 15 2c 55 11 f0    	mov    0xf011552c,%edx
f0100462:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100466:	eb 92                	jmp    f01003fa <cons_putc+0xbe>
		crt_pos += CRT_COLS;
f0100468:	66 83 05 28 55 11 f0 	addw   $0x50,0xf0115528
f010046f:	50 
f0100470:	e9 66 ff ff ff       	jmp    f01003db <cons_putc+0x9f>
		cons_putc(' ');
f0100475:	b8 20 00 00 00       	mov    $0x20,%eax
f010047a:	e8 bd fe ff ff       	call   f010033c <cons_putc>
		cons_putc(' ');
f010047f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100484:	e8 b3 fe ff ff       	call   f010033c <cons_putc>
		cons_putc(' ');
f0100489:	b8 20 00 00 00       	mov    $0x20,%eax
f010048e:	e8 a9 fe ff ff       	call   f010033c <cons_putc>
		cons_putc(' ');
f0100493:	b8 20 00 00 00       	mov    $0x20,%eax
f0100498:	e8 9f fe ff ff       	call   f010033c <cons_putc>
		cons_putc(' ');
f010049d:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a2:	e8 95 fe ff ff       	call   f010033c <cons_putc>
f01004a7:	e9 4e ff ff ff       	jmp    f01003fa <cons_putc+0xbe>
		crt_buf[crt_pos++] = c;		/* write the character */
f01004ac:	66 a1 28 55 11 f0    	mov    0xf0115528,%ax
f01004b2:	8d 50 01             	lea    0x1(%eax),%edx
f01004b5:	66 89 15 28 55 11 f0 	mov    %dx,0xf0115528
f01004bc:	0f b7 c0             	movzwl %ax,%eax
f01004bf:	8b 15 2c 55 11 f0    	mov    0xf011552c,%edx
f01004c5:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004c9:	e9 2c ff ff ff       	jmp    f01003fa <cons_putc+0xbe>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004ce:	a1 2c 55 11 f0       	mov    0xf011552c,%eax
f01004d3:	83 ec 04             	sub    $0x4,%esp
f01004d6:	68 00 0f 00 00       	push   $0xf00
f01004db:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004e1:	52                   	push   %edx
f01004e2:	50                   	push   %eax
f01004e3:	e8 f1 1b 00 00       	call   f01020d9 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01004e8:	8b 15 2c 55 11 f0    	mov    0xf011552c,%edx
f01004ee:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01004f4:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01004fa:	83 c4 10             	add    $0x10,%esp
f01004fd:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100502:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100505:	39 d0                	cmp    %edx,%eax
f0100507:	75 f4                	jne    f01004fd <cons_putc+0x1c1>
		crt_pos -= CRT_COLS;
f0100509:	66 83 2d 28 55 11 f0 	subw   $0x50,0xf0115528
f0100510:	50 
f0100511:	e9 f3 fe ff ff       	jmp    f0100409 <cons_putc+0xcd>

f0100516 <serial_intr>:
	if (serial_exists)
f0100516:	80 3d 34 55 11 f0 00 	cmpb   $0x0,0xf0115534
f010051d:	75 01                	jne    f0100520 <serial_intr+0xa>
f010051f:	c3                   	ret    
{
f0100520:	55                   	push   %ebp
f0100521:	89 e5                	mov    %esp,%ebp
f0100523:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100526:	b8 c6 01 10 f0       	mov    $0xf01001c6,%eax
f010052b:	e8 b5 fc ff ff       	call   f01001e5 <cons_intr>
}
f0100530:	c9                   	leave  
f0100531:	c3                   	ret    

f0100532 <kbd_intr>:
{
f0100532:	55                   	push   %ebp
f0100533:	89 e5                	mov    %esp,%ebp
f0100535:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100538:	b8 28 02 10 f0       	mov    $0xf0100228,%eax
f010053d:	e8 a3 fc ff ff       	call   f01001e5 <cons_intr>
}
f0100542:	c9                   	leave  
f0100543:	c3                   	ret    

f0100544 <cons_getc>:
{
f0100544:	55                   	push   %ebp
f0100545:	89 e5                	mov    %esp,%ebp
f0100547:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f010054a:	e8 c7 ff ff ff       	call   f0100516 <serial_intr>
	kbd_intr();
f010054f:	e8 de ff ff ff       	call   f0100532 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100554:	a1 20 55 11 f0       	mov    0xf0115520,%eax
f0100559:	3b 05 24 55 11 f0    	cmp    0xf0115524,%eax
f010055f:	74 26                	je     f0100587 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100561:	8d 50 01             	lea    0x1(%eax),%edx
f0100564:	89 15 20 55 11 f0    	mov    %edx,0xf0115520
f010056a:	0f b6 80 20 53 11 f0 	movzbl -0xfeeace0(%eax),%eax
		if (cons.rpos == CONSBUFSIZE)
f0100571:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100577:	74 02                	je     f010057b <cons_getc+0x37>
}
f0100579:	c9                   	leave  
f010057a:	c3                   	ret    
			cons.rpos = 0;
f010057b:	c7 05 20 55 11 f0 00 	movl   $0x0,0xf0115520
f0100582:	00 00 00 
f0100585:	eb f2                	jmp    f0100579 <cons_getc+0x35>
	return 0;
f0100587:	b8 00 00 00 00       	mov    $0x0,%eax
f010058c:	eb eb                	jmp    f0100579 <cons_getc+0x35>

f010058e <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f010058e:	55                   	push   %ebp
f010058f:	89 e5                	mov    %esp,%ebp
f0100591:	57                   	push   %edi
f0100592:	56                   	push   %esi
f0100593:	53                   	push   %ebx
f0100594:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f0100597:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f010059e:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01005a5:	5a a5 
	if (*cp != 0xA55A) {
f01005a7:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f01005ad:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005b1:	0f 84 a2 00 00 00    	je     f0100659 <cons_init+0xcb>
		addr_6845 = MONO_BASE;
f01005b7:	c7 05 30 55 11 f0 b4 	movl   $0x3b4,0xf0115530
f01005be:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005c1:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f01005c6:	8b 3d 30 55 11 f0    	mov    0xf0115530,%edi
f01005cc:	b0 0e                	mov    $0xe,%al
f01005ce:	89 fa                	mov    %edi,%edx
f01005d0:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005d1:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005d4:	89 ca                	mov    %ecx,%edx
f01005d6:	ec                   	in     (%dx),%al
f01005d7:	0f b6 c0             	movzbl %al,%eax
f01005da:	c1 e0 08             	shl    $0x8,%eax
f01005dd:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005df:	b0 0f                	mov    $0xf,%al
f01005e1:	89 fa                	mov    %edi,%edx
f01005e3:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005e4:	89 ca                	mov    %ecx,%edx
f01005e6:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01005e7:	89 35 2c 55 11 f0    	mov    %esi,0xf011552c
	pos |= inb(addr_6845 + 1);
f01005ed:	0f b6 c0             	movzbl %al,%eax
f01005f0:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01005f2:	66 a3 28 55 11 f0    	mov    %ax,0xf0115528
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005f8:	b1 00                	mov    $0x0,%cl
f01005fa:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01005ff:	88 c8                	mov    %cl,%al
f0100601:	89 da                	mov    %ebx,%edx
f0100603:	ee                   	out    %al,(%dx)
f0100604:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100609:	b0 80                	mov    $0x80,%al
f010060b:	89 fa                	mov    %edi,%edx
f010060d:	ee                   	out    %al,(%dx)
f010060e:	b0 0c                	mov    $0xc,%al
f0100610:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100615:	ee                   	out    %al,(%dx)
f0100616:	be f9 03 00 00       	mov    $0x3f9,%esi
f010061b:	88 c8                	mov    %cl,%al
f010061d:	89 f2                	mov    %esi,%edx
f010061f:	ee                   	out    %al,(%dx)
f0100620:	b0 03                	mov    $0x3,%al
f0100622:	89 fa                	mov    %edi,%edx
f0100624:	ee                   	out    %al,(%dx)
f0100625:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010062a:	88 c8                	mov    %cl,%al
f010062c:	ee                   	out    %al,(%dx)
f010062d:	b0 01                	mov    $0x1,%al
f010062f:	89 f2                	mov    %esi,%edx
f0100631:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100632:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100637:	ec                   	in     (%dx),%al
f0100638:	88 c1                	mov    %al,%cl
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010063a:	3c ff                	cmp    $0xff,%al
f010063c:	0f 95 05 34 55 11 f0 	setne  0xf0115534
f0100643:	89 da                	mov    %ebx,%edx
f0100645:	ec                   	in     (%dx),%al
f0100646:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010064b:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010064c:	80 f9 ff             	cmp    $0xff,%cl
f010064f:	74 23                	je     f0100674 <cons_init+0xe6>
		cprintf("Serial port does not exist!\n");
}
f0100651:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100654:	5b                   	pop    %ebx
f0100655:	5e                   	pop    %esi
f0100656:	5f                   	pop    %edi
f0100657:	5d                   	pop    %ebp
f0100658:	c3                   	ret    
		*cp = was;
f0100659:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100660:	c7 05 30 55 11 f0 d4 	movl   $0x3d4,0xf0115530
f0100667:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010066a:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f010066f:	e9 52 ff ff ff       	jmp    f01005c6 <cons_init+0x38>
		cprintf("Serial port does not exist!\n");
f0100674:	83 ec 0c             	sub    $0xc,%esp
f0100677:	68 c4 25 10 f0       	push   $0xf01025c4
f010067c:	e8 dc 0e 00 00       	call   f010155d <cprintf>
f0100681:	83 c4 10             	add    $0x10,%esp
}
f0100684:	eb cb                	jmp    f0100651 <cons_init+0xc3>

f0100686 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100686:	55                   	push   %ebp
f0100687:	89 e5                	mov    %esp,%ebp
f0100689:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010068c:	8b 45 08             	mov    0x8(%ebp),%eax
f010068f:	e8 a8 fc ff ff       	call   f010033c <cons_putc>
}
f0100694:	c9                   	leave  
f0100695:	c3                   	ret    

f0100696 <getchar>:

int
getchar(void)
{
f0100696:	55                   	push   %ebp
f0100697:	89 e5                	mov    %esp,%ebp
f0100699:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010069c:	e8 a3 fe ff ff       	call   f0100544 <cons_getc>
f01006a1:	85 c0                	test   %eax,%eax
f01006a3:	74 f7                	je     f010069c <getchar+0x6>
		/* do nothing */;
	return c;
}
f01006a5:	c9                   	leave  
f01006a6:	c3                   	ret    

f01006a7 <iscons>:

int
iscons(int fdnum)
{
f01006a7:	55                   	push   %ebp
f01006a8:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01006aa:	b8 01 00 00 00       	mov    $0x1,%eax
f01006af:	5d                   	pop    %ebp
f01006b0:	c3                   	ret    

f01006b1 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006b1:	55                   	push   %ebp
f01006b2:	89 e5                	mov    %esp,%ebp
f01006b4:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006b7:	68 20 28 10 f0       	push   $0xf0102820
f01006bc:	68 3e 28 10 f0       	push   $0xf010283e
f01006c1:	68 43 28 10 f0       	push   $0xf0102843
f01006c6:	e8 92 0e 00 00       	call   f010155d <cprintf>
f01006cb:	83 c4 0c             	add    $0xc,%esp
f01006ce:	68 d8 28 10 f0       	push   $0xf01028d8
f01006d3:	68 4c 28 10 f0       	push   $0xf010284c
f01006d8:	68 43 28 10 f0       	push   $0xf0102843
f01006dd:	e8 7b 0e 00 00       	call   f010155d <cprintf>
	return 0;
}
f01006e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01006e7:	c9                   	leave  
f01006e8:	c3                   	ret    

f01006e9 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006e9:	55                   	push   %ebp
f01006ea:	89 e5                	mov    %esp,%ebp
f01006ec:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006ef:	68 55 28 10 f0       	push   $0xf0102855
f01006f4:	e8 64 0e 00 00       	call   f010155d <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006f9:	83 c4 08             	add    $0x8,%esp
f01006fc:	68 0c 00 10 00       	push   $0x10000c
f0100701:	68 00 29 10 f0       	push   $0xf0102900
f0100706:	e8 52 0e 00 00       	call   f010155d <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010070b:	83 c4 0c             	add    $0xc,%esp
f010070e:	68 0c 00 10 00       	push   $0x10000c
f0100713:	68 0c 00 10 f0       	push   $0xf010000c
f0100718:	68 28 29 10 f0       	push   $0xf0102928
f010071d:	e8 3b 0e 00 00       	call   f010155d <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100722:	83 c4 0c             	add    $0xc,%esp
f0100725:	68 74 24 10 00       	push   $0x102474
f010072a:	68 74 24 10 f0       	push   $0xf0102474
f010072f:	68 4c 29 10 f0       	push   $0xf010294c
f0100734:	e8 24 0e 00 00       	call   f010155d <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100739:	83 c4 0c             	add    $0xc,%esp
f010073c:	68 00 53 11 00       	push   $0x115300
f0100741:	68 00 53 11 f0       	push   $0xf0115300
f0100746:	68 70 29 10 f0       	push   $0xf0102970
f010074b:	e8 0d 0e 00 00       	call   f010155d <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100750:	83 c4 0c             	add    $0xc,%esp
f0100753:	68 70 59 11 00       	push   $0x115970
f0100758:	68 70 59 11 f0       	push   $0xf0115970
f010075d:	68 94 29 10 f0       	push   $0xf0102994
f0100762:	e8 f6 0d 00 00       	call   f010155d <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100767:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010076a:	b8 6f 5d 11 f0       	mov    $0xf0115d6f,%eax
f010076f:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100774:	c1 f8 0a             	sar    $0xa,%eax
f0100777:	50                   	push   %eax
f0100778:	68 b8 29 10 f0       	push   $0xf01029b8
f010077d:	e8 db 0d 00 00       	call   f010155d <cprintf>
	return 0;
}
f0100782:	b8 00 00 00 00       	mov    $0x0,%eax
f0100787:	c9                   	leave  
f0100788:	c3                   	ret    

f0100789 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100789:	55                   	push   %ebp
f010078a:	89 e5                	mov    %esp,%ebp
f010078c:	57                   	push   %edi
f010078d:	56                   	push   %esi
f010078e:	53                   	push   %ebx
f010078f:	83 ec 38             	sub    $0x38,%esp
	cprintf("Stack backtrace:\n");
f0100792:	68 6e 28 10 f0       	push   $0xf010286e
f0100797:	e8 c1 0d 00 00       	call   f010155d <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010079c:	89 e8                	mov    %ebp,%eax
	uint32_t ebp = read_ebp(), prev_ebp, eip;
	while (ebp != 0) {
f010079e:	83 c4 10             	add    $0x10,%esp
f01007a1:	eb 34                	jmp    f01007d7 <mon_backtrace+0x4e>
				*((int*)ebp + 5), *((int*)ebp + 6));
		struct Eipdebuginfo info;
		int code = debuginfo_eip((uintptr_t)eip, &info);
		cprintf("         %s:%d: ", info.eip_file, info.eip_line);
		for (int i = 0; i < info.eip_fn_namelen; i++)
			cprintf("%c", info.eip_fn_name[i]);
f01007a3:	83 ec 08             	sub    $0x8,%esp
f01007a6:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01007a9:	0f be 04 18          	movsbl (%eax,%ebx,1),%eax
f01007ad:	50                   	push   %eax
f01007ae:	68 91 28 10 f0       	push   $0xf0102891
f01007b3:	e8 a5 0d 00 00       	call   f010155d <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f01007b8:	43                   	inc    %ebx
f01007b9:	83 c4 10             	add    $0x10,%esp
f01007bc:	39 5d dc             	cmp    %ebx,-0x24(%ebp)
f01007bf:	7f e2                	jg     f01007a3 <mon_backtrace+0x1a>
		cprintf("+%d\n", eip - info.eip_fn_addr);
f01007c1:	83 ec 08             	sub    $0x8,%esp
f01007c4:	2b 75 e0             	sub    -0x20(%ebp),%esi
f01007c7:	56                   	push   %esi
f01007c8:	68 94 28 10 f0       	push   $0xf0102894
f01007cd:	e8 8b 0d 00 00       	call   f010155d <cprintf>
		ebp = prev_ebp;
f01007d2:	83 c4 10             	add    $0x10,%esp
f01007d5:	89 f8                	mov    %edi,%eax
	while (ebp != 0) {
f01007d7:	85 c0                	test   %eax,%eax
f01007d9:	74 4a                	je     f0100825 <mon_backtrace+0x9c>
		prev_ebp = *(int*)ebp;
f01007db:	8b 38                	mov    (%eax),%edi
		eip = *((int*)ebp + 1);
f01007dd:	8b 70 04             	mov    0x4(%eax),%esi
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, 
f01007e0:	ff 70 18             	pushl  0x18(%eax)
f01007e3:	ff 70 14             	pushl  0x14(%eax)
f01007e6:	ff 70 10             	pushl  0x10(%eax)
f01007e9:	ff 70 0c             	pushl  0xc(%eax)
f01007ec:	ff 70 08             	pushl  0x8(%eax)
f01007ef:	56                   	push   %esi
f01007f0:	50                   	push   %eax
f01007f1:	68 e4 29 10 f0       	push   $0xf01029e4
f01007f6:	e8 62 0d 00 00       	call   f010155d <cprintf>
		int code = debuginfo_eip((uintptr_t)eip, &info);
f01007fb:	83 c4 18             	add    $0x18,%esp
f01007fe:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100801:	50                   	push   %eax
f0100802:	56                   	push   %esi
f0100803:	e8 56 0e 00 00       	call   f010165e <debuginfo_eip>
		cprintf("         %s:%d: ", info.eip_file, info.eip_line);
f0100808:	83 c4 0c             	add    $0xc,%esp
f010080b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010080e:	ff 75 d0             	pushl  -0x30(%ebp)
f0100811:	68 80 28 10 f0       	push   $0xf0102880
f0100816:	e8 42 0d 00 00       	call   f010155d <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f010081b:	83 c4 10             	add    $0x10,%esp
f010081e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100823:	eb 97                	jmp    f01007bc <mon_backtrace+0x33>
	}
	return 0;
}
f0100825:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100828:	5b                   	pop    %ebx
f0100829:	5e                   	pop    %esi
f010082a:	5f                   	pop    %edi
f010082b:	5d                   	pop    %ebp
f010082c:	c3                   	ret    

f010082d <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010082d:	55                   	push   %ebp
f010082e:	89 e5                	mov    %esp,%ebp
f0100830:	57                   	push   %edi
f0100831:	56                   	push   %esi
f0100832:	53                   	push   %ebx
f0100833:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100836:	68 1c 2a 10 f0       	push   $0xf0102a1c
f010083b:	e8 1d 0d 00 00       	call   f010155d <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100840:	c7 04 24 40 2a 10 f0 	movl   $0xf0102a40,(%esp)
f0100847:	e8 11 0d 00 00       	call   f010155d <cprintf>
f010084c:	83 c4 10             	add    $0x10,%esp
f010084f:	eb 47                	jmp    f0100898 <monitor+0x6b>
		while (*buf && strchr(WHITESPACE, *buf))
f0100851:	83 ec 08             	sub    $0x8,%esp
f0100854:	0f be c0             	movsbl %al,%eax
f0100857:	50                   	push   %eax
f0100858:	68 9d 28 10 f0       	push   $0xf010289d
f010085d:	e8 f5 17 00 00       	call   f0102057 <strchr>
f0100862:	83 c4 10             	add    $0x10,%esp
f0100865:	85 c0                	test   %eax,%eax
f0100867:	74 0a                	je     f0100873 <monitor+0x46>
			*buf++ = 0;
f0100869:	c6 03 00             	movb   $0x0,(%ebx)
f010086c:	89 f7                	mov    %esi,%edi
f010086e:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100871:	eb 68                	jmp    f01008db <monitor+0xae>
		if (*buf == 0)
f0100873:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100876:	74 6f                	je     f01008e7 <monitor+0xba>
		if (argc == MAXARGS-1) {
f0100878:	83 fe 0f             	cmp    $0xf,%esi
f010087b:	74 09                	je     f0100886 <monitor+0x59>
		argv[argc++] = buf;
f010087d:	8d 7e 01             	lea    0x1(%esi),%edi
f0100880:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100884:	eb 37                	jmp    f01008bd <monitor+0x90>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100886:	83 ec 08             	sub    $0x8,%esp
f0100889:	6a 10                	push   $0x10
f010088b:	68 a2 28 10 f0       	push   $0xf01028a2
f0100890:	e8 c8 0c 00 00       	call   f010155d <cprintf>
f0100895:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100898:	83 ec 0c             	sub    $0xc,%esp
f010089b:	68 99 28 10 f0       	push   $0xf0102899
f01008a0:	e8 a7 15 00 00       	call   f0101e4c <readline>
f01008a5:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01008a7:	83 c4 10             	add    $0x10,%esp
f01008aa:	85 c0                	test   %eax,%eax
f01008ac:	74 ea                	je     f0100898 <monitor+0x6b>
	argv[argc] = 0;
f01008ae:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01008b5:	be 00 00 00 00       	mov    $0x0,%esi
f01008ba:	eb 21                	jmp    f01008dd <monitor+0xb0>
			buf++;
f01008bc:	43                   	inc    %ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f01008bd:	8a 03                	mov    (%ebx),%al
f01008bf:	84 c0                	test   %al,%al
f01008c1:	74 18                	je     f01008db <monitor+0xae>
f01008c3:	83 ec 08             	sub    $0x8,%esp
f01008c6:	0f be c0             	movsbl %al,%eax
f01008c9:	50                   	push   %eax
f01008ca:	68 9d 28 10 f0       	push   $0xf010289d
f01008cf:	e8 83 17 00 00       	call   f0102057 <strchr>
f01008d4:	83 c4 10             	add    $0x10,%esp
f01008d7:	85 c0                	test   %eax,%eax
f01008d9:	74 e1                	je     f01008bc <monitor+0x8f>
			*buf++ = 0;
f01008db:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f01008dd:	8a 03                	mov    (%ebx),%al
f01008df:	84 c0                	test   %al,%al
f01008e1:	0f 85 6a ff ff ff    	jne    f0100851 <monitor+0x24>
	argv[argc] = 0;
f01008e7:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008ee:	00 
	if (argc == 0)
f01008ef:	85 f6                	test   %esi,%esi
f01008f1:	74 a5                	je     f0100898 <monitor+0x6b>
		if (strcmp(argv[0], commands[i].name) == 0)
f01008f3:	83 ec 08             	sub    $0x8,%esp
f01008f6:	68 3e 28 10 f0       	push   $0xf010283e
f01008fb:	ff 75 a8             	pushl  -0x58(%ebp)
f01008fe:	e8 00 17 00 00       	call   f0102003 <strcmp>
f0100903:	83 c4 10             	add    $0x10,%esp
f0100906:	85 c0                	test   %eax,%eax
f0100908:	74 34                	je     f010093e <monitor+0x111>
f010090a:	83 ec 08             	sub    $0x8,%esp
f010090d:	68 4c 28 10 f0       	push   $0xf010284c
f0100912:	ff 75 a8             	pushl  -0x58(%ebp)
f0100915:	e8 e9 16 00 00       	call   f0102003 <strcmp>
f010091a:	83 c4 10             	add    $0x10,%esp
f010091d:	85 c0                	test   %eax,%eax
f010091f:	74 18                	je     f0100939 <monitor+0x10c>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100921:	83 ec 08             	sub    $0x8,%esp
f0100924:	ff 75 a8             	pushl  -0x58(%ebp)
f0100927:	68 bf 28 10 f0       	push   $0xf01028bf
f010092c:	e8 2c 0c 00 00       	call   f010155d <cprintf>
f0100931:	83 c4 10             	add    $0x10,%esp
f0100934:	e9 5f ff ff ff       	jmp    f0100898 <monitor+0x6b>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100939:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f010093e:	83 ec 04             	sub    $0x4,%esp
f0100941:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100944:	01 d0                	add    %edx,%eax
f0100946:	ff 75 08             	pushl  0x8(%ebp)
f0100949:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f010094c:	51                   	push   %ecx
f010094d:	56                   	push   %esi
f010094e:	ff 14 85 70 2a 10 f0 	call   *-0xfefd590(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100955:	83 c4 10             	add    $0x10,%esp
f0100958:	85 c0                	test   %eax,%eax
f010095a:	0f 89 38 ff ff ff    	jns    f0100898 <monitor+0x6b>
				break;
	}
}
f0100960:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100963:	5b                   	pop    %ebx
f0100964:	5e                   	pop    %esi
f0100965:	5f                   	pop    %edi
f0100966:	5d                   	pop    %ebp
f0100967:	c3                   	ret    

f0100968 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100968:	55                   	push   %ebp
f0100969:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f010096b:	83 3d 38 55 11 f0 00 	cmpl   $0x0,0xf0115538
f0100972:	74 1f                	je     f0100993 <boot_alloc+0x2b>
	}

	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	if (!n)
f0100974:	85 c0                	test   %eax,%eax
f0100976:	74 2e                	je     f01009a6 <boot_alloc+0x3e>
		return (void*)nextfree;
	else {
		result = nextfree;
f0100978:	8b 15 38 55 11 f0    	mov    0xf0115538,%edx
		nextfree = ROUNDUP(nextfree + n, PGSIZE);
f010097e:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100985:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010098a:	a3 38 55 11 f0       	mov    %eax,0xf0115538
		return (void*)result;
	}
}
f010098f:	89 d0                	mov    %edx,%eax
f0100991:	5d                   	pop    %ebp
f0100992:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100993:	ba 6f 69 11 f0       	mov    $0xf011696f,%edx
f0100998:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010099e:	89 15 38 55 11 f0    	mov    %edx,0xf0115538
f01009a4:	eb ce                	jmp    f0100974 <boot_alloc+0xc>
		return (void*)nextfree;
f01009a6:	8b 15 38 55 11 f0    	mov    0xf0115538,%edx
f01009ac:	eb e1                	jmp    f010098f <boot_alloc+0x27>

f01009ae <nvram_read>:
{
f01009ae:	55                   	push   %ebp
f01009af:	89 e5                	mov    %esp,%ebp
f01009b1:	56                   	push   %esi
f01009b2:	53                   	push   %ebx
f01009b3:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01009b5:	83 ec 0c             	sub    $0xc,%esp
f01009b8:	50                   	push   %eax
f01009b9:	e8 38 0b 00 00       	call   f01014f6 <mc146818_read>
f01009be:	89 c3                	mov    %eax,%ebx
f01009c0:	46                   	inc    %esi
f01009c1:	89 34 24             	mov    %esi,(%esp)
f01009c4:	e8 2d 0b 00 00       	call   f01014f6 <mc146818_read>
f01009c9:	c1 e0 08             	shl    $0x8,%eax
f01009cc:	09 d8                	or     %ebx,%eax
}
f01009ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01009d1:	5b                   	pop    %ebx
f01009d2:	5e                   	pop    %esi
f01009d3:	5d                   	pop    %ebp
f01009d4:	c3                   	ret    

f01009d5 <page2kva>:
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01009d5:	2b 05 6c 59 11 f0    	sub    0xf011596c,%eax
f01009db:	c1 f8 03             	sar    $0x3,%eax
f01009de:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01009e1:	89 c2                	mov    %eax,%edx
f01009e3:	c1 ea 0c             	shr    $0xc,%edx
f01009e6:	39 15 64 59 11 f0    	cmp    %edx,0xf0115964
f01009ec:	76 06                	jbe    f01009f4 <page2kva+0x1f>
	return (void *)(pa + KERNBASE);
f01009ee:	2d 00 00 00 10       	sub    $0x10000000,%eax

static inline void*
page2kva(struct PageInfo *pp)
{
	return KADDR(page2pa(pp));
}
f01009f3:	c3                   	ret    
{
f01009f4:	55                   	push   %ebp
f01009f5:	89 e5                	mov    %esp,%ebp
f01009f7:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009fa:	50                   	push   %eax
f01009fb:	68 80 2a 10 f0       	push   $0xf0102a80
f0100a00:	6a 52                	push   $0x52
f0100a02:	68 5c 2c 10 f0       	push   $0xf0102c5c
f0100a07:	e8 27 f7 ff ff       	call   f0100133 <_panic>

f0100a0c <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100a0c:	89 d1                	mov    %edx,%ecx
f0100a0e:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100a11:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100a14:	a8 01                	test   $0x1,%al
f0100a16:	74 47                	je     f0100a5f <check_va2pa+0x53>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100a18:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100a1d:	89 c1                	mov    %eax,%ecx
f0100a1f:	c1 e9 0c             	shr    $0xc,%ecx
f0100a22:	3b 0d 64 59 11 f0    	cmp    0xf0115964,%ecx
f0100a28:	73 1a                	jae    f0100a44 <check_va2pa+0x38>
	if (!(p[PTX(va)] & PTE_P))
f0100a2a:	c1 ea 0c             	shr    $0xc,%edx
f0100a2d:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100a33:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100a3a:	a8 01                	test   $0x1,%al
f0100a3c:	74 27                	je     f0100a65 <check_va2pa+0x59>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a3e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a43:	c3                   	ret    
{
f0100a44:	55                   	push   %ebp
f0100a45:	89 e5                	mov    %esp,%ebp
f0100a47:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a4a:	50                   	push   %eax
f0100a4b:	68 80 2a 10 f0       	push   $0xf0102a80
f0100a50:	68 99 02 00 00       	push   $0x299
f0100a55:	68 6a 2c 10 f0       	push   $0xf0102c6a
f0100a5a:	e8 d4 f6 ff ff       	call   f0100133 <_panic>
		return ~0;
f0100a5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100a64:	c3                   	ret    
		return ~0;
f0100a65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100a6a:	c3                   	ret    

f0100a6b <page_init>:
{
f0100a6b:	55                   	push   %ebp
f0100a6c:	89 e5                	mov    %esp,%ebp
f0100a6e:	57                   	push   %edi
f0100a6f:	56                   	push   %esi
f0100a70:	53                   	push   %ebx
	for (i = 1; i < npages_basemem; i++) {
f0100a71:	8b 35 40 55 11 f0    	mov    0xf0115540,%esi
f0100a77:	8b 1d 3c 55 11 f0    	mov    0xf011553c,%ebx
f0100a7d:	b2 00                	mov    $0x0,%dl
f0100a7f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100a84:	bf 01 00 00 00       	mov    $0x1,%edi
f0100a89:	eb 22                	jmp    f0100aad <page_init+0x42>
		pages[i].pp_ref = 0;
f0100a8b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100a92:	89 d1                	mov    %edx,%ecx
f0100a94:	03 0d 6c 59 11 f0    	add    0xf011596c,%ecx
f0100a9a:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100aa0:	89 19                	mov    %ebx,(%ecx)
	for (i = 1; i < npages_basemem; i++) {
f0100aa2:	40                   	inc    %eax
		page_free_list = &pages[i];
f0100aa3:	89 d3                	mov    %edx,%ebx
f0100aa5:	03 1d 6c 59 11 f0    	add    0xf011596c,%ebx
f0100aab:	89 fa                	mov    %edi,%edx
	for (i = 1; i < npages_basemem; i++) {
f0100aad:	39 c6                	cmp    %eax,%esi
f0100aaf:	77 da                	ja     f0100a8b <page_init+0x20>
f0100ab1:	84 d2                	test   %dl,%dl
f0100ab3:	75 33                	jne    f0100ae8 <page_init+0x7d>
	size_t table_size = PTX(8*npages);;
f0100ab5:	8b 15 64 59 11 f0    	mov    0xf0115964,%edx
f0100abb:	c1 e2 0d             	shl    $0xd,%edx
f0100abe:	c1 ea 16             	shr    $0x16,%edx
	size_t end_idx = PTX(ROUNDUP((char *) end, PGSIZE));
f0100ac1:	b8 6f 69 11 f0       	mov    $0xf011696f,%eax
f0100ac6:	c1 e8 0c             	shr    $0xc,%eax
f0100ac9:	25 ff 03 00 00       	and    $0x3ff,%eax
	for (i = table_size + end_idx + 1; i < npages; i++) {
f0100ace:	8d 54 02 01          	lea    0x1(%edx,%eax,1),%edx
f0100ad2:	8b 1d 3c 55 11 f0    	mov    0xf011553c,%ebx
f0100ad8:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0100adf:	b1 00                	mov    $0x0,%cl
f0100ae1:	be 01 00 00 00       	mov    $0x1,%esi
f0100ae6:	eb 26                	jmp    f0100b0e <page_init+0xa3>
f0100ae8:	89 1d 3c 55 11 f0    	mov    %ebx,0xf011553c
f0100aee:	eb c5                	jmp    f0100ab5 <page_init+0x4a>
		pages[i].pp_ref = 0;
f0100af0:	89 c1                	mov    %eax,%ecx
f0100af2:	03 0d 6c 59 11 f0    	add    0xf011596c,%ecx
f0100af8:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100afe:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0100b00:	89 c3                	mov    %eax,%ebx
f0100b02:	03 1d 6c 59 11 f0    	add    0xf011596c,%ebx
	for (i = table_size + end_idx + 1; i < npages; i++) {
f0100b08:	42                   	inc    %edx
f0100b09:	83 c0 08             	add    $0x8,%eax
f0100b0c:	89 f1                	mov    %esi,%ecx
f0100b0e:	39 15 64 59 11 f0    	cmp    %edx,0xf0115964
f0100b14:	77 da                	ja     f0100af0 <page_init+0x85>
f0100b16:	84 c9                	test   %cl,%cl
f0100b18:	75 05                	jne    f0100b1f <page_init+0xb4>
}
f0100b1a:	5b                   	pop    %ebx
f0100b1b:	5e                   	pop    %esi
f0100b1c:	5f                   	pop    %edi
f0100b1d:	5d                   	pop    %ebp
f0100b1e:	c3                   	ret    
f0100b1f:	89 1d 3c 55 11 f0    	mov    %ebx,0xf011553c
f0100b25:	eb f3                	jmp    f0100b1a <page_init+0xaf>

f0100b27 <page_alloc>:
{
f0100b27:	55                   	push   %ebp
f0100b28:	89 e5                	mov    %esp,%ebp
f0100b2a:	53                   	push   %ebx
f0100b2b:	83 ec 04             	sub    $0x4,%esp
	struct PageInfo* next = page_free_list;
f0100b2e:	8b 1d 3c 55 11 f0    	mov    0xf011553c,%ebx
	if (!next)
f0100b34:	85 db                	test   %ebx,%ebx
f0100b36:	74 13                	je     f0100b4b <page_alloc+0x24>
	page_free_list = page_free_list->pp_link;
f0100b38:	8b 03                	mov    (%ebx),%eax
f0100b3a:	a3 3c 55 11 f0       	mov    %eax,0xf011553c
	next->pp_link = NULL;
f0100b3f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f0100b45:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100b49:	75 07                	jne    f0100b52 <page_alloc+0x2b>
}
f0100b4b:	89 d8                	mov    %ebx,%eax
f0100b4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b50:	c9                   	leave  
f0100b51:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0100b52:	89 d8                	mov    %ebx,%eax
f0100b54:	2b 05 6c 59 11 f0    	sub    0xf011596c,%eax
f0100b5a:	c1 f8 03             	sar    $0x3,%eax
f0100b5d:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100b60:	89 c2                	mov    %eax,%edx
f0100b62:	c1 ea 0c             	shr    $0xc,%edx
f0100b65:	3b 15 64 59 11 f0    	cmp    0xf0115964,%edx
f0100b6b:	73 1a                	jae    f0100b87 <page_alloc+0x60>
		memset(content, 0, PGSIZE);
f0100b6d:	83 ec 04             	sub    $0x4,%esp
f0100b70:	68 00 10 00 00       	push   $0x1000
f0100b75:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100b77:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b7c:	50                   	push   %eax
f0100b7d:	e8 0a 15 00 00       	call   f010208c <memset>
f0100b82:	83 c4 10             	add    $0x10,%esp
f0100b85:	eb c4                	jmp    f0100b4b <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b87:	50                   	push   %eax
f0100b88:	68 80 2a 10 f0       	push   $0xf0102a80
f0100b8d:	6a 52                	push   $0x52
f0100b8f:	68 5c 2c 10 f0       	push   $0xf0102c5c
f0100b94:	e8 9a f5 ff ff       	call   f0100133 <_panic>

f0100b99 <page_free>:
{
f0100b99:	55                   	push   %ebp
f0100b9a:	89 e5                	mov    %esp,%ebp
f0100b9c:	83 ec 08             	sub    $0x8,%esp
f0100b9f:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref)
f0100ba2:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100ba7:	75 14                	jne    f0100bbd <page_free+0x24>
	if (pp->pp_link)
f0100ba9:	83 38 00             	cmpl   $0x0,(%eax)
f0100bac:	75 26                	jne    f0100bd4 <page_free+0x3b>
	pp->pp_link = page_free_list;
f0100bae:	8b 15 3c 55 11 f0    	mov    0xf011553c,%edx
f0100bb4:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100bb6:	a3 3c 55 11 f0       	mov    %eax,0xf011553c
}
f0100bbb:	c9                   	leave  
f0100bbc:	c3                   	ret    
		panic("Ref count is non-zero");
f0100bbd:	83 ec 04             	sub    $0x4,%esp
f0100bc0:	68 76 2c 10 f0       	push   $0xf0102c76
f0100bc5:	68 36 01 00 00       	push   $0x136
f0100bca:	68 6a 2c 10 f0       	push   $0xf0102c6a
f0100bcf:	e8 5f f5 ff ff       	call   f0100133 <_panic>
		panic("Page is double-freed");
f0100bd4:	83 ec 04             	sub    $0x4,%esp
f0100bd7:	68 8c 2c 10 f0       	push   $0xf0102c8c
f0100bdc:	68 38 01 00 00       	push   $0x138
f0100be1:	68 6a 2c 10 f0       	push   $0xf0102c6a
f0100be6:	e8 48 f5 ff ff       	call   f0100133 <_panic>

f0100beb <mem_init>:
{
f0100beb:	55                   	push   %ebp
f0100bec:	89 e5                	mov    %esp,%ebp
f0100bee:	57                   	push   %edi
f0100bef:	56                   	push   %esi
f0100bf0:	53                   	push   %ebx
f0100bf1:	83 ec 2c             	sub    $0x2c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0100bf4:	b8 15 00 00 00       	mov    $0x15,%eax
f0100bf9:	e8 b0 fd ff ff       	call   f01009ae <nvram_read>
f0100bfe:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0100c00:	b8 17 00 00 00       	mov    $0x17,%eax
f0100c05:	e8 a4 fd ff ff       	call   f01009ae <nvram_read>
f0100c0a:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0100c0c:	b8 34 00 00 00       	mov    $0x34,%eax
f0100c11:	e8 98 fd ff ff       	call   f01009ae <nvram_read>
	if (ext16mem)
f0100c16:	c1 e0 06             	shl    $0x6,%eax
f0100c19:	75 0e                	jne    f0100c29 <mem_init+0x3e>
		totalmem = basemem;
f0100c1b:	89 d8                	mov    %ebx,%eax
	else if (extmem)
f0100c1d:	85 f6                	test   %esi,%esi
f0100c1f:	74 0d                	je     f0100c2e <mem_init+0x43>
		totalmem = 1 * 1024 + extmem;
f0100c21:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0100c27:	eb 05                	jmp    f0100c2e <mem_init+0x43>
		totalmem = 16 * 1024 + ext16mem;
f0100c29:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0100c2e:	89 c2                	mov    %eax,%edx
f0100c30:	c1 ea 02             	shr    $0x2,%edx
f0100c33:	89 15 64 59 11 f0    	mov    %edx,0xf0115964
	npages_basemem = basemem / (PGSIZE / 1024);
f0100c39:	89 da                	mov    %ebx,%edx
f0100c3b:	c1 ea 02             	shr    $0x2,%edx
f0100c3e:	89 15 40 55 11 f0    	mov    %edx,0xf0115540
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100c44:	89 c2                	mov    %eax,%edx
f0100c46:	29 da                	sub    %ebx,%edx
f0100c48:	52                   	push   %edx
f0100c49:	53                   	push   %ebx
f0100c4a:	50                   	push   %eax
f0100c4b:	68 a4 2a 10 f0       	push   $0xf0102aa4
f0100c50:	e8 08 09 00 00       	call   f010155d <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0100c55:	b8 00 10 00 00       	mov    $0x1000,%eax
f0100c5a:	e8 09 fd ff ff       	call   f0100968 <boot_alloc>
f0100c5f:	a3 68 59 11 f0       	mov    %eax,0xf0115968
	memset(kern_pgdir, 0, PGSIZE);
f0100c64:	83 c4 0c             	add    $0xc,%esp
f0100c67:	68 00 10 00 00       	push   $0x1000
f0100c6c:	6a 00                	push   $0x0
f0100c6e:	50                   	push   %eax
f0100c6f:	e8 18 14 00 00       	call   f010208c <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0100c74:	a1 68 59 11 f0       	mov    0xf0115968,%eax
	if ((uint32_t)kva < KERNBASE)
f0100c79:	83 c4 10             	add    $0x10,%esp
f0100c7c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100c81:	77 15                	ja     f0100c98 <mem_init+0xad>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100c83:	50                   	push   %eax
f0100c84:	68 e0 2a 10 f0       	push   $0xf0102ae0
f0100c89:	68 91 00 00 00       	push   $0x91
f0100c8e:	68 6a 2c 10 f0       	push   $0xf0102c6a
f0100c93:	e8 9b f4 ff ff       	call   f0100133 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100c98:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100c9e:	83 ca 05             	or     $0x5,%edx
f0100ca1:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(8*npages);
f0100ca7:	a1 64 59 11 f0       	mov    0xf0115964,%eax
f0100cac:	c1 e0 03             	shl    $0x3,%eax
f0100caf:	e8 b4 fc ff ff       	call   f0100968 <boot_alloc>
f0100cb4:	a3 6c 59 11 f0       	mov    %eax,0xf011596c
	memset(pages, 0, 8*npages);
f0100cb9:	83 ec 04             	sub    $0x4,%esp
f0100cbc:	8b 3d 64 59 11 f0    	mov    0xf0115964,%edi
f0100cc2:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0100cc9:	52                   	push   %edx
f0100cca:	6a 00                	push   $0x0
f0100ccc:	50                   	push   %eax
f0100ccd:	e8 ba 13 00 00       	call   f010208c <memset>
	page_init();
f0100cd2:	e8 94 fd ff ff       	call   f0100a6b <page_init>
	if (!page_free_list)
f0100cd7:	a1 3c 55 11 f0       	mov    0xf011553c,%eax
f0100cdc:	83 c4 10             	add    $0x10,%esp
f0100cdf:	85 c0                	test   %eax,%eax
f0100ce1:	74 4c                	je     f0100d2f <mem_init+0x144>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100ce3:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100ce6:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100ce9:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100cec:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100cef:	89 c2                	mov    %eax,%edx
f0100cf1:	2b 15 6c 59 11 f0    	sub    0xf011596c,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit; 
f0100cf7:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100cfd:	0f 95 c2             	setne  %dl
f0100d00:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100d03:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100d07:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100d09:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d0d:	8b 00                	mov    (%eax),%eax
f0100d0f:	85 c0                	test   %eax,%eax
f0100d11:	75 dc                	jne    f0100cef <mem_init+0x104>
		*tp[1] = 0;
f0100d13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d16:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100d1c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100d1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d22:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100d24:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0100d27:	89 1d 3c 55 11 f0    	mov    %ebx,0xf011553c
f0100d2d:	eb 2b                	jmp    f0100d5a <mem_init+0x16f>
		panic("'page_free_list' is a null pointer!");
f0100d2f:	83 ec 04             	sub    $0x4,%esp
f0100d32:	68 04 2b 10 f0       	push   $0xf0102b04
f0100d37:	68 da 01 00 00       	push   $0x1da
f0100d3c:	68 6a 2c 10 f0       	push   $0xf0102c6a
f0100d41:	e8 ed f3 ff ff       	call   f0100133 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d46:	50                   	push   %eax
f0100d47:	68 80 2a 10 f0       	push   $0xf0102a80
f0100d4c:	6a 52                	push   $0x52
f0100d4e:	68 5c 2c 10 f0       	push   $0xf0102c5c
f0100d53:	e8 db f3 ff ff       	call   f0100133 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d58:	8b 1b                	mov    (%ebx),%ebx
f0100d5a:	85 db                	test   %ebx,%ebx
f0100d5c:	74 3f                	je     f0100d9d <mem_init+0x1b2>
	return (pp - pages) << PGSHIFT;
f0100d5e:	89 d8                	mov    %ebx,%eax
f0100d60:	2b 05 6c 59 11 f0    	sub    0xf011596c,%eax
f0100d66:	c1 f8 03             	sar    $0x3,%eax
f0100d69:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100d6c:	89 c6                	mov    %eax,%esi
f0100d6e:	c1 ee 16             	shr    $0x16,%esi
f0100d71:	75 e5                	jne    f0100d58 <mem_init+0x16d>
	if (PGNUM(pa) >= npages)
f0100d73:	89 c2                	mov    %eax,%edx
f0100d75:	c1 ea 0c             	shr    $0xc,%edx
f0100d78:	3b 15 64 59 11 f0    	cmp    0xf0115964,%edx
f0100d7e:	73 c6                	jae    f0100d46 <mem_init+0x15b>
			memset(page2kva(pp), 0x97, 128);
f0100d80:	83 ec 04             	sub    $0x4,%esp
f0100d83:	68 80 00 00 00       	push   $0x80
f0100d88:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100d8d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d92:	50                   	push   %eax
f0100d93:	e8 f4 12 00 00       	call   f010208c <memset>
f0100d98:	83 c4 10             	add    $0x10,%esp
f0100d9b:	eb bb                	jmp    f0100d58 <mem_init+0x16d>
	first_free_page = (char *) boot_alloc(0);
f0100d9d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100da2:	e8 c1 fb ff ff       	call   f0100968 <boot_alloc>
f0100da7:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100daa:	8b 15 3c 55 11 f0    	mov    0xf011553c,%edx
		assert(pp >= pages);
f0100db0:	8b 0d 6c 59 11 f0    	mov    0xf011596c,%ecx
		assert(pp < pages + npages);
f0100db6:	a1 64 59 11 f0       	mov    0xf0115964,%eax
f0100dbb:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100dbe:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100dc1:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0100dc4:	be 00 00 00 00       	mov    $0x0,%esi
f0100dc9:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0100dcc:	e9 c8 00 00 00       	jmp    f0100e99 <mem_init+0x2ae>
		assert(pp >= pages);
f0100dd1:	68 a1 2c 10 f0       	push   $0xf0102ca1
f0100dd6:	68 ad 2c 10 f0       	push   $0xf0102cad
f0100ddb:	68 f4 01 00 00       	push   $0x1f4
f0100de0:	68 6a 2c 10 f0       	push   $0xf0102c6a
f0100de5:	e8 49 f3 ff ff       	call   f0100133 <_panic>
		assert(pp < pages + npages);
f0100dea:	68 c2 2c 10 f0       	push   $0xf0102cc2
f0100def:	68 ad 2c 10 f0       	push   $0xf0102cad
f0100df4:	68 f5 01 00 00       	push   $0x1f5
f0100df9:	68 6a 2c 10 f0       	push   $0xf0102c6a
f0100dfe:	e8 30 f3 ff ff       	call   f0100133 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100e03:	68 28 2b 10 f0       	push   $0xf0102b28
f0100e08:	68 ad 2c 10 f0       	push   $0xf0102cad
f0100e0d:	68 f6 01 00 00       	push   $0x1f6
f0100e12:	68 6a 2c 10 f0       	push   $0xf0102c6a
f0100e17:	e8 17 f3 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) != 0);
f0100e1c:	68 d6 2c 10 f0       	push   $0xf0102cd6
f0100e21:	68 ad 2c 10 f0       	push   $0xf0102cad
f0100e26:	68 f9 01 00 00       	push   $0x1f9
f0100e2b:	68 6a 2c 10 f0       	push   $0xf0102c6a
f0100e30:	e8 fe f2 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100e35:	68 e7 2c 10 f0       	push   $0xf0102ce7
f0100e3a:	68 ad 2c 10 f0       	push   $0xf0102cad
f0100e3f:	68 fa 01 00 00       	push   $0x1fa
f0100e44:	68 6a 2c 10 f0       	push   $0xf0102c6a
f0100e49:	e8 e5 f2 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100e4e:	68 5c 2b 10 f0       	push   $0xf0102b5c
f0100e53:	68 ad 2c 10 f0       	push   $0xf0102cad
f0100e58:	68 fb 01 00 00       	push   $0x1fb
f0100e5d:	68 6a 2c 10 f0       	push   $0xf0102c6a
f0100e62:	e8 cc f2 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e67:	68 00 2d 10 f0       	push   $0xf0102d00
f0100e6c:	68 ad 2c 10 f0       	push   $0xf0102cad
f0100e71:	68 fc 01 00 00       	push   $0x1fc
f0100e76:	68 6a 2c 10 f0       	push   $0xf0102c6a
f0100e7b:	e8 b3 f2 ff ff       	call   f0100133 <_panic>
	if (PGNUM(pa) >= npages)
f0100e80:	89 c3                	mov    %eax,%ebx
f0100e82:	c1 eb 0c             	shr    $0xc,%ebx
f0100e85:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100e88:	76 63                	jbe    f0100eed <mem_init+0x302>
	return (void *)(pa + KERNBASE);
f0100e8a:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e8f:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100e92:	77 6b                	ja     f0100eff <mem_init+0x314>
			++nfree_extmem;
f0100e94:	ff 45 d0             	incl   -0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e97:	8b 12                	mov    (%edx),%edx
f0100e99:	85 d2                	test   %edx,%edx
f0100e9b:	74 7b                	je     f0100f18 <mem_init+0x32d>
		assert(pp >= pages);
f0100e9d:	39 d1                	cmp    %edx,%ecx
f0100e9f:	0f 87 2c ff ff ff    	ja     f0100dd1 <mem_init+0x1e6>
		assert(pp < pages + npages);
f0100ea5:	39 fa                	cmp    %edi,%edx
f0100ea7:	0f 83 3d ff ff ff    	jae    f0100dea <mem_init+0x1ff>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ead:	89 d0                	mov    %edx,%eax
f0100eaf:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100eb2:	a8 07                	test   $0x7,%al
f0100eb4:	0f 85 49 ff ff ff    	jne    f0100e03 <mem_init+0x218>
	return (pp - pages) << PGSHIFT;
f0100eba:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100ebd:	c1 e0 0c             	shl    $0xc,%eax
f0100ec0:	0f 84 56 ff ff ff    	je     f0100e1c <mem_init+0x231>
		assert(page2pa(pp) != IOPHYSMEM);
f0100ec6:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100ecb:	0f 84 64 ff ff ff    	je     f0100e35 <mem_init+0x24a>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100ed1:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100ed6:	0f 84 72 ff ff ff    	je     f0100e4e <mem_init+0x263>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100edc:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100ee1:	74 84                	je     f0100e67 <mem_init+0x27c>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100ee3:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100ee8:	77 96                	ja     f0100e80 <mem_init+0x295>
			++nfree_basemem;
f0100eea:	46                   	inc    %esi
f0100eeb:	eb aa                	jmp    f0100e97 <mem_init+0x2ac>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100eed:	50                   	push   %eax
f0100eee:	68 80 2a 10 f0       	push   $0xf0102a80
f0100ef3:	6a 52                	push   $0x52
f0100ef5:	68 5c 2c 10 f0       	push   $0xf0102c5c
f0100efa:	e8 34 f2 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100eff:	68 80 2b 10 f0       	push   $0xf0102b80
f0100f04:	68 ad 2c 10 f0       	push   $0xf0102cad
f0100f09:	68 fd 01 00 00       	push   $0x1fd
f0100f0e:	68 6a 2c 10 f0       	push   $0xf0102c6a
f0100f13:	e8 1b f2 ff ff       	call   f0100133 <_panic>
f0100f18:	8b 5d d0             	mov    -0x30(%ebp),%ebx
	assert(nfree_basemem > 0);
f0100f1b:	85 f6                	test   %esi,%esi
f0100f1d:	7e 3e                	jle    f0100f5d <mem_init+0x372>
	assert(nfree_extmem > 0);
f0100f1f:	85 db                	test   %ebx,%ebx
f0100f21:	7e 53                	jle    f0100f76 <mem_init+0x38b>
	cprintf("check_page_free_list() succeeded!\n");
f0100f23:	83 ec 0c             	sub    $0xc,%esp
f0100f26:	68 c8 2b 10 f0       	push   $0xf0102bc8
f0100f2b:	e8 2d 06 00 00       	call   f010155d <cprintf>
	if (!pages)
f0100f30:	83 c4 10             	add    $0x10,%esp
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0100f33:	a1 3c 55 11 f0       	mov    0xf011553c,%eax
f0100f38:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (!pages)
f0100f3d:	83 3d 6c 59 11 f0 00 	cmpl   $0x0,0xf011596c
f0100f44:	75 4c                	jne    f0100f92 <mem_init+0x3a7>
		panic("'pages' is a null pointer!");
f0100f46:	83 ec 04             	sub    $0x4,%esp
f0100f49:	68 3d 2d 10 f0       	push   $0xf0102d3d
f0100f4e:	68 19 02 00 00       	push   $0x219
f0100f53:	68 6a 2c 10 f0       	push   $0xf0102c6a
f0100f58:	e8 d6 f1 ff ff       	call   f0100133 <_panic>
	assert(nfree_basemem > 0);
f0100f5d:	68 1a 2d 10 f0       	push   $0xf0102d1a
f0100f62:	68 ad 2c 10 f0       	push   $0xf0102cad
f0100f67:	68 05 02 00 00       	push   $0x205
f0100f6c:	68 6a 2c 10 f0       	push   $0xf0102c6a
f0100f71:	e8 bd f1 ff ff       	call   f0100133 <_panic>
	assert(nfree_extmem > 0);
f0100f76:	68 2c 2d 10 f0       	push   $0xf0102d2c
f0100f7b:	68 ad 2c 10 f0       	push   $0xf0102cad
f0100f80:	68 06 02 00 00       	push   $0x206
f0100f85:	68 6a 2c 10 f0       	push   $0xf0102c6a
f0100f8a:	e8 a4 f1 ff ff       	call   f0100133 <_panic>
		++nfree;
f0100f8f:	43                   	inc    %ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0100f90:	8b 00                	mov    (%eax),%eax
f0100f92:	85 c0                	test   %eax,%eax
f0100f94:	75 f9                	jne    f0100f8f <mem_init+0x3a4>
	assert((pp0 = page_alloc(0)));
f0100f96:	83 ec 0c             	sub    $0xc,%esp
f0100f99:	6a 00                	push   $0x0
f0100f9b:	e8 87 fb ff ff       	call   f0100b27 <page_alloc>
f0100fa0:	89 c7                	mov    %eax,%edi
f0100fa2:	83 c4 10             	add    $0x10,%esp
f0100fa5:	85 c0                	test   %eax,%eax
f0100fa7:	0f 84 d3 01 00 00    	je     f0101180 <mem_init+0x595>
	assert((pp1 = page_alloc(0)));
f0100fad:	83 ec 0c             	sub    $0xc,%esp
f0100fb0:	6a 00                	push   $0x0
f0100fb2:	e8 70 fb ff ff       	call   f0100b27 <page_alloc>
f0100fb7:	89 c6                	mov    %eax,%esi
f0100fb9:	83 c4 10             	add    $0x10,%esp
f0100fbc:	85 c0                	test   %eax,%eax
f0100fbe:	0f 84 d5 01 00 00    	je     f0101199 <mem_init+0x5ae>
	assert((pp2 = page_alloc(0)));
f0100fc4:	83 ec 0c             	sub    $0xc,%esp
f0100fc7:	6a 00                	push   $0x0
f0100fc9:	e8 59 fb ff ff       	call   f0100b27 <page_alloc>
f0100fce:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100fd1:	83 c4 10             	add    $0x10,%esp
f0100fd4:	85 c0                	test   %eax,%eax
f0100fd6:	0f 84 d6 01 00 00    	je     f01011b2 <mem_init+0x5c7>
	assert(pp1 && pp1 != pp0);
f0100fdc:	39 f7                	cmp    %esi,%edi
f0100fde:	0f 84 e7 01 00 00    	je     f01011cb <mem_init+0x5e0>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0100fe4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100fe7:	39 c6                	cmp    %eax,%esi
f0100fe9:	0f 84 f5 01 00 00    	je     f01011e4 <mem_init+0x5f9>
f0100fef:	39 c7                	cmp    %eax,%edi
f0100ff1:	0f 84 ed 01 00 00    	je     f01011e4 <mem_init+0x5f9>
	return (pp - pages) << PGSHIFT;
f0100ff7:	8b 0d 6c 59 11 f0    	mov    0xf011596c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0100ffd:	8b 15 64 59 11 f0    	mov    0xf0115964,%edx
f0101003:	c1 e2 0c             	shl    $0xc,%edx
f0101006:	89 f8                	mov    %edi,%eax
f0101008:	29 c8                	sub    %ecx,%eax
f010100a:	c1 f8 03             	sar    $0x3,%eax
f010100d:	c1 e0 0c             	shl    $0xc,%eax
f0101010:	39 d0                	cmp    %edx,%eax
f0101012:	0f 83 e5 01 00 00    	jae    f01011fd <mem_init+0x612>
f0101018:	89 f0                	mov    %esi,%eax
f010101a:	29 c8                	sub    %ecx,%eax
f010101c:	c1 f8 03             	sar    $0x3,%eax
f010101f:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101022:	39 c2                	cmp    %eax,%edx
f0101024:	0f 86 ec 01 00 00    	jbe    f0101216 <mem_init+0x62b>
f010102a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010102d:	29 c8                	sub    %ecx,%eax
f010102f:	c1 f8 03             	sar    $0x3,%eax
f0101032:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101035:	39 c2                	cmp    %eax,%edx
f0101037:	0f 86 f2 01 00 00    	jbe    f010122f <mem_init+0x644>
	fl = page_free_list;
f010103d:	a1 3c 55 11 f0       	mov    0xf011553c,%eax
f0101042:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101045:	c7 05 3c 55 11 f0 00 	movl   $0x0,0xf011553c
f010104c:	00 00 00 
	assert(!page_alloc(0));
f010104f:	83 ec 0c             	sub    $0xc,%esp
f0101052:	6a 00                	push   $0x0
f0101054:	e8 ce fa ff ff       	call   f0100b27 <page_alloc>
f0101059:	83 c4 10             	add    $0x10,%esp
f010105c:	85 c0                	test   %eax,%eax
f010105e:	0f 85 e4 01 00 00    	jne    f0101248 <mem_init+0x65d>
	page_free(pp0);
f0101064:	83 ec 0c             	sub    $0xc,%esp
f0101067:	57                   	push   %edi
f0101068:	e8 2c fb ff ff       	call   f0100b99 <page_free>
	page_free(pp1);
f010106d:	89 34 24             	mov    %esi,(%esp)
f0101070:	e8 24 fb ff ff       	call   f0100b99 <page_free>
	page_free(pp2);
f0101075:	83 c4 04             	add    $0x4,%esp
f0101078:	ff 75 d4             	pushl  -0x2c(%ebp)
f010107b:	e8 19 fb ff ff       	call   f0100b99 <page_free>
	assert((pp0 = page_alloc(0)));
f0101080:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101087:	e8 9b fa ff ff       	call   f0100b27 <page_alloc>
f010108c:	89 c6                	mov    %eax,%esi
f010108e:	83 c4 10             	add    $0x10,%esp
f0101091:	85 c0                	test   %eax,%eax
f0101093:	0f 84 c8 01 00 00    	je     f0101261 <mem_init+0x676>
	assert((pp1 = page_alloc(0)));
f0101099:	83 ec 0c             	sub    $0xc,%esp
f010109c:	6a 00                	push   $0x0
f010109e:	e8 84 fa ff ff       	call   f0100b27 <page_alloc>
f01010a3:	89 c7                	mov    %eax,%edi
f01010a5:	83 c4 10             	add    $0x10,%esp
f01010a8:	85 c0                	test   %eax,%eax
f01010aa:	0f 84 ca 01 00 00    	je     f010127a <mem_init+0x68f>
	assert((pp2 = page_alloc(0)));
f01010b0:	83 ec 0c             	sub    $0xc,%esp
f01010b3:	6a 00                	push   $0x0
f01010b5:	e8 6d fa ff ff       	call   f0100b27 <page_alloc>
f01010ba:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01010bd:	83 c4 10             	add    $0x10,%esp
f01010c0:	85 c0                	test   %eax,%eax
f01010c2:	0f 84 cb 01 00 00    	je     f0101293 <mem_init+0x6a8>
	assert(pp1 && pp1 != pp0);
f01010c8:	39 fe                	cmp    %edi,%esi
f01010ca:	0f 84 dc 01 00 00    	je     f01012ac <mem_init+0x6c1>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01010d0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01010d3:	39 c7                	cmp    %eax,%edi
f01010d5:	0f 84 ea 01 00 00    	je     f01012c5 <mem_init+0x6da>
f01010db:	39 c6                	cmp    %eax,%esi
f01010dd:	0f 84 e2 01 00 00    	je     f01012c5 <mem_init+0x6da>
	assert(!page_alloc(0));
f01010e3:	83 ec 0c             	sub    $0xc,%esp
f01010e6:	6a 00                	push   $0x0
f01010e8:	e8 3a fa ff ff       	call   f0100b27 <page_alloc>
f01010ed:	83 c4 10             	add    $0x10,%esp
f01010f0:	85 c0                	test   %eax,%eax
f01010f2:	0f 85 e6 01 00 00    	jne    f01012de <mem_init+0x6f3>
	memset(page2kva(pp0), 1, PGSIZE);
f01010f8:	89 f0                	mov    %esi,%eax
f01010fa:	e8 d6 f8 ff ff       	call   f01009d5 <page2kva>
f01010ff:	83 ec 04             	sub    $0x4,%esp
f0101102:	68 00 10 00 00       	push   $0x1000
f0101107:	6a 01                	push   $0x1
f0101109:	50                   	push   %eax
f010110a:	e8 7d 0f 00 00       	call   f010208c <memset>
	page_free(pp0);
f010110f:	89 34 24             	mov    %esi,(%esp)
f0101112:	e8 82 fa ff ff       	call   f0100b99 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101117:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010111e:	e8 04 fa ff ff       	call   f0100b27 <page_alloc>
f0101123:	83 c4 10             	add    $0x10,%esp
f0101126:	85 c0                	test   %eax,%eax
f0101128:	0f 84 c9 01 00 00    	je     f01012f7 <mem_init+0x70c>
	assert(pp && pp0 == pp);
f010112e:	39 c6                	cmp    %eax,%esi
f0101130:	0f 85 da 01 00 00    	jne    f0101310 <mem_init+0x725>
	c = page2kva(pp);
f0101136:	e8 9a f8 ff ff       	call   f01009d5 <page2kva>
f010113b:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		assert(c[i] == 0);
f0101141:	80 38 00             	cmpb   $0x0,(%eax)
f0101144:	0f 85 df 01 00 00    	jne    f0101329 <mem_init+0x73e>
f010114a:	40                   	inc    %eax
	for (i = 0; i < PGSIZE; i++)
f010114b:	39 c2                	cmp    %eax,%edx
f010114d:	75 f2                	jne    f0101141 <mem_init+0x556>
	page_free_list = fl;
f010114f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101152:	a3 3c 55 11 f0       	mov    %eax,0xf011553c
	page_free(pp0);
f0101157:	83 ec 0c             	sub    $0xc,%esp
f010115a:	56                   	push   %esi
f010115b:	e8 39 fa ff ff       	call   f0100b99 <page_free>
	page_free(pp1);
f0101160:	89 3c 24             	mov    %edi,(%esp)
f0101163:	e8 31 fa ff ff       	call   f0100b99 <page_free>
	page_free(pp2);
f0101168:	83 c4 04             	add    $0x4,%esp
f010116b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010116e:	e8 26 fa ff ff       	call   f0100b99 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101173:	a1 3c 55 11 f0       	mov    0xf011553c,%eax
f0101178:	83 c4 10             	add    $0x10,%esp
f010117b:	e9 c5 01 00 00       	jmp    f0101345 <mem_init+0x75a>
	assert((pp0 = page_alloc(0)));
f0101180:	68 58 2d 10 f0       	push   $0xf0102d58
f0101185:	68 ad 2c 10 f0       	push   $0xf0102cad
f010118a:	68 21 02 00 00       	push   $0x221
f010118f:	68 6a 2c 10 f0       	push   $0xf0102c6a
f0101194:	e8 9a ef ff ff       	call   f0100133 <_panic>
	assert((pp1 = page_alloc(0)));
f0101199:	68 6e 2d 10 f0       	push   $0xf0102d6e
f010119e:	68 ad 2c 10 f0       	push   $0xf0102cad
f01011a3:	68 22 02 00 00       	push   $0x222
f01011a8:	68 6a 2c 10 f0       	push   $0xf0102c6a
f01011ad:	e8 81 ef ff ff       	call   f0100133 <_panic>
	assert((pp2 = page_alloc(0)));
f01011b2:	68 84 2d 10 f0       	push   $0xf0102d84
f01011b7:	68 ad 2c 10 f0       	push   $0xf0102cad
f01011bc:	68 23 02 00 00       	push   $0x223
f01011c1:	68 6a 2c 10 f0       	push   $0xf0102c6a
f01011c6:	e8 68 ef ff ff       	call   f0100133 <_panic>
	assert(pp1 && pp1 != pp0);
f01011cb:	68 9a 2d 10 f0       	push   $0xf0102d9a
f01011d0:	68 ad 2c 10 f0       	push   $0xf0102cad
f01011d5:	68 26 02 00 00       	push   $0x226
f01011da:	68 6a 2c 10 f0       	push   $0xf0102c6a
f01011df:	e8 4f ef ff ff       	call   f0100133 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01011e4:	68 ec 2b 10 f0       	push   $0xf0102bec
f01011e9:	68 ad 2c 10 f0       	push   $0xf0102cad
f01011ee:	68 27 02 00 00       	push   $0x227
f01011f3:	68 6a 2c 10 f0       	push   $0xf0102c6a
f01011f8:	e8 36 ef ff ff       	call   f0100133 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f01011fd:	68 ac 2d 10 f0       	push   $0xf0102dac
f0101202:	68 ad 2c 10 f0       	push   $0xf0102cad
f0101207:	68 28 02 00 00       	push   $0x228
f010120c:	68 6a 2c 10 f0       	push   $0xf0102c6a
f0101211:	e8 1d ef ff ff       	call   f0100133 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101216:	68 c9 2d 10 f0       	push   $0xf0102dc9
f010121b:	68 ad 2c 10 f0       	push   $0xf0102cad
f0101220:	68 29 02 00 00       	push   $0x229
f0101225:	68 6a 2c 10 f0       	push   $0xf0102c6a
f010122a:	e8 04 ef ff ff       	call   f0100133 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010122f:	68 e6 2d 10 f0       	push   $0xf0102de6
f0101234:	68 ad 2c 10 f0       	push   $0xf0102cad
f0101239:	68 2a 02 00 00       	push   $0x22a
f010123e:	68 6a 2c 10 f0       	push   $0xf0102c6a
f0101243:	e8 eb ee ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f0101248:	68 03 2e 10 f0       	push   $0xf0102e03
f010124d:	68 ad 2c 10 f0       	push   $0xf0102cad
f0101252:	68 31 02 00 00       	push   $0x231
f0101257:	68 6a 2c 10 f0       	push   $0xf0102c6a
f010125c:	e8 d2 ee ff ff       	call   f0100133 <_panic>
	assert((pp0 = page_alloc(0)));
f0101261:	68 58 2d 10 f0       	push   $0xf0102d58
f0101266:	68 ad 2c 10 f0       	push   $0xf0102cad
f010126b:	68 38 02 00 00       	push   $0x238
f0101270:	68 6a 2c 10 f0       	push   $0xf0102c6a
f0101275:	e8 b9 ee ff ff       	call   f0100133 <_panic>
	assert((pp1 = page_alloc(0)));
f010127a:	68 6e 2d 10 f0       	push   $0xf0102d6e
f010127f:	68 ad 2c 10 f0       	push   $0xf0102cad
f0101284:	68 39 02 00 00       	push   $0x239
f0101289:	68 6a 2c 10 f0       	push   $0xf0102c6a
f010128e:	e8 a0 ee ff ff       	call   f0100133 <_panic>
	assert((pp2 = page_alloc(0)));
f0101293:	68 84 2d 10 f0       	push   $0xf0102d84
f0101298:	68 ad 2c 10 f0       	push   $0xf0102cad
f010129d:	68 3a 02 00 00       	push   $0x23a
f01012a2:	68 6a 2c 10 f0       	push   $0xf0102c6a
f01012a7:	e8 87 ee ff ff       	call   f0100133 <_panic>
	assert(pp1 && pp1 != pp0);
f01012ac:	68 9a 2d 10 f0       	push   $0xf0102d9a
f01012b1:	68 ad 2c 10 f0       	push   $0xf0102cad
f01012b6:	68 3c 02 00 00       	push   $0x23c
f01012bb:	68 6a 2c 10 f0       	push   $0xf0102c6a
f01012c0:	e8 6e ee ff ff       	call   f0100133 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01012c5:	68 ec 2b 10 f0       	push   $0xf0102bec
f01012ca:	68 ad 2c 10 f0       	push   $0xf0102cad
f01012cf:	68 3d 02 00 00       	push   $0x23d
f01012d4:	68 6a 2c 10 f0       	push   $0xf0102c6a
f01012d9:	e8 55 ee ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f01012de:	68 03 2e 10 f0       	push   $0xf0102e03
f01012e3:	68 ad 2c 10 f0       	push   $0xf0102cad
f01012e8:	68 3e 02 00 00       	push   $0x23e
f01012ed:	68 6a 2c 10 f0       	push   $0xf0102c6a
f01012f2:	e8 3c ee ff ff       	call   f0100133 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01012f7:	68 12 2e 10 f0       	push   $0xf0102e12
f01012fc:	68 ad 2c 10 f0       	push   $0xf0102cad
f0101301:	68 43 02 00 00       	push   $0x243
f0101306:	68 6a 2c 10 f0       	push   $0xf0102c6a
f010130b:	e8 23 ee ff ff       	call   f0100133 <_panic>
	assert(pp && pp0 == pp);
f0101310:	68 30 2e 10 f0       	push   $0xf0102e30
f0101315:	68 ad 2c 10 f0       	push   $0xf0102cad
f010131a:	68 44 02 00 00       	push   $0x244
f010131f:	68 6a 2c 10 f0       	push   $0xf0102c6a
f0101324:	e8 0a ee ff ff       	call   f0100133 <_panic>
		assert(c[i] == 0);
f0101329:	68 40 2e 10 f0       	push   $0xf0102e40
f010132e:	68 ad 2c 10 f0       	push   $0xf0102cad
f0101333:	68 47 02 00 00       	push   $0x247
f0101338:	68 6a 2c 10 f0       	push   $0xf0102c6a
f010133d:	e8 f1 ed ff ff       	call   f0100133 <_panic>
		--nfree;
f0101342:	4b                   	dec    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101343:	8b 00                	mov    (%eax),%eax
f0101345:	85 c0                	test   %eax,%eax
f0101347:	75 f9                	jne    f0101342 <mem_init+0x757>
	assert(nfree == 0);
f0101349:	85 db                	test   %ebx,%ebx
f010134b:	0f 85 a2 00 00 00    	jne    f01013f3 <mem_init+0x808>
	cprintf("check_page_alloc() succeeded!\n");
f0101351:	83 ec 0c             	sub    $0xc,%esp
f0101354:	68 0c 2c 10 f0       	push   $0xf0102c0c
f0101359:	e8 ff 01 00 00       	call   f010155d <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010135e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101365:	e8 bd f7 ff ff       	call   f0100b27 <page_alloc>
f010136a:	89 c3                	mov    %eax,%ebx
f010136c:	83 c4 10             	add    $0x10,%esp
f010136f:	85 c0                	test   %eax,%eax
f0101371:	0f 84 95 00 00 00    	je     f010140c <mem_init+0x821>
	assert((pp1 = page_alloc(0)));
f0101377:	83 ec 0c             	sub    $0xc,%esp
f010137a:	6a 00                	push   $0x0
f010137c:	e8 a6 f7 ff ff       	call   f0100b27 <page_alloc>
f0101381:	89 c6                	mov    %eax,%esi
f0101383:	83 c4 10             	add    $0x10,%esp
f0101386:	85 c0                	test   %eax,%eax
f0101388:	0f 84 97 00 00 00    	je     f0101425 <mem_init+0x83a>
	assert((pp2 = page_alloc(0)));
f010138e:	83 ec 0c             	sub    $0xc,%esp
f0101391:	6a 00                	push   $0x0
f0101393:	e8 8f f7 ff ff       	call   f0100b27 <page_alloc>
f0101398:	83 c4 10             	add    $0x10,%esp
f010139b:	85 c0                	test   %eax,%eax
f010139d:	0f 84 9b 00 00 00    	je     f010143e <mem_init+0x853>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01013a3:	39 f3                	cmp    %esi,%ebx
f01013a5:	0f 84 ac 00 00 00    	je     f0101457 <mem_init+0x86c>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013ab:	39 c6                	cmp    %eax,%esi
f01013ad:	0f 84 bd 00 00 00    	je     f0101470 <mem_init+0x885>
f01013b3:	39 c3                	cmp    %eax,%ebx
f01013b5:	0f 84 b5 00 00 00    	je     f0101470 <mem_init+0x885>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
	page_free_list = 0;
f01013bb:	c7 05 3c 55 11 f0 00 	movl   $0x0,0xf011553c
f01013c2:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01013c5:	83 ec 0c             	sub    $0xc,%esp
f01013c8:	6a 00                	push   $0x0
f01013ca:	e8 58 f7 ff ff       	call   f0100b27 <page_alloc>
f01013cf:	83 c4 10             	add    $0x10,%esp
f01013d2:	85 c0                	test   %eax,%eax
f01013d4:	0f 84 af 00 00 00    	je     f0101489 <mem_init+0x89e>
f01013da:	68 03 2e 10 f0       	push   $0xf0102e03
f01013df:	68 ad 2c 10 f0       	push   $0xf0102cad
f01013e4:	68 ba 02 00 00       	push   $0x2ba
f01013e9:	68 6a 2c 10 f0       	push   $0xf0102c6a
f01013ee:	e8 40 ed ff ff       	call   f0100133 <_panic>
	assert(nfree == 0);
f01013f3:	68 4a 2e 10 f0       	push   $0xf0102e4a
f01013f8:	68 ad 2c 10 f0       	push   $0xf0102cad
f01013fd:	68 54 02 00 00       	push   $0x254
f0101402:	68 6a 2c 10 f0       	push   $0xf0102c6a
f0101407:	e8 27 ed ff ff       	call   f0100133 <_panic>
	assert((pp0 = page_alloc(0)));
f010140c:	68 58 2d 10 f0       	push   $0xf0102d58
f0101411:	68 ad 2c 10 f0       	push   $0xf0102cad
f0101416:	68 ad 02 00 00       	push   $0x2ad
f010141b:	68 6a 2c 10 f0       	push   $0xf0102c6a
f0101420:	e8 0e ed ff ff       	call   f0100133 <_panic>
	assert((pp1 = page_alloc(0)));
f0101425:	68 6e 2d 10 f0       	push   $0xf0102d6e
f010142a:	68 ad 2c 10 f0       	push   $0xf0102cad
f010142f:	68 ae 02 00 00       	push   $0x2ae
f0101434:	68 6a 2c 10 f0       	push   $0xf0102c6a
f0101439:	e8 f5 ec ff ff       	call   f0100133 <_panic>
	assert((pp2 = page_alloc(0)));
f010143e:	68 84 2d 10 f0       	push   $0xf0102d84
f0101443:	68 ad 2c 10 f0       	push   $0xf0102cad
f0101448:	68 af 02 00 00       	push   $0x2af
f010144d:	68 6a 2c 10 f0       	push   $0xf0102c6a
f0101452:	e8 dc ec ff ff       	call   f0100133 <_panic>
	assert(pp1 && pp1 != pp0);
f0101457:	68 9a 2d 10 f0       	push   $0xf0102d9a
f010145c:	68 ad 2c 10 f0       	push   $0xf0102cad
f0101461:	68 b2 02 00 00       	push   $0x2b2
f0101466:	68 6a 2c 10 f0       	push   $0xf0102c6a
f010146b:	e8 c3 ec ff ff       	call   f0100133 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101470:	68 ec 2b 10 f0       	push   $0xf0102bec
f0101475:	68 ad 2c 10 f0       	push   $0xf0102cad
f010147a:	68 b3 02 00 00       	push   $0x2b3
f010147f:	68 6a 2c 10 f0       	push   $0xf0102c6a
f0101484:	e8 aa ec ff ff       	call   f0100133 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101489:	68 2c 2c 10 f0       	push   $0xf0102c2c
f010148e:	68 ad 2c 10 f0       	push   $0xf0102cad
f0101493:	68 c0 02 00 00       	push   $0x2c0
f0101498:	68 6a 2c 10 f0       	push   $0xf0102c6a
f010149d:	e8 91 ec ff ff       	call   f0100133 <_panic>

f01014a2 <page_decref>:
{
f01014a2:	55                   	push   %ebp
f01014a3:	89 e5                	mov    %esp,%ebp
f01014a5:	83 ec 08             	sub    $0x8,%esp
f01014a8:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01014ab:	8b 42 04             	mov    0x4(%edx),%eax
f01014ae:	48                   	dec    %eax
f01014af:	66 89 42 04          	mov    %ax,0x4(%edx)
f01014b3:	66 85 c0             	test   %ax,%ax
f01014b6:	74 02                	je     f01014ba <page_decref+0x18>
}
f01014b8:	c9                   	leave  
f01014b9:	c3                   	ret    
		page_free(pp);
f01014ba:	83 ec 0c             	sub    $0xc,%esp
f01014bd:	52                   	push   %edx
f01014be:	e8 d6 f6 ff ff       	call   f0100b99 <page_free>
f01014c3:	83 c4 10             	add    $0x10,%esp
}
f01014c6:	eb f0                	jmp    f01014b8 <page_decref+0x16>

f01014c8 <pgdir_walk>:
{
f01014c8:	55                   	push   %ebp
f01014c9:	89 e5                	mov    %esp,%ebp
}
f01014cb:	b8 00 00 00 00       	mov    $0x0,%eax
f01014d0:	5d                   	pop    %ebp
f01014d1:	c3                   	ret    

f01014d2 <page_insert>:
{
f01014d2:	55                   	push   %ebp
f01014d3:	89 e5                	mov    %esp,%ebp
}
f01014d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01014da:	5d                   	pop    %ebp
f01014db:	c3                   	ret    

f01014dc <page_lookup>:
{
f01014dc:	55                   	push   %ebp
f01014dd:	89 e5                	mov    %esp,%ebp
}
f01014df:	b8 00 00 00 00       	mov    $0x0,%eax
f01014e4:	5d                   	pop    %ebp
f01014e5:	c3                   	ret    

f01014e6 <page_remove>:
{
f01014e6:	55                   	push   %ebp
f01014e7:	89 e5                	mov    %esp,%ebp
}
f01014e9:	5d                   	pop    %ebp
f01014ea:	c3                   	ret    

f01014eb <tlb_invalidate>:
{
f01014eb:	55                   	push   %ebp
f01014ec:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01014ee:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014f1:	0f 01 38             	invlpg (%eax)
}
f01014f4:	5d                   	pop    %ebp
f01014f5:	c3                   	ret    

f01014f6 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01014f6:	55                   	push   %ebp
f01014f7:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01014f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01014fc:	ba 70 00 00 00       	mov    $0x70,%edx
f0101501:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0101502:	ba 71 00 00 00       	mov    $0x71,%edx
f0101507:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0101508:	0f b6 c0             	movzbl %al,%eax
}
f010150b:	5d                   	pop    %ebp
f010150c:	c3                   	ret    

f010150d <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010150d:	55                   	push   %ebp
f010150e:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0101510:	8b 45 08             	mov    0x8(%ebp),%eax
f0101513:	ba 70 00 00 00       	mov    $0x70,%edx
f0101518:	ee                   	out    %al,(%dx)
f0101519:	8b 45 0c             	mov    0xc(%ebp),%eax
f010151c:	ba 71 00 00 00       	mov    $0x71,%edx
f0101521:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0101522:	5d                   	pop    %ebp
f0101523:	c3                   	ret    

f0101524 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0101524:	55                   	push   %ebp
f0101525:	89 e5                	mov    %esp,%ebp
f0101527:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010152a:	ff 75 08             	pushl  0x8(%ebp)
f010152d:	e8 54 f1 ff ff       	call   f0100686 <cputchar>
	*cnt++;
}
f0101532:	83 c4 10             	add    $0x10,%esp
f0101535:	c9                   	leave  
f0101536:	c3                   	ret    

f0101537 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0101537:	55                   	push   %ebp
f0101538:	89 e5                	mov    %esp,%ebp
f010153a:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010153d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0101544:	ff 75 0c             	pushl  0xc(%ebp)
f0101547:	ff 75 08             	pushl  0x8(%ebp)
f010154a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010154d:	50                   	push   %eax
f010154e:	68 24 15 10 f0       	push   $0xf0101524
f0101553:	e8 1b 04 00 00       	call   f0101973 <vprintfmt>
	return cnt;
}
f0101558:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010155b:	c9                   	leave  
f010155c:	c3                   	ret    

f010155d <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010155d:	55                   	push   %ebp
f010155e:	89 e5                	mov    %esp,%ebp
f0101560:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0101563:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0101566:	50                   	push   %eax
f0101567:	ff 75 08             	pushl  0x8(%ebp)
f010156a:	e8 c8 ff ff ff       	call   f0101537 <vcprintf>
	va_end(ap);

	return cnt;
}
f010156f:	c9                   	leave  
f0101570:	c3                   	ret    

f0101571 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0101571:	55                   	push   %ebp
f0101572:	89 e5                	mov    %esp,%ebp
f0101574:	57                   	push   %edi
f0101575:	56                   	push   %esi
f0101576:	53                   	push   %ebx
f0101577:	83 ec 14             	sub    $0x14,%esp
f010157a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010157d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101580:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0101583:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0101586:	8b 32                	mov    (%edx),%esi
f0101588:	8b 01                	mov    (%ecx),%eax
f010158a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010158d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0101594:	eb 2f                	jmp    f01015c5 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0101596:	48                   	dec    %eax
		while (m >= l && stabs[m].n_type != type)
f0101597:	39 c6                	cmp    %eax,%esi
f0101599:	7f 4d                	jg     f01015e8 <stab_binsearch+0x77>
f010159b:	0f b6 0a             	movzbl (%edx),%ecx
f010159e:	83 ea 0c             	sub    $0xc,%edx
f01015a1:	39 f9                	cmp    %edi,%ecx
f01015a3:	75 f1                	jne    f0101596 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01015a5:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01015a8:	01 c2                	add    %eax,%edx
f01015aa:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01015ad:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01015b1:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01015b4:	73 37                	jae    f01015ed <stab_binsearch+0x7c>
			*region_left = m;
f01015b6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01015b9:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f01015bb:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f01015be:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f01015c5:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f01015c8:	7f 4d                	jg     f0101617 <stab_binsearch+0xa6>
		int true_m = (l + r) / 2, m = true_m;
f01015ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01015cd:	01 f0                	add    %esi,%eax
f01015cf:	89 c3                	mov    %eax,%ebx
f01015d1:	c1 eb 1f             	shr    $0x1f,%ebx
f01015d4:	01 c3                	add    %eax,%ebx
f01015d6:	d1 fb                	sar    %ebx
f01015d8:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f01015db:	01 d8                	add    %ebx,%eax
f01015dd:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01015e0:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f01015e4:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f01015e6:	eb af                	jmp    f0101597 <stab_binsearch+0x26>
			l = true_m + 1;
f01015e8:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f01015eb:	eb d8                	jmp    f01015c5 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f01015ed:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01015f0:	76 12                	jbe    f0101604 <stab_binsearch+0x93>
			*region_right = m - 1;
f01015f2:	48                   	dec    %eax
f01015f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01015f6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01015f9:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f01015fb:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0101602:	eb c1                	jmp    f01015c5 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0101604:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101607:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0101609:	ff 45 0c             	incl   0xc(%ebp)
f010160c:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f010160e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0101615:	eb ae                	jmp    f01015c5 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0101617:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010161b:	74 18                	je     f0101635 <stab_binsearch+0xc4>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010161d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101620:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0101622:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101625:	8b 0e                	mov    (%esi),%ecx
f0101627:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010162a:	01 c2                	add    %eax,%edx
f010162c:	8b 75 ec             	mov    -0x14(%ebp),%esi
f010162f:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0101633:	eb 0e                	jmp    f0101643 <stab_binsearch+0xd2>
		*region_right = *region_left - 1;
f0101635:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101638:	8b 00                	mov    (%eax),%eax
f010163a:	48                   	dec    %eax
f010163b:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010163e:	89 07                	mov    %eax,(%edi)
f0101640:	eb 14                	jmp    f0101656 <stab_binsearch+0xe5>
		     l--)
f0101642:	48                   	dec    %eax
		for (l = *region_right;
f0101643:	39 c1                	cmp    %eax,%ecx
f0101645:	7d 0a                	jge    f0101651 <stab_binsearch+0xe0>
		     l > *region_left && stabs[l].n_type != type;
f0101647:	0f b6 1a             	movzbl (%edx),%ebx
f010164a:	83 ea 0c             	sub    $0xc,%edx
f010164d:	39 fb                	cmp    %edi,%ebx
f010164f:	75 f1                	jne    f0101642 <stab_binsearch+0xd1>
			/* do nothing */;
		*region_left = l;
f0101651:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101654:	89 07                	mov    %eax,(%edi)
	}
}
f0101656:	83 c4 14             	add    $0x14,%esp
f0101659:	5b                   	pop    %ebx
f010165a:	5e                   	pop    %esi
f010165b:	5f                   	pop    %edi
f010165c:	5d                   	pop    %ebp
f010165d:	c3                   	ret    

f010165e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010165e:	55                   	push   %ebp
f010165f:	89 e5                	mov    %esp,%ebp
f0101661:	57                   	push   %edi
f0101662:	56                   	push   %esi
f0101663:	53                   	push   %ebx
f0101664:	83 ec 3c             	sub    $0x3c,%esp
f0101667:	8b 75 08             	mov    0x8(%ebp),%esi
f010166a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010166d:	c7 03 55 2e 10 f0    	movl   $0xf0102e55,(%ebx)
	info->eip_line = 0;
f0101673:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010167a:	c7 43 08 55 2e 10 f0 	movl   $0xf0102e55,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0101681:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0101688:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010168b:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0101692:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101698:	0f 86 31 01 00 00    	jbe    f01017cf <debuginfo_eip+0x171>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010169e:	b8 4e a0 10 f0       	mov    $0xf010a04e,%eax
f01016a3:	3d c1 82 10 f0       	cmp    $0xf01082c1,%eax
f01016a8:	0f 86 b6 01 00 00    	jbe    f0101864 <debuginfo_eip+0x206>
f01016ae:	80 3d 4d a0 10 f0 00 	cmpb   $0x0,0xf010a04d
f01016b5:	0f 85 b0 01 00 00    	jne    f010186b <debuginfo_eip+0x20d>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01016bb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01016c2:	ba c0 82 10 f0       	mov    $0xf01082c0,%edx
f01016c7:	81 ea 88 30 10 f0    	sub    $0xf0103088,%edx
f01016cd:	c1 fa 02             	sar    $0x2,%edx
f01016d0:	8d 04 92             	lea    (%edx,%edx,4),%eax
f01016d3:	8d 04 82             	lea    (%edx,%eax,4),%eax
f01016d6:	8d 04 82             	lea    (%edx,%eax,4),%eax
f01016d9:	89 c1                	mov    %eax,%ecx
f01016db:	c1 e1 08             	shl    $0x8,%ecx
f01016de:	01 c8                	add    %ecx,%eax
f01016e0:	89 c1                	mov    %eax,%ecx
f01016e2:	c1 e1 10             	shl    $0x10,%ecx
f01016e5:	01 c8                	add    %ecx,%eax
f01016e7:	01 c0                	add    %eax,%eax
f01016e9:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
f01016ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01016f0:	83 ec 08             	sub    $0x8,%esp
f01016f3:	56                   	push   %esi
f01016f4:	6a 64                	push   $0x64
f01016f6:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01016f9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01016fc:	b8 88 30 10 f0       	mov    $0xf0103088,%eax
f0101701:	e8 6b fe ff ff       	call   f0101571 <stab_binsearch>
	if (lfile == 0)
f0101706:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101709:	83 c4 10             	add    $0x10,%esp
f010170c:	85 c0                	test   %eax,%eax
f010170e:	0f 84 5e 01 00 00    	je     f0101872 <debuginfo_eip+0x214>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0101714:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0101717:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010171a:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010171d:	83 ec 08             	sub    $0x8,%esp
f0101720:	56                   	push   %esi
f0101721:	6a 24                	push   $0x24
f0101723:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0101726:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0101729:	b8 88 30 10 f0       	mov    $0xf0103088,%eax
f010172e:	e8 3e fe ff ff       	call   f0101571 <stab_binsearch>

	if (lfun <= rfun) {
f0101733:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101736:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101739:	83 c4 10             	add    $0x10,%esp
f010173c:	39 d0                	cmp    %edx,%eax
f010173e:	0f 8f 9f 00 00 00    	jg     f01017e3 <debuginfo_eip+0x185>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0101744:	8d 0c 00             	lea    (%eax,%eax,1),%ecx
f0101747:	01 c1                	add    %eax,%ecx
f0101749:	c1 e1 02             	shl    $0x2,%ecx
f010174c:	8d b9 88 30 10 f0    	lea    -0xfefcf78(%ecx),%edi
f0101752:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0101755:	8b 89 88 30 10 f0    	mov    -0xfefcf78(%ecx),%ecx
f010175b:	bf 4e a0 10 f0       	mov    $0xf010a04e,%edi
f0101760:	81 ef c1 82 10 f0    	sub    $0xf01082c1,%edi
f0101766:	39 f9                	cmp    %edi,%ecx
f0101768:	73 09                	jae    f0101773 <debuginfo_eip+0x115>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010176a:	81 c1 c1 82 10 f0    	add    $0xf01082c1,%ecx
f0101770:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0101773:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0101776:	8b 4f 08             	mov    0x8(%edi),%ecx
f0101779:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f010177c:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f010177e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0101781:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0101784:	83 ec 08             	sub    $0x8,%esp
f0101787:	6a 3a                	push   $0x3a
f0101789:	ff 73 08             	pushl  0x8(%ebx)
f010178c:	e8 e3 08 00 00       	call   f0102074 <strfind>
f0101791:	2b 43 08             	sub    0x8(%ebx),%eax
f0101794:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// N_SLINE represents text segment
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0101797:	83 c4 08             	add    $0x8,%esp
f010179a:	56                   	push   %esi
f010179b:	6a 44                	push   $0x44
f010179d:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01017a0:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01017a3:	b8 88 30 10 f0       	mov    $0xf0103088,%eax
f01017a8:	e8 c4 fd ff ff       	call   f0101571 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f01017ad:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01017b0:	8d 04 12             	lea    (%edx,%edx,1),%eax
f01017b3:	01 d0                	add    %edx,%eax
f01017b5:	c1 e0 02             	shl    $0x2,%eax
f01017b8:	0f b7 88 8e 30 10 f0 	movzwl -0xfefcf72(%eax),%ecx
f01017bf:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01017c2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01017c5:	05 8c 30 10 f0       	add    $0xf010308c,%eax
f01017ca:	83 c4 10             	add    $0x10,%esp
f01017cd:	eb 29                	jmp    f01017f8 <debuginfo_eip+0x19a>
  	        panic("User address");
f01017cf:	83 ec 04             	sub    $0x4,%esp
f01017d2:	68 5f 2e 10 f0       	push   $0xf0102e5f
f01017d7:	6a 7f                	push   $0x7f
f01017d9:	68 6c 2e 10 f0       	push   $0xf0102e6c
f01017de:	e8 50 e9 ff ff       	call   f0100133 <_panic>
		info->eip_fn_addr = addr;
f01017e3:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f01017e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01017e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01017ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01017ef:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01017f2:	eb 90                	jmp    f0101784 <debuginfo_eip+0x126>
f01017f4:	4a                   	dec    %edx
f01017f5:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f01017f8:	39 d6                	cmp    %edx,%esi
f01017fa:	7f 34                	jg     f0101830 <debuginfo_eip+0x1d2>
	       && stabs[lline].n_type != N_SOL
f01017fc:	8a 08                	mov    (%eax),%cl
f01017fe:	80 f9 84             	cmp    $0x84,%cl
f0101801:	74 0b                	je     f010180e <debuginfo_eip+0x1b0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0101803:	80 f9 64             	cmp    $0x64,%cl
f0101806:	75 ec                	jne    f01017f4 <debuginfo_eip+0x196>
f0101808:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f010180c:	74 e6                	je     f01017f4 <debuginfo_eip+0x196>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010180e:	8d 04 12             	lea    (%edx,%edx,1),%eax
f0101811:	01 c2                	add    %eax,%edx
f0101813:	8b 14 95 88 30 10 f0 	mov    -0xfefcf78(,%edx,4),%edx
f010181a:	b8 4e a0 10 f0       	mov    $0xf010a04e,%eax
f010181f:	2d c1 82 10 f0       	sub    $0xf01082c1,%eax
f0101824:	39 c2                	cmp    %eax,%edx
f0101826:	73 08                	jae    f0101830 <debuginfo_eip+0x1d2>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0101828:	81 c2 c1 82 10 f0    	add    $0xf01082c1,%edx
f010182e:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0101830:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101833:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0101836:	39 f2                	cmp    %esi,%edx
f0101838:	7d 3f                	jge    f0101879 <debuginfo_eip+0x21b>
		for (lline = lfun + 1;
f010183a:	42                   	inc    %edx
f010183b:	89 d0                	mov    %edx,%eax
f010183d:	8d 0c 12             	lea    (%edx,%edx,1),%ecx
f0101840:	01 ca                	add    %ecx,%edx
f0101842:	8d 14 95 8c 30 10 f0 	lea    -0xfefcf74(,%edx,4),%edx
f0101849:	eb 03                	jmp    f010184e <debuginfo_eip+0x1f0>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010184b:	ff 43 14             	incl   0x14(%ebx)
		for (lline = lfun + 1;
f010184e:	39 c6                	cmp    %eax,%esi
f0101850:	7e 34                	jle    f0101886 <debuginfo_eip+0x228>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0101852:	8a 0a                	mov    (%edx),%cl
f0101854:	40                   	inc    %eax
f0101855:	83 c2 0c             	add    $0xc,%edx
f0101858:	80 f9 a0             	cmp    $0xa0,%cl
f010185b:	74 ee                	je     f010184b <debuginfo_eip+0x1ed>

	return 0;
f010185d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101862:	eb 1a                	jmp    f010187e <debuginfo_eip+0x220>
		return -1;
f0101864:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101869:	eb 13                	jmp    f010187e <debuginfo_eip+0x220>
f010186b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101870:	eb 0c                	jmp    f010187e <debuginfo_eip+0x220>
		return -1;
f0101872:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101877:	eb 05                	jmp    f010187e <debuginfo_eip+0x220>
	return 0;
f0101879:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010187e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101881:	5b                   	pop    %ebx
f0101882:	5e                   	pop    %esi
f0101883:	5f                   	pop    %edi
f0101884:	5d                   	pop    %ebp
f0101885:	c3                   	ret    
	return 0;
f0101886:	b8 00 00 00 00       	mov    $0x0,%eax
f010188b:	eb f1                	jmp    f010187e <debuginfo_eip+0x220>

f010188d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010188d:	55                   	push   %ebp
f010188e:	89 e5                	mov    %esp,%ebp
f0101890:	57                   	push   %edi
f0101891:	56                   	push   %esi
f0101892:	53                   	push   %ebx
f0101893:	83 ec 1c             	sub    $0x1c,%esp
f0101896:	89 c7                	mov    %eax,%edi
f0101898:	89 d6                	mov    %edx,%esi
f010189a:	8b 45 08             	mov    0x8(%ebp),%eax
f010189d:	8b 55 0c             	mov    0xc(%ebp),%edx
f01018a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01018a3:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01018a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01018a9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01018ae:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01018b1:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01018b4:	39 d3                	cmp    %edx,%ebx
f01018b6:	72 05                	jb     f01018bd <printnum+0x30>
f01018b8:	39 45 10             	cmp    %eax,0x10(%ebp)
f01018bb:	77 78                	ja     f0101935 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01018bd:	83 ec 0c             	sub    $0xc,%esp
f01018c0:	ff 75 18             	pushl  0x18(%ebp)
f01018c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01018c6:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01018c9:	53                   	push   %ebx
f01018ca:	ff 75 10             	pushl  0x10(%ebp)
f01018cd:	83 ec 08             	sub    $0x8,%esp
f01018d0:	ff 75 e4             	pushl  -0x1c(%ebp)
f01018d3:	ff 75 e0             	pushl  -0x20(%ebp)
f01018d6:	ff 75 dc             	pushl  -0x24(%ebp)
f01018d9:	ff 75 d8             	pushl  -0x28(%ebp)
f01018dc:	e8 8f 09 00 00       	call   f0102270 <__udivdi3>
f01018e1:	83 c4 18             	add    $0x18,%esp
f01018e4:	52                   	push   %edx
f01018e5:	50                   	push   %eax
f01018e6:	89 f2                	mov    %esi,%edx
f01018e8:	89 f8                	mov    %edi,%eax
f01018ea:	e8 9e ff ff ff       	call   f010188d <printnum>
f01018ef:	83 c4 20             	add    $0x20,%esp
f01018f2:	eb 11                	jmp    f0101905 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01018f4:	83 ec 08             	sub    $0x8,%esp
f01018f7:	56                   	push   %esi
f01018f8:	ff 75 18             	pushl  0x18(%ebp)
f01018fb:	ff d7                	call   *%edi
f01018fd:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0101900:	4b                   	dec    %ebx
f0101901:	85 db                	test   %ebx,%ebx
f0101903:	7f ef                	jg     f01018f4 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0101905:	83 ec 08             	sub    $0x8,%esp
f0101908:	56                   	push   %esi
f0101909:	83 ec 04             	sub    $0x4,%esp
f010190c:	ff 75 e4             	pushl  -0x1c(%ebp)
f010190f:	ff 75 e0             	pushl  -0x20(%ebp)
f0101912:	ff 75 dc             	pushl  -0x24(%ebp)
f0101915:	ff 75 d8             	pushl  -0x28(%ebp)
f0101918:	e8 53 0a 00 00       	call   f0102370 <__umoddi3>
f010191d:	83 c4 14             	add    $0x14,%esp
f0101920:	0f be 80 7a 2e 10 f0 	movsbl -0xfefd186(%eax),%eax
f0101927:	50                   	push   %eax
f0101928:	ff d7                	call   *%edi
}
f010192a:	83 c4 10             	add    $0x10,%esp
f010192d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101930:	5b                   	pop    %ebx
f0101931:	5e                   	pop    %esi
f0101932:	5f                   	pop    %edi
f0101933:	5d                   	pop    %ebp
f0101934:	c3                   	ret    
f0101935:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0101938:	eb c6                	jmp    f0101900 <printnum+0x73>

f010193a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010193a:	55                   	push   %ebp
f010193b:	89 e5                	mov    %esp,%ebp
f010193d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0101940:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0101943:	8b 10                	mov    (%eax),%edx
f0101945:	3b 50 04             	cmp    0x4(%eax),%edx
f0101948:	73 0a                	jae    f0101954 <sprintputch+0x1a>
		*b->buf++ = ch;
f010194a:	8d 4a 01             	lea    0x1(%edx),%ecx
f010194d:	89 08                	mov    %ecx,(%eax)
f010194f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101952:	88 02                	mov    %al,(%edx)
}
f0101954:	5d                   	pop    %ebp
f0101955:	c3                   	ret    

f0101956 <printfmt>:
{
f0101956:	55                   	push   %ebp
f0101957:	89 e5                	mov    %esp,%ebp
f0101959:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f010195c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010195f:	50                   	push   %eax
f0101960:	ff 75 10             	pushl  0x10(%ebp)
f0101963:	ff 75 0c             	pushl  0xc(%ebp)
f0101966:	ff 75 08             	pushl  0x8(%ebp)
f0101969:	e8 05 00 00 00       	call   f0101973 <vprintfmt>
}
f010196e:	83 c4 10             	add    $0x10,%esp
f0101971:	c9                   	leave  
f0101972:	c3                   	ret    

f0101973 <vprintfmt>:
{
f0101973:	55                   	push   %ebp
f0101974:	89 e5                	mov    %esp,%ebp
f0101976:	57                   	push   %edi
f0101977:	56                   	push   %esi
f0101978:	53                   	push   %ebx
f0101979:	83 ec 2c             	sub    $0x2c,%esp
f010197c:	8b 75 08             	mov    0x8(%ebp),%esi
f010197f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101982:	8b 7d 10             	mov    0x10(%ebp),%edi
f0101985:	e9 ac 03 00 00       	jmp    f0101d36 <vprintfmt+0x3c3>
		padc = ' ';
f010198a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f010198e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0101995:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f010199c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f01019a3:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01019a8:	8d 47 01             	lea    0x1(%edi),%eax
f01019ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01019ae:	8a 17                	mov    (%edi),%dl
f01019b0:	8d 42 dd             	lea    -0x23(%edx),%eax
f01019b3:	3c 55                	cmp    $0x55,%al
f01019b5:	0f 87 fc 03 00 00    	ja     f0101db7 <vprintfmt+0x444>
f01019bb:	0f b6 c0             	movzbl %al,%eax
f01019be:	ff 24 85 04 2f 10 f0 	jmp    *-0xfefd0fc(,%eax,4)
f01019c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f01019c8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f01019cc:	eb da                	jmp    f01019a8 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f01019ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f01019d1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f01019d5:	eb d1                	jmp    f01019a8 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f01019d7:	0f b6 d2             	movzbl %dl,%edx
f01019da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f01019dd:	b8 00 00 00 00       	mov    $0x0,%eax
f01019e2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f01019e5:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01019e8:	01 c0                	add    %eax,%eax
f01019ea:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
f01019ee:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f01019f1:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01019f4:	83 f9 09             	cmp    $0x9,%ecx
f01019f7:	77 52                	ja     f0101a4b <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
f01019f9:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
f01019fa:	eb e9                	jmp    f01019e5 <vprintfmt+0x72>
			precision = va_arg(ap, int);
f01019fc:	8b 45 14             	mov    0x14(%ebp),%eax
f01019ff:	8b 00                	mov    (%eax),%eax
f0101a01:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101a04:	8b 45 14             	mov    0x14(%ebp),%eax
f0101a07:	8d 40 04             	lea    0x4(%eax),%eax
f0101a0a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101a0d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0101a10:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101a14:	79 92                	jns    f01019a8 <vprintfmt+0x35>
				width = precision, precision = -1;
f0101a16:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101a19:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101a1c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0101a23:	eb 83                	jmp    f01019a8 <vprintfmt+0x35>
f0101a25:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101a29:	78 08                	js     f0101a33 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
f0101a2b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101a2e:	e9 75 ff ff ff       	jmp    f01019a8 <vprintfmt+0x35>
f0101a33:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0101a3a:	eb ef                	jmp    f0101a2b <vprintfmt+0xb8>
f0101a3c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0101a3f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0101a46:	e9 5d ff ff ff       	jmp    f01019a8 <vprintfmt+0x35>
f0101a4b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101a4e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101a51:	eb bd                	jmp    f0101a10 <vprintfmt+0x9d>
			lflag++;
f0101a53:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
f0101a54:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0101a57:	e9 4c ff ff ff       	jmp    f01019a8 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f0101a5c:	8b 45 14             	mov    0x14(%ebp),%eax
f0101a5f:	8d 78 04             	lea    0x4(%eax),%edi
f0101a62:	83 ec 08             	sub    $0x8,%esp
f0101a65:	53                   	push   %ebx
f0101a66:	ff 30                	pushl  (%eax)
f0101a68:	ff d6                	call   *%esi
			break;
f0101a6a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0101a6d:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0101a70:	e9 be 02 00 00       	jmp    f0101d33 <vprintfmt+0x3c0>
			err = va_arg(ap, int);
f0101a75:	8b 45 14             	mov    0x14(%ebp),%eax
f0101a78:	8d 78 04             	lea    0x4(%eax),%edi
f0101a7b:	8b 00                	mov    (%eax),%eax
f0101a7d:	85 c0                	test   %eax,%eax
f0101a7f:	78 2a                	js     f0101aab <vprintfmt+0x138>
f0101a81:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101a83:	83 f8 06             	cmp    $0x6,%eax
f0101a86:	7f 27                	jg     f0101aaf <vprintfmt+0x13c>
f0101a88:	8b 04 85 5c 30 10 f0 	mov    -0xfefcfa4(,%eax,4),%eax
f0101a8f:	85 c0                	test   %eax,%eax
f0101a91:	74 1c                	je     f0101aaf <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
f0101a93:	50                   	push   %eax
f0101a94:	68 bf 2c 10 f0       	push   $0xf0102cbf
f0101a99:	53                   	push   %ebx
f0101a9a:	56                   	push   %esi
f0101a9b:	e8 b6 fe ff ff       	call   f0101956 <printfmt>
f0101aa0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0101aa3:	89 7d 14             	mov    %edi,0x14(%ebp)
f0101aa6:	e9 88 02 00 00       	jmp    f0101d33 <vprintfmt+0x3c0>
f0101aab:	f7 d8                	neg    %eax
f0101aad:	eb d2                	jmp    f0101a81 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
f0101aaf:	52                   	push   %edx
f0101ab0:	68 92 2e 10 f0       	push   $0xf0102e92
f0101ab5:	53                   	push   %ebx
f0101ab6:	56                   	push   %esi
f0101ab7:	e8 9a fe ff ff       	call   f0101956 <printfmt>
f0101abc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0101abf:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0101ac2:	e9 6c 02 00 00       	jmp    f0101d33 <vprintfmt+0x3c0>
			if ((p = va_arg(ap, char *)) == NULL)
f0101ac7:	8b 45 14             	mov    0x14(%ebp),%eax
f0101aca:	83 c0 04             	add    $0x4,%eax
f0101acd:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101ad0:	8b 45 14             	mov    0x14(%ebp),%eax
f0101ad3:	8b 38                	mov    (%eax),%edi
f0101ad5:	85 ff                	test   %edi,%edi
f0101ad7:	74 18                	je     f0101af1 <vprintfmt+0x17e>
			if (width > 0 && padc != '-')
f0101ad9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101add:	0f 8e b7 00 00 00    	jle    f0101b9a <vprintfmt+0x227>
f0101ae3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0101ae7:	75 0f                	jne    f0101af8 <vprintfmt+0x185>
f0101ae9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101aec:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0101aef:	eb 6e                	jmp    f0101b5f <vprintfmt+0x1ec>
				p = "(null)";
f0101af1:	bf 8b 2e 10 f0       	mov    $0xf0102e8b,%edi
f0101af6:	eb e1                	jmp    f0101ad9 <vprintfmt+0x166>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101af8:	83 ec 08             	sub    $0x8,%esp
f0101afb:	ff 75 d0             	pushl  -0x30(%ebp)
f0101afe:	57                   	push   %edi
f0101aff:	e8 45 04 00 00       	call   f0101f49 <strnlen>
f0101b04:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101b07:	29 c1                	sub    %eax,%ecx
f0101b09:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0101b0c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0101b0f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0101b13:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101b16:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101b19:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0101b1b:	eb 0d                	jmp    f0101b2a <vprintfmt+0x1b7>
					putch(padc, putdat);
f0101b1d:	83 ec 08             	sub    $0x8,%esp
f0101b20:	53                   	push   %ebx
f0101b21:	ff 75 e0             	pushl  -0x20(%ebp)
f0101b24:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0101b26:	4f                   	dec    %edi
f0101b27:	83 c4 10             	add    $0x10,%esp
f0101b2a:	85 ff                	test   %edi,%edi
f0101b2c:	7f ef                	jg     f0101b1d <vprintfmt+0x1aa>
f0101b2e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101b31:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101b34:	89 c8                	mov    %ecx,%eax
f0101b36:	85 c9                	test   %ecx,%ecx
f0101b38:	78 59                	js     f0101b93 <vprintfmt+0x220>
f0101b3a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101b3d:	29 c1                	sub    %eax,%ecx
f0101b3f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0101b42:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101b45:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0101b48:	eb 15                	jmp    f0101b5f <vprintfmt+0x1ec>
				if (altflag && (ch < ' ' || ch > '~'))
f0101b4a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0101b4e:	75 29                	jne    f0101b79 <vprintfmt+0x206>
					putch(ch, putdat);
f0101b50:	83 ec 08             	sub    $0x8,%esp
f0101b53:	ff 75 0c             	pushl  0xc(%ebp)
f0101b56:	50                   	push   %eax
f0101b57:	ff d6                	call   *%esi
f0101b59:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101b5c:	ff 4d e0             	decl   -0x20(%ebp)
f0101b5f:	47                   	inc    %edi
f0101b60:	8a 57 ff             	mov    -0x1(%edi),%dl
f0101b63:	0f be c2             	movsbl %dl,%eax
f0101b66:	85 c0                	test   %eax,%eax
f0101b68:	74 53                	je     f0101bbd <vprintfmt+0x24a>
f0101b6a:	85 db                	test   %ebx,%ebx
f0101b6c:	78 dc                	js     f0101b4a <vprintfmt+0x1d7>
f0101b6e:	4b                   	dec    %ebx
f0101b6f:	79 d9                	jns    f0101b4a <vprintfmt+0x1d7>
f0101b71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101b74:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0101b77:	eb 35                	jmp    f0101bae <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
f0101b79:	0f be d2             	movsbl %dl,%edx
f0101b7c:	83 ea 20             	sub    $0x20,%edx
f0101b7f:	83 fa 5e             	cmp    $0x5e,%edx
f0101b82:	76 cc                	jbe    f0101b50 <vprintfmt+0x1dd>
					putch('?', putdat);
f0101b84:	83 ec 08             	sub    $0x8,%esp
f0101b87:	ff 75 0c             	pushl  0xc(%ebp)
f0101b8a:	6a 3f                	push   $0x3f
f0101b8c:	ff d6                	call   *%esi
f0101b8e:	83 c4 10             	add    $0x10,%esp
f0101b91:	eb c9                	jmp    f0101b5c <vprintfmt+0x1e9>
f0101b93:	b8 00 00 00 00       	mov    $0x0,%eax
f0101b98:	eb a0                	jmp    f0101b3a <vprintfmt+0x1c7>
f0101b9a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101b9d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0101ba0:	eb bd                	jmp    f0101b5f <vprintfmt+0x1ec>
				putch(' ', putdat);
f0101ba2:	83 ec 08             	sub    $0x8,%esp
f0101ba5:	53                   	push   %ebx
f0101ba6:	6a 20                	push   $0x20
f0101ba8:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0101baa:	4f                   	dec    %edi
f0101bab:	83 c4 10             	add    $0x10,%esp
f0101bae:	85 ff                	test   %edi,%edi
f0101bb0:	7f f0                	jg     f0101ba2 <vprintfmt+0x22f>
			if ((p = va_arg(ap, char *)) == NULL)
f0101bb2:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101bb5:	89 45 14             	mov    %eax,0x14(%ebp)
f0101bb8:	e9 76 01 00 00       	jmp    f0101d33 <vprintfmt+0x3c0>
f0101bbd:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0101bc0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101bc3:	eb e9                	jmp    f0101bae <vprintfmt+0x23b>
	if (lflag >= 2)
f0101bc5:	83 f9 01             	cmp    $0x1,%ecx
f0101bc8:	7e 3f                	jle    f0101c09 <vprintfmt+0x296>
		return va_arg(*ap, long long);
f0101bca:	8b 45 14             	mov    0x14(%ebp),%eax
f0101bcd:	8b 50 04             	mov    0x4(%eax),%edx
f0101bd0:	8b 00                	mov    (%eax),%eax
f0101bd2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101bd5:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101bd8:	8b 45 14             	mov    0x14(%ebp),%eax
f0101bdb:	8d 40 08             	lea    0x8(%eax),%eax
f0101bde:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0101be1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101be5:	79 5c                	jns    f0101c43 <vprintfmt+0x2d0>
				putch('-', putdat);
f0101be7:	83 ec 08             	sub    $0x8,%esp
f0101bea:	53                   	push   %ebx
f0101beb:	6a 2d                	push   $0x2d
f0101bed:	ff d6                	call   *%esi
				num = -(long long) num;
f0101bef:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101bf2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101bf5:	f7 da                	neg    %edx
f0101bf7:	83 d1 00             	adc    $0x0,%ecx
f0101bfa:	f7 d9                	neg    %ecx
f0101bfc:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0101bff:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101c04:	e9 10 01 00 00       	jmp    f0101d19 <vprintfmt+0x3a6>
	else if (lflag)
f0101c09:	85 c9                	test   %ecx,%ecx
f0101c0b:	75 1b                	jne    f0101c28 <vprintfmt+0x2b5>
		return va_arg(*ap, int);
f0101c0d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101c10:	8b 00                	mov    (%eax),%eax
f0101c12:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101c15:	89 c1                	mov    %eax,%ecx
f0101c17:	c1 f9 1f             	sar    $0x1f,%ecx
f0101c1a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101c1d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101c20:	8d 40 04             	lea    0x4(%eax),%eax
f0101c23:	89 45 14             	mov    %eax,0x14(%ebp)
f0101c26:	eb b9                	jmp    f0101be1 <vprintfmt+0x26e>
		return va_arg(*ap, long);
f0101c28:	8b 45 14             	mov    0x14(%ebp),%eax
f0101c2b:	8b 00                	mov    (%eax),%eax
f0101c2d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101c30:	89 c1                	mov    %eax,%ecx
f0101c32:	c1 f9 1f             	sar    $0x1f,%ecx
f0101c35:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101c38:	8b 45 14             	mov    0x14(%ebp),%eax
f0101c3b:	8d 40 04             	lea    0x4(%eax),%eax
f0101c3e:	89 45 14             	mov    %eax,0x14(%ebp)
f0101c41:	eb 9e                	jmp    f0101be1 <vprintfmt+0x26e>
			num = getint(&ap, lflag);
f0101c43:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101c46:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0101c49:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101c4e:	e9 c6 00 00 00       	jmp    f0101d19 <vprintfmt+0x3a6>
	if (lflag >= 2)
f0101c53:	83 f9 01             	cmp    $0x1,%ecx
f0101c56:	7e 18                	jle    f0101c70 <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
f0101c58:	8b 45 14             	mov    0x14(%ebp),%eax
f0101c5b:	8b 10                	mov    (%eax),%edx
f0101c5d:	8b 48 04             	mov    0x4(%eax),%ecx
f0101c60:	8d 40 08             	lea    0x8(%eax),%eax
f0101c63:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101c66:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101c6b:	e9 a9 00 00 00       	jmp    f0101d19 <vprintfmt+0x3a6>
	else if (lflag)
f0101c70:	85 c9                	test   %ecx,%ecx
f0101c72:	75 1a                	jne    f0101c8e <vprintfmt+0x31b>
		return va_arg(*ap, unsigned int);
f0101c74:	8b 45 14             	mov    0x14(%ebp),%eax
f0101c77:	8b 10                	mov    (%eax),%edx
f0101c79:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101c7e:	8d 40 04             	lea    0x4(%eax),%eax
f0101c81:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101c84:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101c89:	e9 8b 00 00 00       	jmp    f0101d19 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0101c8e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101c91:	8b 10                	mov    (%eax),%edx
f0101c93:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101c98:	8d 40 04             	lea    0x4(%eax),%eax
f0101c9b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101c9e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101ca3:	eb 74                	jmp    f0101d19 <vprintfmt+0x3a6>
	if (lflag >= 2)
f0101ca5:	83 f9 01             	cmp    $0x1,%ecx
f0101ca8:	7e 15                	jle    f0101cbf <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
f0101caa:	8b 45 14             	mov    0x14(%ebp),%eax
f0101cad:	8b 10                	mov    (%eax),%edx
f0101caf:	8b 48 04             	mov    0x4(%eax),%ecx
f0101cb2:	8d 40 08             	lea    0x8(%eax),%eax
f0101cb5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101cb8:	b8 08 00 00 00       	mov    $0x8,%eax
f0101cbd:	eb 5a                	jmp    f0101d19 <vprintfmt+0x3a6>
	else if (lflag)
f0101cbf:	85 c9                	test   %ecx,%ecx
f0101cc1:	75 17                	jne    f0101cda <vprintfmt+0x367>
		return va_arg(*ap, unsigned int);
f0101cc3:	8b 45 14             	mov    0x14(%ebp),%eax
f0101cc6:	8b 10                	mov    (%eax),%edx
f0101cc8:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101ccd:	8d 40 04             	lea    0x4(%eax),%eax
f0101cd0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101cd3:	b8 08 00 00 00       	mov    $0x8,%eax
f0101cd8:	eb 3f                	jmp    f0101d19 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0101cda:	8b 45 14             	mov    0x14(%ebp),%eax
f0101cdd:	8b 10                	mov    (%eax),%edx
f0101cdf:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101ce4:	8d 40 04             	lea    0x4(%eax),%eax
f0101ce7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101cea:	b8 08 00 00 00       	mov    $0x8,%eax
f0101cef:	eb 28                	jmp    f0101d19 <vprintfmt+0x3a6>
			putch('0', putdat);
f0101cf1:	83 ec 08             	sub    $0x8,%esp
f0101cf4:	53                   	push   %ebx
f0101cf5:	6a 30                	push   $0x30
f0101cf7:	ff d6                	call   *%esi
			putch('x', putdat);
f0101cf9:	83 c4 08             	add    $0x8,%esp
f0101cfc:	53                   	push   %ebx
f0101cfd:	6a 78                	push   $0x78
f0101cff:	ff d6                	call   *%esi
			num = (unsigned long long)
f0101d01:	8b 45 14             	mov    0x14(%ebp),%eax
f0101d04:	8b 10                	mov    (%eax),%edx
f0101d06:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0101d0b:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0101d0e:	8d 40 04             	lea    0x4(%eax),%eax
f0101d11:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101d14:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0101d19:	83 ec 0c             	sub    $0xc,%esp
f0101d1c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0101d20:	57                   	push   %edi
f0101d21:	ff 75 e0             	pushl  -0x20(%ebp)
f0101d24:	50                   	push   %eax
f0101d25:	51                   	push   %ecx
f0101d26:	52                   	push   %edx
f0101d27:	89 da                	mov    %ebx,%edx
f0101d29:	89 f0                	mov    %esi,%eax
f0101d2b:	e8 5d fb ff ff       	call   f010188d <printnum>
			break;
f0101d30:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0101d33:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101d36:	47                   	inc    %edi
f0101d37:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101d3b:	83 f8 25             	cmp    $0x25,%eax
f0101d3e:	0f 84 46 fc ff ff    	je     f010198a <vprintfmt+0x17>
			if (ch == '\0')
f0101d44:	85 c0                	test   %eax,%eax
f0101d46:	0f 84 89 00 00 00    	je     f0101dd5 <vprintfmt+0x462>
			putch(ch, putdat);
f0101d4c:	83 ec 08             	sub    $0x8,%esp
f0101d4f:	53                   	push   %ebx
f0101d50:	50                   	push   %eax
f0101d51:	ff d6                	call   *%esi
f0101d53:	83 c4 10             	add    $0x10,%esp
f0101d56:	eb de                	jmp    f0101d36 <vprintfmt+0x3c3>
	if (lflag >= 2)
f0101d58:	83 f9 01             	cmp    $0x1,%ecx
f0101d5b:	7e 15                	jle    f0101d72 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
f0101d5d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101d60:	8b 10                	mov    (%eax),%edx
f0101d62:	8b 48 04             	mov    0x4(%eax),%ecx
f0101d65:	8d 40 08             	lea    0x8(%eax),%eax
f0101d68:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101d6b:	b8 10 00 00 00       	mov    $0x10,%eax
f0101d70:	eb a7                	jmp    f0101d19 <vprintfmt+0x3a6>
	else if (lflag)
f0101d72:	85 c9                	test   %ecx,%ecx
f0101d74:	75 17                	jne    f0101d8d <vprintfmt+0x41a>
		return va_arg(*ap, unsigned int);
f0101d76:	8b 45 14             	mov    0x14(%ebp),%eax
f0101d79:	8b 10                	mov    (%eax),%edx
f0101d7b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101d80:	8d 40 04             	lea    0x4(%eax),%eax
f0101d83:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101d86:	b8 10 00 00 00       	mov    $0x10,%eax
f0101d8b:	eb 8c                	jmp    f0101d19 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0101d8d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101d90:	8b 10                	mov    (%eax),%edx
f0101d92:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101d97:	8d 40 04             	lea    0x4(%eax),%eax
f0101d9a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101d9d:	b8 10 00 00 00       	mov    $0x10,%eax
f0101da2:	e9 72 ff ff ff       	jmp    f0101d19 <vprintfmt+0x3a6>
			putch(ch, putdat);
f0101da7:	83 ec 08             	sub    $0x8,%esp
f0101daa:	53                   	push   %ebx
f0101dab:	6a 25                	push   $0x25
f0101dad:	ff d6                	call   *%esi
			break;
f0101daf:	83 c4 10             	add    $0x10,%esp
f0101db2:	e9 7c ff ff ff       	jmp    f0101d33 <vprintfmt+0x3c0>
			putch('%', putdat);
f0101db7:	83 ec 08             	sub    $0x8,%esp
f0101dba:	53                   	push   %ebx
f0101dbb:	6a 25                	push   $0x25
f0101dbd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101dbf:	83 c4 10             	add    $0x10,%esp
f0101dc2:	89 f8                	mov    %edi,%eax
f0101dc4:	eb 01                	jmp    f0101dc7 <vprintfmt+0x454>
f0101dc6:	48                   	dec    %eax
f0101dc7:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0101dcb:	75 f9                	jne    f0101dc6 <vprintfmt+0x453>
f0101dcd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101dd0:	e9 5e ff ff ff       	jmp    f0101d33 <vprintfmt+0x3c0>
}
f0101dd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101dd8:	5b                   	pop    %ebx
f0101dd9:	5e                   	pop    %esi
f0101dda:	5f                   	pop    %edi
f0101ddb:	5d                   	pop    %ebp
f0101ddc:	c3                   	ret    

f0101ddd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101ddd:	55                   	push   %ebp
f0101dde:	89 e5                	mov    %esp,%ebp
f0101de0:	83 ec 18             	sub    $0x18,%esp
f0101de3:	8b 45 08             	mov    0x8(%ebp),%eax
f0101de6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101de9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101dec:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101df0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101df3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101dfa:	85 c0                	test   %eax,%eax
f0101dfc:	74 26                	je     f0101e24 <vsnprintf+0x47>
f0101dfe:	85 d2                	test   %edx,%edx
f0101e00:	7e 29                	jle    f0101e2b <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101e02:	ff 75 14             	pushl  0x14(%ebp)
f0101e05:	ff 75 10             	pushl  0x10(%ebp)
f0101e08:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101e0b:	50                   	push   %eax
f0101e0c:	68 3a 19 10 f0       	push   $0xf010193a
f0101e11:	e8 5d fb ff ff       	call   f0101973 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101e16:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101e19:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101e1f:	83 c4 10             	add    $0x10,%esp
}
f0101e22:	c9                   	leave  
f0101e23:	c3                   	ret    
		return -E_INVAL;
f0101e24:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101e29:	eb f7                	jmp    f0101e22 <vsnprintf+0x45>
f0101e2b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101e30:	eb f0                	jmp    f0101e22 <vsnprintf+0x45>

f0101e32 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101e32:	55                   	push   %ebp
f0101e33:	89 e5                	mov    %esp,%ebp
f0101e35:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101e38:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101e3b:	50                   	push   %eax
f0101e3c:	ff 75 10             	pushl  0x10(%ebp)
f0101e3f:	ff 75 0c             	pushl  0xc(%ebp)
f0101e42:	ff 75 08             	pushl  0x8(%ebp)
f0101e45:	e8 93 ff ff ff       	call   f0101ddd <vsnprintf>
	va_end(ap);

	return rc;
}
f0101e4a:	c9                   	leave  
f0101e4b:	c3                   	ret    

f0101e4c <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101e4c:	55                   	push   %ebp
f0101e4d:	89 e5                	mov    %esp,%ebp
f0101e4f:	57                   	push   %edi
f0101e50:	56                   	push   %esi
f0101e51:	53                   	push   %ebx
f0101e52:	83 ec 0c             	sub    $0xc,%esp
f0101e55:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101e58:	85 c0                	test   %eax,%eax
f0101e5a:	74 11                	je     f0101e6d <readline+0x21>
		cprintf("%s", prompt);
f0101e5c:	83 ec 08             	sub    $0x8,%esp
f0101e5f:	50                   	push   %eax
f0101e60:	68 bf 2c 10 f0       	push   $0xf0102cbf
f0101e65:	e8 f3 f6 ff ff       	call   f010155d <cprintf>
f0101e6a:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101e6d:	83 ec 0c             	sub    $0xc,%esp
f0101e70:	6a 00                	push   $0x0
f0101e72:	e8 30 e8 ff ff       	call   f01006a7 <iscons>
f0101e77:	89 c7                	mov    %eax,%edi
f0101e79:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0101e7c:	be 00 00 00 00       	mov    $0x0,%esi
f0101e81:	eb 6f                	jmp    f0101ef2 <readline+0xa6>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0101e83:	83 ec 08             	sub    $0x8,%esp
f0101e86:	50                   	push   %eax
f0101e87:	68 78 30 10 f0       	push   $0xf0103078
f0101e8c:	e8 cc f6 ff ff       	call   f010155d <cprintf>
			return NULL;
f0101e91:	83 c4 10             	add    $0x10,%esp
f0101e94:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0101e99:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101e9c:	5b                   	pop    %ebx
f0101e9d:	5e                   	pop    %esi
f0101e9e:	5f                   	pop    %edi
f0101e9f:	5d                   	pop    %ebp
f0101ea0:	c3                   	ret    
				cputchar('\b');
f0101ea1:	83 ec 0c             	sub    $0xc,%esp
f0101ea4:	6a 08                	push   $0x8
f0101ea6:	e8 db e7 ff ff       	call   f0100686 <cputchar>
f0101eab:	83 c4 10             	add    $0x10,%esp
f0101eae:	eb 41                	jmp    f0101ef1 <readline+0xa5>
				cputchar(c);
f0101eb0:	83 ec 0c             	sub    $0xc,%esp
f0101eb3:	53                   	push   %ebx
f0101eb4:	e8 cd e7 ff ff       	call   f0100686 <cputchar>
f0101eb9:	83 c4 10             	add    $0x10,%esp
f0101ebc:	eb 5a                	jmp    f0101f18 <readline+0xcc>
		} else if (c == '\n' || c == '\r') {
f0101ebe:	83 fb 0a             	cmp    $0xa,%ebx
f0101ec1:	74 05                	je     f0101ec8 <readline+0x7c>
f0101ec3:	83 fb 0d             	cmp    $0xd,%ebx
f0101ec6:	75 2a                	jne    f0101ef2 <readline+0xa6>
			if (echoing)
f0101ec8:	85 ff                	test   %edi,%edi
f0101eca:	75 0e                	jne    f0101eda <readline+0x8e>
			buf[i] = 0;
f0101ecc:	c6 86 60 55 11 f0 00 	movb   $0x0,-0xfeeaaa0(%esi)
			return buf;
f0101ed3:	b8 60 55 11 f0       	mov    $0xf0115560,%eax
f0101ed8:	eb bf                	jmp    f0101e99 <readline+0x4d>
				cputchar('\n');
f0101eda:	83 ec 0c             	sub    $0xc,%esp
f0101edd:	6a 0a                	push   $0xa
f0101edf:	e8 a2 e7 ff ff       	call   f0100686 <cputchar>
f0101ee4:	83 c4 10             	add    $0x10,%esp
f0101ee7:	eb e3                	jmp    f0101ecc <readline+0x80>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101ee9:	85 f6                	test   %esi,%esi
f0101eeb:	7e 3c                	jle    f0101f29 <readline+0xdd>
			if (echoing)
f0101eed:	85 ff                	test   %edi,%edi
f0101eef:	75 b0                	jne    f0101ea1 <readline+0x55>
			i--;
f0101ef1:	4e                   	dec    %esi
		c = getchar();
f0101ef2:	e8 9f e7 ff ff       	call   f0100696 <getchar>
f0101ef7:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0101ef9:	85 c0                	test   %eax,%eax
f0101efb:	78 86                	js     f0101e83 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101efd:	83 f8 08             	cmp    $0x8,%eax
f0101f00:	74 21                	je     f0101f23 <readline+0xd7>
f0101f02:	83 f8 7f             	cmp    $0x7f,%eax
f0101f05:	74 e2                	je     f0101ee9 <readline+0x9d>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101f07:	83 f8 1f             	cmp    $0x1f,%eax
f0101f0a:	7e b2                	jle    f0101ebe <readline+0x72>
f0101f0c:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101f12:	7f aa                	jg     f0101ebe <readline+0x72>
			if (echoing)
f0101f14:	85 ff                	test   %edi,%edi
f0101f16:	75 98                	jne    f0101eb0 <readline+0x64>
			buf[i++] = c;
f0101f18:	88 9e 60 55 11 f0    	mov    %bl,-0xfeeaaa0(%esi)
f0101f1e:	8d 76 01             	lea    0x1(%esi),%esi
f0101f21:	eb cf                	jmp    f0101ef2 <readline+0xa6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101f23:	85 f6                	test   %esi,%esi
f0101f25:	7e cb                	jle    f0101ef2 <readline+0xa6>
f0101f27:	eb c4                	jmp    f0101eed <readline+0xa1>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101f29:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101f2f:	7e e3                	jle    f0101f14 <readline+0xc8>
f0101f31:	eb bf                	jmp    f0101ef2 <readline+0xa6>

f0101f33 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101f33:	55                   	push   %ebp
f0101f34:	89 e5                	mov    %esp,%ebp
f0101f36:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101f39:	b8 00 00 00 00       	mov    $0x0,%eax
f0101f3e:	eb 01                	jmp    f0101f41 <strlen+0xe>
		n++;
f0101f40:	40                   	inc    %eax
	for (n = 0; *s != '\0'; s++)
f0101f41:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101f45:	75 f9                	jne    f0101f40 <strlen+0xd>
	return n;
}
f0101f47:	5d                   	pop    %ebp
f0101f48:	c3                   	ret    

f0101f49 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101f49:	55                   	push   %ebp
f0101f4a:	89 e5                	mov    %esp,%ebp
f0101f4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101f4f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101f52:	b8 00 00 00 00       	mov    $0x0,%eax
f0101f57:	eb 01                	jmp    f0101f5a <strnlen+0x11>
		n++;
f0101f59:	40                   	inc    %eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101f5a:	39 d0                	cmp    %edx,%eax
f0101f5c:	74 06                	je     f0101f64 <strnlen+0x1b>
f0101f5e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0101f62:	75 f5                	jne    f0101f59 <strnlen+0x10>
	return n;
}
f0101f64:	5d                   	pop    %ebp
f0101f65:	c3                   	ret    

f0101f66 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101f66:	55                   	push   %ebp
f0101f67:	89 e5                	mov    %esp,%ebp
f0101f69:	53                   	push   %ebx
f0101f6a:	8b 45 08             	mov    0x8(%ebp),%eax
f0101f6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101f70:	89 c2                	mov    %eax,%edx
f0101f72:	41                   	inc    %ecx
f0101f73:	42                   	inc    %edx
f0101f74:	8a 59 ff             	mov    -0x1(%ecx),%bl
f0101f77:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101f7a:	84 db                	test   %bl,%bl
f0101f7c:	75 f4                	jne    f0101f72 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101f7e:	5b                   	pop    %ebx
f0101f7f:	5d                   	pop    %ebp
f0101f80:	c3                   	ret    

f0101f81 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101f81:	55                   	push   %ebp
f0101f82:	89 e5                	mov    %esp,%ebp
f0101f84:	53                   	push   %ebx
f0101f85:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101f88:	53                   	push   %ebx
f0101f89:	e8 a5 ff ff ff       	call   f0101f33 <strlen>
f0101f8e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0101f91:	ff 75 0c             	pushl  0xc(%ebp)
f0101f94:	01 d8                	add    %ebx,%eax
f0101f96:	50                   	push   %eax
f0101f97:	e8 ca ff ff ff       	call   f0101f66 <strcpy>
	return dst;
}
f0101f9c:	89 d8                	mov    %ebx,%eax
f0101f9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101fa1:	c9                   	leave  
f0101fa2:	c3                   	ret    

f0101fa3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101fa3:	55                   	push   %ebp
f0101fa4:	89 e5                	mov    %esp,%ebp
f0101fa6:	56                   	push   %esi
f0101fa7:	53                   	push   %ebx
f0101fa8:	8b 75 08             	mov    0x8(%ebp),%esi
f0101fab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101fae:	89 f3                	mov    %esi,%ebx
f0101fb0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101fb3:	89 f2                	mov    %esi,%edx
f0101fb5:	39 da                	cmp    %ebx,%edx
f0101fb7:	74 0e                	je     f0101fc7 <strncpy+0x24>
		*dst++ = *src;
f0101fb9:	42                   	inc    %edx
f0101fba:	8a 01                	mov    (%ecx),%al
f0101fbc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f0101fbf:	80 39 00             	cmpb   $0x0,(%ecx)
f0101fc2:	74 f1                	je     f0101fb5 <strncpy+0x12>
			src++;
f0101fc4:	41                   	inc    %ecx
f0101fc5:	eb ee                	jmp    f0101fb5 <strncpy+0x12>
	}
	return ret;
}
f0101fc7:	89 f0                	mov    %esi,%eax
f0101fc9:	5b                   	pop    %ebx
f0101fca:	5e                   	pop    %esi
f0101fcb:	5d                   	pop    %ebp
f0101fcc:	c3                   	ret    

f0101fcd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101fcd:	55                   	push   %ebp
f0101fce:	89 e5                	mov    %esp,%ebp
f0101fd0:	56                   	push   %esi
f0101fd1:	53                   	push   %ebx
f0101fd2:	8b 75 08             	mov    0x8(%ebp),%esi
f0101fd5:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101fd8:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101fdb:	85 c0                	test   %eax,%eax
f0101fdd:	74 20                	je     f0101fff <strlcpy+0x32>
f0101fdf:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
f0101fe3:	89 f0                	mov    %esi,%eax
f0101fe5:	eb 05                	jmp    f0101fec <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101fe7:	42                   	inc    %edx
f0101fe8:	40                   	inc    %eax
f0101fe9:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0101fec:	39 d8                	cmp    %ebx,%eax
f0101fee:	74 06                	je     f0101ff6 <strlcpy+0x29>
f0101ff0:	8a 0a                	mov    (%edx),%cl
f0101ff2:	84 c9                	test   %cl,%cl
f0101ff4:	75 f1                	jne    f0101fe7 <strlcpy+0x1a>
		*dst = '\0';
f0101ff6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101ff9:	29 f0                	sub    %esi,%eax
}
f0101ffb:	5b                   	pop    %ebx
f0101ffc:	5e                   	pop    %esi
f0101ffd:	5d                   	pop    %ebp
f0101ffe:	c3                   	ret    
f0101fff:	89 f0                	mov    %esi,%eax
f0102001:	eb f6                	jmp    f0101ff9 <strlcpy+0x2c>

f0102003 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0102003:	55                   	push   %ebp
f0102004:	89 e5                	mov    %esp,%ebp
f0102006:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0102009:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010200c:	eb 02                	jmp    f0102010 <strcmp+0xd>
		p++, q++;
f010200e:	41                   	inc    %ecx
f010200f:	42                   	inc    %edx
	while (*p && *p == *q)
f0102010:	8a 01                	mov    (%ecx),%al
f0102012:	84 c0                	test   %al,%al
f0102014:	74 04                	je     f010201a <strcmp+0x17>
f0102016:	3a 02                	cmp    (%edx),%al
f0102018:	74 f4                	je     f010200e <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010201a:	0f b6 c0             	movzbl %al,%eax
f010201d:	0f b6 12             	movzbl (%edx),%edx
f0102020:	29 d0                	sub    %edx,%eax
}
f0102022:	5d                   	pop    %ebp
f0102023:	c3                   	ret    

f0102024 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0102024:	55                   	push   %ebp
f0102025:	89 e5                	mov    %esp,%ebp
f0102027:	53                   	push   %ebx
f0102028:	8b 45 08             	mov    0x8(%ebp),%eax
f010202b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010202e:	89 c3                	mov    %eax,%ebx
f0102030:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0102033:	eb 02                	jmp    f0102037 <strncmp+0x13>
		n--, p++, q++;
f0102035:	40                   	inc    %eax
f0102036:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
f0102037:	39 d8                	cmp    %ebx,%eax
f0102039:	74 15                	je     f0102050 <strncmp+0x2c>
f010203b:	8a 08                	mov    (%eax),%cl
f010203d:	84 c9                	test   %cl,%cl
f010203f:	74 04                	je     f0102045 <strncmp+0x21>
f0102041:	3a 0a                	cmp    (%edx),%cl
f0102043:	74 f0                	je     f0102035 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0102045:	0f b6 00             	movzbl (%eax),%eax
f0102048:	0f b6 12             	movzbl (%edx),%edx
f010204b:	29 d0                	sub    %edx,%eax
}
f010204d:	5b                   	pop    %ebx
f010204e:	5d                   	pop    %ebp
f010204f:	c3                   	ret    
		return 0;
f0102050:	b8 00 00 00 00       	mov    $0x0,%eax
f0102055:	eb f6                	jmp    f010204d <strncmp+0x29>

f0102057 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0102057:	55                   	push   %ebp
f0102058:	89 e5                	mov    %esp,%ebp
f010205a:	8b 45 08             	mov    0x8(%ebp),%eax
f010205d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0102060:	8a 10                	mov    (%eax),%dl
f0102062:	84 d2                	test   %dl,%dl
f0102064:	74 07                	je     f010206d <strchr+0x16>
		if (*s == c)
f0102066:	38 ca                	cmp    %cl,%dl
f0102068:	74 08                	je     f0102072 <strchr+0x1b>
	for (; *s; s++)
f010206a:	40                   	inc    %eax
f010206b:	eb f3                	jmp    f0102060 <strchr+0x9>
			return (char *) s;
	return 0;
f010206d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102072:	5d                   	pop    %ebp
f0102073:	c3                   	ret    

f0102074 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0102074:	55                   	push   %ebp
f0102075:	89 e5                	mov    %esp,%ebp
f0102077:	8b 45 08             	mov    0x8(%ebp),%eax
f010207a:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010207d:	8a 10                	mov    (%eax),%dl
f010207f:	84 d2                	test   %dl,%dl
f0102081:	74 07                	je     f010208a <strfind+0x16>
		if (*s == c)
f0102083:	38 ca                	cmp    %cl,%dl
f0102085:	74 03                	je     f010208a <strfind+0x16>
	for (; *s; s++)
f0102087:	40                   	inc    %eax
f0102088:	eb f3                	jmp    f010207d <strfind+0x9>
			break;
	return (char *) s;
}
f010208a:	5d                   	pop    %ebp
f010208b:	c3                   	ret    

f010208c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010208c:	55                   	push   %ebp
f010208d:	89 e5                	mov    %esp,%ebp
f010208f:	57                   	push   %edi
f0102090:	56                   	push   %esi
f0102091:	53                   	push   %ebx
f0102092:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102095:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0102098:	85 c9                	test   %ecx,%ecx
f010209a:	74 13                	je     f01020af <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010209c:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01020a2:	75 05                	jne    f01020a9 <memset+0x1d>
f01020a4:	f6 c1 03             	test   $0x3,%cl
f01020a7:	74 0d                	je     f01020b6 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01020a9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01020ac:	fc                   	cld    
f01020ad:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01020af:	89 f8                	mov    %edi,%eax
f01020b1:	5b                   	pop    %ebx
f01020b2:	5e                   	pop    %esi
f01020b3:	5f                   	pop    %edi
f01020b4:	5d                   	pop    %ebp
f01020b5:	c3                   	ret    
		c &= 0xFF;
f01020b6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01020ba:	89 d3                	mov    %edx,%ebx
f01020bc:	c1 e3 08             	shl    $0x8,%ebx
f01020bf:	89 d0                	mov    %edx,%eax
f01020c1:	c1 e0 18             	shl    $0x18,%eax
f01020c4:	89 d6                	mov    %edx,%esi
f01020c6:	c1 e6 10             	shl    $0x10,%esi
f01020c9:	09 f0                	or     %esi,%eax
f01020cb:	09 c2                	or     %eax,%edx
f01020cd:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f01020cf:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01020d2:	89 d0                	mov    %edx,%eax
f01020d4:	fc                   	cld    
f01020d5:	f3 ab                	rep stos %eax,%es:(%edi)
f01020d7:	eb d6                	jmp    f01020af <memset+0x23>

f01020d9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01020d9:	55                   	push   %ebp
f01020da:	89 e5                	mov    %esp,%ebp
f01020dc:	57                   	push   %edi
f01020dd:	56                   	push   %esi
f01020de:	8b 45 08             	mov    0x8(%ebp),%eax
f01020e1:	8b 75 0c             	mov    0xc(%ebp),%esi
f01020e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01020e7:	39 c6                	cmp    %eax,%esi
f01020e9:	73 33                	jae    f010211e <memmove+0x45>
f01020eb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01020ee:	39 c2                	cmp    %eax,%edx
f01020f0:	76 2c                	jbe    f010211e <memmove+0x45>
		s += n;
		d += n;
f01020f2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01020f5:	89 d6                	mov    %edx,%esi
f01020f7:	09 fe                	or     %edi,%esi
f01020f9:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01020ff:	74 0a                	je     f010210b <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0102101:	4f                   	dec    %edi
f0102102:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0102105:	fd                   	std    
f0102106:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0102108:	fc                   	cld    
f0102109:	eb 21                	jmp    f010212c <memmove+0x53>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010210b:	f6 c1 03             	test   $0x3,%cl
f010210e:	75 f1                	jne    f0102101 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0102110:	83 ef 04             	sub    $0x4,%edi
f0102113:	8d 72 fc             	lea    -0x4(%edx),%esi
f0102116:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0102119:	fd                   	std    
f010211a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010211c:	eb ea                	jmp    f0102108 <memmove+0x2f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010211e:	89 f2                	mov    %esi,%edx
f0102120:	09 c2                	or     %eax,%edx
f0102122:	f6 c2 03             	test   $0x3,%dl
f0102125:	74 09                	je     f0102130 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0102127:	89 c7                	mov    %eax,%edi
f0102129:	fc                   	cld    
f010212a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010212c:	5e                   	pop    %esi
f010212d:	5f                   	pop    %edi
f010212e:	5d                   	pop    %ebp
f010212f:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0102130:	f6 c1 03             	test   $0x3,%cl
f0102133:	75 f2                	jne    f0102127 <memmove+0x4e>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0102135:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0102138:	89 c7                	mov    %eax,%edi
f010213a:	fc                   	cld    
f010213b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010213d:	eb ed                	jmp    f010212c <memmove+0x53>

f010213f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010213f:	55                   	push   %ebp
f0102140:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0102142:	ff 75 10             	pushl  0x10(%ebp)
f0102145:	ff 75 0c             	pushl  0xc(%ebp)
f0102148:	ff 75 08             	pushl  0x8(%ebp)
f010214b:	e8 89 ff ff ff       	call   f01020d9 <memmove>
}
f0102150:	c9                   	leave  
f0102151:	c3                   	ret    

f0102152 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0102152:	55                   	push   %ebp
f0102153:	89 e5                	mov    %esp,%ebp
f0102155:	56                   	push   %esi
f0102156:	53                   	push   %ebx
f0102157:	8b 45 08             	mov    0x8(%ebp),%eax
f010215a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010215d:	89 c6                	mov    %eax,%esi
f010215f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0102162:	39 f0                	cmp    %esi,%eax
f0102164:	74 16                	je     f010217c <memcmp+0x2a>
		if (*s1 != *s2)
f0102166:	8a 08                	mov    (%eax),%cl
f0102168:	8a 1a                	mov    (%edx),%bl
f010216a:	38 d9                	cmp    %bl,%cl
f010216c:	75 04                	jne    f0102172 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010216e:	40                   	inc    %eax
f010216f:	42                   	inc    %edx
f0102170:	eb f0                	jmp    f0102162 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0102172:	0f b6 c1             	movzbl %cl,%eax
f0102175:	0f b6 db             	movzbl %bl,%ebx
f0102178:	29 d8                	sub    %ebx,%eax
f010217a:	eb 05                	jmp    f0102181 <memcmp+0x2f>
	}

	return 0;
f010217c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102181:	5b                   	pop    %ebx
f0102182:	5e                   	pop    %esi
f0102183:	5d                   	pop    %ebp
f0102184:	c3                   	ret    

f0102185 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0102185:	55                   	push   %ebp
f0102186:	89 e5                	mov    %esp,%ebp
f0102188:	8b 45 08             	mov    0x8(%ebp),%eax
f010218b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010218e:	89 c2                	mov    %eax,%edx
f0102190:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0102193:	39 d0                	cmp    %edx,%eax
f0102195:	73 07                	jae    f010219e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
f0102197:	38 08                	cmp    %cl,(%eax)
f0102199:	74 03                	je     f010219e <memfind+0x19>
	for (; s < ends; s++)
f010219b:	40                   	inc    %eax
f010219c:	eb f5                	jmp    f0102193 <memfind+0xe>
			break;
	return (void *) s;
}
f010219e:	5d                   	pop    %ebp
f010219f:	c3                   	ret    

f01021a0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01021a0:	55                   	push   %ebp
f01021a1:	89 e5                	mov    %esp,%ebp
f01021a3:	57                   	push   %edi
f01021a4:	56                   	push   %esi
f01021a5:	53                   	push   %ebx
f01021a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01021a9:	eb 01                	jmp    f01021ac <strtol+0xc>
		s++;
f01021ab:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f01021ac:	8a 01                	mov    (%ecx),%al
f01021ae:	3c 20                	cmp    $0x20,%al
f01021b0:	74 f9                	je     f01021ab <strtol+0xb>
f01021b2:	3c 09                	cmp    $0x9,%al
f01021b4:	74 f5                	je     f01021ab <strtol+0xb>

	// plus/minus sign
	if (*s == '+')
f01021b6:	3c 2b                	cmp    $0x2b,%al
f01021b8:	74 2b                	je     f01021e5 <strtol+0x45>
		s++;
	else if (*s == '-')
f01021ba:	3c 2d                	cmp    $0x2d,%al
f01021bc:	74 2f                	je     f01021ed <strtol+0x4d>
	int neg = 0;
f01021be:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01021c3:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f01021ca:	75 12                	jne    f01021de <strtol+0x3e>
f01021cc:	80 39 30             	cmpb   $0x30,(%ecx)
f01021cf:	74 24                	je     f01021f5 <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01021d1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01021d5:	75 07                	jne    f01021de <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01021d7:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f01021de:	b8 00 00 00 00       	mov    $0x0,%eax
f01021e3:	eb 4e                	jmp    f0102233 <strtol+0x93>
		s++;
f01021e5:	41                   	inc    %ecx
	int neg = 0;
f01021e6:	bf 00 00 00 00       	mov    $0x0,%edi
f01021eb:	eb d6                	jmp    f01021c3 <strtol+0x23>
		s++, neg = 1;
f01021ed:	41                   	inc    %ecx
f01021ee:	bf 01 00 00 00       	mov    $0x1,%edi
f01021f3:	eb ce                	jmp    f01021c3 <strtol+0x23>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01021f5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01021f9:	74 10                	je     f010220b <strtol+0x6b>
	else if (base == 0 && s[0] == '0')
f01021fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01021ff:	75 dd                	jne    f01021de <strtol+0x3e>
		s++, base = 8;
f0102201:	41                   	inc    %ecx
f0102202:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f0102209:	eb d3                	jmp    f01021de <strtol+0x3e>
		s += 2, base = 16;
f010220b:	83 c1 02             	add    $0x2,%ecx
f010220e:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f0102215:	eb c7                	jmp    f01021de <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0102217:	8d 72 9f             	lea    -0x61(%edx),%esi
f010221a:	89 f3                	mov    %esi,%ebx
f010221c:	80 fb 19             	cmp    $0x19,%bl
f010221f:	77 24                	ja     f0102245 <strtol+0xa5>
			dig = *s - 'a' + 10;
f0102221:	0f be d2             	movsbl %dl,%edx
f0102224:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0102227:	3b 55 10             	cmp    0x10(%ebp),%edx
f010222a:	7d 2b                	jge    f0102257 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
f010222c:	41                   	inc    %ecx
f010222d:	0f af 45 10          	imul   0x10(%ebp),%eax
f0102231:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0102233:	8a 11                	mov    (%ecx),%dl
f0102235:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0102238:	80 fb 09             	cmp    $0x9,%bl
f010223b:	77 da                	ja     f0102217 <strtol+0x77>
			dig = *s - '0';
f010223d:	0f be d2             	movsbl %dl,%edx
f0102240:	83 ea 30             	sub    $0x30,%edx
f0102243:	eb e2                	jmp    f0102227 <strtol+0x87>
		else if (*s >= 'A' && *s <= 'Z')
f0102245:	8d 72 bf             	lea    -0x41(%edx),%esi
f0102248:	89 f3                	mov    %esi,%ebx
f010224a:	80 fb 19             	cmp    $0x19,%bl
f010224d:	77 08                	ja     f0102257 <strtol+0xb7>
			dig = *s - 'A' + 10;
f010224f:	0f be d2             	movsbl %dl,%edx
f0102252:	83 ea 37             	sub    $0x37,%edx
f0102255:	eb d0                	jmp    f0102227 <strtol+0x87>
		// we don't properly detect overflow!
	}

	if (endptr)
f0102257:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010225b:	74 05                	je     f0102262 <strtol+0xc2>
		*endptr = (char *) s;
f010225d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102260:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0102262:	85 ff                	test   %edi,%edi
f0102264:	74 02                	je     f0102268 <strtol+0xc8>
f0102266:	f7 d8                	neg    %eax
}
f0102268:	5b                   	pop    %ebx
f0102269:	5e                   	pop    %esi
f010226a:	5f                   	pop    %edi
f010226b:	5d                   	pop    %ebp
f010226c:	c3                   	ret    
f010226d:	66 90                	xchg   %ax,%ax
f010226f:	90                   	nop

f0102270 <__udivdi3>:
f0102270:	55                   	push   %ebp
f0102271:	57                   	push   %edi
f0102272:	56                   	push   %esi
f0102273:	53                   	push   %ebx
f0102274:	83 ec 1c             	sub    $0x1c,%esp
f0102277:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010227b:	8b 74 24 34          	mov    0x34(%esp),%esi
f010227f:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0102283:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0102287:	85 d2                	test   %edx,%edx
f0102289:	75 2d                	jne    f01022b8 <__udivdi3+0x48>
f010228b:	39 f7                	cmp    %esi,%edi
f010228d:	77 59                	ja     f01022e8 <__udivdi3+0x78>
f010228f:	89 f9                	mov    %edi,%ecx
f0102291:	85 ff                	test   %edi,%edi
f0102293:	75 0b                	jne    f01022a0 <__udivdi3+0x30>
f0102295:	b8 01 00 00 00       	mov    $0x1,%eax
f010229a:	31 d2                	xor    %edx,%edx
f010229c:	f7 f7                	div    %edi
f010229e:	89 c1                	mov    %eax,%ecx
f01022a0:	31 d2                	xor    %edx,%edx
f01022a2:	89 f0                	mov    %esi,%eax
f01022a4:	f7 f1                	div    %ecx
f01022a6:	89 c3                	mov    %eax,%ebx
f01022a8:	89 e8                	mov    %ebp,%eax
f01022aa:	f7 f1                	div    %ecx
f01022ac:	89 da                	mov    %ebx,%edx
f01022ae:	83 c4 1c             	add    $0x1c,%esp
f01022b1:	5b                   	pop    %ebx
f01022b2:	5e                   	pop    %esi
f01022b3:	5f                   	pop    %edi
f01022b4:	5d                   	pop    %ebp
f01022b5:	c3                   	ret    
f01022b6:	66 90                	xchg   %ax,%ax
f01022b8:	39 f2                	cmp    %esi,%edx
f01022ba:	77 1c                	ja     f01022d8 <__udivdi3+0x68>
f01022bc:	0f bd da             	bsr    %edx,%ebx
f01022bf:	83 f3 1f             	xor    $0x1f,%ebx
f01022c2:	75 38                	jne    f01022fc <__udivdi3+0x8c>
f01022c4:	39 f2                	cmp    %esi,%edx
f01022c6:	72 08                	jb     f01022d0 <__udivdi3+0x60>
f01022c8:	39 ef                	cmp    %ebp,%edi
f01022ca:	0f 87 98 00 00 00    	ja     f0102368 <__udivdi3+0xf8>
f01022d0:	b8 01 00 00 00       	mov    $0x1,%eax
f01022d5:	eb 05                	jmp    f01022dc <__udivdi3+0x6c>
f01022d7:	90                   	nop
f01022d8:	31 db                	xor    %ebx,%ebx
f01022da:	31 c0                	xor    %eax,%eax
f01022dc:	89 da                	mov    %ebx,%edx
f01022de:	83 c4 1c             	add    $0x1c,%esp
f01022e1:	5b                   	pop    %ebx
f01022e2:	5e                   	pop    %esi
f01022e3:	5f                   	pop    %edi
f01022e4:	5d                   	pop    %ebp
f01022e5:	c3                   	ret    
f01022e6:	66 90                	xchg   %ax,%ax
f01022e8:	89 e8                	mov    %ebp,%eax
f01022ea:	89 f2                	mov    %esi,%edx
f01022ec:	f7 f7                	div    %edi
f01022ee:	31 db                	xor    %ebx,%ebx
f01022f0:	89 da                	mov    %ebx,%edx
f01022f2:	83 c4 1c             	add    $0x1c,%esp
f01022f5:	5b                   	pop    %ebx
f01022f6:	5e                   	pop    %esi
f01022f7:	5f                   	pop    %edi
f01022f8:	5d                   	pop    %ebp
f01022f9:	c3                   	ret    
f01022fa:	66 90                	xchg   %ax,%ax
f01022fc:	b8 20 00 00 00       	mov    $0x20,%eax
f0102301:	29 d8                	sub    %ebx,%eax
f0102303:	88 d9                	mov    %bl,%cl
f0102305:	d3 e2                	shl    %cl,%edx
f0102307:	89 54 24 08          	mov    %edx,0x8(%esp)
f010230b:	89 fa                	mov    %edi,%edx
f010230d:	88 c1                	mov    %al,%cl
f010230f:	d3 ea                	shr    %cl,%edx
f0102311:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0102315:	09 d1                	or     %edx,%ecx
f0102317:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010231b:	88 d9                	mov    %bl,%cl
f010231d:	d3 e7                	shl    %cl,%edi
f010231f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102323:	89 f7                	mov    %esi,%edi
f0102325:	88 c1                	mov    %al,%cl
f0102327:	d3 ef                	shr    %cl,%edi
f0102329:	88 d9                	mov    %bl,%cl
f010232b:	d3 e6                	shl    %cl,%esi
f010232d:	89 ea                	mov    %ebp,%edx
f010232f:	88 c1                	mov    %al,%cl
f0102331:	d3 ea                	shr    %cl,%edx
f0102333:	09 d6                	or     %edx,%esi
f0102335:	89 f0                	mov    %esi,%eax
f0102337:	89 fa                	mov    %edi,%edx
f0102339:	f7 74 24 08          	divl   0x8(%esp)
f010233d:	89 d7                	mov    %edx,%edi
f010233f:	89 c6                	mov    %eax,%esi
f0102341:	f7 64 24 0c          	mull   0xc(%esp)
f0102345:	39 d7                	cmp    %edx,%edi
f0102347:	72 13                	jb     f010235c <__udivdi3+0xec>
f0102349:	74 09                	je     f0102354 <__udivdi3+0xe4>
f010234b:	89 f0                	mov    %esi,%eax
f010234d:	31 db                	xor    %ebx,%ebx
f010234f:	eb 8b                	jmp    f01022dc <__udivdi3+0x6c>
f0102351:	8d 76 00             	lea    0x0(%esi),%esi
f0102354:	88 d9                	mov    %bl,%cl
f0102356:	d3 e5                	shl    %cl,%ebp
f0102358:	39 c5                	cmp    %eax,%ebp
f010235a:	73 ef                	jae    f010234b <__udivdi3+0xdb>
f010235c:	8d 46 ff             	lea    -0x1(%esi),%eax
f010235f:	31 db                	xor    %ebx,%ebx
f0102361:	e9 76 ff ff ff       	jmp    f01022dc <__udivdi3+0x6c>
f0102366:	66 90                	xchg   %ax,%ax
f0102368:	31 c0                	xor    %eax,%eax
f010236a:	e9 6d ff ff ff       	jmp    f01022dc <__udivdi3+0x6c>
f010236f:	90                   	nop

f0102370 <__umoddi3>:
f0102370:	55                   	push   %ebp
f0102371:	57                   	push   %edi
f0102372:	56                   	push   %esi
f0102373:	53                   	push   %ebx
f0102374:	83 ec 1c             	sub    $0x1c,%esp
f0102377:	8b 74 24 30          	mov    0x30(%esp),%esi
f010237b:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f010237f:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0102383:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0102387:	89 f0                	mov    %esi,%eax
f0102389:	89 da                	mov    %ebx,%edx
f010238b:	85 ed                	test   %ebp,%ebp
f010238d:	75 15                	jne    f01023a4 <__umoddi3+0x34>
f010238f:	39 df                	cmp    %ebx,%edi
f0102391:	76 39                	jbe    f01023cc <__umoddi3+0x5c>
f0102393:	f7 f7                	div    %edi
f0102395:	89 d0                	mov    %edx,%eax
f0102397:	31 d2                	xor    %edx,%edx
f0102399:	83 c4 1c             	add    $0x1c,%esp
f010239c:	5b                   	pop    %ebx
f010239d:	5e                   	pop    %esi
f010239e:	5f                   	pop    %edi
f010239f:	5d                   	pop    %ebp
f01023a0:	c3                   	ret    
f01023a1:	8d 76 00             	lea    0x0(%esi),%esi
f01023a4:	39 dd                	cmp    %ebx,%ebp
f01023a6:	77 f1                	ja     f0102399 <__umoddi3+0x29>
f01023a8:	0f bd cd             	bsr    %ebp,%ecx
f01023ab:	83 f1 1f             	xor    $0x1f,%ecx
f01023ae:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01023b2:	75 38                	jne    f01023ec <__umoddi3+0x7c>
f01023b4:	39 dd                	cmp    %ebx,%ebp
f01023b6:	72 04                	jb     f01023bc <__umoddi3+0x4c>
f01023b8:	39 f7                	cmp    %esi,%edi
f01023ba:	77 dd                	ja     f0102399 <__umoddi3+0x29>
f01023bc:	89 da                	mov    %ebx,%edx
f01023be:	89 f0                	mov    %esi,%eax
f01023c0:	29 f8                	sub    %edi,%eax
f01023c2:	19 ea                	sbb    %ebp,%edx
f01023c4:	83 c4 1c             	add    $0x1c,%esp
f01023c7:	5b                   	pop    %ebx
f01023c8:	5e                   	pop    %esi
f01023c9:	5f                   	pop    %edi
f01023ca:	5d                   	pop    %ebp
f01023cb:	c3                   	ret    
f01023cc:	89 f9                	mov    %edi,%ecx
f01023ce:	85 ff                	test   %edi,%edi
f01023d0:	75 0b                	jne    f01023dd <__umoddi3+0x6d>
f01023d2:	b8 01 00 00 00       	mov    $0x1,%eax
f01023d7:	31 d2                	xor    %edx,%edx
f01023d9:	f7 f7                	div    %edi
f01023db:	89 c1                	mov    %eax,%ecx
f01023dd:	89 d8                	mov    %ebx,%eax
f01023df:	31 d2                	xor    %edx,%edx
f01023e1:	f7 f1                	div    %ecx
f01023e3:	89 f0                	mov    %esi,%eax
f01023e5:	f7 f1                	div    %ecx
f01023e7:	eb ac                	jmp    f0102395 <__umoddi3+0x25>
f01023e9:	8d 76 00             	lea    0x0(%esi),%esi
f01023ec:	b8 20 00 00 00       	mov    $0x20,%eax
f01023f1:	89 c2                	mov    %eax,%edx
f01023f3:	8b 44 24 04          	mov    0x4(%esp),%eax
f01023f7:	29 c2                	sub    %eax,%edx
f01023f9:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01023fd:	88 c1                	mov    %al,%cl
f01023ff:	d3 e5                	shl    %cl,%ebp
f0102401:	89 f8                	mov    %edi,%eax
f0102403:	88 d1                	mov    %dl,%cl
f0102405:	d3 e8                	shr    %cl,%eax
f0102407:	09 c5                	or     %eax,%ebp
f0102409:	8b 44 24 04          	mov    0x4(%esp),%eax
f010240d:	88 c1                	mov    %al,%cl
f010240f:	d3 e7                	shl    %cl,%edi
f0102411:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0102415:	89 df                	mov    %ebx,%edi
f0102417:	88 d1                	mov    %dl,%cl
f0102419:	d3 ef                	shr    %cl,%edi
f010241b:	88 c1                	mov    %al,%cl
f010241d:	d3 e3                	shl    %cl,%ebx
f010241f:	89 f0                	mov    %esi,%eax
f0102421:	88 d1                	mov    %dl,%cl
f0102423:	d3 e8                	shr    %cl,%eax
f0102425:	09 d8                	or     %ebx,%eax
f0102427:	8a 4c 24 04          	mov    0x4(%esp),%cl
f010242b:	d3 e6                	shl    %cl,%esi
f010242d:	89 fa                	mov    %edi,%edx
f010242f:	f7 f5                	div    %ebp
f0102431:	89 d1                	mov    %edx,%ecx
f0102433:	f7 64 24 08          	mull   0x8(%esp)
f0102437:	89 c3                	mov    %eax,%ebx
f0102439:	89 d7                	mov    %edx,%edi
f010243b:	39 d1                	cmp    %edx,%ecx
f010243d:	72 29                	jb     f0102468 <__umoddi3+0xf8>
f010243f:	74 23                	je     f0102464 <__umoddi3+0xf4>
f0102441:	89 ca                	mov    %ecx,%edx
f0102443:	29 de                	sub    %ebx,%esi
f0102445:	19 fa                	sbb    %edi,%edx
f0102447:	89 d0                	mov    %edx,%eax
f0102449:	8a 4c 24 0c          	mov    0xc(%esp),%cl
f010244d:	d3 e0                	shl    %cl,%eax
f010244f:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0102453:	88 d9                	mov    %bl,%cl
f0102455:	d3 ee                	shr    %cl,%esi
f0102457:	09 f0                	or     %esi,%eax
f0102459:	d3 ea                	shr    %cl,%edx
f010245b:	83 c4 1c             	add    $0x1c,%esp
f010245e:	5b                   	pop    %ebx
f010245f:	5e                   	pop    %esi
f0102460:	5f                   	pop    %edi
f0102461:	5d                   	pop    %ebp
f0102462:	c3                   	ret    
f0102463:	90                   	nop
f0102464:	39 c6                	cmp    %eax,%esi
f0102466:	73 d9                	jae    f0102441 <__umoddi3+0xd1>
f0102468:	2b 44 24 08          	sub    0x8(%esp),%eax
f010246c:	19 ea                	sbb    %ebp,%edx
f010246e:	89 d7                	mov    %edx,%edi
f0102470:	89 c3                	mov    %eax,%ebx
f0102472:	eb cd                	jmp    f0102441 <__umoddi3+0xd1>
